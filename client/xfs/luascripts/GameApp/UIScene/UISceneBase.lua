-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\UIScene\\UISceneBase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local logger = LoggerManager.getLogger("UISceneBase")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local UISceneBase = Class.LightClass("UISceneBase")

function UISceneBase:ctor(name, resId, additionRes, params)
	self.scene = nil
	self.enable = false
	self.resId = resId
	self.addRes = additionRes or {}
	self.ctorParams = params
	self.addIns = {}
	self.name = name .. (params and params.uiId or "")
	self.expire = false
	self.monitor = {}
	self.timers = {}
	self.entPool = {}
	self.uiCtrlKeys = {}
	self.uiCtrlVisible = {}
	self.sceneLoaded = false
	self.loadSucceed = nil
	self.loadResState = UISceneConst.Scene_Load_State.None
	self.loadTimeout = -1
	self.timeoutTimer = nil
	self.checkAllEntityReadyWhiteList = nil

	self:onCtor()
end

function UISceneBase:startLoad(callback, param)
	self.expire = false
	self.loadSucceed = nil
	self._loadedCallback = callback
	self.loadParam = param

	table.insert(self.addRes, self.resId)
	self:startLoadUISceneRes()
	pg.game.uiScene:registerUIScene(self.name, self)
end

function UISceneBase:bindUICtrlKey(uiCtrlName)
	self.uiCtrlKeys[uiCtrlName] = true
end

function UISceneBase:removeUICtrlKey(uiCtrlName)
	self.uiCtrlKeys[uiCtrlName] = nil
	self.uiCtrlVisible[uiCtrlName] = nil
end

function UISceneBase:checkHasUICtrlBind()
	return not Utils.isEmptyTable(self.uiCtrlKeys)
end

function UISceneBase:checkSceneVisible()
	for _, visible in pairs(self.uiCtrlVisible) do
		if visible then
			return true
		end
	end

	return false
end

function UISceneBase:onCtrlVisibleChange(ctrlName, visible)
	if self.uiCtrlKeys[ctrlName] then
		self.uiCtrlVisible[ctrlName] = visible
	end
end

function UISceneBase:startLoadUISceneRes()
	if #self.addRes == 0 then
		return
	end

	if self.loadResState ~= UISceneConst.Scene_Load_State.None then
		return
	end

	self.loadResState = UISceneConst.Scene_Load_State.Loading
	self.sceneLoaded = false

	for _, resId in ipairs(self.addRes) do
		self.getInstanceId = pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, userData)
			self.getInstanceId = nil

			if not IsNil(gameObj) then
				gameObj.transform:SetParent(appFacade.uiManager.uiSceneRoot)

				local oldPosition = gameObj.transform.position

				gameObj.transform.position = Vector3.New(oldPosition.x, oldPosition.y + 500, oldPosition.z)

				local audioListeners = gameObj:GetComponentsInChildren(typeof(CS.AkAudioListener))

				if audioListeners then
					for i = 0, audioListeners.Length - 1 do
						audioListeners[i].enabled = false
					end
				end
			end

			self:resLoadFinished(resId, gameObj)
		end)
	end
end

function UISceneBase:checkLoadStateIsNone()
	return self.loadResState == UISceneConst.Scene_Load_State.None
end

function UISceneBase:checkLoaded()
	return self.sceneLoaded
end

function UISceneBase:checkLoadSucceed()
	return self.sceneLoaded and self.loadSucceed == true
end

function UISceneBase:loadUISceneRes(resId, callback)
	if string.isNilOrEmpty(resId) then
		return
	end

	pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, userData)
		if IsNil(gameObj) then
			return
		end

		gameObj.transform:SetParent(appFacade.uiManager.uiSceneRoot)

		self.addIns[resId] = gameObj

		table.insert(self.addRes, resId)
		self:applySingleCameraParam(gameObj)

		if callback then
			callback(gameObj)
		end
	end)
end

