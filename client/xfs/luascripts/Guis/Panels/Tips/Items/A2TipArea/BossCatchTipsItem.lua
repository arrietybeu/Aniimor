-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\BossCatchTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossCatchTipsItem = Class.LightClass("BossCatchTipsItem", BaseQueueItem)

function BossCatchTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BossCatchTipsItem:pushData(data)
	if self:isRunning() or not self:isQueueEmpty() then
		return
	end

	self:enqueue(data)
end

function BossCatchTipsItem:onUpdate()
	self:tryPopupItem()
end

function BossCatchTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossCatchTipsItem:hideById(id)
	self:clearDataQueue()
	self:onClearRunningList()
end

function BossCatchTipsItem:onClearRunningList(force)
	for index = #self.runList, 1, -1 do
		self:destroyContent(self.runList[index], force)
	end
end

function BossCatchTipsItem:initUContainer(data)
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

function BossCatchTipsItem:renderItem(item, data)
	if not item then
		return
	end

	local objectReference = item:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")

	if txtTipsUSDFText then
		ClientTextUtils.setText(txtTipsUSDFText, data.text)
	end
end

function BossCatchTipsItem:destroyContent(data, force)
	self:requestRecycle(data, force)
end

function BossCatchTipsItem:playRecycleAnimation(data, target, exitEvent, complete)
	if NotNil(target) then
		target:TryDestroyWithAnim(complete)
	else
		complete()
	end
end

function BossCatchTipsItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleContainer(target, reason, true)
end

return BossCatchTipsItem
