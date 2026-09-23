-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainChapterTip\\SpecialTrainChapterTipModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local SpecialTrainChapterTipModel = Class.LightClass("SpecialTrainChapterTipModel", UIModel)
local SpecialTrainChapterData = require("Data.special_train_chapter_data")
local SpecialTrainRevertData = require("Data.quest_special_train_revert")
local SpecialTrainTypeData = require("Data.special_train_type_data")
local QuestConst = require("Common.Const.QuestConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")

function SpecialTrainChapterTipModel:getChapterConfig(chapterId)
	if SpecialTrainChapterData[chapterId] == nil then
		return
	end

	return SpecialTrainChapterData[chapterId]
end

function SpecialTrainChapterTipModel:getChapterIntroConfig(chapterId)
	local mainTaskIds = QuestUtils.getChapterCourseQuestList(chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY)
	local sideTaskIds = QuestUtils.getChapterCourseQuestList(chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.ELECTIVE)
	local stageItems = {}

	for i, v in pairs(mainTaskIds) do
		local revertConfig = SpecialTrainRevertData[v + 1]

		if revertConfig and revertConfig.taskType then
			if stageItems[revertConfig.taskType] == nil then
				stageItems[revertConfig.taskType] = {
					num = 1
				}
			else
				stageItems[revertConfig.taskType].num = stageItems[revertConfig.taskType].num + 1
			end
		end
	end

	for i, v in pairs(sideTaskIds) do
		local revertConfig = SpecialTrainRevertData[v + 1]

		if revertConfig and revertConfig.taskType then
			if stageItems[revertConfig.taskType] == nil then
				stageItems[revertConfig.taskType] = {
					num = 1
				}
			else
				stageItems[revertConfig.taskType].num = stageItems[revertConfig.taskType].num + 1
			end
		end
	end

	local chapterItems = {}

	for i, v in pairs(stageItems) do
		local pageConfig = SpecialTrainTypeData[i]

		if pageConfig then
			local stageItem = {
				icon = pageConfig.tabIcon1,
				name = pageConfig.typeName,
				des = string.format("+%s", v.num)
			}

			table.insert(chapterItems, stageItem)
		end
	end

	return chapterItems
end

return SpecialTrainChapterTipModel
