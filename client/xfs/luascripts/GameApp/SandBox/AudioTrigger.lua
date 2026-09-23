-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\AudioTrigger.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local AudioTrigger = Class.LightClass("AudioTrigger", LevelItem)

function AudioTrigger:ctor(sandbox, spawnInfo, syncInfo)
	AudioTrigger.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function AudioTrigger:onInit()
	local defaultValue = self.spawnInfo.defaultValue or {}

	self.arkRewardId = defaultValue.arkRewardId
end

function AudioTrigger:onTriggerSuccess()
	if self.arkRewardId and self.arkRewardId ~= 0 then
		self:serverMsg("RPC_CS_OnPuzzleFinished")
	end
end

return AudioTrigger
