-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\ActorAttributeModifier.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AttributeConst = require("Common.Const.AttributeConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeCalcUtils = require("Common.Ability.Attribute.AttributeCalcUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local CalcLvModifyData = require("Data.calc_lv_modify_data")
local BodyShapeEffectData = require("Data.body_shape_effect_config_data")
local pg = pg
local ToBool = ToBool
local ActorAttributeModifier = Class.LiteClass("ActorAttributeModifier")

ActorAttributeModifier.OnlyClientModifyAttributes = {
	[AttributeConst.stamina_cur] = true,
	[AttributeConst.add_cur_stamina_v] = true,
	[AttributeConst.add_cur_stamina_max_p] = true
}

function ActorAttributeModifier:ctor()
	self.attrPreProcessFun = {}
	self.attrProcessFun = {}

	self:registerProcessFun()
end

function ActorAttributeModifier:getLvModifyData(lvDiff)
	return CalcLvModifyData[lvDiff] or {}
end

function ActorAttributeModifier:registerProcessFun()
	for attributeId = AttributeConst.GROUP_BASE_XP_BEGIN, AttributeConst.GROUP_BASE_XP_END do
		local offset = AttributeConst.ID_INFO[attributeId].offset

		if offset >= AbilityConst.ATTRIBUTE_ID_OFFSET_V and offset <= AbilityConst.ATTRIBUTE_ID_OFFSET_CONV or offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_FORCE_SET then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeXPMaxVPFix
		elseif offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeXPCur
		elseif offset > AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR and offset < AbilityConst.ATTRIBUTE_ID_OFFSET_XP_INC_RATE_V + 1 or offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_TEMP_CUR then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeBaseAttribValue
		elseif offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_TEMP_MAX then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeXPTempMax
		elseif offset == AbilityConst.ATTRIBUTE_ID_OFFSET_XP_SCALE then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeXPScale
		end
	end

	for attributeId = AttributeConst.GROUP_BASE_PVC_BEGIN, AttributeConst.GROUP_BASE_PVC_END do
		local offset = AttributeConst.ID_INFO[attributeId].offset

		if offset >= AbilityConst.ATTRIBUTE_ID_OFFSET_V and offset <= AbilityConst.ATTRIBUTE_ID_OFFSET_CONV then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changePVCGroupVPFix
		end
	end

	for attributeId = AttributeConst.GROUP_BASE_MAX_PVC_CUR_BEGIN, AttributeConst.GROUP_BASE_MAX_PVC_CUR_END do
		local offset = AttributeConst.ID_INFO[attributeId].offset

		if offset >= AbilityConst.ATTRIBUTE_ID_OFFSET_V and offset <= AbilityConst.ATTRIBUTE_ID_OFFSET_CONV then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeMaxPVCGroupMaxVPFix
		elseif offset == AbilityConst.ATTRIBUTE_ID_OFFSET_MAX_PVC_CUR then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeMaxPVCGroupCur
		end
	end

	for attributeId = AttributeConst.GROUP_BASE_CUR_MAX_BEGIN, AttributeConst.GROUP_BASE_CUR_MAX_END do
		local offset = AttributeConst.ID_INFO[attributeId].offset

		if offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeCurMaxGroupCur
		elseif offset == AbilityConst.ATTRIBUTE_ID_OFFSET_CUR_MAX then
			self.attrProcessFun[attributeId] = ActorAttributeModifier.changeCurMaxGroupMax
		end
	end

	for attributeId = AttributeConst.GROUP_BASE_SINGLE_BEGIN, AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN - 1 do
		self.attrProcessFun[attributeId] = ActorAttributeModifier.changeBaseAttribValue
	end

	for attributeId = AttributeConst.GROUP_BEGIN, AttributeConst.GROUP_END do
		local name = AttributeConst.ID2NAME[attributeId]
		local allNames = string.split(name, "_")

		for index, name in ipairs(allNames) do
			allNames[index] = Utils.firstToUpper(name)
		end

		local allNames = table.concat(allNames)
		local preProcessFunName = string.format("preProcess%s", allNames)

		self.attrPreProcessFun[attributeId] = self[preProcessFunName]

		local processFunName = string.format("process%s", allNames)

		if self[processFunName] then
			self.attrProcessFun[attributeId] = function(actorCombatAttribute, attributeId, value, customData)
				local entity = actorCombatAttribute.actorInterface:getEntity()

				if entity.ignoreProcessAttributeMap and entity.ignoreProcessAttributeMap[attributeId] then
					if LoggerManager.checkLogger(LoggerConst.DEBUG) then
						CombatLogger.debug("actorId %d ignore process attribute %s", actorCombatAttribute.actorInterface:getActorId(), AttributeConst.ID2NAME[attributeId])
					end
				else
					self[processFunName](actorCombatAttribute, attributeId, value, customData)
				end
			end
		end
	end
end

function ActorAttributeModifier:modifyAttrib(actorCombatAttribute, attributeId, value, customData)
	if actorCombatAttribute == nil then
		return false, 0
	end

	if not ToBool(value) then
		return false, 0
	end

	if actorCombatAttribute.isPet and AbilityUtils.isGroupAttribute(attributeId) then
		if not actorCombatAttribute.masterActorCombatAttribute then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				CombatLogger.warn("@jqj masterActorCombatAttribute not found", actorCombatAttribute.entity:repr())
			end

			return false, 0
		else
			return self:modifyAttrib(actorCombatAttribute.masterActorCombatAttribute, attributeId, value, customData)
		end
	end

	local oldVal = actorCombatAttribute._baseAttr[attributeId] or 0
	local attrPreProcessFun = self.attrPreProcessFun[attributeId]

	if attrPreProcessFun then
		value = attrPreProcessFun(actorCombatAttribute, attributeId, value, customData)
	end

	local attrProcessFun = self.attrProcessFun[attributeId]

	if attrProcessFun then
		attrProcessFun(actorCombatAttribute, attributeId, value, customData)
	else
		return false, 0
	end

	return true, (actorCombatAttribute._baseAttr[attributeId] or 0) - oldVal
end

function ActorAttributeModifier.changeXPMaxVPFix(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
	local forceSetValue = actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_FORCE_SET)
	local scaleValue = actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_SCALE)
	local maxCur = AttributeCalcUtils.calcXpMaxCurValue(actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV), scaleValue, forceSetValue)

	actorCombatAttribute:setAttribute(maxCurId, maxCur)

	local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR
	local cur = actorCombatAttribute:getRawAttribValue(curId)

	cur = AttributeCalcUtils.calcLimitCurValue(cur, maxCur)

	actorCombatAttribute:setAttribute(curId, cur)
