-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetSwitch\\PetSwitchAnim.lua

local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local Const = require("Common.Const.Const")
local PlayableConst = require("Const.PlayableConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Utils = require("Common.Utils.Utils")
local EffectConst = require("Const.EffectConst")
local AudioConst = require("Const.AudioConst")
local SysConfigData = require("Data.sys_config_data")
local ConflictTypes = require("Common.ConflictTypes")
local AddressDataConst = require("Const.AddressDataConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local logger = require("Core.Log.LoggerManager").getLogger("PetSwitchAnim")
local switchingStartEffectResId = "Eff_Switch_Switching_Start"
local switchingEffectResId = "Eff_Switch_Switching"
local switchingHitResId = "Eff_Switch_Hit"
local switchingHitResId_Idyll = "Eff_Equip_Idyllcommon"
local switchingHitAvatarResId = "Eff_Switch_Hit_Avatar"
local dissolveEffectResId = ""
local switchingHitNormalResId = "Eff_Switch_Hit_Normal"
local switchingHitQuitResId_Idyll = "Eff_Equip_IdyllQuitConnect"
local dissolveOutEffectResId = ""
local mergeScreenEffect = "Eff_Avatar_Merge_Screen"
local Time = require("Core.Common.Time")
local GameObject = CS.UnityEngine.GameObject
local dissolveFadeTime = 0.6
local idyllSDissolveFadeTime = 2
local dissolveRefreshTime = 1.2
local dissolveAppearTime = 0.8
local idyllSDissolveAppearTime = 0.8
local fresnelPlayPoint = 0.4
local PetSwitchAnim = Class.LightClass("PetSwitchAnim")

function PetSwitchAnim:ctor()
	self.switchTimeline = nil
	self.curPetEnt = nil
	self.curPlayerEnt = nil
	self.vegEffId = nil
end

function PetSwitchAnim:destroy()
	self:stop()
end

function PetSwitchAnim:stop()
	self:stopCurTimeline()

	self.curPetEnt = nil
	self.curPlayerEnt = nil
end

function PetSwitchAnim:stopCurTimeline()
	if self.switchTimeline ~= nil then
		self.switchTimeline:stop()

		self.switchTimeline = nil
	end
end

function PetSwitchAnim:getDissolveAppearTime(isIdyllSwitch)
	if isIdyllSwitch then
		return idyllSDissolveAppearTime
	end

	return SysConfigData.switchAppearTime or dissolveAppearTime
end

function PetSwitchAnim:playPetToPetAnim(petEnt, playerEnt)
	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if self.curPetEnt then
		if not self.curPlayerEnt:EXTRA_TEMP_PET_ST() then
			self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_RECIEVE)
		end

		self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime())

		if not self.curPlayerEnt:EXTRA_TEMP_PET_ST() then
			self.curPetEnt:playSummonPetSound()
		end
	end
end

function PetSwitchAnim:playSwitchToPetAnim(petEnt, playerEnt)
	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if self.curPetEnt then
		if not self.curPlayerEnt:EXTRA_TEMP_PET_ST() then
			self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_RECIEVE)
		end

		self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
		self.curPetEnt:playSwitchToPetSound()
	end

	self:playSwitchToPetEffect(true)
end

function PetSwitchAnim:isCurPlayerValid()
	return self.curPlayerEnt and self.curPlayerEnt.eModel ~= nil
end

function PetSwitchAnim:isCurPetValid()
	return self.curPetEnt and self.curPetEnt.eModel ~= nil
end

function PetSwitchAnim:getRotation(from, to, default)
	local dir = to - from
	local dirRot = default

	dir.y = 0

	if Vector3.Magnitude(dir) > 0.001 then
		dirRot = Quaternion.LookRotation(dir, Vector3.constUp)
	end

	return dirRot
end

