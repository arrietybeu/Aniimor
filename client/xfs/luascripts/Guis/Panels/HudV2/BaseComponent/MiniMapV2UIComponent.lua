-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MiniMapV2UIComponent.lua

local UIConst = require("Const.UIConst")
local Mathf = require("Common.Math.Mathf")
local Const = require("Common.Const.Const")
local SceneData = require("Data.scene_data")
local MapLineData = require("Data.map_line_config_data")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local AddressDataConst = require("Const.AddressDataConst")
local MapMarkerPool = require("Guis.Panels.HudV2.BaseComponent.Minimap.MapMarkerPool")
local MapUtils = require("Guis.Utils.MapUtils")
local SCALE_MINI_MAP_TWEEN_ID = "scaleMiniMap"
local MiniMapV2UIComponent = Class.LightClass("MiniMapV2UIComponent", HudBaseComponent)
local ClientConst = require("Const.ClientConst")
local MapBlockConfigData = require("Data.map_block_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local WeatherData = require("Data.weather_data")
local PetData = require("Data.pet_data")
local MeteorologyData = require("Data.meteorology_data")
local Time = require("Core.Common.Time")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local MinimapGrabEggAreaComponent = require("Guis.Panels.HudV2.BaseComponent.Minimap.MinimapGrabEggAreaComponent")
local MinimapDynamicMarkComponent = require("Guis.Panels.HudV2.BaseComponent.Minimap.MinimapDynamicMarkComponent")
local MapMarkPrefabPoolManager = require("Guis.Utils.MapMarkPrefabPoolManager")
local MapHelper = require("GameApp.Map.MapHelper")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local DEFAULT_MINIMAP_SCALE_FACTOR = 1
local FACTOR_IN_SCALE_AREA = 5
local MAP_MARK_QUEST = Const.MAP_MARK_QUEST
local GameObject = GameObject
local NotNil = NotNil
local MINIMAP_ICON_SCALE_COE = UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE
local ConstUpdateInterval = 3

MiniMapV2UIComponent.messages = {
	[MessageName.WEATHER_REFRESH] = {
		"onWeatherRefresh"
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded"
	},
	[MessageName.ON_ADD_INFO_STAMP_SUCCESS] = {
		"onAddInfoStampSuccess"
	},
	[MessageName.ON_DELETE_INFO_STAMP_SUCCESS] = {
		"onDeleteInfoStampSuccess"
	},
	[MessageName.UI_MAP_SYSTEM_UNTRACE_QUEST_MARK] = {
		"onUntrackQuestMark"
	},
	[MessageName.UI_MAP_SYSTEM_TRACE_QUEST_MARK] = {
		"ontrackQuestMark"
	},
	[MessageName.UI_MAP_SYSTEM_ON_SPECIAL_STATE_UPDATE] = {
		"onMapSystemSpecialStateUpdate"
	},
	[MessageName.DRAW_NAV_EFF_LINE] = {
		"drawNavEffLine"
	},
	[MessageName.TEAM_MARK_CHANGE] = {
		"onTeamMarkChange",
		true
	},
	[MessageName.TEAM_MARK_TRACK_CHANGE] = {
		"onTeamMarkTrackChange",
		true
	},
	[MessageName.LEYLINEFLOWER_FLOWER_STATE_CHANGED] = {
		"onFlowerStateChanged",
		true
	},
	[MessageName.LEYLINEFLOWER_PLENTY_CIRCLE_CHANGED] = {
		"onPlentyCircleChanged",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.DUNGEON_PLAYER_COUNTDOWN] = {
		"onRefreshGameCountDown",
		true
	},
	[MessageName.DUNGEON_START_PLAYING] = {
		"onRefreshGameCountDown",
		true
	},
	[MessageName.GRAB_EGG_ADD_MAP_APPEAR_AREA] = {
		"onGrabEggAreaAdd",
		true
	},
	[MessageName.GRAB_EGG_REMOVE_MAP_APPEAR_AREA] = {
		"onGrabEggAreaRemove",
		true
	},
	[MessageName.NPC_DUEL_STATE_CHANGED] = {
		"onDuelStateChanged",
		true
	},
	[MessageName.ON_DYNAMIC_MARK_STATUS_CHANGED] = {
		"onDynamicMarkStatusChanged",
		true
	},
	[MessageName.ON_MAP_MARK_UNBIND_ENTITY] = {
		"onMapMarkUnbindEntity",
		true
	},
	[MessageName.LOGIC_TIME_UPDATE] = {
		"onLogicTimeUpdate",
		true
	},
	[MessageName.PLAYER_DESTROY] = {
		"onPlayerDestroyed",
		true
	}
}

function MiniMapV2UIComponent:onCtor()
	self.forceHidePlayerArrow = false
	self._markerLayers = {}
	self._markerPoolMap = {}
	self._trackMarkerPoolArray = {}
	self._isOK = false
	self._oldX = nil
	self._oldY = nil
	self._sqrVisibleDis = 0
	self._disArr = {
		0,
		0,
		0,
		0
	}
	self.markIndex = 0
	self.updateDataFrame = 0

	local normalSlot = {}

	for i = 0, ConstUpdateInterval do
		normalSlot[i] = {}
	end

	self._normalSlot = normalSlot
	self.chunkLoaded = {}
	self.chunkChanges = {}
end

function MiniMapV2UIComponent:onUntrackQuestMark(info)
	self:deleteTrackMark(info.questId)
end

function MiniMapV2UIComponent:ontrackQuestMark(info)
	self:manualTrackMark(info.markType, info.questId, info.showPath)
end

function MiniMapV2UIComponent:onMapSystemSpecialStateUpdate(info)
	self:refreshNPCIconBySpecialState(info.staticId)
end

function MiniMapV2UIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.miniMapContainerUContainer = objectReference:GetRefValue("miniMapContainerUContainer")
	self.miniMapUComponent = objectReference:GetRefValue("miniMapUComponent")
	self.playerArrowTransform = objectReference:GetRefValue("playerArrowTransform")
	self.lightArrowTransform = objectReference:GetRefValue("lightArrowTransform")
	self.uINodeMiniMapTransform = objectReference:GetRefValue("uINodeMiniMapTransform")
	self.markPointTrackGroupTransform = objectReference:GetRefValue("markPointTrackGroupTransform")
	self.buttonUButton = objectReference:GetRefValue("buttonUButton")
	self.serverUWidget = objectReference:GetRefValue("serverUWidget")
	self.branchLine = objectReference:GetRefValue("branchLine")
	self.textTextPlus = objectReference:GetRefValue("textTextPlus")
	self.guideAnimation = objectReference:GetRefValue("guideAnimation")
	self.buttonArrowUButton = objectReference:GetRefValue("buttonArrowUButton")
	self.weatherIconUImage = objectReference:GetRefValue("weatherIconUImage")
	self.guideWeatherIconUImage = objectReference:GetRefValue("guideWeatherIconUImage")
	self.buttonWeatherUButton = objectReference:GetRefValue("buttonWeatherUButton")
	self.btnQuitUButton = objectReference:GetRefValue("btnQuitUButton")
	self.countDown = objectReference:GetRefValue("countDown")
end

function MiniMapV2UIComponent:GetLayer(priority)
	if priority == MapHelper.trackPriority then
		return self.markPointTrackGroupTransform
	end

	return self._markerLayers[priority]
end

function MiniMapV2UIComponent:onWeatherRefresh(data)
	local curBlockAreaId = pg.game.map:getCurBlockAreaId()

	if curBlockAreaId == data.blockAreaId then
		self:RefreshWeatherIcon()
		self:showWeatherTips(1)
	end
end

function MiniMapV2UIComponent:showWeatherTips(index)
	if index > 0 and index <= #pg.me.weatherChanged then
		local blockAreaId = pg.me.weatherChanged[index]
		local weatherInfo = pg.me.weatherInfoForecast[blockAreaId][1]
		local curWeatherId = weatherInfo.weatherId
		local showTips = false

		if pg.me.weatherSubscription[blockAreaId] then
			for _, id in pairs(pg.me.weatherSubscription[blockAreaId]) do
				if id == curWeatherId then
					showTips = true

					break
				end
			end
		end

		if showTips then
			local pets = MapBlockConfigData[blockAreaId][self:getWeatherStateName(curWeatherId)]
			local tipsText = ""
			local petInfo = ""

			if pets ~= nil then
				tipsText = ClientTextUtils.getLocalizationText(WeatherData[curWeatherId].push)

				for i = 1, #pets do
					if i ~= 1 then
						petInfo = petInfo .. ","
					end

					petInfo = petInfo .. ClientTextUtils.getLocalizationText(PetData[pets[i]].name)
				end

				tipsText = pg.getFormatText(tipsText, ClientTextUtils.getLocalizationText(MapBlockConfigData[blockAreaId].areaName), petInfo)
			else
				tipsText = ClientTextUtils.getLocalizationText(WeatherData[curWeatherId].noPetPush)
				tipsText = pg.getFormatText(tipsText, ClientTextUtils.getLocalizationText(MapBlockConfigData[blockAreaId].areaName))
			end

			ClientTextUtils.setText(self.textTextPlus, tipsText)
			self.miniMapUComponent:TryChangePage("Prompt", 1)
			UIUtils.PlayAnimation(self.guideAnimation, "UI_Node_MiniMap_Guide_Prompt")
			self.ctrl:startTimer(function()
				UIUtils.PlayAnimation(self.guideAnimation, "UI_Node_MiniMap_Guide_Prompt_Out", function()
					self.miniMapUComponent:TryChangePage("Prompt", 0)
					self:showWeatherTips(index + 1)
				end)
			end, 5)
		end
	else
		pg.me:clearChangedWeather()
	end
end

function MiniMapV2UIComponent:getWeatherStateName(state)
	for key, value in pairs(UIConst.WeatherState) do
		if value == state then
			return key
		end
	end

	return nil
end

function MiniMapV2UIComponent:onShow()
	if pg.game.map.MiniMapV2UIComponentMapReloadedFlag then
		self:onSceneLoaded()

		pg.game.map.MiniMapV2UIComponentMapReloadedFlag = nil
	end
end

function MiniMapV2UIComponent:reloadAll()
	self:findObjectsInner()
end

function MiniMapV2UIComponent:registerObjects()
	return
end

function MiniMapV2UIComponent:bindComponent()
	return
end

function MiniMapV2UIComponent:findObjectsInner()
	if self.onMapReloaded then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_RELOADED, self.onMapReloaded)
	end

	function self.onMapReloaded(data)
		pg.game.map.MiniMapV2UIComponentMapReloadedFlag = true
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_RELOADED, self.onMapReloaded)
end

