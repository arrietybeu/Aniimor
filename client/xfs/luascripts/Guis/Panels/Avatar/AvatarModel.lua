-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\AvatarModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local AppearanceData = require("Data.appearance_data")
local AppearanceIcon = require("Data.appearance_icon")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceMakeupPresetData = require("Data.appearance_makeup_preset_data")
local MakeupResData = require("Data.makeup_res_data")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local AvatarHairResIdToReaction = require("Data.Avatar.avatar_hair_resId_to_reaction")
local lume = require("Core.Common.lume")
local AvatarModel = Class.LightClass("AvatarModel", UIModel)
local GameConst = CS.FunPlus.WorldX.Const.GameConst

AvatarModel.HAIR_PART = {
	PART = "part",
	WHOLE = "whole"
}
AvatarModel.COLOR_TYPE = {
	PURE_COLOR = "pureColor",
	GRADIENT_ROOT_COLOR = "rootColor",
	GRADIENT_COLOR = "color"
}

function AvatarModel:getHairFirstSortList()
	local res = {
		{
			icon = AppearanceIcon[AvatarUtils.APPEARANCE_ICON_ID.HAIR] and AppearanceIcon[AvatarUtils.APPEARANCE_ICON_ID.HAIR].icon or nil,
			key = AvatarUtils.HAIR_DESIGN_TYPE.PRESET,
			displayName = pg.getGameString("CREATE_PLAYER_HAIR_SELECT")
		},
		{
			icon = AppearanceIcon[AvatarUtils.APPEARANCE_ICON_ID.DYE] and AppearanceIcon[AvatarUtils.APPEARANCE_ICON_ID.DYE].icon or nil,
			key = AvatarUtils.HAIR_DESIGN_TYPE.COLOR,
			displayName = pg.getGameString("CREATE_PLAYER_HAIR_COLOR")
		}
	}

	return res
end

function AvatarModel:getHairFirstDesignList()
	local res = {
		{
			state = "Normal",
			key = AvatarUtils.HAIR_DESIGN_TYPE.COLOR,
			displayName = pg.getGameString("APPEARANCE_DYE"),
			icon = AddressDataConst.APPEARANCE_DESIGN_DYE
		}
	}

	return res
end

function AvatarModel:getHairSecondDesignList(originConfig, key)
	local res = AvatarUtils.getSortedGroup(originConfig)

	if key == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
		table.insert(res, 1, {
			state = 1,
			key = self.HAIR_PART.WHOLE,
			displayName = pg.getGameString("CREATE_PLAYER_HAIR_WHOLE")
		})
	elseif key == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		-- block empty
	end

	return res
end

function AvatarModel:getHairSecondList(originConfig, hairOp)
	local res = AvatarUtils.getSortedGroup(originConfig)
	local wholeItem = {
		state = 1,
		key = self.HAIR_PART.WHOLE,
		displayName = pg.getGameString("CREATE_PLAYER_HAIR_WHOLE")
	}

	if hairOp == AvatarUtils.HAIR_DESIGN_TYPE.PRESET then
		table.insert(res, 1, wholeItem)
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.COLOR then
		table.insert(res, 1, wholeItem)
	elseif hairOp == AvatarUtils.HAIR_DESIGN_TYPE.SETTING then
		-- block empty
	end

	return res
end

function AvatarModel:getHairSuitList(presetKey)
	local body = pg.game.avatar:getAvatarPresetData(presetKey).body
	local res = {}
	local empty = {
		state = "Null",
		tIndex = 0,
		id = -1
	}

	table.insert(res, empty)

	for suitId, suitData in pairs(AvatarHairSuitData) do
		if pg.me then
			if table.contains(suitData.body, body) then
				local info = {
					tIndex = 0,
					state = "Normal",
					id = suitId,
					assetId = suitData.assetId,
					icon = suitData.icon or ItemData[suitId] and ItemData[suitId].icon or ""
				}

				table.insert(res, info)
			end
		elseif table.contains(suitData.body, body) and suitData.preview and suitData.preview == 1 then
			local info = {
				tIndex = 0,
				state = "Normal",
				id = suitId,
				assetId = suitData.assetId,
				icon = suitData.icon or ItemData[suitId] and ItemData[suitId].icon or ""
			}

			table.insert(res, info)
		end
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)

	return res
