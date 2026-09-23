-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\SingleChild.lua

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
local Branch = require("Common.AI.Behaviac.Core.Branch")
local SingleChild = functions.class("SingleChild", Branch)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("SingleChild", SingleChild)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("SingleChild", "Branch")

local _M = SingleChild

function _M:ctor()
	_M.super.ctor(self)

	self.m_root = false
end

function _M:release()
	_M.super.release(self)

	if self.m_root then
		self.m_root:release()
	end

	self.m_root = false
end

function _M:init(tick)
	_M.super.init(self, tick)
	macros.BEHAVIAC_ASSERT(self:getChildrenCount() <= 1, "[_M:init()] node:getChildrenCount() <= 1")

	if self:getChildrenCount() == 1 then
		local childNode = self:getChild(1)

		childNode:init(tick)
	else
		Logging.error("[_M:init()] do nothing")
	end
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	if childFirst then
		if self.m_root then
			self.m_root:traverse(childFirst, handler, agent, tick, userData)
		end

		handler(self, agent, tick, userData)
	elseif handler(self, agent, userData) and self.m_root then
		self.m_root:traverse(childFirst, handler, agent, tick, userData)
	end
end

function _M:update(agent, tick, childStatus)
	if self.m_root then
		return tick:execWithChildStatus(self.m_root, agent, childStatus)
	end

	return EBTStatus.BT_FAILURE
end

function _M:addChild(child)
	_M.super.addChild(self, child)

	self.m_root = child
end

return _M
