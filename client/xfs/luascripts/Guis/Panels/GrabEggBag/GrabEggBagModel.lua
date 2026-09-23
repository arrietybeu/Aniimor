-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\GrabEggBagModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggBagModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggBagModel = Class.LightClass("GrabEggBagModel", UIModel)
local HotkeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local RobEggConst = require("Common.Const.RobEggConst")
local tSort = table.sort
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local InventoryData = require("Data.inventory_data")
local ItemThirdPageData = require("Data.item_third_page_data")
local GameStringConfig = require("Data.gamestring_config_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local RobEggItemIn = require("Data.rob_egg_item_in")
local SysConfigData = require("Data.sys_config_data")
local RobEggChipData = require("Data.robegg_chip_data")
local RobEggRepairKitData = require("Data.robegg_repair_kit_data")
local RobEggEquipData = require("Data.robegg_equip_data")
local RobEggTalentData = require("Data.rob_egg_talent_data")
local ConflictTypes = require("Common.ConflictTypes")
local CALCINATION_GOTO_TEXT_KEY = "GRAB_EGG_CALCINATION_GOTO"
local CALCINATION_GOTO_DEFAULT_TEXT = "去煅烧"

local function getGameStringOrDefault(key, defaultText)
	local text = pg.getGameString(key)

	if not text or text == "" or text == key or tonumber(text) then
		return defaultText
	end

	return text
end

GrabEggBagModel.STATE_NORMAL = 0
GrabEggBagModel.STATE_DECOMPOSE = 1
GrabEggBagModel.SORT_IDX_DEFAULT = 0
GrabEggBagModel.SORT_IDX_QUALITY = 1
GrabEggBagModel.SORT_IDX_TYPE = 2
GrabEggBagModel.INVENTORY_DRAG_AREA = "INVENTORY_DRAG_AREA"
GrabEggBagModel.BAG_DRAG_AREA = "BAG_DRAG_AREA"
GrabEggBagModel.DISCARD_DRAG_AREA = "DISCARD_DRAG_AREA"

function GrabEggBagModel:ctor()
	UIModel.ctor(self)

	self.SORT_DESC = {
		[self.SORT_IDX_DEFAULT] = "DEFAULT_SORT",
		[self.SORT_IDX_QUALITY] = "QUALITY",
		[self.SORT_IDX_TYPE] = "TYPE"
	}
	self.operationSate = GrabEggBagModel.STATE_NORMAL
	self.sortIsAscending = true
	self.curInventoryInvId = -1
	self.invId2thirdTabList = {}
	self.inventorySortType = self.SORT_IDX_DEFAULT
	self.bagType = nil
	self.boxEntityId = nil
	self.resourceData = {}
	self.resourceBoxName = ""
	self.showWeight = false
	self.hoverData = nil
	self.nearbySlotMap = {}
end

function GrabEggBagModel:setBagType(type)
	self.bagType = type
end

function GrabEggBagModel:getBagType()
	return self.bagType
end

function GrabEggBagModel:setInventoryInvId(invId)
	self.curInventoryInvId = invId
end

function GrabEggBagModel:getInventoryInvId()
	return self.curInventoryInvId
end

function GrabEggBagModel:setOperationState(state)
	self.operationSate = state
end

function GrabEggBagModel:isInOperationState(state)
	return self.operationSate == state
end

function GrabEggBagModel:getPropsCount(invId)
	invId = invId or self.curInventoryInvId

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invId)

	return bag:getCount()
end

function GrabEggBagModel:getCapacity(invId)
	invId = invId or self.curInventoryInvId

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invId)

	return bag:getCapacity()
end

