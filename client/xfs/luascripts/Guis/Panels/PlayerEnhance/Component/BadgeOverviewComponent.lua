-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\Component\\BadgeOverviewComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local PlayerBadgeData = require("Data.player_badge_data")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local Utils = require("Common.Utils.Utils")
local BadgeOverviewComponent = Class.LiteClass("BadgeOverviewComponent", UIComponent)
local firstEnterAnimation = "VX_Ani_Node_Personal_Badge_FirstIn"
local enterAnimation = "VX_Ani_Node_Personal_Badge_In"
local badgeRefreshAnimation = "VX_Ani_Node_UI_Personal_Badge_ItemRefresh"
local UIUtils = UIUtils

function BadgeOverviewComponent:onCtor(info)
	return
end

function BadgeOverviewComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")

	local routeUWidget = objectReference:GetRefValue("routeUWidget")
	local route1UWidget = objectReference:GetRefValue("route1UWidget")
	local route2UWidget = objectReference:GetRefValue("route2UWidget")
	local route3UWidget = objectReference:GetRefValue("route3UWidget")
	local route4UWidget = objectReference:GetRefValue("route4UWidget")
	local routeUList = objectReference:GetRefValue("routeUList")
	local route1UList = objectReference:GetRefValue("route1UList")
	local route2UList = objectReference:GetRefValue("route2UList")
	local route3UList = objectReference:GetRefValue("route3UList")
	local route4UList = objectReference:GetRefValue("route4UList")

	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.rootView = self.transform:GetComponent("UComponent")
	self.rootAnim = self.transform:GetComponent("Animation")
	self.route = {}
	self.route[1] = routeUWidget
	self.route[2] = route1UWidget
	self.route[3] = route2UWidget
	self.route[4] = route3UWidget
	self.route[5] = route4UWidget
	self.routeList = {}
	self.routeList[1] = routeUList
	self.routeList[2] = route1UList
	self.routeList[3] = route2UList
	self.routeList[4] = route3UList
	self.routeList[5] = route4UList
end

function BadgeOverviewComponent:registerObjects()
	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local titleIconUImage = objectReference:GetRefValue("titleIconUImage")
		local titleIconSelUImage = objectReference:GetRefValue("titleIconSelUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local name, icon, iconSelect = BadgeUtils.getNameAndIconByMainType(data.tabType)

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))

		titleIconUImage.url = icon
		titleIconSelUImage.url = iconSelect

		function button.luaClick()
			if self.isInUnlockAnim == true then
				return
			end

			self:clickTabInner(button, index)
		end

		self:refreshTabRed(button, index + 1)
	end

	for idx, list in pairs(self.routeList) do
		function list.luaRenderItem(button, index, data)
			self:_renderBadgeSuite(button, index, data, idx)
		end

		list:RegisterToScrollEvent(function(pos)
			self:onListScroll(pos.x, idx)
		end)
	end

	function self.btnLeftUButton.luaClick()
		self:onClickArrow(self.curLookListIndex - 1)
	end

	function self.btnRightUButton.luaClick()
		self:onClickArrow(self.curLookListIndex + 1)
	end

	self.ctrl:addNavFocusListener(function()
		local cb = self._onGamepadNavFocusMoved

		if type(cb) == "function" then
			cb(self)
		end
	end, "BadgeOverview")
end

function BadgeOverviewComponent:initView()
	self.tabData = {}
	self.listTab = {}

	local tmpTab = {
		BadgeUtils.BADGE_TYPE.MASTER_PATH,
		BadgeUtils.BADGE_TYPE.CHAMPION_PATH,
		BadgeUtils.BADGE_TYPE.EXPLORE_PATH,
		BadgeUtils.BADGE_TYPE.GLITZ_PATH,
		BadgeUtils.BADGE_TYPE.SPECIAL_PATH
	}

	for _, v in ipairs(tmpTab) do
		if BadgeUtils.checkBadgeTypeIsUnlock(v) then
			table.insert(self.listTab, {
				tabType = v
			})
		end
	end

	self.listTabUList:SetList(self.listTab)

	for k, v in ipairs(self.listTab) do
		local tabData = BadgeUtils.getDataByTab(v.tabType)

		self.tabData[k] = tabData
	end
end

