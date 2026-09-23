-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\AvatarCreateRoleScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local AvatarCreateRoleScene = Class.LightClass("AvatarCreateRoleScene", UISceneBase)

AvatarCreateRoleScene.ENTITY_SLOT_ID = {
	BOY_LOOP = -1758607216,
	GIRL = -960799485,
	BOY = -1467211069,
	GIRL_LOOP = -1879547106
}

local BODY_TYPE = {
	BOY = 21,
	GIRL = 11
}

local function getPresetIdByBody(body)
	local resultId, resultSort

	for id, cfg in pairs(AvatarPresetData) do
		if cfg.body == body and cfg.sort and (resultSort == nil or resultSort > cfg.sort) then
			resultId, resultSort = id, cfg.sort
		end
	end

	return resultId
end

AvatarCreateRoleScene.ENTITY_TYPE = {
	BOY = getPresetIdByBody(BODY_TYPE.BOY),
	GIRL = getPresetIdByBody(BODY_TYPE.GIRL)
}

function AvatarCreateRoleScene:onStart()
	self:initScene()
end

function AvatarCreateRoleScene:initScene()
	self.scene.transform.position = Vector3(0, 500, 0)
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.createRoleCutSceneRoot = self.objectReference:GetRefValue("createRoleCutSceneRoot")
	self.createRoleLoopCutSceneRoot = self.objectReference:GetRefValue("createRoleLoopCutSceneRoot")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")

	local global = self.scene.transform:Find("Global")

	self.sharedModelAnchor = global:Find("SharedModelAnchor")

	if IsNil(self.sharedModelAnchor) then
		local anchorGo = CS.UnityEngine.GameObject("SharedModelAnchor")

		anchorGo.transform:SetParent(global)

		anchorGo.transform.localPosition = Vector3.zero
		anchorGo.transform.localRotation = Quaternion.identity
		anchorGo.transform.localScale = Vector3.one
		self.sharedModelAnchor = anchorGo.transform
	end

	self.sharedModelAnchor.gameObject:SetActiveEx(false)
	self:preProcess()
	ClientTextUtils.setText(self.textUSDFText, pg.getGameString("CHOOSE_YOUR_APPEARANCE"))
end

function AvatarCreateRoleScene:onDestroy()
	local avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not avatarScene or avatarScene.expire then
		pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Avatar)
	end
end

function AvatarCreateRoleScene:preProcess()
	self.createRoleCutSceneRoot:BindCreateEntityDelegate(function(data)
		if data.slotKey == AvatarCreateRoleScene.ENTITY_SLOT_ID.GIRL then
			return self:createTrackRefVirtualEntity(data, AvatarCreateRoleScene.ENTITY_TYPE.GIRL)
		elseif data.slotKey == AvatarCreateRoleScene.ENTITY_SLOT_ID.BOY then
			return self:createTrackRefVirtualEntity(data, AvatarCreateRoleScene.ENTITY_TYPE.BOY)
		end
	end)
	self.createRoleCutSceneRoot:CreateAndBindAssets(true)
	self.createRoleCutSceneRoot:WaitAssetsReady(function()
		self:bindLoopTimelineToSharedModels()
	end)
end

function AvatarCreateRoleScene:bindLoopTimelineToSharedModels()
	self.createRoleLoopCutSceneRoot:BindCreateEntityDelegate(function(data)
		if data.slotKey == AvatarCreateRoleScene.ENTITY_SLOT_ID.GIRL_LOOP then
			local girlEnt = self.entPool[AvatarCreateRoleScene.ENTITY_SLOT_ID.GIRL]

			return girlEnt and girlEnt.eModel
		elseif data.slotKey == AvatarCreateRoleScene.ENTITY_SLOT_ID.BOY_LOOP then
			local boyEnt = self.entPool[AvatarCreateRoleScene.ENTITY_SLOT_ID.BOY]

			return boyEnt and boyEnt.eModel
		end
	end)
	self.createRoleLoopCutSceneRoot:CreateAndBindAssets(true)
	self:ensureCutsceneLayer()
end

function AvatarCreateRoleScene:createTrackRefVirtualEntity(virtualEntityData, presetKey)
	local templateId = pg.game.avatar:getAvatarPresetData(presetKey).templateId
	local initDict = {
		useDefaultParts = true,
		templateId = templateId,
		avatarPresetKey = presetKey
	}
	local virtualEntity = self:createEntity(virtualEntityData.slotKey, ClientSimpleVirtualPlayer, initDict)

	virtualEntity.eModel:SetTransformParent(self.sharedModelAnchor)
	virtualEntity.eModel:SetTransformLocalPosition()
	virtualEntity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	virtualEntity.eModel:SetTransformLocalScale()

	if virtualEntity.isModelLoaded then
		self:tryActivatePreviewModels()
	else
		local previousCallback = virtualEntity.modelLoadedCallback

		function virtualEntity.modelLoadedCallback()
			if self.expire then
				return
			end

			virtualEntity.modelLoadedCallback = previousCallback

			if previousCallback then
				previousCallback()
			end

			self:tryActivatePreviewModels()
		end
	end

	return virtualEntity and virtualEntity.eModel
end

function AvatarCreateRoleScene:tryActivatePreviewModels()
	if self.expire then
		return
	end

	local boy = self.entPool[AvatarCreateRoleScene.ENTITY_SLOT_ID.BOY]
	local girl = self.entPool[AvatarCreateRoleScene.ENTITY_SLOT_ID.GIRL]

	if boy and girl and boy.isModelLoaded and girl.isModelLoaded then
		self.sharedModelAnchor.gameObject:SetActiveEx(true)
	end
end

