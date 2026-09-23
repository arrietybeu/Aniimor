-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAudioComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local VoxelConst = require("Common.Const.VoxelConst")
local Utils = require("Common.Utils.Utils")
local PuppetData = require("Data.puppet_data")
local ClientAudioComponent = Class.Component("ClientAudioComponent")
local dashEventSizeMap = {
	Medium = "SFX_3C_ParmonDashCommon_Medium",
	Large = "SFX_3C_ParmonDashCommon_Heavy",
	Small = "SFX_3C_ParmonDashCommon_Light"
}
local grassMoveEventSizeMap = {
	Medium = "SFX_3C_Common_HighGrass_Medium",
	Large = "SFX_3C_Common_HighGrass_Large",
	Small = "SFX_3C_Common_HighGrass_Small"
}
local stepEventMap = {
	"sound_avatar_loco_footstep_material_s",
	"sound_avatar_loco_footstep_material_m",
	"sound_avatar_loco_footstep_material_h",
	"sound_avatar_loco_footstep_material_h_02"
}
local grassMoveRtpc = "RTPC_MovementSpeed"

function ClientAudioComponent:EVENT_EModelCreate()
	if self.eModel then
		local useSeperateFootStepSound = self.isMainPet or self.isMainPlayer or self.isOfflineMainPlayer or false

		self.eModel:InitAudioEmitters(self:getAudioRootHeightOffset(), useSeperateFootStepSound)
	end
end

function ClientAudioComponent:EVENT_AddEComponent()
	if not self.eModel then
		return
	end

	if self.needCreateAudioComponent and self:needCreateAudioComponent() == false then
		return
	end

	self:addEModelComponent(CommonConst.COMPONENT_INDEX_AUDIO)
end

function ClientAudioComponent:start()
	self:refreshFootStepSound()

	local volumeEx = pg.space and pg.space:checkSkipSkillCutScene() and 0 or 1

	self:setSoundRTPCValue(AudioConst.RTPC_VOLUME_EX, volumeEx)

	if self.isInCombat and self:isInCombat() then
		self:playCombatBgm()
	end

	self:playExtraTempPetBgm()
end

function ClientAudioComponent:getAudioRootHeightOffset()
	if self.getHeight then
		return self:getHeight() * 0.5
	end

	return 0
end

function ClientAudioComponent:triggerSoundEvent(eventName, switchInfo, stopTime)
	if not eventName or not self.eModel then
		return
	end

	if switchInfo and not IsNil(self.eModel.audioEmitter) then
		local obj = self.eModel.audioEmitter

		for groupName, switchName in pairs(switchInfo) do
			pg.game.audio:setSwitch(groupName, switchName, obj)
		end
	end

	self.eModel:PlayEvent(CommonConst.COMPONENT_INDEX_AUDIO, eventName, stopTime or 0)
end

function ClientAudioComponent:playSoundAtSelfPos(eventName)
	if not eventName or not self.eModel then
		return
	end

	self.eModel:PlaySoundAtPos(CommonConst.COMPONENT_INDEX_AUDIO, eventName)
end

function ClientAudioComponent:playSoundEvent(eventName, eventCallback)
	if not eventName or not self.eModel then
		return
	end

	self.eModel:PlayEvent(CommonConst.COMPONENT_INDEX_AUDIO, eventName, 0, eventCallback)
end

function ClientAudioComponent:playDashSoundEvent()
	self:playSoundEventAt(dashEventSizeMap[self.sizeLevelName3], self.eModel.audioEmitterFootStep)
end

function ClientAudioComponent:playFootStepSoundEvent(level)
	self:playSoundEventAt(stepEventMap[level], self.eModel.audioEmitterFootStep)
end

function ClientAudioComponent:playHighGrassSoundEvent()
	self:playSoundEventAt(grassMoveEventSizeMap[self.sizeLevelName3], self.eModel.audioEmitter)
end

function ClientAudioComponent:stopHighGrassSoundEvent()
	self:stopSoundEvent(grassMoveEventSizeMap[self.sizeLevelName3])
end

function ClientAudioComponent:playSoundEventAt(eventName, emitter)
	self.eModel:PlayEvent(CommonConst.COMPONENT_INDEX_AUDIO, eventName, 0, nil, emitter)
