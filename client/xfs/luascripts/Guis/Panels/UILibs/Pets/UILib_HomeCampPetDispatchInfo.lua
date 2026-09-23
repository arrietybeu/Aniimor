-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\UILibs\\Pets\\UILib_HomeCampPetDispatchInfo.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("UILib_HomeCampPetDispatchInfo")
local Class = require("Core.Framework.Class")
local UILib_HomeCampPetDispatchInfo = Class.LiteClass("UILib_HomeCampPetDispatchInfo")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetLevelData = require("Data.pet_level_data")
local PetDispatchData = require("Data.pet_dispatch_data")
local CommonSwitch = require("Common.CommonSwitch")
local math_floor = math.floor
local string_format = string.format
local ListItemType = {
	Pet = 1,
	DispatchType = 2
}
local ListItemTempIds = {
	WaitDispatch = 3,
	NoPet_Lock = 2,
	NoPet_Unlock = 1,
	HasPet = 0
}
local DispatchTypesDescKey = {
	"HOME_CAMP_CAR_PET_DISP_S_FOOTING",
	"HOME_CAMP_CAR_PET_DISP_S_TRIP",
	"HOME_CAMP_CAR_PET_DISP_S_CAMPING"
}
local DispatchingIconUrl = {
	"$UI_Img_Home_CampManage_Hiking.png",
	"$UI_Img_Home_CampManage_Explore.png",
	"$UI_Img_Home_CampManage_Camping.png"
}

function UILib_HomeCampPetDispatchInfo:ctor(rootUComponent, parentCtrl)
	self:resetData()

	self.parentCtrl = parentCtrl
	self.parentModel = parentCtrl and parentCtrl.model

	local objectReference = rootUComponent:GetComponent("ObjectReference")

	self.delegateUComponent = objectReference:GetRefValue("delegateUComponent")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.iconTimeUImage = objectReference:GetRefValue("iconTimeUImage")
	self.txtDelegationUSDFText = objectReference:GetRefValue("txtDelegationUSDFText")
	self.dipatchTimeUSDFText = objectReference:GetRefValue("dipatchTimeUSDFText")
	self.txtReceiveUSDFText = objectReference:GetRefValue("txtReceiveUSDFText")
	self.confirmUSDFText = objectReference:GetRefValue("confirmUSDFText")
	self.confirmUImage = objectReference:GetRefValue("confirmUImage")

	local modalControlsTransform = self.listUList.transform.parent:Find("LayoutBox")

	self.modalControlsUWidget = modalControlsTransform and modalControlsTransform:GetComponent("UWidget")

	function self.listUList.luaRenderItem(button, index, data)
		self:m_renderItem(button, index, data)
	end

	function self.btnConfirmUButton.luaClick()
		self:m_onClickConfirm()
	end

	function self.btnBackUButton.luaClick()
		self:m_onClickCancel()
	end

	self.m_secondUpdateTimerId = TimerManager.addRepeatTimer(1, function()
		self:m_secondUpdate()
	end)
	self.isCreated = true
end

function UILib_HomeCampPetDispatchInfo:onDestroy()
	if self.m_secondUpdateTimerId then
		TimerManager.removeTimer(self.m_secondUpdateTimerId)

		self.m_secondUpdateTimerId = nil
	end

	if self.m_focusDispatchTypeTimerId then
		TimerManager.removeTimer(self.m_focusDispatchTypeTimerId)

		self.m_focusDispatchTypeTimerId = nil
	end

	self.isCreated = false
end

function UILib_HomeCampPetDispatchInfo:getCampCarEnt()
	local carUid = pg.me and pg.me.uid

	return HomeLandUtils.getCampCarEntity(carUid)
end

function UILib_HomeCampPetDispatchInfo:getCampCarEntPetsState()
	local campCarEnt = self:getCampCarEnt()

	return campCarEnt and campCarEnt:getCampPetDispatchState() or UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch
end

function UILib_HomeCampPetDispatchInfo:isShowingDispatchTypes()
	return self:getCampCarEntPetsState() == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch and self.m_isReadyToDispatch
end

function UILib_HomeCampPetDispatchInfo:getCampCarDispatchId()
	local campCarEnt = self:getCampCarEnt()

	return campCarEnt and campCarEnt:getDispatchId() or 0
end

function UILib_HomeCampPetDispatchInfo:resetData()
	self.m_pageType = UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr

	self:resetSelectedData()
end

