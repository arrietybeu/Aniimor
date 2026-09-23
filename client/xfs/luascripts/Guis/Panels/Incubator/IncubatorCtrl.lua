-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Incubator\\IncubatorCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("IncubatorCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local IncubatorCtrl = Class.LightClass("IncubatorCtrl", UICtrl)
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CashShopConst = require("Const.CashShopConst")
local HotkeyConst = require("Const.HotkeyConst")
local LIMIT_CLOSE_PROP_DELAY_TIME = 150

IncubatorCtrl.messages = {
	[MessageName.HOMELAND_HATCH_UPDATE_SINGLEINFO] = {
		"m_updateOrnamentHatchInfo",
		true
	},
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onRefreshTabList",
		true
	},
	[MessageName.MONTH_CARD_ACTIVATE] = {
		"onRefreshTabList",
		true
	},
	[MessageName.HOMELAND_HATCH_UPDATE_ADD_SINGLEINFO] = {
		"m_addOrnamentHatchInfo",
		true
	},
	[MessageName.HOMELAND_HATCH_UPDATE_REMOVE_SINGLEINFO] = {
		"m_removeOrnamentHatchInfo",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function IncubatorCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.updateTimer = self:startTimer(function()
		self:onTick()
	end, 0.5, true)

	self:Init(info)
end

function IncubatorCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:onClickClose()
	end

	function self.view.btnPasueUButton.luaClick()
		self:onClickPause()
	end

	function self.view.btnSortUButton.luaClick()
		self:onClickSortOrFilter()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onClickConfirm()
	end

	if self.view.speedTipsUButton then
		function self.view.speedTipsUButton.luaRenderTooltip(_, tooltip)
			local objectReference = tooltip:GetComponent("ObjectReference")
			local btnUpUButton = objectReference:GetRefValue("btnUpUButton")
			local txtDesc = objectReference:GetRefValue("txtDesc")
			local btnNameUSDFText = objectReference:GetRefValue("btnNameUSDFText")
			local isActivated = MonthCardUtils.isActivated()

			tooltip:TryChangePage("Btn", isActivated and 0 or 1)
			tooltip:TryChangePage("headTitle", 0)

			local tipKey = isActivated and "INCUBATE_MONTHLY_ACTIVATED_INFO" or "INCUBATE_MONTHLY_UNACTIVATED_INFO"
			local time = ClientActivityUtils.getMonthCardSpeedupHatchTime()

			ClientTextUtils.setText(txtDesc, pg.getFormatText(pg.getGameString(tipKey), time))
			ClientTextUtils.setText(btnNameUSDFText, pg.getGameString("INCUBATE_MONTHLY_GO_TO"))

			function btnUpUButton.luaClick()
				self.view.speedTipsUButton:CloseTooltip()
				pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
					tabId = CashShopConst.CategoryType.MONTHLYCARD
				})
			end
		end

		function self.view.speedTipsUButton.luaClick()
			self.view.speedTipsUButton:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)
		end
	end

	self:m_setupBtnConfirmHotKey()
end

function IncubatorCtrl:m_setupBtnConfirmHotKey()
	local btn = self.view and self.view.btnConfirmUButton

	if not btn or IsNil(btn) then
		return
	end

	local keyTrans = btn.transform:Find("PanelText/Key") or btn.transform:Find("Key")
	local hotKeyContentGo = keyTrans and not IsNil(keyTrans) and keyTrans.gameObject or nil

	btn:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, hotKeyContentGo)
	btn:SetHotkeyBypassUIModalBlock(true)
end

function IncubatorCtrl:onDestroy()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end

	IncubatorCtrl.super.onDestroy(self)
end

function IncubatorCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:Init(info)
	self:RefreshOnOpen()
end

function IncubatorCtrl:onShow()
	self:RefreshOnOpen()

	local isPetHatchOpen = ClientActivityUtils.isPetHatchActivityOpen()

	if isPetHatchOpen then
		pg.global.ui.tips:showDropHint("PET_HATCH_ACTIVITY_1", self.view.root.position)
	end