function MiniMapV2UIComponent:onSceneLoaded()
	if IsNil(self.miniMapContainerUContainer) then
		return
	end

	if not pg.global.scene:isSceneValid() then
		return
	end

	if self.minimapGrabEggAreaComponent then
		self.minimapGrabEggAreaComponent:resetForSceneReload()
	end

	if self.tempMarkPointDataUpdatedEvent then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_UPDATED, self.tempMarkPointDataUpdatedEvent)

		self.tempMarkPointDataUpdatedEvent = nil
	end

	MapHelper.InitSceneCache()
	MapMarkPrefabPoolManager:OnSceneReload()

	function self.tempMarkPointDataUpdatedEvent(data)
		self:tempMarkPointDataUpdated(data)
	end

	self:destroyAllInstances()
	MapMarkPrefabPoolManager:DumpStats("hud_scene_instances_cleared")
	self:loadFactor()
	self:listening()
	self:initViewInner()
	pg.game.map:removeAllTraceTypeMark()
	self:restoreTrackMarksRecord()

	self.hideLeylineTree = false
end

function MiniMapV2UIComponent:destroyLayer(priority)
	local go = self._markerLayers[priority]

	if NotNil(go) then
		GameObject.Destroy(go)
	end

	self._markerLayers[priority] = nil
end

function MiniMapV2UIComponent:destroyAllInstances()
	if self._markerPoolMap then
		for _, v in pairs(self._markerPoolMap) do
			v:dispose()
		end

		self._markerPoolMap = {}

		local normalSlot = {}

		for i = 0, ConstUpdateInterval do
			normalSlot[i] = {}
		end

		self._normalSlot = normalSlot
		self._trackMarkerPoolArray = {}
		self.chunkLoaded = {}
		self.chunkChanges = {}
	end

	for i, layer in ipairs(MapHelper.GetMarkPriorityList()) do
		self:destroyLayer(layer)
	end
end

function MiniMapV2UIComponent:loadFactor()
	local sceneData = SceneData[pg.game.map:convertSceneId(pg.me.space.sceneId)]

	if sceneData ~= nil and sceneData.miniMapImageScale ~= nil then
		DEFAULT_MINIMAP_SCALE_FACTOR = sceneData.miniMapImageScale[1]
		FACTOR_IN_SCALE_AREA = sceneData.miniMapImageScale[2]
	end
end

function MiniMapV2UIComponent:listening()
	return
end

function MiniMapV2UIComponent:_registerNpcDuelSpawnerListeners()
	if self._npcDuelSpawnerEventEmitter then
		return
	end

	local entityMgr = pg.global and pg.global.entityMgr
	local events = entityMgr and entityMgr.eventEmitter

	if not events then
		return
	end

	function self._onNpcDuelSpawnerEnterSpace(entity)
		if not entity then
			return
		end

		self:_refreshNpcDuelMarkBySpawnerState(entity.staticId, true)
	end

	function self._onNpcDuelSpawnerLeaveSpace(entity)
		if not entity then
			return
		end

		self:_refreshNpcDuelMarkBySpawnerState(entity.staticId, false)
	end

	self._npcDuelSpawnerEventEmitter = events

	events:addEventListener(EventConst.ENTITY_ENTER_SPACE, self._onNpcDuelSpawnerEnterSpace)
	events:addEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onNpcDuelSpawnerLeaveSpace)
end

function MiniMapV2UIComponent:_unregisterNpcDuelSpawnerListeners()
	local events = self._npcDuelSpawnerEventEmitter

	if events then
		if self._onNpcDuelSpawnerEnterSpace then
			events:removeEventListener(EventConst.ENTITY_ENTER_SPACE, self._onNpcDuelSpawnerEnterSpace)
		end

		if self._onNpcDuelSpawnerLeaveSpace then
			events:removeEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onNpcDuelSpawnerLeaveSpace)
		end
	end

	self._onNpcDuelSpawnerEnterSpace = nil
	self._onNpcDuelSpawnerLeaveSpace = nil
	self._npcDuelSpawnerEventEmitter = nil
end

function MiniMapV2UIComponent:_refreshNpcDuelMarkBySpawnerState(staticId, spawnerExists)
	if not staticId or staticId == 0 then
		return
	end

	if not self._isOK or not self._markerPoolMap then
		return
	end

	local spawnerData = pg.game.map:getMarkInfo(staticId)

	if not spawnerData or spawnerData.type ~= Const.MAP_CONST.TYPE.DUEL then
		return
	end

	local pool = self._markerPoolMap[staticId]

	if not spawnerExists then
		if pool and pool.gameObject then
			pool.gameObject:SetActiveEx(false)
		end

		return
	end

	self:refreshSpawner(self.sceneId, staticId)
end

function MiniMapV2UIComponent:onClose()
	self:_unregisterNpcDuelSpawnerListeners()
	HudBaseComponent.onClose(self)
end

function MiniMapV2UIComponent:RefreshWeatherIcon()
	local curWeatherId = pg.me:getWeather()

	if curWeatherId == 0 then
		curWeatherId = 1
	end

	local iconURL = WeatherData[curWeatherId].icon
	local blockAreaId = pg.game.map:getCurBlockAreaId()
	local meteorologyId = pg.me:getAreaMeteorology(blockAreaId)

	if meteorologyId ~= 0 then
		iconURL = MeteorologyData[meteorologyId].icon
	end

	if self.weatherIconUImage then
		self.weatherIconUImage.url = iconURL
		self.guideWeatherIconUImage.url = iconURL
	end
end

function MiniMapV2UIComponent:initView()
	self:_registerNpcDuelSpawnerListeners()
	MapMarkPrefabPoolManager:RegisterReclaimProvider(self, function(prefabPath, requiredCount)
		return self:reclaimUnusedMarkPrefabs(prefabPath, requiredCount)
	end)

	function self.buttonUButton.luaClick()
		pg.global.ui.hudV2:commonOpenFunc(Const.FUNCTION_IDS.MAP)
	end

	function self.buttonArrowUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_MAP, {
			openWeather = true,
			forceSceneId = pg.me.space.sceneId
		}, function()
			return
		end)
	end

	function self.buttonWeatherUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_MAP, {
			openWeather = true,
			forceSceneId = pg.me.space.sceneId
		})
	end

	self:showComponent()
	self:onShowInner()
	self:onSceneLoaded()
end

