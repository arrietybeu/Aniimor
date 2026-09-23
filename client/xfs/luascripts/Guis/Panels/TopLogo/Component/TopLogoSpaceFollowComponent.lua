-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoSpaceFollowComponent.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoSpaceFollowComponent = Class.LightClass("TopLogoSpaceFollowComponent", TopLogoItemComponent)
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local AppearanceActionData = require("Data.appearance_action_data")

function TopLogoSpaceFollowComponent:ctor(refUContainer, topLogoItem)
	TopLogoSpaceFollowComponent.super.ctor(self, refUContainer, topLogoItem)

	self.showType = 0
end

function TopLogoSpaceFollowComponent:onCtor()
	self.m_pendingSpaceFollow = false

	self:refreshVisible()
end

function TopLogoSpaceFollowComponent:shouldBeActive()
	if self.m_pendingSpaceFollow then
		return true
	end

	return self.commandVisible == true
end

function TopLogoSpaceFollowComponent:resetRender()
	self.countDown = nil
	self.rootComponent = nil
	self.followIconUImage = nil

	TopLogoSpaceFollowComponent.super.resetRender(self)
end

function TopLogoSpaceFollowComponent:onDestroy()
	self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_FRIEND_INTERACT, self.onShowCountDown)

	self.m_pendingSpaceFollow = false

	TopLogoSpaceFollowComponent.super.onDestroy(self)

	self.m_cacheSaceFollowFunc = nil
end

function TopLogoSpaceFollowComponent:findObjects()
	local objectReference = self.refUContainer.content:GetComponent("ObjectReference")

	self.countDown = objectReference:GetRefValue("countDown")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.followIconUImage = objectReference:GetRefValue("followIconUImage")
end

function TopLogoSpaceFollowComponent:addListener()
	if not self.countDown then
		return
	end

	function self.countDown.luaFinished()
		self:removeCountDown()
	end
end

function TopLogoSpaceFollowComponent:initUI()
	if self:checkSpaceFollowItemVisible() then
		self:handleCountDown()
	else
		self:removeCountDown()
	end
end

function TopLogoSpaceFollowComponent:addEntityListener()
	if not self.m_cacheSaceFollowFunc then
		function self.m_cacheSaceFollowFunc()
			if self:checkSpaceFollowItemVisible() then
				self:handleCountDown()
			else
				self:removeCountDown()
			end
		end
	end

	function self.onShowCountDown(isVisible, type, actionId)
		self.commandVisible = isVisible == true
		self.showType = type
		self.actionId = actionId
		self.m_pendingSpaceFollow = self.commandVisible

		self:notifyActiveStateChanged(self:shouldBeActive())

		if not self.topLogoItem:isTopLogoPrefabReady() then
			return
		end

		self.m_pendingSpaceFollow = false

		if self:checkContainerLoaded() then
			if self.m_cacheSaceFollowFunc then
				self.m_cacheSaceFollowFunc()
			end
		else
			self:checkAndLoadUContainerUrlSupportAsync(self.m_cacheSaceFollowFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end

		self:notifyActiveStateChanged(self:shouldBeActive())
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_FRIEND_INTERACT, self.onShowCountDown)
	end
end

function TopLogoSpaceFollowComponent:handleCountDown()
	if IsNil(self.rootComponent) then
		return
	end

	self.rootComponent:SetActiveFastest(self.commandVisible)

	if self.commandVisible then
		if NotNil(self.countDown) then
			self.countDown:Play(10, 10)
		end

		self.rootComponent:TryChangePage("IconState", self.showType)

		if self.actionId then
			self.followIconUImage.url = AppearanceActionData[self.actionId] and AppearanceActionData[self.actionId].icon or ""
		end
	end
end

function TopLogoSpaceFollowComponent:checkSpaceFollowItemVisible()
	if not self:checkFinalVisible() then
		return false
	end

	if not self.commandVisible then
		return false
	end

	return true
end

function TopLogoSpaceFollowComponent:removeCountDown()
	self:hideCountDown()
end

function TopLogoSpaceFollowComponent:hideCountDown()
	if IsNil(self.rootComponent) then
		return
	end

	self.rootComponent:SetActiveFastest(false)
end

function TopLogoSpaceFollowComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoSpaceFollowComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingSpaceFollow then
		self.m_pendingSpaceFollow = false

		if self.onShowCountDown then
			self.onShowCountDown(self.commandVisible, self.showType, self.actionId)
		end

		return
	end

	if not self:checkSpaceFollowItemVisible() then
		return
	end

	self:checkAndLoadUContainerUrlSupportAsync()
end

function TopLogoSpaceFollowComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoSpaceFollowComponent
