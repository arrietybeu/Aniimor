-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientMapComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EventConst = require("Const.EventConst")
local MapHelper = require("GameApp.Map.MapHelper")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local GlobalData = require("Core.Client.GlobalData")
local MapLevelConfigData = require("Data.map_level_config_data")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local SceneUtils = require("Common.Utils.SceneUtils")
local MapMarkLeylineTreeLargeAreaIndexData = require("Data.map_mark_leylinetree_large_area_index_data")
local ClientMapComponent = Class.Component("ClientMapComponent")
local MAP_FOG_UPLOAD_INTERVAL = 5

function ClientMapComponent:onLeaveSpace()
	return
end

function ClientMapComponent:onEnterSpace()
	self.mapFogContentCacheMap = {}
	self.mapFogRequestCallbacks = {}
	self.mapFogRequestTimerIds = {}
	self.mapFogDirtyFlag = {}
	self.mapFogUploadTimer = nil
	self.mapFogContentDisplayFlag = true
	self.spaceOwnerMapMarkCache = nil

	if not self.isMainPlayer then
		return
	end

	self.enterSpaceFlag = true
end

function ClientMapComponent:setMapFogDataDirtyFlag(flag, blockIndex)
	blockIndex = blockIndex or 1

	if flag == false then
		flag = nil
	end

	self.mapFogDirtyFlag[blockIndex] = flag

	if self.enterSpaceFlag then
		self.enterSpaceFlag = false

		self:uploadMapFogToServer(true)
	end
end

function ClientMapComponent:getCurrentSceneMapFogContent()
	local sceneId = MapHelper.getRootScene(pg.game.map:convertSceneId(self.space and self.space.sceneId))

	return self.mapFogContentCacheMap[sceneId]
end

function ClientMapComponent:getFirstCreateMapFogContent()
	return {
		ClientRepo.protoCodec:encode({
			fogLighter = {
				0,
				0
			}
		})
	}
end

function ClientMapComponent:startMapFogServerRefresh()
	if not self.isMainPlayer then
		return
	end

	local sceneId = MapHelper.getRootScene(pg.game.map:convertSceneId(self.space and self.space.sceneId))

	self:tryRefreshMapFog(sceneId, nil, true)

	if _G_IsDebugMode then
		self:refreshMapFogByFlag(not self.mapFogWholeUnlocked[sceneId])
	end
end

