-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\ItemRepeatObtainItem.lua

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
local ItemRepeatObtainItem = Class.LightClass("ItemRepeatObtainItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local PiecesItemSpecialData = require("Data.pieces_item_special_data")
local ItemUtils = require("Common.Utils.ItemUtils")

function ItemRepeatObtainItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ItemRepeatObtainItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ItemRepeatObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + 5

	self:addRunItem(data)
	self:initUContainer(data)
end

function ItemRepeatObtainItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ItemRepeatObtainItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ItemRepeatObtainItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function ItemRepeatObtainItem:initUContainer(data)
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

function ItemRepeatObtainItem:renderItem(item, data)
	if not data then
		return
	end

	local obtainType = data.type

	obtainType = obtainType or "item"

	local oc = item:GetComponent("ObjectReference")
	local ownNameText = oc:GetRefValue("ownName")
	local ownNumText = oc:GetRefValue("ownNum")
	local numText = oc:GetRefValue("itemNum")
	local itemNameText = oc:GetRefValue("itemName")
	local itemIcon = oc:GetRefValue("itemIcon")
	local propRepeatUButton = oc:GetRefValue("itemRepeatUButton")
	local keyHotKeyContent = oc:GetRefValue("keyHotKeyContent")
	local btnCloseTipsUSDFText = oc:GetRefValue("btnCloseTipsUSDFText")
	local btnGoTipsUSDFText = oc:GetRefValue("btnGoTipsUSDFText")

	ClientTextUtils.setText(btnCloseTipsUSDFText, pg.getGameString("CLOSE"))
	ClientTextUtils.setText(btnGoTipsUSDFText, pg.getGameString("GOTO"))
	LuaUIUtils.bindHotKey(keyHotKeyContent.gameObject, "Hud/ItemClose", self:guardRunCallback(data, function()
		self:clearRunningList()
	end, item))

	local keyCloseHotKeyContent = oc:GetRefValue("keyCloseHotKeyContent")

	if keyCloseHotKeyContent then
		keyCloseHotKeyContent:SetHotKeyPaths("Hud/ItemClose")
	end

	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")

	local ownNum, ownTitle, num, quality, icon, name, piecesId = "", "", "", 0, "", "", 0
	local cData

	if obtainType == "item" then
		cData = ItemData[tonumber(data.id)]

		if cData then
			ownNum = ItemUtils.getItemCountById(pg.me, data.id, true) or 0

			local showNum = data.num * (data.magnification or 1)

			if showNum > 0 then
				num = string.format("x%d", showNum)
			elseif showNum < 0 then
				num = string.format("-%d", showNum)
			end

			quality = cData.quality
			icon = cData.icon
			name = cData.itemName
			piecesId = cData.showIPContent or 0
		end

		local piecesTb = PiecesItemSpecialData[piecesId]

		quality = piecesTb and piecesTb.skin or quality

		self:setClickDetail(data, 0, piecesId)
	elseif obtainType == "pieces" then
		cData = PiecesItemSpecialData[data.piecesId]

		if cData then
			icon = cData.icon
			name = cData.name
			quality = cData.skin or 0

			self:setClickDetail(data, 1, data.piecesId)
			ClientTextUtils.setText(ownNameText, ownTitle)
		end
	elseif obtainType == "badge" then
		name = data.name
		icon = data.icon
		quality = data.quality

		ClientTextUtils.setText(ownNameText, pg.getGameString("HOMELAND_PLOT_UNLOCKED"))
		self:setBadgeClick(data)
	end

	itemIcon.url = LuaUIUtils.getIconByIconId(icon)

	ClientTextUtils.setText(itemNameText, pg.getLocalizationText(name))
	propRepeatUButton:TryChangePage("Quality", quality)
	ClientTextUtils.setText(ownNumText, ownNum)
	ClientTextUtils.setText(numText, num)
end

function ItemRepeatObtainItem:bindDetailLongPress(propRepeatUButton, hotKeyContent)
	hotKeyContent:SetHotKeyPaths("Hud/ItemDetail")
	LuaUIUtils.waitHotKeyContentObjectReference(self, hotKeyContent, function(objectReference)
		if IsNil(propRepeatUButton) or IsNil(hotKeyContent) then
			return
		end

		self:clearHotKeyBindByPath(hotKeyContent.gameObject, "Hud/ItemDetail")
		self:bindHotKeyItemLongPress(objectReference, {
			path = "Hud/ItemDetail",
			hotKeyObject = hotKeyContent.gameObject,
			longPressFunc = function()
				local isShow = self.uWidget and self.uWidget.gameObject.activeSelf

				if isShow and propRepeatUButton.luaClick then
					propRepeatUButton.luaClick()
				end
			end
		})
	end)
end

function ItemRepeatObtainItem:setClickDetail(data, openType, piecesId)
	local oc = self.uWidget.content:GetComponent("ObjectReference")
	local propRepeatUButton = oc:GetRefValue("itemRepeatUButton")
	local hotKeyContent = oc:GetRefValue("keyHotKeyContent")
	local piecesTb = PiecesItemSpecialData[tonumber(piecesId)]

	function propRepeatUButton.luaClick()
		if piecesTb and piecesTb.event and piecesTb.event > 0 then
			pg.me:doEvent(piecesTb.event)
		else
			local msg = {}

			if openType == 1 then
				msg.openType = openType
				msg.piecesId = data.piecesId
			elseif openType == 0 then
				msg = data
				msg.openType = openType
			end

			pg.global.ui:open(UIConst.UI_ID_PIECES_ITEM_PANEL, msg)
		end

		self:clearRunningList()
	end

	self:bindDetailLongPress(propRepeatUButton, hotKeyContent)
end

function ItemRepeatObtainItem:setBadgeClick(data)
	local oc = self.uWidget.content:GetComponent("ObjectReference")
	local propRepeatUButton = oc:GetRefValue("itemRepeatUButton")
	local hotKeyContent = oc:GetRefValue("keyHotKeyContent")

	function propRepeatUButton.luaClick()
		local clickCall = data.customClick

		if clickCall then
			clickCall()
		end

		data.customClick = nil

		self:clearRunningList()
	end

	self:bindDetailLongPress(propRepeatUButton, hotKeyContent)
end

function ItemRepeatObtainItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end
end

return ItemRepeatObtainItem
