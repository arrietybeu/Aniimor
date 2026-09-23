-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientHomelandUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local HomelandFormulaData = require("Data.homeland_formula_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeObjectData = require("Data.home_object_data")
local HomeTypeData = require("Data.home_type_data")
local RevertHomeObjectData = require("Data.revert_home_object_data")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local PetData = require("Data.pet_data")
local AreaData = require("Data.homeland_area_data")
local HomeData = require("Data.homeland_config_data")
local ComposeData = require("Data.home_handbook_ornament_set_data")
local FurnitureData = require("Data.home_handbook_homeland_data")
local ComposeFurnitureData = require("Data.compose_furniture_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local HomeItemReleaseData = require("Data.home_item_release_data")
local InteractData = require("Data.interact_data")
local InteractionConst = require("Common.Const.InteractionConst")
local LotteryUtils = require("Utils.LotteryUtils")
local Time = require("Core.Common.Time")
local ShopCommonHelper = require("Utils.ShopCommonHelper")
local ClientHomelandUtils = {}

ClientHomelandUtils.HomelandUnlockType = {
	None = 0,
	Drawing = 2,
	Condition = 1
}

local HOMELAND_DRAWING_UNLOCK_DESC = "HOMELAND_DRAWING_UNLOCK_DESC"
local HOMELAND_DRAWING_SOURCE_TITLE = "HOMELAND_DRAWING_SOURCE_TITLE"
local HOMELAND_NOTE_UNLOCK_DESC = "HOMELAND_NOTE_UNLOCK_DESC"
local HOMELAND_NOTE_SOURCE_TITLE = "HOMELAND_NOTE_SOURCE_TITLE"
local HOMELAND_DRAWING_UNLOCK_DESC_SIMPLE = "HOMELAND_DRAWING_UNLOCK_DESC_SIMPLE"
local FURNITURE_RED_DOT_READ_SNAPSHOT_KEY = "read_snapshot"
local FURNITURE_RED_DOT_ITEM_TYPE_ID = 101

local function isAccelerateNeedPetWork(formulaData)
	return formulaData.accelerateNeedPetWork == 1 or formulaData.accelerateNeedPetWork == true
end

local function hasPetWorkingOnProduceStage(space, ornamentId, stageId)
	local petList = space.facilityAllocationInfo[ornamentId]

	if not petList then
		return false
	end

	local allocationMap = space.allocation

	for _, petId in ipairs(petList) do
		local allocationInfo = allocationMap[petId]

		if allocationInfo and allocationInfo.opId == stageId then
			return true
		end
	end

	return false
end

function ClientHomelandUtils.getDrawingUnlockText(isFurniture, simple)
	if isFurniture then
		if simple then
			local text = pg.getGameString(HOMELAND_DRAWING_UNLOCK_DESC_SIMPLE)

			if not text or text == "" or text == HOMELAND_DRAWING_UNLOCK_DESC_SIMPLE or tonumber(text) then
				return "图纸解锁"
			end

			return text
		end

		local text = pg.getGameString(HOMELAND_DRAWING_UNLOCK_DESC)

		if not text or text == "" or text == HOMELAND_DRAWING_UNLOCK_DESC or tonumber(text) then
			return "获取家具图纸后解锁"
		end

		return text
	end

	local text = pg.getGameString(HOMELAND_NOTE_UNLOCK_DESC)

	if not text or text == "" or text == HOMELAND_NOTE_UNLOCK_DESC or tonumber(text) then
		return "获取配方笔记后解锁"
	end

	return text
end

function ClientHomelandUtils.getDrawingSourceTitle(isFurniture)
	if isFurniture then
		local text = pg.getGameString(HOMELAND_DRAWING_SOURCE_TITLE)

		if not text or text == "" or text == HOMELAND_DRAWING_SOURCE_TITLE or tonumber(text) then
			return "图纸获取途径"
		end

		return text
	end

	local text = pg.getGameString(HOMELAND_NOTE_SOURCE_TITLE)

	if not text or text == "" or text == HOMELAND_NOTE_SOURCE_TITLE or tonumber(text) then
		return "笔记获取途径"
	end

	return text
end

local function buildUnlockState(config, drawingUnlocked, isFurniture, simple)
	local conditionLocked = config.unlockCondition ~= nil and not pg.me.triggerMap:isCompleteOrMeetCondition(config.unlockCondition)
	local drawingLocked = not drawingUnlocked
	local lockType = ClientHomelandUtils.HomelandUnlockType.None
	local lockText = ""

	if conditionLocked then
		lockType = ClientHomelandUtils.HomelandUnlockType.Condition
		lockText = pg.getLocalizationText(config.unlockDesc or "")

		if lockText == "" then
			lockText = LuaUIUtils.getConditionUnlockDesc(config.unlockCondition)
		end
	elseif drawingLocked then
		lockType = ClientHomelandUtils.HomelandUnlockType.Drawing
		lockText = ClientHomelandUtils.getDrawingUnlockText(isFurniture, simple)
	end

	return {
		isLocked = lockType ~= ClientHomelandUtils.HomelandUnlockType.None,
		lockType = lockType,
		conditionLocked = conditionLocked,
		drawingLocked = drawingLocked,
		unlockItemId = config.unlockByItemId or 0,
		lockText = lockText
	}
end

function ClientHomelandUtils.getFurnitureUnlockState(itemId, isSimple)
	local config = HomeObjectData[itemId]

	return buildUnlockState(config, HomeLandUtils.isHomelandFurnitureDrawingUnlocked(pg.me, itemId), true, isSimple)
end

function ClientHomelandUtils.isFurnitureAvailableInArea(itemId)
	local areaNo = Utils.getServerArea()

	return ShopCommonHelper.isConfigAvailableInArea(ItemData[itemId], areaNo) and ShopCommonHelper.isConfigAvailableInArea(HomeObjectData[itemId], areaNo)
end

function ClientHomelandUtils.getFurnitureReleaseState(itemId)
	local releaseConfig = HomeItemReleaseData[itemId]

	if not releaseConfig then
		return {
			isReleased = true,
			isOffShelf = false
		}
	end

	local hasRule = false
	local isReleased = false
	local anyOnShelf = false
	local startTime = releaseConfig.timeRefId and Utils.getConfigTimeOfAreaByData(nil, releaseConfig.timeRefId)

	if startTime then
		hasRule = true

		if startTime <= (Time.secondCache or Time.getSecond()) then
			isReleased = true
			anyOnShelf = true
		end
	end

	if releaseConfig.commodityId then
		local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
		local commodityInfo = ClientCashShopUtils.getCommodityData(releaseConfig.commodityId)

		if commodityInfo then
			hasRule = true

			if ClientCashShopUtils.isCommodityOnShelf(commodityInfo, releaseConfig.commodityId) then
				isReleased = true
				anyOnShelf = true
			elseif ClientCashShopUtils.isCommodityAfterStartTime(commodityInfo) then
				isReleased = true
			end
		end
	end

	if releaseConfig.lotteryId then
		hasRule = true

		if LotteryUtils.isOpen(releaseConfig.lotteryId) then
			isReleased = true
			anyOnShelf = true
		end
	end

	if not hasRule then
		return {
			isReleased = true,
			isOffShelf = false
		}
	end

	return {
		isReleased = isReleased,
		isOffShelf = isReleased and not anyOnShelf
	}
end

function ClientHomelandUtils:isLotteryOpen(lotteryId)
	if lotteryId then
		return LotteryUtils.isOpen(lotteryId)
	end

	return true
end

function ClientHomelandUtils.getFormulaUnlockState(formulaId)
	local config = HomelandFormulaData[formulaId]

	return buildUnlockState(config, HomeLandUtils.isHomelandFormulaDrawingUnlocked(pg.me, formulaId), false, false)
end

function ClientHomelandUtils.getDrawingSourceList(unlockItemId)
	local sourceList = {}
	local itemConfig = ItemData[unlockItemId]

	for _, sourceId in ipairs(itemConfig.source or EMPTY_TABLE) do
		local sourceConfig = ItemSourceData[sourceId]

		if sourceConfig then
			local conditionPass = LuaUIUtils.checkItemSourceCondition(sourceConfig)

			if conditionPass or sourceConfig.showForce == 1 then
				local sourceData = {
					clueSeekID = sourceId,
					conditionPass = conditionPass
				}

				table.merge(sourceData, sourceConfig)

				sourceList[#sourceList + 1] = sourceData
			end
		end
	end

	return sourceList
end

function ClientHomelandUtils.getHomeEditorEditType(editor, editType)
	if editType then
		return editType
	end

	if editor and editor.editType == ClientConst.EntityEditType.Create then
		return ClientConst.HomeEditType.PlaceOrnament
	end

	if editor and editor.editType == ClientConst.EntityEditType.Update then
		return ClientConst.HomeEditType.UpdateOrnament
	end
end

function ClientHomelandUtils.getPendingPlaceOrnamentCount(context)
	context = context or {}

	if context.isPet or context.templateEntityType == Const.HomelandEntType.Pet then
		return 0
	end

	local editInfo = context.editInfo
	local editType = ClientHomelandUtils.getHomeEditorEditType(context.editor, context.editType or editInfo and editInfo.editType)

	if editType ~= ClientConst.HomeEditType.PlaceOrnament and editType ~= ClientConst.HomeEditType.UpdateOrnament then
		return 0
	end

	local templateEntity = context.templateEntity or context.editor and context.editor.templateEntity

	if templateEntity and templateEntity.getGroupPlaceChildCount then
		local count = templateEntity:getGroupPlaceChildCount()

		if editType == ClientConst.HomeEditType.UpdateOrnament then
			count = count - 1
		end

		return math.max(count, 0)
	end

	if editType == ClientConst.HomeEditType.PlaceOrnament then
		return 1
	end

	return 0
end

function ClientHomelandUtils.getPendingPlaceHomeTemplateId(context)
	context = context or {}

	if context.homeTemplateId then
		return context.homeTemplateId
	end

	local editInfo = context.editInfo

	if editInfo then
		if editInfo.homeTemplateId then
			return editInfo.homeTemplateId
		end

		if editInfo.entity then
			return editInfo.entity.homeTemplateId
		end
	end

	if context.entity then
		return context.entity.homeTemplateId
	end
end

function ClientHomelandUtils.getLoadValueById(id)
	local homeObjectData = HomeObjectData[id] or {}

	return homeObjectData.loadValue or 0
end

function ClientHomelandUtils.getComfortValueById(id)
	local homeObjectData = HomeObjectData[id] or {}

	return homeObjectData.comfortValue or 0
end

function ClientHomelandUtils.getPreviewDataByConfig(config, prefabResID)
	if not config or not prefabResID then
		return nil
	end

	return {
		modelResId = prefabResID,
		modelScale = config.modelScale or 1,
		positionOffset = config.positionOffset or {
			0,
			0,
			0
		},
		modelRotationInit = config.modelRotationInit or {
			0,
			0,
			0
		},
		rotationXLimit = config.rotationXLimit or {
			-30,
			30
		},
		rotationYLimit = config.rotationYLimit or {
			-180,
			180
		}
	}
end

function ClientHomelandUtils.getHomeBookFurniturePreviewDataById(id, isSuit)
	local resId, config

	if isSuit then
		if ComposeFurnitureData[id] then
			resId = ComposeFurnitureData[id].prefabResID
		end

		if ComposeData[id] then
			config = ComposeData[id]
		end
	else
		if HomeObjectData[id] then
			resId = HomeObjectData[id].prefabResID
		end

		if FurnitureData[id] then
			config = FurnitureData[id]
		end
	end

	if config and resId then
		return {
			modelResId = resId,
			modelScale = config.modelScale or 1,
			positionOffset = config.positionOffset or {
				0,
				0,
				0
			},
			modelRotationInit = config.modelRotationInit or {
				0,
				0,
				0
			},
			rotationXLimit = config.rotationXLimit or {
				-30,
				30
			},
			rotationYLimit = config.rotationYLimit or {
				-180,
				180
			}
		}
	end

	return nil
end

function ClientHomelandUtils.getPetComfortValueById(id)
	local petInfo = pg.me:getPetInfo(id)

	if not petInfo then
		return 0
	end

	return HomeLandUtils.getCampCarPetComfortValue(petInfo)
end

function ClientHomelandUtils.getPendingPlaceLoadValue(context)
	local editInfo = context and context.editInfo

	if editInfo and editInfo.isBlueprintPlace then
		local loadValue = 0
		local blueprintData = editInfo.blueprintData or {}

		for _, ornamentInfo in ipairs(blueprintData.ornaments or blueprintData.furnitureData or EMPTY_TABLE) do
			loadValue = loadValue + ClientHomelandUtils.getLoadValueById(ornamentInfo.homeId)
		end

		return loadValue
	end

	local homeTemplateId = ClientHomelandUtils.getPendingPlaceHomeTemplateId(context)

	if homeTemplateId == nil then
		return 0
	end

	local homeObjectData = HomeObjectData[homeTemplateId] or {}

	return ClientHomelandUtils.getPendingPlaceOrnamentCount(context) * (homeObjectData.loadValue or 0)
end

function ClientHomelandUtils.getHomelandCurLoadValue(areaId, carGroup)
	if carGroup ~= nil then
		local campCarEnt = carGroup.campCarEnt

		if campCarEnt then
			return campCarEnt.CampCarLoadValue or 0
		end

		return 0
	end

	if pg.space and pg.space.homeAreaStats and pg.space.homeAreaStats[areaId] then
		return pg.space.homeAreaStats[areaId].loadValue or 0
	end

	return 0
end

function ClientHomelandUtils.getHomelandPreviewLoadValue(addLoadValue, areaId, carGroup)
	return ClientHomelandUtils.getHomelandCurLoadValue(areaId, carGroup) + (addLoadValue or 0)
end

function ClientHomelandUtils.getHomelandLoadValueLimit(areaId, carGroup)
	if carGroup then
		if HomeData and HomeData.homeCampLoadLimit then
			return HomeData.homeCampLoadLimit or 0
		end
	elseif AreaData and AreaData[areaId] then
		return AreaData[areaId].loadLimit or 0
	end

	return 0
end

function ClientHomelandUtils.checkHomelandLoadCanAdd(context, areaId, carGroup)
	local limit = ClientHomelandUtils.getHomelandLoadValueLimit(areaId, carGroup)

	if not limit or limit <= 0 then
		return true
	end

	return limit >= ClientHomelandUtils.getHomelandPreviewLoadValue(ClientHomelandUtils.getPendingPlaceLoadValue(context), areaId, carGroup)
end

function ClientHomelandUtils.collectOrnamentEditGroupEntities(seedEntities, context)
	context = context or {}

	local entities = {}
	local entityMap = {}
	local pendingEntities = {}
	local collectGroups = context.collectGroups == true
	local entityGroupIndexes = collectGroups and {} or nil
	local entityGroupParents = collectGroups and {} or nil
	local entityGroupCount = 0
	local editor = context.editor
	local areaId = context.areaId
	local homeSpace = context.homeSpace

	if homeSpace == nil then
		homeSpace = pg.me and pg.me.space
	end

	local getEntity = context.getEntity or function(ornamentId)
		return pg.game.home:getHomeEntity(ornamentId)
	end

	local function addEntity(entity, groupIndex)
		if not entity or entity.destroyed or not entity.id or not entity.ornamentId then
			return
		end

		if areaId and entity.areaId ~= areaId then
			return
		end

		if entityMap[entity.id] then
			if collectGroups and groupIndex then
				local currentRoot = groupIndex

				while entityGroupParents[currentRoot] ~= currentRoot do
					currentRoot = entityGroupParents[currentRoot]
				end

				local existingRoot = entityGroupIndexes[entity.id]

				while entityGroupParents[existingRoot] ~= existingRoot do
					existingRoot = entityGroupParents[existingRoot]
				end

				if currentRoot ~= existingRoot then
					if currentRoot < existingRoot then
						entityGroupParents[existingRoot] = currentRoot
					else
						entityGroupParents[currentRoot] = existingRoot
					end
				end
			end

			return
		end

		if collectGroups then
			if not groupIndex then
				entityGroupCount = entityGroupCount + 1
				groupIndex = entityGroupCount
				entityGroupParents[groupIndex] = groupIndex
			end

			entityGroupIndexes[entity.id] = groupIndex
		end

		entityMap[entity.id] = entity

		table.insert(entities, entity)
		table.insert(pendingEntities, entity)
	end

	for _, entity in ipairs(seedEntities or EMPTY_TABLE) do
		addEntity(entity)
	end

	local pendingIndex = 1

	while pendingIndex <= #pendingEntities do
		local entity = pendingEntities[pendingIndex]

		pendingIndex = pendingIndex + 1

		local groupIndex = collectGroups and entityGroupIndexes[entity.id] or nil

		if homeSpace and homeSpace.getHomeBlueprintBuildGroupByOrnamentId then
			local _, groupInfo = homeSpace:getHomeBlueprintBuildGroupByOrnamentId(entity.ornamentId)

			for _, ornamentId in ipairs(groupInfo and groupInfo.ornamentIds or EMPTY_TABLE) do
				addEntity(getEntity(ornamentId), groupIndex)
			end
		end

		if editor and editor.buildAttachManager then
			local childOrnamentIds = {}

			editor.buildAttachManager:getAttachChildEntitiesId(entity.ornamentId, childOrnamentIds)

			for ornamentId in pairs(childOrnamentIds) do
				addEntity(getEntity(ornamentId), groupIndex)
			end
		end
	end

	local entityGroups

	if collectGroups then
		entityGroups = {}

		local groupOutputIndexes = {}

		for _, entity in ipairs(entities) do
			local groupRoot = entityGroupIndexes[entity.id]

			while entityGroupParents[groupRoot] ~= groupRoot do
				groupRoot = entityGroupParents[groupRoot]
			end

			local outputIndex = groupOutputIndexes[groupRoot]

			if not outputIndex then
				outputIndex = #entityGroups + 1
				groupOutputIndexes[groupRoot] = outputIndex
				entityGroups[outputIndex] = {}
			end

			table.insert(entityGroups[outputIndex], entity)
		end
	end

	return entities, entityMap, entityGroups
end

function ClientHomelandUtils.getHomeFormulaData(formulaId)
	local formulaData = HomelandFormulaData[formulaId]
	local formulaInfo = {}

	if not formulaData then
		return formulaInfo
	end

	if formulaData.pet then
		formulaInfo.formulaType = 1
		formulaInfo.petList = {
			{
				label = 0,
				petId = formulaData.pet
			}
		}
	else
		formulaInfo.formulaType = 0

		local itemList = {}

		for i = 1, 3 do
			local consumableId = formulaData["consumable" .. i]

			if consumableId then
				local numText = ""

				if pg.space and Utils.isHomeland(pg.space.spaceType) then
					local curCount = ClientUtils.getHomelandItemCountById(consumableId)
					local consumeCount = formulaData["consumableNum" .. i]

					if consumeCount <= curCount then
						numText = pg.getFormatText("{0}/{1}", ClientUtils.getHomelandItemCountById(consumableId), formulaData["consumableNum" .. i])
					else
						numText = pg.getFormatText("<style=Debuff>{0}</style>/{1}", ClientUtils.getHomelandItemCountById(consumableId), formulaData["consumableNum" .. i])
					end
				else
					numText = formulaData["consumableNum" .. i]
				end

				table.insert(itemList, {
					tIndex = 0,
					id = consumableId,
					num = numText
				})
			else
				table.insert(itemList, {
					tIndex = 1
				})
			end
		end

		formulaInfo.itemList = itemList
	end

	if formulaData.time then
		formulaInfo.time = formulaData.time
		formulaInfo.formulaType = 0
	end

	if formulaData.workload then
		formulaInfo.workload = formulaData.workload
		formulaInfo.formulaType = formulaInfo.itemList and 2 or 1
	end

	return formulaInfo
end

function ClientHomelandUtils.getProduceAccelerateInfo(ornamentId, facilityInfo)
	if not pg.me or not pg.me.space or not pg.me:isInSelfHomeland() then
		return nil
	end

	local space = pg.me.space

	facilityInfo = facilityInfo or space.facility[ornamentId]

	if not Utils.checkHomeFacilityStateValid(facilityInfo) or not HomeLandUtils.isHomelandFormulaTimeValid(facilityInfo.formulaId, Time.getSecond()) then
		return nil
	end

	local formulaData = HomelandFormulaData[facilityInfo.formulaId]

	if not formulaData or not formulaData.accelerateStageList or not formulaData.accelerateItemId then
		return nil
	end

	local stageId = formulaData.accelerateStageList
	local stageConfigured = table.contains(formulaData.preOperateList or {}, stageId) or table.contains(formulaData.postOperateList or {}, stageId)

	if not stageConfigured or facilityInfo.facilityState ~= stageId then
		return nil
	end

	if isAccelerateNeedPetWork(formulaData) and not hasPetWorkingOnProduceStage(space, ornamentId, stageId) then
		return nil
	end

	local itemId = formulaData.accelerateItemId
	local itemConfig = ItemData[itemId]

	if not itemConfig then
		return nil
	end

	return {
		costNum = 1,
		ornamentId = ornamentId,
		formulaId = facilityInfo.formulaId,
		stageId = stageId,
		itemId = itemId,
		ownedCount = ClientUtils.getItemCountById(itemId) + ClientUtils.getHomelandItemCountById(itemId),
		itemName = pg.getLocalizationText(itemConfig.itemName),
		icon = itemConfig.icon,
		quality = itemConfig.quality or 0
	}
end

function ClientHomelandUtils.showProduceAccelerateConfirm(itemNameText, confirmCallback)
	local hideTimestamp = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.HomeSpeedUpConfirmTipTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if hideTimestamp + 86400 > Time.secondCache then
		confirmCallback()

		return
	end

	local description = pg.getFormatText(pg.getGameString("HOME_SPEED_UP_COMFIRM"), itemNameText)
	local hideToday = false

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), description, function()
		if hideToday then
			pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.HomeSpeedUpConfirmTipTs, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			pg.global.prefsCacheUtils:save()
		end

		confirmCallback()
	end, nil, nil, nil, nil, {
		hint = true,
		hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
		hintCb = function(isSelected)
			hideToday = isSelected
		end
	})
end

function ClientHomelandUtils.getFurnitureRedDotReadSnapshot()
	local redDotInfo = pg.me:getClientInfo(Const.CLIENT_KEY.HOMELAND_FURNITURE_RED_DOT, FURNITURE_RED_DOT_READ_SNAPSHOT_KEY)

	return redDotInfo or {}
end

function ClientHomelandUtils.isFurnitureRedDotItemValid(itemId, itemFilter)
	local homeObjectInfo = HomeObjectData[itemId]

	if not homeObjectInfo then
		return false
	end

	return not itemFilter or itemFilter(itemId, homeObjectInfo)
end

function ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId)
	if not ClientHomelandUtils.isFurnitureAvailableInArea(itemId) then
		return false
	end

	local releaseInfo = ClientHomelandUtils.getFurnitureReleaseState(itemId)

	if readSnapshot[itemId] == true or not HomeObjectData[itemId] or not releaseInfo.isReleased then
		return false
	end

	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(itemId, true)

	return unlockState and not unlockState.isLocked
