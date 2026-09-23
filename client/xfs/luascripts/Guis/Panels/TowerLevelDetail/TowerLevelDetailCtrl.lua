-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerLevelDetail\\TowerLevelDetailCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TowerLevelDetailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local TowerLevelDetailCtrl = Class.LightClass("TowerLevelDetailCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local UIConst = require("Const.UIConst")
local RoguelikeData = require("Data.roguelike_data")
local RecommendPetData = require("Data.recommend_pet_data")
local ElementPropData = require("Data.element_prop_data")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local RogueUtils = require("Utils.RogueUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local RedDotConst = require("Const.RedDotConst")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")
local TalentEventData = require("Data.talent_event_data")
local RogueTalentData = require("Data.rogue_talent_data")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientConst = require("Const.ClientConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local RougeSeasonData = require("Data.rogue_season_data")
local ROGUE_GROUP_REPLACE_COUNT = 4
local ROGUE_ELEMENT_ALL_LEVEL_PASSED_TEXT_KEY = "Rogue_Week_Pass_All_Tips"
local ROGUE_ELEMENT_FIRST_WEEK_NOT_ALL_PASSED_TEXT_KEY = "Rogue_Week_Tips"
local ROGUE_ELEMENT_NOT_ALL_PASSED_TEXT_KEY = "Rogue_Week_Next_Tips"

local function getGameStringByKey(key)
	return key ~= "" and pg.getGameString(key) or ""
end

TowerLevelDetailCtrl.messages = {
	[MessageName.ROGUE_LAYER_CHANGE] = {
		"refreshChallengeState",
		true
	},
	[MessageName.ROGUE_SELECT_SERIES] = {
		"refreshSelectedStyleInfo",
		true
	}
}

function TowerLevelDetailCtrl:onCreate(info)
	self.levelId = info and info.levelId

	if self.levelId then
		self.levelIds = info.levelIds or self:getLevelIds()

		local hasChallenge = pg.me.curRogueLayer > 0
		local cacheLevelId, firstOpen = self:resolveWeeklyLevelId(self.levelId, self.levelIds)

		self.firstOpen = firstOpen

		if not hasChallenge and RogueUtils.checkLevelPass(self.levelId) then
			self.levelId = cacheLevelId
		end
	end

	UICtrl.onCreate(self, info)

	if not self.levelId then
		return
	end

	self.isCloseing = false
	self.showNewLevelIds = {}

	pg.global.prefsCacheUtils:deleteKey(ClientConst.PrefKey.RogueBattleCountDown)
	self:initUI()

	self.cacheFocus = pg.global.navMgr.CurrentFocusedUContent
end

function TowerLevelDetailCtrl:getWeeklyLevelRecordKey(prefKey, elementType)
	return string.format("%s_%s", prefKey, elementType)
end

function TowerLevelDetailCtrl:getCurrentWeeklyId()
	return pg.me and tonumber(pg.me.lastWeekUpdateTs) or 0
end

function TowerLevelDetailCtrl:getRogueSeasonStartTime()
	local season = RogueUtils.getCurrentSeasonStage(pg.me.rogueSeasonId)

	return season and season.startDayTime or nil
end

function TowerLevelDetailCtrl:getElementLevelPassResultText(elementType)
	local difficultyCfg = RogueDifficultyData[self.levelId]

	elementType = elementType or difficultyCfg and difficultyCfg.elementType

	if elementType == nil then
		return ""
	end

	if pg.me:isRogueElementAllLevelPassed(elementType) then
		return getGameStringByKey(ROGUE_ELEMENT_ALL_LEVEL_PASSED_TEXT_KEY)
	end

	local seasonStartTime = self:getRogueSeasonStartTime() or Time.getSecond()
	local currentSeasonWeek = Utils.getCurrentSeasonWeek(seasonStartTime)

	if currentSeasonWeek == 1 then
		return getGameStringByKey(ROGUE_ELEMENT_FIRST_WEEK_NOT_ALL_PASSED_TEXT_KEY)
	end

	return getGameStringByKey(ROGUE_ELEMENT_NOT_ALL_PASSED_TEXT_KEY)
end

function TowerLevelDetailCtrl:recordWeeklySelectedDifficulty(levelId)
	local difficultyCfg = RogueDifficultyData[levelId]

	if not difficultyCfg then
		return
	end

	local elementType = difficultyCfg.elementType
	local weekKey = self:getWeeklyLevelRecordKey(ClientConst.PrefKey.TowerLevelDetailOpenWeek, elementType)
	local difficultyKey = self:getWeeklyLevelRecordKey(ClientConst.PrefKey.TowerLevelDetailLastDifficulty, elementType)
	local cacheType = ClientConst.CACHE_TYPE_FLAG.USER

	pg.global.prefsCacheUtils:setInt(weekKey, self:getCurrentWeeklyId(), cacheType)
	pg.global.prefsCacheUtils:setInt(difficultyKey, difficultyCfg.difficultyLabel, cacheType)
end

function TowerLevelDetailCtrl:resolveWeeklyLevelId(inputLevelId, levelIds)
	local inputCfg = RogueDifficultyData[inputLevelId]

	if not inputCfg then
		return inputLevelId
	end

	local cacheType = ClientConst.CACHE_TYPE_FLAG.USER
	local weekKey = self:getWeeklyLevelRecordKey(ClientConst.PrefKey.TowerLevelDetailOpenWeek, inputCfg.elementType)
	local currentWeeklyId = self:getCurrentWeeklyId()
	local lastOpenWeeklyId = pg.global.prefsCacheUtils:getInt(weekKey, -1, cacheType)

	if lastOpenWeeklyId ~= currentWeeklyId then
		self:recordWeeklySelectedDifficulty(inputLevelId)

		return inputLevelId, true
	end

	local difficultyKey = self:getWeeklyLevelRecordKey(ClientConst.PrefKey.TowerLevelDetailLastDifficulty, inputCfg.elementType)
	local lastDifficulty = pg.global.prefsCacheUtils:getInt(difficultyKey, -1, cacheType)

	for _, levelId in ipairs(levelIds or EMPTY_TABLE) do
		local difficultyCfg = RogueDifficultyData[levelId]

		if difficultyCfg and difficultyCfg.difficultyLabel == lastDifficulty then
			local isUnlock = RogueUtils.checkLevelUnlock(levelId)

			if isUnlock then
				return levelId
			end

			break
		end
	end

	self:recordWeeklySelectedDifficulty(inputLevelId)

	return inputLevelId
end

function TowerLevelDetailCtrl:getLevelIds()
	local difficultyCfg = RogueDifficultyData[self.levelId]

	if not difficultyCfg then
		return {}
	end

	local levelIds = {}

	for index, value in ipairs(RogueDifficultyData) do
		if value.elementType == difficultyCfg.elementType then
			table.insert(levelIds, index)
		end
	end

	return levelIds
end

function TowerLevelDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnStartUButton.luaClick()
		local difficultyCfg = RogueDifficultyData[self.levelId]

		if not difficultyCfg then
			return
		end

		local selectedPets = self:getSelectedRoguePetIds()

		if #selectedPets == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("TOWER_SELECT_PET_EMPTY"))

			return
		end

		local curDungeonId = pg.me.curRogueLayer

		if curDungeonId == 0 then
			curDungeonId = difficultyCfg.roguelikeIDStart
		end

		pg.me:setRoguePets(selectedPets)
		pg.me:startRogue(curDungeonId)
		RogueUtils.setSelectedRogueLevel(0)
		self:close()
	end

	function self.view.btnCombatStyleUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TOWER_SELECT_STYLE, {
			levelId = self.levelId
		})
	end

	function self.view.btnResetUButton.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("ROGUE_SETTLEMENT_RESET_TIP"), function()
			RogueUtils.resetRogue()
			self:refreshChallengeState()
		end)
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openRogueRewardUpDesc()
	end

	function self.view.btnfastTrainUButton.luaClick()
		self:onFastTrainClick()
	end

	function self.view.recommendPetBtn.luaClick()
		pg.global.ui:open(UIConst.UI_ID_RECOMMEND_PET, {
			isRogue = true,
			levelId = self.levelId
		})
	end

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))

	local difficultyCfg = RogueDifficultyData[self.levelId]

	self.petGroupSelectorOptions = {
		showInUse = false,
		maxPetsCount = ROGUE_GROUP_REPLACE_COUNT,
		recommendElements = difficultyCfg and difficultyCfg.recommendType or {}
	}

	if not IsNil(self.view.buttonUButton) then
		function self.view.buttonUButton.luaClick()
			local res, button = self.view.listElementUList:TryGetChildAt(0)

			if res and button then
				button:OnClickSimulate()
			end
		end
	end
