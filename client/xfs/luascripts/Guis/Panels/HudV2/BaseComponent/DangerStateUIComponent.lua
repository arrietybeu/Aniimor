-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\DangerStateUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("DangerStateUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local DangerStateUIComponent = Class.LightClass("DangerStateUIComponent", HudBaseComponent)

function DangerStateUIComponent:findObjects()
	return
end

function DangerStateUIComponent:initView()
	return
end

function DangerStateUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return DangerStateUIComponent
