-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPhysicsComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local RigidbodyData = require("Data.rigidbody_data")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local SysConfigData = require("Data.sys_config_data")
local Vector3 = Vector3
local Quaternion = Quaternion
local bit = bit
local ClientPhysicsComponent = Class.Component("ClientPhysicsComponent")

function ClientPhysicsComponent:ctor()
	self.tempVector3 = Vector3()
	self.isKinematicFlag = 0
end

function ClientPhysicsComponent:EVENT_AddEComponent()
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
	self.eModel:SetMass(Const.COMPONENT_IDX_PHYSX, self.bodyMass or 1)

	if self.bodyDrag then
		self.eModel:SetDrag(Const.COMPONENT_IDX_PHYSX, self.bodyDrag)
	end

	if self.actorId then
		self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, 0)
	end

	if not Utils.isRobEggSpaceEgg(self) then
		self:refreshPhysxInternal()
	end
end

function ClientPhysicsComponent:EVENT_EnterScene()
	self:refreshPhysicsState()

	if Utils.isHomePet(self) then
		if self.space and self.space.sceneId and Utils.isHomelandBySceneId(self.space.sceneId) then
			self.isHomePetInHomeland = true

			self:refreshHomeLandNoCollision()
		end
	elseif self:getConfigData().IgnoreCollision == 1 then
		self:setNoCollision()
	elseif Utils.isPet(self) and self.space and self.space:isPvpEnv() then
		self:setPvPCollision()
	end

	if Utils.isRobEggSpaceEgg(self) then
		self:refreshPhysxInternal()
	end
end

function ClientPhysicsComponent:start()
	self:refreshAuthorityIsKinematic()
	self:refreshDynamicPosSync()

	if self.aoiRange and self.aoiRange > 12800 then
		pg.game.ecs:registerFarawayPhysics(self)
	end
end

function ClientPhysicsComponent:EVENT_RefreshPhysx()
	self:refreshPhysxInternal()
end

function ClientPhysicsComponent:refreshPhysxInternal()
	if Utils.isCreation(self) then
		self:genCreationCollider()
	elseif Utils.isRobEggSpaceEgg(self) then
		self:genRobEggCollider()
	else
		local entityConfigData = self:getConfigData()
		local rigidbodyId = entityConfigData.rigidbody

		if not rigidbodyId then
			return
		end

		local rigidbodyData = RigidbodyData[rigidbodyId]

		if not rigidbodyData then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error(string.format("[Physics]: rigidbodyData not found, actorId %d, templateId %s, rigidbody id %s", self.actorId, tostring(self.templateId), tostring(rigidbodyId)))
			end

			return
		end

		self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
		self.eModel:SetTag(Const.COMPONENT_IDX_PHYSX, Const.TAG_ACTOR, self.actorId, self.actorPartIdx)
		self:refreshPhysxData(self.characterState)
	end
end

function ClientPhysicsComponent:refreshPhysxDataOnAnimation(characterState, adjustRootPos, preserveRootXZ)
	local radius, height, centerX, centerY, centerZ, isTrigger = self:getPhysxDataByState(characterState)

	if radius then
		if adjustRootPos then
			Vector3.enableCreateFromCache()

			local px, py, pz = self.eModel:GetPositionAgentPosEx()
			local rx, ry, rz, rw = self.eModel:GetPositionAgentRotationEx()
			local position = Vector3.New(px, py, pz)
			local rotation = Quaternion(rx, ry, rz, rw)
			local oldCenterX, oldCenterY, oldCenterZ = self.eModel:GetArgsV3(Const.COMPONENT_IDX_PHYSX, 2, 3, 4)
			local newCenter = Vector3.New(centerX, centerY, centerZ)
			local oldCenter = Vector3.New(oldCenterX, oldCenterY, oldCenterZ)

			Vector3.SubByCache(oldCenter, newCenter, self.tempVector3)

			local offset = Quaternion.MulVec3(rotation, self.tempVector3)

			Vector3.AddByCache(position, offset, self.tempVector3)

			if preserveRootXZ then
				self.tempVector3.x = position.x
				self.tempVector3.z = position.z
			end

			Vector3.disableCreateFromCache()
		end

		Vector3.enableCreateFromCache()
		self.eModel:GenCapsule(Const.COMPONENT_IDX_PHYSX, radius, height, Vector3.New(centerX, centerY, centerZ), isTrigger, false, true)
		Vector3.disableCreateFromCache()

		if adjustRootPos then
			EModelUtils.setAgentPosition(self, self.tempVector3)
			self:refreshFollowUI(characterState, height)
		end
	end
