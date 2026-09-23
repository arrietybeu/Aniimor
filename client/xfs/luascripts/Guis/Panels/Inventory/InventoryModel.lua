-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\InventoryModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemCompoundMaterial2Id = require("Data.item_compound_material2id")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local RedDotConst = require("Const.RedDotConst")
local logger = LoggerManager.getLogger("InventoryModel")
local Utils = require("Common.Utils.Utils")
local InventoryModel = Class.LightClass("InventoryModel", UIModel)
local ItemUseChecker = require("Guis.Panels.Inventory.Helper.ItemUseChecker")
local InventoryData = require("Data.inventory_data")
local ClientConst = require("Const.ClientConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local GameStringConfig = require("Data.gamestring_config_data")
local ItemThirdPageData = require("Data.item_third_page_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local tSort = table.sort

InventoryModel.EMPTY_ITEM_ID = 0
InventoryModel.SORT_IDX_DEFAULT = 0
InventoryModel.SORT_IDX_QUALITY = 1
InventoryModel.SORT_IDX_TYPE = 2
InventoryModel.PET_PAGE_DEFAULT = 0
InventoryModel.THIRD_PAGE_ALL = -1
InventoryModel.ITEM_STYPE_TO_PET_PAGE = {
	[ItemConst.USEITEM_TYPE_PET_EXP] = 1
}
InventoryModel.STATE_NORMAL = 0
InventoryModel.STATE_CATCHBALL = 1
InventoryModel.STATE_DECOMPOSE = 2

function InventoryModel:ctor()
	self.SORT_DESC = {
		[InventoryModel.SORT_IDX_DEFAULT] = "DEFAULT_SORT",
		[InventoryModel.SORT_IDX_QUALITY] = "QUALITY",
		[InventoryModel.SORT_IDX_TYPE] = "TYPE"
	}
	self.sortIsAscending = true
	self.curInvType = -1
	self.operationSate = InventoryModel.STATE_NORMAL
	self.selectPropData = nil
	self.invId2thirdTabList = {}
end

function InventoryModel:setOperationState(state)
	self.operationSate = state
end

function InventoryModel:isInOperationState(state)
	return self.operationSate == state
end

function InventoryModel:getPropsCount(invId)
	invId = invId or self.curInvType

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invId)

	return bag:getCount()
end

function InventoryModel:getCapacity(invId)
	invId = invId or self.curInvType

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invId)

	return bag:getCapacity()
end

