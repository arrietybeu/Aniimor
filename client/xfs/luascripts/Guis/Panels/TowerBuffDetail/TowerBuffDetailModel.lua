-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerBuffDetail\\TowerBuffDetailModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RandomBuffData = require("Data.random_buff_data")
local RandomBuffSeriesName = require("Data.random_buff_series_name")
local BuffConfigData = require("Data.buff_config_data")
local TowerBuffDetailModel = Class.LightClass("TowerBuffDetailModel", UIModel)
local DungeonConst = require("Common.Const.DungeonConst")
local ExtraRandomBuff = require("Data.extra_random_buff")
local RogueUtils = require("Utils.RogueUtils")
local RogueTalentUtils = require("Common.Utils.RogueTalentUtils")

local function sortFunc(a, b)
	if a.type == b.type then
		return false
	end

	return a.type < b.type
end

function TowerBuffDetailModel:getBuffTypes()
	local curBuffList = pg.me.rogueBuffs or {}
	local data = {
		{
			selected = true,
			type = DungeonConst.ROGUE_ALL_BUFF_TYPE_ID,
			label = pg.getGameString("ALL"),
			count = RogueUtils.getTotalRogueBuffCount()
		}
	}
	local types = {}

	for buffId, _ in pairs(curBuffList) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

		if not table.contains(types, buffCfg.buffSeries) then
			table.insert(types, buffCfg.buffSeries)
			table.insert(data, {
				type = buffCfg.buffSeries,
				label = pg.getLocalizationText(RandomBuffSeriesName[buffCfg.buffSeries].buffSeriesName),
				count = RogueUtils.getRogueBuffCountBySeries(buffCfg.buffSeries)
			})
		end
	end

	table.sort(data, sortFunc)

	return data
end

function TowerBuffDetailModel:getBuffTypes2(curType)
	local rogueExtraBuffSeries = RogueTalentUtils.func(pg.me, "rogueExtraBuffSeries")
	local unlockSeries = pg.me.rogueInitSeriesInfo:getUnlockSeriesList(rogueExtraBuffSeries)
	local data = {
		{
			type = DungeonConst.ROGUE_ALL_BUFF_TYPE_ID,
			label = pg.getGameString("ALL"),
			count = RogueUtils.getTotalRogueBuffCount(),
			selected = curType == DungeonConst.ROGUE_ALL_BUFF_TYPE_ID
		}
	}

	for i = 0, #RandomBuffSeriesName do
		local seriesCfg = RandomBuffSeriesName[i]

		if seriesCfg and table.contains(unlockSeries, i) then
			table.insert(data, {
				type = i,
				label = pg.getLocalizationText(seriesCfg.buffSeriesName),
				count = RogueUtils.getRogueBuffCountBySeries(i),
				selected = curType == i
			})
		end
	end

	return data
end

function TowerBuffDetailModel:getBuffLists()
	return pg.me:getRogueBuffLists()
end

return TowerBuffDetailModel
