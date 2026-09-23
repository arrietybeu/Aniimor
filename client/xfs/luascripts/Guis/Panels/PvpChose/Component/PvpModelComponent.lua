-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\Component\\PvpModelComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpModelComponent = Class.LightClass("PvpModelComponent", UIComponent)
local UISceneConst = require("GameApp.UIScene.UISceneConst")

function PvpModelComponent:initView()
	self.pvpScene = pg.game.uiScene:getScene(UISceneConst.PVP_BP_SCENE)

	pg.game.pvp:playPvpBGM("bgm_battle_pvp_prepare", "None")
end

function PvpModelComponent:showModel(isEnemy, pos, data)
	data.fake = true

	self.pvpScene:showModel(isEnemy, pos, data)
end

function PvpModelComponent:hideModel(isEnemy, pos)
	self.pvpScene:hideModel(isEnemy, pos)
end

function PvpModelComponent:startLoading(matchInfos)
	self.pvpScene:getReady()
	self.pvpScene:startLoading(matchInfos)
end

function PvpModelComponent:onDestroy()
	if self.pvpScene ~= nil then
		self.pvpScene:destroy()
	end

	self.pvpScene = nil

	pg.game.pvp:playPvpBGM()
end

return PvpModelComponent
