-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSetFormula\\HomelandSetFormulaCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local GlobalData = require("Core.Client.GlobalData")
local Time = require("Core.Common.Time")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandUpgradeData = require("Data.home_upgrade_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFormulaPeriodData = require("Data.homeland_formula_period_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandSetFormulaCtrl = Class.LightClass("HomelandSetFormulaCtrl", UICtrl)

HomelandSetFormulaCtrl.messages = {
	[MessageName.HOMELAND_FORMULA_CHANGED] = {
		"onHomelandFormulaChanged",
		true
	},
	[MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED] = {
		"onDrawingUnlockChanged",
		true
	}
}
HomelandSetFormulaCtrl.FORMULA_TIP_PADDING = 110

function HomelandSetFormulaCtrl:onCreate(info)
	HomelandSetFormulaCtrl.super.onCreate(self, info)

	self.view = self.view
	self.info = info
	self.ornamentId = info.ornamentId
	self.homeTemplateId = info.homeTemplateId
	self.selectFormulaId = nil

	self:initUI()
end

function HomelandSetFormulaCtrl:addListener()
	function self.view.formulaList.luaRenderItem(button, index, data)
		self:refreshLevelFormulaInfo(button, data)
	end

	function self.levelFormulaRenderFunc(item, index, data)
		self:rendererFormulaItem(item, index, data)
	end

	function self.view.btnClose.luaClick()
		self:close()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.priority = 10
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function self.view.btnConfirm.luaClick()
		self:onConfirmFormula()
	end

	function self.view.btnCleanUButton.luaClick()
		if not pg.game.home:tryShowChangeFormulaConfirm(self.ornamentId, function()
			pg.me.space:removeHomelandProduce(self.ornamentId, self.formulaId)
			self:close()
		end) then
			pg.me.space:removeHomelandProduce(self.ornamentId, self.formulaId)
			self:close()
		end
	end

	self:m_setupBtnConfirmHotKey()
	self:m_setupBtnCleanHotKey()
end

function HomelandSetFormulaCtrl:m_setupBtnConfirmHotKey()
	local btn = self.view and self.view.btnConfirm

	if not btn or IsNil(btn) then
		return
	end

	local keyTrans = btn.transform:Find("PanelText/Key") or btn.transform:Find("Key")
	local hotKeyContentGo = keyTrans and not IsNil(keyTrans) and keyTrans.gameObject or nil

	btn:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, hotKeyContentGo)
	btn:SetHotkeyBypassUIModalBlock(true)
end

function HomelandSetFormulaCtrl:m_setupBtnCleanHotKey()
	local btn = self.view and self.view.btnCleanUButton

	if not btn or IsNil(btn) then
		return
	end

	local keyTrans = btn.transform:Find("PanelText/Key") or btn.transform:Find("Key")
	local hotKeyContentGo = keyTrans and not IsNil(keyTrans) and keyTrans.gameObject or nil

	btn:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, hotKeyContentGo)
	btn:SetHotkeyBypassUIModalBlock(true)
end

function HomelandSetFormulaCtrl:onDestroy()
	HomelandSetFormulaCtrl.super.onDestroy(self)
end

function HomelandSetFormulaCtrl:checkFadeOutHud()
	return false
end

function HomelandSetFormulaCtrl:getFinalFormulaList(facilityInfo)
	local ornamentInfo = pg.space.ornament[self.ornamentId]
	local formulaList = facilityInfo.formulaList

	if ornamentInfo and facilityInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch and ornamentInfo.electricMode then
		formulaList = facilityInfo.electricModeFormulaList
	end

	local validFormulaList = {}

	for _, formulaId in ipairs(formulaList or EMPTY_TABLE) do
		if HomelandFormulaData[formulaId] and HomeLandUtils.isHomelandFormulaTimeValid(formulaId) then
			table.insert(validFormulaList, formulaId)
		end
	end

	return validFormulaList
end

function HomelandSetFormulaCtrl:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, level, facilityLevel)
	local formulaInfo = HomelandFormulaData[formulaId]

	if not formulaInfo then
		return
	end

	local outputItemId = HomeLandUtils.getDisplayOutputItemId(formulaInfo)
	local previewItemId = formulaInfo.previewItemId or outputItemId
	local unlockState = ClientHomelandUtils.getFormulaUnlockState(formulaId)
	local formulaItem = {
		formulaId = formulaId,
		conditionLocked = unlockState.conditionLocked,
		drawingLocked = unlockState.drawingLocked,
		unlockLocked = unlockState.isLocked,
		lockText = unlockState.lockText,
		unlockItemId = unlockState.unlockItemId,
		previewItemInfo = {
			id = previewItemId
		},
		itemInfo = {
			id = outputItemId
		},
		isLocked = facilityLevel < level
	}
	local timePeriodId = formulaInfo.timePeriodId

	if not timePeriodId or timePeriodId == 0 then
		table.insert(levelFormulaList, formulaItem)

		return
	end

	local timePeriodGroup = timePeriodGroupMap[timePeriodId]

	if not timePeriodGroup then
		local timePeriodData = HomelandFormulaPeriodData[timePeriodId] or {}

		timePeriodGroup = {
			timePeriodId = timePeriodId,
			name = timePeriodData.name,
			level = level,
			periodType = timePeriodData.periodType,
			formulaList = {},
			isLocked = facilityLevel < level
		}
		timePeriodGroupMap[timePeriodId] = timePeriodGroup

		table.insert(timePeriodGroups, timePeriodGroup)
	end

	table.insert(timePeriodGroup.formulaList, formulaItem)
