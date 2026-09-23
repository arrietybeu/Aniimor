-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local HomeEntityEditor = require("GameApp.Home.HomeEntityEditor")
local HomeCameraGroupMode = require("GameApp.Camera.CameraMode.HomeCamera.HomeCameraGroupMode")
local HomeCameraMode = require("GameApp.Camera.CameraMode.HomeCamera.HomeCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local HomelandConfigData = require("Data.homeland_config_data")
local Utils = require("Common.Utils.Utils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AddressDataConst = require("Const.AddressDataConst")
local EffectConst = require("Const.EffectConst")
local ListPool = require("Common.Container.ListPool")
local Time = require("Core.Common.Time")
local HomelandFastFindMap = require("Common.Homeland.HomelandFastFindMap")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLightShadowScheduler = require("GameApp.Home.HomeLightShadowScheduler")
local NoticeDef = require("Common.NoticeDef")
local SceneData = require("Data.scene_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomelandDemoCmdImplement = require("GameApp.CmdSocket.HomelandDemoCmdImplement")
local HomelandAreaData = require("Data.homeland_area_data")
local CommonSwitch = require("Common.CommonSwitch")
local UIConst = require("Const.UIConst")
local logger = require("Core.Log.LoggerManager").getLogger("HomeSystem")
local Quaternion = Quaternion
local HomeSystem = Class.LightClass("HomeSystem", SystemBase)

HomeSystem.WORLD_FURNITURE_CLASS_NAMES = {
	ClientSpaceFurniture = true,
	ClientSpaceFurnitureVehicle = true
}
HomeSystem.WORLD_FURNITURE_PHYSX_COMPONENT = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
HomeSystem.WORLD_FURNITURE_PLACE_CHECK_GROUND_GAP = 0.05
HomeSystem.HOMELAND_SNAPSHOT_INTERVAL = 900
HomeSystem.HOMELAND_SNAPSHOT_UPLOAD_TIME_BUFFER = 20
HomeSystem.HOMELAND_SNAPSHOT_RETRY_INTERVAL = 5
HomeSystem.HOMELAND_SNAPSHOT_CAPTURE_TIMEOUT = 5
HomeSystem.LOCK_ZONE_AREA_ID = 0
HomeSystem.NEAREST_AREA_PRIORITY_RANGE_EXTEND = 10
HomeSystem.ZONE_POSITION_EPSILON = 0.01
HomeSystem.ZONE_UNLOCK_EFFECT = "Eff_Env_Home_KeyItem_AirwallUnlock"
HomeSystem.ZONE_LOCK_EFFECT_HEIGHT = 0.35
HomeSystem.ZONE_LOCK_LABEL_TEXT_KEY = "HOMELAND_ITEM_LOCKED"
HomeSystem.AREA_LOCK_TIP_MAX_DISTANCE = 30

function HomeSystem:getMessageBindMap()
	return {
		[MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED] = "onHomelandFacilityAllocateChanged",
		[MessageName.ON_PLAYER_ENTER_SPACE] = "onPlayerEnterSpace",
		[MessageName.ON_MULTISELECT_ENT_DESTROY] = "onMutiSelectEntityDestroy"
	}
end

function HomeSystem:onCtor(name)
	HomeSystem.super.onCtor(self, name)

	self.fastFindMapDict = {}
	self.ornamentAreaIdDict = {}
	self.tempCollideResult = {}
	self.tempFloorLiftResult = {}
	self.editor = HomeEntityEditor.new()
	self.enableDebugInfo = {}
	self.homeEntities = {}
	self.virtualHomeEntities = {}
	self.lockZones = {}
	self.lockZoneLoadVersion = 0
	self.zoneLockEffects = {}
	self.zoneLockEffectAreaId = nil
	self.areaAirWalls = {}
	self.areaAirWallLoadVersion = 0
	self.zoneWidth = Const.HomelandZoneWidth
	self.zoneHeight = Const.HomelandZoneHeight
	self.entEffectInfo = {}
	self.lastPlayerAllocation = {}
	self.virtualOrnamentId = 0
	self.virtualOrnaments = {}
	self.ornamentFilterInfo = {}

	self:intAreaBaseInfo()
	self:updateEffectVisibleInfo()

	self.curLoginShowConfirmHint = true
	self.curLoginPlaceShowConfirmHint = true
	self.curLoginShowOrderPayRefreshHint = true
	self.curLoginShowElectricModeHint = true
	self.curDelFacilityConfirmHint = true
	self.curLoginShowPetHint = true
	self.curLoginShowMultiSelectClearHint = true
	self.syncWorkEffectFacilities = {}
	self.lightShadowScheduler = HomeLightShadowScheduler.new()
	self.editorPlayerSetting = {}
	self.grassCullMap = {}
	self.grassCullPositionCache = Vector3.ForceNew(0, 0, 0)
	self.grassCullRotationCache = Quaternion.NewReadOnly(0, 0, 0, 1)
	self.srcEntityLinkPresetFilter = nil
	self.srcEntityLinkDirFilter = nil
	self.homelandSnapshotRequestId = 0
	self.homelandSnapshotSpaceId = nil
	self.nextHomelandSnapshotTime = nil
	self.isHomelandSnapshotInProgress = false
	self.homelandSnapshotCaptureDeadline = nil
	self.lastHomelandSnapshotLocalUploadTs = nil
end

function HomeSystem:onClear()
	self:stopHomelandSnapshotSchedule()
	self:clearHomeSystem()

	self.curLoginShowConfirmHint = true
	self.curLoginPlaceShowConfirmHint = true
	self.curLoginShowOrderPayRefreshHint = true
	self.curLoginShowElectricModeHint = true
	self.lastSyncWorkEffectTime = nil
	self.lastCheckAIWorkStateTime = nil
	self.curLoginShowPetHint = true
	self.curDelFacilityConfirmHint = true
	self.curLoginShowMultiSelectClearHint = true
	self.initScene = false

	table.clear(self.syncWorkEffectFacilities)
	table.clear(self.editorPlayerSetting)

	if self.lightShadowScheduler then
		self.lightShadowScheduler:clear()
	end

	self.lastLightShadowTime = nil
end

function HomeSystem:onPlayerDestroy(player)
	self:stopHomelandSnapshotSchedule()

	self.lastHomelandSnapshotLocalUploadTs = nil

	self:clearHomeSystem()
end

function HomeSystem:clearHomeSystem()
	self.editor:clear()
	self:clearFastFindData()
	self:destroyZones()
	self:restoreAllGrass()
	self:destroyHomeEntities()
end

function HomeSystem:onSceneLoaded(sceneId, sceneName)
	if pg.space and pg.space:isHomeland() then
		self.editor:initHomeland(pg.space)
		pg.global.homelandMgr:TryInitHomeManager()
		pg.global.homelandMgr:SwitchHomelandSettings(true)

		self.initScene = true

		self:cullGrassForAllOrnaments()
		self:startHomelandSnapshotSchedule()
	end
end

function HomeSystem:onSceneUnloaded(sceneId, sceneName)
	if Utils.isHomelandBySceneId(sceneId) then
		self:stopHomelandSnapshotSchedule()
	end

	self:clearHomeSystem()

	if Utils.isHomelandBySceneId(sceneId) then
		pg.global.homelandMgr:SwitchHomelandSettings(false)
		pg.global.homelandMgr:ResetHomeManager()

		self.initScene = false
	end
end

function HomeSystem:onTick()
	if pg.me and pg.me.space and pg.me.space.isHomeland and pg.me.space:isHomeland() then
		self.editor:tickEditor()
		self:updateHomeEntityInteractEffect()

		local now = Time.realSecondCache

		if not self.lastSyncWorkEffectTime or now - self.lastSyncWorkEffectTime > 5 then
			self.lastSyncWorkEffectTime = now

			self:doSyncWorkEffectFacilities()
		end

		if not self.lastCheckAIWorkStateTime or now - self.lastCheckAIWorkStateTime > 1 then
			self.lastCheckAIWorkStateTime = now

			self:checkHomePetWorkState()
		end

		if self:isSelfHomelandSnapshotSpace(pg.me.space) then
			self:updateHomelandSnapshotSchedule(now)
		elseif self.homelandSnapshotSpaceId then
			self:stopHomelandSnapshotSchedule()
		end

		self:checkAndRefreshShadows()

		local lightShadowInterval = HomelandConfigData.shadowLightUpdateInterval or 0.5

		if not self.lastLightShadowTime or lightShadowInterval < now - self.lastLightShadowTime then
			self.lastLightShadowTime = now

			self.lightShadowScheduler:update(pg.me:getPosition())
		end
	elseif self.homelandSnapshotSpaceId then
		self:stopHomelandSnapshotSchedule()
	end
end

function HomeSystem:isSelfHomelandSnapshotSpace(space)
	local player = pg.me

	space = space or player and player.space

	return player and space and space.isHomeland and space:isHomeland() and space.isSelfHomeland and space:isSelfHomeland(player)
end

function HomeSystem:getHomelandSnapshotInterval()
	local configInterval = tonumber(HomelandConfigData.homelandSnapshotUploadInterval)

	if configInterval and configInterval > 0 then
		return configInterval
	end

	return HomeSystem.HOMELAND_SNAPSHOT_INTERVAL
end

function HomeSystem:getNextHomelandSnapshotTime(now)
	now = now or Time.realSecondCache

	local interval = self:getHomelandSnapshotInterval()
	local serverUploadTs = tonumber(pg.me and pg.me.lastHomelandSnapshotUploadTs) or 0
	local localUploadTs = tonumber(self.lastHomelandSnapshotLocalUploadTs) or 0
	local lastUploadTs = math.max(serverUploadTs, localUploadTs)

	if lastUploadTs <= 0 then
		return now + interval + HomeSystem.HOMELAND_SNAPSHOT_UPLOAD_TIME_BUFFER
	end

	local nextUploadTs = lastUploadTs + interval + HomeSystem.HOMELAND_SNAPSHOT_UPLOAD_TIME_BUFFER

	return now + math.max(0, nextUploadTs - Time.secondCache)
end

function HomeSystem:startHomelandSnapshotSchedule()
	local space = pg.me and pg.me.space

	if not self:isSelfHomelandSnapshotSpace(space) then
		return
	end

	local spaceId = tostring(space.id or "")

	if self.homelandSnapshotSpaceId == spaceId then
		return
	end

	self:stopHomelandSnapshotSchedule()

	self.homelandSnapshotSpaceId = spaceId
	self.nextHomelandSnapshotTime = self:getNextHomelandSnapshotTime(Time.realSecondCache)
end

function HomeSystem:stopHomelandSnapshotSchedule()
	self.homelandSnapshotRequestId = (self.homelandSnapshotRequestId or 0) + 1
	self.homelandSnapshotSpaceId = nil
	self.nextHomelandSnapshotTime = nil
	self.isHomelandSnapshotInProgress = false
	self.homelandSnapshotCaptureDeadline = nil
end

function HomeSystem:isHomelandSnapshotContextValid(requestId, spaceId)
	if requestId ~= self.homelandSnapshotRequestId or spaceId ~= self.homelandSnapshotSpaceId then
		return false
	end

	local space = pg.me and pg.me.space

	return self:isSelfHomelandSnapshotSpace(space) and tostring(space.id or "") == spaceId
end

function HomeSystem:canCaptureHomelandSnapshot()
	local ui = pg.global and pg.global.ui

	if not pg.me or not pg.me.addPhotoImgSprite or not pg.global or not pg.global.mobileCameraMgr or not ui or not pg.game then
		return false
	end

	if self.editor and self.editor.isInEditMode then
		return false
	end

	return ui:checkUIVisible(UIConst.UI_ID_HUD_V2) and not ClientUtils.isFullScreenUI() and not ui:getLastNormalSecondPanel()
end

function HomeSystem:updateHomelandSnapshotSchedule(now)
	if not self.homelandSnapshotSpaceId then
		self:startHomelandSnapshotSchedule()

		return
	end

	local currentSpaceId = tostring(pg.me.space.id or "")

	if currentSpaceId ~= self.homelandSnapshotSpaceId then
		self:startHomelandSnapshotSchedule()

		return
	end

	if self.homelandSnapshotCaptureDeadline and now >= self.homelandSnapshotCaptureDeadline then
		self.homelandSnapshotRequestId = self.homelandSnapshotRequestId + 1
		self.isHomelandSnapshotInProgress = false
		self.homelandSnapshotCaptureDeadline = nil
		self.nextHomelandSnapshotTime = now + HomeSystem.HOMELAND_SNAPSHOT_RETRY_INTERVAL

		logger:warn("homeland auto review screenshot timed out")
	end

	if self.isHomelandSnapshotInProgress or not self.nextHomelandSnapshotTime or now < self.nextHomelandSnapshotTime then
		return
	end

	if not self:canCaptureHomelandSnapshot() then
		self.nextHomelandSnapshotTime = now + HomeSystem.HOMELAND_SNAPSHOT_RETRY_INTERVAL

		return
	end

	self:captureHomelandSnapshot(now)
end

function HomeSystem:captureHomelandSnapshot(now)
	self.homelandSnapshotRequestId = self.homelandSnapshotRequestId + 1

	local requestId = self.homelandSnapshotRequestId
	local spaceId = self.homelandSnapshotSpaceId

	self.isHomelandSnapshotInProgress = true
	self.homelandSnapshotCaptureDeadline = now + HomeSystem.HOMELAND_SNAPSHOT_CAPTURE_TIMEOUT
	self.nextHomelandSnapshotTime = now + self:getHomelandSnapshotInterval() + HomeSystem.HOMELAND_SNAPSHOT_UPLOAD_TIME_BUFFER

	pg.global.mobileCameraMgr:CaptureScreenDelaySaveCopy(function(sprite)
		self:onHomelandSnapshotCaptured(requestId, spaceId, sprite)
	end)
end

function HomeSystem:destroyHomelandSnapshotSprite(sprite)
	local cameraMgr = pg.global and pg.global.mobileCameraMgr

	if sprite and not IsNil(sprite) and cameraMgr then
		cameraMgr:DestroySpriteTexture(sprite)
	end
end

function HomeSystem:onHomelandSnapshotCaptured(requestId, spaceId, sprite)
	if requestId == self.homelandSnapshotRequestId then
		self.homelandSnapshotCaptureDeadline = nil
	end

	if not self:isHomelandSnapshotContextValid(requestId, spaceId) then
		self:destroyHomelandSnapshotSprite(sprite)

		return
	end

	if not self:canCaptureHomelandSnapshot() then
		self:destroyHomelandSnapshotSprite(sprite)

		self.isHomelandSnapshotInProgress = false
		self.nextHomelandSnapshotTime = Time.realSecondCache + HomeSystem.HOMELAND_SNAPSHOT_RETRY_INTERVAL

		return
	end

	if not sprite or IsNil(sprite) then
		self.isHomelandSnapshotInProgress = false
		self.nextHomelandSnapshotTime = Time.realSecondCache + HomeSystem.HOMELAND_SNAPSHOT_RETRY_INTERVAL

		logger:warn("homeland auto review screenshot failed")

		return
	end

	pg.me:addPhotoImgSprite(sprite, function(_, success, imgUrl)
		self:onHomelandSnapshotUploaded(requestId, spaceId, sprite, success, imgUrl)
	end)
end

function HomeSystem:onHomelandSnapshotUploaded(requestId, spaceId, sprite, success, imgUrl)
	self:destroyHomelandSnapshotSprite(sprite)

	if not self:isHomelandSnapshotContextValid(requestId, spaceId) then
		return
	end

	self.isHomelandSnapshotInProgress = false

	if not success or string.isNilOrEmpty(imgUrl) then
		logger:warn("homeland auto review screenshot upload failed")

		return
	end

	self.lastHomelandSnapshotLocalUploadTs = Time.secondCache
	self.nextHomelandSnapshotTime = self:getNextHomelandSnapshotTime(Time.realSecondCache)

	pg.me:serverMsg("RPC_CS_SubmitHomelandSnapshot", imgUrl)
end

function HomeSystem:intAreaBaseInfo()
	self.areaInfoDict = {}

	for areaId, areaData in pairs(HomelandAreaData) do
		local areaCenter = areaData.areaCenter or {
			0,
			0,
			0
		}
		local areaYaw = areaData.areaYaw or 0
		local basePosition = Vector3(areaCenter[1], areaCenter[2], areaCenter[3])
		local baseRotation = Quaternion.Euler(0, areaYaw, 0)
		local baseTransMatrix = Matrix4x4.TRS(basePosition, baseRotation, Vector3.constOne)

		self.areaInfoDict[areaId] = {
			basePosition = basePosition,
			baseRotation = baseRotation,
			baseTransMatrix = baseTransMatrix,
			baseTransMatrixInv = baseTransMatrix.inverse,
			baseRotationInv = baseRotation:Inverse()
		}
	end
end

function HomeSystem:getAreaOrnamentDefaultYaw(areaId)
	if not areaId or not CommonSwitch.HOMELAND_NEW_MAP then
		return 180
	end

	local areaData = HomelandAreaData[areaId] or {}

	return areaData.ornamentDefaultYaw or 180
end

function HomeSystem:getAreaBasePosition(areaId)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return nil
	end

	local areaInfo = self.areaInfoDict[areaId]

	if not areaInfo then
		return nil
	end

	return areaInfo.basePosition
end

function HomeSystem:getAreaBaseTransform(areaId)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return nil
	end

	local areaInfo = self.areaInfoDict[areaId]

	if not areaInfo then
		return nil
	end

	return areaInfo.baseTransMatrix
end

function HomeSystem:getAreaBaseRotation(areaId)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return Quaternion.identity
	end

	local areaInfo = self.areaInfoDict[areaId]

	if not areaInfo then
		return nil
	end

	return areaInfo.baseRotation
end

function HomeSystem:getAreaRange(areaId)
	if not CommonSwitch.HOMELAND_NEW_MAP or not areaId then
		return HomelandConfigData.homelandAreaRange
	end

	local areaData = HomelandAreaData[areaId]

	if not areaData then
		return HomelandConfigData.homelandAreaRange
	end

	return areaData.areaRange or HomelandConfigData.homelandAreaRange
end

function HomeSystem:getAreaYAxisRange(areaId)
	if not CommonSwitch.HOMELAND_NEW_MAP or not areaId then
		return HomelandConfigData.yAxisRange
	end

	local areaData = HomelandAreaData[areaId]

	if not areaData then
		return HomelandConfigData.yAxisRange
	end

	return areaData.yAxisRange or HomelandConfigData.yAxisRange
end

function HomeSystem:getWorldPosition(areaId, position)
	local baseMatrix = self:getAreaBaseTransform(areaId)

	if baseMatrix then
		return baseMatrix:MultiplyPoint(position)
	end

	return position
end

function HomeSystem:getWorldRotation(areaId, rotation)
	local baseRotation = self:getAreaBaseRotation(areaId)

	if baseRotation then
		return baseRotation * rotation
	end

	return rotation
end

function HomeSystem:getLocalPosition(areaId, position)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return position
	end

	local areaInfo = self.areaInfoDict[areaId]

	if not areaInfo or not areaInfo.baseTransMatrixInv then
		return position
	end

	return areaInfo.baseTransMatrixInv:MultiplyPoint(position)
end

function HomeSystem:getLocalRotation(areaId, rotation)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return rotation
	end

	local areaInfo = self.areaInfoDict[areaId]

	if not areaInfo or not areaInfo.baseRotationInv then
		return rotation
	end

	return areaInfo.baseRotationInv * rotation
end

function HomeSystem:onAreaUnlockedChanged()
	self:updateAreaAirWalls()
	facade:sendMsgToUI(MessageName.HOMELAND_AREA_LOCK_STATE_CHANGED)
end

function HomeSystem:checkAreaNotOpened(areaId)
	local areaData = HomelandAreaData[areaId] or {}

	if areaData.noOpen == 1 then
		return true
	end

	return false
end

function HomeSystem:checkAreaLocked(areaId)
	if self:checkAreaNotOpened(areaId) then
		return true
	end

	local areaData = HomelandAreaData[areaId] or {}

	if areaData.isUnlock == 1 then
		return false
	end

	return pg.space.unlockArea[areaId] ~= true
end

function HomeSystem:getNearestAreaId(playerPosition, needBuildArea)
	if not CommonSwitch.HOMELAND_NEW_MAP or not playerPosition then
		return 0
	end

	local nearestAreaId = 0
	local minSqrDist, priorityAreaId, priorityMinSqrDist

	for areaId, areaInfo in pairs(self.areaInfoDict) do
		local areaData = HomelandAreaData[areaId] or {}
		local valid = true

		if needBuildArea and areaData.isBuildArea ~= 1 then
			valid = false
		end

		if self:checkAreaLocked(areaId) then
			valid = false
		end

		if valid then
			local areaRange = self:getAreaRange(areaId)
			local localPosition = areaInfo.baseTransMatrixInv:MultiplyPoint(playerPosition)
			local nearestX = math.clamp(localPosition.x, areaRange[1], areaRange[2])
			local nearestZ = math.clamp(localPosition.z, areaRange[3], areaRange[4])
			local dx = localPosition.x - nearestX
			local dz = localPosition.z - nearestZ
			local sqrDist = dx * dx + dz * dz
			local isPriorityArea = areaId == Const.HOMELAND_AREA_TYPE.PRODUCE or areaId == Const.HOMELAND_AREA_TYPE.BUILD or areaId == Const.HOMELAND_AREA_TYPE.SEASON
			local rangeExtend = HomeSystem.NEAREST_AREA_PRIORITY_RANGE_EXTEND

			if isPriorityArea and areaRange[1] - rangeExtend <= localPosition.x and localPosition.x <= areaRange[2] + rangeExtend and areaRange[3] - rangeExtend <= localPosition.z and localPosition.z <= areaRange[4] + rangeExtend and (not priorityMinSqrDist or sqrDist < priorityMinSqrDist) then
				priorityMinSqrDist = sqrDist
				priorityAreaId = areaId
			end

			if not minSqrDist or sqrDist < minSqrDist then
				minSqrDist = sqrDist
				nearestAreaId = areaId
			end
		end
	end

	return priorityAreaId or nearestAreaId
end

function HomeSystem:getCurPlayerAreaId(playerPosition, areaRangeExtend)
	if not CommonSwitch.HOMELAND_NEW_MAP then
		return Const.HOMELAND_AREA_TYPE.PRODUCE, true
	end

	if not playerPosition then
		return Const.HOMELAND_AREA_TYPE.PRODUCE, false
	end

	areaRangeExtend = areaRangeExtend or 5

	local curAreaId = 0
	local minSqrDist, priorityAreaId, priorityMinSqrDist

	for areaId, areaInfo in pairs(self.areaInfoDict) do
		if self:checkAreaLocked(areaId) then
			-- block empty
		else
			local areaRange = self:getAreaRange(areaId)
			local localPosition = areaInfo.baseTransMatrixInv:MultiplyPoint(playerPosition)

			if areaRange[1] - areaRangeExtend <= localPosition.x and localPosition.x <= areaRange[2] + areaRangeExtend and areaRange[3] - areaRangeExtend <= localPosition.z and localPosition.z <= areaRange[4] + areaRangeExtend then
				local dx = playerPosition.x - areaInfo.basePosition.x
				local dz = playerPosition.z - areaInfo.basePosition.z
				local sqrDist = dx * dx + dz * dz
				local isPriorityArea = areaId == Const.HOMELAND_AREA_TYPE.PRODUCE or areaId == Const.HOMELAND_AREA_TYPE.BUILD or areaId == Const.HOMELAND_AREA_TYPE.SEASON

				if isPriorityArea and (not priorityMinSqrDist or sqrDist < priorityMinSqrDist) then
					priorityMinSqrDist = sqrDist
					priorityAreaId = areaId
				end

				if not minSqrDist or sqrDist < minSqrDist then
					minSqrDist = sqrDist
					curAreaId = areaId
				end
			end
		end
	end

	return priorityAreaId or curAreaId, minSqrDist ~= nil
end

function HomeSystem:openManagePanelByArea()
	if not CommonSwitch.HOMELAND_NEW_MAP then
		pg.global.ui.homelandPlotManageNew:open()

		return
	end

	local playerPosition = pg.me:getPosition()
	local currentAreaId, isInArea = pg.game.home:getCurPlayerAreaId(playerPosition, 10)

	if not isInArea then
		currentAreaId = pg.game.home:getNearestAreaId(playerPosition)
	end

	if currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE or currentAreaId == Const.HOMELAND_AREA_TYPE.BUILD then
		pg.global.ui.homelandPlotManageNew:open({
			areaId = currentAreaId
		})
	else
		pg.global.ui.homelandAreaManage:open()
	end
end

function HomeSystem:registerHomeEnt(ornamentId, homeEntity)
	self.homeEntities[ornamentId] = homeEntity

	self:onOrnamentAdd(ornamentId, homeEntity)
end

function HomeSystem:unregisterHomeEnt(ornamentId, homeEntity)
	self.homeEntities[ornamentId] = nil

	self:onOrnamentRemove(ornamentId, homeEntity)
end

function HomeSystem:refreshShadows()
	self.needRefreshShadow = true
end

function HomeSystem:checkAndRefreshShadows()
	if self.needRefreshShadow then
		self.needRefreshShadow = false

		pg.global.gameMgr:ForceRefreshShadows()
	end
end

function HomeSystem:getHomeEntity(ornamentId)
	if ornamentId < 0 then
		return self.virtualHomeEntities[ornamentId]
	end

	return self.homeEntities[ornamentId]
end

function HomeSystem:registerVirtualHomeEnt(ornamentId, homeEntity)
	self.virtualHomeEntities[ornamentId] = homeEntity

	self:onOrnamentAdd(ornamentId, homeEntity, true)
end

function HomeSystem:unregisterVirtualHomeEnt(ornamentId, homeEntity)
	self:onOrnamentRemove(ornamentId, homeEntity)

	self.virtualHomeEntities[ornamentId] = nil
end

function HomeSystem:getFastFindMap(areaId, create)
	areaId = areaId or 0

	local fastFindMap = self.fastFindMapDict[areaId]

	if not fastFindMap and create then
		fastFindMap = HomelandFastFindMap.new(16)
		self.fastFindMapDict[areaId] = fastFindMap
	end

	return fastFindMap
end

function HomeSystem:getOrnamentAreaId(ent)
	if ent then
		if ent.areaId then
			return ent.areaId
		end

		if ent.getOrnamentInfo then
			local ornamentInfo = ent:getOrnamentInfo()

			if ornamentInfo and ornamentInfo.areaId then
				return ornamentInfo.areaId
			end
		end
	end

	return 0
end

function HomeSystem:onOrnamentPositionChanged(ornamentId, ent, isTemplateEntity)
	local px, py, pz = ent.eModel:GetPositionAgentPosEx()
	local rx, ry, rz, rw = ent.eModel:GetPositionAgentRotationEx()
	local areaId = self.ornamentAreaIdDict[ornamentId] or self:getOrnamentAreaId(ent)
	local fastFindMap = self:getFastFindMap(areaId, true)

	Vector3.enableCreateFromCache()
	fastFindMap:refreshFastFindInfo(ornamentId, self:getLocalPosition(areaId, Vector3.New(px, py, pz)), self:getLocalRotation(areaId, Quaternion(rx, ry, rz, rw)), ent:getBoundSize())
	Vector3.disableCreateFromCache()
	self.editor:onOrnamentPositionChanged(ornamentId, ent, isTemplateEntity)

	if not isTemplateEntity then
		self:cullGrassForEntity(ornamentId, ent)
	end

	self.lightShadowScheduler:onLightMoved(ornamentId)
end

function HomeSystem:onOrnamentAdd(ornamentId, ent, isTemplateEntity)
	local px, py, pz = ent.eModel:GetPositionAgentPosEx()
	local rx, ry, rz, rw = ent.eModel:GetPositionAgentRotationEx()
	local areaId = self:getOrnamentAreaId(ent)
	local fastFindMap = self:getFastFindMap(areaId, true)

	fastFindMap:addOrUpdateFastFindInfo(ornamentId, ent:getBoundSize(), self:getLocalPosition(areaId, Vector3.New(px, py, pz)), self:getLocalRotation(areaId, Quaternion(rx, ry, rz, rw)), self:getFastFindExtraInfo(ent))

	self.ornamentAreaIdDict[ornamentId] = areaId

	if self.initScene and not isTemplateEntity then
		self:cullGrassForEntity(ornamentId, ent)
	end
end

function HomeSystem:onOrnamentRemove(ornamentId, ent)
	local areaId = self.ornamentAreaIdDict[ornamentId] or self:getOrnamentAreaId(ent)
	local fastFindMap = self:getFastFindMap(areaId)

	if fastFindMap then
		fastFindMap:removeFastFindInfo(ornamentId)
	end

	self.ornamentAreaIdDict[ornamentId] = nil

	self:restoreGrassForOrnament(ornamentId)
end

function HomeSystem:getFastFindExtraInfo(ent)
	local extraInfo = {}

	extraInfo.homeTemplateId = ent.homeTemplateId
	extraInfo.layer = ent:getOrnamentLayer()
	extraInfo.ent = ent

	HomeLandUtils.addFastFindAttachExtraInfo(ent, extraInfo)

	return extraInfo
end

function HomeSystem:getPositionOrnament(areaId, position)
	local fastFindMap = self:getFastFindMap(areaId)

	if not fastFindMap then
		return nil
	end

	local localPosition = self:getLocalPosition(areaId, position)

	fastFindMap:getAreaRangeOrnamentIds(localPosition.x, localPosition.x, localPosition.z, localPosition.z, false, self.tempCollideResult)

	local result

	for collideOrnamentId, fastInfo in pairs(self.tempCollideResult) do
		if fastInfo.extraInfo.ent.visible then
			result = fastInfo.extraInfo.ent

			break
		end
	end

	table.clear(self.tempCollideResult)

	return result
end

function HomeSystem:getAreaOrnaments(areaId, minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
	local fastFindMap = self:getFastFindMap(areaId)

	if not fastFindMap then
		table.clear(ornaments)

		return true
	end

	fastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, ornaments, nil, minHeight, maxHeight, filterFunc, slowFilterFunc)

	return true
end

function HomeSystem:setLinkEffectVisible(visible)
	self.linkEffectVisible = visible

	self.editor:updateAllLinkEffects(true)
end

function HomeSystem.floorLiftFastFilter(ornamentId, fastInfo)
	local extraInfo = fastInfo.extraInfo

	return extraInfo ~= nil and HomeLandUtils.checkHomeObjectIsFloor(extraInfo.homeTemplateId)
end

function HomeSystem:getFloorLiftLocalY(areaId, localPosition)
	local fastFindMap = self:getFastFindMap(areaId)

	if not fastFindMap then
		return 0
	end

	local tolerance = HomeLandUtils.HOME_FLOOR_LIFT_QUERY_TOLERANCE

	fastFindMap:getAreaRangeOrnamentIds(localPosition.x, localPosition.x, localPosition.z, localPosition.z, true, self.tempFloorLiftResult, nil, localPosition.y - tolerance, localPosition.y + tolerance, HomeSystem.floorLiftFastFilter)

	local floorY

	for _, fastInfo in pairs(self.tempFloorLiftResult) do
		if not floorY or floorY < fastInfo.position.y then
			floorY = fastInfo.position.y
		end
	end

	table.clear(self.tempFloorLiftResult)

	if not floorY then
		return 0
	end

	return floorY + HomeLandUtils.HOME_FLOOR_LIFT_HEIGHT
end

function HomeSystem:createLockZone(zoneId)
	return
end

function HomeSystem:hasLockedZoneAtPosition(zoneConfigData, areaId, targetX, targetZ)
	for zoneId, zoneData in pairs(zoneConfigData) do
		local zoneAreaId = zoneData.areaId or 0
		local zonePosition = zoneData.prefabPos

		if zoneAreaId == areaId and zonePosition and not self:isHomelandZoneUnlock(zoneId) and math.abs(zonePosition[1] - targetX) < self.ZONE_POSITION_EPSILON and math.abs(zonePosition[2] - targetZ) < self.ZONE_POSITION_EPSILON then
			return true
		end
	end

	return false
end

function HomeSystem:updateLockZoneEffect(zoneId, zoneObj, zoneConfigData)
	if not zoneObj then
		return
	end

	local zoneEffect = zoneObj:GetComponent("HomeZoneEffect")

	if not zoneEffect then
		return
	end

	local zoneData = zoneConfigData[zoneId]
	local zonePosition = zoneData and zoneData.prefabPos

	if not zonePosition then
		return
	end

	local areaId = zoneData.areaId or 0
	local x = zonePosition[1]
	local z = zonePosition[2]
	local leftActive = not self:hasLockedZoneAtPosition(zoneConfigData, areaId, x, z + self.zoneHeight)
	local rightActive = not self:hasLockedZoneAtPosition(zoneConfigData, areaId, x, z - self.zoneHeight)
	local frontActive = not self:hasLockedZoneAtPosition(zoneConfigData, areaId, x + self.zoneWidth, z)
	local backActive = not self:hasLockedZoneAtPosition(zoneConfigData, areaId, x - self.zoneWidth, z)

	return zoneEffect:SetEdgeEffectsActive(leftActive, rightActive, frontActive, backActive)
end

function HomeSystem:refreshLockZoneEffects()
	local zoneConfigData = HomeLandUtils.getHomelandZoneUnlockData()

	for zoneId, zoneObj in pairs(self.lockZones) do
		if self:updateLockZoneEffect(zoneId, zoneObj, zoneConfigData) then
			local zoneItem = zoneObj:GetComponent("HomeLockZoneItem")

			if zoneItem then
				zoneItem:SetZoneRendererBatch(ClientUtils.checkEnableRendererBatch())
			end
		end
	end
end

function HomeSystem:showAreaZoneLockEffects(areaId)
	areaId = areaId or 0
	self.zoneLockEffectAreaId = areaId

	local zoneConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local effectHeight = self.editor:getBottomEffectOffset() + HomeSystem.ZONE_LOCK_EFFECT_HEIGHT
	local lockText = pg.getGameString(HomeSystem.ZONE_LOCK_LABEL_TEXT_KEY)
	local rotation = self:getWorldRotation(areaId, Quaternion.identity)

	for zoneId, zoneData in pairs(zoneConfigData) do
		local zonePosition = zoneData.prefabPos

		if (zoneData.areaId or 0) == areaId and zonePosition and not self:isHomelandZoneUnlock(zoneId) then
			self.zoneLockEffects[zoneId] = true

			local center = self:getWorldPosition(areaId, Vector3(zonePosition[1], effectHeight, zonePosition[2]))

			pg.global.homelandMgr:ShowZoneLockEffect(zoneId, center, rotation, self.zoneWidth, self.zoneHeight, lockText)
		end
	end
end

function HomeSystem:hideZoneLockEffects()
	self.zoneLockEffectAreaId = nil

	if Utils.tableIsEmptyOrNil(self.zoneLockEffects) then
		return
	end

	table.clear(self.zoneLockEffects)
	pg.global.homelandMgr:ClearZoneLockEffects()
end

function HomeSystem:refreshZoneLockEffects()
	if not self.zoneLockEffectAreaId then
		return
	end

	for zoneId, _ in pairs(self.zoneLockEffects) do
		if self:isHomelandZoneUnlock(zoneId) then
			self.zoneLockEffects[zoneId] = nil

			pg.global.homelandMgr:HideZoneLockEffect(zoneId)
		end
	end
end

function HomeSystem:genVirtualOrnamentId()
	self.virtualOrnamentId = self.virtualOrnamentId - 1

	return self.virtualOrnamentId
end

function HomeSystem:createAreaAirWalls()
	self.areaAirWallLoadVersion = (self.areaAirWallLoadVersion or 0) + 1

	local areaAirWallLoadVersion = self.areaAirWallLoadVersion
	local homeRoot = pg.global.homelandMgr.homeRoot.transform

	for areaId, areaData in pairs(HomelandAreaData) do
		local airWallPos = areaData.airWallPos
		local airWallResId = areaData.airWallResId

		if airWallPos and not string.isNilOrEmpty(airWallResId) and self:checkAreaLocked(areaId) then
			pg.global.resMgr:GetInstanceFromCacheByLua(airWallResId, function(obj, userData)
				if areaAirWallLoadVersion ~= self.areaAirWallLoadVersion or not pg.space or not pg.space.unlockArea or not self:checkAreaLocked(areaId) then
					pg.global.resMgr:RemoveInstanceToCache(obj)

					return
				end

				self.areaAirWalls[areaId] = obj
				obj.transform.position = Vector3(airWallPos[1], airWallPos[2], airWallPos[3])
			end, 1, nil, homeRoot)
		end
	end
end

function HomeSystem:updateAreaAirWalls()
	for areaId, airWallObj in pairs(self.areaAirWalls) do
		if not self:checkAreaLocked(areaId) then
			self.areaAirWalls[areaId] = nil

			pg.global.resMgr:RemoveInstanceToCache(airWallObj)
		end
	end
end

function HomeSystem:destroyAreaAirWalls()
	self.areaAirWallLoadVersion = (self.areaAirWallLoadVersion or 0) + 1

	for areaId, airWallObj in pairs(self.areaAirWalls) do
		pg.global.resMgr:RemoveInstanceToCache(airWallObj)
	end

	self.areaAirWalls = {}
end

function HomeSystem:getNearestAirWallAreaId(position)
	if not position then
		return nil
	end

	local nearestAreaId, minSqrDist

	for areaId in pairs(self.areaAirWalls) do
		local areaInfo = self.areaInfoDict[areaId]

		if areaInfo and areaInfo.baseTransMatrixInv then
			local areaRange = self:getAreaRange(areaId)
			local localPosition = areaInfo.baseTransMatrixInv:MultiplyPoint(position)
			local dx = localPosition.x - math.clamp(localPosition.x, areaRange[1], areaRange[2])
			local dz = localPosition.z - math.clamp(localPosition.z, areaRange[3], areaRange[4])
			local sqrDist = dx * dx + dz * dz

			if not minSqrDist or sqrDist < minSqrDist then
				minSqrDist = sqrDist
				nearestAreaId = areaId
			end
		end
	end

	local maxDist = HomeSystem.AREA_LOCK_TIP_MAX_DISTANCE

	if nearestAreaId and minSqrDist <= maxDist * maxDist then
		return nearestAreaId
	end

	return nil
end

function HomeSystem:tryShowAreaLockTip(position)
	if not pg.space or not pg.space:isHomeland() then
		return
	end

	if not self:getNearestAirWallAreaId(position) then
		return
	end

	pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_AREA_AIRWALL_NOT_OPEN)
end

function HomeSystem:getLockZonePrefabName(areaId)
	if areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		return AddressDataConst.HOME_BUILD_AREA_LOCK_ZONE
	end

	if CommonSwitch.HOMELAND_NEW_MAP then
		return HomelandConfigData.newHomePlotsPrefab
	end

	return HomelandConfigData.homePlotsPrefab
end

function HomeSystem:createLockZones(unlockZones)
	self.lockZoneLoadVersion = (self.lockZoneLoadVersion or 0) + 1

	local lockZoneLoadVersion = self.lockZoneLoadVersion
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local homeRoot = pg.global.homelandMgr.homeRoot.transform
	local isSelfHomeland = pg.space:isSelfHomeland(pg.me)

	for zoneId, zoneData in pairs(HomelandZoneUnlockConfigData) do
		if not self:isHomelandZoneUnlock(zoneId) then
			local areaId = zoneData.areaId or 0

			pg.global.resMgr:GetInstanceFromCacheByLua(self:getLockZonePrefabName(areaId), function(obj, userData)
				if lockZoneLoadVersion ~= self.lockZoneLoadVersion or not pg.space or not pg.space.unlockZone or self:isHomelandZoneUnlock(zoneId) then
					pg.global.resMgr:RemoveInstanceToCache(obj)

					return
				end

				self.lockZones[zoneId] = obj
				obj.transform.position = self:getWorldPosition(areaId, Vector3(zoneData.prefabPos[1], 0, zoneData.prefabPos[2]))
				obj.transform.rotation = self:getWorldRotation(areaId, Quaternion.Euler(0, 90, 0))

				local zoneItem = obj:GetComponent("HomeLockZoneItem")

				if zoneItem then
					zoneItem.zoneId = zoneId
					zoneItem.enableInteract = isSelfHomeland

					self:updateLockZoneEffect(zoneId, obj, HomelandZoneUnlockConfigData)
					zoneItem:SetZoneRendererBatch(ClientUtils.checkEnableRendererBatch())
				end
			end, 1, nil, homeRoot)
		end
	end

	self:createAreaAirWalls()
	self:refreshShadows()
end

function HomeSystem:onZoneUnlock()
	if pg.me then
		pg.me:playEffect(HomeSystem.ZONE_UNLOCK_EFFECT)
	end

	self:updateZones()
end

function HomeSystem:updateZones()
	for zoneId, zoneObj in pairs(self.lockZones) do
		if self:isHomelandZoneUnlock(zoneId) then
			self.lockZones[zoneId] = nil

			pg.global.resMgr:RemoveInstanceToCache(zoneObj)
		end
	end

	self:refreshLockZoneEffects()
	self:refreshZoneLockEffects()
	self:refreshShadows()
end

function HomeSystem:destroyZones()
	self.lockZoneLoadVersion = (self.lockZoneLoadVersion or 0) + 1

	for zoneId, zoneObj in pairs(self.lockZones) do
		pg.global.resMgr:RemoveInstanceToCache(zoneObj)
	end

	self.lockZones = {}

	self:destroyAreaAirWalls()
	self:refreshShadows()
end

function HomeSystem:isHomelandZoneUnlock(zoneId)
	return pg.space.unlockZone[zoneId] or false
end

function HomeSystem:createHomeEntities(ornamentData)
	for ornamentId, ornamentInfo in pairs(ornamentData) do
		self:createHomeEntity(ornamentId, ornamentInfo)
	end
end

function HomeSystem:destroyHomeEntities()
	self.isDestroyingAll = true

	local toDestroy = {}

	for ornamentId, homeEntity in pairs(self.homeEntities) do
		toDestroy[#toDestroy + 1] = homeEntity
	end

	for _, homeEntity in ipairs(toDestroy) do
		self:destroyHomeEntity(homeEntity)
	end

	self.isDestroyingAll = false
end

function HomeSystem:createHomeEntity(ornamentId, ornamentInfo)
	local templateId = ornamentInfo.homeId
	local areaId = ornamentInfo.areaId
	local position = self:getWorldPosition(areaId, ornamentInfo:getPosition())
	local rotation = self:getWorldRotation(areaId, ornamentInfo:getRotation())
	local scale = ornamentInfo:getScale()
	local ent = self:getHomeEntity(ornamentId)

	if ent then
		return ent
	end

	return self:innerCreateHomeEntity(ornamentId, areaId, templateId, position, rotation, scale)
end

function HomeSystem:getClientEntityClassName(homeObjectData, homeTemplateId)
	local wishStarBottleHomeId = HomelandConfigData.homeVoucherCollectorHome

	if wishStarBottleHomeId ~= nil and homeTemplateId == wishStarBottleHomeId then
		return "ClientHomeWishingStar"
	end

	if homeObjectData.facilityId then
		if homeObjectData.subEntType == Const.HomelandEntSubType.HatchBox then
			return "ClientHomeFacilityHatchBox"
		else
			return "ClientHomeFacility"
		end
	end

	if HomeLandUtils.isHomeOrnamentPureStatic(homeObjectData) then
		return "ClientHomeStaticEntity"
	end

	return "ClientHomeEntity"
end

function HomeSystem:innerCreateHomeEntity(ornamentId, areaId, homeTemplateId, position, rotation, scale)
	local configData = HomeObjectData[homeTemplateId] or {}

	if Utils.checkIsServerHomeObject(homeTemplateId) then
		return
	end

	local className = self:getClientEntityClassName(configData, homeTemplateId)

	rotation = rotation or Quaternion.identity

	local homeEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		homeTemplateId = homeTemplateId,
		ornamentId = ornamentId,
		areaId = areaId,
		position = position,
		rotation = rotation
	})

	if homeEntity and scale and homeEntity.setScale then
		homeEntity:setScale(scale)
		homeEntity:onEntityPositionChanged()
	end

	self:refreshShadows()

	return homeEntity
end

function HomeSystem:getWorldFurniturePlaceHeightLimit()
	return HomelandConfigData.placeFurnitureHeightDiffLimit or 20
end

function HomeSystem:getRaycastHitActorEntity(hitInfo)
	local collider = hitInfo and hitInfo.colliderHandle and hitInfo.colliderHandle.collider

	if IsNil(collider) then
		return nil
	end

	local physxComponent = collider:GetComponentInParent(typeof(self.WORLD_FURNITURE_PHYSX_COMPONENT))

	if physxComponent == nil then
		local rb = collider.attachedRigidbody

		if NotNil(rb) then
			physxComponent = rb:GetComponent(typeof(self.WORLD_FURNITURE_PHYSX_COMPONENT))
		end
	end

	if physxComponent == nil or physxComponent.tagType ~= Const.TAG_ACTOR then
		return nil
	end

	return pg.getEntityByActorId(physxComponent.tagId)
end

function HomeSystem:isWorldFurnitureRaycastHit(hitInfo)
	local entity = self:getRaycastHitActorEntity(hitInfo)

	if not entity or not entity.homeTemplateId or not entity.getClassType then
		return false
	end

	return self.WORLD_FURNITURE_CLASS_NAMES[entity:getClassType()] == true
end

function HomeSystem:getWorldFurniturePlaceValidHit(raycastPos, direction, maxDistance)
	local curRaycastPos = raycastPos
	local remainDistance = maxDistance
	local hitInfo, succ = PhysicsUtils.getRaycastInfo(curRaycastPos, direction, remainDistance, CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS)

	if not succ or not hitInfo then
		return nil, false
	end

	if not self:isWorldFurnitureRaycastHit(hitInfo) then
		return hitInfo, true
	end

	local skipDistance = (hitInfo.distance or 0) + 0.05

	if remainDistance <= skipDistance then
		return nil, false
	end

	curRaycastPos = curRaycastPos + direction * skipDistance
	remainDistance = remainDistance - skipDistance
end

function HomeSystem:getWorldFurniturePlaceTransform(distance)
	local player = pg.me

	if not player then
		return nil, nil, nil
	end

	local forward = player:getRotation():Forward()

	forward.y = 0

	if Vector3.SqrMagnitude(forward) <= 0.0001 then
		forward = Vector3.constForward
	else
		forward:Normalize()
	end

	local playerPos = player:getPosition()
	local targetDistance = distance or 1
	local position = playerPos + forward * targetDistance
	local maxPlaceHeight = self:getWorldFurniturePlaceHeightLimit()
	local heightProbeOffset = maxPlaceHeight + 0.5
	local highObstacleCheckPos = playerPos + Vector3.constUp * heightProbeOffset
	local highObstacleHitInfo, highObstacleSucc = self:getWorldFurniturePlaceValidHit(highObstacleCheckPos, forward, targetDistance)

	if highObstacleSucc and highObstacleHitInfo then
		return nil, nil, nil
	end

	local raycastPos = position + Vector3.constUp * heightProbeOffset
	local hitInfo, succ = self:getWorldFurniturePlaceValidHit(raycastPos, Vector3.constDown, heightProbeOffset + maxPlaceHeight)

	if not succ then
		return nil, nil, nil
	end

	local rotation = player:getRotation():Clone()

	return hitInfo.point, rotation, hitInfo.normal
end

function HomeSystem:checkWorldFurniturePlaceAngle(normal)
	if not normal then
		return false
	end

	local maxAngle = HomelandConfigData.placeFurnitureAngle

	if not maxAngle or maxAngle < 0 then
		return true
	end

	return maxAngle >= Vector3.Angle(normal, Vector3.constUp)
end

function HomeSystem:getWorldFurniturePlaceOverlapLayerMask()
	local layerDefine = ClientConst.LayerDefine

	return bit.lshift(1, layerDefine.LAYER_DEFAULT) + bit.lshift(1, layerDefine.LAYER_WALL) + bit.lshift(1, layerDefine.LAYER_AIR_WALL) + bit.lshift(1, layerDefine.LAYER_ENTITY) + bit.lshift(1, layerDefine.LAYER_PET) + bit.lshift(1, layerDefine.LAYER_PLAYER) + bit.lshift(1, layerDefine.LAYER_NOCLIMB) + bit.lshift(1, layerDefine.LAYER_NOACROSS) + bit.lshift(1, layerDefine.LAYER_NO_CLIMBING_SCENE)
end

function HomeSystem:checkWorldFurniturePlaceOverlap(homeTemplateId, position)
	local configData = HomeObjectData[homeTemplateId]

	if not configData then
		return false
	end

	local boundSize = configData.boundSize or {
		1,
		1
	}
	local scale = configData.prefabScale or 1
	local height = math.max((configData.modelHeight or 1) * scale, self.WORLD_FURNITURE_PLACE_CHECK_GROUND_GAP * 2)
	local halfX = (boundSize[1] or 1) * scale * 0.5
	local halfZ = (boundSize[2] or 1) * scale * 0.5
	local radius = math.max(math.sqrt(halfX * halfX + halfZ * halfZ), 0.1)
	local minCenterY = radius + self.WORLD_FURNITURE_PLACE_CHECK_GROUND_GAP
	local maxCenterY = math.max(minCenterY, height - radius)
	local sampleStep = radius * 2
	local layerMask = self:getWorldFurniturePlaceOverlapLayerMask()
	local sampleY = minCenterY

	while sampleY < maxCenterY do
		local _, count = pg.global.physicsMgr:SphereOverlap(position + Vector3.constUp * sampleY, radius, layerMask, false)

		if count and count > 0 then
			return true
		end

		sampleY = sampleY + sampleStep
	end

	local _, count = pg.global.physicsMgr:SphereOverlap(position + Vector3.constUp * maxCenterY, radius, layerMask, false)

	return count and count > 0
end

function HomeSystem:buildWorldFurnitureOrnamentInfo(homeTemplateId, distance)
	local position, rotation, normal = self:getWorldFurniturePlaceTransform(distance)

	if not position or not rotation then
		return nil
	end

	return HomeLandUtils.fillOrnamentTransform({
		homeId = homeTemplateId,
		pos3 = Utils.positionToPos3(position)
	}, nil, rotation, Vector3.constOne), normal, position, rotation
end

function HomeSystem:placeWorldFurniture(homeTemplateId, distance)
	if pg.me.placedHomeTemplateId and pg.me.placedHomeTemplateId == homeTemplateId then
		pg.me:serverMsg("RPC_CS_RecycleWorldFurniture")

		return
	end

	local sceneId = SceneUtils.getMainSceneId(pg.me.space.sceneId)
	local sceneData = SceneData[sceneId] or {}

	if sceneData.canPlaceFurniture ~= Const.WORLD_FURNITURE.CAN_PLACE_FURNITURE then
		pg.global.showBubbleMessageById(NoticeDef.SPACE_FURNITURE_PLACE_SCENE_INVALID)

		return
	end

	if not homeTemplateId then
		pg.global.showBubbleMessageById(NoticeDef.SPACE_FURNITURE_PLACE_FAILED)

		return
	end

	local ornamentInfo, normal, position = self:buildWorldFurnitureOrnamentInfo(homeTemplateId, distance)

	if not ornamentInfo or not self:checkWorldFurniturePlaceAngle(normal) then
		pg.global.showBubbleMessageById(NoticeDef.SPACE_FURNITURE_PLACE_POSITION_INVALID)

		return
	end

	if self:checkWorldFurniturePlaceOverlap(homeTemplateId, position) then
		pg.global.showBubbleMessageById(NoticeDef.SPACE_FURNITURE_PLACE_POSITION_INVALID)

		return
	end

	pg.me:serverMsg("RPC_CS_PlaceWorldFurniture", ornamentInfo)
end

function HomeSystem:recycleWorldFurniture(callback)
	if not pg.me then
		if callback then
			callback(Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_PARAM)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_RecycleWorldFurniture", function(code)
		if pg.me and pg.me.showOrnamentNotice then
			pg.me:showOrnamentNotice(code)
		end

		if callback then
			callback(code)
		end
	end)
