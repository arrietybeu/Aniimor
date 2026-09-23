-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\QuestCompleteItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local QuestCompleteItem = Class.LightClass("QuestCompleteItem", BaseQueueItem)
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")

function QuestCompleteItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function QuestCompleteItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function QuestCompleteItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3.6)

	self:addRunItem(data)
	self:initUContainer(data)
end

function QuestCompleteItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function QuestCompleteItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function QuestCompleteItem:initUContainer(data)
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

function QuestCompleteItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("uIPbQuestComponent")

	rootUComponent:TryChangePage("States", 2)

	local questConfig = QuestUtils.getQuestConfig(data.id)
	local contentTxt

	if questConfig.questType == QuestConst.QUEST_TYPE.MAIN then
		rootUComponent:TryChangePage("States", 0)

		contentTxt = objectReference:GetRefValue("taskUText")
	elseif questConfig.questType == QuestConst.QUEST_TYPE.DELEGATION then
		rootUComponent:TryChangePage("States", 1)

		contentTxt = objectReference:GetRefValue("delegationUText")
	else
		rootUComponent:TryChangePage("States", 3)

		contentTxt = objectReference:GetRefValue("delegationUText")
	end

	ClientTextUtils.setText(contentTxt, pg.getLocalizationText(questConfig.title))
end

return QuestCompleteItem