function UILib_HomeCampPetDispatchInfo:resetSelectedData()
	if self.m_focusDispatchTypeTimerId then
		TimerManager.removeTimer(self.m_focusDispatchTypeTimerId)

		self.m_focusDispatchTypeTimerId = nil
	end

	self.m_selectDispatchTypeId = HomeCampUtils.getCampPreSelectedDispatchedId()
	self.m_readyToRemovePetsMap = {}
	self.m_isReadyToDispatch = false
	self.m_prePageIndex = -1
	self.m_isTryStopDispatch = true
end

function UILib_HomeCampPetDispatchInfo:setDataAndRefresh(pageType, forceSet)
	if not forceSet and self.m_pageType == pageType then
		return
	end

	self.m_pageType = pageType

	self:resetSelectedData()
	self:refreshUI()
end

function UILib_HomeCampPetDispatchInfo:refreshUI()
	self:m_tryChangePage()
	self:m_refreshTimeCountDown()
	self:m_refreshBtnConfirm()
end

function UILib_HomeCampPetDispatchInfo:m_secondUpdate()
	self:m_refreshTimeCountDown()
end

function UILib_HomeCampPetDispatchInfo:m_getChangePageIndex()
	local dispatchState = self:getCampCarEntPetsState()
	local pageIndex = 0

	if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		if self.m_isReadyToDispatch then
			pageIndex = 1
		end
	else
		pageIndex = dispatchState
	end

	return pageIndex
end

function UILib_HomeCampPetDispatchInfo:m_tryChangePage()
	local pageIndex = self:m_getChangePageIndex()

	if self.m_prePageIndex and self.m_prePageIndex == pageIndex then
		return
	end

	self.delegateUComponent:TryChangePage("State", pageIndex)

	self.m_prePageIndex = pageIndex

	self:m_refreshList()

	if self.parentCtrl and self.parentCtrl.trySetSceneDisplayPetsDisplay then
		self.parentCtrl:trySetSceneDisplayPetsDisplay()
	end
end

function UILib_HomeCampPetDispatchInfo:m_refreshList()
	if not self:getCampCarEnt() then
		return
	end

	local dispatchState = self:getCampCarEntPetsState()
	local itemsData = {}
	local isShowDispatchTyps = false

	if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch and self.m_isReadyToDispatch then
		isShowDispatchTyps = true
		self.m_dispathButtomItmes = {}

		local dispatchTypes = HomeCampUtils:getCampPetDispatchSortTypes() or {}

		for _, dispatchTypeCfg in ipairs(dispatchTypes) do
			itemsData[#itemsData + 1] = {
				type = ListItemType.DispatchType,
				dispatchTypeInfo = dispatchTypeCfg,
				tIndex = ListItemTempIds.WaitDispatch,
				dispatchState = dispatchState
			}
		end
	end

	if not isShowDispatchTyps then
		local campCarEnt = self:getCampCarEnt()
		local campPets = HomeCampUtils.getUICacheCampPetsList(self.parentModel:getUICacheCampPetIds(), campCarEnt)
		local petCanSetCnt = campCarEnt:getCarPetCanSetCount()
		local maxPetCnt = UIConst.HOME_CAMP_PETS_SLOT_MAXCNT
		local campPetCnt = #campPets
		local max = math.max(petCanSetCnt, maxPetCnt)
		local isShowCancel = self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr

		for i = 1, max do
			local hasPet = i <= campPetCnt
			local isLock = petCanSetCnt < i
			local petId = campPets and campPets[i] and campPets[i].id or 0

			itemsData[#itemsData + 1] = {
				type = ListItemType.Pet,
				campPetInfo = campPets and campPets[i] or nil,
				tIndex = hasPet and ListItemTempIds.HasPet or isLock and ListItemTempIds.NoPet_Lock or ListItemTempIds.NoPet_Unlock,
				isLock = isLock,
				dispatchState = dispatchState,
				isShowCancel = isShowCancel
			}
		end
	end

	self.listUList:SetList(itemsData)

	if self.modalControlsUWidget and not IsNil(self.modalControlsUWidget) then
		self.modalControlsUWidget:SetActive(self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr)
	end

	if self.parentCtrl and self.parentCtrl.refreshPetListNavigationState then
		self.parentCtrl:refreshPetListNavigationState(isShowDispatchTyps)
	end
end