end

function TowerLevelDetailCtrl:switchRoguePetsByGroup(groupData)
	local selectedPets = self:getSelectedRoguePetIds()
	local fifthPetId = selectedPets[ROGUE_GROUP_REPLACE_COUNT + 1]
	local newPetIds = {}

	for index = 1, ROGUE_GROUP_REPLACE_COUNT do
		local petInfo = groupData and groupData.pets and groupData.pets[index]
		local petId = petInfo and petInfo.id

		if petId and petId ~= fifthPetId then
			table.insert(newPetIds, petId)
		end
	end

	if fifthPetId then
		table.insert(newPetIds, fifthPetId)
	end

	pg.me:setRoguePets(newPetIds)
	pg.me:setRogueLevelHistoryBattlePet(self.levelId, newPetIds)
	self:refreshListPet(newPetIds)
end

function TowerLevelDetailCtrl:getSelectedRoguePetIds()
	return pg.me:getCurSelectPets(self.levelId)
end

function TowerLevelDetailCtrl:close()
	if self.isCloseing then
		return
	end

	self.isCloseing = true

	UIUtils.PlayAnimation(self.view.rootAnimation, self.view:getEndAnimName(self.elementType), function()
		UICtrl.close(self)
	end)
end

function TowerLevelDetailCtrl:initUI()
	local isRewardUp = ClientActivityUtils.isRogueRewardUpWithRemainTimes()

	self.view.btnInfoUButton:SetActive(isRewardUp)
	self.view.iconUp3UContainer:SetActive(isRewardUp)
	ClientActivityUtils.initRogueRewardUpWidget(self.view.doubleRewardUWidget)
	ClientActivityUtils.initRogueRewardUpWidget(self.view.startDoubleRewardUWidget)

	local hasChallenge = pg.me.curRogueLayer > 0

	if hasChallenge then
		self.view.rootUComponent:TryChangePage("Status", 1)
	end

	ClientTextUtils.setText(self.view.fastTrainBtnUText, pg.getGameString("TOWER_FAST_TRAIN_TITLE"))

	function self.view.styleItemUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewards(button, index, data)
	end

	function self.view.listPetNewUList.luaRenderItem(button, index, data)
		button.enabledTooltip = false

		if data.tIndex == 0 then
			LuaUIUtils.renderPetHeadRound(button, data, index + 1)
			button:TryChangePage("Dead", 0)
		end
	end

	function self.view.listPetNewUList.luaClick()
		local hasChallenge = pg.me.curRogueLayer > 0

		if hasChallenge then
			pg.global.ui.tips:showTextTip(pg.getGameString("TOWER_FORBID_CHANGE_PET"))

			return
		end

		pg.global.ui.petManagement:open({
			isRogue = true,
			levelId = self.levelId
		}, nil, nil, nil, nil, true)
	end

	function self.view.levelUList.luaRenderItem(button, index, data)
		self:renderLevelItem(button, index, data)
	end

	function self.view.levelUList.luaClick(button, data)
		local isUnlock, reason = RogueUtils.checkLevelUnlock(data.levelId)

		if not isUnlock then
			pg.global.ui.tips:showTextTip(reason)

			return
		end

		local styleId = pg.me.rogueInitSeriesInfo.curSeries

		if styleId and styleId > 0 then
			return
		end

		self.levelId = data.levelId

		self:recordWeeklySelectedDifficulty(self.levelId)
		self:refreshLevelBaseInfo()
		self:refreshListPet()
		self:tryClearRedDot(button, data.levelId)
	end

	function self.view.levelUList.luaCheckCanSelected(data)
		local styleId = pg.me.rogueInitSeriesInfo.curSeries

		if styleId and styleId > 0 and RogueUtils.getCurRogueLevel() ~= data.levelId then
			return false
		end

		return RogueUtils.checkLevelUnlock(data.levelId)
	end

	function self.view.levelUList.luaFinishRender()
		if self.firstOpen then
			for index, levelId in ipairs(self.levelIds) do
				if levelId == self.levelId then
					local found, item = self.view.levelUList:TryGetChildAt(index - 1)

					if found and not IsNil(item) then
						item:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
					end

					break
				end
			end
		end
	end

	self:refreshLevelBaseInfo(true)
	self:refreshLevelList()
	self:refreshListPet()
	self:refreshChallengeState()
