-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetHatchComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local PetFertilityConst = require("Const.PetFertilityConst")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local PetHatchComponent = Class.LightClass("PetHatchComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local AudioConst = require("Const.AudioConst")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CashShopConst = require("Const.CashShopConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LS_PRESS_BIND_NAME = "petHatchLSPress"
local ID_DETAIL_UWIDGET_MOVE = "detailUWidgetMove"
local ID_DETAIL_UWIDGET_SCALE = "detailUWidgetScale"

PetHatchComponent.MAX_SLOT_COUNT = 7
PetHatchComponent.RIGHT_INFO_TYPE = {
	EGG_HATCHED_INFO = 3,
	EGG_HATCHING_INFO = 2,
	EGG_UNHATCH_INFO = 1
}
PetHatchComponent.messages = {
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onRefreshTabList",
		true
	},
	[MessageName.MONTH_CARD_ACTIVATE] = {
		"onRefreshTabList",
		true
	}
}
PetHatchComponent.MOVE_COE = {
	DEFAULT = Vector3(1, 1, 1),
	LARGER = Vector3(2, 2, 1)
}
PetHatchComponent.SPECIAL_HATCH_INDEX = 1
PetHatchComponent.VISIBLE_HATCH_INDICES = {
	1,
	3,
	6
}
PetHatchComponent.VISIBLE_HATCH_INDEX_SET = {
	true,
	nil,
	true,
	nil,
	nil,
	true
}
PetHatchComponent.OUTER_HATCH_INDICES = {
	3,
	6
}

local rightInfoUnType = PetHatchComponent.RIGHT_INFO_TYPE.EGG_UNHATCH_INFO
local rightInfoHatchingType = PetHatchComponent.RIGHT_INFO_TYPE.EGG_HATCHING_INFO
local rightInfoHatchedType = PetHatchComponent.RIGHT_INFO_TYPE.EGG_HATCHED_INFO

function PetHatchComponent:_isHatchSlotVisible(index)
	return PetHatchComponent.VISIBLE_HATCH_INDEX_SET[index] == true
end

local function getActivityHatchSpeedTime(hatchInfo, itemId)
	local speedUpTime = hatchInfo and hatchInfo.speedUpTime
	local activitySpeed = speedUpTime and speedUpTime[Const.HatchSpeedUpReason.activty_petHatch]

	if activitySpeed and activitySpeed > 0 then
		return activitySpeed
	end

	local _, fixedSpeedUpTime = Utils.getFixedInitHatchTime(pg.me, itemId)

	return fixedSpeedUpTime and fixedSpeedUpTime[Const.HatchSpeedUpReason.activty_petHatch] or 0
end

local function setHatchCountDownL10nFunc(countDown)
	function countDown.onGetL10nFormatText(formatText)
		if not formatText then
			return ""
		end

		if string.find(formatText, "{0}", 1, true) then
			return ClientTextUtils.concatCountDownUnitsByLanguage("{0}", pg.getGameString("DAY"), "{1}", pg.getGameString("HOUR"))
		elseif string.find(formatText, "{1}", 1, true) then
			return ClientTextUtils.concatCountDownUnitsByLanguage("{1}", pg.getGameString("HOUR"), "{2}", pg.getGameString("MINUTE"))
		elseif string.find(formatText, "{2}", 1, true) then
			return ClientTextUtils.concatCountDownUnitsByLanguage("{2}", pg.getGameString("MINUTE"), "{3}", pg.getGameString("SECOND"))
		end

		return ClientTextUtils.concatCountDownUnitsByLanguage("{3}", pg.getGameString("SECOND"))
	end
end

function PetHatchComponent:clearHatchSlotCountDownFormatTimer(index)
	if not self.hatchSlotCountDownFormatTimers then
		return
	end

	local timer = self.hatchSlotCountDownFormatTimers[index]

	if timer then
		TimerManager.removeTimer(timer)

		self.hatchSlotCountDownFormatTimers[index] = nil
	end
end

function PetHatchComponent:setHatchSlotCountDownTime(index, countDown, endTs)
	self:clearHatchSlotCountDownFormatTimer(index)

	local remainTime = endTs - Time.getSecond()

	if remainTime <= 0 then
		return
	end

	local dayL10n = pg.getGameString("DAY")
	local hourL10n = pg.getGameString("HOUR")
	local minuteL10n = pg.getGameString("MINUTE")
	local secondL10n = pg.getGameString("SECOND")
	local nextSwitchTime

	if remainTime >= 86400 then
		countDown.formatText = ClientTextUtils.concatCountDownUnitsByLanguage("{0}", dayL10n, "{1}", hourL10n)
		nextSwitchTime = remainTime - 86400 + 1
	elseif remainTime >= 3600 then
		countDown.formatText = ClientTextUtils.concatCountDownUnitsByLanguage("{1}", hourL10n, "{2}", minuteL10n)
		nextSwitchTime = remainTime - 3600 + 1
	elseif remainTime >= 60 then
		countDown.formatText = ClientTextUtils.concatCountDownUnitsByLanguage("{2}", minuteL10n, "{3}", secondL10n)
		nextSwitchTime = remainTime - 60 + 1
	else
		countDown.formatText = ClientTextUtils.concatCountDownUnitsByLanguage("{3}", secondL10n)
	end

	countDown:Play(remainTime)

	if nextSwitchTime then
		self.hatchSlotCountDownFormatTimers = self.hatchSlotCountDownFormatTimers or {}
		self.hatchSlotCountDownFormatTimers[index] = TimerManager.addTimer(nextSwitchTime, function()
			self.hatchSlotCountDownFormatTimers[index] = nil

			local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
			local hatchInfo = hatchSlotList and hatchSlotList[index]

			if hatchInfo and hatchInfo.status == Const.PET_BALL.HATCH_STATUS_START then
				self:setHatchSlotCountDownTime(index, countDown, hatchInfo.endTs)
			end
		end)
	end
end

function PetHatchComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.hiveCellEmpty01AUWidget = self.objectReference:GetRefValue("hiveCellEmpty01AUWidget")
	self.hiveCell01AUButton = self.objectReference:GetRefValue("hiveCell01AUButton")
	self.hiveCellEmpty02AUWidget = self.objectReference:GetRefValue("hiveCellEmpty02AUWidget")
	self.hiveCell02AUButton = self.objectReference:GetRefValue("hiveCell02AUButton")
	self.hiveCellEmpty03AUWidget = self.objectReference:GetRefValue("hiveCellEmpty03AUWidget")
	self.hiveCell03AUButton = self.objectReference:GetRefValue("hiveCell03AUButton")
	self.hiveCellEmpty04AUWidget = self.objectReference:GetRefValue("hiveCellEmpty04AUWidget")
	self.hiveCell04AUButton = self.objectReference:GetRefValue("hiveCell04AUButton")
	self.hiveCellEmpty05AUWidget = self.objectReference:GetRefValue("hiveCellEmpty05AUWidget")
	self.hiveCell05AUButton = self.objectReference:GetRefValue("hiveCell05AUButton")
	self.hiveCellEmpty06AUWidget = self.objectReference:GetRefValue("hiveCellEmpty06AUWidget")
	self.hiveCell06AUButton = self.objectReference:GetRefValue("hiveCell06AUButton")
	self.hiveCellEmpty07AUWidget = self.objectReference:GetRefValue("hiveCellEmpty07AUWidget")
	self.hiveCell07AUButton = self.objectReference:GetRefValue("hiveCell07AUButton")
	self.txtNameUText = self.objectReference:GetRefValue("txtNameUText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.bgNormalUImage = self.objectReference:GetRefValue("bgNormalUImage")
	self.petIcon = self.objectReference:GetRefValue("petIcon")
	self.eggPanelUComponent = self.objectReference:GetRefValue("eggPanelUComponent")
	self.root = self.objectReference:GetRefValue("root")
	self.btnStartUButton = self.objectReference:GetRefValue("btnStartUButton")
	self.eggListUList = self.objectReference:GetRefValue("eggListUList")
	self.btnStopUButton = self.objectReference:GetRefValue("btnStopUButton")
	self.btnSpeedUpUButton = self.objectReference:GetRefValue("btnSpeedUpUButton")
	self.selectorUSelector = self.objectReference:GetRefValue("selectorUSelector")
	self.btnSortUButton = self.objectReference:GetRefValue("btnSortUButton")
	self.selectorTxtNameUBaseText = self.objectReference:GetRefValue("selectorTxtNameUBaseText")
	self.detailUWidget = self.objectReference:GetRefValue("detailUWidget")
	self.vXSelectTransform = self.objectReference:GetRefValue("vXSelectTransform")
	self.vXSelectAnimation = self.objectReference:GetRefValue("vXSelectAnimation")
	self.hiveBarUComponent = self.objectReference:GetRefValue("hiveBarUComponent")
	self.newRightInfoUComponent = self.objectReference:GetRefValue("newRightInfoUComponent")
	self.propInfoUContainer = self.objectReference:GetRefValue("propInfoUContainer")
	self.newBtnStartUButton = self.objectReference:GetRefValue("newBtnStartUButton")
	self.newBtnStopUButton = self.objectReference:GetRefValue("newBtnStopUButton")
	self.newBtnStartTxtNameUText = nil
	self.newBtnStartOriginalTextId = nil
	self.newBtnStartOriginalText = nil

	local newBtnStartObjectReference = self.newBtnStartUButton:GetComponent("ObjectReference")

	if not IsNil(newBtnStartObjectReference) then
		self.newBtnStartTxtNameUText = newBtnStartObjectReference:GetRefValue("txtNameUText")

		if not IsNil(self.newBtnStartTxtNameUText) then
			self.newBtnStartOriginalTextId = self.newBtnStartTxtNameUText.textId
			self.newBtnStartOriginalText = self.newBtnStartTxtNameUText.text
		end
	end

	self.newBtnSpeedUpUButton = self.objectReference:GetRefValue("newBtnSpeedUpUButton")
	self.hatchLockedCells = {
		self.hiveCellEmpty01AUWidget,
		self.hiveCellEmpty02AUWidget,
		self.hiveCellEmpty03AUWidget,
		self.hiveCellEmpty04AUWidget,
		self.hiveCellEmpty05AUWidget,
		self.hiveCellEmpty06AUWidget,
		self.hiveCellEmpty07AUWidget
	}
	self.hatchValidCells = {
		self.hiveCell01AUButton,
		self.hiveCell02AUButton,
		self.hiveCell03AUButton,
		self.hiveCell04AUButton,
		self.hiveCell05AUButton,
		self.hiveCell06AUButton,
		self.hiveCell07AUButton
	}
	self.activityUButton = self.objectReference:GetRefValue("activityUButton")
	self.txtActivityUp = self.objectReference:GetRefValue("txtActivityUp")
	self.speedUpUWidget = self.objectReference:GetRefValue("speedUpUWidget")
	self.txtSpeedUp = self.objectReference:GetRefValue("txtSpeedUp")
	self.speedTipsUButton = self.objectReference:GetRefValue("speedTipsUButton")
	self.txtSpeedTips = self.objectReference:GetRefValue("txtSpeedTips")

	self:onRefreshSpeedState()

	if self.speedTipsUButton then
		function self.speedTipsUButton.luaRenderTooltip(_, tooltip)
			local isActivated = MonthCardUtils.isActivated()
			local objectReference = tooltip:GetComponent("ObjectReference")
			local btnUpUButton = objectReference:GetRefValue("btnUpUButton")
			local txtDesc = objectReference:GetRefValue("txtDesc")
			local btnNameUSDFText = objectReference:GetRefValue("btnNameUSDFText")

			tooltip:TryChangePage("Btn", isActivated and 0 or 1)
			tooltip:TryChangePage("headTitle", 0)

			local tipKey = isActivated and "INCUBATE_MONTHLY_ACTIVATED_INFO" or "INCUBATE_MONTHLY_UNACTIVATED_INFO"
			local time = ClientActivityUtils.getMonthCardSpeedupHatchTime()

			ClientTextUtils.setText(txtDesc, pg.getFormatText(pg.getGameString(tipKey), time))
			ClientTextUtils.setText(btnNameUSDFText, pg.getGameString("INCUBATE_MONTHLY_GO_TO"))

			function btnUpUButton.luaClick()
				self.speedTipsUButton:CloseTooltip()
				pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
					tabId = CashShopConst.CategoryType.MONTHLYCARD
				})
			end
		end

		function self.speedTipsUButton.luaClick()
			self.speedTipsUButton:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)
		end
	end

	self.notAchievedUWidget = self.objectReference:GetRefValue("notAchievedUWidget")
	self.imgBgRequireUImage = self.objectReference:GetRefValue("imgBgRequireUImage")
	self.textRequireUSDFText = self.objectReference:GetRefValue("textRequireUSDFText")
end

function PetHatchComponent:initView()
	for _, cell in ipairs(self.hatchValidCells) do
		local objectReference = cell:GetComponent("ObjectReference")
		local countDown = objectReference:GetRefValue("countDownUCountDown")
		local countDownSpeed = objectReference:GetRefValue("countDownSpeedUComponent")
		local previewCountDown = objectReference:GetRefValue("previewCD")

		if countDown and countDown.title then
			countDown.title.disabledLocalization = true
			countDown.title.textId = ""
			countDown.title.text = ""

			setHatchCountDownL10nFunc(countDown)
		end

		if countDownSpeed and countDownSpeed.title then
			countDownSpeed.title.disabledLocalization = true
			countDownSpeed.title.textId = ""
			countDownSpeed.title.text = ""

			setHatchCountDownL10nFunc(countDownSpeed)
		end

		if previewCountDown and previewCountDown.title then
			previewCountDown.title.disabledLocalization = true
			previewCountDown.title.textId = ""
			previewCountDown.title.text = ""

			setHatchCountDownL10nFunc(previewCountDown)
		end
	end

	function self.eggListUList.luaRenderItem(button, index, data)
		self:renderEggItem(button, index, data)
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaHotkeyActivationChangedListener(LS_PRESS_BIND_NAME, function()
			local navMgr = pg.global.navMgr

			if not navMgr then
				return
			end

			local newGroup = navMgr.CurrentFocusedGroupName
			local oldGroup = self._hatchListenerLastGroup

			self._hatchListenerLastGroup = newGroup

			local newIsHatch = newGroup == "HiveCellHex" or newGroup == "HiveCellSpecial" or newGroup == "ListEgg"
			local oldIsHatch = oldGroup == "HiveCellHex" or oldGroup == "HiveCellSpecial" or oldGroup == "ListEgg"

			if not newIsHatch then
				return
			end

			if oldIsHatch then
				return
			end

			self:tryFocusFirstHatchedEggSlot()
		end)
	end
end

function PetHatchComponent:destroy()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener(LS_PRESS_BIND_NAME)
	end

	self.curSelectedSlotIndex = nil

	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.PET_BALL_UI)
end

function PetHatchComponent:_invalidateTempShowPreviews(cancelImageLoad)
	self._tempShowToken = (self._tempShowToken or 0) + 1

	local hatchSlotList

	if cancelImageLoad and self.model and self.ctrl and self.ctrl.info and pg.space and pg.me then
		hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	end

	for index, cell in pairs(self.hatchValidCells or {}) do
		cell:TryChangePage("TempShow", 0)

		local slot = hatchSlotList and hatchSlotList[index]

		if cancelImageLoad and slot and slot.status == Const.PET_BALL.HATCH_STATUS_INIT then
			local objectReference = cell:GetComponent("ObjectReference")
			local previewEgg = objectReference:GetRefValue("previewEgg")

			if NotNil(previewEgg) then
				previewEgg.url = nil
			end
		end
	end
end

