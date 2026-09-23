-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Scenes\\UIScenes\\HomeCarScene.lua

local Class = require("Core.Framework.Class")
local UISceneBase = require("GameApp.UIScene.UISceneBase")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCarScene = Class.LightClass("HomeCarScene", UISceneBase)
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local PlayableConst = require("Common.Const.PlayableConst")
local HomeCarComponentData = require("Data.home_car_component_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local HomelandConfigData = require("Data.homeland_config_data")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCarScene")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_HOME_CAR_RESET_ROTATION = "homeCarResetRotation"
local DoTweenAnimMgr = DoTweenAnimMgr
local fingerGestures = fingerGestures

HomeCarScene.ROTATE_SPEED = 3
HomeCarScene.DRAG_ROTATE_SENSITIVITY = 0.15

function HomeCarScene:onStart(info)
	local homeCarChild = self.scene.transform:GetChild(0)

	self.objectReference = homeCarChild:GetComponent("ObjectReference")
	self.camera = self.objectReference:GetRefValue("camera")
	self.root = self.objectReference:GetRefValue("root")
	self.mainPageTransform = self.objectReference:GetRefValue("mainPageTransform")
	self.upgradeCarTransform = self.objectReference:GetRefValue("upgradeCarTransform")
	self.upgradeDecorationTransform = self.objectReference:GetRefValue("upgradeDecorationTransform")
	self.modifyCarShapeTransform = self.objectReference:GetRefValue("modifyCarShapeTransform")
	self.mainPageLightTransform = self.objectReference:GetRefValue("mainPageLightTransform")
	self.upgradeDecorationLithgTransform = self.objectReference:GetRefValue("upgradeDecorationLithgTransform")
	self.modifyCarTopTransform = self.objectReference:GetRefValue("modifyCarTopTransform")
	self.HomePageRoot = self.objectReference:GetRefValue("HomePageRoot")
	self.curVCamera = nil
	self.pageId = nil
	self.isRotating = false
	self.blameInTime = 0.5
	self.homeCarMode = UIConst.HOMECAR_UPGRADE_TYPE.HomeCar

	self:createHomeCar()
	self:initVirtualCameraGroup()
	pg.game.camera:setUICameraObject(self.camera)
end

function HomeCarScene:showHomeCarNotObtained(needShow, cb)
	self:setHomeCarNotObtained(self.homeCar, needShow, cb)
	self:setHomeCarNotObtained(self.homeCarMirror, needShow)
end

function HomeCarScene:setHomeCarNotObtained(homeCar, needShow, cb)
	if not homeCar or not homeCar.eModel then
		return
	end

	local modelShaderView = homeCar.eModel.modelShaderView

	if modelShaderView then
		if needShow then
			modelShaderView:SetOverrideMaterial(AddressDataConst.HOME_CAR_PHANTOM_MAT, cb)
			modelShaderView:SetMultiPassRenderEnable(false)
		else
			modelShaderView:SetOverrideMaterial("")
			modelShaderView:SetMultiPassRenderEnable(true)
		end
	end
end

function HomeCarScene:showHomeCarDecorationNotObtained(resId, cb)
	if not self.homeCarDecoration or not self.homeCarDecoration.eModel then
		return
	end

	local modelShaderView = self.homeCarDecoration.eModel.modelShaderView

	if modelShaderView then
		if resId and resId ~= "" then
			modelShaderView:SetOverrideMaterial(AddressDataConst.HOME_CAR_PHANTOM_MAT, cb, resId)
			modelShaderView:SetMultiPassRenderEnable(false)
		else
			modelShaderView:SetOverrideMaterial("")
			modelShaderView:SetMultiPassRenderEnable(true)
		end
	end
end

function HomeCarScene:setSingleDecorationOutline(enable, resId)
	if not self.homeCarDecoration or not self.homeCarDecoration.eModel then
		return
	end

	local modelShaderView = self.homeCarDecoration.eModel.modelShaderView

	if self.enableDecorationOutline ~= enable or self.decorationResId ~= resId then
		self.decorationResId = resId
		self.enableDecorationOutline = enable

		if enable and resId then
			modelShaderView:ChangeEffectMaterial({
				AddressDataConst.HOMELAND_OUTLINE_GREEN_NC,
				AddressDataConst.HOMELAND_OUTLINE_BASE_NC
			}, nil, nil, resId)
		else
			modelShaderView:ChangeEffectMaterial({})
		end
	end
end

