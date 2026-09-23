-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoIconComponent.lua

local Class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoIconComponent = Class.LightClass("TopLogoIconComponent", TopLogoItemComponent)

function TopLogoIconComponent:ctor(refUContainer, topLogoItem)
	TopLogoIconComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoIconComponent:refreshIcon()
	self._cachedIcon = nil

	if self.entity ~= nil then
		self._cachedIcon = self.entity:getTopLogoIcon()
	end

	self:notifyActiveStateChanged(self:shouldBeActive())

	if self.rootIcon ~= nil then
		if self:checkFinalVisible() == true and self._cachedIcon ~= nil then
			self.rootIcon:SetActive(true)

			self.rootIcon.url = self._cachedIcon
		else
			self.rootIcon:SetActive(false)
		end
	end
end

function TopLogoIconComponent:onCtor()
	self._cachedIcon = self.entity:getTopLogoIcon()

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoIconComponent:shouldBeActive()
	return self._cachedIcon ~= nil
end

function TopLogoIconComponent:m_refreshIcon()
	self:refreshIcon()
	self:refreshVisible()
end

function TopLogoIconComponent:resetRender()
	self.m_loadedIconCallback = nil
	self.rootIcon = nil
	self.objectReference = nil

	TopLogoIconComponent.super.resetRender(self)
end

function TopLogoIconComponent:onDestroy()
	TopLogoIconComponent.super.onDestroy(self)
end

function TopLogoIconComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootIcon = self.objectReference:GetRefValue("uINodeIconUImage")
	self.rootIcon.preserveAspect = false
end

function TopLogoIconComponent:initUI()
	TopLogoIconComponent.super.initUI(self)
	self:refreshIcon()
end

function TopLogoIconComponent:innerGetVisible()
	if not TopLogoIconComponent.super.innerGetVisible(self) then
		return false
	end

	if self._cachedIcon == nil then
		return false
	end

	if self.entity.hideTitleAndEffs and self.entity:hideTitleAndEffs() then
		return false
	end

	return true
end

function TopLogoIconComponent:refreshTopLogoInfo(callFromUpdate)
	if self:checkFinalVisible() then
		if self.m_loadedIconCallback == nil then
			function self.m_loadedIconCallback(loadState)
				if loadState ~= true then
					return
				end

				self:refreshIcon()
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedIconCallback, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	elseif self.rootIcon ~= nil then
		self.rootIcon:SetActive(false)
	end
end

function TopLogoIconComponent:getInitMaxDistance()
	if pg.me.isInDialogue and self._cachedIcon then
		return SysConfigData.CATCH_ROGUE_TOPLOGO_DISTANCE
	end

	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoIconComponent
