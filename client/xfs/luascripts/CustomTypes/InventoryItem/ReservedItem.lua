-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\ReservedItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local ReservedItem = class.LiteClass("ReservedItem", CustomDict)
local bit = bit

function ReservedItem.getCodec()
	if ReservedItem.protoCodec == nil then
		if pg.component == "game" then
			ReservedItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			ReservedItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return ReservedItem.protoCodec
end

function ReservedItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function ReservedItem:stackable()
	return self:maxCount() > 1
end

function ReservedItem:isFullPile()
	return self:maxCount() == self.count
end

function ReservedItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function ReservedItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function ReservedItem:getInvID()
	return ItemConst.INV_TYPE_RESERVED
end

function ReservedItem:getCount()
	return self.count
end

function ReservedItem:setCount(count)
	self.count = count
end

function ReservedItem:getProps()
	return self.props
end

function ReservedItem:setProps(props)
	self.props = props
end

function ReservedItem:getGenID()
	return self.genID
end

function ReservedItem:setGenID(genID)
	self.genID = genID
end

function ReservedItem:getObjID()
	return self.objID
end

function ReservedItem:setObjID(objID)
	self.objID = objID
end

function ReservedItem:getIsBind()
	return true
end

function ReservedItem:setIsBind()
	return
end

function ReservedItem:getUseTimes()
	return self.useTimes
end

function ReservedItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function ReservedItem:getStatus()
	return self.status
end

function ReservedItem:setStatus(status)
	self.status = status
end

function ReservedItem:getValidStartTime()
	return self.vaildStartTime
end

function ReservedItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function ReservedItem:getValidEndTime()
	return self.vaildEndTime
end

function ReservedItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function ReservedItem:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function ReservedItem:getOwnerUid()
	return self.owner
end

function ReservedItem:setOwnerUid(ownerUid)
	self.owner = ownerUid
end

function ReservedItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "ReservedItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function ReservedItem:getChipSlotNum()
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

function ReservedItem:forEachChipSlot(callback)
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

function ReservedItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function ReservedItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function ReservedItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function ReservedItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function ReservedItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function ReservedItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function ReservedItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function ReservedItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function ReservedItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function ReservedItem:forEachAntiqueAffix(cb)
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

return ReservedItem
