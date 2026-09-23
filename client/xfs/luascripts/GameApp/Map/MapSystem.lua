-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Map\\MapSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local SceneData = require("Data.scene_data")
local SceneSeamlessData = require("Data.scene_seamless_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local MapLevelConfigData = require("Data.map_level_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local Lume = require("Core.Common.lume")
local MapUtils = require("Guis.Utils.MapUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local AiConst = require("Common.Const.AiConst")
local EventConst = require("Const.EventConst")
local QuestConst = require("Common.Const.QuestConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local NavMeshServiceUtils = require("Common.Utils.NavMeshServiceUtils")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local ClientRepo = require("Core.Client.ClientRepo")
local MapBlockConfigData = require("Data.map_block_config_data")
local SystemBase = require("GameApp.Core.SystemBase")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local MapFiltrateConfigData = require("Data.map_filtrate_config_data")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("MapSystem")
local SysConfigData = require("Data.sys_config_data")
local AreaNavTransitData = require("Data.area_nav_transit_data")
local TriggerConst = require("Common.Const.TriggerConst")
local HomeCampCarData = require("Data.home_camp_car_data")
local NoticeDef = require("Common.NoticeDef")
local HomelandConfigData = require("Data.homeland_config_data")
local MarkUnlockerComponent = require("GameApp.Map.Component.MarkUnlockerComponent")
local MapHelper = require("GameApp.Map.MapHelper")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local MapMarkStatusMap = require("CustomTypes.MapMarkStatusMap")
local ItemSourceData = require("Data.item_source_data")
local mapFogManager = CS.FunPlus.WorldX.GameApp.UIMap.MapFogManager
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local MapSystem = Class.LightClass("MapSystem", SystemBase)
local _mapMarkBindMessageInfo = {}
local _mapMarkUnbindMessageInfo = {}

MapSystem.FUNCTION_TYPE = {
	MISTY_AREA = 1
}
MapSystem.TRANSMIT_SEARCH_DISTANCE = 500
MapSystem.DIRECT_NAV_DISTANCE = 30

function MapSystem:onCtor()
	SystemBase.onCtor(self)

	function self.specialStateUpdateListener(staticId)
		self:onSpecialStateUpdate(staticId)
	end

	pg.global.eventEmitter:addEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.specialStateUpdateListener)
end

function MapSystem:EVENT_PostReload()
	MapMarkStatusMap.clearAllStatusCache()
end

function MapSystem:onInit()
	SystemBase.onInit(self)
	self:onClear()

	self.tempFogData = LuaCSharpArr.New(0, 0)
end

local _validSceneMap = {}
local _specialMarkMap = {
	[Const.MAP_MARK_ALLY] = true,
	[Const.MAP_MARK_QUEST] = true,
	[Const.MAP_MARK_CUSTOM] = true,
	[Const.MAP_MARK_SHARE] = true,
	[Const.MAP_MARK_ZONE] = true,
	[Const.MAP_MARK_TRACE] = true,
	[Const.MAP_MARK_CLUE] = true,
	[Const.MAP_MARK_GOLD_MONSTER] = true
}

function MapSystem:onClear()
	MapHelper.clearSceneDataCache()
	SceneUtils.clearCache()

	self.fogGeneratorRegistry = {}
	self.miniMapComponentMapReloadedFlag = nil
	self.cacheAllSceneMarkPointData = {}
	self.sceneMarkPointData = {}
	self.sceneMarkPointConfigCountData = {}
	self.sceneMarkPointChunkData = {}
	self.curBlockId = 0

	if pg.me then
		pg.me.curBlockId = 0
	end

	self.curPriorityBlockId = nil
	self.sceneId = nil
	self.mainSceneId = nil
	self.cacheSceneId = -1
	self.cacheSpaceId = -1
	self.cacheInLeaderWorld = nil
	self.blockInfo = {}
	self.curFunctionType = nil
	self.curFunctionTypeBlockInfo = {}
	self.tempMarkPointData = {}
	self.extraSharedInfoByMarkId = {}
	self.trackMarksRecord = {}
	self.trackMarksSceneIndex = {}
	self.trackStartMarks = {}
	self.trackPathStartByOwner = {}
	self._trackFilterDirty = nil

	if self._trackFilterDirtyTimer then
		self:killTimer(self._trackFilterDirtyTimer)

		self._trackFilterDirtyTimer = nil
	end

	self.curTraceMark = {}
	self.entityStaticIdInitRecord = {}
	self.puppetStaticIdInitRecord = {}
	self.enableFinishedType = {}
	self.disabledType = {}
	self.totalDisabledType = {}
	self.mapHudOnceTable = {}
	self.sceneMarkQuestPointData = {}
	self.sceneMarkQuestOverlapPoint = {}
	self._questAssocSpawner2Mark = nil
	self._questAssocSpawner2MarkDirty = true
	self.sceneMarkPointDataOverlap = {}
	self.bindMap = {}
	self.desiredCleanSmallArea = {}
	self.desiredWarningSmallArea = {}
	self.mapNodeDisplayStatus = {}

	for i, sceneId in ipairs(SysConfigData.CURRENT_VALID_SCENE) do
		_validSceneMap[sceneId] = true
	end

	self.teamMarkPointData = {}
	self.teamFixedMarkTrackMap = {}
	self.sceneBlocks = {}
	self.whiteListTempMarkIds = {}

	if self.markUnlocker then
		self.markUnlocker:destroy()

		self.markUnlocker = nil
	end
end

function MapSystem:onDestroy()
	if self.markUnlocker then
		self.markUnlocker:destroy()

		self.markUnlocker = nil
	end

	pg.global.eventEmitter:removeEventListener(EventConst.NPC_SPECIAL_STATE_UPDATE, self.specialStateUpdateListener)

	self.specialStateUpdateListener = nil

	if self.homelandTimer then
		self:killTimer(self.homelandTimer)

		self.homelandTimer = nil
	end

	if self.homeCampTimer then
		self:killTimer(self.homeCampTimer)

		self.homeCampTimer = nil
	end

	if self.homeCarTimer then
		self:killTimer(self.homeCarTimer)

		self.homeCarTimer = nil
	end

	if self.clueSeekArriveTimer then
		self:killTimer(self.clueSeekArriveTimer)

		self.clueSeekArriveTimer = nil
	end

	MapHelper.clearSceneDataCache()
end

function MapSystem:onSceneLoaded(sceneId, sceneName)
	self:ClearFriendTrack(sceneId)
	self:setSceneId(sceneId)
	pg.game.leylineTree:refreshRings()

	if pg.space:isHomeland() then
		self:dealWithHomelandSceneLoaded()
	end

	self:dealWithClueSeekTeleportTrace()

	if self.markUnlocker then
		self.markUnlocker:destroy()
	end

	self.markUnlocker = MarkUnlockerComponent.new()

	if self.curPriorityBlockId then
		pg.me:serverMsg("RPC_CS_SyncMapBlockId", pg.me.space.sceneId, self.curPriorityBlockId)
	end
end

function MapSystem:setSceneId(sceneId)
	if self.sceneId ~= sceneId then
		self.curBlockId = 0

		if pg.me then
			pg.me.curBlockId = 0
		end

		self.curPriorityBlockId = 0

		clientLevelUtils.notifyEcsWeather()
	end

	self.tempMarkPointData = {}

	for k, _ in ipairs(self.tempFogData) do
		self.tempFogData[k] = nil
	end

	self.chunkGroup = nil
	self.sceneId = sceneId
	self.mainSceneId = SceneUtils.getMainSceneId(sceneId)

	TriggerUtils.ClientOnSceneLoad(sceneId)
	self:_cacheBlockInfo(sceneId)
end

function MapSystem:ClearFriendTrack(sceneId)
	local player = pg.me

	if not player then
		return
	end

	local newInLeaderWorld = player.inLeaderWorld or false

	if self.cacheInLeaderWorld ~= newInLeaderWorld then
		self.cacheInLeaderWorld = newInLeaderWorld

		local mapMarkStatusMap = player:getSpaceOwnerMapMarkStatusMap() or player.mapMarkStatusMap

		if mapMarkStatusMap then
			local markIdList = {}

			for markId, markInfo in pairs(self.trackMarksRecord) do
				local status = mapMarkStatusMap:getStatus(sceneId, markInfo.markType, markId)

				if status >= Const.MAP_MARK_STATUS_LOCKED then
					markIdList[#markIdList + 1] = markId
				end
			end

			for i = 1, #markIdList do
				self:unStoreTrackMarks(markIdList[i])
			end
		end
	end
end

function MapSystem:onSceneUnloaded(sceneId, sceneName)
	self.entityStaticIdInitRecord = {}
	self.puppetStaticIdInitRecord = {}
	self.sceneId = nil
	self.mainSceneId = nil
end

function MapSystem:GetMiniMapUI()
	if pg.global.ui:checkUIOpen(UIConst.UI_DEATH_SPECTATE) then
		local spectateCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_DEATH_SPECTATE)
		local miniMap = spectateCtrl and spectateCtrl.minMapComponent and spectateCtrl.minMapComponent.miniMapComponent

		if miniMap then
			return miniMap
		end
	end

	local hudV2 = pg.global.ui.hudV2

	return hudV2 and hudV2.LU and hudV2.LU.minimapV2
end

function MapSystem:refreshAllyMarks()
	local minimap = self:GetMiniMapUI()

	if minimap and minimap.loadMovingTargetMark then
		minimap:loadMovingTargetMark()
	end
end

function MapSystem:getMessageBindMap()
	return {
		[MessageName.QUEST_ON_STATE_CHANGE] = "onQuestStateChanged",
		[MessageName.ON_PLAYER_POSITION_RESET] = "onPlayerPositionReset",
		[MessageName.DRAW_NAV_EFF_LINE] = "onDrawNavEffLine",
		[MessageName.QUEST_ON_CLUE_STATE_CHANGE] = "onClueQuestStateChanged"
	}
end

function MapSystem:onTick()
	self:flushTrackFilterDirty()

	if not self:checkValidScene(self.mainSceneId) then
		return
	end

	local curBlockId, curPriorityBlockId = self:queryCurBlockAreaId()

	if curBlockId and self.curBlockId ~= curBlockId then
		self:setCurBlockId(curBlockId)
		pg.me:tryClientTriggerAll(TriggerConst.TRIGGER_IN_TIME_WEATHER_BLOCK)
	end

	if curPriorityBlockId and self.curPriorityBlockId ~= curPriorityBlockId then
		self:setCurPriorityBlockId(curPriorityBlockId)
	end
end

function MapSystem:convertPos(x, yOrz, sceneId, toMap)
	sceneId = self:convertSceneId(sceneId)

	return MapHelper.convertPos(x, yOrz, sceneId, toMap)
end

function MapSystem:_cacheBlockInfo(inputSceneId)
	local mainSceneId = self:convertSceneId(inputSceneId)
	local spaceId = pg.space and pg.space.id

	if self.cacheSceneId == mainSceneId and self.cacheSpaceId == spaceId then
		return
	end

	self.cacheSceneId = mainSceneId
	self.cacheSpaceId = spaceId

	local sceneMarkPointData = MapHelper.combineAllSeamlessSceneData(mainSceneId, spaceId)

	self.sceneMarkPointData = sceneMarkPointData
	self.sceneMarkPointChunkData = self:generateChunkSceneMarkPointData(sceneMarkPointData)
	self.blockInfo = MapHelper.GetMainSceneBlockInfo(mainSceneId, spaceId)
end

function MapSystem:calculateMarkNumsByConfigId(sceneId, sceneMarkPointData, tempMarkPointData, mapMarkStatusMap)
	if not mapMarkStatusMap then
		return
	end

	local configs = {}

	self.sceneMarkPointConfigCountData[sceneId] = configs

	for markId, markTable in pairs(sceneMarkPointData) do
		if not configs[markTable.markConfigId] then
			configs[markTable.markConfigId] = {
				active = 0,
				total = 0
			}
		end

		configs[markTable.markConfigId].total = configs[markTable.markConfigId].total + 1

		if mapMarkStatusMap:getStatus(sceneId, markTable.markType, markId) >= Const.MAP_MARK_STATUS_UNLOCKED then
			configs[markTable.markConfigId].active = configs[markTable.markConfigId].active + 1
		end
	end

	for _, markTable in pairs(tempMarkPointData) do
		if not configs[markTable.markConfigId] then
			configs[markTable.markConfigId] = {
				total = 0
			}
		end

		configs[markTable.markConfigId].total = configs[markTable.markConfigId].total + 1
	end
end

function MapSystem:manualCalculateTempMarkNums(sceneId, markConfigId, isAdd)
	local configs = self.sceneMarkPointConfigCountData[sceneId]

	if isAdd then
		if not configs[markConfigId] then
			configs[markConfigId] = {
				total = 0
			}
		end

		configs[markConfigId].total = configs[markConfigId].total + 1
	else
		local config = configs[markConfigId]

		if config and config.total > 0 then
			config.total = config.total - 1

			if config.total <= 0 then
				configs[markConfigId] = nil
			end
		end
	end
end

function MapSystem:getBlockInfo(inputSceneId)
	if inputSceneId ~= self.cacheSceneId then
		self:_cacheBlockInfo(inputSceneId)
	end

	return self.blockInfo
end

local _empty = {}

function MapSystem:getBlockIds(inputSceneId)
	local mainSceneId = self:convertSceneId(inputSceneId)

	return MapHelper.GetMainSceneBlockIdList(mainSceneId)
end

function MapSystem:getCurBlockAreaId()
	return self.curBlockId, self.curPriorityBlockId
end

function MapSystem:queryCurBlockAreaId()
	if not pg.me or not pg.me.space then
		return
	end

	if not self:checkValidScene(self.mainSceneId) then
		return
	end

	local pos = pg.me:getPosition()

	if not pos or not pos.x or not pos.z then
		return
	end

	local blockList = MapHelper.GetMainSceneBlockList(self.mainSceneId)

	return MapHelper.queryMinPriorityBlock(self.mainSceneId, pos, blockList)
end

function MapSystem:getCurBlockAreaIds(blockList)
	table.clear(blockList)

	if not pg.me or not pg.me.space then
		return
	end

	if not self:checkValidScene(self.mainSceneId) then
		return
	end

	if not pg.me:getPosition() then
		return
	end

	return self:inWhichBlocks(self.mainSceneId, false, pg.me:getPosition(), blockList)
end

function MapSystem:inWhichBlock(inputSceneId, isMapPosition, positionTable, muteOffset)
	local mainSceneId = self:convertSceneId(inputSceneId)
	local blockList = MapHelper.GetMainSceneBlockList(mainSceneId)

	return MapHelper.inWhichBlock(inputSceneId, isMapPosition, positionTable, blockList, muteOffset)
end

function MapSystem:inWhichBlocks(inputSceneId, isMapPosition, positionTable, blockList)
	local mainSceneId = SceneUtils.getMainSceneId(inputSceneId)
	local blocks = MapHelper.GetMainSceneBlockList(mainSceneId)

	return MapHelper.inWhichBlocks(inputSceneId, isMapPosition, positionTable, blockList, blocks)
end

function MapSystem:getMaxPriorityMainAreaId(blockList)
	if not pg.me or not pg.me.space then
		return
	end

	if not self:checkValidScene(self.mainSceneId) then
		return
	end

	local tempT = self:getBlockInfo(self.sceneId)

	return MapHelper.getMaxPriorityMainAreaId(blockList, tempT, MapSmallAreaIdToIndex)
end

function MapSystem:findHighestNavMeshPoint(sceneId, x, z, callback)
	local tempPoint = Vector3(x, 0, z)

	NavMeshServiceUtils.findHighestNavMeshPoint(sceneId, tempPoint, function(aiConstReqState, highestPoint)
		if aiConstReqState == AiConst.AUTO_PATH_REQ_STATE.Success and callback then
			callback(highestPoint)
		else
			callback(tempPoint)
		end
	end)
end

function MapSystem:getDefaultMapPos(sceneId)
	return MapHelper.getDefaultMapPos(sceneId)
end

function MapSystem:getDefaultMapScaleRatio(sceneId)
	return MapHelper.getDefaultMapScaleRatio(sceneId)
end

function MapSystem:getSpawnerIdByMarkPointId(sceneId, markPointId)
	return MapHelper.getSpawnerIdByMarkPointId(sceneId, markPointId)
end

function MapSystem:getSandBoxIdBySpawnerId(sceneId, spawnerId)
	return MapHelper.getSandBoxIdBySpawnerId(sceneId, spawnerId)
end

function MapSystem:isPOIPopupBelongsToFightType(sceneId, markPointId)
	return MapHelper.isPOIPopupBelongsToFightType(sceneId, markPointId, self.puppetStaticIdInitRecord)
end

function MapSystem:getRewardTableByMarkPointId(sceneId, markPointId)
	return MapHelper.getRewardTableByMarkPointId(sceneId, markPointId)
end

function MapSystem:getLeylineTreePlentyInfo(sceneId, markPointId, createId)
	return MapHelper.getLeylineTreePlentyInfo(sceneId, markPointId, createId)
end

function MapSystem:calRadius(sceneId, radius)
	sceneId = self:convertSceneId(sceneId)

	return MapHelper.calRadius(sceneId, radius)
end

function MapSystem:addOrUpdateTempMark(sceneId, x, y, z, markId, markConfigId, extraParam, independentTable, forceUpdatemark)
	if not sceneId then
		return
	end

	local id = markId
	local defaultMapMarkSpecificData = DefaultMapMarkData[markConfigId]
	local pos = {
		x,
		y,
		z
	}

	if not x or not y or not z then
		pos = nil

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("mapSystem empty pos detected!", markId)
		end
	end

	local t = {
		addQuestTagId = 0,
		yaw = 0,
		randomRange = 0,
		mapAreaId = 0,
		hideToplogoMark = false,
		circleRadius = 0,
		arriveType = 1,
		type = defaultMapMarkSpecificData.showType,
		UsableState = defaultMapMarkSpecificData.UsableState,
		ShoworNot = defaultMapMarkSpecificData.ShoworNot,
		isPortal = defaultMapMarkSpecificData.isPortal,
		typeName = defaultMapMarkSpecificData.typeName,
		icon = defaultMapMarkSpecificData.icon,
		infoPage = defaultMapMarkSpecificData.infoPage,
		infoAvatar = defaultMapMarkSpecificData.infoAvatar,
		infoTitleNot = defaultMapMarkSpecificData.infoTitleNot,
		infoImageNot = defaultMapMarkSpecificData.infoImageNot,
		infoTextNot = defaultMapMarkSpecificData.infoTextNot,
		infoTitle = defaultMapMarkSpecificData.infoTitle,
		infoImage = defaultMapMarkSpecificData.infoImage,
		infoText = defaultMapMarkSpecificData.infoText,
		POIIcon = defaultMapMarkSpecificData.POIIcon,
		POIMusic = defaultMapMarkSpecificData.POIMusic,
		POIOrNot = defaultMapMarkSpecificData.POIOrNot,
		POIShowType = defaultMapMarkSpecificData.POIShowType,
		POIDesc = defaultMapMarkSpecificData.POIDesc,
		POIPriority = defaultMapMarkSpecificData.POIPriority,
		initState = defaultMapMarkSpecificData.initState,
		openMapState = defaultMapMarkSpecificData.openMapState,
		activeState = defaultMapMarkSpecificData.activeState,
		activeDistance = defaultMapMarkSpecificData.activeDistance,
		activeDisplayType = defaultMapMarkSpecificData.activeDisplayType,
		multiplayerPoiType = defaultMapMarkSpecificData.multiplayerPoiType,
		OnlyShowInMinimapResizeArea = defaultMapMarkSpecificData.OnlyShowInMinimapResizeArea,
		scale1 = defaultMapMarkSpecificData.scale1,
		scale2 = defaultMapMarkSpecificData.scale2,
		scale3 = defaultMapMarkSpecificData.scale3,
		scale4 = defaultMapMarkSpecificData.scale4,
		enableHudShow = defaultMapMarkSpecificData.enableHudShow,
		hudShow = defaultMapMarkSpecificData.hudShow,
		hudShowDistance = defaultMapMarkSpecificData.hudShowDistance,
		compassShowDistance = defaultMapMarkSpecificData.compassShowDistance,
		CompassShow = defaultMapMarkSpecificData.CompassShow,
		compassTxt = defaultMapMarkSpecificData.compassTxt,
		compassinactiveTxt = defaultMapMarkSpecificData.compassinactiveTxt,
		timeLimit = defaultMapMarkSpecificData.timeLimit,
		reward = defaultMapMarkSpecificData.reward,
		chest = defaultMapMarkSpecificData.chest,
		showOntrail = defaultMapMarkSpecificData.showOntrail,
		globalBubble = defaultMapMarkSpecificData.globalBubble,
		ClickorNot = defaultMapMarkSpecificData.ClickorNot,
		showInLevelDesigner = defaultMapMarkSpecificData.showInLevelDesigner,
		editorIcon = defaultMapMarkSpecificData.editorIcon,
		activeHigh = {
			0.5,
			-0.5
		},
		activeShapes = {},
		arriveParam = {},
		markConfigId = markConfigId,
		markPosition = pos,
		markType = defaultMapMarkSpecificData.funcType,
		realSceneId = sceneId,
		belongAreaId = self:pointInWhichArea(sceneId, pos)
	}

	if independentTable then
		independentTable[id] = t
	else
		self.tempMarkPointData[id] = t
	end

	self:_additionInsert(id, markConfigId, extraParam, independentTable)

	if markConfigId == Const.MAP_MARK_QUEST then
		self.sceneMarkQuestPointData[id] = t

		self:addSceneMarkQuestOverlap(t)

		self._questAssocSpawner2MarkDirty = true
	end

	if not independentTable or forceUpdatemark then
		pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
			type = "addOrUpdate",
			id = id
		})
	end

	return id
