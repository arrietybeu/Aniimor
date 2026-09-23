-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\PetSkillCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local SkillReplaceComponent = require("Guis.Panels.PetSkill.Component.SkillReplaceComponent")
local SkillLearnComponent = require("Guis.Panels.PetSkill.Component.SkillLearnComponent")
local ItemConst = require("Common.Const.ItemConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetSkillCtrl = Class.LightClass("PetSkillCtrl", UICtrl)

PetSkillCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	}
}

function PetSkillCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.notPetManagement = info.notPetManagement
	self.skillReplaceComponent = SkillReplaceComponent.new(self)
	self.skillLearnComponent = SkillLearnComponent.new(self)

	self:Init(info)
end

function PetSkillCtrl:onShow()
	if self.from == "learn" then
		self.view.skillLearnUButton:OnClickSimulate()
	elseif self.from == "replace" then
		self.view.skillSwapUButton:OnClickSimulate()
	else
		self:closePanel()
	end
end

function PetSkillCtrl:onHide()
	return
end

function PetSkillCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetSkillCtrl:Init(info)
	self.from = info.from
	self.petId = info.petId
	self.model.IS_PVP_FAIL_MODE = info.pvpFailMode

	self.view.root:TryChangePage("pvp", self.model.IS_PVP_FAIL_MODE ~= nil and 1 or 0)

	self.view.petName.text, self.petInfo = self.model:getPetNameAndInfo(self.petId)

	self.view.imgPetUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(PetData[self.petInfo.templateId].iconName, LuaUIUtils.PET_ICON, self.petInfo.label, self.petInfo.gender), function()
		return
	end)

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.view.listCurrencyUList:SetList({
		{
			itemId = ItemConst.ITEM_SPECIAL_MONEY_COIN
		}
	})
end

function PetSkillCtrl:destroy()
	return
end

function PetSkillCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self.closePanel()
	end

	function self.view.skillSwapUButton.luaClick()
		self:switchSkillPanelPages(false)
		self.skillReplaceComponent:init(self.petInfo.id)
	end

	function self.view.skillLearnUButton.luaClick()
		self:switchSkillPanelPages(true)
		self.skillLearnComponent:init(self.petId)
	end
end

function PetSkillCtrl:switchSkillPanelPages(isLearn)
	self.view.root:TryChangePage("Type", not isLearn and 1 or 0)

	if isLearn then
		self.view.skillLearnUButton:TryChangePage("button", 5)

		self.view.skillLearnUButton.isSelected = true

		self.view.skillSwapUButton:TryChangePage("button", 0)

		self.view.skillSwapUButton.isSelected = false
	else
		self.view.skillLearnUButton:TryChangePage("button", 0)

		self.view.skillLearnUButton.isSelected = false

		self.view.skillSwapUButton:TryChangePage("button", 5)

		self.view.skillSwapUButton.isSelected = true
	end
end

function PetSkillCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_SKILL)
end

function PetSkillCtrl:onPetCurAbilityChanged(info)
	local petId = info.petId

	if petId == self.petId then
		self.skillReplaceComponent:refreshSkillList(self.petId)
		self.skillReplaceComponent:refreshAllSkillsBtnState()
		self.skillReplaceComponent:playRefreshAnim(info.index)
	end
end

return PetSkillCtrl
