-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\BossCatchWarningItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossCatchWarningItem = Class.LightClass("BossCatchWarningItem", BaseQueueItem)

function BossCatchWarningItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BossCatchWarningItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function BossCatchWarningItem:pushData(data)
	if self:isRunning() then
		local cur = self.runList[1]

		if cur then
			cur.duration = data.duration
			cur.endTime = Time.realSecondCache + (data.duration or 0)

			self:_refreshNumText(cur.endTime - Time.realSecondCache)
		end

		return
	end

	self:onClearDataQueue()
	self:enqueue(data)
end

function BossCatchWarningItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 0)

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossCatchWarningItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]
	local remain = data.endTime - Time.realSecondCache

	if remain <= 0 then
		self:recycleToast(data)

		return
	end

	self:_refreshNumText(remain)
end

function BossCatchWarningItem:hideById(id)
	self:onClearDataQueue()
	self:onClearRunningList()
end

function BossCatchWarningItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function BossCatchWarningItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			if not self.uContainer or data.removing then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function BossCatchWarningItem:renderItem(item, data)
	if not item then
		return
	end

	local oc = item:GetComponent("ObjectReference")

	if not oc then
		return
	end

	self._panel = oc:GetRefValue("panelUWidget")
	self._bg1 = oc:GetRefValue("bg1UBaseText")
	self._textNum = oc:GetRefValue("textNumUBaseText")

	local titleText = oc:GetRefValue("textTitleUBaseText")
	local subText = oc:GetRefValue("textSubUBaseText")

	if titleText then
		if string.isNilOrEmpty(data.title) then
			titleText:SetActive(false)
		else
			titleText:SetActive(true)
			ClientTextUtils.setText(titleText, data.title)
		end
	end

	if subText then
		if string.isNilOrEmpty(data.subTitle) then
			subText:SetActive(false)
		else
			subText:SetActive(true)
			ClientTextUtils.setText(subText, data.subTitle)
		end
	end

	local remain = data.endTime - Time.realSecondCache
	local sec = math.max(0, math.ceil(remain))

	self._lastSec = sec

	self:_setNumText(sec)

	if self._panel then
		self._panel:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function BossCatchWarningItem:_setNumText(sec)
	local str = tostring(sec)

	if self._bg1 then
		ClientTextUtils.setText(self._bg1, str)
	end

	if self._textNum then
		ClientTextUtils.setText(self._textNum, str)
	end
end

function BossCatchWarningItem:_refreshNumText(remain)
	local sec = math.max(0, math.ceil(remain))

	if sec == self._lastSec then
		return
	end

	self._lastSec = sec

	self:_setNumText(sec)

	if self._panel then
		self._panel:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end
end

function BossCatchWarningItem:GMPushData(data)
	data.startTime = Time.realSecondCache
end

function BossCatchWarningItem:onRecycleFinished(data, reason)
	self._panel = nil
	self._bg1 = nil
	self._textNum = nil
	self._lastSec = nil
end

return BossCatchWarningItem