function MiniMapV2UIComponent:initViewInner()
	self.sceneId = pg.game.map:convertSceneId(pg.me.space.sceneId)
	self._lastAnchorX = nil
	self.markMap = pg.me.getSpaceOwnerMapMarkStatusMap and pg.me:getSpaceOwnerMapMarkStatusMap() and pg.me:getSpaceOwnerMapMarkStatusMap() or pg.me.mapMarkStatusMap

	if pg.game.map:checkValidScene(self.sceneId) then
		pg.game.map:loadTotalEnabledMarkTypes(self.sceneId)
		pg.game.map:loadEnabledMarkTypes(self.sceneId)

		local mapMask = self.miniMapContainerUContainer.transform.parent:GetComponent(typeof(CS.UnityEngine.RectTransform))
		local width, height = mapMask:GetSizeDeltaEx()

		self.miniMapContainerUContainer.url = string.format("$UI_Node_MiniMap_%s.prefab", SceneData[self.sceneId].mapImage)
		self.miniMapContainerUContainerReference = self.miniMapContainerUContainer.content:GetComponent("ObjectReference")
		self.detailTransform = self.miniMapContainerUContainerReference:GetRefValue("detailTransform")

		local img = self.detailTransform:GetComponent(typeof(CS.XGUI.UImage))

		if img then
			img.enabled = false
		end

		local imgPro = self.detailTransform:GetComponent(typeof(CS.XGUI.SRenderer.ImagePro))

		if imgPro then
			imgPro.enabled = false
		end

		self.markerListTransform = self.miniMapContainerUContainerReference:GetRefValue("markerListTransform")
		self.fogMapFogGenerator = self.miniMapContainerUContainerReference:GetRefValue("fogMapFogGenerator")

		local tempVec2 = Vector2(0.5, 0.5)

		self.detailTransform.anchorMin = tempVec2
		self.detailTransform.anchorMax = tempVec2
		self.detailTransform.pivot = tempVec2
		self.detailTransform.localPosition = Vector3.constZero
		self.detailTransform.localScale = Vector3.constOne

		local sceneData = SceneData[self.sceneId] or {}
		local mapUISize = sceneData.mapUISize or {
			0,
			0
		}

		self.detailTransform.sizeDelta = Vector2(mapUISize[1], mapUISize[2])
		self.detailChunkingLoad = self.detailTransform:GetComponent("ChunkingLoad")
		self.detailChunkingLoadTrans = self.detailChunkingLoad.transform
		self.detailChunkingLoad.minimapFrameWidth = width - 24
		self.detailChunkingLoad.minimapFrameHeight = height - 24

		local maxDis = math.max(width, height) * 0.5

		self._disArr[3] = maxDis^2
		self._disArr[4] = (maxDis + 10)^2

		self:onChangeMapLayerData()

		self.updateDataFrame = 0
		self._isOK = true
		self._offsetX, self._offsetZ = MapHelper.GetSceneOffset(self.sceneId)
	else
		self._offsetX = 0
		self._offsetZ = 0
		self._isOK = false
		self.miniMapContainerUContainer.url = nil
	end

	self:updateScaleFactor(DEFAULT_MINIMAP_SCALE_FACTOR)

	local hideArrow = self.forceHidePlayerArrow or pg.space and pg.space:isGrabEgg() and pg.me ~= nil and ToBool(pg.me.controlEggId) or false

	self._arrowHiddenByEgg = hideArrow

	LuaUIUtils.setUIViewVisible(self.playerArrowTransform, not hideArrow)
	LuaUIUtils.setUIViewVisible(self.lightArrowTransform, true)

	local childCount = self.markPointTrackGroupTransform.childCount

	for i = childCount - 1, 0, -1 do
		GameObject.Destroy(self.markPointTrackGroupTransform:GetChild(i).gameObject)
	end

	self.npcObjCaches = {}
	self.markTagCaches = {}
	self.scaleFactorNow = nil
	self.markDisplayRefreshLogicTime = nil
	self.tempVec3Sub = Vector3.zero
	self.tempVec3Cross = Vector3.zero
	self.playerPosXInMap = 0
	self.playerPosYInMap = 0
	self.playerCurrentInScaleArea = false
	self.playerCurrentInScaleAreaLastRecord = false
	self.blockAreaTempVec3 = {
		z = 0,
		x = 0
	}
	self.miniMapScaleArea = MapHelper.loadCustomAreaConfigData(self.sceneId)
	self.customMapMarkMap = pg.me.customMapMarkMap
	self.playerEModel = pg.me.eModel

	local _upx, _upy, _upz = self.playerEModel:GetPositionAgentAxisEx(1)

	self.playerAgentTransUp = Vector3.New(_upx, _upy, _upz)
	self.camera = pg.global.cameraMgr.worldCameraInst.transform
	self.playerPos = pg.me:getPosition()
	self.playerChunkIndexX, self.playerChunkIndexZ = nil
	self.sceneMarkPointData = pg.game.map.sceneMarkPointData
	self.sceneMarkPointChunkData = pg.game.map.sceneMarkPointChunkData
	self.tempMarkPointData = pg.game.map.tempMarkPointData

	if self._isOK then
		pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_UPDATED, self.tempMarkPointDataUpdatedEvent)

		self.minimapDynamicMarkComponent = MinimapDynamicMarkComponent.new(self, self.transform, {
			isFixRoot = false
		})

		self:preLoadMapTrackMark()
		self:preLoadMapMark()
		self:loadSavedCustomMark()
		self:loadSavedMarkShare()
		self:loadMovingTargetMark()

		if pg.game.map and pg.game.map.populateSceneMarkPointOverlap then
			pg.game.map:populateSceneMarkPointOverlap()
		end

		pg.game.quest:initQuestHudMark()

		if self.fogMapFogGenerator then
			pg.game.map:registerFogGenerator(self.sceneId, self.fogMapFogGenerator)

			function self.fogMapFogGenerator.chunkDataInitFinished()
				pg.me:tryRefreshMapFog(self.sceneId, function(contentTable)
					pg.game.map:setBitMaskAll(contentTable, self.fogMapFogGenerator, self.sceneId)
				end)
			end
		end
	else
		self:loadMovingTargetMark()
	end

	self:refreshBranchLine()
	self:RefreshWeatherIcon()
	self:refreshGameCountDown()

	if not self.minimapGrabEggAreaComponent then
		self.minimapGrabEggAreaComponent = MinimapGrabEggAreaComponent.new(self, self.transform, {
			isFixRoot = false
		})
	end

	self.minimapGrabEggAreaComponent:init()
end

function MiniMapV2UIComponent:updateScaleFactor(newFactor)
	self.scaleFactor = newFactor

	local factor = 1 / newFactor^2
	local visialeDis = self._disArr[3] * factor
	local disableDis = self._disArr[4] * factor

	self._disArr[1] = visialeDis
	self._disArr[2] = disableDis
	self._lastAnchorX = nil
end

function MiniMapV2UIComponent:GetMarkMapStatus(sceneId, markType, markId)
	if not pg.game.map then
		return Const.MAP_MARK_STATUS_HIDE
	end

	local markInfo = pg.game.map:getMarkInfo(markId)

	if markInfo and markInfo.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		return MapHelper.getRainbowPetMarkStatus(markId)
	end

	if pg.game.map:getTempWhiteListMarkData(markId) then
		return Const.MAP_MARK_STATUS_LOCKED
	end

	if MapHelper.isSpecialMark(markType) then
		return Const.MAP_MARK_STATUS_UNLOCKED
	end

	if markType == Const.MAP_MARK_CLUE then
		if not pg.game.map:isMarkInCurMainScene(markInfo) then
			return Const.MAP_MARK_STATUS_HIDE
		end

		return QuestUtils.getClueMarkStatus(markId) > 0 and Const.MAP_MARK_STATUS_UNLOCKED or Const.MAP_MARK_STATUS_HIDE
	end

	return self.markMap and self.markMap:getStatus(sceneId, markType, markId) or Const.MAP_MARK_STATUS_HIDE
end

function MiniMapV2UIComponent:GetMarkMapStatusEx(markType, markId)
	if not pg.game.map then
		return Const.MAP_MARK_STATUS_HIDE
	end

	local markInfo = pg.game.map:getMarkInfo(markId)

	if markInfo and markInfo.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		return MapHelper.getRainbowPetMarkStatus(markId)
	end

	if pg.game.map:getTempWhiteListMarkData(markId) then
		return Const.MAP_MARK_STATUS_LOCKED
	end

	if MapHelper.isSpecialMark(markType) then
		return Const.MAP_MARK_STATUS_UNLOCKED
	end

	if markType == Const.MAP_MARK_CLUE then
		if not pg.game.map:isMarkInCurMainScene(markInfo) then
			return Const.MAP_MARK_STATUS_HIDE
		end

		return QuestUtils.getClueMarkStatus(markId) > 0 and Const.MAP_MARK_STATUS_UNLOCKED or Const.MAP_MARK_STATUS_HIDE
	end

	return self.markMap and self.markMap:getStatus(pg.game.map.mainSceneId, markType, markId) or Const.MAP_MARK_STATUS_HIDE
end

function MiniMapV2UIComponent:onShowInner()
	if self.uWidget then
		self.uWidget:TryChangePage("MistyForest", 0)
	end

	if self.timer then
		self.ctrl:killTimer(self.timer)

		self.timer = nil
	end

	if self.markDisplayTimer then
		self.ctrl:killTimer(self.markDisplayTimer)

		self.markDisplayTimer = nil
	end

	local interval = IS_MOBILE and 0.2 or 0

	self.timer = self.ctrl:startTimer(function()
		self.updateDataFrame = self.updateDataFrame + 1

		self:startTicking()
	end, interval, true)
	self.markDisplayTimer = self.ctrl:startTimer(function()
		self:startMarkDisplayTick()
		self:checkTrackMarkIsReached()
	end, 1, true)

	self:refreshMinimapVisible()
end

function MiniMapV2UIComponent:onChangeMapLayerData()
	if not self.detailChunkingLoad then
		return
	end

	local mapLayerData = pg.game.map:getMapLayerData(self.sceneId)

	self.detailChunkingLoad:UpdateMapLayer(pg.game.map:convertSceneId(mapLayerData[1]), mapLayerData[2], mapLayerData[3], mapLayerData[4], pg.game.map:getLayerAreaIndexes(mapLayerData[1], mapLayerData[2], mapLayerData[3], mapLayerData[4]))

	if not self._markerPoolMap then
		return
	end

	for id, pool in pairs(self._markerPoolMap) do
		pool:renderInAreaRange(false)
	end
end

function MiniMapV2UIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.Map then
		self:refreshMinimapVisible()
	end
end

