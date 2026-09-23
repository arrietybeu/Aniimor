-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\GrabEgg\\GrabEggSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local RobEggBorn = require("Data.rob_egg_born_data")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local SysConfigData = require("Data.sys_config_data")
local MapHelper = require("GameApp.Map.MapHelper")
local EventConst = require("Const.EventConst")
local RobEggConst = require("Common.Const.RobEggConst")
local DiGongConfData = require("Data.digong_config_data")
local NavMeshServiceUtils = require("Common.Utils.NavMeshServiceUtils")
local AiConst = require("Common.Const.AiConst")
local Vector3 = CS.UnityEngine.Vector3
local GrabEggSystem = Class.LightClass("GrabEggSystem", SystemBase)
local END_TIME_TIPS = SysConfigData.GRABEGG_REMAIN_EXTRACT_TIME or {}
local END_TIME_TIP_AUDIO = "SFX_UI_Grabegg_Remain_Extract_Time"
local NORMAL_GUIDE_SCENE_ID = Const.ROB_EGG_SCENE_CLIP_ID
local GUIDE_NAV_RETRY_INTERVAL = 0.5
local GUIDE_NAV_MAX_RETRY_COUNT = 20
local GUIDE_GO_TO_DUNGEON_TIP_KEY = "GRAB_EGG_GUIDANCE"
local GUIDE_GO_TO_DUNGEON_TIP_STATE = 8
local PLAYER_NAV_MARK_TYPES = {
	[Const.MAP_MARK_CUSTOM] = true,
	[Const.MAP_MARK_COUSTOM_TRACE] = true,
	[Const.MAP_MARK_FAST_TARGET] = true
}

