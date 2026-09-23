-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoInteractSignComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoConst = require("Const.TopLogoConst")
local EventConst = require("Const.EventConst")
local TopLogoInteractSignComponent = Class.LightClass("TopLogoInteractSignComponent", TopLogoItemComponent)

function TopLogoInteractSignComponent:ctor(refUContainer, topLogoItem)
	TopLogoInteractSignComponent.super.ctor(self, refUContainer, topLogoItem)

	self._isInInteractRange = false
	self._lastRidingState = false
	self._rootUComponent = nil
	self.m_pendingInteractRange = false

	function self.m_onSetInteractStateLoaded(isSuccess)
		if isSuccess ~= false then
			self:_switchPageState(self.m_pendingInteractRange)
		end
	end

	pg.game.topLogo.interactSignLimiter:register(self.entity.actorId, self)
end

function TopLogoInteractSignComponent:onDestroy()
	if self.entity and self.entity.eventEmitter then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_FOCUS, self._onFocusChanged)
	end

	self._onFocusChanged = nil
	self._rootUComponent = nil

	pg.game.topLogo.interactSignLimiter:unregister(self.entity.actorId)
	TopLogoInteractSignComponent.super.onDestroy(self)
end

function TopLogoInteractSignComponent:resetRender()
	self._rootUComponent = nil

	TopLogoInteractSignComponent.super.resetRender(self)
end

function TopLogoInteractSignComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoInteractSignComponent.super.onLanguageChanged(self)
end

function TopLogoInteractSignComponent:shouldBeActive()
	return self._lastRidingState or TopLogoInteractSignComponent.super.shouldBeActive(self)
end

function TopLogoInteractSignComponent:addEntityListener()
	function self._onFocusChanged(isFocused)
		self:setInteractState(isFocused)
	end

	self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_FOCUS, self._onFocusChanged)
end

function TopLogoInteractSignComponent:findObjects()
	if self.refUContainer and self.refUContainer.content then
		self._rootUComponent = self.refUContainer.content:GetComponent("UComponent")
	end
end

function TopLogoInteractSignComponent:initUI()
	TopLogoInteractSignComponent.super.initUI(self)
	self:_switchPageState(self._isInInteractRange)
end

function TopLogoInteractSignComponent:_switchPageState(inRange)
	self._isInInteractRange = inRange

	if self._rootUComponent then
		self._rootUComponent:TryChangePage("State", inRange and 1 or 0)
	end
end

function TopLogoInteractSignComponent:refreshTopLogoInfo(callFromUpdate)
	if self:checkContainerLoaded() then
		return
	end

	self:checkAndLoadUContainerUrlSupportAsync(nil, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoInteractSignComponent:setInteractState(inRange)
	if self._isInInteractRange == inRange then
		return
	end

	self.m_pendingInteractRange = inRange

	if self:checkContainerLoaded() then
		self.m_onSetInteractStateLoaded(true)

		return
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_onSetInteractStateLoaded, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoInteractSignComponent:onTopLogoCompUpdate()
	local isRiding = pg.me and pg.me.RIDING_ST and pg.me:RIDING_ST() or false

	if self._lastRidingState ~= isRiding then
		self._lastRidingState = isRiding

		if isRiding then
			self:setVisible(false, UIConst.TOPLOGO_VISIBLE_KEY.RIDING_VEHICLE)
		else
			self:setVisible(true, UIConst.TOPLOGO_VISIBLE_KEY.RIDING_VEHICLE)
		end
	end
end

return TopLogoInteractSignComponent
