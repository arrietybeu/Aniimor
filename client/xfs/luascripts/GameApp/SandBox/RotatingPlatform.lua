-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\RotatingPlatform.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local RotatingPlatform = Class.LightClass("RotatingPlatform", LevelItem)

function RotatingPlatform:ctor(sandbox, spawnInfo, syncInfo)
	RotatingPlatform.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

return RotatingPlatform
