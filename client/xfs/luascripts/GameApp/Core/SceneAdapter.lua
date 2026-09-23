-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Core\\SceneAdapter.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local SceneData = require("Data.scene_data")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("SceneAdapter")
local AudioConst = require("Const.AudioConst")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local SceneUtils = require("Common.Utils.SceneUtils")
local SysConfigData = require("Data.sys_config_data")
local CoreConst = require("Core.Common.Const")
local TeleportData = require("Data.teleport_data")
local SceneAdapter = Class.OldLightClass("SceneAdapter", nil, true)

SceneAdapter.DEFAULT_LOADING_PANEL_ID = UIConst.UI_ID_LOADING
SceneAdapter.WAIT_ENTS_MAX_TIME = 60
SceneAdapter.EXIT_LOADING_GUARD_TIME = 5
SceneAdapter.SCENE_READY_GUARD_INTERVAL = 5
SceneAdapter.SCENE_REVEAL_FRAME_COUNT = 15

function SceneAdapter:ctor()
	self.curSpace = nil
	self.lastScene = nil
	self.curScene = nil
	self.voxelReady = true
	self.clzMap = {}
	self.additiveScene = {}
	self.waitEnts = {}
	self.isSceneReady = false
	self.blackScreenId = 0
	self.sceneReadyGuardTimer = nil
	self.sceneReadyGuardSceneId = nil
	self.sceneRevealFrameCb = nil
	self.deferSceneReveal = false
end

function SceneAdapter:onSpaceCreated(space)
	self.curSpace = space

	pg.game:onSpaceCreated(space)
end

function SceneAdapter:onSpaceDestroy(space)
	pg.game:onSpaceDestroy(space)

	if space and space.forceReloadOnSwitch then
		self.pendingForceReload = true
	end

	if self.curSpace == space then
		self.curSpace = nil
	end
end

function SceneAdapter:isSameSceneFile(newSceneId)
	local sceneId = 0

	if self.curScene then
		sceneId = self.curScene.sceneId
	end

	local cData = SceneData[newSceneId]
	local sData = SceneData[sceneId]

	if sData and sData.file == cData.file then
		return true
	end

	return false
end

function SceneAdapter:loadScene(newSceneId, portalPos)
	local newForce = pg.space and pg.space.forceReloadOnSwitch
	local oldForce = self.curSpace and self.curSpace.forceReloadOnSwitch
	local pendingForce = self.pendingForceReload
	local forceReload = newForce or oldForce or pendingForce

	self.pendingForceReload = false

	local requireEnvRefresh = not pg.space or pg.space.envRefreshOnEnter ~= false

	if not self:checkNeedSeamlessLoadNewScene(newSceneId, portalPos) then
		self:loadSeamlessScene(newSceneId, portalPos)

		return
	end

	if self:isSameSceneFile(newSceneId) then
		self:loadAddedScene(newSceneId, portalPos, forceReload, requireEnvRefresh)

		return
	end

	if newSceneId ~= ClientConst.SCENE_LOGIN_ID then
		self:showLoadingPanel(newSceneId)
	else
		self:hideLoadingPanel()
	end

	self:destroyCurrScene()

	local levelName = ClientUtils.getSceneName(newSceneId)

	pg.game:onStartLoadScene(newSceneId, levelName)

	self.isSceneReady = false
	self.voxelReady = false

	self:setVoxelReadyCallback()
	self:startEntWaitTimer()
	pg.game.loading:enterSingleLoading(newSceneId)
end

function SceneAdapter:loadAddedScene(newSceneId, portalPos, force, requireEnvRefresh)
	local needShowLoading = force and newSceneId ~= ClientConst.SCENE_LOGIN_ID

	if needShowLoading then
		self:showLoadingPanel(newSceneId)
	end

	self.waitLoadAddedSceneId = newSceneId

	TimerManager.addNextFrameCb(function()
		self.waitLoadAddedSceneId = nil

		if self.curScene:isSameScript(newSceneId) then
			self.curScene:reset(newSceneId)
		else
			self.lastScene = self.curScene
			self.curScene = nil

			self:onLoadingSceneLoaded(newSceneId)

			if self.curScene then
				self.curScene:loaded()
			end
		end

		local triggeredReload = false

		if portalPos and #portalPos >= 3 then
			local pos = Vector3.New(portalPos[1] or 0, portalPos[2] or 0, portalPos[3] or 0)

			if force or appFacade.streamManager:CheckNeedLoad(pos) then
				triggeredReload = self:reloadCurrentScene(pos, requireEnvRefresh) == true
			end
		end

		if self.curScene and not triggeredReload then
			pg.game:onSceneReset(self.curScene.sceneId, self.curScene.sceneName)
		end

		if needShowLoading and not triggeredReload then
			self:hideLoadingPanel()
		end
	end)
