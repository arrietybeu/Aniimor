-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BatchDialogueMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local pairs = pairs
local BatchDialogueMap = class.LiteClass("BatchDialogueMap", CustomDict)

function BatchDialogueMap:isBatchDialogueExist(eventId)
	return self[eventId] ~= nil
end

function BatchDialogueMap:addBatchDialogue(eventId, batchDialogueList, isRandom)
	self[eventId] = {}
	self[eventId].curIndex = 1
	self[eventId].isFinished = false

	if isRandom then
		local shuffledList = lume.clone(batchDialogueList)

		lume.shuffle(shuffledList)

		self[eventId].dialogueList = shuffledList
	else
		self[eventId].dialogueList = batchDialogueList
	end
end

function BatchDialogueMap:oneDialogueFinished(eventId, dialogueId)
	if not self[eventId] then
		return
	end

	local curIndex = self[eventId].curIndex

	if self[eventId].dialogueList[curIndex] ~= dialogueId then
		return
	end

	self[eventId].curIndex = curIndex + 1

	if self[eventId].curIndex > #self[eventId].dialogueList then
		self[eventId].isFinished = true
	end
end

function BatchDialogueMap:isBatchDialogueFinished(eventId)
	if not self[eventId] then
		return true
	end

	return self[eventId].isFinished
end

function BatchDialogueMap:removeBatchDialogue(eventId)
	self[eventId] = nil
end

function BatchDialogueMap:getCurBatchDialogue(eventId)
	if not self[eventId] then
		return nil
	end

	local curIndex = self[eventId].curIndex

	if curIndex > #self[eventId].dialogueList then
		return nil
	end

	return self[eventId].dialogueList[curIndex]
end

function BatchDialogueMap:getOneBatchDialogueEventId()
	for eventId, info in pairs(self) do
		if not info.isFinished then
			return eventId
		end
	end

	return nil
end

return BatchDialogueMap