function PetSwitchAnim:playQuickSwitchToPetAnimSpecial(petEnt, playerEnt)
	local moveDurationMax = 0.5

	if petEnt then
		petEnt:setInSwitchAnimScale(true)
	end

	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline

	local initPlayerPos = self.curPlayerEnt:getPosition():Clone()
	local initPlayerRot = self.curPlayerEnt:getRotation()
	local initPetPos = self.curPetEnt:getPosition()
	local distance = math.max(Vector3.Distance(initPlayerPos, initPetPos), 0.1)
	local moveDuration = math.clamp(distance / 15, moveDurationMax * 0.4, moveDurationMax)
	local isMainPlayer = self.curPlayerEnt.isMainPlayer
	local duration = moveDuration

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera:setTempTargetPlayer(self.curPlayerEnt)
			end

			self.curPlayerEnt.eModel.enableFollow = false
		end
	end)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera.playerCameraMode:blendToFov(55, 0.2)
			end

			local startEffectPosition = self.curPlayerEnt:getPosition():Clone()

			startEffectPosition.y = startEffectPosition.y + self.curPlayerEnt:getHeight() * 0.5

			local dirRot = self:getRotation(initPlayerPos, initPetPos, initPlayerRot)

			self.curPlayerEnt:playEffect(switchingStartEffectResId, {
				position = startEffectPosition,
				rotation = dirRot:ToEulerAngles()
			})

			local extraConfig = {
				position = Vector3(0, self.curPlayerEnt:getHeight() * 0.5, 0),
				duration = moveDuration
			}

			self.curPlayerEnt:playEffect(switchingEffectResId, extraConfig)

			if isMainPlayer then
				self.curPlayerEnt:playEffect(mergeScreenEffect)
			end

			self.curPlayerEnt:setSwitchEndTime(nil)
		end
	end)
	timeline:createAndAddClip(0, moveDuration, function(_, currTime)
		if isMainPlayer and self:isCurPlayerValid() and self:isCurPetValid() then
			local petPos = self.curPetEnt:getPosition()
			local blendValue = currTime / moveDuration

			Vector3.enableCreateFromCache()

			local lerpPos = Vector3.Lerp(initPlayerPos, petPos, blendValue)
			local rx, ry, rz, rw = self.curPlayerEnt.eModel:GetPositionAgentRotationEx()
			local dirRot = self:getRotation(lerpPos, petPos, Quaternion(rx, ry, rz, rw))

			EModelUtils.setAgentPositionAndRotation(self.curPlayerEnt, lerpPos, dirRot, true)
			Vector3.disableCreateFromCache()
			self.curPetEnt:playSwitchToPetSound()
		end
	end)
	timeline:createAndAddTrigger(duration, function()
		if isMainPlayer then
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
			pg.game.camera:setTempTargetPlayer(nil)
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt:stopEffect(switchingEffectResId)
		end

		if self:isCurPetValid() then
			self.curPetEnt:setInSwitchAnimScale(nil)
			self:playSwitchToPetEffect()
			self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_RECIEVE)
			self.curPetEnt:playSwitchAppearEffectRefresh(dissolveRefreshTime)
		end
	end)
	timeline:setStopCallback(function()
		if isMainPlayer then
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
			pg.game.camera:setTempTargetPlayer(nil)
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt:stopEffect(switchingEffectResId)

			self.curPlayerEnt.eModel.enableFollow = true

			self.curPlayerEnt:refreshVisible()
		end

		self.curPlayerEnt.inSwitchAnim = false
		self.curPlayerEnt.captureSwitchFlag = false

		if self:isCurPetValid() then
			self.curPetEnt:setInSwitchAnimScale(nil)
		end
	end)
	timeline:start()
end

function PetSwitchAnim:playSwitchToPetAnimSpecial(petEnt, playerEnt)
	local stayTime = 1
	local moveDurationMax = 0.5
	local playerHeightOffset = 0.2

	if petEnt then
		petEnt:setInSwitchAnimScale(true)
	end

	if playerEnt then
		playerEnt:setSwitchEndTime(Time.realSecondCache + stayTime, true)
	end

	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	self.curPlayerEnt:setInLinkAnim(true)

	local isMainPlayer = playerEnt.isMainPlayer

	if isMainPlayer then
		self.curPlayerEnt:checkStatus(ConflictTypes.CT_SWITCHING_ANIM)

		if self.curPetEnt then
			self.curPetEnt:checkStatus(ConflictTypes.CT_SWITCHING_ANIM)
		end
	end

	self.curPlayerEnt.inSwitchAnim = true

	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline

	local initPlayerPos = self.curPlayerEnt:getPosition():Clone()
	local initPlayerRot = self.curPlayerEnt:getRotation():Clone()
	local initPetPos = self.curPetEnt:getPosition()
	local distance = math.max(Vector3.Distance(initPlayerPos, initPetPos), 0.1)
	local moveDuration = math.clamp(distance / 15, moveDurationMax * 0.4, moveDurationMax)
	local duration = moveDuration + stayTime

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				self.curPlayerEnt:SetInSwitchFlying(true)
				pg.game.camera:setTempTargetPlayer(self.curPlayerEnt)
			end

			self.curPlayerEnt:playAnimation(PlayableConst.Link)

			self.curPlayerEnt.eModel.enableFollow = false
		end
	end)
	timeline:createAndAddTrigger(fresnelPlayPoint, function()
		if self:isCurPetValid() then
			self.curPetEnt:playSwitchFresnelEffect()
		end
	end)
	timeline:createAndAddTrigger(stayTime - dissolveFadeTime, function()
		if self:isCurPlayerValid() then
			self.curPlayerEnt:playSwitchDissolveEffect(dissolveFadeTime, function()
				self.curPlayerEnt:setSwitchEndTime(nil)
			end, playerHeightOffset)
		end

		if self:isCurPetValid() then
			self:playSwitchDissolveVegEffect(self.curPlayerEnt, dissolveFadeTime, playerHeightOffset)
		end
	end)
	timeline:createAndAddTrigger(stayTime, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera.playerCameraMode:blendToFov(55, 0.2)
			end

			self.curPlayerEnt:setInLinkAnim(false)

			local startEffectPosition = self.curPlayerEnt:getPosition():Clone()

			startEffectPosition.y = startEffectPosition.y + self.curPlayerEnt:getHeight() * 0.5

			local dirRot = self:getRotation(initPlayerPos, initPetPos, initPlayerRot)

			self.curPlayerEnt:playEffect(switchingStartEffectResId, {
				position = startEffectPosition,
				rotation = dirRot:ToEulerAngles()
			})

			local extraConfig = {
				position = Vector3(0, self.curPlayerEnt:getHeight() * 0.5, 0),
				duration = moveDuration
			}

			self.curPlayerEnt:playEffect(switchingEffectResId, extraConfig)
			self.curPlayerEnt:setSwitchEndTime(nil)
		end
	end)

	if isMainPlayer then
		timeline:createAndAddClip(stayTime, moveDuration, function(_, currTime)
			if self:isCurPlayerValid() and self:isCurPetValid() then
				local petPos = self.curPetEnt:getPosition()
				local blendValue = currTime / moveDuration

				Vector3.enableCreateFromCache()

				local lerpPos = Vector3.Lerp(initPlayerPos, petPos, blendValue)
				local rx, ry, rz, rw = self.curPlayerEnt.eModel:GetPositionAgentRotationEx()
				local dirRot = self:getRotation(lerpPos, petPos, Quaternion(rx, ry, rz, rw))

				EModelUtils.setAgentPositionAndRotation(self.curPlayerEnt, lerpPos, dirRot, true)
				Vector3.disableCreateFromCache()
			end
		end)
	end

	timeline:createAndAddTrigger(duration, function()
		if isMainPlayer then
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
			pg.game.camera:setTempTargetPlayer(nil)
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt:stopEffect(switchingEffectResId)
		end

		if self:isCurPetValid() then
			self.curPetEnt:setInSwitchAnimScale(nil)
			self:playSwitchToPetEffect()
			self.curPetEnt:playSwitchToPetSound()
			self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_RECIEVE)
			self.curPetEnt:playSwitchAppearEffectRefresh(dissolveRefreshTime)
		end
	end)
	timeline:setStopCallback(function()
		if isMainPlayer then
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
			pg.game.camera:setTempTargetPlayer(nil)

			if self:isCurPetValid() then
				self.curPlayerEnt:setPosition(self.curPlayerEnt:getPosition())
			end
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt:SetInSwitchFlying(false)
			self.curPlayerEnt:stopEffect(switchingEffectResId)
			self.curPlayerEnt:stopAnimation(PlayableConst.Link)

			self.curPlayerEnt.eModel.enableFollow = true

			self.curPlayerEnt:setSwitchEndTime(nil)
			self.curPlayerEnt:setInLinkAnim(false)
		end

		self.curPlayerEnt.inSwitchAnim = false
		self.curPlayerEnt.captureSwitchFlag = false

		if self:isCurPetValid() then
			self.curPetEnt:setInSwitchAnimScale(nil)
		end
	end)
	timeline:start()