end

function TowerLevelDetailCtrl:refreshLevelBaseInfo(isInit)
	local difficultyCfg = RogueDifficultyData[self.levelId]

	if not difficultyCfg then
		return
	end

	ClientTextUtils.setText(self.view.levelTitleUBaseText, pg.getLocalizationText(difficultyCfg.levelName))

	local recommendLevel = difficultyCfg.recommendLv

	ClientTextUtils.setText(self.view.levelLvUBaseText, "Lv." .. recommendLevel)

	local recommendEles = difficultyCfg.recommendType or {}

	if self.petGroupSelectorOptions then
		self.petGroupSelectorOptions.recommendElements = recommendEles
	end

	LuaUIUtils.renderPetElement(self.view.listElementUList, recommendEles)

	self.view.bossImagePro.url = difficultyCfg.interfacePoster
	self.elementType = difficultyCfg.elementType or 0

	self.view.rootUComponent:TryChangePage("Property", self.view:getPropertyValue(self.elementType))

	if isInit then
		UIUtils.PlayAnimation(self.view.rootAnimation, self.view:getStartAnimName(self.elementType))
	end

	self.view.btnStarUButton:TryChangePage("finish", RogueUtils.checkLevelPass(self.levelId) and 1 or 0)
	self:refreshReward(difficultyCfg)

	if isInit then
		local tips = self:getElementLevelPassResultText(RogueDifficultyData[self.levelId].elementType)

		ClientTextUtils.setText(self.view.textUSDFText, tips)
		ClientTextUtils.setText(self.view.text2USDFText, tips)
	end
