-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\A2TipArea\\DungeonTipsItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CatchRogueBuffData = require("Data.catch_rogue_buff_data")
local DungeonTipsItem = Class.LightClass("DungeonTipsItem", BaseQueueItem)
local Const = require("Common.Const.Const")

function DungeonTipsItem:onInit()
	self:setMaxLimit(3)

	self.uContainer = self.uWidget
end

function DungeonTipsItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function DungeonTipsItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function DungeonTipsItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function DungeonTipsItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function DungeonTipsItem:initUContainer(data)
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

function DungeonTipsItem:renderItem(item, data)
	local objectReference = item.transform:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local aniCom = objectReference:GetRefValue("rootAni")

	UIUtils.PlayAnimation(aniCom, "VX_Node_TipsGene_DungeonTips_In")

	local buffId = data.buffId
	local bData = CatchRogueBuffData[buffId]

	ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(bData.buffToastDesc))

	local icon = bData.buffUi

	iconUImage.url = icon
end

function DungeonTipsItem:GMPushData(data)
	data.countDownBeginTime = Time.realSecondCache
end

function DungeonTipsItem:playRecycleAnimation(data, target, exitEvent, complete)
	if IsNil(target) or target:CheckHasEvent(exitEvent) then
		BaseQueueItem.playRecycleAnimation(self, data, target, exitEvent, complete)
	else
		local refs = target.transform:GetComponent("ObjectReference")

		UIUtils.PlayAnimation(refs:GetRefValue("rootAni"), "VX_Node_TipsGene_DungeonTips_Out", complete)
	end
end

return DungeonTipsItem
