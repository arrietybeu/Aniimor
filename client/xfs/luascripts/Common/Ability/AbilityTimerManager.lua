-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AbilityTimerManager.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local WeakRefCallbackHandle = require("Core.Common.WeakRefCallbackHandle")
local CombatLogger = require("Common.Ability.CombatLogger")
local Lume = require("Core.Common.lume")
local AbilityTimerManager = Class.LiteClass("AbilityTimerManager")

function AbilityTimerManager:ctor(space)
	self.timerIdGen = 100
	self.timerMap = {}
	self.lastTickTime = space:getGameTime() or 0

	local ServerConst
	local isGame = pg.component == "game"

	if isGame then
		ServerConst = require("GameServer.ServerConst")
	end

	local weakHandle = WeakRefCallbackHandle.new(function(self, space)
		if isGame and space.state == ServerConst.SpacePhase_DESTROY then
			self:destroy()

			return
		end

		local deltaTime = math.min(1, space:getGameTime() - self.lastTickTime)

		deltaTime = deltaTime * (pg.game and pg.game.baseTimeScale or 1)

		if deltaTime > 0 then
			self:tick(deltaTime)
		end

		self.lastTickTime = space:getGameTime()
	end, self, space)
	local timerId = TimerManager.addRepeatNextFrameCb(weakHandle)

	self.timerId = timerId

	weakHandle:setClearFun(function()
		TimerManager.delFrameCb(timerId)
	end)
end

function AbilityTimerManager:destroy()
	if self.timerId then
		TimerManager.delFrameCb(self.timerId)

		self.timerId = nil
	end

	Lume.clear(self.timerMap)
end

function AbilityTimerManager:tick(deltaTime)
	for timerId, handle in pairs(self.timerMap) do
		local result, info = xpcall(handle, debug.traceback, deltaTime)

		if not result then
			CombatLogger.logException(info)
		end

		if handle.refValid == false then
			CombatLogger.error("AbilityTimerManager handle ref is nil")

			self.timerMap[timerId] = nil
		end
	end
end

function AbilityTimerManager:addRepeatTimer(handle)
	local curTimerId = self.timerIdGen

	self.timerMap[self.timerIdGen] = handle
	self.timerIdGen = self.timerIdGen + 1

	if self.timerIdGen == math.maxInt then
		self.timerIdGen = 0
	end

	return curTimerId
end

function AbilityTimerManager:removeRepeatTimer(timerId)
	if timerId then
		self.timerMap[timerId] = nil
	end
end

return AbilityTimerManager
