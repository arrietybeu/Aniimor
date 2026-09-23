-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientStateCheckComponent.lua

local Lume = require("Core.Common.lume")
local ConflictTypes = require("Common.ConflictTypes")
local class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local StateCheckComponent = require("Common.Components.StateCheckComponent")
local CharacterStateConstImp = require("Common.Const.CharacterStateConstImp")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local PetConfigData = require("Data.pet_config_data")
local SysConfigData = require("Data.sys_config_data")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientConst = require("Const.ClientConst")
local TriggerConst = require("Common.Const.TriggerConst")
local UIConst = require("Const.UIConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local CommonSwitch = require("Common.CommonSwitch")
local ClientStateCheckComponent = class.Component("ClientStateCheckComponent", StateCheckComponent)

function ClientStateCheckComponent:ctor()
	ClientStateCheckComponent.super.ctor(self)

	self.blockAttackTime = 0
end

function ClientStateCheckComponent:checkMove()
	local ignoreStates = self:HIT_BACKSWING_ST() and AbilityConst.SKILL_HIT_BACK_SWING_IGNORE_STS
	local ret = self:checkStatus(ConflictTypes.CT_MOVE, true, ignoreStates)

	return ret
end

function ClientStateCheckComponent:checkSkillState(skillId, showMsg, noCancel)
	if not ToBool(skillId) then
		return false
	end

	local aData = pg.global.abilityMgr:getAbilityTemplate(skillId, 1)
	local cType = ConflictTypes.CT_SKILL

	if aData.abilityType == AbilityConst.EnumAbilityType.Attack then
		cType = ConflictTypes.CT_ATTACK
	elseif aData.abilityType == AbilityConst.EnumAbilityType.Ultimate then
		cType = ConflictTypes.CT_ULTIMATE
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)
	local stateCheckExclude = abilityParamData.stateCheckExclude or {}
	local exclude = {}

	if ToBool(aData.isGhostEye) then
		exclude[ConflictTypes.PET_SPECIAL_VISION_ST] = true
	end

	for _, stateExclude in ipairs(stateCheckExclude) do
		exclude[stateExclude] = true
	end

	if self:HIT_BACKSWING_ST() then
		for state, _ in pairs(AbilityConst.SKILL_HIT_BACK_SWING_IGNORE_STS) do
			exclude[state] = true
		end
	end

	if self.cancelAbilityByAbilityIdList[skillId] then
		for stat, _ in pairs(AbilityConst.SKILL_CANCELLABLE_IGNORE_STS) do
			exclude[stat] = true
		end
	end

	if cType == ConflictTypes.CT_ATTACK and self.characterState == CharacterStateConst.DASH and self:getGameTime() < self.attackBlockTime then
		return false
	end

	if not self:checkStatus(cType, showMsg, exclude, noCancel, nil, exclude) then
		return false
	end

	return true
end

function ClientStateCheckComponent:checkJump()
	local excludeCancel

	if self.characterState == CharacterStateConst.SPEEDBURSTSTART or self.characterState == CharacterStateConst.SPEEDBURSTLOOP or self.characterState == CharacterStateConst.SPEEDBURSTFALL or self.characterState == CharacterStateConst.SPEEDBURSTJUMP then
		excludeCancel = {
			SPEED_BURST_ST = true
		}
	end

	local ret = self:checkStatus(ConflictTypes.CT_JUMP, nil, nil, nil, excludeCancel)

	return ret
end

function ClientStateCheckComponent:checkEnterAfk()
	if not self.space or not self.space:canEnterAfk() then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_ENTER_AFK)

	return ret and not ClientUtils.isFullScreenUI() and not self:isInCombat() and self.isInControl
end

function ClientStateCheckComponent:checkEnterAfkActionState()
	if not self.space or not self or self.space.isMultiPlayerEnv and not self.space:isMultiPlayerEnv() then
		return false
	end

	return not self:isInCombat() and not ClientUtils.isFullScreenUI()
end

function ClientStateCheckComponent:checkEnterAfkStateConflict()
	return self:checkStatus(ConflictTypes.CT_ENTER_AFK)
end

function ClientStateCheckComponent:AFK_ST()
	local cameraMode = pg.game and pg.game.camera and pg.game.camera.playerCameraMode

	return cameraMode and cameraMode.inAfk or false
end

function ClientStateCheckComponent:checkStaySocialAnim()
	local ret = self:checkStatus(ConflictTypes.CT_SOCIAL_ANIM)

	return ret
end

function ClientStateCheckComponent:SOCIAL_ANIM_ST()
	local player = pg.me
	local eModel = player and player.eModel

	return eModel and eModel.InSocialAnim or false
end

function ClientStateCheckComponent:SOCIAL_INTERACT_ACTION_ST()
	local ret = false

	if self.singleActionState and self.singleActionState > 0 then
		ret = true
	end

	if self.friendInteractAction and self.friendInteractAction.actionId > 0 then
		ret = true
	end

	if self.multiInteractAction and self.multiInteractAction.actionId > 0 then
		ret = true
	end

	return ret
end

function ClientStateCheckComponent:_cancel_SOCIAL_INTERACT_ACTION_ST()
	if self.isMainPlayer then
		if self.singleActionState and self.singleActionState > 0 then
			self:playSingleAction(0)
		end

		if self.friendInteractAction and self.friendInteractAction.actionId > 0 then
			self:exitFriendAction()
		end

		if self.multiInteractAction and self.multiInteractAction.actionId > 0 then
			self:exitMultiAction()
		end
	end
end

function ClientStateCheckComponent:DUNGEON_MATCHING_ST()
	local player = pg.me

	return player and (player.matchState == Const.PLAYER_MATCH_STATUS.MATCH_TEAM or player.matchState == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON)
end

function ClientStateCheckComponent:checkInviteFriendNear()
	local ret = self:checkStatus(ConflictTypes.CT_INVITE_FRIEND_NEAR, true)

	return ret
end

function ClientStateCheckComponent:_cancel_SOCIAL_ANIM_ST()
	local eModel = self.eModel

	if self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		eModel.InSocialAnim = false
	end
end

function ClientStateCheckComponent:checkSprint()
	local ret = self:checkStatus(ConflictTypes.CT_SPRINT)

	return ret
end

function ClientStateCheckComponent:checkDead()
	local ret = self:checkStatus(ConflictTypes.CT_DEAD)

	if ret and self == pg.me and pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui:close(UIConst.UI_ID_PHOTO)
	end

	return ret
