-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AbilityObject.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local EventBus = require("Common.Ability.Buff.EventBus")
local CombatLogger = require("Common.Ability.CombatLogger")
local lume = require("Core.Common.lume")
local AbilityObject = Class.LiteClass("AbilityObject")

function AbilityObject:ctor()
	self:resetAbilityObjectData()

	self.observer = nil
end

function AbilityObject:resetAbilityObjectData()
	if not self.cacheValMap then
		self.cacheValMap = {}
	else
		lume.clear(self.cacheValMap)
	end

	if not self.exitCallbacks then
		self.exitCallbacks = {}
	else
		lume.clear(self.exitCallbacks)
	end

	if not self.timerMap then
		self.timerMap = {}
	else
		lume.clear(self.timerMap)
	end
end

function AbilityObject:setOwner(owner)
	self.owner = owner
end

function AbilityObject:clearObject()
	for _, fun in ipairs(self.exitCallbacks) do
		local isOk, result = xpcall(fun, debug.traceback)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.logException("Ability clear error", result)
		end
	end

	if self.observer then
		self.observer:unlistenAll()
	end

	for _, timerId in pairs(self.timerMap) do
		self.owner:removeEntityTimer(timerId)
	end

	self:resetAbilityObjectData()

	if self.combatContext then
		self.owner:returnCombatContext(self.combatContext, true)
	end
end

function AbilityObject:getObserver()
	if self.observer == nil then
		self.observer = EventBus.EventObserver()
	end

	return self.observer
end

function AbilityObject:addExitCallback(fun)
	self.exitCallbacks[#self.exitCallbacks + 1] = fun
end

function AbilityObject:addTimer(key, delay, fun)
	if self.timerMap[key] then
		self.owner:removeEntityTimer(self.timerMap[key])
	end

	self.timerMap[key] = self.owner:addEntityTimer(delay, fun)
end

function AbilityObject:removeTimer(key)
	if self.timerMap[key] then
		self.owner:removeEntityTimer(self.timerMap[key])

		self.timerMap[key] = nil
	end
end

return AbilityObject
