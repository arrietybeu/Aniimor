-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientEggModeComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientEggModeComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local EggRandomModelIdData = require("Data.egg_random_model_id_data")
local EggIdToModelResData = require("Data.egg_id_to_model_res_data")
local EggPatternColorData = require("Data.egg_pattern_color_data")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local MessageName = require("Const.MessageName")
local CallbackHandler = require("Core.Common.CallbackHandler")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientEggModeComponent = class.Component("ClientEggModeComponent")

function ClientEggModeComponent:ctor()
	return
end

function ClientEggModeComponent:start()
	if self.isDungeonBot then
		return
	end

	self:cacheEquipShowIds()

	local visible = self.curHighGrassId == 0 or self.curHighGrassId == pg.me.curHighGrassId

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.IN_HIGH_GRASS, visible)

	if self.eggManTemplateId and self.eggManTemplateId > 0 then
		self:tryDeformToEggMan(self.eggManTemplateId)
	end

	pg.game:setModuleEnable("ForceControlEgg", ClientConst.ModuleKey.PetLink, not self.forceControlEgg)

	if ToBool(self.controlEggId) then
		self:switchToEgg(false)
	end
end

function ClientEggModeComponent:onEnterSpace()
	if pg.space and pg.space:isGrabEgg() then
		local radius = SysConfigData.GRAB_EGG_EMPTY_IDLE_RANGE or 50

		self.lootRangeEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_GRAB_EGG_LOOT_REACTION, radius, radius)
	end
end

function ClientEggModeComponent:onLeaveSpace()
	if self.lootRangeEvent then
		self:removeRangeEvent(self.lootRangeEvent, true)

		self.lootRangeEvent = nil
	end

	self:onControlledEggBeDropped()
end

function ClientEggModeComponent:EVENT_OnModelRefreshed()
	self:createFollowSprite()
end

function ClientEggModeComponent:createFollowSprite()
	if not pg.space or not pg.space:isGrabEgg() then
		return
	end

	if self.followSprite then
		return
	end

	local armorInfo = self.equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR]
	local weaponInfo = self.equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON]
	local armorQuality = 0
	local weaponQuality = 0
	local curArmorDura = 0
	local curWeaponDura = 0

	if armorInfo then
		local armorEquipId = armorInfo.equipId

		if armorEquipId and ItemData[armorEquipId] then
			armorQuality = ItemData[armorEquipId].quality
		end

		curArmorDura = armorInfo.curDura or 0
	end

	if weaponInfo then
		local weaponEquipId = weaponInfo.equipId

		if weaponEquipId and ItemData[weaponEquipId] then
			weaponQuality = ItemData[weaponEquipId].quality
		end

		curWeaponDura = weaponInfo.curDura or 0
	end

	local masterActorId = self.actorId

	if self:isControllingPet() then
		local petEnt = self:getActivePetEnt()

		if petEnt then
			masterActorId = petEnt.actorId
		end
	end

	self.followSprite = ClientUtils.createClientEntity("ClientFollowSpriteVirtualEntity", VirtualEntUtils.getNewVirtualEntityId(), {
		masterActorId = masterActorId,
		ownerActorId = self.actorId,
		armorQuality = armorQuality,
		weaponQuality = weaponQuality,
		curArmorDura = curArmorDura,
		curWeaponDura = curWeaponDura
	})

	self:ensureSpriteMasterReconcile()
end

function ClientEggModeComponent:destroy()
	self:cancelSpriteMasterReconcile()

	if self.followSprite then
		ClientUtils.safeDestroy(self.followSprite)

		self.followSprite = nil
	end

	if self.lootRangeEvent then
		self:removeRangeEvent(self.lootRangeEvent, true)

		self.lootRangeEvent = nil
	end

	self:stopEggStruggleQte()
end

function ClientEggModeComponent:onEnterTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_GRAB_EGG_LOOT_REACTION then
		return
	end

	if not self.followSprite then
		return
	end

	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return
	end

	if not self:isFindLootTarget(ent) then
		return
	end

	self.followSprite:addNearbyLoot(actorId)
end

