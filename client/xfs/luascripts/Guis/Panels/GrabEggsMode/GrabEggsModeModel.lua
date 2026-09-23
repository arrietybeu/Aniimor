-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsMode\\GrabEggsModeModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsModeModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsModeModel = Class.LightClass("GrabEggsModeModel", UIModel)
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local LevelData = require("Data.level_data")
local ConstData = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local SysConfigData = require("Data.sys_config_data")
local EggRankBaseData = require("Data.egg_rank_base_data")
local EggRankDailyBoxData = require("Data.egg_rank_daily_box_data")
local RobEggTalentData = require("Data.rob_egg_talent_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local GrabEggsCalcinationRedDotUtils = require("Utils.GrabEggsCalcinationRedDotUtils")
local RobEggConst = require("Common.Const.RobEggConst")
local CommonSwitch = require("Common.CommonSwitch")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local RobEggBookGroupData = require("Data.egg_book_group_data")
local RobEggBookRewardData = require("Data.egg_book_reward_data")
local Utils = require("Common.Utils.Utils")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local DIFFICULT_TEXT = {
	"DUNGEON_DIFFICUITY_1",
	"DUNGEON_DIFFICUITY_2",
	"DUNGEON_DIFFICUITY_3",
	"DUNGEON_DIFFICUITY_4",
	"DUNGEON_DIFFICUITY_5"
}
local ROMAN_NUMERALS = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}
local BASE_COLLECTION_CASE_ID = 1001
local CHAOS_DIFFICULT_LV = 6

local function isDifficultLvVisible(sceneId, difficultLv)
	return sceneId ~= ConstData.ROB_EGG_SCENE_CLIP_ID or difficultLv ~= CHAOS_DIFFICULT_LV
end

local function getAreaTimeZoneText()
	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()]

	if areaOffset == nil then
		return ""
	end

	local sign = areaOffset >= 0 and "+" or "-"
	local totalMinutes = math.floor(math.abs(areaOffset) / 60)
	local hours = math.floor(totalMinutes / 60)
	local minutes = totalMinutes % 60

	if minutes == 0 then
		return string.format("UTC%s%d", sign, hours)
	end

	return string.format("UTC%s%d:%02d", sign, hours, minutes)
end

local function addAreaTimeZoneString(timeStr)
	local timeZoneText = getAreaTimeZoneText()

	if timeZoneText == "" then
		return timeStr
	end

	return timeStr .. " " .. timeZoneText
end

function GrabEggsModeModel:ctor()
	self.normalDifficultLvByScene = {}
	self.chaosModeSelected = false

	if self:checkIsFirstTimePlay() then
		self.mode = 1

		return
	end

	local teamInfo = pg.me:getCurTeamInfo()
	local dungeonSceneId = teamInfo and teamInfo.dungeonSceneId

	if dungeonSceneId == ConstData.ROB_EGG_SCENE_ID then
		self.mode = 2
	else
		self.mode = 1
	end

	if teamInfo and teamInfo.hardLv then
		if dungeonSceneId == ConstData.ROB_EGG_SCENE_CLIP_ID and teamInfo.hardLv == CHAOS_DIFFICULT_LV then
			self.chaosModeSelected = true
			self.selectedDifLv = CHAOS_DIFFICULT_LV
		elseif dungeonSceneId then
			self.normalDifficultLvByScene[dungeonSceneId] = teamInfo.hardLv
		end
	end
end

function GrabEggsModeModel:checkIsFirstTimePlay()
	if pg.me:grabEgg_isFirstTimePlay() then
		return true, 1, ConstData.DungeonDifficultLevel.NORMAL
	end

	return false
end

function GrabEggsModeModel:isTalentEntryUnlocked()
	return pg.me ~= nil and pg.me:grabEgg_isTalentEntryUnlocked()
end

function GrabEggsModeModel:getDefaultDifLv()
	local teamInfo = pg.me:getCurTeamInfo()
	local difLv = teamInfo.hardLv

	return difLv
end

function GrabEggsModeModel:setSelectionDifLv(selectedDifLv)
	self.selectedDifLv = selectedDifLv

	if selectedDifLv ~= CHAOS_DIFFICULT_LV then
		self.normalDifficultLvByScene = self.normalDifficultLvByScene or {}
		self.normalDifficultLvByScene[self:getDungeonSceneId()] = selectedDifLv
	end
