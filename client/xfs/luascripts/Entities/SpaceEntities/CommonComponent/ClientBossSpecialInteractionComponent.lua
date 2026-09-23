-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientBossSpecialInteractionComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CTRPool = require("Common.AICt.CTRPool")
local ClientBossSpecialInteractionComponent = Class.Component("ClientBossSpecialInteractionComponent")

function ClientBossSpecialInteractionComponent:ctor()
	return
end

function ClientBossSpecialInteractionComponent:isInSpecialRidden()
	return self.isSpecialRidden
end

function ClientBossSpecialInteractionComponent:RPC_SC_OnBossEnterSpecialRideMode(riderActorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnBossEnterSpecialRideMode", riderActorId)
	end

	self:playAnimation(PlayableConst.Riding_Fly_Loop)

	local context = CTRPool.getContext()

	context.tFlyCenterPos = self.bornPosition

	AIControllerUtils.sendAIEvent(self, "Msg_EnterSpecialRidden", context)
end

function ClientBossSpecialInteractionComponent:RPC_SC_OnBossSpecialRideModeSuccess(riderActorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnBossSpecialRideModeSuccess", riderActorId)
	end

	self.isBossSpecialBreakFall = true

	local riderEntity = pg.getEntityByActorId(riderActorId)

	if riderEntity.characterState == CharacterStateConst.SPECIALRIDECLIMBON then
		AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
	else
		AnimationUtils.playAnimationState(riderEntity, CharacterStateConst.SPECIALRIDEBREAKSUCCESS)
	end

	riderEntity:exitSpecialRideMode()
end

function ClientBossSpecialInteractionComponent:RPC_SC_OnBossSpecialRideModeFailed(riderActorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OnBossSpecialRideModeFailed", riderActorId)
	end

	self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_BOSS_SPECIAL_LAND, PlayableConst.Break_Fail)

	local riderEntity = pg.getEntityByActorId(riderActorId)

	AnimationUtils.playAnimationState(riderEntity, CharacterStateConst.SPECIALRIDEBREAKFAIL)
	riderEntity:exitSpecialRideMode()
end

return ClientBossSpecialInteractionComponent
