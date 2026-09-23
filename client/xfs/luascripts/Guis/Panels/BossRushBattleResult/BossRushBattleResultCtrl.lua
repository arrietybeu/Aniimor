-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBattleResult\\BossRushBattleResultCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("BossRushBattleResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PuppetData = require("Data.puppet_data")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local BossRushBattleResultCtrl = Class.LightClass("BossRushBattleResultCtrl", UICtrl)
local SysConfigData = require("Data.sys_config_data")
local BossRushFunData = require("Data.bossrush_fun_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local BossRushUtils = require("Utils.BossRushUtils")
local HotKeyConst = require("Const.HotKeyConst")
local UIConst = require("Const.UIConst")
local AvatarRobotData = require("Data.avatar_robot_data")
local TEAMMATE_LEAVE_AI_REMIND_ID = 130

BossRushBattleResultCtrl.messages = {}

function BossRushBattleResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.cycleData = BossRushCycleData[pg.me.curBossRushCycleId]
	self.levelId = info.levelId
	self.result = info.result
	self.playerSnapshots = info.playerSnapshots or EMPTY_TABLE
	self.lastHitTypeIndex = 4
	self.autoCloseTime = SysConfigData.BossRushResultWaitTime or 150
	self.delayCloseTime = 0.2

	self:initUI()
end

function BossRushBattleResultCtrl:addListener()
	function self.view.btnExitUButton.luaClick()
		if self.forbidClose then
			return
		end

		self:close()
	end

	function self.view.btnViewDataUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_BATTLE_DETAIL_RESULT, {
			finalFunData = self.finalFunData,
			result = self.result,
			levelId = self.levelId,
			lastCountDown = self.view.countDownUCountDown.currentSecond
		})
	end
end

function BossRushBattleResultCtrl:initUI()
	local bossData = BossRushLevelData[self.levelId]

	if not bossData or not bossData.bossId then
		self:close()

		return
	end

	local bossInfo = PuppetData[bossData.bossId]

	if not bossInfo then
		self:close()

		return
	end

	local needShowAiBtn = self.result and self.result.subReason == 3 and BossRushUtils.canAddBotPlayer()

	ClientTextUtils.setText(self.view.btnAiHelpUText, pg.getGameString("BOSS_RUSH_ESC_AI_ADD"))
	ClientTextUtils.setText(self.view.btnExitUText, pg.getGameString("BOSS_RUSH_ESC_BACK"))
	ClientTextUtils.setText(self.view.bossNameUBaseText, pg.getLocalizationText(bossInfo.BossShowName or ""))

	local star = self.result and self.result.grade or 0
	local isStarNew = pg.me.curBossRushCycBossBestGrades[bossData.bossId] and star > pg.me.curBossRushCycBossBestGrades[bossData.bossId]

	self.view.result1UButton:TryChangePage("isNew", isStarNew and 1 or 0)
	ClientTextUtils.setText(self.view.starUBaseText, star)

	local score = self.result and self.result.score or 0
	local isScoreNew = pg.me.curBossRushCycBossBestScores[bossData.bossId] and score > pg.me.curBossRushCycBossBestScores[bossData.bossId]

	self.view.result2UButton:TryChangePage("isNew", isScoreNew and 1 or 0)
	ClientTextUtils.setText(self.view.scoreUBaseText, math.floor(score))

	local time = self.result and self.result.costtm or 0

	self.view.result3UButton:TryChangePage("isNew", 0)

	time = math.min(SysConfigData.BossRushCombatDuration, math.ceil(time))

	ClientTextUtils.setText(self.view.timeUBaseText, time, "s")

	function self.view.playerUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
		local descUBaseText = objectReference:GetRefValue("descUBaseText")
		local scoreUBaseText = objectReference:GetRefValue("scoreUBaseText")
		local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if data.score then
			ClientTextUtils.setText(scoreUBaseText, math.floor(data.score))
		else
			scoreUBaseText:SetActive(false)
		end

		local recordInfo = BossRushUtils.startBattlePlayerRecord[data.pId] or {}
		local ent = pg.getEntity(data.pId)
		local playerSnapshot = data.playerSnapshot
		local playerName = playerSnapshot.playerName

		if data.isAi then
			local robotData = AvatarRobotData[playerSnapshot.botTemplateId]

			if robotData and robotData.name then
				playerName = pg.getLocalizationText(robotData.name)
			end
		end

		local _h = BossRushBattleResultCtrl._platformHooks

		playerName = _h and _h.getMaskedPlayerName and _h.getMaskedPlayerName(self, data, recordInfo, ent, playerName) or playerName

		ClientTextUtils.setText(playerNameUBaseText, playerName)

		local order = data.order or pg.me:getTeamOrderByEntityId(data.pId) or recordInfo.order or 1

		button:TryChangePage("Teammate", order - 1)

		local cfg = BossRushFunData[data.type]

		ClientTextUtils.setText(titleUBaseText, cfg and pg.getLocalizationText(cfg.name) or "")
		ClientTextUtils.setText(descUBaseText, cfg and pg.getLocalizationText(cfg.desc) or "")

		local petInfo = playerSnapshot.petInfo

		if petInfo then
			iconUImage.url = LuaUIUtils.getPetIcon(PetData[petInfo.templateId].iconName, LuaUIUtils.PET_ICON, petInfo.label)
		end
	end

	self.finalFunData = self:parseFunData()

	self.view.playerUList:SetList(self.finalFunData)
	self.view.countDownUCountDown:Play(self.autoCloseTime)
	self:startTimer(function()
		self:close()
	end, self.autoCloseTime)

	self.forbidClose = true

	self:startTimer(function()
		self.forbidClose = false
	end, self.delayCloseTime)
end

function BossRushBattleResultCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function BossRushBattleResultCtrl:parseFunData()
	local funData = {}
	local serverDatas = self.result.batFunData or {}

	for index, data in ipairs(serverDatas) do
		if index == self.lastHitTypeIndex then
			if data[1] then
				table.insert(funData, {
					pId = data[1],
					type = index,
					priority = BossRushFunData[index] and BossRushFunData[index].funWeight[1] or 0
				})
			end
		else
			local tempData = {}

			for pId, score in pairs(data) do
				table.insert(tempData, {
					score = score,
					pId = pId,
					type = index
				})
			end

			table.sort(tempData, function(a, b)
				return a.score > b.score
			end)

			for i, sortData in ipairs(tempData) do
				sortData.priority = BossRushFunData[index] and BossRushFunData[index].funWeight[i] or 0

				table.insert(funData, sortData)
			end
		end
	end

	table.sort(funData, function(a, b)
		return a.priority > b.priority
	end)

	return self:buildFinalFunData(funData, serverDatas)
end

function BossRushBattleResultCtrl:buildFinalFunData(funData, serverDatas)
	local funType = Const.BossRushSettleFunType
	local lastStrikePId = serverDatas[funType.AttackLast] and serverDatas[funType.AttackLast][1]
	local lastStrikePIdKey = lastStrikePId and tostring(lastStrikePId)
	local bestFunData = {}

	for _, data in ipairs(funData) do
		local key = data.pId and tostring(data.pId)

		if key and not bestFunData[key] then
			bestFunData[key] = data
		end
	end

	local function getServerValue(typeIndex, pId)
		local serverData = serverDatas[typeIndex]

		if not serverData or not pId then
			return 0
		end

		return serverData[pId] or serverData[tostring(pId)] or serverData[tonumber(pId)] or 0
	end

	local finalFunData = {}

	for index, playerData in ipairs(self.playerSnapshots) do
		local pId = playerData.pId
		local key = tostring(pId)
		local isAi = playerData.isAi
		local data = bestFunData[key]
		local totalDamage = getServerValue(funType.TotalDamage, pId)
		local costTime = self.result.costtm or 0
		local dps = costTime > 0 and totalDamage / costTime or totalDamage
		local statistic = {
			{
				value = math.floor(dps)
			},
			{
				value = math.floor(getServerValue(funType.AttackBreakMost, pId))
			},
			{
				value = math.floor(getServerValue(funType.BearMostDamage, pId))
			},
			{
				value = math.floor(getServerValue(funType.CauseMostCure, pId))
			}
		}

		if not data then
			data = {
				type = 1,
				priority = 1,
				score = 0,
				pId = pId,
				statistic = statistic,
				isAi = isAi
			}
		else
			data.statistic = statistic
			data.isLastStrike = lastStrikePIdKey ~= nil and key == lastStrikePIdKey
			data.isAi = isAi
		end

		data.order = playerData.order or index
		data.uid = playerData.uid
		data.playerSnapshot = playerData.playerSnapshot

		table.insert(finalFunData, data)
	end

	return finalFunData
end

function BossRushBattleResultCtrl:onDestroy()
	local currentPlayerCount = pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1

	if currentPlayerCount < BossRushUtils.startBattlePlayerCount then
		pg.me:doEventByData({
			"startAIRemind",
			{
				TEAMMATE_LEAVE_AI_REMIND_ID
			}
		})
	end

	UICtrl.onDestroy(self)
end

function BossRushBattleResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BossRushBattleResultCtrl:onShow()
	return
end

function BossRushBattleResultCtrl:onHide()
	return
end

return BossRushBattleResultCtrl
