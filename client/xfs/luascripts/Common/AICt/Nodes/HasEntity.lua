-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\HasEntity.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local HasEntity = Class.LightClass("HasEntity", CTRNode)

function HasEntity:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	self.curEntity = nil
end

function HasEntity:registerPorts()
	self.valueInput_inTable = self:addValueInput("inTable")
	self.valueInput_condition = self:addValueInput("condition")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
	self:addValueOutput("element", function(flow)
		return self:Get_element_Value(flow)
	end)
end

function HasEntity:Get_out_Value(flow)
	local elements = self:getInputValue(self.valueInput_inTable, flow)
	local enough = false

	for _, v in ipairs(elements) do
		self.curEntity = pg.getEntityByActorId(v)

		local res = self:getInputValue(self.valueInput_condition, flow)

		enough = enough or res
	end

	return enough
end

function HasEntity:Get_element_Value()
	return self.curEntity and self.curEntity.actorId or 0
end

return HasEntity