function UISceneBase:resLoadFinished(resId, obj)
	self.addIns[resId] = obj or false

	if self.resId == resId then
		self.scene = obj
	end

	local isAllLoaded = true
	local succeed = true

	for _, id in ipairs(self.addRes) do
		local v = self.addIns[id]

		if v == nil then
			isAllLoaded = false

			break
		end

		if v == false then
			succeed = false
		end
	end

	if not isAllLoaded then
		return
	end

	self.sceneLoaded = true
	self.loadSucceed = succeed
	self.loadResState = UISceneConst.Scene_Load_State.Loaded

	if succeed then
		self:onSceneLoaded()
	end

	self:doLoadedCallBack(succeed)
end

function UISceneBase:doLoadedCallBack(succeed)
	if self._loadedCallback then
		local isOk, res = xpcall(self._loadedCallback, debug.traceback, succeed)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Load UI Scene Res Failure with error:", res)
		end
	end

	self._loadedCallback = nil
end

function UISceneBase:destroy()
	self.expire = true

	ClientUtils.tryWithLogErrorEx(self.onDestroy, self)

	if self.getInstanceId then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(self.getInstanceId)

		self.getInstanceId = nil
	end

	self:resetCameraParam()

	if self.scene ~= nil then
		pg.global.resMgr:RemoveInstanceToCache(self.scene, true)
	end

	for entityId, _ in pairs(self.entPool) do
		self:removeEntity(entityId)
	end

	if table.nums(self.addIns) > 0 then
		for _, v in pairs(self.addIns) do
			if v then
				pg.global.resMgr:RemoveInstanceToCache(v, true)
			end
		end
	end

	self.uiCtrlKeys = nil
	self.uiCtrlVisible = nil

	table.clear(self.addIns)
	pg.global.cameraMgr:ClearUISceneCamera()
	self:refreshMainPlayerVisible()
	pg.game.uiScene:unRegisterUIScene(self.name)
	self:killAllTimer()

	self.checkAllEntityReadyWhiteList = nil
end

function UISceneBase:applyCameraParam()
	if self.mobileHighQuality then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetShadowQuality(3)
	end

	for _, ins in pairs(self.addIns) do
		if ins then
			self:applySingleCameraParam(ins)
		end
	end
end

function UISceneBase:applySingleCameraParam(ins)
	local height = pg.game.setting:getUISceneResolutionHeight(self.mobileHighQuality)

	pg.global.cameraMgr:SetUISceneCameraParam(ins, true, height, self.mobileHighQuality)
end

function UISceneBase:resetCameraParam()
	local quality = pg.game.setting:getCommonVideoSettingValue("mainLightShadowQuality")

	CS.FunPlus.WorldX.Setting.VideoSetting.SetShadowQuality(quality)

	for _, ins in pairs(self.addIns) do
		if ins then
			self:resetSingleCameraParam(ins)
		end
	end
end

function UISceneBase:resetSingleCameraParam(ins)
	local height = pg.game.setting:getUISceneResolutionHeight(false)

	pg.global.cameraMgr:SetUISceneCameraParam(ins, false, height, false)
end

function UISceneBase:onSceneLoaded()
	if self.expire then
		self:destroy()

		return
	end

	self:setActive(self.enable)
	self:applyCameraParam()
	self:onStart(self.loadParam)
end

function UISceneBase:setActive(active)
	self.enable = active

	for _, v in pairs(self.addIns) do
		v:SetActiveEx(self.enable)
	end

	self:onActiveChanged(active)
end

function UISceneBase:hidePawnModel()
	return false
end

function UISceneBase:refreshMainPlayerVisible()
	local pawn = pg.pawn

	if pawn then
		pawn:refreshVisible()
	end

	local curPetEnt = pg.me and pg.me:getCurPetEntity() or nil

	if curPetEnt then
		curPetEnt:refreshVisible()
	end
end

function UISceneBase:copyMainPlayer(staticId)
	local initDict = {
		copyEntity = pg.me,
		staticId = staticId
	}

	return self:createEntity(pg.me.uid, ClientSimpleVirtualPlayer, initDict)
end

function UISceneBase:getAllEntities()
	return self.entPool
end

function UISceneBase:getEntity(entityId)
	return self.entPool[entityId]
end

