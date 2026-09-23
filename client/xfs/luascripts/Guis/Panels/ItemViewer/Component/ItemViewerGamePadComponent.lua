-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemViewer\\Component\\ItemViewerGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ItemViewerGamePadComponent = Class.LightClass("ItemViewerGamePadComponent", UIComponent)

function ItemViewerGamePadComponent:findObjects()
	return
end

function ItemViewerGamePadComponent:initView()
	return
end

function ItemViewerGamePadComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ItemViewerGamePadComponent
