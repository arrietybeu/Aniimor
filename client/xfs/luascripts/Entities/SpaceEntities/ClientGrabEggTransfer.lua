-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientGrabEggTransfer.lua

local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local Bitset = require("Common.Bitset")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local PuppetData = require("Data.puppet_data")
local NpcAvatarData = require("Data.npc_avatar_data")
local InteractionConst = require("Common.Const.InteractionConst")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local InteractData = require("Data.interact_data")
local SysConfigData = require("Data.sys_config_data")
local EffectConst = require("Const.EffectConst")
local ClientGrabEggTransfer = class.Class("ClientGrabEggTransfer", ClientPawnEntity)
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientInanimateNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInanimateNpcInteractComponent")
local ClientGrabEggTransferComponents = {
	ClientAuthorityComponent,
	ClientTrapEventComponent,
	ClientTopLogoComponent,
	ClientInanimateNpcInteractComponent
}

if EnableBotTest then
	ClientGrabEggTransferComponents = {
		ClientAuthorityComponent,
		ClientInanimateNpcInteractComponent
	}
end

class.AddComponents(ClientGrabEggTransfer, ClientGrabEggTransferComponents)

function ClientGrabEggTransfer:ctor(entityId)
	ClientGrabEggTransfer.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
	self.isGrabEggTransfer = true
end

function ClientGrabEggTransfer:init(bdict)
	ClientGrabEggTransfer.super.init(self, bdict)

	self.trapEventId = bdict.trapEventId

	local pdd = PuppetData[self.templateId] or {}

	self.forbiddenTopLogo = pdd.forbidTopLogo or false
	self.spriteIdAfterCatch = pdd.spriteIdAfterCatch
	self.useHitBox = false
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.isWild = pdd.isWild and pdd.isWild > 0
	self.topLogoType = ClientConst.TopLogoType.EggTransmitter
	self.effs = pdd.effs
	self.ownerSpawnerId = bdict.spawnerId
	self.entityCanMove = false

	return true
end

function ClientGrabEggTransfer:initializeComponents()
	ClientGrabEggTransfer.super.initializeComponents(self)

	if self.eModel == nil then
		return
	end

	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
end

function ClientGrabEggTransfer:postInitializeComponents()
	ClientGrabEggTransfer.super.postInitializeComponents(self)
end

function ClientGrabEggTransfer:start()
	ClientGrabEggTransfer.super.start(self)

	self.bornPosition = self:transferBornPosition()
end

function ClientGrabEggTransfer:onEnterScene()
	ClientGrabEggTransfer.super.onEnterScene(self)
end

function ClientGrabEggTransfer:transferBornPosition()
	return Vector3(self.bornPosition_x, self.bornPosition_y, self.bornPosition_z)
end

function ClientGrabEggTransfer:refreshAppearance(forceRefreshPlayable)
	if EnableBotTest then
		return
	end

	ClientGrabEggTransfer.super.refreshAppearance(self, forceRefreshPlayable)
end

function ClientGrabEggTransfer:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	ClientGrabEggTransfer.super.onRefreshAppearance(self, configData, extraData, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView

	if configData.keepPrefabLayer then
		modelView.keepPrefabLayer = true
	end

	if configData.needWait and not self:modelLoaded() then
		self.waitModelMark = true
		modelView.instPriority = ClientConst.InstantiatePriority.High

		pg.global.scene:markWaitEntity(self.id, true)
	end

	self:refreshEffect()
end

function ClientGrabEggTransfer:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientGrabEggTransfer:getModelExtraData(configData)
	local label = self:getLabel()
	local gender = self:getGender()
	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true)

	if self.spPrefabResID then
		extraInfo.prefabResID = self.spPrefabResID
	end

	return extraInfo
end

function ClientGrabEggTransfer:repr()
	return string.format("ClientGrabEggTransfer(entityId=%s, uid=%d)", self.id, self.uid or 0)
end

function ClientGrabEggTransfer:getTemplateData()
	return PuppetData[self.templateId] or {}
end

function ClientGrabEggTransfer:checkCanActualInteract(interactId)
	if pg.me and pg.me:CARRY_EGG_ST() and SysConfigData.CarryEggModeInteractWhiteList and not table.contains(SysConfigData.CarryEggModeInteractWhiteList, interactId) then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return false
	end

	return true
end

function ClientGrabEggTransfer:queryModelVisible()
	if Bitset.any(ClientConst.PUPPET_VISIBLE_FLAG) then
		return true, false
	end

	return ClientGrabEggTransfer.super.queryModelVisible(self)
end

function ClientGrabEggTransfer:refreshEffect()
	local state = pg.me:grabEgg_transportState(self.staticId)

	if state ~= Const.ROB_EGG_TRANSPORT_STATE.NORMAL and self._transportEffectState ~= state then
		self:playEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_LOOP)
		self:playEffect(EffectConst.TRANSPORT_EFFECT.TOP_LOOP)

		self._transportEffectState = state
	end
end

function ClientGrabEggTransfer:tryPlayTransportEffect(state)
	if state == self._transportEffectState then
		return
	end

	self._transportEffectState = state

	if state == Const.ROB_EGG_TRANSPORT_STATE.TRANSPORTING or state == Const.ROB_EGG_TRANSPORT_STATE.INVADING then
		if state == Const.ROB_EGG_TRANSPORT_STATE.TRANSPORTING then
			local extraInfo = {
				endCallback = function()
					if self._transportEffectState == Const.ROB_EGG_TRANSPORT_STATE.NORMAL then
						return
					end

					self:playEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_LOOP)
					self:playEffect(EffectConst.TRANSPORT_EFFECT.TOP_LOOP)
				end
			}

			self:playEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_START, extraInfo)
		else
			self:playEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_LOOP)
			self:playEffect(EffectConst.TRANSPORT_EFFECT.TOP_LOOP)
		end
	elseif state == Const.ROB_EGG_TRANSPORT_STATE.NORMAL then
		self:playEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_END)
		self:playEffect(EffectConst.TRANSPORT_EFFECT.TOP_END)
		self:addTimer(0.04, function()
			self:stopEffect(EffectConst.TRANSPORT_EFFECT.BOTTOM_LOOP, true)
			self:stopEffect(EffectConst.TRANSPORT_EFFECT.TOP_LOOP, true)
		end)
	end
end

function ClientGrabEggTransfer:preDestroy()
	self:playDestroyEffect()
	ClientGrabEggTransfer.super.preDestroy(self)
end

return ClientGrabEggTransfer
