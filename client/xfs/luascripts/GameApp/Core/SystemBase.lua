-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Core\\SystemBase.lua

local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local SystemBase = Class.LightClass("SystemBase")

function SystemBase:ctor(name)
	self.name = name
	self._timerIds = {}
end

function SystemBase:getName()
	return self.name
end

function SystemBase:tick()
	self:onTick()
end

function SystemBase:initSystem()
	self:onInit()
	self:registAllMessage()
end

function SystemBase:clear()
	self:onClear()
end

function SystemBase:destroy()
	self:onDestroy()
	self:unregistAllMessage()
	self:killAllTimer()
end

function SystemBase:onCtor()
	return
end

function SystemBase:onInit()
	return
end

function SystemBase:onClear()
	return
end

function SystemBase:onDestroy()
	return
end

function SystemBase:onTick()
	return
end

function SystemBase:beforeAnimation()
	return
end

function SystemBase:onWorldSceneDestroy(sceneId)
	return
end

function SystemBase:getMessageBindMap()
	return nil
end

function SystemBase:registAllMessage()
	local messageDict = self:getMessageBindMap()

	if not messageDict then
		return
	end

	for messageIndex, funcName in raw_next, messageDict do
		facade:RegisterSysCommand(messageIndex, self.name, funcName)
	end
end

function SystemBase:unregistAllMessage()
	local messageDict = self:getMessageBindMap()

	if not messageDict then
		return
	end

	for messageIndex in raw_next, messageDict do
		facade:RemoveSysCommand(messageIndex, self.name)
	end
end

function SystemBase:startTimer(func, delay, loop)
	local timerId

	loop = loop or false

	if loop then
		timerId = TimerManager.addRepeatTimer(delay, func)
	else
		self:checkAndCleanFinishedTimers()

		timerId = TimerManager.addTimer(delay, func)
	end

	self._timerIds[timerId] = loop

	return timerId
end

function SystemBase:checkAndCleanFinishedTimers()
	for timerId, isLoop in raw_next, self._timerIds do
		if not isLoop and not TimerManager.checkTimerValid(timerId) then
			self._timerIds[timerId] = nil
		end
	end
end

function SystemBase:killTimer(timerId)
	TimerManager.removeTimer(timerId)

	self._timerIds[timerId] = nil
end

function SystemBase:killAllTimer()
	for timerId, loop in raw_next, self._timerIds or {} do
		TimerManager.removeTimer(timerId)
	end

	self._timerIds = {}
end

function SystemBase:onBackToLogin()
	return
end

function SystemBase:onLogin()
	return
end

function SystemBase:onConnected()
	return
end

function SystemBase:onDisconnected()
	return
end

function SystemBase:onMemoryWarning()
	return
end

function SystemBase:onPlayerInit(player)
	return
end

function SystemBase:onPlayerDestroy(player)
	return
end

function SystemBase:onSceneLoaded(sceneId, sceneName)
	return
end

function SystemBase:onSceneUnloaded(sceneId, sceneName)
	return
end

function SystemBase:onSceneReset(sceneId, sceneName)
	self:onSceneLoaded(sceneId, sceneName)
end

function SystemBase:onSpaceCreated(space)
	return
end

function SystemBase:onSpaceDestroy(space)
	return
end

return SystemBase
