-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\PvpChoseModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpChoseModel = Class.LightClass("PvpChoseModel", UIModel)
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PvpModeData = require("Data.pvp_mode_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local PvpRankData = require("Data.pvp_rank_data")
local Time = require("Core.Common.Time")

function PvpChoseModel:ctor()
	self.teamInfo = nil

	self:clearData()
end

function PvpChoseModel:clearData()
	self.selectTeam = {}

	for i = 1, 6 do
		self.selectTeam[i] = false
	end

	self.confirmTeam = false
end

function PvpChoseModel:getMaxPit()
	local cData = PvpModeData[pg.game.pvp.pvpMode]

	return cData and cData.fighterNum[2] or 0
end

function PvpChoseModel:getDefaultPits()
	local pitMax = self:getMaxPit()
	local res = {}

	for i = 1, pitMax do
		res[i] = {}
	end

	return res
end

function PvpChoseModel:initTeamInfos(info)
	local res = {}

	if info == nil then
		return res
	end

	for id, v in pairs(info) do
		if id == pg.me.uid then
			res.selfTeams = self:initTeamInfoInternal(v)
			res.selfScoreData = LuaUIUtils.getPVPRankInfo(v.playerScore or 0)
			res.selfName = v.playerName
		elseif id == "additionInfo" then
			res.endTime = v.endTime
			res.maxTime = v.endTime - Time.secondCache
		else
			res.otherTeams = self:initTeamInfoInternal(v, true)
			res.otherScoreData = LuaUIUtils.getPVPRankInfo(v.playerScore or 0)
			res.otherName = v.playerName
		end
	end

	self.teamInfo = res

	return res
end

function PvpChoseModel:initTeamInfoInternal(group, isEnemy)
	local res = {}

	if group == nil then
		return res
	end

	if pg.game.pvp:isFairMode() then
		local fairPvpTeamList = group.isDefaultTeam and group.defaultPets.fairPvpTeamList or group.presetInfo.fairPvpTeamList

		return self:parseTemplateIdInfo(fairPvpTeamList)
	else
		return isEnemy and self:parseTemplateIdInfo(group.pvpTemplateIds) or self:parsePetIdInfo(group.presetInfo.unfairPvpTeamList)
	end
end

function PvpChoseModel:parsePetIdInfo(teamList)
	local res = {}

	for _, id in ipairs(teamList) do
		local templateId = 0
		local pet = {}
		local cPet = pg.me.pets[id]

		if cPet then
			templateId = cPet.templateId
			pet.id = id
			pet.label = cPet.label
			pet.gender = cPet.gender
		end

		pet.templateId = templateId
		pet.empty = false
		cPet = PetData[templateId]
		pet.level = cPet and cPet.level or 1

		if cPet then
			pet.icon = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)
			pet.name = pg.getLocalizationText(cPet.name)
			pet.elements = cPet.elementType
		else
			pet.empty = true
		end

		if not pet.empty then
			res[#res + 1] = pet
		end
	end

	return res
end

function PvpChoseModel:parseTemplateIdInfo(teamList)
	local res = {}

	for _, templateId in ipairs(teamList) do
		local pet = {}

		pet.templateId = templateId
		pet.empty = false

		local cPet = PetData[templateId]

		pet.level = cPet and cPet.level or 1

		if cPet then
			pet.icon = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)
			pet.name = pg.getLocalizationText(cPet.name)
			pet.elements = cPet.elementType
		else
			pet.empty = true
		end

		if not pet.empty then
			res[#res + 1] = pet
		end
	end

	return res
end

function PvpChoseModel:checkSelected(id)
	for i, v in pairs(self.selectTeam) do
		if v == id then
			return i
		end
	end

	return 0
end

function PvpChoseModel:checkHasPos()
	local maxPit = self:getMaxPit()

	for i = 1, maxPit do
		if self.selectTeam[i] == false then
			return i
		end
	end

	return 0
end

function PvpChoseModel:selectPet(index, data)
	self.selectTeam[index] = pg.game.pvp:isFairMode() and data.templateId or data.id
end

function PvpChoseModel:deSelectPet(index)
	self.selectTeam[index] = false
end

function PvpChoseModel:checkCanReady()
	local selectNum = 0

	for _, v in pairs(self.selectTeam) do
		if v ~= false then
			selectNum = selectNum + 1
		end
	end

	if selectNum == 0 then
		return false
	end

	local maxPit = self:getMaxPit()

	if selectNum == maxPit then
		return true
	end

	local ownCount = 0

	for _, v in ipairs(self.teamInfo.selfTeams) do
		if v.templateId ~= 0 and v.id ~= "" then
			ownCount = ownCount + 1
		end
	end

	ownCount = math.min(ownCount, maxPit)

	return selectNum == ownCount
end

return PvpChoseModel
