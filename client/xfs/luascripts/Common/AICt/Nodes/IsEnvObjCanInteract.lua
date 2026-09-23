-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\IsEnvObjCanInteract.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local IsEnvObjCanInteract = Class.LightClass("IsEnvObjCanInteract", CTRNode)

function IsEnvObjCanInteract:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function IsEnvObjCanInteract:registerPorts()
	self.valueInput_tgtId = self:addValueInput("tgtId")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
end

function IsEnvObjCanInteract:Get_out_Value(flow)
	local targetId = self:getInputValue(self.valueInput_tgtId, flow)
	local ent = pg.getEntityByActorId(targetId)

	if ent == nil then
		return false
	end

	return ent.checkCanInteract
end

return IsEnvObjCanInteract
