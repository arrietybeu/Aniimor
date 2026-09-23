-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TimeSwitch\\TimeSwitchCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local SysConfigData = require("Data.sys_config_data")
local TimeSwitchCtrl = Class.LightClass("TimeSwitchCtrl", UICtrl)

TimeSwitchCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local TIME_BTN = {
	[Const.TimePeriod.Morning] = "btnMatinal",
	[Const.TimePeriod.Day] = "btnNoon",
	[Const.TimePeriod.Dusk] = "btnDusk",
	[Const.TimePeriod.Night] = "btnNight"
}
local TIME_NAME = {
	[Const.TimePeriod.Morning] = "TIME_MORNING",
	[Const.TimePeriod.Day] = "TIME_NOON",
	[Const.TimePeriod.Dusk] = "TIME_EVENING",
	[Const.TimePeriod.Night] = "TIME_NIGHT"
}
local ANI_NAME = {
	DUSK_2_NIGHT = "VX_Pb_TimeSwitch_Switch_3",
	NOON_2_DUSK = "VX_Pb_TimeSwitch_Switch_2",
	NIGHT_2_MORNING = "VX_Pb_TimeSwitch_Switch_4",
	MORNING_2_NOON = "VX_Pb_TimeSwitch_Switch_1"
}
local ANI_NAME_LOOP = {
	[Const.TimePeriod.Morning] = ANI_NAME.MORNING_2_NOON,
	[Const.TimePeriod.Day] = ANI_NAME.NOON_2_DUSK,
	[Const.TimePeriod.Dusk] = ANI_NAME.DUSK_2_NIGHT,
	[Const.TimePeriod.Night] = ANI_NAME.NIGHT_2_MORNING
}

function TimeSwitchCtrl:ctor()
	UICtrl.ctor(self)
end

function TimeSwitchCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function TimeSwitchCtrl:checkCanOpen(showNotice, info)
	if info and info.animOnly then
		return true
	end

	return UICtrl.checkCanOpen(self, showNotice, info)
end

function TimeSwitchCtrl:onOpen(info)
	self._hasSwitch = false
	self.animOnly = info and info.animOnly or false

	if self.animOnly then
		self.endTimePeriod = info.endTimePeriod
		self.onBlackCb = info.onBlack
		self.startTimePeriod = pg.timePeriod

		self:setSelectVisible(false)
		self.view.uIPbTimeSwitchUComponent:TryChangePage("TimeFrame", self.startTimePeriod - 1)
		self:setTimeBtnState(self.startTimePeriod)
		self:startSwitchAnim()

		return
	end

	self.endTimePeriod = nil
	self.onBlackCb = nil
	self.startTimePeriod = nil

	self:setSelectVisible(true)

	local timePeriod = pg.timePeriod

	self.view.uIPbTimeSwitchUComponent:TryChangePage("TimeFrame", timePeriod - 1 or 0)
	ClientTextUtils.setText(self.view.txtClose, pg.getGameString("TIME_CLOSE"))
	pg.game.audio:triggerEvent("SFX_UI_TimePass01")
	ClientTextUtils.setText(self.view.txtCurTimeDesc, string.format(pg.getGameString("TIME_DISPLAY"), pg.getGameString(TIME_NAME[timePeriod])))
	self:setTimeBtnState(timePeriod)
end

function TimeSwitchCtrl:startSwitchAnim()
	if self._hasSwitch then
		return
	end

	self._hasSwitch = true

	local startTimePeriod = self.startTimePeriod or pg.timePeriod

	self.view[TIME_BTN[startTimePeriod]]:TryChangePage("state", 0)
	UIUtils.PlayAnimation(self.view.panelAnimation, "VX_Pb_TimeSwitch_Switch_Constant")
	pg.game.audio:triggerEvent("SFX_UI_TimePass02")

	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	self.timerId = self:startTimer(CallbackHandler(self, "_onBlack"), 0.5)
end

function TimeSwitchCtrl:setSelectVisible(visible)
	for _, btnName in ipairs(TIME_BTN) do
		if self.view[btnName] then
			self.view[btnName]:SetActive(visible)
		end
	end

	self.view.btnCloseUButton:SetActive(visible)
	self.view.txtCurTimeDesc:SetActive(visible)
	self.view.txtClose:SetActive(visible)
end

function TimeSwitchCtrl:setTimeBtnState(timePeriod)
	for timePeriodIndex, btnName in ipairs(TIME_BTN) do
		if self.view[btnName] then
			self.view[btnName]:SetActive(true)
			self.view[btnName]:TryChangePage("state", timePeriod == timePeriodIndex and 1 or 0)
		end
	end
end

