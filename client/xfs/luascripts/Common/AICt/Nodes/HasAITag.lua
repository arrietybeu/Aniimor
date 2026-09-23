-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\HasAITag.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local HasAITag = Class.LightClass("HasAITag", CTRNode)

function HasAITag:registerPorts()
	self.valueCount = self.nodeData.numb
	self.aiTagList = {}

	for i = 1, self.valueCount do
		self.aiTagList[i] = self:addValueInput("tag" .. i - 1)
	end

	self.valueTargetEntityActorId = self:addValueInput("targetEntityActorId")

	self:addValueOutput("out", function(flow)
		return self:Get_Value_Value(flow)
	end)
end

function HasAITag:Get_Value_Value(flow)
	local entityActorId = self:getInputValue(self.valueTargetEntityActorId, flow)

	if entityActorId == 0 then
		entityActorId = flow.context._entActorId
	end

	local tEnt = pg.getEntityByActorId(entityActorId)

	if tEnt and tEnt.hasAITag then
		for _, tAITagValue in ipairs(self.aiTagList) do
			if tEnt:hasAITag(self:getInputValue(tAITagValue, flow)) then
				return true
			end
		end
	end

	return false
end

return HasAITag
