-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\ItemBatchComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ItemBatchComponent = Class.LightClass("ItemBatchComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local Bitset = require("Common.Bitset")
local lume = require("Core.Common.lume")
local QuestConst = require("Data.quest_const")
local ItemNotifyManager = require("Common.ItemNotifyManager")
local ItemBatchNotifySideData = require("Data.item_batch_notify_side_data")
local ItemBatchNotifyFullData = require("Data.item_batch_notify_full_data")
local ItemBatchNotifyLightData = require("Data.item_batch_notify_light_data")
local ItemBatchNotifySpecialData = require("Data.item_batch_notify_special_data")
local ItemBatchNotifyDontInterData = require("Data.item_batch_notify_dont_interrupt_data")
local ItemData = require("Data.item_data")
local DropData = require("Data.drop_data")
local logger = LoggerManager.getLogger("ClientInventoryComponent")
local TimerManager = require("Core.Timer.TimerManager")
local PetData = require("Data.pet_data")
local SourceData = require("Data.log_source_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ResLoader = require("GameApp.ResLoad.ResLoader")
local Time = require("Core.Common.Time")
local AddressDataConst = require("Const.AddressDataConst")
local ChestData = require("Data.chest_data")
local EnvObjectData = require("Data.envobj_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientChestRewardAttractCtrl = require("GameApp.Sandbox.ClientChestRewardAttractCtrl")
local QuickUseUtils = require("Utils.QuickUseUtils")
local ITEM_NOTIFY_SHIELD = -1
local ITEM_NOTIFY_NORMAL = 0
local ITEM_NOTIFY_MERGE_SOURCE = 1
local ITEM_NOTIFY_MERGE_PET_TEMPLATE = 2
local ITEM_NOTIFY_MERGE_PET_ID = 3
local FILTER_TYPE_SIDE = 1
local FILTER_TYPE_FULL = 2
local FILTER_TYPE_LIGHT = 3
local FILTER_TYPE_SPECIAL = 4
local FILTER_TYPE_NON_BREAK = 5
local ITEM_OBTAIN_ADVANCE_TIME = 1

ItemBatchComponent.BatchType = {
	Sub = 2,
	Add = 1
}

function ItemBatchComponent:findObjects()
	return
end

function ItemBatchComponent:initView()
	self.itemNotifyManager = ItemNotifyManager(self)
	self.logger = logger
end

function ItemBatchComponent:onNotifyItem(info)
	local idNumDict, source, context = unpack(info)
	local ctx = context or {}
	local chestTemplateId = ctx.chestTemplateId

	if chestTemplateId and (source == ItemConstSourceData.ITEM_SOURCE_OPEN_CHEST or source == ItemConstSourceData.ITEM_SOURCE_OPEN_CHEST_FULL_SCREEN) then
		local chestCfg = ChestData[chestTemplateId] or {}
		local mode = chestCfg.rewardAttractMode or Const.RewardAttractMode.Disabled

		if mode > 0 then
			ClientChestRewardAttractCtrl.fireWithItems(chestTemplateId, idNumDict)
		end
	end

	if self.itemNotifyManager ~= nil then
		if not self.itemNotifyManager.running then
			self.itemNotifyManager:run()
			TimerManager.addTimer(0.1, function()
				self.itemNotifyManager:exit()
			end)
		end

		self.itemNotifyManager:doItemNotify(idNumDict, source, context)
	else
		self:handleOnItemBatchNotifyEnd({
			{
				idNumDict,
				source,
				context
			}
		})
	end
end

function ItemBatchComponent:onNotifyItemBatch(info)
	local notifyList, soc = unpack(info)

	self:handleOnItemBatchNotifyEnd(notifyList, soc)
end

function ItemBatchComponent:buildInstanceLookup(instances)
	if not instances or #instances == 0 then
		return nil
	end

	local lookup = {}

	for _, inst in ipairs(instances) do
		local itemId = inst.itemId

		if itemId then
			lookup[itemId] = lookup[itemId] or {}

			lume.push(lookup[itemId], inst)
		end
	end

	return lookup
end

function ItemBatchComponent:batchDataList(notifyList, filterType, batchType)
	local dropId
	local result = {
		[ITEM_NOTIFY_NORMAL] = {},
		[ITEM_NOTIFY_MERGE_SOURCE] = {},
		[ITEM_NOTIFY_MERGE_PET_TEMPLATE] = {},
		[ITEM_NOTIFY_MERGE_PET_ID] = {}
	}
	local mergeSource = {}
	local mergePetTemplate = {}
	local mergePetId = {}

	for _, notifyInfo in ipairs(notifyList) do
		local idNumBoundDict, source, context = unpack(notifyInfo)
		local itemTargetInfo = context.itemTargetInfo or {}
		local petInfo = context.clientShowPetInfo

		dropId = dropId or context.dropId

		local instByItem = filterType == FILTER_TYPE_FULL and self:buildInstanceLookup(context.successInstances) or nil
		local ibnsdd

		if filterType == FILTER_TYPE_SIDE then
			ibnsdd = ItemBatchNotifySideData[source]
		elseif filterType == FILTER_TYPE_FULL then
			ibnsdd = ItemBatchNotifyFullData[source]
		elseif filterType == FILTER_TYPE_LIGHT then
			ibnsdd = ItemBatchNotifyLightData[source]
		elseif filterType == FILTER_TYPE_SPECIAL then
			ibnsdd = ItemBatchNotifySpecialData[source]
		elseif filterType == FILTER_TYPE_NON_BREAK then
			ibnsdd = ItemBatchNotifyDontInterData[source]
		end

		for itemId, numInfo in pairs(idNumBoundDict) do
			local itemCount = ItemUtils.getItemCountFromNumInfo(numInfo)

			if itemCount > 0 and batchType == ItemBatchComponent.BatchType.Add or itemCount < 0 and batchType == ItemBatchComponent.BatchType.Sub then
				local idd = ItemData[itemId] or {
					invId = ItemConst.INV_TYPE_SPECIAL
				}
				local typeDesKey = idd.invId == ItemConst.INV_TYPE_SPECIAL and "item_" .. tostring(itemId) or "type_" .. tostring(idd.type)
				local isShowIpContent = self:isShowIpContent(itemId)

				if isShowIpContent and filterType == FILTER_TYPE_SPECIAL then
					typeDesKey = "type_6"
				end

				local showType = ibnsdd and (ibnsdd[typeDesKey] or ibnsdd.default)

				showType = showType == ITEM_NOTIFY_SHIELD and idd.invId == ItemConst.INV_TYPE_SPECIAL and ibnsdd and ibnsdd["type_" .. tostring(idd.type)] or showType

				local instList = instByItem and instByItem[itemId]

				if instList and showType ~= nil and showType ~= ITEM_NOTIFY_SHIELD then
					for _, inst in ipairs(instList) do
						lume.push(result[ITEM_NOTIFY_NORMAL], {
							itemId,
							inst.count,
							source,
							[5] = inst
						})
					end
				elseif showType == ITEM_NOTIFY_NORMAL then
					if itemId == ItemConst.ITEM_SPECIAL_PET_DISPLAY and petInfo then
						lume.push(result[showType], {
							itemId,
							itemCount,
							0,
							petInfo
						})
					else
						lume.push(result[showType], {
							itemId,
							itemCount,
							0
						})
					end
				elseif showType == ITEM_NOTIFY_MERGE_SOURCE then
					mergeSource[source] = mergeSource[source] or {}

					local info = mergeSource[source][itemId] or {
						num = 0
					}

					if itemId == ItemConst.ITEM_SPECIAL_PET_DISPLAY and petInfo then
						info.content = petInfo
					end

					if source == ItemConstSourceData.ITEM_SOURCE_ACTIVITY_COLLECT_BADGE then
						info.content = context
					end

					mergeSource[source][itemId] = info
					info.num = info.num + itemCount
				elseif showType == ITEM_NOTIFY_MERGE_PET_TEMPLATE then
					local petTemplateIds = itemTargetInfo[itemId] or {}

					for _, petTemplateId in pairs(petTemplateIds) do
						mergePetTemplate[petTemplateId] = mergePetTemplate[petTemplateId] or {}
						mergePetTemplate[petTemplateId][itemId] = (mergePetTemplate[petTemplateId][itemId] or 0) + itemCount
					end
				elseif showType == ITEM_NOTIFY_MERGE_PET_ID then
					local petIdInfos = itemTargetInfo[itemId] or {}

					for _, info in pairs(petIdInfos) do
						local petId, rate = unpack(info)

						mergePetId[petId] = mergePetId[petId] or {}
						mergePetId[petId][itemId] = (mergePetId[petId][itemId] or 0) + itemCount * rate
					end
				end
			end
		end
	end

	for source, idNums in pairs(mergeSource) do
		for id, info in pairs(idNums) do
			lume.push(result[ITEM_NOTIFY_MERGE_SOURCE], {
				id,
				info.num,
				source,
				info.content
			})
		end
	end

	for petTemplateId, idNums in pairs(mergePetTemplate) do
		for id, num in pairs(idNums) do
			lume.push(result[ITEM_NOTIFY_MERGE_PET_TEMPLATE], {
				id,
				num,
				petTemplateId
			})
		end
	end

	for petId, idNums in pairs(mergePetId) do
		for id, num in pairs(idNums) do
			lume.push(result[ITEM_NOTIFY_MERGE_PET_ID], {
				id,
				num,
				petId
			})
		end
	end

	return dropId, result
end

function ItemBatchComponent:_extractQuickUseItems(notifyList)
	local remaining = {}

	for _, notifyInfo in ipairs(notifyList) do
		local idNumDict, source, context = unpack(notifyInfo)
		local keptDict = {}
		local instByItem = context and self:buildInstanceLookup(context.successInstances) or nil

		for itemId, numInfo in pairs(idNumDict) do
			if QuickUseUtils.isQuickUse(itemId) then
				local itemCount = ItemUtils.getItemCountFromNumInfo(numInfo)

				if itemCount and itemCount > 0 then
					local instances = instByItem and instByItem[itemId]
					local instance = instances and instances[1]

					self.ctrl:pushQuickUseItem({
						id = itemId,
						num = itemCount,
						source = source,
						genID = instance and instance.genID,
						invId = instance and instance.invId
					})
				else
					keptDict[itemId] = numInfo
				end
			else
				keptDict[itemId] = numInfo
			end
		end

		remaining[#remaining + 1] = {
			keptDict,
			source,
			context
		}
	end

	return remaining
end

function ItemBatchComponent:handleOnItemBatchNotifyEnd(notifyList, type)
	local sideNotifyList = self:_extractQuickUseItems(notifyList)
	local bpActive, normal, bpActiveSide, normalSide

	for index, notifyInfo in ipairs(notifyList) do
		local _, source = unpack(notifyInfo)

		if source == ItemConstSourceData.ITEM_SOURCE_BP_ACTIVE then
			bpActive = bpActive or {}
			bpActiveSide = bpActiveSide or {}
			bpActive[#bpActive + 1] = notifyInfo
			bpActiveSide[#bpActiveSide + 1] = sideNotifyList[index]
		else
			normal = normal or {}
			normalSide = normalSide or {}
			normal[#normal + 1] = notifyInfo
			normalSide[#normalSide + 1] = sideNotifyList[index]
		end
	end

	if normal then
		self:_dispatchItemBatchNotify(normal, type, normalSide)
	end

	if bpActive then
		self:_openBpUnlockThenShow(bpActive, type, bpActiveSide)
	elseif not normal then
		self:_dispatchItemBatchNotify(notifyList, type, sideNotifyList)
	end
end

function ItemBatchComponent:_openBpUnlockThenShow(notifyList, type, sideNotifyList)
	local shown = false

	local function showRewards()
		if shown then
			return
		end

		shown = true

		self:_dispatchItemBatchNotify(notifyList, type, sideNotifyList)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BP_Get) then
		showRewards()

		return
	end

	pg.global.ui:open(UIConst.UI_ID_BP_Get, {
		gear = ActivityConst.BattlePassGear.Pay2
	}, nil, showRewards)
end

function ItemBatchComponent:_dispatchItemBatchNotify(notifyList, type, sideNotifyList)
	local sideGroups, hasSideObtain = self:_prepareSideItemBatchGroups(sideNotifyList, ItemBatchComponent.BatchType.Add)

	self:handleSpecialItemBatch(notifyList, type, ItemBatchComponent.BatchType.Add)
	self:handleFullScreenItemBatch(notifyList, type, ItemBatchComponent.BatchType.Add)

	local propObtainMinDelay = self:handleFullScreenNonBreakItemBatch(notifyList, type, ItemBatchComponent.BatchType.Add, hasSideObtain)

	self:handleSideItemBatch(sideNotifyList, type, ItemBatchComponent.BatchType.Add, propObtainMinDelay, sideGroups)
	self:handleLightItemBatch(notifyList, type, ItemBatchComponent.BatchType.Add)
	self:handleExtraTip(notifyList, ItemBatchComponent.BatchType.Add)
	self:handleSpecialItemBatch(notifyList, type, ItemBatchComponent.BatchType.Sub)
	self:handleSideItemBatch(sideNotifyList, type, ItemBatchComponent.BatchType.Sub)
	self:handleLightItemBatch(notifyList, type, ItemBatchComponent.BatchType.Sub)
	self:handleExtraTip(notifyList, ItemBatchComponent.BatchType.Sub)
end

function ItemBatchComponent:handleOrdinaryItemBatch(notifyList)
	local showDelay = self:getShowDelay(notifyList)
	local items = {}
	local itemIndexByKey = {}

	local function appendItem(itemId, count, templateId)
		local key = templateId and itemId .. ":" .. templateId or itemId
		local index = itemIndexByKey[key]

		if index then
			items[index].num = items[index].num + count
		else
			items[#items + 1] = {
				id = itemId,
				num = count,
				templateId = templateId
			}
			itemIndexByKey[key] = #items
		end
	end

	for _, notifyInfo in ipairs(notifyList or EMPTY_TABLE) do
		local idNumDict = notifyInfo[1] or {}
		local context = notifyInfo[3] or {}

		for itemId, numInfo in pairs(idNumDict) do
			local count = ItemUtils.getItemCountFromNumInfo(numInfo)

			if count and count > 0 then
				local targetIds = context.itemTargetInfo and context.itemTargetInfo[itemId]
				local hasTarget = false

				if itemId == ItemConst.ITEM_SPECIAL_RESEARCH_POINT and targetIds then
					for _, templateId in pairs(targetIds) do
						hasTarget = true

						appendItem(itemId, count, templateId)
					end
				end

				if not hasTarget then
					appendItem(itemId, count)
				end
			end
		end
	end

	for _, item in ipairs(items) do
		if ItemData[item.id] then
			self.ctrl:pushPropItem({
				id = item.id,
				num = item.num,
				delay = showDelay,
				templateId = item.templateId
			})
		end
	end
end

function ItemBatchComponent:isShowIpContent(itemId)
	local visible = false
	local itemData = ItemData[itemId]

	if itemData and itemData.showIPContent and itemData.type ~= 6 then
		visible = true
	end

	return visible
end

function ItemBatchComponent:handleExtraTip(notifyList, batchType)
	local strTable = {}
	local isImportantItem = false

	if batchType == ItemBatchComponent.BatchType.Add then
		table.insert(strTable, pg.getGameString("GOT"))
	else
		table.insert(strTable, pg.getGameString("CONSUME_LABEL"))
	end

	for _, notifyInfo in ipairs(notifyList) do
		local idNumBoundDict, source, context = unpack(notifyInfo)

		for itemId, info in pairs(idNumBoundDict) do
			local itemCfg = ItemData[itemId]
			local number = ItemUtils.getItemCountFromNumInfo(info)

			if itemCfg and (number > 0 and batchType == ItemBatchComponent.BatchType.Add or number < 0 and batchType == ItemBatchComponent.BatchType.Sub) then
				table.insert(strTable, string.format(" <link=\"%s\"><color=#5d90eb><u>", itemId))
				table.insert(strTable, pg.getLocalizationText(itemCfg.itemName))
				table.insert(strTable, "*")
				table.insert(strTable, math.abs(number))
				table.insert(strTable, "</u></color></link>")

				if itemCfg.quality >= 4 then
					isImportantItem = true
				end
			end
		end
	end

	if #strTable > 1 then
		pg.game.chat:recvSystemNotice(table.concat(strTable, ""), nil, function(button, action, content)
			if not tonumber(action) then
				return
			end

			function button.luaRenderTooltip(btn, popup)
				LuaUIUtils.refreshItemInfo(popup, {
					itemId = tonumber(action)
				}, button, true)
			end

			button:SetHorizontalAlignment(2)
			button:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_ITEM_POP)
		end, isImportantItem, "tooltip")
	end
end

function ItemBatchComponent:_hasSideObtainItem(resList)
	for _, resInfo in ipairs(resList or EMPTY_TABLE) do
		for _, resSingle in ipairs(resInfo) do
			if ItemData[resSingle[1]] then
				return true
			end
		end
	end

	return false
end

function ItemBatchComponent:_prepareSideItemBatchGroups(notifyList, batchType)
	local sourceGroups = {}
	local sourceGroupMap = {}

	for _, notifyInfo in ipairs(notifyList or EMPTY_TABLE) do
		local source = notifyInfo[2]
		local sourceKey = source == nil and "__nil_source__" or source
		local sourceGroup = sourceGroupMap[sourceKey]

		if sourceGroup == nil then
			sourceGroup = {
				source = source,
				notifyList = {}
			}
			sourceGroupMap[sourceKey] = sourceGroup
			sourceGroups[#sourceGroups + 1] = sourceGroup
		end

		sourceGroup.notifyList[#sourceGroup.notifyList + 1] = notifyInfo
	end

	local hasSideObtain = false

	for _, sourceGroup in ipairs(sourceGroups) do
		local sourceNotifyList = sourceGroup.notifyList

		sourceGroup.showDelay = self:getShowDelay(sourceNotifyList)

		local _, resList = self:batchDataList(sourceNotifyList, FILTER_TYPE_SIDE, batchType)

		sourceGroup.resList = resList
		hasSideObtain = hasSideObtain or self:_hasSideObtainItem(sourceGroup.resList)
	end

	return sourceGroups, hasSideObtain
end

function ItemBatchComponent:handleSideItemBatch(notifyList, type, batchType, minShowDelay, sourceGroups)
	local me = pg.me

	sourceGroups = sourceGroups or self:_prepareSideItemBatchGroups(notifyList, batchType)

	for _, sourceGroup in ipairs(sourceGroups) do
		local showDelay = math.max(sourceGroup.showDelay, minShowDelay or 0)

		self:_handleSideItemBatchInternal(sourceGroup.resList, me, showDelay, sourceGroup.source, batchType)
	end
end

function ItemBatchComponent:_handleSideItemBatchInternal(resList, me, showDelay, source, batchType)
	local items = {}

	for s, resInfo in ipairs(resList) do
		for _, resSingle in ipairs(resInfo) do
			local itemId, itemCount, targetId = unpack(resSingle)
			local iData = ItemData[itemId]

			if iData then
				local msg = {
					id = itemId,
					num = itemCount
				}

				if s == ITEM_NOTIFY_MERGE_SOURCE then
					local sData = SourceData[targetId]

					if sData then
						msg.name = ClientTextUtils.concatByLanguage(pg.getLocalizationText(sData.desc), pg.getLocalizationText(iData.itemName))
					end
				elseif s == ITEM_NOTIFY_MERGE_PET_TEMPLATE then
					local pet = PetData[targetId]

					msg.templateId = targetId

					if pet then
						msg.name = ClientTextUtils.concatByLanguage(pg.getLocalizationText(pet.name), pg.getLocalizationText(iData.itemName))
					end
				elseif s == ITEM_NOTIFY_MERGE_PET_ID then
					msg.petId = targetId

					local petInfo = me:getPetInfo(targetId)
					local pet

					if petInfo then
						msg.templateId = petInfo.templateId
						msg.label = petInfo.label
						pet = PetData[petInfo.templateId]
					else
						msg.templateId = targetId
						pet = PetData[targetId]
					end

					if pet and pet then
						msg.name = string.format("%s%s", pg.getLocalizationText(pet.name), pg.getLocalizationText(iData.itemName))
					end
				end

				msg.delay = showDelay
				items[#items + 1] = msg
			end
		end
	end

	if #items > 0 then
		self.ctrl:pushPropItemGroup({
			source = source,
			batchType = batchType,
			items = items
		})
	end
end

function ItemBatchComponent:handleLightItemBatch(notifyList, type, batchType)
	local showDelay = self:getShowDelay(notifyList)
	local _, resList = self:batchDataList(notifyList, FILTER_TYPE_LIGHT, batchType)

	self:_handleLightItemBatchInternal(resList, showDelay)
end

function ItemBatchComponent:_handleLightItemBatchInternal(resList, showDelay)
	for s, resInfo in pairs(resList) do
		for _, resSingle in ipairs(resInfo) do
			local itemId, itemCount, targetId = unpack(resSingle)
			local iData = ItemData[itemId]

			if iData then
				local msg = {
					id = itemId,
					num = itemCount,
					itemName = pg.getLocalizationText(iData.itemName)
				}

				if s == ITEM_NOTIFY_MERGE_SOURCE then
					local sData = SourceData[targetId]

					msg.socDesc = sData and pg.getLocalizationText(sData.desc)
				elseif s == ITEM_NOTIFY_MERGE_PET_TEMPLATE then
					msg.tmpId = targetId
				elseif s == ITEM_NOTIFY_MERGE_PET_ID then
					msg.pId = targetId
				end

				msg.showDelay = showDelay

				self:showItemTip(msg)
			end
		end
	end
end

function ItemBatchComponent:showItemTip(data)
	local name = data.itemName
	local me = pg.me
	local tmpId, bigIcon, normalIcon
	local showDelay = data.showDelay
	local isItemObtain = data.num > 0

	if data.pId then
		local petInfo = me:getPetInfo(data.pId)

		tmpId = petInfo.templateId

		local pet = PetData[tmpId]

		name = string.format("%s-%s", pg.getLocalizationText(pet.name), name)
		bigIcon = LuaUIUtils.getPetIcon(pet.iconName, LuaUIUtils.PET_ICON)
	elseif data.tmpId then
		tmpId = data.tmpId

		local pet = PetData[tmpId]

		name = string.format("%s-%s", pg.getLocalizationText(pet.name), name)
		bigIcon = LuaUIUtils.getPetIcon(pet.iconName, LuaUIUtils.PET_ICON)
		normalIcon = LuaUIUtils.getIconByItemId(data.id)
	else
		normalIcon = LuaUIUtils.getIconByItemId(data.id)
	end

	local numDesc = ""

	if data.num > 0 then
		numDesc = string.format("X%d", data.num)
	elseif data.num < 0 then
		local content = pg.getGameString("ITEM_CONSUME_TIP")

		name = pg.getFormatText(content, LuaUIUtils.getNameByItemId(data.id))
		numDesc = math.abs(data.num)
	end

	if showDelay > 0 then
		self.ctrl:startTimer(function()
			self.ctrl:showTextTip(name, 3, nil, numDesc, bigIcon, normalIcon, false, true, nil, isItemObtain)
		end, showDelay)
	else
		self.ctrl:showTextTip(name, 3, nil, numDesc, bigIcon, normalIcon, false, true, nil, isItemObtain)
	end
end

function ItemBatchComponent:handleFullScreenItemBatch(notifyList, itemType, batchType)
	local dropId, resList = self:batchDataList(notifyList, FILTER_TYPE_FULL, batchType)
	local itemList = {}

	for _, resInfo in pairs(resList) do
		for _, resSingle in ipairs(resInfo) do
			local itemId, itemCount, source, content, instEntry = unpack(resSingle, 1, 5)
			local item = {
				itemId = itemId,
				itemCount = itemCount,
				content = content,
				source = source
			}

			if instEntry then
				item.invId = instEntry.invId
				item.genID = instEntry.genID
			end

			itemList[#itemList + 1] = item
		end
	end

	if #itemList == 0 then
		return
	end

	if dropId then
		local newList = {}
		local dropData = DropData[dropId] or {}
		local tpDataList = dropData.fixedDrop or {}

		for _, v in ipairs(tpDataList) do
			local reward = self:getAndRemoveAward(itemList, v[1])

			if reward then
				newList[#newList + 1] = reward
			end
		end

		for _, v in ipairs(itemList) do
			newList[#newList + 1] = v
		end

		itemList = newList
	end

	local showDelay, shouldWaitBackHud, shouldWaitRogueBuff, showBadge, shouldWaitNpcDuel = self:getShowDelay(notifyList)
	local source = itemList[1].source

	if shouldWaitBackHud then
		pg.global.ui.hudV2:delayShowItemAdd({
			itemList = itemList,
			source = source
		})

		return
	end

	if shouldWaitRogueBuff then
		if pg.me and pg.me.space and pg.me.space:isRogueEnv() then
			pg.me.space:addCacheInfo({
				uid = UIConst.UI_ID_COMMON_OBTAIN,
				itemList = itemList,
				source = source
			})
		end

		return
	end

	if showBadge == true then
		pg.global.ui.itemObtain:open({
			itemList = itemList,
			source = source
		})

		return
	end

	pg.global.ui.tips:showPropsObtainTips({
		itemList = itemList,
		source = source,
		overallDelayTime = showDelay
	})
end

function ItemBatchComponent:getSource(notifyList)
	if notifyList and notifyList[1] then
		local _, source, _ = unpack(notifyList[1])

		return source
	end

	return nil
end

function ItemBatchComponent:handleFullScreenNonBreakItemBatch(notifyList, itemType, batchType, hasSideObtain)
	local dropId, resList = self:batchDataList(notifyList, FILTER_TYPE_NON_BREAK, batchType)
	local itemList = {}

	for _, resInfo in ipairs(resList) do
		for _, resSingle in ipairs(resInfo) do
			local itemId, itemCount, _ = unpack(resSingle)

			itemList[#itemList + 1] = {
				itemId = itemId,
				itemCount = itemCount
			}
		end
	end

	if #itemList == 0 then
		return
	end

	if dropId then
		local newList = {}
		local dropData = DropData[dropId] or {}
		local tpDataList = dropData.fixedDrop or {}

		for _, v in ipairs(tpDataList) do
			local reward = self:getAndRemoveAward(itemList, v[1])

			if reward then
				newList[#newList + 1] = reward
			end
		end

		for _, v in ipairs(itemList) do
			newList[#newList + 1] = v
		end

		itemList = newList
	end

	local showDelay, _, _, _, shouldWaitNpcDuel = self:getShowDelay(notifyList)

	if shouldWaitNpcDuel then
		if pg.me and pg.me.space and pg.me.space:isNpcDuel() then
			pg.me.space:npcDuelItemGetCahce({
				uid = UIConst.UI_ID_COMMON_OBTAIN,
				itemList = itemList
			})
		end

		return
	end

	local itemObtainDelay = showDelay
	local propObtainMinDelay

	if hasSideObtain then
		itemObtainDelay = math.max(0, showDelay - ITEM_OBTAIN_ADVANCE_TIME)
		propObtainMinDelay = math.max(showDelay, itemObtainDelay + ITEM_OBTAIN_ADVANCE_TIME)
	end

	self.ctrl:pushLightPropItem({
		overallDelayTime = itemObtainDelay,
		itemList = itemList
	})

	return propObtainMinDelay
end

function ItemBatchComponent:handleSpecialItemBatch(notifyList, itemType, batchType)
	local showDelay = self:getShowDelay(notifyList)
	local _, resList = self:batchDataList(notifyList, FILTER_TYPE_SPECIAL, batchType)

	self:_handleSpecialItemBatchInternal(resList, showDelay)
end

function ItemBatchComponent:_handleSpecialItemBatchInternal(resList, showDelay)
	for s, resInfo in pairs(resList) do
		for _, resSingle in ipairs(resInfo) do
			local itemId, itemCount, targetId = unpack(resSingle)
			local msg = LuaUIUtils.getSpecialItemInfo(itemId, itemCount)

			if msg ~= nil and not Bitset.getBit(pg.me.notifiedItemSet, itemId) then
				pg.me:serverMsg("RPC_CS_OnItemSpecialNotify", itemId)

				if showDelay > 0 then
					self.ctrl:startTimer(function()
						self.ctrl:showSpecialReplaceItem(msg)
					end, showDelay)
				else
					self.ctrl:showSpecialReplaceItem(msg)
				end
			else
				if msg ~= nil and Bitset.getBit(pg.me.notifiedItemSet, itemId) and not self:isShowIpContent(itemId) then
					msg.type = "item"

					if showDelay > 0 then
						self.ctrl:startTimer(function()
							self.ctrl:showSpecialReplaceItem(msg)
						end, showDelay)
					else
						self.ctrl:showSpecialReplaceItem(msg)
					end
				end

				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					logger:debug("skip item special notify", itemId, itemCount)
				end
			end
		end
	end
end

function ItemBatchComponent:getAndRemoveAward(rewardList, id)
	local res, index

	for i, v in ipairs(rewardList) do
		if v.itemId == id then
			res = v
			index = i

			break
		end
	end

	if res then
		table.remove(rewardList, index)
	end

	return res
end

function ItemBatchComponent:getShowDelay(notifyList)
	local showDelay = 0
	local shouldWaitBackHud = false
	local shouldWaitRogueBuff = false
	local showBadge = false
	local shouldWaitNpcDuel = false

	for _, notifyInfo in ipairs(notifyList) do
		local _, source, context = unpack(notifyInfo)

		if source == ItemConstSourceData.ITEM_SOURCE_OPEN_CHEST or source == ItemConstSourceData.ITEM_SOURCE_OPEN_CHEST_FULL_SCREEN then
			local chestTemplateId = context.chestTemplateId

			if chestTemplateId then
				local chestCfg = ChestData[chestTemplateId] or {}

				showDelay = math.max(showDelay, chestCfg.openingTime or 0)

				local mode = chestCfg.rewardAttractMode or Const.RewardAttractMode.Disabled

				if mode == Const.RewardAttractMode.EnableDelayShow then
					local extra = ClientChestRewardAttractCtrl.getShowDelay(chestTemplateId)

					if extra > 0 then
						showDelay = math.max(showDelay, (chestCfg.openingTime or 0) + extra)
					end
				end
			end

			local envObjTemplateId = context.envObjTemplateId

			if envObjTemplateId then
				showDelay = math.max(showDelay, (EnvObjectData[envObjTemplateId] or EMPTY_TABLE).openingTime or 0)
			end
		elseif source == ItemConstSourceData.ITEM_SOURCE_DELEGATION then
			showDelay = QuestConst.delegationDelayObtainReward
		elseif source == ItemConstSourceData.ITEM_SOURCE_NPCDUEL_CLEAR_FIRST or source == ItemConstSourceData.ITEM_SOURCE_NPCDUEL_CLEAR_REPEAT then
			shouldWaitNpcDuel = true
		elseif SourceData[source] and SourceData[source].showDelay and SourceData[source].showDelay > 0 then
			showDelay = math.max(showDelay, SourceData[source].showDelay)
		elseif source == ItemConstSourceData.ITEM_SOURCE_EXCHANGE_PET then
			shouldWaitBackHud = true
		elseif source == ItemConstSourceData.ITEM_SOURCE_ROGUE_START_STYLE or source == ItemConstSourceData.ITEM_SOURCE_SANDBOX_ROGUELIKE then
			shouldWaitRogueBuff = true
		elseif source == ItemConstSourceData.ITEM_SOURCE_ACTIVITY_COLLECT_BADGE then
			showBadge = true
		end
	end

	return showDelay, shouldWaitBackHud, shouldWaitRogueBuff, showBadge, shouldWaitNpcDuel
end

function ItemBatchComponent:onDestroy()
	return
end

function ItemBatchComponent:repr()
	return self.className
end

return ItemBatchComponent