end

function MapSystem:removeTempMark(sceneId, id, independentTable)
	if independentTable then
		if independentTable[id] == nil then
			return
		end

		independentTable[id] = nil
	else
		if not id then
			return
		end

		if self.tempMarkPointData[id] == nil then
			return
		end

		pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
			type = "delete",
			id = id
		})
		self:manualUnTraceQuestMark(id)

		self.tempMarkPointData[id] = nil

		local removedQuestMark = self.sceneMarkQuestPointData[id]

		self.sceneMarkQuestPointData[id] = nil

		if removedQuestMark then
			self:removeSceneMarkQuestOverlap(removedQuestMark.questId, removedQuestMark.objId)

			self._questAssocSpawner2MarkDirty = true
		end
	end
end

function MapSystem:updateMovingTargetPosAndRot()
	if not self.tempMarkPointData then
		return
	end

	for entityId, markInfo in pairs(self.tempMarkPointData) do
		if markInfo.markType == Const.MAP_MARK_ALLY then
			local entPos = MapHelper.GetEntityPos(entityId)

			if entPos then
				markInfo.markPosition = entPos
			end
		end
	end
end

function MapSystem:_additionInsert(id, markConfigId, extraParam, independentTable)
	if markConfigId == Const.MAP_MARK_QUEST and extraParam then
		local cfg = QuestUtils.getQuestConfig(extraParam.arg2)
		local markData = independentTable and independentTable[id] or self.tempMarkPointData[id]

		markData.delegateIndex = extraParam.arg1
		markData.questId = extraParam.arg2
		markData.questState = extraParam.arg3
		markData.circleRadius = extraParam.arg5
		markData.sceneId = self:convertSceneId(extraParam.arg6)
		markData.objId = extraParam.arg7
		markData.type = Const.MAP_CONST.TYPE.QUEST
		markData.infoImage = "$UI_Img_Map_Preview_Storymissions.png"
		markData.infoText = cfg and cfg.desc or ""
		markData.delegateName = cfg and cfg.title or ""
		markData.questType = cfg and cfg.questType or QuestConst.QUEST_TYPE.SIDE
		markData.activeHigh = {
			0.5,
			-0.5
		}
		markData.questMarkInfo = QuestUtils.getQuestMarkInfo(extraParam.arg2, extraParam.arg7)
		markData.siblingIndex = QuestUtils.getQuestMarkPriority(markData.questType)
	elseif markConfigId == Const.MAP_MARK_CUSTOM and extraParam then
		local markData = independentTable and independentTable[id] or self.tempMarkPointData[id]

		markData.markIconIndex = extraParam.markIconIndex
	elseif markConfigId == Const.MAP_MARK_CLUE and extraParam then
		local cfg = QuestUtils.getQuestConfig(extraParam.arg2)
		local markData = independentTable and independentTable[id] or self.tempMarkPointData[id]

		markData.delegateIndex = extraParam.arg1
		markData.questId = extraParam.arg2
		markData.sceneId = self:convertSceneId(extraParam.arg6)
		markData.objId = extraParam.arg7
		markData.type = Const.MAP_CONST.TYPE.NORMAL
		markData.infoImage = "$UI_Img_Map_Preview_Storymissions.png"
		markData.infoText = cfg and cfg.desc or ""
		markData.delegateName = cfg and cfg.title or ""
		markData.questType = cfg and cfg.questType or QuestConst.QUEST_TYPE.CLUE
		markData.activeHigh = {
			0.5,
			-0.5
		}
		markData.questMarkInfo = QuestUtils.getQuestMarkInfo(extraParam.arg2, extraParam.arg7)
	end

	if extraParam then
		local markData = independentTable and independentTable[id] or self.tempMarkPointData[id]

		if extraParam.replaceIcon then
			markData.replaceIcon = extraParam.replaceIcon
		end

		if extraParam.infoTitle then
			markData.infoTitle = extraParam.infoTitle
		end

		if extraParam.infoText then
			markData.infoText = extraParam.infoText
		end

		if extraParam.infoImage then
			markData.infoImage = extraParam.infoImage
		end

		if extraParam.photoData then
			markData.photoData = extraParam.photoData
		end

		if extraParam.markIconIndex then
			markData.markIconIndex = extraParam.markIconIndex
		end

		if extraParam.creatorUid then
			markData.creatorUid = extraParam.creatorUid
		end

		if extraParam.trackUids then
			markData.trackUids = extraParam.trackUids
		end

		if extraParam.name then
			markData.name = extraParam.name
		end
	end
end

function MapSystem:manualTraceQuestMark(markType, questId, showPath)
	if not questId then
		return
	end

	facade:sendMsgToUI(MessageName.UI_MAP_SYSTEM_TRACE_QUEST_MARK, {
		markType = markType,
		questId = questId,
		showPath = showPath
	})

	local minimap = pg.game.map:GetMiniMapUI()

	if minimap then
		minimap:manualTrackMark(markType, questId, showPath)
	end
end

function MapSystem:manualUnTraceQuestMark(questId)
	if not questId then
		return
	end

	facade:sendMsgToUI(MessageName.UI_MAP_SYSTEM_UNTRACE_QUEST_MARK, {
		questId = questId
	})

	local minimap = pg.game.map:GetMiniMapUI()

	if minimap then
		minimap:deleteTrackMark(questId)
	end
end

function MapSystem:checkTrackMarkExists(questId)
	return self.trackMarksRecord[questId] ~= nil
end

function MapSystem:onQuestStateChanged(info)
	if QuestUtils.isQuestOfClueQuestType(info.questId) then
		return
	end

	if info.questId == Const.INTERACT_GESTURE_QUEST_ID and info.state == QuestConst.QUEST_STATE.COMPLETED and pg.global.ui.hudV2 then
		pg.global.ui.hudV2:refreshInteractGestureBtnState()
	end

	if info.state >= QuestConst.QUEST_STATE.COMPLETED then
		self:clearSpecialTrainGoToTrack(info.questId)
	end

	local config = QuestUtils.getQuestConfig(info.questId)

	if not config.objectivesIDs then
		return
	end

	for _, objId in pairs(config.objectivesIDs) do
		local combineId = QuestUtils.getCombinedId(info.questId, objId)

		if info.state == QuestConst.QUEST_STATE.COMPLETED then
			pg.game.navEffect:unPath(combineId)
		end

		if info.state > QuestConst.QUEST_STATE.COMPLETED then
			self:removeTempMark(nil, combineId)
		elseif self.tempMarkPointData[combineId] then
			self.tempMarkPointData[combineId].questState = info.state

			pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
				type = "addOrUpdate",
				id = combineId
			})
		end
	end
