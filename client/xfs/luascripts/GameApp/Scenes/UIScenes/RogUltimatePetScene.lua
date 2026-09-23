-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\RogUltimatePetScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local RogueTransformData = require("Data.rogue_transform_data")
local RogueUtils = require("Utils.RogueUtils")
local RogUltimatePetScene = Class.LightClass("RogUltimatePetScene", UISceneBase)

function RogUltimatePetScene:onStart(param)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(1400, 1400, 24)
	self.cam = self.objectReference:GetRefValue("cam")
	self.cam.targetTexture = self.renderTexture
	self.pos = self.objectReference:GetRefValue("pos")
	self.scene.transform.position = Vector3(0, 5000, 0)

	self:_applyPosFromConfig(param.posConfigKey)

	local petTemplateId = RogueUtils.getUltimatePetTemplateID()
	local entity = ClientVirtualEntityUtils.createPetVirtualEntity(petTemplateId)

	if entity then
		entity.eModel:SetTransformParent(self.pos)
		entity.eModel:SetTransformLocalPosition()
		entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		entity.eModel:SetTransformLocalScale()
		entity.eModel:SetModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		entity.eModel.modelShaderView:MultiPassUseExtraConfig(0)

		self.entity = entity
	end
end

function RogUltimatePetScene:setRawImageProRef(rawImagePro)
	if not self.renderTexture then
		return
	end

	rawImagePro.texture = self.renderTexture
end

function RogUltimatePetScene:_applyPosFromConfig(posConfigKey)
	if not posConfigKey then
		return
	end

	local series = pg.me.rogueUltimateSeries

	if series < 0 then
		return
	end

	local posConfig = RogueTransformData[series][posConfigKey] or {}

	if posConfig.pos then
		self.pos.localPosition = posConfig.pos
	end

	if posConfig.rot then
		self.pos.localEulerAngles = posConfig.rot
	end

	if posConfig.scale then
		self.pos.localScale = posConfig.scale
	end
end

function RogUltimatePetScene:onDestroy()
	if self.renderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end

	if self.entity then
		ClientUtils.safeDestroy(self.entity)

		self.entity = nil
	end
end

return RogUltimatePetScene
