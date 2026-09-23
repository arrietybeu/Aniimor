-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\GiftTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local Time = require("Core.Common.Time")
local GiftTipsItem = Class.LightClass("GiftTipsItem", BaseQueueItem)

function GiftTipsItem:onInit()
	self.uContainer = self.uWidget

	self:setMaxLimit(1)
end

function GiftTipsItem:pushData(data)
	self:enqueue(data)
end

function GiftTipsItem:onUpdate()
	if self:isTimelineSuspended() then
		return
	end

	self:tryPopupItem()

	local data = self.runList[1]

	if data and not data.removing and Time.realSecondCache >= data.endTime then
		self:onCountDownFinished(data)
	end
end

function GiftTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)

	data.recycleCloseCallback = nil
	data.endTime = Time.realSecondCache + (data.duration or 5)

	self:loadGiftTips(data)
end

function GiftTipsItem:loadGiftTips(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:initGiftView()
			self:refreshGiftTips(data)
		end))
	else
		self:initGiftView()
		self:refreshGiftTips(data)
	end
end

function GiftTipsItem:initGiftView()
	local objectReference = self.uContainer.content:GetComponent("ObjectReference")

	self.itemUButton = objectReference:GetRefValue("itemUButton")
	self.textDescUBaseText = objectReference:GetRefValue("textDescUBaseText")
	self.jumpUButton = objectReference:GetRefValue("jumpUButton")
	self.cdUCountDown = objectReference:GetRefValue("cdUCountDown")
	self.textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
	self.keyKeyBindingPro = objectReference:GetRefValue("keyKeyBindingPro")
	self.txtKeyTips = objectReference:GetRefValue("txtKeyTips")
	self.rootWidget = self.uContainer.content

	ClientTextUtils.setText(self.textTitleUBaseText, pg.getGameString("SHOP_GIFT_TIPS_TITLE"))
	ClientTextUtils.setText(self.txtKeyTips, pg.getGameString("SHOP_GIFT_CHECK"))
end

function GiftTipsItem:applyEnterKeyBinding()
	if IsNil(self.keyKeyBindingPro) then
		return
	end

	if pg.game.input:isUsingGamepad() then
		self.keyKeyBindingPro.actionPath = "Raw/GamepadStart"
		self.keyKeyBindingPro.priority = 100
	else
		self.keyKeyBindingPro.actionPath = "Hud/TipEnter"
		self.keyKeyBindingPro.priority = 10
	end
end

function GiftTipsItem:onInputDeviceChanged(deviceType)
	self:applyEnterKeyBinding()
end

function GiftTipsItem:refreshGiftTips(data)
	if IsNil(self.rootWidget) then
		return
	end

	self.keyKeyBindingPro.enabled = true
	self.keyKeyBindingPro.luaTrigger = self:guardRunCallback(data, function(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onJumpClick(data)
		end
	end, self.rootWidget)

	self:applyEnterKeyBinding()

	self.jumpUButton.luaClick = self:guardRunCallback(data, function()
		self:onJumpClick(data)
	end, self.rootWidget)
	self.cdUCountDown.luaFinished = self:guardRunCallback(data, function()
		self:onCountDownFinished(data)
	end, self.rootWidget)

	local itemId = data.id

	if itemId and not data.rechargeId then
		local replacedTable = ItemUtils.getReplacedItemCountTable(pg.me, {
			[itemId] = 1
		})

		itemId = replacedTable and next(replacedTable) or itemId
	end

	if itemId then
		LuaUIUtils.renderRewardItem(self.itemUButton, {
			id = itemId,
			num = data.num
		}, tostring(data.num or 1))
	end

	local giverName = data.giverName or ""
	local itemName = ""

	if itemId and ItemData[itemId] then
		itemName = pg.getLocalizationText(ItemData[itemId].itemName)
	end

	local formatStr = pg.getGameString("SHOP_GIFT_TIPS_DESC")

	ClientTextUtils.setText(self.textDescUBaseText, string.format(formatStr, giverName, itemName))

	local duration = data.duration or 5
	local now = self:isTimelineSuspended() and self.__timelineSuspendAt or Time.realSecondCache

	data.endTime = now + duration

	self.cdUCountDown:Play(duration)
	self.rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
	pg.game.audio:triggerEvent("SFX_SHOP_GET_GIFT")
end

function GiftTipsItem:onJumpClick(data)
	data = data or self.runList[1]

	if not data or data.removing or self:isTimelineSuspended() or not self:hasRecycleData(data) then
		return
	end

	pg.game.audio:triggerEvent("ui_sfx_button")

	data.recycleCloseCallback = data.jumpFunc

	self:requestRecycle(data, false, CS.XGUI.EInvokeTime.Custom1)
end

function GiftTipsItem:onCountDownFinished(data)
	data = data or self.runList[1]

	if not data or data.removing or self:isTimelineSuspended() or not self:hasRecycleData(data) then
		return
	end

	pg.game.audio:triggerEvent("ui_sfx_button")
	self:recycleToast(data)
end

function GiftTipsItem:closeTips(data)
	self:completeRecycle(data, true)
end

function GiftTipsItem:onClearRunningList()
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		self:closeTips(self.runList[i])
	end
end

function GiftTipsItem:removeByMailId(mailId)
	for i = #self.dataQueue, 1, -1 do
		if self.dataQueue[i].mail and self.dataQueue[i].mail.MailId == mailId then
			table.remove(self.dataQueue, i)
		end
	end

	for i = #self.runList, 1, -1 do
		local data = self.runList[i]

		if data.mail and data.mail.MailId == mailId then
			self:closeTips(data)
		end
	end

	self:refreshRunState()
end

function GiftTipsItem:hide()
	self:clearAllData(true)

	if NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self.rootWidget = nil
end

function GiftTipsItem:GMPushData(data)
	data.giverName = "测试玩家"
	data.id = 100003
	data.num = 1
	data.duration = 5
end

function GiftTipsItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Custom2)
end

function GiftTipsItem:onRecycleStarted(data, target)
	if IsNil(target) or self.rootWidget ~= target then
		return
	end

	self.keyKeyBindingPro.luaTrigger = nil
	self.keyKeyBindingPro.enabled = false
	self.jumpUButton.luaClick = nil
	self.cdUCountDown.luaFinished = nil

	self.cdUCountDown:Stop()
end

function GiftTipsItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleContainer(target, reason)

	if self.rootWidget == target and (IsNil(target) or self.uContainer.content ~= target) then
		self.rootWidget = nil
	end
end

function GiftTipsItem:onRecycleFinished(data, reason)
	local callback = data.recycleCloseCallback

	data.recycleCloseCallback = nil

	if callback and not self:isRecycleCancelled(reason) then
		callback()
	end
end

function GiftTipsItem:onTimelineResume(delta, suspendedAt)
	BaseQueueItem.onTimelineResume(self, delta, suspendedAt)

	local data = self.runList[1]

	if data and not data.removing and NotNil(self.rootWidget) and self.uContainer.content == self.rootWidget then
		local remaining = data.endTime - Time.realSecondCache

		if remaining > 0 then
			self.cdUCountDown:Play(remaining, data.duration or 5)
		end
	end
end

return GiftTipsItem
