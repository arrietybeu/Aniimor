-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\FurnitureStoreScene.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local GameObject = CS.UnityEngine.GameObject
local FurnitureStoreScene = Class.LightClass("FurnitureStoreScene", UISceneBase)
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientHomeFurnitureStoreEntity = require("Entities.SpaceEntities.Home.ClientHomeFurnitureStoreEntity")
local fingerGestures = fingerGestures

function FurnitureStoreScene:onStart()
	self.modelDistance = 10
	self.objectReference = self.scene.transform:Find("Global"):GetComponent("ObjectReference")
	self.targetCamera = self.objectReference:GetRefValue("camera")
	self.modelContainer = self.objectReference:GetRefValue("itemContainer")
	self.targetCamera.transform.localPosition = Vector3.New(0, 0.3, 3.6)

	self.targetCamera:GetComponent("XCameraData"):SetFov(30)
	pg.global.cameraMgr:SetCameraStackWithUICamera(self.targetCamera)

	self.models = {}
	self.curShowModelResId = nil
end

function FurnitureStoreScene:setGestureOptions(targetName, allowEmptyTarget, touchStartCallback)
	self.gestureTargetName = targetName
	self.allowEmptyGestureTarget = allowEmptyTarget == true
	self.gestureTouchStartCallback = touchStartCallback
end

function FurnitureStoreScene:isGestureTarget(gesture)
	local pickedUIElement = gesture and gesture.pickedUIElement

	if not pickedUIElement then
		return self.allowEmptyGestureTarget
	end

	return pickedUIElement.name == (self.gestureTargetName or "GestureRayBox")
end

function FurnitureStoreScene:initGestures()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnSwipe(gesture)
		if self:isGestureTarget(gesture) then
			self:onSwipeModel(gesture.deltaPosition)
		end
	end

	function fingerGestures.luaOnTouchStart(gesture)
		if not self:isGestureTarget(gesture) then
			return
		end

		if self.gestureTouchStartCallback then
			self.gestureTouchStartCallback()
		end
	end

	self:claimGlobalGesture()
end

function FurnitureStoreScene:disableGestures()
	if self:tryReleaseGlobalGesture() then
		fingerGestures.luaOnSwipe = nil
		fingerGestures.luaOnTouchStart = nil

		fingerGestures.DeActive()
	end
end

function FurnitureStoreScene:setRawImage(rawImage)
	self.targetCamera.targetTexture = rawImage.texture
end

function FurnitureStoreScene:showModel(data, onModelLoadedCallback)
	local resId = data.modelResId

	self.endX = nil
	self.endY = nil

	self:hideOldModel(self.curShowModelResId)

	self.pendingShowModelResId = resId

	local entity = self.models[resId]

	if entity then
		if entity.modelReady then
			self:showOldModel(resId, data)

			if onModelLoadedCallback then
				onModelLoadedCallback()
			end
		end

		return
	end

	entity = ClientHomeFurnitureStoreEntity.new()
	self.models[resId] = entity

	entity:setConfigData(data)
	entity:setModelLayer()

	function entity.modelLoadedCallback()
		entity.modelReady = true

		if self.pendingShowModelResId ~= resId then
			return
		end

		self:showOldModel(resId, data)

		if onModelLoadedCallback then
			onModelLoadedCallback()
		end
	end

	entity:start()

	local initInfo = {}

	entity:init(initInfo)
	entity:postInit(initInfo)
end

function FurnitureStoreScene:onSwipeModel(deltaPosition)
	local entity = self.models[self.curShowModelResId]

	if not entity then
		return
	end

	local dtX = deltaPosition.x
	local dtY = deltaPosition.y
	local data = entity:getConfigData()
	local oldRot = entity.eModel.itemModel.transform.localRotation.eulerAngles

	if self.endY == nil then
		self.endY = oldRot.y
	end

	self.endY = self.endY - dtX * 0.2
	self.endY = self:parseAngle(self.endY, data.rotationYLimit)

	if self.endX == nil then
		self.endX = oldRot.x
	end

	entity.eModel.itemModel.transform.localRotation = Quaternion.Euler(self.endX, self.endY, 0)
end

function FurnitureStoreScene:parseAngle(angle, range)
	if angle < -360 or angle > 360 then
		angle = angle % 360
	end

	if angle < -180 then
		angle = angle + 360
	end

	if angle > 180 then
		angle = angle - 360
	end

	return angle
end

function FurnitureStoreScene:showOldModel(resId, data)
	if resId == nil then
		return
	end

	if not self.models[resId] then
		return
	end

	self.curShowModelResId = resId

	self.models[resId].eModel:SetActive(true)

	if data then
		self.models[resId].eModel:SetTransformParent(self.modelContainer)
		self.models[resId].eModel:SetTransformLocalPosition()
		self.models[resId]:setScaleNumber(data.modelScale)

		if self.models[resId].eModel.itemModel then
			self.models[resId].eModel.itemModel.transform.localPosition = Vector3.New(data.positionOffset[1], data.positionOffset[2], data.positionOffset[3])
			self.models[resId].eModel.itemModel.transform.localRotation = Quaternion.Euler(data.modelRotationInit[1], data.modelRotationInit[2], data.modelRotationInit[3])
		end
	end

	self:initGestures()
end

function FurnitureStoreScene:hideOldModel(resId)
	if resId == nil then
		return
	end

	if not self.models[resId] then
		return
	end

	self.models[resId].eModel:SetActive(false)
end

function FurnitureStoreScene:hideCurModel()
	self:hideOldModel(self.curShowModelResId)
end

function FurnitureStoreScene:onDestroy()
	pg.global.cameraMgr.vcManager:RemoveSubCameraGroup(self.name)

	for _, v in pairs(self.models) do
		ClientUtils.safeDestroy(v)
	end

	table.clear(self.models)
	self:disableGestures()
	self:setGestureOptions(nil, false, nil)
end

return FurnitureStoreScene