function AvatarCreateRoleScene:ensureCutsceneLayer()
	if IsNil(self.createRoleCutSceneRoot) or IsNil(self.createRoleCutSceneRoot.transform) or IsNil(self.createRoleLoopCutSceneRoot) or IsNil(self.createRoleLoopCutSceneRoot.transform) then
		return
	end

	LuaUIUtils.safeSetGoLayer(self.createRoleCutSceneRoot.transform.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
	LuaUIUtils.safeSetGoLayer(self.createRoleLoopCutSceneRoot.transform.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
end

function AvatarCreateRoleScene:prepareTimelineFirstFrame(readyCallback)
	if IsNil(self.createRoleCutSceneRoot) or IsNil(self.createRoleLoopCutSceneRoot) then
		return nil
	end

	self:ensureCutsceneLayer()

	local skipIntro = pg.game.avatar.jumpToCreateRoleTimelineEnd == true
	local targetRoot = skipIntro and self.createRoleLoopCutSceneRoot or self.createRoleCutSceneRoot

	self.preparedTimelineRoot = targetRoot
	self.preparedTimelineSkipIntro = skipIntro

	if skipIntro then
		self.createRoleCutSceneRoot.gameObject:SetActiveEx(false)
	end

	local cameras = targetRoot:GetComponentsInChildren(typeof(CS.FunPlus.WorldX.Cutscene.RefVirtualCameraBehavior), true)
	local originalBlendInTimes = {}
	local cameraCount = cameras and cameras.Length or 0

	for i = 0, cameraCount - 1 do
		originalBlendInTimes[i] = cameras[i].blendInTime
		cameras[i].blendInTime = 0
	end

	return function()
		local director = targetRoot:GetComponent(typeof(CS.UnityEngine.Playables.PlayableDirector))

		if IsNil(director) then
			for i = 0, cameraCount - 1 do
				cameras[i].blendInTime = originalBlendInTimes[i]
			end

			if readyCallback then
				readyCallback()
			end

			return
		end

		director.time = 0.03333333333333333

		director:Evaluate()
		director:Pause()

		for i = 0, cameraCount - 1 do
			cameras[i].blendInTime = originalBlendInTimes[i]
		end

		TimerManager.addSpecificFrameCb(2, false, function()
			if self.enable == true and readyCallback then
				readyCallback()
			end
		end)
	end
end

function AvatarCreateRoleScene:playPreparedTimeline()
	local targetRoot = self.preparedTimelineRoot

	if IsNil(targetRoot) then
		self:playTimeline()

		return
	end

	local skipIntro = self.preparedTimelineSkipIntro == true

	self.preparedTimelineRoot = nil
	self.preparedTimelineSkipIntro = nil
	pg.game.avatar.jumpToCreateRoleTimelineEnd = false

	pg.game.audio:playBgm("BGM_AppearanceSystem", AudioConst.BgmPriority.Avatar)

	if skipIntro then
		targetRoot:TryPlayTimeline()

		local createRoleUI = pg.global.ui.createRoleTimeline

		if createRoleUI then
			createRoleUI:onTimelineFinished()
		end

		return
	end

	targetRoot:TryPlayTimelineWithCallback(function()
		self.createRoleLoopCutSceneRoot:TryPlayTimeline()

		local createRoleUI = pg.global.ui.createRoleTimeline

		if createRoleUI then
			createRoleUI:onTimelineFinished()
		end
	end)
end

local RefVirtualCameraBehavior = CS.FunPlus.WorldX.Cutscene.RefVirtualCameraBehavior
local PlayableDirector = CS.UnityEngine.Playables.PlayableDirector

local function releaseCutsceneRoot(root)
	if IsNil(root) then
		return
	end

	local director = root:GetComponent(typeof(PlayableDirector))

	if not IsNil(director) then
		director:Pause()
	end

	local cameras = root:GetComponentsInChildren(typeof(RefVirtualCameraBehavior), true)
	local cameraCount = cameras and cameras.Length or 0

	for i = 0, cameraCount - 1 do
		cameras[i].blendOutTime = 0
	end

	root.gameObject:SetActiveEx(false)
end

function AvatarCreateRoleScene:releaseForSnapshot()
	self.preparedTimelineRoot = nil
	self.preparedTimelineSkipIntro = nil

	releaseCutsceneRoot(self.createRoleCutSceneRoot)
	releaseCutsceneRoot(self.createRoleLoopCutSceneRoot)
end

function AvatarCreateRoleScene:playTimeline()
	if IsNil(self.createRoleCutSceneRoot) or IsNil(self.createRoleLoopCutSceneRoot) then
		return
	end

	self:ensureCutsceneLayer()

	local createRoleUI = pg.global.ui.createRoleTimeline

	if pg.game.avatar.jumpToCreateRoleTimelineEnd then
		pg.game.audio:playBgm("BGM_AppearanceSystem", AudioConst.BgmPriority.Avatar)
		TimerManager.addTimer(0.1, function()
			self.createRoleCutSceneRoot.gameObject:SetActiveEx(false)
			self.createRoleLoopCutSceneRoot:TryPlayTimeline()
		end)

		pg.game.avatar.jumpToCreateRoleTimelineEnd = false

		if createRoleUI then
			createRoleUI:onTimelineFinished()
		end

		return
	end

	pg.game.audio:playBgm("BGM_AppearanceSystem", AudioConst.BgmPriority.Avatar)
	self.createRoleCutSceneRoot:TryPlayTimelineWithCallback(function()
		self.createRoleLoopCutSceneRoot:TryPlayTimeline()

		if createRoleUI then
			createRoleUI:onTimelineFinished()
		end
	end)
end

return AvatarCreateRoleScene