function ClientMapComponent:tryRefreshMapFog(sceneId, callback, force)
	local contentTable = self.mapFogContentCacheMap[sceneId]

	if contentTable ~= nil and not force then
		if callback ~= nil then
			callback(contentTable)
		end

		return
	end

	local storageKey = self.mapFogStorageKeyMap[sceneId]

	if storageKey == nil and not Utils.isServerDrivenDungeonFog(sceneId) then
		local contentTable = self:getFirstCreateMapFogContent()

		self:callRefreshMapFog(sceneId, Const.MAP_FOG_FIRST_CREATE, contentTable)
		self:_onRefreshMapFog(sceneId, contentTable)

		if callback ~= nil then
			callback(contentTable)
		end

		return
	end

	local callbackTable = self.mapFogRequestCallbacks[sceneId]

	if callbackTable == nil then
		self.mapFogRequestCallbacks[sceneId] = {
			callback
		}

		self:callRefreshMapFog(sceneId, Const.MAP_FOG_FULL_DOWNLOAD, {})
	else
		callbackTable[#callbackTable + 1] = callback
	end

	local requestTimerId = self.mapFogRequestTimerIds[sceneId]

	if requestTimerId == nil then
		local endTs = Time.realSecondCache + 3

		self.mapFogRequestTimerIds[sceneId] = self:addRepeatTimer(1, function()
			if Time.realSecondCache >= endTs then
				self:_onRefreshMapFog(sceneId, nil)
			end
		end)
	end
end

function ClientMapComponent:_onRefreshMapFog(sceneId, contentTable)
	self.mapFogContentCacheMap[sceneId] = contentTable

	local requestTimerId = self.mapFogRequestTimerIds[sceneId]

	if requestTimerId ~= nil then
		self:removeTimer(requestTimerId)

		self.mapFogRequestTimerIds[sceneId] = nil

		for _, cb in ipairs(self.mapFogRequestCallbacks[sceneId] or EMPTY_TABLE) do
			cb(contentTable)
		end

		self.mapFogRequestCallbacks[sceneId] = nil
	end

	local space = self.space

	if space ~= nil and not Utils.isServerDrivenDungeonFog(sceneId) and sceneId == MapHelper.getRootScene(pg.game.map:convertSceneId(space.sceneId)) and self.mapFogUploadTimer == nil then
		self.mapFogUploadTimer = self:addRepeatTimer(MAP_FOG_UPLOAD_INTERVAL, CallbackHandler(self, "uploadMapFogToServer"))
	end
end

function ClientMapComponent:uploadMapFogToServer(force)
	local sceneId = MapHelper.getRootScene(pg.game.map:convertSceneId(self.space and self.space.sceneId))

	if Utils.isServerDrivenDungeonFog(sceneId) then
		return
	end

	if not self.mapFogContentCacheMap[sceneId] then
		return
	end

	if not force and not next(self.mapFogDirtyFlag) then
		return
	end

	local contentTable = {}

	for blockIndex, _ in pairs(self.mapFogDirtyFlag) do
		self:setMapFogDataDirtyFlag(nil, blockIndex)

		local newMapFogContent = ClientRepo.protoCodec:encode(pg.game.map:getBitMask(blockIndex, sceneId))

		contentTable[blockIndex] = newMapFogContent
		self.mapFogContentCacheMap[sceneId][blockIndex] = newMapFogContent
	end

	self:callRefreshMapFog(sceneId, Const.MAP_FOG_INC_UPLOAD, contentTable)
end

function ClientMapComponent:callRefreshMapFog(sceneId, refreshType, contentTable)
	self:serverMsg("RPC_CS_RefreshMapFog", sceneId, refreshType, contentTable, function(ret)
		if ret ~= NoticeDef.SUCCESS then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("__fog RPC_CS_RefreshMapFog ret=%s, sceneId=%s, refreshType=%d, contentKeys=%s", NoticeDef.getRepr(ret), sceneId, refreshType, inspect(lume.keys(contentTable)))
			end

			return
		end
	end)
end

local function getMapFogLogStr(refreshType, contentTable)
	local typeStr = Const.MAP_FOG_LOG_STR[refreshType] or "unknown"

	if refreshType == Const.MAP_FOG_FULL_DOWNLOAD then
		return string.format("%s contentTable_keys=%s", typeStr, inspect(lume.keys(contentTable)))
	end

	return typeStr
end

function ClientMapComponent:RPC_SC_RefreshMapFogCallback(sceneId, refreshType, contentTable)
	if not Utils.isRobEggSceneId(sceneId) then
		local storageKey = self.mapFogStorageKeyMap[sceneId]

		if storageKey == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:error("__fog refreshMapFog server callback no storageKey, sceneId=%s, refreshType=%d, contentKeys=%s", sceneId, refreshType, inspect(lume.keys(contentTable)))
			end

			return
		end
	end

	pg.temp = contentTable

	if refreshType == Const.MAP_FOG_FULL_DOWNLOAD then
		self:_onRefreshMapFog(sceneId, contentTable)
	elseif refreshType == Const.MAP_FOG_INC_SERVER_PUSH then
		self:onServerPushMapFog(sceneId, contentTable)
	end
end

function ClientMapComponent:onServerPushMapFog(sceneId, contentTable)
	if contentTable == nil then
		return
	end

	local cachedContent = self.mapFogContentCacheMap[sceneId]

	if cachedContent == nil then
		return
	end

	for blockIndex, content in pairs(contentTable) do
		cachedContent[blockIndex] = content
	end

	pg.game.map:applyServerFogPush(sceneId, contentTable)
end

function ClientMapComponent:isSpaceOwner()
	return self.space and self.space.ownerPlayerId == self.id
end

function ClientMapComponent:isUsingSpaceOwnerMap()
	if not self.space or not Utils.isSpaceSingleWorld(self.space.spaceType) then
		return false
	end

	if not self:isInTeam() or not self.inLeaderWorld then
		return false
	end

	return true
end

function ClientMapComponent:getSpaceOwnerMapMarkStatus(sceneId, markType, portalId)
	local mapMarkStatusMap = self:getSpaceOwnerMapMarkStatusMap() or self.mapMarkStatusMap

	return mapMarkStatusMap:getStatus(sceneId, markType, portalId)
end

function ClientMapComponent:getSpaceOwnerMapMarkStatusMap()
	if not self:isUsingSpaceOwnerMap() then
		return nil
	end

	local leaderPlayer = self:getTeamLeaderPlayer()

	if leaderPlayer == nil then
		return nil
	end

	if leaderPlayer.spaceOwnerMapMarkCache == nil then
		local function initRealTable(dstTable, markType, srcTable)
			dstTable[markType] = {}

			for markId, status in pairs(srcTable) do
				local dmmdd = Utils.getMarkConfigByMarkId(markId, self.space and self.space.id)

				if dmmdd and ToBool(dmmdd.multiplayerPoiType) then
					dstTable[markType][markId] = status
				end
			end

			return dstTable[markType]
		end

		leaderPlayer.spaceOwnerMapMarkCache = setmetatable({
			getStatus = function(_, sceneId, markType, staticId)
				local space = self.space

				return leaderPlayer.mapMarkStatusMap:getFilteredStatus(sceneId, markType, staticId, space and space.id)
			end
		}, {
			__len = leaderPlayer.mapMarkStatusMap and getmetatable(leaderPlayer.mapMarkStatusMap).__len,
			__pairs = leaderPlayer.mapMarkStatusMap and getmetatable(leaderPlayer.mapMarkStatusMap).__pairs,
			__index = function(tb1, key)
				local src = leaderPlayer.mapMarkStatusMap[key]

				if src == nil then
					return nil
				end

				if type(key) == "number" then
					return setmetatable({}, {
						__len = leaderPlayer.mapMarkStatusMap[key] and getmetatable(leaderPlayer.mapMarkStatusMap[key]).__len,
						__pairs = leaderPlayer.mapMarkStatusMap[key] and getmetatable(leaderPlayer.mapMarkStatusMap[key]).__pairs,
						__index = function(tb2, key2)
							local src2 = leaderPlayer.mapMarkStatusMap[key][key2]

							if src2 == nil then
								return nil
							end

							if type(key2) == "number" then
								local copiedTable = initRealTable(tb2, key2, src2)

								return setmetatable(copiedTable, {
									__index = function(tb3, key3)
										if type(key3) == "number" then
											return rawget(tb3, key3)
										else
											return leaderPlayer.mapMarkStatusMap[key][key2][key3]
										end
									end
								})
							else
								return src2
							end
						end
					})
				else
					return src
				end
			end
		})
	end

	return leaderPlayer.spaceOwnerMapMarkCache
end

function ClientMapComponent:onMapMarkStatusMap_changed(_, mapMarkStatusMap)
	mapMarkStatusMap:clearStatusCache()
end

function ClientMapComponent:OnMapMarkStatusChange(sceneId, markType, staticId, oldVal, newVal, skipNotifyPoiChange)
	if not self.isMainPlayer and (not self:isSpaceOwner() or not pg.me:isUsingSpaceOwnerMap()) then
		return
	end

	if self:isSpaceOwner() then
		self.spaceOwnerMapMarkCache = nil
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onMapMarkStatus_changed who=%s, old=%s, new=%s", self.id, oldVal, newVal, sceneId, markType, staticId, tostring(skipNotifyPoiChange))
	end

	pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
		type = "addOrUpdate",
		id = staticId
	})

	local staticIdInfo = pg.game.map.sceneMarkPointData[staticId]

	GlobalData.BILogger:customeLog("map_flow", {
		role_name = self.playerName,
		sceneId = sceneId,
		markpoint_uid = staticId,
		markpoint_type = markType,
		state = newVal,
		preState = oldVal,
		markName = pg.getLocalizationText(staticIdInfo and staticIdInfo.infoTitle or "Empty")
	})

	if not skipNotifyPoiChange and staticIdInfo and staticIdInfo.POIOrNot and staticIdInfo.POIState and LuaUIUtils.tableContains(staticIdInfo.POIState, newVal) and staticIdInfo.POIShowType and self:checkDistance(staticIdInfo) then
		local msg = {
			state = 1,
			priority = staticIdInfo.POIPriority,
			uniqueId = staticId,
			args = {
				POIShowType = staticIdInfo.POIShowType,
				POIIcon = staticIdInfo.POIIcon,
				POIMusic = staticIdInfo.POIMusic,
				title = staticIdInfo.infoTitle,
				subTitle = staticIdInfo.POIDesc,
				sceneId = sceneId,
				staticId = staticId
			}
		}

		pg.global.ui.tips:showPoi(msg)

		pg.game.map.mapHudOnceTable[staticId] = true
	end

	if oldVal ~= Const.MAP_MARK_STATUS_UNLOCKED and newVal == Const.MAP_MARK_STATUS_UNLOCKED then
		if markType == Const.MAP_MARK_LEYLINETREE then
			self.curTreeMarkId = staticId

			facade:SendMessageCommand(MessageName.MAP_AREA_ACTIVE, {
				sceneId = sceneId,
				markId = staticId,
				markType = markType
			})
		elseif staticIdInfo and staticIdInfo.markConfigId == Const.MAP_MARK_LEYLINETREE_TRANSMIT and staticIdInfo.largeAreaId ~= 0 and not pg.me:getAreaFirstInData(staticIdInfo.largeAreaId) and Utils.checkTransmit(staticId) then
			pg.game.map.curUnlockedLargeAreaId = staticIdInfo.largeAreaId

			TimerManager.addTimer(0.5, function()
				pg.global.ui:open(UIConst.UI_ID_MAP, {
					isUnlockArea = true,
					onMarkLoaded = function(spawnerId, spawnerTable)
						if spawnerId == staticId then
							pg.global.ui.map:addActivatedVX(spawnerId, false, true)
						end
					end
				}, function()
					return
				end)
			end)
		end
	end

	if newVal == Const.MAP_MARK_STATUS_CLOSED then
		-- block empty
	end

	self:dealFirstInArea(staticId, oldVal, newVal)
