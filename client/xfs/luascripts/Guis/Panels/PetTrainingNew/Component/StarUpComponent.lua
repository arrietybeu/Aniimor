-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\StarUpComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("StarUpComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local StarUpComponent = Class.LightClass("StarUpComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetFamilyData = require("Data.pet_family_data")
local PetConfigData = require("Data.pet_config_data")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AttributeData = require("Data.attribute_group_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local NoticeDef = require("Common.NoticeDef")
local PetCardInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetCardInfoComponent")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local FrontCondition = require("Data.front_condition_data")
local TimerManager = require("Core.Timer.TimerManager")
local AudioConst = require("Const.AudioConst")
local Time = require("Core.Common.Time")
local math_floor = math.floor
local string_format = string.format
local MAX_ATTRS_LEN = 3
local NOTICE_SECOND = 2
local NORMAL_CLICK_INTERVAL_MS = 100
local BREAK_CLICK_INTERVAL_MS = 1000
local SOURCE_CRYSTAL_ITEM_ID = 152100
local SOURCE_CRYSTAL_CONFIRM_MIN_STAGE = 5
local SOURCE_CRYSTAL_CONFIRM_PREF_KEY = "petStarUpSourceCrystalConfirmTs"
local normalUpLvAni = CS.XGUI.EInvokeTime.Custom1
local normalUpLvAniSecond = 0.85
local normalUpLvFinishAni = CS.XGUI.EInvokeTime.Custom2
local normalUpLvFinishAniSecond = 1.4333333333333333
local switchInfoStateTo0Ani = CS.XGUI.EInvokeTime.Custom3
local switchInfoStateTo2Ani = CS.XGUI.EInvokeTime.Custom4
local breakKey = "PET_RISING_NORMAL"
local uplvKey = "PET_RISING_UPLV"
local RINFO_STATE_NAME = "InfoState"
local RINFO_STATE = {
	[PetManagementDataHelper.RESONANCE_STATE.NORMAL] = 0,
	[PetManagementDataHelper.RESONANCE_STATE.WAIT_MIN_UP] = 2,
	[PetManagementDataHelper.RESONANCE_STATE.WAIT_MAX_UP] = 2,
	[PetManagementDataHelper.RESONANCE_STATE.MAXED] = 3
}
local RINFO_STATE_UPBTN_TXTKEY = {
	[PetManagementDataHelper.RESONANCE_STATE.NORMAL] = "PET_RISING_UPLV",
	[PetManagementDataHelper.RESONANCE_STATE.WAIT_MIN_UP] = "PET_RISING_NORMAL",
	[PetManagementDataHelper.RESONANCE_STATE.WAIT_MAX_UP] = "PET_RISING_NORMAL",
	[PetManagementDataHelper.RESONANCE_STATE.MAXED] = nil
}

function StarUpComponent:findObjects()
	local objectReference = self.view.starUpUComponent.content.transform:GetComponent("ObjectReference")

	self.rightPanelUComponent = LuaUIUtils.safeGetRefValue(objectReference, "rightPanelUComponent")
	self.newRatioNodeUComp = LuaUIUtils.safeGetRefValue(objectReference, "newRatioNodeUComp")
	self.noQualityUWidget = LuaUIUtils.safeGetRefValue(objectReference, "noQualityUWidget")
	self.btnUpgradeUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnUpgradeUButton")
	self.btnUpgradNameUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "btnUpgradNameUSDFText")
	self.normalUWidget = LuaUIUtils.safeGetRefValue(objectReference, "normalUWidget")
	self.fullUWidget = LuaUIUtils.safeGetRefValue(objectReference, "fullUWidget")
	self.requirementUWidget = LuaUIUtils.safeGetRefValue(objectReference, "requirementUWidget")
	self.petInfoUComponent = objectReference:GetRefValue("petInfoUComponent")
	self.petInfoCardComponent = PetCardInfoComponent.new(self.petInfoUComponent)
	self.notAchievedUWidget = LuaUIUtils.safeGetRefValue(objectReference, "notAchievedUWidget")
	self.textRequireUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "textRequireUSDFText")
	objectReference = self.normalUWidget.transform:GetComponent("ObjectReference")
	self.n_starBeforeUContainer = LuaUIUtils.safeGetRefValue(objectReference, "starBeforeUContainer")
	self.n_imgBeforeUImage = LuaUIUtils.safeGetRefValue(objectReference, "imgBeforeUImage")
	self.n_starAfterUContainer = LuaUIUtils.safeGetRefValue(objectReference, "starAfterUContainer")
	self.n_listAttributeUList = LuaUIUtils.safeGetRefValue(objectReference, "listAttributeUList")
	self.n_numBigBoxUWidget = LuaUIUtils.safeGetRefValue(objectReference, "numBigBoxUWidget")
	self.n_txtBigBonusUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtBigBonusUSDFText")

	function self.n_listAttributeUList.luaRenderItem(button, index, data)
		self:m_onRefreshAttributeItem(button, index, data)
	end

	objectReference = self.fullUWidget.transform:GetComponent("ObjectReference")
	self.m_starMaxUContainer = LuaUIUtils.safeGetRefValue(objectReference, "starMaxUContainer")
	self.m_txtNumMaxUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtNumMaxUSDFText")
	objectReference = self.requirementUWidget.transform:GetComponent("ObjectReference")
	self.costList1 = LuaUIUtils.safeGetRefValue(objectReference, "listUList")

	function self.costList1.luaRenderItem(button, index, data)
		self:m_onRefreshCostListItem(button, index, data)
	end

	self.m_isCreated = true