end

function MapSystem:clearSpecialTrainGoToTrack(questId)
	local specialTrainConfig = QuestUtils.getSpecialTrainConfig(questId)

	if not specialTrainConfig then
		return
	end

	self:clearClueSeekTrackByGoTo(specialTrainConfig.goTo)
	self:clearClueSeekTrackByGoTo(specialTrainConfig.preGoTo)
end

function MapSystem:clearClueSeekTrackByGoTo(goTo)
	if not goTo or goTo[1] ~= 1 or not goTo[2] then
		return
	end

	local sourceData = ItemSourceData[goTo[2]]

	if not sourceData then
		return
	end

	local markId

	if sourceData.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS and sourceData.buttonTxt then
		markId = math.abs(sourceData.buttonTxt)

		self:removeTempMark(nil, markId)
	elseif sourceData.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_MARK and sourceData.sourceMarkPoint then
		markId = sourceData.sourceMarkPoint[1]
	end

	if not markId then
		return
	end

	if self:checkTrackMarkExists(markId) then
		self:manualUnTraceQuestMark(markId)
	end

	if pg.game and pg.game.navEffect then
		pg.game.navEffect:unPath(markId)
	end
end

function MapSystem:onClueQuestStateChanged(info)
	if self.tempMarkPointData[info.questId] then
		pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
			type = "addOrUpdate",
			id = info.questId
		})
	end
end

