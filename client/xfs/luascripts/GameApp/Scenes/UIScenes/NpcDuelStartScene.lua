-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\NpcDuelStartScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local NpcDuelStartScene = Class.LightClass("NpcDuelStartScene", UISceneBase)
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AvatarData = require("Data.avatar_data")
local ClientNpcDuelAvatarPrefabPlayer = require("Entities.ClientNpcDuelAvatarPrefabPlayer")

function NpcDuelStartScene:onStart(param)
	self.curEntity = nil
	self.curPetId = nil

	self:initScene(param)
end

function NpcDuelStartScene:initScene(param)
	local textureWidth = 1400
	local textureHeight = 1400

	if param and param.textureWidth then
		textureWidth = param.textureWidth
		textureHeight = param.textureHeight
	end

	local global = self.scene.transform:Find("Global")
	local objectReference = global:GetComponent("ObjectReference")

	self.rLTransform = objectReference:GetRefValue("rLTransform")
	self.rRTransform = objectReference:GetRefValue("rRTransform")
	self.shaderViewComp = objectReference:GetRefValue("shaderViewComp")
	self.xmeshRenderAnim = objectReference:GetRefValue("xmeshRenderAnim")
	self.cameraAni = objectReference:GetRefValue("cameraAni")
end

function NpcDuelStartScene:previewModel_Left()
	local leftPlayer = self:copyMainPlayer()

	if leftPlayer then
		leftPlayer.eModel:SetTransformParent(self.rLTransform)
		leftPlayer.eModel:SetTransformLocalRotation(0, 0, 0, 1)
		leftPlayer.eModel:SetTransformLocalPosition()
		leftPlayer:setRendererLod(0)

		self.leftEntity = leftPlayer
	end
end

function NpcDuelStartScene:previewModel_Right()
	local avatarId = pg.me.npcDuelBotInfo.avatarId

	if not ToBool(avatarId) then
		return
	end

	local avatarData = AvatarData[avatarId]

	if not avatarData or not avatarData.prefabResID then
		return
	end

	local initDict = {
		useDefaultParts = true,
		templateId = avatarId,
		avatarPrefabResID = avatarData.prefabResID
	}
	local entityId = "NpcDuelAvatarPrefab_" .. avatarData.prefabResID

	self:removeEntity(entityId)

	local entity = self:createEntity(entityId, ClientNpcDuelAvatarPrefabPlayer, initDict)

	entity:setRendererLod(0)

	entity.curShow = {
		customShow = {}
	}

	entity.eModel:SetTransformParent(self.rRTransform)
	entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	entity.eModel:SetTransformLocalPosition()

	self.rightEntity = entity
end

function NpcDuelStartScene:cameraAnimToIn()
	if not IsNil(self.cameraAni) then
		self.cameraAni:Play("CameraAni_Activity_GymBattle_PrepareStart")
	end
end

function NpcDuelStartScene:cameraAnimToConfirm()
	if not IsNil(self.cameraAni) then
		self.cameraAni:Play("CameraAni_Activity_GymBattle_PrepareToLoading")
	end
end

function NpcDuelStartScene:bgAnimToConfirm()
	if not IsNil(self.xmeshRenderAnim) then
		self.xmeshRenderAnim:Play("VX_Ani_BattleRoom_BG_Confirm")
	end
end

function NpcDuelStartScene:bgAnimToIn()
	if not IsNil(self.xmeshRenderAnim) then
		self.xmeshRenderAnim:Play("VX_Ani_BattleRoom_BG_In")
	end
end

function NpcDuelStartScene:bgAnimToClamp()
	if not IsNil(self.xmeshRenderAnim) then
		self.xmeshRenderAnim:Play("VX_Ani_BattleRoom_BG_Nml")
	end
end

function NpcDuelStartScene:applyMaterialEffect(keyName)
	if not IsNil(self.shaderViewComp) then
		self.shaderViewComp:ApplyMaterialEffect(keyName)
	end
end

function NpcDuelStartScene:playSleAnimation_Player(anim1, anim2)
	if self.leftEntity then
		AnimationUtils.playSleAnimation(self.leftEntity, AnimationUtils.getID(anim1), AnimationUtils.getID(anim2), AnimationUtils.getID(anim2), false, math.maxFloat)
	end
end

function NpcDuelStartScene:playSleAnimation_NPC(anim1, anim2)
	if self.rightEntity then
		AnimationUtils.playSleAnimation(self.rightEntity, AnimationUtils.getID(anim1), AnimationUtils.getID(anim2), AnimationUtils.getID(anim2), false, math.maxFloat)
	end
end

function NpcDuelStartScene:onDestroy()
	if self.renderTexture ~= nil then
		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end
end

return NpcDuelStartScene
