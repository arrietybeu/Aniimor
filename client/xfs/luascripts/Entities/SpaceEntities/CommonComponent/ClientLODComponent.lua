-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientLODComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local Bitset = require("Common.Bitset")
local Utils = require("Common.Utils.Utils")
local ClientLODTickManager = require("Core.Common.ClientLODTickManager")
local SampleUtils = SampleUtils
local ClientLODComponent = class.Component("ClientLODComponent")
local pg = pg
local defaultDelayConfig = {
	{
		4900,
		2500,
		900,
		400,
		0
	},
	{
		1,
		0.6,
		0.4,
		0.2,
		0.1
	}
}

function ClientLODComponent:ctor()
	self.tickDeltaTime = 0
	self.lodCallbackId = 0
	self.sqrtDistance = 0
	self.lodTickLastTime = {}
	self.lodConfig = {}
	self.lodHandler = {}
	self.allowLodTick = true
	self.lodTimer = nil
	self._getTickDelta = self.getTickDelta
end

function ClientLODComponent:init(dict)
	self.enterTriggerMaps = {}
	self.lodTickDisableKeys = {}

	return true
end

function ClientLODComponent:getTickDelta(sqrtDistance, delayConfig)
	local sqrtDis = delayConfig[1]
	local delta = delayConfig[2]

	for k, v in ipairs(sqrtDis) do
		if v <= sqrtDistance then
			return delta[k]
		end
	end

	return 0.1
end

function ClientLODComponent:getDefaultTickDelta2(sqrtDistance)
	return 0.1
end

function ClientLODComponent:genLODCallbackId()
	self.lodCallbackId = self.lodCallbackId + 1

	if self.lodCallbackId > 4294967295 then
		self.lodCallbackId = 1
	end

	return self.lodCallbackId
end

function ClientLODComponent:addLODRepeatTimer(handler, delayConfig)
	if delayConfig == nil then
		delayConfig = defaultDelayConfig
	end

	local callbackId = self:genLODCallbackId()

	self.lodConfig[callbackId] = delayConfig
	self.lodTickLastTime[callbackId] = Time.getTickSecond()
	self.lodHandler[callbackId] = handler

	if self.lodTimer == nil then
		self.lodTimer = self.callbackGuard:addRepeatTimerCallback(0.1, function()
			self:lodTick()
		end)
	end

	return callbackId
end

function ClientLODComponent:toggleLodTick(enable)
	if self.allowLodTick ~= enable then
		if enable then
			self._getTickDelta = self.getTickDelta
		else
			self._getTickDelta = self.getDefaultTickDelta2
		end

		self.allowLodTick = enable

		ClientLODTickManager.setDisabled(self, not enable)
	end

	if self.eModel then
		self.eModel:ToggleLodTick(enable)
	end
end

function ClientLODComponent:setLodTickEnable(key, enable)
	local changed = false

	if enable then
		changed = Bitset.clrBit(self.lodTickDisableKeys, key)
	else
		changed = Bitset.setBit(self.lodTickDisableKeys, key)
	end

	if changed then
		local allowLodTick = self:innerQueryLodTickEnable()

		if self.allowLodTick ~= allowLodTick then
			self:toggleLodTick(allowLodTick)
		end
	end
end

function ClientLODComponent:innerQueryLodTickEnable()
	if Bitset.any(self.lodTickDisableKeys) then
		return false
	end

	return true
end

function ClientLODComponent:setRendererLod(lodLevel)
	if self.eModel and self.eModel.modelView then
		self.eModel.modelView:SetRendererLod(lodLevel)
	end
end

function ClientLODComponent:removeLODTimer(callbackId)
	if callbackId then
		self.lodConfig[callbackId] = nil
		self.lodTickLastTime[callbackId] = nil
		self.lodHandler[callbackId] = nil
	end

	if Utils.isEmptyTable(self.lodConfig) and self.lodTimer ~= nil then
		self:removeTimer(self.lodTimer)

		self.lodTimer = nil
	end
end

function ClientLODComponent:lodTick()
	local playerPos = pg.playerPos

	if pg.me == self or playerPos == nil or self.getPosition == nil then
		local lodHandler = self.lodHandler

		for callbackId in pairs(self.lodConfig) do
			local handler = lodHandler[callbackId]

			handler()
		end
	else
		local now = Time.getTickSecond()
		local myPos = self:getPosition()
		local lodHandler = self.lodHandler
		local dx = playerPos[1] - myPos[1]
		local dz = playerPos[3] - myPos[3]
		local sqrtDistance = dx * dx + dz * dz
		local lodTickLastTime = self.lodTickLastTime
		local sampleOn = SampleUtils.sampleOn()

		if sampleOn then
			for callbackId, delayConfig in pairs(self.lodConfig) do
				local timeDelta = now - lodTickLastTime[callbackId]

				if timeDelta > self:_getTickDelta(sqrtDistance, delayConfig) then
					lodTickLastTime[callbackId] = now

					local handler = lodHandler[callbackId]

					SampleUtils.beginSample(SampleUtils.showSampleDesc(handler))
					handler()
					SampleUtils.endSample()
				end
			end
		else
			for callbackId, delayConfig in pairs(self.lodConfig) do
				local timeDelta = now - lodTickLastTime[callbackId]

				if timeDelta > self:_getTickDelta(sqrtDistance, delayConfig) then
					lodTickLastTime[callbackId] = now

					local handler = lodHandler[callbackId]

					handler()
				end
			end
		end
	end
end

function ClientLODComponent:destroy()
	self.lodCallbackId = 0
	self.lodTickLastTime = nil
	self.lodConfig = nil
	self.lodHandler = nil

	if self.lodTimer ~= nil then
		self:removeTimer(self.lodTimer)

		self.lodTimer = nil
	end
end

return ClientLODComponent
