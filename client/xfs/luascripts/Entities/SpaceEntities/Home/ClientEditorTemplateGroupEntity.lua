-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientEditorTemplateGroupEntity.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientEditorTemplateGroupComponent = require("Entities.SpaceEntities.Home.ClientEditorTemplateGroupComponent")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local Utils = require("Common.Utils.Utils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientEditorTemplateGroupEntity = Class.Class("ClientEditorTemplateGroupEntity", ClientModelEntity)
local ClientEditorTemplateGroupEntityComponents = {
	ClientEditorTemplateGroupComponent,
	ClientEntityEditorComponent
}

Class.AddComponents(ClientEditorTemplateGroupEntity, ClientEditorTemplateGroupEntityComponents)

function ClientEditorTemplateGroupEntity:ctor(entityId)
	ClientEditorTemplateGroupEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
	self.childEntities = {}
end

function ClientEditorTemplateGroupEntity:init(dict)
	local result = ClientEditorTemplateGroupEntity.super.init(self, dict)

	self.editor = dict.editor
	self.areaId = dict.areaId
	self.baseTransMatrixInv = self.baseTransMatrixInv or dict.baseTransMatrixInv
	self.initPosition = dict.initPosition
	self.initRotation = dict.initRotation

	return result
end

function ClientEditorTemplateGroupEntity:destroy()
	self:destroyChildEntities()
	ClientEditorTemplateGroupEntity.super.destroy(self)
end

function ClientEditorTemplateGroupEntity:initializeComponents()
	self:setPosition(self.initPosition)
	self:setRotation(self.initRotation)
	self:postComponentMethod("EVENT_AddEComponent")
end

function ClientEditorTemplateGroupEntity:getRelativePosition(posOffset)
	return self:getRotation() * posOffset + self:getPosition()
end

function ClientEditorTemplateGroupEntity:getInverseRelativePosition(position)
	return self:getRotation():Inverse() * (position - self:getPosition())
end

function ClientEditorTemplateGroupEntity:getScale()
	if self.eModel then
		local x, y, z = self.eModel:GetPositionAgentLocalScaleEx()

		return Vector3.New(x, y, z)
	end

	return Vector3.New(1, 1, 1)
end

function ClientEditorTemplateGroupEntity:getRelativeRotation(rotOffset)
	return self:getRotation() * rotOffset
end

function ClientEditorTemplateGroupEntity:getInverseRelativeRotation(rotation)
	return self:getRotation():Inverse() * rotation
end

function ClientEditorTemplateGroupEntity:addChildEntity(entity, relativePos, relativeRot, isMainEntity)
	if not relativePos then
		local px, py, pz = entity.eModel:GetPositionAgentPosEx()

		relativePos = self:getInverseRelativePosition(Vector3.New(px, py, pz))
	end

	if not relativeRot then
		local rx, ry, rz, rw = entity.eModel:GetPositionAgentRotationEx()

		relativeRot = self:getInverseRelativeRotation(Quaternion(rx, ry, rz, rw))
	end

	self.childEntities[entity.id] = {
		entity = entity,
		relativePos = relativePos,
		relativeRot = relativeRot
	}

	entity:setEditParent(self)

	if isMainEntity then
		self.mainChildEntity = entity
	end

	self.boundDirty = true

	self:onChildEntityAdded(entity)
end

function ClientEditorTemplateGroupEntity:removeChildEntity(entity)
	self.boundDirty = true

	self:onChildEntityRemove(entity)

	if self.mainChildEntity == entity then
		self.mainChildEntity = nil
	end

	entity:setEditParent(nil)

	self.childEntities[entity.id] = nil
end

function ClientEditorTemplateGroupEntity:destroyChildEntities()
	self.boundDirty = true

	for _, childEntityInfo in pairs(self.childEntities) do
		self:onChildEntityDestroy(childEntityInfo.entity)
		ClientUtils.safeDestroy(childEntityInfo.entity)
	end

	self.childEntities = {}
end

function ClientEditorTemplateGroupEntity:onEntityPositionChanged()
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		if childEntity.onEntityPositionChanged then
			childEntity:onEntityPositionChanged()
		end
	end

	self:postComponentMethod("EVENT_onEntityPositionChanged")
end

function ClientEditorTemplateGroupEntity:getChildEntities(entitiesDict)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		entitiesDict[childEntity.id] = childEntity
	end
end

function ClientEditorTemplateGroupEntity:getGroupMainEntity()
	return self.mainChildEntity
end

function ClientEditorTemplateGroupEntity:getBoundAreaRange(isLocal)
	if self.boundDirty then
		self:updateBoundAreaRange()

		self.boundDirty = false
	end

	local minX = self.boundAreRangeInfo.minX
	local maxX = self.boundAreRangeInfo.maxX
	local minZ = self.boundAreRangeInfo.minZ
	local maxZ = self.boundAreRangeInfo.maxZ
	local minY = self.boundAreRangeInfo.minY
	local maxY = self.boundAreRangeInfo.maxY

	if isLocal then
		return minX, maxX, minZ, maxZ, minY, maxY
	end

	Vector3.enableCreateFromCache()

	local rotation = self:getRotation()

	if self.baseTransMatrixInv then
		rotation = self.baseTransMatrixInv.rotation * rotation
	end

	local worldMinX, worldMaxX = math.huge, -math.huge
	local worldMinZ, worldMaxZ = math.huge, -math.huge
	local x1, _, z1 = rotation:MulXYZNoGC(minX, 0, minZ)
	local x2, _, z2 = rotation:MulXYZNoGC(maxX, 0, minZ)
	local x3, _, z3 = rotation:MulXYZNoGC(minX, 0, maxZ)
	local x4, _, z4 = rotation:MulXYZNoGC(maxX, 0, maxZ)

	worldMinX = math.min(x1, x2, x3, x4)
	worldMaxX = math.max(x1, x2, x3, x4)
	worldMinZ = math.min(z1, z2, z3, z4)
	worldMaxZ = math.max(z1, z2, z3, z4)

	Vector3.disableCreateFromCache()

	return worldMinX, worldMaxX, worldMinZ, worldMaxZ, minY, maxY
end

function ClientEditorTemplateGroupEntity:onUpdateHomeEditorState()
	if self.boundEffectDirtyFlag then
		self.boundEffectDirtyFlag = false

		self:updateGroupBoundsEffect()
	end
end

function ClientEditorTemplateGroupEntity:checkShowBoundAreaEffect()
	return true
end

function ClientEditorTemplateGroupEntity:updateGroupBoundsEffect()
	local minX, maxX, minZ, maxZ, minY, maxY = self:getBoundAreaRange(true)

	self.groupBoundSize = self.groupBoundSize or {}
	self.groupBoundSize[1] = maxX - minX
	self.groupBoundSize[2] = maxZ - minZ
	self.groupBoundSize[3] = maxY - minY

	local offsetX = (maxX + minX) * 0.5
	local offsetZ = (maxZ + minZ) * 0.5
	local showBoundHeight = self.groupBoundSize[3]

	if not self:checkShowBoundAreaEffect() then
		showBoundHeight = false
	end

	self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Default, 8, self.groupBoundSize, ClientConst.HomelandEffectBaseOffset, self.editor:getBaseY(), nil, false, showBoundHeight, offsetX, offsetZ)
