-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarFusion\\AvatarFusionModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local lume = require("Core.Common.lume")
local AvatarPresetData = require("Data.avatar_preset_data")
local AvatarFusionModel = Class.LightClass("AvatarFusionModel", UIModel)

AvatarFusionModel.GENDER = {
	BOY = 21,
	GIRL = 11
}

function AvatarFusionModel:getPresetList(body, alreadyContains)
	local list = {}

	for key, presetData in pairs(AvatarPresetData) do
		if body == presetData.body then
			table.insert(list, {
				presetKey = key,
				icon = presetData.icon,
				order = presetData.sort or 999
			})
		end
	end

	return lume.sort(list, "order")
end

function AvatarFusionModel:getPickPresetList(slotA, slotB, slotC)
	local list = {}

	if slotB then
		list[#list + 1] = {
			presetKey = slotB,
			icon = pg.game.avatar:getAvatarPresetData(slotB).icon
		}
	else
		list[#list + 1] = {
			empty = true
		}
	end

	if slotC then
		list[#list + 1] = {
			presetKey = slotC,
			icon = pg.game.avatar:getAvatarPresetData(slotC).icon
		}
	else
		list[#list + 1] = {
			empty = true
		}
	end

	if slotA then
		list[#list + 1] = {
			presetKey = slotA,
			icon = pg.game.avatar:getAvatarPresetData(slotA).icon
		}
	else
		list[#list + 1] = {
			empty = true
		}
	end

	return list
end

function AvatarFusionModel:getRandomThreePreset(body)
	local list = {}

	for key, presetData in pairs(AvatarPresetData) do
		if body == presetData.body then
			table.insert(list, {
				presetKey = key,
				icon = presetData.icon,
				order = presetData.sort or 999
			})
		end
	end

	local n = #list

	if n > 1 then
		for i = n, 2, -1 do
			local j = math.random(i)

			list[i], list[j] = list[j], list[i]
		end
	end

	if n > 3 then
		list = {
			list[1],
			list[2],
			list[3]
		}
	end

	return list
end

function AvatarFusionModel:getReactions(originConfig, key1, key2)
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

return AvatarFusionModel