local function appendDoorMarkIds(result, doorConfig)
	for _, markIds in pairs(doorConfig or EMPTY_TABLE) do
		for _, markId in ipairs(markIds or EMPTY_TABLE) do
			result[#result + 1] = markId
		end
	end
end

function GrabEggSystem:onCtor()
	self.bindMapTags = {}
	self.eggSyncData = {}
	self.dynamicMarkSyncData = {}
	self.dynamicMarkEntityIds = {}
	self.endTimeTips = {}
	self.virtualPlayerEntity = nil
	self.rankInfo = nil
	self.rankResult = nil
	self.rankDifficulty = nil
	self.normalGuideLoadedSceneId = nil
	self.normalGuidePendingShipParam = nil
end

function GrabEggSystem:isNormalGuideEnabled(guideParam)
	if not pg.me or not pg.space or not pg.space:isGrabEgg() then
		return false
	end

	local masterSceneId = pg.space.masterDungeonSceneId or pg.space.sceneId

	if guideParam and guideParam.isNormalGuide then
		return masterSceneId == NORMAL_GUIDE_SCENE_ID
	end

	local hardLv = pg.space.hardLv or pg.me:getDungeonHardLv()

	return masterSceneId == NORMAL_GUIDE_SCENE_ID and hardLv == Const.DungeonDifficultLevel.NORMAL
end

function GrabEggSystem:isNormalGuideSceneMatched(guideEvent)
	if guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GooutDG then
		return pg.space.spaceType == Const.SPACE_TYPE_ROBEGG_UNDERGROUND
	end

	return pg.space.sceneId == NORMAL_GUIDE_SCENE_ID
end

function GrabEggSystem:showGoToDungeonGuideTip()
	if not pg.global or not pg.global.ui or not pg.global.ui.tips then
		return
	end

	pg.global.ui.tips:showIconTextTip(pg.getGameString(GUIDE_GO_TO_DUNGEON_TIP_KEY), 5, GUIDE_GO_TO_DUNGEON_TIP_STATE)
end

function GrabEggSystem:getTrackableGuideMark(markId)
	local map = pg.game and pg.game.map

	if not map or not pg.space then
		return
	end

	local markInfo = map:getMarkInfo(markId)

	if not markInfo or not markInfo.markPosition then
		return
	end

	local sceneId = map.mainSceneId or map:convertSceneId(pg.space.sceneId)
	local markStatus = map:getMarkStatus(markId, markInfo.markType, sceneId)

	if markStatus ~= Const.MAP_MARK_STATUS_UNLOCKED then
		return
	end

	local position = map:GetCurrentBindMapMarkPosOriginal(markId) or markInfo.markPosition

	return markInfo, position
end

function GrabEggSystem:findClosestTrackableGuideMark(markIds)
	local pawn = pg.pawn or pg.me

	if not pawn or not pawn.getPosition then
		return
	end

	local playerPosition = pawn:getPosition()
	local closestMarkId
	local closestDistance = math.huge
	local checked = {}

	for _, markId in ipairs(markIds or EMPTY_TABLE) do
		if not checked[markId] then
			checked[markId] = true

			local _, markPosition = self:getTrackableGuideMark(markId)

			if markPosition then
				local distance = Vector3.SqrDistance(playerPosition, markPosition)

				if distance < closestDistance then
					closestDistance = distance
					closestMarkId = markId
				end
			end
		end
	end

	return closestMarkId
end

function GrabEggSystem:getSelfTeamAreaId()
	local teamInfo = pg.space and pg.space.teamInfo
	local idToTeam = teamInfo and teamInfo.id_to_team
	local teams = teamInfo and teamInfo.teams
	local teamId = idToTeam and idToTeam[pg.me.uid]
	local team = teams and teams[teamId]
	local bornData = RobEggBorn[NORMAL_GUIDE_SCENE_ID]

	return bornData and bornData.areaIndex and team and bornData.areaIndex[team.bornSpawnerId]
end

function GrabEggSystem:findMainDungeonDoorMark()
	local bornData = RobEggBorn[NORMAL_GUIDE_SCENE_ID]

	if not bornData then
		return
	end

	local areaId = self:getSelfTeamAreaId()
	local mainDoorMarks = areaId and bornData.entrance and bornData.entrance[areaId]
	local markId = self:findClosestTrackableGuideMark(mainDoorMarks)

	if markId then
		return markId
	end

	local allMainDoorMarks = {}

	appendDoorMarkIds(allMainDoorMarks, bornData.entrance)

	markId = self:findClosestTrackableGuideMark(allMainDoorMarks)

	if markId then
		return markId
	end

	appendDoorMarkIds(allMainDoorMarks, bornData.exit)

	return self:findClosestTrackableGuideMark(allMainDoorMarks)
end

function GrabEggSystem:findClosestDungeonExitMark()
	local dungeonConfig = pg.space and DiGongConfData[pg.space.sceneId]

	if not dungeonConfig then
		return
	end

	local doorMarks = {}

	appendDoorMarkIds(doorMarks, dungeonConfig.entrance)
	appendDoorMarkIds(doorMarks, dungeonConfig.exit)

	return self:findClosestTrackableGuideMark(doorMarks)
end

function GrabEggSystem:getTrackedPlayerNavigationMarkIds(sceneId, targetMarkId, miniMap)
	local markIds = {}
	local checked = {}

	for markId, trackInfo in pairs(pg.game.map.trackMarksRecord or EMPTY_TABLE) do
		if markId ~= targetMarkId and trackInfo.sceneId == sceneId and PLAYER_NAV_MARK_TYPES[trackInfo.markType] then
			checked[markId] = true
			markIds[#markIds + 1] = markId
		end
	end

	for markId, pool in pairs(miniMap and miniMap._markerPoolMap or EMPTY_TABLE) do
		if markId ~= targetMarkId and not checked[markId] and pool.trackMode and PLAYER_NAV_MARK_TYPES[pool.markType] then
			markIds[#markIds + 1] = markId
		end
	end

	return markIds
end

function GrabEggSystem:cancelPlayerNavigationMarks(markIds)
	for _, markId in ipairs(markIds) do
		pg.game.map:manualUnTraceQuestMark(markId)
	end
end

function GrabEggSystem:trackGuideMark(markId, guidePosition)
	local map = pg.game and pg.game.map
	local markInfo = map and map:getMarkInfo(markId)

	if not map or not pg.space then
		return false
	end

	local markPosition

	if guidePosition then
		markPosition = Vector3(guidePosition[1], guidePosition[2], guidePosition[3])
	elseif markInfo then
		markPosition = map:GetCurrentBindMapMarkPosOriginal(markId) or markInfo.markPosition
	end

	if not markPosition then
		return false
	end

	local miniMap = map:GetMiniMapUI()
	local sceneId = map.mainSceneId or map:convertSceneId(pg.space.sceneId)
	local playerNavigationMarkIds = self:getTrackedPlayerNavigationMarkIds(sceneId, markId, miniMap)

	self:cancelPlayerNavigationMarks(playerNavigationMarkIds)

	if miniMap and miniMap._isOK and markInfo then
		map:manualTraceQuestMark(markInfo.markType, markId, true)

		if map.trackMarksRecord[markId] then
			return true
		end
	end

	if markInfo then
		map:storeTrackMarks(markId, sceneId, markInfo.markType, markPosition, markInfo.replaceIcon)
	end

	if pg.game.navEffect then
		pg.game.navEffect:path(pg.space.sceneId, markPosition, markId)

		return true
	end

	return false
end

function GrabEggSystem:getGuidePathDistance(path)
	local distance = 0

	for index = 2, #(path or {}) do
		local lastPosition = path[index - 1]
		local position = path[index]
		local deltaX = position[1] - lastPosition[1]
		local deltaY = position[2] - lastPosition[2]
		local deltaZ = position[3] - lastPosition[3]

		distance = distance + math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
	end

	return distance
end

function GrabEggSystem:tryNavigateReachableDungeonDoor(guideDoors)
	if self.normalGuideNavPathChecking then
		return false
	end

	local candidates = {}

	for _, door in ipairs(guideDoors or EMPTY_TABLE) do
		local position = door and door.position

		if door and door.markId and position then
			candidates[#candidates + 1] = door
		end
	end

	if #candidates == 0 or not pg.me or not pg.space or not pg.game or not pg.game.map then
		return false
	end

	local startPosition = pg.me:getPosition()
	local sceneId = pg.game.map:convertSceneId(pg.space.sceneId)
	local checkToken = (self.normalGuideNavPathCheckToken or 0) + 1

	self.normalGuideNavPathCheckToken = checkToken
	self.normalGuideNavPathChecking = true

	local pendingCount = #candidates
	local closestReachableDoor
	local closestPathDistance = math.huge
	local closestPartialDoor
	local closestPartialPathDistance = math.huge

	for _, door in ipairs(candidates) do
		local candidate = door
		local position = candidate.position

		NavMeshServiceUtils.findPath(sceneId, {
			startPosition[1],
			startPosition[2],
			startPosition[3]
		}, {
			{
				position[1],
				position[2],
				position[3]
			}
		}, function(state, path)
			if self.normalGuideNavPathCheckToken ~= checkToken then
				return
			end

			if path and #path > 0 then
				local pathDistance = self:getGuidePathDistance(path)

				if state == AiConst.AUTO_PATH_REQ_STATE.Success and pathDistance < closestPathDistance then
					closestPathDistance = pathDistance
					closestReachableDoor = candidate
				elseif state == AiConst.AUTO_PATH_REQ_STATE.PartialSuccess and pathDistance < closestPartialPathDistance then
					closestPartialPathDistance = pathDistance
					closestPartialDoor = candidate
				end
			end

			pendingCount = pendingCount - 1

			if pendingCount > 0 then
				return
			end

			self.normalGuideNavPathChecking = false
			closestReachableDoor = closestReachableDoor or closestPartialDoor

			if closestReachableDoor and self:trackGuideMark(closestReachableDoor.markId, closestReachableDoor.position) then
				self:stopNormalGuideNavigation()
			end
		end)
	end

	return false
end

function GrabEggSystem:tryNavigateNormalGuide(guideEvent, guideParam)
	local markId, guidePosition

	if guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GoToDG then
		markId = guideParam and guideParam.guideMarkId
		guidePosition = guideParam and guideParam.guidePosition

		if not markId then
			markId = self:findMainDungeonDoorMark()
		end
	elseif guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GooutDG then
		if guideParam and guideParam.guideDoors and #guideParam.guideDoors > 0 then
			return self:tryNavigateReachableDungeonDoor(guideParam.guideDoors)
		end

		markId = guideParam and guideParam.guideMarkId
		guidePosition = guideParam and guideParam.guidePosition

		if not markId then
			markId = self:findClosestDungeonExitMark()
		end
	elseif guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GoToSubmitEgg then
		markId = guideParam and guideParam.guideMarkId
		guidePosition = guideParam and guideParam.guidePosition
	end

	return markId ~= nil and self:trackGuideMark(markId, guidePosition)
end

function GrabEggSystem:stopNormalGuideNavigation()
	if self.normalGuideNavTimer then
		self:killTimer(self.normalGuideNavTimer)

		self.normalGuideNavTimer = nil
	end

	self.normalGuideNavPathCheckToken = (self.normalGuideNavPathCheckToken or 0) + 1
	self.normalGuideNavPathChecking = false
	self.normalGuideNavEvent = nil
	self.normalGuideNavParam = nil
	self.normalGuideNavRetryCount = nil
end

function GrabEggSystem:startNormalGuideNavigation(guideEvent, guideParam)
	if not self:isNormalGuideEnabled(guideParam) then
		return
	end

	if guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GoToSubmitEgg and self.normalGuideLoadedSceneId ~= NORMAL_GUIDE_SCENE_ID then
		self.normalGuidePendingShipParam = guideParam

		return
	end

	if guideEvent == RobEggConst.ROBEGG_NEWER_GUIDE.GoToDG then
		self:showGoToDungeonGuideTip()
	end

	self:stopNormalGuideNavigation()

	if not self:isNormalGuideSceneMatched(guideEvent) then
		return
	end

	self.normalGuideNavEvent = guideEvent
	self.normalGuideNavParam = guideParam
	self.normalGuideNavRetryCount = 1

	if self:tryNavigateNormalGuide(guideEvent, guideParam) then
		self:stopNormalGuideNavigation()

		return
	end

	if not self.normalGuideNavEvent then
		return
	end

	self.normalGuideNavTimer = self:startTimer(function()
		local retryGuideEnabled = self:isNormalGuideEnabled(self.normalGuideNavParam)
		local retrySceneMatched = retryGuideEnabled and self:isNormalGuideSceneMatched(self.normalGuideNavEvent)

		if not retryGuideEnabled or not retrySceneMatched then
			self:stopNormalGuideNavigation()

			return
		end

		if self.normalGuideNavPathChecking then
			self.normalGuideNavRetryCount = self.normalGuideNavRetryCount + 1

			if self.normalGuideNavRetryCount >= GUIDE_NAV_MAX_RETRY_COUNT then
				self:stopNormalGuideNavigation()
			end

			return
		end

		self.normalGuideNavRetryCount = self.normalGuideNavRetryCount + 1

		if self:tryNavigateNormalGuide(self.normalGuideNavEvent, self.normalGuideNavParam) or self.normalGuideNavRetryCount >= GUIDE_NAV_MAX_RETRY_COUNT then
			self:stopNormalGuideNavigation()
		end
	end, GUIDE_NAV_RETRY_INTERVAL, true)
end

function GrabEggSystem:bindDynamicMapStatus(entityId, mapStaticId)
	self.bindMapTags[entityId] = mapStaticId

	pg.game.map:bindEntityPosToMapMark(mapStaticId, entityId)
end

function GrabEggSystem:syncEggDynamicMark(eggId, syncData)
	if not pg.space or not pg.space.isGrabEgg or not pg.space:isGrabEgg() then
		return
	end

	local configId = SysConfigData.GRABEGG_MARKER_INDEX[syncData.subType]

	if not configId or not DefaultMapMarkData[configId] then
		return
	end

	local pos = MapHelper.GetEntityPos(eggId) or syncData.position

	if not pos then
		return
	end

	local prev = self.eggSyncData[eggId]
	local isNew = prev == nil
	local markMissing = pg.game.map.tempMarkPointData[eggId] == nil
	local renderChanged = isNew or markMissing or prev.controller ~= syncData.controller or prev.camp ~= syncData.camp or prev.tempCamp ~= syncData.tempCamp or prev.tempCampGroup ~= syncData.tempCampGroup
	local controllerChanged = not prev or prev.controller ~= syncData.controller

	self.eggSyncData[eggId] = syncData

	if renderChanged then
		local sceneId = pg.game.map:convertSceneId(pg.space.sceneId)

		pg.game.map:addOrUpdateTempMark(sceneId, pos[1], pos[2], pos[3], eggId, configId)
	end

	if isNew or markMissing then
		pg.game.map:bindEntityPosToMapMark(eggId, eggId)
	end

	if controllerChanged then
		pg.game.map:refreshAllyMarks()
	end
end

function GrabEggSystem:getEggSyncData(eggId)
	return self.eggSyncData[eggId]
end

function GrabEggSystem:getDynamicMarkSyncData(entityId)
	local markId = self.dynamicMarkEntityIds[entityId] or entityId

	return self.dynamicMarkSyncData[markId]
end

function GrabEggSystem:getSyncMarkConfigId(syncData)
	if not syncData then
		return nil
	end

	if syncData.markConfigId and DefaultMapMarkData[syncData.markConfigId] then
		return syncData.markConfigId
	end

	local syncMarkType = syncData.syncMarkType
	local configId = syncMarkType and RobEggConst.SYNC_MARK_CONFIG_ID[syncMarkType] or nil

	return configId
end

function GrabEggSystem:isSupportedDynamicMarkSyncData(syncData)
	return self:getSyncMarkConfigId(syncData) ~= nil
end

function GrabEggSystem:isGoldMonsterDynamicMarkSyncData(syncData)
	local configId = self:getSyncMarkConfigId(syncData)
	local configData = configId and DefaultMapMarkData[configId]

	return configData and configData.funcType == Const.MAP_MARK_GOLD_MONSTER
end

function GrabEggSystem:getDynamicMarkId(entityId, syncData)
	if self:isGoldMonsterDynamicMarkSyncData(syncData) and ToBool(syncData.markId) then
		return syncData.markId
	end

	return entityId
end

function GrabEggSystem:syncDynamicMark(entityId, syncData)
	if not pg.space or not pg.space.isGrabEgg or not pg.space:isGrabEgg() then
		return
	end

	local configId = self:getSyncMarkConfigId(syncData)

	if not configId or not DefaultMapMarkData[configId] then
		return
	end

	local pos = MapHelper.GetEntityPos(entityId) or syncData.position

	if not pos then
		return
	end

	local markId = self:getDynamicMarkId(entityId, syncData)
	local prev = self.dynamicMarkSyncData[markId]
	local isNew = prev == nil
	local markMissing = pg.game.map.tempMarkPointData[markId] == nil
	local renderChanged = isNew or markMissing or self:getSyncMarkConfigId(prev) ~= configId

	self.dynamicMarkSyncData[markId] = syncData
	self.dynamicMarkEntityIds[entityId] = markId

	if renderChanged then
		local sceneId = pg.game.map:convertSceneId(pg.space.sceneId)

		pg.game.map:addOrUpdateTempMark(sceneId, pos[1], pos[2], pos[3], markId, configId)
	end

	if isNew or markMissing then
		pg.game.map:bindEntityPosToMapMark(markId, entityId)
	end
end

function GrabEggSystem:isEntityControllingEgg(entityId)
	local ent = pg.getEntity(entityId)

	if ent and ent.isControllingEgg and ent:isControllingEgg() then
		return true
	end

	for _, syncData in pairs(self.eggSyncData) do
		if syncData.controller == entityId then
			return true
		end
	end

	return false
end

function GrabEggSystem:refreshEggDynamicMark(eggId)
	local syncData = self.eggSyncData[eggId]

	if not syncData then
		return
	end

	local configId = SysConfigData.GRABEGG_MARKER_INDEX[syncData.subType]

	if not configId then
		return
	end

	local pos = MapHelper.GetEntityPos(eggId)

	if not pos then
		return
	end

	local sceneId = pg.game.map:convertSceneId(pg.space and pg.space.sceneId)

	pg.game.map:addOrUpdateTempMark(sceneId, pos[1], pos[2], pos[3], eggId, configId)
end

function GrabEggSystem:clearDynamicMarkTrack(markId)
	if pg.game.map.trackMarksRecord and pg.game.map.trackMarksRecord[markId] then
		pg.game.map:unStoreTrackMarks(markId)
		pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_TRACE_REMOVE, markId)

		if pg.game.navEffect then
			pg.game.navEffect:unPath(markId, function()
				return
			end)
		end
	end
end

function GrabEggSystem:removeEggDynamicMark(eggId)
	local prev = self.eggSyncData[eggId]

	if not prev then
		return
	end

	local sceneId = pg.game.map:convertSceneId(pg.space and pg.space.sceneId)

	self:clearDynamicMarkTrack(eggId)
	pg.game.map:unbindEntityPosFromMapMark(eggId)
	pg.game.map:removeTempMark(sceneId, eggId)

	self.eggSyncData[eggId] = nil

	if ToBool(prev.controller) then
		pg.game.map:refreshAllyMarks()
	end
end

function GrabEggSystem:removeDynamicMark(entityId)
	local markId = self.dynamicMarkEntityIds[entityId] or entityId
	local syncData = self.dynamicMarkSyncData[markId]

	if not syncData then
		self.dynamicMarkEntityIds[entityId] = nil

		return
	end

	local sceneId = pg.game.map:convertSceneId(pg.space and pg.space.sceneId)
	local isSelfTracking = pg.game.map.trackMarksRecord and pg.game.map.trackMarksRecord[markId]

	if isSelfTracking and self:isGoldMonsterDynamicMarkSyncData(syncData) then
		pg.me:unTrackTeamMapMark(sceneId, 0, markId)
	end

	self:clearDynamicMarkTrack(markId)
	pg.game.map:unbindEntityPosFromMapMark(markId)
	pg.game.map:removeTempMark(sceneId, markId)

	self.dynamicMarkSyncData[markId] = nil
	self.dynamicMarkEntityIds[entityId] = nil
end

function GrabEggSystem:clearDynamicMarkLifecycleData()
	local markIds = {}

	for markId in pairs(self.dynamicMarkSyncData) do
		markIds[markId] = true
	end

	for _, markId in pairs(self.dynamicMarkEntityIds) do
		markIds[markId] = true
	end

	if pg.game and pg.game.map then
		for markId in pairs(markIds) do
			pg.game.map:unbindEntityPosFromMapMark(markId)
		end
	end

	table.clear(self.dynamicMarkSyncData)
	table.clear(self.dynamicMarkEntityIds)
end

function GrabEggSystem:onSceneLoaded(sceneId, sceneName)
	self.normalGuideLoadedSceneId = sceneId

	table.clear(self.eggSyncData)
	self:clearDynamicMarkLifecycleData()

	if not pg.space or not pg.space:isGrabEgg() then
		return
	end

	for entityId, staticId in pairs(self.bindMapTags) do
		pg.game.map:bindEntityPosToMapMark(staticId, entityId)
	end

	if sceneId == NORMAL_GUIDE_SCENE_ID and self.normalGuidePendingShipParam then
		local pendingShipParam = self.normalGuidePendingShipParam

		self.normalGuidePendingShipParam = nil

		self:startNormalGuideNavigation(RobEggConst.ROBEGG_NEWER_GUIDE.GoToSubmitEgg, pendingShipParam)
	end
end

function GrabEggSystem:onSceneUnloaded(sceneId, sceneName)
	if self.normalGuideLoadedSceneId == sceneId then
		self.normalGuideLoadedSceneId = nil
	end

	self:stopNormalGuideNavigation()
	self:clearDynamicMarkLifecycleData()

	if self.virtualPlayerEntity then
		ClientUtils.safeDestroy(self.virtualPlayerEntity)

		self.virtualPlayerEntity = nil
	end
end

function GrabEggSystem:tryStartEndTimeCountdown(endTime)
	if self.gameOverTimer then
		self:killTimer(self.gameOverTimer)
	end

	self.gameOverTimer = nil

	local finishedTips = true

	for i, _ in ipairs(END_TIME_TIPS) do
		if not self.endTimeTips[i] then
			finishedTips = false

			break
		end
	end

	if finishedTips then
		return
	end

	self.curEndTime = endTime or pg.me.space and pg.me.space.end_ts or Time.secondCache

	local endTimeMatchStr = pg.getGameString("GRAB_EGG_Remain_Extract_Time")

	self.gameOverTimer = self:startTimer(function()
		local finished = true

		for i, v in ipairs(END_TIME_TIPS) do
			if not self.endTimeTips[i] then
				finished = false

				if self.curEndTime - Time.secondCache <= v * 60 then
					self.endTimeTips[i] = true

					local desc = pg.getFormatText(endTimeMatchStr, v)
					local extractionTimePage = i == 1 and 0 or 1

					pg.global.ui.tips:showIconTextTip(desc, 5, 5, extractionTimePage)
					pg.game.audio:playEvent(END_TIME_TIP_AUDIO)
				end
			end
		end

		if finished then
			self:killTimer(self.gameOverTimer)

			self.gameOverTimer = nil
		end
	end, 1, true)
end

function GrabEggSystem:clearGrabEggDungeonData()
	self:stopNormalGuideNavigation()

	self.normalGuideLoadedSceneId = nil
	self.normalGuidePendingShipParam = nil

	self:killAllTimer()

	self.gameOverTimer = nil

	for _, staticId in pairs(self.bindMapTags) do
		pg.game.map:unbindEntityPosFromMapMark(staticId)
	end

	table.clear(self.bindMapTags)

	local dungeonSceneId = pg.game.map:convertSceneId(pg.me:getDungeonSceneId())

	for eggId in pairs(self.eggSyncData) do
		pg.game.map:unbindEntityPosFromMapMark(eggId)
		pg.game.map:removeTempMark(dungeonSceneId, eggId)
	end

	table.clear(self.eggSyncData)

	for markId in pairs(self.dynamicMarkSyncData) do
		pg.game.map:removeTempMark(dungeonSceneId, markId)
	end

	self:clearDynamicMarkLifecycleData()
	table.clear(self.endTimeTips)
	self:clearRelatedTrackMarks()
end

function GrabEggSystem:clearRelatedTrackMarks()
	local dungeonSceneId = pg.me:getDungeonSceneId()

	pg.game.map:unStoreAllSceneRelatedTrackMarks(dungeonSceneId)

	local cData = RobEggBorn[dungeonSceneId]

	if cData == nil then
		return
	end

	local hardLv = pg.me:getDungeonHardLv()
	local dgList = cData.DungeonList[hardLv] or {}

	for _, sceneId in ipairs(dgList) do
		pg.game.map:unStoreAllSceneRelatedTrackMarks(sceneId)
	end
end

function GrabEggSystem:tryInvokeSettlement()
	local rankInfo = self.rankInfo
	local rankResult = self.rankResult
	local rankDifficulty = self.rankDifficulty

	self.rankInfo = nil
	self.rankResult = nil
	self.rankDifficulty = nil

	if rankInfo then
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SETTLEMENT_RANK, {
			rankInfo = rankInfo,
			result = rankResult,
			difficulty = rankDifficulty
		})
	end
end

function GrabEggSystem:markSettlement(info, result, difficulty)
	self.rankInfo = info
	self.rankResult = result
	self.rankDifficulty = tonumber(difficulty)
end

function GrabEggSystem:createVirtualPlayer()
	if self.virtualPlayerEntity then
		return
	end

	local entity = ClientSimpleVirtualPlayer.new()
	local initDict = {
		copyEntity = pg.me
	}

	entity:init(initDict)
	entity:postInit(initDict)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)
	ClientUtils.onClientEntityCreated(entity)
	entity.eModel:SetTransformPosition(0, -1000, 0)
	entity:setActive(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, false)

	self.virtualPlayerEntity = entity
end

function GrabEggSystem:getVirtualPlayerEntity()
	return self.virtualPlayerEntity
end

return GrabEggSystem