end

function AvatarModel:getHairPartList(presetKey, assetId, partId)
	local body = pg.game.avatar:getAvatarPresetData(presetKey).body
	local res = {}
	local empty = {
		res = "",
		tIndex = 1,
		id = -1,
		state = "Null",
		partId = partId
	}

	table.insert(res, empty)

	for id, partData in pairs(AppearanceData) do
		if LuaUIUtils.isHair(partData.type) and table.contains(partData.body, body) and AvatarHairSuitData[partData.hairId].assetId == assetId and partData.partId == partId then
			local info = {
				tIndex = 1,
				state = "Normal",
				id = id,
				res = partData.res,
				partId = partId,
				icon = partData.icon or ItemData[id].icon
			}

			table.insert(res, info)
		end
	end

	table.sort(res, function(a, b)
		return a.id < b.id
	end)

	return res
end

function AvatarModel:getHairReaction(originConfig, groupKey, reactionKey)
	local groupData = self:getGroupData(originConfig, groupKey)
	local kindList = groupData.kindList or {}

	for _, kindData in pairs(kindList) do
		local reaction = kindData.reaction or {}

		if reaction.key == reactionKey then
			return reaction
		end
	end
end

function AvatarModel:findGroupKeyByPartId(originConfig, partId)
	for groupKey, groupData in pairs(originConfig or EMPTY_TABLE) do
		if groupData.partId == partId then
			return groupKey
		end
	end
end

function AvatarModel:collectHairColorsFromReaction(reaction, colorMap)
	local colorConfig = reaction and reaction.colors

	if not colorConfig then
		return
	end

	for opName, config in pairs(colorConfig) do
		if not colorMap[opName] then
			colorMap[opName] = config
		end
	end
end

function AvatarModel:getHairSuitColorList(originConfig, partModelInfo)
	local colorMap = {}

	if originConfig and partModelInfo then
		for partId = GameConst.PART_HAIR_FRINGE, GameConst.PART_HAIR_PLAIT do
			local resId = partModelInfo:GetPartResId(partId)

			if resId and resId ~= "" then
				local reactionKey = AvatarHairResIdToReaction[resId]

				if reactionKey then
					local groupKey = self:findGroupKeyByPartId(originConfig, partId)

					if groupKey then
						local reaction = self:getHairReaction(originConfig, groupKey, reactionKey)

						self:collectHairColorsFromReaction(reaction, colorMap)
					end
				end
			end
		end
	end

	local res = {}

	for _, config in pairs(colorMap) do
		table.insert(res, config)
	end

	table.insert(res, {
		tIndex = 0,
		opName = AvatarUtils.OP_NAME.reflectance,
		displayName = pg.getGameString("CREATE_PLAYER_REFLECTANCE")
	})
	table.sort(res, function(a, b)
		return a.opName < b.opName
	end)

	return res
end

function AvatarModel:getHairPartColorList(originConfig, groupKey, reactionKey)
	local res = {}

	if reactionKey and reactionKey ~= -1 then
		local reaction = self:getHairReaction(originConfig, groupKey, reactionKey)
		local colorConfig = reaction and reaction.colors

		if colorConfig then
			for opName, config in pairs(colorConfig) do
				table.insert(res, config)
			end
		end
	end

	table.sort(res, function(a, b)
		return a.opName < b.opName
	end)

	return res
end

local function isPlayerOwnMakeupSuit(suitId)
	if not suitId or not pg.me then
		return false
	end

	if pg.me.avatarSuitUnlockMap and pg.me.avatarSuitUnlockMap[suitId] == true then
		return true
	end

	return ItemUtils.getItemCountById(pg.me, suitId, true) > 0
