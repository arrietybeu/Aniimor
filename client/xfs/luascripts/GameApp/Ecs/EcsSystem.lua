-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ecs\\EcsSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EcsSystem")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local EcsShareData = require("GameApp.ShareData.Generated.EcsShareData")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local EcsSkillCache = require("GameApp.Ecs.EcsSkillCache")
local ClientConst = require("Const.ClientConst")
local LevelData = require("Data.level_data")
local AddressDataConst = require("Const.AddressDataConst")
local EcsSyncClient = require("GameApp.Ecs.EcsSyncClient")
local EcsSyncExchange = require("GameApp.Ecs.EcsSyncExchange")
local EcsSystem = Class.LightClass("EcsSystem", SystemBase)
local ecsTopLogoElementResIds = {
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Fire,
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Water,
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Ice,
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Thunder,
	"",
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Wind,
	AddressDataConst.UI_Node_ECS_TopLogo_Element_Destructible
}

function EcsSystem:onCtor()
	self.ecsShares = {}
	self.lastSlowTickTime = 0
	self.syncExchange = EcsSyncExchange.new()
	self.sync = EcsSyncClient.new(self.syncExchange)
	self.droppedEarlyFullStateSessionId = nil
	self.farawayMovingEnts = {}
	self.fireCache = EcsSkillCache.new("FlammableStart")
	self.waterCache = EcsSkillCache.new("Flammablemeetwater")
	self.iceCache = EcsSkillCache.new("StateFrozenStart")
	self.electricCache = EcsSkillCache.new("ConductBoomStart")

	appFacade.ecsMgr:ConfigureEcsTopLogoAssets(AddressDataConst.UI_Node_TopLogo_ElementProgress, ecsTopLogoElementResIds)
end

function EcsSystem:onDestroy()
	if self.sync then
		self.sync:shutdown()
	end

	if self.syncExchange then
		self.syncExchange:destroy()
	end
end

function EcsSystem:initializeSync(fullState)
	if not self.sync:initialize(fullState) then
		logger:error("ECS initialization failed: invalid Space full state or shared exchange unavailable")
	else
		if self.droppedEarlyFullStateSessionId == fullState.syncSessionId then
			self.sync:requestFullSync()
		end

		self.droppedEarlyFullStateSessionId = nil
	end
end

function EcsSystem:registerSyncObject(syncObject)
	return self.sync:registerSyncObject(syncObject)
end

function EcsSystem:onUploadResult(uploadResult)
	return self.sync:onUploadResult(uploadResult)
end

function EcsSystem:applyStateChanges(changes)
	return self.sync:applyStateChanges(changes)
end

function EcsSystem:applyFullState(fullState)
	if type(fullState) ~= "table" or type(fullState.syncSessionId) ~= "string" then
		return false
	end

	if not self.sync.enabled or fullState.syncSessionId ~= self.sync.syncSessionId then
		self.droppedEarlyFullStateSessionId = fullState.syncSessionId

		return true
	end

	return self.sync:applyFullState(fullState)
end

function EcsSystem:requestFullSync(syncIds)
	return self.sync:requestFullSync(syncIds)
end

function EcsSystem:onAuthorityChange(message)
	return self.sync:onAuthorityChange(message)
end

function EcsSystem:queueBuffCountChange(actorId, element, layer, srcActorId)
	return self.sync:queueBuffCountChange(actorId, element, layer, srcActorId)
end

function EcsSystem:shutdownSync()
	self.sync:shutdown()
end

function EcsSystem:registerEcsShares(ecsId)
	if self.ecsShares[ecsId] then
		logger:error("EcsSystem:registerEcsShares ecsId %s already exists", ecsId)

		return self.ecsShares[ecsId]
	end

	local ecsShare = EcsShareData.create()

	self.ecsShares[ecsId] = ecsShare

	return ecsShare
end

function EcsSystem:getEcsShares(ecsId)
	return self.ecsShares[ecsId]
