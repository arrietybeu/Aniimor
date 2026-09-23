-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\BossMechanismProgressItem.lua

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
local Utils = require("Common.Utils.Utils")
local BossMechanismProgressItem = Class.LightClass("BossMechanismProgressItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function BossMechanismProgressItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BossMechanismProgressItem:onUpdate()
	self:refreshRemainTime()
	self:tryPopupItem()
	self:refreshRunState()
end

function BossMechanismProgressItem:findDataByUniqueId(list, uniqueId)
	for i, data in ipairs(list) do
		if data.uniqueId == uniqueId then
			return data, i
		end
	end
end

function BossMechanismProgressItem:pushData(data)
	local runData = self:findDataByUniqueId(self.runList, data.uniqueId)

	if runData and not runData.removing then
		BossMechanismProgressItem.clearProcess(runData)
		table.merge(runData, data)
		BossMechanismProgressItem.resetTime(runData)

		if NotNil(self.uContainer.content) then
			self:renderItem(self.uContainer.content, runData)
		end

		return
	end

	local queueData, queueIndex = self:findDataByUniqueId(self.dataQueue, data.uniqueId)

	if queueData then
		table.merge(queueData, data)
		BossMechanismProgressItem.resetTime(queueData)
		table.remove(self.dataQueue, queueIndex)
		self:prioritizeData(queueData)

		return
	end

	BossMechanismProgressItem.resetTime(data)
	self:prioritizeData(data)
end

function BossMechanismProgressItem:prioritizeData(data)
	local runData = self:firstRunItem()

	if not runData then
		table.insert(self.dataQueue, 1, data)
		self:refreshRunState()

		return
	end

	if runData.removing then
		self:destroyContent(runData)
	else
		BossMechanismProgressItem.clearProcess(runData)
		table.insert(self.dataQueue, 1, runData)
		self:removeItem(runData)
	end

	self:addRunItem(data)
	self:refreshRunState()
	self:initUContainer(data)
end

function BossMechanismProgressItem.resetTime(data)
	data.runStartTime = Time.realSecondCache
	data.endTime = data.duration or 3
	data.processDelay = data.countDownBeginTime
	data.processDuration = data.countDownDuration
end

function BossMechanismProgressItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossMechanismProgressItem:refreshRemainTime()
	local timePause = BossMechanismProgressItem.checkTimePause()

	for i = #self.dataQueue, 1, -1 do
		local data = self.dataQueue[i]

		self:updateDataTime(data, timePause)

		if data.endTime <= 0 then
			table.remove(self.dataQueue, i)
		end
	end

	local data = self:firstRunItem()

	if not data or data.removing then
		return
	end

	self:updateDataTime(data, timePause)

	if data.endTime <= 0 then
		self:recycleToast(data)
	end
end

function BossMechanismProgressItem:updateDataTime(data, timePause)
	local delta = Time.realSecondCache - data.runStartTime

	data.runStartTime = Time.realSecondCache

	if timePause then
		return
	end

	data.endTime = data.endTime - delta

	self:runProcessAnime(data, delta)
end

function BossMechanismProgressItem:onTimelineResume(delta, suspendedAt)
	for _, data in ipairs(self.runList) do
		data.runStartTime = math.min(data.runStartTime + delta, Time.realSecondCache)
	end

	for _, data in ipairs(self.dataQueue) do
		data.runStartTime = math.min(data.runStartTime + delta, Time.realSecondCache)
	end
end

function BossMechanismProgressItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function BossMechanismProgressItem:hideById(id)
	for i = #self.dataQueue, 1, -1 do
		if self.dataQueue[i].uniqueId == id then
			table.remove(self.dataQueue, i)
		end
	end

	local param = self:firstRunItem()

	if param and param.uniqueId == id then
		self:recycleToast(param)
	end

	self:refreshRunState()
end

function BossMechanismProgressItem:hide()
	self:clearAllData()
end

function BossMechanismProgressItem:initUContainer(data)
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
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function BossMechanismProgressItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local tipsText = objectReference:GetRefValue("txtTipsUSDFText")
	local rightUProgress = objectReference:GetRefValue("progressRightUProgress")
	local leftUProgress = objectReference:GetRefValue("progressLeftUProgress")
	local progressUWidget = objectReference:GetRefValue("progressUWidget")

	ClientTextUtils.setText(tipsText, pg.getLocalizationText(data.text))

	local countDownDuration = data.countDownDuration

	if countDownDuration <= 0 or data.processDuration <= 0 then
		LuaUIUtils.setUIViewVisible(progressUWidget, false)

		return
	end

	LuaUIUtils.setUIViewVisible(progressUWidget, true)

	rightUProgress.maxValue = countDownDuration
	rightUProgress.value = data.processDuration
	leftUProgress.maxValue = countDownDuration
	leftUProgress.value = data.processDuration
	data.startProcess = true
	data.leftUProgress = leftUProgress
	data.rightUProgress = rightUProgress
	data.progressUWidget = progressUWidget
end

function BossMechanismProgressItem:runProcessAnime(data, delta)
	if data.processDelay > 0 then
		local delayDelta = math.min(data.processDelay, delta)

		data.processDelay = data.processDelay - delayDelta
		delta = delta - delayDelta
	end

	data.processDuration = math.max(data.processDuration - delta, 0)

	if not data.startProcess then
		return
	end

	if data.processDuration <= 0 then
		LuaUIUtils.setUIViewVisible(data.progressUWidget, false)
		BossMechanismProgressItem.clearProcess(data)

		return
	end

	data.leftUProgress.value = data.processDuration
	data.rightUProgress.value = data.processDuration
end

function BossMechanismProgressItem.clearProcess(data)
	data.startProcess = nil
	data.leftUProgress = nil
	data.rightUProgress = nil
	data.progressUWidget = nil
end

function BossMechanismProgressItem.checkTimePause()
	local timeZoneList = pg.pawn.timeScaleMgr.timeZones
	local finalTimeScale = pg.pawn:getFinalTimeScale()

	return not Utils.tableIsEmptyOrNil(timeZoneList) or finalTimeScale == 0
end

function BossMechanismProgressItem:GMPushData(data)
	if data.uniqueId == nil then
		self.gmUniqueIdSeed = (self.gmUniqueIdSeed or 0) + 1
		data.uniqueId = "GM_" .. self.gmUniqueIdSeed
	end

	data.countDownBeginTime = data.countDownBeginTime or 0
	data.countDownDuration = data.countDownDuration or data.duration or 5
	data.duration = math.max(data.duration or 0, data.countDownBeginTime + data.countDownDuration)
end

function BossMechanismProgressItem:onRecycleStarted(data, target)
	BossMechanismProgressItem.clearProcess(data)
end

return BossMechanismProgressItem