end

local function isPlayerOwnSingleMakeup(makeupId)
	if not makeupId or not pg.me then
		return false
	end

	local appearanceInfo = pg.me.appearanceInfo

	if appearanceInfo and appearanceInfo[makeupId] ~= nil then
		return true
	end

	return ItemUtils.getItemCountById(pg.me, makeupId, true) > 0
end

local function isInAnyMakeupSuit(makeupId)
	for _, presetInfo in pairs(AppearanceMakeupPresetData) do
		if presetInfo.makeupList then
			for _, id in ipairs(presetInfo.makeupList) do
				if id == makeupId then
					return true
				end
			end
		end
	end

	return false
end

function AvatarModel:isMakeupAppearanceVisible(id)
	if ClientCashShopUtils.isAppearanceReleaseTimeOpen(id) then
		return true
	end

	local presetInfo = AppearanceMakeupPresetData[id]

	if presetInfo and presetInfo.makeupList then
		return isPlayerOwnMakeupSuit(id)
	end

	return isPlayerOwnSingleMakeup(id)
end

function AvatarModel:isMakeupSuitEntryVisible(suitId, presetInfo)
	local showStatus = presetInfo.showStatus or 1

	if showStatus == 2 then
		return false
	end

	if showStatus == 3 and not isPlayerOwnMakeupSuit(suitId) then
		return false
	end

	return self:isMakeupAppearanceVisible(suitId)
end

function AvatarModel:isVisibleViaMakeupSuit(makeupId)
	for suitId, presetInfo in pairs(AppearanceMakeupPresetData) do
		if presetInfo.makeupList then
			for _, id in ipairs(presetInfo.makeupList) do
				if id == makeupId and isPlayerOwnMakeupSuit(suitId) then
					local showStatus = presetInfo.showStatus or 1

					if showStatus ~= 2 then
						return true
					end
				end
			end
		end
	end

	return false
end

function AvatarModel:isSingleMakeupItemVisible(configId, appearanceData)
	local showStatus = appearanceData.showStatus or 1

	if showStatus == 2 then
		return false
	end

	if not pg.me then
		if appearanceData.initialClaim == 1 then
			return true
		else
			return false
		end
	end

	if isPlayerOwnSingleMakeup(configId) then
		return true
	end

	if self:isVisibleViaMakeupSuit(configId) then
		return true
	end

	return false
end

function AvatarModel:getMakeUpPresetList(body)
	local res = {}

	if not body then
		return res
	end

	for id, presetInfo in pairs(AppearanceMakeupPresetData) do
		if table.contains(presetInfo.body, body) then
			table.insert(res, {
				id = id,
				icon = presetInfo.icon,
				res = presetInfo.res
			})
		end
	end

	return res
end

function AvatarModel:getMakeupSuitList(body)
	local res = {}

	if not body then
		return res
	end

	if not pg.me then
		return res
	end

	for id, presetInfo in pairs(AppearanceMakeupPresetData) do
		if not presetInfo.makeupList or not table.contains(presetInfo.body, body) or not self:isMakeupSuitEntryVisible(id, presetInfo) then
			-- block empty
		else
			local owned = isPlayerOwnMakeupSuit(id)
			local itemInfo = ItemData[id] or {}
			local icon = itemInfo.icon or presetInfo.icon

			table.insert(res, {
				id = id,
				icon = icon,
				makeupList = presetInfo.makeupList,
				owned = owned,
				order = presetInfo.sort or 999
			})
		end
	end

	table.sort(res, function(a, b)
		if a.owned ~= b.owned then
			return a.owned
		end

		return a.order < b.order
	end)

	return res
end

AvatarModel.EYE_KIND = {
	L = "-94715488",
	R = "-94715981"
}

