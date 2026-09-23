-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\PvpInviteStateItem.lua

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
local PvpInviteStateItem = Class.LightClass("PvpInviteStateItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function PvpInviteStateItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function PvpInviteStateItem:pushData(data)
	if self:isRunning() or not self:isQueueEmpty() then
		return
	end

	self:enqueue(data)
end

function PvpInviteStateItem:onUpdate()
	self:tryPopupItem()
end

function PvpInviteStateItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	self:addRunItem(data)
	self:initUContainer(data)
end

function PvpInviteStateItem:hide()
	local param = self:firstRunItem()

	if param then
		self:recycleToast(param)
	end
end

function PvpInviteStateItem:onClearRunningList(force)
	local param = self:firstRunItem()

	if param then
		self:recycleToast(param, force)
	end
end

function PvpInviteStateItem:initUContainer(data)
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

function PvpInviteStateItem:renderItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local rootWidget = item:GetComponent("UWidget")
	local inviting = oc:GetRefValue("inviting")
	local accepted = oc:GetRefValue("accepted")
	local iconInvite = oc:GetRefValue("iconInvite")

	if data.mode == 1 then
		rootWidget:TryChangePage("InviteState", 1)
	elseif data.mode == 2 then
		rootWidget:TryChangePage("InviteState", 2)
	else
		rootWidget:TryChangePage("InviteState", 0)
	end
end

function PvpInviteStateItem:onRecycleStarted(data, target)
	if data.tickTimer then
		self:killTimer(data.tickTimer)

		data.tickTimer = nil
	end
end

function PvpInviteStateItem:onRecycleFinished(data, reason)
	self:setVisible(false)
end

return PvpInviteStateItem