end

function EcsSystem:setAllEcsTopLogoVisible(visible)
	appFacade.ecsMgr:SetEcsTopLogoVisible(visible)
end

function EcsSystem:unregisterEcsShares(ecsId)
	local ecsShare = self.ecsShares[ecsId]

	if ecsShare then
		EcsShareData.destroy(ecsShare)
	end

	self.ecsShares[ecsId] = nil
end

function EcsSystem:registerFarawayPhysics(ent)
	self.farawayMovingEnts[ent.id] = true
end

function EcsSystem:onTick()
	if not pg.space then
		return
	end

	if Time.realSecondCache - self.lastSlowTickTime > 1 then
		self.lastSlowTickTime = Time.realSecondCache

		self:onSlowTick()
	end

	self.sync:tick()
end

function EcsSystem:onSlowTick()
	local levelInfo = pg.space and LevelData[pg.space.sceneId]
	local disableFarawayPhysics = levelInfo and levelInfo.isTemple == 1

	if not disableFarawayPhysics then
		local playerPos = pg.playerPos
		local moveDistSqr = 16384

		for id, moving in pairs(self.farawayMovingEnts) do
			local ent = pg.getEntity(id)

			if not ent or ent.isDestroyed then
				self.farawayMovingEnts[id] = nil
			else
				local distSqr = Utils.squareDistNoYAxis(playerPos, ent:getPosition())
				local shouldMove = distSqr < moveDistSqr

				if shouldMove and not moving then
					ent:setIsKinematic(false, ClientConst.IsKinematicKey.Faraway)

					self.farawayMovingEnts[id] = true
				elseif not shouldMove and moving then
					ent:setIsKinematic(true, ClientConst.IsKinematicKey.Faraway)

					self.farawayMovingEnts[id] = false
				end
			end
		end
	end
end

function EcsSystem:onEcsSkillHit(targetEnt, ret, abilityId, elementType, srcActorId)
	local skillCache

	if elementType == 0 then
		skillCache = self.fireCache
	elseif elementType == 1 then
		skillCache = self.waterCache
	elseif elementType == 2 then
		skillCache = self.iceCache
	elseif elementType == 3 then
		skillCache = self.electricCache
	end

	if skillCache then
		skillCache:add(targetEnt, ret, abilityId, elementType, srcActorId)
	end
end

function EcsSystem:getSkillCasterByElement(targetEnt, elementType)
	local skillCache

	if elementType == 0 then
		skillCache = self.fireCache
	elseif elementType == 1 then
		skillCache = self.waterCache
	elseif elementType == 2 then
		skillCache = self.iceCache
	elseif elementType == 3 then
		skillCache = self.electricCache
	end

	if not skillCache then
		return 0
	end

	return skillCache:findSkillCasterActorId(targetEnt)
end

local ECSConst = require("Const.ECSConst")
local bit = bit

function EcsSystem:onEcsStateChange(targetEnt, lastState, newState)
	local stateDef = ECSConst.EcsStateDef
	local stateDiff = bit.bxor(lastState, newState)

	if bit.band(stateDiff, stateDef.Burning) ~= 0 then
		if bit.band(newState, stateDef.Burning) ~= 0 then
			self.fireCache:trigger(targetEnt)
		else
			self.waterCache:trigger(targetEnt)
		end
	end

	if bit.band(stateDiff, stateDef.Wet) ~= 0 and bit.band(newState, stateDef.Wet) ~= 0 then
		-- block empty
	end

	if bit.band(stateDiff, stateDef.Frozen) ~= 0 and bit.band(newState, stateDef.Frozen) ~= 0 then
		self.iceCache:trigger(targetEnt)
	end

	if bit.band(stateDiff, stateDef.Conducted) ~= 0 and bit.band(newState, stateDef.Conducted) ~= 0 then
		self.electricCache:trigger(targetEnt)
	end
end

return EcsSystem
