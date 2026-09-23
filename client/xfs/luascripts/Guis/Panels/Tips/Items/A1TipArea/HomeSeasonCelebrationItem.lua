-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\HomeSeasonCelebrationItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local HotkeyConst = require("Const.HotkeyConst")
local HomeSeasonCelebrationTestConst = require("Common.Const.HomeSeasonCelebrationTestConst")
local HomeSeasonCelebrationItem = Class.LightClass("HomeSeasonCelebrationItem", BaseQueueItem)

function HomeSeasonCelebrationItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function HomeSeasonCelebrationItem:pushData(data)
	local current = self:firstRunItem()

	if current and current.uniqueId == data.uniqueId then
		table.merge(current, data)

		if NotNil(self.uContainer.content) then
			self:renderItem(self.uContainer.content, current)
		end

		return
	end

	for _, queuedData in ipairs(self.dataQueue) do
		if queuedData.uniqueId == data.uniqueId then
			table.merge(queuedData, data)

			return
		end
	end

	self:enqueue(data)
	self:tryPopupItem()
end

function HomeSeasonCelebrationItem:onUpdate()
	self:tryPopupItem()
end

function HomeSeasonCelebrationItem:onStart()
	local data = self:firstRunItem()

	if data and NotNil(self.uContainer.content) then
		self:renderItem(self.uContainer.content, data)
	end
end

function HomeSeasonCelebrationItem:onUIVisibleToHide()
	self:finished()
end

function HomeSeasonCelebrationItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function HomeSeasonCelebrationItem:hideById(id)
	local current = self:firstRunItem()

	if current and current.uniqueId == id then
		self:recycleItem(current)
	end

	for index = #self.dataQueue, 1, -1 do
		if self.dataQueue[index].uniqueId == id then
			table.remove(self.dataQueue, index)
		end
	end
end

function HomeSeasonCelebrationItem:hide()
	self:onClearDataQueue()
	self:onClearRunningList()
end

function HomeSeasonCelebrationItem:onClearRunningList(force)
	for index = #self.runList, 1, -1 do
		self:recycleItem(self.runList[index], force)
	end
end

function HomeSeasonCelebrationItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			if data.removing or self:firstRunItem() ~= data then
				return
			end

			self:renderItem(loadedItem, data)
		end))

		return
	end

	self:renderItem(self.uContainer.content, data)
end

function HomeSeasonCelebrationItem:renderItem(item, data)
	local remainSeconds = math.max(0, data.endTime - Time.secondCache)

	if remainSeconds <= 0 then
		self:recycleItem(data)

		return
	end

	local objectReference = item:GetComponent("ObjectReference")
	local prepareButton = objectReference:GetRefValue("btnPrepareUButton")
	local arrowImage = objectReference:GetRefValue("imgArrowUImage")
	local prepareHotkeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local countDown = objectReference:GetRefValue("countDownUCountDown")
	local detailsText = objectReference:GetRefValue("txtDetailsUSDFText")
	local clickable = data.clickable == true

	ClientTextUtils.setText(detailsText, data.title)

	prepareButton.interactable = clickable
	prepareButton.luaClick = clickable and data.clickFunc or nil

	if clickable and prepareHotkeyContent then
		prepareButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickPress, prepareHotkeyContent.gameObject)
	else
		prepareButton:RemoveLuaGamepadHotkey()
	end

	arrowImage.gameObject:SetActiveEx(clickable)

	countDown.useGameTime = false
	countDown.positiveTiming = false
	countDown.formatText = "{2}:{3}"
	countDown.enableTimePrefix = true

	countDown:Stop()
	countDown:Play(remainSeconds, data.duration or remainSeconds)

	countDown.luaFinished = self:guardRunCallback(data, function()
		if self:firstRunItem() == data then
			self:recycleItem(data)
		end
	end, item)
end

function HomeSeasonCelebrationItem:recycleItem(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Custom1)
end

function HomeSeasonCelebrationItem:GMPushData(data)
	data.uniqueId = data.uniqueId or HomeSeasonCelebrationTestConst.GM_TIP_UNIQUE_ID
	data.endTime = Time.secondCache + (data.duration or HomeSeasonCelebrationTestConst.GM_TIP_DURATION)
end

function HomeSeasonCelebrationItem:onDestroy()
	BaseQueueItem.onDestroy(self)

	if NotNil(self.uContainer) and NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end
end

function HomeSeasonCelebrationItem:onRecycleStarted(data, target)
	if NotNil(target) then
		local countDown = target:GetComponent("ObjectReference"):GetRefValue("countDownUCountDown")

		countDown.luaFinished = nil

		countDown:Stop()
	end
end

return HomeSeasonCelebrationItem
