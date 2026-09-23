-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\NetHandler.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local GateClient = require("Core.Client.GateClient")
local LoggerManager = require("Core.Log.LoggerManager")
local ProtobufConst = require("Core.Common.ProtobufConst")
local IDManager = require("Core.Common.IDManager")
local NetHandler = class.Class("NetHandler")

NetHandler.RECONNECT_FINALIZE_DELAY = 1
NetHandler.RECONNECT_PAUSE_MAX_TIME = 30

local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local Switch = require("Core.Common.Switch")
local ClientUtils = require("Utils.ClientUtils")
local TimerManager = require("Core.Timer.TimerManager")
local lume = require("Core.Common.lume")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local CommonSwitch = require("Common.CommonSwitch")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local RECONNECT_TIMEOUT_COUNT = 60
local RECONNECT_RETRY_DELAY = 2
local HEARTBEAT_RECONNECT_TIMEOUT = 5
local SOUL_GAP_RECONNECT_WINDOW = 10
local SOUL_GAP_RECONNECT_MAX = 5
local BIND_SOUL_REASON_LOGIN_REBIND = 1
local premiumResumeRetryTimer
local premiumResumeChecking = false
local resumePremiumFeatureSessionAfterReconnectUiClosed

local function schedulePremiumResumeAfterReconnectUiClosed()
	if premiumResumeRetryTimer ~= nil then
		return
	end

	premiumResumeRetryTimer = TimerManager.addTimer(1, function()
		premiumResumeRetryTimer = nil

		resumePremiumFeatureSessionAfterReconnectUiClosed()
	end)
end

local function isLoginGameState()
	local gameState = pg and pg.game and pg.game.gameState

	return gameState == nil or gameState == ClientConst.GS_CONNECT or gameState == ClientConst.GS_LOGIN
end

local function shouldResumePremiumFeatureSession()
	local space = pg and pg.space
	local multiPlayerEnv = space and space.isMultiPlayerEnv and space:isMultiPlayerEnv() == true
	local me = pg and pg.me
	local selfInTeam = me and type(me.isInTeam) == "function" and me:isInTeam() == true

	return not isLoginGameState() and (multiPlayerEnv or selfInTeam)
end

function resumePremiumFeatureSessionAfterReconnectUiClosed()
	if premiumResumeChecking then
		return
	end

	local ui = pg and pg.global and pg.global.ui

	if ui == nil or ui:checkUIOpen(UIConst.UI_ID_NET_LOADING) or ui:checkUIOpen(UIConst.UI_ID_COMMON_CONFIRM) then
		schedulePremiumResumeAfterReconnectUiClosed()

		return
	end

	if not shouldResumePremiumFeatureSession() then
		return
	end

	premiumResumeChecking = true

	local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")

	PlatformPremiumFeatureService:checkEligibility(function(success)
		premiumResumeChecking = false

		if success ~= true then
			ClientUtils.backToHome()

			return true
		end

		PlatformPremiumFeatureService:beginSession("cross_play", function()
			return true
		end, 0)

		return true
	end, 0)
end

function NetHandler:ctor(config)
	self.gateClient = nil
	self.gateClientSoul = nil
	self.connectCb = nil
	self.disconnectCb = nil
	self.bindSoulSucceedCb = nil
	self.bindSoulFailedCb = nil
	self.serverList = {}
	self.soulInfo = nil
	self.tempSoulGates = {}
	self.soulConnected = false
	self.ip = nil
	self.port = nil
	self.clusterId = nil
	self.connectToken = nil
	self.connLogicWithKcp = false
	self.connBattleWithKcp = false
	self.config = config or {}
	self.deviceid = IDManager.genB64ID()
	self.rebindSoulCount = 0
	self.rebindSoulTimer = nil
	self._reconnectFinalizeTimer = nil
	self._lastTTL = nil
	self._TTL = 0
	self._TTLTimer = nil
	self._lastHeartbeatRecvTime = nil
	self._lastHeartbeatTimerTickTime = nil
	self._heartbeatReconnectTriggered = false
	self._heartbeatTimeoutPaused = false
	self._heartbeatExpiredCount = 0
	self._autoReconnect = true
	self._reconnectFailedCount = 0
	self._clientRpcSeqId = 0
	self._reconnectClientRpcSeqId = 0
	self._soulReplayResumed = false
	self._loseConnectTestFullSync = false
	self.logger = LoggerManager.getLogger("NetHandler")
