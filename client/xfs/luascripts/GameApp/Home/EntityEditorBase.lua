-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\EntityEditorBase.lua

local Class = require("Core.Framework.Class")
local EntityEditorHistory = require("GameApp.Home.EntityEditorHistory")
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils
local PositionOper = require("GameApp.Home.HomeEdtorOper.PositionOper")
local RotationOper = require("GameApp.Home.HomeEdtorOper.RotationOper")
local ExtendOper = require("GameApp.Home.HomeEdtorOper.ExtendOper")
local ScaleOper = require("GameApp.Home.HomeEdtorOper.ScaleOper")
local ClientConst = require("Const.ClientConst")
local HomeCameraGroupMode = require("GameApp.Camera.CameraMode.HomeCamera.HomeCameraGroupMode")
local CameraConst = require("GameApp.Camera.CameraConst")
local TimerManager = require("Core.Timer.TimerManager")
local HomelandConfigData = require("Data.homeland_config_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local EffectConst = require("Const.EffectConst")
local AddressDataConst = require("Const.AddressDataConst")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local HomeObjectData = require("Data.home_object_data")
local HomeEditorOutline = require("GameApp.Home.HomeEditorOutline")
local EntityEditorBase = Class.LiteClass("EntityEditorBase")

EntityEditorBase.GRID_ADSORPTION_EPSILON = 0.0001

function EntityEditorBase:ctor()
	self.targetEntity = nil
	self.templateEntity = nil
	self.editType = ClientConst.EntityEditType.None
	self.placeConfig = {}
	self.isInEditMode = false
	self.confirmCallback = nil
	self.editState = {}
	self.multiSelectEntities = {}
	self.multiSelectList = {}
	self.editingOriginEntities = {}
	self.editingEntities = {}
	self.tempEditingEntities = {}
	self.tempRaycastHitEntities = {}
	self.tempRaycastHitPoints = {}
	self.tempHeightHideEntityMap = {}
	self.tempHeightHideVisibleMap = {}
	self.tempHeightHideResolvingMap = {}
	self.cameraFocusCache = Vector3.ForceNew(0, 0, 0)
	self.cameraForwardCache = Vector3.ForceNew(0, 0, 0)
	self.lastCameraFocusCache = Vector3.ForceNew(0, 0, 0)
	self.lastCameraForwardCache = Vector3.ForceNew(0, 0, 0)
	self.hasLastCameraFocus = false
	self.displayHideMode = 0
	self.cameraHeightLimit = 0

	self:initEditorCamera()

	self.areaRange = self:getAreaRange()
	self.yAxisRange = self:getYAreaRange()
	self.history = EntityEditorHistory.new(30)
end

function EntityEditorBase:setBaseTransMatrix(transMatrix)
	if transMatrix then
		self.baseTransMatrix = transMatrix
		self.baseTransMatrixInv = transMatrix.inverse
		self.baseRotation = transMatrix.rotation
		self.baseRotationInv = self.baseRotation:Inverse()
	else
		self.baseTransMatrix = nil
		self.baseTransMatrixInv = nil
		self.baseRotation = nil
		self.baseRotationInv = nil
	end
end

function EntityEditorBase:setEditArea(areaId)
	areaId = areaId or 0
	self.areaId = areaId
	self.areaRange = self:getAreaRange()
	self.yAxisRange = self:getYAreaRange()
end

function EntityEditorBase:getAreaRange()
	return {
		-20,
		20,
		-20,
		20
	}
end

function EntityEditorBase:getYAreaRange()
	return {
		0,
		15
	}
end

function EntityEditorBase:getDefaultRotation()
	return Quaternion.identity
end

function EntityEditorBase:setBuildAttachManager(buildAttachManager)
	if self.buildAttachManager ~= buildAttachManager then
		if self.buildAttachManager then
			self.buildAttachManager:clearEditorInfo()
		end

		self.buildAttachManager = buildAttachManager
	end
end

function EntityEditorBase:clear()
	self:exitBuildMode()
end

function EntityEditorBase:setEditingOriginEntities(entities)
	for _, hideEntity in pairs(self.editingOriginEntities) do
		if not hideEntity.destroyed then
			hideEntity:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOMELAND_EDIT, true, true)
		end
	end

	self:restoreEditOriginEntities(self.editingOriginEntities)
	table.clear(self.editingOriginEntities)

	if entities then
		for _, entity in pairs(entities) do
			table.insert(self.editingOriginEntities, entity)
			entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOMELAND_EDIT, false, true)
		end
	end

	self:handleEditOriginEntities(self.editingOriginEntities)
end

function EntityEditorBase:setEditingOriginEntity(entity)
	for _, hideEntity in pairs(self.editingOriginEntities) do
		if not hideEntity.destroyed then
			hideEntity:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOMELAND_EDIT, true, true)
		end
	end

	self:restoreEditOriginEntities(self.editingOriginEntities)
	table.clear(self.editingOriginEntities)

	if entity then
		table.insert(self.editingOriginEntities, entity)
		entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOMELAND_EDIT, false, true)
	end

	self:handleEditOriginEntities(self.editingOriginEntities)
end

function EntityEditorBase:restoreEditOriginEntities(entities)
	return
end

function EntityEditorBase:handleEditOriginEntities(entities)
	return
end

function EntityEditorBase:updateEditingEntities()
	table.clear(self.tempEditingEntities)

	if self.templateEntity then
		self.tempEditingEntities[self.templateEntity.id] = self.templateEntity

		if self.templateEntity.getChildEntities then
			self.templateEntity:getChildEntities(self.tempEditingEntities)
		end
	end

	local changed = false

	for id, entity in pairs(self.tempEditingEntities) do
		if self.editingEntities[id] ~= entity then
			self.editingEntities[id] = entity
			changed = true
		end
	end

	for id, entity in pairs(self.editingEntities) do
		if not self.tempEditingEntities[id] then
			self.editingEntities[id] = nil
			changed = true
		end
	end

	if changed and self.buildAttachManager then
		self.buildAttachManager:setEditVirtualEntities(self.editingEntities)
	end
end

function EntityEditorBase:tickEditor()
	self:checkAndUpdateMultiSelectEntity()

	if self.isInBuildMode then
		self:onTick()
		self:tickHeightHideByCamera()
	end
end

