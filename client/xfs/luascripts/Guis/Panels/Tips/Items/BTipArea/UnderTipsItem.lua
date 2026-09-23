-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\UnderTipsItem.lua

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
local AbilityConst = require("Common.Const.AbilityConst")
local UnderTipsItem = Class.LightClass("UnderTipsItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function UnderTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function UnderTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function UnderTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 5)

	self:addRunItem(data)
	self:initUContainer(data)
end

function UnderTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function UnderTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function UnderTipsItem:hideById(id)
	self:onClearDataQueue()

	local data = self.runList[1]

	if data then
		self:recycleToast(data)
	end
end

function UnderTipsItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function UnderTipsItem:initUContainer(data)
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

function UnderTipsItem:renderItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local displayText = oc:GetRefValue("displayText")

	ClientTextUtils.setText(displayText, data.displayText)
end

function UnderTipsItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end
end

return UnderTipsItem
