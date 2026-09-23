-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoDownloadTemplate\\PhotoDownloadTemplateModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoDownloadTemplateModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PhotoDownloadTemplateModel = Class.LightClass("PhotoDownloadTemplateModel", UIModel)
local MapBlockConfigData = require("Data.map_block_config_data")

function PhotoDownloadTemplateModel:getPointNameByPos(sceneId, pos)
	if not sceneId then
		return ""
	end

	local blockId = pg.game.map:inWhichBlock(sceneId, false, {
		x = pos[1],
		z = pos[3]
	})

	if blockId then
		return pg.getLocalizationText(MapBlockConfigData[blockId].areaName) or ""
	end

	return pg.game.map:getSceneName(sceneId)
end

function PhotoDownloadTemplateModel:formatNumber(num)
	if num < 0 then
		num = math.ceil(num - 0.5)

		return string.format("-%04d", math.abs(num))
	else
		num = math.floor(num + 0.5)

		return string.format("%04d", num)
	end
end

return PhotoDownloadTemplateModel