end

function ActorAttributeModifier.changeXPScale(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_CUR
	local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
	local oldMax = actorCombatAttribute:getRawAttribValue(maxCurId)
	local percent = actorCombatAttribute:getRawAttribValue(curId) / oldMax
	local forceSetValue = actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_FORCE_SET)
	local scaleValue = actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_SCALE)
	local maxCur = AttributeCalcUtils.calcXpScaleMaxCurValue(actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV), scaleValue, forceSetValue)

	actorCombatAttribute:setAttribute(maxCurId, maxCur, false)

	local cur = maxCur * percent

	actorCombatAttribute:setAttribute(curId, cur)
	actorCombatAttribute:onAttributeChange(maxCurId, oldMax, maxCur)
end

function ActorAttributeModifier.changeXPCur(actorCombatAttribute, attributeId, changeValue)
	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local tempCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_TEMP_CUR

	if changeValue > 0 then
		local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue
		local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
		local maxCur = actorCombatAttribute:getRawAttribValue(maxCurId)
		local newValue = math.min(value, maxCur)

		actorCombatAttribute:setAttribute(attributeId, newValue)

		changeValue = value - newValue

		local tempValue = actorCombatAttribute:getRawAttribValue(tempCurId) + changeValue
		local tempCurMaxId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_TEMP_MAX
		local maxTempCur = actorCombatAttribute:getRawAttribValue(tempCurMaxId)

		tempValue = math.min(tempValue, maxTempCur)

		actorCombatAttribute:setAttribute(tempCurId, tempValue)
	else
		local tempValue = actorCombatAttribute:getRawAttribValue(tempCurId) + changeValue
		local newTempValue = math.max(tempValue, 0)

		changeValue = tempValue - newTempValue

		actorCombatAttribute:setAttribute(tempCurId, newTempValue)

		local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

		actorCombatAttribute:setAttribute(attributeId, value)
	end
end

function ActorAttributeModifier.changeXPTempMax(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local tempCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_XP_TEMP_CUR
	local tempCur = actorCombatAttribute:getRawAttribValue(tempCurId)

	tempCur = math.min(tempCur, value)

	actorCombatAttribute:setAttribute(tempCurId, tempCur)
end

function ActorAttributeModifier.changeBaseAttribValue(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)
end

function ActorAttributeModifier.changePVCGroupVPFix(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
	local cur = AttributeCalcUtils.calcPvcCurValue(actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV))

	actorCombatAttribute:setAttribute(curId, cur)
end

function ActorAttributeModifier.changeMaxPVCGroupMaxVPFix(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
	local maxCur = AttributeCalcUtils.calcMaxPvcCurValue(actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_V), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_P), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_FIX), actorCombatAttribute:getRawAttribValue(beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CONV))

	actorCombatAttribute:setAttribute(maxCurId, maxCur)

	local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_MAX_PVC_CUR
	local cur = AttributeCalcUtils.calcLimitCurValue(actorCombatAttribute:getRawAttribValue(curId), maxCur)

	actorCombatAttribute:setAttribute(curId, cur)
