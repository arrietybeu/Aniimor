-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\AttributeMonitorNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local Utils = require("Common.Utils.Utils")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local AttributeMonitorNode = Class.LiteClass("AttributeMonitorNode", ListenBaseNode)
local AttributeConst = require("Common.Const.AttributeConst")
local pg = pg
local COMPARE_OP = {
	function(a, b)
		return b < a
	end,
	function(a, b)
		return b <= a
	end,
	function(a, b)
		return a == b
	end,
	function(a, b)
		return a < b
	end,
	function(a, b)
		return a <= b
	end,
	function(a, b)
		return a ~= b
	end
}

function AttributeMonitorNode:ctor(nodeId, nodeData, graph)
	AttributeMonitorNode.super.ctor(self, nodeId, nodeData, graph)
end

function AttributeMonitorNode:registerPorts()
	AttributeMonitorNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.attribute = self.nodeData.Attribute
	self.operation = self.nodeData.Operation
	self.targetPercent = self.nodeData.TargetPercent
	self.valueInput_Entities = self:addValueInput("Entities")
	self.flowOut_Out = self:addFlowOutput("Out")
	self.lastPercentKey = "lastPercentMap" .. self.nodeId
	self.registerEntityKey = "registerEntityKey" .. self.nodeId
	self.notifyIdsKey = "attrNotifyIds" .. self.nodeId
end

function AttributeMonitorNode:clearNotifies(context)
	local notifyIds = context:getContextValue(self.notifyIdsKey)

	if notifyIds then
		for _, info in ipairs(notifyIds) do
			local ent = pg.getEntity(info[1])

			if ent and ent.actorCombatAttribute then
				ent.actorCombatAttribute:unregisterAttributeNotify(info[2], info[3])
			end

			context:setContextValue(self.registerEntityKey .. info[1], nil)
		end

		context:setContextValue(self.notifyIdsKey, nil)
	end

	context:setContextValue(self.lastPercentKey, nil)
end

function AttributeMonitorNode:removeListen(context)
	self:clearNotifies(context)
	AttributeMonitorNode.super.removeListen(self, context)
end

function AttributeMonitorNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local compareFunc = COMPARE_OP[self.operation]

	if not compareFunc then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("AttributeMonitorNode:On_In_PortCalled %s %s", self.nodeId, self.operation)
		end

		return
	end

	self:clearNotifies(context)

	local entities = self:getContextValue(context, self.valueInput_Entities)
	local entityIds = {}

	if Utils.isAttributeChangeEntity(entities) then
		entityIds[entities.id] = true
	else
		for _, entity in pairs(entities or EMPTY_TABLE) do
			if Utils.isAttributeChangeEntity(entity) then
				entityIds[entity.id] = true
			end
		end
	end

	local function notifyFuc(entity)
		if not entity.hasInitAbilityInfo then
			return
		end

		if not context:getContextValue(self.registerEntityKey .. entity.id) then
			return
		end

		local percent = entity.actorCombatAttribute[self.attribute](entity.actorCombatAttribute)

		if compareFunc(percent, self.targetPercent) then
			local percentMap = context:getContextValue(self.lastPercentKey) or {}

			if percentMap[entity.id] then
				if percent ~= percentMap[entity.id] then
					percentMap[entity.id] = percent
				else
					return
				end
			else
				percentMap[entity.id] = percent
			end

			context:setContextValue(self.lastPercentKey, percentMap)
			self:removeTimer(context)

			local doOnce = self:checkDoOnce(context)

			self.flowOut_Out:call(context)

			if doOnce then
				self:clearNotifies(context)
			end
		end
	end

	local notifyAttributes

	if self.attribute == "getHpPercent" then
		notifyAttributes = {
			AttributeConst.hp_cur,
			AttributeConst.hp_max_cur
		}
	elseif self.attribute == "getBreakPercent" then
		notifyAttributes = {
			AttributeConst.bp_cur,
			AttributeConst.bp_max_cur
		}
	end

	if notifyAttributes then
		for entityId, _ in pairs(entityIds) do
			local ent = pg.getEntity(entityId)

			if ent and ent.actorCombatAttribute then
				context:setContextValue(self.registerEntityKey .. ent.id, true)

				for _, attributeId in ipairs(notifyAttributes) do
					local notifyId = ent.actorCombatAttribute:registerAttributeNotify(attributeId, notifyFuc)
					local notifyIds = context:getContextValue(self.notifyIdsKey) or {}

					notifyIds[#notifyIds + 1] = {
						ent.id,
						attributeId,
						notifyId
					}

					context:setContextValue(self.notifyIdsKey, notifyIds)
					notifyFuc(ent)
				end
			end
		end
	end
end

function AttributeMonitorNode:onContextDestroy(context)
	if context then
		self:clearNotifies(context)
	end

	AttributeMonitorNode.super.onContextDestroy(self, context)
end

return AttributeMonitorNode
