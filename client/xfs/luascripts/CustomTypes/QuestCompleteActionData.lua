-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\QuestCompleteActionData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local QuestCompleteActionData = class.LiteClass("QuestCompleteActionData", CustomDict)

function QuestCompleteActionData:getConditionCnt(objectiveKey, objType)
	if objType ~= QuestConst.QUEST_CONDTYPE.COM_ACTION_OBJECTIVE then
		return false, 0
	end

	local cnt = self.comActionObjcvs and self.comActionObjcvs[objectiveKey] and self.comActionObjcvs[objectiveKey].currentCnt

	if cnt then
		return true, cnt
	end

	return false, 0
end

return QuestCompleteActionData