end

function ClientMapComponent:RPC_SC_OnMapMarkStatusChange(sceneId, markType, staticId, oldVal, newVal, skipNotifyPoiChange)
	self:OnMapMarkStatusChange(sceneId, markType, staticId, oldVal, newVal, skipNotifyPoiChange)
end

function ClientMapComponent:checkDistance(staticIdInfo)
	if staticIdInfo and staticIdInfo.markPosition and staticIdInfo.activeDistance then
		local distance = Vector3.Distance(pg.me:getPosition(), staticIdInfo.markPosition)

		if distance <= staticIdInfo.activeDistance then
			return true
		end

		return false
	else
		return true
	end
end

function ClientMapComponent:onCustomMapMarkMap_changed(oldVal, newVal, sceneId, genId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCustomMapMarkMap_changed old=%s, new=%s", inspect(oldVal), inspect(newVal), sceneId, genId)
	end

	local map = pg.global.ui.map
	local id = tonumber(string.format("%s%s%s%s", sceneId, Const.MAP_MARK_CUSTOM, Const.MAP_MARK_CUSTOM, genId))

	facade:sendMsgToUI(MessageName.CUSTOM_MARK_ICON_CHANGED, {
		id = id,
		markIconIndex = newVal.markIconIndex
	})

	if sceneId ~= pg.game.map:convertSceneId(pg.me.space.sceneId) then
		pg.game.map:addOrUpdateTempMark(sceneId, newVal.pos[1], newVal.pos[2], newVal.pos[3], id, Const.MAP_MARK_CUSTOM, {
			markIconIndex = newVal.markIconIndex
		}, map.tempMarkPointData)

		return
	end

	pg.game.map:addOrUpdateTempMark(sceneId, newVal.pos[1], newVal.pos[2], newVal.pos[3], id, Const.MAP_MARK_CUSTOM, {
		markIconIndex = newVal.markIconIndex
	})
end

function ClientMapComponent:onCustomMapMarkMap_entryAdded(genId, value, sceneId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCustomMapMarkMap_entryAdded", genId, value, sceneId)
	end

	local map = pg.global.ui.map

	if not map then
		return
	end

	local id = tonumber(string.format("%s%s%s%s", sceneId, Const.MAP_MARK_CUSTOM, Const.MAP_MARK_CUSTOM, genId))
	local mapX, mapY = pg.game.map:convertPos(value.pos[1], value.pos[3], sceneId, true)

	if sceneId ~= pg.game.map:convertSceneId(pg.me.space.sceneId) then
		pg.game.map:addOrUpdateTempMark(sceneId, value.pos[1], value.pos[2], value.pos[3], id, Const.MAP_MARK_CUSTOM, {
			markIconIndex = value.markIconIndex
		}, map.tempMarkPointData)
		map.view.locationInfo:SetActive(false)
		map.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

		local data = map:getMarkInfo(id)

		map:scaleToCustomMarkStage(mapX, mapY)
		map:loadRes(id, data, function()
			map:selectMark(string.format("mark_%s_%s", Const.MAP_MARK_CUSTOM, id), true)
			pg.game.map:manualCalculateTempMarkNums(sceneId, Const.MAP_MARK_CUSTOM, true)
			map:refreshAllFilterList()
		end)

		return
	end

	pg.game.map:addOrUpdateTempMark(sceneId, value.pos[1], value.pos[2], value.pos[3], id, Const.MAP_MARK_CUSTOM, {
		markIconIndex = value.markIconIndex
	})
	map.view.locationInfo:SetActive(false)
	map.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

	local data = map:getMarkInfo(id)

	map:scaleToCustomMarkStage(mapX, mapY)
	map:loadRes(id, data, function()
		map:selectMark(string.format("mark_%s_%s", Const.MAP_MARK_CUSTOM, id), true)
		pg.game.map:manualCalculateTempMarkNums(sceneId, Const.MAP_MARK_CUSTOM, true)
		map:refreshAllFilterList()
	end)
end

function ClientMapComponent:onCustomMapMarkMap_entryDeleted(genId, value, sceneId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCustomMapMarkMap_entryDeleted", genId, value, sceneId)
	end

	local map = pg.global.ui.map
	local id = tonumber(string.format("%s%s%s%s", sceneId, Const.MAP_MARK_CUSTOM, Const.MAP_MARK_CUSTOM, genId))

	pg.game.map:removeTempMark(sceneId, id)
	map.view.locationInfo:SetActive(false)

	if sceneId ~= pg.game.map:convertSceneId(pg.me.space.sceneId) then
		map.tempMarkPointData[id] = nil

		map:removeSelectedBtn(id)
		map.customMarkerPool:recycleToPool(id)
		pg.game.navEffect:unPath(id)

		map.markCaches[id] = nil

		pg.game.map:manualCalculateTempMarkNums(sceneId, Const.MAP_MARK_CUSTOM, false)
		map:refreshAllFilterList()

		return
	end

	map:removeSelectedBtn(id)
	map.customMarkerPool:recycleToPool(id)
	pg.game.navEffect:unPath(id)

	map.markCaches[id] = nil

	pg.game.map:manualCalculateTempMarkNums(sceneId, Const.MAP_MARK_CUSTOM, false)
	map:refreshAllFilterList()
end

function ClientMapComponent:onCustomMapMarkMapName_valueChanged(oldVal, newVal, sceneId, genId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onCustomMapMarkMapName_valueChanged", oldVal, newVal, sceneId, genId)
	end
end

function ClientMapComponent:RPC_SC_OnPoiResult(markType, staticId, isSuccess)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_OnPoiResult", markType, staticId, isSuccess)
	end

	local staticIdInfo = pg.game.map:getMarkInfo(staticId)

	if staticIdInfo and staticIdInfo.POIOrNot and staticIdInfo.POIShowType then
		local msg = {
			state = 1,
			priority = staticIdInfo.POIPriority,
			uniqueId = staticId,
			args = {
				isSuccess = isSuccess,
				POIShowType = staticIdInfo.POIShowType,
				POIIcon = staticIdInfo.POIIcon,
				POIMusic = staticIdInfo.POIMusic,
				title = staticIdInfo.infoTitle,
				subTitle = staticIdInfo.POIDesc,
				sceneId = pg.game.map:convertSceneId(pg.me.space.sceneId),
				staticId = staticId
			}
		}

		pg.global.ui.tips:showPoi(msg)
	end
end

function ClientMapComponent:refreshMapFogByFlag(flag)
	self.mapFogContentDisplayFlag = flag

	if pg.global.ui:checkUIShow(UIConst.UI_ID_MAP) then
		pg.global.ui.map:displayMapFog(flag)
	end
end

function ClientMapComponent:RPC_SC_HideMapFogUI(flag)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_HideMapFogUI", flag)
	end

	self:refreshMapFogByFlag(flag)
end

function ClientMapComponent:RPC_SC_UnlockAllMapArea()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_UnlockAllMapArea")
	end

	for smallAreaId, _ in pairs(MapSmallAreaIdToIndex) do
		self:setAreaFirstInData(smallAreaId)
	end
end

function ClientMapComponent:onMapFogWholeUnlocked_valueChanged(oldVal, newVal, sceneId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("onMapFogWholeUnlocked_valueChanged", oldVal, newVal, sceneId)
	end

	self:refreshMapFogByFlag(not newVal)
end

function ClientMapComponent:tryTeleportToScene(sceneId, portalId, ignoreCheck)
	if not self.isMainPlayer then
		return
	end

	self:uploadMapFogToServer(true)
	pg.me:CallServerMsgTeleportToScene(sceneId, portalId or 0, ignoreCheck or false)
end

function ClientMapComponent:getSceneLastFloor(sceneId)
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "sceneLastFloor")

	return dict and dict[sceneId] or 1
end

function ClientMapComponent:setSceneLastFloor(sceneId, floor)
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "sceneLastFloor")

	dict = dict or {}
	dict[sceneId] = floor

	return self:setClientInfo(Const.CLIENT_KEY.MAP, "sceneLastFloor", dict)
end

function ClientMapComponent:getMapLayerData(sceneId)
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "mapLayerData")

	sceneId = pg.game.map:convertSceneId(sceneId)

	if not dict[sceneId] then
		dict[sceneId] = {
			sceneId,
			0,
			0,
			0,
			0
		}
	end

	return dict[sceneId]
end

function ClientMapComponent:setMapLayerData(valueTable)
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "mapLayerData")

	dict = dict or {}
	dict[valueTable[1]] = {}

	for k, v in pairs(valueTable) do
		dict[valueTable[1]][k] = v
	end

	return self:setClientInfo(Const.CLIENT_KEY.MAP, "mapLayerData", dict)
end

function ClientMapComponent:getMapLayerUnlockData()
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "mapLayerUnlockData")

	return dict