function MiniMapV2UIComponent:refreshMinimapVisible()
	local inNpcDuel = pg.me and pg.me.space and pg.me.space:isNpcDuel()
	local visible = pg.game:checkModuleEnable(ClientConst.ModuleKey.Map) and not inNpcDuel

	LuaUIUtils.setUIVisible(self.uWidget, visible)
end

local _checkSpecialAreaInterval = 8

function MiniMapV2UIComponent:startTicking()
	if IsNil(self.playerEModel) then
		return
	end

	if not pg.me then
		return
	end

	if not self._isOK then
		self:refreshPlayerAndLightRotation()
	else
		self.playerPos = pg.me:getPosition()

		local playerChunkIndexX, playerChunkIndexZ = MapHelper.calXAndZKeyEx(self.playerPos[1] + self._offsetX, self.playerPos[3] + self._offsetZ)

		if playerChunkIndexX ~= self.playerChunkIndexX or playerChunkIndexZ ~= self.playerChunkIndexZ then
			self.playerChunkIndexX, self.playerChunkIndexZ = playerChunkIndexX, playerChunkIndexZ

			self:addMarks(playerChunkIndexX, playerChunkIndexZ)
			pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_CHUNK_INDEX_CHANGED, playerChunkIndexX, playerChunkIndexZ)
		else
			local chunk, change = raw_next(self.chunkChanges)

			if chunk then
				self.chunkChanges[chunk] = nil

				if change then
					self:AddMarkPools(chunk)
				else
					self:RemoveMarkPools(chunk)
				end
			end
		end

		self:refreshMiniMapAnchorPosAndPlayerAnchorPos()

		local frame = self.updateDataFrame

		if frame % _checkSpecialAreaInterval == 0 then
			self:checkMiniMapSpecialArea()
		end

		self:updateAndTickAllyMarks()
		self:processBindMarkStatus()
		self:UpdateData()
	end
end

function MiniMapV2UIComponent:refreshMarks()
	local map = pg.game.map
	local x, y = self.playerPosXInMap, self.playerPosYInMap
	local targetSqrtDistance = self.miniMapFieldViewRangeDistance
	local visialeDis = self._disArr[1]
	local disableDis = self._disArr[2]
	local px = self.playerPos[1]
	local pz = self.playerPos[3]
	local arr = self._trackMarkerPoolArray

	if #arr > 0 then
		local upX, upY, upZ = self.playerEModel:GetPositionAgentAxisEx(1)

		self.playerAgentTransUp:Set(upX, upY, upZ)

		local index = self.updateDataFrame % #arr + 1
		local mark = arr[index]
		local pos = map:GetCurrentBindMapMarkPosOriginal(mark.markId)

		if not pos then
			local spawnerTable = mark.spawnerTable

			pos = spawnerTable.markPosition
		end

		local sx = pos[1]
		local sz = pos[3]
		local dx = sx - px
		local dz = sz - pz
		local sqrDistance = dx * dx + dz * dz

		if targetSqrtDistance < sqrDistance then
			mark:SetTrack(true)

			local x, y = self:calTrackMarkPosition(dx, dz, sqrDistance)

			mark:SetXY(x, y)
		else
			mark:SetTrack(false)
		end
	end

	local index = self.updateDataFrame % ConstUpdateInterval
	local arr = self._normalSlot[index]

	for i = 1, #arr do
		local mark = arr[i]
		local ddx, ddy = x - mark.x, y - mark.y
		local dis = ddx * ddx + ddy * ddy
		local old = mark.visible
		local cmpDis = old and disableDis or visialeDis
		local newVisiable = dis < cmpDis
		local changed = old ~= newVisiable

		if changed then
			mark:SetVisible(newVisiable)
		end
	end
end

function MiniMapV2UIComponent:UpdateData()
	self:refreshMarks()

	local dirtys = MapMarkerPool.GetDirtyTable()

	for marker in pairs(dirtys) do
		marker:updateDirty()
	end
end

function MiniMapV2UIComponent:_processOneBindMarkStatus(markId, entityId)
	local pos = MapHelper.GetEntityPos(entityId)

	if pos then
		local spawner = self._markerPoolMap[markId]

		if not spawner then
			local spawnerData = pg.game.map:getMarkInfo(markId)

			if spawnerData and self:checkMarkCondition(markId, spawnerData) then
				spawner = self:generateMarkPool(markId, spawnerData, false)
			end
		end

		if spawner and not spawner.track then
			local x, y = MapHelper.convertPosExCached(pos[1], pos[3], self._offsetX, self._offsetZ, true)

			spawner:SetXY(x, y)
		end
	else
		pg.game.map:unbindEntityPosFromMapMark(markId)
	end
end

function MiniMapV2UIComponent:processBindMarkStatus()
	pg.game.map:BindMapForeach(self._processOneBindMarkStatus, self)
end

local MAP_MARK_ALLY = Const.MAP_MARK_ALLY

function MiniMapV2UIComponent:isMemberControllingEgg(entityId)
	return pg.game.grabEgg ~= nil and pg.game.grabEgg:isEntityControllingEgg(entityId)
end

