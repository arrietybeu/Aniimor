-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\CountDownBeatItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local HotkeyConst = require("Const.HotkeyConst")
local CountDownBeatItem = Class.LightClass("CountDownBeatItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function CountDownBeatItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function CountDownBeatItem:pushData(data)
	if not self:isWaitingOrRunning() then
		self:enqueue(data)
	end
end

function CountDownBeatItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function CountDownBeatItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = data.endTime or Time.secondCache

	self:addRunItem(data)
	self:initUContainer(data)
end

function CountDownBeatItem:onClearRunningList(force)
	if force then
		self:clearCurrentRunningItem(force)
	end
end

function CountDownBeatItem:clearCurrentRunningItem(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:recycleToast(data, force)
	end
end

function CountDownBeatItem:hide()
	self:clearCurrentRunningItem()
end

function CountDownBeatItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.secondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function CountDownBeatItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function CountDownBeatItem:renderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local number = objectReference:GetRefValue("number")
	local bgNumber = objectReference:GetRefValue("bgNumber")
	local countDownAnimation = objectReference:GetRefValue("countDownAnimation")
	local remandTime = math.ceil(math.max(0, data.endTime - Time.secondCache))

	self:playAnim(number, bgNumber, countDownAnimation, math.floor(remandTime))

	data.timer = self:startTimer(self:guardRunCallback(data, function()
		remandTime = math.ceil(math.max(0, data.endTime - Time.secondCache))

		self:playAnim(number, bgNumber, countDownAnimation, remandTime)
	end, button), 1, true)
end

function CountDownBeatItem:playAnim(uText, bgNumber, anim, number)
	ClientTextUtils.setText(bgNumber, tostring(number))
	ClientTextUtils.setText(uText, tostring(number))
	anim:Stop()
	anim:Play("VX_Node_CountDown_Single_In")
end

function CountDownBeatItem:GMPushData(data)
	data.endTime = Time.secondCache + (data.duration or 3)
end

function CountDownBeatItem:onRecycleStarted(data, target)
	if data.timer then
		self:killTimer(data.timer)

		data.timer = nil
	end
end

return CountDownBeatItem