end

function ClientAudioComponent:stopSoundEvent(eventName, fadeTime)
	if not self.eModel then
		return
	end

	pg.game.audio:stopEvent(eventName, self.eModel.audioEmitter, fadeTime)
end

function ClientAudioComponent:setSoundSwitch(groupName, switchName)
	if not self.eModel then
		return
	end

	local audioEmitter = self.eModel.audioEmitter

	if NotNil(audioEmitter) then
		pg.game.audio:setSwitch(groupName, switchName, audioEmitter)
	end

	local footStepEmitter = self.eModel.audioEmitterFootStep

	if NotNil(footStepEmitter) and footStepEmitter ~= audioEmitter then
		pg.game.audio:setSwitch(groupName, switchName, footStepEmitter)
	end
end

function ClientAudioComponent:setSoundSwitchById(switchGroupId, switchStateId)
	if not self.eModel then
		return
	end

	local audioEmitter = self.eModel.audioEmitter

	if NotNil(audioEmitter) then
		pg.game.audio:setSwitchById(switchGroupId, switchStateId, audioEmitter)
	end

	local footStepEmitter = self.eModel.audioEmitterFootStep

	if NotNil(footStepEmitter) and footStepEmitter ~= audioEmitter then
		pg.game.audio:setSwitchById(switchGroupId, switchStateId, footStepEmitter)
	end
end

function ClientAudioComponent:setSoundRTPCValue(key, value)
	if not self.eModel then
		return
	end

	if NotNil(self.eModel.audioEmitter) then
		pg.game.audio:setRTPCValue(key, value, self.eModel.audioEmitter)
	end

	if NotNil(self.eModel.audioEmitterFootStep) then
		pg.game.audio:setRTPCValue(key, value, self.eModel.audioEmitterFootStep)
	end
end

function ClientAudioComponent:setSoundOutputBusVolume(volumeRatio)
	if not self.eModel or IsNil(self.eModel.audioEmitter) then
		return false
	end

	return pg.game.audio:setGameObjectOutputBusVolume(self.eModel.audioEmitter, volumeRatio)
end

function ClientAudioComponent:getSoundRTPCValue(key)
	if not self.eModel then
		return
	end

	if NotNil(self.eModel.audioEmitter) then
		return pg.game.audio:getRTPCValue(key, self.eModel.audioEmitter)
	end

	if NotNil(self.eModel.audioEmitterFootStep) then
		return pg.game.audio:getRTPCValue(key, self.eModel.audioEmitterFootStep)
	end
end

function ClientAudioComponent:playSoundOnAnimation(eventName)
	self:playSoundEvent(eventName)
end

function ClientAudioComponent:stopSoundOnAnimation(eventName)
	self:stopSoundEvent(eventName, 0.5)
end

function ClientAudioComponent:onEnterCombat()
	self:playCombatBgm()
end

function ClientAudioComponent:onLeaveCombat()
	self:stopCombatBgm()
end

function ClientAudioComponent:destroy()
	self:stopCombatBgm()
	self:stopExtraTempPetBgm()
end

function ClientAudioComponent:playCombatBgm()
	if Utils.isBoss(self) then
		local bgm = self:getConfigData().combatBgm

		if bgm then
			pg.game.audio:setCombatBgmInfo(self.actorId, bgm, AudioConst.BgmPriority.Boss)
			pg.game.audio:registerAudioBgmEventByActorId(self.actorId)
		end
	elseif Utils.isElite(self) then
		local bgm = self:getConfigData().combatBgm

		if bgm then
			pg.game.audio:setCombatBgmInfo(self.actorId, bgm, AudioConst.BgmPriority.Elite)
			pg.game.audio:registerAudioBgmEventByActorId(self.actorId)
		end
	end
end

function ClientAudioComponent:stopCombatBgm()
	if Utils.isBoss(self) or Utils.isElite(self) then
		pg.game.audio:setCombatBgmInfo(self.actorId, nil)
		pg.game.audio:unregisterAudioBgmEventByActorId(self.actorId)
	end
end

function ClientAudioComponent:playExtraTempPetBgm()
	if self.isExtraTempPet and self:isExtraTempPet() then
		local bgm = self:getConfigData().extraTempPetBgm

		if bgm then
			pg.game.audio:playBgm(bgm, AudioConst.BgmPriority.ExtraTempPet)
		end
	end