end

function PetSwitchAnim:playQuickSwitchToPetAnimSpecial2(petEnt, playerEnt)
	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if self.curPlayerEnt.isMainPlayer then
		self.curPetEnt:forceSetPosRot(self.curPlayerEnt:getPosition(), self.curPlayerEnt:getRotation(), false, true)
		self.curPlayerEnt:playEffect(mergeScreenEffect)
	end

	self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_APPEAR)
	self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
	self.curPetEnt:playSwitchToPetSound()
	self:playSwitchToPetEffect()
end

function PetSwitchAnim:playSwitchToPetAnimSpecial2(petEnt, playerEnt, extraData)
	local stayTime = 1
	local playerHeightOffset = 0.2

	if playerEnt then
		if playerEnt.setSwitchEndTime then
			playerEnt:setSwitchEndTime(Time.realSecondCache + stayTime, true)
		end

		if petEnt and petEnt.setInSwitchAnimScale then
			petEnt:setInSwitchAnimScale(true)
		end
	end

	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if self.curPlayerEnt.setInLinkAnim then
		self.curPlayerEnt:setInLinkAnim(true)
	end

	local isIdyllSwitch = extraData and extraData.isIdyllSwitch or false
	local ignoreCamera = extraData and extraData.ignoreCamera or false
	local isMainPlayer = self.curPlayerEnt.isMainPlayer

	if not isMainPlayer then
		ignoreCamera = true
	end

	local forcePlay = extraData and extraData.forcePlay or false
	local finishedCallback = extraData and extraData.finishedCallback or nil

	if self.curPlayerEnt.isMainPlayer then
		if self.curPlayerEnt.checkStatus then
			self.curPlayerEnt:checkStatus(ConflictTypes.CT_SWITCHING_ANIM)
		end

		if self.curPetEnt and self.curPetEnt.checkStatus then
			self.curPetEnt:checkStatus(ConflictTypes.CT_SWITCHING_ANIM)
		end
	end

	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline

	local duration = stayTime

	self.curPlayerEnt.inSwitchAnim = true

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if not ignoreCamera then
				pg.game.camera.playerCameraMode:blendToFov(35, 0.2)
				pg.game.camera:setTempTargetPlayer(self.curPlayerEnt)
			end

			if not isIdyllSwitch then
				self.curPlayerEnt:playAnimation(PlayableConst.Link)
			end

			self.curPlayerEnt.eModel.enableFollow = false
		end
	end)

	local fadeTime = isIdyllSwitch and idyllSDissolveFadeTime or dissolveFadeTime

	timeline:createAndAddTrigger(stayTime - fadeTime, function()
		if self:isCurPlayerValid() then
			if isIdyllSwitch then
				self.curPetEnt:playSwitchDissolveSurfaceEffect(fadeTime + 0.05, nil, 0)
				self.curPlayerEnt:playSwitchDissolveSurfaceEffect(fadeTime, function()
					if self.curPlayerEnt and self.curPlayerEnt.setSwitchEndTime then
						self.curPlayerEnt:setSwitchEndTime(nil)
					end
				end, playerHeightOffset, isIdyllSwitch)
			else
				self.curPetEnt:playSwitchDissolveEffect(fadeTime + 0.05, nil, 0)
				self.curPlayerEnt:playSwitchDissolveEffect(fadeTime, function()
					if self.curPlayerEnt and self.curPlayerEnt.setSwitchEndTime then
						self.curPlayerEnt:setSwitchEndTime(nil)
					end
				end, playerHeightOffset)
			end
		end
	end)
	timeline:createAndAddTrigger(stayTime, function()
		if self:isCurPlayerValid() then
			if self.curPlayerEnt.setSwitchEndTime then
				self.curPlayerEnt:setSwitchEndTime(nil)
			end

			if self.curPlayerEnt.setInLinkAnim then
				self.curPlayerEnt:setInLinkAnim(false)
			end
		end
	end)
	timeline:createAndAddTrigger(duration, function()
		if not ignoreCamera then
			pg.game.camera:setTempTargetPlayer(nil)
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
		end

		if self:isCurPetValid() and self:isCurPlayerValid() then
			if self.curPetEnt.setInSwitchAnimScale then
				self.curPetEnt:setInSwitchAnimScale(nil)
			end

			if isMainPlayer or forcePlay then
				if self.curPetEnt.forceSetPosRot then
					self.curPetEnt:forceSetPosRot(self.curPlayerEnt:getPosition(), self.curPlayerEnt:getRotation(), false, true)
				else
					local rx, ry, rz, rw = self.curPlayerEnt.eModel:GetPositionAgentRotationEx()

					EModelUtils.setAgentPositionAndRotation(self.curPetEnt, self.curPlayerEnt:getPosition(), Quaternion(rx, ry, rz, rw), false)
				end
			end

			self.curPetEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_APPEAR)

			if isIdyllSwitch then
				self.curPetEnt:playSwitchAppearSurfaceEffect(self:getDissolveAppearTime(isIdyllSwitch), nil, 0, false, true)
			else
				self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
			end

			self.curPetEnt:playSwitchToPetSound()
			self:playSwitchToPetEffect(false, isIdyllSwitch)
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt.eModel.enableFollow = true

			if self.curPlayerEnt.setSwitchEndTime then
				self.curPlayerEnt:setSwitchEndTime(nil)
			end
		end
	end)
	timeline:setStopCallback(function()
		self.curPlayerEnt.inSwitchAnim = false

		if not ignoreCamera then
			pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
			pg.game.camera:setTempTargetPlayer(nil)
		end

		if self:isCurPlayerValid() then
			self.curPlayerEnt:stopAnimation(PlayableConst.Link)

			self.curPlayerEnt.eModel.enableFollow = true

			if self.curPlayerEnt.setSwitchEndTime then
				self.curPlayerEnt:setSwitchEndTime(nil)
			end

			if self.curPlayerEnt.setInLinkAnim then
				self.curPlayerEnt:setInLinkAnim(false)
			end
		end

		if self:isCurPetValid() and self.curPetEnt.setInSwitchAnimScale then
			self.curPetEnt:setInSwitchAnimScale(nil)
		end

		self.curPlayerEnt.captureSwitchFlag = false

		if finishedCallback then
			finishedCallback()
		end
	end)
	timeline:start()
