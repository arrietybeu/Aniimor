-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetListItem.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetListItem = Class.LiteClass("GetListItem", FlowNode)

function GetListItem:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetListItem:registerPorts()
	self.valueInput_list = self:addValueInput("list")
	self.valueInput_index = self:addValueInput("index")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetListItem:Get_Value_Value(context)
	local list = self:getContextValue(context, self.valueInput_list)
	local index = self:getContextValue(context, self.valueInput_index)

	return list[index]
end

return GetListItem
