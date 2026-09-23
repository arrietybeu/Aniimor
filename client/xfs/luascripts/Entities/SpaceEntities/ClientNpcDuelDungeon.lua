-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientNpcDuelDungeon.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local logger = require("Core.Log.LoggerManager").getLogger("ClientNpcDuelDungeon")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local PlayableConst = require("Common.Const.PlayableConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Const = require("Common.Const.Const")
local PetSwitchAnim = require("GameApp.PetSwitch.PetSwitchAnim")
local NpcDuelData = require("Data.npc_duel_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local NPC_DUEL_EXIT_COUNTDOWN_ID = "NpcDuelExit"
local NPC_DUEL_GYM_BATTLE_CAMERA_ANIM = "$CameraAni_Activity_GymBattle_Intro_01.asset"
local NPC_DUEL_GYM_BATTLE_CAMERA_HEIGHT_HOLD_RATIO = 0.65
local NPC_DUEL_AUTO_LOCK_DISTANCE = 9999
local NPC_DUEL_AUTO_LOCK_RETRY_INTERVAL = 0.1
local NPC_DUEL_AUTO_LOCK_TIMEOUT = 3
local BUFF_AND_COUNTDOWN_DURATION = 3
local START_TIPS_DURATION = 3

local function getNpcDuelGymBattleCameraHeightWeight(progress)
	if progress <= 0 then
		return 1
	end

	if progress >= 1 then
		return 0
	end

	if progress <= NPC_DUEL_GYM_BATTLE_CAMERA_HEIGHT_HOLD_RATIO then
		return 1
	end

	local t = (progress - NPC_DUEL_GYM_BATTLE_CAMERA_HEIGHT_HOLD_RATIO) / (1 - NPC_DUEL_GYM_BATTLE_CAMERA_HEIGHT_HOLD_RATIO)

	t = t * t * (3 - 2 * t)

	return 1 - t
end

local ClientNpcDuelDungeon = Class.Class("ClientNpcDuelDungeon", ClientPveDungeon)

function ClientNpcDuelDungeon:ctor(entityId)
	ClientNpcDuelDungeon.super.ctor(self, entityId)

	self.forceReloadOnSwitch = true
	self.envRefreshOnEnter = false

	logger:info("ClientNpcDuelDungeon ctor ok")
end

function ClientNpcDuelDungeon:init(dict)
	ClientNpcDuelDungeon.super.init(self, dict)
	logger:info("ClientNpcDuelDungeon init ok")

	return true
end

function ClientNpcDuelDungeon:refreshNpcDuelEndTimelinesSpeed()
	local speed = self.gameTimeScale <= 0 and 0 or 1

	if self.npcDuelEndUiTimeline then
		self.npcDuelEndUiTimeline:setSpeed(speed)
	end

	if self.npcDuelAllPetDeathTimeline then
		self.npcDuelAllPetDeathTimeline:setSpeed(speed)
	end
end

function ClientNpcDuelDungeon:onGameTimeScaleChange()
	ClientNpcDuelDungeon.super.onGameTimeScaleChange(self)
	self:refreshNpcDuelEndTimelinesSpeed()
end

function ClientNpcDuelDungeon:start()
	self.checkTimer = TimerManager.removeTimer(self.checkTimer)
	self._npcDuelDungeonIsReady = false
	self._npcDuelEnding = false
	self._npcDuelLockForbidden = true

	ClientNpcDuelDungeon.super.start(self)
	pg.game.controller:unlockTarget()

	if pg.me and pg.me.setForbidAllAiHelper then
		pg.me:setForbidAllAiHelper(true)
	end

	pg.global.ui.tips:clearAIHelperTips()

	if pg.game.npcDuel then
		pg.game.npcDuel:clearDialogRecored()
	end

	self.faultId = 0

	logger:info("start, check npcduel dungeon ready")
	pg.game.audio:setVolume(AudioConst.VolumeType.Sfx, 0, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:setVolume(AudioConst.VolumeType.Vox, 0, AudioConst.SetVolumeReason.Loading)

	self.checkTimer = TimerManager.addRepeatTimer(0.1, function()
		if pg.me == nil or pg.me.space == nil then
			logger:info("check ready: pg.me == nil or pg.me.space == nil ")

			self.faultId = 1

			return
		end

		if not pg.me.space:isNpcDuel() then
			logger:info("check ready: pg.me.space is not a NpcDuel")

			self.faultId = 2

			return
		end

		if not pg.global.scene:isSceneValid() then
			logger:info("check ready: global scene is not valid")

			self.faultId = 3

			return
		end

		if not self:isBotReady() then
			logger:info("check ready: bot is not ready")

			self.faultId = 4

			return
		end

		self.faultId = 0

		if pg.game.npcDuel then
			pg.game.npcDuel:clearNpcDuelStartFallbackTimer()
		end

		self:npcDuelDungeonReady()

		self.checkTimer = TimerManager.removeTimer(self.checkTimer)
	end)
end

function ClientNpcDuelDungeon:isBotReady()
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)

	if not botEntity then
		return false
	end

	local petEnt = botEntity:getCurPetEntity()

	if not petEnt then
		return false
	end

	return true
end

function ClientNpcDuelDungeon:npcDuelDungeonReady()
	self:initNpcDuelCenterPositionAndRadius()
	self:npcDuelCreateAreaEffect()
	self:registerBotPetCastAbilityListeners()

	if not self.hasFinishedOpeningShow then
		self:npcDuelTryPlayCameraAnim()
	elseif pg.game.npcDuel:isInRematch() then
		self:npcDuelRematchFlow()
	else
		self:startCtrlPet()
		self:afterCameraAnim()
		self:resumeBt()
	end
end

function ClientNpcDuelDungeon:registerBotPetCastAbilityListeners()
	self:unregisterBotPetCastAbilityListeners()

	self.botPetCastAbilityListeners = {}

	local botEntity = pg.getEntity(self.npcDuelBotEntityId)

	if not botEntity then
		return
	end

	for _, petEntityId in ipairs(botEntity.petPrepareList or EMPTY_TABLE) do
		local botPet = pg.getEntity(petEntityId)

		if botPet and botPet.subject then
			local token = pg.global.abilityMgr:genTokenId()

			botPet.subject:add(token, AbilityConst.COMBAT_EVENT_CAST_ABILITY, function(combatContext)
				self:onBotPetCastAbility(botPet, combatContext)
			end)
			table.insert(self.botPetCastAbilityListeners, {
				botPet = botPet,
				token = token
			})
		end
	end
end

function ClientNpcDuelDungeon:unregisterBotPetCastAbilityListeners()
	for _, listener in ipairs(self.botPetCastAbilityListeners or EMPTY_TABLE) do
		if listener.botPet and listener.botPet.subject then
			listener.botPet.subject:remove(listener.token, AbilityConst.COMBAT_EVENT_CAST_ABILITY)
		end
	end

	self.botPetCastAbilityListeners = nil
end

function ClientNpcDuelDungeon:onBotPetCastAbility(botPet, combatContext)
	local abilityId = combatContext and combatContext.abilityId
	local isEquippedAbility = abilityId == botPet:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY) or abilityId == botPet:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY2) or abilityId == botPet:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)

	if not isEquippedAbility then
		return
	end

	local abilityParamData = abilityId and pg.global.abilityMgr:getAbilityParamData(abilityId)
	local skillType = abilityParamData and abilityParamData.skillType

	if not skillType or skillType ~= Const.SkillType.Skill and skillType ~= Const.SkillType.Ultimate then
		return
	end

	local abilityNameKey = abilityId and AbilityUtils.getAbilityName(abilityId)
	local abilityName = abilityNameKey and pg.getLocalizationText(abilityNameKey) or ""

	pg.global.ui.tips:showBattleRoomMechanismTips(abilityName, 3)
