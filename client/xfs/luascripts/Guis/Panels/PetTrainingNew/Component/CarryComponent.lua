-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\CarryComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CarryComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local CarryComponent = Class.LightClass("CarryComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ItemPropUIUtils = require("Utils.ItemPropUIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local TimerManager = require("Core.Timer.TimerManager")
local isShowDebugInfo = false
local CORE_CARRY_CERTIFY_TIP_TITLE = "CARRY_CERT_TITLE"
local CORE_CARRY_CERTIFY_TIP_DESC = "CARRY_CERT_TIPS_ENHANCED"
local CORE_CARRY_CERTIFY_TIP_ACTIVE = "CARRY_CERT_ON"
local CORE_CARRY_CERTIFY_TIP_INACTIVE = "CARRY_CERT_OFF"
local CORE_CARRY_CERTIFY_BUTTON = "CARRY_CERT_BTN"
local CORE_CARRY_CERTIFY_SKILL_TIP = "CARRY_CERT_SKILL_TIP"
local CORE_CARRY_CERTIFIED = "PET_CARRY_CERTIFIED"
local CORE_CARRY_CERTIFY_ANI_ACTIVATE = "VX_Pb_PetManagement_Cultivate_ContactActivate"
local CORE_CARRY_CERTIFY_ANI_CHANGE = "VX_Pb_PetManagement_Cultivate_ContactChange"
local CORE_CARRY_EQUIP_ANI = "VX_Pb_PetManagement_Cultivate_BtnCarryFit"

function CarryComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.listProps = self.objectReference:GetRefValue("listProps")
	self.selectorUSelector = self.objectReference:GetRefValue("selectorUSelector")
	self.btnSort = self.objectReference:GetRefValue("btnSort")
	self.imgSlot = self.objectReference:GetRefValue("imgSlot")
	self.tabCarry = self.objectReference:GetRefValue("tabCarry")
	self.tabCarryAssst = self.objectReference:GetRefValue("tabCarryAssst")
	self.assistPosList = self.objectReference:GetRefValue("assistPosList")
	self.leftComponent = self.objectReference:GetComponent("leftComponent")
	self.assistTab1 = self.objectReference:GetRefValue("assistTab1")
	self.assistTab2 = self.objectReference:GetRefValue("assistTab2")
	self.assistTab3 = self.objectReference:GetRefValue("assistTab3")
	self.txtCarryAssitEnergyStage = self.objectReference:GetRefValue("txtCarryAssitEnergyStage")
	self.txtCarryAssitEnergyPro = self.objectReference:GetRefValue("txtCarryAssitEnergyPro")
	self.txtCarryAssitEnergyDone = self.objectReference:GetRefValue("txtCarryAssitEnergyDone")
	self.jewelBonus = self.objectReference:GetRefValue("jewelBonus")
	self.jewelBonusInfoUWidget = self.objectReference:GetRefValue("jewelBonusInfoUWidget")
	self.jewelBonusGet = self.objectReference:GetRefValue("jewelBonusGet")
	self.txtEmptyAssist = self.objectReference:GetRefValue("txtEmptyAssist")
	self.btnCarryCore = self.objectReference:GetRefValue("btnCarryCore")
	self.carryNewAnimation = self.objectReference:GetRefValue("carryNewAnimation")
	self.carryFigure = self.objectReference:GetRefValue("carryFigure")
	self.infoUComponent = self.objectReference:GetRefValue("infoUComponent")
	self.cpInfoUComponent = self.objectReference:GetRefValue("cpInfoUComponent")
	self.btnCompare = self.objectReference:GetRefValue("btnCompare")
	self.btnEquip = self.objectReference:GetRefValue("btnEquip")
	self.btnStrengthen = self.objectReference:GetRefValue("btnStrengthen")
	self.infoAssistUComponent = self.objectReference:GetRefValue("infoAssistUComponent")
	self.cpInfoAssistUComponent = self.objectReference:GetRefValue("cpinfoAssistUComponent")
	self.btnAssistCompare = self.objectReference:GetRefValue("btnAssistCompare")
	self.btnAssistEquip = self.objectReference:GetRefValue("btnAssistEquip")
	self.btnCompound = self.objectReference:GetRefValue("btnCompound")
	self.txtCompound = self.objectReference:GetRefValue("txtCompound")
	self.dragTemplateUWidget = self.objectReference:GetRefValue("dragTemplateUWidget")
	self.btnRecommendUButton = self.objectReference:GetRefValue("btnRecommendUButton")
	self.recommendUSDFText = self.objectReference:GetRefValue("recommendUSDFText")
	self.recommendTxtMaxUSDFText = self.objectReference:GetRefValue("recommendTxtMaxUSDFText")
	self.recommendTipsUWidget = self.objectReference:GetRefValue("recommendTipsUWidget")
	self.btnGoToUButton = self.objectReference:GetRefValue("btnGoToUButton")
	self.btnToGetUButton = self.objectReference:GetRefValue("btnToGetUButton")
	self.gotoCarrySourceUSDFText = self.objectReference:GetRefValue("gotoCarrySourceUSDFText")
	self.txtToGetUSDFText = self.objectReference:GetRefValue("txtToGetUSDFText")

	ClientTextUtils.setText(self.gotoCarrySourceUSDFText, pg.getGameString("PETCARRY_GOTTO_SOURCE"))
	ClientTextUtils.setText(self.txtToGetUSDFText, pg.getGameString("PETCARRY_GOTTO_SOURCE"))

	self.btnContactUButton = self.objectReference:GetRefValue("btnContactUButton")
	self.contactPetIconUImage = self.objectReference:GetRefValue("contactPetIconUImage")
	self.contactTxtNameUSDFText = self.objectReference:GetRefValue("contactTxtNameUSDFText")

	ClientTextUtils.setText(self.contactTxtNameUSDFText, "")

	local disTs = self.transform:Find("Solt/Dis")

	self.certifyContactTUAnimation = disTs and disTs:GetComponent("Animation")

	local carryEquipTs = self.transform:Find("Solt/Dis/Display/Bg")

	self.carryEquipTUAnimation = carryEquipTs and carryEquipTs:GetComponent("Animation")

	local contactBgTs = self.transform:Find("Solt/Dis/Display/Bg/Contact")

	self.contactBgUWidget = contactBgTs and contactBgTs:GetComponent("UWidget")
end

function CarryComponent:initView()
	function self.listProps.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.listProps.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onPropSelectChanged(uList)
	end

	self.assistPosItems = {}

	function self.assistPosList.luaRenderItem(button, index, data)
		self:onRenderAssistPosItem(button, index, data)
	end

	function self.assistPosList.luaSelectedChanged(uList)
		self:onAssistPosSelectChanged(uList)
	end

	function self.selectorUSelector.luaSelectedChanged(selector)
		self.model:setSortOption(selector.selectedIndex)
		self:onOptionSelected()

		if self.delayCloseSelectPopTimer then
			self:killTimer(self.delayCloseSelectPopTimer)

			self.delayCloseSelectPopTimer = nil
		end

		self.delayCloseSelectPopTimer = self:startTimer(function()
			self.selectorUSelector:ClosePopup(true)

			self.delayCloseSelectPopTimer = nil
		end, 0.15)
	end

	function self.btnSort.luaClick()
		self.model:switchSortAscending()
		self:onOptionSelected()
	end

	for i = 1, 3 do
		self["assistTab" .. i].luaClick = function()
			if self.curCompareState ~= 0 then
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_GEM_CAN_NOT_COMPARE_TYPE_DIFFERENT"))

				self.tabTimer = self:startTimer(function()
					self:refreshAssistTabState()
				end, 0.1)

				return
			end

			self.assistPosList:DeselectAll()
			self.model:setAssistTypeOption(i)
			self:onOptionSelected()
			self:m_autoSelectFirstUnequippedAsst()

			if self.listProps and self.listProps.selectedItem then
				self:setAssistPosAutoSelect(self.listProps.selectedItem)
			end

			if (not self.selectAsstPosInfo or self.selectAsstPosInfo.type ~= i) and self.posAssistList then
				for _, v in ipairs(self.posAssistList) do
					if v.type == i and v.state ~= 0 then
						local btn = self.assistPosItems and self.assistPosItems[v.posIndex]

						if btn then
							self.assistPosList:SetNavGroupDefaultItem(btn)
						end

						break
					end
				end
			end

			pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Restore)
		end
	end

	function self.btnCompare.luaClick()
		self:onBtnCompare()
	end

	function self.btnEquip.luaClick()
		self:onBtnEquip()
	end

	function self.btnStrengthen.luaClick()
		self:onBtnStrength()
	end

	function self.tabCarry.luaClick()
		self:choseCarryCore()
		pg.global.navMgr:FocusGroupByName("ListProps", false)
	end

	function self.btnCarryCore.luaClick()
		self:choseCarryCore()
	end

	function self.tabCarryAssst.luaClick()
		if not self.model:isAssistOpen() then
			pg.global.showBubbleMessageById(PetConfigData.gemsNotActivationFeedback)
			self:unableSelectAssist()

			return
		end

		local selectCarryCore = self.model:getSelectCarryCore()

		if not selectCarryCore then
			pg.global.showBubbleMessageById(NoticeDef.NOT_EQUIP_CARRY_CORE)
			self:unableSelectAssist()

			return
		end

		self:choseCarryAssist()
		self.assistPosList:SelectItem(0)
		pg.global.navMgr:FocusGroupByName("JewelList", false)
	end

	function self.btnAssistCompare.luaClick()
		self:onBtnCompare()
	end

	function self.btnAssistEquip.luaClick()
		self:onAssistEquip()
	end

	function self.btnCompound.luaClick()
		self:onBtnCompound()
	end

	local isRogue = self.ctrl:isInRogueDungeon()

	self.btnCompound.interactable = not isRogue
	self.curCompareState = 0

	function self.btnRecommendUButton.luaClick()
		self:onBtnRecommendUButton()
	end

	self.btnRecommendUButton.interactable = not isRogue

	self.recommendTipsUWidget:SetActive(not isRogue)
	ClientTextUtils.setText(self.recommendUSDFText, pg.getGameString("PETCARRY_RECOMMEND"))
	ClientTextUtils.setText(self.recommendTxtMaxUSDFText, pg.getGameString("PETCARRY_RECOMMEND_TIP"))

	local defaultSourceId = 3

	LuaUIUtils.setSourceSeekButton(self.btnGoToUButton, PetConfigData.PETCARRY_SOURCE_ID_1 or defaultSourceId, true)
	LuaUIUtils.setSourceSeekButton(self.btnToGetUButton, PetConfigData.PETCARRY_SOURCE_ID_2 or defaultSourceId, true)

	function self.rootComponent.luaTryChangePage()
		if self.ctrl and self.ctrl.refreshConsoleBarState then
			self.ctrl:refreshConsoleBarState()
		end
	end
