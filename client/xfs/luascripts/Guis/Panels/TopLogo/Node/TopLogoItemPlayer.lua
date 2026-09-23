-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemPlayer.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoItemPlayerComponentDefs = require("Guis.Panels.TopLogo.Node.TopLogoItemPlayerComponentDefs")
local playerChatComponentName = UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT
local playerChatComponentDefinition = TopLogoItemPlayerComponentDefs.byName[playerChatComponentName]
local playerGhostComponentDefinition = {
	componentName = playerChatComponentName,
	create = playerChatComponentDefinition.create
}
local TopLogoItemPlayerGhostComponentDefs = {
	ordered = {
		playerGhostComponentDefinition
	},
	byName = {
		[playerChatComponentName] = playerGhostComponentDefinition
	}
}
local TopLogoItemPlayer = Class.LightClass("TopLogoItemPlayer", TopLogoItem)

function TopLogoItemPlayer:ctor(entity)
	TopLogoItemPlayer.super.ctor(self, entity)
end

function TopLogoItemPlayer:destroy()
	TopLogoItemPlayer.super.destroy(self)
end

function TopLogoItemPlayer:findObjects()
	return
end

function TopLogoItemPlayer:getLogicComponentDefinition(componentName)
	if Utils.isPlayerGhost(self.entity) and componentName ~= playerChatComponentName then
		return nil
	end

	return TopLogoItemPlayerComponentDefs.byName[componentName]
end

function TopLogoItemPlayer:createLogicComponents()
	if Utils.isPlayerGhost(self.entity) then
		self:initializeLogicComponents(TopLogoItemPlayerGhostComponentDefs)

		return
	end

	if self.entity and self.entity._calculateNameState then
		self.nameState = self.entity:_calculateNameState()
	end

	self:initializeLogicComponents(TopLogoItemPlayerComponentDefs)
end

function TopLogoItemPlayer:switchNameState(state)
	self.nameState = state

	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:setBloodVisible(state == UIConst.NAME_STATE.COMBAT)
	end

	local npcComponent

	if state == UIConst.NAME_STATE.DIALOGUE then
		npcComponent = self:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC)
	else
		npcComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.NPC)
	end

	if npcComponent then
		npcComponent:setVisibleNpcInfo(state == UIConst.NAME_STATE.DIALOGUE)
	end
end

function TopLogoItemPlayer:refreshTopLogoItemOnLoaded()
	local playingEmojiName = self.entity.topLogoData.playingEmojiName
	local playingDuration = self.entity.topLogoData.playingDuration

	if playingEmojiName then
		self.entity.eventEmitter:emitNextFrame(EventConst.TOPLOGO_BUBBLE, true, playingEmojiName, playingDuration)
	end

	local combatComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

	if combatComponent then
		combatComponent:initCombatInfo()
	end

	local teamMateComponent = self:peekToplogoComponent(UIConst.TOPLOGO_COMPONENT.TEAM_MATE)

	if teamMateComponent then
		teamMateComponent:refreshStateFromEntity()
	end
end

return TopLogoItemPlayer
