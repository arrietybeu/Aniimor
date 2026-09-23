-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetsFormationComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local IDManager = require("Core.Common.IDManager")
local lume = require("Core.Common.lume")
local TablePool = require("Common.Container.TablePool")
local PetData = require("Data.pet_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local Const = require("Common.Const.Const")

local function isInFormation(formationInfo, petId)
	return lume.find(formationInfo.formation, petId) ~= nil or lume.find(formationInfo.exploreFormation, petId) ~= nil
end

local function getRawList(list)
	if list and list.getRawTable then
		return list:getRawTable()
	end

	return list or {}
end

local ClientPetsFormationComponent = class.Component("ClientPetsFormationComponent")

function ClientPetsFormationComponent:ctor()
	return
end

function ClientPetsFormationComponent:RPC_SC_OnChangePrepareFormation(index, formation)
	facade:SendMessageCommand(MessageName.MODIFY_PET_FORMATION)
end

function ClientPetsFormationComponent:checkPetHasWaterExploreAbility(petId)
	local petInfo = self.getPetInfo and self:getPetInfo(petId)

	if not petInfo or not petInfo.curAbilityMap then
		return false
	end

	local ability = petInfo.curAbilityMap[Const.SkillType.Explore]

	if not ability then
		return false
	end

	local petData = PetData[petInfo.templateId or 0]

	if not petData then
		return false
	end

	local petProtoTypeData = PetProtoTypeData[petData.petPrototypeId or 0]

	return petProtoTypeData ~= nil and petProtoTypeData.maxWater ~= nil and petProtoTypeData.maxWater > 0
end

function ClientPetsFormationComponent:isPetInOtherFormation(petId, curFormationIndex)
	for formationIndex, formationInfo in ipairs(self.prepareFormationList or EMPTY_TABLE) do
		if formationIndex ~= curFormationIndex and isInFormation(formationInfo, petId) then
			return true, formationIndex
		end
	end

	return false, nil
end

function ClientPetsFormationComponent:on_formation_changed(oldVal, newVal, formationIndex)
	if formationIndex ~= self.curPetFormationIndex then
		return
	end

	local oldList = getRawList(oldVal)
	local newList = getRawList(newVal)
	local addedPets = TablePool.getTable()
	local oldPetMap = TablePool.getTable()

	for _, petId in ipairs(oldList) do
		oldPetMap[petId] = true
	end

	for _, petId in ipairs(newList) do
		if not oldPetMap[petId] then
			addedPets[#addedPets + 1] = petId
		end
	end

	for _, petId in ipairs(addedPets) do
		local isInOtherFormation, otherFormationIndex = self:isPetInOtherFormation(petId, formationIndex)

		if not isInOtherFormation and self:checkPetHasWaterExploreAbility(petId) then
			self:setPetCurWater(petId, 0)
		end
	end

	TablePool.returnTable(oldPetMap)
	TablePool.returnTable(addedPets)
end

function ClientPetsFormationComponent:on_exploreFormation_changed(oldVal, newVal, formationIndex)
	facade:SendMessageCommand(MessageName.MODIFY_PET_EXPLORE_FORMATION)
end

function ClientPetsFormationComponent:on_curPetFormationIndex_changed(ov, nv)
	facade:SendMessageCommand(MessageName.FIGHT_GROUP_CHANGE)
end

function ClientPetsFormationComponent:RPC_SC_OnRenamePrepareFormation(index, newName)
	facade:sendMsgToUI(MessageName.ON_GROUP_NAME_CHANGE, {
		index = index,
		newName = newName
	})
end

function ClientPetsFormationComponent:isInAnyFormation(petId)
	for _, formationInfo in ipairs(self.prepareFormationList) do
		if isInFormation(formationInfo, petId) then
			return true
		end
	end

	return false
end

return ClientPetsFormationComponent
