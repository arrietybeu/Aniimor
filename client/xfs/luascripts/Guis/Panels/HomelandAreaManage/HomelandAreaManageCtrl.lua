-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandAreaManage\\HomelandAreaManageCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandAreaManageCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local HomelandAreaManageCtrl = Class.LightClass("HomelandAreaManageCtrl", UICtrl)
local HomelandAreaData = require("Data.homeland_area_data")
local HomelandConfigData = require("Data.homeland_config_data")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeOrderConst = require("Common.Const.HomeOrderConst")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local HomelandWishStarData = require("Common.Homeland.HomelandWishStarData")
local TimerManager = require("Core.Timer.TimerManager")

HomelandAreaManageCtrl.UNLOCK_EFFECT_PREFS_KEY_PREFIX = "HomelandAreaUnlockEffect_"
HomelandAreaManageCtrl.DETAIL_LIST_SKIP_TEMPLATE_INDEX = 1
HomelandAreaManageCtrl.messages = {
	[MessageName.HOMELAND_AREA_LOCK_STATE_CHANGED] = {
		"onAreaLockStateChanged",
		true
	},
	[MessageName.ON_HOME_ORDER_LIST_CHANGED] = {
		"onHomeOrderListChanged",
		true
	},
	[MessageName.HOMELAND_WISH_STAR_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"onHomelandWishStarChanged",
		true
	},
	[MessageName.HOMELAND_PET_EVENT_STATE_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	}
}

function HomelandAreaManageCtrl:onCreate(info)
	self.areaItems = {}
	self.areaItems[Const.HOMELAND_AREA_TYPE.PRODUCE] = self.view.btnProductUButton
	self.areaItems[Const.HOMELAND_AREA_TYPE.BUILD] = self.view.btnBuildUButton
	self.areaItems[Const.HOMELAND_AREA_TYPE.SEASON] = self.view.btnSeasonUButton
	self.areaItems[Const.HOMELAND_AREA_TYPE.LAKE] = self.view.btnLakeUButton
	self.areaItems[Const.HOMELAND_AREA_TYPE.MINE] = self.view.btnOreUButton
	self.areaItems[Const.HOMELAND_AREA_TYPE.PUBLIC] = self.view.btnPublicUButton

	UICtrl.onCreate(self, info)
end

function HomelandAreaManageCtrl:addListener()
	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.view.listCurrencyUList:SetList(self:getCurrencyData())

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	ClientTextUtils.setText(self.view.titleText, pg.getGameString("HOME_AREA_OVERVIEW"))

	for areaId, areaItem in pairs(self.areaItems) do
		function areaItem.luaClick()
			self:onAreaItemClick(areaId)
		end
	end
end

function HomelandAreaManageCtrl:getCurrencyData()
	local currencyData = {}

	table.insert(currencyData, {
		itemId = Const.HomeCoinItemId
	})
	table.insert(currencyData, {
		itemId = Const.HomeDecCoinItemId
	})

	return currencyData
end

function HomelandAreaManageCtrl:onDestroy()
	if self.wishStarRefreshFrameId then
		TimerManager.delFrameCb(self.wishStarRefreshFrameId)

		self.wishStarRefreshFrameId = nil
	end

	if self.wishStarRefreshTimer then
		self:killTimer(self.wishStarRefreshTimer)

		self.wishStarRefreshTimer = nil
	end

	self.wishStarDisplayedCurrent = nil
	self.wishStarDisplayedHasBottle = nil
	self.wishStarDisplayedHasData = nil
	self.wishStarDisplayedCapacity = nil
	self.wishStarDisplayedIsFull = nil
	self.wishStarDetailList = nil
	self.wishStarDetailIndex = nil

	table.clear(self.areaItems)

	self.enterEventMark = false

	UICtrl.onDestroy(self)
end

function HomelandAreaManageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshAreaItems()

	if not self.wishStarRefreshTimer then
		self.wishStarRefreshTimer = self:startTimer(function()
			self:refreshWishStarProjection()
		end, 1, true)
	end

	self:checkAndPlayUnlockAreaEffect()
end

function HomelandAreaManageCtrl:onPostOpen(info, isReOpen)
	HomelandAreaManageCtrl.super.onPostOpen(self, info, isReOpen)
	self:triggerEnterEvent(info)
