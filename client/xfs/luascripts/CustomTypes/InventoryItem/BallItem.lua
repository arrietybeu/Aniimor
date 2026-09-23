-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\BallItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local BallItem = class.LiteClass("BallItem", CustomDict)
local bit = bit

function BallItem.getCodec()
	if BallItem.protoCodec == nil then
		if pg.component == "game" then
			BallItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			BallItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return BallItem.protoCodec
end

function BallItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function BallItem:stackable()
	return self:maxCount() > 1
end

function BallItem:isFullPile()
	return self:maxCount() == self.count
end

function BallItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function BallItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function BallItem:getInvID()
	return ItemConst.INV_TYPE_BALL
end

function BallItem:getCount()
	return self.count
end

function BallItem:setCount(count)
	self.count = count
end

function BallItem:getProps()
	return self.props
end

function BallItem:setProps(props)
	self.props = props
end

function BallItem:getGenID()
	return self.genID
end

function BallItem:setGenID(genID)
	self.genID = genID
end

function BallItem:getObjID()
	return ""
end

function BallItem:setObjID()
	return
end

function BallItem:getIsBind()
	return true
end

function BallItem:setIsBind()
	return
end

function BallItem:getUseTimes()
	return 0
end

function BallItem:setUseTimes()
	return
end

function BallItem:getStatus()
	return self.status
end

function BallItem:setStatus(status)
	self.status = status
end

function BallItem:getValidStartTime()
	return self.vaildStartTime
end

function BallItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function BallItem:getValidEndTime()
	return self.vaildEndTime
end

function BallItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function BallItem:getExtraProp()
	return nil
end

function BallItem:getOwnerUid()
	return ""
end

function BallItem:setOwnerUid()
	return
end

function BallItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "BallItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function BallItem:getChipSlotNum()
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

function BallItem:forEachChipSlot(callback)
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

function BallItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function BallItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function BallItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function BallItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function BallItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function BallItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function BallItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function BallItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function BallItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function BallItem:forEachAntiqueAffix(cb)
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

return BallItem