end

function GrabEggsModeModel:getSelectedDifLv()
	return self.selectedDifLv or 4
end

function GrabEggsModeModel:isChaosModeSelected()
	return self.mode == 1 and self.chaosModeSelected == true
end

function GrabEggsModeModel:isChaosModeStateSelected()
	return self.chaosModeSelected == true
end

function GrabEggsModeModel:selectNormalMode()
	self.mode = 1
	self.chaosModeSelected = false
end

function GrabEggsModeModel:clearChaosModeSelection()
	self.chaosModeSelected = false

	if self.selectedDifLv == CHAOS_DIFFICULT_LV then
		self.selectedDifLv = self.normalDifficultLvByScene[ConstData.ROB_EGG_SCENE_CLIP_ID]
	end
end

function GrabEggsModeModel:selectChaosMode()
	self.mode = 1
	self.chaosModeSelected = true
	self.selectedDifLv = CHAOS_DIFFICULT_LV
end

function GrabEggsModeModel:getChaosDifficultLv()
	return CHAOS_DIFFICULT_LV
end

function GrabEggsModeModel:getAverageTeamLevel()
	local teamInfo = pg.me:getCurTeamInfo()

	if teamInfo == nil or teamInfo.membersInfo == nil then
		return pg.me.level
	end

	local num = 0
	local totalLv = 0

	for _, v in pairs(teamInfo.membersInfo) do
		totalLv = totalLv + v.level
		num = num + 1
	end

	return math.floor(totalLv / num)
end

function GrabEggsModeModel:checkMatchCondition()
	local teamInfo = pg.me:getCurTeamInfo()

	if teamInfo == nil then
		return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_ERROR")
	end

	local dungeonSceneId = teamInfo.dungeonSceneId
	local hardLv = teamInfo.hardLv
	local difData = DungeonDifficultLevelData[dungeonSceneId]

	if not difData then
		return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_ERROR")
	end

	local difLvData = difData[hardLv]

	if not difLvData then
		return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_ERROR")
	end

	local difLvResData = {
		selfLvLimit = difLvData.levelRestriction or 0,
		starLv = difLvData.serverLevel or 0,
		rankLimit = difLvData.rank,
		condition = difLvData.condition
	}
	local state, reason = self:checkMemberLvMatch(difLvResData)

	return state, reason
end

function GrabEggsModeModel:checkModeUnlock()
	local sceneId = ConstData.ROB_EGG_SCENE_ID
	local difData = DungeonDifficultLevelData[sceneId]

	for _, vcf in pairs(difData) do
		local curLimitStarLv = vcf.serverLevel or 0

		if curLimitStarLv > pg.me.starTitle then
			return false
		end
	end

	return true
end

function GrabEggsModeModel:checkMemberLvMatch(difData)
	local curLimitLv = difData.selfLvLimit
	local curLimitStarLv = difData.starLv
	local curLimitBigRank = 1
	local curLimitSmallRank = 1

	if difData.rankLimit then
		curLimitBigRank = difData.rankLimit[1]
		curLimitSmallRank = difData.rankLimit[2]
	end

	local player = pg.me
	local teamInfo = player:getCurTeamInfo()
	local dungeonConfig = LevelData[self:getDungeonSceneId()]

	if teamInfo and teamInfo.membersInfo and dungeonConfig and player:getTeamMemberCount(teamInfo) > dungeonConfig.playerNumMax then
		return false, pg.getGameString("NUMBER_NOT_READY")
	end

	if difData.condition and player.triggerMap then
		for _, conditionId in ipairs(difData.condition) do
			if not player.triggerMap:isCompleteOrMeetCondition(conditionId) then
				return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_TIME")
			end
		end
	end

	if teamInfo == nil or teamInfo.membersInfo == nil then
		if curLimitLv > player.level then
			return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_LEVEL")
		end

		if curLimitStarLv > player.starTitle then
			local titleName = LuaUIUtils.getStarTitleName(curLimitStarLv, true)

			return false, pg.getFormatText(pg.getGameString("GRAB_EGG_MODE_CONDITION_TITLE"), titleName)
		end

		local preparePetId = player:getTeamPetIds()

		if #preparePetId == 0 then
			return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_PET")
		end

		if curLimitBigRank > (player.eggLv or 1) then
			local titleName = self:getRankDisplayInfoByLv(curLimitBigRank, curLimitSmallRank).name

			return false, pg.getFormatText(pg.getGameString("GRAB_EGG_MODE_CONDITION_RANK"), titleName)
		elseif (player.eggLv or 1) == curLimitBigRank and curLimitSmallRank > (player.secEggLv or 1) then
			local titleName = self:getRankDisplayInfoByLv(curLimitBigRank, curLimitSmallRank).name

			return false, pg.getFormatText(pg.getGameString("GRAB_EGG_MODE_CONDITION_RANK"), titleName)
		end

		return true
	end

	for _, v in pairs(teamInfo.membersInfo) do
		if curLimitLv > v.level then
			return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_LEVEL")
		end

		if curLimitStarLv > v.starTitle then
			local titleName = LuaUIUtils.getStarTitleName(curLimitStarLv, true)

			return false, pg.getFormatText(pg.getGameString("GRAB_EGG_MODE_CONDITION_TITLE"), titleName)
		end

		if #v.petInfoList == 0 then
			return false, pg.getGameString("GRAB_EGG_MODE_CONDITION_PET")
		end
	end

	return true
