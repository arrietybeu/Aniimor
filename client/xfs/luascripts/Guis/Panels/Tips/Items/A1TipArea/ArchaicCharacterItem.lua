-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\ArchaicCharacterItem.lua

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
local ArchaicCharacterItem = Class.LightClass("ArchaicCharacterItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function ArchaicCharacterItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function ArchaicCharacterItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function ArchaicCharacterItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function ArchaicCharacterItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function ArchaicCharacterItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function ArchaicCharacterItem:hideById(id)
	local param = self:firstRunItem()

	if param and (param.uniqueId == id or not param.uniqueId) then
		self:recycleToast(param)
	end
end

function ArchaicCharacterItem:initUContainer(data)
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

local ARCHAIC_ICON_PREFIX = "$UI_Icon_ArchaicCharacter_"

function ArchaicCharacterItem:renderItem(item, data)
	local noticeKey = data.noticeKey
	local characters = data.characters
	local charList = {}

	for i = 1, #characters do
		charList[i] = {
			char = characters:sub(i, i)
		}
	end

	local objectReference = item:GetComponent("ObjectReference")
	local textBase = objectReference:GetRefValue("textUBaseText")
	local textVfx = objectReference:GetRefValue("textVXUBaseText")
	local characterList = objectReference:GetRefValue("listUList")
	local widgetAnimation = objectReference:GetRefValue("widgetAnimation")

	characterList.luaRenderItem = self:guardRunCallback(data, function(button, index, itemData)
		local char = itemData.char
		local objRef = button:GetComponent("ObjectReference")
		local icon = objRef:GetRefValue("iconUImage")
		local itemWidgetAnimation = objRef:GetRefValue("widgetAnimation")
		local temp = string.format("%s%s.png", ARCHAIC_ICON_PREFIX, char)

		icon.forceSyncLoad = true
		icon.url = temp

		UIUtils.PlayAnimation(itemWidgetAnimation, "VX_Node_ArchaicChaacter_Item_In", function()
			return
		end)
	end, item)

	characterList:SetList(charList)
	UIUtils.PlayAnimation(widgetAnimation, "VX_Pb_Underground_ArchaicCharacter_Tips_In", function()
		return
	end)
	pg.game.audio:playEvent("SFX_Temple_ThemeUI_Show")
	ClientTextUtils.setText(textBase, pg.getLocalizationText(pg.getGameString(noticeKey)))
	ClientTextUtils.setText(textVfx, pg.getLocalizationText(pg.getGameString(noticeKey)))
end

return ArchaicCharacterItem
