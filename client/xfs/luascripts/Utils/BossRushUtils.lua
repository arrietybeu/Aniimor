-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\BossRushUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local BossRushBuffData = require("Data.bossrush_buff_data")
local BossRushCycleData = require("Data.bossrush_cycle_data")
local BossRushLevelData = require("Data.bossrush_guanka_data")
local BossRushGradeData = require("Data.bossrush_grade_data")
local BossRushSeasonRewardData = require("Data.bossrush_season_reward_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushUITagData = require("Data.bossrush_ui_tag_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local ItemData = require("Data.item_data")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local PuppetData = require("Data.puppet_data")
local Utils = require("Common.Utils.Utils")
local BossRushConst = require("Common.Const.BossRushConst")
local RankUtils = require("Utils.RankUtils")
local BossRushUtils = {
	startBattlePlayerCount = 1,
	startBattlePlayerRecord = {}
}

function BossRushUtils.getDisplaySeasonId()
	local seasonId = pg.me.curBossRushSeasonId or 0

	if seasonId == 0 then
		seasonId = pg.me.nextBossRushSeasonId or 0
	end

	return seasonId
end

function BossRushUtils.getCycleData()
	local isOpen = BossRushUtils.checkIsOpen()

	if isOpen then
		return BossRushCycleData[pg.me.curBossRushCycleId]
	else
		return BossRushCycleData[pg.me.nextBossRushCycleId]
	end
end

function BossRushUtils.recordPlayerInfo(levelId)
	BossRushUtils.startBattlePlayerRecord = {}
	BossRushUtils.startBattlePlayerCount = pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1

	local teamInfo = pg.me:getCurTeamInfo()

	if not teamInfo.sortList then
		return
	end

	for index, uid in ipairs(teamInfo.sortList) do
		local memberInfo = teamInfo.membersInfo[uid]

		if memberInfo and memberInfo.entityId then
			local pLists = pg.space.teamerInfos[memberInfo.entityId] and pg.space.teamerInfos[memberInfo.entityId].levelBatPetList or {}

			BossRushUtils.startBattlePlayerRecord[memberInfo.entityId] = {
				uid = uid,
				playerName = memberInfo.playerName,
				order = index,
				pList = pLists[levelId]
			}
		end
	end
end

function BossRushUtils.buildBattleResultPlayerSnapshots(levelId)
	local playerSnapshots = {}
	local botIdSet = {}

	for _, botId in ipairs(pg.space and pg.space.playerBotUidList or EMPTY_TABLE) do
		botIdSet[tostring(botId)] = true
	end

	local playerIds = Utils.getTeamMemberEntIdWithBot(pg.me)

	for index, pId in ipairs(playerIds) do
		local recordInfo = BossRushUtils.startBattlePlayerRecord[pId] or EMPTY_TABLE
		local ent = pg.getEntity(pId)
		local teamerInfo = pg.space and pg.space.teamerInfos and pg.space.teamerInfos[pId]
		local levelBatPetList = teamerInfo and teamerInfo.levelBatPetList or EMPTY_TABLE
		local pList = levelBatPetList[levelId] or recordInfo.pList or EMPTY_TABLE
		local petInfo = pList[1]
		local isAi = botIdSet[tostring(pId)] == true

		playerSnapshots[#playerSnapshots + 1] = {
			pId = pId,
			uid = ent and ent.uid or recordInfo.uid,
			order = index,
			isAi = isAi,
			playerSnapshot = {
				playerName = ent and ent.playerName or recordInfo.playerName or "",
				botTemplateId = isAi and ent and ent.botTemplateId or nil,
				petInfo = petInfo and {
					templateId = petInfo.templateId,
					label = petInfo.label
				} or nil
			}
		}
	end

	return playerSnapshots
end

function BossRushUtils.getUnlockMingameBuffs()
	local res = {
		{
			isMiniGame = true,
			state = 2
		},
		{
			isMiniGame = true,
			state = 2
		}
	}
	local buffs = pg.me.space.unlockMingameBuffs or {}
	local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

	if buffs[cycleData.miniGameLeft] then
		res[1] = {
			state = 0,
			buffId = buffs[cycleData.miniGameLeft]
		}
	end

	if buffs[cycleData.miniGameRight] then
		res[2] = {
			state = 0,
			buffId = buffs[cycleData.miniGameRight]
		}
	end

	return res
end

function BossRushUtils.getLockBuffMap()
	local lockBuffMap = {}
	local seasonId = BossRushUtils.getDisplaySeasonId()

	if seasonId <= 0 then
		return lockBuffMap
	end

	for needStar, seasonBeginData in pairs(BossRushSeasonRewardData) do
		for seasonBegin, seasonEndData in pairs(seasonBeginData) do
			if seasonBegin <= seasonId then
				for seasonEnd, rewardData in pairs(seasonEndData) do
					local seasonBuffId = rewardData.seasonBuff
					local buffConfig = BossRushBuffData[seasonBuffId]
					local buffLevel = buffConfig and (buffConfig.Bufflevel or 1) or 1
					local baseBuffConfigId = seasonBuffId and seasonBuffId - buffLevel + 1

					if seasonId <= seasonEnd and baseBuffConfigId and baseBuffConfigId > 0 then
						if not lockBuffMap[baseBuffConfigId] then
							lockBuffMap[baseBuffConfigId] = {}
						end

						lockBuffMap[baseBuffConfigId][buffLevel] = needStar
					end
				end
			end
		end
	end

	return lockBuffMap
end

function BossRushUtils.getCurSeasonStar()
	local seasonData = pg.me and pg.me.curBossRushSeasonData

	if not seasonData then
		return 0
	end

	local totalStar = 0

	for _, cycleData in seasonData:items() do
		for _, grade in pairs(cycleData.bossBestGrade or EMPTY_TABLE) do
			totalStar = totalStar + grade
		end
	end

	return totalStar
end

function BossRushUtils.getSelectBatBuffs(isNew)
	local res = {
		{
			index = 0,
			state = 1,
			isNew = isNew or false
		}
	}
	local selectBuffs = pg.me.space.selectBatBuffs or {}

	if selectBuffs[1] then
		res[1].buffId = selectBuffs[1]
		res[1].state = 0
	end

	return res
end

function BossRushUtils.getHistoryRecordBatBuffs(isOpen, bossId)
	local res = {}
	local recordBuffs = {}

	if isOpen and bossId then
		local bossRecordBuffs = pg.me.curBossRushCycBestScoreBuffList or {}

		recordBuffs = bossRecordBuffs[bossId] or {}
	end

	if recordBuffs[1] then
		table.insert(res, {
			index = 0,
			state = 0,
			buffId = recordBuffs[1]
		})
	end

	return res
end

function BossRushUtils.getHistoryRecordSeasonBuffs(isOpen, bossId, isHistory)
	isHistory = isHistory or false

	local res = {}
	local recordBuffs = {}

	if isOpen and bossId then
		local bossRecordBuffs = pg.me.curBossRushCycBestScoreSeasonBatBuffList or {}

		recordBuffs = bossRecordBuffs[bossId] or {}
	end

	if recordBuffs[1] then
		table.insert(res, {
			index = 0,
			state = 0,
			buffId = recordBuffs[1],
			isHistory = isHistory
		})
	else
		table.insert(res, {
			index = 0,
			isUnlock = false,
			state = 0,
			buffId = 0,
			isHistory = isHistory
		})
	end

	if recordBuffs[2] then
		table.insert(res, {
			index = 0,
			state = 0,
			buffId = recordBuffs[2],
			isHistory = isHistory
		})
	else
		table.insert(res, {
			index = 0,
			isUnlock = false,
			state = 0,
			buffId = 0,
			isHistory = isHistory
		})
	end

	return res
end

function BossRushUtils.renderBuffItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	if data.isUnlock ~= nil then
		if data.isHistory then
			button:TryChangePage("Lock", data.isUnlock and 0 or 2)
		else
			button:TryChangePage("Lock", data.isUnlock and 0 or 1)
		end

		if data.level then
			button:TryChangePage("Level", 1)

			local textBuffLvUSDFText = objectReference:GetRefValue("textBuffLvUSDFText")

			ClientTextUtils.setText(textBuffLvUSDFText, ClientTextUtils.getGameString("LEVEL_LITE") .. data.level)
		end
	end

	button:TryChangePage("State", data.state)

	local curBossRushPlace = BossRushUtils.getCurBossRushPlace()
	local isBattleLevel = table.contains(Const.BossRushBattlePlace, curBossRushPlace)
	local canSelect = (not pg.me:isInTeam() or pg.me:isTeamLeader()) and pg.me.space:isBossRushEnv() and not isBattleLevel

	button:TryChangePage("Team", canSelect and 1 or 0)

	if not data.isMiniGame then
		local isNew = data.isNew or false

		pg.global.setRedDot(RedDotConst.RedDotPath.BOSS_RUSH_MAIN_BUFF, button, isNew, RedDotConst.RedDotStyle.NEW)
	end

	if data.state == 0 then
		local iconUrl = BossRushBuffData[data.buffId] and BossRushBuffData[data.buffId].buffIcon or ""

		iconUImage.url = iconUrl
	end
end

function BossRushUtils.getSpecialBuffList(isOpen)
	local cycleData = isOpen and BossRushCycleData[pg.me.curBossRushCycleId] or BossRushCycleData[pg.me.nextBossRushCycleId]
	local buffData = cycleData and cycleData.specialBuffRef or {}

	return BossRushUtils.parseBuffData(buffData)
end

function BossRushUtils.getNormalBuffList(curStar)
	local buffList = {}
	local lockBuffMap = BossRushUtils.getLockBuffMap()

	if IsNil(curStar) then
		curStar = BossRushUtils.getCurSeasonStar()
	end

	for baseBuffConfigId, levelNeedStarMap in pairs(lockBuffMap) do
		local maxLevel = 0
		local needStar = 0

		for level = 1, #levelNeedStarMap do
			local levelNeedStar = levelNeedStarMap[level]

			if maxLevel < level and needStar <= curStar then
				maxLevel = level
				needStar = levelNeedStar
			end
		end

		local isUnlock = maxLevel ~= 1

		if maxLevel > 1 and curStar < needStar then
			maxLevel = maxLevel - 1
		end

		table.insert(buffList, {
			state = 0,
			buffId = baseBuffConfigId + maxLevel - 1,
			isUnlock = isUnlock,
			needStar = needStar,
			level = maxLevel
		})
	end

	table.sort(buffList, function(a, b)
		return a.buffId > b.buffId
	end)

	return buffList
end

function BossRushUtils.parseBuffData(buffData)
	local buffList = {}

	for i = 1, #buffData do
		local buffId = buffData[i]

		if buffId then
			table.insert(buffList, {
				state = 0,
				buffId = buffId
			})
		end
	end

	return buffList
end

function BossRushUtils.getCurBossRushPlace()
	local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

	if cycleData then
		for key, value in pairs(Const.BossRushTeleportTarget) do
			if cycleData[value] == pg.space.dungeonId then
				return value
			end
		end
	end

	return Const.BossRushTeleportTarget.Prepare
end

function BossRushUtils.isInBossRushBattleLevel()
	local playerSpace = pg.me and pg.me.space

	return playerSpace and playerSpace:isBossRushEnv() and table.contains(Const.BossRushBattlePlace, BossRushUtils.getCurBossRushPlace())
end

function BossRushUtils.getBossCurHpState(curHp, maxHp)
	for index, value in ipairs(BossRushGradeData) do
		if curHp > maxHp * (1 - value.bossHpLossPercent) then
			local beforeRate = BossRushGradeData[index - 1] and BossRushGradeData[index - 1].bossHpLossPercent or 1

			return index, curHp - maxHp * (1 - value.bossHpLossPercent), maxHp * (value.bossHpLossPercent - beforeRate)
		end
	end

	return #BossRushGradeData, 0, 0
end

function BossRushUtils.checkIsBossLastHp(curHp, maxHp)
	if #BossRushGradeData == 1 then
		return true
	end

	local lastGradeData = BossRushGradeData[#BossRushGradeData - 1]

	return curHp < maxHp * (1 - lastGradeData.bossHpLossPercent)
end

function BossRushUtils.getBossTotalHpCount()
	return #BossRushGradeData
end

function BossRushUtils.getCurCycleTotalScore()
	local score, star = 0, 0

	for index, value in pairs(pg.me.curBossRushCycBossBestScores) do
		score = score + value
	end

	for index, value in pairs(pg.me.curBossRushCycBossBestGrades) do
		star = star + value
	end

	return score, star
end

function BossRushUtils.getLastCycleTotalScore()
	local score, star = 0, 0

	for index, value in pairs(pg.me.lastBossRushCycBossBestScores) do
		score = score + value
	end

	for index, value in pairs(pg.me.lastBossRushCycBossBestGrades) do
		star = star + value
	end

	return score, star
end

function BossRushUtils.isPlayerReady(entityId, levelId)
	if not pg.space.teamerInfos then
		return false
	end

	return pg.space.teamerInfos[entityId] and pg.space.teamerInfos[entityId].levelIsReady[levelId] == 1 or false
end

function BossRushUtils.getPlayerSelectPetIds(entityId, levelId)
	local petInfos = BossRushUtils.getPlayerSelectPets(entityId, levelId)
	local petIds = {}

	for _, petInfo in ipairs(petInfos) do
		table.insert(petIds, petInfo.entityId)
	end

	return petIds
end

function BossRushUtils.getPlayerSelectPets(entityId, levelId)
	if not pg.space.teamerInfos then
		return {}
	end

	if not pg.space.teamerInfos[entityId] then
		return {}
	end

	return pg.space.teamerInfos[entityId].levelBatPetList[levelId] or {}
end

function BossRushUtils.checkSelfPetAvailable(levelId)
	local petIds = BossRushUtils.getPlayerSelectPetIds(pg.me.id, levelId)
	local availablePetIds = {}

	for _, petId in ipairs(petIds) do
		local petInfo = petId and pg.me.pets[petId]

		if petInfo and not pg.me:isPetPutInHomeland(petInfo) then
			table.insert(availablePetIds, petId)
		end
	end

	if #petIds ~= #availablePetIds then
		pg.me:bossRushSelectPet(levelId, availablePetIds)
	end
end

function BossRushUtils.initSelectPetTitleInfo(rootUContainer, levelId)
	local function handle()
		local objectReference = rootUContainer.content:GetComponent("ObjectReference")
		local listElementUList = objectReference:GetRefValue("listElementUList")
		local listDMGTipsUList = objectReference:GetRefValue("listDMGTipsUList")
		local luckyPetUImage = objectReference:GetRefValue("luckyPetUImage")
		local petHeadUWidget = objectReference:GetRefValue("petHeadUWidget")
		local levelData = BossRushLevelData[levelId]
		local recommendEle = levelData.elementRecmmend or {}

		LuaUIUtils.renderPetElement(listElementUList, recommendEle)

		function listDMGTipsUList.luaRenderItem(button, index, data)
			button:TryChangePage("Recommend", data.isRecommend and 0 or 1)
		end

		local tags = BossRushUtils.getLevelTagInfos(levelId)

		listDMGTipsUList:SetList(tags)
		petHeadUWidget:SetActive(BossRushUtils.getLevelIdRoad(levelId) == Const.BossRushTeleportTarget.BossMid)

		local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

		if cycleData and cycleData.recommendPet then
			luckyPetUImage.url = LuaUIUtils.getPetIcon(PetData[cycleData.recommendPet].iconName, LuaUIUtils.PET_ICON, 0)
		end
	end

	if rootUContainer:CheckURLLoaded() then
		handle()
	else
		rootUContainer:LoadDefaultUrlManually(handle)
	end
end

function BossRushUtils.getLevelIdRoad(levelId)
	local cycleData = BossRushCycleData[pg.me.curBossRushCycleId]

	if not cycleData then
		return Const.BossRushTeleportTarget.Prepare
	end

	if cycleData.bossLeft == levelId then
		return Const.BossRushTeleportTarget.BossLeft
	elseif cycleData.bossRight == levelId then
		return Const.BossRushTeleportTarget.BossRight
	elseif cycleData.bossMid == levelId then
		return Const.BossRushTeleportTarget.BossMid
	else
		return Const.BossRushTeleportTarget.Prepare
	end
end

function BossRushUtils.getLevelTagInfos(levelId)
	local levelData = BossRushLevelData[levelId]

	if not levelData then
		return {}
	end

	local tags = {}
	local recommendTags = levelData.positiveTag or {}

	for _, tag in ipairs(recommendTags) do
		local text = BossRushUITagData[tag] and pg.getLocalizationText(BossRushUITagData[tag].ui_tag_name) or tag

		table.insert(tags, {
			isRecommend = true,
			label = text
		})
	end

	local unrecommendTags = levelData.negativeTag or {}

	for _, tag in ipairs(unrecommendTags) do
		local text = BossRushUITagData[tag] and pg.getLocalizationText(BossRushUITagData[tag].ui_tag_name) or tag

		table.insert(tags, {
			isRecommend = false,
			label = text
		})
	end

	return tags
end

function BossRushUtils.onLeaveBossRush()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_CHALLENGE) then
		pg.global.ui:close(UIConst.UI_ID_BOSS_RUSH_CHALLENGE)
	end

	pg.global.ui.tips:setBossTitleItemInvisibleReason("inBossRushPrepare", true)
end

function BossRushUtils.getCurCycleEndTime()
	if not pg.me.curBossRushCycleId or pg.me.curBossRushCycleId == 0 then
		return 0
	end

	if pg.me.curBossRushCycleEndTm then
		return pg.me.curBossRushCycleEndTm
	end

	return 0
end

function BossRushUtils.checkIsOpen()
	return pg.me.curBossRushCycleId and pg.me.curBossRushCycleId ~= 0
end

function BossRushUtils.checkHasAssistReward(newRecordData)
	local assistRewards = newRecordData and newRecordData.assistRewards or {}

	for id, value in pairs(assistRewards) do
		return true
	end

	return false
end

function BossRushUtils.showBossRushHelpTip(args)
	local playerArgs1 = {}
	local playerArgs2 = {}

	for _, v in pairs(args) do
		if not table.contains(playerArgs1, v[1]) then
			table.insert(playerArgs1, v[1])
		end

		if not table.contains(playerArgs2, v[2]) then
			table.insert(playerArgs2, v[2])
		end
	end

	local cData = ItemData[SysConfigData.BossRushAssistRewardItemId]
	local itemName = cData and cData.itemName or ""

	itemName = pg.getLocalizationText(itemName)

	pg.game.chat:addCommonSystemNotice(Const.HUD_NOTICE_ID.BOSS_RUSH_HELP_NOTICE, table.concat(playerArgs1, "<style=Nml_L>,</style>"), table.concat(playerArgs2, "<style=Nml_L>,</style>"), itemName)
end

function BossRushUtils.checkNeedShowCancelChallengeTip()
	local time = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.LastShowCancelChallengeTipTime, 0)
	local now = Time.secondCache
	local interval = 2592000

	return interval < now - time
