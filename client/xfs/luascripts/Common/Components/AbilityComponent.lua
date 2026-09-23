-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AbilityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ABILITY_TICK_REASONS = AbilityConst.ABILITY_TICK_REASONS
local TICK_REASON_TIMELINE = ABILITY_TICK_REASONS.TIMELINE
local TICK_REASON_BUFF = ABILITY_TICK_REASONS.BUFF_THINK
local TICK_REASON_FORCE_DISPLACEMENT = ABILITY_TICK_REASONS.FORCE_DISPLACEMENT
local EnumAbilityType = AbilityConst.EnumAbilityType
local ActorTimeline = require("Common.Ability.Timeline.ActorTimeline")
local SkillStateManager = require("Common.Ability.SkillState.SkillStateManager")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ImpulseData = require("Data.impulse_data")
local EventBus = require("Common.Ability.Buff.EventBus")
local AttributeConst = require("Common.Const.AttributeConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityDebugTool = require("Common.Ability.AbilityDebugTool")
local Utils = require("Common.Utils.Utils")
local SpreadAnnularSectorData = require("Common.Ability.SpreadAnnularSectorData")
local BodyShapeEffectData = require("Data.body_shape_effect_config_data")
local ServerEventConst = require("Const.ServerEventConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local EntityTimer = require("Common.Ability.EntityTimer")
local WeakRefCallbackHandle = require("Core.Common.WeakRefCallbackHandle")
local ConflictTypes = require("Common.ConflictTypes")
local lume = require("Core.Common.lume")
local ToBool = ToBool
local pg = pg
local Quaternion = Quaternion
local Vector3 = Vector3
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local AbilityComponent = Class.Component("AbilityComponent")

function AbilityComponent:ctor()
	self.actionMask = {}

	for i = 1, AbilityConst.ACTION_MASK_COUNT do
		self.actionMask[i] = false
	end

	self.castingMap = {}
	self.abilityObjectMap = {}
	self.stolenAbilityObjectMap = {}
	self.chargeMap = {}
	self.switchMap = {}
	self.switchSkillData = {}
	self.switchSkillTimerMap = {}
	self.switchSkillRecoverEndTimeMap = {}
	self.entityCacheVal = {}
	self.spreadAnnularSectors = {}
	self.rangeLevelCache = {}
	self.frameFreezeMap = {}
	self.combatTimelineRef = {
		isNormalAttack = false,
		cnt = 0,
		abilityId = 0
	}
	self.jumpingTimelineRefCnt = 0
	self.abilityTimerMap = {}
	self.lastStartDashTime = nil
	self.specialAttackModeData = nil
	self.isInSpecialDefense = nil
	self.isPositionMoved = false
	self.combatContextMap = {}
	self.dyingCombatContextMapA = {}
	self.dyingCombatContextMapB = {}
	self.curDyingCombatContext = self.dyingCombatContextMapA
	self.followingPhantomList = {}
	self.createdProjectileList = {}
	self.tempTbl = {}
	self.abilityTickRefMap = {}
	self.baseAttr = {
		__index = function()
			return 0
		end
	}

	setmetatable(self.baseAttr, self.baseAttr)

	self.rePressSkillSlotInfo = {}
	self.abilityCollisionTestInfo = {}
	self.castingCombatContextId = 0
	self.castingAbilityActOnTargetHit = nil
	self.cancelAbilityByAbilityIdList = {}
	self.skillStateMgr = SkillStateManager(self)
end

function AbilityComponent:getCombatContext(id)
	return self.combatContextMap[id] or self.dyingCombatContextMapA[id] or self.dyingCombatContextMapB[id]
end

function AbilityComponent:genProjectileInstanceId()
	return self:genCombatContextId()
end

function AbilityComponent:genCombatContextId()
	return
end

function AbilityComponent:getCombatContextFromCache(ctxType, id)
	id = id or self:genCombatContextId()

	if self.combatContextMap[id] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("getCombatContext genId already exists", self.actorId, ctxType, id)
		end

		self.combatContextMap[id].refCnt = self.combatContextMap[id].refCnt + 1

		return self.combatContextMap[id]
	end

	local combatContext = pg.global.abilityMgr.combatContextPool:get(true)

	combatContext:init(self.actorId)

	combatContext.id = id
	combatContext.ctxType = ctxType
	self.combatContextMap[combatContext.id] = combatContext
	combatContext.refCnt = combatContext.refCnt + 1

	return combatContext
end

function AbilityComponent:returnCombatContext(combatContext, isDying)
	combatContext = CombatActionTool.getRealCombatContext(self, combatContext)

	if not combatContext then
		return
	end

	if combatContext.refCnt <= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("combatContext.refCnt <= 0", self.actorId, combatContext.id, combatContext.BPName)
		end

		return
	end

	combatContext.refCnt = combatContext.refCnt - 1

	if isDying == true then
		combatContext.isDying = true
	end

	if combatContext.refCnt == 0 then
		self.combatContextMap[combatContext.id] = nil

		if self.voxelSyncMap and self.voxelSyncMap[combatContext.id] then
			self.voxelSyncMap[combatContext.id] = nil
		end

		self:addDyingCombatContext(combatContext)
	end
end

function AbilityComponent:checkAbilityTimer()
	return
end

function AbilityComponent:addCombatContextRefCnt(combatContext)
	if not combatContext or not combatContext.id then
		return
	end

	combatContext = CombatActionTool.getRealCombatContext(self, combatContext)

	if not combatContext then
		return
	end

	combatContext.refCnt = combatContext.refCnt + 1
	self.dyingCombatContextMapA[combatContext.id] = nil
	self.dyingCombatContextMapB[combatContext.id] = nil
	self.combatContextMap[combatContext.id] = combatContext
end

function AbilityComponent:setEntityCacheVal(key, value)
	local rawValue = self.entityCacheVal[key]

	self.entityCacheVal[key] = value

	if rawValue ~= value then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_CACHE_VAL_CHANGE, key)
	end
end

function AbilityComponent:getEntityCacheVal(key)
	return self.entityCacheVal[key]
end

function AbilityComponent:addEntityTimer(duration, fun)
	return self.entityTimer:add(duration, fun)
end

function AbilityComponent:removeEntityTimer(id)
	if self.entityTimer then
		self.entityTimer:remove(id)
	end
end

function AbilityComponent:getEnableAbilityCheck()
	local authEntity = pg.getEntity(self.authorityId)

	if authEntity then
		return authEntity and authEntity.enableAbilityCheck
	end

	return true
end

function AbilityComponent:addAbilityTickReason(reason)
	self.abilityTickRefMap[reason] = (self.abilityTickRefMap[reason] or 0) + 1

	self:checkAbilityTimer()
end

function AbilityComponent:removeAbilityTickReason(reason)
	if self.abilityTickRefMap[reason] then
		if self.abilityTickRefMap[reason] == 1 then
			self.abilityTickRefMap[reason] = nil
		else
			self.abilityTickRefMap[reason] = self.abilityTickRefMap[reason] - 1
		end
	end

	self:checkAbilityTimer()

	if not next(self.abilityTickRefMap) then
		self:updateAbilityTimeScale()
	end
end

function AbilityComponent:init()
	local abilityManager = pg.global.abilityMgr

	self.combatAction = abilityManager.combatAction
	self.actorTimeline = ActorTimeline(self)
	self.subject = EventBus.EventSubject(self.actorId)
	self.hitTargetSetMap = {}
	self.hitTargetCdMap = {}
	self.normalAtkAbilityList = {}
	self.nextComboAbilityId = 0

	self.actorTimeline:init()

	self.ignoreProcessAttributeMap = {}

	local entityConfigData = Utils.getEntityConfigData(self)

	self.weightLevel = BodyShapeEffectData[entityConfigData.sizeLevel] and BodyShapeEffectData[entityConfigData.sizeLevel].weightLevel or 0

	if Utils.isPet(self) or Utils.isPuppet(self) or Utils.isCreation(self) then
		local masterEntity = self.getMasterEntity and self:getMasterEntity()

		if masterEntity then
			self.subject.additionalReceiver = masterEntity.subject
		end
	end

	self.attachMap = {}
	self.attachInfo = nil
	self.mainElementType = self:getConfigData().mainElementType
	self.entityTimer = EntityTimer(self)

	return true
end

function AbilityComponent:start()
	self:refreshAllAbilityInvalidReasons()
	self:refreshAllAbilityInvalidLockReasons()
end

function AbilityComponent:onEnterSpace()
	if self.clearDyingCombatContextTimer == nil then
		self.clearDyingCombatContextTimer = self:addRepeatTimer(1, WeakRefCallbackHandle.new(function(self)
			self:clearDyingCombatContext()
		end, self))
	end

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.NO_SPACE, false)
end

function AbilityComponent:onLeaveSpace()
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.NO_SPACE, true)
end

function AbilityComponent:updateHitBoxParam()
	if Utils.isCreation(self) then
		local scale = self.curModelScale

		if self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_SPHERE then
			self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
				self.shapeArgs[1] * scale,
				self.shapeArgs[1] * scale,
				0
			})

			self.bodySize = self.shapeArgs[1] * 0.5 * scale
			self.bodyHeight = self.shapeArgs[1] * scale
		elseif self.shapeType == AbilityConst.LX_GEOMETRY_TYPE_BOX then
			self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_BOX, 3, {
				self.shapeArgs[1] / 2 * scale,
				self.shapeArgs[2] / 2 * scale,
				self.shapeArgs[3] / 2 * scale
			})

			self.bodySize = math.max(self.shapeArgs[1], self.shapeArgs[3])
			self.bodyHeight = self.shapeArgs[2]
		else
			self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
				1,
				1,
				0
			})

			self.bodySize = 0.5
			self.bodyHeight = 1
			self.canBeHit = false
		end
	else
		self.aoi:setHitBoxParam(AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D, 3, {
			self.bodySize,
			self.bodyHeight,
			0
		})
	end