end

function SceneAdapter:loadSeamlessScene(newSceneId, portalPos)
	self.waitLoadSeamlessSceneId = newSceneId

	pg.game.seamless:seam_sys_createChannelEntity(CoreConst.CreateClientEntityMode.Seamless)
	TimerManager.addNextFrameCb(function()
		self.waitLoadSeamlessSceneId = nil

		if self.curScene:isSameScript(newSceneId) then
			self.curScene:reset(newSceneId)
		else
			self.curScene:onDestroy()

			self.lastScene = self.curScene
			self.curScene = nil

			self:onLoadingSceneLoaded(newSceneId)

			if self.curScene then
				self.curScene:loaded()
			end
		end

		if self.curScene then
			local sceneId = self.curScene.sceneId

			pg.game:onSceneReset(self.curScene.sceneId, self.curScene.sceneName, {
				isSeamlessScene = true
			})
			pg.game.seamless:onSceneReset(sceneId)
		end

		if portalPos and #portalPos >= 3 then
			local pos = Vector3.New(portalPos[1] or 0, portalPos[2] or 0, portalPos[3] or 0)

			if appFacade.streamManager:CheckNeedLoad(pos) then
				self:reloadCurrentScene(pos)
			else
				self:hideLoadingPanel()
			end
		end
	end)
end

function SceneAdapter:checkDittoSceneLoad()
	if not self.lastScene then
		return
	end

	local lastSceneId = self.lastScene.sceneId
	local curSceneId = self.curScene.sceneId
	local lastData = SceneData[lastSceneId]
	local curData = SceneData[curSceneId]
	local waitLoadSceneData = self.waitLoadAddedSceneId and SceneData[self.waitLoadAddedSceneId]

	return lastData and lastData.type == Const.SPACE_TYPE_DITTO_DUNGEON or curData and curData.type == Const.SPACE_TYPE_DITTO_DUNGEON or waitLoadSceneData and waitLoadSceneData.type == Const.SPACE_TYPE_DITTO_DUNGEON
end

function SceneAdapter:checkNeedSeamlessLoadNewScene(newSceneId, portalPos)
	local cData = SceneData[newSceneId]

	if cData == nil then
		return false
	end

	if not pg.game.loading:isFinished() or not self.curScene then
		return true
	end

	local sData = SceneData[self.curScene.sceneId]

	if sData == nil then
		return true
	end

	if sData.file == cData.file and (SceneUtils.isSeamlessScene(self.curScene.sceneId) or SceneUtils.isSeamlessScene(newSceneId)) then
		local mainSceneId = SceneUtils.getMainSceneId(self.curScene.sceneId)
		local newMainSceneId = SceneUtils.getMainSceneId(newSceneId)

		if mainSceneId == newMainSceneId then
			if portalPos and #portalPos == 3 then
				local pos = Vector3.New(portalPos[1] or 0, portalPos[2] or 0, portalPos[3] or 0)

				if appFacade.streamManager:CheckNeedLoad(pos) then
					return true
				end
			end

			return false
		end
	end

	return true
end

function SceneAdapter:startEntWaitTimer()
	if self.entWaitTimer then
		TimerManager.removeTimer(self.entWaitTimer)

		self.entWaitTimer = nil
	end

	self.entWaitTimer = TimerManager.addTimer(SceneAdapter.WAIT_ENTS_MAX_TIME, function()
		self.entWaitTimer = nil
		self.waitEnts = {}

		if not self.isSceneReady and self:isSceneValid() then
			self:onSceneReady()
		end
	end)
end

