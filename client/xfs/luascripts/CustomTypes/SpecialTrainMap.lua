-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SpecialTrainMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ObjHelper = require("ObjHelper")
local SpecialTrainMap = class.LiteClass("SpecialTrainMap", CustomDict)

function SpecialTrainMap:unlockGroup(taskGroup)
	if not self[taskGroup] then
		self[taskGroup] = {}
	end
end

function SpecialTrainMap:setCurQuestId(taskGroup, curQuestId)
	if not self[taskGroup] then
		self[taskGroup] = {}
	end

	self[taskGroup]:setCurQuestId(curQuestId)
end

function SpecialTrainMap:setEntryReward(taskGroupId, taskProcess)
	if not self[taskGroupId] then
		return false
	end

	return self[taskGroupId]:setEntryReward(taskProcess)
end

function SpecialTrainMap:isEntryRewarded(taskGroupId, taskProcess)
	if not self[taskGroupId] then
		return false
	end

	return self[taskGroupId]:isEntryRewarded(taskProcess)
end

function SpecialTrainMap:isGetChapterReward()
	return self.isChapterRewarded
end

function SpecialTrainMap:setChapterRewarded(isRewarded)
	self.isChapterRewarded = isRewarded
end

function SpecialTrainMap:setChapterInStarTitleQuest(isInStarTitleQuest)
	self.isInStarTitleQuest = isInStarTitleQuest
end

function SpecialTrainMap:isChapterInStarTitleQuest()
	return self.isInStarTitleQuest
end

function SpecialTrainMap:setCanGetChapterReward(canGetChapterReward)
	self.canGetChapterReward = canGetChapterReward
end

function SpecialTrainMap:isCanGetChapterReward()
	return self.canGetChapterReward
end

function SpecialTrainMap:setStarTitleQuestViewed(isStarTitleQuestViewed)
	self.isStarTitleQuestViewed = isStarTitleQuestViewed
end

function SpecialTrainMap:isStarTitleQuestViewed()
	return self.isStarTitleQuestViewed
end

return SpecialTrainMap
