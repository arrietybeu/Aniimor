-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetRigidBodyStateNode.lua

local Class = require("Core.Framework.Class")
local ServerUtils = require("GameServer.ServerUtils")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SetRigidBodyStateNode = Class.LiteClass("SetRigidBodyStateNode", FlowNode)
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")

function SetRigidBodyStateNode:ctor(nodeId, nodeData, graph)
	SetRigidBodyStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetRigidBodyStateNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_entId = self:addValueInput("entId")
	self.valueInput_staticId = self:addValueInput("staticId")
	self.valueInput_state = self:addValueInput("state")
end

function SetRigidBodyStateNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_staticId)
	local globalId
	local space = context:getSpace()

	if not space then
		return
	end

	local entity

	if staticId and staticId ~= 0 then
		entity = space:getEntityByStaticId(staticId)
	else
		globalId = self:getContextValue(context, self.valueInput_entId)

		if not string.isNilOrEmpty(globalId) then
			entity = space:getEntityByGlobalId(globalId)
		end
	end

	if entity and entity.setEnableRigidBody then
		local stateValue = self:getContextValue(context, self.valueInput_state)

		entity:setEnableRigidBody(Const.ServerSetRigidBodyKey.Level, stateValue)
	end

	self.flowOut_Out:call(context)
end

return SetRigidBodyStateNode
