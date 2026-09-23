-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Decorators\\DecoratorLoop.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreDecoratorPhase = enums.EPreDecoratorPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local DecoratorCount = require("Common.AI.Behaviac.Node.Decorators.DecoratorCount")
local DecoratorLoop = functions.class("DecoratorLoop", DecoratorCount)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("DecoratorLoop", DecoratorLoop)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("DecoratorLoop", "DecoratorCount")

local _M = DecoratorLoop
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)

	self.m_bDoneWithinFrame = false
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

		if nameStr == "DoneWithinFrame" then
			self.m_bDoneWithinFrame = valueStr == "true"
		end
	end
end

function _M:update(agent, tick, childStatus)
	if self.m_bDoneWithinFrame then
		macros.BEHAVIAC_ASSERT(self.m_root, "[_M:update()] self.m_root")

		local num = self:getNum(tick)

		macros.BEHAVIAC_ASSERT(num >= 0, "[_M:update()] num >= 0")

		local status = EBTStatus.BT_INVALID

		for i = 1, num do
			status = tick:execWithChildStatus(self.m_root, agent, childStatus)

			if self.m_bDecorateWhenChildEnds then
				while status == EBTStatus.BT_RUNNING do
					status = _M.super.update(self, agent, tick, childStatus)
				end
			end

			if status == EBTStatus.BT_FAILURE then
				return EBTStatus.BT_FAILURE
			end
		end

		return EBTStatus.BT_SUCCESS
	end

	return _M.super.update(self, agent, tick, childStatus)
end

function _M:decorate(status, tick)
	local num = self:getNum(tick)

	if num > 0 then
		num = num - 1

		self:setNum(tick, num)

		if num == 0 then
			return EBTStatus.BT_SUCCESS
		end

		return EBTStatus.BT_RUNNING
	end

	if num == -1 then
		return EBTStatus.BT_RUNNING
	end

	macros.BEHAVIAC_ASSERT(num == 0, "[_M:decorate()] num == 0")

	return EBTStatus.BT_SUCCESS
end

return _M
