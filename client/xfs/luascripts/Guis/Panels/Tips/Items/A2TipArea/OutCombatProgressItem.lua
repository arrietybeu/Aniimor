-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\OutCombatProgressItem.lua

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
local OutCombatProgressItem = Class.LightClass("OutCombatProgressItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function OutCombatProgressItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function OutCombatProgressItem:pushData(data)
	local current = self:firstRunItem()

	self:clearDataQueue()

	if current and not current.removing then
		self.data = data

		self:refreshView(self.uContainer.content, data)
	elseif current then
		self:recycleToast(current, true)

		self.data = data

		self:addRunItem(data)
		self:initUContainer(data)
	else
		self.data = data

		self:enqueue(data)
	end
end

function OutCombatProgressItem:onUpdate()
	self:tryPopupItem()

	local current = self:firstRunItem()
	local auto = current and not current.removing and self.data and self.data.autoUpdate

	if auto then
		self.data.progress = math.clamp((Time.realSecondCache - self.data.startTime) / (self.data.duration or 1), 0, 1)

		if self.data.progress >= 1 then
			self:recycleToast(current)

			return
		end

		self:refreshView(self.uContainer.content, self.data)
	end
end

function OutCombatProgressItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self.data = self:dequeue()

	self:addRunItem(self.data)
	self:initUContainer(self.data)
end

function OutCombatProgressItem:onUIVisibleToHide()
	self:clearRunningList(true)
end

function OutCombatProgressItem:onClearRunningList(force)
	self:clearDataQueue()

	self.data = nil

	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:recycleToast(data, force)
	end
end

function OutCombatProgressItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function OutCombatProgressItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			self:renderItem(loadedItem, self.data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function OutCombatProgressItem:renderItem(item, data)
	item:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	self:refreshView(item, data)
end

function OutCombatProgressItem:refreshView(item, data)
	if IsNil(item) then
		return
	end

	local current = self:firstRunItem()

	if not current or current.removing then
		return
	end

	local widget = item:GetComponent("UComponent")
	local objectReference = widget:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local txtTitle = objectReference:GetRefValue("txtTitle")

	progressUProgress.minValue = 0
	progressUProgress.maxValue = 1

	local progress = math.clamp(data.progress, 0, 1)

	progressUProgress.value = progress

	if not string.isNilOrEmpty(data.title) then
		ClientTextUtils.setText(txtTitle, data.title)
	else
		ClientTextUtils.setText(txtTitle, pg.getLocalizationText(1663226021))
	end
end

function OutCombatProgressItem:hideById(id)
	self.data = nil

	self:clearDataQueue()

	local data = self:firstRunItem()

	if data then
		self:recycleToast(data)
	end
end

function OutCombatProgressItem:onDestroy()
	BaseQueueItem.onDestroy(self)

	if NotNil(self.uContainer.content) then
		self.uContainer:DestroyContent()
	end

	self:setVisible(false)
end

function OutCombatProgressItem:onRecycleFinished(data, reason)
	if not self:firstRunItem() and self:isQueueEmpty() then
		self.data = nil
	end
end

return OutCombatProgressItem