function EntityEditorBase:tickHeightHideByCamera()
	if self.displayHideMode ~= 1 then
		return
	end

	local focus, forward = self:getCameraFocusInfo()

	if not focus then
		return
	end

	if self.hasLastCameraFocus then
		local dPosX = focus.x - self.lastCameraFocusCache.x
		local dPosY = focus.y - self.lastCameraFocusCache.y
		local dPosZ = focus.z - self.lastCameraFocusCache.z
		local dFwdX = forward.x - self.lastCameraForwardCache.x
		local dFwdY = forward.y - self.lastCameraForwardCache.y
		local dFwdZ = forward.z - self.lastCameraForwardCache.z

		if dPosX * dPosX + dPosY * dPosY + dPosZ * dPosZ < 0.0001 and dFwdX * dFwdX + dFwdY * dFwdY + dFwdZ * dFwdZ < 0.0001 then
			return
		end
	end

	self.lastCameraFocusCache:Copy(focus)
	self.lastCameraForwardCache:Copy(forward)

	self.hasLastCameraFocus = true

	self:refreshHeightHide()
end

function EntityEditorBase:getEntityMaxPlaceNum(templateId)
	return nil
end

function EntityEditorBase:getEntityCurPlaceNum(templateId)
	return nil
end

function EntityEditorBase:confirm(callback)
	self.confirmCallback = callback

	self:applyTemplateData()

	if not self.confirmCallback then
		self:finishEdit()
	end
end

function EntityEditorBase:withdrawEnt()
	return
end

function EntityEditorBase:withdrawMultiSelectEntities()
	return
end

function EntityEditorBase:cancelCallback()
	self.confirmCallback = nil
end

function EntityEditorBase:onFinishCallback(isSucc, operationType)
	if isSucc then
		local confirmCallback = self.confirmCallback

		if confirmCallback then
			confirmCallback(operationType)
		else
			self:finishEdit()
		end
	end
end

function EntityEditorBase:clearEditor()
	if self.refreshShadowTimer then
		TimerManager.removeTimer(self.refreshShadowTimer)

		self.refreshShadowTimer = nil
	end

	self:finishEdit()
end

function EntityEditorBase:beforeEdit()
	self:finishEdit()
end

function EntityEditorBase:finishEdit()
	self:clearHistory()
	self:cancelCallback()
	self:destroyTemplateObject(self.templateEntity)

	self.templateEntity = nil

	self:setEditingOriginEntities(nil)

	self.placeConfig = {}
	self.cachedScale = nil

	self:setInEditMode(false)

	if self.displayHideMode ~= 0 then
		self:refreshHeightHide()
	end
end

function EntityEditorBase:setInEditMode(isInEditMode, editType)
	if self.isInEditMode ~= isInEditMode then
		self.isInEditMode = isInEditMode

		self:onEditModeChanged(isInEditMode)
	end

	self:updateEditingEntities()

	editType = editType or ClientConst.EntityEditType.None

	if self.editType ~= editType then
		self.editType = editType
	end
end

function EntityEditorBase:destroyTemplateObject(templateEntity)
	if not templateEntity then
		return
	end

	ClientUtils.safeDestroy(templateEntity)
end

function EntityEditorBase:getLocalPosition(position)
	if self.baseTransMatrixInv then
		return self.baseTransMatrixInv:MultiplyPoint(position)
	end

	return position
end

function EntityEditorBase:getLocalRotation(rotation)
	if self.baseRotationInv then
		return self.baseRotationInv * rotation
	end

	return rotation
end

function EntityEditorBase:getWorldPosition(position)
	if self.baseTransMatrix then
		return self.baseTransMatrix:MultiplyPoint(position)
	end

	return position
end

function EntityEditorBase:getBaseY()
	if self.baseTransMatrix then
		return self.baseTransMatrix:GetPosition().y
	end
end

function EntityEditorBase:getWorldRotation(rotation)
	if self.baseRotation then
		return self.baseRotation * rotation
	end

	return rotation
end

function EntityEditorBase:clearHistory()
	self.history:clearHistory()

	self.inDraggingYPos = false
	self.positionDirty = false
	self.inDraggingPos = false
	self.posOper = nil
	self.rotOper = nil
	self.deltaPosOper = nil
	self.extendOper = nil
	self.scaleOper = nil
	self.cachedEulerAngles = nil
end

function EntityEditorBase:startEdit(targetEntity, placeConfig)
	self:beforeEdit()

	self.placeConfig = placeConfig

	self:doStartEdit(targetEntity)
end

function EntityEditorBase:startEditMulti(targetEntities, placeConfig)
	self:beforeEdit()

	self.placeConfig = placeConfig

	self:doStartEditMulti(targetEntities)
end

function EntityEditorBase:startEditNew(templateId, entityData, initInfo, placeConfig)
	self:beforeEdit()

	self.entityData = entityData
	self.placeConfig = placeConfig or {}

	self:doStartEditNew(templateId, entityData, initInfo)
end

function EntityEditorBase:doStartEdit(targetEntity)
	self:setEditingOriginEntity(targetEntity)

	self.templateEntity = self:createTemplateObjectByTarget(targetEntity)

	self:setInEditMode(true, ClientConst.EntityEditType.Update)
	self:onStartEditEntity()
end

function EntityEditorBase:doStartEditMulti(targetEntities)
	self:setEditingOriginEntities(targetEntities)

	self.templateEntity = self:createTemplateMultiEditObject(targetEntities)

	self:setInEditMode(true, ClientConst.EntityEditType.Update)
	self:onStartEditEntity()
end

function EntityEditorBase:doStartEditNew(templateId, entityData, initInfo)
	self.templateEntity = self:createTemplateObjectNew(templateId, entityData, initInfo)

	self:setInEditMode(true, ClientConst.EntityEditType.Create)
	self:onStartEditEntity()
end

function EntityEditorBase:moveCameraToEditEntity(ent)
	ent = ent or self.templateEntity

	if not ent then
		return
	end

	local _px, _, _pz = ent.eModel:GetPositionAgentPosEx()
	local position = Vector3.New(_px, 0, _pz)

	self.rootCameraMode.editorCamera:setPosition(position)
end

function EntityEditorBase:getCameraDistanceRange()
	return {
		10,
		50
	}
end

function EntityEditorBase:getCameraSpeedRange()
	return {
		2,
		20
	}
end