end

function PetSwitchAnim:playSwitchDissolveVegEffect(targetEnt, duration, offset)
	offset = offset or 0

	local height = targetEnt:getHeight() + offset

	targetEnt:playEffect("Eff_VEG_Switch_Disappear")
end

function PetSwitchAnim:playSwitchToPlayerAnim(petEnt, playerEnt, extraData)
	self:stopCurTimeline()

	local duration = 0.5
	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline
	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	local isIdyllSwitch = extraData and extraData.isIdyllSwitch or false
	local forcePlay = extraData and extraData.forcePlay or false
	local finishedCallback = extraData and extraData.finishedCallback or nil

	if playerEnt and (playerEnt.isMainPlayer or forcePlay) then
		if playerEnt.setSwitchEndTime then
			playerEnt:setSwitchEndTime(nil)
		end

		if playerEnt.setInLinkAnim then
			playerEnt:setInLinkAnim(false)
		end
	end

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPetValid() then
			if isIdyllSwitch then
				self.curPetEnt:playSwitchAppearSurfaceEffect(self:getDissolveAppearTime(isIdyllSwitch), nil, 0, false, true)
			else
				self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime(), nil, 0)
			end
		end

		if self:isCurPlayerValid() then
			if forcePlay or not self.curPlayerEnt:EXTRA_TEMP_PET_ST() then
				self.curPlayerEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_APPEAR)
			end

			if isIdyllSwitch then
				self.curPlayerEnt:playSwitchAppearSurfaceEffect(self:getDissolveAppearTime(isIdyllSwitch), nil, 0, false, true)
			else
				self.curPlayerEnt:playSwitchAppearEffect(self:getDissolveAppearTime(), nil, 0)
			end

			self:playSwitchToPlayerEffect(isIdyllSwitch)
		end
	end)
	timeline:setStopCallback(function()
		self.curPlayerEnt.captureSwitchFlag = false

		if finishedCallback then
			finishedCallback()
		end
	end)
	timeline:start()
