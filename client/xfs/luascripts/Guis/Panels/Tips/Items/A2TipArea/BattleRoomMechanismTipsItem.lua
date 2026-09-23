-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\BattleRoomMechanismTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BattleRoomMechanismTipsItem = Class.LightClass("BattleRoomMechanismTipsItem", BaseQueueItem)

function BattleRoomMechanismTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BattleRoomMechanismTipsItem:pushData(data)
	local runningData = self:firstRunItem()

	self:onClearDataQueue()
	self:enqueue(data)

	if runningData then
		self:destroyContent(runningData)
	end
end

function BattleRoomMechanismTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function BattleRoomMechanismTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.secondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function BattleRoomMechanismTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.secondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function BattleRoomMechanismTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function BattleRoomMechanismTipsItem:hide()
	self:clearAllData(true)
end

function BattleRoomMechanismTipsItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			if self:firstRunItem() ~= data then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function BattleRoomMechanismTipsItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local tipsText = objectReference:GetRefValue("txtTipsUSDFText")
	local iconTransform = objectReference:GetRefValue("iconTransform")

	ClientTextUtils.setText(tipsText, pg.getLocalizationText(data.text))
	iconTransform.gameObject:SetActiveEx(false)
end

return BattleRoomMechanismTipsItem
