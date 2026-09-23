-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\BilateralTotem.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SceneUtils = require("Common.Utils.SceneUtils")
local inspect = require("Core.Common.inspect")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local BilateralTotem = Class.LightClass("BilateralTotem", LevelItem)

function BilateralTotem:ctor(sandbox, spawnInfo, syncInfo)
	BilateralTotem.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function BilateralTotem:onSandboxReady()
	BilateralTotem.super.onSandboxReady(self)

	self.BilateralTotemSB = self.shell.gameObject:GetComponent("BilateralTotemSB")
end

function BilateralTotem:onTotemInView()
	self:serverMsg("RPC_CS_OnTotemInView")
end

function BilateralTotem:onInSuccess()
	self:serverMsg("RPC_CS_OnInSuccess")
end

function BilateralTotem:onExitGhostEye()
	self:serverMsg("RPC_CS_OnExitGhostEye")
end

function BilateralTotem:onCancelInSuccess()
	self:serverMsg("RPC_CS_OnCancelInSuccess")
end

function BilateralTotem:onSuccess()
	AutoPathFindUtils.stopAutoPathFind(pg.me)
	self:serverMsg("RPC_CS_OnSuccess")
end

function BilateralTotem:onFadeOut()
	self:serverMsg("RPC_CS_OnFadeOut")
end

function BilateralTotem:destroy()
	BilateralTotem.super.destroy(self)
end

return BilateralTotem
