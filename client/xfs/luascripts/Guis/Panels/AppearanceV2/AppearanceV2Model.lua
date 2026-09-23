-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\AppearanceV2Model.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local ClientModelUtils = require("Utils.ClientModelUtils")
local HandheldAppearanceUIUtils = require("Utils.HandheldAppearanceUIUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local AppearanceData = require("Data.appearance_data")
local AppearancePointData = require("Data.appearance_point_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarAccessoryClassifyData = require("Data.Avatar.avatar_accessory_classify_data")
local ColorAccessoryData = require("Data.appearance_color_jewelry_data")
local AccessoryData = require("Data.appearance_jewelry_pet_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local ItemData = require("Data.item_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local PetAccessoryTransformData = require("Data.pet_accessory_transform_data")
local AttachPointData = require("Data.pet_appearance_point_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AppearanceJewelryPointData = require("Data.appearance_jewelry_point_data")
local PetData = require("Data.pet_data")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local AppearanceV2Model = Class.LightClass("AppearanceV2Model", UIModel)
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local EnergyMatchAccessoriesData = require("Data.energy_match_accessories_data")
local GameConst = CS.FunPlus.WorldX.Const.GameConst
local PET_ACCESSORY_BONE_ROOT = "_BoneRoot"
local APPEARANCE_TYPE_PERIPHERAL = 5

AppearanceV2Model.PET_ACCESSORY_ADJUST_MODE = {
	SIMPLE = 1,
	ADVANCED = 2
}

local function clampToRange(value, rangeA, rangeB)
	local minValue = math.min(rangeA, rangeB)
	local maxValue = math.max(rangeA, rangeB)

	return math.max(minValue, math.min(maxValue, value))
end

local function isPlayerOwnAppearanceItem(itemId)
	if not itemId or not pg.me then
		return false
	end

	if pg.me.itemCountBindMap and ItemUtils.getItemCountById(pg.me, itemId, true) > 0 then
		return true
	end

	local appearanceInfo = pg.me.appearanceInfo

	if AppearanceData[itemId] then
		return appearanceInfo and appearanceInfo[itemId] ~= nil
	end

	local suitData = AppearanceSuitData[itemId]

	if suitData then
		if not appearanceInfo then
			return false
		end

		local partList = suitData.appearanceList or {}

		if #partList == 0 then
			return false
		end

		for _, partId in ipairs(partList) do
			if not appearanceInfo[partId] then
				return false
			end
		end

		return true
	end

	if AvatarHairSuitData[itemId] then
		return LuaUIUtils.isHairSuitClaimed(pg.me, itemId)
	end

	if AppearanceJewelryPetData[itemId] then
		return ItemUtils.getItemCountById(pg.me, itemId, true) > 0
	end

	return false
end

AppearanceV2Model.RIGHT_INFO_CMP_STATE_PAGE_INDEX = {
	Detail = 2,
	Edit = 1,
	Normal = 0,
	Colorful = 4,
	Preset = 3
}

function AppearanceV2Model:getCurrencyData(itemIdList)
	local res = {}

	for _, itemId in ipairs(itemIdList) do
		res[#res + 1] = {
			count = ItemUtils.getItemCountById(pg.me, itemId),
			icon = LuaUIUtils.getIconByItemId(itemId)
		}
	end

	return res
end

function AppearanceV2Model:getTitleTabList()
	local res = {}

	table.insert(res, {
		tIndex = 0,
		componentName = "player",
		controller = 0,
		text = "ROLE"
	})

	local defaultPetId = pg.me:getAvatarFirstOrDefaultPetId()

	if not string.isNilOrEmpty(defaultPetId) then
		table.insert(res, {
			tIndex = 1,
			componentName = "pet",
			controller = 1,
			text = "PET"
		})
	end

	table.insert(res, {
		tIndex = 1,
		componentName = "workShopHome",
		controller = 2,
		text = "DESIGN"
	})
	table.insert(res, {
		tIndex = 2,
		componentName = "photoStudioEdit",
		controller = 3,
		text = "PHOTO_STUDIO"
	})

	return res
end

function AppearanceV2Model:isAppearanceVisible(id)
	if ClientCashShopUtils.isAppearanceReleaseTimeOpen(id) then
		return true
	end

	return isPlayerOwnAppearanceItem(id)
end

function AppearanceV2Model:getPeripheralConfig(id)
	local source = id and AppearanceData[id]

	if not source or source.type ~= APPEARANCE_TYPE_PERIPHERAL then
		return nil
	end

	local config = {}

	for key, value in pairs(source) do
		config[key] = value
	end

	config.id = id

	local item = ItemData[id] or {}

	config.icon = config.icon and config.icon ~= "" and config.icon or item.icon
	config.name = item.itemName or ""
	config.desc = item.itemDes or ""
	config.quality = item.quality or 0

	return config
end

function AppearanceV2Model:getVisiblePeripheralConfigMap()
	local res = {}

	for id, source in pairs(AppearanceData) do
		if source.type == APPEARANCE_TYPE_PERIPHERAL then
			local showStatus = source.showStatus or 1
			local isOwned = isPlayerOwnAppearanceItem(id)

			if showStatus ~= 2 and (showStatus ~= 3 or isOwned) and self:isAppearanceVisible(id) then
				res[id] = self:getPeripheralConfig(id)
			end
		end
	end

	return res
end

function AppearanceV2Model:getPeripheralPointList(bodyType, equippedLookup)
	return HandheldAppearanceUIUtils.buildPointList(self:getVisiblePeripheralConfigMap(), AppearancePointData, bodyType, equippedLookup)
end

function AppearanceV2Model:getPeripheralInfoList(pointId, bodyType, equippedId, filterFunc)
	local res = HandheldAppearanceUIUtils.buildOptionList(self:getVisiblePeripheralConfigMap(), pointId, equippedId, bodyType, function(id)
		return isPlayerOwnAppearanceItem(id)
	end, function(id)
		return self:redDot_CheckOptionItemState({
			claimed = true,
			itemId = id
		})
	end)

	if not filterFunc then
		return res
	end

	local filtered = {}

	for _, info in ipairs(res) do
		if info.isEmpty or filterFunc(info) then
			filtered[#filtered + 1] = info
		end
	end

	return filtered
end

function AppearanceV2Model:getClothesEquipInfoList(customShow)
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local equipList = AvatarUtils.getClothPartList(customShow)
	local suitId
	local entity = avatarScene and avatarScene:getCurEntity() or pg.me

	if entity then
		suitId = LuaUIUtils.tryGetEquippedSuitId(entity, customShow)
	end

	table.insert(equipList, 1, {
		part = "Suit",
		state = suitId and LuaUIUtils.SLOT_STATE.HAVE or LuaUIUtils.SLOT_STATE.EMPTY,
		suitId = suitId,
		slotIcon = LuaUIUtils.getClothesSlotIcon(),
		icon = suitId and ItemData[suitId].icon or nil,
		quality = suitId and ItemData[suitId].quality or nil,
		text = pg.getGameString("APPEARANCE_SUIT")
	})

	return equipList
end

function AppearanceV2Model:getSuitList(bodyType, forceFirstSuitId, filterFunc, displaySuitId)
	local res = {}
	local suitIdInWear = displaySuitId

	if not suitIdInWear then
		local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

		if avatarScene then
			suitIdInWear = avatarScene:getCurSuitId(avatarScene:getCurEntityId())
		end

		if not suitIdInWear then
			local entity = avatarScene and avatarScene:getCurEntity() or pg.me

			suitIdInWear = LuaUIUtils.tryGetEquippedSuitId(entity)
		end
	end

	for id, suitData in pairs(AppearanceSuitData) do
		if AvatarUtils.isValid(suitData, bodyType) then
			local suitInfo = LuaUIUtils.getSuitInfo(pg.me, id, suitIdInWear == id)

			suitInfo.state = suitInfo.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or suitInfo.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED

			local isVisible = false
			local partList = suitData.appearanceList or {}

			for _, clothesId in ipairs(partList) do
				local cfg = AppearanceData[clothesId] or {}
				local showStatus = cfg.showStatus or 1

				if showStatus == 1 then
					isVisible = true

					break
				elseif showStatus == 3 then
					local clothesInfo = LuaUIUtils.getClothesInfo(pg.me, clothesId)

					if clothesInfo and clothesInfo.claimed then
						isVisible = true

						break
					end
				end
			end

			if isVisible and self:isAppearanceVisible(id) and (filterFunc == nil or filterFunc(suitInfo) == true) then
				res[#res + 1] = suitInfo
			end
		end
	end

	table.sort(res, function(a, b)
		if a.equipped ~= b.equipped then
			return a.equipped
		elseif a.claimed ~= b.claimed then
			return a.claimed
		end

		local aq = a.quality or 0
		local bq = b.quality or 0

		if aq ~= bq then
			return bq < aq
		end

		local aid = a.suitId or a.itemId or 0
		local bid = b.suitId or b.itemId or 0

		return bid < aid
	end)

	if forceFirstSuitId then
		local index, info

		for i, clothesInfo in ipairs(res) do
			if clothesInfo.suitId == forceFirstSuitId then
				index = i
				info = clothesInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	for _, data in ipairs(res) do
		data.showRedDot = self:redDot_CheckClothesSuitOptionItemState(data)
	end

	return res
end

function AppearanceV2Model:getClothesInfoList(slotId, bodyType, forceFirstClothesId, filterFunc)
	local params = {
		slotId = slotId,
		bodyType = bodyType,
		orderBy = function(a, b)
			if a.equipped ~= b.equipped then
				return a.equipped
			elseif a.claimed ~= b.claimed then
				return a.claimed
			end

			local aq = a.quality or 0
			local bq = b.quality or 0

			if aq ~= bq then
				return bq < aq
			end

			local aid = a.clothesId or a.itemId or 0
			local bid = b.clothesId or b.itemId or 0

			return bid < aid
		end,
		forceFirstClothesId = forceFirstClothesId,
		filterFunc = filterFunc
	}
	local res = AvatarUtils.getClothesInfoList(params)
	local filtered = {}

	for _, data in ipairs(res) do
		local cfg = AppearanceData[data.clothesId] or AppearanceData[data.itemId] or {}
		local itemId = data.clothesId or data.itemId
		local showStatus = cfg.showStatus or 1

		if showStatus ~= 2 and self:isAppearanceVisible(itemId) and (showStatus ~= 3 or data.claimed) then
			filtered[#filtered + 1] = data
		end
	end

	res = filtered

	for _, data in ipairs(res) do
		data.showRedDot = self:redDot_CheckOptionItemState(data)
	end

	return res
end

function AppearanceV2Model:getAccessoryEquipInfoList()
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local slotList = {}
	local entity = avatarScene:getCurEntity()

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if LuaUIUtils.isAppearancePointHidden(slotId) then
			-- block empty
		elseif pg.me.curShow.customShow[slotId] == nil then
			slotList[#slotList + 1] = {
				state = LuaUIUtils.SLOT_STATE.LOCKED,
				costItemId = AppearancePointData[slotId].costType,
				costNum = AppearancePointData[slotId].costNum,
				slotId = slotId
			}

			break
		else
			local accessoryId = pg.me.curShow.customShow[slotId]

			if avatarScene then
				accessoryId = entity:getAppearanceConfigId(slotId)
			end

			local accessoryInfo = LuaUIUtils.getAccessoryInfo(entity, accessoryId)

			slotList[#slotList + 1] = {
				state = accessoryId == 0 and LuaUIUtils.SLOT_STATE.EMPTY or LuaUIUtils.SLOT_STATE.HAVE,
				icon = accessoryInfo.icon,
				quality = accessoryInfo.quality,
				accessoryId = accessoryId,
				slotId = slotId,
				slotIcon = AppearancePointData[slotId].icon,
				text = AppearancePointData[slotId].text
			}
		end
	end

	return slotList
end

function AppearanceV2Model:getAccessoryInfoList(bodyType, forceFirstAccessoryId, filterFunc)
	local res = {}
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local entity = avatarScene:getCurEntity()

	for id, appearanceData in pairs(AppearanceData) do
		if LuaUIUtils.isAccessory(appearanceData.type) then
			local showStatus = appearanceData.showStatus or 1

			if showStatus ~= 2 and AvatarUtils.isValid(appearanceData, bodyType) and self:isAppearanceVisible(id) then
				local accessoryInfo = LuaUIUtils.getAccessoryInfo(entity, id)

				accessoryInfo.reactionKey, accessoryInfo.kindKey = self:getReactionKeyAndKindKey(id, entity.eModel.modelView.modelInfo)

				if (showStatus ~= 3 or accessoryInfo.claimed) and (filterFunc == nil or filterFunc(accessoryInfo) == true) then
					res[#res + 1] = accessoryInfo
				end
			end
		end
	end

	table.sort(res, function(a, b)
		if a.equipped ~= b.equipped then
			return a.equipped
		elseif a.claimed ~= b.claimed then
			return a.claimed
		end

		local aq = a.quality or 0
		local bq = b.quality or 0

		if aq ~= bq then
			return bq < aq
		end

		local aid = a.accessoryId or a.itemId or 0
		local bid = b.accessoryId or b.itemId or 0

		return bid < aid
	end)

	if forceFirstAccessoryId then
		local index, info

		for i, accessoryInfo in ipairs(res) do
			if accessoryInfo.accessoryId == forceFirstAccessoryId then
				index = i
				info = accessoryInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	for _, data in ipairs(res) do
		data.showRedDot = self:redDot_CheckOptionItemState(data)
	end

	return res
end

function AppearanceV2Model:getConfig(presetKey)
	local accessoryPresetKey = AvatarUtils.getPartAssetIdByPreset(presetKey, "makeup")

	if not accessoryPresetKey then
		return {}
	end

	local AvatarMakeUpData = require(string.format("Data.Avatar.accessory.accessory_%s_data", accessoryPresetKey))

	return AvatarMakeUpData or {}
end

function AppearanceV2Model:getReaction(originConfig, reactionKey)
	for _, kindData in pairs(originConfig) do
		local reactionList = kindData.reactionList or {}

		for _, reactionData in ipairs(reactionList) do
			if reactionData.key == reactionKey then
				local res = Utils.deepCopyTable(reactionData)

				res.kindDisplayName = kindData.displayName
				res.kindKey = kindData.key

				return res
			end
		end
	end
end

function AppearanceV2Model:getReactionKeyAndKindKey(accessoryId, modelInfo)
	return ClientModelUtils.getAccessoryReactionKeyAndKindKey(accessoryId, modelInfo:GetMakeUpPartAssetId())
end

function AppearanceV2Model:isColorAccessoryWear(accessoryId, colorAccessoryId)
	local wearSlot = -1

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if pg.me.curShow.customShow[slotId] == accessoryId then
			wearSlot = slotId

			break
		end
	end

	local wearColorJewelryId = pg.me.curShow[wearSlot] and pg.me.curShow[wearSlot].colorJewelryId or 0

	return wearColorJewelryId == colorAccessoryId
end

function AppearanceV2Model:getColorAccessoryList(accessoryId)
	local res = {}

	if not accessoryId then
		return res
	end

	for id, data in pairs(ColorAccessoryData) do
		if data.originalJewelryId == accessoryId then
			local isClaimed = pg.me.colorJewelryIds and pg.me.colorJewelryIds[id] == true
			local itemInfo = ItemData[id] or {}
			local info = {
				id = id,
				petTemplateId = data.templateId,
				res = data.res,
				icon = itemInfo.icon,
				isLock = not isClaimed,
				isWear = self:isColorAccessoryWear(accessoryId, id)
			}

			info.showRedDot = self:redDot_CheckColorAccessoryItemState(info)

			table.insert(res, info)
		end
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)

	return res
end

function AppearanceV2Model:clearCacheHairSuitId()
	self.cacheHairSuitId = nil
end

function AppearanceV2Model:getHairEquipInfoList()
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local entity = avatarScene:getCurEntity()
	local res = {}
	local suitId = LuaUIUtils.tryGetEntityHairSuitId(entity)
	local isNoSuit = true

	for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local configId = pg.me.curShow.customShow[slotId]

		if avatarScene then
			configId = entity:getAppearanceConfigId(slotId)
		end

		if configId and configId ~= 0 then
			isNoSuit = false

			break
		end
	end

	if isNoSuit then
		suitId = self.cacheHairSuitId
	else
		self.cacheHairSuitId = suitId
	end

	local itemData = ItemData[suitId] or {}

	table.insert(res, {
		part = "Suit",
		state = suitId and LuaUIUtils.SLOT_STATE.HAVE or LuaUIUtils.SLOT_STATE.EMPTY,
		id = suitId,
		slotIcon = LuaUIUtils.getHairSlotIcon(),
		icon = suitId and itemData.icon or nil,
		quality = suitId and itemData.quality or nil,
		text = pg.getGameString("CREATE_PLAYER_HAIR_WHOLE")
	})

	local validPartIdList = {}
	local hairSuitInfo = AvatarHairSuitData[suitId] or {}

	if hairSuitInfo.appearanceList then
		for _, configId in ipairs(hairSuitInfo.appearanceList) do
			local data = AppearanceData[configId] or {}
			local partId = data.partId

			if partId then
				validPartIdList[partId] = true
			end
		end
	end

	for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		if validPartIdList[slotId] then
			local configId = pg.me.curShow.customShow[slotId]

			if avatarScene then
				local entity = avatarScene:getCurEntity()

				configId = entity:getAppearanceConfigId(slotId)
			end

			if configId then
				local info = LuaUIUtils.getHairPartInfo(pg.me, configId)

				res[#res + 1] = {
					state = configId == 0 and LuaUIUtils.SLOT_STATE.EMPTY or LuaUIUtils.SLOT_STATE.HAVE,
					id = configId,
					icon = info.icon,
					quality = info.quality,
					slotId = slotId,
					part = AppearancePointData[slotId].name,
					slotIcon = LuaUIUtils.getHairSlotIcon(slotId),
					text = AppearancePointData[slotId].text
				}
			else
				res[#res + 1] = {
					state = LuaUIUtils.SLOT_STATE.LOCKED,
					costItemId = AppearancePointData[slotId].costType,
					costNum = AppearancePointData[slotId].costNum,
					slotId = slotId,
					part = AppearancePointData[slotId].name,
					slotIcon = LuaUIUtils.getHairSlotIcon(slotId),
					text = AppearancePointData[slotId].text
				}
			end
		end
	end

	return res
end

function AppearanceV2Model:getHairSuitList(bodyType, forceFirstSuitId, filterFunc, customShow)
	local res = {}

	for id, suitData in pairs(AvatarHairSuitData) do
		if AvatarUtils.isValid(suitData, bodyType) then
			local suitInfo = LuaUIUtils.getHairSuitInfo(pg.me, id, customShow)
			local isVisible = false
			local partList = suitData.appearanceList or {}

			for _, cfgId in ipairs(partList) do
				local cfg = AppearanceData[cfgId] or {}
				local showStatus = cfg.showStatus or 1

				if showStatus == 1 then
					isVisible = true

					break
				elseif showStatus == 3 then
					local partInfo = LuaUIUtils.getHairPartInfo(pg.me, cfgId, customShow)

					if partInfo and partInfo.claimed then
						isVisible = true

						break
					end
				end
			end

			if isVisible and self:isAppearanceVisible(id) and (filterFunc == nil or filterFunc(suitInfo) == true) then
				res[#res + 1] = suitInfo
			end
		end
	end

	table.sort(res, function(a, b)
		if a.equipped ~= b.equipped then
			return a.equipped
		elseif a.claimed ~= b.claimed then
			return a.claimed
		end

		local aq = a.quality or 0
		local bq = b.quality or 0

		if aq ~= bq then
			return bq < aq
		end

		local aid = a.id or a.itemId or 0
		local bid = b.id or b.itemId or 0

		return bid < aid
	end)

	if forceFirstSuitId then
		local index, info

		for i, clothesInfo in ipairs(res) do
			if clothesInfo.suitId == forceFirstSuitId then
				index = i
				info = clothesInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	for _, data in ipairs(res) do
		data.showRedDot = self:redDot_CheckHairSuitOptionItemState(data)
	end

	table.insert(res, 1, {
		itemId = -1,
		state = LuaUIUtils.SELECT_STATE.NULL
	})

	return res
end

function AppearanceV2Model:getHairPartList(slotId, equippedHairId, bodyType, forceFirstClothesId, filterFunc, customShow)
	local res = {}

	for id, hairPartData in pairs(AppearanceData) do
		if LuaUIUtils.isHair(hairPartData.type) then
			local showStatus = hairPartData.showStatus or 1

			if showStatus ~= 2 and AvatarUtils.isValid(hairPartData, bodyType) and hairPartData.hairId == equippedHairId and self:isAppearanceVisible(id) then
				local hairPartInfo = LuaUIUtils.getHairPartInfo(pg.me, id, customShow)

				if hairPartInfo.partId == slotId and (showStatus ~= 3 or hairPartInfo.claimed) and (filterFunc == nil or filterFunc(hairPartInfo) == true) then
					res[#res + 1] = hairPartInfo
				end
			end
		end
	end

	table.sort(res, function(a, b)
		if a.equipped ~= b.equipped then
			return a.equipped
		elseif a.claimed ~= b.claimed then
			return a.claimed
		end

		local aq = a.quality or 0
		local bq = b.quality or 0

		if aq ~= bq then
			return bq < aq
		end

		local aid = a.id or a.itemId or 0
		local bid = b.id or b.itemId or 0

		return bid < aid
	end)

	if forceFirstClothesId then
		local index, info

		for i, hairInfo in ipairs(res) do
			if hairInfo.id == forceFirstClothesId then
				index = i
				info = hairInfo

				break
			end
		end

		if index then
			table.remove(res, index)
			table.insert(res, 1, info)
		end
	end

	if slotId ~= GameConst.PART_HAIR_BODY then
		table.insert(res, 1, {
			state = LuaUIUtils.SELECT_STATE.NULL
		})
	end

	return res
end

AppearanceV2Model.Operation = {
	operations = {
		{
			displayName = 55295756,
			subOps = {
				{
					displayName = 59381762,
					minValue = -200,
					opName = 1,
					maxValue = 200,
					tIndex = 0
				},
				{
					displayName = 56026640,
					minValue = -200,
					opName = 2,
					maxValue = 200,
					tIndex = 0
				},
				{
					displayName = 47151758,
					minValue = -200,
					opName = 3,
					maxValue = 200,
					tIndex = 0
				}
			}
		},
		{
			displayName = 41352984,
			subOps = {
				{
					displayName = 57605298,
					minValue = -200,
					opName = 5,
					maxValue = 200,
					tIndex = 0
				},
				{
					displayName = 35417729,
					minValue = -200,
					opName = 6,
					maxValue = 200,
					tIndex = 0
				},
				{
					displayName = 41352984,
					minValue = -200,
					opName = 7,
					maxValue = 200,
					tIndex = 0
				}
			}
		},
		{
			displayName = 65641329,
			subOps = {
				{
					displayName = 65641329,
					minValue = 5,
					opName = 8,
					maxValue = 0.1,
					tIndex = 0
				}
			}
		}
	}
}

function AppearanceV2Model:ctor()
	self.cacheOperation = {}
	self.operationDATAS = {}
	self.operationStack = nil
	self.operationStackIndex = 0
	self.selectTabIndex = nil
	self.adjustPetProId = nil
	self.adjustPetCurId = nil
	self.petAccessoryPointList = nil
	self.petAccessoryAdjustMode = nil
	self.operationSliderInfo = nil
	self.operationDefaultScale = nil
	self.tabDataList = nil
	self.accessDataList = nil
	self.tryTabDataList = {}
end

function AppearanceV2Model:setPetProId(petId)
	local pInfo = pg.me:getPetInfo(petId)

	self.adjustPetCurId = petId
	self.adjustPetProId = pInfo.petPrototypeId

	self:buildPetAccessoryPointList()

	local res = {
		scale = 1,
		offset = {}
	}
	local cData = PetAccessoryTransformData[pInfo.templateId]

	if cData and cData.modelPos and #cData.modelPos >= 3 then
		res.offset = Vector3.New(cData.modelPos[1], cData.modelPos[2], cData.modelPos[3])
		res.scale = cData.scale or 1
	else
		res.offset = Vector3.constZero
	end

	return res
end

function AppearanceV2Model:buildPetAccessoryPointList()
	local sourceList = AppearanceJewelryPointData[self.adjustPetProId]
	local pointList = {
		{
			name = "APPEARANCE_PET_ACCESSORY_DEFAULT_POINT",
			index = 1,
			isDefault = true
		}
	}

	if sourceList then
		for _, point in ipairs(sourceList) do
			local offset = point.offset

			if point.boneName and offset and #offset >= 3 then
				local index = #pointList + 1

				pointList[#pointList + 1] = {
					index = index,
					name = point.name,
					boneName = point.boneName,
					offset = Vector3.New(offset[1], offset[2], offset[3])
				}
			end
		end
	end

	self.petAccessoryPointList = pointList
end

function AppearanceV2Model:getPetAccessoryPointList()
	return self.petAccessoryPointList
end

function AppearanceV2Model:hasPetAccessorySimpleMode()
	return self.petAccessoryPointList ~= nil and #self.petAccessoryPointList > 0
end

function AppearanceV2Model:getPetAccessoryAdjustMode()
	return self.petAccessoryAdjustMode
end

function AppearanceV2Model:isPetAccessorySimpleMode()
	return self.petAccessoryAdjustMode == self.PET_ACCESSORY_ADJUST_MODE.SIMPLE
end

function AppearanceV2Model:getSelectedPetAccessoryPointIndex()
	return self.operationDATAS.simplePointIndex
end

function AppearanceV2Model:getPetAccessoryPointWorldPosition(index)
	local pointList = self.petAccessoryPointList
	local point = pointList and pointList[index]
	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView

	if point == nil or point.boneName == nil or point.offset == nil or modelView == nil then
		return false, nil
	end

	return modelView:TryGetAttachPointWorldPosition(point.boneName, point.offset)
end

function AppearanceV2Model:updatePetAccessoryDefaultPoint(defaultAttachInfo, modelView)
	local pointList = self.petAccessoryPointList
	local defaultPoint = pointList and pointList[1]

	if defaultPoint == nil or not defaultPoint.isDefault or defaultAttachInfo == nil or defaultAttachInfo.localPosition == nil or defaultAttachInfo.localRotation == nil then
		return
	end

	local boneName = defaultAttachInfo.attachHp or defaultAttachInfo.attachBone

	if boneName == nil or boneName == "" then
		boneName = PET_ACCESSORY_BONE_ROOT
	end

	local localPosition = defaultAttachInfo.localPosition
	local localRotation = defaultAttachInfo.localRotation
	local localScale = defaultAttachInfo.scale or self:getPetAccessoryDefaultScale()
	local rootPosition = localPosition
	local rootRotation = localRotation
	local rootScale = localScale

	if modelView and boneName ~= PET_ACCESSORY_BONE_ROOT then
		local success

		success, rootPosition, rootRotation, rootScale = modelView:TryConvertAttachBoneLocalToRoot(boneName, localPosition, localRotation, localScale)

		if not success then
			rootPosition = modelView:GetTransformPositionReverse(boneName, localPosition, localRotation, localScale)
			rootRotation = modelView:GetTransformRotationReverse(boneName, localPosition, localRotation, localScale)
			rootScale = modelView:GetTransformScaleReverse(boneName, localPosition, localRotation, localScale)
		end
	end

	defaultPoint.boneName = PET_ACCESSORY_BONE_ROOT
	defaultPoint.offset = Vector3.New(rootPosition.x, rootPosition.y, rootPosition.z)
	defaultPoint.rotation = Vector3.New(rootRotation.x, rootRotation.y, rootRotation.z)
	defaultPoint.scale = rootScale
end

function AppearanceV2Model:getUnlockedSlotCount(petPrototypeId)
	if not petPrototypeId then
		return 1
	end

	local baseId = Utils.getBasePetPrototypeId(petPrototypeId)

	if baseId == 0 then
		baseId = petPrototypeId
	end

	local pointMap = pg.me.petJewelryPoint

	if pointMap and pointMap[baseId] then
		return pointMap[baseId]
	end

	return 1
end

function AppearanceV2Model:getSlotCount()
	return self:getUnlockedSlotCount(self.adjustPetProId)
end

function AppearanceV2Model:initTabDataList()
	local tabList = {}

	if self.adjustPetProId == nil then
		return tabList
	end

	local unlockedCount = self:getUnlockedSlotCount(self.adjustPetProId)

	for i, v in ipairs(AttachPointData) do
		local item = {
			isPreview = false,
			state = i <= unlockedCount and LuaUIUtils.SLOT_STATE.EMPTY_NO_WORD or LuaUIUtils.SLOT_STATE.LOCKED,
			text = tostring(i),
			tabIndex = i,
			costNum = v.costNum,
			costItemId = v.costType,
			unlockCost = {
				id = v.costType,
				num = v.costNum,
				ownNum = ItemUtils.getItemCountById(pg.me, v.costType),
				icon = LuaUIUtils.getIconByItemId(v.costType),
				name = LuaUIUtils.getNameByItemId(v.costType)
			}
		}

		self:refreshTabInfo(item)

		tabList[i] = item

		if item.state == LuaUIUtils.SLOT_STATE.LOCKED then
			break
		end
	end

	self.tabDataList = tabList
end

function AppearanceV2Model:addNewTabToDataList()
	local index = #self.tabDataList + 1
	local v = AttachPointData[index]

	if v == nil then
		return
	end

	local item = {
		isPreview = false,
		state = LuaUIUtils.SLOT_STATE.LOCKED,
		name = tostring(index),
		tabIndex = index,
		unlockCost = {
			id = v.costType,
			num = v.costNum,
			ownNum = ItemUtils.getItemCountById(pg.me, v.costType),
			icon = LuaUIUtils.getIconByItemId(v.costType),
			name = LuaUIUtils.getNameByItemId(v.costType)
		}
	}

	self:refreshTabInfo(item)

	self.tabDataList[index] = item
end

function AppearanceV2Model:getTabList()
	return self.tabDataList
end

function AppearanceV2Model:equipTryAccessData(tabIndex)
	if self.selectItemData and self.selectItemData.isTry then
		self.tryTabDataList[tabIndex] = self.selectItemData
		self.tryTabDataList[tabIndex].tabIndex = tabIndex
	end
end

function AppearanceV2Model:getTryAccessData()
	local accessData = {}

	for _, data in pairs(self.tryTabDataList) do
		if data then
			table.insert(accessData, data)
		end
	end

	return accessData
end

function AppearanceV2Model:dropTryAccessData(tabIndex)
	self.tryTabDataList[tabIndex] = nil
end

function AppearanceV2Model:clearTryAccessData()
	self.tryTabDataList = {}
end

function AppearanceV2Model:getTabInTabDataList(slot)
	if self.tabDataList == nil then
		return false
	end

	for _, v in ipairs(self.tabDataList) do
		if v.tabIndex == slot then
			return v
		end
	end

	return false
end

function AppearanceV2Model:refreshTabDataList()
	if self.tabDataList == nil then
		return
	end

	for _, v in ipairs(self.tabDataList) do
		self:refreshTabInfo(v)
	end
end

function AppearanceV2Model:setPreviewData(tabInfo, isPreview, data)
	tabInfo.isPreview = isPreview
	data.isPreview = isPreview

	if isPreview then
		tabInfo.previewInstId = data.instanceId
	else
		tabInfo.previewInstId = nil
	end
end

function AppearanceV2Model:refreshTabInfo(tabInfo)
	local unlockedCount = self:getUnlockedSlotCount(self.adjustPetProId)

	tabInfo.isTry = false

	if unlockedCount >= tabInfo.tabIndex then
		local tryData = self.tryTabDataList[tabInfo.tabIndex]

		if tabInfo.isPreview then
			local data = self:getAccessDataInDataListWithInstId(tabInfo.previewInstId)

			if data then
				if tryData then
					if tryData.tabIndex == tabInfo.tabIndex then
						data = tryData
						tabInfo.icon = tryData.icon
						tabInfo.quality = tryData.quality
						tabInfo.isTry = true
					elseif tryData.instanceId == tabInfo.previewInstId then
						tabInfo.state = LuaUIUtils.SLOT_STATE.EMPTY_NO_WORD

						return
					end
				end

				tabInfo.preIcon = data.icon
				tabInfo.preQuality = data.quality
				tabInfo.state = LuaUIUtils.SLOT_STATE.HAVE
			else
				tabInfo.state = LuaUIUtils.SLOT_STATE.EMPTY_NO_WORD
			end
		else
			local petAccess = pg.me.petJewelryInfos[self.adjustPetCurId]

			if petAccess then
				local genId = petAccess.customShow[tabInfo.tabIndex]
				local data = self:getAccessDataInDataList(genId)

				if data then
					tabInfo.icon = data.icon
					tabInfo.quality = data.quality
					tabInfo.genId = genId
					tabInfo.state = LuaUIUtils.SLOT_STATE.HAVE
				elseif tryData then
					tabInfo.icon = tryData.icon
					tabInfo.quality = tryData.quality
					tabInfo.genId = genId
					tabInfo.state = LuaUIUtils.SLOT_STATE.HAVE
					tabInfo.isTry = true
				else
					tabInfo.genId = nil
					tabInfo.state = LuaUIUtils.SLOT_STATE.EMPTY_NO_WORD
				end
			elseif tryData then
				tabInfo.icon = tryData.icon
				tabInfo.quality = tryData.quality
				tabInfo.state = LuaUIUtils.SLOT_STATE.HAVE
				tabInfo.isTry = true
			else
				tabInfo.genId = nil
				tabInfo.state = LuaUIUtils.SLOT_STATE.EMPTY_NO_WORD
			end
		end
	else
		tabInfo.genId = nil
		tabInfo.state = LuaUIUtils.SLOT_STATE.LOCKED
	end
end

function AppearanceV2Model:initAccessDataList(vitalityPhase, vitalityThemeId)
	local res = {}
	local tmpIds = {}
	local allAccess = self:getAllAccessInBag()

	for i, v in ipairs(allAccess) do
		local cfg = AccessoryData[v.id] or {}
		local showStatus = cfg.showStatus or 1

		if showStatus ~= 2 and self:isAppearanceVisible(v.id) then
			local item = self:getAccessoryInfo(v.id)

			item.genId = v.genID
			item.orderIdx = i
			item.owner = true

			self:refreshAccessInfo(item)

			res[#res + 1] = item

			if not table.contains(tmpIds, v.id) then
				tmpIds[#tmpIds + 1] = v.id
			end
		end
	end

	if vitalityPhase and vitalityThemeId then
		local themeData = EnergyMatchThemeData[vitalityPhase][vitalityThemeId]

		if themeData then
			for _, accessoryId in ipairs(themeData.accessoryTry) do
				if not table.contains(tmpIds, accessoryId) then
					local idx = #res + 1
					local item = self:getAccessoryInfo(accessoryId)

					item.owner = true
					item.orderIdx = idx

					self:refreshAccessInfo(item)

					item.state = LuaUIUtils.SELECT_STATE.TRY
					item.isTry = true
					res[idx] = item
					tmpIds[#tmpIds + 1] = accessoryId
				end
			end
		end
	end

	for id, accessoryData in pairs(AccessoryData) do
		local showStatus = accessoryData.showStatus or 1

		if showStatus == 1 and self:isAppearanceVisible(id) and not table.contains(tmpIds, id) then
			local idx = #res + 1
			local item = self:getAccessoryInfo(id)

			item.owner = false
			item.orderIdx = idx

			self:refreshAccessInfo(item)

			res[idx] = item
		end
	end

	if vitalityPhase and vitalityThemeId then
		local themeData = EnergyMatchThemeData[vitalityPhase][vitalityThemeId]

		for _, accessoryInfo in pairs(res) do
			accessoryInfo.inVitality = true

			local score = ActivityUtils.caculateAccessories({
				accessoryInfo.accessoryId
			}, themeData, vitalityPhase, pg.me)

			accessoryInfo.vitalityScore = score

			local tagData = EnergyMatchAccessoriesData[accessoryInfo.accessoryId]
			local tagMatchCount = 0

			if tagData then
				for _, tagId in pairs(tagData.accessoryTag) do
					if table.contains(themeData.accessoryTheme, tagId) then
						tagMatchCount = tagMatchCount + 1
					end
				end
			end

			accessoryInfo.tagRateIcon = self:getAccessoryRateIcon(accessoryInfo.quality, tagMatchCount)
		end
	end

	self.accessDataList = res

	self:orderByAccesses()

	return res
end

function AppearanceV2Model:getAccessoryRateIcon(quality, tagMatchCount)
	local iconName = "$UI_Event_VitalityContest_"

	if quality == 5 and tagMatchCount == 2 then
		iconName = iconName .. "S"
	elseif quality == 4 and tagMatchCount == 2 then
		iconName = iconName .. "A"
	elseif quality == 5 and tagMatchCount == 1 then
		iconName = iconName .. "B"
	else
		iconName = iconName .. "C"
	end

	iconName = iconName .. ".png"

	return iconName
end

function AppearanceV2Model:orderByAccesses()
	if self.accessDataList == nil then
		return
	end

	table.sort(self.accessDataList, function(a, b)
		if a.owner ~= b.owner then
			return a.owner or false
		end

		local aq = a.quality or 0
		local bq = b.quality or 0

		if aq ~= bq then
			return bq < aq
		end

		local aid = a.accessoryId or 0
		local bid = b.accessoryId or 0

		return bid < aid
	end)
end

function AppearanceV2Model:getAccessDataInDataList(genId)
	if self.accessDataList == nil then
		return false
	end

	for _, v in ipairs(self.accessDataList) do
		if v.genId == genId then
			return v
		end
	end

	return false
end

function AppearanceV2Model:getAccessDataInDataListWithInstId(instanceId)
	if self.accessDataList == nil then
		return false
	end

	for _, v in ipairs(self.accessDataList) do
		if v.instanceId == instanceId then
			return v
		end
	end

	return false
end

function AppearanceV2Model:getAccessoryInfo(accessoryId)
	local accessoryData = AccessoryData[accessoryId] or {}
	local itemData = ItemData[accessoryId] or {}
	local res = {
		genId = 0,
		accessoryId = accessoryId or 0,
		icon = itemData.icon,
		name = pg.getLocalizationText(itemData.itemName),
		quality = itemData.quality,
		resId = accessoryData.res,
		state = LuaUIUtils.SELECT_STATE.LOCKED,
		fashion = accessoryData.fashion or 0
	}

	return res
end

function AppearanceV2Model:refreshAccessDataList()
	if self.accessDataList == nil then
		return
	end

	for _, v in ipairs(self.accessDataList) do
		self:refreshAccessInfo(v)
	end
end

function AppearanceV2Model:refreshAccessInfo(accessInfo)
	local v = self:checkAccessEquipped(accessInfo.genId)

	if v then
		accessInfo.state = LuaUIUtils.SELECT_STATE.PET_WEAR
		accessInfo.refPetId = v.petId
		accessInfo.slot = v.point
		accessInfo.instanceId = string.format("%d_%d", v.point, accessInfo.accessoryId)

		local petInfo = pg.me:getPetInfo(v.petId)

		accessInfo.refPetIcon = LuaUIUtils.getPetIcon(PetData[petInfo.templateId].iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
		accessInfo.showRedDot = self:redDot_CheckPetOptionItemState(accessInfo)
	else
		if accessInfo.state ~= LuaUIUtils.SELECT_STATE.TRY then
			accessInfo.state = accessInfo.genId == 0 and LuaUIUtils.SELECT_STATE.LOCKED or LuaUIUtils.SELECT_STATE.HAVE
		end

		accessInfo.refPetId = nil
		accessInfo.slot = nil
		accessInfo.instanceId = string.format("%d", accessInfo.accessoryId)
		accessInfo.refPetIcon = nil
		accessInfo.showRedDot = self:redDot_CheckPetOptionItemState(accessInfo)
	end

	local appearanceData = AppearanceJewelryPetData[accessInfo.accessoryId] or {}
	local resId = appearanceData.res

	if resId then
		local classifyData = AvatarAccessoryClassifyData[resId] or {}

		accessInfo.kind = classifyData.kind
	end
end

function AppearanceV2Model:filterAccesses(filterFunc)
	local res = {}

	for _, v in ipairs(self.accessDataList) do
		if filterFunc == nil or filterFunc(v) == true then
			res[#res + 1] = v
		end
	end

	return res
end

function AppearanceV2Model:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return pg.getLocalizationText(name)
end

function AppearanceV2Model:setAvatarScene(avatarScene)
	self.avatarScene = avatarScene
end

function AppearanceV2Model:setSelectTabIndex(tabIndex)
	self.selectTabIndex = tabIndex
end

function AppearanceV2Model:setSelectAccessData(data)
	self.selectItemData = data
end

function AppearanceV2Model:getSelectAccessInstanceId()
	return self.selectItemData.instanceId
end

function AppearanceV2Model:getSelectAccessData()
	return self.selectItemData
end

function AppearanceV2Model:setAccessTransWithOpName(v, opName)
	if opName == 1 then
		self:setAccessOffsetX(v)
	elseif opName == 2 then
		self:setAccessOffsetY(v)
	elseif opName == 3 then
		self:setAccessOffsetZ(v)
	elseif opName == 5 then
		self:setAccessRotateX(v)
	elseif opName == 6 then
		self:setAccessRotateY(v)
	elseif opName == 7 then
		self:setAccessRotateZ(v)
	elseif opName == 8 then
		self:setAccessScale(v)
	end
end

function AppearanceV2Model:getAccessTransWithOpName(opName, default)
	if opName == 1 then
		return self:getAccessOffsetX(default)
	elseif opName == 2 then
		return self:getAccessOffsetY(default)
	elseif opName == 3 then
		return self:getAccessOffsetZ(default)
	elseif opName == 5 then
		return self:getAccessRotateX(default)
	elseif opName == 6 then
		return self:getAccessRotateY(default)
	elseif opName == 7 then
		return self:getAccessRotateZ(default)
	elseif opName == 8 then
		return self:getAccessScale(default)
	end
end

function AppearanceV2Model:setAccessScale(v)
	self:setAccessScaleInternal(v)
	self:adjustTransform()
end

function AppearanceV2Model:setAccessScaleInternal(v)
	local accessInfo = self:getOperationData()

	accessInfo.curScale = v
end

function AppearanceV2Model:getAccessScale(default)
	local accessInfo = self:getOperationData()

	return accessInfo.curScale or default
end

function AppearanceV2Model:setAccessOffsetInternal(pos)
	self:setAccessOffset(pos.x, pos.y, pos.z)
end

function AppearanceV2Model:setAccessOffsetX(x)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	self:setAccessOffset(x, oldOffset.y, oldOffset.z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessOffsetX(default)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	if oldOffset == nil then
		return default
	end

	return oldOffset.x
end

function AppearanceV2Model:setAccessOffsetY(y)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	self:setAccessOffset(oldOffset.x, y, oldOffset.z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessOffsetY(default)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	if oldOffset == nil then
		return default
	end

	return oldOffset.y
end

function AppearanceV2Model:setAccessOffsetZ(z)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	self:setAccessOffset(oldOffset.x, oldOffset.y, z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessOffsetZ(default)
	local accessInfo = self:getOperationData()
	local oldOffset = accessInfo.curOffset

	if oldOffset == nil then
		return default
	end

	return oldOffset.z
end

function AppearanceV2Model:setAccessOffset(x, y, z)
	local accessInfo = self:getOperationData()

	if accessInfo.curOffset == nil then
		accessInfo.curOffset = Vector3.New(x, y, z)
	else
		accessInfo.curOffset:Set(x, y, z)
	end
end

function AppearanceV2Model:setAccessRotateInternal(rot)
	self:setAccessRotate(rot.x, rot.y, rot.z)
end

function AppearanceV2Model:setAccessRotateX(x)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	self:setAccessRotate(x, oldRotate.y, oldRotate.z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessRotateX(default)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	if oldRotate == nil then
		return default
	end

	return oldRotate.x
end

function AppearanceV2Model:setAccessRotateY(y)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	self:setAccessRotate(oldRotate.x, y, oldRotate.z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessRotateY(default)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	if oldRotate == nil then
		return default
	end

	return oldRotate.y
end

function AppearanceV2Model:setAccessRotateZ(z)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	self:setAccessRotate(oldRotate.x, oldRotate.y, z)
	self:adjustTransform()
end

function AppearanceV2Model:getAccessRotateZ(default)
	local accessInfo = self:getOperationData()
	local oldRotate = accessInfo.curRotate

	if oldRotate == nil then
		return default
	end

	return oldRotate.z
end

function AppearanceV2Model:setAccessRotate(x, y, z)
	local accessInfo = self:getOperationData()

	if accessInfo.curRotate == nil then
		accessInfo.curRotate = Vector3.New(x, y, z)
	else
		accessInfo.curRotate:Set(x, y, z)
	end
end

function AppearanceV2Model:setAccessAttachBone(attachBone)
	local accessInfo = self:getOperationData()

	accessInfo.attachBone = attachBone
end

function AppearanceV2Model:snapPetAccessoryToAttachPoint(boneName)
	if self:isPetAccessorySimpleMode() or string.isNilOrEmpty(boneName) then
		return false
	end

	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()
	local operationData = self.operationDATAS

	if modelView == nil or instanceId == nil or operationData.curOffset == nil or operationData.curRotate == nil or operationData.curScale == nil or not modelView:IsAttachBoneValid(boneName) then
		return false
	end

	local rootPosition = modelView:GetTransformPositionReverse(boneName, Vector3.zero, Vector3.zero, 1)

	operationData.curOffset = Vector3.New(rootPosition.x, rootPosition.y, rootPosition.z)
	operationData.attachBone = boneName

	modelView:RefreshAttachParent(instanceId, boneName)

	if not self:adjustTransform() then
		return false
	end

	self:recordOperationStep()

	return true
end

function AppearanceV2Model:getPetAccessoryPointByBoneName(boneName, modelView, rootPosition)
	local pointList = self.petAccessoryPointList

	if pointList == nil or boneName == nil then
		return nil
	end

	local nearestPoint, nearestDistance

	for _, point in ipairs(pointList) do
		if not point.isDefault and point.boneName == boneName then
			local success, pointPosition = modelView:TryConvertAttachBoneLocalToRoot(point.boneName, point.offset, point.rotation or Vector3.zero, 1)

			if success then
				local dx = rootPosition.x - pointPosition.x
				local dy = rootPosition.y - pointPosition.y
				local dz = rootPosition.z - pointPosition.z
				local distance = dx * dx + dy * dy + dz * dz

				if nearestDistance == nil or distance < nearestDistance then
					nearestPoint = point
					nearestDistance = distance
				end
			end
		end
	end

	return nearestPoint
end

function AppearanceV2Model:getSelectedPetAccessoryPoint()
	local pointList = self.petAccessoryPointList
	local index = self.operationDATAS.simplePointIndex

	return pointList and index and pointList[index]
end

function AppearanceV2Model:getPetAccessoryDefaultScale()
	if self.operationDefaultScale ~= nil then
		return self.operationDefaultScale
	end

	local sliderInfo = self.operationSliderInfo

	return sliderInfo and sliderInfo.defaultAccessScale or 1
end

function AppearanceV2Model:getSimplePetAccessoryRootTransform(modelView, operationData)
	local pointOffset = operationData.simplePointOffset
	local pointRotation = operationData.simplePointRotation or Vector3.zero
	local sliderOffset = operationData.curOffset
	local sliderRotation = operationData.curRotate

	if pointOffset == nil or sliderOffset == nil or sliderRotation == nil then
		return false
	end

	local success, rootPosition, _, rootScale = modelView:TryConvertAttachBoneLocalToRoot(operationData.attachBone, pointOffset, pointRotation, operationData.curScale)

	if not success then
		return false
	end

	rootPosition = Vector3.New(rootPosition.x + sliderOffset.x, rootPosition.y + sliderOffset.y, rootPosition.z + sliderOffset.z)

	return true, rootPosition, sliderRotation, rootScale
end

function AppearanceV2Model:clampSimplePetAccessoryTransform(localPosition, localRotation, localScale, pointOffset)
	local offset = Vector3.New(localPosition.x - pointOffset.x, localPosition.y - pointOffset.y, localPosition.z - pointOffset.z)
	local rotation = Vector3.New(localRotation.x, localRotation.y, localRotation.z)
	local scale = localScale
	local sliderInfo = self.operationSliderInfo

	if sliderInfo then
		offset:Set(clampToRange(offset.x, sliderInfo.minOffset.x, sliderInfo.maxOffset.x), clampToRange(offset.y, sliderInfo.minOffset.y, sliderInfo.maxOffset.y), clampToRange(offset.z, sliderInfo.minOffset.z, sliderInfo.maxOffset.z))
		rotation:Set(clampToRange(rotation.x, -sliderInfo.mapRotLength, sliderInfo.mapRotLength), clampToRange(rotation.y, -sliderInfo.mapRotLength, sliderInfo.mapRotLength), clampToRange(rotation.z, -sliderInfo.mapRotLength, sliderInfo.mapRotLength))

		scale = clampToRange(scale, sliderInfo.minScale, sliderInfo.maxScale)
	end

	return offset, rotation, scale
end

function AppearanceV2Model:applyPetAccessoryPoint(modelView, instanceId, point, rootRotation, preservedRootScale)
	local pointRotation = point.rotation or Vector3.zero
	local pointScale = point.scale or self:getPetAccessoryDefaultScale()
	local success, rootPosition, pointRootRotation, rootScale = modelView:TryConvertAttachBoneLocalToRoot(point.boneName, point.offset, pointRotation, pointScale)

	if not success then
		return false
	end

	local sliderRotation = rootRotation or pointRootRotation

	if rootRotation then
		local converted, localPosition, localRotation, localScale = modelView:TryConvertAttachRootToBoneLocal(point.boneName, rootPosition, rootRotation, preservedRootScale or rootScale)

		if not converted or not modelView:TryApplyAttachBoneLocalTransform(instanceId, point.boneName, localPosition, localRotation, localScale) then
			return false
		end

		pointScale = localScale
	elseif not modelView:TryApplyAttachBoneLocalTransform(instanceId, point.boneName, point.offset, pointRotation, pointScale) then
		return false
	end

	local operationData = self.operationDATAS

	operationData.simplePointIndex = point.index
	operationData.simplePointOffset = Vector3.New(point.offset.x, point.offset.y, point.offset.z)
	operationData.simplePointRotation = Vector3.New(pointRotation.x, pointRotation.y, pointRotation.z)
	operationData.attachBone = point.boneName
	operationData.curOffset = Vector3.zero
	operationData.curRotate = Vector3.New(sliderRotation.x, sliderRotation.y, sliderRotation.z)
	operationData.curScale = pointScale

	return true
end

function AppearanceV2Model:selectPetAccessoryPoint(index, recordOperation, preserveRotationAndScale)
	if not self:isPetAccessorySimpleMode() then
		return false
	end

	local pointList = self.petAccessoryPointList
	local point = pointList and pointList[index]
	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()

	if point == nil or modelView == nil or instanceId == nil or not modelView:IsAttachBoneValid(point.boneName) then
		return false
	end

	local rootRotation, rootScale

	if preserveRotationAndScale then
		local success, _, currentRootRotation, currentRootScale = self:getSimplePetAccessoryRootTransform(modelView, self.operationDATAS)

		if not success then
			return false
		end

		rootRotation = currentRootRotation
		rootScale = currentRootScale
	end

	if not self:applyPetAccessoryPoint(modelView, instanceId, point, rootRotation, rootScale) then
		return false
	end

	if recordOperation ~= false then
		self:recordOperationStep()
	end

	return true
end

function AppearanceV2Model:resetSelectedPetAccessoryPoint()
	local index = self:getSelectedPetAccessoryPointIndex()

	if index == nil then
		return false
	end

	return self:selectPetAccessoryPoint(index)
end

function AppearanceV2Model:setPetAccessoryAdjustMode(mode, recordOperation, preferredPointIndex)
	if mode ~= self.PET_ACCESSORY_ADJUST_MODE.SIMPLE and mode ~= self.PET_ACCESSORY_ADJUST_MODE.ADVANCED then
		return false
	end

	if self.petAccessoryAdjustMode == mode then
		return true
	end

	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()
	local operationData = self.operationDATAS

	if modelView == nil or instanceId == nil or operationData.curOffset == nil or operationData.curRotate == nil or operationData.curScale == nil then
		return false
	end

	if mode == self.PET_ACCESSORY_ADJUST_MODE.SIMPLE then
		local pointList = self.petAccessoryPointList
		local pointIndex = preferredPointIndex or operationData.simplePointIndex
		local point = pointIndex and pointList and pointList[pointIndex]

		if point == nil or not modelView:IsAttachBoneValid(point.boneName) then
			point = self:getPetAccessoryPointByBoneName(operationData.attachBone, modelView, operationData.curOffset)
		end

		if point == nil or not modelView:IsAttachBoneValid(point.boneName) then
			point = pointList and pointList[1]
		end

		if point == nil or not modelView:IsAttachBoneValid(point.boneName) then
			return false
		end

		local rootPosition = operationData.curOffset
		local rootRotation = operationData.curRotate
		local pointRotation = point.rotation or Vector3.zero
		local success, pointRootPosition = modelView:TryConvertAttachBoneLocalToRoot(point.boneName, point.offset, pointRotation, 1)

		if not success then
			return false
		end

		local converted, localPosition, localRotation, localScale = modelView:TryConvertAttachRootToBoneLocal(point.boneName, rootPosition, rootRotation, operationData.curScale)

		if not converted or not modelView:TryApplyAttachBoneLocalTransform(instanceId, point.boneName, localPosition, localRotation, localScale) then
			return false
		end

		operationData.simplePointIndex = point.index
		operationData.simplePointOffset = Vector3.New(point.offset.x, point.offset.y, point.offset.z)
		operationData.simplePointRotation = Vector3.New(pointRotation.x, pointRotation.y, pointRotation.z)
		operationData.attachBone = point.boneName
		operationData.curOffset = Vector3.New(rootPosition.x - pointRootPosition.x, rootPosition.y - pointRootPosition.y, rootPosition.z - pointRootPosition.z)
		operationData.curScale = localScale
	else
		local success, rootPosition, rootRotation, rootScale = self:getSimplePetAccessoryRootTransform(modelView, operationData)

		if not success then
			return false
		end

		operationData.curOffset = rootPosition
		operationData.curRotate = rootRotation
		operationData.curScale = rootScale

		local nearestBoneName = modelView:GetNearestBoneName(instanceId)

		if nearestBoneName and nearestBoneName ~= "" and modelView:IsAttachBoneValid(nearestBoneName) then
			operationData.attachBone = nearestBoneName
		end
	end

	self.petAccessoryAdjustMode = mode
	operationData.adjustMode = mode

	if mode == self.PET_ACCESSORY_ADJUST_MODE.ADVANCED then
		modelView:RefreshAttachParent(instanceId, operationData.attachBone)
		AvatarUtils.syncPetAttachFromOperation(modelView, instanceId, operationData)
	end

	if recordOperation ~= false then
		self:recordOperationStep()
	end

	return true
end

function AppearanceV2Model:adjustTransform()
	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()
	local accessInfo = self:getOperationData()

	if self:isPetAccessorySimpleMode() then
		local success, rootPosition, rootRotation, rootScale = self:getSimplePetAccessoryRootTransform(modelView, accessInfo)

		if not success then
			return false
		end

		local converted, localPosition, localRotation, localScale = modelView:TryConvertAttachRootToBoneLocal(accessInfo.attachBone, rootPosition, rootRotation, rootScale)

		if not converted then
			return false
		end

		return modelView:TryApplyAttachBoneLocalTransform(instanceId, accessInfo.attachBone, localPosition, localRotation, localScale)
	end

	AvatarUtils.syncPetAttachFromOperation(modelView, instanceId, accessInfo)

	return true
end

function AppearanceV2Model:getServerCacheAccessInfo(data, sliderInfo, defaultAttachInfo)
	if not data then
		return nil
	end

	local function inner(info, instanceId)
		local targetPos = Vector3.New(info.posX, info.posY, info.posZ)
		local targetRot = Vector3.New(info.rotX, info.rotY, info.rotZ)
		local targetScl = info.scale
		local attachInfo1 = {
			accessoryId = info.configId,
			instanceId = instanceId,
			attachHp = info.attachBone,
			resId = AppearanceJewelryPetData[info.configId].res,
			localPosition = targetPos,
			localRotation = targetRot,
			scale = targetScl
		}

		return attachInfo1
	end

	local attachInfo
	local ossInfo = PetJewelryOssCache.getSavedTransform(self.adjustPetCurId, data.accessoryId, nil)

	if ossInfo then
		attachInfo = inner(ossInfo, data.instanceId)
		attachInfo.genId = data.genId

		return attachInfo
	end

	attachInfo = defaultAttachInfo or self:parseDefaultAccessInfo(data, sliderInfo)

	if not attachInfo then
		return nil
	end

	attachInfo.genId = data.genId

	return attachInfo
end

function AppearanceV2Model:parseDefaultAccessInfo(data, sliderInfo)
	if not data then
		return nil
	end

	local accessoryId = data.accessoryId
	local instanceId = data.instanceId
	local pInfo = pg.me:getPetInfo(self.adjustPetCurId)
	local curTemplateId = pInfo.templateId
	local refId = PetData[curTemplateId].refId or curTemplateId
	local resTb

	if curTemplateId and accessoryId then
		local t = pgUtils.GetAccessoryConfigFromLocal(curTemplateId, accessoryId)

		t = t or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)

		if t then
			t.instanceId = instanceId
			resTb = t
		end
	end

	resTb = resTb or {
		accessoryId = accessoryId,
		instanceId = instanceId,
		resId = AppearanceJewelryPetData[accessoryId].res,
		localPosition = sliderInfo.defaultPos,
		localRotation = Vector3.zero,
		scale = sliderInfo.defaultAccessScale
	}
	resTb.genId = data.genId

	return resTb
end

function AppearanceV2Model:initOperationData(sliderInfo)
	self.operationStack = nil
	self.operationStackIndex = 0
	self.operationSliderInfo = sliderInfo
	self.operationDefaultScale = nil
	self.petAccessoryAdjustMode = self.PET_ACCESSORY_ADJUST_MODE.ADVANCED
	self.operationDATAS.adjustMode = self.petAccessoryAdjustMode
	self.operationDATAS.simplePointIndex = nil
	self.operationDATAS.simplePointOffset = nil
	self.operationDATAS.simplePointRotation = nil

	local selectAccessData = self:getSelectAccessData()
	local defaultAttachInfo = self:parseDefaultAccessInfo(selectAccessData, sliderInfo)

	if defaultAttachInfo then
		self.operationDefaultScale = defaultAttachInfo.scale
	end

	local attachInfo = self:getServerCacheAccessInfo(selectAccessData, sliderInfo, defaultAttachInfo)

	if not attachInfo then
		return
	end

	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local instanceId = attachInfo.instanceId

	self:updatePetAccessoryDefaultPoint(defaultAttachInfo, modelView)

	local op = AvatarUtils.loadPetOperationFromAttach(modelView, instanceId, attachInfo, sliderInfo)

	self.operationDATAS.curOffset = op.curOffset
	self.operationDATAS.curRotate = op.curRotate
	self.operationDATAS.curScale = op.curScale
	self.operationDATAS.attachBone = op.attachBone
	self.operationDATAS.resId = op.resId

	local attachBone = modelView:GetAttachBoneName(instanceId)

	if attachBone == nil or attachBone == "" or attachBone == PET_ACCESSORY_BONE_ROOT then
		attachBone = self.operationDATAS.attachBone
	end

	self.cacheBoneLocal = AvatarUtils.capturePetAttachBoneLocal(modelView, instanceId, attachBone, self.operationDATAS.resId)

	if not self:tryRestoreCommittedOperation() and self:hasPetAccessorySimpleMode() then
		local savedTransform = PetJewelryOssCache.getSavedTransform(self.adjustPetCurId, selectAccessData.accessoryId, nil)
		local preferredPointIndex = savedTransform and savedTransform.simplePointIndex

		if savedTransform == nil then
			preferredPointIndex = 1
		end

		self:setPetAccessoryAdjustMode(self.PET_ACCESSORY_ADJUST_MODE.SIMPLE, false, preferredPointIndex)
	end

	self:copyOperation2Dest(self.operationDATAS, self.cacheOperation)
	self:initOperationStack()
end

function AppearanceV2Model:commitOperationSnapshot()
	local data = self.selectItemData

	if not data then
		return
	end

	local snapshot = self:captureOperationSnapshot()

	if not snapshot then
		return
	end

	self.committedOperationSnapshot = {
		petId = self.adjustPetCurId,
		accessoryId = data.accessoryId,
		instanceId = data.instanceId,
		tabIndex = self.selectTabIndex,
		snapshot = snapshot
	}
end

function AppearanceV2Model:tryRestoreCommittedOperation()
	local committed = self.committedOperationSnapshot
	local data = self:getSelectAccessData()

	if not committed or not data then
		return false
	end

	if committed.petId ~= self.adjustPetCurId or committed.accessoryId ~= data.accessoryId or committed.instanceId ~= data.instanceId or committed.tabIndex ~= self.selectTabIndex then
		return false
	end

	return self:applyOperationSnapshot(committed.snapshot)
end

function AppearanceV2Model:clearCommittedOperationSnapshot()
	self.committedOperationSnapshot = nil
end

function AppearanceV2Model:copyOperation2Dest(ori, des)
	des.curOffset = Vector3.New(ori.curOffset.x, ori.curOffset.y, ori.curOffset.z)
	des.curRotate = Vector3.New(ori.curRotate.x, ori.curRotate.y, ori.curRotate.z)
	des.curScale = ori.curScale
	des.attachBone = ori.attachBone
	des.resId = ori.resId
	des.adjustMode = ori.adjustMode or self.petAccessoryAdjustMode
	des.simplePointIndex = ori.simplePointIndex

	if ori.simplePointOffset then
		des.simplePointOffset = Vector3.New(ori.simplePointOffset.x, ori.simplePointOffset.y, ori.simplePointOffset.z)
	else
		des.simplePointOffset = nil
	end

	if ori.simplePointRotation then
		des.simplePointRotation = Vector3.New(ori.simplePointRotation.x, ori.simplePointRotation.y, ori.simplePointRotation.z)
	else
		des.simplePointRotation = nil
	end
end

function AppearanceV2Model:getOperationData()
	return self.operationDATAS
end

function AppearanceV2Model:resetOperation()
	if self.cacheOperation.curOffset == nil then
		return false
	end

	return self:applyOperationSnapshot(self.cacheOperation)
end

function AppearanceV2Model:applyCachedOperation()
	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()

	if modelView and instanceId and self.cacheBoneLocal then
		return AvatarUtils.restorePetAttachBoneLocal(modelView, instanceId, self.cacheBoneLocal)
	end

	return false
end

function AppearanceV2Model:clearOperationCache()
	table.clear(self.operationDATAS)
	table.clear(self.cacheOperation)

	self.cacheBoneLocal = nil
	self.operationStack = nil
	self.operationStackIndex = 0
	self.petAccessoryAdjustMode = nil
	self.operationSliderInfo = nil
	self.operationDefaultScale = nil
end

function AppearanceV2Model:discardOperationData()
	self:applyCachedOperation()
	self:clearOperationCache()
end

function AppearanceV2Model:captureOperationSnapshot()
	local data = self.operationDATAS

	if not data.curOffset or not data.curRotate then
		return nil
	end

	return {
		curOffset = Vector3.New(data.curOffset.x, data.curOffset.y, data.curOffset.z),
		curRotate = Vector3.New(data.curRotate.x, data.curRotate.y, data.curRotate.z),
		curScale = data.curScale,
		attachBone = data.attachBone,
		resId = data.resId,
		adjustMode = self.petAccessoryAdjustMode,
		simplePointIndex = data.simplePointIndex,
		simplePointOffset = data.simplePointOffset and Vector3.New(data.simplePointOffset.x, data.simplePointOffset.y, data.simplePointOffset.z),
		simplePointRotation = data.simplePointRotation and Vector3.New(data.simplePointRotation.x, data.simplePointRotation.y, data.simplePointRotation.z)
	}
end

function AppearanceV2Model:applyOperationSnapshot(snapshot)
	if not snapshot then
		return false
	end

	self:copyOperation2Dest(snapshot, self.operationDATAS)

	self.petAccessoryAdjustMode = snapshot.adjustMode or self.PET_ACCESSORY_ADJUST_MODE.ADVANCED
	self.operationDATAS.adjustMode = self.petAccessoryAdjustMode

	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local instanceId = self:getSelectAccessInstanceId()

	if not self:isPetAccessorySimpleMode() and self.operationDATAS.attachBone then
		modelView:RefreshAttachParent(instanceId, self.operationDATAS.attachBone)
	end

	return self:adjustTransform()
end

function AppearanceV2Model:isOperationSnapshotEqual(a, b)
	if not a or not b then
		return false
	end

	return a.curOffset.x == b.curOffset.x and a.curOffset.y == b.curOffset.y and a.curOffset.z == b.curOffset.z and a.curRotate.x == b.curRotate.x and a.curRotate.y == b.curRotate.y and a.curRotate.z == b.curRotate.z and a.curScale == b.curScale and a.attachBone == b.attachBone and a.adjustMode == b.adjustMode and a.simplePointIndex == b.simplePointIndex
end

function AppearanceV2Model:initOperationStack()
	local snapshot = self:captureOperationSnapshot()

	if not snapshot then
		self.operationStack = nil
		self.operationStackIndex = 0

		return
	end

	self.operationStack = {
		snapshot
	}
	self.operationStackIndex = 1
end

function AppearanceV2Model:recordOperationStep()
	if not self.operationStack then
		self:initOperationStack()

		return
	end

	local current = self:captureOperationSnapshot()

	if not current then
		return
	end

	local top = self.operationStack[self.operationStackIndex]

	if self:isOperationSnapshotEqual(current, top) then
		return
	end

	for i = #self.operationStack, self.operationStackIndex + 1, -1 do
		self.operationStack[i] = nil
	end

	table.insert(self.operationStack, current)

	self.operationStackIndex = #self.operationStack
end

function AppearanceV2Model:canBackwardOperation()
	return self.operationStack ~= nil and self.operationStackIndex > 1
end

function AppearanceV2Model:canForwardOperation()
	return self.operationStack ~= nil and self.operationStackIndex < #self.operationStack
end

function AppearanceV2Model:backwardOperation()
	if not self:canBackwardOperation() then
		return false
	end

	local targetIndex = self.operationStackIndex - 1

	if not self:applyOperationSnapshot(self.operationStack[targetIndex]) then
		return false
	end

	self.operationStackIndex = targetIndex

	return true
end

function AppearanceV2Model:forwardOperation()
	if not self:canForwardOperation() then
		return false
	end

	local targetIndex = self.operationStackIndex + 1

	if not self:applyOperationSnapshot(self.operationStack[targetIndex]) then
		return false
	end

	self.operationStackIndex = targetIndex

	return true
end

function AppearanceV2Model:saveAccessTransToLocal(callback)
	local curEnt = self.avatarScene:getCurEntity()
	local itemData = self.selectItemData
	local item = self:parseServerJewelryInfo(itemData)

	pgUtils.SaveAccessoryConfigToLocal({
		petTemplateId = curEnt.templateId,
		accessoryId = itemData.accessoryId,
		instanceId = itemData.instanceId,
		attachHp = item.attachBone,
		resId = itemData.resId,
		localPosition = Vector3(item.posX, item.posY, item.posZ),
		localRotation = Vector3(item.rotX, item.rotY, item.rotZ),
		scale = item.scale
	})

	if callback then
		callback(curEnt.templateId, itemData.accessoryId)
	end
end

function AppearanceV2Model:equipAccess2Server(setInfo, callback)
	local petId = self.adjustPetCurId

	pg.me:serverMsg("RPC_CS_MultiSetPetJewelry", petId, setInfo, callback)
end

function AppearanceV2Model:adjustAccessTrans(callback)
	local petId = self.adjustPetCurId
	local itemData = self.selectItemData
	local item = self:parseServerJewelryInfo(itemData)
	local savedTransform = Utils.deepCopyTable(item)

	savedTransform.simplePointIndex = self.operationDATAS.simplePointIndex

	PetJewelryOssCache.set(petId, itemData.accessoryId, savedTransform)
	PetJewelryOssCache.upload()
	self:syncTempJewelrySlot(item)
	pg.me:serverMsg("RPC_CS_SetPetJewelryInfo", petId, itemData.genId, item, callback)
end

function AppearanceV2Model:syncTempJewelrySlot(item)
	local curEnt = self.avatarScene and self.avatarScene:getCurEntity()

	if not curEnt or not curEnt.tempJewelryInfo or not self.selectTabIndex or not item then
		return
	end

	local slotInfo = curEnt.tempJewelryInfo[self.selectTabIndex]

	if not slotInfo then
		return
	end

	slotInfo.configId = item.configId
	slotInfo.attachBone = item.attachBone
	slotInfo.posX = item.posX
	slotInfo.posY = item.posY
	slotInfo.posZ = item.posZ
	slotInfo.rotX = item.rotX
	slotInfo.rotY = item.rotY
	slotInfo.rotZ = item.rotZ
	slotInfo.scale = item.scale
end

function AppearanceV2Model:unlockSlot2Server(callback)
	local petProId = self.adjustPetProId

	pg.me:serverMsg("RPC_CS_UnlockPetAppearancePoint", petProId, callback)
end

function AppearanceV2Model:parseServerJewelryInfo(attachInfo)
	local operationData = self:getOperationData()
	local instanceId = attachInfo.instanceId
	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local item = {
		configId = attachInfo.accessoryId
	}

	item.attachBone = modelView:GetAttachBoneName(instanceId)

	local lPos = modelView:GetAttachLocalPosition(instanceId)

	item.posX = lPos.x
	item.posY = lPos.y
	item.posZ = lPos.z

	local lRot = modelView:GetAttachLocalEulerRotation(instanceId)

	item.rotX = lRot.x
	item.rotY = lRot.y
	item.rotZ = lRot.z
	item.scale = modelView:GetAttachLocalScale(instanceId)
	item.attachBone = operationData.attachBone

	return item
end

function AppearanceV2Model:checkAccessEquipped(genId, excludeSelf)
	for uid, v in pg.me.petJewelryRecords:items() do
		if excludeSelf then
			if v.petId ~= self.adjustPetCurId and uid == genId then
				return v
			end
		elseif uid == genId then
			return v
		end
	end

	return false
end

function AppearanceV2Model:getAllAccessInBag()
	local allAccess = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PET_JEWELRY):getAll()

	return allAccess
end

function AppearanceV2Model:clearCacheData()
	table.clear(self.operationDATAS)
	table.clear(self.cacheOperation)

	self.cacheBoneLocal = nil
	self.operationStack = nil
	self.operationStackIndex = 0
	self.petAccessoryPointList = nil
	self.petAccessoryAdjustMode = nil
	self.operationSliderInfo = nil
	self.operationDefaultScale = nil

	self:clearCommittedOperationSnapshot()

	self.adjustPetProId = nil
	self.adjustPetCurId = nil
	self.selectTabIndex = nil
end

function AppearanceV2Model:redDot_CheckOptionItemState(data)
	local showRedDot = false
	local configData = AppearanceData[data.itemId] or {}
	local initialClaim = configData.initialClaim == 1

	if data.claimed and not initialClaim then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, true)
	end

	return showRedDot
end

function AppearanceV2Model:redDot_CheckClothesSuitOptionItemState(data)
	local showRedDot = false
	local configData = AppearanceSuitData[data.itemId] or {}
	local clothesIdList = configData.appearanceList or {}
	local initialClaimNum = 0

	for _, clothesId in ipairs(clothesIdList) do
		local clothesData = AppearanceData[clothesId] or {}

		if clothesData.initialClaim == 1 then
			initialClaimNum = initialClaimNum + 1
		end
	end

	if data.claimed and initialClaimNum == 0 then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, true)
	end

	return showRedDot
end

function AppearanceV2Model:redDot_CheckHairSuitOptionItemState(data)
	local showRedDot = false
	local hairSuitData = AvatarHairSuitData[data.itemId] or {}
	local hairPartIdList = hairSuitData.appearanceList or {}
	local initialClaimNum = 0

	for _, hairPartId in ipairs(hairPartIdList) do
		local hairPartData = AppearanceData[hairPartId] or {}

		if hairPartData.initialClaim == 1 then
			initialClaimNum = initialClaimNum + 1
		end
	end

	if data.claimed and initialClaimNum == 0 then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_OPTION_LIST_ITEM, data.itemId)

		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, true)
	end

	return showRedDot
end

function AppearanceV2Model:redDot_CheckPetOptionItemState(data)
	local showRedDot = false

	if data.state == LuaUIUtils.SELECT_STATE.TRY then
		return showRedDot
	end

	if data.state ~= LuaUIUtils.SELECT_STATE.LOCKED then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_PET_OPTION_LIST_ITEM, string.format("%s_%s", data.accessoryId, data.genId))

		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_PET_RED_DOT, treePath, true)
	end

	return showRedDot
end

function AppearanceV2Model:redDot_CheckColorAccessoryItemState(data)
	local showRedDot = false

	if not data.isLock then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_COLOR_ACCESSORY_ITEM, data.id)

		showRedDot = pg.me:getRedDotRecord(Const.CLIENT_KEY.APPEARANCE_RED_DOT, treePath, true)
	end

	return showRedDot
end

return AppearanceV2Model
