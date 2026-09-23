-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMarket\\Component\\HomelandSpecialOrderComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandSpecialOrderComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local HomelandSpecialOrderComponent = Class.LightClass("HomelandSpecialOrderComponent", UIComponent)

function HomelandSpecialOrderComponent:findObjects()
	return
end

function HomelandSpecialOrderComponent:initView()
	return
end

function HomelandSpecialOrderComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function HomelandSpecialOrderComponent:onEnterPage()
	return
end

function HomelandSpecialOrderComponent:refreshSelectElement()
	return
end

return HomelandSpecialOrderComponent