end

function ClientNpcDuelDungeon:npcDuelTryPlayCameraAnim()
	local curNpcDuelId = pg.me.curNpcDuelId
	local curNpcDuelVariantId = pg.me.curNpcDuelVariantId
	local npcDuelData = NpcDuelData[curNpcDuelId] and NpcDuelData[curNpcDuelId][curNpcDuelVariantId]

	if not npcDuelData then
		return
	end

	local openingType = npcDuelData.openingType

	self:beforeStart()

	if openingType == 1 then
		self:npcDuelTryPlayCameraAnim_Type1(npcDuelData)
	elseif openingType == 2 then
		self:npcDuelTryPlayCameraAnim_Type2()
	end
end

function ClientNpcDuelDungeon:beforeStart()
	self:npcDuelPauseBt()
	pg.game.input:enablePlayerInput(false, HotkeyConst.INPUT_BLOCK_FLAG.Move)
	self:npcDuelSetJoyStickActive(false)
end

function ClientNpcDuelDungeon:npcDuelGetBotIntroAnim()
	local duelData = NpcDuelData[pg.me.curNpcDuelId] and NpcDuelData[pg.me.curNpcDuelId][pg.me.curNpcDuelVariantId]

	return duelData and duelData.openingNpcAnimStateName
end

function ClientNpcDuelDungeon:setNpcDuelIntroCameraHeightOffset(heightDelta, progress)
	if not pg.game or not pg.game.camera or not pg.game.camera.animCameraMode then
		return
	end

	self.npcDuelIntroCameraHeightOffsetActive = true

	local weight = getNpcDuelGymBattleCameraHeightWeight(progress)

	pg.game.camera.animCameraMode:setCameraOffset(Vector3(0, heightDelta * weight, 0))
end

function ClientNpcDuelDungeon:clearNpcDuelIntroCameraHeightOffset()
	if not self.npcDuelIntroCameraHeightOffsetActive then
		return
	end

	self.npcDuelIntroCameraHeightOffsetActive = nil

	if pg.game and pg.game.camera and pg.game.camera.animCameraMode then
		pg.game.camera.animCameraMode:setCameraOffset(Vector3.zero)
	end
end

function ClientNpcDuelDungeon:npcDuelTryPlayCameraAnim_Type1(npcDuelData)
	local BASE_TIME = 9.267
	local MASK_FADEOUT_TIME = 0.1
	local CLOSE_LOADING_TIME = 0.45 + MASK_FADEOUT_TIME
	local PLAY_ANIM_TIME = CLOSE_LOADING_TIME
	local CAMERA_ANIM_DURATION = BASE_TIME
	local CAMERA_ANIM_HOLD_ADVANCE = 0.1
	local CAMERA_ANIM_HOLD_TIME = CAMERA_ANIM_DURATION - CAMERA_ANIM_HOLD_ADVANCE
	local NAMEIN_OPEN_TIME = 3.5 + PLAY_ANIM_TIME
	local NAMEIN_CLOSE_TIME = 2 + NAMEIN_OPEN_TIME
	local START_CTRL_TIME = 2.5 + NAMEIN_CLOSE_TIME
	local SysConfigData = require("Data.sys_config_data")
	local openingTimelineParams = SysConfigData.openingTimelineParams1 or {}
	local COUNT_DOWN_BUFF_TIME = openingTimelineParams[1] or 8.55
	local START_TIPS_TIME = openingTimelineParams[2] or 11.55
	local CAMERA_BLEND_OUT_TIME = openingTimelineParams[3] or 12.75
	local CAMERA_BLEND_OUT_DURATION = openingTimelineParams[4] or 1.9
	local PLAYER_CTRL_TIME = openingTimelineParams[5] or 14.75
	local BOT_PET_RESUME_TIME = openingTimelineParams[6] or 14.55
	local TOTAL_DURATION = math.max(PLAYER_CTRL_TIME, BOT_PET_RESUME_TIME)
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)
	local petAnim = npcDuelData.openingNpcPetAnimStateName
	local petAnimTime = npcDuelData.openingNpcPetAnimTimestamp + CLOSE_LOADING_TIME

	if self.npcDuelCameraTimeline then
		self.npcDuelCameraTimeline:stop()
	end

	local timeline = LuaTimeline.new()

	self.npcDuelCameraTimeline = timeline

	local isDrivingCameraAnim = false
	local drivingCameraAnimRequestId

	local function markCameraAnimDriving()
		if pg.game and pg.game.camera then
			drivingCameraAnimRequestId = pg.game.camera.cameraAnimRequestId
		end
	end

	local function getDrivingAnimCameraMode()
		if drivingCameraAnimRequestId == nil or not pg.game or not pg.game.camera then
			return nil
		end

		local camera = pg.game.camera

		if camera.cameraAnimRequestId ~= drivingCameraAnimRequestId then
			return nil
		end

		local animCameraMode = camera.animCameraMode

		if animCameraMode and animCameraMode.cameraMode and animCameraMode.refEntity == pg.me then
			return animCameraMode
		end

		return nil
	end

	local function updateCameraAnimTime(currTime)
		local animCameraMode = getDrivingAnimCameraMode()

		if not animCameraMode then
			return
		end

		if not isDrivingCameraAnim then
			isDrivingCameraAnim = true

			animCameraMode:setAnimSpeed(0)
		end

		animCameraMode:setTime(math.min(currTime, CAMERA_ANIM_HOLD_TIME))
	end

	local function stopHeldCameraAnim()
		if not isDrivingCameraAnim then
			return
		end

		isDrivingCameraAnim = false

		if getDrivingAnimCameraMode() then
			pg.game.camera:stopCameraAnim()
		end
	end

	timeline:setStopCallback(function()
		stopHeldCameraAnim()

		if self.npcDuelCameraTimeline == timeline then
			self.npcDuelCameraTimeline = nil
		end

		self:clearNpcDuelIntroCameraHeightOffset()
	end)
	timeline:setDuration(TOTAL_DURATION)
	timeline:createAndAddTrigger(MASK_FADEOUT_TIME, function()
		pg.global.ui:hide(UIConst.UI_ID_HUD_V2)

		if pg.game.npcDuel then
			pg.game.npcDuel:npcDuelMaskFadeOut()
		end

		pg.game.audio:playEvent("SFX_UI_Npcduel_Scene_Enter")
	end)
	timeline:createAndAddTrigger(CLOSE_LOADING_TIME, function()
		self:closeLoading()
	end)

	local botAnimName = self:npcDuelGetBotIntroAnim()
	local cameraHeightDelta = 0
	local cameraAnim = npcDuelData.openingCameraAnim or NPC_DUEL_GYM_BATTLE_CAMERA_ANIM

	timeline:createAndAddTrigger(PLAY_ANIM_TIME, function()
		cameraHeightDelta = 0

		if botEntity and pg.me then
			local botPos = botEntity:getPosition()
			local mePos = pg.me:getPosition()

			cameraHeightDelta = botPos.y - mePos.y
		end

		local cameraOffset = Vector3(0, cameraHeightDelta, 0)

		pg.game.camera:playCameraAnimByEntity(pg.me, cameraAnim, 0, CAMERA_BLEND_OUT_DURATION, true, cameraOffset, nil, nil, nil, nil, nil, true)
		markCameraAnimDriving()
		updateCameraAnimTime(0)
		self:setNpcDuelIntroCameraHeightOffset(cameraHeightDelta, 0)

		if botEntity and botAnimName then
			botEntity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
			botEntity:playRawAnimation(botAnimName, 0)
		end
	end)
	timeline:createAndAddClip(PLAY_ANIM_TIME, CAMERA_ANIM_DURATION, function(_, currTime)
		updateCameraAnimTime(currTime)
		self:setNpcDuelIntroCameraHeightOffset(cameraHeightDelta, currTime / CAMERA_ANIM_DURATION)
	end, function()
		updateCameraAnimTime(0)
		self:setNpcDuelIntroCameraHeightOffset(cameraHeightDelta, 0)
	end, function()
		updateCameraAnimTime(CAMERA_ANIM_HOLD_TIME)
		self:clearNpcDuelIntroCameraHeightOffset()
	end)
	timeline:createAndAddTrigger(petAnimTime, function()
		local petEntity = botEntity and botEntity:getCurPetEntity()

		if petEntity then
			petEntity:playAnimation(petAnim)
		end
	end)
	timeline:createAndAddTrigger(NAMEIN_OPEN_TIME, function()
		pg.global.ui:open(UIConst.UI_ID_NPC_DUEL_NAMEIN)
	end)
	timeline:createAndAddTrigger(NAMEIN_CLOSE_TIME, function()
		pg.global.ui:close(UIConst.UI_ID_NPC_DUEL_NAMEIN)
	end)
	timeline:createAndAddTrigger(COUNT_DOWN_BUFF_TIME, function()
		self:showCountDownWithBuffTips(BUFF_AND_COUNTDOWN_DURATION)
	end)
	timeline:createAndAddTrigger(START_TIPS_TIME, function()
		self:npcDuelStartTips(START_TIPS_DURATION)
	end)
	timeline:createAndAddTrigger(BOT_PET_RESUME_TIME, function()
		self:resumeBt()
	end)
	timeline:createAndAddTrigger(CAMERA_BLEND_OUT_TIME, function()
		stopHeldCameraAnim()
	end)
	timeline:createAndAddTrigger(START_CTRL_TIME, function()
		self:startCtrlPet()
	end)
	timeline:createAndAddTrigger(PLAYER_CTRL_TIME, function()
		self:afterCameraAnim()
	end)
	timeline:start()