function ClientEggModeComponent:onLeaveTrap(actorId, eventId)
	if eventId ~= Const.TRAP_EVENT_ID_GRAB_EGG_LOOT_REACTION then
		return
	end

	if not self.followSprite then
		return
	end

	self.followSprite:removeNearbyLoot(actorId)
end

function ClientEggModeComponent:getActivePetEnt()
	if self == pg.me and pg.pawn and pg.pawn ~= self then
		return pg.pawn
	end

	if self:isControllingExplorePet() then
		return self:getControllingExploreEnt()
	end

	local exploreIdx = self.exploreAbilityIndex

	if exploreIdx and exploreIdx > 0 then
		return pg.getEntity(self.petExploreList[exploreIdx])
	end

	return self:getCurPetEntity()
end

function ClientEggModeComponent:isFindLootTarget(ent)
	if not ent or not ent.subType then
		return false
	end

	if ent.subType == Const.ROB_EGG_LOOT_TYPE.EGG_NEST then
		return true
	end

	if ent.subType == Const.ROB_EGG_LOOT_TYPE.RESOURCE_BOX then
		local cfg = ent.getConfigData and ent:getConfigData() or nil

		return cfg ~= nil and cfg.quality == ItemConst.ITEM_QUALITY.GOLD
	end

	return false
end

function ClientEggModeComponent:refreshFollowSprite()
	if self.followSprite then
		ClientUtils.safeDestroy(self.followSprite)

		self.followSprite = nil
	end

	self:createFollowSprite()
end

function ClientEggModeComponent:refreshFollowSpriteDurability()
	if not self.followSprite then
		self:createFollowSprite()

		return
	end

	local armorInfo = self.equipShowInfo and self.equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR]
	local weaponInfo = self.equipShowInfo and self.equipShowInfo[ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON]
	local curArmorDura = armorInfo and armorInfo.curDura or 0
	local curWeaponDura = weaponInfo and weaponInfo.curDura or 0

	self.followSprite:setDurability(curArmorDura, curWeaponDura)
end

function ClientEggModeComponent:getRobEggSpriteEquipId(info)
	return info and info.equipId or nil
end

function ClientEggModeComponent:cacheEquipShowIds()
	self._cachedEquipIds = {}

	for pos, info in pairs(self.equipShowInfo or EMPTY_TABLE) do
		self._cachedEquipIds[pos] = self:getRobEggSpriteEquipId(info)
	end
end

function ClientEggModeComponent:on_equipShowInfo_changed(oldValue, newValue)
	local cached = self._cachedEquipIds or {}
	local equipChanged = false

	for pos, info in pairs(newValue or EMPTY_TABLE) do
		if cached[pos] ~= self:getRobEggSpriteEquipId(info) then
			equipChanged = true

			break
		end
	end

	self:cacheEquipShowIds()

	if equipChanged then
		self:refreshFollowSprite()
	else
		self:refreshFollowSpriteDurability()
	end

	self:notifyEquipShowInfoChanged()
end

function ClientEggModeComponent:notifyEquipShowInfoChanged()
	if self ~= pg.me then
		return
	end

	facade:sendMsgToUI(MessageName.GRAB_EGG_EQUIP_SHOW_INFO_CHANGED)
end

function ClientEggModeComponent:on_chipSkillId_changed(ov, nv)
	if self ~= pg.me then
		return
	end

	facade:sendMsgToUI(MessageName.GRAB_EGG_CHIP_SKILL_ID_CHANGED, nv)
end

function ClientEggModeComponent:EVENT_OnPetControlChanged()
	if self ~= pg.me then
		local petEnt = self:getActivePetEnt()

		if petEnt and petEnt.subject then
			local eventName = self:isControllingPet() and AbilityConst.COMBAT_EVENT_ON_PET_ENTER_CONTROL or AbilityConst.COMBAT_EVENT_ON_PET_LEAVE_CONTROL

			petEnt.subject:notify(eventName)
		end
	end

	self:reconcileSpriteMaster()
	self:ensureSpriteMasterReconcile()
end

local SPRITE_MASTER_RECONCILE_INTERVAL = 0.2

