-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\ActorCombatAttribute.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local math = math
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TablePool = require("Common.Container.TablePool")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local PuppetData = require("Data.puppet_data")
local AttributeData = require("Data.attribute_id_data")
local FormulaData = require("Data.formula_data")
local SysConfigData = require("Data.sys_config_data")
local ActorCombatAttribute = Class.LiteClass("ActorCombatAttribute")
local pg = pg
local unpack = unpack

function ActorCombatAttribute:ctor(actorInterface, attributeModifier)
	self.actorInterface = actorInterface
	self.attributeModifier = attributeModifier
	self._baseAttr = actorInterface:getBaseAttr()
	self.notifyInstanceId = 1000
	self.attrNotifyFuncs = {}

	if actorInterface:isPuppet() then
		local templateId = actorInterface:getTemplateId()
		local puppetData = PuppetData[templateId]

		if puppetData then
			if puppetData.runspeedRange then
				self.runSpeedRange = {
					puppetData.runspeedRange[1],
					puppetData.runspeedRange[2]
				}
			end

			if puppetData.walkSpeedRange then
				self.walkSpeedRange = {
					puppetData.walkspeedRange[1],
					puppetData.walkspeedRange[2]
				}
			end

			if puppetData.sidewalkspeedRange then
				self.sidewalkspeedRange = {
					puppetData.sidewalkspeedRange[1],
					puppetData.sidewalkspeedRange[2]
				}
			end

			if puppetData.walkbackspeedRange then
				self.walkbackspeedRange = {
					puppetData.walkbackspeedRange[1],
					puppetData.walkbackspeedRange[2]
				}
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("puppetData not found", templateId)
		end
	elseif actorInterface:isPet() then
		local petData = actorInterface:getConfigData()

		if petData then
			if petData.runspeedRange then
				self.runSpeedRange = {
					petData.runspeedRange[1],
					petData.runspeedRange[2]
				}
			end

			if petData.walkSpeedRange then
				self.walkSpeedRange = {
					petData.walkspeedRange[1],
					petData.walkspeedRange[2]
				}
			end

			if petData.sidewalkspeedRange then
				self.sidewalkspeedRange = {
					petData.sidewalkspeedRange[1],
					petData.sidewalkspeedRange[2]
				}
			end

			if petData.walkbackspeedRange then
				self.walkbackspeedRange = {
					petData.walkbackspeedRange[1],
					petData.walkbackspeedRange[2]
				}
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("petData not found", templateId)
		end
	end

	self.isPet = self.actorInterface:isPet()
	self.isPlayer = self.actorInterface:isPlayer()
	self.isPuppet = self.actorInterface:isPuppet()

	if self.isPet then
		local masterEntity = self.actorInterface:getMasterEntity()

		if masterEntity then
			self.masterActorCombatAttribute = masterEntity.actorCombatAttribute
		end
	elseif self.isPlayer then
		local petEntity = self.actorInterface:getCurPetEntity()

		if petEntity and not petEntity.actorCombatAttribute then
			petEntity.masterActorCombatAttribute = self
		end
	end

	self.entity = self.actorInterface:getEntity()
	self.isVirtualEntity = self.actorInterface:isVirtualEntity()
	self.actorId = self.actorInterface:getActorId()
	self.space = self.actorInterface:getSpace()
end

function ActorCombatAttribute:registerAttributeNotify(attributeId, notifyFunc)
	if self.attrNotifyFuncs[attributeId] == nil then
		self.attrNotifyFuncs[attributeId] = {}
	end

	local notifyId = self.notifyInstanceId

	self.attrNotifyFuncs[attributeId][self.notifyInstanceId] = notifyFunc
	self.notifyInstanceId = self.notifyInstanceId + 1

	return notifyId
end

