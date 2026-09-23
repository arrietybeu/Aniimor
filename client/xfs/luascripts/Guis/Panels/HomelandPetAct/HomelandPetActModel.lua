-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetAct\\HomelandPetActModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandPetActModel = Class.LightClass("HomelandPetActModel", UIModel)
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")

function HomelandPetActModel:checkAndFillPetEventTargetData(eventInfo, eventType, data)
	local eventTypeData = HomeEventTypeData[eventType]
	local targetNum = eventTypeData and eventTypeData.targetNum or 0
	local targetType = eventTypeData and eventTypeData.targetType
	local needOtherPet = targetType == Const.HomeEventTarget.Pet and targetNum >= 2

	if needOtherPet and targetNum > #eventInfo.targetIds then
		return false
	end

	if #eventInfo.targetIds > 1 then
		local otherPetId = eventInfo.targetIds[2]
		local otherPetInfo = pg.space.pets[otherPetId]

		if otherPetInfo then
			data.otherPetName = LuaUIUtils.getPetNameByPetInfo(otherPetInfo)
		elseif needOtherPet then
			data.otherPetName = pg.getGameString("HOMELAND_HOME_LOG_ANOTHERPET")
		end
	end

	if #eventInfo.targetIds > 2 then
		data.friendId = eventInfo.targetIds[3]
	end

	return true
end

function HomelandPetActModel:getPetActData(isResolved)
	local actData = {}
	local pets = pg.space.pets
	local eventMap = pg.space.homeEventMap

	for eventId, eventInfo in pairs(eventMap) do
		if not isResolved and eventInfo.solvedTs == 0 and #eventInfo.targetIds > 0 then
			local eventConfig = HomeEventTextData[eventInfo.textId]
			local eventType = eventConfig and eventConfig.eventType

			if eventType == 5 then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]

				local staticId = HomeLandUtils.getHomeRewardBoxId() or 72555527

				if staticId then
					local giftEntity = pg.space:getEntityByStaticId(staticId)

					if giftEntity then
						data.pos = giftEntity:getPosition()
					end
				end

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.MUTATION then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.ornamentId = tonumber(eventInfo.targetIds[1])
				data.itemId = tonumber(eventInfo.targetIds[2])

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.HELP_LOOSEN then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]
				data.count = tonumber(eventInfo.targetIds[2]) or 1
				data.friendName = eventInfo.targetIds[3]

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.LOOSEN_GIFT then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]
				data.friendName = eventInfo.targetIds[2]

				local staticId = HomeLandUtils.getTillRewardBoxId()

				if staticId then
					local giftEntity = pg.space:getEntityByStaticId(staticId)

					if giftEntity then
						data.pos = giftEntity:getPosition()
					end
				end

				table.insert(actData, data)
			end
		end
	end

	for petId, pet in pairs(pets) do
		local petEntity = pg.getEntity(petId)
		local eventInfo = pet:getHomeEventInfo(pg.space)

		if eventInfo and not isResolved and eventInfo.solvedTs == 0 then
			local data = {}

			data.petId = petId
			data.name = LuaUIUtils.getPetNameByPetInfo(pet)

			local eventType = HomeEventTextData[eventInfo.textId].eventType

			if self:checkAndFillPetEventTargetData(eventInfo, eventType, data) then
				if petEntity and petEntity.eModel then
					local _ppx, _ppy, _ppz = petEntity.eModel:GetPositionAgentPosEx()

					data.pos = Vector3.New(_ppx, _ppy, _ppz)
				end

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs

				table.insert(actData, data)
			end
		end
	end

	actData = self:sortcreateTsDESC(actData)

	return actData
end

function HomelandPetActModel:getPetResolvedActData()
	local actData = {}
	local eventMap = pg.space.homeEventMap

	for eventId, eventInfo in pairs(eventMap) do
		if eventInfo.solvedTs ~= 0 and eventInfo.targetIds and #eventInfo.targetIds > 0 then
			local eventConfig = HomeEventTextData[eventInfo.textId]
			local eventType = eventConfig and eventConfig.eventType

			if eventType == 5 then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.MUTATION then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.ornamentId = tonumber(eventInfo.targetIds[1])
				data.itemId = tonumber(eventInfo.targetIds[2])

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.PRODUCTION then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.num1 = tonumber(eventInfo.targetIds[1]) or 0
				data.num2 = tonumber(eventInfo.targetIds[2]) or 0

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.HELP_LOOSEN then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]
				data.count = tonumber(eventInfo.targetIds[2]) or 1
				data.friendName = eventInfo.targetIds[3]

				table.insert(actData, data)
			elseif eventType == Const.HOME_EVENT_TYPE.LOOSEN_GIFT then
				local data = {}

				data.textId = eventInfo.textId
				data.eventId = eventType
				data.createTs = eventInfo.createTs
				data.solvedTs = eventInfo.solvedTs
				data.friendId = eventInfo.targetIds[1]
				data.friendName = eventInfo.targetIds[2]

				table.insert(actData, data)
			else
				local petId = eventInfo.targetIds[1]
				local petInfo = pg.space.pets[petId]

				if petInfo then
					local data = {}

					data.name = LuaUIUtils.getPetNameByPetInfo(petInfo)

					if self:checkAndFillPetEventTargetData(eventInfo, eventType, data) then
						data.textId = eventInfo.textId
						data.eventId = eventType
						data.createTs = eventInfo.createTs
						data.solvedTs = eventInfo.solvedTs

						table.insert(actData, data)
					end
				end
			end
		end
	end

	actData = self:sortcreateTsDESC(actData)

	return actData
end

function HomelandPetActModel:getOfflineRewardData()
	local rewardData = {}

	for id, count in pairs(pg.me.simulateOutputMap) do
		local data = {}

		data.id = id
		data.num = count

		table.insert(rewardData, data)
	end

	return rewardData
end

function HomelandPetActModel:sortcreateTsDESC(res)
	table.sort(res, function(a, b)
		return a.createTs > b.createTs
	end)

	return res
end

return HomelandPetActModel
