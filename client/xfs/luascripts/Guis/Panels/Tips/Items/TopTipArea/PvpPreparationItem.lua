-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\PvpPreparationItem.lua

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
local TimeUtils = require("Common.Utils.TimeUtils")
local PvpPreparationItem = Class.LightClass("PvpPreparationItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function PvpPreparationItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function PvpPreparationItem:pushData(data)
	if self:isRunning() or not self:isQueueEmpty() then
		return
	end

	self:enqueue(data)
end

function PvpPreparationItem:onUpdate()
	self:tryPopupItem()
end

function PvpPreparationItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function PvpPreparationItem:hide()
	local param = self:firstRunItem()

	if param and param.uniqueId then
		self:recycleToast(param)
	end
end

function PvpPreparationItem:onClearRunningList(force)
	local param = self:firstRunItem()

	if param then
		self:recycleToast(param, force)
	end
end

function PvpPreparationItem:initUContainer(data)
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

function PvpPreparationItem:renderItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local txtCountdown = oc:GetRefValue("txtCountdown")

	if data.tickTimer then
		self:killTimer(data.tickTimer)
	end

	data.tickTimer = self:startTimer(self:guardRunCallback(data, function()
		local remandSecond = data.endTime - Time.secondCache

		ClientTextUtils.setText(txtCountdown, TimeUtils.timeToFormatString(remandSecond))
	end, item), 0.02, true)
end

function PvpPreparationItem:GMPushData(data)
	data.endTime = Time.secondCache + (data.duration or 50)
end

function PvpPreparationItem:onRecycleStarted(data, target)
	if data.tickTimer then
		self:killTimer(data.tickTimer)

		data.tickTimer = nil
	end
end

function PvpPreparationItem:onRecycleFinished(data, reason)
	self:setVisible(false)
end

return PvpPreparationItem
