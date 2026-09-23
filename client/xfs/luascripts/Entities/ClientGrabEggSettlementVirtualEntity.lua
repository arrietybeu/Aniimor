-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientGrabEggSettlementVirtualEntity.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientChest = require("Entities.SpaceEntities.ClientChest")
local ClientGrabEggSettlementVirtualEntity = Class.Class("ClientGrabEggSettlementVirtualEntity", ClientVirtualEntity)
local Utils = require("Common.Utils.Utils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local lume = require("Core.Common.lume")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ItemData = require("Data.item_data")
local CollectItemData = require("Data.collect_item_data")
local EggRandomModelIdData = require("Data.egg_random_model_id_data")
local EggIdToModelResData = require("Data.egg_id_to_model_res_data")
local EggPatternColorData = require("Data.egg_pattern_color_data")
local RigidbodyData = require("Data.rigidbody_data")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local VirtualChestComponents = {
	ClientPhysicsComponent,
	ClientModelComponent
}

if EnableBotTest then
	VirtualChestComponents = {}
end

Class.AddComponents(ClientGrabEggSettlementVirtualEntity, VirtualChestComponents)

function ClientGrabEggSettlementVirtualEntity:ctor(entityId)
	ClientGrabEggSettlementVirtualEntity.super.ctor(self, entityId)

	self.isInited = false
end

function ClientGrabEggSettlementVirtualEntity:init(bdict)
	ClientGrabEggSettlementVirtualEntity.super.init(self, bdict)

	self.templateId = bdict.templateId
	self.modelPosition = bdict.position
	self.modelScale = bdict.modelScale or 1
	self.rootTransform = bdict.rootTransform
	self.patternType = bdict.patternType
	self.patternColorType = bdict.patternColorType
	self.isInited = true
	self.configData = self:getConfigData() or {}
	self.isInScene = true

	return true
end

function ClientGrabEggSettlementVirtualEntity:start()
	ClientGrabEggSettlementVirtualEntity.super.start(self)
end

function ClientGrabEggSettlementVirtualEntity:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
	self:addEModelComponent(Const.COMPONENT_INDEX_EFFECT)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientGrabEggSettlementVirtualEntity:postInitializeComponents()
	ClientGrabEggSettlementVirtualEntity.super.postInitializeComponents(self)
	pg.me.space:onEntityJoin(self)
end

function ClientGrabEggSettlementVirtualEntity:refreshAppearance()
	ClientGrabEggSettlementVirtualEntity.super.refreshAppearance(self)

	self.eModel.itemModelView.keepPrefabLayer = false

	self:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	if not self.eModel then
		return
	end

	local eggPattern = self.patternType
	local modelDataInfo = EggIdToModelResData[eggPattern] or EggIdToModelResData[1]
	local modelRes = modelDataInfo.model

	if modelRes then
		self.eModel.itemModelView.forceColliderLayer = ClientConst.LayerDefine.LAYER_NOACROSS

		self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, modelRes)
	end
end

function ClientGrabEggSettlementVirtualEntity:setEggModel()
	local modelView = self.eModel.itemModelView
	local eggPatternColor = self.patternColorType
	local randomCfgData = EggRandomModelIdData[self.templateId] or EggRandomModelIdData[5010001]
	local modelScale = randomCfgData and randomCfgData.modelScale

	if modelScale then
		modelView:SetModelScale(modelScale)
		self:onSyncScale(modelScale)

		self.appliedModelScale = modelScale
	end

	ClientModelUtils.applyEggModelMaterialEffect(self, modelView, randomCfgData, eggPatternColor)

	self.isModelLoaded = true

	self.eModel:SetTransformParent(self.rootTransform, false)
	EModelUtils.setAgentPositionAndRotation(self, self.rootTransform.position + self.modelPosition, Quaternion(0, 0, 0, 1))
end

function ClientGrabEggSettlementVirtualEntity:getInteractionListData()
	return ClientChest.getInteractionListData(self)
end

function ClientGrabEggSettlementVirtualEntity:rescaleCollider()
	local modelScale = self.appliedModelScale or 1

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	local rigidbodyData = RigidbodyData.GrabEGG_Egg

	if not rigidbodyData then
		return
	end

	local radius = (ToBool(rigidbodyData.radius) and rigidbodyData.radius or 0.1) * modelScale
	local height = (ToBool(rigidbodyData.height) and rigidbodyData.height or 0.1) * modelScale
	local center

	if rigidbodyData.center == nil then
		center = Vector3.New(0, rigidbodyData.height * 0.5 * modelScale, 0)
	else
		center = Vector3.New()

		center:Copy(rigidbodyData.center)

		center.y = center.y * modelScale
	end

	local isTrigger = ToBool(rigidbodyData.trigger)

	self.eModel:GenCapsule(Const.COMPONENT_IDX_PHYSX, radius, height, center, isTrigger, false, true)
end

function ClientGrabEggSettlementVirtualEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self:setEggModel()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
	self:postComponentMethod("EVENT_EnterScene")
	self:postComponentMethod("EVENT_RefreshPhysx")
	self:rescaleCollider()
	self.eModel:SetCollisionDetectionMode(Const.COMPONENT_IDX_PHYSX, 3)
end

function ClientGrabEggSettlementVirtualEntity:onModelRefreshed()
	ClientVirtualEntity.onModelRefreshed(self)
end

function ClientGrabEggSettlementVirtualEntity:getConfigData()
	if not self.templateId then
		return self.configData
	end

	if not self.configData then
		self.configData = CollectItemData[self.templateId]
	end

	return self.configData
end

function ClientGrabEggSettlementVirtualEntity:isConfigKinematic()
	return false
end

function ClientGrabEggSettlementVirtualEntity:getTemplateId()
	return self.templateId
end

return ClientGrabEggSettlementVirtualEntity
