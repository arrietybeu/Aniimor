-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\Utils\\LockHelper.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local SysConfigData = require("Data.sys_config_data")
local SceneData = require("Data.scene_data")
local lume = require("Core.Common.lume")
local AIUtils = require("Common.Utils.AIUtils")
local NoticeDef = require("Common.NoticeDef")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local LockHelper = Class.LiteClass("LockHelper")
local sqrt = math.sqrt
local Vector3 = Vector3
local pg = pg
local ToBool = ToBool
local viewPortWidth = 0.6
local viewPortHeight = 0.8
local playerDistPriorityOffset = -1000
local petDistPriorityOffset = -2000
local stableGroundLayer = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
local MAX_SEARCH_CNT = 30

local function _sortScrollLeft(a, b)
	local _, _, isRightA, angleA = unpack(a)
	local _, _, isRightB, angleB = unpack(b)

	if isRightA == isRightB then
		if isRightA then
			return angleB < angleA
		else
			return angleA < angleB
		end
	end

	return not isRightA
end

local function _sortScrollRight(a, b)
	local _, _, isRightA, angleA = unpack(a)
	local _, _, isRightB, angleB = unpack(b)

	if isRightA == isRightB then
		if isRightA then
			return angleA < angleB
		else
			return angleB < angleA
		end
	end

	return isRightA
end

function LockHelper:ctor()
	self.logger = LoggerManager.getLogger("LockHelper")
	self.nextAutoLockTargetId = 0
	self.forceLockActorId = 0
	self.forceLockPartId = 0
	self.lastAutoLockTime = 0
	self.isUseLockOnExtendCamera = true

	local defaultMode = tonumber(ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.UseExtendLockCamera)) or 0

	self.isUseLockOnExtendCamera = pg.game.setting:getBool(ClientConst.PrefKey.UseExtendLockCamera, defaultMode ~= 0)
	self.isUseLockOnCamera = pg.game.setting:getBool(ClientConst.PrefKey.IsForceLockTarget, defaultMode == 1)

	local isEnableManualClickForceLockEnemyDefVal = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.IsEnableManualClickForceLockEnemy)

	self.isEnableManualClickForceLockEnemy = pg.game.setting:getBool(ClientConst.PrefKey.IsEnableManualClickForceLockEnemy, ToBool(isEnableManualClickForceLockEnemyDefVal))
	self.isUseTabSwitchTarget = false
	self.isUseHoldCancelLock = false
	self.lockRecord = {}
	self.scrollGroup = 1
	self.scrollVisited = {}
	self.lastScrollTime = 0
	self.isUseLockCD = false
	self.lastLockByDisTime = 0
	self.scrollChangeTargetCd = SysConfigData.scrollChangeTargetCd or 0.5
	self.lockDis = AbilitySettingGlobalConstData.forceLockDis

	self:onInputDeviceChange()

	self.forceLockMasterActorId = nil
	self.flashlightLockSet = {}
	self.actorList = LuaCSharpArr.New(MAX_SEARCH_CNT)
	self.envList = LuaCSharpArr.New(MAX_SEARCH_CNT)
end

function LockHelper:onInputDeviceChange()
	if pg.game.input:isUsingGamepad() then
		self.mode = ClientConst.LockMode.ModeB
		self.isUseLockOnExtendCamera = true
	elseif pg.global.ui:runPlatformByMobile() then
		self.mode = pg.game.setting:getInt(ClientConst.PrefKey.KeyboardLockMode, ClientConst.LockMode.ModeB)

		local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.UseExtendLockCamera)

		self.isUseLockOnExtendCamera = pg.game.setting:getBool(ClientConst.PrefKey.UseExtendLockCamera, ToBool(defaultValue))
	else
		self.mode = pg.game.setting:getInt(ClientConst.PrefKey.KeyboardLockMode, ClientConst.LockMode.ModeB)

		local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.UseExtendLockCamera)

		self.isUseLockOnExtendCamera = pg.game.setting:getBool(ClientConst.PrefKey.UseExtendLockCamera, ToBool(defaultValue))
	end

	if self.mode == ClientConst.LockMode.ModeA then
		self.isUseTabSwitchTarget = false
		self.isUseHoldCancelLock = false
		self.isUseLockCD = false
	elseif self.mode == ClientConst.LockMode.ModeB then
		self.isUseTabSwitchTarget = true
		self.isUseHoldCancelLock = true
		self.isUseLockCD = true
		self.lockRecord = {}
		self.lastLockByDisTime = 0
	end

	facade:sendMsgToUI(MessageName.REFRESH_OPERATION_HINT)
end

function LockHelper:getLockPos(actorId)
	local lockEnt = pg.getEntityByActorId(actorId)

	return lockEnt and lockEnt:getLockPosition()