end

function StarUpComponent:initView()
	self.btnUpgradeUButton.visualInteractable = true

	function self.btnUpgradeUButton.luaClick()
		if self.m_isBreakPopPending then
			return
		end

		local interval = self.m_preClickInterval or NORMAL_CLICK_INTERVAL_MS

		if self.m_preClickMSecond and interval > Time.realSecondCache * 1000 - self.m_preClickMSecond then
			return
		end

		local isBreak = self:m_isNextUpgradeBreak()

		self:onClikUpStar()

		self.m_preClickMSecond = Time.realSecondCache * 1000
		self.m_preClickInterval = isBreak and BREAK_CLICK_INTERVAL_MS or NORMAL_CLICK_INTERVAL_MS
	end
end

function StarUpComponent:init(info)
	if not self.m_isCreated then
		return
	end

	self.petId = info.petId

	if info.pvpFailMode or info.onlyShowSkillPage then
		return
	end

	self:m_updateData()
	self:refreshStarUp()
end

function StarUpComponent:m_updateData()
	self.petInfo = self.model:setUpPetInfo(self.petId)
	self.isEnoughCostToUp = self.model:isEnoughCostToUp(self.petId)
	self.m_oldPetResonanceState = self.m_resonanceState
	self.m_resonanceState = self.model:getResonanceState(self.petId)
	self.m_curStage, self.m_curLevel = self.model:getResonanceCurSLv(self.petId)

	local nextResonanceCfg, nextStage, nextLevel = self.model:getResonanceNextSLvCfg(self.petId)

	self.m_nextResonanceCfg = nextResonanceCfg
	self.m_nextStage = nextStage
	self.m_nextLevel = nextLevel

	local maxStage, maxLevel = self.model:getResonanceMaxSLvCfg(self.petId)

	self.m_maxStage = maxStage
	self.m_maxLevel = maxLevel
	self.m_curAttributeList = self.model:getPetTargeResonanceStagelvDisplayAttrs2(self.petId)
	self.m_attributeList = self.m_attributeList or {}
	self.m_attributeList[self:m_getCacheAttrsKey(self.m_curStage, self.m_curLevel)] = self.m_curAttributeList or {}
	self.m_isReachedMaxed = PetManagementUtils.isMaxedResonance(self.m_curStage, self.m_curLevel)
end

function StarUpComponent:m_getCacheAttrsKey(stage, lv)
	return stage * 100 + lv
end

function StarUpComponent:m_getPreAttributeList(stage, lv)
	local prevStage, prevLv = PetManagementUtils.getPetPrevResonanceCfg(self.petId, stage, lv)

	return self.m_attributeList[self:m_getCacheAttrsKey(prevStage, prevLv)]
end

