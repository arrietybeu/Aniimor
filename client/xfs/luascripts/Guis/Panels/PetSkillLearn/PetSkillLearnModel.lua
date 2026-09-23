-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkillLearn\\PetSkillLearnModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AbilityParamData = require("Data.ability_param_data")
local PetSkillData = require("Data.pet_skill_data")
local SkillTagData = require("Data.skill_tag_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local logger = LoggerManager.getLogger("PetSkillLearnModel")
local PetSkillLearnModel = Class.LightClass("PetSkillLearnModel", UIModel)

function PetSkillLearnModel:getSkillLearnData(petId)
	local res = {}
	local me = pg.me
	local pet = me:getPetInfo(petId)

	if pet == nil then
		return res
	end

	local tpId = pet.petPrototypeId
	local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(tpId)]

	if skData == nil then
		return res
	end

	for k, v in pairs(skData) do
		local abParm = AbilityParamData[k]

		if abParm == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("skill param [id:%d] is not exist", k)
		end

		local isUnlock = Utils.isPetSkillUnlock(pg.me, tpId, k)
		local tp = skData[k] and skData[k].abilityType

		if abParm and tp == "skill" and pet.unlockedAbilityMap[k] == nil then
			local rare = ToInt(AbilityUtils.isRareAbilityByParamId(k, tpId))
			local item = {
				id = k,
				skTy = tp,
				unLock = isUnlock,
				icon = abParm.icon,
				desc = LuaUIUtils.getSkillDesc(abParm, pet),
				eType = abParm.elementType,
				tpName = pg.getGameString("ABILITY_NAME_SKILL"),
				name = abParm.name,
				rare = rare,
				consume = skData[k] and skData[k].learnSkillConsume or {},
				tIndex = isUnlock and 0 or 1
			}
			local tagList = {}

			if abParm.tags then
				for _, tagId in pairs(abParm.tags) do
					tagList[#tagList + 1] = {
						tagName = SkillTagData[tagId].tagName,
						tagId = tagId
					}
				end
			end

			item.tagList = tagList

			if abParm.power then
				item.power = abParm.power
			end

			if abParm.epCost then
				item.energy = abParm.epCost
			end

			res[#res + 1] = item
		end
	end

	return res
end

return PetSkillLearnModel
