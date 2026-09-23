-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBotPlayerCombatComponent.lua

local Class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AIUtils = require("Common.Utils.AIUtils")
local ListPool = require("Common.Container.ListPool")
local pg = pg
local EBTStatus = enums.EBTStatus
local IBotPlayerCombatComponent = Class.Component("IBotPlayerCombatComponent")

function IBotPlayerCombatComponent:OVERRIDE_getTarget(range)
	local targetActorId = AIUtils.getBotPlayerTarget(self.ent, range)

	targetActorId = AIUtils.resetCombatTargetPlayerToControllingPet(targetActorId)

	AIUtils.attackTarget(self.ent, targetActorId)

	return targetActorId
end

function IBotPlayerCombatComponent:getPetActorId(index)
	local petEnt = (index == 0 or index == nil) and self.ent:getCurPetEntity() or pg.getEntity(self.ent.petPrepareList[index])

	return petEnt and petEnt.actorId or 0
end

function IBotPlayerCombatComponent:getTeammatePetActorId(index)
	local mainPlayer = self.ent.space.mainPlayerId
	local teamMemberEntIdList = Utils.getTeamMemberEntIdWithBot(pg.getEntity(mainPlayer)) or AiConst.DefaultNullTable
	local tCurIndex = 0
	local selfId = self.ent.id

	for i = 1, #teamMemberEntIdList do
		if teamMemberEntIdList[i] ~= selfId then
			tCurIndex = tCurIndex + 1

			if tCurIndex == index then
				local teammateEnt = pg.getEntity(teamMemberEntIdList[i])
				local petEnt = teammateEnt and teammateEnt:getCurPetEntity()

				return petEnt and petEnt.actorId or 0
			end
		end
	end

	return 0
end

function IBotPlayerCombatComponent:tryCommandPetCastSupportSkill(supportTag, featureId)
	local petPrepareList = self.ent.petPrepareList

	for i = 1, #petPrepareList do
		local petEnt = pg.getEntity(petPrepareList[i])

		if (string.isNilOrEmpty(supportTag) or AbilityUtils.checkPetHasSupportTag(petEnt, supportTag)) and (featureId < 0 or AbilityUtils.checkAbilityInFeatures(petEnt.coreAbilityId, featureId)) then
			return AbilityUtils.trySwitchSupportPet(self.ent, i) and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
		end
	end

	return EBTStatus.BT_FAILURE
end

function IBotPlayerCombatComponent:getTeammatePetActorIdBySupportTag(supportTag)
	local mainPlayer = self.ent.space.mainPlayerId
	local teamMemberEntIdList = Utils.getTeamMemberEntIdWithBot(pg.getEntity(mainPlayer)) or AiConst.DefaultNullTable
	local selfId = self.ent.id

	for i = 1, #teamMemberEntIdList do
		if teamMemberEntIdList[i] ~= selfId then
			local teammateEnt = pg.getEntity(teamMemberEntIdList[i])
			local petEnt = teammateEnt and teammateEnt:getCurPetEntity()

			if AbilityUtils.checkPetHasSupportTag(petEnt, supportTag) then
				return petEnt.actorId
			end
		end
	end

	return 0
end

function IBotPlayerCombatComponent:getPetActorIdByFunctionIdFromPetList(supportTag)
	local petPrepareList = self.ent.petPrepareList

	for i = 1, #petPrepareList do
		local petEnt = pg.getEntity(petPrepareList[i])

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) and AbilityUtils.checkPetHasSupportTag(petEnt, supportTag) then
			return petEnt.actorId
		end
	end

	return 0
end

function IBotPlayerCombatComponent:switchPetByActorId(petActorId)
	local petPrepareList = self.ent.petPrepareList

	for i = 1, #petPrepareList do
		local petEnt = pg.getEntity(petPrepareList[i])

		if petEnt and petEnt.actorId == petActorId and not AbilityUtils.checkEntityIsDead(petEnt) then
			return AbilityUtils.trySwitchPet(self.ent, i) and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
		end
	end

	return EBTStatus.BT_FAILURE
end

