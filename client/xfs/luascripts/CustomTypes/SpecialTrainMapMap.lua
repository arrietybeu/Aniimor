-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SpecialTrainMapMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ObjHelper = require("ObjHelper")
local SpecialTrainChapterData = require("Data.special_train_chapter_data")
local SpecialTrainMapMap = class.LiteClass("SpecialTrainMapMap", CustomDict)

function SpecialTrainMapMap:unlockChapter(chapterId)
	if not self[chapterId] then
		self[chapterId] = {}
	end
end

function SpecialTrainMapMap:isUnlocked(chapterId)
	return self[chapterId] ~= nil
end

function SpecialTrainMapMap:unlockChapterAndGroup(chapterId, taskGroup)
	if not self[chapterId] then
		self[chapterId] = {}
	end

	self[chapterId]:unlockGroup(taskGroup)
end

function SpecialTrainMapMap:setCurQuestId(chapterId, taskGroup, curQuestId)
	if not self[chapterId] then
		self[chapterId] = {}
	end

	self[chapterId]:setCurQuestId(taskGroup, curQuestId)
end

function SpecialTrainMapMap:setChapterViewed(chapterId)
	if not self[chapterId] then
		return false
	end

	self[chapterId].isChapterViewed = true
end

function SpecialTrainMapMap:getCurChapterId()
	local curChapterId = 0

	for k, _ in pairs(self) do
		if curChapterId < k then
			curChapterId = k
		end
	end

	return curChapterId
end

function SpecialTrainMapMap:setEntryReward(chapterId, taskGroupId, taskProcess)
	if not self[chapterId] then
		return false
	end

	return self[chapterId]:setEntryReward(taskGroupId, taskProcess)
end

function SpecialTrainMapMap:isEntryRewarded(chapterId, taskGroupId, taskProcess)
	if not self[chapterId] then
		return false
	end

	return self[chapterId]:isEntryRewarded(taskGroupId, taskProcess)
end

function SpecialTrainMapMap:isAllPreChapterUnlocked(chapterId)
	if chapterId <= 0 then
		return true
	end

	for i = 0, chapterId - 1 do
		if SpecialTrainChapterData[i] and not self[i] then
			return false
		end
	end

	return true
end

function SpecialTrainMapMap:setChapterRewarded(chapterId)
	if not self[chapterId] then
		return false
	end

	self[chapterId]:setChapterRewarded(true)

	return true
end

function SpecialTrainMapMap:isGetChapterReward(chapterId)
	if not self[chapterId] then
		return false
	end

	if self[chapterId]:isGetChapterReward() then
		return true
	end

	return false
end

function SpecialTrainMapMap:setChapterInStarTitleQuest(chapterId, isInStarTitleQuest)
	if not self[chapterId] then
		return false
	end

	self[chapterId]:setChapterInStarTitleQuest(isInStarTitleQuest)

	return true
end

function SpecialTrainMapMap:isChapterInStarTitleQuest(chapterId)
	if not self[chapterId] then
		return false
	end

	if self[chapterId]:isChapterInStarTitleQuest() then
		return true
	end

	return false
end

function SpecialTrainMapMap:isCanGetChapterReward(chapterId)
	if not self[chapterId] then
		return false
	end

	return self[chapterId]:isCanGetChapterReward()
end

function SpecialTrainMapMap:setCanGetChapterReward(chapterId, canGetChapterReward)
	if not self[chapterId] then
		return false
	end

	self[chapterId]:setCanGetChapterReward(canGetChapterReward)

	return true
end

function SpecialTrainMapMap:isStarTitleQuestViewed(chapterId)
	if not self[chapterId] then
		return false
	end

	return self[chapterId]:isStarTitleQuestViewed()
end

function SpecialTrainMapMap:setStarTitleQuestViewed(chapterId, isStarTitleQuestViewed)
	if not self[chapterId] then
		return false
	end

	self[chapterId]:setStarTitleQuestViewed(isStarTitleQuestViewed)

	return true
end

return SpecialTrainMapMap
