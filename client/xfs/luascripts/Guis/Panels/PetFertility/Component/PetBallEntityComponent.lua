-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetBallEntityComponent.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetBallEntityComponent = Class.LightClass("PetBallEntityComponent", UIComponent)
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientPetBallEntity = require("Entities.SpaceEntities.ClientPetBallEntity")
local ClientPet = require("Entities.SpaceEntities.ClientPet")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AIConst = require("Common.Const.AiConst")

function PetBallEntityComponent:findObjects()
	self.fixedScale = 1.5
	self.petBallPreviewScene = pg.game.uiScene:getScene(UISceneConst.PET_BALL_PREVIEW_SCENE)
	self.pets = {}
	self.curPreviewingPetEntId = nil
	self.selectedPets = {}
	self.curPreviewingPetEntTempHideFlag = false
	self.selectedBreedPets = {}
end

function PetBallEntityComponent:initView()
	return
end

function PetBallEntityComponent:destroy()
	for petId, petEnt in pairs(self.pets) do
		ClientUtils.safeDestroy(petEnt)

		self.pets[petId] = nil
	end

	for petId, petEnt in pairs(self.selectedPets) do
		ClientUtils.safeDestroy(petEnt)

		self.selectedPets[petId] = nil
	end

	self.pets = {}
	self.selectedPets = {}
	self.curPreviewingPetEntId = nil
	self.curPreviewingPetEntTempHideFlag = false

	for petId, petEntTale in pairs(self.selectedBreedPets) do
		if petEntTale.ent then
			ClientUtils.safeDestroy(petEntTale.ent)

			petEntTale.ent = nil
		end

		petEntTale.isMale = nil
		self.selectedBreedPets[petId] = nil
	end

	self.selectedBreedPets = {}
end

function PetBallEntityComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

function PetBallEntityComponent:getOrSetPetVirtualEntity(petId, parentTrans)
	if self.pets[petId] then
		self.pets[petId].eModel:SetTransformParent(parentTrans)
		self.pets[petId]:forceSetPosRot(parentTrans.position, parentTrans.rotation, true)

		return self.pets[petId]
	end

	local petInfo = pg.me.pets[petId]
	local entityContent = {
		position = parentTrans.position,
		rotation = parentTrans.rotation,
		virtualTemplateClassName = ClientPet.typeName,
		virtualTemplateActorType = Const.ACTOR_TYPE_PET,
		virtualModelLayer = ClientConst.LayerDefine.LAYER_UI_SCENE,
		virtualTemplateId = petInfo.templateId,
		bornPosition = parentTrans.position,
		curModelScale = self.fixedScale,
		baseAttr = {},
		abilityMap = {},
		label = petInfo.label,
		individuationIds = petInfo.individuationIds
	}

	self.pets[petId] = ClientVirtualEntityUtils.createPetVirtualEntityByPetId(petId, ClientPetBallEntity, entityContent)

	self.pets[petId].eModel:SetTransformParent(parentTrans)
	self.pets[petId].eModel:SetGameObjectName(string.format("VirtualSimpleEntityPet_%s", petId))
	self.pets[petId].eModel:SetEnablePosSync(true)
	self.pets[petId]:enterSpace(pg.space)

	return self.pets[petId]
end

function PetBallEntityComponent:setPetEntityVisible(petId, visible)
	if not self.pets[petId] then
		return
	end

	self.pets[petId].eModel:SetModelVisible(visible)
end

function PetBallEntityComponent:showSpecificPetEnt(petId)
	if not self.pets[petId] then
		return
	end

	self:hideAllPetEnt()
	self:setPetEntityVisible(petId, true)

	self.curPreviewingPetEntId = petId
end

function PetBallEntityComponent:hideAllPetEnt()
	for id, ent in pairs(self.pets) do
		self:stopAI(ent)
		self:setPetEntityVisible(id, false)
	end
end

function PetBallEntityComponent:onMainBallPetEntChanged(petId)
	local virtualEnt = self:getOrSetPetVirtualEntity(petId, self.petBallPreviewScene.parmonGeneratedPosTransform)

	self:showSpecificPetEnt(petId)
	self:resumeAI(virtualEnt)
end

function PetBallEntityComponent:showAroundPetEnts(curBallIndex)
	self:hideAllPetEnt()

	local maxCount = self.model:getPetBallCount()

	for i = 1, 4 do
		local index

		if curBallIndex - i < 1 then
			index = maxCount + (curBallIndex - i)
		else
			index = curBallIndex - i
		end

		local currentBallContainsPet = self.model:isBallContainsPet(index)

		if currentBallContainsPet then
			local petInfo = self.model:getPetBallPetInfo(index)
			local virtualEnt = self:getOrSetPetVirtualEntity(petInfo.id, self.petBallPreviewScene.leftOrderTrans[i])

			self:setPetEntityVisible(petInfo.id, true)
		end
	end

	local index

	index = maxCount < curBallIndex + 1 and 1 or curBallIndex + 1

	local currentBallContainsPet = self.model:isBallContainsPet(index)

	if currentBallContainsPet then
		local petInfo = self.model:getPetBallPetInfo(index)
		local virtualEnt = self:getOrSetPetVirtualEntity(petInfo.id, self.petBallPreviewScene.rightOrderTrans[1])

		self:setPetEntityVisible(petInfo.id, true)
	end

	currentBallContainsPet = self.model:isBallContainsPet(curBallIndex)

	if currentBallContainsPet then
		local petInfo = self.model:getPetBallPetInfo(curBallIndex)
		local virtualEnt = self:getOrSetPetVirtualEntity(petInfo.id, self.petBallPreviewScene.parmonGeneratedPosTransform)

		self:setPetEntityVisible(petInfo.id, true)
	end
