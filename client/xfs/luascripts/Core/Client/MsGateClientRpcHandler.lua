-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\MsGateClientRpcHandler.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ProtoCodec = require("Core.Common.ProtoCodec")
local ProtobufConst = require("Core.Common.ProtobufConst")
local logger = LoggerManager.getLogger("MsGateClientRpcHandler")
local RpcHandler = require("Core.Net.RpcHandler")
local GlobalData = require("Core.Client.GlobalData")
local ClientRepo = require("Core.Client.ClientRepo")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local CommonSwitch = require("Common.CommonSwitch")
local MsGateClientRpcHandler = class.Class("MsGateClientRpcHandler", RpcHandler)

function MsGateClientRpcHandler:ctor(client)
	MsGateClientRpcHandler.super.ctor(self)

	self.codec = ProtoCodec()
	self.client = client
	self.isServiceLogin = false
end

function MsGateClientRpcHandler:onSessionDisconnected()
	MsGateClientRpcHandler.super.onSessionDisconnected(self)

	if self.client and self.client.session then
		self.client.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
	end

	if not self.client.msProxy:isExtraConnect() then
		GlobalData.GlobalGateId = nil
		GlobalData.GlobalGateSessionId = nil
	end
end

function MsGateClientRpcHandler:handshake(pubKeyData)
	assert(self.client ~= nil)
	self:requestEncryptToken(pubKeyData)
end

function MsGateClientRpcHandler:requestEncryptToken(pubKeyData)
	self:dispatchRpc("sendRequestEncryptToken", pubKeyData)
end

function MsGateClientRpcHandler:confirmEncryptKeyAck()
	if self.client then
		self.client:callConnectCb()
	end
end

function MsGateClientRpcHandler:onMicroResponse(rid, parameters, contextData, serviceId)
	local response = parameters
	local ret = response.Ret

	assert(ret ~= nil)

	if ret == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("onMicroResponse error, response invalid")
		end

		return
	end

	local retStatus = {
		status = ret[1],
		errmsg = ret[2],
		serviceId = serviceId
	}

	response.context = contextData
	response.Ret = nil

	self.client.msProxy:onResponse(rid, retStatus, response)
end

function MsGateClientRpcHandler:onMicroPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
	self.client.msProxy:onPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
end

function MsGateClientRpcHandler:sendHeartbeat()
	self:dispatchRpc("sendHeartbeat", Time.getNanosecond())
end

function MsGateClientRpcHandler:recvHeartbeat(time)
	local delta = Time.getNanosecond() - time

	if self.heartbeatCb ~= nil then
		self.heartbeatCb(delta)
	end
end

function MsGateClientRpcHandler:setHeartbeatCb(cb)
	self.heartbeatCb = cb
end

function MsGateClientRpcHandler:regGlobalGate2Client(gateId, sessionId)
	if gateId == "FORBID" and sessionId == "FORBID" then
		local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

		if loginCtrl and loginCtrl.resetLoginState then
			loginCtrl:resetLoginState()
		end

		local ClientUtils = require("Utils.ClientUtils")

		ClientUtils.destroyAll()
		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("DISCONNECT_SERVER_CLOSED_TIPS"), function()
			ClientUtils.backToHome()
		end, true)

		return
	end

	self.client.msProxy:finishedGetGateInfo()

	if not self.client.msProxy:isExtraConnect() then
		local oldSessionId = GlobalData.GlobalGateSessionId

		GlobalData.GlobalGateId = gateId
		GlobalData.GlobalGateSessionId = sessionId

		if oldSessionId ~= GlobalData.GlobalGateSessionId and self.isServiceLogin and GlobalData.UserName ~= nil and GlobalData.UserName ~= "" then
			local connInfo = {
				sessionId = GlobalData.GlobalGateSessionId,
				gateId = GlobalData.GlobalGateId
			}

			TimerManager.addTimer(5, function()
				self:callService("RoleService", "CS_ClientConnInfoChanged", {
					GlobalData.UserName,
					ClientRepo.netHandler.connectToken,
					connInfo
				}, nil, {
					hint = GlobalData.UserName
				})
			end)

			if GlobalData.Player then
				GlobalData.Player:updateMsGateInfo(false)
			end
		end

		GlobalData.LastBindMsUid = nil

		if GlobalData.Player then
			GlobalData.Player:bindGlobalMsGate()
		end
	end