end

function CarryComponent:init(info)
	self.petId = info.petId

	self.model:setSelectCarryCore(nil)

	self.m_selectedCarryCore = {}

	if self.curType and self.curType ~= ItemConst.ITEM_TYPE_CARRY_CORE then
		self.carryNewAnimation:Play("VX_Pb_PetManagement_Cultivate_Carry_CarrySlecet")
	end

	self.curType = ItemConst.ITEM_TYPE_CARRY_CORE

	self.view.centerTabUWidget.simulateButtonSwitch:SetCursor(self.curType - 7, -1)

	self.carryPetInfo = self.model:getPetCarryInfo(self.petId)

	self:refreshGroupSelectorOptions()
	self.rootComponent:TryChangePage("JewelCompare", 0)
	self.rootComponent:TryChangePage("CarryContact", PetManagementDataHelper.CoreCarryContactState.Unlocked)
	self:tryChangeCoreCarryCertifyActivationState(PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive)
	self:refreshCoreCarryCertifyButton(nil)
	self.btnSort:TryChangePage("Sort", not self.model.isAscending and 1 or 0)
	ClientTextUtils.setText(self.txtCompound, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_ENTRANCE_BUTTON"))
	ClientTextUtils.setText(self.txtEmptyAssist, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_NO_GEM_DEFAULT"))
end

function CarryComponent:refreshGroupSelectorOptions()
	local groupInfos

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		groupInfos = self.model:getCarrySortOptions()

		self.assistPosList:DeselectAll()
	else
		groupInfos = pg.global.ui.petCarryAssistStrength.model:getCarrySortOptions()
	end

	self.model:setSortOption(0)
	self.selectorUSelector:SetOptions(groupInfos)

	self.selectorUSelector.selectedIndex = self.model:getSortOption()
end

function CarryComponent:m_isViewValid()
	return self.view and self.rootComponent and not IsNil(self.rootComponent)
end

function CarryComponent:m_findCarryCoreInList(dataList, checkCore)
	if not dataList or not checkCore or not checkCore.invId or not checkCore.genID then
		return -1, nil
	end

	for i, v in ipairs(dataList) do
		if v.invId == checkCore.invId and v.genID == checkCore.genID then
			return i - 1, v
		end
	end

	return -1, nil
end

function CarryComponent:m_findFirstUnequippedCarryCore(dataList)
	if not dataList or #dataList <= 0 then
		return -1, nil
	end

	for i, v in ipairs(dataList) do
		if not v.isEquipped then
			return i - 1, v
		end
	end

	return 0, dataList[1]
end

function CarryComponent:m_resetCoreCompareState()
	self.btnCompare:SetActive(false)

	self.curCompareState = 0

	self.rootComponent:TryChangePage("JewelCompare", 0)

	if self.ctrl and self.ctrl.setTabLeftActive then
		self.ctrl:setTabLeftActive(true)
	end
end

function CarryComponent:m_closeCompareView()
	local _, page = self.rootComponent:TryGetCurrentPage("JewelCompare")

	if self.curCompareState == 0 and page == 0 then
		return
	end

	self.curCompareState = 0

	self.rootComponent:TryChangePage("JewelCompare", 0)

	if self.ctrl and self.ctrl.setTabLeftActive then
		self.ctrl:setTabLeftActive(true)
	end

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		local coreData = self.model:getSelectCarryCore()

		if coreData then
			self:refreshPropInfoJewelUWidget(self.infoUComponent, coreData)
		end
	end
end

function CarryComponent:choseCarryCore()
	if self.curType ~= ItemConst.ITEM_TYPE_CARRY_CORE then
		self.carryNewAnimation:Play("VX_Pb_PetManagement_Cultivate_Carry_CarrySlecet")
	end

	self.curType = ItemConst.ITEM_TYPE_CARRY_CORE

	self.view.centerTabUWidget.simulateButtonSwitch:SetCursor(self.curType - 7, -1)
	self:refreshGroupSelectorOptions()
	self:onOptionSelected()
end

function CarryComponent:choseCarryAssist()
	if self.curType ~= ItemConst.ITEM_TYPE_CARRY_ASSISTED then
		self.carryNewAnimation:Play("VX_Pb_PetManagement_Cultivate_Carry_JewelSlecet")
	end

	self.curType = ItemConst.ITEM_TYPE_CARRY_ASSISTED

	self.view.centerTabUWidget.simulateButtonSwitch:SetCursor(self.curType - 7, -1)
	self:refreshGroupSelectorOptions()
	self:onOptionSelected()
end

function CarryComponent:onOptionSelected(selectInfo, forceDeselect)
	local isCarryCore = self.curType == ItemConst.ITEM_TYPE_CARRY_CORE
	local dataList = self.model:getCarryPropListWithFilter(self.curType)

	self.listProps:SetList(dataList)
	self.tabCarry:SetSelected(isCarryCore)
	self.tabCarryAssst:SetSelected(not isCarryCore)
	self.rootComponent:TryChangePage("selectbag", self.curType == ItemConst.ITEM_TYPE_CARRY_ASSISTED and 0 or 1)

	if isCarryCore and forceDeselect then
		self.model:setSelectCarryCore(nil)
		self.listProps:DeselectAll(false)
		self:refreshSlotView(nil)
		self:refreshSelectPropView(nil)
		self:m_resetCoreCompareState()

		if #dataList > 0 then
			self.carryFigure:TryChangePage("Quality", 0)
		end

		self.rootComponent:TryChangePage("Empty", #dataList > 0 and 2 or 1)
		self.rootComponent:TryChangePage("EmptyState", 0)
		self.rootComponent:TryChangePage("JewelUnlock", 1)

		return
	end

	if isCarryCore then
		local selectCarryCore = self.model:getSelectCarryCore()
		local selectedCore

		if #dataList > 0 then
			local selectIdx, validSelectCore = self:m_findCarryCoreInList(dataList, selectCarryCore)
			local hasInvalidSelectCore = selectCarryCore and selectIdx < 0
			local carryPetIdx, validCarryPetCore = self:m_findCarryCoreInList(dataList, self.carryPetInfo)
			local hasInvalidCarryPetCore = self.carryPetInfo.isEquipped and carryPetIdx < 0

			if hasInvalidSelectCore then
				self.model:setSelectCarryCore(nil)

				selectCarryCore = nil
			end

			if hasInvalidCarryPetCore then
				self.carryPetInfo = {
					isEquipped = false,
					genID = 0,
					invId = 0
				}
			end

			if selectIdx >= 0 then
				selectedCore = validSelectCore
			elseif self.carryPetInfo.isEquipped then
				selectIdx = carryPetIdx
				selectedCore = validCarryPetCore
			end

			if selectIdx < 0 and (hasInvalidSelectCore or hasInvalidCarryPetCore) then
				selectIdx, selectedCore = self:m_findFirstUnequippedCarryCore(dataList)
			end

			if selectIdx >= 0 then
				self.listProps:SelectItem(selectIdx)
				self.listProps:GoToIndex(selectIdx)
			else
				self:m_resetCoreCompareState()
				self.carryFigure:TryChangePage("Quality", 0)
				self.rootComponent:TryChangePage("Empty", 2)
			end
		else
			self:m_resetCoreCompareState()
			self.rootComponent:TryChangePage("Empty", 1)
		end

		self.rootComponent:TryChangePage("EmptyState", 0)

		local checkCore = selectedCore or self.model:getSelectCarryCore()
		local unlockState = checkCore and self.model:getJewelUnlockStateByCoreCarryIds(checkCore.invId, checkCore.genID) or 1

		self.rootComponent:TryChangePage("JewelUnlock", unlockState)
	else
		self.rootComponent:TryChangePage("EmptyState", #dataList > 0 and 0 or 1)

		local checkCore = self.m_selectedCarryCore or {}
		local unlockState = checkCore and self.model:getJewelUnlockStateByCoreCarryIds(checkCore.invId, checkCore.genID) or 1

		self.rootComponent:TryChangePage("JewelUnlock", unlockState)

		if #dataList > 0 then
			local cpInfo = self.selectAsstPosInfo and self.selectAsstPosInfo.asstData or selectInfo

			if cpInfo and next(cpInfo) then
				for i, v in ipairs(dataList) do
					if cpInfo.genID == v.genID and cpInfo.invId == v.invId then
						self.listProps:SelectItem(i - 1)
						self.listProps:GoToIndex(i - 1)

						break
					end
				end
			else
				self:m_autoSelectFirstUnequippedAsst()
			end
		end

		self:refreshAssistTabState()
	end
end

function CarryComponent:m_autoSelectFirstUnequippedAsst()
	local data = self.listProps and self.listProps.itemData
	local count = data and data.Count or 0

	if count == 0 then
		return
	end

	for i = 0, count - 1 do
		local v = data[i]

		if not v.isEquipped then
			self.listProps:SelectItem(i)
			self.listProps:GoToIndex(i)

			return
		end
	end

	self.listProps:SelectItem(0)
end

function CarryComponent:setAssistPosAutoSelect(sData)
	if sData.ownerCoreCarryPos and next(sData.ownerCoreCarryPos) and sData.ownerCoreCarryPos[1] ~= 0 and sData.ownerCoreCarryPos[2] ~= 0 then
		for i, v in ipairs(self.posAssistList) do
			if v.asstData and sData.invId == v.asstData.invId and sData.genID == v.asstData.genID then
				self.assistPosList:SelectItem(i - 1, false)
				self.model:setAssistTypeOption(v.type)
				self:setSelectAsstPosInfo(v)
				self:refreshBtnState()

				return
			end
		end
	end

	local curAssistType = self.model:getAssistTypeOption()

	for i, v in ipairs(self.posAssistList) do
		if v.type == curAssistType and v.state == 1 then
			self.assistPosList:SelectItem(i - 1, false)
			self.model:setAssistTypeOption(v.type)
			self:setSelectAsstPosInfo(v)
			self:refreshBtnState()

			return
		end
	end

	for i, v in ipairs(self.posAssistList) do
		if v.type == curAssistType and v.state == 2 then
			self.assistPosList:SelectItem(i - 1, false)
			self.model:setAssistTypeOption(v.type)
			self:setSelectAsstPosInfo(v)
			self:m_selectListPropByAsstData(v.asstData)
			self:refreshBtnState()

			return
		end
	end

	self:refreshBtnState()
	self:m_syncAssistPosNavDefault()
	pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Restore)
end

function CarryComponent:m_selectListPropByAsstData(asstData)
	if not asstData then
		return
	end

	local data = self.listProps and self.listProps.itemData
	local count = data and data.Count or 0

	for i = 0, count - 1 do
		local v = data[i]

		if v and v.invId == asstData.invId and v.genID == asstData.genID then
			self.listProps:SelectItem(i)
			self.listProps:GoToIndex(i)

			return
		end
	end
end

function CarryComponent:resetCarryView(equip, unloadInfo)
	self.rootComponent:TryChangePage("Compare", 0)

	local sItem = self.listProps.selectedItem
	local shouldClearSelectedCore = not equip and self.curType == ItemConst.ITEM_TYPE_CARRY_CORE and unloadInfo and sItem and sItem.invId == unloadInfo.invId and sItem.genID == unloadInfo.genID

	self.carryPetInfo = self.model:getPetCarryInfo(self.petId)

	local selectCarryCore = self.model:getSelectCarryCore()

	if shouldClearSelectedCore then
		self.model:setSelectCarryCore(nil)

		selectCarryCore = nil
	elseif selectCarryCore then
		pg.global.ui.petTrainingNew.model:overrideCarryFullInfo(selectCarryCore)
	end

	self.model:overrideCarryList(self.listProps.itemData)

	local selectInfo = not shouldClearSelectedCore and sItem and {
		invId = sItem.invId,
		genID = sItem.genID
	} or nil

	if shouldClearSelectedCore then
		self:onOptionSelected(nil, true)
	else
		self:refreshSlotView(selectCarryCore)
		self:onPropSelectChanged(self.listProps)
		self:onOptionSelected(selectInfo)
	end

	if equip then
		self.isEquip = nil

		self:m_closeCompareView()
		self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	else
		if self.curCompareState ~= 0 and not self.isEquip then
			self:m_closeCompareView()
		end

		self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User3)
	end

	pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Restore)
end

function CarryComponent:onCoreCarryCertifySuccess()
	self.isResettingCoreCarryCertifyView = true

	self:resetCarryView(true)

	self.isResettingCoreCarryCertifyView = nil
end

function CarryComponent:playCoreCarryCertifySuccessAnimation()
	if not self:m_isViewValid() or self.coreCarryCertifyActivationState ~= PetManagementDataHelper.CoreCarryCertifyActivationState.Active then
		return
	end

	self:playCoreCarryCertifyActivationAnimation(CORE_CARRY_CERTIFY_ANI_ACTIVATE)
end

function CarryComponent:resetSelectCarryView()
	local sData = self.listProps.selectedItem

	self.model:overrideCarryFullInfo(sData)
	self.listProps:RefreshElement(self.listProps.selectedIndex)
	self:onPropSelectChanged(self.listProps)
end

function CarryComponent:onSelected()
	self:onOptionSelected()
end

function CarryComponent:onRenderPropItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local cLock = objectReference:GetRefValue("stateLockUWidget")
	local carryItem = objectReference:GetRefValue("carryItem")
	local carryObjectReference = carryItem:GetComponent("ObjectReference")
	local iconPet = carryObjectReference:GetRefValue("iconPet")
	local equip = carryObjectReference:GetRefValue("equip")
	local gem = carryObjectReference:GetRefValue("gem")
	local iconCarry = carryObjectReference:GetRefValue("iconCarry")
	local contactUWidget = LuaUIUtils.safeGetRefValue(carryObjectReference, "contactUWidget")
	local iconPetContactUImage = LuaUIUtils.safeGetRefValue(carryObjectReference, "iconPetContactUImage")

	LuaUIUtils.refreshCarryAssistInfo_Item(objectReference, data)

	local isCoreAssist = self.curType == ItemConst.ITEM_TYPE_CARRY_ASSISTED
	local isCertifiedCoreCarry = not isCoreAssist and PetManagementDataHelper.isCoreCarryCertified(data)

	if contactUWidget then
		contactUWidget:SetActive(isCertifiedCoreCarry)
	end

	if iconPetContactUImage then
		iconPetContactUImage.url = isCertifiedCoreCarry and LuaUIUtils.getPetIconByTemplateId(data.certifiedBaseFormPet, LuaUIUtils.PET_ICON) or ""
	end

	button.draggable = isCoreAssist and not self.ctrl:isInRogueDungeon()
	button.replicaSelf = not isCoreAssist
	button.dragStartPos = 1

	if isCoreAssist then
		button.dragReplica = self.dragTemplateUWidget

		function button.luaBeginDrag()
			local draggingWidget = CS.XGUI.UComponent.draggingWidget

			draggingWidget:TryChangePage("Type", data.assistType - 1)
			draggingWidget:TryChangePage("Quality", data.quality)

			local objectReference = draggingWidget:GetComponent("ObjectReference")
			local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

			imgAddUImage.url = data.icon

			self:renderAssistPosDragState(true, data)
		end

		function button.luaEndDrag()
			self:renderAssistPosDragState(false, data)
		end
	end

	carryItem:SetActive(true)

	if data.ownerCoreCarryPos and next(data.ownerCoreCarryPos) and data.ownerCoreCarryPos[1] ~= 0 and data.ownerCoreCarryPos[2] ~= 0 then
		equip:SetActive(false)
		gem:SetActive(true)

		local assistCarryCfg = pg.global.ui.petTrainingNew.model:parseCarryFullInfoWithId(data.ownerCoreCarryPos[1], data.ownerCoreCarryPos[2])

		if assistCarryCfg then
			local selectCarryCore = self.model:getSelectCarryCore()

			gem:TryChangePage("State", selectCarryCore and data.ownerCoreCarryPos[2] == selectCarryCore.genID and 1 or 0)
			gem:TryChangePage("Quality", assistCarryCfg.quality)

			iconCarry.url = assistCarryCfg.icon
		end
	elseif data.isEquipped then
		equip:SetActive(true)
		gem:SetActive(false)

		iconPet.url = data.petIcon
	else
		equip:SetActive(false)
		gem:SetActive(false)
	end

	cLock:SetActive(data.isLocked)

	local isRecommend = LuaUIUtils.checkCarryIsRecommend(self.petId, data.itemId)

	carryItem:TryChangePage("GoodState", isRecommend and 1 or 0)
end

function CarryComponent:onPropSelectChanged(uList)
	local sData = uList.selectedItem
	local selectCarryCore

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		local previousSelectCarryCore = self.model:getSelectCarryCore()
		local isSwitchFromUnequippedToEquipped = previousSelectCarryCore and not previousSelectCarryCore.isEquipped and sData and sData.isEquipped and (previousSelectCarryCore.invId ~= sData.invId or previousSelectCarryCore.genID ~= sData.genID)

		self.model:setSelectCarryCore(sData)

		selectCarryCore = self.model:getSelectCarryCore()

		self:refreshSlotView(selectCarryCore)

		if isSwitchFromUnequippedToEquipped then
			self:playCarryEquipAnimation()
		end
	end

	self.rootComponent:TryChangePage("Empty", 0)
	self:refreshSelectPropView(sData)
	self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)

	local checkCore = self.m_selectedCarryCore or {}
	local unlockState = checkCore and self.model:getJewelUnlockStateByCoreCarryIds(checkCore.invId, checkCore.genID) or 1

	self.rootComponent:TryChangePage("JewelUnlock", unlockState)
