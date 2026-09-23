-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemWishingStar.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoHomeWishingStarComponent = require("Guis.Panels.TopLogo.Component.TopLogoHomeWishingStarComponent")
local TopLogoItemWishingStar = Class.LightClass("TopLogoItemWishingStar", TopLogoItem)

function TopLogoItemWishingStar:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.FACILITY] = TopLogoHomeWishingStarComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemWishingStar
