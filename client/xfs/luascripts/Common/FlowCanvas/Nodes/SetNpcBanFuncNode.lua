-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetNpcBanFuncNode.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SetNpcBanFuncNode = Class.LiteClass("SetNpcBanFuncNode", FlowNode)

function SetNpcBanFuncNode:ctor(nodeId, nodeData, graph)
	SetNpcBanFuncNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetNpcBanFuncNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_npcId = self:addValueInput("npcId")
	self.valueInput_disable = self:addValueInput("disable")
	self.valueInput_funcIds = self:addValueInput("funcIds")
end

function SetNpcBanFuncNode:On_In_PortCalled(context, inputPortName)
	local npcId = self:getContextValue(context, self.valueInput_npcId)
	local enable = self:getContextValue(context, self.valueInput_disable)
	local funcIds = self:getContextValue(context, self.valueInput_funcIds)

	if npcId and npcId > 0 then
		local space = context:getSpace()

		for _, player in pairs(context:getGraphPlayers()) do
			player:setBanNpcFunc(npcId, enable, funcIds)
		end
	end

	self.flowOut_Out:call(context)
end

return SetNpcBanFuncNode
