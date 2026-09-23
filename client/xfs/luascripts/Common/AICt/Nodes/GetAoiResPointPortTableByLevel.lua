-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\GetAoiResPointPortTableByLevel.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ListPool = require("Common.Container.ListPool")
local GetAoiResPointPortTableByLevel = Class.LightClass("GetAoiResPointPortTableByLevel", CTRNode)

function GetAoiResPointPortTableByLevel:ctor(nodeId, nodeData, graph)
	GetAoiResPointPortTableByLevel.super.ctor(self, nodeId, nodeData, graph)

	self.pointTags = {}
	self.portTags = {}
end

function GetAoiResPointPortTableByLevel:registerPorts()
	self.valueTargetActorId = self:addValueInput("targetActorId")
	self.valueMaxDeltaHeight = self:addValueInput("maxDeltaHeight")
	self.pointTagNum = self.nodeData.pointTagNum
	self.valuePointTagList = {}

	for i = 1, self.pointTagNum do
		self.valuePointTagList[i] = self:addValueInput("pointTag" .. i - 1)
	end

	self.portTagNum = self.nodeData.portTagNum
	self.valuePortTagList = {}

	for i = 1, self.portTagNum do
		self.valuePortTagList[i] = self:addValueInput("portTag" .. i - 1)
	end

	self:addValueOutput("resPointPortTable", function(flow)
		return self:Get_resPointPortTable_Value(flow)
	end)
end

function GetAoiResPointPortTableByLevel:Get_resPointPortTable_Value(flow)
	local tgId = self:getInputValue(self.valueTargetActorId, flow)

	if tgId == 0 then
		tgId = flow.context._entActorId
	end

	local maxDeltaHeight = self:getInputValue(self.valueMaxDeltaHeight, flow) or 0

	table.clear(self.pointTags)
	table.clear(self.portTags)

	for _, valuePointTag in ipairs(self.valuePointTagList) do
		table.insert(self.pointTags, self:getInputValue(valuePointTag, flow))
	end

	for _, valuePortTag in ipairs(self.valuePortTagList) do
		table.insert(self.portTags, self:getInputValue(valuePortTag, flow))
	end

	local portIdTables = ListPool.getList()

	ResPointUtils.GetResPointPortInRange(tgId, self.nodeData.aoiLevel, maxDeltaHeight, self.pointTags, self.portTags, portIdTables)

	local fixPortIds = flow:getTempList()

	for _, portIdTable in ipairs(portIdTables) do
		local portId = flow:getTempList()

		portId[1] = ResPointUtils.ToFixPointId(portIdTable[1], portIdTable[2])
		portId[2] = portIdTable[3]

		table.insert(fixPortIds, portId)
	end

	ListPool.returnList(portIdTables)

	return fixPortIds
end

return GetAoiResPointPortTableByLevel