end

function ClientEditorTemplateGroupEntity:updateBoundAreaRange()
	local minX, maxX, minZ, maxZ = 0, 0, 0, 0
	local minY, maxY = 0, 0

	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity
		local childMinX, childMaxX, childMinZ, childMaxZ, childMinY, childMaxY = childEntity:getBoundAreaRange(true)

		if Utils.checkRotationIsVertical(childEntityInfo.relativeRot) then
			childMinX, childMaxX, childMinZ, childMaxZ = childMinZ, childMaxZ, childMinX, childMaxX
		end

		local positionOffset = childEntityInfo.relativePos

		minX = math.min(minX, childMinX + positionOffset.x)
		maxX = math.max(maxX, childMaxX + positionOffset.x)
		minZ = math.min(minZ, childMinZ + positionOffset.z)
		maxZ = math.max(maxZ, childMaxZ + positionOffset.z)
		minY = math.min(minY, childMinY + positionOffset.y)
		maxY = math.max(maxY, childMaxY + positionOffset.y)
	end

	self.boundAreRangeInfo = self.boundAreRangeInfo or {}
	self.boundAreRangeInfo.minX = minX
	self.boundAreRangeInfo.maxX = maxX
	self.boundAreRangeInfo.minZ = minZ
	self.boundAreRangeInfo.maxZ = maxZ
	self.boundAreRangeInfo.minY = minY
	self.boundAreRangeInfo.maxY = maxY
end

function ClientEditorTemplateGroupEntity:getOrnamentLayer()
	local layer = 0

	for _, childEntityInfo in pairs(self.childEntities) do
		layer = bit.bor(layer, childEntityInfo.entity:getOrnamentLayer())
	end

	return layer
end

function ClientEditorTemplateGroupEntity:setPosition(position)
	EModelUtils.setAgentPosition(self, position)

	for _, childEntityInfo in pairs(self.childEntities) do
		local relativePos = childEntityInfo.relativePos
		local pos = self:getRelativePosition(relativePos)

		childEntityInfo.entity:setPosition(pos)
	end
end

function ClientEditorTemplateGroupEntity:checkHitEntity(screenPos, hitEntities)
	for _, childEntityInfo in pairs(self.childEntities) do
		local childEntity = childEntityInfo.entity

		if childEntity:checkHitEntity(screenPos, hitEntities) then
			return true
		end
	end

	return false
end

function ClientEditorTemplateGroupEntity:setRotation(rotation)
	ClientEditorTemplateGroupEntity.super.setRotation(self, rotation)

	for _, childEntityInfo in pairs(self.childEntities) do
		local relativePos = childEntityInfo.relativePos
		local relativeRot = childEntityInfo.relativeRot
		local pos = self:getRelativePosition(relativePos)
		local rot = self:getRelativeRotation(relativeRot)

		childEntityInfo.entity:setPosition(pos)
		childEntityInfo.entity:setRotation(rot)
	end
end

function ClientEditorTemplateGroupEntity:setScale(scale)
	for _, childEntityInfo in pairs(self.childEntities) do
		local relativePos = childEntityInfo.relativePos
		local pos = self:getRelativePosition(relativePos)

		childEntityInfo.entity:setPosition(pos)
		childEntityInfo.entity:setScale(scale)
	end
end

function ClientEditorTemplateGroupEntity:onChildEntityAdded(entity)
	if entity and entity.setEditorBoundEffectVisible then
		entity:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Default, ClientConst.EditorEffectVisibleReason.GroupEdit, false)
	end

	self.boundEffectDirtyFlag = true
end

function ClientEditorTemplateGroupEntity:onChildEntityRemove(entity)
	if entity and entity.setEditorBoundEffectVisible then
		entity:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Default, ClientConst.EditorEffectVisibleReason.GroupEdit, true)
	end

	self.boundEffectDirtyFlag = true
end

function ClientEditorTemplateGroupEntity:onChildEntityDestroy(entity)
	return
end

return ClientEditorTemplateGroupEntity