end

function LockHelper:getWeightDis(dir, center, pos, alpha)
	local dis = pos - center

	alpha = alpha or 1

	local len = Vector3.Magnitude(dis)

	dis.y = 0

	Vector3.SetNormalize(dis)

	local cos = Vector3.Dot(dir, dis)
	local factor = (-cos + 1) / 2 * (1 - alpha) + alpha

	return factor * len
end

function LockHelper:getGoAutoLockEnt(fromEnt, lockDis)
	local pawn = fromEnt or pg.pawn

	if not pawn then
		return nil, 0
	end

	local autoLockDis = lockDis or AbilitySettingGlobalConstData.forceLockDis
	local lockEnt = pg.getEntityByActorId(pg.me.lockedActorId)
	local actorCount = 0
	local envCount = 0

	if lockEnt then
		if Utils.isPuppet(lockEnt) then
			return pg.me.lockedActorId, 0, 0
		elseif Utils.isEnvObj(lockEnt) then
			actorCount = 0
			envCount = 1
			self.envList[1] = pg.me.lockedActorId
		else
			return pg.me.lockedActorId, pg.me.lockedPartId, 0
		end
	else
		actorCount, envCount = self:getLockableTargetList(pg.pawn, autoLockDis, false)
	end

	local targetActorId = 0
	local targetPartId = 0

	if actorCount > 0 then
		local targetEnt, partId = self:getNoBlockTarget(self.actorList, actorCount, true, autoLockDis)

		targetActorId = targetEnt and targetEnt.actorId
		targetPartId = partId

		if ToBool(targetActorId) then
			return targetActorId, targetPartId, 0
		end
	end

	local findEnvActorId = 0

	if envCount > 0 then
		for i = 1, envCount do
			local envActorId = self.envList[i]
			local ent = pg.getEntityByActorId(envActorId)

			if ent and ent.isLockAsPuppet and Utils.checkValidLock(ent) then
				findEnvActorId = envActorId

				break
			end
		end
	end

	if findEnvActorId > 0 then
		targetActorId = findEnvActorId

		return targetActorId, targetPartId, AIUtils.getEnvObjInteractAbility(pawn, pg.getEntityByActorId(targetActorId))
	else
		targetActorId = 0
		targetPartId = 0

		local interactAbilityId = 0

		if pawn.forceUpdateNoImpSensor then
			pawn:forceUpdateNoImpSensor()
		end

		targetActorId, targetPartId, interactAbilityId = AIUtils.searchInteractEnvObj(pawn.actorId)

		if LoggerManager.checkLogger(LoggerConst.DEBUG, "AI") then
			self.logger:debug("lockEnvObj:", targetActorId, targetPartId, interactAbilityId)
		end

		if targetActorId == 0 then
			return pg.me.lockedActorId, pg.me.lockedPartId, 0
		end

		return targetActorId, targetPartId, interactAbilityId
	end
end

local _existingSet = {}
local bossList = {}
local eliteList = {}
local otherList = {}

function LockHelper:getLockableTargetList(fromEnt, autoLockDis, isForceLock)
	local petOffsetDis = 0
	local playerOffsetDis = 0

	if pg.me.space and Utils.isRobEggSceneId(pg.me.space.sceneId) then
		petOffsetDis = petDistPriorityOffset
		playerOffsetDis = playerDistPriorityOffset
	end

	local actorCount = fromEnt:entitiesInRangeWithTable(autoLockDis, Const.SEARCH_USR_TYPE_LOCKABLE, 25, self.actorList, true) or 0

	if next(self.flashlightLockSet) then
		for k in pairs(_existingSet) do
			_existingSet[k] = nil
		end

		for i = 1, actorCount do
			_existingSet[self.actorList[i]] = true
		end

		for aid in pairs(self.flashlightLockSet) do
			if not _existingSet[aid] then
				local e = pg.getEntityByActorId(aid)

				if not e or not e.space then
					self.flashlightLockSet[aid] = nil
				elseif actorCount < MAX_SEARCH_CNT then
					actorCount = actorCount + 1
					self.actorList[actorCount] = aid
				end
			end
		end
	end

	local envCount = 0

	if actorCount > 0 then
		actorCount, envCount = pg.global.csAbilityMgr:BuildLockableTargetEntries(fromEnt.eModel, self.actorList:GetCSharpAccess(), actorCount, petOffsetDis, playerOffsetDis, self.envList:GetCSharpAccess(), fromEnt:isInCombat())

		if isForceLock then
			lume.clear(bossList)
			lume.clear(eliteList)
			lume.clear(otherList)

			for i = 1, actorCount do
				local actorId = self.actorList[i]
				local ent = pg.getEntityByActorId(self.actorList[i])
				local labl = ent.label
				local isBoss = Utils.isLabelBoss(labl)

				if isBoss then
					table.insert(bossList, actorId)
				elseif Utils.isLabelElite(labl) then
					table.insert(eliteList, actorId)
				else
					table.insert(otherList, actorId)
				end
			end

			local tableIndex = 1

			for _, bossActorId in ipairs(bossList) do
				self.actorList[tableIndex] = bossActorId
				tableIndex = tableIndex + 1
			end

			for _, eliteActorId in ipairs(eliteList) do
				self.actorList[tableIndex] = eliteActorId
				tableIndex = tableIndex + 1
			end

			for _, otherActorId in ipairs(otherList) do
				self.actorList[tableIndex] = otherActorId
				tableIndex = tableIndex + 1
			end
		end

		return actorCount, envCount
	end

	return 0, 0
