-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeStateInteractComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local InteractionConst = require("Common.Const.InteractionConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeObjectData = require("Data.home_object_data")
local ClientHomeStateInteractComponent = Class.Component("ClientHomeStateInteractComponent")

function ClientHomeStateInteractComponent:init(dict)
	local configData = self:getConfigData()

	self._needStateInteraction = configData and configData.needStateInteraction == 1

	return true
end

function ClientHomeStateInteractComponent:EVENT_AddEComponent()
	if self._needStateInteraction then
		self:addEModelComponent(CommonConst.COMPONENT_INDEX_ANIMATOR)
	end
end

function ClientHomeStateInteractComponent:EVENT_InitInteractionList()
	if not self._needStateInteraction then
		return
	end

	local configData = self:getConfigData()
	local actionIds = configData.actionPrototypeIds

	if not actionIds or #actionIds < 2 then
		return
	end

	self.interactionListData = self.interactionListData or {}

	table.insert(self.interactionListData, {
		skipHomelandCheck = true,
		interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
		globalId = self:getGlobalId(),
		actionPrototypeId = actionIds[1],
		overrideInteractDis = configData.interactDistance,
		canInteractiveFunc = function()
			return not self:isOrnamentSwitchOpen()
		end,
		interactFunc = function()
			self:doSwitchInteract(true)
		end
	})
	table.insert(self.interactionListData, {
		skipHomelandCheck = true,
		interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
		globalId = self:getGlobalId(),
		actionPrototypeId = actionIds[2],
		overrideInteractDis = configData.interactDistance,
		canInteractiveFunc = function()
			return self:isOrnamentSwitchOpen()
		end,
		interactFunc = function()
			self:doSwitchInteract(false)
		end
	})
end

function ClientHomeStateInteractComponent:EVENT_onModelLoaded()
	if not self._needStateInteraction then
		return
	end

	if self:isOrnamentSwitchOpen() then
		local configData = self:getConfigData()

		if configData.interactiveOpenAnim then
			self:playAnimancerAnimAtEnd(configData.interactiveOpenAnim)
		end

		if configData.interactionMaterialKey and self.eModel and self.eModel.shaderView then
			self.eModel.shaderView:ApplyMaterialGlobalFloat("_Intensity", configData.interactionMaterialKey)
		end
	end
end

function ClientHomeStateInteractComponent:_getOrnamentOwnerEntity()
	local homeSpace = HomeLandUtils.getHomeSpace(self)

	if homeSpace and homeSpace.ornamentSwitchOpenSet then
		return homeSpace
	end

	if self.carGroup and self.carGroup.campCarEnt then
		return self.carGroup.campCarEnt
	end

	return nil
end

function ClientHomeStateInteractComponent:isOrnamentSwitchOpen()
	local owner = self:_getOrnamentOwnerEntity()

	if owner and owner.ornamentSwitchOpenSet then
		return owner.ornamentSwitchOpenSet[self.ornamentId] == true
	end

	return false
end

function ClientHomeStateInteractComponent:doSwitchInteract(isOpen)
	local owner = self:_getOrnamentOwnerEntity()

	if owner and owner.changeOrnamentSwitch then
		owner:changeOrnamentSwitch(self.ornamentId, isOpen)
	end
end

function ClientHomeStateInteractComponent:onOrnamentSwitchChanged(isOpen)
	if not self._needStateInteraction then
		return
	end

	local configData = self:getConfigData()
	local delay = 0.2

	if configData.interactionMaterialKey then
		delay = 0
	end

	if isOpen then
		if configData.interactiveOpenAnim then
			self:playAnimancerAnim(configData.interactiveOpenAnim, delay)
		end

		if configData.openSound then
			self:playSoundEvent(configData.openSound)
		end

		if configData.interactionMaterialKey and self.eModel and self.eModel.shaderView then
			self.eModel.shaderView:ApplyMaterialGlobalFloat("_Intensity", configData.interactionMaterialKey)
		end
	else
		if configData.interactiveCloseAnim then
			self:playAnimancerAnim(configData.interactiveCloseAnim, delay)
		end

		if configData.closeSound then
			self:playSoundEvent(configData.closeSound)
		end

		if configData.interactionMaterialKey and self.eModel and self.eModel.shaderView then
			self.eModel.shaderView:ApplyMaterialGlobalFloat("_Intensity", -10)
		end
	end

	pg.game.home:markShadowLightDirty()
end

return ClientHomeStateInteractComponent
