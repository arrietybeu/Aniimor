-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BlockPetRecordMap.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BlockPetRecordMap")
local BlockPetRecordMap = class.LiteClass("BlockPetRecordMap", CustomDict)

function BlockPetRecordMap:addRecordCount(blockId, recordType, count)
	count = count or 1
	self[blockId] = self[blockId] or {}
	self[blockId][recordType] = (self[blockId][recordType] or 0) + count

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("addPetRecord, templateId=%s, blockId=%d, recordType=%d, addCount=%d, newCount=%d", tostring(self._parent and self._parent._name), blockId, recordType, count, self[blockId][recordType])
	end
end

function BlockPetRecordMap:getRecordCount(blockId, recordType)
	return self[blockId] and self[blockId][recordType] or 0
end

function BlockPetRecordMap:getRecordCountByList(blockIds, recordType)
	local total = 0

	for _, blockId in ipairs(blockIds or EMPTY_TABLE) do
		total = total + (self[blockId] and self[blockId][recordType] or 0)
	end

	return total
end

return BlockPetRecordMap