end

function NetHandler:_clearSoulReplayReconnectState()
	self._soulReplayResumed = false
end

function NetHandler:onSoulReplayResumeConnected()
	self._soulReplayResumed = true
end

function NetHandler:setLoseConnectTestFullSync(isFullSync)
	self._loseConnectTestFullSync = isFullSync == true
end

function NetHandler:consumeLoseConnectTestFullSync()
	local isFullSync = self._loseConnectTestFullSync == true

	self._loseConnectTestFullSync = false

	return isFullSync
end

function NetHandler:getClientRpcSeqId(isSoul)
	if isSoul then
		if self._clientRpcSeqId and self._clientRpcSeqId > 0 then
			return self._clientRpcSeqId
		end

		return self._reconnectClientRpcSeqId or 0
	end

	return 0
end

function NetHandler:updateClientRpcSeqId(seqId, isSoul)
	if isSoul then
		seqId = seqId or 0
		self._clientRpcSeqId = seqId

		if seqId > 0 then
			self._reconnectClientRpcSeqId = seqId
		else
			self._reconnectClientRpcSeqId = 0
		end
	end
end

function NetHandler:onClientRpcSeqGap(expectedSeqId, actualSeqId, isSoul)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("Client RPC seq gap expected=%s actual=%s isSoul=%s", tostring(expectedSeqId), tostring(actualSeqId), tostring(isSoul))
	end

	if not isSoul then
		return
	end

	if self:getClientRpcSeqId(true) == 0 and self.gateClientSoul ~= nil and self.gateClientSoul.handler ~= nil and self.gateClientSoul.handler.resumeEntityServer ~= nil and self.gateClientSoul.handler:resumeEntityServer() then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("client RPC seq gap with cursor 0, soul serverProxy rebound, keep session")
		end

		return
	end

	local now = Time.getTickSecond()

	if now > (self._soulGapReconnectAt or 0) + SOUL_GAP_RECONNECT_WINDOW then
		self._soulGapReconnectCount = 0
	end

	self._soulGapReconnectAt = now
	self._soulGapReconnectCount = (self._soulGapReconnectCount or 0) + 1

	if self._soulGapReconnectCount > SOUL_GAP_RECONNECT_MAX then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("soul rpc gap reconnect throttled, stop auto reconnect")
		end

		self.rebindSoulCount = 0

		self:stopAutoReconnect()

		return
	end

	if isSoul and self.gateClientSoul and self.gateClientSoul.session then
		self.gateClientSoul.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
	end
end

function NetHandler:setConnectLogicWithKcp(useKcp)
	self.connLogicWithKcp = useKcp
end

function NetHandler:setConnectBattleWithKcp(useKcp)
	self.connBattleWithKcp = useKcp
end

function NetHandler:setServerList(serverList)
	self.serverList = serverList
end

function NetHandler:getServerList()
	return self.serverList
end

function NetHandler:getTargetServer(clusterId)
	return lume.match(self.serverList, function(v)
		return v.ClusterId == clusterId
	end)
end

function NetHandler:setClusterId(clusterId)
	self.clusterId = clusterId
end

function NetHandler:setAddress(ip, port)
	self.ip = ip
	self.port = port
end

function NetHandler:setConnectToken(token)
	self.connectToken = token
end

function NetHandler:connect()
	self:_createGateClient(self.ip, self.port)
	self.gateClient:connect(ProtobufConst.CONNECT_REQUEST_TYPE_NEW_CONNECTION)
end

function NetHandler:reconnect(reconnectInfo)
	self:_createGateClient(self.ip, self.port)
	self.gateClient:reconnect(reconnectInfo)
