-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientScentTrackingComponent.lua

local class = require("Core.Framework.Class")
local ScentTrackingConst = require("Const.ScentTrackingConst")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local Vector3 = Vector3
local ToBool = ToBool
local ClientScentTrackingComponent = class.Component("ClientScentTrackingComponent")

function ClientScentTrackingComponent:ctor()
	self.scentTrackingState = ScentTrackingConst.ScentTrackingState.None

	if self.updateStateCache then
		self:updateStateCache("SCENT_TRACKING_ST")
	end

	self.scentTrackingOwnerActorId = nil
	self.closestScentTrackingTargetInfos = {}
	self.currentTrackingItem = nil
	self.lastTrackingItem = nil
end

function ClientScentTrackingComponent:enableScentTrackingState(enable, casterActorId)
	if enable then
		self:enterScentTracking()

		self.scentTrackingOwnerActorId = casterActorId
	else
		self:exitScentTracking()
	end
end

function ClientScentTrackingComponent:isInScentTrackReadyState()
	return self.scentTrackingState == ScentTrackingConst.ScentTrackingState.Ready
end

function ClientScentTrackingComponent:enterScentTracking()
	self:exitScentTracking()
	self:onEnterScentTracking()
end

function ClientScentTrackingComponent:exitScentTracking()
	self:onExitScentTracking()

	self.scentTrackingOwnerActorId = nil
end

function ClientScentTrackingComponent:pauseScentTracking()
	if self.scentTrackingState ~= ScentTrackingConst.ScentTrackingState.Tracking then
		return
	end

	if self.currentTrackingItem == nil or not self.currentTrackingItem.entity or not self.currentTrackingItem.effectId then
		return
	end

	local effectTransform = self.currentTrackingItem.entity:getEffectTransform(self.currentTrackingItem.effectId)

	effectTransform.gameObject:SetActiveEx(false)
end

function ClientScentTrackingComponent:restartScentTracking()
	if self.scentTrackingState ~= ScentTrackingConst.ScentTrackingState.Tracking then
		return
	end

	if self.currentTrackingItem == nil or not self.currentTrackingItem.entity or not self.currentTrackingItem.effectId then
		return
	end

	local effectTransform = self.currentTrackingItem.entity:getEffectTransform(self.currentTrackingItem.effectId)

	effectTransform.gameObject:SetActiveEx(true)
end

function ClientScentTrackingComponent:onEnterScentTracking()
	local sniffState = pg.pawn:playAnimation(PlayableConst.ExploreSkill_Smell)

	if not sniffState then
		return
	end

	sniffState:AddEndCallback(function(reason)
		if reason == PlayableConst.END_REASON.PLAYBACK then
			self:onScentTrackingReady()
		elseif reason == PlayableConst.END_REASON.INTERRUPT then
			self:exitScentTracking()
		end
	end)
	pg.global.ui.video:open({
		videoType = Const.VideoType.BlackTransition
	})
end

function ClientScentTrackingComponent:onScentTrackingReady()
	self.scentTrackingState = ScentTrackingConst.ScentTrackingState.Ready

	if self.updateStateCache then
		self:updateStateCache("SCENT_TRACKING_ST")
	end

	local foundTrack = self:playScentTrackingEffect()

	if not foundTrack then
		self:exitScentTracking()
		pg.global.showBubbleMessageRaw(pg.getGameString("SCENT_TRACKING_TARGET_NOT_FOUND"))

		return
	end

	facade:sendMsgToUI(MessageName.SCENT_TRACK_STATE_CHANGED)

	self.scentTrackTickTimer = self:addRepeatTimer(1, function()
		self:stopScentTrackingEffect()
		self:playScentTrackingEffect()
	end)
end

function ClientScentTrackingComponent:onScentTrackingAim()
	return
end

function ClientScentTrackingComponent:onScentTrackingSelected(entity)
	for _, info in ipairs(self.closestScentTrackingTargetInfos) do
		if info.entity and info.effectId then
			if info.entity.actorId ~= entity.actorId then
				info.entity:stopEffectById(info.effectId)
			else
				self.currentTrackingItem = info
				self.lastTrackingItem = self.currentTrackingItem
			end
		end
	end

	self.closestScentTrackingTargetInfos = {}
	self.scentTrackingState = ScentTrackingConst.ScentTrackingState.Tracking

	if self.updateStateCache then
		self:updateStateCache("SCENT_TRACKING_ST")
	end

	facade:sendMsgToUI(MessageName.SCENT_TRACK_STATE_CHANGED)
end

function ClientScentTrackingComponent:onRecoverLastScentTrackingItem()
	if self.lastTrackingItem == nil or not self.lastTrackingItem.entity then
		pg.global.showBubbleMessageRaw(pg.getGameString("LAST_SCENT_TRACKING_TARGET_NOT_FOUND"))

		return
	end

	self.currentTrackingItem = self.lastTrackingItem

	local trackEffectKey = self:getScentTrackingEffect(self.currentTrackingItem.entity)

	self.currentTrackingItem.effectId = self.currentTrackingItem.entity:playLinkEffect(trackEffectKey, pg.me)
