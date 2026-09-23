-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerRogueComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local RandomBuffData = require("Data.random_buff_data")
local BuffConfigData = require("Data.buff_config_data")
local ExtraRandomBuff = require("Data.extra_random_buff")
local DungeonConst = require("Common.Const.DungeonConst")
local RoguelikeData = require("Data.roguelike_data")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("Rogue")
local Utils = require("Common.Utils.Utils")
local RogueUtils = require("Utils.RogueUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local CommonSwitch = require("Common.CommonSwitch")
local CallbackHandler = require("Core.Common.CallbackHandler")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local ClientPlayerRogueComponent = Class.Component("ClientPlayerRogueComponent")

function ClientPlayerRogueComponent:ctor()
	self:clientInit()
end

function ClientPlayerRogueComponent:init(dict)
	return true
end

function ClientPlayerRogueComponent:isRogueElementAllLevelPassed(elementType)
	local hasLevel = false
	local weeklyLevelPassInfo = self.rogueWeeklyLevelPassInfo or {}

	for levelId, levelCfg in ipairs(RogueDifficultyData) do
		if levelCfg.elementType == elementType then
			hasLevel = true

			if not weeklyLevelPassInfo[levelId] then
				return false
			end
		end
	end

	return hasLevel
end

local function sortFunc(a, b)
	if a.buffQuality == b.buffQuality then
		return a.buffSeries < b.buffSeries
	end

	return a.buffQuality > b.buffQuality
end

function ClientPlayerRogueComponent:getRogueBuffLists()
	local curBuffList = self.rogueBuffs or {}
	local total = {}
	local data = {}

	for buffId, buffCount in pairs(curBuffList) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

		if data[buffCfg.buffSeries] == nil then
			data[buffCfg.buffSeries] = {}
		end

		local buffCfg2 = BuffConfigData[buffId]
		local buffName, buffDesc = RogueUtils.getBuffNameAndDesc(buffId, buffCount)
		local item = {
			buffId = buffId,
			buffCount = buffCount,
			buffName = buffName,
			buffDesc = buffDesc,
			buffIcon = buffCfg.buffIcon,
			buffQuality = buffCfg.buffRarity or buffCfg.buffLv,
			buffSeries = buffCfg.buffSeries,
			buffTagIcon = buffCfg.buffTagIcon
		}

		item.showQuality = item.buffQuality

		if item.showQuality == Const.RogueBuffQuality.Equipment and buffCount >= buffCfg.maxLayer then
			item.showQuality = Const.RogueBuffQuality.Boss
		end

		table.insert(data[buffCfg.buffSeries], item)
		table.insert(total, item)
	end

	data[DungeonConst.ROGUE_ALL_BUFF_TYPE_ID] = total

	for _, subData in pairs(data) do
		table.sort(subData, sortFunc)
	end

	return data
end

function ClientPlayerRogueComponent:getRogueBuffListWithType(type)
	return self:getRogueBuffLists()[type] or {}
end

function ClientPlayerRogueComponent:getRogueBuffListWithBuffId(buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

	if buffCfg == nil then
		return {}
	end

	return self:getRogueBuffListWithType(buffCfg.buffSeries)
end

function ClientPlayerRogueComponent:getRogueBuffCount(type, buffId)
	local buffs = {}

	if type then
		buffs = self:getRogueBuffListWithType(type)
	elseif buffId then
		buffs = self:getRogueBuffListWithBuffId(buffId)
	end

	local count = 0

	for index, value in ipairs(buffs) do
		if value.buffQuality < 3 then
			count = count + value.buffCount
		end
	end

	return count
end

function ClientPlayerRogueComponent:EVNET_OnMoneyChange(moneyType, oldValue, newValue)
	if moneyType == ItemConst.ITEM_SPECIAL_ROGUE_COIN then
		local changeValue = oldValue - newValue

		if self.subject then
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ROGUE_COIN_CHANGE, changeValue)
		end
	end
end

function ClientPlayerRogueComponent:getRogueBuffs()
	local curBuffList = self.rogueBuffs or {}
	local data = {}

	for buffId, buffCount in pairs(curBuffList) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]
		local buffCfg2 = BuffConfigData[buffId]
		local buffName, buffDesc = RogueUtils.getBuffNameAndDesc(buffId, buffCount)

		table.insert(data, {
			buffId = buffId,
			buffCount = buffCount,
			buffName = buffName,
			buffDesc = buffDesc,
			buffIcon = buffCfg.buffIcon,
			buffQuality = buffCfg.buffRarity or buffCfg.buffLv,
			buffSeries = buffCfg.buffSeries,
			buffTagIcon = buffCfg.buffTagIcon
		})
	end

	table.sort(data, sortFunc)

	return data
