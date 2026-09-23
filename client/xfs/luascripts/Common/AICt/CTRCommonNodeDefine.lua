-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTRCommonNodeDefine.lua

local IBaseCombatComponent = require("Common.AI.BehaviacAgent.Unit.IBaseCombatComponent")
local IBaseOpComponent = require("Common.AI.BehaviacAgent.Unit.IBaseOpComponent")
local IBasePropertyComponent = require("Common.AI.BehaviacAgent.Unit.IBasePropertyComponent")
local IMoveComponent = require("Common.AI.BehaviacAgent.Unit.IMoveComponent")
local IParmonPlanComponent = require("Common.AI.BehaviacAgent.Unit.IParmonPlanComponent")
local IPetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPetCombatComponent")
local IResPointComponent = require("Common.AI.BehaviacAgent.Unit.IResPointComponent")
local IUtilsComponent = require("Common.AI.BehaviacAgent.Unit.IUtilsComponent")
local IVoxelComponent = require("Common.AI.BehaviacAgent.Unit.IVoxelComponent")
local AIUtils = require("Common.Utils.AIUtils")
local CTRCommonNodeDefine = {}

CTRCommonNodeDefine.Add = {
	inPort = {
		"op1",
		"op2"
	},
	outFunc = IBaseOpComponent.add
}
CTRCommonNodeDefine.Sub = {
	inPort = {
		"op1",
		"op2"
	},
	outFunc = IBaseOpComponent.sub
}
CTRCommonNodeDefine.Mul = {
	inPort = {
		"op1",
		"op2"
	},
	outFunc = IBaseOpComponent.mul
}
CTRCommonNodeDefine.Div = {
	inPort = {
		"op1",
		"op2"
	},
	outFunc = IBaseOpComponent.div
}
CTRCommonNodeDefine.Mod = {
	inPort = {
		"op1",
		"op2"
	},
	outFunc = IBaseOpComponent.mod
}
CTRCommonNodeDefine.IsGreaterThan = {
	outPort = "result",
	inPort = {
		"inputA",
		"inputB"
	},
	outFunc = IBaseOpComponent.isGreaterThan
}
CTRCommonNodeDefine.IsGreaterOrEqual = {
	outPort = "result",
	inPort = {
		"inputA",
		"inputB"
	},
	outFunc = IBaseOpComponent.isGreaterOrEqual
}
CTRCommonNodeDefine.IsLessThan = {
	outPort = "result",
	inPort = {
		"inputA",
		"inputB"
	},
	outFunc = IBaseOpComponent.isLessThan
}
CTRCommonNodeDefine.IsLessOrEqual = {
	outPort = "result",
	inPort = {
		"inputA",
		"inputB"
	},
	outFunc = IBaseOpComponent.isLessOrEqual
}
CTRCommonNodeDefine.IsEqual = {
	outPort = "result",
	inPort = {
		"inputA",
		"inputB"
	},
	outFunc = IBaseOpComponent.isEqual
}
CTRCommonNodeDefine.IsNil = {
	outPort = "isNil",
	inPort = {
		"input"
	},
	outFunc = IBaseOpComponent.isNil
}
CTRCommonNodeDefine.IsTableEmpty = {
	outPort = "isEmpty",
	inPort = {
		"input"
	},
	outFunc = IBaseOpComponent.isTableEmpty
}
CTRCommonNodeDefine.RandomInteger = {
	inPort = {
		"min",
		"max"
	},
	outFunc = IBaseOpComponent.randomInteger
}
CTRCommonNodeDefine.GetTableLength = {
	outPort = "length",
	inPort = {
		"input"
	},
	outFunc = IBaseOpComponent.getTableLength
}
CTRCommonNodeDefine.GetTableValueByKey = {
	outPort = "value",
	inPort = {
		"inTable",
		"key"
	},
	outFunc = IBaseOpComponent.getTableValueByKey
}
CTRCommonNodeDefine.CheckCanMoveToTarget = {
	inPort = {
		"targetActorId",
		"stopDistance"
	},
	outFunc = IMoveComponent.checkCanMoveToTarget
}
CTRCommonNodeDefine.CheckCanUseSkill = {
	inPort = {
		"tgtId",
		"skillId"
	},
	outFunc = IBaseCombatComponent.checkCanUseSkill
}
CTRCommonNodeDefine.CheckEntIsBreak = {
	inPort = {
		"targetActorId"
	},
	outFunc = IBaseCombatComponent.checkIsBreakST
}
CTRCommonNodeDefine.CheckEntIsChargeSkill = {
	inPort = {
		"targetActorId",
		"skillId"
	},
	outFunc = IBaseCombatComponent.checkIsChargeSkill
}
CTRCommonNodeDefine.CheckEntityExist = {
	inPort = {
		"targetActorId"
	},
	outFunc = IUtilsComponent.checkEntityExist
}
CTRCommonNodeDefine.CheckHasChemState = {
	inPort = {
		"entityActorId",
		"$chemStateKey"
	},
	outFunc = IUtilsComponent.checkHasChemState
}
CTRCommonNodeDefine.CheckHasEntityTag = {
	inPort = {
		"entityActorId",
		"$tag"
	},
	outFunc = IUtilsComponent.checkEntityHasTag
}
CTRCommonNodeDefine.CheckInAIState = {
	inPort = {
		"targetEntityActorId",
		"stateName"
	},
	outFunc = IUtilsComponent.checkInAIState
}
CTRCommonNodeDefine.CheckInDialog = {
	inPort = {
		"dialogId"
	},
	outFunc = IUtilsComponent.checkInDialog
}
CTRCommonNodeDefine.CheckPetActionMode = {
	inPort = {
		"$actionMode",
		"targetEntityActorId"
	},
	outFunc = IPetCombatComponent.checkPetActionMode
}
CTRCommonNodeDefine.CheckRelation = {
	inPort = {
		"targetEntityActorId",
		"targetEntityActorId2",
		"$relationType"
	},
	outFunc = IUtilsComponent.checkRelation
}
CTRCommonNodeDefine.CheckRouteIdIsValid = {
	inPort = {
		"routeId",
		"entityId",
		"dayTime",
		"weatherId",
		"meteorologyId",
		"entityTag",
		"otherTag1",
		"otherTag2",
		"otherTag3"
	},
	outFunc = IBasePropertyComponent.checkRouteIdIsValid
}
CTRCommonNodeDefine.CheckRouteIdIsValidSimple = {
	inPort = {
		"routeId",
		"entityId"
	},
	outFunc = IBasePropertyComponent.checkRouteIdIsValidSimple
}
CTRCommonNodeDefine.CheckSkillCanCast = {
	inPort = {
		"targetEntityActorId",
		"skillId"
	},
	outFunc = IBaseCombatComponent.checkSkillCanCast
}
CTRCommonNodeDefine.CheckTargetLabel = {
	inPort = {
		"entityActorId",
		"$label"
	},
	outFunc = IUtilsComponent.checkTargetLabel
}
CTRCommonNodeDefine.CheckTargetMBTI = {
	inPort = {
		"entityActorId",
		"$mbti"
	},
	outFunc = IUtilsComponent.checkTargetMBTI
}
CTRCommonNodeDefine.GetActorId = {
	outPort = "actorId",
	inPort = {
		"staticId"
	},
	outFunc = IUtilsComponent.getActorId
}
CTRCommonNodeDefine.GetAIBlackboardValue = {
	inPort = {
		"targetActorId",
		"$blackboardName"
	},
	outFunc = IBasePropertyComponent.getAIBlackboardValue
}
CTRCommonNodeDefine.GetAngleByEntity = {
	outPort = "angle",
	inPort = {
		"targetId",
		"referenceId"
	},
	outFunc = IUtilsComponent.getAngleByEntity
}
CTRCommonNodeDefine.GetAnimTagDuration = {
	inPort = {
		"tgtId"
	},
	outFunc = IBasePropertyComponent.getAnimTagDuration
}
CTRCommonNodeDefine.GetAuthorityPlayer = {
	inPort = {},
	outFunc = IBasePropertyComponent.getAuthorityPlayer
}
CTRCommonNodeDefine.GetBornState = {
	outPort = "bornState",
	inPort = {},
	outFunc = IBasePropertyComponent.getBornState
}
CTRCommonNodeDefine.GetChestGuideLevel = {
	outPort = "chestGuideLevel",
	inPort = {
		"chestActorId"
	},
	outFunc = IUtilsComponent.getChestGuideLevel
}
CTRCommonNodeDefine.GetClimbDataIdFromResPoint = {
	inPort = {
		"pointId"
	},
	outFunc = IResPointComponent.getClimbDataIdFromResPoint
}
CTRCommonNodeDefine.GetControllingPetActorId = {
	outPort = "actorId",
	inPort = {
		"playerId"
	},
	outFunc = IUtilsComponent.getControllingPetActorId
}
CTRCommonNodeDefine.GetDayTime = {
	outPort = "dayTime",
	inPort = {},
	outFunc = IBasePropertyComponent.getDayTime
}
CTRCommonNodeDefine.GetDistance = {
	outPort = "distance",
	inPort = {
		"entityId1",
		"entityId2",
		"useBodySize"
	},
	outFunc = IUtilsComponent.getDistance
}
CTRCommonNodeDefine.GetDistanceFromEntityToResPointPort = {
	outPort = "distance",
	inPort = {
		"entityId",
		"resPointPort"
	},
	outFunc = IResPointComponent.getDistanceFromEntityToResPointPort
}
CTRCommonNodeDefine.GetEntConfigData = {
	inPort = {
		"targetActorId",
		"$propertyName"
	},
	outFunc = IBasePropertyComponent.getEntConfigData
}
CTRCommonNodeDefine.GetEntityCacheValue = {
	inPort = {
		"$keyName",
		"entityActorId"
	},
	outFunc = IUtilsComponent.getEntityCacheValue
}
CTRCommonNodeDefine.GetEntityIdByResPointId = {
	outPort = "entityId",
	inPort = {
		"pointId"
	},
	outFunc = IResPointComponent.getEntityIdByResPointId
}
CTRCommonNodeDefine.GetEntPosition = {
	inPort = {
		"targetActorId"
	},
	outFunc = IBasePropertyComponent.getEntPosition
}
CTRCommonNodeDefine.GetEntProperty = {
	inPort = {
		"targetActorId",
		"$propertyName"
	},
	outFunc = IBasePropertyComponent.getEntProperty
}
CTRCommonNodeDefine.GetForbidFollowMasterCharStateList = {
	inPort = {},
	outFunc = IBasePropertyComponent.getForbidFollowMasterCharStateList
}
CTRCommonNodeDefine.GetGameTime = {
	inPort = {},
	outFunc = IBasePropertyComponent.getGameTime
}
CTRCommonNodeDefine.GetHpPercent = {
	inPort = {
		"tgtId"
	},
	outFunc = IBaseCombatComponent.getHpPercent
}
CTRCommonNodeDefine.GetId = {
	inPort = {
		"$idName"
	},
	outFunc = IBasePropertyComponent.getId
}
CTRCommonNodeDefine.GetLeaderId = {
	outPort = "leaderId",
	inPort = {
		"entityId"
	},
	outFunc = IBasePropertyComponent.getLeaderId
}
CTRCommonNodeDefine.GetLogicState = {
	outPort = "result",
	inPort = {
		"$dataValue"
	},
	outFunc = IBasePropertyComponent.getLogicState
}
CTRCommonNodeDefine.GetNpcStatusConfigData = {
	inPort = {
		"key"
	},
	outFunc = IUtilsComponent.getNpcStatusConfigData
}
CTRCommonNodeDefine.GetNpcStatusServerData = {
	inPort = {
		"key"
	},
	outFunc = IUtilsComponent.getNpcStatusServerData
}
CTRCommonNodeDefine.GetPartnerIds = {
	outPort = "partnerIds",
	inPort = {
		"entityId"
	},
	outFunc = IBasePropertyComponent.getPartnerIds
}
CTRCommonNodeDefine.GetPerceptibilityTable = {
	outPort = "perceptibilityEntityTable",
	inPort = {},
	outFunc = IBasePropertyComponent.getPerceptibilityTable
}
CTRCommonNodeDefine.GetPerceptibilityValue = {
	outPort = "perceptibilityValue",
	inPort = {
		"targetActorId"
	},
	outFunc = IBasePropertyComponent.getPerceptibilityValue
}
CTRCommonNodeDefine.GetPetData = {
	outPort = "result",
	inPort = {
		"targetId",
		"$dataKey"
	},
	outFunc = IBasePropertyComponent.getPetData
}
CTRCommonNodeDefine.GetPetLockedId = {
	outPort = "lockedActorId",
	inPort = {},
	outFunc = IBasePropertyComponent.getPetLockedId
}
CTRCommonNodeDefine.GetPetMaster = {
	outPort = "masterId",
	inPort = {
		"targetActorId"
	},
	outFunc = IBaseCombatComponent.getMasterId
}
CTRCommonNodeDefine.GetPlayerVar = {
	inPort = {
		"key"
	},
	outFunc = IUtilsComponent.getPlayerVar
}
CTRCommonNodeDefine.GetPuppetData = {
	outPort = "result",
	inPort = {
		"targetId",
		"$dataKey",
		"$safeGet",
		"defaultValue"
	},
	outFunc = IBasePropertyComponent.getPuppetData
}
CTRCommonNodeDefine.GetResPointPortPosition = {
	outPort = "position",
	inPort = {
		"resPointId",
		"portId"
	},
	outFunc = IResPointComponent.getResPointPortPosition
}
CTRCommonNodeDefine.GetRouteIdFromEntity = {
	outPort = "routeId",
	inPort = {
		"entityId",
		"dayTime",
		"weatherId",
		"meteorologyId",
		"entityTag",
		"otherTag1",
		"otherTag2",
		"otherTag3"
	},
	outFunc = IBasePropertyComponent.getRouteIdFromEntity
}
CTRCommonNodeDefine.GetRouteIdFromEntitySimple = {
	outPort = "routeId",
	inPort = {
		"entityId"
	},
	outFunc = IBasePropertyComponent.getRouteIdFromEntitySimple
}
CTRCommonNodeDefine.GetSelfId = {
	outPort = "myActorId",
	inPort = {},
	outFunc = IBasePropertyComponent.getSelfId
}
CTRCommonNodeDefine.GetSkillProperty = {
	inPort = {
		"skillId",
		"$propertyName"
	},
	outFunc = IBasePropertyComponent.getSkillProperty
}
CTRCommonNodeDefine.GetSkillType = {
	inPort = {
		"abilityId"
	},
	outFunc = IBasePropertyComponent.getSkillType
}
CTRCommonNodeDefine.GetStaticId = {
	inPort = {
		"entityId"
	},
	outFunc = IUtilsComponent.getStaticId
}
CTRCommonNodeDefine.GetTargetBuffLayerCount = {
	inPort = {
		"entityActorId",
		"buffId"
	},
	outFunc = IBaseCombatComponent.getTargetBuffLayerCount
}
CTRCommonNodeDefine.IsChildOfCharState = {
	inPort = {
		"entityActorId",
		"$stateName"
	},
	outFunc = IUtilsComponent.isChildOfCharState
}
CTRCommonNodeDefine.IsChildOrTransitionOfCharState = {
	inPort = {
		"entityActorId",
		"$stateName"
	},
	outFunc = IUtilsComponent.isChildOrTransitionOfCharState
}
CTRCommonNodeDefine.IsControllingPet = {
	outPort = "result",
	inPort = {
		"playerId"
	},
	outFunc = IUtilsComponent.isControllingPet
}
CTRCommonNodeDefine.IsCurCombatPet = {
	outPort = "result",
	inPort = {
		"actorId"
	},
	outFunc = IUtilsComponent.isCurCombatPet
}
CTRCommonNodeDefine.IsEntityType = {
	inPort = {
		"target",
		"type"
	},
	outFunc = IUtilsComponent.isEntityType
}
CTRCommonNodeDefine.IsEthnicGroup = {
	outPort = "result",
	inPort = {
		"targetActorId",
		"ethnicGroupId"
	},
	outFunc = IUtilsComponent.isEthnicGroup
}
CTRCommonNodeDefine.IsInAnimState = {
	inPort = {
		"tgtId",
		"animStateName"
	},
	outFunc = IUtilsComponent.isInAnimState
}
CTRCommonNodeDefine.IsInBehavTag = {
	inPort = {
		"targetEntityActorId",
		"behavTag"
	},
	outFunc = IUtilsComponent.isInBehavTag
}
CTRCommonNodeDefine.IsInCatchMode = {
	inPort = {
		"entityId"
	},
	outFunc = IUtilsComponent.isInCatchMode
}
CTRCommonNodeDefine.IsInCrouch = {
	inPort = {
		"entityId"
	},
	outFunc = IUtilsComponent.isInCrouch
}
CTRCommonNodeDefine.IsInGroupBehaviour = {
	inPort = {
		"targetEntityActorId",
		"includePrepare",
		"$groupBehavName"
	},
	outFunc = IUtilsComponent.isInGroupBehaviour
}
CTRCommonNodeDefine.IsInMagnesisMode = {
	inPort = {
		"entityId"
	},
	outFunc = IUtilsComponent.isInMagnesisMode
}
CTRCommonNodeDefine.IsInPetBallExpAction = {
	inPort = {},
	outFunc = IUtilsComponent.isInPetBallExpAction
}
CTRCommonNodeDefine.IsInSelfieMode = {
	inPort = {},
	outFunc = IUtilsComponent.isInSelfieMode
}
CTRCommonNodeDefine.IsInSkill = {
	inPort = {
		"entityId",
		"skillId"
	},
	outFunc = IBaseCombatComponent.isInSkill
}
CTRCommonNodeDefine.IsInUltimateSkill = {
	inPort = {
		"entityId"
	},
	outFunc = IBaseCombatComponent.isInUltimateSkill
}
CTRCommonNodeDefine.IsOnWater = {
	inPort = {
		"tgtId",
		"heightRange"
	},
	outFunc = IVoxelComponent.isOnWater
}
CTRCommonNodeDefine.IsPlayerInCombat = {
	inPort = {
		"playerId"
	},
	outFunc = IBaseCombatComponent.isInCombat
}
CTRCommonNodeDefine.IsPlayerTwinPet = {
	inPort = {
		"petPrototypeId"
	},
	outFunc = IUtilsComponent.isPlayerTwinPet
}
CTRCommonNodeDefine.IsPuppetInCallFriend = {
	inPort = {
		"targetActorId"
	},
	outFunc = IUtilsComponent.isPuppetInCallFriend
}
CTRCommonNodeDefine.IsSameDayTime = {
	inPort = {
		"time1",
		"time2"
	},
	outFunc = IBaseOpComponent.isEqual
}
CTRCommonNodeDefine.IsSameSpecies = {
	inPort = {
		"targetEntityActorId",
		"sourceEntityActorId"
	},
	outFunc = IUtilsComponent.isSameSpecies
}
CTRCommonNodeDefine.IsTwinPet = {
	inPort = {
		"petPrototypeId"
	},
	outFunc = IUtilsComponent.isTwinPet
}
CTRCommonNodeDefine.GetBodyHeight = {
	inPort = {
		"targetActorId"
	},
	outFunc = IUtilsComponent.getBodyHeight
}
CTRCommonNodeDefine.CheckHasAbility = {
	inPort = {
		"targetActorId",
		"abilityTypeName"
	},
	outFunc = IUtilsComponent.checkHasAbility
}
CTRCommonNodeDefine.CheckIsCamouflage = {
	inPort = {
		"targetActorId"
	},
	outFunc = IBaseCombatComponent.checkIsCamouflage
}
CTRCommonNodeDefine.CheckIsDead = {
	inPort = {
		"tgtActorId"
	},
	outFunc = IBaseCombatComponent.checkIsDead
}
CTRCommonNodeDefine.CheckIsInCapture = {
	inPort = {
		"tgtActorId"
	},
	outFunc = IBaseCombatComponent.checkIsInCapture
}
CTRCommonNodeDefine.GetInteractEnvObj = {
	outPort = "interactActorId",
	inPort = {
		"tgtActorId"
	},
	outFunc = IBaseCombatComponent.getInteractEnvObj
}
CTRCommonNodeDefine.GetCurMeteorologyId = {
	outPort = "meteorologyId",
	inPort = {
		"targetActorId"
	},
	outFunc = IUtilsComponent.getCurMeteorologyId
}
CTRCommonNodeDefine.GetCurWeatherId = {
	outPort = "weatherId",
	inPort = {
		"targetActorId"
	},
	outFunc = IUtilsComponent.getCurWeatherId
}
CTRCommonNodeDefine.CheckIsInRangeTgt2D = {
	inPort = {
		"targetActorId",
		"rangeMin",
		"rangeMax",
		"noTgtBodySize",
		"noSelfBodySize"
	},
	outFunc = IMoveComponent.checkIsInRangeTgt2D
}

return CTRCommonNodeDefine