end

function ClientScentTrackingComponent:onExitScentTracking()
	self.scentTrackingState = ScentTrackingConst.ScentTrackingState.None

	if self.updateStateCache then
		self:updateStateCache("SCENT_TRACKING_ST")
	end

	self:stopScentTrackingEffect()

	if self.currentTrackingItem ~= nil then
		if self.currentTrackingItem.entity and self.currentTrackingItem.effectId then
			self.currentTrackingItem.entity:stopEffectById(self.currentTrackingItem.effectId)
		end

		self.currentTrackingItem = nil
	end

	if self.scentTrackTickTimer then
		self:removeTimer(self.scentTrackTickTimer)
	end

	facade:sendMsgToUI(MessageName.SCENT_TRACK_STATE_CHANGED)
end

function ClientScentTrackingComponent:gatherTrackingEntities()
	local scentTrackingTargetInfos = {}
	local actorIds = self:entitiesInRange(ScentTrackingConst.TrackSearchDistance, ScentTrackingConst.TrackSearchType)

	for _, actorId in ipairs(actorIds) do
		local ent = pg.getEntityByActorId(actorId)
		local canBeTracked = self:canBeScentTracked(ent)

		if canBeTracked then
			local sqrDistance = Vector3.SqrDistance(ent:getPosition(), pg.pawn:getPosition())

			for i = 1, ScentTrackingConst.MaxTrackCnt do
				if scentTrackingTargetInfos[i] == nil then
					scentTrackingTargetInfos[i] = {
						sqrDistance = sqrDistance,
						entity = ent
					}

					break
				else
					local curTargetInfo = scentTrackingTargetInfos[i]

					if sqrDistance < curTargetInfo.sqrDistance then
						if curTargetInfo.entity.templateId == ent.templateId then
							curTargetInfo.sqrDistance = sqrDistance
							curTargetInfo.entity = ent

							break
						end

						local tempDisVal = curTargetInfo.sqrDistance
						local tempEntity = curTargetInfo.entity

						curTargetInfo.sqrDistance = sqrDistance
						curTargetInfo.entity = ent
						sqrDistance = tempDisVal
						ent = tempEntity
					end
				end
			end
		end
	end

	return scentTrackingTargetInfos
end

function ClientScentTrackingComponent:canBeScentTracked(ent)
	if not ent then
		return false
	end

	return true
end

function ClientScentTrackingComponent:getScentTrackingEffect(ent)
	if not ent then
		return nil
	end

	if Utils.isPuppet(ent) then
		return ScentTrackingConst.SCENT_TRACK_MONSTER_EFFECT
	end

	return nil
end

function ClientScentTrackingComponent:playScentTrackingEffect()
	self.closestScentTrackingTargetInfos = self:gatherTrackingEntities()

	for _, info in ipairs(self.closestScentTrackingTargetInfos) do
		local trackEffectKey = self:getScentTrackingEffect(info.entity)
		local effectId = info.entity:playLinkEffect(trackEffectKey, pg.me)

		info.effectId = effectId
	end

	return ToBool(self.closestScentTrackingTargetInfos)
end

function ClientScentTrackingComponent:stopScentTrackingEffect()
	for _, info in ipairs(self.closestScentTrackingTargetInfos) do
		if info.entity and info.effectId then
			info.entity:stopEffectById(info.effectId)
		end
	end
end

function ClientScentTrackingComponent:EVENT_OnPetLifeDead(actorId)
	if self.scentTrackingOwnerActorId == actorId then
		self:exitScentTracking()
	end
end

function ClientScentTrackingComponent:onEnterCombat()
	self:pauseScentTracking()
end

function ClientScentTrackingComponent:onLeaveCombat()
	self:restartScentTracking()
end

function ClientScentTrackingComponent:EVENT_onControlPetSwitchToAnotherPet()
	local curPet = self:getCurPetEntity()

	if not curPet or curPet.actorId ~= self.scentTrackingOwnerActorId then
		self:pauseScentTracking()
	else
		self:restartScentTracking()
	end
end

function ClientScentTrackingComponent:EVENT_onControlPetSwitchToPlayer()
	self:pauseScentTracking()
end

function ClientScentTrackingComponent:EVENT_onControlPlayerSwitchToPet()
	local curPet = self:getCurPetEntity()

	if curPet and curPet.actorId == self.scentTrackingOwnerActorId then
		self:restartScentTracking()
	end
end

function ClientScentTrackingComponent:EVENT_OnPetDestroy(actorId)
	if self.scentTrackingOwnerActorId == actorId then
		self:exitScentTracking()
	end
end

return ClientScentTrackingComponent
