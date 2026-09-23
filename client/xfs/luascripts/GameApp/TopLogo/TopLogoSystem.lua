-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\TopLogo\\TopLogoSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoSystem")
local bitset = require("Common.Bitset")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local Lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local Queue = require("Core.Framework.Queue")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local ConflictTypes = require("Common.ConflictTypes")
local SafeCallback = require("Core.Framework.SafeCallback")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local DialogueGraphConfig = require("Data.dialogue_graph_data")
local DialogueItemCmd = require("GameApp.DialogueGraph.DialogueItemCmd")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local TopLogoLodTickManager = require("GameApp.TopLogo.TopLogoLodTickManager")
local TopLogoCapacityLimiter = require("GameApp.TopLogo.TopLogoCapacityLimiter")
local SysConfigData = require("Data.sys_config_data")
local HomelandConfigData = require("Data.homeland_config_data")
local Time = require("Core.Common.Time")
local TopLogoSystem = Class.LightClass("TopLogoSystem", SystemBase)

function TopLogoSystem:onCtor()
	self:resetData()

	self.lodManager = TopLogoLodTickManager("TopLogoLodTickManager")

	self:_initCapacityLimiters()
end

function TopLogoSystem:_initCapacityLimiters()
	self.alertLimiter = TopLogoCapacityLimiter({
		cadenceSec = 0.3,
		maxProvider = function()
			return SysConfigData.ToplogoAlertMax
		end,
		filterFunc = function(comp)
			return comp:checkParentVisible()
		end,
		sortFunc = function(a, b)
			if a._limiterInView and not b._limiterInView then
				return true
			end

			if not a._limiterInView and b._limiterInView then
				return false
			end

			return a.topLogoItem.distance < b.topLogoItem.distance
		end,
		prepareSortData = function(list)
			local fx, _, fz = pg.global.cameraMgr:GetWorldCameraForwardEx()
			local playerPos = pg.me:getPosition()
			local fovCos = math.cos(math.rad(SysConfigData.ToplogoAlertStartRemoveFOV))

			for _, comp in ipairs(list) do
				local entPos = comp.entity:getPosition()
				local dx = entPos[1] - playerPos[1]
				local dz = entPos[3] - playerPos[3]
				local len = math.sqrt(dx * dx + dz * dz)
				local cosAngle = len > 0 and (fx * dx + fz * dz) / len or -1

				comp._limiterInView = fovCos < cosAngle
			end
		end
	})
	self.homeFacilityLimiter = TopLogoCapacityLimiter({
		cadenceSec = 0.5,
		maxProvider = function()
			return HomelandConfigData.TopLogoMaxCount or 8
		end,
		filterFunc = function(comp)
			return comp:checkParentVisible()
		end,
		sortFunc = function(a, b)
			return a.topLogoItem.distance < b.topLogoItem.distance
		end
	})
	self.interactSignLimiter = TopLogoCapacityLimiter({
		cadenceSec = 0.5,
		maxProvider = function()
			return HomelandConfigData.InteractSignTopLogoMaxCount or 8
		end,
		filterFunc = function(comp)
			return comp:checkParentVisible()
		end,
		sortFunc = function(a, b)
			return (a._limiterDistance or math.huge) < (b._limiterDistance or math.huge)
		end,
		prepareSortData = function(list)
			local playerPos = pg.me and pg.me:getPosition()

			if not playerPos then
				return
			end

			for _, comp in ipairs(list) do
				local entPos = comp.entity and comp.entity:getPosition()

				comp._limiterDistance = entPos and Vector3.SqrDistance(entPos, playerPos) or math.huge
			end
		end
	})
end

function TopLogoSystem:getMessageBindMap()
	return {
		[MessageName.SYNC_TEAM_INFO] = "onSyncTeamInfo"
	}
end

function TopLogoSystem:onSyncTeamInfo()
	local space = pg.space

	if space and space.toplogoType == ClientConst.TopLogoSpecial.Pvp_2 then
		self._pvp2TeamCacheDirty = true
	end
end

function TopLogoSystem:_flushPvp2TeamCacheRefresh()
	if not self._pvp2TeamCacheDirty then
		return
	end

	self._pvp2TeamCacheDirty = false

	local space = pg.space

	if not space or not pg.getActorEntities then
		return
	end

	local actorEntities = pg.getActorEntities()

	if not actorEntities then
		return
	end

	for _, entity in pairs(actorEntities) do
		if entity and entity.space == space and entity._isPvp2Scene and entity.refreshPvp2TeamCache then
			entity:refreshPvp2TeamCache()
		end
	end
end

function TopLogoSystem:onSceneLoaded(sceneId, sceneName)
	return
end

function TopLogoSystem:onTick()
	self:_flushPvp2TeamCacheRefresh()
	self.lodManager:lodTick()

	local now = Time.getTickSecond()

	self.alertLimiter:flush(now)
	self.homeFacilityLimiter:flush(now)
	self.interactSignLimiter:flush(now)
end

function TopLogoSystem:setUIPaused(paused)
	self.lodManager:setUIPaused(paused)
end

function TopLogoSystem:resetData()
	self._pvp2TeamCacheDirty = false

	self:clearGlobalVisibleData()
end

function TopLogoSystem:onClear()
	self:resetData()
	self.alertLimiter:clear()
	self.homeFacilityLimiter:clear()
	self.interactSignLimiter:clear()
end

function TopLogoSystem:onDestroy()
	self.lodManager:Clear()
	self:onClear()
end

function TopLogoSystem:registerGlobalVisibleData(registerVisibleData)
	if not registerVisibleData or not registerVisibleData.visibleKey then
		return
	end

	self.globalVisibleData = self.globalVisibleData or {}
	self.globalVisibleData[registerVisibleData.visibleKey] = registerVisibleData
end

function TopLogoSystem:unRegisterGlobalVisibleData(visibleKey)
	if not visibleKey then
		return
	end

	self.globalVisibleData = self.globalVisibleData or {}
	self.globalVisibleData[visibleKey] = nil
end

function TopLogoSystem:clearGlobalVisibleData()
	self.globalVisibleData = nil
end

function TopLogoSystem:applyGlobalVisibleToComponent(componentName, component)
	if not self.globalVisibleData or not next(self.globalVisibleData) or not component then
		return
	end

	for _, registerVisibleData in pairs(self.globalVisibleData) do
		if registerVisibleData and next(registerVisibleData) then
			local visibleKey = registerVisibleData.visibleKey
			local visible = registerVisibleData.visible

			if visible == nil then
				visible = false
			end

			if visibleKey then
				local targetCompNames = registerVisibleData.targetCompNames

				if component.ignoreCompVisibleCheck or targetCompNames == nil or targetCompNames[componentName] then
					component:setVisible(visible, visibleKey)
				else
					component:setVisible(not visible, visibleKey)
				end
			end
		end
	end
end

function TopLogoSystem:setTopLogoComponentGlobalVisible(topLogoItem)
	if not self.globalVisibleData or not next(self.globalVisibleData) or not topLogoItem then
		return
	end

	for name, comp in pairs(topLogoItem.components) do
		self:applyGlobalVisibleToComponent(name, comp)
	end
end

return TopLogoSystem