end

function ActorAttributeModifier.changeMaxPVCGroupCur(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue
	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local maxCurId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR

	value = math.min(value, actorCombatAttribute:getRawAttribValue(maxCurId))

	actorCombatAttribute:setAttribute(attributeId, value)
end

function ActorAttributeModifier.changeCurMaxGroupCur(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue
	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local maxId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR_MAX

	value = math.min(value, actorCombatAttribute:getRawAttribValue(maxId))

	actorCombatAttribute:setAttribute(attributeId, value)
end

function ActorAttributeModifier.changeCurMaxGroupMax(actorCombatAttribute, attributeId, changeValue)
	local value = actorCombatAttribute:getRawAttribValue(attributeId) + changeValue

	actorCombatAttribute:setAttribute(attributeId, value)

	local beginId = AttributeConst.ID_INFO[attributeId].beginId
	local curId = beginId + AbilityConst.ATTRIBUTE_ID_OFFSET_CUR
	local cur = actorCombatAttribute:getRawAttribValue(curId)

	cur = math.min(cur, value)

	actorCombatAttribute:setAttribute(curId, cur)
end

function ActorAttributeModifier.processReduceCurTpRate(actorCombatAttribute, attributeId, value, customData)
	if value <= 0 then
		return
	end

	local owner = actorCombatAttribute.actorInterface:getEntity()

	if owner.isFakeActor then
		return
	end

	if owner:inBreak() or owner:inBreakRecover() then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("inBreakStatus, can't process reduce_tp_v")
		end

		return
	end

	if owner.actorBuff:hasTag(AbilityConst.BUFF_TAG_SUPER_ARMOR) then
		return
	end

	local old = actorCombatAttribute:getTp() + actorCombatAttribute:getTempTp()
	local tpPower = 1
	local combatContext = customData and customData.combatContext
	local abilityId = combatContext and combatContext.abilityId
	local casterEntity = CombatActionTool.getCasterEnt(combatContext)

	if not casterEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("processReduceCurTpRate casterEntity not found", combatContext and combatContext.BPName, combatContext and combatContext.calcResultNodeId, abilityId)
		end

		return
	end

	local elementType = combatContext and combatContext.damageData and combatContext.damageData.elementType

	if ToBool(abilityId) then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId, combatContext.buffTemplateId)

		tpPower = AbilityUtils.getAbilityParamTpPower(abilityParamData, casterEntity)
		elementType = abilityParamData.elementType
	end

	local casterData = casterEntity and Utils.getEntityConfigData(casterEntity) or {}
	local targetData = Utils.getEntityConfigData(owner)
	local casterBodyShapeEffectData = casterData and BodyShapeEffectData[casterData.sizeLevel]
	local targetBodyShapeEffectData = targetData and BodyShapeEffectData[targetData.sizeLevel]
	local tpPowerRate = casterBodyShapeEffectData and casterBodyShapeEffectData.TpPowerRate or 1
	local tpResistRate = targetBodyShapeEffectData and targetBodyShapeEffectData.TpResistRate or 1
	local tpDamFixRate = combatContext and combatContext.lvModifyData.tpDamFixRate or 1
	local elementTpReduceRate = CombatActionTool.getElementTpReduceAddRatio(owner, elementType)
	local rawValue = value

	value = value * tpPower * tpDamFixRate * elementTpReduceRate * tpPowerRate / tpResistRate

	CombatLogger.debug("changeTp actorId %d changeTp %f, reduce_cur_tp_rate %f tpPower %f tpDamFixRate %f elementTpReduceRate %f tpPowerRate %f tpResistRate", actorCombatAttribute.actorInterface:getActorId(), value, rawValue, tpPower, tpDamFixRate, elementTpReduceRate, tpPowerRate, tpResistRate)
	actorCombatAttribute:changeTp(-value)

	if actorCombatAttribute.clearTpBreakTimer and old - value <= 0 and actorCombatAttribute.tpBreakRecoverTimer == nil then
		actorCombatAttribute.tpBreakRecoverTimer = actorCombatAttribute.entity:addTimer(actorCombatAttribute:getRawAttribValue(AttributeConst.tp_break_recover_cd), function()
			actorCombatAttribute:clearTpBreakTimer()
		end)
	end
end

return ActorAttributeModifier