function EntityEditorBase:getCameraFov()
	return 25
end

function EntityEditorBase:getCameraRotation()
	return self.rootCameraMode.editorCamera:getRotationDir()
end

function EntityEditorBase:showConfirmEffect()
	return
end

function EntityEditorBase:onStartDragTemplate(screenPos, useRaycastDrag, rayCastRootOffset)
	if self.inDraggingYPos then
		return
	end

	self.positionDirty = false

	local startDragTemplatePos = self.templateEntity:getPosition():Clone()
	local templateScreenPosVec3 = UIUtils.GetPositionScreenPoint(startDragTemplatePos)
	local templateScreenPos = Vector2(templateScreenPosVec3.x, templateScreenPosVec3.y)

	self.startDragTemplatePos = startDragTemplatePos
	self.inDraggingPos = true
	self.useRaycastDrag = useRaycastDrag
	self.rayCastRootOffset = rayCastRootOffset

	if useRaycastDrag then
		if rayCastRootOffset then
			local startDragRaycastRootScreenPosVec3 = UIUtils.GetPositionScreenPoint(startDragTemplatePos - rayCastRootOffset)
			local startDragRaycastRootScreenPos = Vector2(startDragRaycastRootScreenPosVec3.x, startDragRaycastRootScreenPosVec3.y)

			self.startDragRaycastRootScreenPos = startDragRaycastRootScreenPos
			self.raycastDragPositionDiff = screenPos - startDragRaycastRootScreenPos
		else
			self.raycastDragPositionDiff = screenPos - templateScreenPos
		end
	end

	self.dragPositionDiff = screenPos - templateScreenPos

	self:moveTo(true, self.startDragTemplatePos)

	return true
end

function EntityEditorBase:getScreenCastPosition(screenPosition, yBase, raycastScreenPos)
	local y = 0

	if yBase then
		y = yBase
	elseif self.baseTransMatrix then
		y = self.baseTransMatrix:GetPosition().y
	end

	if self.useRaycastDrag and raycastScreenPos then
		local valid, resultPosition = self:getRaycastSurfacePosition(raycastScreenPos)

		if valid then
			if self.rayCastRootOffset then
				resultPosition = resultPosition - self.rayCastRootOffset
			end

			return true, resultPosition
		end
	end

	local valid, resultPosition = HomeEditorUtils.GetRaycastPlacePosition(screenPosition, y)

	return valid, resultPosition
end

function EntityEditorBase:getRaycastSurfacePosition(screenPosition)
	local hitEntities = self.tempRaycastHitEntities
	local hitPoints = self.tempRaycastHitPoints

	table.clear(hitEntities)
	table.clear(hitPoints)
	HomeEditorUtils.GetRaycastHitHomeEntitiesWithPoint(screenPosition, 300, hitEntities, hitPoints)

	for i, ent in ipairs(hitEntities) do
		if self:isValidRaycastSurfaceEntity(ent) then
			return true, hitPoints[i]
		end
	end

	return false, nil
end

function EntityEditorBase:isValidRaycastSurfaceEntity(ent)
	if not ent or ent.destroyed then
		return false
	end

	local ornamentId = ent.ornamentId

	if not ornamentId or ornamentId < 0 then
		return false
	end

	if self.editingEntities[ent.id] then
		return false
	end

	if ent.visible == false then
		return false
	end

	return true
end

function EntityEditorBase:onDraggingTemplate(screenPos)
	if not self.inDraggingPos then
		return
	end

	local yBase

	if self.startDragTemplatePos then
		yBase = self.startDragTemplatePos.y
	end

	local baseScreenPos = screenPos - self.dragPositionDiff
	local raycastScreenPos

	if self.useRaycastDrag then
		raycastScreenPos = screenPos - self.raycastDragPositionDiff
	end

	local valid, placePos = self:getScreenCastPosition(baseScreenPos, yBase, raycastScreenPos)

	if valid then
		self.positionDirty = true

		self:moveTo(false, placePos)
	end
end

function EntityEditorBase:onFinishDragTemplate(screenPos)
	if not self.inDraggingPos then
		return
	end

	if not self.positionDirty then
		return
	end

	self.history:push(self.posOper)

	self.posOper = nil
	self.dragPositionDiff = nil
	self.startDragTemplatePos = nil
	self.inDraggingPos = false
end

function EntityEditorBase:onStartDragYAxis(screenPos)
	if self.inDraggingPos then
		return
	end

	self.startDragTemplatePos = self.templateEntity:getPosition():Clone()

	local yValue = HomeEditorUtils.GetYAxisValue(screenPos, self.templateEntity:getPosition())

	self.inDraggingYPos = true

	local templateStartYValue = self.templateEntity:getPosition().y
	local yDiff = yValue - templateStartYValue

	self.dragYDiff = yDiff

	self:moveTo(true, self.startDragTemplatePos)

	return true
end

function EntityEditorBase:onDraggingYAxis(screenPos)
	if not self.inDraggingYPos then
		return
	end

	local yValue = HomeEditorUtils.GetYAxisValue(screenPos, self.templateEntity:getPosition())
	local moveYValue = yValue - self.dragYDiff

	self.positionYDirty = true

	local curPosition = self.templateEntity:getPositionClone()

	curPosition.y = moveYValue

	self:moveTo(false, curPosition)
end

function EntityEditorBase:onFinishDraggingYAxis(screenPos)
	if not self.inDraggingYPos then
		return
	end

	if not self.positionYDirty then
		return
	end

	self.history:push(self.posOper)

	self.posOper = nil
	self.dragYDiff = nil
	self.inDraggingYPos = false
end

function EntityEditorBase:setRotateOffset(rotation)
	local offsetRotOper = RotationOper.new(self)

	offsetRotOper:setOperTarget(self.templateEntity)
	offsetRotOper:doRotate(rotation)
	self.history:push(offsetRotOper)
	self:setCachedEulerAngles(rotation.x, rotation.y, rotation.z)
end

function EntityEditorBase:getCachedEulerAngles()
	if not self.cachedEulerAngles and self.templateEntity then
		local euler = self:getLocalRotation(self.templateEntity:getRotation()).eulerAngles

		self.cachedEulerAngles = {
			x = math.round(euler.x),
			y = math.round(euler.y),
			z = math.round(euler.z)
		}
	end

	return self.cachedEulerAngles
end