function GrabEggBagModel:getMainTabList()
	local tabList = {}

	for invId, v in pairs(InventoryData) do
		if v.showInEggRob == 1 then
			local tab = {}

			tab.name = pg.getLocalizationText(v.bagName)
			tab.state = v.funcType == 99 and 3 or v.funcType - 1
			tab.order = v.sort
			tab.invId = invId
			tab.funcType = v.funcType
			tab.default = v.default
			tab.icon = v.icon
			tabList[#tabList + 1] = tab
		end
	end

	table.sort(tabList, function(a, b)
		return a.order < b.order
	end)

	return tabList
end

function GrabEggBagModel:getThirdTabList(invId)
	invId = invId or self.curInventoryInvId

	if not self.invId2thirdTabList[invId] then
		self.invId2thirdTabList[invId] = {}

		if InventoryData[invId] and InventoryData[invId].thirdPage then
			local thirdPageList = InventoryData[invId].thirdPage
			local ret = self.invId2thirdTabList[invId]

			for _, id in ipairs(thirdPageList) do
				local curData = ItemThirdPageData[id]

				ret[#ret + 1] = {
					paginationId = id,
					nameHashId = curData.name
				}
			end

			table.sort(ret, function(a, b)
				local sortA = ItemThirdPageData[a.paginationId].displayPriority
				local sortB = ItemThirdPageData[b.paginationId].displayPriority

				return sortB < sortA
			end)

			ret[#ret + 1] = {
				paginationId = -1,
				nameHashId = GameStringConfig.ALL.desc
			}
		end
	end

	return self.invId2thirdTabList[invId]
end

function GrabEggBagModel:getInventoryPropList(paginationId)
	local ret = LuaUIUtils.getInventoryProps(self.curInventoryInvId, paginationId)

	for i = 1, #ret do
		ret[i].canCarryToRace = RobEggItemOut[ret[i].itemId] and true or false
	end

	if self.inventorySortType == self.SORT_IDX_QUALITY then
		tSort(ret, function(c1, c2)
			local canCarry1 = c1.canCarryToRace and 1 or 0
			local canCarry2 = c2.canCarryToRace and 1 or 0

			if canCarry1 ~= canCarry2 then
				return canCarry2 < canCarry1
			end

			local slot1 = c1.bindCatchBallSlot and c1.bindCatchBallSlot or math.maxInt
			local slot2 = c2.bindCatchBallSlot and c2.bindCatchBallSlot or math.maxInt

			if slot1 ~= slot2 then
				return slot1 < slot2
			end

			if c1.quality ~= c2.quality then
				if self.sortIsAscending == true then
					return c1.quality < c2.quality
				else
					return c1.quality > c2.quality
				end
			end

			if c1.itemId ~= c2.itemId then
				return c1.itemId < c2.itemId
			end

			return c1.genID < c2.genID
		end)
	elseif self.inventorySortType == self.SORT_IDX_TYPE then
		tSort(ret, function(c1, c2)
			local canCarry1 = c1.canCarryToRace and 1 or 0
			local canCarry2 = c2.canCarryToRace and 1 or 0

			if canCarry1 ~= canCarry2 then
				return canCarry2 < canCarry1
			end

			local slot1 = c1.bindCatchBallSlot and c1.bindCatchBallSlot or math.maxInt
			local slot2 = c2.bindCatchBallSlot and c2.bindCatchBallSlot or math.maxInt

			if slot1 ~= slot2 then
				return slot1 < slot2
			end

			if c1.displayType ~= c2.displayType then
				if self.sortIsAscending == true then
					return c1.displayType < c2.displayType
				else
					return c1.displayType > c2.displayType
				end
			end

			if c1.itemId ~= c2.itemId then
				return c1.itemId < c2.itemId
			end

			return c1.genID < c2.genID
		end)
	else
		tSort(ret, function(c1, c2)
			local canCarry1 = c1.canCarryToRace and 1 or 0
			local canCarry2 = c2.canCarryToRace and 1 or 0

			if canCarry1 ~= canCarry2 then
				return canCarry2 < canCarry1
			end

			local slot1 = c1.bindCatchBallSlot and c1.bindCatchBallSlot or math.maxInt
			local slot2 = c2.bindCatchBallSlot and c2.bindCatchBallSlot or math.maxInt

			if slot1 ~= slot2 then
				return slot1 < slot2
			end

			if c1.itemId ~= c2.itemId then
				if self.sortIsAscending == true then
					return c1.itemId < c2.itemId
				else
					return c1.itemId > c2.itemId
				end
			end

			return c1.genID < c2.genID
		end)
	end

	return ret
end

function GrabEggBagModel:getPropsByDecomposeSelectedList(selectedList)
	local ret = {}
	local player = pg.me
	local tabList = self:getMainTabList()

	for _, value in pairs(tabList) do
		local invId = value.invId
		local bag = ItemUtils.getTypedBag(player, invId) or {}

		for k, _ in pairs(selectedList) do
			if bag[k] ~= nil then
				local item = LuaUIUtils.getItemClientInfoById(bag[k].id)

				item.index = k
				item.packSlot = bag[k]
				ret[#ret + 1] = item
			end
		end
	end

	tSort(ret, function(c1, c2)
		return c1.index < c2.index
	end)

	return ret
end

function GrabEggBagModel:setSortAscendingOrder(isAscending)
	self.sortIsAscending = isAscending
end

function GrabEggBagModel:setSortIdxType(type)
	self.inventorySortType = type
end

function GrabEggBagModel:getSortOptions()
	local ret = {}

	for idx, sortDesc in pairs(self.SORT_DESC) do
		ret[idx + 1] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return ret
end

function GrabEggBagModel:getInventorySortType()
	if not self.inventorySortType then
		self.inventorySortType = GrabEggBagModel.SORT_IDX_DEFAULT
	end

	return self.inventorySortType
end

function GrabEggBagModel:checkItemDisable(data)
	local isLock = data.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

	return isLock
end

function GrabEggBagModel:setHoverData(data)
	if data ~= nil and data.itemId == nil then
		self.hoverData = nil
	else
		self.hoverData = data
	end
end

function GrabEggBagModel:getHoverData()
	return self.hoverData
end

function GrabEggBagModel:getBagData()
	return self:getBagItemDataBySlot(ItemConst.ROB_EGG_EQUIP_SLOT.BAG, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

function GrabEggBagModel:getEggData()
	return self:getBagItemDataBySlot(ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN, ItemConst.INV_TYPE_ROB_EGG)
end

function GrabEggBagModel:getNormalItemDataList(bagCapacity, list)
	bagCapacity = bagCapacity or 0

	local ret = {}
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN

	for i = beginPos, beginPos + bagCapacity - 1 do
		local item = self:getBagItemDataBySlot(i, ItemConst.INV_TYPE_ROB_EGG)

		ret[#ret + 1] = item
	end

	local fillTo = 20

	if list then
		fillTo = list:CalculateMainAxisFillCountByTIndex() * 4
	end

	fillTo = math.min(fillTo, 20)

	for i = bagCapacity + 1, fillTo do
		ret[#ret + 1] = {
			isMyBag = true,
			tIndex = 3,
			empty = true
		}
	end

	return ret
end

function GrabEggBagModel:getBagItemDataBySlot(i, invId)
	local packSlot = pg.me:getItemFromBagSlotIndex(i, invId)
	local itemId = packSlot and packSlot.id
	local item = itemId and LuaUIUtils.getItemClientInfoById(itemId) or {
		empty = true
	}

	if itemId then
		item.packSlot = packSlot
		item.count = packSlot.count
		item.genID = packSlot.genID
	end

	item.invId = invId
	item.tIndex = item.itemId and 0 or 1
	item.slotIndex = i
	item.isMyBag = true
	item.ownerUid = packSlot and packSlot:getOwnerUid()

	return item
end

function GrabEggBagModel:getMyBagEffectData()
	local packSlot = pg.me:getItemFromBagSlotIndex(ItemConst.ROB_EGG_EQUIP_SLOT.BAG, ItemConst.INV_TYPE_EQUIP_SLOTS)
	local itemId = packSlot and packSlot.id

	return ItemEffectData[itemId]
end

function GrabEggBagModel:getMyBagCapacity()
	local effectData = self:getMyBagEffectData()

	if not effectData then
		return 0
	end

	return effectData.volume or 0
end

function GrabEggBagModel:getMyBagEggCapacity()
	local effectData = self:getMyBagEffectData()

	if not effectData then
		return 0
	end

	return effectData.eggvolume or 0
end

function GrabEggBagModel:getMyLoadAdd()
	local effectData = self:getMyBagEffectData()

	if not effectData then
		return 0
	end

	return effectData.load or 0
end

function GrabEggBagModel:getMyLoadLimit()
	return pg.me.curLoadBearing
end

function GrabEggBagModel:getMyCurLoad()
	return pg.me.curLoad
end

function GrabEggBagModel:getLoadState(curWeight, loadLimit)
	curWeight = curWeight or self:getMyCurLoad()
	loadLimit = loadLimit or self:getMyLoadLimit()

	local proportion = (loadLimit == 0 and 0 or curWeight / loadLimit) * 100
	local weightRange = SysConfigData.WEIGHT_RANGE

	for i = #weightRange, 2, -1 do
		if proportion > weightRange[i] then
			return i - 1
		end
	end

	return 0
end

function GrabEggBagModel:getOverloadBubbleId(state)
	if not state or state < 1 then
		return nil
	end

	return 101002 + state
end

function GrabEggBagModel:getMyEquipmentValue()
	if not pg.me or not self:isInGrabEggSpace() then
		return 0
	end

	return pg.me.achievedCoin or 0
end

function GrabEggBagModel:getMyBagNormalItemCount()
	local myBagCapacity = self:getMyBagCapacity()
	local count = 0
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN

	for i = beginPos, beginPos + myBagCapacity - 1 do
		local packSlot = pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_ROB_EGG)

		if packSlot then
			count = count + 1
		end
	end

	return count
end

function GrabEggBagModel:getMyBagEmptyIndex(type)
	local myBagCapacity = self:getMyBagCapacity()
	local haveBag = myBagCapacity > 0

	if type == ItemConst.ITEM_TYPE.EGG then
		return haveBag and ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN or nil
	end

	local index
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN

	for i = beginPos, beginPos + myBagCapacity - 1 do
		local packSlot = pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_ROB_EGG)

		if not packSlot then
			index = i

			return index, haveBag
		end
	end

	return index, haveBag
end

function GrabEggBagModel:getSafeBoxEmptyIndex()
	local showCount = self:getSafeBoxSlotCount()
	local unlockCount = pg.me.safeBoxNum or 0
	local count = math.min(showCount, unlockCount)

	for i = ItemConst.ROB_EGG_SAFE_SLOT.MIN, ItemConst.ROB_EGG_SAFE_SLOT.MIN + count - 1 do
		local packSlot = pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_EQUIP_SLOTS)

		if not packSlot then
			return i
		end
	end

	return nil
end

function GrabEggBagModel:getMyEquipEmptyIndex(type, itemId)
	local index

	if type == ItemConst.ITEM_TYPE.BAG then
		index = ItemConst.ROB_EGG_EQUIP_SLOT.BAG
	elseif type == ItemConst.ITEM_TYPE.WEAPON then
		index = ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON
	elseif type == ItemConst.ITEM_TYPE.ARMOR then
		index = ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR
	end

	return index
end

function GrabEggBagModel:getDoubleClickIndex(type, itemId)
	local index

	if type == ItemConst.ITEM_TYPE.BAG then
		index = ItemConst.ROB_EGG_EQUIP_SLOT.BAG
	elseif type == ItemConst.ITEM_TYPE.WEAPON then
		local packSlot = pg.me:getItemFromBagSlotIndex(ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON, ItemConst.INV_TYPE_EQUIP_SLOTS)

		if not packSlot then
			index = ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON
		end
	elseif type == ItemConst.ITEM_TYPE.ARMOR then
		local packSlot = pg.me:getItemFromBagSlotIndex(ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR, ItemConst.INV_TYPE_EQUIP_SLOTS)

		if not packSlot then
			index = ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR
		end
	end

	return index
end

function GrabEggBagModel:isEquipBagSlot(index)
	local number = tonumber(index)

	if number and (number == ItemConst.ROB_EGG_EQUIP_SLOT.BAG or number == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or number == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR) then
		return true
	end

	return false
end

function GrabEggBagModel:isEquipBagType(type, containBag)
	if containBag and type == ItemConst.ITEM_TYPE.BAG or type == ItemConst.ITEM_TYPE.WEAPON or type == ItemConst.ITEM_TYPE.ARMOR or type == ItemConst.ITEM_TYPE.CHIP then
		return true
	end

	return false
end

function GrabEggBagModel:checkTypeCanPutInSlot(type, itemId, slot)
	local inNormalArea = slot >= ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN and slot <= ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_END or self:isSafeBoxSlot(slot)

	if type == ItemConst.ITEM_TYPE.EGG then
		return slot >= ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN and slot <= ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_END
	end

	if type == ItemConst.ITEM_TYPE.BAG then
		return slot == ItemConst.ROB_EGG_EQUIP_SLOT.BAG
	end

	if type == ItemConst.ITEM_TYPE.WEAPON then
		return slot == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or inNormalArea
	end

	if type == ItemConst.ITEM_TYPE.ARMOR then
		return slot == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR or inNormalArea
	end

	if type == ItemConst.ITEM_TYPE.CHIP or type == ItemConst.ITEM_TYPE.REPAIR_KIT then
		return inNormalArea
	end

	return inNormalArea
end

function GrabEggBagModel:isInGrabEggSpace()
	if pg.me and pg.me.space and Utils.isRobEggSceneId(pg.me.space.sceneId) then
		return true
	end

	return false
end

function GrabEggBagModel:canUseItem(type)
	if not self:isInGrabEggSpace() then
		return false
	end

	return type == ItemConst.ITEM_TYPE.REPAIR_KIT
end

function GrabEggBagModel:getItemRaceStackCount(outId)
	local data = RobEggItemOut[outId]
	local inId = data and data.inid

	if inId then
		return ItemUtils.getItemStackCount(inId)
	end

	return nil
end

function GrabEggBagModel:getMaxCountCanDragInInventory(itemId, count)
	local stackCountInRace = self:getItemRaceStackCount(itemId)

	if not stackCountInRace then
		return nil
	end

	return math.min(stackCountInRace, count)
end

function GrabEggBagModel:getInvIdOut(inId)
	local data = RobEggItemIn[inId]
	local outId = data and data.outid
	local itemData = ItemData[outId]

	if itemData then
		return itemData.invId
	end

	return nil
end

function GrabEggBagModel:getWeightIn(outId)
	return ItemUtils.getRobEggItemWeight(outId)
end

GrabEggBagModel.MONEY_REPAIR_COST_RATE_IN_SPACE = 1.5
GrabEggBagModel.USE_TYPE_CONFIG = {
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX] = {
		isLongPress = true,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickPress
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.USE] = {
		isLongPress = true,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.SPLIT] = {
		isLongPress = true,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart
	},
	[UIConst.GRAB_EGG_ITEM_USE_TYPE.CALCINATION] = {
		isLongPress = false,
		path = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	}
}

