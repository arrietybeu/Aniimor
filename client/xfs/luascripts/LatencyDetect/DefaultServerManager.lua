-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\LatencyDetect\\DefaultServerManager.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerManager = require("Core.Log.LoggerManager")
local GateClient = require("Core.Client.GateClient")
local StringEx = require("Core.Framework.String")
local IDManager = require("Core.Common.IDManager")
local ClientRepo = require("Core.Client.ClientRepo")
local ProtobufConst = require("Core.Common.ProtobufConst")
local ClientUtils = require("Utils.ClientUtils")
local DefaultServerManager = Class.OldLightClass("DefaultServerManager", nil, true)

function DefaultServerManager:ctor()
	self.defaultClusterName = nil
	self.defaultClusterId = nil
	self.latencyInfo = nil
	self.clusterName2GateClient = {}
	self.deviceid = IDManager.genB64ID()
	self.logger = LoggerManager.getLogger("DefaultServerManager")
end

function DefaultServerManager:destroy()
	self.latencyInfo = nil

	self:removeLatencyDetectTimer()
	self:removeClearGateClientTimer()
end

function DefaultServerManager:getServerInfo()
	return self.defaultClusterName, self.defaultClusterId
end

function DefaultServerManager:start()
	self.latencyDetectTimer = TimerManager.addRepeatTimer(10, CallbackHandler(self, "latencyDetect"))

	self:latencyDetect()
end

function DefaultServerManager:removeGetLatencyDetectTimer()
	if self.latencyDetectTimer ~= nil then
		TimerManager.removeTimer(self.latencyDetectTimer)

		self.latencyDetectTimer = nil
	end
end

function DefaultServerManager:removeClearGateClientTimer()
	if self.clearGateClientTimer ~= nil then
		TimerManager.removeTimer(self.clearGateClientTimer)

		self.clearGateClientTimer = nil
	end
end

function DefaultServerManager:latencyDetect()
	if self.defaultClusterName ~= nil then
		return
	end

	local dirConf, _ = ClientUtils.getDirConf()

	if dirConf == nil or not dirConf.enableDefaultServerDetect then
		return
	end

	for _, info in ipairs(dirConf.localDirData) do
		if info.msGateAddrList ~= nil and #info.msGateAddrList > 0 then
			local randomIndex = math.random(#info.msGateAddrList)
			local targetAddr = info.msGateAddrList[randomIndex]
			local targetIp, targetPort = unpack(StringEx.split(targetAddr, ":"))
			local gateClient = GateClient(self, targetIp, targetPort, self.deviceid, false, ClientRepo.confJson, false)

			gateClient:regConnectCb(CallbackHandler(self, "_onLatencyConnect", info.ClusterName))
			gateClient:regDisconnectCb(CallbackHandler(self, "_onLatencyDisconnect", info.ClusterName))
			gateClient.handler:setHeartbeatCb(CallbackHandler(self, "_onLatencyHeartbeat", info.ClusterName))

			self.clusterName2GateClient[info.ClusterName] = {
				clusterId = info.ClusterId,
				client = gateClient
			}

			gateClient:connect(ProtobufConst.CONNECT_REQUEST_TYPE_LATENCY_DETECT, nil)
		end
	end

	if next(self.clusterName2GateClient) ~= nil then
		self.clearGateClientTimer = TimerManager.addTimer(3, CallbackHandler(self, "closeAllGateClient"))
	end
end

function DefaultServerManager:_onLatencyConnect(clusterName)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onLatencyConnect================= for: %s", clusterName)
	end

	self.clusterName2GateClient[clusterName].client.handler:sendHeartbeat()
end

function DefaultServerManager:_onLatencyDisconnect(clusterName, connType)
	return
end

function DefaultServerManager:_onLatencyHeartbeat(clusterName, delta)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onLatencyHeartbeat================= for: %s, %s", clusterName, delta)
	end

	local lastDelta = self.clusterName2GateClient[clusterName].delta

	if lastDelta == nil then
		self.clusterName2GateClient[clusterName].delta = delta
	else
		self.clusterName2GateClient[clusterName].delta = lastDelta * 0.2 + delta * 0.8
	end

	if self.defaultClusterName == nil then
		self.defaultClusterName = clusterName
		self.defaultClusterId = self.clusterName2GateClient[clusterName].clusterId
	end
end

function DefaultServerManager:closeAllGateClient()
	for _, info in pairs(self.clusterName2GateClient) do
		if info.client ~= nil then
			info.client:close()

			info.client = nil
		end
	end

	if self.defaultClusterId and self.defaultClusterName then
		pg.global.ui.login.loginServerComponent:updateRecommendServer(self.defaultClusterId, self.defaultClusterName)
	end
end

return DefaultServerManager
