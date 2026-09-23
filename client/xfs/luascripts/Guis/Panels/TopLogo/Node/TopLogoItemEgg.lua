-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemEgg.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItem = require("Guis.Panels.TopLogo.Node.TopLogoItem")
local TopLogoBubbleComponent = require("Guis.Panels.TopLogo.Component.TopLogoBubbleComponent")
local TopLogoCombatComponent = require("Guis.Panels.TopLogo.Component.TopLogoCombatComponent")
local TopLogoChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoChatComponent")
local TopLogoPlayerChatComponent = require("Guis.Panels.TopLogo.Component.TopLogoPlayerChatComponent")
local TopLogoTeamMateStateComponent = require("Guis.Panels.TopLogo.Component.TopLogoTeamMateStateComponent")
local TopLogoItemEgg = Class.LightClass("TopLogoItemEgg", TopLogoItem)

function TopLogoItemEgg:ctor(entity)
	TopLogoItemEgg.super.ctor(self, entity)
end

function TopLogoItemEgg:onTopLogoLoaded()
	TopLogoItemEgg.super.onTopLogoLoaded(self)

	self.topLogoScript.compensateRigidbodyPivotDrift = true
end

function TopLogoItemEgg:destroy()
	TopLogoItemEgg.super.destroy(self)
end

function TopLogoItemEgg:findObjects()
	return
end

function TopLogoItemEgg:m_resolveInfoEntity()
	local egg = self.entity
	local master = egg and egg.getMasterEntity and egg:getMasterEntity()

	return master or egg
end

function TopLogoItemEgg:createLogicComponents()
	local infoEnt = self:m_resolveInfoEntity()
	local visualEnt = self.entity

	self.entity = infoEnt

	local combat = TopLogoCombatComponent.new(nil, self)

	combat.forceNameOnly = true
	self.components = {
		[UIConst.TOPLOGO_COMPONENT.COMBAT] = combat,
		[UIConst.TOPLOGO_COMPONENT.BUBBLE] = TopLogoBubbleComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.CHAT] = TopLogoChatComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT] = TopLogoPlayerChatComponent.new(nil, self),
		[UIConst.TOPLOGO_COMPONENT.TEAM_MATE] = TopLogoTeamMateStateComponent.new(nil, self)
	}
	self.entity = visualEnt

	self:m_classifyComponents()
end

function TopLogoItemEgg:switchNameState(state)
	self.nameState = UIConst.NAME_STATE.COMBAT

	if self.components[UIConst.TOPLOGO_COMPONENT.COMBAT] then
		self.components[UIConst.TOPLOGO_COMPONENT.COMBAT]:setBloodVisible(true)
	end
end

function TopLogoItemEgg:refreshTopLogoItemOnLoaded()
	local master = self:m_resolveInfoEntity()

	if not master or not master.topLogoData then
		return
	end

	local playingEmojiName = master.topLogoData.playingEmojiName
	local playingDuration = master.topLogoData.playingDuration

	if playingEmojiName then
		local EventConst = require("Const.EventConst")

		master.eventEmitter:emitNextFrame(EventConst.TOPLOGO_BUBBLE, true, playingEmojiName, playingDuration)
	end

	if self.components[UIConst.TOPLOGO_COMPONENT.COMBAT] then
		self.components[UIConst.TOPLOGO_COMPONENT.COMBAT]:initCombatInfo()
	end

	if self.components[UIConst.TOPLOGO_COMPONENT.TEAM_MATE] then
		self.components[UIConst.TOPLOGO_COMPONENT.TEAM_MATE]:refreshStateFromEntity()
	end
end

return TopLogoItemEgg
