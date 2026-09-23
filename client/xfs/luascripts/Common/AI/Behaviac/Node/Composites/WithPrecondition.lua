-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Node\\Composites\\WithPrecondition.lua

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
local Sequence = require("Common.AI.Behaviac.Node.Composites.Sequence")
local WithPrecondition = functions.class("WithPrecondition", Sequence)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("WithPrecondition", WithPrecondition)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("WithPrecondition", "Sequence")

local _M = WithPrecondition
local NodeParser = require("Common.AI.Behaviac.Parser.NodeParser")

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:preconditionNode()
	macros.BEHAVIAC_ASSERT(#self.m_children == 2, "[_M:preconditionNode()] #self.m_children == 2")

	return self.m_children[1]
end

function _M:actionNode()
	macros.BEHAVIAC_ASSERT(#self.m_children == 2, "[_M:actionNode()] #self.m_children == 2")

	return self.m_children[2]
end

function _M:isWithPrecondition()
	return true
end

function _M:onEnter(agent, tick)
	local pParent = self:getParent()

	macros.BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoop(), "[_M:onEnter()] pParent:isSelectorLoop")

	return true
end

function _M:onExit(agent, tick, status)
	local pParent = self:getParent()

	macros.BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoop(), "[_M:onExit()] pParent:isSelectorLoop")

	return true
end

function _M:updateCurrent(agent, tick, childStatus)
	return self:update(agent, tick, childStatus)
end

function _M:update(agent, tick, childStatus)
	local pParent = self.getParent()

	macros.BEHAVIAC_ASSERT(pParent and pParent:isSelectorLoop(), "[_M:update()] pParent:isSelectorLoop")
	macros.BEHAVIAC_ASSERT(#self.m_children == 2, "[_M:update()] #self.m_children == 2")
	macros.BEHAVIAC_ASSERT(false)

	return EBTStatus.BT_RUNNING
end

return _M