function MapSystem:generateChunkSceneMarkPointData(sceneMarkPointData)
	if self.chunkGroup then
		return self.chunkGroup
	end

	self.chunkGroup = {}

	for markId, markSpawner in pairs(sceneMarkPointData) do
		if markSpawner.markPosition then
			local xKey, zKey = MapHelper.calXAndZKey(markSpawner.markPosition[1], markSpawner.markPosition[3], self:convertSceneId(markSpawner.realSceneId))

			if not self.chunkGroup[xKey] then
				self.chunkGroup[xKey] = {}
			end

			if not self.chunkGroup[xKey][zKey] then
				self.chunkGroup[xKey][zKey] = {}
			end

			self.chunkGroup[xKey][zKey][#self.chunkGroup[xKey][zKey] + 1] = markId
		end
	end

	return self.chunkGroup
end

function MapSystem:storeExtraSharedInfoToMarkId(markId, paramKey, paramValue)
	if not self.extraSharedInfoByMarkId[markId] then
		self.extraSharedInfoByMarkId[markId] = {}
	end

	self.extraSharedInfoByMarkId[markId][paramKey] = paramValue
end

function MapSystem:getChunkByMark(markData)
	local xKey, zKey = MapHelper.calXAndZKey(markData.markPosition[1], markData.markPosition[3], self.mainSceneId)
	local xChunk = self.sceneMarkPointChunkData[xKey]

	if not xChunk then
		return
	end

	return xChunk[zKey]
end

function MapSystem:getChunkByPos(markPosition)
	local xKey, zKey = MapHelper.calXAndZKey(markPosition[1], markPosition[3], self.mainSceneId)
	local xChunk = self.sceneMarkPointChunkData[xKey]

	if not xChunk then
		return
	end

	return xChunk[zKey]
end

function MapSystem:isSpecialMark(markType)
	return _specialMarkMap[markType]
end

function MapSystem:getMarkInfo(spawnerId)
	if self.sceneMarkPointData[spawnerId] then
		return self.sceneMarkPointData[spawnerId]
	elseif self.tempMarkPointData[spawnerId] then
		return self.tempMarkPointData[spawnerId]
	elseif self.teamMarkPointData[spawnerId] then
		return self.teamMarkPointData[spawnerId]
	end
end

function MapSystem:isMarkInCurMainScene(markData)
	if not markData then
		return true
	end

	local markSceneId = markData.sceneId or markData.realSceneId

	if not markSceneId then
		return true
	end

	return self:convertSceneId(markSceneId) == self.mainSceneId
end

function MapSystem:checkAtLeastOneTrackingMarkQuestExcept()
	for _, v in pairs(self.trackMarksRecord) do
		if v.markType ~= Const.MAP_MARK_QUEST then
			return true
		end
	end

	return false
end

function MapSystem:storeTrackMarks(spawnerId, sceneId, markType, pos, replaceIcon)
	for id, t in pairs(self.trackMarksRecord) do
		if t.sceneId == sceneId then
			self:unStoreTrackMarks(id)
		end
	end

	self.trackMarksRecord[spawnerId] = {
		sceneId = sceneId,
		markType = markType,
		pos = pos,
		replaceIcon = replaceIcon
	}

	if not self.trackMarksSceneIndex[sceneId] then
		self.trackMarksSceneIndex[sceneId] = {}
	end

	self.trackMarksSceneIndex[sceneId][spawnerId] = true
end

function MapSystem:unStoreTrackMarks(spawnerId)
	local isClueMark = self.trackMarksRecord[spawnerId] and self.trackMarksRecord[spawnerId].markType == Const.MAP_MARK_CLUE
	local sceneId = self.trackMarksRecord[spawnerId] and self.trackMarksRecord[spawnerId].sceneId or nil

	if sceneId and self.trackMarksSceneIndex[sceneId] then
		self.trackMarksSceneIndex[sceneId][spawnerId] = nil
	end

	self.trackMarksRecord[spawnerId] = nil

	self:setTrackPathStart(spawnerId, nil, sceneId)
	self:markTrackFilterDirty(sceneId, spawnerId)

	if isClueMark and spawnerId and QuestUtils.isQuestOfClueQuestType(spawnerId) then
		facade:SendMessageCommand(MessageName.QUEST_ON_CLUE_STATE_CHANGE, {
			questId = spawnerId
		})
	end
end

function MapSystem:unStoreAllSceneRelatedTrackMarks(sceneId)
	if not sceneId or not self.trackMarksSceneIndex[sceneId] then
		return
	end

	for spawnerId, _ in pairs(self.trackMarksSceneIndex[sceneId]) do
		self:unStoreTrackMarks(spawnerId)
	end

	self.trackMarksSceneIndex[sceneId] = nil
end

function MapSystem:addTraceTypeMark(spawnerId, cb)
	self.curTraceMark[spawnerId] = true

	if cb then
		cb()
	end
end

function MapSystem:removeTraceTypeMark(spawnerId, cb)
	if not self.curTraceMark[spawnerId] then
		return
	end

	self.curTraceMark[spawnerId] = nil

	if cb then
		cb()
	end
end

function MapSystem:removeAllTraceTypeMark()
	for spawnerId in pairs(self.curTraceMark) do
		self:markTrackFilterDirty(nil, spawnerId)
	end

	self.curTraceMark = {}
end

function MapSystem:getSceneMarkInfoByMarkId(sceneId, markId, spaceId)
	if not self.cacheAllSceneMarkPointData[sceneId] then
		self.cacheAllSceneMarkPointData[sceneId] = SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	end

	if not markId then
		return
	end

	return self.cacheAllSceneMarkPointData[sceneId][markId]
end

function MapSystem:getMarkInfoFromAllCacheData(markId)
	for _, sceneMarkPointData in pairs(self.cacheAllSceneMarkPointData) do
		if sceneMarkPointData[markId] then
			return sceneMarkPointData[markId]
		end
	end

	return nil
end

function MapSystem:getBitMask(blockIndex, sceneId)
	local width = 0
	local height = 0
	local ret = 0

	ret, width, height = mapFogManager.QueryBitMaskWidthAndHeight(sceneId, blockIndex, width, height)

	local tempFogData = self.tempFogData

	if ret == 1 then
		for i = 1, width * height + 2 do
			tempFogData[i] = 0
		end

		local access = tempFogData:GetCSharpAccess()

		ret = mapFogManager.GetBitMask(access, sceneId, blockIndex)

		tempFogData:DestroyCSharpAccess()

		if ret == 1 then
			return {
				fogLighter = tempFogData
			}
		end
	end

	return nil
end

function MapSystem:setBitMask(blockIndex, content, mapFogGenerator, sceneId)
	if content == nil or type(content.fogLighter) == "string" or content.fogLighter == nil then
		return
	end

	if #content.fogLighter <= 2 then
		return
	end

	if mapFogGenerator then
		local data = LuaCSharpArr.NewByTable(content.fogLighter)
		local access = data:GetCSharpAccess()

		mapFogManager.SetBitMask(mapFogGenerator, access, sceneId, blockIndex)
		data:DestroyCSharpAccess()
	end
end

function MapSystem:setBitMaskAll(contentTable, mapFogGenerator, sceneId)
	if contentTable == nil then
		return
	end

	mapFogManager.InitBitMask(mapFogGenerator, sceneId)

	for blockIndex, content in pairs(contentTable) do
		self:setBitMask(blockIndex, ClientRepo.protoCodec:decode(content), mapFogGenerator, sceneId)
	end
end

function MapSystem:getFogRegistryKey(sceneId)
	return MapHelper.getRootScene(self:convertSceneId(sceneId))
end

function MapSystem:registerFogGenerator(sceneId, generator)
	if generator == nil then
		return
	end

	local key = self:getFogRegistryKey(sceneId)
	local generators = self.fogGeneratorRegistry[key]

	if generators == nil then
		generators = {}
		self.fogGeneratorRegistry[key] = generators
	end

	generators[generator] = sceneId
	generator.localExploreEnabled = not Utils.isServerDrivenDungeonFog(key)
end

function MapSystem:unregisterFogGenerator(generator)
	if generator == nil then
		return
	end

	for key, generators in pairs(self.fogGeneratorRegistry) do
		if generators[generator] ~= nil then
			generators[generator] = nil

			if next(generators) == nil then
				self.fogGeneratorRegistry[key] = nil
			end
		end
	end
end

function MapSystem:applyServerFogPush(sceneId, contentTable)
	if contentTable == nil then
		return
	end

	local key = self:getFogRegistryKey(sceneId)
	local generators = self.fogGeneratorRegistry[key]

	if generators == nil then
		return
	end

	for generator, registeredSceneId in pairs(generators) do
		for blockIndex, content in pairs(contentTable) do
			self:setBitMask(blockIndex, ClientRepo.protoCodec:decode(content), generator, registeredSceneId)
		end
	end
end

local function calcDist(p1, p2)
	local dx = p1[1] - p2[1]
	local dy = p1[2] - p2[2]
	local dz = p1[3] - p2[3]

	return dx * dx + dy * dy + dz * dz
end

function MapSystem:generateBatchMarks(sceneMarkPointData)
	local t2, t1, t0 = {}, {}, {}
	local notInteractPoints = {}
	local playerPos = pg.me:getPosition()

	for markId, v in pairs(sceneMarkPointData) do
		local targetList

		if not v.ClickorNot or v.ClickorNot == 0 or v.markType == Const.MAP_MARK_ZONE or v.markType == Const.MAP_MARK_ALLY then
			if v.scale4 == 1 or v.scale3 == 1 or v.scale2 == 1 then
				targetList = t2
			elseif v.scale1 == 1 then
				targetList = t1
			else
				targetList = t0
			end
		else
			targetList = notInteractPoints
		end

		local d = calcDist(v.markPosition, playerPos)

		targetList[#targetList + 1] = {
			id = markId,
			dist = d
		}
	end

	local function sortByDist(t)
		table.sort(t, function(a, b)
			return a.dist < b.dist
		end)
	end

	sortByDist(t2)
	sortByDist(t1)
	sortByDist(t0)
	sortByDist(notInteractPoints)

	local function extractIdList(t)
		local r = {}

		for _, v in ipairs(t) do
			r[#r + 1] = v.id
		end

		return r
	end

	t2 = extractIdList(t2)
	t1 = extractIdList(t1)
	t0 = extractIdList(t0)
	notInteractPoints = extractIdList(notInteractPoints)

	LuaUIUtils.appendTable(t2, t1)
	LuaUIUtils.appendTable(t2, t0)

	return t2, notInteractPoints
end

function MapSystem:loadEnabledMarkTypes(sceneId)
	if not sceneId then
		return
	end

	self.enableFinishedType[sceneId] = pg.global.prefsCacheUtils:getBool("enabledFinishedMarkType" .. sceneId, false, ClientConst.CACHE_TYPE_FLAG.USER)
	self.disabledType[sceneId] = {}

	local result = pg.global.prefsCacheUtils:getString("disabledMarkType" .. sceneId, "empty", ClientConst.CACHE_TYPE_FLAG.USER)

	if not result or result == "empty" or result == "" then
		local defaultDisable = SceneData[sceneId].mapFiltrateNotTick

		if defaultDisable then
			for _, configId in pairs(defaultDisable) do
				local strConfigId = tostring(configId)

				self.disabledType[sceneId][strConfigId] = strConfigId
			end
		end

		return
	end

	local arr = string.split(result, ",")

	if not arr or #arr <= 0 then
		return
	end

	for i = 1, #arr do
		if not self.disabledType[sceneId][arr[i]] then
			self.disabledType[sceneId][arr[i]] = arr[i]
		end
	end
end

function MapSystem:checkDisabledTypeContains(sceneId)
	if not self.disabledType then
		return false
	end

	if not self.disabledType[sceneId] then
		return false
	end

	for typeStr, _ in pairs(self.disabledType[sceneId]) do
		if typeStr ~= "" and not LuaUIUtils.tableContains(SceneData[sceneId].mapFiltrateNotTick, tonumber(typeStr)) then
			return true
		end
	end

	return false
end

function MapSystem:resetDefaultDisabledType(sceneId)
	self.disabledType[sceneId] = {}

	local defaultDisable = SceneData[sceneId].mapFiltrateNotTick

	if defaultDisable then
		for _, configId in pairs(defaultDisable) do
			local strConfigId = tostring(configId)

			self.disabledType[sceneId][strConfigId] = strConfigId
		end
	end
end

function MapSystem:saveEnabledMarkTypes(sceneId)
	if not sceneId then
		return
	end

	if self.enableFinishedType[sceneId] == true then
		pg.global.prefsCacheUtils:setBool("enabledFinishedMarkType" .. sceneId, true, ClientConst.CACHE_TYPE_FLAG.USER)
	else
		pg.global.prefsCacheUtils:setBool("enabledFinishedMarkType" .. sceneId, false, ClientConst.CACHE_TYPE_FLAG.USER)
	end

	local s = ""

	if self.disabledType[sceneId] then
		for _, v in pairs(self.disabledType[sceneId]) do
			s = s .. v .. ","
		end
	end

	pg.global.prefsCacheUtils:setString("disabledMarkType" .. sceneId, s, ClientConst.CACHE_TYPE_FLAG.USER)
	pg.global.prefsCacheUtils:save()
end

function MapSystem:isSpawnerTracked(spawnerId)
	if not spawnerId then
		return false
	end

	if self.curTraceMark and self.curTraceMark[spawnerId] then
		return true
	end

	if self.trackMarksRecord and self.trackMarksRecord[spawnerId] then
		return true
	end

	local minimap = self:GetMiniMapUI()

	if minimap and minimap.checkTrackMarkExists and minimap:checkTrackMarkExists(spawnerId) then
		return true
	end

	return false
end

function MapSystem:isTrackPathStartSpawner(spawnerId)
	return spawnerId ~= nil and (self.trackStartMarks[spawnerId] or 0) > 0
end

function MapSystem:shouldForceVisibleMark(spawnerId)
	return self:isSpawnerTracked(spawnerId) or self:isTrackPathStartSpawner(spawnerId)
end

function MapSystem:setTrackPathStart(owner, startSpawnerId, sceneId)
	if not owner then
		return
	end

	local old = self.trackPathStartByOwner[owner]

	if old == startSpawnerId then
		return
	end

	if old then
		local rest = (self.trackStartMarks[old] or 1) - 1

		self.trackStartMarks[old] = rest > 0 and rest or nil

		self:markTrackFilterDirty(sceneId, old)
	end

	self.trackPathStartByOwner[owner] = startSpawnerId

	if startSpawnerId then
		self.trackStartMarks[startSpawnerId] = (self.trackStartMarks[startSpawnerId] or 0) + 1

		self:markTrackFilterDirty(sceneId, startSpawnerId)
	end
end

function MapSystem:markTrackFilterDirty(sceneId, spawnerId)
	local dirty = self._trackFilterDirty

	if not dirty then
		dirty = {
			ids = {}
		}
		self._trackFilterDirty = dirty
		self._trackFilterDirtyTimer = self:startTimer(function()
			self._trackFilterDirtyTimer = nil

			self:flushTrackFilterDirty()
		end, 0)
	end

	dirty.sceneId = sceneId or dirty.sceneId

	if spawnerId then
		dirty.ids[spawnerId] = true
	end
end

function MapSystem:flushTrackFilterDirty()
	local dirty = self._trackFilterDirty

	if not dirty then
		return
	end

	self._trackFilterDirty = nil

	if self._trackFilterDirtyTimer then
		self:killTimer(self._trackFilterDirtyTimer)

		self._trackFilterDirtyTimer = nil
	end

	self:refreshMapFilterOnTrackChange(dirty.sceneId, dirty.ids)
end

function MapSystem:refreshMapFilterOnTrackChange(sceneId, spawnerIds)
	sceneId = sceneId or self.mainSceneId

	if not sceneId then
		return
	end

	local minimap = self:GetMiniMapUI()

	if minimap and minimap.updateMapFilter then
		minimap:updateMapFilter(sceneId)
	end

	local mapCtrl = pg.global.ui.map

	if not mapCtrl then
		return
	end

	if mapCtrl.mapMarkFilterComponent and mapCtrl.sceneId == sceneId then
		mapCtrl.mapMarkFilterComponent:doFilter()
	end

	if not spawnerIds then
		return
	end

	if type(spawnerIds) ~= "table" then
		spawnerIds = {
			[spawnerIds] = true
		}
	end

	for id in pairs(spawnerIds) do
		mapCtrl:refreshMarkVisibility(id)
	end
end

function MapSystem:isEnabledByFilter(sceneId, markConfigId, markStatus, markId, extraInfo)
	if markId and self:shouldForceVisibleMark(markId) then
		return true
	end

	if not self.disabledType then
		return true
	end

	if not self.disabledType[sceneId] then
		return true
	end

	if self.disabledType[sceneId][tostring(markConfigId)] then
		return false
	end

	local finishStateAlwaysShow = extraInfo and extraInfo.finishStateAlwaysShow or nil

	if markStatus and markStatus >= Const.MAP_MARK_STATUS_CLOSED and not finishStateAlwaysShow then
		return self.enableFinishedType[sceneId]
	else
		return true
	end
end

function MapSystem:loadTotalEnabledMarkTypes(sceneId)
	if not sceneId then
		return
	end

	self.totalDisabledType[sceneId] = {}

	local result = pg.global.prefsCacheUtils:getString("totalDisabledType" .. sceneId, "empty", ClientConst.CACHE_TYPE_FLAG.USER)

	if not result or result == "empty" or result == "" then
		return
	end

	local arr = string.split(result, ",")

	if not arr or #arr <= 0 then
		return
	end

	for i = 1, #arr do
		if arr[i] ~= "" and not self.totalDisabledType[sceneId][tonumber(arr[i])] then
			self.totalDisabledType[sceneId][tonumber(arr[i])] = tonumber(arr[i])
		end
	end
end

function MapSystem:saveTotalEnabledMarkTypes(sceneId)
	if not sceneId then
		return
	end

	local s = ""

	if self.totalDisabledType[sceneId] then
		for _, v in pairs(self.totalDisabledType[sceneId]) do
			s = s .. v .. ","
		end
	end

	pg.global.prefsCacheUtils:setString("totalDisabledType" .. sceneId, s, ClientConst.CACHE_TYPE_FLAG.USER)
	pg.global.prefsCacheUtils:save()
end

function MapSystem:isEnabledByTotalFilter(sceneId, markConfigId)
	if self.totalDisabledType[sceneId] then
		for _, filterId in pairs(self.totalDisabledType[sceneId]) do
			if LuaUIUtils.tableContains(MapFiltrateConfigData[filterId].categories, markConfigId) then
				return false
			end
		end
	end

	return true
end

function MapSystem:getLeylineTreeIdByMarkId(markId)
	return MapHelper.getLeylineTreeIdByMarkId(markId)
end

function MapSystem:getMarkPriorityByConfigId(markConfigId)
	return MapHelper.getMarkPriorityByConfigId(markConfigId)
end

function MapSystem:getMarkTraceTypeByConfigId(markConfigId)
	return MapHelper.getMarkTraceTypeByConfigId(markConfigId)
end

function MapSystem:openMapAndLocateTempMark(sceneId, x, y, z, markPointType, id, cb, showPath, extraParam, respectTrackRule)
	pg.global.ui:closeAllNormalPanel()

	local markType = markPointType or Const.MAP_MARK_COUSTOM_TRACE
	local replaceIcon = MapUtils.getMarkDefaultResIcon(markType)

	extraParam = extraParam or {}
	extraParam.replaceIcon = extraParam.replaceIcon or replaceIcon

	local isCurrentScene = self:convertSceneId(sceneId) == self.mainSceneId

	if isCurrentScene then
		self:addOrUpdateTempMark(sceneId, x, y, z, id, markType, extraParam)
		self:manualTraceQuestMark(markType, id, showPath)
	else
		self.diffSceneTempMarkData = {}

		self:addOrUpdateTempMark(sceneId, x, y, z, id, markType, extraParam, self.diffSceneTempMarkData)
		self:storeTrackMarks(id, sceneId, markType, self.diffSceneTempMarkData[id].markPosition, replaceIcon)
	end

	if extraParam.navPath then
		local targetPos = Vector3(x, y, z)

		pg.game.navEffect:path(sceneId, targetPos, id)
	end

	if respectTrackRule and isCurrentScene and showPath and not extraParam.dontOpenMap then
		self:_checkTrackRuleDirect(id, function(direct)
			if direct then
				if cb then
					cb()
				end
			else
				self:_openTempMarkOnBigMap(sceneId, id, cb, markType)
			end
		end)

		return
	end

	if not extraParam.dontOpenMap then
		self:_openTempMarkOnBigMap(sceneId, id, cb, markType)
	elseif cb then
		cb()
	end
end

function MapSystem:_openTempMarkOnBigMap(sceneId, id, cb, markType)
	markType = markType or Const.MAP_MARK_COUSTOM_TRACE

	local defaultData = DefaultMapMarkData[markType]
	local funcType = defaultData and defaultData.funcType or markType

	pg.global.ui:open(UIConst.UI_ID_MAP, {
		forceSceneId = sceneId
	}, function()
		pg.global.ui.map:focusMark({
			string.format("mark_%s_%s", funcType, id),
			nil,
			true,
			function()
				if cb then
					cb()
				end

				local mapView = pg.global.ui.map.view

				if not mapView then
					return
				end

				local objectReference = mapView.locationInfo:GetComponent("ObjectReference")
				local locationTrackBtn = objectReference:GetRefValue("locationTrackBtn")
				local pinTrackBtn = objectReference:GetRefValue("pinTrackBtn")

				if locationTrackBtn then
					locationTrackBtn.luaClick()
				end

				if pinTrackBtn then
					locationTrackBtn.luaClick()
				end
			end
		})
	end)
end

function MapSystem:_checkTrackRuleDirect(spawnerId, onDecision)
	local markInfo = pg.game.map:getMarkInfo(spawnerId)

	if not markInfo or not markInfo.markPosition then
		onDecision(false)

		return
	end

	local pos = markInfo.markPosition
	local entPos = pg.game.map:GetCurrentBindMapMarkPosOriginal(spawnerId)

	if entPos then
		pos = entPos
	end

	local isDiffArea, isolatedIslandLinkPos, oriEndPos, isolatedIslandLinkPosAlter = self:calDestinationPosition(pos)

	self:compareDistanceAtPlayerPos(isDiffArea, oriEndPos, isolatedIslandLinkPos, markInfo.realSceneId, function(ret)
		onDecision(ret.directToTarget == true)
	end, isolatedIslandLinkPosAlter)
end

function MapSystem:openMapAndLocateMark(sceneId, markType, markId, trace, stage, cb, showPath, respectTrackRule)
	pg.global.ui:closeAllNormalPanel()
	self:addTempMarkToWhiteList(markId, sceneId, markType)

	if sceneId == self.sceneId then
		if trace then
			self:manualTraceQuestMark(markType, markId, showPath)
		end
	elseif markType ~= Const.MAP_MARK_QUEST then
		local markInfo = SceneUtils.getSceneMarkPointData(sceneId)[markId]
		local pos = markInfo and markInfo.markPosition or nil
		local replaceIcon = markInfo and markInfo.replaceIcon or nil

		self:storeTrackMarks(markId, sceneId, markType, pos, replaceIcon)
	end

	if respectTrackRule and sceneId == self.sceneId and trace and showPath then
		self:_checkTrackRuleDirect(markId, function(direct)
			if direct then
				if cb then
					cb()
				end
			else
				self:_openMarkOnBigMap(sceneId, markType, markId, trace, stage, cb)
			end
		end)

		return
	end

	self:_openMarkOnBigMap(sceneId, markType, markId, trace, stage, cb)
end

function MapSystem:_openMarkOnBigMap(sceneId, markType, markId, trace, stage, cb)
	pg.global.ui:open(UIConst.UI_ID_MAP, {
		forceSceneId = sceneId
	}, function()
		pg.global.ui.map:focusMark({
			string.format("mark_%s_%s", markType, markId),
			stage,
			true,
			function()
				if cb then
					cb()
				end

				if not trace then
					return
				end

				local mapView = pg.global.ui.map.view

				if not mapView then
					return
				end

				local objectReference = mapView.locationInfo:GetComponent("ObjectReference")
				local locationTrackBtn = objectReference:GetRefValue("locationTrackBtn")
				local pinTrackBtn = objectReference:GetRefValue("pinTrackBtn")

				if locationTrackBtn then
					locationTrackBtn.luaClick()
				end

				if pinTrackBtn then
					locationTrackBtn.luaClick()
				end
			end
		})
	end)
end

function MapSystem:openMapWithFilter(tempFilter)
	pg.global.ui:open(UIConst.UI_ID_MAP, {
		forceSceneId = tempFilter.sceneId,
		tempFilter = tempFilter
	}, function()
		pg.global.ui.map:showFilter(false)
		pg.global.ui.map:scaleFromOutside(tempFilter.stage)
	end)
end

function MapSystem:setMapLayerData(layerId, layerLevel, layerArea, areaId)
	if layerId == 0 then
		areaId = 0
	end

	local mapLayerData = {
		self:convertSceneId(pg.space.sceneId),
		layerId,
		layerLevel,
		layerArea,
		areaId
	}

	pg.me:setMapLayerData(mapLayerData)
	pg.me:setMapLayerUnlockData(mapLayerData)
end

function MapSystem:getMapLayerData(sceneId)
	return pg.me:getMapLayerData(sceneId)
end

function MapSystem:getLayerAreaIndexes(sceneId, layerId, layerLevel, fallbackArea)
	local t = {}

	if layerId == 0 then
		return t
	end

	local sceneCfg = MapLevelConfigData[sceneId]
	local layerCfg = sceneCfg and sceneCfg[layerId]
	local areaData = layerCfg and layerCfg[layerLevel]

	if not areaData then
		t[#t + 1] = fallbackArea or 0

		return t
	end

	local unlockData = pg.me:getMapLayerUnlockData()

	for k, _ in pairs(areaData) do
		if unlockData[sceneId] and unlockData[sceneId][layerId] and unlockData[sceneId][layerId][layerLevel] and unlockData[sceneId][layerId][layerLevel][k] then
			t[#t + 1] = k
		end
	end

	return t
end

function MapSystem:convertSceneId(sceneId)
	return SceneUtils.getMainSceneId(sceneId)
end

function MapSystem:pointInWhichArea(sceneId, markPos, spaceId)
	sceneId = self:convertSceneId(sceneId)

	return MapHelper.pointInWhichArea(sceneId, markPos, spaceId)
end

function MapSystem:onPlayerPositionReset(info)
	if not pg.me or not pg.space then
		return
	end

	local sceneId = pg.space.sceneId
	local areaId, mapLayerEvent = self:pointInWhichArea(sceneId, pg.me:getPosition(), pg.space.id)

	if not mapLayerEvent then
		areaId = 0
		mapLayerEvent = {
			"changeMapLayerData",
			{
				0,
				0,
				0
			}
		}
	end

	pg.me:doEventByData(mapLayerEvent, {
		areaId = areaId
	})
end

function MapSystem:checkShowSceneAreaPoiTip(blockId)
	if not self.sceneId then
		return false
	end

	local sceneData = SceneData[self.sceneId]

	if sceneData.hideSceneBlockPoiTip then
		return false
	end

	return true
end

function MapSystem:setCurBlockId(blockId)
	self.curBlockId = blockId
	pg.me.curBlockId = blockId

	pg.me:serverMsg("RPC_CS_SyncMapFormalBlockId", self.sceneId, self.curBlockId)
	clientLevelUtils.notifyEcsWeather()

	if not self:checkShowSceneAreaPoiTip(blockId) then
		return
	end

	pg.global.gameMgr:UpdateAreaId(self.curBlockId)
	csSDKManager.SetTrackingServiceInfo({
		area_id = tostring(self.curBlockId),
		game_version = tostring(ClientFullVersion or "")
	})

	if pg.me and MapBlockConfigData[blockId].POIOrNot == 1 then
		local minLv, maxLv = MapHelper.getAreaRecommandLevel(blockId)
		local msg = {
			state = 1,
			isFirst = not Utils.isRobEggSceneId(self.sceneId) and not pg.me:getAreaFirstInData(blockId),
			priority = 9999 - MapBlockConfigData[blockId].priority,
			uniqueId = blockId,
			minLv = minLv,
			maxLv = maxLv,
			args = {
				POIShowType = {
					3,
					1
				},
				POIIcon = MapBlockConfigData[blockId].poiIcon,
				title = MapBlockConfigData[blockId].areaName,
				subTitle = MapBlockConfigData[blockId].extraDescription,
				warningColor = MapBlockConfigData[blockId].warningColor
			}
		}

		pg.global.ui.tips:showPoiArea(msg)
	end
end

function MapSystem:setCurPriorityBlockId(blockId)
	self.curPriorityBlockId = blockId

	pg.me:serverMsg("RPC_CS_SyncMapBlockId", self.sceneId, self.curPriorityBlockId)
end

function MapSystem:getCurLargeBlockId()
	if not self.curBlockId then
		return nil
	end

	if not MapBlockConfigData[self.curBlockId] then
		return nil
	end

	return MapBlockConfigData[self.curBlockId].mapAreaId
end

function MapSystem:redDot_GetMapState()
	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.MAP) or not CommonSwitch[Const.FUNCTION_NAME.MAP] then
		return RedDotConst.RedDotStyle.NONE
	end

	if not Utils.isSceneWorld() then
		return RedDotConst.RedDotStyle.NONE
	end

	if Lume.getMapLen(self:getPetAreaRewardsState()) > 0 then
		return RedDotConst.RedDotStyle.REWARD
	end

	if pg.game.leylineTree:getLeylineTreeTotalRewardState() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function MapSystem:redDot_GetMapAreaState()
	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.MAP) or not CommonSwitch[Const.FUNCTION_NAME.MAP] then
		return RedDotConst.RedDotStyle.NONE
	end

	if not Utils.isSceneWorld() then
		return RedDotConst.RedDotStyle.NONE
	end

	if Lume.getMapLen(self:getPetAreaRewardsState()) > 0 then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function MapSystem:getPetAreaRewardsState()
	local res = {}

	for smallAreaId, _ in pairs(MapSmallAreaIdToIndex) do
		local redDot1, redDot2, redDot3 = self:getPetAreaRewardStateById(smallAreaId)

		if redDot1 or redDot2 or redDot3 then
			res[#res + 1] = {
				smallAreaId = smallAreaId,
				rewardState = {
					redDot1,
					redDot2,
					redDot3
				}
			}
		end
	end

	table.sort(res, function(a, b)
		return a.smallAreaId < b.smallAreaId
	end)

	return res
end

function MapSystem:isPetAreaRewardUnlocked(smallAreaId)
	if not MapSmallAreaIdToIndex[smallAreaId] then
		return false
	end

	local smallAreaCfg = MapBlockConfigData[smallAreaId]

	if not smallAreaCfg or not smallAreaCfg.mapAreaId then
		return false
	end

	return self:checkBlockLeylineTreeUnlocked(smallAreaCfg.mapAreaId) and pg.me:getAreaFirstInData(smallAreaId)
end

function MapSystem:getPetAreaRewardStateById(smallAreaId)
	if not self:isPetAreaRewardUnlocked(smallAreaId) then
		return false, false, false
	end

	local smallAreaCfg = MapBlockConfigData[smallAreaId]
	local serverUnlockInfo = pg.me.badgeUnlockInfoMap
	local hasGet1 = false
	local hasGet2 = false
	local hasGet3 = false
	local badgeId1 = smallAreaCfg.badge1
	local badgeId2 = smallAreaCfg.badge2
	local badgeId3 = smallAreaCfg.badge3
	local canGet1 = serverUnlockInfo[badgeId1] ~= nil
	local canGet2 = serverUnlockInfo[badgeId2] ~= nil
	local canGet3 = serverUnlockInfo[badgeId3] ~= nil

	if pg.me.blockCatchRewardStatus and pg.me.blockCatchRewardStatus[smallAreaId] then
		hasGet1 = pg.me.blockCatchRewardStatus[smallAreaId][1]
		hasGet2 = pg.me.blockCatchRewardStatus[smallAreaId][2]
		hasGet3 = pg.me.blockCatchRewardStatus[smallAreaId][3]
	end

	local redDot1 = not hasGet1 and canGet1
	local redDot2 = not hasGet2 and canGet2
	local redDot3 = not hasGet3 and canGet3

	return redDot1, redDot2, redDot3
end

function MapSystem:checkBlockLeylineTreeUnlocked(areaId)
	return MapHelper.checkBlockLeylineTreeUnlocked(areaId, pg.me.leylineTreeInfoMap)
end

function MapSystem:checkValidScene(sceneId)
	return sceneId and _validSceneMap[sceneId]
end

function MapSystem:isCurrentSceneValid()
	return self:checkValidScene(self.sceneId)
end

function MapSystem:getNPCSpecialState(staticId)
	return MapHelper.getNPCSpecialState(staticId, pg.me and pg.me.specialContentDict)
end

function MapSystem:onSpecialStateUpdate(staticId)
	facade:sendMsgToUI(MessageName.UI_MAP_SYSTEM_ON_SPECIAL_STATE_UPDATE, {
		staticId = staticId
	})

	local miniMap = self:GetMiniMapUI()

	if miniMap and miniMap.refreshNPCIconBySpecialState then
		miniMap:refreshNPCIconBySpecialState(staticId)
	end
end

function MapSystem:getSceneName(sceneId)
	return MapHelper.getSceneName(sceneId)
end

function MapSystem:getMarkStatus(spawnerId, markType, sceneId)
	return MapHelper.getMarkStatus(spawnerId, markType, sceneId)
end

function MapSystem:compareDistanceAtPlayerPos(isDiffArea, oriEndPos, isolatedIslandLinkPos, destinationRealSceneId, cb, isolatedIslandLinkPosAlter)
	local realSceneId = pg.me.space.sceneId
	local ret = {}
	local playerPos = Vector3(0, 0, 0)

	playerPos:Copy(pg.me:getPosition())

	local aroundTeleportMarkIds = {}

	self:getSceneMarkInfoByMarkId(destinationRealSceneId)

	local playerToDestinationDist = math.maxInt
	local mainSceneId = self:convertSceneId(destinationRealSceneId)
	local infos = MapHelper.combineAllSeamlessSceneData(mainSceneId)
	local baseOffX, baseOffZ = MapHelper.GetSceneOffset(mainSceneId)

	for markId, markInfo in pairs(infos) do
		if (markInfo.infoPage == 2 or DefaultMapMarkData[markInfo.markConfigId].infoPage == 2) and markInfo.ShoworNot == 1 and self:getMarkStatus(markId, markInfo.markType, self:convertSceneId(markInfo.realSceneId)) > Const.MAP_MARK_STATUS_LOCKED then
			local candOffX, candOffZ = MapHelper.GetSceneOffset(self:convertSceneId(markInfo.realSceneId))
			local normX = markInfo.markPosition[1] + candOffX - baseOffX
			local normZ = markInfo.markPosition[3] + candOffZ - baseOffZ
			local dist = Vector3.Distance(oriEndPos, {
				normX,
				markInfo.markPosition[2],
				normZ
			})

			if dist <= MapSystem.TRANSMIT_SEARCH_DISTANCE then
				aroundTeleportMarkIds[#aroundTeleportMarkIds + 1] = {
					markId = markId,
					markInfo = markInfo
				}
			end
		end
	end

	local function repeatCall()
		local first = MapHelper.popFirstElement(aroundTeleportMarkIds)

		if first then
			local startPos = {
				first.markInfo.markPosition[1],
				first.markInfo.markPosition[2],
				first.markInfo.markPosition[3]
			}
			local sceneId = self:convertSceneId(first.markInfo.realSceneId)

			NavMeshServiceUtils.findPath(sceneId, startPos, {
				{
					oriEndPos[1],
					oriEndPos[2],
					oriEndPos[3]
				}
			}, function(aiConstReqState, path)
				if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState) and path then
					NavMeshServiceUtils.findPath(sceneId, playerPos, {
						{
							startPos[1],
							startPos[2],
							startPos[3]
						}
					}, function(aiConstReqState1, path1)
						local toTeleportRealDist = self:calPathDistance(path1)

						if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState1) and path1 and toTeleportRealDist < MapSystem.DIRECT_NAV_DISTANCE then
							ret.startPos = {
								playerPos[1],
								playerPos[2],
								playerPos[3]
							}
							ret.endPos = {
								oriEndPos[1],
								oriEndPos[2],
								oriEndPos[3]
							}

							if cb then
								cb(ret)
							end
						elseif playerToDestinationDist < self:calPathDistance(path) then
							repeatCall()
						else
							ret.startPos = startPos
							ret.endPos = {
								oriEndPos[1],
								oriEndPos[2],
								oriEndPos[3]
							}
							ret.startSpawnerId = first.markId
							ret.startSpawnerType = first.markInfo.markType

							if cb then
								cb(ret)
							end
						end
					end)
				else
					repeatCall()
				end
			end)
		else
			ret.startPos = {
				playerPos[1],
				playerPos[2],
				playerPos[3]
			}

			if not isDiffArea then
				ret.endPos = {
					oriEndPos[1],
					oriEndPos[2],
					oriEndPos[3]
				}
			else
				ret.endPos = {
					isolatedIslandLinkPos[1],
					isolatedIslandLinkPos[2],
					isolatedIslandLinkPos[3]
				}
			end

			if cb then
				cb(ret)
			end
		end
	end

	local function mainCall()
		NavMeshServiceUtils.findPath(self:convertSceneId(realSceneId), playerPos, {
			{
				oriEndPos[1],
				oriEndPos[2],
				oriEndPos[3]
			}
		}, function(aiConstReqState, path)
			if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState) and path and not isDiffArea and self:calPathDistance(path) < MapSystem.DIRECT_NAV_DISTANCE then
				ret.startPos = {
					playerPos[1],
					playerPos[2],
					playerPos[3]
				}
				ret.endPos = {
					oriEndPos[1],
					oriEndPos[2],
					oriEndPos[3]
				}
				ret.directToTarget = true

				if cb then
					cb(ret)
				end
			elseif not next(aroundTeleportMarkIds) then
				ret.startPos = {
					playerPos[1],
					playerPos[2],
					playerPos[3]
				}

				if not isDiffArea then
					ret.endPos = {
						oriEndPos[1],
						oriEndPos[2],
						oriEndPos[3]
					}
				else
					ret.endPos = {
						isolatedIslandLinkPos[1],
						isolatedIslandLinkPos[2],
						isolatedIslandLinkPos[3]
					}
				end

				if cb then
					cb(ret)
				end
			else
				local callCount = 0

				for i = 1, #aroundTeleportMarkIds do
					NavMeshServiceUtils.findPath(self:convertSceneId(destinationRealSceneId), {
						aroundTeleportMarkIds[i].markInfo.markPosition[1],
						aroundTeleportMarkIds[i].markInfo.markPosition[2],
						aroundTeleportMarkIds[i].markInfo.markPosition[3]
					}, {
						{
							oriEndPos[1],
							oriEndPos[2],
							oriEndPos[3]
						}
					}, function(aiConstReqState1, path1)
						if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState1) and path1 then
							aroundTeleportMarkIds[i].realDist = self:calPathDistance(path1)
						else
							aroundTeleportMarkIds[i].realDist = math.maxInt
						end

						callCount = callCount + 1

						if callCount >= #aroundTeleportMarkIds then
							table.sort(aroundTeleportMarkIds, function(a, b)
								return a.realDist < b.realDist
							end)

							if isDiffArea then
								NavMeshServiceUtils.findPath(self:convertSceneId(realSceneId), playerPos, {
									{
										isolatedIslandLinkPos[1],
										isolatedIslandLinkPos[2],
										isolatedIslandLinkPos[3]
									}
								}, function(aiConstReqState2, path2)
									if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState2) and path2 then
										playerToDestinationDist = self:calPathDistance(path2)

										NavMeshServiceUtils.findPath(self:convertSceneId(destinationRealSceneId), {
											isolatedIslandLinkPosAlter[1],
											isolatedIslandLinkPosAlter[2],
											isolatedIslandLinkPosAlter[3]
										}, {
											{
												oriEndPos[1],
												oriEndPos[2],
												oriEndPos[3]
											}
										}, function(aiConstReqState3, path3)
											if NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState3) and path3 then
												playerToDestinationDist = playerToDestinationDist + self:calPathDistance(path3)
											end

											repeatCall()
										end)
									else
										repeatCall()
									end
								end)
							else
								playerToDestinationDist = self:calPathDistance(path)

								repeatCall()
							end
						end
					end)
				end
			end
		end)
	end

	mainCall()
