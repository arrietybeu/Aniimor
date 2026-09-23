-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\ItemViewerScene.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local GameObject = CS.UnityEngine.GameObject
local ItemViewerScene = Class.LightClass("ItemViewerScene", UISceneBase)
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local EModelUtils = require("Entities.Utils.EModelUtils")
local fingerGestures = fingerGestures

function ItemViewerScene:onStart()
	self.modelDistance = 10
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.targetCamera = self.objectReference:GetRefValue("camera")
	self.modelContainer = self.objectReference:GetRefValue("itemContainer")
	self.targetCamera.transform.position = Vector3.New(0, 0, 0.5)

	self.targetCamera:GetComponent("XCameraData"):SetFov(30)
	pg.global.cameraMgr:SetCameraStackWithUICamera(self.targetCamera)

	self.models = {}
	self.curShowModelResId = nil
end

function ItemViewerScene:setRawImage(rawImage, width, height)
	self.renderTexture = pg.global.uiMgr:GetRenderTextureWithPool(width or 1080, height or 1080, 24)
	self.targetCamera.targetTexture = self.renderTexture
	rawImage.texture = self.renderTexture
end

function ItemViewerScene:clearTexture()
	if self.renderTexture ~= nil then
		self.targetCamera.targetTexture = nil

		pg.global.uiMgr:ReleaseRenderTextureWithPool(self.renderTexture)

		self.renderTexture = nil
	end
end

function ItemViewerScene:initGestures()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipe(gesture)
		self:onSwipeModel(gesture.deltaPosition)
	end
end

function ItemViewerScene:disableGestures()
	fingerGestures.DeActive()
end

function ItemViewerScene:showModel(data)
	local resId = data.modelResId

	self.endX = nil
	self.endY = nil

	self:hideOldModel(self.curShowModelResId)

	if self.models[resId] then
		self:showOldModel(resId)

		return
	end

	local entity = ClientSimpleVirtualEntity.new()

	entity:setConfigData(data)

	local initInfo = {}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	local modelView = entity.eModel.modelModelView

	function modelView.luaOnModelRefreshFinshed()
		self:onModelLoaded(entity)
	end

	self.models[resId] = entity

	self:showOldModel(resId)
end

function ItemViewerScene:onModelLoaded(entity)
	local data = entity:getConfigData()

	entity.eModel:SetTransformParent(self.modelContainer)

	local modelView = entity.eModel.modelModelView
	local scale = data.modelScale

	if scale == nil then
		local extents = modelView:GetBoundExtents()

		scale = 1 / (extents.y * 2)
	end

	entity:setScaleNumber(scale)

	if data.modelRotationInit then
		local rot = Quaternion.Euler(data.modelRotationInit[1], data.modelRotationInit[2], data.modelRotationInit[3])

		EModelUtils.setAgentRotation(entity, rot)
	end
end

function ItemViewerScene:onSwipeModel(deltaPosition)
	local entity = self.models[self.curShowModelResId]

	if not entity then
		return
	end

	local dtX = deltaPosition.x
	local dtY = deltaPosition.y
	local data = entity:getConfigData()

	if self.endY == nil then
		local _, _oey, _ = entity.eModel:GetPositionAgentLocalEulerEx()

		self.endY = _oey
	end

	self.endY = self.endY - dtX * 0.2
	self.endY = self:parseAngle(self.endY, data.rotationYLimit)

	entity.eModel:SetPositionAgentLocalEulerEx(0, self.endY, 0)

	if self.endX == nil then
		local oldRotX, oldRotY, oldRotZ = entity.eModel:GetTransformLocalRotationEulerAngles()

		self.endX = oldRotX
	end

	self.endX = self.endX - dtY * 0.2
	self.endX = self:parseAngle(self.endX, data.rotationXLimit or data.rotationZLimit)

	entity.eModel:SetTransformLocalEulerAngle(self.endX, 0, 0)
end

function ItemViewerScene:parseAngle(angle, range)
	if angle < -360 or angle > 360 then
		angle = angle % 360
	end

	if angle < -180 then
		angle = angle + 360
	end

	if angle > 180 then
		angle = angle - 360
	end

	if range == nil or #range < 2 then
		return angle
	end

	if angle < range[1] then
		angle = range[1]
	end

	if angle > range[2] then
		angle = range[2]
	end

	return angle
end

function ItemViewerScene:showOldModel(resId)
	if resId == nil then
		return
	end

	if not self.models[resId] then
		return
	end

	self.curShowModelResId = resId

	self.models[resId].eModel:SetActive(true)
	self:initGestures()
end

function ItemViewerScene:hideOldModel(resId)
	if resId == nil then
		return
	end

	if not self.models[resId] then
		return
	end

	self.models[resId].eModel:SetActive(false)
	self:disableGestures()
end

function ItemViewerScene:hideCurModel()
	self:hideOldModel(self.curShowModelResId)
end

function ItemViewerScene:onDestroy()
	self:clearTexture()
	pg.global.cameraMgr.vcManager:RemoveSubCameraGroup(self.name)

	for _, v in pairs(self.models) do
		ClientUtils.safeDestroy(v)
	end

	table.clear(self.models)
end

return ItemViewerScene
