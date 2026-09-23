-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\MechanismBallFeature.lua

local Class = require("Core.Framework.Class")
local iFeature = require("Entities.SpaceEntities.DynamicFeature.iFeature")
local SysConfigData = require("Data.sys_config_data")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local MechanismBallFeature = Class.LiteClass("MechanismBallFeature", iFeature)

function MechanismBallFeature:ctor()
	MechanismBallFeature.super.ctor(self)
end

function MechanismBallFeature:init(master, data)
	MechanismBallFeature.super.init(self, master, data)

	self.sandboxId = self.master.sandboxId
end

function MechanismBallFeature:destroy()
	MechanismBallFeature.super.destroy(self)
end

function MechanismBallFeature:onMasterModelLoaded()
	if self.master.eModel then
		if self.isTriggered then
			self.master.eModel:SendEventToFlowScript("StartShining")
		else
			self.master.eModel:SendEventToFlowScript("StopShining")
		end
	end
end

function MechanismBallFeature:on_isTriggered_Changed(oldv, newv)
	if self.master.eModel then
		if self.isTriggered then
			self.master.eModel:SendEventToFlowScript("StartShining")
		else
			self.master.eModel:SendEventToFlowScript("StopShining")
		end
	end
end

return MechanismBallFeature