end

function MsGateClientRpcHandler:globalGate2ClientMessage(sessionId, methodName, parameters)
	local parames = self.codec:decode(parameters)

	if GlobalData.GlobalGateSessionId ~= sessionId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("globalGate2ClientMessage sessionId not match for: ", methodName)
		end

		return
	end

	if methodName == "bindSoul" then
		self.isServiceLogin = true

		local gates, auth, soulMbBin, reason = parames[3], parames[1], parames[2], parames[4]
		local gatesList = ClientRepo.protoCodec:decode(gates)
		local soulInfo = {
			gates = gatesList,
			auth = auth,
			soulMbBin = soulMbBin
		}

		ClientRepo.netHandler:bindSoulFromMs(soulInfo, reason)
	elseif methodName == "unbindSoul" then
		ClientRepo.netHandler:_unbindSoul()
	elseif methodName == "notifyErrMsg" then
		local ClientUtils = require("Utils.ClientUtils")
		local msg = parames[1]

		if #parames > 1 then
			ClientUtils.showErrorMsg(string.format(pg.getGameString(msg), unpack(parames[2])))
		else
			ClientUtils.showErrorMsg(pg.getGameString(msg))
		end
	elseif methodName == "notifyQueueInfo" then
		ClientRepo.loginAgent:notifyQueueInfo(parames[1])
	elseif methodName == "notifyKicked" then
		local ClientUtils = require("Utils.ClientUtils")

		ClientRepo.notShowDisconnectStartTime = Time.realSecondCache

		ClientUtils.showKicked()
	elseif methodName == "notifyServerClose" then
		local ClientUtils = require("Utils.ClientUtils")

		ClientUtils.showErrorMsg(pg.getGameString(parames[1]))

		ClientRepo.notShowDisconnectStartTime = Time.realSecondCache
	elseif methodName == "bindSoulClientNotMatch" then
		self.isServiceLogin = true

		local gates, auth, soulMbBin = parames[3], parames[1], parames[2]
		local gatesList = ClientRepo.protoCodec:decode(gates)
		local soulInfo = {
			gates = gatesList,
			auth = auth,
			soulMbBin = soulMbBin
		}

		if EnableBotTest then
			ClientRepo.netHandler:_bindSoul(soulInfo)

			return
		end

		if GlobalData.BlockBindSoulClientNotMatch == true then
			print("BlockBindSoulClientNotMatch: skip tip")
			ClientRepo.netHandler:_bindSoul(soulInfo)

			return
		end

		local ClientUtils = require("Utils.ClientUtils")

		pg.global.ui.commonConfirm:close()
		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("LoginErr_CLIENT_SERVER_MISMATCH"), function()
			ClientUtils.backToHome()
		end, false, function()
			ClientRepo.netHandler:_bindSoul(soulInfo)
		end, nil, nil, {
			okBtnDesc = pg.getGameString("LOAD_BUTTON_TXT_1"),
			cancelBtnDesc = pg.getGameString("LOAD_BUTTON_TXT")
		})
	elseif GlobalData.Player ~= nil and GlobalData.Player[methodName] then
		GlobalData.Player[methodName](GlobalData.Player, unpack(parames))
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("globalGate2ClientMessage not method: ", methodName)
	end
end

function MsGateClientRpcHandler:destroy()
	MsGateClientRpcHandler.super.destroy(self)
end

return MsGateClientRpcHandler