end

function AbilityComponent:clearDyingCombatContext()
	for id, combatContext in pairs(self.curDyingCombatContext) do
		combatContext.isDead = true

		pg.global.abilityMgr:returnCombatContextToPool(combatContext)

		self.curDyingCombatContext[id] = nil
	end

	self.curDyingCombatContext = self.curDyingCombatContext == self.dyingCombatContextMapA and self.dyingCombatContextMapB or self.dyingCombatContextMapA
end

function AbilityComponent:refreshAllAbilityInvalidReasons()
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.NO_SPACE, not self.space)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.SKILL_CAMERA_ANIM_INVINCIBLE, self.isSkillCameraAnimInvincible == true)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IN_INVINCIBLE, self.inInvincible and self:inInvincible())
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRANSPARENT, self.isTransparent == true)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_IN_CAPTURE, self.isInCapture == true)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, self.isTrapped == true)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.GROUP_DROP_END, self.groupDropEndTsMap and #self.groupDropEndTsMap > 0)
	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.LIFE_NEAR_DEAD, self.life == Const.LIFE_NEAR_DEAD)

	local cylinderTrapEmpty = false

	if self.cylinderTrapItem then
		cylinderTrapEmpty = not next(self.cylinderTrapItem.inRangeActorIdMap)
	end

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.CYLINDER_TRAP_EMPTY, cylinderTrapEmpty)
end

function AbilityComponent:refreshAllAbilityInvalidLockReasons()
	AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.IS_TRANSPARENT, self.isTransparent == true)
	AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.IS_IN_CAPTURE, self.isInCapture == true)

	local disableLocked = self.actorBuff and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_DISABLE_LOCKED)

	AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.BUFF_TAG_DISABLE_LOCKED, disableLocked == true)
end

function AbilityComponent:addDyingCombatContext(combatContext)
	if not combatContext or combatContext.isClone then
		return
	end

	if self.curDyingCombatContext == self.dyingCombatContextMapA then
		self.dyingCombatContextMapB[combatContext.id] = combatContext
	else
		self.dyingCombatContextMapA[combatContext.id] = combatContext
	end
end

function AbilityComponent:addSkillCombatTimelineRef(abilityId)
	if self.combatTimelineRef.cnt > 0 and abilityId ~= self.combatTimelineRef.abilityId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("addSkillTimelineRef error cur abilityId not equal abilityId", self.combatTimelineRef.abilityId, abilityId)
		end

		return
	end

	self.combatTimelineRef.abilityId = abilityId
	self.combatTimelineRef.cnt = self.combatTimelineRef.cnt + 1
	self.combatTimelineRef.isNormalAttack = false
end

function AbilityComponent:removeSkillCombatTimelineRef(abilityId)
	if self.combatTimelineRef.cnt > 0 and abilityId ~= self.combatTimelineRef.abilityId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("addSkillTimelineRef error cur abilityId not equal abilityId", self.combatTimelineRef.abilityId, abilityId)
		end

		return
	end

	self.combatTimelineRef.abilityId = abilityId
	self.combatTimelineRef.cnt = self.combatTimelineRef.cnt - 1
end

function AbilityComponent:addAttackCombatTimelineRef(abilityId)
	if self.combatTimelineRef.cnt > 0 and abilityId ~= self.combatTimelineRef.abilityId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("addAttackCombatTimelineRef error cur abilityId not equal abilityId", self.combatTimelineRef.abilityId, abilityId)
		end

		return
	end

	self.combatTimelineRef.abilityId = abilityId
	self.combatTimelineRef.cnt = self.combatTimelineRef.cnt + 1
	self.combatTimelineRef.isNormalAttack = true
end

function AbilityComponent:removeAttackCombatTimelineRef(abilityId)
	if self.combatTimelineRef.cnt > 0 and abilityId ~= self.combatTimelineRef.abilityId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("removeAttackCombatTimelineRef error cur abilityId not equal abilityId", self.combatTimelineRef.abilityId, abilityId)
		end

		return
	end

	self.combatTimelineRef.abilityId = abilityId
	self.combatTimelineRef.cnt = self.combatTimelineRef.cnt - 1
end

function AbilityComponent:checkCastAbilityByFlyST(inFly, abilityParamData)
	if inFly then
		return abilityParamData.specialStateCanCast and abilityParamData.specialStateCanCast.FLY_ST
	else
		return not abilityParamData.specialStateCanCast or not abilityParamData.specialStateCanCast.FLY_ST or abilityParamData.blockCastInNormalState ~= 1
	end
end

function AbilityComponent:canCastUltimate()
	local ultimateAbilityId = self:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)

	if not self:checkSkillState(ultimateAbilityId) then
		return false
	end

	return true
end

function AbilityComponent:initNorAtkAbilityList(inFly)
	inFly = ToBool(inFly)

	local normalAtkAbilityList = {}
	local abilityMgr = pg.global.abilityMgr

	for abilityId, ability in pairs(self.abilityMap or EMPTY_TABLE) do
		local abilityData = abilityMgr:getAbilityTemplate(abilityId, 1)

		if not ability.isSubAbility and abilityData.abilityType == EnumAbilityType.Attack then
			local abilityParamData = abilityMgr:getAbilityParamData(abilityId)

			if self:checkCastAbilityByFlyST(inFly, abilityParamData) then
				table.insert(normalAtkAbilityList, abilityId)
			end

			for _, subAbilityId in ipairs(abilityData.subAbilityIds or EMPTY_TABLE) do
				local subAbilityParamData = abilityMgr:getAbilityParamData(abilityId)

				if self:checkCastAbilityByFlyST(inFly, subAbilityParamData) then
					normalAtkAbilityList[#normalAtkAbilityList + 1] = subAbilityId
				end
			end
		end
	end

	table.sort(normalAtkAbilityList)

	self.normalAtkAbilityList = normalAtkAbilityList
	self.rawMaxAttackDist = 0

	for _, abilityId in ipairs(self.normalAtkAbilityList) do
		local attackDist = abilityMgr:getAbilityParamData(abilityId).searchTargetRangeRadius or 0

		self.rawMaxAttackDist = math.max(attackDist, self.rawMaxAttackDist)
	end

	if self.bodySize then
		self.maxAttackDist = self.bodySize + (self.rawMaxAttackDist - self.bodySize) * 0.8
	end
end

function AbilityComponent:getActionMask(mask)
	return self.actionMask[mask]
end

function AbilityComponent:setActionMask(mask, value, abilityId)
	value = ToBool(value)

	if self.actionMask[mask] == value then
		return
	end

	self.actionMask[mask] = value

	self:postComponentMethod("onActionMaskChange", mask, value, abilityId)

	if mask == AbilityConst.ACTION_MASK_IN_CAST and value == true then
		self:setActionMask(AbilityConst.ACTION_MASK_IN_COMBO, false, abilityId)
		self:setActionMask(AbilityConst.ACTION_MASK_IN_BACKSWING, false, abilityId)
	elseif mask == AbilityConst.ACTION_MASK_IN_COMBO and value == true then
		self:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, false, abilityId)
		self:setActionMask(AbilityConst.ACTION_MASK_IN_BACKSWING, false, abilityId)
	elseif mask == AbilityConst.ACTION_MASK_IN_BACKSWING and value == true then
		self:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, false, abilityId)
		self:setActionMask(AbilityConst.ACTION_MASK_IN_COMBO, false, abilityId)
		self:setActionMask(AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING, false, abilityId)
	elseif mask == AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING and value == true then
		self:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, false, abilityId)
	end

	self:checkExitSpecialAttackMode(mask, value)

	if mask == AbilityConst.ACTION_MASK_IN_SKILL or mask == AbilityConst.ACTION_MASK_IN_ATTACK then
		self:postComponentMethod("EVENT_AbilityStateChange", value, abilityId or 0)
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ABILITY_STATE_CHANGE, abilityId, self.actorId)
	end

	self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ACTION_MASK_CHANGE, mask, value)

	if mask == AbilityConst.ACTION_MASK_IN_BACKSWING and value then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_ABILITY_BACK_SWING, abilityId, self.actorId)
	end
end

function AbilityComponent:onAbilityStart(abilityId, combatCasterInfo, castSource, extraInfo)
	local ability = self:getAbility(abilityId)

	self:handleSwitchAbility(ability, true)
	self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ABILITY_ST)
end

function AbilityComponent:onAbilityEnd(ability)
	ability:onAbilityEnd()
	self:checkExitSpecialAttackMode()
	self:handleSwitchAbility(ability, false)
	self:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_IN_COMBO, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_IN_BACKSWING, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_CANCELLABLE, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_CAN_MOVE, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_CAN_ROTATE, false, ability.abilityId)
	self:setActionMask(AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING, false, ability.abilityId)
	self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ABILITY_ST)

	self.castingCombatContextId = 0
end

function AbilityComponent:inAbility()
	return self:inSkill() or self:inAttack()
end

function AbilityComponent:inSkill()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_IN_SKILL))
end

function AbilityComponent:inAttack()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_IN_ATTACK))
end

function AbilityComponent:inCombo()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_IN_COMBO))
end

function AbilityComponent:canRotate()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_CAN_ROTATE))
end

function AbilityComponent:canMove()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_CAN_MOVE))
end

function AbilityComponent:isAbilityCancellable()
	return ToBool(self:getActionMask(AbilityConst.ACTION_MASK_CANCELLABLE))
end

function AbilityComponent:inKnockUp()
	return self.knockState > AbilityConst.KNOCK_STATE_BACK
end

function AbilityComponent:inKnockUpStartLoop()
	return self.knockState == AbilityConst.KNOCK_STATE_UP_START or self.knockState == AbilityConst.KNOCK_STATE_UP_LOOP
end

function AbilityComponent:inKnockUpEnd()
	return self.knockState == AbilityConst.KNOCK_STATE_UP_END
end

