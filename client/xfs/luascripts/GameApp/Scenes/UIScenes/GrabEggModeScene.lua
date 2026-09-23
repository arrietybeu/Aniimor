-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\GrabEggModeScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemConst = require("Common.Const.ItemConst")
local PlayableConst = require("Common.Const.PlayableConst")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local GrabEggModeScene = Class.LightClass("GrabEggModeScene", UISceneBase)
local INIT_PARAM = {
	{
		weatherProfilerName = "WeatherProfile_Snow_Heavy",
		time = {
			12,
			0,
			0
		},
		boatInitPos = {
			-82.63,
			0,
			572.67
		},
		boatInitRot = {
			0,
			-35,
			0
		}
	},
	{
		weatherProfilerName = "WeatherProfile_Rain_Storm",
		time = {
			18,
			0,
			0
		},
		boatInitPos = {
			-74.32,
			0,
			567.45
		},
		boatInitRot = {
			0,
			147.886,
			0
		}
	}
}
local MODE_TIME = {
	{
		boatPos = {
			-82.63,
			0,
			572.67
		},
		boatRot = {
			0,
			-35,
			0
		}
	},
	{
		boatPos = {
			-81.39,
			0,
			572.39
		},
		boatRot = {
			0,
			0,
			0
		}
	},
	{
		boatPos = {
			-74.32,
			0,
			567.45
		},
		boatRot = {
			0,
			147.886,
			0
		}
	},
	{
		boatPos = {
			-74.32,
			0,
			567.45
		},
		boatRot = {
			0,
			147.886,
			0
		}
	}
}

function GrabEggModeScene:onCtor()
	self.mode = 1
	self.loadTimeout = 0.5
end

function GrabEggModeScene:onStart(param)
	local root = self.scene.transform:Find("Global")
	local objectReference = root:GetComponent("ObjectReference")

	self.uiSceneEnv = objectReference:GetComponent("UISceneEnv")
	self.boatCutscene = objectReference:GetRefValue("boatCutscene")
	self.camera = objectReference:GetRefValue("camera")
	self.vcCameraMode1 = objectReference:GetRefValue("vcCameraMode1")
	self.vcCameraMode2 = objectReference:GetRefValue("vcCameraMode2")
	self.vcCameraMode3 = objectReference:GetRefValue("vcCameraMode3")
	self.vcCameraMode4 = objectReference:GetRefValue("vcCameraMode4")
	self.boatCutscene = objectReference:GetRefValue("boatCutscene")
	self.colliderTransform = objectReference:GetRefValue("colliderTransform")
	self.eggs = {}

	pgUtils.SetAllEffLodCamera(self.boatCutscene.transform, self.camera)
	self:setInitParam(param)
	self.boatCutscene:BindCreateEntityDelegate(function(data)
		return self:createTrackRefVirtualEntity(data)
	end)
	self.boatCutscene:CreateAndBindAssets(true)
	self:ensureBoatCutsceneLayer()
end

function GrabEggModeScene:onAllEntityLoaded()
	local virtualPlayer = self.entPool[pg.me.uid]

	if not virtualPlayer then
		return
	end

	if GrabEggModeScene._isVirtualPlayerReady(virtualPlayer) then
		self:tryPlayBoatTimeline()
	else
		self:_waitAndPlayTimeline(virtualPlayer, 6)
	end
end

function GrabEggModeScene:ensureBoatCutsceneLayer()
	if IsNil(self.boatCutscene) or IsNil(self.boatCutscene.transform) then
		return
	end

	LuaUIUtils.safeSetGoLayer(self.boatCutscene.transform.gameObject, ClientConst.LayerDefine.LAYER_UI_SCENE)
end

function GrabEggModeScene:tryPlayBoatTimeline()
	if IsNil(self.boatCutscene) then
		return
	end

	self:ensureBoatCutsceneLayer()
	self.boatCutscene:TryPlayTimeline()
	self:setOriPos()
end

function GrabEggModeScene._isVirtualPlayerReady(entity)
	if not entity or not entity.eModel then
		return false
	end

	local state = entity.eModel:GetCurrentPlayableState(Const.COMPONENT_IDX_PLAYABLE, 2) or entity.eModel:GetCurrentPlayableState(Const.COMPONENT_IDX_PLAYABLE, 0)

	if IsNil(state) or state.Weight < 0.001 then
		return false
	end

	local modelView = entity.eModel.modelModelView

	return modelView and modelView:CheckRendererLoaded()
