-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MakeSkill\\MakeSkillModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("MakeSkillModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local MakeSkillModel = Class.LightClass("MakeSkillModel", UIModel)
local AbilityParamData = require("Data.ability_param_data")
local AbilityParamMapData = require("Common.Data.SkillBPData.abilityId2ParamId_BP")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SkillTagData = require("Data.skill_tag_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local SKILL_NAME = {
	ultimate = "ABILITY_NAME_ULTIMATE",
	normal = "ABILITY_NAME_NORMAL",
	appear = "ABILITY_NAME_APPEAR",
	skill = "ABILITY_NAME_SKILL"
}
local Element = {
	Holy = 4,
	Grass = 3,
	Fire = 2,
	Electric = 1,
	Dark = 0,
	Psychic = 9,
	Rock = 10,
	Water = 11,
	Wind = 12,
	null = 13,
	Poison = 8,
	Normal = 7,
	Mental = 6,
	Ice = 5
}
local ElementAlter = {
	[0] = "null",
	"Normal",
	"Ice",
	"Water",
	"Electric",
	"Fire",
	"Grass",
	"Mental",
	"Rock",
	"Wind",
	"Poison",
	"Psychic",
	"Dark",
	"Holy"
}

function MakeSkillModel:getSkillData(id, tp)
	local paramId = AbilityParamMapData[id]
	local abParm = AbilityParamData[paramId]

	if abParm == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("skill param [id:%d] is not exist", id)
		end

		return nil
	end

	local item = {
		skTy = tp,
		icon = abParm.icon,
		desc = abParm.clue or "",
		eType = Element[ElementAlter[abParm.elementType]],
		tpName = pg.getLocalizationText(SKILL_NAME[tp]),
		name = abParm.name,
		rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId))
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

	local numberList = {}

	if abParm.power then
		numberList[#numberList + 1] = {
			style = 1,
			number = abParm.power
		}
	end

	if abParm.epCost then
		numberList[#numberList + 1] = {
			style = 0,
			number = abParm.epCost
		}
	end

	item.numberList = numberList

	return item
end

return MakeSkillModel
