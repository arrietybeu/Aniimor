-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestArrivalTip\\QuestArrivalTipCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local QuestArrivalTipCtrl = Class.LightClass("QuestArrivalTipCtrl", UICtrl)
local ArrivalTipData = require("Data.quest_arrival_tip_data")

function QuestArrivalTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function QuestArrivalTipCtrl:addListener()
	return
end

function QuestArrivalTipCtrl:onShow()
	return
end

function QuestArrivalTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:showPanel(info)
end

function QuestArrivalTipCtrl:showPanel(info)
	local data = ArrivalTipData[tonumber(info[1])]

	if not data or not data.position then
		return
	end

	local xOffset, yOffset = data.position[1] or 0, data.position[2] or 0
	local countDown = data.duration or 60

	self.updateTimer = self:startTimer(function()
		countDown = countDown - 1

		if countDown < 0 then
			self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			self:dismiss()
		end
	end, 1, true)

	local referenceResolution = pg.global.uiMgr.uiRootCanvasRt:GetComponent("RectTransform")
	local pos = Vector3(xOffset * referenceResolution.sizeDelta[1], yOffset * referenceResolution.sizeDelta[2], 0) or Vector3.zero

	self.view.widgetUWidget.transform.localPosition = pos

	ClientTextUtils.setText(self.view.textUBaseText, pg.getLocalizationText(data.desc))
end

function QuestArrivalTipCtrl:onHide()
	return
end

function QuestArrivalTipCtrl:clearUpdateTimer()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function QuestArrivalTipCtrl:checkCanOpen()
	return pg.me and pg.me.authority == Const.AUTHORITY_MASTER
end

function QuestArrivalTipCtrl:checkFadeOutHud()
	return false
end

function QuestArrivalTipCtrl:onDestroy()
	self:clearUpdateTimer()
	UICtrl.onDestroy(self)
end

function QuestArrivalTipCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return QuestArrivalTipCtrl