end

function HomelandAreaManageCtrl:triggerEnterEvent(info)
	if info and info.isFromPlotManage then
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	else
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	self.enterEventMark = false
end

function HomelandAreaManageCtrl:onShow()
	return
end

function HomelandAreaManageCtrl:onHide()
	return
end

function HomelandAreaManageCtrl:onVisibleChange(visible)
	if self.enterEventMark and visible then
		self.enterEventMark = false

		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function HomelandAreaManageCtrl:refreshAreaItems()
	local playerPosition = pg.me:getPosition()
	local currentAreaId, isInArea = pg.game.home:getCurPlayerAreaId(playerPosition, 10)

	self.currentAreaId = isInArea and currentAreaId or nil
	self.curSelectArea = isInArea and currentAreaId or pg.game.home:getNearestAreaId(playerPosition)

	if self._openInfo and self._openInfo.isFromPlotManage then
		self.curSelectArea = self._openInfo.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE
	end

	for areaId, areaItem in pairs(self.areaItems) do
		self:refreshAreaItem(areaItem, areaId)
	end

	self:refreshBuildAreaWishStarRedDot()
	self:refreshAreaInfo(self.curSelectArea)
end

function HomelandAreaManageCtrl:refreshAreaItem(button, areaId)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local areaData = HomelandAreaData[areaId] or {}

	ClientTextUtils.setText(txtName, pg.getLocalizationText(areaData.name))
	button:TryChangePage("Locked", pg.game.home:checkAreaLocked(areaId) and 1 or 0)
	button:TryChangePage("Location", self.currentAreaId == areaId and 1 or 0)
end

function HomelandAreaManageCtrl:onAreaItemClick(areaId)
	if pg.game.home:checkAreaNotOpened(areaId) then
		pg.global.showBubbleMessage(NoticeDef.HOME_AREA_NOT_OPEN)

		return
	end

	self:refreshAreaInfo(areaId)

	self.curSelectArea = areaId

	self:refreshAreasSelectState()
end

function HomelandAreaManageCtrl:refreshAreasSelectState()
	for areaId, areaItem in pairs(self.areaItems) do
		areaItem.isSelected = areaId == self.curSelectArea
	end
end

function HomelandAreaManageCtrl:refreshAreaInfo(areaId)
	local areaData = HomelandAreaData[areaId] or {}
	local areaInfoObjectReference = self.view.areaInfoObjectReference
	local scrollRect = areaInfoObjectReference:GetRefValue("scrollRectUScrollRect")
	local areaIcon = areaInfoObjectReference:GetRefValue("areaIcon")
	local areaName = areaInfoObjectReference:GetRefValue("areaName")
	local areaTip = areaInfoObjectReference:GetRefValue("areaTip")
	local bottomUWidget = areaInfoObjectReference:GetRefValue("bottomUWidget")

	bottomUWidget:TryChangePage("Teleport", 1)

	local teleportBtn = areaInfoObjectReference:GetRefValue("teleportBtn")
	local teleportText = teleportBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(teleportText, pg.getGameString("TELEPORT"))

	local content = scrollRect.content

	ClientTextUtils.setText(areaName, pg.getLocalizationText(areaData.name))

	areaIcon.url = areaData.icon

	function teleportBtn.luaClick()
		self:teleportToAreaPosition(areaId)
	end

	self:refreshAreaDetailInfo(content, areaId)

	if pg.game.home:checkAreaLocked(areaId) then
		areaTip:SetActive(true)
		teleportBtn:SetActive(false)

		if areaData.unlockConditionDes then
			ClientTextUtils.setText(areaTip, pg.getLocalizationText(areaData.unlockConditionDes))
		elseif areaData.startTime or areaData.startTimeRefId then
			local startTime = Utils.getConfigTimeOfAreaByData(areaData.startTime, areaData.startTimeRefId)
			local endTime = Utils.getConfigTimeOfAreaByData(areaData.endTime, areaData.endTimeRefId)
			local currentTime = Time.secondCache or Time.getSecond()

			if startTime and endTime and (currentTime < startTime or endTime <= currentTime) then
				ClientTextUtils.setText(areaTip, pg.getFormatText(pg.getGameString("HOME_AREA_OPEN_TIME"), LuaUIUtils.timeStampToUtcString(startTime)))
			else
				areaTip:SetActive(false)
			end
		end
	else
		local teleportPos = areaData.teleportPos

		teleportBtn:SetActive(teleportPos ~= nil)
		areaTip:SetActive(false)
	end
end

function HomelandAreaManageCtrl:getIncompleteHomeOrderCount()
	local orderNum = 0
	local rawShowList = pg.me.showList:getRawTable()

	for _, orderInfo in ipairs(rawShowList) do
		if orderInfo.orderStatus == HomeOrderConst.STATUS.Incomplete then
			orderNum = orderNum + 1
		end
	end

	return orderNum
end

function HomelandAreaManageCtrl:refreshAreaDetailInfo(content, areaId)
	local isAreaUnlocked = not pg.game.home:checkAreaLocked(areaId)
	local funcBtn = self.view.areaInfoObjectReference:GetRefValue("funcBtn")
	local btnText = funcBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	local areaData = HomelandAreaData[areaId] or {}
	local contentObjectRef = content:GetComponent("ObjectReference")
	local areaDesc = contentObjectRef:GetRefValue("areaDesc")
	local detailList = contentObjectRef:GetRefValue("detailList")

	self.homeOrderDetailList = nil
	self.homeOrderAreaInfo = nil

	ClientTextUtils.setText(areaDesc, pg.getLocalizationText(areaData.desc))

	function detailList.luaRenderItem(button, index, data)
		button:ClearRedDot()

		local objectRef = button:GetComponent("ObjectReference")

		if data.tIndex == HomelandAreaManageCtrl.DETAIL_LIST_SKIP_TEMPLATE_INDEX then
			local txtNameUSDFText = objectRef:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, data.title or "")
			button:TryChangePage("State", 0)

			button.interactable = data.interactable
			button.luaClick = data.onClick

			return
		end

		button.interactable = data.interactable ~= false
		button.luaClick = data.onClick

		local title = objectRef:GetRefValue("title")
		local detail = objectRef:GetRefValue("detail")
		local imgArrowUImage = objectRef:GetRefValue("imgArrowUImage")

		ClientTextUtils.setText(title, data.title or "")
		ClientTextUtils.setText(detail, data.value or "")
		imgArrowUImage:SetActive(data.onClick ~= nil)

		if data.redDotPath then
			pg.global.setRedDot(data.redDotPath, button, data.showRedDot == true, RedDotConst.RedDotStyle.POINT)
		end
	end

	local areaInfos = {}

	self.wishStarDetailList = nil
	self.wishStarDetailIndex = nil
	self.wishStarDisplayedHasBottle = nil
	self.wishStarDisplayedHasData = nil
	self.wishStarDisplayedCurrent = nil
	self.wishStarDisplayedCapacity = nil
	self.wishStarDisplayedIsFull = nil

	if areaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
		funcBtn:SetActive(isAreaUnlocked)
		ClientTextUtils.setText(btnText, pg.getGameString("VIEW_DETAIL"))

		function funcBtn.luaClick()
			pg.global.ui.homelandPlotManageNew:open({
				areaId = areaId
			})
		end

		local unlockZoneCount = 0
		local totalZoneCount = 0
		local zoneUnlockData = HomeLandUtils.getHomelandZoneUnlockData()

		for zoneId, zoneData in pairs(zoneUnlockData) do
			if zoneData.areaId == areaId then
				totalZoneCount = totalZoneCount + 1

				if pg.game.home:isHomelandZoneUnlock(zoneId) then
					unlockZoneCount = unlockZoneCount + 1
				end
			end
		end

		table.insert(areaInfos, {
			title = pg.getGameString("UNLOCK_ZONE_NUM"),
			value = unlockZoneCount .. "/" .. totalZoneCount
		})
	elseif areaId == Const.HOMELAND_AREA_TYPE.PUBLIC then
		self.homeOrderDetailList = detailList
		self.homeOrderAreaInfo = {
			title = pg.getGameString("ORDER_NUM"),
			value = tostring(self:getIncompleteHomeOrderCount()),
			interactable = isAreaUnlocked,
			onClick = function()
				pg.global.ui.homeOrder:open()
			end
		}

		table.insert(areaInfos, self.homeOrderAreaInfo)
		table.insert(areaInfos, {
			tIndex = HomelandAreaManageCtrl.DETAIL_LIST_SKIP_TEMPLATE_INDEX,
			title = pg.getGameString("HOME_STORE_NAME_1"),
			interactable = isAreaUnlocked,
			onClick = function()
				if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
					return
				end

				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						HomelandConfigData.homelandShopId
					}
				})
			end
		})
		table.insert(areaInfos, {
			tIndex = HomelandAreaManageCtrl.DETAIL_LIST_SKIP_TEMPLATE_INDEX,
			title = pg.getGameString("HOME_STORE_NAME_2"),
			interactable = isAreaUnlocked,
			onClick = function()
				pg.global.ui:open(UIConst.UI_ID_HOMELAND_MARKET, {})
			end
		})
		funcBtn:SetActive(false)
	elseif areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		local unlockZoneCount = 0
		local totalZoneCount = 0
		local zoneUnlockData = HomeLandUtils.getHomelandZoneUnlockData()

		for zoneId, zoneData in pairs(zoneUnlockData) do
			if zoneData.areaId == areaId then
				totalZoneCount = totalZoneCount + 1

				if pg.game.home:isHomelandZoneUnlock(zoneId) then
					unlockZoneCount = unlockZoneCount + 1
				end
			end
		end

		table.insert(areaInfos, {
			title = pg.getGameString("UNLOCK_ZONE_NUM"),
			value = unlockZoneCount .. "/" .. totalZoneCount
		})

		local wishStarSnapshot = HomelandWishStarData.getSnapshot(pg.space or pg.me.space)

		self.wishStarDisplayedHasBottle = wishStarSnapshot.hasBottle
		self.wishStarDisplayedHasData = wishStarSnapshot.hasData
		self.wishStarDisplayedCurrent = wishStarSnapshot.current
		self.wishStarDisplayedCapacity = wishStarSnapshot.capacity
		self.wishStarDisplayedIsFull = wishStarSnapshot.isFull

		if wishStarSnapshot.hasBottle then
			local wishStarValue = "--/--"

			if wishStarSnapshot.hasData then
				wishStarValue = pg.getFormatText(pg.getGameString("HOME_PET_STAR_OUTPUT_TOPLOGO"), wishStarSnapshot.current, wishStarSnapshot.capacity)
			end

			self.wishStarDetailList = detailList
			self.wishStarDetailIndex = #areaInfos

			table.insert(areaInfos, {
				title = pg.getGameString("HOME_PET_STAR_OUTPUT_TIPS"),
				value = wishStarValue,
				redDotPath = RedDotConst.RedDotPath.HOMELAND_WISH_STAR,
				showRedDot = wishStarSnapshot.isFull
			})
		end

		ClientTextUtils.setText(btnText, pg.getGameString("VIEW_DETAIL"))
		funcBtn:SetActive(isAreaUnlocked)

		function funcBtn.luaClick()
			pg.global.ui.homelandPlotManageNew:open({
				areaId = areaId
			})
		end
	else
		funcBtn:SetActive(false)
	end

	detailList:SetList(areaInfos)