end

function GrabEggsModeModel:isTeamMemberCountOverDungeonMax()
	local player = pg.me

	if not player then
		return false
	end

	local teamInfo = player:getCurTeamInfo()
	local dungeonConfig = LevelData[self:getDungeonSceneId()]

	return teamInfo and teamInfo.membersInfo and dungeonConfig and player:getTeamMemberCount(teamInfo) > dungeonConfig.playerNumMax
end

function GrabEggsModeModel:checkRobEggCanEnter(sceneId, hardLv)
	local result = {
		lackTime = false,
		lackRank = false,
		lackConditions = {},
		hardLv = hardLv
	}
	local cData = DungeonDifficultLevelData[sceneId]

	if not cData then
		return false, result
	end

	local cfg = cData[hardLv]

	if not cfg then
		return false, result
	end

	if RobEggConst.GM_SKIP_ENTER_CHECK then
		return true, result, 0
	end

	local player = pg.me

	if cfg.condition and player.triggerMap then
		for _, conditionId in ipairs(cfg.condition) do
			if not player.triggerMap:isCompleteOrMeetCondition(conditionId) then
				table.insert(result.lackConditions, conditionId)
			end
		end
	end

	if cfg.rank then
		local bigLimit, smallLimit = cfg.rank[1], cfg.rank[2]
		local playerBig = player.eggLv or 1
		local playerSmall = player.secEggLv or 1

		if playerBig < bigLimit or playerBig == bigLimit and playerSmall < smallLimit then
			result.lackRank = true

			local info = self:getRankDisplayInfoByLv(bigLimit, smallLimit)

			result.requiredRankName = info and info.name or ""
		end
	end

	if CommonSwitch.EnableRobEggTimeLimit then
		local timeOk, timeRange = self:checkRobEggTime(sceneId, hardLv)

		if not timeOk then
			result.lackTime = true
			result.requiredTimeRange = timeRange
		end
	end

	local canEnter = #result.lackConditions == 0 and not result.lackRank and not result.lackTime
	local isPvp = sceneId == ConstData.ROB_EGG_SCENE_ID
	local isChaos = sceneId == ConstData.ROB_EGG_SCENE_CLIP_ID and hardLv == ConstData.DungeonDifficultLevel.CHAOS
	local hasCondition = #result.lackConditions > 0
	local hasRank = result.lackRank
	local hasTime = result.lackTime
	local TimeLimit = 0

	if not canEnter then
		if isPvp or isChaos then
			TimeLimit = 1
		elseif hasCondition then
			TimeLimit = 1
		end
	end

	return canEnter, result, TimeLimit
end

function GrabEggsModeModel:getModeMinHardLv(sceneId)
	local cData = DungeonDifficultLevelData[sceneId]

	if not cData then
		return nil
	end

	local minLv

	for hardLv, _ in pairs(cData) do
		if not minLv or hardLv < minLv then
			minLv = hardLv
		end
	end

	return minLv
end

