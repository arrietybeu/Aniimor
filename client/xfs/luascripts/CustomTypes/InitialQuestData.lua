-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InitialQuestData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local InitialQuestData = class.LiteClass("InitialQuestData", CustomDict)

function InitialQuestData:getConditionCnt(objectiveKey, objType)
	local key = objectiveKey
	local obj = {}

	if objType == QuestConst.QUEST_CONDTYPE.CLAIMCOND then
		obj = self.claimCond
	end

	local cnt = obj and obj[key] and obj[key].currentCnt

	if cnt then
		return true, cnt
	end

	return false, 0
end

return InitialQuestData
