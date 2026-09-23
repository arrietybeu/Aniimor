-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetSimpleScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PetSimpleScene = Class.LightClass("PetSimpleScene", UISceneBase)
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local PetProtoTypeData = require("Data.pet_prototype_data")

function PetSimpleScene:onStart(param)
	self:initScene(param)
end

function PetSimpleScene:initScene(param)
	self.objectReference = self.scene.transform:GetComponent("ObjectReference")
	self.cameraCamera = self.objectReference:GetRefValue("cameraCamera")
	self.petPosTransform = self.objectReference:GetRefValue("petPosTransform")
	self.scene.transform.position = Vector3(0, 5000, 0)
	self.fov = self.cameraCamera.fieldOfView
	self.cameraTrans = self.cameraCamera.transform
end

function PetSimpleScene:setTemplateId(templateId, label, rotationCfg, gender)
	self.curTemplateId = templateId
	self.label = label
	self.rotationCfg = rotationCfg
	self.gender = gender
end

function PetSimpleScene:setRawImageProRef(rawImagePro)
	self.cameraCamera.targetTexture = rawImagePro.texture
end

function PetSimpleScene:refreshEntity()
	local configData = PetProtoTypeData[self.curTemplateId]

	if self.curEnt then
		ClientUtils.safeDestroy(self.curEnt)
	end

	self.curEnt = ClientSimpleVirtualEntity.new()

	self.curEnt:setConfigData(configData)

	local initInfo = {
		isIgnoreEffectLod = true,
		templateId = self.curTemplateId
	}

	self.curEnt:init(initInfo)
	self.curEnt:postInit(initInfo)
	self.curEnt:start()
	self.curEnt:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	local eModel = self.curEnt.eModel

	if eModel then
		local petData = PetProtoTypeData[self.curTemplateId]
		local modelView = eModel.modelModelView
		local extraData, prefabResID

		extraData = ClientModelUtils.getModelExtraInfo(petData, self.label or 0, self.gender or 0, false)

		ClientModelUtils.applyModelAppearance(modelView.modelInfo, petData, extraData)

		eModel.RootRotationScale = Vector3(0, 0, 0)

		ClientModelUtils.applyAnimController(self.curEnt, eModel, configData)
		self.curEnt:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		self.curEnt:setRendererLod(0)
		modelView:RefreshModels()
		self.curEnt:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
		eModel:SetTransformParent(self.petPosTransform, false)
	end

	local success, pos, size = eModel:TryGetHead(Const.COMPONENT_INDEX_MODEL)
	local targetForward = self.curEnt:getRotation() * Vector3.forward
	local targetPos = pos + size * targetForward * 2
	local cameraTrans = self.cameraCamera.transform

	cameraTrans.position = targetPos
	cameraTrans.rotation = Quaternion.LookRotation(-targetForward, Vector3.up)
end

function PetSimpleScene:beforeAnimation()
	PetSimpleScene.super.beforeAnimation(self)

	if self.curEnt then
		local eModel = self.curEnt.eModel

		if eModel then
			local entPos = self.curEnt:getPosition()
			local success, pos, size = eModel:TryGetHead(Const.COMPONENT_INDEX_MODEL)
			local targetForward = self.curEnt:getRotation() * Vector3.forward
			local sizeScale = 1.4
			local chestPosition = 0.7
			local topPosY = pos.y + size * sizeScale
			local bottomY = pos.y - size * sizeScale

			bottomY = math.min(math.lerp(entPos.y, pos.y, chestPosition), bottomY)

			local len = (topPosY - bottomY) / 2
			local midY = (topPosY + bottomY) / 2

			len = len / math.tan(math.rad(self.fov / 2))

			local targetPos = Vector3(pos.x, midY, pos.z) + targetForward * len

			self.cameraTrans.position = targetPos
			self.cameraTrans.rotation = Quaternion.LookRotation(-targetForward, Vector3.up)
		end
	end
end

return PetSimpleScene
