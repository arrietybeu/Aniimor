-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackScreen\\ScreenCtrlBase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ScreenCtrlBase")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local HotkeyConst = require("Const.HotkeyConst")
local ScreenCtrlBase = Class.LightClass("ScreenCtrlBase", UICtrl)
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local DialogueConst = require("Const.DialogueConst")
local BlackScreenData = require("Data.black_screen_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DialogueUtils = require("Utils.DialogueUtils")
local DialogueGraphConst = require("Const.DialogueGraphConst")

ScreenCtrlBase.messages = {
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.DIALOGUE_GRAPH_PLAYBACK_STATE_CHANGE] = {
		"onPlaybackStateChange",
		true
	}
}

function ScreenCtrlBase:checkCommonQuit()
	return false
end

function ScreenCtrlBase:addListener()
	function self.view.listUList.luaRenderItem(button, index, data)
		self:onRefreshDialogItem(button, index, data)
	end

	function self.view.btnSkipUButton.luaClick()
		self:startCloseScreen()
	end

	local function clickNext()
		self:onClickNextBtn()
	end

	self.view.btnNextUButton.luaClick = clickNext

	self.view.btnNextUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.InteractSouth, nil, clickNext)
	self.view.btnNextUButton:SetPCAction(HotkeyConst.INPUT_MAP_ACTION_KEY.InteractSouth, nil, clickNext)
end

function ScreenCtrlBase:refreshConsoleBarState()
	if self.enableConsoleBar == false then
		self.view.consoleBar:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, true)

		return
	end

	self.view.consoleBar:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, false)

	if self:isShowFinished() then
		self.view.btnNextUButton:SetHotkeyConsoleBar("CONSOLE_BAR_CLOSE", -1)
	else
		self.view.btnNextUButton:SetHotkeyConsoleBar("CONSOLE_BAR_CONTINUE", -1)
	end
end

function ScreenCtrlBase:onSceneLoaded()
	if self.notAutoCloseOnSceneLoaded then
		return
	end

	if self.isInDialogueGraph ~= true then
		if self:isShowFinished() then
			self:startCloseScreen()
		else
			self.markForClose = true
		end
	end
end

function ScreenCtrlBase:onPreShow(cmd)
	self.cmd = cmd

	if cmd == nil then
		return
	end

	self.canMoveNext = false

	self:onPlaybackStateChange(self.cmd:getPlaybackState())
end

function ScreenCtrlBase:onPlaybackStateChange(state)
	if state == DialogueGraphConst.PLAYBACK_STATE.NORMAL then
		self.isPlaying = false
	elseif state == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING then
		self.isPlaying = true

		self:moveNext()
	elseif state == DialogueGraphConst.PLAYBACK_STATE.SKIPPING then
		self.isPlaying = true

		self:moveNext()
	end
end

function ScreenCtrlBase:canAutoPlay()
	if self.isInDialogueGraph then
		return self:canAutoPlayInDialogueGraph() or pg.game.communication:isDialogueUnbreakable()
	end

	return pg.game.communication:canAutoPlay()
end

function ScreenCtrlBase:canAutoPlayInDialogueGraph()
	return self.cmd and self.cmd:isAutoPlaying()
end

function ScreenCtrlBase:moveNext()
	if self.canMoveNext and self.cacheCallback then
		self.cacheCallback(self)
	end
end

function ScreenCtrlBase:onShow()
	UICtrl.onShow(self)
end

function ScreenCtrlBase:onOpen(info)
	UICtrl.onOpen(self, info)

	self.startCloseCb = info.startCloseCb
	self.context = info.context
	self.blendTime = info.blendTime
	self.isInDialogueGraph = info.isDialogueGraph or false
	self.isDurationScreen = info.isDialogueGraph and info.id ~= nil or false
	self.needClose = info.needClose == true
	self.notAutoCloseOnSceneLoaded = info.notAutoCloseOnSceneLoaded or false

	if info.autoCloseByConfig == nil then
		self.autoCloseByConfig = true
	else
		self.autoCloseByConfig = info.autoCloseByConfig
	end

	self.outOrNot = info.outOrNot
	self.inOrNot = info.inOrNot
	self.outTime = info.outTime
	self.inTime = info.inTime

	LuaUIUtils.setUIViewVisible(self.view.keyConsoleULayoutBox, false)
	self:onPreShow(info.cmd)
	self:init()

	if self.isInDialogueGraph then
		self:onRefreshDurationScreen(info)
	else
		self:onRefreshScreen(info)
	end
end