end

function ClientStateCheckComponent:checkFallen()
	local ret = self:checkStatus(ConflictTypes.CT_ENTER_FALLEN)

	if ret and self == pg.me and pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui:close(UIConst.UI_ID_PHOTO)
	end

	return ret
end

function ClientStateCheckComponent:SPEEDBURST_DASH_BLOCK_ST()
	return self.characterState == CharacterStateConst.SPEEDBURSTJUMP
end

function ClientStateCheckComponent:checkDash(showLog, ignoreCancelStates)
	showLog = showLog ~= nil and showLog or false

	if self:SPEEDBURST_DASH_BLOCK_ST() then
		return false
	end

	if not pg.me:checkStaminaCost(TagMask.None, TagMask.Dash) then
		return false
	end

	local ignoreStates

	if self:CANCELLABLE_ST() then
		ignoreStates = AbilityConst.SKILL_CANCELLABLE_IGNORE_STS
	elseif self:HIT_BACKSWING_ST() then
		ignoreStates = AbilityConst.SKILL_HIT_BACK_SWING_IGNORE_STS
	end

	local ret = self:checkStatus(ConflictTypes.CT_DASH, showLog, ignoreStates, nil, ignoreCancelStates)

	return ret
end

function ClientStateCheckComponent:checkFall()
	local ret = self:checkStatus(ConflictTypes.CT_FALL)

	return ret
end

function ClientStateCheckComponent:checkCrouch()
	local ret = self:checkStatus(ConflictTypes.CT_CROUCH)

	return ret
end

function ClientStateCheckComponent:checkTeleport()
	return self:checkStatus(ConflictTypes.CT_TELEPORT)
end

function ClientStateCheckComponent:checkClimbAcross()
	return self:checkStatus(ConflictTypes.CT_CLIMB_ACROSS)
end

function ClientStateCheckComponent:checkStepAcrossInAir()
	local r = self:checkStatus(ConflictTypes.CT_STEP_ACROSS_IN_AIR, false, nil, true)

	return r
end

function ClientStateCheckComponent:checkNormalAttack()
	if not self:checkStatus(ConflictTypes.CT_ATTACK) then
		return false
	end

	return true
end

