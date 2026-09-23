-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoSocialComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local SysConfigData = require("Data.sys_config_data")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoSocialComponent = Class.LightClass("TopLogoSocialComponent", TopLogoItemComponent)

function TopLogoSocialComponent:ctor(refUContainer, topLogoItem)
	TopLogoSocialComponent.super.ctor(self, refUContainer, topLogoItem)

	self.configData = self.entity:getConfigData() or {}
	self.m_cbCacheSocialInfos = {}
	self.m_cbCacheSocialFunc = nil
end

function TopLogoSocialComponent:onCtor()
	self.m_pendingSocialRefresh = false

	self:refreshVisible()
end

function TopLogoSocialComponent:shouldBeActive()
	if self.m_pendingSocialRefresh then
		return true
	end

	return self.selectFrameInfo ~= nil and self.selectFrameInfo.show == true
end

function TopLogoSocialComponent:resetRender()
	self.selectFrameLoadInfoFlag = false

	if self.m_cbCacheSocialInfos then
		self.m_cbCacheSocialInfos = {}
	end

	self.objectReference = nil
	self.selectFrameUImage = nil
	self.selectFrameRectTransform = nil

	TopLogoSocialComponent.super.resetRender(self)
end

function TopLogoSocialComponent:onDestroy()
	self.m_cbCacheSocialInfos = {}
	self.m_cbCacheSocialFunc = nil
	self.m_pendingSocialRefresh = false

	TopLogoSocialComponent.super.onDestroy(self)
end

function TopLogoSocialComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.selectFrameUImage = self.objectReference:GetRefValue("selectFrameUImage")
	self.selectFrameRectTransform = self.objectReference:GetRefValue("selectFrameRectTransform")

	if self.selectFrameLoadInfoFlag then
		self:refreshSelectFrame(self.selectFrameInfo)

		self.selectFrameLoadInfoFlag = false
	end
end

function TopLogoSocialComponent:addEntityListener()
	if self.entity then
		-- block empty
	end
end

function TopLogoSocialComponent:initUI()
	self:refreshVisible()
end

function TopLogoSocialComponent:onTopLogoCompVisibleChanged(visible)
	if not self:checkContainerLoaded() then
		return
	end

	if visible then
		-- block empty
	end
end

function TopLogoSocialComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoSocialComponent:innerGetVisible()
	return true
end

function TopLogoSocialComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingSocialRefresh then
		self.m_pendingSocialRefresh = false

		self:refreshSelectFrame(self.selectFrameInfo)

		return
	end
end

function TopLogoSocialComponent:refreshSelectFrame(info)
	if not info then
		return
	end

	self.selectFrameInfo = info
	self.m_pendingSocialRefresh = info.show == true

	self:notifyActiveStateChanged(self:shouldBeActive())

	if not self.topLogoItem:isTopLogoPrefabReady() then
		return
	end

	self.m_pendingSocialRefresh = false
	self.m_cbCacheSocialInfos = info

	if info.show ~= true and not self:checkContainerLoaded() then
		self:notifyActiveStateChanged(self:shouldBeActive())

		return
	end

	if not self.m_cbCacheSocialFunc then
		function self.m_cbCacheSocialFunc()
			if self.selectFrameUImage then
				self.selectFrameUImage.gameObject:SetActiveEx(self.m_cbCacheSocialInfos.show)
			end
		end
	end

	if self:checkContainerLoaded() then
		self.m_cbCacheSocialFunc()
	else
		self:checkAndLoadUContainerUrlSupportAsync(self.m_cbCacheSocialFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end

	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoSocialComponent:getInitMaxDistance()
	return SysConfigData.CALL_FRIENDS_TOP_LOGO_MAX_DISTANCE
end

return TopLogoSocialComponent
