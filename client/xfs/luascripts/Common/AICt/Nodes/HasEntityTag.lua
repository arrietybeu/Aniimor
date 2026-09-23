-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\HasEntityTag.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local HasEntityTag = Class.LightClass("HasEntityTag", CTRNode)
local Utils = require("Common.Utils.Utils")

function HasEntityTag:ctor(nodeId, nodeData, graph)
	HasEntityTag.super.ctor(self, nodeId, nodeData, graph)
end

function HasEntityTag:registerPorts()
	self.valueCount = self.nodeData.numb
	self.entityTagList = {}

	for i = 1, self.valueCount do
		self.entityTagList[i] = self:addValueInput("entityTag" .. i - 1)
	end

	self.valueTargetEntityActorId = self:addValueInput("targetEntityActorId")

	self:addValueOutput("out", function(flow)
		return self:Get_Value_Value(flow)
	end)
end

function HasEntityTag:Get_Value_Value(flow)
	local entityActorId = self:getInputValue(self.valueTargetEntityActorId, flow)

	if entityActorId == 0 then
		entityActorId = flow.context._entActorId
	end

	local tEnt = pg.getEntityByActorId(entityActorId)

	if tEnt then
		for _, tEntityTagValue in ipairs(self.entityTagList) do
			if Utils.hasEntityTag(tEnt, self:getInputValue(tEntityTagValue, flow)) then
				return true
			end
		end
	end

	return false
end

return HasEntityTag
