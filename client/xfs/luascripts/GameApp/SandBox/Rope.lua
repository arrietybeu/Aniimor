-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Rope.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Rope = Class.LightClass("Rope", LevelItem)

function Rope:ctor(sandbox, spawnInfo, syncInfo)
	Rope.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Rope:destroy()
	Rope.super.destroy(self)
end

return Rope
