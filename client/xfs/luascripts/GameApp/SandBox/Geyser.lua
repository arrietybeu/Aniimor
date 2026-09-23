-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Geyser.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local Geyser = Class.LightClass("Geyser", LevelItem)
local ClientConst = require("Const.ClientConst")
local SandboxConst = require("Common.Const.SandboxConst")
local Time = require("Core.Common.Time")

function Geyser:ctor(sandbox, spawnInfo, syncInfo)
	Geyser.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function Geyser:onSandboxReady()
	return
end

function Geyser:destroy()
	Geyser.super.destroy(self)
end

return Geyser
