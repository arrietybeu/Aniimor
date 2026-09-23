-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\GainCropItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local ItemData = require("Data.item_data")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local GainCropItem = Class.LightClass("GainCropItem", BaseQueueItem)

function GainCropItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function GainCropItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function GainCropItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.secondCache + (data.duration or 5)

	self:addRunItem(data)
	self:initUContainer(data)
end

function GainCropItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.secondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function GainCropItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Custom1)
	end
end

function GainCropItem:recycleToast(data, callback)
	if not data.removing then
		data.recycleCloseCallback = callback
	end

	local event = data.isClick and CS.XGUI.EInvokeTime.Custom2 or CS.XGUI.EInvokeTime.Custom1

	self:requestRecycle(data, false, event)
end

function GainCropItem:destroyContent(data, callback)
	if callback then
		data.recycleCloseCallback = callback
	end

	self:completeRecycle(data)
end

function GainCropItem:initUContainer(data)
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

function GainCropItem:renderItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local itemCfg = ItemData[data.itemId]
	local titleTxt = oc:GetRefValue("titleTxt")

	if titleTxt then
		local itemName = itemCfg and ClientTextUtils.getLocalizationText(itemCfg.itemName) or ""

		ClientTextUtils.setText(titleTxt, pg.getFormatText(pg.getGameString("HOMELAND_VARIATION_PLANT_GET"), itemName))
	end

	local iconCrop = oc:GetRefValue("iconCrop")

	if iconCrop and itemCfg then
		iconCrop.url = LuaUIUtils.getIconByIconId(itemCfg.icon)
	end

	local iconVXCrop = oc:GetRefValue("iconVXCrop")

	if iconVXCrop and itemCfg then
		iconVXCrop.url = LuaUIUtils.getIconByIconId(itemCfg.icon)
	end

	local goBtn = oc:GetRefValue("goBtn")

	if goBtn then
		goBtn.luaClick = self:guardRunCallback(data, function()
			self:openHomeBookCropDetail(data)
		end, item)
	end

	local keyHotKeyContent = oc:GetRefValue("keyHotKeyContent")

	if goBtn then
		LuaUIUtils.bindHotKey(goBtn.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm, self:guardRunCallback(data, function()
			self:openHomeBookCropDetail(data)
		end, item), keyHotKeyContent, 100)
	end
end

function GainCropItem:openHomeBookCropDetail(data)
	data.isClick = true

	self:recycleToast(data, function()
		if not HomeBookDataUtils.getEntity(data.itemId) then
			pg.global.ui:open(UIConst.UI_ID_HOME_BOOK)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_CROP_DETAIL, {
			entryId = data.itemId
		})
	end)
end

function GainCropItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end

	local callback = data.recycleCloseCallback

	data.recycleCloseCallback = nil

	if callback and not self:isRecycleCancelled(reason) then
		callback()
	end
end

return GainCropItem