end

function CarryComponent:refreshSlotView(data)
	self.m_selectedCarryCore = {}

	if data == nil then
		return
	end

	self.m_selectedCarryCore = {
		invId = data.invId,
		genID = data.genID
	}
	self.imgSlot.url = data.bigIcon and data.bigIcon or data.icon

	if pg.game.petManage.lockCarryAssistant then
		return
	end

	self:refreshAssistItem(data)

	local hasEff = data.energyEffects and data.energyEffects[1] and true or false

	self.jewelBonus.gameObject:SetActiveEx(hasEff and self.curType == ItemConst.ITEM_TYPE_CARRY_ASSISTED)

	if hasEff then
		local selectCarryCore = self.model:getSelectCarryCore()

		if not self.curCoreId or self.curCoreId ~= selectCarryCore.genID then
			self.curCoreId = selectCarryCore.genID
			self.curCoreStage = nil
			self.maxCoreEnergy = 0
		end

		local coreStage = 0
		local coreEnergy = 0

		for i, energyCfg in ipairs(data.energyEffects) do
			if data.energySum >= energyCfg.energy then
				coreStage = i
			end
		end

		coreEnergy = data.energyEffects[coreStage < #data.energyEffects and coreStage + 1 or coreStage].energy

		ClientTextUtils.setText(self.txtCarryAssitEnergyStage, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_N_STAGE"))
		ClientTextUtils.setText(self.txtCarryAssitEnergyPro, string.format("%d/%d", math.min(data.energySum, coreEnergy), coreEnergy))
		ClientTextUtils.setText(self.txtCarryAssitEnergyDone, string.format(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_N_STAGE_ACHIEVE"), coreStage))

		local stageChange = self.curCoreStage and self.curCoreStage ~= coreStage

		if self.timerId then
			self:killTimer(self.timerId)

			self.timerId = nil
		end

		if stageChange and coreStage > self.curCoreStage then
			self.jewelBonus:TryChangePage("State", stageChange and 0 or 1)

			self.timerId = self:startTimer(function()
				self.jewelBonus:TryChangePage("State", 1)
			end, 1.2)
		else
			self.jewelBonus:TryChangePage("State", 1)
		end

		self.curCoreStage = coreStage
		self.maxCoreEnergy = coreEnergy
	end
end

function CarryComponent:onRenderAssistPosItem(assist, index, data)
	assist:TryChangePage("State", data.state)
	assist:TryChangePage("Quality", data.quality)

	assist.navForceNonInteractable = data.state == 0

	local objRefAsst = assist:GetComponent("ObjectReference")
	local lockText = objRefAsst:GetRefValue("lockText")
	local jewelUImage = objRefAsst:GetRefValue("jewelUImage")
	local txtTipsUBaseText = objRefAsst:GetRefValue("txtTipsUBaseText")

	if lockText and data.slotUnlockLv then
		ClientTextUtils.setText(lockText, string.format("+%d", data.slotUnlockLv))
	end

	if data.asstData then
		jewelUImage.url = data.asstData.icon
	end

	function assist.luaHover()
		if self.dragItem then
			local canSet = data.type == self.dragItem.assistType and data.state ~= 0

			assist:TryChangePage("button", canSet and 0 or 4)

			self.dragAssistPos = data

			assist:TryChangePage("GamePadFocus", 1)
			assist:TryChangePage("Match", canSet and 0 or 1)
			assist:TryChangePage("DragState", canSet and 4 or 0)

			local showTex

			if data.type ~= self.dragItem.assistType then
				showTex = "PET_EQUIPMENT_EQUIP_GEM_SLOT_MISMATCH"
			elseif data.state == 0 then
				showTex = "PET_EQUIPMENT_EQUIP_GEM_SLOT_UNLOCK"
			end

			if showTex then
				ClientTextUtils.setText(txtTipsUBaseText, pg.getGameString(showTex))
			end
		end
	end

	function assist.luaUnhover()
		if self.dragItem then
			assist:TryChangePage("Match", 0)

			local canSet = data.type == self.dragItem.assistType and data.state ~= 0

			assist:TryChangePage("button", canSet and 0 or 4)

			self.dragAssistPos = nil

			assist:TryChangePage("GamePadFocus", 0)
			assist:TryChangePage("DragState", 0)
		end
	end

	self.assistPosItems[data.posIndex] = assist

	self:m_refreshAssistSlotRedDot(assist, data)
end

function CarryComponent:m_refreshAssistSlotRedDot(assist, slotData)
	local selectedCore = self.m_selectedCarryCore or {}
	local curPetEquipedCore = self.model:getPetCarryInfo(self.petId) or {}
	local coreGenId = 0

	if selectedCore and curPetEquipedCore and next(curPetEquipedCore) and selectedCore.genID == curPetEquipedCore.genID and selectedCore.invId == curPetEquipedCore.invId then
		coreGenId = self.carryPetInfo and self.carryPetInfo.isEquipped and self.carryPetInfo.genID or 0
	end

	local isShow = coreGenId ~= 0 and slotData.state == 1 and self.model:checkExistUnequippedAssistByType(slotData.type) and self.carryPetInfo and self.model:getJewelUnlockStateByCoreCarryIds(self.carryPetInfo.invId, self.carryPetInfo.genID) == 0

	self.model:redDot_SetAssistSlotRedDot(self.petId, coreGenId, slotData.posIndex, assist, isShow)
end

function CarryComponent:refreshAssistRedDot()
	if not self.posAssistList then
		return
	end

	for i, slotData in ipairs(self.posAssistList) do
		local assist = self.assistPosItems and self.assistPosItems[i]

		if assist then
			self:m_refreshAssistSlotRedDot(assist, slotData)
		end
	end
end

function CarryComponent:m_refreshStrengthRedDot(sData, isRogue)
	local isShow = false

	if sData and sData.isEquipped and not sData.isMaxLv and not isRogue then
		isShow = self.model:checkExistStrengthMaterial(sData.genID, sData.familyId)
	end

	local coreGenId = sData and sData.genID or 0

	self.model:redDot_SetStrengthRedDot(self.petId, coreGenId, self.btnStrengthen, isShow)
end

function CarryComponent:refreshStrengthRedDot()
	if self.curType ~= ItemConst.ITEM_TYPE_CARRY_CORE then
		return
	end

	local sData = self.listProps and self.listProps.selectedItem

	if not sData then
		return
	end

	self:m_refreshStrengthRedDot(sData, self.ctrl and self.ctrl:isInRogueDungeon())
end

function CarryComponent:renderAssistPosDragState(isDragStart, data)
	for i, assistPosItem in ipairs(self.assistPosItems) do
		if isDragStart then
			local assistPosInfo = self.posAssistList[i]
			local canSet = assistPosInfo and assistPosInfo.type == data.assistType and assistPosInfo.state ~= 0

			assistPosItem:TryChangePage("button", canSet and 0 or 4)
			assistPosItem:TryChangePage("DragState", 0)
		else
			assistPosItem:TryChangePage("Match", 0)
			assistPosItem:TryChangePage("button", 0)
			assistPosItem:TryChangePage("GamePadFocus", 0)
			assistPosItem:TryChangePage("DragState", 0)
		end
	end

	if isDragStart then
		self.dragItem = data

		self:setSelectAsstPosInfo(nil)
		self:refreshBtnState()
	else
		if self.dragAssistPos then
			local canSet = self.dragAssistPos.type == data.assistType and self.dragAssistPos.state ~= 0

			if canSet then
				self:setSelectAsstPosInfo(self.posAssistList[self.dragAssistPos.posIndex])
				self:onAssistEquip()
			elseif self.dragAssistPos.type ~= data.assistType then
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_EQUIP_GEM_SLOT_MISMATCH"))
			elseif self.dragAssistPos.state == 0 then
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_EQUIP_GEM_SLOT_UNLOCK"))
			end

			self.dragAssistPos = nil
		end

		self.dragItem = nil
	end
end

function CarryComponent:onAssistPosSelectChanged(uList)
	local sData = uList.selectedItem

	if not sData then
		self:setSelectAsstPosInfo(nil)

		return
	end

	if not self.model:isAssistOpen() then
		pg.global.showBubbleMessageById(PetConfigData.gemsNotActivationFeedback)
		self.assistPosList:DeselectAll()

		return
	end

	if sData.state == 0 then
		if self.selectAsstPosInfo then
			self.assistPosList:SelectItem(self.selectAsstPosInfo.posIndex - 1, false)
		else
			self.assistPosList:DeselectAll()
		end

		pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_EQUIP_GEM_SLOT_UNLOCK"))

		return
	end

	self.model:setAssistTypeOption(sData.type)
	self:setSelectAsstPosInfo(sData)
	self:choseCarryAssist()
	self:refreshSelectPropView(self.listProps.selectedItem)
	self.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function CarryComponent:m_syncAssistPosNavDefault()
	if not self.selectAsstPosInfo then
		return
	end

	local btn = self.assistPosItems and self.assistPosItems[self.selectAsstPosInfo.posIndex]

	if btn then
		self.assistPosList:SetNavGroupDefaultItem(btn)
	end
end

function CarryComponent:setSelectAsstPosInfo(info)
	self.selectAsstPosInfo = info

	self.model:setAssistPosInfo(info)
	self:m_syncAssistPosNavDefault()
end

function CarryComponent:isAssistTabSelected()
	return self.curType == ItemConst.ITEM_TYPE_CARRY_ASSISTED
end

function CarryComponent:isCompareOpen()
	return self.curCompareState and self.curCompareState ~= 0
end

function CarryComponent:refreshAssistItem(data)
	local hasAsst = data.assistCarryPosList and next(data.assistCarryPosList)

	if not hasAsst then
		return
	end

	self.posAssistList = {}

	for i, postData in ipairs(data.assistCarryPosList) do
		local state, asstData

		if postData[1] and postData[2] and postData[1] ~= 0 and postData[2] ~= 0 then
			asstData = pg.global.ui.petTrainingNew.model:parseCarryFullInfoWithId(postData[1], postData[2])
			state = 2
		else
			state = data.assistUnlock[i] and data.assistUnlock[i] == 0 and 0 or 1
		end

		self.posAssistList[i] = {
			tIndex = data.assistCarryTypeList[i] - 1,
			type = data.assistCarryTypeList[i],
			state = state,
			slotUnlockLv = data.slotUnlockLv and data.slotUnlockLv[i] or 0,
			asstData = asstData,
			posIndex = i
		}
	end

	self.assistPosList.itemData = self.posAssistList

	self.assistPosList:RefreshList()

	if self.selectAsstPosInfo then
		self.assistPosList:SelectItem(self.selectAsstPosInfo.posIndex - 1)
	end
end

function CarryComponent:refreshSelectPropView(data)
	if data == nil then
		self:refreshCoreCarryCertifyButton(nil)

		if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
			self.rootComponent:TryChangePage("CarryContact", PetManagementDataHelper.CoreCarryContactState.Unlocked)
			self:tryChangeCoreCarryCertifyActivationState(PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive)
		end

		return
	end

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		self:refreshCoreCarryCertifyButton(data)
		self.carryFigure:TryChangePage("Quality", data.quality)

		local contactState = PetManagementDataHelper.getCoreCarryCertifyDisplayState(data)

		self.rootComponent:TryChangePage("CarryContact", contactState)
		self:refreshCoreCarryCertifyActivationState(data)
		self:refreshPropInfo(self.infoUComponent, data)
	else
		self:refreshCoreCarryCertifyButton(nil)
		self:refreshAssistPropInfo(self.infoAssistUComponent, data)
	end

	self:refreshBtnState()
end

function CarryComponent:refreshCoreCarryCertifyActivationState(data)
	local ownerPetId = data and data.ownerPetId
	local equipPetInfo = ownerPetId and ownerPetId ~= "" and pg.me.pets and pg.me.pets[ownerPetId] or nil
	local activationState = PetManagementDataHelper.getCoreCarryCertifyActivationState(data, equipPetInfo)

	self:tryChangeCoreCarryCertifyActivationState(activationState)
end

function CarryComponent:tryChangeCoreCarryCertifyActivationState(activationState)
	local lastActivationState = self.coreCarryCertifyActivationState

	self:refreshCoreCarryCertifyActivationVisualState(activationState)

	self.coreCarryCertifyActivationState = activationState

	if self.isResettingCoreCarryCertifyView then
		return
	end

	if lastActivationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Active and activationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive then
		self:cancelCoreCarryCertifyActivationAnimation()
		self:refreshCoreCarryCertifyActivationVisualState(activationState)
	elseif lastActivationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive and activationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Active then
		self:playCoreCarryCertifyActivationAnimation(CORE_CARRY_CERTIFY_ANI_CHANGE)
	end
end

function CarryComponent:refreshCoreCarryCertifyActivationVisualState(activationState)
	local isInactive = activationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Inactive
	local opacity = isInactive and 0.6 or 1

	self.rootComponent:TryChangePage("UnContact", activationState)

	self.contactPetIconUImage.grayed = isInactive
	self.btnContactUButton.transform.localScale = Vector3(1, 1, 1)
	self.btnContactUButton.renderOpacity = opacity

	if self.contactBgUWidget then
		self.contactBgUWidget.renderOpacity = opacity
	end
end

function CarryComponent:playCoreCarryCertifyActivationAnimation(aniName)
	self.coreCarryCertifyAnimationToken = (self.coreCarryCertifyAnimationToken or 0) + 1

	local animationToken = self.coreCarryCertifyAnimationToken

	self:playCertifyAnimation(aniName, function()
		if self:m_isViewValid() and self.coreCarryCertifyAnimationToken == animationToken then
			self:refreshCoreCarryCertifyActivationVisualState(self.coreCarryCertifyActivationState)
		end
	end)
end

function CarryComponent:cancelCoreCarryCertifyActivationAnimation()
	self.coreCarryCertifyAnimationToken = (self.coreCarryCertifyAnimationToken or 0) + 1

	if not IsNil(self.certifyContactTUAnimation) then
		self.certifyContactTUAnimation:Stop()
	end
end

function CarryComponent:refreshCoreCarryCertifyButton(data)
	local isCoreCarry = self.curType == ItemConst.ITEM_TYPE_CARRY_CORE and data ~= nil

	self.btnContactUButton:SetActive(isCoreCarry)

	self.btnContactUButton.enabledTooltip = false
	self.btnContactUButton.luaRenderTooltip = nil
	self.btnContactUButton.luaClick = nil
	self.contactPetIconUImage.url = ""

	if not isCoreCarry then
		return
	end

	if not PetManagementDataHelper.isCoreCarryCertified(data) then
		return
	end

	self.contactPetIconUImage.url = LuaUIUtils.getPetIconByTemplateId(data.certifiedBaseFormPet, LuaUIUtils.PET_ICON)
	self.btnContactUButton.enabledTooltip = true
	self.btnContactUButton.tooltipTemplateUrl = AddressDataConst.UI_TOOLTIP_PET_SKILL_CONTACT

	function self.btnContactUButton.luaRenderTooltip(_, tooltip)
		self:refreshCoreCarryCertifyTooltip(tooltip, data)
	end
end

function CarryComponent:checkSelectedCoreCarryCertify(selectedCoreCarry, skipCostCheck)
	local petCarryInfo = self.model:getPetCarryInfo(self.petId)
	local isSelectedCoreEquipped = selectedCoreCarry and petCarryInfo and petCarryInfo.isEquipped and selectedCoreCarry.invId == petCarryInfo.invId and selectedCoreCarry.genID == petCarryInfo.genID

	if not isSelectedCoreEquipped then
		return false, NoticeDef.PET_EQUIPMENT_BIND_NO_CORE_CARRY
	end

	return pg.game.petManage:checkCoreCarryCertify(self.petId, nil, skipCostCheck)
end

function CarryComponent:openCoreCarryCertifyDialog(selectedCoreCarry)
	local success, noticeId = self:checkSelectedCoreCarryCertify(selectedCoreCarry, true)

	if not success then
		pg.global.showBubbleMessageById(noticeId)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_CARRYCONTACT, {
		petId = self.petId
	})
end

function CarryComponent:refreshCoreCarryCertifyInfo(objectReference, coreCarryInfo, rootWidget)
	if not objectReference or not PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtContactUSDFText = objectReference:GetRefValue("txtContactUSDFText")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	local petSkill1UWidget = objectReference:GetRefValue("petSkill1UWidget")
	local petSkill2UWidget = objectReference:GetRefValue("petSkill2UWidget")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	local ownerPetId = coreCarryInfo.ownerPetId
	local equipPetInfo = ownerPetId and ownerPetId ~= "" and pg.me.pets and pg.me.pets[ownerPetId] or nil
	local activationState = PetManagementDataHelper.getCoreCarryCertifyActivationState(coreCarryInfo, equipPetInfo)
	local isActive = activationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Active
	local certifiedPetInfo = PetManagementDataHelper.getCoreCarryCertifiedPetInfo(coreCarryInfo, equipPetInfo)
	local certifiedPetName = LuaUIUtils.getPetNameWithIdOrTmpId(coreCarryInfo.certifiedBaseFormPet)
	local beforeSkillInfo, afterSkillInfo = PetManagementDataHelper.getCoreCarryCertifySkillPair(coreCarryInfo)
	local beforeSkillRenderInfo = beforeSkillInfo and Utils.deepCopyTable(beforeSkillInfo) or nil
	local afterSkillRenderInfo = afterSkillInfo and Utils.deepCopyTable(afterSkillInfo) or nil

	if beforeSkillRenderInfo then
		beforeSkillRenderInfo.hasGlazePath = true
		beforeSkillRenderInfo.alreadyGlazed = false
	end

	if afterSkillRenderInfo then
		afterSkillRenderInfo.hasGlazePath = true
		afterSkillRenderInfo.alreadyGlazed = true
	end

	local certifiedPetSkillName = beforeSkillInfo and pg.getLocalizationText(beforeSkillInfo.name) or ""

	if iconUImage then
		iconUImage.url = LuaUIUtils.getPetIconByTemplateId(coreCarryInfo.certifiedBaseFormPet, LuaUIUtils.PET_ICON)
		iconUImage.grayed = not isActive
	end

	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString(CORE_CARRY_CERTIFY_TIP_TITLE))
	ClientTextUtils.setText(txtContactUSDFText, pg.getGameString(isActive and CORE_CARRY_CERTIFY_TIP_ACTIVE or CORE_CARRY_CERTIFY_TIP_INACTIVE))
	ClientTextUtils.setText(txtDetailsUSDFText, string.format(pg.getGameString(CORE_CARRY_CERTIFY_TIP_DESC), certifiedPetName, certifiedPetSkillName))

	local petSkill1UButton = petSkill1UWidget and petSkill1UWidget:GetComponent("UButton") or nil
	local petSkill2UButton = petSkill2UWidget and petSkill2UWidget:GetComponent("UButton") or nil

	if petSkill1UButton then
		PetManagementUtils._renderSkillCmp(petSkill1UButton, beforeSkillRenderInfo, false, nil, certifiedPetInfo)

		if beforeSkillRenderInfo then
			petSkill1UButton:TryChangePage("IsRare", LuaUIUtils.getSkillGlazeType(beforeSkillRenderInfo))
		end
	end

	if petSkill2UButton then
		PetManagementUtils._renderSkillCmp(petSkill2UButton, afterSkillRenderInfo, false, nil, certifiedPetInfo)

		if afterSkillRenderInfo then
			petSkill2UButton:TryChangePage("IsRare", LuaUIUtils.getSkillGlazeType(afterSkillRenderInfo))
		end
	end

	if rootWidget then
		rootWidget:TryChangePage("Active", 1)
	end

	if btnInfoUButton then
		function btnInfoUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_HELP, {
				helpId = PetManagementDataHelper.PetCoreCarryContactHelpId
			})
		end
	end

	return isActive
end

function CarryComponent:refreshCoreCarryCertifyTooltip(tooltip, coreCarryInfo)
	if not tooltip or not PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return
	end

	self:refreshCoreCarryCertifyInfo(tooltip:GetComponent("ObjectReference"), coreCarryInfo)

	local bgTs = tooltip.transform:Find("Tips/Bg")
	local bgUImage = bgTs and bgTs:GetComponent("UImage")

	if NotNil(bgUImage) then
		bgUImage.url = ""
	end
end

function CarryComponent:refreshPropInfo(uWidget, data)
	local objectReference = uWidget:GetComponent("ObjectReference")
	local scrollInfo = objectReference:GetRefValue("scrollInfo")
	local equipPetIcon = objectReference:GetRefValue("equipPetIcon")
	local txtPetName = objectReference:GetRefValue("txtPetName")
	local txtTitleTs = uWidget.transform:Find("Panel/Equiped/LayoutBox/TxtTitle")
	local txtTitleUBaseText = txtTitleTs and txtTitleTs:GetComponent("USDFText")
	local isEquipped = data.isEquipped or false
	local isCompare = data.isCompare or false

	equipPetIcon.url = data.petIcon or ""

	ClientTextUtils.setText(txtTitleUBaseText, "")
	self:setEquipTipText(txtPetName, isEquipped, isCompare, data.petName)
	uWidget:TryChangePage("Equiped", isEquipped and 1 or 0)
	uWidget:TryChangePage("EquipedSel", isEquipped and isCompare and 1 or 0)

	local isRecommend = LuaUIUtils.checkCarryIsRecommend(self.petId, data.itemId)

	uWidget:TryChangePage("GoodState", isRecommend and 1 or 0)
	uWidget:TryChangePage("Quality", data.quality)

	objectReference = scrollInfo.content:GetComponent("ObjectReference")

	local txtPropName = objectReference:GetRefValue("txtPropName")
	local txtEnhanceNum = objectReference:GetRefValue("txtEnhanceNum")
	local txtCoreAttrDesc = objectReference:GetRefValue("txtCoreAttrDesc")
	local mainAttrList = objectReference:GetRefValue("mainAttrList")
	local btnLock = objectReference:GetRefValue("btnLock")
	local coreBonusUWidget = objectReference:GetRefValue("coreBonusUWidget")
	local advancedList = objectReference:GetRefValue("advancedList")
	local assistList = objectReference:GetRefValue("assistList")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local txtEnergy = objectReference:GetRefValue("txtEnergy")
	local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	local txtAdvanceUBaseText = objectReference:GetRefValue("txtAdvanceUBaseText")

	ClientTextUtils.setText(txtTitleUBaseText, pg.getGameString("PET_EQUIPMENT_CORE_BUFF"))
	ClientTextUtils.setText(txtAdvanceUBaseText, pg.getGameString("PET_EQUIPMENT_EXTRA_BUFF"))

	function mainAttrList.luaRenderItem(sBtn, _, sData)
		local oc = sBtn:GetComponent("ObjectReference")
		local attributeName = oc:GetRefValue("attributeName")
		local attributeValue = oc:GetRefValue("attributeValue")
		local iconTypeUImage = oc:GetRefValue("iconTypeUImage")

		ClientTextUtils.setText(attributeName, sData.name)
		ClientTextUtils.setText(attributeValue, sData.tDesc)

		iconTypeUImage.url = sData.icon
	end

	mainAttrList:SetList(data.mainProperties)

	local nameStr = data.name or ""

	if pg.game.setting:getShowDebugId() then
		nameStr = string.format("%s: (%s-%s-itemId:%s)", nameStr, data.invId, data.genID, data.itemId)
	end

	ClientTextUtils.setText(txtPropName, nameStr)

	local dataDescStr = data.itemDes or ""

	ClientTextUtils.setText(txtDesc, dataDescStr)
	ClientTextUtils.setText(txtEnergy, data.energySum)

	if data.cLevel > 0 then
		txtEnhanceNum:SetActive(true)
		ClientTextUtils.setText(txtEnhanceNum, string.format("+%d", data.cLevel))
	else
		txtEnhanceNum:SetActive(false)
	end

	coreBonusUWidget:SetActive(true)
	ClientTextUtils.setText(txtCoreAttrDesc, data.buffDesc)

	if data.isCompare then
		btnLock:SetActive(false)
	else
		btnLock:SetActive(true)
		btnLock:TryChangePage("Lock", data.isLocked and 1 or 0)
	end

	function btnLock.luaClick()
		local isLockNewState = not data.isLocked

		pg.me:serverMsg("RPC_CS_ModifyItemStatus", data.invId, {
			data.genID
		}, ItemConst.ITEM_STATUS_LOCKED, isLockNewState, function(retCode)
			if retCode == false then
				return
			end

			self:resetSelectCarryView()
			self:refreshCarryLockStatus(btnLock, data, isLockNewState)
		end)
	end

	self:refreshPropInfoJewelUWidget(uWidget, data)
	LuaUIUtils.refreshCarryAssistInfo(assistList, nil, data)
	self:refreshCoreCarryAdvancedList(advancedList, data)
end

function CarryComponent:refreshCoreCarryAdvancedList(advancedList, coreCarryInfo)
	if not advancedList then
		return
	end

	local certifyCoreCarryInfo = coreCarryInfo
	local sourceItem = coreCarryInfo and coreCarryInfo.sourceItem
	local sourceCoreCarryInfo = sourceItem and ItemUtils.getPropertyWithType(sourceItem) or nil

	if sourceCoreCarryInfo and sourceCoreCarryInfo:isValid() and not PetManagementDataHelper.isCoreCarryCertified(certifyCoreCarryInfo) then
		certifyCoreCarryInfo = sourceCoreCarryInfo
	end

	local contactState = PetManagementDataHelper.getCoreCarryCertifyDisplayState(certifyCoreCarryInfo)
	local isCertifyUnlocked = contactState ~= PetManagementDataHelper.CoreCarryContactState.Unlocked
	local isCertified = PetManagementDataHelper.isCoreCarryCertified(certifyCoreCarryInfo)
	local advancedDataList = {}

	for _, energyEffect in ipairs(coreCarryInfo.energyEffects or {}) do
		advancedDataList[#advancedDataList + 1] = {
			tIndex = 0,
			energyEffect = energyEffect
		}
	end

	if isCertifyUnlocked then
		advancedDataList[#advancedDataList + 1] = {
			tIndex = 1
		}
	end

	local hasAdvancedData = #advancedDataList > 0

	advancedList:SetActive(hasAdvancedData)

	function advancedList.luaRenderItem(advancedItem, advancedIndex, advancedData)
		if advancedData.tIndex == 1 then
			local objectReference = advancedItem:GetComponent("ObjectReference")
			local isActive = self:refreshCoreCarryCertifyInfo(objectReference, certifyCoreCarryInfo, advancedItem)

			advancedItem:TryChangePage("Active", isCertified and 1 or 0)

			local isCertifyAvailable = contactState == PetManagementDataHelper.CoreCarryContactState.Contacted
			local isCertifyNotContact = contactState == PetManagementDataHelper.CoreCarryContactState.NotContact

			advancedItem:TryChangePage("NotContact", isActive and isCertifyAvailable and 0 or 1)

			local txtNotActiveUSDFText = objectReference:GetRefValue("txtNotActiveUSDFText")

			if isCertifyNotContact and txtNotActiveUSDFText then
				ClientTextUtils.setText(txtNotActiveUSDFText, pg.getGameString("CARRY_CERT_TIPS_UNENHANCE"))
			end

			local notActiveTxtDetailsUSDFText = objectReference:GetRefValue("NotActiveTxtDetailsUSDFText")

			if notActiveTxtDetailsUSDFText then
				notActiveTxtDetailsUSDFText.gameObject:SetActiveEx(isCertifyAvailable)

				if isCertifyNotContact then
					ClientTextUtils.setText(notActiveTxtDetailsUSDFText, pg.getGameString(CORE_CARRY_CERTIFY_SKILL_TIP))
				end
			end

			return
		end

		local objectReference = advancedItem:GetComponent("ObjectReference")
		local txtGrade = objectReference:GetRefValue("txtGrade")
		local txtDetails = objectReference:GetRefValue("txtDetails")
		local energyEffect = advancedData.energyEffect
		local allEnergy = coreCarryInfo.cLevel or 0
		local showIndex = advancedIndex + 1
		local showEnergy = allEnergy >= energyEffect.enhanceLv and energyEffect.enhanceLv or allEnergy
		local text = string.format(pg.getGameString("PET_EQUIPMENT_STAGE"), showIndex, showEnergy, energyEffect.enhanceLv)

		ClientTextUtils.setText(txtGrade, text)
		ClientTextUtils.setText(txtDetails, energyEffect.effDesc)
		advancedItem:TryChangePage("Active", allEnergy >= energyEffect.enhanceLv and 1 or 0)
	end

	advancedList:SetList(advancedDataList)
end

function CarryComponent:refreshCarryLockStatus(btnLock, data, isLocked)
	if not data then
		return
	end

	data.isLocked = isLocked

	if btnLock and NotNil(btnLock) then
		btnLock:TryChangePage("Lock", isLocked and 1 or 0)
	end

	local sData = self.listProps and self.listProps.selectedItem

	if sData and sData.invId == data.invId and sData.genID == data.genID then
		sData.isLocked = isLocked

		if self.listProps.selectedIndex then
			self.listProps:RefreshElement(self.listProps.selectedIndex)
		end
	end
end

function CarryComponent:refreshPropInfoJewelUWidget(uWidget, data)
	local objectReference = uWidget:GetComponent("ObjectReference")
	local scrollInfo = objectReference:GetRefValue("scrollInfo")

	objectReference = scrollInfo.content:GetComponent("ObjectReference")

	local advancedUWidget = objectReference:GetRefValue("advancedUWidget")
	local jewelUWidget = objectReference:GetRefValue("jewelUWidget")
	local isCompareState = self.curCompareState ~= 0
	local advancedLockedUWidget = objectReference:GetRefValue("advancedLockedUWidget")
	local txtLockedUSDFText = objectReference:GetRefValue("txtLockedUSDFText")

	ItemPropUIUtils.refreshCarryAdvancedModule(advancedUWidget, jewelUWidget, advancedLockedUWidget, txtLockedUSDFText, data, isCompareState)
end

function CarryComponent:refreshAssistPropInfo(uWidget, data, isCompare)
	local objectReference = uWidget:GetComponent("ObjectReference")
	local scrollInfo = objectReference:GetRefValue("scrollInfo")
	local imgEquipPetIcon = objectReference:GetRefValue("imgEquipPetIcon")
	local txtEquipPetName = objectReference:GetRefValue("txtEquipPetName")
	local txtTitleTs = uWidget.transform:Find("Panel/Equiped/LayoutBox/TxtTitle")
	local txtTitleUBaseText = txtTitleTs and txtTitleTs:GetComponent("USDFText")
	local scrollObjectReference = scrollInfo.content:GetComponent("ObjectReference")
	local txtName = scrollObjectReference:GetRefValue("txtName")
	local txtAsstScore = scrollObjectReference:GetRefValue("txtAsstScore")
	local imgEnergyIcon = scrollObjectReference:GetRefValue("imgEnergyIcon")
	local txtEnergy = scrollObjectReference:GetRefValue("txtEnergy")
	local imgAsstIcon = scrollObjectReference:GetRefValue("imgAsstIcon")
	local listAsstAttrs = scrollObjectReference:GetRefValue("listAsstAttrs")
	local listAsstRandomAttrs = scrollObjectReference:GetRefValue("listAsstRandomAttrs")
	local txtAsstDesc = scrollObjectReference:GetRefValue("txtAsstDesc")
	local txtRadomUBaseText = scrollObjectReference:GetRefValue("txtRadomUBaseText")

	ClientTextUtils.setText(txtRadomUBaseText, pg.getGameString("PET_EQUIPMENT_GEM_EXTRA_PROP"))

	local isEquipped = data.isEquipped or false

	imgEquipPetIcon.url = data.coreIcon or ""

	ClientTextUtils.setText(txtTitleUBaseText, "")
	self:setEquipTipText(txtEquipPetName, isEquipped, isCompare, data.coreName)
	uWidget:TryChangePage("Equiped", isEquipped and 1 or 0)
	uWidget:TryChangePage("EquipedSel", isCompare and 1 or 0)

	local isRecommend = LuaUIUtils.checkCarryIsRecommend(self.petId, data.itemId)

	uWidget:TryChangePage("GoodState", isRecommend and 1 or 0)
	uWidget:TryChangePage("Quality", data.quality)
	uWidget:TryChangePage("Type", data.assistType - 1)
	LuaUIUtils.refreshCarryAssistAttrList(listAsstAttrs, data.mainProperties)
	LuaUIUtils.refreshCarryAssistAttrList(listAsstRandomAttrs, data.randomProperties)
	ClientTextUtils.setText(txtName, data.name)

	local inventoryName = ""
	local assistPosDebugStr = ""

	if pg.game.setting:getShowDebugId() and isShowDebugInfo then
		inventoryName = "invId(" .. data.invId .. ")genID(" .. data.genID .. ")assistType(" .. data.assistType .. ")"
		assistPosDebugStr = string.format("当前符文[%s]槽位数据: \n", inventoryName)
	end

	ClientTextUtils.setText(txtAsstDesc, assistPosDebugStr .. data.itemDes)
	ClientTextUtils.setText(txtEnergy, data.energy)
	ClientTextUtils.setText(txtAsstScore, string.format("CP %d", data.cpValue))

	imgAsstIcon.url = data.icon
end

function CarryComponent:refreshBtnState()
	local sData = self.listProps.selectedItem
	local isRogue = self.ctrl:isInRogueDungeon()

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		local cpInfo = self.carryPetInfo

		self.btnCompare:SetActive(cpInfo.genID ~= 0 and sData and cpInfo.genID ~= sData.genID)

		local oc = self.btnEquip:GetComponent("ObjectReference")
		local name = oc:GetRefValue("txtNameUText")

		if cpInfo.genID == sData.genID then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_UNLOAD"))
		elseif cpInfo.isEquipped and cpInfo.genID ~= sData.genID then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_REPLACE"))
		else
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_EQUIPPED"))
		end

		self.btnEquip:TryChangePage("button", isRogue and 4 or 0)

		self.btnEquip.interactable = not isRogue
		oc = self.btnStrengthen:GetComponent("ObjectReference")
		name = oc:GetRefValue("txtNameUText")

		local contactState = PetManagementDataHelper.getCoreCarryCertifyDisplayState(sData)
		local isCertified = PetManagementDataHelper.isCoreCarryCertified(sData)
		local isCertifiedMaxLv = isCertified and sData.isMaxLv

		self.btnStrengthen:SetActive(not isCertifiedMaxLv)

		if isCertifiedMaxLv then
			ClientTextUtils.setText(name, pg.getGameString(CORE_CARRY_CERTIFIED))
			self.btnStrengthen:TryChangePage("button", 4)

			self.btnStrengthen.interactable = false
			self.btnStrengthen.visualInteractable = false
		elseif sData.isMaxLv and contactState == PetManagementDataHelper.CoreCarryContactState.NotContact then
			ClientTextUtils.setText(name, pg.getGameString(CORE_CARRY_CERTIFY_BUTTON))

			local isCertifyAvailable = self:checkSelectedCoreCarryCertify(sData, true)

			self.btnStrengthen.visualInteractable = isCertifyAvailable

			self.btnStrengthen:TryChangePage("button", isCertifyAvailable and 0 or 4)

			self.btnStrengthen.interactable = true

			if not isCertifyAvailable then
				TimerManager.addNextFrameCb(function()
					local selectedCoreCarry = self.listProps and self.listProps.selectedItem

					if not NotNil(self.btnStrengthen) or not selectedCoreCarry or selectedCoreCarry.invId ~= sData.invId or selectedCoreCarry.genID ~= sData.genID then
						return
					end

					self.btnStrengthen.interactable = true

					local rayBox = self.btnStrengthen.transform:Find("RayBox")

					if NotNil(rayBox) then
						rayBox.gameObject:SetActiveEx(true)
					end
				end)
			end
		elseif sData.isMaxLv then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_MAXED_LEVEL"))
			self.btnStrengthen:TryChangePage("button", 4)

			self.btnStrengthen.interactable = false
			self.btnStrengthen.visualInteractable = false
		elseif isRogue then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_STRENGTH"))
			self.btnStrengthen:TryChangePage("button", 4)

			self.btnStrengthen.interactable = false
			self.btnStrengthen.visualInteractable = false
		else
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_STRENGTH"))
			self.btnStrengthen:TryChangePage("button", 0)

			self.btnStrengthen.interactable = true
			self.btnStrengthen.visualInteractable = true
		end

		self:m_refreshStrengthRedDot(sData, isRogue)
	else
		local cpInfo = self.selectAsstPosInfo and self.selectAsstPosInfo.asstData
		local oc = self.btnAssistEquip:GetComponent("ObjectReference")
		local name = oc:GetRefValue("txtNameUText")

		if cpInfo and next(cpInfo) and cpInfo.genID == sData.genID then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_UNLOAD"))
		elseif cpInfo and next(cpInfo) and cpInfo[1] ~= 0 and cpInfo[2] ~= 0 then
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_REPLACE"))
		else
			ClientTextUtils.setText(name, pg.getGameString("PET_EQUIPMENT_EQUIPPED"))
		end

		self.btnAssistCompare:SetActive(cpInfo and next(cpInfo) and cpInfo.genID ~= sData.genID)
		self.btnAssistEquip:TryChangePage("button", self.selectAsstPosInfo and not isRogue and 0 or 4)

		self.btnAssistEquip.interactable = not isRogue
	end
end

function CarryComponent:refreshAssistTabState()
	for i = 1, 3 do
		self["assistTab" .. i]:SetSelected(i == self.model:getAssistTypeOption())
		self.view.jewelTabUWidget.simulateButtonSwitch:SetCursor(self.model:getAssistTypeOption() - 1, -1)
	end

	pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Restore)