function PetHatchComponent:tempShowEggRemainTimes(forbidShowNew)
	self:_invalidateTempShowPreviews(false)

	local myToken = self._tempShowToken

	if forbidShowNew or self._isParentVisible == false then
		return
	end

	if self.curSelectedSlotIndex and self.curSelectedLeftEggInfo then
		local slotIdx = self.curSelectedSlotIndex
		local cell = self.hatchValidCells and self.hatchValidCells[slotIdx]

		if not cell then
			return
		end

		local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
		local slot = hatchSlotList and hatchSlotList[slotIdx]

		if not slot or slot.status ~= Const.PET_BALL.HATCH_STATUS_INIT then
			return
		end

		local objectReference = cell:GetComponent("ObjectReference")
		local previewCD = objectReference:GetRefValue("previewCD")
		local countDownSpeedUComponent = objectReference:GetRefValue("countDownSpeedUComponent")
		local previewEgg = objectReference:GetRefValue("previewEgg")
		local previewIcon = self.curSelectedLeftEggInfo.icon
		local previewDuration = self.curSelectedLeftEggInfo.duration

		if not previewIcon then
			return
		end

		local hasSpeed = self.curSelectedLeftEggInfo.hatchSpeed
		local cd = hasSpeed and countDownSpeedUComponent or previewCD

		local function isRequestValid()
			if myToken ~= self._tempShowToken or self._isParentVisible == false then
				return false
			end

			if self.curSelectedSlotIndex ~= slotIdx then
				return false
			end

			if not self.curSelectedLeftEggInfo or self.curSelectedLeftEggInfo.icon ~= previewIcon then
				return false
			end

			local currentHatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
			local currentSlot = currentHatchSlotList and currentHatchSlotList[slotIdx]

			return currentSlot and currentSlot.status == Const.PET_BALL.HATCH_STATUS_INIT
		end

		local function refreshPreviewCountDown()
			previewCD:SetActive(not hasSpeed)
			countDownSpeedUComponent:SetActive(hasSpeed)
			LuaUIUtils.setCountDownTime(cd, previewDuration, nil, nil, nil, true)
			cd:Reset(previewDuration, previewDuration)
		end

		local previewTitleReactivateInterval = 0.1
		local previewTitleReactivateRounds = 1

		local function schedulePreviewTitleReactivation(round)
			TimerManager.addTimer(previewTitleReactivateInterval, function()
				if not isRequestValid() then
					return
				end

				refreshPreviewCountDown()

				local title = cd.title

				if IsNil(title) or IsNil(title.gameObject) then
					return
				end

				local titleGameObject = title.gameObject

				titleGameObject:SetActiveEx(false)
				TimerManager.addNextFrameCb(function()
					if NotNil(titleGameObject) then
						titleGameObject:SetActiveEx(true)
					end

					if not isRequestValid() then
						return
					end

					refreshPreviewCountDown()

					if round < previewTitleReactivateRounds then
						schedulePreviewTitleReactivation(round + 1)
					end
				end)
			end)
		end

		previewEgg.url = nil

		previewEgg:SetUrlWithCallback(previewIcon, function()
			if not isRequestValid() then
				return
			end

			local title = cd.title

			if NotNil(title) then
				title.renderOpacity = 0

				TimerManager.addTimer(0.2, function()
					if NotNil(title) then
						title.renderOpacity = 1
					end
				end)
			end

			cell:TryChangePage("TempShow", 1)
			refreshPreviewCountDown()
			schedulePreviewTitleReactivation(1)
		end, nil, true)
	end
end

function PetHatchComponent:renderEggItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local disabledUImage = objectReference:GetRefValue("disabledUImage")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")

	button.draggable = false

	button:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUText, data.count)

	local needBlock = self:_isEggQualityBlockedBySlot(self.curSelectedSlotIndex, data)

	disabledUImage.gameObject:SetActiveEx(data.isHatching or needBlock)

	local isLock = data.isLock

	stateLockUWidget.gameObject:SetActiveEx(isLock)

	needBlock = needBlock or isLock

	function button.luaPress()
		if self:_isCurSelectedSlotBusy() then
			return
		end

		local curNeedBlock = self:_isEggQualityBlockedBySlot(self.curSelectedSlotIndex, data) or isLock

		if not curNeedBlock then
			self:_selectEggLocally(data)
		elseif isLock then
			pg.global.ui.tips:showTextTipById(NoticeDef.HATCH_EGG_LOCK)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("PETBALL_HATCH_CENTER_BAN_NORMALEGG"))
		end
	end
end

function PetHatchComponent:_isCurSelectedSlotBusy()
	if not self.curSelectedSlotIndex then
		return false
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList then
		return false
	end

	local slot = hatchSlotList[self.curSelectedSlotIndex]

	if not slot then
		return false
	end

	return slot.status == Const.PET_BALL.HATCH_STATUS_START or slot.status == Const.PET_BALL.HATCH_STATUS_SUCC
end

function PetHatchComponent:renderHatchSlotItem()
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	self.curSelectedSlotIndex = nil

	for i = 1, PetHatchComponent.MAX_SLOT_COUNT do
		self:refreshSingleHatchSlot(i, hatchSlotList)
	end
end

function PetHatchComponent:refreshSingleHatchSlot(index, hatchSlotList)
	if not self:_isHatchSlotVisible(index) then
		self:clearHatchSlotCountDownFormatTimer(index)
		self.hatchLockedCells[index].gameObject:SetActiveEx(false)
		self.hatchValidCells[index].gameObject:SetActiveEx(false)

		self.hatchLockedCells[index].luaPress = nil
		self.hatchValidCells[index].luaPress = nil
		self.hatchValidCells[index].luaSelectChanged = nil
		self.hatchValidCells[index].isSelected = false

		return
	end

	local totalCount = #hatchSlotList

	self.hatchLockedCells[index].gameObject:SetActiveEx(true)
	self.hatchLockedCells[index]:TryChangePage("hideLockIcon", index <= totalCount and 1 or 0)
	self.hatchValidCells[index].gameObject:SetActiveEx(index <= totalCount)

	self.hatchLockedCells[index].luaPress = function()
		if index <= totalCount then
			return
		end

		self:displayEggPanel(false)
		self:displayInfoPanel(false)
		self:moveToCellSmoothly(nil, false)
	end

	if index <= totalCount then
		local hatchInfo = hatchSlotList[index]
		local status = hatchInfo.status

		if status ~= Const.PET_BALL.HATCH_STATUS_START then
			self:clearHatchSlotCountDownFormatTimer(index)
		end

		if status == Const.PET_BALL.HATCH_STATUS_INIT then
			self.hatchValidCells[index]:TryChangePage("EggState", 0)
		elseif status == Const.PET_BALL.HATCH_STATUS_START then
			self.hatchValidCells[index]:TryChangePage("TempShow", 0)
			self.hatchValidCells[index]:TryChangePage("EggState", 1)

			local objectReference = self.hatchValidCells[index]:GetComponent("ObjectReference")
			local eggUImage = objectReference:GetRefValue("eggUImage")
			local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
			local countDownSpeedUComponent = objectReference:GetRefValue("countDownSpeedUComponent")
			local slotData = self.model:getHatchSlotEggItemInfo(hatchInfo)

			eggUImage.url = slotData.icon

			local activitySpeed = getActivityHatchSpeedTime(hatchInfo, slotData.id)
			local isSpeed = activitySpeed and activitySpeed > 0
			local ts = hatchInfo.endTs

			countDownUCountDown:SetActive(not isSpeed)
			countDownSpeedUComponent:SetActive(isSpeed)

			local countDown = isSpeed and countDownSpeedUComponent or countDownUCountDown

			self:setHatchSlotCountDownTime(index, countDown, ts)
		elseif status == Const.PET_BALL.HATCH_STATUS_SUCC then
			self.hatchValidCells[index]:TryChangePage("EggState", 2)

			local objectReference = self.hatchValidCells[index]:GetComponent("ObjectReference")
			local egg1UImage = objectReference:GetRefValue("egg1UImage")

			egg1UImage.url = self.model:getHatchSlotEggItemInfo(hatchInfo).icon
		end
	end

	local button = self.hatchValidCells[index]

	self.hatchValidCells[index].luaSelectChanged = function(v)
		local state = v == true and 1 or 0

		button:TryChangePage("Select", state)
	end
	self.hatchValidCells[index].luaPress = function()
		local hatchSlot = hatchSlotList[index]
		local statusCur = hatchSlot.status

		if self.curSelectedSlotIndex == index and statusCur == Const.PET_BALL.HATCH_STATUS_INIT then
			return
		end

		if self.curSelectedSlotIndex and self.curSelectedSlotIndex ~= index then
			self.hatchValidCells[self.curSelectedSlotIndex].isSelected = false
		end

		self.hatchValidCells[index].isSelected = true
		self.curSelectedSlotIndex = index

		if statusCur == Const.PET_BALL.HATCH_STATUS_INIT then
			self:displayEggPanel(true)

			local found = self:_ensureCompatibleEgg()

			if not found then
				self.curSelectedLeftEggInfo = nil

				self:tempShowEggRemainTimes(true)
			end

			self:_updateEggButtonHighlight()

			if pg.game.input:isUsingGamepad() then
				self._gamepadReturnSlotIndex = index
				self._pendingFocusEggListForGamepad = true

				self:_scheduleFocusEggListForGamepad()
			end
		elseif statusCur == Const.PET_BALL.HATCH_STATUS_START then
			if self:_hasAnyInitSlot() then
				self:displayEggPanel(true)
			else
				self.root:TryChangePage("HiveSelect", 0)
			end

			self:displayInfoPanel(true, rightInfoHatchingType, self.model:getHatchSlotEggItemInfo(hatchSlot), index)

			self._curSelectedEggData = nil
			self.curSelectedLeftEggInfo = nil

			self:tempShowEggRemainTimes(true)
			self:_updateEggButtonHighlight()
			self:_refreshStartBtn()
		elseif statusCur == Const.PET_BALL.HATCH_STATUS_SUCC then
			self.lastClickTime = Time.secondCache
			self._curSelectedEggData = nil
			self.curSelectedLeftEggInfo = nil

			self:tempShowEggRemainTimes(true)
			self:_updateEggButtonHighlight()
			self:_refreshStartBtn()
			self:showCompletedEggDetail(index)
		end
	end
