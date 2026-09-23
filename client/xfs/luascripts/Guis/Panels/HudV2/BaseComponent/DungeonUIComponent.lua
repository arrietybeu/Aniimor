-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\DungeonUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("DungeonUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local DungeonUIComponent = Class.LightClass("DungeonUIComponent", HudBaseComponent)

function DungeonUIComponent:findObjects()
	return
end

function DungeonUIComponent:initView()
	return
end

function DungeonUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return DungeonUIComponent
