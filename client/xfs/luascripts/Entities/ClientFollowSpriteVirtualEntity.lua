-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientFollowSpriteVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ActorManager = require("Core.Common.ActorManager")
local AppearancePointEnum = require("Data.appearance_point_enum")
local ItemConst = require("Common.Const.ItemConst")
local AbilityConst = require("Common.Const.AbilityConst")
local EventBus = require("Common.Ability.Buff.EventBus")
local PlayableConst = require("Common.Const.PlayableConst")
local Const = require("Common.Const.Const")
local pg = pg
local IsNil = IsNil
local NotNil = NotNil
local FollowingSpriteComponent = CS.FunPlus.WorldX.Entities.Components.FollowingSpriteComponent
local Animator = CS.UnityEngine.Animator
local PlayableReplayMode = CS.FunPlus.WorldX.Animations.PlayableReplayMode
local INTERLUDE_INTERVAL = 8
local FIND_LOOT_REPEAT_INTERVAL = 6.57
local BROKEN_HEIGHT_OFFSET = -0.3
local defaultBody = "$E_P_NPC_GrabEgg_EquArmor_White.prefab"
local resMap = {
	[ItemConst.ITEM_QUALITY.GREEN] = {
		"$E_P_NPC_GrabEgg_EquArmor_Green.prefab",
		"$E_P_NPC_GrabEgg_EquWeapon_Green.prefab"
	},
	[ItemConst.ITEM_QUALITY.BLUE] = {
		"$E_P_NPC_GrabEgg_EquArmor_Blue.prefab",
		"$E_P_NPC_GrabEgg_EquWeapon_Blue.prefab"
	},
	[ItemConst.ITEM_QUALITY.PURPLE] = {
		"$E_P_NPC_GrabEgg_EquArmor_Pruple.prefab",
		"$E_P_NPC_GrabEgg_EquWeapon_Pruple.prefab"
	},
	[ItemConst.ITEM_QUALITY.GOLD] = {
		"$E_P_NPC_GrabEgg_EquArmor_Gold.prefab",
		"$E_P_NPC_GrabEgg_EquWeapon_Gold.prefab"
	}
}
local effectMap = {
	[ItemConst.ITEM_QUALITY.GREEN] = {
		"Eff_Env_GrabEgg_EquArmor_Green_Idle",
		"Eff_Env_GrabEgg_EquArmor_GreenTrail"
	},
	[ItemConst.ITEM_QUALITY.BLUE] = {
		"Eff_Env_GrabEgg_EquArmor_Blue_Idle",
		"Eff_Env_GrabEgg_EquArmor_BlueTrail"
	},
	[ItemConst.ITEM_QUALITY.PURPLE] = {
		"Eff_Env_GrabEgg_EquArmor_Purple_Idle",
		"Eff_Env_GrabEgg_EquArmor_PurpleTrail"
	},
	[ItemConst.ITEM_QUALITY.GOLD] = {
		"Eff_Env_GrabEgg_EquArmor_Gold_Idle",
		"Eff_Env_GrabEgg_EquArmor_GoldTrail"
	}
}
local presetMap = {
	[ItemConst.ITEM_QUALITY.GREEN] = "Eff_NPC_GrabEgg_EquWeapon_Green0",
	[ItemConst.ITEM_QUALITY.BLUE] = "Eff_NPC_GrabEgg_EquWeapon_Blue",
	[ItemConst.ITEM_QUALITY.PURPLE] = "Eff_NPC_GrabEgg_EquWeapon_Purple",
	[ItemConst.ITEM_QUALITY.GOLD] = "Eff_NPC_GrabEgg_EquWeapon_Gold"
}
local animMap = {
	Idle = "Idle",
	FindLoot = "Excited",
	IdleBreak = "Break_Idle",
	MovePlay = "Move_Play01",
	MoveBreak = "Break_Move",
	IdlePlay = "Play01",
	BeHit = "BeHit",
	Move = "RunLoop"
}
local ClientFollowSpriteVirtualEntity = Class.Class("ClientFollowSpriteVirtualEntity", ClientSimpleVirtualEntity)
local WEAPON_TRAIL_STOP_DELAY = 0.8

