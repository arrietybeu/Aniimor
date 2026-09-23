-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\SpeechComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SpeechComponent = Class.LightClass("SpeechComponent", UIComponent)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local MAX_RECORD_TIME = 30
local LAST_COUNTDOWN_TIME = 10

local function formatDuration(seconds)
	local min = math.floor(seconds / 60)
	local sec = seconds % 60

	return string.format("%02d:%02d", min, sec)
end

function SpeechComponent:onCtor()
	self.recordTimerId = nil
	self.recordElapsed = 0
	self.recording = false
	self.recordStopping = false
	self.lastCountdownStarted = false
	self.listeningStateListener = nil
end

function SpeechComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnTransitionUButton = objectReference:GetRefValue("buttonTransitionUButton")
	self.btnListenUButton = objectReference:GetRefValue("buttonListenUButton")
	self.btnCancelUButton = objectReference:GetRefValue("buttonCanelUButton")
	self.btnRecordUButton = objectReference:GetRefValue("buttonRecordUButton")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.btnCancelInnerUButton = objectReference:GetRefValue("buttonCancelUButton")
	self.btnSendUButton = objectReference:GetRefValue("buttonSendUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.textDurationUSDFText = objectReference:GetRefValue("textDurationUSDFText")
	self.btnVoiceUButton = objectReference:GetRefValue("voiceUButton")
	self.countUSDFText = objectReference:GetRefValue("countUSDFText")
	self.textSendTipUSDFText = objectReference:GetRefValue("textSendTipUSDFText")
end

function SpeechComponent:initView()
	self.countDownUCountDown:SetActive(true)
	self:initText()
	self:addListener()
	self:updateRecordDurationText(0)
	self:stopLastCountDown()
	self:bindListeningState()
	self:refreshSpeechPanel(true)
end

function SpeechComponent:addListener()
	function self.btnTransitionUButton.luaHover()
		self.waitTriggerFunc = self.transition

		self.btnTransitionUButton:TryChangePage("button", 3)
	end

	function self.btnCancelUButton.luaHover()
		self.waitTriggerFunc = self.cancel

		self.btnCancelUButton:TryChangePage("button", 3)
	end

	function self.btnListenUButton.luaHover()
		self.waitTriggerFunc = self.listen

		self.btnListenUButton:TryChangePage("button", 3)
	end

	function self.btnTransitionUButton.luaUnhover()
		self.waitTriggerFunc = nil

		self.btnTransitionUButton:TryChangePage("button", 0)
	end

	function self.btnCancelUButton.luaUnhover()
		self.waitTriggerFunc = nil

		self.btnCancelUButton:TryChangePage("button", 0)
	end

	function self.btnListenUButton.luaUnhover()
		self.waitTriggerFunc = nil

		self.btnListenUButton:TryChangePage("button", 0)
	end

	function self.btnCancelInnerUButton.luaClick()
		if self.recording then
			self.waitTriggerFunc = self.cancel

			self:handleTriggerFunc()
		else
			self:refreshSpeechPanel(false)
		end
	end

	function self.btnSendUButton.luaClick()
		if self.recording then
			self.waitTriggerFunc = self.send

			self:handleTriggerFunc()
		else
			local curAudioFile = pg.game.speech:getCurAudioFile()

			self:send(curAudioFile.fileID, curAudioFile.filePath, curAudioFile.fileSize, curAudioFile.duration, curAudioFile.text, curAudioFile.auditResult)
		end
	end

	function self.btnVoiceUButton.luaClick()
		pg.game.speech:playCurLocalAudioFile()
	end

	function self.btnRecordUButton.luaHover()
		self.view.voicePanelUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end

	function self.btnRecordUButton.luaUnhover()
		self.view.voicePanelUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	local function innerBindFunc(button, actionPath, bindName, func)
		local bind = KeyBindingPro.GetOrAddKeyBindingByName(button.gameObject, bindName)

		bind.isVirtual = true
		bind.priority = -1
		bind.actionPath = actionPath

		function bind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				func()
			end
		end
	end

	innerBindFunc(self.btnTransitionUButton, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft, "transitionBind", function()
		self.waitTriggerFunc = self.transition

		self:handleTriggerFunc()
	end)
	innerBindFunc(self.btnListenUButton, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadUp, "listenBind", function()
		self.waitTriggerFunc = self.listen

		self:handleTriggerFunc()
	end)
	innerBindFunc(self.btnCancelUButton, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight, "cancelBind", function()
		self.waitTriggerFunc = self.cancel

		self:handleTriggerFunc()
	end)
	innerBindFunc(self.btnCancelInnerUButton, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast, "cancelInnderBind", function()
		self.btnCancelInnerUButton.luaClick()
	end)
	innerBindFunc(self.btnSendUButton, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, "sendBind", function()
		self.btnSendUButton.luaClick()
	end)
end

function SpeechComponent:initText()
	ClientTextUtils.setText(self.textSendTipUSDFText, pg.getGameString("CHAT_RELEASE_SEND_SPEECH"))
end

function SpeechComponent:handleTriggerFunc()
	if self.recordStopping or not self.recording then
		return
	end

	self.recordStopping = true

	self:clearRecordTimers()

	local triggerFunc = self.waitTriggerFunc

	self.waitTriggerFunc = nil

	local stopAccepted = pg.global.gmeManager:StopRecording(function(fileID, filePath, fileSize, duration, text, auditResult, code, tooShort)
		pg.game.speech:onRecordStopped(fileID, filePath, fileSize, duration, text, auditResult, code, tooShort)

		self.recording = false
		self.recordStopping = false

		if not self.view then
			return
		end

		if fileID then
			if triggerFunc then
				triggerFunc(self, fileID, filePath, fileSize, duration, text, auditResult)
			else
				self:send(fileID, filePath, fileSize, duration, text, auditResult)
			end
		else
			self:refreshSpeechPanel(false)
		end
	end)

	if stopAccepted ~= true then
		self.recording = false
		self.recordStopping = false
	end
end

function SpeechComponent:transition(fileID, filePath, fileSize, duration, text, auditResult)
	self:refreshSpeechPanel(false)

	if not string.isNilOrEmpty(text) then
		self.view.bottomSendUComponent:TryChangePage("Switch", 0)
		self.view.chatUInputField:SetTextWithoutNotify(text)
	end
end

function SpeechComponent:cancel(fileID, filePath, fileSize, duration, text, auditResult)
	self:refreshSpeechPanel(false)
end

function SpeechComponent:listen(fileID, filePath, fileSize, duration, text, auditResult)
	self.view.widget:TryChangePage("VoiceState", 1)
	ClientTextUtils.setText(self.txtNameUSDFText, math.round(duration / 1000) .. "\"")
end

function SpeechComponent:send(fileID, filePath, fileSize, duration, text, auditResult)
	pg.game.speech:sendRecordedAudioMessage(fileID, filePath, duration, text, auditResult)
	self:refreshSpeechPanel(false)
end

function SpeechComponent:refreshSpeechPanel(visible)
	pg.game.speech:clearCurLocalAudioFile()
	pg.game.speech:stopPlayAudioFile()

	if visible then
		local languageCode = pg.game.chat:getCurrentGmeLanguageCode()

		self.recording = pg.global.gmeManager:StartRecording(languageCode, languageCode) == true
		self.recordStopping = false

		if self.recording then
			self:startRecordTiming()
		else
			visible = false
		end
	else
		self.recording = false
		self.recordStopping = false

		self:clearRecordTimers()
		self:updateRecordDurationText(0)
	end

	self.view.widget:TryChangePage("VoiceState", 0)
	self.uWidget:SetActive(visible)
end

function SpeechComponent:cancelRecording()
	self.waitTriggerFunc = nil

	self:clearRecordTimers()

	if self.recording or self.recordStopping then
		pg.global.gmeManager:CancelRecording()
	end

	self.recording = false
	self.recordStopping = false
	self.lastCountdownStarted = false

	pg.game.speech:clearCurLocalAudioFile()
	pg.game.speech:stopPlayAudioFile()

	if self.view and self.view.widget then
		self.view.widget:TryChangePage("VoiceState", 0)
	end

	if self.uWidget then
		self.uWidget:SetActive(false)
	end

	self:updateRecordDurationText(0)
end

function SpeechComponent:startRecordTiming()
	self:clearRecordTimers()

	self.recordElapsed = 0
	self.lastCountdownStarted = false

	self:updateRecordDurationText(0)

	self.recordTimerId = self:startTimer(function()
		self:onRecordTick()
	end, 1, true)
end

function SpeechComponent:onRecordTick()
	if not self.recording or self.recordStopping then
		return
	end

	self.recordElapsed = self.recordElapsed + 1

	self:updateRecordDurationText(self.recordElapsed)

	local remainTime = MAX_RECORD_TIME - self.recordElapsed

	if not self.lastCountdownStarted and remainTime == LAST_COUNTDOWN_TIME then
		self.lastCountdownStarted = true

		if self.countDownUCountDown then
			self.countDownUCountDown:Play(LAST_COUNTDOWN_TIME)
		end
	end

	if remainTime <= 0 then
		self.waitTriggerFunc = self.listen

		self:handleTriggerFunc()
	end
end

function SpeechComponent:refreshListeningState(isListening)
	local gameStr = isListening and "AUDIO_LISTENING" or "CLICK_TO_LISTEN_AUDIO"

	if isListening then
		self.view.voicePanelUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	else
		self.view.voicePanelUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end

	ClientTextUtils.setText(self.textDurationUSDFText, pg.getGameString(gameStr))
end

function SpeechComponent:updateRecordDurationText(seconds)
	ClientTextUtils.setText(self.countUSDFText, pg.getFormatText(pg.getGameString("AUDIO_RECORDING_TIME"), seconds))
end

function SpeechComponent:clearRecordTimers()
	if self.recordTimerId then
		self:killTimer(self.recordTimerId)

		self.recordTimerId = nil
	end

	self:stopLastCountDown()
end

function SpeechComponent:stopLastCountDown()
	self.countDownUCountDown:Stop()
end

function SpeechComponent:bindListeningState()
	self:unbindListeningState()

	function self.listeningStateListener(isListening)
		if not self.view then
			return
		end

		self:refreshListeningState(isListening)
	end

	pg.game.speech:addListeningStateListener(self.listeningStateListener)
end

function SpeechComponent:unbindListeningState()
	if self.listeningStateListener then
		pg.game.speech:removeListeningStateListener(self.listeningStateListener)

		self.listeningStateListener = nil
	end
end

function SpeechComponent:onDestroy()
	self:cancelRecording()
	self:unbindListeningState()
end

return SpeechComponent
