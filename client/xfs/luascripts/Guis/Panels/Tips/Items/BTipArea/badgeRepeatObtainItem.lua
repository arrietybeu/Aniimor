-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\badgeRepeatObtainItem.lua

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
local GO_ACTION_KEY = "Hud/ItemDetail"
local CANCEL_ACTION_KEY = "Hud/ItemClose"
local badgeRepeatObtainItem = Class.LightClass("badgeRepeatObtainItem", BaseQueueItem)

function badgeRepeatObtainItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function badgeRepeatObtainItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function badgeRepeatObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + 8

	self:addRunItem(data)
	self:initUContainer(data)
end

function badgeRepeatObtainItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function badgeRepeatObtainItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function badgeRepeatObtainItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function badgeRepeatObtainItem:initUContainer(data)
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

function badgeRepeatObtainItem:renderItem(item, data)
	if not data then
		return
	end

	local objectReference = item:GetComponent("ObjectReference")
	local itemName = objectReference:GetRefValue("itemName")
	local itemNum = objectReference:GetRefValue("itemNum")
	local ownName = objectReference:GetRefValue("ownName")
	local ownNumText = objectReference:GetRefValue("ownNum")
	local imgBgUImage = objectReference:GetRefValue("imgBgUImage")
	local imBgGlow = objectReference:GetRefValue("imBgGlow")
	local itemIcon = objectReference:GetRefValue("itemIcon")
	local itemRepeatUButton = objectReference:GetRefValue("itemRepeatUButton")
	local itemRepeatAni = objectReference:GetRefValue("itemRepeatAni")
	local listKeyUList = objectReference:GetRefValue("listKeyUList")
	local isMobile = pg.global.ui:runPlatformByMobile()
	local canShowKeyList = not isMobile

	listKeyUList:SetActiveFastest(canShowKeyList)

	if canShowKeyList then
		local keyListData = {
			{
				actionKey = CANCEL_ACTION_KEY,
				label = pg.getGameString("CLOSE")
			},
			{
				actionKey = GO_ACTION_KEY,
				hotKeyObject = self.uWidget.gameObject,
				longPressFunc = self:guardRunCallback(data, function()
					if itemRepeatUButton.luaClick then
						itemRepeatUButton.luaClick()
					end
				end, item),
				label = pg.getGameString("GOTO")
			}
		}

		listKeyUList.luaRenderItem = self:guardRunCallback(data, function(button, index, d)
			self:renderKeyItem(button, index, d)
		end, item)

		listKeyUList:SetList(keyListData)
	end

	ClientTextUtils.setText(itemName, pg.getGameString("UNLOCK_BADGE"))
	LuaUIUtils.bindHotKey(item.gameObject, "Hud/ItemClose", self:guardRunCallback(data, function()
		self:clearRunningList()
	end, item))
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)

	itemIcon.url = data.icon

	ClientTextUtils.setText(ownName, pg.getLocalizationText(data.name))
	item:TryChangePage("Quality", data.quality)
	self:setBadgeClick(data)
	pg.game.audio:playEvent("SFX_UI_BadgeSystem_BadgeUnlock")
end

function badgeRepeatObtainItem:renderKeyItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local btnTipsUText = objectReference:GetRefValue("btnTipsUText")

	keyHotKeyContent:SetHotKeyPaths(data.actionKey)
	ClientTextUtils.setText(btnTipsUText, data.label)
	self:bindHotKeyItemLongPress(objectReference, data)
end

function badgeRepeatObtainItem:setBadgeClick(data)
	local oc = self.uWidget.content:GetComponent("ObjectReference")
	local propRepeatUButton = oc:GetRefValue("itemRepeatUButton")

	function propRepeatUButton.luaClick()
		local clickCall = data.customClick

		if clickCall then
			clickCall()
		end

		data.customClick = nil

		self:clearRunningList()
	end
end

function badgeRepeatObtainItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end
end

return badgeRepeatObtainItem