function GrabEggsModeModel:getModeLockResult(sceneId, hardLv)
	return self:checkRobEggCanEnter(sceneId, hardLv)
end

function GrabEggsModeModel:getLockTipKey(result, sceneId)
	local isPvp = sceneId == ConstData.ROB_EGG_SCENE_ID
	local isChaos = sceneId == ConstData.ROB_EGG_SCENE_CLIP_ID and result.hardLv == ConstData.DungeonDifficultLevel.CHAOS
	local hasCondition = #result.lackConditions > 0
	local hasRank = result.lackRank
	local hasTime = result.lackTime

	if hasCondition and hasRank and (isPvp or isChaos) then
		return "GRAB_EGG_LOCK_PVP_DAY_AND_RANK", {
			LuaUIUtils.getConditionUnlockDesc(result.lackConditions[1]),
			result.requiredRankName
		}
	end

	if isPvp then
		if hasCondition then
			return "GRAB_EGG_LOCK_PVP_DAY", {
				LuaUIUtils.getConditionUnlockDesc(result.lackConditions[1])
			}
		elseif hasRank then
			return "GRAB_EGG_LOCK_RANK", {
				result.requiredRankName or ""
			}
		elseif hasTime then
			return nil, nil
		end
	elseif hasCondition then
		return "GRAB_EGG_LOCK_PVE_DAY", {
			LuaUIUtils.getConditionUnlockDesc(result.lackConditions[1])
		}
	elseif hasRank then
		return "GRAB_EGG_LOCK_RANK", {
			result.requiredRankName or ""
		}
	end

	return nil, nil
end

function GrabEggsModeModel:getLockTipFinalText(result, sceneId)
	if result.lackTime and #result.lackConditions == 0 and not result.lackRank then
		return result.requiredTimeRange or ""
	end

	local key, args = self:getLockTipKey(result, sceneId)

	if not key then
		return ""
	end

	local raw = pg.getGameString(key)

	if args then
		local s = string.format(raw, unpack(args))

		return s
	end

	return raw
end

function GrabEggsModeModel:getEnterBubbleText(result, sceneId)
	return self:getLockTipFinalText(result, sceneId)
end

function GrabEggsModeModel:checkGrabEggLv(data)
	local cData = DungeonDifficultLevelData[self:getDungeonSceneId()]

	if not cData then
		return false
	end

	local cfg = cData[data.difficultLv]

	if not cfg then
		return false
	end

	return pg.me ~= nil and pg.me:checkGrabEggLevelCondition(cfg.rank and cfg.rank[1] or 1, cfg.rank and cfg.rank[2] or 1)
end

function GrabEggsModeModel:checkRobEggTimeRange(sceneId, hardLv)
	local formatTime
	local day_of_week = TimeUtils.getWeekDayOffArea(Time.secondCache)
	local cData = DungeonDifficultLevelData[sceneId]

	if not cData then
		return formatTime, nil
	end

	local cfg = cData[hardLv]

	if not cfg or not cfg.timeRanges then
		return formatTime, nil
	end

	local dayCfg = cfg.timeRanges[day_of_week]

	if not dayCfg or #dayCfg == 0 then
		return formatTime, nil
	end

	local timeData = dayCfg[1]

	if #timeData < 2 then
		return formatTime, nil
	end

	local startTime = TimeUtils.timeStringToHM(timeData[1])
	local endTime = addAreaTimeZoneString(TimeUtils.timeStringToHM(timeData[2]))

	return startTime, endTime
end

function GrabEggsModeModel:checkRobEggTime(sceneId, hardLv)
	local day_of_week = TimeUtils.getWeekDayOffArea(Time.secondCache)
	local cData = DungeonDifficultLevelData[sceneId]

	if not cData then
		return false, ""
	end

	local cfg = cData[hardLv]

	if not cfg then
		return false, ""
	end

	if not ToBool(cfg.timeRanges) then
		return true, ""
	end

	local dayCfg = cfg.timeRanges[day_of_week]

	if not ToBool(dayCfg) then
		return true, ""
	end

	if #dayCfg == 0 then
		return true, ""
	end

	for _, timeCfg in ipairs(dayCfg) do
		if #timeCfg >= 2 then
			local timeBegin = TimeUtils.stringToAreaTimestamp(timeCfg[1])
			local timeEnd = TimeUtils.stringToAreaTimestamp(timeCfg[2])

			if TimeUtils.isInRangeTimestamp(timeBegin, timeEnd) then
				return true, ""
			end
		end
	end

	return false, self:getRobEggUnlockTimeFormat(sceneId, hardLv)