end

function ClientPlayerRogueComponent:onRogueTalentLevelUnlockChanged(ov, nv)
	facade:sendMsgToUI(MessageName.ROGUE_TALENT_LEVEL_UNLOCK_UPDATE)
end

function ClientPlayerRogueComponent:onRogueTalentNodeLvMapChanged(ov, nv)
	facade:sendMsgToUI(MessageName.ROGUE_TALENT_LEVEL_UNLOCK_UPDATE)
end

function ClientPlayerRogueComponent:onRogueTalentExpChanged(ov, nv)
	facade:sendMsgToUI(MessageName.ROGUE_TALENT_EXP_UPDATE)
end

function ClientPlayerRogueComponent:onRogueWeeklyBossKillCountChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRogueWeeklyBossKillCount_changed ov:%s, nv:%s", inspect(ov), inspect(nv))
	end
end

function ClientPlayerRogueComponent:onRogueWeeklyBossRewardInfoChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRogueWeeklyBossRewardInfo_changed ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	facade:sendMsgToUI(MessageName.ROGUE_WEEKLY_REWARD_UPDATE, {})
end

function ClientPlayerRogueComponent:onRogueSeasonIdChanged(ov, nv)
	self:clearTowerLevelDetailWeeklyRecordCache()
	ClientActivityUtils.refreshMockBattleRedDot()
	facade:sendMsgToUI(MessageName.ROGUE_SEASON_CHANGE, {
		oldV = ov,
		newV = nv
	})
end

function ClientPlayerRogueComponent:onRogueSeasonLevelPassInfoChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRogueSeasonLevelPassInfoChanged ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	ClientActivityUtils.refreshMockBattleRedDot()
	facade:sendMsgToUI(MessageName.ROGUE_SEASON_WEEKLY_REWARD_UPDATE, {})
end

function ClientPlayerRogueComponent:onRogueWeeklyLevelPassInfoChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRogueWeeklyLevelPassInfoChanged ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	ClientActivityUtils.refreshMockBattleRedDot()
	facade:sendMsgToUI(MessageName.ROGUE_SEASON_WEEKLY_REWARD_UPDATE, {})
end

function ClientPlayerRogueComponent:onRogueWeeklyLevelRewardInfoChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onRogueWeeklyLevelRewardInfoChanged ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	ClientActivityUtils.refreshMockBattleRedDot()
	facade:sendMsgToUI(MessageName.ROGUE_SEASON_WEEKLY_REWARD_UPDATE, {})
end

function ClientPlayerRogueComponent:onCurRogueLayerChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCurLayer_changed ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	facade:sendMsgToUI(MessageName.ROGUE_LAYER_CHANGE, {})
end

function ClientPlayerRogueComponent:onCurRogueLevelChanged(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCurLevel_changed ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	facade:sendMsgToUI(MessageName.ROGUE_LEVEL_CHANGE, {})
end

function ClientPlayerRogueComponent:onRogueDataValueChange(ov, nv, name)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ROGUE_PERSIST_DATA_CHANGE, name, ov - nv)
	facade:sendMsgToUI(MessageName.ROGUE_COMBAT_DATA_CHANGE, {
		key = name
	})
end

function ClientPlayerRogueComponent:onRogueDataValueAdd(name, value)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ROGUE_PERSIST_DATA_CHANGE, name, value)
	facade:sendMsgToUI(MessageName.ROGUE_COMBAT_DATA_CHANGE, {
		key = name
	})
end

function ClientPlayerRogueComponent:onRogueDataValueRemove(name, value)
	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ROGUE_PERSIST_DATA_CHANGE, name, -value)
	facade:sendMsgToUI(MessageName.ROGUE_COMBAT_DATA_CHANGE, {
		key = name
	})
end

function ClientPlayerRogueComponent:onRogueBuffsValueAdd(buffId, v)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]
	local buffQuality = buffCfg.buffRarity or buffCfg.buffLv

	if buffQuality == Const.RogueBuffQuality.Equipment then
		facade:sendMsgToUI(MessageName.ROGUE_EQUIPMENT_CHANGE)
	end
end

