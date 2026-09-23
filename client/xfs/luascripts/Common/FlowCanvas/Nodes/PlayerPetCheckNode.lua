-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PlayerPetCheckNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PlayerPetCheckNode = Class.LiteClass("PlayerPetCheckNode", FlowNode)

function PlayerPetCheckNode:ctor(nodeId, nodeData, graph)
	PlayerPetCheckNode.super.ctor(self, nodeId, nodeData, graph)
end

function PlayerPetCheckNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_True = self:addFlowOutput("True")
	self.flowOut_False = self:addFlowOutput("False")
	self.valueInput_TemplateId = self:addValueInput("TemplateId")
	self.valueInput_PetLevel = self:addValueInput("PetLevel")
end

function PlayerPetCheckNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space.ownerPlayer

	if not player then
		return
	end

	local templateId = self:getContextValue(context, self.valueInput_TemplateId)
	local petLevel = self:getContextValue(context, self.valueInput_PetLevel)
	local pet = player:getPetBytemplateId(templateId)

	if not pet then
		self.flowOut_False:call(context)

		return
	end

	if petLevel ~= 0 and petLevel > pet.level then
		self.flowOut_False:call(context)

		return
	end

	self.flowOut_True:call(context)
end

return PlayerPetCheckNode
