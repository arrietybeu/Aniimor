-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Audio\\AudioSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local SceneData = require("Data.scene_data")
local Time = require("Core.Common.Time")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local logger = LoggerManager.getLogger("AudioSystem")
local SceneUtils = require("Common.Utils.SceneUtils")
local ElementPropData = require("Data.element_prop_data")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local Events = require("Common.Container.Events")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Lume = require("Core.Common.lume")
local WeatherData = require("Data.weather_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local decibel_grade_data = require("Data.decibel_grade_data")
local sys_config_data = require("Data.sys_config_data")
local AudioSystem = Class.LightClass("AudioSystem", SystemBase)

AudioSystem.SWITCH_ID_PRELOAD_CONFIG = {
	[AudioConst.SWITCH_GROUP_SEX] = {
		AudioConst.SWITCH_STATE_ID_BOY,
		AudioConst.SWITCH_STATE_ID_GIRL
	},
	[AudioConst.SWITCH_GROUP_SURFACE_MATERIAL] = {
		"swamp",
		"water",
		"snow",
		"ice",
		"sand",
		"grass",
		"metal",
		"concret",
		"soil",
		"stone",
		"wood"
	}
}
AudioSystem.SWITCH_DEFAULT_CONFIG = {
	[AudioConst.SWITCH_GROUP_SURFACE_MATERIAL] = AudioConst.SWITCH_STATE_SURFACE_MATERIAL_DEFAULT
}

local ToBool = ToBool
local ListenerFollowType = CS.FunPlus.WorldX.Manager.ListenerFollowType
local SoundType = CS.FunPlus.WorldX.Audio.SoundType
local EMPTY_TABLE = {}
local checkHateInterval = 0.1
local checkBgmAreaInterval = 0.2
local CombatBgmSilenceTime = 10
local changeAreaIdInterval = 2

AudioSystem.checkCombatBgmInterval = 1

function AudioSystem:getMessageBindMap()
	return {
		[MessageName.PLAYER_ONTELEPORT] = "onPlayerTeleport",
		[MessageName.TIMESCALE_CHANGE] = "onTimeScaleChange"
	}
end

function AudioSystem:onCtor()
	self.mgrInst = appFacade.audioManager
	self.currBgm = nil
	self.bgmStack = {}
	self.currAmb = nil
	self.ambStack = {}
	self.auxStack = {}
	self.sceneAreaData = {}
	self.lastCheckHateTime = 0
	self.lastCheckBgmAreaTime = 0
	self.lastCheckCombatBgmTime = 0
	self.curBlockAreaId = 0
	self.curBlockAreaIds = {}
	self.settingBlockAreaIds = {}
	self.tempBlockAreaIds = {}
	self.inTimeScaleSound = nil
	self.inSoundArea = false
	self.soundAreaState = nil
	self.combatBgmAreaId = nil
	self.muteLoseFocusAudio = false
	self.projectileHitCache = {}
	self.registerEventEntity = {}
	self.registerEventInfo = {}
	self.levelBgmInfo = {}
	self.levelAmbInfo = {}
	self.stateInfo = {}
	self.combatBgmState = {}
	self.volumeInfo = {}
	self.auxDisableInfo = {}
	self.combatBgmInfo = {}
	self.defaultCombatBgm = ""
	self.combatBgmResetTime = CombatBgmSilenceTime
	self.currentSceneId = nil
	self.sceneBerserkBgmEnabled = false
	self.decibelListeners = {}
	self.switchIdCache = {}
end

function AudioSystem:onInit()
	self:setConfiguredDefaultSwitches()
	self:preloadConfiguredSwitchIds()
	self:setRTPCValue(AudioConst.RTPC_PAMON_MOVEMENT, 1)
	self:setRTPCValue(AudioConst.RTPC_VOLUME_3P, 1)
	self:setRTPCValue(AudioConst.RTPC_VOLUME_EX, 1)
	self:playEvent(AudioConst.GAME_MUSIC_EVENT, nil, AudioConst.AkCallbackType.AK_MusicSyncAll, CallbackHandler(self, "_onAudioBgmEventCallbackGlobal"))
	self:setState(AudioConst.STATE_GROUP_GAME_MUSIC_STATE, "None")
	self:playEvent(AudioConst.GAME_WEATHER_EVENT, nil)
	self:setRTPCValue(AudioConst.RTPC_WEATHER_TYPE, 0)
end

function AudioSystem:onPlayerInit(player)
	local playerTemplateId = player.templateId
	local switchState

	if playerTemplateId == 4 then
		switchState = AudioConst.SWITCH_STATE_ID_BOY
	else
		switchState = AudioConst.SWITCH_STATE_ID_GIRL
	end

	self.playerSexSwitchState = switchState

	self.mgrInst:SetDefaultSwitch(AudioConst.SWITCH_GROUP_SEX, switchState)
	self:setPlayerSexSwitch()

	if player.setSoundSwitch then
		player:setSoundSwitch(AudioConst.SWITCH_GROUP_SEX, switchState)
	end
end

function AudioSystem:setPlayerSexSwitch(obj)
	if self.playerSexSwitchState == nil then
		return false
	end

	return self:setSwitch(AudioConst.SWITCH_GROUP_SEX, self.playerSexSwitchState, obj)
end

function AudioSystem:onPlayerDestroy(player)
	AudioSystem.super.onPlayerDestroy(self, player)

	self.playerSexSwitchState = nil
	self.combatBgmInfo = {}

	self:stopBgm(AudioConst.BgmPriority.BossDeath)
end

function AudioSystem:onPlayerTeleport()
	if self.combatBgmState.curState ~= AudioConst.BGMCombatState.Fading then
		return
	end

	self.combatBgmState.curState = AudioConst.BGMCombatState.Stop

	self:stopBgm(AudioConst.BgmPriority.Combat)
end

function AudioSystem:getMatchedAudioLanguage(language)
	return ClientConst.DefaultLangToAudioLangMap[language] or ClientConst.AudioLanguageType.en
end

function AudioSystem:initAudioLanguage()
	local audioLanguage = pg.game.setting:getString(ClientConst.PrefKey.AudioLanguage)

	if string.isNilOrEmpty(audioLanguage) then
		audioLanguage = self:getMatchedAudioLanguage(pg.game.setting:getLanguage())
	end

	self:setLanguage(audioLanguage, true)
end

function AudioSystem:getLanguage()
	return self.curLanguage
end

function AudioSystem:setLanguage(langName, skipSave)
	self.curLanguage = langName

	if not skipSave then
		pg.game.setting:setStringImmediately(ClientConst.PrefKey.AudioLanguage, langName)
	end

	if self:checkDisableVox() then
		self.mgrInst:SetLanguage("None")
	else
		self.mgrInst:SetLanguage(langName)
	end
end

function AudioSystem:checkDisableVox()
	return ClientConfigAppCountry == "vnm"
end

function AudioSystem:initLoseFocusAudio()
	local ClientSettingUtils = require("Utils.ClientSettingUtils")

	self.muteLoseFocusAudio = ClientSettingUtils.get_autoMute()

	self:onAppFocusChanged(pg.game.isFocused)
end

function AudioSystem:setLoseFocusAudio(enable)
	self.muteLoseFocusAudio = ToBool(enable)

	self:onAppFocusChanged(pg.game.isFocused)
end

function AudioSystem:onTimeScaleChange(timeScale)
	return
end

function AudioSystem:trySetState(stateGroup, stateId, reason, forceSet)
	reason = reason or "Default"
	self.stateInfo[stateGroup] = self.stateInfo[stateGroup] or {}
	self.stateInfo[stateGroup][reason] = stateId

	if forceSet then
		self:setState(stateGroup, stateId)

		return
	end

	self:refreshState(stateGroup)
end

function AudioSystem:refreshState(stateGroup)
	local stateInfo = self.stateInfo[stateGroup]
	local finalStateId
	local curPri = -1

	for reason, stateId in pairs(stateInfo) do
		local pri

		if AudioConst.StateIdPriority[stateGroup] and AudioConst.StateIdPriority[stateGroup][stateId] then
			pri = AudioConst.StateIdPriority[stateGroup][stateId]
		else
			pri = 0
		end

		if curPri <= pri then
			curPri = pri
			finalStateId = stateId
		end
	end

	self:setState(stateGroup, finalStateId)
end

function AudioSystem:setState(stateGroup, stateId)
	self.mgrInst:SetState(stateGroup, stateId)
end

function AudioSystem:setVolume(volumeKey, volume, reason)
	reason = reason or AudioConst.SetVolumeReason.Default

	if not self.volumeInfo[volumeKey] then
		self.volumeInfo[volumeKey] = {}
	end

	self.volumeInfo[volumeKey][reason] = volume

	self:refreshVolume(volumeKey)
end

function AudioSystem:refreshVolume(volumeKey)
	local volumeData = self.volumeInfo[volumeKey] or {}
	local volume = 100

	for i = AudioConst.SetVolumeReason.MAX, 1, -1 do
		if volumeData[i] then
			volume = volumeData[i]

			break
		end
	end

	self.mgrInst:SetRTPCValue(volumeKey, volume)
end

function AudioSystem:setRTPCValue(key, value, gameObject)
	self.mgrInst:SetRTPCValue(key, value, gameObject)
end

function AudioSystem:setGameObjectOutputBusVolume(gameObject, volumeRatio)
	if self.mgrInst.SetGameObjectOutputBusVolume then
		return self.mgrInst:SetGameObjectOutputBusVolume(gameObject, volumeRatio)
	end

	return false
end

function AudioSystem:getRTPCValue(key, gameObject)
	return self.mgrInst:GetRTPCValue(key, gameObject)
end

function AudioSystem:setBlockOtherPlayerAudio(enable)
	self.mgrInst:SetBlockOtherPlayerAudio(ToBool(enable))
end

function AudioSystem:playCombat(eventName, gameObject, combatRTPCType)
	if string.isNilOrEmpty(eventName) then
		return
	end

	if combatRTPCType == nil then
		self.mgrInst:PlayEvent(eventName, gameObject)

		return
	end

	self.mgrInst:PlayCombatEvent(eventName, gameObject, combatRTPCType)
end

function AudioSystem:playCombatAtPos(eventName, pos, combatRTPCType)
	if string.isNilOrEmpty(eventName) then
		return
	end

	if combatRTPCType == nil then
		self.mgrInst:PlayEvent(eventName, pos)

		return
	end

	self.mgrInst:PlayCombatEventAtPos(eventName, pos, combatRTPCType)
end

function AudioSystem:playHit(atkType, hitType, materialType, position, combatRTPCType)
	if atkType and hitType and materialType then
		local eventName = string.format("battle_mathit_%s_%s_%s", materialType, atkType, hitType)

		self:playCombatAtPos(eventName, position, combatRTPCType)
	end
end

function AudioSystem:playSoundAtPos(eventName, pos, combatRTPCType)
	if eventName and pos then
		self:playCombatAtPos(eventName, pos, combatRTPCType)
	end
end

function AudioSystem:playProjectileHit(elementType, hitSoundType, position, combatRTPCType)
	if elementType and hitSoundType then
		local eventName

		if self.projectileHitCache[elementType] and self.projectileHitCache[elementType][hitSoundType] then
			eventName = self.projectileHitCache[elementType][hitSoundType]
		else
			eventName = string.format("battle_projectilehit_%s_%s", ElementPropData[elementType].projectileHitSound, hitSoundType)

			if not self.projectileHitCache[elementType] then
				self.projectileHitCache[elementType] = {}
			end

			self.projectileHitCache[elementType][hitSoundType] = eventName
		end

		self:playCombatAtPos(eventName, position, combatRTPCType)
	end
end

function AudioSystem:playHitById(hitSoundId, position, combatRTPCType)
	if not ToBool(hitSoundId) then
		return
	end

	self:playCombatAtPos(hitSoundId, position, combatRTPCType)
end

function AudioSystem:triggerEvent(eventName, obj, stopTime, eventMask, eventCallback)
	if string.isNilOrEmpty(eventName) then
		return
	end

	self:playEvent(eventName, obj, eventMask, eventCallback)

	if stopTime ~= nil and stopTime > 0 then
		self:startTimer(function()
			self.mgrInst:StopEvent(eventName, obj)
		end, stopTime)
	end
end

function AudioSystem:setSwitch(groupName, switchName, obj)
	if string.isNilOrEmpty(groupName) then
		return
	end

	return self.mgrInst:SetSwitch(groupName, switchName, obj)
end

function AudioSystem:tryGetSwitchIds(switchGroupName, switchStateName)
	if string.isNilOrEmpty(switchGroupName) or string.isNilOrEmpty(switchStateName) then
		return false, 0, 0
	end

	self.switchIdCache = self.switchIdCache or {}

	local switchGroupCache = self.switchIdCache[switchGroupName]

	if switchGroupCache and switchGroupCache.switchStateIds then
		local switchStateId = switchGroupCache.switchStateIds[switchStateName]

		if switchStateId ~= nil then
			return true, switchGroupCache.switchGroupId, switchStateId
		end
	end

	local success, switchGroupId, switchStateId = self.mgrInst:TryGetSwitchIds(switchGroupName, switchStateName)

	if not success then
		return false, 0, 0
	end

	if not switchGroupCache or not switchGroupCache.switchStateIds or switchGroupCache.switchGroupId ~= switchGroupId then
		switchGroupCache = {
			switchGroupId = switchGroupId,
			switchStateIds = {}
		}
		self.switchIdCache[switchGroupName] = switchGroupCache
	end

	switchGroupCache.switchStateIds[switchStateName] = switchStateId

	return true, switchGroupId, switchStateId
end

function AudioSystem:preloadSwitchIds(switchGroupName, switchStateNames)
	if string.isNilOrEmpty(switchGroupName) or type(switchStateNames) ~= "table" then
		return false
	end

	local allSuccess = true

	for _, switchStateName in ipairs(switchStateNames) do
		local success = self:tryGetSwitchIds(switchGroupName, switchStateName)

		if not success then
			allSuccess = false

			logger:error("Failed to preload switch ids, groupName:%s, stateName:%s", switchGroupName, switchStateName)
		end
	end

	return allSuccess
end

function AudioSystem:preloadConfiguredSwitchIds()
	local allSuccess = true

	for switchGroupName, switchStateNames in pairs(AudioSystem.SWITCH_ID_PRELOAD_CONFIG) do
		if not self:preloadSwitchIds(switchGroupName, switchStateNames) then
			allSuccess = false
		end
	end

	return allSuccess
end

function AudioSystem:setConfiguredDefaultSwitches()
	local allSuccess = true

	for switchGroupName, switchStateName in pairs(AudioSystem.SWITCH_DEFAULT_CONFIG) do
		if not self.mgrInst:SetDefaultSwitch(switchGroupName, switchStateName) then
			allSuccess = false

			logger:error("Failed to set default switch, groupName:%s, stateName:%s", switchGroupName, switchStateName)
		end
	end

	return allSuccess
end

function AudioSystem:setSwitchById(switchGroupId, switchStateId, obj)
	if switchGroupId == nil or switchGroupId == 0 or switchStateId == nil or switchStateId == 0 then
		return false
	end

	return self.mgrInst:SetSwitchById(switchGroupId, switchStateId, obj)
end

function AudioSystem:playEvent(eventName, obj, eventMask, eventCallback, playAfterDestroy)
	if string.isNilOrEmpty(eventName) then
		return
	end

	eventMask = eventMask or 0
	playAfterDestroy = playAfterDestroy or false

	self.mgrInst:PlayEvent(eventName, obj, eventMask, eventCallback, playAfterDestroy)
end

function AudioSystem:playPetEmotionSound(templateId, emotion, obj)
	local petData = PetData[tonumber(templateId) or templateId]

	if not petData or not petData.resId or string.isNilOrEmpty(emotion) then
		return false
	end

	local eventName = string.format("VOX_Emotion_Parmon_%s_%s", tostring(petData.resId), emotion)

	self:playEvent(eventName, obj)

	return true
end

function AudioSystem:seekEvent(eventName, obj, seekTime)
	if string.isNilOrEmpty(eventName) then
		return
	end

	self.mgrInst:SeekEvent(eventName, obj, seekTime)
end

function AudioSystem:stopEvent(eventName, obj, fadeTime, force)
	if string.isNilOrEmpty(eventName) then
		return
	end

	fadeTime = fadeTime or 0.1
	force = force or false

	self.mgrInst:StopEvent(eventName, obj, fadeTime, force)
end

function AudioSystem:isSceneBerserkBgmEnabled(sceneId)
	local space = pg.me and pg.me.space

	if not space or space.sceneId ~= sceneId or not Utils.isRobEggUnderGround(space.spaceType) then
		return false
	end

	return space.useAfterViewLimitFog == true
end

function AudioSystem:getSceneBgm(sceneInfo)
	if self.sceneBerserkBgmEnabled then
		return sceneInfo.berserkBgm or sceneInfo.bgm
	end

	return sceneInfo.bgm
end

function AudioSystem:getSceneCombatBgm(sceneInfo)
	if self.sceneBerserkBgmEnabled then
		return sceneInfo.berserkCombatBgm or sceneInfo.combatBgm or "BGM_Normal_Combat01"
	end

	return sceneInfo.combatBgm or "BGM_Normal_Combat01"
end

function AudioSystem:setSceneBerserkBgmEnabled(sceneId, enable)
	if self.currentSceneId ~= sceneId then
		return
	end

	enable = enable == true

	if self.sceneBerserkBgmEnabled == enable then
		return
	end

	self.sceneBerserkBgmEnabled = enable

	local mainSceneId = SceneUtils.getMainSceneId(sceneId)
	local sceneInfo = SceneData[sceneId] or EMPTY_TABLE

	self.defaultCombatBgm = self:getSceneCombatBgm(sceneInfo)

	local priority = mainSceneId == sceneId and AudioConst.BgmPriority.Scene or AudioConst.BgmPriority.SeamlessScene

	self:playBgm(self:getSceneBgm(sceneInfo), priority)
	self:updateCombatBgmState()
end

function AudioSystem:onSceneLoaded(sceneId, sceneName)
	self:resetTimelineClipDisabledAudio()

	self.currentSceneId = sceneId
	self.sceneBerserkBgmEnabled = self:isSceneBerserkBgmEnabled(sceneId)

	local mainSceneId = SceneUtils.getMainSceneId(sceneId)
	local sceneInfo = SceneData[sceneId] or EMPTY_TABLE
	local mainSceneInfo = SceneData[mainSceneId] or EMPTY_TABLE

	self.disableBattleMusic = sceneInfo.noBattleMusic or false
	self.defaultCombatBgm = self:getSceneCombatBgm(sceneInfo)
	self.defaultExitCombatBgm = sceneInfo.exitCombatBgm or "BGM_Slience"
	self.combatBgmResetTime = sceneInfo.combatBgmResetTime or CombatBgmSilenceTime

	if mainSceneId ~= sceneId then
		self:playBgm(self:getSceneBgm(sceneInfo), AudioConst.BgmPriority.SeamlessScene)
		self:playAmb(sceneInfo.amb or nil, AudioConst.BgmPriority.SeamlessScene)
	else
		self:playBgm(nil, AudioConst.BgmPriority.SeamlessScene)
		self:playAmb(nil, AudioConst.BgmPriority.SeamlessScene)
	end

	local mainSceneBgm = mainSceneInfo.bgm

	if mainSceneId == sceneId then
		mainSceneBgm = self:getSceneBgm(mainSceneInfo)
	end

	self:playBgm(mainSceneBgm, AudioConst.BgmPriority.Scene, true)
	self:playAmb(mainSceneInfo.amb or nil, AudioConst.BgmPriority.Scene, true)
	self:setAuxName(sceneInfo.reverb, AudioConst.BgmPriority.Scene)
	self.mgrInst:SetListenerFollowType(ListenerFollowType.Player)
	self:refreshTimePeriodRTPC()
	self:refreshDungeonState()
end

function AudioSystem:onSceneUnloaded(sceneId, sceneName)
	if self.currentSceneId == sceneId then
		self.currentSceneId = nil
		self.sceneBerserkBgmEnabled = false
	end

	self:resetMapBlockId()
	self:playBgm(nil, AudioConst.BgmPriority.Scene)
	self:playAmb(nil, AudioConst.BgmPriority.Scene)
	self:playBgm(nil, AudioConst.BgmPriority.SeamlessScene)
	self:playAmb(nil, AudioConst.BgmPriority.SeamlessScene)
	self:playBgm(nil, AudioConst.BgmPriority.BgmArea)
	self:playAmb(nil, AudioConst.BgmPriority.BgmArea)

	self.mgrInst.isInDungeon = false
end

function AudioSystem:onTick()
	local now = Time.realSecondCache

	if now - self.lastCheckHateTime > checkHateInterval then
		self.lastCheckHateTime = now
	end

	if now - self.lastCheckBgmAreaTime > checkBgmAreaInterval then
		self:updateSoundArea()

		self.lastCheckBgmAreaTime = now
	end

	self:updateAuxEnvBus()

	if now - self.lastCheckCombatBgmTime > AudioSystem.checkCombatBgmInterval then
		self:checkBossEliteValid()

		self.lastCheckCombatBgmTime = now
	end

	self:updateCombatBgmState()

	if self.bgmDirty then
		self.bgmDirty = false

		self:refreshBgm()
	end

	if self.ambDirty then
		self.ambDirty = false

		self:refreshAmb()
	end
end

function AudioSystem:checkEventValid(eventName)
	if not string.isNilOrEmpty(eventName) and not self:isNullEvent(eventName) and not self:isEmptyEvent(eventName) then
		return true
	end

	return false
end

function AudioSystem:getCurBgmAndMaxPriority()
	local curBgm
	local curPriority = 0

	for i = AudioConst.BgmPriority.MAX, 1, -1 do
		curBgm = self:getBGMStackBgmStr(i)

		if curBgm then
			curPriority = i

			break
		end
	end

	return curBgm, curPriority
end

function AudioSystem:refreshBgm()
	local curBgm, curPriority = self:getCurBgmAndMaxPriority()

	if curBgm then
		if curBgm ~= self.currBgm then
			if self:checkEventValid(self.currBgm) then
				self:stopEvent(self.currBgm, nil, 2)
			end

			self.currBgm = curBgm

			if not self:isNullEvent(curBgm) and not self:isEmptyEvent(curBgm) then
				self:playEvent(curBgm, nil, AudioConst.AkCallbackType.AK_MusicSyncAll, CallbackHandler(self, "_onAudioBgmEventCallback", curBgm))
			elseif not self:isEmptyEvent(curBgm) then
				self:setState(AudioConst.STATE_GROUP_GAME_MUSIC_STATE, "None")
			end
		end
	else
		if self:checkEventValid(self.currBgm) then
			self:stopEvent(self.currBgm, nil, 2)
			self:setState(AudioConst.STATE_GROUP_GAME_MUSIC_STATE, "None")
		end

		self.currBgm = nil
	end

	self.curBgmPriority = curPriority

	if curPriority > AudioConst.BgmPriority.SceneEmitter then
		self.mgrInst:SetSceneSoundEmitterValid(SoundType.Bgm, false)
	else
		self.mgrInst:SetSceneSoundEmitterValid(SoundType.Bgm, true)
	end
end

function AudioSystem:getCurSceneAreaId(position, curAreaId)
	local maxWeight = -999999
	local resultAreaId

	for areaId, areaInfo in pairs(self.sceneAreaData) do
		if areaId == curAreaId then
			if Vector3.SqrDistance(position, areaInfo.position) <= areaInfo.exitRadius * areaInfo.exitRadius and maxWeight <= areaInfo.weight then
				maxWeight = areaInfo.weight
				resultAreaId = areaId
			end
		elseif Vector3.SqrDistance(position, areaInfo.position) <= areaInfo.enterRadius * areaInfo.enterRadius and maxWeight < areaInfo.weight then
			maxWeight = areaInfo.weight
			resultAreaId = areaId
		end
	end

	return resultAreaId
end

function AudioSystem:updateMapBlockId()
	pg.game.map:getCurBlockAreaIds(self.tempBlockAreaIds)

	local curTime = Time.realSecondCache

	for _, areaBlockId in ipairs(self.tempBlockAreaIds) do
		self.curBlockAreaIds[areaBlockId] = curTime
	end

	for areaBlockId, time in pairs(self.curBlockAreaIds) do
		if curTime > time + changeAreaIdInterval then
			self.curBlockAreaIds[areaBlockId] = nil
		end
	end

	local maxBgmPriority = -1
	local maxCombatBgmPriority = -1
	local combatBgmAreaId, bgmBlockAreaId
	local tempBlockIndex = 1

	for areaBlockId, _ in pairs(self.curBlockAreaIds) do
		self.tempBlockAreaIds[tempBlockIndex] = areaBlockId
		tempBlockIndex = tempBlockIndex + 1

		local blockConfigData = MapBlockConfigData[areaBlockId]
		local areaPriority = blockConfigData.bgmPriority

		if blockConfigData.bgmEvent and areaPriority and maxBgmPriority < areaPriority then
			maxBgmPriority = areaPriority
			bgmBlockAreaId = areaBlockId
		end

		if blockConfigData.combatBgm and areaPriority and maxCombatBgmPriority < areaPriority then
			maxCombatBgmPriority = areaPriority
			combatBgmAreaId = areaBlockId
		end
	end

	for i = tempBlockIndex, #self.tempBlockAreaIds do
		self.tempBlockAreaIds[i] = nil
	end

	self.combatBgmAreaId = combatBgmAreaId
	self.curBlockAreaId = pg.game.map:getMaxPriorityMainAreaId(self.tempBlockAreaIds)

	self:refreshWeatherInfo(self.curBlockAreaId)
	self:setMapBlockAreaIds(self.tempBlockAreaIds)

	if bgmBlockAreaId then
		local bgmEvent, ambEvent = MapBlockConfigData[bgmBlockAreaId].bgmEvent, MapBlockConfigData[bgmBlockAreaId].ambEvent

		if bgmEvent then
			self:playBgm(bgmEvent, AudioConst.BgmPriority.BgmArea)
		end

		if ambEvent then
			self:playAmb(ambEvent, AudioConst.BgmPriority.BgmArea)
		end
	else
		self:playBgm(nil, AudioConst.BgmPriority.BgmArea)
		self:playAmb(nil, AudioConst.BgmPriority.BgmArea)
	end
end

function AudioSystem:resetMapBlockId()
	table.clear(self.curBlockAreaIds)

	self.curBlockAreaId = 0

	self:setMapBlockAreaIds({})
	self:refreshWeatherInfo(0)
end

function AudioSystem:setMapBlockAreaIds(areaIds)
	local changed = false

	if #self.settingBlockAreaIds ~= #areaIds then
		table.clear(self.settingBlockAreaIds)

		changed = true
	end

	for i, val in pairs(areaIds) do
		if self.settingBlockAreaIds[i] ~= val then
			changed = true
		end

		self.settingBlockAreaIds[i] = val
	end

	if changed then
		self.mgrInst:SetMapBlockAreaIds(areaIds)
	end
end

function AudioSystem:refreshWeatherInfo(curBlockAreaId)
	local curWeatherId

	if not pg.me or not pg.me.weatherInfoForecast then
		curWeatherId = nil
	else
		local weatherInfo = pg.me.weatherInfoForecast[curBlockAreaId]

		if weatherInfo and #weatherInfo > 0 then
			curWeatherId = weatherInfo[1].weatherId
		end
	end

	if self.curWeatherId ~= curWeatherId then
		self.curWeatherId = curWeatherId

		local weatherData = WeatherData[curWeatherId] or EMPTY_TABLE
		local weatherRTPC = weatherData.weatherRTPC or 0

		self:setRTPCValue(AudioConst.RTPC_WEATHER_TYPE, weatherRTPC)
	end
end

function AudioSystem:onTimePeriodChange(timePeriod)
	self:refreshTimePeriodRTPC()
end

function AudioSystem:refreshTimePeriodRTPC()
	local timePeriod = pg.timePeriod
	local timePeriodRTPC = timePeriod == Const.TimePeriod.Night and 20 or 9

	self.curTimePeriodRTPC = timePeriodRTPC

	self:setRTPCValue(AudioConst.RTPC_TIME, timePeriodRTPC)
end

function AudioSystem:refreshDungeonState()
	local isInDungeon = false

	if pg.space then
		isInDungeon = pg.space:isPVEDungeon()
	end

	self.mgrInst.isInDungeon = isInDungeon
end

function AudioSystem:updateSoundArea()
	local pawn = pg.pawn

	self.inSoundArea = false
	self.soundAreaState = nil

	if pawn and pawn.space then
		self:updateMapBlockId()

		local enableBgm, bgmEvent, bgmState, enableAmb, ambEvent, enableAux, auxEvent = self.mgrInst:QuerySoundAreaInfoEx()

		if enableBgm or enableAmb or enableAux then
			self.inSoundArea = true
			self.soundAreaState = bgmState
		end

		if enableBgm then
			if bgmEvent == "bgm_scene_3000" then
				bgmEvent = bgmState
			end

			bgmEvent = bgmEvent or "None"

			self:playBgm(bgmEvent, AudioConst.BgmPriority.SoundArea)
		else
			self:playBgm(nil, AudioConst.BgmPriority.SoundArea)
		end

		if enableAmb then
			self:playAmb(ambEvent, AudioConst.BgmPriority.SoundArea)
		else
			self:playAmb(nil, AudioConst.BgmPriority.SoundArea)
		end

		if enableAux then
			self:setAuxName(auxEvent, AudioConst.BgmPriority.SoundArea)
		else
			self:setAuxName(nil, AudioConst.BgmPriority.SoundArea)
		end

		local isInBgmEventRange = self.mgrInst.isInBgmEventRange

		if isInBgmEventRange then
			self:playBgm("", AudioConst.BgmPriority.SceneEmitter)
		else
			self:playBgm(nil, AudioConst.BgmPriority.SceneEmitter)
		end

		local isInAmbEventRange = self.mgrInst.isInAmbEventRange

		if isInAmbEventRange then
			self:playAmb("", AudioConst.BgmPriority.SceneEmitter)
		else
			self:playAmb(nil, AudioConst.BgmPriority.SceneEmitter)
		end

		if self.mgrInst.roomDisableAmb then
			self:playAmb("", AudioConst.BgmPriority.Room)
		else
			self:playAmb(nil, AudioConst.BgmPriority.Room)
		end

		if self.mgrInst.roomDisableBgm then
			self:playBgm("", AudioConst.BgmPriority.Room)
		else
			self:playBgm(nil, AudioConst.BgmPriority.Room)
		end
	else
		self:playBgm(nil, AudioConst.BgmPriority.Room)
		self:playAmb(nil, AudioConst.BgmPriority.Room)
		self:playAmb(nil, AudioConst.BgmPriority.SceneEmitter)
		self:playBgm(nil, AudioConst.BgmPriority.SceneEmitter)
		self:playBgm(nil, AudioConst.BgmPriority.SoundArea)
		self:playAmb(nil, AudioConst.BgmPriority.SoundArea)
		self:playBgm(nil, AudioConst.BgmPriority.BgmArea)
		self:playAmb(nil, AudioConst.BgmPriority.BgmArea)
	end
end

function AudioSystem:onAppFocusChanged(focus, fromApplicationPause)
	if UNITY_IOS then
		return
	end

	if not UNITY_STANDALONE and not fromApplicationPause then
		return
	end

	local muted = not focus

	if pg.game.setting.curPlatform == "Windows" and not self.muteLoseFocusAudio then
		muted = false
	end

	self.mgrInst:SetWwiseBackgroundMuted(muted)
end

function AudioSystem:setCombatBgmInfo(actorId, bgm, type)
	self.combatBgmState.bossList = self.combatBgmState.bossList or {}
	self.combatBgmState.eliteList = self.combatBgmState.eliteList or {}

	if not bgm then
		self.combatBgmState.bossList[actorId] = nil
		self.combatBgmState.eliteList[actorId] = nil
	elseif type == AudioConst.BgmPriority.Boss then
		self.combatBgmState.bossList[actorId] = bgm
	elseif type == AudioConst.BgmPriority.Elite then
		self.combatBgmState.eliteList[actorId] = bgm
	end
end

function AudioSystem:checkBossEliteValid()
	local state = self.combatBgmState

	if state.bossList then
		for actorId in pairs(state.bossList) do
			local ent = pg.getEntityByActorId(actorId)

			if not ent or ent.isDestroyed then
				state.bossList[actorId] = nil
			end
		end
	end

	if state.eliteList then
		for actorId in pairs(state.eliteList) do
			local ent = pg.getEntityByActorId(actorId)

			if not ent or ent.isDestroyed then
				state.eliteList[actorId] = nil
			end
		end
	end
end

function AudioSystem:updateCombatBgmState()
	local needPlayCombatBgm = false
	local resultBgm, exitCombatBgm, resultBossBgm, resultEliteBgm
	local isUseSceneBgm = false
	local space = pg.me and pg.me.space
	local isNpcDuelActive = space and space.isNpcDuelActive and space:isNpcDuelActive()

	if not self.disableBattleMusic then
		local bossId, bossBgm = next(self.combatBgmState.bossList or EMPTY_TABLE)

		if bossBgm then
			resultBossBgm = bossBgm
		end

		local eliteId, eliteBgm = next(self.combatBgmState.eliteList or EMPTY_TABLE)

		if eliteBgm then
			resultEliteBgm = eliteBgm
		end

		if isNpcDuelActive or pg.me and (pg.me:isInCombat() or resultEliteBgm or resultBossBgm) then
			needPlayCombatBgm = true

			if not resultBossBgm then
				for actorId, _ in pairs(pg.me.behatredMap) do
					local ent = pg.getEntityByActorId(actorId)

					if ent then
						if Utils.isBoss(ent) then
							if not self:isNullEvent(PuppetData[ent.templateId].combatBgm) then
								resultBossBgm = resultBossBgm or PuppetData[ent.templateId].combatBgm
							end
						elseif Utils.isElite(ent) and not self:isNullEvent(PuppetData[ent.templateId].combatBgm) then
							resultEliteBgm = resultEliteBgm or PuppetData[ent.templateId].combatBgm
						end
					end
				end
			end

			if isNpcDuelActive then
				isUseSceneBgm = true
				exitCombatBgm = self.defaultExitCombatBgm
				resultBgm = self.defaultCombatBgm
			elseif resultBossBgm then
				resultBgm = resultBossBgm
			elseif resultEliteBgm then
				resultBgm = resultEliteBgm
			else
				isUseSceneBgm = true

				if self.combatBgmAreaId and self.combatBgmAreaId ~= 0 then
					exitCombatBgm = MapBlockConfigData[self.combatBgmAreaId].exitCombatBgm
					resultBgm = MapBlockConfigData[self.combatBgmAreaId].combatBgm
				else
					exitCombatBgm = self.defaultExitCombatBgm
					resultBgm = self.defaultCombatBgm
				end
			end
		else
			needPlayCombatBgm = false
		end
	end

	if needPlayCombatBgm then
		local isSameBgm = false

		if self.combatBgmState.curState == AudioConst.BGMCombatState.Playing then
			if self.combatBgmState.combatBgm == resultBgm then
				isSameBgm = true
			end

			if not isSameBgm and self.combatBgmState.exitCombatBgm then
				self:triggerEvent(self.combatBgmState.exitCombatBgm)
			end
		end

		self.combatBgmState.isNpcDuel = isNpcDuelActive

		if not isSameBgm then
			self.combatBgmState.curState = AudioConst.BGMCombatState.Playing
			self.combatBgmState.inCombat = true
			self.combatBgmState.enterCombatTime = Time.realSecondCache
			self.combatBgmState.isUseSceneBgm = isUseSceneBgm
			self.combatBgmState.combatBgm = resultBgm
			self.combatBgmState.exitCombatBgm = exitCombatBgm or "BGM_Slience"

			self:playBgm(self.combatBgmState.combatBgm, AudioConst.BgmPriority.Combat)
		end
	elseif self.combatBgmState.isNpcDuel then
		self.combatBgmState.curState = AudioConst.BGMCombatState.Stop
		self.combatBgmState.inCombat = false
		self.combatBgmState.isNpcDuel = nil
		self.combatBgmState.combatBgm = nil
		self.combatBgmState.exitCombatBgm = nil

		self:stopBgm(AudioConst.BgmPriority.Combat)
	elseif self.combatBgmState.curState == AudioConst.BGMCombatState.Playing then
		self.combatBgmState.curState = AudioConst.BGMCombatState.Fading
		self.combatBgmState.inCombat = false
		self.combatBgmState.leaveCombatTime = Time.realSecondCache

		if self.combatBgmState.exitCombatBgm then
			self:triggerEvent(self.combatBgmState.exitCombatBgm)
		end

		self:playBgm("Empty", AudioConst.BgmPriority.Combat)
	elseif self.combatBgmState.curState == AudioConst.BGMCombatState.Fading and Time.realSecondCache > self.combatBgmState.leaveCombatTime + self.combatBgmResetTime then
		self.combatBgmState.curState = AudioConst.BGMCombatState.Stop

		self:stopBgm(AudioConst.BgmPriority.Combat)
	end
end

function AudioSystem:setAuxName(auxName, priority)
	if not priority then
		return
	end

	if self.auxStack[priority] ~= auxName then
		self.auxStack[priority] = auxName
		self.auxName = self:innerGetAuxName()
	end
end

function AudioSystem:innerGetAuxName()
	local curAux

	for i = AudioConst.BgmPriority.MAX, 1, -1 do
		curAux = self.auxStack[i]

		if curAux then
			break
		end
	end

	return curAux
end

function AudioSystem:updateAuxEnvBus()
	local auxEnvBus

	if Utils.tableIsEmptyOrNil(self.auxDisableInfo) then
		auxEnvBus = self.auxName

		if pg.pawn then
			auxEnvBus = pg.pawn.auxEnvState or self.auxName
		end
	end

	self:innerSetAuxEnvBus(auxEnvBus)
end

function AudioSystem:disableAuxEnvBus(reason, disable)
	reason = reason or AudioConst.DisableAuxEnvReason.Default

	if disable then
		self.auxDisableInfo[reason] = false
	else
		self.auxDisableInfo[reason] = nil
	end

	self:updateAuxEnvBus()
end

function AudioSystem:setAttenGroupState(reason, enabled)
	reason = reason or AudioConst.AttenGroupStateReason.Default

	self:trySetState(AudioConst.STATE_GROUP_ATTENUATION, enabled and AudioConst.ATTENUATION_STATE_ID_ATTENUATION or AudioConst.ATTENUATION_STATE_ID_NORMAL, reason)
end

function AudioSystem:innerSetAuxEnvBus(auxName)
	if self.curAuxEnvBus ~= auxName then
		self.curAuxEnvBus = auxName

		self.mgrInst:SetGlobalAuxEnv(auxName)
	end
end

function AudioSystem:isEmptyEvent(eventName)
	return eventName == "Empty"
end

function AudioSystem:isNullEvent(eventName)
	return eventName == "None" or eventName == ""
end

function AudioSystem:getBGMStackBgmStr(priority, actorId)
	if priority == AudioConst.BgmPriority.Elite or priority == AudioConst.BgmPriority.Boss then
		if self.bgmStack[priority] then
			if actorId then
				return self.bgmStack[priority][actorId]
			end

			local _, nextBgmInfo = next(self.bgmStack[priority])

			return nextBgmInfo
		end

		return
	end

	return self.bgmStack[priority]
end

function AudioSystem:setBGMStackBgmStr(priority, bgmStr, actorId)
	local changed = false

	if priority == AudioConst.BgmPriority.Elite or priority == AudioConst.BgmPriority.Boss then
		if not self.bgmStack[priority] then
			self.bgmStack[priority] = {}
		end

		if actorId then
			if not bgmStr then
				if self.bgmStack[priority][actorId] then
					self.bgmStack[priority][actorId] = nil
					changed = true
				end
			elseif self.bgmStack[priority][actorId] ~= bgmStr then
				changed = true
			end
		end

		return
	end

	if not bgmStr then
		if self.bgmStack[priority] then
			changed = true
			self.bgmStack[priority] = nil
		end
	elseif self.bgmStack[priority] ~= bgmStr then
		changed = true
		self.bgmStack[priority] = bgmStr
	end

	return changed
end

function AudioSystem:checkBGMStackBgmStrSame(priority, bgmStr, actorId)
	local curBgmInfo = self:getBGMStackBgmStr(priority, actorId)

	return curBgmInfo == bgmStr
end

function AudioSystem:playBgm(bgmStr, priority, forceReset, actorId)
	local protectHigherPriorityBgm = false

	if forceReset then
		local topBgm, topPriority = self:getCurBgmAndMaxPriority()

		protectHigherPriorityBgm = self:checkEventValid(self.currBgm) and topBgm == self.currBgm and priority < topPriority

		if not protectHigherPriorityBgm and self:checkEventValid(self.currBgm) then
			self:stopEvent(self.currBgm)
		end

		if not protectHigherPriorityBgm then
			self:playEvent("Game_Music_State_Clear")

			self.currBgm = nil
		end
	elseif self:checkBGMStackBgmStrSame(priority, bgmStr, actorId) then
		return
	end

	local changed = self:setBGMStackBgmStr(priority, bgmStr, actorId)

	if forceReset and not protectHigherPriorityBgm then
		self:refreshBgm()

		self.bgmDirty = false
	else
		self.bgmDirty = self.bgmDirty or changed
	end
end

function AudioSystem:disableBgmByTimelineClip(isDisable, disableAmb)
	self:playBgm(isDisable and "" or nil, AudioConst.BgmPriority.TimelineClip)

	if disableAmb then
		self:playAmb(isDisable and "" or nil, AudioConst.BgmPriority.TimelineClip)
	end
end

function AudioSystem:resetTimelineClipDisabledAudio()
	self:playBgm(nil, AudioConst.BgmPriority.TimelineClip)
	self:playAmb(nil, AudioConst.BgmPriority.TimelineClip)
end

function AudioSystem:playBgmByLevel(reasonKey, bgmStr, priority, restart)
	reasonKey = reasonKey or "Default"
	self.levelBgmInfo[reasonKey] = {
		soundName = bgmStr,
		priority = priority
	}

	self:refreshLevelBgm(restart)
end

function AudioSystem:stopBgmByLevel(reasonKey)
	reasonKey = reasonKey or "Default"
	self.levelBgmInfo[reasonKey] = nil

	self:refreshLevelBgm()
end

function AudioSystem:forceReplayGameMusic()
	self:stopEvent(AudioConst.GAME_MUSIC_EVENT, nil, 0.5, true)
	self:playEvent(AudioConst.GAME_MUSIC_EVENT, nil, AudioConst.AkCallbackType.AK_MusicSyncAll, CallbackHandler(self, "_onAudioBgmEventCallbackGlobal"))
end

function AudioSystem:refreshLevelBgm(restart)
	local resultEvent, eventPriority

	for reasonKey, eventItem in pairs(self.levelBgmInfo) do
		if not eventPriority or eventPriority < eventItem.priority then
			resultEvent = eventItem.soundName
			eventPriority = eventItem.priority
		end
	end

	if restart then
		local curBgm, curPriority = self:getCurBgmAndMaxPriority()

		if curPriority > AudioConst.BgmPriority.Level then
			restart = false
		else
			self:forceReplayGameMusic()
		end
	end

	self:playBgm(resultEvent, AudioConst.BgmPriority.Level, restart)
end

function AudioSystem:playAmbByLevel(reasonKey, ambStr, priority)
	reasonKey = reasonKey or "Default"
	self.levelAmbInfo[reasonKey] = {
		soundName = ambStr,
		priority = priority
	}

	self:refreshLevelAmb()
end

function AudioSystem:stopAmbByLevel(reasonKey)
	reasonKey = reasonKey or "Default"
	self.levelAmbInfo[reasonKey] = nil

	self:refreshLevelAmb()
end

function AudioSystem:refreshLevelAmb()
	local resultEvent, eventPriority

	for reasonKey, eventItem in pairs(self.levelAmbInfo) do
		if not eventPriority or eventPriority < eventItem.priority then
			resultEvent = eventItem.soundName
			eventPriority = eventItem.priority
		end
	end

	self:playAmb(resultEvent, AudioConst.BgmPriority.Level)
end

function AudioSystem:stopBgm(priority, actorId)
	local changed = self:setBGMStackBgmStr(priority, nil, actorId)

	self.bgmDirty = self.bgmDirty or changed
end

function AudioSystem:playAmb(abmStr, priority, forceReset)
	if forceReset then
		if self:checkEventValid(self.currAmb) then
			self:stopEvent(self.currAmb)
		end

		self.currAmb = nil
	elseif self.ambStack[priority] == abmStr then
		return
	end

	self.ambStack[priority] = abmStr

	if forceReset then
		self:refreshAmb()

		self.ambDirty = false
	else
		self.ambDirty = true
	end
end

function AudioSystem:stopAmb(priority)
	if not self.ambStack[priority] then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("stopAmb:", priority, self.ambStack[priority])
	end

	self.ambStack[priority] = nil
	self.ambDirty = true
end

function AudioSystem:refreshAmb()
	local curPriority = 0
	local amb

	for i = AudioConst.BgmPriority.MAX, 1, -1 do
		amb = self.ambStack[i]

		if amb then
			curPriority = i

			break
		end
	end

	if amb then
		if amb ~= self.currAmb then
			if self:checkEventValid(self.currAmb) then
				self:stopEvent(self.currAmb, nil, 5)
			end

			if not self:isNullEvent(amb) and not self:isEmptyEvent(amb) then
				self:triggerEvent(amb)
			end

			self.currAmb = amb
		end
	elseif not string.isNilOrEmpty(self.currAmb) then
		if not self:isNullEvent(self.currAmb) and not self:isEmptyEvent(self.currAmb) then
			self:stopEvent(self.currAmb, nil, 5)
		end

		self.currAmb = nil
	end

	self.curAmbPriority = curPriority

	if curPriority > AudioConst.BgmPriority.SceneEmitter then
		self.mgrInst:SetSceneSoundEmitterValid(SoundType.Amb, false)
	else
		self.mgrInst:SetSceneSoundEmitterValid(SoundType.Amb, true)
	end
end

function AudioSystem:registerAudioBgmEventByActorId(actorId)
	self.registerEventEntity[actorId] = true
end

function AudioSystem:unregisterAudioBgmEventByActorId(actorId)
	self.registerEventEntity[actorId] = nil
end

function AudioSystem:registerAudioBgmEvent(key, func)
	self.registerEventInfo[key] = func
end

function AudioSystem:unregisterAudioBgmEvent(key)
	self.registerEventInfo[key] = nil
end

function AudioSystem:_onAudioBgmEventCallbackGlobal(eventType, extraInfo)
	for actorId, _ in pairs(self.registerEventEntity) do
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			entity:postComponentMethod("EVENT_onAudioBgmEventCallback", eventType, extraInfo)
		end
	end

	for _, func in pairs(self.registerEventInfo) do
		func(eventType, extraInfo)
	end
end

function AudioSystem:_onAudioBgmEventCallback(bgm, eventType, extraInfo)
	for actorId, _ in pairs(self.registerEventEntity) do
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			entity:postComponentMethod("EVENT_onAudioBgmEventCallback", eventType, extraInfo)
		end
	end

	for _, func in pairs(self.registerEventInfo) do
		func(eventType, extraInfo)
	end
end

function AudioSystem:onSoundEmitterEvent(eventName, eventType, extraInfo)
	for actorId, _ in pairs(self.registerEventEntity) do
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			entity:postComponentMethod("EVENT_onAudioBgmEventCallback", eventType, extraInfo)
		end
	end

	for _, func in pairs(self.registerEventInfo) do
		func(eventType, extraInfo, eventName)
	end
end

function AudioSystem:emitDecibel(pos, id)
	local decibelData = decibel_grade_data[id]

	if not decibelData then
		return
	end

	for listenerId, listener in pairs(self.decibelListeners) do
		local listenRange = listener.listenRange or 0

		if listenRange > 0 then
			local listenerPos = listener:getPosition()
			local sqrDist = Vector3.SqrDistance(pos, listenerPos)
			local soundRange = decibelData.soundRange

			for i = #soundRange, 1, -1 do
				if sqrDist <= (soundRange[i] + listenRange)^2 then
					listener:receiveDecibel(id, decibelData.level - (#soundRange - i))

					break
				end
			end
		end
	end
end

function AudioSystem:emitPhysicsCollide(pos, impulse)
	local soundImpulseConversion = sys_config_data.soundImpulseConversion

	for i = #soundImpulseConversion, 1, -1 do
		if impulse > soundImpulseConversion[i][1] then
			self:emitDecibel(pos, soundImpulseConversion[i][2])

			break
		end
	end
end

function AudioSystem:registerDecibelListener(listener)
	self.decibelListeners[listener.id] = listener
end

function AudioSystem:unregisterDecibelListener(listener)
	self.decibelListeners[listener.id] = nil
end

function AudioSystem:testCallback()
	self:triggerEvent("boss_bgm_test", nil, nil, nil, AudioConst.AkCallbackType.AK_MusicSyncAll, function(eventType, extraInfo)
		if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_MusicSyncBeat) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("dxk event11")
		end

		if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_MusicSyncBar) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("dxk event22")
		end

		if AudioConst.checkCallbackType(eventType, AudioConst.AkCallbackType.AK_EndOfEvent) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("dxk end event")
		end
	end)
end

return AudioSystem