end

function HomeSystem:updateHomeEntity(ornamentId, ornamentInfo)
	local homeEntity = self.homeEntities[ornamentId]

	if homeEntity and homeEntity.isClientEnt then
		if ornamentInfo.homeId ~= homeEntity.homeTemplateId then
			self:destroyHomeEntityById(ornamentId)
			self:createHomeEntity(ornamentId, ornamentInfo)
		else
			local areaId = ornamentInfo.areaId
			local position = self:getWorldPosition(areaId, ornamentInfo:getPosition())
			local rotation = self:getWorldRotation(areaId, ornamentInfo:getRotation())
			local scale = ornamentInfo:getScale()

			homeEntity:forceSetPos(position)
			homeEntity:forceSetRot(rotation)

			if scale and homeEntity.setScale then
				homeEntity:setScale(scale)
			end

			if homeEntity.onEntityPositionChanged then
				homeEntity:onEntityPositionChanged()
			end
		end
	end

	self:refreshShadows()
end

function HomeSystem:refreshOrnamentShadow(position, bounds)
	if self.isDestroyingAll then
		return
	end

	pg.global.homelandMgr:RefreshShadow(position, bounds[1] + 0.1, bounds[2] + 0.1, 4)
end

function HomeSystem:destroyHomeEntityById(ornamentId)
	local homeEntity = self.homeEntities[ornamentId]

	if homeEntity and homeEntity.isClientEnt then
		ClientUtils.safeDestroy(homeEntity)
	end

	self:refreshShadows()