function AbilityComponent:inKnockBack()
	return self.knockState == AbilityConst.KNOCK_STATE_BACK
end

function AbilityComponent:checkItemSkillCanCastCount(abilityId)
	local ability = self:getAbility(abilityId)

	return ability and ability.itemSkillCanCastCount >= 1
end

function AbilityComponent:modifyItemSkillCanCastCount(abilityId, offset)
	local ability = self:getAbility(abilityId)

	if ability == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@lgz modify itemskill invalid", abilityId, offset)
		end

		return
	end

	ability.itemSkillCanCastCount = ability.itemSkillCanCastCount + offset
end

function AbilityComponent:getAbility(abilityId, storeType)
	abilityId = self:getSwitchSkill(abilityId)

	return self:getRawAbility(abilityId, storeType)
end

function AbilityComponent:getRawAbility(abilityId, storeType)
	if storeType == nil then
		return self.abilityMap[abilityId] or self.stolenAbilityMap[abilityId] or self.callFriendsAbilityMap and self.callFriendsAbilityMap[abilityId]
	elseif storeType == AbilityConst.ABILITY_STORE_TYPE.NORMAL then
		return self.abilityMap[abilityId]
	elseif storeType == AbilityConst.ABILITY_STORE_TYPE.STOLEN then
		return self.stolenAbilityMap[abilityId]
	elseif storeType == AbilityConst.ABILITY_STORE_TYPE.CALL_FRIENDS then
		return self.callFriendsAbilityMap[abilityId]
	end
end

function AbilityComponent:onAbilityDestroy(ability)
	if not ability:isStolenAbility() then
		self.abilityMap[ability.abilityId] = nil
	else
		self.stolenAbilityMap[ability.abilityId] = nil
	end
end

function AbilityComponent:setNextComboAbility(abilityId)
	self.nextComboAbilityId = abilityId
end

function AbilityComponent:setNextComboTimeline(timeline, timelineId, combatContext)
	if ToBool(timelineId) then
		self.nextComboTimeline = {
			timeline,
			timelineId,
			combatContext
		}
	else
		self.nextComboTimeline = nil
	end
end

function AbilityComponent:getNextComboAbility()
	return self.nextComboAbilityId
end

function AbilityComponent:checkCanCastAbilityNoTarget(abilityId, castSource, cancelStates)
	return self:checkCanCastAbility(abilityId, nil, castSource, nil, cancelStates)
end

function AbilityComponent:checkCanCastAbilityOnTarget(abilityId, targetId, castSource, cancelStates)
	return self:checkCanCastAbility(abilityId, targetId, castSource, nil, cancelStates)
end

function AbilityComponent:checkCanCastAbility(abilityId, targetActorId, castSource, context, cancelStates, extraInfo)
	if abilityId == AbilityConst.BACK_SKILL_ID and not self:isInCombat() then
		return false, AbilityConst.ABILITY_CAST_FAILED_BACK_NOT_IN_COMBAT
	end

	if not self.space then
		return false, AbilityConst.ABILITY_CAST_FAILED_FAULT
	end

	if extraInfo and extraInfo.isFromServer then
		return true, AbilityConst.ABILITY_CAST_FAILED_NONE
	end

	local deadAbilityId = self.getDeadAbilityId and self:getDeadAbilityId() or 0
	local isDeadAbility = false

	if self.isDyingExtraTempPet or self:isDead() then
		if ToBool(deadAbilityId) then
			if deadAbilityId ~= abilityId then
				return false, AbilityConst.ABILITY_CAST_FAILED_IN_DEAD
			end

			isDeadAbility = true
		else
			return false, AbilityConst.ABILITY_CAST_FAILED_IN_DEAD
		end
	end

	abilityId = self:getSwitchSkill(abilityId)

	local ability = self:getAbility(abilityId)

	if ability == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@jqj AbilityComponent:checkCanCastAbility failed, ability not exist", self.actorId, abilityId)
		end

		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST
	end

	if Utils.isSpaceRogueDungeon(self.space.spaceType) and not Utils.isPuppet(self) and not self:isInCombat() and not AbilityUtils.isNormalAttack(abilityId) then
		return false, AbilityConst.ABILITY_CAST_FAILED_ROUGE_DUNGEON_NOT_IN_COMBAT
	end

	local entity = pg.getEntityByActorId(self.actorId)
	local abilityData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not entity or not abilityData then
		return false, AbilityConst.ABILITY_CAST_FAILED_FAULT
	end

	if abilityData.petUseAbilityType ~= nil then
		local result, reason = self:checkCanUsePetAbility(abilityId)

		if not result then
			return result, reason
		end
	end

	if castSource == AbilityConst.CAST_SOURCE.CALL_FRIENDS and abilityData.canCastByCallFriends == false then
		return false, AbilityConst.ABILITY_CAST_FAILED_CALL_FRIENDS
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local isFromDialogueGraph = castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH
	local checkStamina = abilityParamData.checkStamina

	if Utils.isAIEntity(self) or isFromDialogueGraph or pg.component == "game" then
		checkStamina = false
	end

	if checkStamina and entity.actorCombatAttribute:getAttribValue(AttributeConst.stamina_cur) < abilityParamData.checkStamina then
		return false, AbilityConst.ABILITY_CAST_FAILED_NOT_ENOUGH_STAMINA
	end

	if not entity or not abilityData then
		return false, AbilityConst.ABILITY_CAST_FAILED_FAULT
	end

	local useSkillItemCheck = context and context.useSkillItemCheck

	if not useSkillItemCheck and abilityData.abilityType == EnumAbilityType.Item and not self:checkItemSkillCanCastCount(abilityId) then
		return false, AbilityConst.ABILITY_CAST_ERR_ITEM_SKILL_COUNT
	end

	if targetActorId then
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if targetEntity == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("AbilityComponent:checkCanCastAbility failed", targetActorId)
			end

			return false, AbilityConst.ABILITY_CAST_TARGET_NOT_EXIST
		end

		if targetEntity.isFakeDead and targetEntity:isFakeDead() then
			return false, AbilityConst.ABILITY_CAST_TARGET_NOT_EXIST
		end

		if targetEntity.FALLEN_ST and targetEntity:FALLEN_ST() and Utils.isWildPuppet(self) then
			return false
		end
	end

	if not isFromDialogueGraph then
		if abilityData.checkExistBurrow and self.isMainPet and pg.component == "client" and self:BURROW_ST() and not self:canStopBurrow(abilityId) then
			return false
		end

		local stateValid, reason = self:checkCharacterStateCastAbilityValid(abilityId)

		if not stateValid then
			return false, reason
		end
	end

	if Utils.isPlayer(self) and self:getCurPetEntity() == nil and ability:getAbilityTemplate().onlyCastWithPet == true then
		return false, AbilityConst.ABILITY_CAST_FAILED_PET_NOT_FOUND
	end

	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL

	local checkCost = true
	local checkCd = true

	if castSource == AbilityConst.CAST_SOURCE.APPEAR then
		checkCd = false
	elseif castSource == AbilityConst.CAST_SOURCE.SKILL then
		checkCost = true
		checkCd = true
	elseif castSource == AbilityConst.CAST_SOURCE.CALL_FRIENDS then
		checkCost = false
		checkCd = false
	elseif entity.gmMode == Const.NO_COST_MODE then
		checkCost = false
		checkCd = false
	elseif extraInfo and extraInfo.isFromServer then
		checkCost = false
		checkCd = false
	elseif isFromDialogueGraph then
		checkCost = false
		checkCd = false
	end

	if checkCd and not ToBool(self:checkAbilityCd(abilityId)) then
		return false, AbilityConst.ABILITY_CAST_FAILED_IN_CD
	end

	if checkCost then
		local checkCostResult, reason = self:checkAbilityCost(abilityId)

		if not checkCostResult then
			return false, reason
		end
	end

	if not isFromDialogueGraph and self.checkSkillState and not isDeadAbility and not self:checkSkillState(abilityId, false, not cancelStates) then
		return false, AbilityConst.ABILITY_CAST_FAILED_STATE_CHECK_FAILED
	end

	return true, AbilityConst.ABILITY_CAST_FAILED_NONE
end

function AbilityComponent:checkAbilityCd(abilityId)
	local ability = self:getAbility(abilityId)

	if ability == nil then
		return false
	end

	return not ability:isInCd()
end

function AbilityComponent:checkAbilityCost(abilityId)
	local ability = self:getAbility(abilityId)

	if ability == nil then
		return false, nil
	end

	local masterEntity = Utils.isPlayer(self) and self or Utils.isPet(self) and self:getMasterEntity()
	local castSkillFreeEpCnt = masterEntity and masterEntity.castSkillFreeEpCnt or 0
	local castSkillFreeSpCnt = masterEntity and masterEntity.castSkillFreeSpCnt or 0

	if castSkillFreeEpCnt <= 0 and self.actorCombatAttribute:getEp() < ability:getCurEpCost(self) then
		return false, AbilityConst.ABILITY_CAST_NOT_ENOUGH_EP
	end

	if castSkillFreeSpCnt <= 0 and self.actorCombatAttribute:getSp() < ability.spCost then
		return false, AbilityConst.ABILITY_CAST_NOT_ENOUGH_SP
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

	if abilityParamData.costItemId then
		local cnt = ItemUtils.getItemCountById(self, abilityParamData.costItemId, true)

		if cnt < abilityParamData.costItemCnt then
			return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_ITEM
		end
	end

	if abilityParamData.isSetRogueExtraTempPet then
		if masterEntity:EXTRA_TEMP_PET_ST() then
			return false, AbilityConst.ABILITY_CAST_FAILED_STATE_CHECK_FAILED
		end

		local epCnt = masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] or 0
		local epMax = masterEntity.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX] or 100

		if epCnt < epMax then
			return false, AbilityConst.ABILITY_CAST_FAILED_ROGUE_EP_NOT_ENOUGH
		end
	end

	local rogueEpCost = AbilityUtils.getRogueEpCost(abilityParamData, masterEntity)

	if rogueEpCost then
		local rogueEp = AbilityUtils.getRogueEp(masterEntity)

		if rogueEp < rogueEpCost then
			return false, AbilityConst.ABILITY_CAST_FAILED_ROGUE_EP_NOT_ENOUGH
		end
	end

	local abilityTemplateData = ability:getAbilityTemplate()

	if abilityTemplateData.loadingCd and self.abilityLoadingMap[abilityId].cnt <= 0 then
		return false, AbilityConst.ABILITY_CAST_FAILED_LOADED_CNT
	end

	if AbilityUtils.isUseWaterExploreAbility(masterEntity, abilityId) and self.actorCombatAttribute:getCurWater() < AbilityUtils.getAbilityParamWaterCost(masterEntity, abilityId) then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_ENOUGH_WATER
	end

	return true, nil
