-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\Component\\MapMarkTipComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local PuppetData = require("Data.puppet_data")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ClientUtils = require("Utils.ClientUtils")
local EventConst = require("Const.EventConst")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local SceneData = require("Data.scene_data")
local NpcFuncData = require("Data.npc_func_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("MapMarkTipComponent")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local MapUtils = require("Guis.Utils.MapUtils")
local MapMarkTipComponent = Class.LightClass("MapMarkTipComponent", UIComponent)
local UIConst = require("Const.UIConst")
local SysConfigData = require("Data.sys_config_data")
local MapHelper = require("GameApp.Map.MapHelper")
local MapMarkTipHelper = require("Guis.Panels.HatredArrowTip.Component.MapMarkTipHelper")
local GrabEggMapMarkUtils = require("GameApp.GrabEgg.GrabEggMapMarkUtils")
local CircularQueue = require("Core.Framework.CircularQueue")
local Time = require("Core.Common.Time")
local Vector2 = Vector2
local Vector3 = Vector3
local Quaternion = Quaternion
local ToBool = ToBool
local math = math
local InvalidPosValue = MapMarkTipHelper.InvalidPosValue
local ConstUpdateFrameInterval = 5
local ConstClueNearHideSqrDis = 36
local IS_MOBILE = IS_MOBILE
local GetEntityPos = MapHelper.GetEntityPos
local HasEntityPosSource = MapHelper.HasEntityPosSource
local getBindTargetPos = MapMarkTipHelper.GetBindTargetPos
local getFixedTargetPos = MapMarkTipHelper.GetFixedTargetPos
local getSandboxTargetPos = MapMarkTipHelper.GetSandboxTargetPos
local getUnresolvedStaticTargetPos = MapMarkTipHelper.GetUnresolvedStaticTargetPos
local setupStaticTargetPosGetter = MapMarkTipHelper.SetupStaticTargetPosGetter
local restoreSourceTargetPos = MapMarkTipHelper.RestoreSourceTargetPos
local getDuelTargetPos = MapMarkTipHelper.GetDuelTargetPos
local DUEL_TYPE = Const.MAP_CONST.TYPE.DUEL
local BATTLE_ROOM_COMP = UIConst.TOPLOGO_COMPONENT.BATTLE_ROOM
local ENABLE_DUEL_MARK_DEBUG = false
local duelMarkDebug = {
	projectionCalls = 0,
	targetPosCalls = 0,
	count = 0,
	battleRoomPushEvents = 0,
	suppressReads = 0,
	suppressFlips = 0
}

MapMarkTipComponent.PRELOAD_MAP_MARK_TIP_COUNT = 5
MapMarkTipComponent.SCREEN_CENTER = Vector3(0.5, 0.5, 0)
MapMarkTipComponent.INVALID_SHOW_DIST = {
	-1,
	-1
}
MapMarkTipComponent.relatedScreenWidth = 3840
MapMarkTipComponent.relatedScreenHeight = 2160
MapMarkTipComponent.POSITION_TYPE = {
	FIXED_POS = 1,
	ENTITY_POS = 2
}

local function setUrl(obj, lastUrl, newUrl)
	if lastUrl == newUrl then
		return
	end

	obj.url = newUrl
end

local function setVisible(trans, visible)
	trans.gameObject:SetActiveEx(visible)
end

local function shouldHideAllyMark(entity)
	if not entity then
		return false
	end

	local isReplaced = entity.isControllingEgg and entity:isControllingEgg() or entity.isControllingPet and entity:isControllingPet()

	if not isReplaced and (entity.active == false or entity.visible == false) then
		return true
	end

	if entity.DEAD_ST and entity:DEAD_ST() then
		return true
	end

	return entity.isDead and entity:isDead() or false
end

local sqrX = 1
local sqrY = 1

function MapMarkTipComponent:initView()
	self:refreshPlayerReferences()

	self.curMapMarkTipNum = 0
	self.timer = nil
	self.mapMarkTipPools = {}
	self.caches = {}
	self.mapMarkTipData = {}
	self.trackMarkTip = {}
	self.normalMarkTip = {}
	self._duelMarks = {}
	self._staticIds = {}
	self._entityChanges = {}
	self._sandboxIds = {}
	self.tracingMarkIds = {}
	self.teamMarkIds = {}
	self.allyMarkTipData = {}
	self.forceMarkTipData = {}
	self.preLoadingCount = 0
	self.playerPos = Vector3(0, 0, 0)

	self.playerPos:Copy(pg.me:getPosition())

	self.cachedTargetPos = Vector3(0, 0, 0)
	self.arrowPos = Vector2(0, 0)
	self.arrowRot = Quaternion(0, 0, 0, 1)

	local widthRatio = self.ctrl.width / self.relatedScreenWidth
	local heightRatio = self.ctrl.height / self.relatedScreenHeight

	self.ratioX = widthRatio * 0.5
	self.ratioY = heightRatio * 0.5
	sqrX = 1 / math.pow(self.ratioX, 2)
	sqrY = 1 / math.pow(self.ratioY, 2)
	self.updateIndex = 0
	self.markIndex = 0
	self.staticIndex = 0
	self._updateSet = {}
	self._updateKey = nil
	self._loadingSet = {}
	self.chunkLoaded = {}
	self.chunkChanges = {}

	self:addListener()
	self:initOnCreate()

	self._textQueue = CircularQueue.new(16)
	self._urlQueue = CircularQueue.new(16)

	self._urlQueue:InitUniqueCache()
	self:startMapMarkTipTimer()
end

function MapMarkTipComponent:addListener()
	function self.addMapMarkTrace(markType, spawnerId, data)
		self:onMapMarkTraceAdd(spawnerId)
	end

	function self.removeMapMarkTrace(spawnerId)
		self:onMapMarkTraceRemove(spawnerId)
	end

	function self.updateMapMarkTrace(info)
		self:onMapMarkUpdate(info)
	end

	function self.markChunkIndexChanged(x, z)
		self:onMapMarkChunkIndexChanged(x, z)
	end

	function self._onSandBoxUpdate(sandboxId)
		self:onSandBoxUpdate(sandboxId)
	end

	function self._onAllyMarkStateChanged(entityId)
		self:onAllyMarkStateChanged(entityId)
	end

	function self._onBattleRoomDisplayChanged(entityId, displayed)
		self:onBattleRoomDisplayChanged(entityId, displayed)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_TRACE_ADD, self.addMapMarkTrace)
	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self.removeMapMarkTrace)
	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_CHUNK_INDEX_CHANGED, self.markChunkIndexChanged)
	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_UPDATED, self.updateMapMarkTrace)
	pg.global.eventEmitter:addEventListener(EventConst.SANDBOX_UPDATE, self._onSandBoxUpdate)
	pg.global.eventEmitter:addEventListener(EventConst.ON_ALLY_MARK_STATE_CHANGED, self._onAllyMarkStateChanged)
	pg.global.eventEmitter:addEventListener(EventConst.TOPLOGO_BATTLE_ROOM_DISPLAY_CHANGED, self._onBattleRoomDisplayChanged)

	local events = pg.global.entityMgr.eventEmitter

	function self._onEntityAdd(entityId, entity)
		self:onEntityAdd(entityId, entity)
	end

	function self._onEntityRemove(entityId, staticId)
		self:onEntityRemove(entityId, staticId)
	end

	function self._onEntityEnterSpace(entity)
		self:onEntityEnterSpace(entity)
	end

	function self._onEntityLeaveSpace(entity)
		self:onEntityLeaveSpace(entity)
	end

	events:addEventListener(EventConst.ENTITY_ADD, self._onEntityAdd)
	events:addEventListener(EventConst.ENTITY_REMOVE, self._onEntityRemove)
	events:addEventListener(EventConst.ENTITY_ENTER_SPACE, self._onEntityEnterSpace)
	events:addEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onEntityLeaveSpace)
end

function MapMarkTipComponent:onSandBoxUpdate(sandboxId)
	if sandboxId == nil then
		for id, data in raw_next, self._sandboxIds do
			self:changeTipArray(data)
		end
	else
		local data = self._sandboxIds[sandboxId]

		if data then
			self:changeTipArray(data)
		end
	end
end

function MapMarkTipComponent:onAllyMarkStateChanged(entityId)
	if not self.allyMarkTipData[entityId] then
		return
	end

	local mapMarkData = self.mapMarkTipPools[entityId]

	if mapMarkData and not mapMarkData.taskId then
		self:setPlayerMarkState(entityId, mapMarkData)
	end
end

function MapMarkTipComponent:onEntityAdd(entityId, entity)
	local staticId = entity.staticId or 0
	local data = self._staticIds[staticId]

	if data then
		self._entityChanges[staticId] = entity
	end

	if self.allyMarkTipData[entityId] then
		local mapMarkData = self.mapMarkTipPools[entityId]

		if mapMarkData and not mapMarkData.taskId then
			self:setPlayerMarkState(entityId, mapMarkData)
		end
	end
end

function MapMarkTipComponent:onEntityRemove(entityId, staticId)
	staticId = staticId or 0

	local data = self._staticIds[staticId]

	if data then
		self:changeTipArray(data)

		self._entityChanges[staticId] = nil
	end

	if self.allyMarkTipData[entityId] then
		local mapMarkData = self.mapMarkTipPools[entityId]

		if mapMarkData and not mapMarkData.taskId then
			self:setPlayerMarkState(entityId, mapMarkData, true)
		end
	end
end

function MapMarkTipComponent:getDuelMarkByStaticId(staticId)
	local data = self.mapMarkTipData[staticId or 0]

	if data and data.type == DUEL_TYPE then
		return data
	end

	return nil
end

function MapMarkTipComponent:onEntityEnterSpace(entity)
	local data = self:getDuelMarkByStaticId(entity.staticId)

	if not data then
		return
	end

	data.duelEntityId = entity.id
	data.duelEntity = entity

	self:changeTipArray(data)
end

function MapMarkTipComponent:onEntityLeaveSpace(entity)
	local data = self:getDuelMarkByStaticId(entity.staticId)

	if not data or data.duelEntityId ~= entity.id then
		return
	end

	data.duelEntityId = nil
	data.duelEntity = nil

	self:changeTipArray(data)
end

function MapMarkTipComponent:onDuelStateChanged(info)
	for _, markId in ipairs(MapUtils.getDuelIdRelatedMarkIds(info and info.npcDuelId or -1)) do
		local data = self:getDuelMarkByStaticId(markId)

		if data then
			self:changeTipArray(data)
		end
	end
end

function MapMarkTipComponent:refreshAllDuelMarkState()
	for _, data in raw_next, self.mapMarkTipData do
		if data.type == DUEL_TYPE then
			self:changeTipArray(data)
		end
	end
end

function MapMarkTipComponent:updateEntityChange()
	for staticId, entity in raw_next, self._entityChanges do
		local data = self._staticIds[staticId]

		if data then
			if entity.destroyed then
				data.entity = nil
				self._entityChanges[staticId] = nil

				self:changeTipArray(data)
			elseif entity.isInited then
				data.entity = entity
				self._entityChanges[staticId] = nil

				self:changeTipArray(data)
			end
		else
			self._entityChanges[staticId] = nil
		end
	end
