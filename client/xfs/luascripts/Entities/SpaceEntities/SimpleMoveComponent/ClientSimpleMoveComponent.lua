-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SimpleMoveComponent\\ClientSimpleMoveComponent.lua

local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local TablePool = require("Common.Container.TablePool")
local EventConst = require("Const.EventConst")
local AIUtils = require("Common.Utils.AIUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager").getLogger("ClientSimpleMoveComponent")
local PlayableConst = require("Common.Const.PlayableConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConstImp")
local Vector3 = Vector3
local ClientSimpleMoveComponent = class.Component("ClientSimpleMoveComponent")

function ClientSimpleMoveComponent:ctor()
	self.simpleLuaLeaveNotifyInfoMap = {}
	self.simpleLuaEnterNotifyInfoMap = {}
	self.pauseBtInfo = {}
	self.simpleMoveIsPaused = false
	self.pauseBtInfo[AiConst.PauseBtReason.SpaceLoading] = true
end

function ClientSimpleMoveComponent:EVENT_AddEComponent()
	local d = self.dic or AiConst.DefaultNullTable

	self.simpleMoveBehaviorMode = d.simpleMoveBehaviorMode or AiConst.SimpleMoveBehaviorMode.None
	self.simpleMoveProximityEnabled = d.simpleMoveProximityEnabled or false
	self.simpleMoveProximityRadius = d.simpleMoveProximityRadius or 3

	self:addEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT)
	self:_applyMovementConfig()
	self:_refreshBtPause()

	if self.bornPosition then
		self.eModel:SetBornPosition(Const.COMPONENT_SIMPLE_MOVEMENT, self.bornPosition[1], self.bornPosition[2], self.bornPosition[3])
	end
end

function ClientSimpleMoveComponent:onEnterSpace()
	self:resumeBt(AiConst.PauseBtReason.SpaceLoading)
	self:_loadInitialRoute()
end

function ClientSimpleMoveComponent:EVENT_OnAnimatorReady()
	self:_setupSimpleMoveProximity()
end

function ClientSimpleMoveComponent:checkBtPause()
	return not Utils.tableIsEmptyOrNil(self.pauseBtInfo)
end

function ClientSimpleMoveComponent:_refreshBtPause()
	local paused = self:checkBtPause()

	if self.simpleMoveIsPaused == paused then
		return
	end

	self.simpleMoveIsPaused = paused

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	if paused then
		self.eModel:Pause(Const.COMPONENT_SIMPLE_MOVEMENT)
	else
		self.eModel:Resume(Const.COMPONENT_SIMPLE_MOVEMENT)
	end
end

function ClientSimpleMoveComponent:pauseBt(reason)
	reason = reason or AiConst.PauseBtReason.Default
	self.pauseBtInfo[reason] = true

	self:_refreshBtPause()
end

function ClientSimpleMoveComponent:resumeBt(reason)
	reason = reason or AiConst.PauseBtReason.Default
	self.pauseBtInfo[reason] = nil

	self:_refreshBtPause()
end

function ClientSimpleMoveComponent:_applyMovementConfig()
	self.eModel:SetRunSpeed(Const.COMPONENT_SIMPLE_MOVEMENT, self:getConfigData().runspeed_v or 3)
	self.eModel:SetArriveDist(Const.COMPONENT_SIMPLE_MOVEMENT, 0.15)
end

function ClientSimpleMoveComponent:_setupSimpleMoveProximity()
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	local pData = self:getConfigData() or AiConst.DefaultNullTable
	local d = self.dic or AiConst.DefaultNullTable

	if pData.npcControlType ~= Const.NPC_CONTROL_TYPE.SimpleMove then
		return
	end

	self._smAnimHash = d.simpleMoveAnimStateKey or 0
	self._smSleHash1 = d.simpleMoveSleKey1 or 0
	self._smSleHash2 = d.simpleMoveSleKey2 or 0
	self._smSleHash3 = d.simpleMoveSleKey3 or 0
	self._smSleDuration = d.simpleMoveSleDuration or 0

	self.eModel:SetIdleAnimHash(Const.COMPONENT_SIMPLE_MOVEMENT, PlayableConst.Idle)

	if self.simpleMoveProximityEnabled then
		self.eModel:CreateProximityTrigger(Const.COMPONENT_SIMPLE_MOVEMENT, ClientConst.TriggerType.SIMPLE_MOVE_PROXIMITY, self.simpleMoveProximityRadius)
		self.eModel:SetProximityBehavior(Const.COMPONENT_SIMPLE_MOVEMENT, self.simpleMoveBehaviorMode or AiConst.SimpleMoveBehaviorMode.None, self._smAnimHash or 0, AnimationUtils.getID(self._smSleHash1), AnimationUtils.getID(self._smSleHash2), AnimationUtils.getID(self._smSleHash3), self._smSleDuration or 0, false)
	else
		self:_simpleMoveStartOff()
	end