function SceneAdapter:reloadCurrentScene(pos, requireEnvRefresh)
	if requireEnvRefresh == nil then
		requireEnvRefresh = true
	end

	local isPVPStarting = false

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PVP_CHOSE) then
		isPVPStarting = true
	end

	if self.curScene then
		pg.game:onStartReloadScene(self.curScene.sceneId, self.curScene.sceneName)

		local newSceneId = self.curScene.sceneId

		if newSceneId ~= ClientConst.SCENE_LOGIN_ID and not isPVPStarting then
			self:showLoadingPanel(newSceneId)
		end

		self.voxelReady = false

		self:setVoxelReadyCallback()

		self.isSceneReady = false

		self:startEntWaitTimer()
		pg.game.loading:enterSingleReloading(newSceneId, pos, requireEnvRefresh)

		return true
	end

	return false
end

function SceneAdapter:setVoxelReadyCallback()
	pg.game.voxel:setRegionLoadedCallback(function()
		self.voxelReady = true

		self:onVoxelReady()
	end)
end

function SceneAdapter:cancelVoxelReadyCallback()
	pg.game.voxel:setRegionLoadedCallback(nil)
end

function SceneAdapter:destroyCurrScene()
	self:cancelVoxelReadyCallback()
	self:cancelSceneReadyGuard()

	if self.curScene then
		pg.game:onSceneUnloaded(self.curScene.sceneId, self.curScene.sceneName)
		self.curScene:onDestroy()

		self.lastScene = self.curScene
		self.curScene = nil
	end
end

function SceneAdapter:onLoadingSceneLoaded(sceneId)
	local sceneClz = self:getOrRegisterScript(sceneId)

	if sceneClz == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("failed to find sceneClz", sceneId)
		end

		return
	end

	if sceneId == ClientConst.SCENE_PVP_Combat then
		self:hideLoadingPanel()
	end

	self.curScene = sceneClz.new(sceneId)

	self.curScene:start(self.lastScene)

	if sceneId == ClientConst.SCENE_LOGIN_ID then
		self.lastScene = nil
	end
end

function SceneAdapter:onSceneLoaded(sceneId, isSuccess, isReloading, deferSceneReveal)
	self.deferSceneReveal = deferSceneReveal == true

	if not self:onCheckSceneValid(sceneId, "SceneLoaded", isSuccess) then
		return
	end

	self:onSceneReady()

	if isReloading then
		pg.game:onEndReloadScene()
	end
end

function SceneAdapter:onVoxelReady()
	local sceneId = self.curScene and self.curScene.sceneId or self.targetSceneId

	if self:onCheckSceneValid(sceneId, "VoxelReady") then
		self:onSceneReady()
	end
end

function SceneAdapter:cancelSceneRevealFrameCb()
	if self.sceneRevealFrameCb then
		TimerManager.delFrameCb(self.sceneRevealFrameCb)

		self.sceneRevealFrameCb = nil
	end
end

function SceneAdapter:prepareSceneReveal()
	self:cancelSceneRevealFrameCb()
	pg.global.ui:enableMainCamera(true)

	local sceneId = self.curScene and self.curScene.sceneId

	logger:info("[@airfeng][loading] Scene reveal warmup started: sceneId=%s, frameCount=%d.", tostring(sceneId), SceneAdapter.SCENE_REVEAL_FRAME_COUNT)

	local frameCbId

	frameCbId = TimerManager.addSpecificFrameCb(SceneAdapter.SCENE_REVEAL_FRAME_COUNT, false, function()
		if self.sceneRevealFrameCb ~= frameCbId then
			return
		end

		self.sceneRevealFrameCb = nil

		if not self.isSceneReady or not self.curScene or self.curScene.sceneId ~= sceneId then
			return
		end

		logger:info("[@airfeng][loading] Scene reveal warmup finished: sceneId=%s, frameCount=%d.", tostring(sceneId), SceneAdapter.SCENE_REVEAL_FRAME_COUNT)
		self:hideLoadingPanel()

		if pg.me and pg.me.tryTriggerPendingTeleportAppear then
			pg.me:tryTriggerPendingTeleportAppear()
		end
	end)
	self.sceneRevealFrameCb = frameCbId
