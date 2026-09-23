-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Projectile\\Projectile.lua

local Class = require("Core.Framework.Class")
local ProjectileConst = require("Common.Const.ProjectileConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AbilityObject = require("Common.Ability.AbilityObject")
local AttributeSnapshot = require("Common.Ability.AttributeSnapshot")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Projectile")
local ListPool = require("Common.Container.ListPool")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local SysConfigData = require("Data.sys_config_data")
local CombatLogger = require("Common.Ability.CombatLogger")
local Projectile = Class.LiteClass("Projectile", AbilityObject)
local Vector3 = Vector3
local Quaternion = Quaternion
local pg = pg
local ToBool = ToBool

function Projectile:ctor()
	AbilityObject.ctor(self)
end

function Projectile:init(projectileParams, callCtor)
	self.templateId = projectileParams.templateId
	self.projectileTemplate = nil
	self.combatContext = nil
	self.isDestroyed = false
	self.isSleeping = false
	self.destroyOnHit = true
	self.projectileType = ProjectileConst.PROJECTILE_TYPE_NONE
	self.instanceId = projectileParams.instanceId
	self.lastHitActorId = nil
	self.lastHitActorPartIdx = nil
	self.pos = projectileParams.pos:Clone()
	self.srcActorId = projectileParams.srcActorId
	self.projectileMgr = pg.getEntityByActorId(self.srcActorId).space.projectileMgr
	self.timeScaleMgr = pg.getEntityByActorId(self.srcActorId).space.timeScaleMgr
	self.timeScale = 1
	self.globalFreeze = 1
	self.srcAbilityId = projectileParams.srcAbilityId
	self.srcAbilityStoreType = projectileParams.srcAbilityStoreType
	self.targetActorId = projectileParams.targetActorId
	self.trackingRandomOffset = projectileParams.trackingRandomOffset
	self.targetPos = Vector3.Clone(projectileParams.targetPosition)
	self.srcCombatContextId = projectileParams.srcCombatContextId
	self.castingCombatContextId = projectileParams.castingCombatContextId
	self.soundId = projectileParams.soundId
	self.hitTargetSet = {}
	self.accumulateTime = 0
	self.tickInterval = 0
	self.nextTickTime = 0
	self.curTime = 0
	self.duration = 0
	self.sleepTime = 0
	self.needSleepTime = 0
	self.effectId = ""
	self.chemElementId = pg.global.abilityMgr:getEcsElement(self.srcAbilityId)
	self.maxHitNum = 0
	self.curHitIdx = 0
	self.moveSpeed = 0
	self.acceleration = 0
	self.maxMoveSpeed = nil
	self.sweepRadius = 0
	self.groundSweepRadius = nil
	self.startSleepTime = projectileParams.startSleepTime
	self.rot = projectileParams.rotation:Clone()
	self.velocity = Vector3(0, 0, 0)
	self.gravityVelocity = Vector3(0, 0, 0)
	self.startPos = Vector3.Clone(projectileParams.pos)
	self.startDir = Vector3.Clone(projectileParams.emitDir)
	self.controlPos = {}
	self.circleData = projectileParams.circleData or {}
	self.iterNumber = projectileParams.iterNumber
	self.arriveDestination = nil

	self:setOwner(pg.getEntityByActorId(self.srcActorId), callCtor)

	if ToBool(self.owner.projectileAttrSnapshotRefCnt) then
		if self.attributeSnapshot == nil then
			self.attributeSnapshot = AttributeSnapshot()
		end

		self.attributeSnapshot:init(self.owner)
	else
		self.attributeSnapshot = nil
	end

	self.keepRot = nil
	self.maxReboundCnt = nil
	self.reboundRadius = nil
	self.reboundRelation = nil
	self.isReboundSelf = nil
	self.reboundRecord = nil
	self.initLockedActorId = nil
	self.hitEventName = nil
	self.hadNotifyAI = false
end

function Projectile:refreshTimeScale()
	local timeScale = 1

	if self.timeScaleMgr then
		timeScale = self.timeScaleMgr:getTimeScale(self.owner)
		self.globalFreeze = self.timeScaleMgr:getGlobalFreeze()
	else
		self.globalFreeze = 1
	end

	if self.timeScale ~= timeScale then
		self.timeScale = timeScale

		self:applyTimeScale()
	end
end

function Projectile:applyTimeScale()
	if self.effectGeneratorId and self.effectGeneratorId ~= 0 then
		local gameTimeScale = self.timeScaleMgr and self.timeScaleMgr.space.gameTimeScale or 1

		pg.game.effect:setTimeScale(self.effectGeneratorId, self.timeScale * gameTimeScale)
	end
end

function Projectile:notifyAI()
	if not self.projectileTemplate.impulseId then
		return
	end

	local masterEntity = Utils.getMasterPlayer(self.owner)

	if masterEntity then
		local targetEnt = pg.getEntityByActorId(masterEntity.lockedActorId)

		if targetEnt then
			AIControllerUtils.sendAIEvent(targetEnt, "ProjectileMoveTo", {
				velocity = Vector3.Magnitude(self.velocity),
				distance = Vector3.Distance(self.pos, targetEnt:getPosition())
			})
		end
	end
end

function Projectile:activate(deltaSeconds)
	if self.isDestroyed then
		return
	end

	if not self:checkSrcEntityValid() then
		self:destroy()

		return
	end

	if not self.hadNotifyAI and not self.isSleeping then
		self:notifyAI()

		self.hadNotifyAI = true
	end

	self:refreshTimeScale()

	deltaSeconds = deltaSeconds * self.timeScale * self.globalFreeze

	if not self.isDestroyed and self.isSleeping then
		if self.sleepTime >= self.needSleepTime then
			self.isSleeping = false
			self.curTime = self.curTime + self.sleepTime - self.needSleepTime

			if not self.isDestroyed and self.curTime >= self.duration then
				if not self.destroyImmediately then
					self:onResetToProjectile()

					return
				end

				self:destroy()

				return
			end
		else
			self.sleepTime = self.sleepTime + deltaSeconds

			return
		end
	end

	local preTime = self.curTime

	self.curTime = self.curTime + deltaSeconds

	if self.projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING then
		self:tickTrackingProjectile(deltaSeconds, preTime)
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_FREE3D then
		self:tickFree3DProjectile(deltaSeconds, preTime)
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_PARABOLA then
		self:tickParabolaProjectile(deltaSeconds)
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_BEZIER then
		self:tickBezierCurveProjectile(deltaSeconds, preTime)
	end

	if self.tickInterval > 0 then
		while self.curTime >= self.nextTickTime do
			self.nextTickTime = math.fixedFloat(self.nextTickTime + self.tickInterval)

			self:onTick()
		end
	end

	if pg.component == "game" and not self.isDestroyed and self.curTime >= self.duration then
		if not self.destroyImmediately then
			self:onResetToProjectile()

			return
		end

		self:destroy()

		return
	end
end

function Projectile:getHitPosition(targetEntity)
	return CombatActionTool.getHitPosition(targetEntity)
end

function Projectile:searchReboundTarget(centerEnt)
	local radius = self.reboundRadius
	local relation = self.reboundRelation
	local actorIds = ListPool.getList(3)
	local searchList = ListPool.getList(3)
	local searchCnt = centerEnt:entitiesInRangeWithCache(radius + 3, Const.SEARCH_USR_TYPE_ACTOR_CREATION, actorIds)
	local pos = centerEnt:getPosition()

	for i = 1, searchCnt do
		local ent = pg.getEntityByActorId(actorIds[i])
		local entPos = ent:getPosition()
		local sqrDis = Vector3.SqrDistance(pos, entPos)

		if Utils.checkRelation(self.owner, ent, relation) and sqrDis <= radius * radius and Utils.checkValidLock(ent, true) then
			searchList[#searchList + 1] = actorIds[i]
		end
	end

	table.sort(searchList, function(actorIdA, actorIdB)
		if self.reboundRecord and self.reboundRecord[actorIdA] ~= self.reboundRecord[actorIdB] then
			return not self.reboundRecord[actorIdA]
		end

		if self.initLockedActorId and (self.initLockedActorId == actorIdA or self.initLockedActorId == actorIdB) then
			return self.initLockedActorId == actorIdA
		end

		local disSqrA = Vector3.Distance(self.pos, pg.getEntityByActorId(actorIdA):getPosition())
		local disSqrB = Vector3.Distance(self.pos, pg.getEntityByActorId(actorIdB):getPosition())

		return disSqrA < disSqrB
	end)

	local resultEnt = pg.getEntityByActorId(searchList[1])

	ListPool.returnList(actorIds, 3)
	ListPool.returnList(searchList, 3)

	return resultEnt
end

function Projectile:tickTrackingProjectile(deltaSeconds, preTime)
	local targetEntity = self:getTargetEntity()
	local destPos

	if self.finalDestination or self.targetPos then
		destPos = self.finalDestination or self.targetPos
	else
		if not targetEntity then
			self:tickFree3DProjectile(deltaSeconds, preTime)

			return
		end

		destPos = self:getHitPosition(targetEntity)
	end

	local curPos = Vector3.getFromCache()

	curPos:Copy(self.pos)

	local maxAngularOffset = -1

	if self.enableMaxAngleTime <= 0 and ToBool(self.maxReboundCnt) == false then
		if self.angularIncreaseDuration <= self.angularConstraintElapsedTime then
			maxAngularOffset = self.maxAngularOffset
		else
			maxAngularOffset = math.lerp(self.minAngularOffset, self.maxAngularOffset, self.angularConstraintElapsedTime / self.angularIncreaseDuration)
			self.angularConstraintElapsedTime = self.angularConstraintElapsedTime + deltaSeconds
		end
	else
		self.enableMaxAngleTime = self.enableMaxAngleTime - deltaSeconds
	end

	local nextMoveSpeed = self.moveSpeed + self.acceleration * deltaSeconds

	nextMoveSpeed = math.max(nextMoveSpeed, 0)

	if self.maxMoveSpeed then
		nextMoveSpeed = math.min(nextMoveSpeed, self.maxMoveSpeed)
	end

	local avgMoveSpeed = (self.moveSpeed + nextMoveSpeed) * 0.5
	local nextPos, isEnd = CombatActionTool.interpConstantPoint(self.pos, destPos, deltaSeconds, avgMoveSpeed, self.rot, maxAngularOffset)

	self.pos:Copy(nextPos)
	Vector3.enableCreateFromCache()

	local dir = nextPos - curPos

	if dir:Magnitude() > 0.001 and not ToBool(self.keepRot) then
		self.rot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	end

	if not targetEntity and not destPos then
		self.duration = 0
	end

	Vector3.disableCreateFromCache()

	dir = nil

	local distSqr = Vector3.SqrDistance(destPos, curPos)
	local casterEntity = pg.getEntityByActorId(self.srcActorId)

	if casterEntity.authority == Const.AUTHORITY_MASTER and targetEntity and ToBool(self.maxReboundCnt) then
		isEnd = false

		if distSqr < 0.1 then
			if self.curReboundCnt < self.maxReboundCnt then
				local closestEnt = self:searchReboundTarget(targetEntity)

				if not closestEnt and self.isReboundSelf and targetEntity ~= self.owner and Vector3.HoriSqrDistance(curPos, self:getHitPosition(self.owner)) < self.reboundRadius * self.reboundRadius then
					closestEnt = self.owner
				end

				local hitResult = pg.global.abilityMgr.combatHitResultPool:getWithCtor(true, targetEntity.actorId, self.pos, targetEntity.actorPartIdx)

				self:onHitTarget(hitResult, closestEnt and closestEnt.actorId)

				if not closestEnt then
					self:destroy()
				else
					self.curTime = 0
					self.targetPos = nil
					self.finalDestination = nil

					if not self.reboundRecord then
						self.reboundRecord = {}
					end

					self.reboundRecord[closestEnt.actorId] = true
				end

				pg.global.abilityMgr.combatHitResultPool:returnObject(hitResult)
			else
				local hitResult = pg.global.abilityMgr.combatHitResultPool:getWithCtor(true, targetEntity.actorId, self.pos, targetEntity.actorPartIdx)

				self:onHitTarget(hitResult, 0)
				self:destroy()
				pg.global.abilityMgr.combatHitResultPool:returnObject(hitResult)
			end

			self.curReboundCnt = self.curReboundCnt + 1
		end
	end

	self.moveSpeed = nextMoveSpeed

	if not isEnd or pg.component == "game" then
		-- block empty
	else
		self.duration = 0
	end
end

function Projectile:tickFree3DProjectile(deltaSeconds, preTime)
	Vector3.enableCreateFromCache()

	local curPos = self.pos:Clone()
	local nextPos = self.pos:Clone()
	local isEnd = false
	local destination = self.destination or self.targetPos
	local nextVelocity, avgVelocity
	local nextMoveSpeed = self.moveSpeed + self.acceleration * deltaSeconds

	nextMoveSpeed = math.max(nextMoveSpeed, 0)

	if self.maxMoveSpeed then
		nextMoveSpeed = math.min(nextMoveSpeed, self.maxMoveSpeed)
	end

	local avgMoveSpeed = (self.moveSpeed + nextMoveSpeed) * 0.5

	if ToBool(self.noGravity) or self.curTime <= self.startNoGravityTime then
		nextVelocity = self.startDir * nextMoveSpeed
		avgVelocity = (self.velocity + nextVelocity) * 0.5

		if destination then
			local dir = destination - self.pos

			if ToBool(self.keepRot) then
				dir.y = 0
			end

			avgVelocity = Vector3.Normalize(dir) * avgMoveSpeed

			if Vector3.Magnitude(avgVelocity * deltaSeconds) > Vector3.Magnitude(dir) then
				avgVelocity = dir / deltaSeconds
				nextVelocity = avgVelocity
				isEnd = true
			end
		end

		nextPos = nextPos + avgVelocity * deltaSeconds

		if self.needMoveCenter then
			self.circleCenter:Copy(self.circleCenter + avgVelocity * deltaSeconds)
		end
	elseif preTime <= self.startNoGravityTime and self.curTime > self.startNoGravityTime then
		local noGravityTime = self.startNoGravityTime - preTime

		nextMoveSpeed = self.moveSpeed + self.acceleration * noGravityTime
		nextMoveSpeed = math.max(nextMoveSpeed, 0)

		if self.maxMoveSpeed then
			nextMoveSpeed = math.min(nextMoveSpeed, self.maxMoveSpeed)
		end

		nextVelocity = self.startDir * nextMoveSpeed
		avgVelocity = (self.velocity + nextVelocity) * 0.5
		nextPos = nextPos + avgVelocity * noGravityTime

		local t = self.curTime - self.startNoGravityTime
		local noGravityTimeVt = nextVelocity

		nextMoveSpeed = nextMoveSpeed + self.acceleration * t
		nextMoveSpeed = math.max(nextMoveSpeed, 0)

		if self.maxMoveSpeed then
			nextMoveSpeed = math.min(nextMoveSpeed, self.maxMoveSpeed)
		end

		nextVelocity = self.startDir * nextMoveSpeed

		self.gravityVelocity:Copy(self.gravity * t)

		local vt = nextVelocity + self.gravityVelocity

		nextPos = (vt + noGravityTimeVt) * t * 0.5 + nextPos

		if self.needMoveCenter then
			self.circleCenter:Copy(self.circleCenter + avgVelocity * noGravityTime)
			self.circleCenter:Copy((vt + self.velocity) * t * 0.5 + self.circleCenter)
		end
	else
		local preVelocity = self.velocity + self.gravityVelocity

		self.gravityVelocity:Copy(self.gravityVelocity + self.gravity * deltaSeconds)

		nextVelocity = self.startDir * nextMoveSpeed

		local vt = nextVelocity + self.gravityVelocity

		nextPos = nextPos + (vt + preVelocity) * deltaSeconds * 0.5

		if self.needMoveCenter then
			self.circleCenter:Copy(self.circleCenter + (vt + self.velocity) * deltaSeconds * 0.5)
		end
	end

	self.pos:Copy(nextPos)
	self.velocity:Copy(nextVelocity)

	self.moveSpeed = nextMoveSpeed

	local dir = nextPos - curPos

	if dir:Magnitude() > 0.001 and not ToBool(self.keepRot) then
		self.rot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	end

	if self.circleCenter then
		nextPos, nextVelocity = CombatActionTool.rotateAround(self.circleCenter, self.pos, self.velocity, self.projectileTemplate.rotOffsetDuringMoving, self.circleCenterForward, self.circleCenterUp, self.circleCenterLeft, deltaSeconds)

		self.pos:Copy(nextPos)
		self.velocity:Copy(nextVelocity)

		local newDir = self.velocity:Normalize()

		if newDir:Magnitude() > 0.001 then
			self.rot:Copy(Quaternion.LookRotation(newDir, self.circleCenterUp))
		end
	end

	if ToBool(isEnd) then
		if not self.destroyImmediately then
			if pg.component == "game" then
				-- block empty
			else
				self.duration = 0
			end

			Vector3.disableCreateFromCache()

			return
		end

		self.arriveDestination = true

		Vector3.disableCreateFromCache()

		return
	end

	Vector3.disableCreateFromCache()
end

function Projectile:tickParabolaProjectile(deltaSeconds)
	Vector3.enableCreateFromCache()

	local curPos = self.pos:Clone()
	local elapsedTime = math.clamp(self.curTime, 0, self.realDuration)
	local delta = elapsedTime / self.realDuration
	local nextPos = Vector3.Lerp(self.startPos, self.targetPos, delta)
	local deltaY = self.gravityRatio * (self.realDuration - elapsedTime) * elapsedTime * 0.5

	nextPos.y = nextPos.y + deltaY

	self.pos:Copy(nextPos)

	local dir = nextPos - curPos

	if not ToBool(self.keepRot) and dir:Magnitude() > 0.001 then
		self.rot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	end

	Vector3.disableCreateFromCache()
end

function Projectile:tickBezierCurveProjectile(deltaSeconds, preTime)
	if self.curTime >= self.realDuration and self.projectileTemplate.autoSwitchTrack then
		local targetEntity = self:getTargetEntity()

		if targetEntity then
			self.targetPos = self:getHitPosition(targetEntity)
		end

		self:tickTrackingProjectile(deltaSeconds, preTime)

		return
	end

	Vector3.enableCreateFromCache()

	local curPos = self.pos:Clone()
	local elapsedTime = math.clamp(self.curTime, 0, self.realDuration)
	local delta = elapsedTime / self.performDuration
	local nextPos = Vector3.BezierLerp(self.controlPos, delta)

	self.pos:Copy(nextPos)

	local dir = nextPos - curPos

	if not ToBool(self.keepRot) and dir:Magnitude() > 0.001 then
		self.rot:Copy(Quaternion.LookRotation(dir, Vector3.up))
	end

	if ToBool(self.heightAboveGround) then
		local succ, heightGround = PhysicsUtils.getGroundHeight(self.pos)

		if succ then
			self.pos.y = self.pos.y + self.heightAboveGround - heightGround
		end
	end

	Vector3.disableCreateFromCache()
end

function Projectile:clear()
	self.spaceId = 0
	self.hitTargetSet = {}
end

function Projectile:checkSrcEntityValid()
	return pg.getEntityByActorId(self.srcActorId) ~= nil
end

function Projectile:start()
	self:onStart()
	self:DoStartSleep()
end

function Projectile:destroy(ignoreTrigger)
	if self.isDestroyed then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj projectile is destroyed", self.isDestroyed)
		end

		return
	end

	self.isDestroyed = true

	if not ignoreTrigger then
		self:onHitFinish()
	end

	self:onDestroy()
	AbilityObject.clearObject(self)

	local entity = pg.getEntityByActorId(self.srcActorId)

	if entity then
		local srcCombatContext = entity:getCombatContext(self.srcCombatContextId)

		if srcCombatContext then
			entity:returnCombatContext(srcCombatContext)
		end
	end
end

function Projectile:onStart()
	local entity = pg.getEntityByActorId(self.srcActorId)

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj entity not found", self.srcActorId)
		end

		return
	end

	self:applyTimeScale()

	local ability = self:getSrcAbility()

	self.combatContext = entity:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE, self.instanceId)
	self.combatContext.BPName = self.projectileTemplate.BPName
	self.combatContext.projectileTemplateId = self.templateId

	local constCasterInfo = ability and ability:getCastingInfo()

	self.combatContext:setConstCasterInfo(constCasterInfo, self.owner.actorId)

	self.combatContext.runtimeTargetInfo = nil
	self.combatContext.abilityId = self.srcAbilityId
	self.combatContext.srcType = AbilityConst.SRC_TYPE_ABILITY
	self.combatContext.abilityStoreType = self.srcAbilityStoreType
	self.combatContext.iterNumber = self.iterNumber

	self.combatContext:initNodeMap()

	self.combatContext.srcCombatContextId = self.srcCombatContextId
	self.combatContext.castingCombatContextId = self.castingCombatContextId

	local srcCombatContext = entity:getCombatContext(self.srcCombatContextId)

	if srcCombatContext then
		entity:addCombatContextRefCnt(srcCombatContext)

		if srcCombatContext.castingCombatContextId then
			self.combatContext.castingCombatContextId = srcCombatContext.castingCombatContextId
		end

		self.combatContext.curEpCost = srcCombatContext.curEpCost
	end

	if Utils.isTable(self.maxReboundCnt) and self.maxReboundCnt.name then
		self.maxReboundCnt = entity.combatAction:doAction(self.maxReboundCnt, self.combatContext)
	end

	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_START]

	if not ToBool(triggerActions) then
		return false
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)
end