function StarUpComponent:onDestroy()
	UIComponent.onDestroy(self)
	self:killTimer(self.onItemChangedDelayRefreshTimer)

	self.onItemChangedDelayRefreshTimer = nil

	self:killTimer(self.delaySwitchInfoStateTimer)

	self.delaySwitchInfoStateTimer = nil
	self.m_preClickMSecond = nil
	self.m_preClickInterval = nil
	self.m_isBreakPopPending = nil
	self.petId = nil
end

function StarUpComponent:refreshStarUp(msg)
	if not self.petId then
		return
	end

	self:m_updateData()
	self.petInfoCardComponent:renderPetInfoCard(self.petInfo)
	self:renderRatio()
	self:refresStarUpUI(msg)
	self:tryShowBreakPop(msg)
end

function StarUpComponent:tryShowBreakPop(msg)
	if msg and self.m_curLevel == 0 then
		local maxStage = PetManagementUtils.getResonanceMaxStageLv(self.petId)
		local uiId = UIConst.UI_ID_PET_RESONANCE_BREAK

		self.m_isBreakPopPending = true

		self.rightPanelUComponent:SetActive(false)

		if pg.game and pg.game.audio then
			pg.game.audio:playEvent(AudioConst.EVENT_PET_STARUP_3)
		end

		pg.global.ui:open(uiId, {
			petId = self.petId,
			stage = self.m_curStage,
			level = self.m_curLevel,
			attributeList = self:m_getPreAttributeList(self.m_curStage, self.m_curLevel) or self.m_curAttributeList or {},
			onCloseFunc = function()
				self.m_isBreakPopPending = false

				self.rightPanelUComponent:SetActive(true)
				self:refresStarUpUI()
			end
		})
	end
end

function StarUpComponent:debugShowBreakPop(msg)
	local stage = msg.stage
	local lv = msg.lv
	local maxStage = PetManagementUtils.getResonanceMaxStageLv(stage)
	local attributeList = PetManagementUtils.getPetTargeResonanceStagelvDisplayAttrs2(self.petId, stage, lv) or {}
	local uiId = UIConst.UI_ID_PET_RESONANCE_BREAK

	if maxStage <= stage then
		uiId = UIConst.UI_ID_PET_RESONANCE_FINAL_BREAK
	end

	pg.global.ui:open(uiId, {
		petId = self.petId,
		stage = stage,
		level = lv,
		attributeList = attributeList,
		onCloseFunc = function()
			self.rightPanelUComponent:SetActive(true)
		end
	})
	self.rightPanelUComponent:SetActive(false)
end

function StarUpComponent:refreshPetName(petName)
	self.petInfoCardComponent:refreshPetName(petName)
end

function StarUpComponent:resetFavouriteBtnState(favoriteType)
	favoriteType = favoriteType or 0

	self.petInfoCardComponent:resetFavouriteBtnState(favoriteType)
end

function StarUpComponent:renderRatio()
	if not self.petInfo or not self.petInfo.id then
		return
	end

	local realPetInfo = pg.me:getPetInfo(self.petInfo.id)

	PetManagementUtils.setPetRatioUINode(realPetInfo, self.newRatioNodeUComp)
end