end

function MapMarkTipComponent:_refreshAllMarkTipDisplayState()
	for _, data in pairs(self.mapMarkTipData) do
		self:changeTipArray(data)
	end
end

function MapMarkTipComponent:filterByPos(data)
	if data.staticId then
		local entity = pg.getEntity(ClientUtils.getEntityIdByStaticId(data.staticId))

		if entity then
			setupStaticTargetPosGetter(data, entity)
		else
			data.entity = nil
			data.anchorHeight = nil
			data.sourceTargetPosGetter = getUnresolvedStaticTargetPos
			data.targetPosGetter = data.boundEntityId and getBindTargetPos or getUnresolvedStaticTargetPos
		end

		return data.boundEntityId or entity
	elseif data.sBstaticId then
		return data.boundEntityId or pg.me.space:getSandbox(data.sBstaticId)
	end

	return true
end

function MapMarkTipComponent:filterByShowDistance(data)
	local spawnerId = data.spawnerId
	local minimap = pg.global.ui.hudV2 and pg.global.ui.hudV2.LU and pg.global.ui.hudV2.LU.minimapV2

	if minimap and (minimap:checkTrackMarkExists(spawnerId) or pg.game.map:checkTrackMarkExists(spawnerId)) then
		return true
	end

	if data.isTeamMark then
		return true
	end

	local sceneId = pg.game.map.mainSceneId

	if sceneId and pg.game.map:isMarkTeamTrack(sceneId, spawnerId, true) then
		return true
	end

	if data.maxDis < 0 then
		return false
	else
		return nil
	end
end

function MapMarkTipComponent:filterByDuelState(data)
	if data.type ~= DUEL_TYPE then
		return true
	end

	if data.duelEntityId == nil or not pg.me then
		return false
	end

	return MapUtils.getNpcDuelStatus(data.spawnerId) > 0
end

function MapMarkTipComponent:changeTipArray(data)
	local spawnerId = data.spawnerId
	local isDuel = data.type == DUEL_TYPE

	if not self:filterByPos(data) or not self:filterByDuelState(data) then
		self.normalMarkTip[spawnerId] = nil
		self.trackMarkTip[spawnerId] = nil
		self._duelMarks[spawnerId] = nil

		self:setBattleRoomSuppressed(data, false)
		self:removeMapMarkTip(data.spawnerId)
	else
		local dis = self:filterByShowDistance(data)

		if dis == false then
			self.normalMarkTip[spawnerId] = nil
			self.trackMarkTip[spawnerId] = nil
			self._duelMarks[spawnerId] = nil

			self:setBattleRoomSuppressed(data, false)
			self:removeMapMarkTip(data.spawnerId)
		elseif isDuel then
			self.normalMarkTip[spawnerId] = nil
			self.trackMarkTip[spawnerId] = nil
			data.duelTracked = dis == true

			if not self._duelMarks[spawnerId] then
				self:GetTargetPos(spawnerId, data)
			end

			self._duelMarks[spawnerId] = data
		else
			self._duelMarks[spawnerId] = nil

			if not self.normalMarkTip[spawnerId] and not self.trackMarkTip[spawnerId] then
				self:GetTargetPos(spawnerId, data)
			end

			if dis then
				self.normalMarkTip[spawnerId] = nil
				self.trackMarkTip[spawnerId] = data
			else
				self.normalMarkTip[spawnerId] = data
				self.trackMarkTip[spawnerId] = nil
			end
		end
	end
end

function MapMarkTipComponent:startMapMarkTipTimer()
	if self.timer then
		return
	end

	self.timer = pg.game.camera:addLateUpdateTimer(function()
		self:startTick()
	end)
end

function MapMarkTipComponent:clearMapMarkTipTimer()
	if self.timer then
		pg.game.camera:removeLateUpdateTimer(self.timer)

		self.timer = nil
	end
end

function MapMarkTipComponent:removeAllOnNotValidScene()
	for spawnerId in raw_next, self.mapMarkTipData do
		self:removeMapMarkTip(spawnerId)
	end
end

function MapMarkTipComponent:getMarkStatus(sceneId, markType, spawnerId)
	if not self.markMap then
		return Const.MAP_MARK_STATUS_HIDE
	end

	if pg.game.map:getTempWhiteListMarkData(spawnerId) then
		return Const.MAP_MARK_STATUS_LOCKED
	end

	return self.markMap:getStatus(sceneId, markType, spawnerId)
end

function MapMarkTipComponent:updateAllMarkTip()
	local map = pg.game.map
	local sceneId = map.mainSceneId
	local updateIndex = (self.updateIndex + 1) % ConstUpdateFrameInterval

	self.updateIndex = updateIndex

	local pools = self.mapMarkTipPools

	for spawnerId, data in raw_next, self.trackMarkTip do
		local markType = data.markType
		local targetPos = data.index ~= updateIndex and data.oldPos or data.targetPosGetter(data)
		local canShow, sqrDis = self:checkTrackVisibleDistance(data, targetPos)

		if markType == Const.MAP_MARK_CLUE then
			canShow = canShow and (data.markSceneId == nil or data.markSceneId == sceneId) and sqrDis >= ConstClueNearHideSqrDis and QuestUtils.getClueMarkStatus(spawnerId) >= Const.MAP_MARK_STATUS_UNLOCKED
		else
			canShow = canShow and (data.hudShow == nil or data.isTeamMark == true or data.isForceShow or pg.game.map:isMarkTeamTrack(sceneId, spawnerId, true) or LuaUIUtils.tableContains(data.hudShow, self:getMarkStatus(sceneId, markType, spawnerId)) == true)
		end

		if canShow then
			if not self:checkPosInScreenGuidanceRegion(targetPos) then
				self:ShowMapMarkTipArrow(spawnerId, targetPos, data)
			else
				self:ShowMapMarkTip(spawnerId, targetPos, sqrDis, data)
			end
		elseif pools[spawnerId] then
			self:removeMapMarkTipEx(spawnerId)
		end
	end

	for spawnerId, data in raw_next, self.normalMarkTip do
		local markType = data.markType
		local targetPos = data.index ~= updateIndex and data.oldPos or data.targetPosGetter(data)
		local canShow, sqrDis = self:checkNormalVisibleDistance(data, targetPos, data.minDis, data.maxDis)

		if markType == Const.MAP_MARK_CLUE then
			canShow = canShow and (data.markSceneId == nil or data.markSceneId == sceneId) and sqrDis >= ConstClueNearHideSqrDis and QuestUtils.getClueMarkStatus(spawnerId) >= Const.MAP_MARK_STATUS_UNLOCKED
		else
			canShow = canShow and (data.hudShow == nil or data.isTeamMark == true or data.isForceShow or LuaUIUtils.tableContains(data.hudShow, self:getMarkStatus(sceneId, markType, spawnerId)) == true)
		end

		if canShow then
			if not self:checkPosInScreenGuidanceRegion(targetPos) then
				self:ShowMapMarkTipArrow(spawnerId, targetPos, data)
			else
				self:ShowMapMarkTip(spawnerId, targetPos, sqrDis, data)
			end
		elseif pools[spawnerId] then
			self:removeMapMarkTipEx(spawnerId)
		end
	end
end

function MapMarkTipComponent:GetTargetPos(spawnerId, data)
	return data.targetPosGetter(data)
end

function MapMarkTipComponent:updateDuelMarkTip()
	local duelMarks = self._duelMarks

	if not duelMarks then
		return
	end

	local pools = self.mapMarkTipPools
	local sceneId = pg.game.map.mainSceneId

	for spawnerId, data in raw_next, duelMarks do
		local targetPos = data.targetPosGetter(data)

		if ENABLE_DUEL_MARK_DEBUG then
			duelMarkDebug.targetPosCalls = duelMarkDebug.targetPosCalls + 1
		end

		if targetPos[1] == InvalidPosValue then
			self:setBattleRoomSuppressed(data, false)

			if pools[spawnerId] then
				self:removeMapMarkTipEx(spawnerId)
			end
		else
			local canShow, sqrDis

			if data.duelTracked then
				canShow, sqrDis = self:checkTrackVisibleDistance(data, targetPos)
			else
				canShow, sqrDis = self:checkNormalVisibleDistance(data, targetPos, data.minDis, data.maxDis)
			end

			canShow = canShow and (data.hudShow == nil or data.isTeamMark == true or data.isForceShow or pg.game.map:isMarkTeamTrack(sceneId, spawnerId, true) or LuaUIUtils.tableContains(data.hudShow, self:getMarkStatus(sceneId, data.markType, spawnerId)) == true)

			if not canShow then
				self:setBattleRoomSuppressed(data, false)

				if pools[spawnerId] then
					self:removeMapMarkTipEx(spawnerId)
				end
			else
				local inRegion = self:checkPosInScreenGuidanceRegion(targetPos)

				if ENABLE_DUEL_MARK_DEBUG then
					duelMarkDebug.projectionCalls = duelMarkDebug.projectionCalls + 1
				end

				local suppress = inRegion and self:isDuelMarkSuppressed(data)

				self:setBattleRoomSuppressed(data, suppress)

				if suppress then
					self:applyBattleRoomSuppressVisual(spawnerId)
				elseif inRegion then
					self:ShowMapMarkTip(spawnerId, targetPos, sqrDis, data)
				else
					self:ShowMapMarkTipArrow(spawnerId, targetPos, data)
				end
			end
		end
	end

	if ENABLE_DUEL_MARK_DEBUG then
		duelMarkDebug.count = 0

		for _ in raw_next, duelMarks do
			duelMarkDebug.count = duelMarkDebug.count + 1
		end
	end
end

function MapMarkTipComponent:isDuelMarkSuppressed(data)
	local entity = data.duelEntity

	if not entity then
		return false
	end

	local battleRoom = entity:getToplogoComponent(BATTLE_ROOM_COMP)

	if not battleRoom then
		return false
	end

	if ENABLE_DUEL_MARK_DEBUG then
		duelMarkDebug.suppressReads = duelMarkDebug.suppressReads + 1
	end

	return battleRoom:shouldSuppressMark()
end

function MapMarkTipComponent:setBattleRoomSuppressed(data, suppressed)
	suppressed = suppressed and true

	if data.battleRoomSuppressed == suppressed then
		return
	end

	data.battleRoomSuppressed = suppressed

	if ENABLE_DUEL_MARK_DEBUG then
		duelMarkDebug.suppressFlips = duelMarkDebug.suppressFlips + 1
	end
end

function MapMarkTipComponent:applyBattleRoomSuppressVisual(spawnerId)
	local tip = self.mapMarkTipPools[spawnerId]

	if not tip or tip.taskId then
		return
	end

	if not tip.isHidden then
		setVisible(tip.arrowTrans, false)

		tip.isHidden = true
	end

	tip.isArrow = false
	tip.showLayer = nil
	tip.activeStatus = false
end

function MapMarkTipComponent:onBattleRoomDisplayChanged(entityId, displayed)
	if ENABLE_DUEL_MARK_DEBUG then
		duelMarkDebug.battleRoomPushEvents = duelMarkDebug.battleRoomPushEvents + 1
	end