function BadgeOverviewComponent:open(pathType, lookBadgeId)
	self.seasonStage = Utils.getCurrentSeasonStage() or {}
	self.needDelete = {}

	local enterType = pathType or BadgeUtils.BADGE_TYPE.MASTER_PATH

	self.lookBadgeGroupId = BadgeUtils.getGroupId(lookBadgeId)

	local mainType, subType, inCfg = BadgeUtils.getTypeByBadgeId(lookBadgeId)

	if inCfg then
		enterType = mainType
		self.initSubType = subType
	else
		self.initSubType = self:getInitSubType(enterType)
	end

	self:initNeedPlayerUnlockVX()
	self.listTabUList:RefreshList()

	local enterTabIndex = self:tryGetTabIndexByType(enterType)
	local res, tabItem = self.listTabUList:TryGetChildAt(enterTabIndex - 1)

	self.isInUnlockAnim = false

	for _, route in ipairs(self.route) do
		route:SetActive(true)
		route:SetActiveFastest(false)
	end

	local firstEnter = BadgeUtils.getFirstEnterBadgeUI()

	if firstEnter then
		BadgeUtils.setFirstEnterBadgeUI(false)

		local animLength = UIUtils.GetAnimationClipLength(self.rootAnim, firstEnterAnimation)

		self.rootAnim:Play(firstEnterAnimation)

		self.isInFirstAnim = true

		self.ctrl:startTimer(function()
			self.isInFirstAnim = false

			if res then
				tabItem:OnClickSimulate()
			end
		end, animLength)
	else
		self.rootView:TryChangePage("BadgeOpen", 1)
		self.rootAnim:Play(enterAnimation)

		self.isInFirstAnim = false

		if res then
			tabItem:OnClickSimulate()
		end
	end
end

function BadgeOverviewComponent:close()
	self:_stopRouteStateTimer()
	self.ctrl:killTimer(self.unlockTimerId)

	self.unlockTimerId = nil

	self:refreshTabRedDot()

	if self.tabIndex then
		self.listTabUList:RefreshElement(self.tabIndex - 1)
		self.route[self.tabIndex]:SetActive(false)
	end

	if self.selectTab then
		self.selectTab.isSelected = false
	end

	self.selectTab = nil
	self.tabIndex = nil
	self.isInUnlockAnim = nil

	if self.rootAnim then
		self.rootAnim:Stop()
		UIUtils.SampleAnimation(self.rootAnim, 0, enterAnimation)
	end
end

function BadgeOverviewComponent:onDestroy()
	self:close()
end

function BadgeOverviewComponent:checkCanDismiss()
	return not self.isInFirstAnim
end

function BadgeOverviewComponent:tryGetTabIndexByType(tabType)
	for k, v in ipairs(self.listTab) do
		if v.tabType == tabType then
			return k
		end
	end

	return 1
end

function BadgeOverviewComponent:getInitSubType(mainType)
	local subType = BadgeUtils.getSeasonBadgeBoxSubType(mainType, self.seasonStage.seasonId, self.seasonStage.stageId)

	if self:checkHasSubType(mainType, subType) then
		return subType
	end

	subType = BadgeUtils.getLastLookBadgeBoxSubType(mainType)

	if self:checkHasSubType(mainType, subType) then
		return subType
	end
end

function BadgeOverviewComponent:checkHasSubType(mainType, subType)
	if mainType == nil or subType == nil or subType <= 0 then
		return false
	end

	local tabIndex = self:tryGetTabIndexByType(mainType)
	local tabData = self.tabData[tabIndex]

	if tabData == nil then
		return false
	end

	for _, data in ipairs(tabData) do
		if data.subType == subType then
			return true
		end
	end

	return false
end

function BadgeOverviewComponent:getInitLookIndex()
	local tabData = self.tabData and self.tabData[self.tabIndex]

	if tabData == nil then
		return 0
	end

	if self.initSubType then
		for index, data in ipairs(tabData) do
			if data.subType == self.initSubType then
				self.initSubType = nil

				return index - 1
			end
		end

		self.initSubType = nil
	end

	return 0
end