end

function SceneAdapter:onSceneReady()
	self:cancelSceneReadyGuard()

	self.isSceneReady = true

	local deferSceneReveal = self.deferSceneReveal == true

	self.deferSceneReveal = false

	if pg.me and pg.me.clientFirstCreateFlag == true then
		local GmToolUtils = require("Utils.GmToolUtils")

		if pg.me.clientFirstCreateFlag and GmToolUtils.getEnableDebugTrySkipNew() then
			if pg.me.space.sceneId ~= 3000 then
				pg.me:doGmCmd("teleportToScene", 3000, 0)
			end

			GmToolUtils.cmdSkipNew()
		end

		pg.me.clientFirstCreateFlag = false
	end

	if self.curScene then
		self.curScene:loaded()

		if not deferSceneReveal then
			self:hideLoadingPanel()
		end

		pg.global.ui.avatarLoading:close()
	end

	pg.game:onSceneLoaded(self.curScene.sceneId, self.curScene.sceneName)

	if deferSceneReveal then
		self:prepareSceneReveal()
	end
end

function SceneAdapter:onCheckSceneValid(sceneId, source, isSuccess)
	local sceneReady = self:isSceneValid()

	if not self:isSceneReadyGuardIgnored(sceneId) then
		logger:info("[@airfeng][loading] OnCheckSceneValid: source=%s, sceneId=%s, isSuccess=%s, ready=%s.", tostring(source), tostring(sceneId), tostring(isSuccess), tostring(sceneReady == true))

		if not sceneReady then
			self:startSceneReadyGuard(sceneId, source)
		end
	end

	return sceneReady
end

function SceneAdapter:startSceneReadyGuard(sceneId, source)
	local guardSceneId = self:getSceneReadyGuardSceneId(sceneId)

	if self:isSceneReadyGuardIgnored(guardSceneId) then
		return
	end

	if guardSceneId ~= nil then
		self.sceneReadyGuardSceneId = guardSceneId
	end

	if self.sceneReadyGuardTimer then
		return
	end

	logger:info("[@airfeng][loading] SceneReady blocked guard begin: source=%s, sceneId=%s.", tostring(source), tostring(self.sceneReadyGuardSceneId))
	self:dumpSceneReadyBlockers(self.sceneReadyGuardSceneId, source or "SceneReadyGuard")

	self.sceneReadyGuardTimer = TimerManager.addRepeatTimer(SceneAdapter.SCENE_READY_GUARD_INTERVAL, function()
		local tickSceneId = self:getSceneReadyGuardSceneId()

		if self:isSceneReadyGuardIgnored(tickSceneId) then
			self:cancelSceneReadyGuard("ignored_scene")

			return
		end

		if tickSceneId ~= nil then
			self.sceneReadyGuardSceneId = tickSceneId
		end

		self:dumpSceneReadyBlockers(self.sceneReadyGuardSceneId, "SceneReadyGuard")
	end)
end

function SceneAdapter:getSceneReadyGuardSceneId(sceneId)
	if sceneId ~= nil then
		return sceneId
	end

	if self.sceneReadyGuardSceneId ~= nil then
		return self.sceneReadyGuardSceneId
	end

	if self.targetSceneId ~= nil then
		return self.targetSceneId
	end

	return self.curScene and self.curScene.sceneId or nil
end

function SceneAdapter:isSceneReadyGuardIgnored(sceneId)
	local curSceneId = self.curScene and self.curScene.sceneId or nil

	return sceneId == ClientConst.SCENE_LOGIN_ID or curSceneId == ClientConst.SCENE_LOGIN_ID
end

function SceneAdapter:cancelSceneReadyGuard(reason)
	if self.sceneReadyGuardTimer then
		logger:info("[@airfeng][loading] SceneReady blocked guard end: sceneId=%s, reason=%s.", tostring(self.sceneReadyGuardSceneId), tostring(reason))
		TimerManager.removeTimer(self.sceneReadyGuardTimer)

		self.sceneReadyGuardTimer = nil
	end

	self.sceneReadyGuardSceneId = nil
end