end

function MapMarkTipComponent:updateTickArray()
	if pg.me.inTeammateView then
		for id, info in raw_next, pg.me:getCurTeamInfo().membersInfo do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				if other then
					self.playerPos:Copy(other:getPosition())
				end
			end
		end
	end

	local sceneId = pg.game.map.mainSceneId
	local validScene = pg.game.map:checkValidScene(sceneId)

	if not validScene then
		for spawnerId in raw_next, self.mapMarkTipData do
			self:removeMapMarkTip(spawnerId)
		end
	else
		self:processBindMarkStatus()
		self:updateAllMarkTip()
		self:updateDuelMarkTip()
	end

	self:updateAllyMarkTip()

	for instanceId, data in raw_next, self.forceMarkTipData do
		local targetPos = data.markPosition

		if not self:checkPosInScreenGuidanceRegion(targetPos) then
			self:ShowMapMarkTipArrow(instanceId, targetPos, data)
		else
			local sqrDis = Vector3.SqrDistance(targetPos, self.playerPos)

			self:ShowMapSimpleMarkTip(instanceId, targetPos, sqrDis, data)
		end
	end
end

function MapMarkTipComponent:updateFrameThing()
	self:updateEntityChange()
	self:updateChunkChange()
	self:updateLoadingSet()

	local index = self._textQueue:pop()

	if index then
		local questItem = self.mapMarkTipPools[index]

		if questItem and questItem.distanceText then
			questItem.distanceText.text = questItem.showedDistance .. "m"
		end
	end

	local data = self._urlQueue:pop()

	if data then
		local questItem = self.mapMarkTipPools[data.spawnerId]

		if questItem and not questItem.taskId then
			self:updateUrl(questItem, data)
		end
	end
end

function MapMarkTipComponent:startTick()
	if Time.luaFrameCount % 30 == 0 then
		self:updateCache()
	end

	if not pg.me then
		self:removeAllMapMarkTip()

		return
	end

	if not pg.me.space then
		self:removeAllMapMarkTip()

		return
	end

	self.playerPos:Copy(pg.me:getPosition())

	if IS_MOBILE then
		if Time.luaFrameCount % 2 == 0 then
			self:updateTickArray()
		else
			self:updateDuelMarkTip()
			self:updateFrameThing()
		end
	else
		self:updateTickArray()
		self:updateFrameThing()
	end
end

function MapMarkTipComponent:updateAllyMarkTip()
	if not raw_next(self.allyMarkTipData) then
		return
	end

	local sceneId = pg.game.map.mainSceneId
	local isGrabEgg = pg.me and pg.me.space and pg.me.space:isGrabEgg()
	local hudDis = SceneData[sceneId].teamHudDis
	local teamHudDis

	teamHudDis = hudDis == nil and -1 or hudDis^2

	local cachePos = self.cachedTargetPos

	for instanceId, data in raw_next, self.allyMarkTipData do
		local targetPos
		local entity = pg.getEntity(data.refEntityId)
		local hideForControllingEgg = isGrabEgg and pg.game.grabEgg and pg.game.grabEgg:isEntityControllingEgg(data.refEntityId)

		if hideForControllingEgg or isGrabEgg and entity and shouldHideAllyMark(entity) then
			self:removeMapMarkTip(instanceId)
		elseif entity then
			local visualEnt = entity

			if entity.isControllingEgg and entity:isControllingEgg() then
				local eggEnt = entity:getCurControllingEgg()

				if eggEnt then
					visualEnt = eggEnt
				end
			elseif entity.isControllingPet and entity:isControllingPet() then
				local petEnt = entity.getCurPetEntity and entity:getCurPetEntity()

				if petEnt then
					visualEnt = petEnt
				end
			end

			local toplogo = visualEnt:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.COMBAT)

			if toplogo and toplogo:checkSelfVisible() and toplogo:checkFinalVisible() then
				targetPos = nil
			else
				local halfHeight = entity:getHeight() * 0.5

				cachePos:Copy(entity:getPosition())

				cachePos.y = cachePos.y + halfHeight
				targetPos = cachePos
			end
		else
			local movingPos = pg.me:getMovingEntityPosData(data.refEntityId, cachePos)

			if movingPos then
				targetPos = movingPos
			end
		end

		if targetPos then
			local canShow, sqrDis = self:checkNormalVisibleDistance(data, targetPos, data.minDis, data.maxDis)

			canShow = canShow or teamHudDis < sqrDis

			if canShow then
				if not self:checkPosInScreenGuidanceRegion(targetPos) then
					self:ShowMapMarkTipArrow(instanceId, targetPos, data)
				elseif self:checkPosInCameraBlocked(targetPos) or teamHudDis < sqrDis then
					self:ShowMapMarkTip(instanceId, targetPos, sqrDis, data)
				else
					self:removeMapMarkTip(instanceId)
				end
			else
				self:removeMapMarkTip(instanceId)
			end
		else
			self:removeMapMarkTip(instanceId)
		end
	end
end

function MapMarkTipComponent:checkSceneId(sceneId)
	local player = pg.me

	if player == nil then
		return false
	end

	if player.space == nil then
		return false
	end

	if sceneId ~= pg.game.map:convertSceneId(player.space.sceneId) then
		return false
	end

	return true
end

function MapMarkTipComponent:refreshPlayerReferences()
	if pg.me then
		self.markMap = pg.me:getSpaceOwnerMapMarkStatusMap() or pg.me.mapMarkStatusMap
	else
		self.markMap = nil
	end
end

function MapMarkTipComponent:clearPlayerReferences()
	self.markMap = nil
end

function MapMarkTipComponent:onDestroy()
	self:clearPlayerReferences()

	for id, tip in pairs(self.mapMarkTipPools) do
		self:removeMapMarkTip(id)
	end

	self.mapMarkTipPools = {}

	for id, markTip in pairs(self.mapMarkTipData) do
		Vector3.returnToPool(markTip.oldPos)

		markTip.oldPos = nil
	end

	self.mapMarkTipData = {}
	self.normalMarkTip = {}
	self.trackMarkTip = {}
	self._duelMarks = {}
	self.allyMarkTipData = {}
	self.preLoadingCount = 0

	self._urlQueue:clear()
	self._textQueue:clear()
	self:clearCaches()

	self.caches = nil
	self._loadingSet = nil
	self.chunkChanges = nil
	self.chunkLoaded = nil
	self._staticIds = nil
	self._entityChanges = nil
	self._sandboxIds = nil

	self:clearMapMarkTipTimer()

	if self.addMapMarkTrace then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_TRACE_ADD, self.addMapMarkTrace)

		self.addMapMarkTrace = nil
	end

	if self.markChunkIndexChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_CHUNK_INDEX_CHANGED, self.markChunkIndexChanged)

		self.markChunkIndexChanged = nil
	end

	if self.removeMapMarkTrace then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self.removeMapMarkTrace)

		self.removeMapMarkTrace = nil
	end

	if self.updateMapMarkTrace then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_UPDATED, self.updateMapMarkTrace)

		self.updateMapMarkTrace = nil
	end

	if self._onSandBoxUpdate then
		pg.global.eventEmitter:removeEventListener(EventConst.SANDBOX_UPDATE, self._onSandBoxUpdate)

		self._onSandBoxUpdate = nil
	end

	if self._onAllyMarkStateChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ALLY_MARK_STATE_CHANGED, self._onAllyMarkStateChanged)

		self._onAllyMarkStateChanged = nil
	end

	if self._onBattleRoomDisplayChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.TOPLOGO_BATTLE_ROOM_DISPLAY_CHANGED, self._onBattleRoomDisplayChanged)

		self._onBattleRoomDisplayChanged = nil
	end

	local events = pg.global.entityMgr.eventEmitter

	if self._onEntityAdd then
		events:removeEventListener(EventConst.ENTITY_ADD, self._onEntityAdd)

		self._onEntityAdd = nil
	end

	if self._onEntityRemove then
		events:removeEventListener(EventConst.ENTITY_REMOVE, self._onEntityRemove)

		self._onEntityRemove = nil
	end

	if self._onEntityEnterSpace then
		events:removeEventListener(EventConst.ENTITY_ENTER_SPACE, self._onEntityEnterSpace)

		self._onEntityEnterSpace = nil
	end

	if self._onEntityLeaveSpace then
		events:removeEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onEntityLeaveSpace)

		self._onEntityLeaveSpace = nil
	end

	UIComponent.onDestroy(self)
end

function MapMarkTipComponent:checkPosInScreenGuidanceRegion(targetPos)
	local targetViewportPosX, targetViewportPosY, targetViewportPosZ = pg.global.cameraMgr:GetTargetViewportPosXYZ(targetPos[1], targetPos[2], targetPos[3])

	if targetViewportPosZ > 0 then
		local vdx, vdy = targetViewportPosX - 0.5, targetViewportPosY - 0.5
		local dist = vdx * vdx * sqrX + vdy * vdy * sqrY

		return dist <= 1
	end

	return false
end

function MapMarkTipComponent:checkNormalVisibleDistance(data, targetPos, minDis, maxDis)
	local sqrDistance = Vector3.SqrDistance(targetPos, self.playerPos)

	if minDis < sqrDistance and sqrDistance < maxDis then
		if not self.ctrl:canShowTrack(self.ctrl.TRACK_PRIORITY.MAP_MARK, MapMarkTipHelper.GetTrackTargetPos(data, targetPos)) then
			return false, sqrDistance
		end

		return true, sqrDistance
	end

	return false, sqrDistance
end

function MapMarkTipComponent:checkTrackVisibleDistance(data, targetPos)
	local sqrDistance = Vector3.SqrDistance(targetPos, self.playerPos)

	if not self.ctrl:canShowTrack(self.ctrl.TRACK_PRIORITY.MAP_MARK, MapMarkTipHelper.GetTrackTargetPos(data, targetPos)) then
		return false, sqrDistance
	end

	return true, sqrDistance
end

function MapMarkTipComponent:checkPosInCameraBlocked(targetPos)
	local success = PhysicsUtils.checkCameraRayCastToPosBlocked(targetPos)

	return success
end

