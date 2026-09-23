-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoHomeWishingStarComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local HomelandWishStarData = require("Common.Homeland.HomelandWishStarData")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local HomelandConfigData = require("Data.homeland_config_data")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoHomeWishingStarComponent = Class.LightClass("TopLogoHomeWishingStarComponent", TopLogoItemComponent)

TopLogoHomeWishingStarComponent.MAIN_STATE = {
	PRODUCING = 1,
	STANDBY = 0,
	COLLECTABLE = 2
}
TopLogoHomeWishingStarComponent.DISTANCE_STATE = {
	CENTER = 1,
	NEAR = 0
}
TopLogoHomeWishingStarComponent.MAX_DISTANCE_FALLBACK = 10
TopLogoHomeWishingStarComponent.SNAPSHOT_REFRESH_INTERVAL_SECONDS = 1
TopLogoHomeWishingStarComponent.EMPTY_REQUIRE_LIST = {}

function TopLogoHomeWishingStarComponent:ctor(refUContainer, topLogoItem)
	TopLogoHomeWishingStarComponent.super.ctor(self, refUContainer, topLogoItem)

	local topLogoSystem = pg.game and pg.game.topLogo

	if topLogoSystem and topLogoSystem.homeFacilityLimiter then
		topLogoSystem.homeFacilityLimiter:register(self.entity.actorId, self)

		self.registeredFacilityLimiter = true
	end

	self.ignoreCompVisibleCheck = true
	self.wishingStarSnapshot = nil
	self.wishingStarSnapshotRefreshTick = nil
	self.lastRenderedWishingStarHasData = nil
	self.lastRenderedWishingStarCurrent = nil
	self.lastRenderedWishingStarCapacity = nil
	self.lastRenderedWishingStarMainState = nil
	self.lastRenderedDetailHasData = nil
	self.lastRenderedDetailEfficiency = nil
end

function TopLogoHomeWishingStarComponent:onDestroy()
	local topLogoSystem = pg.game and pg.game.topLogo

	if self.registeredFacilityLimiter and topLogoSystem and topLogoSystem.homeFacilityLimiter then
		topLogoSystem.homeFacilityLimiter:unregister(self.entity.actorId)
	end

	self.registeredFacilityLimiter = nil
	self.loadedWishingStarCallback = nil
	self.tipsLoadingContainer = nil
	self.wishingStarSnapshot = nil
	self.wishingStarSnapshotRefreshTick = nil
	self.lastRenderedWishingStarHasData = nil
	self.lastRenderedWishingStarCurrent = nil
	self.lastRenderedWishingStarCapacity = nil
	self.lastRenderedWishingStarMainState = nil
	self.lastRenderedDetailHasData = nil
	self.lastRenderedDetailEfficiency = nil

	TopLogoHomeWishingStarComponent.super.onDestroy(self)
end

function TopLogoHomeWishingStarComponent:shouldBeActive()
	return true
end

function TopLogoHomeWishingStarComponent:getInitMaxDistance()
	return self.entity.overrideTopLogoEnterDistance or HomelandConfigData.facilityTopLogoEnterDistance or TopLogoHomeWishingStarComponent.MAX_DISTANCE_FALLBACK
end

function TopLogoHomeWishingStarComponent:findObjects()
	local content = self.refUContainer and self.refUContainer.content

	if not content or IsNil(content) then
		return
	end

	self.objectReference = content:GetComponent("ObjectReference")

	if not self.objectReference or IsNil(self.objectReference) then
		return
	end

	self.widget = self.objectReference:GetComponent("UWidget")
	self.warnRoot = self.objectReference:GetRefValue("warnRoot")
	self.warnIcon = self.objectReference:GetRefValue("warnIcon")
	self.warnText = self.objectReference:GetRefValue("warnText")
	self.buffList = self.objectReference:GetRefValue("buffList")
	self.numText = self.objectReference:GetRefValue("numText")
	self.numBox = self.objectReference:GetRefValue("numBox")
	self.progress = self.objectReference:GetRefValue("progress")
	self.icon = self.objectReference:GetRefValue("icon")
	self.requireWidget = self.objectReference:GetRefValue("requireWidget")
	self.lackWater = self.objectReference:GetRefValue("lackWaterUWidget")
	self.envContainerUContainer = self.objectReference:GetRefValue("envContainerUContainer")
	self.tipsUContainer = self.objectReference:GetRefValue("tipsUContainer")
	self.progressHighImg = self.objectReference:GetRefValue("progressHighImg")
end