function EntityEditorBase:getBlueprintBuildGroupYawAngleDelta()
	if not self.templateEntity then
		return 0
	end

	local localYaw = Utils.normalizeAngle(math.deg(self:getLocalRotation(self.templateEntity:getRotation()):ToYaw()))
	local defaultYaw = Utils.normalizeAngle(math.deg(self:getDefaultRotation():ToYaw()))
	local currentYawAngle = Utils.yawToYawAngleInt(Utils.normalizeAngle(localYaw - defaultYaw))
	local initialYawAngle = self.placeConfig and self.placeConfig.homeBlueprintGroupInitialYawAngle or 0

	return (currentYawAngle - initialYawAngle) % 36000
end

function EntityEditorBase:setCachedEulerAngles(x, y, z)
	self.cachedEulerAngles = {
		x = x,
		y = y,
		z = z
	}
end

function EntityEditorBase:moveTo(createNewRecord, targetPosition)
	if createNewRecord or not self.posOper then
		self.posOper = PositionOper.new(self)

		self.posOper:setOperTarget(self.templateEntity)
	end

	self.posOper:doMove(targetPosition)
end

function EntityEditorBase:doExtend(extendValue)
	if not self.extendOper then
		self.extendOper = ExtendOper.new(self)

		self.extendOper:setOperTarget(self.templateEntity)
	end

	self.extendOper:setExtend(extendValue)
end

function EntityEditorBase:clampPosition(position, editEntityRange, floorLiftTemplateId)
	position = self:getLocalPosition(position)

	return self:getWorldPosition(self:innerClampLocalPosition(position, editEntityRange, nil, floorLiftTemplateId))
end

function EntityEditorBase:clampLocalPosition(position, gridAdsorptionOrigin)
	return self:innerClampLocalPosition(position, nil, gridAdsorptionOrigin, self.templateEntity and self.templateEntity.homeTemplateId)
end

function EntityEditorBase:checkEditAreaInRange(localPosition, minX, maxX, minZ, maxZ)
	local areaRange = self.areaRange

	minX = minX + localPosition.x
	maxX = maxX + localPosition.x
	minZ = minZ + localPosition.z
	maxZ = maxZ + localPosition.z

	if areaRange then
		return minX >= areaRange[1] and maxX <= areaRange[2] and minZ >= areaRange[3] and maxZ <= areaRange[4]
	end

	return true
end

function EntityEditorBase:checkEditAreaInRangeWithY(localPosition, minX, maxX, minZ, maxZ, minY, maxY)
	if not self:checkEditAreaInRange(localPosition, minX, maxX, minZ, maxZ) then
		return false
	end

	if not minY and not maxY then
		return true
	end

	local yRange = self.yAxisRange

	if not yRange then
		return true
	end

	local worldMinY = localPosition.y + (minY or 0)
	local worldMaxY = localPosition.y + (maxY or 0)

	return worldMinY >= yRange[1] and worldMaxY <= yRange[2]
end

function EntityEditorBase:getBoundAreaRange()
	if self.templateEntity then
		return self.templateEntity:getBoundAreaRange()
	end

	return -0.5, 0.5, -0.5, 0.5, 0, 1
end

function EntityEditorBase:innerClampLocalPosition(position, customAreaRange, gridAdsorptionOrigin, floorLiftTemplateId)
	local resultPosition = position:Clone()
	local gridAdsorption = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.GridAdsorption, true)
	local useRelativeGridAdsorption = gridAdsorption and gridAdsorptionOrigin ~= nil

	if gridAdsorption then
		if useRelativeGridAdsorption then
			resultPosition.x = gridAdsorptionOrigin.x + Utils.convertToGridValue(position.x - gridAdsorptionOrigin.x, Const.HOMELAND_GRID_SIZE)
			resultPosition.z = gridAdsorptionOrigin.z + Utils.convertToGridValue(position.z - gridAdsorptionOrigin.z, Const.HOMELAND_GRID_SIZE)
		else
			resultPosition.x = Utils.convertToGridValue(position.x, Const.HOMELAND_GRID_SIZE)
			resultPosition.z = Utils.convertToGridValue(position.z, Const.HOMELAND_GRID_SIZE)
		end
	end

	local areaRange = self.areaRange

	if areaRange then
		local minX, maxX, minZ, maxZ, minY, maxY = self:getBoundAreaRange()

		if customAreaRange then
			minX, maxX, minZ, maxZ = customAreaRange[1], customAreaRange[2], customAreaRange[3], customAreaRange[4]
		end

		local positionMinX = areaRange[1] - minX
		local positionMaxX = areaRange[2] - maxX
		local positionMinZ = areaRange[3] - minZ
		local positionMaxZ = areaRange[4] - maxZ

		if useRelativeGridAdsorption then
			local minGridCountX = math.ceil((positionMinX - gridAdsorptionOrigin.x) / Const.HOMELAND_GRID_SIZE - EntityEditorBase.GRID_ADSORPTION_EPSILON)
			local maxGridCountX = math.floor((positionMaxX - gridAdsorptionOrigin.x) / Const.HOMELAND_GRID_SIZE + EntityEditorBase.GRID_ADSORPTION_EPSILON)
			local minGridCountZ = math.ceil((positionMinZ - gridAdsorptionOrigin.z) / Const.HOMELAND_GRID_SIZE - EntityEditorBase.GRID_ADSORPTION_EPSILON)
			local maxGridCountZ = math.floor((positionMaxZ - gridAdsorptionOrigin.z) / Const.HOMELAND_GRID_SIZE + EntityEditorBase.GRID_ADSORPTION_EPSILON)

			if minGridCountX <= maxGridCountX then
				local gridCountX = math.round((position.x - gridAdsorptionOrigin.x) / Const.HOMELAND_GRID_SIZE)

				gridCountX = math.clamp(gridCountX, minGridCountX, maxGridCountX)
				resultPosition.x = gridAdsorptionOrigin.x + gridCountX * Const.HOMELAND_GRID_SIZE
			else
				resultPosition.x = math.clamp(resultPosition.x, positionMinX, positionMaxX)
			end

			if minGridCountZ <= maxGridCountZ then
				local gridCountZ = math.round((position.z - gridAdsorptionOrigin.z) / Const.HOMELAND_GRID_SIZE)

				gridCountZ = math.clamp(gridCountZ, minGridCountZ, maxGridCountZ)
				resultPosition.z = gridAdsorptionOrigin.z + gridCountZ * Const.HOMELAND_GRID_SIZE
			else
				resultPosition.z = math.clamp(resultPosition.z, positionMinZ, positionMaxZ)
			end
		else
			resultPosition.x = math.clamp(resultPosition.x, positionMinX, positionMaxX)
			resultPosition.z = math.clamp(resultPosition.z, positionMinZ, positionMaxZ)
		end

		if minY and maxY then
			resultPosition.y = math.clamp(resultPosition.y, self.yAxisRange[1] - minY, self.yAxisRange[2] - maxY)
		end
	end

	if not self.placeConfig.freeYAxis then
		resultPosition.y = self:getFloorLiftLocalY(resultPosition, floorLiftTemplateId)
	else
		if self.placeConfig.yAxisUnit then
			resultPosition.y = math.round(resultPosition.y / self.placeConfig.yAxisUnit) * self.placeConfig.yAxisUnit
		end

		resultPosition.y = math.clamp(resultPosition.y, self.yAxisRange[1], self.yAxisRange[2])
	end

	if not useRelativeGridAdsorption then
		resultPosition.x = math.round(resultPosition.x * 100) / 100
		resultPosition.z = math.round(resultPosition.z * 100) / 100
	end

	resultPosition.y = math.round(resultPosition.y * 100) / 100

	return resultPosition