end

function MapSystem:onDrawNavEffLine(info)
	self:setTrackPathStart("nav", info and info.path and info.overrideStartPosInfo and info.overrideStartPosInfo.startSpawnerId or nil, info and info.sceneId)

	if info.path then
		if info.isInner or info.duplicateCall then
			return
		end

		if not info.overrideStartPosInfo or not info.overrideStartPosInfo.startSpawnerId then
			if pg.global.ui:checkUIVisible(UIConst.UI_ID_MAP) then
				pg.global.ui.map:centralizeMark("BtnMine")
				pg.global.ui.map:drawNavEffLine(info)

				return
			end
		else
			if pg.global.ui:checkUIVisible(UIConst.UI_ID_MAP) then
				if not pg.global.ui.map.markCaches then
					return
				end

				local mark = pg.global.ui.map.markCaches[info.overrideStartPosInfo.startSpawnerId]

				pg.global.ui.map:focusMark({
					string.format("mark_%s_%s", info.overrideStartPosInfo.startSpawnerType, info.overrideStartPosInfo.startSpawnerId),
					nil,
					true,
					function()
						pg.global.ui.map:drawNavEffLine(info, mark and mark.button)
					end
				})

				return
			end

			self:openMapAndLocateMark(info.sceneId, info.overrideStartPosInfo.startSpawnerType, info.overrideStartPosInfo.startSpawnerId, nil, nil, function()
				return
			end)
		end
	else
		pg.global.ui.map:drawNavEffLine(info)
	end
