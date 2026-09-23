-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Cache.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local Cache = Class.LightClass("Cache", CTRNode)

function Cache:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function Cache:registerPorts()
	local ports = self.nodeData._inputPortValues

	for k, _ in pairs(ports) do
		local pName = k

		self[pName] = self:addValueInput(pName)

		self:addValueOutput("out_" .. pName, function(vp)
			return self:get_Port_Value(vp, pName)
		end)
	end
end

function Cache:get_Port_Value(flow, pName)
	local value = flow:getCacheValue(self.nodeId, pName)

	if value ~= nil and value ~= 0 then
		return value
	end

	local res = self:getInputValue(self[pName], flow)

	flow:setCacheValue(self.nodeId, pName, res)

	return res
end

return Cache