function ClientEggModeComponent:isEntReadyForSprite(ent)
	if not ent or not ent.actorId then
		return false
	end

	local trans = CSEntityManager:GetPositionAgentByActorId(ent.actorId)

	return not IsNil(trans) and trans.gameObject.activeInHierarchy
end

function ClientEggModeComponent:getDesiredSpriteMasterEnt()
	if self:isControllingPet() then
		local petEnt = self:getActivePetEnt()

		if self:isEntReadyForSprite(petEnt) then
			return petEnt
		end

		if self:isEntReadyForSprite(self) then
			return self
		end

		return nil
	end

	if self:isEntReadyForSprite(self) then
		return self
	end

	return nil
end

function ClientEggModeComponent:reconcileSpriteMaster()
	if not self.followSprite then
		return
	end

	local targetEnt = self:getDesiredSpriteMasterEnt()

	if not targetEnt then
		return
	end

	if self.followSprite.masterActorId ~= targetEnt.actorId then
		self.followSprite:changeMaster(targetEnt.actorId)
	end
end

function ClientEggModeComponent:ensureSpriteMasterReconcile()
	if self.spriteMasterReconcileTimer then
		return
	end

	self.spriteMasterReconcileTimer = self:addRepeatTimer(SPRITE_MASTER_RECONCILE_INTERVAL, function()
		if not self.followSprite then
			self:cancelSpriteMasterReconcile()

			return
		end

		self:reconcileSpriteMaster()
	end)
end

function ClientEggModeComponent:cancelSpriteMasterReconcile()
	if self.spriteMasterReconcileTimer then
		self:removeTimer(self.spriteMasterReconcileTimer)

		self.spriteMasterReconcileTimer = nil
	end
end

function ClientEggModeComponent:EVENT_OnActiveChange(active)
	if not self.followSprite then
		return
	end

	if self:isControllingPet() then
		return
	end

	self.followSprite:setActive(ClientConst.MODEL_VISIBLE_KEY.ROBEGG_SPRITE, active)
end

function ClientEggModeComponent:switchToEgg(needAnim)
	local eggEnt = self:getCurControllingEgg()

	if not eggEnt then
		self:calcAndRefreshModelScale(true)
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.EGG_MODE, false)

		return
	end

	if needAnim and self.isModelLoaded and pg.pawn:checkCanChangeModelBeforeInteract() then
		self:playPlayerToEggAnim(eggEnt)
	else
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.EGG_MODE, false)

		if self.isMainPlayer and eggEnt.eModel then
			eggEnt:addEModelComponent(Const.COMPONENT_PHYSIC_CONTROLLER)
			eggEnt.eModel:SetupController(Const.COMPONENT_PHYSIC_CONTROLLER, self.eModel, 0)
		end
	end

	self:calcAndRefreshModelScale(true)

	if self.followSprite then
		self.followSprite:setActive(ClientConst.MODEL_VISIBLE_KEY.ROBEGG_SPRITE, false)
	end

	if self.isMainPlayer then
		pg.game.camera:setTargetPlayer(eggEnt, 0)
		facade:SendMessageCommand(MessageName.ON_CONTROL_ENT, {
			targetEnt = eggEnt
		})
		self:onControlEggStateChange()

		if self:EGG_BE_CARRIED_ST() then
			local carriedEnt = pg.getEntity(eggEnt.moveUser)

			self.eggStruggleNeedButton = carriedEnt and self:isEggCarrierTeammate(carriedEnt.actorId) or false
		end
	end
end

function ClientEggModeComponent:recoverToPlayer(eggEntId)
	self:setActive(ClientConst.MODEL_VISIBLE_KEY.EGG_MODE, true)

	if self.petSwitchAnim then
		self.petSwitchAnim:stop()
	end

	if self.isMainPlayer and self.characterState == CharacterStateConst.REVIVE then
		AnimationUtils.playAnimationState(self, CharacterStateConst.IDLE)
	end

	self:switchToPlayer()
	self:calcAndRefreshModelScale(true)

	if self.followSprite then
		self.followSprite:setActive(ClientConst.MODEL_VISIBLE_KEY.ROBEGG_SPRITE, true)
	end

	if self.isMainPlayer then
		self:onControlledEggBeDropped()

		local eggEnt = pg.getEntity(eggEntId)

		if eggEnt and eggEnt.eModel then
			eggEnt:delEModelComponent(Const.COMPONENT_PHYSIC_CONTROLLER)
		end

		pg.game.camera:setTargetPlayer(self, 0)
		facade:SendMessageCommand(MessageName.ON_CONTROL_ENT, {})
		self:onControlEggStateChange()
	end