end

function ClientPhysicsComponent:refreshPhysxData(characterState)
	local radius, height, centerX, centerY, centerZ, isTrigger = self:getPhysxDataByState(characterState)

	if radius then
		Vector3.Set(self.tempVector3, centerX, centerY, centerZ)
		self.eModel:GenCapsule(Const.COMPONENT_IDX_PHYSX, radius, height, self.tempVector3, isTrigger, false, true)

		local configData = self:getConfigData()

		self.eModel.stepHeightUp = self.getStepHeightUp and self:getStepHeightUp() or configData.stepHeightUp or 0

		if self.refreshClimbAcrossConfig then
			self:refreshClimbAcrossConfig()
		end
	end
end

function ClientPhysicsComponent:refreshCapsuleScale(scale, characterState)
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	self.eModel:SetCapsuleScale(Const.COMPONENT_IDX_PHYSX, scale)

	if (Utils.isPuppet(self) and not self.isServerAI or self.isMainPlayer or self.isMainPet) and not self.isDummyClone then
		local state = characterState or self.characterState or CharacterStateConst.None
		local radius, height, centerX, centerY, centerZ, isTrigger = self:getPhysxDataByState(state)

		if not radius or not height then
			return
		end

		radius = radius * scale
		height = height * scale

		local minR = SysConfigData.enemyExtraCollideRadiusMin
		local bR = radius + minR
		local bH = height + minR * 2

		self.eModel:GenCombatCollider(Const.COMPONENT_IDX_PHYSX, bR, bH, centerY)
	end
end

function ClientPhysicsComponent:getPhysxData()
	local entityConfigData = self:getConfigData()
	local rigidbodyId = entityConfigData.rigidbody

	if not rigidbodyId then
		return
	end

	return RigidbodyData[rigidbodyId]
end

function ClientPhysicsComponent:getPhysxDataByState(characterState)
	local entityConfigData = self:getConfigData()
	local rigidbodyId

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.CLIMBING) and characterState ~= CharacterStateConst.CLIMBOFF then
		rigidbodyId = entityConfigData.rigidbodyForClimb
	elseif (characterState == CharacterStateConst.DEAD or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.DEAD)) and entityConfigData.rigidbodyForDead then
		rigidbodyId = entityConfigData.rigidbodyForDead
	else
		rigidbodyId = entityConfigData.rigidbody
	end

	if not rigidbodyId then
		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PHYSX) then
		return
	end

	local centerX, centerY, centerZ

	if rigidbodyData.center == nil then
		centerX, centerY, centerZ = 0, rigidbodyData.height * 0.5, 0
	else
		local rCenter = rigidbodyData.center

		centerX, centerY, centerZ = rCenter[1], rCenter[2], rCenter[3]
	end

	local radius = ToBool(rigidbodyData.radius) and rigidbodyData.radius or 0.1
	local height = ToBool(rigidbodyData.height) and rigidbodyData.height or 0.1
	local isTrigger = Utils.isHomePet(self) or ToBool(rigidbodyData.trigger)

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SNEAK) or characterState == CharacterStateConst.SNEAKIN then
		return 0.14, 0.3, 0, 0.15, 0, isTrigger
	end

	return radius, height, centerX, centerY, centerZ, isTrigger
end

function ClientPhysicsComponent:refreshFollowUI(characterState, height)
	local _, _, _, centerY = self:getPhysxDataByState(characterState)

	if centerY == nil then
		return
	end

	if self.topLogoData then
		self.topLogoData.agentToCapsuleCenterY = centerY
	end

	if self ~= pg.pawn then
		return
	end

	if self.refreshTopLogoHeight then
		self:refreshTopLogoHeight()
	end

	local specialEnergyBar = pg.global and pg.global.ui and pg.global.ui.specialEnergyBar

	if specialEnergyBar and specialEnergyBar.refreshFollowAnchorOffset then
		specialEnergyBar:refreshFollowAnchorOffset()
	end
