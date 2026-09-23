-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBall\\PetFertilityChooseBallModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetFertilityChooseBallModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CaptureUtils = require("Common.Utils.CaptureUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local ItemEffectData = require("Data.item_effect_data")
local PetTalentRandomGroupData = require("Data.pet_talent_random_group_data")
local PetCubeItemData = require("Data.pet_hatch_egg_cube_data")
local PetFertilityChooseBallModel = Class.LightClass("PetFertilityChooseBallModel", UIModel)
local AUTO_HIDE_TIME_TYPE_ALWAYS = 0
local AUTO_HIDE_TIME_TYPE_SEASON_STAGE = 1
local AUTO_HIDE_TIME_TYPE_FIXED = 2
local AREA_DATE_TIME_PATTERN = "^(%d+)/(%d+)/(%d+)/(%d+):(%d+):(%d+)$"

function PetFertilityChooseBallModel:_isValidCube(itemId)
	local cubeBallCfg = CaptureUtils.getBallCfg(itemId)

	if not cubeBallCfg then
		return false
	end

	local cubeRandomTalentGroup = cubeBallCfg.randomTalentGroup

	if cubeRandomTalentGroup and PetTalentRandomGroupData[cubeRandomTalentGroup] == nil then
		return false
	end

	return true
end

function PetFertilityChooseBallModel:_getAutoHideStartTime(itemId, cubeCfg)
	local timeType = cubeCfg.timeType or AUTO_HIDE_TIME_TYPE_ALWAYS

	if timeType == AUTO_HIDE_TIME_TYPE_ALWAYS then
		return 0
	end

	local timeParam = cubeCfg.timeParam or {}

	if timeType == AUTO_HIDE_TIME_TYPE_SEASON_STAGE then
		local seasonId = timeParam[1]
		local stageId = timeParam[2]
		local seasonStageInfo = Utils.getSeasonStageInfo(seasonId, stageId)

		if not seasonStageInfo or not seasonStageInfo.startTime then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("PetFertilityChooseBallModel invalid auto hide season stage, itemId=%s, seasonId=%s, stageId=%s", tostring(itemId), tostring(seasonId), tostring(stageId))
			end

			return nil
		end

		return seasonStageInfo.startTime
	end

	if timeType == AUTO_HIDE_TIME_TYPE_FIXED then
		local configTimeType = timeParam[1]
		local timeString = timeParam[2]

		if string.isNilOrEmpty(timeString) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("PetFertilityChooseBallModel invalid auto hide fixed time, itemId=%s, configTimeType=%s, timeString=%s", tostring(itemId), tostring(configTimeType), tostring(timeString))
			end

			return nil
		end

		local startTime, err = TimeUtils.configStringToTimestampByType(configTimeType, timeString, AREA_DATE_TIME_PATTERN)

		if not startTime then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("PetFertilityChooseBallModel failed to parse auto hide fixed time, itemId=%s, configTimeType=%s, timeString=%s, err=%s", tostring(itemId), tostring(configTimeType), tostring(timeString), tostring(err))
			end

			return nil
		end

		return startTime
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("PetFertilityChooseBallModel invalid auto hide timeType, itemId=%s, timeType=%s", tostring(itemId), tostring(timeType))
	end

	return nil
end

function PetFertilityChooseBallModel:isCubeVisibleInChooseList(itemId, count, now)
	local cubeCfg = PetCubeItemData[itemId]

	if not cubeCfg or cubeCfg.autoHide ~= 1 then
		return true
	end

	local startTime = self:_getAutoHideStartTime(itemId, cubeCfg)

	if startTime == nil then
		return true
	end

	now = now or Time.secondCache

	if not now or now <= 0 then
		now = Time.getSecond()
	end

	if now < startTime then
		return true
	end

	count = count or ItemUtils.getItemCountById(pg.me, itemId) or 0

	return count > 0
end

function PetFertilityChooseBallModel:getAllValidCubeList(eggItemId)
	local list = {}
	local eggCfg = PetHatchEggData[eggItemId]
	local unAvailableCubeMap = eggCfg and eggCfg.unavailable or {}
	local suggestItemId = eggCfg and eggCfg.suggest and eggCfg.suggest[1]

	for petCubeId, ballCfg in pairs(PetCubeItemData or EMPTY_TABLE) do
		local cubeId = petCubeId

		if self:_isValidCube(cubeId) then
			local count = ItemUtils.getItemCountById(pg.me, cubeId) or 0

			if self:isCubeVisibleInChooseList(cubeId, count) then
				local info = LuaUIUtils.getItemClientInfoById(cubeId)

				if info and info.name then
					info.count = count
					info.isEnough = count > 0
					info.itemId = cubeId
					info.ballLv = ballCfg.ballLv or 0
					info.sort = ballCfg.sort or 0
					info.isAvailable = unAvailableCubeMap[cubeId] ~= 1
					info.isRecommend = suggestItemId and cubeId == suggestItemId or false
					list[#list + 1] = info
				end
			end
		end
	end

	table.sort(list, function(a, b)
		if a.sort ~= b.sort then
			return a.sort < b.sort
		end

		return a.itemId < b.itemId
	end)

	return list
end

function PetFertilityChooseBallModel:getSelectedItemId()
	return self.selectedItemId
end

function PetFertilityChooseBallModel:setSelectedItemId(itemId)
	self.selectedItemId = itemId
end

function PetFertilityChooseBallModel:clearSelected()
	self.selectedItemId = nil
end

function PetFertilityChooseBallModel:getCubeInfoById(itemId, eggItemId)
	if not itemId then
		return nil
	end

	if not self:_isValidCube(itemId) then
		return nil
	end

	local info = LuaUIUtils.getItemClientInfoById(itemId)

	if not info then
		return nil
	end

	local count = ItemUtils.getItemCountById(pg.me, itemId) or 0

	info.count = count
	info.isEnough = count > 0

	local eggCfg = PetHatchEggData[eggItemId]
	local unAvailableCubeMap = eggCfg and eggCfg.unavailable or {}

	info.isAvailable = unAvailableCubeMap[itemId] ~= 1

	local cubeBallCfg = CaptureUtils.getFetilityCubeCfg(itemId)

	info.fertityDesc = cubeBallCfg and cubeBallCfg.petFertilityDesc

	local cubeBallCfg = CaptureUtils.getBallCfg(itemId)

	info.modelResPath = cubeBallCfg and cubeBallCfg.model
	info.linkEffect = cubeBallCfg and cubeBallCfg.linkEffect

	return info
end

return PetFertilityChooseBallModel