end

function LockHelper:isTargetNoBlock(startPos, targetEntity)
	Vector3.enableCreateFromCache()

	if self:checkBlockedBySmoke(targetEntity) then
		Vector3.disableCreateFromCache()

		return false
	end

	local targetPos = self:getLockPos(targetEntity.actorId)
	local offset = targetPos - startPos
	local len = Vector3.Magnitude(offset)
	local raycastResult = pg.global.physicsMgr:LockRaycast(startPos, Vector3.Normalize(offset), len, stableGroundLayer, targetEntity.eModel)

	Vector3.disableCreateFromCache()

	return not raycastResult
end

function LockHelper:getNoBlockTarget(targetList, count, checkTargetValid, lockDis)
	Vector3.enableCreateFromCache()

	local playerPos = self:getLockPos(pg.me.actorId, 0)

	if not playerPos then
		Vector3.disableCreateFromCache()

		return nil, 0
	end

	for i = 1, count do
		local targetActorId = targetList[i]
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if Utils.isEnvObj(targetEntity) and not targetEntity.isLockAsPuppet then
			-- block empty
		elseif (not checkTargetValid or self:checkTargetValid(targetEntity, lockDis, nil, false)) and self:isTargetNoBlock(playerPos, targetEntity) then
			Vector3.disableCreateFromCache()

			return targetEntity, 0
		end
	end

	Vector3.disableCreateFromCache()

	return nil, 0
end

function LockHelper:getAutoLockEnt(fromEnt, lockDis, isForceLock)
	local autoLockDis = lockDis or AbilitySettingGlobalConstData.forceLockDis

	if pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 then
		autoLockDis = pg.me.fogMaskRadius
	end

	local actorCount, envCount = self:getLockableTargetList(fromEnt, autoLockDis, isForceLock)
	local targetEnt, partId = self:getNoBlockTarget(self.actorList, actorCount, true, autoLockDis)

	if targetEnt ~= nil then
		return targetEnt, partId
	else
		targetEnt, partId = self:getNoBlockTarget(self.envList, envCount, true, autoLockDis)

		return targetEnt, partId
	end

	return nil, 0
end

function LockHelper.getVirtualLockDistance(entActorId, rawDist)
	local ent = pg.getEntityByActorId(entActorId)

	if not ent then
		return rawDist
	end

	if Utils.isPlayer(ent) then
		return rawDist + playerDistPriorityOffset
	elseif Utils.isPet(ent) then
		return rawDist + petDistPriorityOffset
	end

	return rawDist
end

function LockHelper:tryLockTarget(targetId, partId, lockDis, notifyEntity, ignoreViewport, isForceLock)
	if notifyEntity == nil then
		notifyEntity = true
	end

	local pawn = pg.pawn

	if not pawn then
		return 0, 0
	end

	if pawn:attaching() then
		return 0, 0
	end

	if pg.space and pg.space.npcDuelDungeonIsEnding and pg.space:npcDuelDungeonIsEnding() then
		return 0, 0
	end

	if pg.space and pg.space.npcDuelLockForbidden and pg.space:npcDuelLockForbidden() then
		return 0, 0
	end

	if not ToBool(targetId) and self.forceLockActorId ~= 0 then
		targetId = self.forceLockActorId
		partId = self.forceLockPartId
	end

	if lockDis == nil and targetId == self.forceLockActorId and partId == self.forceLockPartId then
		lockDis = self.lockDis
	end

	lockDis = lockDis or AbilitySettingGlobalConstData.forceLockDis

	local rawLockDis = lockDis

	if pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 then
		lockDis = pg.me.fogMaskRadius
	end

	local targetEnt = pg.getEntityByActorId(targetId)

	if not targetEnt or not self:checkTargetValid(targetEnt, lockDis, ignoreViewport) then
		targetId = 0
		partId = 0
		self.lockDis = nil
	end

	if not ToBool(targetId) then
		local closestEnt, closestPartId = self:getAutoLockEnt(pawn, lockDis, isForceLock)

		targetId = closestEnt and closestEnt.actorId or 0
		partId = closestPartId or 0

		if Utils.isEnvObj(closestEnt) or Utils.isVirtualTarget(closestEnt) then
			self.lockDis = 3
		end

		self.lastAutoLockTime = Time.realSecondCache

		if not ToBool(targetId) then
			targetId = 0
			partId = 0
		end
	end

	if notifyEntity then
		pg.me:lockTarget(targetId, partId, targetId == self.forceLockActorId)
	end

	self.lockDis = rawLockDis

	return targetId, partId