function TopLogoHomeWishingStarComponent:initUI()
	self.wishingStarSnapshot = nil
	self.wishingStarSnapshotRefreshTick = nil
	self.lastRenderedWishingStarHasData = nil
	self.lastRenderedWishingStarCurrent = nil
	self.lastRenderedWishingStarCapacity = nil
	self.lastRenderedWishingStarMainState = nil
	self.lastRenderedDetailHasData = nil
	self.lastRenderedDetailEfficiency = nil

	TopLogoHomeWishingStarComponent.super.initUI(self)

	if not self.widget or IsNil(self.widget) then
		return
	end

	self.widget:TryChangePage("ActiveState", 0)
	self.widget:TryChangePage("NumState", 0)
	self.widget:TryChangePage("ShowDetail", 0)
	self.widget:TryChangePage("Distance", TopLogoHomeWishingStarComponent.DISTANCE_STATE.CENTER)

	if self.warnIcon and NotNil(self.warnIcon) then
		self.warnIcon:SetActive(false)
	end

	if self.buffList and NotNil(self.buffList) then
		self.buffList:SetList(TopLogoHomeWishingStarComponent.EMPTY_REQUIRE_LIST)
	end

	if self.numBox and NotNil(self.numBox) then
		self.numBox:SetActive(false)
	end

	if self.requireWidget and NotNil(self.requireWidget) then
		self.requireWidget:SetActive(false)
	end

	if self.lackWater and NotNil(self.lackWater) then
		self.lackWater:SetActive(false)
	end

	if self.envContainerUContainer and NotNil(self.envContainerUContainer) then
		self.envContainerUContainer:SetActive(false)
	end

	if self.icon and NotNil(self.icon) then
		self.icon.url = LuaUIUtils.getIconByItemId(Const.HomeDecCoinItemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL)
	end

	self:refreshWishingStarInfo(false)
end

function TopLogoHomeWishingStarComponent:resetRender()
	self.objectReference = nil
	self.widget = nil
	self.warnRoot = nil
	self.warnIcon = nil
	self.warnText = nil
	self.buffList = nil
	self.numText = nil
	self.numBox = nil
	self.progress = nil
	self.icon = nil
	self.requireWidget = nil
	self.lackWater = nil
	self.envContainerUContainer = nil
	self.tipsUContainer = nil
	self.progressHighImg = nil
	self.tipsInfoComponent = nil
	self.tipsRequireText = nil
	self.tipsRequireTitleText = nil
	self.tipsRequireList = nil
	self.timeText = nil
	self.demandUComponent = nil
	self.tipsLoadingContainer = nil
	self.distanceState = nil
	self.showDetail = nil
	self.wishingStarSnapshot = nil
	self.wishingStarSnapshotRefreshTick = nil
	self.lastRenderedWishingStarHasData = nil
	self.lastRenderedWishingStarCurrent = nil
	self.lastRenderedWishingStarCapacity = nil
	self.lastRenderedWishingStarMainState = nil
	self.lastRenderedDetailHasData = nil
	self.lastRenderedDetailEfficiency = nil

	TopLogoHomeWishingStarComponent.super.resetRender(self)
end

function TopLogoHomeWishingStarComponent:innerGetVisible()
	if not TopLogoHomeWishingStarComponent.super.innerGetVisible(self) then
		return false
	end

	local space = self.entity and self.entity.space

	return space ~= nil and space.isSelfHomeland ~= nil and space:isSelfHomeland()
end