end

function NetHandler:close()
	self:_cancelReconnectFinalize()

	if self.gateClient ~= nil then
		self.gateClient:close()

		self.gateClient = nil
	end

	if self.gateClientSoul ~= nil then
		self.gateClientSoul:close()

		self.gateClientSoul = nil
	end

	self.soulInfo = nil
	self.tempSoulGates = {}
	self.soulConnected = false
	self._clientRpcSeqId = 0
	self._reconnectClientRpcSeqId = 0
	self._loseConnectTestFullSync = false

	self:_clearSoulReplayReconnectState()

	self.rebindSoulCount = 0

	self:_stopRebindSoulTimer()
	self:_stopTTL()
end

function NetHandler:rebindSoul()
	assert(self.soulInfo ~= nil)

	if self.soulInfo ~= nil then
		self:_bindSoul(self.soulInfo)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("client rebind soul without valid soulInfo")
	end
end

function NetHandler:unbindSoul()
	assert(self.soulInfo ~= nil)

	if self.soulInfo ~= nil then
		self:_unbindSoul()
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("client unbind soul without valid soulInfo")
	end
end

function NetHandler:_bindSoul(soulInfo, rebindFlag)
	self:_unbindSoul()

	self.soulInfo = soulInfo
	self.tempSoulGates = {}

	for _, gate in ipairs(soulInfo.gates) do
		table.insert(self.tempSoulGates, gate)
	end

	self:_createGateClientSoul()

	if self.gateClientSoul ~= nil then
		local bindInfo = {
			auth = soulInfo.auth,
			mb = soulInfo.soulMbBin
		}

		if rebindFlag then
			self.gateClientSoul:connect(ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL, bindInfo)
		else
			self.gateClientSoul:connect(ProtobufConst.CONNECT_REQUEST_TYPE_BIND_SOUL, bindInfo)
		end
	elseif self.bindSoulFailedCb ~= nil then
		self.bindSoulFailedCb(ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE)
	end
end

function NetHandler:_isSameSoul(soulInfo)
	return self.soulInfo ~= nil and soulInfo ~= nil and soulInfo.soulMbBin ~= nil and soulInfo.soulMbBin ~= "" and self.soulInfo.soulMbBin == soulInfo.soulMbBin
end

function NetHandler:_refreshSoulInfo(soulInfo)
	self.soulInfo = soulInfo
	self.tempSoulGates = {}

	for _, gate in ipairs(soulInfo.gates or EMPTY_TABLE) do
		table.insert(self.tempSoulGates, gate)
	end
end

function NetHandler:_canSkipSameSoulLoginRebind()
	local game = pg and pg.game
	local seamless = game and game.seamless

	if seamless and seamless:seam_sys_isSwitchSeamless() then
		return false
	end

	local global = pg and pg.global
	local me = pg and pg.me
	local space = pg and pg.space
	local scene = global and global.scene

	if me == nil or space == nil or me.space ~= space or scene == nil or scene.curSpace ~= space or scene.isSceneReady == false then
		return false
	end

	local ui = global and global.ui

	return ui == nil or not ui:checkUIShow(UIConst.UI_ID_LOADING) and not ui:checkUIShow(UIConst.UI_ID_LOADING_SHOW)
end

function NetHandler:bindSoulFromMs(soulInfo, reason)
	if CommonSwitch.ClientRpcReplayReconnect and self:_isSameSoul(soulInfo) then
		local soulReplayResumed = self._soulReplayResumed
		local rpcSeqId = self:getClientRpcSeqId(true)

		self:_clearSoulReplayReconnectState()
		self:_refreshSoulInfo(soulInfo)

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("bindSoulFromMs same soul state reason=%s soulConnected=%s hasGateClientSoul=%s soulReplayResumed=%s clientRpcSeqId=%s", tostring(reason), tostring(self.soulConnected), tostring(self.gateClientSoul ~= nil), tostring(soulReplayResumed), tostring(rpcSeqId))
		end

		if reason == BIND_SOUL_REASON_LOGIN_REBIND and self.soulConnected and self.gateClientSoul ~= nil and self:_canSkipSameSoulLoginRebind() then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				self.logger:info("bindSoulFromMs same soul login_rebind with connected soul, refresh soulInfo and skip bind")
			end

			self:_stopRebindSoulTimer()

			return
		end

		if not self.soulConnected and rpcSeqId > 0 then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				self.logger:info("bindSoulFromMs same soul disconnected, rebind with clientRpcSeqId=%s", tostring(rpcSeqId))
			end

			self:_rebindSoulHandler()

			return
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("bindSoulFromMs same soul without clientRpcSeqId, fallback to bind")
		end
	end

	self:_bindSoul(soulInfo)
end

function NetHandler:_unbindSoul()
	self:_stopTTL()

	if self.gateClientSoul ~= nil then
		self.gateClientSoul:close()

		self.gateClientSoul = nil
	end

	self._clientRpcSeqId = 0
	self._reconnectClientRpcSeqId = 0
	self._loseConnectTestFullSync = false

	self:_clearSoulReplayReconnectState()

	self.soulInfo = nil
	self.tempSoulGates = {}
	self.soulConnected = false
end

function NetHandler:_onConnect(connType, onlineInfo)
	if self.connectCb ~= nil then
		self.connectCb(connType, onlineInfo)
	end
end

function NetHandler:_onDisconnect(connType)
	if self.disconnectCb ~= nil then
		self.disconnectCb(connType)
	end
end

function NetHandler:_createGateClient(ip, port)
	if self.gateClient ~= nil then
		self.gateClient:close()
	end

	self.gateClient = GateClient(self, ip, port, self.deviceid, false, self.config, self.connLogicWithKcp)

	self.gateClient:regConnectCb(CallbackHandler(self, "_onConnect"))
	self.gateClient:regDisconnectCb(CallbackHandler(self, "_onDisconnect"))
	self.gateClient:regBindSoulHandler(CallbackHandler(self, "_bindSoul"))
	self.gateClient:regUnbindSoulHandler(CallbackHandler(self, "_unbindSoul"))
end

function NetHandler:_cancelReconnectFinalize()
	if self._reconnectFinalizeTimer ~= nil then
		TimerManager.removeTimer(self._reconnectFinalizeTimer)

		self._reconnectFinalizeTimer = nil
	end
end

function NetHandler:_finishReconnectAfterDelay(shouldFinalizeReconnect)
	self._reconnectFinalizeTimer = nil

	if not self.soulConnected then
		return
	end

	local ui = pg and pg.global and pg.global.ui

	if ui and ui:checkUIOpen(UIConst.UI_ID_NET_LOADING) then
		ui:close(UIConst.UI_ID_NET_LOADING)
	end

	local reconnectSpace = pg and pg.space

	if reconnectSpace then
		reconnectSpace:resumeGameByType(Const.GameTimeScaleType.RECONNECT)
	end

	if not shouldFinalizeReconnect then
		return
	end

	resumePremiumFeatureSessionAfterReconnectUiClosed()

	local space = pg and pg.space

	if space then
		ClientUtils.tryWithLogErrorEx(space.CheckAndSetGameTimeStatus, space)
	end
end

function NetHandler:_onSoulConnect(connType)
	local shouldFinalizeReconnect = self.rebindSoulCount > 0 or self._reconnectTipShowing == true

	self:_cancelReconnectFinalize()

	self.soulConnected = true

	if self.bindSoulSucceedCb ~= nil then
		self.bindSoulSucceedCb()
	end

	self.rebindSoulCount = 0
	self._reconnectFailedCount = 0

	self:_stopRebindSoulTimer()

	if self._reconnectTipShowing then
		self._reconnectTipShowing = false

		pg.global.ui:close(UIConst.UI_ID_COMMON_CONFIRM)
	end

	self._reconnectFinalizeTimer = TimerManager.addTimer(NetHandler.RECONNECT_FINALIZE_DELAY, CallbackHandler(self, "_finishReconnectAfterDelay", shouldFinalizeReconnect))

	if pg.me then
		pg.game:onConnected()
	end
