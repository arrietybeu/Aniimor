-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RobEggCollectionDisplayModelUtils.lua

local RobEggItemOut = require("Data.rob_egg_item_out")
local RobEggAccessoryData = require("Data.rob_egg_accessory_data")
local AppearanceData = require("Data.appearance_data")
local CollectItemData = require("Data.collect_item_data")
local RobEggCollectionDisplayModelUtils = {}

function RobEggCollectionDisplayModelUtils.getModelData(itemId)
	local itemOutCfg = itemId and RobEggItemOut[itemId]
	local inItemId = itemOutCfg and itemOutCfg.inid or itemId
	local accessoryCfg = inItemId and RobEggAccessoryData[inItemId]
	local playCosItemId = accessoryCfg and accessoryCfg.playCosItemId
	local appearanceCfg = playCosItemId and AppearanceData[playCosItemId]
	local collectCfg = inItemId and CollectItemData[inItemId]
	local appearanceResId = appearanceCfg and appearanceCfg.res

	if type(appearanceResId) ~= "string" or appearanceResId == "" then
		appearanceResId = nil
	end

	return {
		itemId = itemId,
		inItemId = inItemId,
		playCosItemId = playCosItemId,
		modelResId = appearanceResId or collectCfg and collectCfg.model,
		modelScale = collectCfg and collectCfg.modelScale or 1
	}
end

return RobEggCollectionDisplayModelUtils
