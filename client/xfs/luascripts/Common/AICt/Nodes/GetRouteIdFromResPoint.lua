-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\GetRouteIdFromResPoint.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local GetRouteIdFromResPoint = Class.LightClass("GetRouteIdFromResPoint", CTRNode)

function GetRouteIdFromResPoint:registerPorts()
	self.valueInput_pointId = self:addValueInput("pointId")

	self:addValueOutput("routeId", function(flow)
		return self:Get_routeId_Value(flow)
	end)

	if self.nodeData.getWithIndex then
		self.valueInput_index = self:addValueInput("index")
	end
end

function GetRouteIdFromResPoint:Get_routeId_Value(flow)
	local fixPointId = self:getInputValue(self.valueInput_pointId, flow)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)

	if self.nodeData.getWithIndex then
		local index = self:getInputValue(self.valueInput_index, flow)

		return ResPointUtils.GetRouteIdFromResPointWithIndex(actorId, pointId, index)
	else
		return ResPointUtils.GetRouteIdFromResPoint(actorId, pointId)
	end
end

return GetRouteIdFromResPoint