end

function HomelandAreaManageCtrl:onAreaLockStateChanged(areaId)
	self:refreshAreaItems()
end

function HomelandAreaManageCtrl:onHomeOrderListChanged()
	if self.curSelectArea ~= Const.HOMELAND_AREA_TYPE.PUBLIC then
		return
	end

	self.homeOrderAreaInfo.value = tostring(self:getIncompleteHomeOrderCount())

	self.homeOrderDetailList:RefreshList()
end

function HomelandAreaManageCtrl:refreshBuildAreaWishStarRedDot()
	local wishStarSnapshot = HomelandWishStarData.getSnapshot(pg.space or pg.me.space)

	pg.global.setRedDot(RedDotConst.RedDotPath.HOMELAND_WISH_STAR, self.areaItems[Const.HOMELAND_AREA_TYPE.BUILD], wishStarSnapshot.hasBottle and wishStarSnapshot.isFull, RedDotConst.RedDotStyle.POINT)
end

function HomelandAreaManageCtrl:onHomelandWishStarChanged()
	self:refreshBuildAreaWishStarRedDot()

	if self.curSelectArea ~= Const.HOMELAND_AREA_TYPE.BUILD or self.wishStarRefreshFrameId then
		return
	end

	self.wishStarRefreshFrameId = TimerManager.addNextFrameCb(function()
		self.wishStarRefreshFrameId = nil

		self:refreshWishStarProjection()
	end)
