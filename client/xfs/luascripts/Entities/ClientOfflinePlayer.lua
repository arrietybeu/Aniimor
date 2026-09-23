-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientOfflinePlayer.lua

local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local GlobalData = require("Core.Client.GlobalData")
local EntityFactory = require("Core.Common.EntityFactory")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local AvatarData = require("Data.avatar_data")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local AttributeConst = require("Common.Const.AttributeConst")
local EventBus = require("Common.Ability.Buff.EventBus")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local PropertyData = require("Data.property_data")
local ActorInterface = require("Common.Ability.Attribute.ActorInterface")
local AIManager = require("Common.AI.AIManager")
local AbilityTimerManager = require("Common.Ability.AbilityTimerManager")
local AudioConst = require("Const.AudioConst")
local ClientUtils = require("Utils.ClientUtils")
local FEED_OFFLINE_SCENE_ID = 3007
local ClientOfflinePlayer = class.Class("ClientOfflinePlayer", ClientPawnEntity)
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientStaminaComponent = require("Entities.SpaceEntities.CommonComponent.ClientStaminaComponent")
local ActorCombatAttribute = require("Common.Ability.Attribute.ActorCombatAttribute")
local ClientOfflineCaptureComponent = require("Entities.SpaceEntities.PlayerComponent.ClientOfflineCaptureComponent")
local CharacterController = require("Common.Components.CharacterController")
local ClientDyingComponent = require("Entities.SpaceEntities.CommonComponent.ClientDyingComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local PlayerComponents = {
	CharacterController,
	ClientVoxelComponent,
	ClientStateCheckComponent,
	ClientDyingComponent,
	ClientMotionComponent,
	ClientStaminaComponent,
	ClientOfflineCaptureComponent
}

class.AddComponents(ClientOfflinePlayer, PlayerComponents)

function ClientOfflinePlayer:init(dict)
	self.isOfflineMainPlayer = true
	self.sceneId = dict.sceneId
	self.offlineIsReady = false

	local ret = ClientOfflinePlayer.super.init(self, dict)

	self.invQuickSlotBall = self.invQuickSlotBall or {}
	self.invEliteSlotBall = self.invEliteSlotBall or {}

	return ret
end

function ClientOfflinePlayer:initializeComponents()
	ClientOfflinePlayer.super.initializeComponents(self)
	self:addEModelComponent(Const.COMPONENT_INDEX_MAIN_PLAYER)
	self:addEModelComponent(Const.COMPONENT_MOTION)
	self:addEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	self:addEModelComponent(Const.COMPONENT_MAGNESIS_CONTROLLER)
end

function ClientOfflinePlayer:postInit(dict)
	ClientOfflinePlayer.super.postInit(self, dict)
end

function ClientOfflinePlayer:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.MAIN_PLAYER
end

function ClientOfflinePlayer:postInitializeComponents()
	ClientOfflinePlayer.super.postInitializeComponents(self)
	self:applyMotionProp()
	self:setSoundRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 1)
	self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_3P, 1)
end

function ClientOfflinePlayer:getEModelResId()
	return AddressDataConst.Ent_MainPlayer
end

function ClientOfflinePlayer:onEnterScene()
	ClientOfflinePlayer.super.onEnterScene(self)
	self:postComponentMethod("EVENT_RefreshPhysx")
	pg.global.scene:hideLoadingPanel()
	pg.global.ui.hudV2:open({
		isOffline = true
	})

	if self.sceneId == FEED_OFFLINE_SCENE_ID then
		pg.global.ui:open(UIConst.UI_ID_FEED_GAME_ENTRY)
	end

	pg.global.ui.tips:open(nil, function()
		if pg.global.ui.tips then
			pg.global.ui.tips:forceHideEdgeTipsAndAreaC(true)
			pg.global.ui.tips:setEdgeVisible(false)
		end
	end)

	if UIPlatformName == "mobile" then
		pg.global.ui.mobileOperate:open()
	end
end

function ClientOfflinePlayer:setControllerMachine()
	local avatarData = AvatarData[self.templateId]

	self.eModel:SetControllerMachine(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, ClientModelUtils.getAnimController(avatarData))
end

function ClientOfflinePlayer:isInCombat()
	return false
end

local function checkStatus(self, event, showMsg, exclude, noCancel)
	return true