function TopLogoHomeWishingStarComponent:refreshTopLogoInfo(callFromUpdate)
	if not self:checkFinalVisible() then
		return
	end

	if self:checkContainerLoaded() then
		self:refreshWishingStarInfo(callFromUpdate)

		return
	end

	if not self.loadedWishingStarCallback then
		function self.loadedWishingStarCallback()
			if self:checkContainerLoaded() then
				self:refreshWishingStarInfo(false)
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.loadedWishingStarCallback, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoHomeWishingStarComponent:refreshWishingStarInfo(callFromUpdate)
	if not self.widget or IsNil(self.widget) then
		return
	end

	local currentTick = Time.getTickSecond()
	local lastRefreshTick = self.wishingStarSnapshotRefreshTick
	local snapshotRefreshed = false

	if not self.wishingStarSnapshot or not callFromUpdate or type(lastRefreshTick) ~= "number" or currentTick < lastRefreshTick or currentTick - lastRefreshTick >= TopLogoHomeWishingStarComponent.SNAPSHOT_REFRESH_INTERVAL_SECONDS then
		self.wishingStarSnapshot = HomelandWishStarData.getSnapshot(self.entity and self.entity.space) or {}
		self.wishingStarSnapshotRefreshTick = currentTick
		snapshotRefreshed = true
	end

	local snapshot = self.wishingStarSnapshot
	local hasData = snapshot.hasData and snapshot.hasBottle or false
	local current = math.max(tonumber(snapshot.current) or 0, 0)
	local capacity = math.max(tonumber(snapshot.capacity) or 0, 0)
	local isFull = snapshot.hasData and snapshot.isFull
	local mainState = TopLogoHomeWishingStarComponent.MAIN_STATE.STANDBY

	if isFull then
		mainState = TopLogoHomeWishingStarComponent.MAIN_STATE.COLLECTABLE
	elseif hasData and snapshot.hasBuildPets then
		mainState = TopLogoHomeWishingStarComponent.MAIN_STATE.PRODUCING
	end

	local mainInfoChanged = self.lastRenderedWishingStarHasData ~= hasData or self.lastRenderedWishingStarCurrent ~= current or self.lastRenderedWishingStarCapacity ~= capacity or self.lastRenderedWishingStarMainState ~= mainState

	if snapshotRefreshed or not callFromUpdate or mainInfoChanged then
		self.widget:TryChangePage("MainState", mainState)

		local progressText = "--"

		if hasData and capacity > 0 then
			progressText = pg.getFormatText(pg.getGameString("HOME_PET_STAR_OUTPUT_TOPLOGO"), math.floor(current), math.floor(capacity))
		end

		if mainState == TopLogoHomeWishingStarComponent.MAIN_STATE.COLLECTABLE then
			progressText = pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_CLAIMABLE")
		end

		if self.warnText and NotNil(self.warnText) then
			ClientTextUtils.setText(self.warnText, progressText)

			self.warnText.color = CS.UnityEngine.Color.white
		end

		local progressVisible = mainState == TopLogoHomeWishingStarComponent.MAIN_STATE.PRODUCING

		if self.progress and NotNil(self.progress) then
			self.progress:SetActive(progressVisible)

			self.progress.maxValue = capacity > 0 and capacity or 1
			self.progress.value = capacity > 0 and math.min(current, capacity) or 0
		end

		if self.progressHighImg and NotNil(self.progressHighImg) then
			local progressRatio = capacity > 0 and math.min(current / capacity, 1) or 0

			self.progressHighImg:SetImgFillAmount(progressRatio)
		end

		self.lastRenderedWishingStarHasData = hasData
		self.lastRenderedWishingStarCurrent = current
		self.lastRenderedWishingStarCapacity = capacity
		self.lastRenderedWishingStarMainState = mainState
	end

	local detailInfoChanged = self.lastRenderedDetailHasData ~= hasData or self.lastRenderedDetailEfficiency ~= snapshot.efficiency

	self:refreshDistanceState(snapshot, snapshotRefreshed or not callFromUpdate or detailInfoChanged)
end

function TopLogoHomeWishingStarComponent:refreshDistanceState(snapshot, refreshDetail)
	if not self.widget or IsNil(self.widget) or type(self.compDistance) ~= "number" then
		return
	end

	local nearDistance = HomelandConfigData.facilityTopLogoNearDistance or 3
	local isNear = self.compDistance >= 0 and nearDistance > self.compDistance
	local distanceState = isNear and TopLogoHomeWishingStarComponent.DISTANCE_STATE.NEAR or TopLogoHomeWishingStarComponent.DISTANCE_STATE.CENTER

	if self.distanceState ~= distanceState then
		self.distanceState = distanceState

		self.widget:TryChangePage("Distance", distanceState)
	end

	local homeSystem = pg.game and pg.game.home
	local shouldShowDetail = isNear and snapshot.hasData and snapshot.hasBottle and snapshot.hasBuildPets and homeSystem and self.entity.id == homeSystem.curInteractEntId or false
	local detailOpened = false

	if self.showDetail ~= shouldShowDetail then
		self.showDetail = shouldShowDetail

		self.widget:TryChangePage("ShowDetail", shouldShowDetail and 1 or 0)

		detailOpened = shouldShowDetail
	end

	if shouldShowDetail and (detailOpened or refreshDetail) then
		self:tryLoadDetail(snapshot)
	end

	if self.warnRoot and NotNil(self.warnRoot) then
		self.warnRoot:SetActive(not shouldShowDetail)
	end
end

