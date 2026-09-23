-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\GridCell.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local GridCell = Class.LightClass("GridCell", LevelItem)

function GridCell:ctor(sandbox, spawnInfo, syncInfo)
	GridCell.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function GridCell:onInit()
	GridCell.super.onInit(self)
end

function GridCell:onSandboxReady()
	GridCell.super.onSandboxReady(self)
end

function GridCell:destroy()
	GridCell.super.destroy(self)
end

return GridCell
