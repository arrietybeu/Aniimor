-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\QuickUseItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemData = require("Data.item_data")
local ItemEffectData = require("Data.item_effect_data")
local PropDetailUseAction = require("Guis.Panels.Inventory.Helper.PropDetailUseAction")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local QuickUseItem = Class.LightClass("QuickUseItem", BaseQueueItem)
local MAX_TOTAL = 6
local ACTION_USE = "Hud/TipEnter"
local ACTION_CLOSE = "Hud/ItemClose"
local KEY_HINT_SPACING = 100
local RAINBOW_QUALITY = 5

local function getLocalizedText(key)
	local value = pg.getGameString(key)

	if type(value) ~= "string" then
		return ""
	end

	return value
end

function QuickUseItem:onInit()
	self:setMaxLimit(MAX_TOTAL)

	self.uContainer = self.uWidget
	self.scrollList = nil
	self.showList = {}
	self._contentReady = false
	self._loading = false
	self._usingData = nil
end

function QuickUseItem:isReachTheLimit()
	return #self.showList + #self.dataQueue >= MAX_TOTAL
end

function QuickUseItem:getDisplayCount()
	return math.min(#self.showList + #self.dataQueue, MAX_TOTAL)
end

function QuickUseItem:getOccupiedHeight()
	if self:getDisplayCount() <= 0 or IsNil(self.scrollList) then
		return 0
	end

	local ok, height = pcall(function()
		return self.scrollList:GetPreferredHeight()
	end)

	if not ok or type(height) ~= "number" then
		return 0
	end

	return math.max(0, height)
end

function QuickUseItem:getLastItemBottomWorldPosition()
	if IsNil(self.scrollList) or #self.showList <= 0 then
		return nil
	end

	local rectTransform = self.scrollList.rectTransform

	if IsNil(rectTransform) or rectTransform.rect == nil then
		return nil
	end

	local occupiedHeight = self:getOccupiedHeight()

	if occupiedHeight <= 0 then
		return nil
	end

	local bottomY = rectTransform.rect.yMax - occupiedHeight - KEY_HINT_SPACING

	return rectTransform:TransformPoint(CS.UnityEngine.Vector3(0, bottomY, 0))
end

function QuickUseItem:pushData(data)
	if self:mergeIfExists(data) then
		return
	end

	while #self.showList + #self.dataQueue >= MAX_TOTAL do
		local recycleData

		recycleData = self.showList[1]

		if recycleData ~= nil then
			self:recycle(recycleData)
		else
			table.remove(self.dataQueue, 1)
		end
	end

	data.mergeNum = 0

	self:enqueue(data)
end

function QuickUseItem:mergeIfExists(data)
	for i, v in ipairs(self.showList) do
		if v.id == data.id and not v.removing and not v.using then
			v.mergeNum = (v.mergeNum or 0) + (data.num or 0)

			table.remove(self.showList, i)
			table.insert(self.showList, v)
			self:refreshView()

			return true
		end
	end

	for i, v in ipairs(self.dataQueue) do
		if v.id == data.id then
			v.mergeNum = (v.mergeNum or 0) + (data.num or 0)

			table.remove(self.dataQueue, i)
			table.insert(self.dataQueue, v)

			return true
		end
	end

	return false
end

function QuickUseItem:onUpdate()
	self:tryPopupItem()
end

function QuickUseItem:tryPopupItem()
	if self:isQueueEmpty() and #self.showList <= 0 then
		return
	end

	if IsNil(self.uContainer) then
		return
	end

	if not self.uContainer:CheckURLLoaded() then
		if not self._loading then
			self._loading = true

			self.uContainer:LoadDefaultUrlManually(function()
				self._loading = false

				if IsNil(self.uContainer) or IsNil(self.uContainer.content) then
					self._contentReady = false

					return
				end

				self._contentReady = true

				self:onContentLoaded()
				self:refreshView()
				self:drainQueue()
			end)
		end

		return
	end

	if not self._contentReady then
		self._contentReady = true

		self:onContentLoaded()
		self:refreshView()
	end

	self:drainQueue()
end

function QuickUseItem:_destroyInteractiveContent()
	if IsNil(self.uContainer) then
		return
	end

	self.uContainer:DestroyContent()

	self.scrollList = nil
	self._contentReady = false
	self._loading = false
end

function QuickUseItem:onContentLoaded()
	local content = self.uContainer.content

	if IsNil(content) then
		return
	end

	self.scrollList = content:GetComponent("UList") or content:GetComponent("UScrollList")

	if IsNil(self.scrollList) and content.gameObject then
		self.scrollList = content.gameObject:GetComponent("UList") or content.gameObject:GetComponent("UScrollList")
	end

	if NotNil(self.scrollList) then
		function self.scrollList.luaRenderItem(item, _, data)
			self:renderItem(item, data)
		end
	end
end

function QuickUseItem:drainQueue()
	if self._usingData ~= nil or self:isAreaHidden() or not self.owner.visible or self.owner.isWaitingOpenFullScreen then
		return
	end

	local changed = false

	while not self:isQueueEmpty() and #self.showList < MAX_TOTAL do
		local data = self:dequeue()
		local available = ItemUtils.getItemCountById(pg.me, data.id, true)

		for _, shown in ipairs(self.showList) do
			if shown.id == data.id then
				available = available - (shown.num or 0) - (shown.mergeNum or 0)
			end
		end

		data.num = math.min((data.num or 0) + (data.mergeNum or 0), available)
		data.mergeNum = 0

		if data.num > 0 then
			self:addRunItem(data)
			table.insert(self.showList, data)

			changed = true
		end
	end

	if changed then
		self:refreshView()
		pg.game.audio:triggerEvent("ui_sfx_getitem")
	end

	if #self.showList == 0 and self:isQueueEmpty() then
		self:refreshRunState()
		self:clearRunningList(true)
	end
end

function QuickUseItem:refreshView()
	if NotNil(self.scrollList) then
		self.scrollList:SetList(self.showList)
	end
end

function QuickUseItem:isInteractiveItem(data)
	return self._usingData == nil and data ~= nil and data == self.showList[#self.showList]
end

function QuickUseItem:renderItem(item, data)
	if IsNil(item) or data == nil then
		return
	end

	local cData = ItemData[data.id]

	if cData == nil then
		return
	end

	local root = item.transform or item
	local objectReference = root:GetComponent("ObjectReference")

	if IsNil(objectReference) then
		return
	end

	local qualityWidget = root.gameObject and root.gameObject:GetComponent("UWidget")
	local eventWidget = qualityWidget or item
	local qualityPage = cData.quality >= RAINBOW_QUALITY and RAINBOW_QUALITY or cData.quality

	if NotNil(qualityWidget) then
		qualityWidget:TryChangePage("Quality", qualityPage)
	elseif item.TryChangePage then
		item:TryChangePage("Quality", qualityPage)
	end

	if qualityPage == RAINBOW_QUALITY then
		local qualityDec = objectReference:GetRefValue("qualityDecTransform")

		if NotNil(qualityDec) then
			qualityDec.gameObject:SetActiveEx(true)
		end
	end

	local nameStr = pg.getLocalizationText(cData.itemName)
	local nameText = objectReference:GetRefValue("itemNameUText")

	if NotNil(nameText) then
		nameText.gameObject:SetActiveEx(true)
		ClientTextUtils.setText(nameText, nameStr)

		nameText.color = CS.UnityEngine.Color.white
	end

	local nameEffect = objectReference:GetRefValue("nameEffectTransform")

	if NotNil(nameEffect) then
		nameEffect.gameObject:SetActiveEx(false)
	end

	local iconImage = objectReference:GetRefValue("itemIconUImage")

	if NotNil(iconImage) then
		iconImage.url = LuaUIUtils.getIconByIconId(cData.icon)
	end

	local numTxt = objectReference:GetRefValue("itemNumUText")

	if NotNil(numTxt) then
		local num = (data.num or 0) + (data.mergeNum or 0)

		ClientTextUtils.setText(numTxt, num > 0 and string.format("x%d", num) or "")
	end

	local useLabel = getLocalizedText("USE")
	local useTxt = objectReference:GetRefValue("useLabelUText")

	if NotNil(useTxt) then
		ClientTextUtils.setText(useTxt, useLabel)
	end

	local interactive = self:isInteractiveItem(data)
	local useButton = self:_bindBtn(objectReference:GetRefValue("useUButton"), ACTION_USE, function()
		self:useItem(data, eventWidget)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end, interactive)

	self:_bindBtn(objectReference:GetRefValue("closeUButton"), ACTION_CLOSE, function()
		self:closeItem(data)
		pg.game.audio:triggerEvent("ui_sfx_button")
	end, interactive)
	self:_refreshDevicePresentation(objectReference:GetRefValue("closeVisualTransform"))
	self:_setupKeyHintList(objectReference:GetRefValue("keyHintUList"), interactive, useButton, useLabel)

	if data.replayInAnimation then
		data.replayInAnimation = nil

		self:_replayItemInAnimation(eventWidget)
	end

	if not data._quickUseRumblePlayed then
		data._quickUseRumblePlayed = true

		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
	end

	pg.game.audio:playEvent("SFX_UI_HudRecommendedProps")
end

function QuickUseItem:_setupKeyHintList(keyHintList, visible, useButton, useLabel)
	if IsNil(keyHintList) then
		return
	end

	function keyHintList.luaRenderItem(button, index, rowData)
		self:renderKeyHint(button, index, rowData)
	end

	if not visible then
		keyHintList:SetList({})

		return
	end

	local closeLabel = getLocalizedText("CLOSE")
	local data = {
		{
			path = ACTION_CLOSE,
			label = closeLabel
		},
		{
			path = ACTION_USE,
			label = useLabel,
			hotKeyObject = useButton and useButton.gameObject or nil,
			longPressFunc = useButton and function()
				if useButton.luaClick then
					useButton.luaClick()
				end
			end or nil
		}
	}

	keyHintList:SetList(data)
end

function QuickUseItem:renderKeyHint(button, _, data)
	if not button or not data then
		return
	end

	local tr = button.transform or button

	if not tr then
		return
	end

	local objectReference = tr:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	if NotNil(keyHotKeyContent) then
		pcall(function()
			keyHotKeyContent:SetHotKeyPaths(data.path)
		end)
	end

	local btnTipsUText = objectReference:GetRefValue("btnTipsUText")

	if NotNil(btnTipsUText) then
		ClientTextUtils.setText(btnTipsUText, data.label or "")
	end

	self:bindHotKeyItemLongPress(objectReference, data)
end

function QuickUseItem:_refreshDevicePresentation(closeVisual)
	if IsNil(closeVisual) then
		return
	end

	local isGamepad = false

	if pg and pg.game and pg.game.input then
		pcall(function()
			isGamepad = pg.game.input:isUsingGamepad() == true
		end)
	end

	closeVisual.gameObject:SetActiveEx(not isGamepad)
end

function QuickUseItem:onInputDeviceChanged()
	BaseQueueItem.onInputDeviceChanged(self)
	self:refreshView()
end

function QuickUseItem:_bindBtn(ub, actionPath, fn, enableHotKey)
	if IsNil(ub) then
		return
	end

	function ub.luaClick()
		fn()

		return false
	end

	if enableHotKey then
		ub:SetPCAction(actionPath)

		if actionPath == ACTION_USE then
			ub:RemoveLuaGamepadHotkey()
			self:clearHotKeyBindByPath(ub.gameObject, actionPath)
		else
			ub:SetGamepadAction(actionPath)
		end
	else
		ub:RemoveLuaGamepadHotkey()
		self:clearHotKeyBindByPath(ub.gameObject, actionPath)
	end

	return ub
end

function QuickUseItem:_replayItemInAnimation(eventWidget)
	if IsNil(eventWidget) then
		return
	end

	local transitionAnimation = eventWidget.transitionAnimation

	if IsNil(transitionAnimation) and NotNil(eventWidget.gameObject) then
		transitionAnimation = eventWidget.gameObject:GetComponent("Animation")
	end

	if IsNil(transitionAnimation) then
		return
	end

	transitionAnimation:Stop()
	UIUtils.PlayAnimation(transitionAnimation, "VX_Node_Hud_Recommended_Props_In")
end

function QuickUseItem:_removeEmptyUseAnimationEvent(eventWidget)
	if IsNil(eventWidget) then
		return
	end

	local transitionAnimation = eventWidget.transitionAnimation

	if IsNil(transitionAnimation) and NotNil(eventWidget.gameObject) then
		transitionAnimation = eventWidget.gameObject:GetComponent("Animation")
	end

	if IsNil(transitionAnimation) then
		return
	end

	local useAnimation = transitionAnimation:GetClip("VX_Node_Hud_Recommended_Props_Use")

	if IsNil(useAnimation) then
		return
	end

	local eventsProperty = useAnimation:GetType():GetProperty("events")

	if IsNil(eventsProperty) then
		return
	end

	local animationEvents = eventsProperty:GetValue(useAnimation, nil)

	if animationEvents == nil or animationEvents.Length ~= 1 then
		return
	end

	local functionName = animationEvents[0].functionName

	if functionName ~= nil and functionName ~= "" then
		return
	end

	local emptyEvents = CS.System.Array.CreateInstance(typeof(CS.UnityEngine.AnimationEvent), 0)

	eventsProperty:SetValue(useAnimation, emptyEvents, nil)
end

function QuickUseItem:useItem(data, eventWidget)
	if self._usingData ~= nil or not data or data.removing or data.using then
		return
	end

	local itemNum = (data.num or 0) + (data.mergeNum or 0)

	if itemNum <= 0 then
		return
	end

	local effectData = ItemEffectData[data.id]
	local canUseAll = effectData ~= nil and effectData.canUseAll == 1
	local useNum = canUseAll and itemNum or 1
	local useItemInnerCalled = false

	PropDetailUseAction.execute({
		itemId = data.id
	}, {
		useItemInner = function()
			useItemInnerCalled = true
		end
	}, {
		hideHudOnOpenUI = true
	})

	if not useItemInnerCalled then
		local remaining = itemNum - useNum

		if remaining <= 0 then
			self:recycle(data)
		else
			data.num = remaining
			data.mergeNum = 0

			self:refreshView()
		end

		return
	end

	data.using = true
	data.batchCancelled = false
	self._usingData = data

	local shouldReplayInAnimation = false

	local function finishUse()
		if data.removing then
			return
		end

		data.using = false

		if self._usingData == data then
			self._usingData = nil
		end

		if shouldReplayInAnimation then
			data.replayInAnimation = true
		end

		self:refreshView()
	end

	local requestSent = false

	local function sendUseRequest()
		if requestSent or self._usingData ~= data or data.batchCancelled or data.removing then
			return
		end

		requestSent = true

		LuaMsgUtils.useItemById(data.id, useNum, {}, function()
			if self._usingData ~= data or data.batchCancelled or data.removing then
				return
			end

			local remaining = itemNum - useNum

			if remaining <= 0 then
				self:recycle(data)

				return
			end

			data.num = remaining
			data.mergeNum = 0

			finishUse()
		end, function()
			finishUse()
		end)
	end

	if effectData ~= nil and NotNil(eventWidget) and eventWidget.CheckHasEvent and eventWidget.InvokeCallbackWithCallback and eventWidget:CheckHasEvent(CS.XGUI.EInvokeTime.Custom1) then
		shouldReplayInAnimation = true

		ClientUtils.tryWithLogError(function()
			self:_removeEmptyUseAnimationEvent(eventWidget)
		end)
		eventWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, sendUseRequest)
	else
		sendUseRequest()
	end
end

function QuickUseItem:closeItem(data)
	self:recycle(data)
end

function QuickUseItem:recycle(data)
	if not data or data.removing then
		return
	end

	data.batchCancelled = true
	data.removing = true

	if self._usingData == data then
		self._usingData = nil
	end

	for i, v in ipairs(self.showList) do
		if v == data then
			table.remove(self.showList, i)

			break
		end
	end

	self:removeItem(data)

	if #self.showList > 0 then
		self:refreshView()
	elseif self:isQueueEmpty() and not IsNil(self.uContainer) then
		self:_destroyInteractiveContent()
	end
end

function QuickUseItem:setAreaHideFlag(flag, isHide)
	BaseQueueItem.setAreaHideFlag(self, flag, isHide)

	if not self:isAreaHidden() then
		self._preservingObtainQueue = nil
	end

	if isHide and flag == TipAreaConst.UITipAreaFlag.AreaFlag_CustomAreaShow and table.contains(self.owner.hideFlags, TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen) then
		self:onUIVisibleToHide()
	end
end

function QuickUseItem:shouldPreserveObtainQueue()
	local ui = pg.global.ui
	local uid = UIConst.UI_ID_COMMON_OBTAIN
	local obtain = ui.ctrlDict and ui.ctrlDict[uid]
	local presenting = ui:checkUIOpen(uid) or ui.waitLoadingUI[uid] or ui.pendingDestroyUI[uid] or obtain and obtain._pendingQueue and #obtain._pendingQueue > 0

	if not presenting and not self._preservingObtainQueue then
		return false
	end

	local hiddenAreas, forced, fullScreen = ui:getHideTipAreas(uid)

	if forced or fullScreen or hiddenAreas[TipAreaConst.AREAS.C] then
		return false
	end

	for waitingUID in pairs(ui.waitLoadingUI) do
		if waitingUID ~= uid then
			local hide = ui:getHideTipByUID(waitingUID)

			if hide.force or hide.fullScreen or hide.tips[TipAreaConst.AREAS.C] then
				return false
			end
		end
	end

	return true
end

function QuickUseItem:onUIVisibleToHide()
	if self:shouldPreserveObtainQueue() then
		self._preservingObtainQueue = true

		return
	end

	self._preservingObtainQueue = nil

	self:clearRunningList(true)
end

function QuickUseItem:onClearRunningList(force)
	self._usingData = nil

	for i = #self.showList, 1, -1 do
		local d = self.showList[i]

		d.batchCancelled = true
		d.removing = true

		self:removeItem(d)
	end

	self.showList = {}

	if not IsNil(self.uContainer) then
		self:_destroyInteractiveContent()
	end
end

function QuickUseItem:GMPushData(data)
	data.id = data.id or 7008
	data.num = data.num or 1
end

return QuickUseItem