end

function HomelandSetFormulaCtrl:initFormulaListInfo()
	local revertInfo = RevertHomeUpgradeData[self.homeTemplateId]

	self.formulaListInfo = {}

	local timePeriodGroups = {}
	local timePeriodGroupMap = {}

	if revertInfo then
		self.facilityType = revertInfo[1]
		self.facilityLevel = revertInfo[2]

		local tempFormulaList = {}
		local upgradeInfo = HomelandUpgradeData[self.facilityType]

		for level, ornamentInfo in ipairs(upgradeInfo) do
			local levelFormulaList = {}
			local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeTemplateId)
			local facilityInfo = HomelandFacilityData[facilityId]

			if facilityInfo then
				local formulaList = self:getFinalFormulaList(facilityInfo)

				for _, formulaId in ipairs(formulaList) do
					if not tempFormulaList[formulaId] then
						tempFormulaList[formulaId] = true

						self:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, level, self.facilityLevel)
					end
				end

				if #levelFormulaList > 0 then
					table.insert(self.formulaListInfo, {
						level = level,
						formulaList = levelFormulaList,
						isLocked = level > self.facilityLevel
					})
				end
			end
		end
	else
		local facilityId = Utils.getHomeObjectFacilityId(self.homeTemplateId)
		local facilityInfo = HomelandFacilityData[facilityId]
		local levelFormulaList = {}
		local formulaList = self:getFinalFormulaList(facilityInfo)

		for _, formulaId in ipairs(formulaList) do
			self:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, 1, 1)
		end

		if #levelFormulaList > 0 then
			table.insert(self.formulaListInfo, {
				level = 1,
				isLocked = false,
				formulaList = levelFormulaList
			})
		end
	end

	for index, timePeriodGroup in ipairs(timePeriodGroups) do
		table.insert(self.formulaListInfo, index, timePeriodGroup)
	end

	local facilityId = Utils.getHomeObjectFacilityId(self.homeTemplateId)
	local facilityInfo = HomelandFacilityData[facilityId]

	self.formulaList = self:getFinalFormulaList(facilityInfo)

	self.view.formulaList:SetList(self.formulaListInfo)
end

function HomelandSetFormulaCtrl:initUI()
	self:initFormulaListInfo()
	self:refreshFormulaInfo(true)
end

function HomelandSetFormulaCtrl:setSelectFormula(data)
	self.selectFormulaId = data.formulaId
	self.unlockLocked = data.unlockLocked
	self.levelLocked = data.isLocked

	self.view.formulaList:RefreshList()
	self:refreshButtonInfo()
end

function HomelandSetFormulaCtrl:refreshFormulaInfo(isInit)
	self.facilityInfo = GlobalData.Space.facility[self.ornamentId] or {}
	self.formulaId = self.facilityInfo.formulaId

	if isInit and self.formulaId and self.formulaId ~= 0 then
		self.selectFormulaId = self.formulaId
	end

	self.view.formulaList:RefreshList()
	self:refreshButtonInfo()
end

function HomelandSetFormulaCtrl:onHomelandFormulaChanged()
	self.view.formulaList:RefreshList()
	self:refreshButtonInfo()
end

function HomelandSetFormulaCtrl:onDrawingUnlockChanged(data)
	if not data.formulaId then
		return
	end

	self:initFormulaListInfo()

	if self.selectFormulaId == data.formulaId then
		local unlockState = ClientHomelandUtils.getFormulaUnlockState(data.formulaId)

		self.unlockLocked = unlockState.isLocked
	end

	self:refreshButtonInfo()
end

function HomelandSetFormulaCtrl:refreshButtonInfo()
	if not self.selectFormulaId then
		self.view.widget:TryChangePage("ButtonState", 3)
	elseif self.formulaId == self.selectFormulaId then
		self.view.widget:TryChangePage("ButtonState", 2)
	elseif table.contains(self.formulaList, self.selectFormulaId) and not self.unlockLocked and not self.levelLocked then
		self.view.widget:TryChangePage("ButtonState", 0)
	else
		self.view.widget:TryChangePage("ButtonState", 1)
	end
end

function HomelandSetFormulaCtrl:onConfirmFormula()
	if self.selectFormulaId and table.contains(self.formulaList, self.selectFormulaId) and not self.unlockLocked and not self.levelLocked and HomeLandUtils.isHomelandFormulaTimeValid(self.selectFormulaId) and not pg.game.home:tryShowChangeFormulaConfirm(self.ornamentId, function()
		pg.me.space:setHomelandProduce(self.ornamentId, self.selectFormulaId)
		self:close()
	end) then
		pg.me.space:setHomelandProduce(self.ornamentId, self.selectFormulaId)
		self:close()
	end
