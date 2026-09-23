-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ApplyECSElementNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ApplyECSElementNode = Class.LiteClass("ApplyECSElementNode", FlowNode)
local Utils = require("Common.Utils.Utils")

function ApplyECSElementNode:ctor(nodeId, nodeData, graph)
	ApplyECSElementNode.super.ctor(self, nodeId, nodeData, graph)
end

function ApplyECSElementNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_ElementType = self:addValueInput("ElementType")
	self.valueInput_Value = self:addValueInput("Value")
	self.valueInput_StaticId = self:addValueInput("StaticId")
end

function ApplyECSElementNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local addValue = self:getContextValue(context, self.valueInput_Value)
	local elementType = self:getContextValue(context, self.valueInput_ElementType)
	local space = context:getSpace()
	local envObj = space:getEntityByStaticId(staticId)

	if Utils.isEnvObj(envObj) then
		envObj:applyECSElement(elementType, addValue)
	end

	self.flowOut_Out:call(context)
end

return ApplyECSElementNode