end

function PetHatchComponent:showCompletedEggDetail(slotIndex)
	if not self:_isHatchSlotVisible(slotIndex) then
		return false
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local hatchSlotInfo = hatchSlotList and hatchSlotList[slotIndex]

	if hatchSlotInfo and hatchSlotInfo.status == Const.PET_BALL.HATCH_STATUS_SUCC then
		local itemInfo = self.model:getHatchSlotEggItemInfo(hatchSlotInfo)

		if itemInfo then
			self:displayInfoPanel(true, rightInfoHatchedType, itemInfo, slotIndex)

			return true
		end
	end

	if hatchSlotInfo then
		self:refreshSingleHatchSlot(slotIndex, hatchSlotList)
	end

	self:_forceHideInfoPanel()

	return false
end

function PetHatchComponent:onClickChooseCompletedEgg(slotIndex)
	local isCompletedDetailShown = self:showCompletedEggDetail(slotIndex)

	if not isCompletedDetailShown then
		return
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local hatchSlotInfo = hatchSlotList and hatchSlotList[slotIndex]

	if not hatchSlotInfo or hatchSlotInfo.status ~= Const.PET_BALL.HATCH_STATUS_SUCC then
		if hatchSlotInfo then
			self:refreshSingleHatchSlot(slotIndex, hatchSlotList)
		end

		self:_forceHideInfoPanel()

		return
	end

	self:openChooseBallPanel(slotIndex)
end

function PetHatchComponent:openChooseBallPanel(slotIndex)
	if not self:_isHatchSlotVisible(slotIndex) then
		return
	end

	if pg.space:isGrabEgg() then
		pg.game.uiScene:setMainSceneActive(true)

		return
	end

	local envObjTemId, eggPrefabResID = Utils.getEggBindingSceneObjectId(slotIndex, PetFertilityConst.fallbackEggResId)

	if not eggPrefabResID or eggPrefabResID == "" then
		return
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local slotInfo = hatchSlotList and hatchSlotList[slotIndex]
	local eggItemId = slotInfo and slotInfo.item and slotInfo.item.id or 0

	if eggItemId <= 0 then
		return
	end

	local eggInfo = {
		templateId = envObjTemId,
		eggItemId = eggItemId,
		prefabResID = eggPrefabResID
	}
	local cubeChooseInfo = {
		eggItemId = eggInfo.eggItemId,
		slotIndex = slotIndex,
		onConfirm = function(cubeItemId)
			self:takeHatchEgg(slotIndex, cubeItemId)
		end,
		onCancel = function(isSourceJump)
			if isSourceJump then
				self:_forceHideInfoPanel()

				return
			end

			pg.game.uiScene:setMainSceneActive(true)
			self:showCompletedEggDetail(slotIndex)
		end
	}

	pg.game.soulEggEvolution:startSoulEggChooseCube(eggInfo, cubeChooseInfo)
end

function PetHatchComponent:takeHatchEgg(slotIndex, cubeItemId)
	if not self:_isHatchSlotVisible(slotIndex) then
		return
	end

	local epoch = pg.game.soulEggEvolution and pg.game.soulEggEvolution:getChooseEpoch() or 0

	pg.me:serverMsg("RPC_CS_GetHatchPetEgg", slotIndex, cubeItemId, function(noticeId, noticeArg)
		if noticeId ~= NoticeDef.SUCCESS then
			if pg.game and pg.game.soulEggEvolution then
				pg.game.soulEggEvolution:discardPendingHatchRequest(epoch)
			end

			pg.global.showBubbleMessage(noticeId)

			if pg.game and pg.game.soulEggEvolution and pg.game.soulEggEvolution:getChooseEpoch() == epoch then
				pg.game.soulEggEvolution:cancelChooseCube()

				if pg.game.uiScene then
					pg.game.uiScene:setMainSceneActive(true)
				end
			end

			return
		end
	end)
end

function PetHatchComponent:openHatchPanel()
	self.model:setHatchSortId(1)
	self.model:setHatchDescending(true)
	self:refreshSortOption()
	self:renderHatchSlotItem()

	self._gamepadReturnSlotIndex = nil
	self._pendingFocusEggListForGamepad = false

	local isGamepad = pg.game.input:isUsingGamepad()

	if isGamepad then
		self.root:TryChangePage("HiveSelect", 0)
		self:_forceHideInfoPanel()
		self.root:TryChangePage("EggSelect", 0)
		self:moveToCellSmoothly(nil, false)
		self:_focusInitialHatchSlot()
	else
		self:displayEggPanel(true)
		self:_forceHideInfoPanel()
		self:moveToCellSmoothly(nil, false)
		self:_autoSelectFirstSlotAndEgg()
	end

	pg.game.audio:playBgm("BGM_UI_Incubate_Loop", AudioConst.BgmPriority.PET_BALL_UI)

	local vxT = self.transform:Find("Hive/Detail/VxHiveCellEffect")
	local ani = vxT and vxT:GetComponent("Animation")

	if ani then
		UIUtils.PlayAnimation(ani, "VX_Node_PanelHatch_Hive_Detail_HexCenter", function()
			local hexT = self.transform:Find("Hive/Detail/VxHiveCellEffect/HiveCellHex")
			local hexUWidget = hexT and hexT:GetComponent("UWidget")

			if hexUWidget then
				hexUWidget:RefreshNavGroupHotkeyVisible()
			end
		end)
	end
end

function PetHatchComponent:_findSpecialInitSlot(hatchSlotList, skipIdx)
	if skipIdx == PetHatchComponent.SPECIAL_HATCH_INDEX then
		return nil
	end

	local slot = hatchSlotList and hatchSlotList[PetHatchComponent.SPECIAL_HATCH_INDEX]

	if slot and slot.status == Const.PET_BALL.HATCH_STATUS_INIT then
		return PetHatchComponent.SPECIAL_HATCH_INDEX
	end

	return nil
end

function PetHatchComponent:_findNextOuterInitSlot(fromIdx, hatchSlotList)
	if not hatchSlotList then
		return nil
	end

	local outerIndices = PetHatchComponent.OUTER_HATCH_INDICES
	local startOrder = 1

	if fromIdx then
		for orderIdx, slotIdx in ipairs(outerIndices) do
			if slotIdx == fromIdx then
				startOrder = orderIdx % #outerIndices + 1

				break
			end
		end
	end

	for offset = 0, #outerIndices - 1 do
		local orderIdx = (startOrder - 1 + offset) % #outerIndices + 1
		local idx = outerIndices[orderIdx]
		local slot = hatchSlotList[idx]

		if idx ~= fromIdx and slot and slot.status == Const.PET_BALL.HATCH_STATUS_INIT then
			return idx
		end
	end

	return nil
end

function PetHatchComponent:_pickInitialFocusSlotIndex()
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList or #hatchSlotList <= 0 then
		return 1
	end

	return self:_findNextOuterInitSlot(nil, hatchSlotList) or self:_findSpecialInitSlot(hatchSlotList) or 1
end