end

function EntityEditorBase:endExtend()
	if self.extendOper then
		self.history:push(self.extendOper)

		self.extendOper = nil
	end
end

function EntityEditorBase:setScaleValue(scaleXYZ)
	local scaleOper = ScaleOper.new(self)

	scaleOper:setOperTarget(self.templateEntity)
	scaleOper:doScale(scaleXYZ)
	self.history:push(scaleOper)
	self:setCachedScale(scaleXYZ.x, scaleXYZ.y, scaleXYZ.z)
end

function EntityEditorBase:getCachedScale()
	if not self.cachedScale and self.templateEntity then
		local s = self.templateEntity:getScale()

		self.cachedScale = {
			x = s.x,
			y = s.y,
			z = s.z
		}
	end

	return self.cachedScale
end

function EntityEditorBase:setCachedScale(x, y, z)
	self.cachedScale = {
		x = x,
		y = y,
		z = z
	}
end

function EntityEditorBase:getCurrentScale()
	if self.templateEntity then
		return self.templateEntity:getScale()
	end

	return nil
end

function EntityEditorBase:undoAllChanges()
	self.history:undoAll()
end

function EntityEditorBase:cancel()
	self.history:clearHistory()
end

function EntityEditorBase:undo()
	self.history:undo()
end

function EntityEditorBase:redo()
	self.history:redo()
end

function EntityEditorBase:getHistoryStatus()
	return self.history:canUndo(), self.history:canRedo()
end

function EntityEditorBase:checkPlaceValid()
	if not self.templateEntity then
		return Const.HomeEditorErrorType.None
	end

	return self.templateEntity.placementValid
end

function EntityEditorBase:getCurOper()
	return self.history:getCurOper()
end

function EntityEditorBase:initEditorCamera()
	self.rootCameraMode = HomeCameraGroupMode.new()

	local distanceRange = self:getCameraDistanceRange()

	self.rootCameraMode.editorCamera:setDistanceRange(distanceRange[1], distanceRange[2])

	local speedRange = self:getCameraSpeedRange()

	self.rootCameraMode.editorCamera:setSpeedRange(speedRange[1], speedRange[2])
	self.rootCameraMode.editorCamera:setEditorFov(self:getCameraFov())
end

function EntityEditorBase:handleMove(x, y)
	if self.enableHomeCamera then
		self.rootCameraMode.editorCamera:handleMove(x, y)

		return true
	end

	return false
end

function EntityEditorBase:zoomIn()
	if self.enableHomeCamera then
		self.rootCameraMode.editorCamera:zoomIn()
	end
end

function EntityEditorBase:zoomOut()
	if self.enableHomeCamera then
		self.rootCameraMode.editorCamera:zoomOut()
	end
end

function EntityEditorBase:handleZoom(deltaZoom)
	if self.enableHomeCamera then
		self.rootCameraMode.editorCamera:handleZoom(deltaZoom)
	end
end

function EntityEditorBase:setCameraHeightOffset(offset)
	if self.enableHomeCamera then
		self.rootCameraMode.editorCamera:setHeightOffset(offset)
	end
end

function EntityEditorBase:setDisplayHideMode(mode)
	self.displayHideMode = mode or 0
end

function EntityEditorBase:setCameraHeightLimit(height)
	self.cameraHeightLimit = height or 0
end

function EntityEditorBase:isHeightOverCamera(localY)
	return localY > self.cameraHeightLimit - 0.01
end

function EntityEditorBase:forEachHideableEntity(func)
	return
end

function EntityEditorBase:calcEntityHeightHideVisible(entity, hideMode, fullHideMode, halfHideMode, focus, forward)
	if not hideMode then
		return true
	end

	local isHiddenFurniture = false

	if entity.homeTemplateId then
		local configData = HomeObjectData[entity.homeTemplateId]

		isHiddenFurniture = configData and configData.isHidden == 1
	end

	if fullHideMode and isHiddenFurniture then
		return false
	end

	local localPos = self:getLocalPosition(entity:getPosition())

	if self:isHeightOverCamera(localPos.y) then
		return false
	end

	if halfHideMode and isHiddenFurniture and focus and self:shouldHideWallByPlane(entity, focus, forward) then
		return false
	end

	return true
end