end

function TowerLevelDetailCtrl:refreshLevelList()
	local data = {}

	for index, levelId in ipairs(self.levelIds) do
		local state = 1

		if index == 1 then
			state = 0
		elseif index == #self.levelIds then
			state = 2
		end

		table.insert(data, {
			levelId = levelId,
			state = state,
			selected = levelId == self.levelId
		})
	end

	self.view.btnSwitchUButton:TryChangePage("Option", #data > 1 and 0 or 1)
	self.view.btnSwitchUButton:TryChangePage("State", #data > 1 and 1 or 0)

	if #data == 1 then
		local difficultyCfg = RogueDifficultyData[data[1].levelId]

		ClientTextUtils.setText(self.view.levelUBaseText, pg.getLocalizationText(difficultyCfg.difficulty))

		return
	end

	self.view.levelUList:SetList(data)
end

function TowerLevelDetailCtrl:renderLevelItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local levelUBaseText = objectReference:GetRefValue("levelUBaseText")
	local btnStarUButton = objectReference:GetRefValue("btnStarUButton")
	local rootUButton = objectReference:GetRefValue("rootUButton")
	local difficultyCfg = RogueDifficultyData[data.levelId]
	local isLast = difficultyCfg.difficultyLabel == 3

	btnStarUButton:TryChangePage("State", isLast and 1 or 0)
	ClientTextUtils.setText(levelUBaseText, pg.getLocalizationText(difficultyCfg.difficulty))
	btnStarUButton:TryChangePage("finish", RogueUtils.checkLevelPass(data.levelId) and 1 or 0)

	local hasUnlock = RogueUtils.checkLevelUnlock(data.levelId)

	rootUButton:TryChangePage("LockState", hasUnlock and 0 or 1)
	rootUButton:TryChangePage("Status", data.state)

	local treePath = RedDotConst.RedDotPath.TOWER_LEVEL_ITEM .. data.levelId
	local showNew = hasUnlock and pg.me:getRedDotRecord(Const.CLIENT_KEY.ROGUE, treePath, true)

	if showNew then
		self.showNewLevelIds[data.levelId] = true
	end

	pg.global.setRedDot(treePath, button, showNew, RedDotConst.RedDotStyle.NEW)
end

function TowerLevelDetailCtrl:refreshChallengeState()
	if self.isCloseing then
		return
	end

	local hasChallenge = pg.me.curRogueLayer > 0

	if not IsNil(self.view.btnSwitchUSelector) then
		self.view.btnSwitchUSelector.interactable = not hasChallenge

		if hasChallenge then
			self.view.btnSwitchUSelector:ClosePopup(true)
		end
	end

	local text = hasChallenge and pg.getGameString("TOWER_CONTINUE_COMBAT") or pg.getGameString("TOWER_START_COMBAT")

	ClientTextUtils.setText(self.view.startCombatNameUBaseText, text)
	self.view.startUWidget:SetActive(hasChallenge)
	self:refreshSelectedStyleInfo()
end

function TowerLevelDetailCtrl:refreshListPet(battlePetIds)
	local data = {
		{
			tIndex = 1,
			isEmpty = true
		},
		{
			tIndex = 1,
			isEmpty = true
		},
		{
			tIndex = 1,
			isEmpty = true
		},
		{
			tIndex = 1,
			isEmpty = true
		},
		{
			isEmpty = true,
			tIndex = RogueTalentUtils.func(pg.me, "rogueExtraSlot") and 1 or 2
		}
	}

	if battlePetIds == nil then
		battlePetIds = pg.me:getCurSelectPets(self.levelId)
	end

	for index, petId in ipairs(battlePetIds) do
		local pet = pg.me.pets[petId]

		if pet and data[index].tIndex ~= 2 then
			data[index] = LuaUIUtils.generatePetInfo(pet)
			data[index].tIndex = 0
		end
	end

	self.view.listPetNewUList:SetList(data)
end

function TowerLevelDetailCtrl:refreshReward(difficultyCfg)
	local hasGetFirst = pg.me.rogueSettlementCnt[difficultyCfg.roguelikeIDEnd] and pg.me.rogueSettlementCnt[difficultyCfg.roguelikeIDEnd] > 0
	local dropFirstData = {}

	if difficultyCfg.firstClearReward then
		table.insert(dropFirstData, {
			dropId = difficultyCfg.firstClearReward,
			hasGet = hasGetFirst
		})
	end

	LuaUIUtils.setRewardListByDropId(self.view.listFirstRewardUList, difficultyCfg.firstClearReward, 5, hasGetFirst)
	self.view.firstUWidget:SetActive(#dropFirstData > 0)

	local dropData = {}

	if difficultyCfg.clearReward then
		table.insert(dropData, {
			dropId = difficultyCfg.clearReward
		})
	end

	LuaUIUtils.setRewardListByDropIds(self.view.listRewardItemUList, dropData)
end

function TowerLevelDetailCtrl:refreshSelectedStyleInfo()
	local styleId = pg.me.rogueInitSeriesInfo.curSeries
	local showStyle = styleId ~= nil and styleId >= 0

	self.view.startUWidget:SetActive(showStyle)
	LuaUIUtils.setUIVisible(self.view.firstUWidget, not showStyle)
	LuaUIUtils.setUIVisible(self.view.toastUComponent, not showStyle)
	self.view.rootUComponent:TryChangePage("Ready", showStyle and 1 or 0)
	self:refreshConsoleBarState()

	if showStyle then
		self.view.safeBoxMobileAnimation:Play()
		self.view.btnSwitchUButton:SetActiveFastest(false)
	else
		self.view.btnCombatStyleUButton.renderOpacity = 1

		self.view.btnSwitchUButton:SetActiveFastest(true)
	end

	RogueUtils.refreshSelectedStyleInfo(self, styleId, true)
end

function TowerLevelDetailCtrl:tryClearRedDot(button, levelId)
	if button then
		local treePath = RedDotConst.RedDotPath.TOWER_LEVEL_ITEM .. levelId

		pg.global.setRedDot(treePath, button, false)
		pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, treePath, false)
	end
end

function TowerLevelDetailCtrl:tryClearAllRedDot()
	for levelId, _ in pairs(self.showNewLevelIds) do
		local treePath = RedDotConst.RedDotPath.TOWER_LEVEL_ITEM .. levelId

		pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, treePath, false)
	end
end

function TowerLevelDetailCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_ROG_LEVEL_SELECT] = true

	return whiteList
