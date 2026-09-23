-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\GrabEggExitPoint.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local GrabEggExitPoint = Class.LightClass("GrabEggExitPoint", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")

function GrabEggExitPoint:ctor(sandbox, spawnInfo, syncInfo)
	GrabEggExitPoint.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function GrabEggExitPoint:destroy()
	GrabEggExitPoint.super.destroy(self)
end

return GrabEggExitPoint