end

function GrabEggsModeModel:getRobEggUnlockTimeFormat(sceneId, hardLv)
	local formatTime = "Error"
	local day_of_week = TimeUtils.getWeekDayOffArea(Time.secondCache)
	local cData = DungeonDifficultLevelData[sceneId]

	if not cData then
		return formatTime
	end

	local cfg = cData[hardLv]

	if not cfg or not cfg.timeRanges then
		return formatTime
	end

	local dayCfg = cfg.timeRanges[day_of_week]

	if not dayCfg or #dayCfg == 0 then
		return formatTime
	end

	local timeData = dayCfg[1]

	if #timeData < 2 then
		return formatTime
	end

	local startTime = TimeUtils.timeStringToHM(timeData[1])
	local endTime = addAreaTimeZoneString(TimeUtils.timeStringToHM(timeData[2]))

	formatTime = pg.getFormatText(pg.getGameString("GRAB_EGG_OPEN_LIMIT_TIME_TIP"), startTime, endTime)

	return formatTime
end

function GrabEggsModeModel:setSelectedMode(mode)
	self.mode = mode
end

function GrabEggsModeModel:getSelectedMode()
	return self.mode
end

function GrabEggsModeModel:getDungeonSceneId()
	local sceneId = ConstData.ROB_EGG_SCENE_CLIP_ID

	if self.mode == 1 then
		sceneId = ConstData.ROB_EGG_SCENE_CLIP_ID
	elseif self.mode == 2 then
		sceneId = ConstData.ROB_EGG_SCENE_ID
	end

	return sceneId
end