end

function LockHelper:tryForceLockTarget(targetId, partId, lockDist, isTemp, ignoreViewport)
	if not self:canForceLock() then
		return
	end

	if not pg.me.enableLockTarget then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("tryForceLockTarget forbid.", pg.me.enableLockTarget)
		end

		return
	end

	if isTemp and ToBool(self.forceLockActorId) then
		self.lastForceLockActorId = self.forceLockActorId
	else
		self.lastForceLockActorId = 0
	end

	if not ToBool(targetId) then
		targetId = pg.me.lockedActorId
		partId = pg.me.lockedPartId
	end

	local sceneLockDis = SceneData[pg.me.space.sceneId].forceLockDis

	lockDist = lockDist or sceneLockDis or AbilitySettingGlobalConstData.forceLockDis

	if pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 then
		lockDist = pg.me.fogMaskRadius
	end

	local forceTargetId, forceTargetPartId = self:tryLockTarget(targetId, partId, lockDist, false, ignoreViewport, true)

	if not ToBool(forceTargetId) then
		return false
	end

	local lockEnt = pg.getEntityByActorId(forceTargetId)

	if Utils.isEnvObj(lockEnt) then
		return false
	end

	self.forceLockMasterActorId = Utils.isPet(lockEnt) and lockEnt:getMasterEntity():isControllingPet() and lockEnt:getMasterEntity().actorId or nil
	self.forceLockActorId = forceTargetId or 0
	self.forceLockPartId = forceTargetPartId or 0

	pg.me:lockTarget(forceTargetId, forceTargetPartId, true)

	if forceTargetId ~= 0 then
		local forceLockEnt = pg.getEntityByActorId(forceTargetId)

		self:forceLockEnt(forceLockEnt, forceTargetPartId)

		self.lastLockByDisTime = Time.realSecondCache
		self.lockDis = math.max(self.lockDis or 0, AbilitySettingGlobalConstData.leaveForceLockDis)
	end
end

function LockHelper:addLockRecord(targetId, partId)
	partId = partId or 0

	if not self.lockRecord[targetId] then
		self.lockRecord[targetId] = {}
	end

	self.lockRecord[targetId][partId] = true
end

function LockHelper:checkContainsRecord(targetId, partId)
	partId = partId or 0

	if not self.lockRecord[targetId] then
		return false
	end

	return self.lockRecord[targetId][partId]
end

function LockHelper:findClosestTarget()
	local pawn = pg.pawn
	local pawnPosition = pawn:getPosition()
	local closestEnt
	local closestDis = math.maxFloat
	local closestPartId = 0
	local startPos = self:getLockPos(pawn.actorId, 0)
	local isInRobEgg = pawn.space and Utils.isRobEggSceneId(pawn.space.sceneId) or false

	for _, actorId in ipairs(pawn:entitiesInRange(AbilitySettingGlobalConstData.forceLockDis, Const.SEARCH_USR_TYPE_LOCKABLE)) do
		local ent = pg.getEntityByActorId(actorId)

		if actorId ~= self.forceLockActorId and self:checkTargetValid(ent, nil, nil, false) then
			local dis = Vector3.Distance(ent:getPosition(), pawnPosition)

			if isInRobEgg then
				dis = LockHelper.getVirtualLockDistance(ent.actorId, dis)
			end

			if dis < closestDis and self:isTargetNoBlock(startPos, ent, 0) then
				closestEnt = ent
				closestPartId = 0
				closestDis = dis
			end
		end
	end

	return closestEnt, closestPartId
end

