-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\CommonItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local CommonItem = class.LiteClass("CommonItem", CustomDict)
local bit = bit

function CommonItem.getCodec()
	if CommonItem.protoCodec == nil then
		if pg.component == "game" then
			CommonItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			CommonItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return CommonItem.protoCodec
end

function CommonItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function CommonItem:stackable()
	return self:maxCount() > 1
end

function CommonItem:isFullPile()
	return self:maxCount() == self.count
end

function CommonItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function CommonItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function CommonItem:getInvID()
	return ItemConst.INV_TYPE_COMMON
end

function CommonItem:getCount()
	return self.count
end

function CommonItem:setCount(count)
	self.count = count
end

function CommonItem:getProps()
	return self.props
end

function CommonItem:setProps(props)
	self.props = props
end

function CommonItem:getGenID()
	return self.genID
end

function CommonItem:setGenID(genID)
	self.genID = genID
end

function CommonItem:getObjID()
	return self.objID
end

function CommonItem:setObjID(objID)
	self.objID = objID
end

function CommonItem:getIsBind()
	return true
end

function CommonItem:setIsBind()
	return
end

function CommonItem:getUseTimes()
	return self.useTimes
end

function CommonItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function CommonItem:getStatus()
	return self.status
end

function CommonItem:setStatus(status)
	self.status = status
end

function CommonItem:getValidStartTime()
	return self.vaildStartTime
end

function CommonItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function CommonItem:getValidEndTime()
	return self.vaildEndTime
end

function CommonItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function CommonItem:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function CommonItem:getOwnerUid()
	return self.owner
end

function CommonItem:setOwnerUid(ownerUid)
	self.owner = ownerUid
end

function CommonItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "CommonItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function CommonItem:getChipSlotNum()
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

function CommonItem:forEachChipSlot(callback)
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

function CommonItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function CommonItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function CommonItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function CommonItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function CommonItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function CommonItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function CommonItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function CommonItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function CommonItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function CommonItem:forEachAntiqueAffix(cb)
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

return CommonItem
