-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioPetPlaceAdapter.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientConst = require("Const.ClientConst")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local StudioPetPlaceAdapter = Class.LightClass("StudioPetPlaceAdapter", UIComponent)

function StudioPetPlaceAdapter:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)

	self.petEntity = {}
	self.virtualToRealIdMap = {}
	self.rotationMap = {}
	self.visibleMap = {}
end

function StudioPetPlaceAdapter:getScene()
	return self.ctrl:getStudioScene()
end

function StudioPetPlaceAdapter:getStudioPetIdentity(petIdOrEntityId, ownerUid)
	local parsedOwnerUid, parsedPetId = PhotographyStudioUtils.parseStudioPetEntityId(petIdOrEntityId)

	if parsedPetId then
		return petIdOrEntityId, parsedOwnerUid, parsedPetId
	end

	if not petIdOrEntityId then
		return nil, nil, nil
	end

	local realOwnerUid = ownerUid or pg.me.uid

	return PhotographyStudioUtils.buildStudioPetEntityId(realOwnerUid, petIdOrEntityId), realOwnerUid, petIdOrEntityId
end

function StudioPetPlaceAdapter:createPet(petId, ownerUid, petData)
	local entityId, realOwnerUid, realPetId = self:getStudioPetIdentity(petId, ownerUid)

	if not entityId then
		return nil
	end

	if self.petEntity[entityId] then
		return self.petEntity[entityId]
	end

	local scene = self:getScene()

	if not scene then
		return nil
	end

	local entity = scene:spawnStudioPet(realPetId, realOwnerUid, nil, nil, petData)

	if not entity then
		return nil
	end

	self.petEntity[entityId] = entity
	self.virtualToRealIdMap[entity.id] = entityId
	self.rotationMap[entity.id] = 0
	self.visibleMap[entityId] = true

	entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, true)

	return entity
end

function StudioPetPlaceAdapter:selectPetEntity(petId, showUI)
	return self:createPet(petId)
end

function StudioPetPlaceAdapter:registerPetEntity(entityId, entity)
	if not entityId or not entity or not entity.id then
		return
	end

	self.virtualToRealIdMap[entity.id] = entityId
end

function StudioPetPlaceAdapter:getPetEntity(entityId)
	if not entityId then
		return nil
	end

	local realEntityId = self.virtualToRealIdMap[entityId]

	if realEntityId then
		local entity = self.petEntity[realEntityId]

		if entity then
			return entity
		end

		local scene = self:getScene()

		return scene and scene:getStudioPet(realEntityId) or nil
	end

	if self.petEntity[entityId] then
		return self.petEntity[entityId]
	end

	local selfEntityId = PhotographyStudioUtils.buildStudioPetEntityId(pg.me.uid, entityId)
	local entity = selfEntityId and self.petEntity[selfEntityId] or nil

	if entity then
		return entity
	end

	local scene = self:getScene()

	return scene and scene:getStudioPet(entityId) or nil
end

function StudioPetPlaceAdapter:getRealEntityId(virtualId)
	return self.virtualToRealIdMap[virtualId]
end

function StudioPetPlaceAdapter:retrievePet(entityId)
	if not entityId then
		return
	end

	local realEntityId = self.virtualToRealIdMap[entityId] or entityId

	if not self.petEntity[realEntityId] then
		realEntityId = PhotographyStudioUtils.buildStudioPetEntityId(pg.me.uid, entityId)
	end

	if not realEntityId then
		return
	end

	local entity = self.petEntity[realEntityId]

	if entity then
		self.virtualToRealIdMap[entity.id] = nil
		self.rotationMap[entity.id] = nil
	end

	self.petEntity[realEntityId] = nil
	self.visibleMap[realEntityId] = nil

	local scene = self:getScene()

	if scene then
		scene:removeStudioPet(realEntityId)
	end
end

function StudioPetPlaceAdapter:setPetVisible(entityId, isVisible)
	if not entityId then
		return
	end

	local realEntityId = self.virtualToRealIdMap[entityId] or entityId
	local entity = self.petEntity[realEntityId]

	if not entity then
		local scene = self:getScene()

		entity = scene and scene:getStudioPet(realEntityId)
	end

	if not entity and isVisible then
		entity = self:createPet(realEntityId)
		realEntityId = entity and entity.studioPetEntityId or realEntityId
	end

	if not entity then
		return
	end

	self.visibleMap[realEntityId] = isVisible == true

	entity:setVisible(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, isVisible == true)
end

function StudioPetPlaceAdapter:isPetVisible(entityId)
	if not entityId then
		return false
	end

	local realEntityId = self.virtualToRealIdMap[entityId] or entityId
	local entity = self.petEntity[realEntityId]

	if not entity then
		local scene = self:getScene()

		entity = scene and scene:getStudioPet(realEntityId)
	end

	return entity ~= nil and self.visibleMap[realEntityId] ~= false
end

function StudioPetPlaceAdapter:updateUIAttach()
	return
end

function StudioPetPlaceAdapter:onPageChange(enter)
	return
end

function StudioPetPlaceAdapter:showUI(show)
	return
end

function StudioPetPlaceAdapter:refreshCanMovePetState()
	return
end

function StudioPetPlaceAdapter:destroy()
	self.petEntity = {}
	self.virtualToRealIdMap = {}
	self.rotationMap = {}
	self.visibleMap = {}
end

return StudioPetPlaceAdapter