function ClientPlayerRogueComponent:onRogueBuffsValueRemove(buffId, v)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]
	local buffQuality = buffCfg.buffRarity or buffCfg.buffLv

	if buffQuality == Const.RogueBuffQuality.Equipment then
		facade:sendMsgToUI(MessageName.ROGUE_EQUIPMENT_CHANGE)
	end
end

function ClientPlayerRogueComponent:onRogueBuffsValueChanged(oldVal, newVal, buffId)
	local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]
	local buffQuality = buffCfg.buffRarity or buffCfg.buffLv

	if buffQuality == Const.RogueBuffQuality.Equipment then
		facade:sendMsgToUI(MessageName.ROGUE_EQUIPMENT_CHANGE)
	end
end

function ClientPlayerRogueComponent:onCurOptionListChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.ROGUE_EVENT_DIALOGUE_DATA_UPDATE)
end

function ClientPlayerRogueComponent:onRogueHarvestPendingRewardsChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.ROGUE_DAILY_REWARD_UPDATE)
end

function ClientPlayerRogueComponent:setRoguePets(petIds)
	self:serverMsg("RPC_CS_SelectRoguePets", petIds)
end

function ClientPlayerRogueComponent:startRogue(dungeonId)
	if CommonSwitch.ROGUELIKE == false then
		local tipText = pg.getGameString("FUNCTION_NOT_OPEN")

		pg.global.ui.tips:showTextTip(tipText)

		return
	end

	self:serverMsg("RPC_CS_StartRogue", dungeonId)
end

function ClientPlayerRogueComponent:reStartRogue(dungeonId)
	self:serverMsg("RPC_CS_ReStartRogue", dungeonId)
end

function ClientPlayerRogueComponent:startRandomRogue(staticId)
	self:serverMsg("RPC_CS_StartRandomRogue", staticId)
end

function ClientPlayerRogueComponent:resetRogue()
	self:serverMsg("RPC_CS_ResetRogue")
	pg.me:setRedDotRecord(Const.CLIENT_KEY.ROGUE, RedDotConst.RedDotPath.TOWER_TALENT_LEVEL .. "needCheck", 1)
	facade:sendMsgToUI(MessageName.ROGUE_TALENT_RED_DOT_UPDATE)
	self:clientClear()
end

function ClientPlayerRogueComponent:clientInit()
	return
end

function ClientPlayerRogueComponent:clientClear()
	RogueUtils.randomStyleRevealed = false

	pg.global.prefsCacheUtils:deleteKey(ClientConst.PrefKey.RogueBattleCountDown)
end

function ClientPlayerRogueComponent:getRogueBattleRecord()
	self:serverMsg("RPC_CS_GetRogueCombatStatistic", function(resultA, resultB)
		local battleData = Utils.deepCopyTable(resultA)

		for buffId, info in pairs(resultB.buff) do
			if battleData.buff[buffId] then
				local curInfo = battleData.buff[buffId]

				curInfo.damage = curInfo.damage + info.damage
				curInfo.heal = curInfo.heal + info.heal
				curInfo.takenDamage = curInfo.takenDamage + info.takenDamage
			else
				battleData.buff[buffId] = info
			end
		end

		for petId, info in pairs(resultB.pet) do
			if battleData.pet[petId] then
				local curInfo = battleData.pet[petId]

				curInfo.damage = curInfo.damage + info.damage
				curInfo.heal = curInfo.heal + info.heal
				curInfo.takenDamage = curInfo.takenDamage + info.takenDamage
			else
				battleData.pet[petId] = info
			end
		end

		for bossId, info in pairs(resultB.tempPet) do
			if battleData.tempPet[bossId] then
				local curInfo = battleData.tempPet[bossId]

				curInfo.damage = curInfo.damage + info.damage
				curInfo.heal = curInfo.heal + info.heal
				curInfo.takenDamage = curInfo.takenDamage + info.takenDamage
			else
				battleData.tempPet[bossId] = info
			end
		end

		facade:sendMsgToUI(MessageName.ROGUE_RECV_COMBAT_RECORD, {
			battleData = battleData
		})
	end)
end

function ClientPlayerRogueComponent:RPC_SC_StartRogue()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_EVENT_DIALOGUE) then
		pg.global.ui:close(UIConst.UI_ID_TOWER_EVENT_DIALOGUE)
	end

	if pg.space:isRogueEnv() then
		pg.space:executeCacheInfo()
	end

	pg.me:playRougeSceneScan(true)
end

