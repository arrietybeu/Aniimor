-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoFocusComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoFocusComponent = Class.LightClass("TopLogoFocusComponent", TopLogoItemComponent)
local SysConfigData = require("Data.sys_config_data")

function TopLogoFocusComponent:ctor(refUContainer, topLogoItem)
	TopLogoFocusComponent.super.ctor(self, refUContainer, topLogoItem)

	self.m_cbCacheFocusCallback = nil
	self.m_cbCacheFocusInfo = false
end

function TopLogoFocusComponent:onCtor()
	self.m_pendingFocusRefresh = false

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoFocusComponent:shouldBeActive()
	if self.m_pendingFocusRefresh then
		return true
	end

	return self.m_cbCacheFocusInfo == true
end

function TopLogoFocusComponent:resetRender()
	TopLogoFocusComponent.super.resetRender(self)
end

function TopLogoFocusComponent:onDestroy()
	self.m_cbCacheFocusCallback = nil
	self.m_cbCacheFocusInfo = false
	self.m_pendingFocusRefresh = false

	if self.entity ~= nil and self.entity.eventEmitter ~= nil then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_FOCUS, self.topLogoFocusMsg)
	end

	TopLogoFocusComponent.super.onDestroy(self)
end

function TopLogoFocusComponent:initUI()
	return
end

function TopLogoFocusComponent:findObjects()
	return
end

function TopLogoFocusComponent:addEntityListener()
	function self.topLogoFocusMsg(visible)
		local isVisible = visible == true

		if isVisible and self:innerGetVisible() ~= true then
			return
		end

		self.m_cbCacheFocusInfo = isVisible
		self.m_pendingFocusRefresh = true

		self:notifyActiveStateChanged(self:shouldBeActive())

		if not self.topLogoItem:isTopLogoPrefabReady() then
			return
		end

		self.m_pendingFocusRefresh = false

		if not self.m_cbCacheFocusCallback then
			function self.m_cbCacheFocusCallback(isSuccess)
				if not isSuccess or not self.refUContainer then
					return
				end

				self.refUContainer:SetActive(self.m_cbCacheFocusInfo and true or false)
			end
		end

		if self:checkContainerLoaded() then
			self.m_cbCacheFocusCallback(true)
		else
			self:checkAndLoadUContainerUrlSupportAsync(self.m_cbCacheFocusCallback, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end

		self:notifyActiveStateChanged(self:shouldBeActive())
	end

	self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_FOCUS, self.topLogoFocusMsg)
end

function TopLogoFocusComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingFocusRefresh then
		self.m_pendingFocusRefresh = false

		if self.topLogoFocusMsg then
			self.topLogoFocusMsg(self.m_cbCacheFocusInfo)
		end

		return
	end
end

function TopLogoFocusComponent:checkTopLogoCompUpdate()
	return TopLogoFocusComponent.super.checkTopLogoCompUpdate(self)
end

function TopLogoFocusComponent:innerGetVisible()
	if TopLogoFocusComponent.super.innerGetVisible(self) ~= true then
		return false
	end

	if pg.me == nil then
		return false
	end

	local space = pg.me.space

	if space == nil then
		return false
	end

	if not space.isGrabEgg then
		return false
	end

	return space:isGrabEgg() == true
end

function TopLogoFocusComponent:onTopLogoCompUpdate()
	return
end

function TopLogoFocusComponent:getInitMaxDistance()
	return SysConfigData.CALL_FRIENDS_TOP_LOGO_MAX_DISTANCE
end

return TopLogoFocusComponent