function GrabEggBagModel:getItemBtnDataListByType(itemData, typeSet, calcinationCloseCb)
	if not typeSet then
		return nil
	end

	local btnDataList = {}

	local function addBtn(useType, name, confirmFunc)
		local cfg = GrabEggBagModel.USE_TYPE_CONFIG[useType]

		if not cfg then
			return
		end

		btnDataList[#btnDataList + 1] = {
			name = name,
			confirmFunc = confirmFunc,
			path = cfg.path,
			isLongPress = cfg.isLongPress
		}
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR, self:isInGrabEggSpace() and pg.getGameString("GRAB_EGG_REPAIR_2") or pg.getGameString("GRAB_EGG_REPAIR"), function(itemInfo)
			if pg.game.input:isUsingGamepad() and self:isRepairingItem(itemData.invId, itemData.genID) then
				self:cancelRepairTimer()
				LuaUIUtils.popupPropTip()

				return
			end

			if itemData.type == ItemConst.ITEM_TYPE.WEAPON or itemData.type == ItemConst.ITEM_TYPE.ARMOR then
				self:tryRepairEquipByMoney(itemData)
			else
				self:tryRepairEquipWithKit(itemData, nil)
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY, pg.getGameString("GRAB_EGG_CARRY"), function(itemInfo)
			local carryNum = itemInfo[itemData.itemId] or 1
			local emptyIndex, haveBag = self:getMyBagEmptyIndex(itemData.type)

			if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
				if emptyIndex then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, carryNum)
				end
			elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
				if emptyIndex then
					self:collectItemToMyBag(itemData.entityId, itemData.interactId, emptyIndex)
				end
			elseif emptyIndex then
				self:takeItemFromBox(itemData.slotIndex, ItemConst.INV_TYPE_ROB_EGG, emptyIndex)
			end

			if not emptyIndex then
				if haveBag then
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_2"))
				end
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	if RobEggConst.CALCINATION_ENTRY_ENABLED and typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.CALCINATION] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.CALCINATION, getGameStringOrDefault(CALCINATION_GOTO_TEXT_KEY, CALCINATION_GOTO_DEFAULT_TEXT), function()
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_CALCINATION, {
				genID = itemData.genID
			}, nil, calcinationCloseCb)
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP, pg.getGameString("GRAB_EGG_EQUIP"), function(itemInfo)
			if itemData.type == ItemConst.ITEM_TYPE.CHIP then
				self:equipChipFromButton(itemData)
				LuaUIUtils.popupPropTip()

				return
			end

			local carryNum = itemInfo[itemData.itemId] or 1
			local index = self:getMyEquipEmptyIndex(itemData.type, itemData.itemId)

			if index then
				if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY or itemData.isMyBag then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, ItemConst.INV_TYPE_EQUIP_SLOTS, index, carryNum)
				elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
					self:collectItemToMyBag(itemData.entityId, itemData.interactId, index)
				else
					self:takeItemFromBox(itemData.slotIndex, ItemConst.INV_TYPE_EQUIP_SLOTS, index)
				end
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD] then
		local isSafeBox = self:isSafeBoxSlot(itemData.slotIndex)
		local isUnloadToBox = itemData.invId == ItemConst.INV_TYPE_ROB_EGG and self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX
		local btnName = not isUnloadToBox and (itemData.invId == ItemConst.INV_TYPE_ROB_EGG or isSafeBox) and pg.getGameString("GRAB_EGG_PUTBACK") or pg.getGameString("GRAB_EGG_UNLOAD")

		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.UNLOAD, btnName, function(itemInfo)
			local carryNum = itemInfo[itemData.itemId] or 1

			if itemData.type == ItemConst.ITEM_TYPE.CHIP and itemData.equipGenID then
				local emptyIndex = self:getMyBagEmptyIndex()

				if emptyIndex then
					self:removeChipFromEquip(itemData.invId, itemData.equipGenID, itemData.chipSlotIdx, ItemConst.INV_TYPE_ROB_EGG, emptyIndex)
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
				end

				LuaUIUtils.popupPropTip()

				return
			end

			if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
				if itemData.invId == ItemConst.INV_TYPE_ROB_EGG or itemData.type == ItemConst.ITEM_TYPE.BAG then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, 0, 0, carryNum)
				else
					local emptyIndex = self:getMyBagEmptyIndex()

					if emptyIndex then
						pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, carryNum)
					else
						pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, 0, 0, carryNum)
					end
				end
			elseif itemData.invId == ItemConst.INV_TYPE_EQUIP_SLOTS then
				if not isSafeBox and (itemData.type == ItemConst.ITEM_TYPE.WEAPON or itemData.type == ItemConst.ITEM_TYPE.ARMOR) and not self:checkUnloadEquipSpace(itemData.packSlot) then
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_EQUIP_PLACE_NOT_ENOUGH"))
					LuaUIUtils.popupPropTip()

					return
				end

				local emptyIndex = self:getMyBagEmptyIndex(itemData.type)

				if emptyIndex then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, carryNum)
				elseif isSafeBox and not self:isInGrabEggSpace() then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, 0, 0, carryNum)
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
				end
			elseif itemData.invId == ItemConst.INV_TYPE_ROB_EGG and self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX then
				local boxIndex = self:getResourceBoxEmptyIndex()

				if boxIndex then
					pg.me:serverMsg("RPC_CS_MoveItemToResourceBox", self:getBoxEntityId(), itemData.invId, itemData.genID, boxIndex, carryNum)
				else
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_RESOURCE_BOX_FULL"))
				end
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX] then
		local safeIndex = self:getSafeBoxEmptyIndex()

		if pg.game.input:isUsingGamepad() and safeIndex and self:checkDragRule(itemData, nil, safeIndex, false) then
			addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX, pg.getGameString("GRAB_EGG_SAFE_BOX"), function(itemInfo)
				local carryNum = itemInfo[itemData.itemId] or 1

				if itemData.isMyBag or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
					pg.me:serverMsg("RPC_CS_MoveRobEggItem", itemData.invId, itemData.genID, ItemConst.INV_TYPE_EQUIP_SLOTS, safeIndex, carryNum)
				elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
					self:collectItemToMyBag(itemData.entityId, itemData.interactId, safeIndex)
				else
					self:takeItemFromBox(itemData.slotIndex, ItemConst.INV_TYPE_EQUIP_SLOTS, safeIndex)
				end

				LuaUIUtils.popupPropTip()
			end)
		end
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.USE] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.USE, pg.getGameString("GRAB_EGG_USE"), function(itemInfo)
			local carryNum = itemInfo[itemData.itemId] or 1

			LuaMsgUtils.useItem(itemData.itemId, itemData.invId, itemData.genID, 1, {})
			LuaUIUtils.popupPropTip()
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.DISCARD, pg.getGameString("GRAB_EGG_DISCARD"), function(itemInfo)
			if not self:isInGrabEggSpace() then
				return
			end

			local carryNum = itemInfo[itemData.itemId] or 1

			if itemData.isMyBag then
				pg.me:releaseCarryIfGenID(itemData.genID)
				pg.me:serverMsg("RPC_CS_ThrowItemFromRobBag", itemData.invId, itemData.genID, carryNum)
			else
				self:takeItemFromBox(itemData.slotIndex, ItemConst.INV_TYPE_INVAILD, 0)
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	if typeSet[UIConst.GRAB_EGG_ITEM_USE_TYPE.SPLIT] then
		addBtn(UIConst.GRAB_EGG_ITEM_USE_TYPE.SPLIT, pg.getGameString("GRAB_EGG_SPLIT"), function(itemInfo)
			local carryNum = itemInfo[itemData.itemId] or 1

			if itemData.isMyBag then
				local bagCapacity = self:getMyBagCapacity()
				local count = self:getMyBagNormalItemCount()

				if bagCapacity < count + 1 then
					local bagData = self:getBagData()
					local bagName = pg.getLocalizationText(bagData.name)

					pg.global.showBubbleMessageRaw(string.format(pg.getGameString("GRAB_EGG_SPLIT_FULL"), bagName))

					return
				end

				pg.me:serverMsg("RPC_CS_SplitRobBagItem", itemData.genID, carryNum)
			else
				local bagCapacity = self.resourceData and #self.resourceData or 0
				local count = self:getResourceBoxItemCount()

				if bagCapacity < count + 1 then
					pg.global.showBubbleMessageRaw(string.format(pg.getGameString("GRAB_EGG_SPLIT_FULL"), self.resourceBoxName))

					return
				end

				pg.me:serverMsg("RPC_CS_SplitResourceBoxItem", self:getBoxEntityId(), itemData.slotIndex, carryNum)
			end

			LuaUIUtils.popupPropTip()
		end)
	end

	return btnDataList