end

local function ABILITY_ST(self)
	return false
end

local function getEntityIdByStaticId(self, staticId)
	return nil
end

function ClientOfflinePlayer:start()
	ClientOfflinePlayer.super.start(self)

	self.ABILITY_ST = ABILITY_ST
	self.actorType = Const.ACTOR_TYPE_PLAYER
	self.buffImmuneTag = 0
	self.buffTag = 0
	self.footprintSfxLevel = 1
	self.footprintInterval = 0.1
	self.guidanceCurs = {}
	self.checkStatus = checkStatus
	self.bodyMass = SysConfigData.avatarMass
	self.bodyWeight = SysConfigData.avatarWeight or 6
	self.authority = Const.AUTHORITY_MASTER
	self.subject = EventBus.EventSubject(self.actorId)
	self.baseAttr = {}
	self.specialContentDict = {}
	self.triggerMap = {}
	self.photoEntInRange = {}
	self.teamInfo = {
		membersInfo = {}
	}

	for i = 1, AttributeConst.GROUP_BASE_SINGLE_PROCESS_BEGIN - 1 do
		self.baseAttr[i] = 0
	end

	local templateData = self:getTemplateData()
	local propData = PropertyData[templateData.propId]

	self.actorCombatAttribute = ActorCombatAttribute(ActorInterface(self), pg.global.abilityMgr.actorAttributeModifier)

	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_max_cur, propData.stamina_max_v)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_cur, propData.stamina_max_v)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_regen_v, propData.stamina_regen_v)
	self.actorCombatAttribute:setAttribute(AttributeConst.stamina_regen_p, propData.stamina_regen_p or 0)

	self.pets = {
		[tostring(AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB)] = {
			templateId = SysConfigData.OffLineSpecificAbilityBindPetTable.Climb
		},
		[tostring(AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE)] = {
			templateId = SysConfigData.OffLineSpecificAbilityBindPetTable.Glide
		},
		[tostring(AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM)] = {
			templateId = SysConfigData.OffLineSpecificAbilityBindPetTable.Swim
		}
	}
	self.maxStamina = propData.stamina_max_v
	self.space = {
		getEntityIdByStaticId = getEntityIdByStaticId,
		isHomeland = function()
			return false
		end,
		checkImmuneFallDamage = function()
			return false
		end,
		isHomeCamp = function()
			return false
		end,
		isGrabEgg = function()
			return false
		end,
		isRogueEnv = function()
			return false
		end,
		onSceneLoaded = function()
			return
		end,
		isSupportPetMode = function()
			return false
		end,
		isMultiPlayerEnv = function()
			return false
		end,
		getLogicTime = function()
			return 0
		end,
		getGameTime = function()
			return 0
		end,
		getClientEntVisible = function()
			return true, true
		end,
		onEntityJoin = function()
			return
		end,
		onEntityLeave = function()
			return
		end,
		getGameTime = function()
			return Time.secondCache
		end,
		getGameTimeScale = function()
			return 1
		end
	}
	self.space.sceneId = self.sceneId or 100
	self.space.id = ""
	self.space.gameTimeScale = 1
	self.space.aiMgr = AIManager(self.space)

	self.space.aiMgr:init()

	self.aiTickFrameId = TimerManager.addRepeatNextFrameCb(function()
		self.space.aiMgr:tick(Time.unscaledDeltaTime)
	end)
	self.space.abilityTimerMgr = AbilityTimerManager(self.space)
	pg.playerPos = self:getPosition()

	pg.game:onPlayerInit(self)

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.stopPullServerList()
end

