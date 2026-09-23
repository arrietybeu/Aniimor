-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\AcceptedQuestData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local AcceptedQuestData = class.LiteClass("AcceptedQuestData", CustomDict)

function AcceptedQuestData:getConditionCnt(objectiveKey, objType)
	local key = objectiveKey
	local obj

	if objType == QuestConst.QUEST_CONDTYPE.RUNCOND then
		obj = self.runCond
	elseif objType == QuestConst.QUEST_CONDTYPE.OBJECTIVE then
		obj = self.objectives
	end

	local cnt = obj and obj[key] and obj[key].currentCnt

	if cnt then
		return true, cnt
	end

	return false, 0
end

return AcceptedQuestData
