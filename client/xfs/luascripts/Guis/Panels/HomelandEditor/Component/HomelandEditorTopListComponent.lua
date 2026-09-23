-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditor\\Component\\HomelandEditorTopListComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandEditorTopListComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local HomeTypeData = require("Data.home_type_data")
local HomeSubTypeData = require("Data.home_sub_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RevertHomeObjectData = require("Data.revert_home_object_data")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotKeyConst = require("Const.HotkeyConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local HomeFreePlacementData = require("Data.free_placement_data")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local GlobalData = require("Core.Client.GlobalData")
local HomelandEditorTopListComponent = Class.LightClass("HomelandEditorTopListComponent", UIComponent)

HomelandEditorTopListComponent.FuncName = {
	"changeMultipleChoiceMode",
	"changeGridDisplayMode",
	"changeGridAdsorptionMode",
	"changeOverlookMode"
}
HomelandEditorTopListComponent.KeyName = {
	"Hud/HomelandMultiple",
	"Hud/HomelandGridDisplay",
	"Hud/HomelandGridAdsorption",
	"Hud/HomelandOverlook"
}

function HomelandEditorTopListComponent:onCtor(info)
	self.editor = info.editor
	self.getIsMultiSelectFunc = info.getIsMultiSelectFunc
	self.onMultiSelectFunc = info.onMultiSelectFunc
end

function HomelandEditorTopListComponent:onDestroy()
	self.topList = nil
	self.editor = nil
	self.getIsMultiSelectFunc = nil
	self.onMultiSelectFunc = nil

	HomelandEditorTopListComponent.super.onDestroy(self)
end

function HomelandEditorTopListComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.topListUList = self.objectReference:GetRefValue("listUList")
	self.btnSettingUButton = self.objectReference:GetRefValue("btnSettingUButton")
	self.btnShopUButton = self.objectReference:GetRefValue("btnShopUButton")
	self.settingHotKeyContent = self.objectReference:GetRefValue("settingHotKeyContent")
	self.shopHotKeyContent = self.objectReference:GetRefValue("shopHotKeyContent")
	self.txtSettingTipsUSDFText = self.objectReference:GetRefValue("txtSettingTipsUSDFText")
	self.txtShopTipsUSDFText = self.objectReference:GetRefValue("txtShopTipsUSDFText")
	self.btnDesignUButton = self.objectReference:GetRefValue("btnDesignUButton")
	self.txtDesignTipsUSDFText = self.objectReference:GetRefValue("txtDesignTipsUSDFText")
	self.designHotKeyContent = self.objectReference:GetRefValue("designHotKeyContent")
end

function HomelandEditorTopListComponent:initView()
	function self.topListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local iconHoverUImage = objectReference:GetRefValue("iconHoverUImage")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
		local txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")

		ClientTextUtils.setText(txtTipsUSDFText, pg.getLocalizationText(data.tooltipText))

		iconUImage.url = data.icon
		iconHoverUImage.url = data.icon
		button.isSelected = data.switch or false

		function button.luaClick()
			local isSelect = not button.isSelected

			button.isSelected = isSelect

			local skipMessage = false

			if data.func then
				skipMessage = self[data.func](self, button.isSelected)
			end

			if not skipMessage then
				if isSelect and data.startText then
					pg.global.showBubbleMessageRaw(pg.getLocalizationText(data.startText))
				elseif not isSelect and data.closeText then
					pg.global.showBubbleMessageRaw(pg.getLocalizationText(data.closeText))
				end
			end
		end

		self.ctrl:bindHotKeyPerform(data.keyName, function()
			button.luaClick()
		end, button.gameObject, data.keyName)
		keyHotKeyContent:SetHotKeyPaths(data.keyName)
	end

	function self.btnSettingUButton.luaClick()
		GlobalData.BILogger:customeLog("home_build_mode", {
			action_type = "open_settings"
		})
		pg.global.ui.homelandPlayerEditorSetting:open({
			editor = self.editor,
			areaId = self.ctrl.carGroup and -1 or self.ctrl.areaId or 0
		})
	end

	function self.btnShopUButton.luaClick()
		if self.ctrl.shopButtonClick then
			GlobalData.BILogger:customeLog("home_build_mode", {
				action_type = "open_store"
			})
			self.ctrl:shopButtonClick()
		end
	end

	function self.btnDesignUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_DESIGN, {
			carGroup = self.ctrl.carGroup
		})
	end

	self.ctrl:bindHotKeyPerform("Hud/HomelandSetting", function()
		self.btnSettingUButton.luaClick()
	end, self.btnSettingUButton.gameObject, "Hud/HomelandSetting")
	self.settingHotKeyContent:SetHotKeyPaths("Hud/HomelandSetting")
	self.ctrl:bindHotKeyPerform("Hud/HomelandShop", function()
		self.btnShopUButton.luaClick()
	end, self.btnShopUButton.gameObject, "Hud/HomelandShop")
	self.shopHotKeyContent:SetHotKeyPaths("Hud/HomelandShop")
	self.ctrl:bindHotKeyPerform("Hud/HomelandTopDesign", function()
		self.btnDesignUButton.luaClick()
	end, self.btnDesignUButton.gameObject, "Hud/HomelandTopDesign")
	self.designHotKeyContent:SetHotKeyPaths("Hud/HomelandTopDesign")
	ClientTextUtils.setText(self.txtSettingTipsUSDFText, pg.getGameString("HOMELAND_EDITOR_SETTING_TIPS"))
	ClientTextUtils.setText(self.txtShopTipsUSDFText, pg.getGameString("HOMELAND_FURNITURE_STORE_TIPS"))
	ClientTextUtils.setText(self.txtDesignTipsUSDFText, pg.getGameString("HOMELAND_COMPOSE_DESIGN_TITLE"))
	self:refreshTopList()
end

function HomelandEditorTopListComponent:refreshTopList()
	self.topList = self:getEditorTopList()

	if self.getIsMultiSelectFunc then
		self.topList[1].switch = self.getIsMultiSelectFunc()
	end

	self.topListUList:SetList(self.topList)
end

function HomelandEditorTopListComponent:getEditorTopList()
	local topList = {}

	for i, v in ipairs(HomeFreePlacementData) do
		local switch = pg.game.home:getHomeEditorPlayerSetting(i, v.defaultState == 1)

		table.insert(topList, {
			icon = v.icon,
			switch = switch,
			startText = v.startText,
			closeText = v.closeText,
			func = self.FuncName[i],
			keyName = self.KeyName[i],
			tooltipText = v.tooltipText
		})
	end

	return topList
end

function HomelandEditorTopListComponent:changeMultipleChoiceMode(switch)
	if self.onMultiSelectFunc then
		self.onMultiSelectFunc(switch)
	end

	if self.ctrl then
		self:refreshTopList()
	end

	return true
end

function HomelandEditorTopListComponent:changeGridDisplayMode(switch)
	self.topList[2].switch = switch or false

	pg.game.home:setHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.GridDisplay, switch, self.editor)
end

function HomelandEditorTopListComponent:changeGridAdsorptionMode(switch)
	self.topList[3].switch = switch or false

	pg.game.home:setHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.GridAdsorption, switch, self.editor)
end

function HomelandEditorTopListComponent:changeOverlookMode(switch)
	self.topList[4].switch = switch or false

	pg.game.home:setHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.Overlook, switch, self.editor)
end

return HomelandEditorTopListComponent
