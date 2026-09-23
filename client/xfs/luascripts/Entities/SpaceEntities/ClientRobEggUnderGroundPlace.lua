-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRobEggUnderGroundPlace.lua

local Class = require("Core.Framework.Class")
local ClientDungeon = require("Entities.SpaceEntities.ClientDungeon")
local DungeonConst = require("Common.Const.DungeonConst")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local RobEggViewLimitFogUtils = require("Common.Utils.RobEggViewLimitFogUtils")
local ClampVisionPlayerType = typeof(CS.FunPlus.WorldX.RenderingScripts.Effect.ClampVisionPlayer)
local Vector2 = CS.UnityEngine.Vector2
local Color = CS.UnityEngine.Color
local ClientRobEggUnderGroundPlace = Class.Class("ClientRobEggUnderGroundPlace", ClientDungeon)
local ClientSpaceComponents = {}

Class.AddComponents(ClientRobEggUnderGroundPlace, ClientSpaceComponents)

function ClientRobEggUnderGroundPlace:preInit(dict)
	ClientRobEggUnderGroundPlace.super.preInit(self, dict)

	self.masterDungeonSceneId = dict.masterDungeonSceneId

	RandomMapBatchUtils.batchSceneData(dict.sceneId, nil, dict.sandboxIdsMap, self.id)

	self.teamInfo = dict.teamInfo or {}
end

function ClientRobEggUnderGroundPlace:init(dict)
	ClientRobEggUnderGroundPlace.super.init(self, dict)

	return true
end

function ClientRobEggUnderGroundPlace:start()
	ClientRobEggUnderGroundPlace.super.start(self)
	self:preloadFogViewLimit()
end

function ClientRobEggUnderGroundPlace:shouldRevealAllMapFog(mapSceneId)
	if mapSceneId ~= nil then
		if not pg.game or not pg.game.map then
			return false
		end

		local currentMapSceneId = pg.game.map:convertSceneId(self.sceneId)
		local targetMapSceneId = pg.game.map:convertSceneId(mapSceneId)

		if currentMapSceneId ~= targetMapSceneId then
			return false
		end
	end

	return pg.me ~= nil and pg.me.grabEgg_shouldRevealMapFog ~= nil and pg.me:grabEgg_shouldRevealMapFog(self.masterDungeonSceneId, self.hardLv)
end

function ClientRobEggUnderGroundPlace:onSceneLoaded()
	self.fogSceneLoaded = true

	self:refreshFogViewLimit()
end

function ClientRobEggUnderGroundPlace:onSceneUnloaded()
	self:clearFogViewLimit()
end

function ClientRobEggUnderGroundPlace:getFogViewLimitParams()
	local useAfter = self.useAfterViewLimitFog == true
	local params = RobEggViewLimitFogUtils.getParams(self.hardLv, useAfter)

	if not params then
		self.logger:error("rob_egg_fog_config_invalid: hardLv=%s sceneId=%s useAfter=%s", self.hardLv, self.sceneId, tostring(useAfter))

		return
	end

	return params
end

function ClientRobEggUnderGroundPlace:preloadFogViewLimit()
	if self.fogViewLimitApplied or not pg.global or not pg.global.cameraMgr then
		return
	end

	local params = self:getFogViewLimitParams()

	if not params then
		return
	end

	pg.global.cameraMgr:TrySetSightOfViewRange(params.nearFog, params.farFog)

	self.fogViewLimitApplied = true
end

function ClientRobEggUnderGroundPlace:refreshFogViewLimit()
	if not self.fogSceneLoaded or not pg.global or not pg.global.cameraMgr then
		return
	end

	local params = self:getFogViewLimitParams()

	if not params then
		return
	end

	pg.global.cameraMgr:TrySetSightOfViewRange(params.nearFog, params.farFog)

	self.fogViewLimitApplied = true

	self:refreshFogVisualParams(params)
end

function ClientRobEggUnderGroundPlace:stopRefreshFogVisualParams()
	if not self.fogVisualParamsTimer then
		return
	end

	self:removeTimer(self.fogVisualParamsTimer)

	self.fogVisualParamsTimer = nil
end

function ClientRobEggUnderGroundPlace:tryApplyFogVisualParams(params)
	local camera = pg.global.cameraMgr.worldCameraInst

	if not camera then
		return false
	end

	local visionPlayer = camera.transform:GetComponentInChildren(ClampVisionPlayerType)

	if not visionPlayer then
		return false
	end

	visionPlayer:UpdateViewRange(Vector2(params.nearFog, params.farFog), Color(params.color[1], params.color[2], params.color[3], 1), params.fogFadePower, params.pepsiPos)

	return true
end

function ClientRobEggUnderGroundPlace:refreshFogVisualParams(params)
	self:stopRefreshFogVisualParams()

	if self:tryApplyFogVisualParams(params) then
		return
	end

	self.fogVisualParamsTimer = self:addRepeatTimer(0.05, function()
		if not self.fogSceneLoaded or self:tryApplyFogVisualParams(params) then
			self:stopRefreshFogVisualParams()
		end
	end)
end

function ClientRobEggUnderGroundPlace:clearFogViewLimit()
	self.fogSceneLoaded = false

	self:stopRefreshFogVisualParams()

	if not self.fogViewLimitApplied then
		return
	end

	self.fogViewLimitApplied = false

	if pg.global and pg.global.cameraMgr then
		pg.global.cameraMgr:UnloadSightOfViewEffect(true)
	end
end

function ClientRobEggUnderGroundPlace:on_useAfterViewLimitFog_changed(oldv, newv)
	self:refreshFogViewLimit()

	if pg.game and pg.game.audio then
		pg.game.audio:setSceneBerserkBgmEnabled(self.sceneId, newv)
	end
end

function ClientRobEggUnderGroundPlace:getGrabEggTeamIndex(uid)
	local id_to_team = self.teamInfo.id_to_team
	local teams = self.teamInfo.teams

	if not id_to_team or not teams then
		return 0
	end

	local myTeamId = id_to_team[pg.me.uid]
	local teamId = id_to_team[uid]

	if teamId ~= myTeamId then
		return 0
	end

	local team = teams[teamId]

	if not team then
		return 0
	end

	for index, curUid in ipairs(team.members) do
		if curUid == uid then
			return index
		end
	end

	return 0
end

function ClientRobEggUnderGroundPlace:on_escapeStage_changed(oldv, newv)
	if newv == DungeonConst.RobEggStage.PVP then
		pg.me:grabEgg_PvpAreaUnlock()
	end
end

function ClientRobEggUnderGroundPlace:destroy()
	self:clearFogViewLimit()
	ClientRobEggUnderGroundPlace.super.destroy(self)
	RandomMapBatchUtils.clearSceneCacheData(self.id)
end

return ClientRobEggUnderGroundPlace
