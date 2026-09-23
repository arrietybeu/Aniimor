-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\WaitFramesState.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local ETransitionPhase = enums.ETransitionPhase
local State = require("Common.AI.Behaviac.Fsm.State")
local WaitFramesState = functions.class("WaitFramesState", State)
local _M = WaitFramesState
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_frames_p = 0
end

function _M:release()
	_M.super.release(self)
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "Frames" then
			local pParenthesis

			if type(valueStr) == "string" then
				pParenthesis = string.find(valueStr, "%(")
			end

			if not pParenthesis then
				self.m_frames_p = NodeParser.parseProperty(valueStr)
			else
				self.m_frames_p = NodeParser.parseMethod(valueStr)
			end
		end
	end
end

function _M:getFramesP(agent, tick)
	if self.m_frames_p then
		local frames = self.m_frames_p:getValue(agent, tick)

		if frames == 4294967295 then
			return -1
		end

		return frames
	end

	return 0
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setStart(tick, 0)
	self:setFrames(tick, 0)
end

function _M:onEnter(agent, tick)
	_M.super.onEnter(self, agent, tick)
	self:setStart(tick, common.getFrames())
	self:setFrames(tick, self:getFramesP(agent, tick) or 0)

	return self:getFrames(tick) > 0
end

function _M:update(agent, tick, childStatus)
	local frames = common.getFrames()

	if frames - self:getStart(tick) + 1 >= self:getFrames(tick) then
		_M.super.update(self, agent, tick, childStatus)

		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_RUNNING
end

function _M:setStart(tick, n)
	tick:setNodeMem("start", n, self)
end

function _M:getStart(tick)
	return tick:getNodeMem("start", self)
end

function _M:setFrames(tick, n)
	tick:setNodeMem("frames", n, self)
end

function _M:getFrames(tick)
	return tick:getNodeMem("frames", self)
end

return _M
