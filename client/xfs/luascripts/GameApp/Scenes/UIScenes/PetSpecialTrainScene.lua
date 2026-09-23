-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetSpecialTrainScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local PetSpecialTrainScene = Class.LightClass("PetSpecialTrainScene", UISceneBase)
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")

function PetSpecialTrainScene:onStart(param)
	self.curEntity = nil
	self.curPetId = nil

	self:initScene(param)
end

function PetSpecialTrainScene:initScene(param)
	local textureWidth = 1400
	local textureHeight = 1400

	if param and param.textureWidth then
		textureWidth = param.textureWidth
		textureHeight = param.textureHeight
	end

	local root = self.scene.transform:Find("Global")

	self.objectReference = root:GetComponent("ObjectReference")
	self.cameraCamera = self.objectReference:GetRefValue("cameraCamera")
	self.petPos = self.objectReference:GetRefValue("petPos")
	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(textureWidth, textureHeight, 24)
	self.cameraCamera.targetTexture = self.renderTexture
	self.scene.transform.position = Vector3(0, 5000, 0)
end

function PetSpecialTrainScene:setRawImageProRef(rawImagePro)
	if not self.renderTexture then
		return
	end

	rawImagePro.texture = self.renderTexture
end

function PetSpecialTrainScene:previewPetByTId(petTId, playDissolve)
	if self.curPetId == petTId then
		return
	end

	local entity = ClientVirtualEntityUtils.createPetVirtualEntity(petTId)

	if entity then
		entity.eModel:SetTransformParent(self.petPos)
		entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		entity.eModel:SetTransformLocalPosition()
		entity.eModel:SetModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		entity.eModel.modelShaderView:MultiPassUseExtraConfig(0)

		local offsetY = 0
		local isBorn = true
		local globalOffsetY = 0

		if entity.eModel and playDissolve then
			local dissolveStartPosition = Vector3(0, 0, 0)
			local playerHeight = entity:getHeight() + offsetY

			dissolveStartPosition.y = dissolveStartPosition.y + playerHeight + globalOffsetY

			local border = playerHeight * 1
			local startValue = isBorn and playerHeight - 0.1 + globalOffsetY or globalOffsetY
			local endValue = isBorn and globalOffsetY or playerHeight - 0.1 + globalOffsetY

			entity.eModel.shaderView:PlayDissolveSurfaceEffectPreset("SpecialTrainDissolve", dissolveStartPosition, startValue, endValue, border)
		end

		self.curEntity = entity
		self.curPetId = petTId
	end
end

function PetSpecialTrainScene:playPetIdle()
	if self.curEntity then
		self.curEntity:playAnimation("Idle")
	end
end

function PetSpecialTrainScene:clear()
	if self.renderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end

	if self.curEntity and self.curPetId then
		ClientUtils.safeDestroy(self.curEntity)

		self.curEntity = nil
		self.curPetId = nil
	end
end

function PetSpecialTrainScene:onDestroy()
	self:clear()
end

function PetSpecialTrainScene:entActive(active)
	if self.curEntity then
		self.curEntity:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, active)
	end
end

return PetSpecialTrainScene