function EntityEditorBase:refreshHeightHide()
	local hideMode = self.displayHideMode ~= 0
	local fullHideMode = self.displayHideMode == 2
	local halfHideMode = self.displayHideMode == 1
	local focus, forward

	if halfHideMode then
		focus, forward = self:getCameraFocusInfo()
	end

	table.clear(self.tempHeightHideEntityMap)
	table.clear(self.tempHeightHideVisibleMap)
	table.clear(self.tempHeightHideResolvingMap)
	self:forEachHideableEntity(function(entity)
		if not entity or entity.destroyed or not entity.setVisible or entity.areaId ~= self.areaId then
			return
		end

		if entity.ornamentId then
			self.tempHeightHideEntityMap[entity.ornamentId] = entity
		end
	end)

	local attachData = self.buildAttachManager and self.buildAttachManager.attachData
	local resolveVisible

	function resolveVisible(entity)
		local cachedVisible = self.tempHeightHideVisibleMap[entity]

		if cachedVisible ~= nil then
			return cachedVisible
		end

		if self.tempHeightHideResolvingMap[entity] then
			return self:calcEntityHeightHideVisible(entity, hideMode, fullHideMode, halfHideMode, focus, forward)
		end

		self.tempHeightHideResolvingMap[entity] = true

		local visible
		local attachInfo = entity.ornamentId and attachData and attachData[entity.ornamentId]
		local parentEntity = attachInfo and attachInfo.parentId and self.tempHeightHideEntityMap[attachInfo.parentId]

		if parentEntity and parentEntity ~= entity and not parentEntity.destroyed then
			visible = resolveVisible(parentEntity)
		else
			visible = self:calcEntityHeightHideVisible(entity, hideMode, fullHideMode, halfHideMode, focus, forward)
		end

		self.tempHeightHideResolvingMap[entity] = nil
		self.tempHeightHideVisibleMap[entity] = visible

		return visible
	end

	local heightHideVisibleChanged = false

	self:forEachHideableEntity(function(entity)
		if not entity or entity.destroyed or not entity.setVisible or entity.areaId ~= self.areaId then
			return
		end

		local oldVisible = entity.visible

		entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.HOMELAND_HEIGHT_HIDE, resolveVisible(entity), true)

		if oldVisible ~= entity.visible then
			heightHideVisibleChanged = true
		end
	end)

	if heightHideVisibleChanged and self.templateEntity then
		self:refreshBuildAttachDisplay(self.templateEntity)
	end
end

function EntityEditorBase:getCameraFocusInfo()
	local cameraMgr = pg.global and pg.global.cameraMgr
	local worldCamera = cameraMgr and cameraMgr.worldCameraInst

	if not worldCamera then
		return nil
	end

	local cameraPosX, cameraPosY, cameraPosZ, fwdX, fwdY, fwdZ = cameraMgr:GetWorldCameraPositionAndForwardEx()
	local distance = 0

	if self.rootCameraMode and self.rootCameraMode.editorCamera and self.rootCameraMode.editorCamera.getDistance then
		distance = self.rootCameraMode.editorCamera:getDistance() or 0
	end

	self.cameraForwardCache:Set(fwdX, fwdY, fwdZ)
	self.cameraFocusCache:Set(cameraPosX + fwdX * distance, cameraPosY + fwdY * distance, cameraPosZ + fwdZ * distance)

	return self.cameraFocusCache, self.cameraForwardCache
end

function EntityEditorBase:shouldHideWallByPlane(entity, focus, forward)
	local epsilon = 0.1
	local pos = entity:getPosition()
	local centerY = pos.y

	if entity.getBoundHeight then
		centerY = pos.y + (entity:getBoundHeight() or 0) * 0.5
	end

	local d = (pos.x - focus.x) * forward.x + (centerY - focus.y) * forward.y + (pos.z - focus.z) * forward.z

	if d < -epsilon then
		entity.homeHidePlaneHidden = true
	elseif epsilon < d then
		entity.homeHidePlaneHidden = false
	end

	return entity.homeHidePlaneHidden == true
end

function EntityEditorBase:getCameraAreaBounds()
	return self:getAreaRange()
end

function EntityEditorBase:setHomeCameraEnable(enableHomeCamera, areaBounds)
	if self.enableHomeCamera ~= enableHomeCamera then
		self.enableHomeCamera = enableHomeCamera

		if self.enableHomeCamera then
			pg.game.input:forceEnableViewControl(ClientConst.ViewControl.HomelandEditor, true)
			self.rootCameraMode.editorCamera:initCameraMode()

			local centerPosition = Vector3.zero
			local centerRotation = Quaternion.identity

			if self.baseTransMatrix then
				centerPosition = self.baseTransMatrix:GetPosition()
				centerRotation = self.baseRotation
			end

			self.rootCameraMode.editorCamera:setMoveBounds(centerPosition, centerRotation, areaBounds)

			local worldCameraRotX, worldCameraRotY, worldCameraRotZ, worldCameraRotW = pg.global.cameraMgr:GetWorldCameraRotationEx()
			local worldCameraRotation = Quaternion(worldCameraRotX, worldCameraRotY, worldCameraRotZ, worldCameraRotW)

			self.rootCameraMode.editorCamera:setInitRotation(worldCameraRotation)
			self.rootCameraMode.editorCamera:setPosition(pg.me:getPositionClone(), self:getAreaRange())
			self.rootCameraMode:pushToParent(nil, CameraConst.PRIORITY_HOME_CAMERA)

			local overlookSetting = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.Overlook, false)

			if overlookSetting then
				self.rootCameraMode.editorCamera:setOverlookMode(true)
			end
		else
			pg.game.input:forceEnableViewControl(ClientConst.ViewControl.HomelandEditor, false)
			self.rootCameraMode:pullFromParent()
			self.rootCameraMode.editorCamera:setOverlookMode(false)
		end
	end
end

function EntityEditorBase:refreshShadows()
	return
end

function EntityEditorBase:setEnableEdit(uid, enableEdit)
	if enableEdit then
		self.editState[uid] = true
	else
		self.editState[uid] = nil
	end

	if not Utils.tableIsEmptyOrNil(self.editState) then
		if not self.isInBuildMode then
			self:enterBuildMode()
		end
	elseif self.isInBuildMode then
		self:exitBuildMode()
	end
end

function EntityEditorBase:enterBuildMode()
	if self.isInBuildMode then
		return
	end

	self.isInBuildMode = true

	self:setHomeCameraEnable(true, self:getCameraAreaBounds())
	pg.global.homelandMgr:TempSetShadowEnable(false)

	local areaRange = self:getAreaRange()
	local gridVisible = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.GridDisplay, true)

	self:setGridEffectVisible(gridVisible, areaRange)
	self:refreshEditorProcessEff()
	self:onEditorBuildModeChanged()
end

function EntityEditorBase:exitBuildMode()
	if not self.isInBuildMode then
		return
	end

	self.isInBuildMode = false

	self:clearEditor()
	self:setHomeCameraEnable(false, nil)
	pg.global.homelandMgr:TempSetShadowEnable(true)
	self:setGridEffectVisible(false)
	self:setAttachGridVisible(false)
	self:refreshEditorProcessEff()
	self:onEditorBuildModeChanged()
