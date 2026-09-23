-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A1TipArea\\BossFirstKillItem.lua

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
local BossFirstKillItem = Class.LightClass("BossFirstKillItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function BossFirstKillItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function BossFirstKillItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function BossFirstKillItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function BossFirstKillItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function BossFirstKillItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function BossFirstKillItem:initUContainer(data)
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

function BossFirstKillItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local iconTipsUImage = objectReference:GetRefValue("iconTipsUImage")
	local vXIconTipsUImage = objectReference:GetRefValue("vXIconTipsUImage")
	local titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	local firstKillAnimation = objectReference:GetRefValue("firstKillAnimation")

	iconTipsUImage.url = data.icon
	vXIconTipsUImage.url = data.icon

	ClientTextUtils.setText(titleUSDFText, pg.getLocalizationText(data.title))
	firstKillAnimation:Play("Vx_Pb_POI_Tips_New_FirstKill")
end

return BossFirstKillItem