end

function ClientMapComponent:setMapLayerUnlockData(valueTable)
	local dict = self:getClientInfo(Const.CLIENT_KEY.MAP, "mapLayerUnlockData")

	dict = dict or {}

	if not dict[valueTable[1]] then
		dict[valueTable[1]] = {}
	end

	if not dict[valueTable[1]][valueTable[2]] then
		dict[valueTable[1]][valueTable[2]] = {}
	end

	if not dict[valueTable[1]][valueTable[2]][valueTable[3]] then
		dict[valueTable[1]][valueTable[2]][valueTable[3]] = {}
	end

	dict[valueTable[1]][valueTable[2]][valueTable[3]][valueTable[4]] = true

	local t1 = MapLevelConfigData[valueTable[1]]

	if t1 then
		local t2 = t1[valueTable[2]]

		if t2 then
			local t3 = t2[valueTable[3]]

			if t3 then
				local t4 = t3[valueTable[4]]

				if t4 and t4.syncUnlock then
					for _, layerArea in pairs(t4.syncUnlock) do
						dict[valueTable[1]][valueTable[2]][valueTable[3]][layerArea] = true
					end
				end
			end
		end
	end

	return self:setClientInfo(Const.CLIENT_KEY.MAP, "mapLayerUnlockData", dict)
