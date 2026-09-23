-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\CompletionPromptItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ActivityConst = require("Common.Const.ActivityConst")
local GameEventData = require("Data.game_event_data")
local GameEventTypeData = require("Data.game_event_type_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local PetData = require("Data.pet_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local CompletionPromptItem = Class.LightClass("CompletionPromptItem", BaseQueueItem)

function CompletionPromptItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function CompletionPromptItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function CompletionPromptItem:isActivityOpen()
	return ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.PuppetCatch, pg.me)
end

function CompletionPromptItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() or not self:isActivityOpen() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (SysConfigData.LUCKYPET_TIP or 5)

	self:addRunItem(data)
	self:initUContainer(data)
end

function CompletionPromptItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function CompletionPromptItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Custom1)
end

function CompletionPromptItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function CompletionPromptItem:initUContainer(data)
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

function CompletionPromptItem:onClickJump(data, tabType)
	pg.global.ui:open(UIConst.UI_ID_EVENT, {
		id = data.eventId,
		tabType = tabType
	})
	self:clearRunningList(true)
end

function CompletionPromptItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local textPointsUBaseText = objectReference:GetRefValue("textPointsUBaseText")
	local rootButton = objectReference:GetRefValue("rootButton")
	local taskNameUBaseText = objectReference:GetRefValue("taskNameUBaseText")
	local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")

	rootButton.luaClick = self:guardRunCallback(data, function()
		if data.overrideClick then
			data.overrideClick()

			return
		end

		local eventData = GameEventData[data.eventId]
		local tabType = eventData and GameEventTypeData[eventData.eventType] and GameEventTypeData[eventData.eventType].tabType

		if not tabType then
			return
		end

		if item:CheckHasEvent(CS.XGUI.EInvokeTime.Custom2) then
			item:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom2, self:guardRunCallback(data, function()
				self:onClickJump(data, tabType)
			end, item))
		else
			self:onClickJump(data, tabType)
		end
	end, item)

	ClientTextUtils.setText(textPointsUBaseText, string.format("+%s", data.pointNum))

	local eventName = GameEventTypeData[ActivityConst.EventType.PuppetCatch].name

	ClientTextUtils.setText(taskNameUBaseText, pg.getLocalizationText(eventName))

	local petName = data.templateId and PetData[data.templateId] and PetData[data.templateId].name

	ClientTextUtils.setText(petNameUBaseText, ClientTextUtils.concatByLanguage(pg.getLocalizationText(petName), pg.getGameString("LUCKYPET_FINISH")))

	if data.overrideTitle then
		ClientTextUtils.setText(taskNameUBaseText, data.overrideTitle)
	end

	if data.overrideName then
		ClientTextUtils.setText(petNameUBaseText, data.overrideName)
	end

	if data.type then
		rootButton:TryChangePage("type", data.type)
	end
end

function CompletionPromptItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end
end

return CompletionPromptItem
