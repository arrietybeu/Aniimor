-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\ChallengeDoor.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ChallengeDoor = Class.LightClass("ChallengeDoor", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")
local Time = require("Core.Common.Time")

function ChallengeDoor:ctor(sandbox, spawnInfo, syncInfo)
	ChallengeDoor.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.mainChallengeDoorId = 101
end

function ChallengeDoor:onSandboxReady()
	self.ChallengeDoorSB = self.shell.gameObject:GetComponent("ChallengeDoorSB")
end

function ChallengeDoor:onTrigger()
	self:serverMsg("RPC_CS_FinishChallengeDoor")
end

function ChallengeDoor:destroy()
	ChallengeDoor.super.destroy(self)
end

return ChallengeDoor
