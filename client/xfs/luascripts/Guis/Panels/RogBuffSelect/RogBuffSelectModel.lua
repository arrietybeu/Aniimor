-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogBuffSelect\\RogBuffSelectModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RogBuffSelectModel = Class.LightClass("RogBuffSelectModel", UIModel)
local BuffConfigData = require("Data.buff_config_data")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local RandomBuffData = require("Data.random_buff_data")
local ExtraRandomBuff = require("Data.extra_random_buff")

function RogBuffSelectModel:parserBuffData(info)
	local res = {
		cNum = info.cNum
	}
	local buffs = {}

	for i, buffId in pairs(info.buffs) do
		local buffCfg = RandomBuffData[buffId] or ExtraRandomBuff[buffId]

		if buffCfg then
			local buffCfg2 = BuffConfigData[buffId]

			buffs[i] = {
				hasPlayFx = false,
				buffId = buffId,
				buffName = buffCfg2.buffName,
				buffDesc = ClientAbilityUtils.getBuffDesc(buffId, buffCfg.buffLv),
				buffIcon = buffCfg2.icon,
				buffQuality = buffCfg.buffRarity or buffCfg.buffLv,
				buffSeries = buffCfg.buffSeries
			}
		end
	end

	res.buffs = buffs

	return res
end

return RogBuffSelectModel
