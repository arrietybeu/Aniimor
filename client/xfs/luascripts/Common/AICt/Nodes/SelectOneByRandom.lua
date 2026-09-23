-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SelectOneByRandom.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local SelectOneByRandom = Class.LightClass("SelectOneByRandom", CTRNode)

function SelectOneByRandom:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function SelectOneByRandom:registerPorts()
	self.valueInput_inTable = self:addValueInput("inTable")

	self:addValueOutput("out", function(vp)
		return self:Get_out_Value(vp)
	end)
end

function SelectOneByRandom:Get_out_Value(flow)
	local vTable = self:getInputValue(self.valueInput_inTable, flow)

	if vTable == nil or #vTable == 0 then
		return nil
	end

	local index = math.random(1, #vTable)

	return vTable[index]
end

return SelectOneByRandom
