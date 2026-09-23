-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\ForEach.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local ForEach = Class.LightClass("ForEach", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")

function ForEach:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function ForEach:registerPorts()
	self.flowOut_forEachBody = self:addFlowOutput("forEachBody")
	self.valueInput_mapData = self:addValueInput("mapData")

	self:addValueOutput("element", function(flow)
		return self:Get_arrayElement_Value(flow)
	end)
	self:addValueOutput("resList", function(flow)
		return self:Get_resList_Value(flow)
	end)
end

function ForEach:Get_arrayElement_Value(flow)
	return self.selectElement
end

function ForEach:Get_resList_Value(flow)
	local elements = self:getInputValue(self.valueInput_mapData, flow)
	local enough

	for k, v in pairs(elements) do
		if self.nodeData.foreachKv == CTRConst.ForeachKV.MAP_KEY then
			self.selectElement = k
		else
			self.selectElement = v
		end

		local res = self:callFlowOut(self.flowOut_forEachBody, flow)

		if res then
			if enough == nil then
				enough = flow:getTempList()
			end

			enough[#enough + 1] = self.selectElement
		end
	end

	return enough
end

return ForEach
