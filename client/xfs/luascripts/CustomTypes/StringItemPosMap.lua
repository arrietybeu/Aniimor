-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\StringItemPosMap.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemUtils = require("Common.Utils.ItemUtils")
local StringItemPosMap = class.LiteClass("StringItemPosMap", CustomDict)

function StringItemPosMap:getItemPos(petId)
	return self[petId]
end

function StringItemPosMap:getItem(petId)
	local itemPos = self:getItemPos(petId)

	if not itemPos or not itemPos:isValid() then
		return nil
	end

	local player = self:getRootOwner()

	return player and ItemUtils.getItem(player, itemPos:invId(), itemPos:genId()) or nil
end

function StringItemPosMap:getItemInfo(petId)
	local item = self:getItem(petId)

	return item and ItemUtils.getPropertyWithType(item) or nil
end

function StringItemPosMap:getCarrySnapshot(petId)
	local player = self:getRootOwner()
	local coreItem = self:getItem(petId)
	local coreInfo = coreItem and ItemUtils.getPropertyWithType(coreItem) or nil

	if not player or not coreInfo then
		return nil
	end

	local itemIds = {
		coreItem.id
	}
	local itemGenIds = {
		coreItem:getGenID()
	}

	for _, itemPos in ipairs(coreInfo.assistCarryPosList or EMPTY_TABLE) do
		local assistItem = itemPos:isValid() and ItemUtils.getItem(player, itemPos:invId(), itemPos:genId()) or nil

		itemIds[#itemIds + 1] = assistItem and assistItem.id or 0
		itemGenIds[#itemGenIds + 1] = assistItem and assistItem:getGenID() or 0
	end

	return {
		itemIds = itemIds,
		itemGenIds = itemGenIds
	}
end

return StringItemPosMap
