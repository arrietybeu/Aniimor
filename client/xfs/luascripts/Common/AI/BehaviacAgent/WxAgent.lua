-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\WxAgent.lua

local Class = require("Core.Framework.Class")
local BaseAgent = require("Common.AI.Behaviac.Agent.BaseAgent")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local VectorPool = require("Common.Container.VectorPool")
local ListPool = require("Common.Container.ListPool")
local WxAgent = Class.Class("WxAgent", BaseAgent)
local IAnimationComponent = require("Common.AI.BehaviacAgent.Unit.IAnimationComponent")
local IUtilsComponent = require("Common.AI.BehaviacAgent.Unit.IUtilsComponent")
local IFlyComponent = require("Common.AI.BehaviacAgent.Unit.IFlyComponent")
local IMoveComponent = require("Common.AI.BehaviacAgent.Unit.IMoveComponent")
local IVoxelComponent = require("Common.AI.BehaviacAgent.Unit.IVoxelComponent")
local IPhysicsComponent = require("Common.AI.BehaviacAgent.Unit.IPhysicsComponent")
local ISneakComponent = require("Common.AI.BehaviacAgent.Unit.ISneakComponent")
local IParmonPlanComponent = require("Common.AI.BehaviacAgent.Unit.IParmonPlanComponent")
local IMimicryComponent = require("Common.AI.BehaviacAgent.Unit.IMimicryComponent")
local IGroundComponent = require("Common.AI.BehaviacAgent.Unit.IGroundComponent")
local IResPointComponent = require("Common.AI.BehaviacAgent.Unit.IResPointComponent")
local IClimbComponent = require("Common.AI.BehaviacAgent.Unit.IClimbComponent")
local IPerceptibilityComponent = require("Common.AI.BehaviacAgent.Unit.IPerceptibilityComponent")
local IBaseOpComponent = require("Common.AI.BehaviacAgent.Unit.IBaseOpComponent")
local IBasePropertyComponent = require("Common.AI.BehaviacAgent.Unit.IBasePropertyComponent")
local ICameraComponent = require("Common.AI.BehaviacAgent.Unit.ICameraComponent")
local IHomeLandComponent = require("Common.AI.BehaviacAgent.Unit.IHomeLandComponent")
local SceneUtils = require("Common.Utils.SceneUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local WxAgentUnits = {
	IAnimationComponent,
	IUtilsComponent,
	IMoveComponent,
	IFlyComponent,
	IVoxelComponent,
	IPhysicsComponent,
	ISneakComponent,
	IParmonPlanComponent,
	IMimicryComponent,
	IGroundComponent,
	IResPointComponent,
	IClimbComponent,
	IPerceptibilityComponent,
	IBaseOpComponent,
	IBasePropertyComponent,
	ICameraComponent,
	IHomeLandComponent
}

Class.AddComponents(WxAgent, WxAgentUnits)

function WxAgent:ctor()
	BaseAgent.ctor(self)

	self.EAgentType = AiConst.EAgentType.WxAgent
end

function WxAgent:init(entity)
	BaseAgent.init(self, entity)

	self.ent = entity

	self:postComponentMethod("onInit")
	self:initBlackBoardProperties()
end

function WxAgent:release()
	self:setBlackBoardProperty("partnerIds", nil)
	self:setBlackBoardProperty("bornPos", nil)
	BaseAgent.release(self)

	self.ent = nil
end

function WxAgent:initBlackBoardProperties()
	local myEnt = self.ent

	self:setBlackBoardProperty("selfId", myEnt.actorId)
	self:setBlackBoardProperty("patrolWeight", 50)
	self:setBlackBoardProperty("leaderId", 0)
	self:setBlackBoardProperty("partnerIds", {})
	self:setBlackBoardProperty("followTarget", 0)

	local pdd = myEnt:getConfigData()
	local entityData

	if myEnt.space and myEnt.staticId then
		entityData = SceneUtils.getSceneEntityData(myEnt.space.sceneId, myEnt.space.id)[myEnt.staticId]
	end

	local idleMotionState = entityData and entityData.spawnerIdleMotionState or pdd.IdleMotionState or CharacterStateConst[CharacterStateConst.LOCOMOTION].name

	if Utils.isCreatePlenty(myEnt) then
		local emergenceOverrideData = Utils.getPuppetEmergenceOverrideData()

		if emergenceOverrideData and string.notNilOrEmpty(emergenceOverrideData.bornState) then
			idleMotionState = emergenceOverrideData.bornState
		end
	end

	self:setBlackBoardProperty("IdleMotionState", idleMotionState)
	self:setBlackBoardProperty("AI_IdleSpecialProb", entityData and entityData.spawnerIdleSpecialProb or pdd.AI_IdleSpecialProb or 0)
	self:setBlackBoardProperty("testC", 1)
	self:setBlackBoardProperty("bornPos", myEnt:getPosition())
end

return WxAgent