function StarUpComponent:refresStarUpUI(msg)
	local nextResonanceCfg, nextStage, nextLevel = PetManagementUtils.getPetNextResonanceCfg(self.petId, self.m_curStage, self.m_curLevel)
	local EState = PetManagementDataHelper.RESONANCE_STATE

	self.m_canUseUniversalCost = false
	self.m_starUpReplacedInfo = {}
	self.m_starUpAvailableReplacedNumMap = {}

	local extraStrKeys = {
		"PET_RESONANCE_UPSTAGE_GAIN1",
		"PET_RESONANCE_UPSTAGE_GAIN2",
		"PET_RESONANCE_UPSTAGE_GAIN3"
	}
	local extraStrTxt = {
		self.n_txtBigBonusUSDFText,
		self.n_txtBigBonusUSDFText,
		self.m_txtNumMaxUSDFText
	}
	local extraStrKey = extraStrKeys[self.m_resonanceState]
	local extraStrTxt = extraStrTxt[self.m_resonanceState]

	if extraStrTxt then
		local extraStr = pg.getGameString(extraStrKey or "")
		local gainStr = nextResonanceCfg and nextResonanceCfg.upStageBonusDesc or ""

		if self.m_resonanceState == EState.MAXED then
			ClientTextUtils.setText(extraStrTxt, pg.getGameString("PET_STARUP_REACHED_MAXED"))
		else
			ClientTextUtils.setText(extraStrTxt, ClientTextUtils.concatByLanguage(extraStr, pg.getLocalizationText(gainStr or "")))
		end
	end

	local curStageStarUrl = self.model:getStarItemUrl(self.m_curStage)
	local nextStageStarUrl = self.model:getStarItemUrl(self.m_nextStage, self.m_resonanceState)

	if self.m_resonanceState == EState.MAXED then
		self.m_starMaxUContainer:SetUrlWithCallback(curStageStarUrl, function()
			self:m_refreshRMaxStar()
		end)
	else
		if curStageStarUrl == self.m_curStageStarUrl then
			self:m_refreshRCurStar(msg)
		else
			self.n_starBeforeUContainer:SetUrlWithCallback(curStageStarUrl, function()
				self:m_refreshRCurStar(msg)

				self.m_curStageStarUrl = curStageStarUrl
			end)
		end

		if nextStageStarUrl == self.m_nextStageStarUrl then
			self:m_refreshRNextStar(msg)
		else
			self.n_starAfterUContainer:SetUrlWithCallback(nextStageStarUrl, function()
				self:m_refreshRNextStar(msg)

				self.m_nextStageStarUrl = nextStageStarUrl
			end)
		end

		self.n_listAttributeUList:SetList(self.m_curAttributeList or {})
	end

	local infoState = RINFO_STATE[self.m_resonanceState]

	local function innerRefreshFunc()
		if self.m_resonanceState == EState.MAXED then
			self.notAchievedUWidget:SetActive(false)
		else
			local costItemInfo = self.model:getPetNextResonanceSLvCosts(self.petId)
			local costAllItems = costItemInfo.allItems or {}

			self:m_refreshUniversalCostResult(costAllItems)

			if self.m_resonanceState == EState.NORMAL then
				self.costList1:SetList(costAllItems or {})
				self.notAchievedUWidget:SetActive(false)
			elseif self.m_resonanceState == EState.WAIT_MIN_UP or self.m_resonanceState == EState.WAIT_MAX_UP then
				self.costList1:SetList(costAllItems or {})

				local conditionDescKey = costItemInfo.conditionDescKey or ""
				local checkRet, isCanUp = self:m_getCheckCanUpRet()
				local canUseUniversalCostForCheck = self:m_isUniversalCostCheckAvailable(checkRet)
				local checkLessLv = checkRet and checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_LEVEL

				if checkLessLv then
					if conditionDescKey and conditionDescKey ~= "" then
						ClientTextUtils.setText(self.textRequireUSDFText, ClientTextUtils.getLocalizationText(conditionDescKey or ""))
					else
						ClientTextUtils.setText(self.textRequireUSDFText, "")
					end
				else
					ClientTextUtils.setText(self.textRequireUSDFText, pg.getGameString("PET_STARUP_ITEM_NOT_ENOUGH"))
				end

				if self.delayTimer then
					TimerManager.removeTimer(self.delayTimer)

					self.delayTimer = nil
				end

				if isCanUp or canUseUniversalCostForCheck then
					self.notAchievedUWidget:SetActive(false)

					self.delayTimer = TimerManager.addTimer(0.1, function()
						self.btnUpgradeUButton:SetActive(true)
					end)
				else
					self.notAchievedUWidget:SetActive(true)

					self.delayTimer = TimerManager.addTimer(0.1, function()
						self.btnUpgradeUButton:SetActive(false)
					end)
				end
			end
		end

		local canUseUniversalCost = self:m_isUniversalCostCheckAvailable()
		local btnState = (self.isEnoughCostToUp or canUseUniversalCost) and not self.ctrl:isInRogueDungeon() and 0 or 4

		LuaUIUtils.tryAddDelayTimer(self, "delayRefreshBtnUpgradeUButtonState", 0.1, function()
			self.btnUpgradeUButton.visualInteractable = btnState == 0

			self.btnUpgradeUButton:TryChangePage("button", btnState)
		end)
	end

	if msg then
		TimerManager.addNextFrameCb(function()
			local oldStage = msg.oldStage
			local oldLv = msg.oldLv
			local newStage = msg.newStage
			local newLv = msg.newLv
			local playAniSecond = 0
			local newStageMaxLv = PetManagementUtils.getResonanceStageMaxLv(newStage)

			if newStage == oldStage then
				if newLv == newStageMaxLv then
					self.normalUWidget:InvokeCallback(normalUpLvFinishAni)

					playAniSecond = normalUpLvAniSecond
				end
			elseif oldStage < newStage and newLv == 0 then
				self.normalUWidget:InvokeCallback(normalUpLvAni)

				playAniSecond = normalUpLvFinishAniSecond
			end

			if playAniSecond > 0 then
				self:killTimer(self.delaySwitchInfoStateTimer)

				self.delaySwitchInfoStateTimer = self:startTimer(function()
					self.rightPanelUComponent:TryChangePage("InfoState", infoState)
					self:m_switchInfoStateAni(infoState)
					innerRefreshFunc()
				end, playAniSecond)
			else
				self.rightPanelUComponent:TryChangePage("InfoState", infoState)
				self:m_switchInfoStateAni(infoState)
				innerRefreshFunc()
			end
		end)
	else
		self.rightPanelUComponent:TryChangePage("InfoState", infoState)
		self:m_switchInfoStateAni(infoState)
		innerRefreshFunc()
	end