end

function ClientEggModeComponent:onControlEggStateChange()
	local isControllingEgg = self:isControllingEgg()

	pg.game:setModuleEnable("EggMode", ClientConst.ModuleKey.NormalAttack, not isControllingEgg)
	pg.game:setModuleEnable("EggMode", ClientConst.ModuleKey.Skill, not isControllingEgg)
	pg.game:setModuleEnable("EggMode", ClientConst.ModuleKey.PetList, not isControllingEgg)
	pg.game:setModuleEnable("EggMode", ClientConst.ModuleKey.BallAndItem, not isControllingEgg)
	pg.game.camera:refreshTargetPlayer()
	pg.global.effectMgr:EnableAreaDithering(not isControllingEgg)
end

function ClientEggModeComponent:isControllingEgg()
	return ToBool(self.controlEggId)
end

function ClientEggModeComponent:getCurControllingEgg()
	return pg.getEntity(self.controlEggId)
end

function ClientEggModeComponent:checkEggModeDashCD()
	local now = self:getGameTime()

	return self.eggModeDashCD == nil or now >= self.eggModeDashCD
end

function ClientEggModeComponent:setEggModeDashCD()
	local cd = SysConfigData.EGG_MODE_DASH_CD or 3

	self.eggModeDashCD = self:getGameTime() + cd
end

function ClientEggModeComponent:getEggModeDashRemainCD()
	if self.eggModeDashCD == nil then
		return 0
	end

	local now = self:getGameTime()

	return math.max(self.eggModeDashCD - now, 0)
end

function ClientEggModeComponent:isDeformToEggMan(templateId)
	return self:isDeformToPuppet(templateId) and self.deformContext.isEggManMode
end

function ClientEggModeComponent:onControlledEggBeCarried(carrierActorId)
	if self ~= pg.me or not self:isControllingEgg() then
		return
	end

	self.eggCarrierActorId = carrierActorId

	if self:isEggCarrierTeammate(carrierActorId) then
		self.eggStruggleNeedButton = true
	else
		self:startEggStruggleQte()
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_STRUGGLE_STATE_CHANGED)
end

function ClientEggModeComponent:onControlledEggBeDropped()
	if self ~= pg.me then
		return
	end

	self.eggCarrierActorId = nil

	self:stopEggStruggleQte()
	self:exitEggCarriedCamera()

	if self.eggStruggleNeedButton then
		self.eggStruggleNeedButton = false
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_STRUGGLE_STATE_CHANGED)
end

function ClientEggModeComponent:isEggCarrierTeammate(carrierActorId)
	local carrier = carrierActorId and pg.getEntityByActorId(carrierActorId)

	if not carrier or not carrier.uid then
		return false
	end

	if self.grabEgg_isTeammate then
		return self:grabEgg_isTeammate(carrier.uid)
	end

	return false
end

function ClientEggModeComponent:isEggStruggleButtonNeeded()
	return ToBool(self.eggStruggleNeedButton)
end

function ClientEggModeComponent:startEggStruggleQte(skipDelay)
	self:clearStruggleQteTimer()

	local function internalQteFunc()
		pg.game.qte:startQte(self.actorId, Const.ROB_EGG_STRUGGLE_QTE_GROUP_ID, {
			triggerCallback = CallbackHandler(self, "eggModeStruggleQteCallback")
		})
		self:clearStruggleQteTimer()

		self.struggleQteTimer = self:addRepeatTimer(7, function()
			pg.game.qte:startQte(self.actorId, Const.ROB_EGG_STRUGGLE_QTE_GROUP_ID, {
				triggerCallback = CallbackHandler(self, "eggModeStruggleQteCallback")
			})
		end)
	end

	if skipDelay then
		internalQteFunc()
	else
		self.delayStruggleQteTimer = self:addTimer(SysConfigData.QTE_EGG_STRUGGLE_DELAY or 3, internalQteFunc)
	end
