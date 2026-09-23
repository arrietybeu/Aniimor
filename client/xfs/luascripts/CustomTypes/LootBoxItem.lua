-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\LootBoxItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local LootBoxItem = class.LiteClass("LootBoxItem", CustomDict)

function LootBoxItem:isValid()
	return ToBool(self.id) and ToBool(self.count)
end

function LootBoxItem:isFinishDiscovery(uid)
	if not uid then
		return
	end

	local value = self.discoverys[uid]

	if not value then
		return
	end

	return value == Const.ROB_LOOT_ITEM_FINISH_DISCOVERY
end

function LootBoxItem:getOwnerUid()
	return self.tag.ownerUid
end

function LootBoxItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function LootBoxItem:getChips()
	return {}
end

return LootBoxItem