function HomeCarScene:initVirtualCameraGroup()
	self.cameraGoDict = {}

	local pageCameraTrans = {
		[UIConst.HOMECAR_MODE_IDX.MAINPAGE] = self.mainPageTransform,
		[UIConst.HOMECAR_MODE_IDX.UPGRADE] = self.upgradeCarTransform,
		[UIConst.HOMECAR_MODE_IDX.DECORATION] = self.upgradeDecorationTransform,
		[UIConst.HOMECAR_MODE_IDX.MODIFYSHAPE] = self.modifyCarShapeTransform,
		[UIConst.HOMECAR_MODE_IDX.MODIFYTOP] = self.modifyCarTopTransform
	}
	local cameraNames = {
		"VCamera1",
		"VCamera2",
		"VCamera3",
		"VCamera4",
		"VCamera5"
	}

	for pid, trans in pairs(pageCameraTrans) do
		for cIdx, name in ipairs(cameraNames) do
			local vcId = self:getVCameraId(pid, cIdx)
			local vcObj = trans:Find(name)

			if vcObj then
				local vc = vcObj:GetComponent("RefVirtualCameraBehavior")

				self.cameraGoDict[vcId] = vc.gameObject

				function vc.luaFinishBlend()
					return
				end

				self.cameraGoDict[vcId]:SetActiveEx(false)
			end
		end
	end
end

function HomeCarScene:getVCameraId(pageId, cameraModeId)
	return string.format("%s_%s", pageId, cameraModeId)
end

function HomeCarScene:switchCamera(pageId, cameraModeId, blendInTime)
	if not pageId then
		return
	end

	self.pageId = pageId

	self.HomePageRoot.gameObject:SetActiveEx(pageId == UIConst.HOMECAR_MODE_IDX.MAINPAGE)
	self:refreshPetEnt(pageId)

	cameraModeId = cameraModeId or 1

	local viewId = self:getVCameraId(pageId, cameraModeId)
	local vcCamera = self.cameraGoDict[viewId]

	if self.curVCamera ~= vcCamera then
		if self.curVCamera then
			self.curVCamera:SetActiveEx(false)
		end

		self.curVCamera = vcCamera

		local time = self.blameInTime

		if blendInTime then
			time = blendInTime
		end

		local vc = self.curVCamera:GetComponent("RefVirtualCameraBehavior")

		vc.blendInTime = time

		if self.curVCamera then
			self.curVCamera:SetActiveEx(true)
		end
	end
end

function HomeCarScene:refreshHomeCar(basicInfo, extraParam)
	if not basicInfo then
		return
	end

	extraParam = extraParam or {}

	local needUpgradeEffect = basicInfo.upgradeEndTs > 0 and basicInfo.needUpgradeEffect ~= false
	local oldNeedUpgradeEffect = self.basicInfo and self.basicInfo.upgradeEndTs > 0 and self.basicInfo.needUpgradeEffect ~= false
	local isSame = false

	if self.basicInfo and basicInfo.modelLevel == self.basicInfo.modelLevel and needUpgradeEffect == oldNeedUpgradeEffect then
		isSame = true

		for _, partId in pairs(Const.HOME_CAR_BASE_PART) do
			if basicInfo.carShapeInfo[partId] ~= self.basicInfo.carShapeInfo[partId] then
				isSame = false

				break
			end
		end
	end

	if isSame then
		return
	end

	self.basicInfo = Utils.deepCopyTable(basicInfo)
	self.basicInfo.isUIScene = true
	self.basicInfo.needShadow = not extraParam.needPhantom

	if self.homeCar then
		self:destroyPetEnt()
		self.homeCar:setShapeInfo(self.basicInfo, self.basicInfo.needUpgradeEffect ~= false)

		if self.homeCarMirror then
			self.homeCarMirror:setShapeInfo(self.basicInfo, self.basicInfo.needUpgradeEffect ~= false)
		end
	end
end

function HomeCarScene:createHomeCar()
	if not self.homeCar then
		self.homeCar = ClientUtils.createClientEntity("ClientVirtualHomeCar", VirtualEntUtils.getNewVirtualEntityId(), {
			camera = self.camera,
			uiScene = self
		})

		self.homeCar.eModel:SetTransformParent(self.root.transform, false)

		self.homeCarMirror = ClientUtils.createClientEntity("ClientVirtualHomeCar", VirtualEntUtils.getNewVirtualEntityId(), {
			camera = self.camera
		})

		self.homeCarMirror.eModel:SetTransformParent(self.root.transform, false)
		self.homeCarMirror.eModel:SetTransformLocalScale(1, -1, 1)
	end
end