end

function PetSwitchAnim:playFollowToFollowAnim(petEnt)
	if not petEnt then
		return
	end

	local playerEnt = petEnt:getMasterEntity()

	if not playerEnt or not playerEnt:EXTRA_TEMP_PET_ST() then
		petEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_APPEAR)
		petEnt:playSummonPetSound()
	end

	petEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
end

function PetSwitchAnim:playSwitchToPlayerAnimSpecial(petEnt, playerEnt)
	self:stopCurTimeline()

	local duration = 0.15

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if playerEnt then
		playerEnt:setSwitchEndTime(nil)
		playerEnt:setInLinkAnim(false)
	end

	local isMainPlayer = playerEnt and playerEnt.isMainPlayer or false
	local initPlayerPos = self.curPlayerEnt:getPosition():Clone()
	local initPlayerRot = self.curPlayerEnt:getRotation()
	local initPetRot = self.curPetEnt:getRotation()
	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if self.curPlayerEnt.disableMotion then
				self.curPlayerEnt:disableMotion(ClientConst.DISABLE_MOTION_KEY.SWITCHING, true)
			end

			self.curPlayerEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.SWITCHING, false, false)
		end
	end)

	if isMainPlayer then
		local result, playerDisplacePos = AutoPathFindUtils.findDisplacement(petEnt, playerEnt, nil, true)

		if not result then
			playerDisplacePos = petEnt:getPosition()
		end

		timeline:createAndAddClip(0, duration, function(_, currTime)
			if self:isCurPlayerValid() then
				Vector3.enableCreateFromCache()

				local lerpPos = Vector3.Lerp(initPlayerPos, playerDisplacePos, currTime / duration)

				EModelUtils.setAgentPosition(self.curPlayerEnt, lerpPos)
				Vector3.disableCreateFromCache()
			end
		end, nil, nil)
	end

	timeline:setStopCallback(function()
		if self:isCurPlayerValid() then
			if self.curPlayerEnt.disableMotion then
				self.curPlayerEnt:disableMotion(ClientConst.DISABLE_MOTION_KEY.SWITCHING, false)
			end

			self.curPlayerEnt:setVisible(ClientConst.MODEL_VISIBLE_KEY.SWITCHING, true, true)
			self.curPlayerEnt:playSoundEvent(AudioConst.EVENT_AVATAR_MERGE_APPEAR)
			self.curPlayerEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
			self:playSwitchToPlayerEffect()
		end

		self.curPlayerEnt.captureSwitchFlag = false
	end)
	timeline:start()
end

function PetSwitchAnim:playSwitchToExplorePetAnim(petEnt, playerEnt, isFromPlayer)
	self:stopCurTimeline()

	self.curPetEnt = petEnt
	self.curPlayerEnt = playerEnt

	if self.curPetEnt then
		self.curPetEnt:playSwitchAppearEffect(self:getDissolveAppearTime())

		if isFromPlayer then
			self.curPlayerEnt:playSwitchToPetSound()
		else
			self.curPlayerEnt:playSummonPetSound()
		end
	end
end

function PetSwitchAnim:playSwitchToExplorePlayerAnim(playerEnt)
	self:stopCurTimeline()

	self.curPetEnt = nil
	self.curPlayerEnt = playerEnt

	if self.curPlayerEnt then
		self.curPlayerEnt:playSwitchAppearEffect(self:getDissolveAppearTime())
	end
end

function PetSwitchAnim:playSwitchToPetEffect(normal, isIdyll, additionalEffectResId)
	local extraConfig

	additionalEffectResId = self:getFashionSwitchToPetEffectResId(additionalEffectResId)

	if self.curPlayerEnt.captureSwitchFlag then
		self.curPlayerEnt:playEffect("Eff_Common_Parmon_Switch")
	else
		extraConfig = {
			position = Vector3(0, self.curPetEnt:getHeight() * 0.5, 0)
		}

		local hitResId = isIdyll and switchingHitResId_Idyll or switchingHitResId

		self.curPetEnt:playEffect(normal and switchingHitNormalResId or hitResId, extraConfig)
	end

	if additionalEffectResId then
		self:_playFashionSwitchEffect(self.curPetEnt, additionalEffectResId, extraConfig)
	end
