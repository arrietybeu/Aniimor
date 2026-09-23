-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarPreview\\AvatarPreviewModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceActionData = require("Data.appearance_action_data")
local ItemData = require("Data.item_data")
local AvatarPreviewModel = Class.LightClass("AvatarPreviewModel", UIModel)

function AvatarPreviewModel:getTabList()
	local res = {}

	table.insert(res, {
		pageIdx = 0,
		text = pg.getGameString("APPEARANCE_CLOTHES")
	})
	table.insert(res, {
		pageIdx = 1,
		text = pg.getGameString("CREATE_PLAYER_ANIMATION")
	})

	return res
end

function AvatarPreviewModel:getSuitList(bodyType)
	local res = {}

	for id, suitData in pairs(AppearanceSuitData) do
		if suitData.preview and suitData.preview > 0 then
			local itemData = ItemData[id] or {}

			if table.contains(suitData.body, bodyType) and suitData.preview then
				table.insert(res, {
					suitId = id,
					itemId = id,
					icon = suitData.previewIcon,
					name = itemData.itemName,
					quality = itemData.quality,
					clothesList = suitData.appearanceList
				})
			end
		end
	end

	table.sort(res, function(a, b)
		return a.suitId < b.suitId
	end)
	table.insert(res, 1, {})

	return res
end

function AvatarPreviewModel:getAnimationList(bodyType)
	local res = {}

	for id, actionData in pairs(AppearanceActionData) do
		if actionData.preview and actionData.preview > 0 then
			local itemData = ItemData[id] or {}

			if table.contains(actionData.body, bodyType) then
				table.insert(res, {
					actionId = id,
					itemId = id,
					name = actionData.name,
					icon = actionData.previewIcon or itemData.icon,
					name = itemData.itemName,
					state = actionData.res1 and actionData.res1[1] or nil
				})
			end
		end
	end

	table.sort(res, function(a, b)
		return a.actionId < b.actionId
	end)
	table.insert(res, 1, {})

	return res
end

return AvatarPreviewModel
