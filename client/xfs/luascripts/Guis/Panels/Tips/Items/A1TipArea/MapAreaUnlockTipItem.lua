-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\MapAreaUnlockTipItem.lua

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
local MapAreaUnlockTipItem = Class.LightClass("MapAreaUnlockTipItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function MapAreaUnlockTipItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function MapAreaUnlockTipItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function MapAreaUnlockTipItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 4)

	self:addRunItem(data)
	self:initUContainer(data)
end

function MapAreaUnlockTipItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function MapAreaUnlockTipItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function MapAreaUnlockTipItem:initUContainer(data)
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

function MapAreaUnlockTipItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local shadowTMPUSDFText = objectReference:GetRefValue("shadowTMPUSDFText")
	local titleTMPUSDFText = objectReference:GetRefValue("titleTMPUSDFText")

	ClientTextUtils.setText(shadowTMPUSDFText, pg.getLocalizationText(data.unlockName))
	ClientTextUtils.setText(titleTMPUSDFText, pg.getLocalizationText(data.unlockName))
end

return MapAreaUnlockTipItem