end

function StarUpComponent:m_switchInfoStateAni(infoState)
	TimerManager.addNextFrameCb(function()
		if infoState == 0 then
			self.normalUWidget:InvokeCallback(switchInfoStateTo0Ani)
		else
			self.normalUWidget:InvokeCallback(switchInfoStateTo2Ani)
		end
	end)
end

local function normalizeCostConfigList(value)
	if Utils.isTable(value) then
		return value
	end

	return {}
end

function StarUpComponent:m_getStarUpCostBackupMap()
	local petInfo = pg.me and pg.me:getPetInfo(self.petId)
	local cfgData = petInfo and petInfo:getConfigData()
	local familyData = PetFamilyData[cfgData and cfgData.ethnicGroup or 0]
	local backupMap = {}

	if familyData then
		local enhanceItems = normalizeCostConfigList(familyData.enhanceItem)
		local enhanceItemBackups = normalizeCostConfigList(familyData.enhanceItemBackup)

		for i, itemId in ipairs(enhanceItems) do
			local backupId = enhanceItemBackups[i]

			if itemId and itemId > 0 and backupId and backupId > 0 then
				backupMap[itemId] = backupId
			end
		end
	end

	local mainElementName = cfgData and LuaUIUtils.getElementName(cfgData.mainElementType)
	local elementItemIdMap = PetConfigData.petElementItemId
	local elementItemBackupIdMap = PetConfigData.petElementItemIdBackup
	local elementItemId = mainElementName and elementItemIdMap and elementItemIdMap[mainElementName]
	local backupItemId = mainElementName and elementItemBackupIdMap and elementItemBackupIdMap[mainElementName]

	if elementItemId and elementItemId > 0 and backupItemId and backupItemId > 0 then
		backupMap[elementItemId] = backupItemId
	end

	return backupMap
end

function StarUpComponent:m_getStarUpCostAlternativeResult(costItems)
	local idNumDict = {}

	for _, itemInfo in ipairs(costItems or EMPTY_TABLE) do
		local itemId = itemInfo and itemInfo[1] or 0
		local itemNum = itemInfo and itemInfo[2] or 0

		if itemId > 0 and itemNum > 0 then
			idNumDict[itemId] = (idNumDict[itemId] or 0) + itemNum
		end
	end

	local backupMap = self:m_getStarUpCostBackupMap()
	local resIdNumDict = {}
	local altIdNumDict = {}
	local replacedInfo = {}
	local resultFlag = 0

	for needId, needCount in pairs(idNumDict) do
		resIdNumDict[needId] = needCount

		local hasCount = ItemUtils.getItemCountById(pg.me, needId)

		if hasCount < needCount then
			local backupId = backupMap[needId]

			if not backupId or backupId <= 0 then
				resultFlag = resultFlag + 1
			else
				local beReplacedCount = needCount - hasCount

				altIdNumDict[backupId] = (altIdNumDict[backupId] or 0) + beReplacedCount
				resIdNumDict[needId] = resIdNumDict[needId] - beReplacedCount
				replacedInfo[#replacedInfo + 1] = {
					oriItemId = needId,
					oriNum = beReplacedCount,
					newItemId = backupId,
					newNum = beReplacedCount
				}
			end
		end
	end

	for itemId, itemCount in pairs(altIdNumDict) do
		resIdNumDict[itemId] = (resIdNumDict[itemId] or 0) + itemCount
	end

	return resultFlag <= 0, resIdNumDict, altIdNumDict, replacedInfo