end

function ClientMapComponent:RPC_SC_GetSpaceLineInfoRes(lineInfo)
	self.logger:debug("RPC_SC_GetSpaceLineInfoRes", inspect(lineInfo), self.space.sceneId, self:repr())
	facade:sendMsgToUI(MessageName.REQUEST_BRANCH_LINE_INFO, {
		info = lineInfo
	})
end

function ClientMapComponent:getAreaFirstInDataDict()
	return self:getClientInfo(Const.CLIENT_KEY.SMALL_AREA_FIRST_IN, "first_in")
end

function ClientMapComponent:getAreaFirstInData(smallAreaId)
	local dict = self:getClientInfo(Const.CLIENT_KEY.SMALL_AREA_FIRST_IN, "first_in")

	return dict[smallAreaId] ~= nil and dict[smallAreaId] or false
end

function ClientMapComponent:setAreaFirstInData(smallAreaId)
	local dict = self:getClientInfo(Const.CLIENT_KEY.SMALL_AREA_FIRST_IN, "first_in")

	dict = dict or {}

	if dict[smallAreaId] then
		return
	end

	dict[smallAreaId] = true

	return self:setClientInfo(Const.CLIENT_KEY.SMALL_AREA_FIRST_IN, "first_in", dict)
end

function ClientMapComponent:getFirstInAreaId(staticId, staticInfo)
	if not staticInfo or staticInfo.markConfigId ~= Const.MAP_MARK_LEYLINETREE_TRANSMIT and staticInfo.markConfigId ~= Const.MAP_MARK_LEYLINETREE_BASE or not staticInfo.largeAreaId or staticInfo.largeAreaId == 0 then
		return
	end

	if not Utils.checkTransmit(staticId) then
		return
	end

	return staticInfo.largeAreaId