end

function HomeSystem:destroyHomeEntity(homeEntity)
	if homeEntity.isClientEnt then
		ClientUtils.safeDestroy(homeEntity)
	end

	self:refreshShadows()
end

function HomeSystem:updateHomeEntityInteractEffect()
	local curInteractEntId

	if not self.enableHomeCamera then
		curInteractEntId = pg.game.interaction.curChooseEntId
	end

	if self.curInteractEntId ~= curInteractEntId then
		if self.curInteractEntId then
			local oldEnt = pg.getEntity(self.curInteractEntId)

			if oldEnt and oldEnt.setInHomeInteract then
				oldEnt:setInHomeInteract(false)
			end
		end

		self.curInteractEntId = curInteractEntId

		if curInteractEntId then
			local ent = pg.getEntity(curInteractEntId)

			if ent and ent.setInHomeInteract then
				ent:setInHomeInteract(true)
			end
		end
	end
end

function HomeSystem:clearFastFindData()
	for _, fastFindMap in pairs(self.fastFindMapDict) do
		fastFindMap:clearFastFindInfo()
	end

	table.clear(self.ornamentAreaIdDict)
end

function HomeSystem:checkPetPosCollide(areaId, position, collideOrnaments)
	local fastFindMap = self:getFastFindMap(areaId)

	if not fastFindMap then
		if collideOrnaments then
			table.clear(collideOrnaments)
		end

		return false
	end

	local minX = position.x - 0.5
	local maxX = position.x + 0.5
	local minZ = position.z - 0.5
	local maxZ = position.z + 0.5

	fastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, self.tempCollideResult)

	for collideOrnamentId, fastInfo in pairs(self.tempCollideResult) do
		if not fastInfo.extraInfo.ent.visible then
			self.tempCollideResult[collideOrnamentId] = nil
		end
	end

	if collideOrnaments then
		table.clear(collideOrnaments)

		for collideOrnamentId, _ in pairs(self.tempCollideResult) do
			collideOrnaments[collideOrnamentId] = true
		end
	end

	return next(self.tempCollideResult) ~= nil
end

function HomeSystem:checkPosCollide(areaId, ornamentId, collideOrnaments, threshold)
	table.clear(collideOrnaments)

	local fastFindMap = self:getFastFindMap(areaId)

	if not fastFindMap then
		return false
	end

	local fastFindInfo = fastFindMap:getFastFindInfo(ornamentId)

	if not fastFindInfo then
		return false
	end

	local hBoundX, hBoundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = fastFindInfo.position.x - hBoundX
	local maxX = fastFindInfo.position.x + hBoundX
	local minZ = fastFindInfo.position.z - hBoundZ
	local maxZ = fastFindInfo.position.z + hBoundZ

	fastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, self.tempCollideResult, threshold)

	self.tempCollideResult[ornamentId] = nil

	local selfLayer = fastFindInfo.extraInfo.layer

	for collideOrnamentId, fastInfo in pairs(self.tempCollideResult) do
		if bit.band(selfLayer, fastInfo.extraInfo.layer) == 0 then
			self.tempCollideResult[collideOrnamentId] = nil
		elseif not fastInfo.extraInfo.ent.visible then
			self.tempCollideResult[collideOrnamentId] = nil
		end
	end

	if collideOrnaments then
		table.clear(collideOrnaments)

		for collideOrnamentId, _ in pairs(self.tempCollideResult) do
			collideOrnaments[collideOrnamentId] = true
		end
	end

	table.clear(self.tempCollideResult)

	return next(collideOrnaments) ~= nil