end

function CarryComponent:onBtnCompare()
	local newIndex = 0
	local _, page = self.rootComponent:TryGetCurrentPage("JewelCompare")

	if page == newIndex then
		newIndex = self.curType == ItemConst.ITEM_TYPE_CARRY_CORE and 1 or 2
	end

	self.curCompareState = newIndex

	self.rootComponent:TryChangePage("JewelCompare", self.curCompareState)
	self.ctrl:setTabLeftActive(newIndex == 0)

	if newIndex == 0 then
		if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
			local coreData = self.model:getSelectCarryCore()

			self:refreshPropInfoJewelUWidget(self.infoUComponent, coreData)
		end

		return
	end

	if self.curType == ItemConst.ITEM_TYPE_CARRY_CORE then
		local carry = self.carryPetInfo
		local ownInfo = self.model:parseCarryFullInfoWithId(carry.invId, carry.genID)

		if not ownInfo then
			self.curCompareState = 0

			self.rootComponent:TryChangePage("JewelCompare", self.curCompareState)

			return
		end

		ownInfo.isCompare = true

		self:refreshPropInfo(self.cpInfoUComponent, ownInfo)

		local coreData = self.model:getSelectCarryCore()

		self:refreshPropInfoJewelUWidget(self.infoUComponent, coreData)
	else
		self:refreshAssistPropInfo(self.cpInfoAssistUComponent, self.selectAsstPosInfo.asstData, true)
	end
