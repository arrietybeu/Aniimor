-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPetSaveManual\\EventPetSaveManualModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local PetData = require("Data.pet_data")
local PetSaveManualData = require("Data.event_petsave_manual_data")
local EventPetSaveManualModel = Class.LightClass("EventPetSaveManualModel", UIModel)

function EventPetSaveManualModel:getPetSaveWeekSumyData(week)
	if pg.me.activityPetSaveData and next(pg.me.activityPetSaveData) then
		return week and pg.me.activityPetSaveData[week] or pg.me.activityPetSaveData
	end

	return nil
end

function EventPetSaveManualModel:getWeekArrival(week)
	local curWeek = ClientActivityUtils.checkPetSaveCurWeek()

	return week <= curWeek
end

function EventPetSaveManualModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}

	return pg.getLocalizationText(pData.name)
end

function EventPetSaveManualModel:getPetCfg(templateId)
	return PetData[templateId] or nil
end

function EventPetSaveManualModel:getManualCfg()
	return PetSaveManualData[pg.me.activityPetSaveData.pshase or 1][1] or {}
end

function EventPetSaveManualModel:receivedWeekSumyReward(week)
	local weekData = self:getPetSaveWeekSumyData(week)

	return weekData and weekData.received and weekData.received == 1
end

function EventPetSaveManualModel:getSubActId(week)
	return week + 110
end

function EventPetSaveManualModel:getWeekSumyPetInfo(week)
	local showInfo
	local weekData = self:getPetSaveWeekSumyData(week)

	if weekData.pets and next(weekData.pets) then
		for i = 1, 3 do
			if weekData.pets[i] then
				showInfo = showInfo or {}
				showInfo[i] = weekData.pets[i]
			elseif showInfo and next(showInfo) then
				showInfo[i] = {}
			end
		end
	end

	return showInfo
end

return EventPetSaveManualModel