function GrabEggsModeModel:getDungeonModeInfo()
	local sceneId = self:getDungeonSceneId()
	local res = {
		sceneId = sceneId,
		difficultLvs = {}
	}
	local difficultLvs = res.difficultLvs
	local difData = DungeonDifficultLevelData[sceneId]

	for difLv, vcf in pairs(difData) do
		local difficultyTextKey = DIFFICULT_TEXT[difLv]
		local difficultyLabel = difficultyTextKey and pg.getGameString(difficultyTextKey) or difLv == CHAOS_DIFFICULT_LV and pg.getGameString("GRAB_EGG_ChaosDifficulty_3") or tostring(difLv)
		local difOption = {
			rewards = {},
			label = difficultyLabel,
			rankLimit = {}
		}

		difOption.sceneName = pg.getLocalizationText(vcf.name)
		difOption.describe = pg.getLocalizationText(vcf.describe)
		difOption.teamNumDesc = pg.getLocalizationText(vcf.teamsNumber)

		if sceneId == ConstData.ROB_EGG_SCENE_ID then
			difOption.openTime = pg.getGameString("GRAB_EGG_OPEN_LIMIT_TIME_TIP_1")
		else
			difOption.openTime = pg.getGameString("GRAB_EGG_OPEN_LIMIT_TIME_TIP_2")
		end

		difOption.difficultLv = difLv
		difOption.gameUIAsset = vcf.gameUIAsset
		difOption.gameUINpcAsset = vcf.gameUINpcAsset
		difOption.dangerLv = vcf.dangerLevel or 0
		difOption.selfLvLimit = vcf.levelRestriction or 0
		difOption.enemyLevel = pg.getLocalizationText(vcf.EquipmentLevel)
		difOption.starLv = vcf.serverLevel or 0

		if vcf.rank then
			for i, lv in pairs(vcf.rank) do
				difOption.rankLimit[i] = lv
			end
		else
			difOption.rankLimit = nil
		end

		difOption.condition = vcf.condition

		for i, itemId in ipairs(vcf.rewardList) do
			local item = LuaUIUtils.getItemInfoById(itemId)

			item.id = itemId
			difOption.rewards[i] = item
		end

		difOption.openTimeRange, difOption.endTimeRange = self:checkRobEggTimeRange(sceneId, difLv)

		if isDifficultLvVisible(sceneId, difLv) then
			difficultLvs[#difficultLvs + 1] = difOption
		elseif difLv == CHAOS_DIFFICULT_LV then
			res.chaosDifficult = difOption
		end
	end

	table.sort(difficultLvs, function(a, b)
		return a.difficultLv < b.difficultLv
	end)

	local defaultDifLv = self.normalDifficultLvByScene[sceneId] or self:getDefaultDifLv()
	local defaultIndex = 1

	for i, v in ipairs(difficultLvs) do
		if v.difficultLv == defaultDifLv then
			defaultIndex = i

			break
		end
	end

	if difficultLvs[defaultIndex] and not self:isChaosModeSelected() then
		self:setSelectionDifLv(difficultLvs[defaultIndex].difficultLv)
	end

	return res, defaultIndex
end

function GrabEggsModeModel:getDifficultName(difLv)
	local textKey = DIFFICULT_TEXT[difLv]

	return textKey and pg.getGameString(textKey) or difLv == CHAOS_DIFFICULT_LV and pg.getGameString("GRAB_EGG_ChaosDifficulty_3") or tostring(difLv)
end

function GrabEggsModeModel:getCurrentModeInfo()
	local dungeonSceneId = self:getDungeonSceneId()
	local difLv = self:getSelectedDifLv()
	local res = {
		sceneId = dungeonSceneId,
		difficultLv = difLv
	}

	res.difName = self:getDifficultName(difLv)
	res.modeType = dungeonSceneId == ConstData.ROB_EGG_SCENE_CLIP_ID and 0 or 1

	return res
end

function GrabEggsModeModel:getTalentDataList()
	local skillIds = SysConfigData.GrabEggSkill
	local skillDataList = {}

	for i, skillId in ipairs(skillIds) do
		skillDataList[i] = pg.global.ui.playerEnhance.model:getSkillDataWithLv(skillId)
	end

	return skillDataList
end

function GrabEggsModeModel:parseTalentData()
	return
end

function GrabEggsModeModel:redDot_GetFuncMenuState()
	if GrabEggsRankUtils.hasClaimableReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:hasReadyRewardBox() then
		return RedDotConst.RedDotStyle.REWARD
	end

	local collectionState = self:redDot_GetCollectionState()

	if collectionState == RedDotConst.RedDotStyle.REWARD then
		return collectionState
	end

	if collectionState == RedDotConst.RedDotStyle.POINT then
		return collectionState
	end

	return RedDotConst.RedDotStyle.NONE
end

function GrabEggsModeModel:redDot_GetCalcinationState()
	if GrabEggsCalcinationRedDotUtils.hasNewItem() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function GrabEggsModeModel:redDot_GetCollectionState()
	local player = pg.me

	if not player then
		return RedDotConst.RedDotStyle.NONE
	end

	local showCase = player.showCases and player.showCases[BASE_COLLECTION_CASE_ID]

	if showCase and self:hasCollectionReward(showCase) then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:hasCollectionSlotPlaceTip(showCase) then
		return RedDotConst.RedDotStyle.POINT
	end

	return RedDotConst.RedDotStyle.NONE
end

function GrabEggsModeModel:hasCollectionReward(showCase)
	local groupCfg = RobEggBookGroupData[BASE_COLLECTION_CASE_ID]
	local rewardCfg = groupCfg and RobEggBookRewardData[groupCfg.reward]

	if not rewardCfg then
		return false
	end

	local currentPoint = showCase.allPoint or 0
	local rewardRecord = showCase.rewardRecord or {}

	for nodeId, nodeCfg in pairs(rewardCfg) do
		if currentPoint >= (nodeCfg.nodePoint or 0) and (rewardRecord[nodeId] or 0) <= 0 then
			return true
		end
	end

	return false
end

function GrabEggsModeModel:hasCollectionSlotPlaceTip(showCase)
	local warehouse = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE)

	if not warehouse then
		return false
	end

	local bagItemIds = {}

	for _, item in warehouse:items() do
		if item and item.id then
			bagItemIds[item.id] = true
		end
	end

	for slotId, slotCfg in pairs(RobEggBookCollectionData) do
		local placedItem = showCase and showCase[slotId]
		local hasPlacedItem = placedItem and placedItem.id and placedItem.id > 0

		if slotCfg.collectGroup == BASE_COLLECTION_CASE_ID and not hasPlacedItem then
			for _, itemId in ipairs(slotCfg.itemId or EMPTY_TABLE) do
				if bagItemIds[itemId] then
					return true
				end
			end
		end
	end

	return false
