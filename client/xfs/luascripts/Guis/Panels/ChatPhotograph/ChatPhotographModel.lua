-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChatPhotograph\\ChatPhotographModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ChatPhotographModel = Class.LightClass("ChatPhotographModel", UIModel)
local MapBlockConfigData = require("Data.map_block_config_data")

function ChatPhotographModel:getPointNameByPos(sceneId, pos)
	if not sceneId or not pos then
		return ""
	end

	local x = pos[1] or pos.x
	local z = pos[3] or pos.z
	local blockId = pg.game.map:inWhichBlock(sceneId, false, {
		x = x,
		z = z
	})

	if blockId then
		return pg.getLocalizationText(MapBlockConfigData[blockId].areaName) or ""
	end

	return pg.game.map:getSceneName(sceneId)
end

function ChatPhotographModel:formatNumber(num)
	num = tonumber(num) or 0

	if num < 0 then
		num = math.ceil(num - 0.5)

		return string.format("-%04d", math.abs(num))
	else
		num = math.floor(num + 0.5)

		return string.format("%04d", num)
	end
end

return ChatPhotographModel