end

function CarryComponent:onBtnEquip()
	local sData = self.listProps.selectedItem
	local cpInfo = self.carryPetInfo

	if cpInfo.genID == sData.genID then
		pg.me:serverMsg("RPC_CS_UnequipCoreCarry", self.petId)
	elseif sData.isEquipped and cpInfo.genID ~= sData.genID then
		self.isEquip = true

		pg.global.showConfirmMsgRaw(pg.getGameString("EQUIP_CARRY"), pg.getGameString("REPLACE_DOUBLE_CONFIRMATION_TIP"), function()
			pg.me:serverMsg("RPC_CS_EquipCoreCarry", self.petId, sData.invId, sData.genID)
		end)
	else
		self.isEquip = true

		pg.me:serverMsg("RPC_CS_EquipCoreCarry", self.petId, sData.invId, sData.genID)
	end
end

function CarryComponent:onBtnStrength()
	local sData = self.listProps.selectedItem
	local contactState = PetManagementDataHelper.getCoreCarryCertifyDisplayState(sData)

	if sData.isMaxLv and PetManagementDataHelper.isCoreCarryCertified(sData) then
		return
	end

	if sData.isMaxLv and contactState == PetManagementDataHelper.CoreCarryContactState.NotContact then
		self:openCoreCarryCertifyDialog(sData)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_CARRY_STRENGTH, {
		closeCallback = function()
			if not self:m_isViewValid() then
				return
			end

			self.rootComponent:TryChangePage("JewelCompare", 0)
			self:onOptionSelected()
		end,
		strengthCarry = sData
	})
