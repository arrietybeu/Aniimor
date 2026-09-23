-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Loading\\SingleLoading.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LoadingBase = require("GameApp.Loading.LoadingBase")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local logger = LoggerManager.getLogger("SingleLoading")
local SingleLoading = Class.LightClass("SingleLoading", LoadingBase)
local Const = require("Common.Const.Const")
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneData = require("Data.scene_data")
local AudioConst = require("Const.AudioConst")
local Utils = require("Common.Utils.Utils")
local EModelUtils = require("Entities.Utils.EModelUtils")

function SingleLoading:ctor(sceneId)
	SingleLoading.super.ctor(self, sceneId)

	self.request = nil
	self.loadingRequest = nil
end

function SingleLoading:startLoading()
	local loadingSceneId = ClientConst.SCENE_LOADING_ID
	local levelName = ClientUtils.getSceneName(loadingSceneId)

	self.loadingRequest = pg.global.resMgr:LoadLevel(loadingSceneId, levelName, false)

	function self.loadingRequest.loadedCallback(isSucc)
		if isSucc then
			self:onLoadingSceneLoaded(loadingSceneId)
			pg.game.loading:onLoadingSceneLoaded(self, isSucc)
			self:enterLoadingScene()
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Failed to load level")
		end
	end
end

function SingleLoading:onLoadingSceneLoaded(sceneId)
	local scData = SceneData[sceneId]

	if scData == nil then
		return
	end

	if not string.isNilOrEmpty(scData.bgm) then
		pg.game.audio:playBgm(scData.bgm, AudioConst.BgmPriority.Scene)
	end

	if not string.isNilOrEmpty(scData.amb) then
		pg.game.audio:playAmb(scData.amb, AudioConst.BgmPriority.Scene)
	end
end

function SingleLoading:startReloading(pos, requireEnvRefresh)
	local levelName = ClientUtils.getSceneName(self.sceneId)

	pg.game.voxel:loadNearbyRegions()

	self.request = pg.global.resMgr:StreamReloadLevel(levelName, pos, requireEnvRefresh)

	function self.request.loadedCallback(isSucc)
		if not isSucc and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Failed to load level", levelName)
		end

		pg.game.loading:onFinishLoading(self, isSucc)
	end
end

function SingleLoading:enterOfflineScene(player, onSceneLoaded)
	local sceneId = self.sceneId
	local levelName = ClientUtils.getSceneName(sceneId)
	local isStream = ClientUtils.isStreamScene(sceneId)

	if isStream then
		self.request = pg.global.resMgr:StreamLoadLevel(levelName)
	else
		self.request = pg.global.resMgr:LoadLevel(sceneId, levelName, false)
	end

	function self.request.loadedCallback(isSucc)
		if not isSucc and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Failed to load level", levelName)
		end

		local pos = Vector3(0, 0, 0)
		local sceneData = SceneData[sceneId]
		local bornTpId = sceneData.bornTpId
		local portalData = SceneUtils.getScenePortalData(sceneId)
		local d = portalData[bornTpId] and portalData[bornTpId].markPosition

		if d then
			pos.x = d[1]
			pos.y = d[2]
			pos.z = d[3]
		end

		EModelUtils.setAgentPosition(player, pos)
		player.eModel:ClearGravityMask(Const.COMPONENT_MOTION, ClientConst.GravityMask.GMMove)

		if onSceneLoaded then
			onSceneLoaded(isSucc)
		end

		pg.me.offlineIsReady = true
	end
end

function SingleLoading:stopLoading()
	pg.game.audio:playBgm(nil, AudioConst.BgmPriority.Scene)

	self.request = nil
	self.loadingRequest = nil
end

function SingleLoading:enterLoadingScene()
	local levelName = ClientUtils.getSceneName(self.sceneId)
	local isStream = ClientUtils.isStreamScene(self.sceneId)
	local player = pg.me

	if player ~= nil then
		player:forceSetPos(player:getPosition(), true)
	end

	pg.game.voxel:loadNearbyRegions()

	if isStream then
		self.request = pg.global.resMgr:StreamLoadLevel(levelName)
	else
		self.request = pg.global.resMgr:LoadLevel(self.sceneId, levelName, false)
	end

	function self.request.loadedCallback(isSucc)
		if not isSucc and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Failed to load level", levelName)
		end

		pg.game.loading:onFinishLoading(self, isSucc)
	end
end

return SingleLoading
