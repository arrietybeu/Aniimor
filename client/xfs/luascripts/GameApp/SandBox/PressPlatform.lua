-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PressPlatform.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local PressPlatform = Class.LightClass("PressPlatform", LevelItem)

function PressPlatform:ctor(sandbox, spawnInfo, syncInfo)
	PressPlatform.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function PressPlatform:destroy()
	PressPlatform.super.destroy(self)
end

return PressPlatform
