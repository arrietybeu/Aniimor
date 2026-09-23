-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Fissure\\FissureModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RiftLevelData = require("Data.rift_level_data")
local RiftBuffData = require("Data.rift_buff_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local FissureModel = Class.LightClass("FissureModel", UIModel)

FissureModel.STAGE_TYPE = {
	DEFEAT = 1,
	GUARD = 3,
	SURVIVE = 2
}

function FissureModel:getLevelConfig(levelId)
	return levelId and RiftLevelData[levelId] or nil
end

function FissureModel:getDifficultyGroup(levelId)
	local cfg = self:getLevelConfig(levelId)

	if not cfg then
		return {}, 1
	end

	local npcId = cfg.npcid
	local list = {}

	for id, data in pairs(RiftLevelData) do
		if data.npcid == npcId then
			list[#list + 1] = {
				levelId = id,
				config = data
			}
		end
	end

	table.sort(list, function(a, b)
		local la, lb = a.config.entity_lv or 0, b.config.entity_lv or 0

		if la == lb then
			return a.levelId < b.levelId
		end

		return la < lb
	end)

	local selectIndex = self:_getDefaultDifficultyIndex(list)

	for i, item in ipairs(list) do
		item.tabIndex = i
	end

	return list, selectIndex
end

function FissureModel:getMutationBuffs(levelConfig)
	local ret = {}

	if not levelConfig then
		return ret
	end

	for _, key in ipairs({
		"envBuff01",
		"envBuff02"
	}) do
		local buffId = levelConfig[key]

		if buffId and buffId ~= 0 then
			local buffCfg = RiftBuffData[buffId]

			if buffCfg then
				ret[#ret + 1] = {
					buffId = buffId,
					config = buffCfg
				}
			end
		end
	end

	return ret
end

function FissureModel:getRecommendElements(levelConfig)
	local ret = {}

	if not levelConfig or not levelConfig.recommendedElements then
		return ret
	end

	for _, element in ipairs(levelConfig.recommendedElements) do
		ret[#ret + 1] = {
			element = element
		}
	end

	return ret
end

function FissureModel:getVictoryConditionText(levelConfig)
	if not levelConfig then
		return ""
	end

	local base = levelConfig.desc or ""
	local time = levelConfig.time

	if time and time > 0 then
		return string.format("%s(%ds)", base, time)
	end

	return base
end

function FissureModel:isFinished(levelId)
	local state = pg.me:getLevelState(levelId)

	if state and state == Const.RiftState.Got then
		return true
	end

	return false
end

function FissureModel:canGetReward(levelId)
	return self:getLevelState(levelId) == Const.RiftState.Win
end

function FissureModel:getLevelState(levelId)
	if not pg.me or not levelId then
		return Const.RiftState.None
	end

	return pg.me:getLevelState(levelId) or Const.RiftState.None
end

function FissureModel:isChallengeAvailable(levelId)
	local list = self:getDifficultyGroup(levelId)
	local difficulties = list

	if type(list) ~= "table" then
		return true
	end

	for i, item in ipairs(difficulties) do
		if item.levelId == levelId then
			if i <= 1 then
				return true
			end

			return self:getLevelState(difficulties[i - 1].levelId) == Const.RiftState.Got
		end
	end

	return true
end

function FissureModel:_getDefaultDifficultyIndex(difficulties)
	if not difficulties or #difficulties == 0 then
		return 1
	end

	for i, item in ipairs(difficulties) do
		local state = self:getLevelState(item.levelId)

		if state == Const.RiftState.Win then
			return i
		end

		if state == Const.RiftState.None then
			if i > 1 and self:getLevelState(difficulties[i - 1].levelId) == Const.RiftState.Win then
				return i - 1
			end

			return i
		end
	end

	return #difficulties
end

function FissureModel:getFollowPets()
	local data = {
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		},
		{
			isEmpty = true
		}
	}
	local player = pg.me
	local petPrepareList = player.petPrepareList

	for idx = 1, 4 do
		local petId = petPrepareList[idx]

		if petId then
			local pet = pg.me.pets[petId]

			data[idx] = LuaUIUtils.generatePetInfo(pet)
		end
	end

	return data
end

return FissureModel
