-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoTeamSpeechComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoTeamSpeechComponent = Class.LightClass("TopLogoTeamSpeechComponent", TopLogoItemComponent)

function TopLogoTeamSpeechComponent.resolveVisibleFromEntity(entity)
	local owner = entity and (entity.master or entity.getMasterEntity and entity:getMasterEntity() or entity)
	local speech = pg.game and pg.game.speech

	if not owner or not owner.uid or not speech then
		return false
	end

	local target = owner

	if owner == pg.me then
		target = pg.pawn or owner
	elseif owner.isControllingPet and owner:isControllingPet() then
		target = owner:getCurPetEntity()
	end

	return target == entity and speech:checkMemberSpeakingVisible(owner.uid) == true
end

function TopLogoTeamSpeechComponent:restoreStateFromEntity()
	local visible = TopLogoTeamSpeechComponent.resolveVisibleFromEntity(self.entity)

	if self.onTeamSpeechMsg and self.commandVisible ~= visible then
		self.onTeamSpeechMsg(visible)
	end
end

function TopLogoTeamSpeechComponent:ctor(refUContainer, topLogoItem)
	TopLogoTeamSpeechComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoTeamSpeechComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_TEAM_SPEECH, self.onTeamSpeechMsg)
	end

	TopLogoTeamSpeechComponent.super.onDestroy(self)
end

function TopLogoTeamSpeechComponent:onCtor()
	self.commandVisible = false

	self:refreshVisible()
end

function TopLogoTeamSpeechComponent:initUI()
	return
end

function TopLogoTeamSpeechComponent:findObjects()
	return
end

function TopLogoTeamSpeechComponent:shouldBeActive()
	return self.commandVisible == true
end

function TopLogoTeamSpeechComponent:innerGetVisible()
	if not TopLogoTeamSpeechComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.commandVisible then
		return false
	end

	return true
end

function TopLogoTeamSpeechComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoTeamSpeechComponent:refreshTopLogoInfo()
	if self:checkFinalVisible() then
		self:checkAndLoadUContainerUrlSupportAsync()
	end
end

function TopLogoTeamSpeechComponent:addEntityListener()
	function self.onTeamSpeechMsg(isVisible)
		self.commandVisible = isVisible == true

		self:refreshVisible()
		self:notifyActiveStateChanged(self:shouldBeActive())
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_TEAM_SPEECH, self.onTeamSpeechMsg)
	end
end

return TopLogoTeamSpeechComponent
