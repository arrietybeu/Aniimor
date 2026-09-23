-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeTemplateEditorComponent.lua

local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local HomeObjectData = require("Data.home_object_data")
local HomeFacilityData = require("Data.homeland_facility_data")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeTemplateEditorComponent = Class.Component("ClientHomeTemplateEditorComponent")

function ClientHomeTemplateEditorComponent:updateHomeEditorState()
	if not self.templateEntityType then
		return
	end

	self.collideOrnaments = self.collideOrnaments or {}

	table.clear(self.collideOrnaments)

	self.placementValid = self:checkPlacementValid(self.collideOrnaments)

	self:syncOverlapHint(self.collideOrnaments, self.placementValid)

	if self.templateEntityType == Const.HomelandEntType.Pet then
		self:refreshPetRelatedInfo(self.collideOrnaments)
	end

	local effectType = 8
	local showArrow = false

	if self.templateEntityType == Const.HomelandEntType.Pet then
		if self.placementValid ~= Const.HomeEditorErrorType.Normal then
			effectType = 3
		end

		if self.petRelateOrnamentId then
			if self.petOperValid then
				effectType = 2
			else
				effectType = 4
			end
		end
	else
		effectType = 8

		local configData = HomeObjectData[self.homeTemplateId] or {}

		if configData.needForwardIcon == 1 then
			showArrow = true
		end
	end

	self:updateEditorEffect()
	self:refreshEditorOutline()

	local boundHeight = 0

	if self.gridEffectType ~= effectType then
		self.gridEffectType = effectType

		if effectType ~= 0 then
			self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Default, effectType, self:getBaseBoundSize(), ClientConst.HomelandEffectBaseOffset, self:getBasePositionY(), nil, showArrow, boundHeight)
		else
			self:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.Default)
		end
	end
end

function ClientHomeTemplateEditorComponent:checkPlacementValid(colliderOrnaments)
	table.clear(colliderOrnaments)

	local valid = Const.HomeEditorErrorType.Normal
	local localPosition = self.editor:getLocalPosition(self:getPosition())
	local localRotation = self.editor:getLocalRotation(self:getRotation())

	if self.templateEntityType == Const.HomelandEntType.Pet then
		valid = Const.HomeEditorErrorType.Normal

		pg.game.home:checkPetPosCollide(self.areaId, localPosition, colliderOrnaments)
	elseif pg.game.home:checkPosCollide(self.areaId, self.ornamentId, colliderOrnaments, 0.01) then
		valid = Const.HomeEditorErrorType.Overlap
	end

	if not self.editor:checkBoundInArea(localPosition, localRotation, self:getBoundSize()) then
		valid = Const.HomeEditorErrorType.CrossBoundary
	end

	if valid == Const.HomeEditorErrorType.Normal and self.editor.displayHideMode and self.editor.displayHideMode ~= 0 and self.editor:isHeightOverCamera(localPosition.y) then
		valid = Const.HomeEditorErrorType.OverCameraHeight
	end

	if valid == Const.HomeEditorErrorType.Normal and not ClientHomelandUtils.checkHomelandLoadCanAdd({
		editor = self.editor,
		editInfo = self.editInfo,
		homeTemplateId = self.homeTemplateId,
		templateEntityType = self.templateEntityType
	}, self.areaId, nil) then
		valid = Const.HomeEditorErrorType.OverLoad
	end

	return valid
end

