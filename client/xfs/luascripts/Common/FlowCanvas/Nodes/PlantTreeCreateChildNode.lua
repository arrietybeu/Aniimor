-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PlantTreeCreateChildNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PlantTreeCreateChildNode = Class.LiteClass("PlantTreeCreateChildNode", FlowNode)
local logger = LoggerManager.getLogger("PlantTreeCreateChildNode")

function PlantTreeCreateChildNode:ctor(nodeId, nodeData, graph)
	PlantTreeCreateChildNode.super.ctor(self, nodeId, nodeData, graph)
end

function PlantTreeCreateChildNode:registerPorts()
	PlantTreeCreateChildNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_levelItemId = self:addValueInput("levelItemId")
	self.valueInput_slotIndex = self:addValueInput("slotIndex")
	self.valueInput_force = self:addValueInput("force")
end

function PlantTreeCreateChildNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_levelItemId)
	local slotIndex = self:getContextValue(context, self.valueInput_slotIndex)
	local force = self:getContextValue(context, self.valueInput_force)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem or not levelItem.createChild then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PlantTreeCreateChildNode levelItem not exist or not valid", sandboxId, levelItemId)
		end

		return
	end

	levelItem:createChild(slotIndex, force)
	self.flowOut_Out:call(context)
end

return PlantTreeCreateChildNode
