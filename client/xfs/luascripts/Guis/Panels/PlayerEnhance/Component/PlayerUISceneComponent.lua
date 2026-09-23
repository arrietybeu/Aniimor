-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\Component\\PlayerUISceneComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PlayerUISceneComponent = Class.LightClass("PlayerUISceneComponent", UIComponent)
local UISceneConst = require("GameApp.UIScene.UISceneConst")

function PlayerUISceneComponent:initView()
	self.modelScene = pg.game.uiScene:getScene(UISceneConst.PLAYER_ENHANCE_SCENE)

	self.modelScene:initDefaultSceneMode(self.ctrl.firstEnter)

	if self.ctrl.defaultPlayerActive ~= nil then
		self:setPlayerActive(self.ctrl.defaultPlayerActive)
	end

	self.ctrl.defaultPlayerActive = nil
end

function PlayerUISceneComponent:playEnterAnimation(afterEnterCallback)
	self.modelScene:playEnterTimeline(afterEnterCallback)
end

function PlayerUISceneComponent:switchToMain()
	self.modelScene:switch2_MAIN_Mode()
end

function PlayerUISceneComponent:switchToCombats()
	self.modelScene:switch2_EQUIP_COMBATS_Mode()
end

function PlayerUISceneComponent:switchToExplore()
	self.modelScene:switch2_EQUIP_EXPLORE_Mode()
end

function PlayerUISceneComponent:setPlayerActive(active)
	self.modelScene:setPlayerActive(active)
end

function PlayerUISceneComponent:refreshModelView()
	self.modelScene:refreshModelView()
end

function PlayerUISceneComponent:onDestroy()
	pg.game.uiScene:switchOutScene(UISceneConst.PLAYER_ENHANCE_SCENE)
	UIComponent.onDestroy(self)
end

return PlayerUISceneComponent