function BadgeOverviewComponent:saveLookBadgeBoxIndex(idx)
	local tabData = self.tabData and self.tabData[self.tabIndex]
	local data = tabData and tabData[idx + 1]

	if data and data.subType then
		local tabInfo = self.listTab and self.listTab[self.tabIndex]

		BadgeUtils.setLastLookBadgeBoxSubType(tabInfo and tabInfo.tabType, data.subType)
	end
end

function BadgeOverviewComponent:initNeedPlayerUnlockVX()
	self.unlocks = {}

	for k, v in ipairs(self.tabData) do
		for m, item in ipairs(v) do
			for n, info in ipairs(item.suite) do
				local isNewUnlock = BadgeUtils.getBadgeObtainFromPrefs(info.badgeGroupId)

				if isNewUnlock then
					info._tmpIsNewUnlock = true
					info._tmpHasRedDot = true
					self.unlocks[k] = self.unlocks[k] or {}

					table.insert(self.unlocks[k], {
						tabIndex = k,
						badgeId = BadgeUtils.getLatestCompleteBadgeId(info.badgeGroupId),
						badgeGroupId = info.badgeGroupId,
						subType = item.subType,
						subIndex = m,
						suiteIndex = n
					})
				end
			end
		end
	end
end

function BadgeOverviewComponent:clickTabInner(button, index)
	if self.selectTab then
		self.selectTab.isSelected = false
	end

	self.selectTab = button
	button.isSelected = true

	self:changeTab(index + 1)
end

function BadgeOverviewComponent:changeTab(newTabIndex)
	if self.tabIndex ~= newTabIndex then
		self:refreshTabRedDot()
		self:_stopRouteStateTimer()

		if self.tabIndex then
			self.listTabUList:RefreshElement(self.tabIndex - 1)
		end

		self.oldTabIndex = self.tabIndex
		self.tabIndex = newTabIndex
		self.waitLoadingTabIndex = newTabIndex

		if self.initSubType == nil then
			local tabInfo = self.listTab and self.listTab[self.tabIndex]

			self.initSubType = self:getInitSubType(tabInfo and tabInfo.tabType)
		end

		self.routeList[self.tabIndex]:SetList(self.tabData[self.tabIndex])
	end
end

function BadgeOverviewComponent:refreshTabRedDot()
	if self.needDelete then
		for _, id in ipairs(self.needDelete) do
			BadgeUtils.deleteBadgeObtainFromPrefs(id)
		end

		table.clearArray(self.needDelete)
	end

	pg.global.refreshRedDotState(RedDotConst.RedDotPath.PLAYER_BADGE_TAB)
end

function BadgeOverviewComponent:tryPlayUnlockVx(tabIndex)
	if self.unlocks then
		local firstFind, findIndex = self:findNextToPlayUnlockVX(tabIndex)

		if firstFind then
			local data = table.remove(self.unlocks[tabIndex], findIndex)

			self:openUnlockVxUI(data)

			self.isInUnlockAnim = true

			table.insert(self.needDelete, data.badgeGroupId)

			self.lookBadgeGroupId = nil

			if #self.unlocks[tabIndex] == 0 then
				self.unlocks[tabIndex] = nil
			end

			if next(self.unlocks) == nil then
				self.unlocks = nil
			end

			return true
		end
	end

	self.isInUnlockAnim = false

	return false
end

function BadgeOverviewComponent:findNextToPlayUnlockVX(tabIndex)
	local unlockVx = self.unlocks[tabIndex]

	if unlockVx and #unlockVx > 0 then
		if self.lookBadgeGroupId then
			for i, v in ipairs(unlockVx) do
				if v.badgeGroupId == self.lookBadgeGroupId then
					return true, i
				end
			end

			return true, 1
		else
			return true, 1
		end
	end

	return false
end

function BadgeOverviewComponent:openUnlockVxUI(unlockData)
	local itemUIItem = self:tryGetBadgeUIItem(unlockData.subIndex, unlockData.suiteIndex)
	local objectReference = itemUIItem:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local size = iconUImage.sizeDelta

	self:onClickArrow(unlockData.subIndex - 1)

	local info = {
		unlockData = unlockData,
		closeCallback = function(data)
			self:onAfterUnlockVx(data)
		end,
		targetPosition = itemUIItem.position,
		targetSize = size
	}

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLAYER_BADGE_OBTAIN) then
		pg.global.ui.badgeObtain:setShowComponentInfo(info)
	elseif pg.global.ui:checkUIOpen(UIConst.UI_ID_PLAYER_BADGE_FIRST_UNLOCK) then
		pg.global.ui.badgeUnlockShow:onOpen(info)
	else
		pg.global.ui:open(UIConst.UI_ID_PLAYER_BADGE_FIRST_UNLOCK, info)
	end
end

function BadgeOverviewComponent:onAfterUnlockVx(data)
	local animLength = -1

	if self.tabIndex == data.tabIndex then
		self.routeList[self.tabIndex]:GoToIndex(data.subIndex - 1, true)
		self:setLookListIndex(data.subIndex - 1)

		local itemUIItem = self:tryGetBadgeUIItem(data.subIndex, data.suiteIndex)

		if itemUIItem then
			local suiteData = self:getBadgeInfoByUnlockData(data)

			if suiteData then
				suiteData._tmpIsNewUnlock = nil

				self:_renderOneBadgeByInfo(itemUIItem, suiteData)

				suiteData._tmpHasRedDot = nil
			end

			local animCmp = itemUIItem:GetComponent("Animation")

			if animCmp then
				animLength = UIUtils.GetAnimationClipLength(animCmp, badgeRefreshAnimation)

				animCmp:Play(badgeRefreshAnimation)
			end
		end
	end

	if animLength > 0 then
		self.unlockTimerId = self.ctrl:startTimer(function()
			self:playNextUnlock()
		end, animLength)
	else
		self:playNextUnlock()
	end
end

function BadgeOverviewComponent:getBadgeInfoByUnlockData(unlockData)
	local data = self.tabData[unlockData.tabIndex]

	if data then
		local item = data[unlockData.subIndex]

		if item then
			return item.suite[unlockData.suiteIndex]
		end
	end
end

function BadgeOverviewComponent:playNextUnlock()
	if self.unlocks then
		if self.unlocks[self.tabIndex] and #self.unlocks[self.tabIndex] > 0 then
			self:tryPlayUnlockVx(self.tabIndex)
		else
			local nextTabIndex, nextList = next(self.unlocks)
			local unlockInfo = nextList and nextList[1]

			if unlockInfo == nil then
				self.isInUnlockAnim = false

				return
			end

			self.initSubType = unlockInfo.subType or unlockInfo.subIndex

			local res, tabItem = self.listTabUList:TryGetChildAt(nextTabIndex - 1)

			if res then
				self:clickTabInner(tabItem, nextTabIndex - 1)
			end
		end
	else
		self.isInUnlockAnim = false
	end
end

function BadgeOverviewComponent:refreshTabRed(button, tabIndex)
	if self.unlocks and self.unlocks[tabIndex] then
		local hasNew = #self.unlocks[tabIndex] > 0

		pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PLAYER_BADGE_PATH_TAB, tabIndex), button, hasNew, RedDotConst.RedDotStyle.NEW)
	else
		pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PLAYER_BADGE_PATH_TAB, tabIndex), button, false, RedDotConst.RedDotStyle.NEW)
	end
end

function BadgeOverviewComponent:tryGetBadgeUIItem(subIndex, suiteIndex)
	local res, boxItem = self.routeList[self.tabIndex]:TryGetChildAt(subIndex - 1)

	if res then
		local objectReference = boxItem:GetComponent("ObjectReference")
		local containerUContainer = objectReference:GetRefValue("containerUContainer")

		if containerUContainer.content then
			local contentOC = containerUContainer.content:GetComponent("ObjectReference")
			local itemUI = contentOC:GetRefValue(string.format("item%sUButton", suiteIndex - 1))

			return itemUI
		end
	end
end

function BadgeOverviewComponent:_renderBadgeSuite(button, index, data, tabIndex)
	local objectReference = button:GetComponent("ObjectReference")
	local containerUContainer = objectReference:GetRefValue("containerUContainer")

	containerUContainer:SetUrlWithCallback(data.resPath, function(content)
		content.anchoredPosition = Vector2(0, 0)

		local sizeDelta = content.sizeDelta

		button.sizeDelta = sizeDelta

		self:_renderOneBox(content, index, data)

		if self.waitLoadingTabIndex and self.waitLoadingTabIndex == tabIndex then
			self.waitLoadingTabIndex = nil

			self:_refreshRouteState()
		end
	end)
end

function BadgeOverviewComponent:_refreshRouteState()
	self:_stopRouteStateTimer()

	self.routeStateTimeId = self.ctrl:startTimer(function()
		if self.tabIndex == nil then
			return
		end

		self.route[self.tabIndex]:SetActiveFastest(true)

		for k, route in ipairs(self.route) do
			if k ~= self.tabIndex then
				route:SetActiveFastest(false)
			end
		end

		self:onClickArrow(self:getInitLookIndex())
		self:tryPlayUnlockVx(self.tabIndex)
	end, 0.1)
end

function BadgeOverviewComponent:_stopRouteStateTimer()
	if self.routeStateTimeId then
		self.ctrl:killTimer(self.routeStateTimeId)

		self.routeStateTimeId = nil
	end
end

function BadgeOverviewComponent:_renderOneBox(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")
	local arkNameUSDFText = objectReference:GetRefValue("arkNameUSDFText")

	ClientTextUtils.setText(nameUSDFText, pg.getLocalizationText(data.subName))
	ClientTextUtils.setText(arkNameUSDFText, pg.getLocalizationText(data.subArkName))

	for k, info in ipairs(data.suite) do
		local itemUI = objectReference:GetRefValue(string.format("item%sUButton", info.resKey - 1))

		if itemUI then
			self:_renderOneBadgeByInfo(itemUI, info)
		end
	end

	if data.bigBadgeGroupId then
		local itemBigUI = objectReference:GetRefValue("itemBigUButton")

		if itemBigUI then
			self:_renderOneBadge(itemBigUI, data.bigBadgeId, data.bigBadgeState, data.bigBadgeGroupId, data.bigProcess, data.bigBadgeLevel)
		end
	end
end

function BadgeOverviewComponent:_renderOneBadgeByInfo(itemUI, info)
	self:_renderOneBadge(itemUI, info.badgeId, info.badgeState, info.badgeGroupId, info.process, info.level, info._tmpIsNewUnlock, info._tmpHasRedDot)
end

function BadgeOverviewComponent:_renderOneBadge(button, badgeId, badgeState, badgeGroupId, process, level, isNewUnlock, hasRedDot)
	if badgeState <= Const.BADGE_STATUS.Hide then
		button:SetActiveFastest(false)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local iconAddUImage = objectReference:GetRefValue("iconAddUImage")
	local iconLightUImage = objectReference:GetRefValue("iconLightUImage")
	local bgHoverUImage = objectReference:GetRefValue("bgHoverUImage")
	local fxHongUWidget = objectReference:GetRefValue("fxHongUWidget")

	button:SetActiveFastest(true)

	local urlPath
	local quality = 0
	local displayLevel = 1

	if level > 0 and badgeState == Const.BADGE_STATUS.Complete then
		displayLevel = level
		urlPath = BadgeUtils.getBadgeIcon(badgeGroupId, displayLevel)
		quality = BadgeUtils.getBadgeQuality(badgeGroupId, displayLevel)
	elseif level > 1 then
		displayLevel = level - 1
		urlPath = BadgeUtils.getBadgeIcon(badgeGroupId, displayLevel)
		quality = BadgeUtils.getBadgeQuality(badgeGroupId, displayLevel)
	end

	local bgUrl = BadgeUtils.getBadgeSlotIcon(badgeGroupId, displayLevel)

	bgUImage.url = bgUrl
	bgHoverUImage.url = bgUrl

	if not isNewUnlock then
		iconUImage.url = urlPath
		iconAddUImage.url = urlPath
		iconLightUImage.url = urlPath

		button:TryChangePage("Lock", urlPath and 0 or 1)

		if quality == BadgeUtils.RainBowQuality then
			iconUImage:SetMaterial(BadgeUtils.RainBowMatPath)
		else
			iconUImage.material = ""
		end

		if fxHongUWidget then
			fxHongUWidget:SetActive(quality == BadgeUtils.RainBowQuality)
		end

		if badgeState > Const.BADGE_STATUS.Hide then
			pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PLAYER_BADGE_ONE_BADGE, badgeId), button, hasRedDot == true, RedDotConst.RedDotStyle.NEW)
		end
	end

	function button.luaClick()
		if self.isInUnlockAnim == true then
			return
		end

		if BadgeUtils.badgeStateIsShow(badgeState) then
			pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PLAYER_BADGE_ONE_BADGE, badgeId), button, false, RedDotConst.RedDotStyle.NONE)
			pg.global.ui.badgeDetail:open({
				badgeGroupId = badgeGroupId
			})
		end
	end

	button.hoverSoundUrl = urlPath and "SFX_UI_BadgeSystem_BadgeTabHover_03" or "SFX_UI_BadgeSystem_BadgeTabHover_02"
end

function BadgeOverviewComponent:onListScroll(posX, idx)
	if self.tabIndex ~= idx then
		return
	end

	local count = #self.tabData[self.tabIndex]
	local index = math.floor(posX * (count - 1) + 0.5)
	local newIndex = math.clamp(index, 0, count - 1)

	self:setLookListIndex(newIndex)
	self:saveLookBadgeBoxIndex(newIndex)
end

function BadgeOverviewComponent:setLookListIndex(idx)
	self.curLookListIndex = idx

	self:refreshArrow()
end

function BadgeOverviewComponent:refreshArrow()
	local num = #self.tabData[self.tabIndex]

	self.btnLeftUButton:SetActiveFastest(self.curLookListIndex > 0)
	self.btnRightUButton:SetActiveFastest(self.curLookListIndex < num - 1)
end

function BadgeOverviewComponent:onClickArrow(idx)
	self:setLookListIndex(idx)
	self.routeList[self.tabIndex]:GoToIndex(idx, true)
	self:tryFocusBadgeBoxForGamepad(idx)
end

function BadgeOverviewComponent:tryFocusBadgeBoxForGamepad(boxIndex)
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if navMgr == nil then
		return
	end

	local target = self:tryGetFocusBox(boxIndex)

	if target then
		navMgr:FocusItem(target)
	end
end

function BadgeOverviewComponent:tryGetFocusBox(boxIndex)
	if self.tabIndex == nil or self.routeList[self.tabIndex] == nil then
		return
	end

	local res, boxItem = self.routeList[self.tabIndex]:TryGetChildAt(boxIndex)

	if not res or boxItem == nil then
		return
	end

	local objectReference = boxItem:GetComponent("ObjectReference")

	if objectReference == nil then
		return
	end

	local containerUContainer = objectReference:GetRefValue("containerUContainer")

	if containerUContainer == nil or containerUContainer.content == nil then
		return
	end

	local contentOC = containerUContainer.content:GetComponent("ObjectReference")

	if contentOC == nil then
		return
	end

	return contentOC:GetRefValue("itemBigUButton") or contentOC:GetRefValue("item0UButton")
end

function BadgeOverviewComponent:_onGamepadNavFocusMoved()
	if not pg.game.input or not pg.game.input:isUsingGamepad() then
		return
	end

	if self.tabIndex == nil or self.isInUnlockAnim == true then
		return
	end

	local navMgr = pg.global.navMgr

	if navMgr == nil then
		return
	end

	local focusedUContent = navMgr.CurrentFocusedUContent

	if focusedUContent == nil then
		return
	end

	local activeRouteList = self.routeList[self.tabIndex]

	if activeRouteList == nil then
		return
	end

	local boxIndex = self:_resolveBoxIndexFromFocused(focusedUContent, activeRouteList)

	if boxIndex == nil or boxIndex == self.curLookListIndex then
		return
	end

	self:onClickArrow(boxIndex)
end

function BadgeOverviewComponent:_resolveBoxIndexFromFocused(focusedUContent, activeRouteList)
	if focusedUContent == nil or activeRouteList == nil then
		return nil
	end

	local tabData = self.tabData and self.tabData[self.tabIndex]

	if tabData == nil then
		return nil
	end

	local focusedTransform = focusedUContent.transform

	if focusedTransform == nil then
		return nil
	end

	for i = 0, #tabData - 1 do
		local res, boxButton = activeRouteList:TryGetChildAt(i)

		if res and boxButton ~= nil then
			local boxTransform = boxButton.transform

			if boxTransform ~= nil then
				local cur = focusedTransform

				while cur ~= nil and cur ~= boxTransform do
					cur = cur.parent
				end

				if cur == boxTransform then
					return i
				end
			end
		end
	end

	return nil
end

return BadgeOverviewComponent
