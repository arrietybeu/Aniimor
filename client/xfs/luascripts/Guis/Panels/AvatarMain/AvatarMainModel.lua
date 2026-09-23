-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarMain\\AvatarMainModel.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local AvatarPresetData = require("Data.avatar_preset_data")
local AvatarMainModel = Class.LightClass("AvatarMainModel", UIModel)

AvatarMainModel.GENDER = {
	GIRL = 11,
	BOY = 21
}

function AvatarMainModel:getPresetList(body)
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

function AvatarMainModel:getPresetData(key)
	return pg.game.avatar:getAvatarPresetData(key) or {}
end

return AvatarMainModel
