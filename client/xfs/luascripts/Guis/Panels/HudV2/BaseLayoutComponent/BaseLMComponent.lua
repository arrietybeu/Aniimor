-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseLMComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseLMComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BaseLMComponent = Class.LightClass("BaseLMComponent", HudBaseComponent)

function BaseLMComponent:findObjects()
	return
end

function BaseLMComponent:initView()
	return
end

function BaseLMComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BaseLMComponent