function ClientFollowSpriteVirtualEntity:init(dict)
	ClientSimpleVirtualEntity.init(self, dict)

	self.masterActorId = dict.masterActorId
	self.ownerActorId = dict.ownerActorId
	self.offsetHeight = dict.offsetHeight or 1
	self.offsetBack = dict.offsetBack or 0.3
	self.offsetHorizontal = dict.offsetHorizontal or -0.2
	self.walkSpeed = dict.walkSpeed
	self.scale = dict.scale
	self.minMoveDis = dict.minMoveDis
	self.acceleration = dict.acceleration
	self.maxVelocity = dict.maxVelocity
	self.teleportDis = dict.teleportDis
	self.animController = dict.animController or "Map_BaseLoco_GrabEgg_Elve"
	self.curArmorDura = dict.curArmorDura
	self.curWeaponDura = dict.curWeaponDura
	self.armorQuality = dict.armorQuality
	self.weaponQuality = dict.weaponQuality
	self.isBroken = self:computeIsBroken()
	self.idleState, self.moveState = self:getLocoStates()
	self.beHitObserver = EventBus.EventObserver()
	self.nearbyLootSet = {}
	self.nearbyLootCount = 0
	self.modelResId = resMap[self.armorQuality] and resMap[self.armorQuality][1] or defaultBody
	self.earModelResId = resMap[self.weaponQuality] and resMap[self.weaponQuality][2] or nil
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()

	ActorManager.addEntity(self.actorId, self)
end

function ClientFollowSpriteVirtualEntity:start()
	ClientSimpleVirtualEntity.start(self)
	self:refreshVisible()

	if self.scale then
		self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, self.scale)
	end

	self.interludeTimer = self:addRepeatTimer(INTERLUDE_INTERVAL, function()
		self:tryPlayInterlude()
	end)
end

function ClientFollowSpriteVirtualEntity:computeIsBroken()
	local armorBroken = self.armorQuality and self.armorQuality > 0 and (self.curArmorDura or 0) == 0
	local weaponBroken = self.weaponQuality and self.weaponQuality > 0 and (self.curWeaponDura or 0) == 0

	return armorBroken or weaponBroken or false
end

function ClientFollowSpriteVirtualEntity:getLocoStates()
	if self.isBroken then
		return animMap.IdleBreak, animMap.MoveBreak
	end

	return animMap.Idle, animMap.Move
end

function ClientFollowSpriteVirtualEntity:playOneShot(animName)
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	if not self.followingSpriteCom then
		return
	end

	local key = Animator.StringToHash(animName)
	local state = self.eModel:PlayAnimation(Const.COMPONENT_IDX_PLAYABLE, key, PlayableReplayMode.FromStart)

	if not state then
		return
	end

	local duration = state.Length or 0

	if duration <= 0 then
		duration = 1
	end

	self.followingSpriteCom:SuppressSpriteAnim(self.id, duration)

	self.currentOneShotName = animName
	self.currentOneShotState = state

	state:AddAutoTransition(0)
	state:RemoveEndCallback()
	state:AddEndCallback(function(reason)
		if self.currentOneShotState ~= state then
			return
		end

		self.currentOneShotName = nil
		self.currentOneShotState = nil

		if reason == PlayableConst.END_REASON.PLAYBACK then
			self:resumeBaseLoco()
		end
	end)

	return state
end

function ClientFollowSpriteVirtualEntity:resumeBaseLoco()
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	if not self.followingSpriteCom then
		return
	end

	local isMoving = self.followingSpriteCom:GetIsMoving(self.id)
	local baseAnim = isMoving and self.moveState or self.idleState

	self.eModel:PlayAnimation(Const.COMPONENT_IDX_PLAYABLE, Animator.StringToHash(baseAnim), PlayableReplayMode.FromStart)
	self.followingSpriteCom:SuppressSpriteAnim(self.id, 0)
end

