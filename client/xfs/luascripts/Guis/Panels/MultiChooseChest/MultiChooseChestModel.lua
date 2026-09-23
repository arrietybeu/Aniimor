-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MultiChooseChest\\MultiChooseChestModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemData = require("Data.item_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local DropData = require("Data.drop_data")
local DropGroupData = require("Data.drop_group_data")
local Lume = require("Core.Common.lume")
local MultiChooseChestModel = Class.LightClass("MultiChooseChestModel", UIModel)

function MultiChooseChestModel:getMaxChooseNum(itemId)
	if not ItemEffectData[itemId] or ItemEffectData[itemId].sType ~= ItemConst.USEITEM_TYPE_MULTI_CHOOSE_CHEST or not ItemEffectData[itemId].params or #ItemEffectData[itemId].params < 2 then
		return 0
	end

	local params = ItemEffectData[itemId].params

	return params[2], params[1]
end

function MultiChooseChestModel:getAllRewards(itemId)
	local ret = {}
	local maxChooseNum, dropId = self:getMaxChooseNum(itemId)

	if maxChooseNum <= 0 then
		return ret
	end

	if not DropData[dropId] then
		return ret
	end

	local dropD = DropData[dropId]

	if dropD.dropType == 1 then
		if dropD.fixedDrop and #dropD.fixedDrop > 0 then
			for i = 1, #dropD.fixedDrop do
				ret[i] = self:_setupItemInfo(dropD.fixedDrop[i][1], dropD.fixedDrop[i][2])
			end
		end
	elseif dropD.dropType == 2 and dropD.dropParam and #dropD.dropParam > 0 then
		for i = 1, #dropD.dropParam do
			local dropT = Lume.clone(DropGroupData[dropD.dropParam[i]])

			table.sort(dropT, function(a, b)
				return a.index < b.index
			end)

			if #dropT > 0 then
				for ii = 1, #dropT do
					ret[#ret + 1] = self:_setupItemInfo(dropT[ii].itemId, dropT[ii].dropMinNum)
				end
			end
		end
	end

	return ret
end

function MultiChooseChestModel:_setupItemInfo(itemId, itemNum)
	local ret = {}

	ret.id = itemId
	ret.num = itemNum
	ret.itemName = "Error Item"

	local itemConfig = ItemData[itemId]

	if itemConfig then
		ret.itemName = pg.getLocalizationText(itemConfig.itemName)
	end

	ret.owned = ItemUtils.getItemCountById(pg.me, itemId)

	return ret
end

return MultiChooseChestModel
