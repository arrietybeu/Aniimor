-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\ScreenCaptureShareItem.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ScreenCaptureShareItem = Class.LightClass("ScreenCaptureShareItem", BaseQueueItem)

function ScreenCaptureShareItem:onInit()
	self.uContainer = self.uWidget
	self.isContainerLoading = false
	self.isDestroyed = false
end

function ScreenCaptureShareItem:pushData(data)
	local now = Time.realSecondCache
	local runningData = self:firstRunItem()

	if runningData ~= nil then
		self:refreshRunningScreenshot(runningData, data, now)

		return
	end

	self:enqueueScreenshot(data)
end

function ScreenCaptureShareItem:refreshRunningScreenshot(runningData, data, now)
	runningData.sprite = data.sprite
	runningData.imageShareConfig = data.imageShareConfig
	runningData.endTime = now + data.imageShareConfig.stayTime

	if not self.uContainer:CheckURLLoaded() then
		return
	end

	self:renderItem(self.uContainer.content, runningData)
end

function ScreenCaptureShareItem:enqueueScreenshot(data)
	table.clearArray(self.dataQueue)
	self:enqueue(data)
end

function ScreenCaptureShareItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ScreenCaptureShareItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + data.imageShareConfig.stayTime

	self:addRunItem(data)
	self:loadContent(data)
end

function ScreenCaptureShareItem:loadContent(data)
	if self.uContainer:CheckURLLoaded() then
		self:renderItem(self.uContainer.content, data)

		return
	end

	if self.isContainerLoading then
		return
	end

	self.isContainerLoading = true

	local uContainer = self.uContainer

	local function onContentLoaded(content)
		self.isContainerLoading = false

		if self.isDestroyed or self.uContainer ~= uContainer then
			uContainer:DestroyContent()

			return
		end

		if IsNil(content) or self:firstRunItem() ~= data or data.removing then
			return
		end

		self:renderItem(content, data)
	end

	uContainer:LoadDefaultUrlManually(onContentLoaded)
end

function ScreenCaptureShareItem:renderItem(content, data)
	local objectReference = content:GetComponent("ObjectReference")
	local btnShareUButton = objectReference:GetRefValue("btnShareUButton")
	local photoUImage = objectReference:GetRefValue("photoUImage")

	photoUImage.sprite = data.sprite

	local function onClick()
		self:onShareClick(data)
	end

	content.luaClick = onClick
	btnShareUButton.luaClick = onClick
end

function ScreenCaptureShareItem:refreshRemainTime()
	local data = self:firstRunItem()

	if data == nil or Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ScreenCaptureShareItem:onShareClick(data)
	pg.game.audio:triggerEvent("ui_sfx_button")

	local tipsCtrl = self.owner.owner.ctrl

	if data.removing or tipsCtrl.screenCaptureShareComponent:isCapturePending() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HUD_SCREENSHOT_SHARING, {
		sprite = data.sprite
	})
	self:recycleToast(data)
end

function ScreenCaptureShareItem:recycleToast(data)
	if data.removing then
		return
	end

	data.removing = true
	self.isContainerLoading = false

	self.uContainer:DestroyContent()
	self:removeItem(data)
end

function ScreenCaptureShareItem:onClearRunningList()
	for i = #self.runList, 1, -1 do
		self:recycleToast(self.runList[i])
	end
end

function ScreenCaptureShareItem:onDestroy()
	self.isDestroyed = true

	BaseQueueItem.onDestroy(self)

	if NotNil(self.uContainer) then
		self.uContainer:DestroyContent()
	end

	self.uContainer = nil
end

return ScreenCaptureShareItem
