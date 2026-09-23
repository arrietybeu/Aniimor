-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\ClientSpaceBase.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local ClientEntity = require("Core.Client.ClientEntity")
local SceneData = require("Data.scene_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientConst = require("Const.ClientConst")
local AoiLodConst = require("Common.Const.AoiLodConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientSpaceBase = class.Class("ClientSpaceBase", ClientEntity)

function ClientSpaceBase:ctor(entityId)
	ClientSpaceBase.super.ctor(self, entityId)

	self.forceReloadOnSwitch = false
	self.envRefreshOnEnter = true
	GlobalData.Space = self
	pg.space = self
	self.firstCreate = false
end

function ClientSpaceBase:init(createInfo)
	ClientSpaceBase.super.init(self, createInfo)

	if self.firstCreate then
		return true
	end

	self.firstCreate = true
	self.sceneId = createInfo.sceneId

	if not EnableBotTest then
		local sceneId = self.sceneId or ClientConst.SCENE_ELEMENT_DEMO

		if pg.global.scene:checkNeedSeamlessLoadNewScene(sceneId, createInfo.portalPos) then
			pg.global.resMgr:SetInLoading(true)
		end

		local sceneConfig = {}

		table.merge(sceneConfig, SceneData[self.sceneId] or {})

		sceneConfig.file = SceneUtils.getSceneName(sceneConfig.file or "")
		sceneConfig.voxel_load_type = self:getVoxelLoadType()
		sceneConfig.voxel_path = SceneUtils.getVoxelPath(sceneConfig, self)
		sceneConfig.marker_tile_size = AoiLodConst.SPACE_MARKER_TILE_SIZE
		self.toplogoType = sceneConfig.toplogoType

		local weakSelf = setmetatable({
			self
		}, {
			__mode = "v"
		})

		pg.world.createSpace(self.sceneId, self.id, sceneConfig, false, function(succ)
			local space = weakSelf[1]

			if space == nil or space.destroyed then
				return
			end

			if succ then
				space:_doAfterLoaded()
				pg.game.voxel:registerVoxelRegionLoadCallback(space)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				space.logger:error("(%s) failed to load space", space:repr())
			end
		end)
		pg.global.scene:loadScene(sceneId, createInfo.portalPos)
	end

	return true
end

function ClientSpaceBase:_doAfterLoaded()
	if FREE_WALK then
		return
	end
end

function ClientSpaceBase:getVoxelLoadType()
	return ClientConst.VoxelLoadType.MAP_LOAD_NORMAL_AROUND
end

function ClientSpaceBase:checkEnableMutableVoxel()
	local sceneData = SceneData[self.sceneId] or {}

	if sceneData.disableMutableVoxel then
		return false
	end

	return true
end

function ClientSpaceBase:start()
	ClientSpaceBase.super.start(self)
	pg.global.scene:onSpaceCreated(self)
end

function ClientSpaceBase:onSceneLoaded()
	return
end

function ClientSpaceBase:onSceneUnloaded()
	return
end

function ClientSpaceBase:destroy()
	if not EnableBotTest then
		pg.global.scene:onSpaceDestroy(self)
		pg.world.destroySpace()
	end

	GlobalData.Space = nil
	pg.space = nil

	ClientSpaceBase.super.destroy(self)
end

return ClientSpaceBase
