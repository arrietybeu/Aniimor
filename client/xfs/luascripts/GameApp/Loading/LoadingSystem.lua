-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Loading\\LoadingSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local SingleLoading = require("GameApp.Loading.SingleLoading")
local GmToolUtils = require("Utils.GmToolUtils")
local logger = LoggerManager.getLogger("LoadingSystem")
local UIConst = require("Const.UIConst")
local LOADING_SCENE_PROGRESS_WEIGHT = 0.1
local LoadingSystem = Class.LightClass("LoadingSystem", SystemBase)

function LoadingSystem:getMessageBindMap()
	return {}
end

function LoadingSystem:onCtor()
	self.inSingleLoading = false
	self.singleLoadingInst = nil
	self.sameSceneLoadingInst = nil
	self.curSceneId = ClientConst.SCENE_INIT_ID
	self.pos = nil
end

function LoadingSystem:enterSingleLoading(sceneId)
	pg.global.resMgr:SetSceneLoadingUnloadSuppressed(true)

	self.inSingleLoading = true
	self.curSceneId = sceneId
	self.pos = nil
	self.isReloading = false
	self.singleLoadingInst = SingleLoading(sceneId)

	self.singleLoadingInst:startLoading()
end

function LoadingSystem:enterSingleReloading(sceneId, pos, requireEnvRefresh)
	pg.global.resMgr:SetSceneLoadingUnloadSuppressed(true)

	self.inSingleLoading = true
	self.curSceneId = sceneId
	self.pos = pos
	self.isReloading = true
	self.singleLoadingInst = SingleLoading(sceneId)

	self.singleLoadingInst:startReloading(pos, requireEnvRefresh)
end

function LoadingSystem:enterOfflineScene(sceneId, player, onSceneLoaded)
	local loadingInst = SingleLoading(sceneId)

	self.singleLoadingInst = loadingInst

	loadingInst:enterOfflineScene(player, function(isSucc)
		if self.singleLoadingInst == loadingInst then
			self:exitSingleLoading()
		end

		if onSceneLoaded then
			onSceneLoaded(isSucc)
		end
	end)

	local whiteList = {}

	whiteList[UIConst.UI_ID_HUD_V2] = true
	whiteList[UIConst.UI_ID_FEED_GAME_ENTRY] = true
	whiteList[UIConst.UI_ID_CAPTURE_BALL] = true
	whiteList[UIConst.UI_ID_THROW_PANEL] = true
	whiteList[UIConst.UI_ID_TIPS] = true
	whiteList[UIConst.UI_ID_HUD_MOBILE_OPERATE] = true
	whiteList[UIConst.UI_ID_PET_FIRST_SHOW] = true
	whiteList[UIConst.UI_ID_COMMON_CONFIRM] = true

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.CLIENT_UTILS, whiteList)
end

function LoadingSystem:onLoadingSceneLoaded(loadingInst, isSucc)
	if loadingInst == self.singleLoadingInst then
		pg.global.scene:onLoadingSceneLoaded(loadingInst.sceneId, isSucc)
	end
end

function LoadingSystem:onProgressFinished()
	if self.singleLoadingInst then
		local sceneId = self.singleLoadingInst.sceneId

		self:exitSingleLoading()
		pg.global.scene:onSceneLoaded(sceneId, true)
		pg.global.resMgr:SetSceneLoadingUnloadSuppressed(false)
	end
end

function LoadingSystem:onFinishLoading(loadingInst, isSucc)
	if loadingInst.sceneId == ClientConst.SCENE_PVP_Combat then
		self.inSingleLoading = false

		return
	end

	if loadingInst == self.singleLoadingInst then
		local deferSceneReveal = isSucc == true

		if not isSucc and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("failed to load scene", loadingInst.sceneId)
		end

		self:exitSingleLoading()
		pg.global.scene:onSceneLoaded(loadingInst.sceneId, isSucc, self.isReloading, deferSceneReveal)
		pg.global.resMgr:SetSceneLoadingUnloadSuppressed(false)
	end

	GmToolUtils.OnSceneLoadedDo()
end

function LoadingSystem:exitSingleLoading()
	if not self.singleLoadingInst then
		return
	end

	self.singleLoadingInst:stopLoading()

	self.singleLoadingInst = nil
	self.inSingleLoading = false
end

function LoadingSystem:getRequest()
	if self.singleLoadingInst then
		return self.singleLoadingInst.request
	end
end

function LoadingSystem:getProgress()
	if self.singleLoadingInst then
		local request = self.singleLoadingInst.request

		if request then
			local progress = tonumber(request.progress) or 0

			return LOADING_SCENE_PROGRESS_WEIGHT + progress * (1 - LOADING_SCENE_PROGRESS_WEIGHT)
		end

		local loadingRequest = self.singleLoadingInst.loadingRequest

		if loadingRequest then
			local progress = tonumber(loadingRequest.progress) or 0

			return progress * LOADING_SCENE_PROGRESS_WEIGHT
		end
	end

	return 0
end

function LoadingSystem:isFinished()
	return not self.inSingleLoading
end

return LoadingSystem