end

function GrabEggBagModel:getDataWeight(data)
	if not data or not data.itemId then
		return 0
	end

	local weight = ItemUtils.getRobEggItemWeight(data.itemId)

	if weight == 0 then
		return 0
	end

	local count = data.packSlot and data.packSlot.count or data.count or 1

	return weight * count
end

function GrabEggBagModel:getDataUnitWeight(data)
	if not data or not data.itemId then
		return 0
	end

	return ItemUtils.getRobEggItemWeight(data.itemId)
end

function GrabEggBagModel:checkSafeBoxOverweight(dragData, targetData)
	local limit = self:getSafeBoxLoadLimit()

	if limit <= 0 then
		return true
	end

	if dragData and dragData.isMyBag and self:isSafeBoxSlot(dragData.slotIndex) then
		return true
	end

	local replaced = targetData and targetData.itemId and self:getDataWeight(targetData) or 0
	local incoming = self:getDataUnitWeight(dragData)

	return limit >= self:getSafeBoxCurLoad() - replaced + incoming
end

function GrabEggBagModel:checkDragRule(dragData, targetData, index, showTips)
	if not index then
		return
	end

	if dragData == targetData then
		return
	end

	if showTips == nil then
		showTips = true
	end

	if targetData and targetData.unlock == false then
		if showTips then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))
		end

		return false
	end

	if not self:checkTypeCanPutInSlot(dragData.type, dragData.itemId, index) then
		if showTips then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))
		end

		return false
	end

	if self:isSafeBoxSlot(index) and not self:checkSafeBoxOverweight(dragData, targetData) then
		if showTips then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_SAFE_BOX_OVERWEIGHT"))
		end

		return false
	end

	return true
end

function GrabEggBagModel:isShowWeight()
	return self.showWeight == true
end

function GrabEggBagModel:setShowWeight(show)
	self.showWeight = show
end

function GrabEggBagModel:getItemCountText(data, showDurability, showWeight)
	if showWeight then
		if not data or not data.itemId then
			return ""
		end

		return ClientTextUtils.concatByLanguage(self:getDataWeight(data), "kg")
	end

	if data and showDurability then
		if data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR then
			local cur, max

			if data.packSlot then
				cur, max = data.packSlot:getDurability()
			elseif data.props and data.props.equipData then
				cur, max = data.props.equipData.durability, data.props.equipData.maxDurability
			end

			if max and max > 0 then
				cur = math.ceil(cur or 0)

				if cur == 0 then
					cur = string.format(" <color=#ff5959>%s</color>", cur)
				end

				return string.format("%s/%s", cur, max)
			end
		elseif data.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
			local cur, max

			if data.packSlot then
				cur, max = data.packSlot:getRepairValue()
			elseif data.props and data.props.chipRepairKit then
				cur, max = data.props.chipRepairKit.repairValue, data.props.chipRepairKit.maxRepairValue
			end

			if max and max > 0 then
				cur = math.ceil(cur or 0)

				if cur == 0 then
					cur = string.format(" <color=#ff5959>%s</color>", cur)
				end

				return string.format("%s/%s", cur, max)
			end
		end
	end

	local count = data and data.packSlot and data.packSlot.count or data and data.count or 0

	if count <= 1 and data and data.itemId then
		local inId = RobEggItemOut[data.itemId] and RobEggItemOut[data.itemId].inid or data.itemId
		local stackMax = ItemUtils.getItemStackCount(inId)

		if stackMax and stackMax <= 1 then
			return ""
		end
	end

	return tostring(count)
end

function GrabEggBagModel:discardHoverItem()
	if not self:isInGrabEggSpace() then
		return
	end

	if not self.hoverData then
		return
	end

	local itemData = self.hoverData

	if itemData.isMyBag then
		pg.me:releaseCarryIfGenID(itemData.genID)
		pg.me:serverMsg("RPC_CS_ThrowItemFromRobBag", itemData.invId, itemData.genID, itemData.packSlot.count)
	else
		self:takeItemFromBox(itemData.slotIndex, ItemConst.INV_TYPE_INVAILD, 0)
	end
end

function GrabEggBagModel:getWeaponData()
	return self:getBagItemDataBySlot(ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

function GrabEggBagModel:getArmorData()
	return self:getBagItemDataBySlot(ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR, ItemConst.INV_TYPE_EQUIP_SLOTS)
end

function GrabEggBagModel:getSafeBoxSlotCount()
	return SysConfigData.GrabEggSafeBoxSlotNum or 0
end

function GrabEggBagModel:getSafeBoxLoadLimit()
	return pg.me.safeBoxWeightLimit or 0
end

function GrabEggBagModel:getSafeBoxCurLoad()
	local total = 0

	for i = ItemConst.ROB_EGG_SAFE_SLOT.MIN, ItemConst.ROB_EGG_SAFE_SLOT.MAX do
		local packSlot = pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_EQUIP_SLOTS)

		if packSlot and packSlot.id then
			total = total + self:getDataWeight({
				itemId = packSlot.id,
				packSlot = packSlot
			})
		end
	end

	return total
end

function GrabEggBagModel:isSafeBoxSlot(slot)
	return slot and slot >= ItemConst.ROB_EGG_SAFE_SLOT.MIN and slot <= ItemConst.ROB_EGG_SAFE_SLOT.MAX
end