end

function IncubatorCtrl:onHide()
	pg.global.ui.tips:hideDropHint()
end

function IncubatorCtrl:onTick()
	self:m_updateHatchProgress()
end

function IncubatorCtrl:Init(info)
	self.m_homeSpace = pg.me.space
	self.m_uiOpenParams = info or {}
	self.m_listContData = {}

	self.model:setSelectedItemData()
	self.model:setHatchSortId(1)
	self:initOrnamentHatchInfo()
	self:initPropList(info)
	self:initSortOption(info)
	self:m_updateHatchProgress(true)
end

function IncubatorCtrl:RefreshOnOpen()
	self:updatAndRefresh()
end

function IncubatorCtrl:updatAndRefresh()
	self.m_rootPage = self.model:getRootPage(self.m_uiOpenParams)

	self:refreshRoot()
	self:refreshHatchInfo()
	self:refreshSortOption()
	self:refreshBottom()
end

function IncubatorCtrl:refreshRoot()
	self.view.root:TryChangePage("Type", self.m_rootPage)
	ClientTextUtils.setText(self.view.txtListContEmptyUSDFtext, self.model:getListContEmptyDesc(self.m_rootPage))
end

function IncubatorCtrl:initOrnamentHatchInfo()
	self.m_ornamentId = self.m_uiOpenParams and self.m_uiOpenParams.ornamentId or 0

	if self.m_ornamentId <= 0 then
		self:close()

		return
	end

	self:m_updateOrnamentHatchInfo({
		ornamentId = self.m_ornamentId
	})
end

function IncubatorCtrl:isSameOrnament(ornamentIdTbl)
	local ornamentId = ornamentIdTbl and ornamentIdTbl.ornamentId or 0

	if not ornamentId or ornamentId <= 0 then
		return false
	end

	return ornamentId == self.m_ornamentId
end

function IncubatorCtrl:m_addOrnamentHatchInfo(ornamentIdTbl)
	if not self:isSameOrnament(ornamentIdTbl) then
		return
	end

	self:close()
end

function IncubatorCtrl:m_removeOrnamentHatchInfo(ornamentIdTbl)
	if not self:isSameOrnament(ornamentIdTbl) then
		return
	end

	self:close()
end

function IncubatorCtrl:m_updateOrnamentHatchInfo(ornamentIdTbl)
	if not self:isSameOrnament(ornamentIdTbl) then
		return
	end

	self:updatAndRefresh()
end

function IncubatorCtrl:onRefreshTabList()
	if not self.m_ornamentId or self.m_ornamentId <= 0 then
		return
	end

	self:updatAndRefresh()
end

function IncubatorCtrl:refreshHatchInfo()
	local hatchInfo = self.model:getOrnamentHatchInfo(self.m_ornamentId)
	local isEmptyHacth = not hatchInfo or not hatchInfo.item

	self.view.nmlUWidget:SetActive(not isEmptyHacth)
	self.view.nullUWidget:SetActive(isEmptyHacth)

	if isEmptyHacth then
		ClientTextUtils.setText(self.view.txtEmptyUSDFText, self.model:getEmptyHatchDesc())
	else
		local item = hatchInfo.item
		local itemId = item and item.id or 0
		local itemCfg = ItemData[itemId]

		if itemCfg then
			self.view.iconProductUImage.url = itemCfg and itemCfg.icon or ""

			ClientTextUtils.setText(self.view.txtNameUSDFText, ItemUtils.getItemFinalNameStr(itemCfg))

			local nowTime = Time.secondCache or 0
			local endTime = hatchInfo.endTime or 0

			LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, math.max(0.1, endTime - nowTime), nil, nil, nil, true)
			ClientTextUtils.setText(self.view.txtReduceUSDFText, self.model:getPreviewSpeedupTimeDesc())
		end

		local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.m_ornamentId)
		local isInSpeedUpPage = self.m_rootPage == self.model.RootPage_SpeedUp

		self.view.btnPasueUButton:SetActive(hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING and not isInSpeedUpPage)
	end
