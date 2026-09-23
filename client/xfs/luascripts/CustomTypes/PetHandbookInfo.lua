-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetHandbookInfo.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("PetHandbookInfo")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local Bitset = require("Common.Bitset")
local PetResearchUtils = require("Common.Utils.PetResearchUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetHandbookInfo = class.LiteClass("PetHandbookInfo", CustomDict)

function PetHandbookInfo:hasStateMask(mask, stateMask)
	return bit.band(stateMask or self.stateMask, mask) == mask
end

function PetHandbookInfo:getStateMaskRepr()
	local res = lume.imap(lume.parseMaskToList(self.stateMask), function(v)
		return Const.REPR_MAP_PET_HBMSK[v]
	end)

	return string.format("%d(%s)", self.stateMask, table.concat(res, ","))
end

function PetHandbookInfo:isKnown()
	return self:hasStateMask(Const.PET_HBMSK_KNOWN)
end

function PetHandbookInfo:isCatched()
	return self:hasStateMask(Const.PET_HBMSK_CATCHED)
end

function PetHandbookInfo:isResearched()
	return self:hasStateMask(Const.PET_HBMSK_RESEARCHED)
end

function PetHandbookInfo:isShinyKnown()
	return self:hasStateMask(Const.PET_HBMSK_SHINY_KNOWN)
end

function PetHandbookInfo:isShinyCatched()
	return self:hasStateMask(Const.PET_HBMSK_SHINY_CATCHED)
end

function PetHandbookInfo:isEvolveGet()
	return self:hasStateMask(Const.PET_HBMSK_EVOLVE_GET)
end

function PetHandbookInfo:isRainbowKnown()
	return self:hasStateMask(Const.PET_HBMSK_RAINBOW_KNOWN)
end

function PetHandbookInfo:isRainbowCatched()
	return self:hasStateMask(Const.PET_HBMSK_RAINBOW_CATCHED)
end

function PetHandbookInfo:isAvatarUnlock(subIndex)
	if self.avatarNoneResearch:isUnlock(subIndex) then
		return true
	end

	if self.avatarMaleResearch:isUnlock(subIndex) then
		return true
	end

	if self.avatarFemaleResearch:isUnlock(subIndex) then
		return true
	end

	return false
end

function PetHandbookInfo:getTotalExp()
	local prcdd = PetResearchContentData[Utils.getBasePetPrototypeId(self._name)]

	if prcdd == nil then
		return 0
	end

	local totalExp = self.exp
	local needResearchPoint = prcdd.needResearchPoint or {}

	for i = 1, self.level do
		totalExp = totalExp + (needResearchPoint[i] or 0)
	end

	return totalExp
end

function PetHandbookInfo:getReportingExp()
	local value = 0

	for _, typeInfo in self.researchPointMap:items() do
		value = value + typeInfo.researchPoint
	end

	return value
end

function PetHandbookInfo:getLevelRewardStatus(level)
	return self.levelRewardStatus[level] or Const.REWARD_STATUS_INIT
end

function PetHandbookInfo:checkIsContainAvailableReward()
	for level = Const.PET_RESEARCH_REWARD_LEVEL_MIN, Const.PET_RESEARCH_REWARD_LEVEL_MAX do
		local rewardStatus = self:getLevelRewardStatus(level)

		if rewardStatus == Const.REWARD_STATUS_CANREWARD then
			return true
		end
	end

	return false
end

function PetHandbookInfo:getResearchInfo(researchKey, subIndex, upsert)
	local KEY_MAP = Const.PET_RESEARCHKEY_MAP[researchKey] or {}
	local researchInfoKey = KEY_MAP[Const.PRM_PROPERTY]
	local researchInfo

	if researchInfoKey then
		if upsert and pg.component == "game" then
			researchInfo = self:getOrCreateOrdinaryResearchInfo(researchKey, subIndex)

			if researchInfo ~= nil then
				return researchInfo
			end
		end

		local researchMapOrInfo = self[researchInfoKey]

		if researchMapOrInfo.__ClassType.typeName == "PetResearchMap" then
			researchInfo = researchMapOrInfo:getInfo(subIndex, upsert)
		else
			researchInfo = researchMapOrInfo
		end
	end

	return researchInfo
end

function PetHandbookInfo:getTraitResearchInfo(traitId, upsert)
	if self.traitResearchMap[traitId] == nil and upsert and pg.component == "game" then
		return self:getOrCreateTraitResearchInfo(traitId)
	end

	return self.traitResearchMap[traitId]
end

function PetHandbookInfo:isTraitResearchUnlocked(traitId)
	local researchInfo = self:getTraitResearchInfo(traitId)

	return researchInfo and researchInfo.status == Const.PET_RESEARCH.STATUS_SHOW or false
end

function PetHandbookInfo:getTraitResearchUnlockedCount(needTraitId)
	needTraitId = needTraitId or 0

	local count = 0

	if needTraitId == 0 then
		for traitId, _ in self.traitResearchMap:items() do
			if self:isTraitResearchUnlocked(traitId) then
				count = count + 1
			end
		end
	else
		count = self:isTraitResearchUnlocked(needTraitId) and 1 or 0
	end

	return count
end

function PetHandbookInfo:getTraitResearchInfoWithDefault(traitId)
	local researchInfo = self.traitResearchMap[traitId]

	if researchInfo == nil then
		local initDict = PetResearchUtils.genTraitResearchInfoInitDict(self._name, traitId)

		return initDict and require("CustomTypes.PetResearch.TraitResearchInfo")(initDict)
	end

	return self.traitResearchMap[traitId]
end

function PetHandbookInfo:getEvolveResearchInfo(evolveId, upsert)
	if self.evolveResearchMap[evolveId] == nil and upsert and pg.component == "game" then
		return self:getOrCreateEvolveResearchInfo(evolveId)
	end

	return self.evolveResearchMap[evolveId]
end

function PetHandbookInfo:isEvolveResearchUnlocked(evolveId)
	local researchInfo = self:getEvolveResearchInfo(evolveId)

	return researchInfo and researchInfo.status == Const.PET_RESEARCH.STATUS_SHOW or false
end

function PetHandbookInfo:getEvolveResearchInfoWithDefault(evolveId)
	local researchInfo = self.evolveResearchMap[evolveId]

	if researchInfo == nil then
		local initDict = PetResearchUtils.genEvolveResearchInfoInitDict(self._name, evolveId)

		return initDict and require("CustomTypes.PetResearch.EvolveResearchInfo")(initDict)
	end

	return self.evolveResearchMap[evolveId]
end

function PetHandbookInfo:getSkillUnlockedCount(needRare)
	needRare = needRare or -1

	local count = 0

	if needRare == -1 then
		for _, researchInfo in self.battleResearch:items() do
			if researchInfo:isUnlock() then
				count = count + 1
			end
		end
	else
		for abilityParamId, researchInfo in self.battleResearch:items() do
			local rare = ToInt(AbilityUtils.isRareAbilityByParamId(abilityParamId, self._name))

			if researchInfo:isUnlock() and needRare == rare then
				count = count + 1
			end
		end
	end

	return count
end

function PetHandbookInfo:getAvatarResearchedCount(needLabel)
	needLabel = needLabel or -1

	local count = 0

	if needLabel == -1 then
		local function mapFunc(researchInfo)
			return researchInfo:isUnlock() or nil
		end

		local unlockMap = lume.merge(lume.map(self.avatarNoneResearch, mapFunc), lume.map(self.avatarMaleResearch, mapFunc), lume.map(self.avatarFemaleResearch, mapFunc))

		return lume.count(unlockMap)
	else
		local isUnlock = self.avatarNoneResearch:isUnlock(needLabel) or self.avatarMaleResearch:isUnlock(needLabel) or self.avatarFemaleResearch:isUnlock(needLabel)

		count = isUnlock and 1 or 0
	end

	return count
end

function PetHandbookInfo:dumpResearchMap(researchKey)
	local KEY_MAP = Const.PET_RESEARCHKEY_MAP[researchKey] or {}
	local researchInfoKey = KEY_MAP[Const.PRM_PROPERTY]
	local researchMapOrInfo = self[researchInfoKey]

	if researchMapOrInfo.__ClassType.typeName == "PetResearchMap" then
		local res = {}

		for subIndex, researchInfo in researchMapOrInfo:items() do
			if KEY_MAP[Const.PRM_RESULTKEY] == "avatar" then
				subIndex = Const.REPR_PET_LABEL_MASK[subIndex]
			end

			res[subIndex] = researchInfo:dump()
		end

		return res
	else
		return researchMapOrInfo and researchMapOrInfo:dump() or "invalidKey"
	end
end

function PetHandbookInfo:dumpTraitResearchMap()
	local res = {}

	for traitId, researchInfo in self.traitResearchMap:items() do
		res[tostring(traitId)] = researchInfo:dump()
	end

	return res
end

function PetHandbookInfo:dumpEvolveResearchMap()
	local res = {}

	for evolveId, researchInfo in self.evolveResearchMap:items() do
		res[tostring(evolveId)] = researchInfo:dump()
	end

	return res
end

function PetHandbookInfo:dump()
	local res = {
		_base = string.format("lv:%d exp:%d expAcc:%d expIng:%d", self.level, self.exp, self:getTotalExp(), self:getReportingExp()),
		_stateMask = self:getStateMaskRepr(),
		r_avatarNone = self:dumpResearchMap(Const.PET_RESEARCH.KEY_AVATAR_NONE),
		r_avatarMale = self:dumpResearchMap(Const.PET_RESEARCH.KEY_AVATAR_MALE),
		r_avatarFemale = self:dumpResearchMap(Const.PET_RESEARCH.KEY_AVATAR_FEMALE),
		r_battleSkill = self:dumpResearchMap(Const.PET_RESEARCH.KEY_BATTLE_SKILL),
		r_bodyEntry = self:dumpResearchMap(Const.PET_RESEARCH.KEY_BODY_ENTRY),
		rs_trait = self:dumpTraitResearchMap(),
		rs_evolve = self:dumpEvolveResearchMap()
	}

	return res
end

return PetHandbookInfo
