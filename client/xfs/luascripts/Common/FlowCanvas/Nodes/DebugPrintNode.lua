-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DebugPrintNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local DebugPrintNode = Class.LiteClass("DebugPrintNode", FlowNode)
local logger = LoggerManager.getLogger("DebugPrintNode")

function DebugPrintNode:ctor(nodeId, nodeData, graph)
	DebugPrintNode.super.ctor(self, nodeId, nodeData, graph)
end

function DebugPrintNode:registerPorts()
	self:addFlowInput("in", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("out")
	self.textCount = self.nodeData.textCount or 0

	for i = 1, self.textCount do
		self["valueInput_Text" .. i] = self:addValueInput("Text" .. tostring(i))
	end
end

function DebugPrintNode:On_In_PortCalled(context, inputPortName)
	local str = ""

	for i = 1, self.textCount do
		local contextValue = self:getContextValue(context, self["valueInput_Text" .. i])

		if contextValue == nil then
			contextValue = ""
		end

		local s = "#Text" .. i .. ":" .. tostring(contextValue)

		str = str .. s
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(str, self.nodeId)
	end

	self.flowOut_Out:call(context)
end

return DebugPrintNode