end

function StarUpComponent:m_refreshUniversalCostResult(costAllItems)
	self.m_canUseUniversalCost = false
	self.m_starUpReplacedInfo = {}
	self.m_starUpAvailableReplacedNumMap = {}

	local success, _, altIdNumDict, replacedInfo = self:m_getStarUpCostAlternativeResult(costAllItems)

	self.m_starUpReplacedInfo = replacedInfo or {}
	self.m_canUseUniversalCost = success and next(self.m_starUpReplacedInfo) ~= nil

	for backupId, backupNeedNum in pairs(altIdNumDict or EMPTY_TABLE) do
		local backupHasNum = ItemUtils.getItemCountById(pg.me, backupId)

		if backupNeedNum <= backupHasNum then
			for _, itemInfo in ipairs(self.m_starUpReplacedInfo) do
				if itemInfo.newItemId == backupId then
					local oriItemId = itemInfo.oriItemId

					self.m_starUpAvailableReplacedNumMap[oriItemId] = (self.m_starUpAvailableReplacedNumMap[oriItemId] or 0) + (itemInfo.oriNum or 0)
				end
			end
		end
	end
end

function StarUpComponent:m_isUniversalCostCheckAvailable(checkRet)
	if not self.m_canUseUniversalCost then
		return false
	end

	checkRet = checkRet or select(1, self:m_getCheckCanUpRet())

	return not checkRet or not checkRet.code or checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ITEM
end

function StarUpComponent:m_hasSourceCrystalCost(costAllItems)
	for _, itemInfo in ipairs(costAllItems or EMPTY_TABLE) do
		local itemId = itemInfo and itemInfo[1] or 0
		local itemCostNum = itemInfo and itemInfo[2] or 0

		if itemId == SOURCE_CRYSTAL_ITEM_ID and itemCostNum > 0 then
			return true
		end
	end

	return false
end