end

function NetHandler:_stopRebindSoulTimer()
	if self.rebindSoulTimer ~= nil then
		TimerManager.removeTimer(self.rebindSoulTimer)

		self.rebindSoulTimer = nil
	end
end

function NetHandler:_rebindSoulHandler()
	self:_stopRebindSoulTimer()
	self:_createGateClientSoul()

	if self.gateClientSoul ~= nil then
		local bindInfo = {
			auth = self.soulInfo.auth,
			mb = self.soulInfo.soulMbBin
		}

		self.gateClientSoul:connect(ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL, bindInfo)
	elseif self.bindSoulFailedCb ~= nil then
		self.bindSoulFailedCb(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
	end
end

function NetHandler:_bindSoulRetryHandler()
	self:_stopRebindSoulTimer()
	self:_createGateClientSoul()

	if self.gateClientSoul ~= nil then
		local bindInfo = {
			auth = self.soulInfo.auth,
			mb = self.soulInfo.soulMbBin
		}
		local reqType = ProtobufConst.CONNECT_REQUEST_TYPE_BIND_SOUL

		if self:getClientRpcSeqId(true) > 0 then
			reqType = ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL
		end

		self.gateClientSoul:connect(reqType, bindInfo)
	else
		self.rebindSoulCount = 0

		if self.bindSoulFailedCb ~= nil then
			self.bindSoulFailedCb(ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE)
		end
	end
end

function NetHandler:_getReconnectMaxTimes()
	local n = tonumber(SysConfigData.RECONNECT_MAX_TIMES) or 3

	return math.max(n, 1)
end

function NetHandler:_handleSoulReconnect(connType, retryFn)
	local maxTimes = self:_getReconnectMaxTimes()

	self.rebindSoulCount = self.rebindSoulCount + 1

	if maxTimes < self.rebindSoulCount then
		self.rebindSoulTimer = TimerManager.addTimer(RECONNECT_RETRY_DELAY, CallbackHandler(self, "_showReconnectFailTip", connType, retryFn))
	else
		self:_startReconnectSpin(retryFn)
	end
end

function NetHandler:_showReconnectFailTip(connType, retryFn)
	self.rebindSoulTimer = nil

	if not pg.global.ui:checkUIVisible(UIConst.UI_ID_LOGIN) then
		self._reconnectTipShowing = true

		ClientUtils.showNetworkReconnectTip(function()
			self._reconnectTipShowing = false
			self.rebindSoulCount = 0

			self:_handleSoulReconnect(connType, retryFn)
		end)
	end
end

function NetHandler:_startReconnectSpin(retryFn)
	if self.rebindSoulCount == 1 then
		self:_doReconnect(retryFn)
	else
		self.rebindSoulTimer = TimerManager.addTimer(RECONNECT_RETRY_DELAY, CallbackHandler(self, "_doReconnect", retryFn))
	end
end

function NetHandler:_doReconnect(retryFn)
	if not pg.global.ui:checkUIVisible(UIConst.UI_ID_LOGIN) then
		pg.global.ui:open(UIConst.UI_ID_NET_LOADING, {
			reconnectCount = self.rebindSoulCount,
			maxReconnectCount = self:_getReconnectMaxTimes()
		})

		if pg.space then
			pg.space:pauseGameByType(Const.GameTimeScaleType.RECONNECT, NetHandler.RECONNECT_PAUSE_MAX_TIME)
		end
	end

	self[retryFn](self)
end

function NetHandler:_onSoulDisconnect(connType)
	self:_stopTTL()
	self:_cancelReconnectFinalize()

	self.soulConnected = false

	self:_clearSoulReplayReconnectState()
	pg.game:onDisconnected()

	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN then
		if self.soulInfo ~= nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				self.logger:warn("[1]bindSoul connect gate failed, choose another gate and retry...")
			end

			self:_handleSoulReconnect(connType, "_rebindSoulHandler")
		else
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				self.logger:warn("[1]soul connection disconnected, has no soulInfo to rebind!")
			end

			self.rebindSoulCount = 0

			self:_stopRebindSoulTimer()
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE or connType == ProtobufConst.CONNECT_RESPONSE_TYPE_BUSY then
		assert(self.soulInfo ~= nil)

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("[2]bindSoul connect gate failed, choose another gate and retry...")
		end

		if not self._autoReconnect then
			if self.bindSoulFailedCb ~= nil then
				self.bindSoulFailedCb(connType)
			end

			if LoggerManager.checkLogger(LoggerConst.WARN) then
				self.logger:warn("[2]soul connection disconnected timeout, has no soulInfo to rebind!")
			end

			self.rebindSoulCount = 0

			return
		end

		self:_handleSoulReconnect(connType, "_bindSoulRetryHandler")
		ClientUtils.checkNetwork()
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED or connType == ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN or connType == ProtobufConst.CONNECT_RESPONSE_TYPE_MAX_CONNECTIONS then
		if self.bindSoulFailedCb ~= nil then
			self.bindSoulFailedCb(connType)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORECONNECT then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("soul connection disconnected by server, no reconnect")
		end

		local ClientRepo = require("Core.Client.ClientRepo")
		local Time = require("Core.Common.Time")

		if not ClientRepo.notShowDisconnectStartTime then
			ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.SoulDisconnectNoReconnect_1)
		elseif Time.realSecondCache - ClientRepo.notShowDisconnectStartTime > 10 then
			ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.SoulDisconnectNoReconnect_2)
		end

		ClientRepo.notShowDisconnectStartTime = nil
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("soul connection disconnected with unknown type %s", connType)
	end