function UILib_HomeCampPetDispatchInfo:m_renderItem(button, index, data)
	button.draggable = false
	button.enabledTooltip = true

	local itemType = data.type
	local tIndex = data.tIndex

	if itemType == ListItemType.Pet then
		local campPetInfo = data.campPetInfo

		if campPetInfo and tIndex == ListItemTempIds.HasPet then
			campPetInfo.isShowCancel = data.isShowCancel

			LuaUIUtils.renderHomePetHead(button, campPetInfo, data.dispatchState, {
				isForbidToolTips = true
			})
			self:m_setPetHeadCancelBtn(button, data, index)
		elseif tIndex == ListItemTempIds.NoPet_Unlock then
			self:renderHomePetHeadLock(button, false)
		elseif tIndex == ListItemTempIds.NoPet_Lock then
			self:renderHomePetHeadLock(button, true)
		end

		function button.luaClick()
			self:m_onClickPetItem(button, index, data)
		end

		function button.luaHover()
			if self.parentCtrl and self.parentCtrl.onItemFocused then
				self.parentCtrl:onItemFocused(button)
			end
		end
	elseif itemType == ListItemType.DispatchType then
		self:renderDispatchTypeItem(button, index, data)
	end
end

function UILib_HomeCampPetDispatchInfo:renderHomePetHeadLock(button, isLock)
	return
end

function UILib_HomeCampPetDispatchInfo:m_onClickPetItem(button, index, data)
	if data and data.isLock then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_COUNT_MAX)

		return
	end

	local dispatchState = self:getCampCarEntPetsState()

	if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr then
			facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_SWITCH_PET_DISPATCHUI)
		else
			if pg.game.input and pg.game.input:isUsingGamepad() then
				return
			end

			self:m_removeFocusedCampPet(data.campPetInfo)
		end
	end
end

function UILib_HomeCampPetDispatchInfo:m_removeFocusedCampPet(campPetInfo)
	if not campPetInfo then
		return
	end

	if self.m_pageType ~= UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		return
	end

	if self:getCampCarEntPetsState() ~= UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		return
	end

	local remainSlots = pg.me.petBoxMap and pg.me.petBoxMap:getValidEmptySlot() or 0

	if remainSlots < 1 then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAMP_PET_BAG_FULL)

		return
	end

	self:m_setSelectedToRemovePetIds(campPetInfo.id)
	self:m_refreshBtnConfirm()
end

function UILib_HomeCampPetDispatchInfo:m_setSelectedToRemovePetIds(petId)
	if not petId then
		return
	end

	self.parentModel:tryRemoveCacheCampPet(petId, function()
		self:resetSelectedData()
		self:refreshUI()
	end, nil, true)
end

function UILib_HomeCampPetDispatchInfo:m_isExistDiffCachePetIds()
	return not self.parentModel:isEqualInitCacheCampPetIds()
end

function UILib_HomeCampPetDispatchInfo:m_getIsExistCampPets()
	local campCarEnt = self:getCampCarEnt()
	local campPets = HomeCampUtils.getUICacheCampPetsList(self.parentModel:getUICacheCampPetIds(), campCarEnt)

	return campPets and next(campPets)
end

function UILib_HomeCampPetDispatchInfo:m_tryRefreshSelectedToRemovePets(button, data)
	if not button then
		return
	end

	local petId = data and data.campPetInfo and data.campPetInfo.id
	local isToRemove = petId and self.m_readyToRemovePetsMap[petId]
	local btnCancelWorkingUContainer = button:GetComponent("ObjectReference"):GetRefValue("btnCancelWorkingUContainer")

	if btnCancelWorkingUContainer then
		btnCancelWorkingUContainer:SetActive(ToBool(isToRemove))
	end

	function btnCancelWorkingUContainer.content.luaClick()
		pg.me.space:deallocateHomePetWork(data.petId, nil, true)
	end
end

function UILib_HomeCampPetDispatchInfo:m_setPetHeadCancelBtn(button, data, index)
	if not button then
		return
	end

	local btnCancelWorkingUContainer = button:GetComponent("ObjectReference"):GetRefValue("btnCancelWorkingUContainer")

	function btnCancelWorkingUContainer.content.luaClick()
		self:m_onClickPetItem(button, index, data)
	end
end