function ClientStateCheckComponent:checkClimb(noCancel)
	local ret = self:checkStatus(ConflictTypes.CT_CLIMB, false, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkGlide(noCancel)
	local ret = self:checkStatus(ConflictTypes.CT_GLIDE, false, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkSwim(noCancel)
	local ret = self:checkStatus(ConflictTypes.CT_SWIM, false, AbilityConst.SWIM_IGNORE_BUFF_CONTROL_ST, noCancel)

	return ret
end

function ClientStateCheckComponent:checkChangeMeleeWeapon()
	if not self:checkStatus(ConflictTypes.CT_CHANGE_MELEE_WEAPON) then
		return false
	end

	return true
end

function ClientStateCheckComponent:checkQuickCatch(noCancel)
	if self.isInQuickCapture and self:isInQuickCapture() then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_QUICK_CATCH, true, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkControlPet(excludeStates)
	if self:isForbidControlPet() then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_CONTROL_PET, true, excludeStates)

	return ret
end

function ClientStateCheckComponent:checkBeControlPet()
	local ret = self:checkStatus(ConflictTypes.CT_BE_CONTROL_PET, true)

	return ret
end

function ClientStateCheckComponent:checkStopControlPet(exclude)
	local ret = self:checkStatus(ConflictTypes.CT_STOP_CONTROL_PET, true, exclude)

	return ret
end

function ClientStateCheckComponent:checkBeStopControlPet(exclude)
	local ret = self:checkStatus(ConflictTypes.CT_BE_STOP_CONTROL_PET, true, exclude)

	return ret
end

function ClientStateCheckComponent:checkExploreControlPet(noCancel, showLog)
	local lastSeamlessSwitchTime = pg.game.seamless.lastSeamlessSwitchTime

	if lastSeamlessSwitchTime and Time.realSecondCache < lastSeamlessSwitchTime + 2 then
		return false
	end

	if self:isForbidControlPet() then
		return false
	end

	if self:isControllingSupportPet() then
		return false
	end

	if self:RIDING_ST() then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_EXPLORE_CONTROL_PET, showLog, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkExploreBeControlPet(noCancel, showLog)
	local ret = self:checkStatus(ConflictTypes.CT_EXPLORE_BE_CONTROL_PET, showLog, AbilityConst.CONTROL_BUFF_STS, noCancel)

	return ret
end

function ClientStateCheckComponent:checkExploreDelayExit(noCancel, showLog)
	local ret = self:checkStatus(ConflictTypes.CT_DELAY_CANCEL_SWITCH, showLog, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkExploreStopControlPet(noCancel, showLog)
	local ret = self:checkStatus(ConflictTypes.CT_EXPLORE_STOP_CONTROL_PET, showLog, AbilityConst.CONTROL_BUFF_STS, noCancel)

	return ret
end

function ClientStateCheckComponent:checkExploreBeStopControlPet(noCancel, showLog)
	local ret = self:checkStatus(ConflictTypes.CT_EXPLORE_BE_STOP_CONTROL_PET, showLog, AbilityConst.CONTROL_BUFF_STS, noCancel)

	return ret
end

function ClientStateCheckComponent:checkDungeonMatching(noCancel, showLog)
	local ret = self:checkStatus(ConflictTypes.DUNGEON_MATCHING, showLog, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkSwitchPetCD(index)
	local now = Time.secondCache

	if now <= self.switchPetEndCDs[index] then
		return false
	end

	return true
end

function ClientStateCheckComponent:checkSwitchPetReasonForce(inputEvent)
	return inputEvent >= Const.EVENT_RESET
end

function ClientStateCheckComponent:checkSwitchPetCostEnough(showMsg, inputEvent)
	if self.gmMode == Const.NO_COST_MODE then
		return true
	end

	if self:checkSwitchPetReasonForce(inputEvent) then
		return true
	end

	local inCombat = self:isInCombat()
	local isInControl = self:isControllingPet()

	return true
end

function ClientStateCheckComponent:checkSwitchPet(index, showMsg, inputEvent)
	if self:CARRY_EGG_ST() then
		pg.global.showBubbleMessage(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return false
	end

	if not self:checkSwitchPetCostEnough(showMsg, inputEvent) then
		return false
	end

	if inputEvent ~= Const.EVENT_SHOW_PET_QTE and inputEvent ~= Const.EVENT_SHOW_PET_BY_EVENT then
		if self.actorBuff:hasTag(AbilityConst.BUFF_TAG_FORBIDDEN_SWITCH_PET) or self:getCurPetEntity() and self:getCurPetEntity().actorBuff:hasTag(AbilityConst.BUFF_TAG_FORBIDDEN_SWITCH_PET) then
			if showMsg then
				pg.global.showBubbleMessage(NoticeDef.FORBIDDEN_SWITCH_PET)
			end

			return false
		end

		if not self:checkSwitchPetCD(index) and self.switchPetForceMaxCount > 0 then
			if self.switchPetForceCount <= 0 then
				ClientUtils.showBubbleMessage(NoticeDef.FORCE_SWITCH_PET_CNT_ZERO)

				return false
			end

			if Time.realSecondCache - (self.lastSwitchPetForceTime or 0) < (PetConfigData.switchPetForceInterval or 1) then
				ClientUtils.showBubbleMessage(NoticeDef.FORCE_SWITCH_PET_INNER_CD)

				return false
			end
		end
	end

	local entityConfigData = Utils.getEntityConfigData(self)
	local switchPetExclude = {}

	if entityConfigData.switchPetExclude then
		for stat, value in pairs(entityConfigData.switchPetExclude) do
			switchPetExclude[stat] = value
		end
	end

	if self:ABILITY_ST() and self:isAbilityCanSwitchPet() then
		for stat, _ in pairs(AbilityConst.SKILL_CANCELLABLE_IGNORE_STS) do
			switchPetExclude[stat] = true
		end
	end

	if pg.pawn:HIT_BACKSWING_ST() then
		for stat, _ in pairs(AbilityConst.SKILL_HIT_BACK_SWING_IGNORE_STS) do
			switchPetExclude[stat] = true
		end
	end

	local ret = self:checkStatus(ConflictTypes.CT_SWITCH_PET, showMsg, switchPetExclude)

	if ret and self:isControllingPet() and inputEvent ~= Const.EVENT_SHOW_PET_QTE then
		ret = self:getCurPetEntity():checkStatus(ConflictTypes.CT_SWITCH_PET, showMsg, switchPetExclude)
	end

	if ret then
		self:_cancel_KNOCK_UP_ST()
	end

	return ret
end

function ClientStateCheckComponent:checkEnterCatchMode(showMsg, exclude)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.BallAndItem) then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_ENTER_CATCH_MODE, showMsg, exclude)

	return ret
end

function ClientStateCheckComponent:checkInteractNpc(showMsg, noCancel)
	local ret = self:checkStatus(ConflictTypes.CT_INTERACT_NPC, showMsg, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkDialogue(showMsg, noCancel)
	local ret = self:checkStatus(ConflictTypes.CT_START_DIALOGUE, showMsg, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkInteract(showMsg, noCancel, exlcude)
	local ret = self:checkStatus(ConflictTypes.CT_INTERACT, showMsg, exlcude, noCancel)

	return ret
end

function ClientStateCheckComponent:checkAutoInteract(showMsg, noCancel, exclude)
	local ret = self:checkStatus(ConflictTypes.CT_AUTO_INTERACT, showMsg, exclude, noCancel)

	return ret
end

function ClientStateCheckComponent:checkCanPlayInteractAnim(isCancelVersion, showMsg, noCancel, exclude)
	if isCancelVersion then
		return self:checkStatus(ConflictTypes.CT_INTERACT_PLAY_ANIM_CANCEL, showMsg, exclude, noCancel)
	else
		return self:checkStatus(ConflictTypes.CT_INTERACT_PLAY_ANIM_BLOCK, showMsg, exclude, noCancel)
	end
end

function ClientStateCheckComponent:checkCanChangeLocationBeforeInteract(isCancelVersion, showMsg, noCancel, exclude)
	if isCancelVersion then
		return self:checkStatus(ConflictTypes.CT_INTERACT_LOCATION_CHANGE_CANCEL, showMsg, exclude, noCancel)
	else
		return self:checkStatus(ConflictTypes.CT_INTERACT_LOCATION_CHANGE_BLOCK, showMsg, exclude, noCancel)
	end
end

function ClientStateCheckComponent:checkCanChangeModelBeforeInteract(isCancelVersion, showMsg, noCancel, exclude)
	if isCancelVersion then
		return self:checkStatus(ConflictTypes.CT_INTERACT_MODEL_CHANGE_CANCEL, showMsg, exclude, noCancel)
	else
		return self:checkStatus(ConflictTypes.CT_INTERACT_MODEL_CHANGE_BLOCK, showMsg, exclude, noCancel)
	end
end

function ClientStateCheckComponent:checkEnterBossCapture(showMsg, exclude)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.BallAndItem) then
		return false
	end

	local ret = self:checkStatus(ConflictTypes.CT_ENTER_BOSS_CAPTURE, showMsg, exclude)

	return ret
end

function ClientStateCheckComponent:CONTROLLING_PET_ST()
	if self.isControllingPet and self:isControllingPet() then
		return true
	elseif Utils.isPet(self) then
		local masterEnt = self.getMasterEntity and self:getMasterEntity()

		if masterEnt and masterEnt.isControllingPet and masterEnt:isControllingPet() then
			return masterEnt.checkInControllingPet and masterEnt:checkInControllingPet(self) or false
		end
	end

	return false
end

function ClientStateCheckComponent:RIDING_ST()
	local characterState = self.characterState

	return CharacterStateConst.isChildOfState(characterState, CharacterStateConst.MOUNTING) or self.seatId and self.seatId > 0 or self.pendingVehicleMount
end

function ClientStateCheckComponent:WEAPON_ATTACH_ST()
	return self.weaponState == Const.WEAPON_STATE_ATTACH
end

function ClientStateCheckComponent:NEXT_SKILL_ST()
	if self == pg.pawn then
		local controller = pg.game and pg.game.controller
		local nextSkillAction = controller and controller.nextSkillAction

		return nextSkillAction and nextSkillAction.nextSkillId or false
	else
		return false
	end
end

function ClientStateCheckComponent:FALL_ST()
	if self.eModel and self.eModel:IsCommandPerformed(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Jump) then
		return true
	end

	local characterState = self.fakeConflictCheckState or self.characterState

	if self == pg.me and self.isControllingPet and self:isControllingPet() then
		local pet = self.getCurPetEntity and self:getCurPetEntity()

		if pet then
			characterState = pet.characterState
		end
	end

	return CharacterStateConst.isChildOfState(characterState, CharacterStateConst.AIRING) or characterState == CharacterStateConst.SPEEDBURSTJUMP or characterState == CharacterStateConst.INFLATEDASH
end

function ClientStateCheckComponent:SPRINT_ST()
	local characterState = self.fakeConflictCheckState or self.characterState

	return characterState == CharacterStateConst.SPRINT
end

function ClientStateCheckComponent:DASH_ST()
	local characterState = self.fakeConflictCheckState or self.characterState

	if characterState == CharacterStateConst.DASH then
		return true
	end

	if self.eModel and self.eModel:IsCommandPerformed(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Dash) then
		return true
	end

	return false
end

function ClientStateCheckComponent:CLIMB_ST()
	local characterState = self.characterState

	if self == pg.me and self.isControllingPet and self:isControllingPet() then
		local pet = self.getCurPetEntity and self:getCurPetEntity()

		if pet then
			characterState = pet.characterState
		end
	end

	return CharacterStateConst.isChildOfState(characterState, CharacterStateConst.CLIMBING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.CLIMBWATERFALL)
end

function ClientStateCheckComponent:CLIMB_ACROSS_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.CLIMBACROSS)
end

function ClientStateCheckComponent:GLIDE_ST()
	local characterState = self.characterState

	if self == pg.me and self.isControllingPet and self:isControllingPet() then
		local pet = self.getCurPetEntity and self:getCurPetEntity()

		if pet then
			characterState = pet.characterState
		end
	end

	return CharacterStateConst.isChildOfState(characterState, CharacterStateConst.GLIDING)
end

function ClientStateCheckComponent:MOVE_STOP_ST()
	local characterState = self.characterState

	return characterState == CharacterStateConst.DASHSTOP or characterState == CharacterStateConst.RUNSTOP or characterState == CharacterStateConst.SPRINTSTOP
end

function ClientStateCheckComponent:PATHFINDING_ST()
	return AutoPathFindUtils.isAutoPathFinding(self)
end

function ClientStateCheckComponent:CONTROL_ENT_ST()
	return self.controlState == Const.CONTROL_STATE_CONTROL
end

function ClientStateCheckComponent:TRIVIAL_ACTION_ST()
	return self.curTrivialAnim and self:isAnimationPlaying(self.curTrivialAnim)
end

function ClientStateCheckComponent:TRIVIAL_UPPER_ACTION_ST()
	return self.curUpperTrivialAnim and self:isAnimationPlaying(self.curUpperTrivialAnim)
end

function ClientStateCheckComponent:STRUGGLE_ST()
	return self.characterState == CharacterStateConst.STRUGGLE
end

function ClientStateCheckComponent:FORCE_DISPLACEMENT_ST()
	local data = rawget(self, "forceDisplacementData")

	return data ~= nil and not data.notBlockInput
end

function ClientStateCheckComponent:FORCE_DISPLACEMENT_NOT_BLOCK_INPUT_ST()
	local data = rawget(self, "forceDisplacementData")

	return data ~= nil and data.notBlockInput
end

function ClientStateCheckComponent:HIDE_ST()
	return not self.active or not self.visible
end

function ClientStateCheckComponent:CATCH_MODE_ST()
	return self.isInCatchMode and self:isInCatchMode()
end

function ClientStateCheckComponent:IN_BALL_ST()
	return self.isTrapped
end

function ClientStateCheckComponent:CROUCH_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.CROUCHING)
end

function ClientStateCheckComponent:PLAY_ANIMATION_SCRIPT_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.PLAYANIMATIONSCRIPT)
end

