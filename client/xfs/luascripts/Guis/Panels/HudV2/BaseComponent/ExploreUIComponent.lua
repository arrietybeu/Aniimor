-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\ExploreUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ExploreUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local ExploreUIComponent = Class.LightClass("ExploreUIComponent", HudBaseComponent)

function ExploreUIComponent:findObjects()
	return
end

function ExploreUIComponent:initView()
	return
end

function ExploreUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return ExploreUIComponent
