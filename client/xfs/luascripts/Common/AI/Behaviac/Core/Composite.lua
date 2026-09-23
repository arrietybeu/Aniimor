-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Composite.lua

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
local Composite = functions.class("Composite", Branch)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Composite", Composite)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Composite", "Branch")

local _M = Composite

function _M:ctor()
	_M.super.ctor(self)

	self.m_children = {}
end

function _M:release()
	_M.super.release(self)

	for _, child in ipairs(self.m_children) do
		child:release()
	end

	self.m_children = {}
end

function _M:isComposite()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	macros.BEHAVIAC_ASSERT(self:getChildrenCount() > 0, "self:getChildrenCount() > 0")

	local childrenCount = self:getChildrenCount()

	for index = 1, childrenCount do
		local childNode = self:getChild(index)

		childNode:init(tick)
	end
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	if childFirst then
		for _, child in ipairs(self.m_children) do
			child:traverse(childFirst, handler, agent, tick, userData)
		end

		handler(self, agent, tick, userData)
	elseif handler(self, agent, tick, userData) then
		for _, child in ipairs(self.m_children) do
			child:traverse(childFirst, handler, agent, tick, userData)
		end
	end
end

function _M:setActiveChildIndex(tick, index)
	tick:setNodeMem("activeChildIndex", index, self)
end

function _M:getActiveChildIndex(tick)
	return tick:getNodeMem("activeChildIndex", self)
end

return _M