end

function TowerLevelDetailCtrl:onDestroy()
	self:tryClearAllRedDot()

	if self.petInfoTipPresenter then
		self.petInfoTipPresenter:destroy()

		self.petInfoTipPresenter = nil
	end

	self.cacheFocus = nil

	UICtrl.onDestroy(self)
end

function TowerLevelDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerLevelDetailCtrl:onShow()
	pg.global.ui.tips:hideDropHint()
end

function TowerLevelDetailCtrl:onHide()
	return
end

function TowerLevelDetailCtrl:onFastTrainClick()
	if not RogueUtils.checkLevelPass(self.levelId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("TOWER_FAST_TRAIN_NEED_PASS"))

		return
	end

	local isSweepUnlocked = RogueTalentUtils.func(pg.me, "rogueUnlockSweep")

	if not isSweepUnlocked then
		local title = pg.getGameString("TOWER_FAST_TRAIN_UNLOCK_TITLE")
		local desc = pg.getGameString("TOWER_FAST_TRAIN_UNLOCK_DESC")

		pg.global.showConfirmMsgRaw(title, desc, function()
			local sweepNodeId = self:getSweepTalentNodeId()

			self:close()
			pg.global.ui:open(UIConst.UI_ID_ROG_LEVEL_SELECT, {
				focusTalentId = sweepNodeId
			})
		end)
	else
		pg.global.ui:open(UIConst.UI_ID_TOWER_FAST_TRAIN, {
			levelId = self.levelId
		})
	end
end

function TowerLevelDetailCtrl:getSweepTalentNodeId()
	local unlockSweepNodes = TalentEventData.unlockSweep or {}

	for _, nodeId in ipairs(unlockSweepNodes) do
		if not pg.me.rogueTalentLevelUnlock[nodeId] then
			return nodeId
		end
	end

	return unlockSweepNodes[1]
end

function TowerLevelDetailCtrl:refreshConsoleBarState()
	if not pg.global.navMgr then
		return
	end

	local hasChallenge = pg.me.curRogueLayer > 0
	local styleId = pg.me.rogueInitSeriesInfo.curSeries
	local showStyle = styleId ~= nil and styleId >= 0
	local show = not hasChallenge and showStyle

	pg.global.navMgr:SetConsoleBarState("TowerLevelDetail_isSelect", show, true)
end

function TowerLevelDetailCtrl:onNavFocusChange()
	self:refreshConsoleBarState()
end

return TowerLevelDetailCtrl
