-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\BossMechanismTipsItem.lua

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
local BossMechanismTipsItem = Class.LightClass("BossMechanismTipsItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function BossMechanismTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BossMechanismTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function BossMechanismTipsItem:findDataByUniqueId(list, uniqueId)
	for _, data in ipairs(list) do
		if data.uniqueId == uniqueId then
			return data
		end
	end
end

function BossMechanismTipsItem:pushData(data)
	local runData = self:findDataByUniqueId(self.runList, data.uniqueId)

	if runData and not runData.removing then
		table.merge(runData, data)

		runData.endTime = Time.realSecondCache + (runData.duration or 3)

		if NotNil(self.uContainer.content) then
			self:renderItem(self.uContainer.content, runData)
		end

		return
	end

	local queueData = self:findDataByUniqueId(self.dataQueue, data.uniqueId)

	if queueData then
		table.merge(queueData, data)

		return
	end

	self:enqueue(data)
end

function BossMechanismTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossMechanismTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function BossMechanismTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function BossMechanismTipsItem:hide()
	self:clearAllData(true)
end

function BossMechanismTipsItem:initUContainer(data)
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

function BossMechanismTipsItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local tipsText = objectReference:GetRefValue("txtTipsUSDFText")

	ClientTextUtils.setText(tipsText, pg.getLocalizationText(data.text))
end

return BossMechanismTipsItem
