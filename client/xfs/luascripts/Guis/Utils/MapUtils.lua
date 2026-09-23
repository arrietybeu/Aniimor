-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\MapUtils.lua

local DynamicMarkConfigData = require("Data.dynamic_mark_config_data")
local DynamicMarkBankData = require("Data.dynamic_mark_bank_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local MapAreaConfigData = require("Data.map_area_config_data")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local RedDotConst = require("Const.RedDotConst")
local RedDotUtils = require("Utils.RedDotUtils")
local NpcDuelIdToMarkIdsData = require("Data.npc_duel_id_to_mark_ids_data")
local MarkIdToNpcDuelIdData = require("Data.mark_id_to_npc_duel_id_data")
local WeatherData = require("Data.weather_data")
local MeteorologyData = require("Data.meteorology_data")
local PlayerBadgeData = require("Data.player_badge_data")
local PlayerSkillData = require("Data.player_skill_data")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local AddressDataConst = require("Const.AddressDataConst")
local NpcDuelData = require("Data.npc_duel_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local MapUtils = {}

MapUtils.GRAB_EGG_TRANSMITTER_MARK_CONFIG_ID = 1003

local MAP_BLOCK_WEATHER_FIELD_ORDER = {
	"aurora",
	"rain",
	"snow",
	"thunder",
	"sun"
}
local MAP_BLOCK_WEATHER_FIELD_TO_ID = {
	rain = UIConst.WeatherState.rain,
	snow = UIConst.WeatherState.snow,
	thunder = UIConst.WeatherState.thunder,
	sun = UIConst.WeatherState.sun
}

function MapUtils.getDynamicMarkStatus(markId)
	local dict = pg.me:getClientInfo(Const.CLIENT_KEY.DYNAMIC_MARK_INFO, Const.CLINET_KEY_STR.DYNAMIC_MARK_INFO)

	dict = dict or {}

	if not dict[markId] then
		dict[markId] = {
			status = 1,
			params = {}
		}
	end

	return dict[markId]
end

function MapUtils.setDynamicMarkStatus(markId, status, params)
	local dict = pg.me:getClientInfo(Const.CLIENT_KEY.DYNAMIC_MARK_INFO, Const.CLINET_KEY_STR.DYNAMIC_MARK_INFO)

	dict[markId] = {
		status = status,
		params = params
	}

	pg.me:setClientInfo(Const.CLIENT_KEY.DYNAMIC_MARK_INFO, Const.CLINET_KEY_STR.DYNAMIC_MARK_INFO, dict)
	facade:SendMessageCommand(MessageName.ON_DYNAMIC_MARK_STATUS_CHANGED, {
		markId = markId,
		status = status,
		params = params
	})
end

function MapUtils.parseDynamicMarkStatus(markId)
	local markStatus = MapUtils.getDynamicMarkStatus(markId)

	if not markStatus then
		return
	end

	local markStatusInfo = DynamicMarkConfigData[markId]

	if not markStatusInfo then
		return
	end

	local markStatusConfig = markStatusInfo[string.format("Status%s", markStatus.status)]
	local markStatusExtraInfo = markStatusInfo[string.format("Status%sExtraInfo", markStatus.status)]

	if not markStatusConfig then
		return
	end

	local result = {}

	for _, config in pairs(markStatusConfig) do
		local partId = config[1]
		local params = config[2]
		local markBankInfo = DynamicMarkBankData[partId]

		if markBankInfo then
			table.insert(result, {
				res = markBankInfo.res,
				params = params,
				partId = partId,
				extraInfo = markStatusExtraInfo,
				serverParams = markStatus.params
			})
		end
	end

	return result
end

function MapUtils.parseFirstDynamicMarkStatusExtraInfo(markId)
	local markStatus = MapUtils.getDynamicMarkStatus(markId)

	if not markStatus then
		return
	end

	local markStatusInfo = DynamicMarkConfigData[markId]

	if not markStatusInfo then
		return
	end

	local markStatusExtraInfo = markStatusInfo[string.format("Status%sExtraInfo", markStatus.status)]

	return markStatusExtraInfo
end

function MapUtils.getDynamicMarkSimpleIcon(markId)
	local markStatusExtraInfo = MapUtils.parseFirstDynamicMarkStatusExtraInfo(markId)

	if not markStatusExtraInfo then
		return
	end

	return markStatusExtraInfo[1]
end

local tmpPos = {}

function MapUtils.getPlayerRecordPosCampId(sceneId)
	if not pg.me then
		return
	end

	if not pg.me.recordPosMap then
		return
	end

	if not pg.me.recordPosMap[sceneId] then
		return
	end

	local pos = pg.me.recordPosMap[sceneId]

	tmpPos.x = pos[1]
	tmpPos.z = pos[3]

	local smallBlockId = pg.game.map:inWhichBlock(sceneId, false, tmpPos)

	if not smallBlockId then
		return
	end

	local blockConfig = MapBlockConfigData[smallBlockId]

	if not blockConfig then
		return
	end

	local largeBlockId = blockConfig.mapAreaId

	if not largeBlockId then
		return
	end

	local areaConfig = MapAreaConfigData[largeBlockId]

	if not areaConfig then
		return
	end

	return areaConfig.portalId
end

function MapUtils.getMarkDefaultResIcon(markConfigId)
	local markConfig = MapMarkResourceData[markConfigId]

	if not markConfig then
		return
	end

	local group = markConfig[0]

	if not group then
		return
	end

	return group.icon
end

function MapUtils.getMarkDefaultUnKnownResIcon(markConfigId)
	local markConfig = MapMarkResourceData[markConfigId]

	if not markConfig then
		return
	end

	local group = markConfig[0]

	if not group then
		return
	end

	return group.iconUnknow
end

function MapUtils.getLeylineFlowerMarkIcon(markConfigId, sceneId, markStatus, flowerState)
	local imgPath
	local markResource = MapMarkResourceData[markConfigId]
	local defaultRes = markResource and (markResource[sceneId] or markResource[0])

	if Const.MAP_MARK_STATUS_HIDE == markStatus or Const.MAP_MARK_STATUS_LOCKED == markStatus then
		imgPath = MapUtils.getMarkDefaultUnKnownResIcon(markConfigId)
	elseif Const.MAP_MARK_STATUS_UNLOCKED == markStatus or Const.MAP_MARK_STATUS_CLOSED == markStatus then
		imgPath = defaultRes and defaultRes.icon
	end

	if flowerState == LeylineFlowerConst.FLOWER_STATE.Budding then
		imgPath = AddressDataConst.UI_LEYLINE_FLOWER_BUDDING_ICON
	elseif flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming then
		imgPath = AddressDataConst.UI_LEYLINE_FLOWER_BLOMING_ICON
	elseif flowerState == LeylineFlowerConst.FLOWER_STATE.Fruiting or flowerState == LeylineFlowerConst.FLOWER_STATE.Withering then
		imgPath = AddressDataConst.UI_LEYLINE_FLOWER_FRUITING_ICON
	end

	return imgPath
end

function MapUtils.renderLeylineFlowerMark(gameObject, imgPath, showCircle, qualityPage, radius, glowScale)
	local objectReference = gameObject:GetComponent("ObjectReference")
	local uComponent = gameObject:GetComponent("UComponent")
	local imageIconUImage = objectReference:GetRefValue("imageIconUImage")
	local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")

	uComponent:TryChangePage("State", showCircle and 1 or 0)

	if showCircle then
		uComponent:TryChangePage("Quality", qualityPage)
	end

	if imgPath then
		imageIconUImage.url = imgPath
	end

	if radius ~= nil then
		local size = radius > 0 and radius * 8 or 200

		imgGlowUImage.transform:SetSizeDeltaEx(size, size)
	end

	if glowScale then
		imgGlowUImage.transform:SetLocalScaleEx(glowScale, glowScale, 1)
	end

	return imgGlowUImage
end

function MapUtils.isGrabEggTransmitterInUse(staticId)
	local space = pg.me and pg.me.space
	local transportInfo = space and space.transportInfo
	local transPoint = transportInfo and transportInfo[staticId]

	if not transPoint then
		return false
	end

	return transPoint.state ~= Const.ROB_EGG_TRANSPORT_STATE.NORMAL
end

function MapUtils.getGrabEggTransmitterIcon(staticId)
	local markConfigId = MapUtils.GRAB_EGG_TRANSMITTER_MARK_CONFIG_ID

	return MapUtils.isGrabEggTransmitterInUse(staticId) and MapUtils.getMarkDefaultResIcon(markConfigId) or MapUtils.getMarkDefaultUnKnownResIcon(markConfigId)
end

function MapUtils.renderLeylineClusterMapInfoPanel(objectReference, spawnerTable, taskContainer, ctrl)
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local txtAreaLvUSDFText = objectReference:GetRefValue("txtAreaLvUSDFText")
	local areaTransform = objectReference:GetRefValue("areaTransform")
	local petListUList = objectReference:GetRefValue("petListUList")
	local dadgeProgressUComponent = objectReference:GetRefValue("dadgeProgressUComponent")
	local petGatherTransform = objectReference:GetRefValue("petGatherTransform")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local weatherTransform = objectReference:GetRefValue("weatherTransform")
	local dadgeListUCentralList = objectReference:GetRefValue("dadgeListUCentralList")
	local leftBtnUButton = objectReference:GetRefValue("leftBtnUButton")
	local rightBtnUButton = objectReference:GetRefValue("rightBtnUButton")
	local selectIconUComponent = objectReference:GetRefValue("selectIconUComponent")

	if areaTransform then
		areaTransform.gameObject:SetActiveEx(true)
	end

	if petListUList then
		petListUList.gameObject:SetActiveEx(true)
	end

	if dadgeProgressUComponent then
		dadgeProgressUComponent.gameObject:SetActiveEx(true)
	end

	if petGatherTransform then
		petGatherTransform.gameObject:SetActiveEx(true)
	end

	if scrollRectUScrollRect then
		scrollRectUScrollRect.gameObject:SetActiveEx(false)
	end

	if weatherTransform then
		weatherTransform.gameObject:SetActiveEx(true)
	end

	if dadgeListUCentralList then
		dadgeListUCentralList.gameObject:SetActiveEx(true)
	end

	local smallAreaId = spawnerTable.largeAreaId

	if smallAreaId and smallAreaId ~= 0 then
		local minLv, maxLv = MapHelper.getAreaRecommandLevel(smallAreaId)

		ClientTextUtils.setText(txtAreaLvUSDFText, ClientTextUtils.formatShortLevelRange(minLv, maxLv))

		local rate = (Utils.getBlockCatchedRate(pg.me, smallAreaId) or 0) * 100

		ClientTextUtils.setText(txtNumUSDFText, string.format("%d%%", rate))

		if weatherTransform then
			MapUtils.renderWeatherIcon(nil, taskContainer, nil, true)
			MapUtils.renderWeatherIcon(smallAreaId, taskContainer, weatherTransform)
		end

		if dadgeProgressUComponent then
			MapUtils.renderDadgeProgress(dadgeProgressUComponent.transform:GetComponent("ObjectReference"), smallAreaId, selectIconUComponent)
		end

		if petListUList then
			local petLists = {}

			function petListUList.luaRenderItem(button, index, data)
				local list = button:GetChild("List"):GetComponent("UList")

				petLists[index + 1] = list

				function list.luaRenderItem(button1, index1, data1)
					LuaUIUtils.renderMapPetList(button1, index1, data1, smallAreaId)
				end

				local index_ = index + 1

				function list.luaClick()
					for i, list_ in ipairs(petLists) do
						if i ~= index_ then
							list_:DeselectAll()
						end
					end
				end

				list:SetList(data.petInfo)
			end

			local curPlatform = ClientUtils.getAdaptionPlatform()

			if curPlatform == UIConst.PLATFORM.Mobile then
				petListUList:SetList(LuaUIUtils.getSmallAreaPetData(smallAreaId, {
					4,
					5,
					4,
					5,
					4,
					5,
					4,
					5,
					4,
					5,
					4,
					5
				}))
			else
				petListUList:SetList(LuaUIUtils.getSmallAreaPetData(smallAreaId, {
					3,
					4,
					3,
					4,
					3,
					4,
					3,
					4,
					3,
					4,
					3,
					4
				}))
			end
		end

		if dadgeListUCentralList then
			MapUtils.renderBadgeList(dadgeListUCentralList, smallAreaId)

			if leftBtnUButton and rightBtnUButton then
				local stages, _, curFocusStage = MapUtils.getBadgeStageStatus(smallAreaId)
				local joystickCurIndex = curFocusStage and curFocusStage - 1 or 0

				if ctrl and ctrl.view and ctrl.view.consoleBarTransform then
					leftBtnUButton:SetHotkeyConsoleBarMultiPaths("CONSOLE_BAR_CYCLE_BADGE_REWARD", 8, {
						"Raw/GamepadLeftShoulder",
						"Raw/GamepadRightShoulder"
					}, nil, nil, ctrl.view.consoleBarTransform)
				end

				function leftBtnUButton.luaClick()
					if not dadgeListUCentralList or not dadgeListUCentralList.gameObject.activeSelf then
						return true
					end

					if joystickCurIndex <= 0 then
						return true
					end

					joystickCurIndex = joystickCurIndex - 1

					MapUtils.renderBadgeList(dadgeListUCentralList, smallAreaId, joystickCurIndex)
				end

				function rightBtnUButton.luaClick()
					if not dadgeListUCentralList or not dadgeListUCentralList.gameObject.activeSelf then
						return true
					end

					if not stages or joystickCurIndex >= #stages - 1 then
						return true
					end

					joystickCurIndex = joystickCurIndex + 1

					MapUtils.renderBadgeList(dadgeListUCentralList, smallAreaId, joystickCurIndex)
				end
			end
		end
	end
end

function MapUtils.clearLeylineClusterMapInfoPanel(objectReference)
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local areaTransform = objectReference:GetRefValue("areaTransform")
	local petListUList = objectReference:GetRefValue("petListUList")
	local dadgeProgressUComponent = objectReference:GetRefValue("dadgeProgressUComponent")
	local petGatherTransform = objectReference:GetRefValue("petGatherTransform")
	local weatherTransform = objectReference:GetRefValue("weatherTransform")
	local dadgeListUCentralList = objectReference:GetRefValue("dadgeListUCentralList")

	if areaTransform then
		areaTransform.gameObject:SetActiveEx(false)
	end

	if petListUList then
		petListUList.gameObject:SetActiveEx(false)
	end

	if dadgeProgressUComponent then
		dadgeProgressUComponent.gameObject:SetActiveEx(false)
	end

	if petGatherTransform then
		petGatherTransform.gameObject:SetActiveEx(false)
	end

	if scrollRectUScrollRect then
		scrollRectUScrollRect.gameObject:SetActiveEx(true)
	end

	if weatherTransform then
		weatherTransform.gameObject:SetActiveEx(false)
	end

	if dadgeListUCentralList then
		dadgeListUCentralList.gameObject:SetActiveEx(false)
	end
end

function MapUtils.getBlockRewardStatus(blockId, rewardIdx)
	return pg.me.blockCatchRewardStatus[blockId] and pg.me.blockCatchRewardStatus[blockId][rewardIdx]
end

function MapUtils._clickOpenBadgeDetailUI(button, badgeId)
	if badgeId then
		button.interactable = true

		function button.luaClick()
			pg.global.ui.badgeDetail:open({
				badgeId = badgeId
			})
		end
	else
		button.interactable = false
	end
end

function MapUtils.getNpcDuelStatus(markId)
	local duelId = MarkIdToNpcDuelIdData[markId]

	if not duelId then
		return 0
	end

	local npcDuelState = pg.me.npcDuelState or {}
	local data = npcDuelState[duelId]

	if not data then
		local config = NpcDuelData[duelId] and NpcDuelData[duelId][1]

		data = config and config.initState or 0
	end

	return data
end

function MapUtils.getDuelIdRelatedMarkIds(duelId)
	local markIds = NpcDuelIdToMarkIdsData[duelId] or {}

	return markIds
end

function MapUtils.getCurDuelVariantId(duelId)
	local npcDuelBasicInfo = pg.me.npcDuelBasicInfo or {}
	local variantIdMap = npcDuelBasicInfo.variantIdMap

	if not variantIdMap then
		return 1
	end

	return variantIdMap[duelId] or 1
end

function MapUtils.getAreaCollectionSections(blockId)
	local areaConfig = MapBlockConfigData[blockId]

	if not areaConfig then
		return
	end

	local t = {}
	local maxSecCount = 3

	for i = 1, maxSecCount do
		if areaConfig["unlockReward" .. i] then
			t[i] = areaConfig["unlockReward" .. i]
		end
	end

	if #t ~= 3 then
		return
	end

	return t
end

function MapUtils.renderDadgeProgress(objectReference, blockId, petAreaUComponent)
	local sections = MapUtils.getAreaCollectionSections(blockId)

	if not sections then
		return
	end

	local rate = Utils.getBlockCatchedRate(pg.me, blockId)
	local progresses = {
		objectReference:GetRefValue("progressUProgress1"),
		objectReference:GetRefValue("progress1UProgress2"),
		objectReference:GetRefValue("progress2UProgress3")
	}
	local texts = {
		objectReference:GetRefValue("textUSDFText1"),
		objectReference:GetRefValue("text1USDFText2"),
		objectReference:GetRefValue("text2USDFText3")
	}
	local v1, v2, v3

	if rate <= sections[1] then
		v1, v2, v3 = rate / sections[1], 0, 0
	elseif rate <= sections[2] then
		v1, v2, v3 = 1, (rate - sections[1]) / (sections[2] - sections[1]), 0
	else
		local span = sections[3] - sections[2]

		v1, v2, v3 = 1, 1, span > 0 and math.min((rate - sections[2]) / span, 1) or 1
	end

	progresses[1].value, progresses[2].value, progresses[3].value = v1, v2, v3

	local configData = MapBlockConfigData[blockId] or {}
	local badgeId1 = configData.badge1 or 0
	local badgeId2 = configData.badge2 or 0
	local badgeId3 = configData.badge3 or 0
	local badgeId4 = configData.badge4 or 0
	local serverUnlockInfo = pg.me.badgeUnlockInfoMap
	local areaUnlocked = pg.game.map:isPetAreaRewardUnlocked(blockId)
	local canGet1 = areaUnlocked and serverUnlockInfo[badgeId1] ~= nil
	local canGet2 = areaUnlocked and serverUnlockInfo[badgeId2] ~= nil
	local canGet3 = areaUnlocked and serverUnlockInfo[badgeId3] ~= nil
	local canGet4 = areaUnlocked and serverUnlockInfo[badgeId4] ~= nil
	local badgeUnlocked = {
		canGet1,
		canGet2,
		canGet3
	}

	for i, text in ipairs(texts) do
		if badgeUnlocked[i] then
			text.gameObject:SetActiveEx(false)
		else
			text.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(text, string.format("%d%%", sections[i] * 100))
		end
	end

	local scheduleIcon = objectReference:GetRefValue("scheduleIconRectTransform")
	local root = objectReference:GetRefValue("root")
	local gatherProgressPage = 0
	local showScheduleIcon = false

	if canGet3 or canGet4 then
		gatherProgressPage = 2
		showScheduleIcon = true
	elseif canGet2 then
		gatherProgressPage = 1
		showScheduleIcon = true
	elseif canGet1 then
		showScheduleIcon = true
	end

	scheduleIcon.gameObject:SetActiveEx(showScheduleIcon)
	root:TryChangePage("GatherProgress", gatherProgressPage)

	if petAreaUComponent then
		petAreaUComponent:TryChangePage("GatherProgress", gatherProgressPage)
	end
end

function MapUtils.renderWeatherIcon(smallAreaId, taskContainer, layoutTransform, clear)
	if taskContainer and type(taskContainer) == "table" and clear then
		if taskContainer.taskIds then
			for _, id in ipairs(taskContainer.taskIds) do
				pg.global.resMgr:TryCancelGOLoadAsyncTask(id)
			end
		end

		if taskContainer.taskObjs then
			for _, obj in ipairs(taskContainer.taskObjs) do
				pg.global.resMgr:RemoveInstanceToCache(obj)
			end
		end

		taskContainer.taskIds = nil
		taskContainer.taskObjs = nil

		return
	end

	if not smallAreaId or not taskContainer or not layoutTransform then
		return
	end

	if type(taskContainer) ~= "table" then
		return
	end

	local objectReference1 = layoutTransform:GetComponent("ObjectReference")

	if not objectReference1 then
		return
	end

	local weatherTransform = objectReference1:GetRefValue("weatherTransform")
	local textUSDFText = objectReference1:GetRefValue("textUSDFText")

	if not weatherTransform or not textUSDFText then
		return
	end

	taskContainer.taskIds = {}
	taskContainer.taskObjs = {}

	local meteorologyId = MapHelper.getAreaMeteorology(smallAreaId)

	if meteorologyId > 0 and MeteorologyData[meteorologyId] then
		local taskId = pg.global.resMgr:GetInstanceFromCacheByLua(MeteorologyData[meteorologyId].effect, function(obj, _)
			obj.transform.localPosition = Vector3.constZero

			table.insert(taskContainer.taskObjs, obj)
		end, 1, nil, weatherTransform, false, 0)

		table.insert(taskContainer.taskIds, taskId)
	end

	local weatherId = MapHelper.getWeatherByAreaId(smallAreaId)

	if WeatherData[weatherId] then
		local taskId = pg.global.resMgr:GetInstanceFromCacheByLua(WeatherData[weatherId].effect, function(obj, _)
			obj.transform.localPosition = Vector3.constZero

			table.insert(taskContainer.taskObjs, obj)
		end, 1, nil, weatherTransform, false, 0)

		table.insert(taskContainer.taskIds, taskId)
	end

	local areaWeatherInfo = MapHelper.getAreaWeatherForecast(smallAreaId)

	if areaWeatherInfo then
		local firstWeatherInfo = areaWeatherInfo[1]

		if firstWeatherInfo then
			local weatherData = WeatherData[firstWeatherInfo.weatherId]
			local weatherName = weatherData.name

			if meteorologyId ~= 0 then
				weatherName = MeteorologyData[meteorologyId].name
			end

			local curWeatherName = ClientTextUtils.getLocalizationText(weatherName)

			ClientTextUtils.setText(textUSDFText, curWeatherName)
		end
	end
end

function MapUtils.getWeatherIcon(smallAreaId, petTemplateId)
	if not smallAreaId or not petTemplateId then
		return nil, nil, nil
	end

	local blockCfg = MapBlockConfigData[smallAreaId]

	if not blockCfg then
		return nil, nil, nil
	end

	for _, field in ipairs(MAP_BLOCK_WEATHER_FIELD_ORDER) do
		local petList = blockCfg[field]

		if petList then
			for _, id in ipairs(petList) do
				if id == petTemplateId then
					if field == "aurora" then
						local meteorologyId = pg.me and pg.me:getAreaMeteorology(smallAreaId) or 0

						if meteorologyId > 0 and MeteorologyData[meteorologyId] then
							return MeteorologyData[meteorologyId].icon, meteorologyId, true
						end

						local meteorologyCfg = MeteorologyData[1]

						return meteorologyCfg and meteorologyCfg.icon, 1, true
					end

					local weatherId = MAP_BLOCK_WEATHER_FIELD_TO_ID[field]
					local weatherCfg = weatherId and WeatherData[weatherId]

					if weatherCfg then
						return weatherCfg.icon, weatherId, false
					end

					return nil, nil, nil
				end
			end
		end
	end

	return nil, nil, nil
end

function MapUtils.getBadgeStageStatus(blockId)
	local configData = MapBlockConfigData[blockId] or {}
	local serverUnlockInfo = pg.me.badgeUnlockInfoMap or {}
	local areaUnlocked = pg.game.map:isPetAreaRewardUnlocked(blockId)
	local stages = {}
	local firstUnclaimedStage, focusStage

	for stage = 1, 3 do
		local badgeId = configData["badge" .. stage]
		local hasGet = MapUtils.getBlockRewardStatus(blockId, stage) and true or false
		local canGet = areaUnlocked and badgeId ~= nil and serverUnlockInfo[badgeId] ~= nil

		stages[stage] = {
			stage = stage,
			hasGet = hasGet,
			canGet = canGet
		}

		if not hasGet then
			firstUnclaimedStage = firstUnclaimedStage or stage

			if canGet then
				focusStage = focusStage or stage
			end
		end
	end

	focusStage = focusStage or firstUnclaimedStage

	return stages, firstUnclaimedStage, focusStage
end

function MapUtils._renderBadgeStageItem(objectReference, blockId, stage, currentFocusIndex)
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnViewUButton = objectReference:GetRefValue("btnViewUButton")
	local stageListUList = objectReference:GetRefValue("stageListUList")
	local listUList = objectReference:GetRefValue("listUList")

	if pg.game.input:isUsingGamepad() and currentFocusIndex ~= nil and listUList then
		local isCurrent = stage - 1 == currentFocusIndex

		listUList.navGroupForceNonInteractable = not isCurrent
	end

	local configData = MapBlockConfigData[blockId] or {}

	if btnViewUButton then
		btnViewUButton.luaClick = nil
	end

	local badgeIcons = {
		AddressDataConst.UI_ICON_BADGE_2,
		AddressDataConst.UI_ICON_BADGE_3,
		AddressDataConst.UI_ICON_BADGE_4
	}

	if iconUImage then
		iconUImage.url = badgeIcons[stage]
	end

	MapUtils._clickOpenBadgeDetailUI(btnViewUButton, configData["badge" .. stage])

	local collectRate = Utils.getBlockCatchedRate(pg.me, blockId) or 0
	local unlockProgress = (configData["unlockReward" .. stage] or 0) * 100
	local d = {}

	d[1] = {
		value = string.format("%d%%", unlockProgress),
		finish = collectRate >= (configData["unlockReward" .. stage] or 0)
	}

	local badgeConditionId, badgeConditionNumRequire, conditionIcon = MapUtils.getBadgeCondition2(configData["badge" .. stage])

	if badgeConditionId then
		d[2] = {
			icon = conditionIcon,
			value = badgeConditionNumRequire,
			finish = ClientUtils.checkCondition(badgeConditionId)
		}
	else
		d[2] = {
			empty = true
		}
	end

	if stageListUList then
		function stageListUList.luaRenderItem(button, _, data)
			local objectReference1 = button:GetComponent("ObjectReference")
			local iocnUImage = objectReference1:GetRefValue("iocnUImage")
			local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

			if data.empty then
				button:TryChangePage("ConditionState", 2)

				return
			end

			if data.icon then
				iocnUImage.url = data.icon
			else
				iocnUImage.url = "$UI_Icon_MarkShare_Words_Organism.png"
			end

			ClientTextUtils.setText(txtNameUSDFText, data.value)
			button:TryChangePage("ConditionState", data.finish and 1 or 0)
		end

		stageListUList:SetList(d)
	end

	MapUtils.renderBadgeRewards(listUList, stage, blockId, configData)
end

function MapUtils.renderBadgeList(centralList, blockId, currentFocusIndex)
	if not centralList then
		return
	end

	local stages, firstUnclaimedStage, focusStage = MapUtils.getBadgeStageStatus(blockId)

	if not firstUnclaimedStage then
		centralList.gameObject:SetActiveEx(false)

		return
	end

	centralList.gameObject:SetActiveEx(true)

	local targetFocusIndex = currentFocusIndex ~= nil and currentFocusIndex or focusStage and focusStage - 1

	function centralList.luaRenderItem(button, index, data)
		local itemObjectReference = button:GetComponent("ObjectReference")

		MapUtils._renderBadgeStageItem(itemObjectReference, blockId, data.stage, targetFocusIndex)
	end

	centralList:SetList(stages)

	if targetFocusIndex ~= nil then
		centralList:GoToIndex(targetFocusIndex, true)
	end
end

function MapUtils.renderBadgePanel(objectReference, blockId)
	local root = objectReference:GetRefValue("root")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnViewUButton = objectReference:GetRefValue("btnViewUButton")
	local stageListUList = objectReference:GetRefValue("stageListUList")
	local listUList = objectReference:GetRefValue("listUList")

	btnViewUButton.luaClick = nil

	root.gameObject:SetActiveEx(true)

	local configData = MapBlockConfigData[blockId] or {}
	local hasGetReward1 = MapUtils.getBlockRewardStatus(blockId, 1)
	local hasGetReward2 = MapUtils.getBlockRewardStatus(blockId, 2)
	local hasGetReward3 = MapUtils.getBlockRewardStatus(blockId, 3)
	local stage

	if not hasGetReward1 then
		iconUImage.url = AddressDataConst.UI_ICON_BADGE_2

		MapUtils._clickOpenBadgeDetailUI(btnViewUButton, configData.badge1)

		stage = 1
	elseif not hasGetReward2 then
		iconUImage.url = AddressDataConst.UI_ICON_BADGE_3

		MapUtils._clickOpenBadgeDetailUI(btnViewUButton, configData.badge2)

		stage = 2
	elseif not hasGetReward3 then
		iconUImage.url = AddressDataConst.UI_ICON_BADGE_4

		MapUtils._clickOpenBadgeDetailUI(btnViewUButton, configData.badge3)

		stage = 3
	else
		root.gameObject:SetActiveEx(false)

		return
	end

	local collectRate = Utils.getBlockCatchedRate(pg.me, blockId) or 0
	local unlockProgress1 = (configData.unlockReward1 or 0) * 100
	local unlockProgress2 = (configData.unlockReward2 or 0) * 100
	local unlockProgress3 = (configData.unlockReward3 or 0) * 100
	local d = {}

	if stage then
		local badgeConditionId, badgeConditionNumRequire, conditionIcon

		if stage == 1 then
			d[1] = {
				value = string.format("%d%%", unlockProgress1),
				finish = collectRate >= (configData.unlockReward1 or 0)
			}
			badgeConditionId, badgeConditionNumRequire, conditionIcon = MapUtils.getBadgeCondition2(configData.badge1)
		elseif stage == 2 then
			d[1] = {
				value = string.format("%d%%", unlockProgress2),
				finish = collectRate >= (configData.unlockReward2 or 0)
			}
			badgeConditionId, badgeConditionNumRequire, conditionIcon = MapUtils.getBadgeCondition2(configData.badge2)
		else
			d[1] = {
				value = string.format("%d%%", unlockProgress3),
				finish = collectRate >= (configData.unlockReward3 or 0)
			}
			badgeConditionId, badgeConditionNumRequire, conditionIcon = MapUtils.getBadgeCondition2(configData.badge3)
		end

		if badgeConditionId then
			d[2] = {
				icon = conditionIcon,
				value = badgeConditionNumRequire,
				finish = ClientUtils.checkCondition(badgeConditionId)
			}
		else
			d[2] = {
				empty = true
			}
		end
	end

	function stageListUList.luaRenderItem(button, _, data)
		local objectReference1 = button:GetComponent("ObjectReference")
		local iocnUImage = objectReference1:GetRefValue("iocnUImage")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

		if data.empty then
			button:TryChangePage("ConditionState", 2)

			return
		end

		if data.icon then
			iocnUImage.url = data.icon
		else
			iocnUImage.url = "$UI_Icon_MarkShare_Words_Organism.png"
		end

		ClientTextUtils.setText(txtNameUSDFText, data.value)
		button:TryChangePage("ConditionState", data.finish and 1 or 0)
	end

	stageListUList:SetList(d)
	MapUtils.renderBadgeRewards(listUList, stage, blockId, configData)
end

function MapUtils.getBadgeCondition2(badgeId)
	if not badgeId then
		return
	end

	local badgeData = PlayerBadgeData[badgeId]

	if not badgeData then
		return
	end

	local conditions = badgeData.condition

	if not conditions or #conditions < 2 then
		return
	end

	local conditionId, conditionNumRequire

	conditionId = conditions[2][1]
	conditionNumRequire = conditions[2][2]

	if not conditionId or not conditionNumRequire then
		return
	end

	local triggerData = CustomTriggerData[conditionId]

	if not triggerData then
		return
	end

	local icon = triggerData.icon

	return conditionId, conditionNumRequire, icon
end

function MapUtils.renderBadgeRewards(list, stage, smallAreaId, configData)
	if not list or not stage or not smallAreaId or not configData then
		return
	end

	local badgeId = configData["badge" .. stage]
	local serverUnlockInfo = pg.me.badgeUnlockInfoMap[badgeId]
	local areaUnlocked = pg.game.map:isPetAreaRewardUnlocked(smallAreaId)
	local canGet = areaUnlocked and serverUnlockInfo ~= nil
	local hasGet = MapUtils.getBlockRewardStatus(smallAreaId, stage)
	local exFunc

	if canGet and not hasGet then
		function exFunc()
			pg.me:getPetAreaReward(smallAreaId, stage)
		end
	end

	local drops = LuaUIUtils.getRewardItemByDropId(configData["reward" .. stage], hasGet, canGet, nil, exFunc)

	for _, data in ipairs(drops) do
		data.rewardIdx = stage
		data.tIndex = 0
	end

	function list.luaRenderItem(button, index, data)
		data.state = data.hasGet and 1 or 0

		LuaUIUtils.renderRewardItem(button, data)

		local curStage = data.rewardIdx
		local dotPath = string.format(RedDotConst.RedDotPath.FUNC_MENU_MAP_COLLECTION_REWARD_ITEM, smallAreaId, curStage * 100 + index)

		RedDotUtils.setPreViewRedDot(dotPath, button, function()
			local areaUnlocked = pg.game.map:isPetAreaRewardUnlocked(smallAreaId)
			local stillCanGet = pg.me.badgeUnlockInfoMap[configData["badge" .. curStage]] ~= nil
			local stillHasGet = MapUtils.getBlockRewardStatus(smallAreaId, curStage)

			if areaUnlocked and stillCanGet and not stillHasGet then
				return RedDotConst.RedDotStyle.REWARD
			end

			return RedDotConst.RedDotStyle.NONE
		end)
	end

	list:SetList(drops)
end

function MapUtils.isPartyStart(areaId)
	local function isInTimeRange(sec, startSec, endSec)
		if startSec < endSec then
			return startSec <= sec and sec < endSec
		end

		return startSec <= sec or sec < endSec
	end

	local SocialPartyData = require("Data.social_party_data")
	local zoneCfg = SocialPartyData[areaId]

	if not zoneCfg then
		return nil
	end

	local now = Time.secondCache
	local todaySec = now - TimeUtils.getAreaDayBegin(now)

	for _, seg in ipairs(zoneCfg) do
		local startSec = Utils.getConfigTimeOfArea(seg, "startTime")
		local endSec = Utils.getConfigTimeOfArea(seg, "endTime")

		if startSec and endSec and isInTimeRange(todaySec, startSec, endSec) then
			return true
		end
	end

	return false
end

return MapUtils
