-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FissureInfo\\FissureInfoModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RiftLevelData = require("Data.rift_level_data")
local RiftBuffData = require("Data.rift_buff_data")
local FissureInfoModel = Class.LightClass("FissureInfoModel", UIModel)
local MUTATION_KEYS = {
	"envBuff01",
	"envBuff02"
}

function FissureInfoModel:getLevelConfig(levelId)
	return levelId and RiftLevelData[levelId] or nil
end

function FissureInfoModel:getMutations(levelId)
	local ret = {}
	local levelConfig = self:getLevelConfig(levelId)

	if not levelConfig then
		return ret
	end

	for _, key in ipairs(MUTATION_KEYS) do
		local buffId = levelConfig[key]

		if buffId and buffId ~= 0 then
			local buffCfg = RiftBuffData[buffId]

			if buffCfg then
				ret[#ret + 1] = {
					buffId = buffId,
					config = buffCfg
				}
			end
		end
	end

	return ret
end

return FissureInfoModel
