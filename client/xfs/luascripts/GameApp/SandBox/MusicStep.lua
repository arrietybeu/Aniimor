-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\MusicStep.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local MusicStep = Class.LightClass("MusicStep", LevelItem)
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SandboxConst = require("Common.Const.SandboxConst")

function MusicStep:ctor(sandbox, spawnInfo, syncInfo)
	MusicStep.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.sysName = "MusicStep"
end

function MusicStep:onSandboxReady()
	MusicStep.super.onSandboxReady(self)

	self.MusicStepSB = self.shell.gameObject:GetComponent("MusicStepSB")
end

function MusicStep:onFinish(isOn)
	self:syncFieldValue({
		state = 1
	})
end

function MusicStep:destroy()
	MusicStep.super.destroy(self)
end

return MusicStep
