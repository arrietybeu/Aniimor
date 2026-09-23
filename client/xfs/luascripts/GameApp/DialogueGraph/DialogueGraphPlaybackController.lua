-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphPlaybackController.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DialogueGraphPlaybackController")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local SafeCallback = require("Core.Framework.SafeCallback")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphPlaybackController = Class.LightClass("DialogueGraphPlaybackController")

function DialogueGraphPlaybackController:ctor(cmd)
	self.cmd = cmd
	self.playbackPermission = 0
	self.skipFinishCallbacks = {}
	self.autoPlaySpeed = DialogueGraphUtils.getSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_PLAY_SPEED, 1)
end

function DialogueGraphPlaybackController:turnOn(arg)
	if self.destroyed then
		return
	end

	self.onSkipStartCallback = arg.onSkipStartCallback
	self.onSkipFinishCallback = arg.onSkipFinishCallback

	self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON, true)
	self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.AUTO_PLAY, true)
	self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP, true)

	local activeAutoPlay = DialogueGraphUtils.getSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_AUTO_PLAY, false)

	if activeAutoPlay then
		self:setState(DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING)
	else
		self:setState(DialogueGraphConst.PLAYBACK_STATE.NORMAL)
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_SKIP_PANEL, {
		cmd = self.cmd,
		skipMsg = self.skipMsg
	})
	pg.global.ui:show(UIConst.UI_ID_COMMON_SKIP_PANEL)
end

function DialogueGraphPlaybackController:turnOff(force)
	if not self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON) then
		return
	end

	local function onClose()
		DialogueGraphUtils.setGameTime(1)
		self:setState(DialogueGraphConst.PLAYBACK_STATE.NONE)
		self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON, false)
		self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP, false)
		pg.global.ui:close(UIConst.UI_ID_COMMON_SKIP_PANEL)
	end

	if self:isSkipping() then
		table.insert(self.skipFinishCallbacks, onClose)

		if force then
			self:stopSkip()
		end
	else
		onClose()
	end
end

function DialogueGraphPlaybackController:setPermission(permissonType, active)
	if active then
		self.playbackPermission = bit.bor(self.playbackPermission, permissonType)
	else
		self.playbackPermission = bit.band(self.playbackPermission, bit.bnot(permissonType))
	end

	facade:sendMsgToUI(MessageName.DIALOGUE_GRAPH_PLAYBACK_PERMISSION_CHANGE, permissonType)
end

function DialogueGraphPlaybackController:checkPlaybackPermission(permissonType)
	return bit.band(self.playbackPermission, permissonType) == permissonType
end

function DialogueGraphPlaybackController:setState(state)
	if self.playbackState == state then
		return
	end

	self.playbackState = state

	if self.cmd ~= nil and self.cmd.graphItem ~= nil then
		self.cmd.graphItem.playbackState = state
	end

	facade:sendMsgToUI(MessageName.DIALOGUE_GRAPH_PLAYBACK_STATE_CHANGE, state)
end

function DialogueGraphPlaybackController:checkPlaybackState(state)
	return self.playbackState == state
end

function DialogueGraphPlaybackController:enableSkipPermission()
	self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP, true)
end

function DialogueGraphPlaybackController:disableSkipPermission()
	self:setPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP, false)
end

function DialogueGraphPlaybackController:startSkip()
	local enable = self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP)

	if not enable or self.destroyed or self.stoppingSkip or self:isSkipping() or not self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON) then
		return false
	end

	self.skipFlowTriggered = false

	self:removeSkipTimer()
	table.clearArray(self.skipFinishCallbacks)
	DialogueGraphUtils.setGameTime(1)
	self:setState(DialogueGraphConst.PLAYBACK_STATE.SKIPPING)
	self:disableSkipPermission()

	if self.destroyed then
		return false
	end

	local result = self.cmd.compiledRunnerResult
	local runner = result and result.runner

	if runner and not runner:onGraphSkipping() then
		self.skipFlowTriggered = true

		self:stopSkip()

		return false
	end

	SafeCallback(self.cmd.resetNodeFuncTypeState, self.cmd)

	if self.onSkipStartCallback then
		SafeCallback(self.onSkipStartCallback)
	end

	if self.destroyed or not self:isSkipping() then
		return false
	end

	self.skipFlowTimer = TimerManager.addTimer(DialogueGraphConst.SKIP_FLOW_TRIGGER_DELAY, function()
		if self.destroyed then
			return
		end

		self.skipFlowTimer = nil

		if self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON) then
			self:triggerSkipFlow()
		end
	end)
	self.skipTimer = TimerManager.addTimer(DialogueGraphConst.SKIPPING_DURATION, function()
		if self.destroyed then
			return
		end

		self.skipTimer = nil

		if self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.TURN_ON) then
			self:stopSkip()
		end
	end)

	return true