function MapMarkTipComponent:updateUrl(mapMarkData, data)
	local instanceId = data.spawnerId
	local icon, markType, markConfigId, replaceIcon, type, idInType = data.markIcon, data.markType, data.markConfigId, data.replaceIcon, data.type, data.idInType

	if replaceIcon then
		local url = replaceIcon

		setUrl(mapMarkData.icon, mapMarkData.lastUrl, url)

		mapMarkData.lastUrl = url
	elseif markConfigId == MapUtils.GRAB_EGG_TRANSMITTER_MARK_CONFIG_ID then
		local url = MapUtils.getGrabEggTransmitterIcon(instanceId)

		setUrl(mapMarkData.icon, mapMarkData.lastUrl, url)

		mapMarkData.lastUrl = url
	elseif type == Const.MAP_CONST.TYPE.SINGLE_PUPPET then
		local sceneId = pg.game.map.mainSceneId
		local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

		if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE)

			mapMarkData.iconPetLastUrl = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_BORDER_BOSS2)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_BORDER_BOSS2
		else
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, mapMarkData.idInTypeImgPath)

			mapMarkData.iconPetLastUrl = mapMarkData.idInTypeImgPath

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_BORDER_BOSS)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_BORDER_BOSS
		end
	elseif type == Const.MAP_CONST.TYPE.BOSS then
		local sceneId = pg.game.map.mainSceneId
		local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

		if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1)

			mapMarkData.iconPetLastUrl = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_BORDER_BOSS1)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
		else
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, mapMarkData.idInTypeImgPath)

			mapMarkData.iconPetLastUrl = mapMarkData.idInTypeImgPath

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_BORDER_BOSS1)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
		end
	elseif type == Const.MAP_CONST.TYPE.NPC then
		local spData = pg.game.map:getNPCSpecialState(instanceId)
		local imgPath

		if spData and spData.iconMap then
			imgPath = spData.iconMap
		elseif NpcFuncData[idInType].iconMap then
			imgPath = NpcFuncData[idInType].iconMap
		else
			imgPath = nil
		end

		setUrl(mapMarkData.icon, mapMarkData.iconLastUrl, imgPath)

		mapMarkData.iconLastUrl = imgPath
	elseif type == Const.MAP_CONST.TYPE.DISTRIBUTION_AREA then
		local sceneId = pg.game.map.mainSceneId
		local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

		if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE)

			mapMarkData.iconPetLastUrl = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_HABITAT)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_HABITAT
		else
			setUrl(mapMarkData.iconPet, mapMarkData.iconPetLastUrl, mapMarkData.idInTypeImgPath)

			mapMarkData.iconPetLastUrl = mapMarkData.idInTypeImgPath

			setUrl(mapMarkData.iconFrame, mapMarkData.iconFrameLastUrl, AddressDataConst.UI_MARK_IMG_HABITAT)

			mapMarkData.iconFrameLastUrl = AddressDataConst.UI_MARK_IMG_HABITAT
		end
	elseif type == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
		local url = icon
		local sceneId = pg.game.map.mainSceneId
		local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

		if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
			url = MapUtils.getMarkDefaultUnKnownResIcon(markConfigId) or icon
		end

		local floawerState = pg.me:getCurFlowerState(instanceId)

		if floawerState then
			if floawerState == LeylineFlowerConst.FLOWER_STATE.Budding then
				url = AddressDataConst.UI_LEYLINE_FLOWER_BUDDING_ICON
			elseif floawerState == LeylineFlowerConst.FLOWER_STATE.Blooming then
				url = AddressDataConst.UI_LEYLINE_FLOWER_BLOMING_ICON
			elseif floawerState == LeylineFlowerConst.FLOWER_STATE.Fruiting or floawerState == LeylineFlowerConst.FLOWER_STATE.Withering then
				url = AddressDataConst.UI_LEYLINE_FLOWER_FRUITING_ICON
			end
		end

		setUrl(mapMarkData.icon, mapMarkData.lastUrl, url)

		mapMarkData.lastUrl = url
	elseif type == DUEL_TYPE then
		local url = icon
		local sceneId = pg.game.map.mainSceneId
		local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

		if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
			url = MapUtils.getMarkDefaultUnKnownResIcon(markConfigId) or icon
		else
			url = MapUtils.getMarkDefaultResIcon(markConfigId) or icon
		end

		setUrl(mapMarkData.icon, mapMarkData.lastUrl, url)

		mapMarkData.lastUrl = url
	else
		local url = icon

		if markType ~= Const.MAP_MARK_CUSTOM and markType ~= Const.MAP_MARK_ALLY and markType ~= Const.MAP_MARK_GOLD_MONSTER then
			local sceneId = pg.game.map.mainSceneId
			local markStatus = self:getMarkStatus(sceneId, markType, instanceId)

			if markStatus < Const.MAP_MARK_STATUS_UNLOCKED then
				url = MapUtils.getMarkDefaultUnKnownResIcon(markConfigId) or icon
			end
		end

		setUrl(mapMarkData.icon, mapMarkData.lastUrl, url)

		mapMarkData.lastUrl = url
	end
end

function MapMarkTipComponent:ShowMapMarkTip(instanceId, targetPos, sqrDis, data)
	local mapMarkData = self.mapMarkTipPools[instanceId]

	if mapMarkData ~= nil then
		if mapMarkData.taskId then
			return
		end

		if mapMarkData.firstShowAni and mapMarkData.sizeRootAnimation and data.markType ~= Const.MAP_MARK_ALLY then
			mapMarkData.sizeRootAnimation:Play("VX_Node_Arrow_Tracing_In")

			mapMarkData.firstShowAni = false
		end

		if mapMarkData.isHidden then
			setVisible(mapMarkData.arrowTrans, true)

			mapMarkData.isHidden = false
		end

		if mapMarkData.isArrow then
			setVisible(mapMarkData.imgArrowTrans, false)
			setVisible(mapMarkData.distanceULayoutBoxTrans, true)

			mapMarkData.isArrow = false
		end

		local heightDiff = targetPos[2] - self.playerPos.y
		local layerGap = self.model.LAYER_GAP
		local curLayer = sqrDis <= self.model.LAYER_SQR_DISTANCE and (heightDiff < -layerGap and -1 or layerGap < heightDiff and 1 or 0) or 0

		if mapMarkData.showLayer ~= curLayer then
			if curLayer < 0 then
				setVisible(mapMarkData.txtDirectionUSDFText.transform, true)

				mapMarkData.txtDirectionUSDFText.text = pg.getGameString("LAYER_BELOW")
			elseif curLayer > 0 then
				setVisible(mapMarkData.txtDirectionUSDFText.transform, true)

				mapMarkData.txtDirectionUSDFText.text = pg.getGameString("LAYER_ABOVE")
			else
				setVisible(mapMarkData.txtDirectionUSDFText.transform, false)
			end

			mapMarkData.showLayer = curLayer
		end

		pg.global.uiMgr:SetRectTransformViewportPos(mapMarkData.arrowTrans, targetPos[1], targetPos[2], targetPos[3])

		local dis = math.floor(math.sqrt(sqrDis))

		if mapMarkData.showedDistance ~= dis then
			self._textQueue:push_unique(instanceId)

			mapMarkData.showedDistance = dis
		end

		self._urlQueue:push_unique2(data)
	else
		self:addLoadingSet(instanceId, data)
	end
end

function MapMarkTipComponent:ShowMapMarkTipArrow(instanceId, targetPos, data)
	local arrowData = self.mapMarkTipPools[instanceId]

	if arrowData then
		if arrowData.taskId then
			return
		end

		if arrowData.firstShowAni and arrowData.sizeRootAnimation and data.markType ~= Const.MAP_MARK_ALLY then
			arrowData.sizeRootAnimation:Play("VX_Node_Arrow_Tracing_In")

			arrowData.firstShowAni = false
		end

		if arrowData.isHidden then
			setVisible(arrowData.arrowTrans, true)

			arrowData.isHidden = false
		end

		if not arrowData.isArrow then
			setVisible(arrowData.imgArrowTrans, true)
			setVisible(arrowData.distanceULayoutBoxTrans, false)
			setVisible(arrowData.txtDirectionUSDFText.transform, false)

			arrowData.isArrow = true
			arrowData.showLayer = nil
		end

		LuaUIUtils.setArrowTipRtPosAndRot(arrowData.arrowTrans, arrowData.imgArrowTrans, targetPos, self.ratioX, self.ratioY, -90)
		self._urlQueue:push_unique2(data)
	else
		self:addLoadingSet(instanceId, data)
	end
end

function MapMarkTipComponent:ShowMapSimpleMarkTip(instanceId, targetPos, sqrDis, data)
	local mapMarkData = self.mapMarkTipPools[instanceId]

	if mapMarkData ~= nil then
		if mapMarkData.taskId then
			return
		end

		if mapMarkData.firstShowAni and mapMarkData.sizeRootAnimation and data.markType ~= Const.MAP_MARK_ALLY then
			mapMarkData.sizeRootAnimation:Play("VX_Node_Arrow_Tracing_In")

			mapMarkData.firstShowAni = false
		end

		if mapMarkData.isHidden then
			setVisible(mapMarkData.arrowTrans, true)

			mapMarkData.isHidden = false
		end

		if mapMarkData.isArrow then
			setVisible(mapMarkData.imgArrowTrans, false)
			setVisible(mapMarkData.distanceULayoutBoxTrans, true)

			mapMarkData.isArrow = false
		end

		local heightDiff = targetPos[2] - self.playerPos.y
		local layerGap = self.model.LAYER_GAP
		local curLayer = sqrDis <= self.model.LAYER_SQR_DISTANCE and (heightDiff < -layerGap and -1 or layerGap < heightDiff and 1 or 0) or 0

		if mapMarkData.showLayer ~= curLayer then
			if curLayer < 0 then
				setVisible(mapMarkData.txtDirectionUSDFText.transform, true)

				mapMarkData.txtDirectionUSDFText.text = pg.getGameString("LAYER_BELOW")
			elseif curLayer > 0 then
				setVisible(mapMarkData.txtDirectionUSDFText.transform, true)

				mapMarkData.txtDirectionUSDFText.text = pg.getGameString("LAYER_ABOVE")
			else
				setVisible(mapMarkData.txtDirectionUSDFText.transform, false)
			end

			mapMarkData.showLayer = curLayer
		end

		pg.global.uiMgr:SetRectTransformViewportPos(mapMarkData.arrowTrans, targetPos.x or targetPos[1], targetPos.y or targetPos[2], targetPos.z or targetPos[3])

		local dis = math.floor(math.sqrt(sqrDis))

		if mapMarkData.showedDistance ~= dis then
			self._textQueue:push_unique(instanceId)

			mapMarkData.showedDistance = dis
		end

		self._urlQueue:push_unique2(data)
	end
end

function MapMarkTipComponent:ShowMapMarkSimpleTipArrow(instanceId, targetPos, data)
	local arrowData = self.mapMarkTipPools[instanceId]

	if arrowData then
		if arrowData.taskId then
			return true
		end

		if arrowData.firstShowAni and arrowData.sizeRootAnimation and data.markType ~= Const.MAP_MARK_ALLY then
			arrowData.sizeRootAnimation:Play("VX_Node_Arrow_Tracing_In")

			arrowData.firstShowAni = false
		end

		if arrowData.isHidden then
			setVisible(arrowData.arrowTrans, true)

			arrowData.isHidden = false
		end

		if not arrowData.isArrow then
			setVisible(arrowData.imgArrowTrans, true)
			setVisible(arrowData.distanceULayoutBoxTrans, false)
			setVisible(arrowData.txtDirectionUSDFText.transform, false)

			arrowData.isArrow = true
			arrowData.showLayer = nil
		end

		LuaUIUtils.setArrowTipRtPosAndRot(arrowData.arrowTrans, arrowData.imgArrowTrans, targetPos, self.ratioX, self.ratioY, -90)
		self._urlQueue:push_unique2(data)

		return true
	end
end

