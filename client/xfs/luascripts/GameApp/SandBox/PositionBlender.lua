-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PositionBlender.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local PositionBlender = Class.LightClass("PositionBlender", LevelItem)

function PositionBlender:ctor(sandbox, spawnInfo, syncInfo)
	PositionBlender.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PositionBlender:onSandboxReady()
	PositionBlender.super.onSandboxReady(self)

	self.positionBlendSB = self.shell.gameObject.transform:GetComponent("PositionBlendSB")

	if self.positionBlendSB then
		self.positionBlendSB:SetBlendInfo(self.syncInfo.lastStateChangeTime, self.syncInfo.startBlendVal, self.syncInfo.state == 1)
	end
end

function PositionBlender:onValueChange(key, oldValue, value, isInit)
	PositionBlender.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "state" and self.positionBlendSB then
		self.positionBlendSB:SetBlendInfo(self.syncInfo.lastStateChangeTime, self.syncInfo.startBlendVal, self.syncInfo.state == 1)
	end
end

function PositionBlender:destroy()
	PositionBlender.super.destroy(self)
end

return PositionBlender
