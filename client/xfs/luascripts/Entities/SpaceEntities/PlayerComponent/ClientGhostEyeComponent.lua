-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientGhostEyeComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local GhostEyeConst = require("Common.Const.GhostEyeConst")
local SandboxConst = require("Common.Const.SandboxConst")
local ConflictTypes = require("Common.ConflictTypes")
local ClientGhostEyeComponent = class.Component("ClientGhostEyeComponent")

function ClientGhostEyeComponent:ctor()
	self.ghostEyeState = Const.GHOST_EYE_STATE_OFF
	self.GhostEye = {
		isOpen = false
	}
	self.GhostEyeDetect = {
		rangeEffectStartTime = 0,
		rangeEnts = {},
		rangeEffectType = {}
	}
	self.GhostEyeBothSide = {}
	self.GhostEyeNightVision = {}
end

function ClientGhostEyeComponent:preDestroy()
	self:_innerExitGhostEyeState()
end

function ClientGhostEyeComponent:setGhostEyeState(ghostEyeType, ghostEyeAbilityId, entityTagList, outlineRemainTimeTag, outlineRemainTimeCamouflage)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("set ghostEyeState ", ghostEyeType, "   abilityId: ", ghostEyeAbilityId, "   old: ", self.ghostEyeState, "   entityTagList: ", inspect(entityTagList))
	end

	if ghostEyeType == Const.GHOST_EYE_STATE_OFF and not self.GhostEye.isOpen then
		return
	end

	if ghostEyeType ~= Const.GHOST_EYE_STATE_OFF and self.GhostEye.isOpen then
		return
	end

	local lastEyeType = self.ghostEyeState

	self.ghostEyeState = ghostEyeType

	local isOpen = ghostEyeType ~= Const.GHOST_EYE_STATE_OFF

	self.GhostEye.isOpen = isOpen

	self:onSetGhostEyeState(self:getCurPetEntity(), ghostEyeType, lastEyeType, ghostEyeAbilityId, entityTagList, outlineRemainTimeTag, outlineRemainTimeCamouflage)
	facade:SendMessageCommand(MessageName.PET_GHOST_EYE_STATE_CHANGED, {})
	facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.PET_GHOST_EYE_STATE_CHANGED, isOpen or false)
end

function ClientGhostEyeComponent:getGhostEyeState()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("get ghostEyeState ", self.ghostEyeState)
	end

	return self.ghostEyeState
end

function ClientGhostEyeComponent:isInGhostEyeState()
	return self.ghostEyeState ~= Const.GHOST_EYE_STATE_OFF
end

function ClientGhostEyeComponent:exitGhostEyeState()
	if not pg.me:checkStatus(ConflictTypes.CT_EXIT_PET_SPECIAL_VISION) then
		return
	end

	self:_innerExitGhostEyeState()
end

function ClientGhostEyeComponent:forceExitGhostEyeState()
	self:_innerExitGhostEyeState()
end

function ClientGhostEyeComponent:_innerExitGhostEyeState()
	if self.GhostEye.isOpen then
		local petEnt = self.GhostEye.curPetEnt

		if petEnt then
			petEnt:switchSkill(self.GhostEye.ghostEyeAbilityId, self.GhostEye.ghostEyeAbilityId)
		end

		self:setGhostEyeState(Const.GHOST_EYE_STATE_OFF)
	end
end

function ClientGhostEyeComponent:onSetGhostEyeState(petEnt, ghostEyeType, lastEyeType, ghostEyeAbilityId, entityTagList, outlineRemainTimeTag, outlineRemainTimeCamouflage)
	if self.GhostEye.isOpen then
		self.GhostEye.curPetEnt = petEnt
		self.GhostEye.ghostEyeAbilityId = ghostEyeAbilityId
		self.GhostEye.entityTagList = entityTagList
		self.GhostEye.outlineRemainTimeTag = outlineRemainTimeTag
		self.GhostEye.outlineRemainTimeCamouflage = outlineRemainTimeCamouflage
		self.GhostEye.isFirstPlay = self:_checkGhostEyeFirstPlay(ghostEyeType)

		self:onGhostEyeEnable(ghostEyeType)
	else
		self:onGhostEyeDisable(lastEyeType)

		self.GhostEye.ghostEyeAbilityId = nil
		self.GhostEye.entityTagList = nil
		self.GhostEye.outlineRemainTimeTag = nil
		self.GhostEye.outlineRemainTimeCamouflage = nil
		self.GhostEye.isFirstPlay = nil
	end