end

function HomeSystem:checkBoundsLock(areaId, position, rotation, boundSize)
	areaId = areaId or self.LOCK_ZONE_AREA_ID

	local boundX = boundSize[1]
	local boundZ = boundSize[2]

	if Utils.checkRotationIsVertical(rotation) then
		boundX = boundSize[2]
		boundZ = boundSize[1]
	end

	local left = position.x - boundX * 0.5
	local right = position.x + boundX * 0.5
	local bottom = position.z - boundZ * 0.5
	local top = position.z + boundZ * 0.5

	if self:checkLocalPointLock(areaId, left, bottom) then
		return true
	end

	if self:checkLocalPointLock(areaId, right, bottom) then
		return true
	end

	if self:checkLocalPointLock(areaId, left, top) then
		return true
	end

	if self:checkLocalPointLock(areaId, right, top) then
		return true
	end

	return false
end

function HomeSystem:checkLocalPointLock(areaId, localX, localZ)
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local hasZoneInArea = false

	for zoneId, zoneData in pairs(HomelandZoneUnlockConfigData) do
		if (zoneData.areaId or 0) == areaId then
			hasZoneInArea = true

			local x = zoneData.prefabPos[1] - self.zoneWidth * 0.5
			local y = zoneData.prefabPos[2] - self.zoneHeight * 0.5

			if pg.space.unlockZone[zoneId] and self:isPointInside(localX, localZ, x, y, self.zoneWidth, self.zoneHeight) then
				return false
			end
		end
	end

	return hasZoneInArea
