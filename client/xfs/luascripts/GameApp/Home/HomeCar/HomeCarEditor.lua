-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeCar\\HomeCarEditor.lua

local Class = require("Core.Framework.Class")
local EntityEditorHistory = require("GameApp.Home.EntityEditorHistory")
local EntityEditorBase = require("GameApp.Home.EntityEditorBase")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local HomeObjectData = require("Data.home_object_data")
local Utils = require("Common.Utils.Utils")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientConst = require("Const.ClientConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils
local HomeCarEditor = Class.LiteClass("HomeCarEditor", EntityEditorBase)

function HomeCarEditor:ctor()
	HomeCarEditor.super.ctor(self)

	self.tempHitEntities = {}
end

function HomeCarEditor:finishEdit()
	self:destroyTemplateObject(self.previewEntity)

	self.previewEntity = nil

	HomeCarEditor.super.finishEdit(self)
end

function HomeCarEditor:onTick()
	self:updateEditEntityState()
end

function HomeCarEditor:getAreaRange()
	return HomelandConfigData.homeCarAreaRange or {
		-20,
		20,
		-20,
		20
	}
end

function HomeCarEditor:getYAreaRange()
	return HomelandConfigData.homeCarYAxisRange or {
		0,
		15
	}
end

function HomeCarEditor:forEachHideableEntity(func)
	local carGroup = self.carGroup

	if not carGroup then
		return
	end

	if carGroup.ornamentEntities then
		for _, homeEntity in pairs(carGroup.ornamentEntities) do
			func(homeEntity)
		end
	end
end

function HomeCarEditor:getCameraDistanceRange()
	return HomelandConfigData.homeCarEditorDistanceRange or {
		10,
		50
	}
end

function HomeCarEditor:getCameraFov()
	return HomelandConfigData.homeCarEditorFov or 25
end

function HomeCarEditor:setTargetCarGroup(carGroup)
	if self.carGroup then
		self.carGroup:setInBuildMode(false)
	end

	local baseTransMatrix = carGroup.baseTransMatrix

	self.carGroup = carGroup

	self:setBaseTransMatrix(baseTransMatrix)
	self.carGroup:setInBuildMode(self.isInBuildMode)
end

function HomeCarEditor:enterBuildMode()
	pg.global.homelandMgr:TryInitHomeManager()
	HomeCarEditor.super.enterBuildMode(self)
end

function HomeCarEditor:exitBuildMode()
	HomeCarEditor.super.exitBuildMode(self)
	pg.global.homelandMgr:ResetHomeManager()
end

function HomeCarEditor:onEditorBuildModeChanged()
	self.carGroup:setInBuildMode(self.isInBuildMode)

	if self.isInBuildMode then
		local baseYaw = self.baseRotation.eulerAngles.y + 180

		self.rootCameraMode.editorCamera:setInitRotation(Quaternion.Euler(0, baseYaw, 0))
	end
end

function HomeCarEditor:startEditNew(homeTemplateId, entityData, initInfo, placeConfig)
	self:beforeEdit()

	self.entityData = entityData
	self.placeConfig = placeConfig or {}

	self:doStartEditNew(homeTemplateId, entityData, initInfo)
end

function HomeCarEditor:startEditBlueprint(blueprintData, initInfo, placeConfig)
	self:beforeEdit()

	self.targetEntity = nil
	self.entityData = blueprintData
	self.placeConfig = placeConfig or {}
	self.entityType = Const.HomelandEntType.Ornament

	local startPosition = initInfo and initInfo.position

	if not startPosition then
		local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
		local _, targetPosition = self:getScreenCastPosition(screenCenter)

		startPosition = targetPosition
	end

	local startRotation = initInfo and initInfo.rotation or self:getWorldRotation(self:getDefaultRotation())
	local templateEntity = self:createTemplateBlueprintObject(blueprintData, startPosition, startRotation, false)

	if not templateEntity then
		self:finishEdit()

		return false
	end

	local clampedPosition = self:clampBlueprintGroupPosition(templateEntity, startPosition)

	templateEntity:setPosition(clampedPosition)
	templateEntity:onEntityPositionChanged()

	self.templateEntity = templateEntity

	self:setInEditMode(true, ClientConst.EntityEditType.Create)
	self:onStartEditEntity()

	return true
end

function HomeCarEditor:getEditAreaRangeRange(homeTemplateId)
	local homeObjectData = HomeObjectData[homeTemplateId]
	local boundSize = homeObjectData.boundSize or {
		1,
		1
	}

	return {
		-boundSize[1] * 0.5,
		boundSize[1] * 0.5,
		-boundSize[2] * 0.5,
		boundSize[2] * 0.5
	}
end

function HomeCarEditor:createTemplateObjectByTarget(targetEntity)
	local homeTemplateId = targetEntity.homeTemplateId
	local position = targetEntity:getPosition():Clone()
	local rotation = targetEntity:getRotation():Clone()
	local _sx, _sy, _sz = targetEntity.eModel:GetPositionAgentLocalScaleEx()
	local scale = Vector3.New(_sx, _sy, _sz)
	local templateEntity = self:createTemplateObject(homeTemplateId, position, rotation, targetEntity:getHomelandConfigData(), {
		originEntity = targetEntity,
		initScale = scale
	})

	return templateEntity
end

function HomeCarEditor:createTemplateObjectNew(templateId, entityData, initInfo)
	local homeTemplateId = templateId
	local homeObjData = HomeObjectData[homeTemplateId] or {}
	local startPosition = initInfo and initInfo.position
	local startRotation = initInfo and initInfo.rotation

	if not startPosition then
		local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
		local valid, targetPosition = self:getScreenCastPosition(screenCenter)

		startPosition = targetPosition
	end

	startPosition = self:clampPosition(startPosition, self:getEditAreaRangeRange(homeTemplateId))
	startRotation = startRotation or self:getWorldRotation(Quaternion.identity)

	local templateEntity

	templateEntity = self:createTemplateObject(homeTemplateId, startPosition, startRotation, homeObjData)

	return templateEntity
end

function HomeCarEditor:createTemplateObject(templateId, position, rotation, templateData, extraInfo)
	local className = "ClientHomeCarTemplateEntity"
	local virtualOrnamentId = pg.game.home:genVirtualOrnamentId()

	templateId = templateId or 0

	local isPreview = false
	local originEntity

	if extraInfo then
		isPreview = extraInfo.isPreview
		originEntity = extraInfo.originEntity
	end

	local initScale = extraInfo and extraInfo.initScale
	local templateEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		baseTransMatrixInv = self.baseTransMatrixInv,
		ornamentId = virtualOrnamentId,
		playerUID = self.carGroup.playerUID,
		templateData = templateData,
		homeTemplateId = templateId,
		initPosition = position,
		initRotation = rotation,
		areaId = self.areaId,
		initScale = initScale,
		isPreview = isPreview,
		originEntity = originEntity,
		editor = self
	})

	return templateEntity