function ActorCombatAttribute:unregisterAttributeNotify(attributeId, instanceId)
	if self.attrNotifyFuncs[attributeId] == nil or self.attrNotifyFuncs[attributeId][instanceId] == nil then
		return
	end

	self.attrNotifyFuncs[attributeId][instanceId] = nil
end

function ActorCombatAttribute:notifyAttributeChange(attributeId, old, new)
	local notifyFuncs = self.attrNotifyFuncs[attributeId]
	local entity = self.entity

	if notifyFuncs ~= nil then
		for _, notifyFunc in pairs(notifyFuncs) do
			notifyFunc(entity, old, new)
		end
	end
end

function ActorCombatAttribute:clear()
	return
end

function ActorCombatAttribute:getAttribValue(attributeId)
	if self.isPet and AbilityUtils.isGroupAttribute(attributeId) then
		return self.masterActorCombatAttribute and self.masterActorCombatAttribute:getRawAttribValue(attributeId) or 0
	end

	return self._baseAttr[attributeId] or 0
end

function ActorCombatAttribute:getRawAttribValue(attributeId)
	return self._baseAttr[attributeId] or 0
end

function ActorCombatAttribute:getGroupAttribute(attributeId)
	if self.isPet then
		return self.masterActorCombatAttribute and self.masterActorCombatAttribute._baseAttr[attributeId] or 0
	else
		return self._baseAttr[attributeId]
	end
end

function ActorCombatAttribute.checkAttributeValue(attributeId, value)
	local min, max = unpack(pg.global.abilityMgr.attributeRangeMap[attributeId])

	if min ~= nil and value < min then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("attribute out of range min", AttributeConst.ID2NAME[attributeId], value, min)
		end

		return min
	end

	if max ~= nil and max < value then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("attribute out of range max", AttributeConst.ID2NAME[attributeId], value, max)
		end

		return max
	end

	return value
end

function ActorCombatAttribute:setAttribute(attributeId, value, notifyEvent)
	if self._baseAttr[attributeId] == value then
		return false
	end

	value = ActorCombatAttribute.checkAttributeValue(attributeId, value)

	local oldValue = self._baseAttr[attributeId]

	self._baseAttr[attributeId] = value

	if notifyEvent ~= false then
		self:onAttributeChange(attributeId, oldValue, value)
	end

	return true
end

function ActorCombatAttribute:onAttributeChange(attributeId, oldValue, value)
	self:notifyAttributeChange(attributeId, oldValue, value)

	if self.isVirtualEntity then
		return
	end

	local entity = self.entity

	if not entity.subject then
		return
	end

	local context

	if entity.subject and entity.subject:isEventListening(AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE) then
		context = pg.global.abilityMgr.attributeChangeContextPool:get(true)
		context.attributeId = attributeId
		context.oldValue = oldValue
		context.value = value
		context.actorId = self.actorId

		entity.subject:notify(AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE, context)
	end

	if Utils.isPlayerPet(entity) then
		local master = entity:getMasterEntity()

		if master.subject and master.subject:isEventListening(AbilityConst.COMBAT_EVENT_PET_ATTRIBUTE_CHANGE) then
			if context == nil then
				context = pg.global.abilityMgr.attributeChangeContextPool:get(true)
				context.attributeId = attributeId
				context.oldValue = oldValue
				context.value = value
				context.actorId = self.actorId
			end

			master.subject:notify(AbilityConst.COMBAT_EVENT_PET_ATTRIBUTE_CHANGE, context)
		end
	end

	pg.global.abilityMgr.attributeChangeContextPool:returnObject(context)
end

function ActorCombatAttribute:changeAttribValue(attributeId, value)
	if value == 0 or not value then
		return
	end

	local oldValue = self._baseAttr[attributeId]

	self:setAttribute(attributeId, oldValue + value)
end

function ActorCombatAttribute:getHp()
	return self:getRawAttribValue(AttributeConst.hp_cur)
end