end

function NetHandler:_createGateClientSoul()
	if self.gateClientSoul ~= nil then
		self.gateClientSoul:close()

		self.gateClientSoul = nil
	end

	if #self.tempSoulGates > 0 then
		local targetGate = table.remove(self.tempSoulGates, 1)
		local soulClient = GateClient(self, targetGate.ip, targetGate.port, self.deviceid, true, self.config, self.connBattleWithKcp)

		self.gateClientSoul = soulClient

		soulClient:regConnectCb(CallbackHandler(self, "_onSoulConnect"))
		soulClient:regDisconnectCb(function(connType)
			if self.gateClientSoul == soulClient then
				self:_onSoulDisconnect(connType)
			end
		end)
	elseif self.soulInfo ~= nil and self.soulInfo.gates ~= nil and #self.soulInfo.gates > 0 then
		local targetGate = self.soulInfo.gates[1]

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("[2]bindSoul connect gate %s:%d", targetGate.ip, targetGate.port)
		end

		local soulClient = GateClient(self, targetGate.ip, targetGate.port, self.deviceid, true, self.config, self.connBattleWithKcp)

		self.gateClientSoul = soulClient

		soulClient:regConnectCb(CallbackHandler(self, "_onSoulConnect"))
		soulClient:regDisconnectCb(function(connType)
			if self.gateClientSoul == soulClient then
				self:_onSoulDisconnect(connType)
			end
		end)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("bindSoul connect gate failed: no valid soul gate")
	end

	if self.gateClientSoul ~= nil then
		self.gateClientSoul.handler:setHeartbeatCb(CallbackHandler(self, "_onHeartbeat"))
	end
end

function NetHandler:isSoulConnected()
	return self.soulConnected
end

function NetHandler:regConnectCb(cb)
	self.connectCb = cb
end

function NetHandler:regDisconnectCb(cb)
	self.disconnectCb = cb
end

function NetHandler:regBindSoulSucceedCb(cb)
	self.bindSoulSucceedCb = cb
end

function NetHandler:regBindSoulFailedCb(cb)
	self.bindSoulFailedCb = cb
end

