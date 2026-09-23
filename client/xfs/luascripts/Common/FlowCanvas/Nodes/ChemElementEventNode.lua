-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ChemElementEventNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local SceneUtils = require("Common.Utils.SceneUtils")
local ChemElementEventNode = Class.LiteClass("ChemElementEventNode", ListenBaseNode)

function ChemElementEventNode:ctor(nodeId, nodeData, graph)
	ChemElementEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function ChemElementEventNode:registerPorts()
	ChemElementEventNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.valueInput_PartId = self:addValueInput("PartId")
	self.valueInput_StaticId = self:addValueInput("StaticId")
end

function ChemElementEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local partId = self:getContextValue(context, self.valueInput_PartId)

	if not eventName or not staticId or not partId then
		return
	end

	local globalId = SceneUtils.getEnvIdByStaticId(staticId)

	if globalId then
		eventName = eventName .. "#" .. globalId .. "#" .. partId

		local function listener()
			self:removeTimer(context)
			self:checkDoOnce(context)
			self.flowOut_Out:call(context)
		end

		self:addEventListen(context, eventName, listener)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("ChemElementEventNode find globalId fail. eventName:%s staticId:%s partId:%s", eventName, staticId, partId)
	end
end

return ChemElementEventNode
