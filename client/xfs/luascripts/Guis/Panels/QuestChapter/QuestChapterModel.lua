-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestChapter\\QuestChapterModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local QuestMain = require("Data.quest_main")
local QuestChapter = require("Data.quest_chapter")
local QuestChapterModel = Class.LightClass("QuestChapterModel", UIModel)

function QuestChapterModel:getChapterInfo(chapterId)
	local chapter = QuestChapter[chapterId]

	if chapter then
		return chapter
	end

	return nil
end

function QuestChapterModel:getSectionInfo(chapterId, sectionId)
	local sections = QuestMain[chapterId]

	if sections then
		return sections[sectionId]
	end

	return nil
end

return QuestChapterModel