function AvatarModel:isDynamicEyeball(originConfig, groupKey)
	local groupData = originConfig[groupKey] or {}
	local realizeType = groupData.realizeType
	local shaderPropertyType = groupData.shaderPropertyType

	return realizeType == GameConst.MAKE_UP_TEXTURE and shaderPropertyType == GameConst.SHADER_DYNAMIC_EYE
end

function AvatarModel:isEyeball(originConfig, groupKey)
	local groupData = originConfig[groupKey] or {}
	local realizeType = groupData.realizeType
	local shaderPropertyType = groupData.shaderPropertyType

	return realizeType == GameConst.MAKE_UP_TEXTURE and shaderPropertyType == GameConst.SHADER_EYE
end

function AvatarModel:getMakeupKindList(originConfig, groupKey)
	local groupData = originConfig[groupKey] or {}

	if not groupData.kindList then
		return nil
	end

	local sortedKind = {}

	for kindKey, kindData in pairs(groupData.kindList) do
		table.insert(sortedKind, {
			order = kindData.order,
			key = kindKey,
			displayName = kindData.displayName
		})
	end

	return lume.sort(sortedKind, "order")
end

function AvatarModel:getMakeupKindData(originConfig, groupKey, kindKey)
	local groupData = originConfig[groupKey] or {}

	if kindKey and groupData.kindList then
		return groupData.kindList[kindKey] or {}
	end

	return groupData
end

function AvatarModel:getMakeUpList(originConfig, groupKey, body, kindKey)
	local res = {}
	local sourceData = self:getMakeupKindData(originConfig, groupKey, kindKey)
	local reactionList = sourceData.reactionList or {}
	local realizeType = sourceData.realizeType
	local isFixedDecal = realizeType == GameConst.MAKE_UP_FIXED_DECAL
	local isDecal = realizeType == GameConst.MAKE_UP_DECAL
	local isEyeball = self:isEyeball(originConfig, groupKey)
	local isDynamicEyeball = self:isDynamicEyeball(originConfig, groupKey)
	local tIndex = (isDecal or isEyeball or isDynamicEyeball) and 0 or 1

	for _, reaction in ipairs(reactionList) do
		local id = reaction.configId

		if id then
			local appearanceData = AppearanceData[id]

			if appearanceData and LuaUIUtils.tableContains(appearanceData.body, body) and self:isSingleMakeupItemVisible(id, appearanceData) then
				local itemData = ItemData[id] or {}

				table.insert(res, {
					state = "Normal",
					key = reaction.key,
					key_L = reaction.key_L,
					key_R = reaction.key_R,
					icon = appearanceData.icon or itemData.icon,
					isSelected = pg.global.avatarMgr.avatarMakeup:IsReactionSelected(groupKey, reaction.key),
					tIndex = tIndex
				})
			end
		end
	end

	if isFixedDecal or isDynamicEyeball then
		table.insert(res, 1, {
			key = -1,
			state = "Null",
			tIndex = tIndex
		})
	end

	return res
end

AvatarModel.ADJUST_TYPE = {
	BOTH = 1,
	LEFT = 0,
	RIGHT = 2
}

function AvatarModel:getGroupData(originConfig, key1)
	return originConfig[key1] or {}
end

function AvatarModel:getKindData(originConfig, key1, key2)
	local groupData = self:getGroupData(originConfig, key1) or {}
	local kindList = groupData.kindList or {}

	for key, kindData in pairs(kindList) do
		if key == key2 then
			return kindData
		end
	end

	return {}
end

function AvatarModel:getReactions(originConfig, key1, key2)
	local groupData = originConfig[key1] or {}
	local selectedKindData = groupData.kindList[key2] or {}
	local reactionList = selectedKindData.reactionList or {}
	local res = {}

	for index, reaction in ipairs(reactionList) do
		res[index] = {
			key = reaction.key
		}

		table.merge(res[index], reaction.operation)
	end

	return res
end

return AvatarModel
