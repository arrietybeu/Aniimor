-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Trigger.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local Trigger = Class.LightClass("Trigger", LevelItem)

function Trigger:ctor(sandbox, spawnInfo, syncInfo)
	Trigger.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Trigger:enterTrigger(actorId)
	self:serverMsg("RPC_CS_EnterTrigger", actorId or -1)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.TRIGGER_ENTER)
end

function Trigger:exitTrigger(actorId)
	self:serverMsg("RPC_CS_ExitTrigger", actorId or -1)
	self:sendSandboxEvent(SandboxConst.EVENT_TYPE.TRIGGER_LEAVE)
end

function Trigger:destroy()
	Trigger.super.destroy(self)
end

return Trigger
