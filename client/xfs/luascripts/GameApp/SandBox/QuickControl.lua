-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\QuickControl.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local QuickControl = Class.LightClass("QuickControl", LevelItem)

function QuickControl:ctor(sandbox, spawnInfo, syncInfo)
	QuickControl.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function QuickControl:sendDoQuickControl()
	self:serverMsg("RPC_CS_DoQuickControl")
end

function QuickControl:RPC_SC_DoQuickControl(eventParam)
	pg.me:doEventByData({
		"quickEnterControlMode",
		eventParam
	})
end

return QuickControl