end

function MapSystem:calDestinationPosition(oriEndPos)
	local sceneId = pg.me.space.sceneId
	local playerInIsolatedIsland = Utils.checkInSpecificAreaRange(sceneId, pg.me:getPosition())
	local endInIsolatedIsland = Utils.checkInSpecificAreaRange(sceneId, oriEndPos)

	if playerInIsolatedIsland then
		if endInIsolatedIsland then
			return false, nil, oriEndPos, nil
		else
			local mark = AreaNavTransitData[playerInIsolatedIsland].exit
			local markAlter = AreaNavTransitData[playerInIsolatedIsland].entry[SceneUtils.getMainSceneId(sceneId)]

			return true, self.sceneMarkPointData[mark].markPosition, oriEndPos, self.sceneMarkPointData[markAlter].markPosition
		end
	elseif endInIsolatedIsland then
		local mark = AreaNavTransitData[endInIsolatedIsland].entry[SceneUtils.getMainSceneId(sceneId)]
		local markAlter = AreaNavTransitData[endInIsolatedIsland].exit

		return true, self.sceneMarkPointData[mark].markPosition, oriEndPos, self.sceneMarkPointData[markAlter].markPosition
	else
		return false, nil, oriEndPos, nil
	end
end

function MapSystem:calPathDistance(path)
	return MapHelper.calPathDistance(path)
end

function MapSystem:trackDiffSceneMark(sceneId, spawnerId, markInfo, cb)
	local pos = markInfo and markInfo.markPosition or nil
	local replaceIcon = markInfo and markInfo.replaceIcon or nil

	self:storeTrackMarks(spawnerId, sceneId, markInfo.markType, pos, replaceIcon)

	local ret = {}
	local aroundTeleportMarkIds = {}
	local sceneIds = {}

	sceneIds[#sceneIds + 1] = markInfo.realSceneId

	local mainSceneId = SceneUtils.getMainSceneId(markInfo.realSceneId)

	if SceneSeamlessData[mainSceneId] and SceneSeamlessData[mainSceneId].seamlessGroup then
		for seamlessId, _ in pairs(SceneSeamlessData[mainSceneId].seamlessGroup) do
			sceneIds[#sceneIds + 1] = seamlessId
		end
	end

	for _, seamlessId in pairs(sceneIds) do
		self:getSceneMarkInfoByMarkId(seamlessId)
	end

	for _, seamlessId in pairs(sceneIds) do
		self:getSceneMarkInfoByMarkId(seamlessId)

		for markId, markInfo1 in pairs(self.cacheAllSceneMarkPointData[seamlessId]) do
			if (markInfo1.infoPage == 2 or DefaultMapMarkData[markInfo1.markConfigId].infoPage == 2) and markInfo1.ShoworNot == 1 and self:getMarkStatus(markId, markInfo1.markType, markInfo1.realSceneId) > Const.MAP_MARK_STATUS_LOCKED then
				local dist = Vector3.Distance(pos, markInfo1.markPosition)

				if dist <= MapSystem.TRANSMIT_SEARCH_DISTANCE then
					local startInIsolatedIsland = Utils.checkInSpecificAreaRange(sceneId, markInfo1.markPosition)
					local endInIsolatedIsland = Utils.checkInSpecificAreaRange(sceneId, pos)
					local areaInfo = {}

					if startInIsolatedIsland then
						if endInIsolatedIsland then
							areaInfo = {
								inDiffArea = false,
								oriEndPos = pos
							}
						else
							local mark = AreaNavTransitData[startInIsolatedIsland].exit
							local markAlter = AreaNavTransitData[startInIsolatedIsland].entry[SceneUtils.getMainSceneId(sceneId)]

							areaInfo = {
								inDiffArea = true,
								isolatedIslandLinkPos = self:getMarkInfoFromAllCacheData(mark).markPosition,
								oriEndPos = pos,
								isolatedIslandLinkPosAlter = self:getMarkInfoFromAllCacheData(markAlter).markPosition
							}
						end
					elseif endInIsolatedIsland then
						local mark = AreaNavTransitData[endInIsolatedIsland].entry[SceneUtils.getMainSceneId(sceneId)]
						local markAlter = AreaNavTransitData[endInIsolatedIsland].exit

						areaInfo = {
							inDiffArea = true,
							isolatedIslandLinkPos = self:getMarkInfoFromAllCacheData(mark).markPosition,
							oriEndPos = pos,
							isolatedIslandLinkPosAlter = self:getMarkInfoFromAllCacheData(markAlter).markPosition
						}
					else
						areaInfo = {
							inDiffArea = false,
							oriEndPos = pos
						}
					end

					aroundTeleportMarkIds[#aroundTeleportMarkIds + 1] = {
						markId = markId,
						markInfo = markInfo1,
						areaInfo = areaInfo
					}
				end
			end
		end
	end

	local function repeatCall()
		local first = MapHelper.popFirstElement(aroundTeleportMarkIds)

		if first then
			local startPos = {
				first.markInfo.markPosition[1],
				first.markInfo.markPosition[2],
				first.markInfo.markPosition[3]
			}

			if not first.endPos then
				if cb then
					cb(false)
				end
			else
				NavMeshServiceUtils.findPath(self:convertSceneId(markInfo.realSceneId), startPos, {
					{
						first.endPos[1],
						first.endPos[2],
						first.endPos[3]
					}
				}, function(aiConstReqState, path)
					if (NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState) or aiConstReqState == AiConst.AUTO_PATH_REQ_STATE.SceneIdNotMatch) and path then
						ret.sceneId = sceneId
						ret.path = path
						ret.startSpawnerId = first.markId

						self:setTrackPathStart(spawnerId, first.markId, sceneId)

						if cb then
							cb(ret)
						end
					else
						repeatCall()
					end
				end)
			end
		elseif cb then
			cb(false)
		end
	end

	if not next(aroundTeleportMarkIds) then
		if cb then
			cb(false)
		end
	else
		local callCount = 0

		for i = 1, #aroundTeleportMarkIds do
			NavMeshServiceUtils.findPath(self:convertSceneId(markInfo.realSceneId), {
				aroundTeleportMarkIds[i].markInfo.markPosition[1],
				aroundTeleportMarkIds[i].markInfo.markPosition[2],
				aroundTeleportMarkIds[i].markInfo.markPosition[3]
			}, {
				{
					pos[1],
					pos[2],
					pos[3]
				}
			}, function(aiConstReqState1, path1)
				if not aroundTeleportMarkIds[i].areaInfo.inDiffArea and (NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState1) or aiConstReqState1 == AiConst.AUTO_PATH_REQ_STATE.SceneIdNotMatch) and path1 then
					aroundTeleportMarkIds[i].realDist = self:calPathDistance(path1)
					aroundTeleportMarkIds[i].endPos = pos
					callCount = callCount + 1

					if callCount >= #aroundTeleportMarkIds then
						table.sort(aroundTeleportMarkIds, function(a, b)
							return a.realDist < b.realDist
						end)
						repeatCall()
					end
				elseif not aroundTeleportMarkIds[i].areaInfo.inDiffArea then
					aroundTeleportMarkIds[i].realDist = math.maxInt
					callCount = callCount + 1

					if callCount >= #aroundTeleportMarkIds then
						table.sort(aroundTeleportMarkIds, function(a, b)
							return a.realDist < b.realDist
						end)
						repeatCall()
					end
				else
					NavMeshServiceUtils.findPath(self:convertSceneId(markInfo.realSceneId), {
						aroundTeleportMarkIds[i].markInfo.markPosition[1],
						aroundTeleportMarkIds[i].markInfo.markPosition[2],
						aroundTeleportMarkIds[i].markInfo.markPosition[3]
					}, {
						{
							aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPos[1],
							aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPos[2],
							aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPos[3]
						}
					}, function(aiConstReqState2, path2)
						if (NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState2) or aiConstReqState2 == AiConst.AUTO_PATH_REQ_STATE.SceneIdNotMatch) and path2 then
							aroundTeleportMarkIds[i].realDist = self:calPathDistance(path2)
							aroundTeleportMarkIds[i].endPos = aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPos

							NavMeshServiceUtils.findPath(self:convertSceneId(markInfo.realSceneId), {
								aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPosAlter[1],
								aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPosAlter[2],
								aroundTeleportMarkIds[i].areaInfo.isolatedIslandLinkPosAlter[3]
							}, {
								{
									pos[1],
									pos[2],
									pos[3]
								}
							}, function(aiConstReqState3, path3)
								if (NavMeshServiceUtils.isResponseStateSuccess(aiConstReqState3) or aiConstReqState3 == AiConst.AUTO_PATH_REQ_STATE.SceneIdNotMatch) and path3 then
									aroundTeleportMarkIds[i].realDist = aroundTeleportMarkIds[i].realDist + self:calPathDistance(path3)
								else
									aroundTeleportMarkIds[i].realDist = math.maxInt
								end

								callCount = callCount + 1

								if callCount >= #aroundTeleportMarkIds then
									table.sort(aroundTeleportMarkIds, function(a, b)
										return a.realDist < b.realDist
									end)
									repeatCall()
								end
							end)
						else
							aroundTeleportMarkIds[i].realDist = math.maxInt
							callCount = callCount + 1

							if callCount >= #aroundTeleportMarkIds then
								table.sort(aroundTeleportMarkIds, function(a, b)
									return a.realDist < b.realDist
								end)
								repeatCall()
							end
						end
					end)
				end
			end)
		end
	end
end

function MapSystem:isContainShowQuestTagMarkId(questId, spawnerId)
	for i, v in pairs(self.sceneMarkQuestOverlapPoint) do
		if questId == i then
			for j, k in pairs(v) do
				if k.spawnerId == spawnerId then
					return true
				end
			end
		end
	end

	return false
end

function MapSystem:_getQuestAssocSpawner2Mark()
	if self._questAssocSpawner2MarkDirty or self._questAssocSpawner2Mark == nil then
		local map = {}
		local questMarkById = {}

		if self.sceneMarkQuestPointData then
			for _, questMark in pairs(self.sceneMarkQuestPointData) do
				local id = QuestUtils.getCombinedId(questMark.questId, questMark.objId)

				questMarkById[id] = questMark
			end
		end

		if self.sceneMarkPointDataOverlap then
			for spawnerId, owner in pairs(self.sceneMarkPointDataOverlap) do
				local id = QuestUtils.getCombinedId(owner.questId, owner.objId)

				map[spawnerId] = questMarkById[id]
			end
		end

		self._questAssocSpawner2Mark = map
		self._questAssocSpawner2MarkDirty = false
	end

	return self._questAssocSpawner2Mark
end

function MapSystem:getValidQuestAssociationMarkData(spawnerId, questMark)
	local markData = self.sceneMarkPointData and self.sceneMarkPointData[spawnerId]

	if markData == nil or markData.markType == Const.MAP_MARK_CLUE or questMark == nil then
		return nil
	end

	if markData.ShoworNot ~= 1 and markData.OnlyShowInMinimapResizeArea ~= 1 then
		return nil
	end

	local source = QuestUtils.getQuestAssociationSpawnerSource(questMark.questId, questMark.objId, spawnerId)

	if source == QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.NONE then
		return nil
	end

	if source == QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.TARGET_ENTITY then
		local ownerInfo = markData.ownerInfo

		if ownerInfo == nil or ownerInfo[1] ~= "entity" or tonumber(ownerInfo[2]) ~= spawnerId then
			return nil
		end
	end

	return markData
end

function MapSystem:getQuestMarkByAssocSpawnerId(spawnerId)
	local map = self:_getQuestAssocSpawner2Mark()

	return map and map[spawnerId] or nil
