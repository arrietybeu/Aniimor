-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SubComponents\\DynamicVoxelSB.lua

local Class = require("Core.Framework.Class")
local SubComponent = require("GameApp.Sandbox.SubComponents.SubComponent")
local DynamicVoxelSB = Class.LightClass("DynamicVoxelSB", SubComponent)

function DynamicVoxelSB:ctor(id, levelItem, info)
	DynamicVoxelSB.super.ctor(self, id, levelItem, info)
end

return DynamicVoxelSB
