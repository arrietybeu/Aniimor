-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonPlayerSkillTip\\CommonPlayerSkillTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local CommonPlayerSkillTipModel = Class.LightClass("CommonPlayerSkillTipModel", UIModel)

CommonPlayerSkillTipModel.SKILL_STATE = {
	CAN_UPGRADE = 6,
	CANT_UPGRADE_CONDITION_NOT_MEET = 5,
	CANT_UPGRADE_LEVEL_INSUFFICIENT = 4,
	CAN_UNLOCK = 3,
	CANT_UNLOCK_CONDITION_NOT_MEET = 2,
	CANT_UNLOCK_LEVEL_INSUFFICIENT = 1,
	NEED_TURN_POSITIVE = 8,
	MAX_LEVEL = 7
}

function CommonPlayerSkillTipModel:parseSkillInfo()
	return {}
end

return CommonPlayerSkillTipModel
