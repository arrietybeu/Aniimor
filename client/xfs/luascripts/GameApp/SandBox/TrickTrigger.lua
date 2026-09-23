-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TrickTrigger.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local TrickTrigger = Class.LightClass("Sandbox.TrickTrigger", LevelItem)

function TrickTrigger:ctor(sandbox, spawnInfo, syncInfo)
	TrickTrigger.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function TrickTrigger:sendDoEvent()
	self:serverMsg("RPC_CS_DoEvent")
end

function TrickTrigger:onLevelItemValueChange(key, oldValue, value)
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

function TrickTrigger:destroy()
	TrickTrigger.super.destroy(self)
end

return TrickTrigger