end

function HomeSystem:checkPointLock(areaId, px, py)
	local shouldCheckAreaRange = areaId ~= nil

	areaId = areaId or self.LOCK_ZONE_AREA_ID

	if shouldCheckAreaRange and (not self.areaInfoDict or not self.areaInfoDict[areaId]) then
		return true
	end

	local localPos = self:getLocalPosition(areaId, Vector3(px, 0, py))

	if shouldCheckAreaRange then
		local areaRange = self:getAreaRange(areaId)

		if not areaRange or localPos.x < areaRange[1] or localPos.x > areaRange[2] or localPos.z < areaRange[3] or localPos.z > areaRange[4] then
			return true
		end
	end

	return self:checkLocalPointLock(areaId, localPos.x, localPos.z)
end

function HomeSystem:isPointInside(px, py, x, y, width, height)
	local epsilon = 0.01
	local left = x - epsilon
	local right = x + width + epsilon
	local bottom = y - epsilon
	local top = y + height + epsilon

	return left <= px and px <= right and bottom <= py and py <= top
end

function HomeSystem:getRandomUnlockPoint(areaId)
	areaId = areaId or self.LOCK_ZONE_AREA_ID

	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local unlockZoneList = ListPool.getList()

	for zoneId, zoneState in pairs(pg.space.unlockZone) do
		local zoneData = HomelandZoneUnlockConfigData[zoneId]

		if zoneState and zoneData and (zoneData.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE) == areaId then
			unlockZoneList[#unlockZoneList + 1] = zoneData
		end
	end

	if #unlockZoneList == 0 then
		ListPool.returnList(unlockZoneList)

		return false, 0, 0
	end

	local zoneData = unlockZoneList[math.random(1, #unlockZoneList)]
	local x = math.random((zoneData.prefabPos[1] - self.zoneWidth * 0.5) * 100, (zoneData.prefabPos[1] + self.zoneWidth * 0.5) * 100) / 100
	local y = math.random((zoneData.prefabPos[2] - self.zoneHeight * 0.5) * 100, (zoneData.prefabPos[2] + self.zoneHeight * 0.5) * 100) / 100

	ListPool.returnList(unlockZoneList)

	local worldPos = self:getWorldPosition(areaId, Vector3(x, 0, y))

	return true, worldPos.x, worldPos.z
end

function HomeSystem:onFacilityChanged(ornamentId, facilityInfo)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.setFacilityInfo then
		ornamentEnt:setFacilityInfo(facilityInfo)
	end
end

function HomeSystem:onFacilityAdded(ornamentId, facilityInfo)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.setFacilityInfo then
		ornamentEnt:setFacilityInfo(facilityInfo)
	end
end

function HomeSystem:onFacilityDeleted(ornamentId)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.setFacilityInfo then
		ornamentEnt:setFacilityInfo(nil)
	end
end

function HomeSystem:onAllocationChanged(petId, allocationInfo)
	local petEnt = pg.getEntity(petId)

	if petEnt and petEnt.setAllocationInfo then
		petEnt:setAllocationInfo(allocationInfo)
	end
end

function HomeSystem:onAllocationAdded(petId, allocationInfo)
	local petEnt = pg.getEntity(petId)

	if petEnt and petEnt.setAllocationInfo then
		petEnt:setAllocationInfo(allocationInfo)
	end
end

function HomeSystem:onAllocationDeleted(petId)
	local petEnt = pg.getEntity(petId)

	if petEnt and petEnt.setAllocationInfo then
		petEnt:setAllocationInfo(nil)
	end
end

function HomeSystem:onHomelandFacilityAllocateChanged(ornamentId)
	local homeEntity = self.homeEntities[ornamentId]

	if homeEntity and homeEntity.onFacilityAllocateChanged then
		homeEntity:onFacilityAllocateChanged()
	end
end

function HomeSystem:onFacilityProduceFinish(ornamentId)
	local homeEntity = self.homeEntities[ornamentId]

	if homeEntity and homeEntity.onFacilityProduceFinish then
		homeEntity:onFacilityProduceFinish()
	end
end

function HomeSystem:initLastPlayerAllocation(playerAllocation)
	self.lastPlayerAllocation = {}

	for playerId, allocationInfo in pairs(playerAllocation) do
		self.lastPlayerAllocation[playerId] = allocationInfo.ornamentId
	end
end

function HomeSystem:onPlayerAllocationChanged(playerId, allocationInfo)
	local playerEnt = pg.getEntity(playerId)

	if playerEnt and playerEnt.setAllocationInfo then
		playerEnt:setAllocationInfo(allocationInfo)
	end

	local lastAllocateOrnamentId = self.lastPlayerAllocation[playerId]

	if lastAllocateOrnamentId then
		local homeEntity = self.homeEntities[lastAllocateOrnamentId]

		if homeEntity and homeEntity.onFacilityAllocateChanged then
			homeEntity:onFacilityAllocateChanged()
		end
	end

	if allocationInfo then
		self.lastPlayerAllocation[playerId] = allocationInfo.ornamentId

		if lastAllocateOrnamentId ~= allocationInfo.ornamentId then
			local homeEntity = self.homeEntities[allocationInfo.ornamentId]

			if homeEntity and homeEntity.onFacilityAllocateChanged then
				homeEntity:onFacilityAllocateChanged()
			end
		end
	else
		self.lastPlayerAllocation[playerId] = nil
	end

	HomelandDemoCmdImplement._onPlayerAllocationChanged(playerId, allocationInfo)
end

function HomeSystem:onPlayerAllocationAdded(playerId, allocationInfo)
	self:onPlayerAllocationChanged(playerId, allocationInfo)
end

function HomeSystem:onPlayerAllocationDeleted(playerId)
	self:onPlayerAllocationChanged(playerId, nil)
end

function HomeSystem:onPlayerEnterSpace()
	HomelandDemoCmdImplement._onPlayerEnterHomeland()
end

function HomeSystem:tryShowChangeFormulaConfirm(ornamentId, okCallback)
	local facilityInfo = pg.space.facility[ornamentId]

	if not facilityInfo then
		return false
	end

	if Utils.checkReturnHomeProduceCost(facilityInfo) then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_RET_CONFIRM_DESC1"), okCallback)

		return true
	end

	return false
end

function HomeSystem:checkEnableHomePet()
	return pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.HOMELAND_PET)
end

function HomeSystem:checkEnableHomeSimulate()
	local carLevel = pg.me.homeBasicInfo.level

	return carLevel >= (HomelandConfigData.envSimulateLevel or 0)
end

function HomeSystem:tryShowRemoveFacilityConfirm(ornamentId, homeTemplateId, okCallback)
	if not pg.game.home.curDelFacilityConfirmHint then
		return false
	end

	local extraInfo = {
		hint = true,
		hintCb = function(isSelected)
			pg.game.home.curDelFacilityConfirmHint = not isSelected
		end
	}

	if homeTemplateId then
		local configData = HomeObjectData[homeTemplateId] or {}

		if configData and configData.subEntType == Const.HomelandEntSubType.HatchBox then
			local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

			if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
				pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HATCHING_PAUSE_CONFIRM"), okCallback, nil, nil, nil, nil, extraInfo)

				return true
			elseif hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
				pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HATED_PAUSE_CONFIRM"), okCallback, nil, nil, nil, nil, extraInfo)

				return true
			end
		end
	end

	local facilityInfo = pg.space.facility[ornamentId]

	if not facilityInfo then
		return false
	end

	local hasOutput = Utils.checkHasOutput(facilityInfo)
	local hasConsume = Utils.checkReturnHomeProduceCost(facilityInfo)

	if hasOutput and hasConsume then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_RET_CONFIRM_DESC2"), okCallback, nil, nil, nil, nil, extraInfo)

		return true
	elseif hasConsume then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_RET_CONFIRM_DESC1"), okCallback, nil, nil, nil, nil, extraInfo)

		return true
	elseif hasOutput then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_RET_CONFIRM_DESC3"), okCallback, nil, nil, nil, nil, extraInfo)

		return true
	end

	return false
end

function HomeSystem:checkShowRemoveFacilitiesConfirm(entities)
	if not pg.game.home.curDelFacilityConfirmHint then
		return false
	end

	for _, entity in pairs(entities) do
		local homeTemplateId = entity.homeTemplateId
		local ornamentId = entity.ornamentId

		if entity.originEntity then
			ornamentId = entity.originEntity.ornamentId
		end

		if homeTemplateId then
			local configData = HomeObjectData[homeTemplateId] or {}

			if configData and configData.subEntType == Const.HomelandEntSubType.HatchBox then
				local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

				if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
					return true
				elseif hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
					return true
				end
			end
		end

		local facilityInfo = pg.space.facility[ornamentId]

		if facilityInfo then
			local hasOutput = Utils.checkHasOutput(facilityInfo)
			local hasConsume = Utils.checkReturnHomeProduceCost(facilityInfo)

			if hasOutput and hasConsume then
				return true
			elseif hasConsume then
				return true
			elseif hasOutput then
				return true
			end
		end
	end

	return false
end

function HomeSystem:tryShowRemoveFacilitiesConfirm(entities, okCallback)
	if self:checkShowRemoveFacilitiesConfirm(entities) then
		local extraInfo = {
			hint = true,
			hintCb = function(isSelected)
				pg.game.home.curDelFacilityConfirmHint = not isSelected
			end
		}

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_MULTI_REMOVE_FACILITY_CONFIRM"), okCallback, nil, nil, nil, nil, extraInfo)

		return true
	end

	return false
end

function HomeSystem:getHomeEditorPlayerSetting(type, defaultValue)
	if self.editorPlayerSetting[type] == nil then
		local key = "EditorPlayerSetting_" .. type .. "_" .. pg.me.uid

		if type == ClientConst.HomelandEditorSetting.RotationAngle then
			self.editorPlayerSetting[type] = pg.global.prefsCacheUtils:getInt(key, defaultValue)
		else
			self.editorPlayerSetting[type] = pg.global.prefsCacheUtils:getBool(key, defaultValue)
		end
	end

	return self.editorPlayerSetting[type]
end

function HomeSystem:setHomeEditorPlayerSetting(type, info, editor)
	if self.editorPlayerSetting[type] ~= info then
		self.editorPlayerSetting[type] = info

		local key = "EditorPlayerSetting_" .. type .. "_" .. pg.me.uid

		if type == ClientConst.HomelandEditorSetting.RotationAngle then
			pg.global.prefsCacheUtils:setInt(key, info)
			facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_SETTING_REFRESH)
		else
			pg.global.prefsCacheUtils:setBool(key, info)

			if type == ClientConst.HomelandEditorSetting.GridDisplay then
				if editor and editor.isInBuildMode then
					local areaRange = editor:getAreaRange()

					editor:setGridEffectVisible(info, areaRange)

					if not info then
						editor:setAttachGridVisible(false)
					end
				end
			elseif type == ClientConst.HomelandEditorSetting.Overlook then
				if editor and editor.rootCameraMode then
					editor.rootCameraMode.editorCamera:setOverlookMode(info)
				end
			elseif type == ClientConst.HomelandEditorSetting.ThreeAxisRotation or type == ClientConst.HomelandEditorSetting.ThreeAxisScaling then
				facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_SETTING_REFRESH)
			elseif type == ClientConst.HomelandEditorSetting.AutoAttach and editor and editor.buildAttachManager then
				editor.buildAttachManager:setEnableBuildAttach(info)
			end
		end
	end