end

function HomelandAreaManageCtrl:refreshWishStarProjection()
	if self.curSelectArea ~= Const.HOMELAND_AREA_TYPE.BUILD or not self:checkUIVisible() then
		return
	end

	local wishStarSnapshot = HomelandWishStarData.getSnapshot(pg.space or pg.me.space)

	if wishStarSnapshot.hasBottle ~= self.wishStarDisplayedHasBottle then
		self:refreshAreaInfo(self.curSelectArea)

		return
	end

	if not wishStarSnapshot.hasBottle then
		return
	end

	local displayChanged = wishStarSnapshot.hasData ~= self.wishStarDisplayedHasData or wishStarSnapshot.current ~= self.wishStarDisplayedCurrent or wishStarSnapshot.capacity ~= self.wishStarDisplayedCapacity or wishStarSnapshot.isFull ~= self.wishStarDisplayedIsFull

	if not displayChanged then
		return
	end

	self.wishStarDisplayedHasData = wishStarSnapshot.hasData
	self.wishStarDisplayedCurrent = wishStarSnapshot.current
	self.wishStarDisplayedCapacity = wishStarSnapshot.capacity
	self.wishStarDisplayedIsFull = wishStarSnapshot.isFull

	if not self.wishStarDetailList or self.wishStarDetailIndex == nil then
		self:refreshAreaInfo(self.curSelectArea)

		return
	end

	local wishStarValue = "--/--"

	if wishStarSnapshot.hasData then
		wishStarValue = pg.getFormatText(pg.getGameString("HOME_PET_STAR_OUTPUT_TOPLOGO"), wishStarSnapshot.current, wishStarSnapshot.capacity)
	end

	self.wishStarDetailList:SetElement(self.wishStarDetailIndex, {
		title = pg.getGameString("HOME_PET_STAR_OUTPUT_TIPS"),
		value = wishStarValue,
		redDotPath = RedDotConst.RedDotPath.HOMELAND_WISH_STAR,
		showRedDot = wishStarSnapshot.isFull
	})
end

function HomelandAreaManageCtrl:teleportToAreaPosition(areaId)
	if pg.game.home.curLoginPlaceShowConfirmHint then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_AREA_TEMEPORT_CONFIRM"), function()
			self:doTeleportToArea(areaId)
		end, nil, nil, nil, nil, {
			hint = true,
			hintCb = function(isSelected)
				pg.game.home.curLoginPlaceShowConfirmHint = not isSelected
			end
		})
	else
		self:doTeleportToArea(areaId)
	end
end

function HomelandAreaManageCtrl:doTeleportToArea(areaId)
	local areaData = HomelandAreaData[areaId] or {}
	local teleportPos = areaData.teleportPos

	if teleportPos then
		pg.me:CallServerMsgTeleportToScene(pg.me.space.sceneId, teleportPos, false)
	end

	self:close()
end

function HomelandAreaManageCtrl:checkAndPlayUnlockAreaEffect()
	for areaId in pairs(self.areaItems) do
		local areaData = HomelandAreaData[areaId]

		if areaData and areaData.isUnlock ~= 1 and not pg.game.home:checkAreaLocked(areaId) then
			self:playFirstUnlockAreaEffect(areaId)
		end
	end
end

function HomelandAreaManageCtrl:playFirstUnlockAreaEffect(areaId)
	local areaItem = self.areaItems[areaId]

	if not areaItem then
		return
	end

	local prefsKey = HomelandAreaManageCtrl.UNLOCK_EFFECT_PREFS_KEY_PREFIX .. areaId
	local cacheType = ClientConst.CACHE_TYPE_FLAG.USER

	if pg.global.prefsCacheUtils:getBool(prefsKey, false, cacheType) then
		return
	end

	pg.global.prefsCacheUtils:setBool(prefsKey, true, cacheType)
	areaItem:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

return HomelandAreaManageCtrl