end

function ClientHomelandUtils.hasFurnitureSubTypeNew(readSnapshot, typeId, subTypeId, itemFilter)
	local itemIds = RevertHomeObjectData[typeId] and RevertHomeObjectData[typeId][subTypeId]

	for _, itemId in ipairs(itemIds or {}) do
		if ClientHomelandUtils.isFurnitureRedDotItemValid(itemId, itemFilter) and ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId) then
			return true
		end
	end

	return false
end

function ClientHomelandUtils.isFurnitureRedDotType(typeId)
	return typeId ~= nil and typeId ~= FURNITURE_RED_DOT_ITEM_TYPE_ID and RevertHomeObjectData[typeId] ~= nil
end

function ClientHomelandUtils.getFurnitureItemRedDotState(itemId)
	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()
	local hasNew = ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId)

	return hasNew and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function ClientHomelandUtils.getFurnitureItemListRedDotState(itemInfoList)
	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()

	for _, itemInfo in ipairs(itemInfoList or {}) do
		local itemId = itemInfo and itemInfo.itemId

		if itemId and ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId) then
			return RedDotConst.RedDotStyle.NEW
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientHomelandUtils.getFurnitureSubTypeRedDotState(typeId, subTypeId, itemFilter)
	if not ClientHomelandUtils.isFurnitureRedDotType(typeId) or not subTypeId then
		return RedDotConst.RedDotStyle.NONE
	end

	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()
	local hasNew = ClientHomelandUtils.hasFurnitureSubTypeNew(readSnapshot, typeId, subTypeId, itemFilter)

	return hasNew and RedDotConst.RedDotStyle.NEW or RedDotConst.RedDotStyle.NONE