function MapMarkTipComponent:setUrl(obj, lastUrl, newUrl)
	if lastUrl == newUrl then
		return
	end

	obj.url = newUrl
end

function MapMarkTipComponent:setVisible(trans, visible)
	trans.gameObject:SetActiveEx(visible)
end

function MapMarkTipComponent:addLoadingSet(instanceId, data)
	self._loadingSet[instanceId] = data
end

function MapMarkTipComponent:updateLoadingSet()
	local id, data = raw_next(self._loadingSet)

	if id then
		self._loadingSet[id] = nil

		self:addMapMarkTip(id, data)
	end
end

function MapMarkTipComponent:addMapMarkTip(instanceId, data)
	if self.mapMarkTipPools[instanceId] then
		return
	end

	local cache = self:GetFromCache()

	if cache then
		self.mapMarkTipPools[instanceId] = cache

		self:updateData(self.mapMarkTipPools[instanceId], instanceId, data)

		return
	end

	local markConfigId = data.markConfigId
	local priority = pg.game.map:getMarkPriorityByConfigId(markConfigId)
	local markLayer = string.format("markerListTransformLayer%s", priority)
	local mapMarkArrow = {}

	self.mapMarkTipPools[instanceId] = mapMarkArrow
	mapMarkArrow.markConfigId = markConfigId
	mapMarkArrow.priority = priority
	mapMarkArrow.taskId = self.view:addPrefabWithPathAsync(self.view[markLayer], AddressDataConst.QUEST_ARROW_RES, function(objInfo)
		if not self.mapMarkTipPools[instanceId] then
			pg.global.uiMgr:DestroyItem(objInfo.gameObject)

			return
		end

		mapMarkArrow.taskId = nil
		mapMarkArrow.obj = objInfo.gameObject
		mapMarkArrow.transform = objInfo.transform

		self:initObject(mapMarkArrow)
		self:updateData(mapMarkArrow, instanceId, data)
	end)
end

function MapMarkTipComponent:updateData(mapMarkArrow, instanceId, data)
	mapMarkArrow.firstShowAni = true
	mapMarkArrow.obj.name = "MapMark_Tip_" .. instanceId

	local icon, markConfigId, markType, idInType = data.markIcon, data.markConfigId, data.type, data.idInType

	mapMarkArrow.markConfigId = markConfigId

	local priority = pg.game.map:getMarkPriorityByConfigId(markConfigId)

	if mapMarkArrow.priority ~= priority then
		mapMarkArrow.priority = priority

		local markLayer = string.format("markerListTransformLayer%s", priority)
		local parent = self.view[markLayer]

		mapMarkArrow.transform:SetParent(parent.transform, false)
	end

	local markLevel = markConfigId and (DefaultMapMarkData[markConfigId].markLevel or 1) or 1
	local scaleX = UIConst.MAP_CONST.SIZE_DELTA[markLevel][1] * 0.8
	local scaleY = UIConst.MAP_CONST.SIZE_DELTA[markLevel][2] * 0.8
	local scaleZ = UIConst.MAP_CONST.SIZE_DELTA[markLevel][3] * 0.8

	mapMarkArrow.sizeRootRectTransform:SetLocalScaleEx(scaleX, scaleY, scaleZ)
	setVisible(mapMarkArrow.arrowTrans, false)

	mapMarkArrow.isHidden = true

	setVisible(mapMarkArrow.distanceULayoutBoxTrans, false)
	setVisible(mapMarkArrow.txtDirectionUSDFText.transform, false)

	mapMarkArrow.isArrow = true
	mapMarkArrow.showLayer = nil
	mapMarkArrow.activeStatus = false
	mapMarkArrow.id = instanceId
	mapMarkArrow.icon.url = icon

	mapMarkArrow.icon.gameObject:SetActiveEx(true)

	if markConfigId == Const.MAP_MARK_FAST_TARGET then
		mapMarkArrow.rootCmp:TryChangePage("HintType", 2)
		mapMarkArrow.rootCmp:TryChangePage("isPet", 0)

		local uContainer = mapMarkArrow.getEggPalyerSignUContainer

		if uContainer then
			uContainer:SetActive(true)
			uContainer:LoadDefaultUrlManually(function(widget)
				local rootCmp = widget:GetComponent("UComponent")

				if rootCmp then
					local markData = pg.game.map:getMarkInfo(instanceId)
					local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, markData.creatorUid)

					rootCmp:TryChangePage("Teammate", idx - 1)
				end
			end)
		end
	elseif markConfigId == Const.MAP_MARK_ALLY then
		mapMarkArrow.rootCmp:TryChangePage("HintType", 1)
		mapMarkArrow.rootCmp:TryChangePage("isPet", 0)
		mapMarkArrow.icon.gameObject:SetActiveEx(false)

		local uContainer = mapMarkArrow.getEggPalyerSignUContainer

		if uContainer then
			uContainer:SetActive(false)
		end

		local ent = pg.getEntity(instanceId)

		if ent then
			if ent.uid and pg.me:getCurTeamInfo().sortList then
				local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, ent.uid)

				if contain then
					mapMarkArrow.teammateUComponent:TryChangePage("Teammate", idx - 1)
				end
			end

			self:setPlayerMarkState(instanceId, mapMarkArrow)
		end
	elseif data.markType == Const.MAP_MARK_GRAB_EGG then
		mapMarkArrow.rootCmp:TryChangePage("HintType", 0)

		local uContainer = mapMarkArrow.getEggPalyerSignUContainer

		if uContainer then
			uContainer:SetActive(false)
		end

		mapMarkArrow.icon.gameObject:SetActiveEx(false)
	else
		local uContainer = mapMarkArrow.getEggPalyerSignUContainer

		if uContainer then
			uContainer:SetActive(false)
		end

		mapMarkArrow.rootCmp:TryChangePage("HintType", 0)

		if markType == Const.MAP_CONST.TYPE.SINGLE_PUPPET or markType == Const.MAP_CONST.TYPE.BOSS or markType == Const.MAP_CONST.TYPE.DISTRIBUTION_AREA then
			if markType == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
				local createId = pg.me:getCurFlowerCreateId(instanceId)
				local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(instanceId, createId)

				idInType = plentyInfo and plentyInfo.puppetId1 or nil
			end

			local puppetData = idInType and PuppetData[idInType] or nil
			local iconName = puppetData and puppetData.iconName or nil
			local imgPath = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)

			mapMarkArrow.idInTypeImgPath = imgPath

			mapMarkArrow.rootCmp:TryChangePage("isPet", 1)

			if markType == Const.MAP_CONST.TYPE.DISTRIBUTION_AREA or markType == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
				mapMarkArrow.rootCmp:TryChangePage("maskType", 1)
			else
				mapMarkArrow.rootCmp:TryChangePage("maskType", 0)
			end
		else
			mapMarkArrow.rootCmp:TryChangePage("isPet", 0)
		end
	end

	if markConfigId ~= Const.MAP_MARK_ALLY then
		self:updateUrl(mapMarkArrow, data)
	end

	self:renderTeamTrackBadge(instanceId, mapMarkArrow)
end

function MapMarkTipComponent:initObject(mapMarkArrow)
	mapMarkArrow.rootCmp = mapMarkArrow.obj:GetComponent("UComponent")

	local objectReference = mapMarkArrow.transform:GetComponent("ObjectReference")

	mapMarkArrow.arrowTrans = objectReference:GetRefValue("arrowTrans")
	mapMarkArrow.imgArrowTrans = objectReference:GetRefValue("imgArrowTrans")
	mapMarkArrow.distanceText = objectReference:GetRefValue("distanceText")
	mapMarkArrow.teammateUComponent = objectReference:GetRefValue("teammateUComponent")
	mapMarkArrow.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	mapMarkArrow.icon = objectReference:GetRefValue("icon")
	mapMarkArrow.distanceULayoutBox = objectReference:GetRefValue("distanceULayoutBox")
	mapMarkArrow.sizeRootRectTransform = objectReference:GetRefValue("sizeRootRectTransform")
	mapMarkArrow.txtDirectionUSDFText = objectReference:GetRefValue("txtDirectionUSDFText")
	mapMarkArrow.distanceULayoutBoxTrans = mapMarkArrow.distanceULayoutBox.transform
	mapMarkArrow.sizeRootAnimation = objectReference:GetRefValue("sizeRootAnimation")
	mapMarkArrow.getEggPalyerSignUContainer = objectReference:GetRefValue("getEggPalyerSignUContainer")
	mapMarkArrow.upperDynamicLoadRectTransform = objectReference:GetRefValue("upperDynamicLoadRectTransform")

	local markPetObjRef = objectReference:GetRefValue("markPetObjectReference")

	mapMarkArrow.iconPet = markPetObjRef:GetRefValue("iconPet")
	mapMarkArrow.iconFrame = markPetObjRef:GetRefValue("iconFrame")
end

function MapMarkTipComponent:addSimpleMapMarkTip(instanceId, icon)
	local tip = self.mapMarkTipPools[instanceId]

	if tip then
		if tip.sizeRootAnimation then
			tip.sizeRootAnimation:Play("VX_Node_Arrow_Tracing_In")
		end

		return
	end

	tip = {}
	self.mapMarkTipPools[instanceId] = tip

	local priority = pg.game.map:getMarkPriorityByConfigId()
	local markLayer = string.format("markerListTransformLayer%s", priority)

	tip.priority = priority
	tip.taskId = self.view:addPrefabWithPathAsync(self.view[markLayer], AddressDataConst.QUEST_ARROW_RES, function(objInfo)
		tip.taskId = nil

		local mapMarkArrow = tip

		mapMarkArrow.obj = objInfo.gameObject
		mapMarkArrow.transform = objInfo.transform
		mapMarkArrow.firstShowAni = true
		mapMarkArrow.obj.name = "MapMark_Tip_" .. instanceId
		mapMarkArrow.rootCmp = mapMarkArrow.obj:GetComponent("UComponent")

		local objectReference = objInfo.transform:GetComponent("ObjectReference")

		mapMarkArrow.arrowTrans = objectReference:GetRefValue("arrowTrans")
		mapMarkArrow.imgArrowTrans = objectReference:GetRefValue("imgArrowTrans")
		mapMarkArrow.distanceText = objectReference:GetRefValue("distanceText")
		mapMarkArrow.icon = objectReference:GetRefValue("icon")
		mapMarkArrow.distanceULayoutBox = objectReference:GetRefValue("distanceULayoutBox")
		mapMarkArrow.sizeRootRectTransform = objectReference:GetRefValue("sizeRootRectTransform")
		mapMarkArrow.txtDirectionUSDFText = objectReference:GetRefValue("txtDirectionUSDFText")
		mapMarkArrow.distanceULayoutBoxTrans = mapMarkArrow.distanceULayoutBox.transform
		mapMarkArrow.sizeRootAnimation = objectReference:GetRefValue("sizeRootAnimation")

		local markLevel = 1
		local scaleX = UIConst.MAP_CONST.SIZE_DELTA[markLevel][1] * 0.8
		local scaleY = UIConst.MAP_CONST.SIZE_DELTA[markLevel][2] * 0.8
		local scaleZ = UIConst.MAP_CONST.SIZE_DELTA[markLevel][3] * 0.8

		mapMarkArrow.sizeRootRectTransform.localScale = {
			scaleX,
			scaleY,
			scaleZ
		}

		setVisible(mapMarkArrow.arrowTrans, false)

		mapMarkArrow.isHidden = true

		setVisible(mapMarkArrow.distanceULayoutBoxTrans, false)
		setVisible(mapMarkArrow.txtDirectionUSDFText.transform, false)

		mapMarkArrow.isArrow = true
		mapMarkArrow.showLayer = nil
		mapMarkArrow.activeStatus = false
		mapMarkArrow.id = instanceId
		self.mapMarkTipPools[instanceId] = mapMarkArrow
		mapMarkArrow.icon.url = icon
	end)