function MiniMapV2UIComponent:updateAndTickAllyMarks()
	local markerPools = self._markerPoolMap
	local offsetX = self._offsetX
	local offsetZ = self._offsetZ
	local isGrabEgg = pg.space and pg.space:isGrabEgg()
	local obTargetUid = isGrabEgg and pg.space and pg.space.obTargetUid or nil
	local memberInfo

	if isGrabEgg and obTargetUid then
		local teamInfo = pg.me and pg.me:getCurTeamInfo()

		memberInfo = teamInfo and teamInfo.membersInfo or nil
	end

	local removeList

	for markId, info in pairs(self.tempMarkPointData) do
		if info.markType == MAP_MARK_ALLY then
			local isObserving = false

			if isGrabEgg and obTargetUid and memberInfo then
				for uid, v in pairs(memberInfo) do
					if v.entityId == markId then
						if ToBool(obTargetUid[uid]) then
							isObserving = true
						end

						break
					end
				end
			end

			if not isObserving and self:isMemberControllingEgg(markId) then
				isObserving = true
			end

			if isObserving then
				removeList = removeList or {}
				removeList[#removeList + 1] = markId
			else
				local entPos = MapHelper.GetEntityPos(markId)

				if entPos then
					info.markPosition = entPos
				end

				local marker = markerPools[markId]

				if marker then
					local pos = info.markPosition

					if pos then
						local x, y = MapHelper.convertPosExCached(pos[1], pos[3], offsetX, offsetZ, true)

						marker:SetXY(x, y)
					end
				end
			end
		end
	end

	if removeList then
		for i = 1, #removeList do
			local markId = removeList[i]

			pg.game.map:removeTempMark(self.sceneId, markId)
			facade:SendMessageCommand(MessageName.SCENE_MARK_DATA_ALLY_CHANGED, {
				entryAdd = false,
				refEntityId = markId
			})
		end
	end
end

function MiniMapV2UIComponent:startMarkDisplayTick()
	if not pg.me or not pg.me.space then
		return
	end

	local logicTime = pg.me.space.logicTime

	if self.markDisplayRefreshLogicTime == logicTime then
		return
	end

	if not pg.game.map:isCurrentSceneValid() then
		return
	end

	self.markDisplayRefreshLogicTime = logicTime

	for markId, pool in pairs(self._markerPoolMap) do
		if not pool.old.track and pool.cache then
			pool.cache:updateMarkButtonDisplay(logicTime)
		end
	end
end

function MiniMapV2UIComponent:addTrackMarkArray(pool)
	if pool.markType == Const.MAP_MARK_FAST_TARGET then
		return
	end

	self._trackMarkerPoolArray[#self._trackMarkerPoolArray + 1] = pool

	self:removeMarkArray(pool)
end

function MiniMapV2UIComponent:removeTrackMarkArray(pool)
	if pool.markType == Const.MAP_MARK_FAST_TARGET then
		return
	end

	for i, v in ipairs(self._trackMarkerPoolArray) do
		if v == pool then
			table.remove(self._trackMarkerPoolArray, i)
			self:addMarkArray(pool)

			break
		end
	end
end

function MiniMapV2UIComponent:addMarkArray(pool)
	local arr = self._normalSlot[pool.index]

	arr[#arr + 1] = pool
end

function MiniMapV2UIComponent:removeMarkArray(pool)
	local arr = self._normalSlot[pool.index]

	for i, v in ipairs(arr) do
		if v == pool then
			table.remove(arr, i)

			break
		end
	end
end

function MiniMapV2UIComponent:addTrackMark(markType, spawnerId, successCallback, hidePath, duplicateCall)
	local markInfo = pg.game.map:getMarkInfo(spawnerId)

	if markType ~= MAP_MARK_QUEST then
		local pos = markInfo and markInfo.markPosition or nil
		local replaceIcon = markInfo and markInfo.replaceIcon or nil

		pg.game.map:storeTrackMarks(spawnerId, self.sceneId, markType, pos, replaceIcon)
	end

	self:judgeTrackMarks(spawnerId, markType)

	if not self._isOK then
		return
	end

	if markInfo == nil or markInfo.markPosition == nil then
		return
	end

	local pool = self:generateMarkPool(spawnerId, markInfo, false)

	if pool.trackMode then
		return
	end

	pool:SetTrackMode(true)
	self:addTrackMarkArray(pool)

	if markInfo.showOntrail == 1 then
		pg.game.map:addTraceTypeMark(spawnerId)
		self:refreshSpawner(self.sceneId, spawnerId)
	end

	self:refreshQuestTagSpawner(spawnerId)

	if successCallback ~= nil then
		successCallback()
	end

	if LuaUIUtils.useTeamMapMark() then
		local isFastMark = markType == Const.MAP_MARK_FAST_TARGET
		local isSelfCreatedFastMark = isFastMark and markInfo.creatorUid == pg.me.uid

		if not isSelfCreatedFastMark then
			pg.me:trackTeamMapMark(self.sceneId, isFastMark and spawnerId or 0, isFastMark and 0 or spawnerId)
		end
	end

	pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_TRACE_ADD, markType, spawnerId, pg.game.map:getMarkInfo(spawnerId))
	pg.game.map:refreshMapFilterOnTrackChange(self.sceneId)

	if markType ~= MAP_MARK_QUEST then
		if markType == Const.MAP_MARK_GRAB_EGG then
			hidePath = true
		end

		local pos = markInfo.markPosition
		local entPos = pg.game.map:GetCurrentBindMapMarkPosOriginal(spawnerId)

		if entPos then
			pos = entPos
		end

		local isDiffArea, isolatedIslandLinkPos, oriEndPos, isolatedIslandLinkPosAlter = pg.game.map:calDestinationPosition(pos)

		pg.game.map:compareDistanceAtPlayerPos(isDiffArea, oriEndPos, isolatedIslandLinkPos, markInfo.realSceneId, function(overrideStartPosInfo)
			pg.game.navEffect:path(self.sceneId, overrideStartPosInfo.endPos, spawnerId, function()
				return
			end, hidePath, overrideStartPosInfo, duplicateCall, isolatedIslandLinkPos)
		end, isolatedIslandLinkPosAlter)
	end
end

function MiniMapV2UIComponent:deleteTrackMark(spawnerId, successCallback, skipTeamMarkRpc)
	pg.game.map:unStoreTrackMarks(spawnerId)
	pg.game.map:removeTempMarkFromWhiteList(spawnerId)

	if not self._isOK then
		return
	end

	local pool = self._markerPoolMap[spawnerId]

	if not pool then
		return
	end

	if not pool.trackMode then
		return
	end

	pool:SetTrackMode(false)
	self:removeTrackMarkArray(pool)

	local markInfo = pool.spawnerTable

	if markInfo.showOntrail == 1 then
		pg.game.map:removeTraceTypeMark(spawnerId)
		self:refreshSpawner(self.sceneId, spawnerId)
	end

	self:refreshQuestTagSpawner(spawnerId)
	pg.game.map:refreshMapFilterOnTrackChange(self.sceneId)
	pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_TRACE_REMOVE, spawnerId)

	if not skipTeamMarkRpc and LuaUIUtils.useTeamMapMark() then
		local isFastMark = markInfo.markType == Const.MAP_MARK_FAST_TARGET

		pg.me:unTrackTeamMapMark(self.sceneId, isFastMark and spawnerId or 0, isFastMark and 0 or spawnerId)
	end

	if successCallback ~= nil then
		successCallback()
	end

	pg.game.navEffect:unPath(spawnerId, function()
		return
	end)
end

function MiniMapV2UIComponent:refreshQuestTagSpawner(spawnerId)
	local addQuestTag = pg.game.map:getContainMarkSpawnerId(spawnerId)

	if addQuestTag and addQuestTag.questId and addQuestTag.objId then
		local questSpawnerId = QuestUtils.getCombinedId(addQuestTag.questId, addQuestTag.objId)

		self:clearPreviousQuestTagTask(questSpawnerId)
		self:refreshSpawner(self.sceneId, questSpawnerId)
	end
end

function MiniMapV2UIComponent:clearPreviousQuestTagTask(questSpawnerId)
	if not self.markTagCaches or not self.markTagCaches[questSpawnerId] then
		return
	end

	if self.markTagCaches[questSpawnerId].resTaskTagId then
		self.view:cancelUIAsyncTask(self.markTagCaches[questSpawnerId].resTaskTagId)
	end
end

function MiniMapV2UIComponent:checkTrackMarkExists(spawnerId, anyMember)
	if anyMember == nil then
		anyMember = true
	end

	local pool = self._markerPoolMap[spawnerId]

	if pool and pool.trackMode then
		return true
	end

	local isTeamTrack = pg.game.map:isMarkTeamTrack(self.sceneId, spawnerId, anyMember)

	return isTeamTrack
end

function MiniMapV2UIComponent:manualTrackMark(markType, spawnerId, showPath)
	if not self._isOK then
		return
	end

	self:addTrackMark(markType, spawnerId, function()
		return
	end, not showPath)
end

function MiniMapV2UIComponent:addMarks(playerChunkIndexX, playerChunkIndexZ)
	local loaded = self.chunkLoaded
	local changes = self.chunkChanges

	for chunk, load in pairs(changes) do
		if load then
			changes[chunk] = nil
		end
	end

	for _, offset in ipairs(MapHelper.CHUNK_DIRECTION) do
		local x = playerChunkIndexX + offset[1]
		local z = playerChunkIndexZ + offset[2]
		local sceneMarkPointChunkDataX = self.sceneMarkPointChunkData[x]

		if sceneMarkPointChunkDataX then
			local sceneMarkPointChunkDataZ = sceneMarkPointChunkDataX[z]

			if sceneMarkPointChunkDataZ then
				changes[sceneMarkPointChunkDataZ] = true
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

	for spawnerId, spawnerTable in pairs(self.tempMarkPointData) do
		if not self._markerPoolMap[spawnerId] and self:checkMarkCondition(spawnerId, spawnerTable) then
			self:generateMarkPool(spawnerId, spawnerTable, true)
		end
	end
end

function MiniMapV2UIComponent:AddMarkPools(chunk)
	self.chunkLoaded[chunk] = true

	local sceneMarkPointData = self.sceneMarkPointData

	for _, markId in pairs(chunk) do
		local spawnerTable = sceneMarkPointData[markId]

		if self:checkMarkCondition(markId, spawnerTable) then
			self:generateMarkPool(markId, spawnerTable, true)
		end
	end
end

function MiniMapV2UIComponent:RemoveMarkPools(chunk)
	self.chunkLoaded[chunk] = nil

	for _, markId in pairs(chunk) do
		local pool = self._markerPoolMap[markId]

		if pool and not pool.trackMode and not self.tempMarkPointData[markId] and not pg.game.map.bindMap[markId] then
			self:deleteSpawnerEx(markId)
		end
	end
end

local _validMarkTypes = {
	[MAP_MARK_QUEST] = true,
	[Const.MAP_MARK_CUSTOM] = true,
	[Const.MAP_MARK_SHARE] = true,
	[Const.MAP_MARK_ALLY] = true
}

function MiniMapV2UIComponent:checkMarkCondition(spawnerId, spawnerTable)
	local affiliatedCamp = spawnerTable.affiliatedCamp

	if pg.me.tempCamp and affiliatedCamp and next(affiliatedCamp) and not LuaUIUtils.tableContains(affiliatedCamp, 0) and not LuaUIUtils.tableContains(affiliatedCamp, pg.me.tempCamp) then
		return false
	end

	return not self._markerPoolMap[spawnerId] and (spawnerTable.ShoworNot == 1 or spawnerTable.OnlyShowInMinimapResizeArea == 1) and (self:GetMarkMapStatus(self.sceneId, spawnerTable.markType, spawnerId) ~= Const.MAP_MARK_STATUS_HIDE or spawnerTable.markType == Const.MAP_MARK_QUEST or spawnerTable.markType == Const.MAP_MARK_CUSTOM or spawnerTable.markType == Const.MAP_MARK_SHARE or spawnerTable.markType == Const.MAP_MARK_ALLY or spawnerTable.markType == Const.MAP_MARK_GRAB_EGG or spawnerTable.markType == Const.MAP_MARK_GOLD_MONSTER) and spawnerTable.markPosition ~= nil
end

function MiniMapV2UIComponent:generateMarkPool(spawnerId, spawnerTable, updatePos)
	local pool = self._markerPoolMap[spawnerId]

	if not pool then
		pool = MapMarkerPool.new(self, spawnerId, spawnerTable)
		pool.scale = self:GetCurrentMarkPoolScale()
		pool.index = self.markIndex
		self.markIndex = (self.markIndex + 1) % ConstUpdateInterval
		self._markerPoolMap[spawnerId] = pool

		self:addMarkArray(pool)
	end

	if updatePos then
		local mapX, mapY = pg.game.map:convertPos(spawnerTable.markPosition[1], spawnerTable.markPosition[3], spawnerTable.realSceneId, true)

		pool:SetXY(mapX, mapY)
	end

	return pool
end

function MiniMapV2UIComponent:refreshPlayerAndLightRotation()
	local hideArrow = self.forceHidePlayerArrow or pg.space and pg.space:isGrabEgg() and pg.me ~= nil and ToBool(pg.me.controlEggId) or false

	if self._arrowHiddenByEgg ~= hideArrow then
		self._arrowHiddenByEgg = hideArrow

		LuaUIUtils.setUIViewVisible(self.playerArrowTransform, not hideArrow)
	end

	local _, y = self.playerEModel:GetPositionAgentLocalEulerEx()

	if self._arrowY ~= y then
		self.playerArrowTransform:SetLocalEulerAnglesEx(0, 0, -y)

		self._arrowY = y
	end

	local _, cameraY = self.camera:GetLocalEulerAnglesEx()

	if self._cameraY ~= cameraY then
		self.lightArrowTransform:SetLocalEulerAnglesEx(0, 0, -cameraY)

		self._cameraY = cameraY
	end
end

function MiniMapV2UIComponent:refreshMiniMapAnchorPosAndPlayerAnchorPos()
	if not pg.me.space then
		return
	end

	local x, y = MapHelper.posSceneToMapCached(self.playerPos[1], self.playerPos[3], self._offsetX, self._offsetZ)

	self.playerPosXInMap = x
	self.playerPosYInMap = y

	local x1, y1 = MapHelper.calMapUISizeCached(x, y)
	local scaleFactor = self.scaleFactor
	local worldX = MapHelper.posViewToSceneXCached(x + UIConst.MAP_CONST.MINIMAP_UI_RADIUS / scaleFactor, self._offsetX)
	local fvDx = self.playerPos[1] - worldX

	self.miniMapFieldViewRangeDistance = fvDx * fvDx

	if x1 ~= self._lastAnchorX or y1 ~= self._lastAnchorY then
		self._lastAnchorX = x1
		self._lastAnchorY = y1

		self.detailChunkingLoadTrans:SetAnchoredPositionEx(x1 * scaleFactor, y1 * scaleFactor)
	end

	self:refreshPlayerAndLightRotation()

	if self.scaleFactorNow ~= scaleFactor then
		self:UpdateScale(scaleFactor)
	end
end

function MiniMapV2UIComponent:UpdateScale(scaleFactor)
	local afterExtraScale = MINIMAP_ICON_SCALE_COE / scaleFactor
	local scaleRverse = scaleFactor / MINIMAP_ICON_SCALE_COE

	for _, markInfo in pairs(self._markerPoolMap) do
		if NotNil(markInfo.gameObject) then
			markInfo:SetScale(afterExtraScale)
			markInfo:UpdateNoTrackCacheScale(scaleRverse)
		end
	end

	self.detailChunkingLoadTrans:SetLocalScaleEx(scaleFactor, scaleFactor, 1)
	self:adjustNavEffLineWidth()
	self:adjustScale(scaleFactor)

	self.scaleFactorNow = scaleFactor
end

function MiniMapV2UIComponent:GetCurrentMarkPoolScale()
	local afterExtraScale = MINIMAP_ICON_SCALE_COE / self.scaleFactor

	return afterExtraScale
end

function MiniMapV2UIComponent:GetQuestCircleScale(r)
	return r * (self.scaleFactor / MINIMAP_ICON_SCALE_COE) * 2
end

function MiniMapV2UIComponent:scaleMiniMap(factor, isEnter)
	DoTweenAnimMgr.DoFloat(self.detailTransform.gameObject, self.scaleFactor, factor, LuaUIUtils.TweenId(SCALE_MINI_MAP_TWEEN_ID), 0.3, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		for _, v in pairs(self.npcObjCaches) do
			v:SetNpcVisiable(isEnter)
		end
	end, function(fac)
		self:updateScaleFactor(fac)
	end, function()
		return
	end, false)
end

function MiniMapV2UIComponent:AddNpcCache(id, cache)
	self.npcObjCaches[id] = cache
end

function MiniMapV2UIComponent:RemoveNpcCache(id)
	self.npcObjCaches[id] = nil
end

function MiniMapV2UIComponent:checkMiniMapSpecialArea()
	for _, v in pairs(self.miniMapScaleArea) do
		self.playerCurrentInScaleArea = LuaUIUtils.isPointInPoly(self.playerPosXInMap, self.playerPosYInMap, v)

		if self.playerCurrentInScaleArea then
			break
		end
	end

	if self.playerCurrentInScaleAreaLastRecord ~= self.playerCurrentInScaleArea then
		if self.playerCurrentInScaleArea then
			self:scaleMiniMap(FACTOR_IN_SCALE_AREA, true)
		else
			self:scaleMiniMap(DEFAULT_MINIMAP_SCALE_FACTOR, false)
		end

		self.playerCurrentInScaleAreaLastRecord = self.playerCurrentInScaleArea
	end
end

function MiniMapV2UIComponent:IsInScaleArea()
	return self.playerCurrentInScaleArea
end

function MiniMapV2UIComponent:preLoadMapTrackMark()
	self.trackMarkerPool = {}
end

function MiniMapV2UIComponent:_createMarkerLayer(priority)
	local go = GameObject(string.format("Layer%s", priority))

	self._markerLayers[priority] = go

	local rectTrans = go:AddComponent(typeof(CS.UnityEngine.RectTransform))

	rectTrans:SetParent(self.markerListTransform, false)
	rectTrans:SetLocalPositionEx(0, 0, 0)
	rectTrans:SetLocalScaleEx(1, 1, 1)
	rectTrans:SetAnchorMinEx(0, 0)
	rectTrans:SetAnchorMaxEx(1, 1)
	rectTrans:SetSizeDeltaEx(0, 0)
end

function MiniMapV2UIComponent:preLoadMapMark()
	for i, priority in ipairs(MapHelper.GetMarkPriorityList()) do
		self:_createMarkerLayer(priority)
	end
end

function MiniMapV2UIComponent:calTrackMarkPosOnCircle(angle)
	local x = UIConst.MAP_CONST.MINIMAP_UI_RADIUS * Mathf.Cos(angle * Mathf.PI / 180)
	local y = UIConst.MAP_CONST.MINIMAP_UI_RADIUS * Mathf.Sin(angle * Mathf.PI / 180)

	return x, y
end

function MiniMapV2UIComponent:calTrackMarkPosition(dx, dz, sqrDistance)
	local sinVal = self.playerAgentTransUp.y * dz
	local cosVal = dx
	local len = Mathf.Sqrt(sqrDistance + 0.01)
	local radius = UIConst.MAP_CONST.MINIMAP_UI_RADIUS
	local circleX = radius * cosVal / len
	local circleY = radius * sinVal / len

	return circleX, circleY
end

function MiniMapV2UIComponent:refreshSpawner(sceneId, staticId)
	if not self._isOK then
		return
	end

	if sceneId ~= self.sceneId then
		return
	end

	local spawnerData = pg.game.map:getMarkInfo(staticId)

	if not spawnerData or spawnerData.ShoworNot ~= 1 or not spawnerData.markPosition then
		return
	end

	local pool = self:generateMarkPool(staticId, spawnerData, true)

	pool:update()
end

function MiniMapV2UIComponent:reclaimUnusedMarkPrefabs(prefabPath, requiredCount)
	if prefabPath ~= AddressDataConst.UI_MARK_NO_RAYBOX and prefabPath ~= AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON then
		return 0
	end

	if not self._markerPoolMap then
		return 0
	end

	local statsBefore = MapMarkPrefabPoolManager:GetStats(prefabPath)
	local idleBefore = statsBefore and statsBefore.idleCount or 0

	for _, marker in pairs(self._markerPoolMap) do
		local isUnused = marker.gameObject and (not marker.visible or not marker.logicVisiable)
		local targetLease

		if prefabPath == AddressDataConst.UI_MARK_NO_RAYBOX then
			targetLease = marker.rootLease
		elseif prefabPath == AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON then
			targetLease = marker.cache and marker.cache.commonIconLease
		end

		if isUnused and targetLease then
			marker:ChangeVisible()

			local currentStats = MapMarkPrefabPoolManager:GetStats(prefabPath)

			if currentStats and currentStats.idleCount - idleBefore >= (requiredCount or 1) then
				break
			end
		end
	end

	local statsAfter = MapMarkPrefabPoolManager:GetStats(prefabPath)

	return statsAfter and math.max(0, statsAfter.idleCount - idleBefore) or 0
end

function MiniMapV2UIComponent:deleteSpawner(sceneId, staticId)
	if not self._isOK then
		return
	end

	if sceneId ~= self.sceneId then
		return
	end

	self:deleteSpawnerEx(staticId)
end

function MiniMapV2UIComponent:deleteSpawnerEx(staticId)
	local marker = self._markerPoolMap[staticId]

	if marker then
		marker:dispose()
		self:removeTrackMarkArray(marker)
		self:removeMarkArray(marker)

		self._markerPoolMap[staticId] = nil
	end
end

function MiniMapV2UIComponent:loadSavedMarkShare()
	if not pg.game.markShare:shouldShowOwnMediaMarker() then
		return
	end

	local data = {}
	local allChildrenScenes = MapHelper.getAllChildrenScene(self.sceneId)

	for k, v in pairs(pg.me.mediaMarker) do
		if LuaUIUtils.tableContains(allChildrenScenes, pg.game.map:convertSceneId(v.sceneId)) then
			data[#data + 1] = {
				createTs = v.createTs,
				key = k,
				pos = v.pos
			}

			pg.game.map:addOrUpdateTempMark(pg.game.map:convertSceneId(v.sceneId), v.pos[1], v.pos[2], v.pos[3], k, Const.MAP_MARK_SHARE)
		end
	end
end

function MiniMapV2UIComponent:loadSavedCustomMark()
	local allChildrenScenes = MapHelper.getAllChildrenScene(self.sceneId)

	for _, sceneId in pairs(allChildrenScenes) do
		if self.customMapMarkMap[sceneId] then
			for k, v in pairs(self.customMapMarkMap[sceneId]) do
				local id = tonumber(string.format("%s%s%s%s", sceneId, Const.MAP_MARK_CUSTOM, Const.MAP_MARK_CUSTOM, k))

				pg.game.map:addOrUpdateTempMark(sceneId, v.pos[1], v.pos[2], v.pos[3], id, Const.MAP_MARK_CUSTOM, {
					markIconIndex = v.markIconIndex
				})
			end
		end
	end
end

function MiniMapV2UIComponent:loadMovingTargetMark()
	if not self.sceneId then
		return
	end

	if not MapHelper.IsShowTeam(self.sceneId) then
		return
	end

	local memberInfo = pg.me:getCurTeamInfo().membersInfo or {}
	local selfId = pg.me.id
	local isGrabEgg = pg.space and pg.space:isGrabEgg()
	local obTargetUid = isGrabEgg and pg.space and pg.space.obTargetUid or nil

	for memberUid, info in pairs(memberInfo) do
		local entityId = info.entityId

		if entityId ~= selfId then
			local ent = pg.getEntity(entityId)
			local isDead = isGrabEgg and ent and ent:isDead()
			local isObserving = obTargetUid and ToBool(obTargetUid[memberUid])
			local isControllingEgg = self:isMemberControllingEgg(entityId)

			if not isDead and not isObserving and not isControllingEgg then
				local entPos = MapHelper.GetEntityPos(entityId)

				if entPos and not self._markerPoolMap[entityId] then
					pg.game.map:addOrUpdateTempMark(self.sceneId, entPos[1], entPos[2], entPos[3], entityId, Const.MAP_MARK_ALLY)
					facade:SendMessageCommand(MessageName.SCENE_MARK_DATA_ALLY_CHANGED, {
						entryAdd = true,
						refEntityId = entityId
					})
				end
			end
		end
	end

	for markId, mark in pairs(self.tempMarkPointData) do
		if mark.markType == Const.MAP_MARK_ALLY then
			local ent = pg.getEntity(markId)
			local memberUid

			for uid, v in pairs(memberInfo) do
				if v.entityId == markId then
					memberUid = uid

					break
				end
			end

			local isDead = isGrabEgg and ent and ent:isDead()
			local isObserving = isGrabEgg and obTargetUid and memberUid and ToBool(obTargetUid[memberUid])
			local isControllingEgg = self:isMemberControllingEgg(markId)

			if not memberUid or not MapHelper.GetEntityPos(markId) or isDead or isObserving or isControllingEgg then
				pg.game.map:removeTempMark(self.sceneId, markId)
				facade:SendMessageCommand(MessageName.SCENE_MARK_DATA_ALLY_CHANGED, {
					entryAdd = false,
					refEntityId = markId
				})
			end
		end
	end
end

function MiniMapV2UIComponent:onAddInfoStampSuccess(info)
	self:addMarkShare(info.markerId)
end

function MiniMapV2UIComponent:onDeleteInfoStampSuccess(info)
	self:removeMarkShare(info.markerId)
end

function MiniMapV2UIComponent:addMarkShare(markerId)
	if not pg.game.markShare:shouldShowOwnMediaMarker() then
		return
	end

	if pg.game.map:convertSceneId(pg.me.mediaMarker[markerId].sceneId) ~= self.sceneId then
		return
	end

	local pos = pg.me.mediaMarker[markerId].pos

	pg.game.map:addOrUpdateTempMark(self.sceneId, pos[1], pos[2], pos[3], markerId, Const.MAP_MARK_SHARE)
end

function MiniMapV2UIComponent:removeMarkShare(markerId)
	pg.game.map:removeTempMark(self.sceneId, markerId)
end

function MiniMapV2UIComponent:tempMarkPointDataUpdated(data)
	if not self._isOK then
		return
	end

	if data.type == "delete" then
		self:deleteSpawner(self.sceneId, data.id)
	elseif data.type == "addOrUpdate" then
		self:refreshSpawner(self.sceneId, data.id)
		self:autoTrackFastTargetMark(data.id)
	end
end

function MiniMapV2UIComponent:autoTrackFastTargetMark(markId)
	if not LuaUIUtils.checkFastTargetMark() then
		return
	end

	local spawnerData = pg.game.map:getMarkInfo(markId)

	if not spawnerData then
		return
	end

	if spawnerData.markType ~= Const.MAP_MARK_CUSTOM then
		return
	end

	local pool = self._markerPoolMap[markId]

	if not pool or pool.trackMode then
		return
	end

	self:addTrackMark(Const.MAP_MARK_CUSTOM, markId, nil, nil, true)
end

function MiniMapV2UIComponent:onTeamMarkChange()
	if not self._isOK then
		return
	end

	if not pg.game.map:checkValidScene(self.sceneId) then
		return
	end

	self.teamMarkPointData = pg.game.map.teamMarkPointData or {}
	self.teamMarkIds = self.teamMarkIds or {}

	local currentTeamMarkIds = {}

	for markId, markPointData in pairs(self.teamMarkPointData) do
		if markPointData and markPointData.markPosition then
			currentTeamMarkIds[markId] = true

			self:refreshSpawner(self.sceneId, markId)

			local pool = self._markerPoolMap[markId]

			if pool and not pool.trackMode and pg.game.map.trackMarksRecord and pg.game.map.trackMarksRecord[markId] then
				self:judgeTrackMarks(markId, pool.markType)
				pool:SetTrackMode(true)
			end
		else
			self:deleteSpawner(self.sceneId, markId)
		end
	end

	for markId, _ in pairs(self.teamMarkIds) do
		if not currentTeamMarkIds[markId] then
			local pool = self._markerPoolMap[markId]

			if pool and pool.trackMode then
				self:deleteTrackMark(markId)
			end

			self:deleteSpawner(self.sceneId, markId)
		end
	end

	self.teamMarkIds = currentTeamMarkIds
end

function MiniMapV2UIComponent:onTeamMarkTrackChange()
	if not self._markerPoolMap then
		return
	end

	for _, pool in pairs(self._markerPoolMap) do
		if pool.cache then
			pool.cache:renderTeamTrack(pool.markId, pool.spawnerTable)
		end
	end
end

function MiniMapV2UIComponent:restoreTrackMarksRecord()
	if not self._isOK then
		return
	end

	for markId, t in pairs(pg.game.map.trackMarksRecord) do
		if t.sceneId == self.sceneId then
			local markData = pg.game.map:getMarkInfo(markId)

			if markData and markData.infoPage == 2 and self:GetMarkMapStatusEx(t.markType, markId) >= Const.MAP_MARK_STATUS_UNLOCKED then
				-- block empty
			else
				if not markData and (t.markType == Const.MAP_MARK_TRACE or t.markType == Const.MAP_MARK_COUSTOM_TRACE) and t.pos and t.replaceIcon then
					pg.game.map:addOrUpdateTempMark(t.sceneId, t.pos[1], t.pos[2], t.pos[3], markId, t.markType, {
						replaceIcon = t.replaceIcon
					})

					markData = pg.game.map:getMarkInfo(markId)
				end

				if markData then
					self:addTrackMark(markData.markType, markId, nil, nil, true)
				end
			end
		end
	end
end

function MiniMapV2UIComponent:judgeTrackMarks(spawnerId, markType)
	local pool = self._markerPoolMap[spawnerId]

	if pool and pool.trackMode then
		return
	end

	if markType == Const.MAP_MARK_GRAB_EGG then
		return
	end

	local markInfo = pool and pool.spawnerTable or pg.game.map:getMarkInfo(spawnerId)
	local targetTraceType = pool and pool.traceType or pg.game.map:getMarkTraceTypeByConfigId(markInfo and markInfo.markConfigId)
	local questId = {}
	local otherId

	for id, markerPool in pairs(self._markerPoolMap) do
		if markerPool.trackMode and markerPool.markType ~= Const.MAP_MARK_GRAB_EGG then
			if markerPool.markType == MAP_MARK_QUEST then
				questId[#questId + 1] = id
			elseif markerPool.traceType and targetTraceType and markerPool.traceType == targetTraceType then
				otherId = id
			end
		end
	end

	if markType == MAP_MARK_QUEST and #questId >= 99 then
		if not LuaUIUtils.tableContains(questId, spawnerId) then
			self:deleteTrackMark(questId[1])
		end
	elseif markType ~= MAP_MARK_QUEST and otherId and spawnerId ~= otherId then
		local skipUnTrackRpc = markType ~= Const.MAP_MARK_FAST_TARGET

		self:deleteTrackMark(otherId, nil, skipUnTrackRpc)
	end
end

function MiniMapV2UIComponent:checkTrackMarkIsReached()
	local pos = self.playerPos

	if not pos then
		return
	end

	for markId, pool in pairs(self._markerPoolMap) do
		if pool.trackMode then
			local markInfo = pool.spawnerTable

			if pool.markType == MAP_MARK_QUEST then
				if markInfo and Vector3.SqrDistance(markInfo.markPosition, pos) < ClientConst.DIALOGUE_GRAPH_PLAY_APPROXIMATELY_EPS then
					self:deleteTrackMark(markId)
					facade:sendMsgToUI(MessageName.QUEST_ON_TRACK_REACH, {
						questId = markInfo.questId
					})
				end
			elseif markInfo and Vector3.SqrDistance(markInfo.markPosition, pos) < 36 then
				self:deleteTrackMark(markId)
				pg.global.showBubbleMessageById(2124)
			end
		end
	end
end

function MiniMapV2UIComponent:refreshBranchLine()
	local me = pg.me

	if me == nil then
		self.serverUWidget:SetActive(false)

		return
	end

	local space = me.space
	local sceneId = space.sceneId or 3000

	if sceneId == 501 or sceneId == 513 then
		self.serverUWidget:SetActive(true)
	else
		self.serverUWidget:SetActive(false)

		return
	end

	local lineId = space.lineNo
	local cData = MapLineData[space.sceneId]

	if cData == nil then
		return
	end

	local content = string.format(pg.getGameString("MAP_BRANCH_LINE"), pg.getLocalizationText(cData.name), lineId or 0)

	ClientTextUtils.setText(self.branchLine, content)
end

function MiniMapV2UIComponent:onRefreshGameCountDown()
	self:refreshGameCountDown()
end

function MiniMapV2UIComponent:refreshGameCountDown()
	if IsNil(self.countDown) then
		return
	end

	local space = pg.me and pg.me.space
	local mainSceneId = space and (space.masterDungeonSceneId or space.sceneId) or 0

	if space and space:isGrabEgg() and (mainSceneId ~= Const.ROB_EGG_SCENE_CLIP_ID or pg.me.observeTargetUid ~= nil) then
		self.countDown:SetActive(true)
	else
		self.countDown:SetActive(false)

		return
	end

	local endTime = pg.me.space.end_ts
	local remandTime = math.max(0, endTime - Time.secondCache)

	self.countDown:Play(remandTime)
end

function MiniMapV2UIComponent:refreshNPCIconBySpecialState(staticId)
	self:refreshSpawner(self.sceneId, staticId)
end

function MiniMapV2UIComponent:drawNavEffLine(info)
	self:destroyNavEffLine()

	if not info.path then
		return
	end

	if not self._isOK or IsNil(self.markerListTransform) then
		return
	end

	local path = info.path
	local vec2Table = {}

	for i = 1, #path do
		local pos = path[i]
		local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], info.sceneId, true)

		vec2Table[#vec2Table + 1] = Vector2(mapX, mapY)
	end

	self.taskId = self.view:addPrefabWithPathAsync(self.markerListTransform, AddressDataConst.MAP_LINE_DRAWER, function(obj)
		self.taskObj = obj.gameObject

		obj.gameObject.transform:SetSiblingIndex(0)

		local objectReference = obj.gameObject:GetComponent("ObjectReference")
		local lineDrawerULineDrawer = objectReference:GetRefValue("lineDrawerULineDrawer")

		lineDrawerULineDrawer:SetPoints(vec2Table)
		lineDrawerULineDrawer:SetWidth(30 / self.scaleFactor)
	end, true)
end

function MiniMapV2UIComponent:destroyNavEffLine()
	if self.taskId then
		self.view:cancelUIAsyncTask(self.taskId)

		self.taskId = nil
	end

	if self.taskObj then
		self.view:destroyInstance(self.taskObj)

		self.taskObj = nil
	end
end

function MiniMapV2UIComponent:adjustNavEffLineWidth()
	if self.taskObj then
		local objectReference = self.taskObj:GetComponent("ObjectReference")
		local lineDrawerULineDrawer = objectReference:GetRefValue("lineDrawerULineDrawer")

		lineDrawerULineDrawer:SetWidth(30 / self.scaleFactor)
	end
end

function MiniMapV2UIComponent:onGrabEggAreaAdd(info)
	if self.minimapGrabEggAreaComponent then
		self.minimapGrabEggAreaComponent:instantiateAppearArea(info.areaData.id, info.areaData)
	end
end

function MiniMapV2UIComponent:onGrabEggAreaRemove(info)
	if self.minimapGrabEggAreaComponent then
		self.minimapGrabEggAreaComponent:destroyAppearArea(info.id)
	end
end

function MiniMapV2UIComponent:adjustScale(currentZoom)
	local comp = self.minimapGrabEggAreaComponent

	if comp then
		comp:adjustScale(currentZoom)
	end
end

function MiniMapV2UIComponent:onDestroy()
	self:_unregisterNpcDuelSpawnerListeners()
	MapMarkPrefabPoolManager:UnregisterReclaimProvider(self)
	HudBaseComponent.onDestroy(self)
	self:clearPlayerReferences()

	if self.onMapReloaded then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_RELOADED, self.onMapReloaded)

		self.onMapReloaded = nil
	end

	if self.tempMarkPointDataUpdatedEvent then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_UPDATED, self.tempMarkPointDataUpdatedEvent)

		self.tempMarkPointDataUpdatedEvent = nil
	end

	for id, pool in pairs(self._markerPoolMap) do
		pool:dispose()
	end

	MapMarkPrefabPoolManager:DumpStats("hud_destroy")

	self._trackMarkerPoolArray = nil
	self._normalSlot = nil
	self._markerPoolMap = nil

	if self.timer then
		self.ctrl:killTimer(self.timer)

		self.timer = nil
	end

	if self.markDisplayTimer then
		self.ctrl:killTimer(self.markDisplayTimer)
	end

	self.markDisplayTimer = nil
	self.markTagCaches = nil
	self.npcObjCaches = nil
	self.chunkLoaded = nil
	self.chunkChanges = nil
	self.playerAgentTransUp = nil
	self.camera = nil

	if self.minimapGrabEggAreaComponent then
		self.minimapGrabEggAreaComponent:destroy()

		self.minimapGrabEggAreaComponent = nil
	end

	if self.minimapDynamicMarkComponent then
		self.minimapDynamicMarkComponent:destroy()

		self.minimapDynamicMarkComponent = nil
	end

	if self.fogMapFogGenerator then
		pg.game.map:unregisterFogGenerator(self.fogMapFogGenerator)

		self.fogMapFogGenerator = nil
	end