function GrabEggBagModel:getSafeBoxData()
	local showCount = self:getSafeBoxSlotCount()
	local list = {}

	for i = ItemConst.ROB_EGG_SAFE_SLOT.MIN, ItemConst.ROB_EGG_SAFE_SLOT.MIN + showCount - 1 do
		list[#list + 1] = self:getSafeBoxItem(i)
	end

	return list
end

function GrabEggBagModel:getNextSafeBoxLinkTalentId()
	local linkMap = SysConfigData.GRABEGG_SAFEBOX_LINK_TAL

	if not linkMap then
		return nil
	end

	local unlockCount = pg.me and pg.me.safeBoxNum or 0

	return linkMap[unlockCount + 1]
end

function GrabEggBagModel:getNextSafeBoxLinkTalentName()
	local talentId = self:getNextSafeBoxLinkTalentId()
	local cfg = talentId and RobEggTalentData[talentId]

	if not cfg then
		return nil
	end

	return pg.getLocalizationText(cfg.talentName)
end

function GrabEggBagModel:getSafeBoxItem(slot)
	local unlockCount = pg.me.safeBoxNum or 0
	local data = self:getBagItemDataBySlot(slot, ItemConst.INV_TYPE_EQUIP_SLOTS)

	data.unlock = slot < ItemConst.ROB_EGG_SAFE_SLOT.MIN + unlockCount
	data.tIndex = 0

	return data
end

function GrabEggBagModel:getChipSlotData(equipData, slotIdx)
	if not equipData or not equipData.packSlot then
		return {
			isMyBag = true,
			empty = true,
			chipSlotIdx = slotIdx
		}
	end

	local packSlot = equipData.packSlot

	if not packSlot:checkChipSlotValid(slotIdx) then
		return {
			isMyBag = true,
			empty = true,
			chipSlotIdx = slotIdx
		}
	end

	local chipSlotType = packSlot:getChipType(slotIdx)
	local chipId, ownerUid = packSlot:getChipId(slotIdx)
	local hasChip = chipId and chipId > 0
	local item

	if hasChip then
		item = LuaUIUtils.getItemClientInfoById(chipId)
	else
		item = {
			empty = true
		}
	end

	item.chipSlotIdx = slotIdx
	item.chipSlotType = chipSlotType
	item.equipGenID = equipData.genID
	item.equipSlotIndex = equipData.slotIndex
	item.invId = ItemConst.INV_TYPE_EQUIP_SLOTS
	item.isMyBag = true
	item.ownerUid = ownerUid or ""
	item.tIndex = hasChip and 0 or 1

	return item
end

function GrabEggBagModel:getEquipChipSlotList(equipData)
	local ret = {}

	if not equipData or not equipData.packSlot then
		return ret
	end

	local chipSlotNum = equipData.packSlot:getChipSlotNum() or 0

	for i = 1, chipSlotNum do
		ret[#ret + 1] = self:getChipSlotData(equipData, i)
	end

	return ret
end

function GrabEggBagModel:getEquipChipCount(packSlot)
	if not packSlot then
		return 0
	end

	local count = 0

	packSlot:forEachChipSlot(function(slotIdx, chipType, chipId)
		if chipId and chipId > 0 then
			count = count + 1
		end
	end)

	return count
end

function GrabEggBagModel:getChipType(chipItemId)
	local chipData = RobEggChipData[chipItemId]

	if not chipData then
		local outData = RobEggItemOut[chipItemId]
		local inId = outData and outData.inid

		chipData = inId and RobEggChipData[inId]
	end

	return chipData and chipData.type
end

function GrabEggBagModel:canInsertChip(chipItemId, equipPackSlot, slotIdx)
	if not equipPackSlot or not chipItemId then
		return false
	end

	if not equipPackSlot:checkChipSlotValid(slotIdx) then
		return false
	end

	local chipType = self:getChipType(chipItemId)

	if not chipType then
		return false
	end

	local slotType = equipPackSlot:getChipType(slotIdx)

	return chipType == slotType
end

function GrabEggBagModel:getMyBagEmptyCount()
	local emptyCount = 0
	local myBagCapacity = self:getMyBagCapacity()
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN

	for i = beginPos, beginPos + myBagCapacity - 1 do
		if not pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_ROB_EGG) then
			emptyCount = emptyCount + 1
		end
	end

	return emptyCount
end

function GrabEggBagModel:checkUnloadEquipSpace(packSlot)
	local needSlots = 1 + self:getEquipChipCount(packSlot)

	return needSlots <= self:getMyBagEmptyCount()
end

function GrabEggBagModel:getEquipMoveNeedSlots(equipData)
	local packSlot = equipData and equipData.packSlot

	return 1 + self:getEquipChipCount(packSlot)
end

function GrabEggBagModel:getSafeBoxEmptyCount()
	local showCount = self:getSafeBoxSlotCount()
	local unlockCount = pg.me.safeBoxNum or 0
	local count = math.min(showCount, unlockCount)
	local emptyCount = 0

	for i = ItemConst.ROB_EGG_SAFE_SLOT.MIN, ItemConst.ROB_EGG_SAFE_SLOT.MIN + count - 1 do
		if not pg.me:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_EQUIP_SLOTS) then
			emptyCount = emptyCount + 1
		end
	end

	return emptyCount
end

function GrabEggBagModel:getResourceBoxEmptyCount()
	local slots
	local isBag = false

	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		slots = self.resourceData
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG then
		slots = self:getOtherBagSlots()
		isBag = true
	end

	if not slots then
		return 0
	end

	local emptyCount = 0

	if isBag then
		for i = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN, ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_END do
			local data = slots[i]

			if data and (not data.itemid or data.itemid == 0) then
				emptyCount = emptyCount + 1
			end
		end
	else
		for i = 1, #slots do
			local itemid = slots[i].itemid

			if not itemid or itemid == 0 then
				emptyCount = emptyCount + 1
			end
		end
	end

	return emptyCount
end

GrabEggBagModel.EQUIP_PLACE_FAIL_SLOT = 1
GrabEggBagModel.EQUIP_PLACE_FAIL_OVERWEIGHT = 2
GrabEggBagModel.EQUIP_PLACE_FAIL_CANT_SWAP = 3

function GrabEggBagModel:checkEquipSwapPlaceEnough(equipData, targetData)
	local needSlots = self:getEquipMoveNeedSlots(equipData)
	local targetHaveItem = targetData and targetData.itemId ~= nil

	if targetHaveItem then
		local equipSlotIndex = equipData and equipData.slotIndex
		local isWornEquipSlot = equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR

		if isWornEquipSlot and not self:checkTypeCanPutInSlot(targetData.type, targetData.itemId, equipSlotIndex) then
			return false, GrabEggBagModel.EQUIP_PLACE_FAIL_CANT_SWAP
		end
	end

	local swapBonus = targetHaveItem and 1 or 0

	if targetData and targetData.isMyBag and self:isSafeBoxSlot(targetData.slotIndex) then
		if needSlots > self:getSafeBoxEmptyCount() + swapBonus then
			return false, GrabEggBagModel.EQUIP_PLACE_FAIL_SLOT
		end

		if not self:checkSafeBoxOverweight(equipData, targetData) then
			return false, GrabEggBagModel.EQUIP_PLACE_FAIL_OVERWEIGHT
		end

		return true
	elseif targetData and targetData.isMyBag then
		if needSlots > self:getMyBagEmptyCount() + swapBonus then
			return false, GrabEggBagModel.EQUIP_PLACE_FAIL_SLOT
		end

		return true
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		return true
	else
		if needSlots > self:getResourceBoxEmptyCount() + swapBonus then
			return false, GrabEggBagModel.EQUIP_PLACE_FAIL_SLOT
		end

		return true
	end
end

function GrabEggBagModel:findChipSlotForItem(chipItemId)
	local chipType = self:getChipType(chipItemId)

	if not chipType then
		return nil, nil
	end

	local equipList = {
		self:getWeaponData(),
		self:getArmorData()
	}

	for _, equipData in ipairs(equipList) do
		if equipData and equipData.packSlot then
			local packSlot = equipData.packSlot
			local chipSlotNum = packSlot:getChipSlotNum() or 0

			for i = 1, chipSlotNum do
				if packSlot:checkChipSlotValid(i) then
					local slotChipType = packSlot:getChipType(i)

					if slotChipType == chipType then
						local chipId = packSlot:getChipId(i)

						if not chipId or chipId == 0 then
							return equipData, i
						end
					end
				end
			end
		end
	end

	return nil, nil
end

function GrabEggBagModel:findBestChipSlotForItem(chipItemId)
	local chipType = self:getChipType(chipItemId)

	if not chipType then
		return nil, nil
	end

	local fallbackEquip, fallbackIdx
	local equipList = {
		self:getWeaponData(),
		self:getArmorData()
	}

	for _, equipData in ipairs(equipList) do
		if equipData and equipData.packSlot then
			local packSlot = equipData.packSlot
			local chipSlotNum = packSlot:getChipSlotNum() or 0

			for i = 1, chipSlotNum do
				if packSlot:checkChipSlotValid(i) and packSlot:getChipType(i) == chipType then
					local chipId = packSlot:getChipId(i)

					if not chipId or chipId == 0 then
						return equipData, i
					elseif not fallbackEquip then
						fallbackEquip, fallbackIdx = equipData, i
					end
				end
			end
		end
	end

	return fallbackEquip, fallbackIdx
end

