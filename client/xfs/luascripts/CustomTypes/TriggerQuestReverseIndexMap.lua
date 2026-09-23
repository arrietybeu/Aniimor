-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\TriggerQuestReverseIndexMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerQuestReverseIndexMap = class.LiteClass("TriggerQuestReverseIndexMap", CustomDict)

function TriggerQuestReverseIndexMap:reset()
	for registerType = TriggerConst.TRIGGER_QUEST_INDEX_START, TriggerConst.TRIGGER_QUEST_INDEX_END do
		self[registerType] = nil
	end

	self.initialized = false
end

function TriggerQuestReverseIndexMap:addEntryRaw(registerType, registerId, trigger, triggerId)
	if not self[registerType] then
		self[registerType] = {}
	end

	if not self[registerType][registerId] then
		self[registerType][registerId] = {}
	end

	if not self[registerType][registerId][trigger] then
		self[registerType][registerId][trigger] = {}
	end

	self[registerType][registerId][trigger][triggerId] = true
end

function TriggerQuestReverseIndexMap:addEntry(registerType, registerId, trigger, triggerId)
	if not self.initialized then
		return
	end

	self:addEntryRaw(registerType, registerId, trigger, triggerId)
end

function TriggerQuestReverseIndexMap:setInitialized(initialized)
	self.initialized = initialized
end

function TriggerQuestReverseIndexMap:removeEntry(registerType, registerId, trigger, triggerId)
	if not self.initialized then
		return
	end

	if not self[registerType] or not self[registerType][registerId] then
		return
	end

	local byQuest = self[registerType][registerId]

	if byQuest[trigger] then
		byQuest[trigger][triggerId] = nil

		if not next(byQuest[trigger]) then
			byQuest[trigger] = nil
		end
	end

	if not next(byQuest) then
		self[registerType][registerId] = nil
	end
end

function TriggerQuestReverseIndexMap:getTriggersByQuestId(questId, registerType)
	if not self.initialized then
		return nil
	end

	return self[registerType] and self[registerType][questId]
end

return TriggerQuestReverseIndexMap
