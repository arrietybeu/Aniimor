-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPetLevelUpComponent.lua

local Class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local PetLevelUpUIUtils = require("Guis.Utils.PetLevelUpUIUtils")
local TopLogoPetLevelUpComponent = Class.LightClass("TopLogoPetLevelUpComponent", TopLogoItemComponent)

function TopLogoPetLevelUpComponent:onCtor()
	self.playVersion = 0

	self:refreshVisible()
end

function TopLogoPetLevelUpComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

function TopLogoPetLevelUpComponent:shouldBeActive()
	return self:shouldForceTopLogoVisible()
end

function TopLogoPetLevelUpComponent:shouldForceTopLogoVisible()
	return self:isActive() and (self.pendingLevel ~= nil or self.playingLevel ~= nil)
end

function TopLogoPetLevelUpComponent:innerGetVisible()
	return TopLogoPetLevelUpComponent.super.innerGetVisible(self) and self:shouldForceTopLogoVisible()
end

function TopLogoPetLevelUpComponent:findObjects()
	self.rootUComponent = self.refUContainer.content
end

function TopLogoPetLevelUpComponent:initUI()
	self:playPendingLevelUp()
end

function TopLogoPetLevelUpComponent:clearTimer()
	if self.timer then
		self:killTimer(self.timer)

		self.timer = nil
	end
end

function TopLogoPetLevelUpComponent:refreshPlayState()
	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
	self:notifyMaxDistanceChanged()
	self.topLogoItem:refreshTopLogoVisible()
end

function TopLogoPetLevelUpComponent:stopLevelUp()
	self.playVersion = self.playVersion + 1

	self:clearTimer()

	self.pendingLevel = nil
	self.playingLevel = nil

	self:refreshPlayState()
end

function TopLogoPetLevelUpComponent:playPendingLevelUp()
	local level = self.pendingLevel

	if level == nil then
		return
	end

	self.pendingLevel = nil
	self.playingLevel = level

	self:clearTimer()

	local playVersion = self.playVersion
	local duration = PetLevelUpUIUtils.play(self.rootUComponent, level)

	self.timer = self:startTimer(function()
		if self.playVersion ~= playVersion then
			return
		end

		self.timer = nil
		self.playingLevel = nil

		self:refreshPlayState()
	end, duration)
end

function TopLogoPetLevelUpComponent:playPetLevelUp(level)
	self.playVersion = self.playVersion + 1
	self.pendingLevel = level

	self:refreshPlayState()

	if not self.topLogoItem:isTopLogoPrefabReady() then
		if not self.topLogoItem:checkCreate() then
			self:stopLevelUp()

			return false
		end

		return true
	end

	self:refreshTopLogoInfo()

	return true
end

function TopLogoPetLevelUpComponent:refreshTopLogoInfo(callFromUpdate)
	if self.pendingLevel == nil or not self:checkFinalVisible() then
		return
	end

	if self:checkContainerLoaded() then
		self:playPendingLevelUp()

		return
	end

	self:checkAndLoadUContainerUrlSupportAsync(function(isSuccess)
		if isSuccess then
			self:playPendingLevelUp()
		else
			self:stopLevelUp()
		end
	end, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoPetLevelUpComponent:resetRender()
	self.playVersion = self.playVersion + 1

	self:clearTimer()

	if self.playingLevel ~= nil then
		self.pendingLevel = nil
		self.playingLevel = nil
	end

	self.rootUComponent = nil

	TopLogoPetLevelUpComponent.super.resetRender(self)
end

function TopLogoPetLevelUpComponent:onDestroy()
	self:clearTimer()

	self.pendingLevel = nil
	self.playingLevel = nil

	TopLogoPetLevelUpComponent.super.onDestroy(self)
end

return TopLogoPetLevelUpComponent