function PetHatchComponent:_focusInitialHatchSlot()
	local idx = self:_pickInitialFocusSlotIndex()

	TimerManager.addNextFrameCb(function()
		local navMgr = pg.global.navMgr

		if not navMgr then
			return
		end

		local cell = self.hatchValidCells and self.hatchValidCells[idx]

		if cell then
			navMgr:FocusItem(cell)
		end
	end)
end

function PetHatchComponent:_autoSelectFirstSlotAndEgg()
	if self:_refreshHatchingMode() then
		self._pendingAutoSelectEgg = false

		return
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local firstNormalInit = self:_findNextOuterInitSlot(nil, hatchSlotList)
	local firstSpecialInit = self:_findSpecialInitSlot(hatchSlotList)
	local firstEgg = self:_findFirstAvailableEgg()
	local firstSpecialEgg = self:_findFirstAvailableEgg(5)
	local slotPick, eggPick

	if firstNormalInit and firstEgg then
		slotPick, eggPick = firstNormalInit, firstEgg
	elseif firstSpecialInit and firstSpecialEgg then
		slotPick, eggPick = firstSpecialInit, firstSpecialEgg
	end

	if slotPick and eggPick then
		self:_selectHatchSlotLocally(slotPick)
		self:_selectEggLocally(eggPick)

		self._pendingAutoSelectEggData = eggPick
	else
		local fallbackInit = firstNormalInit or firstSpecialInit

		if fallbackInit then
			self:_selectHatchSlotLocally(fallbackInit)
		end

		self.curSelectedLeftEggInfo = nil

		self:tempShowEggRemainTimes(true)
		self:_forceHideInfoPanel()
	end

	self._pendingAutoSelectEgg = slotPick and eggPick and true or nil
end

function PetHatchComponent:_forceHideInfoPanel()
	self._propInfoRenderToken = (self._propInfoRenderToken or 0) + 1

	self.root:TryChangePage("EggSelect", 0)

	self.rightInfoPanelCurHatchSlotIndex = nil
	self.curRightInfoPanelType = nil
	self._curSelectedEggData = nil

	self:_refreshSealedEggHatchState(nil)
	self:_refreshStartBtn()
end

function PetHatchComponent:_isEggQualityBlockedBySlot(slotIdx, eggData)
	if pg.space:isGrabEgg() then
		return false
	end

	if not slotIdx or not eggData then
		return false
	end

	return slotIdx == PetHatchComponent.SPECIAL_HATCH_INDEX and (eggData.quality or 0) < 5
end

function PetHatchComponent:_isSlotEggBlocked(slotIdx, eggData)
	if pg.space:isGrabEgg() then
		return false
	end

	if not slotIdx or not eggData then
		return true
	end

	if (eggData.count or 0) <= 0 then
		return true
	end

	if self:_isEggQualityBlockedBySlot(slotIdx, eggData) then
		return true
	end

	return false
end

function PetHatchComponent:_refreshStartBtn()
	if not self.newBtnStartUButton then
		return
	end

	local blocked = self:_isSlotEggBlocked(self.curSelectedSlotIndex, self._curSelectedEggData)

	self.newBtnStartUButton.visualInteractable = not blocked
end

function PetHatchComponent:_checkSealedEggCanHatch(eggData)
	if not eggData or not Utils.isSealedPetEgg(eggData.id) then
		return true
	end

	return LuaUIUtils.checkSealedEggCanHatch(eggData.id)
end

function PetHatchComponent:_refreshSealedEggHatchState(eggData)
	local showNotAchieved = eggData and Utils.isSealedPetEgg(eggData.id) and not self:_checkSealedEggCanHatch(eggData)

	if not IsNil(self.notAchievedUWidget) then
		self.notAchievedUWidget:SetActive(ToBool(showNotAchieved))
	end

	if not IsNil(self.textRequireUSDFText) then
		ClientTextUtils.setText(self.textRequireUSDFText, showNotAchieved and pg.getGameString("PET_RECEIVE_HATCH_TIP") or "")
	end

	if eggData and not IsNil(self.newBtnStartUButton) then
		self.newBtnStartUButton:SetActive(not showNotAchieved)
	end
end

function PetHatchComponent:_updateEggButtonHighlight()
	local btns = self.eggListUList and self.eggListUList:GetAllButtons()

	if not btns or btns.Length <= 0 then
		return
	end

	local cur = self._curSelectedEggData

	for i = 0, btns.Length - 1 do
		local b = btns[i]
		local d = b.dataFromUList
		local matched = cur and d and d.id == cur.id and d.genId == cur.genId

		b.isSelected = matched and true or false

		b:TryChangePage("GamePadFocus", matched and 1 or 0)
	end
end

function PetHatchComponent:_ensureCompatibleEgg()
	if pg.space:isGrabEgg() then
		self:_refreshStartBtn()
		self:displayInfoPanel(false)

		return false
	end

	local cur = self._curSelectedEggData

	if cur and not self:_isSlotEggBlocked(self.curSelectedSlotIndex, cur) then
		self:_refreshStartBtn()
		self:displayInfoPanel(true, rightInfoUnType, self._curSelectedEggData, self.curSelectedSlotIndex)
		self:tempShowEggRemainTimes(false)

		return true
	end

	local minQuality = 0

	if self.curSelectedSlotIndex == PetHatchComponent.SPECIAL_HATCH_INDEX then
		minQuality = 5
	end

	local newEgg = self:_findFirstAvailableEgg(minQuality)

	if newEgg then
		self:_selectEggLocally(newEgg)

		return newEgg ~= nil
	end

	self.curSelectedLeftEggInfo = nil

	self:tempShowEggRemainTimes(true)
	self:_forceHideInfoPanel()

	return false
end

function PetHatchComponent:_findFirstAvailableEgg(minQuality)
	minQuality = minQuality or 0

	local list = self.model:getAllEggs()

	if not list then
		return nil
	end

	for _, eg in ipairs(list) do
		if not eg.isHatching and not eg.isLock and (eg.count or 0) > 0 and minQuality <= (eg.quality or 0) then
			return eg
		end
	end

	return nil
end

function PetHatchComponent:_hasAnyInitSlot()
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList then
		return false
	end

	for _, i in ipairs(PetHatchComponent.VISIBLE_HATCH_INDICES) do
		local slot = hatchSlotList[i]

		if slot and slot.status == Const.PET_BALL.HATCH_STATUS_INIT then
			return true
		end
	end

	return false
end

function PetHatchComponent:_hasUsableInitSlot()
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList then
		return false
	end

	local hasNormalInit, hasSpecialInit = false, false

	for _, i in ipairs(PetHatchComponent.VISIBLE_HATCH_INDICES) do
		local slot = hatchSlotList[i]

		if slot and slot.status == Const.PET_BALL.HATCH_STATUS_INIT then
			if i == PetHatchComponent.SPECIAL_HATCH_INDEX then
				hasSpecialInit = true
			else
				hasNormalInit = true
			end
		end
	end

	if not hasNormalInit and not hasSpecialInit then
		return false
	end

	if hasNormalInit and self:_findFirstAvailableEgg(0) then
		return true
	end

	if hasSpecialInit and self:_findFirstAvailableEgg(5) then
		return true
	end

	return false
end

function PetHatchComponent:_refreshHatchingMode()
	if self:_hasAnyInitSlot() then
		self.root:TryChangePage("HiveSelect", 1)

		return false
	end

	self.root:TryChangePage("HiveSelect", 0)

	self._curSelectedEggData = nil
	self.curSelectedLeftEggInfo = nil

	self:tempShowEggRemainTimes(true)
	self:_refreshStartBtn()

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId) or {}
	local cur = self.curSelectedSlotIndex
	local curIsStart = cur and self:_isHatchSlotVisible(cur) and hatchSlotList[cur] and hatchSlotList[cur].status == Const.PET_BALL.HATCH_STATUS_START

	if not curIsStart then
		if self.curSelectedSlotIndex and self.hatchValidCells[self.curSelectedSlotIndex] then
			self.hatchValidCells[self.curSelectedSlotIndex].isSelected = false
		end

		self.curSelectedSlotIndex = nil
		cur = nil

		for _, idx in ipairs(PetHatchComponent.VISIBLE_HATCH_INDICES) do
			local slot = hatchSlotList[idx]

			if slot and slot.status == Const.PET_BALL.HATCH_STATUS_START then
				self:_selectHatchSlotLocally(idx)

				cur = idx

				break
			end
		end
	end

	if cur and hatchSlotList[cur] and hatchSlotList[cur].status == Const.PET_BALL.HATCH_STATUS_START then
		local slotEggData = self.model:getHatchSlotEggItemInfo(hatchSlotList[cur])

		if slotEggData then
			self:displayInfoPanel(true, rightInfoHatchingType, slotEggData, cur)
		else
			self:_forceHideInfoPanel()
		end
	else
		self:_forceHideInfoPanel()
	end

	self:_scheduleFocusHatchingTargetForGamepad(cur)

	return true
