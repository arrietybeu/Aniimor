-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\Display\\RankBaseTextDisplay.lua

local ClientTextUtils = require("Utils.ClientTextUtils")
local ValueDisplayUtils = require("Utils.ValueDisplayUtils")
local RankBaseTextDisplay = {}

function RankBaseTextDisplay.renderSpecialText(objectReference, _, specialText)
	RankBaseTextDisplay.renderText(objectReference, pg.getLocalizationText(specialText))

	return true
end

function RankBaseTextDisplay.renderPlayerLevelText(objectReference, _, level)
	if level == nil then
		RankBaseTextDisplay.renderText(objectReference, "")

		return false
	end

	RankBaseTextDisplay.renderText(objectReference, tostring(level))

	return true
end

function RankBaseTextDisplay.renderScoreText(objectReference, _, score)
	if score == nil then
		RankBaseTextDisplay.renderText(objectReference, "")

		return false
	end

	RankBaseTextDisplay.renderText(objectReference, score)

	return true
end

function RankBaseTextDisplay.renderText(objectReference, text)
	local txtScoreUSDFText = objectReference:GetRefValue("txtScoreUSDFText")

	ClientTextUtils.setText(txtScoreUSDFText, text)
end

return RankBaseTextDisplay
