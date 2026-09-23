-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\UICtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local logger = LoggerManager.getLogger("UICtrl")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local SysConfigData = require("Data.sys_config_data")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local FuncUIDMap = require("Data.function_unlock_ui")
local FuncIdConfigData = require("Data.func_index_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local CommonSwitch = require("Common.CommonSwitch")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local AddressDataConst = require("Const.AddressDataConst")
local UICtrl = Class.LightClass("UICtrl")
local PanelConfig = CS.FunPlus.WorldX.Manager.PanelConfig
local DEFAULT_LONG_PRESS_START_TIME = 0.25
local DEFAULT_LONG_PRESS_DURATION = 0.55

local function getLongPressProgress(pressTime, startTriggerPressTime, triggerPressTime)
	if triggerPressTime <= startTriggerPressTime then
		return triggerPressTime <= pressTime and 1 or 0
	end

	return math.min(math.max((pressTime - startTriggerPressTime) / (triggerPressTime - startTriggerPressTime), 0), 1)
end

function UICtrl:ctor()
	self.uiMgr = pg.global.uiMgr
	self.view = nil
	self.uiComponents = {}
	self.uiComponentsSet = {}
	self._timerIds = {}
	self._scaleTimerIds = {}
	self._relatedNpcIds = {}
	self._navListenerNames = {}
	self._loadTaskId = 0
	self._blurSource = nil
	self._curVisible = nil
	self._visible = true
	self.hideMarkDict = {}
	self._adapterVisibilityState = UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE
	self._isOpen = false
	self._syncUISceneVisibleWithUI = false
	self._uiSceneVisibleWithUICtrl = nil
	self._uiSceneHiddenWithUICtrl = false
	self._uiSceneIgnoreDisableMainCamera = nil
	self._uiSceneOpenAdditive = nil
	self._uiSceneIgnoreResetUICamera = nil
	self._deferBlackCloseForUIScene = false
	self._activateUISceneFrameId = nil
	self._releaseUISceneBlackFrameId = nil
	self._releaseUISceneBlackTimerId = nil
	self._blackTransitionCameraSuppressed = false
	self._deferredUISceneActivationPending = false
	self._pendingUISceneOpenCallbacks = nil
	self._loadState = UIConst.LOAD_STATE.NONE
	self._openInfo = nil
	self._closeCb = nil
	self._shouldRefreshGameTimeOnClose = false
	self.longPressInterval = 0.1
	self._GamePadCmp = nil
	self._managedBlurEffect = nil
	self._managedBlurSource = nil
	self._blurCaptureVersion = 0
	self._blurGatePending = false
	self._blurPreOpenPrepared = false
	self._blurGateContext = nil
	self._blurGateContinuation = nil
	self._blurGateFrameTimerId = nil
	self._blurDelayTimerId = nil
	self._blurDelayFrameTimerId = nil
end

function UICtrl:initCtrl(uiConfig, uid, adapter)
	self.adapter = adapter
	self.uiConfig = uiConfig
	self._uiSceneName = self.uiConfig.uiSceneName
	self._uiSceneRes = self.uiConfig.uiSceneResId
	self._syncUISceneVisibleWithUI = self._uiSceneName ~= nil
	self.module = uiConfig.module
	self.uid = uid

	local modelClz = self.modelClz or self.adapter:genModelClass(uid, self.module)

	self.model = modelClz and modelClz.new() or nil

	local panelConfig = PanelConfig()

	panelConfig.uid = self.uid

	local isModel = self.uiConfig.isModel
	local uiType = self.uiConfig.uiType
	local gamepadPass = self.uiConfig.gamepadPass

	if isModel == nil then
		isModel = (uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER) and true or false
	end

	panelConfig.isModel = isModel
	panelConfig.gamepadPass = gamepadPass or false
	panelConfig.gamepadModel = self.uiConfig.gamepadModel or false
	panelConfig.disableVirtualMouseToggle = self.uiConfig.disableVirtualMouseToggle or uiType ~= UIConst.PANEL_LAYER

	pcall(function()
		panelConfig.allowNavWithMouse = self.uiConfig.allowNavWithMouse or false
	end)

	if uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER then
		panelConfig.orderWidget = 0
	else
		panelConfig.orderWidget = self.uiConfig.orderWidget or 0
	end

	self._panelConfig = panelConfig

	self:afterInit()
end

function UICtrl:afterInit()
	return
end

function UICtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	if not self:checkPlatform() then
		if closeCb then
			closeCb()
		end

		return
	end

	if self._blurGatePending then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("UICtrl open ignored, blur capture gate is pending:", self.uid)
		end

		return
	end

	if not self:checkCanOpen(true, info) then
		if closeCb then
			closeCb()
		end

		return
	end

	if self.view and self.view.widget.isClosing then
		self:closeImmediately()
	end

	local fadeOutHudRequested = false

	if self.uiConfig.fullScreen and self.uiConfig.uiType == UIConst.PANEL_LAYER and not self._isOpen and self:checkFadeOutHud() then
		self.adapter:tryFadeOutHud()

		fadeOutHudRequested = true
	end

	self.adapter:markUIOpenState(self.uid, false)

	local blurConfig = self:getManagedBlurConfig()

	if self:shouldCaptureBlurBeforeOpen(blurConfig) then
		self:captureBlurBeforeOpen(blurConfig, {
			closeCb = closeCb,
			fadeOutHudRequested = fadeOutHudRequested
		}, function()
			self:continueOpen(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
		end)

		return
	end

	self:continueOpen(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
end

function UICtrl:continueOpen(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	local needBlackChange = false

	if self:isBlurBg() then
		if self:checkNeedBlackChangeToBlur() then
			needBlackChange = true
		end
	else
		needBlackChange = self.uiConfig.addBlackChange or self:checkNeedLoadUIScene(info)
	end

	local fullScreen = (self.uiConfig.uiType == UIConst.PANEL_LAYER or self.uiConfig.uiType == UIConst.POPUP_LAYER) and self.uiConfig.fullScreen ~= false

	if not forceNoBlack and fullScreen and needBlackChange then
		self._blackFadeInDuration = UIConst.DEFAULT_BLACK_CHANGE[1]
		self._blackFadeOutDuration = UIConst.DEFAULT_BLACK_CHANGE[2]

		self:__blackIn(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	else
		self:_startResLoad(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	end
end

function UICtrl:checkFadeOutHud()
	return true
end

function UICtrl:isBlurBg()
	return self.uiConfig.blurBg or self.uiConfig.addBlurBg
end

function UICtrl:checkNeedLoadUIScene(info)
	local ignoreUIScene = info and type(info) == "table" and info.ignoreUIScene

	if not self._uiSceneName or not self._uiSceneRes or ignoreUIScene then
		return false
	end

	return not self:isUISceneActive()
end

function UICtrl:isUISceneActive()
	local uiScene = pg.game and pg.game.uiScene
	local uiSceneStack = uiScene and uiScene.uiSceneStack
	local topScene = uiSceneStack and uiSceneStack[#uiSceneStack]

	return topScene ~= nil and topScene.name == self._uiSceneName
end

function UICtrl:shouldSyncUISceneVisibleWithUI()
	return self._syncUISceneVisibleWithUI
end

function UICtrl:getUISceneVisibleWithUI(forceHideUI)
	if forceHideUI or not self._visible or not self._isOpen or not Utils.tableIsEmptyOrNil(self.hideMarkDict) then
		return false
	end

	local adapterState = self._adapterVisibilityState

	if adapterState == UIConst.UI_ADAPTER_VISIBILITY_STATE.UI_HIDE_FORCE then
		return false
	end

	if adapterState == UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE or adapterState == UIConst.UI_ADAPTER_VISIBILITY_STATE.UI_HIDE_KEEP_UI_SCENE then
		return true
	end

	if adapterState == UIConst.UI_ADAPTER_VISIBILITY_STATE.PANEL_COVERED then
		return self.uiConfig.keepUISceneOnPanelCovered == true
	end

	return false
end

function UICtrl:refreshUISceneVisible(forceHideUI)
	if not self:shouldSyncUISceneVisibleWithUI() then
		return
	end

	local visible = self:getUISceneVisibleWithUI(forceHideUI)

	if self._uiSceneVisibleWithUICtrl == visible then
		return
	end

	self._uiSceneVisibleWithUICtrl = visible

	self:onUISceneVisibleChange(visible)
end

function UICtrl:hasUISceneOwner(sceneName, ownerKey)
	sceneName = sceneName or self._uiSceneName
	ownerKey = ownerKey or self.module

	local uiScene = pg.game and pg.game.uiScene

	for _, sceneInfo in ipairs(uiScene and uiScene.uiSceneStack or EMPTY_TABLE) do
		if sceneInfo.name == sceneName and sceneInfo.ownerKey == ownerKey then
			return true
		end
	end

	return false
end

function UICtrl:checkNeedBlackChangeToBlur()
	local uiScene = pg.game and pg.game.uiScene

	if not self:isBlurBg() or not uiScene or not uiScene.uiSceneStack or #uiScene.uiSceneStack == 0 then
		return false
	end

	local topScene = uiScene.uiSceneStack[#uiScene.uiSceneStack]

	return topScene ~= nil
end

function UICtrl:startOpen(info, cb, closeCb)
	self._isOpen = true
	self._blurPreOpenPrepared = false
	self._openInfo = info
	self._closeCb = closeCb

	local changed = self.adapter:onUIAdd(self.uid, self)

	self._adapterVisibilityState = self.adapter:getAdapterVisibilityState(self)

	if changed then
		pg.global.ui:refreshModelWidget()
	end

	if self.view then
		self:tryShowBlackBackground()
		self:blackClose()
		self:_refreshGameTimeStatusOnOpen()
		self:openUI(info, true)

		if cb then
			cb()
		end
	elseif self._loadState == UIConst.LOAD_STATE.NONE then
		self:_startLoadState(cb)
	end

	self.adapter:markUIOpenState(self.uid, true)
end

function UICtrl:_startOpenWithUIScene(info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera)
	if self._deferredUISceneActivationPending then
		if cb then
			self._pendingUISceneOpenCallbacks = self._pendingUISceneOpenCallbacks or {}

			table.insert(self._pendingUISceneOpenCallbacks, cb)
		end

		self:startOpen(info, nil, closeCb)

		return
	end

	if self._releaseUISceneBlackFrameId or self._releaseUISceneBlackTimerId then
		self:startOpen(info, cb, closeCb)

		return
	end

	local previousVisible = self._curVisible
	local isConsole = UNITY_EDITOR or pg.global.platform ~= nil and pg.global.platform:isConsole()
	local canScheduleActivation = self.view ~= nil or self._loadState == UIConst.LOAD_STATE.NONE
	local holdBlackForUIScene = canScheduleActivation and not openAdditive and not ignoreDisableMainCamera and not self:isUISceneActive() and self._blackFadeOutDuration ~= nil
	local deferUISceneActivation = isConsole and holdBlackForUIScene

	if holdBlackForUIScene then
		self._deferBlackCloseForUIScene = true
	end

	if deferUISceneActivation then
		self._deferredUISceneActivationPending = true
		self._pendingUISceneOpenCallbacks = {}

		if cb then
			table.insert(self._pendingUISceneOpenCallbacks, cb)
		end

		self.adapter:beginUISceneCameraTransition()

		self._blackTransitionCameraSuppressed = true
	end

	self:startOpen(info, function()
		if deferUISceneActivation and not self._deferredUISceneActivationPending then
			if cb then
				cb()
			end

			return
		end

		local targetScene = self.uiScene

		local function activateUIScene()
			self._activateUISceneFrameId = nil

			local uiClosing = self:checkUIClosing()

			if uiClosing or not targetScene or self.uiScene ~= targetScene or targetScene.expire then
				self._deferredUISceneActivationPending = false
				self._deferBlackCloseForUIScene = false

				self:releaseBlackTransitionCameraSuppression()
				self:blackClose()

				self._pendingUISceneOpenCallbacks = nil

				if self._isOpen and not uiClosing then
					self:close()
				end

				return
			end

			local visible = self:checkUIVisible() == true
			local uiSceneVisible = self:getUISceneVisibleWithUI()

			if not uiSceneVisible and self:shouldSyncUISceneVisibleWithUI() then
				if self.uiScene then
					self.uiScene:onCtrlVisibleChange(self.module, false)
				end

				self:releaseBlackTransitionCameraSuppression()

				self._deferredUISceneActivationPending = false
				self._deferBlackCloseForUIScene = false

				self:blackClose()

				if deferUISceneActivation then
					local pendingCallbacks = self._pendingUISceneOpenCallbacks

					self._pendingUISceneOpenCallbacks = nil

					for _, pendingCallback in ipairs(pendingCallbacks or EMPTY_TABLE) do
						pendingCallback()
					end
				elseif cb then
					cb()
				end

				return
			end

			pg.game.uiScene:switchToScene(self._uiSceneName, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera, self.module)
			self:releaseBlackTransitionCameraSuppression()

			self._deferredUISceneActivationPending = false

			if self:shouldSyncUISceneVisibleWithUI() then
				self:onVisibleChangeUIScene(uiSceneVisible, true)
			elseif not visible or self._curVisible == previousVisible then
				self:onUISceneVisibleChange(visible)
			end

			if holdBlackForUIScene then
				self:_waitForUIScenePresentationReady(targetScene)
			end

			if deferUISceneActivation then
				local pendingCallbacks = self._pendingUISceneOpenCallbacks

				self._pendingUISceneOpenCallbacks = nil

				for _, pendingCallback in ipairs(pendingCallbacks or EMPTY_TABLE) do
					pendingCallback()
				end
			elseif cb then
				cb()
			end
		end

		if deferUISceneActivation then
			local activationDelayFrames = math.max(tonumber(UIConst.CONSOLE_UI_SCENE_CAMERA_DELAY_FRAMES) or 1, 1)

			self._activateUISceneFrameId = self:startFrameTimer(activateUIScene, activationDelayFrames)
		else
			activateUIScene()
		end
	end, closeCb)
end

function UICtrl:_waitForUIScenePresentationReady(targetScene)
	local waitedFrames = 0
	local minWaitFrames = math.max(tonumber(UIConst.UI_SCENE_PRESENTATION_MIN_WAIT_FRAMES) or 2, 1)
	local timeoutSeconds = math.max(tonumber(UIConst.UI_SCENE_PRESENTATION_TIMEOUT_SECONDS) or 0.5, 0)
	local frameId, timeoutTimerId
	local finished = false
	local timedOut = false
	local presentationCheckFailed = false

	local function stopFrameWaiting()
		if frameId then
			if self._releaseUISceneBlackFrameId == frameId then
				self._releaseUISceneBlackFrameId = nil
			end

			TimerManager.delFrameCb(frameId)

			frameId = nil
		end
	end

	local function stopTimeoutWaiting()
		if timeoutTimerId then
			if self._releaseUISceneBlackTimerId == timeoutTimerId then
				self._releaseUISceneBlackTimerId = nil
			end

			self:killTimer(timeoutTimerId)

			timeoutTimerId = nil
		end
	end

	local function finishWaiting()
		if finished then
			return false
		end

		finished = true

		stopFrameWaiting()
		stopTimeoutWaiting()

		return true
	end

	local function checkTargetPresentationReady()
		return targetScene:checkPresentationReady()
	end

	local function releaseBlack()
		self._deferBlackCloseForUIScene = false

		self:blackClose()
	end

	local function releaseBlackOnTimeout()
		finishWaiting()

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("UIScene presentation ready timeout:", self._uiSceneName, timeoutSeconds, waitedFrames)
		end

		releaseBlack()
	end

	local function checkReady()
		if finished then
			return
		end

		if self:checkUIClosing() or not targetScene or self.uiScene ~= targetScene or targetScene.expire or targetScene.enable ~= true then
			finishWaiting()
			self:releaseBlackTransitionCameraSuppression()
			releaseBlack()

			return
		end

		waitedFrames = waitedFrames + 1

		local presentationReady = false

		if not presentationCheckFailed then
			local checkSucceed, readyOrTraceback = xpcall(checkTargetPresentationReady, debug.traceback)

			if checkSucceed then
				presentationReady = readyOrTraceback == true
			else
				presentationCheckFailed = true

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("UIScene presentation ready check failed:", self._uiSceneName, readyOrTraceback)
				end
			end
		end

		if waitedFrames >= minWaitFrames and (presentationReady or timedOut or presentationCheckFailed) then
			if presentationReady or presentationCheckFailed then
				finishWaiting()
				releaseBlack()
			else
				releaseBlackOnTimeout()
			end

			return
		end
	end

	local function onTimeout()
		local firedTimerId = timeoutTimerId

		timeoutTimerId = nil

		if self._releaseUISceneBlackTimerId == firedTimerId then
			self._releaseUISceneBlackTimerId = nil
		end

		if firedTimerId then
			self._timerIds[firedTimerId] = nil
		end

		if finished then
			return
		end

		timedOut = true

		if waitedFrames < minWaitFrames then
			return
		end

		releaseBlackOnTimeout()
	end

	frameId = TimerManager.addSpecificFrameCb(0, true, checkReady)
	self._releaseUISceneBlackFrameId = frameId
	timeoutTimerId = self:startTimer(onTimeout, timeoutSeconds)
	self._releaseUISceneBlackTimerId = timeoutTimerId
end

function UICtrl:_waitForUISceneLoad(scene, info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera, onSceneLoadedCb)
	if not self._inloadUIScene or self.uiScene ~= scene or scene.expire then
		return
	end

	if scene:checkLoaded() then
		if not scene:checkLoadSucceed() then
			self:close()

			return
		end

		if onSceneLoadedCb then
			onSceneLoadedCb()
		end

		self:onUISceneLoaded()
		self:_startOpenWithUIScene(info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera)

		return
	end

	self._waitUISceneTimer = self:startTimer(function()
		self._waitUISceneTimer = nil

		self:_waitForUISceneLoad(scene, info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera, onSceneLoadedCb)
	end, 0.05)
end

function UICtrl:startLoadUIScene(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	local ignoreDisableMainCamera = sceneParams and sceneParams.ignoreDisableMainCamera
	local openAdditive = sceneParams and sceneParams.openAdditive
	local ignoreResetUICamera = sceneParams and sceneParams.ignoreResetUICamera

	self._uiSceneIgnoreDisableMainCamera = ignoreDisableMainCamera
	self._uiSceneOpenAdditive = openAdditive
	self._uiSceneIgnoreResetUICamera = ignoreResetUICamera

	if not self._inloadUIScene then
		self._inloadUIScene = true

		self:initUIScene(sceneParams)

		if self.uiScene:checkLoadStateIsNone() then
			self.uiScene:startLoad(function(succeed)
				if not succeed then
					self:close()

					return
				end

				if onSceneLoadedCb then
					onSceneLoadedCb()
				end

				self:onUISceneLoaded()
				self:_startOpenWithUIScene(info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera)
			end, sceneParams)
		elseif self.uiScene:checkLoaded() then
			if not self.uiScene:checkLoadSucceed() then
				self:close()

				return
			end

			self:_startOpenWithUIScene(info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera)
		else
			self.adapter.waitLoadingUI[self.uid] = nil

			self:_waitForUISceneLoad(self.uiScene, info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera, onSceneLoadedCb)
		end
	else
		self:_startOpenWithUIScene(info, cb, closeCb, ignoreDisableMainCamera, openAdditive, ignoreResetUICamera)
	end
end

function UICtrl:__blackIn(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	local duration = self._blackFadeInDuration

	self._blackFadeInDuration = nil

	self.adapter:blackFadeIn(duration, true)
	self:clearBlackTimer()

	self.blackTimer = self:startTimer(function()
		self:_startResLoad(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	end, duration)
end

function UICtrl:_startResLoad(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	local ignoreUIScene = Utils.isTable(info) and info.ignoreUIScene
	local deferUISceneLoad = self.uiConfig and self.uiConfig.deferUISceneLoad

	if self._uiSceneName and self._uiSceneRes and not ignoreUIScene and not deferUISceneLoad then
		self:startLoadUIScene(info, cb, closeCb, sceneParams, onSceneLoadedCb)
	else
		self:startOpen(info, cb, closeCb)
	end
end

function UICtrl:onUISceneLoaded()
	return
end

function UICtrl:initUIScene(sceneParams)
	if self._uiSceneName then
		self.uiScene = pg.game.uiScene:getScene(self._uiSceneName)
	end

	if not self.uiScene then
		self.uiScene = pg.game.uiScene:getUISceneInst(self._uiSceneName, self._uiSceneRes, sceneParams and sceneParams.additionRes, sceneParams and sceneParams.paramsTable)
	end

	if self.uiConfig.hairLayerCount then
		self.uiScene:setHairLayerCount(self.uiConfig.hairLayerCount)
	end

	if self.uiConfig.mobileHighQuality then
		self.uiScene:setMobileHighQuality(true)
	end

	self.uiScene:bindUICtrlKey(self.module)
end

function UICtrl:clearBlackTimer()
	if self.blackTimer then
		self:killTimer(self.blackTimer)
	end

	self.blackTimer = nil
end

function UICtrl:blackClose()
	if self._deferBlackCloseForUIScene then
		return
	end

	if self._blackFadeOutDuration then
		local duration = self._blackFadeOutDuration

		self._blackFadeOutDuration = nil

		self.adapter:blackFadeOut(duration)
	else
		self.adapter:blackFadeOut(0)
	end
end

function UICtrl:tryShowBlackBackground()
	if self.uiConfig.blackBgDuration == nil then
		return
	end

	if self._deferBlackCloseForUIScene then
		return
	end

	self.adapter:showBlackBackground(self, self.uiConfig.blackBgDuration)
end

function UICtrl:clearBlackBackground()
	if self.uiConfig.blackBgDuration == nil then
		return
	end

	self.adapter:hideBlackBackground(self)
end

function UICtrl:releaseBlackTransitionCameraSuppression()
	if not self._blackTransitionCameraSuppressed then
		return
	end

	self._blackTransitionCameraSuppressed = false

	self.adapter:endUISceneCameraTransition()
end

function UICtrl:clearDeferredUISceneActivation()
	if self._activateUISceneFrameId then
		TimerManager.delFrameCb(self._activateUISceneFrameId)

		self._activateUISceneFrameId = nil
	end

	if self._releaseUISceneBlackFrameId then
		TimerManager.delFrameCb(self._releaseUISceneBlackFrameId)

		self._releaseUISceneBlackFrameId = nil
	end

	if self._releaseUISceneBlackTimerId then
		self:killTimer(self._releaseUISceneBlackTimerId)

		self._releaseUISceneBlackTimerId = nil
	end

	self._deferBlackCloseForUIScene = false
	self._deferredUISceneActivationPending = false
	self._pendingUISceneOpenCallbacks = nil

	self:releaseBlackTransitionCameraSuppression()
end

function UICtrl:_startLoadState(cb)
	self._loadState = UIConst.LOAD_STATE.LOADING

	local needRaycaster = true

	if self.uiConfig.needRaycaster ~= nil then
		needRaycaster = self.uiConfig.needRaycaster
	end

	self:tryCapture()

	self._loadTaskId = self.uiMgr:InstantiateUIView(self.uiConfig.resID, self.uiConfig.uiType, self.uiConfig.syncLoad or false, needRaycaster, function(mediator)
		if self._loadState == UIConst.LOAD_STATE.LOADING then
			if NotNil(mediator) then
				self._loadState = UIConst.LOAD_STATE.LOADED

				self:tryShowBlackBackground()
				self:blackClose()

				local createSucceeded = self:createUI(mediator, self._openInfo)

				if createSucceeded and UNITY_EDITOR then
					mediator.name = string.format("%s-%d", mediator.name, self.uid)
				end
			else
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("ui asset:" .. self.uiConfig.resID .. " is null, ctrl will close.")
				end

				self:close()
			end

			if cb then
				cb()
			end
		else
			pg.global.uiMgr:DestroyItem(mediator)
		end
	end)
end

function UICtrl:checkPlatform()
	if pg.game.input:isUsingGamepad() and UIConst.PLATFORM_CONSOLE[self.uid] then
		return false
	end

	return true
end

function UICtrl:close()
	if self:cancelBlurOpenGate() then
		return
	end

	self:_refreshGameTimeStatusOnClose()

	self.adapter.waitLoadingUI[self.uid] = nil

	if self.view then
		self.view.widget:TryDestroyWithAnim(function()
			if self.view and NotNil(self.view.widget) then
				self:closeImmediately()
			end
		end)
	else
		self:closeImmediately()
	end
end

function UICtrl:closePanel()
	self:close()
end

function UICtrl:tryDestroyUIScene()
	local uiScene = self.uiScene

	if not uiScene or uiScene.expire then
		self.uiScene = nil
		self._uiSceneHiddenWithUICtrl = false

		return
	end

	uiScene:removeUICtrlKey(self.module)

	if not uiScene:checkHasUICtrlBind() then
		pg.game.uiScene:switchOutScene(self._uiSceneName, false, nil, self.module)
	elseif self:hasUISceneOwner() then
		pg.game.uiScene:switchOutScene(self._uiSceneName, true, nil, self.module)
	end

	self.uiScene = nil
	self._uiSceneHiddenWithUICtrl = false
end

function UICtrl:closeImmediately()
	if self:cancelBlurOpenGate() then
		return
	end

	local wasDeferringBlackClose = self._deferBlackCloseForUIScene

	self._isOpen = false
	self._uiSceneVisibleWithUICtrl = nil
	self._uiSceneHiddenWithUICtrl = false

	self:_refreshGameTimeStatusOnClose()

	self._inloadUIScene = false

	self:clearBlackBackground()
	self:clearDeferredUISceneActivation()

	if self._loadState == UIConst.LOAD_STATE.LOADING and self._loadTaskId ~= 0 then
		self.uiMgr:CancelUIAsyncTask(self._loadTaskId)

		self._loadTaskId = 0
	end

	self:clearBlackTimer()
	self:releaseBlurSource()
	self:releaseManagedBlur()

	self._blackFadeInDuration = nil
	self._blackFadeOutDuration = nil
	self._loadState = UIConst.LOAD_STATE.NONE

	if self:needBlackChangeOnClose() then
		local fadeInDuration = 0.1

		self.adapter:beginUISceneBlack()
		self.adapter:blackFadeIn(fadeInDuration)

		local closeView = self.view
		local closeVisible = self._curVisible

		TimerManager.addTimer(fadeInDuration, function()
			if self._isOpen then
				self.adapter:endUISceneBlack(0.3)

				return
			end

			self:tryDestroyUIScene()

			local ok, errors = ClientUtils.tryWithLogError(function()
				if closeView then
					if closeVisible and self._curVisible == nil then
						self._curVisible = true
					end

					self:destroyUI()
					closeView:destroy(true)

					if self.view == closeView then
						self.view = nil
					end
				elseif self._visible then
					self.adapter:onUIHide(self.uid, self)
				end
			end)

			self._curVisible = nil

			if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("UICtrl close ui failed:", self.uid)
			end

			TimerManager.addSpecificFrameCb(4, false, function()
				self.adapter:endUISceneBlack(0.3)
			end)
		end)
	else
		if wasDeferringBlackClose then
			self.adapter:blackFadeOut(0)
		else
			self.adapter:blackFadeOut(0, true)
		end

		self:tryDestroyUIScene()

		local ok, errors = ClientUtils.tryWithLogError(function()
			if self.view then
				self:destroyUI()
				self.view:destroy()

				self.view = nil
			elseif self._visible then
				self.adapter:onUIHide(self.uid, self)
			end
		end)

		if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UICtrl close ui failed:", self.uid)
		end
	end

	self._curVisible = nil

	self.adapter:onUIRemove(self.uid, self)
	self:dealCloseCallback()
end

function UICtrl:needBlackChangeOnClose()
	if not self._uiSceneName or not self._visible or not self.uiScene or self.uiScene.expire then
		return false
	end

	local fullScreen = (self.uiConfig.uiType == UIConst.PANEL_LAYER or self.uiConfig.uiType == UIConst.POPUP_LAYER) and self.uiConfig.fullScreen ~= false

	if not fullScreen then
		return false
	end

	if not self:isUISceneActive() then
		return false
	end

	if self.uiConfig.addBlackChangeOnClose then
		return true
	end

	local uiSceneStack = pg.game.uiScene.uiSceneStack
	local previousScene = uiSceneStack[#uiSceneStack - 1]

	return previousScene == nil or previousScene.name ~= self._uiSceneName
end

function UICtrl:show()
	if self._visible ~= true then
		self._visible = true

		self:refreshUIVisible()
		self:showUI()
	end
end

function UICtrl:resetVisibleState()
	self._visible = true
end

function UICtrl:hide()
	if self._visible ~= false then
		self._visible = false

		self:refreshUIVisible()
		self:hideUI()
		self:dealCloseCallback()
	end
end

function UICtrl:openOrShow(info)
	if not self.view then
		self:open(info)
	end

	self:show()
end

function UICtrl:checkUIVisible()
	return self.view and self._curVisible and self._isOpen
end

function UICtrl:checkUIOpen()
	return self._isOpen
end

function UICtrl:checkGameTimeStopActive()
	if self._isOpen ~= true or self._shouldRefreshGameTimeOnClose ~= true then
		return false
	end

	if not self.view or IsNil(self.view.widget) then
		return false
	end

	if self.view.widget.isClosing then
		return false
	end

	return true
end

function UICtrl:collectGameTimeStopDebugInfo()
	local hasView = self.view ~= nil
	local widgetAlive = hasView and not IsNil(self.view.widget)

	return {
		uid = self.uid,
		module = self.module,
		resID = self.uiConfig and self.uiConfig.resID,
		isOpen = self._isOpen == true,
		shouldRefreshOnClose = self._shouldRefreshGameTimeOnClose == true,
		hasView = hasView,
		widgetAlive = widgetAlive,
		isClosing = widgetAlive and self.view.widget.isClosing == true or false,
		active = self:checkGameTimeStopActive() == true
	}
end

function UICtrl:checkUIClosing()
	if not self._isOpen then
		return true
	end

	if self.view and self.view.widget.isClosing then
		return true
	end

	return false
end

function UICtrl:checkUIAssetReady()
	return self._loadState == UIConst.LOAD_STATE.LOADED
end

function UICtrl:checkUIShow()
	return self:checkUIOpen() and self._visible
end

function UICtrl:checkUIIgnore()
	if self:getIsModel() then
		return false
	end

	return self.uiConfig.ignore
end

function UICtrl:checkUILockCursor()
	return self.uiConfig.lockCursor
end

function UICtrl:checkUIShowVirtualMouseCursor()
	if self.view and NotNil(self.view.widget) and self.view.widget.enableNavRegion and not self.view.widget.navRegionForceCursorOn then
		return false
	end

	return true
end

function UICtrl:tryToastVirtualMouseTips()
	if not self:checkUIVisible() or self.adapter:getTopFirstPanel() ~= self.uid then
		return
	end

	if self:checkUILockCursor() or not self:checkUIShowVirtualMouseCursor() then
		return
	end

	if not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if navMgr and (navMgr.IsVirtualMouseMode or navMgr.HasActiveUnblockedNavigation) then
		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("CONSOLE_ENTER_CURSOR_MODE"))
end

function UICtrl:checkUseModel()
	if not self:getIsModel() then
		return false
	end

	if self.view then
		return self._curVisible
	end

	return self:getUIVisible()
end

function UICtrl:checkUseGamepadModel()
	if self:checkUseModel() then
		return true
	end

	if not self._panelConfig.gamepadModel then
		return false
	end

	if self.view then
		return self._curVisible
	end

	return self:getUIVisible()
end

function UICtrl:getUIVisible()
	if not self._visible then
		return false
	end

	if not self._isOpen then
		return false
	end

	if not Utils.tableIsEmptyOrNil(self.hideMarkDict) then
		return false
	end

	return self._adapterVisibilityState == UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE
end

function UICtrl:refreshUIVisible(forceHideUI, forbidNotifyTrigger)
	if self._isOpen then
		self._adapterVisibilityState = self.adapter:getAdapterVisibilityState(self)
	end

	if not self.view then
		return
	end

	local visible

	visible = (not forceHideUI or false) and self:getUIVisible()

	if self._curVisible ~= visible then
		self._curVisible = visible

		self:_setUIVisible(visible, nil, false, forbidNotifyTrigger)
	end

	self:refreshUISceneVisible(forceHideUI)
end

function UICtrl:setUIHide(key, enable)
	if enable then
		self.hideMarkDict[key] = true
	else
		self.hideMarkDict[key] = nil
	end

	self:refreshUIVisible()
end

function UICtrl:applyPanelConfig(mediator)
	local widget = mediator.transform:GetComponent("UWidget")

	if IsNil(widget) then
		return
	end

	widget.customData = self._panelConfig

	if CS.XGUI.Navigation.NavModeSwitch.Instance then
		CS.XGUI.Navigation.NavModeSwitch.Instance:RefreshVirtualMouseToggleOwner()
	end
end

function UICtrl:setOrderWidget(order)
	self._panelConfig.orderWidget = order
end

function UICtrl:getOrderWidget()
	return self._panelConfig.orderWidget
end

function UICtrl:setIsModel(isModel)
	local panelConfig = self._panelConfig

	panelConfig.isModel = isModel

	pg.global.ui:onIsModelChanged(self.uid, self)
end

function UICtrl:setIsGamepadModel(isModel)
	local panelConfig = self._panelConfig

	panelConfig.gamepadModel = isModel

	pg.global.ui:onIsModelChanged(self.uid, self)
end

function UICtrl:getIsModel()
	return self._panelConfig.isModel
end

function UICtrl:setGamepadPass(pass)
	self._panelConfig.gamepadPass = pass
end

function UICtrl:getGamepadPass()
	return self._panelConfig.gamepadPass
end

function UICtrl:createUI(mediator, info)
	local ok = ClientUtils.tryWithLogError(function()
		self:applyPanelConfig(mediator)

		local viewClz = self.adapter:genModuleClass(self.uid, self.module, "View")

		self.view = viewClz.new(mediator, self.uid)

		self.adapter:onUICreate(self.uid, self)
		self:preCreate(info)
		self:openUI(info)
		self:openGamePadInner()
	end)

	if not ok then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UICtrl createUI failed uid:", self.uid)
		end

		return false
	end

	return true
end

function UICtrl:tryCapture()
	if not self.uiConfig.addBlurBg then
		return
	end

	local blurBgParam = self:getBlurBgParam(1)
	local blurOnlyScene = blurBgParam == nil or blurBgParam == UIConst.BLUR_BG_ONLY_SCENE

	CS.UIBlurEffect.CaptureSource(blurOnlyScene, function(source)
		if not self._isOpen then
			CS.UIBlurEffect.ReleaseCapturedSource(source)

			return
		end

		self._blurSource = source
	end)
end

function UICtrl:tryCreateBlurBg()
	if not self.uiConfig.addBlurBg then
		return
	end

	self.view:addPrefabWithPathAsync(self.view.transform, AddressDataConst.UI_BLUR_PREFAB, function(item)
		if IsNil(item.gameObject) then
			return
		end

		item.transform:SetAsFirstSibling()

		local loadedBlurEffect = item.gameObject.transform:GetComponentInChildren(typeof(CS.UIBlurEffect))

		if NotNil(loadedBlurEffect) then
			local blurBgParam = self:getBlurBgParam(1)

			if blurBgParam ~= nil then
				loadedBlurEffect.onlyScene = blurBgParam == UIConst.BLUR_BG_ONLY_SCENE
			end

			if self._blurSource then
				loadedBlurEffect:SetCapturedSource(self._blurSource)

				self._blurSource = nil
			end
		end
	end)
end

function UICtrl:getBlurBgParam(index)
	local addBlurBg = self.uiConfig.addBlurBg

	if not addBlurBg or addBlurBg[index] == nil then
		return nil
	end

	return addBlurBg[index]
end

function UICtrl:releaseBlurSource()
	if self._blurSource then
		CS.UIBlurEffect.ReleaseCapturedSource(self._blurSource)

		self._blurSource = nil
	end
end

function UICtrl:openUI(info, isReOpen)
	self.adapter:onUIOpen(self.uid, self)
	self:onOpen(info)
	self:_tryBindFunctionIdHotKeyClose()
	self:refreshUIVisible()

	if self._visible then
		self:showUI(isReOpen, true)
	end

	self:onPostOpen(info, isReOpen)
end

function UICtrl:_tryBindFunctionIdHotKeyClose()
	local functionID = self.uiConfig and self.uiConfig.functionID

	if not functionID then
		return
	end

	local actionPath = LuaUIUtils.getFuncActionPath(functionID)

	self:bindKeyClose(actionPath)
end

function UICtrl:destroyUI()
	if self._curVisible then
		self._curVisible = false

		ClientUtils.tryWithLogError(function()
			self:_setUIVisible(false, true)
		end)
	end

	if self._visible then
		ClientUtils.tryWithLogErrorEx(self.hideUI, self)
	end

	self:destroyComponents()
	self:onGamePadDestroy()
	self:removeAllRelatedNpc()
	ClientUtils.tryWithLogErrorEx(self.onDestroy, self)
	self:clearComponets()
	self:killAllTimer()
	self:removeAllNavListeners()
	self.adapter:onUIClose(self.uid, self)
end

function UICtrl:_refreshGameTimeStatusOnClose()
	if not self._shouldRefreshGameTimeOnClose then
		return
	end

	self._shouldRefreshGameTimeOnClose = false

	if pg.space then
		ClientUtils.tryWithLogErrorEx(pg.space.CheckAndSetGameTimeStatus, pg.space)
	end
end

function UICtrl:_refreshGameTimeStatusOnOpen()
	if self._shouldRefreshGameTimeOnClose then
		return
	end

	if table.contains(UIConst.StopGameTimeUI, self.uid) then
		self._shouldRefreshGameTimeOnClose = true

		if pg.space then
			pg.space:CheckAndSetGameTimeStatus()
		end
	end
end

function UICtrl:onVisibleChange(visible)
	return
end

function UICtrl:onUISceneVisibleChange(visible)
	if self:shouldSyncUISceneVisibleWithUI() then
		self:onVisibleChangeUIScene(visible)
	end
end

function UICtrl:onVisibleChangeUIScene(visible, skipSwitchToScene)
	if not self.uiScene or self.uiScene.expire then
		if self.uiScene and self.uiScene.expire then
			self.uiScene = nil
			self._uiSceneHiddenWithUICtrl = false
		end

		return
	end

	self._syncUISceneVisibleWithUI = true

	local hasSceneOwner = self:hasUISceneOwner()

	if not visible then
		if self.uiConfig.deferUISceneLoad and not hasSceneOwner then
			if self.uiScene then
				self.uiScene:onCtrlVisibleChange(self.module, false)
			end

			return
		end

		self._uiSceneHiddenWithUICtrl = true

		if self.uiScene then
			self.uiScene:onCtrlVisibleChange(self.module, false)
		end

		if not self._deferredUISceneActivationPending and hasSceneOwner then
			pg.game.uiScene:switchOutScene(self._uiSceneName, true, nil, self.module)
		end

		return
	end

	if self._deferredUISceneActivationPending then
		return
	end

	if self.uiConfig.deferUISceneLoad and not self._uiSceneHiddenWithUICtrl and not hasSceneOwner then
		return
	end

	if self.uiScene then
		self.uiScene:onCtrlVisibleChange(self.module, visible)

		if self._uiSceneHiddenWithUICtrl and not hasSceneOwner and not skipSwitchToScene then
			pg.game.uiScene:switchToScene(self._uiSceneName, self._uiSceneIgnoreDisableMainCamera, self._uiSceneOpenAdditive, self._uiSceneIgnoreResetUICamera, self.module)
		end
	end

	self._uiSceneHiddenWithUICtrl = false
end

function UICtrl:showUI(isReOpen, isOpen)
	self.adapter:onUIShow(self.uid, self)

	if not self.view then
		return
	end

	self:scheduleManagedBlurCapture()

	if isReOpen then
		return
	end

	self:onGamePadEnabled()

	for idx, component in ipairs(self.uiComponents) do
		component:onParentShow()
	end

	self:initConsoleBarStateKeys()
	self:tryToastVirtualMouseTips()
	ClientUtils.tryWithLogErrorEx(self.onShow, self, isReOpen, isOpen)
end

function UICtrl:hideUI()
	self.adapter:onUIHide(self.uid, self)
	self:cancelManagedBlurDelayTimer()

	if not self.view then
		return
	end

	for idx, component in ipairs(self.uiComponents) do
		component:onParentHide()
	end

	ClientUtils.tryWithLogErrorEx(self.onUICtrlHide, self)
end

function UICtrl:onUICtrlHide()
	self:onHide()
	self:onGamePadDisable()
end

function UICtrl:setViewVisible(visible)
	if self.uiConfig.hideByOutOfView then
		self.view:setViewVisibleByOutOfView(visible)
	else
		self.view:setViewVisible(visible)
	end
end

function UICtrl:checkVirtualMouseHoverSnapEnabled()
	return false
end

function UICtrl:refreshVirtualMouseHoverSnapEnabled()
	local enabled = false

	if pg.game.input:isUsingGamepad() then
		for _, ctrl in pairs(self.adapter.ctrlDict) do
			if ctrl._curVisible and ctrl:checkVirtualMouseHoverSnapEnabled() then
				enabled = true

				break
			end
		end
	end

	if pg.global.inputMgr:GetVirtualMouseHoverSnapEnabled() ~= enabled then
		pg.global.inputMgr:SetVirtualMouseHoverSnapEnabled(enabled)
	end
end

function UICtrl:_setUIVisible(visible, isDestroy, isRecursion, forbidNotifyTrigger)
	if not self.view then
		return
	end

	if not isDestroy then
		self:setViewVisible(visible)
	end

	for idx, component in ipairs(self.uiComponents) do
		component:onParentVisibleChange(visible)
	end

	self:onVisibleChange(visible)
	self:refreshVirtualMouseHoverSnapEnabled()

	if not forbidNotifyTrigger then
		if pg.me ~= nil and visible then
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_OPEN_INTERFACE, self.uid, 1)
		end

		if pg.me ~= nil and not visible then
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_CLOSE_INTERFACE, self.uid, 1)
		end

		if pg.me ~= nil then
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_OPENING_INTERFACE, self.uid)
		end
	end

	self.adapter:onUIVisibleChange(self.uid, self, visible)
end

function UICtrl:addUIComponent(component)
	self.uiComponents[#self.uiComponents + 1] = component
	self.uiComponentsSet[component] = true
end

function UICtrl:destroyComponents()
	local comps = self.uiComponents

	for _, component in ipairs(comps) do
		ClientUtils.tryWithLogErrorEx(component.destroy, component)
	end

	self.uiComponents = {}
end

function UICtrl:clearComponets()
	local comps = self.uiComponentsSet

	for k, v in next, self do
		if comps[v] then
			self[k] = nil
		end
	end

	self.uiComponentsSet = {}
end

function UICtrl:preCreate(info)
	self:tryInitGamePad()
	self:onCreate(info)
end

function UICtrl:onCreate(info)
	self:tryCreateBlurBg()

	if self.uiConfig.blurScene then
		self.adapter:setGauBlurScene(self.uid, true)
	end

	local uiType = self.uiConfig.uiType
	local openAudio = self.uiConfig.openAudio

	if uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER then
		openAudio = openAudio or UIConst.DEFAULT_OPEN_AUDIO
	end

	pg.game.audio:triggerEvent(openAudio)
	self:addCommonQuitListener()
	self:addListener()
	self:_refreshGameTimeStatusOnOpen()
end

function UICtrl:initConsoleBarStateKeys()
	self:refreshConsoleBarState()
end

function UICtrl:refreshConsoleBarState()
	return
end

function UICtrl:onOpen(info)
	return
end

function UICtrl:onPostOpen(info, isReOpen)
	return
end

function UICtrl:onDestroy()
	self:releaseManagedBlur()

	if self.uiConfig.blurScene then
		self.adapter:setGauBlurScene(self.uid, false)
	end

	self:dealOpenInfo()
end

function UICtrl:dealOpenInfo()
	if self._openInfo == nil then
		return
	end

	if type(self._openInfo) ~= "table" then
		return
	end
end

function UICtrl:dealCloseCallback()
	if self._closeCb ~= nil then
		local cb = self._closeCb

		self._closeCb = nil

		ClientUtils.tryWithLogError(cb)
	end
end

function UICtrl:checkInfoValid(info)
	return true
end

function UICtrl:checkCanOpen(showNotice, info)
	if self.uid == UIConst.UI_ID_QUEST_PANEL then
		return true
	end

	local funcName = FuncUIDMap[self.uid]

	if funcName then
		local funcCfg = FuncIdConfigData[funcName]

		if not pg.me:checkFunctionUnlock(funcName) then
			local tipText = pg.getLocalizationText(funcCfg.unlockDesc or "")

			pg.global.ui.tips:showTextTip(tipText)

			return false
		end

		if CommonSwitch[funcName] == false then
			local tipText = pg.getGameString("FUNCTION_NOT_OPEN")

			pg.global.ui.tips:showTextTip(tipText)

			return false
		end

		if not LuaUIUtils.checkUIFuncValid(self.uid) then
			return false
		end

		if funcCfg.entrance and LuaUIUtils.checkFuncIdForbidden(funcCfg.entrance[2]) then
			local tipText = pg.getGameString("FUNCTION_CANT_STATE")

			pg.global.ui.tips:showTextTip(tipText)

			return false
		end
	end

	if self.checkOpenExtra then
		local canOpen, tipText = self:checkOpenExtra(info)

		if not canOpen then
			pg.global.ui.tips:showTextTip(tipText or pg.getGameString("FUNCTION_NOT_OPEN"))

			return false
		end
	end

	if not self:checkInfoValid(info) then
		return false
	end

	return true
end

function UICtrl:addListener()
	return
end

function UICtrl:addCommonQuitListener()
	if not self:checkCommonQuit() then
		return
	end

	local curUid = self.uid
	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = -1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if pg.game.input:isUsingGamepad() then
				local panelUID = pg.global.ui:getTopFirstPanel()

				if panelUID then
					local panelCtrl = pg.global.ui:tryGetCtrlByUid(panelUID)

					if not panelCtrl or panelCtrl:checkCommonQuit() then
						pg.global.ui:closePanel(panelUID)

						return false
					end
				end

				return true
			else
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui:closePanel(UIConst.UI_ID_COMMON_ITEM_TIP)
				end

				local buttonPoppingUpTooltip = pg.global.inputMgr:GetButtonPoppingUpToolTip()

				if buttonPoppingUpTooltip then
					buttonPoppingUpTooltip:ClosePopup()
				else
					local panelUID = pg.global.ui:getTopFirstPanel()

					if panelUID then
						local panelCtrl = pg.global.ui:tryGetCtrlByUid(panelUID)

						if not panelCtrl or panelCtrl:checkCommonQuit() then
							pg.global.ui:closePanel(panelUID)

							return false
						end
					end

					return true
				end
			end
		end
	end
end

local BTNBACK_FIXED_PATH = "SafeBoxMobile/Window/TopBack/TitleBar/FrameTitle/BtnBack"

function UICtrl:bindCloseButton(btn, gamepadPath, pcPath)
	if not btn then
		local t = self.view.widget.transform:Find(BTNBACK_FIXED_PATH)

		if t then
			btn = t:GetComponent("UButton")
		end
	end

	if not btn then
		local all = self.view.widget.transform:GetComponentsInChildren(typeof(CS.XGUI.UButton), false)

		if all then
			for i = 0, all.Length - 1 do
				if all[i].name == "BtnBack" then
					btn = all[i]

					break
				end
			end
		end
	end

	if not btn then
		logger:error("bindCloseButton: BtnBack not found in", self.uid)

		return
	end

	btn:SetGamepadAction(gamepadPath or "Common/GamepadCancel")
	btn:SetPCAction(pcPath or "Raw/KeyBoardEsc")
end

function UICtrl:checkCommonQuit()
	if self.uiConfig then
		return self.uiConfig.blockCommonQuit ~= true
	end

	return true
end

function UICtrl:onShow(isOpen)
	local uiType = self.uiConfig.uiType

	if self.uiConfig.fxAA and uiType == UIConst.PANEL_LAYER or uiType == UIConst.POPUP_LAYER then
		pg.global.ui.uiMgr:SwitchUICameraAA(true)
	end
end

function UICtrl:onHide()
	if self.uiConfig.fxAA then
		pg.global.ui.uiMgr:SwitchUICameraAA(false)
	end
end

local DEFAULT_WHITE_LIST = {}

function UICtrl:getWhiteList()
	return DEFAULT_WHITE_LIST
end

function UICtrl:dismiss()
	self:close()
end

function UICtrl:getExcludeResetInputActions()
	return {}
end

function UICtrl:startFrameTimer(func, frame)
	local frameId = TimerManager.addSpecificFrameCb(frame, false, func)

	return frameId
end

function UICtrl:startTimer(func, delay, loop)
	local timerId

	loop = loop or false

	if loop then
		timerId = TimerManager.addRepeatTimer(delay, func)
	else
		self:checkAndCleanFinishedTimers()

		timerId = TimerManager.addTimer(delay, func)
	end

	self._timerIds[timerId] = loop

	return timerId
end

function UICtrl:checkAndCleanFinishedTimers()
	for timerId, isLoop in pairs(self._timerIds) do
		if not isLoop and not TimerManager.checkTimerValid(timerId) then
			self._timerIds[timerId] = nil
		end
	end
end

function UICtrl:killTimer(timerId)
	if timerId then
		TimerManager.removeTimer(timerId)

		self._timerIds[timerId] = nil
	end
end

function UICtrl:startScaleTimer(func, delay, loop)
	local timerId

	loop = loop or false
	timerId = pg.game.timer:addScaleTimer(delay, func, loop)
	self._scaleTimerIds[timerId] = timerId

	return timerId
end

function UICtrl:killScaleTimer(timerId)
	if timerId then
		pg.game.timer:removeScaleTimer(timerId)

		self._scaleTimerIds[timerId] = nil
	end
end

function UICtrl:killAllTimer()
	for timerId, _ in pairs(self._timerIds) do
		TimerManager.removeTimer(timerId)
	end

	self._timerIds = {}

	for timerId, _ in pairs(self._scaleTimerIds) do
		pg.game.timer:removeScaleTimer(timerId)
	end

	self._scaleTimerIds = {}
end

function UICtrl:addNavFocusListener(callback, name)
	if not name then
		name = tostring(self.uid)
	else
		name = name .. tostring(self.uid)
	end

	if self._navListenerNames[name] then
		return
	end

	pg.global.navMgr:AddLuaFocusCursorMovedListener(name, callback)

	self._navListenerNames[name] = true
end

function UICtrl:removeAllNavListeners()
	if not pg.global.navMgr then
		return
	end

	for n, _ in pairs(self._navListenerNames) do
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener(n)
	end

	self._navListenerNames = {}
end

function UICtrl:addRelatedNpc(npcGlobalId)
	if not npcGlobalId or not table.contains(SysConfigData.needPauseAIUIList, self.uid) then
		return
	end

	AIUtils.PauseAI(npcGlobalId, AiConst.PauseBtReason.NpcInteractUIStart + self.uid)

	self._relatedNpcIds[npcGlobalId] = true
end

function UICtrl:removeRelatedNpc(npcGlobalId)
	if not npcGlobalId or not table.contains(SysConfigData.needPauseAIUIList, self.uid) then
		return
	end

	self:resetNpcRotation(npcGlobalId)
	AIUtils.ResumeAI(npcGlobalId, AiConst.PauseBtReason.NpcInteractUIStart + self.uid)

	self._relatedNpcIds[npcGlobalId] = nil
end

function UICtrl:removeAllRelatedNpc()
	if not table.contains(SysConfigData.needPauseAIUIList, self.uid) then
		return
	end

	for npcId, _ in pairs(self._relatedNpcIds) do
		AIUtils.ResumeAI(npcId, AiConst.PauseBtReason.NpcInteractUIStart + self.uid)
	end

	self._relatedNpcIds = {}
end

function UICtrl:resetNpcRotation(npcGlobalId)
	if npcGlobalId then
		local interactEntity = pg.getEntity(npcGlobalId)

		if not interactEntity then
			return
		end

		local pData = interactEntity:getConfigData()

		if pData and pData.resetRotation and interactEntity.interactRawRot then
			interactEntity:faceToRotation(interactEntity.interactRawRot)

			interactEntity.interactRawRot = nil
		end
	end
end

function UICtrl:checkSkipBgmAttenuation()
	if self.uiConfig and self.uiConfig.noBgmAttenuation then
		return true
	end

	return false
end

function UICtrl:checkSkipMenuAttenuation()
	if self.uiConfig and self.uiConfig.noBgmAttenuation then
		return true
	end

	return false
end

function UICtrl:bindHotKeyPerform(path, func, obj, bindName, hotKeyContent)
	bindName = bindName or path
	obj = obj or self.view.gameObject

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, bindName)

	if hotKeyContent then
		hotKeyBind.keyBoardContent = hotKeyContent
	end

	hotKeyBind.actionPath = path
	hotKeyBind.isVirtual = true
	hotKeyBind.priority = 999

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if func then
				return func(self, inputInfo)
			end
		elseif inputInfo.phase == "Checked" then
			return false
		end

		return true
	end
end

function UICtrl:bindKeyClose(actionPath)
	if not actionPath then
		return
	end

	self:bindHotKeyPerform(actionPath, function()
		self:closePanel()
	end)
end

function UICtrl:bindTipsGamepadClose()
	self:bindHotKeyPerform("Raw/GamepadButtonEast", function()
		self:close()
	end)
end

function UICtrl:bindHotKey(path, func, longPressFunc, obj, extraInfo)
	local maxPressTime = extraInfo and extraInfo.maxPressTime
	local startTriggerPressTime = extraInfo and extraInfo.startTriggerPressTime
	local longPressEnd = extraInfo and extraInfo.longPressEnd

	startTriggerPressTime = startTriggerPressTime or self.longPressInterval

	local longPressCheckPassFunc = extraInfo and extraInfo.longPressCheckPassFunc

	obj = obj or self.view.transform.gameObject

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, path)

	hotKeyBind.isVirtual = true
	hotKeyBind.priority = -1
	hotKeyBind.actionPath = path

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if longPressCheckPassFunc and longPressCheckPassFunc() then
				if self[path .. "press"] then
					self:killTimer(self[path .. "press"])
				end

				return true
			end

			if longPressFunc then
				if self[path .. "press"] then
					self:killTimer(self[path .. "press"])
				end

				self[path .. "pressTime"] = 0
				self[path .. "press"] = self:startTimer(function()
					self[path .. "pressTime"] = self[path .. "pressTime"] + self.longPressInterval

					if maxPressTime and maxPressTime < self[path .. "pressTime"] then
						return
					end

					if startTriggerPressTime and startTriggerPressTime >= self[path .. "pressTime"] then
						return
					end

					longPressFunc(self[path .. "pressTime"])
				end, self.longPressInterval, true)
			end
		elseif inputInfo.phase == "Canceled" then
			if self[path .. "press"] then
				self:killTimer(self[path .. "press"])

				if self[path .. "pressTime"] <= startTriggerPressTime and func then
					func()
				end

				if longPressEnd then
					longPressEnd()
				end

				self[path .. "pressTime"] = nil
			elseif func then
				func()
			end
		end
	end

	return hotKeyBind
end

function UICtrl:longClickLuafunction(inputInfo, path, triggerPressTime, startTriggerPressTime, func, progress, cancelFunc, skipShortPressReplay)
	local pressName = path .. "press"
	local pressTimeName = path .. "pressTime"

	if inputInfo.phase == "Performed" then
		if self[pressName] then
			self:killTimer(self[pressName])
		end

		self[pressTimeName] = 0

		progress:ProgressToValue(0, nil, 0)

		self[pressName] = self:startTimer(function()
			if self[pressTimeName] >= triggerPressTime then
				return
			end

			self[pressTimeName] = self[pressTimeName] + Time.unscaledDeltaTime

			if self[pressTimeName] > startTriggerPressTime then
				progress:ProgressToValue(getLongPressProgress(self[pressTimeName], startTriggerPressTime, triggerPressTime), nil, 0)
			end

			if self[pressTimeName] >= triggerPressTime then
				if func then
					func()
				end

				self[pressTimeName] = 0

				self:killTimer(self[pressName])

				self[pressName] = nil
			end
		end, 0, true)
	elseif inputInfo.phase == "Canceled" then
		if self[pressName] then
			self:killTimer(self[pressName])

			if not skipShortPressReplay and startTriggerPressTime >= self[pressTimeName] then
				pg.game.input:triggerWaitAction(inputInfo.inputControl, {
					path
				})
			end

			self[pressTimeName] = 0
			self[pressName] = nil

			progress:ProgressToValue(0, nil, 0)
		end

		if cancelFunc then
			cancelFunc()
		end
	end
end

function UICtrl:bindHotKeyWithProgress(path, func, obj, progress, cancelFunc, extraInfo)
	local triggerPressTime = extraInfo and extraInfo.triggerPressTime or DEFAULT_LONG_PRESS_DURATION
	local startTriggerPressTime = extraInfo and extraInfo.startTriggerPressTime or DEFAULT_LONG_PRESS_START_TIME
	local passThrough = extraInfo and extraInfo.passThrough == true
	local gamepadOnly = extraInfo and extraInfo.gamepadOnly == true
	local priority = extraInfo and extraInfo.priority or -1

	obj = obj or self.view.transform.gameObject

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, path)

	hotKeyBind.enabled = true
	hotKeyBind.isVirtual = true
	hotKeyBind.priority = priority
	hotKeyBind.actionPath = path

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Checked" then
			return false
		end

		if gamepadOnly and not pg.game.input:isUsingGamepad() then
			if inputInfo.phase == "Performed" and func then
				func()
			end

			return false
		end

		UICtrl.longClickLuafunction(self, inputInfo, path, triggerPressTime, startTriggerPressTime, func, progress, cancelFunc, passThrough)

		return passThrough
	end

	return hotKeyBind
end

function UICtrl:bindGamepadScrollUList(uList, scrollSpeed, isUpAndDown)
	if uList == nil then
		return
	end

	scrollSpeed = scrollSpeed or 150

	local listScrollGamepadBind = KeyBindingPro.GetOrAddKeyBindingByName(uList.gameObject, "listScrollGamepadBind")

	listScrollGamepadBind.actionPath = "Hud/ScrollGamepad"
	listScrollGamepadBind.isVirtual = true
	listScrollGamepadBind.priority = -1

	function listScrollGamepadBind.luaTrigger(inputInfo)
		self.ScrollGamepadDelta = inputInfo.valueVec2 * scrollSpeed

		if isUpAndDown then
			self.ScrollGamepadDelta.x = 0
		else
			self.ScrollGamepadDelta.y = 0
		end

		if inputInfo.phase == "Performed" then
			if self.ScrollGamepadTimer == nil then
				self.ScrollGamepadTimer = self:startTimer(function()
					local targetPos = uList.currentScrollPosition - self.ScrollGamepadDelta

					uList:GoToPos(targetPos, false)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.ScrollGamepadTimer then
			self:killTimer(self.ScrollGamepadTimer)

			self.ScrollGamepadTimer = nil
		end
	end
end

function UICtrl:bindCommonCloseHotKey(closeFunc)
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel
	self[closeFunc] = closeFunc

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and closeFunc and self[closeFunc] then
			if pg.game.input:isUsingGamepad() and pg.global.navMgr and pg.global.navMgr:IsActionPathOccupied("Raw/GamepadButtonEast") then
				return true
			end

			self[closeFunc](self)
		end
	end
end

function UICtrl:onRequestGamePadComponent()
	return ""
end

function UICtrl:openGamePadInner()
	self:inputDeviceChanged()
end

function UICtrl:inputDeviceChanged(device)
	self:refreshConsoleBarState()
end

function UICtrl:tryInitGamePad()
	do return false end

	if not pg.game.input:isUsingGamepad() then
		return false
	end

	if self._GamePadCmp then
		return true
	end

	local csPath = self:onRequestGamePadComponent()

	if string.isNilOrEmpty(csPath) then
		return false
	end

	local result, cs = xpcall(require, debug.traceback, csPath)

	if not result then
		logger:error(cs)

		return false
	end

	self._GamePadCmp = cs.new(self.view)

	return true
end

function UICtrl:onGamePadDestroy()
	self:onGamePadDisable()
	self:disposeGamePad()
end

function UICtrl:onGamePadStart()
	if self._GamePadCmp == nil then
		return
	end

	self._GamePadCmp:initGamePad()
end

function UICtrl:onGamePadEnabled()
	if self._GamePadCmp == nil then
		return
	end

	self._GamePadCmp:enableGamePad()
end

function UICtrl:onGamePadDisable()
	if self._GamePadCmp == nil then
		return
	end

	self._GamePadCmp:disableGamePad()
end

function UICtrl:disposeGamePad()
	if self._GamePadCmp then
		self._GamePadCmp:destroy()
	end

	self._GamePadCmp = nil
end

function UICtrl:getManagedBlurConfig()
	return UIConst.UI_BLUR_CONFIGS[self.uid]
end

function UICtrl:getManagedBlurEffect()
	return nil
end

function UICtrl:shouldCaptureBlurBeforeOpen(blurConfig)
	if not blurConfig or blurConfig.timing ~= UIConst.BLUR_TIMING.BEFORE_OPEN then
		return false
	end

	if self._isOpen or self.view then
		return false
	end

	if self._blurPreOpenPrepared then
		return false
	end

	return true
end

function UICtrl:captureBlurBeforeOpen(blurConfig, gateContext, continuation)
	local target = blurConfig.target

	if target == nil or target == UIConst.BLUR_TARGET.FOLLOW_PREFAB then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("BEFORE_OPEN blur capture requires explicit target, uid:", self.uid)
		end

		continuation()

		return
	end

	if blurConfig.partial then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("BEFORE_OPEN blur capture does not support partial, uid:", self.uid)
		end

		continuation()

		return
	end

	self:cancelBlurGateTimer()

	self._blurCaptureVersion = self._blurCaptureVersion + 1
	self._blurGatePending = true
	self._blurGateContext = gateContext
	self._blurGateContinuation = continuation

	local version = self._blurCaptureVersion
	local timeoutFrames = math.max(tonumber(blurConfig.timeoutFrames) or UIConst.BLUR_DEFAULT_TIMEOUT_FRAMES, 1)

	self._blurGateFrameTimerId = self:startFrameTimer(function()
		self._blurGateFrameTimerId = nil

		self:finishBlurBeforeOpen(version, nil)
	end, timeoutFrames)

	CS.UIBlurEffect.CaptureSourceByTarget(target, function(source)
		self:finishBlurBeforeOpen(version, source)
	end)
end

function UICtrl:finishBlurBeforeOpen(version, source)
	if version ~= self._blurCaptureVersion or not self._blurGatePending then
		if source then
			CS.UIBlurEffect.ReleaseCapturedSource(source)
		end

		return
	end

	self:cancelBlurGateTimer()

	self._blurGatePending = false
	self._blurGateContext = nil

	local continuation = self._blurGateContinuation

	self._blurGateContinuation = nil
	self._blurPreOpenPrepared = true

	self:holdManagedBlurSource(source)

	if continuation then
		continuation()
	end
end

function UICtrl:cancelBlurOpenGate()
	if not self._blurGatePending then
		return false
	end

	local gateContext = self._blurGateContext

	self._blurGatePending = false
	self._blurGateContext = nil
	self.adapter.waitLoadingUI[self.uid] = nil

	self:releaseManagedBlur()

	if gateContext then
		if gateContext.fadeOutHudRequested and not self.adapter:checkOtherFadeOutHudHolder(self.uid) then
			self.adapter:tryFadeInHud()
		end

		if gateContext.closeCb then
			ClientUtils.tryWithLogError(gateContext.closeCb)
		end
	end

	return true
end

function UICtrl:holdManagedBlurSource(source)
	if self._managedBlurSource and self._managedBlurSource ~= source then
		CS.UIBlurEffect.ReleaseCapturedSource(self._managedBlurSource)

		self._managedBlurSource = nil
	end

	self._managedBlurSource = source

	if source then
		self:consumeManagedBlurSource()
	end
end

function UICtrl:consumeManagedBlurSource()
	if not self._managedBlurSource or IsNil(self._managedBlurEffect) then
		return
	end

	self._managedBlurEffect:SetCapturedSource(self._managedBlurSource)

	self._managedBlurSource = nil
end

function UICtrl:initializeManagedBlur()
	local blurConfig = self:getManagedBlurConfig()

	if not blurConfig then
		return
	end

	local blurEffect = self:getManagedBlurEffect()

	if IsNil(blurEffect) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("managed blur effect is missing, override getManagedBlurEffect(), uid:", self.uid)
		end

		return
	end

	self:setManagedBlurEffect(blurEffect)
end

function UICtrl:setManagedBlurEffect(blurEffect)
	if IsNil(blurEffect) then
		return
	end

	self._managedBlurEffect = blurEffect

	self:consumeManagedBlurSource()
end

function UICtrl:scheduleManagedBlurCapture()
	local blurConfig = self:getManagedBlurConfig()

	if not blurConfig then
		return
	end

	self:cancelManagedBlurDelayTimer()

	local timing = blurConfig.timing

	if timing == UIConst.BLUR_TIMING.AFTER_SHOW then
		self:captureBlur()

		return
	end

	if timing ~= UIConst.BLUR_TIMING.DELAY then
		return
	end

	local delay = blurConfig.delay

	if delay == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("DELAY blur capture requires delay, uid:", self.uid)
	end

	if type(delay) == "table" then
		local frames = math.max(tonumber(delay.frame) or 1, 1)

		self._blurDelayFrameTimerId = self:startFrameTimer(function()
			self._blurDelayFrameTimerId = nil

			self:captureBlur()
		end, frames)
	else
		local seconds = math.max(tonumber(delay) or 0, 0)

		self._blurDelayTimerId = self:startTimer(function()
			self._blurDelayTimerId = nil

			self:captureBlur()
		end, seconds)
	end
end

function UICtrl:captureBlur()
	local blurConfig = self:getManagedBlurConfig()

	if not blurConfig or IsNil(self._managedBlurEffect) then
		return false
	end

	if not self:checkUIVisible() then
		return false
	end

	self._managedBlurEffect:RequestCapture(blurConfig.target or UIConst.BLUR_TARGET.FOLLOW_PREFAB)

	return true
end

function UICtrl:cancelBlurGateTimer()
	if self._blurGateFrameTimerId then
		TimerManager.delFrameCb(self._blurGateFrameTimerId)

		self._blurGateFrameTimerId = nil
	end
end

function UICtrl:cancelManagedBlurDelayTimer()
	if self._blurDelayTimerId then
		self:killTimer(self._blurDelayTimerId)

		self._blurDelayTimerId = nil
	end

	if self._blurDelayFrameTimerId then
		TimerManager.delFrameCb(self._blurDelayFrameTimerId)

		self._blurDelayFrameTimerId = nil
	end
end

function UICtrl:releaseManagedBlur()
	self._blurCaptureVersion = self._blurCaptureVersion + 1
	self._blurGateContinuation = nil

	self:cancelBlurGateTimer()
	self:cancelManagedBlurDelayTimer()

	if self._managedBlurSource then
		CS.UIBlurEffect.ReleaseCapturedSource(self._managedBlurSource)

		self._managedBlurSource = nil
	end

	self._blurPreOpenPrepared = false
	self._managedBlurEffect = nil
end

return UICtrl