end

function ClientNpcDuelDungeon:npcDuelTryPlayCameraAnim_Type2()
	local BASE_TIME = 0
	local MASK_FADEOUT_TIME = 0.1
	local CLOSE_LOADING_TIME = 0.45 + MASK_FADEOUT_TIME
	local START_CTRL_TIME = 1.5 + CLOSE_LOADING_TIME
	local SysConfigData = require("Data.sys_config_data")
	local openingTimelineParams = SysConfigData.openingTimelineParams2 or {}
	local COUNT_DOWN_BUFF_TIME = openingTimelineParams[1] or START_CTRL_TIME
	local START_TIPS_TIME = openingTimelineParams[2] or START_CTRL_TIME + BUFF_AND_COUNTDOWN_DURATION
	local PLAYER_CTRL_TIME = openingTimelineParams[3] or START_TIPS_TIME + START_TIPS_DURATION - 1
	local BOT_PET_RESUME_TIME = openingTimelineParams[4] or START_TIPS_TIME + START_TIPS_DURATION
	local TOTAL_DURATION = math.max(PLAYER_CTRL_TIME, BOT_PET_RESUME_TIME, PLAYER_CTRL_TIME)

	pg.global.ui:hide(UIConst.UI_ID_HUD_V2)

	if self.npcDuelCameraTimeline then
		self.npcDuelCameraTimeline:stop()
	end

	local timeline = LuaTimeline.new()

	self.npcDuelCameraTimeline = timeline

	timeline:setDuration(TOTAL_DURATION)
	timeline:createAndAddTrigger(MASK_FADEOUT_TIME, function()
		if pg.game.npcDuel then
			pg.game.npcDuel:npcDuelMaskFadeOut()
		end

		pg.game.audio:playEvent("SFX_UI_Npcduel_Scene_Enter")
	end)
	timeline:createAndAddTrigger(CLOSE_LOADING_TIME, function()
		self:closeLoading()
	end)
	timeline:createAndAddTrigger(START_CTRL_TIME, function()
		self:startCtrlPet()
	end)
	timeline:createAndAddTrigger(COUNT_DOWN_BUFF_TIME, function()
		self:showCountDownWithBuffTips(BUFF_AND_COUNTDOWN_DURATION)
	end)
	timeline:createAndAddTrigger(START_TIPS_TIME, function()
		self:npcDuelStartTips(START_TIPS_DURATION)
	end)
	timeline:createAndAddTrigger(BOT_PET_RESUME_TIME, function()
		self:resumeBt()
	end)
	timeline:createAndAddTrigger(PLAYER_CTRL_TIME, function()
		self:afterCameraAnim()
	end)
	timeline:start()
end

function ClientNpcDuelDungeon:npcDuelRematchFlow()
	pg.game.npcDuel:setInRematch(false)
	pg.global.ui:hide(UIConst.UI_ID_HUD_V2)
	pg.game.npcDuel:onRematchFadeOut()
	pg.game.camera.playerCameraMode:resetCamera()
	self:beforeStart()

	local START_CTRL_TIME = 1
	local SysConfigData = require("Data.sys_config_data")
	local openingTimelineParams = SysConfigData.openingTimelineParams3 or {}
	local COUNT_DOWN_BUFF_TIME = openingTimelineParams[1] or START_CTRL_TIME
	local START_TIPS_TIME = openingTimelineParams[2] or START_CTRL_TIME + BUFF_AND_COUNTDOWN_DURATION
	local PLAYER_CTRL_TIME = openingTimelineParams[3] or START_TIPS_TIME + START_TIPS_DURATION - 1
	local BOT_PET_RESUME_TIME = openingTimelineParams[4] or START_TIPS_TIME + START_TIPS_DURATION
	local TOTAL_DURATION = math.max(PLAYER_CTRL_TIME, BOT_PET_RESUME_TIME)

	pg.global.ui:hide(UIConst.UI_ID_HUD_V2)

	if self.npcDuelCameraTimeline then
		self.npcDuelCameraTimeline:stop()
	end

	local timeline = LuaTimeline.new()

	self.npcDuelCameraTimeline = timeline

	timeline:setDuration(TOTAL_DURATION)
	timeline:createAndAddTrigger(START_CTRL_TIME, function()
		self:startCtrlPet()
	end)
	timeline:createAndAddTrigger(COUNT_DOWN_BUFF_TIME, function()
		self:showCountDownWithBuffTips(BUFF_AND_COUNTDOWN_DURATION)
	end)
	timeline:createAndAddTrigger(START_TIPS_TIME, function()
		self:npcDuelStartTips(START_TIPS_DURATION)
	end)
	timeline:createAndAddTrigger(BOT_PET_RESUME_TIME, function()
		self:resumeBt()
	end)
	timeline:createAndAddTrigger(PLAYER_CTRL_TIME, function()
		self:afterCameraAnim()
	end)
	timeline:start()