end

function PetHatchComponent:_doAutoSelectFirstEgg()
	local eg = self._pendingAutoSelectEggData or self._curSelectedEggData

	if not eg then
		local minQuality = self.curSelectedSlotIndex == PetHatchComponent.SPECIAL_HATCH_INDEX and 5 or 0

		eg = self:_findFirstAvailableEgg(minQuality)
	end

	self._pendingAutoSelectEggData = nil

	if eg and not self:_isSlotEggBlocked(self.curSelectedSlotIndex, eg) then
		self:_selectEggLocally(eg)
	else
		self:_updateEggButtonHighlight()
		self:_refreshStartBtn()
	end
end

function PetHatchComponent:refreshEggListPanel()
	function self.eggListUList.luaFinishRender(_)
		self:_updateEggButtonHighlight()

		if self._pendingAutoSelectEgg then
			self._pendingAutoSelectEgg = nil

			self:_doAutoSelectFirstEgg()
		end
	end

	local data = self.model:getAllEggs()

	if not data or #data <= 0 then
		self.hiveBarUComponent:TryChangePage("Empty", 1)
	else
		self.hiveBarUComponent:TryChangePage("Empty", 0)
	end

	self.eggListUList:SetList(data)
end

function PetHatchComponent:onParentVisibleChange(visible)
	UIComponent.onParentVisibleChange(self, visible)

	local wasParentVisible = self._isParentVisible

	self._isParentVisible = visible

	if not visible then
		self:_invalidateTempShowPreviews(true)

		self._infoPanelPageToken = (self._infoPanelPageToken or 0) + 1

		return
	end

	if wasParentVisible == false then
		self:tempShowEggRemainTimes(false)
	end

	if not self._pendingFocusEggListOnVisible then
		return
	end

	self._pendingFocusEggListOnVisible = false

	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	if not self.curSelectedSlotIndex then
		return
	end

	self:displayEggPanel(true)
	self:_ensureCompatibleEgg()
	self:_updateEggButtonHighlight()

	self._pendingFocusEggListForGamepad = true

	self:_scheduleFocusEggListForGamepad()
end

function PetHatchComponent:_scheduleFocusEggListForGamepad()
	self._focusHatchingToken = (self._focusHatchingToken or 0) + 1
	self._focusEggToken = (self._focusEggToken or 0) + 1

	local myToken = self._focusEggToken

	TimerManager.addNextFrameCb(function()
		if myToken ~= self._focusEggToken then
			return
		end

		if not self._pendingFocusEggListForGamepad then
			return
		end

		self._pendingFocusEggListForGamepad = false

		self:_focusFirstValidEggButton()
	end)
end

function PetHatchComponent:_scheduleFocusHatchingTargetForGamepad(slotIdx)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	self._pendingFocusEggListForGamepad = false
	self._focusHatchingToken = (self._focusHatchingToken or 0) + 1

	local myToken = self._focusHatchingToken

	TimerManager.addNextFrameCb(function()
		if myToken ~= self._focusHatchingToken then
			return
		end

		self:_focusHatchingTarget(slotIdx)
	end)
end

function PetHatchComponent:_focusHatchingTarget(slotIdx)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	if not IsNil(self.newBtnStopUButton) and navMgr:FocusItem(self.newBtnStopUButton) then
		return
	end

	local cell = slotIdx and self.hatchValidCells and self.hatchValidCells[slotIdx]

	if cell and navMgr:FocusItem(cell) then
		return
	end

	for _, idx in ipairs(PetHatchComponent.VISIBLE_HATCH_INDICES) do
		local c = self.hatchValidCells and self.hatchValidCells[idx]

		if c and navMgr:FocusItem(c) then
			return
		end
	end
end

function PetHatchComponent:_focusFirstValidEggButton()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local btns = self.eggListUList and self.eggListUList:GetAllButtons()

	if not btns or btns.Length <= 0 then
		return
	end

	for i = 0, btns.Length - 1 do
		local b = btns[i]

		if b and navMgr:FocusItem(b) then
			return
		end
	end
end

function PetHatchComponent:refreshRightInfoPanel(panelType, data, hatchSlotIndex)
	if not data then
		return
	end

	if panelType ~= rightInfoUnType and panelType ~= rightInfoHatchingType and panelType ~= rightInfoHatchedType then
		return
	end

	self._propInfoRenderToken = (self._propInfoRenderToken or 0) + 1

	local renderToken = self._propInfoRenderToken
	local itemInfoData = {}

	for key, value in pairs(data) do
		itemInfoData[key] = value
	end

	itemInfoData.typeTextDisplacePropName = true

	function itemInfoData.validate()
		return self.ctrl ~= nil and self._propInfoRenderToken == renderToken
	end

	LuaUIUtils.renderItemInfo(self.propInfoUContainer, itemInfoData)

	self.rightInfoPanelCurHatchSlotIndex = hatchSlotIndex
	self.curRightInfoPanelType = panelType

	if panelType == rightInfoUnType then
		self.eggPanelUComponent:TryChangePage("PanelState", 0)
		self.newRightInfoUComponent:TryChangePage("HiveState", 0)

		if not IsNil(self.newBtnStartTxtNameUText) then
			if self.newBtnStartOriginalTextId and self.newBtnStartOriginalTextId ~= "" then
				ClientTextUtils.setTextWithId(self.newBtnStartTxtNameUText, self.newBtnStartOriginalTextId)
			elseif self.newBtnStartOriginalText then
				ClientTextUtils.setText(self.newBtnStartTxtNameUText, self.newBtnStartOriginalText)
			end
		end

		function self.newBtnStartUButton.luaClick()
			local fromSlotIdx = self.curSelectedSlotIndex

			if not fromSlotIdx then
				return
			end

			if not self:_checkSealedEggCanHatch(data) then
				return
			end

			if self:_isSlotEggBlocked(fromSlotIdx, data) then
				pg.global.ui.tips:showTextTip(pg.getGameString("PETBALL_HATCH_CENTER_BAN_NORMALEGG"))

				return
			end

			self:startHatchEgg(data)

			if pg.space:isGrabEgg() then
				self.ctrl:close()
			end
		end

		self:refreshSpeedUpInfo()
	elseif panelType == rightInfoHatchingType then
		self.eggPanelUComponent:TryChangePage("PanelState", 0)
		self.newRightInfoUComponent:TryChangePage("HiveState", 1)

		if not IsNil(self.newBtnStartUButton) then
			self.newBtnStartUButton:SetActive(false)
		end

		function self.newBtnStopUButton.luaClick()
			if not self.curSelectedSlotIndex then
				return
			end

			if not self:_isHatchSlotVisible(self.curSelectedSlotIndex) then
				return
			end

			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("STOP_HATCH_WARN"), function()
				local slotIdx = self.curSelectedSlotIndex

				if not self:_isHatchSlotVisible(slotIdx) then
					return
				end

				local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
				local slotInfo = hatchSlotList and hatchSlotList[slotIdx]
				local stoppedItem = slotInfo and slotInfo.item
				local stoppedEggKey = stoppedItem and {
					id = stoppedItem.id,
					genId = stoppedItem.genID
				}

				pg.me:serverMsg("RPC_CS_QuitHatchPetEgg", slotIdx, function(ret)
					if ret == 0 then
						self:_onHatchStopConfirmed(slotIdx, stoppedEggKey)
					end
				end)
			end, false, function()
				return
			end)
		end

		function self.newBtnSpeedUpUButton.luaClick()
			self.eggPanelUComponent:TryChangePage("PanelState", 1)
		end

		self.speedUpUWidget:SetActive(false)
	else
		self.eggPanelUComponent:TryChangePage("PanelState", 0)
		self.newRightInfoUComponent:TryChangePage("HiveState", 0)

		local completedSlotIndex = hatchSlotIndex

		if not IsNil(self.newBtnStartUButton) then
			self.newBtnStartUButton:SetActive(true)
		end

		self.newBtnStartUButton.visualInteractable = true

		if not IsNil(self.newBtnStartTxtNameUText) then
			ClientTextUtils.setText(self.newBtnStartTxtNameUText, pg.getGameString("PET_FERTILITY_SURE_LINK"))
		end

		function self.newBtnStartUButton.luaClick()
			self:onClickChooseCompletedEgg(completedSlotIndex)
		end

		self.speedUpUWidget:SetActive(false)
	end

	self:_refreshSealedEggHatchState(panelType == rightInfoUnType and data or nil)
