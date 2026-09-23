-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\EventTrigger.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local EventTrigger = Class.LightClass("Sandbox.EventTrigger", LevelItem)

function EventTrigger:ctor(sandbox, spawnInfo, syncInfo)
	EventTrigger.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function EventTrigger:sendDoEvent()
	self:serverMsg("RPC_CS_DoEvent")
end

function EventTrigger:onLevelItemValueChange(key, oldValue, value)
	if key == "state" then
		if oldValue == value then
			return
		end

		local majorConfig = self:getMajorConfig()

		if majorConfig.forbidActive then
			return
		end

		self:setIsActive(value == 0)
	end
end

function EventTrigger:destroy()
	EventTrigger.super.destroy(self)
end

return EventTrigger