end

function HomeCarEditor:createTemplateBlueprintObject(blueprintData, position, rotation, isPreview)
	local ornaments = self:getBlueprintOrnaments(blueprintData)

	if not ornaments then
		return nil
	end

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo and ornamentInfo.homeId

		if not homeId or not HomeObjectData[homeId] then
			return nil
		end
	end

	local templateEntity = ClientUtils.createClientEntity("ClientEditorTemplateGroupEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		editor = self,
		areaId = self.areaId,
		baseTransMatrixInv = self.baseTransMatrixInv,
		templateType = Const.HomelandEntType.Ornament,
		initPosition = position,
		initRotation = rotation
	})

	if not templateEntity then
		return nil
	end

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo.homeId
		local homeObjData = HomeObjectData[homeId]
		local relativePosition = self:getBlueprintPosition(ornamentInfo.relPos3)
		local relativeRotation = self:getBlueprintRotation(ornamentInfo.relRot3)
		local childEntity = self:createTemplateObject(homeId, templateEntity:getRelativePosition(relativePosition), templateEntity:getRelativeRotation(relativeRotation), homeObjData, {
			isPreview = isPreview,
			initScale = self:getBlueprintScale(ornamentInfo.scale3)
		})

		if not childEntity then
			ClientUtils.safeDestroy(templateEntity)

			return nil
		end

		templateEntity:addChildEntity(childEntity, relativePosition, relativeRotation)
	end

	return templateEntity
end

function HomeCarEditor:clampBlueprintGroupPosition(templateEntity, position)
	local oldTemplateEntity = self.templateEntity

	self.templateEntity = templateEntity

	local clampedPosition = self:clampPosition(position)

	self.templateEntity = oldTemplateEntity

	return clampedPosition
end

