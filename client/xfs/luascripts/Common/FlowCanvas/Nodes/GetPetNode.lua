-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetPetNode.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local GetPetNode = Class.LiteClass("GetPetNode", FlowNode)

function GetPetNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetPetNode:registerPorts()
	GetPetNode.super.registerPorts(self)

	self.valueInput_Player = self:addValueInput("Player")

	self:addValueOutput("Pet", function(context)
		return self:Get_Value_Pet(context)
	end)
end

function GetPetNode:Get_Value_Pet(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = self:getContextValue(context, self.valueInput_Player)

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetPetNode get player nil.")
		end

		return
	end

	if Utils.isPlayer(player) then
		return player:getCurPetEntity()
	else
		local ret = {}

		for _, entity in pairs(player or EMPTY_TABLE) do
			if Utils.isPlayer(entity) then
				ret[#ret + 1] = entity:getCurPetEntity()
			end
		end

		return ret
	end
end

return GetPetNode
