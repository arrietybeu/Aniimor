-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\PetFirstMeetScene.lua

local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local PlayableConst = require("Common.Const.PlayableConst")
local bit = bit
local Const = require("Common.Const.Const")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetData = require("Data.pet_data")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PetFirstMeetScene = Class.LightClass("PetFirstMeetScene", UISceneBase)
local ClientAbilityConst = require("Const.ClientAbilityConst")

function PetFirstMeetScene:onStart()
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.petScaleTransform = self.objectReference:GetRefValue("petScaleTransform")
	self.cameraCamera = self.objectReference:GetRefValue("cameraCamera")
	self.petPosTransform = self.objectReference:GetRefValue("petPosTransform")
	self.scene.transform.position = Vector3(0, 5000, 0)

	pgUtils.DisableEffectLodUnload(self.scene.transform)
end

function PetFirstMeetScene:showPet(templateId, label, firstShowData, shinyStyle)
	local petData = PetData[templateId]

	if self.ent and (self.templateId ~= templateId or self.label ~= label) then
		self:destroyPet()
	end

	self.templateId = templateId
	self.label = label

	local isNewEnt = false

	if not self.ent then
		self.ent = ClientSimpleVirtualEntity.new()

		self.ent:setConfigData(petData)

		local initInfo = {
			templateId = templateId,
			label = label,
			shinyStyle = shinyStyle
		}

		self.ent:init(initInfo)
		self.ent:postInit(initInfo)
		self.ent:start()
		self.ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
		self.ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)

		isNewEnt = true
	end

	local scaleFT = firstShowData.scaleFT or 1
	local ent = self.ent
	local eModel = ent.eModel

	ent.label = label
	ent.modelLoadedCallback = CallbackHandler(self, "applyPetRenderState", ent)

	eModel:SetTransformParent(self.petPosTransform, false)

	local contentData = PetResearchUtils.getPetResearchContent(templateId)
	local scale = (contentData.scale or 1) * scaleFT

	self.petScaleTransform.localScale = Vector3(scale, scale, scale)
	self.petPosTransform.localPosition = Vector3(firstShowData.offset[1], firstShowData.offset[2], firstShowData.offset[3])

	local modelRotation = Quaternion.Euler(contentData.modelRotation[1], contentData.modelRotation[2], contentData.modelRotation[3])

	eModel:SetTransformLocalRotation(modelRotation.x, modelRotation.y, modelRotation.z, modelRotation.w)
	eModel:SetActiveEx(true)

	local didRefresh = PetTransmogUtils.applySchemeTransmog(ent, templateId, nil, not isNewEnt, true)

	self:replayAfterTransmogRefresh(ent, didRefresh, CallbackHandler(self, "playFirstMeetAnimation", ent, firstShowData))

	local resId = PetData[templateId].resId

	if resId then
		pg.game.audio:triggerEvent("VOX_Combat_Parmon_" .. tostring(resId) .. "_Appear")
	end
end

function PetFirstMeetScene:applyPetRenderState(ent)
	if self.ent ~= ent or not ent.eModel then
		return
	end

	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
	ent:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)

	local eModel = ent.eModel
	local shaderView = eModel.modelShaderView

	if shaderView then
		shaderView:SetShaderGlowOrSilhouette("UIPetAppear", 0.7, 2.15)
		shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
		shaderView:MultiPassUseExtraConfig(0)
	end
end

function PetFirstMeetScene:playFirstMeetAnimation(ent, firstShowData)
	if self.ent ~= ent or not ent.eModel then
		return
	end

	self:applyPetRenderState(ent)

	local aniCfg = firstShowData.animation

	if #aniCfg <= 3 then
		ent:playCfgAnimation({
			aniCfg[1],
			aniCfg[2],
			aniCfg[3],
			{
				true
			}
		})
	else
		ent:playCfgAnimation(aniCfg)
	end

	ent.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, function()
		if self.ent ~= ent then
			return
		end

		ent:stopLayerAnimation(PlayableConst.AnimationLayer.LAYER_FULLBODY, 0.2)
		ent:playAnimation(PlayableConst.Idle)
	end)
end

function PetFirstMeetScene:onDestroy()
	self:destroyPet()
end

function PetFirstMeetScene:destroyPet()
	if self.ent then
		ClientUtils.safeDestroy(self.ent)
	end

	self.ent = nil
	self.templateId = nil
	self.label = nil
end

return PetFirstMeetScene
