-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\TextHelper\\Component\\LeylineFlowerTextHelper.lua

local LeylineFlowerTextHelper = {}

LeylineFlowerTextHelper.priority = 0
LeylineFlowerTextHelper.LEYLINE_FLOWER_TEMPLATE_ID = 200028
LeylineFlowerTextHelper.STYLE_ID = 285
LeylineFlowerTextHelper.FULL_NUMBER = 99

function LeylineFlowerTextHelper.meetCondition(ent, interactData)
	if ent.templateId == LeylineFlowerTextHelper.LEYLINE_FLOWER_TEMPLATE_ID and interactData.styleId == LeylineFlowerTextHelper.STYLE_ID then
		return true
	end

	return false
end

function LeylineFlowerTextHelper.getProcessedText(oriText, ent, interactData)
	local leylineFlowerInfoMap = pg.me:getSpaceOwnerSceneLeylineFlowerInfoMap() or pg.me.leylineFlowerInfoMap:getRawTable()
	local flowerId = ent.staticId

	if leylineFlowerInfoMap[flowerId] then
		local bloomCountStack = leylineFlowerInfoMap[flowerId].pendingCaptureBloomCount or 0

		if bloomCountStack >= LeylineFlowerTextHelper.FULL_NUMBER then
			return pg.getFormatText(pg.getGameString("BLOOM_STACK_FULL"), bloomCountStack)
		else
			return pg.getFormatText(oriText, bloomCountStack)
		end
	else
		return oriText
	end
end

local TextHelperBase = require("GameApp.Interaction.TextHelper.TextHelperBase")

TextHelperBase.register(LeylineFlowerTextHelper)

return LeylineFlowerTextHelper