function ClientFollowSpriteVirtualEntity:tryPlayInterlude()
	if self.currentOneShotName then
		return
	end

	if not self.followingSpriteCom then
		return
	end

	if self.isBroken then
		return
	end

	local animName = self.followingSpriteCom:GetIsMoving(self.id) and animMap.MovePlay or animMap.IdlePlay

	self:playOneShot(animName)
end

function ClientFollowSpriteVirtualEntity:addNearbyLoot(actorId)
	if self.nearbyLootSet[actorId] then
		return
	end

	self.nearbyLootSet[actorId] = true
	self.nearbyLootCount = self.nearbyLootCount + 1

	self:tryStartFindLootTimer()
end

function ClientFollowSpriteVirtualEntity:removeNearbyLoot(actorId)
	if not self.nearbyLootSet[actorId] then
		return
	end

	self.nearbyLootSet[actorId] = nil
	self.nearbyLootCount = self.nearbyLootCount - 1

	if self.nearbyLootCount <= 0 then
		self.nearbyLootCount = 0

		self:stopFindLootTimer()
	end
end

function ClientFollowSpriteVirtualEntity:tryStartFindLootTimer()
	if self.findLootTimer then
		return
	end

	if self.isBroken then
		return
	end

	if self.nearbyLootCount <= 0 then
		return
	end

	self:tryPlayFindLoot()

	if self.findLootTimer or self.nearbyLootCount <= 0 then
		return
	end

	self.findLootTimer = self:addRepeatTimer(FIND_LOOT_REPEAT_INTERVAL, function()
		self:tryPlayFindLoot()
	end)
end

function ClientFollowSpriteVirtualEntity:stopFindLootTimer()
	if self.findLootTimer then
		self:removeTimer(self.findLootTimer)

		self.findLootTimer = nil
	end
end

function ClientFollowSpriteVirtualEntity:pruneNearbyLoot()
	for actorId in pairs(self.nearbyLootSet) do
		local ent = pg.getEntityByActorId(actorId)
		local shouldRemove = ent == nil

		if ent and (ent.isOpened or ent.openProgress and ent.openProgress >= 100) then
			shouldRemove = true
		end

		if shouldRemove then
			self.nearbyLootSet[actorId] = nil
			self.nearbyLootCount = self.nearbyLootCount - 1
		end
	end

	if self.nearbyLootCount < 0 then
		self.nearbyLootCount = 0
	end
end

function ClientFollowSpriteVirtualEntity:tryPlayFindLoot()
	self:pruneNearbyLoot()

	if self.nearbyLootCount <= 0 then
		self:stopFindLootTimer()

		return
	end

	if self.isBroken then
		return
	end

	if self.currentOneShotName == animMap.BeHit then
		return
	end

	if self.currentOneShotName == animMap.FindLoot then
		return
	end

	self:playOneShot(animMap.FindLoot)
end

function ClientFollowSpriteVirtualEntity:listenBeHit(masterEntity)
	self.beHitObserver:unlistenAll()

	local function cb()
		self:playOneShot(animMap.BeHit)
	end

	local seen = {}

	local function listenOne(ent)
		if not ent or not ent.subject then
			return
		end

		if seen[ent.actorId] then
			return
		end

		seen[ent.actorId] = true

		self.beHitObserver:listen(ent.subject, AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, cb)
	end

	listenOne(masterEntity)

	local ownerEnt = self.ownerActorId and pg.getEntityByActorId(self.ownerActorId) or nil

	listenOne(ownerEnt)

	if ownerEnt and ownerEnt.getActivePetEnt then
		listenOne(ownerEnt:getActivePetEnt())
	end
end

function ClientFollowSpriteVirtualEntity:updateBrokenState()
	local newBroken = self:computeIsBroken()

	if newBroken == self.isBroken then
		return
	end

	self.isBroken = newBroken
	self.idleState, self.moveState = self:getLocoStates()

	if self.followingSpriteCom then
		self.followingSpriteCom:SetSpriteAnimStates(self.id, self.idleState, self.moveState)
		self:applyOffsetOverride()
	end

	if self.isBroken then
		self:stopFindLootTimer()
	else
		self:tryStartFindLootTimer()
	end
end