function ClientOfflinePlayer:destroy()
	if self.sceneId == FEED_OFFLINE_SCENE_ID then
		pg.global.ui:close(UIConst.UI_ID_FEED_GAME_ENTRY)
		pg.global.ui:close(UIConst.UI_ID_CAPTURE_BALL)
		pg.global.ui:close(UIConst.UI_ID_THROW_PANEL)
		pg.global.ui:close(UIConst.UI_ID_HUD_V2)
		pg.global.ui:close(UIConst.UI_ID_HUD_MOBILE_OPERATE)
		pg.global.ui:close(UIConst.UI_ID_TIPS)
	end

	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_UTILS)

	if self.offlinePuppetTimer then
		TimerManager.removeTimer(self.offlinePuppetTimer)

		self.offlinePuppetTimer = nil
	end

	if self.offlinePuppetActorIds then
		for actorId in pairs(self.offlinePuppetActorIds) do
			local puppet = pg.getEntityByActorId(actorId)

			if puppet then
				ClientUtils.safeDestroy(puppet)
			end
		end

		self.offlinePuppetActorIds = nil
	end

	if self.offlineSandboxIds then
		for sandboxId in pairs(self.offlineSandboxIds) do
			ClientUtils.tryWithLogError(function()
				appFacade.sandboxManager:DestroySandbox(sandboxId)
			end)
		end

		self.offlineSandboxIds = nil
	end

	if self.aiTickFrameId then
		TimerManager.delFrameCb(self.aiTickFrameId)

		self.aiTickFrameId = nil
	end

	ClientOfflinePlayer.super.destroy(self)

	if GlobalData.Player == self then
		GlobalData.Player = nil
	end

	pg.game:onPlayerDestroy(self)
end

function ClientOfflinePlayer:getWeather()
	return 0
end

function ClientOfflinePlayer:getCurPetEntity()
	return nil
end

function ClientOfflinePlayer:isDead()
	return false
end

function ClientOfflinePlayer:isControllingPet()
	return false
end

function ClientOfflinePlayer:canRotate()
	return false
end

function ClientOfflinePlayer:inBreak()
	return false
end

function ClientOfflinePlayer:canMove()
	return true
end

function ClientOfflinePlayer:isControllingMaster()
	return true
end

function ClientOfflinePlayer:isControllingExploreEnt()
	return false
end

function ClientOfflinePlayer:getPetInfo(petId)
	return petId
end

function ClientOfflinePlayer:getSpecificAbilityPetId(abilityId)
	return tostring(abilityId)
end

function ClientOfflinePlayer:getTemplateData()
	return AvatarData[self.templateId] or {}
end

function ClientOfflinePlayer:addStatData(data)
	return
end

function ClientOfflinePlayer:getStamina()
	return self.actorCombatAttribute:getAttribValue(AttributeConst.stamina_cur)
end

function ClientOfflinePlayer:getGameTime()
	return Time.secondCache
end

function ClientOfflinePlayer:getCurrScaledTime()
	return Time.realtimeSinceStartup
end

ClientOfflinePlayer:forceAttrRepeat("checkEnterCatchMode")

function ClientOfflinePlayer:checkEnterCatchMode(showMsg, exclude)
	return true
end

ClientOfflinePlayer:clearAttrRepeat()
ClientOfflinePlayer:forceAttrRepeat("getLogicState")

function ClientOfflinePlayer:getLogicState()
	local CharacterStateConst = require("Common.Const.CharacterStateConst")

	return CharacterStateConst.IDLE
end

ClientOfflinePlayer:clearAttrRepeat()
ClientOfflinePlayer:forceAttrRepeat("CROUCH_ST")

function ClientOfflinePlayer:CROUCH_ST()
	return false
end

ClientOfflinePlayer:clearAttrRepeat()

function ClientOfflinePlayer:isThrowItem()
	return false
end

function ClientOfflinePlayer:getRawAbility(abilityId, index)
	return nil
end

function ClientOfflinePlayer:cancelAbility()
	return
end

function ClientOfflinePlayer:getEntityIdByStaticId()
	return nil
end

function ClientOfflinePlayer:isAbilityEdgeBlocking()
	return false
end

function ClientOfflinePlayer:isAlive()
	return true
end

function ClientOfflinePlayer:tryClientTrigger(triggerType, triggerId, count, triggerParams)
	return
end

function ClientOfflinePlayer:getCurTeamInfo()
	return {}
end

function ClientOfflinePlayer:getAreaMeteorology()
	return 0
end

function ClientOfflinePlayer:playRougeSceneScan()
	return
end

function ClientOfflinePlayer:playBossRushSceneScan()
	return
end

function ClientOfflinePlayer:isControllingEgg()
	return false
end

function ClientOfflinePlayer:doGmCmd()
	return
end

function ClientOfflinePlayer:isTeamPlayerInWorld()
	return false
end

function ClientOfflinePlayer:getEntityAIEventInfo()
	return
end

return ClientOfflinePlayer
