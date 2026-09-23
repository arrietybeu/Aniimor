-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\HomelandFurnitureItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local HomelandFurnitureItem = class.LiteClass("HomelandFurnitureItem", CustomDict)
local bit = bit

function HomelandFurnitureItem.getCodec()
	if HomelandFurnitureItem.protoCodec == nil then
		if pg.component == "game" then
			HomelandFurnitureItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			HomelandFurnitureItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return HomelandFurnitureItem.protoCodec
end

function HomelandFurnitureItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function HomelandFurnitureItem:stackable()
	return self:maxCount() > 1
end

function HomelandFurnitureItem:isFullPile()
	return self:maxCount() == self.count
end

function HomelandFurnitureItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function HomelandFurnitureItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function HomelandFurnitureItem:getInvID()
	return ItemConst.INV_TYPE_HOMELAND_FURNITURE
end

function HomelandFurnitureItem:getCount()
	return self.count
end

function HomelandFurnitureItem:setCount(count)
	self.count = count
end

function HomelandFurnitureItem:getProps()
	return self.props
end

function HomelandFurnitureItem:setProps(props)
	self.props = props
end

function HomelandFurnitureItem:getGenID()
	return self.genID
end

function HomelandFurnitureItem:setGenID(genID)
	self.genID = genID
end

function HomelandFurnitureItem:getObjID()
	return ""
end

function HomelandFurnitureItem:setObjID()
	return
end

function HomelandFurnitureItem:getIsBind()
	return true
end

function HomelandFurnitureItem:setIsBind()
	return
end

function HomelandFurnitureItem:getUseTimes()
	return 0
end

function HomelandFurnitureItem:setUseTimes()
	return
end

function HomelandFurnitureItem:getStatus()
	return self.status
end

function HomelandFurnitureItem:setStatus(status)
	self.status = status
end

function HomelandFurnitureItem:getValidStartTime()
	return self.vaildStartTime
end

function HomelandFurnitureItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function HomelandFurnitureItem:getValidEndTime()
	return self.vaildEndTime
end

function HomelandFurnitureItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function HomelandFurnitureItem:getExtraProp()
	return
end

function HomelandFurnitureItem:getOwnerUid()
	return ""
end

function HomelandFurnitureItem:setOwnerUid()
	return
end

function HomelandFurnitureItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "HomelandFurnitureItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function HomelandFurnitureItem:getChipSlotNum()
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

function HomelandFurnitureItem:forEachChipSlot(callback)
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

function HomelandFurnitureItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function HomelandFurnitureItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function HomelandFurnitureItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function HomelandFurnitureItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function HomelandFurnitureItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function HomelandFurnitureItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function HomelandFurnitureItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function HomelandFurnitureItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function HomelandFurnitureItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function HomelandFurnitureItem:forEachAntiqueAffix(cb)
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

return HomelandFurnitureItem