end

function ClientGhostEyeComponent:onGhostEyeEnable(ghostEyeType)
	if ghostEyeType == Const.GHOST_EYE_STATE_DETECT_TAG or ghostEyeType == Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE or ghostEyeType == Const.GHOST_EYE_STATE_DETECT_ALL then
		self:onGhostEyeDetectEnable()
	elseif ghostEyeType == Const.GHOST_EYE_STATE_BOTH_SIDE then
		self:onGhostEyeBothEnable()
	elseif ghostEyeType == Const.GHOST_EYE_STATE_NIGHT_VISION then
		self:onGhostEyeNightEnable()
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("undefined ghostEyeType: ", ghostEyeType)
	end

	self:_setIgnoreTurnAnimation(true)
	self:refreshGhostEyeBuff()
	pg.global.ui:hide(UIConst.UI_ID_TOPLOGO)

	local lockComponent = pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.focus

	if lockComponent then
		lockComponent:hide()
	end
end

function ClientGhostEyeComponent:onGhostEyeDisable(lastEyeType)
	if lastEyeType == Const.GHOST_EYE_STATE_DETECT_TAG or lastEyeType == Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE or lastEyeType == Const.GHOST_EYE_STATE_DETECT_ALL then
		self:onGhostEyeDetectDisable()
	elseif lastEyeType == Const.GHOST_EYE_STATE_BOTH_SIDE then
		self:onGhostEyeBothDisable()
	elseif lastEyeType == Const.GHOST_EYE_STATE_NIGHT_VISION then
		self:onGhostEyeNightDisable()
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("undefined ghostEyeType: ", lastEyeType)
	end

	self:_setIgnoreTurnAnimation(false)
	self:refreshGhostEyeBuff()

	local petEnt = self.GhostEye.curPetEnt

	if petEnt then
		local cameraForwardX, _, cameraForwardZ = pg.global.cameraMgr:GetWorldCameraForwardEx()
		local cameraForward = Vector3(cameraForwardX, 0, cameraForwardZ)

		petEnt:forceSetPosRot(petEnt:getPosition(), Quaternion.LookRotation(cameraForward, Vector3.up))
	end

	pg.global.ui:show(UIConst.UI_ID_TOPLOGO)

	local lockComponent = pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.focus

	if lockComponent then
		lockComponent:show()
	end
end

function ClientGhostEyeComponent:onGhostEyeDetectEnable()
	self:_detectEntsInRange()

	self.GhostEyeDetect.rangeEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_GHOST_EYE, GhostEyeConst.DETECT_RANGE, GhostEyeConst.DETECT_RANGE)

	local delaySpreadTime = self:isInCombat() and 0 or self.GhostEye.isFirstPlay and GhostEyeConst.DETECT_SPREAD_DELAY_SLOW or GhostEyeConst.DETECT_SPREAD_DELAY_FAST

	self.GhostEyeDetect.rangeEffectStartTime = Time.realtimeSinceStartup + delaySpreadTime

	self:_playGhostEyeDetectEntEffect()
	self:_playGhostEyeDetectRangeEffect()
	pg.global.cameraMgr:AddVolumeEffect(10, GhostEyeConst.DETECT_MASK_EFFECT, -1)

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.DETECT_CAMERA_ENTER_TIME

	pg.game.camera.playerCameraMode:enableGhostEye(true)
end

function ClientGhostEyeComponent:onGhostEyeDetectDisable()
	if self.GhostEyeDetect.rangeEvent ~= nil then
		self:removeRangeEvent(self.GhostEyeDetect.rangeEvent, true)

		self.GhostEyeDetect.rangeEvent = nil
	end

	self.GhostEyeDetect.rangeEffectStartTime = 0

	self:_stopGhostEyeDetectEntEffect()
	self:_stopGhostEyeDetectRangeEffect()
	pg.global.cameraMgr:DelVolumeEffect(GhostEyeConst.DETECT_MASK_EFFECT)

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.DETECT_CAMERA_EXIT_TIME

	pg.game.camera.playerCameraMode:enableGhostEye(false)
	self:_clearAllEntRangeEffects()