end

function MapMarkTipComponent:removeMapMarkTip(id)
	self._loadingSet[id] = nil

	local tip = self.mapMarkTipPools[id]

	if tip ~= nil then
		self:AddCache(tip)

		self.mapMarkTipPools[id] = nil
	end
end

function MapMarkTipComponent:removeMapMarkTipEx(id)
	local tip = self.mapMarkTipPools[id]

	self:AddCache(tip)

	self.mapMarkTipPools[id] = nil
end

function MapMarkTipComponent:GetFromCache()
	local tip, now = raw_next(self.caches)

	if tip then
		self.caches[tip] = nil
	end

	return tip
end

function MapMarkTipComponent:AddCache(tip)
	if tip.taskId then
		pg.global.uiMgr:CancelUIAsyncTask(tip.taskId)

		return
	end

	if not tip.obj then
		return
	end

	self:_clearTeamTrackBadge(tip)

	if tip.rootCmp then
		tip.rootCmp:TryChangePage("isPet", 0)
		tip.rootCmp:TryChangePage("maskType", 0)
		tip.rootCmp:TryChangePage("HintType", 0)
	end

	tip.lastUrl = nil
	tip.iconLastUrl = nil
	tip.iconPetLastUrl = nil
	tip.iconFrameLastUrl = nil
	tip.isFallen = nil
	tip.isFallenAID = nil
	tip.isInCallHelp = nil
	tip.playerMarkState = nil

	if tip.markTimer then
		self:killTimer(tip.markTimer)

		tip.markTimer = nil
	end

	tip.showedDistance = nil

	if tip.distanceText then
		tip.distanceText.text = ""
	end

	tip.transform:SetLocalPositionEx(-9997, -9997, 0)

	self.caches[tip] = Time.unityFrameCount
end

function MapMarkTipComponent:clearCache(cache)
	if cache.taskId then
		pg.global.uiMgr:CancelUIAsyncTask(cache.taskId)

		cache.taskId = nil
	else
		self:_clearTeamTrackBadge(cache)
		pg.global.uiMgr:DestroyItem(cache.obj)

		cache.obj = nil
		cache.transform = nil
	end

	self.caches[cache] = nil
end

function MapMarkTipComponent:clearCaches()
	for cache in pairs(self.caches) do
		self:clearCache(cache)
	end
end

function MapMarkTipComponent:updateCache()
	local now = Time.unityFrameCount

	for cache, time in pairs(self.caches) do
		if now > time + 1800 then
			self:clearCache(cache)

			break
		end
	end
end

function MapMarkTipComponent:removeAllMapMarkTipByChunk()
	local saves = pg.game.map.trackMarksRecord

	for id in raw_next, self.mapMarkTipPools do
		if not saves[id] then
			self:removeMapMarkTip(id)
		end
	end
end

function MapMarkTipComponent:removeAllMapMarkTip()
	for id in raw_next, self.mapMarkTipPools do
		self:removeMapMarkTip(id)
	end
end

function MapMarkTipComponent:clearMarkTip(data)
	Vector3.returnToPool(data.oldPos)

	local spawnerId = data.spawnerId

	self.mapMarkTipData[spawnerId] = nil
	self.trackMarkTip[spawnerId] = nil
	self.normalMarkTip[spawnerId] = nil
	self._duelMarks[spawnerId] = nil
	self._loadingSet[spawnerId] = nil

	local staticId = data.staticId

	if staticId then
		self._staticIds[staticId] = nil
		self._entityChanges[staticId] = nil
	elseif data.sBstaticId then
		self._sandboxIds[data.sBstaticId] = nil
	end

	self:removeMapMarkTip(data.spawnerId)
end

function MapMarkTipComponent:setPlayerMarkState(instanceId, mapMarkData, force)
	local ent = pg.getEntity(instanceId)
	local isFallen_ST = ent and ent:FALLEN_ST() or false
	local isFALLEN_AID_ST = ent and ent:FALLEN_AID_ST() or false
	local state = 0

	if isFALLEN_AID_ST then
		state = 2
	elseif isFallen_ST then
		state = 1
	end

	if mapMarkData.playerMarkState == nil or mapMarkData.playerMarkState ~= state then
		mapMarkData.playerMarkState = state
	end

	if mapMarkData.teammateUComponent then
		mapMarkData.teammateUComponent:TryChangePage("State", state)
	end

	if mapMarkData.isFallenAID == nil or isFALLEN_AID_ST ~= mapMarkData.isFallenAID then
		if mapMarkData.markTimer then
			self:killTimer(mapMarkData.markTimer)

			mapMarkData.markTimer = nil
		end

		mapMarkData.isFallenAID = isFALLEN_AID_ST

		if mapMarkData.isFallenAID and mapMarkData.sliderUSlider then
			local fallenAidDuration = ent.fallenAidEndTime - ent:getGameTime()

			self:startSliderValueTimer(mapMarkData, function()
				return (ent.fallenAidEndTime - ent:getGameTime()) / fallenAidDuration
			end)
		else
			self:setPlayerMarkState(instanceId, mapMarkData, true)
		end
	elseif mapMarkData.isFallen == nil or isFallen_ST ~= mapMarkData.isFallen or force then
		if mapMarkData.markTimer then
			self:killTimer(mapMarkData.markTimer)

			mapMarkData.markTimer = nil
		end

		mapMarkData.isFallen = isFallen_ST

		if mapMarkData.isFallen and mapMarkData.sliderUSlider then
			self:startSliderValueTimer(mapMarkData, function()
				return ent.curHp / ent.maxHp
			end)
		end
	end

	local isInCallHelp = ent and ent:isInCallHelp() or false

	if mapMarkData.isInCallHelp == nil or isInCallHelp ~= mapMarkData.isInCallHelp then
		if mapMarkData.teammateUComponent then
			mapMarkData.teammateUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end

		mapMarkData.isInCallHelp = isInCallHelp
	end
end

function MapMarkTipComponent:startSliderValueTimer(mapMarkData, valueGetter)
	if not mapMarkData.sliderUSlider then
		return
	end

	mapMarkData.sliderUSlider.value = valueGetter()
	mapMarkData.markTimer = self:startTimer(function()
		if mapMarkData.sliderUSlider then
			mapMarkData.sliderUSlider.value = valueGetter()
		end
	end, 0.1, true)
end

function MapMarkTipComponent:initOnCreate()
	self:onSceneLoaded()

	if not pg.game.map.mainSceneId then
		return
	end

	local playerChunkIndexX, playerChunkIndexZ = MapHelper.calXAndZKey(self.playerPos.x, self.playerPos.z, pg.game.map.mainSceneId)

	self:onMapMarkChunkIndexChanged(playerChunkIndexX, playerChunkIndexZ)
end

function MapMarkTipComponent:onSceneLoaded()
	if not pg.game.map.mainSceneId then
		return
	end

	self:refreshPlayerReferences()

	self.sceneMarkData = SceneUtils.getSceneMarkPointData(pg.game.map.mainSceneId)

	self:refreshAllDuelMarkState()
end

function MapMarkTipComponent:onMapMarkChunkIndexChanged(x, z)
	local loaded = self.chunkLoaded
	local changes = self.chunkChanges

	self.teamMarkIds = {}

	local chunkData = pg.game.map.sceneMarkPointChunkData

	for _, offset in ipairs(MapHelper.CHUNK_DIRECTION) do
		local x1 = x + offset[1]
		local z1 = z + offset[2]
		local chunkX = chunkData[x1]

		if chunkX then
			local chunkZ = chunkX[z1]

			if chunkZ then
				changes[chunkZ] = true
			end
		end
	end

	for chunk in pairs(loaded) do
		if changes[chunk] then
			changes[chunk] = nil
		else
			changes[chunk] = false
		end
	end

	for spawnerId, _ in pairs(pg.game.map.teamMarkPointData) do
		self:onMapMarkAdd(spawnerId)

		self.teamMarkIds[spawnerId] = true
	end

	for spawnerId, _ in pairs(pg.game.map.tempMarkPointData) do
		if self.mapMarkTipData[spawnerId] == nil then
			self:onMapMarkAddEx(spawnerId)
		end
	end

	for spawnerId, _ in pairs(self.tracingMarkIds) do
		if self.mapMarkTipData[spawnerId] == nil then
			self:onMapMarkTraceAdd(spawnerId)
		end
	end

	self:initAllyData()
end

function MapMarkTipComponent:updateChunkChange()
	local chunk, change = raw_next(self.chunkChanges)

	if chunk then
		self.chunkChanges[chunk] = nil

		if change then
			self:addChunkMark(chunk)
		else
			self:removeChunkMark(chunk)
		end
	end
end

function MapMarkTipComponent:addChunkMark(chunk)
	self.chunkLoaded[chunk] = true

	for _, markId in pairs(chunk) do
		self:onMapMarkAddEx(markId)
	end
end

function MapMarkTipComponent:removeChunkMark(chunk)
	self.chunkLoaded[chunk] = nil

	local temps = pg.game.map.tempMarkPointData
	local traces = self.tracingMarkIds
	local bindMap = pg.game.map.bindMap

	for _, markId in pairs(chunk) do
		if not temps[markId] and not traces[markId] and not bindMap[markId] then
			self:onMapMarkRemove(markId)
		end
	end
end

function MapMarkTipComponent:_processOneBindMarkStatus(markId, entityId)
	if HasEntityPosSource(entityId) then
		if not self.mapMarkTipData[markId] then
			self:onMapMarkAddEx(markId)
		end
	else
		pg.game.map:unbindEntityPosFromMapMark(markId, entityId)
	end
end

function MapMarkTipComponent:processBindMarkStatus()
	pg.game.map:BindMapForeach(self._processOneBindMarkStatus, self)
end

function MapMarkTipComponent:onMapMarkBindEntity(info)
	local markId = info.markId
	local data = self.mapMarkTipData[markId]

	if not data then
		self:onMapMarkAddEx(markId)

		return
	end

	data.boundEntityId = info.entityId
	data.targetPosGetter = getBindTargetPos

	self:changeTipArray(data)
end

function MapMarkTipComponent:onMapMarkUnbindEntity(info)
	local data = self.mapMarkTipData[info.markId]

	if not data then
		return
	end

	restoreSourceTargetPos(data)
	self:changeTipArray(data)
end

