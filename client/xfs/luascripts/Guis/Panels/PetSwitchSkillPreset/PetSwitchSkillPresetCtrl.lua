-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSwitchSkillPreset\\PetSwitchSkillPresetCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local PetSwitchSkillPresetCtrl = Class.LightClass("PetSwitchSkillPresetCtrl", UICtrl)

PetSwitchSkillPresetCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetSwitchSkillPresetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init(info)
end

function PetSwitchSkillPresetCtrl:onShow()
	return
end

function PetSwitchSkillPresetCtrl:onHide()
	return
end

function PetSwitchSkillPresetCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetSwitchSkillPresetCtrl:Init(info)
	self.notPetManagement = info.notPetManagement
	self.model.IS_PVP_FAIL_MODE = info.pvpFailMode
	self.templateId = info.templateId

	if self.model.IS_PVP_FAIL_MODE ~= nil then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[info.curPetId].serverData

		self.petInfo = serverData
	else
		self.petInfo = pg.me:getPetInfo(info.curPetId)

		if not self.petInfo or not self.petInfo.abilityPresetMap then
			self:closePanel()

			return
		end
	end

	self.curPetId = info.curPetId
	self.cacheCurPetId = info.curPetId
	self.curSelectPresetSkillIndex = self.petInfo.curAbilityPreset

	ClientTextUtils.setText(self.view.title, self.model:getPresetName(info.curPetId, self.petInfo.curAbilityPreset))

	function self.view.listPresetUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end

	local data = self.model:getAllPresetSkills(info.curPetId)

	self.view.listPresetUList:SetList(data)
end

function PetSwitchSkillPresetCtrl:destroy()
	self.petInfo = nil
	self.curPetId = nil
	self.curSelectPresetSkillIndex = nil
end

function PetSwitchSkillPresetCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnBottomUButton.luaClick()
		self:choosePreset()
	end
end

function PetSwitchSkillPresetCtrl:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnEditUButton = objectReference:GetRefValue("btnEditUButton")
	local listUList = objectReference:GetRefValue("listUList")
	local emptyBtnUButton = objectReference:GetRefValue("emptyBtnUButton")

	local function selectThisPreset()
		local btns = self.view.listPresetUList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			btns[i]:TryChangePage("select", 0)
		end

		button:TryChangePage("select", 1)

		self.curSelectPresetSkillIndex = index + 1

		ClientTextUtils.setText(self.view.title, self.model:getPresetName(self.curPetId, index + 1))
	end

	local function innerFun()
		selectThisPreset()
		self.view.btnBottomUButton:OnClickSimulate()
		self:openSkillConfigUI()
	end

	function emptyBtnUButton.luaClick()
		innerFun()
	end

	if data[1].abilityId == self.model.EMPTY_ABILITY_ID and data[2].abilityId == self.model.EMPTY_ABILITY_ID then
		button:TryChangePage("State", 0)
	else
		button:TryChangePage("State", 1)
	end

	if self.petInfo.curAbilityPreset == index + 1 then
		button:TryChangePage("inUse", 1)
	else
		button:TryChangePage("inUse", 0)
	end

	button:TryChangePage("select", self.curSelectPresetSkillIndex == index + 1 and 1 or 0)
	ClientTextUtils.setText(txtNameUSDFText, self.model:getPresetName(self.curPetId, index + 1))

	function btnEditUButton.luaClick()
		if self.model.IS_PVP_FAIL_MODE ~= nil then
			return
		end

		pg.global.ui.tips:showCommonInput(pg.getGameString("RENAME_TIPS_SKILL"), function(newName)
			pg.me:serverMsg("RPC_CS_PetRenameAbilityPreset", self.curPetId, index + 1, newName, function(result)
				if result then
					self:onPetCurAbilityChanged({
						index = index + 1
					})
				end

				if self.curSelectPresetSkillIndex == index + 1 then
					ClientTextUtils.setText(self.view.title, self.model:getPresetName(self.curPetId, index + 1))
				end
			end)
		end, function()
			return
		end, {
			characterLimit = 14,
			text = self.model:getPresetName(self.curPetId, index + 1) or ""
		})
	end

	function button.luaPress()
		selectThisPreset()
	end

	function button.luaClick(isFromNavigation)
		if isFromNavigation then
			return
		end

		if data[1].abilityId == self.model.EMPTY_ABILITY_ID and data[2].abilityId == self.model.EMPTY_ABILITY_ID then
			innerFun()
		end
	end

	function listUList.luaRenderItem(b, i, d)
		local objectReference1 = b:GetComponent("ObjectReference")
		local iconSkillUImage = objectReference1:GetRefValue("iconSkillUImage")
		local txtNameUSDFText1 = objectReference1:GetRefValue("txtNameUSDFText")
		local listTagUList = objectReference1:GetRefValue("listTagUList")
		local elementUButton = objectReference1:GetRefValue("elementUButton")
		local keyEquipmentHotKeyContent = objectReference1:GetRefValue("keyEquipmentHotKeyContent")

		if d.abilityType == AbilityConst.WEAPON_SKILL_ABILITY then
			keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillQ")
		else
			keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillE")
		end

		function b.luaClick()
			if d.abilityId == self.model.EMPTY_ABILITY_ID then
				innerFun()
			end
		end

		if d.abilityId == self.model.EMPTY_ABILITY_ID then
			b:TryChangePage("empty", 1)
			b:TryChangePage("Element", 0)
			b:TryChangePage("IsRare", 0)

			b.enabledTooltip = false
			b.interactable = true
		else
			b:TryChangePage("empty", 0)
			b:TryChangePage("IsRare", d.rare)

			iconSkillUImage.url = LuaUIUtils.getSkillIcon(d.icon)

			ClientTextUtils.setText(txtNameUSDFText1, pg.getLocalizationText(d.name))

			function listTagUList.luaRenderItem(b1, _, d1)
				local objectReference2 = b1:GetComponent("ObjectReference")
				local txtNameUText = objectReference2:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d1.tagName))
			end

			if d.tagShowList then
				listTagUList:SetList(d.tagShowList)
			else
				listTagUList:SetList(d.tagList)
			end

			if d.elementType then
				b:TryChangePage("Element", 1)
				LuaUIUtils.setElementButtonNew(elementUButton, d.elementType)
			end

			b.enabledTooltip = false
			b.interactable = false
		end
	end

	listUList:SetList(data)