end

function PetSwitchAnim:playSwitchToPlayerEffect(isIdyll, additionalEffectResId)
	local extraConfig

	additionalEffectResId = self:getFashionSwitchToPlayerEffectResId(additionalEffectResId)

	if self.curPlayerEnt.captureSwitchFlag then
		self.curPlayerEnt:playEffect("Eff_Common_Parmon_Switch")
	else
		if not isIdyll then
			extraConfig = {
				position = Vector3(0, self.curPlayerEnt:getHeight() * 0.5, 0)
			}
		end

		local hitResId = isIdyll and switchingHitQuitResId_Idyll or switchingHitNormalResId

		self.curPlayerEnt:playEffect(hitResId, extraConfig)

		if isIdyll then
			self.curPetEnt:playEffect(hitResId, extraConfig)
		end
	end

	if additionalEffectResId then
		self:_playFashionSwitchEffect(self.curPlayerEnt, additionalEffectResId, extraConfig)
	end
end

function PetSwitchAnim:playSwitchToEggAnimSpecial(eggEnt, playerEnt)
	local stayTime = 1
	local moveDurationMax = 0.5
	local playerHeightOffset = 0.2

	playerEnt:setSwitchEndTime(Time.realSecondCache + stayTime, true)
	self:stopCurTimeline()

	self.curPlayerEnt = playerEnt

	local isMainPlayer = playerEnt.isMainPlayer

	if isMainPlayer then
		self.curPlayerEnt:checkStatus(ConflictTypes.CT_SWITCHING_ANIM)
	end

	self.curPlayerEnt.inSwitchAnim = true

	local timeline = LuaTimeline.new()

	self.switchTimeline = timeline

	local initPlayerPos = self.curPlayerEnt:getPosition():Clone()
	local initPlayerRot = self.curPlayerEnt:getRotation()
	local initEggPos = eggEnt:getPosition()
	local distance = math.max(Vector3.Distance(initPlayerPos, initEggPos), 0.1)
	local moveDuration = math.clamp(distance / 15, moveDurationMax * 0.4, moveDurationMax)
	local duration = moveDuration + stayTime

	timeline:setDuration(duration)
	timeline:createAndAddTrigger(0, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera:setTempTargetPlayer(self.curPlayerEnt)
			end

			self.curPlayerEnt:playAnimation(PlayableConst.Link)
			self.curPlayerEnt:setInLinkAnim(true)
		end
	end)
	timeline:createAndAddTrigger(stayTime - dissolveFadeTime, function()
		if self:isCurPlayerValid() then
			self.curPlayerEnt:playSwitchDissolveEffect(dissolveFadeTime, nil, playerHeightOffset)
			self:playSwitchDissolveVegEffect(self.curPlayerEnt, dissolveFadeTime, playerHeightOffset)
		end
	end)
	timeline:createAndAddTrigger(stayTime, function()
		if self:isCurPlayerValid() then
			if not self.curPlayerEnt:isControllingEgg() then
				self.curPlayerEnt:setInLinkAnim(false)
				self.curPlayerEnt:setSwitchEndTime(nil)

				return
			end

			if isMainPlayer then
				pg.game.camera.playerCameraMode:blendToFov(55, 0.2)
			end

			self.curPlayerEnt:setInLinkAnim(false)

			local startEffectPosition = self.curPlayerEnt:getPosition():Clone()

			startEffectPosition.y = startEffectPosition.y + self.curPlayerEnt:getHeight() * 0.5

			local dirRot = self:getRotation(initPlayerPos, initEggPos, initPlayerRot)

			self.curPlayerEnt:playEffect(switchingStartEffectResId, {
				position = startEffectPosition,
				rotation = dirRot:ToEulerAngles()
			})

			local extraConfig = {
				position = Vector3(0, self.curPlayerEnt:getHeight() * 0.5, 0),
				duration = moveDuration
			}

			self.curPlayerEnt:setActive(ClientConst.MODEL_VISIBLE_KEY.EGG_MODE, false)
			self.curPlayerEnt:playEffect(switchingEffectResId, extraConfig)
			self.curPlayerEnt:setSwitchEndTime(nil)

			if isMainPlayer and eggEnt and eggEnt.eModel then
				eggEnt:addEModelComponent(Const.COMPONENT_PHYSIC_CONTROLLER)
				eggEnt.eModel:SetupController(Const.COMPONENT_PHYSIC_CONTROLLER, self.curPlayerEnt.eModel, 0)
			end
		end
	end)

	if isMainPlayer then
		timeline:createAndAddClip(stayTime, moveDuration, function(_, currTime)
			if self:isCurPlayerValid() then
				local eggPos = eggEnt:getPosition()
				local blendValue = currTime / moveDuration

				Vector3.enableCreateFromCache()

				local lerpPos = Vector3.Lerp(initPlayerPos, eggPos, blendValue)
				local rx, ry, rz, rw = self.curPlayerEnt.eModel:GetPositionAgentRotationEx()
				local dirRot = self:getRotation(lerpPos, eggPos, Quaternion(rx, ry, rz, rw))

				EModelUtils.setAgentPositionAndRotation(self.curPlayerEnt, lerpPos, dirRot, true)
				Vector3.disableCreateFromCache()
			end
		end)
	end

	timeline:createAndAddTrigger(duration, function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
				pg.game.camera:setTempTargetPlayer(nil)
			end

			self.curPlayerEnt:stopEffect(switchingEffectResId)
		end
	end)
	timeline:setStopCallback(function()
		if self:isCurPlayerValid() then
			if isMainPlayer then
				pg.game.camera.playerCameraMode:cancelFovBlend(0.2)
				pg.game.camera:setTempTargetPlayer(nil)
			end

			self.curPlayerEnt:stopEffect(switchingEffectResId)
			self.curPlayerEnt:stopAnimation(PlayableConst.Link)
			self.curPlayerEnt:setSwitchEndTime(nil)
			self.curPlayerEnt:setInLinkAnim(false)

			self.curPlayerEnt.inSwitchAnim = false
			self.curPlayerEnt.captureSwitchFlag = false
		end
	end)
	timeline:start()
