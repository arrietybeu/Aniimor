-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SelectEntityInTable.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local SelectEntityInTable = Class.LightClass("SelectEntityInTable", CTRNode)

function SelectEntityInTable:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	self.curEntity = nil
end

function SelectEntityInTable:registerPorts()
	self.valueInput_inTable = self:addValueInput("inTable")
	self.valueInput_condition = self:addValueInput("condition")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
	self:addValueOutput("element", function(flow)
		return self:Get_element_Value(flow)
	end)
end

function SelectEntityInTable:Get_out_Value(flow)
	local elements = self:getInputValue(self.valueInput_inTable, flow)
	local enough

	for _, v in ipairs(elements) do
		self.curEntity = pg.getEntityByActorId(v)

		local res = self:getInputValue(self.valueInput_condition, flow)

		if res then
			if enough == nil then
				enough = {}
			end

			enough[#enough + 1] = self.curEntity.actorId
		end
	end

	return enough
end

function SelectEntityInTable:Get_element_Value()
	return self.curEntity and self.curEntity.actorId or 0
end

return SelectEntityInTable