end

function PetBallEntityComponent:stopAI(ent)
	ent:pauseBt(AIConst.PauseBtReason.InPetBall)

	if ent.setIsKinematic then
		ent:setIsKinematic(false, ClientConst.IsKinematicKey.PetBall)
	end

	if ent.SetKccEnable then
		ent:SetKccEnable(false, Const.KccDisableReason.PetBall)
	end
end

function PetBallEntityComponent:resumeAI(ent)
	ent:resumeBt(AIConst.PauseBtReason.InPetBall)

	if ent.setIsKinematic then
		ent:setIsKinematic(true, ClientConst.IsKinematicKey.PetBall)
	end

	if ent.SetKccEnable then
		ent:SetKccEnable(true, Const.KccDisableReason.PetBall)
	end
end

function PetBallEntityComponent:refreshSelectedPetEnt(petId)
	for _, petEnt in pairs(self.selectedPets) do
		petEnt.eModel:SetModelVisible(false)
	end

	local previewingPet = self.ctrl:getCurPreviewingPetEnt()

	if petId == self.curPreviewingPetEntId then
		if self.curPreviewingPetEntTempHideFlag and previewingPet then
			previewingPet.eModel:SetModelVisible(true)
			previewingPet:resumeBt(AIConst.PauseBtReason.InPetBall)

			self.curPreviewingPetEntTempHideFlag = false
		end

		return
	end

	if previewingPet then
		previewingPet:pauseBt(AIConst.PauseBtReason.InPetBall)
		previewingPet.eModel:SetModelVisible(false)

		self.curPreviewingPetEntTempHideFlag = true
	end

	if not petId then
		return
	end

	if self.selectedPets[petId] then
		self.selectedPets[petId].eModel:SetModelVisible(true)
	else
		self.selectedPets[petId] = ClientVirtualEntityUtils.createPetVirtualEntityByPetId(petId)

		self.selectedPets[petId].eModel:SetTransformParent(self.petBallPreviewScene.parmonGeneratedPosTransform)
		self.selectedPets[petId].eModel:SetTransformLocalPosition()

		self.selectedPets[petId].eModel.modelRoot.transform.localScale = Vector3(self.fixedScale, self.fixedScale, self.fixedScale)

		self.selectedPets[petId].eModel:SetGameObjectName(string.format("VirtualSimpleEntityPetSelected_%s", petId))
	end
end

function PetBallEntityComponent:leavePetSelection()
	for _, petEnt in pairs(self.selectedPets) do
		petEnt.eModel:SetModelVisible(false)
	end

	local previewingPet = self.ctrl:getCurPreviewingPetEnt()

	if previewingPet then
		previewingPet.eModel:SetModelVisible(true)
		previewingPet:resumeBt(AIConst.PauseBtReason.InPetBall)

		self.curPreviewingPetEntTempHideFlag = false
	end
end

function PetBallEntityComponent:refreshBreedSceneSelectedPetEnt(petId, isMale, allClear)
	if allClear then
		for _, petEntTable in pairs(self.selectedBreedPets) do
			if petEntTable.ent then
				petEntTable.ent.eModel:SetModelVisible(false)
			end
		end

		return
	end

	for _, petEntTable in pairs(self.selectedBreedPets) do
		if petEntTable.isMale == isMale then
			petEntTable.ent.eModel:SetModelVisible(false)
		end
	end

	if petId then
		if self.selectedBreedPets[petId] then
			if self.selectedBreedPets[petId].ent then
				self.selectedBreedPets[petId].ent.eModel:SetModelVisible(true)
			end
		else
			self.selectedBreedPets[petId] = {
				ent = ClientVirtualEntityUtils.createPetVirtualEntityByPetId(petId),
				isMale = isMale
			}

			local targetPos, targetRot, parentTransform

			if isMale then
				parentTransform = self.petBallPreviewScene.breedSelectedMalePosTransform
				targetPos = self.petBallPreviewScene.breedSelectedMalePosTransform.position
				targetRot = self.petBallPreviewScene.breedSelectedMalePosTransform.rotation
			else
				parentTransform = self.petBallPreviewScene.breedSelectedFemalePosTransform
				targetPos = self.petBallPreviewScene.breedSelectedFemalePosTransform.position
				targetRot = self.petBallPreviewScene.breedSelectedFemalePosTransform.rotation
			end

			local eModel = self.selectedBreedPets[petId].ent.eModel

			eModel:SetTransformParent(parentTransform)
			eModel:SetTransformPosition(targetPos.x, targetPos.y, targetPos.z)
			eModel:SetTransformRotation(targetRot.x, targetRot.y, targetRot.z, targetRot.w)
			eModel:SetGameObjectName(string.format("VirtualSimpleEntityBreedPetSelected_%s_%s", petId, isMale and "Male" or "Female"))
		end
	end
end

return PetBallEntityComponent