function InventoryModel:getPropsByInv(paginationId)
	local ret

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) and self.curInvType == ItemConst.INV_TYPE_BALL then
		local ballList = pg.me.catchRogueInfo:getValidBallList(pg.me)

		ret = {}

		local oriRet = LuaUIUtils.getInventoryProps(self.curInvType, paginationId)

		for index, item in ipairs(oriRet) do
			local itemId = item.itemId

			if table.contains(ballList, itemId) then
				item.count = pg.me.catchRogueInfo:getValidBallCount(pg.me, itemId)
				item.isCaptureBind = false

				local isBind, bindSlot = LuaUIUtils.tableContains(ballList, itemId)

				if isBind then
					item.isCaptureBind = true
					item.bindCatchBallSlot = bindSlot
				end

				ret[#ret + 1] = item
			end
		end
	else
		ret = LuaUIUtils.getInventoryProps(self.curInvType, paginationId)
	end

	if self.sortIdxType == self.SORT_IDX_QUALITY then
		tSort(ret, function(c1, c2)
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
	elseif self.sortIdxType == self.SORT_IDX_TYPE then
		tSort(ret, function(c1, c2)
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

function InventoryModel:getPropsByDecomposeSelectedList(selectedList)
	local ret = {}
	local player = pg.me
	local tabList = self:getTabList()

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

function InventoryModel:getBallQuickSlot(slotType)
	if slotType == ItemConst.QUICK_SLOT_BALL then
		return pg.me.invQuickSlotBall
	elseif slotType == ItemConst.QUICK_SLOT_ELITE_BALL then
		return pg.me.invEliteSlotBall
	end
end

function InventoryModel:getQuickSlotItemInfos(quickType)
	local ret = {}
	local quickSlotInfo

	if quickType == ItemConst.QUICK_SLOT_BALL or quickType == ItemConst.QUICK_SLOT_ELITE_BALL then
		quickSlotInfo = self:getBallQuickSlot(quickType)
	elseif quickType == ItemConst.QUICK_SLOT_ITEM then
		quickSlotInfo = pg.me.invQuickSlotItem
	end

	if not quickSlotInfo then
		return ret
	end

	local maxSlot = ItemUtils.getQuickSlotMaxCount(quickType)

	for idx = 1, maxSlot do
		local itemId = quickSlotInfo[idx] or InventoryModel.EMPTY_ITEM_ID
		local item = {}

		if itemId ~= InventoryModel.EMPTY_ITEM_ID then
			item = LuaUIUtils.getItemClientInfoById(itemId)
			item.icon = LuaUIUtils.getIconByItemId(item.itemId)
		else
			item = {
				itemId = itemId
			}
		end

		item.tIndex = 0
		item.slotType = quickType
		item.slotIndex = idx
		ret[#ret + 1] = item
	end

	return ret
end

function InventoryModel:getSelectGroupId()
	if not self.selectGroupId then
		self.selectGroupId = pg.me.curPetFormationIndex
	end

	return self.selectGroupId
end

function InventoryModel:getItemCount(fromSlot, propData)
	if fromSlot then
		local me = pg.me

		return me and ItemUtils.getItemCountById(me, propData.itemId) or 0
	else
		return propData.packSlot.count
	end
end

function InventoryModel:checkSelectGroupIdIsFight()
	return self.selectGroupId == pg.me.curPetFormationIndex
end

function InventoryModel:setSelectGroupId(groupId)
	self.selectGroupId = groupId
end

function InventoryModel:getGroupNameInfo(idx)
	return pg.global.ui.petManagement.model:getGroupNameInfo(idx)
end

function InventoryModel:tryModifyGroup(startSlotIdx, pointerIdx, slotType)
	if slotType == ItemConst.QUICK_SLOT_ITEM then
		self:tryModifyQuickPlayerPropSlot(startSlotIdx, pointerIdx)
	elseif slotType == ItemConst.QUICK_SLOT_BALL or slotType == ItemConst.QUICK_SLOT_ELITE_BALL then
		self:tryModifyQuickBallPropSlot(startSlotIdx, pointerIdx, slotType)
	end
end

function InventoryModel:setSelectPropData(data)
	self.selectPropData = data
	self.selectGenId = self.selectPropData and self.selectPropData.index
end

function InventoryModel:getSelectPropData()
	return self.selectPropData
end

function InventoryModel:setCurInvType(invType)
	self.curInvType = invType
end

function InventoryModel:getInventoryInvId()
	return self.curInvType
end

function InventoryModel:setCurSelectPetInfo(petInfo)
	self.curPetInfo = petInfo
end

function InventoryModel:getCurSelectPetInfo()
	return self.curPetInfo
end

function InventoryModel:tryModifyQuickPlayerPropSlot(startSlotIdx, pointerIdx)
	local player = pg.me

	if pointerIdx and pointerIdx <= ItemUtils.getQuickSlotMaxCount(ItemConst.QUICK_SLOT_ITEM) then
		local quickSlotInfo = player.invQuickSlotItem
		local itemId = quickSlotInfo[pointerIdx]
		local selectItemId = quickSlotInfo[startSlotIdx]

		player:setQuickSlotItem(startSlotIdx, itemId)
		player:setQuickSlotItem(pointerIdx, selectItemId)
	else
		player:setQuickSlotItem(startSlotIdx, InventoryModel.EMPTY_ITEM_ID)
	end
end

function InventoryModel:tryModifyQuickBallPropSlot(startSlotIdx, pointerIdx, slotType)
	local player = pg.me

	if pointerIdx and pointerIdx <= ItemUtils.getQuickSlotMaxCount(slotType) then
		local quickSlotInfo = self:getBallQuickSlot(slotType)
		local selectItemId = quickSlotInfo[startSlotIdx]

		player:setQuickSlotBall(slotType, pointerIdx, selectItemId)
	else
		player:setQuickSlotBall(slotType, startSlotIdx, InventoryModel.EMPTY_ITEM_ID)
	end
end

function InventoryModel:trySetupPlayerProp(slotIndex, itemId)
	if slotIndex > ItemUtils.getQuickSlotMaxCount(ItemConst.QUICK_SLOT_ITEM) then
		return
	end

	pg.me:setQuickSlotItem(slotIndex, itemId)
end

function InventoryModel:trySetupBallToQuickSlot(slotType, slotIndex, itemId, mode)
	if slotIndex > ItemUtils.getQuickSlotMaxCount(slotType) then
		return
	end

	pg.me:setQuickSlotBall(slotType, slotIndex, itemId, mode)
end

function InventoryModel:getFirstEmptyBallSlot(slotType)
	local quickSlotInfo = self:getBallQuickSlot(slotType)

	if not quickSlotInfo then
		return nil
	end

	local maxSlot = ItemUtils.getQuickSlotMaxCount(slotType)

	for idx = 1, maxSlot do
		if (quickSlotInfo[idx] or InventoryModel.EMPTY_ITEM_ID) == InventoryModel.EMPTY_ITEM_ID then
			return idx
		end
	end

	return nil
end

function InventoryModel:getPlayerPropSelectIdx()
	return self.playerPropSelectIdx
end

function InventoryModel:setPlayerPropSelectIdx(idx)
	self.playerPropSelectIdx = idx
end

function InventoryModel:getPetPropSelectIdx()
	return self.petPropSelectIdx
end

function InventoryModel:setPetPropSelectIdx(idx)
	self.petPropSelectIdx = idx
end

function InventoryModel:getBallPropSelectIdx()
	return self.ballPropSelectIdx
end

function InventoryModel:setBallPropSelectId(idx)
	self.ballPropSelectIdx = idx
end

function InventoryModel:getSortOptions()
	local ret = {}

	for idx, sortDesc in pairs(self.SORT_DESC) do
		ret[idx + 1] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return ret
end

function InventoryModel:getGroupInfos()
	local groupInfos = {}

	for idx = 1, Const.MAX_FORMATION_COUNT do
		local nameInfo = self:getGroupNameInfo(idx)
		local groupName

		if nameInfo.customName and nameInfo.customName ~= "" then
			groupName = {
				label = nameInfo.customName
			}
		else
			groupName = {
				label = ClientTextUtils.concatByLanguage(pg.getGameString("DEFAULT_GROUP_NAME"), nameInfo.idx)
			}
		end

		groupInfos[idx] = groupName
	end

	return groupInfos
end

function InventoryModel:getSortIdxType()
	if not self.sortIdxType then
		self.sortIdxType = InventoryModel.SORT_IDX_DEFAULT
	end

	return self.sortIdxType
end

function InventoryModel:trySwitchSelectPropLock()
	if self.selectGenId then
		local player = pg.me
		local bag = ItemUtils.getTypedBag(player, self.curInvType) or {}
		local item = bag[self.selectGenId]

		if item then
			local lockStatus = item:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

			pg.me:serverMsg("RPC_CS_ModifyItemStatus", self.curInvType, {
				self.selectGenId
			}, ItemConst.ITEM_STATUS_LOCKED, not lockStatus)
		end
	end
end

function InventoryModel:getSelectPropLockStatus()
	if self.selectGenId then
		return self:getPropLockStatus(self.selectGenId)
	end
end

function InventoryModel:getPropLockStatus(genId, invType)
	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invType or self.curInvType) or {}
	local item = bag[genId]

	if item then
		local lockStatus = item:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

		return lockStatus
	end
end

function InventoryModel:tryGetCompoundList(itemId)
	return ItemCompoundMaterial2Id[itemId]
end

function InventoryModel:tryDropItem()
	if self.selectGenId then
		local player = pg.me
		local bag = ItemUtils.getTypedBag(player, self.curInvType) or {}
		local item = bag[self.selectGenId]

		if item then
			pg.me:serverMsg("RPC_CS_ThrowItem", item.id, 1)
		end
	end
end

function InventoryModel:tryCancelSelectPropNewStatus(genId)
	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, self.curInvType)

	if bag and bag[genId] then
		pg.me:serverMsg("RPC_CS_ModifyItemStatus", self.curInvType, {
			genId
		}, ItemConst.ITEM_STATUS_NEW, false)
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("tryCancelSelectPropNewStatus, error invId:%d or genId:%d", self.curInvType, self.selectGenId)
	end
end

function InventoryModel:setSortIdxType(idxType)
	self.sortIdxType = idxType
end

function InventoryModel:setSortAscendingOrder(isAscending)
	self.sortIsAscending = isAscending
end

function InventoryModel:tryRemoveInvNewLabel()
	local player = pg.me

	if not self.curInvType then
		return
	end

	local bag = ItemUtils.getTypedBag(player, self.curInvType) or {}
	local newItem = {}

	for genId, prop in bag:items() do
		if prop:hasStatus(ItemConst.ITEM_STATUS_NEW) then
			newItem[#newItem + 1] = genId
		end
	end

	if #newItem > 0 then
		pg.me:serverMsg("RPC_CS_ModifyItemStatus", self.curInvType, newItem, ItemConst.ITEM_STATUS_NEW, false)
	end
end

function InventoryModel:tryBindCaptureBall(isLogin)
	if not self.selectGenId then
		return
	end

	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, self.curInvType) or {}
	local item = bag[self.selectGenId]

	if not item then
		return
	end

	if not Utils.isQuickCaptureItemIdValid(self, item.id) then
		pg.global.showBubbleMessage(2135)

		return
	end

	pg.me:serverMsg("RPC_CS_SetQuickCaptureItemId", isLogin and item.id or 0)
end

function InventoryModel:bindQuickCaptureBallRes(res)
	if not res then
		-- block empty
	end
end

function InventoryModel:getCurrenciesData()
	local res = {}
	local currencies = {
		2
	}
	local me = pg.me

	for _, v in ipairs(currencies) do
		local cData = ItemData[v]

		if cData then
			local item = {
				id = v,
				name = cData.itemName,
				icon = LuaUIUtils.getIconByIconId("$ui_item_2_small.png"),
				num = pg.LocalizationNumber(ItemUtils.getItemCountById(me, v))
			}

			res[#res + 1] = item
		end
	end

	return res
end

function InventoryModel:checkItemUseAble(args)
	return ItemUseChecker.checkItemUse(args)
end

function InventoryModel:getDetailSourceInfo(sourceList)
	local dataList = {}

	if ToBool(sourceList) then
		for _, idx in pairs(sourceList) do
			local sourceEntry = ItemSourceData[idx]

			if sourceEntry then
				local conditionPass = LuaUIUtils.checkItemSourceCondition(sourceEntry)

				if conditionPass or sourceEntry.showForce == 1 then
					local data = {}

					table.merge(data, sourceEntry)

					data.conditionPass = conditionPass

					table.insert(dataList, data)
				end
			end
		end
	end

	return dataList
end

function InventoryModel:getTabList()
	local tabList = {}

	for invId, v in pairs(InventoryData) do
		if v.hideInBag ~= 1 and ItemUtils.isSupportedTypedInvId(invId) then
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

function InventoryModel:getThirdTabList(invId)
	invId = invId or self.curInvType

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
			table.insert(ret, 1, {
				paginationId = InventoryModel.THIRD_PAGE_ALL,
				nameHashId = GameStringConfig.ALL.desc
			})
		end
	end

	return self.invId2thirdTabList[invId]
end

function InventoryModel:checkPetSlotHasPet()
	local petInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())

	return #petInfos > 0
end

InventoryModel.PAGE_2_LIST_ITEM_PATH = {
	[0] = RedDotConst.RedDotPath.BAG_ITEM_TAB_BALL_ITEM,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_COMMON_ITEM,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_PET_ITEM,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_TASK_ITEM,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_PLAYER_ITEM
}
InventoryModel.PAGE_2_TAB_PATH = {
	[0] = RedDotConst.RedDotPath.BAG_ITEM_TAB_PLAYER,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_COMMON,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_PET,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_BALL,
	RedDotConst.RedDotPath.BAG_ITEM_TAB_TASK
}

function InventoryModel:redDot_GetItemState(sItemInfo)
	return false
end

function InventoryModel:redDot_GetCurTreePathWithTab()
	return self.PAGE_2_LIST_ITEM_PATH[self.oldPage or 0]
end

function InventoryModel:redDot_GetTreePathWithTab(page)
	return self.PAGE_2_TAB_PATH[page or 0]
end

function InventoryModel:redDot_GetInventoryTabState(invIdx)
	local player = pg.me
	local bag = ItemUtils.getTypedBag(player, invIdx) or {}
	local hasRedDot = false

	for _, sItemInfo in bag:items() do
		if self:redDot_GetItemState(sItemInfo) then
			hasRedDot = true

			break
		end
	end

	return false
end

function InventoryModel:redDot_GetInventoryTabItemNum(page)
	local player = pg.me
	local invIdx = page
	local bag = ItemUtils.getTypedBag(player, invIdx) or {}

	return 0
end

function InventoryModel:redDot_GetTabNumState(page)
	local dotNum = self:redDot_GetInventoryTabItemNum(page)
	local treePath = self:redDot_GetTreePathWithTab(page)
	local oldNum = pg.global.prefsCacheUtils:getInt(treePath, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	return false
end

function InventoryModel:redDot_SetTabNumState(page)
	self.redDotDirty = true

	local dotNum = self:redDot_GetInventoryTabItemNum(page)
	local treePath = self:redDot_GetTreePathWithTab(page)

	pg.global.prefsCacheUtils:setInt(treePath, dotNum, ClientConst.CACHE_TYPE_FLAG.USER)
end

function InventoryModel:redDot_GetFuncMenuInventoryState()
	local player = pg.me
	local hasRedDot = false

	ItemUtils.eachSupportedTypedBag(player, function(invIdx)
		if not hasRedDot and self:redDot_GetInventoryTabState(invIdx) then
			hasRedDot = true
		end
	end)

	return false
end

function InventoryModel:redDot_CheckSaveDirty()
	if self.redDotDirty then
		pg.global.prefsCacheUtils:save()
	end
end

return InventoryModel
