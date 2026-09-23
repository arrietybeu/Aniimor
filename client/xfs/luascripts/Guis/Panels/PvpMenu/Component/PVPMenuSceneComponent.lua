-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\Component\\PVPMenuSceneComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PVPMenuSceneComponent = Class.LightClass("PVPMenuSceneComponent", UIComponent)
local UISceneConst = require("GameApp.UIScene.UISceneConst")

function PVPMenuSceneComponent:initView()
	self.pvpMenuScene = pg.game.uiScene:getScene(UISceneConst.PVP_TEAM_SCENE)

	self.pvpMenuScene:onInitCamera()
end

function PVPMenuSceneComponent:onHide()
	self.pvpMenuScene:disFocus()
end

function PVPMenuSceneComponent:switchPage(page)
	self.pvpMenuScene:focus(page)
end

function PVPMenuSceneComponent:switchMatchState(state)
	self.pvpMenuScene:switchState(state)
end

function PVPMenuSceneComponent:viewTickTimer(timeStr)
	self.pvpMenuScene:tickRemandTime(timeStr)
end

function PVPMenuSceneComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PVPMenuSceneComponent
