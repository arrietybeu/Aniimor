-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\ResultFailItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ResultFailItem = Class.LightClass("ResultFailItem", BaseQueueItem)

function ResultFailItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ResultFailItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ResultFailItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function ResultFailItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ResultFailItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ResultFailItem:initUContainer(data)
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

function ResultFailItem:renderItem(item, data)
	local objectRef = item:GetComponent("ObjectReference")
	local textUBaseText = objectRef:GetRefValue("textUBaseText")

	ClientTextUtils.setText(textUBaseText, pg.getGameString("CHALLENGE_FAIL"))
end

return ResultFailItem