function ScreenCtrlBase:init()
	self.curPage = 1
	self.dialogueId = nil
	self.curVoice = nil
	self.allDialogs = nil
	self.duration = nil
	self.curDialogIndex = 0
	self.playType = 0
	self.intervalTime = 1
	self.lockFinishTime = 0
	self.markForClose = false
	self.isClosingScreen = false
	self.markTime = Time.realtimeSinceStartup
	self.enableConsoleBar = true

	self.view.listUList:SetList()
	self:killAllTimers()
end

function ScreenCtrlBase:onRefreshScreen(param, finishInAni)
	self.screenConfig = BlackScreenData[param.id]

	if self.screenConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("黑幕配置不存在！", param.id)
		end

		self:startCloseScreen()

		return
	end

	LuaUIUtils.setUIViewVisible(self.view.layoutBtnRect, false)
	LuaUIUtils.setUIViewVisible(self.view.btnNextUButton, false)
	self.view.btnAuto:SetActive(false)
	LuaUIUtils.setUIViewVisible(self.view.keyConsoleULayoutBox, false)

	if finishInAni == nil and self.screenConfig.inOrNot == 1 then
		self.view.mainPanel:TryChangePage("ShowTxt", 1)
		UIUtils.PlayAnimation(self.view.mainAni, self.SCREEN_IN_ANI, function()
			self:onRefreshScreen(param, true)
		end)

		return
	end

	local backgroundVideo = self.screenConfig.backgroundVideo
	local backgroundPicture = self.screenConfig.backgroundPicture
	local dialogueId = self.screenConfig.dialogue

	if backgroundVideo then
		self.view.mainPanel:TryChangePage("Type", 2)

		self.view.videoPlayer.resID = backgroundVideo
	elseif backgroundPicture ~= nil then
		self.view.mainPanel:TryChangePage("Type", 1)

		self.view.picImg.url = backgroundPicture
	else
		self.view.mainPanel:TryChangePage("Type", 0)
	end

	self.view.mainPanel:TryChangePage("ShowTxt", dialogueId ~= nil and 0 or 1)

	self.allDialogs = Utils.deepCopyTable(NpcDialogueData[dialogueId])

	if self.allDialogs ~= nil then
		self.dialogueId = dialogueId
		self.playType = self.screenConfig.playType or 1
		self.intervalTime = self.screenConfig.intervalTime or 1

		self:startSwitchDialogueTimer(self.intervalTime, self.playType)
	end

	self.lockFinishTime = self.screenConfig.lockFinish

	if self.lockFinishTime ~= nil then
		self.lockFinishTimer = self:startTimer(function()
			LuaUIUtils.setUIViewVisible(self.view.btnNextUButton, true)

			if self.allDialogs == nil or self.curDialogIndex > #self.allDialogs then
				LuaUIUtils.setUIViewVisible(self.view.keyConsoleULayoutBox, true)
			end
		end, self.lockFinishTime, false)
	end

	self.lockEscTime = self.screenConfig.lockEscape

	if self.lockEscTime ~= nil then
		self.lockEscTimer = self:startTimer(function()
			LuaUIUtils.setUIViewVisible(self.view.layoutBtnRect, true)
		end, self.lockEscTime, false)
	end

	local autoCloseTime = self.screenConfig.autoCloseTime

	if autoCloseTime ~= nil and self.autoCloseByConfig then
		self.autoCloseTimer = self:startTimer(function()
			self:startCloseScreen()
		end, autoCloseTime, false)
	end
end

function ScreenCtrlBase:onClickNextBtn()
	if not self:isShowFinished() then
		if self:isInLockTime() then
			return
		end

		self:startSwitchDialogueTimer(self.intervalTime, self.playType)
	elseif self.isDurationScreen then
		self:startCloseScreen()
	elseif not self:isInLockTime() then
		self:startCloseScreen()
	end
end

