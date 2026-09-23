-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PhotographyAssetRedDotUtils.lua

local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local PhotoPrefabData = require("Data.photo_prefab_data")
local LightingData = require("Data.photo_lighting_data")
local FilterData = require("Data.photo_filter_data")
local DIYData = require("Data.photo_diy_data")
local OrnamentData = require("Data.photo_ornament_data")
local BackgroundData = require("Data.appearance_background_data")
local AppearanceActionData = require("Data.appearance_action_data")
local PhotographyAssetRedDotUtils = {}

PhotographyAssetRedDotUtils.AssetType = {
	DIY = "diy",
	Ornament = "ornament",
	Filter = "filter",
	Background = "background",
	Lighting = "lighting",
	PlayerPose = "playerPose",
	StudioPrefab = "studioPrefab"
}
PhotographyAssetRedDotUtils.SubType = {
	DynamicPose = 2,
	StaticPose = 1,
	StudioOfficial = "studioOfficial"
}

local AssetType = PhotographyAssetRedDotUtils.AssetType
local SHOW_STATUS_NORMAL = 1
local SHOW_STATUS_HIDDEN = 2
local SHOW_STATUS_UNLOCKED = 3
local SHOW_STATUS_TARGET_ITEM = 4
local AssetData = {
	[AssetType.StudioPrefab] = PhotoPrefabData,
	[AssetType.Lighting] = LightingData,
	[AssetType.Filter] = FilterData,
	[AssetType.DIY] = DIYData,
	[AssetType.Ornament] = OrnamentData,
	[AssetType.Background] = BackgroundData,
	[AssetType.PlayerPose] = AppearanceActionData
}

local function getAssetConfig(assetType, assetId)
	local dataTable = AssetData[assetType]

	if not dataTable then
		return nil
	end

	return dataTable[tonumber(assetId) or assetId]
end

local function isInitialAsset(config)
	return config and (config.initialClaim == 1 or config.initialClaim == true)
end

local function getRecordKey(assetType, assetId)
	return string.format("%s_%s", assetType, tostring(assetId))
end

local function isConfigInSubType(assetType, config, subType)
	if assetType == AssetType.StudioPrefab then
		return subType == nil or subType == PhotographyAssetRedDotUtils.SubType.StudioOfficial
	end

	if assetType == AssetType.Filter or assetType == AssetType.DIY then
		return subType == nil or tonumber(config.type) == tonumber(subType)
	end

	if assetType == AssetType.PlayerPose then
		local photoType = tonumber(config.photo)

		if not photoType or photoType <= 0 then
			return false
		end

		return subType == nil or photoType == tonumber(subType)
	end

	return subType == nil
end

function PhotographyAssetRedDotUtils.getFunctionPath(assetType)
	return string.format(RedDotConst.RedDotPath.PHOTO_ASSET_FUNCTION, assetType)
end

function PhotographyAssetRedDotUtils.getSubTabPath(assetType, subType)
	return string.format(RedDotConst.RedDotPath.PHOTO_ASSET_SUB_TAB, assetType, tostring(subType))
end

function PhotographyAssetRedDotUtils.getItemPath(assetType, subType, assetId)
	if subType == nil then
		return string.format(RedDotConst.RedDotPath.PHOTO_ASSET_DIRECT_ITEM, assetType, tostring(assetId))
	end

	return string.format(RedDotConst.RedDotPath.PHOTO_ASSET_ITEM, assetType, tostring(subType), tostring(assetId))
end

function PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, assetId)
	local config = getAssetConfig(assetType, assetId)

	if not config then
		return false
	end

	if isInitialAsset(config) then
		return true
	end

	if not pg.me then
		return false
	end

	local id = tonumber(assetId) or assetId

	return pg.me.isPhotoUnlock and pg.me:isPhotoUnlock(id) or false
end

local function isTargetItemVisible(assetType, targetItemId)
	targetItemId = tonumber(targetItemId)

	if not targetItemId or targetItemId <= 0 then
		return false
	end

	if assetType == AssetType.Ornament then
		local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
		local releaseState = ClientHomelandUtils.getFurnitureReleaseState(targetItemId)

		return releaseState.isReleased and not releaseState.isOffShelf
	end

	if assetType == AssetType.Background then
		local AppearanceV2Model = require("Guis.Panels.AppearanceV2.AppearanceV2Model")

		return AppearanceV2Model:isAppearanceVisible(targetItemId)
	end

	return false
end

function PhotographyAssetRedDotUtils.isAssetVisible(assetType, assetId)
	local config = getAssetConfig(assetType, assetId)

	if not config then
		return false
	end

	local showStatus = tonumber(config.showStatus) or SHOW_STATUS_NORMAL

	if showStatus == SHOW_STATUS_HIDDEN then
		return false
	end

	if showStatus == SHOW_STATUS_UNLOCKED then
		return PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, assetId)
	end

	if showStatus == SHOW_STATUS_TARGET_ITEM then
		return PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, assetId) or isTargetItemVisible(assetType, config.target_item)
	end

	return true
end

function PhotographyAssetRedDotUtils.sortUnlockedFirst(list, assetType, idField)
	idField = idField or "id"

	for _, data in ipairs(list) do
		local id = data[idField]

		data.isUnlocked = id == nil or id == -1 or PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, id)
	end

	table.sort(list, function(left, right)
		local leftId = left[idField]
		local rightId = right[idField]

		if left.isUnlocked ~= right.isUnlocked then
			return left.isUnlocked
		end

		if leftId == nil then
			return rightId ~= nil
		end

		if rightId == nil then
			return false
		end

		return leftId < rightId
	end)
end

function PhotographyAssetRedDotUtils.isAssetNew(assetType, assetId)
	local config = getAssetConfig(assetType, assetId)

	if not config or isInitialAsset(config) or not PhotographyAssetRedDotUtils.isAssetVisible(assetType, assetId) or not PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, assetId) then
		return false
	end

	local id = tonumber(assetId) or assetId

	if assetType == AssetType.PlayerPose then
		local component = pg.game and pg.game.social and pg.game.social.interactGestureComponent

		return component and component:isNewInteractGesture(id) or false
	end

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.PHOTO_ASSET_RED_DOT, getRecordKey(assetType, id), true)
end

function PhotographyAssetRedDotUtils.markAssetViewed(assetType, assetId)
	local config = getAssetConfig(assetType, assetId)

	if not config or isInitialAsset(config) or not PhotographyAssetRedDotUtils.isAssetUnlocked(assetType, assetId) then
		return
	end

	local id = tonumber(assetId) or assetId

	if assetType == AssetType.PlayerPose then
		local component = pg.game and pg.game.social and pg.game.social.interactGestureComponent

		if component and component.markInteractGestureViewed then
			component:markInteractGestureViewed(id)
		end

		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PHOTO_ASSET_RED_DOT, getRecordKey(assetType, id), false)
end

function PhotographyAssetRedDotUtils.hasNewAsset(assetType, subType)
	local dataTable = AssetData[assetType]

	if not dataTable then
		return false
	end

	for assetId, config in pairs(dataTable) do
		if isConfigInSubType(assetType, config, subType) and PhotographyAssetRedDotUtils.isAssetNew(assetType, assetId) then
			return true
		end
	end

	return false
end

function PhotographyAssetRedDotUtils.getRedDotStyle(assetType, subType)
	if PhotographyAssetRedDotUtils.hasNewAsset(assetType, subType) then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

return PhotographyAssetRedDotUtils
