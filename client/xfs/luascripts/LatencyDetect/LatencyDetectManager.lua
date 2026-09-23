-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\LatencyDetect\\LatencyDetectManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerManager = require("Core.Log.LoggerManager")
local GateClient = require("Core.Client.GateClient")
local StringEx = require("Core.Framework.String")
local IDManager = require("Core.Common.IDManager")
local ClientRepo = require("Core.Client.ClientRepo")
local ProtobufConst = require("Core.Common.ProtobufConst")
local LatencyDetectManager = Class.OldLightClass("LatencyDetectManager", nil, true)

function LatencyDetectManager:ctor()
	self.regionNo = nil
	self.latencyInfo = nil
	self.region2GateClient = {}
	self.deviceid = IDManager.genB64ID()
	self.logger = LoggerManager.getLogger("LatencyDetectManager")
end

function LatencyDetectManager:destroy()
	self.regionNo = nil
	self.latencyInfo = nil

	self:removeGetLatencyDetectTimer()
	self:removeClearGateClientTimer()
end

function LatencyDetectManager:getRegionNo()
	if self.regionNo == nil then
		return 0
	end

	return self.regionNo
end

function LatencyDetectManager:start()
	return
end

function LatencyDetectManager:removeGetLatencyDetectTimer()
	if self.getLatencyDetectTimer ~= nil then
		TimerManager.removeTimer(self.getLatencyDetectTimer)

		self.getLatencyDetectTimer = nil
	end
end

function LatencyDetectManager:removeClearGateClientTimer()
	if self.clearGateClientTimer ~= nil then
		TimerManager.removeTimer(self.clearGateClientTimer)

		self.clearGateClientTimer = nil
	end
end

function LatencyDetectManager:latencyDetect()
	if #self.latencyInfo <= 1 then
		self.regionNo = 0

		return
	end

	for _, info in ipairs(self.latencyInfo) do
		if #info.addrs > 0 then
			local randomIndex = math.random(#info.addrs)
			local targetAddr = info.addrs[randomIndex]
			local targetIp, targetPort = unpack(StringEx.split(targetAddr, ":"))
			local gateClient = GateClient(self, targetIp, targetPort, self.deviceid, false, ClientRepo.confJson, false)

			gateClient:regConnectCb(CallbackHandler(self, "_onLatencyConnect", info.regionNo))
			gateClient:regDisconnectCb(CallbackHandler(self, "_onLatencyDisconnect", info.regionNo))
			gateClient.handler:setHeartbeatCb(CallbackHandler(self, "_onLatencyHeartbeat", info.regionNo))

			self.region2GateClient[info.regionNo] = {
				client = gateClient
			}

			gateClient:connect(ProtobufConst.CONNECT_REQUEST_TYPE_LATENCY_DETECT, nil)
		end
	end

	if next(self.region2GateClient) ~= nil then
		self.clearGateClientTimer = TimerManager.addTimer(5, CallbackHandler(self, "closeAllGateClient"))
	end
end

function LatencyDetectManager:_onLatencyConnect(regionNo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onLatencyConnect================= for: %s", regionNo)
	end

	self.region2GateClient[regionNo].client.handler:sendHeartbeat()
end

function LatencyDetectManager:_onLatencyDisconnect(regionNo, connType)
	if self.regionNo == regionNo then
		-- block empty
	end
end

function LatencyDetectManager:_onLatencyHeartbeat(regionNo, delta)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_onLatencyHeartbeat================= for: %s, %s", regionNo, delta)
	end

	local lastDelta = self.region2GateClient[regionNo].delta

	if lastDelta == nil then
		self.region2GateClient[regionNo].delta = delta
	else
		self.region2GateClient[regionNo].delta = lastDelta * 0.2 + delta * 0.8
	end

	if self.regionNo == nil then
		self.regionNo = regionNo
	elseif self.region2GateClient[self.regionNo] ~= nil and self.region2GateClient[regionNo].delta < self.region2GateClient[self.regionNo].delta then
		self.regionNo = regionNo
	end
end

function LatencyDetectManager:closeAllGateClient()
	for _, info in pairs(self.region2GateClient) do
		info.client:close()

		info.client = nil
	end
end

return LatencyDetectManager