function Projectile:onDestroy()
	if self.onDestroyRPC then
		self:onDestroyRPC()
	end

	self.projectileMgr:removeProjectile(self.instanceId)

	self.owner.createdProjectileList[self.instanceId] = nil
end

function Projectile:loadDataFromTemplate()
	local projTemplate = pg.global.abilityMgr:getProjectileTemplate(self.templateId)

	if not projTemplate then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj projTempalte not found", self.templateId, self.templateIdList, self.curSegmentIndex)
		end

		return false
	end

	self.projectileType = ProjectileConst.PROJECTILE_TYPE_PARSER[projTemplate.kind]

	if not self.projectileType or self.projectileType == ProjectileConst.PROJECTILE_TYPE_NONE then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj wrong projectileType", self.templateId, self.projectileType, projTemplate.kind)
		end

		return false
	end

	local trackingMaxAngular = projTemplate.maxAngularOffset

	if self.projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING and Utils.isPuppet(self.owner) then
		if not ToBool(projTemplate.puppetTrackingMaxAngular) then
			self.projectileType = ProjectileConst.PROJECTILE_TYPE_FREE3D
		else
			trackingMaxAngular = projTemplate.puppetTrackingMaxAngular
		end
	end

	self.projectileTemplate = projTemplate

	if ToBool(projTemplate.nextTemplateId) then
		self.destroyImmediately = false
	else
		self.destroyImmediately = true
	end

	if projTemplate.destroyOnHit ~= nil then
		self.destroyOnHit = projTemplate.destroyOnHit
	end

	local maxHitNum = projTemplate.maxHitNum and projTemplate.maxHitNum or 1
	local gravityRatio = projTemplate.gravityRatio and projTemplate.gravityRatio or 0
	local moveSpeed = projTemplate.moveSpeed and projTemplate.moveSpeed or 0

	self.moveSpeed = moveSpeed

	if projTemplate.maxMoveSpeed then
		self.maxMoveSpeed = math.max(projTemplate.maxMoveSpeed, moveSpeed)
	else
		self.maxMoveSpeed = nil
	end

	self.duration = projTemplate.duration
	self.scale = self.overrideScale or self.projectileTemplate.useModelScale ~= false and self.owner.curModelScale or 1

	local radiusScale = self.scale

	self.sweepRadius = (projTemplate.sweepRadius or 0) * radiusScale
	self.acceleration = projTemplate.acceleration and projTemplate.acceleration or 0
	self.tickInterval = projTemplate.tickInterval and projTemplate.tickInterval or 0
	self.tickInterval = math.max(0.1, self.tickInterval)
	self.maxHitNum = math.min(ProjectileConst.MAX_PROJECTILE_HIT_COUNT_LIMIT, maxHitNum)
	self.keepRot = projTemplate.keepRot

	if self.projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING then
		self.angularConstraintElapsedTime = 0
		self.curReboundCnt = nil
		self.maxAngularOffset = trackingMaxAngular
		self.minAngularOffset = projTemplate.minAngularOffset or 0
		self.angularIncreaseDuration = projTemplate.angularIncreaseDuration or 0
		self.enableMaxAngleTime = projTemplate.enableMaxAngleTime or 0

		if projTemplate.reboundData then
			self.maxReboundCnt = projTemplate.reboundData.maxCount
			self.reboundRadius = projTemplate.reboundData.searchRadius
			self.reboundRelation = projTemplate.reboundData.reboundRelation
			self.isReboundSelf = projTemplate.reboundData.isReboundSelf

			local prioritizeLockTarget = projTemplate.reboundData.prioritizeLockTarget

			if self.initLockedActorId == nil and prioritizeLockTarget then
				local playerEntity = Utils.getMasterPlayer(self.owner)

				self.initLockedActorId = playerEntity and playerEntity.lockedActorId or self.targetActorId
			end
		end

		if ToBool(self.maxReboundCnt) then
			self.curReboundCnt = 0
		end

		self.startNoGravityTime = projTemplate.startNoGravityTime

		local gravity = SysConfigData.g

		self.gravityRatio = gravityRatio
		self.gravity = Vector3(0, -gravity * self.gravityRatio, 0)

		Vector3.enableCreateFromCache()

		local dir = self.rot:MulVec3(Vector3.forward)

		dir:SetNormalize()
		self.startDir:Copy(dir)
		self.velocity:Copy(dir * self.moveSpeed)
		Vector3.disableCreateFromCache()

		self.heightAboveGround = projTemplate.heightAboveGround
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_LINEAR then
		self.heightAboveGround = projTemplate.heightAboveGround

		Vector3.enableCreateFromCache()

		local dir = self.rot:MulVec3(Vector3.forward)

		dir:SetNormalize()
		self.startDir:Copy(dir)
		self.velocity:Copy(dir * self.moveSpeed)
		Vector3.disableCreateFromCache()
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_FREE3D then
		self.startNoGravityTime = projTemplate.startNoGravityTime

		local gravity = SysConfigData.g

		self.gravityRatio = gravityRatio
		self.gravity = Vector3(0, -gravity * self.gravityRatio, 0)

		Vector3.enableCreateFromCache()

		if self.targetPos then
			local moveDir = self.targetPos - self.pos

			moveDir:SetNormalize()
			self.velocity:Copy(moveDir * self.moveSpeed)
		else
			self.velocity:Copy(self.startDir * self.moveSpeed)
		end

		Vector3.disableCreateFromCache()

		self.heightAboveGround = projTemplate.heightAboveGround
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_PARABOLA then
		local gravity = SysConfigData.g

		self.gravityRatio = gravityRatio * gravity

		if self.moveSpeed > 0 then
			local len = Vector3.Distance(self.pos, self.targetPos)

			self.duration = len / self.moveSpeed
		end

		self.duration = math.max(0.001, self.duration)
		self.realDuration = self.duration
	elseif self.projectileType == ProjectileConst.PROJECTILE_TYPE_BEZIER then
		Vector3.enableCreateFromCache()

		local dir = self.rot:MulVec3(Vector3.forward)

		dir:SetNormalize()

		local refStartPoint = Vector3(unpack(projTemplate.refStartPoint))
		local refTargetPoint = Vector3(unpack(projTemplate.refTargetPoint))

		Vector3.disableCreateFromCache(refStartPoint, refTargetPoint)

		if not self.targetPos then
			local targetEntity = self:getTargetEntity()

			if targetEntity then
				self.targetPos = self:getHitPosition(targetEntity)
			else
				Vector3.enableCreateFromCache()

				local dir = self.rot:MulVec3(Vector3.forward)

				dir:SetNormalize()

				local targetPos = self.startPos + dir * 10

				Vector3.disableCreateFromCache(targetPos)

				self.targetPos = targetPos
			end
		end

		self.controlPos = CombatActionTool.calcRelativeControlPoint(refStartPoint, refTargetPoint, projTemplate.refControlPoint, self.startPos, self.targetPos)
		self.performRatio = projTemplate.performRatio or 1

		local moveDuration = self.duration

		if self.moveSpeed > 0 then
			local len = Vector3.Distance(self.pos, self.targetPos)

			moveDuration = len / self.moveSpeed
		end

		self.performDuration = math.max(0.001, moveDuration)
		self.realDuration = self.performDuration * self.performRatio

		if self.projectileTemplate.autoSwitchTrack then
			self.angularConstraintElapsedTime = 0
			self.angularIncreaseDuration = projTemplate.angularIncreaseDuration or 0
			self.enableMaxAngleTime = projTemplate.enableMaxAngleTime or 0
		else
			self.duration = self.realDuration
		end

		self.heightAboveGround = projTemplate.heightAboveGround
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@jqj not support projectileType", self.projectileType)
	end

	self.noGravity = self.gravityRatio == nil or self.startNoGravityTime == nil or self.gravityRatio == 0
	self.sweepRadius = math.max(0.1, self.sweepRadius or 0)

	local groundSweepRadius = projTemplate.groundSweepRadius

	if groundSweepRadius and groundSweepRadius * radiusScale < self.sweepRadius then
		self.groundSweepRadius = groundSweepRadius * radiusScale
	else
		self.groundSweepRadius = nil
	end

	self.effectTimeInitOffset = projTemplate.effectTimeInitOffset

	if pg.component == "game" then
		self.duration = self.duration + 1
	end

	if ToBool(self.circleData) then
		self.circleCenter = Vector3.Clone(self.circleData.centerPos)
		self.circleCenterUp = Vector3.Clone(self.circleData.centerUp)
		self.circleCenterLeft = Vector3.Clone(self.circleData.centerLeft)
		self.circleCenterForward = Vector3.Clone(self.circleData.centerForward)
		self.needMoveCenter = self.circleData.needMoveCenter
	end

	return true
