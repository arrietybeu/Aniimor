-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ConditionTrigger\\CTHelper.lua

local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local BlackBoardData = require("Common.Data.AICtrData.aictr_global_blackBoards_data")
local AICtrConstData = require("Common.Data.AICtrData.aictr_const_data")
local AiConst = require("Common.Const.AiConst")
local ListPool = require("Common.Container.ListPool")
local PlanPool = require("Common.AI.BehaviacAgent.Unit.Plan.PlanPool")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local CalcUtils = require("Common.Utils.CalcUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local CTActionFunc = require("Common.AI.ConditionTrigger.CTActionFunc")
local CTFlow = require("Common.AI.ConditionTrigger.CTFlow")
local IBaseCombatComponent = require("Common.AI.BehaviacAgent.Unit.IBaseCombatComponent")
local IBaseOpComponent = require("Common.AI.BehaviacAgent.Unit.IBaseOpComponent")
local IBasePropertyComponent = require("Common.AI.BehaviacAgent.Unit.IBasePropertyComponent")
local IMoveComponent = require("Common.AI.BehaviacAgent.Unit.IMoveComponent")
local IPetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPetCombatComponent")
local IResPointComponent = require("Common.AI.BehaviacAgent.Unit.IResPointComponent")
local IUtilsComponent = require("Common.AI.BehaviacAgent.Unit.IUtilsComponent")
local IVoxelComponent = require("Common.AI.BehaviacAgent.Unit.IVoxelComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("CTFlow")
local Vector3 = require("Common.Math.vector3")
local select = select
local ipairs = ipairs
local pairs = pairs
local pg = pg
local CTHelper = {}
local _commonFunc = {
	Add = IBaseOpComponent.add,
	CheckCanMoveToTarget = IMoveComponent.checkCanMoveToTarget,
	CheckCanUseSkill = IBaseCombatComponent.checkCanUseSkill,
	CheckEntIsBreak = IBaseCombatComponent.checkIsBreakST,
	CheckEntIsChargeSkill = IBaseCombatComponent.checkIsChargeSkill,
	CheckEntityExist = IUtilsComponent.checkEntityExist,
	CheckHasAbility = IUtilsComponent.checkHasAbility,
	CheckHasChemState = IUtilsComponent.checkHasChemState,
	CheckHasEntityTag = IUtilsComponent.checkEntityHasTag,
	CheckInAIState = IUtilsComponent.checkInAIState,
	CheckInDialog = IUtilsComponent.checkInDialog,
	CheckIsCamouflage = IBaseCombatComponent.checkIsCamouflage,
	CheckIsDead = IBaseCombatComponent.checkIsDead,
	CheckIsInCapture = IBaseCombatComponent.checkIsInCapture,
	CheckIsInRangeTgt2D = IMoveComponent.checkIsInRangeTgt2D,
	CheckPetActionMode = IPetCombatComponent.checkPetActionMode,
	CheckRelation = IUtilsComponent.checkRelation,
	CheckRouteIdIsValid = IBasePropertyComponent.checkRouteIdIsValid,
	CheckRouteIdIsValidSimple = IBasePropertyComponent.checkRouteIdIsValidSimple,
	CheckSkillCanCast = IBaseCombatComponent.checkSkillCanCast,
	CheckTargetLabel = IUtilsComponent.checkTargetLabel,
	CheckTargetMBTI = IUtilsComponent.checkTargetMBTI,
	Div = IBaseOpComponent.div,
	GetActorId = IUtilsComponent.getActorId,
	GetAIBlackboardValue = IBasePropertyComponent.getAIBlackboardValue,
	GetAngleByEntity = IUtilsComponent.getAngleByEntity,
	GetAnimTagDuration = IBasePropertyComponent.getAnimTagDuration,
	GetAuthorityPlayer = IBasePropertyComponent.getAuthorityPlayer,
	GetBodyHeight = IUtilsComponent.getBodyHeight,
	GetBornState = IBasePropertyComponent.getBornState,
	GetChestGuideLevel = IUtilsComponent.getChestGuideLevel,
	GetClimbDataIdFromResPoint = IResPointComponent.getClimbDataIdFromResPoint,
	GetControllingPetActorId = IUtilsComponent.getControllingPetActorId,
	GetCurMeteorologyId = IUtilsComponent.getCurMeteorologyId,
	GetCurWeatherId = IUtilsComponent.getCurWeatherId,
	GetDayTime = IBasePropertyComponent.getDayTime,
	GetDistance = IUtilsComponent.getDistance,
	GetDistanceFromEntityToResPointPort = IResPointComponent.getDistanceFromEntityToResPointPort,
	GetEntConfigData = IBasePropertyComponent.getEntConfigData,
	GetEntityCacheValue = IUtilsComponent.getEntityCacheValue,
	GetEntityIdByResPointId = IResPointComponent.getEntityIdByResPointId,
	GetEntPosition = IBasePropertyComponent.getEntPosition,
	GetEntProperty = IBasePropertyComponent.getEntProperty,
	GetForbidFollowMasterCharStateList = IBasePropertyComponent.getForbidFollowMasterCharStateList,
	GetGameTime = IBasePropertyComponent.getGameTime,
	GetHpPercent = IBaseCombatComponent.getHpPercent,
	GetId = IBasePropertyComponent.getId,
	GetInteractEnvObj = IBaseCombatComponent.getInteractEnvObj,
	GetLeaderId = IBasePropertyComponent.getLeaderId,
	GetNpcStatusConfigData = IUtilsComponent.getNpcStatusConfigData,
	GetNpcStatusServerData = IUtilsComponent.getNpcStatusServerData,
	GetPartnerIds = IBasePropertyComponent.getPartnerIds,
	GetPerceptibilityTable = IBasePropertyComponent.getPerceptibilityTable,
	GetPerceptibilityValue = IBasePropertyComponent.getPerceptibilityValue,
	GetPetData = IBasePropertyComponent.getPetData,
	GetPetLockedId = IBasePropertyComponent.getPetLockedId,
	GetPetMaster = IBaseCombatComponent.getMasterId,
	GetPlayerVar = IUtilsComponent.getPlayerVar,
	GetPuppetData = IBasePropertyComponent.getPuppetData,
	GetResPointPortPosition = IResPointComponent.getResPointPortPosition,
	GetRouteIdFromEntity = IBasePropertyComponent.getRouteIdFromEntity,
	GetRouteIdFromEntitySimple = IBasePropertyComponent.getRouteIdFromEntitySimple,
	GetRouteIdFromResPoint = IBasePropertyComponent.getRouteIdFromResPoint,
	GetSkillProperty = IBasePropertyComponent.getSkillProperty,
	GetSkillType = IBasePropertyComponent.getSkillType,
	GetStaticId = IUtilsComponent.getStaticId,
	GetTableLength = IBaseOpComponent.getTableLength,
	GetTableValueByKey = IBaseOpComponent.getTableValueByKey,
	GetTargetBuffLayerCount = IBaseCombatComponent.getTargetBuffLayerCount,
	IsChildOfCharState = IUtilsComponent.isChildOfCharState,
	IsChildOrTransitionOfCharState = IUtilsComponent.isChildOrTransitionOfCharState,
	IsControllingPet = IUtilsComponent.isControllingPet,
	IsCurCombatPet = IUtilsComponent.isCurCombatPet,
	IsEntityType = IUtilsComponent.isEntityType,
	IsEnvObjCanInteract = IUtilsComponent.isEnvObjCanInteract,
	IsEqual = IBaseOpComponent.isEqual,
	IsEthnicGroup = IUtilsComponent.isEthnicGroup,
	IsGreaterOrEqual = IBaseOpComponent.isGreaterOrEqual,
	IsGreaterThan = IBaseOpComponent.isGreaterThan,
	IsInAnimState = IUtilsComponent.isInAnimState,
	IsInBehavTag = IUtilsComponent.isInBehavTag,
	IsInCatchMode = IUtilsComponent.isInCatchMode,
	IsInCharState = IUtilsComponent.isInCharState,
	IsInCrouch = IUtilsComponent.isInCrouch,
	IsInGroupBehaviour = IUtilsComponent.isInGroupBehaviour,
	IsInMagnesisMode = IUtilsComponent.isInMagnesisMode,
	IsInPetBallExpAction = IUtilsComponent.isInPetBallExpAction,
	IsInSelfieMode = IUtilsComponent.isInSelfieMode,
	IsInSkill = IBaseCombatComponent.isInSkill,
	IsInUltimateSkill = IBaseCombatComponent.isInUltimateSkill,
	IsLessOrEqual = IBaseOpComponent.isLessOrEqual,
	IsLessThan = IBaseOpComponent.isLessThan,
	IsNil = IBaseOpComponent.isNil,
	IsOnWater = IVoxelComponent.isOnWater,
	IsPlayerInCombat = IBaseCombatComponent.isInCombat,
	IsPlayerTwinPet = IUtilsComponent.isPlayerTwinPet,
	IsPuppetInCallFriend = IUtilsComponent.isPuppetInCallFriend,
	IsSameDayTime = IBaseOpComponent.isEqual,
	IsSameSpecies = IUtilsComponent.isSameSpecies,
	IsTableEmpty = IBaseOpComponent.isTableEmpty,
	IsTwinPet = IUtilsComponent.isTwinPet,
	Mod = IBaseOpComponent.mod,
	Mul = IBaseOpComponent.mul,
	RandomInteger = IBaseOpComponent.randomInteger,
	Sub = IBaseOpComponent.sub
}
local __useTimeCounter = {}

local function __addCount(funcName, time)
	local info = __useTimeCounter[funcName]

	if info == nil then
		info = {}
		__useTimeCounter[funcName] = info
	end

	info.count = (info.count or 0) + 1
	info.time = (info.time or 0) + time
end

function CTHelper.ClearResult()
	__useTimeCounter = {}
end

function CTHelper.GetResult()
	local temp = {}

	for k, v in pairs(__useTimeCounter) do
		temp[#temp + 1] = {
			funcName = k,
			useTime = v.time,
			count = v.count,
			averageTime = v.time / v.count
		}
	end

	table.sort(temp, function(a, b)
		return a.useTime > b.useTime
	end)

	return temp
end

function CTHelper.SafeCallDebug(nodeId, isFlow, toNodeId, toPortName, fromNodeId, fromPortName, funcName, flow, ...)
	local specialFunc = CTHelper[funcName]
	local func, obj

	if specialFunc then
		func, obj = specialFunc, flow
	else
		func, obj = _commonFunc[funcName], flow.__agent
	end

	if func then
		local status, res = xpcall(func, debug.traceback, obj, ...)

		if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("GRAPH: 【%s】, CTRNode: 【%s】, Pos: 【%s】, StaticId: 【%s】 execute with error: %s", flow.__graphId, nodeId, flow.__owner and inspect(flow.__owner:getPosition()) or "", flow.__owner and flow.__owner.staticId or "", res))
		end

		if flow.__graph and flow.__graph.debugMode then
			if isFlow then
				flow.__graph.executeNodeAction({
					vPort = true,
					entityId = flow.__actorId,
					inputNodeId = fromNodeId,
					outputNodeId = toNodeId,
					exception = not status,
					errorInfo = res,
					iPortName = fromPortName,
					oPortName = toPortName
				})
			else
				flow.__graph.executeNodeAction({
					vPort = false,
					entityId = flow.__actorId,
					inputNodeId = fromNodeId,
					outputNodeId = toNodeId,
					exception = not status,
					errorInfo = res,
					value = inspect(res),
					iPortName = fromPortName,
					oPortName = toPortName
				})
			end
		end

		return res
	end
end

function CTHelper.SafeCall(_, funcName, flow, ...)
	local specialFunc = CTHelper[funcName]

	if specialFunc then
		return specialFunc(flow, ...)
	end

	local commonFunc = _commonFunc[funcName]

	if commonFunc then
		return commonFunc(flow.__agent, ...)
	end
end

function CTHelper.AddEntityTag(flow, entityActorId, tag)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	Utils.addEntityTag(ent, tag)
end

function CTHelper.And(flow, ...)
	local n = select("#", ...)

	for i = 1, n do
		local item = select(i, ...)

		if not item then
			return false
		end
	end

	return true
end

function CTHelper.CreateEntityGroupBehaviour(flow, behavName)
	if Utils.checkClient() then
		local ent = flow.__owner

		if ent and ent.space and ent.space.aiMgr and ent.isInGroupBehaviour and not ent:isInGroupBehaviour(true) then
			local groupBehav = ent.space.aiMgr:createBehaviour(behavName, ent)

			groupBehav:start()
			ent:joinGroupBehaviour(groupBehav)
		end
	end
end

function CTHelper.DoAction(flow, funcName, ...)
	CTActionFunc[funcName](flow, ...)
end

function CTHelper.DoBehaviour(flow, btName)
	BehaviorTreePlanUtils.startEcologyPlanByState(flow.__agent, BehaviorPathMapData.EnumNameMap[btName])
end

function CTHelper.BeginBehaviourV2(flow, btName)
	if flow.__isAdditive then
		return false
	end

	flow:setActive()
	BehaviorTreePlanUtils.startEcologyPlanByState(flow.__agent, BehaviorPathMapData.EnumNameMap[btName])

	return true
end

function CTHelper.DoPatrolBehavior(flow, patrolType, patrolId, loopTime, leadActorId)
	local ent = flow.__owner
	local plan

	if patrolType == AiConst.PatrolType.Normal or patrolType == AiConst.PatrolType.Glide then
		if patrolId > 0 then
			plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.PatrolPlan, ent.space.sceneId, patrolId, false, loopTime, flow.__behaviourId, ent.space.id)

			if plan then
				ent:setIgnoreAILod(plan:checkIgnoreAILod(), AiConst.IgnoreAILodReason.Route)
			end
		end
	elseif patrolType == AiConst.PatrolType.Climb then
		local climbData, posX, posY, posZ, angleX, angleY, angleZ = AIUtils.getPatrolData(ent, patrolId)

		if climbData then
			plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.ClimbPlan, posX, posY, posZ, angleX, angleY, angleZ, patrolId, climbData, flow.__behaviourId)
		end
	elseif patrolType == AiConst.PatrolType.NPCLead then
		if leadActorId == 0 then
			leadActorId = Utils.getAuthorityPlayerActorId(ent)
		end

		local leadTargetEnt = pg.getEntityByActorId(leadActorId)

		if patrolId > 0 and leadTargetEnt then
			plan = PlanPool.getNewPlan(AiConst.ParmonPlanType.NPCLeadPlan, ent.space.sceneId, patrolId, flow.__behaviourId, leadActorId, ent.space.id)

			if plan then
				ent:setIgnoreAILod(plan:checkIgnoreAILod(), AiConst.IgnoreAILodReason.Route)
			end
		end
	end

	if plan then
		flow:setPatrolPlan(patrolId, plan)
	end

	return plan
