-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPetExchangeComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoPetExchangeComponent = Class.LightClass("TopLogoPetExchangeComponent", TopLogoItemComponent)

function TopLogoPetExchangeComponent:ctor(refUContainer, topLogoItem)
	TopLogoPetExchangeComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoPetExchangeComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PET_EXCHANGE, self.onPetExchange)
	end

	TopLogoPetExchangeComponent.super.onDestroy(self)
end

function TopLogoPetExchangeComponent:onCtor()
	self.commandVisible = false

	self:refreshVisible()
end

function TopLogoPetExchangeComponent:initUI()
	return
end

function TopLogoPetExchangeComponent:findObjects()
	return
end

function TopLogoPetExchangeComponent:shouldBeActive()
	return self.commandVisible == true
end

function TopLogoPetExchangeComponent:innerGetVisible()
	if not TopLogoPetExchangeComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.commandVisible then
		return false
	end

	return true
end

function TopLogoPetExchangeComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoPetExchangeComponent:refreshTopLogoInfo()
	if self:checkFinalVisible() then
		self:checkAndLoadUContainerUrlSupportAsync()
	end
end

function TopLogoPetExchangeComponent:addEntityListener()
	function self.onPetExchange(isVisible)
		self.commandVisible = isVisible == true

		self:refreshVisible()
		self:notifyActiveStateChanged(self:shouldBeActive())
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PET_EXCHANGE, self.onPetExchange)
	end
end

function TopLogoPetExchangeComponent:restoreStateFromEntity()
	self.commandVisible = self.entity ~= nil and not string.isNilOrEmpty(self.entity.curSocialId)

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

local SysConfigData = require("Data.sys_config_data")

function TopLogoPetExchangeComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoPetExchangeComponent
