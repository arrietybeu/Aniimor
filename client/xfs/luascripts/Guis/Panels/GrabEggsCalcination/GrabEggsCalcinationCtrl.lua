-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCalcination\\GrabEggsCalcinationCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsCalcinationCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsCalcinationCtrl = Class.LightClass("GrabEggsCalcinationCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local MessageName = require("Const.MessageName")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local RedDotConst = require("Const.RedDotConst")
local GrabEggsCalcinationRedDotUtils = require("Utils.GrabEggsCalcinationRedDotUtils")
local HotkeyConst = require("Const.HotkeyConst")
local DoTweenAnimMgr = DoTweenAnimMgr
local CALCINATION_TIMEOUT = 5
local CALCINATION_CURRENCY_ID = 1014
local RATING_VALUE_ANIMATION_DURATION = 0.3
local RATING_PROGRESS_ANIMATION_DURATION = 0.8
local CALCINATION_TRAIL_OUT_DURATION = 0.4
local CALCINATION_TAG_TOAST_DURATION = 3
local CALCINATION_TAG_TOAST_TEXT_KEY = "GRAB_EGG_CALCINATION_TAG_TOAST"
local CALCINATION_TAG_TOAST_DEFAULT_TEXT = "本次煅烧获得词条 {0}"
local CALCINATION_CONFIRM_TEXT_KEY = "GRAB_EGG_CALCINATION_CONFIRM"
local CALCINATION_CONFIRM_DEFAULT_TEXT = "确认"
local CALCINATION_COMPLETE_TEXT_KEY = "GRAB_EGG_CALCINATION_COMPLETE"
local CALCINATION_COMPLETE_DEFAULT_TEXT = "煅烧完成"
local CALCINATION_RAINBOW_TAG_LEVEL = 3
local CALCINATION_PERFORMANCE_DURATION = 2
local CALCINATION_PERFORMANCE_TRANSITION_DURATION = 0.5
local CALCINATION_PERFORMANCE_CAMERA_FOV_SCALE = 0.75
local CALCINATION_PERFORMANCE_UI_OFFSET_PADDING = 200
local CALCINATION_STRONG_PERFORMANCE_TAG_LEVEL = 2
local CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID = LuaUIUtils.TweenId("calcinationPerformanceLeftUI")
local CALCINATION_TAG_TOAST_NAME_STYLES = {
	[1] = "Q_4",
	[2] = "Q_5"
}

local function getGameStringOrDefault(key, defaultText)
	local text = pg.getGameString(key)

	if not text or text == "" or text == key or tonumber(text) then
		return defaultText
	end

	return text
end

GrabEggsCalcinationCtrl.messages = {
	[MessageName.GRAB_EGG_EQUIP_PROP] = {
		"onItemPropsChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onCurrencyChanged",
		true
	}
}

function GrabEggsCalcinationCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.retainedCompletedGenIDs = {}
	self.pendingCalcinationGenIDs = {}

	self:resetCalcinationState()
end

function GrabEggsCalcinationCtrl:resetCalcinationState()
	local calcinatingGenID = self.calcinatingGenID

	self:stopCalcinationTagTrail()
	self:stopCalcinationPerformance()

	if self.ratingStartFrameTimer then
		TimerManager.delFrameCb(self.ratingStartFrameTimer)

		self.ratingStartFrameTimer = nil
	end

	if self.calcinationResultFrameTimer then
		TimerManager.delFrameCb(self.calcinationResultFrameTimer)

		self.calcinationResultFrameTimer = nil
	end

	if self.calcinationTimeoutTimer then
		self:killTimer(self.calcinationTimeoutTimer)

		self.calcinationTimeoutTimer = nil
	end

	if self.ratingDelayTimer then
		self:killTimer(self.ratingDelayTimer)

		self.ratingDelayTimer = nil
	end

	if self.ratingProgressTimer then
		self:killTimer(self.ratingProgressTimer)

		self.ratingProgressTimer = nil
	end

	self:stopRatingValueAnimation()

	if calcinatingGenID and self.pendingCalcinationGenIDs then
		self.pendingCalcinationGenIDs[calcinatingGenID] = nil
	end

	self.isCalcinating = false
	self.isCalcinationAnimating = false
	self.oldRatingInfo = nil
	self.calcinatingGenID = nil
	self.calcinatingAffixNum = nil
end

function GrabEggsCalcinationCtrl:stopCalcinationPerformance()
	if self.calcinationPerformanceTimer then
		self:killTimer(self.calcinationPerformanceTimer)

		self.calcinationPerformanceTimer = nil
	end

	if self.calcinationPerformanceRestoreTimer then
		self:killTimer(self.calcinationPerformanceRestoreTimer)

		self.calcinationPerformanceRestoreTimer = nil
	end

	local performanceLeftRect = self.view and self.view.performanceLeftRectTransform or nil

	if NotNil(performanceLeftRect) then
		DoTweenAnimMgr.Kill(performanceLeftRect.gameObject, CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID, false)

		if self.calcinationPerformanceLeftPosition then
			performanceLeftRect.anchoredPosition = self.calcinationPerformanceLeftPosition
		end
	end

	local performanceRightRect = self.view and self.view.performanceRightRectTransform or nil

	if NotNil(performanceRightRect) and self.calcinationPerformanceRightWasActive ~= nil then
		performanceRightRect.gameObject:SetActiveEx(self.calcinationPerformanceRightWasActive)
	end

	local performanceTitleGameObject = self.view and self.view.performanceTitleGameObject or nil

	if NotNil(performanceTitleGameObject) and self.calcinationPerformanceTitleWasActive ~= nil then
		performanceTitleGameObject:SetActiveEx(self.calcinationPerformanceTitleWasActive)
	end

	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if scene and scene:isReady() then
		scene:stopCalcinationPerformance(0, true)
	end

	self.calcinationPerformanceActive = false
	self.calcinationPerformanceTimeElapsed = false
	self.calcinationPerformanceResultReady = false
	self.calcinationPerformanceGenID = nil
	self.calcinationPerformanceLeftPosition = nil
	self.calcinationPerformanceRightWasActive = nil
	self.calcinationPerformanceTitleWasActive = nil
end

function GrabEggsCalcinationCtrl:startCalcinationPerformance(genID)
	self:stopCalcinationPerformance()

	self.calcinationPerformanceActive = true
	self.calcinationPerformanceTimeElapsed = false
	self.calcinationPerformanceResultReady = false
	self.calcinationPerformanceGenID = genID

	local performanceLeftRect = self.view and self.view.performanceLeftRectTransform or nil

	if NotNil(performanceLeftRect) then
		local currentPosition = performanceLeftRect.anchoredPosition

		self.calcinationPerformanceLeftPosition = Vector2(currentPosition.x, currentPosition.y)

		local moveDistance = performanceLeftRect.rect.width + CALCINATION_PERFORMANCE_UI_OFFSET_PADDING

		DoTweenAnimMgr.Kill(performanceLeftRect.gameObject, CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID, false)
		DoTweenAnimMgr.AnchorPositionMove(performanceLeftRect, CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID, Vector3(currentPosition.x - moveDistance, currentPosition.y, 0), CALCINATION_PERFORMANCE_TRANSITION_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil)
	end

	local performanceRightRect = self.view and self.view.performanceRightRectTransform or nil

	if NotNil(performanceRightRect) then
		self.calcinationPerformanceRightWasActive = performanceRightRect.gameObject.activeSelf

		performanceRightRect.gameObject:SetActiveEx(false)
	end

	local performanceTitleGameObject = self.view and self.view.performanceTitleGameObject or nil

	if NotNil(performanceTitleGameObject) then
		self.calcinationPerformanceTitleWasActive = performanceTitleGameObject.activeSelf

		performanceTitleGameObject:SetActiveEx(false)
	end

	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if scene and scene:isReady() then
		scene:startCalcinationPerformance(CALCINATION_PERFORMANCE_CAMERA_FOV_SCALE, CALCINATION_PERFORMANCE_TRANSITION_DURATION)
	end

	local waitDuration = math.max(0, CALCINATION_PERFORMANCE_DURATION - CALCINATION_PERFORMANCE_TRANSITION_DURATION)

	self.calcinationPerformanceTimer = self:startTimer(function()
		self.calcinationPerformanceTimer = nil

		if not self.isCalcinating or self.calcinationPerformanceGenID ~= genID then
			return
		end

		self.calcinationPerformanceTimeElapsed = true

		self:tryFinishCalcinationPerformance()
	end, waitDuration)
end

function GrabEggsCalcinationCtrl:playCalcinationPerformanceEffect(tagData)
	local tagLevel = tagData and tagData.tagLevel or 0
	local isStrong = math.abs(tagLevel) >= CALCINATION_STRONG_PERFORMANCE_TAG_LEVEL
	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if scene and scene:isReady() then
		scene:playCalcinationPerformanceEffect(tagData, isStrong)
	end
end

function GrabEggsCalcinationCtrl:tryFinishCalcinationPerformance()
	if not self.isCalcinating or not self.calcinationPerformanceResultReady then
		return
	end

	if not self.calcinationPerformanceActive then
		local item = self.model:getItemByGenID(self.calcinatingGenID)

		if item then
			self:playRatingUpgradeAnimation(item)
		end

		return
	end

	if not self.calcinationPerformanceTimeElapsed or self.calcinationPerformanceRestoreTimer then
		return
	end

	local genID = self.calcinationPerformanceGenID
	local performanceLeftRect = self.view and self.view.performanceLeftRectTransform or nil

	if NotNil(performanceLeftRect) and self.calcinationPerformanceLeftPosition then
		DoTweenAnimMgr.Kill(performanceLeftRect.gameObject, CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID, false)
		DoTweenAnimMgr.AnchorPositionMove(performanceLeftRect, CALCINATION_PERFORMANCE_LEFT_UI_TWEEN_ID, Vector3(self.calcinationPerformanceLeftPosition.x, self.calcinationPerformanceLeftPosition.y, 0), CALCINATION_PERFORMANCE_TRANSITION_DURATION, 0, CS.DG.Tweening.Ease.__CastFrom(6), nil)
	end

	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if scene and scene:isReady() then
		scene:stopCalcinationPerformance(CALCINATION_PERFORMANCE_TRANSITION_DURATION, false)
	end

	self.calcinationPerformanceRestoreTimer = self:startTimer(function()
		self.calcinationPerformanceRestoreTimer = nil

		if not self.isCalcinating or self.calcinatingGenID ~= genID then
			return
		end

		if NotNil(performanceLeftRect) and self.calcinationPerformanceLeftPosition then
			performanceLeftRect.anchoredPosition = self.calcinationPerformanceLeftPosition
		end

		local performanceRightRect = self.view and self.view.performanceRightRectTransform or nil

		if NotNil(performanceRightRect) and self.calcinationPerformanceRightWasActive ~= nil then
			performanceRightRect.gameObject:SetActiveEx(self.calcinationPerformanceRightWasActive)
		end

		local performanceTitleGameObject = self.view and self.view.performanceTitleGameObject or nil

		if NotNil(performanceTitleGameObject) and self.calcinationPerformanceTitleWasActive ~= nil then
			performanceTitleGameObject:SetActiveEx(self.calcinationPerformanceTitleWasActive)
		end

		self.calcinationPerformanceActive = false
		self.calcinationPerformanceLeftPosition = nil
		self.calcinationPerformanceRightWasActive = nil
		self.calcinationPerformanceTitleWasActive = nil
		self.calcinationPerformanceGenID = nil

		local item = self.model:getItemByGenID(genID)

		if item then
			self:playRatingUpgradeAnimation(item)
		else
			self:resetCalcinationState()
			self:refreshSelectedItem()
			self:refreshItemList()
		end
	end, CALCINATION_PERFORMANCE_TRANSITION_DURATION)
end

function GrabEggsCalcinationCtrl:stopCalcinationTagTrail()
	if self.calcinationTrailHideTimer then
		self:killTimer(self.calcinationTrailHideTimer)

		self.calcinationTrailHideTimer = nil
	end

	local coinGeneral = self.calcinationTrailCoinGeneral

	self.calcinationTrailCoinGeneral = nil

	if NotNil(coinGeneral) then
		coinGeneral.luaEndFly = nil

		coinGeneral:StopCoin()
	end

	self:hideCalcinationTagTrailClones()
end

function GrabEggsCalcinationCtrl:scheduleCalcinationTagTrailHide()
	if self.calcinationTrailHideTimer then
		self:killTimer(self.calcinationTrailHideTimer)

		self.calcinationTrailHideTimer = nil
	end

	self.calcinationTrailHideTimer = self:startTimer(function()
		self.calcinationTrailHideTimer = nil

		self:hideCalcinationTagTrailClones()
	end, CALCINATION_TRAIL_OUT_DURATION)
end

function GrabEggsCalcinationCtrl:hideCalcinationTagTrailClones()
	local flyNode = self.view and self.view.flyNodeUWidget or nil

	if IsNil(flyNode) then
		return
	end

	local flyTransform = flyNode.transform

	for i = flyTransform.childCount - 1, 0, -1 do
		local child = flyTransform:GetChild(i)

		if NotNil(child) then
			child.gameObject:SetActiveEx(false)
		end
	end
end

function GrabEggsCalcinationCtrl:stopRatingValueAnimation()
	if self.ratingValueTimer then
		self:killTimer(self.ratingValueTimer)

		self.ratingValueTimer = nil
	end
end

function GrabEggsCalcinationCtrl:playCalcinationTagTrail(item, onComplete)
	self:stopCalcinationTagTrail()

	if not item or not self.view or IsNil(self.view.flyNodeUWidget) then
		return false
	end

	local tagIndex = self.model:getCalcinedNodeCount(item)
	local tagWidget = self.view.tagWidgets and self.view.tagWidgets[tagIndex]

	if IsNil(tagWidget) then
		return false
	end

	local objectReference = tagWidget:GetComponent("ObjectReference")
	local fxTrailUWidget = objectReference and objectReference:GetRefValue("fxTrailUWidget") or nil
	local coinGeneral = NotNil(fxTrailUWidget) and fxTrailUWidget:GetComponent("CoinGeneral") or nil

	if IsNil(coinGeneral) then
		return false
	end

	local flyTransform = self.view.flyNodeUWidget.transform

	coinGeneral.subParent = flyTransform
	coinGeneral.sourcePosition = fxTrailUWidget.transform.position
	coinGeneral.targetPosition = flyTransform.position
	self.calcinationTrailCoinGeneral = coinGeneral

	function coinGeneral.luaEndFly()
		coinGeneral.luaEndFly = nil

		if self.calcinationTrailCoinGeneral == coinGeneral then
			self.calcinationTrailCoinGeneral = nil
		end

		self:scheduleCalcinationTagTrailHide()

		if onComplete then
			onComplete()
		end
	end

	coinGeneral:PlayCoinSingle()

	return true
end

function GrabEggsCalcinationCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	self:bindCloseButton(self.view.btnBackUButton)

	function self.view.calcinationUButton.luaClick()
		self:onCalcineClick()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmCompletedItem()
	end

	if self.view.listCurrencyUList then
		function self.view.listCurrencyUList.luaRenderItem(button, index, data)
			self:renderCurrencyItem(button, index, data)
		end
	end
end

function GrabEggsCalcinationCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.initialGenID = info and info.genID or nil
end

function GrabEggsCalcinationCtrl:onShow()
	self:resetCalcinationState()

	self.retainedCompletedGenIDs = {}
	self.pendingCalcinationGenIDs = {}

	self.model:setSelectedGenID(nil)

	local initialGenID = self.initialGenID
	local initialItem = self.model:getItemByGenID(initialGenID)

	if initialItem and self.model:getRemainNodeCount(initialItem) > 0 then
		self.model:setSelectedGenID(initialGenID)

		self.initialScrollGenID = initialGenID
	else
		self.initialScrollGenID = nil
	end

	self.initialGenID = nil

	self:InitUI()
	self:refreshItemList()
	self:refreshSelectedItem()
	self:refreshSceneItemModel(self.model:getSelectedItem())
	self:markCalcinationItemsViewed()
end

function GrabEggsCalcinationCtrl:markCalcinationItemsViewed()
	GrabEggsCalcinationRedDotUtils.markCurrentItemsViewed()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_CALCINATION)
