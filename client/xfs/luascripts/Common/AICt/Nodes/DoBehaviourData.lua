-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoBehaviourData.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local DoBehaviourData = Class.LightClass("DoBehaviourData", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")
local btTreeData = require("Data.behavior_editor_export_data")
local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("DoBehaviourData")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local TablePool = require("Common.Container.TablePool")

function DoBehaviourData:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function DoBehaviourData:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_flowIn_PortCalled(flow)
	end)

	self.flowOut_flowOut = self:addFlowOutput("flowOut")
	self.valueInput_condition = self:addValueInput("condition")
end

function DoBehaviourData:On_flowIn_PortCalled(flow)
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

function DoBehaviourData:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local bName = self.nodeData.behaviourName
	local ent = pg.getEntityByActorId(flow.context._entActorId)
	local cModelData = ent:getConfigData()

	if cModelData and cModelData.prefabResID then
		bName = bName .. "_" .. cModelData.prefabResID
	end

	local cData = btTreeData[bName]

	if cData == nil then
		return false
	end

	local context = TablePool.getTable(3)

	for _, v in pairs(cData.behaviorStateKey.behaviorTreeTemplateParameters) do
		context[v.name] = ConstValueReader.readAnyType(v.type, v.value)
	end

	local btName = cData.behaviorStateKey.templateKey

	if BehaviorPathMapData.EnumNameMap[btName] ~= nil then
		local targetEntity = pg.getEntityByActorId(flow.context._entActorId)

		BehaviorTreePlanUtils.startEcologyPlanByState(targetEntity.agent, BehaviorPathMapData.EnumNameMap[btName], context)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("行为树枚举未定义:", btName)
	end

	TablePool.returnTable(context, 3)
	flow:setContinueNode(self)

	return false
end

return DoBehaviourData