end

function GrabEggsModeModel:redDot_GetMultiModeState()
	if not RobEggConst.PVP_MODE_ENTRY_ENABLED or self:checkIsFirstTimePlay() or not self:checkModeUnlock() then
		return false
	end

	local state = pg.me:getRedDotRecord(Const.CLIENT_KEY.GRAB_EGG_MODE, RedDotConst.RedDotPath.GRAB_EGG_MODE_MULTI, true)

	return state
end

function GrabEggsModeModel:redDot_SetMultiModeState()
	if self:checkIsFirstTimePlay() then
		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.GRAB_EGG_MODE, RedDotConst.RedDotPath.GRAB_EGG_MODE_MULTI, false)
end

function GrabEggsModeModel:redDot_GetSelectorState()
	if self:checkIsFirstTimePlay() then
		return false
	end

	local state = false
	local difData = DungeonDifficultLevelData[ConstData.ROB_EGG_SCENE_CLIP_ID]

	for hardLv, _ in pairs(difData) do
		if isDifficultLvVisible(ConstData.ROB_EGG_SCENE_CLIP_ID, hardLv) then
			state = self:redDot_GetSelectorOptionState(hardLv) or state

			if state then
				break
			end
		end
	end

	return state
end

function GrabEggsModeModel:redDot_GetSelectorOptionState(hardLv)
	if self:checkIsFirstTimePlay() then
		return false
	end

	local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR_OPTION, hardLv)
	local state = pg.me:getRedDotRecord(Const.CLIENT_KEY.GRAB_EGG_MODE, path, true)

	return state
end

function GrabEggsModeModel:redDot_SetSelectorOptionState(hardLv)
	if self:checkIsFirstTimePlay() then
		return
	end

	local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_SELECTOR_OPTION, hardLv)

	pg.me:setRedDotRecord(Const.CLIENT_KEY.GRAB_EGG_MODE, path, false)
end

function GrabEggsModeModel:redDot_GetTalentBtnState()
	if not self:isTalentEntryUnlocked() then
		return false
	end

	for id, cfg in pairs(RobEggTalentData) do
		if cfg.isBroadcast ~= 1 and not pg.me:getTalentIsUnlockByTalentId(id) then
			local prereqsMet = true

			if cfg.prerequisite then
				for _, preId in ipairs(cfg.prerequisite) do
					if not pg.me:getTalentIsUnlockByTalentId(preId) then
						prereqsMet = false

						break
					end
				end
			end

			if prereqsMet and (cfg.baseCost or 0) <= pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG) then
				local itemsOk = true

				for _, pair in ipairs(cfg.itemCost or EMPTY_TABLE) do
					if pg.me:getItemCountById(pair[1]) < pair[2] then
						itemsOk = false

						break
					end
				end

				if itemsOk then
					return true
				end
			end
		end
	end

	return false
end

function GrabEggsModeModel:getCurrentRank()
	local bigRank = pg.me.eggLv or 1
	local smallRank = pg.me.secEggLv or 1

	return bigRank, smallRank
end

function GrabEggsModeModel:getSeasonDisplayInfo()
	return GrabEggsRankUtils.getSeasonDisplayInfo()
end

function GrabEggsModeModel:hasClaimableRankReward()
	return GrabEggsRankUtils.hasClaimableReward()
end

function GrabEggsModeModel:getRankDisplayInfoByLv(bigRank, smallRank)
	local cfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]

	if not cfg then
		return
	end

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		name = pg.getLocalizationText(cfg.name),
		icon = cfg.icon,
		levelText = string.format("%d-%d", bigRank, smallRank)
	}
end

function GrabEggsModeModel:getRankDisplayInfo()
	local bigRank, smallRank = self:getCurrentRank()
	local cfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]

	if not cfg then
		return
	end

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		name = pg.getLocalizationText(cfg.name),
		icon = cfg.icon,
		levelText = string.format("%d-%d", bigRank, smallRank),
		upNumber = cfg.upNumber or 0,
		eggStar = pg.me.eggStar or 0
	}
end