end

function GrabEggsCalcinationCtrl:onUISceneLoaded()
	UICtrl.onUISceneLoaded(self)
end

function GrabEggsCalcinationCtrl:InitUI()
	ClientTextUtils.setText(self.view.btnBackUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_TITLE"))
	ClientTextUtils.setText(self.view.emptyTextUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_EMPTY"))
	ClientTextUtils.setText(self.view.chooseItemtextUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_CHOOSE"))
	ClientTextUtils.setText(self.view.textLVTitleUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_RANK"))
	ClientTextUtils.setText(self.view.textValueUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_RANKVALUE"))
	ClientTextUtils.setText(self.view.CalcinationtextUSDFText, pg.getGameString("GRAB_EGG_CALCINATION_FORGE"))
	ClientTextUtils.setText(self.view.txtbtnComfirmNameUSDFText, getGameStringOrDefault(CALCINATION_CONFIRM_TEXT_KEY, CALCINATION_CONFIRM_DEFAULT_TEXT))
end

function GrabEggsCalcinationCtrl:getDisplayItems()
	return self.model:getCalcinableItems(self.retainedCompletedGenIDs)
end

function GrabEggsCalcinationCtrl:isRetainedCompletedItem(item)
	return item and self.retainedCompletedGenIDs[item.genID] and self.model:getRemainNodeCount(item) <= 0
end

function GrabEggsCalcinationCtrl:refreshItemList()
	local items = self:getDisplayItems()

	function self.view.forgItemlistUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end

	self.view.forgItemlistUList:SetList(items)

	local initialScrollGenID = self.initialScrollGenID

	self.initialScrollGenID = nil

	if initialScrollGenID then
		for index, data in ipairs(items) do
			if data.genID == initialScrollGenID then
				self.view.forgItemlistUList:GoToIndex(index - 1, true)

				break
			end
		end
	end

	local isEmpty = not items or #items == 0

	self.view.emptyTextUSDFText.gameObject:SetActiveEx(isEmpty)
	self.view.forgItemlistUList.gameObject:SetActiveEx(not isEmpty)
end

function GrabEggsCalcinationCtrl:renderCurrencyItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local countUText = objectReference:GetRefValue("countUText")

	if iconUImage then
		iconUImage.url = data.icon
	end

	if countUText then
		ClientTextUtils.setText(countUText, tostring(data.ownNum))
	end

	if data.quality then
		button:TryChangePage("Quality", data.quality)
	end
end

function GrabEggsCalcinationCtrl:refreshCalcineCost()
	local item = self.model:getSelectedItem()

	if self.view.listCurrencyUList then
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
			CALCINATION_CURRENCY_ID
		})
	end

	if not item then
		if self.view.textCostNumUSDFText then
			ClientTextUtils.setText(self.view.textCostNumUSDFText, "")
		end

		return
	end

	local costTable = self.model:getCalcineCost(item)

	if not costTable then
		return
	end

	if self.view.textCostNumUSDFText then
		local costNum = costTable[CALCINATION_CURRENCY_ID] or 0

		ClientTextUtils.setText(self.view.textCostNumUSDFText, tostring(costNum))
	end
end

function GrabEggsCalcinationCtrl:renderItem(uButton, index, data)
	if not data then
		return
	end

	local objectReference = uButton:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textCanCalcinationUSDFText = objectReference:GetRefValue("textCanCalcinationUSDFText")
	local itemGrabEggs96UWidget = objectReference:GetRefValue("itemGrabEggs96UWidget")

	LuaUIUtils.refreshGrabEggAntiqueTags(itemGrabEggs96UWidget, data)

	local itemCfg = ItemData[data.itemId]

	if txtNameUSDFText and itemCfg then
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(itemCfg.itemName))
	end

	local remainCount = self.model:getRemainNodeCount(data.packSlot)

	if textCanCalcinationUSDFText then
		local remainText

		if remainCount <= 0 then
			remainText = getGameStringOrDefault(CALCINATION_COMPLETE_TEXT_KEY, CALCINATION_COMPLETE_DEFAULT_TEXT)
		else
			remainText = string.format(pg.getGameString("GRAB_EGG_CALCINATION_CANFORGETIME"), remainCount)
		end

		ClientTextUtils.setText(textCanCalcinationUSDFText, remainText)
	end

	if itemGrabEggs96UWidget and itemCfg then
		local itemObjRef = itemGrabEggs96UWidget:GetComponent("ObjectReference")

		if itemObjRef then
			local itemIconUImage = itemObjRef:GetRefValue("itemIconUImage")

			if itemIconUImage then
				itemIconUImage.url = data.icon or itemCfg.icon
			end
		end

		if itemCfg.quality then
			itemGrabEggs96UWidget:TryChangePage("Quality", itemCfg.quality)
		end
	end

	local selectedGenID = self.model:getSelectedGenID()
	local isSelected = data.genID == selectedGenID

	uButton.isSelected = isSelected

	uButton:TryChangePage("State", isSelected and 1 or 0)

	function uButton.luaClick(isFromNavigation)
		if isFromNavigation then
			return
		end

		self:onSelectItem(data)
	end

	uButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
		if uButton.luaClick then
			uButton.luaClick()
		end

		return false
	end)
	uButton:SetHotkeyActiveOnlyInCurrentItem(true)
	uButton:SetHotkeyConsoleBar("CONSOLE_BAR_PUT", 0)
end

function GrabEggsCalcinationCtrl:refreshSceneItemModel(itemOrData, nextAffixData)
	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if not itemOrData then
		if scene and scene:isReady() then
			scene:hideCurrentModel()
		end

		return
	end

	local item = itemOrData.packSlot or itemOrData
	local itemId = item.id or item.itemId or itemOrData.itemId

	if not itemId then
		return
	end

	if scene and scene:isReady() then
		scene:showItemModel(itemId, item, nextAffixData)
	end
end

function GrabEggsCalcinationCtrl:onSelectItem(data)
	local selectedGenID = self.model:getSelectedGenID()

	if self.isCalcinating then
		if data and data.genID == selectedGenID then
			return
		end

		self:resetCalcinationState()
	end

	self.model:setSelectedGenID(data and data.genID)
	self:refreshSelectedItem()
	self:refreshItemList()
	self:refreshSceneItemModel(data)
end

function GrabEggsCalcinationCtrl:onItemPropsChanged(param)
	local invId = param and param[1]
	local genId = param and param[2]
	local isCalcinationItem = invId == self.model.CALCINE_INV_ID and genId ~= nil
	local changedItem = isCalcinationItem and self.model:getItemByGenID(genId) or nil
	local isCurrentRequest = self.isCalcinating and isCalcinationItem and genId == self.calcinatingGenID
	local hasCalcinationResult = isCurrentRequest and changedItem and self.model:getCalcinedNodeCount(changedItem) > (self.calcinatingAffixNum or 0)

	if hasCalcinationResult then
		self:scheduleCalcinationResult(genId)
	end

	if changedItem and self.model:getRemainNodeCount(changedItem) <= 0 and (hasCalcinationResult or self.model:getSelectedGenID() == genId) then
		self.retainedCompletedGenIDs[genId] = true
	end

	if not isCurrentRequest then
		local selectedItem = self.model:getSelectedItem()

		if selectedItem and selectedItem.genID == genId and isCalcinationItem then
			self:refreshSelectedItem()
			self:refreshSceneItemModel(selectedItem)
		end
	end

	self:refreshItemList()
end

function GrabEggsCalcinationCtrl:scheduleCalcinationResult(genID)
	if self.calcinationResultFrameTimer then
		TimerManager.delFrameCb(self.calcinationResultFrameTimer)

		self.calcinationResultFrameTimer = nil
	end

	self.calcinationResultFrameTimer = self:startFrameTimer(function()
		self.calcinationResultFrameTimer = nil

		self:tryHandleCalcinationResult(genID)
	end, 1)
end

function GrabEggsCalcinationCtrl:tryHandleCalcinationResult(genID)
	if not self.isCalcinating or self.isCalcinationAnimating or self.calcinatingGenID ~= genID then
		return
	end

	local item = self.model:getItemByGenID(genID)
	local affixNum = item and self.model:getCalcinedNodeCount(item) or 0
	local tags = item and self.model:getItemTags(item) or {}
	local newInfo = item and self.model:calcRatingInfo(item) or nil

	if affixNum <= (self.calcinatingAffixNum or 0) or affixNum > #tags or not newInfo or newInfo.level <= 0 then
		return
	end

	if self.calcinationTimeoutTimer then
		self:killTimer(self.calcinationTimeoutTimer)

		self.calcinationTimeoutTimer = nil
	end

	self.pendingCalcinationGenIDs[genID] = nil

	if self.model:getRemainNodeCount(item) <= 0 then
		self.retainedCompletedGenIDs[genID] = true
	end

	if self.oldRatingInfo then
		self.isCalcinationAnimating = true
		self.calcinationPerformanceResultReady = true

		local newTagIndex = (self.calcinatingAffixNum or 0) + 1

		self:playCalcinationPerformanceEffect(tags[newTagIndex])
		self:tryFinishCalcinationPerformance()
	else
		self:resetCalcinationState()
		self:refreshSelectedItem()
		self:refreshSceneItemModel(item)
	end
end

function GrabEggsCalcinationCtrl:onCurrencyChanged()
	self:refreshCalcineCost()
	self:refreshCalcineBtn()
end

function GrabEggsCalcinationCtrl:refreshSelectedItem()
	local item = self.model:getSelectedItem()
	local hasSelectedItem = item ~= nil
	local items = self:getDisplayItems()
	local hasItems = items and #items > 0
	local isCompleted = self:isRetainedCompletedItem(item)

	self.view.chooseItemtextUSDFText.gameObject:SetActiveEx(not hasSelectedItem)

	local stage = 0

	if isCompleted then
		stage = 4
	elseif hasItems then
		stage = hasSelectedItem and 2 or 1
	end

	if self.view.rootWidget then
		self.view.rootWidget:TryChangePage("Stage", stage)
	end

	self:refreshTags(item)
	self:refreshRating(item)
	self:refreshCalcineCost()
	self:refreshCalcineBtn()
end

function GrabEggsCalcinationCtrl:refreshTags(item)
	local tags = item and self.model:getItemTags(item) or {}

	for i, tagWidget in ipairs(self.view.tagWidgets) do
		local tagData = tags[i]

		if tagWidget then
			tagWidget.gameObject:SetActiveEx(tagData ~= nil)

			if tagData then
				local objectReference = tagWidget:GetComponent("ObjectReference")

				if objectReference then
					local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

					if txtNameUSDFText then
						ClientTextUtils.setText(txtNameUSDFText, tagData.tagName or "")
					end

					local tagIconUWidget = objectReference:GetRefValue("tagIconUWidget")
					local iconUImage = tagIconUWidget:GetComponent("ObjectReference"):GetRefValue("iconUImage")

					if iconUImage then
						iconUImage.url = tagData.tagIcon or ""
					end
				end

				tagWidget:TryChangePage("Level", tagData.tagLevel - 1)
			end
		end
	end
end

function GrabEggsCalcinationCtrl:refreshRating(item)
	local info = self.model:calcRatingInfo(item)
	local hasRating = info.level > 0

	if self.view.levelInfoUWidget then
		self.view.levelInfoUWidget.gameObject:SetActiveEx(hasRating)
	end

	if hasRating then
		self:setRatingLevel(info.level)
		ClientTextUtils.setText(self.view.textLVNameUSDFText, info.levelName or "")
		ClientTextUtils.setText(self.view.textValueRateNumUSDFText, string.format("x%s", info.valueRate or 1))

		self.displayedRatingValue = info.finalValue or 0

		ClientTextUtils.setText(self.view.textValueNumUSDFText, tostring(self.displayedRatingValue))

		if self.view.sliderUSlider then
			self.view.sliderUSlider.value = info.progress or 0
		end
	else
		self.displayedRatingValue = nil
	end
end

function GrabEggsCalcinationCtrl:setRatingLevel(level)
	if not level or level <= 0 then
		return
	end

	if self.view.levelInfoUWidget then
		self.view.levelInfoUWidget.gameObject:SetActiveEx(true)
		self.view.levelInfoUWidget:TryChangePage("Level", level - 1)
	end

	if self.view.rootWidget then
		self.view.rootWidget:TryChangePage("Level", level - 1)
	end
end

function GrabEggsCalcinationCtrl:showInitialRating(item)
	self:setRatingLevel(1)

	if self.view.sliderUSlider then
		self.view.sliderUSlider.value = 0
	end

	local RobEggCollectionCalcineRankData = require("Data.rob_egg_collection_calcine_rank_data")
	local rankCfg = RobEggCollectionCalcineRankData[1]

	if not rankCfg then
		return
	end

	ClientTextUtils.setText(self.view.textLVNameUSDFText, pg.getLocalizationText(rankCfg.rankName))
	ClientTextUtils.setText(self.view.textValueRateNumUSDFText, string.format("x%s", rankCfg.doubleMul or 1))

	local itemCfg = item and ItemData[item.id] or nil
	local baseValue = itemCfg and itemCfg.sellPrice or 0

	self.displayedRatingValue = math.ceil(baseValue * (rankCfg.doubleMul or 1))

	ClientTextUtils.setText(self.view.textValueNumUSDFText, tostring(self.displayedRatingValue))
end

function GrabEggsCalcinationCtrl:playRatingValueAnimation(targetValue, onComplete)
	self:stopRatingValueAnimation()

	targetValue = targetValue or 0

	local startValue = self.displayedRatingValue

	if startValue == nil then
		startValue = targetValue
	end

	if startValue == targetValue then
		self.displayedRatingValue = targetValue

		ClientTextUtils.setText(self.view.textValueNumUSDFText, tostring(targetValue))

		if onComplete then
			onComplete()
		end

		return
	end

	local elapsed = 0

	self.ratingValueTimer = self:startTimer(function()
		elapsed = elapsed + Time.unscaledDeltaTime

		local t = math.min(1, elapsed / RATING_VALUE_ANIMATION_DURATION)
		local value = startValue + (targetValue - startValue) * t

		value = targetValue >= startValue and math.floor(value) or math.ceil(value)
		self.displayedRatingValue = value

		ClientTextUtils.setText(self.view.textValueNumUSDFText, tostring(value))

		if t >= 1 then
			local timer = self.ratingValueTimer

			self.ratingValueTimer = nil

			if timer then
				self:killTimer(timer)
			end

			self.displayedRatingValue = targetValue

			ClientTextUtils.setText(self.view.textValueNumUSDFText, tostring(targetValue))

			if onComplete then
				onComplete()
			end
		end
	end, 0, true)
end

function GrabEggsCalcinationCtrl:applyFinalRatingInfo(newInfo)
	self:setRatingLevel(newInfo.level)
	ClientTextUtils.setText(self.view.textLVNameUSDFText, newInfo.levelName or "")
end

function GrabEggsCalcinationCtrl:showCalcinationTagToast(tagData)
	if not tagData or not tagData.tagLevel then
		return
	end

	if tagData.tagLevel >= CALCINATION_RAINBOW_TAG_LEVEL then
		self:showCalcinationRainbowTagToast(tagData)

		return
	end

	local style = CALCINATION_TAG_TOAST_NAME_STYLES[tagData.tagLevel]

	if not style then
		return
	end

	local styledTagName = string.format("<style=%s>%s</style>", style, tagData.tagName or "")
	local textTemplate = getGameStringOrDefault(CALCINATION_TAG_TOAST_TEXT_KEY, CALCINATION_TAG_TOAST_DEFAULT_TEXT)

	ClientUtils.showBubbleMessageRaw(pg.getFormatText(textTemplate, styledTagName), CALCINATION_TAG_TOAST_DURATION)
end

function GrabEggsCalcinationCtrl:showCalcinationRainbowTagToast(tagData)
	return
end

function GrabEggsCalcinationCtrl:playFinalRatingValueAnimation(item, newInfo)
	if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
		return
	end

	ClientTextUtils.setText(self.view.textValueRateNumUSDFText, string.format("x%s", newInfo.valueRate or 1))
	self:playRatingValueAnimation(newInfo.finalValue, function()
		if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
			return
		end

		self:onRatingAnimationComplete(item, newInfo)
	end)
end

function GrabEggsCalcinationCtrl:refreshCalcineBtn()
	local item = self.model:getSelectedItem()
	local hasCalcinationCount = item and self.model:getRemainNodeCount(item) > 0
	local canOperate = not self.isCalcinating and hasCalcinationCount

	self.view.calcinationUButton.interactable = canOperate and true or false
	self.view.calcinationUButton.visualInteractable = canOperate and self.model:isCalcineCostEnough(item) or false
end

function GrabEggsCalcinationCtrl:onCalcineClick()
	if self.isCalcinating then
		return
	end

	local item = self.model:getSelectedItem()

	if not item or not item.genID then
		self:resetCalcinationState()
		self:refreshSelectedItem()

		return
	end

	if self.model:getRemainNodeCount(item) <= 0 then
		return
	end

	if not self.model:isCalcineCostEnough(item) then
		LuaUIUtils.showItemNotEnough(CALCINATION_CURRENCY_ID)

		return
	end

	self.isCalcinating = true
	self.calcinatingGenID = item.genID
	self.calcinatingAffixNum = self.model:getCalcinedNodeCount(item)
	self.pendingCalcinationGenIDs[item.genID] = true
	self.oldRatingInfo = self.model:calcRatingInfo(item)

	local requestGenID = item.genID
	local requestAffixNum = self.calcinatingAffixNum

	self.calcinationTimeoutTimer = self:startTimer(function()
		self.calcinationTimeoutTimer = nil

		if self.isCalcinating and self.calcinatingGenID == requestGenID then
			logger:warn(string.format("[Calcination] request timeout, genID=%s", tostring(requestGenID)))

			local currentItem = self.model:getItemByGenID(requestGenID)

			if currentItem and self.model:getCalcinedNodeCount(currentItem) > requestAffixNum and self.oldRatingInfo then
				self:tryHandleCalcinationResult(requestGenID)

				if self.isCalcinationAnimating then
					return
				end
			end

			self:resetCalcinationState()
			self:refreshSelectedItem()
			self:refreshItemList()
		end
	end, CALCINATION_TIMEOUT)

	if self.view.rootWidget then
		self.view.rootWidget:TryChangePage("Stage", 3)
	end

	if self.oldRatingInfo.level <= 0 then
		self:showInitialRating(item)
	end

	self:refreshCalcineBtn()
	self:startCalcinationPerformance(requestGenID)

	local requested = self.model:requestCalcine(function(result, response)
		local failed = result == false or type(result) == "number" and result ~= NoticeDef.SUCCESS

		if failed and self.isCalcinating and self.calcinatingGenID == requestGenID then
			self.pendingCalcinationGenIDs[requestGenID] = nil

			self:resetCalcinationState()
			self:refreshSelectedItem()
			self:refreshItemList()
		end
	end)

	if not requested and self.isCalcinating and self.calcinatingGenID == requestGenID then
		self.pendingCalcinationGenIDs[requestGenID] = nil

		self:resetCalcinationState()
		self:refreshSelectedItem()
	end
end

function GrabEggsCalcinationCtrl:playRatingUpgradeAnimation(item)
	local oldInfo = self.oldRatingInfo
	local newInfo = self.model:calcRatingInfo(item)

	self:refreshTags(item)

	local tags = self.model:getItemTags(item)
	local newTagIndex = (self.calcinatingAffixNum or 0) + 1

	self:showCalcinationTagToast(tags[newTagIndex])

	local startLevel = oldInfo.level
	local startProgress = oldInfo.progress
	local isFirstRating = startLevel == 0 and newInfo.level > 0

	if isFirstRating then
		self:showInitialRating(item)

		startLevel = 1
		startProgress = 0
	end

	local function startAnimation()
		self.ratingStartFrameTimer = nil

		if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
			return
		end

		self:setRatingLevel(startLevel)

		local function beginProgressAnimation()
			if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
				return
			end

			self:playProgressAnimation(item, startLevel, startProgress, newInfo.level, newInfo.progress, newInfo, 0)
		end

		if not self:playCalcinationTagTrail(item, beginProgressAnimation) then
			beginProgressAnimation()
		end
	end

	if isFirstRating then
		self.ratingStartFrameTimer = self:startFrameTimer(startAnimation, 1)
	else
		startAnimation()
	end
end

function GrabEggsCalcinationCtrl:playProgressAnimation(item, currentLevel, currentProgress, targetLevel, targetProgress, newInfo, delay)
	local function startProgressAnimation()
		self.ratingDelayTimer = nil

		if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
			return
		end

		local isLevelUp = targetLevel > currentLevel

		local function runProgressPhase(fromProgress, toProgress, onComplete)
			local elapsed = 0
			local isFirstProgressFrame = true

			if self.view.sliderUSlider then
				self.view.sliderUSlider.value = fromProgress
			end

			self.ratingProgressTimer = self:startTimer(function()
				if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
					if self.ratingProgressTimer then
						self:killTimer(self.ratingProgressTimer)

						self.ratingProgressTimer = nil
					end

					return
				end

				if isFirstProgressFrame then
					isFirstProgressFrame = false

					return
				end

				elapsed = elapsed + Time.unscaledDeltaTime

				local t = math.min(1, elapsed / RATING_PROGRESS_ANIMATION_DURATION)
				local progress = fromProgress + (toProgress - fromProgress) * t

				if self.view.sliderUSlider then
					self.view.sliderUSlider.value = progress
				end

				if t >= 1 then
					local timer = self.ratingProgressTimer

					self.ratingProgressTimer = nil

					if timer then
						self:killTimer(timer)
					end

					onComplete()
				end
			end, 0, true)
		end

		if isLevelUp then
			runProgressPhase(currentProgress, 1, function()
				if not self.isCalcinating or self.calcinatingGenID ~= item.genID then
					return
				end

				self:applyFinalRatingInfo(newInfo)
				runProgressPhase(0, targetProgress, function()
					self:playFinalRatingValueAnimation(item, newInfo)
				end)
			end)
		else
			self:applyFinalRatingInfo(newInfo)
			runProgressPhase(currentProgress, targetProgress, function()
				self:playFinalRatingValueAnimation(item, newInfo)
			end)
		end
	end

	if delay and delay > 0 then
		self.ratingDelayTimer = self:startTimer(startProgressAnimation, delay)
	else
		startProgressAnimation()
	end
end

function GrabEggsCalcinationCtrl:onRatingAnimationComplete(item, newInfo)
	self:resetCalcinationState()
	self:refreshSelectedItem()
	self:refreshSceneItemModel(item)
	self:refreshItemList()
end

function GrabEggsCalcinationCtrl:onConfirmCompletedItem()
	local genID = self.model:getSelectedGenID()

	if not genID or not self.retainedCompletedGenIDs[genID] then
		return
	end

	local item = self.model:getSelectedItem()
	local scene = pg.game.uiScene:getScene(UISceneConst.CALCINATION_SCENE)

	if scene and scene:isReady() then
		if item and item.id then
			scene:removeEntity(item.id)
		else
			scene:hideCurrentModel()
		end
	end

	self.retainedCompletedGenIDs[genID] = nil
	self.pendingCalcinationGenIDs[genID] = nil

	self.model:setSelectedGenID(nil)
	self:refreshItemList()
	self:refreshSelectedItem()
end

function GrabEggsCalcinationCtrl:onDestroy()
	self:resetCalcinationState()
	UICtrl.onDestroy(self)
end

return GrabEggsCalcinationCtrl
