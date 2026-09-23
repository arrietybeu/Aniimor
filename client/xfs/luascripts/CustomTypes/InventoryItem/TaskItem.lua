-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\TaskItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local TaskItem = class.LiteClass("TaskItem", CustomDict)
local bit = bit

function TaskItem.getCodec()
	if TaskItem.protoCodec == nil then
		if pg.component == "game" then
			TaskItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			TaskItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return TaskItem.protoCodec
end

function TaskItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function TaskItem:stackable()
	return self:maxCount() > 1
end

function TaskItem:isFullPile()
	return self:maxCount() == self.count
end

function TaskItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function TaskItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function TaskItem:getInvID()
	return ItemConst.INV_TYPE_TASK
end

function TaskItem:getCount()
	return self.count
end

function TaskItem:setCount(count)
	self.count = count
end

function TaskItem:getProps()
	return self.props
end

function TaskItem:setProps(props)
	self.props = props
end

function TaskItem:getGenID()
	return self.genID
end

function TaskItem:setGenID(genID)
	self.genID = genID
end

function TaskItem:getObjID()
	return ""
end

function TaskItem:setObjID()
	return
end

function TaskItem:getIsBind()
	return true
end

function TaskItem:setIsBind()
	return
end

function TaskItem:getUseTimes()
	return self.useTimes
end

function TaskItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function TaskItem:getStatus()
	return self.status
end

function TaskItem:setStatus(status)
	self.status = status
end

function TaskItem:getValidStartTime()
	return self.vaildStartTime
end

function TaskItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function TaskItem:getValidEndTime()
	return self.vaildEndTime
end

function TaskItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function TaskItem:getExtraProp()
	return nil
end

function TaskItem:getOwnerUid()
	return ""
end

function TaskItem:setOwnerUid()
	return
end

function TaskItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "TaskItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function TaskItem:getChipSlotNum()
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

function TaskItem:forEachChipSlot(callback)
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

function TaskItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function TaskItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function TaskItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function TaskItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function TaskItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function TaskItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function TaskItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function TaskItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function TaskItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function TaskItem:forEachAntiqueAffix(cb)
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

return TaskItem