end

function PetHatchComponent:refreshSpeedUpInfo()
	if self.activityUButton then
		local isPetHatchOpen = ClientActivityUtils.isPetHatchActivityOpen()

		self.activityUButton:SetActive(isPetHatchOpen)
	end

	if self.txtActivityUp then
		local rate = ClientActivityUtils.getPetHatchActivityUpTimeRata()

		ClientTextUtils.setText(self.txtActivityUp, pg.getFormatText(pg.getGameString("INCUBATE_PERCENT"), rate))
	end

	local isActivated = MonthCardUtils.isActivated()

	if self.speedUpUWidget then
		self.speedUpUWidget:SetActive(isActivated)
	end

	if self.txtSpeedUp then
		local time = ClientActivityUtils.getMonthCardSpeedupHatchTime()

		ClientTextUtils.setText(self.txtSpeedUp, pg.getFormatText(pg.getGameString("INCUBATE_MINUTE"), time))
	end

	self:onRefreshSpeedState()
end

function PetHatchComponent:onRefreshSpeedState()
	local isActivated = MonthCardUtils.isActivated()

	if self.speedTipsUButton then
		self.speedTipsUButton:SetActive(ClientCashShopUtils.canOpenCashShop())
		self.speedTipsUButton:TryChangePage("Monthcard", isActivated and 1 or 0)
	end

	if self.txtSpeedTips then
		local tipKey = isActivated and "INCUBATE_MONTHLY_ACTIVATED" or "INCUBATE_HOW_TO_ACCELERATE"

		ClientTextUtils.setText(self.txtSpeedTips, pg.getGameString(tipKey))
	end
end

function PetHatchComponent:onRefreshTabList()
	if self.curRightInfoPanelType ~= rightInfoUnType then
		return
	end

	self:refreshSpeedUpInfo()
end

function PetHatchComponent:startHatchEgg(data)
	if pg.space:isGrabEgg() then
		local info = self.ctrl.info

		pg.me:grabEgg_startHatchEgg(info.spawnerId, info.targetId, data.genId)

		return
	end

	local fromSlotIdx = self.curSelectedSlotIndex

	if not self:_isHatchSlotVisible(fromSlotIdx) then
		return
	end

	pg.me:serverMsg("RPC_CS_StartHatchPetEgg", data.id, data.genId, fromSlotIdx, function(ret)
		if ret == NoticeDef.SUCCESS then
			self:_onHatchStartConfirmed(fromSlotIdx, data)
		end
	end)
end

function PetHatchComponent:_onHatchStartConfirmed(fromSlotIdx, data)
	if not fromSlotIdx then
		return
	end

	self:_refreshCurSelectedEggData()

	local cur = self._curSelectedEggData
	local nextSlot = self:_findNextEmptyHatchSlot(fromSlotIdx, cur or data)

	if nextSlot then
		self:_selectHatchSlotLocally(nextSlot)
		self:_ensureCompatibleEgg()

		return
	end

	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local slotInfo = hatchSlotList and hatchSlotList[fromSlotIdx]

	if slotInfo and slotInfo.status == Const.PET_BALL.HATCH_STATUS_START then
		local slotEggData = self.model:getHatchSlotEggItemInfo(slotInfo)

		if slotEggData then
			self:displayInfoPanel(true, rightInfoHatchingType, slotEggData, fromSlotIdx)
		else
			self:_forceHideInfoPanel()
		end
	else
		self:displayInfoPanel(true, rightInfoHatchingType, data, fromSlotIdx)
	end

	self.curSelectedLeftEggInfo = nil
	self._curSelectedEggData = nil

	self:tempShowEggRemainTimes()
	self:_refreshStartBtn()
	self:_scheduleFocusHatchingTargetForGamepad(fromSlotIdx)
end

function PetHatchComponent:_onHatchStopConfirmed(slotIdx, stoppedEggKey)
	if not slotIdx then
		return
	end

	local selected = false

	if stoppedEggKey then
		local list = self.model:getAllEggs()

		if list then
			for _, eg in ipairs(list) do
				if eg.id == stoppedEggKey.id and eg.genId == stoppedEggKey.genId and not self:_isSlotEggBlocked(slotIdx, eg) then
					self:_selectEggLocally(eg)

					selected = true

					break
				end
			end
		end
	end

	if not selected then
		self:_ensureCompatibleEgg()
	end

	if pg.game.input:isUsingGamepad() then
		self._gamepadReturnSlotIndex = slotIdx
		self._pendingFocusEggListForGamepad = true

		self:_scheduleFocusEggListForGamepad()
	end
end

function PetHatchComponent:_refreshCurSelectedEggData()
	local cur = self._curSelectedEggData

	if not cur then
		return
	end

	local list = self.model:getAllEggs()

	if not list then
		return
	end

	for _, eg in ipairs(list) do
		if eg.id == cur.id and eg.genId == cur.genId then
			self._curSelectedEggData = eg

			return
		end
	end

	for _, eg in ipairs(list) do
		if eg.id == cur.id then
			self._curSelectedEggData = eg

			return
		end
	end

	cur.count = ClientUtils.getItemCountById(cur.id, true) or 0
end

function PetHatchComponent:_findNextEmptyHatchSlot(fromIdx, curEggData)
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList then
		return nil
	end

	return self:_findNextOuterInitSlot(fromIdx, hatchSlotList) or self:_findSpecialInitSlot(hatchSlotList, fromIdx)
end

function PetHatchComponent:_refreshEggListIfVisible()
	local _, hiveSelect = self.root:TryGetCurrentPage("HiveSelect")

	if hiveSelect == 1 then
		self:refreshEggListPanel()
	end
end

function PetHatchComponent:_selectHatchSlotLocally(index)
	if not self:_isHatchSlotVisible(index) then
		return
	end

	if self.curSelectedSlotIndex and self.hatchValidCells[self.curSelectedSlotIndex] then
		self.hatchValidCells[self.curSelectedSlotIndex].isSelected = false
	end

	if self.hatchValidCells[index] then
		self.hatchValidCells[index].isSelected = true
	end

	self.curSelectedSlotIndex = index

	self:_refreshEggListIfVisible()
	self:tempShowEggRemainTimes()
	self:_refreshStartBtn()
end

function PetHatchComponent:tryFocusFirstHatchedEggSlot()
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)

	if not hatchSlotList then
		return false
	end

	for _, idx in ipairs(PetHatchComponent.VISIBLE_HATCH_INDICES) do
		local slot = hatchSlotList[idx]

		if slot and slot.status == Const.PET_BALL.HATCH_STATUS_SUCC then
			local cell = self.hatchValidCells and self.hatchValidCells[idx]

			if cell and pg.global.navMgr then
				pg.global.navMgr:FocusItem(cell)
			end

			return true
		end
	end

	return false
end

function PetHatchComponent:tryCollapseEggBarForGamepad()
	if not pg.game.input:isUsingGamepad() then
		return false
	end

	local _, hiveSelect = self.root:TryGetCurrentPage("HiveSelect")

	if hiveSelect ~= 1 then
		return false
	end

	self:displayEggPanel(false)
	self:_forceHideInfoPanel()
	self.root:TryChangePage("EggSelect", 0)

	if self.curSelectedSlotIndex and self.hatchValidCells[self.curSelectedSlotIndex] then
		self.hatchValidCells[self.curSelectedSlotIndex].isSelected = false
	end

	self.curSelectedSlotIndex = nil

	local navMgr = pg.global.navMgr
	local backIdx = self._gamepadReturnSlotIndex

	if navMgr and backIdx and self.hatchValidCells[backIdx] then
		navMgr:FocusItem(self.hatchValidCells[backIdx])
	end

	return true
end