end

function MapSystem:_insertSceneMarkOverlapEntry(spawnerId, markPointData, questMark)
	if self.sceneMarkQuestOverlapPoint[questMark.questId] == nil then
		self.sceneMarkQuestOverlapPoint[questMark.questId] = {}
	end

	local temp = {}

	temp.spawnerId = spawnerId
	temp.addQuestTagId = questMark.questId
	temp.objId = questMark.objId
	temp.addQuestTagShow = false

	if self:isEnabledByFilter(self.sceneId, markPointData.markConfigId, markPointData.markStatus, spawnerId, {
		finishStateAlwaysShow = markPointData.finishStateAlwaysShow
	}) then
		temp.addQuestTagShow = true
	end

	table.insert(self.sceneMarkQuestOverlapPoint[questMark.questId], temp)

	if not self.sceneMarkPointDataOverlap[spawnerId] then
		self.sceneMarkPointDataOverlap[spawnerId] = {
			questId = questMark.questId,
			objId = questMark.objId,
			markType = markPointData.markType
		}
		self._questAssocSpawner2MarkDirty = true
	end
end

function MapSystem:addSceneMarkQuestOverlap(questMark)
	if not questMark or not questMark.questId then
		return
	end

	if not self.sceneMarkPointData then
		return
	end

	self.sceneMarkQuestOverlapPoint = self.sceneMarkQuestOverlapPoint or {}
	self.sceneMarkPointDataOverlap = self.sceneMarkPointDataOverlap or {}

	local overlapList = self.sceneMarkQuestOverlapPoint[questMark.questId]

	if overlapList then
		for _, entry in pairs(overlapList) do
			if entry.objId == questMark.objId then
				return
			end
		end
	end

	local candidateIds = QuestUtils.getQuestAssociationSpawnerIds(questMark.questId, questMark.objId)

	for i = 1, #candidateIds do
		local spawnerId = candidateIds[i]
		local markPointData = self:getValidQuestAssociationMarkData(spawnerId, questMark)

		if markPointData and not self.sceneMarkPointDataOverlap[spawnerId] then
			self:_insertSceneMarkOverlapEntry(spawnerId, markPointData, questMark)
		end
	end
end

function MapSystem:removeSceneMarkQuestOverlap(questId, objId)
	if not questId then
		return
	end

	if not self.sceneMarkQuestOverlapPoint or not self.sceneMarkPointDataOverlap then
		return
	end

	local overlapList = self.sceneMarkQuestOverlapPoint[questId]

	if overlapList == nil then
		return
	end

	local freedSpawners = {}

	for i = #overlapList, 1, -1 do
		local entry = overlapList[i]

		if objId == nil or entry.objId == objId then
			local sid = entry.spawnerId

			freedSpawners[sid] = true

			local owner = self.sceneMarkPointDataOverlap[sid]

			if owner and owner.questId == questId and (objId == nil or owner.objId == objId) then
				self.sceneMarkPointDataOverlap[sid] = nil
				self._questAssocSpawner2MarkDirty = true
			end

			table.remove(overlapList, i)
		end
	end

	if #overlapList == 0 then
		self.sceneMarkQuestOverlapPoint[questId] = nil
	end

	if self.sceneMarkPointData and self.sceneMarkQuestPointData then
		for sid in pairs(freedSpawners) do
			if not self.sceneMarkPointDataOverlap[sid] then
				for _, qm in pairs(self.sceneMarkQuestPointData) do
					local markPointData = self:getValidQuestAssociationMarkData(sid, qm)

					if markPointData then
						self:_insertSceneMarkOverlapEntry(sid, markPointData, qm)

						break
					end
				end
			end
		end
	end
end

function MapSystem:populateSceneMarkPointOverlap()
	if not self.sceneMarkPointData or not self.sceneMarkQuestPointData then
		return
	end

	self.sceneMarkQuestOverlapPoint = {}
	self.sceneMarkPointDataOverlap = {}
	self._questAssocSpawner2MarkDirty = true

	for _, questMark in pairs(self.sceneMarkQuestPointData) do
		self:addSceneMarkQuestOverlap(questMark)
	end
end

function MapSystem:isContainMarkSpawnerId(questId, objId)
	for i, v in pairs(self.sceneMarkPointDataOverlap) do
		if questId == v.questId and (objId == nil or objId == v.objId) then
			return i, true, v
		end
	end

	return nil, false, nil
end

function MapSystem:getContainMarkSpawnerId(spawnerId)
	return self.sceneMarkPointDataOverlap and self.sceneMarkPointDataOverlap[spawnerId]
end

function MapSystem:getQuestTagRelateMarkPosition(questId, objId)
	local spawnerId, isSpawnerId = self:isContainMarkSpawnerId(questId, objId)

	if not isSpawnerId or not spawnerId then
		return nil
	end

	local markInfo = self:getMarkInfo(spawnerId)

	if markInfo and markInfo.markPosition then
		return markInfo.markPosition
	end

	return nil
end

function MapSystem:isShowQuestTagMark(questId, objId)
	local num = 0

	for i, v in pairs(self.sceneMarkQuestOverlapPoint) do
		if questId == i then
			for j, k in pairs(v) do
				if (objId == nil or objId == k.objId) and k.addQuestTagShow then
					num = num + 1
				end
			end
		end
	end

	return num > 0
end

function MapSystem:setSceneMarkQuestPointDataFiler(pointData, flag)
	for i, v in pairs(self.sceneMarkQuestOverlapPoint) do
		if pointData then
			for j, k in pairs(v) do
				if pointData.spawnerId and k.spawnerId == pointData.spawnerId then
					self.sceneMarkQuestOverlapPoint[k.addQuestTagId][j].addQuestTagShow = flag
				end
			end
		end
	end
end

function MapSystem:grabEggSettlementOpen(sceneId, path, cb)
	pg.global.ui:open(UIConst.UI_ID_MAP, nil, function()
		pg.global.ui.map:grabEggSettlementOpen(sceneId, path, cb)
	end)
end

function MapSystem:grabEggSettlementClose()
	if pg.global.ui:checkUIVisible(UIConst.UI_ID_MAP) then
		pg.global.ui.map:grabEggSettlementClose()
	end
end

function MapSystem:getCountryAreaUnlockDict()
	return MapHelper.getCountryAreaUnlockDict()
end

function MapSystem:saveMapAreaSelectedSetting(selecedAreaIds)
	local flagStr = MapHelper.serializeMapAreaSetting(selecedAreaIds)

	pg.global.prefsCacheUtils:setString(ClientConst.PrefKey.MapAreaFilterFlagKey .. tostring(pg.me.uid), flagStr)
end

function MapSystem:getMapAreaSelectedSetting()
	local flagStr = pg.global.prefsCacheUtils:getString(ClientConst.PrefKey.MapAreaFilterFlagKey .. tostring(pg.me.uid), "")

	return MapHelper.deserializeMapAreaSetting(flagStr)
end

function MapSystem:forceShowHudMarkTraceIfCurrentSceneNoMapRes(markPosition, markIcon, id, show)
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if pg.game.map:checkValidScene(pg.game.map:convertSceneId(pg.me.space.sceneId)) then
		return
	end

	local mapMarkTipComponent = pg.global.ui.hatredArrowTip.mapMarkTipComponent

	if not mapMarkTipComponent then
		return
	end

	mapMarkTipComponent:forceShowHudMark(markPosition, markIcon, id, show)
end

function MapSystem:openMapAndTraceToHomelandPortal(facilityId, markIcon, cb)
	if not pg.space:isHomeland() then
		if not self:checkValidScene(self:convertSceneId(pg.me.space.sceneId)) then
			pg.global.showBubbleMessageById(2126)

			return
		end

		if not pg.me or not pg.me.curCampStaticId or pg.me.curCampStaticId == 0 then
			return
		end

		self:openMapAndLocateMark(3000, Const.MAP_MARK_HOME_CAMP, pg.me.curCampStaticId, true, nil, cb, true)

		self.homelandHUDMarkTraceFlag = {
			facilityId = facilityId,
			markIcon = markIcon
		}
	else
		self:homelandHUDMarkTrace(facilityId, markIcon)
	end
end

function MapSystem:getClosestHomelandFacilityPosition(facilityId)
	if not pg.space or not pg.space.ornament or not pg.game.home then
		return nil
	end

	local closestDistance = math.maxFloat
	local targetPos
	local playerPos = pg.me:getPosition()

	for _, ornamentInfo in pairs(pg.space.ornament) do
		if ornamentInfo.homeId == facilityId then
			local facilityPos = pg.game.home:getWorldPosition(ornamentInfo.areaId, ornamentInfo:getPosition())
			local distance = Vector3.Distance(playerPos, facilityPos)

			if distance < closestDistance then
				closestDistance = distance
				targetPos = facilityPos
			end
		end
	end

	return targetPos
end

function MapSystem:homelandHUDMarkTrace(facilityId, markIcon)
	if not pg.space:isHomeland() then
		return
	end

	local targetPos = self:getClosestHomelandFacilityPosition(facilityId)

	if not targetPos then
		return
	end

	self:forceShowHudMarkTraceIfCurrentSceneNoMapRes(targetPos, markIcon, facilityId, true)
	pg.game.navEffect:path(pg.space.sceneId, targetPos, facilityId)

	if self.homelandTimer then
		self:killTimer(self.homelandTimer)

		self.homelandTimer = nil
	end

	self.homelandTimer = self:startTimer(function()
		local playerPos1 = pg.me:getPosition()
		local dis = Vector3.Distance(playerPos1, targetPos)

		if dis < 5 then
			self:forceShowHudMarkTraceIfCurrentSceneNoMapRes(nil, nil, facilityId, false)
			pg.game.navEffect:unPath(facilityId)
			pg.global.showBubbleMessageById(2124)

			if self.homelandTimer then
				self:killTimer(self.homelandTimer)

				self.homelandTimer = nil
			end
		end
	end, 1, true)
end

function MapSystem:traceSelfHomeCar(posType, markIcon, data, cb)
	if not pg.me.isHomeCampUnlocked then
		pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_NOT_UNLOCKED)

		return
	end

	self.traceCampInfo = {
		posType = posType,
		markIcon = markIcon,
		buttonTxt = data.buttonTxt,
		showTrace = data.showTrace
	}
	self.curTraceCampCarId = nil

	self:updateHomeCampMark(cb)
end

function MapSystem:updateHomeCampMark(cb)
	if not pg.me or not pg.me.space then
		return
	end

	local curCampCarId = pg.me:getSelfHomeCampPlaceId()

	if not curCampCarId or curCampCarId == 0 then
		return
	end

	local posType = self.traceCampInfo.posType
	local traceId = math.abs(self.traceCampInfo.buttonTxt)

	if self.curTraceCampCarId == curCampCarId and self.tempMarkPointData[traceId] then
		return
	end

	local campCarData = HomeCampCarData[curCampCarId]
	local posId

	if posType == 1 then
		posId = campCarData.boardPosition
	elseif posType == 2 then
		posId = campCarData.ornamentCenter
	elseif posType == 3 then
		posId = campCarData.carPosition
	elseif posType == 4 then
		posId = campCarData.carPosition
	end

	if not posId then
		return
	end

	local sceneId = SceneUtils.getMainSceneId(pg.me.space.sceneId)
	local dstPos, dstRot = SceneUtils.getCommonBasicsPosition(sceneId, posId)

	if not dstPos then
		self.curTraceCampCarId = nil

		return
	end

	if posType == 4 then
		local offsetPos = HomelandConfigData.carInteractOffset or Const.HOME_CAMP_CAR_INTERACT_OFFSET

		dstPos = dstPos + dstRot:MulVec3(Vector3(offsetPos[1], offsetPos[2], offsetPos[3]))
	end

	local extraParam = {
		navPath = true,
		dontOpenMap = true
	}

	self.curTraceCampCarId = curCampCarId

	self:openMapAndLocateTempMark(sceneId, dstPos[1], dstPos[2] + 0.2, dstPos[3], nil, traceId, cb, self.traceCampInfo.showTrace and self.traceCampInfo.showTrace == 1, extraParam)
end

function MapSystem:dealWithHomelandSceneLoaded()
	if self.homelandTimer then
		self:killTimer(self.homelandTimer)

		self.homelandTimer = nil
	end

	if self.homelandHUDMarkTraceFlag then
		self:homelandHUDMarkTrace(self.homelandHUDMarkTraceFlag.facilityId, self.homelandHUDMarkTraceFlag.markIcon)

		self.homelandHUDMarkTraceFlag = nil
	end
end

function MapSystem:setClueSeekTeleportTrace(dstScene, data)
	self.clueSeekTeleportTraceFlag = {
		dstScene = dstScene,
		data = data
	}
end

function MapSystem:getClueSeekTargetPos(data)
	if data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS then
		return data.sourcePosition
	elseif data.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_MARK and data.sourceMarkPoint then
		local markInfos = SceneUtils.getSceneTargetPositionData(self.sceneId)
		local markInfo = markInfos and markInfos[data.sourceMarkPoint[1]]
		local markPos = markInfo and markInfo.position

		return markPos and {
			markPos[1],
			markPos[2],
			markPos[3]
		}
	elseif data.type == LuaUIUtils.ITEM_SOURCE_HOMELAND_FACILITIES and data.sourceFacilities then
		local facilityId = data.sourceFacilities[1]
		local targetPos = self:getClosestHomelandFacilityPosition(facilityId)

		return targetPos and {
			targetPos.x,
			targetPos.y,
			targetPos.z
		}
	end

	return nil
end

function MapSystem:dealWithClueSeekTeleportTrace()
	local flag = self.clueSeekTeleportTraceFlag

	if not flag then
		return
	end

	self.clueSeekTeleportTraceFlag = nil

	if self:convertSceneId(self.sceneId) ~= flag.dstScene then
		return
	end

	local data = flag.data
	local targetPos = self:getClueSeekTargetPos(data)

	if not targetPos then
		return
	end

	local markId = math.abs(data.buttonTxt or 1)

	QuestUtils.navigateToTarget({
		scene = self.sceneId,
		position = targetPos
	}, markId)
	self:startClueSeekArriveCheck(markId, targetPos)