end

function ClientSimpleMoveComponent:_resolveFollowSpeed(speed, rateType)
	if speed and speed > 0 then
		return speed
	end

	local cfg = self:getConfigData()

	if not cfg then
		return 0
	end

	rateType = rateType or 0

	if rateType <= 0 then
		return cfg.walkspeed_v or 0
	end

	return cfg.runspeed_v or cfg.walkspeed_v or 0
end

function ClientSimpleMoveComponent:_simpleMoveStartOff()
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	local mode = self.simpleMoveBehaviorMode

	if mode == AiConst.SimpleMoveBehaviorMode.Router then
		self.eModel:StartRoute(Const.COMPONENT_SIMPLE_MOVEMENT)
	elseif mode == AiConst.SimpleMoveBehaviorMode.PlaySingleAnim then
		if self._smAnimHash ~= 0 then
			self.eModel:PlayOneShotAnim(Const.COMPONENT_SIMPLE_MOVEMENT, self._smAnimHash, true)
		end
	elseif mode == AiConst.SimpleMoveBehaviorMode.PlaySleAnim then
		if self._smSleHash1 ~= 0 or self._smSleHash2 ~= 0 or self._smSleHash3 ~= 0 then
			self.eModel:PlaySleAnim(Const.COMPONENT_SIMPLE_MOVEMENT, self._smSleHash1, self._smSleHash2, self._smSleHash3, true, self._smSleDuration)
		end
	elseif mode == AiConst.SimpleMoveBehaviorMode.FollowEntity then
		local d = self.dic or AiConst.DefaultNullTable

		if (d.simpleMoveFollowTargetStaticId or 0) == 0 then
			return
		end

		local resolvedSpeed = self:_resolveFollowSpeed(d.simpleMoveFollowSpeed, d.simpleMoveFollowBehaviorSpeedRateType)

		self.eModel:StartFollowEntityByStaticId(Const.COMPONENT_SIMPLE_MOVEMENT, d.simpleMoveFollowTargetStaticId, resolvedSpeed, d.simpleMoveFollowKeepDistance or 0, d.simpleMoveFollowMoveAnimKey or 0, 0, d.simpleMoveFollowSnapToGround == true)
	end
end

