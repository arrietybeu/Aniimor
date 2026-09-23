-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\MapModel.lua

local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local ChestData = require("Data.chest_data")
local DropData = require("Data.drop_data")
local PetData = require("Data.pet_data")
local GameplayTargetData = require("Data.gameplay_target_data")
local MapLevelConfigData = require("Data.map_level_config_data")
local MapFiltrateConfigData = require("Data.map_filtrate_config_data")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ElementNameToId = require("Data.element_name_to_id")
local ClientUtils = require("Utils.ClientUtils")
local MapModel = Class.LightClass("MapModel", UIModel)
local Time = require("Core.Common.Time")
local MapOverlapScene = require("Data.map_overlap_scene")
local SceneData = require("Data.scene_data")
local NpcDuelData = require("Data.npc_duel_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local SceneDistributeAreaData = require("Data.scene_distribute_area_data")
local MapUtils = require("Guis.Utils.MapUtils")
local MapAreaConfigData = require("Data.map_area_config_data")
local TeleportMarkEventData = require("Data.teleport_mark_event_data")
local MarkIdToNpcDuelIdData = require("Data.mark_id_to_npc_duel_id_data")
local UIConst = require("Const.UIConst")
local MapHelper = require("GameApp.Map.MapHelper")
local TimeUtils = require("Common.Utils.TimeUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local NpcDuelSharedUtils = require("Common.Utils.NpcDuelSharedUtils")

MapModel.MAPS = {
	IDYLL_WATER = 3003,
	ARK = 501,
	IDYLL = 3000
}

local PET_SHOW_TAB = PetResearchUtils.PET_SHOW_TAB.FORM

function MapModel:refreshPetShowTab(curTab)
	PET_SHOW_TAB = curTab or PetResearchUtils.PET_SHOW_TAB.FORM
end

function MapModel:getPetShowTab()
	return PET_SHOW_TAB
end

function MapModel:getCurrencyDataList()
	local idList = {}

	if pg.me:checkFunctionUnlock("VITALITY") then
		table.insert(idList, Const.CommonEnergyType_Stamina)
	end

	local res = {}

	for i, id in ipairs(idList) do
		res[i] = {
			id = id,
			icon = LuaUIUtils.getIconByItemId(id),
			num = ClientUtils.getItemCountById(id, true)
		}
	end

	return res
end

function MapModel:getSpawnerIdByMarkName(markName)
	local arr = string.split(markName, "_")
	local spawnerId

	if #arr > 3 then
		spawnerId = arr[3]

		for i = 4, #arr do
			spawnerId = spawnerId .. "_" .. arr[i]
		end
	else
		spawnerId = tonumber(arr[3])
		spawnerId = spawnerId or arr[3]
	end

	return spawnerId
end

function MapModel:getCustomMarkName(id, sceneId)
	local customMarkGenId = MapHelper.getCustomMarkGenId(id, sceneId)

	if not customMarkGenId or not pg.me.customMapMarkMap[sceneId] then
		return pg.getGameString("CUSTOM_MARK")
	end

	local customMarkInfo = pg.me.customMapMarkMap[sceneId][customMarkGenId] or {}

	if string.isNilOrEmpty(customMarkInfo.name) then
		return pg.getGameString("CUSTOM_MARK")
	else
		return pg.getLocalizationText(customMarkInfo.name)
	end
end

function MapModel:getLocationInfo(sceneId, markId, markConfigId)
	local rewardLinkedData = LevelRewardLinkedData[markId]

	if not rewardLinkedData then
		return {}
	end

	local helpID = rewardLinkedData.helpID
	local propertyOrNot = rewardLinkedData.PropertyOrNot
	local requirePet = rewardLinkedData.requirePet
	local requireSkill = rewardLinkedData.requireSkill
	local recommenSkill = rewardLinkedData.recommenSkill
	local recommendPet = rewardLinkedData.recommendPet
	local playerNum = rewardLinkedData.playerNum
	local cratesInfo
	local cratesInfoLink = rewardLinkedData.cratesInfoFromTarget

	if cratesInfoLink then
		local gameplayTargetData = GameplayTargetData[cratesInfoLink]

		if gameplayTargetData then
			cratesInfo = gameplayTargetData.chest
		end
	end

	local fightInfo = pg.game.map:isPOIPopupBelongsToFightType(sceneId, markId)
	local isFight, maxLevelRequire, propertyPrefer, entityId, idInType, extraProperties = fightInfo[1], fightInfo[2], fightInfo[3], fightInfo[4], fightInfo[5], fightInfo[6]
	local dungenLimit = 0

	if requirePet or requireSkill then
		dungenLimit = 1
		requirePet = {}

		for _, petTemplateId in pairs(rewardLinkedData.requirePet) do
			local pData = PetData[petTemplateId] or {}

			requirePet[#requirePet + 1] = {
				iconName = pData.iconName
			}
		end

		if requireSkill then
			requireSkill = {}

			for _, skillParamId in pairs(rewardLinkedData.requireSkill) do
				requireSkill[#requireSkill + 1] = {
					skillParamId = skillParamId
				}
			end
		end
	end

	if propertyOrNot == 1 and isFight and maxLevelRequire and propertyPrefer or recommenSkill then
		dungenLimit = 2

		if recommenSkill then
			recommenSkill = {}

			for _, skillParamId in pairs(rewardLinkedData.recommenSkill) do
				recommenSkill[#recommenSkill + 1] = {
					skillParamId = skillParamId
				}
			end
		end
	end

	if dungenLimit == 0 then
		return {
			helpID = helpID,
			dungenLimit = dungenLimit,
			playerNum = playerNum,
			cratesInfo = cratesInfo,
			entityId = entityId,
			idInType = idInType,
			markConfigId = markConfigId,
			recommendPet = recommendPet
		}
	elseif dungenLimit == 1 then
		return {
			helpID = helpID,
			dungenLimit = dungenLimit,
			playerNum = playerNum,
			cratesInfo = cratesInfo,
			requirePet = requirePet,
			requireSkill = requireSkill,
			entityId = entityId,
			idInType = idInType,
			markConfigId = markConfigId,
			recommendPet = recommendPet
		}
	else
		return {
			helpID = helpID,
			dungenLimit = dungenLimit,
			playerNum = playerNum,
			cratesInfo = cratesInfo,
			maxLevelRequire = maxLevelRequire,
			propertyPrefer = propertyPrefer,
			extraProperties = extraProperties,
			recommenSkill = recommenSkill,
			entityId = entityId,
			idInType = idInType,
			markConfigId = markConfigId,
			recommendPet = recommendPet
		}
	end
end

function MapModel:hasSpecialPetInArea(smallAreaId)
	local rainbowPets = MapHelper.getAreaRainbowPetTemplates(smallAreaId)

	if rainbowPets and next(rainbowPets) then
		return true
	end

	local areaWeatherInfo = MapHelper.getAreaWeatherForecast(smallAreaId)

	if areaWeatherInfo then
		local weatherInfo = areaWeatherInfo[1]

		if weatherInfo then
			local pets = MapBlockConfigData[smallAreaId][self:getWeatherStateName(weatherInfo.weatherId)]

			if pets ~= nil then
				return true
			end
		end
	end

	return false
end

function MapModel:getWeatherData(smallAreaId)
	local weatherData = {}
	local weatherInfoToday = {}
	local areaWeatherInfo = MapHelper.getAreaWeatherForecast(smallAreaId)

	weatherData[1] = {
		isToday = true,
		tIndex = 1,
		title = pg.getGameString("WEATHER_TODAY")
	}

	local dataIndex = 2
	local lastStartHour = -1
	local nowStartDate = os.date("*t", Time.secondCache)

	nowStartDate.hour = 0
	nowStartDate.min = 0
	nowStartDate.sec = 1

	local todayStartTime = os.time(nowStartDate)
	local nowEndDate = os.date("*t", Time.secondCache)

	nowEndDate.hour = 23
	nowEndDate.min = 59
	nowEndDate.sec = 59

	local todayEndTime = os.time(nowEndDate)
	local hasShowTomorrow = false
	local weatherState = 0

	for i = 1, #areaWeatherInfo do
		local weatherPets = {}
		local curWeatherInfo = {}
		local weatherInfo = areaWeatherInfo[i]
		local startDateTime = weatherInfo.startTime
		local endDateTime = weatherInfo.endTime - 1
		local startTime = TimeUtils.timeToFormatString3(startDateTime)
		local endTime = TimeUtils.timeToFormatString3(endDateTime)
		local hour = tonumber(os.date("%H", weatherInfo.startTime))

		if todayEndTime < weatherInfo.startTime and not hasShowTomorrow then
			hasShowTomorrow = true

			local data = {}

			data.time = "Tomorrow"
			data.tIndex = 1
			data.smallAreaId = smallAreaId

			table.insert(weatherData, dataIndex, data)

			weatherData[dataIndex].title = pg.getGameString("WEATHER_TOMORROW")
			weatherData[dataIndex].tIndex = 1
			dataIndex = dataIndex + 1
		end

		lastStartHour = hour
		curWeatherInfo.time = startTime .. "-" .. endTime
		curWeatherInfo.weatherId = weatherInfo.weatherId

		local pets = MapBlockConfigData[smallAreaId][self:getWeatherStateName(weatherInfo.weatherId)]

		if pets ~= nil then
			for k, v in pairs(pets) do
				local petData = {}

				petData.smallAreaId = smallAreaId
				petData.petPrototypeId = v

				if LuaUIUtils.checkPetCatch(smallAreaId, v) then
					petData.state = LuaUIUtils.PetInfoState.Catch
				elseif LuaUIUtils.checkPetFind(smallAreaId, v) then
					petData.state = LuaUIUtils.PetInfoState.Find
				elseif LuaUIUtils.checkFriendCatch(smallAreaId, v) then
					petData.state = LuaUIUtils.PetInfoState.FriendCatch
					petData.friendId = LuaUIUtils.getLatestCatchFriendId(smallAreaId, v)
				else
					petData.state = LuaUIUtils.PetInfoState.None
				end

				table.insert(weatherPets, k, petData)
			end
		end

		curWeatherInfo.pets = weatherPets

		if i == 1 then
			weatherInfoToday.weatherInfo = curWeatherInfo

			if pets ~= nil then
				weatherState = #pets > 0 and 1 or 2
			end
		else
			local data = {}

			data.time = "Today"
			data.weatherInfo = curWeatherInfo
			data.tIndex = 0
			data.smallAreaId = smallAreaId
			data.index = #weatherData

			table.insert(weatherData, dataIndex, data)

			dataIndex = dataIndex + 1
		end

		if weatherState == 0 then
			weatherState = 2
		end
	end

	return weatherData, weatherInfoToday, weatherState
end

function MapModel:getWeatherStateName(i)
	for key, value in pairs(UIConst.WeatherState) do
		if value == i then
			return key
		end
	end

	return nil
end

function MapModel:getLayerData(sceneId, layerId)
	local ret = {}

	if not MapLevelConfigData[sceneId] or not MapLevelConfigData[sceneId][layerId] then
		return ret
	end

	local areaData = MapLevelConfigData[sceneId][layerId]
	local unlockData = pg.me:getMapLayerUnlockData()

	for k, v in pairs(areaData) do
		if unlockData[sceneId] and unlockData[sceneId][layerId] and unlockData[sceneId][layerId][k] then
			local temp = v[0] or v[1]
			local t = {}

			t.levelIndex = k
			t.totalDesc = pg.getLocalizationText(temp.desc)
			t.icon = temp.selectedIcon
			t.deIcon = temp.unSelectedIcon
			t.layerData = {
				sceneId,
				layerId,
				k,
				v[1] and 1 or 0
			}
			ret[#ret + 1] = t
		end
	end

	local t = {}

	t.levelIndex = 0
	t.totalDesc = pg.getGameString("MAP_LAYER_GROUND")
	t.icon = "$UI_Img_MapLayerSys_GroundSelected.png"
	t.deIcon = "$UI_Img_MapLayerSys_GroundUnselected.png"
	t.layerData = {
		sceneId,
		0,
		0,
		0
	}
	ret[#ret + 1] = t

	table.sort(ret, function(a, b)
		return a.levelIndex > b.levelIndex
	end)

	return ret
end

function MapModel:getSortTagListData(sceneId)
	local result = {}

	for k, v in pairs(MapFiltrateConfigData) do
		local contains = false

		for _, v1 in pairs(v.categories) do
			if pg.game.map.sceneMarkPointConfigCountData[sceneId][v1] then
				contains = true

				break
			end
		end

		if contains then
			local t = {}

			t.name = pg.getLocalizationText(v.name)
			t.categories = v.categories
			t.index = k
			result[#result + 1] = t
		end
	end

	table.sort(result, function(a, b)
		return a.index < b.index
	end)

	return result
end

function MapModel:getSortNormalListData(sceneId)
	local result = {}

	for k, v in pairs(MapFiltrateConfigData) do
		local contains = false

		for _, v1 in pairs(v.categories) do
			if pg.game.map.sceneMarkPointConfigCountData[sceneId][v1] then
				contains = true

				break
			end
		end

		if contains then
			result[#result + 1] = {
				tIndex = 0,
				name = pg.getLocalizationText(v.name),
				sortIndex = k * 100
			}
			result[#result + 1] = {
				tIndex = 1,
				categories = v.categories,
				sortIndex = k * 100 + 1
			}
		end
	end

	table.sort(result, function(a, b)
		return a.sortIndex < b.sortIndex
	end)

	return result
end

function MapModel:getNameByMarkType(markConfigId)
	if not DefaultMapMarkData[markConfigId] then
		return " "
	end

	if not DefaultMapMarkData[markConfigId].typeName then
		return " "
	end

	return DefaultMapMarkData[markConfigId].typeName
end

function MapModel:getIconByMarkType(markConfigId)
	if not DefaultMapMarkData[markConfigId] then
		return nil
	end

	if not DefaultMapMarkData[markConfigId].icon then
		return nil
	end

	return DefaultMapMarkData[markConfigId].icon
end

function MapModel:getSearchListData(searchText, sceneId)
	local result = {}

	for k, v in pairs(MapFiltrateConfigData) do
		local contains = 0
		local tempT = {}

		for _, v1 in pairs(v.categories) do
			if pg.game.map.sceneMarkPointConfigCountData[sceneId][v1] and string.find(pg.getLocalizationText(DefaultMapMarkData[v1].typeName), searchText) then
				contains = contains + 1
				tempT[#tempT + 1] = v1
			end
		end

		if contains > 0 then
			result[#result + 1] = {
				tIndex = 0,
				name = pg.getLocalizationText(v.name),
				sortIndex = k * 100
			}
			result[#result + 1] = {
				tIndex = 1,
				categories = tempT,
				sortIndex = k * 100 + 1
			}
		end
	end

	table.sort(result, function(a, b)
		return a.sortIndex < b.sortIndex
	end)

	return result
end

function MapModel:getPlayerLevelPeriodRewards(spawnerId)
	if not pg.me then
		return nil
	end

	local levelLinkedData = LevelRewardLinkedData[spawnerId]

	if not levelLinkedData then
		return nil
	end

	if not levelLinkedData.cost then
		return nil
	end

	local costItemIcon = LuaUIUtils.getIconByItemId(levelLinkedData.cost[1])
	local costItemNum = levelLinkedData.cost[2]
	local ret = {}

	ret.level = LuaUIUtils.getStarTitleName(pg.me.starTitle, true)

	if not ret.level then
		return nil
	end

	if not levelLinkedData.periodRewardId then
		return nil
	end

	if not levelLinkedData.periodRewardId[pg.me.starTitle] then
		return nil
	end

	ret.itemCountTable = LuaUIUtils.getRewardItemByDropId(levelLinkedData.periodRewardId[pg.me.starTitle])
	ret.costItemIcon = costItemIcon
	ret.costItemNum = costItemNum
	ret.costItemId = levelLinkedData.cost[1]

	return ret
end

function MapModel:getBossChallengeInfo(spawnerId)
	local useLimitMap = pg.me and pg.me.useLimitMap

	if not useLimitMap then
		return nil
	end

	local levelLinkedData = LevelRewardLinkedData[spawnerId]
	local chestId = levelLinkedData and levelLinkedData.chestId

	if not chestId or chestId == 0 then
		return nil
	end

	local chestData = ChestData[chestId]
	local rewardId = chestData and chestData.reward
	local needItem = chestData and chestData.needItem

	if not rewardId or rewardId == 0 or not needItem then
		return nil
	end

	local dropData = DropData[rewardId]
	local limitId = dropData and dropData.limitId
	local costItemId = needItem[1]
	local costItemNum = needItem[2]

	if not limitId or limitId == 0 or not costItemId or not costItemNum then
		return nil
	end

	local totalCount = useLimitMap:getTotalCount(limitId)

	if not totalCount or totalCount <= 0 then
		return nil
	end

	return {
		chestId = chestId,
		rewardId = rewardId,
		limitId = limitId,
		costItemId = costItemId,
		costItemNum = costItemNum,
		remainCount = useLimitMap:getRemainCount(limitId),
		totalCount = totalCount
	}
end

function MapModel:findPosMark(markCaches, x, z)
	for spawnerId, markCache in pairs(markCaches) do
		if spawnerId == 72037417 then
			local a
		end

		local uBtn = markCache.button

		if NotNil(uBtn) then
			local _, hideAllChildren = uBtn:TryGetCurrentPage("hideAllChildren")
			local _, mapFilterHide = uBtn:TryGetCurrentPage("MapFilterHide")
			local offset, newX, newZ

			if markCache.realSceneId and MapOverlapScene[markCache.realSceneId] and SceneData[markCache.realSceneId] then
				local markWholemapOffset = SceneData[markCache.realSceneId].wholemapOffset

				if markWholemapOffset and #markWholemapOffset == 3 then
					offset = markWholemapOffset
				end
			end

			if uBtn.gameObject.activeSelf == true and tostring(uBtn.visibility) == tostring(CS.XGUI.EVisibility.Visible) and hideAllChildren == 0 and mapFilterHide == 0 and markCache.markPos and markCache.ClickorNot == 0 then
				if offset then
					newX = x - offset[1]
					newZ = z - offset[3]
				else
					newX = x
					newZ = z
				end

				if math.abs(newX - markCache.markPos[1]) <= 1 and math.abs(newZ - markCache.markPos[3]) <= 1 then
					return uBtn.name
				end
			end
		end
	end
end

function MapModel:getQuickTeleportData(sceneId)
	local result = {}
	local sceneData = SceneData[sceneId]

	if not sceneData then
		return result
	end

	local quickTeleportList = sceneData.mapQuickTeleport

	if not quickTeleportList then
		return result
	end

	for scene, group in pairs(quickTeleportList) do
		local t = {}

		for order, data in pairs(group) do
			t.teleportToSceneId = scene
			t.name = SceneData[scene] and SceneData[scene].sceneName and pg.getLocalizationText(SceneData[scene].sceneName) or ""
			t.order = order

			if data[1] == 0 then
				t.markId = MapUtils.getPlayerRecordPosCampId(scene)
			else
				t.markId = data[1]
			end

			local info = pg.game.map:getSceneMarkInfoByMarkId(scene, t.markId)

			t.icon = data[2]

			local specificName = "nil"

			if info then
				if info.txt then
					specificName = info.txt
				elseif info.infoTitle then
					specificName = info.infoTitle
				end
			end

			t.specificName = specificName

			if TeleportMarkEventData[t.markId] then
				t.eventType = TeleportMarkEventData[t.markId].eventType

				for k, v in pairs(TeleportMarkEventData[t.markId].eventParam) do
					if not t.eventParam then
						t.eventParam = {}
					end

					t.eventParam[k] = v
				end
			end

			if t.markId then
				result[#result + 1] = t
			end
		end
	end

	table.sort(result, function(a, b)
		return a.order < b.order
	end)

	return result
end

function MapModel:getAllSmallAreaInfo(sceneId)
	local rootSceneId = MapHelper.getRootScene(sceneId)
	local mapDisplayOverlayScenes = SceneData[rootSceneId] and SceneData[rootSceneId].mapDisplayOverlayScenes or {}
	local allScenes = {
		rootSceneId
	}

	for _, scene in pairs(mapDisplayOverlayScenes) do
		allScenes[#allScenes + 1] = scene
	end

	local result = {}

	for _, scene in pairs(allScenes) do
		local areaIds = SceneDistributeAreaData[scene]

		if areaIds then
			for _, areaId in pairs(areaIds) do
				local t = {}

				t.areaId = areaId
				t.order = areaId
				t.campId = MapAreaConfigData[areaId].Campid
				t.areaName = pg.getLocalizationText(MapAreaConfigData[areaId].areaName)
				result[#result + 1] = t
			end
		end
	end

	table.sort(result, function(a, b)
		return a.order < b.order
	end)

	return result
end

function MapModel:getDuelMarkInfo(markId)
	if not markId then
		return
	end

	local duelId = MarkIdToNpcDuelIdData[markId]

	if not duelId then
		return
	end

	local duelData = NpcDuelData[duelId]

	if not duelData then
		return
	end

	local ret = {}
	local variantId = MapUtils.getCurDuelVariantId(duelId)

	duelData = duelData[variantId]

	if not duelData then
		return
	end

	ret.helpID = duelData.helpId
	ret.dungenLimit = 2
	ret.maxLevelRequire = pg.game.npcDuel:getNpcDuelLevelByDuelId(duelId, variantId)

	local recommendedElements = duelData.recommendedElements or {}
	local elements = {}

	for index, elementName in pairs(recommendedElements) do
		local elementId = ElementNameToId[elementName]

		if elementId then
			elements[index] = {
				elementId = elementId
			}
		end
	end

	ret.propertyPrefer = elements

	local conditionInfo = NpcDuelSharedUtils:getCurrentVariantStartCondition(pg.me, duelId)

	if conditionInfo.startCondition and conditionInfo.startCondition > 0 then
		local conditionDesc = LuaUIUtils.getConditionUnlockDesc(conditionInfo.startCondition)

		ret.startCondition = conditionInfo.startCondition
		ret.startConditionMet = conditionInfo.result
		ret.startConditionDesc = pg.getFormatText(pg.getGameString("NPCDUEL_PET_LOCKED"), conditionDesc)
	end

	if not next(ret) then
		return
	end

	return ret
end

function MapModel:getDuelMarkRewards(markId)
	if not markId then
		return
	end

	local duelId = MarkIdToNpcDuelIdData[markId]

	if not duelId then
		return
	end

	local duelData = NpcDuelData[duelId]

	if not duelData then
		return
	end

	local ret = {}

	duelData = duelData[MapUtils.getCurDuelVariantId(duelId)]

	local duelStatus = MapUtils.getNpcDuelStatus(markId)

	if duelStatus > 2 then
		duelData = nil
	end

	if not duelData then
		return
	end

	ret.rewards = LuaUIUtils.getRewardItemByDropId(duelData.firstRewardId)
	ret.title = pg.getGameString("DUEL_REWARDS")

	return ret
end

return MapModel