end

function AbilityComponent:checkComboAbilityId(abilityId)
	return self.nextComboAbilityId == 0 or self.nextComboAbilityId == abilityId
end

function AbilityComponent:checkCharacterStateCastAbilityValid(abilityId)
	if not abilityId then
		return false
	end

	local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if abilityTemplateData.notCastInState then
		for _, state in ipairs(abilityTemplateData.notCastInState) do
			local func = self[state]

			if func and func(self) then
				return false, AbilityConst.ABILITY_CAST_FAILED_BY_IN_STATE[state] or AbilityConst.ABILITY_CAST_FAILED_CUR_STATE_FORBIDDEN
			end
		end
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local onlyCastInState = abilityParamData.onlyCastInState

	if ToBool(onlyCastInState) then
		for _, state in ipairs(onlyCastInState) do
			local func = self[state]

			if func and func(self) then
				return true
			end
		end

		return false, AbilityConst.ABILITY_CAST_FAILED_BY_NOT_IN_STATE[onlyCastInState[1]] or AbilityConst.ABILITY_CAST_FAILED_CUR_STATE_FORBIDDEN
	end

	local specialState = AbilitySettingGlobalConstData.specialStateToCastSkill or {}
	local blockCastInNormalState = ToBool(abilityParamData.blockCastInNormalState)

	for _, state in ipairs(specialState) do
		local specialStateCanCast = abilityParamData.specialStateCanCast

		specialStateCanCast = ToBool(specialStateCanCast) and specialStateCanCast[state]

		if not specialStateCanCast then
			local func = self[state]

			if func and func(self) then
				return false, AbilityConst.ABILITY_CAST_FAILED_BY_IN_STATE[state] or AbilityConst.ABILITY_CAST_FAILED_CUR_STATE_FORBIDDEN
			end
		elseif blockCastInNormalState then
			local func = self[state]

			if not func or not func(self) then
				return false, AbilityConst.ABILITY_CAST_FAILED_BY_NOT_IN_STATE[state] or AbilityConst.ABILITY_CAST_FAILED_CUR_STATE_FORBIDDEN
			else
				blockCastInNormalState = false

				break
			end
		end
	end

	if blockCastInNormalState then
		return false, AbilityConst.ABILITY_CAST_FAILED_NOT_IN_SPECIAL_STATE
	end

	return true
end

function AbilityComponent:castAbilityNoTarget(abilityId, castSource, extraInfo)
	local combatCasterInfo = self.castingMap[abilityId]

	if not combatCasterInfo then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST
	end

	combatCasterInfo:ctor(self.actorId)

	if extraInfo then
		combatCasterInfo.aimPos = Vector3.CloneFromPool(extraInfo.aimPos)
		combatCasterInfo.chaseActorId = extraInfo.chaseActorId
	end

	local result, reason = self:castAbilityInternal(abilityId, combatCasterInfo, castSource, extraInfo)

	return result, reason
end

function AbilityComponent:castAbilityOnTarget(abilityId, targetActorId, castSource, extraInfo)
	local combatCasterInfo = self.castingMap[abilityId]

	if not combatCasterInfo then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST
	end

	combatCasterInfo:ctor(self.actorId)

	combatCasterInfo.partId = extraInfo and extraInfo.partId
	combatCasterInfo.isFromAutoCast = extraInfo and extraInfo.fromAutoCast

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity and targetEntity.isInCapture == true then
		targetActorId = nil
	end

	combatCasterInfo.targetActorId = targetActorId

	return self:castAbilityInternal(abilityId, combatCasterInfo, castSource, extraInfo)
end

function AbilityComponent:castAbilityOnPosRot(abilityId, position, rotation, castSource)
	local combatCasterInfo = self.castingMap[abilityId]

	if not combatCasterInfo then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST
	end

	combatCasterInfo:ctor(self.actorId)

	combatCasterInfo.attackPos = Vector3.Clone(position)
	combatCasterInfo.attackRot = Quaternion.Clone(rotation)

	return self:castAbilityInternal(abilityId, combatCasterInfo, castSource)
end

function AbilityComponent:doAbilityCast(abilityId, ability, combatCasterInfo, castSource, extraInfo)
	local abilityObject = ability:getAbilityObject()

	if abilityObject.combatContext then
		abilityObject.combatContext:setConstCasterInfo(combatCasterInfo)
	end

	self:onAbilityStart(abilityId, combatCasterInfo, castSource, extraInfo)

	if Switch.EnableRuntimeDebug then
		AbilityDebugTool.clearRuntimeDebugInfo(self.actorId, abilityId)
		AbilityDebugTool.startAbilityCastCoroutine(function()
			ability:cast(combatCasterInfo, castSource, extraInfo)
		end)

		return true, AbilityConst.ABILITY_CAST_FAILED_NONE
	end

	ability:cast(combatCasterInfo, castSource, extraInfo)

	if pg.component == "game" then
		if (Utils.isPlayer(self) or Utils.isPlayerPet(self)) and self.space then
			self.space:emitSpaceEvent(ServerEventConst.USE_ABILITY, {
				abilityId = abilityId,
				actorId = self.actorId
			})
		end

		if self.pveBossCastAbility then
			self:pveBossCastAbility()
		end
	end
end

function AbilityComponent:castAbilityInternal(abilityId, combatCasterInfo, castSource, extraInfo)
	combatCasterInfo.castSource = castSource
	abilityId = self:getSwitchSkill(abilityId)

	local result, reason = self:checkCanCastAbility(abilityId, combatCasterInfo.targetActorId, castSource, nil, true, extraInfo)

	if not result then
		return false, reason
	end

	local ability = self:getAbility(abilityId)

	if ability == nil then
		return false, AbilityConst.ABILITY_CAST_ABILITY_NOT_EXIST
	end

	self:doAbilityCast(abilityId, ability, combatCasterInfo, castSource, extraInfo)

	return true, AbilityConst.ABILITY_CAST_FAILED_NONE
end

function AbilityComponent:isCastingAbility(abilityId)
	return self.combatTimelineRef.cnt > 0 and self.combatTimelineRef.abilityId == abilityId
end

function AbilityComponent:getCastingAbilityId()
	return self.combatTimelineRef.cnt > 0 and self.combatTimelineRef.abilityId or 0
end

function AbilityComponent:isCastingUltimateAbility()
	return AbilityUtils.isUltimateAbility(self:getCastingAbilityId()) or false
end

function AbilityComponent:updateAbilityTimeScale()
	local scale = self:getCurFrameFreezeScale()

	if self.setTimeScale then
		self:setTimeScale(scale, AbilityConst.TIME_SCALE_KEY_FRAME_FREEZE)
	end
end

function AbilityComponent:tickAbility(deltaTime)
	if not next(self.abilityTickRefMap) then
		return
	end

	self:tickFrameFreeze(deltaTime)
	self:updateAbilityTimeScale()

	local timeScale = self:getSelfTimeScale()

	deltaTime = deltaTime * timeScale

	self:onAbilityActivate(deltaTime)

	if rawget(self, "needFastForwardTimelineId") then
		local fastForwardTimelineId = self.needFastForwardTimelineId

		self.needFastForwardTimelineId = nil

		self:doFastForward(fastForwardTimelineId)
	end
end

function AbilityComponent:tickFrameFreeze(deltaSecond)
	for key, info in pairs(self.frameFreezeMap) do
		info[2] = info[2] - deltaSecond

		if info[2] <= 0 then
			self:stopFrameFreeze(key)
		end
	end
end

function AbilityComponent:onAbilityActivate(deltaSecond)
	self.skillStateMgr:tick(deltaSecond)

	if rawget(self, "forceDisplacementData") then
		self:tickForceDisplacement(deltaSecond)
	end

	if rawget(self, "followTargetData") then
		self:tickFollowTarget(deltaSecond)
	end

	if next(self.entityTimer.tasks) then
		self.entityTimer:update(deltaSecond)
	end

	local abilityTickRefMap = self.abilityTickRefMap

	if abilityTickRefMap[TICK_REASON_TIMELINE] then
		self.actorTimeline:activate(deltaSecond)
	end

	if abilityTickRefMap[TICK_REASON_BUFF] then
		self.actorBuff:activate(deltaSecond)
	end

	if next(self.spreadAnnularSectors) then
		self:activateSpreadAnnularSectors(deltaSecond)
	end

	if rawget(self, "specialAttackModeData") then
		self:tickSpecialAttackMode(deltaSecond)
	end

	if self.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_MOVE_CHANGE) then
		self:updateMovingState(deltaSecond)
	end
end

function AbilityComponent:getAttackCombatTimelineCnt(abilityId)
	if not self.combatTimelineRef.isNormalAttack then
		return 0
	end

	if ToBool(abilityId) then
		return self.combatTimelineRef.abilityId == abilityId and self.combatTimelineRef.cnt or 0
	else
		return self.combatTimelineRef.cnt
	end
end