function ScreenCtrlBase:onRefreshDurationScreen(param)
	LuaUIUtils.setUIViewVisible(self.view.layoutBtnRect, false)
	LuaUIUtils.setUIViewVisible(self.view.keyConsoleULayoutBox, false)

	local blendTime

	if self.blendTime ~= nil then
		blendTime = self.blendTime
	elseif self.inOrNot ~= nil then
		if self.inOrNot == 1 then
			blendTime = self.inTime
		end
	elseif self.screenConfig ~= nil and self.screenConfig.inOrNot == 1 then
		blendTime = self.screenConfig.inTime
	end

	if blendTime ~= nil and blendTime > 0.0001 and pg.game.globalTimeScale ~= 0 then
		blendTime = blendTime / pg.game.globalTimeScale

		local blendSpeed = self.SCREEN_IN_ANI_TIME / blendTime

		UIUtils.PlayAnimation(self.view.mainAni, self.SCREEN_IN_ANI, nil, blendSpeed)
	end

	self.lockFinishTime = param.skipTime or 0

	if param.id ~= nil and param.id ~= 0 then
		self.allDialogs = Utils.deepCopyTable(NpcDialogueData[param.id])
		self.dialogueId = param.id

		LuaUIUtils.setUIViewVisible(self.view.btnNextUButton, true)

		self.enableConsoleBar = true
	else
		LuaUIUtils.setUIViewVisible(self.view.btnNextUButton, false)
		self.view.consoleBar:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, true)

		self.enableConsoleBar = false
	end

	if self.allDialogs ~= nil then
		self.view.mainPanel:TryChangePage("ShowTxt", 0)

		self.curPage = 1
		self.curDialogIndex = 0
		self.duration = param.duration and param.duration or DialogueUtils.getDialogueDuration(self.curChatType, param.id)

		self:switchNextDialogue()
	else
		self.view.mainPanel:TryChangePage("ShowTxt", 1)
	end

	if self.allDialogs ~= nil then
		self.intervalTime = self.duration

		if param.intervalTime ~= nil and param.intervalTime > 0 then
			self.intervalTime = param.intervalTime
		end

		self.playType = param.playType or 0

		self:startSwitchDialogueTimer(self.intervalTime, self.playType)
	end

	if self.autoCloseByConfig and self.duration ~= nil and self.duration > 0 then
		local durationTime = self.duration

		if param.playType and param.playType == DialogueConst.PlayMode.TURN and self.allDialogs then
			durationTime = param.intervalTime * #self.allDialogs
		end

		self.delayToCloseTimer = self:startScaleTimer(function()
			if self:canAutoPlay() and self.needClose then
				self:startCloseScreen()
			end
		end, durationTime, false)
	end
end

function ScreenCtrlBase:startSwitchDialogueTimer(intervalTime, playType)
	self:killTickTimer()
	self:showDialog(playType)

	if self.tickTimer then
		self:killScaleTimer(self.tickTimer)
	end

	self.tickTimer = self:startScaleTimer(function()
		if self:canAutoPlay() or self.curDialogIndex == 0 or self.curDialogIndex == #self.allDialogs then
			self:showDialog(playType)
		end
	end, intervalTime, true)
end

function ScreenCtrlBase:showDialog(playType)
	if self.curDialogIndex > #self.allDialogs then
		if self:isInLockTime() then
			return
		end

		self:killTickTimer()

		if self:canClose() then
			self:startCloseScreen()
		end

		return
	end

	self.curDialogIndex = self.curDialogIndex + 1

	self:refreshConsoleBarState()
	self:startPlayVoice()

	if playType == DialogueConst.PlayMode.TURN then
		self:switchNextDialogue()
	else
		self:addNextDialog()
	end
end

function ScreenCtrlBase:switchNextDialogue()
	if self.curDialogIndex > #self.allDialogs then
		return
	end

	self.curDialog = self.allDialogs[self.curDialogIndex]

	if self.curDialog then
		self.view.listUList:SetList({
			self.curDialog
		})
	end
end

function ScreenCtrlBase:startPlayVoice()
	if self.curDialogIndex == 0 or self.dialogueId == nil then
		return
	end

	local communication = pg.game.communication

	if communication == nil or communication.isInDialogue == nil then
		return
	end

	local isSystemDriven = communication:isInDialogue() and communication.curDialogueId == self.dialogueId

	if isSystemDriven and self.curDialogIndex == 1 then
		return
	end

	if not isSystemDriven and communication:isInDialogue() then
		return
	end

	if isSystemDriven then
		communication:stopDialogVoice()
	else
		self:stopPlayVoice()
	end

	if self.allDialogs == nil or self.curDialogIndex > #self.allDialogs then
		return
	end

	local voice = DialogueUtils.getAudioName(self.dialogueId, self.curDialogIndex)

	self.curVoice = voice

	if voice == nil then
		return
	end

	local dialogInfo = NpcDialogueData[self.dialogueId][self.curDialogIndex]
	local isMyAudio = dialogInfo ~= nil and dialogInfo.npcId == 0

	communication:playDialogVoice(voice, isMyAudio)
end

function ScreenCtrlBase:stopPlayVoice()
	local communication = pg.game.communication

	if communication ~= nil and self.curVoice ~= nil and communication.curDialogVoice == self.curVoice then
		communication:stopDialogVoice()
	end

	self.curVoice = nil
end

