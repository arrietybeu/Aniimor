-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\AIAssistant\\AIAssistantCtrl.lua

local Class = require("Core.Framework.Class")
local DialogueBaseCtrl = require("Guis.Panels.DialogueModule.DialogueBaseCtrl")
local UIConst = require("Const.UIConst")
local AIAssistantCtrl = Class.LightClass("AIAssistantCtrl", DialogueBaseCtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

function AIAssistantCtrl:addListener()
	AIAssistantCtrl.super.addListener(self)

	function self.view.nextBtn.luaClick()
		return self:onNextBtnClick()
	end
end

function AIAssistantCtrl:tryStopTypewriterEffect()
	if self.view and self.view.contentTxt:IsRunningTypewriter() then
		self.view.contentTxt:TryFinishedStoryText()

		return true
	end

	return false
end

function AIAssistantCtrl:canTriggerNextBtn()
	return self.callback and pg.game.communication:getEnableStopUI()
end

function AIAssistantCtrl:startClose()
	self:onHide()

	if not self.closeTimer then
		if self.view then
			self.view.mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
			self:startCloseTimer()
		else
			self:dismiss()
		end
	end
end

function AIAssistantCtrl:startCloseTimer()
	self.closeTimer = self:startScaleTimer(function()
		self:dismiss()

		self.closeTimer = nil
	end, 0.6, false)
end

function AIAssistantCtrl:removeCloseTimer()
	if self.closeTimer then
		self:killScaleTimer(self.closeTimer)

		self.closeTimer = nil
	end
end

function AIAssistantCtrl:showContent(name, content, duration, callback)
	if self.closeTimer and self.view then
		self.view.mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end

	self:removeCloseTimer()

	if not self.view then
		if callback then
			callback()
		end

		return
	end

	self.callback = callback
	duration = duration or 3

	self:removeMoveNextTimer()

	if duration ~= -1 then
		self:startMoveNextTimer(duration, callback)
	end

	if not pg.global.ui:checkUIShow(UIConst.UI_ID_AI_ASSISTANT) then
		pg.game.audio:playEvent("UI_NoviceGuide_DialogueAI")
	end

	self:show()
	ClientTextUtils.setText(self.view.titleNameText, name)
	ClientTextUtils.setText(self.view.contentTxt, content)

	if not pg.game.communication:getEnableTypewriter() and self.view.contentTxt:IsRunningTypewriter() then
		self.view.contentTxt:TryFinishedStoryText()
	end
end

function AIAssistantCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return AIAssistantCtrl
