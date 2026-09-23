-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeCar\\HomeCarSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local HomeCarEditor = require("GameApp.Home.HomeCar.HomeCarEditor")
local HomeCameraGroupMode = require("GameApp.Camera.CameraMode.HomeCamera.HomeCameraGroupMode")
local HomeCarGroup = require("GameApp.Home.HomeCar.HomeCarGroup")
local ClientConst = require("Const.ClientConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampData = require("Data.home_camp_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneSeamlessData = require("Data.scene_seamless_data")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local HomelandConfigData = require("Data.homeland_config_data")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCarSystem")
local HomeCarSystem = Class.LightClass("HomeCarSystem", SystemBase)

HomeCarSystem.HOME_CAMP_SNAPSHOT_INTERVAL = 900
HomeCarSystem.HOME_CAMP_SNAPSHOT_UPLOAD_TIME_BUFFER = 20
HomeCarSystem.HOME_CAMP_SNAPSHOT_RETRY_INTERVAL = 5
HomeCarSystem.HOME_CAMP_SNAPSHOT_EDITOR_READY_DELAY = 2
HomeCarSystem.HOME_CAMP_SNAPSHOT_CAPTURE_TIMEOUT = 5
HomeCarSystem.HOME_CAMP_SNAPSHOT_MIN_ORNAMENT_COUNT = 2

function HomeCarSystem:getMessageBindMap()
	return {
		[MessageName.ON_MULTISELECT_ENT_DESTROY] = "onMutiSelectEntityDestroy"
	}
end

function HomeCarSystem:onCtor(name)
	HomeCarSystem.super.onCtor(self, name)

	self.editor = HomeCarEditor.new()
	self.homeCarCamps = {}
	self.homeCarGroups = {}
	self.worldCampInfo = {}
	self.uidToPosInfo = {}
	self.curWorldCampId = nil
	self.loadVirtualCampDistanceSqr = 3600
	self.unloadVirtualCampDistanceSqr = 4900
	self.loadVirtualCampDiff = self.unloadVirtualCampDistanceSqr - self.loadVirtualCampDistanceSqr
	self._homeCarUpgradeNoticeScheduled = false
	self.homeCampSnapshotScheduleCarGroup = nil
	self.nextHomeCampSnapshotTime = nil
	self.homeCampSnapshotEditorReadyTime = nil
	self.homeCampSnapshotRequest = nil
	self.homeCampSnapshotCaptureDeadline = nil
	self.homeCampSnapshotLocalReferenceTs = nil
end

function HomeCarSystem:onInit()
	self:initHomeCampData()
end

function HomeCarSystem:onClear()
	self._homeCarUpgradeNoticeScheduled = false

	self:stopHomeCampSnapshotSchedule()

	self.homeCampSnapshotLocalReferenceTs = nil

	self.editor:clear()
	self:destroyAllHomeCarGroup()
end

function HomeCarSystem:setWorldCampInfo(worldCampInfo)
	self.worldCampInfo = worldCampInfo
	self.worldCampDataReady = true
	self.curWorldCampId = -1

	self:tickWorldCamps()
end

function HomeCarSystem:onTick()
	if pg.me and pg.me.space then
		if Utils.isHomeCamp(pg.me.space.spaceType) then
			self.editor:tickEditor()
			self:checkAndRefreshShadows()
		end

		self:tickWorldCamps()
	end

	self:updateHomeCampSnapshotSchedule(Time.realSecondCache)
end

function HomeCarSystem:getHomeCampSnapshotInterval()
	local configInterval = tonumber(HomelandConfigData.homecampSnapshotUploadInterval)

	if configInterval and configInterval > 0 then
		return configInterval
	end

	return HomeCarSystem.HOME_CAMP_SNAPSHOT_INTERVAL
end

function HomeCarSystem:getNextHomeCampSnapshotTime(now)
	now = now or Time.realSecondCache

	local interval = self:getHomeCampSnapshotInterval()
	local serverUploadTs = tonumber(pg.me and pg.me.lastHomeCampSnapshotUploadTs) or 0
	local localReferenceTs = tonumber(self.homeCampSnapshotLocalReferenceTs) or 0
	local lastUploadTs = math.max(serverUploadTs, localReferenceTs)

	if lastUploadTs <= 0 then
		return now
	end

	local nextUploadTs = lastUploadTs + interval + HomeCarSystem.HOME_CAMP_SNAPSHOT_UPLOAD_TIME_BUFFER

	return now + math.max(0, nextUploadTs - Time.secondCache)
end

function HomeCarSystem:startHomeCampSnapshotSchedule(carGroup)
	if not self:isHomeCampSnapshotCarGroupValid(carGroup) then
		return
	end

	if self.homeCampSnapshotScheduleCarGroup == carGroup and self.nextHomeCampSnapshotTime then
		self.homeCampSnapshotEditorReadyTime = nil

		return
	end

	self:stopHomeCampSnapshotSchedule()

	self.homeCampSnapshotScheduleCarGroup = carGroup
	self.nextHomeCampSnapshotTime = self:getNextHomeCampSnapshotTime(Time.realSecondCache)
end

function HomeCarSystem:stopHomeCampSnapshotSchedule(carGroup)
	if carGroup and self.homeCampSnapshotScheduleCarGroup ~= carGroup then
		return
	end

	self.homeCampSnapshotScheduleCarGroup = nil
	self.nextHomeCampSnapshotTime = nil
	self.homeCampSnapshotEditorReadyTime = nil

	self:cancelHomeCampSnapshotCapture()
end

function HomeCarSystem:isHomeCampSnapshotCarGroupValid(carGroup)
	local player = pg.me
	local space = player and player.space

	if not player or not space or not Utils.isHomeCamp(space.spaceType) then
		return false
	end

	return carGroup and carGroup.playerUID == player.uid and carGroup.campCarEnt ~= nil and self:getHomeCarGroup(player.uid) == carGroup
end

function HomeCarSystem:isHomeCampSnapshotEditorVisible()
	local ui = pg.global and pg.global.ui
	local editorCtrl = ui and ui.homelandEditor

	return editorCtrl and editorCtrl:getUIVisible()
end

function HomeCarSystem:updateHomeCampSnapshotEditorReadyTime(now)
	if not self:isHomeCampSnapshotEditorVisible() then
		self.homeCampSnapshotEditorReadyTime = nil

		return false
	end

	if not self.homeCampSnapshotEditorReadyTime then
		self.homeCampSnapshotEditorReadyTime = now + HomeCarSystem.HOME_CAMP_SNAPSHOT_EDITOR_READY_DELAY
	end

	return now >= self.homeCampSnapshotEditorReadyTime
end

function HomeCarSystem:canCaptureHomeCampSnapshot(carGroup)
	if not self:isHomeCampSnapshotCarGroupValid(carGroup) or not self:isHomeCampSnapshotEditorVisible() or HomeLandUtils.getCarGroupOrnamentCount() < HomeCarSystem.HOME_CAMP_SNAPSHOT_MIN_ORNAMENT_COUNT then
		return false
	end

	return pg.me.addPhotoImgSprite and pg.global and pg.global.mobileCameraMgr
end

function HomeCarSystem:updateHomeCampSnapshotSchedule(now)
	local carGroup = self.homeCampSnapshotScheduleCarGroup

	if not carGroup then
		return
	end

	if not self:isHomeCampSnapshotCarGroupValid(carGroup) then
		self:stopHomeCampSnapshotSchedule(carGroup)

		return
	end

	self:updateHomeCampSnapshotCapture(now)

	if self.homeCampSnapshotRequest then
		return
	end

	local editorReady = self:updateHomeCampSnapshotEditorReadyTime(now)

	if not self.nextHomeCampSnapshotTime or now < self.nextHomeCampSnapshotTime then
		return
	end

	if not editorReady then
		return
	end

	if not self:canCaptureHomeCampSnapshot(carGroup) then
		self.nextHomeCampSnapshotTime = now + HomeCarSystem.HOME_CAMP_SNAPSHOT_RETRY_INTERVAL

		return
	end

	self:captureHomeCampSnapshot(carGroup, Time.realSecondCache)
end

function HomeCarSystem:captureHomeCampSnapshot(carGroup, now)
	local request = {
		carGroup = carGroup
	}

	self.homeCampSnapshotRequest = request
	self.homeCampSnapshotCaptureDeadline = now + HomeCarSystem.HOME_CAMP_SNAPSHOT_CAPTURE_TIMEOUT
	self.nextHomeCampSnapshotTime = now + self:getHomeCampSnapshotInterval() + HomeCarSystem.HOME_CAMP_SNAPSHOT_UPLOAD_TIME_BUFFER

	pg.global.mobileCameraMgr:CaptureScreenDelaySaveCopy(function(sprite)
		self:onHomeCampSnapshotCaptured(request, sprite)
	end)
end

function HomeCarSystem:updateHomeCampSnapshotCapture(now)
	local request = self.homeCampSnapshotRequest

	if not request then
		return
	end

	if not self:isHomeCampSnapshotCarGroupValid(request.carGroup) then
		self:cancelHomeCampSnapshotCapture()

		return
	end

	if self.homeCampSnapshotCaptureDeadline and now >= self.homeCampSnapshotCaptureDeadline then
		self:cancelHomeCampSnapshotCapture()

		self.nextHomeCampSnapshotTime = now + HomeCarSystem.HOME_CAMP_SNAPSHOT_RETRY_INTERVAL

		logger:warn("home camp auto review screenshot timed out")
	end
end

function HomeCarSystem:cancelHomeCampSnapshotCapture()
	self.homeCampSnapshotCaptureDeadline = nil
	self.homeCampSnapshotRequest = nil
end

function HomeCarSystem:isHomeCampSnapshotContextValid(request)
	return request == self.homeCampSnapshotRequest and self:isHomeCampSnapshotCarGroupValid(request.carGroup)
end

function HomeCarSystem:destroyHomeCampSnapshotSprite(sprite)
	local cameraMgr = pg.global and pg.global.mobileCameraMgr

	if sprite and not IsNil(sprite) and cameraMgr then
		cameraMgr:DestroySpriteTexture(sprite)
	end
end

function HomeCarSystem:onHomeCampSnapshotCaptured(request, sprite)
	if request == self.homeCampSnapshotRequest then
		self.homeCampSnapshotCaptureDeadline = nil
	end

	if not self:isHomeCampSnapshotContextValid(request) then
		self:destroyHomeCampSnapshotSprite(sprite)

		if request == self.homeCampSnapshotRequest then
			self:cancelHomeCampSnapshotCapture()
		end

		return
	end

	if not sprite or IsNil(sprite) then
		self.homeCampSnapshotRequest = nil
		self.nextHomeCampSnapshotTime = Time.realSecondCache + HomeCarSystem.HOME_CAMP_SNAPSHOT_RETRY_INTERVAL

		logger:warn("home camp auto review screenshot failed")

		return
	end

	pg.me:addPhotoImgSprite(sprite, function(_, success, imgUrl)
		self:onHomeCampSnapshotUploaded(request, sprite, success, imgUrl)
	end)
end

function HomeCarSystem:onHomeCampSnapshotUploaded(request, sprite, success, imgUrl)
	self:destroyHomeCampSnapshotSprite(sprite)

	if not self:isHomeCampSnapshotContextValid(request) then
		if request == self.homeCampSnapshotRequest then
			self:cancelHomeCampSnapshotCapture()
		end

		return
	end

	self.homeCampSnapshotRequest = nil

	if not success or string.isNilOrEmpty(imgUrl) then
		self.nextHomeCampSnapshotTime = Time.realSecondCache + HomeCarSystem.HOME_CAMP_SNAPSHOT_RETRY_INTERVAL

		logger:warn("home camp auto review screenshot upload failed")

		return
	end

	self.homeCampSnapshotLocalReferenceTs = Time.secondCache
	self.nextHomeCampSnapshotTime = self:getNextHomeCampSnapshotTime(Time.realSecondCache)

	pg.me:serverMsg("RPC_CS_SubmitHomeCampSnapshot", imgUrl)
end

function HomeCarSystem:refreshShadows()
	self.needRefreshShadow = true
end

function HomeCarSystem:checkAndRefreshShadows()
	if self.needRefreshShadow then
		self.needRefreshShadow = false

		pg.global.gameMgr:ForceRefreshShadows()
	end
end

function HomeCarSystem:onSceneLoaded(sceneId, sceneName)
	local space = pg.me and pg.me.space

	if space == nil then
		return
	end

	if not self._homeCarUpgradeNoticeScheduled and pg.me then
		self._homeCarUpgradeNoticeScheduled = true

		pg.me:tryNotifyHomeCarUpgradeFinished()
	end

	for _, homeCarGroup in pairs(self.homeCarGroups) do
		homeCarGroup:enterSpaceEntities(space)
	end
end

function HomeCarSystem:onSpaceDestroy(space)
	for _, homeCarGroup in pairs(self.homeCarGroups) do
		homeCarGroup:leaveSpaceEntities(space)
	end
end

function HomeCarSystem:initHomeCampData()
	self.campSceneDict = {}

	for campId, campInfo in pairs(HomeCampData) do
		local sceneId = campInfo.sceneId
		local mainSceneId = SceneUtils.getMainSceneId(sceneId)

		self.campSceneDict[mainSceneId] = self.campSceneDict[mainSceneId] or {}

		local seamlessData = ((SceneSeamlessData[mainSceneId] or EMPTY_TABLE).seamlessGroup or EMPTY_TABLE)[sceneId]

		if seamlessData then
			local areaId = (seamlessData.seamlessRange or EMPTY_TABLE)[1]

			if areaId then
				local areaData = SceneUtils.getSceneAreaData(mainSceneId)[areaId]

				if areaData then
					local position = areaData.position

					self.campSceneDict[mainSceneId][campId] = Vector3(position[1], position[2], position[3])
				end
			end
		end
	end
end

function HomeCarSystem:getCurWorldCampId(curWorldCampId)
	local space = pg.space

	if space == nil then
		return nil
	end

	local mainSceneId = SceneUtils.getMainSceneId(pg.space.sceneId)
	local sceneCampDict = self.campSceneDict[mainSceneId]

	if not sceneCampDict then
		return nil
	end

	local resultCampId
	local resultDistance = self.loadVirtualCampDistanceSqr

	for campId, campPos in pairs(sceneCampDict) do
		local sqrDistance = Vector3.HoriSqrDistance(campPos, pg.me:getPosition())

		if curWorldCampId == campId then
			sqrDistance = sqrDistance - self.loadVirtualCampDiff
		end

		if sqrDistance < resultDistance then
			resultCampId = campId
			resultDistance = sqrDistance
		end
	end

	return resultCampId
end

function HomeCarSystem:tickWorldCamps()
	local curWorldCampId = self:getCurWorldCampId(self.curWorldCampId)

	if curWorldCampId ~= self.curWorldCampId then
		self.curWorldCampId = curWorldCampId

		if self.curWorldCampId then
			local campInfo = self.worldCampInfo[self.curWorldCampId]
			local homeCampData = HomeCampData[self.curWorldCampId]

			if homeCampData and campInfo then
				for _, carId in ipairs(homeCampData.carId) do
					local carData = campInfo.carList[carId]

					if carData then
						local carGroup = self:getOrCreateHomeCarGroup(self.curWorldCampId, carId, carData.playerUid, ClientConst.HomeCarGroupCreateType.Virtual)

						if carGroup then
							carGroup:setLightCampData(carData.homeBasicInfo)
						end
					else
						local carGroup = self:getHomeCarGroupByPos(curWorldCampId, carId)

						if carGroup then
							carGroup:setLightCampData(nil)
						end
					end
				end
			end
		end
	end

	for uid, homeCarGroup in pairs(self.homeCarGroups) do
		local valid = homeCarGroup:tickHomeCarGroup()

		if not valid then
			self:destroyHomeCarGroup(uid)
		end
	end
end

function HomeCarSystem:getHomeCarGroup(homeCarId)
	return self.homeCarGroups[homeCarId]
end

function HomeCarSystem:setEditorTargetGroup(playerUID)
	local homeCarGroup = self.homeCarGroups[playerUID]

	if not self.homeCarGroups[playerUID] then
		return
	end

	self.editor:setTargetCarGroup(homeCarGroup)
end

function HomeCarSystem:checkEnableHomeCarManagement()
	return pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.HOMECAR_MANAGEMENT)