function NetHandler:startTTL()
	self:_stopTTL()

	if not Switch.EnableTTL then
		return
	end

	local now = Time.getTickSecond()

	self._lastHeartbeatRecvTime = now
	self._lastHeartbeatTimerTickTime = now
	self._heartbeatReconnectTriggered = false
	self._TTLTimer = TimerManager.addRepeatTimer(1, CallbackHandler(self, "_onSendHeartbeat"))
end

function NetHandler:_stopTTL()
	if self._TTLTimer ~= nil then
		TimerManager.removeTimer(self._TTLTimer)

		self._TTLTimer = nil
	end

	self._lastTTL = nil
	self._TTL = 0
	self._lastHeartbeatRecvTime = nil
	self._lastHeartbeatTimerTickTime = nil
	self._heartbeatReconnectTriggered = false
	self._heartbeatTimeoutPaused = false
end

function NetHandler:pauseHeartbeatTimeout()
	self._heartbeatTimeoutPaused = true
end

function NetHandler:resumeHeartbeatTimeout()
	if not self._heartbeatTimeoutPaused then
		return
	end

	local now = Time.getTickSecond()

	self._lastHeartbeatRecvTime = now
	self._lastHeartbeatTimerTickTime = now
	self._heartbeatReconnectTriggered = false
	self._heartbeatTimeoutPaused = false
end

function NetHandler:_onSendHeartbeat()
	local now = Time.getTickSecond()
	local lastTimerTickTime = self._lastHeartbeatTimerTickTime

	self._lastHeartbeatTimerTickTime = now

	local heartbeatSent = false

	if self.gateClientSoul ~= nil then
		self.gateClientSoul.handler:sendHeartbeat()

		heartbeatSent = true
	end

	if self._heartbeatTimeoutPaused then
		return
	end

	if heartbeatSent and self.soulConnected and self._lastHeartbeatRecvTime ~= nil and not self._heartbeatReconnectTriggered and lastTimerTickTime ~= nil and now - self._lastHeartbeatRecvTime > HEARTBEAT_RECONNECT_TIMEOUT and now - lastTimerTickTime > HEARTBEAT_RECONNECT_TIMEOUT then
		self._lastHeartbeatRecvTime = now
		self._heartbeatExpiredCount = 0

		return
	end

	if self.soulConnected and self._lastHeartbeatRecvTime ~= nil and not self._heartbeatReconnectTriggered and now - self._lastHeartbeatRecvTime > HEARTBEAT_RECONNECT_TIMEOUT then
		self._heartbeatReconnectTriggered = true

		self.logger:info("soul heartbeat timeout, reconnect")

		if self.gateClientSoul and self.gateClientSoul.session then
			self.gateClientSoul.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
		end

		return
	end

	self._heartbeatExpiredCount = self._heartbeatExpiredCount + 1

	if self._heartbeatExpiredCount >= RECONNECT_TIMEOUT_COUNT then
		self.logger:error("heartbeat expired, disconnect")
		self:stopAutoReconnect()
	end
end

function NetHandler:_onHeartbeat(delta)
	self._heartbeatExpiredCount = 0
	self._lastHeartbeatRecvTime = Time.getTickSecond()
	self._heartbeatReconnectTriggered = false

	if self._lastTTL == nil then
		self._TTL = delta
	else
		self._TTL = self._lastTTL * 0.2 + delta * 0.8
	end

	self._lastTTL = self._TTL
end

function NetHandler:getTTL()
	return self._TTL
end

function NetHandler:stopAutoReconnect()
	self._reconnectFailedCount = self._reconnectFailedCount + 1
	self._autoReconnect = false
	self._heartbeatExpiredCount = 0

	self:_stopTTL()

	if self._reconnectFailedCount > 1 then
		return
	else
		self.logger:error("stopAutoReconnect show disconnect")
		ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.HeartbeatExpired)
	end
end

function NetHandler:startAutoReconnect()
	self._autoReconnect = true
	self._heartbeatExpiredCount = 0

	self:_rebindSoulHandler()
end

return NetHandler
