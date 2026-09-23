-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoBehaviour.lua

local Class = require("Core.Framework.Class")
local CTRNode = require("Common.AICt.CTRNode")
local DoBehaviour = Class.LightClass("DoBehaviour", CTRNode)
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("DoBehaviour")
local CTRConst = require("Common.AICt.CTRConst")
local CTRFlow = require("Common.AICt.CTRFlow")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local TablePool = require("Common.Container.TablePool")

function DoBehaviour:ctor(nodeId, nodeData, graph)
	DoBehaviour.super.ctor(self, nodeId, nodeData, graph)
end

function DoBehaviour:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")

	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		self[k] = self:addValueInput(k)
	end
end

function DoBehaviour:On_In_PortCalled(flow)
	if flow._AdditiveFlow then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Additive AI 无法执行 行为树.", self.flowOut.graphId, ",node id:", self.nodeId)
		end

		self:callFlowOut(self.flowOut, flow)

		return
	end

	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoBehaviour:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow) and not self:GetInterruptResult(flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local context = TablePool.getTable()

	for k, _ in pairs(self.nodeData._inputPortValues) do
		if k ~= "condition" then
			context[k] = self:getInputValue(self[k], flow)
		end
	end

	local btName = self.nodeData.behaviourName

	if BehaviorPathMapData.EnumNameMap[btName] ~= nil then
		local targetEntity = pg.getEntityByActorId(flow.context._entActorId)

		if targetEntity then
			BehaviorTreePlanUtils.startEcologyPlanByState(targetEntity.agent, BehaviorPathMapData.EnumNameMap[btName], context)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("行为树枚举未定义:", btName)
	end

	TablePool.returnTable(context)
	flow:setContinueNode(self)

	return false
end

function DoBehaviour:GetInterruptResult(flow)
	local interrupt = self:getInputValue(self.interrupt, flow)

	if interrupt then
		flow.__flowFinishType = CTRConst.FlowFinishType.Interrupt
	end

	return interrupt
end

return DoBehaviour
