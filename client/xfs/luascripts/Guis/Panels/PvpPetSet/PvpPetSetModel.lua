-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpPetSet\\PvpPetSetModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpPetSetModel = Class.LightClass("PvpPetSetModel", UIModel)
local PvpModeData = require("Data.pvp_mode_data")
local PvpGroupSetData = require("Data.pvp_preset_group_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetData = require("Data.pet_data")
local PetCharacterData = require("Data.pet_character_data")
local ElementNameToId = require("Data.element_name_to_id")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FairPvpPreset = require("CustomTypes.FairPvpPreset")
local UnFairPvpPreset = require("CustomTypes.UnFairPvpPreset")
local NoticeDef = require("Common.NoticeDef")
local Lume = require("Core.Common.lume")
local SkillTagData = require("Data.skill_tag_data")
local ElementPropData = require("Data.element_prop_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetNatureData = require("Data.pet_nature_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ActorUtils = require("Common.Utils.ActorUtils")
local Utils = require("Common.Utils.Utils")
local PvpPetInfo = require("CustomTypes.PvpPetInfo")
local ClientUtils = require("Utils.ClientUtils")

PvpPetSetModel.ABILITY_LIST = {
	AbilityConst.WEAPON_NORMAL_ATK_ABILITY,
	AbilityConst.ULTIMATE_ABILITY,
	AbilityConst.APPEAR_ABILITY,
	AbilityConst.WEAPON_SKILL_ABILITY,
	AbilityConst.WEAPON_SKILL_ABILITY2
}

function PvpPetSetModel:ctor()
	self.petsMap = nil
	self.petList = nil
	self.operationGroup = nil
	self.rogueSelectPets = {
		"",
		"",
		"",
		"",
		"",
		""
	}
end

function PvpPetSetModel:setContextInfo(context)
	self.context = context
end

function PvpPetSetModel:initPetList()
	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		self:initFairPetList()
	else
		self:initUnFairPetList()
	end
end

function PvpPetSetModel:initFairPetList()
	local modeData = PvpModeData[pg.game.pvp.pvpMode]
	local units = modeData.unitGroup or {}
	local temps = {}

	for _, id in pairs(units) do
		local groups = PvpGroupSetData[id]

		for sequence, v in pairs(groups) do
			if temps[v.petId] == nil then
				temps[v.petId] = {}
				temps[v.petId].unlock = v.specialOpen or self:checkOwnPet(v.petId)
				temps[v.petId].sequence = sequence or 1
			end
		end
	end

	local res = {}
	local map = {}
	local petMap = pg.me.pvpPetInfoMap

	for id, v in pairs(temps) do
		local pet = {
			empty = false,
			serverData = petMap[id],
			configData = {},
			unlock = v.unlock,
			id = id,
			templateId = id,
			sequence = v.sequence or 1
		}

		if pet.serverData == nil then
			local genData = Utils.genEmptyPvpPetInfo(id)

			pet.serverData = PvpPetInfo(genData)
		end

		local cPet = PetData[id]

		if cPet then
			self:setUpPetInfo(pet)
		end

		res[#res + 1] = pet
		map[id] = pet
	end

	table.sort(res, function(a, b)
		return a.sequence <= b.sequence
	end)

	self.petList = res
	self.petsMap = map
end

function PvpPetSetModel:initUnFairPetList()
	local pets = pg.me.pets
	local res = {}
	local map = {}

	for id, v in pairs(pets) do
		local pet = {
			empty = false,
			unlock = true,
			configData = {},
			templateId = v.templateId
		}

		pet.serverData = v

		local cPet = PetData[v.templateId]

		if cPet then
			self:setUpPetInfo(pet)
		end

		pet.id = v.id
		res[#res + 1] = pet
		map[id] = pet
	end

	self.petList = res
	self.petsMap = map
end

function PvpPetSetModel:getPetList()
	if pg.me.space:isRogueEnv() then
		local res = {}
		local curRoguePets = pg.me.selectRoguePets or {}

		for index, value in ipairs(self.petList) do
			if curRoguePets[value.id] then
				table.insert(res, value)
			end
		end

		return res
	end

	return self.petList
end

function PvpPetSetModel:checkOwnPet(tmpId)
	local tpdd = TmpPetTemplateData[tmpId]
	local templateId = tpdd and tpdd.templateBaseId
	local pets = pg.me.pets

	for _, pet in pairs(pets) do
		if pet.templateId == templateId then
			return true
		end
	end

	return false
end

function PvpPetSetModel:getPetGroup()
	local me = pg.me
	local curGroup
	local fairMode = pg.game.pvp:isFairMode() and not self.context.isRogue

	if fairMode then
		curGroup = me.fairPvpPresetList[me.fairPvpRecentId]

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
	else
		curGroup = me.unfairPvpPresetList[me.unfairPvpRecentId]

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
	end

	return curGroup
end

function PvpPetSetModel:initRecorder()
	self.operationGroup = self:getPetGroup()

	local recorder

	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		recorder = {
			fairPvpTeamName = self.operationGroup.fairPvpTeamName,
			fairPvpTeamList = self.operationGroup.fairPvpTeamList:getRawTable()
		}
	else
		recorder = {
			unfairPvpTeamName = self.operationGroup.unfairPvpTeamName,
			unfairPvpTeamList = self.operationGroup.unfairPvpTeamList:getRawTable()
		}
	end

	self.pvpTeamListRecord = Utils.deepCopyTable(recorder)
end

function PvpPetSetModel:getSelectedPetList()
	local petList

	if self.operationGroup == nil then
		self.operationGroup = self:getPetGroup()
	end

	if pg.game.pvp:isFairMode() then
		petList = self.operationGroup.fairPvpTeamList
	else
		petList = self.operationGroup.unfairPvpTeamList
	end

	if self.context.isRogue then
		petList = self.rogueSelectPets

		if pg.me.space:isRogueEnv() then
			local curPets = pg.me.selectRoguePets or {}

			for index, value in pairs(curPets) do
				petList[value] = index
			end
		end
	end

	local res = {}

	for i, templateId in ipairs(petList) do
		local pet

		if templateId and templateId ~= 0 and templateId ~= "" then
			pet = self.petsMap[templateId]

			if pet == nil then
				pet = {
					empty = true,
					templateId = templateId
				}
			else
				pet.empty = false
			end
		else
			pet = {
				empty = true,
				templateId = templateId
			}
		end

		res[i] = pet
	end

	return res
end

function PvpPetSetModel:setUpPetInfo(petInfo)
	local templateId = petInfo.templateId

	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		local tpdd = TmpPetTemplateData[petInfo.templateId]

		templateId = tpdd and tpdd.templateBaseId
		petInfo.configData.level = petInfo.level or TmpPetTemplateData[petInfo.templateId].DefaultLevel
		petInfo.configData.gender = TmpPetTemplateData[petInfo.templateId].DefaultGen
		petInfo.configData.nature = PetNatureData[TmpPetTemplateData[petInfo.templateId].DefaultNature].name
		petInfo.configData.isBoss = Utils.isLabelElite(TmpPetTemplateData[petInfo.templateId].label)
		petInfo.configData.isMini = Utils.isLabelRainbow(TmpPetTemplateData[petInfo.templateId].label)
		petInfo.configData.isShiny = Utils.isLabelShiny(TmpPetTemplateData[petInfo.templateId].label)
		petInfo.configData.isVariant = Utils.isLabelVariant(TmpPetTemplateData[petInfo.templateId].label)
		petInfo.configData.exp = 0
		petInfo.configData.cp = petInfo.serverData:getCpValue()
		petInfo.configData.height = 0
		petInfo.configData.weight = 0
		petInfo.configData.propertyEnhanced = false
	else
		petInfo.configData.level = petInfo.serverData.level or 1
		petInfo.configData.gender = petInfo.serverData.gender
		petInfo.configData.nature = PetNatureData[petInfo.serverData.nature].name
		petInfo.configData.isBoss = Utils.isLabelElite(petInfo.serverData.label)
		petInfo.configData.isMini = Utils.isLabelRainbow(petInfo.serverData.label)
		petInfo.configData.isShiny = Utils.isLabelShiny(petInfo.serverData.label)
		petInfo.configData.isVariant = Utils.isLabelVariant(petInfo.serverData.label)
		petInfo.configData.exp = petInfo.serverData.exp
		petInfo.configData.cp = petInfo.serverData:getCpValue()
		petInfo.configData.height = petInfo.serverData.height
		petInfo.configData.weight = petInfo.serverData.weight
		petInfo.configData.propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo.serverData)
	end

	local pData = PetData[templateId] or {}

	petInfo.configData.templateId = templateId
	petInfo.configData.icon = pData.iconName
	petInfo.configData.name = pg.getLocalizationText(pData.name)

	local prototypeData = PetPrototypeData[templateId]
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.configData.elementIds = elementIds
	petInfo.configData.elementNames = elementNames
	petInfo.configData.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
		canSwim = pData.canSwim ~= nil and pData.canSwim or nil
	}

	self:refreshConfigData(petInfo)
end

function PvpPetSetModel:refreshConfigData(petInfo)
	petInfo.configData.talentPointDetail = {}
	petInfo.configData.strengthenPointDetail = {}
	petInfo.configData.speciesPointDetail = {}
	petInfo.configData.totalPointDetail = {}

	local basePropertyList

	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		basePropertyList = petInfo.serverData:getBasePropertyListDict()
	else
		basePropertyList = petInfo.serverData.basePropertyList
	end

	petInfo.configData.basePropertyList = basePropertyList

	for i, property in ipairs(basePropertyList) do
		petInfo.configData.strengthenPointDetail[i] = property.strengthenPoint
		petInfo.configData.speciesPointDetail[i] = property.speciesPoint
		petInfo.configData.totalPointDetail[i] = property.total
	end

	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		petInfo.configData.remainStrengthenPoints = self:getRemainStrengthenPoint(petInfo)
		petInfo.configData.maxCustomStrengthenPoints = TmpPetTemplateData[petInfo.templateId].strengthenPoint
	else
		petInfo.configData.remainStrengthenPoints = 0
		petInfo.configData.maxCustomStrengthenPoints = 0
	end
end

function PvpPetSetModel:getRemainStrengthenPoint(petInfo)
	local maxCustomStrengthenPoints = 0
	local usedStrengthenPoint = 0
	local basePropertyList = petInfo.serverData:getBasePropertyListDict()

	for i, _ in ipairs(basePropertyList) do
		usedStrengthenPoint = usedStrengthenPoint + 0
	end

	return maxCustomStrengthenPoints - usedStrengthenPoint
end

function PvpPetSetModel:checkCanSelect(data)
	return true
end

function PvpPetSetModel:selectPet(index, data)
	local me = pg.me
	local teamList
	local fairMode = pg.game.pvp:isFairMode() and not self.context.isRogue

	if fairMode then
		teamList = self.operationGroup.fairPvpTeamList
	else
		teamList = self.operationGroup.unfairPvpTeamList
	end

	if self.context.isRogue then
		teamList = self.rogueSelectPets
	end

	local oldIdx = -1

	for i, v in ipairs(teamList) do
		if fairMode then
			if v == data.templateId then
				oldIdx = i

				break
			end
		elseif v == data.id then
			oldIdx = i

			break
		end
	end

	if oldIdx > -1 then
		local tmpId = teamList[index]

		teamList[index] = fairMode and data.templateId or data.id
		teamList[oldIdx] = tmpId
	else
		teamList[index] = fairMode and data.templateId or data.id
	end

	self:sendSaveTeamInfoMsg()
end

function PvpPetSetModel:deSelectPet(index, data)
	if self.operationGroup == nil then
		return
	end

	if self.context.isRogue then
		self.rogueSelectPets[index] = ""

		return
	end

	if pg.game.pvp:isFairMode() then
		self.operationGroup.fairPvpTeamList[index] = 0
	else
		self.operationGroup.unfairPvpTeamList[index] = ""
	end

	self:sendSaveTeamInfoMsg()
end

function PvpPetSetModel:getFeatureInfo(featureId)
	return PetCharacterData[featureId]
end

function PvpPetSetModel:getPetSkillData(petInfo, type)
	if pg.game.pvp:isFairMode() and not self.context.isRogue then
		local tpdd = TmpPetTemplateData[petInfo.templateId]
		local curAbilityMap = ActorUtils.genPvpAbility(tpdd.templateBaseId) or {}
		local abilities = {}

		for k, v in pairs(curAbilityMap) do
			abilities[k] = AbilityUtils.getAbilityIdByParamId(tpdd.templateBaseId, v)
		end

		local serverData = self.petsMap[petInfo.templateId].serverData
		local skill1 = serverData.abilityPresetMap[serverData.curAbilityPreset][AbilityConst.WEAPON_SKILL_ABILITY]
		local skill2 = serverData.abilityPresetMap[serverData.curAbilityPreset][AbilityConst.WEAPON_SKILL_ABILITY2]

		abilities[AbilityConst.WEAPON_SKILL_ABILITY] = skill1 ~= 0 and skill1 or abilities[AbilityConst.WEAPON_SKILL_ABILITY]
		abilities[AbilityConst.WEAPON_SKILL_ABILITY2] = skill2 ~= 0 and skill2 or abilities[AbilityConst.WEAPON_SKILL_ABILITY2]

		return self:getPetSkillInfos(abilities, type, true)
	else
		local curAbilityMap = pg.me:getPetInfo(petInfo.id).curAbilityMap

		return self:getPetSkillInfos(curAbilityMap, type)
	end
end

function PvpPetSetModel:getPetSkillInfos(abilities, type, isFairMode)
	local abilityType = type
	local ability = abilities[abilityType]

	if ability then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(isFairMode and ability or ability.abilityId)
		local abilityInfo = Lume.clone(abilityParamData)

		abilityInfo.abilityId = isFairMode and ability or ability.abilityId
		abilityInfo.abilityType = abilityType

		local numberList = {}

		numberList[#numberList + 1] = {
			number = abilityInfo.epCost or 0
		}
		numberList[#numberList + 1] = {
			number = abilityInfo.power or 0
		}
		abilityInfo.numberList = numberList

		local tagList = {}

		if abilityInfo.tags then
			for _, tagId in pairs(abilityInfo.tags) do
				tagList[#tagList + 1] = {
					tagName = SkillTagData[tagId].tagName
				}
			end
		end

		abilityInfo.tagList = tagList
		abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[abilityType])

		return abilityInfo
	end

	return nil
end

function PvpPetSetModel:getCurFightIdx()
	local pvpPetSet = pg.global.ui.pvpPetSet
	local serverData = pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData

	return serverData.curAbilityPreset
end

function PvpPetSetModel:sendSaveTeamInfoMsg()
	if self.operationGroup == nil then
		return
	end

	local me = pg.me
	local recentId = me.fairPvpRecentId
	local res
	local fairMode = pg.game.pvp:isFairMode() and not self.context.isRogue

	if fairMode then
		res = {
			fairPvpTeamName = self.operationGroup.fairPvpTeamName,
			fairPvpTeamList = self.operationGroup.fairPvpTeamList:getRawTable()
		}

		for i, v in ipairs(res.fairPvpTeamList) do
			if not self:checkPetExist(v) then
				res.fairPvpTeamList[i] = 0
			end
		end
	else
		res = {
			unfairPvpTeamName = self.operationGroup.unfairPvpTeamName,
			unfairPvpTeamList = self.operationGroup.unfairPvpTeamList:getRawTable()
		}
		recentId = me.unfairPvpRecentId
	end

	if self.pvpTeamListRecord and self:compareTeam(res, fairMode) then
		return
	end

	me:setTeamTemplate(res, recentId, fairMode, function(result)
		if result == NoticeDef.SUCCESS then
			ClientUtils.showBubbleMessage(2115)

			if fairMode then
				self.pvpTeamListRecord = {
					fairPvpTeamList = Utils.deepCopyTable(res.fairPvpTeamList),
					fairPvpTeamName = res.fairPvpTeamName
				}
			else
				self.pvpTeamListRecord = {
					unfairPvpTeamList = Utils.deepCopyTable(res.unfairPvpTeamList),
					unfairPvpTeamName = res.unfairPvpTeamName
				}
			end
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("PVP_TEAM_TEMPLATE_SET_FAIL"))
		end
	end)
end

function PvpPetSetModel:compareTeam(teamRes, fairMode)
	local condition1 = false
	local condition2 = false
	local teamList, compairList

	if fairMode then
		condition1 = teamRes.fairPvpTeamName == self.pvpTeamListRecord.fairPvpTeamName
		teamList = teamRes.fairPvpTeamList
		compairList = self.pvpTeamListRecord.fairPvpTeamList
	else
		condition1 = teamRes.unfairPvpTeamName == self.pvpTeamListRecord.unfairPvpTeamName
		teamList = teamRes.unfairPvpTeamList
		compairList = self.pvpTeamListRecord.unfairPvpTeamList
	end

	for k, v in pairs(teamList) do
		condition2 = v == compairList[k]

		if condition2 == false then
			break
		end
	end

	return condition1 == true and condition2 == true
end

function PvpPetSetModel:checkPetExist(pId)
	return TmpPetTemplateData[pId] ~= nil
end

return PvpPetSetModel