function HomeCarEditor:onStartEditEntity()
	if self.templateEntity then
		self.templateEntity:setHomeEditState(ClientConst.HomeEntEffectType.Edit)
	end

	self:updateEditEntityState()
end

function HomeCarEditor:updateEditEntityState()
	if self.templateEntity then
		self.templateEntity:updateHomeEditorState()
	end
end

function HomeCarEditor:getBottomEffectOffset()
	return 0.03
end

function HomeCarEditor:createPreviewObject(homeTemplateId, entityData, screenPos)
	if self.templateEntity ~= nil then
		return
	end

	self:destroyPreviewObject()

	self.entityData = entityData

	local homeObjData = HomeObjectData[homeTemplateId] or {}
	local rotation = self:getWorldRotation(Quaternion.identity)

	screenPos = screenPos or Vector2(Screen.width * 0.5, Screen.height * 0.5)

	local valid, targetPosition = self:getScreenCastPosition(screenPos)

	targetPosition = self:clampPosition(targetPosition, self:getEditAreaRangeRange(homeTemplateId))
	self.previewEntity = self:createTemplateObject(homeTemplateId, targetPosition, rotation, homeObjData, {
		isPreview = true
	})
end

function HomeCarEditor:createBlueprintPreviewObject(blueprintData, screenPos)
	if self.templateEntity ~= nil then
		return nil
	end

	self:destroyPreviewObject()

	self.entityData = blueprintData
	self.entityType = Const.HomelandEntType.Ornament
	screenPos = screenPos or Vector2(Screen.width * 0.5, Screen.height * 0.5)

	local _, targetPosition = self:getScreenCastPosition(screenPos)
	local rotation = self:getWorldRotation(self:getDefaultRotation())
	local previewEntity = self:createTemplateBlueprintObject(blueprintData, targetPosition, rotation, true)

	if not previewEntity then
		return nil
	end

	targetPosition = self:clampBlueprintGroupPosition(previewEntity, targetPosition)

	previewEntity:setPosition(targetPosition)
	previewEntity:onEntityPositionChanged()
	previewEntity:updateHomeEditorState()

	self.previewEntity = previewEntity

	return previewEntity
end

function HomeCarEditor:destroyPreviewObject()
	self:destroyTemplateObject(self.previewEntity)

	self.previewEntity = nil
end

function HomeCarEditor:updatePreviewObjectPosition(screenPos)
	if self.previewEntity == nil then
		return
	end

	local valid, targetPosition = self:getScreenCastPosition(screenPos, self.previewEntity:getPosition().y)

	if self.previewEntity.homeTemplateId then
		targetPosition = self:clampPosition(targetPosition, self:getEditAreaRangeRange(self.previewEntity.homeTemplateId))
	else
		targetPosition = self:clampBlueprintGroupPosition(self.previewEntity, targetPosition)
	end

	self.previewEntity:setPosition(targetPosition)
	self.previewEntity:onEntityPositionChanged()
end

function HomeCarEditor:trySelectRaycastEntity(screenPos, selectType, withHitPoint, onlyEditingEntity)
	local hitEntities = self.tempHitEntities
	local hitPoints

	if withHitPoint then
		hitEntities = self.tempRaycastHitEntities
		hitPoints = self.tempRaycastHitPoints

		table.clear(hitPoints)
	end

	table.clear(hitEntities)

	if withHitPoint then
		HomeEditorUtils.GetRaycastHitHomeEntitiesWithPoint(screenPos, 300, hitEntities, hitPoints)
	else
		HomeEditorUtils.GetRaycastHitHomeEntities(screenPos, 300, hitEntities)
	end

	for i, ent in ipairs(hitEntities) do
		if ent and not ent.destroyed and ent.visible ~= false and ent.carGroup == self.carGroup and (not onlyEditingEntity or self.editingEntities[ent.id]) then
			return ent, hitPoints and hitPoints[i]
		end
	end
end

function HomeCarEditor:trySelectEntity(screenPos, selectType)
	local selectEnt = self:trySelectRaycastEntity(screenPos, selectType)

	if selectEnt then
		return selectEnt
	end

	local valid, placePos = HomeEditorUtils.GetRaycastPlacePosition(screenPos, self.baseTransMatrix:GetPosition().y)

	return self.carGroup:getPositionOrnament(placePos)
end

