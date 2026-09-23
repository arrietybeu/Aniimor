-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoCallFriendsComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local logger = LoggerManager.getLogger("TopLogoCallFriendsComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoCallFriendsComponent = Class.LightClass("TopLogoCallFriendsComponent", TopLogoItemComponent)

function TopLogoCallFriendsComponent:ctor(refUContainer, topLogoItem)
	TopLogoCallFriendsComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoCallFriendsComponent:shouldBeActive()
	return self.canCallFriends == true
end

function TopLogoCallFriendsComponent:resetRender()
	self.lastWetCount = -1
	self.lastPercent = -1

	if self.m_cbCacheCallFriendsInfo then
		self.m_cbCacheCallFriendsInfo = nil
	end

	self.objectReference = nil
	self.rootComponent = nil
	self.animation = nil
	self.numTextPlus = nil
	self.WaterProgress = nil
	self.CountDownProgress = nil
	self.sandGlassProgress = nil

	TopLogoCallFriendsComponent.super.resetRender(self)
end

function TopLogoCallFriendsComponent:onDestroy()
	TopLogoCallFriendsComponent.super.onDestroy(self)

	self.m_cbCacheCallFriendsInfo = nil
	self.m_loadedCallFriendsCallBack = nil
end

function TopLogoCallFriendsComponent:onCtor()
	if not self.entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("TopLogoCallFriendsComponent >> entity is null")
		end

		return
	end

	local cfg = self.entity:getConfigData()

	self.lastWetCount = -1
	self.lastPercent = -1
	self.canCallFriends = cfg.callFriend and cfg.showWetToplogo

	self:refreshVisible()
end

function TopLogoCallFriendsComponent:initUI()
	if not self.entity then
		return
	end

	self.WaterProgress.value = 0
end

function TopLogoCallFriendsComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.WaterProgress = self.objectReference:GetRefValue("WaterProgress")
	self.CountDownProgress = self.objectReference:GetRefValue("CountDownProgress")
	self.numTextPlus = self.objectReference:GetRefValue("numTextPlus")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.sandGlassProgress = self.objectReference:GetRefValue("sandGlassProgress")
	self.animation = self.objectReference:GetRefValue("animation")
end

function TopLogoCallFriendsComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoCallFriendsComponent.super.onLanguageChanged(self)
end

function TopLogoCallFriendsComponent:addEntityListener()
	return
end

function TopLogoCallFriendsComponent:addListener()
	return
end

function TopLogoCallFriendsComponent:innerGetVisible()
	if not TopLogoCallFriendsComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.canCallFriends then
		return false
	end

	local maxDistance = SysConfigData.CALL_FRIENDS_TOP_LOGO_MAX_DISTANCE or 20

	if maxDistance < self.topLogoItem.distance then
		return false
	end

	return true
end

function TopLogoCallFriendsComponent:refreshTopLogoInfo()
	local info = self.entity and self.entity.topLogoData and self.entity.topLogoData.ecsWaterTopLogo

	if info then
		self:refreshEcsTopLogoInfo(info.wetCount, info.totalWetCount, info.percent)
	end
end

function TopLogoCallFriendsComponent:refreshEcsTopLogoInfo(wetCount, totalWetCount, percent)
	self.m_cbCacheCallFriendsInfo = {
		wetCount = wetCount,
		totalWetCount = totalWetCount,
		percent = percent
	}

	local rootReadyAndActive = self.topLogoItem and self.topLogoItem:isTopLogoPrefabReady() and self:innerGetVisible()

	if self:checkFinalVisible() or rootReadyAndActive then
		if self:checkContainerLoaded() then
			self:m_refreshTplCallFriends()
		else
			if not self.m_loadedCallFriendsCallBack then
				function self.m_loadedCallFriendsCallBack(isSuccess)
					if isSuccess then
						self:m_refreshTplCallFriends()
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedCallFriendsCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	end
end

function TopLogoCallFriendsComponent:m_refreshTplCallFriends()
	if self.m_cbCacheCallFriendsInfo then
		self:updateWaterProgress(self.m_cbCacheCallFriendsInfo.wetCount, self.m_cbCacheCallFriendsInfo.totalWetCount)
		self:updateCountDown(self.m_cbCacheCallFriendsInfo.percent)

		self.m_cbCacheCallFriendsInfo = nil
	end
end

function TopLogoCallFriendsComponent:updateWaterProgress(wetCount, totalWetCount)
	if wetCount == self.lastWetCount then
		return
	end

	if totalWetCount > 1 then
		ClientTextUtils.setText(self.numTextPlus, wetCount, "/", totalWetCount)
	end

	if totalWetCount <= 1 then
		self.rootComponent:TryChangePage("Type", 0)
	else
		self.rootComponent:TryChangePage("Type", 1)
	end

	if wetCount > self.lastWetCount then
		pg.game.audio:triggerEvent("plant_water_add")
		self.animation:Play("VX_WaterInteraction_Primary_Change")
	end

	self.lastWetCount = wetCount

	if wetCount > 0 and wetCount < totalWetCount then
		self.rootComponent:TryChangePage("State", 1)
	end

	self.WaterProgress:ProgressToValue(wetCount / totalWetCount, function()
		if wetCount <= 0 then
			self.rootComponent:TryChangePage("State", 0)
		elseif wetCount >= totalWetCount then
			self.rootComponent:TryChangePage("State", 2)
			pg.game.audio:triggerEvent("plant_water_full")
			self.animation:Play("VX_WaterInteraction_Primary_Full")
		else
			self.rootComponent:TryChangePage("State", 1)
		end
	end, math.abs(self.WaterProgress.value - wetCount / totalWetCount), 0, CS.DG.Tweening.Ease.__CastFrom(Const.DoTweenEaseType.InQuad))

	if totalWetCount <= 1 and wetCount <= 0 then
		LuaUIUtils.setUIViewVisible(self.rootComponent, false)
	else
		LuaUIUtils.setUIViewVisible(self.rootComponent, true)
	end
end

function TopLogoCallFriendsComponent:updateCountDown(percent)
	if not self.entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("TopLogoCallFriendsComponent >> entity is null")
		end

		return
	end

	if self.lastPercent - percent < 0.01 then
		return
	end

	self.CountDownProgress:ProgressToValue(percent, nil)
	self.sandGlassProgress:ProgressToValue(percent, nil)
end

function TopLogoCallFriendsComponent:getInitMaxDistance()
	return SysConfigData.CALL_FRIENDS_TOP_LOGO_MAX_DISTANCE
end

return TopLogoCallFriendsComponent
