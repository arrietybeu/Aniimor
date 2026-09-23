-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\EnableCallFriendStateNode.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local EnableCallFriendStateNode = Class.LiteClass("EnableCallFriendStateNode", FlowNode)

function EnableCallFriendStateNode:ctor(nodeId, nodeData, graph)
	EnableCallFriendStateNode.super.ctor(self, nodeId, nodeData, graph)
end

function EnableCallFriendStateNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_staticId = self:addValueInput("staticId")
	self.valueInput_enable = self:addValueInput("enable")
end

function EnableCallFriendStateNode:On_In_PortCalled(context, inputPortName)
	local staticId = self:getContextValue(context, self.valueInput_staticId)
	local enable = self:getContextValue(context, self.valueInput_enable)

	if staticId and staticId > 0 then
		local space = context:getSpace()
		local player = space.ownerPlayer

		if not player then
			return
		end

		local curPet = player:getCurPetEntity()

		if not curPet or not player:isControllingPet() then
			return
		end

		local entity = space:getEntityByStaticId(staticId)

		if entity then
			if enable then
				if entity.setToSlaves and entity.slavesOwnerId == "" and curPet:getConfigData().ethnicGroup == entity:getConfigData().ethnicGroup then
					entity:setToSlaves(curPet.id)
				end
			else
				if entity.setBackSlaves then
					entity:setBackSlaves()
				end

				if curPet.removeSlaves then
					curPet:removeSlaves(entity.actorId)
				end
			end
		end
	end

	self.flowOut_Out:call(context)
end

return EnableCallFriendStateNode