end

function IncubatorCtrl:m_updateHatchProgress(forceInit)
	if forceInit then
		self.view.progressUProgress.value = 0

		return
	end

	local hatchInfo = self.model:getOrnamentHatchInfo(self.m_ornamentId)
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.m_ornamentId)
	local isEmptyHacth = hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.CAN_PLACE

	self.view.nmlUWidget:SetActive(not isEmptyHacth)
	self.view.nullUWidget:SetActive(isEmptyHacth)

	if isEmptyHacth then
		ClientTextUtils.setText(self.view.txtEmptyUSDFText, self.model:getEmptyHatchDesc())
	else
		local item = hatchInfo.item
		local itemId = item and item.id or 0
		local itemCfg = ItemData[itemId]

		if itemCfg then
			self.view.iconProductUImage.url = itemCfg and itemCfg.icon or ""

			ClientTextUtils.setText(self.view.txtNameUSDFText, ItemUtils.getItemFinalNameStr(itemCfg))

			local leftSecond = HomeLandUtils.getHatchBoxHatchedLeftSecond(hatchInfo)

			LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, math.max(0.1, leftSecond), nil, nil, nil, true)

			local proRatio = HomeLandUtils.getHatchBoxProgressRatio(hatchInfo)

			self.view.progressUProgress.maxValue = 1
			self.view.progressUProgress.value = proRatio
		end

		local isInSpeedUpPage = self.m_rootPage == self.model.RootPage_SpeedUp

		self.view.btnPasueUButton:SetActive(hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING and not isInSpeedUpPage)
	end
end

function IncubatorCtrl:initSortOption(info)
	function self.view.btnSortUButton.luaClick()
		self:m_onClickSortOrFilter()
	end

	local sortOptions = self.model:getHatchEggSortInfo()

	function self.view.selectorUSelector.luaRenderPopup(popup, uList)
		function uList.luaRenderItem(button, index, data)
			self:m_onLuaRenderSortOptItem(button, index, data)
		end

		uList:SetList(sortOptions)
	end
end

function IncubatorCtrl:m_onClickSortOrFilter()
	self.model:reverseSetHatchDescending()
	self:refreshSortOption()
end

function IncubatorCtrl:m_onLuaRenderSortOptItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtUText = objectReference:GetRefValue("txtUText")

	ClientTextUtils.setText(txtUText, data.name)

	function button.luaClick()
		self.model:setHatchSortId(index + 1)
		self:refreshSortOption()
		self.view.selectorUSelector:ClosePopup()
	end
end

function IncubatorCtrl:refreshSortOption()
	local sortOptions = self.model:getHatchEggSortInfo()
	local hatchSortId = self.model:getHatchSortId()

	self.view.selectorUSelector:SetOptions(sortOptions)

	self.view.selectorUSelector.selectedIndex = hatchSortId - 1

	ClientTextUtils.setText(self.view.selectorTxtNameUBaseText, self.model:getHatchEggSortInfo()[hatchSortId].name)

	local hatchIsDescending = self.model:getHatchDescending()

	self.view.btnSortUButton:TryChangePage("asc", hatchIsDescending and 1 or 0)
	self:refreshPropListPanel()
end

function IncubatorCtrl:initPropList(info)
	function self.view.listPropUList.luaRenderItem(button, index, data)
		self:m_renderContListItem(button, index, data)
	end
end

function IncubatorCtrl:refreshPropListPanel()
	if self.m_rootPage == self.model.RootPage_PutEgg or self.m_rootPage == self.model.RootPage_Manger then
		self:m_refreshEggListPanel()
	elseif self.m_rootPage == self.model.RootPage_SpeedUp then
		self:m_refreshSpeedUpListPanel()
	end
end