end

function ClientNpcDuelDungeon:afterCameraAnim()
	pg.global.ui:show(UIConst.UI_ID_HUD_V2)

	self._npcDuelDungeonIsReady = true

	if self.npcDuelPassSecondTimer then
		self:removeTimer(self.npcDuelPassSecondTimer)
	end

	local duelPassSecond = 0

	self.npcDuelPassSecondTimer = self:addRepeatTimer(1, function()
		duelPassSecond = duelPassSecond + 1

		if pg.game.npcDuel then
			pg.game.npcDuel:onDeulPassSecond(duelPassSecond)
		end
	end)
	self.exitCountDownTime = self:getExitCountDownTime()

	facade:sendMsgToUI(MessageName.PLAYER_BE_HATRED_LIST_CHANGE)
	pg.global.ui.hudV2:showNpcDuelInCombat(true)
	pg.game.input:enablePlayerInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Move)
	self:npcDuelSetJoyStickActive(true)
	self:resetLoadingAudioVolume()
	pg.me:serverSpaceMsg("RPC_CS_FinishOpeningShow")
	self:npcDuelTryAutoLockBotPet()
	self:startBotPositionCheckTimer()
end

function ClientNpcDuelDungeon:startCtrlPet()
	pg.me:serverMsg("RPC_CS_StartControll", Const.CLIENT_SWITCH_REASON.NpcDuel)
	self:npcDuelBotSwitchPet()
end

function ClientNpcDuelDungeon:closeLoading()
	self:resetLoadingAudioVolume()
	pg.global.ui:close(UIConst.UI_ID_NPC_DUEL_START)
end

function ClientNpcDuelDungeon:resetLoadingAudioVolume()
	pg.game.audio:setVolume(AudioConst.VolumeType.Sfx, nil, AudioConst.SetVolumeReason.Loading)
	pg.game.audio:setVolume(AudioConst.VolumeType.Vox, nil, AudioConst.SetVolumeReason.Loading)
end

function ClientNpcDuelDungeon:showCountDownWithBuffTips(time)
	pg.global.ui.tips:showCountDownBeat(Time.secondCache + time)

	local buffInfo = pg.me:getCurBuffInfo()

	if next(buffInfo) then
		pg.global.ui.tips:showNpcDuelBuff(buffInfo)
	end
end

function ClientNpcDuelDungeon:npcDuelTryAutoLockBotPet()
	self._npcDuelLockForbidden = false

	if self.npcDuelAutoLockTimer then
		self:removeTimer(self.npcDuelAutoLockTimer)

		self.npcDuelAutoLockTimer = nil
	end

	if not pg.global.ui:runPlatformByMobile() then
		return
	end

	local function tryAutoLock()
		if self._npcDuelEnding then
			return true
		end

		local petEntity = self:getCurNpcDuelBotPetEntity()
		local lockHelper = pg.game and pg.game.controller and pg.game.controller.lockHelper

		if not petEntity or not ToBool(petEntity.actorId) or not lockHelper then
			return false
		end

		if not lockHelper:canForceLock() then
			return false
		end

		lockHelper:tryForceLockTarget(petEntity.actorId, 0, NPC_DUEL_AUTO_LOCK_DISTANCE, nil, true)

		return lockHelper.forceLockActorId == petEntity.actorId
	end

	if tryAutoLock() then
		return
	end

	local timeoutTime = Time.realSecondCache + NPC_DUEL_AUTO_LOCK_TIMEOUT

	self.npcDuelAutoLockTimer = self:addRepeatTimer(NPC_DUEL_AUTO_LOCK_RETRY_INTERVAL, function()
		if tryAutoLock() or Time.realSecondCache >= timeoutTime then
			self:removeTimer(self.npcDuelAutoLockTimer)

			self.npcDuelAutoLockTimer = nil
		end
	end)
end

function ClientNpcDuelDungeon:npcDuelBotSwitchPet()
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)

	if not botEntity then
		return
	end

	local petEnt = botEntity:getCurPetEntity()

	if not petEnt then
		return
	end

	if not self.npcDuelBotPetSwitchAnim then
		self.npcDuelBotPetSwitchAnim = PetSwitchAnim.new()
	end

	botEntity.controlState = Const.CONTROL_STATE_CONTROL

	local extraData = {
		forcePlay = true,
		ignoreCamera = true
	}
	local param = {
		clientSwitchReason = Const.CLIENT_SWITCH_REASON.NpcDuel
	}

	self.npcDuelBotPetSwitchAnim:playSwitchToPetAnim(petEnt, botEntity)
	botEntity:switchToPet(Const.EVENT_ENTER_PET, nil, param)