function ClientHomeTemplateEditorComponent:refreshPetRelatedInfo(collideOrnaments)
	self.petRelateOrnamentId = nil
	self.petRelateOperationId = nil
	self.petOperValid = false
	self.fitPersonality = nil

	if not pg.me or not pg.me.space.ornament then
		return
	end

	local petInfo = pg.me:getPetInfo(self.templateData.petId)

	if not petInfo then
		return
	end

	local petTemplateId = petInfo.templateId

	for ornamentId, _ in pairs(collideOrnaments) do
		local ornamentEnt = pg.game.home:getHomeEntity(ornamentId)

		if ornamentEnt and Utils.isClientHomeFacility(ornamentEnt) then
			local requireOperIds = ornamentEnt:getRequireOperIds()

			for _, requireOperId in ipairs(requireOperIds) do
				local petOperValid = Utils.checkHomePetCanDoOperId(petTemplateId, requireOperId)

				if petOperValid then
					self.petRelateOrnamentId = ornamentId
					self.petRelateOperationId = requireOperId
					self.petOperValid = true
				elseif not self.petOperValid and not self.petRelateOperationId then
					self.petRelateOrnamentId = ornamentId
					self.petRelateOperationId = requireOperId
				end
			end

			local nextOperId = ornamentEnt:getNextOperId()

			if nextOperId then
				local petOperValid = Utils.checkHomePetCanDoOperId(petTemplateId, nextOperId)

				if petOperValid then
					self.petRelateOrnamentId = ornamentId
					self.petRelateOperationId = nextOperId
					self.petOperValid = true
				elseif not self.petOperValid and not self.petRelateOperationId then
					self.petRelateOrnamentId = ornamentId
					self.petRelateOperationId = nextOperId
				end
			end
		end
	end

	if self.petOperValid then
		local ornamentEnt = pg.game.home:getHomeEntity(self.petRelateOrnamentId)

		self.fitPersonality = Utils.getHomePetFitPersonality(petInfo, ornamentEnt:getFacilityId())
	end
end

function ClientHomeTemplateEditorComponent:refreshEditorOutline()
	if self.placementValid == Const.HomeEditorErrorType.Normal then
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.Edit, true, AddressDataConst.HOMELAND_OUTLINE_GREEN)
	else
		self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.Edit, true, AddressDataConst.HOMELAND_OUTLINE_RED, AddressDataConst.HOMELAND_OUTLINE_RED_INNER)
	end
end

function ClientHomeTemplateEditorComponent:applyEditorTemplateData(applyData)
	if not self.templateEntityType then
		return
	end

	if self.templateEntityType == Const.HomelandEntType.Pet then
		self:applyEditorPetTemplateData()

		return
	end

	if self.templateEntityType == Const.HomelandEntType.Ornament then
		self:applyEditorOrnamentTemplateData(applyData)

		return
	end
end

function ClientHomeTemplateEditorComponent:applyWithdrawData(applyData)
	if not self.originEntity then
		return
	end

	if self.templateEntityType == Const.HomelandEntType.Pet then
		pg.me.space:removeHomelandPet(self.originEntity.id, -1, -1)

		return
	end

	if self.templateEntityType == Const.HomelandEntType.Ornament then
		table.insert(applyData.removeList, self.originEntity.ornamentId)
	end
end

function ClientHomeTemplateEditorComponent:applyEditorPetTemplateData()
	if not self.originEntity then
		return
	end

	local petId = self.originEntity.id

	if not petId then
		return
	end

	if self.petRelateOrnamentId then
		if self.petOperValid then
			local pos, yaw = HomeLandUtils.getPosRotByOrnamentId(pg.me, self.petRelateOrnamentId, 1)

			if pos and yaw then
				pg.me.space:updateHomelandPet(petId, pos, Quaternion.Euler(0, yaw, 0))
			else
				pg.me.space:updateHomelandPet(petId, self:getValidHomePetPosition(), self:getRotation())
			end

			pg.me.space:allocateHomePetWork(petId, self.petRelateOrnamentId, self.petRelateOperationId, true)
		else
			pg.me.space:updateHomelandPet(petId, self:getValidHomePetPosition(), self:getRotation())
			pg.me.space:allocateHomePetWork(petId, self.petRelateOrnamentId, 0, true)
		end
	else
		pg.me.space:updateHomelandPet(petId, self:getValidHomePetPosition(), self:getRotation())
		pg.me.space:deallocateHomePetWork(petId, nil, true)
	end
