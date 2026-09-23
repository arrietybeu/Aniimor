-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\TransferEggItem.lua

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
local TransferEggItem = Class.LightClass("TransferEggItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function TransferEggItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function TransferEggItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function TransferEggItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 8)

	self:addRunItem(data)
	self:initUContainer(data)
end

function TransferEggItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function TransferEggItem:hide()
	self:clearRunningList()
end

function TransferEggItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function TransferEggItem:initUContainer(data)
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

function TransferEggItem:renderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")
	local txtDesc = objectReference:GetRefValue("txtDesc")

	button:TryChangePage("State", 6)
	button:TryChangePage("State", data.state or 0)
	ClientTextUtils.setText(txtTitle, data.title)

	if string.isNilOrEmpty(data.desc) then
		LuaUIUtils.setUIVisible(txtDesc, false)
	else
		LuaUIUtils.setUIVisible(txtDesc, true)
		ClientTextUtils.setText(txtDesc, data.desc)
	end

	pg.game.audio:triggerEvent("SFX_UI_TransferEgg_A1Tips")
end

function TransferEggItem:onSceneUnload()
	self:clearRunningList()
end

function TransferEggItem:GMPushData(data)
	data.state = data.param or 0
end

return TransferEggItem