function AbilityComponent:getSkillCombatTimelineCnt(abilityId)
	if self.combatTimelineRef.isNormalAttack then
		return 0
	end

	if ToBool(abilityId) then
		return self.combatTimelineRef.abilityId == abilityId and self.combatTimelineRef.cnt or 0
	else
		return self.combatTimelineRef.cnt
	end
end

function AbilityComponent:getTimelineInstance(timelineInsId)
	return self.actorTimeline:getTimelineInstance(timelineInsId)
end

function AbilityComponent:isAbilityEdgeBlocking()
	if self.combatTimelineRef.cnt > 0 then
		local paramData = pg.global.abilityMgr:getAbilityParamData(self.combatTimelineRef.abilityId)

		if ToBool(paramData.ignoreStepHeightDownInSkill) then
			return false
		end

		return true
	end

	return false
end

function AbilityComponent:isAbilityCanSwitchPet()
	if self.combatTimelineRef.cnt > 0 then
		local paramData = pg.global.abilityMgr:getAbilityParamData(self.combatTimelineRef.abilityId)

		if ToBool(paramData.allowSwitchPet) then
			return true
		end
	end

	return false
end

function AbilityComponent:refreshAbilityMask(ability)
	if self.jumpingTimelineRefCnt == 0 and not Utils.isCreation(self) then
		self:setActionMask(AbilityConst.ACTION_MASK_IN_ATTACK, self:getAttackCombatTimelineCnt() > 0, ability and ability.abilityId or 0)
		self:setActionMask(AbilityConst.ACTION_MASK_IN_SKILL, self:getSkillCombatTimelineCnt() > 0, ability and ability.abilityId or 0)
	end
end

function AbilityComponent:activateSpreadAnnularSectors(deltaSecond)
	table.clear(self.tempTbl)

	for index, spreadAnnularSectorData in ipairs(self.spreadAnnularSectors) do
		if not spreadAnnularSectorData.isEnd then
			spreadAnnularSectorData:activate(deltaSecond)

			if spreadAnnularSectorData.isEnd then
				table.insert(self.tempTbl, index)
			end
		end
	end

	for _, i in ipairs(self.tempTbl) do
		table.remove(self.spreadAnnularSectors, i)
		self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SPREAD_ANNULAR_SECTOR)
	end
end

function AbilityComponent:calcHitActionTimelineIdAndImpulse(combatContext, attackData)
	local inBreak = self:inBreak()

	if self.bodyWeight == nil and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("bodyWeight is nil", self.actorId)
	end

	local impulseId = AbilityUtils.getAttackDataImpulseId(attackData, self:isInAir())

	if self.isSpecialRidden then
		return AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	local impulseData = ImpulseData[impulseId] or {}
	local rawImpulseType = impulseData.impulseType

	if AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[rawImpulseType] == nil then
		return AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	if self.actorBuff:hasTag(AbilityConst.BUFF_TAG_SUPER_ARMOR) or Utils.isCreation(self) or Utils.isRobEggSpaceEgg(self) then
		return AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	if self:inBreakFall() then
		return AbilitySettingGlobalConstData.breakFlyHitTimelineId or AbilitySettingGlobalConstData.flyHitTimelineIdNone, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and Utils.isPuppet(ownerEntity) and not ownerEntity:getConfigData().canKnockFly and (rawImpulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP or rawImpulseType == AbilityConst.ATTACK_FORCE_KNOCK_STAND) then
		rawImpulseType = AbilityConst.ATTACK_FORCE_KNOCK_HEAVY
	end

	local impulseType = math.abs(rawImpulseType)
	local attackerWeightLevel = ownerEntity and ownerEntity.weightLevel or 0
	local beHitWeightLevel = self.weightLevel or 0

	if impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP or impulseType == AbilityConst.ATTACK_FORCE_KNOCK_HEAVY then
		impulseType = math.max(AbilityConst.ATTACK_FORCE_KNOCK_LIGHT, impulseType - math.max(0, beHitWeightLevel - attackerWeightLevel))
	else
		impulseType = math.max(AbilityConst.ATTACK_FORCE_KNOCK_SHAKE, impulseType - math.max(0, beHitWeightLevel - attackerWeightLevel))
	end

	if math.abs(rawImpulseType) == impulseType and rawImpulseType == AbilityConst.ATTACK_FORCE_KNOCK_STAND then
		impulseType = rawImpulseType
	end

	local tp = self.actorCombatAttribute:getTp() + self.actorCombatAttribute:getTempTp()

	if tp > 0 and not inBreak then
		impulseType = AbilityConst.ATTACK_FORCE_KNOCK_SHAKE
	end

	local conflictType = AbilityConst.HIT_TIMELINE_STATE_CONFLICT_MAP[impulseType]

	if conflictType and not self:checkStatus(conflictType) then
		impulseType = AbilityConst.ATTACK_FORCE_KNOCK_SHAKE
	end

	if tp <= 0 and Utils.isPlayer(self) and impulseType ~= AbilityConst.ATTACK_FORCE_KNOCK_SHAKE and impulseType ~= AbilityConst.ATTACK_FORCE_KNOCK_NONE then
		return AbilitySettingGlobalConstData.hitTimelineIdHitAvatar, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	local dir

	if tp <= 0 and self:isInAir() then
		local impulseData = ImpulseData[impulseId] or {}

		if impulseData.airHorizontalImpulse or impulseData.airVerticalImpulse then
			impulseType = AbilityConst.ATTACK_FORCE_KNOCK_UP

			if self:FLY_ST() and self.stopFly then
				self:stopFly()
			end

			dir = ownerEntity:getRotation():MulVec3(Vector3.forward)
			dir.y = 0

			Vector3.SetNormalize(dir)
		end
	end

	if impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and self:CARRY_EGG_ST() then
		impulseType = AbilityConst.ATTACK_FORCE_KNOCK_HEAVY
	end

	if impulseType == AbilityConst.ATTACK_FORCE_KNOCK_UP and not dir then
		local rotation = Quaternion(0, 0, 0, 1)

		if impulseData ~= nil then
			CombatActionTool.parseRotationFromTo(combatContext, impulseData.impulseRot, impulseData.impulseRotTo, rotation)
		else
			CombatActionTool.parseRotationFromTo(combatContext, attackData.impulseRot, attackData.impulseRotTo, rotation)
		end

		if ToBool(attackData.impulseRotateYaw) then
			rotation = rotation * Quaternion.AngleAxis(attackData.impulseRotateYaw, Vector3.up)
		end

		dir = Quaternion.MulVec3(rotation, Vector3.forward)
		dir.y = 0

		Vector3.SetNormalize(dir)
	end

	if impulseType == AbilityConst.ATTACK_FORCE_KNOCK_SHAKE and (self:inSkill() or self:inAttack()) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("in skill state, play hitTimelineIdShakeNoAnimation", AbilitySettingGlobalConstData.hitTimelineIdShakeNoAnimation)
		end

		return AbilitySettingGlobalConstData.hitTimelineIdShakeNoAnimation or AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, nil, AbilityConst.ATTACK_FORCE_KNOCK_NONE
	end

	local timelineName = self:inBreak() and AbilityConst.ATTACK_BREAK_FORCE_TO_TIMELINE_NAME[impulseType] or AbilityConst.ATTACK_FORCE_TO_TIMELINE_NAME[impulseType]

	if not self:inBreak() and impulseType >= AbilityConst.ATTACK_FORCE_KNOCK_LIGHT and impulseType <= AbilityConst.ATTACK_FORCE_KNOCK_UP then
		local counterAttackName = AbilityConst.ATTACK_FORCE_TYPE_TO_COUNTER_ATTACK_TYPE[impulseType]
		local configData = self:getConfigData()
		local counterAttackTimelineIds = configData[counterAttackName]

		if ToBool(counterAttackTimelineIds) then
			local timelineCnt = #counterAttackTimelineIds + 1
			local index = math.random(1, timelineCnt)

			if index ~= timelineCnt then
				return counterAttackTimelineIds[index] or AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, dir, AbilityConst.ATTACK_FORCE_KNOCK_NONE
			end
		end
	end

	return AbilitySettingGlobalConstData[timelineName] or AbilitySettingGlobalConstData.hitTimelineIdNone, impulseId, dir, impulseType
end

function AbilityComponent:checkHitTargetSet(actorId, abilityId, actionData)
	local hitBoxId = actionData.hitBoxId

	if not ToBool(hitBoxId) then
		return true
	end

	local abilitySetInfo = self.hitTargetSetMap[abilityId]

	if abilitySetInfo == nil then
		return true
	end

	local hitEntities = abilitySetInfo[hitBoxId]

	if hitEntities == nil then
		return true
	end

	local maxHitEntityCnt = actionData.hitBoxMaxHitEntityCnt

	if ToBool(maxHitEntityCnt) and hitEntities[actorId] == nil and maxHitEntityCnt <= table.getCount(hitEntities) then
		return false
	end

	local hitBoxMaxHitCnt = actionData.hitBoxMaxHitCnt or 1

	return hitBoxMaxHitCnt > (hitEntities[actorId] or 0)
end

function AbilityComponent:addHitTargetActorId(actorId, abilityId, actionData)
	if not actionData or not actorId then
		return true
	end

	local hitBoxId = actionData.hitBoxId

	if not ToBool(hitBoxId) then
		return true
	end

	if not abilityId then
		return true
	end

	local abilitySetInfo = self.hitTargetSetMap[abilityId]

	if abilitySetInfo == nil then
		self.hitTargetSetMap[abilityId] = {}
		abilitySetInfo = self.hitTargetSetMap[abilityId]
	end

	if not abilitySetInfo then
		return true
	end

	local hitEntities = abilitySetInfo[hitBoxId]

	if hitEntities == nil then
		hitEntities = {
			[actorId] = 1
		}
		abilitySetInfo[hitBoxId] = hitEntities

		return true
	end

	hitEntities[actorId] = (hitEntities[actorId] or 0) + 1

	return true
