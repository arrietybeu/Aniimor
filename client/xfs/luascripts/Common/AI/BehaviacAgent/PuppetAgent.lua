-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\PuppetAgent.lua

local Class = require("Core.Framework.Class")
local CombatAgent = require("Common.AI.BehaviacAgent.CombatAgent")
local IPuppetCombatComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetCombatComponent")
local IPuppetStateMachineComponent = require("Common.AI.BehaviacAgent.Unit.IPuppetStateMachineComponent")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local SceneUtils = require("Common.Utils.SceneUtils")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local PuppetData = require("Data.puppet_data")
local StringIsEmpty = string.notNilOrEmpty
local BehaviorPathMapDataEnumMap = BehaviorPathMapData.EnumMap
local BehaviorPathMapDataEnumNameMap = BehaviorPathMapData.EnumNameMap
local PuppetAgent = Class.Class("PuppetAgent", CombatAgent)
local PuppetAgentUnits = {
	IPuppetCombatComponent,
	IPuppetStateMachineComponent
}

Class.AddComponents(PuppetAgent, PuppetAgentUnits)

function PuppetAgent:ctor()
	CombatAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.PuppetAgent
end

function PuppetAgent:initBlackBoardProperties()
	PuppetAgent.super.initBlackBoardProperties(self)

	local myEnt = self.ent
	local pdd = myEnt:getConfigData()

	self:setBlackBoardProperty("attackWeight", pdd.attackWeight)
	self:setBlackBoardProperty("sideWalkWeight", pdd.sideWalkWeight)
	self:setBlackBoardProperty("canNotCombat", pdd.canNotCombat or false)
	self:setBlackBoardProperty("walkBackCd", pdd.goBackCd or AiConst.WALK_BACK_CD)
	self:setBlackBoardProperty("isBossAI", pdd.isBossAI or false)
	self:setBlackBoardProperty("Param_ST_AutoCombat", pdd.Param_ST_Monster_AutoCombat or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_AutoCombat])
	self:setBlackBoardProperty("Param_ST_GoHome", pdd.Param_ST_GoHome or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.ST_GoHome])
	self:setBlackBoardProperty("Param_ST_Combat_Prepare", pdd.Param_ST_Combat_Prepare or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Combat_Prepare_Default])

	local mySpace = myEnt.space
	local sceneEntityData = SceneUtils.getSceneEntityData(mySpace.sceneId, mySpace.id)
	local staticId = myEnt.staticId
	local staticData = sceneEntityData[staticId]
	local Param_ST_Idle

	if staticData and staticData.override_Param_ST_Idle then
		Param_ST_Idle = staticData.override_Param_ST_Idle
	else
		Param_ST_Idle = pdd.Param_ST_Idle
	end

	self:setBlackBoardProperty("Param_ST_Idle", BehaviorPathMapDataEnumNameMap[Param_ST_Idle] and Param_ST_Idle or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])

	local Param_ST_Alert

	if staticData and staticData.override_Param_ST_Alert then
		Param_ST_Alert = staticData.override_Param_ST_Alert
	else
		Param_ST_Alert = pdd.Param_ST_Alert
	end

	local Param_ST_Sensed

	if staticData and staticData.override_Param_ST_Sensed then
		Param_ST_Sensed = staticData.override_Param_ST_Sensed
	else
		Param_ST_Sensed = pdd.Param_ST_Sensed
	end

	if Utils.isCreatePlenty(myEnt) then
		local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData()

		if emergenceOverrideData then
			if StringIsEmpty(emergenceOverrideData.Param_ST_Alert) then
				Param_ST_Alert = emergenceOverrideData.Param_ST_Alert
			end

			if StringIsEmpty(emergenceOverrideData.Param_ST_Sensed) then
				Param_ST_Sensed = emergenceOverrideData.Param_ST_Sensed
			end
		end
	end

	self:setBlackBoardProperty("Param_ST_Alert", Param_ST_Alert or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("Param_ST_Sensed", Param_ST_Sensed or BehaviorPathMapDataEnumMap[BehaviorPathMapDataEnumNameMap.PBT_Noop])
	self:setBlackBoardProperty("fightCd", 0)
	self:setBlackBoardProperty("atkCd", 0)
	self:setBlackBoardProperty("skillCd", 0)
	self:setBlackBoardProperty("CounterInt_1", 0)
end

return PuppetAgent