end

function ClientAudioComponent:stopExtraTempPetBgm()
	if self.isExtraTempPet and self:isExtraTempPet() then
		local bgm = self:getConfigData().extraTempPetBgm

		if bgm then
			pg.game.audio:stopBgm(AudioConst.BgmPriority.ExtraTempPet)
		end
	end
end

function ClientAudioComponent:abilityPlaySoundStr(eventName, switchGroupName1, switchName1, switchGroupName2, switchName2, stopTime)
	if self.eModel then
		local switchInfo = {}

		if switchGroupName1 then
			switchInfo[switchGroupName1] = switchName1
		end

		if switchGroupName2 then
			switchInfo[switchGroupName2] = switchName2
		end

		if switchInfo[AudioConst.AUDIO_ELEMENT_SWITCH_MAP.name] == nil then
			switchInfo[AudioConst.AUDIO_ELEMENT_SWITCH_MAP.name] = AudioConst.AUDIO_ELEMENT_SWITCH_MAP[AudioConst.AUDIO_ELEMENT_SWITCH_EMPTY]
		end

		switchInfo[AudioConst.AUDIO_SEX_SWICH_MAP.name] = "Female"

		self:triggerSoundEvent(eventName, switchInfo, stopTime)
	end
end

function ClientAudioComponent:EVENT_ContactSurfaceVoxelChanged(surfaceVoxelCustomData)
	self:refreshFootStepSound()
end

function ClientAudioComponent:refreshFootStepSound()
	if not self.eModel then
		return
	end

	local contactVoxel = self.surfaceVoxelCustomData or 0
	local switchName

	switchName = bit.band(VoxelConst.VoxelMaterialDef.Swamp, contactVoxel) ~= 0 and "swamp" or bit.band(VoxelConst.VoxelMaterialDef.Water, contactVoxel) ~= 0 and "water" or bit.band(VoxelConst.VoxelMaterialDef.Snow, contactVoxel) ~= 0 and "snow" or bit.band(VoxelConst.VoxelMaterialDef.Ice, contactVoxel) ~= 0 and "ice" or bit.band(VoxelConst.VoxelMaterialDef.Ash, contactVoxel) ~= 0 and "sand" or bit.band(VoxelConst.VoxelMaterialDef.Grass, contactVoxel) ~= 0 and "grass" or bit.band(VoxelConst.VoxelMaterialDef.GrassGround, contactVoxel) ~= 0 and "grass" or bit.band(VoxelConst.VoxelMaterialDef.Metal, contactVoxel) ~= 0 and "metal" or bit.band(VoxelConst.VoxelMaterialDef.Concrete, contactVoxel) ~= 0 and "concret" or bit.band(VoxelConst.VoxelMaterialDef.Sand, contactVoxel) ~= 0 and "sand" or bit.band(VoxelConst.VoxelMaterialDef.Soil, contactVoxel) ~= 0 and "soil" or bit.band(VoxelConst.VoxelMaterialDef.Stone, contactVoxel) ~= 0 and "stone" or bit.band(VoxelConst.VoxelMaterialDef.Wood, contactVoxel) ~= 0 and "wood" or "concret"

	if switchName and self.curSoundSwitchName ~= switchName then
		self.curSoundSwitchName = switchName

		local success, switchGroupId, switchStateId = pg.game.audio:tryGetSwitchIds(AudioConst.SWITCH_GROUP_SURFACE_MATERIAL, switchName)

		if success then
			self:setSoundSwitchById(switchGroupId, switchStateId)
		else
			self:setSoundSwitch(AudioConst.SWITCH_GROUP_SURFACE_MATERIAL, switchName)
		end
	end
end

function ClientAudioComponent:playSwitchToPetSound()
	local resId = self:getConfigData().resId

	if resId then
		self:triggerSoundEvent("VOX_Combat_Parmon_" .. tostring(resId) .. "_OnLink")
	end
end

function ClientAudioComponent:playSummonPetSound()
	local resId = self:getConfigData().resId

	if resId then
		self:triggerSoundEvent("VOX_Combat_Parmon_" .. tostring(resId) .. "_Appear")
	end
end

return ClientAudioComponent
