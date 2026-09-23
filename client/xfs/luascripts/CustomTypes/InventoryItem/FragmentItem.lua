-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\FragmentItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local FragmentItem = class.LiteClass("FragmentItem", CustomDict)
local bit = bit

function FragmentItem.getCodec()
	if FragmentItem.protoCodec == nil then
		if pg.component == "game" then
			FragmentItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			FragmentItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return FragmentItem.protoCodec
end

function FragmentItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function FragmentItem:stackable()
	return self:maxCount() > 1
end

function FragmentItem:isFullPile()
	return self:maxCount() == self.count
end

function FragmentItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function FragmentItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function FragmentItem:getInvID()
	return ItemConst.INV_TYPE_FRAGMENT
end

function FragmentItem:getCount()
	return self.count
end

function FragmentItem:setCount(count)
	self.count = count
end

function FragmentItem:getProps()
	return self.props
end

function FragmentItem:setProps(props)
	self.props = props
end

function FragmentItem:getGenID()
	return self.genID
end

function FragmentItem:setGenID(genID)
	self.genID = genID
end

function FragmentItem:getObjID()
	return self.objID
end

function FragmentItem:setObjID(objID)
	self.objID = objID
end

function FragmentItem:getIsBind()
	return true
end

function FragmentItem:setIsBind()
	return
end

function FragmentItem:getUseTimes()
	return self.useTimes
end

function FragmentItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function FragmentItem:getStatus()
	return self.status
end

function FragmentItem:setStatus(status)
	self.status = status
end

function FragmentItem:getValidStartTime()
	return self.vaildStartTime
end

function FragmentItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function FragmentItem:getValidEndTime()
	return self.vaildEndTime
end

function FragmentItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function FragmentItem:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function FragmentItem:getOwnerUid()
	return self.owner
end

function FragmentItem:setOwnerUid(ownerUid)
	self.owner = ownerUid
end

function FragmentItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "FragmentItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function FragmentItem:getChipSlotNum()
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

function FragmentItem:forEachChipSlot(callback)
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

function FragmentItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function FragmentItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function FragmentItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function FragmentItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function FragmentItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function FragmentItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function FragmentItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function FragmentItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function FragmentItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function FragmentItem:forEachAntiqueAffix(cb)
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

return FragmentItem
