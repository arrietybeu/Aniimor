-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\HomelandItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local HomelandItem = class.LiteClass("HomelandItem", CustomDict)
local bit = bit

function HomelandItem.getCodec()
	if HomelandItem.protoCodec == nil then
		if pg.component == "game" then
			HomelandItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			HomelandItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return HomelandItem.protoCodec
end

function HomelandItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function HomelandItem:stackable()
	return self:maxCount() > 1
end

function HomelandItem:isFullPile()
	return self:maxCount() == self.count
end

function HomelandItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function HomelandItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function HomelandItem:getInvID()
	return ItemConst.INV_TYPE_HOMELAND
end

function HomelandItem:getCount()
	return self.count
end

function HomelandItem:setCount(count)
	self.count = count
end

function HomelandItem:getProps()
	return self.props
end

function HomelandItem:setProps(props)
	self.props = props
end

function HomelandItem:getGenID()
	return self.genID
end

function HomelandItem:setGenID(genID)
	self.genID = genID
end

function HomelandItem:getObjID()
	return ""
end

function HomelandItem:setObjID()
	return
end

function HomelandItem:getIsBind()
	return true
end

function HomelandItem:setIsBind()
	return
end

function HomelandItem:getUseTimes()
	return 0
end

function HomelandItem:setUseTimes()
	return
end

function HomelandItem:getStatus()
	return self.status
end

function HomelandItem:setStatus(status)
	self.status = status
end

function HomelandItem:getValidStartTime()
	return self.vaildStartTime
end

function HomelandItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function HomelandItem:getValidEndTime()
	return self.vaildEndTime
end

function HomelandItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function HomelandItem:getExtraProp()
	return nil
end

function HomelandItem:getOwnerUid()
	return ""
end

function HomelandItem:setOwnerUid()
	return
end

function HomelandItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "HomelandItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function HomelandItem:getChipSlotNum()
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

function HomelandItem:forEachChipSlot(callback)
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

function HomelandItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function HomelandItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function HomelandItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function HomelandItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function HomelandItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function HomelandItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function HomelandItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function HomelandItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function HomelandItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function HomelandItem:forEachAntiqueAffix(cb)
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

return HomelandItem