end

function EntityEditorBase:getBottomEffectOffset()
	return 0.02
end

function EntityEditorBase:setGridEffectVisible(visible, areaRange)
	if visible then
		local centerX = (areaRange[1] + areaRange[2]) * 0.5
		local centerZ = (areaRange[3] + areaRange[4]) * 0.5
		local bottomOffset = self:getBottomEffectOffset()
		local gridCenter = self:getWorldPosition(Vector3.New(centerX, bottomOffset, centerZ))
		local sizeX = areaRange[2] - areaRange[1]
		local sizeZ = areaRange[4] - areaRange[3]
		local gridRotation = Quaternion.identity

		if self.baseRotation then
			gridRotation = self.baseRotation
		end

		pg.global.homelandMgr:ShowGridEffect(0, gridCenter, gridRotation, sizeX, sizeZ)
	else
		pg.global.homelandMgr:HideGridEffect(0)
	end
end

function EntityEditorBase:setAttachGridVisible(visible)
	if not visible and self.buildAttachManager then
		self.buildAttachManager:clearAttachGrids()
	end
end

function EntityEditorBase:refreshEditorProcessEff()
	if self.isInBuildMode then
		if not self.editorEffectId then
			local extraConfig = {
				duration = -1,
				followType = EffectConst.FollowType.Global,
				mountType = EffectConst.MountType.Camera,
				loadCallback = HomeEditorOutline.onVolumeLoaded
			}

			self.editorEffectId = pg.game.effect:playRawEffect(nil, AddressDataConst.HOMELAND_EDITOR_POST_PROCESS_EFF, extraConfig)
		end
	elseif self.editorEffectId then
		pg.game.effect:stopEffect(nil, self.editorEffectId)

		self.editorEffectId = nil

		HomeEditorOutline.onVolumeReleased()
	end
end

function EntityEditorBase:calcEntitiesBounds(entities)
	local minX, maxX, minZ, maxZ, minY, maxY

	for _, ent in ipairs(entities) do
		local position = self:getLocalPosition(ent:getPosition())
		local rotation = self:getLocalRotation(ent:getRotation())
		local bounds = ent.getBoundSize and ent:getBoundSize() or {
			1,
			1
		}
		local boundHeight = ent.getBoundHeight and ent:getBoundHeight() or 1
		local entMinX, entMaxX, entMinZ, entMaxZ

		if Utils.checkRotationIsVertical(rotation) then
			entMinX = position.x - bounds[2] / 2
			entMaxX = position.x + bounds[2] / 2
			entMinZ = position.z - bounds[1] / 2
			entMaxZ = position.z + bounds[1] / 2
		else
			entMinX = position.x - bounds[1] / 2
			entMaxX = position.x + bounds[1] / 2
			entMinZ = position.z - bounds[2] / 2
			entMaxZ = position.z + bounds[2] / 2
		end

		local entMinY = position.y
		local entMaxY = position.y + boundHeight

		if not minX or entMinX < minX then
			minX = entMinX
		end

		if not maxX or maxX < entMaxX then
			maxX = entMaxX
		end

		if not minZ or entMinZ < minZ then
			minZ = entMinZ
		end

		if not maxZ or maxZ < entMaxZ then
			maxZ = entMaxZ
		end

		if not minY or entMinY < minY then
			minY = entMinY
		end

		if not maxY or maxY < entMaxY then
			maxY = entMaxY
		end
	end

	return minX, maxX, minZ, maxZ, minY, maxY
end

function EntityEditorBase:createTemplateMultiEditObject(targetEntities)
	if #targetEntities == 0 then
		return
	end

	local minX, maxX, minZ, maxZ, minY, maxY = self:calcEntitiesBounds(targetEntities)

	if not minX then
		return
	end

	local centerPosLocal = Vector3((minX + maxX) * 0.5, minY, (minZ + maxZ) * 0.5)
	local centerPos = self:getWorldPosition(centerPosLocal)
	local centerLocalRot = self:getDefaultRotation()
	local initialYawAngle = self.placeConfig and self.placeConfig.homeBlueprintGroupInitialYawAngle

	if initialYawAngle then
		centerLocalRot = centerLocalRot * Utils.yawAngleIntToQuaternion(initialYawAngle)
	end

	local centerYaw = Utils.normalizeAngle(math.deg(centerLocalRot:ToYaw()))

	self:setCachedEulerAngles(0, math.round(centerYaw), 0)

	local centerRot = self:getWorldRotation(centerLocalRot)
	local className = "ClientEditorMutiEditGroupEntity"
	local templateEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		editor = self,
		baseTransMatrixInv = self.baseTransMatrixInv,
		templateType = Const.HomelandEntType.Ornament,
		initPosition = centerPos,
		areaId = self.areaId,
		initRotation = centerRot
	})
	local mainTargetEntity

	if self.buildAttachManager and self.buildAttachManager.getEditGroupMainEntity then
		mainTargetEntity = self.buildAttachManager:getEditGroupMainEntity(targetEntities)
	end

	for _, ent in ipairs(targetEntities) do
		templateEntity:addExistChildEntity(ent, ent == mainTargetEntity)
	end

	return templateEntity
end

function EntityEditorBase:createTemplateGroupPlaceObject(templateType, templateId, position, rotation, templateData, extraInfo)
	local className = "ClientEditorGroupPlaceEntity"

	templateId = templateId or 0

	local templateEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		editor = self,
		areaId = self.areaId,
		templateType = templateType,
		templateData = templateData,
		initPosition = position,
		initRotation = rotation,
		homeTemplateId = templateId,
		originEntity = extraInfo and extraInfo.originEntity
	})

	return templateEntity
end

function EntityEditorBase:onTick()
	return
end

function EntityEditorBase:onEditorBuildModeChanged()
	return
end

function EntityEditorBase:onEditModeChanged(isInEditMode)
	return
end

function EntityEditorBase:createTemplateObjectByTarget(targetEntity)
	return nil
end

function EntityEditorBase:createTemplateObjectNew(templateId, entityData, initInfo)
	return nil
end

function EntityEditorBase:createTemplateObjectPreview(entityData, screenPos)
	return nil
end

