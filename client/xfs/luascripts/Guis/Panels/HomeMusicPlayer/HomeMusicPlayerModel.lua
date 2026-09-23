-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeMusicPlayer\\HomeMusicPlayerModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandBgmData = require("Data.homeland_bgm_data")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeMusicPlayerModel = Class.LightClass("HomeMusicPlayerModel", UIModel)

function HomeMusicPlayerModel:ctor()
	UIModel.ctor(self)

	self.displayList = {}
	self.sessionVisibleMusic = {}
	self.openingBgmItemId = nil
	self.playingBgmItemId = Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
	self.defaultBgmConfigId = nil
end

function HomeMusicPlayerModel.isConfigUnlocked(config)
	if config.isUnlock == 1 then
		return true
	end

	local itemId = tonumber(config.itemID)

	if not itemId or itemId <= 0 or not pg.me then
		return false
	end

	return ItemUtils.getHomeBagAndWarehouseItemCount(pg.me, itemId) > 0
end

function HomeMusicPlayerModel.isMusicUnlockItemId(itemId)
	itemId = tonumber(itemId)

	if not itemId then
		return false
	end

	for _, config in pairs(HomelandBgmData) do
		if tonumber(config.itemID) == itemId then
			return true
		end
	end

	return false
end

function HomeMusicPlayerModel.isMusicUnviewed(bgmConfigId)
	if not pg.me then
		return false
	end

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.HOMELAND_MUSIC_PLAYER_RED_DOT, string.format(RedDotConst.RedDotPath.HOME_MUSIC_PLAYER_ITEM_NEW, bgmConfigId), true)
end

function HomeMusicPlayerModel.sortDisplayItem(a, b)
	if a.isCurrentOnOpen ~= b.isCurrentOnOpen then
		return a.isCurrentOnOpen
	end

	if a.sortId ~= b.sortId then
		return a.sortId < b.sortId
	end

	return a.bgmConfigId < b.bgmConfigId
end

function HomeMusicPlayerModel:beginViewSession()
	self.sessionVisibleMusic = {}
	self.openingBgmItemId = nil
end

function HomeMusicPlayerModel:buildDisplayList(playingBgmItemId, defaultBgmConfigId)
	self.defaultBgmConfigId = tonumber(defaultBgmConfigId)
	self.playingBgmItemId = tonumber(playingBgmItemId) or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT

	if self.playingBgmItemId == self.defaultBgmConfigId then
		self.playingBgmItemId = Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
	end

	if self.openingBgmItemId == nil then
		self.openingBgmItemId = self.playingBgmItemId
	end

	local displayList = {}

	for bgmConfigId, config in pairs(HomelandBgmData) do
		local numericId = tonumber(bgmConfigId)

		if numericId and numericId > 0 and HomeMusicPlayerModel.isConfigUnlocked(config) then
			local isSceneDefault = numericId == self.defaultBgmConfigId
			local bgmItemId = isSceneDefault and Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT or numericId
			local newRedDotPath = string.format(RedDotConst.RedDotPath.HOME_MUSIC_PLAYER_ITEM_NEW, numericId)

			self.sessionVisibleMusic[numericId] = newRedDotPath
			displayList[#displayList + 1] = {
				bgmConfigId = numericId,
				bgmItemId = bgmItemId,
				sortId = tonumber(config.sortId) or 0,
				name = config.name,
				itemId = config.itemID,
				isNew = HomeMusicPlayerModel.isMusicUnviewed(numericId),
				newRedDotPath = newRedDotPath,
				isCurrentOnOpen = bgmItemId == self.openingBgmItemId,
				isSceneDefault = isSceneDefault,
				config = config
			}
		end
	end

	table.sort(displayList, HomeMusicPlayerModel.sortDisplayItem)

	self.displayList = displayList

	return self.displayList
end

function HomeMusicPlayerModel:markAllMusicViewed()
	if not pg.me then
		return false
	end

	local hasChanged = false

	for _, newRedDotPath in pairs(self.sessionVisibleMusic) do
		local success = pg.me:setRedDotRecord(Const.CLIENT_KEY.HOMELAND_MUSIC_PLAYER_RED_DOT, newRedDotPath, false)

		if success then
			hasChanged = true
		end
	end

	self.sessionVisibleMusic = {}

	return hasChanged
end

function HomeMusicPlayerModel:getDisplayList()
	return self.displayList
end

function HomeMusicPlayerModel:setPlayingBgmItemId(bgmItemId)
	self.playingBgmItemId = tonumber(bgmItemId) or Const.HOMELAND_BGM_ITEM_ID_SCENE_DEFAULT
end

function HomeMusicPlayerModel:getPlayingBgmItemId()
	return self.playingBgmItemId
end

function HomeMusicPlayerModel:getDisplayIndexByBgmItemId(bgmItemId)
	for index, data in ipairs(self.displayList) do
		if data.bgmItemId == bgmItemId then
			return index - 1
		end
	end

	return nil
end

return HomeMusicPlayerModel
