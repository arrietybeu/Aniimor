-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\BossRushBtnInfoUIComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushBtnInfoUIComponent = Class.LightClass("BossRushBtnInfoUIComponent", HudBaseComponent)

BossRushBtnInfoUIComponent.messages = {
	[MessageName.SCENE_LOADED] = {
		"refreshBossRushInfo",
		true
	}
}

function BossRushBtnInfoUIComponent:findObjects()
	self.bossRushInfoUButton = self.transform:GetComponent("UButton")

	local objectReference = self.bossRushInfoUButton:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_INFO"))
end

function BossRushBtnInfoUIComponent:initView()
	function self.bossRushInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_ROUTE)
	end

	self:refreshBossRushInfo()
end

function BossRushBtnInfoUIComponent:refreshBossRushInfo()
	local isBossRushEnv = pg.space and pg.space:isBossRushEnv() or false

	self.uWidget:SetActive(isBossRushEnv)
end

function BossRushBtnInfoUIComponent:onDestroy()
	self.bossRushInfoUButton.luaClick = nil

	HudBaseComponent.onDestroy(self)
end

return BossRushBtnInfoUIComponent