end

function CarryComponent:onBtnRecommendUButton()
	local recommendData = Utils.getCertifiedRecommendCarrySet(pg.me, self.petId)

	if not recommendData then
		pg.global.showBubbleMessageById(NoticeDef.ERROR_ITEM_NOT_FOUND)

		return
	end

	local recommendCoreCarryPos = recommendData.coreCarryPos
	local currentCarryInfo = self.model:getPetCarryInfo(self.petId)

	if currentCarryInfo.isEquipped and recommendCoreCarryPos and currentCarryInfo.invId == recommendCoreCarryPos[1] and currentCarryInfo.genID == recommendCoreCarryPos[2] then
		pg.global.showBubbleMessageRaw(pg.getGameString("PETCARRY_RECOMMEND_APPLIED"))

		return
	end

	pg.me:serverMsg("RPC_CS_BatchEquipCarry", self.petId, recommendData, function(res)
		local noticeId = res or NoticeDef.ERROR_2

		if noticeId == NoticeDef.SUCCESS then
			pg.game.petManage:onRequstBatchEquipCarrySuccess()
		else
			pg.global.showBubbleMessageById(noticeId)
		end
	end)
end

function CarryComponent:onAssistEquip()
	local sData = self.dragItem or self.listProps.selectedItem
	local cpInfo = self.selectAsstPosInfo and self.selectAsstPosInfo.asstData

	if not self.selectAsstPosInfo then
		pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_SLOT_NOT_SELECT"))

		return
	end

	local coreCarry = sData.ownerCoreCarryPos
	local selectCarryCore = self.model:getSelectCarryCore()

	if cpInfo and next(cpInfo) and cpInfo.genID == sData.genID then
		pg.me:serverMsg("RPC_CS_RemoveAssistCarry", selectCarryCore.invId, selectCarryCore.genID, self.selectAsstPosInfo.posIndex, function(result)
			if result == true then
				facade:sendMsgToUI(MessageName.CARRY_UNLOAD, {
					petId = self.petId
				})
			end
		end)
	elseif coreCarry and next(coreCarry) and coreCarry[1] ~= 0 and coreCarry[2] ~= 0 then
		self.isEquip = true

		local isSameCarryCore = coreCarry[1] == selectCarryCore.invId and coreCarry[2] == selectCarryCore.genID
		local showTex = isSameCarryCore and "REPLACE_GEM_DOUBLE_CONFIRMATION_TIP2" or "REPLACE_GEM_DOUBLE_CONFIRMATION_TIP1"

		pg.global.showConfirmMsgRaw(pg.getGameString("EQUIP_GEM"), pg.getGameString(showTex), function()
			pg.me:serverMsg("RPC_CS_AddAssistCarry", selectCarryCore.invId, selectCarryCore.genID, self.selectAsstPosInfo.posIndex, sData.invId, sData.genID, function(result)
				if result == true then
					facade:sendMsgToUI(MessageName.CARRY_EQUIP, {
						petId = self.petId
					})
				end
			end)
		end)
	else
		self.isEquip = true

		pg.me:serverMsg("RPC_CS_AddAssistCarry", selectCarryCore.invId, selectCarryCore.genID, self.selectAsstPosInfo.posIndex, sData.invId, sData.genID, function(result)
			if result == true then
				facade:sendMsgToUI(MessageName.CARRY_EQUIP, {
					petId = self.petId
				})
			end
		end)
	end
