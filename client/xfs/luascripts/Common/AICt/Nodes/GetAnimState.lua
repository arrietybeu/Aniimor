-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\GetAnimState.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local GetAnimState = Class.LightClass("GetAnimState", CTRNode)
local AICtrConstData = require("Common.Data.AICtrData.aictr_const_data")

function GetAnimState:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function GetAnimState:registerPorts()
	local tb = AICtrConstData.getAnimState[self.nodeData.dataOption]

	if tb == nil then
		return
	end

	for _, v in ipairs(tb) do
		self:addValueOutput(v.name, function(flow)
			return v.value
		end)
	end
end

return GetAnimState