end

function AbilityComponent:clearHitBox(abilityId, hitBoxId)
	if hitBoxId == nil then
		self.hitTargetSetMap[abilityId] = {}
	elseif self.hitTargetSetMap[abilityId] then
		lume.clear(self.hitTargetSetMap[abilityId])

		self.hitTargetSetMap[abilityId][hitBoxId] = {}
	end
end

function AbilityComponent:checkHitTargetCd(actorId, abilityId, actionData, overrideTime)
	local hitCd = actionData.hitCd

	if not ToBool(hitCd) then
		return true
	end

	local hitCdInfo = self.hitTargetCdMap[abilityId]

	if hitCdInfo == nil then
		return true
	end

	local lastTime = hitCdInfo[actorId]
	local time = overrideTime or self:getGameTime()

	return lastTime == nil or math.fixedFloat(lastTime + hitCd) <= math.fixedFloat(time)
end

function AbilityComponent:addHitTargetCd(actorId, abilityId, actionData, overrideTime)
	local hitCd = actionData.hitCd

	if not ToBool(hitCd) then
		return true
	end

	local hitCdInfo = self.hitTargetCdMap[abilityId]

	if hitCdInfo == nil then
		self.hitTargetCdMap[abilityId] = {}
		hitCdInfo = self.hitTargetCdMap[abilityId]
	end

	hitCdInfo[actorId] = overrideTime or self:getGameTime()

	return true
end

function AbilityComponent:clearHitTargetCd(abilityId)
	self.hitTargetCdMap[abilityId] = nil
end

function AbilityComponent:destroy()
	if self.actorTimeline then
		self.actorTimeline:stopAll()

		self.actorTimeline = nil
	end

	if self.entityTimer then
		self.entityTimer:clear()
	end

	if self.actorBuff then
		self.actorBuff:destroy()
	end

	if self.abilityMap then
		for _, ability in pairs(self.abilityMap) do
			ability:destroy()
		end
	end

	if self.actorCombatAttribute then
		self.actorCombatAttribute:clear()
	end
end

function AbilityComponent:getSwitchSkill(abilityId)
	if ToBool(self.switchSkillData[abilityId]) then
		abilityId = self.switchSkillData[abilityId]
	end

	local abilityLevelTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId, 1)

	if abilityLevelTemplate == nil then
		return abilityId
	end

	if ToBool(abilityLevelTemplate.switchSkillByState) then
		for stateName, switchSkillId in pairs(abilityLevelTemplate.switchSkillByState) do
			if CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst[stateName]) then
				return switchSkillId
			end
		end
	end

	if self.stolenAbilityRef[abilityId] then
		abilityId = self.stolenAbilityRef[abilityId].stolenAbilityId
	end

	return abilityId
end

function AbilityComponent:inInvincible()
	return self.actorBuff:hasTag(AbilityConst.BUFF_TAG_INVINCIBLE)
end

function AbilityComponent:inBreak()
	return self.actorBuff:hasTag(AbilityConst.BUFF_TAG_BREAK) or self.actorBuff:hasTag(AbilityConst.BUFF_TAG_BREAK_FALL)
end

function AbilityComponent:inBreakRecover()
	return not self.actorBuff:hasTag(AbilityConst.BUFF_TAG_BREAK) and not self.actorBuff:hasTag(AbilityConst.BUFF_TAG_BREAK_FALL) and self:getGameTime() < self.breakRecoverTime
end

function AbilityComponent:inBreakFall()
	return self.actorBuff:hasTag(AbilityConst.BUFF_TAG_BREAK_FALL)
end

function AbilityComponent:inCharm()
	return self.actorBuff:hasTag(AbilityConst.BUFF_TAG_CHARM)
end

function AbilityComponent:isTimeScaleNoEffect()
	return self.actorBuff:hasTag(AbilityConst.BUFF_TAG_TIMESCALE_NO_EFFECT)
end

function AbilityComponent:switchSkill(from, to, endTime)
	self.switchSkillData[from] = to

	if not ToBool(to) then
		return
	end

	self:postComponentMethod("onSkillSwitched", from, to, from ~= to, endTime)
end

function AbilityComponent:clearSwitchSkillRecoverTimer(from)
	if from == nil then
		for fromId, timerId in pairs(self.switchSkillTimerMap) do
			self:removeTimer(timerId)

			self.switchSkillTimerMap[fromId] = nil
			self.switchSkillRecoverEndTimeMap[fromId] = nil
		end

		return
	end

	local timerId = self.switchSkillTimerMap[from]

	if timerId then
		self:removeTimer(timerId)

		self.switchSkillTimerMap[from] = nil
	end

	self.switchSkillRecoverEndTimeMap[from] = nil
end

function AbilityComponent:startSwitchSkillRecoverTimer(from, duration, recoverEndTime)
	self:clearSwitchSkillRecoverTimer(from)

	self.switchSkillRecoverEndTimeMap[from] = recoverEndTime
	self.switchSkillTimerMap[from] = self:addTimer(duration, function()
		self.switchSkillTimerMap[from] = nil

		self:doSwitchSkillRecover(from)
	end)
end

function AbilityComponent:doSwitchSkillRecover(from)
	if not ToBool(from) then
		return
	end

	local recoverEndTime = self.switchSkillRecoverEndTimeMap[from]

	self.switchSkillTimerMap[from] = nil
	self.switchSkillRecoverEndTimeMap[from] = nil

	self:switchSkill(from, from, recoverEndTime)
end

function AbilityComponent:getCurFrameFreezeScale()
	local scale = 1

	for key, info in pairs(self.frameFreezeMap) do
		scale = scale * info[1]
	end

	return scale
end

function AbilityComponent:startFrameFreeze(key, timeScale, duration, force)
	if self.isDummyClone and not force then
		return
	end

	self.frameFreezeMap[key] = {
		timeScale,
		duration
	}

	self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.FRAME_FREEZE)
end

function AbilityComponent:stopFrameFreeze(key)
	self.frameFreezeMap[key] = nil

	self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.FRAME_FREEZE)
end

function AbilityComponent:startSpreadAnnularSector(actionData, combatContext)
	for _, targetData in ipairs(actionData.target) do
		local spreadAnnularSectorData = SpreadAnnularSectorData(self, actionData, Utils.deepCopyTable(targetData), combatContext)

		table.insert(self.spreadAnnularSectors, spreadAnnularSectorData)
		spreadAnnularSectorData:activate(0)
		self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SPREAD_ANNULAR_SECTOR)
	end
end

function AbilityComponent:startListenStunOnCollision(observer, callback)
	observer:listen(self.subject, AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION, callback)
end

function AbilityComponent:checkCanUsePetAbility(abilityId)
	local petEnt = self:getCurPetEntity()

	if petEnt then
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId) or {}
		local petUseAbilityType = abilityTemplate.petUseAbilityType

		if petUseAbilityType == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("ability template not found usePetAbilityType")
			end

			return false, AbilityConst.ABILITY_CAST_FAILED_PET_NOT_FOUND
		end

		local abilityInfo = petEnt:getSkillByType(petUseAbilityType)
		local petAbilityId = abilityInfo and abilityInfo.abilityId
		local result, reason = petEnt:checkCanCastAbilityNoTarget(petAbilityId)

		return result, reason, petAbilityId
	end

	return false
end

function AbilityComponent:updateKnockUpInvincibleState(state)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("updateKnockUpInvincibleState", state)
	end

	if state == AbilityConst.KNOCK_STATE_UP_END then
		if self.knockUpInvincibleTimer ~= nil then
			self:removeTimer(self.knockUpInvincibleTimer)
		end

		self.knockUpInvincibleTimer = self:addTimer(AbilityConst.KNOCK_UP_RECOVER_MAX_TIME, function()
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:debug("clear knockUpInvincibleTimer by timer")
			end

			self.knockUpInvincibleTimer = nil

			AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.KNOCK_UP_INVINCIBLE, false)
		end)

		AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.KNOCK_UP_INVINCIBLE, true)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("set knockUpInvincibleTimer", self.knockUpInvincibleTimer, Utils.checkValidTarget(self, self))
		end
	else
		if self.knockUpInvincibleTimer ~= nil then
			self:removeTimer(self.knockUpInvincibleTimer)
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("clear knockUpInvincibleTimer")
		end

		self.knockUpInvincibleTimer = nil

		AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.KNOCK_UP_INVINCIBLE, false)
	end
end

function AbilityComponent:setRePressAbilitySlotInfo(abilityId, endTime, enableCountDown)
	if not abilityId then
		return
	end

	if not endTime then
		self.rePressSkillSlotInfo[abilityId] = nil
	else
		self.rePressSkillSlotInfo[abilityId] = {
			abilityId = abilityId,
			endTime = endTime
		}
	end
end

function AbilityComponent:handleSwitchAbility(ability, enable)
	if ability and ability:isSwitchAbility() then
		local abilityId = ability.abilityId

		if enable and not self.switchMap[abilityId] then
			self.switchMap[abilityId] = self:getGameTime()
		elseif not enable and self.switchMap[abilityId] then
			self.switchMap[abilityId] = nil

			if pg.component == "game" then
				local ability = self:getAbility(abilityId)
				local cd = AbilityUtils.getAbilityParamCd(abilityId, self)

				ability:startCoolDown(self:getGameTime() + cd)
			end
		end
	end
end

function AbilityComponent:enableSpecialAttackMode(enable, duration, overrideData)
	if enable then
		self.specialAttackModeData = overrideData

		local hasEndTime = duration and duration >= 0

		self.specialAttackModeData.shouldEndTime = hasEndTime and self:getGameTime() + duration or nil
		self.specialAttackModeData.isInfinite = not hasEndTime

		self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SPECIAL_ATTACK_MODE)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj onEnableSpecialAttackMode", duration)
		end
	else
		local exitActionIds = self.specialAttackModeData.exitActionIds
		local combatContext = self.specialAttackModeData.combatContext

		if exitActionIds ~= nil and combatContext ~= nil then
			self.combatAction:doActionIds(exitActionIds, combatContext)
		end

		self.specialAttackModeData = nil

		self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.SPECIAL_ATTACK_MODE)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("@hyj onExitSpecialAttackMode")
		end
	end

	self:postComponentMethod("EVENT_OnSpecialAttackModeChange")
