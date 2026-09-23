-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\TowerResultWaveItem.lua

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
local TowerResultWaveItem = Class.LightClass("TowerResultWaveItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function TowerResultWaveItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function TowerResultWaveItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function TowerResultWaveItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function TowerResultWaveItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function TowerResultWaveItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function TowerResultWaveItem:initUContainer(data)
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

function TowerResultWaveItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local wave1UBaseText = objectReference:GetRefValue("wave1UBaseText")
	local waveUBaseText = objectReference:GetRefValue("waveUBaseText")

	ClientTextUtils.setText(wave1UBaseText, string.format("%s %d/%d", pg.getGameString("ROGUE_TOWER_STAGE"), data.params.stage, data.params.totalStage))
	ClientTextUtils.setText(waveUBaseText, string.format("%s %d/%d", pg.getGameString("ROGUE_TOWER_STAGE"), data.params.stage, data.params.totalStage))

	local ani = item:GetComponent("Animation")

	ani:Play()
end

return TowerResultWaveItem