function ClientFollowSpriteVirtualEntity:getEffectiveOffset()
	local heightBonus = self.isBroken and BROKEN_HEIGHT_OFFSET or 0

	return self.offsetHorizontal or 0, (self.offsetHeight or 0) + heightBonus, -(self.offsetBack or 0)
end

function ClientFollowSpriteVirtualEntity:applyOffsetOverride()
	if not self.followingSpriteCom then
		return
	end

	local x, y, z = self:getEffectiveOffset()

	self.followingSpriteCom:SetSpriteOverrideOffset(self.id, Vector3(x, y, z))
end

function ClientFollowSpriteVirtualEntity:getConfigData()
	if self.earModelResId then
		return {
			modelResId = self.modelResId,
			partItems = {
				[AppearancePointEnum.Coat] = {
					isAvatarWearPart = false,
					resId = self.earModelResId
				}
			},
			animController = self.animController
		}
	else
		return {
			modelResId = self.modelResId,
			animController = self.animController
		}
	end
end

function ClientFollowSpriteVirtualEntity:refreshVisible()
	local masterEntity = pg.getEntityByActorId(self.masterActorId)

	if not masterEntity then
		return
	end

	if not masterEntity.eModel or IsNil(masterEntity.eModel.modelView) then
		return
	end

	local followingSpriteCom = FollowingSpriteComponent.GetByActorId(masterEntity.actorId)

	if not followingSpriteCom then
		self.eModel:SetActive(false)

		return
	end

	if self.active then
		self.idleState, self.moveState = self:getLocoStates()

		followingSpriteCom:AddFollowingSprite(self.id, self.offsetHeight or 0, self.offsetBack or 0, self.offsetHorizontal or 0, self.idleState, self.moveState, self.walkSpeed or 6)

		self.followingSpriteCom = followingSpriteCom

		self:applyOffsetOverride()
		followingSpriteCom:SetData(self.minMoveDis or 2, self.acceleration or 20, self.maxVelocity or 10, self.teleportDis or 5)
		self:applyDurabilityEffects()
		self:listenBeHit(masterEntity)
	end

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.ROBEGG_SPRITE, self.active)
end

function ClientFollowSpriteVirtualEntity:destroy()
	ClientSimpleVirtualEntity.destroy(self)
	ActorManager.removeEntity(self.actorId, self)
end

function ClientFollowSpriteVirtualEntity:preDestroy()
	if self.interludeTimer then
		self:removeTimer(self.interludeTimer)

		self.interludeTimer = nil
	end

	self:stopFindLootTimer()

	if self.beHitObserver then
		self.beHitObserver:unlistenAll()
	end

	self.currentOneShotName = nil
	self.currentOneShotState = nil

	self:clearDurabilityEffects()

	local masterEntity = pg.getEntityByActorId(self.masterActorId)

	if masterEntity and masterEntity.eModel and NotNil(masterEntity.eModel.modelView) then
		local followingSpriteCom = FollowingSpriteComponent.GetByActorId(masterEntity.actorId)

		if followingSpriteCom then
			followingSpriteCom:RemoveFollowSprite(self.id)
		end
	end

	ClientSimpleVirtualEntity.preDestroy(self)
end

function ClientFollowSpriteVirtualEntity:refreshAppearance()
	if not self.eModel then
		return
	end

	self:setModelLayer(ClientConst.LayerDefine.LAYER_IGNORE_RAYCAST)

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientFollowSpriteVirtualEntity:applyPreset()
	if not self.armorQuality then
		return
	end

	local presetName = presetMap[self.armorQuality]

	if not presetName then
		return
	end

	ClientEffectUtils.PlayPreset(self, presetName, -1, false)
end

function ClientFollowSpriteVirtualEntity:changeModel(modelResId)
	self.modelResId = modelResId

	self:refreshAppearance()
end

function ClientFollowSpriteVirtualEntity:changeMaster(newMasterActorId)
	if self.masterActorId == newMasterActorId then
		return
	end

	if self.followingSpriteCom then
		self:clearDurabilityEffects()
		self.followingSpriteCom:RemoveFollowSprite(self.id)

		self.followingSpriteCom = nil
	end

	if self.beHitObserver then
		self.beHitObserver:unlistenAll()
	end

	self.masterActorId = newMasterActorId

	self:refreshVisible()