end

function ClientPhysicsComponent:checkEnableCombatCollision()
	if self.scrollWithInputData ~= nil then
		return false
	end

	return self:isInCombat()
end

function ClientPhysicsComponent:EVENT_OnLifterIdChanged()
	self:refreshPhysicsState()
end

function ClientPhysicsComponent:EVENT_OnModelRefreshed()
	self:refreshPhysicsState()
end

function ClientPhysicsComponent:EVENT_onModelLoaded()
	self:refreshPhysicsState()
end

function ClientPhysicsComponent:EVENT_LeaveScene()
	self:refreshPhysicsState()
end

function ClientPhysicsComponent:EVENT_OnAuthorityChanged()
	self:refreshAuthorityIsKinematic()
end

function ClientPhysicsComponent:refreshAuthorityIsKinematic()
	if not self.isClientEnt and self.authority ~= Const.AUTHORITY_MASTER then
		self:setIsKinematic(true, ClientConst.IsKinematicKey.Auth)

		return
	end

	self:setIsKinematic(false, ClientConst.IsKinematicKey.Auth)
end

function ClientPhysicsComponent:refreshPhysicsState()
	if not self.eModel then
		return
	end

	local enableAbilityImpulse = self:getEnableAbilityImpulse()

	self:setEnableImpulseDamage(enableAbilityImpulse)

	local isKinematic = self:getIsKinematic()

	if Utils.isCatchBall(self) and self.fired and isKinematic then
		return
	end

	self.eModel:SetIsKinematic(isKinematic)

	if not isKinematic then
		local rigidbody = self.eModel.rigidbody

		if rigidbody and not Utils.isCatchBall(self) then
			local x, y, z = 0, 0, 0

			if self.aoi then
				x, y, z = self.aoi:getVelocity()
			end

			Vector3.Set(self.tempVector3, x, y, z)

			rigidbody.velocity = self.tempVector3
		end
	end
end

function ClientPhysicsComponent:setEnableImpulseDamage(enable)
	if not self.eModel then
		return
	end

	self.eModel:SetEnableImpulseDamage(enable)
end

function ClientPhysicsComponent:getEnableAbilityImpulse()
	local entityConfigData = self:getConfigData()

	if entityConfigData.forbidImpulseDamage then
		return false
	end

	return true
end

function ClientPhysicsComponent:getIsKinematic()
	if not self.isInScene or not self.isModelLoaded then
		return true
	end

	if self:checkIsConfigKinematic() then
		return true
	end

	return false
end

function ClientPhysicsComponent:checkIsConfigKinematic()
	if self.isKinematicFlag > 0 then
		return true
	end

	if self.serverPhysicsInfo ~= nil then
		if self.serverPhysicsInfo.rigidBodyState == Const.RigidBodyState.Kinematic then
			return true
		elseif self.serverPhysicsInfo.rigidBodyState == Const.RigidBodyState.NoneKinematic then
			return false
		end
	end

	return self:isConfigKinematic()
end

function ClientPhysicsComponent:onServerPhysicsInfoRigidBodyStateChanged()
	self:refreshDynamicPosSync()
	self:refreshPhysicsState()
end

function ClientPhysicsComponent:refreshDynamicPosSync()
	if not self.setTempPosSync then
		return
	end

	local state = self.serverPhysicsInfo and self.serverPhysicsInfo.rigidBodyState

	if state == Const.RigidBodyState.NoneKinematic then
		self:setTempPosSync(true, Const.TEMP_POS_SYNC_REASON.RIGIDBODY_NONE_KINEMATIC)
	else
		self:clearTempPosSync(Const.TEMP_POS_SYNC_REASON.RIGIDBODY_NONE_KINEMATIC)
	end
end

function ClientPhysicsComponent:setIsKinematic(isKinematic, flag)
	if isKinematic then
		self.isKinematicFlag = bit.bor(self.isKinematicFlag, flag)
	else
		self.isKinematicFlag = bit.band(self.isKinematicFlag, bit.bnot(flag))
	end

	self:refreshPhysicsState()
