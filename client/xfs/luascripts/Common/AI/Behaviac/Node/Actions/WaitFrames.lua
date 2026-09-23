-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Actions\\WaitFrames.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local Leaf = require("Common.AI.Behaviac.Core.Leaf")
local WaitFrames = functions.class("WaitFrames", Leaf)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("WaitFrames", WaitFrames)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("WaitFrames", "Leaf")

local _M = WaitFrames
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_frames_p = false
end

function _M:release()
	_M.super.release(self)

	self.m_frames_p = false
end

function _M:onLoading(version, agentType, properties)
	_M.super.onLoading(self)

	local nameStr, valueStr, checkstr

	for _, p in ipairs(properties) do
		nameStr = p[1]
		valueStr = p[2]

		local valuetype = {}

		checkstr = valueStr

		if valueStr.func ~= nil then
			checkstr = valueStr.func
		else
			valuetype = valueStr.type
			checkstr = valueStr.value
		end

		if nameStr == "Frames" then
			local pParenthesis

			if type(checkstr) == "string" then
				pParenthesis = string.find(checkstr, "%(")
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

function _M:isWaitFrames()
	return true
end

function _M:init(tick)
	self:setStart(tick, 0)
	self:setFrames(tick, 0)
end

function _M:onEnter(agent, tick)
	self:setStart(tick, common.getFrames())
	self:setFrames(tick, self:getFramesP(agent, tick) or 0)

	return self:getFrames(tick) >= 0
end

function _M:onExit(agent, tick)
	return true
end

function _M:update(agent, tick, childStatus)
	local frames = common.getFrames()

	if frames - self:getStart(tick) + 1 >= self:getFrames(tick) then
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
