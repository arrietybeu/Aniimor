-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPetBall.lua

local Class = require("Core.Framework.Class")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local UIConst = require("Const.UIConst")
local TopLogoBubblePetBallComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubblePetBallComponent")
local TopLogoItemPetBall = Class.LightClass("TopLogoItemPetBall", TopLogoItem)

function TopLogoItemPetBall:ctor(entity)
	TopLogoItemPetBall.super.ctor(self, entity)
end

function TopLogoItemPetBall:onTopLogoLoaded()
	TopLogoItemPetBall.super.onTopLogoLoaded(self)

	self.topLogoScript.overrideWorldCamera = pg.game.petBall.previewSceneCameraGameObject:GetComponent("Camera")
end

function TopLogoItemPetBall:findObjects()
	return
end

function TopLogoItemPetBall:createLogicComponents()
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.BUBBLE] = TopLogoBubblePetBallComponent.new(nil, self)
	}

	self:m_classifyComponents()
end

return TopLogoItemPetBall