end

function BossRushUtils.setLastShowCancelChallengeTipTime()
	local now = Time.secondCache

	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.LastShowCancelChallengeTipTime, now)
end

function BossRushUtils.getLevelIdByTargetId(targetId)
	local bossRushTarget = Const.BossRushTeleportIdToTarget[targetId]
	local cycleData = BossRushUtils.getCycleData()

	if bossRushTarget and cycleData then
		return cycleData[bossRushTarget]
	end
end

function BossRushUtils.getBossCfgByTargetId(targetId)
	local levelId = BossRushUtils.getLevelIdByTargetId(targetId)

	if not levelId then
		return nil
	end

	local levelData = BossRushLevelData[levelId]

	if not levelData or not levelData.bossId then
		return nil
	end

	return PuppetData[levelData.bossId]
end

function BossRushUtils.getBossNameByLevelId(levelId)
	local levelData = BossRushLevelData[levelId]

	if not levelData or not levelData.bossId then
		return nil
	end

	local bossCfg = PuppetData[levelData.bossId]

	if not bossCfg then
		return ""
	end

	return pg.getLocalizationText(bossCfg.BossShowName or "")
end

function BossRushUtils.canAddBotPlayer()
	local playerCount = pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1
	local bots = pg.space.playerBotUidList or {}
	local botCount = #bots
	local isTeamFull = playerCount + botCount == Const.TEAM_BASE.MAX_PLAYER_NUM

	return not isTeamFull and (not pg.me:isInTeam() or pg.me:isTeamLeader())
