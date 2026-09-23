-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TwinklePlatformController.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local TwinklePlatformController = Class.LightClass("TwinklePlatformController", LevelItem)
local Time = require("Core.Common.Time")

function TwinklePlatformController:ctor(sandbox, spawnInfo, syncInfo)
	TwinklePlatformController.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function TwinklePlatformController:syncTwinkleInfo(curIndex)
	if not self.sandbox.isMain then
		return
	end

	self:syncFieldValue({
		curIndex = curIndex,
		lastChangeTime = Time.secondCache
	})
end

return TwinklePlatformController