function LockHelper:findClosestTargetByGroup()
	local pawn = pg.pawn
	local pawnPosition = pawn:getPosition()
	local bestEnt
	local bestPartId = 0
	local bestGroup = 4
	local bestDis = math.maxFloat
	local startPos = self:getLockPos(pawn.actorId, 0)
	local isInRobEgg = pawn.space and Utils.isRobEggSceneId(pawn.space.sceneId) or false

	for _, actorId in ipairs(pawn:entitiesInRange(AbilitySettingGlobalConstData.forceLockDis, Const.SEARCH_USR_TYPE_LOCKABLE)) do
		local ent = pg.getEntityByActorId(actorId)
		local group = LockHelper._getScrollGroupForEnt(ent)

		if group <= bestGroup and actorId ~= self.forceLockActorId and self:checkTargetValid(ent, nil, nil, false) then
			local dis = Vector3.Distance(ent:getPosition(), pawnPosition)

			if isInRobEgg then
				dis = LockHelper.getVirtualLockDistance(ent.actorId, dis)
			end

			if (group < bestGroup or dis < bestDis) and self:isTargetNoBlock(startPos, ent, 0) then
				bestEnt = ent
				bestPartId = 0
				bestGroup = group
				bestDis = dis
			end
		end
	end

	return bestEnt, bestPartId, bestGroup
end