function UILib_HomeCampPetDispatchInfo:renderDispatchTypeItem(button, index, data)
	local dispatchTypeInfo = data.dispatchTypeInfo

	if not dispatchTypeInfo then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	local itemUButton = objectReference:GetRefValue("itemUButton")

	button.isSelected = self.m_selectDispatchTypeId == dispatchTypeInfo.id
	iconUImage.url = dispatchTypeInfo.iconUrl or ""

	ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(dispatchTypeInfo.nameKey or ""))

	local finishTimeL10nName = LuaUIUtils.getCountDownString(dispatchTypeInfo.finishTimeSecond or 0, UIConst.TimeType.Short, true)

	txtTimeUSDFText.text = finishTimeL10nName or ""

	function button.luaRenderTooltip(_, component)
		self:m_toolTipDispatchType(_, component)
	end

	function itemUButton.luaClick(isFromNavigation)
		self:m_onClickDispatchType(button, index, data, isFromNavigation)
	end

	function button.luaHover()
		if self.parentCtrl and self.parentCtrl.m_syncNavFocus then
			self.parentCtrl:m_syncNavFocus(button)
		end
	end

	self.m_dispathButtomItmes = self.m_dispathButtomItmes or {}
	self.m_dispathButtomItmes[dispatchTypeInfo.id] = button

	local dispatchId = data and data.dispatchTypeInfo and data.dispatchTypeInfo.id
	local pdpdd = PetDispatchData[dispatchId]
	local conditionId = pdpdd and pdpdd.unlockCondition
	local isUnlocked = true

	if conditionId and conditionId > 0 then
		isUnlocked = pg.me and pg.me.triggerMap and pg.me.triggerMap:isCompleteOrMeetCondition(conditionId)
	end

	button:TryChangePage("Unlock", isUnlocked and 0 or 1)
end

function UILib_HomeCampPetDispatchInfo:m_onClickDispatchType(button, index, data, isFromNavigation)
	local dispatchTypeInfo = data.dispatchTypeInfo

	if not dispatchTypeInfo then
		return
	end

	local preSelectedButton = self.m_dispathButtomItmes and self.m_dispathButtomItmes[self.m_selectDispatchTypeId]

	if preSelectedButton and not IsNil(preSelectedButton) and preSelectedButton ~= button then
		preSelectedButton.isSelected = false
	end

	self.m_selectDispatchTypeId = dispatchTypeInfo.id

	HomeCampUtils.setCampPreSelectedDispatchedId(dispatchTypeInfo.id)

	button.isSelected = true

	if isFromNavigation then
		button.enabledTooltip = false

		TimerManager.addNextFrameCb(function()
			if self.isCreated and button and not IsNil(button) then
				button.enabledTooltip = true
			end
		end)

		return
	end
end

function UILib_HomeCampPetDispatchInfo:m_toolTipDispatchType(_, component)
	if component then
		local objectReference = component:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local campId = self.parentCtrl:getSelectedExploreAreaId()
		local rewardInfo = HomeCampUtils.getCarDispatchBelongTypeRewardInfo(self:getCampCarEnt(), self.m_selectDispatchTypeId, campId)

		ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(rewardInfo.itemDescKey or "") or "")
	end
end

function UILib_HomeCampPetDispatchInfo:m_refreshTimeCountDown()
	if not self.isCreated then
		return
	end

	local dispatchState = self:getCampCarEntPetsState()

	if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished then
		self:m_tryChangePage()
		self:m_refreshBtnConfirm()
	elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching then
		local campCarEnt = self:getCampCarEnt()
		local dispatchInfo = campCarEnt and campCarEnt:getPetsDispatchInfo()

		if dispatchInfo then
			if dispatchInfo:checkIsFinished() then
				self:m_tryChangePage()
			elseif dispatchInfo.dispId and self.dipatchTimeUSDFText and self.txtDelegationUSDFText then
				local preDescKey = DispatchTypesDescKey[dispatchInfo.dispId]
				local preDesc = pg.getGameString(preDescKey)

				preDesc = (not preDesc or preDesc == preDescKey) and preDescKey or preDesc

				ClientTextUtils.setText(self.txtDelegationUSDFText, preDesc)

				local endTs = dispatchInfo.endTs or 0
				local nowTs = Time.secondCache or 0
				local remainTs = math.max(0, endTs - nowTs)
				local timeContDownStr = LuaUIUtils.getCountDownString(remainTs, UIConst.TimeType.Short, true)

				ClientTextUtils.setText(self.dipatchTimeUSDFText, timeContDownStr)
			end
		end
	end
end

