-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ChemIceMeltEventNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SceneUtils = require("Common.Utils.SceneUtils")
local ChemIceMeltEventNode = Class.LiteClass("ChemIceMeltEventNode", FlowNode)

function ChemIceMeltEventNode:ctor(nodeId, nodeData, graph)
	ChemIceMeltEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function ChemIceMeltEventNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.valueInput_PartId = self:addValueInput("PartId")
	self.valueInput_StaticId = self:addValueInput("StaticId")
	self.valueInput_Percent = self:addValueInput("Percent")
	self.lastMeltPercent = "lastMeltPercent" .. self.nodeId
end

function ChemIceMeltEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName)
	local staticId = self:getContextValue(context, self.valueInput_StaticId)
	local partId = self:getContextValue(context, self.valueInput_PartId)
	local targetpercent = self:getContextValue(context, self.valueInput_Percent)

	if not eventName or not staticId or not partId or not targetpercent then
		return
	end

	local lastMeltPercent = context:getContextValue(self.lastMeltPercent)

	if not lastMeltPercent then
		context:setContextValue(self.lastMeltPercent, 1)
	end

	local globalId = SceneUtils.getEnvIdByStaticId(staticId)

	if globalId then
		eventName = eventName .. "#" .. globalId .. "#" .. partId

		local function listener(percent)
			local lastPercent = context:getContextValue(self.lastMeltPercent)

			if lastPercent >= targetpercent and percent < targetpercent then
				self.flowOut_Out:call(context)
				context:unregisterSpaceEventListener(self.nodeId, eventName)
			end

			context:setContextValue(self.lastMeltPercent, percent)
		end

		context:registerSpaceEventListener(self.nodeId, eventName, listener)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("ChemIceMeltEventNode find globalId fail. eventName:%s staticId:%s partId:%s", eventName, staticId, partId)
	end
end

return ChemIceMeltEventNode
