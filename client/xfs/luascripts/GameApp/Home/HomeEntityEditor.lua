-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEntityEditor.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local EntityEditorBase = require("GameApp.Home.EntityEditorBase")
local EntityEditorHistory = require("GameApp.Home.EntityEditorHistory")
local PositionOper = require("GameApp.Home.HomeEdtorOper.PositionOper")
local DeltaPositionOper = require("GameApp.Home.HomeEdtorOper.DeltaPositionOper")
local RotationOper = require("GameApp.Home.HomeEdtorOper.RotationOper")
local ExtendOper = require("GameApp.Home.HomeEdtorOper.ExtendOper")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientConst = require("Const.ClientConst")
local HomelandConfigData = require("Data.homeland_config_data")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local HomeObjectData = require("Data.home_object_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local OrnamentSingleData = require("CustomTypes.OrnamentSingleData")
local HomeEnvSimulateEditor = require("GameApp.Home.HomeEnvSimulateEditor")
local EffectConst = require("Const.EffectConst")
local AddressDataConst = require("Const.AddressDataConst")
local CommonSwitch = require("Common.CommonSwitch")
local HomeEntityEditor = Class.LiteClass("HomeEntityEditor", EntityEditorBase)
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils

HomeEntityEditor.CAMERA_AREA_EXPAND = 10

function HomeEntityEditor:ctor()
	HomeEntityEditor.super.ctor(self)

	self.previewEntity = nil
	self.tempHitEntities = {}
	self.linkEffectInfo = {}
	self.linkEffects = {}
	self.linkEffectSourcePosition = Vector3.ForceNew(0, 0, 0)
	self.linkEffectTargetPosition = Vector3.ForceNew(0, 0, 0)
	self.envEditor = HomeEnvSimulateEditor.new(self)
end

function HomeEntityEditor:setEditArea(areaId)
	HomeEntityEditor.super.setEditArea(self, areaId)
	self:setBaseTransMatrix(pg.game.home:getAreaBaseTransform(areaId))
end

function HomeEntityEditor:getAreaRange()
	return pg.game.home:getAreaRange(self.areaId)
end

function HomeEntityEditor:getYAreaRange()
	return pg.game.home:getAreaYAxisRange(self.areaId) or {
		0,
		15
	}
end

function HomeEntityEditor:forEachHideableEntity(func)
	local home = pg.game.home

	if not home then
		return
	end

	if home.homeEntities then
		for _, homeEntity in pairs(home.homeEntities) do
			func(homeEntity)
		end
	end
end

function HomeEntityEditor:initHomeland(space)
	self:setBuildAttachManager(space.ornamentBuildAttachManager)
end

function HomeEntityEditor:getEditAreaRangeRange(homeTemplateId)
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

function HomeEntityEditor:clear()
	HomeEntityEditor.super.clear(self)
	self:destroyLinkEffects()
end

function HomeEntityEditor:onTick()
	self:updateHomelandViewCenter()
	self:updateEnvSimulate()
	self:updateEditEntityState()
	self:updateAllLinkEffects()
end

function HomeEntityEditor:getDefaultRotation()
	local defaultYaw = pg.game.home:getAreaOrnamentDefaultYaw(self.areaId)

	return Quaternion.Euler(0, defaultYaw, 0)
end

function HomeEntityEditor:initEnvSimulateEditor()
	self.envEditor:init(pg.space)
end

function HomeEntityEditor:updateEnvSimulate()
	self.envEditor:updateEnvInfo()
end

function HomeEntityEditor:clearEnvSimulateEditor()
	self.envEditor:clear()
end

function HomeEntityEditor:getCameraAreaBounds()
	if CommonSwitch.HOMELAND_NEW_MAP then
		local areaRange = self:getAreaRange()
		local expand = HomeEntityEditor.CAMERA_AREA_EXPAND

		return {
			areaRange[1] - expand,
			areaRange[2] + expand,
			areaRange[3] - expand,
			areaRange[4] + expand
		}
	end

	return HomelandConfigData.homelandCameraAreaRange or self:getAreaRange()
end

function HomeEntityEditor:updateHomelandViewCenter()
	return
end

function HomeEntityEditor:onEnvLinkChange()
	pg.game.home:onEditorEnvLinkChange()
	self:markLinkEffectDirty()
end

function HomeEntityEditor:beforeEdit()
	HomeEntityEditor.super.beforeEdit(self)
	self:initEnvSimulateEditor()
end

function HomeEntityEditor:createTemplateObjectByTarget(targetEntity)
	local homeTemplateId = targetEntity.homeTemplateId
	local position = targetEntity:getPosition():Clone()
	local rotation = targetEntity:getRotation():Clone()
	local _sx, _sy, _sz = targetEntity.eModel:GetPositionAgentLocalScaleEx()
	local scale = Vector3.New(_sx, _sy, _sz)
	local entityType
	local extraInfo = {
		originEntity = targetEntity,
		initScale = scale,
		editor = self
	}

	if Utils.isHomePet(targetEntity) then
		entityType = Const.HomelandEntType.Pet

		local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
		local valid, targetPosition = self:getScreenCastPosition(screenCenter)

		position = self:clampPosition(targetPosition)
		rotation = self:getDefaultRotation()
		extraInfo.isPet = true
	else
		entityType = targetEntity:getHomelandConfigData().entityType or Const.HomelandEntType.Ornament
		extraInfo.ornamentInfo = pg.space.ornament[targetEntity.ornamentId]

		if self.placeConfig and self.placeConfig.isGroupPlace then
			return self:createTemplateGroupPlaceObject(entityType, homeTemplateId, position, rotation, targetEntity:getHomelandConfigData(), extraInfo)
		end
	end

	local templateEntity = self:createTemplateObject(entityType, homeTemplateId, position, rotation, targetEntity:getHomelandConfigData(), extraInfo)

	return templateEntity
end

function HomeEntityEditor:createTemplateObjectNew(templateId, entityData, initInfo)
	if self.entityType == Const.HomelandEntType.Pet then
		local rotation = Quaternion.identity
		local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
		local valid, targetPosition = self:getScreenCastPosition(screenCenter)

		targetPosition = self:clampPosition(targetPosition)

		local templateData = {
			petId = entityData.petId
		}
		local templateEntity = self:createTemplateObject(self.entityType, nil, targetPosition, rotation, templateData)

		return templateEntity
	else
		local homeTemplateId = templateId
		local homeObjData = HomeObjectData[homeTemplateId] or {}
		local startPosition = initInfo and initInfo.position
		local startRotation = initInfo and initInfo.rotation

		if not startPosition then
			local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
			local valid, targetPosition = self:getScreenCastPosition(screenCenter)

			startPosition = targetPosition
		end

		startPosition = self:clampPosition(startPosition, self:getEditAreaRangeRange(homeTemplateId), homeTemplateId)
		startRotation = startRotation or self:getDefaultRotation()

		local templateEntity

		if self.placeConfig.isGroupPlace then
			templateEntity = self:createTemplateGroupPlaceObject(self.entityType, homeTemplateId, startPosition, startRotation, homeObjData)
		else
			templateEntity = self:createTemplateObject(self.entityType, homeTemplateId, startPosition, startRotation, homeObjData)
		end

		return templateEntity
	end
end

function HomeEntityEditor:doStartEdit(targetEntity, placeConfig)
	if Utils.isHomePet(targetEntity) then
		self.entityType = Const.HomelandEntType.Pet
	else
		self.entityType = targetEntity:getHomelandConfigData().entityType or Const.HomelandEntType.Ornament
	end

	HomeEntityEditor.super.doStartEdit(self, targetEntity)
end

function HomeEntityEditor:startEditNewPet(entityData, placeConfig)
	self:beforeEdit()

	self.placeConfig = placeConfig or {}
	self.entityData = entityData
	self.entityType = Const.HomelandEntType.Pet

	self:doStartEditNew(nil, entityData, nil)
end

function HomeEntityEditor:startEditNew(homeTemplateId, entityData, initInfo, placeConfig)
	self:beforeEdit()

	self.targetEntity = nil
	self.entityData = entityData
	self.placeConfig = placeConfig or {}

	local homeObjData = HomeObjectData[homeTemplateId] or {}

	self.entityType = homeObjData.entityType or Const.HomelandEntType.Ornament

	self:doStartEditNew(homeTemplateId, entityData, initInfo)
end

function HomeEntityEditor:startEditBlueprint(blueprintData, initInfo, placeConfig)
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

	local startRotation = initInfo and initInfo.rotation or self:getDefaultRotation()
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

function HomeEntityEditor:getEditLayerFilter()
	if self.entityType == Const.HomelandEntType.Pet then
		return Const.HOMELAND_ORNAMENT_LAYER.Default
	end

	local filter = 0

	if self.templateEntity then
		filter = self.templateEntity:getOrnamentLayer()
	end

	return filter
end

function HomeEntityEditor:onEditModeChanged(isInEditMode)
	self:updateEnvSimulate()
	pg.global.ui.homelandEditorTopLogo:onEditModeChanged()
	self:updateHomeEntityEffect()
	self:refreshEffectGridLayerFilter()
end

function HomeEntityEditor:refreshEffectGridLayerFilter()
	return
end

function HomeEntityEditor:getEntityMaxPlaceNum(templateId)
	return pg.me:getOrnamentAreaMaxPlaceNum(templateId, self.areaId or 0)
end

function HomeEntityEditor:getEntityCurPlaceNum(templateId, ignorePlaceId)
	return pg.me:getOrnamentAreaCurPlaceNum(templateId, self.areaId or 0)
end

function HomeEntityEditor:createPreviewObject(homeTemplateId, entityData, screenPos)
	if self.templateEntity ~= nil then
		return
	end

	self:destroyPreviewObject()

	self.entityData = entityData

	local homeObjData = HomeObjectData[homeTemplateId] or {}

	self.entityType = homeObjData.entityType or Const.HomelandEntType.Ornament

	local rotation = self:getDefaultRotation()

	screenPos = screenPos or Vector2(Screen.width * 0.5, Screen.height * 0.5)

	local valid, targetPosition = self:getScreenCastPosition(screenPos)

	targetPosition = self:clampPosition(targetPosition, self:getEditAreaRangeRange(homeTemplateId), homeTemplateId)
	self.previewEntity = self:createTemplateObject(self.entityType, homeTemplateId, targetPosition, rotation, homeObjData, {
		isPreview = true
	})

	self:updateEditEntityState()
end

function HomeEntityEditor:createTemplateBlueprintObject(blueprintData, position, rotation, isPreview)
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
		local childEntity = self:createTemplateObject(homeObjData.entityType or Const.HomelandEntType.Ornament, homeId, templateEntity:getRelativePosition(relativePosition), templateEntity:getRelativeRotation(relativeRotation), homeObjData, {
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

function HomeEntityEditor:clampBlueprintGroupPosition(templateEntity, position)
	local oldTemplateEntity = self.templateEntity

	self.templateEntity = templateEntity

	local clampedPosition = self:clampPosition(position)

	self.templateEntity = oldTemplateEntity

	return clampedPosition
end

function HomeEntityEditor:createBlueprintPreviewObject(blueprintData, screenPos)
	if self.templateEntity ~= nil then
		return nil
	end

	self:destroyPreviewObject()

	self.entityData = blueprintData
	self.entityType = Const.HomelandEntType.Ornament
	screenPos = screenPos or Vector2(Screen.width * 0.5, Screen.height * 0.5)

	local _, targetPosition = self:getScreenCastPosition(screenPos)
	local rotation = self:getDefaultRotation()
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

function HomeEntityEditor:destroyPreviewObject()
	self:destroyTemplateObject(self.previewEntity)

	self.previewEntity = nil
end

function HomeEntityEditor:updatePreviewObjectPosition(screenPos)
	if self.previewEntity == nil then
		return
	end

	local valid, targetPosition = self:getScreenCastPosition(screenPos, self.previewEntity:getPosition().y)

	if self.previewEntity.homeTemplateId then
		targetPosition = self:clampPosition(targetPosition, self:getEditAreaRangeRange(self.previewEntity.homeTemplateId), self.previewEntity.homeTemplateId)
	else
		targetPosition = self:clampBlueprintGroupPosition(self.previewEntity, targetPosition)
	end

	self.previewEntity:setPosition(targetPosition)
	self.previewEntity:onEntityPositionChanged()
end

function HomeEntityEditor:createPreviewPet(entityData, screenPosX, screenPosY)
	if self.templateEntity ~= nil then
		return
	end

	self:destroyPreviewObject()

	self.entityData = entityData
	self.entityType = Const.HomelandEntType.Pet

	local rotation = Quaternion.identity
	local screenCenter = Vector2(Screen.width * (screenPosX or 0.5), Screen.height * (screenPosY or 0.5))
	local valid, targetPosition = self:getScreenCastPosition(screenCenter)

	targetPosition = self:clampPosition(targetPosition)

	local templateData = {
		petId = entityData.petId
	}

	self.previewEntity = self:createTemplateObject(self.entityType, nil, targetPosition, rotation, templateData, {
		isPreview = true
	})

	self:updateEditEntityState()
end

function HomeEntityEditor:finishEdit()
	local petIds = {}

	if self.isInEditMode and self.entityType == Const.HomelandEntType.Pet then
		for _, entity in pairs(self.editingOriginEntities) do
			petIds[entity.id] = true
		end

		if self.editType == ClientConst.EntityEditType.Create then
			petIds[self.entityData.petId] = true
		end
	end

	self:clearEnvSimulateEditor()
	self:destroyTemplateObject(self.previewEntity)

	self.previewEntity = nil
	self.entityType = nil

	HomeEntityEditor.super.finishEdit(self)

	if pg.space then
		for petId in pairs(petIds) do
			pg.space:homeLeisureManualOperationFinished(petId)
		end
	end
end

function HomeEntityEditor:trySelectRaycastEntity(screenPos, selectType, withHitPoint, onlyEditingEntity)
	selectType = selectType or ClientConst.HomeSelectType.All

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
		if ent and not ent.destroyed and ent.visible ~= false then
			local selectable = false

			if selectType ~= ClientConst.HomeSelectType.Pet and ent.ornamentId then
				selectable = true
			end

			if not selectable and selectType ~= ClientConst.HomeSelectType.Ornament and Utils.isHomePet(ent) then
				selectable = true
			end

			if selectable and (not onlyEditingEntity or self.editingEntities[ent.id]) then
				return ent, hitPoints and hitPoints[i]
			end
		end
	end
end

function HomeEntityEditor:trySelectEntity(screenPos, selectType)
	local selectEnt = self:trySelectRaycastEntity(screenPos, selectType)

	if selectEnt then
		return selectEnt
	end

	local valid, placePos = HomeEditorUtils.GetRaycastPlacePosition(screenPos, 0)

	return pg.game.home:getPositionOrnament(self.areaId, placePos)
end

function HomeEntityEditor:tryBoxSelectEntities(screenPosStart, screenPosEnd, selectType, entities)
	selectType = selectType or ClientConst.HomeSelectType.All

	table.clear(entities)
	table.clear(self.tempHitEntities)

	local valid = false

	HomeEditorUtils.GetSelectBoxHitEntities(screenPosStart, screenPosEnd, 150, self.tempHitEntities)

	for _, ent in ipairs(self.tempHitEntities) do
		if ent and not ent.destroyed and ent.visible ~= false then
			if selectType ~= ClientConst.HomeSelectType.Pet and ent.ornamentId then
				entities[ent.id] = ent
			end

			if selectType ~= ClientConst.HomeSelectType.Ornament and Utils.isHomePet(ent) then
				entities[ent.id] = ent
			end
		end
	end
end

function HomeEntityEditor:createTemplateObject(templateType, templateId, position, rotation, templateData, extraInfo)
	local className = "ClientHomeEditorTemplateEntity"
	local virtualOrnamentId

	if not extraInfo or not extraInfo.isPet then
		virtualOrnamentId = pg.game.home:genVirtualOrnamentId()
	end

	templateId = templateId or 0

	local ornamentInfo = OrnamentSingleData.new(HomeLandUtils.fillOrnamentTransform({
		homeId = templateId,
		areaId = self.areaId
	}, self:getLocalPosition(position), self:getLocalRotation(rotation), Vector3.constOne))
	local isPreview = false
	local originEntity

	if extraInfo then
		isPreview = extraInfo.isPreview
		originEntity = extraInfo.originEntity

		if extraInfo.ornamentInfo then
			ornamentInfo.electricMode = extraInfo.ornamentInfo.electricMode
		end
	end

	local initScale = extraInfo and extraInfo.initScale
	local templateEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		editor = self,
		areaId = self.areaId,
		ornamentId = virtualOrnamentId,
		ornamentInfo = ornamentInfo,
		templateType = templateType,
		templateData = templateData,
		homeTemplateId = templateId,
		initPosition = position,
		initRotation = rotation,
		initScale = initScale,
		isPreview = isPreview,
		originEntity = originEntity
	})

	return templateEntity
end

function HomeEntityEditor:onStartEditEntity()
	if self.templateEntity then
		self.templateEntity:setHomeEditState(ClientConst.HomeEntEffectType.Edit)
	end

	self:updateEditEntityState()
	self:refreshBuildAttachDisplay(self.templateEntity)
end

function HomeEntityEditor:updateEditEntityState()
	if self.templateEntity then
		self.templateEntity:updateHomeEditorState()
	end
end

function HomeEntityEditor:showConfirmEffect()
	return
end

function HomeEntityEditor:withdrawEnt()
	if self.entityType == Const.HomelandEntType.Pet then
		self.templateEntity:applyWithdrawData()
	else
		local applyData = {
			removeList = {}
		}

		self.templateEntity:applyWithdrawData(applyData)

		if not Utils.tableIsEmptyOrNil(applyData.removeList) then
			pg.me.space:removeOrnaments(applyData.removeList)
		end
	end
end

function HomeEntityEditor:withdrawMultiSelectEntities()
	local removeList = {}

	for entId, ent in pairs(self.multiSelectEntities) do
		if ent.ornamentId then
			table.insert(removeList, ent.ornamentId)
		end
	end

	if #removeList > 0 then
		pg.me.space:removeOrnaments(removeList)
	end
end

function HomeEntityEditor:getOrnamentWorkPosRot(ornamentId)
	return HomeLandUtils.getPosRotByOrnamentId(pg.me, ornamentId, 1)
end

function HomeEntityEditor:applyTemplateData()
	if self.entityType == Const.HomelandEntType.Pet then
		self.templateEntity:applyEditorTemplateData()

		return
	end

	local applyData = {
		updateData = {},
		createList = {}
	}
	local buildExtraData

	if self.buildAttachManager then
		buildExtraData = self.buildAttachManager:getEditorBuildExtraData()
	end

	if self.templateEntity then
		local homeBlueprintGroupInfoList = self.placeConfig and self.placeConfig.homeBlueprintGroupInfoList

		if homeBlueprintGroupInfoList and #homeBlueprintGroupInfoList > 0 then
			buildExtraData = buildExtraData or {}
			buildExtraData.homeBlueprintGroupInfoList = {}

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
			pg.me.space:addOrnaments(applyData.createList, buildExtraData)
		end

		if not Utils.tableIsEmptyOrNil(applyData.updateData) then
			pg.me.space:updateOrnaments(applyData.updateData, buildExtraData)
		end
	end
end

function HomeEntityEditor:onEditPetResult(isSucc, petId)
	if not self.confirmCallback then
		return
	end

	self:onFinishCallback(isSucc)
end

function HomeEntityEditor:onEditOrnamentResult(isSucc, operationType)
	if isSucc then
		self.needFixOrnamentsFloorLift = true
	end

	if not self.confirmCallback then
		return
	end

	self:onFinishCallback(isSucc, operationType)
end

function HomeEntityEditor:checkBoundInArea(position, rotation, bounds)
	local valid = HomeEntityEditor.super.checkBoundInArea(self, position, rotation, bounds)

	if valid and pg.game.home:checkBoundsLock(self.areaId or 0, position, rotation, bounds) then
		return false
	end

	return valid
end

function HomeEntityEditor:onEditorBuildModeChanged()
	if self.isInBuildMode then
		pg.global.ui.homelandEditorTopLogo:open()
		self:updateHomelandViewCenter()
		pg.game.home:showAreaZoneLockEffects(self.areaId)
	else
		pg.global.ui.homelandEditorTopLogo:close()
		pg.game.home:hideZoneLockEffects()
	end

	self:updateHomeEntityEffect()
end

function HomeEntityEditor:updateHomeEntityEffect()
	for _, entity in pairs(pg.game.home.homeEntities) do
		if entity.updateEditorEffect then
			entity:updateEditorEffect()
		end
	end

	self:updateAllLinkEffects(true)
end

function HomeEntityEditor:onOrnamentPositionChanged(ornamentId, ent, isTemplateEntity)
	if Utils.isHomeLinkFacilityType(ent.homeFacilityType) and self.envEditor and self.envEditor.homeLinkMap then
		local linkInfo = self.envEditor.homeLinkMap[ornamentId]

		if linkInfo then
			for linkId, _ in pairs(linkInfo.linkIds) do
				local effectId, key1, key2

				if linkId < ornamentId then
					key1 = ornamentId
					key2 = linkId
					effectId = (self.linkEffects[ornamentId] or EMPTY_TABLE)[linkId]
				else
					key1 = linkId
					key2 = ornamentId
					effectId = (self.linkEffects[linkId] or EMPTY_TABLE)[ornamentId]
				end

				if effectId then
					self:playOrUpdateLinkEffect(key1, key2, effectId)
				end
			end
		end
	end
end

function HomeEntityEditor:markLinkEffectDirty()
	self.linkEffectDirty = true
end

function HomeEntityEditor:updateAllLinkEffects(force)
	if not force and not self.linkEffectDirty then
		return
	end

	if not self.isInEditMode or not pg.game.home.linkEffectVisible or not self.envEditor.homeLinkMap then
		self:destroyLinkEffects()

		return
	end

	self.linkEffectDirty = false

	for ornamentId, linkInfo in pairs(self.envEditor.homeLinkMap) do
		for linkId, _ in pairs(linkInfo.linkIds) do
			if linkId < ornamentId then
				self.linkEffects[ornamentId] = self.linkEffects[ornamentId] or {}
				self.linkEffects[ornamentId][linkId] = self:playOrUpdateLinkEffect(ornamentId, linkId, self.linkEffects[ornamentId][linkId])
			end
		end
	end

	for ornamentId, effectInfo in pairs(self.linkEffects) do
		for linkId, effectId in pairs(effectInfo) do
			local linkInfo = self.envEditor.homeLinkMap[ornamentId]

			if not linkInfo or not linkInfo.linkIds[linkId] then
				self:destroyLinkEffect(effectId)

				effectInfo[linkId] = nil
			end
		end
	end
end

function HomeEntityEditor:destroyLinkEffects()
	for ornamentId, curEffects in pairs(self.linkEffects) do
		for linkId, effectId in pairs(curEffects) do
			self:destroyLinkEffect(effectId)
		end
	end

	self.linkEffects = {}
end

function HomeEntityEditor:playOrUpdateLinkEffect(ornamentId1, ornamentId2, effectId)
	local ornament1 = pg.game.home:getHomeEntity(ornamentId1)
	local ornament2 = pg.game.home:getHomeEntity(ornamentId2)

	if not ornament1 or not ornament2 then
		return effectId
	end

	local _p1x, _p1y, _p1z = ornament1.eModel:GetPositionAgentPosEx()

	self.linkEffectSourcePosition:Set(_p1x, _p1y + 1, _p1z)

	local _p2x, _p2y, _p2z = ornament2.eModel:GetPositionAgentPosEx()

	self.linkEffectTargetPosition:Set(_p2x, _p2y + 1, _p2z)

	if effectId then
		pg.global.homelandMgr:UpdateLinkEffect(effectId, self.linkEffectSourcePosition, self.linkEffectTargetPosition)

		return effectId
	else
		return pg.global.homelandMgr:PlayLinkEffect(self.linkEffectSourcePosition, self.linkEffectTargetPosition)
	end
end

function HomeEntityEditor:destroyLinkEffect(effectId)
	pg.global.homelandMgr:StopLinkEffect(effectId)
end

function HomeEntityEditor:refreshShadows()
	pg.game.home:refreshShadows()
end

function HomeEntityEditor:restoreEditOriginEntities(entities)
	for _, entity in pairs(entities) do
		if entity.ornamentId then
			self.envEditor:addOrnament(entity.ornamentId, entity:getOrnamentInfo())
		end
	end

	HomeEntityEditor.super.restoreEditOriginEntities(self, entities)
end

function HomeEntityEditor:handleEditOriginEntities(entities)
	for _, entity in pairs(entities) do
		if entity.ornamentId then
			self.envEditor:removeOrnament(entity.ornamentId)
		end
	end

	HomeEntityEditor.super.handleEditOriginEntities(self, entities)
end

function HomeEntityEditor:getAreaOrnaments(minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
	return pg.game.home:getAreaOrnaments(self.areaId, minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
end

function HomeEntityEditor:getFastFindMap()
	return pg.game.home:getFastFindMap(self.areaId)
end

function HomeEntityEditor:getFloorLiftLocalY(localPosition, homeTemplateId)
	if not HomeLandUtils.checkHomeObjectFloorLift(homeTemplateId) then
		return 0
	end

	return pg.game.home:getFloorLiftLocalY(self.areaId, localPosition)
end

function HomeEntityEditor:checkFixOrnamentsFloorLift()
	if not self.needFixOrnamentsFloorLift then
		return
	end

	self.needFixOrnamentsFloorLift = false

	self:fixOrnamentsFloorLift()
end

function HomeEntityEditor:fixOrnamentsFloorLift()
	if not pg.me or not pg.me.space or not pg.me.space.ornament or not pg.me.space:isSelfHomeland() then
		return
	end

	local fastFindMap = pg.game.home:getFastFindMap(self.areaId)

	if not fastFindMap then
		return
	end

	local liftDict

	for ornamentId, fastInfo in pairs(fastFindMap.ornamentDict) do
		local extraInfo = fastInfo.extraInfo

		if extraInfo and pg.me.space.ornament[ornamentId] and HomeLandUtils.checkHomeObjectFloorLift(extraInfo.homeTemplateId) then
			local localPosition = fastInfo.position
			local expectY = pg.game.home:getFloorLiftLocalY(self.areaId, localPosition)

			if math.abs(expectY - localPosition.y) > HomeLandUtils.HOME_FLOOR_LIFT_EPSILON then
				liftDict = liftDict or {}
				liftDict[ornamentId] = expectY
			end
		end
	end

	if liftDict then
		pg.me.space:liftOrnaments(liftDict)
	end
end

function HomeEntityEditor:tickEditor()
	HomeEntityEditor.super.tickEditor(self)
	self:checkFixOrnamentsFloorLift()
end

function HomeEntityEditor:getBlueprintOrnaments(blueprintData)
	if type(blueprintData) ~= "table" then
		return nil
	end

	local ornaments = blueprintData.ornaments

	if type(ornaments) ~= "table" or #ornaments <= 0 then
		return nil
	end

	return ornaments
end

function HomeEntityEditor:getBlueprintPosition(pos3)
	pos3 = type(pos3) == "table" and pos3 or {}

	local positionBase = HomeLandUtils.ORNAMENT_POSITION_INT_BASE

	return Vector3.New((tonumber(pos3[1]) or 0) / positionBase, (tonumber(pos3[2]) or 0) / positionBase, (tonumber(pos3[3]) or 0) / positionBase)
end

function HomeEntityEditor:getBlueprintRotation(rot3)
	rot3 = type(rot3) == "table" and rot3 or {}

	local rotationBase = HomeLandUtils.ORNAMENT_ROTATION_INT_BASE

	return Quaternion.Euler((tonumber(rot3[1]) or 0) / rotationBase, (tonumber(rot3[2]) or 0) / rotationBase, (tonumber(rot3[3]) or 0) / rotationBase)
end

function HomeEntityEditor:getBlueprintScale(scale3)
	scale3 = type(scale3) == "table" and scale3 or {}

	local scaleBase = HomeLandUtils.ORNAMENT_SCALE_INT_BASE

	return Vector3.New((tonumber(scale3[1]) or scaleBase) / scaleBase, (tonumber(scale3[2]) or scaleBase) / scaleBase, (tonumber(scale3[3]) or scaleBase) / scaleBase)
end

return HomeEntityEditor
