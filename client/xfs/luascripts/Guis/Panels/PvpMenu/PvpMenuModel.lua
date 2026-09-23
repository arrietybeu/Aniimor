-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\PvpMenuModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpMenuModel = Class.LightClass("PvpMenuModel", UIModel)
local PetData = require("Data.pet_data")
local FairPvpPreset = require("CustomTypes.FairPvpPreset")
local UnFairPvpPreset = require("CustomTypes.UnFairPvpPreset")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PvpModeData = require("Data.pvp_mode_data")
local PvpRankData = require("Data.pvp_rank_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local Bitset = require("Common.Bitset")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpMenuModel.STAGE_OFFSET = Vector3.New(10000, 600, 0)

function PvpMenuModel:getSelectedPetList()
	local teamList = self:getTeamList()
	local res = {}

	for i, templateId in ipairs(teamList) do
		local cPet
		local pet = {
			empty = false
		}

		if pg.game.pvp:isFairMode() then
			local tData = TmpPetTemplateData[templateId]

			if tData then
				cPet = tData and PetData[tData.templateBaseId]
				templateId = tData.templateBaseId
			end
		else
			local petId = templateId
			local pData = pg.me.pets[petId]

			if pg.me.petJewelryInfos[petId] then
				pet.appearanceData = pg.me.petJewelryInfos[petId]
			end

			if pData then
				pet.petId = petId
				templateId = pData.templateId
				cPet = PetData[pData.templateId]
				pet.label = pData.label
				pet.gender = pData.gender
			end
		end

		pet.templateId = templateId

		if cPet then
			pet.icon = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_IMG)
			pet.name = pg.getLocalizationText(cPet.name)

			local _, names = LuaUIUtils.getElementInfo(cPet.elementType)

			pet.elements = names
			pet.isBoss = Utils.isLabelElite(TmpPetTemplateData[templateId].label)
			pet.isMini = Utils.isLabelRainbow(TmpPetTemplateData[templateId].label)
			pet.isShiny = Utils.isLabelShiny(TmpPetTemplateData[templateId].label)
			pet.isVariant = Utils.isLabelVariant(TmpPetTemplateData[templateId].label)
		else
			pet.empty = true
		end

		res[i] = pet
	end

	return res
end

function PvpMenuModel:getTeamList()
	local me = pg.me

	if pg.game.pvp:isFairMode() then
		local curGroup = me.fairPvpPresetList[me.fairPvpRecentId]

		if curGroup == nil then
			curGroup = FairPvpPreset({
				fairPvpTeamName = "fair",
				fairPvpTeamList = {
					0,
					0,
					0,
					0,
					0,
					0
				}
			})
		end

		return curGroup.fairPvpTeamList
	else
		local curGroup = me.unfairPvpPresetList[me.unfairPvpRecentId]

		if curGroup == nil then
			curGroup = UnFairPvpPreset({
				fairPvpTeamName = "unfair",
				unfairPvpTeamList = {
					"",
					"",
					"",
					"",
					"",
					""
				}
			})
		end

		return curGroup.unfairPvpTeamList
	end
end

function PvpMenuModel:satisfyMinTeamNum()
	local cData = PvpModeData[pg.game.pvp.pvpMode]

	if cData == nil then
		return false, 999
	end

	local minNum = cData.petsNum[1]
	local teamList = self:getTeamList()
	local ownNum = 0

	for _, v in ipairs(teamList) do
		if v ~= 0 and v ~= "" then
			ownNum = ownNum + 1
		end
	end

	if ownNum < minNum then
		return false, minNum
	end

	return true, minNum
end

function PvpMenuModel:getScoreAndRank()
	local score = ItemUtils.getItemCountById(pg.me, ItemConst.ITEM_SPECIAL_PVP1V1_SCORE)
	local res = LuaUIUtils.getPVPRankInfo(score)

	res.winNum = pg.me.pvpCommonMap[pg.game.pvp.pvpMode].pvpWinCount
	res.reward = self:getNextReward()

	return res
end

function PvpMenuModel:getRewardList()
	local res = {}
	local score = ItemUtils.getItemCountById(pg.me, ItemConst.ITEM_SPECIAL_PVP1V1_SCORE)
	local rankList = {}

	for k, v in pairs(PvpRankData) do
		local item = {
			rankId = k
		}

		table.merge(item, v)

		rankList[#rankList + 1] = item
	end

	table.sort(rankList, function(a, b)
		return a.rank < b.rank
	end)

	for i, v in ipairs(rankList) do
		local rewardItem = {
			rankId = v.rankId
		}
		local reward = {}

		for j, rew in ipairs(v.rewardDisplay or EMPTY_TABLE) do
			local item = {
				id = rew[1],
				count = rew[2]
			}
			local cData = ItemData[item.id]

			if cData then
				item.icon = LuaUIUtils.getIconByIconId(cData.icon)
				item.name = pg.getLocalizationText(cData.itemName)
				item.quality = cData.quality
			end

			reward[j] = item
		end

		rewardItem.reward = reward
		rewardItem.hasTake = Bitset.getBit(pg.me.pvpRankAwardFlags, v.rankId) or not v.rewardDisplay
		rewardItem.canTake = not Bitset.getBit(pg.me.pvpRankAwardFlags, v.rankId) and v.rewardDisplay and score >= (v.needScore or 0)

		local randName = ClientTextUtils.concatByLanguage(pg.getLocalizationText(v.rankName), pg.getLocalizationText(v.levelName))

		rewardItem.desc = randName
		rewardItem.rewardDesc = pg.getFormatText(pg.getGameString("PVP_RANK_REWARD"), randName)
		rewardItem.icon = v.icon
		res[i] = rewardItem
	end

	return res
end

function PvpMenuModel:getNextReward()
	local rewardList = self:getRewardList()

	for _, v in ipairs(rewardList) do
		if not v.hasTake and #v.reward > 0 then
			return v
		end
	end

	return rewardList[#rewardList]
end

function PvpMenuModel:getModeName()
	local cData = PvpModeData[pg.game.pvp.pvpMode]

	if cData == nil then
		return "NULL"
	end

	return pg.getLocalizationText(cData.name)
end

function PvpMenuModel:getMinMun()
	local cData = PvpModeData[pg.game.pvp.pvpMode]

	if cData == nil then
		return 0
	end

	return cData.petsNum[1]
end

function PvpMenuModel:getPlayerInfoWithUid(uid)
	local pInfo = pg.game.chat:getPlayerInfo(uid)

	return pInfo
end

return PvpMenuModel