function UISceneBase:getPlayerOriginInitDict(initDict, entityCls)
	if not initDict or not initDict.copyEntity then
		return initDict
	end

	entityCls = entityCls or ClientSimpleVirtualEntity

	if entityCls ~= ClientSimpleVirtualPlayer and not Class.isSubClassOf(entityCls, ClientSimpleVirtualPlayer) then
		return initDict
	end

	local copyEntity = initDict.copyEntity

	if not copyEntity.isDeformToPet or not copyEntity:isDeformToPet() then
		return initDict
	end

	local originInitDict = {}

	for key, value in pairs(initDict) do
		originInitDict[key] = value
	end

	originInitDict.copyEntity = nil
	originInitDict.templateId = copyEntity.templateId
	originInitDict.avatarPresetKey = copyEntity.avatarPresetKey
	originInitDict.avatarConfig = copyEntity.avatarConfig
	originInitDict.curShow = copyEntity.curShow

	return originInitDict
end

function UISceneBase:createEntity(entityId, entityCls, initDict)
	local entity = self:getEntity(entityId)

	if entity then
		return entity
	end

	entityCls = entityCls or ClientSimpleVirtualEntity
	initDict = self:getPlayerOriginInitDict(initDict, entityCls)
	entity = entityCls.new()
	self.entPool[entityId] = entity

	entity:init(initDict)
	entity:postInit(initDict)
	entity:start()
	self:applyHairLayerCount(entity)
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)
	ClientUtils.onClientEntityCreated(entity)

	entity._uiSceneVisible = true
	self.waitLoadEntity = true
	self.timerOut = false

	if self.timeoutTimer then
		self:killTimer(self.timeoutTimer)
	end

	if self.loadTimeout > 0 then
		self.timeoutTimer = self:startTimer(function()
			self:timeOutReady()
		end, self.loadTimeout, false)
	end

	return entity
end

function UISceneBase:setHairLayerCount(layerCount)
	self.hairLayerCount = layerCount

	if not self.hairLayerCount then
		return
	end

	for _, entity in pairs(self.entPool) do
		self:applyHairLayerCount(entity)
	end
end

function UISceneBase:applyHairLayerCount(entity)
	if not self.hairLayerCount or not entity or not entity.eModel then
		return
	end

	local shaderView = entity.eModel.modelShaderView

	if NotNil(shaderView) then
		shaderView:SetMultiPassForce32Layer(true, self.hairLayerCount)
	end
end

function UISceneBase:removeEntity(entityId)
	local entity = self:getEntity(entityId)

	if not entity then
		return
	end

	ClientUtils.safeDestroy(entity)

	self.entPool[entityId] = nil
end

function UISceneBase:showEntityWithId(entityId)
	local ent = self:getEntity(entityId)

	if ent == nil or ent.eModel == nil then
		return
	end

	ent._uiSceneVisible = true

	ent.eModel:SetActive(true)
end

function UISceneBase:hideEntityWithId(entityId)
	local ent = self:getEntity(entityId)

	if ent == nil or ent.eModel == nil then
		return
	end

	ent._uiSceneVisible = false

	ent.eModel:SetActive(false)
end

function UISceneBase:runWhenAnimatorReady(entity, callback)
	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	if NotNil(modelView) and modelView:IsAnimatorRead() then
		callback()

		return
	end

	function entity.onAnimatorReadyCallback()
		callback()
	end
end

function UISceneBase:replayAfterTransmogRefresh(entity, didRefresh, callback)
	if not entity then
		return
	end

	if not didRefresh then
		callback()

		return
	end

	function entity.modelLoadedCallback()
		entity.modelLoadedCallback = nil

		self:runWhenAnimatorReady(entity, callback)
	end
end

function UISceneBase:timeOutReady()
	self.timeoutTimer = nil
	self.timerOut = true
end