end

function DialogueGraphPlaybackController:registSkipFinishCallback(callback)
	table.insert(self.skipFinishCallbacks, callback)
end

function DialogueGraphPlaybackController:triggerSkipFlow()
	if self.skipFlowTriggered or self.destroyed or not self:isSkipping() then
		return
	end

	self.skipFlowTriggered = true

	if self.onSkipFinishCallback then
		SafeCallback(self.onSkipFinishCallback)
	end
end

function DialogueGraphPlaybackController:stopSkip()
	if self.stoppingSkip or not self:isSkipping() then
		return
	end

	self.stoppingSkip = true

	self:removeSkipTimer()
	self:triggerSkipFlow()

	if self:isSkipping() then
		self:setState(DialogueGraphConst.PLAYBACK_STATE.NORMAL)
	end

	for i = 1, #self.skipFinishCallbacks do
		local cb = self.skipFinishCallbacks[i]

		if cb then
			SafeCallback(cb)
		end
	end

	table.clearArray(self.skipFinishCallbacks)

	self.stoppingSkip = false
end

function DialogueGraphPlaybackController:pause()
	self.isPaused = true

	DialogueGraphUtils.setGameTime(0)
end

function DialogueGraphPlaybackController:resume()
	self.isPaused = false

	DialogueGraphUtils.setGameTime(self:getPlaySpeed())
end

function DialogueGraphPlaybackController:removeSkipTimer()
	if self.skipFlowTimer ~= nil then
		TimerManager.removeTimer(self.skipFlowTimer)

		self.skipFlowTimer = nil
	end

	if self.skipTimer ~= nil then
		TimerManager.removeTimer(self.skipTimer)

		self.skipTimer = nil
	end
end

function DialogueGraphPlaybackController:startAutoPlay()
	local enable = self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.AUTO_PLAY)

	if not enable then
		return
	end

	self:setState(DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING)
	DialogueGraphUtils.setSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_AUTO_PLAY, true)
end

function DialogueGraphPlaybackController:stopAutoPlay()
	self:setState(DialogueGraphConst.PLAYBACK_STATE.NORMAL)
	DialogueGraphUtils.setSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_AUTO_PLAY, false)
	self:setPlaySpeed(1)
end

function DialogueGraphPlaybackController:isSkipping()
	return self.playbackState == DialogueGraphConst.PLAYBACK_STATE.SKIPPING
end

function DialogueGraphPlaybackController:isAutoPlaying()
	return (self.playbackState == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING or self.playbackState == DialogueGraphConst.PLAYBACK_STATE.SKIPPING) and not self.isPaused
end

function DialogueGraphPlaybackController:canSkip()
	return self:checkPlaybackPermission(DialogueGraphConst.PLAYBACK_PERMISSION.SKIP)
end

function DialogueGraphPlaybackController:setPlaySpeed(speed, force)
	if self.playSpeed ~= speed then
		self.playSpeed = speed

		DialogueGraphUtils.setGameTime(speed)

		if self.playbackState == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING and self.autoPlaySpeed ~= speed then
			self.autoPlaySpeed = speed

			DialogueGraphUtils.setSetting(DialogueGraphConst.SETTING_KEY.DIALOGUE_GRAPH_PLAY_SPEED, speed)
		end
	elseif force then
		DialogueGraphUtils.setGameTime(speed)
	end
end

function DialogueGraphPlaybackController:getPlaySpeed()
	if self.playbackState == DialogueGraphConst.PLAYBACK_STATE.AUTO_PLAYING then
		return self.autoPlaySpeed or 1
	end

	return self.playSpeed or 1
end

function DialogueGraphPlaybackController:destroy()
	self.destroyed = true
	self.skipFlowTriggered = true

	self:removeSkipTimer()
	self:turnOff(true)
end

return DialogueGraphPlaybackController