end

function Projectile:getSrcEntity()
	return pg.getEntityByActorId(self.srcActorId)
end

function Projectile:getSrcAbility()
	local entity = self:getSrcEntity()

	if Utils.isCreation(entity) then
		entity = entity:getMasterEntity()
	end

	if not entity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj entity not found", self.srcActorId)
		end

		return nil
	end

	local ability = entity:getAbility(self.srcAbilityId, self.srcAbilityStoreType)

	return ability
end

function Projectile:checkCanHitTarget(hitActorId)
	return self.hitTargetSet[hitActorId] == nil
end

function Projectile:getTargetEntity()
	return pg.getEntityByActorId(self.targetActorId)
end

function Projectile:onHitTarget(combatHitResult, nextReboundActorId)
	if not self:checkCanHitTarget(combatHitResult.hitActorId) then
		return
	end

	local srcEntity = pg.getEntityByActorId(self.srcActorId)
	local targetEntity = pg.getEntityByActorId(combatHitResult.hitActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("targetEntity not exist", combatHitResult.hitActorId)
		end

		return
	end

	if not Utils.checkValidTarget(targetEntity, srcEntity) or not Utils.checkRelation(srcEntity, targetEntity, self.projectileTemplate.relation) then
		if self.isReboundSelf and nextReboundActorId then
			if self.onProjectileHitRPC then
				self:onProjectileHitRPC(srcEntity, combatHitResult, nextReboundActorId)
			end

			self.targetActorId = nextReboundActorId
		end

		return
	end

	if not Utils.checkRelation(srcEntity, targetEntity, self.projectileTemplate.relation) then
		return
	end

	if ToBool(nextReboundActorId) == false then
		self.curHitIdx = self.curHitIdx + 1
		self.hitTargetSet[combatHitResult.hitActorId] = combatHitResult.hitActorId
	end

	local srcAbility = self:getSrcAbility()

	self.lastHitActorId = combatHitResult.hitActorId
	self.lastHitActorPartIdx = combatHitResult.hitActorPartIdx

	if self.onProjectileHitRPC then
		self:onProjectileHitRPC(srcEntity, combatHitResult, nextReboundActorId)
	end

	if self.isReboundSelf or targetEntity ~= self.owner then
		self:onProjectileHit(srcAbility, combatHitResult, self.curHitIdx)
	end

	if self.projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING and ToBool(nextReboundActorId) then
		self.targetActorId = nextReboundActorId
	end
end

function Projectile:onProjectileHit(ability, combatHitResult, hitNum)
	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_HIT]

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("onProjectileHit", combatHitResult.hitActorId, inspect(triggerActions))
	end

	if not ToBool(triggerActions) then
		return false
	end

	local rawInfo = self.combatContext.runtimeTargetInfo
	local runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	self.combatContext.runtimeTargetInfo = runtimeTargetInfo

	self.combatContext.runtimeTargetInfo:initTarget(combatHitResult.hitActorId, combatHitResult.hitPos, hitNum, combatHitResult.hitActorPartIdx)

	self.combatContext.triggerType = AbilityConst.TRIGGER_ON_PROJECT_HIT

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)

	if self.extraHitActionIds then
		pg.global.abilityMgr.combatAction:doActionIds(self.extraHitActionIds, self.combatContext)
	end

	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(self.combatContext.runtimeTargetInfo)

	self.combatContext.runtimeTargetInfo = rawInfo
	self.combatContext.triggerType = nil

	return true
