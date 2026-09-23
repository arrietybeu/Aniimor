-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\GrabEggsIncubatorItem.lua

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
local GrabEggsIncubatorItem = Class.LightClass("GrabEggsIncubatorItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function GrabEggsIncubatorItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function GrabEggsIncubatorItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function GrabEggsIncubatorItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function GrabEggsIncubatorItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function GrabEggsIncubatorItem:hide()
	self:clearRunningList()
end

function GrabEggsIncubatorItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function GrabEggsIncubatorItem:initUContainer(data)
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

function GrabEggsIncubatorItem:renderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local shadowTitle = objectReference:GetRefValue("shadowTMPUSDFText")
	local title = objectReference:GetRefValue("titleTMPUSDFText")
	local desc = objectReference:GetRefValue("textUSDFText")

	ClientTextUtils.setText(shadowTitle, data.title)
	ClientTextUtils.setText(title, data.title)

	if string.isNilOrEmpty(data.desc) then
		LuaUIUtils.setUIVisible(desc, false)
	else
		LuaUIUtils.setUIVisible(desc, true)
		ClientTextUtils.setText(desc, data.desc)
	end

	button:TryChangePage("Type", data.type or 0)
end

function GrabEggsIncubatorItem:GMPushData(data)
	data.type = data.param or 0
end

return GrabEggsIncubatorItem
