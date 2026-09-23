-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCarOrnamentEntity.lua

local Class = require("Core.Framework.Class")
local ClientHomeCarOrnamentBase = require("Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentBase")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local ClientHomeCarEditorComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarEditorComponent")
local ClientModelBatchComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent")
local ClientUtils = require("Utils.ClientUtils")
local ClientEntityEditorComponent = require("Entities.SpaceEntities.Home.ClientEntityEditorComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientHomeStateInteractComponent = require("Entities.SpaceEntities.Home.ClientHomeStateInteractComponent")
local UIConst = require("Const.UIConst")
local InteractionConst = require("Common.Const.InteractionConst")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomeCarOrnamentEntity = Class.Class("ClientHomeCarOrnamentEntity", ClientHomeCarOrnamentBase)
local ClientHomeCarEntityComponents = {
	ClientAoiComponent,
	ClientInteractionComponent,
	ClientModelBatchComponent,
	ClientHomeCarEditorComponent,
	ClientTopLogoComponent,
	ClientAnimatorComponent,
	ClientHomeStateInteractComponent
}

Class.AddComponents(ClientHomeCarOrnamentEntity, ClientHomeCarEntityComponents)

function ClientHomeCarOrnamentEntity:ctor(entityId)
	ClientHomeCarOrnamentEntity.super.ctor(self, entityId)
end

function ClientHomeCarOrnamentEntity:init(dict)
	if self.isClientEnt then
		self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
		self.clenUsrType = Const.CLEN_USE_TYPE_HOME
	end

	ClientHomeCarOrnamentEntity.super.init(self, dict)

	local configData = self:getConfigData()

	if configData and configData.actionPrototypeIds and configData.needIndicatorIcon == 1 and not HomeLandUtils.isHomeMusicPlayer(self.homeTemplateId) then
		self.forbiddenTopLogo = false
		self.topLogoType = ClientConst.TopLogoType.InteractableObject
		self.overrideTopLogoEnterDistance = HomelandConfigData.IndicatorIconDisplayArea or 10
		self.indicatorIconHeight = configData.IndicatorIconHeight
	end

	return true
end

function ClientHomeCarOrnamentEntity:start()
	ClientHomeCarOrnamentEntity.super.start(self)
	self:initInteraction()
end

function ClientHomeCarOrnamentEntity:initializeComponents()
	ClientHomeCarOrnamentEntity.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self:addEModelComponent(Const.COMPONENT_IDX_ITEM)
end

function ClientHomeCarOrnamentEntity:refreshAppearance()
	ClientHomeCarOrnamentEntity.super.refreshAppearance(self)

	if self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		self:setEnableRendererBatch(self:checkEnableRendererBatch())

		local resId = self:getConfigData().prefabResID
		local modelScale = self:getConfigData().prefabScale or 1

		if resId then
			self:setScaleNumber(modelScale)
			self.eModel:SetModelResId(Const.COMPONENT_IDX_ITEM, resId)
		end
	end
end

function ClientHomeCarOrnamentEntity:onItemModelLoaded()
	self.isModelLoaded = true

	self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)

	local modelText = self:getConfigData().modelText

	if modelText then
		local showText = pg.getLocalizationText(modelText)

		self.eModel.modelView:SetModelText(showText, ClientConst.ModelTextType.Default)
	end

	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)
end

function ClientHomeCarOrnamentEntity:initInteraction()
	if self.eModel == nil then
		return
	end

	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	if HomeLandUtils.isHomeMusicPlayer(self.homeTemplateId) then
		self.interactionListData = nil
	elseif actionPrototypeIds and configData.needStateInteraction ~= 1 then
		self.interactionListData = {}

		for _, actionPrototypeId in ipairs(actionPrototypeIds) do
			local isCampAddOnInteract = actionPrototypeId == Const.HOME_CAMP_VIEW_CAMP_BUFF

			self.interactionListData[#self.interactionListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = actionPrototypeId,
				overrideInteractDis = configData.interactDistance,
				name = not isCampAddOnInteract and (configData.name or configData.entityName) or nil
			}
		end
	elseif not actionPrototypeIds then
		self.interactionListData = nil
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomeCarOrnamentEntity:getInteractionListData()
	return self.interactionListData