end

function BossRushUtils.isSeasonRewardReceived(star)
	local receivedRewards = pg.me.bossRushSeasonRewardRecved

	return receivedRewards and receivedRewards[star] or false
end

function BossRushUtils.hasUnreceivedSeasonReward()
	local seasonId = pg.me.curBossRushSeasonId or 0

	if seasonId <= 0 then
		return false
	end

	local function isSeasonRewardConfigActive(seasonId, seasonBegin, seasonEnd)
		return seasonBegin <= seasonId and seasonId <= seasonEnd
	end

	local curStar = BossRushUtils.getCurSeasonStar()

	for needStar, seasonBeginData in pairs(BossRushSeasonRewardData) do
		if needStar <= curStar and not BossRushUtils.isSeasonRewardReceived(needStar) then
			for seasonBegin, seasonEndData in pairs(seasonBeginData) do
				for seasonEnd, rewardData in pairs(seasonEndData) do
					if isSeasonRewardConfigActive(seasonId, seasonBegin, seasonEnd) and rewardData.awardId and rewardData.awardId > 0 then
						return true
					end
				end
			end
		end
	end

	return false
end

function BossRushUtils.hasUnseenSeasonBuffReward()
	local seasonId = pg.me.curBossRushSeasonId or 0

	if seasonId <= 0 then
		return false
	end

	local curStar = BossRushUtils.getCurSeasonStar()

	for needStar, seasonBeginData in pairs(BossRushSeasonRewardData) do
		if needStar <= curStar then
			for seasonBegin, seasonEndData in pairs(seasonBeginData) do
				for seasonEnd, rewardData in pairs(seasonEndData) do
					local seasonBuff = rewardData.seasonBuff

					if seasonBegin <= seasonId and seasonId <= seasonEnd and seasonBuff then
						local redDotKey = string.format(RedDotConst.RedDotPath.BOSS_RUSH_SEASON_REWARD_BUFF, seasonId, seasonBuff)

						if pg.me:getRedDotRecord(Const.CLIENT_KEY.BOSS_RUSH, redDotKey, true) then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

function BossRushUtils.getSeasonRewardRedDotStyle()
	local styleList = {}

	if BossRushUtils.hasUnreceivedSeasonReward() then
		styleList[#styleList + 1] = RedDotConst.RedDotStyle.REWARD
	end

	if BossRushUtils.hasUnseenSeasonBuffReward() then
		styleList[#styleList + 1] = RedDotConst.RedDotStyle.NEW
	end

	return pg.global.calculateRedDotPriority(styleList)
end

function BossRushUtils.getBossRushMainRedDotStyle()
	if BossRushUtils.hasUnreceivedSeasonReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function BossRushUtils.isBossRushMultiPlayerEnv()
	if not pg.space or not pg.space:isBossRushEnv() then
		return false
	end

	return pg.space.playerBotUidList and #pg.space.playerBotUidList > 0 or false
end

function BossRushUtils.openRank()
	pg.global.ui:open(UIConst.UI_ID_RANK_BASE, {
		rankId = 10001
	})
end

function BossRushUtils.isRankOpen()
	if not CommonSwitch.RANK_DISPLAY then
		return false
	end

	local cycleId = BossRushUtils.checkIsOpen() and pg.me.curBossRushCycleId or pg.me.nextBossRushCycleId or 0

	if cycleId == 0 then
		return false
	end

	local cycleConfig = BossRushCycleData[cycleId]

	if not cycleConfig or cycleConfig.isRank ~= 1 then
		return false
	end

	return cycleConfig.isRankView == 1 or pg.me.gmOpenRankWithoutView == true
end

function BossRushUtils.getMyRank(callback)
	local rankConfig = BossRushConst.PersonRank

	RankUtils.queryMemberRank(rankConfig.rankId, rankConfig.tab1, rankConfig.tab2, pg.me.uid, callback)
end

function BossRushUtils.clearPersonRankCD()
	local rankConfig = BossRushConst.PersonRank

	RankUtils.markRankCacheInvalid(rankConfig.rankId)
end

function BossRushUtils.getNearlyRankOpenTime()
	local curCycleId = pg.me.curBossRushCycleId or 0
	local nextRankCycleId

	for cycleId, cycleConfig in pairs(BossRushCycleData) do
		if curCycleId < cycleId and cycleConfig.isRank == 1 and (cycleConfig.isRankView == 1 or pg.me.gmOpenRankWithoutView == true) and (not nextRankCycleId or cycleId < nextRankCycleId) then
			nextRankCycleId = cycleId
		end
	end

	if not nextRankCycleId then
		return ""
	end

	local openTime = Utils.getConfigTimeOfArea(BossRushCycleData[nextRankCycleId], "begDayTime")

	return LuaUIUtils.timeStampToUtcString(openTime or 0)
end

return BossRushUtils
