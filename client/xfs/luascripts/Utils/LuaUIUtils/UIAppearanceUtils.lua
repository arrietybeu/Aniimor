-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIAppearanceUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ItemData = require("Data.item_data")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("LuaUIUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearancePointData = require("Data.appearance_point_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local CommonSwitch = require("Common.CommonSwitch")
local UIConst = require("Const.UIConst")

return function(LuaUIUtils)
	function LuaUIUtils.openPlayerAppearancePanel(closeCallback, openCallback)
		if not CommonSwitch.APPEARAMCE then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
			closeCallback = closeCallback
		}, openCallback, nil, {
			paramsTable = {
				needShowAvatar = true
			}
		})
	end

	function LuaUIUtils.openPlayerAppearancePanelAndSelectSuit(suitId, suitType, closeCallback, openCallback)
		if not CommonSwitch.APPEARAMCE then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
			enterPage = "player",
			closeCallback = closeCallback,
			selectSuitOnOpen = suitId and {
				id = suitId,
				type = suitType
			} or nil
		}, openCallback, nil, {
			paramsTable = {
				needShowAvatar = true
			}
		})
	end

	function LuaUIUtils.isAccessory(type)
		return UIConst.AppearanceMask.ACCESSORY == type
	end

	function LuaUIUtils.isAppearancePointHidden(slotId)
		local definition = AppearancePointData[slotId]

		return definition and definition.hidden == 1
	end

	function LuaUIUtils.getAccessorySelectState(claimed, equipped)
		if claimed and equipped then
			return LuaUIUtils.SELECT_STATE.ROLE_WEAR
		elseif claimed then
			return LuaUIUtils.SELECT_STATE.HAVE
		else
			return LuaUIUtils.SELECT_STATE.LOCKED
		end
	end

	function LuaUIUtils.getAccessoryInfo(entity, accessoryId)
		local accessoryData = AppearanceData[accessoryId] or {}
		local claimed = pg.me.appearanceInfo[accessoryId] ~= nil and true or false
		local equipped = LuaUIUtils.isAccessoryEquipped(entity, accessoryId)
		local state = LuaUIUtils.getAccessorySelectState(claimed, equipped)
		local itemData = ItemData[accessoryId] or {}
		local res = {
			accessoryId = accessoryId,
			itemId = accessoryId,
			icon = accessoryData.icon or itemData.icon,
			name = itemData.itemName,
			quality = itemData.quality or UIConst.QUALITY.GREEN,
			resId = accessoryData.res,
			claimed = claimed,
			equipped = equipped,
			state = state,
			fashion = accessoryData.fashion or 0
		}

		return res
	end

	function LuaUIUtils.isAccessoryEquipped(entity, accessoryId)
		if not entity or not accessoryId or accessoryId == 0 then
			return false
		end

		if not entity.curShow and not entity.getAppearanceConfigId then
			return false
		end

		for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
			local id

			if entity.getAppearanceConfigId then
				id = entity:getAppearanceConfigId(slotId, true, true)
			else
				id = entity.curShow.customShow[slotId]
			end

			if id == accessoryId then
				return true, slotId
			end
		end

		return false
	end

	function LuaUIUtils.isClothes(type)
		return UIConst.AppearanceMask.CLOTHES == type
	end

	function LuaUIUtils.getClothesSlotIcon(slotId)
		if slotId then
			return AppearancePointData[slotId].icon
		else
			return AddressDataConst.AVATAR_APPEARANCE_CLOTHES_SUIT_ICON
		end
	end

	function LuaUIUtils.getClothesInfo(entity, clothesId, customShow)
		local res = {}
		local claimed = entity.appearanceInfo[clothesId] ~= nil and true or false
		local equipped = LuaUIUtils.isClothesEquipped(entity, clothesId, customShow)
		local state = equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
		local clothesData = AppearanceData[clothesId] or {}
		local itemData = ItemData[clothesId] or {}

		res = {
			itemId = clothesId,
			clothesId = clothesId,
			resId = clothesData.res,
			points = clothesData.points,
			partId = clothesData.partId or clothesData.points and clothesData.points[1],
			itemId = clothesId,
			icon = itemData.icon,
			name = itemData.itemName or "",
			quality = itemData.quality or UIConst.QUALITY.GREEN,
			claimed = claimed,
			equipped = equipped,
			state = state,
			fashion = clothesData.fashion or 0
		}

		return res
	end

	function LuaUIUtils.getSuitInfo(entity, suitId, equipped)
		local suitData = AppearanceSuitData[suitId] or {}
		local itemData = ItemData[suitId] or {}
		local claimedCount = 0
		local fashionCount = 0

		for _, clothesId in ipairs(suitData.appearanceList) do
			local clothesData = AppearanceData[clothesId] or {}

			if entity.appearanceInfo[clothesId] then
				claimedCount = claimedCount + 1
			end

			fashionCount = fashionCount + (clothesData.fashion or 0)
		end

		local claimed = claimedCount == #suitData.appearanceList
		local state = equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED

		return {
			suitId = suitId,
			itemId = suitId,
			icon = suitData.icon or itemData.icon,
			name = itemData.itemName,
			quality = itemData.quality or UIConst.QUALITY.GREEN,
			clothesList = suitData.appearanceList,
			allCount = #suitData.appearanceList,
			equipped = equipped,
			claimed = claimed,
			state = state,
			claimedCount = claimedCount,
			fashion = fashionCount
		}
	end

	function LuaUIUtils.tryGetEquippedSuitId(entity, customShow)
		local suitId
		local comparedList = {}

		for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			local clothesId = customShow and customShow[slotId] or entity.curShow.customShow[slotId]

			if entity.getAppearanceConfigId then
				clothesId = entity:getAppearanceConfigId(slotId)
			end

			if clothesId and clothesId ~= 0 and not table.contains(comparedList, clothesId) then
				table.insert(comparedList, clothesId)
			end
		end

		for id, suitData in pairs(AppearanceSuitData) do
			if LuaUIUtils.tablesHaveSameElements(suitData.appearanceList, comparedList) then
				suitId = id

				break
			end
		end

		return suitId
	end

	function LuaUIUtils.tablesHaveSameElements(t1, t2)
		if #t1 ~= #t2 then
			return false
		end

		local elementCounts = {}

		for _, v in ipairs(t1) do
			elementCounts[v] = (elementCounts[v] or 0) + 1
		end

		for _, v in ipairs(t2) do
			if not elementCounts[v] then
				return false
			end

			elementCounts[v] = elementCounts[v] - 1

			if elementCounts[v] < 0 then
				return false
			end
		end

		for _, count in pairs(elementCounts) do
			if count ~= 0 then
				return false
			end
		end

		return true
	end

	function LuaUIUtils.getClothesPrimarySlot(clothesId)
		local clothesData = AppearanceData[clothesId] or {}

		if clothesData.partId then
			return clothesData.partId
		end

		if clothesData.points and clothesData.points[1] then
			return clothesData.points[1]
		end

		return nil
	end

	function LuaUIUtils.isClothesBelongToSlot(clothesId, slotId)
		if not clothesId or clothesId == 0 or not slotId then
			return false
		end

		return LuaUIUtils.getClothesPrimarySlot(clothesId) == slotId
	end

	function LuaUIUtils.isClothesEquipped(entity, clothesId, customShow)
		if not entity then
			return false
		end

		if clothesId == 0 then
			return false
		end

		local clothesData = AppearanceData[clothesId] or {}
		local slotId = LuaUIUtils.getClothesPrimarySlot(clothesId)

		if slotId then
			local clothesIdInWear = customShow and customShow[slotId] or entity.curShow.customShow[slotId]

			if entity.getAppearanceConfigId then
				clothesIdInWear = entity:getAppearanceConfigId(slotId)
			end

			if clothesIdInWear == clothesId then
				return true, slotId
			end
		else
			logger:error(string.format("@sxy invalid clothesData, clothesId = %s, no 'partId'/'points' field", clothesId))
		end

		return false
	end

	function LuaUIUtils.getEquippedClothesList(entity)
		if not entity or not entity.curShow then
			return
		end

		local res = {}
		local curCustomShow = entity.curShow.customShow or {}

		for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
			local clothesId = curCustomShow[partId]

			if clothesId ~= 0 and LuaUIUtils.isClothesBelongToSlot(clothesId, partId) then
				table.insert(res, clothesId)
			end
		end

		return res
	end

	function LuaUIUtils.isHair(type)
		return UIConst.AppearanceMask.HAIR == type
	end

	function LuaUIUtils.getHairSlotIcon(slotId)
		if slotId then
			return AppearancePointData[slotId].icon
		else
			return AddressDataConst.AVATAR_APPEARANCE_HAIR_SUIT_ICON
		end
	end

	function LuaUIUtils.isHairPartEquipped(entity, id, customShow)
		if not entity then
			return false
		end

		for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			local configId = customShow and customShow[slotId] or entity.curShow.customShow[slotId]

			if entity.getAppearanceConfigId then
				configId = entity:getAppearanceConfigId(slotId)
			end

			if configId == id then
				return true, slotId
			end
		end

		return false
	end

	function LuaUIUtils.isHairSuitClaimed(entity, id)
		if not entity or not entity.appearanceInfo then
			return false
		end

		for hairPartId, hairPartInfo in pairs(AppearanceData) do
			if LuaUIUtils.isHair(hairPartInfo.type) and hairPartInfo.hairId == id and not entity.appearanceInfo[hairPartId] then
				return false
			end
		end

		return true
	end

	function LuaUIUtils.getHairPartInfo(entity, id, customShow)
		local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
		local res = {}
		local hairPartData = AppearanceData[id] or {}
		local claimed = entity.appearanceInfo[id] ~= nil and true or false
		local equipped = LuaUIUtils.isHairPartEquipped(entity, id, customShow)
		local state = equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
		local itemData = ItemData[id] or {}

		res = {
			id = id,
			res = hairPartData.res,
			partId = hairPartData.partId,
			itemId = id,
			icon = hairPartData.icon or itemData.icon,
			name = itemData.itemName,
			quality = itemData.quality or UIConst.QUALITY.GREEN,
			claimed = claimed,
			equipped = equipped,
			state = state,
			fashion = hairPartData.fashion or 0
		}

		return res
	end

	function LuaUIUtils.tryGetEntityHairSuitId(entity, customShow)
		if not entity then
			return nil
		end

		local hairId

		for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			local configId

			if entity.getAppearanceConfigId then
				configId = entity:getAppearanceConfigId(slotId)
			elseif customShow then
				configId = customShow[slotId]
			elseif entity.curShow and entity.curShow.customShow then
				configId = entity.curShow.customShow[slotId]
			end

			if configId and configId > 0 then
				if not hairId then
					hairId = AppearanceData[configId].hairId
				elseif hairId ~= AppearanceData[configId].hairId then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("@sxy invalid equip: part %s is not in suit %s", configId, hairId))
					end

					break
				end
			end
		end

		return hairId
	end

	function LuaUIUtils.tryGetHairSuitId(partIds)
		local hairId

		for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			local configId = partIds[slotId]

			if configId and configId ~= 0 then
				if not hairId then
					hairId = AppearanceData[configId].hairId
				elseif hairId ~= AppearanceData[configId].hairId then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string.format("@sxy invalid equip: part %s is not in suit %s", configId, hairId))
					end

					break
				end
			end
		end

		return hairId
	end

	function LuaUIUtils.getDefaultHairPartIds(hairId)
		local res = {}

		for hairPartId, hairPartInfo in pairs(AppearanceData) do
			if LuaUIUtils.isHair(hairPartInfo.type) and hairPartInfo.hairId == hairId then
				local oldHairPartId = res[hairPartInfo.partId]

				if oldHairPartId == nil or hairPartId < oldHairPartId then
					res[hairPartInfo.partId] = hairPartId
				end
			end
		end

		return res
	end

	function LuaUIUtils.getAllPartInSuit(hairId, originAssetId, currentAssetId)
		local res = {}
		local avatarPresetKey = pg.game.avatar:getPresetKey(pg.me)
		local hairSuit = AvatarHairSuitData[hairId] or {}
		local isModelConfig = originAssetId == hairSuit.assetId

		if currentAssetId ~= nil then
			isModelConfig = isModelConfig and currentAssetId == hairSuit.assetId
		end

		local defaultHairParts = LuaUIUtils.getDefaultHairPartIds(hairId)

		for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
			local newHairPartId

			if isModelConfig then
				local AvatarUtils = require("Guis.Utils.AvatarUtils")
				local hairResInfo = AvatarUtils.getModelResPart(pg.me, avatarPresetKey, partId)

				newHairPartId = hairResInfo and hairResInfo.configId
			else
				newHairPartId = defaultHairParts[partId]
			end

			res[partId] = newHairPartId
		end

		return res
	end

	function LuaUIUtils.getHairSuitInfo(entity, id, customShow)
		local suitData = AvatarHairSuitData[id] or {}
		local suitIdInWear = LuaUIUtils.tryGetEntityHairSuitId(entity, customShow)
		local itemData = ItemData[id] or {}
		local fashionCount = 0

		for _, clothesId in ipairs(suitData.appearanceList) do
			local clothesData = AppearanceData[clothesId] or {}

			fashionCount = fashionCount + (clothesData.fashion or 0)
		end

		local claimed = LuaUIUtils.isHairSuitClaimed(entity, id)
		local equipped = suitIdInWear == id
		local state = equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED

		return {
			id = id,
			itemId = id,
			icon = suitData.icon or itemData.icon,
			name = itemData.itemName,
			quality = itemData.quality or UIConst.QUALITY.GREEN,
			equipped = equipped,
			claimed = claimed,
			state = state,
			fashion = fashionCount
		}
	end

	function LuaUIUtils.isMakeUp(type)
		return UIConst.AppearanceMask.MAKEUP == type
	end
end
