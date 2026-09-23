-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientFollowingPhantomVirtualEntity.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetData = require("Data.pet_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ActorManager = require("Core.Common.ActorManager")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local pg = pg
local IsNil = IsNil
local Vector3 = Vector3
local Quaternion = Quaternion
local FollowingPhantomComponent = CS.FunPlus.WorldX.Entities.Components.FollowingPhantomComponent
local ClientFollowingPhantomVirtualEntity = Class.Class("ClientFollowingPhantomVirtualEntity", ClientSimpleVirtualEntity)

function ClientFollowingPhantomVirtualEntity:ctor(entityId)
	ClientFollowingPhantomVirtualEntity.super.ctor(self, entityId)

	self.isClientEnt = false
end

function ClientFollowingPhantomVirtualEntity:init(dict)
	ClientSimpleVirtualEntity.init(self, dict)

	self.actionData = dict.actionData
	self.petTemplateId = dict.petTemplateId
	self.masterActorId = dict.masterActorId
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()

	ActorManager.addEntity(self.actorId, self)
end

function ClientFollowingPhantomVirtualEntity:start()
	ClientSimpleVirtualEntity.start(self)
	self:refreshVisible()
	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, self.actionData.scale)
end

function ClientFollowingPhantomVirtualEntity:showPhantom()
	return
end

function ClientFollowingPhantomVirtualEntity:hidePhantom()
	return
end

function ClientFollowingPhantomVirtualEntity:getConfigData()
	return PetData[self.petTemplateId] or {}
end

function ClientFollowingPhantomVirtualEntity:refreshVisible()
	self:refreshPhantomVisible()

	local masterEntity = pg.getEntityByActorId(self.masterActorId)

	if not masterEntity then
		return false
	end

	local curCombatPet = masterEntity:getCurPetEntity()

	if IsNil(curCombatPet) or IsNil(curCombatPet.eModel.modelView) then
		return false
	end

	if self.active then
		local followingPhantomCom = FollowingPhantomComponent.GetByActorId(curCombatPet.actorId)

		if not followingPhantomCom then
			self.eModel:SetActive(false)
		else
			followingPhantomCom:AddFollowingPhantom(self.id, self.actionData.offsetHeight, self.actionData.offsetBack, self.actionData.offsetHorizontal, self.actionData.idleState, self.actionData.moveState, curCombatPet.actorCombatAttribute:getWalkSpeed())
			followingPhantomCom:SetData(AbilitySettingGlobalConstData.followingPhantomMinMoveDis, AbilitySettingGlobalConstData.followingPhantomAcceleration, AbilitySettingGlobalConstData.followingPhantomMaxVelocity, AbilitySettingGlobalConstData.followingPhantomTeleportDis, AbilitySettingGlobalConstData.followingPhantomAngleDamp)

			self.followingPhantomCom = followingPhantomCom
		end
	end
end

function ClientFollowingPhantomVirtualEntity:destroy()
	ClientSimpleVirtualEntity.destroy(self)
	ActorManager.removeEntity(self.actorId, self)
end

function ClientFollowingPhantomVirtualEntity:preDestroy()
	local masterEntity = pg.getEntityByActorId(self.masterActorId)

	if not masterEntity then
		ClientSimpleVirtualEntity.preDestroy(self)

		return
	end

	local curCombatPet = masterEntity:getCurPetEntity()

	if curCombatPet and curCombatPet.eModel and NotNil(curCombatPet.eModel.modelView) then
		local followingPhantomCom = FollowingPhantomComponent.GetByActorId(curCombatPet.actorId)

		if followingPhantomCom then
			followingPhantomCom:RemoveFollowPhantom(self.id)
		end
	end

	ClientSimpleVirtualEntity.preDestroy(self)
end

function ClientFollowingPhantomVirtualEntity:refreshPhantomVisible()
	local active = AbilityUtils.getFollowingPhantomVisible(self.masterActorId, self.actionData)

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.FOLLOW_PHANTOM, active)
end

function ClientFollowingPhantomVirtualEntity:refreshAppearance()
	if not self.eModel then
		return
	end

	self:setModelLayer(ClientConst.LayerDefine.LAYER_IGNORE_RAYCAST)

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0, nil, nil, "_Shadow")

	if not string.isNilOrEmpty(self.actionData.prefabResId) then
		extraData.prefabResID = self.actionData.prefabResId
	end

	if not string.startsWith(extraData.prefabResID, "$E_P_Parmon") then
		extraData.prefabResID = extraData.prefabResID:gsub("P_Parmon", "E_P_Parmon")
	end

	if pg.global.resMgr:CheckAssetExist(extraData.prefabResID) then
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	else
		extraData = ClientModelUtils.getModelExtraInfo(configData, 0, nil, nil)

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	end

	modelView:RefreshModels()
	modelView.shaderView:SetMultiPassRenderEnable(false)
end

function ClientFollowingPhantomVirtualEntity:onModelRefreshed()
	ClientFollowingPhantomVirtualEntity.super.onModelRefreshed(self)
	self:refreshPhantomVisible()
end

function ClientFollowingPhantomVirtualEntity:followPhantomLockTarget(targetActorId, duration)
	if not duration then
		return
	end

	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity and NotNil(self.followingPhantomCom) then
		local targetDir = targetEntity:getPosition() - self:getPosition()

		targetDir.y = 0

		if Vector3.SqrMagnitude(targetDir) > 0.1 then
			local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

			EModelUtils.setAgentRotation(self, targetRotation)
		end

		self.followingPhantomCom:StopUpdatePos(duration)
	end
end

function ClientFollowingPhantomVirtualEntity:setPhantomOverrideOffset(offset)
	if NotNil(self.followingPhantomCom) then
		self.followingPhantomCom:SetPhantomOverrideOffset(self.id, offset)
	end
end

function ClientFollowingPhantomVirtualEntity:clearPhantomOverrideOffset()
	if NotNil(self.followingPhantomCom) then
		self.followingPhantomCom:ClearPhantomOverrideOffset(self.id)
	end
end

function ClientFollowingPhantomVirtualEntity:startRotateTo(targetActorId, targetPos, rotateSpeed, time, boneName)
	if self.followingPhantomCom then
		self.followingPhantomCom:StartRotateTo(targetActorId or 0, targetPos or Vector3.constZero, rotateSpeed, time, boneName)
	end
end

return ClientFollowingPhantomVirtualEntity