end

function Projectile:onProjectileFinish()
	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_FINISH]

	if not ToBool(triggerActions) then
		return false
	end

	local rawInfo = self.combatContext.runtimeTargetInfo
	local runtimeTargetInfo

	if self.lastHitActorId then
		runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, self.lastHitActorId)
		self.combatContext.runtimeTargetInfo = runtimeTargetInfo
		self.combatContext.runtimeTargetInfo.hitPos = Vector3.Clone(self.pos)
		self.combatContext.runtimeTargetInfo.hitActorPartIdx = self.lastHitActorPartIdx
	end

	if self.onProjectileFinishRPC then
		self:onProjectileFinishRPC()
	end

	self.combatContext.triggerType = AbilityConst.TRIGGER_ON_PROJECT_FINISH

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)

	if self.lastHitActorId then
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)

		self.combatContext.runtimeTargetInfo = rawInfo
	end

	self.combatContext.triggerType = nil
end

function Projectile:onHitFinish()
	self:onProjectileFinish()
end

function Projectile:onProjectileSegmentFinish()
	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_SEGMENT_FINISH]

	if not ToBool(triggerActions) then
		return false
	end

	local rawInfo = self.combatContext.runtimeTargetInfo
	local runtimeTargetInfo

	if self.lastHitActorId then
		runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, self.lastHitActorId)
		self.combatContext.runtimeTargetInfo = runtimeTargetInfo
		self.combatContext.runtimeTargetInfo.hitPos = Vector3.Clone(self.pos)
		self.combatContext.runtimeTargetInfo.hitActorPartIdx = self.lastHitActorPartIdx
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)

	if self.lastHitActorId then
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(runtimeTargetInfo)

		self.combatContext.runtimeTargetInfo = rawInfo
	end