end

function PetSwitchAnim:_getFashionSwitchRawEffectResId(effectResId)
	local resId = effectResId

	if string.sub(resId, 1, 1) ~= "$" then
		resId = "$" .. resId
	end

	if string.sub(resId, -7) ~= ".prefab" then
		resId = resId .. ".prefab"
	end

	return resId
end

function PetSwitchAnim:_playFashionSwitchEffect(entity, effectResId, extraConfig)
	if not entity or string.isNilOrEmpty(effectResId) then
		return nil
	end

	local effectId = entity:playEffect(effectResId, extraConfig)

	if effectId and effectId ~= 0 then
		return effectId
	end

	if not entity.playEffectRaw then
		return nil
	end

	local rawEffectResId = self:_getFashionSwitchRawEffectResId(effectResId)

	if entity.stopEffect then
		entity:stopEffect(rawEffectResId, true)
	end

	extraConfig = extraConfig or {}
	extraConfig.mountType = extraConfig.mountType or EffectConst.MountType.Entity

	return entity:playEffectRaw(rawEffectResId, extraConfig)
end

function PetSwitchAnim:getFashionSwitchToPetEffectResId(additionalEffectResId)
	if not string.isNilOrEmpty(additionalEffectResId) then
		return additionalEffectResId
	end

	if self.curPlayerEnt and self.curPlayerEnt.getFashionSwitchToPetEffectResId then
		return self.curPlayerEnt:getFashionSwitchToPetEffectResId()
	end

	return nil
end

function PetSwitchAnim:getFashionSwitchToPlayerEffectResId(additionalEffectResId)
	if not string.isNilOrEmpty(additionalEffectResId) then
		return additionalEffectResId
	end

	if self.curPlayerEnt and self.curPlayerEnt.getFashionSwitchToPlayerEffectResId then
		return self.curPlayerEnt:getFashionSwitchToPlayerEffectResId()
	end

	return nil
end

return PetSwitchAnim
