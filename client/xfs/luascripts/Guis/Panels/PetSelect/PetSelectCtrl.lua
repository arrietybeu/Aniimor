-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelect\\PetSelectCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetSelectCtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local GlobalData = require("Core.Client.GlobalData")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local UICtrl = require("Guis.UICtrl")
local PetSaveBanData = require("Data.event_petsave_ban_data")
local SysConfigData = require("Data.sys_config_data")
local PetSelectCtrl = Class.LightClass("PetSelectCtrl", UICtrl)

PetSelectCtrl.messages = {}

function PetSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	self:initUI()
end

function PetSelectCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.btnBack.gameObject, "Common/Cancel", function()
		self.view.btnBack.luaClick()
	end)

	function self.view.btnBack.luaClick()
		self:dismiss()
	end

	function self.view.confirmBtn.luaClick()
		local pet = pg.me:getPetInfo(self.selectedPetId)

		if pet then
			local descTxt, tipTxt

			if not ClientActivityUtils.checkPetSaveFinish() then
				descTxt = pg.getGameString("PET_SAVE_CHANGE_TIME_1")
			else
				local limitIndex = pg.me.activityPetSaveData.saveTimes < 2 and 2 or 3

				descTxt = pg.getGameString("PET_SAVE_CHANGE_TIME_" .. limitIndex)
				tipTxt = pg.getFormatText(pg.getGameString("PET_SAVE_CHANGE_TIP"), SysConfigData.PETSAVE_CHANGE_TIME - pg.me.activityPetSaveData.saveTimes, SysConfigData.PETSAVE_CHANGE_TIME)
			end

			pg.global.ui:open(UIConst.UI_ID_PET_CONFIRM, {
				title = pg.getFormatText(pg.getLocalizationText(self.info.confirmTitle), pg.me.playerName),
				desc = descTxt,
				tip = tipTxt,
				templateId = pet.templateId,
				label = pet.label,
				confirmCb = function()
					self.info.confirmCb()
				end
			}, nil, function()
				PetManagementUtils._previewSceneProcess()
			end)
		end
	end
end

function PetSelectCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function PetSelectCtrl:initUI()
	ClientTextUtils.setText(self.view.titleUBaseText, self.info.title or "")
	self.view.btnReleaseUButton:SetActive(false)

	self.pet = pg.me.activityPetSaveData.savePetInfo

	PetManagementUtils.setListButtonDelegateTable({
		selectedChanged = function(data)
			self.selectedPetId = data.id

			if PetManagementUtils.petManagementSceneCtrl.scene then
				PetManagementUtils.petManagementSceneCtrl:previewPet(data.id)
			end

			local isValid, text = self:checkIsValidPetAndGetText(data)

			self.view.confirmBtn.interactable = isValid

			self.view.confirmBtn:TryChangePage("button", isValid and 0 or 4)
			ClientTextUtils.setText(self.view.warningUBaseText, text or "")
		end,
		renderExtraLogic = function(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
			local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
			local txtUsedUSDFText = objectReference:GetRefValue("txtUsedUSDFText")
			local isValid = self:checkIsValidPetAndGetText(data)

			if panelCharListUContainer.content then
				panelCharListUContainer.content.gameObject:SetActiveEx(not isValid)
			end

			if panelCPUContainer.content then
				panelCPUContainer.content.gameObject:SetActiveEx(isValid)
			end

			local text

			if not isValid then
				if self.pet and self.pet.entityId == data.id then
					text = ClientTextUtils.getGameString("PET_SAVE_SEAL_TIP_1")
				else
					text = ClientTextUtils.getGameString("PET_SAVE_SEAL_TIP_2")
				end

				ClientTextUtils.setText(txtUsedUSDFText, text)
			end

			txtUsedUSDFText:SetActive(not isValid)
			button:TryChangePage("state", isValid and 0 or 1)

			button.draggable = false
		end,
		luaHover = function(button, index, data)
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		end,
		luaUnhover = function(button, index, data)
			button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	})
	PetManagementUtils.initTemplate(self.view.petInfoPanelTransform, self.view.petListTransform, {
		textureWidth = 1024,
		defaultSelectTabIndex = 0,
		textureHeight = 1024,
		uiScene = self.uiScene
	})

	self.selectedPetId = PetManagementUtils.petId

	PetManagementUtils._refreshPetSelectedStatus(0)
	PetManagementUtils.petManagementSceneCtrl:previewPet(PetManagementUtils.petId)
end

function PetSelectCtrl:onVisibleChange(visible)
	if visible and PetManagementUtils.petManagementSceneCtrl.scene then
		PetManagementUtils.petManagementSceneCtrl:playPetIdle()
	end
end

function PetSelectCtrl:onDestroy()
	UICtrl.onDestroy(self)
	PetManagementUtils.destroyTemplate()
end

function PetSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetSelectCtrl:onShow()
	return
end

function PetSelectCtrl:onHide()
	return
end

function PetSelectCtrl:checkIsValidPetAndGetText(data)
	if data.isEmpty then
		return false
	end

	local banCfg = PetSaveBanData[data.petPrototypeId]

	if banCfg then
		if banCfg.typeName == "special" then
			return false, pg.getGameString("PET_SAVE_TIP_XY")
		elseif banCfg.typeName == "rainbow" then
			return false, pg.getGameString("PET_SAVE_TIP_Rainbow")
		end

		return false, pg.getGameString("PET_SAVE_TIP_XY")
	end

	local petPrepareList = pg.me.petPrepareList

	for i = 1, #petPrepareList do
		if petPrepareList[i] == data.id then
			return false, pg.getGameString("PET_SAVE_TIP_Fight")
		end
	end

	local explorePets = PetManagementDataHelper.getPetExploreGroupPetsInModel()

	for _, id in pairs(explorePets) do
		if id == data.id then
			return false, pg.getGameString("PET_SAVE_TIP_Explore")
		end
	end

	if not ClientActivityUtils.checkPetSaveFinish() then
		return true
	else
		return true, pg.getFormatText(pg.getGameString("PET_SAVE_CHANGE_TIP_2"), SysConfigData.PETSAVE_CHANGE_TIME - pg.me.activityPetSaveData.saveTimes, SysConfigData.PETSAVE_CHANGE_TIME)
	end
end

return PetSelectCtrl
