-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\GlobalBlackBoard.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local GlobalBlackBoard = Class.LightClass("GlobalBlackBoard", CTRNode)
local BlackBoardData = require("Common.Data.AICtrData.aictr_global_blackBoards_data")

function GlobalBlackBoard:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function GlobalBlackBoard:registerPorts()
	local paramName = self.nodeData.paramName

	self:addValueOutput(paramName, function(flow)
		return BlackBoardData[paramName]
	end)
end

return GlobalBlackBoard
