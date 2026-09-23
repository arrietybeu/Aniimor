-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerLvReward\\PlayerLvRewardModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerLvRewardModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PlayerLvRewardModel = Class.LightClass("PlayerLvRewardModel", UIModel)
local LevelData = require("Data.player_level_data")
local TitleData = require("Data.player_title_data")
local DropData = require("Data.drop_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")

PlayerLvRewardModel.LEVEL_STATE = {
	HAS_REWARD = 2,
	LEVEL_LESS = 1,
	LEVEL_MATCH = 0
}
PlayerLvRewardModel.REWARD_STATE = {
	HAS_REWARD = 1,
	NOT_REWARD = 0
}
PlayerLvRewardModel.ASSESS_STATE = {
	CAN_ASSESS = 1,
	NONE_ASSESS = 0,
	FINISHED = 3,
	CANT_ASSESS = 2
}

function PlayerLvRewardModel:ctor()
	self.MAX_LEVEL = #LevelData
	self.LEVEL_STAR = {}

	local max = #TitleData - 1

	for i = 0, max do
		local v = TitleData[i]

		if v.needLevel then
			self.LEVEL_STAR[v.needLevel] = i + 1
		end
	end

	self.FULL_LEVEL_STAR = {}

	local star = 0

	for i = 1, self.MAX_LEVEL do
		if self.LEVEL_STAR[i] then
			star = self.LEVEL_STAR[i]
		end

		self.FULL_LEVEL_STAR[i] = star
	end
end

function PlayerLvRewardModel:getPlayerLvDataList()
	local dataList = {}

	for i = 1, self.MAX_LEVEL do
		local star = self.LEVEL_STAR[i] or 0
		local res = {
			lv = i,
			maxStar = self.FULL_LEVEL_STAR[i],
			assessStar = star,
			icon = LuaUIUtils.getStarIcon(star),
			maxPetLv = pg.me:getMaxControlLevel() or 15
		}

		self:parseLvReward(res)
		self:parseStarReward(res)
		self:parseAllState(res)

		dataList[i] = res
	end

	return dataList
end

function PlayerLvRewardModel:parseAllState(data)
	self:parseRewardState(data)
	self:parseStarState(data)
	self:parseLevelState(data)
end

function PlayerLvRewardModel:parseLevelState(data)
	data.lvState = self.LEVEL_STATE.LEVEL_LESS

	if data.lv <= pg.me.level then
		data.lvState = self.LEVEL_STATE.LEVEL_MATCH
	end

	if data.rewardState == self.REWARD_STATE.HAS_REWARD and (data.starState == self.ASSESS_STATE.FINISHED or data.starState == self.ASSESS_STATE.NONE_ASSESS) then
		data.lvState = self.LEVEL_STATE.HAS_REWARD
	end

	data.isShowRedDot = self:redDot_GetLvReward(data.lv)
end

function PlayerLvRewardModel:parseRewardState(data)
	data.rewardState = self.REWARD_STATE.NOT_REWARD

	local rewardMap = pg.me.autoLevelRewardMap or {}

	if rewardMap[data.lv] or data.lv == 1 then
		data.rewardState = self.REWARD_STATE.HAS_REWARD
	end
end

function PlayerLvRewardModel:parseStarState(data)
	data.starName = LuaUIUtils.getStarTitleNameForIcon(data.assessStar)

	if data.assessStar > 0 then
		if pg.me.starTitle >= data.maxStar then
			data.starState = self.ASSESS_STATE.FINISHED
		else
			local condition1 = Utils.checkMatchStarCanUp(data.assessStar)

			data.starState = condition1 and self.ASSESS_STATE.CAN_ASSESS or self.ASSESS_STATE.CANT_ASSESS
		end
	else
		data.starState = self.ASSESS_STATE.NONE_ASSESS
	end

	if not Utils.checkUPStarTimeMatch(data.assessStar) then
		data.unlockTimeFormat = Utils.getUPStarFormatTime(data.assessStar)
	end
end

function PlayerLvRewardModel:parseLvReward(data)
	if data.lvReward then
		return
	end

	data.lvReward = {}

	local cData = LevelData[data.lv]
	local dropData = DropData[cData.rewardManual]

	if dropData and dropData.displayReward then
		for i, v in ipairs(dropData.displayReward) do
			local item = LuaUIUtils.getItemInfoById(v[1])

			item.num = v[2]
			item.tIndex = 0
			data.lvReward[i] = item
		end
	end

	local numCnt = #data.lvReward

	if numCnt < 4 then
		for i = numCnt + 1, 4 do
			data.lvReward[i] = {
				tIndex = 1
			}
		end
	end
end

function PlayerLvRewardModel:parseStarReward(data)
	if data.assessStar == 0 then
		return
	end

	local cData = TitleData[data.assessStar]

	if cData == nil then
		return
	end

	if data.propReward == nil then
		local propReward = {}
		local dsProps = cData.skillPointDisplayByTitleInList

		for i, v in ipairs(dsProps) do
			local itemId = v[1]
			local res = {
				id = itemId,
				num = v[2]
			}

			res.icon = LuaUIUtils.getIconByItemId(itemId)
			res.name = LuaUIUtils.getNameByItemId(itemId)
			propReward[i] = res
		end

		data.propReward = propReward
	end

	if data.skReward == nil then
		local skillReward = {}
		local dsSkills = cData.skillDisplayByTitleInList or {}

		for i, v in ipairs(dsSkills) do
			local res = {
				hideSkillButton = true,
				id = v[1],
				lv = v[2]
			}

			pg.global.ui.playerEnhance.model:parseSkillInfo(res, v[2])

			res.tIndex = res.isActiveSkill and 0 or 1
			skillReward[i] = res
		end

		data.skReward = skillReward
	end
end

function PlayerLvRewardModel:redDot_GetLvReward(lv, needTitle)
	if lv <= 1 then
		return false
	end

	local curLv = pg.me.level
	local rewardMap = pg.me.autoLevelRewardMap or {}
	local hasReward = rewardMap[lv] or false

	if not needTitle then
		return not hasReward and lv <= curLv
	else
		return not hasReward and lv <= curLv and self.LEVEL_STAR and self.LEVEL_STAR[lv]
	end
end

function PlayerLvRewardModel:redDot_CheckHasLvReward()
	local hasReward = false

	for i = 1, self.MAX_LEVEL do
		hasReward = self:redDot_GetLvReward(i)

		if hasReward then
			break
		end
	end

	return hasReward
end

function PlayerLvRewardModel:redDot_CheckHasLvTitleReward()
	local hasReward = false

	for i = 1, self.MAX_LEVEL do
		hasReward = self:redDot_GetLvReward(i, true)

		if hasReward then
			break
		end
	end

	return hasReward
end

function PlayerLvRewardModel:redDot_CheckCanUPForCurTitle(star)
	local info = Utils.getTitleAssessInfo(star)

	if not info.can then
		return false
	end

	local cData = TitleData[star - 1]
	local quest = cData.quest
	local hasReceive = false

	if quest then
		hasReceive = QuestUtils.isQuestInState(quest, QuestConst.QUEST_STATE.RECEIVED)
	else
		hasReceive = false
	end

	local hideRedDot = cData.hideRedPoint == 1

	return hasReceive and not hideRedDot
end

return PlayerLvRewardModel