end

function ClientHomeTemplateEditorComponent:applyEditorOrnamentTemplateData(applyData)
	if self.originEntity then
		applyData.updateData[self.originEntity.ornamentId] = {
			clientOrnamentId = self.ornamentId,
			position = self.editor:getLocalPosition(self:getPosition()),
			rotation = self.editor:getLocalRotation(self:getRotation()),
			scale = self:getScale(),
			areaId = self.areaId
		}
	else
		table.insert(applyData.createList, {
			clientOrnamentId = self.ornamentId,
			homeTemplateId = self.homeTemplateId,
			position = self.editor:getLocalPosition(self:getPosition()),
			rotation = self.editor:getLocalRotation(self:getRotation()),
			scale = self:getScale(),
			areaId = self.areaId
		})
	end
end

function ClientHomeTemplateEditorComponent:getEditorEnvRelatedInfo(otherEnt, infoData)
	local facilityType = self.homeFacilityType

	if facilityType then
		local valid = false

		if Const.HOMELAND_ENV_FACILITY_RELATED_INFO[facilityType] and Const.HOMELAND_ENV_FACILITY_RELATED_INFO[facilityType][otherEnt.homeFacilityType] then
			valid = true
		end

		if Const.HOMELAND_ENV_ORNAMENT_LINK_INFO[facilityType] and Const.HOMELAND_ENV_ORNAMENT_LINK_INFO[facilityType][otherEnt.homeFacilityType] then
			valid = true
		end

		if valid then
			if otherEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
				local editorFacilityInfo = otherEnt:getEditorFacilityInfo()

				if editorFacilityInfo.formulaId and Utils.checkEnvReqRelated(editorFacilityInfo.formulaId, facilityType) then
					infoData[self.ornamentId] = self
				end
			else
				infoData[self.ornamentId] = self
			end
		end
	end
end

function ClientHomeTemplateEditorComponent:syncOverlapHint(curCollideMap, placementValid)
	local newSet = self.tempOverlapHintSet or {}

	table.clear(newSet)

	if placementValid == Const.HomeEditorErrorType.Overlap and self.templateEntityType ~= Const.HomelandEntType.Pet then
		for id, _ in pairs(curCollideMap) do
			newSet[id] = true
		end
	end

	local prevSet = self.overlapHintIds or {}

	for id, _ in pairs(prevSet) do
		if not newSet[id] then
			local ornamentEnt = pg.game.home:getHomeEntity(id)

			if ornamentEnt and ornamentEnt.stopEditorBoundEffect then
				ornamentEnt:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.OverlapHint)
			end
		end
	end

	for id, _ in pairs(newSet) do
		if not prevSet[id] then
			local ornamentEnt = pg.game.home:getHomeEntity(id)

			if ornamentEnt and ornamentEnt.playEditorBoundEffect and ornamentEnt.getBaseBoundSize then
				local boundHeight = 0

				ornamentEnt:playEditorBoundEffect(ClientConst.EntityEditorBoundType.OverlapHint, 8, ornamentEnt:getBaseBoundSize(), ClientConst.HomelandEffectBaseOffset, self:getBasePositionY(), nil, false, boundHeight)
			end
		end
	end

	self.overlapHintIds = newSet
	self.tempOverlapHintSet = prevSet
end

function ClientHomeTemplateEditorComponent:clearOverlapHint()
	if not self.overlapHintIds then
		return
	end

	for id, _ in pairs(self.overlapHintIds) do
		local ornamentEnt = pg.game.home:getHomeEntity(id)

		if ornamentEnt and ornamentEnt.stopEditorBoundEffect then
			ornamentEnt:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.OverlapHint)
		end
	end

	table.clear(self.overlapHintIds)
end

return ClientHomeTemplateEditorComponent
