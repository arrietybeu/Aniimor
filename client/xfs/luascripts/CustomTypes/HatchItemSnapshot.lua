-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HatchItemSnapshot.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local HatchItemSnapshot = class.LiteClass("HatchItemSnapshot", CustomDict)
local bit = bit

function HatchItemSnapshot.getCodec()
	if HatchItemSnapshot.protoCodec == nil then
		if pg.component == "game" then
			HatchItemSnapshot.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			HatchItemSnapshot.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return HatchItemSnapshot.protoCodec
end

function HatchItemSnapshot:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function HatchItemSnapshot:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function HatchItemSnapshot:getInvID()
	return ItemUtils.getInvIdByItemId(self.id)
end

function HatchItemSnapshot:getCount()
	return self.count
end

function HatchItemSnapshot:getProps()
	return self.props
end

function HatchItemSnapshot:getGenID()
	return self.genID
end

function HatchItemSnapshot:getObjID()
	return self.objID
end

function HatchItemSnapshot:getIsBind()
	return true
end

function HatchItemSnapshot:getUseTimes()
	return self.useTimes
end

function HatchItemSnapshot:getStatus()
	return self.status
end

function HatchItemSnapshot:getValidStartTime()
	return 0
end

function HatchItemSnapshot:getValidEndTime()
	return 0
end

function HatchItemSnapshot:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function HatchItemSnapshot:getOwnerUid()
	return self.owner
end

function HatchItemSnapshot:getChipSlotNum()
	local cfg = ItemData[self.id]

	if not cfg then
		return 0
	end

	if not self:isEquip() then
		return 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData]

	if not equipData then
		return 0
	end

	return equipData.chipNum or 0
end

function HatchItemSnapshot:forEachChipSlot(callback)
	local chipSlotNum = self:getChipSlotNum()

	if chipSlotNum == 0 then
		return
	end

	for i = 1, chipSlotNum do
		local data = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. i]

		if not data then
			break
		end

		callback(i, data.type or 0, data.id or 0, data.ownerUid or "")
	end
end

function HatchItemSnapshot:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function HatchItemSnapshot:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function HatchItemSnapshot:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function HatchItemSnapshot:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function HatchItemSnapshot:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function HatchItemSnapshot:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function HatchItemSnapshot:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function HatchItemSnapshot:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function HatchItemSnapshot:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

return HatchItemSnapshot