function EntityEditorBase:onStartEditEntity()
	return
end

function EntityEditorBase:applyTemplateData()
	return
end

function EntityEditorBase:addMultiSelectEntity(entity)
	if not self.multiSelectEntities[entity.id] then
		self.multiSelectEntities[entity.id] = entity

		table.insert(self.multiSelectList, entity.id)

		if entity.setInMultiSelect then
			entity:setInMultiSelect(true)
		end

		self:onMultiSelectChanged()
	end
end

function EntityEditorBase:addMultiSelectEntities(entities)
	local changed = false

	for _, entity in ipairs(entities) do
		if not self.multiSelectEntities[entity.id] then
			self.multiSelectEntities[entity.id] = entity

			table.insert(self.multiSelectList, entity.id)

			if entity.setInMultiSelect then
				entity:setInMultiSelect(true)
			end

			changed = true
		end
	end

	if changed then
		self:onMultiSelectChanged()
	end
end

function EntityEditorBase:removeMultiSelectEntity(entity)
	if self.multiSelectEntities[entity.id] == entity then
		self.multiSelectEntities[entity.id] = nil

		lume.removeFromArr(self.multiSelectList, entity.id)

		if entity.setInMultiSelect then
			entity:setInMultiSelect(false)
		end

		self:onMultiSelectChanged()
	end
end

function EntityEditorBase:removeMultiSelectEntities(entities)
	local changed = false

	for _, entity in ipairs(entities) do
		if self.multiSelectEntities[entity.id] == entity then
			self.multiSelectEntities[entity.id] = nil

			lume.removeFromArr(self.multiSelectList, entity.id)

			if entity.setInMultiSelect then
				entity:setInMultiSelect(false)
			end

			changed = true
		end
	end

	if changed then
		self:onMultiSelectChanged()
	end
end

function EntityEditorBase:clearMultiSelectEntities()
	for entId, entity in pairs(self.multiSelectEntities) do
		if not entity.destroyed and entity.setInMultiSelect then
			entity:setInMultiSelect(false)
		end
	end

	table.clear(self.multiSelectEntities)
	table.clear(self.multiSelectList)
	self:onMultiSelectChanged()
end

function EntityEditorBase:clearInvalidMultiSelectEntities()
	local changed = false

	for entId, entity in pairs(self.multiSelectEntities) do
		if entity.destroyed then
			self.multiSelectEntities[entity.id] = nil

			lume.removeFromArr(self.multiSelectList, entity.id)

			changed = true
		end
	end

	if changed then
		self:onMultiSelectChanged()
	end
end

function EntityEditorBase:onMutiSelectEntityDestroy()
	self.multiSelectDirty = true
end

function EntityEditorBase:checkAndUpdateMultiSelectEntity()
	if self.multiSelectDirty then
		self.multiSelectDirty = false

		self:clearInvalidMultiSelectEntities()
	end
end

function EntityEditorBase:onMultiSelectChanged()
	if self.onMultiSelectChangedCallback then
		self.onMultiSelectChangedCallback()
	end
end

function EntityEditorBase:checkBoundInArea(position, rotation, bounds)
	local boundX = bounds[1]
	local boundZ = bounds[2]

	if Utils.checkRotationIsVertical(rotation) then
		boundX = bounds[2]
		boundZ = bounds[1]
	end

	local yAreaRange = self:getYAreaRange()

	if yAreaRange and (position.y < yAreaRange[1] - 0.01 or position.y > yAreaRange[2] + 0.01) then
		return false
	end

	local areaRange = self:getAreaRange()

	if areaRange then
		local epsilon = 0.01
		local minX = position.x - boundX / 2
		local maxX = position.x + boundX / 2
		local minZ = position.z - boundZ / 2
		local maxZ = position.z + boundZ / 2
		local ans = areaRange[1] <= minX + epsilon and maxX - epsilon <= areaRange[2] and areaRange[3] <= minZ + epsilon and maxZ - epsilon <= areaRange[4]

		return ans
	end

	return false
end

function EntityEditorBase:getAreaOrnaments(minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
	return false
end

function EntityEditorBase:getFastFindMap()
	return nil
end

function EntityEditorBase:getFloorLiftLocalY(localPosition, homeTemplateId)
	return 0
end

function EntityEditorBase:refreshAutoBuildAttach(operEntity)
	if self.buildAttachManager then
		self.buildAttachManager:tryApplyBuildAttach(self, operEntity)
	end
end

function EntityEditorBase:refreshBuildAttachDisplay(operEntity)
	if self.buildAttachManager then
		self.buildAttachManager:refreshBuildAttachDisplay(self, operEntity)
	end
end

function EntityEditorBase:setEnableBuildAttach(enable)
	if self.buildAttachManager then
		self.buildAttachManager:setEnableBuildAttach(enable)
	end
end

function EntityEditorBase:onEntityPositionChanged(operEntity, isFirstEdit)
	if operEntity.onEntityPositionChanged then
		operEntity:onEntityPositionChanged()
	end

	if isFirstEdit then
		self:refreshAutoBuildAttach(operEntity)
	else
		self:refreshBuildAttachDisplay(operEntity)
	end
end

function EntityEditorBase:onEntityRotationChanged(operEntity, isFirstEdit)
	if operEntity.onEntityPositionChanged then
		operEntity:onEntityPositionChanged()
	end

	if isFirstEdit then
		self:refreshAutoBuildAttach(operEntity)
	else
		self:refreshBuildAttachDisplay(operEntity)
	end
end

function EntityEditorBase:onEntityScaleChanged(operEntity, isFirstEdit)
	if operEntity.onEntityPositionChanged then
		operEntity:onEntityPositionChanged()
	end

	if isFirstEdit then
		self:refreshAutoBuildAttach(operEntity)
	else
		self:refreshBuildAttachDisplay(operEntity)
	end
end

function EntityEditorBase:onEntityGroupExtendChanged(operEntity, isFirstEdit)
	self:refreshBuildAttachDisplay(operEntity)
end

function EntityEditorBase:onEntityAttachChanged(operEntity)
	if operEntity.onEntityPositionChanged then
		operEntity:onEntityPositionChanged()
	end
end

function EntityEditorBase:onEntityLinkChanged(operEntity)
	if operEntity.onEntityPositionChanged then
		operEntity:onEntityPositionChanged()
	end
end

return EntityEditorBase