end

function CarryComponent:onBtnCompound()
	pg.global.ui:open(UIConst.UI_ID_PET_CARRY_ASSIST_STRENGTH, {
		closeCallback = function()
			if not self:m_isViewValid() then
				return
			end

			self:onOptionSelected()
		end
	}, nil, function()
		if not self:m_isViewValid() then
			return
		end

		if self.curType == ItemConst.ITEM_TYPE_CARRY_ASSISTED then
			self.carryNewAnimation:Play("VX_Pb_PetManagement_Cultivate_Carry_JewelSlecet")
		end
	end)
end

function CarryComponent:unableSelectAssist()
	self.carryNewAnimation.enabled = false

	if self.timerTab then
		self:killTimer(self.timerTab)

		self.timerTab = nil
	end

	self.timerTab = self:startTimer(function()
		self.tabCarryAssst.isSelected = false

		self.tabCarryAssst:TryChangePage("button", 0)

		self.carryNewAnimation.enabled = true
	end, 0.1)
end

function CarryComponent:onDestroy()
	if self.delayCloseSelectPopTimer then
		self:killTimer(self.delayCloseSelectPopTimer)

		self.delayCloseSelectPopTimer = nil
	end

	if self.timerTab then
		self:killTimer(self.timerTab)

		self.timerTab = nil
	end

	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	if self.tabTimer then
		self:killTimer(self.tabTimer)

		self.tabTimer = nil
	end

	UIComponent.onDestroy(self)
