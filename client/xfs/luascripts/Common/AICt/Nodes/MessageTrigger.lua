-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\MessageTrigger.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local MessageTrigger = Class.LightClass("MessageTrigger", CTRNode)
local MessageData = require("Common.Data.AICtrData.aictr_message_data")
local ConstData = require("Common.Data.AICtrData.aictr_const_data")

function MessageTrigger:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function MessageTrigger:registerPorts()
	self:registerSuffixPort()

	self.flowOut = self:addFlowOutput("flowOut")

	self:addValueOutput("sourceActorId", function(vp)
		return vp.context.sourceActorId
	end)

	local rawData = MessageData[self.nodeData.triggerName] or {}

	for k, v in pairs(rawData.inPorts or EMPTY_TABLE) do
		self:addValueOutput(k, function(vp)
			if vp.context[k] ~= nil then
				return vp.context[k]
			else
				return v
			end
		end)
	end
end

function MessageTrigger:registerSuffixPort()
	local suffix = ConstData.repeatTrigger.messageTrigger[self.nodeData.triggerName]

	if string.isNilOrEmpty(suffix) then
		return
	end

	self.suffixPort = self:addValueInput(suffix)
end

function MessageTrigger:getTriggerName()
	if self.fullTriggerName == nil then
		self.fullTriggerName = self:_getFullTriggerName()
	end

	return self.fullTriggerName
end

function MessageTrigger:_getFullTriggerName()
	if self.suffixPort == nil then
		return self.nodeData.triggerName
	end

	return self.nodeData.triggerName .. self.suffixPort:getDefaultValue()
end

function MessageTrigger:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return MessageTrigger
