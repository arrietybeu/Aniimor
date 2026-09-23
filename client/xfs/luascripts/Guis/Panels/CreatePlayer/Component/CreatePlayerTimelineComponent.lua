-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayer\\Component\\CreatePlayerTimelineComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local CreatePlayerTimelineComponent = Class.LightClass("CreatePlayerTimelineComponent", UIComponent)
local AddressDataConst = require("Const.AddressDataConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local UIConst = require("Const.UIConst")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")

function CreatePlayerTimelineComponent:findObjects()
	self.cutscene = pg.game.cutscene:getCurCutScene()

	self:onCutSceneLoaded()
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.CREATE_PLAYER)
end

function CreatePlayerTimelineComponent:onCutSceneLoaded()
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if avatarScene == nil then
		return
	end

	local ctSceneOc = self.cutscene.cutscene.prefabRoot:GetComponent("ObjectReference")

	self.tm3DUIRoot = ctSceneOc:GetRefValue("3DUIRoot")
	self.uI3DTransfer = ctSceneOc:GetRefValue("uI3DTransfer"):GetComponent("ObjectReference")
	self.avatarIcon = self.uI3DTransfer:GetRefValue("imgAvatar")
	self.playerName = self.uI3DTransfer:GetRefValue("txtName")

	pg.global.resMgr:GetInstanceFromCacheByLua(AddressDataConst.CREATE_USER_3DUI_RES, function(gameObj, userData)
		if IsNil(gameObj) then
			return
		end

		self.UI_3D_Root = gameObj

		self.UI_3D_Root.transform:SetParent(avatarScene.uI3DRoot, false)

		self.UI_3D_Root.transform.localPosition = Vector3.zero

		local oc = gameObj.transform:GetComponent("ObjectReference")

		self.uiCanvas = gameObj.transform:GetComponent("Canvas")
		self.dissolveBG = oc:GetRefValue("dissolveBG")
		self.quickPhoto = oc:GetRefValue("quickPhoto")
		self.vxAnimation = oc:GetRefValue("uI3DAnimation")
		self.ui3DCmp = oc:GetRefValue("uI3DComponent")
		self.rTPanel = oc:GetRefValue("rTPanel")

		self.dissolveBG.gameObject:SetActiveEx(false)
		self.quickPhoto.gameObject:SetActiveEx(false)
		self:onTransitionFromAvatar()
	end)
	self.cutscene:setEventCallback(function(param)
		self:onTriggerTmEvent(param)
	end)
end

function CreatePlayerTimelineComponent:onTransitionFromAvatar()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if self.avatarScene == nil then
		return
	end

	self.ctrEntity = self.avatarScene:getCurEntity()

	pg.game.cutscene:setOtherPlayer(ClientConst.CutsceneOtherPlayerKey.Player1, self.ctrEntity.id)
	self.ctrEntity.eModel:SetTransformParent(self.cutscene.cutscene.rootObject.transform)

	self.ctrEntity.eModel.isMainAuthority = false

	self.avatarScene:setTagCameraMode(function()
		self:onQuickPhoto()
	end, 1)
	EModelUtils.setAgentRotation(self.ctrEntity, Quaternion.Euler(0, 0, 0))
	self.ctrEntity.eModel.modelView:CloseBoneSpringByActorId(self.ctrEntity.actorId)
	self:playPosAnim(self.ctrEntity, PlayableConst.Idle, false)
end

function CreatePlayerTimelineComponent:playPosAnim(entity, animName, isLoop, finishedCallback)
	local res = entity:playAnimation(animName, false, nil, isLoop)

	if not finishedCallback then
		return
	end

	if res then
		res:AddEndCallback(finishedCallback)
	else
		self:startTimer(finishedCallback, 0.5)
	end
end

function CreatePlayerTimelineComponent:onQuickPhoto()
	if self.avatarScene.mPlane then
		self.avatarScene.mPlane.gameObject.layer = ClientConst.LayerDefine.LAYER_CUTSCENE
	end

	if self.avatarScene.vfxPlane then
		self.avatarScene.vfxPlane.gameObject.layer = ClientConst.LayerDefine.LAYER_CUTSCENE
	end

	pg.global.cameraMgr:AddUISceneCameraLayer(self.avatarScene.camera, ClientConst.LayerDefine.LAYER_CUTSCENE)
	pg.global.cameraMgr:AddUISceneCameraLayer(self.avatarScene.camera, ClientConst.LayerDefine.LAYER_PLAYER)

	self.avatarScene.cameraPlayer.targetTexture = self.quickPhoto.texture

	self.avatarScene.cameraPlayer.gameObject:SetActiveEx(true)
	self:mergeCameraParams(self.avatarScene.camera, self.avatarScene.cameraPlayer)
	pg.global.cameraMgr:SetUISceneCameraLayer(self.avatarScene.cameraPlayer, ClientConst.LayerDefine.LAYER_PLAYER)
	self.ctrEntity:setModelLayer(ClientConst.LayerDefine.LAYER_PLAYER)

	self.avatarScene.cameraBG.targetTexture = self.dissolveBG.texture

	self.avatarScene.cameraBG.gameObject:SetActiveEx(true)
	self:mergeCameraParams(self.avatarScene.camera, self.avatarScene.cameraBG)
	pg.global.cameraMgr:SetUISceneCameraLayer(self.avatarScene.cameraBG, ClientConst.LayerDefine.LAYER_CUTSCENE)

	self.avatarScene.cameraHeadIcon.targetTexture = self.avatarIcon.texture

	self.avatarScene.cameraHeadIcon.gameObject:SetActiveEx(true)
	self:startFrameTimer(function()
		self:finishedQuickPhoto()
	end, 2)
