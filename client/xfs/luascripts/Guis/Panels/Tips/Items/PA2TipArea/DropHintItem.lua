-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\PA2TipArea\\DropHintItem.lua

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
local DropHintItem = Class.LightClass("DropHintItem", BaseQueueItem)
local Const = require("Common.Const.Const")
local ID_DROP_HINT_HIDE_MOVE = "DropHintHideMove"

function DropHintItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function DropHintItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function DropHintItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	self:setVisible(true)

	local data = self:dequeue()

	data.endTime = Time.realSecondCache + (data.duration or 3.46)

	self:addRunItem(data)
	self:initUContainer(data)
end

function DropHintItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.realSecondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function DropHintItem:hideById(id)
	local param = self:firstRunItem()

	if param and param.uniqueId == id then
		self:recycleToast(param)
	end
end

function DropHintItem:hide()
	self:clearAllData(true)
end

function DropHintItem:onClearRunningList(force)
	local param = self:firstRunItem()

	if param then
		self:recycleToast(param, force)
	end
end

function DropHintItem:initUContainer(data)
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

function DropHintItem:renderItem(item, data)
	local objectReference = item:GetComponent("ObjectReference")
	local progressUProgress = objectReference:GetRefValue("progressUProgress")
	local progressRightUProgress = objectReference:GetRefValue("progressRightUProgress")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local rectTransform = item.rectTransform

	ClientTextUtils.setText(txtNameUBaseText, data.str)

	progressUProgress.value = 1
	progressRightUProgress.value = 1

	progressRightUProgress:ProgressToValue(0, nil, data.progressDuration)
	progressUProgress:ProgressToValue(0, self:guardRunCallback(data, function()
		if data.removing then
			return
		end

		if data.targetPos then
			local screenPos = UIUtils.WorldToScreenPoint(data.targetPos)
			local _, pos = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform.parent, screenPos, CS.XGUI.UWidget.uiCamera)

			DoTweenAnimMgr.AnchorPositionMove(rectTransform, LuaUIUtils.TweenId(ID_DROP_HINT_HIDE_MOVE), pos, 0.8, 0, CS.DG.Tweening.Ease.OutCubic, nil)
		end
	end, item), data.progressDuration)
end

function DropHintItem:onRecycleStarted(data, target)
	if data.tickTimer then
		self:killTimer(data.tickTimer)

		data.tickTimer = nil
	end
end

function DropHintItem:onRecycleFinished(data, reason)
	self:setVisible(false)
end

return DropHintItem