end

function MiniMapV2UIComponent:clearPlayerReferences()
	self.markMap = nil
	self.customMapMarkMap = nil
	self.playerEModel = nil
	self.playerPos = nil
end

function MiniMapV2UIComponent:onPlayerDestroyed()
	self:clearPlayerReferences()
end

function MiniMapV2UIComponent:onDynamicMarkStatusChanged(info)
	if self.minimapDynamicMarkComponent then
		self.minimapDynamicMarkComponent:onDynamicMarkStatusChanged(info)
	end
end

function MiniMapV2UIComponent:onMapMarkUnbindEntity(info)
	if not info or not info.markId then
		return
	end

	self:UpdateMarkPosition(info.markId)
end

function MiniMapV2UIComponent:onLogicTimeUpdate(logicTime)
	if not self.miniMapUComponent then
		return
	end

	self.miniMapUComponent:TryChangePage("Time", pg.timePeriod == Const.TimePeriod.Night and 2 or 1)
end

function MiniMapV2UIComponent:SetMarkLogicVisiable(markId, isEnable)
	local mark = self._markerPoolMap[markId]

	if mark and not mark.trackMode then
		mark:SetLogicVisible(isEnable)
	end
end

function MiniMapV2UIComponent:UpdateMarkPosition(markId)
	local spawnerData = pg.game.map:getMarkInfo(markId)

	if not spawnerData then
		return
	end

	local spawner = self._markerPoolMap[markId]

	if spawner then
		local x, y = pg.game.map:convertPos(spawnerData.markPosition[1], spawnerData.markPosition[3], self.sceneId, true)

		spawner:SetXY(x, y)

		return true
	end

	return false
