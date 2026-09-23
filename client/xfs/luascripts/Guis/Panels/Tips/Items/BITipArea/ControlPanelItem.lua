-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BITipArea\\ControlPanelItem.lua

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
local ControlPanelItem = Class.LightClass("ControlPanelItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function ControlPanelItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ControlPanelItem:pushData(data)
	if not self:isWaitingOrRunning() then
		self:enqueue(data)
	end
end

function ControlPanelItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ControlPanelItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = data.endTime or Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function ControlPanelItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ControlPanelItem:onUIVisibleToHide()
	self:finished()
end

function ControlPanelItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ControlPanelItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function ControlPanelItem:initUContainer(data)
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

function ControlPanelItem:renderItem(button, data)
	button:InvokeCallback(CS.XGUI.EInvokeTime.Show)

	local objectReference = button:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local title = objectReference:GetRefValue("title")

	ClientTextUtils.setText(title, data.title)

	progressUProgress.minValue = 0
	progressUProgress.maxValue = 1

	local remainDuration = math.max(0, data.endTime - Time.realSecondCache)
	local totalDuration = data.startTime and data.endTime - data.startTime or 0
	local hasTimeline = totalDuration > 0
	local progress = 0

	if hasTimeline then
		progress = math.max(0, math.min(1, (Time.realSecondCache - data.startTime) / totalDuration))
	end

	if data.direction == 0 then
		progressUProgress.value = hasTimeline and 1 - progress or 1

		progressUProgress:ProgressToValue(0, nil, remainDuration, 0, CS.DG.Tweening.Ease.Linear, false)
	else
		progressUProgress.value = hasTimeline and progress or 0

		progressUProgress:ProgressToValue(1, nil, remainDuration, 0, CS.DG.Tweening.Ease.Linear, false)
	end
end

function ControlPanelItem:hide()
	self:clearDataQueue()
	self:clearRunningList(true)
	self:refreshRunState()
end

function ControlPanelItem:GMPushData(data)
	data.endTime = Time.realSecondCache + (data.duration or 3)
	data.direction = data.param or 0
end

return ControlPanelItem