function ClientPlayerRogueComponent:RPC_SC_AddRogueUltimateAbility(abilityId)
	logger:info("RPC_SC_AddRogueUltimateAbility abilityId:%s, series:%s", abilityId, pg.me.rogueUltimateSeries)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_HUD_V2) then
		pg.global.ui.hudV2:refreshSkillList()
	end

	if RogueUtils.isInRogueSpace() then
		local cacheInfo = {
			uid = UIConst.UI_ID_ROG_ULTIMATE_UNLOCK,
			abilityId = abilityId
		}

		pg.me.space:addCacheInfo(cacheInfo)
	end
end

function ClientPlayerRogueComponent:RPC_SC_UpgradeRogueUltimateAbility(abilityId, abilityLevel, randomBuffIds)
	return
end

function ClientPlayerRogueComponent:RPC_SC_BeforeRogueDiceReward()
	if not RogueUtils.isInRogueSpace() then
		return
	end

	pg.me.space:pauseCacheInfo()
end

function ClientPlayerRogueComponent:RPC_SC_SyncRogueDiceReward(coinCount, buffIdList, superRewardDropId)
	if coinCount > 0 or #buffIdList > 0 then
		pg.global.ui:open(UIConst.UI_ID_ROG_VENTURE_REWARD, {
			coinCount = coinCount,
			buffIdList = buffIdList,
			superRewardDropId = superRewardDropId
		})
	end
end

function ClientPlayerRogueComponent:playRougeSceneScan(playEffect)
	if not pg.me.space:isRogueEnv() then
		return
	end

	local ins = CS.FunPlus.WorldX.RenderingScripts.Effect.SceneSwitchManager.Ins

	if ins then
		local sceneLevelId = (RoguelikeData[self.space.dungeonId] or EMPTY_TABLE).sceneLevelId or 0

		if self.space.resetGroundReady then
			self.space:resetGroundReady()
		end

		ins:ChangeSceneLevelId(sceneLevelId, self:getPosition(), playEffect)

		if playEffect then
			pg.game.audio:playEvent("SFX_UI_Rouge_LoadScene")
		end
	end
end

function ClientPlayerRogueComponent:getCurSelectPetsInner(levelId)
	local data = {}

	if self.selectRoguePets and lume.getMapLen(self.selectRoguePets) > 0 then
		for petId, index in pairs(self.selectRoguePets) do
			data[index] = petId
		end

		return data
	end

	local historyInfo = self:getRogueLevelHistoryBattlePet(levelId)

	if historyInfo then
		for index, value in ipairs(historyInfo) do
			data[index] = value
		end

		return data
	end

	for index, value in ipairs(self.petPrepareList) do
		data[index] = value
	end

	return data
end

function ClientPlayerRogueComponent:getCurSelectPets(levelId)
	local data = self:getCurSelectPetsInner(levelId)
	local res = {}
	local maxControlLevel = pg.me:getMaxControlLevel()

	for _, petId in ipairs(data) do
		local petInfo = pg.me.pets[petId]

		if petInfo and maxControlLevel >= petInfo.level and not pg.me:isPetPutInHomeland(petInfo) then
			table.insert(res, petId)
		end
	end

	return res
end

function ClientPlayerRogueComponent:getRogueLevelHistoryBattlePet(levelId)
	local dict = self:getClientInfo(Const.CLIENT_KEY.ROGUE, "pet_team")

	return dict[levelId]
end

function ClientPlayerRogueComponent:setRogueLevelHistoryBattlePet(levelId, pets)
	local dict = self:getClientInfo(Const.CLIENT_KEY.ROGUE, "pet_team")

	dict = dict or {}
	dict[levelId] = pets

	self:setClientInfo(Const.CLIENT_KEY.ROGUE, "pet_team", dict)
end

function ClientPlayerRogueComponent:getRogueTalentLastCheckLevel()
	return self:getClientInfo(Const.CLIENT_KEY.ROGUE, "talent")
end

function ClientPlayerRogueComponent:setRogueTalentLastCheckLevel(level)
	self:setClientInfo(Const.CLIENT_KEY.ROGUE, "talent", level)
end

function ClientPlayerRogueComponent:reqRogueExchangeReward(type)
	self:serverMsg("RPC_CS_ReqRogueExchangeReward", type)
end