function GrabEggBagModel:tryRepairEquipWithKit(repairData, equipData)
	if not self:isInGrabEggSpace() then
		return false
	end

	if not pg.me:checkStatus(ConflictTypes.CT_REPAIR_GEAR) then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_EQUIP_CANNOT_REPAIR"))

		return true
	end

	if not repairData or not repairData.isMyBag then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_KIT_ONLY_IN_BAG"))

		return true
	end

	if self:isRepairingKit() then
		self:cancelRepairTimer()
	end

	local kitCfg = RobEggRepairKitData[repairData.itemId]
	local kitType = kitCfg and kitCfg.type
	local equipSlot, checkRet

	if equipData then
		if not self:isRepairKitTypeMatch(kitType, equipData.itemId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_KIT_TYPE_MISMATCH"))

			return true
		end

		equipSlot = equipData
		checkRet = equipData.packSlot and ItemUtils.checkRepairRobEquip(equipData.packSlot, repairData.packSlot) or Const.CheckFixEquipRet.InValid
	else
		equipSlot, checkRet = self:pickRepairableEquip(kitType, repairData)
	end

	if checkRet ~= Const.CheckFixEquipRet.OK then
		self:showRepairCheckFailTip(checkRet)

		return true
	end

	local durationSec = kitCfg and kitCfg.useTime or 0

	if not durationSec or durationSec <= 0 then
		self:repairEquip(ItemConst.INV_TYPE_EQUIP_SLOTS, equipSlot.genID, repairData.invId, repairData.genID)

		return true
	end

	self:startRepairTimer(repairData, equipSlot, durationSec)

	return true
end

function GrabEggBagModel:isRepairKitTypeMatch(kitType, equipItemId)
	if not kitType or not equipItemId then
		return false
	end

	local equipCfg = RobEggEquipData[equipItemId]

	return equipCfg ~= nil and equipCfg.repairType == kitType
end

function GrabEggBagModel:getRepairLoss(equipData, repairData)
	if not equipData or not equipData.itemId or not equipData.packSlot then
		return 0
	end

	local equipItemCfg = ItemData[equipData.itemId]
	local equipCfg = RobEggEquipData[equipData.itemId]

	if not equipItemCfg or not equipCfg then
		return 0
	end

	local cur, max = equipData.packSlot:getDurability()

	if not cur or not max or max <= 0 then
		return 0
	end

	local baseLoss = equipCfg.baseLoss or 0
	local loss = math.ceil(baseLoss * (max - cur) / max)

	if repairData and repairData.itemId then
		local repairItemCfg = ItemData[repairData.itemId]

		if repairItemCfg and repairItemCfg.quality < equipItemCfg.quality then
			local diff = equipItemCfg.quality - repairItemCfg.quality

			loss = loss + ((equipCfg.levelPenalty or EMPTY_TABLE)[diff] or 0)
		end
	end

	return loss
end

function GrabEggBagModel:getRepairMaxDurabilityAfter(equipData, repairData)
	if not equipData or not equipData.packSlot then
		return 0
	end

	local _, max = equipData.packSlot:getDurability()

	return (max or 0) - self:getRepairLoss(equipData, repairData)
end

function GrabEggBagModel:getRepairMoneyCost(equipData)
	if not equipData or not equipData.packSlot or not equipData.itemId then
		return 0
	end

	local equipCfg = RobEggEquipData[equipData.itemId]
	local baseCost = equipCfg and equipCfg.baseCost or 0

	if baseCost <= 0 then
		return 0
	end

	local cur, max = equipData.packSlot:getDurability()

	if not max or max <= 0 then
		return 0
	end

	local cost = baseCost * (max - cur) / max

	if self:isInGrabEggSpace() then
		cost = cost * GrabEggBagModel.MONEY_REPAIR_COST_RATE_IN_SPACE
	end

	return math.ceil(cost)
end

function GrabEggBagModel:tryRepairEquipByMoney(equipData)
	if not equipData or not equipData.packSlot then
		return
	end

	local ret = ItemUtils.checkRepairRobEquip(equipData.packSlot)

	if ret ~= Const.CheckFixEquipRet.OK then
		self:showRepairCheckFailTip(ret)

		return
	end

	local maxAfter = self:getRepairMaxDurabilityAfter(equipData)
	local moneyCost = self:getRepairMoneyCost(equipData)
	local isInGrabEggSpace = self:isInGrabEggSpace()
	local desc = string.format(isInGrabEggSpace and pg.getGameString("GRAB_EGG_REPAIR_CONFIRM_DESC_2") or pg.getGameString("GRAB_EGG_REPAIR_CONFIRM_DESC"), string.format("<color=#da8000>%s</color>", maxAfter))

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, {
		title = isInGrabEggSpace and pg.getGameString("GRAB_EGG_REPAIR_CONFIRM_TITLE_2") or pg.getGameString("GRAB_EGG_REPAIR_CONFIRM_TITLE"),
		tipTop = desc,
		data = {
			{
				ItemConst.ITEM_SPECIAL_MONEY_ROBEGG,
				moneyCost,
				showLack = true,
				hideOwnNum = true
			}
		},
		confirmCb = function()
			local curRet = ItemUtils.checkRepairRobEquip(equipData.packSlot)

			if curRet ~= Const.CheckFixEquipRet.OK then
				self:showRepairCheckFailTip(curRet)

				return
			end

			local curCost = self:getRepairMoneyCost(equipData)
			local ownMoney = pg.me:getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG) or 0

			if ownMoney < curCost then
				pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_COST_NOT_ENOUGH"))

				return
			end

			if isInGrabEggSpace then
				if not pg.me:checkStatus(ConflictTypes.CT_REPAIR_GEAR) then
					pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_EQUIP_CANNOT_REPAIR"))

					return
				end

				if self:isRepairingKit() then
					self:cancelRepairTimer()
				end

				local durationSec = SysConfigData.GRABEGG_egg_repair_time or 0

				self:startRepairTimer(nil, equipData, durationSec, true)

				if self.repairState then
					self.repairState.moneyCost = curCost
				end
			else
				self:repairEquipByMoney(equipData.invId, equipData.genID)
			end
		end
	})
end

function GrabEggBagModel:canRepairEquipWithKit(repairData, equipData)
	if not self:isInGrabEggSpace() then
		return false
	end

	if not repairData or not equipData or not equipData.itemId or not equipData.packSlot then
		return false
	end

	local kitCfg = RobEggRepairKitData[repairData.itemId]
	local kitType = kitCfg and kitCfg.type

	if not self:isRepairKitTypeMatch(kitType, equipData.itemId) then
		return false
	end

	return ItemUtils.checkRepairRobEquip(equipData.packSlot, repairData.packSlot) == Const.CheckFixEquipRet.OK
end

function GrabEggBagModel:pickRepairableEquip(kitType, repairData)
	local candidates = {
		self:getWeaponData(),
		self:getArmorData()
	}
	local firstRet

	for _, target in ipairs(candidates) do
		if target and target.itemId and target.packSlot and self:isRepairKitTypeMatch(kitType, target.itemId) then
			local ret = ItemUtils.checkRepairRobEquip(target.packSlot, repairData.packSlot)

			if ret == Const.CheckFixEquipRet.OK then
				return target, ret
			end

			firstRet = firstRet or ret
		end
	end

	return nil, firstRet or Const.CheckFixEquipRet.InValid
end

function GrabEggBagModel:showRepairCheckFailTip(checkRet)
	if checkRet == Const.CheckFixEquipRet.NoNeed or checkRet == Const.CheckFixEquipRet.TooLow then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_DURABILITY_HIGH"))
	elseif checkRet == Const.CheckFixEquipRet.TooHigh then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_DURABILITY_LOW"))
	end
end

function GrabEggBagModel:startRepairTimer(repairData, equipData, durationSec, isMoneyRepair)
	self:cancelRepairTimer()

	local state

	if isMoneyRepair then
		state = {
			isMoneyRepair = true,
			repairInvId = ItemConst.INV_TYPE_EQUIP_SLOTS,
			repairGenID = equipData.genID,
			repairItemId = equipData.itemId,
			repairSlotIndex = equipData.slotIndex,
			equipInv = ItemConst.INV_TYPE_EQUIP_SLOTS,
			equipGenID = equipData.genID,
			equipSlotIndex = equipData.slotIndex,
			durationSec = durationSec,
			startSec = Time and Time.realSecondCache or 0
		}
	else
		state = {
			repairInvId = repairData.invId,
			repairGenID = repairData.genID,
			repairItemId = repairData.itemId,
			repairSlotIndex = repairData.slotIndex,
			equipInv = ItemConst.INV_TYPE_EQUIP_SLOTS,
			equipGenID = equipData.genID,
			equipSlotIndex = equipData.slotIndex,
			durationSec = durationSec,
			startSec = Time and Time.realSecondCache or 0
		}
	end

	state.timerId = TimerManager.addTimer(durationSec, function()
		self:completeRepairTimer()
	end)
	self.repairState = state

	facade:SendMessageCommand(MessageName.GRAB_EGG_REPAIR_KIT_START, state)

	local tipKey = equipData.type == ItemConst.ITEM_TYPE.ARMOR and "GRAB_EGG_REPAIRING_ARMOR" or "GRAB_EGG_REPAIRING_WEAPON"

	pg.global.ui.tips:showControlPanel(state.startSec + state.durationSec, pg.getGameString(tipKey), 1, state.startSec)
end