end

function MapSystem:startClueSeekArriveCheck(markId, targetPos)
	if self.clueSeekArriveTimer then
		self:killTimer(self.clueSeekArriveTimer)

		self.clueSeekArriveTimer = nil
	end

	self.clueSeekArriveTimer = self:startTimer(function()
		local dis = Vector3.Distance(pg.me:getPosition(), targetPos)

		if dis < 5 then
			pg.game.navEffect:unPath(markId)

			if self.clueSeekArriveTimer then
				self:killTimer(self.clueSeekArriveTimer)

				self.clueSeekArriveTimer = nil
			end
		end
	end, 1, true)
end

function MapSystem:checkAtLeastOneLeylineTreeUnlocked()
	for largeBlockId, _ in pairs(MapAreaConfigData) do
		local leylineTreeData = self:checkBlockLeylineTreeUnlocked(largeBlockId)

		if leylineTreeData then
			return true
		end
	end

	return false
end

function MapSystem:tryBindEntityPosToMapMark(markId, entityId)
	if self.bindMap[markId] then
		return
	end

	self:bindEntityPosToMapMark(markId, entityId)
end

function MapSystem:bindEntityPosToMapMark(markId, entityId)
	local markInfo = self:getMarkInfo(markId)

	if not markInfo then
		return
	end

	self.bindMap[markId] = entityId

	local info = _mapMarkBindMessageInfo

	info.markId = markId
	info.entityId = entityId

	facade:SendMessageCommand(MessageName.ON_MAP_MARK_BIND_ENTITY, info)
end

function MapSystem:unbindEntityPosFromMapMark(markId, entityId)
	local boundEntityId = self.bindMap[markId]

	if not boundEntityId then
		return
	end

	if entityId ~= nil and boundEntityId ~= entityId then
		return
	end

	self.bindMap[markId] = nil

	local info = _mapMarkUnbindMessageInfo

	info.markId = markId
	info.entityId = boundEntityId

	facade:SendMessageCommand(MessageName.ON_MAP_MARK_UNBIND_ENTITY, info)
end

function MapSystem:GetCurrentBindMapMarkPos(markId)
	local pos = self:GetCurrentBindMapMarkPosOriginal(markId)

	if pos then
		local x, y = self:convertPos(pos[1], pos[3], self.mainSceneId, true)

		return x, y
	end
end

function MapSystem:GetCurrentBindMapMarkPosOriginal(markId)
	local bindMap = self.bindMap
	local entityId = bindMap[markId]

	return MapHelper.GetEntityPos(entityId)
end

function MapSystem:getEffectiveMarkPos(markId, fallbackPos)
	local pos = self:GetCurrentBindMapMarkPosOriginal(markId)

	if pos then
		return pos
	end

	return fallbackPos
end

function MapSystem:BindMapForeach(func, that)
	local bindMap = self.bindMap

	if not next(bindMap) then
		return
	end

	for markId, entityId in pairs(bindMap) do
		func(that, markId, entityId)
	end
end

function MapSystem:setMapFogMaskStatus(sceneId, desiredCleanSmallArea)
	self.desiredCleanSmallArea[sceneId] = {}

	for _, smallAreaId in pairs(desiredCleanSmallArea) do
		table.insert(self.desiredCleanSmallArea[sceneId], smallAreaId)
	end
end

function MapSystem:clearMapFogMaskStatus(sceneId)
	self.desiredCleanSmallArea[sceneId] = nil
end

function MapSystem:setMapWarningAreaStatus(sceneId, desiredWarningSmallArea)
	self.desiredWarningSmallArea[sceneId] = {}

	for _, smallAreaId in pairs(desiredWarningSmallArea) do
		table.insert(self.desiredWarningSmallArea[sceneId], smallAreaId)
	end
end

function MapSystem:clearMapWarningAreaStatus(sceneId)
	self.desiredWarningSmallArea[sceneId] = nil
end

function MapSystem:displayMapNode(nodeName, display)
	if not display then
		self.mapNodeDisplayStatus[nodeName] = nil
	else
		self.mapNodeDisplayStatus[nodeName] = true
	end

	if not pg.global.ui:checkUIVisible(UIConst.UI_ID_MAP) then
		return
	end

	local mapView = pg.global.ui.map.view

	if not mapView then
		return
	end

	mapView:displayUINode(nodeName, display)
end

function MapSystem:teamMarkTrackUidsEqual(lhs, rhs)
	if lhs == rhs then
		return true
	end

	lhs = lhs or {}
	rhs = rhs or {}

	if #lhs ~= #rhs then
		return false
	end

	for i = 1, #lhs do
		if lhs[i] ~= rhs[i] then
			return false
		end
	end

	return true
end

function MapSystem:teamMarkPointDataEqual(currentMarkData, sceneId, markType, latestMarkData)
	if not currentMarkData then
		return false
	end

	local currentPos = currentMarkData.markPosition
	local latestPos = latestMarkData.pos

	if not currentPos or not latestPos then
		return false
	end

	return currentMarkData.realSceneId == sceneId and currentMarkData.markConfigId == markType and currentMarkData.markType == markType and currentMarkData.markIconIndex == latestMarkData.markIconIndex and currentPos[1] == latestPos[1] and currentPos[2] == latestPos[2] and currentPos[3] == latestPos[3] and currentMarkData.creatorUid == latestMarkData.creatorUid and currentMarkData.name == latestMarkData.name
end

function MapSystem:teamFixedMarkTrackMapEqual(lhs, rhs)
	if lhs == rhs then
		return true
	end

	lhs = lhs or {}
	rhs = rhs or {}

	for sceneId, lhsSceneMap in pairs(lhs) do
		local rhsSceneMap = rhs[sceneId]

		if not rhsSceneMap then
			return false
		end

		for dividingId, lhsTrackUids in pairs(lhsSceneMap) do
			if not self:teamMarkTrackUidsEqual(lhsTrackUids, rhsSceneMap[dividingId]) then
				return false
			end
		end

		for dividingId, _ in pairs(rhsSceneMap) do
			if lhsSceneMap[dividingId] == nil then
				return false
			end
		end
	end

	for sceneId, _ in pairs(rhs) do
		if lhs[sceneId] == nil then
			return false
		end
	end

	return true
end

function MapSystem:refreshTeamMarkPointData()
	local markChanged = false
	local selfTrackedMarkRemoved = false
	local teamInfo = pg.me:getShowTeamInfo()
	local teamMapMarkMap = teamInfo and teamInfo.teamMapMarkMap or {}
	local teamFixedMarkTrackMap = teamInfo and teamInfo.teamFixedMarkTrackMap or {}
	local allChildrenScenes = MapHelper.getAllChildrenScene(self.sceneId)
	local markType = Const.MAP_MARK_FAST_TARGET
	local latestTeamMarkMap = {}

	for _, sceneId in pairs(allChildrenScenes) do
		for genId, markData in pairs(teamMapMarkMap[sceneId] or EMPTY_TABLE) do
			latestTeamMarkMap[genId] = {
				sceneId = sceneId,
				markData = markData
			}
		end
	end

	for markId, currentMarkData in pairs(self.teamMarkPointData) do
		if not latestTeamMarkMap[markId] then
			local sceneTeamMarkMap = currentMarkData and teamMapMarkMap[currentMarkData.realSceneId]
			local markStillExists = sceneTeamMarkMap and sceneTeamMarkMap[markId]

			if teamInfo and pg.me:isInTeam() and not markStillExists and currentMarkData.creatorUid ~= pg.me.uid then
				local isSelfTrack = self:getTrackResultByUidList(currentMarkData.trackUids, pg.me.uid)

				if isSelfTrack then
					selfTrackedMarkRemoved = true
				end
			end

			self.teamMarkPointData[markId] = nil
			markChanged = true
		end
	end

	for markId, latestMarkInfo in pairs(latestTeamMarkMap) do
		local sceneId = latestMarkInfo.sceneId
		local markData = latestMarkInfo.markData
		local currentMarkData = self.teamMarkPointData[markId]
		local markBaseChanged = not self:teamMarkPointDataEqual(currentMarkData, sceneId, markType, markData)
		local trackChanged = currentMarkData and not self:teamMarkTrackUidsEqual(currentMarkData.trackUids, markData.trackUids)

		if markBaseChanged or trackChanged then
			self:addOrUpdateTempMark(sceneId, markData.pos[1], markData.pos[2], markData.pos[3], markId, markType, {
				markIconIndex = markData.markIconIndex,
				creatorUid = markData.creatorUid,
				trackUids = markData.trackUids,
				name = markData.name
			}, self.teamMarkPointData, true)

			if markBaseChanged then
				markChanged = true
			end
		end
	end

	if not self:teamFixedMarkTrackMapEqual(self.teamFixedMarkTrackMap, teamFixedMarkTrackMap) then
		self.teamFixedMarkTrackMap = Utils.deepCopyTable(teamFixedMarkTrackMap) or {}
	end

	if markChanged then
		facade:SendMessageCommand(MessageName.TEAM_MARK_CHANGE)
	end

	facade:SendMessageCommand(MessageName.TEAM_MARK_TRACK_CHANGE)

	if selfTrackedMarkRemoved then
		pg.global.showBubbleMessageById(NoticeDef.TEAM_TRACK_MARK_REMOVED)
	end
end

function MapSystem:getTrackResultByUidList(trackUids, selfUid)
	if not trackUids or not trackUids[1] then
		return false, nil
	end

	if selfUid == nil then
		return true, trackUids[1]
	end

	for _, uid in ipairs(trackUids) do
		if uid == selfUid then
			return true, trackUids[1]
		end
	end

	return false, nil
end

function MapSystem:isMarkTeamTrack(sceneId, spawnerId, anyMember)
	local teamInfo = pg.me:getShowTeamInfo()

	if not teamInfo then
		return false
	end

	local teamFixedMarkTrackMap = teamInfo.teamFixedMarkTrackMap

	if not teamFixedMarkTrackMap then
		return false
	end

	local selfUid

	if not anyMember then
		selfUid = pg.me.uid
	end

	local sceneFixedTrackMap = teamFixedMarkTrackMap[sceneId]
	local fixedTrackUids = sceneFixedTrackMap and sceneFixedTrackMap[spawnerId]
	local isTrack, firstTrackUid = self:getTrackResultByUidList(fixedTrackUids, selfUid)

	if isTrack then
		return true, firstTrackUid
	end

	local teamMapMarkMap = teamInfo.teamMapMarkMap

	if not teamMapMarkMap then
		return false
	end

	local markType = Const.MAP_MARK_FAST_TARGET
	local sceneTeamMarkMap = teamMapMarkMap[sceneId]

	if not sceneTeamMarkMap then
		return false, nil
	end

	for genId, markData in pairs(sceneTeamMarkMap) do
		local markId = tonumber(string.format("%s%s%s%s", sceneId, markType, markType, genId))

		if markId == spawnerId then
			return self:getTrackResultByUidList(markData.trackUids, selfUid)
		end
	end

	return false, nil
end

function MapSystem:getTrackInfo(sceneId, spawnerType, spawnerId)
	if spawnerType == Const.MAP_CONST.TYPE.FAST_TARGET then
		return false, nil
	end

	return self:isMarkTeamTrack(sceneId, spawnerId, true)
end

function MapSystem:clearAllMapNode()
	for nodeName, _ in pairs(self.mapNodeDisplayStatus) do
		self.mapNodeDisplayStatus[nodeName] = nil

		if pg.global.ui:checkUIVisible(UIConst.UI_ID_MAP) then
			local mapView = pg.global.ui.map.view

			if mapView then
				mapView:displayUINode(nodeName, false)
			end
		end
	end
end

function MapSystem:showPetDistributionArea(petTemplateId, showTab, resetShowTab)
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Map) then
		return
	end

	self.activeDistributionPetTemplateId = petTemplateId

	local targetMap = self.mainSceneId

	if not self:checkValidScene(targetMap) then
		targetMap = ClientConst.SCENE_MAIN_SINGLE_WORLD
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_MAP) then
		pg.global.ui.map:openDistributionMode(showTab, resetShowTab)
	else
		pg.global.ui:open(UIConst.UI_ID_MAP, {
			showDistribution = true,
			forceSceneId = targetMap,
			distributionShowTab = showTab,
			resetDistributionShowTab = resetShowTab
		})
	end
end

function MapSystem:addTempMarkToWhiteList(markId, sceneId, markType)
	local mapMarkStatusMap = pg.me:getSpaceOwnerMapMarkStatusMap() or pg.me.mapMarkStatusMap
	local markStatus = mapMarkStatusMap:getStatus(sceneId, markType, markId)

	if markStatus ~= Const.MAP_MARK_STATUS_HIDE then
		return
	end

	local _whiteListExcludeConfigIds = {
		[35] = true,
		[30] = true
	}

	if _whiteListExcludeConfigIds[Utils.getMarkConfigId(markId)] then
		return
	end

	if not self.whiteListTempMarkIds then
		self.whiteListTempMarkIds = {}
	end

	self.whiteListTempMarkIds[markId] = {
		sceneId = sceneId,
		markType = markType,
		tempStatus = Const.MAP_MARK_STATUS_LOCKED
	}

	pg.me:OnMapMarkStatusChange(sceneId, markType, markId, Const.MAP_MARK_STATUS_HIDE, Const.MAP_MARK_STATUS_LOCKED)
end

function MapSystem:removeTempMarkFromWhiteList(markId)
	if not self.whiteListTempMarkIds then
		return
	end

	if not self.whiteListTempMarkIds[markId] then
		return
	end

	self.whiteListTempMarkIds[markId] = nil
end

function MapSystem:getTempWhiteListMarkData(markId)
	if not self.whiteListTempMarkIds then
		return
	end

	return self.whiteListTempMarkIds[markId]
end

return MapSystem