end

function CreatePlayerTimelineComponent:finishedQuickPhoto()
	self.quickPhoto.gameObject:SetActiveEx(true)
	self.dissolveBG.gameObject:SetActiveEx(true)

	self.avatarScene.cameraBG.targetTexture = nil
	self.avatarScene.cameraPlayer.targetTexture = nil

	self.avatarScene.cameraBG.gameObject:SetActiveEx(false)
	self.avatarScene.cameraPlayer.gameObject:SetActiveEx(false)
	self.avatarScene.cameraHeadIcon.gameObject:SetActiveEx(false)
	self.ctrEntity.eModel:SetActive(false)
	self:onTransition2Timeline()
	self.vxAnimation:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	pg.game.audio:triggerEvent("SFX_UI_CreateRole_Transition")
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Avatar)
end

function CreatePlayerTimelineComponent:onTransition2Timeline()
	self.cutscene.cutscene.prefabRoot.gameObject:SetActiveEx(true)
	self.UI_3D_Root.transform:SetParent(self.tm3DUIRoot, false)

	self.UI_3D_Root.transform.localPosition = Vector3.zero

	pg.game.uiScene:switchOutScene(UISceneConst.AVATAR_SCENE, true)
	self.cutscene:setRefEntityByTemplateId(self.ctrEntity.templateId, self.ctrEntity)

	if self.ctrEntity.templateId == 3 then
		self.cutscene.cutscene:SetGroupActiveWithName("BOY", false)
		self.cutscene.cutscene:SetGroupActiveWithName("GIRL", true)
	else
		self.cutscene.cutscene:SetGroupActiveWithName("GIRL", false)
		self.cutscene.cutscene:SetGroupActiveWithName("BOY", true)
	end

	self.cutscene:play(function()
		return
	end)

	self.uiCanvas.worldCamera = pg.global.cameraMgr.worldCameraInst

	pg.global.cameraMgr:AddWorldCameraLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	self.ctrEntity.eModel:SetActive(true)
	pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.CREATE_PLAYER)
end

function CreatePlayerTimelineComponent:mergeCameraParams(src, dest)
	dest.fieldOfView = src.fieldOfView
	dest.transform.localPosition = src.transform.localPosition
end

function CreatePlayerTimelineComponent:onTriggerTmEvent(name)
	if name == "takeName" then
		self.cutscene:setSpeed(0)
		self.ctrl:show()
		self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		pg.game.audio:triggerEvent("SFX_UI_CreateRole_Naming")
	elseif name == "close3Dui" then
		self.vxAnimation:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		pg.game.audio:triggerEvent("SFX_UI_CreateRole_ScreenOff")
	elseif name == "openCircleUI" then
		-- block empty
	elseif name == "hideRole" then
		self.rTPanel:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif name == "login" then
		self:onEndTimeline()
	end
end

function CreatePlayerTimelineComponent:continuePlay()
	self.cutscene:setSpeed(1)
	self.ui3DCmp:TryChangePage("Upload", 1)
	pg.game.audio:triggerEvent("SFX_UI_CreateRole_NamingFinish")
	self:onEndTimeline()
end

function CreatePlayerTimelineComponent:onEndTimeline()
	self.cutscene:setSpeed(0)

	local ClientRepo = require("Core.Client.ClientRepo")

	ClientRepo.loginAgent:loginImp()
end

function CreatePlayerTimelineComponent:setPlayerName(name)
	ClientTextUtils.setText(self.playerName, name)
end

function CreatePlayerTimelineComponent:onDestroy()
	pg.game.cutscene:setOtherPlayer(ClientConst.CutsceneOtherPlayerKey.Player1, nil)
	pg.global.cameraMgr:SubWorldCameraLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	if not IsNil(self.quickPhoto) then
		pg.global.uiMgr:ReleaseRenderTexture(self.quickPhoto.texture)
	end

	if not IsNil(self.dissolveBG) then
		pg.global.uiMgr:ReleaseRenderTexture(self.dissolveBG.texture)
	end

	if not IsNil(self.avatarIcon) then
		pg.global.uiMgr:ReleaseRenderTexture(self.avatarIcon.texture)
	end

	pg.global.resMgr:RemoveInstanceToCache(self.UI_3D_Root, true)

	if self.cutscene then
		self.cutscene:destroy()
	end

	self.cutscene = nil

	UIComponent.onDestroy(self)
end

return CreatePlayerTimelineComponent