function GrabEggBagModel:cancelRepairTimer()
	if not self.repairState then
		return
	end

	if self.repairState.timerId then
		TimerManager.removeTimer(self.repairState.timerId)
	end

	self.repairState = nil

	facade:SendMessageCommand(MessageName.GRAB_EGG_REPAIR_KIT_END)
	pg.global.ui.tips:hideControlPanel()
end

function GrabEggBagModel:completeRepairTimer()
	local s = self.repairState

	if not s then
		return
	end

	self.repairState = nil

	if s.isMoneyRepair then
		local equipData = self:getBagItemDataBySlot(s.equipSlotIndex, s.equipInv)
		local moneyCost = equipData and equipData.genID == s.equipGenID and self:getRepairMoneyCost(equipData) or s.moneyCost or 0
		local ownMoney = pg.me:getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG) or 0

		if moneyCost > 0 and ownMoney < moneyCost then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_REPAIR_COST_NOT_ENOUGH"))
		else
			self:repairEquipByMoney(s.equipInv, s.equipGenID)
		end
	else
		self:repairEquip(s.equipInv, s.equipGenID, s.repairInvId, s.repairGenID)
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_REPAIR_KIT_END)
end

function GrabEggBagModel:isRepairingKit()
	return self.repairState ~= nil
end

function GrabEggBagModel:onBagSlotChangedDuringRepair(invId, slotIndex)
	local s = self.repairState

	if not s then
		return
	end

	local expectedGenID

	if invId == s.repairInvId and slotIndex == s.repairSlotIndex then
		expectedGenID = s.repairGenID
	elseif invId == s.equipInv and slotIndex == s.equipSlotIndex then
		expectedGenID = s.equipGenID
	else
		return
	end

	local packSlot = pg.me:getItemFromBagSlotIndex(slotIndex, invId)

	if not packSlot or packSlot.genID ~= expectedGenID then
		self:cancelRepairTimer()
	end
end

function GrabEggBagModel:isRepairingItem(invId, genID)
	local s = self.repairState

	return s ~= nil and s.repairInvId == invId and s.repairGenID == genID
end

function GrabEggBagModel:getRepairProgress()
	local s = self.repairState

	if not s or not s.durationSec or s.durationSec <= 0 then
		return 0
	end

	local now = Time and Time.realSecondCache or 0
	local elapsed = now - s.startSec

	if elapsed <= 0 then
		return 0
	end

	if elapsed >= s.durationSec then
		return 1
	end

	return elapsed / s.durationSec
end

function GrabEggBagModel:getRepairDurationSec()
	return self.repairState and self.repairState.durationSec or 0
end

function GrabEggBagModel:getRepairElapsedSec()
	local s = self.repairState

	if not s then
		return 0
	end

	local now = Time and Time.realSecondCache or 0

	return math.max(0, now - s.startSec)
end

function GrabEggBagModel:getRepairRemainingSec()
	local s = self.repairState

	if not s or not s.durationSec then
		return 0
	end

	local now = Time and Time.realSecondCache or 0

	return math.max(0, s.startSec + s.durationSec - now)
end

function GrabEggBagModel:dragChipToEquipSlot(data, targetData, fromBox, fromNearby)
	if not targetData or not targetData.chipSlotIdx or not targetData.equipGenID then
		return false
	end

	local equipData

	if targetData.equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON then
		equipData = self:getWeaponData()
	elseif targetData.equipSlotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR then
		equipData = self:getArmorData()
	end

	if not equipData or not equipData.packSlot or not self:canInsertChip(data.itemId, equipData.packSlot, targetData.chipSlotIdx) then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))

		return true
	end

	if fromNearby then
		self:directInstallChip(data.entityId, targetData.invId, targetData.equipSlotIndex, targetData.chipSlotIdx)
	elseif fromBox then
		self:moveChipFromLootBox(self:getBoxEntityId(), data.slotIndex, targetData.chipSlotIdx, targetData.invId, targetData.equipGenID)
	else
		self:insertChipToEquip(data.invId, data.genID, targetData.invId, targetData.equipGenID, targetData.chipSlotIdx)
	end

	return true
end

function GrabEggBagModel:getChipSourceFlags(data)
	local bagType = self.bagType

	if data.isMyBag or bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		return false, false
	end

	if bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		return false, true
	end

	return true, false
end

function GrabEggBagModel:equipChipFromButton(data)
	local equipData, chipSlotIdx = self:findBestChipSlotForItem(data.itemId)

	if not equipData then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))

		return
	end

	local targetData = {
		invId = equipData.invId,
		equipGenID = equipData.genID,
		equipSlotIndex = equipData.slotIndex,
		chipSlotIdx = chipSlotIdx
	}
	local fromBox, fromNearby = self:getChipSourceFlags(data)

	self:dragChipToEquipSlot(data, targetData, fromBox, fromNearby)
end

function GrabEggBagModel:doubleClickChipToEquipSlot(data, fromBox, fromNearby)
	local equipData, chipSlotIdx = self:findChipSlotForItem(data.itemId)

	if not equipData then
		return false
	end

	if fromNearby then
		self:directInstallChip(data.entityId, equipData.invId, equipData.slotIndex, chipSlotIdx)
	elseif fromBox then
		self:moveChipFromLootBox(self:getBoxEntityId(), data.slotIndex, chipSlotIdx, equipData.invId, equipData.genID)
	else
		self:insertChipToEquip(data.invId, data.genID, equipData.invId, equipData.genID, chipSlotIdx)
	end

	return true
end

function GrabEggBagModel:insertChipToEquip(srcInv, srcGenId, dstInv, dstGenId, slotIdx)
	pg.me:serverMsg("RPC_CS_InsertChip", srcInv, srcGenId, dstInv, dstGenId, slotIdx)
end

function GrabEggBagModel:swapEquipChip(pos, srcSlotIdx, dstSlotIdx)
	pg.me:serverMsg("RPC_CS_SwapRobEggEquipChip", pos, srcSlotIdx, dstSlotIdx)
end

function GrabEggBagModel:removeChipFromEquip(srcInv, srcGenId, slotIdx, dstInv, pos)
	pg.me:serverMsg("RPC_CS_RemoveChip", srcInv, srcGenId, slotIdx, dstInv, pos)
end

function GrabEggBagModel:moveChipFromLootBox(entityId, pos, slotIdx, dstInv, dstGenId)
	pg.me:serverMsg("RPC_CS_MoveChipFromLootBox", entityId, pos, slotIdx, dstInv, dstGenId)
end

function GrabEggBagModel:moveChipToLootBox(entityId, pos, slotIdx, dstInv, dstGenId)
	pg.me:serverMsg("RPC_CS_MoveChipToLootBox", entityId, pos, slotIdx, dstInv, dstGenId)
end

function GrabEggBagModel:directInstallChip(entityId, invId, pos, slotIdx)
	pg.me:serverMsg("RPC_CS_DirectInstallChip", entityId, invId, pos, slotIdx)
end

function GrabEggBagModel:repairEquip(equipInv, equipGenId, repairInv, repairGenId)
	pg.me:serverMsg("RPC_CS_RepairEquip", equipInv, equipGenId, repairInv, repairGenId)
end

function GrabEggBagModel:repairEquipByMoney(equipInv, equipGenId)
	pg.me:serverMsg("RPC_CS_RepairEquipByMoney", equipInv, equipGenId)
end

function GrabEggBagModel:setResourceData(data, force)
	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM and not force then
		self:refreshNearbyData(data)
	else
		self.resourceData = data or {}
	end
end

function GrabEggBagModel:getResourceData()
	return self.resourceData
end

function GrabEggBagModel:setBoxEntityId(id)
	self.boxEntityId = id
end

function GrabEggBagModel:getBoxEntityId()
	return self.boxEntityId
end

function GrabEggBagModel:setResourceBoxName(name)
	self.resourceBoxName = name
end

function GrabEggBagModel:getResourceBoxItemCount()
	local count = 0

	for i = 1, #self.resourceData do
		local resData = self.resourceData[i]

		if resData.itemid or resData.itemId then
			count = count + 1
		end
	end

	return count
end

