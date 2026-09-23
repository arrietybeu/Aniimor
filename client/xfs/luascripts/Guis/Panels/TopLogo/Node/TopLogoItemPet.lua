-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPet.lua

local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoItemPetComponentDefs = require("Guis.Panels.TopLogo.Node.TopLogoItemPetComponentDefs")
local TopLogoItemPet = Class.LightClass("TopLogoItemPet", TopLogoItem)

TopLogoItemPet.PetGhostPlayerChatComponentDef = {
	componentName = UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT,
	create = TopLogoItemPetComponentDefs.byName[UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT].create
}
TopLogoItemPet.PetGhostComponentDefs = {
	ordered = {
		TopLogoItemPet.PetGhostPlayerChatComponentDef
	},
	byName = {
		[UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT] = TopLogoItemPet.PetGhostPlayerChatComponentDef
	}
}

function TopLogoItemPet:ctor(entity)
	self.resId = AddressDataConst.TOPLOGO_TOP_RESID

	TopLogoItemPet.super.ctor(self, entity)
end

function TopLogoItemPet:destroy()
	TopLogoItemPet.super.destroy(self)
end

function TopLogoItemPet:findObjects()
	return
end

function TopLogoItemPet:getLogicComponentDefinition(componentName)
	if Utils.isPetGhost(self.entity) then
		return TopLogoItemPet.PetGhostComponentDefs.byName[componentName]
	end

	return TopLogoItemPetComponentDefs.byName[componentName]
end

function TopLogoItemPet:getTopLogoVisible()
	local baseVisible = TopLogoItemPet.super.getTopLogoVisible(self)

	if baseVisible then
		return true
	end

	local petLevelUpComp = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP)
	local entity = self.entity

	if entity and not entity:isTopLogoDeadState() and petLevelUpComp and petLevelUpComp:shouldForceTopLogoVisible() then
		return true
	end

	return false
end

function TopLogoItemPet:tryRemoveTopLogoComponent(compName)
	if self.components[compName] then
		self.components[compName] = nil
	end
end

function TopLogoItemPet:createLogicComponents()
	local componentDefs = Utils.isPetGhost(self.entity) and TopLogoItemPet.PetGhostComponentDefs or TopLogoItemPetComponentDefs

	self:initializeLogicComponents(componentDefs)
end

function TopLogoItemPet:switchNameState(state)
	self.nameState = state

	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:setBloodVisible(state == UIConst.NAME_STATE.COMBAT)
	end

	local npcComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC)

	if state == UIConst.NAME_STATE.DIALOGUE then
		npcComponent = npcComponent or self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC, "name_state_dialogue")
	end

	if npcComponent then
		npcComponent:setVisibleNpcInfo(state == UIConst.NAME_STATE.DIALOGUE)
	end
end

function TopLogoItemPet:onTopLogoReset()
	TopLogoItemPet.super.onTopLogoReset(self)
end

function TopLogoItemPet:refreshTopLogoItemOnLoaded()
	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:initCombatInfo()
	end
end

function TopLogoItemPet:showPetChatInfo(chatInfoId)
	local petChatComponent = self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_CHAT)

	if petChatComponent then
		local result, duration = petChatComponent:showPetChatInfo(chatInfoId)

		return result, duration
	end

	return false, 0
end

function TopLogoItemPet:hidePetChatInfo()
	local petChatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_CHAT)

	if petChatComponent then
		petChatComponent:hidePetChatInfo()
	end
end

function TopLogoItemPet:refreshPhotoDesc(visible, content)
	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:setVisible(not visible, UIConst.TOPLOGO_VISIBLE_KEY.PHOTO)
	end

	local photoComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO)

	if visible then
		photoComponent = photoComponent or self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_desc")
	end

	if photoComponent then
		photoComponent:refreshPhotoRecognize(visible, content)
	end
end

function TopLogoItemPet:refreshPhotoIdentify(visible, content, state)
	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:setVisible(not visible, UIConst.TOPLOGO_VISIBLE_KEY.PHOTO)
	end

	local photoComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO)

	if visible then
		photoComponent = photoComponent or self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_identify")
	end

	if photoComponent then
		photoComponent:refreshPhotoIdentify(visible, content, state)
	end
end

return TopLogoItemPet