end

function GrabEggModeScene:_waitAndPlayTimeline(entity, retryLeft)
	if retryLeft <= 0 then
		self:tryPlayBoatTimeline()

		return
	end

	self.delayPlayTimer = self:startTimer(function()
		if GrabEggModeScene._isVirtualPlayerReady(entity) then
			self:tryPlayBoatTimeline()
		else
			self:_waitAndPlayTimeline(entity, retryLeft - 1)
		end
	end, 0.5, false)
end

function GrabEggModeScene:setInitParam(param)
	if param == nil or param.sceneMode == nil then
		return
	end

	local sceneMode = param.sceneMode
	local modeData = INIT_PARAM[sceneMode]

	if modeData == nil then
		return
	end

	if NotNil(self.uiSceneEnv) and modeData.time then
		local h, m, s = unpack(modeData.time)

		self.uiSceneEnv:SetTodServerTime(h, m, s)
	end
end

function GrabEggModeScene:createTrackRefVirtualEntity(virtualEntityData)
	local virtualEntity = self:copyMainPlayer()

	virtualEntity.eModel:SetTransformParent(virtualEntityData.rootObject or self.boatCutscene.transform)
	virtualEntity.eModel:SetTransformLocalPosition()
	virtualEntity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	virtualEntity.eModel:SetTransformLocalScale()

	return virtualEntity and virtualEntity.eModel
end

function GrabEggModeScene:setMode(mode)
	self.mode = mode
end

function GrabEggModeScene:switchMode(mode)
	self.mode = mode
	self.transitionTime = 1

	if mode == 1 then
		self.vcCameraMode1.Priority = 10
		self.vcCameraMode2.Priority = 0
		self.vcCameraMode3.Priority = 0
		self.vcCameraMode4.Priority = 0
	elseif mode == 2 then
		self.vcCameraMode1.Priority = 0
		self.vcCameraMode2.Priority = 10
		self.vcCameraMode3.Priority = 0
		self.vcCameraMode4.Priority = 0
	elseif mode == 3 then
		self.vcCameraMode1.Priority = 0
		self.vcCameraMode2.Priority = 0
		self.vcCameraMode3.Priority = 10
		self.vcCameraMode4.Priority = 0
		self.transitionTime = 0
	elseif mode == 4 then
		self.vcCameraMode1.Priority = 0
		self.vcCameraMode2.Priority = 0
		self.vcCameraMode3.Priority = 0
		self.vcCameraMode4.Priority = 10
		self.transitionTime = 0
	end

	self:setOriPos()
end

function GrabEggModeScene:setOriPos()
	local virtualPlayer = self.entPool[pg.me.uid]

	if virtualPlayer and GrabEggModeScene._isVirtualPlayerReady(virtualPlayer) then
		local modeData = MODE_TIME[self.mode]
		local position = Vector3.New(unpack(modeData.boatPos))
		local rotation = Quaternion.Euler(unpack(modeData.boatRot))

		self.boatCutscene:SetPositionAndRotation(position, rotation, self.transitionTime)
	end
end

function GrabEggModeScene:createEggs(transEggs)
	for i = 1, #transEggs do
		local data = transEggs[i]

		self.eggs[i] = ClientUtils.createVirtualGrabEggEntity(data.templateId, Vector3(0, 0.5, 0), 1, self.colliderTransform, data.patternType, data.patternColorType)
	end
end

function GrabEggModeScene:onActiveChanged(active)
	if self.mainPlayer then
		self.mainPlayer.eModel:SetActive(active)
	end

	if NotNil(self.camera) and NotNil(self.camera.gameObject) then
		self.camera.gameObject:SetActiveEx(active)
	end

	if active and NotNil(self.boatCutscene) then
		local virtualPlayer = self.entPool[pg.me.uid]

		if virtualPlayer and GrabEggModeScene._isVirtualPlayerReady(virtualPlayer) then
			self:tryPlayBoatTimeline()
		end
	end
end

function GrabEggModeScene:onDestroy()
	for k, v in pairs(self.eggs) do
		ClientUtils.safeDestroy(v)
	end
end

return GrabEggModeScene
