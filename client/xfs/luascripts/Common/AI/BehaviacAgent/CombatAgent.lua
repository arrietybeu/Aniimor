-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\CombatAgent.lua

local Class = require("Core.Framework.Class")
local WxAgent = require("Common.AI.BehaviacAgent.WxAgent")
local AiConst = require("Common.Const.AiConst")
local sysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local BehaviorPathMapDataEnumMap = BehaviorPathMapData.EnumMap
local BehaviorPathMapDataEnumNameMap = BehaviorPathMapData.EnumNameMap
local CombatAgent = Class.Class("CombatAgent", WxAgent)
local IBaseCombatComponent = require("Common.AI.BehaviacAgent.Unit.IBaseCombatComponent")
local IBaseStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IBaseStateMachineComponent")
local CombatAgentUnits = {
	IBaseCombatComponent
}

Class.AddComponents(CombatAgent, CombatAgentUnits)

function CombatAgent:ctor()
	WxAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.CombatAgent
end

function CombatAgent:initBlackBoardProperties()
	CombatAgent.super.initBlackBoardProperties(self)

	local myEnt = self.ent
	local pdd = myEnt:getConfigData()

	self:setBlackBoardProperty("followMidDist", pdd.followMidDist or AiConst.FOLLOW_MID)
	self:setBlackBoardProperty("followFarDist", pdd.followFarDist or AiConst.FOLLOW_FAR)
	self:setBlackBoardProperty("followCloseDist", pdd.followCloseDist or AiConst.FOLLOW_CLOSE)
	self:setBlackBoardProperty("followTooCloseDist", pdd.followTooCloseDist or AiConst.FOLLOW_TOO_CLOSE)
	self:setBlackBoardProperty("followTeleportDist", pdd.followTeleportDist or AiConst.FOLLOW_TELEPORT)
	self:setBlackBoardProperty("canJumpBack", pdd.canJumpBack or false)
	self:setBlackBoardProperty("canWalkBack", pdd.canWalkBack or false)

	local patrolRange = myEnt.patrolRange or pdd.patrolRange or 0

	if Utils.isCreatePlenty(myEnt) then
		local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData()

		if emergenceOverrideData and emergenceOverrideData.patrolRange then
			patrolRange = emergenceOverrideData.patrolRange
		end
	end

	self:setBlackBoardProperty("patrolRange", patrolRange)
	self:setBlackBoardProperty("catchFailureLeaveTimeout", AiConst.CATCH_FAILURE_LEAVE_TIMEOUT)
	self:setBlackBoardProperty("tgt", 0)
	self:setBlackBoardProperty("skillId", 0)
	self:setBlackBoardProperty("attackWeight", 50)
	self:setBlackBoardProperty("sideWalkWeight", 50)
	self:setBlackBoardProperty("canWalkLeftOrRight", pdd.canWalkLeftOrRight or false)
	self:setBlackBoardProperty("distToTgt", 0)
	self:setBlackBoardProperty("distToTgtForSkill", 0)
	self:setBlackBoardProperty("battlestage", 0)

	if pdd.CombatReady_IsTurnToTarget ~= nil then
		self:setBlackBoardProperty("combatReadyIsTurnToTarget", pdd.CombatReady_IsTurnToTarget)
	else
		self:setBlackBoardProperty("combatReadyIsTurnToTarget", true)
	end

	if pdd.isCombatPrepareTrigger ~= nil then
		self:setBlackBoardProperty("isCombatPrepareTrigger", pdd.isCombatPrepareTrigger)
	else
		self:setBlackBoardProperty("isCombatPrepareTrigger", true)
	end

	local minBoxDist = sysConfigData.minBoxDist or 0

	self:setBlackBoardProperty("minBoxDist", minBoxDist)

	local maxKeepBoxDist = pdd.maxKeepBoxDist or 10

	self:setBlackBoardProperty("maxKeepBoxDist", maxKeepBoxDist)

	local minKeepBoxDist = minBoxDist + (maxKeepBoxDist - minBoxDist) * 0.2

	self:setBlackBoardProperty("minKeepBoxDist", minKeepBoxDist)

	local bestKeepBoxDist = minKeepBoxDist + (maxKeepBoxDist - minKeepBoxDist) * 0.6

	self:setBlackBoardProperty("bestKeepBoxDist", bestKeepBoxDist)
	self:onAbilityChange()
	self:setBlackBoardProperty("Param_ST_Idle", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("Param_ST_Alert", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("Param_ST_Sensed", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("Param_ST_Combat_Prepare", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Combat_Prepare_Default])
	self:setBlackBoardProperty("Param_ST_Born", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Behav_Com_Born])
	self:setBlackBoardProperty("Param_ST_GoHome", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.ST_GoHome])
	self:setBlackBoardProperty("Param_ST_AutoCombat", BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_AutoCombat])
end

function CombatAgent:onAbilityChange()
	local maxAttackDist = self:getMaxAttackDist(0)
	local minAttackDist = self:getMinAttackDist(0)

	self:setBlackBoardProperty("maxAttackDist", maxAttackDist)

	local attackStopBoxDist = minAttackDist + (maxAttackDist - minAttackDist) * 0.6

	self:setBlackBoardProperty("attackStopBoxDist", attackStopBoxDist)
	self:setBlackBoardProperty("minAttackDist", minAttackDist)
end

return CombatAgent