function ActorCombatAttribute:getSp()
	if self.isPet then
		return self.masterActorCombatAttribute and self.masterActorCombatAttribute:getRawAttribValue(AttributeConst.sp_cur) or 0
	else
		return self._baseAttr[AttributeConst.sp_cur] or 0
	end
end

function ActorCombatAttribute:getEp()
	return self:getGroupAttribute(AttributeConst.ep_cur) + self:getGroupAttribute(AttributeConst.ep_temp_cur)
end

function ActorCombatAttribute:getTempEp()
	return self:getGroupAttribute(AttributeConst.ep_temp_cur)
end

function ActorCombatAttribute:getTp()
	return self._baseAttr[AttributeConst.tp_cur] or 0
end

function ActorCombatAttribute:getTempTp()
	return self._baseAttr[AttributeConst.tp_temp_cur] or 0
end

function ActorCombatAttribute:getBp()
	return self._baseAttr[AttributeConst.bp_cur] or 0
end

function ActorCombatAttribute:getMaxHp()
	return self._baseAttr[AttributeConst.hp_max_cur] or 0
end

function ActorCombatAttribute:getMaxSp()
	return self:getGroupAttribute(AttributeConst.sp_max_cur)
end

function ActorCombatAttribute:getMaxEp()
	return self:getGroupAttribute(AttributeConst.ep_max_cur) + self:getGroupAttribute(AttributeConst.ep_temp_max)
end

function ActorCombatAttribute:getMaxTempEp()
	return self:getGroupAttribute(AttributeConst.ep_temp_max)
end

function ActorCombatAttribute:getMaxTp()
	return self._baseAttr[AttributeConst.tp_max_cur]
end

function ActorCombatAttribute:getMaxBp()
	return self:getAttribValue(AttributeConst.bp_max_cur)
end

function ActorCombatAttribute:getBPPercent()
	return self:getAttribValue(AttributeConst.bp_cur) / self:getAttribValue(AttributeConst.bp_max_cur)
end

function ActorCombatAttribute:getCrouchSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_crouch_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getWalkSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_walk_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getRunSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_run_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSprintSpeedRatio()
	local ratio = self:getAttribRatioValue(AttributeConst.speed_ratio_sprint_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)

	if self.isPet then
		ratio = ratio * self:getAttribRatioValue(AttributeConst.speed_ratio_dash_v)
	end

	if self.entity:FAST_CARRY_EGG_ST() then
		ratio = ratio * (SysConfigData.FAST_CARRY_EGG_SPEED_RATIO or 1.4)
	end

	return ratio
end

function ActorCombatAttribute:getHoldballSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_standholdball_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSwimSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_swim_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSwimFastSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_swim_fast_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSwimDashSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_swim_dash_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getGlideSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_glide_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getDashSpeedRatio()
	if self.isPet then
		return self:getSprintSpeedRatio()
	end

	return self:getAttribRatioValue(AttributeConst.speed_ratio_dash_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getEggModeSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_egg_mode_v)
end