function TopLogoHomeWishingStarComponent:tryLoadDetail(snapshot)
	if self.tipsInfoComponent and NotNil(self.tipsInfoComponent) then
		self:refreshDetailInfos(snapshot)

		return
	end

	local tipsContainer = self.tipsUContainer

	if not tipsContainer or IsNil(tipsContainer) then
		return
	end

	if tipsContainer:CheckURLLoaded() then
		if self:initDetailObjects() then
			self:refreshDetailInfos(snapshot)
		end

		return
	end

	if self.tipsLoadingContainer == tipsContainer then
		return
	end

	self.tipsLoadingContainer = tipsContainer

	tipsContainer:LoadDefaultUrlManually(function()
		if self.tipsLoadingContainer == tipsContainer then
			self.tipsLoadingContainer = nil
		end

		if self.tipsUContainer ~= tipsContainer or IsNil(tipsContainer) or not tipsContainer.content or IsNil(tipsContainer.content) then
			return
		end

		if self:initDetailObjects() then
			self:refreshDetailInfos(self.wishingStarSnapshot or {})

			if self.tipsInfoComponent and NotNil(self.tipsInfoComponent) then
				self.tipsInfoComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end
		end
	end)
end

function TopLogoHomeWishingStarComponent:initDetailObjects()
	local tipsContainer = self.tipsUContainer

	if not tipsContainer or IsNil(tipsContainer) or not tipsContainer.content or IsNil(tipsContainer.content) then
		return false
	end

	local tipsInfoComponent = tipsContainer.content:GetComponent("UComponent")

	if not tipsInfoComponent or IsNil(tipsInfoComponent) then
		return false
	end

	local objectReference = tipsInfoComponent:GetComponent("ObjectReference")

	if not objectReference or IsNil(objectReference) then
		return false
	end

	self.tipsInfoComponent = tipsInfoComponent
	self.tipsRequireText = objectReference:GetRefValue("requireText")
	self.tipsRequireTitleText = objectReference:GetRefValue("requireTitleText")
	self.tipsRequireList = objectReference:GetRefValue("requireList")
	self.timeText = objectReference:GetRefValue("timeText")
	self.demandUComponent = objectReference:GetRefValue("demandUComponent")

	self.tipsInfoComponent:TryChangePage("State", 0)
	self.tipsInfoComponent:TryChangePage("ShowDemand", 0)

	if self.demandUComponent and NotNil(self.demandUComponent) then
		self.demandUComponent:SetActive(true)
		self.demandUComponent:TryChangePage("Condition", 0)
	end

	if self.tipsRequireList and NotNil(self.tipsRequireList) then
		self.tipsRequireList:SetList(TopLogoHomeWishingStarComponent.EMPTY_REQUIRE_LIST)
	end

	self.lastRenderedDetailHasData = nil
	self.lastRenderedDetailEfficiency = nil

	return true
end

function TopLogoHomeWishingStarComponent:refreshDetailInfos(snapshot)
	if not self.tipsInfoComponent or IsNil(self.tipsInfoComponent) then
		return
	end

	local current = math.max(tonumber(snapshot.current) or 0, 0)
	local capacity = math.max(tonumber(snapshot.capacity) or 0, 0)
	local progressText = "--"

	if snapshot.hasData and snapshot.hasBottle and capacity > 0 then
		progressText = pg.getFormatText(pg.getGameString("HOME_PET_STAR_OUTPUT_TOPLOGO"), math.floor(current), math.floor(capacity))
	end

	if snapshot.hasData and snapshot.isFull then
		progressText = pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_CLAIMABLE")
	end

	if self.tipsRequireTitleText and NotNil(self.tipsRequireTitleText) then
		ClientTextUtils.setText(self.tipsRequireTitleText, progressText)
	end

	if self.timeText and NotNil(self.timeText) then
		ClientTextUtils.setText(self.timeText, "")
	end

	if self.tipsRequireText and NotNil(self.tipsRequireText) then
		local efficiencyText = "--"

		if snapshot.hasData and snapshot.hasBottle and snapshot.efficiency ~= nil then
			efficiencyText = LuaUIUtils.formatHomeWishingStarOutput(snapshot.efficiency)
		end

		ClientTextUtils.setText(self.tipsRequireText, pg.getGameString("HOME_PET_STAR_OUTPUT_SPEED_TOPLOGO") .. efficiencyText)
	end

	self.lastRenderedDetailHasData = snapshot.hasData and snapshot.hasBottle or false
	self.lastRenderedDetailEfficiency = snapshot.efficiency
end

function TopLogoHomeWishingStarComponent:onLanguageChanged()
	if self:checkContainerLoaded() then
		self:refreshWishingStarInfo(false)
	end
end

return TopLogoHomeWishingStarComponent
