-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\CountDownLimitedTimeItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Time = require("Core.Common.Time")
local CountDownLimitedTimeItem = Class.LightClass("CountDownLimitedTimeItem", BaseQueueItem)
local ZERO_SHOW_DURATION = 1

function CountDownLimitedTimeItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function CountDownLimitedTimeItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function CountDownLimitedTimeItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function CountDownLimitedTimeItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self:firstRunItem()

	if data == nil or data.endTime == nil then
		return
	end

	if data.timer ~= nil or data.finishDelayTimer ~= nil then
		return
	end

	if Time.secondCache < data.endTime then
		return
	end

	if not data.zeroShown and NotNil(self.uContainer.content) then
		self:renderItem(self.uContainer.content, data)

		return
	end

	self:onCountDownFinish(data)
end

function CountDownLimitedTimeItem:refresh(...)
	if IsNil(self.uContainer.content) then
		return
	end

	local uniqueId, extraData = table.unpack({
		...
	})
	local data = self:firstRunItem()

	if data == nil or data.uniqueId ~= uniqueId then
		return
	end

	table.merge(data, extraData)
	self:renderItem(self.uContainer.content, data)
end

function CountDownLimitedTimeItem:hideById(id)
	local data = self:firstRunItem()

	if data and data.uniqueId == id then
		self:recycleToast(data, true)
	end

	local num = #self.dataQueue

	for i = num, 1, -1 do
		if self.dataQueue[i].uniqueId == id then
			table.remove(self.dataQueue, i)
		end
	end
end

function CountDownLimitedTimeItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		self:recycleToast(self.runList[i], force)
	end
end

function CountDownLimitedTimeItem:onUIVisibleToHide()
	self:finished()
end

function CountDownLimitedTimeItem:onCountDownFinish(data)
	if data.finished then
		return
	end

	data.finished = true

	self:recycleToast(data)

	if data.finishCb then
		data.finishCb()
	end
end

function CountDownLimitedTimeItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			if data.removing or not self:isRunning() then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function CountDownLimitedTimeItem:renderItem(item, data)
	if IsNil(item) then
		return
	end

	if data.removing then
		return
	end

	if data.timer then
		self:killTimer(data.timer)

		data.timer = nil
	end

	if data.finishDelayTimer then
		self:killTimer(data.finishDelayTimer)

		data.finishDelayTimer = nil
	end

	data.zeroShown = false

	local objectReference = item:GetComponent("ObjectReference")
	local number = objectReference:GetRefValue("number")
	local bgNumber = objectReference:GetRefValue("bgNumber")
	local countDownAnimation = objectReference:GetRefValue("countDownAnimation")
	local titleTxt = objectReference:GetRefValue("titleTxt")

	ClientTextUtils.setText(titleTxt, pg.getGameString("怪物即将来袭，请做好准备"))

	local function refreshNumber()
		local remain = math.ceil(data.endTime - Time.secondCache)

		if remain <= 0 then
			if data.zeroShown then
				return
			end

			data.zeroShown = true

			if data.timer then
				self:killTimer(data.timer)

				data.timer = nil
			end

			self:playAnim(number, bgNumber, countDownAnimation, 0)

			data.finishDelayTimer = self:startTimer(self:guardRunCallback(data, function()
				data.finishDelayTimer = nil

				self:onCountDownFinish(data)
			end, item), ZERO_SHOW_DURATION)

			return
		end

		self:playAnim(number, bgNumber, countDownAnimation, remain)
	end

	refreshNumber()

	if not data.zeroShown and not data.removing and not data.finished then
		data.timer = self:startTimer(self:guardRunCallback(data, refreshNumber, item), 1, true)
	end
end

function CountDownLimitedTimeItem:playAnim(uText, bgNumber, anim, number)
	ClientTextUtils.setText(bgNumber, tostring(number))
	ClientTextUtils.setText(uText, tostring(number))
	anim:Stop()
	anim:Play("VX_Node_CountDown_Single_In")
end

function CountDownLimitedTimeItem:onSceneUnload()
	self:clearRunningList()
end

function CountDownLimitedTimeItem:GMPushData(data)
	data.endTime = Time.secondCache + (data.duration or 5)
end

function CountDownLimitedTimeItem:onDestroy()
	if NotNil(self.uContainer) and NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self:setVisible(false)
	BaseQueueItem.onDestroy(self)
end

function CountDownLimitedTimeItem:onRecycleStarted(data, target)
	if data.timer then
		self:killTimer(data.timer)

		data.timer = nil
	end

	if data.finishDelayTimer then
		self:killTimer(data.finishDelayTimer)

		data.finishDelayTimer = nil
	end
end

return CountDownLimitedTimeItem