end

function AbilityComponent:tickSpecialAttackMode(deltaSecond)
	if self.specialAttackModeData and self.specialAttackModeData.duration then
		local remainDuration = self.specialAttackModeData.duration - deltaSecond

		self.specialAttackModeData.duration = remainDuration

		if not self.specialAttackModeData.isInfinite and remainDuration <= 0 then
			if self.specialAttackModeData.switchSkillInfo.to then
				self:switchSkill(self.specialAttackModeData.switchSkillInfo.from)

				self.specialAttackModeData.switchSkillInfo.to = nil
			end

			if self.specialAttackModeData.keepModeInSkill and self:inAbility() then
				return
			end

			if self:inAttack() then
				return
			end

			self:enableSpecialAttackMode(false)
		end
	end
end

function AbilityComponent:checkExitSpecialAttackMode(mask, value)
	if not self.specialAttackModeData then
		return
	end

	local canCheck = false

	if self.specialAttackModeData.checkMask ~= nil and mask == self.specialAttackModeData.checkMask and value == true then
		canCheck = true
	end

	if not mask then
		canCheck = true
	end

	if not canCheck then
		return
	end

	if self.specialAttackModeData and self.specialAttackModeData.duration and not self.specialAttackModeData.isInfinite and self.specialAttackModeData.duration <= 0 then
		self:enableSpecialAttackMode(false)
	end
end

function AbilityComponent:checkSpecialAttackModeNextAction(abilityId)
	if self.specialAttackModeData and self.specialAttackModeData.switchSkillInfo and (self.specialAttackModeData.shouldEndTime == nil or self.specialAttackModeData.shouldEndTime < self:getGameTime()) then
		local abilityData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		if abilityData.abilityType == EnumAbilityType.Attack then
			return true
		end
	end

	return false
end

function AbilityComponent:startFollowTarget(targetActorId, followSpeed, stopDistance)
	if Utils.checkClient() and self.eModel then
		self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.FollowTarget)
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("start follow target", targetActorId, followSpeed, stopDistance)
	end

	self.followTargetData = {
		targetActorId = targetActorId,
		followSpeed = followSpeed,
		stopDistance = stopDistance
	}

	if self.updateStateCache then
		self:updateStateCache("ABILITY_FOLLOW_TARGET_ST")
	end
end

function AbilityComponent:stopFollowTarget()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("stop follow target")
	end

	self.followTargetData = nil

	if Utils.checkClient() and self.eModel then
		self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.FollowTarget)
	end

	if self.updateStateCache then
		self:updateStateCache("ABILITY_FOLLOW_TARGET_ST")
	end
end

function AbilityComponent:tickFollowTarget(deltaSeconds)
	local targetEntity = pg.getEntityByActorId(self.followTargetData.targetActorId)

	if not targetEntity then
		self:stopFollowTarget()

		return false
	end

	local offset = targetEntity:getPosition() - self:getPosition()
	local dir = Vector3.Normalize(Vector3(offset.x, 0, offset.z))
	local stopDistance = self.followTargetData.stopDistance or 0.1
	local deltaPosition = dir * self.followTargetData.followSpeed * deltaSeconds

	if Vector3.SqrMagnitude(offset) < stopDistance * stopDistance then
		if Utils.checkClient() and self.eModel then
			self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.FollowTarget)
		end

		return
	elseif Vector3.SqrMagnitude(deltaPosition) > Vector3.SqrMagnitude(offset) then
		deltaPosition = offset
	end

	self:setAbilityDisplacementOffset(deltaPosition, deltaSeconds)
end

function AbilityComponent:startReboundDash(actionData, combatContext)
	self.reboundDashData = {
		actionData = actionData,
		combatContext = combatContext:clone()
	}

	if self.updateStateCache then
		self:updateStateCache("REBOUND_DASH_ST")
	end
end

function AbilityComponent:endReboundDash()
	if Utils.checkClient() and self.eModel then
		self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.ReboundDash)
	end

	if not self.reboundDashData then
		return
	end

	local reboundData = self.reboundDashData

	self.reboundDashData = nil

	if self.updateStateCache then
		self:updateStateCache("REBOUND_DASH_ST")
	end

	pg.global.abilityMgr.combatAction:doActionIds(reboundData.actionData.endActionIds, reboundData.combatContext)
end

function AbilityComponent:onReboundDashHitActor(hitActorId, hitPos)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("onReboundDashHitActor", self.actorId, hitActorId, hitPos)
	end

	if not self.reboundDashData then
		return
	end

	local runtimeHit = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	runtimeHit:initTarget(hitActorId, hitPos, 0, 0)

	self.reboundDashData.combatContext.runtimeTargetInfo = runtimeHit

	pg.global.abilityMgr.combatAction:doActionIds(self.reboundDashData.actionData.hitActionIds, self.reboundDashData.combatContext)

	self.reboundDashData.combatContext.runtimeTargetInfo = nil

	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeHit)
end

function AbilityComponent:updateMovingState(deltaSecond)
	local lastIsMoving = self.isPositionMoved

	self.isPositionMoved = Vector3.SqrDistance(self:getLastPosition(), self:getPosition()) > 0.0001

	if lastIsMoving ~= self.isPositionMoved then
		self.subject:notify(AbilityConst.COMBAT_EVENT_ON_MOVE_CHANGE, self.isPositionMoved)
	end
end

function AbilityComponent:addTempTPByHit()
	if not Utils.isPlayerPet(self) then
		return
	end

	if Utils.isPlayer(self) and not self:isControllingPet() then
		return
	end

	if Utils.isPet(self) and not self.isInControl then
		return
	end

	local function removeTpFunc()
		self.removeTempTPByHitTimer = nil

		local modifier = pg.global.abilityMgr.actorAttributeModifier
		local removeTp = AbilitySettingGlobalConstData.hitStaminaValue

		if self.actorCombatAttribute:getRawAttribValue(AttributeConst.tp_temp_cur) < AbilitySettingGlobalConstData.hitStaminaValue then
			removeTp = self.actorCombatAttribute:getRawAttribValue(AttributeConst.tp_temp_cur)
		end

		local changeMaxTp = AbilitySettingGlobalConstData.hitStaminaValue

		if self.actorCombatAttribute:getRawAttribValue(AttributeConst.tp_temp_max) < AbilitySettingGlobalConstData.hitStaminaValue then
			changeMaxTp = self.actorCombatAttribute:getRawAttribValue(AttributeConst.tp_temp_max)
		end

		modifier:modifyAttrib(self.actorCombatAttribute, AttributeConst.tp_temp_cur, -removeTp)
		modifier:modifyAttrib(self.actorCombatAttribute, AttributeConst.tp_temp_max, -changeMaxTp)
	end

	if self.removeTempTPByHitTimer then
		removeTpFunc()
	end

	local modifier = pg.global.abilityMgr.actorAttributeModifier

	modifier:modifyAttrib(self.actorCombatAttribute, AttributeConst.tp_temp_max, AbilitySettingGlobalConstData.hitStaminaValue)
	modifier:modifyAttrib(self.actorCombatAttribute, AttributeConst.tp_temp_cur, AbilitySettingGlobalConstData.hitStaminaValue)

	self.removeTempTPByHitTimer = self:addTimer(AbilitySettingGlobalConstData.hitStaminaValueTime, removeTpFunc)
end

function AbilityComponent:doFastForward(timelineId)
	local timeline = timelineId and self.actorTimeline:getTimelineInstance(timelineId)
	local combatContext = timeline and timeline.combatContext
	local abilityTemplate = combatContext and combatContext:getAbilityTemplate()
	local cutSceneDuration = abilityTemplate and abilityTemplate.cutSceneDuration

	if not cutSceneDuration then
		return
	end

	if cutSceneDuration <= 0 or timeline.playRate <= 0 then
		return
	end

	local fastForwardTime = math.max(0, (cutSceneDuration - timeline.curTimeStep) / timeline.playRate)

	if fastForwardTime <= 0 then
		return
	end

	combatContext.isCutSceneFastForwarding = true

	timeline:tick(fastForwardTime)

	if timeline.combatContext == combatContext then
		combatContext.isCutSceneFastForwarding = nil
	end
end

function AbilityComponent:setProjAroundSelf(actionData, combatContext)
	return
end

function AbilityComponent:clearProjAroundSelf()
	return
end

function AbilityComponent:destroyAllProjectile()
	for instanceId, projectile in pairs(self.createdProjectileList) do
		if not projectile.isDestroyed then
			projectile:destroy()
		end
	end

	lume.clear(self.createdProjectileList)
end

function AbilityComponent:addAbilityCollisionTest(key, actionData, combatContext, timerId)
	if self.abilityCollisionTestInfo[key] then
		self:returnCombatContext(self.abilityCollisionTestInfo[key].combatCtx)

		self.abilityCollisionTestInfo[key].data = actionData
		self.abilityCollisionTestInfo[key].combatCtx = combatContext
		self.abilityCollisionTestInfo[key].timerId = timerId
	else
		self.abilityCollisionTestInfo[key] = {
			data = actionData,
			combatCtx = combatContext,
			timerId = timerId
		}

		if Utils.isPuppet(self) and Utils.checkClient() then
			local eModel = self.eModel

			self.onKCCMovedAbilityRefCnt = (self.onKCCMovedAbilityRefCnt or 0) + 1

			local func = self.DC_OnKCCMove

			if func and eModel.onKCCMoved == nil then
				function eModel.onKCCMoved(velocity)
					func(self, velocity)
				end
			end
		end
	end

	self:addCombatContextRefCnt(combatContext)
