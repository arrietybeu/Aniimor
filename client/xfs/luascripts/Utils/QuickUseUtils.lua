-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\QuickUseUtils.lua

local ItemEffectData = require("Data.item_effect_data")
local ItemCompoundMaterial2Id = require("Data.item_compound_material2id")
local ItemUtils = require("Common.Utils.ItemUtils")
local QuickUseUtils = {}

function QuickUseUtils.isQuickUse(itemId)
	if itemId == nil then
		return false
	end

	local data = ItemEffectData[itemId]

	return data ~= nil and data.quickUse == 1 and ItemCompoundMaterial2Id[itemId] == nil and not ItemUtils.isOpenUIType(itemId)
end

return QuickUseUtils