end

function ClientMapComponent:repairAreaFirstInData()
	if not self.isMainPlayer or not self.mapMarkStatusMap or not self.space then
		return
	end

	local sceneId = self.space.sceneId
	local markIds = MapMarkLeylineTreeLargeAreaIndexData[sceneId]

	if not markIds or not next(markIds) then
		return
	end

	local dict = self:getAreaFirstInDataDict()
	local repairedAreaIds = {}
	local sceneMarks

	for staticId in pairs(markIds) do
		local markConfig = Utils.getMarkConfigByMarkId(staticId)

		if markConfig and markConfig.funcType ~= nil and self.mapMarkStatusMap:getStatus(sceneId, markConfig.funcType, staticId) >= Const.MAP_MARK_STATUS_UNLOCKED then
			sceneMarks = sceneMarks or SceneUtils.getSceneMarkPointData(sceneId)

			local areaId = self:getFirstInAreaId(staticId, sceneMarks and sceneMarks[staticId])

			if areaId and not dict[areaId] then
				dict[areaId] = true
				repairedAreaIds[#repairedAreaIds + 1] = areaId
			end
		end
	end

	if #repairedAreaIds == 0 then
		return
	end

	self:setClientInfo(Const.CLIENT_KEY.SMALL_AREA_FIRST_IN, "first_in", dict)
end

function ClientMapComponent:dealFirstInArea(staticId, oldVal, newVal)
	if oldVal >= Const.MAP_MARK_STATUS_UNLOCKED or newVal < Const.MAP_MARK_STATUS_UNLOCKED then
		return
	end

	local areaId = self:getFirstInAreaId(staticId, pg.game.map:getMarkInfo(staticId))

	if areaId then
		self:setAreaFirstInData(areaId)
	end
end

return ClientMapComponent
