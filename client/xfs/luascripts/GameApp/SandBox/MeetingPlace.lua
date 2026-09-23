-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\MeetingPlace.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local MeetingPlace = Class.LightClass("MeetingPlace", LevelItem)

function MeetingPlace:ctor(sandbox, spawnInfo, syncInfo)
	MeetingPlace.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function MeetingPlace:destroy()
	MeetingPlace.super.destroy(self)
end

return MeetingPlace