end

function ClientHomelandUtils.getFurnitureTypeRedDotState(typeId, itemFilter)
	if not ClientHomelandUtils.isFurnitureRedDotType(typeId) then
		return RedDotConst.RedDotStyle.NONE
	end

	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()

	for subTypeId in pairs(RevertHomeObjectData[typeId]) do
		if ClientHomelandUtils.hasFurnitureSubTypeNew(readSnapshot, typeId, subTypeId, itemFilter) then
			return RedDotConst.RedDotStyle.NEW
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function ClientHomelandUtils.readFurnitureSubTypeNewItems(typeId, subTypeId, itemFilter)
	local result = {}

	if not ClientHomelandUtils.isFurnitureRedDotType(typeId) or not subTypeId then
		return result
	end

	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()
	local itemIds = RevertHomeObjectData[typeId] and RevertHomeObjectData[typeId][subTypeId]

	for _, itemId in ipairs(itemIds or {}) do
		if ClientHomelandUtils.isFurnitureRedDotItemValid(itemId, itemFilter) and ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId) then
			result[itemId] = true
			readSnapshot[itemId] = true
		end
	end

	if next(result) then
		pg.me:setClientInfo(Const.CLIENT_KEY.HOMELAND_FURNITURE_RED_DOT, FURNITURE_RED_DOT_READ_SNAPSHOT_KEY, readSnapshot)
	end

	return result
end

function ClientHomelandUtils.getFurnitureHudRedDotState()
	local player = pg.me
	local home = pg.game and pg.game.home

	if not player or not home then
		return RedDotConst.RedDotStyle.NONE
	end

	local areaId = home:getNearestAreaId(player:getPosition(), true)
	local readSnapshot = ClientHomelandUtils.getFurnitureRedDotReadSnapshot()

	for typeId, subTypeMap in pairs(RevertHomeObjectData) do
		local typeInfo = HomeTypeData[typeId]

		if ClientHomelandUtils.isFurnitureRedDotType(typeId) and typeInfo and not typeInfo.hideInHomeland and HomeLandUtils.isTypeAreaAllowed(typeId, areaId) then
			for _, itemIds in pairs(subTypeMap) do
				for _, itemId in ipairs(itemIds) do
					local homeObjectInfo = HomeObjectData[itemId]

					if homeObjectInfo and homeObjectInfo.canHomePlace and HomeLandUtils.isOrnamentAreaAllowed(itemId, areaId) and ClientHomelandUtils.isFurnitureRedDotItemNew(readSnapshot, itemId) then
						return RedDotConst.RedDotStyle.NEW
					end
				end
			end
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

return ClientHomelandUtils