end

function HomeSystem:getHomeEditorOrnamentFilter(filterType)
	return self.ornamentFilterInfo[filterType] or false
end

function HomeSystem:setHomeEditorOrnamentFilter(filterType, isHide)
	if self.ornamentFilterInfo[filterType] ~= isHide then
		self.ornamentFilterInfo[filterType] = isHide

		for ornamentId, homeEntity in pairs(self.homeEntities) do
			homeEntity:onHomeEditorFilterChange(filterType)
		end

		for ornamentId, homeEntity in pairs(self.virtualHomeEntities) do
			homeEntity:onHomeEditorFilterChange(filterType)
		end

		self:updateEffectVisibleInfo()
	end
end

function HomeSystem:updateEffectVisibleInfo()
	if self.ornamentFilterInfo[ClientConst.OrnamentFilterType.Electric] then
		self:setLinkEffectVisible(false)
	else
		self:setLinkEffectVisible(true)
	end
end

function HomeSystem:onEditorEnvLinkChange()
	for ornamentId, homeEntity in pairs(self.homeEntities) do
		homeEntity:onEditorEnvLinkChange()
	end

	for ornamentId, homeEntity in pairs(self.virtualHomeEntities) do
		homeEntity:onEditorEnvLinkChange()
	end
end

function HomeSystem:showEditorFitRecommendEffect()
	for ornamentId, homeEntity in pairs(self.homeEntities) do
		if homeEntity.showEditorFitRecommendEffect then
			homeEntity:showEditorFitRecommendEffect()
		end
	end
