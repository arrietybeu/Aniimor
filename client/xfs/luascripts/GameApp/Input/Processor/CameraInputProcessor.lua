-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\CameraInputProcessor.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local Time = require("Core.Common.Time")
local CameraInputProcessor = Class.LightClass("CameraInputProcessor", BaseInputProcessor)

function CameraInputProcessor:onInit()
	BaseInputProcessor.onInit(self)

	self.actionMapKey = HotkeyConst.INPUT_MAP_ACTION_KEY.Camera
	self.viewAxis = {
		x = 0,
		y = 0
	}
	self.gyroAxis = {
		x = 0,
		y = 0
	}
	self.lastOutputAxisX = nil
	self.lastOutputAxisY = nil
end

function CameraInputProcessor:onEnableInputMap(mapName, enabled)
	self:onInputEnable(enabled)
end

function CameraInputProcessor:onCursorModeChange()
	self:onInputEnable(self.isEnabled)
end

function CameraInputProcessor:onInputEnable(enable)
	if enable then
		if pg.game.input:isCursorNormalMode() then
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, false)
		else
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, true)
		end
	else
		self:setViewAxis(0, 0)
	end
end

function CameraInputProcessor:getEnableViewCtrl()
	return pg.game.input:checkEnableViewControl()
end

function CameraInputProcessor:getEnableGyro()
	return pg.game.input:checkEnableViewControlGyro()
end

function CameraInputProcessor:handleCameraZoomAction(inputInfo)
	if inputInfo.phase == "Performed" then
		local deltaZoom = inputInfo.valueVec2.y

		if not pg.game.input:cameraZoomValidCondition(inputInfo) then
			return
		end

		pg.global.inputMgr:SetZoom(deltaZoom)
		pg.game.input:handleZoom(deltaZoom, HotkeyConst.ZoomContext.Input)
	elseif inputInfo.phase == "Canceled" then
		pg.global.inputMgr:SetZoom(0)
	end
end

function CameraInputProcessor:handleViewAxisAction(inputInfo)
	if pg.global.ui:runPlatformByMobile() then
		return
	end

	if inputInfo.phase == "Performed" then
		if not self:getEnableViewCtrl() then
			self:setViewAxis(0, 0)

			return
		end

		local vec = inputInfo.valueVec2

		if vec.x ~= 0 or vec.y ~= 0 then
			local camera = pg.game.camera
			local playerCameraMode = camera and camera.playerCameraMode

			if playerCameraMode then
				playerCameraMode:onMouseViewInput(vec)
			end
		end

		if Time.unscaledDeltaTime > 0 then
			Vector3.enableCreateFromCache()

			local lookX, lookY = pg.game.input:applyLookInversion(vec.x, vec.y)
			local mouseX = 30 * lookX / (Screen.height * Time.unscaledDeltaTime)
			local mouseY = 30 * lookY / (Screen.height * Time.unscaledDeltaTime)

			Vector3.disableCreateFromCache()
			self:setViewAxis(mouseX, mouseY)
		else
			self:setViewAxis(0, 0)
		end
	elseif inputInfo.phase == "Canceled" then
		self:setViewAxis(0, 0)
	end
end

function CameraInputProcessor:handleViewAxisGamepadAction(inputInfo)
	if pg.game.input:isUsingGamepad() and pg.global.ui.photo.isLeftShoulderPressed then
		return true
	end

	if inputInfo.phase == "Performed" then
		if not self:getEnableViewCtrl() then
			self:setViewAxis(0, 0)

			return
		end

		local vec = inputInfo.valueVec2

		if vec.x ~= 0 or vec.y ~= 0 then
			local camera = pg.game.camera
			local playerCameraMode = camera and camera.playerCameraMode

			if playerCameraMode then
				playerCameraMode:onManualViewInput()
			end
		end

		local lookX, lookY = pg.game.input:applyLookInversion(vec.x, vec.y)
		local axisX = 90 * lookX
		local axisY = 67.5 * lookY

		self:setViewAxis(axisX, axisY)
	elseif inputInfo.phase == "Canceled" then
		self:setViewAxis(0, 0)
	end
end

