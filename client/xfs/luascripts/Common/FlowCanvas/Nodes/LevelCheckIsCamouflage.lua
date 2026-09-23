-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\LevelCheckIsCamouflage.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local LevelCheckIsCamouflage = Class.LiteClass("LevelCheckIsCamouflage", FlowNode)

function LevelCheckIsCamouflage:ctor(nodeId, nodeData, graph)
	LevelCheckIsCamouflage.super.ctor(self, nodeId, nodeData, graph)
end

function LevelCheckIsCamouflage:registerPorts()
	self:addValueOutput("Result", function(context)
		return self:Get_Result_Value(context)
	end)
end

function LevelCheckIsCamouflage:Get_Result_Value(context)
	local space = context:getSpace()

	if not space then
		return false
	end

	local player = space:getMainPlayer()
	local curPet = player:getCurPetEntity()

	return curPet.isCamouflage
end

return LevelCheckIsCamouflage
