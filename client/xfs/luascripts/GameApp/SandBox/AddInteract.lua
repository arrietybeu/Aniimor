-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\AddInteract.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local AddInteract = Class.LightClass("AddInteract", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")

function AddInteract:ctor(sandbox, spawnInfo, syncInfo)
	AddInteract.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function AddInteract:onSandboxReady()
	AddInteract.super.onSandboxReady(self)

	self.AddInteractSB = self.shell.gameObject:GetComponent("AddInteractSB")
end

function AddInteract:onTrigger(interactId)
	self:serverMsg("RPC_CS_OnTrigger", interactId)
	facade:sendLuaEvent(interactId .. SandboxConst.COMMON_EVENT.ITEM_INTERACT_TRIGGER, {
		state = self.syncInfo.state
	})
end

function AddInteract:destroy()
	AddInteract.super.destroy(self)
end

return AddInteract
