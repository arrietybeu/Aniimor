-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\PetJewelryItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemProperties = require("CustomTypes.ItemProperties")
local PetJewelryItem = class.LiteClass("PetJewelryItem", CustomDict)

function PetJewelryItem.getCodec()
	if PetJewelryItem.protoCodec == nil then
		if pg.component == "game" then
			PetJewelryItem.protoCodec = require("Core.Server.GameServerRepo").protoCodec
		else
			PetJewelryItem.protoCodec = require("Core.Client.ClientRepo").protoCodec
		end
	end

	return PetJewelryItem.protoCodec
end

function PetJewelryItem:maxCount()
	return 1
end

function PetJewelryItem:stackable()
	return false
end

function PetJewelryItem:isFullPile()
	return true
end

function PetJewelryItem:hasStatus(status)
	return false
end

function PetJewelryItem:isStatusLocked()
	return false
end

function PetJewelryItem:getInvID()
	return ItemConst.INV_TYPE_PET_JEWELRY
end

function PetJewelryItem:getCount()
	return 1
end

function PetJewelryItem:setCount(count)
	return
end

function PetJewelryItem:getProps()
	return ItemProperties({})
end

function PetJewelryItem:setProps(props)
	return
end

function PetJewelryItem:getGenID()
	return self.genID
end

function PetJewelryItem:setGenID(genID)
	self.genID = genID
end

function PetJewelryItem:getObjID()
	return ""
end

function PetJewelryItem:setObjID(objID)
	return
end

function PetJewelryItem:getIsBind()
	return true
end

function PetJewelryItem:setIsBind(isBind)
	return
end

function PetJewelryItem:getUseTimes()
	return 0
end

function PetJewelryItem:setUseTimes(useTimes)
	return
end

function PetJewelryItem:getStatus()
	return 0
end

function PetJewelryItem:setStatus(status)
	return
end

function PetJewelryItem:getValidStartTime()
	return 0
end

function PetJewelryItem:setValidStartTime(validStartTime)
	return
end

function PetJewelryItem:getValidEndTime()
	return 0
end

function PetJewelryItem:setValidEndTime(validEndTime)
	return
end

function PetJewelryItem:getExtraProp()
	return nil
end

function PetJewelryItem:getOwnerUid()
	return ""
end

function PetJewelryItem:setOwnerUid(ownerUid)
	return
end

function PetJewelryItem:repr()
	return string.format("%s(genID=%d, id=%d, count=1)", tostring(self.className or "PetJewelryItem"), self.genID, self.id)
end

function PetJewelryItem:getChipSlotNum()
	return 0
end

function PetJewelryItem:forEachChipSlot(callback)
	return
end

function PetJewelryItem:getDurability()
	return 0, 0
end

function PetJewelryItem:isEquip()
	return false
end

function PetJewelryItem:isChip()
	return false
end

function PetJewelryItem:isRepairKit()
	return false
end

function PetJewelryItem:getRepairValue()
	return 0, 0
end

function PetJewelryItem:getChipId(slotIdx)
	return nil
end

function PetJewelryItem:checkChipSlotValid(slotIdx)
	return false
end

function PetJewelryItem:getChipType(slotIdx)
	return nil
end

function PetJewelryItem:getChips()
	return {}
end

function PetJewelryItem:forEachAntiqueAffix(cb)
	return
end

return PetJewelryItem