function UISceneBase:checkAllEntityReady(ignoreTimeout)
	if self.timerOut and not ignoreTimeout then
		return true
	end

	local allEntities = self:getAllEntities()

	if self.checkAllEntityReadyWhiteList then
		allEntities = {}

		for _, ent in pairs(self.checkAllEntityReadyWhiteList) do
			allEntities[#allEntities + 1] = ent
		end
	end

	for _, entity in pairs(allEntities) do
		if entity._uiSceneVisible == false then
			-- block empty
		else
			local state = entity.eModel:GetCurrentPlayableState(Const.COMPONENT_IDX_PLAYABLE, 2)

			if IsNil(state) then
				state = entity.eModel:GetCurrentPlayableState(Const.COMPONENT_IDX_PLAYABLE, 0)
			end

			if IsNil(state) then
				return false
			end

			if state.Weight < 0.001 then
				return false
			end

			local modelView = entity.eModel.modelModelView

			if not modelView:CheckRendererLoaded() then
				return false
			end
		end
	end

	return true
end

function UISceneBase:checkPresentationReady()
	if not self.sceneLoaded or not self.enable then
		return false
	end

	if self.waitLoadEntity then
		return false
	end

	return self:checkAllEntityReady(true)
end

function UISceneBase:onCtor()
	return
end

function UISceneBase:onStart(param)
	return
end

function UISceneBase:onEnter()
	return
end

function UISceneBase:onExit()
	return
end

function UISceneBase:onEnabled()
	return
end

function UISceneBase:onDisabled()
	return
end

function UISceneBase:onDestroy()
	return
end

function UISceneBase:onActiveChanged(active)
	return
end

function UISceneBase:getPreviewController()
	return self.previewSceneController
end

function UISceneBase:destroyPreviewController()
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:onDestroy()

		self.previewSceneController = nil
	end
end

function UISceneBase:initCameraModes()
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:initCameraModes()
	end
end

function UISceneBase:enableCameraMode(modeName)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:enableCameraMode(modeName)
	end
end

function UISceneBase:disableAllCameras()
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:disableAllCameras()
	end
end

function UISceneBase:startPress(pressFunc, delta, offset)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:startPress(pressFunc, delta, offset)
	end
end

function UISceneBase:inPressing(pressFunc, delta, offset)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:inPressing(pressFunc, delta, offset)
	end
end

function UISceneBase:endPress()
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:endPress()
	end
end

function UISceneBase:addCameraZoomKeyBinding(gameObject, callback, isModelRotationBlocked)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:addCameraZoomKeyBinding(gameObject, callback, isModelRotationBlocked)
	end
end

function UISceneBase:registerGesture(uiId, extraInfo)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:registerGesture(uiId, extraInfo)
	end
end

function UISceneBase:unRegisterGesture(uiId, force)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:unRegisterGesture(uiId, force)
	end
end

function UISceneBase:cameraZoomIn(delta, area)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:cameraZoomIn(delta, area)
	end
end

function UISceneBase:swipeModel(moveVector2, extraInfo)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:swipeModel(moveVector2, extraInfo)
	end
end

function UISceneBase:setPivotOffsetX(offsetX)
	local previewSceneController = self:getPreviewController()

	if previewSceneController then
		previewSceneController:setPivotOffsetX(offsetX)
	end
end

function UISceneBase:claimGlobalGesture()
	UISceneBase._globalGestureOwner = self
end

function UISceneBase:tryReleaseGlobalGesture()
	if UISceneBase._globalGestureOwner == self then
		UISceneBase._globalGestureOwner = nil

		return true
	end

	return false
end

function UISceneBase:onAllEntityLoaded()
	return
end

function UISceneBase:beforeAnimation()
	if self.waitLoadEntity and self:checkAllEntityReady() then
		self.waitLoadEntity = false

		self:onAllEntityLoaded()
	end
end

function UISceneBase:startTimer(func, delay, loop)
	local timerId

	loop = loop or false

	if loop then
		timerId = TimerManager.addRepeatTimer(delay, func)
	else
		timerId = TimerManager.addTimer(delay, func)
	end

	self.timers[timerId] = loop

	return timerId
end

function UISceneBase:killTimer(timerId)
	TimerManager.removeTimer(timerId)

	self.timers[timerId] = nil
end

function UISceneBase:killAllTimer()
	for timerId, _ in pairs(self.timers) do
		TimerManager.removeTimer(timerId)
	end

	self.timers = {}
end

function UISceneBase:setMobileHighQuality(value)
	self.mobileHighQuality = value
end

return UISceneBase
