-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\ForEachPreset.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local ForEachPreset = Class.LightClass("ForEachPreset", CTRNode)
local AICtrConstData = require("Common.Data.AICtrData.aictr_const_data")
local CTRConst = require("Common.AICt.CTRConst")

function ForEachPreset:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function ForEachPreset:registerPorts()
	self.flowOut_forEachBody = self:addFlowOutput("forEachBody")
	self.valueInput_mapData = self:addValueInput("mapData")

	self:addValueOutput("element", function(flow)
		return self:Get_element_Value(flow)
	end)
	self:addValueOutput("resList", function(flow)
		return self:Get_resList_Value(flow)
	end)
end

function ForEachPreset:Get_element_Value(flow)
	return self.selectElement
end

function ForEachPreset:Get_resList_Value(flow)
	local cData = AICtrConstData.foreachPreset[self.nodeData.iteratorOption]
	local elements = self:getInputValue(self.valueInput_mapData, flow)
	local enough

	for k, v in pairs(elements) do
		if cData.foreachKv == CTRConst.ForeachKV.MAP_KEY then
			self.selectElement = k
		else
			self.selectElement = v
		end

		local res = self:callFlowOut(self.flowOut_forEachBody, flow)

		if res then
			if enough == nil then
				enough = {}
			end

			enough[#enough + 1] = self.selectElement
		end
	end

	return enough
end

return ForEachPreset
