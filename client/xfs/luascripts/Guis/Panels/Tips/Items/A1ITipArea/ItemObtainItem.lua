-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1ITipArea\\ItemObtainItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local HotkeyConst = require("Const.HotkeyConst")
local ItemObtainItem = Class.LightClass("ItemObtainItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function ItemObtainItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ItemObtainItem:checkRunState()
	if #self.runList <= 0 then
		local data = self:peek()

		if data and data.readyTime and Time.realSecondCache < data.readyTime then
			return TipAreaConst.ITEM_RUN_STATE.EMPTY
		end
	end

	return ItemObtainItem.super.checkRunState(self)
end

function ItemObtainItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ItemObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3.5)

	self:addRunItem(data)
	self:initUContainer(data)
end

function ItemObtainItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ItemObtainItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ItemObtainItem:initUContainer(data)
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

function ItemObtainItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local itemList = objectReference:GetRefValue("itemList")
	local textTitle = objectReference:GetRefValue("textTitle")
	local iAnim = item:GetComponent("UComponent")
	local title = string.isNilOrEmpty(data.title) and pg.getGameString("SHOP_GET") or data.title

	ClientTextUtils.setText(textTitle, title)

	itemList.luaRenderItem = self:guardRunCallback(data, function(button, index, subData)
		subData.id = subData.itemId
		subData.num = subData.itemCount

		LuaUIUtils.renderRewardItem(button, subData, tostring(subData.itemCount))

		button.luaClick = nil
	end, item)

	self:_sortItemList(data.itemList)
	itemList:SetList(data.itemList)
	iAnim:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
	pg.game.audio:playEvent("SFX_UI_ObtainedNoModalFullScreenItem")
end

function ItemObtainItem:_sortItemList(itemList)
	for _, itemData in ipairs(itemList) do
		LuaUIUtils.parseItemCfgData(itemData)
	end

	table.sort(itemList, function(a, b)
		local aQuality = a.quality or 0
		local bQuality = b.quality or 0

		if aQuality ~= bQuality then
			return bQuality < aQuality
		elseif a.itemId ~= b.itemId then
			return a.itemId < b.itemId
		else
			return (a.genID or 0) < (b.genID or 0)
		end
	end)
end

function ItemObtainItem:GMPushData(data)
	data.itemList = {
		{
			itemId = 1000,
			itemCount = 100
		},
		{
			itemId = 1001,
			itemCount = 200
		},
		{
			itemId = 1002,
			itemCount = 300
		},
		{
			itemId = 1003,
			itemCount = 400
		},
		{
			itemId = 1004,
			itemCount = 500
		},
		{
			itemId = 1005,
			itemCount = 600
		}
	}
end

return ItemObtainItem