function ScreenCtrlBase:addNextDialog()
	if self.curDialogIndex > #self.allDialogs or self.curDialogIndex == self.curPage * DialogueConst.DEFAULT_SCREEN_TURN_COUNT + 1 then
		if self.curDialogIndex > #self.allDialogs then
			LuaUIUtils.setUIViewVisible(self.view.btnNextUButton, true)

			return
		else
			self.curPage = self.curPage + 1

			self.view.listUList:SetList()
		end
	end

	local curDialog = self.allDialogs[self.curDialogIndex]

	if curDialog then
		self.view.listUList:AddElement(curDialog)
	end
end

function ScreenCtrlBase:isInLockTime()
	if self.markForClose then
		return false
	end

	return self.lockFinishTime ~= nil and Time.realtimeSinceStartup - self.markTime <= self.lockFinishTime
end

function ScreenCtrlBase:canClose()
	return self.markForClose or self.duration == nil or self.duration == 0
end

function ScreenCtrlBase:isShowFinished()
	return self.curDialogIndex == 0 or self.curDialogIndex > #self.allDialogs
end

function ScreenCtrlBase:startCloseScreen(blendOutTime)
	if self.view == nil then
		return
	end

	self:stopPlayVoice()

	self.isClosingScreen = true

	local blendTime

	if blendOutTime ~= nil then
		blendTime = blendOutTime
	elseif self.blendTime ~= nil then
		blendTime = self.blendTime
	elseif self.outOrNot ~= nil then
		if self.outOrNot == 1 then
			blendTime = self.outTime
		end
	elseif self.screenConfig ~= nil and self.screenConfig.outOrNot == 1 then
		blendTime = self.screenConfig.outTime
	end

	if blendTime ~= nil and blendTime > 0.0001 and pg.game.globalTimeScale ~= 0 and (self.cmd == nil or not self.cmd:isSkipping()) then
		blendTime = blendTime / pg.game.globalTimeScale

		local blendSpeed = self.SCREEN_OUT_ANI_TIME / blendTime

		UIUtils.PlayAnimation(self.view.mainAni, self.SCREEN_OUT_ANI, function()
			if self.isClosingScreen == true then
				self.isClosingScreen = false

				self:closeScreen()
			end
		end, blendSpeed)
	else
		self:closeScreen()
	end

	self:onStartClose()
end

function ScreenCtrlBase:closeScreen()
	self.isClosingScreen = false

	self:dismiss()

	if self.context and self.context.isRepeat then
		pg.me:finishRepeatEvent(self.context)
	end
end

function ScreenCtrlBase:onRefreshDialogItem(btn, index, data)
	local ani = btn.transform:GetComponent("Animation")

	ani:Play()

	local nameText = btn:Find("TxtName"):GetComponent("UBaseText")

	ClientTextUtils.setText(nameText, LuaUIUtils.getReplacedDialogueText(data.chat))
end

function ScreenCtrlBase:onStartClose()
	if self.startCloseCb then
		local cb = self.startCloseCb

		self.startCloseCb = nil

		cb()
	end
end

function ScreenCtrlBase:onDestroy()
	UICtrl.onDestroy(self)

	self.outOrNot = false
	self.inOrNot = false
	self.outTime = 0
	self.inTime = 0

	self:killAllTimers()
end

function ScreenCtrlBase:killAllTimers()
	self:killTickTimer()
	self:killLockFinishTimer()
	self:killLockEscTimer()
	self:killAutoCloseTimer()
	self:killDelayToCloseTimer()
end

function ScreenCtrlBase:killTickTimer()
	if self.tickTimer ~= nil then
		self:killScaleTimer(self.tickTimer)

		self.tickTimer = nil
	end
end

function ScreenCtrlBase:killLockFinishTimer()
	if self.lockFinishTimer ~= nil then
		self:killScaleTimer(self.lockFinishTimer)

		self.lockFinishTimer = nil
	end
end

function ScreenCtrlBase:killLockEscTimer()
	if self.lockEscTimer ~= nil then
		self:killScaleTimer(self.lockEscTimer)

		self.lockEscTimer = nil
	end
end

function ScreenCtrlBase:killAutoCloseTimer()
	if self.autoCloseTimer ~= nil then
		self:killTimer(self.autoCloseTimer)

		self.autoCloseTimer = nil
	end
end

function ScreenCtrlBase:killDelayToCloseTimer()
	if self.delayToCloseTimer ~= nil then
		self:killScaleTimer(self.delayToCloseTimer)

		self.delayToCloseTimer = nil
	end
end

function ScreenCtrlBase:isInDialogueGraphSystem()
	return self.isInDialogueGraph == true
end

function ScreenCtrlBase:isDialogueGraphScreen()
	return self.isDurationScreen == true
end

function ScreenCtrlBase:checkUIShowVirtualMouseCursor()
	return false
end

return ScreenCtrlBase