function IBotPlayerCombatComponent:switchPetByTemplateId(templateId)
	local petPrepareList = self.ent.petPrepareList

	for i = 1, #petPrepareList do
		local petEnt = pg.getEntity(petPrepareList[i])

		if petEnt and petEnt.templateId == templateId and not AbilityUtils.checkEntityIsDead(petEnt) then
			return AbilityUtils.trySwitchPet(self.ent, i) and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
		end
	end

	return EBTStatus.BT_FAILURE
end

function IBotPlayerCombatComponent:switchPetByTeamIndex(teamIndex)
	local petPrepareList = self.ent.petPrepareList

	for i = 1, #petPrepareList do
		local petEnt = pg.getEntity(petPrepareList[i])

		if petEnt and i == teamIndex and not AbilityUtils.checkEntityIsDead(petEnt) then
			return AbilityUtils.trySwitchPet(self.ent, i) and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
		end
	end

	return EBTStatus.BT_FAILURE
end

function IBotPlayerCombatComponent:checkTargetIsFunctionId(actorId, supportTag)
	return AbilityUtils.checkPetHasSupportTag(pg.getEntityByActorId(actorId), supportTag)
end

function IBotPlayerCombatComponent:getBotPlayerPetListIsLowHpCount(lowHpPercent)
	local count = 0

	for _, id in ipairs(self.ent.petPrepareList) do
		local petEnt = pg.getEntity(id)

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) and lowHpPercent > AbilityUtils.getHpPercent(petEnt) then
			count = count + 1
		end
	end

	return count
end

function IBotPlayerCombatComponent:getPetActorIdByResistAndSupportTagList(resistActorId, supportTagList)
	local resistEnt = pg.getEntityByActorId(resistActorId)

	if not resistEnt or not resistEnt.elementTypes then
		return 0
	end

	local bestActorId = 0
	local bestFactors = ListPool.getList()

	for _, id in ipairs(self.ent.petPrepareList) do
		local petEnt = pg.getEntity(id)

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) then
			local petInfo = petEnt:getConfigData()

			for _, supportTag in ipairs(supportTagList) do
				if AbilityUtils.checkPetHasSupportTag(petEnt, supportTag) then
					local tempFactors = ListPool.getList()

					Utils.getElementsAgainstValueList(petInfo.elementType, resistEnt.elementTypes, tempFactors)

					if #bestFactors == 0 or Utils.compareElementFactors(tempFactors, bestFactors) > 0 then
						table.clearArray(bestFactors)

						for i = 1, #tempFactors do
							bestFactors[i] = tempFactors[i]
						end

						bestActorId = petEnt.actorId
					end

					ListPool.returnList(tempFactors)
				end
			end
		end
	end

	for _, v in ipairs(bestFactors) do
		if v > 1 then
			ListPool.returnList(bestFactors)

			return bestActorId
		end
	end

	ListPool.returnList(bestFactors)

	return 0
end

function IBotPlayerCombatComponent:getPetActorIdByMainTypeResistAndSupportTagList(resistActorId, supportTagList)
	local resistEnt = pg.getEntityByActorId(resistActorId)

	if not resistEnt or not resistEnt.elementTypes or not supportTagList then
		return 0
	end

	local bestActorId = 0
	local bestAgainstValue = 0

	for _, id in ipairs(self.ent.petPrepareList) do
		local petEnt = pg.getEntity(id)

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) then
			local petInfo = petEnt:getConfigData()

			if petInfo then
				for _, supportTag in ipairs(supportTagList) do
					if AbilityUtils.checkPetHasSupportTag(petEnt, supportTag) then
						local againstValue = Utils.getMainElementsAgainstValue(petInfo.mainElementType, resistEnt.elementTypes)

						if bestAgainstValue < againstValue then
							bestAgainstValue = againstValue
							bestActorId = petEnt.actorId
						end
					end
				end
			end
		end
	end

	if bestAgainstValue > 1 then
		return bestActorId
	end

	return 0
end

function IBotPlayerCombatComponent:getBattlePetActorId(playerActorId, isSupportMode)
	local playerEnt = playerActorId == 0 and self.ent or pg.getEntityByActorId(playerActorId)

	if Utils.isPlayer(playerEnt) or Utils.isBotPlayer(playerEnt) then
		local curPetEntity = isSupportMode and pg.getEntity(playerEnt.petPrepareList[1]) or playerEnt:getCurPetEntity()

		return curPetEntity and curPetEntity.actorId or 0
	end

	return 0
end

return IBotPlayerCombatComponent