function ClientStateCheckComponent:MAGNESIS_THROW_ST()
	return self.characterState == CharacterStateConst.MAGNESISTHROW
end

function ClientStateCheckComponent:MAGNESIS_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.MAGNESIS)
end

function ClientStateCheckComponent:MAGNESIS_READY_ST()
	return self.isMagnesisReady and self:isMagnesisReady()
end

function ClientStateCheckComponent:MAGNESIS_GRABBING_ST()
	return self.characterState == CharacterStateConst.MAGNESISGRABIDLE or self.characterState == CharacterStateConst.MAGNESISGRABWALK
end

function ClientStateCheckComponent:CARRY_EGG_ST()
	if self.eModel then
		local carrayItemInt = self.eModel.carrayItemInt

		return carrayItemInt == Const.ROB_EGG_TYPE.SMALL or carrayItemInt == Const.ROB_EGG_TYPE.BIG
	else
		return false
	end
end

function ClientStateCheckComponent:SEGG_ST()
	if self.eModel then
		return self.eModel.carrayItemInt == Const.ROB_EGG_TYPE.SMALL
	else
		return false
	end
end

function ClientStateCheckComponent:BEGG_ST()
	if self.eModel then
		return self.eModel.carrayItemInt == Const.ROB_EGG_TYPE.BIG
	else
		return false
	end
end

function ClientStateCheckComponent:FAST_CARRY_EGG_ST()
	return self.isInFastCarryEggState or false
end

function ClientStateCheckComponent:FIRST_AID_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.AID)
end

function ClientStateCheckComponent:DIG_EGG_ST()
	local qte = pg.game and pg.game.qte
	local isPlayingDigEggQte = qte and qte.isPlayingDigEggQte and qte:isPlayingDigEggQte() or false

	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.DIGEGG) or isPlayingDigEggQte
end

function ClientStateCheckComponent:EGG_MAN_ST()
	return self.isDeformToEggMan and self:isDeformToEggMan()
end

function ClientStateCheckComponent:QTE_ST()
	local qte = pg.game and pg.game.qte

	return qte and qte.isQtePlaying and qte:isQtePlaying() or false
end

function ClientStateCheckComponent:PUSH_ST()
	return self.isPushing and self:isPushing()
end

function ClientStateCheckComponent:EXPLORE_SWITCH_ST()
	if self.isMainPlayer then
		return self.isControllingExploreEnt and self:isControllingExploreEnt() or false
	end

	if Utils.isPet(self) then
		local masterEnt = self.getMasterEntity and self:getMasterEntity()

		if masterEnt then
			return masterEnt.isControllingExploreEnt and masterEnt:isControllingExploreEnt() or false
		end
	end

	return false
