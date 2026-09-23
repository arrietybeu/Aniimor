-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\GrabEggsCalcinationRedDotUtils.lua

local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local GrabEggsCalcinationRedDotUtils = {}
local SNAPSHOT_KEY = "calcination_read_snapshot"
local OWNED_INVENTORY_IDS = {
	ItemConst.INV_TYPE_ROB_EGG,
	ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE,
	ItemConst.INV_TYPE_EQUIP_SLOTS
}

local function getReadSnapshot()
	if not pg or not pg.me then
		return {}
	end

	local snapshot = pg.me:getClientInfo(Const.CLIENT_KEY.GRAB_EGG_MODE, SNAPSHOT_KEY)

	return type(snapshot) == "table" and snapshot or {}
end

local function isSameSnapshot(left, right)
	for genID in pairs(left) do
		if right[genID] ~= true then
			return false
		end
	end

	for genID in pairs(right) do
		if left[genID] ~= true then
			return false
		end
	end

	return true
end

local function getOwnedRefineableSnapshot()
	local snapshot = {}
	local player = pg and pg.me

	if not player then
		return snapshot
	end

	for _, invID in ipairs(OWNED_INVENTORY_IDS) do
		local inventory = ItemUtils.getTypedBag(player, invID)

		if inventory then
			for _, item in inventory:items() do
				if item and item.genID and ItemUtils.isRefineable(item.id) then
					snapshot[tostring(item.genID)] = true
				end
			end
		end
	end

	return snapshot
end

function GrabEggsCalcinationRedDotUtils.getCurrentSnapshot()
	local snapshot = {}
	local player = pg and pg.me
	local warehouse = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE)

	if not warehouse then
		return snapshot
	end

	for _, item in warehouse:items() do
		if item and item.genID and ItemUtils.isRefineable(item.id) then
			local antiqueData = item.props and item.props[ItemConst.ItemPropertyDef.AntiqueData]
			local affixNum = antiqueData and (tonumber(antiqueData.affix_num) or 0) or 0
			local maxAffixNum = antiqueData and (tonumber(antiqueData.max_affix_num) or 0) or 0

			if affixNum < maxAffixNum then
				snapshot[tostring(item.genID)] = true
			end
		end
	end

	return snapshot
end

function GrabEggsCalcinationRedDotUtils.hasNewItem()
	local readSnapshot = getReadSnapshot()

	for genID in pairs(GrabEggsCalcinationRedDotUtils.getCurrentSnapshot()) do
		if not readSnapshot[genID] then
			return true
		end
	end

	return false
end

function GrabEggsCalcinationRedDotUtils.markCurrentItemsViewed()
	if not pg or not pg.me then
		return
	end

	local readSnapshot = getReadSnapshot()
	local viewedSnapshot = GrabEggsCalcinationRedDotUtils.getCurrentSnapshot()
	local ownedSnapshot = getOwnedRefineableSnapshot()

	for genID in pairs(readSnapshot) do
		if ownedSnapshot[genID] then
			viewedSnapshot[genID] = true
		end
	end

	if isSameSnapshot(readSnapshot, viewedSnapshot) then
		return
	end

	pg.me:setClientInfo(Const.CLIENT_KEY.GRAB_EGG_MODE, SNAPSHOT_KEY, viewedSnapshot)
end

return GrabEggsCalcinationRedDotUtils
