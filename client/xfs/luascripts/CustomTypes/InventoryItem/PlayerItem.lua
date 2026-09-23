-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\PlayerItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local PlayerItem = class.LiteClass("PlayerItem", CustomDict)
local bit = bit

function PlayerItem.getCodec()
	if PlayerItem.protoCodec == nil then
		if pg.component == "game" then
			PlayerItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			PlayerItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return PlayerItem.protoCodec
end

function PlayerItem:maxCount()
	return ItemUtils.getItemStackCount(self.id)
end

function PlayerItem:stackable()
	return self:maxCount() > 1
end

function PlayerItem:isFullPile()
	return self:maxCount() == self.count
end

function PlayerItem:hasStatus(status)
	local value = bit.lshift(1, status)

	return bit.band(self.status, value) == value
end

function PlayerItem:isStatusLocked()
	return self:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function PlayerItem:getInvID()
	return ItemConst.INV_TYPE_PLAYER
end

function PlayerItem:getCount()
	return self.count
end

function PlayerItem:setCount(count)
	self.count = count
end

function PlayerItem:getProps()
	return self.props
end

function PlayerItem:setProps(props)
	self.props = props
end

function PlayerItem:getGenID()
	return self.genID
end

function PlayerItem:setGenID(genID)
	self.genID = genID
end

function PlayerItem:getObjID()
	return self.objID
end

function PlayerItem:setObjID(objID)
	self.objID = objID
end

function PlayerItem:getIsBind()
	return true
end

function PlayerItem:setIsBind()
	return
end

function PlayerItem:getUseTimes()
	return self.useTimes
end

function PlayerItem:setUseTimes(useTimes)
	self.useTimes = useTimes
end

function PlayerItem:getStatus()
	return self.status
end

function PlayerItem:setStatus(status)
	self.status = status
end

function PlayerItem:getValidStartTime()
	return self.vaildStartTime
end

function PlayerItem:setValidStartTime(validStartTime)
	self.vaildStartTime = validStartTime
end

function PlayerItem:getValidEndTime()
	return self.vaildEndTime
end

function PlayerItem:setValidEndTime(validEndTime)
	self.vaildEndTime = validEndTime
end

function PlayerItem:getExtraProp()
	return self.extraProp ~= "" and self.getCodec():safeDecodeFromStr(self.extraProp) or nil
end

function PlayerItem:getOwnerUid()
	return ""
end

function PlayerItem:setOwnerUid()
	return
end

function PlayerItem:repr()
	return string.format("%s(genID=%d, id=%d, count=%d, isLock=%s)", tostring(self.className or "PlayerItem"), self.genID, self.id, self.count, self:isStatusLocked())
end

function PlayerItem:getChipSlotNum()
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

function PlayerItem:forEachChipSlot(callback)
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

function PlayerItem:getDurability()
	if not self:isEquip() then
		return 0, 0
	end

	local equipData = self.props[ItemConst.ItemPropertyDef.EquipData] or {}

	return equipData.durability or 0, equipData.maxDurability or 0
end

function PlayerItem:isEquip()
	local cfg = ItemData[self.id]

	return cfg and (cfg.type == ItemConst.ITEM_TYPE.WEAPON or cfg.type == ItemConst.ITEM_TYPE.ARMOR)
end

function PlayerItem:isChip()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.CHIP
end

function PlayerItem:isRepairKit()
	local cfg = ItemData[self.id]

	return cfg and cfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function PlayerItem:getRepairValue()
	if not self:isRepairKit() then
		return 0, 0
	end

	local repairKit = self.props[ItemConst.ItemPropertyDef.ChipRepairKit]

	if not repairKit then
		return 0, 0
	end

	return repairKit.repairValue or 0, repairKit.maxRepairValue or 0
end

function PlayerItem:getChipId(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.id, chip.ownerUid or ""
end

function PlayerItem:checkChipSlotValid(slotIdx)
	if not self:isEquip() then
		return false
	end

	local chipSlotNum = self:getChipSlotNum()

	return slotIdx > 0 and slotIdx <= chipSlotNum
end

function PlayerItem:getChipType(slotIdx)
	if not self:checkChipSlotValid(slotIdx) then
		return nil
	end

	local chip = self.props[ItemConst.ItemPropertyDef.ChipSlotKey .. slotIdx]

	if not chip then
		return nil
	end

	return chip.type
end

function PlayerItem:getChips()
	local chips = {}

	self:forEachChipSlot(function(pos, type, chipId)
		if ToBool(chipId) then
			table.insert(chips, chipId)
		end
	end)

	return chips
end

function PlayerItem:forEachAntiqueAffix(cb)
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

return PlayerItem
