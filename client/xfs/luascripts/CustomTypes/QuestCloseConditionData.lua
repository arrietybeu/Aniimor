-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\QuestCloseConditionData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local QuestCloseConditionData = class.LiteClass("QuestCloseConditionData", CustomDict)

function QuestCloseConditionData:getConditionCnt(objectiveKey, objType)
	if objType ~= QuestConst.QUEST_CONDTYPE.CLOSECOND then
		return false, 0
	end

	local objective = self.closeCond and self.closeCond[objectiveKey]
	local cnt = objective and objective.currentCnt

	if cnt then
		return true, cnt
	end

	return false, 0
end

return QuestCloseConditionData
