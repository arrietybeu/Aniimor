-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceFurniture\\ClientSpaceFurniture.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local InteractionConst = require("Common.Const.InteractionConst")
local UIConst = require("Const.UIConst")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientModelBatchComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientSpaceFurniture = Class.Class("ClientSpaceFurniture", ClientModelEntity)

ClientSpaceFurniture.BORN_SCALE_TWEEN_ID = "spaceFurnitureBornScale"
ClientSpaceFurniture.BORN_SCALE_DURATION = 0.2

local ClientSpaceFurnitureComponents = {
	ClientAoiComponent,
	ClientInteractionComponent,
	ClientModelBatchComponent,
	ClientPhysicsComponent,
	ClientTopLogoComponent
}

Class.AddComponents(ClientSpaceFurniture, ClientSpaceFurnitureComponents)

function ClientSpaceFurniture:ctor(entityId)
	ClientSpaceFurniture.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_HOME_OBJECT
	self.hasPlayedBornScaleAnim = false
	self.bornScaleTarget = 1
end

function ClientSpaceFurniture:init(dict)
	ClientSpaceFurniture.super.init(self, dict)

	if self.homeTemplateId == nil and dict.homeTemplateId ~= nil then
		rawset(self, "homeTemplateId", dict.homeTemplateId)
	end

	if self.ownerUid == nil and dict.ownerUid ~= nil then
		rawset(self, "ownerUid", dict.ownerUid)
	end

	local configData = self:getConfigData()

	if configData.needIndicatorIcon == 1 then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = configData.IndicatorIconHeight
	else
		self.forbiddenTopLogo = true
	end

	return true
end

function ClientSpaceFurniture:start()
	ClientSpaceFurniture.super.start(self)
	self:initInteraction()
end

function ClientSpaceFurniture:initializeComponents()
	ClientSpaceFurniture.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientSpaceFurniture:getConfigData()
	if self.homeTemplateId then
		return HomeObjectData[self.homeTemplateId] or {}
	end

	return {}
end

function ClientSpaceFurniture:refreshAppearance()
	ClientSpaceFurniture.super.refreshAppearance(self)

	if self.eModel then
		self:setScaleNumber(0)
		self:setEnableRendererBatch(self:checkEnableRendererBatch())

		local configData = self:getConfigData()
		local resId = configData.prefabResID

		if resId then
			self.bornScaleTarget = configData.prefabScale or 1

			self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, resId, ClientConst.InstantiatePriority.Low, ClientConst.AsyncLoadPriority.Low)
		end
	end
end

function ClientSpaceFurniture:checkEnableRendererBatch()
	return ClientUtils.checkEnableRendererBatch() and not self:getConfigData().disableRendererBatch
end

function ClientSpaceFurniture:onItemModelLoaded()
	self.isModelLoaded = true

	self.eModel:SetHomeObjectCollider(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self:getConfigData().modelText

	if modelText then
		self.eModel.modelView:SetModelText(pg.getLocalizationText(modelText), ClientConst.ModelTextType.Default)
	end

	self:playBornScaleAnim()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientSpaceFurniture:playBornScaleAnim()
	if self.hasPlayedBornScaleAnim then
		return
	end

	if not self.eModel then
		return
	end

	self.hasPlayedBornScaleAnim = true

	local targetScale = self.bornScaleTarget or self:getConfigData().prefabScale or 1

	DoTweenAnimMgr.Kill(self.actorId, LuaUIUtils.TweenId(self.BORN_SCALE_TWEEN_ID), true)
	DoTweenAnimMgr.DoFloat(self.actorId, 0, targetScale, LuaUIUtils.TweenId(self.BORN_SCALE_TWEEN_ID), self.BORN_SCALE_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(Const.DoTweenEaseType.OutBack), function()
		return
	end, function(value)
		self:setScaleNumber(value)
	end, function()
		return
	end, false)
end

function ClientSpaceFurniture:initInteraction()
	if self.eModel == nil then
		return
	end

	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	if actionPrototypeIds and configData.needStateInteraction ~= 1 then
		self.interactionListData = {}

		for _, actionPrototypeId in ipairs(actionPrototypeIds) do
			self.interactionListData[#self.interactionListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = actionPrototypeId,
				overrideInteractDis = configData.interactDistance,
				name = configData.name or configData.entityName
			}
		end
	elseif not actionPrototypeIds then
		self.interactionListData = nil
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientSpaceFurniture:getInteractionListData()
	return self.interactionListData
end

function ClientSpaceFurniture:checkCanInteract(interactUnit)
	return self.visible ~= false and self.space ~= nil
end

function ClientSpaceFurniture:interact(interactUnit)
	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_MARKET then
		local configData = self:getConfigData()

		if configData.shopId then
			pg.global.ui:open(UIConst.UI_ID_HOMELAND_MARKET, {
				shopId = configData.shopId,
				shopName = configData.name
			})
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)
		end
	end

	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_HOME_INVENTORY then
		pg.global.ui:open(UIConst.UI_ID_HOME_INVENTORY, {})
	end
end

function ClientSpaceFurniture:setScale(scale)
	self:setPositionAgentScale(scale.x, scale.y, scale.z)
	self:postComponentMethod("EVENT_onEntityScaleChanged")
end

function ClientSpaceFurniture:getScale()
	return self:getPositionAgentScale()
end

function ClientSpaceFurniture:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
	self:flushBatchRenderer()
end

return ClientSpaceFurniture