function HomeCarEditor:tryBoxSelectEntities(screenPosStart, screenPosEnd, selectType, entities)
	selectType = selectType or ClientConst.HomeSelectType.All

	table.clear(entities)
	table.clear(self.tempHitEntities)
	HomeEditorUtils.GetSelectBoxHitEntities(screenPosStart, screenPosEnd, 150, self.tempHitEntities)

	for _, ent in ipairs(self.tempHitEntities) do
		if ent.carGroup == self.carGroup then
			entities[ent.id] = ent
		end
	end
end

function HomeCarEditor:applyTemplateData()
	local applyData = {
		updateData = {},
		createList = {}
	}

	if self.templateEntity then
		local buildExtraData
		local homeBlueprintGroupInfoList = self.placeConfig and self.placeConfig.homeBlueprintGroupInfoList

		if homeBlueprintGroupInfoList and #homeBlueprintGroupInfoList > 0 then
			buildExtraData = {
				homeBlueprintGroupInfoList = {}
			}

			local yawAngleDelta = self:getBlueprintBuildGroupYawAngleDelta()

			for _, groupInfo in ipairs(homeBlueprintGroupInfoList) do
				table.insert(buildExtraData.homeBlueprintGroupInfoList, {
					groupIndex = groupInfo.groupIndex,
					yawAngle = yawAngleDelta
				})
			end
		end

		self.templateEntity:applyEditorTemplateData(applyData)

		if not Utils.tableIsEmptyOrNil(applyData.createList) then
			self.carGroup:addOrnaments(applyData.createList)
		end

		if not Utils.tableIsEmptyOrNil(applyData.updateData) then
			self.carGroup:updateOrnaments(applyData.updateData, buildExtraData)
		end
	end
end

function HomeCarEditor:onEditOrnamentResult(isSucc, operationType)
	if not self.confirmCallback then
		return
	end

	self:onFinishCallback(isSucc, operationType)
end

function HomeCarEditor:withdrawEnt()
	local applyData = {
		removeList = {}
	}

	self.templateEntity:applyWithdrawData(applyData)

	if not Utils.tableIsEmptyOrNil(applyData.removeList) then
		self.carGroup:removeOrnaments(applyData.removeList)
	end
end

function HomeCarEditor:withdrawMultiSelectEntities()
	if not self.carGroup then
		return
	end

	local removeList = {}

	for _, ent in pairs(self.multiSelectEntities) do
		if ent.ornamentId then
			table.insert(removeList, ent.ornamentId)
		end
	end

	if #removeList > 0 then
		self.carGroup:removeOrnaments(removeList)
	end
end

function HomeCarEditor:refreshShadows()
	pg.game.homeCar:refreshShadows()
end

function HomeCarEditor:getAreaOrnaments(minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
	return self.carGroup:getAreaOrnaments(minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
end

function HomeCarEditor:getFastFindMap()
	return self.carGroup.fastFindMap
end

function HomeCarEditor:getBlueprintOrnaments(blueprintData)
	if type(blueprintData) ~= "table" then
		return nil
	end

	local ornaments = blueprintData.ornaments

	if type(ornaments) ~= "table" or #ornaments <= 0 then
		return nil
	end

	return ornaments
end

function HomeCarEditor:getBlueprintPosition(pos3)
	pos3 = type(pos3) == "table" and pos3 or {}

	local positionBase = HomeLandUtils.ORNAMENT_POSITION_INT_BASE

	return Vector3.New((tonumber(pos3[1]) or 0) / positionBase, (tonumber(pos3[2]) or 0) / positionBase, (tonumber(pos3[3]) or 0) / positionBase)
end

function HomeCarEditor:getBlueprintRotation(rot3)
	rot3 = type(rot3) == "table" and rot3 or {}

	local rotationBase = HomeLandUtils.ORNAMENT_ROTATION_INT_BASE

	return Quaternion.Euler((tonumber(rot3[1]) or 0) / rotationBase, (tonumber(rot3[2]) or 0) / rotationBase, (tonumber(rot3[3]) or 0) / rotationBase)
end

function HomeCarEditor:getBlueprintScale(scale3)
	scale3 = type(scale3) == "table" and scale3 or {}

	local scaleBase = HomeLandUtils.ORNAMENT_SCALE_INT_BASE

	return Vector3.New((tonumber(scale3[1]) or scaleBase) / scaleBase, (tonumber(scale3[2]) or scaleBase) / scaleBase, (tonumber(scale3[3]) or scaleBase) / scaleBase)
end

return HomeCarEditor