function CameraInputProcessor:handleDialogueViewAxisAction(inputInfo)
	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		return
	end

	if inputInfo.phase == "Performed" then
		if Time.unscaledDeltaTime > 0 then
			local lookX, lookY = pg.game.input:applyLookInversion(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
			local mouseX = 15 * lookX / (Screen.height * Time.unscaledDeltaTime)
			local mouseY = 15 * lookY / (Screen.height * Time.unscaledDeltaTime)
			local maxSpeed = 1800

			self.viewAxis.x = math.clamp(mouseX, -maxSpeed, maxSpeed)
			self.viewAxis.y = math.clamp(mouseY, -maxSpeed, maxSpeed)

			if not self:getEnableGyro() then
				self.gyroAxis.x = 0
				self.gyroAxis.y = 0
			end

			local viewAxisX = self.viewAxis.x - self.gyroAxis.y * 30
			local viewAxisY = self.viewAxis.y + self.gyroAxis.x * 10

			self:applyViewAxis(viewAxisX, viewAxisY)
		else
			self:setViewAxis(0, 0)
		end
	elseif inputInfo.phase == "Canceled" then
		self:setViewAxis(0, 0)
	end
end

function CameraInputProcessor:setViewAxis(x, y)
	local maxSpeed = 1800
	local clampedX = math.clamp(x, -maxSpeed, maxSpeed)
	local clampedY = math.clamp(y, -maxSpeed, maxSpeed)

	if self.viewAxis.x == clampedX and self.viewAxis.y == clampedY and self:getEnableViewCtrl() then
		return
	end

	self.viewAxis.x = clampedX
	self.viewAxis.y = clampedY

	self:updateViewAxis()
end

function CameraInputProcessor:setViewAxisByDelta(deltaX, deltaY)
	if Time.unscaledDeltaTime > 0 then
		local x = deltaX / Time.unscaledDeltaTime
		local y = deltaY / Time.unscaledDeltaTime

		self:setViewAxis(x, y)
	else
		self:setViewAxis(0, 0)
	end
end

function CameraInputProcessor:setViewAxisByDeltaPixel(deltaX, deltaY)
	if Time.unscaledDeltaTime > 0 then
		local deltaHeight = Screen.height * Time.unscaledDeltaTime
		local x = 60 * deltaX / deltaHeight
		local y = 60 * deltaY / deltaHeight

		self:setViewAxis(x, y)
	else
		self:setViewAxis(0, 0)
	end
end

local GYRO_AXIS_THRESHOLD = 0.0001

function CameraInputProcessor:setGyroAxis(x, y, force)
	if not force and math.abs(self.gyroAxis.x - x) < GYRO_AXIS_THRESHOLD and math.abs(self.gyroAxis.y - y) < GYRO_AXIS_THRESHOLD then
		return
	end

	self.gyroAxis.x = x
	self.gyroAxis.y = y

	self:updateViewAxis()
end

function CameraInputProcessor:applyViewAxis(viewAxisX, viewAxisY)
	if self.lastOutputAxisX ~= nil and self.lastOutputAxisY ~= nil and self.lastOutputAxisX == viewAxisX and self.lastOutputAxisY == viewAxisY then
		return
	end

	self.lastOutputAxisX = viewAxisX
	self.lastOutputAxisY = viewAxisY

	pg.global.inputMgr:SetViewAxis(viewAxisX, viewAxisY)
end

function CameraInputProcessor:isManualViewInputActive(thresholdSqr)
	local x = self.lastOutputAxisX or 0
	local y = self.lastOutputAxisY or 0

	return thresholdSqr <= x * x + y * y
end

function CameraInputProcessor:updateViewAxis()
	if not self:getEnableViewCtrl() then
		self.viewAxis.x = 0
		self.viewAxis.y = 0
		self.gyroAxis.x = 0
		self.gyroAxis.y = 0
	elseif not self:getEnableGyro() then
		self.gyroAxis.x = 0
		self.gyroAxis.y = 0
	end

	local viewAxisX = self.viewAxis.x - self.gyroAxis.y * 30
	local viewAxisY = self.viewAxis.y + self.gyroAxis.x * 10

	self:applyViewAxis(viewAxisX, viewAxisY)
end

function CameraInputProcessor:handleEnableViewCtrlAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.input:isCursorNormalMode() then
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, true)
		end
	elseif inputInfo.phase == "Canceled" and pg.game.input:isCursorNormalMode() then
		pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, false)
	end
end

function CameraInputProcessor:handleShowCursorAction(inputInfo)
	if inputInfo.phase == "Performed" then
		if pg.game.input:isCursorActMode() then
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, false)
		end
	elseif inputInfo.phase == "Canceled" and pg.game.input:isCursorActMode() then
		pg.game.input:setLockCursor(ClientConst.LockCursorKey.Camera, true)
	end
end

return CameraInputProcessor
