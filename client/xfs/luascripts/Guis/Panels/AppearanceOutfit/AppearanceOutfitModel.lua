-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceOutfit\\AppearanceOutfitModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AppearanceCustomData = require("Data.appearance_custom_data")
local AppearancePointData = require("Data.appearance_point_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AppearanceOutfitModel = Class.LightClass("AppearanceOutfitModel", UIModel)

AppearanceOutfitModel.OUTFIT_TAB = {
	NOW = "Now",
	PREVIEW = "Preview",
	LOCKED = "Locked",
	NORMAL = "Normal",
	EMPTY = "Empty"
}
AppearanceOutfitModel.CONTENT_TAB = {
	LOCKED = "Locked",
	EMPTY_NO_WORD = "EmptyNoWord",
	EMPTY = "Empty",
	HAVE = "Have"
}
AppearanceOutfitModel.OP_TYPE = {
	SAVE_TO_EMPTY = 2,
	SAVE_TO_OUTFIT = 1,
	USE_FROM_OUTFIT = 0
}

function AppearanceOutfitModel:getOutfitList(entity)
	local res = {}

	table.insert(res, {
		state = self.OUTFIT_TAB.NOW,
		name = pg.getGameString("APPEARANCE_CURRENT_SUIT")
	})

	for id, data in ipairs(AppearanceCustomData) do
		local custom = entity.appearanceCustom[id]
		local state = self.OUTFIT_TAB.EMPTY

		if custom then
			for _, configId in pairs(custom.customShow) do
				if configId ~= 0 then
					state = self.OUTFIT_TAB.NORMAL

					break
				end
			end
		else
			state = self.OUTFIT_TAB.LOCKED
		end

		local outfitName = custom and custom.customName or ""

		table.insert(res, {
			state = state,
			name = outfitName == "" and ClientTextUtils.concatByLanguage(pg.getGameString("APPEARANCE_OUTFIT"), id) or outfitName,
			slotId = id,
			costNum = data.costNum,
			costType = data.costType,
			photoId = Utils.getAppearanceCustomPhotoId(pg.me.uid, "appearanceCustom", id)
		})

		if state == self.OUTFIT_TAB.LOCKED then
			break
		end
	end

	return res
end

function AppearanceOutfitModel:getContentList(outfitId)
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	local entity = avatarScene:getCurEntity()
	local res = {}

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId

		if outfitId then
			if pg.me.appearanceCustom[outfitId] then
				clothesId = pg.me.appearanceCustom[outfitId].customShow[slotId]
			end
		else
			clothesId = entity:getAppearanceConfigId(slotId)
		end

		if clothesId and clothesId ~= 0 then
			local clothesInfo = LuaUIUtils.getClothesInfo(pg.me, clothesId)

			res[#res + 1] = {
				state = self.CONTENT_TAB.HAVE,
				icon = clothesInfo.icon,
				quality = clothesInfo.quality,
				part = AppearancePointData[slotId].name,
				slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
				text = AppearancePointData[slotId].text,
				id = clothesId
			}
		else
			res[#res + 1] = {
				state = self.CONTENT_TAB.EMPTY_NO_WORD,
				part = AppearancePointData[slotId].name,
				slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
				text = AppearancePointData[slotId].text
			}
		end
	end

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		if LuaUIUtils.isAppearancePointHidden(slotId) then
			-- block empty
		else
			local accessoryId

			if outfitId then
				if pg.me.appearanceCustom[outfitId] then
					accessoryId = pg.me.appearanceCustom[outfitId].customShow[slotId]
				end
			else
				accessoryId = entity:getAppearanceConfigId(slotId)
			end

			if accessoryId and accessoryId ~= 0 then
				local accessoryInfo = LuaUIUtils.getAccessoryInfo(pg.me, accessoryId)

				res[#res + 1] = {
					state = self.CONTENT_TAB.HAVE,
					icon = accessoryInfo.icon,
					quality = accessoryInfo.quality,
					part = AppearancePointData[slotId].name,
					slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
					text = AppearancePointData[slotId].text,
					id = accessoryId
				}
			else
				res[#res + 1] = {
					state = self.CONTENT_TAB.EMPTY_NO_WORD,
					part = AppearancePointData[slotId].name,
					slotIcon = LuaUIUtils.getClothesSlotIcon(slotId),
					text = AppearancePointData[slotId].text
				}
			end
		end
	end

	return res
end

return AppearanceOutfitModel
