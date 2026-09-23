-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Branch.lua

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
local BaseNode = require("Common.AI.Behaviac.Core.BaseNode")
local Branch = functions.class("Branch", BaseNode)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Branch", Branch)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Branch", "BaseNode")

local _M = Branch
local CurrentVisitNodeName = "currentVisitingNode"

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isBranch()
	return true
end

function _M:init(tick)
	_M.super.init(self, tick)
	self:setCurrentVisitingNode(tick, false)
end

function _M:onEvent(agent, tick, eventName, eventParams)
	local bGoOn = true

	if self:hasEvents() then
		local curVisitingNode = self:getCurrentVisitingNode(tick)

		if curVisitingNode then
			bGoOn = self:onEventCurrentVisitingNode(agent, tick, eventName, eventParams)
		end

		bGoOn = bGoOn and _M.super.onEvent(self, agent, tick, eventName, eventParams)
	end

	return bGoOn
end

function _M:onEnter(agent, tick)
	return true
end

function _M:onExit(agent, tick)
	return true
end

function _M:onEventCurrentVisitingNode(agent, tick, eventName, eventParams)
	local curVisitingNode = self:getCurrentVisitingNode(tick)

	if curVisitingNode then
		local s = curVisitingNode:getStatus(tick)

		macros.BEHAVIAC_ASSERT(s == EBTStatus.BT_RUNNING and self:hasEvents(), "[_M:onEventCurrentVisitingNode()] invalid status=%d", s)

		local bGoOn = curVisitingNode:onEvent(agent, tick, eventName, eventParams)

		if bGoOn then
			local parentBranch = curVisitingNode:getParent()

			while parentBranch and parentBranch ~= self and curVisitingNode ~= nil do
				macros.BEHAVIAC_ASSERT(parentBranch:getStatus(tick) == EBTStatus.BT_RUNNING, "[_M:onEventCurrentVisitingNode()] invalid status=%d", parentBranch:getStatus(tick))

				bGoOn = parentBranch:onEvent(agent, tick, eventName, eventParams)

				if not bGoOn then
					return false
				end

				parentBranch = parentBranch:getParent()
				curVisitingNode = self:getCurrentVisitingNode(tick)
			end
		end

		return bGoOn
	end

	return true
end

function _M:updateCurrent(agent, tick, childStatus)
	local curVisitingNode = self:getCurrentVisitingNode(tick)

	if curVisitingNode then
		return self:execCurrentVisitingNode(curVisitingNode, agent, tick, childStatus)
	else
		return self:update(agent, tick, childStatus)
	end
end

function _M:execCurrentVisitingNode(curVisitingNode, agent, tick, childStatus)
	if curVisitingNode:getStatus(tick) ~= EBTStatus.BT_RUNNING then
		Logging.error("[_M:execCurrentVisitingNode()] selfNode(%d)curVisitingNode(%d) status (%d) is not running", self:getId(), curVisitingNode:getId(), curVisitingNode:getStatus(tick))

		return EBTStatus.BT_FAILURE
	end

	local status = tick:execWithChildStatus(curVisitingNode, agent, childStatus)

	if status ~= EBTStatus.BT_RUNNING then
		local parentBranch = curVisitingNode:getParent()

		self:setCurrentVisitingNode(tick, false)

		while parentBranch do
			if parentBranch == self then
				status = parentBranch:update(agent, tick, status)
			else
				status = tick:execWithChildStatus(parentBranch, agent, status)
			end

			if status == EBTStatus.BT_RUNNING then
				return EBTStatus.BT_RUNNING
			end

			local parentBranchStatus = parentBranch:getStatus(tick)

			macros.BEHAVIAC_ASSERT(parentBranch == self or parentBranchStatus == status)

			if parentBranch == self then
				break
			end

			parentBranch = parentBranch:getParent()
		end
	end

	return status
end

function _M:resumeBranch(agent, tick, status)
	local curVisitingNode = self:getCurrentVisitingNode(tick)

	if not curVisitingNode then
		Logging.error("[_M:resumeBranch()] no current visiting node")

		return EBTStatus.BT_INVALID
	end

	if status ~= EBTStatus.BT_SUCCESS and status ~= EBTStatus.BT_FAILURE then
		Logging.error("[_M:resumeBranch()] error status %", status)

		return EBTStatus.BT_INVALID
	end

	local parent = false
	local _tNode = curVisitingNode

	if _tNode:isManagingChildrenAsSubTrees() then
		parent = curVisitingNode
	else
		parent = curVisitingNode:getParent()
	end

	self:setCurrentVisitingNode(tick, false)

	return tick:execWithChildStatus(parent, agent, status)
end

function _M:markVisiting(tick, visitingNode)
	local pLastVisitingNode = self:getCurrentVisitingNode(tick)

	if visitingNode then
		if not pLastVisitingNode then
			_M.setCurrentVisitingNode(self, tick, visitingNode)
			visitingNode:setHasManagingParent(tick, true)
		end
	else
		local status = self:getStatus(tick)

		if status ~= EBTStatus.BT_RUNNING then
			_M.setCurrentVisitingNode(self, tick, visitingNode)
		end
	end
end

function _M:setCurrentVisitingNode(tick, visitingNode)
	tick:setNodeMem(CurrentVisitNodeName, visitingNode, self)
end

function _M:getCurrentVisitingNode(tick)
	return tick:getNodeMem(CurrentVisitNodeName, self)
end

return _M