end

function ClientNpcDuelDungeon:npcDuelDungeonIsReady()
	return ToBool(self._npcDuelDungeonIsReady)
end

function ClientNpcDuelDungeon:npcDuelDungeonIsEnding()
	return ToBool(self._npcDuelEnding)
end

function ClientNpcDuelDungeon:isNpcDuelActive()
	return not self:npcDuelDungeonIsEnding()
end

function ClientNpcDuelDungeon:npcDuelLockForbidden()
	return ToBool(self._npcDuelLockForbidden)
end

function ClientNpcDuelDungeon:npcDuelPauseBt()
	if self.botResumeAiTimer then
		self:removeTimer(self.botResumeAiTimer)

		self.botResumeAiTimer = nil
	end

	local botEntity = pg.getEntity(self.npcDuelBotEntityId)

	if botEntity then
		AIUtils.pauseBt(botEntity, AiConst.PauseBtReason.NpcDuelStart)

		for _, id in ipairs(botEntity.petPrepareList) do
			AIUtils.pauseBt(pg.getEntity(id), AiConst.PauseBtReason.NpcDuelStart)
		end
	end

	local petEntity = pg.me:getCurPetEntity()

	if petEntity then
		AIUtils.pauseBt(petEntity, AiConst.PauseBtReason.NpcDuelStart)
	end
end

function ClientNpcDuelDungeon:resumeBt()
	local petEntity = pg.me:getCurPetEntity()

	if petEntity then
		AIUtils.resumeBt(petEntity, AiConst.PauseBtReason.NpcDuelStart)
	end

	if self._npcDuelEnding then
		return
	end

	local botEntity = pg.getEntity(self.npcDuelBotEntityId)

	if botEntity and botEntity:isAlive() then
		AIUtils.resumeBt(botEntity, AiConst.PauseBtReason.NpcDuelStart)

		for _, id in ipairs(botEntity.petPrepareList) do
			local petEntity = pg.getEntity(id)

			if petEntity and petEntity:isAlive() then
				AIUtils.resumeBt(petEntity, AiConst.PauseBtReason.NpcDuelStart)
			end
		end
	end
end

function ClientNpcDuelDungeon:stopNpcDuelEndTimelines()
	if self.npcDuelEndUiTimeline then
		self.npcDuelEndUiTimeline:stop()

		self.npcDuelEndUiTimeline = nil
	end

	if self.npcDuelAllPetDeathTimeline then
		self.npcDuelAllPetDeathTimeline:stop()

		self.npcDuelAllPetDeathTimeline = nil
	end

	if self.npcDuelEndUiDelayTimer then
		self:removeTimer(self.npcDuelEndUiDelayTimer)

		self.npcDuelEndUiDelayTimer = nil
	end

	if self.npcDuelAllPetDeathDelayTimer then
		self:removeTimer(self.npcDuelAllPetDeathDelayTimer)

		self.npcDuelAllPetDeathDelayTimer = nil
	end
end

function ClientNpcDuelDungeon:npcDuelItemGetCahce(cacheInfo)
	self.itemGetCacheInfo = cacheInfo
end

function ClientNpcDuelDungeon:npcDuelExpGetCahce(cacheInfo)
	self.expGetCacheInfo = cacheInfo
end

function ClientNpcDuelDungeon:onNpcDuelEnd(isSuccess)
	self._npcDuelEnding = true

	if self.npcDuelPassSecondTimer then
		self:removeTimer(self.npcDuelPassSecondTimer)

		self.npcDuelPassSecondTimer = nil
	end

	pg.game.controller:unlockTarget()

	if not isSuccess or self.npcDuelEndUiTimeline or self.npcDuelEndUiDelayTimer then
		return
	end

	local freezeDuration = SysConfigData.killBossFreezeDuration

	local function playUiTimeline()
		pg.global.ui.tips:setBossTitleItemInvisibleReason("npcDuel", false)

		self._npcDuelDungeonIsReady = false

		facade:sendMsgToUI(MessageName.PLAYER_BE_HATRED_LIST_CHANGE)

		local timeline = LuaTimeline.new()

		self.npcDuelEndUiTimeline = timeline

		self:refreshNpcDuelEndTimelinesSpeed()
		timeline:setStopCallback(function()
			if self.npcDuelEndUiTimeline == timeline then
				self.npcDuelEndUiTimeline = nil
			end
		end)

		local time = 0
		local winTipDuration = 3

		timeline:createAndAddTrigger(time, function()
			pg.global.ui.tips:showA1Tips({
				id = "TowerResultWin",
				showText = pg.getGameString("NPCDUEL_BATTLE_SUCCESS"),
				duration = winTipDuration
			})
			pg.game.audio:playEvent("SFX_UI_Rouge_ChallengeSuccessful")
		end)

		time = time + winTipDuration

		if self.itemGetCacheInfo then
			local itemTipDuration = 3.5
			local cacheInfo = self.itemGetCacheInfo

			cacheInfo.duration = itemTipDuration
			self.itemGetCacheInfo = nil

			timeline:createAndAddTrigger(time, function()
				pg.global.ui.tips:pushLightPropItem(cacheInfo)
				pg.game.audio:playEvent("SFX_UI_Common_GetItem")
			end)

			time = time + itemTipDuration
		end

		if self.expGetCacheInfo then
			local expTipDuration = 4
			local cacheInfo = self.expGetCacheInfo

			cacheInfo.duration = expTipDuration
			self.expGetCacheInfo = nil

			timeline:createAndAddTrigger(time, function()
				pg.global.ui.tips:pushAreaManagerData(cacheInfo)
			end)

			time = time + expTipDuration
		end

		local realCountdown = self.exitCountDownTime + 1
		local hasNpcDuelExitTriggered = false

		local function tryNpcDuelExit()
			if hasNpcDuelExitTriggered then
				return
			end

			hasNpcDuelExitTriggered = true

			if pg.me and pg.me.npcDuelExit then
				pg.me:npcDuelExit()
			end
		end

		timeline:createAndAddTrigger(time + 1, function()
			pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("NPCDUEL_BATTLE_SUCCESS_COUNTDOWN"), self.exitCountDownTime), 1)
			pg.global.ui.tips:hideCountDown(NPC_DUEL_EXIT_COUNTDOWN_ID)
			pg.global.ui.tips:showCountDown(realCountdown, NPC_DUEL_EXIT_COUNTDOWN_ID)
		end)

		time = time + realCountdown + 2

		timeline:createAndAddTrigger(time, function()
			tryNpcDuelExit()
		end)
		timeline:setDuration(time)
		timeline:start()
	end

	self.npcDuelEndUiDelayTimer = self:addTimer(freezeDuration + 1, function()
		self.npcDuelEndUiDelayTimer = nil

		playUiTimeline()
	end)
