-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Camera\\CameraMode\\PhotoCamera\\StudioFreeCameraMode.lua

local CameraConst = require("GameApp.Camera.CameraConst")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local StackFramingCameraMode = require("GameApp.Camera.CameraMode.StackFramingCameraMode")
local ClientConst = require("Const.ClientConst")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local StudioFreeCameraMode = Class.OldLightClass("StudioFreeCameraMode", StackFramingCameraMode)
local pendingStudioSkyRestore

local function cancelStudioSkyRestore()
	local task = pendingStudioSkyRestore

	pendingStudioSkyRestore = nil

	if task and task.frameId then
		TimerManager.delFrameCb(task.frameId)
	end
end

local function scheduleStudioSkyRestore(studioCamera)
	cancelStudioSkyRestore()

	local game = pg.game
	local cameraMgr = pg.global and pg.global.cameraMgr
	local world = cameraMgr and cameraMgr.worldCameraInst

	if not game or not game.camera or IsNil(world) then
		return
	end

	local cameraSystem = game.camera
	local task = {}

	pendingStudioSkyRestore = task

	local function waitForWorld(pauseTimeout)
		if pauseTimeout then
			task.deadline = nil
		end

		task.stableFrames, task.renderedFrame = 0
	end

	local function tryRestore()
		if pg.game ~= game or game.camera ~= cameraSystem or not pg.global or pg.global.cameraMgr ~= cameraMgr or IsNil(world) or cameraMgr.worldCameraInst ~= world then
			return true
		end

		local rootGroup = cameraMgr.vcManager and cameraMgr.vcManager.rootGroup
		local uiScene = game.uiScene

		if not uiScene or #uiScene.uiSceneStack > 0 or not cameraSystem.enableWorldCamera or not world.isActiveAndEnabled or not rootGroup or not IsNil(rootGroup.extraCamera) or rootGroup.targetCamera ~= world or not IsNil(studioCamera) and studioCamera.isActiveAndEnabled then
			return waitForWorld(true)
		end

		local cameraData = world:GetComponent("XCameraData")

		if IsNil(cameraData) or not cameraData.enableRender then
			return waitForWorld(true)
		end

		task.deadline = task.deadline or Time.realtimeSinceStartup + 10

		if Time.realtimeSinceStartup >= task.deadline then
			return true
		end

		local pipeline = CS.XRender.Pipeline.XRenderPipeline.currentPipeline

		if not pipeline then
			return waitForWorld()
		end

		local found, env = pipeline.EnvMgrV2:TryGetFinalEnv()

		if not found or IsNil(env) or not env.isActiveAndEnabled or env.gameObject.layer == ClientConst.LayerDefine.LAYER_UI_SCENE then
			return waitForWorld()
		end

		if task.env and (task.env ~= env or task.pipeline ~= pipeline) then
			return true
		end

		task.env, task.pipeline = env, pipeline

		local sky = env:GetComponentInChildren(typeof(CS.XRender.Modules.ImageBasedFilter.SkyLightComponent))

		if IsNil(sky) or not sky.isActiveAndEnabled then
			return waitForWorld()
		end

		if not sky.manuallyCapture or sky.m_AlwaysCapture then
			return true
		end

		local atmosphere = env:GetComponentInChildren(typeof(CS.XRender.Modules.AVolumetric.AtmosphereComponent))
		local sun = env:GetComponentInChildren(typeof(CS.XRender.Pipeline.Lighting.XLightData))

		if IsNil(atmosphere) or not atmosphere.isActiveAndEnabled or IsNil(sun) or not sun.isActiveAndEnabled then
			return waitForWorld()
		end

		local config = CS.XRender.Pipeline.Config.XRenderConfigs.Get()

		if not config or not config.supportSkyAtmosphere then
			return true
		end

		local flags = CS.XRender.Pipeline.Settings.XCameraShowFlags.AggregateCameraShowFlags(pipeline, cameraData.m_CameraShowFlags, world, cameraData)

		if not flags.m_EnableSkyAtmosphere or not flags.m_EnableSkyLight then
			return true
		end

		local captureState = CS.XRender.Modules.ImageBasedFilter.UpdateCapturedCubemapTask

		if sky.state ~= captureState.NotReady then
			return waitForWorld()
		end

		if task.sky ~= sky or task.atmosphere ~= atmosphere or task.sun ~= sun then
			task.sky, task.atmosphere, task.sun = sky, atmosphere, sun

			waitForWorld()
		end

		local renderedFrame = CS.UnityEngine.Time.renderedFrameCount

		if task.renderedFrame == nil then
			task.renderedFrame, task.stableFrames = renderedFrame, 0

			return
		end

		if task.renderedFrame == renderedFrame then
			return
		end

		task.renderedFrame = renderedFrame
		task.stableFrames = task.stableFrames + 1

		if task.stableFrames < 3 then
			return
		end

		sky.state = captureState.Capture1

		return true
	end

	task.frameId = TimerManager.addRepeatNextFrameCb(function()
		if pendingStudioSkyRestore ~= task then
			return
		end

		local ok, done = pcall(tryRestore)

		if not ok or done then
			cancelStudioSkyRestore()

			if not ok then
				error(done)
			end
		end
	end)
end