end

function ClientStateCheckComponent:EXPLORE_DELAY_CANCEL_SWITCH_ST()
	local controller = pg.game and pg.game.controller

	if controller and controller.isInDelayExit and controller:isInDelayExit() then
		return true
	end

	return false
end

function ClientStateCheckComponent:PET_PROTECTED_ST()
	return Utils.isPet(self) and self.isPetAbilityProtected
end

function ClientStateCheckComponent:SCENT_TRACKING_ST()
	return self.isInScentTrackReadyState and self:isInScentTrackReadyState()
end

function ClientStateCheckComponent:INTERACT_ST()
	if self:LEVEL_INTERACT_ST() then
		return true
	end

	return ClientStateCheckComponent.super.INTERACT_ST(self)
end

function ClientStateCheckComponent:LEVEL_INTERACT_ST()
	return self.inLevelInteract or false
end

function ClientStateCheckComponent:REVIVE_ST()
	if self.characterState ~= CharacterStateConst.REVIVE then
		return false
	end

	if self.active and self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		local reviveStateDuration = SysConfigData.reviveStateDuration or 1.3

		return reviveStateDuration >= self.eModel.curCharacterStateTime
	end

	return false
end

function ClientStateCheckComponent:PAINT_AREA_CAM_ST()
	local cameraMode = pg.game and pg.game.camera and pg.game.camera.playerCameraMode

	if not cameraMode or not cameraMode.paintAreaCamera then
		return false
	end

	return cameraMode.paintAreaCamera.isActive and cameraMode.paintAreaCamera:isActive() or false
end

function ClientStateCheckComponent:BOSS_CAPTURE_ST()
	if self ~= pg.me or not self.isInBossCatch then
		return false
	end

	return self:isInBossCatch()
end

function ClientStateCheckComponent:LATERAL_ATTACK_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.LATERALATTACK)
end

function ClientStateCheckComponent:STATICSPAWN_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.STATICSPAWN)
end

function ClientStateCheckComponent:check_cancel_CROUCH_ST()
	if self.eModel:OriginalCapsuleOverlapWithIgnoreLayers(Const.COMPONENT_MOTION) then
		pg.global.showBubbleMessageById(NoticeDef.CANNOT_SWITCH_BY_INSUFFICIENT_SPACE)

		return false
	end

	return true
end

function ClientStateCheckComponent:_backToDefault()
	if self.eModel then
		self.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0, 0, 0)
	end

	self:changeToState(CharacterStateConst.IDLE)
end

function ClientStateCheckComponent:_cancel_SPRINT_ST()
	if self:SPRINT_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_DASH_ST()
	if self:DASH_ST() then
		if self.eModel then
			self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Dash, false)
			self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.DashMark, false)
		end

		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_MOVE_STOP_ST()
	if self:MOVE_STOP_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_CLIMB_ST()
	if self:CLIMB_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_CLIMB_ACROSS_ST()
	if self:CLIMB_ACROSS_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_GLIDE_ST()
	if self:GLIDE_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_SWIM_ST()
	if self:SWIM_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_COMBAT_ST()
	return
end

function ClientStateCheckComponent:_cancel_HUG_ENT_ST()
	if not self.isMainPlayer then
		return
	end

	local player = self

	if player.carryType == Const.CARRY_TYPE.PET then
		local carryEnt = player.carryEnt
		local curPet = player:getCurPetEntity()

		if carryEnt == curPet or Utils.isHomePet(carryEnt) then
			player:putDownCarryEnt()
		else
			player:putBackPet()
		end
	elseif player.carryType == Const.CARRY_TYPE.ITEM then
		player:tryPutInItem()
	end
end

function ClientStateCheckComponent:_cancel_WEAPON_ATTACH_ST()
	if self.weaponState == Const.WEAPON_STATE_ATTACH then
		self:changeWeaponState(Const.WEAPON_STATE_HANGUP)
	end
end

function ClientStateCheckComponent:_cancel_NEXT_SKILL_ST()
	if self:NEXT_SKILL_ST() then
		pg.game.controller.nextSkillAction:clearNextSkill()
	end
end

function ClientStateCheckComponent:_cancel_TRIVIAL_ACTION_ST()
	if self:TRIVIAL_ACTION_ST() then
		self:stopAnimation(self.curTrivialAnim)

		self.curTrivialAnim = nil

		if self.setStateCacheValue then
			self:setStateCacheValue("TRIVIAL_ACTION_ST", false)
		end
	end
end

function ClientStateCheckComponent:_cancel_TRIVIAL_UPPER_ACTION_ST()
	if self:TRIVIAL_UPPER_ACTION_ST() then
		self:stopAnimation(self.curUpperTrivialAnim)

		self.curUpperTrivialAnim = nil

		if self.setStateCacheValue then
			self:setStateCacheValue("TRIVIAL_UPPER_ACTION_ST", false)
		end
	end
end

function ClientStateCheckComponent:_cancel_LIFT_ST()
	if self:LIFT_ST() then
		self:unLiftEntity(true)
	end
end

function ClientStateCheckComponent:_cancel_INTERACT_ST()
	if self:INTERACT_ST() then
		self:cancelInteract()
	end
end

function ClientStateCheckComponent:_cancel_MULTI_INTERACT_ST()
	if self:MULTI_INTERACT_ST() then
		self:cancelLevelItemInteractState()
	end
end

function ClientStateCheckComponent:_cancel_HOME_INTERACT_ST()
	if self:HOME_INTERACT_ST() then
		self:cancelHomeInteractState()
	end
end

function ClientStateCheckComponent:checkCanCancelUltimate(event)
	if (event == ConflictTypes.CT_FALL or event == ConflictTypes.CT_SWIM) and AbilityUtils.isUltimateAbility(self:getCastingAbilityId()) then
		return false
	end

	return true
end

