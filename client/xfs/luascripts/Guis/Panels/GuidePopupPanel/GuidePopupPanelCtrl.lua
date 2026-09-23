-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuidePopupPanel\\GuidePopupPanelCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local HotkeyConst = require("Const.HotkeyConst")
local GuideStepData = require("Data.guide_step_data")
local MessageName = require("Const.MessageName")
local GuideInputUtils = require("GameApp.Guide.GuideInputUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local logger = LoggerManager.getLogger("GuidePopupPanelCtrl")
local GuidePopupPanelCtrl = Class.LightClass("GuidePopupPanelCtrl", UICtrl)

GuidePopupPanelCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function GuidePopupPanelCtrl:onDestroy()
	self:clearGroupSkipHoldTimer()
	self:clearGroupSkipUI()
end

function GuidePopupPanelCtrl:onVisibleChange(visible)
	if visible then
		-- block empty
	else
		self:clearGroupSkipUI()
		self:clearGroupSkipHoldTimer()

		self.groupSkipGamepadPressConsumed = false
		self.groupSkipInputBlocked = false
		self.groupSkipEnabled = false
	end
end

function GuidePopupPanelCtrl:addListener()
	GuideInputUtils.addNextStepBindings(self, self.view.widget.gameObject, "guideNextStep", 100)

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and not pg.game.input:isUsingGamepad() then
			if self.groupSkipEnabled then
				self:onGroupSkipClick()

				return false
			end

			self:dismiss()
		end

		return true
	end

	GuideInputUtils.addGamepadGroupSkipBinding(self, self.view.widget.gameObject, "guideGroupSkipGamepadBind")

	function self.view.closeBtn.luaClick()
		self:dismiss()
	end

	LuaUIUtils.bindHotKey(self.view.hotKeyContent.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadB, function()
		if pg.game.input:isUsingGamepad() and not self.groupSkipInputBlocked then
			self:dismiss()
		end
	end)
	self.view.hotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel)
	ClientTextUtils.setText(self.view.btnTipsUText, pg.getGameString("CLOSE"))
end

function GuidePopupPanelCtrl:getNextStepActionPath()
	return GuideInputUtils.getNextStepActionPath()
end

function GuidePopupPanelCtrl:isNextStepEnabled()
	if self.stepInfo == nil or self.stepInfo.isNextStepEnabled == nil then
		return false
	end

	return self.stepInfo.isNextStepEnabled(GuideStepData[self.curGuideStepId])
end

function GuidePopupPanelCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function GuidePopupPanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:clearGroupSkipHoldTimer()
	self:clearGroupSkipUI()

	self.groupSkipGamepadPressConsumed = false
	self.stepInfo = info
	self.curGuideStepId = info.stepId
	self.groupSkipInputBlocked = info.canSkipGroup == true
	self.groupSkipEnabled = false

	LuaUIUtils.setUIViewVisible(self.view.closeBtn, self:isNextStepEnabled())
	self:refreshGuidePanel(self.curGuideStepId)
end

function GuidePopupPanelCtrl:onInputDeviceChanged(deviceType)
	self:refreshGroupSkipHotKeyContent()
end

function GuidePopupPanelCtrl:showGroupSkip()
	GuideInputUtils.showGroupSkip(self, logger, self.stepInfo and self.stepInfo.guideId, self.curGuideStepId)
end

function GuidePopupPanelCtrl:refreshGroupSkipHotKeyContent()
	GuideInputUtils.refreshGroupSkipHotKeyContent(self)
end

function GuidePopupPanelCtrl:getSkipGroupActionPath()
	return GuideInputUtils.getGroupSkipActionPath()
end

function GuidePopupPanelCtrl:clearGroupSkipUI()
	GuideInputUtils.clearGroupSkipUI(self)
end

function GuidePopupPanelCtrl:clearGroupSkipHoldTimer()
	GuideInputUtils.clearGroupSkipHoldTimer(self)
end

function GuidePopupPanelCtrl:onGroupSkipClick()
	return GuideInputUtils.onGroupSkipClick(self)
end

function GuidePopupPanelCtrl:refreshGuidePanel(guideStepId)
	local guideStepData = GuideStepData[guideStepId]

	ClientTextUtils.setText(self.view.titleUText, pg.getLocalizationText(guideStepData.title))
	ClientTextUtils.setText(self.view.txtScrollRect.content, pg.getLocalizationText(guideStepData.msg))

	local isCountDown, countDownTime = self:checkIsCountDown(guideStepData)

	if isCountDown then
		self.view.mainCom:TryChangePage("CountDown", 1)

		self.view.leftProgress.value = 1

		self.view.leftProgress:ProgressToValue(0, nil, countDownTime)

		self.view.rightProgress.value = 1

		self.view.rightProgress:ProgressToValue(0, nil, countDownTime)
	end

	if guideStepData.video ~= nil then
		self.view.picUImage:SetActiveFastest(false)

		self.view.videoPlayer.videoLoop = true
		self.view.videoPlayer.resID = guideStepData.video
	elseif guideStepData.pic ~= nil then
		self.view.picUImage:SetActiveFastest(true)

		self.view.picUImage.url = guideStepData.pic
	end
end

function GuidePopupPanelCtrl:checkIsCountDown(stepCfg)
	local isCountDown = stepCfg.stepOneTime ~= nil
	local countDownTime = stepCfg.stepOneTime
	local endChecks = stepCfg.endCheck

	if endChecks ~= nil then
		for i = 1, #endChecks do
			local endCheck = endChecks[i]

			if endCheck == Const.GUIDE_STEP_END.GSC_COUNT_DOWN then
				isCountDown = true

				local endCheckArgs = stepCfg.endCheckArg

				if endCheckArgs ~= nil then
					local endCheckArg = endCheckArgs[i]

					if endCheckArg ~= nil then
						if type(endCheckArg) == "table" then
							countDownTime = endCheckArg[1]

							break
						end

						countDownTime = endCheckArg
					end
				end

				break
			end
		end
	end

	return isCountDown, countDownTime
end

return GuidePopupPanelCtrl
