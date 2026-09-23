-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIItemUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ItemData = require("Data.item_data")
local CastItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemShowTypeData = require("Data.item_type_show_data")
local PetData = require("Data.pet_data")
local DropData = require("Data.drop_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemTTLUtils = require("Common.Utils.ItemTTLUtils")
local TradeUtils = require("Common.Utils.TradeUtils")
local ItemConst = require("Common.Const.ItemConst")
local AddressDataConst = require("Const.AddressDataConst")
local RobEggCollectionTagData = require("Data.rob_egg_collection_tag_data")
local RobEggCollectionCalcineRankData = require("Data.rob_egg_collection_calcine_rank_data")
local RobEggCollectionVisualUtils = require("Utils.RobEggCollectionVisualUtils")
local logger = LoggerManager.getLogger("LuaUIUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomeSeasonData = require("Data.home_season_data")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local SceneData = require("Data.scene_data")
local RobEggEquipData = require("Data.robegg_equip_data")
local HoldItemData = require("Data.hold_item_data")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local RobEggChipData = require("Data.robegg_chip_data")
local RobEggChipSlotData = require("Data.robegg_chip_slot_data")
local ItemSourceData = require("Data.item_source_data")
local ItemAcquireLimitData = require("Data.item_acquire_limit_data")
local LimitData = require("Data.limit_data")
local CommonSwitch = require("Common.CommonSwitch")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local functionUnlockConditionsByName
local CashShopConst = require("Const.CashShopConst")
local HotkeyConst = require("Const.HotkeyConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local NoticeDef = require("Common.NoticeDef")
local CurrencyAutoChangeData = require("Data.currency_auto_change_data")
local PetTransmogBaseData = require("Data.pet_transmog_base_data")
local RogueBuffMapping = require("Data.rogue_buff_mapping")
local SysConfigData = require("Data.sys_config_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local PetHatchEggData = require("Data.pet_hatch_egg_data")
local PetHatchEggLabelData = require("Data.pet_hatch_egg_label_data")
local StringEx = require("Core.Framework.String")
local UIConst = require("Const.UIConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local MapAreaConfigData = require("Data.map_area_config_data")
local FormulaData = require("Data.formula_data")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local IsNil = IsNil
local ToBool = ToBool
local SUB_TOOLTIP_CONTENT_READY_TIMEOUT = 3
local ClientConst = require("Const.ClientConst")
local RewardStateUtils = require("Common.Utils.RewardStateUtils")

local function getItemNumState(ownNum, needNum, preferState)
	ownNum = ownNum or 0
	needNum = needNum or 0

	if needNum <= 0 then
		return nil
	end

	if ownNum < needNum then
		return UIConst.ITEM_STATE.LACK
	end

	return preferState or UIConst.ITEM_STATE.FULL
end

local function formatRawItemNum(num)
	local value = tonumber(num)

	if value == nil or value ~= value then
		return tostring(num or 0)
	end

	if math.floor(value) == value then
		return string.format("%.0f", value)
	end

	return tostring(num)
end

local function getLocalizedShortNumberUnitText(textKey)
	local unitText = ClientTextUtils.getGameString(textKey)

	if string.isNilOrEmpty(unitText) or unitText == textKey then
		return ""
	end

	return unitText
end

local function getShortNumberUnitInfo(absValue, useThousandBase)
	if useThousandBase then
		if absValue >= 10000000000000 then
			return 1000000000000, "T"
		elseif absValue >= 10000000000 then
			return 1000000000, "B"
		elseif absValue >= 10000000 then
			return 1000000, "M"
		elseif absValue >= 10000 then
			return 1000, "K"
		end

		return nil, nil
	end

	if absValue >= 10000000000000 then
		return 1000000000000, getLocalizedShortNumberUnitText("TRILLION")
	elseif absValue >= 1000000000 then
		return 100000000, getLocalizedShortNumberUnitText("HUNDRED_MILLION")
	elseif absValue >= 100000 then
		return 10000, getLocalizedShortNumberUnitText("TEN_THOUSAND")
	end

	return nil, nil
end

local function formatShortNumberByBase(num, useThousandBase)
	local value = tonumber(num)

	if value == nil or value ~= value then
		return tostring(num or 0), true
	end

	local absValue = math.abs(value)
	local unitValue, unitText = getShortNumberUnitInfo(absValue, useThousandBase)

	if unitValue == nil then
		return formatRawItemNum(num), true
	end

	if string.isNilOrEmpty(unitText) then
		return nil, false
	end

	local shortValue = math.floor(absValue / unitValue * 10) / 10
	local prefix = value < 0 and "-" or ""
	local valueText = string.format("%s%.1f", prefix, shortValue)

	if ClientConst.SHORT_NUMBER_UNIT_WITHOUT_SEPARATOR_BY_LANGUAGE[pg.languageType] then
		return ClientTextUtils.concatWithoutSeparator(valueText, unitText), true
	end

	return ClientTextUtils.concatByLanguage(valueText, unitText), true
end

local function isShortNumberTenThousandLanguage(language)
	return language == ClientConst.LANGUAGE_TYPE_MAP.zh_CN or language == ClientConst.LANGUAGE_TYPE_MAP.zh_TW or language == ClientConst.LANGUAGE_TYPE_MAP.ko_KR or language == ClientConst.LANGUAGE_TYPE_MAP.ja_JP
end

local function hasTenThousandBaseUnitText()
	return not string.isNilOrEmpty(getLocalizedShortNumberUnitText("TEN_THOUSAND"))
end

local function formatShortNumberBySelectedLanguage(num)
	local selectedLanguage = pg.languageType or 0

	if isShortNumberTenThousandLanguage(selectedLanguage) and hasTenThousandBaseUnitText() then
		local tenThousandText, hasTenThousandUnitText = formatShortNumberByBase(num, false)

		if hasTenThousandUnitText then
			return tenThousandText
		end
	end

	local thousandText = formatShortNumberByBase(num, true)

	return thousandText or formatRawItemNum(num)
end

local function formatUnbreakableDenominator(denominatorText)
	local compactDenominatorText = string.gsub(denominatorText, " ", "")

	return string.format("/%s", compactDenominatorText)
end

local function formatUnbreakableNumber(numberText)
	local compactNumberText = string.gsub(numberText, " ", "")

	return string.format("%s", compactNumberText)
end

local function formatItemNumRatio(numeratorText, denominatorText)
	return string.format("%s<zwsp>%s", formatUnbreakableNumber(numeratorText), formatUnbreakableDenominator(denominatorText))
end

local function createContentReadyTracker(onReady)
	return {
		sealed = false,
		pending = 0,
		finished = false,
		onReady = onReady
	}
end

local function tryFinishContentReady(tracker)
	if tracker.finished or not tracker.sealed or tracker.pending > 0 then
		return
	end

	tracker.finished = true

	tracker.onReady()
end

local function addContentReady(tracker)
	tracker.pending = tracker.pending + 1
end

local function finishOneContentReady(tracker)
	tracker.pending = tracker.pending - 1

	tryFinishContentReady(tracker)
end

local function sealContentReady(tracker)
	tracker.sealed = true

	tryFinishContentReady(tracker)
end

local function loadContainerWithTracker(container, tracker, onLoaded)
	if not tracker then
		container:LoadDefaultUrlManually(onLoaded)

		return
	end

	addContentReady(tracker)
	container:LoadDefaultUrlManually(function(content)
		if onLoaded then
			onLoaded(content)
		end

		finishOneContentReady(tracker)
	end)
end

local itemInfoTTLRenderTokens = setmetatable({}, {
	__mode = "k"
})

return function(LuaUIUtils)
	function LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(uiView, active)
		if IsNil(uiView) then
			return
		end

		local isActive = active and true or false

		uiView:SetActive(isActive)
		uiView:SetActiveFastestAndMarkIgnoreLayout(isActive)
	end

	local ICON_ID_TO_PATH = {
		[LuaUIUtils.PET_ICON] = {
			AddressDataConst.PET_HEAD_ICON,
			AddressDataConst.PET_HEAD_FLASH_ICON
		},
		[LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK] = {
			AddressDataConst.IMG_RESEARCH_BOOK_ICON,
			AddressDataConst.IMG_RESEARCH_BOOK_SHINY_ICON
		},
		[LuaUIUtils.PET_RESEARCH_REWARD] = AddressDataConst.PET_RESEARCH_REWARD_ICON,
		[LuaUIUtils.PET_FIRST_SHOW] = AddressDataConst.IMG_RESEARCH_BOOK_FIRST_SHOW_ICON
	}

	function LuaUIUtils.checkItemSourceCondition(sourceData)
		if not sourceData or not sourceData.condition then
			return true
		end

		for _, conditionId in ipairs(sourceData.condition) do
			if not ClientUtils.checkCondition(conditionId) then
				return false
			end
		end

		return true
	end

	function LuaUIUtils.getItemClientInfoById(itemId, invId, itemOrData)
		local item = {}

		item.itemId = itemId

		if itemId == 0 then
			return item
		end

		local configData = ItemData[itemId]

		if not configData then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("itemId not in ItemData ", itemId)
			end

			return item
		end

		item.name = configData.itemName
		item.funcSimpleRep = configData.funcSimpleRep
		item.funcRep = configData.funcRep
		item.itemDesc = configData.itemDes or ""
		item.quality = configData.quality
		item.typeName = ItemShowTypeData[configData.displayType].type
		item.displayType = configData.displayType

		local iconResId = configData.icon

		iconResId = itemOrData and ItemUtils.isRefineable(itemId) and RobEggCollectionVisualUtils.getIconResId(itemOrData) or iconResId
		item.icon = LuaUIUtils.getIconByIconId(iconResId)
		item.source = configData.source
		item.invIdx = invId or configData.invId
		item.type = configData.type
		item.count = ItemUtils.getItemCountById(pg.me, itemId) or 0
		item.canDrop = configData.canDrop
		item.showIPContent = configData.showIPContent
		item.video = configData.video
		item.resolveGetItem = configData.resolveGetItem
		item.paginationId = configData.paginationId

		local effectInfo = ItemEffectData[itemId] or {}

		item.sType = effectInfo.sType

		local cData = CastItemData[itemId]

		if cData then
			item.quickCapture = cData.canQuickCapture == 1
		end

		return item
	end

	function LuaUIUtils.getItemIdsByItemSType(itemType)
		local ret = {}

		for itemId, itemInfo in pairs(ItemEffectData) do
			if itemInfo.sType == itemType then
				ret[#ret + 1] = itemId
			end
		end

		return ret
	end

	function LuaUIUtils.getItemInfoById(itemId)
		if not ItemData[itemId] then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("itemId invalid>>>", itemId)
			end

			return
		end

		local cData = ItemData[itemId]
		local res = {
			id = itemId,
			icon = cData.icon,
			name = pg.getLocalizationText(cData.itemName),
			quality = cData.quality,
			ownNum = ClientUtils.getItemCountById(itemId, true)
		}

		return res
	end

	function LuaUIUtils.getVitalityMaxStoreNum(itemId)
		local id = itemId or Const.CommonEnergyType_Stamina
		local serverLimit = pg.me and pg.me.energyAutoLimit and pg.me.energyAutoLimit[id]

		if serverLimit then
			return serverLimit
		end

		local vData = CurrencyAutoChangeData[id]

		if vData then
			return vData.autoChangeRange and vData.autoChangeRange[2] or vData.maxValue
		end

		return 0
	end

	function LuaUIUtils.openVitalityGot(itemId)
		local id = itemId or Const.CommonEnergyType_Stamina
		local propList = pg.global.ui.vitalityGot.model:getPropDataList(id)

		if not propList or #propList == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_COMMODITY_LOCK"))

			return false
		end

		pg.global.ui:open(UIConst.UI_ID_VITALITY_GOT, {
			itemId = id
		})

		return true
	end

	function LuaUIUtils.getVitalityData(itemId)
		local id = itemId or Const.CommonEnergyType_Stamina
		local res = {
			id = id,
			ownNum = ClientUtils.getItemCountById(id, true)
		}

		res.icon = LuaUIUtils.getIconByItemId(id)
		res.num = res.ownNum

		local vData = CurrencyAutoChangeData[id]

		if vData == nil then
			return res
		end

		local serverLimit = pg.me and pg.me.energyAutoLimit and pg.me.energyAutoLimit[id]

		res.maxLimitNum = vData.maxValue or math.maxInt
		res.maxRestoreNum = serverLimit or vData.autoChangeRange and vData.autoChangeRange[2] or vData.maxValue
		res.maxNum = res.maxRestoreNum
		res.percent = res.ownNum / res.maxNum
		res.isFull = res.ownNum >= res.maxNum
		res.isLimit = res.ownNum >= res.maxLimitNum

		LuaUIUtils.parseVitalityTime(res)

		return res
	end

	function LuaUIUtils.parseVitalityTime(data)
		local vData = CurrencyAutoChangeData[data.id]

		if vData == nil then
			return
		end

		local restoreType = vData.cycleType
		local ve = vData.changeValue
		local cy = vData.cycleValue

		data.ownNum = ClientUtils.getItemCountById(data.id, true)
		data.isFull = data.ownNum >= data.maxNum

		local remandNum = data.maxRestoreNum - data.ownNum

		data.nextRestoreEndTime = Time.secondCache

		local nextRestoreTime = (pg.me.commonEnergyTimes[data.id] or Time.secondCache + ve * cy) - Time.secondCache

		data.nextRestoreEndTime = nextRestoreTime + Time.secondCache
		data.nextRestoreEndTimeStr = TimeUtils.timeToFormatString(nextRestoreTime)
		remandNum = remandNum - ve

		local additionSeconds = 0

		if restoreType == 1 then
			local day = math.ceil(cy * remandNum / ve)

			additionSeconds = day * 86400
		elseif restoreType == 2 then
			local week = math.ceil(cy * remandNum / ve)

			additionSeconds = week * 604800
		elseif restoreType == 3 then
			local month = math.ceil(cy * remandNum / ve)

			additionSeconds = month * 604800 * 30
		elseif restoreType == 4 then
			local seconds = math.ceil(cy * remandNum / ve)

			additionSeconds = seconds
		end

		local totalRestoreTime = nextRestoreTime + additionSeconds

		data.totalRestoreEndTime = totalRestoreTime + Time.secondCache
		data.totalRestoreEndTimeStr = TimeUtils.timeToFormatStringHHMMSS(totalRestoreTime)
	end

	function LuaUIUtils.parseItemCfgData(data)
		local itemId = data.itemId or data.id

		if itemId and pg.me then
			local replacedTable = ItemUtils.getReplacedItemCountTable(pg.me, {
				[itemId] = 1
			})

			itemId = replacedTable and next(replacedTable) or itemId
		end

		local cData = ItemData[itemId]

		if cData == nil then
			return
		end

		data.icon = cData.icon
		data.name = pg.getLocalizationText(cData.itemName)
		data.quality = cData.quality
		data.ownNum = ClientUtils.getItemCountById(itemId, true)
		data.type = cData.type
		data.itemDes = pg.getLocalizationText(cData.itemDes)
	end

	function LuaUIUtils.getIconByItemId(itemId, iconType)
		if not ItemData[itemId] then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("itemId invalid>>>", itemId)
			end

			return
		end

		local iconId = ItemData[itemId].icon

		if string.isNilOrEmpty(iconId) then
			return
		end

		if iconType == nil then
			return iconId
		end

		iconType = iconType or LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL

		local offset = 4
		local prefix = string.sub(iconId, 1, #iconId - offset)
		local suffix = string.sub(iconId, #iconId - offset + 1)
		local insertSuffix = ""

		if iconType == LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL then
			insertSuffix = "_Small"
		elseif iconType == LuaUIUtils.ITEM_ICON_TYPE.ICON_BIG then
			insertSuffix = "_Large"
		end

		iconId = string.format("%s%s%s", prefix, insertSuffix, suffix)

		return iconId
	end

	function LuaUIUtils.getIconByIconId(iconId)
		return iconId
	end

	function LuaUIUtils.getNameByItemId(itemId)
		if not ItemData[itemId] then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("itemId invalid>>>", itemId)
			end

			return
		end

		local name = ItemData[itemId].itemName

		return pg.getLocalizationText(name)
	end

	function LuaUIUtils.setPropCard(button, idx, propData, showType)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
		local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
		local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
		local genIdTransform = objectReference:GetRefValue("genIdTransform")
		local stateNewULayoutBox = objectReference:GetRefValue("stateNewULayoutBox")
		local slotIndex = objectReference:GetRefValue("slotIndex")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUText")

		slotIndex.text = idx + 1

		button:TryChangePage("CardState", showType)

		if showType == UIConst.INVENTORY_CARD.CARD_EMPTY_IDX then
			return
		end

		if showType == UIConst.INVENTORY_CARD.CARD_IDX then
			button.gameObject.name = propData.itemId
			genIdTransform:GetChild(0).gameObject.name = propData.index
		end

		selectedULayoutBox.gameObject:SetActiveEx(false)
		btnDelUButton.gameObject:SetActiveEx(false)
		stateLockUWidget.gameObject:SetActiveEx(false)
		stateNewULayoutBox.gameObject:SetActiveEx(false)

		iconUImage.url = propData.icon

		button:TryChangePage("Quality", propData.quality)
		button:TryChangePage("CaptureMark", propData.isCaptureBind and 1 or 0)
	end

	function LuaUIUtils.checkParseCarryInfo(data)
		data.itemId = data.id or data.itemId
		data.itemCount = data.num or data.itemCount
		data.genID = data.genID
		data.inHome = data.inHome

		local cData = ItemData[data.itemId]

		if cData == nil or cData.type ~= ItemConst.ITEM_TYPE_CARRY_CORE and cData.type ~= ItemConst.ITEM_TYPE_CARRY_ASSISTED then
			return
		end

		local invId = data.invId
		local genID = data.genID
		local sData
		local itemBag = invId and ItemUtils.getTypedBag(pg.me, invId)
		local hasInst = itemBag and genID and itemBag:get(genID) ~= nil

		if invId == nil or genID == nil or not hasInst then
			sData = pg.global.ui.petTrainingNew.model:parseDefaultCarryInfo(data.itemId)
			data.showLock = false
		else
			sData = pg.global.ui.petTrainingNew.model:parseCarryFullInfoWithId(invId, genID)
			data.showLock = true
		end

		local attr = sData.mainProperties[1] or {
			lv = 0
		}

		attr.name = attr.name or pg.getLocalizationText(1202584679)
		attr.desc = attr.tDesc
		attr.lv = sData.cLevel or attr.lv
		attr.buffDesc = sData.buffDesc
		attr.type = cData.type
		data.carryCoreAttr = attr
		data.isLocked = sData.isLocked

		if not data.cLevel and attr and attr.lv then
			data.cLevel = attr.lv
		end

		if cData.type == ItemConst.ITEM_TYPE_CARRY_CORE then
			data.mainProperties = sData.mainProperties
			data.assistCarryPosList = sData.assistCarryPosList
			data.assistCarryTypeList = sData.assistCarryTypeList
			data.assistUnlock = sData.assistUnlock
			data.slotUnlockLv = sData.slotUnlockLv
			data.energyEffects = sData.energyEffects
			data.energySum = sData.energySum
		else
			data.cpValue = sData.cpValue
			data.energy = sData.energy
			data.mainProperties = sData.mainProperties
			data.randomProperties = sData.randomProperties
		end
	end

	local GRAB_EGG_CALCINATION_TAG_UNKNOWN_PAGE = 3
	local GRAB_EGG_CALCINATION_TAG_NEGATIVE_PAGE = 4

	function LuaUIUtils.getGrabEggCalcinationTagLevelPage(tagLevel, unlocked)
		if unlocked == false or type(tagLevel) ~= "number" then
			return GRAB_EGG_CALCINATION_TAG_UNKNOWN_PAGE
		end

		if tagLevel < 0 then
			return GRAB_EGG_CALCINATION_TAG_NEGATIVE_PAGE
		end

		if tagLevel >= 1 and tagLevel <= 3 then
			return tagLevel - 1
		end

		return GRAB_EGG_CALCINATION_TAG_UNKNOWN_PAGE
	end

	function LuaUIUtils.showCollectiblesTagTooltip(tooltip, param)
		if not tooltip or not param then
			return
		end

		local RobEggCollectionTagData = require("Data.rob_egg_collection_tag_data")
		local tagData = param.tagData

		if not tagData or not tagData.affixId then
			return
		end

		local tagCfg = RobEggCollectionTagData[tagData.affixId]

		if not tagCfg then
			return
		end

		local item = param.item

		if not item then
			return
		end

		local objectReference = tooltip:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local collectiblesTagUContainer = objectReference:GetRefValue("collectiblesTagUContainer")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local titleUWidget = objectReference:GetRefValue("titleUWidget")
		local btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")

		if titleUWidget then
			titleUWidget:SetActive(true)
		end

		if nameUBaseText then
			ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(tagCfg.tagName))
		end

		local tagDes = tagCfg.tagDes or tagCfg.tagDescribe

		if tagDes then
			tooltip:TryChangePage("State", 1)

			if textUBaseText then
				ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(tagDes))
			end
		else
			tooltip:TryChangePage("State", 2)

			if textUBaseText then
				ClientTextUtils.setText(textUBaseText, "")
			end
		end

		if iconUImage then
			iconUImage:SetActive(false)
		end

		if btnDetailUButton then
			btnDetailUButton:SetActive(false)
		end

		if collectiblesTagUContainer then
			collectiblesTagUContainer:SetActive(true)

			local tagLevel = tagCfg.tagLevel or 1

			local function myRenderFunc(content)
				if not content then
					return
				end

				content:TryChangePage("Level", LuaUIUtils.getGrabEggCalcinationTagLevelPage(tagLevel))

				local contentRef = content:GetComponent("ObjectReference")
				local tagIconUImage = contentRef and contentRef:GetRefValue("iconUImage")

				if tagIconUImage then
					tagIconUImage.url = tagCfg.tagIcon or ""
				end
			end

			if collectiblesTagUContainer:CheckURLLoaded() then
				myRenderFunc(collectiblesTagUContainer.content)
			else
				collectiblesTagUContainer.forceSyncLoad = true

				collectiblesTagUContainer:LoadDefaultUrlManually(function(content)
					myRenderFunc(content)
				end)
			end
		end
	end

	function LuaUIUtils.openCollectiblesTagTooltip(param)
		if not param or not param.targetRect then
			return
		end

		LuaUIUtils.popupClueSeekTip({
			autoVer = false,
			autoHor = true,
			useCustomLayout = true,
			targetRect = param.targetRect,
			verAlign = CS.XGUI.EVerticalAlignment.Top,
			padding = param.padding or 32,
			customRefresh = function(tooltip)
				LuaUIUtils.showCollectiblesTagTooltip(tooltip, param)
			end
		})
	end

	function LuaUIUtils.getHomeSeasonCollectionTipText(itemId)
		local pointPerItem, seasonId = HomeSeasonUtils.getCollectionPointPerItem(itemId)

		if not pointPerItem then
			return nil
		end

		local seasonInfo = HomeSeasonData[seasonId]
		local progressModuleInfo = seasonInfo and HomeSeasonModuleData[seasonInfo.progressRefId]
		local progressName = progressModuleInfo and pg.getLocalizationText(progressModuleInfo.name) or ""

		if string.isNilOrEmpty(progressName) then
			return nil
		end

		return ClientTextUtils.concatByLanguage(progressName, string.format("+%d", pointPerItem))
	end

	function LuaUIUtils.refreshUnOpenUContainer(param, container)
		if not param or not container then
			return
		end

		if not param.showUnopen and not param.lockText and not param.conditionLockText then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, true)

		local function callbackFunc()
			local objectReference = container.content:GetComponent("ObjectReference")
			local txtOpenUSDFText = objectReference:GetRefValue("txtOpenUSDFText")
			local unlockTipType = param.unlockTipType or param.showUnopen and 0 or 1

			container.content:TryChangePage("Type", unlockTipType)

			if param.showUnopen then
				ClientTextUtils.setText(txtOpenUSDFText, pg.getGameString("HOMELAND_ITEM_LOCKED"))
			elseif param.conditionLockText then
				ClientTextUtils.setText(txtOpenUSDFText, pg.getLocalizationText(param.conditionLockText))
			elseif param.lockText then
				ClientTextUtils.setText(txtOpenUSDFText, param.lockText)
			end
		end

		if not container:CheckURLLoaded() then
			loadContainerWithTracker(container, param.contentTracker, callbackFunc)
		else
			callbackFunc()
		end
	end

	function LuaUIUtils.formatItemTTLRemaining(item, now)
		now = tonumber(now) or 0

		local state = ItemTTLUtils.getState(item, now)
		local targetTime

		if state == ItemTTLUtils.STATE_NOT_STARTED then
			targetTime = item.vaildStartTime
		elseif state == ItemTTLUtils.STATE_ACTIVE then
			targetTime = item.vaildEndTime
		else
			return ""
		end

		local seconds = math.max(0, (tonumber(targetTime) or 0) - now)

		seconds = math.max(60, seconds - seconds % 60)

		return LuaUIUtils.getCountDownString(seconds, UIConst.TimeType.Short, true)
	end

	function LuaUIUtils.formatItemTTLStatusText(textKey, item, now)
		local text = pg.getGameString(textKey)
		local remainingText = ItemTTLUtils.formatTTLRemainingText(LuaUIUtils.formatItemTTLRemaining(item, now))

		if string.find(text, "%s", 1, true) then
			return string.format(text, remainingText)
		end

		if string.find(text, "{0}", 1, true) then
			return pg.getFormatText(text, remainingText)
		end

		return ClientTextUtils.concatByLanguage(text, remainingText)
	end

	function LuaUIUtils.getItemTTLStatusText(item, now)
		local state = ItemTTLUtils.getState(item, now)
		local textKey = ItemTTLUtils.getTTLStatusTextKey(state)

		if not textKey then
			return nil
		end

		if state == ItemTTLUtils.STATE_EXPIRED then
			return pg.getGameString(textKey)
		end

		return LuaUIUtils.formatItemTTLStatusText(textKey, item, now)
	end

	function LuaUIUtils.refreshGrabEggTipEquipChipSlots(container, itemConfig, itemId, visible)
		if not container then
			return
		end

		if not visible then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		local itemType = itemConfig and itemConfig.type
		local isEquip = itemType == ItemConst.ITEM_TYPE.WEAPON or itemType == ItemConst.ITEM_TYPE.ARMOR

		if not isEquip then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		local equipCfg = RobEggEquipData[itemId]
		local slots = equipCfg and equipCfg.slot

		if not slots or #slots == 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(container, true)

		local function renderFunc()
			if IsNil(container.content) then
				return
			end

			local innerRef = container.content:GetComponent("ObjectReference")

			if not innerRef then
				return
			end

			local titleUBaseText = innerRef:GetRefValue("titleUBaseText")
			local listChipUList = innerRef:GetRefValue("listChipUList")

			if titleUBaseText then
				ClientTextUtils.setText(titleUBaseText, pg.getGameString("GRAB_EGG_AVAILABLE_CHIP"))
			end

			if listChipUList then
				local slotDataList = {}

				for i, chipType in ipairs(slots) do
					local cfg = RobEggChipSlotData[chipType]

					slotDataList[i] = {
						chipType = chipType,
						slotIcon = cfg and cfg.slotIcon or ""
					}
				end

				function listChipUList.luaRenderItem(btn, index, data)
					local itemRef = btn:GetComponent("ObjectReference")
					local chipIconUImage = itemRef and itemRef:GetRefValue("chipIconUImage")
					local lineUWidget = itemRef and itemRef:GetRefValue("lineUWidget")

					if chipIconUImage then
						chipIconUImage.url = data.slotIcon
					end

					if lineUWidget then
						LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(lineUWidget, index < #slotDataList - 1)
					end
				end

				listChipUList:SetList(slotDataList)
			end
		end

		if container:CheckURLLoaded() then
			renderFunc()
		else
			container.forceSyncLoad = true

			container:LoadDefaultUrlManually(function()
				renderFunc()
			end)
		end
	end

	function LuaUIUtils.refreshGrabEggTipAntiquePanel(rootWidget, panelRef, item, calcinationlistUList, levelTagUWidget)
		if not panelRef then
			return
		end

		calcinationlistUList = calcinationlistUList or panelRef:GetRefValue("calcinationlistUList")
		levelTagUWidget = levelTagUWidget or panelRef:GetRefValue("levelTagUWidget")

		local itemId = item and (item.id or item.itemId)
		local antiqueData = itemId and ItemUtils.isRefineable(itemId) and item.props and item.props[ItemConst.ItemPropertyDef.AntiqueData] or nil

		if not antiqueData then
			if calcinationlistUList then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(calcinationlistUList, false)
			end

			if levelTagUWidget then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(levelTagUWidget, false)
			end

			return
		end

		local affixNum = antiqueData.affix_num or 0
		local maxAffixNum = antiqueData.max_affix_num or 0

		if calcinationlistUList then
			local dataList = {}

			for i = 1, maxAffixNum do
				local unlocked = i <= affixNum
				local affix = unlocked and item.props[ItemConst.ItemPropertyDef.AntiqueData .. i] or nil
				local tagCfg = affix and RobEggCollectionTagData[affix.affixId] or nil

				dataList[i] = {
					idx = i,
					unlocked = unlocked,
					affixId = affix and affix.affixId or nil,
					score = affix and affix.score or nil,
					tagName = tagCfg and pg.getLocalizationText(tagCfg.tagName) or "",
					tagLevel = tagCfg and tagCfg.tagLevel,
					tagIcon = tagCfg and tagCfg.tagIcon
				}
			end

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(calcinationlistUList, maxAffixNum > 0)

			function calcinationlistUList.luaRenderItem(button, index, data)
				local page = LuaUIUtils.getGrabEggCalcinationTagLevelPage(data.tagLevel, data.unlocked)

				button:TryChangePage("Level", page)

				local objectReference = button:GetComponent("ObjectReference")
				local iconUImage = objectReference and objectReference:GetRefValue("iconUImage")

				if iconUImage then
					iconUImage.url = data.tagIcon or ""
				end

				button.enabledTooltip = false
				button.luaRenderTooltip = nil
				button.luaClick = page ~= 3 and function()
					LuaUIUtils.openCollectiblesTagTooltip({
						itemId = item.itemId,
						genID = item.genID,
						tagData = data,
						item = item,
						targetRect = rootWidget
					})
				end or nil
			end

			calcinationlistUList:SetList(dataList)
		end

		if levelTagUWidget then
			local degree = antiqueData.degree or ItemConst.AntiqueLevel.INIT
			local rated = degree ~= ItemConst.AntiqueLevel.INIT

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(levelTagUWidget, rated)

			if rated and rootWidget then
				rootWidget:TryChangePage("Level", degree - 1)
			end
		end
	end

	function LuaUIUtils.refreshGrabEggTipInfoList(listUList, itemConfig, itemId, visible)
		if not listUList then
			return
		end

		if not visible then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(listUList, false)

			return
		end

		local itemType = itemConfig and itemConfig.type
		local dataList = {}

		if itemType == ItemConst.ITEM_TYPE.CHIP then
			local chipCfg = RobEggChipData[itemId]

			if chipCfg then
				local isSkillChip = chipCfg.skillId ~= nil

				dataList[#dataList + 1] = {
					stage = isSkillChip and 0 or 1,
					title = isSkillChip and pg.getGameString("GRAB_EGG_ACTIVE_SKILL") or pg.getGameString("GRAB_EGG_CHIP_EFFECT"),
					titleInfo = isSkillChip and pg.getGameString("GRAB_EGG_CHIP_EFFECT") or nil,
					content = pg.getLocalizationText(chipCfg.effectDesc)
				}
			end
		elseif itemType == ItemConst.ITEM_TYPE.WEAPON or itemType == ItemConst.ITEM_TYPE.ARMOR then
			local equipCfg = RobEggEquipData[itemId]

			if equipCfg then
				local title = pg.getGameString("GRAB_EGG_EQUIP_PROP")

				if equipCfg.effectDesc1 then
					dataList[#dataList + 1] = {
						stage = 1,
						title = title,
						content = pg.getLocalizationText(equipCfg.effectDesc1)
					}
				end

				if equipCfg.effectDesc2 then
					dataList[#dataList + 1] = {
						stage = 1,
						title = title,
						content = pg.getLocalizationText(equipCfg.effectDesc2)
					}
				end
			end
		end

		if #dataList == 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(listUList, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(listUList, true)

		function listUList.luaRenderItem(button, index, data)
			local innerRef = button:GetComponent("ObjectReference")

			if not innerRef then
				return
			end

			button:TryChangePage("Stage", data.stage)

			local titleUBaseText = innerRef:GetRefValue("titleUBaseText")
			local titleInfoUBaseText = innerRef:GetRefValue("titleInfoUBaseText")
			local textContentUBaseText = innerRef:GetRefValue("textContentUBaseText")

			if titleUBaseText then
				titleUBaseText:SetActive(index == 0)

				if index == 0 then
					ClientTextUtils.setText(titleUBaseText, data.title or "")
				end
			end

			if titleInfoUBaseText then
				ClientTextUtils.setText(titleInfoUBaseText, data.titleInfo or "")
			end

			if textContentUBaseText then
				ClientTextUtils.setText(textContentUBaseText, data.content or "")
			end
		end

		listUList:SetList(dataList)
	end

	function LuaUIUtils.updateGrabEggBtnDragMode(list, btn)
		if not list or not btn then
			return
		end

		btn.enabledDraggingClick = false

		if list.needScrollable then
			local isPC = pg.global.ui:runPlatformByPC()

			btn.dragMode = isPC and 0 or 2
			btn.enabledLongPress = true
			btn.customLongPressSetting = true
			btn.longPressThreshold = isPC and 0 or 0.1
			btn.longPressAdsorb = true
		else
			btn.dragMode = 0
			btn.enabledLongPress = false
			btn.customLongPressSetting = false
			btn.longPressAdsorb = false
		end
	end

	function LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
		if not durableUContainer then
			return
		end

		local cur, max
		local isEquip = false

		if data and data.type then
			if data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR then
				isEquip = true

				if data.packSlot then
					cur, max = data.packSlot:getDurability()
				elseif data.props and data.props.equipData then
					cur, max = data.props.equipData.durability, data.props.equipData.maxDurability
				end
			elseif data.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
				if data.packSlot then
					cur, max = data.packSlot:getRepairValue()
				elseif data.props and data.props.chipRepairKit then
					cur, max = data.props.chipRepairKit.repairValue, data.props.chipRepairKit.maxRepairValue
				end
			end
		end

		if not max or max <= 0 then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(durableUContainer, false)

			return
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(durableUContainer, true)

		cur = math.max(0, cur or 0)

		local ratio = cur / max
		local pct = ratio * 100
		local colorCfg = SysConfigData.GRABEGG_EQUIP_DUR_COLOR or {
			0,
			30,
			60
		}
		local isEquipped = data.invId == ItemConst.INV_TYPE_EQUIP_SLOTS and (data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or data.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR)
		local page

		page = cur == 0 and isEquipped and 2 or pct > colorCfg[3] and 0 or pct > colorCfg[2] and 1 or 4

		local topOffset = 0

		if isEquip then
			local inId = RobEggItemOut[data.itemId] and RobEggItemOut[data.itemId].inid or data.itemId
			local equipCfg = RobEggEquipData[inId]
			local fullMax = equipCfg and equipCfg.durabilityMax

			if fullMax and fullMax > 0 then
				topOffset = (1 - math.min(max, fullMax) / fullMax) * (durableUContainer.rectTransform.rect.height or 200)
			end
		end

		local function renderFunc()
			durableUContainer.content:TryChangePage("Durable", page)

			local innerRef = durableUContainer.content:GetComponent("ObjectReference")
			local sliderUSlider = innerRef and innerRef:GetRefValue("sliderUSlider")

			if sliderUSlider then
				sliderUSlider.value = ratio
			end

			local barRectTransform = innerRef and innerRef:GetRefValue("barRectTransform")

			if barRectTransform then
				barRectTransform:SetOffsetMaxEx(barRectTransform.offsetMax.x, -topOffset)
			end
		end

		if durableUContainer:CheckURLLoaded() then
			renderFunc()
		else
			durableUContainer.forceSyncLoad = true

			durableUContainer:LoadDefaultUrlManually(function()
				renderFunc()
			end)
		end
	end

	function LuaUIUtils.refreshGrabEggAntiqueTags(itemWidget, data)
		if not itemWidget then
			return
		end

		local objectReference = itemWidget:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		local listTagUList = objectReference:GetRefValue("listTagUList")

		if not listTagUList then
			return
		end

		local item = data and (data.packSlot or data)
		local itemId = item and (item.id or item.itemId)
		local antiqueData = itemId and ItemUtils.isRefineable(itemId) and item.props and item.props[ItemConst.ItemPropertyDef.AntiqueData] or nil

		if not antiqueData then
			listTagUList:SetActive(false)
			listTagUList:SetList({})

			return
		end

		local affixNum = antiqueData.affix_num or 0
		local maxAffixNum = antiqueData.max_affix_num or 0
		local tagDataList = {}

		for i = 1, maxAffixNum do
			local unlocked = i <= affixNum
			local affix = unlocked and item.props[ItemConst.ItemPropertyDef.AntiqueData .. i] or nil
			local tagCfg = affix and RobEggCollectionTagData[affix.affixId] or nil

			tagDataList[i] = {
				idx = i,
				unlocked = unlocked,
				affixId = affix and affix.affixId or nil,
				score = affix and affix.score or nil,
				tagName = tagCfg and pg.getLocalizationText(tagCfg.tagName) or "",
				tagLevel = tagCfg and tagCfg.tagLevel
			}
		end

		listTagUList:SetActive(maxAffixNum > 0)

		function listTagUList.luaRenderItem(button, _, tagData)
			local page = LuaUIUtils.getGrabEggCalcinationTagLevelPage(tagData.tagLevel, tagData.unlocked)

			button:TryChangePage("Level", page)

			button.enabledTooltip = page ~= 3

			if page == 3 then
				button.luaRenderTooltip = nil

				return
			end

			function button.luaRenderTooltip(_, tooltip)
				LuaUIUtils.showCollectiblesTagTooltip(tooltip, {
					itemId = data.itemId or itemId,
					genID = data.genID or item.genID,
					tagData = tagData,
					targetRect = button,
					item = item
				})
			end
		end

		listTagUList:SetList(tagDataList)
	end

	function LuaUIUtils.refreshGrabEggSkillChipIcon(button, itemId)
		if not button then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		local panelSkillUWidget = objectReference:GetRefValue("panelSkillUWidget")

		if not panelSkillUWidget then
			return
		end

		local cfg = itemId and RobEggChipData[itemId]
		local isSkillChip = cfg and cfg.skillId ~= nil and cfg.skillIcon ~= nil

		panelSkillUWidget:SetActive(isSkillChip and true or false)

		if isSkillChip then
			local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")

			if iconSkillUImage then
				iconSkillUImage.url = cfg.skillIcon
			end
		end
	end

	function LuaUIUtils.refreshHomeFormulaTrackingButton(button, visible, itemId, propData)
		if not button then
			return
		end

		button:SetActive(visible)

		if not visible then
			return
		end

		propData = propData or LuaUIUtils.getItemClientInfoById(itemId)

		local pinnedFormulaList = pg.me.pinnedFormulaList or {}
		local isTracking = pinnedFormulaList[1] == itemId

		button:TryChangePage("Lock", isTracking and 1 or 0)

		function button.luaClick()
			local currentPinnedFormulaList = pg.me.pinnedFormulaList or {}
			local oldItemId = currentPinnedFormulaList[1]
			local isCurrentTracking = oldItemId == itemId

			pg.me:requestSetPinnedFormulas(isCurrentTracking and {} or {
				itemId
			}, function()
				button:TryChangePage("Lock", isCurrentTracking and 0 or 1)

				if oldItemId ~= nil and not isCurrentTracking then
					local oldConfigData = ItemData[oldItemId]

					if oldConfigData then
						pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("HOME_TRACKING_FORMULA_TIPS"), pg.getLocalizationText(oldConfigData.itemName)))
					end
				end

				if isCurrentTracking then
					pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("HOME_TRACKING_FORMULA_TIPS"), pg.getLocalizationText(propData.name)))
				else
					pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("HOME_CANCEL_TRACKING_TIPS"), pg.getLocalizationText(propData.name)))
				end
			end)
		end
	end

	function LuaUIUtils.refreshHomeItemInfo(button, itemId, countItemId, param, showSellPrice)
		if param.validate and not param.validate() then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local homeOwenedUContainer = objectReference:GetRefValue("homeOwenedUContainer")
		local homeFormulaUContainer = objectReference:GetRefValue("homeFormulaUContainer")
		local homeListProvideUList = objectReference:GetRefValue("homeListProvideUList")
		local homeMachinableUContainer = objectReference:GetRefValue("homeMachinableUContainer")
		local prizeUContainer = objectReference:GetRefValue("prizeUContainer")
		local isInHomeOrCamp = HomeLandUtils.isInHomeOrCamp()

		if isInHomeOrCamp and itemId then
			LuaUIUtils.refreshHomeFormulaUContainer(itemId, param.formulaInfo, homeFormulaUContainer, showSellPrice, param.validate)
			LuaUIUtils.refreshHomeProvideText(itemId, homeListProvideUList)
			LuaUIUtils.refreshHomeMachinableUContainer(itemId, homeMachinableUContainer, showSellPrice, param.validate)
		else
			if NotNil(homeFormulaUContainer) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeFormulaUContainer, false)
			end

			if NotNil(homeListProvideUList) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeListProvideUList, false)
				homeListProvideUList:SetList({})
			end

			if NotNil(homeMachinableUContainer) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeMachinableUContainer, false)
			end
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeOwenedUContainer, false)

		local showPrice = param.price ~= nil

		if NotNil(prizeUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(prizeUContainer, showPrice)

			if showPrice then
				LuaUIUtils.refreshItemInfoContainer(prizeUContainer, function(content)
					local objectReference = content:GetComponent("ObjectReference")
					local textUBaseText = objectReference:GetRefValue("textUBaseText")
					local boxCoinUButton = objectReference:GetRefValue("boxCoinUButton")

					LuaUIUtils.setCostCurrencyItem(boxCoinUButton, param.price[1], param.price[2])
				end, param.contentTracker)
			end
		end

		return isInHomeOrCamp
	end

	function LuaUIUtils.getItemOperateButtonDataList(param, showConfirmBtn, numSelector)
		local btnDataList = {}

		if param.isShowItemInHand == true and HoldItemData[param.itemId] ~= nil then
			local isCarrying = pg.me:checkInCarry()
			local inCombat = pg.me.isInCombat and pg.me:isInCombat()

			if isCarrying or not inCombat then
				btnDataList[#btnDataList + 1] = {
					name = isCarrying and pg.getLocalizationText(HoldEntPanelConfig.propRetrieveSkillDes) or pg.getGameString("CARRY_ITEM_USE"),
					confirmFunc = function()
						if pg.me:checkInCarry() then
							pg.me:tryPutInItem()
						else
							pg.me:tryTakeOutItem(param.invId, param.genID)
						end

						LuaUIUtils.popupPropTip()

						if param.onShowItemInHand then
							param.onShowItemInHand()
						end
					end
				}
			end
		elseif param.isGotoCarry then
			btnDataList[#btnDataList + 1] = {
				name = pg.getGameString("QUEST_DELEGATION_GO"),
				confirmFunc = function()
					LuaUIUtils.tryOpenPetCultivateUI({
						toPage = Const.PetCulPageNames.CARRY,
						petId = param.petId
					})
				end
			}
		end

		local customBtnDataList = Utils.isTable(param.btnDataList) and param.btnDataList or nil

		if customBtnDataList then
			for _, buttonData in ipairs(customBtnDataList) do
				btnDataList[#btnDataList + 1] = buttonData
			end
		elseif showConfirmBtn and NotNil(numSelector) then
			btnDataList[#btnDataList + 1] = {
				name = pg.getGameString("COMMON_CONFIRM_SOCIAL"),
				confirmFunc = param.confirmClick,
				clickSoundUrl = param.confirmClickSoundUrl
			}
		end

		return btnDataList
	end

	function LuaUIUtils.refreshItemOperateButton(button, param, buttonData, showNumSelector, numSelector)
		if IsNil(button) or not buttonData then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		ClientTextUtils.setText(txtNameUText, buttonData.name)

		button.interactable = buttonData.interactable ~= false

		if buttonData.clickSoundUrl then
			button.clickSoundUrl = buttonData.clickSoundUrl
		end

		function button.luaClick()
			local itemInfo = {}

			itemInfo[param.itemId or param.id] = showNumSelector and NotNil(numSelector) and numSelector.value or 1

			if buttonData.confirmFunc then
				buttonData.confirmFunc(itemInfo)
			end
		end

		if buttonData.path and NotNil(keyHotKeyContent) then
			if buttonData.isLongPress then
				button:SetGamepadLongPress(buttonData.path, keyHotKeyContent.gameObject, 0, function()
					button.luaClick()

					return false
				end)
			else
				button:SetGamepadAction(buttonData.path, keyHotKeyContent.gameObject, function()
					button.luaClick()

					return false
				end)
			end
		end

		button:SetActive(true)
	end

	function LuaUIUtils.refreshCarryItemInfo(button, param)
		local objectReference = button:GetComponent("ObjectReference")

		LuaUIUtils.checkParseCarryInfo(param)

		local txtCP = objectReference:GetRefValue("txtCP")
		local txtEnergy = objectReference:GetRefValue("txtEnergy")
		local carryAdvanced = objectReference:GetRefValue("carryAdvanced")
		local carryCoreBonus = objectReference:GetRefValue("carryCoreBonus")
		local carryBuffDesc = objectReference:GetRefValue("carryBuffDesc")
		local carryAssistList = objectReference:GetRefValue("carryAssistList")
		local carryAdvancedList = objectReference:GetRefValue("carryAdvancedList")
		local listAttributeUList = objectReference:GetRefValue("listAttributeUList")
		local listRandomAttributeUList = objectReference:GetRefValue("listRandomAttributeUList")
		local carryAssistAttr = objectReference:GetRefValue("carryAssistAttr")
		local txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
		local txtAdvanceUBaseText = objectReference:GetRefValue("txtAdvanceUBaseText")

		if not param.carryCoreAttr then
			if NotNil(carryAdvanced) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAdvanced, false)
			end

			if NotNil(carryAssistAttr) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAssistAttr, false)
			end

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryCoreBonus, false)

			return 0
		end

		local carryType = param.carryCoreAttr.type

		ClientTextUtils.setText(txtTitleUBaseText, pg.getGameString("PET_EQUIPMENT_CORE_BUFF"))
		ClientTextUtils.setText(txtAdvanceUBaseText, pg.getGameString("PET_EQUIPMENT_EXTRA_BUFF"))

		local carryPage = carryType == ItemConst.ITEM_TYPE_CARRY_CORE and 1 or 2
		local isDefault = param.invId == nil or param.genID == nil
		local showAdvanced = not isDefault and carryType == ItemConst.ITEM_TYPE_CARRY_CORE

		if NotNil(carryAdvanced) then
			if showAdvanced then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAdvanced, true)

				showAdvanced = LuaUIUtils.refreshCarryAssistInfo(carryAssistList, carryAdvancedList, param)
			elseif not isDefault then
				LuaUIUtils.refreshCarryAssistInfo(carryAssistList, carryAdvancedList, param)
			end

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAdvanced, showAdvanced)
		end

		if NotNil(carryAssistAttr) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAssistAttr, false)
		end

		if NotNil(carryAssistAttr) and carryType == ItemConst.ITEM_TYPE_CARRY_ASSISTED then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryAssistAttr, param.mainProperties and next(param.mainProperties) or param.randomProperties and next(param.randomProperties))
			LuaUIUtils.refreshCarryAssistAttrList(listAttributeUList, param.mainProperties)
			LuaUIUtils.refreshCarryAssistAttrList(listRandomAttributeUList, param.randomProperties)
		end

		local isCarryCore = carryType == ItemConst.ITEM_TYPE_CARRY_CORE

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryCoreBonus, isCarryCore)

		if isCarryCore then
			local attr = param.carryCoreAttr

			ClientTextUtils.setText(carryBuffDesc, attr.buffDesc)

			return carryPage
		end

		if param.cpValue then
			txtCP:SetActive(true)
			ClientTextUtils.setText(txtCP, "CP " .. (param.cpValue or 0))
		else
			txtCP:SetActive(false)
		end

		ClientTextUtils.setText(txtEnergy, param.energy)

		return carryPage
	end

	function LuaUIUtils.refreshGrabEggItemInfo(button, param, itemId, itemConfig)
		local objectReference = button:GetComponent("ObjectReference")
		local showGrabEgg = param.showGrabEgg and true or false

		itemConfig = itemConfig or ItemData[itemId]

		local grabEggChipUContainer = objectReference:GetRefValue("grabEggChipUContainer")
		local grabEggInfoListUList = objectReference:GetRefValue("grabEggInfoListUList")

		LuaUIUtils.refreshGrabEggTipEquipChipSlots(grabEggChipUContainer, itemConfig, itemId, showGrabEgg)
		LuaUIUtils.refreshGrabEggTipInfoList(grabEggInfoListUList, itemConfig, itemId, showGrabEgg)

		return showGrabEgg and 2 or 0
	end

	function LuaUIUtils.refreshRogueBuffItemInfo(param, itemId, desc)
		if RogueBuffMapping[itemId] == nil then
			return false
		end

		local RogueUtils = require("Utils.RogueUtils")
		local series = RogueUtils.getRogueBuffSeries(itemId)
		local typeText = param.originData and param.originData.typeText or pg.getLocalizationText(RogueUtils.getRogueBuffSeriesName(series))
		local rogueBuffCount = RogueUtils.getRogueBuffCountBySeries(series)
		local buffCount = pg.me.rogueBuffs[itemId] or 0
		local buffQuality = RogueUtils.getBuffQuality(itemId)
		local isEquipBuff = buffQuality == Const.RogueBuffQuality.Equipment
		local overrideQuality

		if isEquipBuff then
			local buffMaxLayer = RogueUtils.getBuffMaxLayer(itemId)

			if buffMaxLayer <= buffCount then
				overrideQuality = Const.RogueBuffQuality.Boss
			end
		end

		local _, buffDesc = RogueUtils.getBuffNameAndDesc(itemId, buffCount)

		ClientTextUtils.setText(desc, pg.getLocalizationText(buffDesc))

		return true, overrideQuality, typeText, rogueBuffCount
	end

	function LuaUIUtils.refreshItemOperateButtons(param, showNumSelector, showConfirmBtn, btnBoxNewUButton, btnListUList, numSelector)
		local tracker = param.contentTracker

		if tracker then
			addContentReady(tracker)
		end

		TimerManager.addNextFrameCb(function()
			local canRefresh = (NotNil(btnBoxNewUButton) or NotNil(btnListUList)) and (not param.validate or param.validate())

			if canRefresh then
				local btnDataList = LuaUIUtils.getItemOperateButtonDataList(param, showConfirmBtn, numSelector)
				local useSingleButton = #btnDataList == 1 and NotNil(btnBoxNewUButton)

				if NotNil(btnBoxNewUButton) then
					if useSingleButton then
						LuaUIUtils.refreshItemOperateButton(btnBoxNewUButton, param, btnDataList[1], showNumSelector, numSelector)
					else
						btnBoxNewUButton:SetActive(false)

						btnBoxNewUButton.luaClick = nil
					end
				end

				if NotNil(btnListUList) then
					local useButtonList = #btnDataList > 0 and not useSingleButton

					LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(btnListUList, useButtonList)

					if useButtonList then
						function btnListUList.luaRenderItem(button, _, buttonData)
							LuaUIUtils.refreshItemOperateButton(button, param, buttonData, showNumSelector, numSelector)
						end

						btnListUList:SetList(btnDataList)
					else
						btnListUList:SetList({})
					end
				end
			end

			if tracker then
				finishOneContentReady(tracker)
			end
		end)
	end

	function LuaUIUtils.refreshItemSourceInfo(param, scrollObjectReference, cbFunc, propData)
		local itemId = param.id or param.itemId

		propData = propData or LuaUIUtils.getItemClientInfoById(itemId, param.invId)

		local detailUComponent = scrollObjectReference:GetRefValue("detailUComponent")
		local source = scrollObjectReference:GetRefValue("source")
		local sourceTree = scrollObjectReference:GetRefValue("sourceTree")
		local propSourceUText = scrollObjectReference:GetRefValue("propSourceUText")
		local sourceBtn = scrollObjectReference:GetRefValue("sourceBtn")
		local titleGainUSDFText = scrollObjectReference:GetRefValue("titleGainUSDFText")

		if propData.source then
			local itemSource = {}

			for _, sourceId in ipairs(propData.source) do
				if sourceId ~= 805 or CommonSwitch.IOS_REVIEW == false then
					table.insert(itemSource, sourceId)
				end
			end

			propData.source = itemSource
		end

		ClientTextUtils.setText(titleGainUSDFText, param.sourceTitle or pg.getGameString("GET_CHANNEL"))

		function sourceTree.luaRenderItem(button, _, data)
			local subDesc = button:Find("Widget/TxtName"):GetComponent("UBaseText")

			ClientTextUtils.setText(subDesc, pg.getLocalizationText(data.buttonTxt))
			LuaUIUtils.itemSourceTrigger(button, data, nil, nil, cbFunc)

			if param.onSourceClicked then
				local origClick = button.luaClick

				function button.luaClick(...)
					if origClick then
						origClick(...)
					end

					param.onSourceClicked(data)
				end
			end
		end

		local isSourceExpanded = false

		local function setSourceExpanded(expanded)
			isSourceExpanded = expanded

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(sourceTree, expanded)
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(propSourceUText, not expanded)
		end

		local function tryCloseFold()
			if isSourceExpanded then
				setSourceExpanded(false)

				return true
			end

			return false
		end

		if not param.skipFoldHotkey and NotNil(detailUComponent) then
			LuaUIUtils.bindHotKey(detailUComponent.gameObject, "Raw/GamepadButtonEast", function()
				if tryCloseFold() then
					return false
				end

				return true
			end)
		end

		function sourceBtn.luaClick()
			if pg.game.input:isUsingGamepad() then
				local navMgr = CS.XGUI.Navigation.NavManager.Instance

				if navMgr then
					local isFocusIn = navMgr:IsFocusInNavGroupOf(sourceTree)

					if isFocusIn then
						setSourceExpanded(false)
					else
						setSourceExpanded(true)
						navMgr:PushFocusNavGroupOf(sourceTree)
					end
				end
			else
				setSourceExpanded(not isSourceExpanded)
			end
		end

		local filteredSource = propData.source

		if filteredSource and Utils.isTable(param.allowedSourceIds) then
			local whitelist = {}

			for _, id in ipairs(param.allowedSourceIds) do
				whitelist[id] = true
			end

			local kept = {}

			for _, id in ipairs(filteredSource) do
				if whitelist[id] then
					kept[#kept + 1] = id
				end
			end

			filteredSource = kept
		end

		if pg.me and pg.me.space and Utils.isSpaceFishingCaptureDungeon(pg.me.space.spaceType) then
			filteredSource = nil
		end

		if param.hideSource then
			filteredSource = nil
		end

		local dataList = {}

		for _, sourceId in ipairs(filteredSource or EMPTY_TABLE) do
			local sourceEntry = ItemSourceData[sourceId]

			if sourceEntry then
				local conditionPass = LuaUIUtils.checkItemSourceCondition(sourceEntry)

				if conditionPass or sourceEntry.showForce == 1 then
					local data = {
						clueSeekID = sourceId
					}

					table.merge(data, sourceEntry)

					data.conditionPass = conditionPass

					table.insert(dataList, data)
				end
			end
		end

		local hasSource = #dataList > 0

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(source, hasSource)

		if not hasSource then
			setSourceExpanded(false)
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(propSourceUText, false)

			return
		end

		sourceTree:SetList(dataList)

		local descList = {}

		for i = 1, #dataList do
			descList[i] = pg.getLocalizationText(dataList[i].desc)
		end

		ClientTextUtils.setText(propSourceUText, table.concat(descList, pg.getGameString("INTERVAL_SYMBOL")))
		setSourceExpanded(false)
	end

	function LuaUIUtils.refreshPetEggTagInfo(itemId, scrollObjectReference)
		local eggTagUList = scrollObjectReference:GetRefValue("eggTagUList")

		if not eggTagUList then
			return false
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(eggTagUList, false)
		eggTagUList:SetList({})

		if not Utils.isBreedPetEgg(itemId) and not Utils.isNormalPetEgg(itemId) then
			return false
		end

		local eggCfg = PetHatchEggData[itemId]
		local labelIds = eggCfg and eggCfg.tagConfigManageType or {}

		if #labelIds == 0 then
			return false
		end

		local labelsDisplayInfo = {}
		local labelsDisplayGroupIds = {}

		for _, labelId in ipairs(labelIds) do
			local labelCfg = PetHatchEggLabelData[labelId]

			if labelCfg and not labelsDisplayGroupIds[labelCfg.tagGroupRelation] then
				labelsDisplayGroupIds[labelCfg.tagGroupRelation] = true
				labelsDisplayInfo[#labelsDisplayInfo + 1] = {
					name = labelCfg.labelPoolName,
					desc = labelCfg.labelPool1Desc
				}
			end
		end

		if #labelsDisplayInfo == 0 then
			return false
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(eggTagUList, true)

		function eggTagUList.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtTagUSDFText = objectReference:GetRefValue("txtTagUSDFText")
			local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")

			ClientTextUtils.setText(txtTagUSDFText, pg.getLocalizationText(data.name))
			ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(data.desc))
		end

		eggTagUList:SetList(labelsDisplayInfo)

		return false
	end

	function LuaUIUtils.refreshItemInfoTitleNormal(button, param, itemId, propData, displayCount)
		local objectReference = button:GetComponent("ObjectReference")
		local textUWidget = objectReference:GetRefValue("textUWidget")
		local countText = objectReference:GetRefValue("countText")

		itemId = itemId or param.id or param.itemId
		propData = propData or LuaUIUtils.getItemClientInfoById(itemId, param.invId)

		local showNumber = not param.originData or not param.originData.hideCount
		local itemConfig = ItemData[itemId]
		local itemEffectConfig = ItemEffectData[itemId]

		if itemConfig and itemConfig.hideOwnCount == 1 or itemEffectConfig and itemEffectConfig.autoUse == 1 then
			showNumber = false
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(textUWidget, showNumber)

		if showNumber then
			ClientTextUtils.setText(countText, displayCount or propData.count)
		end
	end

	function LuaUIUtils.refreshItemInfoTitleHome(button, countItemId)
		local objectReference = button:GetComponent("ObjectReference")
		local txtTitleBagUSDFText = objectReference:GetRefValue("txtTitleBagUSDFText")
		local txtBagNumHomeUSDFText = objectReference:GetRefValue("txtBagNumHomeUSDFText")
		local txtTitleHomeUSDFText = objectReference:GetRefValue("txtTitleHomeUSDFText")
		local txtTitleNumHomeUSDFText = objectReference:GetRefValue("txtTitleNumHomeUSDFText")

		ClientTextUtils.setText(txtTitleBagUSDFText, pg.getGameString("BAG") .. ":")
		ClientTextUtils.setText(txtTitleHomeUSDFText, pg.getGameString("FILTER_HOMELAND") .. ":")

		local bagCount = ClientUtils.getItemCountById(countItemId, true)

		ClientTextUtils.setText(txtBagNumHomeUSDFText, tostring(bagCount))

		if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
			local homeCount = ClientUtils.getHomelandItemCountById(countItemId)

			ClientTextUtils.setText(txtTitleNumHomeUSDFText, tostring(homeCount))
		else
			ClientTextUtils.setText(txtTitleNumHomeUSDFText, "--")
		end
	end

	function LuaUIUtils.refreshItemInfoTitleGrabEgg(button, param, itemId, itemConfig, bagItem)
		local objectReference = button:GetComponent("ObjectReference")
		local txtValue = objectReference:GetRefValue("txtValue")
		local progressUProgress = objectReference:GetRefValue("progressUProgress")
		local txtWeight = objectReference:GetRefValue("txtWeight")
		local durableUWidget = objectReference:GetRefValue("durableUWidget")
		local durableNumUBaseText = objectReference:GetRefValue("durableNumUBaseText")
		local calcinationlistUList = objectReference:GetRefValue("calcinationlistUList")
		local levelTagUWidget = objectReference:GetRefValue("levelTagUWidget")

		itemId = itemId or param.id or param.itemId
		itemConfig = itemConfig or ItemData[itemId] or {}

		local sellPrice = itemConfig.sellPrice or 0
		local price = LuaUIUtils.getPropDecomposeNum(bagItem or param.oriData, sellPrice)

		price = price > 0 and price or sellPrice

		ClientTextUtils.setText(txtValue, ClientTextUtils.formatSeparatedNumber(price))
		txtValue.transform.parent.gameObject:SetActiveEx(not param.hideGrabEggPrice)

		local weight = param.weight or itemConfig.weight or 0

		ClientTextUtils.setText(txtWeight, ClientTextUtils.concatByLanguage(weight, "kg"))

		progressUProgress.value = (math.floor(weight / 3) + (weight % 3 ~= 0 and 1 or 0)) / 5

		local durableText = param.durableText

		if durableText == nil then
			local grabEggBag = pg.global.ui.grabEggBag
			local grabEggBagModel = grabEggBag and grabEggBag.model

			durableText = grabEggBagModel and grabEggBagModel:getItemCountText(param.oriData, true) or Const.EmptyString
		end

		local showDurable = not tonumber(durableText) and durableText ~= Const.EmptyString

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(durableUWidget, showDurable)

		if showDurable then
			ClientTextUtils.setText(durableNumUBaseText, durableText)
		end

		LuaUIUtils.refreshGrabEggTipAntiquePanel(button, objectReference, bagItem, calcinationlistUList, levelTagUWidget)
	end

	function LuaUIUtils.refreshItemInfoTitleCarry(button, param)
		local objectReference = button:GetComponent("ObjectReference")
		local txtAttribute = objectReference:GetRefValue("txtAttribute")
		local txtValue = objectReference:GetRefValue("txtValue")

		if not param.carryCoreAttr then
			LuaUIUtils.checkParseCarryInfo(param)
		end

		local attr = param.carryCoreAttr or {}

		ClientTextUtils.setText(txtAttribute, attr.name or "")
		ClientTextUtils.setText(txtValue, string.isNilOrEmpty(attr.desc) and "" or string.format("+%s", attr.desc))
	end

	function LuaUIUtils.refreshItemInfoTitleTowerBuff(button, itemId)
		local objectReference = button:GetComponent("ObjectReference")
		local buffTagIcon = objectReference:GetRefValue("buffTagIcon")
		local buffTagUWidget = objectReference:GetRefValue("buffTagUWidget")
		local itemLevelUWidget = objectReference:GetRefValue("itemLevelUWidget")
		local lv1UWidget = objectReference:GetRefValue("lv1UWidget")
		local lv2UWidget = objectReference:GetRefValue("lv2UWidget")
		local lv3UWidget = objectReference:GetRefValue("lv3UWidget")
		local RogueUtils = require("Utils.RogueUtils")
		local tagIcon = RogueUtils.getRogueBuffTagIcon(itemId)
		local showTag = string.notNilOrEmpty(tagIcon)

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(buffTagUWidget, showTag)

		if showTag then
			buffTagIcon.url = tagIcon
		end

		local buffQuality = RogueUtils.getBuffQuality(itemId)
		local isEquipBuff = buffQuality == Const.RogueBuffQuality.Equipment

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(itemLevelUWidget, isEquipBuff)

		if not isEquipBuff then
			return
		end

		local buffCount = pg.me.rogueBuffs[itemId] or 0
		local levelItems = {
			lv1UWidget,
			lv2UWidget,
			lv3UWidget
		}

		for i = 1, 3 do
			levelItems[i]:TryChangePage("Check", i <= buffCount and 1 or 0)
		end
	end

	function LuaUIUtils.refreshItemInfoContainer(container, refreshFunc, tracker)
		if IsNil(container) then
			return
		end

		local function renderFunc(content)
			content = content or container.content

			if NotNil(content) then
				refreshFunc(content)
			end
		end

		if container:CheckURLLoaded() then
			renderFunc(container.content)
		elseif tracker then
			addContentReady(tracker)
			container:LoadDefaultUrlManually(function(content)
				renderFunc(content)
				finishOneContentReady(tracker)
			end)
		else
			container:LoadDefaultUrlManually(renderFunc)
		end
	end

	function LuaUIUtils.renderItemInfo(panelPropInfoUContainer, param, oriBtn, enableSubTooltip, cbFunc)
		LuaUIUtils.refreshItemInfoContainer(panelPropInfoUContainer, function(content)
			if param.validate and not param.validate() then
				return
			end

			local objectReference = content:GetComponent("ObjectReference")
			local panelUComponent = objectReference:GetRefValue("panelUComponent")
			local bottomUContainer = objectReference:GetRefValue("bottomUContainer")

			content:TryChangePage("isEmpty", 0)

			if NotNil(bottomUContainer) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(bottomUContainer, false)
			end

			LuaUIUtils.refreshItemInfo(panelUComponent, param, oriBtn, enableSubTooltip, cbFunc)
		end)
	end

	function LuaUIUtils.renderShopItemInfo(panelPropInfoUContainer, param, purchaseData, oriBtn, enableSubTooltip, cbFunc)
		LuaUIUtils.refreshItemInfoContainer(panelPropInfoUContainer, function(content)
			local currentPurchaseData = purchaseData

			if type(purchaseData) == "function" then
				currentPurchaseData = purchaseData()
			end

			if not currentPurchaseData or currentPurchaseData.validate and not currentPurchaseData.validate() then
				return
			end

			local objectReference = content:GetComponent("ObjectReference")
			local panelUComponent = objectReference:GetRefValue("panelUComponent")
			local bottomUContainer = objectReference:GetRefValue("bottomUContainer")

			content:TryChangePage("isEmpty", 0)
			LuaUIUtils.refreshItemInfo(panelUComponent, param, oriBtn, enableSubTooltip, cbFunc)

			if IsNil(bottomUContainer) then
				return
			end

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(bottomUContainer, true)
			LuaUIUtils.refreshItemInfoContainer(bottomUContainer, function(bottomContent)
				local latestPurchaseData = purchaseData

				if type(purchaseData) == "function" then
					latestPurchaseData = purchaseData()
				end

				if not latestPurchaseData or latestPurchaseData.validate and not latestPurchaseData.validate() then
					return
				end

				local ClientCashShopUtils = require("Utils.ClientCashShopUtils")

				ClientCashShopUtils.renderItemInfoPurchase(bottomContent, latestPurchaseData)
			end)
		end)
	end

	function LuaUIUtils.getItemAcquireLimitList(itemId)
		local acquireLimitConfig = ItemAcquireLimitData[itemId]
		local useLimitMap = pg.me and pg.me.useLimitMap

		if acquireLimitConfig == nil or useLimitMap == nil then
			return EMPTY_TABLE
		end

		local result = {}

		for source, config in pairs(acquireLimitConfig) do
			local showCondition = config.showCondition
			local canShow = config.hideInTips ~= 1 and (showCondition == nil or showCondition == 0 or ClientUtils.checkCondition(showCondition))
			local limitConfig = LimitData[config.limitId]
			local timeTextKey = limitConfig and Const.LimitType2TextKeyMap[limitConfig.type]

			if canShow and config.name and timeTextKey then
				table.insert(result, {
					source = source,
					sort = config.sort or source,
					name = config.name,
					timeTextKey = timeTextKey,
					usedCount = useLimitMap:getUsedCount(config.limitId),
					totalCount = useLimitMap:getTotalCount(config.limitId)
				})
			end
		end

		table.sort(result, function(a, b)
			if a.sort ~= b.sort then
				return a.sort < b.sort
			end

			return a.source < b.source
		end)

		return result
	end

	function LuaUIUtils.refreshItemAcquireLimit(content, dataList)
		local objectReference = content:GetComponent("ObjectReference")
		local textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
		local listUList = objectReference:GetRefValue("listUList")

		ClientTextUtils.setText(textTitleUBaseText, pg.getGameString("ITEM_ACQUIRE_LIMIT_TITLE"))

		function listUList.luaRenderItem(button, _, data)
			local itemObjectReference = button:GetComponent("ObjectReference")
			local txtNameUBaseText = itemObjectReference:GetRefValue("txtNameUBaseText")
			local txtTimeUBaseText = itemObjectReference:GetRefValue("txtTimeUBaseText")
			local txtLimitUBaseText = itemObjectReference:GetRefValue("txtLimitUBaseText")

			ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))
			ClientTextUtils.setText(txtTimeUBaseText, pg.getGameString(data.timeTextKey))
			ClientTextUtils.setText(txtLimitUBaseText, string.format("%s/%s", data.usedCount, data.totalCount))

			button.luaClick = nil
		end

		listUList:SetList(dataList)
	end

	function LuaUIUtils.refreshUseCount(button, param, itemId, propData, effectData, bgItem)
		if IsNil(button) then
			return
		end

		if param.genID == nil then
			button:TryChangePage("type", 0)

			return
		end

		itemId = itemId or param.id or param.itemId

		local objectReference = button:GetComponent("ObjectReference")
		local normalReusedTipsText = objectReference:GetRefValue("normalReusedTipsText")
		local normalReusedCountText = objectReference:GetRefValue("normalReusedCountText")
		local weeklyReusedCountText = objectReference:GetRefValue("weeklyReusedCountText")
		local weeklyLimitCountText = objectReference:GetRefValue("weeklyLimitCountText")

		propData = propData or LuaUIUtils.getItemClientInfoById(itemId, param.invId)
		effectData = effectData or ItemEffectData[itemId] or {}

		if not bgItem then
			local slot = ItemUtils.getTypedBag(pg.me, propData.invIdx) or {}

			bgItem = slot.get and slot:get(param.genID) or {}
		end

		local reuseTimes = effectData.reuseTimes or 0
		local usedTimes = bgItem.getUseTimes and bgItem:getUseTimes() or 0
		local remainTimes = math.clamp(reuseTimes - usedTimes, 0, reuseTimes)

		if reuseTimes > 1 then
			button:TryChangePage("type", 1)
			ClientTextUtils.setText(normalReusedTipsText, pg.getGameString("REMAIN_TIMES"))
			ClientTextUtils.setText(normalReusedCountText, pg.getFormatText(pg.getGameString("TIMES"), remainTimes))
		else
			button:TryChangePage("type", 0)
		end

		local limitConfigId = effectData.countLimit

		if limitConfigId == nil then
			return
		end

		button:TryChangePage("type", 2)

		local cycleRemainTimes = pg.me.useLimitMap:getRemainCount(limitConfigId)
		local cycleType = LimitData[limitConfigId].type
		local remainTimesText = pg.getFormatText(pg.getGameString("TIMES"), remainTimes)

		if remainTimes == 0 then
			remainTimesText = pg.getFormatText(pg.getGameString("ZERO_TIMES_COLOR"), remainTimesText)
		end

		local cycleRemainTimesText = pg.getFormatText(pg.getGameString("TIMES"), cycleRemainTimes)

		if cycleRemainTimes == 0 then
			cycleRemainTimesText = pg.getFormatText(pg.getGameString("ZERO_TIMES_COLOR"), cycleRemainTimesText)
		end

		ClientTextUtils.setText(weeklyReusedCountText, ClientTextUtils.concatByLanguage(pg.getGameString("REMAIN_TIMES"), remainTimesText))
		ClientTextUtils.setText(weeklyLimitCountText, ClientTextUtils.concatByLanguage(pg.getFormatText(pg.getGameString("CYCLE_REMAIN_TIMES"), pg.getGameString(Const.LimitType2TextKeyMap[cycleType])), cycleRemainTimesText))
	end

	function LuaUIUtils.refreshItemInfoTitle1(button, itemInfoWidget, param, oriBtn, itemId, countItemId, propData, bagItem, titleTypeText, displayCount, effectData, bgItem)
		local objectReference = button:GetComponent("ObjectReference")
		local propName = objectReference:GetRefValue("propName")
		local propIcon = objectReference:GetRefValue("propIcon")
		local typeName = objectReference:GetRefValue("typeName")
		local useCountUContainer = objectReference:GetRefValue("useCountUComponent")
		local btnDetails = objectReference:GetRefValue("btnDetails")
		local btnLock = objectReference:GetRefValue("btnLock")
		local btnHomePEgUButton = objectReference:GetRefValue("btnHomePEgUButton")
		local cashShopTradableUContainer = objectReference:GetRefValue("cashShopTradableUContainer")
		local itemUContainer = objectReference:GetRefValue("itemUContainer")
		local grabEggsUContainer = objectReference:GetRefValue("grabEggsUContainer")
		local petChipsUContainer = objectReference:GetRefValue("petChipsUContainer")
		local carryUContainer = objectReference:GetRefValue("carryUContainer")
		local towerBuffUContainer = objectReference:GetRefValue("towerBuffUContainer")
		local homeUContainer = objectReference:GetRefValue("homeUContainer")

		itemId = itemId or param.id or param.itemId
		propData = propData or LuaUIUtils.getItemClientInfoById(itemId, param.invId)

		local itemConfig = ItemData[itemId] or {}
		local isCarryItem = itemConfig.type == ItemConst.ITEM_TYPE_CARRY_CORE or itemConfig.type == ItemConst.ITEM_TYPE_CARRY_ASSISTED

		if isCarryItem and not param.carryCoreAttr then
			LuaUIUtils.checkParseCarryInfo(param)
		end

		ClientTextUtils.setText(propName, pg.getLocalizationText(propData.name))

		if pg.game.setting:getShowDebugId() then
			ClientTextUtils.setText(propName, propName.text, "-", tostring(itemId))
		end

		local carryAttr = param.carryCoreAttr

		if carryAttr and carryAttr.type == ItemConst.ITEM_TYPE_CARRY_CORE and carryAttr.lv and carryAttr.lv > 0 then
			ClientTextUtils.setText(propName, pg.getLocalizationText(propData.name), "+", tostring(carryAttr.lv))
		end

		propIcon.url = propData.icon

		ClientTextUtils.setText(typeName, titleTypeText or param.originData and param.originData.typeText or pg.getLocalizationText(propData.typeName))
		typeName:SetActive(not param.showGrabEgg or param.showGrabEggItemType == true)

		local isTowerBuff = RogueBuffMapping[itemId] ~= nil
		local isCarry = not isTowerBuff and isCarryItem
		local isGrabEgg = not isTowerBuff and not isCarry and param.showGrabEgg == true
		local countItemConfig = ItemData[countItemId]
		local isHome = countItemConfig and countItemConfig.isHomeItem == 1
		local isNormal = not isTowerBuff and not isCarry and not isGrabEgg and not isHome

		if NotNil(itemUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(itemUContainer, isNormal)
		end

		if NotNil(grabEggsUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(grabEggsUContainer, isGrabEgg)
		end

		if NotNil(petChipsUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(petChipsUContainer, false)
		end

		if NotNil(carryUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryUContainer, isCarry)
		end

		if NotNil(towerBuffUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(towerBuffUContainer, isTowerBuff)
		end

		if NotNil(homeUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeUContainer, isHome)
		end

		local contentTracker = param.contentTracker

		if isTowerBuff then
			LuaUIUtils.refreshItemInfoContainer(towerBuffUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitleTowerBuff(content, itemId)
			end, contentTracker)
		elseif isCarry then
			LuaUIUtils.refreshItemInfoContainer(carryUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitleCarry(content, param)
			end, contentTracker)
		elseif isGrabEgg then
			LuaUIUtils.refreshItemInfoContainer(grabEggsUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitleGrabEgg(content, param, itemId, ItemData[itemId], bagItem)
			end, contentTracker)
		elseif isHome then
			LuaUIUtils.refreshItemInfoContainer(homeUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitleHome(content, countItemId)
			end, contentTracker)
		else
			LuaUIUtils.refreshItemInfoContainer(itemUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitleNormal(content, param, itemId, propData, displayCount)
			end, contentTracker)
		end

		local tradableItem = param.packSlot or bagItem
		local isTradable = TradeUtils.isItemCanTrade(tradableItem) == true

		if NotNil(cashShopTradableUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(cashShopTradableUContainer, isTradable)

			if isTradable and not cashShopTradableUContainer:CheckURLLoaded() then
				loadContainerWithTracker(cashShopTradableUContainer, contentTracker, nil)
			end
		end

		local showFormulaTracking = param.formulaTracking or false

		if param.showLock and itemConfig.forbidLock ~= 1 then
			local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

			btnLock:SetActive(true)

			showFormulaTracking = false

			button:TryChangePage("Lock", param.isLocked and 1 or 0)

			function btnLock.luaClick()
				if param.btnLockFunc then
					param.btnLockFunc(param, itemInfoWidget)
				else
					PetManagementDataHelper.switchItemTipLockStatus(itemInfoWidget, param)
				end
			end
		else
			btnLock:SetActive(false)

			btnLock.luaClick = nil
		end

		LuaUIUtils.refreshHomeFormulaTrackingButton(btnHomePEgUButton, showFormulaTracking, itemId, propData)

		local inHome = param.inHome ~= nil and param.inHome or false

		btnDetails:SetActive(false)

		if propData.showIPContent and propData.showIPContent > 0 or inHome then
			btnDetails:SetActive(true)

			function btnDetails.luaClick()
				local msg = LuaUIUtils.getSpecialItemInfo(itemId, propData.count)

				msg.openType = 0

				pg.global.ui:open(UIConst.UI_ID_PIECES_ITEM_PANEL, msg)

				if oriBtn then
					oriBtn:ClosePopup()
				end
			end
		end

		if IsNil(useCountUContainer) then
			return
		end

		if useCountUContainer:CheckURLLoaded() then
			LuaUIUtils.refreshUseCount(useCountUContainer.content, param, itemId, propData, effectData, bgItem)
		else
			loadContainerWithTracker(useCountUContainer, contentTracker, function(content)
				LuaUIUtils.refreshUseCount(content, param, itemId, propData, effectData, bgItem)
			end)
		end
	end

	function LuaUIUtils.refreshItemInfoTitle2(button, param, itemId, countItemId, propData, titleTypeText, displayCount, uWidget)
		local objectReference = button:GetComponent("ObjectReference")
		local propName = objectReference:GetRefValue("propName")
		local typeName = objectReference:GetRefValue("typeName")
		local countText = objectReference:GetRefValue("countText")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local subText = objectReference:GetRefValue("subText")

		itemId = itemId or param.id or param.itemId
		propData = propData or LuaUIUtils.getItemClientInfoById(itemId, param.invId)

		ClientTextUtils.setText(propName, pg.getLocalizationText(propData.name))

		if pg.game.setting:getShowDebugId() then
			ClientTextUtils.setText(propName, propName.text, "-", tostring(itemId))
		end

		local carryAttr = param.carryCoreAttr

		if carryAttr and carryAttr.type == ItemConst.ITEM_TYPE_CARRY_CORE and carryAttr.lv and carryAttr.lv > 0 then
			ClientTextUtils.setText(propName, pg.getLocalizationText(propData.name), "+", tostring(carryAttr.lv))
		end

		ClientTextUtils.setText(typeName, titleTypeText or param.originData and param.originData.typeText or pg.getLocalizationText(propData.typeName))
		typeName:SetActive(not param.showGrabEgg or param.showGrabEggItemType == true)

		local showNumber = not param.originData or not param.originData.hideCount
		local itemConfig = ItemData[itemId]
		local itemEffectConfig = ItemEffectData[itemId]

		if itemConfig and itemConfig.hideOwnCount == 1 or itemEffectConfig and itemEffectConfig.autoUse == 1 then
			showNumber = false
		end

		if showNumber then
			ClientTextUtils.setText(textUBaseText, pg.getGameString("ROGUE_BUFF_OWN"))
			ClientTextUtils.setText(countText, " " .. (displayCount or propData.count))
		end

		local countItemConfig = ItemData[countItemId]
		local isHome = countItemConfig and countItemConfig.isHomeItem == 1

		if uWidget then
			local titleType = showNumber and (isHome and 1 or 0) or 2

			uWidget:TryChangePage("TitleType", titleType)
		end

		if isHome then
			ClientTextUtils.setText(textUBaseText, pg.getGameString("BAG"))

			local bagCount = ClientUtils.getItemCountById(countItemId, true)

			ClientTextUtils.setText(countText, " " .. tostring(bagCount))

			local homeTitle = pg.getGameString("FILTER_HOMELAND") .. " "

			if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
				local homeCount = ClientUtils.getHomelandItemCountById(countItemId)

				ClientTextUtils.setText(subText, homeTitle .. tostring(homeCount))
			else
				ClientTextUtils.setText(subText, homeTitle .. "--")
			end
		end
	end

	function LuaUIUtils.refreshItemInfoBottom(button, itemInfoWidget, param, itemCount, isInHomeOrCamp)
		local objectReference = button:GetComponent("ObjectReference")
		local btnListUList = objectReference:GetRefValue("btnListUList")
		local btnBoxNewUButton = objectReference:GetRefValue("btnBoxNewUButton")
		local unOpenUContainer = objectReference:GetRefValue("unOpenUContainer")
		local numSelector = objectReference:GetRefValue("numSelector")

		param.itemId = param.id or param.itemId
		itemCount = itemCount or param.itemCount or ClientUtils.getItemCountById(param.itemId, true)

		if isInHomeOrCamp == nil then
			isInHomeOrCamp = HomeLandUtils.isInHomeOrCamp()
		end

		local showNumSelector = param.showNumSelector or param.inHome ~= nil and param.inHome or false
		local showConfirmBtn = param.showConfirmBtn or showNumSelector
		local maxCount = param.maxNum or itemCount

		if NotNil(numSelector) then
			numSelector.gameObject:SetActiveEx(showNumSelector)

			if showNumSelector then
				local rootComponent

				if NotNil(itemInfoWidget) then
					local itemInfoObjectReference = itemInfoWidget:GetComponent("ObjectReference")

					rootComponent = itemInfoObjectReference:GetRefValue("rootComponent")
				end

				if NotNil(rootComponent) then
					local homeTimer = TimerManager.addTimer(0.06, function()
						numSelector:SetAllValue(1, 1, maxCount, 1)
					end)

					function rootComponent.luaCloseAction()
						TimerManager.removeTimer(homeTimer)
						pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

						if param.cancelClick ~= nil then
							local itemInfo = {}

							itemInfo[param.itemId or param.id] = numSelector.value

							param.cancelClick(itemInfo)
						end
					end
				else
					numSelector:SetAllValue(1, 1, maxCount, 1)
				end
			end
		end

		LuaUIUtils.refreshItemOperateButtons(param, showNumSelector, showConfirmBtn, btnBoxNewUButton, btnListUList, numSelector)

		local panelTransform = NotNil(itemInfoWidget) and itemInfoWidget.transform:Find("Panel") or nil
		local ttlRenderToken = {}

		if NotNil(panelTransform) then
			itemInfoTTLRenderTokens[panelTransform] = ttlRenderToken
		end

		local function isCurrentTTLRender()
			return NotNil(panelTransform) and itemInfoTTLRenderTokens[panelTransform] == ttlRenderToken and (not param.validate or param.validate())
		end

		local legacyTTLStatusTransform = NotNil(panelTransform) and panelTransform:Find("TTLStatusLegacy") or nil

		if NotNil(legacyTTLStatusTransform) then
			legacyTTLStatusTransform.gameObject:SetActiveEx(false)
		end

		if IsNil(unOpenUContainer) then
			return
		end

		local ttlStatusTransform, ttlStatusRectTransform, ttlStatusUWidget, ttlStatusUText, ttlStatusTMPText, ttlStatusBgImage

		if NotNil(panelTransform) then
			for i = 0, panelTransform.childCount - 1 do
				local child = panelTransform:GetChild(i)
				local childText = child:Find("Text")

				if child.name == "UnOpen" and IsNil(child:GetComponent("UContainer")) and NotNil(childText) then
					ttlStatusTransform = child
					ttlStatusRectTransform = child:GetComponent("RectTransform")
					ttlStatusUWidget = child:GetComponent("UWidget")
					ttlStatusUText = childText:GetComponent("USDFText")
					ttlStatusTMPText = childText:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))

					local bgTransform = child:Find("ImgBgUnOpen")

					ttlStatusBgImage = NotNil(bgTransform) and bgTransform:GetComponent("UImage") or nil

					break
				end
			end
		end

		if NotNil(ttlStatusTransform) then
			ttlStatusTransform.gameObject:SetActiveEx(false)
		end

		if param.ttlStatusText and NotNil(ttlStatusTransform) and ttlStatusUText then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(unOpenUContainer, false)

			if NotNil(ttlStatusTMPText) then
				ttlStatusTMPText.richText = true
			end

			if ttlStatusUWidget then
				ttlStatusUWidget.ignoreLayout = true
			end

			ClientTextUtils.setText(ttlStatusUText, param.ttlStatusText)

			if NotNil(ttlStatusRectTransform) then
				local anchorMin = ttlStatusRectTransform.anchorMin
				local anchorMax = ttlStatusRectTransform.anchorMax

				ttlStatusRectTransform.anchorMin = CS.UnityEngine.Vector2(anchorMin.x, 0)
				ttlStatusRectTransform.anchorMax = CS.UnityEngine.Vector2(anchorMax.x, 0)

				local anchoredPosition = ttlStatusRectTransform.anchoredPosition

				ttlStatusRectTransform.anchoredPosition = CS.UnityEngine.Vector2(anchoredPosition.x, ttlStatusRectTransform.rect.height * ttlStatusRectTransform.pivot.y)
			end

			ttlStatusTransform.gameObject:SetActiveEx(true)

			if NotNil(ttlStatusBgImage) then
				local function refreshTTLStatusStyle()
					if not isCurrentTTLRender() then
						return
					end

					local content = unOpenUContainer.content

					if IsNil(content) then
						return
					end

					content:TryChangePage("Type", 0, true)

					if param.ttlState == ItemTTLUtils.STATE_EXPIRED then
						content:TryChangePage("Type", 1, true)
					end

					local templateBgTransform = content.transform:Find("ImgBgUnOpen")
					local templateBgImage = NotNil(templateBgTransform) and templateBgTransform:GetComponent("UImage") or nil

					if NotNil(templateBgImage) then
						ttlStatusBgImage.color = templateBgImage.color
					end
				end

				if unOpenUContainer:CheckURLLoaded() then
					refreshTTLStatusStyle()
				else
					loadContainerWithTracker(unOpenUContainer, param.contentTracker, refreshTTLStatusStyle)
				end
			end
		elseif param.ttlStatusText and NotNil(panelTransform) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(unOpenUContainer, true)

			local function refreshTTLStatusContainer(content)
				content = content or unOpenUContainer.content

				if not isCurrentTTLRender() or IsNil(content) then
					return
				end

				local statusTransform = panelTransform:Find("TTLStatusLegacy")
				local statusGameObject

				if IsNil(statusTransform) then
					statusGameObject = CS.UnityEngine.Object.Instantiate(content.gameObject, panelTransform, false)
					statusGameObject.name = "TTLStatusLegacy"
					statusTransform = statusGameObject.transform
				else
					statusGameObject = statusTransform.gameObject
				end

				local statusContent = statusGameObject:GetComponent(content:GetType())

				if IsNil(statusContent) then
					return
				end

				local statusRect = statusTransform:GetComponent("RectTransform")

				if NotNil(statusRect) then
					statusRect.anchorMin = CS.UnityEngine.Vector2(0, 0)
					statusRect.anchorMax = CS.UnityEngine.Vector2(1, 0)
					statusRect.pivot = CS.UnityEngine.Vector2(0.5, 0)
					statusRect.sizeDelta = CS.UnityEngine.Vector2(0, 48)
					statusRect.anchoredPosition = CS.UnityEngine.Vector2(0, 0)
				end

				local statusWidget = statusGameObject:GetComponent("UWidget")

				if NotNil(statusWidget) then
					statusWidget.ignoreLayout = true
				end

				statusContent:TryChangePage("Type", param.ttlState == ItemTTLUtils.STATE_EXPIRED and 1 or 0, true)

				local contentObjectReference = statusGameObject:GetComponent("ObjectReference")
				local statusText = contentObjectReference and contentObjectReference:GetRefValue("txtOpenUSDFText") or nil

				if statusText then
					local statusTMPText = statusText:GetComponent(typeof(CS.TMPro.TextMeshProUGUI))

					if NotNil(statusTMPText) then
						statusTMPText.richText = true
					end

					ClientTextUtils.setText(statusText, param.ttlStatusText)
				end

				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(unOpenUContainer, false)
				statusGameObject:SetActiveEx(true)
			end

			if unOpenUContainer:CheckURLLoaded() then
				refreshTTLStatusContainer()
			else
				loadContainerWithTracker(unOpenUContainer, param.contentTracker, refreshTTLStatusContainer)
			end
		elseif isInHomeOrCamp then
			LuaUIUtils.refreshUnOpenUContainer(param, unOpenUContainer)
		else
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(unOpenUContainer, false)
		end
	end

	function LuaUIUtils.refreshItemInfo(uWidget, param, oriBtn, enableSubTooltip, cbFunc)
		local oc = uWidget:GetComponent("ObjectReference")
		local rootComponent = oc:GetRefValue("rootComponent")
		local titleUContainer = oc:GetRefValue("titleUContainer")
		local title2UContainer = oc:GetRefValue("title2UContainer")
		local scrollInfo = oc:GetRefValue("scrollInfo")
		local bottomUContainer = oc:GetRefValue("bottomUContainer")
		local scrollOc = scrollInfo.content:GetComponent("ObjectReference")
		local desc = scrollOc:GetRefValue("desc")
		local itemDesc = scrollOc:GetRefValue("itemDesc")
		local maskVideo = scrollOc:GetRefValue("maskVideo")
		local videoPlayer = scrollOc:GetRefValue("videoPlayer")
		local rewardViewUWidget = scrollOc:GetRefValue("rewardViewUWidget")
		local listUList = scrollOc:GetRefValue("listUList")
		local txtRewardTitleUSDFText = scrollOc:GetRefValue("txtRewardTitleUSDFText")
		local expiredExchangeUContainer = scrollOc:GetRefValue("expiredExchangeUContainer")
		local carryUContainer = scrollOc:GetRefValue("carryUContainer")
		local grabEggUContainer = scrollOc:GetRefValue("grabEggUContainer")
		local homeUContainer = scrollOc:GetRefValue("homeUContainer")
		local timeLimitUContainer = scrollOc:GetRefValue("timeLimitUContainer")
		local contentTracker = param.onContentReady and createContentReadyTracker(param.onContentReady) or nil

		param.contentTracker = contentTracker

		local uiStyle = param.uiStyle or UIConst.ITEM_INFO_STATE.PROP

		rootComponent:TryChangePage("UIStyle", uiStyle)

		if NotNil(titleUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(titleUContainer, uiStyle ~= UIConst.ITEM_INFO_STATE.SHOP)
		end

		if NotNil(title2UContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(title2UContainer, uiStyle == UIConst.ITEM_INFO_STATE.SHOP)
		end

		scrollInfo:SetDenyNavScroll(true)

		desc.enabledHyperlink = true
		desc.luaOnHyperlinkClick = LuaUIUtils.clickHyperText

		scrollInfo:GoToPos(Vector2.zero, false)

		local itemId = param.id or param.itemId

		param.seasonCollectionTipText = LuaUIUtils.getHomeSeasonCollectionTipText(itemId)

		local bagItem = param.invId and param.genID and ItemUtils.getItem(pg.me, param.invId, param.genID) or nil

		if not bagItem and param.oriData then
			local oriItem = param.oriData.packSlot or param.oriData
			local oriItemId = oriItem and (oriItem.id or oriItem.itemId)

			if oriItemId == itemId and oriItem.props then
				bagItem = oriItem
			end
		end

		local countItemId = param.countItemId or itemId
		local itemCount = 0

		if param.fromParamCount then
			itemCount = param.itemCount
		else
			itemCount = ClientUtils.getItemCountById(countItemId, true)

			if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
				itemCount = itemCount + ClientUtils.getHomelandItemCountById(countItemId)
			end
		end

		local genID = param.genID

		if not param.originData then
			param.originData = {}
		end

		local itemCfg = ItemData[itemId]
		local propData = LuaUIUtils.getItemClientInfoById(itemId, param.invId, bagItem or param.oriData)
		local funcRepText = pg.getLocalizationText(propData.funcRep)

		if param.seasonCollectionTipText then
			if string.isNilOrEmpty(funcRepText) then
				funcRepText = param.seasonCollectionTipText
			else
				funcRepText = table.concat({
					funcRepText,
					param.seasonCollectionTipText
				}, "\n")
			end
		end

		if Utils.isSealedPetEgg(itemId) then
			local shinyText, formName, petName = LuaUIUtils.getSealedEggDescArgs(itemId)

			funcRepText = pg.getFormatText(funcRepText, shinyText, formName, petName)
		end

		LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(desc, not string.isNilOrEmpty(funcRepText))

		if desc.gameObject.name == "PropFunction" and type(funcRepText) == "string" and string.find(funcRepText, "<style=", 1, true) then
			desc.text = ""
		end

		ClientTextUtils.setText(desc, funcRepText)

		local itemText = pg.getLocalizationText(propData.itemDesc)

		itemDesc.gameObject:SetActiveEx(not string.isNilOrEmpty(itemText))

		if not string.isNilOrEmpty(itemText) then
			ClientTextUtils.setText(itemDesc, itemText)
		end

		rootComponent:TryChangePage("Quality", propData.quality)

		if not string.isNilOrEmpty(propData.video) then
			maskVideo:SetActive(true)

			videoPlayer.resID = propData.video
		else
			maskVideo:SetActive(false)
		end

		local needShowReward = param.needShowReward

		if needShowReward == nil then
			needShowReward = true
		end

		local needShowBtnSelfTip = param.needShowBtnSelfTip

		if needShowBtnSelfTip == nil then
			needShowBtnSelfTip = true
		end

		if listUList then
			local isShow = false
			local rewardViewItemList = param.rewardViewItemList

			if rewardViewItemList ~= nil then
				isShow = true

				if param.rewardViewText then
					ClientTextUtils.setText(txtRewardTitleUSDFText, param.rewardViewText)
				end

				function listUList.luaRenderItem(button, _, data)
					button:TryChangePage("ItemType", 0)

					local ownNum = data.ownNum

					if ownNum == nil then
						ownNum = ClientUtils.getItemCountById(data.id, true)
					end

					local numText = LuaUIUtils.renderConsumeText(nil, ownNum, data.num, UIConst.ITEM_STATE.FULL)

					LuaUIUtils.renderRewardItem(button, data, numText, needShowBtnSelfTip, enableSubTooltip)

					button.luaClick = nil
				end

				listUList:SetList(rewardViewItemList)
			elseif needShowReward and itemCfg and itemCfg.rewardShow then
				LuaUIUtils.setRewardListInCommonTip(listUList, itemCfg.rewardShow, needShowBtnSelfTip, enableSubTooltip)

				isShow = true
			end

			if NotNil(rewardViewUWidget) then
				LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(rewardViewUWidget, isShow)
			end
		end

		if timeLimitUContainer then
			local acquireLimitList = LuaUIUtils.getItemAcquireLimitList(itemId)
			local showAcquireLimit = #acquireLimitList > 0

			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(timeLimitUContainer, showAcquireLimit)

			if showAcquireLimit then
				LuaUIUtils.refreshItemInfoContainer(timeLimitUContainer, function(content)
					LuaUIUtils.refreshItemAcquireLimit(content, acquireLimitList)
				end, contentTracker)
			end
		end

		local itemType = itemCfg and itemCfg.type
		local carryPage = itemType == ItemConst.ITEM_TYPE_CARRY_CORE and 1 or itemType == ItemConst.ITEM_TYPE_CARRY_ASSISTED and 2 or 0

		if NotNil(carryUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(carryUContainer, carryPage > 0)
		end

		if carryPage > 0 then
			LuaUIUtils.refreshItemInfoContainer(carryUContainer, function(content)
				LuaUIUtils.refreshCarryItemInfo(content, param)
			end, contentTracker)
		end

		uWidget:TryChangePage("isCarry", carryPage)

		local grabEggPage = param.showGrabEgg and 2 or 0

		if NotNil(grabEggUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(grabEggUContainer, grabEggPage == 2)
		end

		if grabEggPage == 2 then
			LuaUIUtils.refreshItemInfoContainer(grabEggUContainer, function(content)
				LuaUIUtils.refreshGrabEggItemInfo(content, param, itemId, itemCfg)
			end, contentTracker)
		end

		uWidget:TryChangePage("ItemType", grabEggPage)

		local isRogueBuff, rogueQuality, rogueTypeText, rogueCount = LuaUIUtils.refreshRogueBuffItemInfo(param, itemId, desc)

		if isRogueBuff then
			uWidget:TryChangePage("ItemType", 1)

			if rogueQuality then
				rootComponent:TryChangePage("Quality", rogueQuality)
			end
		end

		local isNumShowed = LuaUIUtils.refreshPetEggTagInfo(itemId, scrollOc)
		local effectData = ItemEffectData[itemId] or {}
		local bgItem = {}
		local displayCount = isRogueBuff and rogueCount or itemCount or propData.count

		if genID ~= nil then
			local slot = ItemUtils.getTypedBag(pg.me, propData.invIdx) or {}

			bgItem = slot.get and slot:get(genID) or {}

			if not isNumShowed then
				displayCount = bgItem.count or 0

				if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
					displayCount = displayCount + ClientUtils.getHomelandItemCountById(itemId)
				end
			end
		end

		local titleTypeText = rogueTypeText or param.originData.typeText or pg.getLocalizationText(propData.typeName)

		if uiStyle == UIConst.ITEM_INFO_STATE.SHOP then
			LuaUIUtils.refreshItemInfoContainer(title2UContainer, function(content)
				if param.validate and not param.validate() then
					return
				end

				LuaUIUtils.refreshItemInfoTitle2(content, param, itemId, countItemId, propData, titleTypeText, displayCount, uWidget)
			end, contentTracker)
		else
			LuaUIUtils.refreshItemInfoContainer(titleUContainer, function(content)
				LuaUIUtils.refreshItemInfoTitle1(content, uWidget, param, oriBtn, itemId, countItemId, propData, bagItem, titleTypeText, displayCount, effectData, bgItem)
			end, contentTracker)
		end

		local inheritSellPrice = param.inheritSellPrice

		if inheritSellPrice == nil then
			inheritSellPrice = param.price ~= nil
		end

		local isInHomeOrCamp = HomeLandUtils.isInHomeOrCamp()
		local countItemConfig = ItemData[countItemId]
		local showHomeInfo = isInHomeOrCamp or inheritSellPrice or countItemConfig and countItemConfig.isHomeItem == 1

		if NotNil(homeUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(homeUContainer, showHomeInfo)
		end

		if showHomeInfo then
			LuaUIUtils.refreshItemInfoContainer(homeUContainer, function(content)
				if param.validate and not param.validate() then
					return
				end

				LuaUIUtils.refreshHomeItemInfo(content, itemId, countItemId, param, inheritSellPrice)
			end, contentTracker)
		end

		rootComponent:TryChangePage("Unopen", param.ttlStatusText and 1 or 0)
		LuaUIUtils.refreshItemInfoContainer(bottomUContainer, function(content)
			if param.validate and not param.validate() then
				return
			end

			LuaUIUtils.refreshItemInfoBottom(content, uWidget, param, itemCount, isInHomeOrCamp)
		end, contentTracker)

		local showExpiredExchange = param.expiredExchangeFunc ~= nil

		if NotNil(expiredExchangeUContainer) then
			LuaUIUtils.setUIViewActiveAndMarkIgnoreLayout(expiredExchangeUContainer, showExpiredExchange)

			local function refreshExpiredExchange()
				if IsNil(expiredExchangeUContainer.content) then
					return
				end

				local expiredExchangeButtonTransform = expiredExchangeUContainer.content.transform:Find("BtnExpiredExchange")
				local expiredExchangeUButton = NotNil(expiredExchangeButtonTransform) and expiredExchangeButtonTransform:GetComponent("UButton") or nil

				if NotNil(expiredExchangeUButton) then
					ClientTextUtils.setText(expiredExchangeUButton.title, pg.getGameString("EXPIRED_EXCHANGE_CONVERT"))

					expiredExchangeUButton.enabledTooltip = false
					expiredExchangeUButton.luaClick = param.expiredExchangeFunc
				end
			end

			if showExpiredExchange then
				if expiredExchangeUContainer:CheckURLLoaded() then
					refreshExpiredExchange()
				elseif contentTracker then
					addContentReady(contentTracker)
					expiredExchangeUContainer:LoadDefaultUrlManually(function()
						refreshExpiredExchange()
						finishOneContentReady(contentTracker)
					end)
				else
					expiredExchangeUContainer:LoadDefaultUrlManually(refreshExpiredExchange)
				end
			elseif expiredExchangeUContainer:CheckURLLoaded() then
				refreshExpiredExchange()
			end
		end

		local sourcePropData = propData

		if param.sourceItemId then
			sourcePropData = LuaUIUtils.getItemClientInfoById(param.sourceItemId)
		end

		LuaUIUtils.refreshItemSourceInfo(param, scrollOc, cbFunc, sourcePropData)

		if contentTracker then
			sealContentReady(contentTracker)
		end
	end

	function LuaUIUtils.refreshCoreCarryCertifyInfo(objectReference, coreCarryInfo, rootWidget)
		local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

		if not objectReference or not PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
			return
		end

		local PetManagementUtils = require("Utils.PetManagementUtils")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local txtContactUSDFText = objectReference:GetRefValue("txtContactUSDFText")
		local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
		local petSkill1UWidget = objectReference:GetRefValue("petSkill1UWidget")
		local petSkill2UWidget = objectReference:GetRefValue("petSkill2UWidget")
		local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
		local ownerPetId = coreCarryInfo.ownerPetId
		local equipPetInfo = ownerPetId and ownerPetId ~= "" and pg.me.pets and pg.me.pets[ownerPetId] or nil
		local activationState = PetManagementDataHelper.getCoreCarryCertifyActivationState(coreCarryInfo, equipPetInfo)
		local isActive = activationState == PetManagementDataHelper.CoreCarryCertifyActivationState.Active
		local certifiedPetInfo = PetManagementDataHelper.getCoreCarryCertifiedPetInfo(coreCarryInfo, equipPetInfo)
		local certifiedPetName = LuaUIUtils.getPetNameWithIdOrTmpId(coreCarryInfo.certifiedBaseFormPet)
		local beforeSkillInfo, afterSkillInfo = PetManagementDataHelper.getCoreCarryCertifySkillPair(coreCarryInfo)
		local beforeSkillRenderInfo = beforeSkillInfo and Utils.deepCopyTable(beforeSkillInfo) or nil
		local afterSkillRenderInfo = afterSkillInfo and Utils.deepCopyTable(afterSkillInfo) or nil

		if beforeSkillRenderInfo then
			beforeSkillRenderInfo.hasGlazePath = true
			beforeSkillRenderInfo.alreadyGlazed = false
		end

		if afterSkillRenderInfo then
			afterSkillRenderInfo.hasGlazePath = true
			afterSkillRenderInfo.alreadyGlazed = true
		end

		local certifiedPetSkillName = beforeSkillInfo and pg.getLocalizationText(beforeSkillInfo.name) or ""

		if iconUImage then
			iconUImage.url = LuaUIUtils.getPetIconByTemplateId(coreCarryInfo.certifiedBaseFormPet, LuaUIUtils.PET_ICON)
			iconUImage.grayed = not isActive
		end

		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("CARRY_CERT_TITLE"))
		ClientTextUtils.setText(txtContactUSDFText, pg.getGameString(isActive and "CARRY_CERT_ON" or "CARRY_CERT_OFF"))
		ClientTextUtils.setText(txtDetailsUSDFText, string.format(pg.getGameString("CARRY_CERT_TIPS_ENHANCED"), certifiedPetName, certifiedPetSkillName))

		local petSkill1UButton = petSkill1UWidget and petSkill1UWidget:GetComponent("UButton") or nil
		local petSkill2UButton = petSkill2UWidget and petSkill2UWidget:GetComponent("UButton") or nil

		if petSkill1UButton then
			PetManagementUtils._renderSkillCmp(petSkill1UButton, beforeSkillRenderInfo, false, nil, certifiedPetInfo)

			if beforeSkillRenderInfo then
				petSkill1UButton:TryChangePage("IsRare", LuaUIUtils.getSkillGlazeType(beforeSkillRenderInfo))
			end
		end

		if petSkill2UButton then
			PetManagementUtils._renderSkillCmp(petSkill2UButton, afterSkillRenderInfo, false, nil, certifiedPetInfo)

			if afterSkillRenderInfo then
				petSkill2UButton:TryChangePage("IsRare", LuaUIUtils.getSkillGlazeType(afterSkillRenderInfo))
			end
		end

		if rootWidget then
			rootWidget:TryChangePage("Active", 1)
		end

		if btnInfoUButton then
			function btnInfoUButton.luaClick()
				pg.global.ui:open(UIConst.UI_ID_HELP, {
					helpId = PetManagementDataHelper.PetCoreCarryContactHelpId
				})
			end
		end

		return isActive
	end

	function LuaUIUtils.refreshCarryAssistInfo(carryAssistList, carryAdvancedList, data, isCheckData)
		if not isCheckData then
			LuaUIUtils.checkParseCarryInfo(data)
		end

		if carryAssistList then
			local hasAsst = data.assistCarryPosList and next(data.assistCarryPosList)

			carryAssistList:SetActive(hasAsst)

			if hasAsst then
				function carryAssistList.luaRenderItem(assist, index, assistData)
					local objRefAsst = assist:GetComponent("ObjectReference")
					local lockText = objRefAsst:GetRefValue("lockText")
					local jewelUImage = objRefAsst:GetRefValue("jewelUImage")
					local lIndex = index + 1

					if lockText and data.slotUnlockLv and data.slotUnlockLv[lIndex] then
						ClientTextUtils.setText(lockText, string.format("+%d", data.slotUnlockLv[lIndex]))
					end

					local state
					local quality = 0

					if assistData[1] and assistData[2] and assistData[1] ~= 0 and assistData[2] ~= 0 then
						local asstData = pg.global.ui.petTrainingNew.model:parseCarryAssistCfgWithId(assistData[1], assistData[2])

						quality = asstData.quality

						if jewelUImage then
							jewelUImage.url = asstData.icon
						end

						state = jewelUImage and 2 or 1
					else
						state = data.assistUnlock[lIndex] and data.assistUnlock[lIndex] == 0 and 0 or 1
					end

					assist:TryChangePage("Quality", quality)
					assist:TryChangePage("State", state)
					assist:TryChangePage("Type", data.assistCarryTypeList[lIndex] - 1)
				end

				carryAssistList:SetList(data.assistCarryPosList)
			end
		end

		local hasAdvancedData = false

		if carryAdvancedList then
			local itemConfig = ItemData[data.itemId]
			local isCoreCarry = data.carryCoreAttr and data.carryCoreAttr.type == ItemConst.ITEM_TYPE_CARRY_CORE or itemConfig and itemConfig.type == ItemConst.ITEM_TYPE_CARRY_CORE
			local certifyCoreCarryInfo = data
			local contactState
			local isCertifyUnlocked = false
			local isCertified = false
			local PetManagementDataHelper

			if isCoreCarry then
				PetManagementDataHelper = require("Utils.PetManagementDataHelper")

				local sourceItem = data.sourceItem or data.packSlot
				local sourceCoreCarryInfo = sourceItem and ItemUtils.getPropertyWithType(sourceItem) or nil

				if sourceCoreCarryInfo and sourceCoreCarryInfo:isValid() and not PetManagementDataHelper.isCoreCarryCertified(certifyCoreCarryInfo) then
					certifyCoreCarryInfo = sourceCoreCarryInfo
				end

				contactState = PetManagementDataHelper.getCoreCarryCertifyDisplayState(certifyCoreCarryInfo)
				isCertifyUnlocked = contactState ~= PetManagementDataHelper.CoreCarryContactState.Unlocked
				isCertified = PetManagementDataHelper.isCoreCarryCertified(certifyCoreCarryInfo)
			end

			local advancedDataList = {}

			for _, energyEffect in ipairs(data.energyEffects or {}) do
				advancedDataList[#advancedDataList + 1] = {
					tIndex = 0,
					energyEffect = energyEffect
				}
			end

			if isCertifyUnlocked then
				advancedDataList[#advancedDataList + 1] = {
					tIndex = 1
				}
			end

			hasAdvancedData = #advancedDataList > 0

			carryAdvancedList:SetActive(hasAdvancedData)

			if hasAdvancedData then
				function carryAdvancedList.luaRenderItem(advancedItem, aIndex, advancedData)
					if advancedData.tIndex == 1 then
						local objectReference = advancedItem:GetComponent("ObjectReference")

						LuaUIUtils.refreshCoreCarryCertifyInfo(objectReference, certifyCoreCarryInfo, advancedItem)
						advancedItem:TryChangePage("Active", isCertified and 1 or 0)

						local isCertifyAvailable = contactState == PetManagementDataHelper.CoreCarryContactState.NotContact
						local txtNotActiveUSDFText = objectReference:GetRefValue("txtNotActiveUSDFText")

						if txtNotActiveUSDFText then
							txtNotActiveUSDFText.gameObject:SetActiveEx(isCertifyAvailable)

							if isCertifyAvailable then
								ClientTextUtils.setText(txtNotActiveUSDFText, pg.getGameString("CARRY_CERT_TIPS_UNENHANCE"))
							end
						end

						local notActiveTxtDetailsUSDFText = objectReference:GetRefValue("NotActiveTxtDetailsUSDFText")

						if notActiveTxtDetailsUSDFText then
							notActiveTxtDetailsUSDFText.gameObject:SetActiveEx(isCertifyAvailable)

							if isCertifyAvailable then
								ClientTextUtils.setText(notActiveTxtDetailsUSDFText, pg.getGameString("CARRY_CERT_SKILL_TIP"))
							end
						end

						return
					end

					local objectReference = advancedItem:GetComponent("ObjectReference")
					local txtGrade = objectReference:GetRefValue("txtGrade")
					local txtDetails = objectReference:GetRefValue("txtDetails")
					local energyEffect = advancedData.energyEffect
					local allEnergy = data.cLevel or 0
					local showIndex = aIndex + 1
					local showEnergy = allEnergy >= energyEffect.enhanceLv and energyEffect.enhanceLv or allEnergy
					local tex = string.format(pg.getGameString("PET_EQUIPMENT_STAGE"), showIndex, showEnergy, energyEffect.enhanceLv)

					ClientTextUtils.setText(txtGrade, tex)
					ClientTextUtils.setText(txtDetails, energyEffect.effDesc)
					advancedItem:TryChangePage("Active", allEnergy >= energyEffect.enhanceLv and 1 or 0)
				end

				carryAdvancedList:SetList(advancedDataList)
			end
		end

		return hasAdvancedData
	end

	function LuaUIUtils.refreshCarryAssistInfo_Item(objRef, data, isCheckData)
		if IsNil(objRef) then
			return
		end

		local carryItemTransform = objRef.transform:Find("PanelCardRoot/PanelCard/Addon/CarryItem")
		local isCarryCore = data.type == ItemConst.ITEM_TYPE_CARRY_CORE

		if isCarryCore then
			local isCarryItem = isCarryCore or data.type == ItemConst.ITEM_TYPE_CARRY_ASSISTED

			carryItemTransform.gameObject:SetActiveEx(isCarryItem)

			if isCarryItem then
				local equip = carryItemTransform and carryItemTransform:Find("LayoutBox/Equip")
				local equipPetIconTs = equip and equip:Find("Mask/Icon")
				local equipPetIconUImage = equipPetIconTs and equipPetIconTs:GetComponent("UImage")
				local carryInfo = isCarryCore and data.packSlot and ItemUtils.getPropertyWithType(data.packSlot) or data
				local contactTransform = carryItemTransform and carryItemTransform:Find("Contact")

				LuaUIUtils.generalRefreshCarryCertifyComp(contactTransform, carryInfo.certifiedBaseFormPet)

				local ownerPetId = carryInfo.ownerPetId
				local equipPetInfo = ownerPetId and ownerPetId ~= "" and pg.me and pg.me:getPetInfo(ownerPetId) or nil
				local equipPetIconUrl = equipPetInfo and LuaUIUtils.getPetIconByTemplateId(equipPetInfo.templateId, LuaUIUtils.PET_ICON, equipPetInfo.label) or ""

				equip.gameObject:SetActiveEx(equipPetIconUrl ~= "")

				equipPetIconUImage.url = equipPetIconUrl
			end
		else
			carryItemTransform.gameObject:SetActiveEx(false)
		end

		if data.type ~= ItemConst.ITEM_TYPE_CARRY_CORE and data.type ~= ItemConst.ITEM_TYPE_CARRY_ASSISTED then
			return
		end

		if not isCheckData then
			LuaUIUtils.checkParseCarryInfo(data)
		end

		local txtNameUText = objRef:GetRefValue("txtNameUText")

		if isCarryCore then
			ClientTextUtils.setText(txtNameUText, string.format("+%d", data.carryCoreAttr.lv))
		else
			ClientTextUtils.setText(txtNameUText, string.format("CP %d", data.cpValue))
		end
	end

	function LuaUIUtils.refreshCarryAssistAttrList(attrList, mainProperties)
		if IsNil(attrList) then
			return
		end

		if not mainProperties or not next(mainProperties) then
			attrList.gameObject:SetActiveEx(false)

			return
		end

		function attrList.luaRenderItem(sBtn, _, sData)
			LuaUIUtils.renderCarryAssistAttrItem(sBtn, sData)
		end

		attrList:SetList(mainProperties)
		attrList.gameObject:SetActiveEx(true)
	end

	function LuaUIUtils.renderCarryAssistAttrItem(sBtn, sData)
		local oc = sBtn:GetComponent("ObjectReference")
		local attributeName = oc:GetRefValue("attributeName")

		attributeName = attributeName or oc:GetRefValue("txtName")

		local attributeValue = oc:GetRefValue("attributeValue")

		attributeValue = attributeValue or oc:GetRefValue("txtNumNow")

		local iconTypeUImage = oc:GetRefValue("iconTypeUImage")
		local progressUProgress = oc:GetRefValue("progressUProgress")

		ClientTextUtils.setText(attributeName, sData.name)
		ClientTextUtils.setText(attributeValue, string.format("+%s", sData.tDesc))

		if iconTypeUImage then
			iconTypeUImage.url = sData.icon
		end

		if progressUProgress then
			progressUProgress.value = sData.pro

			if sBtn.TryChangePage then
				sBtn:TryChangePage("Quality", sData.isRare and 6 or 0)
				sBtn:TryChangePage("Max", sData.isMax and not sData.isRare and 1 or 0)
			end

			if oc.TryChangePage then
				oc:TryChangePage("Quality", sData.isRare and 6 or 0)
				oc:TryChangePage("Max", sData.isMax and not sData.isRare and 1 or 0)
			end
		end
	end

	function LuaUIUtils.popupPropTip(args)
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui.commonItemTip:closePopUpForm()
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, args)
		end
	end

	function LuaUIUtils.itemSourceTrigger(button, data, isDirectGotoSource, sourceId, cbFunc)
		button:TryChangePage("Info", data.type == LuaUIUtils.ITEM_SOURCE_TYPE_NONINTERACTIVE and 1 or 0)

		if data.type == LuaUIUtils.ITEM_SOURCE_TYPE_TIPS then
			button.enabledTooltip = false
			button.tooltipId = data.tips
		elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS then
			button.enabledTooltip = false
		else
			button.enabledTooltip = false
		end

		function button.luaClick()
			LuaUIUtils.clueSeek(data, nil, button, sourceId)

			if cbFunc then
				cbFunc()
			end
		end
	end

	function LuaUIUtils.getItemSourceClickFunc(button, data, isDirectGotoSource, sourceId, cbFunc)
		return function()
			LuaUIUtils.clueSeek(data, nil, button, sourceId)

			if cbFunc then
				cbFunc()
			end
		end
	end

	function LuaUIUtils.checkFastTargetMark()
		local isFastTargetMark = pg.me.space and pg.me.space.sceneId and SceneData[pg.me.space.sceneId].trackType and SceneData[pg.me.space.sceneId].trackType == Const.TRACK_TYPE.PVP

		return isFastTargetMark
	end

	function LuaUIUtils.useTeamMapMark()
		local shareType = pg.me.space and pg.me.space.sceneId and SceneData[pg.me.space.sceneId].trackShareType and SceneData[pg.me.space.sceneId].trackShareType or Const.TRACK_SHARE_TYPE.SHARE_TYPE_TEAM
		local isFastTargetMark = shareType == Const.TRACK_SHARE_TYPE.SHARE_TYPE_TEAM

		return isFastTargetMark
	end

	function LuaUIUtils.tryTeleportDirectClueSeek(data, targetScene)
		if not data or data.teleportDirect ~= 1 or not targetScene then
			return false
		end

		local curScene = pg.game.map:convertSceneId(pg.me.space.sceneId)
		local dstScene = pg.game.map:convertSceneId(targetScene)

		if not dstScene or curScene == dstScene then
			pg.game.map:setClueSeekTeleportTrace(dstScene or curScene, data)
			pg.game.map:dealWithClueSeekTeleportTrace()

			return
		end

		local function doTeleport()
			pg.game.map:setClueSeekTeleportTrace(dstScene, data)
			ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
				pg.me:serverMsg("RPC_CS_ReqEnterSelfHomeland")
			end)
		end

		if data.confirmTitle and data.confirmTxt then
			ClientUtils.showConfirmRaw(pg.getGameString(data.confirmTitle), pg.getGameString(data.confirmTxt), doTeleport)
		else
			doTeleport()
		end
	end

	function LuaUIUtils.clueSeek(data, cb, button, sourceId)
		if not data then
			return
		end

		if pg.me and pg.me.space and Utils.isSpaceFishingCaptureDungeon(pg.me.space.spaceType) then
			return
		end

		if not LuaUIUtils.checkItemSourceCondition(data) then
			if data.conditionToast then
				ClientUtils.showBubbleMessage(data.conditionToast)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
			end

			return
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("LuaUIUtils.clueSeek, sourceId: %s; type: %s", sourceId or "nil", data and data.type or "nil")
		end

		if data.type == LuaUIUtils.ITEM_SOURCE_HOMELAND_FACILITIES and data.sourceFacilities or data.type == LuaUIUtils.ITEM_SOURCE_HOME_CAMP_CAR and data.campCarPosInfo then
			local sceneId = HomeLandUtils.getCurHomeCampMainSceneId()

			if LuaUIUtils.checkTeleportLimit(sceneId) then
				return
			end
		elseif LuaUIUtils.checkTeleportLimit(data.sourceScene) then
			return
		end

		if data.type == LuaUIUtils.ITEM_SOURCE_TYPE_TIPS and button and data.clueSeekID and data.clueSeekID > 0 then
			local args = {}

			args.clueSeekID = data.clueSeekID
			args.targetRect = button
			args.isModel = true

			LuaUIUtils.popupClueSeekTip(args)
		elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS and data.sourcePosition and data.sourceScene and data.buttonTxt then
			if data.teleportDirect and data.teleportDirect == LuaUIUtils.JUMP_HOME then
				LuaUIUtils.tryTeleportDirectClueSeek(data, data.sourceScene)

				return
			end

			pg.game.map:openMapAndLocateTempMark(data.sourceScene, data.sourcePosition[1], data.sourcePosition[2], data.sourcePosition[3], data.markPointType, math.abs(data.buttonTxt), cb, data.showTrace and data.showTrace == 1, data.extraParam, true)
		elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_MARK and data.sourceMarkPoint and data.sourceScene and data.buttonTxt then
			if data.teleportDirect and data.teleportDirect == LuaUIUtils.JUMP_HOME then
				LuaUIUtils.tryTeleportDirectClueSeek(data, data.sourceScene)

				return
			end

			local sceneMarkPointData = SceneUtils.getSceneMarkPointData(data.sourceScene)

			if not sceneMarkPointData or not sceneMarkPointData[data.sourceMarkPoint[1]] or not sceneMarkPointData[data.sourceMarkPoint[1]].markType then
				return
			end

			if sceneMarkPointData[data.sourceMarkPoint[1]].markType == Const.MAP_MARK_TRACE then
				pg.game.map:openMapAndLocateMark(data.sourceScene, sceneMarkPointData[data.sourceMarkPoint[1]].markType, data.sourceMarkPoint[1], true, data.sourceMarkPoint[2], cb, data.showTrace and data.showTrace == 1, true)
			else
				local trace = false

				if data.showTrace and data.showTrace == 1 then
					trace = true
				end

				pg.game.map:openMapAndLocateMark(data.sourceScene, sceneMarkPointData[data.sourceMarkPoint[1]].markType, data.sourceMarkPoint[1], trace, data.sourceMarkPoint[2], cb, data.showTrace and data.showTrace == 1, true)
			end
		elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_EVENT then
			if data.confirmTitle and data.confirmTxt then
				ClientUtils.showConfirmRaw(pg.getGameString(data.confirmTitle), pg.getGameString(data.confirmTxt), function()
					pg.me:doEventByData({
						data.param[1],
						data.param[2]
					}, {
						uiOpenCb = cb
					})
				end)
			else
				pg.me:doEventByData({
					data.param[1],
					data.param[2]
				}, {
					uiOpenCb = cb
				})
			end
		elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_FILTER and data.sourceMarkPoint and #data.sourceMarkPoint >= 2 then
			local configIds = {}

			for k, id in ipairs(data.sourceMarkPoint) do
				if k ~= 1 then
					configIds[#configIds + 1] = id
				end
			end

			pg.game.map:openMapWithFilter({
				sceneId = data.sourceScene,
				stage = data.sourceMarkPoint[1],
				configIds = configIds,
				cb = cb
			})
		elseif data.type == LuaUIUtils.ITEM_SOURCE_HOMELAND_FACILITIES and data.sourceFacilities then
			if data.teleportDirect and data.teleportDirect == LuaUIUtils.JUMP_HOME then
				LuaUIUtils.tryTeleportDirectClueSeek(data, data.sourceScene)

				return
			end

			pg.game.map:openMapAndTraceToHomelandPortal(data.sourceFacilities[1], data.sourceFacilities[2] or "$UI_Icon_Mark01.png", cb)
		elseif data.type == LuaUIUtils.ITEM_SOURCE_HOME_CAMP_CAR and data.campCarPosInfo then
			pg.game.map:traceSelfHomeCar(data.campCarPosInfo[1], data.campCarPosInfo[2] or "$UI_Icon_Mark01.png", data, cb)
		elseif data.type == LuaUIUtils.ITEM_SOURCE_JUMP_QUEST_PAGE and data.clueSeekID and data.clueSeekID > 0 then
			local QuestUtils = require("GameApp.Quest.QuestUtils")

			QuestUtils.doClueSeekQuickJump(data.clueSeekID)
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
		end
	end

	function LuaUIUtils.locateMark(sceneId, pointId)
		local smpdd = SceneUtils.getSceneMarkPointData(sceneId)
		local point = smpdd and smpdd[pointId]

		if point then
			local status = pg.me:getSpaceOwnerMapMarkStatus(sceneId, point.markType, pointId)

			if status < Const.MAP_MARK_STATUS_LOCKED then
				local treeMarkId = LuaUIUtils._getLeylineTreeMarkId(sceneId)

				if treeMarkId then
					local treePoint = smpdd[treeMarkId]

					if treePoint then
						pg.game.map:openMapAndLocateMark(sceneId, treePoint.markType, treeMarkId, nil, 1, function()
							pg.global.showBubbleMessageRaw(pg.getGameString("PETSHAPE_HABITAT_UNLOCK"), 3)
						end)

						return
					end
				end
			end

			pg.game.map:openMapAndLocateMark(sceneId, point.markType, pointId, nil, 1)
		end
	end

	function LuaUIUtils._getLeylineTreeMarkId(sceneId)
		for _, v in pairs(MapAreaConfigData) do
			if v.Mapid == sceneId and v.Campid and v.Campid ~= 0 then
				return v.Campid
			end
		end

		return nil
	end

	function LuaUIUtils.popupClueSeekTip(args)
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CLUE_SEEK_TIP) then
			pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_CLUE_SEEK_TIP, args)
		end
	end

	function LuaUIUtils.renderItemWithCountCheck(rewardBtn, data, numTextCustomFunc, isForbidDraggable)
		local player = pg.me
		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local iconImg = objectReference:GetRefValue("itemIconUImage")
		local numTxt = objectReference:GetRefValue("txtNumUText")

		if data.isReplace ~= nil then
			local btnSwitchUContainer = LuaUIUtils.safeGetRefValue(objectReference, "btnSwitchUContainer")

			if btnSwitchUContainer then
				local isReplace = data.isReplace and true or false

				btnSwitchUContainer:SetActive(isReplace)

				if isReplace and not btnSwitchUContainer:CheckURLLoaded() then
					btnSwitchUContainer:LoadDefaultUrlManually()
				end
			end
		end

		if numTextCustomFunc then
			numTextCustomFunc(numTxt)
		else
			local itemCount = ItemUtils.getItemCountById(player, data.id)

			LuaUIUtils.renderConsumeText(numTxt, itemCount, data.num, 1)
		end

		iconImg.url = LuaUIUtils.getIconByItemId(data.id)

		local itemConfig = ItemData[data.id]

		if itemConfig then
			rewardBtn:TryChangePage("Quality", itemConfig.quality)
		end

		rewardBtn:TryChangePage("State", 0)

		function rewardBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.num,
				targetRect = rewardBtn
			})
		end

		rewardBtn.draggable = not isForbidDraggable
	end

	function LuaUIUtils.renderPOIRewardItem(rewardBtn, index, data)
		local numTxt = rewardBtn:GetChild("TxtNum"):GetComponent("UBaseText")
		local iconImg = rewardBtn:GetChild("ImgItem"):GetComponent("UImage")

		ClientTextUtils.setText(numTxt, tostring(data.itemCount))

		iconImg.url = LuaUIUtils.getIconByItemId(data.itemId)

		local itemConfig = ItemData[data.itemId]

		if itemConfig then
			rewardBtn:TryChangePage("Quality", itemConfig.quality)
		end

		function rewardBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.itemId,
				num = data.itemCount,
				targetRect = rewardBtn
			})
		end
	end

	function LuaUIUtils.getSpecialItemInfo(itemId, itemCount)
		local iData = ItemData[itemId]

		if iData == nil then
			return nil
		end

		local msg = {
			id = itemId,
			num = itemCount,
			ownNum = ItemUtils.getItemCountById(pg.me, itemId, true),
			itemName = pg.getLocalizationText(iData.itemName),
			quality = iData.quality,
			bgResId = iData.backgroundRes,
			desc = pg.getLocalizationText(iData.funcRep),
			icon = LuaUIUtils.getIconByItemId(itemId)
		}

		return msg
	end

	function LuaUIUtils.setTopCurrencyItemList(currencyUList, uiid, itemList, jumpOptions)
		if not currencyUList or not uiid and not itemList then
			return
		end

		function currencyUList.luaRenderItem(button, index, data)
			LuaUIUtils.setTopCurrencyItem(button, data.itemId, data.needAdd, nil, nil, jumpOptions)
		end

		local currencyItemList = {}

		if itemList then
			for i = 1, #itemList do
				local temp = {}

				temp.itemId = itemList[i]
				currencyItemList[#currencyItemList + 1] = temp
			end
		else
			local panelConstData = UIConst.UI_CONFIGS[uiid]

			if panelConstData and panelConstData.coin_Line then
				for i = 1, #panelConstData.coin_Line do
					local temp = {}

					temp.itemId = panelConstData.coin_Line[i]
					currencyItemList[#currencyItemList + 1] = temp
				end
			end
		end

		currencyUList:SetList(currencyItemList)
	end

	function LuaUIUtils.setTopCurrencyItem(button, itemId, needAdd, maxValue, hideBg, jumpOptions)
		local objectReference = button:GetComponent("ObjectReference")
		local countUText = objectReference:GetRefValue("countUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnAdd = objectReference:GetRefValue("btnAdd")
		local bgUWidget = objectReference:GetRefValue("bgUWidget")

		if bgUWidget then
			bgUWidget:SetActive(not hideBg)
		end

		local itemConfig = ItemData[itemId]
		local itemCount = 0

		button.enabledTooltip = false
		button.luaRenderTooltip = nil
		button.luaClick = nil

		if itemId == ItemConst.ITEM_SPECIAL_EXP_ROGUE_TALENT then
			itemCount = pg.me.rogueTalentExp or 0
		elseif itemId >= ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND and itemId <= ItemConst.ITEM_SPECIAL_MONEY_CASH then
			itemCount = pg.me:getMoneyNum(itemId)
		else
			itemCount = pg.me:getItemCountById(itemId)
		end

		if itemConfig then
			local countText = ItemUtils.NEGATIVE_MONEY_TYPE[itemId] and itemCount < 0 and pg.getFormatText("<style=Debuff>{0}</style>", itemCount) or itemCount

			if maxValue then
				ClientTextUtils.setText(countUText, string.format("%s/%d", countText, maxValue))
			elseif jumpOptions and jumpOptions.useShortItemNum and (not ItemUtils.NEGATIVE_MONEY_TYPE[itemId] or not (itemCount < 0)) then
				countUText.useInternationalNumberFormat = false

				ClientTextUtils.setText(countUText, LuaUIUtils.formatShortItemNum(itemCount))
			else
				ClientTextUtils.setText(countUText, countText)
			end

			iconUImage.url = LuaUIUtils.getIconByItemId(itemId)

			function button.luaClick()
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = itemId,
					num = itemCount,
					targetRect = button
				})
			end
		end

		local isRechage = itemId == ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND
		local isTransmogExchange = itemId == tonumber(PetTransmogBaseData.need_item_id) and tonumber(PetTransmogBaseData.transmog_shop_open) == 1
		local canAdd = CurrencyAutoChangeData[itemId] ~= nil or isRechage or isTransmogExchange

		if jumpOptions and jumpOptions.enableLongPressTips then
			button:RemoveLuaGamepadHotkey()
		end

		if canAdd and jumpOptions and jumpOptions.enableLongPressTips then
			button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, 0, function()
				if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
				else
					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						id = itemId,
						num = itemCount,
						targetRect = button
					})
				end

				return false
			end)
			button:SetHotkeyActiveOnlyInCurrentItem(true)
			button:SetHotkeyConsoleBar("GIFTPACK_TIPS", 0)
		end

		button:TryChangePage("IsAdd", canAdd and 1 or 0)

		if (needAdd or canAdd) and btnAdd then
			function btnAdd.luaClick()
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
				end

				if canAdd then
					local function closeBeforeJump()
						if jumpOptions and jumpOptions.closeBeforeJumpUiId then
							pg.global.ui:close(jumpOptions.closeBeforeJumpUiId)
						end
					end

					if isRechage then
						if not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.CASHSHOP) then
							return
						end

						closeBeforeJump()

						if pg.global.ui:checkUIOpen(UIConst.UI_ID_CASH_SHOP) then
							pg.global.ui.cashShop:navigateTo(CashShopConst.CategoryType.RECHARGE)
						elseif pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
							PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()
						else
							pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
								tabId = CashShopConst.CategoryType.RECHARGE
							})
						end
					elseif isTransmogExchange then
						closeBeforeJump()
						pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
							shopTags = {
								47
							}
						})
					else
						closeBeforeJump()
						LuaUIUtils.openVitalityGot(itemId)
					end
				end
			end
		end
	end

	function LuaUIUtils.setCostCurrencyItem(button, itemId, itemCount, showNotEnough)
		local objectReference = button:GetComponent("ObjectReference")
		local countUText = objectReference:GetRefValue("countUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local itemConfig = ItemData[itemId]

		if itemConfig then
			local hasCount = 0

			if itemId >= ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND and itemId <= ItemConst.ITEM_SPECIAL_MONEY_CASH then
				hasCount = pg.me:getMoneyNum(itemId)
			else
				hasCount = pg.me:getItemCountById(itemId)
			end

			if showNotEnough and hasCount < itemCount then
				local count = pg.getFormatText("<style=Debuff>{0}</style>", itemCount)

				ClientTextUtils.setText(countUText, count)
			else
				ClientTextUtils.setText(countUText, itemCount)
			end

			iconUImage.url = LuaUIUtils.getIconByItemId(itemId)

			function button.luaClick()
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = itemId,
					num = itemCount,
					targetRect = button
				})
			end
		end
	end

	function LuaUIUtils.setRewardListByDropIdsBatch(uList, dropDatas, multiNum, showSellPrice)
		local multi = multiNum or 1
		local rewards = {}
		local sort = {}

		for _, dropData in ipairs(dropDatas) do
			local reward = LuaUIUtils.getRewardItemByDropId(dropData.dropId, dropData.hasGet, dropData.canGet, dropData.firstReward, dropData.extraFunc)

			for index, value in ipairs(reward) do
				value.rewardMulti = dropData.multiNum or multi

				table.insert(sort, value)
			end
		end

		for i = 1, #sort do
			local val = sort[i]

			if val and val.isBatch == nil then
				for j = i + 1, #sort do
					local next = sort[j]

					if next.isBatch == nil and val.type == next.type then
						if val.type == 0 then
							if val.id == next.id and val.rate == next.rate and val.displayRewardType == next.displayRewardType then
								next.isBatch = true
								val.num = val.num + next.num
							end
						elseif val.petId == next.petId and val.level == next.level and val.label == next.label then
							next.isBatch = true
							val.num = val.num + next.num
						end
					end
				end
			end
		end

		for k, v in ipairs(sort) do
			if v.isBatch == nil then
				v.num = math.floor(v.num * v.rewardMulti)

				if showSellPrice and v.type == 0 then
					v.price = Utils.getHomeItemPrice(v.id)
				end

				table.insert(rewards, v)
			end
		end

		function uList.luaRenderItem(button, index, data)
			if data.tIndex == 0 then
				button:TryChangePage("ItemType", data.type)

				if data.type == 0 then
					LuaUIUtils.renderRewardItem(button, data)
				elseif data.type == 1 then
					LuaUIUtils.renderRewardPet(button, data)
				elseif data.type == 2 then
					LuaUIUtils.renderRewardItem(button, data)
				end
			end
		end

		uList:SetList(rewards)
	end

	function LuaUIUtils.setRewardListByDropIds(uList, dropDatas, minCount, extraRenderFunc)
		local rewards = {}

		for _, dropData in ipairs(dropDatas) do
			local reward = LuaUIUtils.getRewardItemByDropId(dropData.dropId, dropData.hasGet, dropData.canGet, dropData.firstReward, dropData.extraFunc)

			for index, value in ipairs(reward) do
				table.insert(rewards, value)
			end
		end

		if minCount then
			for i = #rewards + 1, minCount do
				table.insert(rewards, {
					tIndex = 1
				})
			end
		end

		function uList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewards(button, index, data)

			if extraRenderFunc then
				extraRenderFunc(button, index, data)
			end
		end

		uList:SetList(rewards)
	end

	function LuaUIUtils.setRewardListByDropId(uList, dropId, minCount, hasGet, canGet, hideSource, closeOnJumpToSource)
		local rewards = LuaUIUtils.getRewardItemByDropId(dropId, hasGet, canGet)

		if minCount then
			for i = #rewards + 1, minCount do
				table.insert(rewards, {
					tIndex = 1
				})
			end
		end

		function uList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewards(button, index, data, hideSource, closeOnJumpToSource)
		end

		uList:SetList(rewards)
	end

	function LuaUIUtils.setRewardListByDropIdWithoutClick(uList, dropId, minCount, hasGet, canGet, hideSource, closeOnJumpToSource, renderCallback)
		local rewards = LuaUIUtils.getRewardItemByDropId(dropId, hasGet, canGet)

		if minCount then
			for i = #rewards + 1, minCount do
				table.insert(rewards, {
					tIndex = 1
				})
			end
		end

		function uList.luaRenderItem(button, index, data)
			button.luaClick = nil

			LuaUIUtils.renderRewards(button, index, data, hideSource, closeOnJumpToSource)

			button.luaClick = nil

			if renderCallback then
				renderCallback(button, index, data)
			end
		end

		uList:SetList(rewards)
	end

	function LuaUIUtils.setRewardListInCommonTip(uList, dropId, needShowBtnSelfTip, enableSubTooltip)
		local rewards = LuaUIUtils.getRewardItemByDropId(dropId)

		function uList.luaRenderItem(button, index, data)
			if data.tIndex == 0 then
				button:TryChangePage("ItemType", data.type)

				if data.type == 0 then
					LuaUIUtils.renderRewardItem(button, data, nil, needShowBtnSelfTip, enableSubTooltip)
				elseif data.type == 1 then
					LuaUIUtils.renderRewardPet(button, data)
				elseif data.type == 2 then
					LuaUIUtils.renderRewardItem(button, data)
				end
			end
		end

		uList:SetList(rewards)
	end

	function LuaUIUtils.formatShortItemNum(num)
		return formatShortNumberBySelectedLanguage(num)
	end

	function LuaUIUtils.formatStyledItemNum(ownNum, needNum, preferState, showSingleLack)
		if ownNum == nil and needNum == nil then
			return ""
		end

		if ownNum == nil or needNum == nil then
			local singleNum = ownNum or needNum
			local singleText = LuaUIUtils.formatShortItemNum(singleNum)

			if showSingleLack then
				return string.format("<style=%s>%s</style>", UIConst.ITEM_STATE_COLOR[UIConst.ITEM_STATE.LACK], singleText)
			end

			return singleText
		end

		ownNum = ownNum or 0
		needNum = needNum or 0

		local ownText = LuaUIUtils.formatShortItemNum(ownNum)
		local needText = LuaUIUtils.formatShortItemNum(needNum)

		if needNum <= 0 then
			return formatItemNumRatio(ownText, needText)
		end

		local state = getItemNumState(ownNum, needNum, preferState)
		local style = state and UIConst.ITEM_STATE_COLOR[state]

		if string.isNilOrEmpty(style) then
			return formatItemNumRatio(ownText, needText)
		end

		local styledOwnText = string.format("<style=%s>%s</style>", style, ownText)

		return formatItemNumRatio(styledOwnText, needText)
	end

	function LuaUIUtils.renderConsumeText(uText, ownNum, consumeNum, style, enoughColor, lackColor)
		local content

		if not string.isNilOrEmpty(enoughColor) or not string.isNilOrEmpty(lackColor) then
			local ownText = LuaUIUtils.formatShortItemNum(ownNum)
			local consumeText = LuaUIUtils.formatShortItemNum(consumeNum)
			local color = (tonumber(ownNum) or 0) >= (tonumber(consumeNum) or 0) and enoughColor or lackColor

			if string.isNilOrEmpty(color) then
				content = formatItemNumRatio(ownText, consumeText)
			else
				local coloredOwnText = string.format("<color=%s>%s</color>", color, ownText)

				content = formatItemNumRatio(coloredOwnText, consumeText)
			end
		else
			content = LuaUIUtils.formatStyledItemNum(ownNum, consumeNum, style)
		end

		if uText then
			ClientTextUtils.setText(uText, content)
		end

		return content
	end

	function LuaUIUtils.getItemShowText(itemId)
		local iconUrl = LuaUIUtils.getIconByItemId(itemId)

		iconUrl = string.sub(iconUrl, 2, -5)

		return string.format("<sprite name=\"%s_small\">", iconUrl)
	end

	function LuaUIUtils.getItemCountConsumeShowText(costItemId, consumeNum, needName)
		local hasNum = ClientUtils.getItemCountById(costItemId)
		local textStyle = hasNum < consumeNum and "Debuff" or "Hint_BgL"
		local itemName = needName and LuaUIUtils.getNameByItemId(costItemId) or ""
		local iconUrl = LuaUIUtils.getIconByItemId(costItemId)

		iconUrl = string.sub(iconUrl, 2, -5)

		return string.format("<sprite name=\"%s_small\"><style=%s>%d</style> %s", iconUrl, textStyle, consumeNum, itemName)
	end

	function LuaUIUtils.getItemCountConsumeShowNoColorText(costItemId, consumeNum, needName)
		local itemName = needName and LuaUIUtils.getNameByItemId(costItemId) or ""
		local iconUrl = LuaUIUtils.getIconByItemId(costItemId)

		iconUrl = string.sub(iconUrl, 2, -5)

		return string.format("<sprite name=\"%s_small\">%d%s", iconUrl, consumeNum, itemName)
	end

	function LuaUIUtils.getItemCountConsumeShowColorRedOnlyText(costItemId, consumeNum, needName)
		local hasNum = ClientUtils.getItemCountById(costItemId)
		local textStyle = hasNum < consumeNum and "<sprite name=\"%s_small\"><style=Debuff>%d</style>%s" or "<sprite name=\"%s_small\">%d%s"
		local itemName = needName and LuaUIUtils.getNameByItemId(costItemId) or ""
		local iconUrl = LuaUIUtils.getIconByItemId(costItemId)

		iconUrl = string.sub(iconUrl, 2, -5)

		return string.format(textStyle, iconUrl, consumeNum, itemName)
	end

	function LuaUIUtils.getItemObtainShowText(itemId, obtainNum, needName)
		local itemName = needName and string.format(" %s", LuaUIUtils.getNameByItemId(itemId)) or ""
		local iconUrl = LuaUIUtils.getIconByItemId(itemId)

		iconUrl = string.sub(iconUrl, 2, -5)

		return string.format("<sprite name=\"%s_small\"><style=Hint_BgL>%d%s</style>", iconUrl, obtainNum, itemName)
	end

	function LuaUIUtils.getItemBuyResetText(limitType)
		if limitType == Const.SHOP_LIMIT_TYPE.DAY then
			return pg.getGameString("THIS_DAY")
		elseif limitType == Const.SHOP_LIMIT_TYPE.WEEK then
			return pg.getGameString("THIS_WEEK")
		elseif limitType == Const.SHOP_LIMIT_TYPE.MONTH then
			return pg.getGameString("THIS_MONTH")
		end
	end

	function LuaUIUtils.renderRewards(button, index, data, hideSource, closeOnJumpToSource)
		if data.tIndex == 0 then
			button:TryChangePage("ItemType", data.type)

			if data.type == 0 then
				LuaUIUtils.renderRewardItem(button, data, nil, nil, nil, hideSource, closeOnJumpToSource)
			elseif data.type == 1 then
				LuaUIUtils.renderRewardPet(button, data)
			elseif data.type == 2 then
				LuaUIUtils.renderRewardItem(button, data, nil, nil, nil, hideSource, closeOnJumpToSource)
			end
		end
	end

	function LuaUIUtils.renderMailRewards(button, index, data)
		if data.type == 0 or data.type == 2 then
			LuaUIUtils.renderRewardItem(button, data)
		elseif data.type == 1 then
			button.luaClick = nil

			local objectReference = button:GetComponent("ObjectReference")
			local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
			local iconPetUContainer = objectReference:GetRefValue("iconPetUContainer")
			local txtNumUText = objectReference:GetRefValue("txtNumUText")

			txtNumUText = txtNumUText or objectReference:GetRefValue("txtNumUBaseText")

			itemIconUImage:SetActive(false)
			txtNumUText:SetActive(false)
			iconPetUContainer:SetActive(true)

			local function refreshPetIcon(content)
				local objRef = content:GetComponent("ObjectReference")
				local petIcon = objRef:GetRefValue("petIcon")

				petIcon.url = LuaUIUtils.getPetIcon(PetData[data.petId].iconName, LuaUIUtils.PET_ICON, data.label)
			end

			if iconPetUContainer:CheckURLLoaded() then
				refreshPetIcon(iconPetUContainer.content)
			else
				iconPetUContainer:LoadDefaultUrlManually(refreshPetIcon)
			end
		end

		RewardStateUtils.applyItemState(button, {
			hasGet = data.hasGet,
			canGet = data.canGet == nil and not data.hasGet or data.canGet
		})
	end

	function LuaUIUtils.renderRewardAbility(rewardBtn, data)
		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")
		local itemNameUText = objectReference:GetRefValue("itemNameUText")

		ClientTextUtils.setText(txtNumUText, data.name)

		itemIconUImage.url = data.icon

		ClientTextUtils.setText(itemNameUText, data.desc)
		rewardBtn:TryChangePage("Quality", 5)

		if data.showRedDot ~= nil then
			rewardBtn:ShowRedDot(data.showRedDot)
		end

		function rewardBtn.luaClick()
			if not data.abilityVirtualItemId then
				return
			end

			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.abilityVirtualItemId,
				num = data.num,
				targetRect = rewardBtn
			})
		end
	end

	function LuaUIUtils.renderRewardItem(rewardBtn, data, numOverrideText, needShowBtnSelfTip, enableSubTooltip, hideSource, closeOnJumpToSource)
		if data.tIndex == 1 then
			return
		end

		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local iconPetUContainer = objectReference:GetRefValue("iconPetUContainer")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")

		txtNumUText = txtNumUText or objectReference:GetRefValue("txtNumUBaseText")

		local itemNameUText = objectReference:GetRefValue("itemNameUText")
		local tagFirsRewardUWidget = objectReference:GetRefValue("tagFirsRewardUWidget")

		tagFirsRewardUWidget = tagFirsRewardUWidget or objectReference:GetRefValue("tagFirsRewardUButton")

		local checkedUButton = objectReference:GetRefValue("checkedUButton")
		local buttonUpUButton = objectReference:GetRefValue("buttonUpUButton")

		tagFirsRewardUWidget = tagFirsRewardUWidget and tagFirsRewardUWidget:GetComponent("UWidget")

		if iconPetUContainer then
			iconPetUContainer:SetActive(false)
		end

		itemIconUImage:SetActive(true)

		itemNameUText = itemNameUText and itemNameUText:GetComponent("UBaseText")

		if numOverrideText then
			ClientTextUtils.setText(txtNumUText, numOverrideText)
		elseif data.num then
			if type(data.num) == "number" then
				if data.num > 1 then
					ClientTextUtils.setText(txtNumUText, tostring(data.num))
				else
					ClientTextUtils.setText(txtNumUText, "")
				end
			else
				ClientTextUtils.setText(txtNumUText, tostring(data.num))
			end
		else
			ClientTextUtils.setText(txtNumUText, "")
		end

		local iconResId

		if not data.iconUrl and ItemUtils.isRefineable(data.id) then
			local iconData = data.packSlot or data.props and data or nil

			if iconData then
				iconResId = RobEggCollectionVisualUtils.getIconResId(iconData)
			end
		end

		itemIconUImage.url = data.iconUrl or iconResId or LuaUIUtils.getIconByItemId(data.id)

		local itemConfig = ItemData[data.id]

		if itemConfig then
			local quality = itemConfig.quality or 0

			rewardBtn:TryChangePage("Quality", quality)

			if itemNameUText then
				ClientTextUtils.setText(itemNameUText, pg.getLocalizationText(itemConfig.itemName))
			end
		end

		RewardStateUtils.applyItemState(rewardBtn, data)

		if buttonUpUButton then
			buttonUpUButton:SetActive(data.isExtra == true)
		end

		if tagFirsRewardUWidget then
			if data.firstReward then
				tagFirsRewardUWidget:SetActive(true)
			else
				tagFirsRewardUWidget:SetActive(false)
			end
		end

		if data.enableChecked ~= nil then
			checkedUButton.gameObject:SetActiveEx(data.enableChecked)
		end

		if data.displayRewardType and type(data.num) == "number" and data.rate then
			if data.displayRewardType == 1 then
				if data.num and data.num > 0 then
					ClientTextUtils.setText(txtNumUText, tostring(data.num))
				else
					ClientTextUtils.setText(txtNumUText, "")
				end
			elseif data.displayRewardType == 2 then
				if data.rate and data.rate < 1 then
					ClientTextUtils.setText(txtNumUText, pg.getGameString("PROB"))
				elseif data.num and data.num > 0 then
					ClientTextUtils.setText(txtNumUText, tostring(data.num))
				else
					ClientTextUtils.setText(txtNumUText, "")
				end
			end
		end

		if data.isUnknow == true then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("LuaUIUtils.renderRewardItem, isUnknow == true, itemId: %s", data.id)
			end

			if data.unkownInfoText then
				function rewardBtn.luaClick()
					LuaUIUtils.onUnkownRewardItemClick(rewardBtn, data)
				end
			else
				rewardBtn.luaClick = nil
			end
		else
			function rewardBtn.luaClick(navConfirm)
				LuaUIUtils.onRewardItemClick(rewardBtn, data, needShowBtnSelfTip, navConfirm, enableSubTooltip, hideSource, closeOnJumpToSource)
			end
		end
	end

	function LuaUIUtils.onUnkownRewardItemClick(rewardBtn, data)
		if pg.global.ui:checkUIShow(UIConst.UI_ID_SIMPLE_TEXT_TIP) then
			pg.global.ui:close(UIConst.UI_ID_SIMPLE_TEXT_TIP)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_SIMPLE_TEXT_TIP, {
			infoText = data.unkownInfoText,
			targetRect = rewardBtn
		})
	end

	local function openRewardItemSubTooltip(rewardBtn, data, hideSource)
		if rewardBtn.isTooltipOpen then
			return
		end

		function rewardBtn.luaRenderTooltip(_, cmp)
			local contentReady = false
			local shownBeforeContentReady = false
			local openVersion = 0
			local timeoutTimer

			local function canCompleteOpen()
				return NotNil(cmp) and NotNil(rewardBtn) and rewardBtn.isTooltipOpen
			end

			local function scheduleCompleteOpen()
				openVersion = openVersion + 1

				local version = openVersion

				TimerManager.addNextFrameCb(function()
					if version ~= openVersion or not canCompleteOpen() then
						return
					end

					rewardBtn:CompleteDeferredTooltipOpen()
				end)
			end

			local function onContentReady()
				contentReady = true

				if timeoutTimer then
					TimerManager.removeTimer(timeoutTimer)

					timeoutTimer = nil
				end

				if shownBeforeContentReady then
					openVersion = openVersion + 1

					if canCompleteOpen() then
						cmp.renderOpacity = 0

						rewardBtn:CompleteDeferredTooltipOpen()
					end
				else
					scheduleCompleteOpen()
				end
			end

			LuaUIUtils.refreshItemInfo(cmp, {
				id = data.id,
				num = data.num,
				price = data.price,
				hideSource = hideSource,
				onContentReady = onContentReady
			}, rewardBtn)

			if not contentReady then
				timeoutTimer = TimerManager.addTimer(SUB_TOOLTIP_CONTENT_READY_TIMEOUT, function()
					timeoutTimer = nil
					shownBeforeContentReady = true

					scheduleCompleteOpen()
				end)
			end
		end

		rewardBtn:OpenTooltipDeferred()
	end

	function LuaUIUtils.onRewardItemClick(rewardBtn, data, needShowBtnSelfTip, navConfirm, enableSubTooltip, hideSource, closeOnJumpToSource)
		if enableSubTooltip or needShowBtnSelfTip == true and rewardBtn.enabledTooltip == true then
			openRewardItemSubTooltip(rewardBtn, data, hideSource)

			return
		end

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) and not navConfirm then
			local tipCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_COMMON_ITEM_TIP)
			local tipData = tipCtrl and tipCtrl.iData
			local isSameTip = tipData and tipData.originData == data and tipData.targetRect == rewardBtn

			if data.extraFunc ~= nil then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			local tipClosing = tipCtrl and tipCtrl.view and tipCtrl.view.widget and tipCtrl.view.widget.isClosing

			if isSameTip and not tipClosing then
				return
			end
		end

		if data.extraFunc ~= nil then
			if navConfirm then
				return
			end

			data.extraFunc()

			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			padding = data.padding or nil,
			autoHor = data.autoHor or false,
			originData = data,
			id = data.id,
			num = data.num,
			price = data.price,
			targetRect = rewardBtn,
			navigationPopupOwner = navConfirm and rewardBtn or nil,
			hierarchyMode = data.hierarchyMode,
			sortingOrder = data.sortingOrder,
			hideSource = hideSource,
			closeOnJumpToSource = closeOnJumpToSource,
			rayCastParent = data.rayCastParent,
			addSibling = data.addSibling,
			checkTouchBegin = data.checkTouchBegin
		})
	end

	function LuaUIUtils.renderItem(rewardBtn, data)
		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")
		local itemNameUText = objectReference:GetRefValue("itemNameUText")
		local tagFirsRewardUWidget = objectReference:GetRefValue("tagFirsRewardUWidget")
		local checkedUButton = objectReference:GetRefValue("checkedUButton")
		local iconPetUContainer = objectReference:GetRefValue("iconPetUContainer")

		tagFirsRewardUWidget = tagFirsRewardUWidget and tagFirsRewardUWidget:GetComponent("UWidget")
		itemNameUText = itemNameUText and itemNameUText:GetComponent("UBaseText")

		if data and data.unknownIconKey then
			if itemIconUImage then
				itemIconUImage.url = AddressDataConst[data.unknownIconKey]
			end

			ClientTextUtils.setText(txtNumUText, "")

			if itemNameUText then
				ClientTextUtils.setText(itemNameUText, "")
			end

			rewardBtn:TryChangePage("Quality", 0)
			rewardBtn:TryChangePage("State", 0)

			if tagFirsRewardUWidget then
				tagFirsRewardUWidget:SetActive(false)
			end

			rewardBtn.luaClick = nil

			return
		end

		if data.num then
			if type(data.num) == "number" then
				if data.num >= 0 then
					ClientTextUtils.setText(txtNumUText, tostring(data.num))
				else
					ClientTextUtils.setText(txtNumUText, "")
				end
			else
				ClientTextUtils.setText(txtNumUText, tostring(data.num))
			end
		else
			ClientTextUtils.setText(txtNumUText, "")
		end

		if iconPetUContainer then
			iconPetUContainer:SetActive(false)
		end

		itemIconUImage:SetActive(true)

		itemIconUImage.url = LuaUIUtils.getIconByItemId(data.id)

		local itemConfig = ItemData[data.id]

		if itemConfig then
			rewardBtn:TryChangePage("Quality", itemConfig.quality)

			if itemNameUText then
				ClientTextUtils.setText(itemNameUText, pg.getLocalizationText(itemConfig.itemName))
			end
		end

		if data.hasGet then
			rewardBtn:TryChangePage("State", 1)
		elseif data.canGet then
			rewardBtn:TryChangePage("State", 2)
		else
			rewardBtn:TryChangePage("State", 0)
		end

		if data.state then
			rewardBtn:TryChangePage("State", data.state)
		end

		if tagFirsRewardUWidget then
			if data.firstReward then
				tagFirsRewardUWidget:SetActive(true)
			else
				tagFirsRewardUWidget:SetActive(false)
			end
		end

		if data.enableChecked ~= nil and checkedUButton then
			checkedUButton.gameObject:SetActiveEx(data.enableChecked)
		end

		function rewardBtn.luaClick()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			if data.extraFunc ~= nil then
				data.extraFunc()

				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.num,
				targetRect = rewardBtn,
				hierarchyMode = data.hierarchyMode,
				sortingOrder = data.sortingOrder
			})
		end
	end

	function LuaUIUtils.renderCostItem(rewardBtn, data, forceShowAll)
		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")

		txtNumUText = txtNumUText or objectReference:GetRefValue("txtNumUBaseText")

		local itemNameUText = objectReference:GetRefValue("itemNameUText")
		local tagFirsRewardUWidget = objectReference:GetRefValue("tagFirsRewardUWidget")
		local checkedUButton = objectReference:GetRefValue("checkedUButton")

		tagFirsRewardUWidget = tagFirsRewardUWidget and tagFirsRewardUWidget:GetComponent("UWidget")
		itemNameUText = itemNameUText and itemNameUText:GetComponent("UBaseText")

		if data.num and data.num > 1 and data.costNum and data.costNum > 1 or data.showNum then
			ClientTextUtils.setText(txtNumUText, LuaUIUtils.formatStyledItemNum(data.num, data.costNum))
		else
			ClientTextUtils.setText(txtNumUText, "")
		end

		itemIconUImage.url = LuaUIUtils.getIconByItemId(data.id)

		local itemConfig = ItemData[data.id]

		if itemConfig then
			rewardBtn:TryChangePage("Quality", itemConfig.quality)

			if itemNameUText then
				ClientTextUtils.setText(itemNameUText, pg.getLocalizationText(itemConfig.itemName))
			end
		end

		if data.hasGet then
			rewardBtn:TryChangePage("State", 1)
		elseif data.canGet then
			rewardBtn:TryChangePage("State", 2)
		else
			rewardBtn:TryChangePage("State", 0)
		end

		if data.state then
			rewardBtn:TryChangePage("State", data.state)
		end

		if tagFirsRewardUWidget then
			if data.firstReward then
				tagFirsRewardUWidget:SetActive(true)
			else
				tagFirsRewardUWidget:SetActive(false)
			end
		end

		if data.enableChecked ~= nil and checkedUButton then
			checkedUButton.gameObject:SetActiveEx(data.enableChecked)
		end

		function rewardBtn.luaClick()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			if data.extraFunc ~= nil then
				data.extraFunc()

				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.num,
				targetRect = rewardBtn
			})
		end
	end

	function LuaUIUtils.renderPetItemSimple(petBtn, data)
		local objectReference = petBtn.transform:GetComponent("ObjectReference")
		local petIconUImage = objectReference:GetRefValue("icon")

		petIconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(PetData[data.petId].iconName, LuaUIUtils.PET_ICON, data.label), function()
			if petIconUImage.sprite == nil then
				petIconUImage.url = LuaUIUtils.getPetIcon(PetData[data.petId].iconName, LuaUIUtils.PET_ICON, 0)
			end
		end)
	end

	function LuaUIUtils.renderRewardPet(rewardBtn, data)
		local objectReference = rewardBtn:GetComponent("ObjectReference")
		local txtNumUText = objectReference:GetRefValue("txtNumUText")

		if txtNumUText then
			txtNumUText = txtNumUText:GetComponent("USDFText")

			ClientTextUtils.setText(txtNumUText, "")
		end

		local tagFirsRewardUWidget = objectReference:GetRefValue("tagFirsRewardUWidget")

		tagFirsRewardUWidget = tagFirsRewardUWidget and tagFirsRewardUWidget:GetComponent("UWidget")

		local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
		local iconPetUContainer = objectReference:GetRefValue("iconPetUContainer")

		itemIconUImage:SetActive(false)
		iconPetUContainer:SetActive(true)

		if not iconPetUContainer:CheckURLLoaded() then
			iconPetUContainer:LoadDefaultUrlManually(function(content)
				local objRef = content:GetComponent("ObjectReference")
				local petIcon = objRef:GetRefValue("petIcon")

				petIcon.url = LuaUIUtils.getPetIcon(PetData[data.petId].iconName, LuaUIUtils.PET_ICON, 0)
			end)
		end

		rewardBtn:TryChangePage("Quality", data.label)
		RewardStateUtils.applyItemState(rewardBtn, data)

		if tagFirsRewardUWidget then
			if data.firstReward then
				tagFirsRewardUWidget:SetActive(true)
			else
				tagFirsRewardUWidget:SetActive(false)
			end
		end

		function rewardBtn.luaClick()
			if data.extraFunc ~= nil then
				data.extraFunc()

				return
			end

			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PET_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_PET_TIP)
			else
				pg.global.ui:open(UIConst.UI_ID_COMMON_PET_TIP, {
					checkTouchBegin = false,
					addSibling = 1,
					autoVer = true,
					autoHor = true,
					templateId = data.petId,
					targetRect = rewardBtn
				})
			end
		end
	end

	function LuaUIUtils.openItemCompound(compoundList, isTTLExchange)
		if not compoundList then
			return
		end

		if #compoundList > 1 then
			pg.global.ui:open(UIConst.UI_ID_ITEM_COMPOSITE_POPUP, {
				compoundList = compoundList
			})
		elseif #compoundList == 1 then
			pg.global.ui:open(UIConst.UI_ID_ITEM_COMPOSITE_POPUP_SINGLE, {
				compoundId = compoundList[1],
				isTTLExchange = isTTLExchange
			})
		end
	end

	local function getCompoundMaterialNeedMap(material)
		local materialNeedMap = {}

		for _, materialInfo in ipairs(material) do
			materialNeedMap[materialInfo[1]] = (materialNeedMap[materialInfo[1]] or 0) + materialInfo[2]
		end

		return materialNeedMap
	end

	function LuaUIUtils.checkCompositeCountLimit(compoundData, multi, dontShowTips)
		for materialId, materialNeed in pairs(getCompoundMaterialNeedMap(compoundData.material)) do
			local _, unlockCount = LuaUIUtils.getMaterialCountInfo(materialId, compoundData.compoundId)

			if unlockCount < materialNeed * multi then
				if not dontShowTips then
					LuaUIUtils.showItemNotEnough(materialId)
				end

				return false
			end
		end

		if compoundData.currency then
			local currencyId = compoundData.currency[1]
			local currencyNeedNum = compoundData.currency[2] * multi
			local currencyCount = ClientUtils.getItemCountById(currencyId)

			if currencyCount < currencyNeedNum then
				if not dontShowTips then
					LuaUIUtils.showItemNotEnough(currencyId)
				end

				return false
			end
		end

		return true
	end

	function LuaUIUtils.showItemNotEnough(itemId)
		local configData = ItemData[itemId]

		if configData then
			local itemName = pg.getLocalizationText(configData.itemName)

			pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, itemName)
		end
	end

	function LuaUIUtils.getCompoundMaxCount(compoundData)
		local maxCount

		for materialId, materialNeedCount in pairs(getCompoundMaterialNeedMap(compoundData.material)) do
			local _, unlockCount = LuaUIUtils.getMaterialCountInfo(materialId, compoundData.compoundId)

			if maxCount then
				maxCount = math.min(maxCount, math.floor(unlockCount / materialNeedCount))
			else
				maxCount = math.floor(unlockCount / materialNeedCount)
			end
		end

		if not compoundData.currency then
			return maxCount or 1
		end

		local currencyId = compoundData.currency[1]
		local currencyNeedNum = compoundData.currency[2]
		local currencyCount = ClientUtils.getItemCountById(currencyId)

		maxCount = maxCount and math.min(maxCount, math.floor(currencyCount / currencyNeedNum)) or 0

		return maxCount
	end

	function LuaUIUtils.setCompoundCard(button, propData, isTarget, isSelected, multi)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("itemIconUImage")
		local txtNameUText = objectReference:GetRefValue("txtNumUText")

		txtNameUText = txtNameUText or objectReference:GetRefValue("txtNumUBaseText")

		local propId = propData.propId
		local propInfo = LuaUIUtils.getItemClientInfoById(propId)

		iconUImage.url = propInfo.icon

		button:TryChangePage("Quality", propInfo.quality)

		local multi = isSelected and multi or 1
		local itemNeedCount = propData.countNeed * multi

		if isTarget then
			ClientTextUtils.setText(txtNameUText, itemNeedCount)
		else
			local lockCount, unlockCount = LuaUIUtils.getMaterialCountInfo(propId, propData.compoundId)
			local materialCount = 0

			button:TryChangePage("CompoundState", 0)

			if unlockCount > 0 then
				materialCount = unlockCount
			elseif lockCount > 0 then
				button:TryChangePage("CompoundState", 1)

				materialCount = lockCount
			else
				button:TryChangePage("CompoundState", 2)
			end

			LuaUIUtils.renderConsumeText(txtNameUText, materialCount, itemNeedCount, 1)
		end

		function button.luaClick()
			pg.global.ui.commonItemTip:open({
				id = propId,
				num = ClientUtils.getItemCountById(propId),
				targetRect = button
			})
		end
	end

	function LuaUIUtils.getMaterialCountInfo(propId, compoundId)
		local itemConfig = ItemData[propId]

		if compoundId and itemConfig and (tonumber(itemConfig.ttlType) or 0) > 0 then
			local requiredState = tonumber(itemConfig.ttlChangeItem) == compoundId and ItemTTLUtils.STATE_EXPIRED or ItemTTLUtils.STATE_ACTIVE
			local lockCount = 0
			local unlockCount = 0
			local invId = ItemUtils.getInvIdByItemId(propId)
			local bag = invId and ItemUtils.getTypedBag(pg.me, invId)

			if bag then
				for _, item in bag:items() do
					if item.id == propId and ItemTTLUtils.getState(item, Time.secondCache) == requiredState then
						if item:hasStatus(ItemConst.ITEM_STATUS_LOCKED) then
							lockCount = lockCount + item.count
						else
							unlockCount = unlockCount + item.count
						end
					end
				end
			end

			return lockCount, unlockCount
		end

		local totalCount = ItemUtils.getItemCountById(pg.me, propId, true)
		local unlockCount = ItemUtils.getItemCountById(pg.me, propId, false)

		return totalCount - unlockCount, unlockCount
	end

	function LuaUIUtils.getRewardItemByDropId(dropId, hasGet, canGet, firstReward, extraFunc)
		local ret = {}
		local dropInfo = DropData[dropId] or {}
		local displayRewardInfo = dropInfo.displayReward
		local displayPetRewardInfo = dropInfo.displayPetReward
		local displayRewardType = dropInfo.displayRewardType

		if not displayRewardInfo and not displayPetRewardInfo then
			return ret
		end

		if displayPetRewardInfo then
			for idx, petInfo in ipairs(displayPetRewardInfo) do
				local item = {}

				item.petId = petInfo[1]
				item.level = petInfo[2]
				item.label = petInfo[3]
				item.num = 1
				item.type = 1
				item.tIndex = 0
				item.hasGet = hasGet
				item.canGet = canGet
				item.firstReward = firstReward
				item.extraFunc = extraFunc
				ret[#ret + 1] = item
			end
		end

		if displayRewardInfo then
			local itemRate = {}
			local itemCountTable = {}
			local sortTable = {}

			for index, itemInfo in ipairs(displayRewardInfo) do
				if itemCountTable[itemInfo[1]] then
					itemCountTable[itemInfo[1]] = itemCountTable[itemInfo[1]] + itemInfo[2]
				else
					itemCountTable[itemInfo[1]] = itemInfo[2]
					sortTable[itemInfo[1]] = index
				end

				itemRate[itemInfo[1]] = itemInfo[3]
			end

			if pg.me then
				local t, replaceIdMap = ItemUtils.getReplacedItemCountTable(pg.me, itemCountTable)

				if replaceIdMap then
					for oriId, newId in pairs(replaceIdMap) do
						if sortTable[oriId] then
							sortTable[newId] = sortTable[oriId]
						end
					end
				end

				for itemId, itemNum in pairs(t) do
					local item = {}

					item.num = itemNum
					item.id = itemId
					item.type = 0
					item.tIndex = 0
					item.displayRewardType = displayRewardType
					item.rate = itemRate[itemId] or 1
					item.hasGet = hasGet
					item.canGet = canGet
					item.firstReward = firstReward
					item.extraFunc = extraFunc
					ret[#ret + 1] = item
				end

				table.sort(ret, function(a, b)
					if not a.id then
						return false
					end

					if not b.id then
						return true
					end

					return sortTable[a.id] < sortTable[b.id]
				end)
			else
				for _, itemInfo in ipairs(displayRewardInfo) do
					local item = {}

					item.num = itemInfo[2]
					item.id = itemInfo[1]
					item.type = 0
					item.tIndex = 0
					item.displayRewardType = displayRewardType
					item.rate = itemRate[itemInfo[1]] or 1
					item.hasGet = hasGet
					item.canGet = canGet
					item.firstReward = firstReward
					item.extraFunc = extraFunc
					ret[#ret + 1] = item
				end
			end
		end

		return ret
	end

	function LuaUIUtils.getRewardFixedItemsByDropId(dropId, multiplies)
		local dropInfo = DropData[dropId] or {}
		local fixedDrop = dropInfo.fixedDrop
		local dropItemsInfo = {}

		if fixedDrop and next(fixedDrop) then
			for _, fixedDropInfo in ipairs(fixedDrop) do
				if fixedDropInfo then
					local itemId = fixedDropInfo[1] or 0
					local itemCfg = ItemData[itemId] or {}
					local icon = itemCfg and itemCfg.icon or ""

					table.insert(dropItemsInfo, {
						id = itemId,
						num = (fixedDropInfo[2] or 1) * (multiplies or 1),
						icon = icon,
						quality = itemCfg and itemCfg.quality or 0,
						type = itemCfg and itemCfg.type or 0
					})
				end
			end
		end

		if (not dropItemsInfo or not next(dropItemsInfo)) and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("LuauiUtils.getRewardFixedItemsByDropId ret is nil, dropId=%s;", dropId)
		end

		return dropItemsInfo
	end

	function LuaUIUtils.getDisplayPreDispatchRewardItems(itemCountTable, multiplies)
		local retItemsInfo = {}

		if itemCountTable and next(itemCountTable) then
			for itemId, num in pairs(itemCountTable) do
				local itemCfg = ItemData[itemId] or {}
				local icon = itemCfg and itemCfg.icon or ""

				table.insert(retItemsInfo, {
					id = itemId,
					num = num or 1,
					icon = icon,
					iconUrl = icon,
					quality = itemCfg and itemCfg.quality or 0,
					type = itemCfg and itemCfg.type or 0
				})
			end
		end

		if (not retItemsInfo or not next(retItemsInfo)) and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("LuauiUtils.getDisplayPreDispatchRewardItems ret is nil, itemCountTable=%s;", itemCountTable)
		end

		return retItemsInfo
	end

	function LuaUIUtils.openItemComposite()
		return
	end

	function LuaUIUtils.openItemViewer(eventParam, uiCloseCb, uiOpenCb)
		pg.global.ui:open(UIConst.UI_ID_ITEM_VIEWER, eventParam, uiOpenCb, uiCloseCb, {
			ignoreDisableMainCamera = true
		})
	end

	function LuaUIUtils.getInventoryProps(invId, paginationId, checkItemId)
		local ret = {}
		local player = pg.me
		local bag = ItemUtils.getTypedBag(player, invId)

		if bag == nil then
			return ret
		end

		local item, isBind, bindSlot

		for _, packSlot in bag:items() do
			local itemId = packSlot.id

			if not checkItemId or itemId == checkItemId then
				local configData = ItemData[itemId]

				if not paginationId or paginationId == -1 or configData and configData.paginationId == paginationId then
					item = LuaUIUtils.getItemClientInfoById(itemId, invId, packSlot)
					item.index = packSlot.genID
					item.packSlot = packSlot
					item.count = packSlot.count
					item.invIdx = invId
					item.invId = invId
					item.genID = packSlot.genID
					item.fromList = true
					item.isCaptureBind = false

					if invId == ItemConst.INV_TYPE_BALL then
						item.catchBallSlotType = ItemUtils.getBallQuickSlotType(itemId)

						local quickSlotBall

						if item.catchBallSlotType == ItemConst.QUICK_SLOT_ELITE_BALL then
							quickSlotBall = player.invEliteSlotBall
						else
							quickSlotBall = player.invQuickSlotBall
						end

						isBind, bindSlot = LuaUIUtils.tableContains(quickSlotBall, itemId)

						if isBind then
							item.isCaptureBind = true
							item.bindCatchBallSlot = bindSlot
						end
					else
						isBind, bindSlot = LuaUIUtils.tableContains(player.invQuickSlotItem, itemId)

						if isBind then
							item.isCaptureBind = true
						end
					end

					ret[#ret + 1] = item
				end
			end
		end

		return ret
	end

	function LuaUIUtils.getDecomposeResultList(selectedGensTable, propList)
		local t = {}

		for _, v in pairs(propList) do
			local resolveGetItems = ItemData[v.itemId].resolveGetItem

			if resolveGetItems ~= nil then
				for _, vv in pairs(resolveGetItems) do
					local itemId = vv[1]
					local selectedCount = selectedGensTable[v.index] or 0
					local rewardCount = v.packSlot and LuaUIUtils.getPropDecomposeNum(v, vv[2]) or vv[2]
					local itemNum = selectedCount * rewardCount

					if t[itemId] then
						t[itemId] = t[itemId] + itemNum
					else
						t[itemId] = itemNum
					end
				end
			end
		end

		local tResult = {}

		for k, v in pairs(t) do
			local configData = ItemData[k]

			tResult[#tResult + 1] = {
				itemId = k,
				itemNum = v,
				icon = configData.icon,
				quality = configData.quality
			}
		end

		return tResult
	end

	function LuaUIUtils.getConditionUnlockDesc(condition, overrideDescMap, overrideHandler, addSystemTimeZone)
		if not condition then
			return ""
		end

		local conditionList = Utils.isTable(condition) and condition or {
			condition
		}

		for _, conditionId in ipairs(conditionList) do
			if conditionId and conditionId ~= 0 then
				local defaultDesc = ""
				local triggerData = CustomTriggerData[conditionId]

				if triggerData and triggerData.note then
					defaultDesc = pg.getLocalizationText(triggerData.note)
				end

				if triggerData and triggerData.condition then
					for _, triggerCondition in ipairs(triggerData.condition) do
						local triggerType = triggerCondition and triggerCondition[1]
						local isTimeCondition = false
						local unlockTime = 0

						if triggerType == "CLASS_OPEN_DAY" or triggerType == "SERVER_OPEN_DAY" then
							isTimeCondition = true

							local openDay = tonumber(triggerCondition[5]) or 0
							local beginTime = 0

							if triggerType == "CLASS_OPEN_DAY" then
								beginTime = pg.me and pg.me.classCreatedTime or 0
							else
								beginTime = Time.ServerOpenTime or 0
							end

							if openDay > 0 and beginTime > 0 then
								unlockTime = TimeUtils.getServerDayBegin(beginTime) + openDay * Const.SECONDS_ONE_DAY
							end
						elseif triggerType == "IN_AREA_TIME" then
							isTimeCondition = true

							local areaTimeList = triggerCondition[3]

							unlockTime = LuaUIUtils.getAreaTimeConfigTimestamp(areaTimeList)
						end

						if isTimeCondition then
							if unlockTime > 0 then
								local unlockTimeText = LuaUIUtils.timeStampToSystemLocalString(unlockTime, UIConst.TargetTimeType.Long, addSystemTimeZone == true)

								if defaultDesc ~= "" and string.find(defaultDesc, "<dayTime>", 1, true) then
									defaultDesc = string.gsub(defaultDesc, "<dayTime>", unlockTimeText)

									break
								end

								defaultDesc = unlockTimeText
							end

							break
						end
					end
				end

				local overrideDesc = overrideHandler and overrideHandler(conditionId, defaultDesc) or nil

				if overrideDesc == nil and overrideDescMap then
					overrideDesc = overrideDescMap[conditionId]
				end

				if type(overrideDesc) == "number" then
					return pg.getLocalizationText(overrideDesc)
				elseif type(overrideDesc) == "string" and overrideDesc ~= "" then
					return overrideDesc
				elseif defaultDesc ~= "" then
					return defaultDesc
				end
			end
		end

		return ""
	end

	function LuaUIUtils.getFunctionUnlockDesc(functionName, addSystemTimeZone)
		if not functionName then
			return ""
		end

		if not functionUnlockConditionsByName then
			functionUnlockConditionsByName = {}

			for conditionId, triggerData in pairs(CustomTriggerData) do
				for _, triggerEvent in ipairs(triggerData.event or EMPTY_TABLE) do
					local eventName = triggerEvent[1]
					local eventParams = triggerEvent[2]
					local unlockFunctionName = eventParams and eventParams[1]
					local unlockState = tonumber(eventParams and eventParams[2])

					if eventName == "setFunctionUnlock" and unlockFunctionName and unlockState == 1 then
						local conditionList = functionUnlockConditionsByName[unlockFunctionName]

						if not conditionList then
							conditionList = {}
							functionUnlockConditionsByName[unlockFunctionName] = conditionList
						end

						conditionList[#conditionList + 1] = conditionId
					end
				end
			end

			for _, conditionList in pairs(functionUnlockConditionsByName) do
				table.sort(conditionList)
			end
		end

		return LuaUIUtils.getConditionUnlockDesc(functionUnlockConditionsByName[functionName], nil, nil, addSystemTimeZone)
	end

	function LuaUIUtils.getConditionTriggerNumDesc(condition)
		if not condition then
			return ""
		end

		local conditionList = Utils.isTable(condition) and condition or {
			condition
		}

		for _, conditionId in ipairs(conditionList) do
			if conditionId and conditionId ~= 0 then
				local triggerData = CustomTriggerData[conditionId]

				if triggerData and triggerData.condition and triggerData.condition[1] then
					local curCount = 0

					if pg.me and pg.me.triggerMap then
						curCount = pg.me.triggerMap:getConditionFinishCount(conditionId, 1) or 0
					end

					local curText = tostring(curCount)
					local noteText = triggerData.note and pg.getLocalizationText(triggerData.note) or ""

					if noteText == "" then
						return curText
					end

					if string.find(noteText, "%%s") then
						return (string.gsub(noteText, "%%s", curText, 1))
					end

					return noteText
				end
			end
		end

		return ""
	end

	function LuaUIUtils.getCommodityUnlockDesc(commodityInfo)
		if not commodityInfo or not commodityInfo.condition then
			return ""
		end

		if commodityInfo.showConditionNum == 1 then
			local numDesc = LuaUIUtils.getConditionTriggerNumDesc(commodityInfo.condition)

			if numDesc ~= "" then
				return numDesc
			end
		end

		return LuaUIUtils.getConditionUnlockDesc(commodityInfo.condition)
	end

	function LuaUIUtils.formatItemNum(needNum, ownNum, showLack)
		return LuaUIUtils.formatStyledItemNum(ownNum, needNum, nil, showLack)
	end

	function LuaUIUtils.renderShopBuyConsumeText(uText, costId, ownNum, consumeNum, style)
		local content, state

		consumeNum = consumeNum or 0

		if consumeNum > 0 then
			if ownNum < consumeNum then
				style = 0
			end

			state = UIConst.ITEM_STATE_COLOR[style]
		end

		local costIcon = LuaUIUtils.getItemShowText(costId)

		if string.isNilOrEmpty(state) then
			content = string.format("%s %s%s", costIcon, ClientTextUtils.formatSeparatedNumber(consumeNum), formatUnbreakableDenominator(ClientTextUtils.formatSeparatedNumber(ownNum)))
		else
			content = string.format("%s <style=%s>%s</style>%s", costIcon, state, ClientTextUtils.formatSeparatedNumber(consumeNum), formatUnbreakableDenominator(ClientTextUtils.formatSeparatedNumber(ownNum)))
		end

		ClientTextUtils.setText(uText, content)
	end

	function LuaUIUtils.parseCostDataToIpairs(data)
		local ret = {}

		if not data or not next(data) then
			return ret
		end

		for k, v in pairs(data) do
			table.insert(ret, {
				k,
				v
			})
		end

		return ret
	end

	function LuaUIUtils.setItemProp176ListData(ipairesRefundItems)
		local ret = {}

		if not ipairesRefundItems or not next(ipairesRefundItems) then
			return ret
		end

		local ret = {}

		for _, item in ipairs(ipairesRefundItems) do
			local itemSimpleInfo = ItemUtils.getItemSimpleInfo(item[1], item[2])

			ret[#ret + 1] = itemSimpleInfo
		end

		return ret
	end

	function LuaUIUtils.refreshItemProp176(item, index, data)
		function item.luaClick()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			else
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					checkTouchBegin = false,
					addSibling = 1,
					id = data.itemId,
					num = data.itemCount,
					targetRect = item,
					rayCastParent = item
				})
			end
		end

		item.draggable = false

		local itemNum = data.itemCount
		local objectReference = item:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local buttonUpUButton = objectReference:GetRefValue("buttonUpUButton")
		local itemLableUContainer = objectReference:GetRefValue("itemLableUContainer")

		item:TryChangePage("Quality", data.quality)
		ClientTextUtils.setText(txtNameUText, tostring(itemNum))

		iconUImage.url = data.icon

		if NotNil(buttonUpUButton) then
			buttonUpUButton:SetActive(false)
		end

		if itemLableUContainer then
			itemLableUContainer:SetActive(false)
		end
	end

	function LuaUIUtils.getPropDecomposeNum(data, count)
		if not data or not ToBool(count) then
			return 0
		end

		local itemId = data.itemId or data.id

		if ItemUtils.isEquip(itemId) then
			local func = FormulaData[Const.FormulaId.RobEggEquipPrice]
			local equipCfg = RobEggEquipData[itemId]

			if func and equipCfg then
				local cur, max = 0, 0

				if data.packSlot then
					cur, max = data.packSlot:getDurability()
				elseif data.props and data.props.equipData then
					cur, max = data.props.equipData.durability, data.props.equipData.maxDurability
				end

				local realRewardCount = func.formula(count, max, equipCfg.durabilityMax, cur)

				return math.ceil(realRewardCount)
			end
		elseif ItemUtils.isRepairKit(itemId) then
			local func = FormulaData[Const.FormulaId.RobEggRepairKitPrice]

			if func then
				local cur, max = 0, 0

				if data.packSlot then
					cur, max = data.packSlot:getRepairValue()
				elseif data.props and data.props.chipRepairKit then
					cur, max = data.props.chipRepairKit.repairValue, data.props.chipRepairKit.maxRepairValue
				end

				local realRewardCount = func.formula(count, cur, max)

				return math.ceil(realRewardCount)
			end
		elseif ItemUtils.isRefineable(itemId) then
			local item = data.packSlot or data
			local antiqueData = item.props and item.props[ItemConst.ItemPropertyDef.AntiqueData]
			local rankCfg = antiqueData and RobEggCollectionCalcineRankData[antiqueData.degree]

			if rankCfg then
				return math.ceil(count * (rankCfg.doubleMul or 1))
			end
		end

		return count
	end
end