end

function HomeSystem:checkHomePetWorkState()
	for petEntId, _ in pairs(pg.space.pets) do
		local petEnt = pg.getEntity(petEntId)

		if petEnt and petEnt.checkAIHomeWorkState then
			petEnt:checkAIHomeWorkState()
		end
	end
end

function HomeSystem:updateHatchBox(ornamentId)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.updateHatchBox then
		ornamentEnt:updateHatchBox()
	end
end

function HomeSystem:driveHatchBoxPlayEffect(ornamentId, effectName, offsetH)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.playHatchBoxEffect then
		ornamentEnt:playHatchBoxEffect(effectName, offsetH)
	end
end

function HomeSystem:getHatchBoxRecommendEnvInfoTL(ornamentId)
	local ornamentEnt = self:getHomeEntity(ornamentId)

	if ornamentEnt and ornamentEnt.getOrnamentEnvInfo then
		local envInfo = ornamentEnt:getOrnamentEnvInfo()

		return envInfo.temperature or 0, envInfo.light
	end

	return 0, 0
end

function HomeSystem:registerSynWorkEffectFacility(ornamentId, ent)
	self.syncWorkEffectFacilities[ornamentId] = ent
end

function HomeSystem:unRegisterSynWorkEffectFacility(ornamentId, ent)
	if self.syncWorkEffectFacilities[ornamentId] == ent then
		self.syncWorkEffectFacilities[ornamentId] = nil
	end
end

function HomeSystem:registerShadowLight(ornamentId, ent)
	self.lightShadowScheduler:register(ornamentId, ent)
end

function HomeSystem:unregisterShadowLight(ornamentId)
	self.lightShadowScheduler:unregister(ornamentId)
end

function HomeSystem:markShadowLightDirty()
	self.lightShadowScheduler:markDirty()
end

function HomeSystem:doSyncWorkEffectFacilities()
	for ornamentId, ent in pairs(self.syncWorkEffectFacilities) do
		ent:syncWorkEffectTime()
	end
end

function HomeSystem:onMutiSelectEntityDestroy()
	self.editor:onMutiSelectEntityDestroy()
end

function HomeSystem:setEnableDebugInfo(debugType, enable)
	self.enableDebugInfo[debugType] = enable
end

function HomeSystem:getEnableDebugInfo(debugType)
	if self.enableDebugInfo[debugType] ~= nil then
		return self.enableDebugInfo[debugType]
	end

	return ClientConst.HomelandDebugDefault[debugType]
end

function HomeSystem:setSrcEntityLinkPresetFilter(presetType)
	self.srcEntityLinkPresetFilter = presetType
end

function HomeSystem:getSrcEntityLinkPresetFilter()
	return self.srcEntityLinkPresetFilter
end

function HomeSystem:setSrcEntityLinkDirFilter(dirType)
	self.srcEntityLinkDirFilter = dirType
end

function HomeSystem:getSrcEntityLinkDirFilter()
	return self.srcEntityLinkDirFilter
end

function HomeSystem:scanTrashData()
	local HomeTrashData = HomeLandUtils.getHomelandTrashData()

	for trashId, trashInfo in pairs(HomeTrashData) do
		local trashPos = trashInfo.position
		local trashX, trashZ = trashPos[1], trashPos[2]
		local zoneId = self:getPosZoneId(trashX, trashZ)

		if zoneId ~= trashInfo.landId then
			print("dxk trash invalid", trashId, zoneId)
		end
	end
end

function HomeSystem:getPosZoneId(x, z)
	for zoneId, zoneData in pairs(HomelandZoneUnlockConfigData) do
		local prefabPos = zoneData.prefabPos

		if math.abs(prefabPos[1] - x) < Const.HomelandZoneWidth * 0.5 and math.abs(prefabPos[2] - z) < Const.HomelandZoneHeight * 0.5 then
			return zoneId
		end
	end

	return nil
end

function HomeSystem:cullGrassForOrnament(ornamentId, position, rotation, boundSize, areaId)
	if not pg.space or not pg.space:isHomeland() then
		return
	end

	local info = self.grassCullMap[ornamentId]

	if info then
		pg.global.homelandMgr:AcquireCullMapGrass(false, info.bounds, info.rotation, info.height, Vector3.constOne, ornamentId)
	else
		info = {
			height = 0,
			bounds = Vector4(0, 0, 0, 0),
			rotation = Quaternion(0, 0, 0, 1)
		}
		self.grassCullMap[ornamentId] = info
	end

	info.bounds:Set(position.x, position.z, boundSize[1] * 0.5, boundSize[2] * 0.5)
	info.rotation:SetEuler(0, rotation:GetEulerAnglesY(), 0)
	Vector3.enableCreateFromCache()

	info.height = self:getLocalPosition(areaId, position).y

	Vector3.disableCreateFromCache()
	pg.global.homelandMgr:AcquireCullMapGrass(true, info.bounds, info.rotation, info.height, Vector3.constOne, ornamentId)
end

function HomeSystem:restoreGrassForOrnament(ornamentId)
	local info = self.grassCullMap[ornamentId]

	if info then
		pg.global.homelandMgr:AcquireCullMapGrass(false, info.bounds, info.rotation, info.height, Vector3.constOne, ornamentId)

		self.grassCullMap[ornamentId] = nil
	end
end

function HomeSystem:restoreAllGrass()
	for ornamentId, info in pairs(self.grassCullMap) do
		pg.global.homelandMgr:AcquireCullMapGrass(false, info.bounds, info.rotation, info.height, Vector3.constOne, ornamentId)
	end

	self.grassCullMap = {}
end

function HomeSystem:cullGrassForEntity(ornamentId, ent)
	if ent.isHomeTrash then
		return
	end

	local px, py, pz = ent.eModel:GetPositionAgentPosEx()
	local rx, ry, rz, rw = ent.eModel:GetPositionAgentRotationEx()
	local _sx, _sy, _sz = ent.eModel:GetPositionAgentLocalScaleEx()
	local configBoundSize = ent:getBoundSize()
	local boundSize = {
		configBoundSize[1],
		configBoundSize[2]
	}
	local areaId = self.ornamentAreaIdDict[ornamentId] or self:getOrnamentAreaId(ent)

	self.grassCullPositionCache:Set(px, py, pz)
	self.grassCullRotationCache:refreshReadOnly(rx, ry, rz, rw)
	self:cullGrassForOrnament(ornamentId, self.grassCullPositionCache, self.grassCullRotationCache, boundSize, areaId)
end

function HomeSystem:cullGrassForAllOrnaments()
	self:restoreAllGrass()

	for ornamentId, homeEntity in pairs(self.homeEntities) do
		self:cullGrassForEntity(ornamentId, homeEntity)
	end
end

return HomeSystem