end

function CTHelper.GetAnimState(flow, dataOption, name)
	local data = AICtrConstData.getAnimState[dataOption]

	if data then
		for _, v in ipairs(data) do
			if v.name == name then
				return v.value
			end
		end
	end
end

function CTHelper.GetAoiEntityTableByLevel(flow, actorId, aoiLevel, searchType)
	local ret = flow:getTempList()

	actorId = flow:getValidActorId(actorId)

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		AIUtils.SearchEntitiesInRangeWithCache(ent, aoiLevel, searchType, ret)
	end

	return ret
end

function CTHelper.GetAoiResPointPortTableByLevel(flow, actorId, aoiLevel, maxDeltaHeight, pointTags, portTags)
	actorId = flow:getValidActorId(actorId)

	local portIdTables = ListPool.getList()
	local fixPortIds = flow:getTempList()

	ResPointUtils.GetResPointPortInRange(actorId, aoiLevel, maxDeltaHeight, pointTags, portTags, portIdTables)

	for _, portIdTable in ipairs(portIdTables) do
		local portIds = flow:getTempList()

		portIds[1] = ResPointUtils.ToFixPointId(portIdTable[1], portIdTable[2])
		portIds[2] = portIdTable[3]
		fixPortIds[#fixPortIds + 1] = portIds
	end

	ListPool.returnList(portIdTables)

	return fixPortIds
end

function CTHelper.GetContextValue(flow, key)
	return flow:getContextValue(key)
end

function CTHelper.GetSelfId(flow)
	return flow.__actorId
end

function CTHelper.GlobalBlackBoard(flow, paramName)
	return BlackBoardData[paramName]
end

function CTHelper.HasAITag(flow, actorId, ...)
	actorId = flow:getValidActorId(actorId)

	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.hasAITag then
		local n = select("#", ...)

		for i = 1, n do
			local tag = select(i, ...)

			if ent:hasAITag(tag) then
				return true
			end
		end
	end

	return false
end

function CTHelper.HasEntityTag(flow, actorId, ...)
	actorId = flow:getValidActorId(actorId)

	local ent = pg.getEntityByActorId(actorId)

	if ent then
		local n = select("#", ...)

		for i = 1, n do
			local tag = select(i, ...)

			if Utils.hasEntityTag(ent, tag) then
				return true
			end
		end
	end

	return false
end

function CTHelper.IsInRange(flow, targetActorId, rangeType, needRaycast, originPosOffsetX, originPosOffsetY, originPosOffsetZ, originAngleOffset, angleStart, angleEnd, radius, heightStart, heightEnd)
	local me = flow.__owner
	local target = pg.getEntityByActorId(targetActorId)
	local ret = false

	if target then
		Vector3.enableCreateFromCache()

		local myPos = me:getPosition()
		local myDir = me:getRotation():Forward()
		local targetPos = target:getPosition():Clone()

		targetPos.y = targetPos.y + target:getHeight() * 0.5

		local originPos = Vector3(myPos.x + originPosOffsetX, myPos.y + originPosOffsetY, myPos.z + originPosOffsetZ)
		local originDirX, originDirY, originDirZ = CalcUtils.clockwiseRotateDegree(myDir.x, myDir.y, myDir.z, originAngleOffset)

		if targetPos.y < originPos.y + heightStart or targetPos.y > originPos.y + heightEnd then
			Vector3.disableCreateFromCache()

			return false
		end

		if rangeType == 0 then
			originDirX, originDirY, originDirZ = CalcUtils.clockwiseRotateDegree(originDirX, originDirY, originDirZ, (angleStart + angleEnd) * 0.5)

			local theta = Utils.normalizeAngle(angleEnd - angleStart) * 0.5
			local inRange = CalcUtils.isPointInCirualSector(targetPos.x, targetPos.z, originDirX, originDirZ, originPos.x, originPos.z, radius, theta)

			if inRange then
				if needRaycast then
					local dir = targetPos - originPos
					local maxDist = Vector3.Magnitude(dir)

					dir:SetNormalize()

					local layerMask = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
					local raycastHit, success = PhysicsUtils.getRaycastInfo(originPos, dir, maxDist, layerMask)

					if not success then
						ret = true
					end
				else
					ret = true
				end
			end
		end

		Vector3.disableCreateFromCache()
	end

	return ret
end

function CTHelper.Not(flow, value)
	return not value
end

function CTHelper.Or(flow, ...)
	local n = select("#", ...)

	for i = 1, n do
		local item = select(i, ...)

		if item then
			return true
		end
	end

	return false
end

function CTHelper.RemoveEntityTag(flow, entityActorId, tag)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	Utils.removeEntityTag(ent, tag)
end

function CTHelper.SelectOneByRandom(flow, list)
	if list == nil or #list == 0 then
		return nil
	end

	local index = math.random(1, #list)

	return list[index]
end

function CTHelper.SetAIBlackboardValue(flow, targetActorId, blackboardName, value)
	targetActorId = flow:getValidActorId(targetActorId)

	local ent = pg.getEntityByActorId(targetActorId)

	if ent and ent.agent then
		ent.agent:setBlackBoardProperty(blackboardName, value)
	end
end

function CTHelper.SetCache(flow, cacheNodeId, key, value)
	flow:setCache(cacheNodeId, key, value)
end

function CTHelper.SetEntityCacheValue(flow, entityActorId, keyName, value)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		EntityCacheValueUtils.setCacheValue(ent, keyName, value)
	end
end

function CTHelper.UnpackResPointPort(flow, portIdTable, index)
	return portIdTable and portIdTable[index] or 0
end

return CTHelper