end

function ClientGhostEyeComponent:_playGhostEyeDetectEntEffect()
	self.GhostEyeDetect.rangeEffectTimerId = self:addRepeatTimer(0.1, function()
		self:_doGraduallyRangeEffect()
	end)
end

function ClientGhostEyeComponent:_stopGhostEyeDetectEntEffect()
	if self.GhostEyeDetect.rangeEffectTimerId ~= nil then
		self:removeTimer(self.GhostEyeDetect.rangeEffectTimerId)

		self.GhostEyeDetect.rangeEffectTimerId = nil
	end
end

function ClientGhostEyeComponent:_playGhostEyeDetectRangeEffect()
	local petEnt = self.GhostEye.curPetEnt

	if not petEnt or petEnt:isInCombat() then
		return
	end

	local effectName = self.GhostEye.isFirstPlay and GhostEyeConst.DETECT_SPREAD_EFFECT_SLOW or GhostEyeConst.DETECT_SPREAD_EFFECT_FAST

	self.GhostEyeDetect.rangeEffectId = petEnt:playEffect(effectName, {
		neverHide = true,
		duration = -1,
		loadCallback = function(effectItem)
			local delay = math.max(self.GhostEyeDetect.rangeEffectStartTime - Time.realtimeSinceStartup, 0)

			self.GhostEyeDetect.delayScanTimerId = self:addTimer(delay, function()
				if effectItem and effectItem.effectTrans then
					self.GhostEyeDetect.rangeEffectSceneScanManager = effectItem.effectTrans:GetComponent("SceneScanManager")

					local points = {}

					for actorId, _ in pairs(self.GhostEyeDetect.rangeEnts) do
						local ent = pg.getEntityByActorId(actorId)

						if ent then
							points[#points + 1] = ent:getPosition()
						end
					end

					self.GhostEyeDetect.rangeEffectSceneScanManager:TransferPoints(points)
				end
			end)
		end
	})
end

function ClientGhostEyeComponent:_stopGhostEyeDetectRangeEffect()
	if self.GhostEyeDetect.delayScanTimerId ~= nil then
		self:removeTimer(self.GhostEyeDetect.delayScanTimerId)

		self.GhostEyeDetect.delayScanTimerId = nil
	end

	if self.GhostEyeDetect.rangeEffectSceneScanManager ~= nil then
		self.GhostEyeDetect.rangeEffectSceneScanManager:UnloadAllComponent()

		self.GhostEyeDetect.rangeEffectSceneScanManager = nil
	end

	local petEnt = self.GhostEye.curPetEnt

	if self.GhostEyeDetect.rangeEffectId ~= nil then
		local effectId = self.GhostEyeDetect.rangeEffectId

		self:addTimer(0.1, function()
			if petEnt then
				petEnt:stopEffectById(effectId)
			end
		end)

		self.GhostEyeDetect.rangeEffectId = nil
	end
end

function ClientGhostEyeComponent:_detectEntsInRange()
	local actorIds = self:entitiesInRange(GhostEyeConst.DETECT_RANGE, Const.SEARCH_USR_TYPE_ACTOR + Const.SEARCH_USR_TYPE_INTERACTOR + Const.SEARCH_USR_TYPE_ENVOBJ)

	for _, actorId in ipairs(actorIds) do
		local ent = pg.getEntityByActorId(actorId)
		local canBeDetect, effectType = self:_checkEntCanBeDetect(ent)

		if canBeDetect then
			self.GhostEyeDetect.rangeEnts[ent.actorId] = Vector3.SqrDistance(ent:getPosition(), pg.me:getPosition())
			self.GhostEyeDetect.rangeEffectType[ent.actorId] = effectType
		end
	end
end

function ClientGhostEyeComponent:_checkEntCanBeDetect(ent)
	local isDetectTag = self.ghostEyeState == Const.GHOST_EYE_STATE_DETECT_TAG
	local isDetectCamouflage = self.ghostEyeState == Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE
	local isDetectAll = self.ghostEyeState == Const.GHOST_EYE_STATE_DETECT_ALL

	if (isDetectTag or isDetectAll) and self:_checkEntityDetectTag(ent) then
		if Utils.isChest(ent) or Utils.isEnvObj(ent) then
			return true, GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CHEST
		end

		if Utils.isPuppet(ent) then
			return true, GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CONGENER
		end
	end

	if (isDetectCamouflage or isDetectAll) and Utils.isPuppet(ent) and Utils.isEnemy(self, ent) then
		return true, GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CAMOUFLAGE
	end

	return false
end

function ClientGhostEyeComponent:_checkEntityDetectTag(ent)
	if not self.GhostEye.entityTagList then
		return false
	end

	for _, tag in ipairs(self.GhostEye.entityTagList) do
		if Utils.hasEntityTag(ent, tag) then
			return true
		end
	end

	return false
end

function ClientGhostEyeComponent:_doGraduallyRangeEffect()
	local curTime = Time.realtimeSinceStartup
	local curDist = GhostEyeConst.DETECT_SPREAD_SPEED * math.max(curTime - self.GhostEyeDetect.rangeEffectStartTime, 0)
	local curSqrDist = curDist * curDist

	for actorId, sqrDist in pairs(self.GhostEyeDetect.rangeEnts) do
		if sqrDist > 0 and sqrDist < curSqrDist then
			self:_setEntRangeEffect(actorId, true)

			self.GhostEyeDetect.rangeEnts[actorId] = -1
		end
	end
end

function ClientGhostEyeComponent:_setEntRangeEffect(actorId, enable)
	local ent = pg.getEntityByActorId(actorId)

	if ent and ent.eModel then
		local effectType = self.GhostEyeDetect.rangeEffectType[actorId]
		local delayTime = 0

		if not enable then
			if effectType == GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE.CAMOUFLAGE then
				delayTime = self.GhostEye.outlineRemainTimeCamouflage
			else
				delayTime = self.GhostEye.outlineRemainTimeTag
			end
		end

		if ent.setGhostEyeDetectedState then
			ent:setGhostEyeDetectedState(enable, effectType, delayTime)
		end
	end
end

function ClientGhostEyeComponent:_clearAllEntRangeEffects()
	for actorId, _ in pairs(self.GhostEyeDetect.rangeEnts) do
		self:_setEntRangeEffect(actorId, false)
	end

	table.clear(self.GhostEyeDetect.rangeEnts)
	table.clear(self.GhostEyeDetect.rangeEffectType)
end

function ClientGhostEyeComponent:onEnterTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_GHOST_EYE or self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_TAG and self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE and self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_ALL then
		return
	end

	if self.GhostEyeDetect.rangeEnts[actorId] then
		return
	end

	local ent = pg.getEntityByActorId(actorId)
	local canBeDetect, effectType = self:_checkEntCanBeDetect(ent)

	if canBeDetect then
		self.GhostEyeDetect.rangeEnts[actorId] = -1
		self.GhostEyeDetect.rangeEffectType[actorId] = effectType

		self:_setEntRangeEffect(actorId, true)
	end
end

function ClientGhostEyeComponent:onLeaveTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_GHOST_EYE or self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_TAG and self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE and self.ghostEyeState ~= Const.GHOST_EYE_STATE_DETECT_ALL then
		return
	end

	if not self.GhostEyeDetect.rangeEnts[actorId] then
		return
	end

	self:_setEntRangeEffect(actorId, false)

	self.GhostEyeDetect.rangeEnts[actorId] = nil
	self.GhostEyeDetect.rangeEffectType[actorId] = nil
end

function ClientGhostEyeComponent:onGhostEyeBothEnable()
	self:_innerImmediateStopGhostEyeBothEffect()
	self:_playGhostEyeBothEffect()

	if self.GhostEyeBothSide.delayExitCamTimerId ~= nil then
		self:removeTimer(self.GhostEyeBothSide.delayExitCamTimerId)

		self.GhostEyeBothSide.delayExitCamTimerId = nil
	end

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.BOTH_SIDE_CAMERA_ENTER_TIME

	pg.game.camera.playerCameraMode:enableGhostEye(true)
end

function ClientGhostEyeComponent:onGhostEyeBothDisable()
	self:_stopGhostEyeBothEffect()

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.BOTH_SIDE_CAMERA_EXIT_TIME
	self.GhostEyeBothSide.delayExitCamTimerId = self:addTimer(GhostEyeConst.BOTH_SIDE_CAMERA_WAIT_EXIT_TIME, function()
		pg.game.camera.playerCameraMode:enableGhostEye(false)
	end)
end

function ClientGhostEyeComponent:_playGhostEyeBothEffect()
	local petEnt = self.GhostEye.curPetEnt

	if not petEnt then
		return
	end

	local effectName = self.GhostEye.isFirstPlay and GhostEyeConst.BOTH_SIDE_EFFECT_SLOW or GhostEyeConst.BOTH_SIDE_EFFECT_FAST

	self.GhostEyeBothSide.effectId = petEnt:playEffect(effectName, {
		neverHide = true,
		duration = -1,
		loadCallback = function(effectItem)
			if effectItem then
				self.GhostEyeBothSide.effectManager = effectItem.effectTrans:GetComponent("BilateralVisionManager")
			end
		end
	})
end

function ClientGhostEyeComponent:_stopGhostEyeBothEffect()
	if self.GhostEyeBothSide.effectManager ~= nil then
		self.GhostEyeBothSide.effectManager:PlayExit()

		self.GhostEyeBothSide.delayUnloadEffTimerId = self:addTimer(GhostEyeConst.BOTH_SIDE_EFFECT_EXIT_TIME, function()
			self:_innerUnloadGhostEyeBothEffect()
		end)
	end

	if self.GhostEyeBothSide.effectId ~= nil then
		self.GhostEyeBothSide.delayStopEffTimerId = self:addTimer(GhostEyeConst.BOTH_SIDE_EFFECT_EXIT_TIME + 0.1, function()
			self:_innerStopGhostEyeBothEffect()
		end)
	end
end

function ClientGhostEyeComponent:_innerImmediateStopGhostEyeBothEffect()
	if self.GhostEyeBothSide.delayUnloadEffTimerId ~= nil then
		self:removeTimer(self.GhostEyeBothSide.delayUnloadEffTimerId)

		self.GhostEyeBothSide.delayUnloadEffTimerId = nil

		self:_innerUnloadGhostEyeBothEffect()
	end

	if self.GhostEyeBothSide.delayStopEffTimerId ~= nil then
		self:removeTimer(self.GhostEyeBothSide.delayStopEffTimerId)

		self.GhostEyeBothSide.delayStopEffTimerId = nil

		self:_innerStopGhostEyeBothEffect()
	end
end

function ClientGhostEyeComponent:_innerUnloadGhostEyeBothEffect()
	if self.GhostEyeBothSide.effectManager ~= nil then
		self.GhostEyeBothSide.effectManager:UnloadAllComponent()

		self.GhostEyeBothSide.effectManager = nil
	end
end

function ClientGhostEyeComponent:_innerStopGhostEyeBothEffect()
	local petEnt = self.GhostEye.curPetEnt

	if petEnt then
		petEnt:stopEffectById(self.GhostEyeBothSide.effectId)
	end

	self.GhostEyeBothSide.effectId = nil
end

function ClientGhostEyeComponent:onGhostEyeNightEnable()
	self:_playGhostEyeBlinkEffect()
	self:_playGhostEyeNightEffect()

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.NIGHT_VISION_CAMERA_ENTER_TIME

	pg.game.camera.playerCameraMode:enableGhostEye(true)
end

function ClientGhostEyeComponent:onGhostEyeNightDisable()
	self:_stopGhostEyeBlinkEffect()
	self:_stopGhostEyeNightEffect()

	pg.game.camera.ghostEyeBlendTime = GhostEyeConst.NIGHT_VISION_CAMERA_EXIT_TIME

	pg.game.camera.playerCameraMode:enableGhostEye(false)
end

function ClientGhostEyeComponent:_playGhostEyeNightEffect()
	local petEnt = self.GhostEye.curPetEnt

	if not petEnt then
		return
	end

	local effectName = GhostEyeConst.NIGHT_VISION_EFFECT
	local delayTime = self:isInCombat() and 0 or self.GhostEye.isFirstPlay and GhostEyeConst.NIGHT_VISION_DELAY_SLOW or GhostEyeConst.NIGHT_VISION_DELAY_FAST

	self.GhostEyeNightVision.effectTimerId = self:addTimer(delayTime, function()
		if petEnt then
			self.GhostEyeNightVision.effectId = petEnt:playEffect(effectName, {
				neverHide = true,
				duration = -1,
				loadCallback = function(effectItem)
					if effectItem then
						effectItem:SetParentWorldCamera()

						effectItem.effectTrans.localPosition = Vector3.zero
						effectItem.effectTrans.localRotation = Quaternion.identity
						effectItem.effectTrans.localScale = Vector3.one
					end
				end
			})
		end
	end)
end

function ClientGhostEyeComponent:_stopGhostEyeNightEffect()
	if self.GhostEyeNightVision.effectTimerId ~= nil then
		self:removeTimer(self.GhostEyeNightVision.effectTimerId)

		self.GhostEyeNightVision.effectTimerId = nil
	end

	local petEnt = self.GhostEye.curPetEnt

	if self.GhostEyeNightVision.effectId ~= nil then
		if petEnt then
			petEnt:stopEffectById(self.GhostEyeNightVision.effectId)
		end

		self.GhostEyeNightVision.effectId = nil
	end
end

function ClientGhostEyeComponent:_checkGhostEyeFirstPlay(ghostEyeType)
	local key

	if ghostEyeType == Const.GHOST_EYE_STATE_DETECT_TAG then
		key = GhostEyeConst.DETECT_TAG_KEY
	elseif ghostEyeType == Const.GHOST_EYE_STATE_DETECT_CAMOUFLAGE then
		key = GhostEyeConst.DETECT_CAMOUFLAGE_KEY
	elseif ghostEyeType == Const.GHOST_EYE_STATE_DETECT_ALL then
		key = GhostEyeConst.DETECT_ALL_KEY
	elseif ghostEyeType == Const.GHOST_EYE_STATE_BOTH_SIDE then
		key = GhostEyeConst.BOTH_SIDE_KEY
	elseif ghostEyeType == Const.GHOST_EYE_STATE_NIGHT_VISION then
		key = GhostEyeConst.NIGHT_VISION_KEY
	end

	local hasPlay = pg.global.prefsCacheUtils:getBool(key, false)

	if not hasPlay then
		pg.global.prefsCacheUtils:setBool(key, true)
	end

	return not hasPlay
end

function ClientGhostEyeComponent:_playGhostEyeBlinkEffect()
	local petEnt = self.GhostEye.curPetEnt

	if not petEnt or petEnt:isInCombat() then
		return
	end

	local effectName = self.GhostEye.isFirstPlay and GhostEyeConst.COMMON_BLINK_EFFECT_SLOW or GhostEyeConst.COMMON_BLINK_EFFECT_FAST

	self.GhostEye.blinkEffectId = petEnt:playEffect(effectName, {
		neverHide = true,
		duration = -1
	})
end

function ClientGhostEyeComponent:_stopGhostEyeBlinkEffect()
	local petEnt = self.GhostEye.curPetEnt

	if petEnt and self.GhostEye.blinkEffectId ~= nil then
		petEnt:stopEffectById(self.GhostEye.blinkEffectId)
	end
end

function ClientGhostEyeComponent:_setIgnoreTurnAnimation(enable)
	local petEnt = self.GhostEye.curPetEnt

	if not petEnt or not petEnt.eModel then
		return
	end

	petEnt.eModel.IgnoreTurnAnimation = enable
end

function ClientGhostEyeComponent:refreshGhostEyeBuff()
	self:serverMsg("RPC_CS_SetGhostEyeState", self.ghostEyeState)
end

return ClientGhostEyeComponent