end

function HomeCarSystem:getOrCreateHomeCarGroup(staticId, carPlaceId, playerUID, type)
	type = type or ClientConst.HomeCarGroupCreateType.Virtual

	local placeInfo = self.uidToPosInfo[playerUID]

	if placeInfo and (placeInfo.staticId ~= staticId or placeInfo.carPlaceId ~= carPlaceId) then
		local homeCarGroup = self:getHomeCarGroup(playerUID)

		if homeCarGroup then
			if homeCarGroup:isVirtualCampCar() or type == ClientConst.HomeCarGroupCreateType.Camp then
				self:destroyHomeCarGroup(playerUID)
			else
				return nil
			end
		end
	end

	local campInfo = self.homeCarCamps[staticId]

	if not campInfo then
		campInfo = {}
		self.homeCarCamps[staticId] = campInfo
	end

	local homeCarGroup = campInfo[carPlaceId]

	if homeCarGroup and homeCarGroup.playerUID ~= playerUID then
		if homeCarGroup:isVirtualCampCar() or type == ClientConst.HomeCarGroupCreateType.Camp then
			self:destroyHomeCarGroup(homeCarGroup.playerUID)

			homeCarGroup = nil
		else
			return nil
		end
	end

	if not homeCarGroup then
		homeCarGroup = HomeCarGroup(playerUID, staticId, carPlaceId)
		self.homeCarGroups[playerUID] = homeCarGroup
		campInfo[carPlaceId] = homeCarGroup
		self.uidToPosInfo[playerUID] = {
			staticId = staticId,
			carPlaceId = carPlaceId
		}
	end

	return homeCarGroup
end

function HomeCarSystem:getHomeCarGroupByPos(staticId, carPlaceId)
	return (self.homeCarCamps[staticId] or EMPTY_TABLE)[carPlaceId]
end

function HomeCarSystem:destroyHomeCarGroup(playerUID)
	local homeCarGroup = self.homeCarGroups[playerUID]

	if homeCarGroup then
		homeCarGroup:destroy()

		local placeInfo = self.uidToPosInfo[playerUID]

		if placeInfo then
			(self.homeCarCamps[placeInfo.staticId] or {})[placeInfo.carPlaceId] = nil
		end
	end

	self.homeCarGroups[playerUID] = nil
end

function HomeCarSystem:onMutiSelectEntityDestroy()
	self.editor:onMutiSelectEntityDestroy()
end

function HomeCarSystem:destroyAllHomeCarGroup()
	for k, v in pairs(self.homeCarGroups) do
		v:destroy()
	end

	self.homeCarGroups = {}
	self.homeCarCamps = {}
	self.uidToPosInfo = {}
	self.worldCampInfo = {}
	self.curWorldCampId = nil
end

return HomeCarSystem
