-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetCombatEntityPropertyNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetCombatEntityPropertyNode = Class.LiteClass("GetCombatEntityPropertyNode", FlowNode)

function GetCombatEntityPropertyNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetCombatEntityPropertyNode:registerPorts()
	self.propertyName = self.nodeData.propertyName
	self.valueInput_StaticId = self:addValueInput("staticId")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetCombatEntityPropertyNode:Get_Value_Value(context)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)

	if not staticId or not self.propertyName then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetCombatEntityPropertyNode:Get_Value_Value  NodeId %s staticId %s propertyName %s", self.nodeId, staticId, self.propertyName)
		end

		return
	end

	local space = context:getSpace()
	local entity = space:getEntityByStaticId(staticId)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetCombatEntityPropertyNode:Get_Value_Value NodeId %s entity nil", self.nodeId)
		end

		return
	end

	local value = entity[self.propertyName]

	if type(value) == "boolean" then
		value = value and 1 or 0
	elseif type(value) ~= "number" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetCombatEntityPropertyNode:Get_Value_Value NodeId %s, value = %s not is number", self.nodeId, inspect(value))
		end

		return
	end

	return value
end

return GetCombatEntityPropertyNode
