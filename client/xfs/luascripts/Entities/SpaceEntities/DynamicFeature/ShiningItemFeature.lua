-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\ShiningItemFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local ShiningItemFeature = Class.LiteClass("ShiningItemFeature", iFeature)

function ShiningItemFeature:ctor()
	ShiningItemFeature.super.ctor(self)
end

function ShiningItemFeature:init(master, data)
	ShiningItemFeature.super.init(self, master, data)

	self.sandboxId = self.master.sandboxId

	local configData = self.master:getConfigData()

	self.featureConfigData = configData.featureConfigData or {}
	self.shiningRadius = self.featureConfigData.shiningRadius or 10
	self.shiningValue = self.featureConfigData.shiningValue or 15
	self.shiningImpulseThreshold = self.featureConfigData.shiningImpulseThreshold or 100

	self:refreshShining()
end

function ShiningItemFeature:destroy()
	pg.me:setFogShiningValue(self.master.id, 0)

	if self.updatePlayerShinyTimer then
		self.master:removeTimer(self.updatePlayerShinyTimer)

		self.updatePlayerShinyTimer = nil
	end

	ShiningItemFeature.super.destroy(self)
end

function ShiningItemFeature:onMasterModelLoaded()
	if self.master.eModel then
		if self.isShining then
			self.master.eModel:SendEventToFlowScript("StartShining")
		else
			self.master.eModel:SendEventToFlowScript("StopShining")
		end
	end
end

function ShiningItemFeature:onReceiveImpulse(impulse, reachThreshold)
	local impulseSqrtMag = Vector3.SqrMagnitude(impulse)

	if impulseSqrtMag > self.shiningImpulseThreshold * self.shiningImpulseThreshold then
		self:serverMsg("RPC_CS_onReceiveShiningImpulse")
	end

	if reachThreshold then
		self:serverMsg("RPC_CS_onReceiveThresholdImpulse")
	end
end

function ShiningItemFeature:refreshShining()
	if self.updatePlayerShinyTimer then
		self.master:removeTimer(self.updatePlayerShinyTimer)

		self.updatePlayerShinyTimer = nil
	end

	if self.isShining then
		self.updatePlayerShinyTimer = self.master:addRepeatTimer(0.1, function()
			local playerDistance = self.master:getPlayerDistance()
			local playerYDistance = self.master:getPlayerYDistance()

			if playerDistance <= self.shiningRadius and playerYDistance <= self.shiningRadius then
				pg.me:setFogShiningValue(self.master.id, self.shiningValue)
			else
				pg.me:setFogShiningValue(self.master.id, 0)
			end
		end)
	else
		pg.me:setFogShiningValue(self.master.id, 0)
	end
end

function ShiningItemFeature:on_isShining_Changed(oldv, newv)
	self:refreshShining()

	if self.master.eModel then
		if self.isShining then
			self.master.eModel:SendEventToFlowScript("StartShining")
		else
			self.master.eModel:SendEventToFlowScript("StopShining")
		end
	end
end

return ShiningItemFeature