function SceneAdapter:dumpSceneReadyBlockers(sceneId, source)
	local waitEntsCount = 0
	local waitEntsPreview = {}

	for entId, isWaiting in pairs(self.waitEnts or EMPTY_TABLE) do
		if isWaiting then
			waitEntsCount = waitEntsCount + 1

			if #waitEntsPreview < 10 then
				waitEntsPreview[#waitEntsPreview + 1] = tostring(entId)
			end
		end
	end

	local loading = pg.game and pg.game.loading or nil
	local loadingFinished = loading and loading:isFinished()
	local loadingProgress = loading and loading:getProgress() or nil
	local loadingInst = loading and loading.singleLoadingInst or nil
	local loadingSceneId = loadingInst and loadingInst.sceneId or nil
	local request = loadingInst and loadingInst.request or nil
	local loadingRequest = loadingInst and loadingInst.loadingRequest or nil
	local requestProgress = request and request.progress or nil
	local loadingRequestProgress = loadingRequest and loadingRequest.progress or nil
	local requestDone

	if request then
		requestDone = request.isDone
	end

	local loadingRequestDone

	if loadingRequest then
		loadingRequestDone = loadingRequest.isDone
	end

	local curSpaceSceneId = self.curSpace and self.curSpace.sceneId or nil
	local curSceneId = self.curScene and self.curScene.sceneId or nil

	logger:warn("[@airfeng][loading] SceneReady blocked: source=%s, sceneId=%s, curSpace=%s, curSpaceSceneId=%s, curSceneId=%s, waitLoadAddedSceneId=%s, waitLoadSeamlessSceneId=%s, loadingFinished=%s, loadingProgress=%s, loadingSceneId=%s, requestProgress=%s, requestDone=%s, loadingRequestProgress=%s, loadingRequestDone=%s, voxelReady=%s, waitEntsCount=%d, waitEnts=%s.", tostring(source), tostring(sceneId), tostring(self.curSpace ~= nil), tostring(curSpaceSceneId), tostring(curSceneId), tostring(self.waitLoadAddedSceneId), tostring(self.waitLoadSeamlessSceneId), tostring(loadingFinished == true), tostring(loadingProgress), tostring(loadingSceneId), tostring(requestProgress), tostring(requestDone), tostring(loadingRequestProgress), tostring(loadingRequestDone), tostring(self.voxelReady == true), waitEntsCount, table.concat(waitEntsPreview, ","))
end

function SceneAdapter:showLoadingPanel(sceneId)
	self:cancelSceneRevealFrameCb()

	self.deferSceneReveal = false

	self:cancelExitLoadingGuard()

	if self.blackScreenId ~= 0 then
		return
	end

	if pg.me.clientFirstCreateFlag then
		return
	end

	if sceneId == ClientConst.SCENE_PVP_Combat then
		return
	end

	if self.lastScene ~= nil and Utils.getSpaceType(sceneId) == Const.SPACE_TYPE_NPC_DUEL then
		return
	end

	self.targetSceneId = sceneId

	local v = SceneData[sceneId] or {}
	local panelId = v.LoadingPanelId or SceneAdapter.DEFAULT_LOADING_PANEL_ID

	if self.curLoadingPanelId ~= panelId then
		self:hideLoadingPanel()

		self.curLoadingPanelId = panelId
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TIPS) then
		pg.global.ui.tips:onStartOpenLoadingUI(panelId)
	end

	if pg.global.ui:checkUIOpen(panelId) then
		pg.global.ui:show(panelId)
	else
		pg.global.ui:open(panelId)
	end
end

function SceneAdapter:hideLoadingPanel()
	self:cancelSceneRevealFrameCb()
	self:cancelExitLoadingGuard()

	if self.blackScreenId ~= 0 then
		return
	end

	local panelId = self.curLoadingPanelId or SceneAdapter.DEFAULT_LOADING_PANEL_ID

	if panelId == SceneAdapter.DEFAULT_LOADING_PANEL_ID then
		pg.global.ui:hide(panelId)
	else
		pg.global.ui:close(panelId)
	end
end