function IncubatorCtrl:m_onPressContListItem(itemType, button, data)
	self.m_preClickMs = self.m_preClickMs or 0

	if Time.realSecondCache * 1000 - self.m_preClickMs < LIMIT_CLOSE_PROP_DELAY_TIME then
		return
	end

	self:m_onClickContListItem(button, data)

	if itemType == self.model.ItemType_SpeedUp then
		self.model:setPreviewSpeedupTime(data, self.m_ornamentId)
	end

	self.m_preClickMs = Time.realSecondCache * 1000 or 0

	self:openItemPropUI(data, button)
	self:refreshHatchInfo()
	self:refreshBottom()
end

function IncubatorCtrl:m_onReleaseContListItem(itemType, button, data)
	if not self.view or not self.view.listPropUList then
		return
	end

	local btns = self.view.listPropUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local isSelected = i == (data and data.index or 0) - 1

		btns[i].isSelected = isSelected
	end
end

function IncubatorCtrl:openItemPropUI(data, button)
	self:cancelClosePropTimer()
	LuaUIUtils.popupPropTip({
		id = data.itemId,
		num = data.count,
		targetRect = self.view.panelRectTransform,
		itemId = data.itemId,
		genID = data.genID,
		extra = {
			closeFun = function()
				self:cancelClosePropTimer()

				self.delayRefreshByClosePropTimer = TimerManager.addTimer(LIMIT_CLOSE_PROP_DELAY_TIME / Const.MILLISECOND_ONE_SECOND, function()
					self.delayRefreshByClosePropTimer = nil

					self:closeItemPropUI()
				end)
			end
		}
	})
end

function IncubatorCtrl:cancelClosePropTimer()
	if self.delayRefreshByClosePropTimer then
		TimerManager.removeTimer(self.delayRefreshByClosePropTimer)

		self.delayRefreshByClosePropTimer = nil
	end
end

function IncubatorCtrl:closeItemPropUI()
	if self.view then
		self:refreshHatchInfo()
		self:refreshPropListPanel()
		self:refreshBottom()
	end
end

function IncubatorCtrl:m_renderContListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local disabledUImage = objectReference:GetRefValue("disabledUImage")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")

	button.draggable = false

	button:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUText, data.count)
	disabledUImage.gameObject:SetActiveEx(data.isHatching)

	local isLock = data.isLock

	stateLockUWidget.gameObject:SetActiveEx(isLock)

	local selectedData = self.model:getSelectedItemData()

	button.isSelected = selectedData and selectedData.genId == data.genId and selectedData.id == data.id or false

	function button.luaPress()
		self:m_onPressContListItem(self.model.ItemType_SpeedUp, button, data)
	end

	function button.luaRelease()
		self:m_onReleaseContListItem(self.model.ItemType_Egg, button, data)
	end

	if not IsNil(button) then
		button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
			self:m_onPressContListItem(self.model.ItemType_SpeedUp, button, data)

			return false
		end)
		button:SetHotkeyBypassUIModalBlock(true)
	end
end

function IncubatorCtrl:m_refreshSpeedUpListPanel()
	local data = self.model:getSpeedUpItems()
	local isHasData = data or #data > 0

	self.view.listPropUWidget:SetActive(isHasData)
	self.view.emptyUWidget:SetActive(not isHasData)

	if isHasData then
		self.view.listPropUList:SetList(data)
	end

	self.m_listContData = data
end

function IncubatorCtrl:m_refreshEggListPanel()
	local data = self.model:getAllEggs()
	local isHasData = data and #data > 0

	self.view.listPropUWidget:SetActive(isHasData)
	self.view.emptyUWidget:SetActive(not isHasData)

	if isHasData then
		self.view.listPropUList:SetList(data)

		if not self.model:getSelectedItemData() then
			for _, eggData in ipairs(data) do
				if not eggData.isLock then
					self.model:setSelectedItemData(eggData)

					break
				end
			end
		end
	end

	self.m_listContData = data
end

