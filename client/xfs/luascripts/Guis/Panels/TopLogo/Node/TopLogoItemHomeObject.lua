-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemHomeObject.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoHomeFacilityComponent = require("Guis.Panels.TopLogo.Component.TopLogoHomeFacilityComponent")
local TopLogoItemHomeObject = Class.LightClass("TopLogoItemHomeObject", TopLogoItem)

function TopLogoItemHomeObject:ctor(entity)
	TopLogoItemHomeObject.super.ctor(self, entity)
end

function TopLogoItemHomeObject:destroy()
	TopLogoItemHomeObject.super.destroy(self)
end

function TopLogoItemHomeObject:findObjects()
	return
end

function TopLogoItemHomeObject:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.FACILITY] = TopLogoHomeFacilityComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemHomeObject
