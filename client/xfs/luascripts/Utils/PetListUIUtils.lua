-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetListUIUtils.lua

local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local lume = require("Core.Common.lume")
local pg = pg
local ToBool = ToBool
local PetListUIUtils = {}

function PetListUIUtils.fillFollowPetInfos(petInfos)
	local player = pg.me

	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				player = pg.getEntity(info.entityId)

				break
			end
		end
	end

	if not player then
		return
	end

	local petPrepareList = player.petPrepareList
	local battleMode = player.space and player.space.battleMode
	local hasSupportPet = battleMode and battleMode > 0

	for idx = 1, 4 do
		local curPetInfo = petInfos[idx]
		local petId = petPrepareList[idx]

		curPetInfo.btnValidDirty = curPetInfo.id ~= petId

		if petId then
			curPetInfo.id = petId
			curPetInfo.index = idx

			PetListUIUtils._fillSinglePetInfo(player, petId, curPetInfo)
		else
			curPetInfo.id = nil
			curPetInfo.index = -1
		end

		if hasSupportPet and battleMode < idx then
			curPetInfo.tIndex = 1
		else
			curPetInfo.tIndex = 0
		end
	end
end

function PetListUIUtils._fillSinglePetInfo(player, petId, fillTable)
	local petInfo = player:getPetInfo(petId)

	if pg.me.inTeammateView then
		petInfo = PetListUIUtils.getTeamFollowPetInfo(fillTable.index)
	end

	if petInfo == nil then
		return
	end

	local petTemplateId = petInfo.templateId
	local pData = PetData[petTemplateId]

	if pData then
		local iconUrl = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

		fillTable.iconDirty = fillTable.iconUrl ~= iconUrl
		fillTable.iconUrl = iconUrl
		fillTable.mainElementType = pData.mainElementType

		local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

		fillTable.elementIds = elementIds
		fillTable.elementDirty = fillTable.elementNames ~= elementNames
		fillTable.elementNames = elementNames

		local petFunctionType = pData.functionId
		local petFunctionTypeIcon = petFunctionType and PetConfigData.petFunctionIcon[petFunctionType]

		fillTable.petFunctionTypeIconDirty = petFunctionTypeIcon ~= fillTable.petFunctionTypeIcon
		fillTable.petFunctionTypeIcon = petFunctionTypeIcon
	end

	fillTable.levelDirty = petInfo.level ~= fillTable.level
	fillTable.level = petInfo.level
	fillTable.isTrial = petInfo.isTrial
end

function PetListUIUtils.getTeamFollowPetInfo(petIdx)
	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local player = pg.getEntity(info.entityId)
				local petPrepareInfoList = player.petPrepareList

				if petPrepareInfoList then
					local petId = petPrepareInfoList[petIdx]

					if petId == nil then
						return nil
					end

					local petInfo = {}
					local pet = pg.getEntity(petId)

					if pet == nil then
						return nil
					end

					petInfo.isSelected = petId == player.curCombatPetId

					local petTemplateId = pet.templateId
					local pData = PetData[petTemplateId] or {}

					if pData.comboAbilityId then
						petInfo.finalSkillElement = pg.global.abilityMgr:getAbilityTemplate(pData.comboAbilityId, 1).elementType
					end

					local name = pData.name

					petInfo.gender = pet.gender
					petInfo.name = name
					petInfo.iconName = pData.iconName

					local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

					petInfo.elementIds = elementIds
					petInfo.mainElementType = pData.mainElementType
					petInfo.elementNames = elementNames
					petInfo.index = petIdx
					petInfo.id = petId
					petInfo.customName = pet.customName
					petInfo.label = pet.label
					petInfo.level = pet.level

					local petFunctionType = pData.functionId

					petInfo.petFunctionTypeIcon = petFunctionType and PetConfigData.petFunctionIcon[petFunctionType]
					petInfo.isTrial = true
					petInfo.templateId = petTemplateId

					return petInfo
				end
			end
		end
	end

	return nil
end

return PetListUIUtils