function PetHatchComponent:_findNextEggData(curEggData)
	if not curEggData then
		return nil
	end

	local list = self.model:getAllEggs()

	if not list or #list == 0 then
		return nil
	end

	local found = false

	for _, eg in ipairs(list) do
		if found then
			if not eg.isHatching and not eg.isLock and (eg.count or 0) > 0 and (eg.id ~= curEggData.id or eg.genId ~= curEggData.genId) then
				return eg
			end
		elseif eg.id == curEggData.id and eg.genId == curEggData.genId then
			found = true
		end
	end

	return nil
end

function PetHatchComponent:_selectEggLocally(eggData)
	if not eggData then
		return
	end

	self._curSelectedEggData = eggData

	local dur, speedupTime = Utils.getFixedInitHatchTime(pg.me, eggData.id)
	local activitySpeed = speedupTime and speedupTime[Const.HatchSpeedUpReason.activty_petHatch]
	local hatchSpeed = activitySpeed and activitySpeed > 0

	self.curSelectedLeftEggInfo = {
		icon = eggData.icon,
		duration = dur,
		hatchSpeed = hatchSpeed
	}

	local minQuality = self.curSelectedSlotIndex == PetHatchComponent.SPECIAL_HATCH_INDEX and 5 or 0
	local isValid = minQuality <= eggData.quality

	self:tempShowEggRemainTimes(not isValid)

	if isValid then
		self:displayInfoPanel(true, rightInfoUnType, eggData, nil)
	else
		self:displayInfoPanel(false)
	end

	self:_updateEggButtonHighlight()
	self:_refreshStartBtn()

	self._pendingAutoSelectEgg = nil
	self._pendingAutoSelectEggData = nil
end

function PetHatchComponent:displayEggPanel(show)
	self.root:TryChangePage("HiveSelect", show and 1 or 0)

	if not show then
		self.curSelectedLeftEggInfo = nil

		self:tempShowEggRemainTimes()

		return
	end

	self:refreshEggListPanel()
end

function PetHatchComponent:displayInfoPanel(show, panelType, data, hatchSlotIndex)
	self._infoPanelPageToken = (self._infoPanelPageToken or 0) + 1

	local pageToken = self._infoPanelPageToken

	TimerManager.addNextFrameCb(function()
		if pageToken ~= self._infoPanelPageToken or IsNil(self.root) then
			return
		end

		if show and self._isParentVisible == false then
			return
		end

		self.root:TryChangePage("EggSelect", show and 1 or 0)
	end)

	if not show then
		self._propInfoRenderToken = (self._propInfoRenderToken or 0) + 1
		self.rightInfoPanelCurHatchSlotIndex = nil
		self.curRightInfoPanelType = nil

		self:_refreshSealedEggHatchState(nil)

		return
	end

	self:refreshRightInfoPanel(panelType, data, hatchSlotIndex)
end

function PetHatchComponent:onHatchMapSlotStatusChanged(info)
	local newStatus = info.newValue
	local oldStatus = info.oldValue
	local hatchSlotId = info.hatchSlotId
	local hatchSlotList = self.model:getHatchSlotDataList(self.ctrl.info.spawnerId)
	local totalCount = #hatchSlotList

	if oldStatus == Const.PET_BALL.HATCH_STATUS_INIT and newStatus == Const.PET_BALL.HATCH_STATUS_START then
		if self.hatchValidCells and self.hatchValidCells[hatchSlotId] then
			self.hatchValidCells[hatchSlotId]:TryChangePage("TempShow", 0)
		end

		self:refreshSingleHatchSlot(hatchSlotId, hatchSlotList)
		self:refreshEggListPanel()
		self:_refreshHatchingMode()
	elseif oldStatus == Const.PET_BALL.HATCH_STATUS_START and newStatus == Const.PET_BALL.HATCH_STATUS_INIT then
		self:refreshSingleHatchSlot(hatchSlotId, hatchSlotList)
		self:refreshEggListPanel()
		self:_refreshHatchingMode()
	elseif oldStatus == Const.PET_BALL.HATCH_STATUS_START and newStatus == Const.PET_BALL.HATCH_STATUS_SUCC then
		self:refreshSingleHatchSlot(hatchSlotId, hatchSlotList)

		if hatchSlotId == self.rightInfoPanelCurHatchSlotIndex then
			self:displayInfoPanel(false)
		end

		self:_refreshHatchingMode()
	elseif oldStatus == Const.PET_BALL.HATCH_STATUS_SUCC and newStatus == Const.PET_BALL.HATCH_STATUS_INIT then
		self:refreshSingleHatchSlot(hatchSlotId, hatchSlotList)
		self:_refreshHatchingMode()

		if hatchSlotId == self.curSelectedSlotIndex then
			self:_ensureCompatibleEgg()
			self:_refreshEggListIfVisible()
			self:_updateEggButtonHighlight()

			if pg.game.input:isUsingGamepad() then
				self._gamepadReturnSlotIndex = hatchSlotId
				self._pendingFocusEggListOnVisible = true
			end
		end
	end

	if hatchSlotId == self.curSelectedSlotIndex then
		-- block empty
	end
end

function PetHatchComponent:refreshSortOption()
	function self.btnSortUButton.luaClick()
		self.model:setHatchDescending(not self.model.hatchIsDescending)
		self:refreshSortOption()
	end

	local sortOptions = self.model:getHatchEggSortInfo()

	function self.selectorUSelector.luaRenderPopup(popup, uList)
		function uList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			ClientTextUtils.setText(txtUText, data.name)

			function button.luaClick()
				self.model:setHatchSortId(index + 1)
				self:refreshSortOption()
				self.selectorUSelector:ClosePopup()
			end
		end

		uList:SetList(sortOptions)
	end

	self.selectorUSelector:SetOptions(sortOptions)

	self.selectorUSelector.selectedIndex = self.model.hatchSortId - 1

	ClientTextUtils.setText(self.selectorTxtNameUBaseText, self.model:getHatchEggSortInfo()[self.model.hatchSortId].name)
	self.btnSortUButton:TryChangePage("asc", self.model.hatchIsDescending and 1 or 0)
	self:refreshEggListPanel()
end

function PetHatchComponent:moveToCellSmoothly(index, larger)
	local time = 0.3

	if larger then
		local destination

		if self.detailUWidget.transform.localScale.x == PetHatchComponent.MOVE_COE.LARGER.x then
			local direction = self.view.unFocusBtn.transform.position - self.hatchValidCells[index].transform.position

			destination = self.detailUWidget.transform.position + direction
		else
			local direction = self.view.unFocusBtn.transform.position - self.hatchValidCells[index].transform.position

			destination = self.detailUWidget.transform.position + direction
			self.detailUWidget.transform.localScale = PetHatchComponent.MOVE_COE.DEFAULT
		end

		DoTweenAnimMgr.GlobalMove(self.detailUWidget.transform, LuaUIUtils.TweenId(ID_DETAIL_UWIDGET_MOVE), destination, time, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, nil, false)
		DoTweenAnimMgr.Scale(self.detailUWidget.transform, LuaUIUtils.TweenId(ID_DETAIL_UWIDGET_SCALE), PetHatchComponent.MOVE_COE.LARGER, time, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, false, nil)
	else
		DoTweenAnimMgr.GlobalMove(self.detailUWidget.transform, LuaUIUtils.TweenId(ID_DETAIL_UWIDGET_MOVE), self.view.unFocusBtn.transform.position, time, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, nil, false)
		DoTweenAnimMgr.Scale(self.detailUWidget.transform, LuaUIUtils.TweenId(ID_DETAIL_UWIDGET_SCALE), PetHatchComponent.MOVE_COE.DEFAULT, time, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil, false, nil)
	end
end

function PetHatchComponent:onDestroy()
	self._propInfoRenderToken = (self._propInfoRenderToken or 0) + 1
	self._infoPanelPageToken = (self._infoPanelPageToken or 0) + 1
	self._isParentVisible = false

	self:_invalidateTempShowPreviews(true)

	if self.hatchSlotCountDownFormatTimers then
		for _, timer in pairs(self.hatchSlotCountDownFormatTimers) do
			TimerManager.removeTimer(timer)
		end

		self.hatchSlotCountDownFormatTimers = nil
	end

	self:destroy()
	UIComponent.onDestroy(self)
end

return PetHatchComponent