function ClientStateCheckComponent:_cancel_ABILITY_ST(event)
	if self:ABILITY_ST() and self:checkCanCancelUltimate(event) then
		if self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_SKILL_ST(event)
	if self:SKILL_ST() then
		if self.stopAnimationByTag and event == ConflictTypes.CT_JUMP then
			self:stopAnimationByTag(TagMask.Skill, 0)
		elseif self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_ATTACK_ST(event)
	if self:ATTACK_ST() then
		if self.stopAnimationByTag and (event == ConflictTypes.CT_JUMP or event == ConflictTypes.CT_DASH) then
			self:stopAnimationByTag(TagMask.Skill, 0)
		elseif self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_CAST_ST(event, parentState)
	if self:CAST_ST() then
		if self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_COMBO_ST(event, parentState)
	if self:COMBO_ST() then
		if self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_BACKSWING_ST(event, parentState)
	if self:BACKSWING_ST() then
		if self.stopAnimationByTag then
			self:stopAnimationByTag(TagMask.Skill)
		end

		if self.serverMsg then
			self:serverMsg("RPC_CS_StopCombatActionTimeline", ClientAbilityConst.HIT_CANCEL_ABILITY_CTS[event] or false)
		end

		if self.actorTimeline and self.actorTimeline.stopCombatActionTimeline then
			self.actorTimeline:stopCombatActionTimeline()
		end
	end
end

function ClientStateCheckComponent:_cancel_HIT_BACKSWING_ST()
	if self:HIT_BACKSWING_ST() then
		self:_cancel_HIT_ST()
	end
end

function ClientStateCheckComponent:_cancel_CROUCH_ST()
	if self:CROUCH_ST() then
		if self.eModel and self.eModel.ForceChangeToState then
			self.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.IDLE)
		end

		if self.setCrouchEnabled then
			self:setCrouchEnabled(false)
		end
	end
end

function ClientStateCheckComponent:_cancel_CATCH_MODE_ST()
	if self:CATCH_MODE_ST() then
		if self.isInBossCatch and self:isInBossCatch() or self.isInBigBallCatch and self:isInBigBallCatch() then
			return
		end

		if self.forceExitCaptureMode then
			self:forceExitCaptureMode()
		end
	end
end

function ClientStateCheckComponent:_cancel_MAGNESIS_ST()
	if self.magnesisCancel then
		self:magnesisCancel()
	end
end

function ClientStateCheckComponent:_cancel_WALKING_ATTACK_ST(event)
	if self:WALKING_ATTACK_ST() then
		self:_cancel_ATTACK_ST(event)
	end
end

function ClientStateCheckComponent:_cancel_HOOK_SPRINT_ST()
	if self:HOOK_SPRINT_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_SKILL_MOTION_ST(event)
	if self:SKILL_MOTION_ST() then
		self:_cancel_ABILITY_ST(event)
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_QTE_ST()
	local qte = pg.game and pg.game.qte

	if qte and qte.tryCancelQte then
		qte:tryCancelQte()
	end
end

function ClientStateCheckComponent:_cancel_DIG_EGG_ST()
	if self.tryCancelDigEgg then
		self:tryCancelDigEgg()
	end
end

function ClientStateCheckComponent:_cancel_PUSH_ST()
	if self.isPushing and self:isPushing() then
		self:cancelPush()
	end
end

function ClientStateCheckComponent:_cancel_PLAY_ANIMATION_SCRIPT_ST()
	if self:PLAY_ANIMATION_SCRIPT_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_BURROW_ST()
	if self:BURROW_ST() then
		self:stopBurrow()
	end
end

function ClientStateCheckComponent:_cancel_TAKE_ROOT_ST()
	if self:TAKE_ROOT_ST() then
		self:stopTakeRoot()
	end
end

function ClientStateCheckComponent:_cancel_TAKE_ROOT_IN_ST()
	if self:TAKE_ROOT_IN_ST() then
		AnimationUtils.forceChangeState(self, CharacterStateConst.LOCOMOTION)
	end
end

function ClientStateCheckComponent:_cancel_EXPLORE_SWITCH_ST()
	if self:EXPLORE_SWITCH_ST() then
		self:cancelSwitchToExploreEnt()
	end
end

function ClientStateCheckComponent:_cancel_SCENT_TRACKING_ST()
	if self.exitScentTracking then
		self:exitScentTracking()
	end
end

function ClientStateCheckComponent:GROUND_ABILITY_ST()
	local abilityId = self.getCastingAbilityId and self:getCastingAbilityId() or 0

	if not abilityId or abilityId == 0 then
		return false
	end

	if self:FLY_ST() then
		return false
	end

	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

	if Lume.findInList(abilityParamData.stateCheckExclude or {}, "FALL_ST") then
		return false
	end

	return self:checkCastAbilityByFlyST(false, abilityParamData)
end

function ClientStateCheckComponent:_cancel_GROUND_ABILITY_ST(event)
	if self:GROUND_ABILITY_ST() then
		self:_cancel_ABILITY_ST(event)
	end
end

function ClientStateCheckComponent:_cancel_EXPLORE_DELAY_CANCEL_SWITCH_ST()
	if self:EXPLORE_DELAY_CANCEL_SWITCH_ST() then
		local controller = pg.game and pg.game.controller

		if controller and controller.realCancelExploreSwitch then
			controller:realCancelExploreSwitch()
		end
	end
end

function ClientStateCheckComponent:_cancel_SEGG_ST()
	if self:SEGG_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_BEGG_ST()
	if self:BEGG_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_CARRY_EGG_ST()
	if self:CARRY_EGG_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:_cancel_STATICSPAWN_ST()
	if self:STATICSPAWN_ST() then
		AnimationUtils.playAnimationState(self, CharacterStateConst.LOCOMOTION)
	end
end

function ClientStateCheckComponent:setStateConflictCheckFakeState(state)
	self.fakeConflictCheckState = state

	if CommonSwitch.StateCheckCacheMode then
		self:updateStateCache("SPRINT_ST")
	end
end

function ClientStateCheckComponent:getLogicState()
	return self.fakeConflictCheckState or self.characterState
end

function ClientStateCheckComponent:EVENT_BeControlled()
	if not Utils.isPet(self) then
		return
	end

	self.fakeConflictCheckState = nil

	if CommonSwitch.StateCheckCacheMode then
		self:refreshStateGroup("char")
	end
end

