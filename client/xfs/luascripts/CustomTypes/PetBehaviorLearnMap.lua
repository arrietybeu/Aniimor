-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBehaviorLearnMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PetBehaviorLearnMap = class.LiteClass("PetBehaviorLearnMap", CustomDict)

function PetBehaviorLearnMap:getPetBehaviorLevel(templateId, behaviorId)
	if behaviorId == Const.CALL_FRIEND_BEHAVIOR_ID then
		return 2
	end

	return self[templateId] and self[templateId][behaviorId] or 0
end

return PetBehaviorLearnMap