end

function AbilityComponent:removeAbilityCollisionTest(key)
	if self.abilityCollisionTestInfo[key] then
		self:returnCombatContext(self.abilityCollisionTestInfo[key].combatCtx)

		if self.abilityCollisionTestInfo[key].timerId then
			self:removeTimer(self.abilityCollisionTestInfo[key].timerId)
		end

		self.abilityCollisionTestInfo[key] = nil

		if not ToBool(self.abilityCollisionTestInfo) and self.collisionHitRecordSet then
			self.collisionHitRecordSet:clear()
		end

		if Utils.isPuppet(self) and Utils.checkClient() then
			self.onKCCMovedAbilityRefCnt = math.max(self.onKCCMovedAbilityRefCnt - 1, 0)

			if self.onKCCMovedAbilityRefCnt == 0 then
				self.eModel.onKCCMoved = nil
			end
		end
	end
end

function AbilityComponent:onCSProjectileHit(copyCombatContext, actorId, pos, projectileData)
	copyCombatContext.csProjPos = pos

	local rawInfo = copyCombatContext.runtimeTargetInfo
	local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	copyCombatContext.runtimeTargetInfo = runtimeTargetInfo

	copyCombatContext.runtimeTargetInfo:initTarget(actorId, pos, 1, 0)
	pg.global.abilityMgr.combatAction:doActionIds(projectileData.hitActionIds, copyCombatContext)
	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(copyCombatContext.runtimeTargetInfo)

	copyCombatContext.runtimeTargetInfo = rawInfo
	copyCombatContext.csProjPos = nil
end

function AbilityComponent:addHitImpulse(impulseH, impulseV, dir, impulseId, airAttackLevel)
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	if impulseV ~= 0 then
		if not self:checkKnockUpState() then
			return
		end

		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_KNOCK_UP, impulseH, impulseV, dir, impulseId, airAttackLevel)
	else
		if self:inKnockUp() then
			local knockUpState = self.skillStateMgr[AbilityConst.SKILL_STATE_KNOCK_UP]

			if knockUpState:getState() ~= AbilityConst.KNOCK_STATE_UP_END and LoggerManager.checkLogger(LoggerConst.INFO) then
				self.logger:info("in knockUp state,but not in endState, can not knock back", self.actorId)
			end

			return
		end

		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_KNOCK_BACK, impulseH, dir)
	end
end

function AbilityComponent:enterForceDisplacement(targetPos, duration, speed, isInDir, distance, targetActorId, extraParams)
	extraParams = extraParams or {}

	if self.isTrapped or self.isInCapture then
		return
	end

	local notBlockInput = extraParams.notBlockInput

	if notBlockInput then
		if not self:checkStatus(ConflictTypes.CT_FORCE_DISPLACEMENT_NOT_BLOCK_INPUT) then
			return
		end
	elseif not self:checkStatus(ConflictTypes.CT_FORCE_DISPLACEMENT) then
		return
	end

	local ignoreKnockST = extraParams.ignoreKnockST

	if not ignoreKnockST and (self:inKnockBack() or self:inKnockUp()) then
		return
	end

	targetPos = Vector3.Clone(targetPos)

	local isRefresh = rawget(self, "forceDisplacementData") ~= nil

	self:initForceDisplacement(targetPos, duration, speed, isInDir, distance, targetActorId, extraParams)

	if not isRefresh then
		self:addAbilityTickReason(TICK_REASON_FORCE_DISPLACEMENT)
	end
end

function AbilityComponent:initForceDisplacement(targetPos, duration, speed, isInDir, distance, targetActorId, extraParams)
	if Utils.checkClient() and self.eModel then
		self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.ForceDisplacement)
	end

	local oldData = rawget(self, "forceDisplacementData")

	if oldData and not oldData.ignoreCollision then
		self:setForceDisplacementKccEnabled(false)
	end

	local dir

	if isInDir then
		dir = targetPos - self:getPosition()
	else
		dir = self:getPosition() - targetPos
	end

	if extraParams.ignoreYAxis then
		dir.y = 0
	end

	Vector3.SetNormalize(dir)

	self.forceDisplacementData = {
		targetPos = targetPos,
		targetActorId = targetActorId,
		duration = duration,
		speed = speed ~= 0 and speed or Vector3.Distance(targetPos, self:getPosition()) / duration,
		isInDir = isInDir,
		distance = distance > 0 and distance or nil,
		dir = dir,
		ignoreCollision = extraParams.ignoreCollision,
		notBlockInput = extraParams.notBlockInput
	}

	local data = self.forceDisplacementData

	if not data.ignoreCollision then
		self:setForceDisplacementKccEnabled(true)
	end

	self:updateForceDisplacementCache()
end

function AbilityComponent:setForceDisplacementKccEnabled(enabled)
	if Utils.checkClient() and self.eModel then
		self.eModel:EnableKccFullSimulation(Const.COMPONENT_MOTION, enabled, Const.KccControlType.ForceDisplacementControl)
	end
end

function AbilityComponent:updateForceDisplacementCache()
	if self.updateStateCache then
		self:updateStateCache("FORCE_DISPLACEMENT_ST")
		self:updateStateCache("FORCE_DISPLACEMENT_NOT_BLOCK_INPUT_ST")
	end
end

function AbilityComponent:setForceDisplacement(offset, deltaSeconds)
	if Utils.checkClient() then
		if self.eModel then
			local hasMotion = self.hasEModelComponent and self:hasEModelComponent(Const.COMPONENT_MOTION)

			if not hasMotion then
				local EModelUtils = require("Entities.Utils.EModelUtils")

				Vector3.enableCreateFromCache()

				local targetPos = self:getPosition() + offset

				EModelUtils.setAgentPosition(self, targetPos)
				Vector3.disableCreateFromCache()

				return
			end

			if deltaSeconds == nil or deltaSeconds <= 0 then
				self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.ForceDisplacement)

				return
			end

			self.eModel:SetDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.ForceDisplacement, offset / deltaSeconds, true, true)
		end
	elseif self.serverAddDisplacementOffset then
		self:serverAddDisplacementOffset(offset, true, true)
	end
end

function AbilityComponent:setForceDisplacementPosition(targetPos)
	if self.eModel then
		local EModelUtils = require("Entities.Utils.EModelUtils")

		EModelUtils.setAgentPosition(self, targetPos)
	else
		self:setPosition(targetPos)
	end
end

function AbilityComponent:tickForceDisplacement(deltaSeconds)
	local data = rawget(self, "forceDisplacementData")

	if not data then
		return
	end

	if self.hitFrameFreezeTimer then
		deltaSeconds = deltaSeconds * self.hitFrameFreezeScale
	end

	if data.duration <= 0 then
		self:stopForceDisplacement()

		return
	end

	if data.distance ~= nil and data.distance <= 0 then
		self:stopForceDisplacement()

		return
	end

	local offset

	if data.isInDir then
		if ToBool(data.targetActorId) then
			local targetEntity = pg.getEntityByActorId(data.targetActorId)

			if targetEntity then
				data.targetPos = targetEntity:getPosition()

				local xzDir = data.targetPos - self:getPosition()

				xzDir.y = 0

				xzDir:SetNormalize()

				if targetEntity.eModel and self.eModel then
					data.targetPos = data.targetPos - xzDir * (targetEntity.eModel.radius + self.eModel.radius)
				else
					local selfBodySize = self.bodySize or 0
					local targetBodySize = targetEntity.bodySize or 0

					data.targetPos = data.targetPos - xzDir * (targetBodySize + selfBodySize)
				end

				data.dir = data.targetPos - self:getPosition()

				Vector3.SetNormalize(data.dir)
			end
		end

		local fromTo = data.targetPos - self:getPosition()
		local targetDistance = Vector3.SqrMagnitude(fromTo)

		if targetDistance < data.speed * deltaSeconds then
			offset = fromTo
			data.distance = 0
		else
			offset = data.dir * data.speed * deltaSeconds
		end
	else
		offset = data.dir * data.speed * deltaSeconds
	end

	if ToBool(data.ignoreCollision) then
		self:setForceDisplacementPosition(self:getPosition() + offset)
	else
		self:setForceDisplacement(offset, deltaSeconds)
	end

	data.duration = data.duration - deltaSeconds
end

function AbilityComponent:stopForceDisplacement()
	local data = rawget(self, "forceDisplacementData")

	if Utils.checkClient() and self.eModel then
		self.eModel:ClearDisplacementVelocitySource(Const.COMPONENT_MOTION, Const.DisplacementVelocitySource.ForceDisplacement)
	end

	if not data then
		return
	end

	if not data.ignoreCollision then
		self:setForceDisplacementKccEnabled(false)
	end

	self.forceDisplacementData = nil

	self:removeAbilityTickReason(TICK_REASON_FORCE_DISPLACEMENT)
	self:updateForceDisplacementCache()
end

function AbilityComponent:notifyBuffTagChange(changelist, newVal)
	for _, tagId in ipairs(changelist) do
		if tagId == AbilityConst.BUFF_TAG_BREAK or tagId == AbilityConst.BUFF_TAG_BREAK_FALL then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:debug("break!!")
			end

			self:onBreakStateChange(newVal)
		end

		if AbilityConst.NEED_TICK_BUFF_TAG[tagId] then
			if newVal then
				self:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_TAG)
			else
				self:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.BUFF_TAG)
			end
		end

		if tagId == AbilityConst.BUFF_TAG_INVINCIBLE then
			AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IN_INVINCIBLE, self.inInvincible and self:inInvincible())
		end

		if tagId == AbilityConst.BUFF_TAG_DISABLE_LOCKED then
			AbilityUtils.setAbilityInvalidLock(self, AbilityConst.INVALID_LOCK_REASONS.BUFF_TAG_DISABLE_LOCKED, newVal == true)
		end
	end
end

return AbilityComponent
