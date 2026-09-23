-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Fsm\\StartCondition.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local ETransitionPhase = enums.ETransitionPhase
local Precondition = require("Common.AI.Behaviac.Attachments.Precondition")
local EffectorConfig = require("Common.AI.Behaviac.Attachments.EffectorConfig")
local StartCondition = functions.class("StartCondition", Precondition)
local _M = StartCondition

function _M:ctor()
	_M.super.ctor(self)
	self:setTargetStateId(-1)

	self.m_effectors = {}
end

function _M:release()
	_M.super.release(self)
	self:setTargetStateId(-1)
end

function _M:onLoading(version, agentType, properties)
	if self.m_loadAttachment == true then
		local effectorConfig = EffectorConfig.new()

		if effectorConfig:parse(properties) == true then
			self.m_effectors[#self.m_effectors + 1] = effectorConfig
		end
	end

	_M.super.onLoading(self, version, agentType, properties)

	local nameStr, valueStr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		if nameStr == "TargetFSMNodeId" then
			self:setTargetStateId(tonumber(valueStr))
		end
	end
end

function _M:applyEffects(agent, tick, phase)
	for _, effector in ipairs(self.m_effectors) do
		effector:evaluate(agent, tick)
	end
end

function _M:getTargetStateId()
	return self.m_targetId
end

function _M:setTargetStateId(targetId)
	self.m_targetId = targetId
end

return _M
