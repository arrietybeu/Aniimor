-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\GrabEggWaitingInfoItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggWaitingInfoItem = Class.LightClass("GrabEggWaitingInfoItem", BaseQueueItem)
local DEFAULT_TIPS_TEXT_KEY = "GRAB_EGG_LOADING_WAIT"

function GrabEggWaitingInfoItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function GrabEggWaitingInfoItem:pushData(data)
	if self:isRunning() or not self:isQueueEmpty() then
		return
	end

	self:enqueue(data or {})
end

function GrabEggWaitingInfoItem:onUpdate()
	self:tryPopupItem()
end

function GrabEggWaitingInfoItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function GrabEggWaitingInfoItem:onClearRunningList(force)
	local data = self:firstRunItem()

	if data then
		self:recycleToast(data, force)
	end
end

function GrabEggWaitingInfoItem:hide()
	self:onClearDataQueue()
	self:clearRunningList(true)
end

function GrabEggWaitingInfoItem:initUContainer(data)
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

function GrabEggWaitingInfoItem:renderItem(item, data)
	if IsNil(item) then
		return
	end

	local objectReference = item:GetComponent("ObjectReference")

	if objectReference == nil then
		return
	end

	local tipsTxt = objectReference:GetRefValue("tipsTxt")

	if NotNil(tipsTxt) then
		local tipsText = pg.getGameString(data.tipsTextKey or DEFAULT_TIPS_TEXT_KEY)

		ClientTextUtils.setText(tipsTxt, tipsText)
	end
end

return GrabEggWaitingInfoItem