end

function ClientPhysicsComponent:setNoCollision()
	self.eModel:SetNoCollision(Const.COMPONENT_MOTION)
end

function ClientPhysicsComponent:setDittoCollision()
	self.eModel:SetDittoCollision(Const.COMPONENT_MOTION)
end

function ClientPhysicsComponent:onHomeEventChanged()
	if not self.isHomePetInHomeland then
		return
	end

	if self.homeEventReturnCollisionOn and Utils.checkHomePetStateValid(self.petInfo, pg.space) then
		ClientPhysicsComponent.startHomeEventReturnCollision(self)

		return
	end

	self:refreshDisableHomeNoCollision()
end

function ClientPhysicsComponent:startHomeEventReturnCollision()
	if not self.isHomePetInHomeland then
		return
	end

	if self.homeEventReturnCollisionTimer then
		self:removeTimer(self.homeEventReturnCollisionTimer)

		self.homeEventReturnCollisionTimer = nil
	end

	self.homeEventReturnCollisionOn = true

	self:refreshDisableHomeNoCollision()

	if Utils.checkHomePetStateValid(self.petInfo, pg.space) then
		self.homeEventReturnCollisionTimer = self:addTimer(ClientConst.HOME_PET_EVENT_RETURN_COLLISION_DURATION, function()
			self.homeEventReturnCollisionTimer = nil
			self.homeEventReturnCollisionOn = nil

			self:refreshDisableHomeNoCollision()
		end)
	end
end

function ClientPhysicsComponent:on_areaId_changed(ov, nv)
	if not self.isHomePetInHomeland then
		return
	end

	self:refreshDisableHomeNoCollision()
end

function ClientPhysicsComponent:checkDisableHomeNoCollision()
	return self.areaId == Const.HOMELAND_AREA_TYPE.BUILD or not Utils.checkHomePetStateValid(self.petInfo, pg.space) or self.homePetCollisionOn or self.homeEventReturnCollisionOn
end

function ClientPhysicsComponent:isHomePetCollisionOn()
	if not self.isHomePetInHomeland then
		return false
	end

	local ok, GmToolUtils = pcall(require, "Utils.GmToolUtils")

	if ok and GmToolUtils and GmToolUtils.homePetCollisionModeOn == true then
		return true
	end

	return false
end

function ClientPhysicsComponent:refreshDisableHomeNoCollision()
	self.homePetCollisionOn = self:isHomePetCollisionOn()

	local disableCollision = self:checkDisableHomeNoCollision()

	if self.disableHomeNoCollision ~= disableCollision then
		self.disableHomeNoCollision = disableCollision

		self:applyHomeLandNoCollision()
	end
end

function ClientPhysicsComponent:refreshHomeLandNoCollision()
	self.homePetCollisionOn = self:isHomePetCollisionOn()
	self.disableHomeNoCollision = self:checkDisableHomeNoCollision()

	self:applyHomeLandNoCollision()
end

function ClientPhysicsComponent:applyHomeLandNoCollision()
	if not self.isHomePetInHomeland then
		return
	end

	local enableHomeNoCollision = not self.disableHomeNoCollision

	self.eModel:SetHomeLandNoCollision(Const.COMPONENT_MOTION, enableHomeNoCollision)
end

function ClientPhysicsComponent:setPvPCollision()
	self.eModel:SetPVPCollision(Const.COMPONENT_MOTION)
end

function ClientPhysicsComponent:resetCollision()
	self.eModel:ResetCollision(Const.COMPONENT_MOTION)
end

function ClientPhysicsComponent:preDestroy()
	self:setIsKinematic(false, ClientConst.IsKinematicKey.SceneLoading)
end

function ClientPhysicsComponent:destroy()
	if self.homeEventReturnCollisionTimer then
		self:removeTimer(self.homeEventReturnCollisionTimer)

		self.homeEventReturnCollisionTimer = nil
	end

	self.homeEventReturnCollisionOn = nil
end

return ClientPhysicsComponent