function MapMarkTipComponent:onMapMarkAdd(spawnerId)
	if not ToBool(spawnerId) then
		return
	end

	self:onMapMarkAddEx(spawnerId)
end

function MapMarkTipComponent:onMapMarkAddEx(spawnerId)
	if self.mapMarkTipData[spawnerId] ~= nil then
		return
	end

	local data = pg.game.map:getMarkInfo(spawnerId)

	if not data then
		return
	end

	local markType = data.markType
	local isTeamMark = pg.game.map.teamMarkPointData and pg.game.map.teamMarkPointData[spawnerId] ~= nil

	if markType < 0 or markType == Const.MAP_MARK_QUEST then
		return
	end

	local markConfigId = data.markConfigId
	local defaultConfig = DefaultMapMarkData[markConfigId]
	local enableHudShow = defaultConfig and defaultConfig.enableHudShow

	if data.enableHudShow ~= nil then
		enableHudShow = data.enableHudShow
	end

	if not ToBool(enableHudShow) and markType ~= Const.MAP_MARK_GOLD_MONSTER then
		return
	end

	local player = pg.me
	local sceneId = 0

	if player and player.space then
		sceneId = SceneUtils.getMainSceneId(player.space.sceneId)
	end

	local markRes = MapMarkResourceData[markConfigId]
	local mapMarkIconData = markRes and (markRes[sceneId] or markRes[0])
	local mapMarkIcon = mapMarkIconData and mapMarkIconData.icon or nil
	local hudShow = defaultConfig and defaultConfig.hudShow
	local markIcon = data.icon or mapMarkIcon
	local boundEntityId = pg.game.map.bindMap[spawnerId]
	local isBindMapMark = boundEntityId ~= nil
	local basePos = data.markPosition
	local pos = basePos

	if isBindMapMark then
		local bindPos = GetEntityPos(boundEntityId)

		if bindPos then
			pos = bindPos
		end
	end

	if markType ~= Const.MAP_MARK_CUSTOM and markType ~= Const.MAP_MARK_TRACE and markType ~= Const.MAP_MARK_COUSTOM_TRACE and markType ~= Const.MAP_MARK_CLUE and markType ~= Const.MAP_MARK_GRAB_EGG and markType ~= Const.MAP_MARK_GOLD_MONSTER then
		if not isTeamMark and not isBindMapMark then
			if self.markMap == nil or self.sceneMarkData == nil or self.sceneMarkData[spawnerId] == nil then
				return
			end

			if not ToBool(self:getMarkStatus(sceneId, self.sceneMarkData[spawnerId].markType, spawnerId)) then
				self:onMapMarkRemove(spawnerId)

				return
			end
		elseif not isTeamMark and isBindMapMark then
			if self.markMap == nil then
				return
			end

			if not ToBool(self:getMarkStatus(sceneId, markType, spawnerId)) then
				return
			end
		end
	end

	local forceShow = markType == Const.MAP_MARK_CUSTOM or markType == Const.MAP_MARK_TRACE or markType == Const.MAP_MARK_COUSTOM_TRACE or markType == Const.MAP_MARK_GRAB_EGG or markType == Const.MAP_MARK_GOLD_MONSTER

	if data.idInType == nil or markType == Const.MAP_MARK_CAMP or not PuppetData[data.idInType] then
		-- block empty
	elseif data.type and data.type == Const.MAP_CONST.TYPE.NPC then
		local spData = pg.game.map:getNPCSpecialState(spawnerId)

		if spData and spData.iconMap then
			markIcon = spData.iconMap
		elseif NpcFuncData[data.idInType].iconMap then
			markIcon = NpcFuncData[data.idInType].iconMap
		else
			markIcon = nil
		end
	else
		markIcon = LuaUIUtils.getPetIcon(PuppetData[data.idInType].iconName, LuaUIUtils.PET_ICON) or markIcon
	end

	if markType == Const.MAP_MARK_CUSTOM and data.realSceneId then
		local sceneCustomMarkData = player.customMapMarkMap[data.realSceneId] or {}
		local genId = MapHelper.getCustomMarkGenId(spawnerId, data.realSceneId) or 1
		local markIconIndex = sceneCustomMarkData[genId] and sceneCustomMarkData[genId].markIconIndex or 0

		markIcon = AddressDataConst["UI_MARK_NODE_CUSTOM_ICON_" .. markIconIndex]
	end

	local staticId, sBstaticId
	local ownerInfo = data.ownerInfo

	if ownerInfo then
		if ownerInfo[1] == "entity" then
			staticId = ownerInfo[2]
		elseif ownerInfo[1] == "sandbox" then
			sBstaticId = ownerInfo[2]
		end
	end

	local replaceIcon = data.replaceIcon

	if markType == Const.MAP_MARK_DYNAMIC then
		local simpleIcon = MapUtils.getDynamicMarkSimpleIcon(spawnerId)

		if simpleIcon then
			replaceIcon = simpleIcon
		end
	end

	local mapMarkDistance = defaultConfig and defaultConfig.hudShowDistance
	local showDistance = data.hudShowDistance or mapMarkDistance or self.INVALID_SHOW_DIST
	local minDis = showDistance[1] < 0 and -1 or showDistance[1]^2
	local maxDis = showDistance[2] < 0 and -1 or showDistance[2]^2
	local sourceTargetPosGetter, oldPos

	if staticId then
		sourceTargetPosGetter = getUnresolvedStaticTargetPos
		oldPos = Vector3.GetFromPool(InvalidPosValue, 0, 0)
	elseif sBstaticId then
		sourceTargetPosGetter = getSandboxTargetPos
		oldPos = Vector3.GetFromPool(pos[1], pos[2], pos[3])
	else
		sourceTargetPosGetter = getFixedTargetPos
		oldPos = Vector3.GetFromPool(pos[1], pos[2], pos[3])
	end

	local targetPosGetter = boundEntityId and getBindTargetPos or sourceTargetPosGetter
	local markIndex

	if staticId then
		markIndex = self.staticIndex + 1
		self.staticIndex = markIndex
	else
		markIndex = self.markIndex + 1
		self.markIndex = markIndex
	end

	local markTip = {
		offset = 0,
		spawnerId = spawnerId,
		markIcon = markIcon,
		markType = markType,
		markConfigId = markConfigId,
		targetPos = pos,
		basePos = basePos,
		minDis = minDis,
		maxDis = maxDis,
		hudShow = hudShow,
		staticId = staticId,
		sBstaticId = sBstaticId,
		isForceShow = forceShow,
		isTeamMark = isTeamMark,
		replaceIcon = replaceIcon,
		type = data.type,
		idInType = data.idInType,
		index = markIndex % ConstUpdateFrameInterval,
		sourceTargetPosGetter = sourceTargetPosGetter,
		targetPosGetter = targetPosGetter,
		boundEntityId = boundEntityId,
		oldPos = oldPos
	}

	if markTip.staticId then
		self._staticIds[markTip.staticId] = markTip
	elseif markTip.sBstaticId then
		self._sandboxIds[markTip.sBstaticId] = markTip
	end

	if markType == Const.MAP_MARK_CLUE then
		local markSceneId = data.sceneId or data.realSceneId

		markTip.markSceneId = markSceneId and pg.game.map:convertSceneId(markSceneId) or nil
	end

	if markTip.type == DUEL_TYPE then
		local duelEntity = player and player.space and player.space:getEntityByStaticId(spawnerId)

		markTip.duelEntityId = duelEntity and duelEntity.id or nil
		markTip.duelEntity = duelEntity
		markTip.sourceTargetPosGetter = getDuelTargetPos
		markTip.targetPosGetter = boundEntityId and getBindTargetPos or getDuelTargetPos
	end

	self.mapMarkTipData[spawnerId] = markTip

	self:changeTipArray(markTip)
end

function MapMarkTipComponent:onMapMarkRemove(spawnerId)
	if spawnerId == nil then
		return
	end

	local markTip = self.mapMarkTipData[spawnerId]

	if not markTip then
		return
	end

	self:clearMarkTip(markTip)
end

function MapMarkTipComponent:onMapMarkUpdate(info)
	self:onMapMarkRemove(info.id)

	if info.type == "addOrUpdate" then
		self:onMapMarkAdd(info.id)
	end
end

function MapMarkTipComponent:onTeamMarkChange()
	self.teamMarkIds = self.teamMarkIds or {}

	local teamMarkPointData = pg.game.map.teamMarkPointData or {}
	local currentTeamMarkIds = {}

	for markId, markPointData in pairs(teamMarkPointData) do
		currentTeamMarkIds[markId] = true

		local cache = self.mapMarkTipData[markId]
		local shouldReload = not cache

		if not markPointData or not markPointData.markPosition then
			self:onMapMarkRemove(markId)
		elseif cache and cache.targetPos then
			shouldReload = cache.markType ~= markPointData.markType or cache.markConfigId ~= markPointData.markConfigId or cache.targetPos[1] ~= markPointData.markPosition[1] or cache.targetPos[2] ~= markPointData.markPosition[2] or cache.targetPos[3] ~= markPointData.markPosition[3]
		end

		if markPointData and markPointData.markPosition and shouldReload then
			self:onMapMarkRemove(markId)
			self:onMapMarkAdd(markId)
		end
	end

	for markId, _ in pairs(self.teamMarkIds) do
		if not currentTeamMarkIds[markId] then
			self:onMapMarkRemove(markId)
		end
	end

	self.teamMarkIds = currentTeamMarkIds
end

function MapMarkTipComponent:onMapMarkTraceAdd(spawnerId)
	if spawnerId == nil then
		return
	end

	if not self.mapMarkTipData[spawnerId] then
		self:onMapMarkAdd(spawnerId)

		self.tracingMarkIds[spawnerId] = true
	elseif not self.tracingMarkIds[spawnerId] then
		self:changeTipArray(self.mapMarkTipData[spawnerId])

		self.tracingMarkIds[spawnerId] = true
	end

	self:_refreshAllMarkTipDisplayState()
end

function MapMarkTipComponent:onMapMarkTraceRemove(spawnerId)
	self.tracingMarkIds[spawnerId] = nil

	local data = self.mapMarkTipData[spawnerId]

	if not data then
		return
	end

	local chunk = pg.game.map:getChunkByPos(data.targetPos)
	local needRemove = false

	needRemove = not chunk and true or self.chunkChanges[chunk] == false or not self.chunkLoaded[chunk]

	if needRemove then
		self:onMapMarkRemove(spawnerId)
	else
		self:changeTipArray(data)
	end

	self:_refreshAllMarkTipDisplayState()
end

local function getSpaceFollowUid(ent)
	if ent and ent.CONTROLLING_PET_ST and ent:CONTROLLING_PET_ST() and ent.master then
		return ent.master.uid
	end

	return ent and ent.uid
end

