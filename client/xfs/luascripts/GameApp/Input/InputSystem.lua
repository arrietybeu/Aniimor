-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\InputSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local hotkeyConst = require("Const.HotkeyConst")
local logger = LoggerManager.getLogger("InputSystem")
local HotkeyManager = CS.FunPlus.WorldX.GameApp.Input.HotkeyManager
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local GlobalData = require("Core.Client.GlobalData")
local SysConfigData = require("Data.sys_config_data")
local InputSystem = Class.LightClass("InputSystem", SystemBase)
local InputDeviceType = CS.FunPlus.WorldX.Manager.InputDeviceType
local GAMEPAD_SELECTED_STATE_FOCUS_LISTENER = "InputSystem_GamepadSelectedStateFocusVfx"
local GAMEPAD_SELECTED_STATE_EFFECT_DURATION = 0.5
local GAMEPAD_SELECTED_STATE_EFFECT_MAX_RETRY_FRAMES = 30
local GAMEPAD_SELECTED_STATE_EFFECT_NAMES = {
	UI_Com_SelectedState_Circle = true,
	UI_Com_SelectedState_Round = true,
	UI_Com_SelectedState_Round24 = true,
	UI_Com_SelectedState_Round64 = true,
	UI_Com_SelectedState_Round48 = true,
	UI_Com_SelectedState_Round32 = true,
	UI_Com_SelectedState_Hexagon_Thin = true,
	UI_Com_SelectedState_Hexagon = true
}