end

function ClientFollowSpriteVirtualEntity:applyDurabilityEffects()
	self:clearDurabilityEffects()
	self:updateDurabilityEffect()
end

function ClientFollowSpriteVirtualEntity:updateDurabilityEffect()
	local armorEffects = self.armorQuality and effectMap[self.armorQuality]

	if armorEffects and armorEffects[1] and armorEffects[1] ~= "" then
		local shouldPlay = self.curArmorDura and self.curArmorDura > 0 or false

		if shouldPlay ~= self.armorEffectPlaying then
			if shouldPlay then
				self:playEffect(armorEffects[1])
			else
				self:stopEffect(armorEffects[1])
			end

			self.armorEffectPlaying = shouldPlay
		end
	end

	local weaponEffects = self.weaponQuality and effectMap[self.weaponQuality]

	if weaponEffects and weaponEffects[2] and weaponEffects[2] ~= "" then
		local hasDura = self.curWeaponDura and self.curWeaponDura > 0 or false

		if not hasDura then
			self:cancelWeaponTrailStopTimer()

			if self.weaponTrailPlaying then
				self:stopEffect(weaponEffects[2])

				self.weaponTrailPlaying = false
			end
		end
	end
end

function ClientFollowSpriteVirtualEntity:cancelWeaponTrailStopTimer()
	if self.weaponTrailStopTimer then
		self:removeTimer(self.weaponTrailStopTimer)

		self.weaponTrailStopTimer = nil
	end
end

function ClientFollowSpriteVirtualEntity:tick(deltaTime)
	self:updateWeaponTrailByMovement()
end

function ClientFollowSpriteVirtualEntity:updateWeaponTrailByMovement()
	if not self.followingSpriteCom then
		return
	end

	local weaponEffects = self.weaponQuality and effectMap[self.weaponQuality]

	if not weaponEffects or not weaponEffects[2] or weaponEffects[2] == "" then
		return
	end

	if not self.curWeaponDura or not (self.curWeaponDura > 0) then
		return
	end

	local effectKey = weaponEffects[2]
	local isMoving = self.followingSpriteCom:GetIsMoving(self.id)

	if isMoving then
		self:cancelWeaponTrailStopTimer()

		if not self.weaponTrailPlaying then
			self:playEffect(effectKey)

			self.weaponTrailPlaying = true
		end
	elseif self.weaponTrailPlaying and not self.weaponTrailStopTimer then
		self.weaponTrailStopTimer = self:addTimer(WEAPON_TRAIL_STOP_DELAY, function()
			self.weaponTrailStopTimer = nil

			if self.weaponTrailPlaying then
				self:stopEffect(effectKey)

				self.weaponTrailPlaying = false
			end
		end)
	end
end

function ClientFollowSpriteVirtualEntity:clearDurabilityEffects()
	self.armorEffectPlaying = nil
	self.weaponTrailPlaying = nil

	self:cancelWeaponTrailStopTimer()

	local armorEffects = self.armorQuality and effectMap[self.armorQuality]

	if armorEffects and armorEffects[1] and armorEffects[1] ~= "" then
		self:stopEffect(armorEffects[1])
	end

	local weaponEffects = self.weaponQuality and effectMap[self.weaponQuality]

	if weaponEffects and weaponEffects[2] and weaponEffects[2] ~= "" then
		self:stopEffect(weaponEffects[2])
	end
end

function ClientFollowSpriteVirtualEntity:setDurability(curArmorDura, curWeaponDura)
	self.curArmorDura = curArmorDura or 0
	self.curWeaponDura = curWeaponDura or 0

	self:updateDurabilityEffect()
	self:updateBrokenState()
end

function ClientFollowSpriteVirtualEntity:onModelRefreshed()
	ClientFollowSpriteVirtualEntity.super.onModelRefreshed(self)
	self:refreshVisible()
	self:refreshModelSwitchTag()
	self:applyPreset()
end

return ClientFollowSpriteVirtualEntity