function MapMarkTipComponent:onAllyChanged(data)
	local isAdd = data.entryAdd
	local refEntityId = data.refEntityId

	if isAdd then
		local ent = pg.getEntity(refEntityId)
		local uid = getSpaceFollowUid(ent)

		if pg.me and pg.me.shouldHideByMySpaceFollowTeam and pg.me:shouldHideByMySpaceFollowTeam(uid) then
			self.allyMarkTipData[refEntityId] = nil

			self:removeMapMarkTip(refEntityId)

			return
		end

		local player = pg.me
		local sceneId = 0

		if player and player.space then
			sceneId = pg.game.map:convertSceneId(player.space.sceneId)
		end

		local markType = Const.MAP_MARK_ALLY
		local mapMarkIconData

		if MapMarkResourceData[markType] and (MapMarkResourceData[markType][sceneId] or MapMarkResourceData[markType][0]) then
			mapMarkIconData = MapMarkResourceData[markType][sceneId] or MapMarkResourceData[markType][0]
		end

		local mapMarkIcon = mapMarkIconData and mapMarkIconData.icon or nil
		local mapMarkDistance = DefaultMapMarkData[markType] and DefaultMapMarkData[markType].hudShowDistance
		local hudShow = DefaultMapMarkData[markType] and DefaultMapMarkData[markType].hudShow
		local markIcon = data.imgPath or mapMarkIcon
		local showDistance = data.hudShowDistance or mapMarkDistance
		local minDis = showDistance[1] < 0 and -1 or showDistance[1]^2
		local maxDis = showDistance[2] < 0 and -1 or showDistance[2]^2
		local markConfigId = markType

		self.allyMarkTipData[refEntityId] = {
			spawnerId = refEntityId,
			markIcon = markIcon,
			markType = markType,
			markConfigId = markConfigId,
			minDis = minDis,
			maxDis = maxDis,
			refEntityId = refEntityId,
			showDistance = showDistance,
			hudShow = hudShow
		}
		data.markConfigId = Const.MAP_MARK_ALLY

		self:addMapMarkTip(refEntityId, data)
	else
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info(string.format("@hyj onAllyRemoved: refEntityId = %s", refEntityId))
		end

		self.allyMarkTipData[refEntityId] = nil

		self:removeMapMarkTip(refEntityId)
	end
end

function MapMarkTipComponent:initAllyData()
	local player = pg.me
	local sceneId = 0

	if player and player.space then
		sceneId = pg.game.map:convertSceneId(player.space.sceneId)
	end

	if not ToBool(sceneId) then
		return
	end

	if not MapHelper.IsShowTeam(sceneId) then
		return
	end

	local memberInfo = player:getCurTeamInfo().membersInfo or {}

	for _, info in pairs(memberInfo) do
		if info.entityId ~= player.id then
			self:onAllyChanged({
				entryAdd = true,
				refEntityId = info.entityId
			})
		end
	end
end

function MapMarkTipComponent:refreshAllArrowHideState()
	if pg.game.setting:getHideAllHudArrowType() then
		for spawnerId, data in pairs(self.mapMarkTipData) do
			data.battleRoomSuppressed = nil

			self:removeMapMarkTip(spawnerId)
		end

		for instanceId in pairs(self.allyMarkTipData) do
			self:removeMapMarkTip(instanceId)
		end
	end
end

function MapMarkTipComponent:forceShowHudMark(markPosition, markIcon, id, show)
	if not show then
		self:removeMapMarkTip(id)

		self.forceMarkTipData[id] = nil

		return
	end

	local forceMarkTipData = {
		replaceIcon = markIcon,
		markPosition = markPosition,
		spawnerId = id
	}

	self.forceMarkTipData[id] = forceMarkTipData

	self:addSimpleMapMarkTip(id, markIcon)
end

function MapMarkTipComponent:onDynamicMarkStatusChanged(info)
	if self.mapMarkTipData[info.markId] then
		local replaceIcon = MapUtils.getDynamicMarkSimpleIcon(info.markId)

		self.mapMarkTipData[info.markId].replaceIcon = replaceIcon
	end
end

function MapMarkTipComponent:onTeamMarkTrackChange()
	for spawnerId, data in pairs(self.mapMarkTipData) do
		self:changeTipArray(data)
	end

	local teamInfo = pg.me:getCurTeamInfo()
	local sortList = teamInfo and teamInfo.sortList

	for spawnerId, mapMarkArrow in pairs(self.mapMarkTipPools) do
		if not mapMarkArrow.taskId then
			if mapMarkArrow.markConfigId == Const.MAP_MARK_ALLY then
				local ent = pg.getEntity(spawnerId)

				if ent and ent.uid and sortList then
					local contain, idx = LuaUIUtils.tableContains(sortList, ent.uid)

					if contain then
						mapMarkArrow.teammateUComponent:TryChangePage("Teammate", idx - 1)
					end
				end
			else
				self:renderTeamTrackBadge(spawnerId, mapMarkArrow)
			end
		end
	end

	local mainSceneId = pg.game.map.mainSceneId
	local teamInfo = pg.me and pg.me:getShowTeamInfo()
	local teamFixedMarkTrackMap = teamInfo and teamInfo.teamFixedMarkTrackMap or {}
	local sceneTrackMap = mainSceneId and teamFixedMarkTrackMap[mainSceneId]

	if sceneTrackMap then
		for spawnerId, trackUids in pairs(sceneTrackMap) do
			if trackUids and trackUids[1] and not self.mapMarkTipData[spawnerId] then
				self:onMapMarkAdd(spawnerId)
			end
		end
	end
end

function MapMarkTipComponent:renderTeamTrackBadge(spawnerId, mapMarkArrow)
	local data = self.mapMarkTipData[spawnerId]

	if not data then
		return
	end

	if data.markConfigId == Const.MAP_MARK_FAST_TARGET then
		return
	end

	if data.markConfigId == Const.MAP_MARK_ALLY then
		return
	end

	local parent = mapMarkArrow.upperDynamicLoadRectTransform

	if not parent then
		return
	end

	local markType = data.type

	if data.markType == Const.MAP_MARK_GRAB_EGG then
		if mapMarkArrow._teamTrackObj then
			self:_updateGrabEggBadgeUI(mapMarkArrow, spawnerId)
		else
			if mapMarkArrow._teamTrackTaskId then
				pg.global.uiMgr:CancelUIAsyncTask(mapMarkArrow._teamTrackTaskId)

				mapMarkArrow._teamTrackTaskId = nil
			end

			mapMarkArrow._teamTrackTaskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.UI_MARK_NODE_GRAB_EGG_HUGE_EGG, function(obj)
				mapMarkArrow._teamTrackTaskId = nil

				if not self.mapMarkTipPools[spawnerId] then
					pg.global.uiMgr:DestroyItem(obj.gameObject)

					return
				end

				mapMarkArrow._teamTrackObj = obj.gameObject
				mapMarkArrow._teamTrackObjRef = obj.gameObject:GetComponent("ObjectReference")

				obj.gameObject:GetComponent("RectTransform"):SetAnchoredPositionEx(0, -25)
				self:_updateGrabEggBadgeUI(mapMarkArrow, spawnerId)
			end, false, false, 0)
		end

		return
	end

	local isTrack, firstTrackUid = pg.game.map:getTrackInfo(pg.game.map.mainSceneId, markType, spawnerId)

	if isTrack then
		if mapMarkArrow._teamTrackObj then
			self:_updateTeamTrackBadgeUI(mapMarkArrow, firstTrackUid)
		else
			if mapMarkArrow._teamTrackTaskId then
				pg.global.uiMgr:CancelUIAsyncTask(mapMarkArrow._teamTrackTaskId)

				mapMarkArrow._teamTrackTaskId = nil
			end

			mapMarkArrow._teamTrackTaskId = self.view:addPrefabWithPathAsync(parent, AddressDataConst.UI_MARK_NODE_PLAYER_NUM, function(obj)
				mapMarkArrow._teamTrackTaskId = nil

				if not self.mapMarkTipPools[spawnerId] then
					pg.global.uiMgr:DestroyItem(obj.gameObject)

					return
				end

				mapMarkArrow._teamTrackObj = obj.gameObject

				local uComponent = obj.gameObject:GetComponent("UComponent")
				local objectReference = obj.gameObject:GetComponent("ObjectReference")

				mapMarkArrow._teamTrackRootCmp = uComponent
				mapMarkArrow._teamTrackTxtNum = objectReference and objectReference:GetRefValue("txtPlayerNum")
				obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_TARCKLOC

				self:_updateTeamTrackBadgeUI(mapMarkArrow, firstTrackUid)
			end, false, false, 0)
		end
	else
		self:_clearTeamTrackBadge(mapMarkArrow)
	end
end

function MapMarkTipComponent:_updateTeamTrackBadgeUI(mapMarkArrow, firstTrackUid)
	if not NotNil(mapMarkArrow._teamTrackRootCmp) then
		return
	end

	local sortList = pg.me:getCurTeamInfo().sortList

	if not sortList then
		self:_clearTeamTrackBadge(mapMarkArrow)

		return
	end

	local contain, idx = LuaUIUtils.tableContains(sortList, firstTrackUid)

	if contain then
		mapMarkArrow._teamTrackRootCmp:TryChangePage("Teammate", idx - 1)

		if mapMarkArrow._teamTrackTxtNum then
			ClientTextUtils.setText(mapMarkArrow._teamTrackTxtNum, idx)
		end
	else
		self:_clearTeamTrackBadge(mapMarkArrow)
	end
end

function MapMarkTipComponent:_updateGrabEggBadgeUI(mapMarkArrow, spawnerId)
	local objRef = mapMarkArrow._teamTrackObjRef

	if not NotNil(objRef) then
		return
	end

	local eggView = GrabEggMapMarkUtils.getEggView(spawnerId)
	local data = self.mapMarkTipData[spawnerId]
	local markConfigId = data and data.markConfigId
	local sceneId = 0

	if pg.me and pg.me.space then
		sceneId = SceneUtils.getMainSceneId(pg.me.space.sceneId)
	end

	local markRes = markConfigId and MapMarkResourceData[markConfigId]
	local mapMarkIconData = markRes and (markRes[sceneId] or markRes[0])
	local iconImgPath = mapMarkIconData and mapMarkIconData.icon

	GrabEggMapMarkUtils.applyEggMarkView(objRef, eggView, iconImgPath)
end

function MapMarkTipComponent:_clearTeamTrackBadge(mapMarkArrow)
	if mapMarkArrow._teamTrackTaskId then
		pg.global.uiMgr:CancelUIAsyncTask(mapMarkArrow._teamTrackTaskId)

		mapMarkArrow._teamTrackTaskId = nil
	end

	if mapMarkArrow._teamTrackObj then
		pg.global.uiMgr:DestroyItem(mapMarkArrow._teamTrackObj)

		mapMarkArrow._teamTrackObj = nil
	end

	mapMarkArrow._teamTrackRootCmp = nil
	mapMarkArrow._teamTrackTxtNum = nil
	mapMarkArrow._teamTrackObjRef = nil
end

function MapMarkTipComponent:onCustomMarkIconChanged(info)
	local mapMarkData = self.mapMarkTipPools[info.id]

	if not mapMarkData then
		return
	end

	local icon = mapMarkData.icon

	if not url then
		return
	end

	icon.url = AddressDataConst["UI_MARK_NODE_CUSTOM_ICON_" .. info.markIconIndex or 0]
end

return MapMarkTipComponent