end

function HomelandSetFormulaCtrl:rendererFormulaItem(item, index, data)
	if data.formulaId == self.selectFormulaId then
		item.isSelected = true
	else
		item.isSelected = false
	end

	local objectReference = item:GetComponent("ObjectReference")
	local imgMaskLockUWidget = objectReference:GetRefValue("imgMaskLockUWidget")
	local homeMarketTagUContainer = objectReference:GetRefValue("homeMarketTagUContainer")

	if imgMaskLockUWidget then
		imgMaskLockUWidget:SetActive(data.unlockLocked)
	end

	LuaUIUtils.renderRewardItem(item, data.previewItemInfo)

	local isOrderItem = HomeLandUtils.isHomeOrderItem(data.previewItemInfo.id)

	if isOrderItem and not homeMarketTagUContainer:CheckURLLoaded() then
		homeMarketTagUContainer:LoadDefaultUrlManually()
	end

	homeMarketTagUContainer:SetActive(isOrderItem)

	item.name = data.formulaId

	function item.luaClick()
		self:setSelectFormula(data)

		local formulaData = HomelandFormulaData[data.formulaId]
		local formulaInfo = ClientHomelandUtils.getHomeFormulaData(data.formulaId)
		local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			formulaTracking = true,
			autoVer = false,
			autoHor = true,
			id = data.previewItemInfo.id,
			countItemId = defaultOutputItem,
			targetRect = self.view.contentUWidget,
			showUnopen = data.isLocked and not data.unlockLocked,
			unlockTipType = data.unlockLocked and 1 or 0,
			conditionLockText = data.conditionLocked and formulaData.unlockDesc or nil,
			lockText = data.drawingLocked and not data.conditionLocked and data.lockText or nil,
			sourceItemId = data.drawingLocked and not data.conditionLocked and data.unlockItemId or nil,
			sourceTitle = data.drawingLocked and not data.conditionLocked and ClientHomelandUtils.getDrawingSourceTitle(false) or nil,
			formulaInfo = formulaInfo,
			verAlign = CS.XGUI.EVerticalAlignment.Middle,
			padding = HomelandSetFormulaCtrl.FORMULA_TIP_PADDING,
			price = Utils.getHomeItemPrice(defaultOutputItem)
		})
	end
end

function HomelandSetFormulaCtrl:refreshLevelFormulaInfo(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local levelText = objectReference:GetRefValue("levelText")
	local itemList = objectReference:GetRefValue("itemList")
	local lockText = objectReference:GetRefValue("lockText")
	local numText = objectReference:GetRefValue("numText")
	local nameText = objectReference:GetRefValue("nameText")
	local countDown = objectReference:GetRefValue("countDownUCountDown")

	countDown:Stop()

	if data.periodType then
		button:TryChangePage("Type", data.periodType)
	else
		button:TryChangePage("Type", 0)
	end

	if data.timePeriodId then
		local formulaItem = data.formulaList and data.formulaList[1]
		local _, endTime = HomeLandUtils.getHomelandFormulaValidTimeRange(formulaItem.formulaId)
		local remainTime = endTime and endTime - Time.getSecond() or 0

		if remainTime > 0 then
			local d = ClientTextUtils.getGameString("DAY")
			local h = ClientTextUtils.getGameString("HOUR")
			local m = ClientTextUtils.getGameString("MINUTE")

			if remainTime > Const.SECONDS_ONE_DAY then
				countDown.formatText = string.format("{0}%s{1}%s", d, h)
			else
				countDown.formatText = string.format("{1}%s{2}%s", h, m)
			end

			countDown:Play(remainTime)
		end

		button.name = "TimePeriod" .. data.timePeriodId

		ClientTextUtils.setText(numText, "")
		ClientTextUtils.setText(nameText, data.name and pg.getLocalizationText(data.name) or "")
		ClientTextUtils.setText(levelText, "")
	else
		button.name = "Level" .. data.level

		ClientTextUtils.setText(numText, string.format("%02d", data.level))
		ClientTextUtils.setText(nameText, pg.getGameString("HOME_FORMULA_LEVEL_PRODUCT"))

		local levelTextInfo = pg.getFormatText(pg.getGameString("HOME_FORMULA_LEVEL"), data.level)

		ClientTextUtils.setText(levelText, levelTextInfo)
	end

	if data.isLocked then
		button:TryChangePage("Locked", 1)

		local upgradeInfo = self.facilityType and HomelandUpgradeData[self.facilityType]
		local homeLevel = 1

		if upgradeInfo then
			local levelInfo = upgradeInfo[data.level]

			if levelInfo then
				homeLevel = levelInfo.homeLevel or 1
			end
		end

		local lockTextInfo = pg.getFormatText(pg.getGameString("HOME_LEVEL_LOCK_INFO"), homeLevel, data.level)

		ClientTextUtils.setText(lockText, lockTextInfo)
	else
		button:TryChangePage("Locked", 0)
	end

	itemList.luaRenderItem = self.levelFormulaRenderFunc

	itemList:SetList(data.formulaList)
end

return HomelandSetFormulaCtrl
