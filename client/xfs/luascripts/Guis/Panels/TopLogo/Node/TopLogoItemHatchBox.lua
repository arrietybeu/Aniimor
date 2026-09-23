-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemHatchBox.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoHomeHatchBoxComp = require("Guis.Panels.TopLogo.Component.TopLogoHomeHatchBoxComp")
local TopLogoItemHatchBox = Class.LightClass("TopLogoItemHatchBox", TopLogoItem)

function TopLogoItemHatchBox:ctor(entity)
	TopLogoItemHatchBox.super.ctor(self, entity)
end

function TopLogoItemHatchBox:destroy()
	TopLogoItemHatchBox.super.destroy(self)
end

function TopLogoItemHatchBox:findObjects()
	return
end

function TopLogoItemHatchBox:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.FACILITY] = TopLogoHomeHatchBoxComp.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemHatchBox
