-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\FSM\\FiniteStateMachine.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("FiniteStateMachine")
local FiniteStateMachine = Class.LiteClass("FiniteStateMachine", State)

function FiniteStateMachine:ctor(stateEnum)
	State.ctor(self, stateEnum)

	self._curState = nil
	self._stateMap = {}
	self._transitionMap = {}
	self._anyStateTransition2StateMap = {}
	self._stateTransition2AnyStateMap = {}
	self._startStateName = nil
	self._lock = false
	self._nextStateName = nil
	self._pendingStateName = nil
end

function FiniteStateMachine:start(startStateName)
	self._curState = self._stateMap[startStateName]

	if self._curState then
		self._startStateName = startStateName

		self._curState:onEnter(self)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(string.format("FiniteStateMachine start failed,%s %s state not exist", self.className, startStateName))
	end
end

function FiniteStateMachine:stop()
	if self._curState then
		self._curState:onExit(self)
	end

	self._curState = nil
	self._stateMap = nil
	self._transitionMap = nil
	self._startStateName = nil
	self._nextStateName = nil
end

function FiniteStateMachine:setStartName(startStateName)
	self._startStateName = startStateName
end

function FiniteStateMachine:onExit(...)
	if self._curState then
		self._curState:onExit(self, ...)
	end

	self:onChangeState(self._curStateName, nil)

	self._curState = nil
	self._nextStateName = nil
end

function FiniteStateMachine:onEnter(...)
	local enterState = self._pendingStateName or self._startStateName

	if enterState then
		self._curState = self._stateMap[enterState]

		self._curState:onEnter(self, ...)
		self:onChangeState(nil, enterState)
	end

	self._pendingStateName = nil
end

function FiniteStateMachine:setPendingStateName(stateName)
	if self._stateMap[stateName] then
		self._pendingStateName = stateName
	end
end

function FiniteStateMachine:getStateByName(stateName)
	return self._stateMap[stateName]
end

function FiniteStateMachine:onRun(...)
	if self._curState then
		self._lock = true

		self._curState:onRun(self, ...)

		self._lock = false
	end

	if self._nextStateName then
		self:_changeState(self._nextStateName)

		self._nextStateName = nil
	end
end

function FiniteStateMachine:onChangeState(oldStateName, newStateName)
	return
end

function FiniteStateMachine:reset()
	if self:checkIsCurState(self._startStateName) then
		return
	end

	self:transitionTo(self._startStateName)
end

function FiniteStateMachine:addState(state)
	self._stateMap[state:getStateName()] = state
end

function FiniteStateMachine:addTransitionByStateName(fromStateName, toStateName)
	if not self._transitionMap[fromStateName] then
		self._transitionMap[fromStateName] = {}
	end

	self._transitionMap[fromStateName][toStateName] = true
end

function FiniteStateMachine:addState2AnyStateTransition(stateName)
	self._stateTransition2AnyStateMap[stateName] = true
end

function FiniteStateMachine:addAnyState2StateTransition(stateName)
	self._anyStateTransition2StateMap[stateName] = true
end

function FiniteStateMachine:transitionTo(stateName)
	local curStateName = self._curState:getStateName()

	if curStateName == stateName then
		return true
	end

	if not self._stateTransition2AnyStateMap[curStateName] and not self._anyStateTransition2StateMap[stateName] and not self._transitionMap[curStateName][stateName] then
		return false
	end

	if self._lock then
		self._nextStateName = stateName
	else
		self:_changeState(stateName)
	end

	return true
end

function FiniteStateMachine:_changeState(newStateName)
	local nextState = self._stateMap[newStateName]
	local oldState = self._curState
	local oldStateName = oldState:getStateName()

	oldState:onExit(self, nextState)

	self._curState = nextState

	nextState:onEnter(self, oldState)
	self:onChangeState(oldStateName, newStateName)
end

function FiniteStateMachine:checkIsCurState(stateName)
	local curState = self._curState

	if curState == nil then
		return false
	end

	return curState:getStateName() == stateName
end

return FiniteStateMachine
