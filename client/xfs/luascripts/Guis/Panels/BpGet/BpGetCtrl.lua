-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpGet\\BpGetCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpGetCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local BattlePassData = require("Data.event_battlepass_data")
local BpGetCtrl = Class.LightClass("BpGetCtrl", UICtrl)
local AUTO_DISMISS_DELAY = 3

BpGetCtrl.messages = {}

local GEAR_TO_INFO_TEXT = {
	[ActivityConst.BattlePassGear.Pay1] = "BATTLEPASS_PURCHASE_UNLOCKED1",
	[ActivityConst.BattlePassGear.Pay2] = "BATTLEPASS_PURCHASE_UNLOCKED2"
}
local GEAR_TO_DEFAULT_TYPE = {
	[ActivityConst.BattlePassGear.Pay1] = 3,
	[ActivityConst.BattlePassGear.Pay2] = 4
}
local GEAR_TO_NEXT_TYPE = {
	[ActivityConst.BattlePassGear.Pay1] = 1,
	[ActivityConst.BattlePassGear.Pay2] = 2
}

function BpGetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BpGetCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnNext.luaClick()
		if self.view.rootUComponent then
			self.view.rootUComponent:TryChangePage("Type", GEAR_TO_NEXT_TYPE[self._gear])
		end

		self:_startDismissTimer()
	end
end

function BpGetCtrl:_stopDismissTimer()
	if not self._dismissTimer then
		return
	end

	self:killTimer(self._dismissTimer)

	self._dismissTimer = nil
end

function BpGetCtrl:_startDismissTimer()
	if self._dismissTimer then
		return
	end

	self._dismissTimer = self:startTimer(function()
		self._dismissTimer = nil

		self:dismiss()
	end, AUTO_DISMISS_DELAY)
end

function BpGetCtrl:onDestroy()
	self:_stopDismissTimer()
	UICtrl.onDestroy(self)
end

function BpGetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._gear = info and info.gear or ActivityConst.BattlePassGear.Pay1
	self._name = info and info.name or nil
end

function BpGetCtrl:onShow()
	local view = self.view
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not self._name and bpData then
		if self._gear == ActivityConst.BattlePassGear.Pay2 then
			self._name = bpData.tierName2 or ""
		else
			self._name = bpData.tierName1 or ""
		end
	end

	if view.rootUComponent then
		view.rootUComponent:TryChangePage("Type", GEAR_TO_DEFAULT_TYPE[self._gear])
	end

	if view.btnNext then
		view.btnNext.gameObject:SetActiveEx(true)
	end

	if view.nameTxt then
		ClientTextUtils.setText(view.nameTxt, self._name and pg.getLocalizationText(self._name) or "")
	end

	if view.InfoText then
		ClientTextUtils.setText(view.InfoText, pg.getGameString(GEAR_TO_INFO_TEXT[self._gear] or "BATTLEPASS_PURCHASE_UNLOCKED1"))
	end

	if self._gear == ActivityConst.BattlePassGear.Pay2 then
		pg.game.audio:triggerEvent("SFX_BP_PURCHASE_128")
	else
		pg.game.audio:triggerEvent("SFX_BP_PURCHASE_68")
	end
end

function BpGetCtrl:onHide()
	return
end

return BpGetCtrl
