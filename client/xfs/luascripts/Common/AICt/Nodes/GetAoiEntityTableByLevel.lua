-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\GetAoiEntityTableByLevel.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local AIUtils = require("Common.Utils.AIUtils")
local GetAoiEntityTableByLevel = Class.LightClass("GetAoiEntityTableByLevel", CTRNode)
local Const = require("Common.Const.Const")

function GetAoiEntityTableByLevel:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function GetAoiEntityTableByLevel:registerPorts()
	self.valueInput_target = self:addValueInput("targetId")

	self:addValueOutput("entityTable", function(flow)
		return self:Get_entityTable_Value(flow)
	end)
end

function GetAoiEntityTableByLevel:Get_entityTable_Value(flow)
	local ret = flow:getTempList()
	local tgId = self:getInputValue(self.valueInput_target, flow)

	if tgId == 0 then
		tgId = flow.context._entActorId
	end

	local ent = pg.getEntityByActorId(tgId)

	if ent then
		AIUtils.SearchEntitiesInRangeWithCache(ent, self.nodeData.aoiLevel, self.nodeData.searchType, ret)
	end

	return ret
end

return GetAoiEntityTableByLevel