local function isGamepadSelectedStateEffectName(objectName)
	local cloneSuffix = "(Clone)"

	if string.sub(objectName, -#cloneSuffix) == cloneSuffix then
		objectName = string.sub(objectName, 1, #objectName - #cloneSuffix)
	end

	return GAMEPAD_SELECTED_STATE_EFFECT_NAMES[objectName] == true
end

local function isGamepadSelectedStateEffectUrl(defaultUrl)
	if type(defaultUrl) ~= "string" then
		return false
	end

	local prefabName = string.match(defaultUrl, "([^/\\\\]+)$")

	if prefabName and string.sub(prefabName, 1, 1) == "$" then
		prefabName = string.sub(prefabName, 2)
	end

	prefabName = prefabName and string.gsub(prefabName, "%.[Pp][Rr][Ee][Ff][Aa][Bb]$", "")

	return prefabName and GAMEPAD_SELECTED_STATE_EFFECT_NAMES[prefabName] == true
end

InputSystem.MobileGamepadLayoutMode = {
	TouchLayout = 1,
	DynamicSwitch = 0
}
InputSystem.RUMBLE_DEVICE_RATIO = {
	[InputDeviceType.XBox] = {
		1,
		1
	},
	[InputDeviceType.PSPad] = {
		1,
		1
	},
	[InputDeviceType.SwitchPad] = {
		1,
		1
	}
}
InputSystem.RUMBLE_DEVICE_RATIO_DEFAULT = {
	1,
	1
}
InputSystem.RUMBLE_DEVICE_TYPE_ID = {
	[InputDeviceType.PSPad] = 1,
	[InputDeviceType.XBox] = 2,
	[InputDeviceType.SwitchPad] = 3
}

function InputSystem:onCtor()
	return
end

function InputSystem:onInit()
	self.version = "1"
	self.isInputText = false
	self.lockCursor = false
	self.lockCameraZoom = false
	self.isGamepadCountReported = false
	self.showCursorData = {}
	self.hudShowVirtualMouseCursor = false
	self.viewControlData = {}
	self.forceEnableViewControlData = {}
	self.blockEventData = {}
	self.blockEventWithWhiteListData = {}
	self.blockInputData = {}
	self.moveHandlers = {}
	self.isBlockInput = false
	self.enableViewControlGyro = false
	self.viewControlDisableTime = -1
	self.gamepadInputMode = hotkeyConst.GAMEPAD_INPUT_CONTROL_MODE.CombineMode
	self.gyroscopeRatio = pg.game.setting:getFloat("CommonGyroscopeRatio", 1)

	self:registAllProcessor()
	self:initCursorIcon()
	self:initInputManagerCompleted()
	self:initVirtualMouseCursorSpeed()
	self:initMouseLookSettings()
	self:initGamepadLookSettings()
	self:applyMobileGamepadLayoutSetting()
	self:setCursorMode(ClientConst.CURSOR_MODE_ACT)
	self:initMapState()
	self:enableHudInput(true)
	self:initRumbleRatio()

	self.gyroscopeFrameCount = -1
	self.gyroscopeScaledX = 0
	self.gyroscopeScaledY = 0
	self.sandboxDisableInputInfo = {}

	local navMgr = pg.global.navMgr

	if navMgr then
		function navMgr.luaOnNavigationRegionChanged()
			self:refreshCursorState()
		end

		navMgr:AddLuaFocusCursorMovedListener(GAMEPAD_SELECTED_STATE_FOCUS_LISTENER, function()
			self:scheduleGamepadSelectedStateFocusEffect()
		end)
	end
end

function InputSystem:refreshTempInput()
	self:setInputMapEnabled(hotkeyConst.INPUT_MAP_ACTION.Temp, Utils.enableClientUseGm(pg.me), hotkeyConst.INPUT_BLOCK_FLAG.System)
end

function InputSystem:onClear()
	pg.global.inputMgr:ClearAllInputFlag()
	self:refreshTempInput()
end

function InputSystem:onDestroy()
	if self.gamepadSelectedStateFocusEffectFrameId then
		TimerManager.delFrameCb(self.gamepadSelectedStateFocusEffectFrameId)

		self.gamepadSelectedStateFocusEffectFrameId = nil
	end

	if self.gamepadSelectedStateFocusEffectTimerId then
		TimerManager.removeTimer(self.gamepadSelectedStateFocusEffectTimerId)

		self.gamepadSelectedStateFocusEffectTimerId = nil
	end

	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr.luaOnNavigationRegionChanged = nil

		navMgr:RemoveLuaFocusCursorMovedListener(GAMEPAD_SELECTED_STATE_FOCUS_LISTENER)
	end
end

function InputSystem:scheduleGamepadSelectedStateFocusEffect()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self.gamepadSelectedStateFocusEffectFrameId then
		TimerManager.delFrameCb(self.gamepadSelectedStateFocusEffectFrameId)
	end

	if self.gamepadSelectedStateFocusEffectTimerId then
		TimerManager.removeTimer(self.gamepadSelectedStateFocusEffectTimerId)

		self.gamepadSelectedStateFocusEffectTimerId = nil
	end

	local retryFrameCount = 0

	local function tryPlayFocusEffect()
		self.gamepadSelectedStateFocusEffectFrameId = nil

		if not pg.game.input:isUsingGamepad() then
			return
		end

		local currentNavMgr = pg.global.navMgr
		local focused = currentNavMgr and currentNavMgr.CurrentFocusedUContent

		if not focused or IsNil(focused) then
			return
		end

		local played = self:playGamepadSelectedStateFocusEffect(focused, false)

		if not played then
			retryFrameCount = retryFrameCount + 1

			if retryFrameCount < GAMEPAD_SELECTED_STATE_EFFECT_MAX_RETRY_FRAMES then
				self.gamepadSelectedStateFocusEffectFrameId = TimerManager.addNextFrameCb(tryPlayFocusEffect)
			end

			return
		end

		self.gamepadSelectedStateFocusEffectTimerId = TimerManager.addTimer(GAMEPAD_SELECTED_STATE_EFFECT_DURATION, function()
			self.gamepadSelectedStateFocusEffectTimerId = nil

			if not pg.game.input:isUsingGamepad() or IsNil(focused) then
				return
			end

			local settleNavMgr = pg.global.navMgr
			local settleFocused = settleNavMgr and settleNavMgr.CurrentFocusedUContent

			if settleFocused == focused then
				self:playGamepadSelectedStateFocusEffect(focused, true)
			end
		end)
	end

	self.gamepadSelectedStateFocusEffectFrameId = TimerManager.addNextFrameCb(tryPlayFocusEffect)
end

function InputSystem:playGamepadSelectedStateFocusEffect(focused, instant)
	if not pg.game.input:isUsingGamepad() then
		return false
	end

	if not focused then
		local navMgr = pg.global.navMgr

		focused = navMgr and navMgr.CurrentFocusedUContent
	end

	if not focused or IsNil(focused) then
		return false
	end

	local played = false
	local matchedContainers = {}
	local containers = focused.transform:GetComponentsInChildren(typeof(CS.XGUI.UContainer), true)

	for i = 0, containers.Length - 1 do
		local container = containers[i]

		if not IsNil(container) and isGamepadSelectedStateEffectUrl(container.defaultUrl) then
			local owner = container:GetComponentInParent(typeof(CS.XGUI.UContent))

			if owner == focused then
				container:InvokeCallbackWithChildren(CS.XGUI.EInvokeTime.Custom1, true, instant == true)

				played = true
				matchedContainers[container] = true
			end
		end
	end

	local widgets = focused.transform:GetComponentsInChildren(typeof(CS.XGUI.UWidget), true)

	for i = 0, widgets.Length - 1 do
		local widget = widgets[i]

		if not IsNil(widget) and isGamepadSelectedStateEffectName(widget.gameObject.name) then
			local parentContainer = widget:GetComponentInParent(typeof(CS.XGUI.UContainer))

			if IsNil(parentContainer) or not matchedContainers[parentContainer] then
				local owner = widget:GetComponentInParent(typeof(CS.XGUI.UContent))

				if owner == focused then
					widget:InvokeCallbackWithChildren(CS.XGUI.EInvokeTime.Custom1, true, instant == true)

					played = true
				end
			end
		end
	end

	return played
end

function InputSystem:onTick()
	pg.global.ui:tryRefreshModelWidget()

	if self.cameraProcessor ~= nil then
		if self.enableViewControlGyro and self:checkEnableViewControl() then
			local gyroX, gyroY = self:getGyroscopeXY()

			self.cameraProcessor:setGyroAxis(gyroX, gyroY)
		else
			self.cameraProcessor:setGyroAxis(0, 0, true)
		end
	end

	local now = Time.realSecondCache

	if self.lastTickTime and now - self.lastTickTime < 0.1 then
		return
	else
		self.lastTickTime = now

		self:updateLockBreakRumble()
	end
end

function InputSystem:getMessageBindMap()
	return {
		[MessageName.INPUT_TEXT_STATE_CHANGE] = "onInputText"
	}
end

function InputSystem:setViewAxis(x, y)
	self.cameraProcessor:setViewAxis(x, y)
end

function InputSystem:setViewAxisByDelta(deltaX, deltaY)
	deltaX, deltaY = self:applyLookInversion(deltaX, deltaY)

	self.cameraProcessor:setViewAxisByDelta(deltaX, deltaY)
end

function InputSystem:setViewAxisByDeltaPixel(pixelDeltaX, pixelDeltaY)
	pixelDeltaX, pixelDeltaY = self:applyLookInversion(pixelDeltaX, pixelDeltaY)
	pixelDeltaX = pixelDeltaX * SysConfigData.MAIN_CAMERA_RATE_MOBILE
	pixelDeltaY = pixelDeltaY * SysConfigData.MAIN_CAMERA_RATE_MOBILE

	self.cameraProcessor:setViewAxisByDeltaPixel(pixelDeltaX, pixelDeltaY)
end

function InputSystem:handleMoveEvent(x, y, z)
	self:onHandleMove(x, y, z)
end

function InputSystem:onHandleMove(x, y, z)
	local camera = pg.game.camera
	local playerCameraMode = camera and camera.playerCameraMode

	if playerCameraMode then
		playerCameraMode:onMoveInput(x, y)
	end

	local controller = pg.game.controller
	local followHandled = controller and controller.tryHandleMultiPetFollowInput and controller:tryHandleMultiPetFollowInput()

	if controller ~= nil and not followHandled then
		controller:onHandleMove(x, y, z)
	end
end

function InputSystem:handleZoom(zoomDelta, context)
	context = context or hotkeyConst.ZoomContext.Default

	if zoomDelta > 0.01 then
		pg.game.camera:zoom(-zoomDelta, context)
	elseif zoomDelta < -0.01 then
		pg.game.camera:zoom(-zoomDelta, context)
	end
end

function InputSystem:onInputText(isInput)
	self.isInputText = isInput

	if isInput then
		pg.global.inputMgr.isInputText = true
	else
		pg.global.inputMgr.isInputText = false
	end

	self:refreshCursorState()
end

function InputSystem:initCursorIcon()
	pg.global.inputMgr:SetCursorIcon("Textures/cursor", false)
end

function InputSystem:registAllProcessor()
	self.mapProcessor = {}

	for _, mapName in pairs(hotkeyConst.INPUT_MAP_ACTION) do
		local requireStrArr = {
			"GameApp.Input.Processor.",
			mapName,
			"InputProcessor"
		}
		local processorClass = require(table.concat(requireStrArr))

		self.mapProcessor[mapName] = processorClass.new(mapName)

		self.mapProcessor[mapName]:onInit()
	end

	self.cameraProcessor = self:getInputMapProcessor(hotkeyConst.INPUT_MAP_ACTION_KEY.Camera)
	self.skillInputProcessor = self:getInputMapProcessor(hotkeyConst.INPUT_MAP_ACTION_KEY.Skill)
end

function InputSystem:manuallyTriggerAction(actionPath)
	if pg.global.inputMgr:ManuallyTriggerAction(actionPath, "Performed") then
		pg.global.inputMgr:ManuallyTriggerAction(actionPath, "Canceled")

		return true
	end

	return false
end

function InputSystem:triggerWaitAction(inputControl, excludeActions)
	excludeActions = excludeActions or {}

	if pg.global.inputMgr:TriggerWaitAction(inputControl, excludeActions) then
		return true
	end

	return false
end

function InputSystem:setInputActionEnabled(actionPath, enable, flag)
	if flag == nil then
		return
	end

	pg.global.inputMgr:SetInputActionEnabled(actionPath, enable, flag)
end

function InputSystem:enableInputAction(actionPath, flag)
	if flag == nil then
		return
	end

	pg.global.inputMgr:EnableInputAction(actionPath, flag)
end

function InputSystem:disableInputAction(actionPath, flag)
	if flag == nil then
		return
	end

	pg.global.inputMgr:DisableInputAction(actionPath, flag)
end

function InputSystem:setInputMapEnabled(mapName, enable, flag)
	flag = flag or hotkeyConst.INPUT_BLOCK_FLAG.Default

	pg.global.inputMgr:SetInputMapEnabled(mapName, enable, flag)
end

function InputSystem:setAllInputMapEnabled(enable, flag)
	flag = flag or hotkeyConst.INPUT_BLOCK_FLAG.Default

	for _, mapName in pairs(hotkeyConst.INPUT_MAP_ACTION) do
		pg.global.inputMgr:SetInputMapEnabled(mapName, enable, flag)
	end

	if enable and flag == hotkeyConst.INPUT_BLOCK_FLAG.Teleport then
		self:refreshSwitchCatchModeInput()
	end
end

function InputSystem:handleActionTriggered(inputInfo)
	local ret = true
	local processor = self:getInputMapProcessor(inputInfo.actionMapName)

	if processor ~= nil then
		ret = processor:handleActionTriggered(inputInfo)
	end

	return ret
end

function InputSystem:onActionTriggeredFinished(inputInfo, needPass)
	if (not needPass or inputInfo.handled) and inputInfo.phase == "Performed" then
		facade:SendMessageCommand(MessageName.INPUT_ACTION_TRIGGERED, {
			inputInfo = inputInfo
		})
	end
end

function InputSystem:getInputMapProcessor(mapName)
	return self.mapProcessor[mapName]
end

function InputSystem:onEnableInputMap(mapName, enabled)
	local processor = self:getInputMapProcessor(mapName)

	if processor ~= nil then
		processor:enableInputMap(mapName, enabled)

		return
	end
end

function InputSystem:initInputManagerCompleted()
	local commonMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Common

	self:setInputMapEnabled(commonMapKey, true, hotkeyConst.INPUT_BLOCK_FLAG.Default)

	local tempMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Temp

	self:setInputMapEnabled(tempMapKey, true, hotkeyConst.INPUT_BLOCK_FLAG.Default)
	self:enableCameraInput(true)
end

function InputSystem:enableControlInput(enable, flag)
	self:enablePlayerInput(enable, flag)
	self:enableSkillInput(enable, flag)
	self:enableCatchInput(enable, flag)
	self:enablePetInput(enable, flag)
end

function InputSystem:initMapState()
	self:enableBallDriveInput(false)
	self:enablePhotoInput(false)
end

function InputSystem:resetAllActions(excludeActions)
	pg.global.ui:refreshModelWidget()
	pg.global.inputMgr:ResetAllActions(excludeActions)
end

function InputSystem:enableLevelBlockInput(mapName, enable, graphName)
	if graphName then
		if enable then
			self.sandboxDisableInputInfo[graphName] = nil
		else
			self.sandboxDisableInputInfo[graphName] = true
		end
	end

	local shouldDisable = Utils.isEmptyTable(self.sandboxDisableInputInfo)

	self:setInputMapEnabled(mapName, shouldDisable, hotkeyConst.INPUT_BLOCK_FLAG.LevelNode)
end

function InputSystem:enablePlayerInput(enable, flag)
	local playerMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Player

	self:setInputMapEnabled(playerMapKey, enable, flag)
end

function InputSystem:enablePetInput(enable, flag)
	local petMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Pet

	self:setInputMapEnabled(petMapKey, enable, flag)
end

function InputSystem:enableCameraInput(enable, flag)
	local cameraMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Camera

	self:setInputMapEnabled(cameraMapKey, enable, flag)
end

function InputSystem:enableSkillInput(enable, flag)
	local skillMapKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Skill

	self:setInputMapEnabled(skillMapKey, enable, flag)
end

function InputSystem:enableAimInput(enable, flag)
	local aimKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Aim

	self:setInputMapEnabled(aimKey, enable, flag)
end

function InputSystem:enableCatchInput(enable, flag)
	local catchKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Catch

	self:setInputMapEnabled(catchKey, enable, flag)
end

function InputSystem:enableFlyInput(enable)
	local flag = hotkeyConst.INPUT_BLOCK_FLAG.Fly

	self:enablePlayerInput(not enable, flag)
	self:enableSkillInput(not enable, flag)
	self:setInputMapEnabled(hotkeyConst.INPUT_MAP_ACTION_KEY.Fly, enable, flag)
end

function InputSystem:enableHudInput(enable, flag)
	local key = hotkeyConst.INPUT_MAP_ACTION_KEY.Hud

	self:setInputMapEnabled(key, enable, flag)
end

function InputSystem:enableBallDriveInput(enable)
	local blockKey = hotkeyConst.INPUT_BLOCK_FLAG.BallDrive

	self:enablePlayerInput(not enable, blockKey)
	self:setInputMapEnabled(hotkeyConst.INPUT_MAP_ACTION_KEY.BallDrive, enable, blockKey)
end

function InputSystem:enablePhotoInput(enable, flag)
	self:setInputMapEnabled(hotkeyConst.INPUT_MAP_ACTION_KEY.Photo, enable, flag)
end

function InputSystem:setCursorMode(cursorMode)
	self.cursorMode = cursorMode

	self:getInputMapProcessor(hotkeyConst.INPUT_MAP_ACTION_KEY.Camera):onCursorModeChange()

	local enableCatchSwitch = cursorMode == ClientConst.CURSOR_MODE_ACT
	local switchCatchKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Catch_SwitchCatchMode

	pg.global.inputMgr:SetInputActionEnabled(switchCatchKey, enableCatchSwitch, hotkeyConst.INPUT_BLOCK_FLAG.Default)
end

function InputSystem:refreshSwitchCatchModeInput()
	local switchCatchKey = hotkeyConst.INPUT_MAP_ACTION_KEY.Catch_SwitchCatchMode
	local systemFlag = hotkeyConst.INPUT_BLOCK_FLAG.System

	self:setInputActionEnabled(switchCatchKey, false, systemFlag)
	self:setInputActionEnabled(switchCatchKey, true, systemFlag)
	self:setInputActionEnabled(switchCatchKey, self.cursorMode == ClientConst.CURSOR_MODE_ACT, hotkeyConst.INPUT_BLOCK_FLAG.Default)
end

function InputSystem:initVirtualMouseCursorSpeed()
	local gamepadCursorSpeedLevel = pg.game.setting:getGamepadCursorSpeed()

	self.gamepadCursorSpeed = ClientConst.GAMEPAD_CURSOR_SPEED_LEVEL[gamepadCursorSpeedLevel] or ClientConst.GAMEPAD_CURSOR_SPEED_LEVEL[ClientConst.GAMEPAD_CURSOR_DEFAULT_LEVEL]

	self:setVirtualMouseCursorSpeed(self.gamepadCursorSpeed)
end

function InputSystem:setVirtualMouseCursorSpeed(cursorSpeed)
	self.gamepadCursorSpeed = cursorSpeed

	pg.global.uiMgr:SetVirtualMouseCursorSpeed(cursorSpeed)
end

function InputSystem:initGamepadLookSettings()
	self:setDefaultDeadzoneMin(0.125)
	self:setDefaultDeadzoneMax(1)
	self:setInvertHorizontalLook(pg.game.setting:getInvertHorizontalLook())
	self:setInvertVerticalLook(pg.game.setting:getInvertVerticalLook())
	self:setGamepadLeftStickDeadzone(pg.game.setting:getGamepadLeftStickDeadzone())
	self:setGamepadRightStickDeadzone(pg.game.setting:getGamepadRightStickDeadzone())
end

function InputSystem:initMouseLookSettings()
	self:setInvertHorizontalLookMouse(pg.game.setting:getInvertHorizontalLookMouse())
	self:setInvertVerticalLookMouse(pg.game.setting:getInvertVerticalLookMouse())
end

function InputSystem:setInvertHorizontalLookMouse(value)
	self.invertHorizontalLookMouse = value == true or value == 1
end

function InputSystem:setInvertVerticalLookMouse(value)
	self.invertVerticalLookMouse = value == true or value == 1
end

function InputSystem:setInvertHorizontalLook(value)
	self.invertHorizontalLook = value == true or value == 1
end

function InputSystem:setInvertVerticalLook(value)
	self.invertVerticalLook = value == true or value == 1
end

function InputSystem:mapGamepadStickDeadzone(value)
	value = math.clamp(value, 0, 100)

	local minValue = UIConst.GAMEPAD_STICK_DEADZONE_MIN
	local maxValue = UIConst.GAMEPAD_STICK_DEADZONE_MAX

	return (minValue + (maxValue - minValue) * value / 100) / 100
end

function InputSystem:setGamepadLeftStickDeadzone(value)
	pg.global.inputMgr.GamepadLeftStickDeadzone = self:mapGamepadStickDeadzone(value)
end

function InputSystem:setGamepadRightStickDeadzone(value)
	pg.global.inputMgr.GamepadRightStickDeadzone = self:mapGamepadStickDeadzone(value)
end

function InputSystem:applyGamepadLookInversion(x, y)
	local horizontalDirection = self.invertHorizontalLook and -1 or 1
	local verticalDirection = self.invertVerticalLook and -1 or 1

	return x * horizontalDirection, y * verticalDirection
end

function InputSystem:applyMouseLookInversion(x, y)
	local horizontalDirection = self.invertHorizontalLookMouse and -1 or 1
	local verticalDirection = self.invertVerticalLookMouse and -1 or 1

	return x * horizontalDirection, y * verticalDirection
end

function InputSystem:applyLookInversion(x, y)
	if self:isUsingGamepad() then
		return self:applyGamepadLookInversion(x, y)
	end

	return self:applyMouseLookInversion(x, y)
end

function InputSystem:isCursorNormalMode()
	return self.cursorMode and self.cursorMode == ClientConst.CURSOR_MODE_NORMAL
end

function InputSystem:isCursorActMode()
	return self.cursorMode and self.cursorMode == ClientConst.CURSOR_MODE_ACT
end

function InputSystem:setBlockNoneUIEvent(key, isBlock, whiteList)
	if isBlock then
		self.blockEventData[key] = isBlock

		if whiteList ~= nil then
			pg.global.inputMgr:SetBlockDownEventWhiteList(key, whiteList)
		end
	else
		self.blockEventData[key] = nil

		pg.global.inputMgr:CancelBlockDownEventWhiteList(key)
	end

	if not Utils.tableIsEmptyOrNil(self.blockEventData) then
		pg.global.inputMgr.blockDownNoneUIEvent = true
	else
		pg.global.inputMgr.blockDownNoneUIEvent = false
	end
end

function InputSystem:IsBlockEvent()
	return not Utils.tableIsEmptyOrNil(self.blockEventData)
end

function InputSystem:setBlockEventWithWhiteList(key, isBlock, whiteList)
	if isBlock then
		self.blockEventWithWhiteListData[key] = isBlock

		pg.global.inputMgr:SetBlockDownEventWhiteList(key, whiteList)
	else
		self.blockEventWithWhiteListData[key] = nil

		pg.global.inputMgr:CancelBlockDownEventWhiteList(key)
	end

	if not Utils.tableIsEmptyOrNil(self.blockEventWithWhiteListData) then
		pg.global.inputMgr.blockDownEventWithWhiteList = true
	else
		pg.global.inputMgr.blockDownEventWithWhiteList = false
	end
end

function InputSystem:setDPadNavigationEnabled(enable)
	return
end

function InputSystem:isDPadNavigationEnabled()
	return false
end

function InputSystem:onGamepadLeftStickMoveSimulate(direction)
	return pg.global.inputMgr:OnGamepadLeftStickMoveSimulate(direction)
end

function InputSystem:onGamepadConfirmSimulate()
	return pg.global.inputMgr:OnGamepadConfirmSimulate()
end

function InputSystem:setLockCursor(lockCursorKey, isLock)
	self.showCursorData[lockCursorKey] = not isLock

	self:refreshCursorState()
end

function InputSystem:setHudVirtualMouseCursor(enable)
	self.hudShowVirtualMouseCursor = enable

	self:refreshCursorState()
end

function InputSystem:setEnabledViewCtrl(enable, key)
	if not enable then
		self:setViewAxis(0, 0)
	end

	key = key or ClientConst.ViewControl.Default

	if enable then
		self.viewControlData[key] = nil
	else
		self.viewControlData[key] = false
	end
end

function InputSystem:forceEnableViewControl(reason, enable)
	reason = reason or ClientConst.ViewControl.Default

	if enable then
		self.forceEnableViewControlData[reason] = enable
	else
		self.forceEnableViewControlData[reason] = nil
	end
end

function InputSystem:checkForceEnableViewControl()
	return not Utils.tableIsEmptyOrNil(self.forceEnableViewControlData)
end

function InputSystem:checkEnableViewControl()
	if self.viewControlDisableTime > Time.realSecondCache then
		return false
	end

	if self:checkForceEnableViewControl() then
		return true
	end

	local me = pg.me

	if me and me.inTotemPuzzle then
		return false
	end

	if pg.global.ui:runPlatformByMobile() then
		return true
	end

	for key, value in pairs(self.viewControlData) do
		return false
	end

	if not self:isUsingGamepad() then
		for key, value in pairs(self.showCursorData) do
			if value then
				return false
			end
		end
	end

	return true
end

function InputSystem:temporarilyDisableViewControl(disableTime)
	disableTime = disableTime or 0.1
	self.viewControlDisableTime = math.max(Time.realSecondCache + disableTime, self.viewControlDisableTime)
end

function InputSystem:cancelTemporarilyDisableViewControl()
	self.viewControlDisableTime = -1
end

function InputSystem:setEnableViewControlGyro(enable)
	self.enableViewControlGyro = enable
end

function InputSystem:checkEnableViewControlGyro()
	return self.enableViewControlGyro
end

function InputSystem:getShowCursor()
	if self.cursorMode == ClientConst.CURSOR_MODE_NORMAL then
		return true
	end

	for key, value in pairs(self.showCursorData) do
		if value then
			return true
		end
	end

	return false
end

function InputSystem:setInputBlockDownEventState(block)
	pg.global.inputMgr.blockDownEvent = block

	self:refreshCursorState()
end

function InputSystem:computeLockState()
	if not pg.game.isFocused then
		return false
	end

	if pg.global.ui:runPlatformByMobile() then
		return false
	end

	if self:isUsingGamepad() then
		return false
	end

	if pg.global.inputMgr.blockDownEvent then
		return false
	end

	return not self:getShowCursor()
end

function InputSystem:computeVirtualMouseState()
	return self:isUsingGamepad()
end

function InputSystem:applyCursorState(isLock, isVirtualMouseEnable)
	local hardwareLock = isLock and not isVirtualMouseEnable

	self.lockCursor = hardwareLock

	if hardwareLock then
		pg.global.inputMgr:ReleaseCapture()

		CS.UnityEngine.Cursor.lockState = CS.UnityEngine.CursorLockMode.Locked
	else
		CS.UnityEngine.Cursor.lockState = CS.UnityEngine.CursorLockMode.None
	end

	pg.global.inputMgr:SetEnableVirtualMouse(isVirtualMouseEnable)

	if isLock or self:isUsingGamepad() then
		CS.UnityEngine.Cursor.visible = false
	else
		CS.UnityEngine.Cursor.visible = true
	end
end

function InputSystem:refreshCursorState()
	local isLock = self:computeLockState()
	local isVirtualMouseEnable = self:computeVirtualMouseState()

	self:applyCursorState(isLock, isVirtualMouseEnable)

	local shouldSuppress = false
	local isNavVirtualMouseMode = pg.global.navMgr and pg.global.navMgr.IsVirtualMouseMode

	if isVirtualMouseEnable and not isNavVirtualMouseMode then
		if not self.hudShowVirtualMouseCursor then
			local cursorRequested = self:getShowCursor()
			local _, showVirtualMouseCursor = pg.global.ui:checkShowCursor()

			if not cursorRequested or not showVirtualMouseCursor then
				shouldSuppress = true
			end
		end

		if not shouldSuppress then
			local navMgr = pg.global.navMgr

			if navMgr and navMgr.HasActiveUnblockedNavigation then
				shouldSuppress = true
			end
		end
	end

	pg.global.inputMgr:SetVirtualMouseSuppressed(shouldSuppress)
end

function InputSystem:onPlayerInit()
	self:enableControlInput(true)
	self:refreshSwitchCatchModeInput()
	self:reportGamepadControlCount()
	self:refreshTempInput()
end

function InputSystem:onBackToLogin()
	self:enableControlInput(false)
end

function InputSystem:onAppFocusChanged(focus)
	if focus then
		pg.global.inputMgr:ResetDevice(true)
		self:tempDisableInput(0.1)
		self:getInputMapProcessor(hotkeyConst.INPUT_MAP_ACTION_KEY.Camera):onCursorModeChange()
	else
		pg.global.inputMgr:ResetAllActions()
		pg.global.inputMgr:ResetDevice(true)
		facade:sendMsgToUI(MessageName.APP_FOCUS_CHANGED, focus)
	end

	self:refreshCursorState()
end

function InputSystem:tempDisableInput(disableTime)
	self:setBlockInput("TEMP", true)

	if self.resetTempBlockTimer then
		self:killTimer(self.resetTempBlockTimer)
	end

	self.resetTempBlockTimer = self:startTimer(function()
		self.resetTempBlockTimer = nil

		self:setBlockInput("TEMP", false)
	end, disableTime)
end

function InputSystem:setBlockInput(disableKey, isBlock)
	disableKey = disableKey or "Default"

	if isBlock then
		self.blockInputData[disableKey] = isBlock
	else
		self.blockInputData[disableKey] = nil
	end

	local isBlockInput = false

	if not Utils.tableIsEmptyOrNil(self.blockInputData) then
		isBlockInput = true
	end

	if isBlockInput ~= self.isBlockInput then
		self.isBlockInput = isBlockInput

		if isBlockInput then
			pg.global.inputMgr:SetEnableInput(false)
			pg.game.input:resetAllActions()
		else
			pg.global.inputMgr:SetEnableInput(true)
		end
	end
end

function InputSystem:getCurDeviceType()
	if self.deviceType then
		return self.deviceType
	end

	return pg.global.inputMgr.curDeviceType
end

function InputSystem:getInputSystemDevicesNames()
	return pg.global.inputMgr:GetInputSystemDevicesNames()
end

function InputSystem:getPlayerInputDevicesNames()
	return pg.global.inputMgr:GetPlayerInputDevicesNames()
end

function InputSystem:isUsingGamepad()
	local curDeviceType = self:getCurDeviceType()

	return curDeviceType == InputDeviceType.PSPad or curDeviceType == InputDeviceType.XBox or curDeviceType == InputDeviceType.SwitchPad
end

function InputSystem:getMobileGamepadLayoutMode()
	return pg.game.setting:getInt(ClientConst.PrefKey.MobileGamepadLayout, InputSystem.MobileGamepadLayoutMode.DynamicSwitch)
end

function InputSystem:applyMobileGamepadLayoutSetting(value)
	local mode = value

	if mode == nil then
		mode = self:getMobileGamepadLayoutMode()
	end

	local blocked = mode == InputSystem.MobileGamepadLayoutMode.TouchLayout

	pg.global.inputMgr:SetBlockGamepadByTouchLayout(blocked)
end

function InputSystem:onGamepadConnectionChanged()
	facade:SendMessageCommand(MessageName.INPUT_GAMEPAD_CONNECTION_CHANGED)
end

function InputSystem:onInputDeviceChanged(deviceType)
	self.deviceType = deviceType

	if deviceType == InputDeviceType.PSPad or deviceType == InputDeviceType.XBox or deviceType == InputDeviceType.SwitchPad then
		self:ensureHotkeysInited()
	end

	self:refreshCombineKeyWaitKeys()
	self:refreshCursorState()
	self:rebindGamepadManualPlaceholders(deviceType)
	self:applyRumbleDeviceRatio(deviceType)

	local wasRunMobile = pg.global.ui:runPlatformByMobile()
	local targetIsMobile = pg.global.ui.uiMgr:CheckIsMobileInteract()

	if wasRunMobile ~= targetIsMobile then
		local PlatformSwitchUtils = require("Utils.PlatformSwitchUtils")

		ClientConfigInputPlatform = ""

		pg.global.ui:onInitAdapterPlatform()
		PlatformSwitchUtils.onPlatformSwitched()
	end

	pg.global.ui:onInputDeviceChanged(deviceType)
	facade:SendMessageCommand(MessageName.INPUT_DEVICE_CHANGED, deviceType)
	self:reportGamepadControlCount()
end

function InputSystem:rebindGamepadManualPlaceholders(deviceType)
	if deviceType ~= InputDeviceType.PSPad and deviceType ~= InputDeviceType.XBox and deviceType ~= InputDeviceType.SwitchPad then
		return
	end

	if not self.gamepadHotkeyManager then
		return
	end

	local Resolver = require("GameApp.Input.GamepadManualResolver")
	local excelData = Utils.deepCopyTable(require("Data.gamepad_hotkey_data"))
	local placeholderMap = Resolver.getPlaceholderActions(excelData)
	local pathToPlaceholder = Resolver.getPathToPlaceholderMap()
	local overridePaths = {}

	if self.gamepadHotkeyManager.playerOverridePaths then
		for action, path in pairs(self.gamepadHotkeyManager.playerOverridePaths) do
			overridePaths[action] = path
		end
	end

	local changed = false

	for _, item in ipairs(excelData) do
		if type(item.actionName) == "table" and type(item.inputkey) == "table" then
			for i, actionName in ipairs(item.actionName) do
				if placeholderMap[actionName] then
					local override = overridePaths[actionName]

					if override == nil or pathToPlaceholder[override] then
						local newPath = Resolver.resolvePath(item.inputkey[i], deviceType)

						if newPath then
							self.gamepadHotkeyManager:ApplyHotkeyBindItem(actionName, newPath)

							changed = true
						end
					end
				end
			end
		end
	end

	for actionName, overridePath in pairs(overridePaths) do
		if not placeholderMap[actionName] then
			local placeholderName = pathToPlaceholder[overridePath]

			if placeholderName then
				local newPath = Resolver.resolvePlaceholderName(placeholderName, deviceType)

				if newPath then
					self.gamepadHotkeyManager:ApplyHotkeyBindItem(actionName, newPath)

					changed = true
				end
			end
		end
	end

	if changed then
		facade:SendMessageCommand(MessageName.HOTKEY_UPDATE)
	end
end

function InputSystem:initHotkeys()
	self.hotKeyInited = true

	if UNITY_IOS then
		return
	end

	self:ensureHotkeysInited()
end

function InputSystem:ensureHotkeysInited()
	if self.gamepadHotkeyInited then
		return
	end

	self.gamepadHotkeyInited = true
	self.gamepadInputMode = hotkeyConst.GAMEPAD_INPUT_CONTROL_MODE.CombineMode

	self:_applyGamepadInputAsset(self.gamepadInputMode)

	local keyboardHotkeyConfig = require("Data.Input.keyboard_hotkey_config")
	local keyboardHotkeyData = require("Data.keyboard_hotkey_data")

	self.keyboardHotkeyManager = HotkeyManager()

	self:initHotkeyManager(self.keyboardHotkeyManager, keyboardHotkeyConfig, keyboardHotkeyData)
	self:applyUserSettings(self.keyboardHotkeyManager, keyboardHotkeyConfig, keyboardHotkeyData)

	self.gamepadHotkeyManager = HotkeyManager()

	self:initHotkeyManager(self.gamepadHotkeyManager, require("Data.Input.gamepad_hotkey_config"))
	self:applyUserSettings(self.gamepadHotkeyManager, require("Data.Input.gamepad_hotkey_config"), require("Data.gamepad_hotkey_data"))
	pg.global.inputMgr:RebindXInputSelectForGXDK()
	self:refreshCombineKeyWaitKeys()
	facade:SendMessageCommand(MessageName.INPUT_GAMEPAD_CONTROL_MODE_CHANGE)
end

function InputSystem:getCurHotkeyManager()
	if self:isUsingGamepad() then
		return self.gamepadHotkeyManager
	end

	return self.keyboardHotkeyManager
end

function InputSystem:_applyGamepadInputAsset(mode)
	if mode == hotkeyConst.GAMEPAD_INPUT_CONTROL_MODE.CombineMode then
		pg.global.inputMgr:SetInputAsset("$InputAsset.inputactions")
	else
		pg.global.inputMgr:SetInputAsset("$InputAsset2.inputactions")
	end
end

function InputSystem:setGamepadInputMode(mode)
	self.gamepadInputMode = mode

	self:_applyGamepadInputAsset(mode)
	self:refreshCombineKeyWaitKeys()
	facade:SendMessageCommand(MessageName.INPUT_GAMEPAD_CONTROL_MODE_CHANGE)
end

function InputSystem:refreshCombineKeyWaitKeys()
	local gamepadHotkeyData = require("Data.Input.gamepad_hotkey_config") or {}
	local waitCombineActions = gamepadHotkeyData.waitCombineActions or {}

	if self:isUsingGamepad() then
		pg.global.inputMgr:SetWaitTriggerActions(waitCombineActions)
	else
		pg.global.inputMgr:SetWaitTriggerActions({})
	end
end

function InputSystem:initHotkeyManager(hotkeyManager, data, excelData)
	local hotkeyActions = Utils.deepCopyTable(data.hotkeyActions)

	if data.groupName == "Keyboard&Mouse" and excelData then
		local visibleActions = {}
		local visibleData = Utils.deepCopyTable(excelData)

		for _, item in pairs(visibleData) do
			local actionName = item.actionName

			if type(actionName) == "table" then
				for _, name in ipairs(actionName) do
					visibleActions[name] = true
				end
			elseif actionName then
				visibleActions[actionName] = true
			end
		end

		for actionName, actionInfo in pairs(hotkeyActions) do
			if not visibleActions[actionName] then
				actionInfo.group = "internal"
			end
		end
	end

	hotkeyManager.groupName = data.groupName

	hotkeyManager:SetRebindInputActions(hotkeyActions)
	hotkeyManager:SetMatchPaths(data.matchPaths or {})
	hotkeyManager:SetRelativeInputActions(data.relativeActions or {})
	hotkeyManager:SetHotkeyExcludes(data.hotkeyExcludes or {})
end

function InputSystem:applyUserSettings(hotkeyManager, data, excelData)
	local keyData = Utils.deepCopyTable(excelData)

	if data.groupName == "Gamepad" then
		local Resolver = require("GameApp.Input.GamepadManualResolver")

		keyData = Resolver.resolveExcelData(keyData)
	end

	local planIndex = 1

	hotkeyManager:InitHotKeyWithExcel(keyData, planIndex)
	hotkeyManager:ResetPlayerOverridePaths(data.groupName .. self.version .. planIndex)

	if data.groupName == "Gamepad" then
		self:cleanupGamepadManualOverrides(hotkeyManager)
	end
end

function InputSystem:cleanupGamepadManualOverrides(hotkeyManager)
	if not hotkeyManager or not hotkeyManager.playerOverridePaths then
		return
	end

	local Resolver = require("GameApp.Input.GamepadManualResolver")
	local deviceType = self:getCurDeviceType()
	local snapshot = {}

	for action, path in pairs(hotkeyManager.playerOverridePaths) do
		snapshot[action] = path
	end

	for actionName, overridePath in pairs(snapshot) do
		if Resolver.isPlaceholder(overridePath) then
			local placeholderName = string.sub(overridePath, #"<GamepadManual>/" + 1)
			local realPath = Resolver.resolvePlaceholderName(placeholderName, deviceType)

			if realPath then
				hotkeyManager:ApplyHotkeyBindItem(actionName, realPath)
			end
		end
	end
end

function InputSystem:performHotkeyRebind(hotkeyManager, actionPath, onCancel, onComplete, onConflict, onExcluded)
	local isValid = hotkeyManager:PerformRebindInputAction(actionPath, function(bindPath)
		hotkeyManager:ApplyHotkeyBindItem(actionPath, bindPath)
	end, onCancel, onComplete, onConflict, onExcluded)

	return isValid
end

function InputSystem:setHotkeyRebind(hotkeyManager, actionPath, bindPath)
	local isValid = hotkeyManager:ApplyHotkeyBindItem(actionPath, bindPath)

	return isValid
end

function InputSystem:getHotkeyInfo(hotkeyManager)
	local hotkeyData = hotkeyManager:GetHotkeyBaseDataLua()

	return hotkeyData
end

function InputSystem:getHotkeyDefaultInfo(hotkeyManager)
	local defaultData = hotkeyManager:GetHotkeyDefaultDataLua()

	return defaultData
end

function InputSystem:getHotkeyBindInfo(hotkeyManager)
	local bindData = hotkeyManager:GetHotkeyBindDataLua()

	return bindData
end

function InputSystem:getActionKeyBind(hotkeyManager, actionPath, keyBindingIndex)
	keyBindingIndex = keyBindingIndex or -1

	return hotkeyManager:GetActionKeyBind(actionPath, keyBindingIndex)
end

function InputSystem:getActionDefaultKeyBind(hotkeyManager, actionPath, keyBindingIndex)
	keyBindingIndex = keyBindingIndex or -1

	return hotkeyManager:GetActionKeyDefaultBind(actionPath, keyBindingIndex)
end

function InputSystem:setHotkeyBindInfo(hotkeyManager, bindData)
	hotkeyManager:ApplyHotkeyBindDataLua(bindData)
end

function InputSystem:resetAllHotkeys(hotkeyManager)
	hotkeyManager:ResetAllHotKeys()

	if hotkeyManager == self.gamepadHotkeyManager then
		self:rebindGamepadManualPlaceholders(self:getCurDeviceType())
	end
end

function InputSystem:cancelHotkeyRebind(hotkeyManager)
	hotkeyManager:CancelRebindInputAction()
end

function InputSystem:printHotkeyInfo(hotkeyManager)
	hotkeyManager = hotkeyManager or self:getCurHotkeyManager()

	local hotkeyData = self:getHotkeyInfo(self.gamepadHotkeyManager)

	for k, v in pairs(hotkeyData) do
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug(k .. ":" .. v)
		end
	end
end

function InputSystem:onUIDepthChange()
	pg.global.inputMgr:SortUIKeyBindingItems()
end

function InputSystem:playRumble(layerId, lowFreq, highFreq, duration, loop)
	loop = loop or false

	pg.global.inputMgr:PlayRumble(layerId, lowFreq, highFreq, duration, loop)
end

function InputSystem:playRumbleByName(layerId, rumbleName, skipSame)
	if string.isNilOrEmpty(rumbleName) then
		return
	end

	skipSame = skipSame or false

	pg.global.inputMgr:PlayRumble(layerId, rumbleName, skipSame)
end

function InputSystem:stopRumble(layerId)
	pg.global.inputMgr:StopRumble(layerId)
end

function InputSystem:updateLockBreakRumble()
	local playRumble = false
	local me = pg.me

	if pg.game.controller.lockHelper.forceLockActorId ~= 0 and me and me.lockedActorId then
		local lockEntity = pg.getEntityByActorId(me.lockedActorId)

		if lockEntity and lockEntity.inBreak and lockEntity:inBreak() then
			playRumble = true
		end
	end

	if self.isPlayRumble ~= playRumble then
		self.isPlayRumble = playRumble

		if playRumble then
			self:playRumbleByName(ClientConst.RumbleLayer.BREAK_RECOVER, "CommonTapMiddle")
		else
			self:stopRumble(ClientConst.RumbleLayer.BREAK_RECOVER)
		end
	end
end

function InputSystem:setAdaptiveTrigger(isLeftTrigger, triggerParam)
	pg.global.inputMgr:SetAdaptiveTrigger(isLeftTrigger, triggerParam)
end

function InputSystem:cancelAdaptiveTrigger(isLeftTrigger)
	self:setAdaptiveTrigger(isLeftTrigger, {})
end

function InputSystem:setContinuousResistanceTrigger(isLeftTrigger, startPos, force)
	local triggerParam = {
		triggerType = 1,
		startPos = 255 * startPos,
		force = 255 * force
	}

	self:setAdaptiveTrigger(isLeftTrigger, triggerParam)
end

function InputSystem:setSectionResistanceTrigger(isLeftTrigger, startPos, endPos, force)
	local triggerParam = {
		triggerType = 2,
		startPos = 255 * startPos,
		endPos = 255 * endPos,
		force = 255 * force
	}

	self:setAdaptiveTrigger(isLeftTrigger, triggerParam)
end

function InputSystem:setEffectExTrigger(isLeftTrigger, startPos, keepEffect, beginForce, middleForce, endForce, frequency)
	local triggerParam = {
		triggerType = 3,
		startPos = 255 * startPos,
		beginForce = 255 * beginForce,
		middleForce = 255 * middleForce,
		endForce = 255 * endForce,
		keepEffect = keepEffect or false,
		frequency = 255 * frequency
	}

	self:setAdaptiveTrigger(isLeftTrigger, triggerParam)
end

function InputSystem:getAccelerator()
	return pg.global.inputMgr:GetAccelerate()
end

function InputSystem:updateGyroscopeCache()
	local frameCount = Time.frameCount or -1

	if frameCount >= 0 and self.gyroscopeFrameCount == frameCount then
		return
	end

	local x, y, _ = pg.global.inputMgr:GetGyroscope()
	local ratio = self.gyroscopeRatio or self:getGyroscopeRatio()

	self.gyroscopeScaledX = x * ratio
	self.gyroscopeScaledY = y * ratio

	if frameCount >= 0 then
		self.gyroscopeFrameCount = frameCount
	end
end

function InputSystem:getGyroscopeXY()
	self:updateGyroscopeCache()

	return self.gyroscopeScaledX, self.gyroscopeScaledY
end

function InputSystem:getGyroscopeRatio()
	if self.gyroscopeRatio == nil then
		self.gyroscopeRatio = pg.game.setting:getFloat("CommonGyroscopeRatio", 1)
	end

	return self.gyroscopeRatio
end

function InputSystem:setGyroscopeRatio(ratio)
	if self.gyroscopeRatio == ratio then
		return
	end

	self.gyroscopeRatio = ratio
	self.gyroscopeFrameCount = -1

	pg.game.setting:setFloat("CommonGyroscopeRatio", ratio)
end

function InputSystem:initRumbleRatio()
	pg.global.inputMgr:SetRumbleRatio(self:getRumbleRatio())
	self:applyRumbleDeviceRatio()
end

function InputSystem:getRumbleRatio()
	return pg.game.setting:getFloat("CommonRumbleRatio", 1)
end

function InputSystem:setRumbleRatio(ratio)
	pg.game.setting:setFloat("CommonRumbleRatio", ratio)
	pg.global.inputMgr:SetRumbleRatio(ratio)
end

function InputSystem:getRumbleDeviceRatio(deviceType)
	deviceType = deviceType or self:getCurDeviceType()

	local ratio = self.rumbleDeviceRatioOverride and self.rumbleDeviceRatioOverride[deviceType]

	if ratio == nil then
		local typeId = InputSystem.RUMBLE_DEVICE_TYPE_ID[deviceType]
		local configRatio = typeId and SysConfigData.deviceRumbleRatio

		ratio = configRatio and configRatio[typeId]
	end

	if ratio == nil then
		ratio = InputSystem.RUMBLE_DEVICE_RATIO[deviceType] or InputSystem.RUMBLE_DEVICE_RATIO_DEFAULT
	end

	return ratio[1] or 1, ratio[2] or 1
end

function InputSystem:applyRumbleDeviceRatio(deviceType)
	local lowFreqRatio, highFreqRatio = self:getRumbleDeviceRatio(deviceType)

	pg.global.inputMgr:SetRumbleDeviceRatio(lowFreqRatio, highFreqRatio)
end

function InputSystem:setRumbleDeviceRatio(deviceType, lowFreqRatio, highFreqRatio)
	if deviceType == nil then
		return
	end

	self.rumbleDeviceRatioOverride = self.rumbleDeviceRatioOverride or {}
	self.rumbleDeviceRatioOverride[deviceType] = {
		lowFreqRatio or 1,
		highFreqRatio or 1
	}

	if deviceType == self:getCurDeviceType() then
		self:applyRumbleDeviceRatio(deviceType)
	end
end

function InputSystem:setDefaultDeadzoneMin(value)
	value = math.clamp(value, 0, 0.3)
	pg.global.inputMgr.defaultDeadzoneMin = value
end

function InputSystem:getDefaultDeadzoneMin()
	return pg.global.inputMgr.defaultDeadzoneMin
end

function InputSystem:setDefaultDeadzoneMax(value)
	value = math.clamp(value, 0.8, 1)
	pg.global.inputMgr.defaultDeadzoneMax = value
end

function InputSystem:getDefaultDeadzoneMax()
	return pg.global.inputMgr.defaultDeadzoneMax
end

function InputSystem:cameraZoomValidCondition(inputInfo)
	if self.lockCameraZoom then
		return false
	end

	local deltaZoom = inputInfo.valueVec2.y

	if pg.game.controller.lockHelper:onMouseScroll(deltaZoom) then
		return false
	end

	if pg.me and pg.me.isInMagnesisMode and pg.me:isInMagnesisMode() then
		return false
	end

	if pg.me and pg.me.forbidCameraZoom then
		return false
	end

	return true
end

function InputSystem:debugInputResponse(mapName, actionName)
	return pg.global.inputMgr:DebugHandleInputInfo(mapName, actionName)
end

function InputSystem:test(actionPath)
	local valid = self:performHotkeyRebind(self.gamepadHotkeyManager, actionPath, function()
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("onCancel")
		end
	end, function()
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("onComplete")
		end
	end)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("valid ", valid)
	end
end

function InputSystem:reportGamepadControlCount()
	if not self.isGamepadCountReported and self:isUsingGamepad() and pg.me then
		GlobalData.BILogger:customeLog("gamepad_count_flow", {
			uid = pg.me.uid
		})

		self.isGamepadCountReported = true
	end
end

return InputSystem
