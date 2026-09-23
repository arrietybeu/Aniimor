-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\EventTrigger.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local EventTrigger = Class.LightClass("EventTrigger", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")
local TriggerData = require("Common.Data.AICtrData.aictr_trigger_data")
local ConstData = require("Common.Data.AICtrData.aictr_const_data")

function EventTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function EventTrigger:registerPorts()
	local rawData = TriggerData[self.nodeData.triggerName] or {}

	self.flowOut = self:addFlowOutput("flowOut")

	self:registerSuffixPort()

	for k, v in pairs(rawData.inPorts or CTRConst.DefaultNullTable) do
		if string.find(k, CTRConst.FiltKey) then
			self.inputFiltKey = self:addValueInput(k)

			break
		end
	end

	for k, v in pairs(rawData.outPorts or CTRConst.DefaultNullTable) do
		self:addValueOutput(k, function(vp)
			if vp.context[k] ~= nil then
				return vp.context[k]
			else
				return v
			end
		end)
	end
end

function EventTrigger:executeTrigger(flow)
	if not self:_checkFiltKey(flow) then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function EventTrigger:registerSuffixPort()
	local suffix = ConstData.repeatTrigger.eventTrigger[self.nodeData.triggerName]

	if string.isNilOrEmpty(suffix) then
		return
	end

	self.suffixPort = self:addValueInput(suffix)
end

function EventTrigger:getTriggerName()
	if self.fullTriggerName == nil then
		self.fullTriggerName = self:_getFullTriggerName()
	end

	return self.fullTriggerName
end

function EventTrigger:_getFullTriggerName()
	if self.suffixPort == nil then
		return self.nodeData.triggerName
	end

	return self.nodeData.triggerName .. self.suffixPort:getDefaultValue()
end

function EventTrigger:_checkFiltKey(flow)
	if not self.inputFiltKey then
		return true
	end

	local filtKey = self:getInputValue(self.inputFiltKey, flow)

	return filtKey == flow.context[CTRConst.FiltKey]
end

return EventTrigger
