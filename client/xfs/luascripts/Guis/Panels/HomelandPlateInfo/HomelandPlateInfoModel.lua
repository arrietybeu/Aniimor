-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlateInfo\\HomelandPlateInfoModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandPlateInfoModel = Class.LightClass("HomelandPlateInfoModel", UIModel)
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local DropData = require("Data.drop_data")

function HomelandPlateInfoModel:getRewardData(zoneId)
	local datas = {}
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local rewardId = HomelandZoneUnlockConfigData[zoneId].rewardId

	if rewardId then
		local dropData = DropData[rewardId]

		if dropData then
			for _, reward in pairs(dropData.displayReward) do
				local data = {}

				data.id = reward[1]
				data.num = reward[2]

				table.insert(datas, data)
			end
		end
	end

	return datas
end

return HomelandPlateInfoModel