end

function MiniMapV2UIComponent:updateMapFilter(sceneId)
	for id, pool in pairs(self._markerPoolMap) do
		pool:updateMapFilter(sceneId)
	end
end

function MiniMapV2UIComponent:updateTotalFilter(sceneId)
	for id, pool in pairs(self._markerPoolMap) do
		pool:updateTotalFilter(sceneId)
	end
end

function MiniMapV2UIComponent:isTrack(markId)
	local mark = self._markerPoolMap[markId]

	return mark and mark.trackMode
end

function MiniMapV2UIComponent:onBattleStateChange(state)
	if self._battleState ~= state then
		self._battleState = state

		self.miniMapUComponent:TryChangePage("InBattle", state or 0)
	end
end

function MiniMapV2UIComponent:onFlowerStateChanged(info)
	self:refreshSpawner(self.sceneId, info.leylineFlowerId)
end

function MiniMapV2UIComponent:onPlentyCircleChanged(info)
	if not info.leylineFlowerId then
		return
	end

	self:refreshSpawner(self.sceneId, info.leylineFlowerId)
end

function MiniMapV2UIComponent:onDuelStateChanged(info)
	local relatedMarks = MapUtils.getDuelIdRelatedMarkIds(info.npcDuelId or -1)

	for _, markId in pairs(relatedMarks) do
		self:refreshSpawner(self.sceneId, markId)
	end
end

return MiniMapV2UIComponent
