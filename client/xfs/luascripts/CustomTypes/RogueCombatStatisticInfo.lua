-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RogueCombatStatisticInfo.lua

local Class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityConst = require("Common.Const.AbilityConst")
local RogueCombatStatistic = require("CustomTypes.RogueCombatStatistic")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local CombatLogger = require("Common.Ability.CombatLogger")
local Utils = require("Common.Utils.Utils")
local pg = pg
local RogueCombatStatisticInfo = Class.LiteClass("RogueCombatStatisticInfo", CustomDict)

function RogueCombatStatisticInfo:damageHp(realDamage, combatContext)
	local finalDmg = realDamage

	if finalDmg <= 0 then
		return
	end

	local srcEntity = pg.getEntityByActorId(CombatActionTool.parseActorIdSrc(combatContext))
	local srcCombatContext = CombatActionTool.getCombatContextById(combatContext.srcCombatContextId)
	local srcBuff = srcCombatContext and srcCombatContext:buff()

	if srcBuff and AbilityUtils.isRogueEquip(srcBuff.buffData.templateId) then
		local id = tostring(srcBuff.buffData.templateId)
		local statistic = self.buff[id]

		if not statistic then
			statistic = RogueCombatStatistic({})
			self.buff[id] = statistic
		end

		statistic.damage = statistic.damage + finalDmg

		CombatLogger.debug("add buff statistic templateId %s, damage %f, total %f", id, finalDmg, statistic.damage)

		return
	end

	if not srcEntity then
		CombatLogger.warn("rogue damage statistic missing srcEntity, abilityId=%s, buffTemplateId=%s, projectileTemplateId=%s", combatContext.abilityId, combatContext.buffTemplateId, combatContext.projectileTemplateId)

		return
	end

	if srcEntity.isExtraTempPet and srcEntity:isExtraTempPet() then
		local id = tostring(srcEntity.templateId)
		local statistic = self.tempPet[id]

		if not statistic then
			statistic = RogueCombatStatistic({})
			self.tempPet[id] = statistic
		end

		statistic.damage = statistic.damage + finalDmg

		CombatLogger.debug("add tempPet statistic templateId %s, damage %f, total %f", id, finalDmg, statistic.damage)

		return
	end

	if not Utils.isPet(srcEntity) then
		if Utils.isPlayer(srcEntity) then
			srcEntity = srcEntity:getCurPetEntity()
		else
			CombatLogger.error("undefine case", srcEntity.className, srcEntity.templateId, combatContext.abilityId or combatContext.buffTemplateId or combatContext.projectileTemplateId)

			return
		end
	end

	if not srcEntity then
		CombatLogger.warn("rogue damage statistic missing pet entity after player convert, abilityId=%s, buffTemplateId=%s, projectileTemplateId=%s", combatContext.abilityId, combatContext.buffTemplateId, combatContext.projectileTemplateId)

		return
	end

	local statistic = self.pet[srcEntity.id]

	if not statistic then
		statistic = RogueCombatStatistic({})
		self.pet[srcEntity.id] = statistic
	end

	statistic.damage = statistic.damage + finalDmg

	CombatLogger.debug("add pet statistic templateId %s, damage %f, total %f", srcEntity.id, finalDmg, statistic.damage)
end

function RogueCombatStatisticInfo:takenDamage(realDamage, petEnt, combatContext)
	local finalDmg = realDamage

	if finalDmg <= 0 then
		return
	end

	if petEnt.isExtraTempPet and petEnt:isExtraTempPet() then
		local id = tostring(petEnt.templateId)
		local statistic = self.tempPet[id]

		if not statistic then
			statistic = RogueCombatStatistic({})
			self.tempPet[id] = statistic
		end

		statistic.takenDamage = statistic.takenDamage + finalDmg

		CombatLogger.debug("add TempPet statistic id %s, damage %f, total %f", petEnt.id, finalDmg, statistic.damage)

		return
	end

	local statistic = self.pet[petEnt.id]

	if not statistic then
		statistic = RogueCombatStatistic({})
		self.pet[petEnt.id] = statistic
	end

	statistic.takenDamage = statistic.takenDamage + finalDmg

	CombatLogger.debug("add pet statistic id %s, takenDamage %f, total %f", petEnt.id, finalDmg, statistic.damage)
end

function RogueCombatStatisticInfo:receiveHeal(realVal, combatContext)
	local srcEntity = pg.getEntityByActorId(CombatActionTool.parseActorIdSrc(combatContext))
	local srcCombatContext = CombatActionTool.getCombatContextById(combatContext.srcCombatContextId)
	local srcBuff = srcCombatContext and srcCombatContext:buff()

	if srcBuff and AbilityUtils.isRogueEquip(srcBuff.buffData.templateId) then
		local id = tostring(srcBuff.buffData.templateId)
		local statistic = self.buff[id]

		if not statistic then
			statistic = RogueCombatStatistic({})
			self.buff[id] = statistic
		end

		statistic.heal = statistic.heal + realVal

		CombatLogger.debug("add buff statistic templateId %s, heal %f, total %f", id, realVal, statistic.heal)

		return
	end

	if not srcEntity then
		CombatLogger.warn("rogue heal statistic missing srcEntity, abilityId=%s, buffTemplateId=%s, projectileTemplateId=%s", combatContext.abilityId, combatContext.buffTemplateId, combatContext.projectileTemplateId)

		return
	end

	if srcEntity.isExtraTempPet and srcEntity:isExtraTempPet() then
		local id = tostring(srcEntity.templateId)
		local statistic = self.tempPet[id]

		if not statistic then
			statistic = RogueCombatStatistic({})
			self.tempPet[id] = statistic
		end

		statistic.heal = statistic.heal + realVal

		CombatLogger.debug("add tempPet statistic templateId %s, damage %f, total %f", id, realVal, statistic.heal)

		return
	end

	if not Utils.isPet(srcEntity) then
		if Utils.isPlayer(srcEntity) then
			srcEntity = srcEntity:getCurPetEntity()
		else
			CombatLogger.error("undefine heal case", srcEntity.className, srcEntity.templateId, combatContext.abilityId or combatContext.buffTemplateId or combatContext.projectileTemplateId)

			return
		end
	end

	if not srcEntity then
		CombatLogger.warn("rogue heal statistic missing pet entity after player convert, abilityId=%s, buffTemplateId=%s, projectileTemplateId=%s", combatContext.abilityId, combatContext.buffTemplateId, combatContext.projectileTemplateId)

		return
	end

	local statistic = self.pet[srcEntity.id]

	if not statistic then
		statistic = RogueCombatStatistic({})
		self.pet[srcEntity.id] = statistic
	end

	statistic.heal = statistic.heal + realVal

	CombatLogger.debug("add pet statistic templateId %s, heal %f, total %f", srcEntity.id, realVal, statistic.heal)
end

function RogueCombatStatisticInfo:clearData()
	self.pet = {}
	self.tempPet = {}
	self.buff = {}
end

function RogueCombatStatisticInfo:mergeMap(selfMap, dataMap)
	for id, info in pairs(dataMap) do
		local statistic = selfMap[id]

		if not selfMap[id] then
			statistic = RogueCombatStatistic({})
			selfMap[id] = statistic
		end

		statistic.damage = info.damage
		statistic.heal = info.heal
		statistic.takenDamage = info.takenDamage
	end
end

function RogueCombatStatisticInfo:mergeData(data)
	self:mergeMap(self.pet, data.pet)
	self:mergeMap(self.tempPet, data.tempPet)
	self:mergeMap(self.buff, data.buff)
	data:clearData()
end

return RogueCombatStatisticInfo
