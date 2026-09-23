-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenPetInControlNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local Utils = require("Common.Utils.Utils")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenPetInControlNode = Class.LiteClass("ListenPetInControlNode", ListenBaseNode)

function ListenPetInControlNode:ctor(nodeId, nodeData, graph)
	ListenPetInControlNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenPetInControlNode:registerPorts()
	ListenPetInControlNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_True = self:addFlowOutput("True")
	self.flowOut_False = self:addFlowOutput("False")
	self.flowOut_InitTrue = self:addFlowOutput("InitTrue")
	self.flowOut_InitFalse = self:addFlowOutput("InitFalse")
	self.firstIn = "firstIn" .. self.nodeId
end

function ListenPetInControlNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local firstIn = context:getContextValue(self.firstIn)

	if not firstIn then
		context:setContextValue(self.firstIn, true)

		local player = space:getMainPlayer()

		if player then
			self:setContextValue(context, self.valueOutput_Player, player)
			self:setContextValue(context, self.valueOutput_Pet, nil)

			if player:isControllingPet() then
				self.flowOut_InitTrue:call(context)
			else
				self.flowOut_InitFalse:call(context)
			end
		end
	end

	local eventName = ServerEventConst.PET_IN_CONTROL

	local function listener(petInControl, playerId, petId)
		local player = pg.getEntity(playerId)

		if Utils.isSpaceSingleWorld(space.spaceType) and space:getOwnerPlayer() ~= player then
			return
		end

		if player then
			self:setContextValue(context, self.valueOutput_Player, player)
		else
			self:setContextValue(context, self.valueOutput_Player, nil)
		end

		local pet = pg.getEntity(petId)

		if pet then
			self:setContextValue(context, self.valueOutput_Pet, pet)
		else
			self:setContextValue(context, self.valueOutput_Pet, nil)
		end

		self:removeTimer(context)
		self:checkDoOnce(context)

		if petInControl then
			self.flowOut_True:call(context)
		else
			self.flowOut_False:call(context)
		end
	end

	self:addEventListen(context, eventName, listener)
end

return ListenPetInControlNode
