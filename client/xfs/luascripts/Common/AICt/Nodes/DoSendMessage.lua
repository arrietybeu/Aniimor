-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoSendMessage.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local DoSendMessage = Class.LightClass("DoSendMessage", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")
local LoggerManager = require("Core.Log.LoggerManager")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local TablePool = require("Common.Container.TablePool")
local CTRPool = require("Common.AICt.CTRPool")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")

function DoSendMessage:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function DoSendMessage:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")

	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		self[k] = self:addValueInput(k)
	end
end

function DoSendMessage:On_In_PortCalled(flow)
	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoSendMessage:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local tId = self:getInputValue(self.target, flow)
	local tIdList = self:getInputValue(self.targetList, flow)
	local inputParams = TablePool.getTable()

	for k, _ in pairs(self.nodeData._inputPortValues) do
		if k ~= "target" and k ~= "targetList" and k ~= "condition" then
			inputParams[k] = self:getInputValue(self[k], flow)
		end
	end

	if tId and tId ~= 0 then
		local context = CTRPool.getContext()

		context.sourceActorId = flow.context._entActorId

		table.merge(context, inputParams)
		TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self.doTrigger, tId, self.nodeData.triggerName, context))
	end

	if tIdList ~= nil then
		for i, v in ipairs(tIdList) do
			local context = CTRPool.getContext()

			context.sourceActorId = flow.context._entActorId

			table.merge(context, inputParams)
			TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self.doTrigger, v, self.nodeData.triggerName, context))
		end
	end

	TablePool.returnTable(inputParams)
end

function DoSendMessage:doTrigger(targetActorId, triggerName, context)
	ConditionUtils.DoTrigger(targetActorId, triggerName, context)
end

return DoSendMessage