end

function Projectile:onResetToProjectile()
	if self.onProjectileResetRPC then
		self:onProjectileResetRPC()
	end

	self:onProjectileSegmentFinish()

	if ToBool(self.projectileTemplate.nextTemplateId) then
		local casterEntity = pg.getEntityByActorId(self.srcActorId)

		if not casterEntity then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@hyj casterEntity not found", self.srcActorId)
			end

			return false
		end

		self.templateId = self.projectileTemplate.nextTemplateId

		local projTemplate = pg.global.abilityMgr:getProjectileTemplate(self.templateId)

		if not projTemplate then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@hyj projTempalte not found", self.templateId, self.templateIdList, self.curSegmentIndex)
			end

			return false
		end

		self.projectileType = ProjectileConst.PROJECTILE_TYPE_PARSER[projTemplate.kind]

		if not self.projectileType or self.projectileType == ProjectileConst.PROJECTILE_TYPE_NONE then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@hyj wrong projectileType", self.templateId, self.projectileType, projTemplate.kind)
			end

			return false
		end

		self.projectileTemplate = projTemplate

		self:applyTimeScale()

		self.combatContext.BPName = self.projectileTemplate.BPName
		self.combatContext.runtimeTargetInfo = nil

		self.combatContext:initNodeMap()

		self.isDestroyed = false
		self.isSleeping = false
		self.lastHitActorId = nil
		self.lastHitActorPartIdx = nil
		self.hitTargetSet = {}
		self.accumulateTime = 0
		self.curTime = 0
		self.sleepTime = 0
		self.needSleepTime = 0
		self.curHitIdx = 0

		self.startPos:Copy(self.pos)

		self.targetActorId, self.targetPos = CombatActionTool.getProjectileTargetInfo(self.combatContext, self.projectileTemplate.targetPos, projTemplate.kind, self.pos, self.rot)

		local rotationType = self.projectileTemplate.rotation and self.projectileTemplate.rotation or AbilityConst.COMBAT_ROTATION_TYPE_NONE
		local startRotationOffset = self.projectileTemplate.startRotationOffset and (self.projectileTemplate.startRotationOffset.name == nil and Vector3(unpack(self.projectileTemplate.startRotationOffset)) or pg.global.abilityMgr.combatAction:doAction(self.projectileTemplate.startRotationOffset, self.combatContext)) or Vector3(0, 0, 0)
		local rotation = self.rot:Clone()

		if rotationType == AbilityConst.COMBAT_ROTATION_TYPE_TO_TARGET then
			local position = self.pos:Clone()

			CombatActionTool.parseToTargetRotation(self.targetActorId, self.targetPos, position, rotation)
		end

		if self.projectileType == ProjectileConst.PROJECTILE_TYPE_TRACKING and self.projectileTemplate.trackingNoOffsetRotationRange then
			local sqrTrackingNoOffsetRotationRange = self.projectileTemplate.trackingNoOffsetRotationRange * self.projectileTemplate.trackingNoOffsetRotationRange
			local targetEntity = pg.getEntityByActorId(self.targetActorId)

			if self.targetPos then
				if sqrTrackingNoOffsetRotationRange > Vector3.SqrDistance(self.targetPos, self.pos) then
					startRotationOffset:Set(0, 0, 0)
				end
			elseif targetEntity and sqrTrackingNoOffsetRotationRange > Vector3.SqrDistance(targetEntity:getPosition(), self.pos) then
				startRotationOffset:Set(0, 0, 0)
			end
		end

		if startRotationOffset.x ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.x, Vector3.left))
		end

		if startRotationOffset.y ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.y, Vector3.up))
		end

		if startRotationOffset.z ~= 0 then
			rotation:Copy(rotation * Quaternion.AngleAxis(startRotationOffset.z, Vector3.forward))
		end

		self.rot = rotation:Clone()

		self:loadDataFromTemplate()
		self:DoStartSleep()
	else
		self:onProjectileFinish()
	end

	return true
end

function Projectile:onGrounded()
	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_GROUNDED]

	if not ToBool(triggerActions) then
		return false
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)
end

function Projectile:DoStartSleep()
	if ToBool(self.startSleepTime) then
		pg.global.abilityMgr.combatAction:setProjectileSleep({
			time = self.startSleepTime
		}, self.combatContext)
	elseif ToBool(self.projectileTemplate.startSleepTime) and type(self.projectileTemplate.startSleepTime) == "number" and self.projectileTemplate.startSleepTime > 0 then
		pg.global.abilityMgr.combatAction:setProjectileSleep({
			time = self.projectileTemplate.startSleepTime
		}, self.combatContext)
	end
end

function Projectile:onTick()
	local triggerActions = self.projectileTemplate[AbilityConst.TRIGGER_ON_PROJECT_TICK]

	if not ToBool(triggerActions) then
		return
	end

	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)
end

return Projectile
