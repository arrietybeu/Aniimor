-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\PetLevelUpUIUtils.lua

local ClientTextUtils = require("Utils.ClientTextUtils")
local PetLevelUpUIUtils = {}
local LEVEL_UP_ANIMATION = "VX_Node_HUD_HP_Pet_LevelUp"

function PetLevelUpUIUtils.play(content, level)
	content:TryChangePage("Level", 2)

	local objectReference = content:GetComponent("ObjectReference")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textLevelUSDFText = objectReference:GetRefValue("textLevelUSDFText")
	local levelUpAnimation = objectReference:GetRefValue("levelUpAnimation")
	local textLevelUpUSDFText = objectReference:GetRefValue("textLevelUpUSDFText")

	ClientTextUtils.setText(textLevelUSDFText, pg.getGameString("LEVEL_LITE") .. tostring(level))
	ClientTextUtils.setText(textLevelUpUSDFText, pg.getGameString("LEVEL_UP_ENG"))
	levelUpAnimation:Stop()
	levelUpAnimation:Play(LEVEL_UP_ANIMATION)

	return levelUpAnimation:GetClip(LEVEL_UP_ANIMATION).length
end

function PetLevelUpUIUtils.playSmall(content, level)
	content:TryChangePage("Level", 2)

	local objectReference = content:GetComponent("ObjectReference")
	local avatarUImage = objectReference:GetRefValue("avatarUImage")
	local levelUpAnimation = objectReference:GetRefValue("levelUpAnimation")
	local petHeadTransform = objectReference:GetRefValue("petHeadTransform")
	local textLevelUpUSDFText = objectReference:GetRefValue("textLevelUpUSDFText")
	local textLevelTextPlus = objectReference:GetRefValue("textLevelTextPlus")
	local bgMaskUImage = objectReference:GetRefValue("bgMaskUImage")

	ClientTextUtils.setText(textLevelTextPlus, pg.getGameString("LEVEL_LITE") .. tostring(level))
	ClientTextUtils.setText(textLevelUpUSDFText, pg.getGameString("LEVEL_UP_ENG"))
	levelUpAnimation:Stop()
	levelUpAnimation:Play(LEVEL_UP_ANIMATION)

	return levelUpAnimation:GetClip(LEVEL_UP_ANIMATION).length
end

return PetLevelUpUIUtils