function LockHelper:tryLockNextTarget()
	local pawn = pg.pawn
	local lockEnt = pg.getEntityByActorId(self.forceLockActorId)

	if not ToBool(self.lockRecord) or not ToBool(self.forceLockActorId) or not lockEnt or not self:checkTargetValid(lockEnt) or Time.realSecondCache - self.lastLockByDisTime > (AbilitySettingGlobalConstData.lockByDisDuration or 2) then
		self.lockRecord = {}
		self.scrollVisited = {}

		local closestEnt, closestPartId, closestGroup = self:findClosestTargetByGroup()

		if closestEnt then
			self.scrollGroup = closestGroup
			self.scrollVisited[closestEnt.actorId] = true

			self:tryForceLockTarget(closestEnt.actorId, closestPartId)
			self:addLockRecord(closestEnt.actorId, closestPartId)
		end

		return
	end

	local selfPos = pawn:getPosition()
	local lockDir = lockEnt:getLockPartPosition(self.forceLockPartId) - selfPos

	lockDir.y = 0

	Vector3.SetNormalize(lockDir)

	local bossGroup, eliteGroup, otherGroup = {}, {}, {}

	for _, actorId in ipairs(pawn:entitiesInRange(AbilitySettingGlobalConstData.forceLockDis, Const.SEARCH_USR_TYPE_LOCKABLE)) do
		if actorId ~= self.forceLockActorId then
			local ent = pg.getEntityByActorId(actorId)
			local group = LockHelper._getScrollGroupForEnt(ent)

			if self:checkTargetValid(ent, nil, nil, false) then
				local selfToEntDir = ent:getPosition() - selfPos

				selfToEntDir.y = 0

				Vector3.SetNormalize(selfToEntDir)

				local isRight = Vector3.Cross(lockDir, selfToEntDir).y > 0
				local angle = Vector3.Angle(lockDir, selfToEntDir)
				local entry = {
					ent.actorId,
					0,
					isRight,
					angle
				}

				if group == 1 then
					bossGroup[#bossGroup + 1] = entry
				elseif group == 2 then
					eliteGroup[#eliteGroup + 1] = entry
				else
					otherGroup[#otherGroup + 1] = entry
				end
			end
		end
	end

	table.sort(bossGroup, _sortScrollLeft)
	table.sort(eliteGroup, _sortScrollLeft)
	table.sort(otherGroup, _sortScrollLeft)
	Vector3.enableCreateFromCache()

	local playerPos = self:getLockPos(pg.me.actorId, 0)

	if not playerPos then
		Vector3.disableCreateFromCache()

		return
	end

	local wrapped = false

	for _ = 1, 6 do
		local groupList = self.scrollGroup == 1 and bossGroup or self.scrollGroup == 2 and eliteGroup or otherGroup

		for _, target in ipairs(groupList) do
			local actorId, partId = target[1], target[2]

			if not self.scrollVisited[actorId] then
				local targetEnt = pg.getEntityByActorId(actorId)

				if self:isTargetNoBlock(playerPos, targetEnt, partId) then
					self.scrollVisited[actorId] = true

					Vector3.disableCreateFromCache()
					self:tryForceLockTarget(targetEnt.actorId, partId)
					self:addLockRecord(targetEnt.actorId, partId)

					return
				end
			end
		end

		self.scrollGroup = self.scrollGroup % 3 + 1

		if self.scrollGroup == 1 then
			if wrapped then
				break
			end

			wrapped = true
			self.scrollVisited = {}
		end
	end

	Vector3.disableCreateFromCache()
end

function LockHelper:forceLockEnt(ent, partId)
	partId = partId or 0

	self:addLockRecord(ent.actorId, partId)
	pg.game.audio:triggerEvent("SFX_UI_Battle_Lock")

	if self.isUseLockOnExtendCamera then
		pg.game.camera.playerCameraMode:setLockOnCameraTarget(ent, partId)
	end
end

function LockHelper:cancelLockTarget()
	self:cancelForceLockTarget()

	self.lockDis = nil

	pg.me:unlockTarget()
end

function LockHelper:cancelForceLockTarget()
	if self.forceLockActorId ~= 0 then
		if ToBool(self.lastForceLockActorId) then
			local actorId = self.lastForceLockActorId

			self.lastForceLockActorId = 0

			self:tryForceLockTarget(actorId, 0)

			return
		end

		self.forceLockActorId = 0
		self.forceLockPartId = 0
		self.lockRecord = {}
		self.scrollGroup = 1
		self.scrollVisited = {}

		pg.game.camera.playerCameraMode:setLockOnCameraTarget(nil)

		self.lockDis = nil
	end
end

function LockHelper:checkTargetValid(targetEnt, lockDis, ignoreViewport, checkSmoke)
	if targetEnt == nil or not targetEnt.space then
		return false
	end

	if not Utils.checkValidLock(targetEnt) then
		return false
	end

	local pawn = pg.pawn
	local me = pg.me
	local maxDis = lockDis or AbilitySettingGlobalConstData.forceLockDis

	if self:isFlashlightLockTarget(targetEnt.actorId) then
		maxDis = AbilitySettingGlobalConstData.forceLockDis
	elseif pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 then
		maxDis = pg.me.fogMaskRadius
	end

	if not Utils.isEnemy(pawn, targetEnt) then
		return false
	end

	if Utils.isEnvObj(targetEnt) or Utils.isVirtualTarget(targetEnt) then
		maxDis = 3
	end

	local playerPos, targetPos

	if not ToBool(me.ignoreLockDistanceCheck) then
		if targetEnt.isPartEnt and targetEnt:isPartEnt() then
			maxDis = maxDis + 3
			targetPos = targetEnt:getPosition()
			playerPos = pawn:getPosition()

			if targetEnt.actorId == pg.me.lockedActorId then
				maxDis = maxDis + 5
			end

			if maxDis < Vector3.HoriDistance(targetPos, playerPos) or maxDis < math.abs(targetPos.y - playerPos.y) then
				return false
			end
		else
			local targetPos = targetEnt:getPosition()
			local playerPos = pawn:getPosition()

			if targetEnt.actorId == pg.me.lockedActorId then
				maxDis = maxDis + 1
			end

			if maxDis < Vector3.HoriDistance(targetPos, playerPos) or maxDis < math.abs(targetPos.y - playerPos.y) then
				return false
			end

			if not ignoreViewport then
				local x, y, z = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])
				local inScreen = x > 0 and x < 1 and y > 0 and y < 1 and z > 0

				if self.forceLockActorId ~= targetEnt.actorId and not inScreen and targetEnt.hatredMap and (targetEnt.hatredMap[pg.me.actorId] == nil or targetEnt.hatredMap[pg.me.actorId].hatredValue <= 0) then
					return false
				end
			end
		end
	end

	if checkSmoke ~= false and self:checkBlockedBySmoke(targetEnt) then
		return false
	end

	return true
end

function LockHelper._checkSmoke(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	return ToBool(ent.isSmoke)
end

function LockHelper:checkBlockedBySmoke(targetEnt)
	if pg.me.smokeEntityCnt <= 0 then
		return false
	end

	return not pg.world.checkNoBlockedBySmoke(pg.pawn.aoi, pg.pawn:getPosition(), targetEnt:getPosition(), LockHelper._checkSmoke)
end

function LockHelper:calcTargetPriority(ent, viewport, targetDist, currViewPort)
	local entScore = 1
	local targetPosScore = 1
	local viewPortScore = 1

	if currViewPort == nil or not self:checkViewportValid(currViewPort) then
		local xOffset = viewport.x * 2 - 1
		local yOffset = viewport.y * 2 - 1

		viewPortScore = 1 / (sqrt(xOffset * xOffset + yOffset * yOffset) + 1)
		targetPosScore = 1 - targetDist / AbilitySettingGlobalConstData.forceLockDis
	else
		viewPortScore = viewport.x - currViewPort.x

		if viewPortScore > 0 then
			viewPortScore = 2 - viewPortScore
		else
			viewPortScore = -viewPortScore
		end
	end

	return (viewPortScore * 0.7 + 0.3 * targetPosScore) * entScore
end

function LockHelper:checkViewportValid(viewport)
	local minX = 0.5 * (1 - viewPortWidth)
	local maxX = 0.5 * (1 + viewPortWidth)
	local minY = 0.5 * (1 - viewPortHeight)
	local maxY = 0.5 * (1 + viewPortHeight)

	return minX < viewport.x and maxX > viewport.x and minY < viewport.y and maxY > viewport.y and viewport.z > 0
end

function LockHelper:update()
	if not pg.pawn or not pg.pawn.aoi or not pg.me then
		return
	end

	if ToBool(self.forceLockActorId) and self.forceLockMasterActorId then
		local masterEntity = pg.getEntityByActorId(self.forceLockMasterActorId)

		if masterEntity and masterEntity:isControllingPet() then
			local lockEnt = pg.getEntityByActorId(self.forceLockActorId)

			if lockEnt == nil or not lockEnt.isSummon then
				local petEntity = masterEntity:getCurPetEntity()

				if petEntity and self:checkTargetValid(petEntity, self.lockDis) then
					self:tryForceLockTarget(petEntity.actorId, self.forceLockPartId, self.lockDis)
				end

				return
			end
		end
	end

	self:checkLockTargetValid(ToBool(self.forceLockActorId) and self.lockDis)

	local now = Time.realSecondCache

	if self.lastTickTime and now - self.lastTickTime < 0.5 then
		return
	end

	self.lastTickTime = now

	self:tryLockTarget(nil, nil, self.lockDis)
end

function LockHelper:checkLockTargetValid(lockDis)
	local me = pg.me

	if not me then
		return
	end

	local currTargetId = me.lockedActorId
	local currTargetPartId = me.lockedPartId

	if ToBool(self.forceLockActorId) then
		currTargetId = self.forceLockActorId
		currTargetPartId = self.forceLockPartId
	end

	if ToBool(currTargetId) then
		local target = pg.getEntityByActorId(currTargetId)

		if not self:checkTargetValid(target, lockDis) then
			pg.game.controller:unlockTarget()
		end
	end
end

function LockHelper._getScrollGroupForEnt(ent)
	if Utils.isLabelBoss(ent.label) then
		return 1
	elseif Utils.isLabelElite(ent.label) then
		return 2
	else
		return 3
	end
end

function LockHelper:tryLockNextTargetByDir(dirX)
	if not ToBool(self.forceLockActorId) then
		return
	end

	local pawn = pg.pawn
	local lockEnt = pg.getEntityByActorId(self.forceLockActorId)
	local selfPos = pawn:getPosition()
	local lockDir = lockEnt:getLockPartPosition(self.forceLockPartId) - selfPos

	lockDir.y = 0

	Vector3.SetNormalize(lockDir)

	local bossGroup, eliteGroup, otherGroup = {}, {}, {}

	for _, actorId in ipairs(pawn:entitiesInRange(AbilitySettingGlobalConstData.forceLockDis, Const.SEARCH_USR_TYPE_LOCKABLE)) do
		local ent = pg.getEntityByActorId(actorId)
		local group = LockHelper._getScrollGroupForEnt(ent)

		if actorId ~= self.forceLockActorId and self:checkTargetValid(ent, nil, nil, false) then
			local selfToEntDir = ent:getPosition() - selfPos

			selfToEntDir.y = 0

			Vector3.SetNormalize(selfToEntDir)

			local isRight = Vector3.Cross(lockDir, selfToEntDir).y > 0
			local angle = Vector3.Angle(lockDir, selfToEntDir)
			local entry = {
				ent.actorId,
				0,
				isRight,
				angle
			}

			if group == 1 then
				bossGroup[#bossGroup + 1] = entry
			elseif group == 2 then
				eliteGroup[#eliteGroup + 1] = entry
			else
				otherGroup[#otherGroup + 1] = entry
			end
		end
	end

	local sortFunc = dirX < 0 and _sortScrollLeft or _sortScrollRight

	table.sort(bossGroup, sortFunc)
	table.sort(eliteGroup, sortFunc)
	table.sort(otherGroup, sortFunc)
	Vector3.enableCreateFromCache()

	local playerPos = self:getLockPos(pg.me.actorId, 0)

	if not playerPos then
		Vector3.disableCreateFromCache()

		return nil, 0
	end

	local wrapped = false

	for _ = 1, 6 do
		local groupList = self.scrollGroup == 1 and bossGroup or self.scrollGroup == 2 and eliteGroup or otherGroup

		for _, target in ipairs(groupList) do
			local actorId, partId = target[1], target[2]

			if not self.scrollVisited[actorId] then
				local targetEnt = pg.getEntityByActorId(actorId)

				if self:isTargetNoBlock(playerPos, targetEnt, partId) then
					self.scrollVisited[actorId] = true

					Vector3.disableCreateFromCache()

					return targetEnt, partId
				end
			end
		end

		self.scrollGroup = self.scrollGroup % 3 + 1

		if self.scrollGroup == 1 then
			if wrapped then
				break
			end

			wrapped = true
			self.scrollVisited = {}
		end
	end

	Vector3.disableCreateFromCache()

	return nil, 0
end

function LockHelper:onMouseScroll(delta)
	if not ToBool(self.forceLockActorId) or self.isUseTabSwitchTarget then
		return false
	end

	if Time.realSecondCache - self.lastScrollTime < self.scrollChangeTargetCd then
		return true
	end

	self.lastScrollTime = Time.realSecondCache

	local ent, partId

	if delta > 0 then
		ent, partId = self:tryLockNextTargetByDir(-1)
	else
		ent, partId = self:tryLockNextTargetByDir(1)
	end

	if ent then
		self:tryForceLockTarget(ent.actorId, partId)
	end

	self.lastFrameCnt = Time.unityFrameCount

	return true
end

function LockHelper:setIsUseLockOnExtendCamera(value)
	value = ToBool(value)
	self.isUseLockOnExtendCamera = value

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode

	if not value and playerCameraMode then
		playerCameraMode:setLockOnCameraTarget(nil)
	end

	pg.game.setting:setBool(ClientConst.PrefKey.UseExtendLockCamera, value)
end

function LockHelper:setIsUseLockOnCamera(value)
	value = ToBool(value)
	self.isUseLockOnCamera = value

	pg.game.setting:setBool(ClientConst.PrefKey.IsForceLockTarget, value)

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode

	if playerCameraMode and playerCameraMode.lockOnExtendCamera then
		playerCameraMode.lockOnExtendCamera.cameraMode.isForceLockTarget = value
	end
end

function LockHelper:setIsEnableManualClickForceLockEnemy(value)
	value = ToBool(value)
	self.isEnableManualClickForceLockEnemy = value

	pg.game.setting:setBool(ClientConst.PrefKey.IsEnableManualClickForceLockEnemy, value)
end

function LockHelper:resetLockDis()
	pg.me.ignoreLockDistanceCheck = false

	local lockEnt = pg.getEntityByActorId(pg.me.lockedActorId)

	if lockEnt then
		self.lockDis = AbilitySettingGlobalConstData.leaveForceLockDis
	elseif ToBool(self.forceLockActorId) then
		lockEnt = pg.getEntityByActorId(self.forceLockActorId)

		if lockEnt then
			self.lockDis = AbilitySettingGlobalConstData.leaveForceLockDis
		end
	end
end

function LockHelper:canForceLock()
	local aniCameraMode = pg.game.camera.animCameraMode

	if aniCameraMode.refEntity == pg.me and (aniCameraMode:isTop() or aniCameraMode:isBlending()) then
		return false
	end

	return true
end

function LockHelper:tryManualForceLockTarget(dist, targetId, partId, lockDist, isTemp, ignoreViewport)
	if not self:canForceLock() then
		return
	end

	if not self.isEnableManualClickForceLockEnemy then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("tryManualForceLockTarget return cause not enableManualClickForceLockEnemy.", pg.me.enableLockTarget)
		end

		return
	end

	local mePos = pg.me and pg.me:getPosition() or Vector3.zero
	local ent = pg.getEntityByActorId(targetId)
	local entPos = ent and ent:getPosition() or Vector3.zero
	local sqrDis = Vector3.SqrDistance(mePos, entPos)
	local isNotCanLock = sqrDis > AbilitySettingGlobalConstData.forceLockDis * AbilitySettingGlobalConstData.forceLockDis

	if isNotCanLock then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("tryManualForceLockTarget return cause dist=%s > AbilitySettingGlobalConstData.forceLockDis=%s", dist, AbilitySettingGlobalConstData.forceLockDis)
		end

		pg.global.showBubbleMessage(NoticeDef.FORCE_LOCK_TARGET_DIS_TOO_FAR)

		return
	end

	self:tryForceLockTarget(targetId, partId, lockDist, isTemp, ignoreViewport)
end

function LockHelper:addFlashlightLockTarget(actorId)
	if not actorId or actorId == 0 then
		return
	end

	self.flashlightLockSet[actorId] = (self.flashlightLockSet[actorId] or 0) + 1
end

function LockHelper:removeFlashlightLockTarget(actorId)
	if not actorId or actorId == 0 then
		return
	end

	local cnt = self.flashlightLockSet[actorId]

	if not cnt then
		return
	end

	if cnt <= 1 then
		self.flashlightLockSet[actorId] = nil
	else
		self.flashlightLockSet[actorId] = cnt - 1
	end
end

function LockHelper:clearFlashlightLockTargets()
	self.flashlightLockSet = {}
end

function LockHelper:isFlashlightLockTarget(actorId)
	return self.flashlightLockSet[actorId] ~= nil
end

return LockHelper
