-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ArkPartyChoice\\ArkPartyChoiceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetData = require("Data.pet_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local PuppetData = require("Data.puppet_data")
local EventArkCarnData = require("Data.event_ark_carn_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ArkPartyChoiceModel = Class.LightClass("ArkPartyChoiceModel", UIModel)

function ArkPartyChoiceModel:getDrummerData(phaseId, stageId)
	local eventArkCarnData = EventArkCarnData[phaseId][stageId]
	local drummers = eventArkCarnData.votePetListeDrummer
	local drummerDatas = {}
	local maxVoteNum = 0

	for index, id in pairs(drummers) do
		local data = {}
		local puppetData = PuppetData[id]

		data.id = id

		if pg.me.arkCarnVotePet and table.contains(pg.me.arkCarnVotePet, id) then
			data.isVoted = true
		end

		data.index = index
		data.name = LuaUIUtils.getPetFormNameByPrototypeId(puppetData.petPrototypeId)
		data.voteNum = pg.game.event:getArkPartyVoteNum(eventArkCarnData.voteDrummerKey, id)

		if data.voteNum then
			data.votePec = data.voteNum / pg.game.event:getArkPartyVoteSumNum(eventArkCarnData.voteDrummerKey)
		else
			data.voteNum = 0
			data.votePec = 0
		end

		if maxVoteNum < data.voteNum then
			maxVoteNum = data.voteNum
		end

		table.insert(drummerDatas, data)
	end

	for _, data in ipairs(drummerDatas) do
		if data.voteNum == maxVoteNum then
			data.isMax = true

			break
		end
	end

	return drummerDatas
end

function ArkPartyChoiceModel:getDancerData(phaseId, stageId)
	local eventArkCarnData = EventArkCarnData[phaseId][stageId]
	local dancers = eventArkCarnData.votePetListDancer
	local dancerDatas = {}
	local maxVoteNum = 0

	for index, id in pairs(dancers) do
		local data = {}
		local puppetData = PuppetData[id]

		data.id = id

		if pg.me.arkCarnVotePet and table.contains(pg.me.arkCarnVotePet, id) then
			data.isVoted = true
		end

		data.index = index
		data.name = LuaUIUtils.getPetFormNameByPrototypeId(puppetData.petPrototypeId)
		data.voteNum = pg.game.event:getArkPartyVoteNum(eventArkCarnData.voteDancerKey, id)

		if data.voteNum then
			data.votePec = data.voteNum / pg.game.event:getArkPartyVoteSumNum(eventArkCarnData.voteDancerKey)
		else
			data.voteNum = 0
			data.votePec = 0
		end

		if maxVoteNum < data.voteNum then
			maxVoteNum = data.voteNum
		end

		table.insert(dancerDatas, data)
	end

	for _, data in ipairs(dancerDatas) do
		if data.voteNum == maxVoteNum then
			data.isMax = true

			break
		end
	end

	return dancerDatas
end

function ArkPartyChoiceModel:getAccompanyData(phaseId, stageId)
	local eventArkCarnData = EventArkCarnData[phaseId][stageId]
	local accompanies = eventArkCarnData.votePetListAccompany
	local accompanyDatas = {}
	local maxVoteNum = 0

	for index, id in pairs(accompanies) do
		local data = {}
		local puppetData = PuppetData[id]

		data.id = id

		if pg.me.arkCarnVotePet and table.contains(pg.me.arkCarnVotePet, id) then
			data.isVoted = true
		end

		data.index = index
		data.name = LuaUIUtils.getPetFormNameByPrototypeId(puppetData.petPrototypeId)
		data.voteNum = pg.game.event:getArkPartyVoteNum(eventArkCarnData.voteAccompanyKey, id)

		if data.voteNum then
			data.votePec = data.voteNum / pg.game.event:getArkPartyVoteSumNum(eventArkCarnData.voteAccompanyKey)
		else
			data.voteNum = 0
			data.votePec = 0
		end

		if maxVoteNum < data.voteNum then
			maxVoteNum = data.voteNum
		end

		table.insert(accompanyDatas, data)
	end

	for _, data in ipairs(accompanyDatas) do
		if data.voteNum == maxVoteNum then
			data.isMax = true

			break
		end
	end

	return accompanyDatas
end

function ArkPartyChoiceModel:getAtmosData(phaseId, stageId)
	local eventArkCarnData = EventArkCarnData[phaseId][stageId]
	local atmos = eventArkCarnData.votePetListAtmos
	local atmosDatas = {}
	local maxVoteNum = 0

	for index, id in pairs(atmos) do
		local data = {}
		local puppetData = PuppetData[id]

		data.id = id

		if pg.me.arkCarnVotePet and table.contains(pg.me.arkCarnVotePet, id) then
			data.isVoted = true
		end

		data.index = index
		data.name = LuaUIUtils.getPetFormNameByPrototypeId(puppetData.petPrototypeId)
		data.voteNum = pg.game.event:getArkPartyVoteNum(eventArkCarnData.voteAtmosKey, id)

		if data.voteNum then
			data.votePec = data.voteNum / pg.game.event:getArkPartyVoteSumNum(eventArkCarnData.voteAtmosKey)
		else
			data.voteNum = 0
			data.votePec = 0
		end

		if maxVoteNum < data.voteNum then
			maxVoteNum = data.voteNum
		end

		table.insert(atmosDatas, data)
	end

	for _, data in ipairs(atmosDatas) do
		if data.voteNum == maxVoteNum then
			data.isMax = true

			break
		end
	end

	return atmosDatas
end

return ArkPartyChoiceModel
