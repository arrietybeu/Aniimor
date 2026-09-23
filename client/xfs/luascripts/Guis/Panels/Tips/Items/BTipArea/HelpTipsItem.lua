-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BTipArea\\HelpTipsItem.lua

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
local SysConfigData = require("Data.sys_config_data")
local GuidenceItemData = require("Data.guidence_item_data")
local HelpTipsItem = Class.LightClass("HelpTipsItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function HelpTipsItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function HelpTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function HelpTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.isHide = false
	data.duration = SysConfigData.helpTime or 5
	data.spaceTime = 1
	data.hideTime = Time.realSecondCache + data.duration
	data.endTime = Time.realSecondCache + data.duration + data.spaceTime

	self:addRunItem(data)
	self:initUContainer(data)
end

function HelpTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]
	local curTime = Time.realSecondCache

	if curTime < data.hideTime then
		return
	end

	if data.isHide == false then
		data.isHide = true

		self:setVisible(false)
	end

	if curTime < data.endTime then
		return
	end

	self:recycleToast(data)
end

function HelpTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function HelpTipsItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function HelpTipsItem:initUContainer(data)
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

function HelpTipsItem:renderItem(item, data)
	local helpId = data.helpId
	local oc = item:GetComponent("ObjectReference")
	local arrowUWidget = oc:GetRefValue("arrowUWidget")
	local contentText = oc:GetRefValue("contentText")
	local enterUButton = oc:GetRefValue("enterUButton")
	local keyHotKeyContent = oc:GetRefValue("keyHotKeyContent")
	local progressUProgress = oc:GetRefValue("progressUProgress")
	local keyUWidget = oc:GetRefValue("keyUWidget")

	data.hideTime = Time.realSecondCache + data.duration
	enterUButton.luaClick = self:guardRunCallback(data, function()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = helpId
		})
		self:clearRunningList()
	end, item)

	LuaUIUtils.bindHotKey(enterUButton.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadY, function()
		enterUButton.luaClick()
	end)
	LuaUIUtils.bindHotKey(enterUButton.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, self:guardRunCallback(data, function()
		self:clearRunningList()
	end, item))

	local guideData = GuidenceItemData[helpId]

	if not guideData then
		self:clearRunningList()

		return
	end

	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		ClientTextUtils.setText(contentText, pg.getFormatText(pg.getGameString("ENTRY_HELP_SIMPLE_MOBILE"), pg.getLocalizationText(guideData.name)))
		arrowUWidget:SetActiveFastest(true)
		keyUWidget:SetActiveFastest(false)
	else
		ClientTextUtils.setText(contentText, pg.getFormatText(pg.getGameString("ENTRY_HELP_SIMPLE"), pg.getLocalizationText(guideData.name)))
		arrowUWidget:SetActiveFastest(false)
		keyUWidget:SetActiveFastest(true)
		LuaUIUtils.bindHotKey(enterUButton.gameObject, "Hud/HelpTipEnter", self:guardRunCallback(data, function()
			enterUButton.luaClick()
		end, item), keyHotKeyContent)
	end

	progressUProgress.maxValue = 1
	progressUProgress.minValue = 0
	progressUProgress.value = 1

	progressUProgress:ProgressToValue(0, nil, data.duration, 0, CS.DG.Tweening.Ease.Linear)
end

function HelpTipsItem:bindEnterLongPress(path, enterUButton, keyHotKeyContent)
	keyHotKeyContent:SetHotKeyPaths(path)
	LuaUIUtils.waitHotKeyContentObjectReference(self, keyHotKeyContent, function(objectReference)
		if IsNil(enterUButton) or IsNil(keyHotKeyContent) then
			return
		end

		self:clearHotKeyBindByPath(keyHotKeyContent.gameObject, path)
		self:bindHotKeyItemLongPress(objectReference, {
			path = path,
			hotKeyObject = keyHotKeyContent.gameObject,
			longPressFunc = function()
				if pg.game.input:isUsingGamepad() and self.uWidget.gameObject.activeSelf and enterUButton.luaClick then
					enterUButton.luaClick()
				end
			end
		})
	end)
end

function HelpTipsItem:GMPushData(data)
	data.helpId = 101
end

function HelpTipsItem:onRecycleFinished(data, reason)
	if not self:isQueueEmpty() then
		self:setVisible(false)
	end
end

return HelpTipsItem