function IncubatorCtrl:m_onClickContListItem(button, data)
	if data.isLock then
		pg.global.ui.tips:showTextTipById(NoticeDef.HATCH_EGG_LOCK)
	else
		self.model:setSelectedItemData(data)
	end
end

function IncubatorCtrl:refreshBottom()
	local isActivated = MonthCardUtils.isActivated()

	if self.view.speedTipsUButton then
		self.view.speedTipsUButton:SetActive(ClientCashShopUtils.canOpenCashShop())
		self.view.speedTipsUButton:TryChangePage("Monthcard", isActivated and 1 or 0)
	end

	if self.view.txtSpeedTips then
		local tipKey = isActivated and "INCUBATE_MONTHLY_ACTIVATED" or "INCUBATE_HOW_TO_ACCELERATE"

		ClientTextUtils.setText(self.view.txtSpeedTips, pg.getGameString(tipKey))
	end

	if not self.m_listContData or #self.m_listContData == 0 then
		self.view.bottomUWidget:SetActive(false)

		return
	end

	self.view.bottomUWidget:SetActive(true)

	local curSelectedItemData = self.model:getSelectedItemData()
	local isHasSelected = curSelectedItemData and curSelectedItemData.id > 0
	local ornamentHatchInfo = self.model:getOrnamentHatchInfo(self.m_ornamentId)
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.m_ornamentId)
	local tipsTxt, confirmTxt, confirmGray, topTipPreTxt, topTipContTxt

	if self.m_rootPage == self.model.RootPage_PutEgg then
		confirmTxt = pg.getGameString("INCUBATOR_CONFIRM_PLACE_EGG_DESC")

		if isHasSelected then
			topTipPreTxt = pg.getGameString("INCUBATOR_FINITH_TIME_TIP")
			topTipContTxt = self.model:getPreviewIncubatroFinishTimeDesc(curSelectedItemData.id, self.m_ornamentId)
		end
	elseif self.m_rootPage == self.model.RootPage_SpeedUp then
		if ornamentHatchInfo and ornamentHatchInfo.item then
			local speedupInfo = HomeLandUtils.getHatchBoxSpeedupInfo(ornamentHatchInfo) or {}

			topTipPreTxt = pg.getGameString("INCUBATOR_CONFIRM_SPEEDUP_TITLE")
			topTipContTxt = self.model:getLimitSpeedupCntDesc(speedupInfo)

			if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
				confirmTxt = isHasSelected and pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
				tipsTxt = not isHasSelected and pg.getGameString("INCUBATOR_CONFIRM_TIP_SELECTE_SPEEDUP_ITEM")
				confirmGray = true
			elseif speedupInfo.isCanSpeedup then
				confirmTxt = isHasSelected and pg.getGameString("INCUBATOR_CONFIRM_SPEEDUP_DESC")
				tipsTxt = not isHasSelected and pg.getGameString("INCUBATOR_CONFIRM_TIP_SELECTE_SPEEDUP_ITEM")
			else
				confirmTxt = pg.getGameString("INCUBATOR_CONFIRM_HAVE_SPEEDUP_DESC")
				confirmGray = true
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("家园孵化 - 选中某个加速道具显示加速信息 未获取到孵化信息 ornamentId=%s", self.m_ornamentId)
		end
	elseif self.m_rootPage == self.model.RootPage_Manger then
		local curHatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.m_ornamentId)

		if curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.CAN_PLACE then
			confirmTxt = pg.getGameString("INCUBATOR_CONFIRM_PLACE_EGG_DESC") or "INCUBATOR_CONFIRM_PLACE_EGG_DESC"
		elseif curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
			if isHasSelected then
				confirmTxt = pg.getGameString("INCUBATOR_CONFIRM_PLACE_EGG_DESC") or "INCUBATOR_CONFIRM_PLACE_EGG_DESC"
			else
				confirmTxt = pg.getGameString("HATCH_BTN_PAUSE") or "HATCH_BTN_PAUSE"
			end
		elseif curHatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
			confirmTxt = pg.getGameString("INCUBATOR_CONFIRM_PLACE_EGG_DESC") or "INCUBATOR_CONFIRM_PLACE_EGG_DESC"
		end
	end

	local isStartHatch = self.m_rootPage == self.model.RootPage_PutEgg or self.m_rootPage == self.model.RootPage_Manger

	if isStartHatch and isHasSelected and not self:m_checkSealedEggCanHatch(curSelectedItemData.id) then
		confirmTxt = nil
		tipsTxt = pg.getGameString("PET_RECEIVE_HATCH_TIP")
	end

	ClientTextUtils.setText(self.view.txtTiitleUSDFText, topTipPreTxt or "")
	ClientTextUtils.setText(self.view.txtNumUSDFText, topTipContTxt or "")
	self.view.btnConfirmUButton:SetActive(ToBool(confirmTxt))
	self.view.btnConfirmUButton:TryChangePage("button", ToBool(confirmGray) and 4 or 0)
	ClientTextUtils.setText(self.view.txtBtnConfirmNameUSDFText, confirmTxt or "")
	self.view.tipsUWidget:SetActive(ToBool(tipsTxt))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, tipsTxt or "")

	if self.view.activityUButton then
		local isPetHatchOpen = ClientActivityUtils.isPetHatchActivityOpen()

		self.view.activityUButton:SetActive(ToBool(confirmTxt) and isPetHatchOpen)
	end

	if self.view.txtActivityUp then
		local rate = ClientActivityUtils.getPetHatchActivityUpTimeRata()

		ClientTextUtils.setText(self.view.txtActivityUp, pg.getFormatText(pg.getGameString("INCUBATE_PERCENT"), rate))
	end

	if self.view.speedUpUWidget then
		self.view.speedUpUWidget:SetActive(ToBool(confirmTxt) and isActivated)
	end

	if self.view.txtSpeedUp then
		local time = ClientActivityUtils.getMonthCardSpeedupHatchTime()

		ClientTextUtils.setText(self.view.txtSpeedUp, pg.getFormatText(pg.getGameString("INCUBATE_MINUTE"), time))
	end