function HomeCarScene:createPetEnt(parent)
	if not self.homeCar or not self.homeCar.eModel or not parent then
		return
	end

	if not self.homeCarPetEnt or not self.homeCarPetEnt.eModel or IsNil(CSEntityManager:GetGameObjectByActorId(self.homeCarPetEnt.actorId)) then
		self:destroyPetEnt()

		local ent = self:getSimpleEnt(HomelandConfigData.homeCarRewardPetId)

		if ent then
			self.homeCarPetEnt = ent

			function ent.modelLoadedCallback()
				self:refreshPetEnt()
			end

			local eModel = ent.eModel

			if eModel then
				eModel:SetTransformLocalPosition()
				eModel:SetTransformLocalRotation(0, 0, 0, 1)
				eModel:SetTransformLocalScale()
				ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)
				eModel:SetTransformParent(parent, false)
				ent:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
				self:runWhenAnimatorReady(ent, function()
					if not ent:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
						return
					end

					local state = ent.eModel:PlayAnimation(Const.COMPONENT_IDX_PLAYABLE, PlayableConst.IdleSpecial, 0)

					if state then
						state:SetLogicLoop(true)
					end
				end)
			end
		end
	end
end

function HomeCarScene:refreshPetEnt(pageId)
	if not self.homeCar or not self.homeCar.eModel then
		return
	end

	pageId = pageId or self.pageId

	if NotNil(self.homeCarPetEnt) then
		local active = pageId == UIConst.HOMECAR_MODE_IDX.MAINPAGE

		self.homeCarPetEnt:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, false)

		if active then
			self.homeCarPetEnt:setActive(ClientConst.MODEL_VISIBLE_KEY.UIScene, true)
		end
	end
end

function HomeCarScene:destroyPetEnt()
	if self.homeCarPetEnt then
		ClientUtils.safeDestroy(self.homeCarPetEnt)

		self.homeCarPetEnt = nil
	end
end

function HomeCarScene:refreshHomeCarDecoration(basicInfo, floor)
	if not basicInfo then
		return
	end

	local oldModelLevel = self.decorationBasicInfo and HomeLandUtils.getHomeCarModelLevel(self.decorationBasicInfo.level)
	local newModelLevel = HomeLandUtils.getHomeCarModelLevel(basicInfo.level)
	local isSame = false

	if self.decorationBasicInfo and oldModelLevel == newModelLevel and floor == self.decorationBasicInfo.floor then
		isSame = true

		for tabId, info in pairs(HomeCarComponentData) do
			if basicInfo.carCompsLevel[tabId] ~= self.decorationBasicInfo.carCompsLevel[tabId] then
				isSame = false

				break
			end
		end
	end

	if isSame then
		return
	end

	self.decorationBasicInfo = Utils.deepCopyTable(basicInfo)
	self.decorationBasicInfo.floor = floor

	if self.homeCarDecoration then
		self.homeCarDecoration:setCarDecorationInfo(self.decorationBasicInfo)
	end
end

function HomeCarScene:createHomeCarDecoration()
	if not self.homeCarDecoration then
		self.homeCarDecoration = ClientUtils.createClientEntity("ClientVirtualHomeCarDecoration", VirtualEntUtils.getNewVirtualEntityId(), {
			camera = self.camera
		})

		self.homeCarDecoration.eModel:SetTransformParent(self.root.transform, false)
	end
end

function HomeCarScene:getSimpleEnt(templateId)
	local configData = PetProtoTypeData[templateId]
	local ent = ClientSimpleVirtualEntity.new()

	ent:setConfigData(configData)

	local initInfo = {
		templateId = templateId
	}

	ent:init(initInfo)
	ent:postInit(initInfo)
	ent:start()
	ent:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	ent:setRendererLod(0)
	ent:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)

	return ent
end

function HomeCarScene:changeHomeCarUpgradeMode(mode)
	if not self.homeCar or not self.homeCar.eModel then
		return
	end

	self.homeCarMode = mode

	if mode == UIConst.HOMECAR_UPGRADE_TYPE.Decoration then
		self.homeCar.eModel:SetActive(false)

		if self.homeCarMirror and self.homeCarMirror.eModel then
			self.homeCarMirror.eModel:SetActive(false)
		end

		self:createHomeCarDecoration()

		if self.homeCarDecoration and self.homeCarDecoration.eModel then
			self.homeCarDecoration.eModel:SetActive(true)
		end

		self.mainPageLightTransform.gameObject:SetActiveEx(false)
		self.upgradeDecorationLithgTransform.gameObject:SetActiveEx(true)
	elseif mode == UIConst.HOMECAR_UPGRADE_TYPE.HomeCar then
		self.homeCar.eModel:SetActive(true)

		if self.homeCarMirror and self.homeCarMirror.eModel then
			self.homeCarMirror.eModel:SetActive(true)
		end

		if self.homeCarDecoration and self.homeCarDecoration.eModel then
			self.homeCarDecoration.eModel:SetActive(false)
		end

		self.upgradeDecorationLithgTransform.gameObject:SetActiveEx(false)
		self.mainPageLightTransform.gameObject:SetActiveEx(true)
	end
