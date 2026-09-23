-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelect\\GrowthGiftSelectModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventGrowthGiftData = require("Data.event_growth_gitf_data")
local DropData = require("Data.drop_data")
local GameEventData = require("Data.game_event_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local GrowthGiftSelectModel = Class.LightClass("GrowthGiftSelectModel", UIModel)

GrowthGiftSelectModel.FormType = {
	Prismana = 1,
	Normal = 0
}

function GrowthGiftSelectModel:getActPhase(eventId)
	local eventData = eventId and GameEventData[eventId]

	return eventData and eventData.phase
end

function GrowthGiftSelectModel:getActCfg(eventId)
	local phase = self:getActPhase(eventId)

	return phase and EventGrowthGiftData[phase]
end

function GrowthGiftSelectModel.getRewardPetIdByDropId(dropId)
	if not dropId then
		return nil
	end

	local rewardList = LuaUIUtils.getRewardItemByDropId(dropId)

	for _, reward in ipairs(rewardList) do
		if reward.petId then
			return reward.petId
		end

		if reward.id and PetPrototypeData[reward.id] then
			return reward.id
		end
	end

	local dropCfg = DropData[dropId]
	local petDrop = dropCfg and dropCfg.petDrop and dropCfg.petDrop[1]

	return petDrop and petDrop[1]
end

function GrowthGiftSelectModel:getRewardPetId(dropId)
	return GrowthGiftSelectModel.getRewardPetIdByDropId(dropId)
end

function GrowthGiftSelectModel:buildPrototypeEntry(petPrototypeId)
	if not petPrototypeId then
		return nil
	end

	local petId, prismanaPetId
	local protoData = PetPrototypeData[petPrototypeId]

	if protoData and protoData.formId == Const.FormName2Id.rainbow then
		local basePetId = Utils.getBasePetPrototypeId(petPrototypeId)

		prismanaPetId = petPrototypeId
		petId = basePetId > 0 and basePetId or nil
	end

	petId = petId or petPrototypeId

	return {
		listKey = petPrototypeId,
		rewardPetId = petPrototypeId,
		petId = petId,
		prismanaPetId = prismanaPetId,
		hasShine = protoData and protoData.useShinyModel == 1 or false
	}
end

function GrowthGiftSelectModel:buildRewardEntry(dropId)
	local reward = self:buildPrototypeEntry(self:getRewardPetId(dropId))

	if reward then
		reward.dropId = dropId
		reward.listKey = dropId
	end

	return reward
end

function GrowthGiftSelectModel:getRewardList(eventId)
	local actCfg = self:getActCfg(eventId)

	if not actCfg or not actCfg.canSelectPetEggs then
		return {}
	end

	local list = {}

	for _, dropId in ipairs(actCfg.canSelectPetEggs) do
		local reward = self:buildRewardEntry(dropId)

		if reward then
			list[#list + 1] = reward
		end
	end

	return list
end

function GrowthGiftSelectModel:getCollectionList(eventId)
	local actCfg = self:getActCfg(eventId)
	local rainbowPetIdMap = actCfg and actCfg.rainbowPetId

	if not rainbowPetIdMap or not next(rainbowPetIdMap) then
		return self:getRewardList(eventId)
	end

	local petPrototypeIds = {}

	for petPrototypeId, enabled in pairs(rainbowPetIdMap) do
		if enabled ~= 0 then
			petPrototypeIds[#petPrototypeIds + 1] = petPrototypeId
		end
	end

	table.sort(petPrototypeIds)

	local list = {}

	for _, petPrototypeId in ipairs(petPrototypeIds) do
		local pet = self:buildPrototypeEntry(petPrototypeId)

		if pet then
			list[#list + 1] = pet
		end
	end

	return list
end

function GrowthGiftSelectModel:findRewardByDropId(rewardList, dropId)
	if not rewardList or not dropId then
		return nil
	end

	for _, reward in ipairs(rewardList) do
		if reward.dropId == dropId then
			return reward
		end
	end

	return nil
end

function GrowthGiftSelectModel:getReceiveCondId(eventId)
	local actCfg = self:getActCfg(eventId)

	return actCfg and actCfg.canReceiveCond or 0
end

return GrowthGiftSelectModel