end

function ClientEggModeComponent:stopEggStruggleQte()
	self:clearStruggleQteTimer()
	pg.game.qte:stopQte(self.actorId, Const.ROB_EGG_STRUGGLE_QTE_GROUP_ID)
end

function ClientEggModeComponent:onClickEggStruggleButton()
	if not self:isControllingEgg() then
		return
	end

	self.eggStruggleNeedButton = false

	facade:SendMessageCommand(MessageName.GRAB_EGG_STRUGGLE_STATE_CHANGED)
	self:startEggStruggleQte(true)
end

function ClientEggModeComponent:enterEggCarriedCamera()
	local playerCamera = pg.game.camera and pg.game.camera.playerCameraMode

	if not playerCamera then
		return
	end

	local eggEnt = self:getCurControllingEgg()
	local targetActorId = eggEnt and eggEnt.actorId or self.actorId
	local followTransform = CSEntityManager:GetPositionAgentByActorId(targetActorId)

	playerCamera:enableEggCarriedCameraMode(true, followTransform)
end

function ClientEggModeComponent:exitEggCarriedCamera()
	local playerCamera = pg.game.camera and pg.game.camera.playerCameraMode

	if not playerCamera then
		return
	end

	playerCamera:enableEggCarriedCameraMode(false)
end

function ClientEggModeComponent:clearStruggleQteTimer()
	if self.delayStruggleQteTimer ~= nil then
		self:removeTimer(self.delayStruggleQteTimer)

		self.delayStruggleQteTimer = nil
	end

	if self.struggleQteTimer ~= nil then
		self:removeTimer(self.struggleQteTimer)

		self.struggleQteTimer = nil
	end
end

function ClientEggModeComponent:eggModeStruggleQteCallback(eventName, info)
	if eventName == "qtePartGood" then
		self:serverMsgNoGC("RPC_CS_EscapeCarryEgg")
		self:clearStruggleQteTimer()
	end
end

function ClientEggModeComponent:tryDeformToEggMan(templateId)
	local eggManData = PuppetData[templateId]

	if not eggManData then
		return
	end

	self:deformTo(eggManData, {
		isPuppet = true,
		isEggManMode = true,
		templateId = templateId
	})

	if self.eggManProactive and Utils.checkIsAuthorityMaster(self) then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			actionPrototypeId = 10012,
			interactionType = InteractionConst.INTERACTION_TYPE_LEAVE_EGG_MAN_MODE,
			interactFunc = function()
				self:requestLeaveEggManMode()
			end
		})
	end
end

function ClientEggModeComponent:returnNormalFromEggMan(templateId)
	if self:isDeformToEggMan(templateId) then
		self:deformTo(nil)
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			actionPrototypeId = 10012,
			interactionType = InteractionConst.INTERACTION_TYPE_LEAVE_EGG_MAN_MODE,
			interactFunc = function()
				self:requestLeaveEggManMode()
			end
		})
	end
end

function ClientEggModeComponent:requestLeaveEggManMode()
	if not Utils.checkIsAuthorityMaster(self) then
		return
	end

	self:serverMsgNoGC("RPC_CS_RequestLeaveEggManMode")
end

function ClientEggModeComponent:onEggManTemplateIdChange(ov, nv)
	if nv == 0 then
		self:returnNormalFromEggMan(ov)
	else
		self:tryDeformToEggMan(nv)
	end
end

function ClientEggModeComponent:onControlEggIdChange(ov, nv)
	if ToBool(nv) then
		self:switchToEgg(not self.forceControlEgg)
	else
		self:recoverToPlayer(ov)
	end

	if pg.game and pg.game.map and pg.game.map.refreshAllyMarks then
		pg.game.map:refreshAllyMarks()
	end

	if self.onRobEggControlMsg then
		self:onRobEggControlMsg()
	end
end

function ClientEggModeComponent:onCurHighGrassIdChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onCurHighGrassIdChange", old, new)
	end

	local visible = new == 0 or new == pg.me.curHighGrassId

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.IN_HIGH_GRASS, visible)
end

return ClientEggModeComponent
