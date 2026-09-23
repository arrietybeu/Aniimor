-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\AssistCarryInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local logger = require("Core.Log.LoggerManager").getLogger("AssistCarryInfo")
local AssistCarryData = require("Data.assist_carry_data")
local AssistCarryInfo = class.LiteClass("AssistCarryInfo", CustomDict)

function AssistCarryInfo:isValid()
	return self.itemId ~= 0
end

function AssistCarryInfo:onFirstCreate()
	assert(pg.component == "game", "server only")
	assert(self:isValid(), "itemId is 0")

	if #self.talentList > 0 then
		logger:error("talentList is not empty", self:repr())

		return
	end

	local acdd = AssistCarryData[self.itemId]

	if not acdd then
		logger:error("assist_carry_data config nil", self.itemId)

		return
	end

	if acdd.propGroup then
		self.talentList:initByTemplate(acdd.propGroup, {
			sourceRepr = self:repr()
		})
	end
end

function AssistCarryInfo:repr()
	return string.format("AssistCarryInfo(itemId=%d)", self.itemId)
end

function AssistCarryInfo:getAssistType()
	local data = AssistCarryData[self.itemId]

	return data and data.type or 0
end

function AssistCarryInfo:getEnergy()
	local data = AssistCarryData[self.itemId]

	return data and data.energy or 0
end

function AssistCarryInfo:getBaseProp()
	local data = AssistCarryData[self.itemId]

	return data and data.baseprop or {}
end

function AssistCarryInfo:getBuffId()
	local data = AssistCarryData[self.itemId]

	return data and data.buffId or {}
end

function AssistCarryInfo:getCpValue()
	local data = AssistCarryData[self.itemId]
	local baseCp = data.cp or 0
	local talentCp = self.talentList and self.talentList:getCpValue() or 0

	return baseCp + talentCp
end

return AssistCarryInfo
