-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\PetItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local PetItem = class.LiteClass("PetItem", CustomDict)
local bit = bit

function PetItem.getCodec()
	if PetItem.protoCodec == nil then
		if pg.component == "game" then
			PetItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			PetItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return PetItem.protoCodec
end

function PetItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function PetItem:stackable()
	return self:maxCount() > 1
end

function PetItem:isFullPile()
	return self:maxCount() == self.count
end

function PetItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function PetItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function PetItem:getInvID()
	return ItemConst.INV_TYPE_PET
end

function PetItem:getCount()
	return self.count
end

function PetItem:setCount(count)
	self.count = count
end

function PetItem:getProps()
	return self.props
end

function PetItem:setProps(props)
	self.props = props
end

function PetItem:getGenID()
	return self.genID
end

function PetItem:setGenID(genID)
	self.genID = genID
end

function PetItem:getObjID()
	return ""
end

function PetItem:setObjID()
	return
end

function PetItem:getIsBind()
	return true
end

function PetItem:setIsBind()
	return
end

function PetItem:getUseTimes()
	return 0
end

function PetItem:setUseTimes()
	return
end

function PetItem:getStatus()
	return self.status
end

function PetItem:setStatus(status)
	self.status = status
end

function PetItem:getValidStartTime()
	return self.vaildStartTime
end

function PetItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function PetItem:getValidEndTime()
	return self.vaildEndTime
end

function PetItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function PetItem:getExtraProp()
	return
end

function PetItem:getOwnerUid()
	return ""
end

function PetItem:setOwnerUid(ownerUid)
	return
end

function PetItem:repr()
	return string.format("Item(genID=%d, id=%d, count=%d, isLock=%s)", self.genID, self.id, self.count, self:isStatusLocked())
end

function PetItem:getChipSlotNum()
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

function PetItem:forEachChipSlot(callback)
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

function PetItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function PetItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function PetItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function PetItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function PetItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function PetItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function PetItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function PetItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function PetItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function PetItem:forEachAntiqueAffix(cb)
	if not ItemUtils.isRefineable(self.id) then
		return
	end

	local refineData = self.props[ItemConst.ItemPropertyDef.AntiqueData]

	if not refineData then
		return
	end

	if refineData.affix_num < 0 then
		return
	end

	for i = 1, refineData.affix_num do
		local affixData = self.props[ItemConst.ItemPropertyDef.AntiqueData .. i]

		if affixData then
			cb(i, affixData.affixId, affixData.score)
		end
	end
end

return PetItem