function ClientStateCheckComponent:EVENT_OnCharacterStateChange(oldState, newState)
	self.fakeConflictCheckState = nil

	if CommonSwitch.StateCheckCacheMode then
		self:refreshCharGroup(oldState, newState)
		self:updateStateCache("DEAD_ST")
	end

	if self == pg.game.camera.targetPlayer then
		pg.game.camera:onPlayerCharacterStateChange(oldState, newState)
	end

	local flag = CharacterStateConstImp[newState] and CharacterStateConstImp[newState].name or ""

	if self.isMainPet and self == pg.pawn then
		local masterEnt = self:getMasterEntity()

		if masterEnt then
			masterEnt:tryClientTrigger(TriggerConst.TRIGGER_TARGET_CONTROL_BEHAVIOR, self.basePetPrototypeId, 1, flag)
		end
	elseif self.isMainPlayer then
		self:tryClientTriggerAll(TriggerConst.TRIGGER_TARGET_PLAYER_BEHAVIOR, 1, flag)
	end

	if newState == CharacterStateConst.DASH then
		self.attackBlockTime = self:getGameTime() + 0.45
	end

	if self == pg.pawn then
		facade:sendMsgToUI(MessageName.CHARACTER_STATE_CHANGED, {})
	end
end

function ClientStateCheckComponent:onActionMaskChange(mask, value, abilityId)
	if CommonSwitch.StateCheckCacheMode then
		self:refreshMaskByChange(mask, value)
	end
end

function ClientStateCheckComponent:notifyBuffTagChange(changelist, newVal)
	if CommonSwitch.StateCheckCacheMode then
		self:refreshBuffByChange(changelist, newVal)
	end
end

function ClientStateCheckComponent:onLeaveSpace()
	ClientStateCheckComponent.super.onLeaveSpace(self)
	self:clearStateCache()
end

function ClientStateCheckComponent:EVENT_OnSpecialAttackModeChange()
	if self.isMainPlayer or self.isMainPet then
		facade:sendMsgToUI(MessageName.SPECIAL_ATTACK_MODE_CHANGE)
	end

	if CommonSwitch.StateCheckCacheMode then
		self:updateStateCache("SPECIAL_ATTACK_ST")
	end
end

function ClientStateCheckComponent:EVENT_OnHit()
	if self.isMainPlayer then
		self:_cancel_FALLEN_AID_ST()
		self:_cancel_DIG_EGG_ST()
	end
end

function ClientStateCheckComponent:onUpperStateChange(oldState, newState)
	local state2Name = {
		"IDLE",
		"ThrowRelease",
		"ThrowHold"
	}

	self.oldCharacterUpperState = oldState
	self.characterUpperState = newState

	self.eventEmitter:emit(EventConst.CHARACTER_STATE_CHANGE, oldState, newState)
	facade:sendMsgToUI(MessageName.ON_UPPER_STATE_CHANG, {
		oldState = oldState,
		newState = newState
	})
end

function ClientStateCheckComponent:changeToState(newState)
	AnimationUtils.playAnimationState(self, newState)
end

function ClientStateCheckComponent:showBubbleMessage(id, ...)
	ClientUtils.showBubbleMessage(id, ...)
end

function ClientStateCheckComponent:HIT_L_ST()
	return self.isAnimationPlaying and self:isAnimationPlaying(PlayableConst.Hit_L)
end

function ClientStateCheckComponent:_cancel_HIT_L_ST()
	if self:HIT_L_ST() and self.authority == Const.AUTHORITY_MASTER then
		self.actorTimeline.baseTimeline:stopTimeline()
		self:stopAnimation(PlayableConst.Hit_L)

		if self.setStateCacheValue then
			self:setStateCacheValue("HIT_L_ST", false)
		end
	end
end

function ClientStateCheckComponent:_cancel_HIT_ST()
	self:_cancel_HIT_L_ST()
	self:_cancel_HIT_H_ST()
	self:_cancel_KNOCK_UP_ST()
end

function ClientStateCheckComponent:HIT_H_ST()
	return self.isAnimationPlaying and self:isAnimationPlaying(PlayableConst.Hit_H)
end

function ClientStateCheckComponent:_cancel_HIT_H_ST()
	if self:HIT_H_ST() and self.authority == Const.AUTHORITY_MASTER then
		self.actorTimeline.baseTimeline:stopTimeline()
		self:stopAnimation(PlayableConst.Hit_H)

		if self.setStateCacheValue then
			self:setStateCacheValue("HIT_H_ST", false)
		end
	end
end

function ClientStateCheckComponent:PEEP_ST()
	return pg.me and pg.me.inPeep or false
end

function ClientStateCheckComponent:MORPHLING_NO_ATTACK()
	return pg.me.inMorphling
end

function ClientStateCheckComponent:DITTO_ENTER_ST()
	return pg.me and pg.me.dittoEnter or false
end

function ClientStateCheckComponent:_cancel_DITTO_ENTER_ST()
	if self:DITTO_ENTER_ST() then
		pg.me.dittoEnter = false

		if pg.me.updateStateCache then
			pg.me:updateStateCache("DITTO_ENTER_ST")
		end
	end
end

function ClientStateCheckComponent:CUTSCENE_ST()
	local cutscene = pg.game and pg.game.cutscene

	return cutscene and cutscene.isInCutsceneState and cutscene:isInCutsceneState() or false
end

function ClientStateCheckComponent:APPEAR_DASH_ST()
	return self.skillStateMgr and self.skillStateMgr.currentState == AbilityConst.SKILL_STATE_APPEAR_DASH
end

function ClientStateCheckComponent:_cancel_APPEAR_DASH_ST()
	if self:APPEAR_DASH_ST() and self.skillStateMgr and self.skillStateMgr.switchState then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function ClientStateCheckComponent:_cancel_PATHFINDING_ST()
	if self:PATHFINDING_ST() then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
		AutoPathFindUtils.stopAutoPathFind(self)

		if self.inTeleportFinding then
			self.inTeleportFinding = false
		end
	end
end

function ClientStateCheckComponent:PET_SPECIAL_VISION_ST()
	if Utils.isPet(self) and self.checkPetInControl and self:checkPetInControl() then
		local master = self.getMasterEntity and self:getMasterEntity()

		return master and master.ghostEyeState ~= nil and master.ghostEyeState ~= Const.GHOST_EYE_STATE_OFF
	end

	return self.ghostEyeState ~= nil and self.ghostEyeState ~= Const.GHOST_EYE_STATE_OFF
end

function ClientStateCheckComponent:_cancel_PET_SPECIAL_VISION_ST()
	if self:PET_SPECIAL_VISION_ST() and pg.me and pg.me.forceExitGhostEyeState then
		pg.me:forceExitGhostEyeState()
	end
end

function ClientStateCheckComponent:checkEnterVehicle(noCancel, conflictType)
	if self:BURROW_ST() then
		return false
	end

	local ret = self:checkStatus(conflictType or ConflictTypes.CT_ENTER_VEHICLE, nil, nil, noCancel)

	return ret