function StudioFreeCameraMode:onCtor()
	cancelStudioSkyRestore()
	StackFramingCameraMode.onCtor(self)

	self.stackCameraObj = nil
	self.renderCamera = nil
end

function StudioFreeCameraMode:onDestroy()
	StackFramingCameraMode.onDestroy(self)

	if self.cameraMode ~= nil and self.cameraMode.isActivated and not IsNil(self.renderCamera) then
		local rootGroup = pg.global.cameraMgr.vcManager.rootGroup

		if rootGroup.extraCamera == self.renderCamera and not IsNil(rootGroup.targetCamera) then
			pg.game.camera:resetUICameraBlendStack()

			rootGroup.extraCamera = nil

			rootGroup.targetCamera.gameObject:SetActiveEx(true)
		end
	end

	if not IsNil(self.renderCamera) then
		scheduleStudioSkyRestore(self.renderCamera)
	end
end

function StudioFreeCameraMode:getModeClass()
	return CS.FunPlus.WorldX.VirtualCamera.PhotoCameraMode
end

function StudioFreeCameraMode:getCameraName()
	return CameraConst.CAMERA_NAME_STUDIO_FREE
end

function StudioFreeCameraMode:initPhotoCamera(renderCamera, playerTransform)
	if self.cameraMode ~= nil and not IsNil(renderCamera) then
		self.renderCamera = renderCamera

		self.cameraMode:InitPhotoCameraForStudio(renderCamera, playerTransform)
		self.cameraMode:EnableFishEye(false)
	end
end

function StudioFreeCameraMode:releaseCameraLights()
	if self.cameraMode ~= nil then
		self.cameraMode:ReleaseCameraLights()
	end
end

function StudioFreeCameraMode:setFollowTransform(transform)
	if self.cameraMode ~= nil then
		self.cameraMode.followTransform = transform

		pg.game.camera:syncPhotoCameraRotateSpeed(self.cameraMode)
	end
end

function StudioFreeCameraMode:move(x, y, z)
	self.cameraMode:DoMove(x, y, z)
end

function StudioFreeCameraMode:setMoveRange(centerTrans, bottomRadius, topRadius, height, minHeight)
	if IsNil(centerTrans) then
		return
	end

	self.cameraMode:SetMoveRange(centerTrans, bottomRadius, topRadius, height, 0, 0.5, 0.3, 0.1, 0.1, 0.8, 0.8, 19, minHeight or 0.2)
end

function StudioFreeCameraMode:rotate(x, y)
	self.cameraMode:DoRotate(x, y)
end

function StudioFreeCameraMode:rotateZ(z)
	self.cameraMode:DoRotateZ(z)
end

function StudioFreeCameraMode:zoom(fov)
	self.cameraMode:SetFov(fov)
end

function StudioFreeCameraMode:getPlanePos(renderCamera, screenPos, planeY)
	if IsNil(renderCamera) then
		return false, nil
	end

	return self.cameraMode:GetStudioPlanePos(renderCamera, screenPos, planeY)
end

function StudioFreeCameraMode:setEnableCameraLookAt(enable, entity)
	if not entity then
		return
	end

	local lookAtComponent = entity.eModel.ikLookAtComponent

	if lookAtComponent then
		lookAtComponent.enableCameraLookAt = false
	end

	if enable and not IsNil(self.renderCamera) and entity.lookAtCamera then
		entity:lookAtCamera(self.renderCamera, false)
	elseif enable and lookAtComponent then
		lookAtComponent.enableCameraLookAt = true
	end
end

function StudioFreeCameraMode:getLookAtPos(screenX, screenY, entity)
	if not entity or not entity.eModel then
		return nil
	end

	local posX, posY, posZ = entity.eModel:GetPositionAgentPosEx()

	return self.cameraMode:GetLookAtPos(screenX, screenY, Vector3(posX, posY, posZ))
end

function StudioFreeCameraMode:reset()
	self.cameraMode:Reset()
end

function StudioFreeCameraMode:asyncTrans(posX, posY, posZ, rotX, rotY, rotZ)
	self.cameraMode:AsyncTrans(posX, posY, posZ, rotX, rotY, rotZ)
end

function StudioFreeCameraMode:getFollowPosition()
	if IsNil(self.cameraMode.followTransform) then
		return nil
	end

	return self.cameraMode.followTransform.position
end

function StudioFreeCameraMode:getFollowEulerAngles()
	if IsNil(self.cameraMode.followTransform) then
		return nil
	end

	return self.cameraMode.followTransform.eulerAngles
end

function StudioFreeCameraMode:getFollowLocalPose()
	local t = self.cameraMode.followTransform

	if IsNil(t) then
		return nil, nil
	end

	local p, e = t.localPosition, t.localEulerAngles

	return {
		x = p.x,
		y = p.y,
		z = p.z
	}, {
		x = e.x,
		y = e.y,
		z = e.z
	}
end

function StudioFreeCameraMode:setFollowLocalPose(pos, rot)
	local t = self.cameraMode.followTransform

	if IsNil(t) or not pos or not rot then
		return
	end

	t.localPosition = Vector3(pos.x, pos.y, pos.z)
	t.localEulerAngles = Vector3(rot.x, rot.y, rot.z)
end

return StudioFreeCameraMode