function GrabEggBagModel:getItemDataByResource(resData, slotIndex, needDiscovery)
	resData = resData or {}

	local itemId = resData.itemid ~= 0 and resData.itemid or nil
	local item = itemId and LuaUIUtils.getItemClientInfoById(itemId) or {}
	local mUid = pg.me.uid

	item.count = resData.count
	item.slotIndex = slotIndex
	item.ownerUid = resData.tag and resData.tag.ownerUid
	item.props = resData.props

	if resData.discoverys then
		for uid, data in pairs(resData.discoverys) do
			if uid ~= mUid and pg.me:isUidTeamMember(uid) and ItemUtils.isSearching(uid, resData) then
				item.searchingUid = uid

				break
			end
		end
	end

	item.needDiscovery = false

	if needDiscovery and not item.searchingUid and itemId and resData.discoverys then
		item.needDiscovery = true

		for uid, data in pairs(resData.discoverys) do
			if (uid == mUid or pg.me:isUidTeamMember(uid)) and data == Const.ROB_LOOT_ITEM_FINISH_DISCOVERY then
				item.needDiscovery = false

				break
			end
		end
	end

	if resData.discoverys and ItemUtils.isSearching(mUid, resData) then
		item.endTime = resData.discoverys[mUid]
	end

	local myDiscover = resData.discoverys and resData.discoverys[mUid]

	if myDiscover and myDiscover ~= Const.ROB_LOOT_ITEM_FINISH_DISCOVERY then
		item.myDiscoverTime = myDiscover
	end

	if not item.itemId then
		item.tIndex = 1
	elseif item.needDiscovery or item.searchingUid then
		item.tIndex = 2
	else
		item.tIndex = 0
	end

	return item
end

function GrabEggBagModel:getCollectItemData(resData)
	local itemId = resData.itemId
	local item = itemId and LuaUIUtils.getItemClientInfoById(itemId) or {}

	item.count = resData.count
	item.slotIndex = resData.slotIndex
	item.entityId = resData.entityId
	item.interactId = resData.interactId
	item.ownerUid = resData.ownerUid
	item.props = resData.props
	item.tIndex = itemId and 0 or 1

	return item
end

function GrabEggBagModel:getOtherEquipData(pos)
	local equipSlots = self.resourceData.equipSlots
	local resData = equipSlots and equipSlots[pos] or {}

	return self:getItemDataByResource(resData, pos)
end

function GrabEggBagModel:getOtherBagSlots()
	return self.resourceData.bagSlots or {}
end

function GrabEggBagModel:getOtherBagNormalDataList()
	local ret = {}
	local bagSlots = self:getOtherBagSlots()

	for i = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN, ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_END do
		if not bagSlots[i] then
			break
		end

		ret[#ret + 1] = self:getItemDataByResource(bagSlots[i], i, true)
	end

	return ret
end

function GrabEggBagModel:getOtherBagData()
	return self:getOtherEquipData(ItemConst.ROB_EGG_EQUIP_SLOT.BAG)
end

function GrabEggBagModel:getOtherBagEffectData()
	local equipSlots = self.resourceData.equipSlots

	if not equipSlots then
		return
	end

	local data = equipSlots[ItemConst.ROB_EGG_EQUIP_SLOT.BAG]

	return ItemEffectData[data and data.itemid]
end

function GrabEggBagModel:getOtherBagCapacity()
	local effectData = self:getOtherBagEffectData()

	if not effectData then
		return 0
	end

	return effectData.volume or 0
end

function GrabEggBagModel:getOtherBagEggCapacity()
	local effectData = self:getOtherBagEffectData()

	if not effectData then
		return 0
	end

	return effectData.eggvolume or 0
end

function GrabEggBagModel:getOtherEggData()
	local bagSlots = self:getOtherBagSlots()

	return self:getItemDataByResource(bagSlots[ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN], ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN, true)
end

function GrabEggBagModel:getNormalResourceDataList()
	local ret = {}

	for i = 1, #self.resourceData do
		ret[#ret + 1] = self:getItemDataByResource(self.resourceData[i], i, true)
	end

	return ret
end

function GrabEggBagModel:getResourceDataBySlot(slot)
	if not self.resourceData then
		return nil
	end

	if self.resourceData.bagSlots then
		return self:getItemDataByResource(self.resourceData.bagSlots[slot], slot, true)
	end

	return self:getItemDataByResource(self.resourceData[slot], slot, true)
end

function GrabEggBagModel:getCollectItemList()
	local ret = {}
	local count = #self.resourceData
	local limitCount = SysConfigData.GRABEGG_COLLECTBAG

	for i = 1, limitCount do
		ret[i] = false
	end

	for i = 1, count do
		local data = self.resourceData[i]

		if self.nearbySlotMap[data.slotIndex] then
			ret[data.slotIndex] = self:getCollectItemData(data)
		end
	end

	for i = 1, limitCount do
		if ret[i] == false then
			ret[i] = self:getCollectItemData({
				slotIndex = i
			})
		end
	end

	return ret
end

function GrabEggBagModel:refreshNearbyData(resourceData)
	resourceData = resourceData or self.resourceData

	if not resourceData then
		return
	end

	local newIdMap = {}
	local oldIdMap = {}

	for i = 1, #resourceData do
		local data = resourceData[i]

		newIdMap[data.entityId] = data
	end

	for i = #self.resourceData, 1, -1 do
		local data = self.resourceData[i]

		data.slotIndex = nil

		if not newIdMap[data.entityId] then
			table.remove(self.resourceData, i)
		else
			oldIdMap[data.entityId] = data
		end
	end

	for entityId, data in pairs(newIdMap) do
		if not oldIdMap[entityId] then
			self.resourceData[#self.resourceData + 1] = data
			oldIdMap[entityId] = data
		end
	end

	local limitCount = SysConfigData.GRABEGG_COLLECTBAG

	for i = 1, limitCount do
		local entityId = self.nearbySlotMap[i]

		if oldIdMap[entityId] then
			oldIdMap[entityId].slotIndex = i
		end
	end

	for i = #self.resourceData, 1, -1 do
		local data = self.resourceData[i]

		if not data.slotIndex then
			data.slotIndex = self:findNextNearbyEmptySlot()
		end

		if data.slotIndex then
			self.nearbySlotMap[data.slotIndex] = data.entityId
		end
	end
end

function GrabEggBagModel:findNextNearbyEmptySlot()
	local limitCount = SysConfigData.GRABEGG_COLLECTBAG

	for i = 1, limitCount do
		if not self.nearbySlotMap[i] then
			return i
		end
	end
end

function GrabEggBagModel:setNearbySlot(slot, entityId)
	self.nearbySlotMap[slot] = entityId
end

function GrabEggBagModel:clearNearbySlotMap()
	table.clear(self.nearbySlotMap)
end

function GrabEggBagModel:getOtherBagNormalItemCount()
	local bagSlots = self:getOtherBagSlots()
	local count = 0

	for index, data in pairs(bagSlots) do
		if data.itemid then
			count = count + 1
		end
	end

	return count
end

function GrabEggBagModel:getResourceBoxEmptyIndex()
	local slots
	local isBag = false

	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		slots = self.resourceData
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG then
		slots = self:getOtherBagSlots()
		isBag = true
	end

	if not slots then
		return nil
	end

	if isBag then
		for i = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN, ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_END do
			if not slots[i] then
				break
			end

			local data = slots[i]

			if not data.itemid or data.itemid == 0 then
				return i
			end
		end
	else
		for i = 1, #slots do
			local data = slots[i]

			if not data.itemid or data.itemid == 0 then
				return i
			end
		end
	end

	return nil
end

function GrabEggBagModel:getEntityId()
	return self:getBoxEntityId()
end

function GrabEggBagModel:startDiscoverItem(slotIndex, callback)
	if callback then
		pg.me:serverMsg("RPC_CS_StartDiscoveryItem", self:getEntityId(), slotIndex, callback)
	else
		pg.me:serverMsg("RPC_CS_StartDiscoveryItem", self:getEntityId(), slotIndex)
	end
end

function GrabEggBagModel:endDiscoverItem(slotIndex, callback)
	if callback then
		pg.me:serverMsg("RPC_CS_EndDiscoveryItem", self:getEntityId(), slotIndex, callback)
	else
		pg.me:serverMsg("RPC_CS_EndDiscoveryItem", self:getEntityId(), slotIndex)
	end
end

function GrabEggBagModel:takeItemFromBox(pos, dstInv, dstPos)
	pg.me:serverMsg("RPC_CS_TakeItemFromResourceBox", self:getBoxEntityId(), pos, dstInv, dstPos)
end

function GrabEggBagModel:swapItemInResourceBox(srcPos, dstPos)
	pg.me:serverMsg("RPC_CS_SwapResourceBoxItem", self:getEntityId(), srcPos, dstPos)
end

function GrabEggBagModel:collectItemToMyBag(entityId, interactId, pos)
	pg.me:serverMsg("RPC_CS_DirectCollect", Const.IACT_IP_COLLECT_ITEM, entityId, interactId, {}, pos, function(result)
		if result then
			self:refreshNearbyData()
		end
	end)
end

return GrabEggBagModel