end

function ClientNpcDuelDungeon:onNpcDuelAllPetDeath(isSuccess)
	if self.npcDuelAllPetDeathTimeline or self.npcDuelAllPetDeathDelayTimer then
		return
	end

	local petEntity

	if isSuccess then
		local botEntity = pg.getEntity(self.npcDuelBotEntityId)

		petEntity = botEntity and botEntity:getCurPetEntity()
	else
		petEntity = pg.me and pg.me:getCurPetEntity()
	end

	if not petEntity then
		return
	end

	local dieAnimTime = AnimationUtils.getPlayableClipLength(petEntity, PlayableConst.Die, 0)
	local freezeDuration = SysConfigData.killBossFreezeDuration

	self.npcDuelAllPetDeathDelayTimer = self:addTimer(freezeDuration + 1, function()
		self.npcDuelAllPetDeathDelayTimer = nil

		local timeline = LuaTimeline.new()

		self.npcDuelAllPetDeathTimeline = timeline

		self:refreshNpcDuelEndTimelinesSpeed()
		timeline:setStopCallback(function()
			if self.npcDuelAllPetDeathTimeline == timeline then
				self.npcDuelAllPetDeathTimeline = nil
			end
		end)

		local time = dieAnimTime

		timeline:createAndAddTrigger(dieAnimTime, function()
			if petEntity then
				petEntity:playPetDeadDissolveEffect(dieAnimTime)
			end
		end)

		time = time + dieAnimTime

		timeline:createAndAddTrigger(dieAnimTime + dieAnimTime, function()
			if petEntity then
				petEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.NPC_DUEL_DIE, false)
			end
		end)

		time = time + 1

		timeline:setDuration(time)
		timeline:start()
	end)
end

function ClientNpcDuelDungeon:getExitCountDownTime()
	local defaultTime = 3
	local curNpcDuelId = pg.me.curNpcDuelId
	local curNpcDuelVariantId = pg.me.curNpcDuelVariantId
	local npcDuelData = NpcDuelData[curNpcDuelId] and NpcDuelData[curNpcDuelId][curNpcDuelVariantId]

	return npcDuelData and npcDuelData.exitSceneCountdown or defaultTime
end

function ClientNpcDuelDungeon:initNpcDuelCenterPositionAndRadius()
	if self.npcDuelCenterPosition and self.npcDuelAirWallRadius then
		return
	end

	local curNpcDuelId = pg.me.curNpcDuelId
	local curNpcDuelVariantId = pg.me.curNpcDuelVariantId
	local npcDuelData = NpcDuelData[curNpcDuelId] and NpcDuelData[curNpcDuelId][curNpcDuelVariantId]

	if not npcDuelData then
		return
	end

	local sceneId = npcDuelData.sceneId
	local centerPosId = npcDuelData.centerPos

	if not sceneId or not centerPosId then
		return
	end

	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(sceneId, self.id)
	local centerPointData = sceneMarkPointData and sceneMarkPointData[centerPosId]
	local centerPosition

	if centerPointData and centerPointData.markPosition then
		centerPosition = Utils.getPosByMarkData(centerPointData)
	end

	if not centerPosition then
		return
	end

	local offsetY = npcDuelData.airWallOffsetY or 0

	centerPosition = centerPosition + Vector3(0, offsetY, 0)
	self.npcDuelCenterPosition = centerPosition
	self.npcDuelAirWallRadius = npcDuelData.airWallRadius or 20
end

function ClientNpcDuelDungeon:npcDuelCreateAreaEffect()
	if not self.npcDuelCenterPosition then
		return
	end

	local curNpcDuelId = pg.me.curNpcDuelId
	local curNpcDuelVariantId = pg.me.curNpcDuelVariantId
	local npcDuelData = NpcDuelData[curNpcDuelId] and NpcDuelData[curNpcDuelId][curNpcDuelVariantId]

	if not npcDuelData then
		return
	end

	local scale = (npcDuelData.airWallRadius or 30) / 30

	pg.game.npcDuel:npcDuelCreateAreaEffect(self.npcDuelCenterPosition, scale)
