-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoPetAction.lua

local PetPhotoWeightData = require("Data.pet_photo_weight_data")
local PetPhotoWeightSpecialData = require("Data.pet_photo_weight_special_data")
local SysConfigData = require("Data.sys_config_data")
local PhotoPetAction = {}

PhotoPetAction.ResultKey = {
	"happy",
	"angry",
	"cry",
	"alert",
	"love",
	"sleep"
}

function PhotoPetAction.calcPetAction(natures, sceneId, areaIds, playerAction, entityId)
	if not PhotoPetAction.CalcActionWeight then
		PhotoPetAction.CalcActionWeight = {
			Nature = SysConfigData.PHOTO_ACTION_PARAM[1] * 0.1,
			Scene = SysConfigData.PHOTO_ACTION_PARAM[2] * 0.1,
			Area = SysConfigData.PHOTO_ACTION_PARAM[2] * 0.1,
			Player = SysConfigData.PHOTO_ACTION_PARAM[3] * 0.1
		}
	end

	local natureWeights = {
		0,
		0,
		0,
		0,
		0,
		0
	}

	for _, nature in ipairs(natures) do
		local weightCfg = PetPhotoWeightData[1][nature]

		if weightCfg then
			for i, key in ipairs(PhotoPetAction.ResultKey) do
				natureWeights[i] = natureWeights[i] + (weightCfg[key] or 0)
			end
		end
	end

	for i = 1, #natureWeights do
		natureWeights[i] = natureWeights[i] / #natures * (PhotoPetAction.CalcActionWeight.Nature or 0)
	end

	local sceneWeights = {
		0,
		0,
		0,
		0,
		0,
		0
	}
	local sceneCfg = PetPhotoWeightData[2][tostring(sceneId)]

	if sceneCfg then
		for i, key in ipairs(PhotoPetAction.ResultKey) do
			sceneWeights[i] = (sceneCfg[key] or 0) * (PhotoPetAction.CalcActionWeight.Scene or 0)
		end
	end

	local curAreaId
	local areaWeights = {
		0,
		0,
		0,
		0,
		0,
		0
	}

	for _, areaId in ipairs(areaIds) do
		local areaCfg = PetPhotoWeightData[3][tostring(areaId)]

		if areaCfg then
			for i, key in ipairs(PhotoPetAction.ResultKey) do
				areaWeights[i] = (areaCfg[key] or 0) * (PhotoPetAction.CalcActionWeight.Area or 0)
			end

			curAreaId = areaId

			break
		end
	end

	local actionWeights = {
		0,
		0,
		0,
		0,
		0,
		0
	}

	playerAction = playerAction or ""

	local actionCfg = PetPhotoWeightData[4][playerAction]

	if actionCfg then
		for i, key in ipairs(PhotoPetAction.ResultKey) do
			actionWeights[i] = (actionCfg[key] or 0) * (PhotoPetAction.CalcActionWeight.Player or 0)
		end
	end

	local finalWeights = {}

	for i = 1, #PhotoPetAction.ResultKey do
		finalWeights[i] = natureWeights[i] + sceneWeights[i] + areaWeights[i] + actionWeights[i]

		if finalWeights[i] < 0 then
			finalWeights[i] = 0
		end
	end

	local natureStr = table.concat(natures, "")

	for index, specialInfo in ipairs(PetPhotoWeightSpecialData) do
		local enable = true

		if specialInfo.mbti then
			enable = enable and specialInfo.mbti == natureStr
		end

		if specialInfo.scene then
			enable = enable and specialInfo.scene == sceneId
		end

		if specialInfo.area then
			enable = enable and curAreaId and table.contains(specialInfo.area, curAreaId)
		end

		if specialInfo.action then
			enable = enable and specialInfo.action == playerAction
		end

		if specialInfo.day then
			enable = enable and specialInfo.day == pg.timePeriod
		end

		if enable then
			finalWeights[specialInfo.playType] = (finalWeights[specialInfo.playType] or 0) + specialInfo.param
		end
	end

	local totalWeight = 0

	for i = 1, #finalWeights do
		totalWeight = totalWeight + finalWeights[i]
	end

	if totalWeight <= 0 then
		return
	end

	for index, value in ipairs(finalWeights) do
		finalWeights[index] = value / totalWeight
	end

	local key = math.random()
	local curValue = 0

	for i, value in ipairs(finalWeights) do
		if key < curValue + value then
			return i, PhotoPetAction.ResultKey[i]
		end

		curValue = curValue + value
	end
end

return PhotoPetAction