function ActorCombatAttribute:getDBNOSpeedRatio()
	return self:getAttribRatioValue(AttributeConst.speed_ratio_fallen_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getHpPercent()
	local maxHp = self:getMaxHp()
	local curHp = self:getHp()

	if maxHp <= 0 or maxHp <= curHp then
		return 100
	end

	return math.floor(curHp * 100 / maxHp)
end

function ActorCombatAttribute:getHpRatio()
	local maxHp = self:getMaxHp()
	local curHp = self:getHp()

	if maxHp <= 0 or maxHp <= curHp then
		return 1
	end

	return curHp / maxHp
end

function ActorCombatAttribute:getEpPercent()
	local maxEp = self:getMaxEp()
	local curEp = self:getEp()

	if maxEp <= 0 or maxEp <= curEp then
		return 100
	end

	return math.floor(curEp * 100 / maxEp)
end

function ActorCombatAttribute:getSpPercent()
	local maxSp = self:getMaxSp()
	local curSp = self:getSp()

	if maxSp <= 0 or maxSp <= curSp then
		return 100
	end

	return math.floor(curSp * 100 / maxSp)
end

function ActorCombatAttribute:getBreakPercent()
	local maxBp = self:getMaxBp()
	local curBp = self:getBp()

	if maxBp <= 0 or maxBp <= curBp then
		return 100
	end

	return math.floor(curBp * 100 / maxBp)
end

function ActorCombatAttribute:getLossHp()
	return self:getMaxHp() - self:getHp()
end

function ActorCombatAttribute:getLossHpPercent()
	local maxHp = self:getMaxHp()

	if maxHp > 0 then
		local lossHp = self:getLossHp()

		return math.floor(lossHp * 100 / maxHp)
	end

	return 0
end

function ActorCombatAttribute:getRawSpeed(attributeId)
	local v = self.actorInterface:getConfigData()[AttributeConst.ID2NAME[attributeId]] or 0
	if pg.me and self.entity == pg.me then v = v * 2.0 end --[[SPEEDHACK]]
	return v
end

function ActorCombatAttribute:getRunSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local runSpeed = self:getRawSpeed(AttributeConst.runspeed_v) * curModelScale

	if self.runSpeedRange then
		runSpeed = math.clamp(runSpeed, self.runSpeedRange[1], self.runSpeedRange[2])
	end

	return (runSpeed + self._baseAttr[AttributeConst.runspeed_cur]) * self:getAttribRatioValue(AttributeConst.speed_ratio_run_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getWalkSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local walkSpeed = self:getRawSpeed(AttributeConst.walkspeed_v) * curModelScale

	if self.walkspeedRange then
		walkSpeed = math.clamp(walkSpeed, self.walkspeedRange[1], self.walkspeedRange[2])
	end

	return (walkSpeed + self._baseAttr[AttributeConst.walkspeed_cur]) * self:getAttribRatioValue(AttributeConst.speed_ratio_walk_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSprintSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local sprintSpeed = self:getRawSpeed(AttributeConst.runspeed_v) * curModelScale

	return (sprintSpeed + self._baseAttr[AttributeConst.runspeed_cur]) * self:getSprintSpeedRatio()
end

function ActorCombatAttribute:getWalkStrafeSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local walkStrafeSpeed = self:getRawSpeed(AttributeConst.walk_strafe_speed) * curModelScale

	if self.runSpeedRange then
		walkStrafeSpeed = math.clamp(walkStrafeSpeed, self.runSpeedRange[1], self.runSpeedRange[2])
	end

	return (walkStrafeSpeed + self._baseAttr[AttributeConst.walk_strafe_speed]) * self:getAttribRatioValue(AttributeConst.speed_ratio_walk_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getSideWalkSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local sideWalkSpeed = self:getRawSpeed(AttributeConst.sidewalkspeed_v) * curModelScale

	if self.sidewalkspeedRange then
		sideWalkSpeed = math.clamp(sideWalkSpeed, self.sidewalkspeedRange[1], self.sidewalkspeedRange[2])
	end

	return (sideWalkSpeed + self._baseAttr[AttributeConst.sidewalkspeed_cur]) * self:getAttribRatioValue(AttributeConst.speed_ratio_walk_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getWalkBackSpeed()
	local curModelScale = self.actorInterface:getCurModelScale() or 1
	local walkBackSpeed = self:getRawSpeed(AttributeConst.walkbackspeed_v) * curModelScale

	if self.walkbackspeedRange then
		walkBackSpeed = math.clamp(walkBackSpeed, self.walkbackspeedRange[1], self.walkbackspeedRange[2])
	end

	return (walkBackSpeed + self._baseAttr[AttributeConst.walkbackspeed_cur]) * self:getAttribRatioValue(AttributeConst.speed_ratio_walk_v) * self:getAttribRatioValue(AttributeConst.speed_ratio_load_adjustment_v)
end

function ActorCombatAttribute:getTurnSpeed()
	return self._baseAttr[AttributeConst.turn_speed]
end

function ActorCombatAttribute:getPhyAtk()
	return self._baseAttr[AttributeConst.atk_cur]
end

function ActorCombatAttribute:getPhyDef()
	return self._baseAttr[AttributeConst.def_cur]
end

function ActorCombatAttribute:getAddEpIncRatio()
	local formulaRet = FormulaData[3009].formula(self:getAttribValue(AttributeConst.ep_regen_force_cur), self.entity.level, self.isPlayer)

	return (1 + self:getAttribValue(AttributeConst.ep_inc_rate_v)) * formulaRet
end

function ActorCombatAttribute:getAddSpIncRatio()
	return 1 + self:getAttribValue(AttributeConst.sp_inc_rate_v)
end

function ActorCombatAttribute:changeTp(value)
	if value < 0 and self.actorInterface:hasBuffTag(AbilityConst.BUFF_TAG_SUPER_ARMOR) then
		return
	end

	self.attributeModifier:modifyAttrib(self, AttributeConst.tp_cur, value, nil)
end

function ActorCombatAttribute:changeTpMaxV(value)
	self.attributeModifier:modifyAttrib(self, AttributeConst.tp_max_v, value, nil)
end

function ActorCombatAttribute:changeStamina(value)
	self.attributeModifier:modifyAttrib(self, AttributeConst.stamina_cur, value, nil)
end

function ActorCombatAttribute:getMaxStamina()
	return self:getAttribValue(AttributeConst.stamina_max_cur)
end

function ActorCombatAttribute:getAttribRatioValue(attributeId)
	if attributeId >= AttributeConst.GROUP_BASE_SINGLE_BEGIN and attributeId <= AttributeConst.GROUP_BASE_SINGLE_END then
		return 1 + self:getAttribValue(attributeId)
	end

	return 1
end

function ActorCombatAttribute:getStaminaCostRatio(attributeId)
	if attributeId then
		if attributeId >= AttributeConst.GROUP_BASE_SINGLE_BEGIN and attributeId <= AttributeConst.GROUP_BASE_SINGLE_END then
			return 1 + self:getAttribValue(attributeId) + self:getAttribValue(AttributeConst.stamina_cost_ratio_v)
		end

		return 1
	else
		return 1 + self:getAttribValue(AttributeConst.stamina_cost_ratio_v)
	end
end

function ActorCombatAttribute:getCurWater()
	return self:getAttribValue(AttributeConst.water_cur)
end

function ActorCombatAttribute:getMaxWater()
	return self:getAttribValue(AttributeConst.water_max)
end

function ActorCombatAttribute:changeWater(value)
	self.attributeModifier:modifyAttrib(self, AttributeConst.water_cur, value, nil)
end

function ActorCombatAttribute:setMaxWater(value)
	self:setAttribute(AttributeConst.water_max, value, false)
end

function ActorCombatAttribute:setCurWater(value)
	self:setAttribute(AttributeConst.water_cur, value, false)
end

function ActorCombatAttribute:dump()
	local t = {}

	for idx = 1, #self._baseAttr do
		if self._baseAttr[idx] ~= 0 then
			t[AttributeConst.ID2NAME[idx]] = self._baseAttr[idx]
		end
	end

	return t
end

function ActorCombatAttribute:dumpSingleGroupAttrToTable(t)
	for idx = AttributeConst.GROUP_BASE_SINGLE_BEGIN, AttributeConst.GROUP_BASE_SINGLE_END do
		if self._baseAttr[idx] ~= 0 and self._baseAttr[idx] ~= nil then
			t[AttributeConst.ID2NAME[idx]] = self._baseAttr[idx]
		else
			t[AttributeConst.ID2NAME[idx]] = nil
		end
	end
end

return ActorCombatAttribute