function UILib_HomeCampPetDispatchInfo:m_refreshBtnConfirm()
	local confirmTxtKey = ""
	local dispatchState = self:getCampCarEntPetsState()
	local iconUrl

	if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		confirmTxtKey = "HOME_CAMP_CAR_PET_DISP_CONFIRM"
		iconUrl = "$UI_Img_Home_CampManage_Confirm.png"
	elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
		if self.m_isReadyToDispatch then
			confirmTxtKey = "HOME_CAMP_CAR_PET_DISP_START"
			iconUrl = "$UI_Img_Home_CampManage_Confirm.png"
		else
			confirmTxtKey = "HOME_CAMP_CAR_PET_DISP_TOUR"
			iconUrl = "$UI_Img_Home_CampManage_Travel.png"
		end
	elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching then
		confirmTxtKey = "HOME_CAMP_CAR_PET_DISP_STOP"

		if self.m_isTryStopDispatch then
			iconUrl = "$UI_Img_Home_CampManage_Recall.png"
		else
			local dispatchTypeId = self:getCampCarDispatchId()
			local dispCfg = HomeCampUtils.getCampPetsDispatchCfg(dispatchTypeId)

			iconUrl = dispCfg and dispCfg.iconId

			if not iconUrl then
				iconUrl = DispatchingIconUrl[dispatchTypeId]
			end
		end
	elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished then
		confirmTxtKey = "HOME_CAMP_CAR_PET_DISP_GAIN"
		iconUrl = "$UI_Img_Home_CampManage_Receive.png"
	end

	local confirmTxt = pg.getGameString(confirmTxtKey)

	confirmTxt = (not confirmTxt or confirmTxt == confirmTxtKey) and confirmTxtKey or confirmTxt

	ClientTextUtils.setText(self.confirmUSDFText, confirmTxt)

	if iconUrl and iconUrl ~= "" then
		self.confirmUImage.url = iconUrl
	end

	local showRewardRedDot = self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.CampMgr and dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished

	pg.global.setRedDot(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD_CONFIRM, self.btnConfirmUButton, showRewardRedDot, RedDotConst.RedDotStyle.REWARD)

	if self.parentCtrl and self.parentCtrl.refreshConsoleBarState then
		self.parentCtrl:refreshConsoleBarState()
	end
end

function UILib_HomeCampPetDispatchInfo:m_onClickConfirm()
	if not CommonSwitch.CAMP_MANAGER then
		return
	end

	if self.m_pageType == UIConst.HOME_CAMP_MANAGER_PAGE_TYPE.DispatchMgr then
		self.parentCtrl:backUI()
	else
		local dispatchState = self:getCampCarEntPetsState()

		if dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch then
			if self.m_isReadyToDispatch then
				self:m_tryStartDispatch()
			else
				self:m_tryReadyDispatch()
				self:refreshUI()
				self:m_tryFocusSelectedDispatchType()
			end
		elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching then
			self:m_tryStopDispatch()
		elseif dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished then
			self:m_tryFinishDispatch()
		end
	end
end

function UILib_HomeCampPetDispatchInfo:m_onClickCancel()
	self.m_isReadyToDispatch = false

	self:refreshUI()
end

function UILib_HomeCampPetDispatchInfo:m_trySetCampPets()
	if not self:m_isExistDiffCachePetIds() then
		return
	end

	self.parentModel:setCacheCampPet(function()
		self.parentCtrl:forceSwitchToCurUI()
	end)
end

function UILib_HomeCampPetDispatchInfo:m_tryReadyDispatch()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	local petIds = campCarEnt:getCampPetIds() or {}

	if #petIds == 0 then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_DISPATCH_FAIL_NOPETS)

		return
	end

	self.m_isReadyToDispatch = true
end

function UILib_HomeCampPetDispatchInfo:m_tryFocusSelectedDispatchType()
	if self.m_focusDispatchTypeTimerId then
		TimerManager.removeTimer(self.m_focusDispatchTypeTimerId)

		self.m_focusDispatchTypeTimerId = nil
	end

	self.m_focusDispatchTypeTimerId = TimerManager.addNextFrameCb(function()
		self.m_focusDispatchTypeTimerId = nil

		local button = self.m_dispathButtomItmes and self.m_dispathButtomItmes[self.m_selectDispatchTypeId]

		if not button or IsNil(button) then
			return
		end

		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if navMgr then
			navMgr:PushFocusItem(button)
		end
	end)
end

function UILib_HomeCampPetDispatchInfo:m_tryStartDispatch()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	if not self.m_selectDispatchTypeId or self.m_selectDispatchTypeId <= 0 then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_DISPATCH_FAIL_NOCHOOSE)

		return
	end

	local campId = self.parentCtrl:getSelectedExploreAreaId()

	campCarEnt:dispatchPet(self.m_selectDispatchTypeId, campId)
end

function UILib_HomeCampPetDispatchInfo:m_tryStopDispatch()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_CAMP_CAR_PET_DISP_TIP_STOP"), function()
		campCarEnt:stopDispatch()

		self.m_isTryStopDispatch = false

		self:m_refreshBtnConfirm()
	end, false, function()
		return
	end)

	self.m_isTryStopDispatch = true

	self:m_refreshBtnConfirm()
end

function UILib_HomeCampPetDispatchInfo:m_tryFinishDispatch()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	campCarEnt:finishDispatch()
end

return UILib_HomeCampPetDispatchInfo
