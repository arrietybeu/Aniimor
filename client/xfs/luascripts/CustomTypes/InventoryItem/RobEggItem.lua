-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\RobEggItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local RobEggItem = class.LiteClass("RobEggItem", CustomDict)
local bit = bit

function RobEggItem.getCodec()
	if RobEggItem.protoCodec == nil then
		if pg.component == "game" then
			RobEggItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			RobEggItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return RobEggItem.protoCodec
end

function RobEggItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function RobEggItem:stackable()
	return self:maxCount() > 1
end

function RobEggItem:isFullPile()
	return self:maxCount() == self.count
end

function RobEggItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function RobEggItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function RobEggItem:getInvID()
	return ItemUtils.getInvIdByItemId(self.id)
end

function RobEggItem:getCount()
	return self.count
end

function RobEggItem:setCount(count)
	self.count = count
end

function RobEggItem:getProps()
	return self.props
end

function RobEggItem:setProps(props)
	self.props = props
end

function RobEggItem:getGenID()
	return self.genID
end

function RobEggItem:setGenID(genID)
	self.genID = genID
end

function RobEggItem:getObjID()
	return self.objID
end

function RobEggItem:setObjID(objID)
	self.objID = objID
end

function RobEggItem:getIsBind()
	return true
end

function RobEggItem:setIsBind()
	return
end

function RobEggItem:getUseTimes()
	return self.useTimes
end

function RobEggItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function RobEggItem:getStatus()
	return self.status
end

function RobEggItem:setStatus(status)
	self.status = status
end

function RobEggItem:getValidStartTime()
	return self.vaildStartTime
end

function RobEggItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function RobEggItem:getValidEndTime()
	return self.vaildEndTime
end

function RobEggItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function RobEggItem:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function RobEggItem:getOwnerUid()
	return self.owner
end

function RobEggItem:setOwnerUid(ownerUid)
	self.owner = ownerUid
end

function RobEggItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "RobEggItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function RobEggItem:getChipSlotNum()
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

function RobEggItem:forEachChipSlot(callback)
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

function RobEggItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function RobEggItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function RobEggItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function RobEggItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function RobEggItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function RobEggItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function RobEggItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function RobEggItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function RobEggItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function RobEggItem:forEachAntiqueAffix(cb)
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

return RobEggItem