end

function ClientNpcDuelDungeon:npcDuelStartTips(duration)
	pg.global.ui.tips:showA1Tips({
		id = "TowerResultStart",
		showText = pg.getGameString("NPCDUEL_BATTLE_START"),
		duration = duration or 3
	})
	pg.game.audio:playEvent("SFX_UI_Rouge_ChallengeBegins")
end

function ClientNpcDuelDungeon:startBotPositionCheckTimer()
	if self.botPositionCheckTimer then
		return
	end

	if not self.npcDuelCenterPosition or not self.npcDuelAirWallRadius then
		return
	end

	local maxDistance = self.npcDuelAirWallRadius + 2

	local function checkPosition(entity, entityName)
		if not entity then
			return
		end

		local entityPos = entity:getPosition()

		if not entityPos then
			return
		end

		local dx = entityPos.x - self.npcDuelCenterPosition.x
		local dz = entityPos.z - self.npcDuelCenterPosition.z
		local distanceXZ = math.sqrt(dx * dx + dz * dz)
		local dy = entityPos.y - self.npcDuelCenterPosition.y

		if distanceXZ > maxDistance or dy < -10 then
			local targetPosXZ = Vector3(self.npcDuelCenterPosition.x, entityPos.y, self.npcDuelCenterPosition.z)
			local groundPos, isValid = PhysicsUtils.getGroundPos(targetPosXZ, 200, nil, false, true, 200)

			if isValid then
				entity:setPosition(groundPos)
				logger:error(entityName .. " position corrected, distance: " .. distanceXZ .. ", max: " .. maxDistance .. ", new Y: " .. groundPos.y)
			else
				local fallbackPos = Vector3(self.npcDuelCenterPosition.x, self.npcDuelCenterPosition.y, self.npcDuelCenterPosition.z)

				entity:setPosition(fallbackPos)
				logger:error(entityName .. " position corrected (no ground found), distance: " .. distanceXZ .. ", max: " .. maxDistance .. ", fallback Y: " .. self.npcDuelCenterPosition.y)
			end
		end
	end

	self.botPositionCheckTimer = self:addRepeatTimer(1, function()
		local botEntity = pg.getEntity(self.npcDuelBotEntityId)

		checkPosition(botEntity and botEntity:getCurPetEntity(), "Bot pet")
		checkPosition(pg.pawn, "Player")
	end)
end

function ClientNpcDuelDungeon:stopBotPositionCheckTimer()
	if self.botPositionCheckTimer then
		self:removeTimer(self.botPositionCheckTimer)

		self.botPositionCheckTimer = nil
	end
end

function ClientNpcDuelDungeon:npcDuelSetJoyStickActive(active)
	if active then
		pg.global.ui:show(UIConst.UI_ID_HUD_MOBILE_OPERATE)
	else
		pg.global.ui:hide(UIConst.UI_ID_HUD_MOBILE_OPERATE)
	end
end

function ClientNpcDuelDungeon:destroy()
	if pg.game.npcDuel then
		pg.game.npcDuel:npcDuelRemoveAreaEffect()
	end

	pg.global.ui:show(UIConst.UI_ID_HUD_V2)
	self:unregisterBotPetCastAbilityListeners()
	pg.global.ui.tips:hideBattleRoomMechanismTips()

	if self.checkTimer ~= nil then
		TimerManager.removeTimer(self.checkTimer)

		self.checkTimer = nil
	end

	if self.botResumeAiTimer then
		self:removeTimer(self.botResumeAiTimer)

		self.botResumeAiTimer = nil
	end

	if self.npcDuelAutoLockTimer then
		self:removeTimer(self.npcDuelAutoLockTimer)

		self.npcDuelAutoLockTimer = nil
	end

	self:stopBotPositionCheckTimer()

	if self.npcDuelCameraTimeline then
		self.npcDuelCameraTimeline:stop()

		self.npcDuelCameraTimeline = nil
	end

	if pg.game.npcDuel then
		pg.game.npcDuel:clearNpcDuelStartFallbackTimer()
	end

	self:resetLoadingAudioVolume()
	pg.game.input:enablePlayerInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Move)
	self:npcDuelSetJoyStickActive(true)
	self:stopNpcDuelEndTimelines()
	pg.global.ui.tips:hideCountDown(NPC_DUEL_EXIT_COUNTDOWN_ID)
	pg.global.ui.tips:setBossTitleItemInvisibleReason("npcDuel", true)

	if pg.me and pg.me.setForbidAllAiHelper then
		pg.me:setForbidAllAiHelper(false)
	end

	ClientNpcDuelDungeon.super.destroy(self)
end

function ClientNpcDuelDungeon:getCurNpcDuelBotPetEntity()
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)

	if botEntity then
		return botEntity:getCurPetEntity()
	end
end

function ClientNpcDuelDungeon:npcDuelLeftTime()
	return math.max((self.npcDuelChallengeTotalSeconds or 0) - (self.npcDuelChallengeElapsedSeconds or 0), 0)
end

function ClientNpcDuelDungeon:onNpcDuelDefeatedBotPetCountChanged(ov, nv)
	facade:SendMessageCommand(MessageName.NPC_DUEL_TASKPROGRESS_UPDATE)
end

return ClientNpcDuelDungeon