function ClientSimpleMoveComponent:_simpleMoveOnTriggerDispatch()
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	if not self.eModel:IsIdle(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	local mode = self.simpleMoveBehaviorMode

	if mode == AiConst.SimpleMoveBehaviorMode.Router then
		self.eModel:StartRouteOneShot(Const.COMPONENT_SIMPLE_MOVEMENT)
	elseif mode == AiConst.SimpleMoveBehaviorMode.PlaySingleAnim then
		if self._smAnimHash ~= 0 then
			self.eModel:PlayOneShotAnim(Const.COMPONENT_SIMPLE_MOVEMENT, self._smAnimHash, true)
		end
	elseif mode == AiConst.SimpleMoveBehaviorMode.PlaySleAnim and (self._smSleHash1 ~= 0 or self._smSleHash2 ~= 0 or self._smSleHash3 ~= 0) then
		self.eModel:PlaySleAnim(Const.COMPONENT_SIMPLE_MOVEMENT, self._smSleHash1, self._smSleHash2, self._smSleHash3, false, self._smSleDuration)
	end
end

function ClientSimpleMoveComponent:onTriggerEnter(userData)
	if userData == ClientConst.TriggerType.SIMPLE_MOVE_PROXIMITY then
		self:_simpleMoveOnTriggerDispatch()
	end
end

function ClientSimpleMoveComponent:_resolveStepSpeed(s)
	if s.speed and s.speed > 0 then
		return s.speed
	end

	local cfg = self:getConfigData()

	if not cfg then
		return 0
	end

	local rate = s.behaviorSpeedRateType or 0

	if rate <= 0 then
		return cfg.walkspeed_v or 0
	end

	return cfg.runspeed_v or cfg.walkspeed_v or 0
end

local function _readPosAndFacing(s)
	local p = s.position
	local px, py, pz = 0, 0, 0

	if p then
		px, py, pz = p.x or p[1] or 0, p.y or p[2] or 0, p.z or p[3] or 0
	end

	local f = s.facingDir
	local fx, fy, fz = 0, 0, 0

	if f then
		fx, fy, fz = f.x or f[1] or 0, f.y or f[2] or 0, f.z or f[3] or 0
	end

	return px, py, pz, fx, fy, fz
end

function ClientSimpleMoveComponent:_buildRouteSteps(stepsArray, appendReturnHome, routeSnap)
	if not Utils.isTable(stepsArray) then
		return nil
	end

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return nil
	end

	self.eModel:ClearRoute(Const.COMPONENT_SIMPLE_MOVEMENT)

	if routeSnap == nil then
		routeSnap = true
	end

	self.eModel:SetRouteSnapToGround(Const.COMPONENT_SIMPLE_MOVEMENT, routeSnap == true)

	for i = 1, #stepsArray do
		local s = stepsArray[i]

		if s then
			local leaveNotifyLua = s.leaveNotifyInfoList ~= nil
			local enterNotifyLua = s.enterNotifyInfoList ~= nil
			local px, py, pz, fx, fy, fz = _readPosAndFacing(s)
			local resolvedSpeed = self:_resolveStepSpeed(s)
			local index = self.eModel:AddRouteStep(Const.COMPONENT_SIMPLE_MOVEMENT, leaveNotifyLua, enterNotifyLua, px, py, pz, fx, fy, fz, AnimationUtils.getID(s.animHashKey1), AnimationUtils.getID(s.animHashKey2), AnimationUtils.getID(s.animHashKey3), s.animationTimeout or -1, s.isStatic == true, resolvedSpeed)

			self.simpleLuaLeaveNotifyInfoMap[index] = s.leaveNotifyInfoList
			self.simpleLuaEnterNotifyInfoMap[index] = s.enterNotifyInfoList
		end
	end

	if appendReturnHome and #stepsArray >= 1 then
		local s = stepsArray[1]

		if s then
			local px, py, pz, fx, fy, fz = _readPosAndFacing(s)

			self.eModel:AddRouteStep(Const.COMPONENT_SIMPLE_MOVEMENT, false, false, px, py, pz, fx, fy, fz, AnimationUtils.getID(s.animHashKey1), AnimationUtils.getID(s.animHashKey2), AnimationUtils.getID(s.animHashKey3), s.animationTimeout or -1, s.isStatic == true, self:_resolveStepSpeed(s))
		end
	end
end

function ClientSimpleMoveComponent:startRoute(stepsArray, routeSnap)
	if routeSnap == nil then
		routeSnap = true
	end

	self:_buildRouteSteps(stepsArray, false, routeSnap)

	if self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		self.eModel:StartRoute(Const.COMPONENT_SIMPLE_MOVEMENT)
	end
end

function ClientSimpleMoveComponent:_resolveRouteEntry(routeId)
	if not routeId or routeId == 0 then
		return nil, nil
	end

	local space = self.space
	local routeData = SceneUtils.getSceneRouteData(space.sceneId, space.id)

	if not routeData then
		return nil, nil
	end

	local entry = routeData[routeId]

	if not entry or not AIUtils.isSimpleRoute(entry) then
		if LoggerManager.allow(LoggerConst.DEBUG, "AI") then
			LoggerManager:debug("ClientSimpleMoveComponent:", self.actorId, self.staticId, "_resolveRouteEntry: routeId ", routeId, " 不是SimpleRoute")
		end

		return nil, nil
	end

	local routeSnap = entry.simpleMoveRouteSnapToGround

	if routeSnap == nil then
		routeSnap = true
	end

	return entry, routeSnap
end

function ClientSimpleMoveComponent:startRouteById(routeId, loopTime)
	local entry, routeSnap = self:_resolveRouteEntry(routeId)

	if not entry then
		return false
	end

	self:_buildRouteSteps(entry.wayPoints, false, routeSnap)

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return false
	end

	self.eModel:StartRoute(Const.COMPONENT_SIMPLE_MOVEMENT, loopTime or 0)

	return true
end

function ClientSimpleMoveComponent:_loadInitialRoute()
	local d = self.dic

	if not d then
		return
	end

	if self.simpleMoveBehaviorMode ~= AiConst.SimpleMoveBehaviorMode.Router then
		return
	end

	local entry, routeSnap = self:_resolveRouteEntry(self.routeId)

	if not entry then
		return
	end

	self:_buildRouteSteps(entry.wayPoints, self.simpleMoveProximityEnabled == true, routeSnap)
end

function ClientSimpleMoveComponent:stopToIdleState()
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	self.eModel:StopToIdleState(Const.COMPONENT_SIMPLE_MOVEMENT)
end

function ClientSimpleMoveComponent:playOneShotAnim(animHashKey, isLoop)
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	self.eModel:PlayOneShotAnim(Const.COMPONENT_SIMPLE_MOVEMENT, animHashKey or 0, isLoop == true)
end

function ClientSimpleMoveComponent:notifyOneShotAnimEnded()
	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	self.eModel:NotifyAnimEnded(Const.COMPONENT_SIMPLE_MOVEMENT)
end

function ClientSimpleMoveComponent:_dispatchSimpleMoveNotify(info)
	if not info or not info.callbackFunctionName then
		return
	end

	local fn = self[info.callbackFunctionName]

	if fn then
		fn(self, info)
	end
end

function ClientSimpleMoveComponent:onSimpleMoveEntityRouteLeave(oldIndex)
	local infoList = self.simpleLuaLeaveNotifyInfoMap[oldIndex]

	if not infoList then
		return
	end

	for i = 1, #infoList do
		self:_dispatchSimpleMoveNotify(infoList[i])
	end
end

function ClientSimpleMoveComponent:onSimpleMoveEntityRouteEnter(index)
	local infoList = self.simpleLuaEnterNotifyInfoMap[index]

	if not infoList then
		return
	end

	for i = 1, #infoList do
		self:_dispatchSimpleMoveNotify(infoList[i])
	end
end

function ClientSimpleMoveComponent:startFollowEntityByStaticId(targetStaticId, speed, keepDistance, moveAnimHash, idleAnimHash, snapToGround)
	if not targetStaticId or targetStaticId == 0 then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	self.eModel:StartFollowEntityByStaticId(Const.COMPONENT_SIMPLE_MOVEMENT, targetStaticId, speed or 0, keepDistance or 1.2, moveAnimHash or PlayableConst.RunLoop, idleAnimHash or 0, snapToGround == true)
end

function ClientSimpleMoveComponent:startFollowEntityByActorId(targetActorId, speed, keepDistance, moveAnimHash, idleAnimHash, snapToGround)
	if not targetActorId or targetActorId == 0 then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		return
	end

	self.eModel:StartFollowEntityByActorId(Const.COMPONENT_SIMPLE_MOVEMENT, targetActorId, speed or 0, keepDistance or AiConst.FOLLOW_CLOSE, moveAnimHash or PlayableConst.RunLoop, idleAnimHash or PlayableConst.Idle, snapToGround == true)
end

function ClientSimpleMoveComponent:pawnAutoPathFinding(endPos, arriveCallback, pathFindType, posList, targetState, useAccurateArrive, stopDist)
	local oldCb = self.pendingMoveArriveCallback

	self.pendingMoveArriveCallback = nil

	if oldCb then
		oldCb(false)
	end

	if not self:hasEModelComponent(Const.COMPONENT_SIMPLE_MOVEMENT) then
		if arriveCallback then
			arriveCallback(false)
		end

		return false
	end

	local simplePathFindType = pathFindType == AutoPathFindUtils.PathFindType.ForceMove and AutoPathFindUtils.SimpleMoveTargetPathFindType.ForceMove or AutoPathFindUtils.SimpleMoveTargetPathFindType.Voxel
	local speed = 0
	local cfg = self:getConfigData()
	local isWalk = targetState == CharacterStateConst.WALK

	if cfg then
		if not isWalk then
			speed = cfg.runspeed_v or 0
		else
			speed = cfg.walkspeed_v or 0
		end
	end

	local arriveDist = 0

	if useAccurateArrive then
		arriveDist = 0.05
	elseif stopDist and stopDist > 0 then
		arriveDist = stopDist
	end

	if self.pendingMoveArriveCallback ~= nil then
		if arriveCallback then
			arriveCallback(false)
		end

		return false
	end

	local moveAnimHash = AnimationUtils.getID(isWalk and PlayableConst.Walk or PlayableConst.RunLoop) or 0

	self.pendingMoveArriveCallback = arriveCallback

	self.eModel:MoveToTargetPos(Const.COMPONENT_SIMPLE_MOVEMENT, endPos[1], endPos[2], endPos[3], simplePathFindType, speed, arriveDist, moveAnimHash)

	return true
end

function ClientSimpleMoveComponent:onSimpleMoveTargetArrived(arrived)
	local cb = self.pendingMoveArriveCallback

	self.pendingMoveArriveCallback = nil

	if cb then
		cb(arrived == true)
	end
end

function ClientSimpleMoveComponent:RPC_SC_StartRouteById(routeId, loopTime)
	self:startRouteById(routeId, loopTime)
end

function ClientSimpleMoveComponent:smShowEmojiBubble(info)
	local timeout = info.isLoop and -1 or info.timeout

	self.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, info.emojiName, timeout, info.matchMultiple)
end

function ClientSimpleMoveComponent:smHideEmojiBubble()
	self:emitEventPreCheckComp(EventConst.TOPLOGO_BUBBLE, false)
end

function ClientSimpleMoveComponent:smShowDialogue(info)
	local tmpTable = TablePool.getTable()

	tmpTable.forbidNextBtnClick = true

	pg.game.communication:startNpcDialog(info.dialogueId, self.id, tmpTable)
	TablePool.returnTable(tmpTable)
end

function ClientSimpleMoveComponent:smDoSysEvent(info)
	pg.me:doEvent(info.sysEventId, {
		globalId = self:getGlobalId()
	})
end

return ClientSimpleMoveComponent