end

function PetSwitchSkillPresetCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK)
end

function PetSwitchSkillPresetCtrl:onPetCurAbilityChanged(info)
	local btns = self.view.listPresetUList:GetAllButtons()
	local objectReference = btns[info.index - 1]:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, self.model:getPresetName(self.curPetId, info.index))
end

function PetSwitchSkillPresetCtrl:openSkillConfigUI()
	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_TRAINING_NEW) then
		if self.notPetManagement then
			PetManagementUtils.onEvolveClick(self.cacheCurPetId, self.templateId, {
				onlyShowSkillPage = true,
				pvpFailMode = self.model.IS_PVP_FAIL_MODE,
				toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL],
				notPetManagement = self.notPetManagement
			})
		else
			PetManagementUtils.onEvolveClick(self.cacheCurPetId, self.templateId, {
				pvpFailMode = self.model.IS_PVP_FAIL_MODE,
				toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL],
				notPetManagement = self.notPetManagement
			})
		end
	end
end

function PetSwitchSkillPresetCtrl:isCurSelectPresetEmpty()
	local presets = self.model:getAllPresetSkills(self.curPetId)
	local presetData = presets and presets[self.curSelectPresetSkillIndex]

	return presetData and presetData[1] and presetData[1].abilityId == self.model.EMPTY_ABILITY_ID and presetData[2] and presetData[2].abilityId == self.model.EMPTY_ABILITY_ID
end

function PetSwitchSkillPresetCtrl:choosePreset()
	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet

		pvpPetSet.model.petsMap[self.curPetId].serverData.curAbilityPreset = self.curSelectPresetSkillIndex

		pvpPetSet:sendSavePetInfoMsg(self.curPetId, 2)
	else
		pg.me:serverMsg("RPC_CS_PetApplyAbilityPreset", self.curPetId, self.curSelectPresetSkillIndex)
	end

	self:closePanel()
end

return PetSwitchSkillPresetCtrl
