-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\AFKShopScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local AFKShopScene = Class.LightClass("AFKShopScene", UISceneBase)
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local Const = require("Common.Const.Const")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetProtoTypeData = require("Data.pet_prototype_data")
local SCENE_ID = {
	Grass = 2,
	Water = 1
}
local PetDetailAmb = {
	AmbGrass = "AMB_UI_PetManualExplore_Grassland",
	AmbBeach = "AMB_UI_PetManualExplore_Beach"
}

function AFKShopScene:onStart(shopClassCfg)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.petRoot = self.objectReference:GetRefValue("petRootTransform")
	self.uICameraCamera = self.objectReference:GetRefValue("uISceneCameraCamera")
	self.ableLookAt = true

	self:showPet(shopClassCfg)
end

function AFKShopScene:showPet(shopClassCfg)
	local templateId = shopClassCfg.pet_res

	if not templateId then
		return
	end

	local petModel = self:createEntity(templateId, ClientSimpleVirtualPet, {
		templateId = templateId
	})

	self.petModel = petModel

	petModel.eModel:SetTransformParent(self.petRoot, true)
	petModel.eModel:SetTransformLocalPosition(shopClassCfg.pet_modelPos[1], shopClassCfg.pet_modelPos[2], shopClassCfg.pet_modelPos[3])

	local localRotation = Quaternion.Euler(shopClassCfg.pet_modelRotation[1], shopClassCfg.pet_modelRotation[2], shopClassCfg.pet_modelRotation[3])

	petModel.eModel:SetTransformLocalRotation(localRotation[1], localRotation[2], localRotation[3], localRotation[4])
	petModel.eModel:SetTransformLocalScale(shopClassCfg.pet_scale, shopClassCfg.pet_scale, shopClassCfg.pet_scale)
	petModel.eModel:AddShadowComp(ClientConst.ShadowPriority.PetResearchDetail)

	local shaderView = petModel.eModel.shaderView

	shaderView:SetOverrideMaterial("")
	shaderView:SetMultiPassRenderEnable(true)
	self:refreshPetModelAppearance(templateId, shopClassCfg, petModel, 0, true)

	self.petPos = Vector3(petModel.eModel:GetTransformPosition())
	self.petPosZ = shopClassCfg.pet_modelRotation[3] or 0
end

function AFKShopScene:refreshPetModelAppearance(templateId, shopClassCfg, ent, label, visible, gender)
	ent = ent or self.petModel
	gender = gender or self.gender

	if not ent then
		return
	end

	local eModel = ent.eModel

	if eModel then
		local petData = PetProtoTypeData[templateId]
		local modelView = eModel.modelModelView
		local extraData, prefabResID

		extraData = ClientModelUtils.getModelExtraInfo(petData, label or 0, 0, false)
		prefabResID = shopClassCfg.prefabResID
		extraData.prefabResID = prefabResID

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, petData, extraData)

		eModel.RootRotationScale = Vector3.zero

		ClientModelUtils.applyAnimController(ent, eModel, petData)
		modelView:RefreshModels()
		ent:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, visible)

		local shaderView = eModel.modelShaderView

		if shaderView then
			shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		end

		ent:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)

		local entCfg = ent:getConfigData()

		ent.eModel:GenCapsule(Const.COMPONENT_IDX_PHYSX, entCfg.bodySize, entCfg.modelHeight, Vector3(0, entCfg.modelHeight / 2, 0), true, false)

		self.modelHeight = entCfg.modelHeight * shopClassCfg.pet_scale * 0.5 or 0.5

		ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		ent:setRendererLod(0)
	end
end

function AFKShopScene:playAnimation(key, restart, timelineTag, isLoop, forceLayer)
	if self.petModel then
		return self.petModel:playAnimation(key, restart, timelineTag, isLoop, forceLayer)
	end
end

function AFKShopScene:updateLookAt()
	if self.petModel and self.ableLookAt then
		local worldPos = pg.global.uiMgr:MouseToWorldPoint(self.uICameraCamera)
		local newPos = worldPos - self.petPos

		worldPos.x = worldPos.x
		worldPos.y = self.petPos.y + self.modelHeight + newPos.y
		worldPos.z = self.petPos.z + self.petPosZ + 1

		self.petModel:lookAtPos(worldPos, false)
	end
end

function AFKShopScene:setLookAtAble(bool)
	self.ableLookAt = bool

	if not self.ableLookAt then
		-- block empty
	end
end

function AFKShopScene:onDestroy()
	if self.petModel ~= nil then
		self.petModel = nil
	end
end

return AFKShopScene