function TimeSwitchCtrl:onDestroy()
	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	UICtrl.onDestroy(self)
end

function TimeSwitchCtrl:checkFadeOutHud()
	return false
end

function TimeSwitchCtrl:checkCommonQuit()
	if self.animOnly then
		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function TimeSwitchCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if self.animOnly then
			return
		end

		if inputInfo.phase == "Performed" then
			self:_closeSelf()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		if self.animOnly then
			return
		end

		self:onCloseBtnClick()
	end

	for timePeriodIndex, btnName in ipairs(TIME_BTN) do
		local button = self.view[btnName]

		if button then
			function button.luaClick()
				if self.animOnly then
					return
				end

				self:choseTimeConfirm(timePeriodIndex)
			end
		end
	end
end

function TimeSwitchCtrl:onCloseBtnClick()
	self:_closeSelf()
end

function TimeSwitchCtrl:_omOutAnimEnd()
	self:dismiss()

	if not self.animOnly then
		pg.global.ui:closeImmediately(UIConst.UI_ID_FUNC_MENU)
	end
end

function TimeSwitchCtrl:_closeSelf(isChangeTime)
	UIUtils.PlayAnimation(self.view.panelAnimation, isChangeTime and "VX_Pb_TimeSwitch_Switch_Change_Out" or "VX_Ani_TimeSwitch_Out")

	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	local animTime = self.view.panelAnimation:GetClip(isChangeTime and "VX_Pb_TimeSwitch_Switch_Change_Out" or "VX_Ani_TimeSwitch_Out").length

	self.timerId = self:startTimer(CallbackHandler(self, "_omOutAnimEnd"), animTime)
end

function TimeSwitchCtrl:setChangeAnim()
	local timePeriod = self.startTimePeriod or pg.timePeriod
	local allTime = 0
	local changeList = {}

	if timePeriod > self.endTimePeriod then
		for i = timePeriod, #ANI_NAME_LOOP do
			table.insert(changeList, ANI_NAME_LOOP[i])

			local animTime = self.view.animTimeChange:GetClip(ANI_NAME_LOOP[i]).length

			allTime = allTime + animTime
		end

		for i = 1, self.endTimePeriod - 1 do
			table.insert(changeList, ANI_NAME_LOOP[i])

			local animTime = self.view.animTimeChange:GetClip(ANI_NAME_LOOP[i]).length

			allTime = allTime + animTime
		end
	else
		for i = timePeriod, self.endTimePeriod - 1 do
			table.insert(changeList, ANI_NAME_LOOP[i])

			local animTime = self.view.animTimeChange:GetClip(ANI_NAME_LOOP[i]).length

			allTime = allTime + animTime
		end
	end

	self:loopShowAnim(changeList, 1)
end

function TimeSwitchCtrl:loopShowAnim(changeList, index)
	if index > #changeList then
		self:_onTimeChangeAnimEnd()

		return
	end

	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	local speed = SysConfigData.timeSwitchAnimRate and SysConfigData.timeSwitchAnimRate[#changeList] or 1

	UIUtils.PlayAnimation(self.view.animTimeChange, changeList[index], function()
		index = index + 1

		self:loopShowAnim(changeList, index)
	end, speed)
end

function TimeSwitchCtrl:_onTimeChangeAnimEnd()
	self.view[TIME_BTN[self.endTimePeriod]]:TryChangePage("state", 1)

	if self.timerId then
		self:killTimer(self.timerId)

		self.timerId = nil
	end

	self.timerId = self:startTimer(CallbackHandler(self, "_onBtnChangeEnd"), 0.5)
end

function TimeSwitchCtrl:_onBtnChangeEnd()
	self:_closeSelf(true)
end

function TimeSwitchCtrl:_onBlack()
	if self.animOnly then
		if self.onBlackCb then
			local cb = self.onBlackCb

			self.onBlackCb = nil

			cb()
		end
	else
		pg.game.camera:cancelBlendToFixedWithTarget(0)
		pg.space:timePeriodSwitch(self.endTimePeriod)
	end

	self:setChangeAnim()
end

function TimeSwitchCtrl:choseTimeConfirm(endTimePeriod)
	if endTimePeriod == pg.timePeriod then
		pg.global.ui.tips:showTextTip(pg.getGameString("TIME_SWITCH_SAME"))

		return
	end

	self.endTimePeriod = endTimePeriod

	ClientUtils.showConfirmRaw(string.format(pg.getGameString("TIME_SWITCH"), pg.getGameString(TIME_NAME[endTimePeriod])), nil, function()
		self:startSwitchAnim()
	end)
end

function TimeSwitchCtrl:onInputDeviceChanged(deviceType)
	return
end

return TimeSwitchCtrl