function SceneAdapter:showExitLoadingGuard()
	if self.blackScreenId ~= 0 then
		return
	end

	if pg.me and pg.me.clientFirstCreateFlag then
		return
	end

	local panelId = SceneAdapter.DEFAULT_LOADING_PANEL_ID

	if self.curLoadingPanelId ~= panelId then
		self:hideLoadingPanel()

		self.curLoadingPanelId = panelId
	end

	if pg.global.ui:checkUIOpen(panelId) then
		pg.global.ui:show(panelId)
	else
		pg.global.ui:open(panelId)
	end

	self:cancelExitLoadingGuard()

	self.exitLoadingGuardTimer = TimerManager.addTimer(SceneAdapter.EXIT_LOADING_GUARD_TIME, function()
		self.exitLoadingGuardTimer = nil

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("exit loading guard timeout, force hide loading panel")
		end

		self:hideLoadingPanel()
	end)
end

function SceneAdapter:cancelExitLoadingGuard()
	if self.exitLoadingGuardTimer then
		TimerManager.removeTimer(self.exitLoadingGuardTimer)

		self.exitLoadingGuardTimer = nil
	end
end

function SceneAdapter:getLoadingProgress()
	local request = pg.game.loading:getRequest()

	if request ~= nil then
		return request.progress
	end

	return 1
end

function SceneAdapter:registerScript(sceneId, clz)
	self.clzMap[sceneId] = clz
end

function SceneAdapter:isSceneValid()
	if FREE_WALK then
		return true
	end

	if not self.curSpace then
		return false
	end

	if self.waitLoadAddedSceneId ~= nil or self.waitLoadSeamlessSceneId ~= nil then
		return false
	end

	if not pg.game.loading:isFinished() then
		return false
	end

	if not self.voxelReady then
		return false
	end

	if not Utils.tableIsEmptyOrNil(self.waitEnts) then
		return false
	end

	return true
end

function SceneAdapter:markWaitEntity(id, isLoading)
	if not id then
		return
	end

	if isLoading then
		if self:isSceneValid() then
			return
		end

		self.waitEnts[id] = true
	elseif self.waitEnts[id] then
		self.waitEnts[id] = nil

		if not self.isSceneReady then
			local sceneId = self.curScene and self.curScene.sceneId or self.targetSceneId
			local sceneReady = self:isSceneValid()

			if not sceneReady then
				self:startSceneReadyGuard(sceneId, "WaitEntity")
			end

			if sceneReady then
				self:onSceneReady()
			end
		end
	end
end

function SceneAdapter:loadAdditiveScene(sceneId, callback)
	local levelName = ClientUtils.getSceneName(sceneId)
	local request = pg.global.resMgr:LoadLevel(sceneId, levelName, true)

	function request.loadedCallback(isSucc)
		if not isSucc then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("Failed to load level", levelName)
			end

			return
		end

		if callback then
			callback()
		end

		local params = self.additiveScene[sceneId]

		if params and params.finishedCb then
			params.finishedCb()
		end
	end

	self.additiveScene[sceneId] = {
		request = request
	}
end

function SceneAdapter:setAdditiveSceneLoadedCb(sceneId, callback)
	local params = self.additiveScene[sceneId]

	if params == nil then
		return false
	end

	params.finishedCb = callback
end

function SceneAdapter:checkAdditiveSceneLoaded(sceneId)
	local params = self.additiveScene[sceneId]

	if params == nil or params.request == nil then
		return false
	end

	return params.request.isDone
end

function SceneAdapter:unloadAdditiveScene(sceneId)
	self.additiveScene[sceneId] = nil
end

function SceneAdapter:getOrRegisterScript(sceneId)
	if not sceneId then
		return nil
	end

	local sceneClz = self.clzMap[sceneId]

	if sceneClz then
		return sceneClz
	end

	local v = SceneData[sceneId]

	if v == nil then
		return nil
	end

	local scenesPath = "GameApp.Scenes."
	local moduleName = v.script or "DefaultScene"
	local clz = require(scenesPath .. moduleName)

	self:registerScript(sceneId, clz)

	return clz
end

function SceneAdapter:checkHideRedDot()
	if self.curScene == nil then
		return false
	end

	return self.curScene:isHideRedDot()
end

function SceneAdapter:onStreamLoadCallback()
	return
end

function SceneAdapter:onStreamTeleCallback()
	return
end

return SceneAdapter