function GrabEggsModeModel:forEachRank(callback, bigUpTo, secUpTo)
	local maxBigRank = 0

	for bigRank, _ in pairs(EggRankBaseData) do
		if maxBigRank < bigRank then
			maxBigRank = bigRank
		end
	end

	for bigRank = 1, maxBigRank do
		local bigCfg = EggRankBaseData[bigRank]

		if bigCfg then
			for smallRank, cfg in ipairs(bigCfg) do
				if bigUpTo and (bigUpTo < bigRank or bigRank == bigUpTo and secUpTo < smallRank) then
					return
				end

				if callback(cfg, bigRank, smallRank) then
					return
				end
			end
		end
	end
end

function GrabEggsModeModel:getMaxBoxSlotCount()
	local total = 0

	self:forEachRank(function(cfg)
		total = total + (cfg.boxNumber or 0)
	end)

	return total
end

function GrabEggsModeModel:getUnlockedBoxSlotCount()
	local bigRank, smallRank = self:getCurrentRank()
	local total = 0

	self:forEachRank(function(cfg)
		total = total + (cfg.boxNumber or 0)
	end, bigRank, smallRank)

	return total
end

function GrabEggsModeModel:getDailyBoxLimit()
	local bigRank, smallRank = self:getCurrentRank()
	local cfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]

	return cfg and cfg.boxUpLimit or 0
end

function GrabEggsModeModel:getDailyBoxAcquired()
	return pg.me.refreshCountDaily or 0
end

function GrabEggsModeModel:getBoxDisplayData(box, rewardId)
	if not box or box.id == 0 then
		return nil
	end

	local boxCfg = EggRankDailyBoxData[box.id]

	if not boxCfg then
		return nil
	end

	local remainSec = (box.timestamp or 0) - Time.secondCache
	local totalSec = (box.timestamp or 0) - (box.achievedTime or 0)

	return {
		id = box.id,
		quality = tonumber(boxCfg.quality),
		reward = boxCfg.reward,
		remainSec = math.max(0, remainSec),
		totalSec = math.max(1, totalSec),
		isReady = remainSec <= 0,
		rewardId = rewardId,
		icon = boxCfg.icon
	}
end

function GrabEggsModeModel:getDailyBoxStatus()
	local limit = self:getDailyBoxLimit()
	local acquired = self:getDailyBoxAcquired()

	return {
		acquired = acquired,
		limit = limit,
		remaining = math.max(0, limit - acquired),
		isFull = limit <= acquired
	}
end

function GrabEggsModeModel:buildBoxSlotList()
	local maxSlot = self:getMaxBoxSlotCount()
	local unlockedSlot = self:getUnlockedBoxSlotCount()
	local boxList = pg.me.rewardBoxList
	local dailyStatus = self:getDailyBoxStatus()
	local slots = {}

	for i = 1, maxSlot do
		if unlockedSlot < i then
			slots[i] = {
				isLocked = true
			}
		else
			local box = boxList and boxList[i]

			if box and box.id ~= 0 then
				slots[i] = self:getBoxDisplayData(box, i)
			elseif dailyStatus.isFull then
				slots[i] = {
					isFull = true
				}
			else
				slots[i] = {
					isEmpty = true
				}
			end
		end
	end

	return slots
end

function GrabEggsModeModel:hasReadyRewardBox()
	local boxList = pg.me.rewardBoxList

	if not boxList then
		return false
	end

	local now = Time.secondCache
	local unlockedCount = self:getUnlockedBoxSlotCount()

	for i = 1, unlockedCount do
		local box = boxList[i]

		if box and box.id ~= 0 and now >= (box.timestamp or 0) then
			return true
		end
	end

	return false
end

function GrabEggsModeModel:getSmallRankCount(bigRank)
	local big = EggRankBaseData[bigRank]

	if not big then
		return 0
	end

	local count = 0

	while big[count + 1] do
		count = count + 1
	end

	return count
end

function GrabEggsModeModel:getDisplayRoman(bigRank, smallRank)
	if not bigRank or not smallRank then
		return ""
	end

	local count = self:getSmallRankCount(bigRank)

	if count == 0 or count < smallRank then
		return ""
	end

	return ROMAN_NUMERALS[count - smallRank + 1] or ""
end

return GrabEggsModeModel