end

function ClientHomeCarOrnamentEntity:isCampAddOnOrnament()
	local configData = self:getConfigData()

	return configData and configData.addOnId and configData.addOnId > 0
end

function ClientHomeCarOrnamentEntity:canShowCampAddOnInteract()
	if not self.space or not self.space.isHomeCamp or not self.space:isHomeCamp() then
		return false
	end

	local pawn = pg.pawn

	if not pawn then
		return false
	end

	local interaction = pg.game and pg.game.interaction
	local unitMap = interaction and interaction.unitMap
	local entFuncUnits = unitMap and unitMap[InteractionConst.INTERACTION_TYPE_ENT_FUNC]

	if not entFuncUnits then
		return true
	end

	local selfDist = Utils.squareDistNoYAxis(pawn:getPosition(), self:getPosition())

	for _, unit in ipairs(entFuncUnits) do
		if unit.actionPrototypeId == Const.HOME_CAMP_VIEW_CAMP_BUFF then
			local ent = pg.getEntityByGlobalId(unit.globalId)

			if ent and ent ~= self and ent.isCampAddOnOrnament and ent:isCampAddOnOrnament() then
				local entDist = Utils.squareDistNoYAxis(pawn:getPosition(), ent:getPosition())

				if entDist < selfDist or entDist == selfDist and ent.id and self.id and ent.id < self.id then
					return false
				end
			end
		end
	end

	return true
end

function ClientHomeCarOrnamentEntity:interact(interactUnit)
	if interactUnit and interactUnit.actionPrototypeId == Const.HOME_CAMP_VIEW_CAMP_BUFF then
		if self:isCampAddOnOrnament() then
			local ownerUid = self.playerUID

			if not ownerUid or ownerUid == "" then
				ownerUid = self.carGroup and self.carGroup.playerUID
			end

			pg.global.ui:open(UIConst.UI_ID_HOME_CAR_BUFF_PANEL, {
				ownerUid = ownerUid
			})
		end

		return
	end

	ClientHomeCarOrnamentEntity.super.interact(self, interactUnit)
end

function ClientHomeCarOrnamentEntity:getInteractName(interactUnits)
	if self:isCampAddOnOrnament() and interactUnits and #interactUnits == 1 then
		local interactUnit = interactUnits[1]

		if interactUnit and interactUnit.actionPrototypeId == Const.HOME_CAMP_VIEW_CAMP_BUFF then
			return interactUnit:getActionName()
		end
	end

	if self._needStateInteraction and interactUnits and #interactUnits > 0 then
		return interactUnits[1]:getActionName()
	end

	return pg.getLocalizationText(self:getConfigData().name)
end

function ClientHomeCarOrnamentEntity:checkEnableRendererBatch()
	return ClientUtils.checkEnableRendererBatch() and not self:getConfigData().disableRendererBatch
end

function ClientHomeCarOrnamentEntity:setScale(scale)
	self:setPositionAgentScale(scale.x, scale.y, scale.z)
	self:postComponentMethod("EVENT_onEntityScaleChanged")
end

function ClientHomeCarOrnamentEntity:onEntityPositionChanged()
	self:postComponentMethod("EVENT_onEntityPositionChanged")
	self:flushBatchRenderer()
end

function ClientHomeCarOrnamentEntity:checkCanInteract(interactUnit)
	if not ClientHomeCarOrnamentEntity.super.checkCanInteract(self, interactUnit) then
		return false
	end

	if not self.space then
		return false
	end

	if interactUnit and interactUnit.actionPrototypeId == Const.HOME_CAMP_VIEW_CAMP_BUFF then
		if not self:isCampAddOnOrnament() then
			return false
		end

		return self:canShowCampAddOnInteract()
	end

	if interactUnit.info and interactUnit.info.skipHomelandCheck then
		-- block empty
	elseif not self:checkIsHomeCarOwner() then
		return false
	end

	return true
end

function ClientHomeCarOrnamentEntity:checkIsHomeCarOwner()
	return self.playerId == pg.me.id
end

return ClientHomeCarOrnamentEntity