end

function IncubatorCtrl:onClickClose()
	self:close()
end

function IncubatorCtrl:onClickPause()
	HomeLandUtils.showPauseHatchConfirm(function()
		HomeLandUtils.tryPauseCurHatch(self.m_ornamentId)
	end)
end

function IncubatorCtrl:onClickSortOrFilter()
	self.model:reverseSetHatchDescending()
	self:refreshSortOption()
end

function IncubatorCtrl:m_checkSealedEggCanHatch(itemId)
	if not itemId or not Utils.isSealedPetEgg(itemId) then
		return true
	end

	return LuaUIUtils.checkSealedEggCanHatch(itemId)
end

function IncubatorCtrl:onClickConfirm()
	local selectedItem = self.model:getSelectedItemData()
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(self.m_ornamentId)
	local isStartHatch = self.m_rootPage == self.model.RootPage_PutEgg or self.m_rootPage == self.model.RootPage_Manger

	if isStartHatch and selectedItem and not self:m_checkSealedEggCanHatch(selectedItem.id) then
		return
	end

	local isSuccess = true

	if self.m_rootPage == self.model.RootPage_PutEgg and selectedItem then
		self.m_homeSpace:reqStartHatchPetEgg(self.m_ornamentId, selectedItem.id, selectedItem.genId)
	elseif self.m_rootPage == self.model.RootPage_SpeedUp and selectedItem then
		if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
			isSuccess = HomeLandUtils.trySpeedUpHatchBox(self.m_ornamentId, selectedItem.id, selectedItem.genId, true)
		else
			isSuccess = true
		end
	elseif self.m_rootPage == self.model.RootPage_Manger then
		isSuccess = HomeLandUtils.tryChangeHatchBoxEgg(self.m_ornamentId, selectedItem and selectedItem.id, selectedItem and selectedItem.genId)
	end

	if isSuccess then
		self:close()
	end
end

return IncubatorCtrl