end

function ClientStateCheckComponent:checkKnockUpState()
	return self:checkStatus("KNOCK_UP")
end

function ClientStateCheckComponent:checkKnockBackState()
	return self:checkStatus(ConflictTypes.CT_KNOCK_BACK)
end

function ClientStateCheckComponent:_cancel_KNOCK_UP_ST()
	if self.skillStateMgr and self.skillStateMgr.switchState and self:KNOCK_UP_ST() and self.skillStateMgr.currentState == AbilityConst.SKILL_STATE_KNOCK_UP and self.authority == Const.AUTHORITY_MASTER then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function ClientStateCheckComponent:_cancel_KNOCK_UP_END_ST()
	if self.skillStateMgr and self.skillStateMgr.switchState and self:KNOCK_UP_END_ST() and self.authority == Const.AUTHORITY_MASTER then
		self.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
	end
end

function ClientStateCheckComponent:_cancel_REPAIR_GEAR_ST()
	local isMyHit = self == pg.me or Utils.isPet(self) and self:getMasterEntity() == pg.me

	if isMyHit and pg.space and pg.space:isGrabEgg() then
		facade:sendMsgToUI(MessageName.ON_HIT_WHEN_ROG_EGG)
	end
end

function ClientStateCheckComponent:_cancel_FLY_ST(event)
	if event == ConflictTypes.CT_JUMP and self.characterState == CharacterStateConst.FLYRISE then
		return
	end

	if self.stopFly then
		self:stopFly()
	end
end

function ClientStateCheckComponent:REBOUND_DASH_ST()
	return self.reboundDashData ~= nil
end

function ClientStateCheckComponent:_cancel_SPEED_BURST_ST()
	if self:SPEED_BURST_ST() then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
	end
end

function ClientStateCheckComponent:_cancel_SPECIAL_DEFENSE_ST()
	if self:SPECIAL_DEFENSE_ST() then
		self:_backToDefault()
	end
end

function ClientStateCheckComponent:AUTO_CAST_ST()
	local controller = pg.game and pg.game.controller
	local autoCastController = controller and controller.autoCastController
	local autoCastInfo = autoCastController and autoCastController.autoCastInfo

	return self == pg.pawn and autoCastInfo and next(autoCastInfo) ~= nil or false
end

function ClientStateCheckComponent:_cancel_AUTO_CAST_ST()
	if self:AUTO_CAST_ST() then
		local controller = pg.game and pg.game.controller
		local autoCastController = controller and controller.autoCastController

		if autoCastController and autoCastController.cancel then
			autoCastController:cancel()
		end
	end
end

function ClientStateCheckComponent:_cancel_SKILL_AIM_ST()
	if self.inSkillAim then
		pg.global.ui.hudV2:setIsInAim(false)

		if pg.game.camera.playerCameraMode.isInAim then
			pg.game.camera.playerCameraMode:setInAim(false)

			self.eModel.AlwaysLookScreenCenter = false

			facade:sendMsgToUI(MessageName.LEAVE_SKILL_AIM)
			self:enableLookAtCameraCenter(false)
		end

		self.inSkillAim = false

		if self.updateStateCache then
			self:updateStateCache("SKILL_AIM_ST")
		end
	end
end

function ClientStateCheckComponent:SWITCH_ANIM_ST()
	if self.isInLinkAnim then
		return true
	end

	if self.isMainPet then
		return pg.me and pg.me.isInLinkAnim or false
	end

	return false
end

function ClientStateCheckComponent:FORCE_LOCK_CAMERA_ST()
	if self.isMainPet or self.isMainPlayer then
		local controller = pg.game and pg.game.controller
		local lockHelper = controller and controller.lockHelper

		return lockHelper and ToBool(lockHelper.forceLockActorId) and lockHelper.isUseLockOnExtendCamera or false
	end

	return false
end

function ClientStateCheckComponent:_cancel_FALLEN_AID_ST()
	if self ~= pg.pawn then
		return
	end

	if self:FALLEN_AID_ST() then
		pg.me:serverMsgNoGC("RPC_CS_StopTargetFallenAid")
	end
end

function ClientStateCheckComponent:_cancel_FIRST_AID_ST()
	if self:FIRST_AID_ST() then
		self:serverMsgNoGC("RPC_CS_StopTargetFallenAid")
		self:_backToDefault()
		facade:SendMessageCommand(MessageName.EXIT_FALLEN_AID)
		pg.global.ui.tips:hideControlPanel()
	end
end

function ClientStateCheckComponent:_cancel_BOSS_CAPTURE_ST()
	if not pg.me then
		return
	end

	if self:BOSS_CAPTURE_ST() then
		pg.me:interruptBossCapture()
	end
end

function ClientStateCheckComponent:ABILITY_FOLLOW_TARGET_ST()
	return self.followTargetData ~= nil
end

function ClientStateCheckComponent:ABILITY_INDICATOR_SEL_POS_ST()
	return self.abilityIndicatorSelPosData and self.abilityIndicatorSelPosData.valid ~= false
end

function ClientStateCheckComponent:_cancel_ABILITY_INDICATOR_SEL_POS_ST()
	if self.abilityIndicatorSelPosData then
		self:hideAbilityIndicatorSelPos(false, false)
	end
end

function ClientStateCheckComponent:ABILITY_INDICATOR_AIM_ST()
	return self.abilityIndicatorAimData and self.abilityIndicatorAimData.valid ~= false
end

function ClientStateCheckComponent:_cancel_ABILITY_INDICATOR_AIM_ST()
	if self.abilityIndicatorAimData then
		self:hideAbilityIndicatorAim(false, false)
	end
end

function ClientStateCheckComponent:ABILITY_INDICATOR_AIM_WALK_ST()
	return self.abilityIndicatorAimWalkData and self.abilityIndicatorAimWalkData.valid ~= false
end

function ClientStateCheckComponent:_cancel_ABILITY_INDICATOR_AIM_WALK_ST()
	if self.abilityIndicatorAimWalkData then
		self:hideAbilityIndicatorAimWalk(false, false)
	end
end

function ClientStateCheckComponent:cancelAbilityIndicator()
	self:_cancel_ABILITY_INDICATOR_SEL_POS_ST()
	self:_cancel_ABILITY_INDICATOR_AIM_ST()
	self:_cancel_ABILITY_INDICATOR_AIM_WALK_ST()
end

return ClientStateCheckComponent
