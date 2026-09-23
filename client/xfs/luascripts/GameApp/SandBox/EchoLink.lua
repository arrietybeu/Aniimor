-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\EchoLink.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local EchoLink = Class.LightClass("EchoLink", LevelItem)

function EchoLink:ctor(sandbox, spawnInfo, syncInfo)
	EchoLink.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function EchoLink:destroy()
	EchoLink.super.destroy(self)
end

return EchoLink