function StarUpComponent:m_isSourceCrystalConfirmDisabled()
	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils

	if not prefsCacheUtils then
		return false
	end

	local lastConfirmTs = prefsCacheUtils:getInt(SOURCE_CRYSTAL_CONFIRM_PREF_KEY, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	return lastConfirmTs > 0 and lastConfirmTs + Const.SECONDS_ONE_DAY > Time.secondCache
end

function StarUpComponent:m_saveSourceCrystalConfirmDisabled()
	local prefsCacheUtils = pg.global and pg.global.prefsCacheUtils

	if not prefsCacheUtils then
		return
	end

	prefsCacheUtils:setInt(SOURCE_CRYSTAL_CONFIRM_PREF_KEY, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
	prefsCacheUtils:save()
end

function StarUpComponent:m_tryOpenSourceCrystalCostConfirm(checkRet, isCanUp)
	if (self.m_curStage or 0) < SOURCE_CRYSTAL_CONFIRM_MIN_STAGE then
		return false
	end

	local costItemInfo = self.model:getPetNextResonanceSLvCosts(self.petId) or {}
	local costAllItems = costItemInfo.allItems or {}

	if not self:m_hasSourceCrystalCost(costAllItems) then
		return false
	end

	if not isCanUp then
		self:m_refreshUniversalCostResult(costAllItems)

		if not self:m_isUniversalCostCheckAvailable(checkRet) then
			return false
		end
	end

	if self:m_isSourceCrystalConfirmDisabled() then
		return false
	end

	local disableOneDay = false

	pg.global.showConfirmMsgRaw(pg.getGameString("PET_STARUP_USE_RARE_DOUBLE_CHECK_TITLE"), pg.getGameString("PET_STARUP_USE_RARE_DOUBLE_CHECK"), function()
		if disableOneDay then
			self:m_saveSourceCrystalConfirmDisabled()
		end

		local latestCheckRet, latestIsCanUp = self:m_getCheckCanUpRet()

		self:m_continueUpStar(latestCheckRet, latestIsCanUp)
	end, nil, nil, nil, nil, {
		hint = true,
		hintDesc = string_format(pg.getGameString("DISABLE_HINT"), 1),
		hintCb = function(isSelected)
			disableOneDay = isSelected
		end
	})

	return true
end

function StarUpComponent:m_tryOpenUniversalCostConvertTip(checkRet)
	local petManage = pg.game and pg.game.petManage

	if not petManage or not petManage.openUniversalItemConvertTip then
		return false
	end

	local costItemInfo = self.model:getPetNextResonanceSLvCosts(self.petId) or {}

	self:m_refreshUniversalCostResult(costItemInfo.allItems or {})

	if not self:m_isUniversalCostCheckAvailable(checkRet) then
		return false
	end

	return petManage:openUniversalItemConvertTip(self.m_starUpReplacedInfo, function()
		self:m_reqUpgradeResonance()
	end)
end

function StarUpComponent:m_refreshRCurStar(msg)
	local starUCont = self.n_starBeforeUContainer.content

	self.m_starBeforComp = PetResonaceStarComponent.new(starUCont)

	self.m_starBeforComp:updateAndRefresh(self.petId, {
		stage = self.m_curStage,
		lv = self.m_curLevel,
		pos = UIConst.STARCOMP_POS.BEFORE,
		msg = msg
	}, true)
end

function StarUpComponent:m_refreshRNextStar(msg)
	local starUCont = self.n_starAfterUContainer.content

	self.m_starAfterComp = PetResonaceStarComponent.new(starUCont)

	self.m_starAfterComp:updateAndRefresh(self.petId, {
		stage = self.m_nextStage,
		lv = self.m_nextLevel,
		pos = UIConst.STARCOMP_POS.AFTER,
		msg = msg
	}, true)
end

function StarUpComponent:m_refreshRMaxStar()
	local starUCont = self.m_starMaxUContainer.content

	self.m_starMaxComp = PetResonaceStarComponent.new(starUCont)

	self.m_starMaxComp:updateAndRefresh(self.petId, {
		stage = self.m_maxStage,
		lv = self.m_maxLevel,
		pos = UIConst.STARCOMP_POS.MAX
	}, true)
end

function StarUpComponent:m_onRefreshAttributeItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rootUComp = objectReference:GetRefValue("rootUComp")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textAddUSDFText = objectReference:GetRefValue("textAddUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.l10nName or "")
	ClientTextUtils.setText(textNumUSDFText, data.newVDispTxt)
	ClientTextUtils.setText(textAddUSDFText, data.newVDispTxt)
	rootUComp:TryChangePage("State", 0)
end

function StarUpComponent:m_onRefreshCostListItem(button, index, data)
	if not data then
		return
	end

	local itemId = data and data[1] or 0
	local itemCostNum = data and data[2] or 0
	local itemHasNum = data and data[3] or 0
	local replacedNum = self.m_starUpAvailableReplacedNumMap and self.m_starUpAvailableReplacedNumMap[itemId] or 0

	if itemId > 0 and itemCostNum > 0 then
		local isReplaced = replacedNum > 0
		local itemRenderData = {
			id = itemId,
			num = itemCostNum,
			isReplace = isReplaced
		}
		local itemState = isReplaced and UIConst.ITEM_STATE.EXCHANGE or UIConst.ITEM_STATE.FULL

		LuaUIUtils.renderItemWithCountCheck(button, itemRenderData, function(numText)
			LuaUIUtils.renderConsumeText(numText, itemHasNum + replacedNum, itemCostNum, itemState)
		end, true)
	end
end

function StarUpComponent:m_getCheckCanUpRet()
	local petInfo = pg.me and pg.me:getPetInfo(self.petId)

	if not petInfo then
		return {}, false
	end

	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(self.petId)

	if not resonanceInfo or not resonanceInfo.canUpgradeResonance then
		return {}, false
	end

	local checkRet = {}
	local nextSLvCfg = resonanceInfo:getUpgradeResonanceData()
	local isCanUp = resonanceInfo:canUpgradeResonance(petInfo, nextSLvCfg, checkRet)

	return checkRet, isCanUp
end

function StarUpComponent:m_isNextUpgradeBreak()
	return self.m_nextStage and self.m_curStage and self.m_nextStage > self.m_curStage
end

function StarUpComponent:m_reqUpgradeResonance()
	local isBreak = self:m_isNextUpgradeBreak()

	if isBreak then
		if self.m_isBreakPopPending then
			return
		end

		self.m_isBreakPopPending = true
	end

	PetManagementUtils.reqUpgradeResonance(self.petId, function(noticeId, info)
		if not isBreak then
			return
		end

		if noticeId ~= NoticeDef.SUCCESS then
			self.m_isBreakPopPending = false

			return
		end

		local isBreakSuccess = info and info.newStage and info.oldStage and info.newStage > info.oldStage and info.newLv == 0

		if not isBreakSuccess then
			self.m_isBreakPopPending = false
		end
	end)
end

function StarUpComponent:m_continueUpStar(checkRet, isCanUp)
	if self:m_tryOpenUniversalCostConvertTip(checkRet) then
		return
	end

	local noticeStr = ""

	if checkRet.code then
		local params = checkRet.params or {}

		if checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_LEVEL then
			local needLv = params.needLv or 0

			if needLv > 0 then
				local fStr = pg.getGameString("PET_ENHANCE_PETLEVEL_LESS")

				fStr = fStr == "PET_ENHANCE_PETLEVEL_LESS" and "petLevelLessThan: %s" or fStr
				noticeStr = string.format(pg.getGameString("PET_ENHANCE_PETLEVEL_LESS") or "", needLv)
			end
		elseif checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ORIENTATION then
			local jewelryId = params.jewelryId or 0
			local jewelryL10nName = ItemUtils.getItemFinalNameStrByItemId(jewelryId)

			if jewelryId > 0 then
				local fStr = pg.getGameString("PET_ENHANCE_NOT_APPEARANCE")

				fStr = fStr == "PET_ENHANCE_NOT_APPEARANCE" and "jewelryNotApparance: %s" or fStr
				noticeStr = string.format(pg.getGameString("PET_ENHANCE_NOT_APPEARANCE") or "", jewelryL10nName)
			end
		elseif checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_FAMILY_CONDITION then
			local enhanceConditionId = params.enhanceConditionId or 0

			if enhanceConditionId > 0 then
				noticeStr = pg.getLocalizationText(FrontCondition[enhanceConditionId].note)
			end
		elseif checkRet.code == Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ITEM then
			local itemId = params.itemId or 0

			if itemId > 0 then
				local itemL10nName = ItemUtils.getItemFinalNameStrByItemId(itemId)
				local fStr = pg.getGameString("PET_ENHANCE_ITEM_NOT_ENOUGH")

				fStr = fStr == "PET_ENHANCE_ITEM_NOT_ENOUGH" and "itemNotEnough: %s" or fStr
				noticeStr = string.format(fStr, itemL10nName)
			end
		end

		if noticeStr and noticeStr ~= "" then
			ClientUtils.showBubbleMessageRaw(noticeStr, NOTICE_SECOND)
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("StarUpComponent:onClikUpStar() checkRet.code = %s; noticeStr = %s", checkRet.code, noticeStr)
		end

		return
	end

	if not isCanUp then
		return
	end

	self:m_reqUpgradeResonance()
end

function StarUpComponent:onClikUpStar()
	local checkRet, isCanUp = self:m_getCheckCanUpRet()

	if self:m_tryOpenSourceCrystalCostConfirm(checkRet, isCanUp) then
		return
	end

	self:m_continueUpStar(checkRet, isCanUp)
end

function StarUpComponent:refreshOnLevelChanged(info)
	local changePetId = info and info.petId or 0

	if changePetId == self.petId then
		local refreshData = {
			level = info.newLevel,
			exp = info.curExp
		}

		self.petInfoCardComponent:refreshLevelInfo(refreshData)
		self:refreshStarUp()
	end
end

function StarUpComponent:onParentVisibleChange(visible)
	StarUpComponent.super.onParentVisibleChange(self, visible)

	if visible then
		self:refreshStarUp()
	end
end

function StarUpComponent:refreshOnItemsChanged()
	self.onItemChangedDelayRefreshTimer = self:startTimer(function()
		self:refreshStarUp()
	end, 0.1)
end

return StarUpComponent