end

function CarryComponent:refreshBatchCarryEquiped()
	self.carryPetInfo = self.model:getPetCarryInfo(self.petId)

	self.model:setSelectCarryCore(nil)
	self:onOptionSelected()
end

function CarryComponent:setEquipTipText(usdfText, isEquipped, isCompare, formatName)
	if IsNil(usdfText) then
		return
	end

	if not isEquipped then
		ClientTextUtils.setText(usdfText, "")

		return
	end

	if not isCompare then
		ClientTextUtils.setText(usdfText, pg.getGameString("PET_CARRY_TIP_JEWEL_EQUIPED") or "Equiped")

		return
	end

	local fStr = pg.getGameString("PET_CARRY_TIP_JEWEL_EQUIP_COMPARE")

	fStr = (not fStr or fStr == "" or fStr == "PET_CARRY_TIP_JEWEL_EQUIP_COMPARE") and "Compare:%s" or fStr

	ClientTextUtils.setText(usdfText, string.format(fStr, formatName or ""))
end

function CarryComponent:playCertifyAnimation(aniName, completeCallback)
	local targetAnimation = self.certifyContactTUAnimation

	if IsNil(targetAnimation) then
		return
	end

	UIUtils.PlayAnimation(targetAnimation, aniName, completeCallback)
end

function CarryComponent:playCarryEquipAnimation()
	local targetAnimation = self.carryEquipTUAnimation

	if IsNil(targetAnimation) then
		return
	end

	UIUtils.PlayAnimation(targetAnimation, CORE_CARRY_EQUIP_ANI)
end

return CarryComponent