function ClientPlayerRogueComponent:RPC_SC_ReqRogueExchangeRewardResult(code, normalItemCount, upItemCount, normalInstances, upInstances)
	facade:sendMsgToUI(MessageName.EXCHANGE_REWARD_RESULT, {
		code = code
	})

	local itemList = {}

	local function appendItems(itemCountDict, instances, isUpReward)
		local instByItem = {}

		if instances then
			for _, inst in ipairs(instances) do
				if inst.itemId then
					instByItem[inst.itemId] = instByItem[inst.itemId] or {}

					lume.push(instByItem[inst.itemId], inst)
				end
			end
		end

		for itemId, count in pairs(itemCountDict) do
			local instList = instByItem[itemId]

			if instList then
				for _, inst in ipairs(instList) do
					table.insert(itemList, {
						itemId = itemId,
						itemCount = inst.count,
						genID = inst.genID,
						invId = inst.invId,
						isUpReward = isUpReward
					})
				end
			else
				table.insert(itemList, {
					itemId = itemId,
					itemCount = count,
					isUpReward = isUpReward
				})
			end
		end
	end

	appendItems(normalItemCount, normalInstances, nil)
	appendItems(upItemCount, upInstances, true)
	pg.global.ui.itemObtain:open({
		itemList = itemList
	})
end

function ClientPlayerRogueComponent:initRogueSeriesInfo(cb)
	self:serverMsg("RPC_CS_RandomRogueInitSeriesInfo", cb)
end

function ClientPlayerRogueComponent:selectRogueSeries(series)
	self:serverMsg("RPC_CS_SelectRogueSeries", series, function(result)
		facade:sendMsgToUI(MessageName.ROGUE_SELECT_SERIES)
	end)
end

function ClientPlayerRogueComponent:unlockTalent(id)
	self:serverMsg("RPC_CS_UnlockRogueTalentLevel", id)
end

function ClientPlayerRogueComponent:upgradeTalent(id)
	self:serverMsg("RPC_CS_UpgradeRogueTalentLevel", id)
end

function ClientPlayerRogueComponent:reqSweepLevel(levelId, trainTimes, trainType, cb)
	self:serverMsg("RPC_CS_ReqRogueSweepLevel", levelId, trainTimes, trainType, CallbackHandler(self, "_reqSweepLevelCallback", cb))
end

function ClientPlayerRogueComponent:_reqSweepLevelCallback(cb, success, errcode, rewardSummary)
	cb(success, rewardSummary)
end

function ClientPlayerRogueComponent:resetRogueTalent()
	self:serverMsg("RPC_CS_ResetRogueTalentLevel")
end

function ClientPlayerRogueComponent:getRogueWeeklyReward(configId)
	self:serverMsg("RPC_CS_GetRogueWeeklyKillBossReward", configId)
end

function ClientPlayerRogueComponent:getRogueAllWeeklyReward()
	self:serverMsg("RPC_CS_GetAllRogueWeeklyKillBossReward")
end

function ClientPlayerRogueComponent:getRogueSeasonWeeklyReward(levelId)
	self:serverMsg("RPC_CS_GetRogueWeeklyLevelReward", levelId)
end

function ClientPlayerRogueComponent:getAllRogueSeasonWeeklyReward(elementType)
	self:serverMsg("RPC_CS_GetAllRogueWeeklyLevelReward", elementType)
end

function ClientPlayerRogueComponent:getDailyReward()
	self:serverMsg("RPC_CS_ReqRogueHarvestCollectAll")
end

function ClientPlayerRogueComponent:selectRogueEventOption(eventId, optionId)
	self:serverMsg("RPC_CS_ReqRogueRandomEventChooseOption", eventId, optionId, CallbackHandler(self, "_selectRogueEventOptionCallback"))
end

function ClientPlayerRogueComponent:_selectRogueEventOptionCallback(result)
	return
end

function ClientPlayerRogueComponent:clearTowerLevelDetailWeeklyRecordCache()
	local clearedElementTypes = {}
	local cacheType = ClientConst.CACHE_TYPE_FLAG.USER

	for _, difficultyCfg in ipairs(RogueDifficultyData) do
		local elementType = difficultyCfg.elementType

		if elementType ~= nil and not clearedElementTypes[elementType] then
			clearedElementTypes[elementType] = true

			pg.global.prefsCacheUtils:deleteKey(string.format("%s_%s", ClientConst.PrefKey.TowerLevelDetailOpenWeek, elementType), cacheType)
			pg.global.prefsCacheUtils:deleteKey(string.format("%s_%s", ClientConst.PrefKey.TowerLevelDetailLastDifficulty, elementType), cacheType)
		end
	end
end

return ClientPlayerRogueComponent