end

function HomeCarScene:changeCarRotate(active)
	if active == true then
		self.isRotating = true

		self:_startRotateRuntime()
	elseif active == false then
		self.isRotating = false

		self:_stopRotateRuntime()
	end
end

function HomeCarScene:_startRotateRuntime()
	self:initCarGestures()

	if not self.rotateTimer then
		self.rotateTimer = pg.game.camera:addLateUpdateTimer(function()
			self:updateRotation()
		end)
	end
end

function HomeCarScene:_stopRotateRuntime()
	self:releaseCarGestures()

	if self.rotateTimer then
		pg.game.camera:removeLateUpdateTimer(self.rotateTimer)

		self.rotateTimer = nil
	end
end

function HomeCarScene:updateRotation()
	if not self.isRotating then
		return
	end

	local rootTransform = self.root and self.root.transform

	if rootTransform then
		local curEulerX, curEulerY, curEulerZ = rootTransform:GetLocalEulerAnglesEx()
		local deltaAngle = self.ROTATE_SPEED * Time.deltaTime

		rootTransform:SetLocalEulerAnglesEx(curEulerX, curEulerY + deltaAngle, curEulerZ)
	end
end

function HomeCarScene:resetCarRotation(duration)
	if not self.root then
		return
	end

	duration = duration or 0.5

	self:changeCarRotate(false)

	local rootTransform = self.root.transform
	local eulerX, eulerY, eulerZ = rootTransform:GetLocalEulerAnglesEx()

	if eulerY > 180 then
		eulerY = eulerY - 360
	end

	if duration == 0 then
		rootTransform:SetLocalEulerAnglesEx(eulerX, 0, eulerZ)
	else
		DoTweenAnimMgr.DoFloat(rootTransform.gameObject, eulerY, 0, LuaUIUtils.TweenId(ID_HOME_CAR_RESET_ROTATION), duration, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(value)
			eulerX, eulerY, eulerZ = rootTransform:GetLocalEulerAnglesEx()

			rootTransform:SetLocalEulerAnglesEx(eulerX, value, eulerZ)
		end, nil, false)
	end
end

function HomeCarScene:initCarGestures()
	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(false)

	function fingerGestures.luaOnSwipe(gesture)
		if self.isRotating and gesture.pickedUIElement and gesture.pickedUIElement.name == "GestureRayBox" then
			self:onDragRotateCar(gesture.deltaPosition)
		end
	end

	self:claimGlobalGesture()
end

function HomeCarScene:releaseCarGestures()
	if self:tryReleaseGlobalGesture() then
		fingerGestures.luaOnSwipe = nil

		fingerGestures.DeActive()
	end
end

function HomeCarScene:onDragRotateCar(deltaPosition)
	local rootTransform = self.root and self.root.transform

	if rootTransform then
		local deltaY = -deltaPosition.x * self.DRAG_ROTATE_SENSITIVITY

		rootTransform:RotateAround(rootTransform.position, Vector3.up, deltaY)
	end
end

function HomeCarScene:onActiveChanged(active)
	if active then
		if self.isRotating then
			self:_startRotateRuntime()
		end

		self:refreshPetEnt()
	else
		self:_stopRotateRuntime()
	end
end

function HomeCarScene:onDestroy()
	self:changeCarRotate(false)

	if self.root then
		DoTweenAnimMgr.Kill(self.root.transform.gameObject, LuaUIUtils.TweenId(ID_HOME_CAR_RESET_ROTATION), true)
	end

	if self.homeCar then
		ClientUtils.safeDestroy(self.homeCar)

		self.homeCar = nil
	end

	if self.homeCarMirror then
		ClientUtils.safeDestroy(self.homeCarMirror)

		self.homeCarMirror = nil
	end

	if self.homeCarDecoration then
		ClientUtils.safeDestroy(self.homeCarDecoration)

		self.homeCarDecoration = nil
	end

	self:destroyPetEnt()

	self.curVCamera = nil
	self.decorationBasicInfo = nil
	self.basicInfo = nil
	self.pageId = nil
end

return HomeCarScene
