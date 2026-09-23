-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\MapCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local UICtrl = require("Guis.UICtrl")
local lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local MapCtrl = Class.LightClass("MapCtrl", UICtrl)
local ClientUtils = require("Utils.ClientUtils")
local SceneData = require("Data.scene_data")
local MapOverlapScene = require("Data.map_overlap_scene")
local MapAreaConfigData = require("Data.map_area_config_data")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local Const = require("Common.Const.Const")
local MapUtils = require("Guis.Utils.MapUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local GrabEggMapMarkUtils = require("GameApp.GrabEgg.GrabEggMapMarkUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MapLevelConfigLoadData = require("Data.map_level_config_load_data")
local UIConst = require("Const.UIConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local mapFogManager = CS.FunPlus.WorldX.GameApp.UIMap.MapFogManager
local HotkeyConst = require("Const.HotkeyConst")
local UIObjectPool = require("Utils.UIObjectPool")
local MapMarkPrefabPoolManager = require("Guis.Utils.MapMarkPrefabPoolManager")
local MapMarkFilterComponent = require("Guis.Panels.Map.Component.MapMarkFilterComponent")
local MarkBubbleComponent = require("Guis.Panels.Map.Component.MarkBubbleComponent")
local MapBlockListComponent = require("Guis.Panels.Map.Component.MapBlockListComponent")
local GrabEggAreaComponent = require("Guis.Panels.Map.Component.GrabEggAreaComponent")
local DynamicMarkComponent = require("Guis.Panels.Map.Component.Item.DynamicMarkComponent")
local TransLocationListComponent = require("Guis.Panels.Map.Component.TransLocationListComponent")
local BitMaskComponent = require("Guis.Panels.Map.Component.BitMaskComponent")
local MapNavLineComponent = require("Guis.Panels.Map.Component.MapNavLineComponent")
local MapLeftTopTipsComponent = require("Guis.Panels.Map.Component.MapLeftTopTipsComponent")
local MapPetAreaComponent = require("Guis.Panels.Map.Component.MapPetAreaComponent")
local MapAreaOverlayComponent = require("Guis.Panels.Map.Component.MapAreaOverlayComponent")
local PetDistributionComponent = require("Guis.Panels.Map.Component.PetDistributionComponent")
local LayerComponent = require("Guis.Panels.Map.Component.LayerComponent")
local SysConfigData = require("Data.sys_config_data")
local json = require("json")
local AbilityParamData = require("Data.ability_param_data")
local TeleportMarkEventData = require("Data.teleport_mark_event_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapLevelConfigData = require("Data.map_level_config_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local SceneLeylineTreeAreaData = require("Data.scene_leylineTree_area_data")
local WeatherData = require("Data.weather_data")
local MeteorologyData = require("Data.meteorology_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local GmToolUtils = require("Utils.GmToolUtils")
local HomeCampData = require("Data.home_camp_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Utils = require("Common.Utils.Utils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local NoticeDef = require("Common.NoticeDef")
local MapHelper = require("GameApp.Map.MapHelper")
local PuppetData = require("Data.puppet_data")
local Time = require("Core.Common.Time")
local EventConst = require("Const.EventConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local SocialPartyData = require("Data.social_party_data")
local TimeUtils = require("Common.Utils.TimeUtils")

require("Guis.Panels.Map.Partials.MapCtrlPartial1")(MapCtrl)

local SceneUtils = require("Common.Utils.SceneUtils")
local AudioConst = require("Const.AudioConst")
local SocialConst = require("Common.Const.SocialConst")
local MAP_SCROLL_SCALE_TWEEN_ID = "mapScrollRectRectTransformScale"
local ANCHOR_POSITION_MOVE_TWEEN_ID = "anchorPositionMove"
local MAP_GAMEPAD_MOVE_SPEED = UIConst.MAP_CONST.GAMEPAD_MOVE_PIXELS_PER_FRAME_AT_60_FPS * 60
local MAP_GAMEPAD_MOVE_DEADZONE = 0.15
local MAP_GAMEPAD_BOUNDARY_EPSILON = 0.0001
local MAP_GAMEPAD_SCALE_DEADZONE = 0.3
local MAP_GAMEPAD_SNAP_RADIUS = 36
local GameObject = GameObject
local TEA_PARTY_MAP_POINT_ID = 90882417
local SOCIAL_PARTY_VOXEL_ITEM_ID = 700034
local VISIBLE_MARK_LOAD_BATCH = 64
local MAP_MARK_FRAME_LOAD_MAX_COUNT = 10
local MAP_MARK_FRAME_SCAN_MAX_COUNT = 128
local NORMAL_MARK_MAX_ACTIVE_DEFAULT = 160
local NORMAL_MARK_MAX_ACTIVE_MOBILE = 80
local RECYCLE_VIEWPORT_PADDING = 0.5
local LEYLINE_FLOWER_QUALITY_VX_DURATION = 5
local LEYLINE_FLOWER_QUALITY_VX_URLS = {
	"$VX_Node_WorldMap_01White.prefab",
	"$VX_Node_WorldMap_02Green.prefab",
	"$VX_Node_WorldMap_03Blue.prefab",
	"$VX_Node_WorldMap_04Purple.prefab",
	"$VX_Node_WorldMap_05Orange.prefab"
}

local function getPlatformMaxActiveMarks()
	local platform = pg.global and pg.global.platform

	if platform and platform.isMobile and platform:isMobile() then
		return NORMAL_MARK_MAX_ACTIVE_MOBILE
	end

	return NORMAL_MARK_MAX_ACTIVE_DEFAULT
end

MapCtrl.messages = {
	[MessageName.SCENE_MARK_DATA_ALLY_CHANGED] = {
		"syncMovingTargetMark",
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
	[MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED] = {
		"onHomeCampDispatchStateChanged",
		true
	},
	[MessageName.ON_REQUEST_SELF_MARK_INFO] = {
		"onRequestSelfMarkInfo",
		true
	},
	[MessageName.WEATHER_REFRESH] = {
		"onWeatherRefresh",
		true
	},
	[MessageName.LEYLINE_MAP_RAINBOW_CHANGED] = {
		"onMapRainbowChanged",
		true
	},
	[MessageName.SCENE_MARK_DATA_ALLY_CHANGED] = {
		"onAllyChanged",
		true
	},
	[MessageName.PET_AREA_REWARD_CHANGE] = {
		"onPetAreaRewardChange",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onMoneyNumChange",
		true
	},
	[MessageName.USE_LIMIT_MAP_CHANGE] = {
		"onUseLimitMapChange",
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
	[MessageName.ON_MAP_MARK_UNBIND_ENTITY] = {
		"onMapMarkUnbindEntity",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChange",
		true
	},
	[MessageName.TEAM_MARK_CHANGE] = {
		"onTeamMarkChange",
		true
	},
	[MessageName.TEAM_MARK_TRACK_CHANGE] = {
		"onTeamMarkTrackChange",
		true
	}
}

function MapCtrl:changeMap(sceneId, info)
	self:destroy()
	self.view:unloadMapGO()
	self.view:insertSceneId(sceneId)
	self:listener()
	self:create(info, sceneId)
	self.view.blockRayboxUWidget.gameObject:SetActiveEx(true)
	self:startTimer(function()
		self.view.mapScrollRectRectTransform.localScale = Vector3.one * 0.95

		DoTweenAnimMgr.Scale(self.view.mapScrollRectRectTransform, LuaUIUtils.TweenId(MAP_SCROLL_SCALE_TWEEN_ID), Vector3.one, 0.5, 0, CS.DG.Tweening.Ease.__CastFrom(10), function()
			return
		end)
		UIUtils.PlayAnimation(self.view.vXMapAnimation, "VX_WorldMap_VxMap", function()
			self.view.vXMapAnimation.gameObject:SetActiveEx(false)
			self.view.blockRayboxUWidget.gameObject:SetActiveEx(false)

			if #self.mapSwitchDelayCallbacks > 0 then
				for _, callback in ipairs(self.mapSwitchDelayCallbacks) do
					if callback then
						callback()
					end
				end

				self.mapSwitchDelayCallbacks = {}
			end
		end)
	end, 1, false)
end

function MapCtrl:checkOpenExtra(info)
	local notOpenFuncInfo = pg.getGameString("FUNC_NOT_AVAILABLE")
	local currentSceneId = pg.me and pg.me.space and pg.me.space.sceneId

	if currentSceneId == nil then
		return false, notOpenFuncInfo
	end

	local currentConvertedId = pg.game.map:convertSceneId(currentSceneId)
	local currentHasMap = currentConvertedId and pg.game.map:checkValidScene(currentConvertedId)

	if not currentHasMap and not MapHelper.checkMapForceOpen(currentSceneId) then
		return false, notOpenFuncInfo
	end

	if info ~= nil and info.forceSceneId ~= nil then
		local targetConvertedId = pg.game.map:convertSceneId(info.forceSceneId)

		if not targetConvertedId or not pg.game.map:checkValidScene(targetConvertedId) then
			return false, notOpenFuncInfo
		end
	end

	return true
end

function MapCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petCollectEffect = {}
	self.onMarkLoadedManualCallback = {}

	if info ~= nil and (info.openWeather ~= nil or true) then
		self.openWeather = info.openWeather
		self.tempFilter = info.tempFilter

		if self.tempFilter ~= nil then
			self.tempFilterFlag = true
		end
	end

	local currentSceneId = self:_getCurrentSpaceSceneId()

	if info ~= nil and info.forceSceneId ~= nil and (currentSceneId == nil or pg.game.map:convertSceneId(currentSceneId) ~= pg.game.map:convertSceneId(info.forceSceneId)) then
		self.view:unloadMapGO()

		local convertedSceneId = pg.game.map:convertSceneId(info.forceSceneId)

		self.view:insertSceneId(convertedSceneId)
		self:create(info, convertedSceneId)
	else
		if currentSceneId == nil then
			return
		end

		local convertedSceneId = pg.game.map:convertSceneId(currentSceneId)

		self:create(info, convertedSceneId)
	end
end

function MapCtrl:_getCurrentSpaceSceneId()
	local me = pg.me

	if me ~= nil then
		local space = me.space

		if space ~= nil then
			return space.sceneId
		end
	end

	local space = pg.space

	if space ~= nil and space.sceneId ~= nil then
		return space.sceneId
	end

	return pg.global.scene.targetSceneId
end

function MapCtrl:_getMiniMapComponent()
	local miniMap = pg.game.map:GetMiniMapUI()

	if miniMap and miniMap._markerPoolMap then
		return miniMap
	end
end

function MapCtrl:_checkTrackMarkExists(spawnerId, anyMember)
	if not spawnerId then
		return false
	end

	if pg.game.map.curTraceMark and pg.game.map.curTraceMark[spawnerId] then
		return true
	end

	if pg.game.map.trackMarksRecord and pg.game.map.trackMarksRecord[spawnerId] then
		return true
	end

	local miniMap = self:_getMiniMapComponent()

	if miniMap then
		return miniMap:checkTrackMarkExists(spawnerId, anyMember)
	end

	if anyMember == nil then
		anyMember = true
	end

	return pg.game.map:isMarkTeamTrack(self.sceneId, spawnerId, anyMember)
end

function MapCtrl:onInputDeviceChange()
	pg.global.ui:refreshLockCursor()
	self:RefreshMapVirtualMouseState()
end

function MapCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation then
		local inNavModal = pg.global.navMgr and pg.global.navMgr:IsInModalGroup()
		local focusPetDistribution = pg.global.navMgr.CurrentFocusedGroupName == "MapPetDistributionTop"

		if focusPetDistribution and inNavModal then
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_ChangePet", true)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Choose", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_ChoosePath", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Scroll", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Rule", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_LeftStickMove", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Mark", false)
			CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_RightStickMove", false)

			return
		end

		local rightPanelEnable = self:isRightInfoPanelOpen()
		local chooseListEnable = self.view.chooseList.gameObject and self.view.chooseList.gameObject.activeSelf
		local sortFloatEnable = self.view.sortFloatUComponent.gameObject and self.view.sortFloatUComponent.gameObject.activeSelf

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Choose", rightPanelEnable or chooseListEnable or sortFloatEnable)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_ChoosePath", false)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Scroll", true)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Rule", false)

		local mouseEnable = self:GetMapVirtualMouseState()

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_LeftStickMove", mouseEnable)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_Mark", mouseEnable)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_RightStickMove", mouseEnable)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_WorldMap_ConsoleBar_ChangePet", false)
	end
end

function MapCtrl:onMapRainbowChanged()
	if not self.sceneMarkPointData or not self.markCaches or not self.weatherEffectParent then
		return
	end

	for markId, mark in pairs(self.sceneMarkPointData) do
		if mark.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID and (not pg.space or pg.space.sceneId ~= (mark.realSceneId or self.sceneId)) then
			self:onMapMarkStatusUpdated({
				id = markId
			})
		end
	end

	for blockId in pairs(self.weatherEffectParent) do
		if not pg.space or pg.space.sceneId ~= MapHelper.getAreaSceneId(blockId) then
			self:refreshAreaWeatherEffect(blockId)
		end
	end

	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:RefreshWeather()
	end

	local mark = self.sceneMarkPointData[self.locationInfoPanelCurMarkId]
	local cache = self.markCaches[self.locationInfoPanelCurMarkId]

	if mark and cache and self.view.locationInfo.gameObject.activeSelf and mark.markConfigId == Const.MAP_MARK_LEYLINETREE_TRANSMIT and cache.markStatus >= Const.MAP_MARK_STATUS_UNLOCKED and pg.game.leylineTree:checkLeylineTreeUnlockedBySmallAreaId(mark.largeAreaId) then
		self.weatherTaskContainer = self.weatherTaskContainer or {}

		MapUtils.renderLeylineClusterMapInfoPanel(self.view.locationInfo:GetComponent("ObjectReference"), mark, self.weatherTaskContainer, self)
	end
end

function MapCtrl:onWeatherRefresh(data)
	local curBlockAreaId = pg.game.map:getCurBlockAreaId()

	if self.mapPetAreaComponent and curBlockAreaId == data.blockAreaId then
		self.mapPetAreaComponent:RefreshWeather()
	end

	self:refreshAreaWeatherEffect(data.blockAreaId)
end

function MapCtrl:refreshAreaWeatherEffect(smallAreaId)
	local lastTasks = self.weatherTaskInfo[smallAreaId]

	if lastTasks then
		for _, taskId in ipairs(lastTasks) do
			pg.global.resMgr:TryCancelGOLoadAsyncTask(taskId)
		end
	end

	local lastEffects = self.weatherInfo[smallAreaId]

	if lastEffects then
		for _, effect in ipairs(lastEffects) do
			pg.global.resMgr:RemoveInstanceToCache(effect)
		end
	end

	self.weatherTaskInfo[smallAreaId] = {}
	self.weatherInfo[smallAreaId] = {}

	local layoutInfoRectTransform = self.weatherEffectParent[smallAreaId]
	local meteorologyId = MapHelper.getAreaMeteorology(smallAreaId)

	if meteorologyId > 0 and MeteorologyData[meteorologyId] then
		local taskId = pg.global.resMgr:GetInstanceFromCacheByLua(MeteorologyData[meteorologyId].effect, function(obj, data)
			obj.transform.localPosition = Vector3.constZero

			table.insert(self.weatherInfo[smallAreaId], obj)
		end, 1, nil, layoutInfoRectTransform, false)

		table.insert(self.weatherTaskInfo[smallAreaId], taskId)
	end

	local weatherId = MapHelper.getWeatherByAreaId(smallAreaId)

	if WeatherData[weatherId] then
		local taskId = pg.global.resMgr:GetInstanceFromCacheByLua(WeatherData[weatherId].effect, function(obj, data)
			obj.transform.localPosition = Vector3.constZero

			table.insert(self.weatherInfo[smallAreaId], obj)
		end, 1, nil, layoutInfoRectTransform, false)

		table.insert(self.weatherTaskInfo[smallAreaId], taskId)
	end

	if self.petCollectEffect[smallAreaId] then
		self.petCollectEffect[smallAreaId]:TryChangePage("PetShake", self.model:hasSpecialPetInArea(smallAreaId) and 1 or 0)
	end
end

function MapCtrl:generateFog()
	if not self.view or not self.view.mapScrollContent then
		return
	end

	local fogTrans = self.view.mapScrollContent:Find("Fog")

	if not fogTrans then
		return
	end

	self.mapFogGenerator = fogTrans:GetComponent("MapFogGenerator")

	pg.game.map:registerFogGenerator(MapHelper.getRootScene(self.sceneId), self.mapFogGenerator)

	function self.mapFogGenerator.chunkDataInitFinished()
		pg.me:tryRefreshMapFog(MapHelper.getRootScene(self.sceneId), function(contentTable)
			pg.game.map:setBitMaskAll(contentTable, self.mapFogGenerator, MapHelper.getRootScene(self.sceneId))

			local chunkingLoad = fogTrans:GetComponent("ChunkingLoad")

			if chunkingLoad then
				chunkingLoad:FillTextureToFog()
			end
		end)
	end

	self:displayMapFog(pg.me.mapFogContentDisplayFlag)
end

function MapCtrl:create(info, sceneId)
	self.sceneId = sceneId
	self.mapMarkLoadStopped = false
	self.leylineFlowerQualityVxVersion = (self.leylineFlowerQualityVxVersion or 0) + 1
	self.pendingLeylineFlowerQualityVx = nil
	self.activeLeylineFlowerQualityVxFlowerId = nil
	self.activeLeylineFlowerQualityVxRoot = nil
	self.activeLeylineFlowerQualityVxContainer = nil
	self.leylineFlowerQualityVxTimer = nil
	self.mapDragging = false
	self.touchStart2Fingers = false
	self.touchCount = 0
	self.view.mapScroll.zoomTool.disableZoomWhileDragging = false

	self.view.mapScroll:SetDragEventEnabled(true)

	self.markMap = pg.me:getSpaceOwnerMapMarkStatusMap() or pg.me.mapMarkStatusMap
	self.curSelectedBtn = {}
	self.mapLayerData = pg.game.map:getMapLayerData(self.sceneId)

	self:generateFog()

	self.tempVec2MarkPosTemp = Vector2.zero
	self.onMarkLoaded = info and info.onMarkLoaded
	self.openLocateIntent = info and (info.onMarkLoaded ~= nil or info.tempFilter ~= nil) or false
	self.mapMarkFilterComponent = MapMarkFilterComponent.new(self)
	self.grabEggAreaComponent = GrabEggAreaComponent.new(self)
	self.dynamicMarkComponent = DynamicMarkComponent.new(self)
	self.transLocationListComponent = TransLocationListComponent.new(self)
	self.bitMaskComponent = BitMaskComponent.new(self)
	self.mapAreaOverlayComponent = MapAreaOverlayComponent.new(self, nil, {
		selectedSceneId = sceneId
	})
	self.MapLeftTopTipsComponent = MapLeftTopTipsComponent.new(self)
	self.layerComponent = LayerComponent.new(self)
	self.mapVirtualMouseField = self.view.virtualMouseField

	if self.mapVirtualMouseField then
		self.Handle = self.mapVirtualMouseField.transform:GetChild(0)
		self.HandleAnim = self.Handle and self.Handle:GetComponent("Animation")
		self.HoverInAnimClip = "VX_Prefab_WorldMap_VirtualMouseField_Hover_In"
		self.HoverOutAnimClip = "VX_Prefab_WorldMap_VirtualMouseField_Hover_Out"

		local function setHandleAnimationWrapMode(clipName)
			if not self.HandleAnim then
				return
			end

			local animationState = self.HandleAnim[clipName]

			if animationState then
				animationState.wrapMode = CS.UnityEngine.WrapMode.ClampForever
			end
		end

		setHandleAnimationWrapMode(self.HoverInAnimClip)
		setHandleAnimationWrapMode(self.HoverOutAnimClip)
		self.mapVirtualMouseField:Init(pg.global.uiMgr.uiCamera, pg.global.uiMgr.uiRootCanvasRt, 1)
		self.mapVirtualMouseField:SetMaxSnapDistance(MAP_GAMEPAD_SNAP_RADIUS)
		self.mapVirtualMouseField:SetSnapCenterRearmDistance(MAP_GAMEPAD_SNAP_RADIUS)
		self.mapVirtualMouseField:SetHoverCallback(function()
			if self.HandleAnim then
				self.HandleAnim:Play(self.HoverInAnimClip)
			end
		end, function()
			if self.HandleAnim then
				self.HandleAnim:Play(self.HoverOutAnimClip)
			end
		end)
		pg.global.uiMgr:AddVirtualMouseField(self.mapVirtualMouseField)
		pg.global.navMgr:AddLuaHotkeyActivationChangedListener("UI_MapCtrl_FocusChanged", function()
			self:RefreshMapVirtualMouseState()
			self:refreshConsoleBarState()
		end)
		self:RefreshMapVirtualMouseState()
	end

	local sceneData = SceneData[self.sceneId] or {}

	if not sceneData.hideNormalMapInfo then
		self.mapPetAreaComponent = MapPetAreaComponent.new(self, nil, {
			selectedSceneId = sceneId
		})
		self.petDistributionComponent = PetDistributionComponent.new(self)
	end

	if sceneData.mapFogBlock == 1 then
		self.mapFogBlock = true
	end

	self.layerComponent:setListData(self.sceneId, nil, true)

	self.isUnlockArea = info and info.isUnlockArea or nil
	self.showDistribution = info and info.showDistribution or nil
	self.distributionShowTab = info and info.distributionShowTab or nil
	self.resetDistributionShowTab = info and info.resetDistributionShowTab or nil
	self.isFromLeylineFlowerPlenty = info and info.isFromLeylineFlowerPlenty or nil
	self.focusSmallArea = info and info.focusSmallArea or nil

	if self.focusSmallArea == -1 then
		local blockId = pg.game.map:getCurBlockAreaId()

		self.focusSmallArea = blockId
	end

	self:initGesture()
	self:showFilter(true)

	self.mapAreas = {}
	self.weatherInfo = {}
	self.weatherTaskInfo = {}
	self.weatherEffectParent = {}
	self.petAreaRedDots = {}
	self.petAreaRayBoxs = {}

	local customMarkLayer = string.format("markerListTransformLayer%s", pg.game.map:getMarkPriorityByConfigId(Const.MAP_MARK_CUSTOM))

	self.customMarkerPool = UIObjectPool.new(AddressDataConst.UI_MARK_1, self.view[customMarkLayer], 3, 1, 1, 1, function()
		return
	end, function(gameObject)
		local button = gameObject:GetComponent("UButton")
		local objectReference = button:GetComponent("ObjectReference")
		local btnRectTransform = objectReference:GetRefValue("btnRectTransform")
		local lowerDynamicLoadTransform = objectReference:GetRefValue("lowerDynamicLoadTransform")
		local upperDynamicLoadTransform = objectReference:GetRefValue("upperDynamicLoadTransform")
		local btnCC = btnRectTransform.childCount
		local lowerDynamicLoadTransformCC = lowerDynamicLoadTransform.childCount
		local upperDynamicLoadTransformCC = upperDynamicLoadTransform.childCount

		for i = 0, btnCC - 1 do
			GameObject.Destroy(btnRectTransform:GetChild(0).gameObject)
		end

		for i = 0, lowerDynamicLoadTransformCC - 1 do
			GameObject.Destroy(lowerDynamicLoadTransform:GetChild(0).gameObject)
		end

		for i = 0, upperDynamicLoadTransformCC - 1 do
			GameObject.Destroy(upperDynamicLoadTransform:GetChild(0).gameObject)
		end
	end)
	self._markPoolGenerations = {}

	MapMarkPrefabPoolManager:RegisterReclaimProvider(self, function(prefabPath, requiredCount)
		return self:reclaimUnusedMarkPrefabs(prefabPath, requiredCount)
	end)

	self.markCaches = {}
	self.enableMultiDeleteMode = false
	self.trackTaskTable = {}
	self.trackTaskObjTable = {}
	self.chooseListEggNodes = {}

	function self._onMapMarkUpdated(updateInfo)
		if self:tryHandleGrabEggMarkUpdate(updateInfo) then
			return
		end

		self:onMapMarkStatusUpdated(updateInfo)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_UPDATED, self._onMapMarkUpdated)

	function self._onMapMarkTraceRemove(spawnerId)
		self:_cleanupTrackPrefab(spawnerId)

		if self.differentSceneTrackMark == spawnerId then
			self.differentSceneTrackMark = nil

			if self.mapNavLineComponent then
				self.mapNavLineComponent:drawNavEffLine()
			end
		end

		if self.diffSceneTrackDelayFlag == spawnerId then
			self.diffSceneTrackDelayFlag = nil
			self.diffSceneTrackIsSwitchingMap = nil
		end
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self._onMapMarkTraceRemove)
	self.view.petAreaFloatUComponent:SetActive(false)
	self:preprocessingData()
	self:preprocessing()

	self.markBubbleComponent = MarkBubbleComponent.new(self)
	self.mapNavLineComponent = MapNavLineComponent.new(self)
	self.mapBlockListComponent = MapBlockListComponent.new(self)

	self:onMapVisionChanged()
	self:initPetAreaProgressInfo()
	self:checkHideNormalMapInfo()
	self:tryShowTeaPartyMapHint()

	if self.view.consoleBarTransform then
		LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, {
			right = {
				{
					path = "Common/Confirm",
					label = pg.getGameString("CONSOLE_BAR_CONFIRM")
				},
				{
					path = "Common/Cancel",
					label = pg.getGameString("CONSOLE_BAR_LEAVE")
				}
			}
		})
	end
end

function MapCtrl:_unregisterMapMarkEventListeners()
	if self._onMapMarkUpdated then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_UPDATED, self._onMapMarkUpdated)

		self._onMapMarkUpdated = nil
	end

	if self._onMapMarkTraceRemove then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self._onMapMarkTraceRemove)

		self._onMapMarkTraceRemove = nil
	end
end

function MapCtrl:onVisibleChange(visible)
	if visible then
		self:_startMapMarkLoads()
	else
		self:_pauseMapMarkLoads()
	end
end

function MapCtrl:_refreshGameTimeStatusOnClose()
	self:_stopMapMarkLoads()
	UICtrl._refreshGameTimeStatusOnClose(self)
end

function MapCtrl:onDestroy()
	self:clearKeyBindings()
	self.view.mapScroll:SetDragEventEnabled(true)
	self:destroyGesture()

	self.MapLeftTopTipsComponent = nil
	self.dynamicMarkComponent = nil

	if self.mapMoveTimer then
		self:killTimer(self.mapMoveTimer)

		self.mapMoveTimer = nil
	end

	self.mapMoveLastUnityFrame = nil
	self.mapMoveStickValue = nil

	if self.mapScaleTimer then
		self:killTimer(self.mapScaleTimer)

		self.mapScaleTimer = nil
	end

	self.mapScaleDirection = nil

	local _, _, dailyKey = self:_checkTeaPartyMapHint()

	if dailyKey ~= nil then
		pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, dailyKey, false)
	end

	self:destroy()

	self.onMarkLoadedManualCallback = nil
	self.layerComponent = nil

	UICtrl.onDestroy(self)

	self.markCaches = nil
	self.pointsTasks = nil
	self.pendingMarkLoads = nil
	self.pendingMarkLoadOrder = nil
	self.pendingTempMarkOrder = nil
	self.questOverlapProcessed = nil
	self.activeNormalMarks = nil
	self.markLastSeen = nil
	self.markLruSeq = nil
	self.centralizingMarkId = nil
	self.petCollectEffect = nil
	self.playerEModel = nil
end

function MapCtrl:destroy()
	MapMarkPrefabPoolManager:UnregisterReclaimProvider(self)
	self:_stopMapMarkLoads()
	self:_unregisterMapMarkEventListeners()
	self:_stopLeylineFlowerQualityVx()
	self:_hideTeaPartyMapHint()
	self:clearAllChooseListEggNodes()

	self.chooseListEggNodes = nil

	if self.markBubbleComponent then
		self.markBubbleComponent:destroy()
	end

	self.markBubbleComponent = nil

	if self.markCaches then
		local markIds = {}

		for spawnerId in pairs(self.markCaches) do
			markIds[#markIds + 1] = spawnerId
		end

		for _, spawnerId in ipairs(markIds) do
			self:clearPreviousTask(spawnerId)
		end
	end

	MapMarkPrefabPoolManager:DumpStats("big_map_close")

	if self.grabEggAreaComponent then
		self.grabEggAreaComponent:destroy()
	end

	self.grabEggAreaComponent = nil

	if self.transLocationListComponent then
		self.transLocationListComponent:destroy()
	end

	self.transLocationListComponent = nil

	if self.bitMaskComponent then
		self.bitMaskComponent:destroy()
	end

	self.bitMaskComponent = nil

	if self.mapAreaOverlayComponent then
		self.mapAreaOverlayComponent:destroy()
	end

	self.mapAreaOverlayComponent = nil

	if self.mapNavLineComponent then
		self.mapNavLineComponent:destroy()
	end

	self.mapNavLineComponent = nil

	if self.mapMarkFilterComponent and self.mapMarkFilterComponent.panelOpened then
		self.mapMarkFilterComponent:closePanel()
	end

	self.mapMarkFilterComponent = nil

	if self.customMarkerPool then
		self.customMarkerPool:destroy()

		self.customMarkerPool = nil
	end

	if self.visibleMarkLoadTimer then
		self:killTimer(self.visibleMarkLoadTimer)

		self.visibleMarkLoadTimer = nil
	end

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener("UI_MapCtrl_FocusChanged")
	end

	if self.scaleValue then
		pg.me:serverMsg("RPC_CS_ChangeMapShowScale", self.sceneId, self.scaleValue)
	end

	self:openLocationPanel(false)
	self.view.chooseList.gameObject:SetActiveEx(false)
	self:onChooseListSetActive(false)
	self:clearAllChooseListEggNodes()
	self:renderMultiIconSelectBox(false)

	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:closePanel()
		self.mapPetAreaComponent:destroy()
	end

	self.mapPetAreaComponent = nil

	if self.petDistributionComponent then
		self.petDistributionComponent:destroy()
	end

	self.petDistributionComponent = nil

	if self.view.markerListTransformLayer100 then
		self.view.mineMarkTrans.parent = self.view.markerListTransformLayer100.transform
	end

	self.view.mineMarkDefaultParent = nil

	if self.view.markerListTransform then
		self.view.fakeCustomMarkUButton.transform:SetParent(self.view.markerListTransform)
	end

	self.view.fakeCustomMarkDefaultParent = nil
	self.view.closeBtn.luaClick = nil
	self.view.sliderFakeUSlider.luaValueChanged = nil
	self.view.sliderFakeUSlider.luaRelease = nil
	self.view.btnAddUButton.luaClick = nil
	self.view.btnReduceUButton.luaClick = nil
	self.view.mapScroll.zoomTool.luaEndScale = nil
	self.view.mapScroll.luaBeginDrag = nil
	self.view.mapScroll.luaEndDrag = nil
	self.view.chooseList.luaRenderItem = nil
	self.view.chooseList.luaClick = nil

	if self.view.mapInputEventHandler then
		self.view.mapInputEventHandler.OnClick = nil
	end

	if self.mapQuickMoveClickListener then
		self.mapQuickMoveClickListener.onDoubleClick = nil
		self.mapQuickMoveClickListener = nil
	end

	self.view.sliderFakeUSlider.value = 0
	self.mapAreas = {}
	self.curStage = nil
	self.currentZoom = nil
	self.sceneId = nil
	self.markMap = nil
	self._markPoolGenerations = nil
	self.pendingMarkLoads = nil
	self.pendingMarkLoadOrder = nil
	self.pendingTempMarkOrder = nil
	self.questOverlapProcessed = nil
	self.activeNormalMarks = nil
	self.markLastSeen = nil
	self.markLruSeq = nil
	self.centralizingMarkId = nil
	self.guideFocusFlag = nil

	if self.allyTickTimer then
		self:killTimer(self.allyTickTimer)

		self.allyTickTimer = nil
	end

	if self.mapAreaHoverTick then
		self:killTimer(self.mapAreaHoverTick)

		self.mapAreaHoverTick = nil
	end

	for _, taskIds in pairs(self.weatherTaskInfo or EMPTY_TABLE) do
		for _, taskId in ipairs(taskIds) do
			pg.global.resMgr:TryCancelGOLoadAsyncTask(taskId)
		end
	end

	for _, effects in pairs(self.weatherInfo or EMPTY_TABLE) do
		for _, weather in ipairs(effects) do
			pg.global.resMgr:RemoveInstanceToCache(weather)
		end
	end

	self.notInteractPoints = nil

	self.view:cancelAllUIAsyncTask()
	self.view:destroyAllInstance()
	self.view:unloadMapGO()

	self.tempFilter = nil
	self.tempFilterFlag = nil

	if self.mapFogGenerator then
		pg.game.map:unregisterFogGenerator(self.mapFogGenerator)
	end

	self.mapFogGenerator = nil
	self.mapFogBlock = nil

	mapFogManager.UnLoadAllRes()

	self.mapSwitchDelayCallbacks = {}
	self.differentSceneTrackMark = nil

	self:addActivatedVX(nil, nil, false)

	if self.weatherTaskContainer then
		MapUtils.renderWeatherIcon(nil, self.weatherTaskContainer, nil, true)
	end

	if pg.global.navMgr and self.mapVirtualMouseModeBeforeNavModal ~= nil then
		pg.global.navMgr:SetVirtualMouseMode(self.mapVirtualMouseModeBeforeNavModal)
	end

	self.mapVirtualMouseModeBeforeNavModal = nil
	self.mapNavModalStickValue = nil
	self.mapWasInNavModal = nil
	self.mapVirtualMouseActive = nil
	self.resumeMapMoveByGamepad = nil
	self.stopMapMoveByGamepad = nil

	pg.global.uiMgr:RemoveVirtualMouseField(self.mapVirtualMouseField)

	self.mapVirtualMouseField = nil
end

function MapCtrl:addListener()
	self:listener()
end

function MapCtrl:clearKeyBindings()
	if self.closeBind then
		self.closeBind.luaTrigger = nil
		self.closeBind = nil
	end

	if self.closeBind2 then
		self.closeBind2.luaTrigger = nil
		self.closeBind2 = nil
	end

	if self.cancelBind then
		self.cancelBind.luaTrigger = nil
		self.cancelBind = nil
	end

	if self.mapMoveGamepadBinding then
		self.mapMoveGamepadBinding.luaTrigger = nil
		self.mapMoveGamepadBinding = nil
	end

	if self.mapAddScaleGamepadBinding then
		self.mapAddScaleGamepadBinding.luaTrigger = nil
		self.mapAddScaleGamepadBinding = nil
	end

	if self.mapReduceScaleGamepadBinding then
		self.mapReduceScaleGamepadBinding.luaTrigger = nil
		self.mapReduceScaleGamepadBinding = nil
	end
end

function MapCtrl:isMapGlobalLayer()
	return self.currentZoom == self.view.scales[1]
end

function MapCtrl:shouldShowMarkOnLoad(scale, spawnerId)
	return scale == 1 or pg.game.map:shouldForceVisibleMark(spawnerId)
end

function MapCtrl:refreshPetAreaRedDot(areaId, redDotUButton)
	if IsNil(redDotUButton) then
		return
	end

	local showResult = self:isMapGlobalLayer()
	local redDot1, redDot2, redDot3 = pg.game.map:getPetAreaRewardStateById(areaId)

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_PET_AREA_LIST_ITEM .. areaId, redDotUButton, (redDot1 or redDot2 or redDot3) and showResult, RedDotConst.RedDotStyle.REWARD)
	redDotUButton:SetActive(showResult)
end

function MapCtrl:scaleMap(value, fromSlider)
	if not math.isFloatMultipleOf(value, self.view.stepSize, 0.01) or value < 0 or value > 1.000001 then
		value = pg.game.map:getDefaultMapScaleRatio(self.sceneId)
	end

	self.scaleValue = value

	self.view.mapScroll.zoomTool:SetTargetIndex(math.round(value / self.view.stepSize))
	self:endScale(math.round((1 - value) / self.view.stepSize) + 1, self.view.scales[math.round(value / self.view.stepSize) + 1])

	if not fromSlider then
		self.view.sliderFakeUSlider.value = value
	end

	if self.mapAreaOverlayComponent then
		self.mapAreaOverlayComponent:setVisible(self.curStage == #self.view.scaleBasicTable)
	end

	if self.mapPetAreaComponent then
		for areaId, redDotUButton in pairs(self.petAreaRedDots) do
			self:refreshPetAreaRedDot(areaId, redDotUButton)
		end

		for areaId, rayBox in pairs(self.petAreaRayBoxs) do
			rayBox:SetActive(self.curStage == #self.view.scaleBasicTable)
		end

		if self.curStage ~= #self.view.scaleBasicTable then
			self.mapPetAreaComponent:closePanel()
		elseif pg.game.map.curBlockId and not self.focusSmallArea then
			self.mapPetAreaComponent:setPetAreaProgressTipInfo(nil, false, pg.game.map.curBlockId)
		end
	end

	self:onMapScaleValueMin()
	self:onMapVisionChanged()

	if self.mapFogGenerator then
		self.mapFogGenerator:SetThinFogTexSt(self.currentZoom or 1)
	end
end

function MapCtrl:cancelMultiSelect()
	self:deselectAll()
	self.view.chooseList.gameObject:SetActiveEx(false)
	self:onChooseListSetActive(false)
	self:clearAllChooseListEggNodes()
	self:renderMultiIconSelectBox(false)
end

function MapCtrl:onMapScaleValueMin()
	if self.curStage == #self.view.scaleBasicTable then
		self:openLocationPanel(false)
		self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)
		self:cancelMultiSelect()
		self.view.sortFilterUComponent.gameObject:SetActiveEx(false)
	else
		self.view.sortFilterUComponent.gameObject:SetActiveEx(true)
	end

	self:refreshCoordinate()
end

function MapCtrl:onChooseListSetActive(active)
	self:RefreshMapVirtualMouseState()
	self:refreshConsoleBarState()
end

function MapCtrl:closeCurrentLocationInfo()
	local closeHandler = self.currentLocationInfoCloseHandler

	if closeHandler then
		closeHandler()

		return
	end

	self:openLocationPanel(false)
end

function MapCtrl:listener()
	self.closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")
	self.closeBind.isVirtual = true
	self.closeBind.priority = -1
	self.closeBind.actionPath = "Hud/OpenMap"

	function self.closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	self.closeBind2 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind2")
	self.closeBind2.isVirtual = true
	self.closeBind2.priority = -1
	self.closeBind2.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.ClosePanelCommon

	function self.closeBind2.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if inputInfo.phase == "Performed" then
			if self.view.locationInfo.gameObject.activeSelf then
				self.view.locationInfo.gameObject:SetActiveEx(false)

				return
			end

			if self.view.petAreaFloatUComponent.gameObject.activeSelf then
				self.view.petAreaFloatUComponent.gameObject:SetActiveEx(false)

				return
			end

			self:closePanel()
		end
	end

	self.cancelBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "mpCancelBind")
	self.cancelBind.isVirtual = true
	self.cancelBind.priority = -1
	self.cancelBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function self.cancelBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and pg.game.input:isUsingGamepad() then
			if self.view.btnAreaSortUSelector then
				local popupInstance = self.view.btnAreaSortUSelector and self.view.btnAreaSortUSelector:GetPopupInstance()

				if popupInstance then
					popupInstance:ClosePopup()

					return
				end
			end

			if self.view.locationInfo.gameObject.activeSelf then
				local _h = MapCtrl._platformHooks

				if _h and _h.handleCancelOnLocationInfo and _h.handleCancelOnLocationInfo(self) then
					return
				end

				local closeBtn = self.currentLocationInfoCloseBtn

				if NotNil(closeBtn) then
					closeBtn:OnClickSimulate()
				else
					self:closeCurrentLocationInfo()
				end

				return
			end

			if self.view.chooseList.gameObject.activeSelf then
				self:cancelMultiSelect()

				return
			end

			if self.view.sortFloatUComponent.gameObject.activeSelf then
				self.mapMarkFilterComponent:closePanel()

				return
			end

			if self.view.petAreaFloatUComponent.gameObject.activeSelf then
				if self.mapPetAreaComponent then
					self.mapPetAreaComponent:closePanel()
				end

				return
			end

			self:closePanel()
		end
	end

	function self.view.closeBtn.luaClick()
		self:closePanel()
	end

	function self.view.listCurrency.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local countUText = objectReference:GetRefValue("countUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnAdd = objectReference:GetRefValue("btnAdd")

		ClientTextUtils.setText(countUText, string.format("%d/%d", data.num, LuaUIUtils.getVitalityMaxStoreNum()))

		iconUImage.url = data.icon

		button:TryChangePage("IsAdd", 1)

		function btnAdd.luaClick()
			LuaUIUtils.openVitalityGot(Const.CommonEnergyType_Stamina)
		end

		function button.luaClick()
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			else
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = data.id,
					num = data.num,
					targetRect = iconUImage
				})
			end
		end
	end

	function self.view.sliderFakeUSlider.luaValueChanged(value)
		if self.mapDragging then
			return
		end

		self:scaleMap(value, true)
	end

	function self.view.btnAddUButton.luaClick()
		if self.mapDragging then
			return
		end

		if self.scaleValue + self.view.stepSize > 1.000001 then
			return
		end

		self:scaleMap(self.scaleValue + self.view.stepSize)
	end

	function self.view.btnReduceUButton.luaClick()
		if self.mapDragging then
			return
		end

		if self.scaleValue - self.view.stepSize < 0 then
			return
		end

		self:scaleMap(self.scaleValue - self.view.stepSize)
	end

	function self.view.mapScroll.zoomTool.luaEndScale(stage, _, _, _)
		self:scaleMap(1 - (stage - 1) * self.view.stepSize)
		self:loadVisibleMarks()
	end

	function self.view.mapScroll.luaBeginDrag()
		if self.touchStart2Fingers then
			return
		end

		self.mapDragging = true
		self.view.mapScroll.zoomTool.disableZoomWhileDragging = true
	end

	function self.view.mapScroll.luaDrag()
		if self.touchStart2Fingers then
			return
		end

		self:onMapVisionChanged()
	end

	function self.view.mapScroll.luaEndDrag()
		self.mapDragging = false
		self.view.mapScroll.zoomTool.disableZoomWhileDragging = false

		if self.touchStart2Fingers then
			return
		end

		self:onMapVisionChanged()
	end

	function self.view.chooseList.luaRenderItem(button, _, data)
		self:renderChooseList(button, data)
	end

	function self.view.chooseList.luaClick(_, data)
		self.manualClick = false

		data.button.luaClick()
	end

	if self.mapVirtualMouseField then
		self.mapVirtualMouseField:SetShouldProcessStickInput(false)

		if self.view.mapScrollView then
			self.mapVirtualMouseField:CenterCursorOnRect(self.view.mapScrollView)
		end
	end

	local function stopMapMoveByGamepad(resetCursorMotion)
		if self.mapMoveTimer then
			self:killTimer(self.mapMoveTimer)

			self.mapMoveTimer = nil
		end

		self.mapMoveLastUnityFrame = nil
		self.mapMoveStickValue = nil

		if resetCursorMotion and self.mapVirtualMouseField then
			self.mapVirtualMouseField:MoveCursorManually(CS.UnityEngine.Vector2.zero, 0)
		end
	end

	local function updateMapMoveByGamepad()
		if not self.view or not self.mapVirtualMouseField or not self.mapMoveStickValue then
			return
		end

		if not self:GetMapVirtualMouseState() then
			stopMapMoveByGamepad(true)

			return
		end

		if self:IsInMapNavModal() then
			stopMapMoveByGamepad(true)

			return
		end

		if self.mapVirtualMouseField.IsHandleMoveInProgress then
			stopMapMoveByGamepad(false)

			return
		end

		local unityFrame = CS.UnityEngine.Time.frameCount

		if self.mapMoveLastUnityFrame == unityFrame then
			return
		end

		self.mapMoveLastUnityFrame = unityFrame

		local rawStickValue = self.mapMoveStickValue
		local stickValue = Vector2(math.abs(rawStickValue.x) > MAP_GAMEPAD_MOVE_DEADZONE and rawStickValue.x or 0, math.abs(rawStickValue.y) > MAP_GAMEPAD_MOVE_DEADZONE and rawStickValue.y or 0)

		if stickValue.x == 0 and stickValue.y == 0 then
			self.mapVirtualMouseField:MoveCursorManually(CS.UnityEngine.Vector2.zero, 0)

			return
		end

		local targetPos = self.view.mapScroll.normalizedScrollPosition
		local scrollRangeX = (self.maxMapAnchoredPosX or 0) - (self.minMapAnchoredPosX or 0)
		local scrollRangeY = (self.maxMapAnchoredPosY or 0) - (self.minMapAnchoredPosY or 0)
		local cursorControlAxes = self.mapVirtualMouseField:GetCursorControlAxesForRect(self.view.mapScrollView, targetPos, stickValue, scrollRangeX > 1e-06, scrollRangeY > 1e-06, MAP_GAMEPAD_BOUNDARY_EPSILON)
		local cursorStickValue = Vector2(stickValue.x * cursorControlAxes.x, stickValue.y * cursorControlAxes.y)
		local mapStickValue = Vector2(stickValue.x * (1 - cursorControlAxes.x), stickValue.y * (1 - cursorControlAxes.y))

		self.mapVirtualMouseField:CenterCursorAxesOnRect(self.view.mapScrollView, cursorControlAxes.x < 0.5, cursorControlAxes.y < 0.5)

		local deltaTime = CS.UnityEngine.Time.unscaledDeltaTime

		if cursorStickValue.x ~= 0 or cursorStickValue.y ~= 0 then
			self.mapVirtualMouseField:MoveCursorManually(cursorStickValue, deltaTime)
		else
			self.mapVirtualMouseField:MoveCursorManually(CS.UnityEngine.Vector2.zero, 0)
		end

		if mapStickValue.x ~= 0 or mapStickValue.y ~= 0 then
			local frameDelta = mapStickValue * MAP_GAMEPAD_MOVE_SPEED * deltaTime

			if scrollRangeX > 1e-06 then
				targetPos.x = math.clamp(targetPos.x + frameDelta.x / scrollRangeX, 0, 1)
			end

			if scrollRangeY > 1e-06 then
				targetPos.y = math.clamp(targetPos.y + frameDelta.y / scrollRangeY, 0, 1)
			end

			self.view.mapScroll:SetNormalizedScrollPosition(targetPos)
			self:onMapVisionChanged()
		end

		local isSnapping = self.mapVirtualMouseField:CheckAndFireHover()

		if isSnapping then
			stopMapMoveByGamepad(false)

			return
		end
	end

	local function startMapMoveByGamepad(stickValue)
		if not stickValue then
			return
		end

		if self.mapVirtualMouseField and self.mapVirtualMouseField.IsHandleMoveInProgress then
			stopMapMoveByGamepad(false)

			return
		end

		if math.abs(stickValue.x) <= MAP_GAMEPAD_MOVE_DEADZONE and math.abs(stickValue.y) <= MAP_GAMEPAD_MOVE_DEADZONE then
			stopMapMoveByGamepad(true)

			return
		end

		self.mapMoveStickValue = stickValue

		updateMapMoveByGamepad()

		if not self.mapMoveStickValue then
			return
		end

		if self.mapMoveTimer == nil then
			self.mapMoveTimer = self:startTimer(updateMapMoveByGamepad, 0, true)
		end
	end

	self.resumeMapMoveByGamepad = startMapMoveByGamepad
	self.stopMapMoveByGamepad = stopMapMoveByGamepad
	self.mapMoveGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "mapMoveGamepadBinding")
	self.mapMoveGamepadBinding.actionPath = "Raw/GamepadLeftStickMove"
	self.mapMoveGamepadBinding.isVirtual = true
	self.mapMoveGamepadBinding.priority = -1

	function self.mapMoveGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not pg.game.input:isUsingGamepad() or not self.mapVirtualMouseField then
				return true
			end

			if self:IsInMapNavModal() then
				self.mapNavModalStickValue = inputInfo.valueVec2

				return true
			end

			if not self:GetMapVirtualMouseState() then
				return true
			end

			self.mapNavModalStickValue = nil

			startMapMoveByGamepad(inputInfo.valueVec2)

			return false
		elseif inputInfo.phase == "Canceled" then
			self.mapNavModalStickValue = nil

			stopMapMoveByGamepad(true)

			return true
		end

		return true
	end

	local function stopMapScale()
		if self.mapScaleTimer then
			self:killTimer(self.mapScaleTimer)

			self.mapScaleTimer = nil
		end

		self.mapScaleDirection = nil
	end

	local function startMapScale(direction)
		if self.mapScaleTimer and self.mapScaleDirection == direction then
			return
		end

		stopMapScale()

		self.mapScaleDirection = direction

		local function scaleMapFunc()
			if not self.view then
				return
			end

			local targetScale = self.scaleValue + self.view.stepSize * direction

			if targetScale > 1.000001 or targetScale < -1e-06 then
				return
			end

			self:scaleMap(targetScale)
		end

		scaleMapFunc()

		self.mapScaleTimer = self:startTimer(scaleMapFunc, 0.2, true)
	end

	local function handleRightStickScale(inputInfo)
		if inputInfo.phase == "Performed" then
			local stickY = inputInfo.valueVec2.y

			if stickY > MAP_GAMEPAD_SCALE_DEADZONE then
				startMapScale(1)
			elseif stickY < -MAP_GAMEPAD_SCALE_DEADZONE then
				startMapScale(-1)
			else
				stopMapScale()
			end
		elseif inputInfo.phase == "Canceled" then
			stopMapScale()
		end
	end

	self.mapAddScaleGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "mapAddScaleGamepadBinding")
	self.mapAddScaleGamepadBinding.actionPath = "Raw/GamepadRightStickMove"
	self.mapAddScaleGamepadBinding.isVirtual = true
	self.mapAddScaleGamepadBinding.priority = -1
	self.mapAddScaleGamepadBinding.luaTrigger = handleRightStickScale
end

function MapCtrl:renderChooseList(button, data)
	button.name = data.spawnerId

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local icon = objectReference:GetRefValue("iconUImage")
	local layerUImage = objectReference:GetRefValue("layerUImage")

	icon:SetActive(true)
	button:TryChangePage("stage", 1)

	local textContent = ""

	self:clearChooseListEggNode(data.spawnerId)

	if data.markType == Const.MAP_MARK_GRAB_EGG then
		local k = self:getMarkInfo(data.spawnerId)

		textContent = pg.getLocalizationText(k.infoTitle)

		icon:SetActive(false)
		self:renderChooseListEggNode(button, icon, data.spawnerId, k)
		layerUImage.gameObject:SetActiveEx(false)
		ClientTextUtils.setText(txtNameUSDFText, textContent)

		function button.luaClick()
			local btns = self.view.chooseList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				if btns[i].name == tostring(data.spawnerId) then
					self.chooseListClick = true
					self.chooseListIndex = i
				end
			end
		end

		return
	end

	if data.markType == Const.MAP_MARK_QUEST then
		local k = self:getMarkInfo(data.spawnerId)

		textContent = k.questMarkInfo.title

		local questIcon = QuestUtils.getQuestTypeIcon(data.questId)

		icon.url = questIcon or "$UI_Hud_Icon_MainLine_Grayed.png"
	else
		local k = self:getMarkInfo(data.spawnerId)

		if data.customMarkName ~= nil then
			textContent = data.customMarkName
		else
			local markStatus = self.markCaches[data.spawnerId].markStatus
			local infoTitle

			if markStatus <= Const.MAP_MARK_STATUS_LOCKED then
				infoTitle = k.infoTitleNot
			else
				infoTitle = k.infoTitle
			end

			textContent = pg.getLocalizationText(infoTitle or "")
		end

		if pg.game.map.extraSharedInfoByMarkId[data.spawnerId].isUnKnownImg and self:markTypeProcessed(data.spawnerId, k.markType) <= Const.MAP_MARK_STATUS_LOCKED then
			icon.url = pg.game.map.extraSharedInfoByMarkId[data.spawnerId].isUnKnownImg
		else
			icon.url = pg.game.map.extraSharedInfoByMarkId[data.spawnerId].imgPath
		end

		textContent = data.markType == Const.MAP_MARK_CLUE and QuestUtils.getClueQuestTitle(data.spawnerId) or textContent
	end

	local inAreaRange = pg.game.map.extraSharedInfoByMarkId[data.spawnerId].inAreaRange

	if inAreaRange == 0 then
		layerUImage.gameObject:SetActiveEx(false)
	elseif inAreaRange == 1 then
		layerUImage.gameObject:SetActiveEx(true)

		layerUImage.url = AddressDataConst.UI_MARK_IMG_LAYER_INACTIVE
	else
		layerUImage.gameObject:SetActiveEx(true)

		layerUImage.url = AddressDataConst.UI_MARK_IMG_LAYER_ACTIVE
	end

	ClientTextUtils.setText(txtNameUSDFText, textContent)

	function button.luaClick()
		local btns = self.view.chooseList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			if btns[i].name == tostring(data.spawnerId) then
				self.chooseListClick = true
				self.chooseListIndex = i
			end
		end
	end
end

function MapCtrl:clearChooseListEggNode(spawnerId)
	if not self.chooseListEggNodes then
		return
	end

	local node = self.chooseListEggNodes[spawnerId]

	if not node then
		return
	end

	if node.taskId then
		self.view:cancelUIAsyncTask(node.taskId)
	end

	if node.obj then
		self.view:destroyInstance(node.obj)
	end

	self.chooseListEggNodes[spawnerId] = nil
end

function MapCtrl:clearAllChooseListEggNodes()
	if not self.chooseListEggNodes then
		return
	end

	for spawnerId in pairs(self.chooseListEggNodes) do
		self:clearChooseListEggNode(spawnerId)
	end
end

function MapCtrl:renderChooseListEggNode(button, icon, spawnerId, markInfo)
	local resData = MapMarkResourceData[markInfo.markConfigId]
	local defaultRes = resData and (resData[self.sceneId] or resData[0])
	local iconImgPath = defaultRes and defaultRes.icon
	local eggView = GrabEggMapMarkUtils.getEggView(spawnerId)
	local node = {}

	self.chooseListEggNodes[spawnerId] = node
	node.taskId = self.view:addPrefabWithPathAsync(icon.transform.parent, AddressDataConst.UI_MARK_NODE_GRAB_EGG_HUGE_EGG, function(obj)
		node.taskId = nil

		if self.chooseListEggNodes[spawnerId] ~= node or button.name ~= tostring(spawnerId) then
			self.view:destroyInstance(obj.gameObject)

			return
		end

		node.obj = obj.gameObject

		local nodeRect = obj.gameObject:GetComponent("RectTransform")

		nodeRect.anchoredPosition = Vector2.zero
		nodeRect.localScale = Vector3.one * 0.5

		local eggObjRef = obj.gameObject:GetComponent("ObjectReference")

		GrabEggMapMarkUtils.applyEggMarkView(eggObjRef, eggView, iconImgPath)
	end, false, true, 0)
end

function MapCtrl:overlaidFootprintByFogBitMask(mapFogChunkIndexTable)
	if self.mapFogGenerator then
		for _, v in pairs(mapFogChunkIndexTable) do
			self.mapFogGenerator:OverlaidFootprintByFogBitMaskWithIndex(v)
		end
	end
end

function MapCtrl:initGesture()
	if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
		return
	end

	fingerGestures.Active()
	fingerGestures.EnableTwist(false)
	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnTouchStart2Fingers(_)
		self.touchStart2Fingers = true
		self.pinchAccum = 0
		self.mapDragging = false
		self.view.mapScroll.zoomTool.disableZoomWhileDragging = false

		self.view.mapScroll:SetScrollDisabled(true)
		self.view.mapScroll:SetDragEventEnabled(false)
	end

	function fingerGestures.luaOnTouchUp2Fingers(gesture)
		self.touchStart2Fingers = false
		self.pinchAccum = 0

		self.view.mapScroll:SetScrollDisabled(false)

		self.touchCount = 0
		self.mapDragging = false
		self.view.mapScroll.zoomTool.disableZoomWhileDragging = false

		self.view.mapScroll:SetDragEventEnabled(true)
	end

	self.pinchStepThreshold = self.pinchStepThreshold or 120
	self.pinchAccum = 0

	local function handlePinch(gesture, isLarger)
		self.twoFingersPosition = Vector3(gesture.position.x, gesture.position.y, 0)

		local signed = (isLarger and 1 or -1) * (gesture.deltaPinch or 0)

		if self.pinchAccum * signed < 0 then
			self.pinchAccum = 0
		end

		self.pinchAccum = self.pinchAccum + signed

		while math.abs(self.pinchAccum) >= self.pinchStepThreshold do
			self.pinchAccum = self.pinchAccum - (isLarger and 1 or -1) * self.pinchStepThreshold

			self:scrollMap(isLarger)
		end
	end

	function fingerGestures.luaOnPinchIn(gesture)
		handlePinch(gesture, false)
	end

	function fingerGestures.luaOnPinchOut(gesture)
		handlePinch(gesture, true)
	end

	function fingerGestures.luaOnTouchStart(gesture)
		if not self.touchCount then
			self.touchCount = 0
		end

		self.touchCount = self.touchCount + 1
	end

	function fingerGestures.luaOnTouchUp(gesture)
		if self.touchCount then
			self.touchCount = self.touchCount - 1

			if self.touchCount < 0 then
				self.touchCount = 0
			end

			if self.touchCount == 0 then
				self.view.mapScroll:SetDragEventEnabled(true)
			end
		end
	end
end

function MapCtrl:destroyGesture()
	if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
		return
	end

	fingerGestures.DeActive()

	self.touchCount = nil

	local mobileOperateCtrl = pg.global.ui.mobileOperate

	if mobileOperateCtrl and mobileOperateCtrl.moveJoyStick then
		mobileOperateCtrl.moveJoyStick:initGesture()
	end
end

function MapCtrl:getMarkInfo(spawnerId)
	if self.sceneMarkPointData[spawnerId] then
		return self.sceneMarkPointData[spawnerId]
	elseif self.tempMarkPointData[spawnerId] then
		return self.tempMarkPointData[spawnerId]
	elseif self.teamMarkPointData and self.teamMarkPointData[spawnerId] then
		return self.teamMarkPointData[spawnerId]
	else
		return nil
	end
end

function MapCtrl:preprocessingData()
	local player = pg.me

	if not player then
		return
	end

	self.markMap = player:getSpaceOwnerMapMarkStatusMap() or player.mapMarkStatusMap

	pg.game.map:loadTotalEnabledMarkTypes(self.sceneId)
	pg.game.map:loadEnabledMarkTypes(self.sceneId)

	self.playerEModel = player.eModel

	if not self:isDifferentScene() then
		self.sceneMarkPointData = pg.game.map.sceneMarkPointData
		self.tempMarkPointData = pg.game.map.tempMarkPointData
		self.teamMarkPointData = pg.game.map.teamMarkPointData
	else
		local spaceId
		local space = pg.space

		if space ~= nil then
			spaceId = space.id
		end

		self.sceneMarkPointData = MapHelper.combineAllSeamlessSceneData(self.sceneId, spaceId)
		self.tempMarkPointData = {}

		for k, v in pairs(pg.game.map.tempMarkPointData) do
			if v.markConfigId == Const.MAP_MARK_QUEST or v.markConfigId == Const.MAP_MARK_CLUE then
				self.tempMarkPointData[k] = v
			end
		end

		if pg.game.map.diffSceneTempMarkData then
			for k, v in pairs(pg.game.map.diffSceneTempMarkData) do
				self.tempMarkPointData[k] = v
			end
		end

		pg.game.map.diffSceneTempMarkData = nil

		self:loadSavedCustomMark()
		self:loadSavedMarkShare()

		self.teamMarkPointData = nil
	end

	pg.game.map:calculateMarkNumsByConfigId(self.sceneId, self.sceneMarkPointData, self.tempMarkPointData, self.markMap)

	if self._switchingMap then
		local function delayFunc()
			self.view.sortFilterUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User2, function()
				self.mapMarkFilterComponent:refreshSimpleTagList()
				self.view.sortFilterUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end)
		end

		self.mapSwitchDelayCallbacks[#self.mapSwitchDelayCallbacks + 1] = delayFunc
	else
		self.mapMarkFilterComponent:refreshSimpleTagList()
	end
end

function MapCtrl:preprocessing()
	self:openLocationPanel(false)

	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:closePanel()
	end

	self.chooseListClick = false
	self.chooseListIndex = nil

	self.view.chooseList.gameObject:SetActiveEx(false)
	self:onChooseListSetActive(false)
	self:renderMultiIconSelectBox(false)

	local halfVec2 = Vector2(0.5, 0.5)
	local zeroOneVec2 = Vector2(0, 1)

	self.view.mapScrollContent.anchorMin = halfVec2
	self.view.mapScrollContent.anchorMax = halfVec2
	self.view.mapScrollContent.pivot = halfVec2
	self.view.mapScrollContent.localPosition = Vector3.zero
	self.view.mapScrollContent.localScale = Vector3(3, 3, 1)
	self.view.mineMarkTrans.parent = self.view.markerListTransformLayer100.transform
	self.view.mineMarkTrans.anchorMin = zeroOneVec2
	self.view.mineMarkTrans.anchorMax = zeroOneVec2
	self.view.mineMarkTrans.pivot = zeroOneVec2
	self.view.mineMarkTrans.localPosition = Vector3.zero

	self.view.fakeCustomMarkUButton.transform:SetParent(self.view.markerListTransform)

	self.view.fakeCustomMarkUButton.transform.anchorMin = zeroOneVec2
	self.view.fakeCustomMarkUButton.transform.anchorMax = zeroOneVec2
	self.view.fakeCustomMarkUButton.transform.pivot = halfVec2
	self.view.fakeCustomMarkUButton.transform.localPosition = Vector3.zero
	self.view.fakeCustomMarkUButton.transform.localScale = Vector3.one

	self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

	self.manualClick = true
	self.templateNode = self.view.mapScrollContent.transform:Find("TemplateNode")
	self.pinButton = self.view.mapScrollContent.transform:Find("PinButton"):GetComponent("UButton")
	self.pinButton.enableVirtualMouseHoverFunc = false

	function self.pinButton.luaClickWithEventData(eventData)
		if self.curStage == #self.view.scaleBasicTable and self.mapPetAreaComponent then
			self.mapPetAreaComponent:setPetAreaProgressTipInfo(eventData)
		else
			self:onPinBtnClick(eventData)
		end
	end

	if pg.global.ui.uiMgr:CheckIsMobileInteract() and Utils.enableClientUseGm(pg.me) and (UNITY_EDITOR or GmToolUtils.quickMoveEnabled) then
		local ClickEventListener = CS.XGUI.EventSystems.ClickEventListener

		self.mapQuickMoveClickListener = ClickEventListener.Get(self.pinButton.gameObject)

		function self.mapQuickMoveClickListener.onDoubleClick(eventData)
			if not Utils.enableClientUseGm(pg.me) or not UNITY_EDITOR and not GmToolUtils.quickMoveEnabled then
				return
			end

			local screenPos = Vector2(eventData.position.x, eventData.position.y)

			self:debugQuickMove(screenPos)
		end
	end

	if self.openWeather then
		if self.mapPetAreaComponent then
			self.mapPetAreaComponent:setPetAreaProgressTipInfo(nil, true)
		end

		self.openWeather = false
	end

	self.firstIn = true

	self:refreshPlayerPosInMap()
	self:checkFromWhichType()

	local notInteractTempPoints

	self.batchSceneMarkPointData, self.notInteractPoints = pg.game.map:generateBatchMarks(self.sceneMarkPointData)
	self.batchTempMarkPointData, notInteractTempPoints = pg.game.map:generateBatchMarks(self.tempMarkPointData)

	LuaUIUtils.appendTable(self.notInteractPoints, notInteractTempPoints)

	self.notInteractPointsInViewGroup = {}
	self.pointsTasks = {}
	self.pendingMarkLoads = {}
	self.pendingMarkLoadOrder = {}
	self.pendingTempMarkOrder = {}
	self.questOverlapProcessed = {}
	self.activeNormalMarks = {}
	self.markLastSeen = {}
	self.markLruSeq = 0
	self.normalMarkMaxActive = getPlatformMaxActiveMarks()

	self:loadAllMarks()

	if self.grabEggAreaComponent then
		self.grabEggAreaComponent:init()
	end

	if self.transLocationListComponent then
		if self._switchingMap then
			local function delayFunc()
				self.view.layoutTransUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
					self.transLocationListComponent:init()
					self.view.layoutTransUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
				end)
			end

			self.mapSwitchDelayCallbacks[#self.mapSwitchDelayCallbacks + 1] = delayFunc
		else
			self.transLocationListComponent:init()
		end
	end

	if self.bitMaskComponent then
		self.bitMaskComponent:init()
	end

	local currencyList = self.model:getCurrencyDataList()

	self.view.listCurrency:SetList(currencyList)
	self:renderLeylineTreeBtn()

	self.view.sliderFakeUSlider.stepSize = self.view.stepSize
	self.allyTickTimer = self:startTimer(function()
		self:startMovingTargetTick()
		self:processBindMarkStatus()
	end, 0, true)
	self.mapAreaHoverTick = self:startTimer(function()
		self:checkMapAreaHover()
	end, 0.05, true)

	if self.sceneId == SocialConst.ARK_SCENE_ID then
		local objectReference = self.view.mapScrollContent:GetComponent("ObjectReference")
		local coffeeAreaImgUImage = objectReference:GetRefValue("coffeeAreaImgUImage")
		local isPartyStart = MapUtils.isPartyStart(SocialConst.CAFE_AREA_ID)

		coffeeAreaImgUImage.gameObject:SetActiveEx(isPartyStart)
	end
end

function MapCtrl:checkMapAreaHover()
	if self.curStage == #self.view.scaleBasicTable then
		local x, y

		if pg.game.input:isUsingGamepad() and self.mapVirtualMouseField then
			x, y = self:getPointerPos(self.mapVirtualMouseField:GetVirtualMousePosition())
		else
			x, y = self:getPointerPos(UnityInput.mousePosition)
		end

		local allChildrenScenes = MapHelper.getAllChildrenScene(self.sceneId)
		local hoverAreaId
		local newX = x
		local newY = y

		for _, sceneId in pairs(allChildrenScenes) do
			local mapOffsetUI = MapHelper.getMapOffsetUI(sceneId)

			if mapOffsetUI then
				newX = x - mapOffsetUI[1]
				newY = y - mapOffsetUI[2]
			end

			hoverAreaId = pg.game.map:inWhichBlock(sceneId, true, {
				x = newX,
				y = newY
			})

			if hoverAreaId then
				break
			end
		end

		if self.mapAreaOverlayComponent then
			self.mapAreaOverlayComponent:setHover(hoverAreaId)
		end
	end
end

function MapCtrl:isIdyllWorld()
	return self.sceneId == self.model.MAPS.IDYLL or self.sceneId == self.model.MAPS.IDYLL_WATER
end

function MapCtrl:renderLeylineTreeBtn()
	local largeBlockId = pg.game.map:getCurLargeBlockId()
	local currentSceneId = self:_getCurrentSpaceSceneId()
	local mainSceneId = currentSceneId and pg.game.map:convertSceneId(currentSceneId)

	if currentSceneId ~= mainSceneId then
		for _, areaData in pairs(SceneLeylineTreeAreaData) do
			if areaData.sceneId == mainSceneId then
				largeBlockId = areaData.areaId

				break
			end
		end
	end

	local isUnlockleylin = pg.game.map:checkBlockLeylineTreeUnlocked(largeBlockId)

	if isUnlockleylin and self:isIdyllWorld() and largeBlockId and MapAreaConfigData[largeBlockId] and MapAreaConfigData[largeBlockId].treeId then
		local treeId = MapAreaConfigData[largeBlockId].treeId

		self.view.btnNourish:SetActive(true)

		local objectReference = self.view.btnNourish:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconUpUContainer = objectReference:GetRefValue("iconUpUContainer")
		local isUp = ClientActivityUtils.isLeylineTreeUp()

		iconUpUContainer:SetActive(isUp)

		if isUp then
			iconUpUContainer:LoadDefaultUrlManually(function(root)
				local objRef = root:GetComponent("ObjectReference")
				local txtNameIconUpUBaseText = objRef:GetRefValue("txtNameUBaseText")

				ClientTextUtils.setText(txtNameIconUpUBaseText, pg.getGameString("LEYLINE_TREE_UP_MAP"))
			end)
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("MAP_OPEN_LEYLINE_TREE"))
		pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_NOURISH_ICON, self.view.btnNourish, pg.game.leylineTree:getLeylineTreeTotalRewardState(), RedDotConst.RedDotStyle.REWARD)

		function self.view.btnNourish.luaClick()
			pg.me:event_interactLeylineTree({
				treeId
			})
			self:closePanel()
		end
	else
		self.view.btnNourish:SetActive(false)
	end
end

function MapCtrl:checkFromWhichType()
	if self.showDistribution then
		self.curStage = #self.view.scales - 1
		self.currentZoom = self.view.scales[self.curStage]

		self:scaleMap((#self.view.scales - self.curStage) * self.view.stepSize)
	elseif self.isUnlockArea then
		local veinMapLevel = SceneData[self.sceneId].veinMapLevel

		self.curStage = veinMapLevel
		self.currentZoom = self.view.scales[self.curStage]

		self:scaleMap((#self.view.scales - self.curStage) * self.view.stepSize)
		self.view.rootAni:Play("VX_Node_Delay_Show")
		self.view.markerListTransform:GetComponent("Animation"):Play("VX_Node_MarkerList_Show")
		pg.game.audio:triggerEvent(AudioConst.MAP_SYSTEM_START)
	elseif self.isFromLeylineFlowerPlenty then
		self.curStage = 1
		self.currentZoom = self.view.scales[self.curStage]

		self:scaleMap((#self.view.scales - self.curStage) * self.view.stepSize)
	elseif self.focusSmallArea then
		self.curStage = #self.view.scaleBasicTable
		self.currentZoom = self.view.scales[self.curStage]

		self:scaleMap((#self.view.scales - self.curStage) * self.view.stepSize)

		if self.mapPetAreaComponent then
			self.mapPetAreaComponent:setPetAreaProgressTipInfo(nil, false, self.focusSmallArea)
		end
	else
		self:scaleMap(pg.me.mapShowScaleMap[self.sceneId] or pg.game.map:getDefaultMapScaleRatio(self.sceneId))
	end

	self.view.sliderFakeUSlider.value = self.scaleValue
end

function MapCtrl:isMarkVisibleAtLogicTime(refreshLogicTimes)
	if not refreshLogicTimes then
		return true
	end

	local space = pg.me ~= nil and pg.me.space or nil

	if space == nil or space.logicTime == nil then
		return nil
	end

	local logicTime = space.logicTime

	for _, times in pairs(refreshLogicTimes) do
		if logicTime >= times[1] and logicTime <= times[2] then
			return true
		end
	end

	return false
end

function MapCtrl:checkMarkDisplay(button, refreshLogicTimes)
	if IsNil(button) then
		return
	end

	local visible = self:isMarkVisibleAtLogicTime(refreshLogicTimes)

	if visible == nil then
		return
	end

	button.visibility = visible and CS.XGUI.EVisibility.Visible or CS.XGUI.EVisibility.Hidden
end

function MapCtrl:onPinBtnClick(eventData, forceWorldX, forceWorldZ)
	if self.view.locationInfo.gameObject.activeSelf then
		local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
		local closeBtn = objectReference:GetRefValue("closeBtn")

		closeBtn.luaClick()

		return
	end

	if self.enableMultiDeleteMode then
		return
	end

	self.view.chooseList.gameObject:SetActiveEx(false)
	self:onChooseListSetActive(false)
	self:renderMultiIconSelectBox(false)

	local x, y

	if forceWorldX and forceWorldZ then
		x, y = pg.game.map:convertPos(forceWorldX, forceWorldZ, self.sceneId, true)
	else
		local curPlatform = ClientUtils.getAdaptionPlatform()

		if curPlatform == UIConst.PLATFORM.Mobile then
			x, y = self:getPointerPos(eventData.position)
		elseif curPlatform == UIConst.PLATFORM.Console then
			x, y = self:getPointerPos(eventData.position)
		else
			x, y = self:getPointerPos(UnityInput.mousePosition)
		end
	end

	if LuaUIUtils.checkFastTargetMark() then
		self:addCustomMapMark(x, y, "fastTrack")
	else
		self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(true)

		self.view.fakeCustomMarkUButton.transform.anchoredPosition = Vector3(x, y, 0)

		self.view.fakeCustomMarkUButton.transform:SetSiblingIndex(-1)
		self.view.fakeCustomMarkUButton.transform:GetComponent("ObjectReference"):GetRefValue("customUButton"):TryChangePage("IconType", 0)
		self:selectMark("FakeCustomMark")
		self:centralizeMark("FakeCustomMark")

		if self.view.locationInfo.gameObject.activeSelf then
			self.chooseListClick = false
		end

		self:openLocationPanel(true)
		self:setPinInfo(nil, nil, 0, nil, x, y)
	end

	local anchoredPosition = self.view.fakeCustomMarkUButton.transform.anchoredPosition
	local forceX, forceY = pg.game.map:convertPos(anchoredPosition.x, anchoredPosition.y, self.sceneId, false)
	local offset

	if MapOverlapScene[self.sceneId] and SceneData[self.sceneId] then
		local markWholemapOffset = SceneData[self.sceneId].wholemapOffset

		if markWholemapOffset and #markWholemapOffset == 3 then
			offset = markWholemapOffset
		end
	end

	if offset then
		forceX = forceX + offset[1]
		forceY = forceY + offset[3]
	end

	self:refreshCoordinate(forceX, forceY)
end

function MapCtrl:scrollMap(isLarger)
	if self.mapDragging then
		return
	end

	if isLarger == true then
		if self.curStage <= 1 then
			return
		end

		self.view.mapScroll.zoomTool.luaEndScale(self.curStage - 1, nil, nil, self.view.scaleOriTable[self.curStage - 1])
	else
		if self.curStage >= #self.view.scaleOriTable then
			return
		end

		self.view.mapScroll.zoomTool.luaEndScale(self.curStage + 1, nil, nil, self.view.scaleOriTable[self.curStage + 1])
	end
end

function MapCtrl:refreshMinMaxMapAnchoredPosXY(zoom)
	local referenceResolution = pg.global.uiMgr.uiRootCanvasRt:GetComponent("RectTransform")

	UIConst.MAP_CONST.FIXED_MAP_RECT_WIDTH = referenceResolution.sizeDelta[1]
	UIConst.MAP_CONST.FIXED_MAP_RECT_HEIGHT = referenceResolution.sizeDelta[2]
	UIConst.MAP_CONST.FIXED_MAP_WIDTH = self.view.mapScrollContent:GetComponent("RectTransform").sizeDelta[1]
	UIConst.MAP_CONST.FIXED_MAP_HEIGHT = self.view.mapScrollContent:GetComponent("RectTransform").sizeDelta[2]
	self.minMapAnchoredPosX = -(zoom * UIConst.MAP_CONST.FIXED_MAP_WIDTH - UIConst.MAP_CONST.FIXED_MAP_RECT_WIDTH) / 2
	self.maxMapAnchoredPosX = (zoom * UIConst.MAP_CONST.FIXED_MAP_WIDTH - UIConst.MAP_CONST.FIXED_MAP_RECT_WIDTH) / 2
	self.minMapAnchoredPosY = -(zoom * UIConst.MAP_CONST.FIXED_MAP_HEIGHT - UIConst.MAP_CONST.FIXED_MAP_RECT_HEIGHT) / 2
	self.maxMapAnchoredPosY = (zoom * UIConst.MAP_CONST.FIXED_MAP_HEIGHT - UIConst.MAP_CONST.FIXED_MAP_RECT_HEIGHT) / 2

	if zoom * UIConst.MAP_CONST.FIXED_MAP_WIDTH < UIConst.MAP_CONST.FIXED_MAP_RECT_WIDTH then
		self.minMapAnchoredPosX = 0
		self.maxMapAnchoredPosX = 0
	end

	if zoom * UIConst.MAP_CONST.FIXED_MAP_HEIGHT < UIConst.MAP_CONST.FIXED_MAP_RECT_HEIGHT then
		self.minMapAnchoredPosY = 0
		self.maxMapAnchoredPosY = 0
	end
end

function MapCtrl:getPointerPos(pos)
	if not pos then
		return 0, 0
	end

	local point

	point = pg.global.uiMgr:ScreenPointToLocalPoint(self.view.mapScrollContent, pos)

	return point.x + UIConst.MAP_CONST.FIXED_MAP_WIDTH / 2, point.y - UIConst.MAP_CONST.FIXED_MAP_HEIGHT / 2
end

function MapCtrl:revertMapPosToLocalPoint(mapX, mapY)
	return mapX - UIConst.MAP_CONST.FIXED_MAP_WIDTH / 2, mapY + UIConst.MAP_CONST.FIXED_MAP_HEIGHT / 2
end

function MapCtrl:recordLastPointerPosInScreen()
	local x, y
	local curPlatform = ClientUtils.getAdaptionPlatform()

	if curPlatform == UIConst.PLATFORM.Mobile then
		x, y = self:getPointerPos(self.twoFingersPosition)
	else
		self.mousePosition = UnityInput.mousePosition
		x, y = self:getPointerPos(self.mousePosition)
	end

	self.templateNode.anchoredPosition = Vector3(x, y, 0)
end

function MapCtrl:doMapOffset(zoom)
	local x, y
	local curPlatform = ClientUtils.getAdaptionPlatform()

	if curPlatform == UIConst.PLATFORM.Mobile then
		x, y = self:getPointerPos(self.twoFingersPosition)
	else
		x, y = self:getPointerPos(self.mousePosition)
	end

	local mapOffsetX = math.clamp(self.view.mapScrollContent.anchoredPosition.x + (x - self.templateNode.anchoredPosition.x) * zoom, self.minMapAnchoredPosX, self.maxMapAnchoredPosX)
	local mapOffsetY = math.clamp(self.view.mapScrollContent.anchoredPosition.y + (y - self.templateNode.anchoredPosition.y) * zoom, self.minMapAnchoredPosY, self.maxMapAnchoredPosY)

	self.view.mapScrollContent.anchoredPosition = Vector3(mapOffsetX, mapOffsetY, self.view.mapScrollContent.anchoredPosition.z)
end

function MapCtrl:refreshPlayerPosInMap()
	if self:isDifferentScene() then
		local x, y
		local scenePos = pg.me.recordPosMap[self.sceneId]

		if scenePos then
			x, y = pg.game.map:convertPos(scenePos[1], scenePos[3], self.sceneId, true)
		else
			x, y = pg.game.map:getDefaultMapPos(self.sceneId)
		end

		self.view.mineMarkTrans.anchoredPosition = Vector2(x, y)

		self.view.mineMarkTrans.gameObject:SetActiveEx(false)

		self.mineMarkMapPosX = x
		self.mineMarkMapPosY = y
	else
		local _ppx, _, _ppz = self.playerEModel:GetPositionAgentPosEx()
		local _, _pry, _ = self.playerEModel:GetPositionAgentLocalEulerEx()
		local x, y = pg.game.map:convertPos(_ppx, _ppz, self.sceneId, true)

		self.view.mineMarkTrans.anchoredPosition = Vector2(x, y)

		local rot = self.view.mineMarkTrans.rotation

		self.view.mineMarkTrans.rotation = Quaternion.Euler(rot.x, rot.y, -_pry)

		local controllingEgg = pg.space and pg.space:isGrabEgg() and pg.me ~= nil and ToBool(pg.me.controlEggId)

		self.view.mineMarkTrans.gameObject:SetActiveEx(not controllingEgg)

		self.mineMarkMapPosX = x
		self.mineMarkMapPosY = y
	end
end

function MapCtrl:getSourceFilterFocusMarkId(playerPos)
	local bestMarkId, bestDistance
	local playerOffsetX, playerOffsetZ = MapHelper.GetSceneOffset(pg.game.map:convertSceneId(self:_getCurrentSpaceSceneId()))

	for _, markData in ipairs({
		self.sceneMarkPointData,
		self.tempMarkPointData,
		self.teamMarkPointData
	}) do
		for markId, markInfo in pairs(markData) do
			if markInfo.markConfigId == self.tempFilter.configIds[1] and (not markInfo.ClickorNot or markInfo.ClickorNot == 0) and self:canLoadMark(markInfo, markId) and self:isMarkVisibleAtLogicTime(markInfo.refreshLogicTimes) ~= false then
				local status = self:markTypeProcessed(markId, markInfo.markType)

				if status >= Const.MAP_MARK_STATUS_LOCKED and status <= Const.MAP_MARK_STATUS_CLOSED and (not markInfo.UsableState or LuaUIUtils.tableContains(markInfo.UsableState, status)) then
					local pos = pg.game.map:getEffectiveMarkPos(markId, markInfo.markPosition)
					local offsetX, offsetZ = MapHelper.GetSceneOffset(pg.game.map:convertSceneId(markInfo.realSceneId or self.sceneId))
					local distance = (pos[1] + offsetX - playerPos[1] - playerOffsetX)^2 + (pos[2] - playerPos[2])^2 + (pos[3] + offsetZ - playerPos[3] - playerOffsetZ)^2

					if not bestMarkId or distance < bestDistance then
						bestMarkId, bestDistance = markId, distance
					end
				end
			end
		end
	end

	return bestMarkId
end

function MapCtrl:focusSourceFilterMark(markId)
	if not markId then
		return
	end

	self.centralizingMarkId = markId

	self:focusMark({
		string.format("mark_%s_%s", self:getMarkInfo(markId).markType, markId),
		self.tempFilter.stage,
		true,
		self.tempFilter.cb
	})

	if not self:shouldPreloadMark(self:getMarkInfo(markId), markId) and (self.markCaches[markId] or self.pointsTasks[markId]) then
		self.activeNormalMarks[markId] = true
		self.markLastSeen[markId] = self.markLruSeq
	end
end

function MapCtrl:loadAllMarks()
	for _, markId in ipairs(self.batchTempMarkPointData) do
		self:prepareMarkLoad(self.tempMarkPointData[markId], markId)
	end

	for _, markId in ipairs(self.batchSceneMarkPointData) do
		self:prepareMarkLoad(self.sceneMarkPointData[markId], markId)
	end

	self.teamMarkIds = {}

	if self.teamMarkPointData and next(self.teamMarkPointData) then
		for markId, markPointData in pairs(self.teamMarkPointData) do
			self.teamMarkIds[markId] = true

			self:prepareMarkLoad(markPointData, markId, true)
		end
	end

	if self.tempFilter and self.tempFilterFlag and self.tempFilter.configIds and #self.tempFilter.configIds > 0 then
		self.tempFilterFlag = nil

		self:focusSourceFilterMark(self:getSourceFilterFocusMarkId(pg.me:getPosition()))
	end
end

function MapCtrl:_canRunMapMarkLoads()
	return not self.mapMarkLoadStopped and self:checkUIVisible() and not self:checkUIClosing()
end

function MapCtrl:_pauseMapMarkLoads()
	self:killTimer(self.mapMarkLoadTimer)

	self.mapMarkLoadTimer = nil
end

function MapCtrl:_stopMapMarkLoads()
	self.mapMarkLoadStopped = true

	self:_pauseMapMarkLoads()

	self.mapMarkLoadQueue = nil
end

function MapCtrl:_startMapMarkLoads(loadMark)
	if self.mapMarkLoadStopped then
		return
	end

	local queue = self.mapMarkLoadQueue

	if loadMark then
		queue = queue or {
			index = 1
		}
		self.mapMarkLoadQueue = queue
		queue[#queue + 1] = loadMark
	end

	if not queue or self.mapMarkLoadTimer or not self:_canRunMapMarkLoads() then
		return
	end

	self.mapMarkLoadTimer = self:startTimer(function()
		local frame = CS.UnityEngine.Time.frameCount

		if frame == self.mapMarkLoadLastFrame then
			return
		end

		local loadedCount = 0

		for _ = 1, MAP_MARK_FRAME_SCAN_MAX_COUNT do
			if self.mapMarkLoadQueue ~= queue then
				return
			end

			local load = queue[queue.index]

			if not load or not self:_canRunMapMarkLoads() then
				self:_pauseMapMarkLoads()

				if not load then
					self.mapMarkLoadQueue = nil
				end

				return
			end

			self.mapMarkLoadLastFrame = frame
			queue[queue.index] = false
			queue.index = queue.index + 1

			if load() then
				loadedCount = loadedCount + 1

				if loadedCount >= MAP_MARK_FRAME_LOAD_MAX_COUNT then
					return
				end
			end
		end
	end, 0, true)
end

function MapCtrl:prepareMarkLoad(markPointData, spawnerId, forceLoad)
	if not self:canLoadMark(markPointData, spawnerId) then
		return
	end

	self:processMarkQuestOverlap(markPointData, spawnerId)

	if forceLoad or self:shouldPreloadMark(markPointData, spawnerId) then
		self:addMarks(markPointData, spawnerId)

		return
	end

	self:_enqueuePendingMark(markPointData, spawnerId)
end

function MapCtrl:_enqueuePendingMark(markPointData, spawnerId)
	if not self.pendingMarkLoads then
		self.pendingMarkLoads = {}
		self.pendingMarkLoadOrder = {}
		self.pendingTempMarkOrder = {}
	end

	if not self.pendingMarkLoads[spawnerId] then
		self.pendingMarkLoadOrder[#self.pendingMarkLoadOrder + 1] = spawnerId

		if self.tempMarkPointData and self.tempMarkPointData[spawnerId] then
			self.pendingTempMarkOrder = self.pendingTempMarkOrder or {}
			self.pendingTempMarkOrder[#self.pendingTempMarkOrder + 1] = spawnerId
		end
	end

	self.pendingMarkLoads[spawnerId] = markPointData
end

function MapCtrl:processMarkQuestOverlap(markPointData, spawnerId)
	if not pg.game.map.sceneMarkQuestPointData or not markPointData then
		return
	end

	self.questOverlapProcessed = self.questOverlapProcessed or {}

	if self.questOverlapProcessed[spawnerId] then
		return
	end

	self.questOverlapProcessed[spawnerId] = true

	local questMark = pg.game.map:getQuestMarkByAssocSpawnerId(spawnerId)

	if questMark then
		if pg.game.map.sceneMarkQuestOverlapPoint[questMark.questId] == nil then
			pg.game.map.sceneMarkQuestOverlapPoint[questMark.questId] = {}
		end

		local temp = {}

		temp.spawnerId = spawnerId
		temp.addQuestTagId = questMark.questId
		temp.objId = questMark.objId
		temp.addQuestTagShow = false

		if pg.game.map:isEnabledByFilter(self.sceneId, markPointData.markConfigId, markPointData.markStatus, spawnerId, {
			finishStateAlwaysShow = markPointData.finishStateAlwaysShow
		}) then
			temp.addQuestTagShow = true
		end

		if not pg.game.map:isContainShowQuestTagMarkId(questMark.questId, spawnerId) then
			table.insert(pg.game.map.sceneMarkQuestOverlapPoint[questMark.questId], temp)
		end

		if not pg.game.map:getContainMarkSpawnerId(spawnerId) then
			pg.game.map.sceneMarkPointDataOverlap[spawnerId] = {
				questId = questMark.questId,
				objId = questMark.objId,
				markType = markPointData.markType
			}
		end
	end
end

function MapCtrl:canLoadMark(markPointData, spawnerId)
	if not markPointData then
		return false
	end

	if markPointData.sceneId and markPointData.sceneId ~= self.sceneId then
		return false
	end

	if not markPointData.markPosition then
		return false
	end

	if pg.me.tempCamp and markPointData.affiliatedCamp and next(markPointData.affiliatedCamp) and not LuaUIUtils.tableContains(markPointData.affiliatedCamp, 0) and not LuaUIUtils.tableContains(markPointData.affiliatedCamp, pg.me.tempCamp) then
		return false
	end

	if markPointData.ShoworNot ~= 1 then
		return false
	end

	local status = self:markTypeProcessed(spawnerId, markPointData.markType)

	return status ~= Const.MAP_MARK_STATUS_HIDE or markPointData.markType == Const.MAP_MARK_QUEST or markPointData.markType == Const.MAP_MARK_CLUE or markPointData.markType == Const.MAP_MARK_CUSTOM or markPointData.markType == Const.MAP_MARK_SHARE or markPointData.markType == Const.MAP_MARK_TRACE or markPointData.markType == Const.MAP_MARK_ALLY or markPointData.markType == Const.MAP_MARK_FAST_TARGET or markPointData.markType == Const.MAP_MARK_GOLD_MONSTER or pg.game.map:getTempWhiteListMarkData(spawnerId)
end

function MapCtrl:ensureStartMarkLoaded(startSpawnerId)
	if not startSpawnerId or self.markCaches[startSpawnerId] then
		return
	end

	local markPointData = self:getMarkInfo(startSpawnerId)

	if not markPointData then
		return
	end

	self:prepareMarkLoad(markPointData, startSpawnerId, true)

	if self.activeNormalMarks and (self.markCaches[startSpawnerId] or self.pointsTasks and self.pointsTasks[startSpawnerId]) then
		self.activeNormalMarks[startSpawnerId] = true
		self.markLastSeen[startSpawnerId] = self.markLruSeq or 0
	end
end

function MapCtrl:shouldPreloadMark(markPointData, spawnerId)
	if not markPointData then
		return false
	end

	if self:_checkTrackMarkExists(spawnerId) or pg.game.map:isTrackPathStartSpawner(spawnerId) then
		return true
	end

	if pg.game.map:getTempWhiteListMarkData(spawnerId) then
		return true
	end

	local defaultData = DefaultMapMarkData[markPointData.markConfigId]

	if defaultData and defaultData.globalBubble == 1 then
		return true
	end

	return markPointData.markType == Const.MAP_MARK_QUEST or markPointData.markType == Const.MAP_MARK_CUSTOM or markPointData.markType == Const.MAP_MARK_SHARE or markPointData.markType == Const.MAP_MARK_TRACE or markPointData.markType == Const.MAP_MARK_ALLY or markPointData.markType == Const.MAP_MARK_FAST_TARGET or markPointData.markType == Const.MAP_MARK_GOLD_MONSTER or markPointData.markType == Const.MAP_MARK_ZONE
end

function MapCtrl:isMarkInCurrentView(markPointData, spawnerId)
	if not self.markBubbleComponent then
		return false
	end

	if not self:canLoadMark(markPointData, spawnerId) then
		return false
	end

	if not pg.game.map:isEnabledByTotalFilter(self.sceneId, markPointData.markConfigId) then
		return false
	end

	local status = self:markTypeProcessed(spawnerId, markPointData.markType)

	if not pg.game.map:isEnabledByFilter(self.sceneId, markPointData.markConfigId, status, spawnerId, {
		finishStateAlwaysShow = markPointData.finishStateAlwaysShow
	}) then
		return false
	end

	local scaleKey = string.format("scale%s", self:curStageScaleConvertor(self.curStage))

	if markPointData[scaleKey] ~= 1 and not self:shouldPreloadMark(markPointData, spawnerId) then
		return false
	end

	local pos = pg.game.map:getEffectiveMarkPos(spawnerId, markPointData.markPosition)
	local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], markPointData.realSceneId or self.sceneId, true)

	return not self.markBubbleComponent:isOutOfViewPort(mapX, mapY)
end

function MapCtrl:isMarkOutOfRecycleRange(spawnerId)
	if self:isMarkPinned(spawnerId) then
		return false
	end

	local data = self:getMarkInfo(spawnerId)

	if not data or not data.markPosition then
		return true
	end

	local bub = self.markBubbleComponent

	if not bub or not bub.leftBotX then
		return false
	end

	local pos = pg.game.map:getEffectiveMarkPos(spawnerId, data.markPosition)
	local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], data.realSceneId or self.sceneId, true)
	local padX = (bub.rightTopX - bub.leftBotX) * RECYCLE_VIEWPORT_PADDING
	local padY = (bub.rightTopY - bub.leftBotY) * RECYCLE_VIEWPORT_PADDING

	return mapX < bub.leftBotX - padX or mapX > bub.rightTopX + padX or mapY < bub.leftBotY - padY or mapY > bub.rightTopY + padY
end

function MapCtrl:isMarkPinned(spawnerId)
	if self.centralizingMarkId and self.centralizingMarkId == spawnerId then
		return true
	end

	if pg.game.map:shouldForceVisibleMark(spawnerId) then
		return true
	end

	if self.curSelectedBtn then
		for btn in pairs(self.curSelectedBtn) do
			if NotNil(btn) and self.model:getSpawnerIdByMarkName(btn.name) == spawnerId then
				return true
			end
		end
	end

	return false
end

function MapCtrl:collectCandidateSpawners()
	local bub = self.markBubbleComponent
	local chunkData = pg.game.map.sceneMarkPointChunkData

	if self:isDifferentScene() then
		return self.pendingMarkLoadOrder
	end

	if not bub or not bub.leftBotX or not chunkData then
		return self.pendingMarkLoadOrder
	end

	local rootSceneId = MapHelper.getRootScene(self.sceneId)
	local wMinX, wMinZ = pg.game.map:convertPos(bub.leftBotX, bub.leftBotY, rootSceneId, false)
	local wMaxX, wMaxZ = pg.game.map:convertPos(bub.rightTopX, bub.rightTopY, rootSceneId, false)

	if wMaxX < wMinX then
		wMinX, wMaxX = wMaxX, wMinX
	end

	if wMaxZ < wMinZ then
		wMinZ, wMaxZ = wMaxZ, wMinZ
	end

	local gap = MapHelper.CHUNK_GAP
	local minXKey = math.floor(wMinX / gap)
	local maxXKey = math.floor(wMaxX / gap)
	local minZKey = math.floor(wMinZ / gap)
	local maxZKey = math.floor(wMaxZ / gap)
	local result = {}

	for xKey = minXKey, maxXKey do
		local xChunk = chunkData[xKey]

		if xChunk then
			for zKey = minZKey, maxZKey do
				local list = xChunk[zKey]

				if list then
					for _, markId in ipairs(list) do
						if self.pendingMarkLoads[markId] then
							result[#result + 1] = markId
						end
					end
				end
			end
		end
	end

	if self.pendingTempMarkOrder then
		local kept = {}

		for _, markId in ipairs(self.pendingTempMarkOrder) do
			if self.pendingMarkLoads[markId] then
				kept[#kept + 1] = markId
				result[#result + 1] = markId
			end
		end

		self.pendingTempMarkOrder = kept
	end

	return result
end

function MapCtrl:loadVisibleMarks(maxLoad)
	if not self.pendingMarkLoads or not self.markBubbleComponent then
		return
	end

	maxLoad = maxLoad or VISIBLE_MARK_LOAD_BATCH
	self.markLruSeq = (self.markLruSeq or 0) + 1

	local seq = self.markLruSeq

	if self.activeNormalMarks then
		for spawnerId in pairs(self.activeNormalMarks) do
			if self:isMarkOutOfRecycleRange(spawnerId) then
				self:recycleNormalMark(spawnerId)
			else
				self.markLastSeen[spawnerId] = seq
			end
		end
	end

	local loadedCount = 0
	local candidates = self:collectCandidateSpawners()

	for i = 1, #candidates do
		if maxLoad <= loadedCount then
			break
		end

		local markId = candidates[i]
		local markPointData = self.pendingMarkLoads[markId]

		if markPointData and self:isMarkInCurrentView(markPointData, markId) then
			self:addMarks(markPointData, markId)

			self.activeNormalMarks[markId] = true
			self.markLastSeen[markId] = seq
			loadedCount = loadedCount + 1
		end
	end

	self:evictOverflowNormalMarks()

	return loadedCount
end

function MapCtrl:reclaimUnusedMarkPrefabs(prefabPath, requiredCount)
	if prefabPath ~= AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON or not self.activeNormalMarks then
		return 0
	end

	local statsBefore = MapMarkPrefabPoolManager:GetStats(prefabPath)
	local idleBefore = statsBefore and statsBefore.idleCount or 0

	for spawnerId in pairs(self.activeNormalMarks) do
		if self:isMarkOutOfRecycleRange(spawnerId) then
			local cache = self.markCaches and self.markCaches[spawnerId]
			local lease = cache and cache.commonIconLease

			if lease then
				self:recycleNormalMark(spawnerId)
			end

			local currentStats = MapMarkPrefabPoolManager:GetStats(prefabPath)

			if currentStats and currentStats.idleCount - idleBefore >= (requiredCount or 1) then
				break
			end
		end
	end

	local statsAfter = MapMarkPrefabPoolManager:GetStats(prefabPath)

	return statsAfter and math.max(0, statsAfter.idleCount - idleBefore) or 0
end

function MapCtrl:recycleNormalMark(spawnerId)
	if not self.activeNormalMarks or not self.activeNormalMarks[spawnerId] then
		return
	end

	local markPointData = self:getMarkInfo(spawnerId)

	if markPointData and self:shouldPreloadMark(markPointData, spawnerId) then
		return
	end

	self:_removeMapMark(spawnerId)

	self.activeNormalMarks[spawnerId] = nil
	self.markLastSeen[spawnerId] = nil

	if markPointData and self.pendingMarkLoads then
		self:_enqueuePendingMark(markPointData, spawnerId)
	end
end

function MapCtrl:evictOverflowNormalMarks()
	if not self.activeNormalMarks then
		return
	end

	local maxActive = self.normalMarkMaxActive or NORMAL_MARK_MAX_ACTIVE_DEFAULT
	local arr = {}

	for spawnerId in pairs(self.activeNormalMarks) do
		arr[#arr + 1] = spawnerId
	end

	if maxActive >= #arr then
		return
	end

	table.sort(arr, function(a, b)
		return (self.markLastSeen[a] or 0) < (self.markLastSeen[b] or 0)
	end)

	local toEvict = #arr - maxActive

	for i = 1, #arr do
		if toEvict <= 0 then
			break
		end

		local spawnerId = arr[i]

		if self:isMarkOutOfRecycleRange(spawnerId) then
			self:recycleNormalMark(spawnerId)

			toEvict = toEvict - 1
		end
	end
end

function MapCtrl:requestLoadVisibleMarks()
	if self.visibleMarkLoadTimer then
		return
	end

	self.visibleMarkLoadTimer = self:startTimer(function()
		self.visibleMarkLoadTimer = nil

		local loadedCount = self:loadVisibleMarks()

		if loadedCount and loadedCount >= VISIBLE_MARK_LOAD_BATCH then
			self:requestLoadVisibleMarks()
		end
	end, 0.05, false)
end

function MapCtrl:addMarks(markPointData, spawnerId)
	if self.markCaches and self.markCaches[spawnerId] then
		return
	end

	if self.pointsTasks and self.pointsTasks[spawnerId] then
		return
	end

	if markPointData.sceneId and markPointData.sceneId ~= self.sceneId then
		return
	end

	if not markPointData.markPosition then
		return
	end

	if pg.me.tempCamp and markPointData.affiliatedCamp and next(markPointData.affiliatedCamp) and not LuaUIUtils.tableContains(markPointData.affiliatedCamp, 0) and not LuaUIUtils.tableContains(markPointData.affiliatedCamp, pg.me.tempCamp) then
		return
	end

	self:processMarkQuestOverlap(markPointData, spawnerId)

	if markPointData.ShoworNot == 1 and (self:markTypeProcessed(spawnerId, markPointData.markType) ~= Const.MAP_MARK_STATUS_HIDE or markPointData.markType == Const.MAP_MARK_QUEST or markPointData.markType == Const.MAP_MARK_CLUE or markPointData.markType == Const.MAP_MARK_CUSTOM or markPointData.markType == Const.MAP_MARK_SHARE or markPointData.markType == Const.MAP_MARK_TRACE or markPointData.markType == Const.MAP_MARK_ALLY or markPointData.markType == Const.MAP_MARK_FAST_TARGET or markPointData.markType == Const.MAP_MARK_GOLD_MONSTER or pg.game.map:getTempWhiteListMarkData(spawnerId)) then
		if self.pendingMarkLoads then
			self.pendingMarkLoads[spawnerId] = nil
		end

		self:loadRes(spawnerId, markPointData)
	end
end

function MapCtrl:diffSceneTrack(spawnerId, spawnerTable, isSwitchingMap)
	if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId and not isSwitchingMap then
		return
	end

	self.differentSceneTrackMark = spawnerId

	pg.game.map:trackDiffSceneMark(self.sceneId, spawnerId, spawnerTable, function(result)
		self:swapMarkLayer(spawnerId, 99, nil)

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].lowerDynamicLoadTransform then
			self:checkTrackTaskAndObjStatus(true)
			self:_cleanupTrackPrefab(spawnerId)

			self.markCaches[spawnerId].trackTaskId = self.view:addPrefabWithPathAsync(self.markCaches[spawnerId].lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_TRACK, function(obj)
				self.markCaches[spawnerId].trackObj = obj.gameObject
				self.trackTaskObjTable[spawnerId] = obj.gameObject
			end, false, false, 0)
			self.trackTaskTable[spawnerId] = self.markCaches[spawnerId].trackTaskId
		end

		if not result then
			local now = Time.realSecondCache or 0
			local shouldShow = not self._lastTrackFailTipTime or now - self._lastTrackFailTipTime > 0.3

			if shouldShow then
				self._lastTrackFailTipTime = now

				pg.global.showBubbleMessageById(2128)
			end
		else
			self:ensureStartMarkLoaded(result.startSpawnerId)

			if not self.markCaches[result.startSpawnerId] then
				self.diffSceneTrackDelayFlag = result.startSpawnerId
				self.diffSceneTrackIsSwitchingMap = isSwitchingMap and not self.openLocateIntent

				self.mapNavLineComponent:drawNavEffLine({
					path = result.path,
					sceneId = result.sceneId
				})
			else
				self.mapNavLineComponent:drawNavEffLine({
					path = result.path,
					sceneId = result.sceneId
				}, self.markCaches[result.startSpawnerId].button, not isSwitchingMap and not self.openLocateIntent and result.startSpawnerId or nil)
			end
		end
	end)
end

function MapCtrl:addCustomMapMark(mapX, mapY, markTex)
	if self:checkFogBlocked(mapX, mapY) then
		return
	end

	local x, z = pg.game.map:convertPos(mapX, mapY, self.sceneId, false)

	local function inner(highestPoint)
		pg.me:sensitiveWordsCheck(markTex, function(text)
			local markId = LuaUIUtils.checkFastTargetMark() and self.uid or self.selectedMarkIndex == nil and 0 or self.selectedMarkIndex

			pg.me:serverMsg("RPC_CS_AddCustomMapMark", self.sceneId, markId, {
				highestPoint[1],
				highestPoint[2],
				highestPoint[3]
			}, text)
		end)
	end

	local spaceType
	local me = pg.me

	if me ~= nil then
		local space = me.space

		if space ~= nil then
			spaceType = space.spaceType
		end
	end

	if spaceType ~= nil and Utils.isRobEggUnderGround(spaceType) then
		local _, playerY, _ = self.playerEModel:GetPositionAgentPosEx()

		inner({
			x,
			playerY,
			z
		})
	else
		pg.game.map:findHighestNavMeshPoint(self.sceneId, x, z, function(highestPoint)
			inner(highestPoint)
		end)
	end
end

function MapCtrl:setPinInfo(markButton, spawnerId, selectedPin, objInfo, mapX, mapY, spawnerTable)
	if self.mapMarkFilterComponent.panelOpened then
		self.mapMarkFilterComponent:closePanel()
	end

	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:closePanel()
	end

	self.locationInfoPanelCurMarkId = spawnerId

	local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
	local closeBtn = objectReference:GetRefValue("closeBtn")
	local iconList = objectReference:GetRefValue("iconList")
	local pinTrackBtn = objectReference:GetRefValue("pinTrackBtn")
	local pinUnTrackBtn = objectReference:GetRefValue("pinUnTrackBtn")
	local pinStickBtn = objectReference:GetRefValue("pinStickBtn")
	local btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	local btnDeleteMultiUButton = objectReference:GetRefValue("btnDeleteMultiUButton")
	local customMarkCountText = objectReference:GetRefValue("customMarkCountText")
	local inputFilterUInputField = objectReference:GetRefValue("inputFilterUInputField")
	local editNameBtnUButton = objectReference:GetRefValue("editNameBtnUButton")

	local function closeHandler()
		local genId = MapHelper.getCustomMarkGenId(spawnerId, self.sceneId)

		if genId then
			local txt = inputFilterUInputField.text

			if string.isNilOrEmpty(txt) then
				txt = inputFilterUInputField.placeHolder.text
			end

			pg.me:sensitiveWordsCheck(txt, function(text)
				pg.me:serverMsg("RPC_CS_UpdateCustomMapMark", self.sceneId, genId, {
					name = text
				})
				self:findChooseListCustomItem(spawnerId, text)
			end)
		end

		self:openLocationPanel(false)
		self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)
		self:deselectAll()

		if self.chooseListClick then
			self.view.chooseList.gameObject:SetActiveEx(true)
			self:onChooseListSetActive(true)

			local btns = self.view.chooseList:GetAllButtons()

			btns[self.chooseListIndex or 0].isSelected = true

			if not self.enableMultiDeleteMode then
				self:renderMultiIconSelectBox(true, self.stackIcons)
			end
		end

		self.chooseListClick = false

		self.layerComponent:setListData(self.sceneId, true)
	end

	closeBtn.luaClick = closeHandler
	self.currentLocationInfoCloseBtn = closeBtn
	self.currentLocationInfoCloseHandler = closeHandler

	local _h = MapCtrl._platformHooks

	if _h and _h.shouldHideLocationInfoCloseBtn then
		_h.shouldHideLocationInfoCloseBtn(self)
	end

	self.view.locationInfo:TryChangePage("PageState", 1)

	function iconList.luaRenderItem(button, index, _)
		self:pinIconListRender(button, index, selectedPin, objInfo, spawnerId)
	end

	local tempTable = {}

	for i = 1, 7 do
		local t = {}

		tempTable[i] = t
	end

	iconList:SetList(tempTable)

	local page

	page = (self:_checkTrackMarkExists(spawnerId) or self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId) and 3 or spawnerId ~= nil and 1 or 2

	self.view.locationInfo:TryChangePage("MapMarkButtonStates", page)
	btnDeleteUButton.gameObject:SetActiveEx(spawnerId ~= nil)

	if self:countCustomMark() <= 0 then
		if page == 2 then
			pinStickBtn.gameObject:SetActiveEx(true)
		end

		ClientTextUtils.setText(customMarkCountText, "0/", UIConst.MAP_CONST.MAX_CUSTOM_MARK_COUNT)
	else
		if page == 2 then
			pinStickBtn.gameObject:SetActiveEx(self:countCustomMark() < UIConst.MAP_CONST.MAX_CUSTOM_MARK_COUNT)
		end

		ClientTextUtils.setText(customMarkCountText, self:countCustomMark() .. "/" .. UIConst.MAP_CONST.MAX_CUSTOM_MARK_COUNT)
	end

	ClientTextUtils.setText(inputFilterUInputField, "")
	ClientTextUtils.setText(inputFilterUInputField.placeHolder, self.model:getCustomMarkName(spawnerId, self.sceneId))

	function editNameBtnUButton.luaClick()
		if spawnerId == nil then
			return
		end

		local genId = MapHelper.getCustomMarkGenId(spawnerId, self.sceneId)

		if genId then
			local txt = inputFilterUInputField.text

			if string.isNilOrEmpty(txt) then
				txt = inputFilterUInputField.placeHolder.text
			end

			pg.me:sensitiveWordsCheck(txt, function(text)
				pg.me:serverMsg("RPC_CS_UpdateCustomMapMark", self.sceneId, genId, {
					name = text
				})
				self:findChooseListCustomItem(spawnerId, text)
			end)
		end
	end

	function pinStickBtn.luaClick()
		if spawnerId == nil then
			self:addCustomMapMark(mapX, mapY, inputFilterUInputField.text)
		end
	end

	self.pinStickBtn = pinStickBtn

	function btnDeleteUButton.luaClick()
		local sceneIdLen = #tostring(self.sceneId)
		local markTypeLen = #tostring(Const.MAP_MARK_CUSTOM)
		local configIdLen = #tostring(Const.MAP_MARK_CUSTOM)
		local spawnerIdLen = #tostring(spawnerId)
		local genId = tonumber(string.sub(tostring(spawnerId), -(spawnerIdLen - sceneIdLen - markTypeLen - configIdLen)))

		pg.me:serverMsg("RPC_CS_DelCustomMapMark", self.sceneId, genId)

		if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
			self.mapNavLineComponent:drawNavEffLine()

			self.differentSceneTrackMark = nil
		end
	end

	self.btnDeleteUButton = btnDeleteUButton

	local function trackInner(noNeedMinimap)
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", 3)
		self:swapMarkLayer(spawnerId, 99, nil)

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].lowerDynamicLoadTransform then
			self:checkTrackTaskAndObjStatus(noNeedMinimap)
			self:_cleanupTrackPrefab(spawnerId)

			self.markCaches[spawnerId].trackTaskId = self.view:addPrefabWithPathAsync(self.markCaches[spawnerId].lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_TRACK, function(obj)
				self.markCaches[spawnerId].trackObj = obj.gameObject
				self.trackTaskObjTable[spawnerId] = obj.gameObject
			end, false, false, 0)
			self.trackTaskTable[spawnerId] = self.markCaches[spawnerId].trackTaskId
		end
	end

	local function unTrackInner()
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", spawnerId ~= nil and 1 or 2)

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].trackTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].trackTaskId)
		end

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].trackObj then
			self.view:destroyInstance(self.markCaches[spawnerId].trackObj)
		end

		self:swapMarkLayer(spawnerId, nil, true)
		pg.game.map:unStoreTrackMarks(spawnerId)
	end

	function pinTrackBtn.luaClick()
		if self:checkFogBlocked(mapX, mapY) then
			return
		end

		if self:isDifferentScene() then
			if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
				return
			end

			self.differentSceneTrackMark = spawnerId

			pg.game.map:trackDiffSceneMark(self.sceneId, spawnerId, spawnerTable, function(result)
				trackInner(true)

				if not result then
					pg.global.showBubbleMessageById(2128)
				else
					self:ensureStartMarkLoaded(result.startSpawnerId)

					if not self.markCaches[result.startSpawnerId] then
						self.diffSceneTrackDelayFlag = result.startSpawnerId

						self.mapNavLineComponent:drawNavEffLine({
							path = result.path,
							sceneId = result.sceneId
						})
					else
						self.mapNavLineComponent:drawNavEffLine({
							path = result.path,
							sceneId = result.sceneId
						}, self.markCaches[result.startSpawnerId].button, result.startSpawnerId)
					end
				end
			end)

			return
		end

		local miniMap = self:_getMiniMapComponent()

		if not miniMap then
			return
		end

		miniMap:addTrackMark(Const.MAP_MARK_CUSTOM, spawnerId, function()
			trackInner()
		end)
	end

	function pinUnTrackBtn.luaClick()
		if self:isDifferentScene() then
			unTrackInner()

			if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
				self.differentSceneTrackMark = nil

				self.mapNavLineComponent:drawNavEffLine()
			end
		else
			local miniMap = self:_getMiniMapComponent()

			if not miniMap then
				return
			end

			miniMap:deleteTrackMark(spawnerId, function()
				unTrackInner()
			end)
		end
	end

	self.pinTrackBtn = pinTrackBtn
	self.pinUnTrackBtn = pinUnTrackBtn

	function btnDeleteMultiUButton.luaClick()
		self:enableMultiDeletePanel(true)

		local genId = MapHelper.getCustomMarkGenId(spawnerId, self.sceneId)

		if genId then
			local txt = inputFilterUInputField.text

			if string.isNilOrEmpty(txt) then
				txt = inputFilterUInputField.placeHolder.text
			end

			pg.me:sensitiveWordsCheck(txt, function(text)
				pg.me:serverMsg("RPC_CS_UpdateCustomMapMark", self.sceneId, genId, {
					name = text
				})
				self:findChooseListCustomItem(spawnerId, text)
			end)
		end

		self:openLocationPanel(false)

		self.chooseListClick = false

		self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)
	end
end

function MapCtrl:findChooseListCustomItem(spawnerId, text)
	local btns = self.view.chooseList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].name == tostring(spawnerId) then
			self:renderChooseList(btns[i], {
				spawnerId = spawnerId,
				markType = Const.MAP_MARK_CUSTOM,
				customMarkName = text
			})
		end
	end
end

function MapCtrl:_cleanupTrackPrefab(spawnerId)
	if not spawnerId then
		return
	end

	local cache = self.markCaches[spawnerId]
	local taskId = cache and cache.trackTaskId or self.trackTaskTable[spawnerId]

	if taskId then
		self.view:cancelUIAsyncTask(taskId)
	end

	local trackObj = cache and cache.trackObj or self.trackTaskObjTable[spawnerId]

	if trackObj and self.view:checkInstanceExists(trackObj) then
		self.view:destroyInstance(trackObj)
	end

	if cache then
		cache.trackTaskId = nil
		cache.trackObj = nil
	end

	self.trackTaskTable[spawnerId] = nil
	self.trackTaskObjTable[spawnerId] = nil
end

function MapCtrl:checkTrackTaskAndObjStatus(noNeedMinimap)
	if noNeedMinimap then
		for spawnerId, v in pairs(self.trackTaskTable) do
			self.view:cancelUIAsyncTask(v)

			self.trackTaskTable[spawnerId] = nil
		end

		for spawnerId, v in pairs(self.trackTaskObjTable) do
			self.view:destroyInstance(v)

			self.trackTaskObjTable[spawnerId] = nil
		end

		return
	end

	for spawnerId, v in pairs(self.trackTaskTable) do
		if not self:_checkTrackMarkExists(spawnerId) then
			self.view:cancelUIAsyncTask(v)

			self.trackTaskTable[spawnerId] = nil
		end
	end

	for spawnerId, v in pairs(self.trackTaskObjTable) do
		if not self:_checkTrackMarkExists(spawnerId) then
			self.view:destroyInstance(v)

			self.trackTaskObjTable[spawnerId] = nil
		end
	end
end

function MapCtrl:renderEggPoiInfo(objectReference, spawnerId, spawnerTable)
	local robEggUContainer = objectReference:GetRefValue("robEgg")

	if IsNil(robEggUContainer) then
		local selectIconUComponent = objectReference:GetRefValue("selectIconUComponent")

		if NotNil(selectIconUComponent) then
			local robEggTransform = selectIconUComponent.transform:Find("Title/GetEggPoi")

			if NotNil(robEggTransform) then
				robEggUContainer = robEggTransform:GetComponent("UContainer")
			end
		end
	end

	if IsNil(robEggUContainer) then
		return
	end

	local eggView = GrabEggMapMarkUtils.getEggView(spawnerId)
	local resData = MapMarkResourceData[spawnerTable.markConfigId]
	local defaultRes = resData and (resData[self.sceneId] or resData[0])
	local iconImgPath = defaultRes and defaultRes.icon

	local function applyView(content)
		if IsNil(content) then
			return
		end

		local eggObjRef = content:GetComponent("ObjectReference")

		if NotNil(eggObjRef) then
			GrabEggMapMarkUtils.applyEggMarkView(eggObjRef, eggView, iconImgPath)
		end
	end

	if robEggUContainer:CheckURLLoaded() then
		applyView(robEggUContainer.content)
	else
		robEggUContainer:LoadDefaultUrlManually(applyView)
	end
end

function MapCtrl:onLocationInfoCloseBtnClick()
	self:openLocationPanel(false)
	self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)
	self:deselectAll()

	if self.chooseListClick then
		self.view.chooseList.gameObject:SetActiveEx(true)
		self:onChooseListSetActive(true)

		local btns = self.view.chooseList:GetAllButtons()

		btns[self.chooseListIndex or 0].isSelected = true

		if not self.enableMultiDeleteMode then
			self:renderMultiIconSelectBox(true, self.stackIcons)
		end
	end

	self.chooseListClick = false

	self.layerComponent:setListData(self.sceneId, true)
end

function MapCtrl:renderRainbowPetPoiInfo(objectReference, spawnerId, spawnerTable)
	objectReference:GetRefValue("selectIconUComponent"):TryChangePage("Title", 1)

	local container = objectReference:GetRefValue("containerUContainer")

	container:SetActiveFastest(true)
	container:SetUrlWithCallback(AddressDataConst.UI_MAP_MARK_CULTIVATE, function(content)
		if self.locationInfoPanelCurMarkId ~= spawnerId or not content then
			return
		end

		local contentReference = content.transform:GetComponent("ObjectReference")
		local petTemplateId = MapHelper.getRainbowPetTemplateIdByPointId(spawnerId, spawnerTable.realSceneId or self.sceneId)

		LuaUIUtils.setRainbowPetNameText(contentReference:GetRefValue("textTitleUSDFText"), petTemplateId)
		ClientTextUtils.setText(contentReference:GetRefValue("textSubUSDFText"), pg.getLocalizationText(spawnerTable.infoTitle))

		local cultivateRectTransform = contentReference:GetRefValue("cultivateRectTransform")
		local cultivateReference = cultivateRectTransform and cultivateRectTransform:GetComponent("ObjectReference")

		if cultivateReference then
			LuaUIUtils.renderRainbowPetIcon(cultivateReference:GetRefValue("playerHeadRectTransform"), petTemplateId)
		end
	end)
end

function MapCtrl:setLocationInfo(markButton, spawnerId, spawnerTable, infoTitle, infoImage, infoText, enableTeleportBtn, rewardTableForce)
	if self.mapMarkFilterComponent.panelOpened then
		self.mapMarkFilterComponent:closePanel()
	end

	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:closePanel()
	end

	self.locationInfoPanelCurMarkId = spawnerId

	local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
	local iconImg = objectReference:GetRefValue("iconImg")
	local titleTxt = objectReference:GetRefValue("titleTxt")
	local previewImgImg = objectReference:GetRefValue("previewImgImg")
	local closeBtn = objectReference:GetRefValue("closeBtn")
	local locationTeleportBtn = objectReference:GetRefValue("locationTeleportBtn")
	local locationTrackBtn = objectReference:GetRefValue("locationTrackBtn")
	local locationUnTrackBtn = objectReference:GetRefValue("locationUnTrackBtn")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local allShareMarkUButton = objectReference:GetRefValue("allShareMarkUButton")
	local markDetailsUButton = objectReference:GetRefValue("markDetailsUButton")
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local btnUnTrackUButton = objectReference:GetRefValue("btnUnTrackUButton")
	local btnUnTrackUButton1 = objectReference:GetRefValue("btnUnTrackUButton1")

	local function closeHandler()
		self:onLocationInfoCloseBtnClick()
	end

	closeBtn.luaClick = closeHandler
	self.currentLocationInfoCloseBtn = closeBtn
	self.currentLocationInfoCloseHandler = closeHandler

	local _h = MapCtrl._platformHooks

	if _h and _h.shouldHideLocationInfoCloseBtn then
		_h.shouldHideLocationInfoCloseBtn(self)
	end

	btnUnTrackUButton.interactable = false

	function btnUnTrackUButton1.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("UNTRACK_QUEST_MARK"))
	end

	function allShareMarkUButton.luaClick()
		local hudCtrl = pg.global.ui.hudV2

		hudCtrl:openFuncMenu(nil, function()
			if not CommonSwitch.MARK_SHARE then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_EDIT, nil, function()
				pg.global.ui.markShareEdit.view.btnHistoryUButton:OnClickSimulate()
			end)
		end)
		self:closePanel(true)
	end

	function markDetailsUButton.luaClick()
		pg.game.markShare:openInfoStampSimple(spawnerId)
		self:closePanel(true)
	end

	local markStatus = self.markCaches[spawnerId].markStatus

	self:renderLocationInfoPanelRewards(objectReference, spawnerId, markStatus, rewardTableForce)
	self.view.locationInfo:TryChangePage("PageState", 0)

	if pg.game.map.extraSharedInfoByMarkId[spawnerId] and pg.game.map.extraSharedInfoByMarkId[spawnerId].locationImgPath then
		iconImg.gameObject:SetActiveEx(true)

		if pg.game.map.extraSharedInfoByMarkId[spawnerId].isUnKnownImg and self:markTypeProcessed(spawnerId, spawnerTable.markType) == Const.MAP_MARK_STATUS_LOCKED then
			iconImg.url = pg.game.map.extraSharedInfoByMarkId[spawnerId].isUnKnownImg
		elseif spawnerTable and spawnerTable.markType == Const.MAP_MARK_QUEST then
			local questIcon = QuestUtils.getQuestTypeIcon(spawnerTable.questId)

			iconImg.url = questIcon
		else
			iconImg.url = pg.game.map.extraSharedInfoByMarkId[spawnerId].locationImgPath
		end
	else
		iconImg.gameObject:SetActiveEx(false)
	end

	local selectIconUComponent = objectReference:GetRefValue("selectIconUComponent")

	selectIconUComponent:TryChangePage("PetSize", markStatus <= Const.MAP_MARK_STATUS_LOCKED and 1 or 0)
	selectIconUComponent:TryChangePage("Title", 0)
	objectReference:GetRefValue("containerUContainer"):SetActiveFastest(false)

	if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		self:renderRainbowPetPoiInfo(objectReference, spawnerId, spawnerTable)
	end

	self.view.locationInfo:TryChangePage("showPetIcon", 0)

	if spawnerTable.type == Const.MAP_CONST.TYPE.GRAB_EGG then
		self.view.locationInfo:TryChangePage("showPetIcon", 3)
		self:renderEggPoiInfo(objectReference, spawnerId, spawnerTable)
	elseif spawnerTable.markType ~= Const.MAP_MARK_EcoTrace_Search and pg.game.map.extraSharedInfoByMarkId[spawnerId].imgPath ~= nil and DefaultMapMarkData[spawnerTable.markConfigId].infoAvatar ~= nil then
		self.view.locationInfo:TryChangePage("showPetIcon", 1)

		iconUImage.url = pg.game.map.extraSharedInfoByMarkId[spawnerId].imgPath
	end

	local locationInfo

	if spawnerTable.type == Const.MAP_CONST.TYPE.DUEL then
		locationInfo = self.model:getDuelMarkInfo(spawnerId) or {}
	else
		locationInfo = self.model:getLocationInfo(self.sceneId, spawnerId, spawnerTable.markConfigId)
	end

	self:renderDetailLocationInfo(objectReference, locationInfo, spawnerId, spawnerTable.markType)

	local photoData = spawnerTable.photoData
	local havePhotoSprite = photoData and photoData.imgKey

	if markStatus <= Const.MAP_MARK_STATUS_LOCKED then
		ClientTextUtils.setText(titleTxt, pg.getLocalizationText(spawnerTable.infoTitleNot or ""))

		if spawnerTable.infoImageNot or havePhotoSprite then
			previewImgImg.gameObject:SetActiveEx(true)

			if havePhotoSprite then
				pg.global.ui.photo.model:queryPresetImg(photoData.imgKey, function(sprite, id)
					if id == havePhotoSprite then
						previewImgImg.sprite = sprite
					end
				end, havePhotoSprite)
			else
				previewImgImg.url = spawnerTable.infoImageNot
			end

			self.view.locationInfo:TryChangePage("NoImage", 0)
		else
			previewImgImg.gameObject:SetActiveEx(false)
			self.view.locationInfo:TryChangePage("NoImage", 1)
		end

		self:renderDetailScrollRect(scrollRectUScrollRect, {
			spawnerId = spawnerId,
			spawnerTable = spawnerTable,
			desc = spawnerTable.infoTextNot or "",
			playerNum = locationInfo.playerNum,
			cratesInfo = locationInfo.cratesInfo,
			photoData = spawnerTable.photoData,
			markPosition = spawnerTable.markPosition,
			locationInfo = locationInfo
		})
	else
		ClientTextUtils.setText(titleTxt, pg.getLocalizationText(infoTitle or ""))

		if infoImage or havePhotoSprite then
			previewImgImg.gameObject:SetActiveEx(true)

			if havePhotoSprite then
				pg.global.ui.photo.model:queryPresetImg(photoData.imgKey, function(sprite, id)
					if id == havePhotoSprite then
						previewImgImg.sprite = sprite
					end
				end, havePhotoSprite)
			else
				previewImgImg.url = infoImage
			end

			self.view.locationInfo:TryChangePage("NoImage", 0)
		else
			previewImgImg.gameObject:SetActiveEx(false)
			self.view.locationInfo:TryChangePage("NoImage", 1)
		end

		self:renderDetailScrollRect(scrollRectUScrollRect, {
			spawnerId = spawnerId,
			spawnerTable = spawnerTable,
			desc = infoText or "",
			playerNum = locationInfo.playerNum,
			cratesInfo = locationInfo.cratesInfo,
			photoData = spawnerTable.photoData,
			markType = spawnerTable.markType,
			markPosition = spawnerTable.markPosition,
			locationInfo = locationInfo
		})
	end

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(titleTxt, titleTxt.text, string.format("-%s-%s", spawnerTable.markType or 0, spawnerId or 0))
	end

	if self:_checkTrackMarkExists(spawnerId, false) or self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
		if spawnerTable.markType == Const.MAP_MARK_TRACE or spawnerTable.markType == Const.MAP_MARK_QUEST and spawnerTable.questId and QuestUtils.isMainQuestType(spawnerTable.questId) then
			self.view.locationInfo:TryChangePage("MapMarkButtonStates", 5)
		else
			self.view.locationInfo:TryChangePage("MapMarkButtonStates", enableTeleportBtn and 0 or 3)
		end
	else
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", enableTeleportBtn and 0 or 1)
	end

	self.dynamicMarkComponent:renderLocationPanelInfo(spawnerId, objectReference)

	function locationTeleportBtn.luaClick()
		if TeleportMarkEventData[spawnerId] and TeleportMarkEventData[spawnerId].defaultEnabled then
			local eventType = TeleportMarkEventData[spawnerId].eventType
			local eventParam = {}

			for k, v in pairs(TeleportMarkEventData[spawnerId].eventParam) do
				eventParam[k] = v
			end

			pg.me:doEventByData({
				eventType,
				eventParam,
				0
			})
		else
			ClientUtils.playTeleportDissolveEffectAndTeleport(pg.game.map:convertSceneId(spawnerTable.realSceneId), spawnerId)
		end

		self:closePanel(true)
		pg.global.ui:closeAllNormalPanel()
	end

	self.localtionTeleportBtn = locationTeleportBtn

	if spawnerTable.markType == Const.MAP_MARK_SHARE then
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", 4)
		self:renderDetailScrollRect(scrollRectUScrollRect, {
			desc = ""
		})

		local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local state, expireTxt = pg.game.markShare:getMyExpireInfoById(spawnerId)

		countDownUCountDown:TryChangePage("Time", state or 0)
		ClientTextUtils.setText(txtNameUSDFText, expireTxt)
		pg.game.markShare:getSelfTxtClips(spawnerId)
	elseif spawnerTable.markType == Const.MAP_MARK_HOME_CAMP then
		self:renderHomeCampInfo(objectReference, markStatus, spawnerId, spawnerTable)
	elseif spawnerTable.markConfigId == Const.NPC_DUEL or spawnerTable.markConfigId == Const.NPC_DUEL_PRO then
		local duelRewardInfo = self.model:getDuelMarkRewards(spawnerId)

		if duelRewardInfo then
			self:renderLocationInfoPanelRewardsCommon(objectReference, duelRewardInfo.rewards, duelRewardInfo.title)
		end
	end

	if spawnerTable.markConfigId == Const.MAP_MARK_LEYLINETREE_TRANSMIT and markStatus >= Const.MAP_MARK_STATUS_UNLOCKED and pg.game.leylineTree:checkLeylineTreeUnlockedBySmallAreaId(spawnerTable.largeAreaId) then
		if not self.weatherTaskContainer then
			self.weatherTaskContainer = {}
		end

		MapUtils.renderLeylineClusterMapInfoPanel(objectReference, spawnerTable, self.weatherTaskContainer, self)
	else
		MapUtils.clearLeylineClusterMapInfoPanel(objectReference)
	end

	function locationTrackBtn.luaClick()
		self:trackMark(spawnerId, spawnerTable, enableTeleportBtn)
	end

	function locationUnTrackBtn.luaClick()
		self:unTrackMark(markButton, spawnerId, spawnerTable, enableTeleportBtn)
	end

	self.locationTrackBtn = locationTrackBtn
	self.locationUnTrackBtn = locationUnTrackBtn
end

function MapCtrl:trackMark(spawnerId, spawnerTable, enableTeleportBtn)
	local function trackInner(noNeedMinimap)
		if spawnerTable.markType == Const.MAP_MARK_TRACE or spawnerTable.markType == Const.MAP_MARK_QUEST and spawnerTable.questId and QuestUtils.isMainQuestType(spawnerTable.questId) then
			self.view.locationInfo:TryChangePage("MapMarkButtonStates", 5)
		else
			self.view.locationInfo:TryChangePage("MapMarkButtonStates", enableTeleportBtn and 0 or 3)
		end

		self:swapMarkLayer(spawnerId, 99, nil)

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].lowerDynamicLoadTransform then
			self:checkTrackTaskAndObjStatus(noNeedMinimap)
			self:_cleanupTrackPrefab(spawnerId)

			self.markCaches[spawnerId].trackTaskId = self.view:addPrefabWithPathAsync(self.markCaches[spawnerId].lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_TRACK, function(obj)
				self.markCaches[spawnerId].trackObj = obj.gameObject
				self.trackTaskObjTable[spawnerId] = obj.gameObject
			end, false, false, 0)
			self.trackTaskTable[spawnerId] = self.markCaches[spawnerId].trackTaskId
		end

		if spawnerTable.markType == Const.MAP_MARK_QUEST and spawnerTable.questId and not QuestUtils.isMainQuestType(spawnerTable.questId) then
			QuestUtils.mapTraceQuest(spawnerTable.questId, true)
		end
	end

	if self:checkFogBlocked(self.markCaches[spawnerId].mapX, self.markCaches[spawnerId].mapY) then
		return
	end

	if self:isDifferentScene() then
		if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
			return
		end

		self.differentSceneTrackMark = spawnerId

		pg.game.map:trackDiffSceneMark(self.sceneId, spawnerId, spawnerTable, function(result)
			trackInner(true)

			if not result then
				pg.global.showBubbleMessageById(2128)
			else
				self:ensureStartMarkLoaded(result.startSpawnerId)

				if not self.markCaches[result.startSpawnerId] then
					self.diffSceneTrackDelayFlag = result.startSpawnerId

					self.mapNavLineComponent:drawNavEffLine({
						path = result.path,
						sceneId = result.sceneId
					})
				else
					self.mapNavLineComponent:drawNavEffLine({
						path = result.path,
						sceneId = result.sceneId
					}, self.markCaches[result.startSpawnerId].button, result.startSpawnerId)
				end
			end
		end)

		return
	else
		local miniMap = self:_getMiniMapComponent()

		if not miniMap then
			return
		end

		if spawnerTable and spawnerTable.markType == Const.MAP_MARK_QUEST and spawnerTable.questId then
			trackInner()
		end

		miniMap:addTrackMark(spawnerTable.markType, spawnerId, function()
			trackInner()
		end)
	end
end

function MapCtrl:unTrackMark(markButton, spawnerId, spawnerTable, enableTeleportBtn)
	local function unTrackInner()
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", enableTeleportBtn and 0 or 1)

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].trackTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].trackTaskId)
		end

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].trackObj then
			self.view:destroyInstance(self.markCaches[spawnerId].trackObj)
		end

		self:swapMarkLayer(spawnerId, nil, true)

		if spawnerTable.showOntrail == 1 then
			self:openLocationPanel(false)
			self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)

			self.chooseListClick = false

			markButton.gameObject:SetActiveEx(false)
		end

		pg.game.map:unStoreTrackMarks(spawnerId)

		if spawnerTable.markType == Const.MAP_MARK_QUEST and spawnerTable.questId and not QuestUtils.isMainQuestType(spawnerTable.questId) then
			QuestUtils.mapTraceQuest(spawnerTable.questId, false)
		end
	end

	if self:isDifferentScene() then
		unTrackInner()

		if self.differentSceneTrackMark and self.differentSceneTrackMark == spawnerId then
			self.differentSceneTrackMark = nil

			self.mapNavLineComponent:drawNavEffLine()
		end
	else
		local miniMap = self:_getMiniMapComponent()

		if not miniMap then
			return
		end

		miniMap:deleteTrackMark(spawnerId, function()
			unTrackInner()
		end)
	end
end

function MapCtrl:_getTeaPartyCfgTime(partyTimeCfg, dayBegin)
	if partyTimeCfg == nil or dayBegin == nil or pg.me == nil then
		return nil, nil
	end

	local startSeconds = Utils.getConfigTimeOfArea(partyTimeCfg, "startTime")
	local endSeconds = Utils.getConfigTimeOfArea(partyTimeCfg, "endTime")

	if startSeconds == nil or endSeconds == nil then
		return nil, nil
	end

	local startTime = dayBegin + startSeconds
	local endTime = dayBegin + endSeconds

	if partyTimeCfg.isTomorrow == true or partyTimeCfg.isTomorrow == 1 or partyTimeCfg.istomorrow == true or partyTimeCfg.istomorrow == 1 then
		startTime = startTime + Const.SECONDS_ONE_DAY
		endTime = endTime + Const.SECONDS_ONE_DAY
	end

	return startTime, endTime
end

function MapCtrl:_getActiveTeaPartyCfg(partyTimeCfgList)
	if Utils.isTable(partyTimeCfgList) ~= true then
		return nil
	end

	local now = Time.secondCache
	local dayBegin = TimeUtils.getAreaDayBegin(now)

	for _, rangeDayBegin in ipairs({
		dayBegin - Const.SECONDS_ONE_DAY,
		dayBegin
	}) do
		for _, partyTimeCfg in ipairs(partyTimeCfgList) do
			local startTime, endTime = self:_getTeaPartyCfgTime(partyTimeCfg, rangeDayBegin)

			if startTime ~= nil and endTime ~= nil and startTime <= now and now < endTime then
				return partyTimeCfg
			end
		end
	end

	return nil
end

function MapCtrl:_mergeTeaPartyDropRewards(rewardMap, rewardOrder, dropId)
	if rewardMap == nil or rewardOrder == nil or dropId == nil then
		return
	end

	local dropRewards = LuaUIUtils.getRewardItemByDropId(dropId)

	if Utils.isTable(dropRewards) ~= true then
		return
	end

	for _, reward in ipairs(dropRewards) do
		local itemId = reward.id

		if itemId ~= nil then
			reward.hideRewardNum = true

			local oldReward = rewardMap[itemId]

			if oldReward == nil then
				rewardMap[itemId] = reward
				rewardOrder[#rewardOrder + 1] = itemId
			elseif type(reward.num) == "number" and type(oldReward.num) == "number" and reward.num > oldReward.num then
				oldReward.num = reward.num
			end
		end
	end
end

function MapCtrl:_mergeTeaPartyCfgRewards(rewardMap, rewardOrder, partyTimeCfg)
	if partyTimeCfg == nil or Utils.isTable(partyTimeCfg.reward) ~= true then
		return
	end

	for _, rewardCfg in ipairs(partyTimeCfg.reward) do
		if Utils.isTable(rewardCfg) == true then
			self:_mergeTeaPartyDropRewards(rewardMap, rewardOrder, rewardCfg[1])
		end
	end
end

function MapCtrl:_getTeaPartyMapRewardTable()
	local partyTimeCfgList = SocialPartyData[SocialConst.CAFE_AREA_ID]

	if Utils.isTable(partyTimeCfgList) ~= true then
		return nil
	end

	local rewardMap = {}
	local rewardOrder = {}
	local activeCfg = self:_getActiveTeaPartyCfg(partyTimeCfgList)

	if activeCfg ~= nil then
		self:_mergeTeaPartyCfgRewards(rewardMap, rewardOrder, activeCfg)
	else
		for _, partyTimeCfg in ipairs(partyTimeCfgList) do
			self:_mergeTeaPartyCfgRewards(rewardMap, rewardOrder, partyTimeCfg)
		end
	end

	local rewardTable = {}

	for _, itemId in ipairs(rewardOrder) do
		local reward = rewardMap[itemId]

		if reward ~= nil then
			rewardTable[#rewardTable + 1] = reward
		end
	end

	return rewardTable
end

function MapCtrl:renderLocationInfoPanelRewards(objectReference, spawnerId, markStatus, rewardTableForce, rewardTableTitleForce)
	local listFirstPassUList = objectReference:GetRefValue("listFirstPassUList")
	local listPeriodUList = objectReference:GetRefValue("listPeriodUList")
	local firstPassUWidget = objectReference:GetRefValue("firstPassUWidget")
	local periodTitle = objectReference:GetRefValue("periodTitle")
	local periodTipBtn = objectReference:GetRefValue("periodTipBtn")
	local periodCostIcon = objectReference:GetRefValue("periodCostIcon")
	local periodCostNum = objectReference:GetRefValue("periodCostNum")
	local comRewardUWidget = objectReference:GetRefValue("comRewardUWidget")
	local firstPassTitle = objectReference:GetRefValue("firstPassTitle")
	local consumeBtnUButton = objectReference:GetRefValue("consumeBtnUButton")
	local consumeRectTransform = objectReference:GetRefValue("consumeRectTransform")
	local voxelIconUImage = objectReference:GetRefValue("voxelIconUImage")

	voxelIconUImage.gameObject:SetActiveEx(false)

	function listFirstPassUList.luaRenderItem(item, idx, data)
		LuaUIUtils.renderRewards(item, idx, data)

		if data ~= nil and data.hideRewardNum == true then
			local itemObjectReference = item:GetComponent("ObjectReference")
			local txtNumUText = itemObjectReference:GetRefValue("txtNumUText")

			if txtNumUText == nil then
				txtNumUText = itemObjectReference:GetRefValue("txtNumUBaseText")
			end

			if txtNumUText ~= nil then
				ClientTextUtils.setText(txtNumUText, "")
			end
		end
	end

	function listPeriodUList.luaRenderItem(item, idx, data)
		LuaUIUtils.renderRewards(item, idx, data)
	end

	if rewardTableForce then
		comRewardUWidget.gameObject:SetActiveEx(false)

		rewardTableTitleForce = rewardTableTitleForce or pg.getGameString("ROGUE_DIEC_REWARD")

		ClientTextUtils.setText(firstPassTitle, rewardTableTitleForce)

		if #rewardTableForce > 0 then
			firstPassUWidget.gameObject:SetActiveEx(true)
			HomeCampUtils.trySetUnknownDispatchItem(rewardTableForce, self:getIsHomeCampMark(spawnerId))
			listFirstPassUList:SetList(rewardTableForce)
		else
			firstPassUWidget.gameObject:SetActiveEx(false)
		end
	else
		firstPassUWidget.gameObject:SetActiveEx(false)
		comRewardUWidget.gameObject:SetActiveEx(false)
		ClientTextUtils.setText(firstPassTitle, pg.getGameString("FIRST_PASS_REWARD"))

		local hasFirstPassReward = false
		local rewardData = LevelRewardLinkedData[spawnerId]
		local markCache = self.markCaches and self.markCaches[spawnerId]
		local isBossMark = markCache and Const.MAP_INFO_BOSS_PANEL[markCache.markConfigId] == true
		local hasClaimedFirstPassReward = isBossMark and markStatus >= Const.MAP_MARK_STATUS_CLOSED

		if rewardData and (markStatus < Const.MAP_MARK_STATUS_CLOSED or hasClaimedFirstPassReward) then
			local rewardTable = LuaUIUtils.getRewardItemByDropId(rewardData.showRewardId, hasClaimedFirstPassReward)

			if rewardTable and #rewardTable > 0 then
				firstPassUWidget.gameObject:SetActiveEx(true)
				HomeCampUtils.trySetUnknownDispatchItem(rewardTable, self:getIsHomeCampMark(spawnerId))
				listFirstPassUList:SetList(rewardTable)

				hasFirstPassReward = true
			end
		end

		if hasFirstPassReward ~= true and spawnerId == TEA_PARTY_MAP_POINT_ID and markStatus < Const.MAP_MARK_STATUS_CLOSED then
			local rewardTable = self:_getTeaPartyMapRewardTable()

			if rewardTable ~= nil and #rewardTable > 0 then
				firstPassUWidget.gameObject:SetActiveEx(true)
				ClientTextUtils.setText(firstPassTitle, pg.getGameString("TEAPARTY_MAP_REWARD_TITLE"))
				listFirstPassUList:SetList(rewardTable)
			end

			voxelIconUImage.gameObject:SetActiveEx(true)

			voxelIconUImage.url = ItemData[SOCIAL_PARTY_VOXEL_ITEM_ID] and ItemData[SOCIAL_PARTY_VOXEL_ITEM_ID].icon or ""
		end

		consumeRectTransform.gameObject:SetActiveEx(not isBossMark or self.model:getBossChallengeInfo(spawnerId) == nil)

		local levelPeriodRewards = self.model:getPlayerLevelPeriodRewards(spawnerId)

		if levelPeriodRewards then
			comRewardUWidget.gameObject:SetActiveEx(true)

			function periodTipBtn.luaRenderTooltip(_, cmp)
				local objectReference1 = cmp:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("LEVEL_PERIOD_REWARD_TIP"))
			end

			ClientTextUtils.setText(periodTitle, string.format(pg.getGameString("LEVEL_PERIOD_REWARD"), levelPeriodRewards.level))

			periodCostIcon.url = levelPeriodRewards.costItemIcon

			function consumeBtnUButton.luaClick()
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = levelPeriodRewards.costItemId,
					num = ItemUtils.getItemCountById(pg.me, levelPeriodRewards.costItemId),
					targetRect = consumeBtnUButton
				})
			end

			ClientTextUtils.setText(periodCostNum, levelPeriodRewards.costItemNum)
			listPeriodUList:SetList(levelPeriodRewards.itemCountTable)
		end
	end
end

function MapCtrl:renderLocationInfoPanelRewardsCommon(objectReference, rewardTable, rewardTableTitle)
	local listFirstPassUList = objectReference:GetRefValue("listFirstPassUList")
	local firstPassUWidget = objectReference:GetRefValue("firstPassUWidget")
	local comRewardUWidget = objectReference:GetRefValue("comRewardUWidget")
	local firstPassTitle = objectReference:GetRefValue("firstPassTitle")

	function listFirstPassUList.luaRenderItem(item, idx, data)
		LuaUIUtils.renderRewards(item, idx, data)
	end

	comRewardUWidget.gameObject:SetActiveEx(false)
	ClientTextUtils.setText(firstPassTitle, rewardTableTitle)

	if #rewardTable > 0 then
		firstPassUWidget.gameObject:SetActiveEx(true)
		listFirstPassUList:SetList(rewardTable)
	else
		firstPassUWidget.gameObject:SetActiveEx(false)
	end
end

function MapCtrl:curStageScaleConvertor(stage)
	if not self.view.mapLevelBreakdown then
		return stage
	end

	for stageNew, v in pairs(self.view.mapLevelBreakdown) do
		if stage >= v[1] and stage <= v[2] then
			return stageNew
		end
	end

	return stage
end

function MapCtrl:getMaxStageByConfigStage(configStage)
	if not self.view.mapLevelBreakdown or not self.view.mapLevelBreakdown[configStage] then
		return nil
	end

	return self.view.mapLevelBreakdown[configStage][2]
end

function MapCtrl:markTypeProcessed(spawnerId, markType)
	local spawnerTable = self.sceneMarkPointData and self.sceneMarkPointData[spawnerId]

	if spawnerTable and spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		return MapHelper.getRainbowPetMarkStatus(spawnerId, spawnerTable.realSceneId or self.sceneId)
	end

	local markStatus = (markType == Const.MAP_MARK_ZONE or markType == Const.MAP_MARK_CUSTOM or markType == Const.MAP_MARK_QUEST or markType == Const.MAP_MARK_SHARE or markType == Const.MAP_MARK_TRACE or markType == Const.MAP_MARK_ALLY or markType == Const.MAP_MARK_FAST_TARGET or markType == Const.MAP_MARK_GOLD_MONSTER or markType == Const.MAP_MARK_GRAB_EGG) and Const.MAP_MARK_STATUS_UNLOCKED or self.markMap:getStatus(self.sceneId, markType, spawnerId)

	if pg.game.map:getTempWhiteListMarkData(spawnerId) then
		markStatus = Const.MAP_MARK_STATUS_LOCKED
	end

	return markStatus
end

function MapCtrl:tryHandleGrabEggMarkUpdate(updateInfo)
	if not updateInfo or not updateInfo.id then
		return false
	end

	local spawnerId = updateInfo.id
	local markInfo = self:getMarkInfo(spawnerId)
	local cache = self.markCaches and self.markCaches[spawnerId]

	if markInfo and markInfo.type == Const.MAP_CONST.TYPE.GOLD or cache and cache.type == Const.MAP_CONST.TYPE.GOLD then
		if updateInfo.type == "delete" then
			self:_removeMapMark(spawnerId)
		elseif markInfo then
			if not cache then
				self:addMarks(markInfo, spawnerId)
			elseif markInfo.markPosition then
				local pos = pg.game.map:getEffectiveMarkPos(spawnerId, markInfo.markPosition)
				local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], markInfo.realSceneId or self.sceneId, true)

				cache.recTrans.anchoredPosition = Vector2(mapX, mapY)
				cache.anchoredPositionX = mapX
				cache.anchoredPositionY = mapY
				cache.realAnchoredPositionX = mapX
				cache.realAnchoredPositionY = mapY
				cache.mapX = mapX
				cache.mapY = mapY
				cache.markPos = {
					markInfo.markPosition[1],
					markInfo.markPosition[2],
					markInfo.markPosition[3]
				}
			end
		end

		return true
	end

	if not markInfo or markInfo.type ~= Const.MAP_CONST.TYPE.GRAB_EGG then
		return false
	end

	if updateInfo.type == "delete" then
		self:_removeMapMark(spawnerId)

		return true
	end

	cache = self.markCaches and self.markCaches[spawnerId]

	if not cache then
		self:addMarks(markInfo, spawnerId)
	elseif cache.resObj then
		local objectReference = cache.resObj:GetComponent("ObjectReference")

		if NotNil(objectReference) then
			local eggView = GrabEggMapMarkUtils.getEggView(spawnerId)

			GrabEggMapMarkUtils.applyEggMarkView(objectReference, eggView)
		end
	end

	if self.locationInfoPanelCurMarkId == spawnerId and self.view.locationInfo.gameObject.activeSelf then
		local locationRef = self.view.locationInfo:GetComponent("ObjectReference")

		if NotNil(locationRef) then
			self:renderEggPoiInfo(locationRef, spawnerId, markInfo)
		end
	end

	return true
end

function MapCtrl:onMapMarkStatusUpdated(updateInfo)
	if not updateInfo or not updateInfo.id then
		return
	end

	local spawnerId = updateInfo.id
	local cache = self.markCaches and self.markCaches[spawnerId]
	local spawnerTable = self.sceneMarkPointData and self.sceneMarkPointData[spawnerId]

	if not spawnerTable then
		return
	end

	if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		local newStatus = self:markTypeProcessed(spawnerId, spawnerTable.markType)

		if newStatus == Const.MAP_MARK_STATUS_UNLOCKED then
			if cache then
				cache.markStatus = newStatus

				local templateId = MapHelper.getRainbowPetTemplateIdByPointId(spawnerId, spawnerTable.realSceneId or self.sceneId)

				if cache.resObj then
					local objectReference = cache.resObj:GetComponent("ObjectReference")

					LuaUIUtils.renderRainbowPetIcon(objectReference:GetRefValue("playerHeadRectTransform"), templateId)
				end

				local puppetData = PuppetData[templateId]
				local icon = LuaUIUtils.getPetIconByTemplateId(puppetData and puppetData.petPrototypeId or templateId, LuaUIUtils.PET_ICON)

				pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "locationImgPath", icon)

				local scale = spawnerTable[string.format("scale%s", self:curStageScaleConvertor(self.curStage))]
				local shouldShow = self:shouldShowMarkOnLoad(scale, spawnerId)

				cache.gameObject:SetActiveEx(shouldShow)

				if shouldShow then
					self:checkMarkDisplay(cache.button, spawnerTable.refreshLogicTimes)
				end
			else
				self:addMarks(spawnerTable, spawnerId)
			end

			if self.locationInfoPanelCurMarkId == spawnerId and self.view.locationInfo.gameObject.activeSelf then
				self:renderRainbowPetPoiInfo(self.view.locationInfo:GetComponent("ObjectReference"), spawnerId, spawnerTable)
			end
		else
			if self.locationInfoPanelCurMarkId == spawnerId and self.view.locationInfo.gameObject.activeSelf then
				self:onLocationInfoCloseBtnClick()
			end

			self:_removeMapMark(spawnerId)
		end

		return
	end

	if not cache then
		return
	end

	if spawnerTable.markConfigId ~= MapUtils.GRAB_EGG_TRANSMITTER_MARK_CONFIG_ID then
		return
	end

	local newStatus = self:markTypeProcessed(spawnerId, spawnerTable.markType)

	cache.markStatus = newStatus

	local isInUse = MapUtils.isGrabEggTransmitterInUse(spawnerId)
	local locationImgPath = MapUtils.getGrabEggTransmitterIcon(spawnerId)

	pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "locationImgPath", locationImgPath)

	if cache.resObj then
		local uComponent = cache.resObj:GetComponent("UComponent")

		if NotNil(uComponent) then
			uComponent:TryChangePage("Active", isInUse and 1 or 0)
		end
	end

	if self.locationInfoPanelCurMarkId == spawnerId and self.view.locationInfo.gameObject.activeSelf then
		local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
		local iconImg = objectReference and objectReference:GetRefValue("iconImg")

		if NotNil(iconImg) then
			iconImg.url = locationImgPath
		end
	end
end

function MapCtrl:changeMapLayerTemporary(scene, layerId, layerLevel, layerArea)
	local areaId = 0

	if layerId ~= 0 then
		local sceneCfg = MapLevelConfigData[scene]
		local layerCfg = sceneCfg and sceneCfg[layerId]
		local levelCfg = layerCfg and layerCfg[layerLevel]
		local areaCfg = levelCfg and levelCfg[layerArea]

		areaId = areaCfg and areaCfg.areaId or 0
	end

	self.mapLayerData = {
		scene,
		layerId,
		layerLevel,
		layerArea,
		areaId
	}

	self.view.chunkingLoad:UpdateMapLayerTemporary(scene, layerId, layerLevel, layerArea, pg.game.map:getLayerAreaIndexes(scene, layerId, layerLevel, layerArea))

	if not self.markCaches then
		return
	end

	for id, v in pairs(self.markCaches) do
		self:renderInAreaRange(id, v)
	end
end

function MapCtrl:renderInAreaRange(spawnerId, table)
	local inSpecificAreaRange = 0

	if self.sceneId ~= self.mapLayerData[1] then
		return
	end

	if table.type == Const.MAP_CONST.TYPE.AREA then
		return
	end

	if table.type == Const.MAP_CONST.TYPE.GRAB_EGG then
		return
	end

	if table.belongAreaId and MapLevelConfigLoadData[self.sceneId] and MapLevelConfigLoadData[self.sceneId][table.belongAreaId] and MapLevelConfigLoadData[self.sceneId][table.belongAreaId].isGround ~= 1 then
		if table.belongAreaId == self.mapLayerData[5] or MapLevelConfigLoadData[self.sceneId] and MapLevelConfigLoadData[self.sceneId][self.mapLayerData[5]] and LuaUIUtils.tableContains(MapLevelConfigLoadData[self.sceneId][self.mapLayerData[5]].relevantAreaIds, table.belongAreaId) then
			inSpecificAreaRange = 2
			table.layerStateTaskId = self.view:addPrefabWithPathAsync(table.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_LAYER_ICON, function(obj)
				obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC2
				obj.gameObject:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_LAYER_ACTIVE
				table.layerState = obj.gameObject
			end, false, false, 0)
		else
			inSpecificAreaRange = 1
			table.layerStateTaskId = self.view:addPrefabWithPathAsync(table.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_LAYER_ICON, function(obj)
				obj.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC2
				obj.gameObject:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_LAYER_INACTIVE
				table.layerState = obj.gameObject
			end, false, false, 0)
		end

		table.inAreaRange = inSpecificAreaRange
	else
		inSpecificAreaRange = 0
		table.inAreaRange = inSpecificAreaRange

		if not self.markCaches[spawnerId] then
			return
		end

		if self.markCaches[spawnerId].layerStateTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].layerStateTaskId)
		end

		if self.markCaches[spawnerId].layerState and self.view:checkInstanceExists(self.markCaches[spawnerId].layerState) then
			self.view:destroyInstance(self.markCaches[spawnerId].layerState)
		end
	end

	pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "inAreaRange", table.inAreaRange)
end

function MapCtrl:renderCompleteIcon(spawnerId, table, force)
	if table.markStatus >= Const.MAP_MARK_STATUS_CLOSED or force then
		table.completeIconTaskId = self.view:addPrefabWithPathAsync(table.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COMPLETE, function(obj1)
			obj1.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC[table.markLevel]
			table.completeIconObj = obj1.gameObject
		end, false, false, 0)
	else
		if not self.markCaches[spawnerId] then
			return
		end

		if self.markCaches[spawnerId].completeIconTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].completeIconTaskId)
		end

		if self.markCaches[spawnerId].completeIconObj then
			self.view:destroyInstance(self.markCaches[spawnerId].completeIconObj)
		end
	end
end

function MapCtrl:renderCoffeeShopCornerIcon(spawnerId, table)
	if spawnerId ~= TEA_PARTY_MAP_POINT_ID then
		return
	end

	local iconUrl = ItemData[SOCIAL_PARTY_VOXEL_ITEM_ID] and ItemData[SOCIAL_PARTY_VOXEL_ITEM_ID].icon

	if not iconUrl then
		return
	end

	table.coffeeShopCornerIconTaskId = self.view:addPrefabWithPathAsync(table.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COMPLETE, function(obj1)
		obj1.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_LOC2
		obj1.gameObject:GetComponent("UImage").url = iconUrl
		table.coffeeShopCornerIconObj = obj1.gameObject
	end, false, false, 0)
end

function MapCtrl:renderTeamTrack(spawnerId, table)
	local isTrack, firstTrackUid = pg.game.map:getTrackInfo(self.sceneId, table.type, spawnerId)

	if isTrack then
		if self.markCaches[spawnerId] and self.markCaches[spawnerId].teamTrackObj then
			local obj1 = self.markCaches[spawnerId].teamTrackObj
			local uComponent = obj1.gameObject:GetComponent("UComponent")
			local objectReference = obj1.gameObject:GetComponent("ObjectReference")
			local txtPlayerNum = objectReference:GetRefValue("txtPlayerNum")
			local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, firstTrackUid)

			if contain and NotNil(uComponent) then
				uComponent:TryChangePage("Teammate", idx - 1)
				ClientTextUtils.setText(txtPlayerNum, idx)
			end

			obj1.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_TARCKLOC
			table.teamTrackObj = obj1.gameObject
		else
			table.resTaskId = self.view:addPrefabWithPathAsync(table.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_PLAYER_NUM, function(obj1)
				local uComponent = obj1.gameObject:GetComponent("UComponent")
				local objectReference = obj1.gameObject:GetComponent("ObjectReference")
				local txtPlayerNum = objectReference:GetRefValue("txtPlayerNum")
				local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, firstTrackUid)

				if contain and NotNil(uComponent) then
					uComponent:TryChangePage("Teammate", idx - 1)
					ClientTextUtils.setText(txtPlayerNum, idx)
				end

				obj1.gameObject:GetComponent("RectTransform").anchoredPosition = MapHelper.LAYER_ICON_TARCKLOC
				table.teamTrackObj = obj1.gameObject
			end, false, false, 0)
		end
	else
		if not self.markCaches[spawnerId] then
			return
		end

		if self.markCaches[spawnerId].resTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].resTaskId)

			self.markCaches[spawnerId].resTaskId = nil
		end

		if self.markCaches[spawnerId].teamTrackObj then
			self.view:destroyInstance(self.markCaches[spawnerId].teamTrackObj)

			self.markCaches[spawnerId].teamTrackObj = nil
		end
	end
end

function MapCtrl:_nextMarkPoolGeneration(spawnerId)
	self._markPoolGenerations = self._markPoolGenerations or {}

	local generation = (self._markPoolGenerations[spawnerId] or 0) + 1

	self._markPoolGenerations[spawnerId] = generation

	return generation
end

function MapCtrl:_acquireCommonMarkIcon(cache, parent, iconUrl)
	cache.commonIconUrl = iconUrl
	cache.resPrefabPath = AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON

	if cache.commonIconLease then
		if NotNil(cache.resObj) then
			cache.resObj:GetComponent("UImage").url = iconUrl

			return
		end

		MapMarkPrefabPoolManager:Release(cache.commonIconLease, cache, true)

		cache.commonIconLease = nil
		cache.resObj = nil
	end

	if cache.commonIconRequest then
		return
	end

	local generation = cache.poolGeneration
	local request = MapMarkPrefabPoolManager:Acquire(AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON, cache, generation, parent, function(gameObject, lease)
		cache.commonIconRequest = nil

		if not lease or IsNil(gameObject) then
			return
		end

		if not self._markPoolGenerations or self._markPoolGenerations[cache.spawnerId] ~= generation then
			MapMarkPrefabPoolManager:Release(lease, cache)

			return
		end

		cache.commonIconLease = lease
		cache.resObj = gameObject
		cache.resObj:GetComponent("UImage").url = cache.commonIconUrl
	end, MapMarkPrefabPoolManager.OwnerTag.BIG_MAP_COMMON_ICON)

	if request and not request.completed then
		cache.commonIconRequest = request
	else
		cache.commonIconRequest = nil
	end
end

function MapCtrl:clearPreviousTask(spawnerId)
	self:_nextMarkPoolGeneration(spawnerId)

	if not self.markCaches[spawnerId] then
		return
	end

	local cache = self.markCaches[spawnerId]
	local pendingQualityVx = self.pendingLeylineFlowerQualityVx

	if self.activeLeylineFlowerQualityVxFlowerId == spawnerId or pendingQualityVx and pendingQualityVx.flowerId == spawnerId then
		self:_stopLeylineFlowerQualityVx()
	end

	if cache.commonIconRequest then
		MapMarkPrefabPoolManager:CancelRequest(cache.commonIconRequest, cache)

		cache.commonIconRequest = nil
	end

	if cache.layerStateTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].layerStateTaskId)
	end

	if self.markCaches[spawnerId].layerState then
		self.view:destroyInstance(self.markCaches[spawnerId].layerState)
	end

	if self.markCaches[spawnerId].resTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].resTaskId)
	end

	if self.markCaches[spawnerId].resTaskTagId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].resTaskTagId)
	end

	if self.markCaches[spawnerId].resTaskIds then
		for _, taskId in pairs(self.markCaches[spawnerId].resTaskIds) do
			self.view:cancelUIAsyncTask(taskId)
		end
	end

	if cache.commonIconLease then
		MapMarkPrefabPoolManager:Release(cache.commonIconLease, cache)
	elseif cache.resObj then
		self.view:destroyInstance(cache.resObj)
	end

	cache.commonIconLease = nil
	cache.resObj = nil
	cache.resPrefabPath = nil
	cache.commonIconUrl = nil

	if cache.resObj then
		self.view:destroyInstance(cache.resObj)

		cache.resObj = nil
	end

	if cache.resTagObj then
		self.view:destroyInstance(cache.resTagObj)

		cache.resTagObj = nil
	end

	if self.markCaches[spawnerId].resObjs then
		for _, resObj in pairs(self.markCaches[spawnerId].resObjs) do
			self.view:destroyInstance(resObj)
		end
	end

	if self.markCaches[spawnerId].completeIconTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].completeIconTaskId)
	end

	if self.markCaches[spawnerId].completeIconObj then
		self.view:destroyInstance(self.markCaches[spawnerId].completeIconObj)
	end

	if self.markCaches[spawnerId].coffeeShopCornerIconTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].coffeeShopCornerIconTaskId)
	end

	if self.markCaches[spawnerId].coffeeShopCornerIconObj then
		self.view:destroyInstance(self.markCaches[spawnerId].coffeeShopCornerIconObj)
	end

	if self.markCaches[spawnerId].trackTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].trackTaskId)
	end

	if self.markCaches[spawnerId].trackObj then
		self.view:destroyInstance(self.markCaches[spawnerId].trackObj)
	end

	if self.markCaches[spawnerId].selectedTaskId then
		self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
	end

	if self.markCaches[spawnerId].selectedObj then
		self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
	end

	if self.markCaches[spawnerId].teamTrackObj then
		self.view:destroyInstance(self.markCaches[spawnerId].teamTrackObj)
	end
end

function MapCtrl:ForceRebuildMark(spawnerId)
	local markInfo = self:getMarkInfo(spawnerId)

	if not markInfo then
		return
	end

	local cache = self.markCaches and self.markCaches[spawnerId]

	if cache and cache.commonIconLease then
		MapMarkPrefabPoolManager:Release(cache.commonIconLease, cache, true)

		cache.commonIconLease = nil
		cache.resObj = nil
		cache.resPrefabPath = nil
	end

	self:_removeMapMark(spawnerId)
	self:prepareMarkLoad(markInfo, spawnerId, true)
end

function MapCtrl:loadRes(spawnerId, spawnerTable, cb)
	if spawnerTable.markType == Const.MAP_MARK_CUSTOM then
		self.customMarkerPool:createFromPool(nil, spawnerId, function(objInfo)
			self:loadResInner(objInfo, spawnerId, spawnerTable)

			if cb then
				cb()
			end
		end)
	else
		local markLayer = string.format("markerListTransformLayer%s", pg.game.map:getMarkPriorityByConfigId(spawnerTable.markConfigId))
		local pointsTasks, task, view = self.pointsTasks, {}, self.view
		local frameLoad = pg.global.platform ~= nil and pg.global.platform:isConsole() and spawnerTable.markType ~= Const.MAP_MARK_ZONE

		pointsTasks[spawnerId] = task

		local function loadMark()
			if self.pointsTasks ~= pointsTasks or pointsTasks[spawnerId] ~= task then
				return false
			end

			task.taskId = view:addPrefabWithPathAsync(view[markLayer], AddressDataConst.UI_MARK_1, function(objInfo)
				if self.pointsTasks ~= pointsTasks or pointsTasks[spawnerId] ~= task or frameLoad and self.mapMarkLoadStopped then
					view:destroyInstance(objInfo.gameObject)

					return
				end

				task.taskObj = objInfo.gameObject

				self:loadResInner(objInfo, spawnerId, spawnerTable)

				if cb and self.pointsTasks == pointsTasks and pointsTasks[spawnerId] == task and (not frameLoad or not self.mapMarkLoadStopped) then
					cb()
				end
			end, false, true, (frameLoad or spawnerTable.markType == Const.MAP_MARK_ZONE) and 0 or 3)

			return true
		end

		if frameLoad then
			self:_startMapMarkLoads(loadMark)
		else
			loadMark()
		end
	end
end

function MapCtrl:selectMark(markName, click)
	if self.enableMultiDeleteMode then
		return
	end

	if not markName then
		for btn, v in pairs(self.curSelectedBtn) do
			if v == "FakeCustomMark" then
				btn.transform:GetComponent("ObjectReference"):GetRefValue("selectedUImage").gameObject:SetActiveEx(false)
			else
				local spawnerId = self.model:getSpawnerIdByMarkName(btn.name)

				if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedTaskId then
					self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
				end

				if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedObj then
					self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
				end
			end

			self.curSelectedBtn[btn] = nil

			self:onMarkSelectedChanged(btn, false)
		end

		return
	end

	local mark, btn

	if markName == "FakeCustomMark" then
		mark = self.view.markerListTransform:Find(markName)

		if mark == nil then
			return
		end

		btn = mark:GetComponent("UButton")
	else
		mark = self.markCaches[self.model:getSpawnerIdByMarkName(markName)]

		if mark == nil then
			return
		end

		btn = mark.button
	end

	if self.curSelectedBtn[btn] then
		return
	end

	for button, v in pairs(self.curSelectedBtn) do
		if v == "FakeCustomMark" then
			button.transform:GetComponent("ObjectReference"):GetRefValue("selectedUImage").gameObject:SetActiveEx(false)
		else
			local spawnerId = self.model:getSpawnerIdByMarkName(button.name)

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedTaskId then
				self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
			end

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedObj then
				self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
			end
		end

		self.curSelectedBtn[button] = nil

		self:onMarkSelectedChanged(button, false)
	end

	if markName == "FakeCustomMark" then
		btn.transform:GetComponent("ObjectReference"):GetRefValue("selectedUImage").gameObject:SetActiveEx(true)

		self.curSelectedBtn[btn] = "FakeCustomMark"
	else
		local id = self.model:getSpawnerIdByMarkName(btn.name)

		self.markCaches[id].selectedTaskId = self.view:addPrefabWithPathAsync(self.markCaches[id].upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_SELECTED, function(obj)
			self.markCaches[id].selectedObj = obj.gameObject
		end, false, false, 0)
		self.curSelectedBtn[btn] = true
	end

	self:onMarkSelectedChanged(btn, true)

	if click then
		btn:OnClickSimulate()
	end
end

function MapCtrl:deselectAll()
	for button, v in pairs(self.curSelectedBtn) do
		if v == "FakeCustomMark" then
			button.transform:GetComponent("ObjectReference"):GetRefValue("selectedUImage").gameObject:SetActiveEx(false)
		else
			local spawnerId = self.model:getSpawnerIdByMarkName(button.name)

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedTaskId then
				self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
			end

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedObj then
				self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
			end
		end

		self.curSelectedBtn[button] = nil

		self:onMarkSelectedChanged(button, false)
	end
end

function MapCtrl:isMarkVisibleForStack(spawnerId, markCache)
	if not markCache or markCache.markStatus == Const.MAP_MARK_STATUS_HIDE then
		return false
	end

	if markCache.ClickorNot ~= 0 then
		return false
	end

	if not self:isMarkActiveByData(spawnerId, markCache) then
		return false
	end

	local markInfo = self:getMarkInfo(spawnerId)

	if self:isMarkVisibleAtLogicTime(markInfo and markInfo.refreshLogicTimes) == false then
		return false
	end

	if self.tempFilter and self.tempFilter.configIds and #self.tempFilter.configIds > 0 then
		if not LuaUIUtils.tableContains(self.tempFilter.configIds, markCache.markConfigId) and not pg.game.map:isSpawnerTracked(spawnerId) then
			return false
		end
	elseif not pg.game.map:isEnabledByFilter(self.sceneId, markCache.markConfigId, markCache.markStatus, spawnerId, {
		finishStateAlwaysShow = markCache.finishStateAlwaysShow
	}) then
		return false
	end

	if not pg.game.map:isEnabledByTotalFilter(self.sceneId, markCache.markConfigId) then
		return false
	end

	if self.enableMultiDeleteMode and markCache.markType ~= Const.MAP_MARK_CUSTOM and markCache.markType ~= Const.MAP_MARK_ZONE then
		return false
	end

	return true
end

function MapCtrl:checkIfIconStack(button)
	local aimX = button.transform.anchoredPosition.x
	local aimY = button.transform.anchoredPosition.y
	local fixedGap = SysConfigData.ICON_STACK_COE[self:curStageScaleConvertor(self.curStage)]
	local x, y
	local curPlatform = ClientUtils.getAdaptionPlatform()

	if curPlatform == UIConst.PLATFORM.Mobile then
		x, y = self:getPointerPos(self.twoFingersPosition)
	elseif curPlatform == UIConst.PLATFORM.Console and self.mapVirtualMouseField then
		x, y = self:getPointerPos(self.mapVirtualMouseField:GetVirtualMousePosition())
	else
		x, y = self:getPointerPos(UnityInput.mousePosition)
	end

	local btns = {}

	for spawnerId, markCache in pairs(self.markCaches) do
		local uBtn = markCache.button

		if NotNil(uBtn) and self:isMarkVisibleForStack(spawnerId, markCache) then
			local rectTransform = uBtn.transform:GetComponent("RectTransform")
			local targetX = rectTransform.anchoredPosition.x
			local targetY = rectTransform.anchoredPosition.y
			local btn = {}

			if fixedGap >= math.abs(aimX - targetX) and fixedGap >= math.abs(aimY - targetY) then
				btn.button = uBtn
				btn.markType = markCache.markType
				btn.spawnerId = spawnerId

				if btn.markType == Const.MAP_MARK_CUSTOM then
					btn.customMarkName = self.model:getCustomMarkName(spawnerId, self.sceneId)
				elseif btn.markType == Const.MAP_MARK_QUEST then
					btn.questId = markCache.questId
				end

				btn.distance = Vector2.Distance(targetX, targetY, x, y)
				btn.priority = markCache.priority or pg.game.map:getMarkPriorityByConfigId(markCache.markConfigId)
				btns[#btns + 1] = btn
			end
		end
	end

	table.sort(btns, function(a, b)
		local pa = a.priority or 0
		local pb = b.priority or 0

		if pa ~= pb then
			return pb < pa
		end

		return a.distance < b.distance
	end)

	return btns
end

function MapCtrl:pinIconListRender(button, index, selectedIndex, objInfo, spawnerId)
	button:TryChangePage("GamePadFocus", 0)

	button.isSelected = false

	button:TryChangePage("IconType", index)

	function button.luaClick()
		local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
		local iconList = objectReference:GetRefValue("iconList")
		local btns = iconList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			btns[i]:TryChangePage("GamePadFocus", 0)

			btns[i].isSelected = false
		end

		button.isSelected = true

		button:TryChangePage("GamePadFocus", 1)

		if objInfo == nil then
			self.view.fakeCustomMarkUButton.transform:GetComponent("ObjectReference"):GetRefValue("customUButton"):TryChangePage("IconType", index)
		else
			if self.markCaches[spawnerId].resObj then
				self.markCaches[spawnerId].resObj:GetComponent("UButton"):TryChangePage("IconType", index)
			end

			if spawnerId ~= nil then
				local sceneIdLen = #tostring(self.sceneId)
				local markTypeLen = #tostring(Const.MAP_MARK_CUSTOM)
				local spawnerIdLen = #tostring(spawnerId)
				local genId = tonumber(string.sub(tostring(spawnerId), -(spawnerIdLen - sceneIdLen - markTypeLen - markTypeLen)))

				if self.sceneId ~= nil and genId ~= nil then
					pg.me:serverMsg("RPC_CS_UpdateCustomMapMark", self.sceneId, genId, {
						markIconIndex = index
					})
				end
			end
		end

		self.selectedMarkIndex = index
	end

	if index == selectedIndex then
		button.luaClick()
	end
end

function MapCtrl:centralizeMark(markName, instant, cb)
	local mark, trans, anchoredPositionX, anchoredPositionY

	if markName == "BtnMine" then
		mark = self.view.markerListTransformLayer100.transform:Find(markName)

		if mark == nil then
			return
		end

		trans = mark:GetComponent("RectTransform")
		anchoredPositionX = trans.anchoredPosition.x
		anchoredPositionY = trans.anchoredPosition.y
	elseif markName == "FakeCustomMark" then
		mark = self.view.markerListTransform:Find(markName)

		if mark == nil then
			return
		end

		trans = mark:GetComponent("RectTransform")
		anchoredPositionX = trans.anchoredPosition.x
		anchoredPositionY = trans.anchoredPosition.y
	else
		local markId = self.model:getSpawnerIdByMarkName(markName)

		mark = self.markCaches[markId]

		if mark == nil then
			local markInfo = self:getMarkInfo(markId)

			if not markInfo or not markInfo.markPosition then
				return
			end

			anchoredPositionX, anchoredPositionY = pg.game.map:convertPos(markInfo.markPosition[1], markInfo.markPosition[3], self.sceneId, true)
			self.centralizingMarkId = markId

			self:prepareMarkLoad(markInfo, markId, true)
		else
			anchoredPositionX = mark.anchoredPositionX
			anchoredPositionY = mark.anchoredPositionY
		end

		local x, y = pg.game.map:GetCurrentBindMapMarkPos(markId)

		if x then
			anchoredPositionX = x
			anchoredPositionY = y
		end
	end

	self:ViewMoveToPos(anchoredPositionX, anchoredPositionY, instant, cb)
end

function MapCtrl:centralizeMarkByMarkId(markId, instant, cb)
	local mark = self.markCaches[markId]
	local anchoredPositionX, anchoredPositionY

	if mark == nil then
		local markInfo = self:getMarkInfo(markId)

		if not markInfo or not markInfo.markPosition then
			return
		end

		anchoredPositionX, anchoredPositionY = pg.game.map:convertPos(markInfo.markPosition[1], markInfo.markPosition[3], self.sceneId, true)
		self.centralizingMarkId = markId

		self:prepareMarkLoad(markInfo, markId, true)
	else
		anchoredPositionX = mark.anchoredPositionX
		anchoredPositionY = mark.anchoredPositionY
	end

	local x, y = pg.game.map:GetCurrentBindMapMarkPos(markId)

	if x then
		anchoredPositionX = x
		anchoredPositionY = y
	end

	self:ViewMoveToPos(anchoredPositionX, anchoredPositionY, instant, cb)
end

function MapCtrl:ViewMoveToPos(anchoredPositionX, anchoredPositionY, instant, cb)
	local widthSum = UIConst.MAP_CONST.FIXED_MAP_WIDTH / 2 * self.currentZoom
	local heightSum = -(UIConst.MAP_CONST.FIXED_MAP_HEIGHT / 2) * self.currentZoom
	local mapOffsetX = math.clamp(widthSum - anchoredPositionX * self.currentZoom, self.minMapAnchoredPosX, self.maxMapAnchoredPosX)
	local mapOffsetY = math.clamp(heightSum - anchoredPositionY * self.currentZoom, self.minMapAnchoredPosY, self.maxMapAnchoredPosY)

	self.view.mapScroll.zoomTool.muteZoom = true

	self.view.blockRayboxUWidget.gameObject:SetActiveEx(true)
	self.view.mapScroll:SetScrollDisabled(true)
	DoTweenAnimMgr.AnchorPositionMove(self.view.mapScrollContent, LuaUIUtils.TweenId(ANCHOR_POSITION_MOVE_TWEEN_ID), Vector3(mapOffsetX, mapOffsetY, 0), instant and 0 or 0.3, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		if cb then
			cb()
		end

		self.view.mapScroll.zoomTool.muteZoom = false

		self.view.blockRayboxUWidget.gameObject:SetActiveEx(false)
		self.view.mapScroll:SetScrollDisabled(false)

		self.centralizingMarkId = nil
	end, false, function()
		self:onMapVisionChanged()
	end)
end

function MapCtrl:centralizePos(mapX, mapY, instant, cb)
	local widthSum = UIConst.MAP_CONST.FIXED_MAP_WIDTH / 2 * self.currentZoom
	local heightSum = -(UIConst.MAP_CONST.FIXED_MAP_HEIGHT / 2) * self.currentZoom
	local mapOffsetX = math.clamp(widthSum - mapX * self.currentZoom, self.minMapAnchoredPosX, self.maxMapAnchoredPosX)
	local mapOffsetY = math.clamp(heightSum - mapY * self.currentZoom, self.minMapAnchoredPosY, self.maxMapAnchoredPosY)

	self.view.mapScroll.zoomTool.muteZoom = true

	self.view.blockRayboxUWidget.gameObject:SetActiveEx(true)
	self.view.mapScroll:SetScrollDisabled(true)
	DoTweenAnimMgr.AnchorPositionMove(self.view.mapScrollContent, LuaUIUtils.TweenId(ANCHOR_POSITION_MOVE_TWEEN_ID), Vector3(mapOffsetX, mapOffsetY, 0), instant and 0 or 0.3, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
		if cb then
			cb()
		end

		self.view.mapScroll.zoomTool.muteZoom = false

		self.view.blockRayboxUWidget.gameObject:SetActiveEx(false)
		self.view.mapScroll:SetScrollDisabled(false)

		self.centralizingMarkId = nil
	end, false, function()
		self:onMapVisionChanged()
	end)
end

function MapCtrl:debugQuickMove(mousePos)
	if SceneData[self.sceneId].PointAPositon == nil then
		return
	end

	local point = pg.global.uiMgr:ScreenPointToLocalPoint(self.view.mapScrollContent, mousePos)
	local worldX, worldZ = pg.game.map:convertPos(point.x + UIConst.MAP_CONST.FIXED_MAP_WIDTH / 2, point.y - UIConst.MAP_CONST.FIXED_MAP_HEIGHT / 2, self.sceneId, false)
	local pos = pg.me.eModel:TeleportWithPositionXZ(Const.COMPONENT_INDEX_MAIN_PLAYER, worldX, worldZ)

	if pos == Vector3.zero then
		pos = Vector3(worldX, 200, worldZ)
	end

	ClientUtils.teleportPos(pos)
	self:closePanel(true)
end

function MapCtrl:endScale(stage, currentZoom)
	self:recordLastPointerPosInScreen()

	self.curStage = stage
	self.currentZoom = currentZoom

	if self.firstIn then
		self.view.mapScrollContent.localScale = Vector3(currentZoom, currentZoom, 1)

		self:refreshMinMaxMapAnchoredPosXY(currentZoom)
		self:centralizeMark("BtnMine", true)

		self.firstIn = nil
	else
		self.view.mapScrollContent.transform.localScale = Vector3(currentZoom, currentZoom, 1)

		self:refreshMinMaxMapAnchoredPosXY(currentZoom)
		self:doMapOffset(currentZoom)
	end

	self.view.mineMarkTrans.localScale = Vector3(1 / currentZoom, 1 / currentZoom, 1)
	self.view.fakeCustomMarkUButton.transform.localScale = Vector3(1 / currentZoom, 1 / currentZoom, 1)

	local scaleKey = string.format("scale%s", self:curStageScaleConvertor(self.curStage))

	for spawnerId, v in pairs(self.markCaches) do
		if NotNil(v.gameObject) then
			self:refreshMarkVisibility(spawnerId, scaleKey)
			v.recTrans:SetLocalScaleEx(1 / currentZoom, 1 / currentZoom, 1)

			if (v.type == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE or v.type == Const.MAP_CONST.TYPE.ECO_TRACE) and v.resObj then
				local objectReference = v.resObj:GetComponent("ObjectReference")
				local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")

				imgGlowUImage.transform.localScale = Vector3(currentZoom, currentZoom, 1)
			elseif v.circleRadius and v.resObj then
				local objRef = v.resObj.gameObject.transform:GetComponent("ObjectReference")
				local circleAreaTransform = objRef:GetRefValue("circleAreaTransform")

				if circleAreaTransform then
					local r = pg.game.map:calRadius(self.sceneId, v.circleRadius)
					local sizeDeltaNum = r / (1 / self.currentZoom) * 2

					circleAreaTransform.transform.sizeDelta = Vector2(sizeDeltaNum, sizeDeltaNum)
				end
			end
		end
	end

	if #self.view.mapLevelBreakdown == 4 and self.curStage == #self.view.scaleBasicTable then
		if self.mapNavLineComponent then
			self.mapNavLineComponent:setVisible(false)
		end

		if self.grabEggAreaComponent then
			self.grabEggAreaComponent:adjustActiveState(false)
		end
	else
		if self.mapNavLineComponent then
			self.mapNavLineComponent:adjustLineWidth()
			self.mapNavLineComponent:setVisible(true)
		end

		if self.grabEggAreaComponent then
			self.grabEggAreaComponent:adjustScale(self.currentZoom)
			self.grabEggAreaComponent:adjustActiveState(true)
		end
	end

	if self.multiSelectBoxTaskObj then
		self.multiSelectBoxTaskObj.transform.localScale = Vector3(1 / currentZoom, 1 / currentZoom, 1)

		local objectReference = self.multiSelectBoxTaskObj:GetComponent("ObjectReference")
		local size = objectReference:GetRefValue("size")
		local elements = {}

		for _, v in pairs(self.stackIcons) do
			elements[#elements + 1] = v.button.transform
		end

		UIUtils.CalculateSelectionBox(elements, self.multiSelectBoxTaskObj.transform, size.transform)
	end
end

function MapCtrl:hideOrShowMarkByMarkTypeExcept(exceptMarkTypeTable, hide)
	for _, v in pairs(self.markCaches) do
		if NotNil(v.button) then
			if hide then
				if not LuaUIUtils.tableContains(exceptMarkTypeTable, v.markType) then
					v.button:TryChangePage("hideAllChildren", 1)
				else
					v.button:TryChangePage("hideAllChildren", 0)
				end
			else
				v.button:TryChangePage("hideAllChildren", 0)
			end

			local spawnerId = self.model:getSpawnerIdByMarkName(v.button.name)

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedTaskId then
				self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
			end

			if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedObj then
				self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
			end

			if self.curSelectedBtn then
				self.curSelectedBtn[v.button] = nil

				self:onMarkSelectedChanged(v.button, false)
			end
		end
	end
end

function MapCtrl:addToCustomMarkMultiDeleteGroup(button, spawnerId)
	if self.customMarkMultiDeleteGroup[spawnerId] == nil then
		self.markCaches[spawnerId].selectedTaskId = self.view:addPrefabWithPathAsync(self.markCaches[spawnerId].upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_SELECTED, function(obj)
			self.markCaches[spawnerId].selectedObj = obj.gameObject
		end, false, false, 0)
		self.curSelectedBtn[button] = true

		self:onMarkSelectedChanged(button, true)

		self.customMarkMultiDeleteGroup[spawnerId] = {
			button = button,
			genId = MapHelper.getCustomMarkGenId(spawnerId, self.sceneId)
		}
	else
		if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedTaskId then
			self.view:cancelUIAsyncTask(self.markCaches[spawnerId].selectedTaskId)
		end

		if self.markCaches[spawnerId] and self.markCaches[spawnerId].selectedObj then
			self.view:destroyInstance(self.markCaches[spawnerId].selectedObj)
		end

		self.curSelectedBtn[button] = nil

		self:onMarkSelectedChanged(button, false)

		self.customMarkMultiDeleteGroup[spawnerId] = nil
	end

	ClientTextUtils.setText(self.view.multiDeletePanelCount, lume.count(self.customMarkMultiDeleteGroup) .. "/" .. self:countCustomMark())
end

function MapCtrl:enableMultiDeletePanel(enable)
	self.view.deleteUWidget.gameObject:SetActiveEx(enable)
	self.view.btnNourish:SetHotkeyForceHidden(enable)

	if enable then
		self.enableMultiDeleteMode = true

		self:hideOrShowMarkByMarkTypeExcept({
			Const.MAP_MARK_CUSTOM,
			Const.MAP_MARK_ZONE
		}, true)

		function self.view.multiDeletePanelCloseBtn.luaClick()
			self:enableMultiDeletePanel(false)
		end

		function self.view.multiDeletePanelDeleteBtn.luaClick()
			for k, _ in pairs(self.customMarkMultiDeleteGroup) do
				local genId = MapHelper.getCustomMarkGenId(k, self.sceneId)

				pg.me:serverMsg("RPC_CS_DelCustomMapMark", self.sceneId, genId)

				if self.differentSceneTrackMark and self.differentSceneTrackMark == k then
					self.mapNavLineComponent:drawNavEffLine()

					self.differentSceneTrackMark = nil
				end
			end

			self.enableMultiDeleteMode = false

			self:hideOrShowMarkByMarkTypeExcept(nil, false)

			self.customMarkMultiDeleteGroup = {}

			self.view.deleteUWidget.gameObject:SetActiveEx(false)
			self.view.btnNourish:SetHotkeyForceHidden(false)
		end

		if not self.customMarkMultiDeleteGroup then
			self.customMarkMultiDeleteGroup = {}
		end

		local totalCustomMarkCount = self:countCustomMark()

		ClientTextUtils.setText(self.view.multiDeletePanelCount, lume.count(self.customMarkMultiDeleteGroup) .. "/" .. totalCustomMarkCount)
	else
		self.enableMultiDeleteMode = false

		self:hideOrShowMarkByMarkTypeExcept(nil, false)

		self.customMarkMultiDeleteGroup = {}

		self:refreshCoordinate()
	end
end

function MapCtrl:countCustomMark()
	local count = 0

	for _, v in pairs(self.tempMarkPointData) do
		if v.markType == Const.MAP_MARK_CUSTOM then
			count = count + 1
		end
	end

	return count
end

function MapCtrl:isMarkActiveByData(spawnerId, info, scaleKey)
	if not self.view or not self.curStage or not info then
		return false
	end

	scaleKey = scaleKey or string.format("scale%s", self:curStageScaleConvertor(self.curStage))

	local selected = info.button and self.curSelectedBtn and self.curSelectedBtn[info.button]
	local forceVisible = pg.game.map:shouldForceVisibleMark(spawnerId)
	local active = false

	if info[scaleKey] == 1 or selected or forceVisible then
		if info.UsableState and LuaUIUtils.tableContains(info.UsableState, info.markStatus) or selected then
			active = true

			if info.markType == Const.MAP_MARK_TRACE and not pg.game.map.curTraceMark[spawnerId] and not pg.game.map.trackMarksRecord[spawnerId] then
				active = false
			end
		end

		if self.view.mapLevelBreakdown and #self.view.mapLevelBreakdown == 4 and self.curStage == #self.view.scaleBasicTable and forceVisible then
			active = true
		end
	end

	return active
end

function MapCtrl:refreshMarkVisibility(spawnerId, scaleKey)
	if not self.view or not self.curStage then
		return
	end

	local info = self.markCaches and self.markCaches[spawnerId]

	if not info or not NotNil(info.gameObject) then
		return
	end

	local active = self:isMarkActiveByData(spawnerId, info, scaleKey)

	info.gameObject:SetActiveEx(active)
end

function MapCtrl:onMarkSelectedChanged(btn, isSelect)
	if btn == self.view.fakeCustomMarkUButton then
		if isSelect then
			-- block empty
		elseif not next(self.curSelectedBtn) then
			self:refreshCoordinate()
		end

		return
	end

	local spawnerId = self.model:getSpawnerIdByMarkName(btn.name)
	local info = self.markCaches[spawnerId]

	self:refreshMarkVisibility(spawnerId)

	if isSelect then
		self:refreshCoordinate(info.markPos[1], info.markPos[3], info.realSceneId)
	elseif not next(self.curSelectedBtn) then
		self:refreshCoordinate()
	end
end

function MapCtrl:removeSelectedBtn(spawnerId)
	local info = self.markCaches[spawnerId]

	if not info then
		return
	end

	self.curSelectedBtn[info.button] = nil
end

function MapCtrl:closePanel(force)
	if not force and self.bitMaskComponent and self.bitMaskComponent:isAreaFogUnlocking() then
		return
	end

	if pg.game.map:checkAtLeastOneTrackingMarkQuestExcept() then
		pg.global.ui:closeAllNormalPanel({
			[UIConst.UI_ID_CASH_SHOP] = true
		})

		return
	end

	pg.global.ui:close(UIConst.UI_ID_MAP)
end

function MapCtrl:displayMapFog(flag)
	if flag == nil then
		return
	end

	local fog = self.view.mapScrollContent:Find("Fog")

	if not fog then
		return
	end

	local fogWidget = fog:GetComponent("UWidget")

	fogWidget.gameObject:SetActiveEx(flag)
end

function MapCtrl:loadSavedCustomMark()
	local customMapMarkMap = pg.me.customMapMarkMap
	local allChildrenScenes = MapHelper.getAllChildrenScene(self.sceneId)

	for _, sceneId in pairs(allChildrenScenes) do
		if customMapMarkMap[sceneId] then
			for k, v in pairs(customMapMarkMap[sceneId]) do
				local markType = LuaUIUtils.checkFastTargetMark() and Const.MAP_MARK_FAST_TARGET or Const.MAP_MARK_CUSTOM
				local id = tonumber(string.format("%s%s%s%s", sceneId, markType, markType, k))

				pg.game.map:addOrUpdateTempMark(sceneId, v.pos[1], v.pos[2], v.pos[3], id, markType, {
					markIconIndex = v.markIconIndex
				}, self.tempMarkPointData)
			end
		end
	end
end

function MapCtrl:loadSavedMarkShare()
	if not pg.game.markShare:shouldShowOwnMediaMarker() then
		for markId, markData in pairs(self.tempMarkPointData or EMPTY_TABLE) do
			if markData.markType == Const.MAP_MARK_SHARE then
				self.tempMarkPointData[markId] = nil
			end
		end

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

			pg.game.map:addOrUpdateTempMark(pg.game.map:convertSceneId(v.sceneId), v.pos[1], v.pos[2], v.pos[3], k, Const.MAP_MARK_SHARE, nil, self.tempMarkPointData)
		end
	end
end

function MapCtrl:_removeMapMark(spawnerId)
	self:removeSelectedBtn(spawnerId)
	self:clearPreviousTask(spawnerId)

	if self.pointsTasks and self.pointsTasks[spawnerId] then
		if self.pointsTasks[spawnerId].taskId then
			self.view:cancelUIAsyncTask(self.pointsTasks[spawnerId].taskId)
		end

		if self.pointsTasks[spawnerId].taskObj then
			self.view:destroyInstance(self.pointsTasks[spawnerId].taskObj)
		end

		self.pointsTasks[spawnerId] = nil
	end

	if self.pendingMarkLoads then
		self.pendingMarkLoads[spawnerId] = nil
	end

	if self.activeNormalMarks then
		self.activeNormalMarks[spawnerId] = nil
	end

	if self.markLastSeen then
		self.markLastSeen[spawnerId] = nil
	end

	self.markCaches[spawnerId] = nil
end

function MapCtrl:onTeamMarkChange()
	if self:isDifferentScene() then
		return
	end

	self.teamMarkPointData = pg.game.map.teamMarkPointData or {}
	self.teamMarkIds = self.teamMarkIds or {}

	local currentTeamMarkIds = {}

	for markId, markPointData in pairs(self.teamMarkPointData) do
		currentTeamMarkIds[markId] = true

		local cache = self.markCaches[markId]
		local shouldReload = not cache

		if not markPointData or not markPointData.markPosition then
			self:_removeMapMark(markId)
		elseif cache and cache.markPos then
			shouldReload = cache.markType ~= markPointData.markType or cache.markConfigId ~= markPointData.markConfigId or cache.markPos[1] ~= markPointData.markPosition[1] or cache.markPos[2] ~= markPointData.markPosition[2] or cache.markPos[3] ~= markPointData.markPosition[3]
		end

		if markPointData and markPointData.markPosition and shouldReload then
			self:_removeMapMark(markId)
			self:prepareMarkLoad(markPointData, markId, true)
		end
	end

	for markId, _ in pairs(self.teamMarkIds) do
		if not currentTeamMarkIds[markId] then
			self:_removeMapMark(markId)
		end
	end

	self.teamMarkIds = currentTeamMarkIds
end

function MapCtrl:onTeamMarkTrackChange()
	if not self.markCaches then
		return
	end

	for spawnerId, cache in pairs(self.markCaches) do
		self:renderTeamTrack(spawnerId, cache)
	end

	if self.markBubbleComponent then
		self.markBubbleComponent:onTeamMarkTrackChange()
	end
end

function MapCtrl:isDifferentScene()
	local sceneId = self:_getCurrentSpaceSceneId()

	if sceneId == nil then
		return false
	end

	return self.sceneId ~= pg.game.map:convertSceneId(sceneId)
end

function MapCtrl:onFlowerStateChanged(info)
	if self.MapLeftTopTipsComponent then
		self.MapLeftTopTipsComponent:onFlowerStateChanged(info)
	end
end

function MapCtrl:onHomeCampDispatchStateChanged()
	if self.MapLeftTopTipsComponent then
		self.MapLeftTopTipsComponent:onHomeCampDispatchStateChanged()
	end
end

function MapCtrl:_setLeylineFlowerQualityVxVisible(root, visible)
	if IsNil(root) then
		return
	end

	local uComponent = root:GetComponent("UComponent")

	if NotNil(uComponent) then
		uComponent:TryChangePage("showParticle", visible and 1 or 0)
	end
end

function MapCtrl:_stopLeylineFlowerQualityVx()
	self.leylineFlowerQualityVxVersion = (self.leylineFlowerQualityVxVersion or 0) + 1
	self.pendingLeylineFlowerQualityVx = nil

	if self.leylineFlowerQualityVxTimer then
		self:killTimer(self.leylineFlowerQualityVxTimer)

		self.leylineFlowerQualityVxTimer = nil
	end

	local vxContainer = self.activeLeylineFlowerQualityVxContainer

	if NotNil(vxContainer) then
		vxContainer:DestroyContent()
	end

	self:_setLeylineFlowerQualityVxVisible(self.activeLeylineFlowerQualityVxRoot, false)

	self.activeLeylineFlowerQualityVxFlowerId = nil
	self.activeLeylineFlowerQualityVxRoot = nil
	self.activeLeylineFlowerQualityVxContainer = nil
end

function MapCtrl:requestLeylineFlowerQualityVx(flowerId, quality)
	quality = math.floor(tonumber(quality) or 0)

	local vxUrl = LEYLINE_FLOWER_QUALITY_VX_URLS[quality]

	if not flowerId or not vxUrl then
		return false
	end

	self:_stopLeylineFlowerQualityVx()

	self.pendingLeylineFlowerQualityVx = {
		flowerId = flowerId,
		quality = quality,
		vxUrl = vxUrl,
		version = self.leylineFlowerQualityVxVersion
	}

	return self:tryPlayLeylineFlowerQualityVx(flowerId)
end

function MapCtrl:tryPlayLeylineFlowerQualityVx(flowerId)
	local request = self.pendingLeylineFlowerQualityVx

	if not request or request.flowerId ~= flowerId then
		return false
	end

	local cache = self.markCaches and self.markCaches[flowerId]
	local root = cache and cache.resObj

	if IsNil(root) then
		return false
	end

	local objectReference = root:GetComponent("ObjectReference")
	local vxContainer = NotNil(objectReference) and objectReference:GetRefValue("vXContainerUContainer") or nil

	if IsNil(vxContainer) then
		self.pendingLeylineFlowerQualityVx = nil

		return false
	end

	self.pendingLeylineFlowerQualityVx = nil
	self.activeLeylineFlowerQualityVxFlowerId = flowerId
	self.activeLeylineFlowerQualityVxRoot = root
	self.activeLeylineFlowerQualityVxContainer = vxContainer

	self:_setLeylineFlowerQualityVxVisible(root, true)
	vxContainer:DestroyContent()

	local requestVersion = request.version

	vxContainer:SetUrlWithCallback(request.vxUrl, function(content)
		if requestVersion ~= self.leylineFlowerQualityVxVersion or self.activeLeylineFlowerQualityVxFlowerId ~= flowerId or self.activeLeylineFlowerQualityVxContainer ~= vxContainer then
			return
		end

		if IsNil(content) then
			self:_stopLeylineFlowerQualityVx()

			return
		end

		self.leylineFlowerQualityVxTimer = self:startTimer(function()
			self.leylineFlowerQualityVxTimer = nil

			if requestVersion ~= self.leylineFlowerQualityVxVersion then
				return
			end

			self:_stopLeylineFlowerQualityVx()
		end, LEYLINE_FLOWER_QUALITY_VX_DURATION, false)
	end)

	return true
end

function MapCtrl:onPlentyCircleChanged(info)
	if self.MapLeftTopTipsComponent then
		self.MapLeftTopTipsComponent:onPlentyCircleChanged(info)
	end
end

function MapCtrl:onRequestSelfMarkInfo(info)
	if not info.result then
		return
	end

	local markers = info.markers

	if markers[self.locationInfoPanelCurMarkId] then
		local content = json.decode(markers[self.locationInfoPanelCurMarkId].content)
		local txt = pg.game.markShare:getTemplateTxt(content)
		local objectReference = self.view.locationInfo:GetComponent("ObjectReference")
		local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")

		self:renderDetailScrollRect(scrollRectUScrollRect, {
			desc = txt
		})
	end
end

function MapCtrl:getHomeCampInfo(spawnerId)
	local homeCampKey = pg.me.campSpaceKeyMap[spawnerId]
	local lineId = 0

	if homeCampKey then
		lineId = HomeLandUtils.getCampLineId(homeCampKey)
	end

	local fullCampInfo = pg.me.worldHomeCampInfo and pg.me.worldHomeCampInfo[spawnerId]
	local displayCode = ""

	if fullCampInfo then
		local lineInfo = fullCampInfo.lineInfo

		if lineInfo then
			displayCode = lineInfo.displayCode
		end
	end

	local campInfo = {
		lineId = lineId,
		displayCode = displayCode,
		homeCampKey = homeCampKey,
		isPlaced = pg.me.curCampStaticId == spawnerId
	}

	return campInfo
end

function MapCtrl:renderHomeCampInfo(objectReference, markStatus, spawnerId, spawnerTable)
	local homeCampTeleportBtn = objectReference:GetRefValue("homeCampTeleportBtn")
	local homeCampSearchBtn = objectReference:GetRefValue("homeCampSearchBtn")
	local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	local previewImgImg = objectReference:GetRefValue("previewImgImg")
	local homeCampTip = objectReference:GetRefValue("homeCampTip")
	local homeCampData = HomeCampData[spawnerId]
	local homeCampInfo = self:getHomeCampInfo(spawnerId)

	if homeCampInfo.isPlaced then
		homeCampTip:SetActive(true)
	else
		homeCampTip:SetActive(false)
	end

	previewImgImg.gameObject:SetActiveEx(true)

	previewImgImg.url = homeCampData.image

	local homeCampText

	if markStatus == Const.MAP_MARK_STATUS_UNLOCKED then
		self.view.locationInfo:TryChangePage("MapMarkButtonStates", 6)

		if not string.isNilOrEmpty(homeCampInfo.displayCode) then
			homeCampText = pg.getFormatText(pg.getGameString("HOME_CAR_LINE_TEXT"), homeCampInfo.displayCode)
		end

		local rewardList = {}

		for _, itemId in ipairs(homeCampData.rewardItemList) do
			rewardList[#rewardList + 1] = {
				type = 0,
				id = itemId,
				unkownInfoText = pg.getGameString("HOME_CAMP_UNKOWN_REWARD_TIP")
			}
		end

		self:renderLocationInfoPanelRewards(objectReference, spawnerId, markStatus, rewardList, pg.getFormatText(pg.getGameString("HOMECAMP_SPECIALTY_NEARBY"), pg.getLocalizationText(homeCampData.name)))
		self:renderDetailScrollRect(scrollRectUScrollRect, {
			homeCampText = homeCampText,
			desc = spawnerTable.infoText or ""
		})
	else
		self:renderDetailScrollRect(scrollRectUScrollRect, {
			homeCampText = homeCampText,
			desc = spawnerTable.infoTextNot or ""
		})
	end

	function homeCampSearchBtn.luaClick()
		pg.global.ui.homeCampVisit:open({
			isFromMap = true,
			campId = spawnerId
		})
	end

	function homeCampTeleportBtn.luaClick()
		if homeCampInfo.isPlaced then
			pg.me:enterSelfHomeCamp()
		else
			ClientUtils.playTeleportDissolveEffectAndTeleport(pg.game.map:convertSceneId(spawnerTable.realSceneId), spawnerId)
		end

		self:closePanel(true)
	end

	self.homeCampTeleportBtn = homeCampTeleportBtn

	local btnName = homeCampTeleportBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	local inDiffCamp = false
	local space = pg.space

	if homeCampInfo.isPlaced == true and pg.me ~= nil and space ~= nil and Utils.isHomeCamp(space.spaceType) and space.staticId == pg.me.curCampStaticId and space.lineId ~= pg.me.curCampLineId then
		inDiffCamp = true
	end

	if inDiffCamp then
		ClientTextUtils.setText(btnName, pg.getGameString("HOME_GO_SELF_CAMP"))
	else
		ClientTextUtils.setText(btnName, pg.getGameString("HOME_GO_CAMP"))
	end
end

function MapCtrl:renderDetailScrollRect(scrollRect, info)
	local objectReference = scrollRect.content.transform:GetComponent("ObjectReference")
	local descriptionUSDFText = objectReference:GetRefValue("descriptionUSDFText")
	local challengeNumberUWidget = objectReference:GetRefValue("challengeNumberUWidget")
	local treasureChestUWidget = objectReference:GetRefValue("treasureChestUWidget")
	local challengeNum = objectReference:GetRefValue("challengeNum")
	local chestNum = objectReference:GetRefValue("chestNum")
	local photoUWidget = objectReference:GetRefValue("photoUWidget")
	local textLocationUBaseText = objectReference:GetRefValue("textLocationUBaseText")
	local textUserNameUBaseText = objectReference:GetRefValue("textUserNameUBaseText")
	local trackUWidget = objectReference:GetRefValue("trackUWidget")
	local ecoTrackUList = objectReference:GetRefValue("ecoTrackUList")
	local emptyEcoTrack = objectReference:GetRefValue("emptyEcoTrack")
	local homeCampIDText = objectReference:GetRefValue("homeCampIDText")
	local bossEffectTransform = objectReference:GetRefValue("bossEffectTransform")

	self:renderBossChallengeInfo(objectReference, info.spawnerId, info.spawnerTable and info.spawnerTable.markConfigId)

	local description = pg.getLocalizationText(info.desc)
	local startConditionDesc = info.locationInfo and info.locationInfo.startConditionDesc or ""

	if not string.isNilOrEmpty(startConditionDesc) then
		if string.isNilOrEmpty(description) then
			description = startConditionDesc
		else
			description = string.format("%s\n%s", description, startConditionDesc)
		end
	end

	ClientTextUtils.setText(descriptionUSDFText, description)
	challengeNumberUWidget.gameObject:SetActiveEx(info.playerNum ~= nil)
	treasureChestUWidget.gameObject:SetActiveEx(info.cratesInfo ~= nil)
	bossEffectTransform.gameObject:SetActiveEx(false)

	if info.locationInfo and info.spawnerTable then
		self:renderBossPanelPropertyInfo(objectReference, info.locationInfo, info.spawnerTable)
	end

	local isEcoTrack = info.markType and info.markType == Const.MAP_MARK_EcoTrace_Search

	trackUWidget.gameObject:SetActiveEx(isEcoTrack)

	if isEcoTrack then
		local researchList = ClientActivityUtils.getEcoStageInfo(true) or {}

		function ecoTrackUList.luaRenderItem(b, index, d)
			local activityData = ClientActivityUtils.getEcoTraceActivityData()
			local objReference = b:GetComponent("ObjectReference")
			local textDescriptionUBaseText = objReference:GetRefValue("textDescriptionUBaseText")
			local stage = index + 1
			local curPro, maxPro = ClientActivityUtils.getEcoStagePro(stage)
			local taskPro = activityData and activityData.ecoTraceSearchStageRecord == stage and (activityData.ecoTraceSearchTaskNumRecord or 0) or maxPro
			local pro = ClientActivityUtils.getEcoStageProNum(stage, taskPro)
			local petName = pg.getLocalizationText(pg.global.ui.eventEcoTraceResearch.model:getChosedPetName())

			ClientTextUtils.setText(textDescriptionUBaseText, pg.getFormatText(pg.getGameString("ECOLOGICAL_SEARCH_MAP_TIP_" .. stage), petName, pro))
		end

		ecoTrackUList:SetList(researchList)
		emptyEcoTrack.gameObject:SetActiveEx(#researchList == 0)
	end

	if info.playerNum then
		ClientTextUtils.setText(challengeNum, info.playerNum)
	end

	if homeCampIDText then
		if info.homeCampText then
			ClientTextUtils.setText(homeCampIDText, info.homeCampText)
			homeCampIDText:SetActive(true)
		else
			homeCampIDText:SetActive(false)
		end
	end

	if info.cratesInfo then
		local chestCount = #info.cratesInfo
		local finishCount = 0

		for _, chestId in ipairs(info.cratesInfo) do
			if pg.me.interactRecord[chestId] then
				finishCount = finishCount + 1
			end
		end

		ClientTextUtils.setText(chestNum, string.format("%s/%s", finishCount, chestCount))
	end

	photoUWidget:SetActive(info.photoData ~= nil)

	if info.photoData then
		local userName = info.photoData.userName
		local sceneName
		local blockId = pg.game.map:inWhichBlock(self.sceneId, false, {
			x = info.markPosition[1],
			z = info.markPosition[3]
		})

		if blockId then
			sceneName = pg.getLocalizationText(MapBlockConfigData[blockId].areaName) or ""
		else
			sceneName = pg.game.map:getSceneName(self.sceneId) or ""
		end

		ClientTextUtils.setText(textLocationUBaseText, sceneName)
		ClientTextUtils.setText(textUserNameUBaseText, userName)
	end
end

function MapCtrl:renderDetailLocationInfo(objectReference, locationInfo, spawnerId, markType)
	local selectIconUComponent = objectReference:GetRefValue("selectIconUComponent")
	local tipsUWidget = objectReference:GetRefValue("tipsUWidget")
	local btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	local listPetUList = objectReference:GetRefValue("listPetUList")
	local listSkillRequirementUList = objectReference:GetRefValue("listSkillRequirementUList")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")
	local elementList = objectReference:GetRefValue("elementList")
	local listSkillRecomUList = objectReference:GetRefValue("listSkillRecomUList")
	local requireUComponent = objectReference:GetRefValue("requireUComponent")
	local recommendUComponent = objectReference:GetRefValue("recommendUComponent")
	local btnInjectUButton = objectReference:GetRefValue("btnInjectUButton")
	local bossInfoUWidget = objectReference:GetRefValue("bossInfoUWidget")

	bossInfoUWidget.gameObject:SetActiveEx(false)

	local markCache = self.markCaches[spawnerId]
	local inAreaRange = markCache and markCache.inAreaRange or 0

	selectIconUComponent:TryChangePage("LayerState", inAreaRange > 0 and 2 or 0)
	selectIconUComponent:TryChangePage("Inject", 0)

	local leylineTreeId = pg.game.map:getLeylineTreeIdByMarkId(spawnerId)

	if leylineTreeId and markType == Const.MAP_MARK_LEYLINETREE then
		selectIconUComponent:TryChangePage("Inject", 1)

		function btnInjectUButton.luaClick()
			pg.me:event_interactLeylineTree({
				SceneLeylineTreeAreaData[spawnerId].treeId
			})
			self:closePanel()
		end
	end

	tipsUWidget.gameObject:SetActiveEx(locationInfo.helpID ~= nil)

	if locationInfo.helpID then
		function btnRulesUButton.luaClick()
			self.adapter:enableVisibleWhitelistForDuration({
				UIConst.UI_ID_MAP
			})
			pg.global.ui:open(UIConst.UI_ID_HELP, {
				helpId = locationInfo.helpID
			})
		end
	end

	ClientTextUtils.setText(txtLevelUSDFText, locationInfo.maxLevelRequire and ClientTextUtils.formatShortLevel(locationInfo.maxLevelRequire) or pg.getGameString("LEVEL_NOT_VALID"))

	if locationInfo.idInType then
		LuaUIUtils.requestMapPuppetLevel(locationInfo.idInType, function(level)
			if locationInfo.entityId then
				pg.game.map.puppetStaticIdInitRecord[locationInfo.entityId] = level
			end

			ClientTextUtils.setText(txtLevelUSDFText, ClientTextUtils.formatShortLevel(level))
		end)
	end

	if locationInfo.markConfigId and Const.MAP_INFO_BOSS_PANEL[locationInfo.markConfigId] then
		selectIconUComponent:TryChangePage("DungenLimit", 0)
		self:renderBossPanelInfo(objectReference, locationInfo, spawnerId)

		return
	end

	if not locationInfo.dungenLimit or locationInfo.dungenLimit == 0 then
		selectIconUComponent:TryChangePage("DungenLimit", 0)

		return
	else
		selectIconUComponent:TryChangePage("DungenLimit", locationInfo.dungenLimit)
	end

	function listPetUList.luaRenderItem(b, _, d)
		local objReference = b:GetComponent("ObjectReference")
		local iconUImage = objReference:GetRefValue("iconUImage")

		iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(d.iconName, LuaUIUtils.PET_ICON), function()
			return
		end)
	end

	listPetUList:SetList(locationInfo.requirePet or {})

	function listSkillRequirementUList.luaRenderItem(b, _, d)
		self:renderSkillIcon(b, d)
	end

	function listSkillRecomUList.luaRenderItem(b, _, d)
		self:renderSkillIcon(b, d)
	end

	listSkillRequirementUList:SetList(locationInfo.requireSkill or {})
	listSkillRecomUList:SetList(locationInfo.recommenSkill or {})

	function elementList.luaRenderItem(b, _, d)
		LuaUIUtils.setElementButtonNew(b, d.elementId)
	end

	elementList:SetList(locationInfo.propertyPrefer or {})

	if locationInfo.requirePet and locationInfo.requireSkill then
		requireUComponent:TryChangePage("Require", 2)
	elseif locationInfo.requirePet then
		requireUComponent:TryChangePage("Require", 0)
	elseif locationInfo.requireSkill then
		requireUComponent:TryChangePage("Require", 1)
	end

	if locationInfo.propertyPrefer and locationInfo.recommenSkill then
		recommendUComponent:TryChangePage("Recommend", 2)
	elseif locationInfo.propertyPrefer then
		recommendUComponent:TryChangePage("Recommend", 0)
	elseif locationInfo.recommenSkill then
		recommendUComponent:TryChangePage("Recommend", 1)
	end
end

function MapCtrl:renderSkillIcon(b, d)
	local objectReference = b:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")

	iconSkillUImage.url = AbilityParamData[d.skillParamId].icon
end

function MapCtrl:_getMarkDisplayStage(spawnerId)
	local markInfo = self:getMarkInfo(spawnerId)

	if not markInfo then
		return nil
	end

	for stage = 1, 4 do
		if markInfo[string.format("scale%s", stage)] == 1 then
			return stage
		end
	end

	return nil
end

function MapCtrl:focusMark(param)
	self.openLocateIntent = true

	local spawnerId = self.model:getSpawnerIdByMarkName(param[1])
	local mark = self.markCaches[spawnerId]

	if mark == nil then
		self.guideFocusFlag = param

		local markInfo = self:getMarkInfo(spawnerId)

		if markInfo then
			self:prepareMarkLoad(markInfo, spawnerId, true)
		end

		return
	end

	local stage = param[2]

	if not stage or stage == 0 then
		stage = self:_getMarkDisplayStage(spawnerId)
	end

	if stage then
		if stage == 0 then
			local markInfo = self:getMarkInfo(spawnerId)

			if markInfo then
				for i = 1, 4 do
					if markInfo["scale" .. i] == 1 then
						stage = i

						break
					end
				end
			end
		end

		self:scaleMap((#self.view.scales - stage) * self.view.stepSize)
	end

	if #self.view.mapLevelBreakdown == 4 and self.curStage == #self.view.scaleBasicTable then
		self:scaleMap(self.scaleValue + self.view.stepSize)
	end

	if param[3] then
		self:centralizeMark(param[1], false, function()
			self.manualClick = false

			mark.button:OnClickSimulate()

			if param[4] then
				param[4]()
			end
		end)
	else
		self:centralizeMark(param[1], nil, function()
			if param[4] then
				param[4]()
			end
		end)
	end
end

function MapCtrl:scaleFromOutside(stage)
	if stage then
		self:scaleMap((#self.view.scales - stage) * self.view.stepSize)
	end
end

function MapCtrl:showFilter(show)
	self.view.sortFilterUComponent.transform.localScale = show and Vector3.one or Vector3.zero
end

function MapCtrl:scaleToCustomMarkStage(mapX, mapY)
	local maxStage = self:getMaxStageByConfigStage(2)

	if not maxStage then
		return
	end

	if maxStage >= self.curStage then
		self:centralizePos(mapX, mapY, true)

		return
	end

	self:scaleMap((#self.view.scales - maxStage) * self.view.stepSize)
	self:centralizePos(mapX, mapY, true)
end

function MapCtrl:swapMarkLayer(markId, newLayer, reset)
	if not self.markCaches[markId] then
		return
	end

	local markInfo = self.markCaches[markId]

	if IsNil(markInfo.gameObject) then
		return
	end

	if newLayer then
		if newLayer == markInfo.priority then
			return
		end

		local markLayer = string.format("markerListTransformLayer%s", newLayer)

		markInfo.gameObject.transform.parent = self.view[markLayer].transform
		self.markCaches[markId].priority = newLayer
	elseif reset then
		local priority = pg.game.map:getMarkPriorityByConfigId(markInfo.markConfigId)

		if priority == markInfo.priority then
			return
		end

		local markLayer = string.format("markerListTransformLayer%s", priority)

		markInfo.gameObject.transform.parent = self.view[markLayer].transform
		self.markCaches[markId].priority = priority
	end
end

function MapCtrl:onMapVisionChanged()
	self:requestLoadVisibleMarks()

	if not self.notInteractPoints then
		return
	end

	if not self.markBubbleComponent then
		return
	end

	for _, markId in pairs(self.notInteractPoints) do
		local markInfo = self:getMarkInfo(markId)

		if markInfo then
			local mapX, mapY = pg.game.map:convertPos(markInfo.markPosition[1], markInfo.markPosition[3], self.sceneId, true)

			if not self.markBubbleComponent:isOutOfViewPort(mapX, mapY) and markInfo[string.format("scale%s", self:curStageScaleConvertor(self.curStage))] == 1 then
				if not self.notInteractPointsInViewGroup[markId] then
					self:onNotInteractPointAdded(markId)

					self.notInteractPointsInViewGroup[markId] = true
				end
			elseif self.notInteractPointsInViewGroup[markId] then
				self:onNotInteractPointRemoved(markId)

				self.notInteractPointsInViewGroup[markId] = nil
			end
		end
	end
end

function MapCtrl:onNotInteractPointAdded(markId)
	self:addMarks(self:getMarkInfo(markId), markId)
end

function MapCtrl:onNotInteractPointRemoved(markId)
	self:removeSelectedBtn(markId)
	self:clearPreviousTask(markId)

	if self.pointsTasks[markId] then
		if self.pointsTasks[markId].taskId then
			self.view:cancelUIAsyncTask(self.pointsTasks[markId].taskId)
		end

		if self.pointsTasks[markId].taskObj then
			self.view:destroyInstance(self.pointsTasks[markId].taskObj)
		end

		self.pointsTasks[markId] = nil
	end

	self.markCaches[markId] = nil
end

function MapCtrl:refreshAllFilterList()
	if self.mapMarkFilterComponent then
		self.mapMarkFilterComponent:openSearchPage(false)
		self.mapMarkFilterComponent:refreshSimpleTagList()
		self.mapMarkFilterComponent:refreshNormalList()
	end
end

function MapCtrl:openLocationPanel(enable)
	if not enable then
		self.currentLocationInfoCloseBtn = nil
		self.currentLocationInfoCloseHandler = nil
	end

	self.view.locationInfo.gameObject:SetActiveEx(enable)

	if enable then
		self.view.sortFilterUComponent.gameObject:SetActiveEx(false)
		self.view.tabBarTransform.gameObject:SetActiveEx(false)
	else
		self.view.sortFilterUComponent.gameObject:SetActiveEx(true)
		self.view.tabBarTransform.gameObject:SetActiveEx(true)
	end

	self:RefreshMapVirtualMouseState()
	self:refreshConsoleBarState()
end

function MapCtrl:isRightInfoPanelOpen()
	local locationPanelEnable = self.view.locationInfo.gameObject and self.view.locationInfo.gameObject.activeSelf
	local petAreaEnable = self.view.petAreaFloatUComponent.gameObject and self.view.petAreaFloatUComponent.gameObject.activeSelf

	return locationPanelEnable or petAreaEnable
end

function MapCtrl:IsInMapNavModal()
	return pg.global.navMgr ~= nil and pg.global.navMgr:IsInModalGroup()
end

function MapCtrl:SetMapNavModalInputMode(inNavModal)
	if not pg.global.navMgr then
		return
	end

	if inNavModal then
		if self.mapVirtualMouseModeBeforeNavModal == nil then
			self.mapVirtualMouseModeBeforeNavModal = pg.global.navMgr.IsVirtualMouseMode
		end

		pg.global.navMgr:SetVirtualMouseMode(false)
	elseif self.mapVirtualMouseModeBeforeNavModal ~= nil then
		pg.global.navMgr:SetVirtualMouseMode(self.mapVirtualMouseModeBeforeNavModal)

		self.mapVirtualMouseModeBeforeNavModal = nil
	end
end

function MapCtrl:RefreshMapVirtualMouseState()
	if self.mapVirtualMouseField == nil then
		return
	end

	local inNavModal = self:IsInMapNavModal()
	local wasInNavModal = self.mapWasInNavModal == true
	local heldStickValue

	if inNavModal and not wasInNavModal then
		self.mapNavModalStickValue = self.mapMoveStickValue
	elseif wasInNavModal and not inNavModal then
		heldStickValue = self.mapNavModalStickValue
		self.mapNavModalStickValue = nil
	end

	self.mapWasInNavModal = inNavModal

	self:SetMapNavModalInputMode(inNavModal)

	if not pg.game.input:isUsingGamepad() then
		if self.stopMapMoveByGamepad then
			self.stopMapMoveByGamepad(true)
		end

		self.mapVirtualMouseField:SetShouldProcessStickInput(false)
		self.mapVirtualMouseField:DeActivate()

		self.mapVirtualMouseActive = false

		return
	end

	if inNavModal and self.stopMapMoveByGamepad then
		self.stopMapMoveByGamepad(true)
	end

	self.mapVirtualMouseField:SetShouldProcessStickInput(false)

	local enable = self:GetMapVirtualMouseState()

	if enable then
		if not self.mapVirtualMouseActive then
			self.mapVirtualMouseField:Activate()
		end

		self.mapVirtualMouseActive = true
	else
		self.mapVirtualMouseField:DeActivate()

		self.mapVirtualMouseActive = false
	end

	if enable and heldStickValue and self.resumeMapMoveByGamepad then
		self.resumeMapMoveByGamepad(heldStickValue)
	end
end

function MapCtrl:GetMapVirtualMouseState()
	local inNavModal = self:IsInMapNavModal()

	if inNavModal then
		return false
	end

	local locationPanelEnable = self.view.locationInfo.gameObject and self.view.locationInfo.gameObject.activeSelf
	local chooseListEnable = self.view.chooseList.gameObject and self.view.chooseList.gameObject.activeSelf
	local sortFloatEnable = self.view.sortFloatUComponent.gameObject and self.view.sortFloatUComponent.gameObject.activeSelf
	local petAreaEnable = self.view.petAreaFloatUComponent.gameObject and self.view.petAreaFloatUComponent.gameObject.activeSelf

	if locationPanelEnable or chooseListEnable or sortFloatEnable or petAreaEnable then
		return false
	end

	return true
end

function MapCtrl:startMovingTargetTick()
	for k, v in pairs(self.tempMarkPointData) do
		if v.markType == Const.MAP_MARK_ALLY and v.markPosition and self.markCaches[k] then
			local recTrans = self.markCaches[k].button.gameObject:GetComponent("RectTransform")
			local x, y = pg.game.map:convertPos(v.markPosition[1], v.markPosition[3], self.sceneId, true)

			recTrans.anchoredPosition = Vector2(x, y)
		end
	end
end

function MapCtrl:_processOneBindMarkStatus(markId, entityId)
	local spawner = self.markCaches[markId]

	if not spawner then
		local markPointData = self:getMarkInfo(markId)

		if markPointData and self:isMarkInCurrentView(markPointData, markId) then
			self:addMarks(markPointData, markId)

			if self.activeNormalMarks then
				self.activeNormalMarks[markId] = true
			end

			spawner = self.markCaches[markId]
		end
	end

	if spawner then
		local x, y = pg.game.map:GetCurrentBindMapMarkPos(markId)

		if x then
			spawner.anchoredPositionX = x
			spawner.anchoredPositionY = y

			spawner.recTrans:SetAnchoredPositionEx(x, y)
		end
	end
end

function MapCtrl:processBindMarkStatus()
	pg.game.map:BindMapForeach(self._processOneBindMarkStatus, self)
end

function MapCtrl:onAllyChanged(info)
	if info.entryAdd then
		self:prepareMarkLoad(self:getMarkInfo(info.refEntityId), info.refEntityId, true)
	else
		self:clearPreviousTask(info.refEntityId)

		if self.pointsTasks[info.refEntityId] then
			if self.pointsTasks[info.refEntityId].taskId then
				self.view:cancelUIAsyncTask(self.pointsTasks[info.refEntityId].taskId)
			end

			if self.pointsTasks[info.refEntityId].taskObj then
				self.view:destroyInstance(self.pointsTasks[info.refEntityId].taskObj)
			end

			self.pointsTasks[info.refEntityId] = nil
		end

		if self.pendingMarkLoads then
			self.pendingMarkLoads[info.refEntityId] = nil
		end

		if self.activeNormalMarks then
			self.activeNormalMarks[info.refEntityId] = nil
		end
	end
end

function MapCtrl:onMoneyNumChange()
	local space = pg.space

	if space ~= nil and space.isGrabEgg and space:isGrabEgg() then
		return
	end

	local currencyList = self.model:getCurrencyDataList()

	self.view.listCurrency:SetList(currencyList)
end

function MapCtrl:onUseLimitMapChange()
	if not self.view.locationInfo.gameObject.activeSelf then
		return
	end

	local spawnerId = self.locationInfoPanelCurMarkId
	local spawnerTable = spawnerId and self:getMarkInfo(spawnerId)

	if not spawnerTable or spawnerTable.markConfigId ~= 10304 then
		return
	end

	local locationObjectReference = self.view.locationInfo:GetComponent("ObjectReference")

	if NotNil(locationObjectReference) then
		local scrollRect = locationObjectReference:GetRefValue("scrollRectUScrollRect")
		local detailObjectReference = scrollRect.content.transform:GetComponent("ObjectReference")

		self:renderBossChallengeInfo(detailObjectReference, spawnerId, spawnerTable.markConfigId)
	end
end

function MapCtrl:onPetAreaRewardChange()
	if self.mapPetAreaComponent then
		self.mapPetAreaComponent:refreshCollectionView()
	end

	if self.view.locationInfo.gameObject.activeSelf then
		local spawnerId = self.locationInfoPanelCurMarkId
		local spawnerTable = spawnerId and self:getMarkInfo(spawnerId)
		local markCache = spawnerId and self.markCaches and self.markCaches[spawnerId]

		if spawnerTable and markCache and spawnerTable.markConfigId == Const.MAP_MARK_LEYLINETREE_TRANSMIT and markCache.markStatus >= Const.MAP_MARK_STATUS_UNLOCKED and pg.game.leylineTree:checkLeylineTreeUnlockedBySmallAreaId(spawnerTable.largeAreaId) then
			local objectReference = self.view.locationInfo:GetComponent("ObjectReference")

			if not self.weatherTaskContainer then
				self.weatherTaskContainer = {}
			end

			MapUtils.renderLeylineClusterMapInfoPanel(objectReference, spawnerTable, self.weatherTaskContainer, self)
		end
	end

	for areaId, redDotUButton in pairs(self.petAreaRedDots) do
		self:refreshPetAreaRedDot(areaId, redDotUButton)
	end
end

function MapCtrl:_getTeaPartyMapHintDailyKey(eventId)
	return pg.me.uid .. ClientConst.PrefKey.ArkCafeGatheringMapTip
end

function MapCtrl:_checkTeaPartyMapHint()
	if pg.me == nil then
		return false, nil, nil
	end

	if pg.me.level and pg.me.level < Const.SocialPartyLevelLimit then
		return false, nil, nil
	end

	local isOpen, eventId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.TeaParty, pg.me)

	if isOpen ~= true or eventId == nil or ClientActivityUtils.isTeaPartyOpenNow(eventId) ~= true then
		return false, nil, nil
	end

	if ClientActivityUtils._isTeaPartyDailyRewardFull() == true then
		return false, nil, nil
	end

	local dailyKey = self:_getTeaPartyMapHintDailyKey(eventId)
	local notRead = pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, dailyKey, true)

	if notRead ~= true then
		return false, nil, nil
	end

	return true, eventId, dailyKey
end

function MapCtrl:_onTeaPartyMapHintClick(eventId, dailyKey)
	if pg.me == nil then
		return
	end

	if dailyKey ~= nil then
		pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, dailyKey, false)
	end

	self._teaPartyMapHintActive = false

	self:_hideTeaPartyMapHint()

	if self.sceneId ~= nil and pg.game.map:convertSceneId(self.sceneId) ~= pg.game.map:convertSceneId(SocialConst.ARK_SCENE_ID) then
		self:onChangeMapBtnClick()
	end

	local sceneMarkPointData = SceneUtils and SceneUtils.getSceneMarkPointData(SocialConst.ARK_SCENE_ID)
	local point = sceneMarkPointData and sceneMarkPointData[TEA_PARTY_MAP_POINT_ID]

	if point == nil then
		LuaUIUtils.locateMark(SocialConst.ARK_SCENE_ID, TEA_PARTY_MAP_POINT_ID)

		return
	end

	local status = pg.me:getSpaceOwnerMapMarkStatus(SocialConst.ARK_SCENE_ID, point.markType, TEA_PARTY_MAP_POINT_ID)

	if status < Const.MAP_MARK_STATUS_LOCKED then
		LuaUIUtils.locateMark(SocialConst.ARK_SCENE_ID, TEA_PARTY_MAP_POINT_ID)

		return
	end

	pg.game.map:openMapAndLocateMark(SocialConst.ARK_SCENE_ID, point.markType, TEA_PARTY_MAP_POINT_ID, nil, 1, function()
		local mapCtrl = pg.global.ui.map

		if mapCtrl == nil or mapCtrl.view == nil or mapCtrl.view.locationInfo == nil then
			return
		end

		if mapCtrl.view.locationInfo.gameObject.activeSelf == true then
			return
		end

		mapCtrl:selectMark(nil)
		mapCtrl:selectMark(string.format("mark_%s_%s", point.markType, TEA_PARTY_MAP_POINT_ID), true)
	end)
end

function MapCtrl:_hideTeaPartyMapHint()
	local hintObjList = self:_getTeaPartyMapHintObjList()

	for _, hintObj in ipairs(hintObjList) do
		self:_unbindTeaPartyMapHintClick(hintObj)
		self:_setTeaPartyMapHintVisible(hintObj, false)
	end

	self._teaPartyMapHintShowingDailyKey = nil
end

function MapCtrl:_addTeaPartyMapHintObj(hintObjList, hintObj)
	if hintObjList == nil or hintObj == nil or IsNil(hintObj) then
		return
	end

	for _, existObj in ipairs(hintObjList) do
		if existObj == hintObj then
			return
		end
	end

	hintObjList[#hintObjList + 1] = hintObj
end

function MapCtrl:_getTeaPartyMapHintObjList()
	if self._teaPartyMapHintObjList ~= nil then
		local validList = {}

		for _, hintObj in ipairs(self._teaPartyMapHintObjList) do
			self:_addTeaPartyMapHintObj(validList, hintObj)
		end

		if #validList ~= 0 then
			self._teaPartyMapHintObjList = validList

			return validList
		end
	end

	local hintObjList = {}

	if self.view ~= nil then
		if self.view.teaPartyGlobalTips ~= nil then
			self:_addTeaPartyMapHintObj(hintObjList, self.view.teaPartyGlobalTips.gameObject)
		end

		if self.view.teaPartyArkTips ~= nil then
			self:_addTeaPartyMapHintObj(hintObjList, self.view.teaPartyArkTips.gameObject)
		end
	end

	self._teaPartyMapHintObjList = hintObjList

	return hintObjList
end

function MapCtrl:_getTeaPartyMapHintRef(hintObj, refName)
	if hintObj == nil or IsNil(hintObj) then
		return nil
	end

	local objRef = hintObj:GetComponent("ObjectReference")

	if objRef == nil or IsNil(objRef) then
		return nil
	end

	return objRef:GetRefValue(refName)
end

function MapCtrl:_refreshTeaPartyMapHintText(hintObj)
	local textComponent = self:_getTeaPartyMapHintRef(hintObj, "textUSDFText")

	if textComponent == nil then
		return
	end

	local text = pg.getGameString("SOCIAL_PARTY_MAP_GUIDE")

	ClientTextUtils.setText(textComponent, text)
end

function MapCtrl:_bindTeaPartyMapHintClick(hintObj, eventId, dailyKey)
	local btn = self:_getTeaPartyMapHintRef(hintObj, "btnGoUButton")

	if btn == nil then
		return
	end

	function btn.luaClick()
		self:_onTeaPartyMapHintClick(eventId, dailyKey)
	end
end

function MapCtrl:_unbindTeaPartyMapHintClick(hintObj)
	local btn = self:_getTeaPartyMapHintRef(hintObj, "btnGoUButton")

	if btn == nil then
		return
	end

	btn.luaClick = nil
end

function MapCtrl:_setTeaPartyMapHintVisible(hintObj, visible)
	if hintObj == nil or IsNil(hintObj) then
		return
	end

	hintObj:SetActiveEx(visible == true)
end

function MapCtrl:tryShowTeaPartyMapHint()
	if self.view == nil then
		return
	end

	local showHint, eventId, dailyKey = self:_checkTeaPartyMapHint()

	self._teaPartyMapHintActive = showHint == true
	self._teaPartyMapHintEventId = eventId
	self._teaPartyMapHintDailyKey = dailyKey

	if showHint ~= true then
		self:_hideTeaPartyMapHint()

		return
	end

	local hintObjList = self:_getTeaPartyMapHintObjList()
	local hasShow = false

	for _, hintObj in ipairs(hintObjList) do
		self:_setTeaPartyMapHintVisible(hintObj, true)
		self:_refreshTeaPartyMapHintText(hintObj)
		self:_bindTeaPartyMapHintClick(hintObj, eventId, dailyKey)

		hasShow = true
	end

	if hasShow == true then
		self._teaPartyMapHintShowingDailyKey = dailyKey
	else
		self._teaPartyMapHintShowingDailyKey = nil
	end
end

function MapCtrl:onChangeMapBtnClick()
	self.view.vXMapAnimation.gameObject:SetActiveEx(true)
	self.view.blockRayboxUWidget.gameObject:SetActiveEx(true)

	local aniName, targetMap

	if self.sceneId == self.model.MAPS.ARK then
		aniName = "VX_Pb_Map_GatherInfo_Planet_In"

		local currentSceneId = self:_getCurrentSpaceSceneId()

		if currentSceneId ~= nil and pg.game.map:convertSceneId(currentSceneId) == self.model.MAPS.IDYLL_WATER then
			targetMap = self.model.MAPS.IDYLL_WATER
		else
			targetMap = self.model.MAPS.IDYLL
		end
	else
		aniName = "VX_Pb_Map_GatherInfo_Ark_In"
		targetMap = self.model.MAPS.ARK
	end

	UIUtils.PlayAnimation(self.view.globalAnimation, aniName, function()
		self._switchingMap = true

		self:changeMap(targetMap)

		self._switchingMap = false
	end)
end

function MapCtrl:initPetAreaProgressInfo()
	self.view.gatherInfoUComponent:SetActive(false)

	local showGlobalBtn = true
	local curSmallAreaId = pg.game.map.curBlockId

	if self:isIdyllWorld() and not self:isDifferentScene() then
		-- block empty
	else
		curSmallAreaId = 0
	end

	if not curSmallAreaId then
		showGlobalBtn = false
	end

	local areaProgressStr = ""
	local smallAreaCfg = MapBlockConfigData[curSmallAreaId]

	if not smallAreaCfg then
		showGlobalBtn = false
	elseif self.mapPetAreaComponent then
		areaProgressStr = self.mapPetAreaComponent:getAreaPetProgressStr(smallAreaCfg.mapAreaId)
	end

	local areaName = pg.game.map:getSceneName(self.sceneId)

	if smallAreaCfg then
		local areaCfg = MapAreaConfigData[smallAreaCfg.mapAreaId]

		if not areaCfg then
			showGlobalBtn = false
		else
			areaName = pg.getLocalizationText(areaCfg.areaName)
		end

		if not pg.game.map:checkBlockLeylineTreeUnlocked(smallAreaCfg.mapAreaId) then
			showGlobalBtn = false
		end
	else
		showGlobalBtn = false
	end

	self.view.gatherInfoUComponent:SetActive(true)

	local objectReference = self.view.gatherInfoUComponent:GetComponent("ObjectReference")
	local iDyllUButton = objectReference:GetRefValue("iDyllUButton")
	local aRKUButton = objectReference:GetRefValue("aRKUButton")
	local areaNameUBaseText = objectReference:GetRefValue("areaNameUBaseText")
	local areaProgressUBaseText = objectReference:GetRefValue("areaProgressUBaseText")
	local areaName2UBaseText = objectReference:GetRefValue("areaName2UBaseText")
	local areaProgress2UBaseText = objectReference:GetRefValue("areaProgress2UBaseText")
	local btnCopyUButton = objectReference:GetRefValue("btnCopyUButton")
	local popUButton = objectReference:GetRefValue("popUButton")
	local detailsUWidget = objectReference:GetRefValue("detailsUWidget")

	if showGlobalBtn then
		self.view.btnDistributionUButton.gameObject:SetActiveEx(true)
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_PET_AREA_LIST, self.view.btnDistributionUButton, function()
			return pg.game.map:redDot_GetMapAreaState()
		end)
	else
		self.view.btnDistributionUButton.gameObject:SetActiveEx(false)
	end

	function self.view.btnDistributionUButton.luaClick()
		local rewardedAreas = pg.game.map:getPetAreaRewardsState()
		local areaCount = lume.getMapLen(rewardedAreas)

		if areaCount > 0 then
			local areaInfo = rewardedAreas[1]
			local areaId = areaInfo and areaInfo.smallAreaId

			if self.mapPetAreaComponent then
				self.focusSmallArea = areaId

				self.mapPetAreaComponent:setPetAreaProgressTipInfo(nil, false, self.focusSmallArea)
			end
		end

		self:scaleMap(0)
		self:centralizeMark("BtnMine")
	end

	function iDyllUButton.luaClick()
		self:onChangeMapBtnClick()
	end

	aRKUButton.luaClick = iDyllUButton.luaClick

	function btnCopyUButton.luaClick()
		if self.coordinateShareX and self.coordinateShareZ then
			UIUtils.ClipboardWriter(string.format("MAPCOORDINATE_%s_%s", self.coordinateShareX, self.coordinateShareZ))
			pg.global.showBubbleMessageRaw(pg.getGameString("MAP_COOR_PASTE_SUCCESS"))
		end
	end

	function popUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_MAP_LOCATION, {
			finishedCb = function(x, z)
				local btnName = self.model:findPosMark(self.markCaches, x, z)

				if btnName then
					self:selectMark(btnName, true)
				else
					local offset

					if MapOverlapScene[self.sceneId] and SceneData[self.sceneId] then
						local markWholemapOffset = SceneData[self.sceneId].wholemapOffset

						if markWholemapOffset and #markWholemapOffset == 3 then
							offset = markWholemapOffset
						end
					end

					if offset then
						x = x - offset[1]
						z = z - offset[3]
					end

					self:onPinBtnClick(nil, x, z)
				end
			end
		})
	end

	if self._switchingMap then
		local function delayFunc()
			detailsUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom4, function()
				self.view.gatherInfoUComponent:TryChangePage("State", self.sceneId == self.model.MAPS.ARK and 1 or 0)
				ClientTextUtils.setText(areaNameUBaseText, areaName)
				ClientTextUtils.setText(areaProgressUBaseText, areaProgressStr)
				ClientTextUtils.setText(areaName2UBaseText, areaName)
				ClientTextUtils.setText(areaProgress2UBaseText, areaProgressStr)
				self:refreshCoordinate()
				self.mapBlockListComponent:renderPopup()
				detailsUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
			end)
		end

		self.mapSwitchDelayCallbacks[#self.mapSwitchDelayCallbacks + 1] = delayFunc
	else
		self.view.gatherInfoUComponent:TryChangePage("State", self.sceneId == self.model.MAPS.ARK and 1 or 0)
		ClientTextUtils.setText(areaNameUBaseText, areaName)
		ClientTextUtils.setText(areaProgressUBaseText, areaProgressStr)
		ClientTextUtils.setText(areaName2UBaseText, areaName)
		ClientTextUtils.setText(areaProgress2UBaseText, areaProgressStr)
		self:refreshCoordinate()
		self.mapBlockListComponent:renderPopup()
	end
end

function MapCtrl:refreshCoordinate(forceX, forceZ, markRealSceneId)
	local objectReference = self.view.gatherInfoUComponent:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local btnCopyUButton = objectReference:GetRefValue("btnCopyUButton")
	local objectReference1 = self.view.gatherInfoUComponent:GetComponent("ObjectReference")
	local areaNameUBaseText = objectReference1:GetRefValue("areaNameUBaseText")
	local areaProgressUBaseText = objectReference1:GetRefValue("areaProgressUBaseText")
	local areaName2UBaseText = objectReference1:GetRefValue("areaName2UBaseText")
	local areaProgress2UBaseText = objectReference1:GetRefValue("areaProgress2UBaseText")

	local function formatNumber(num)
		if num < 0 then
			num = math.ceil(num - 0.5)

			return string.format("-%04d", math.abs(num))
		else
			num = math.floor(num + 0.5)

			return string.format("%04d", num)
		end
	end

	local x, z, offset

	if MapOverlapScene[self.sceneId] and SceneData[self.sceneId] then
		local wholemapOffset = SceneData[self.sceneId].wholemapOffset

		if wholemapOffset and #wholemapOffset == 3 then
			offset = wholemapOffset
		end
	end

	if forceX and forceZ then
		offset = nil

		if markRealSceneId and MapOverlapScene[markRealSceneId] and SceneData[markRealSceneId] then
			local markWholemapOffset = SceneData[markRealSceneId].wholemapOffset

			if markWholemapOffset and #markWholemapOffset == 3 then
				offset = markWholemapOffset
			end
		end

		if offset then
			forceX = forceX + offset[1]
			forceZ = forceZ + offset[3]
		end

		x = formatNumber(forceX)
		z = formatNumber(forceZ)

		ClientTextUtils.setText(textUSDFText, string.format("<u>%s</u>, <u>%s</u>", x, z))
		btnCopyUButton.gameObject:SetActiveEx(true)
	elseif self:isDifferentScene() then
		ClientTextUtils.setText(textUSDFText, string.format("<u>----</u>, <u>----</u>"))
		btnCopyUButton.gameObject:SetActiveEx(false)

		local areaName = pg.game.map:getSceneName(self.sceneId)

		ClientTextUtils.setText(areaNameUBaseText, areaName)
		ClientTextUtils.setText(areaName2UBaseText, areaName)
		ClientTextUtils.setText(areaProgressUBaseText, "")
		ClientTextUtils.setText(areaProgress2UBaseText, "")
	else
		local pos = pg.me:getPosition()

		if offset then
			x = formatNumber(pos.x + offset[1])
			z = formatNumber(pos.z + offset[3])
		else
			x = formatNumber(pos.x)
			z = formatNumber(pos.z)
		end

		ClientTextUtils.setText(textUSDFText, string.format("<u>%s</u>, <u>%s</u>", x, z))
		btnCopyUButton.gameObject:SetActiveEx(true)
	end

	self.coordinateShareX = x
	self.coordinateShareZ = z

	if #self.view.mapLevelBreakdown == 4 and self.curStage == #self.view.scaleBasicTable then
		self.recordPreCoordinateState = {
			btnCopyUButtonActive = btnCopyUButton.gameObject.activeSelf,
			textUSDFTextContent = textUSDFText.text
		}

		local pos = pg.me:getPosition()

		if offset then
			x = formatNumber(pos.x + offset[1])
			z = formatNumber(pos.z + offset[3])
		else
			x = formatNumber(pos.x)
			z = formatNumber(pos.z)
		end

		ClientTextUtils.setText(textUSDFText, string.format("<u>%s</u>, <u>%s</u>", x, z))
		btnCopyUButton.gameObject:SetActiveEx(true)
	elseif self.recordPreCoordinateState then
		btnCopyUButton.gameObject:SetActiveEx(self.recordPreCoordinateState.btnCopyUButtonActive)
		ClientTextUtils.setText(textUSDFText, self.recordPreCoordinateState.textUSDFTextContent)

		self.recordPreCoordinateState = nil
	end

	local inWhichBlock = pg.game.map:inWhichBlock(self.sceneId, false, {
		x = self.coordinateShareX,
		z = self.coordinateShareZ
	})
	local smallAreaCfg = MapBlockConfigData[inWhichBlock]

	if not smallAreaCfg then
		local areaName = pg.game.map:getSceneName(self.sceneId)

		ClientTextUtils.setText(areaNameUBaseText, areaName)
		ClientTextUtils.setText(areaName2UBaseText, areaName)
		ClientTextUtils.setText(areaProgressUBaseText, "")
		ClientTextUtils.setText(areaProgress2UBaseText, "")

		return
	end

	local areaCfg = MapAreaConfigData[smallAreaCfg.mapAreaId]
	local areaName = pg.getLocalizationText(areaCfg.areaName)
	local progress = self.mapPetAreaComponent ~= nil and self.mapPetAreaComponent:getAreaPetProgressStr(smallAreaCfg.mapAreaId) or "0%"

	ClientTextUtils.setText(areaNameUBaseText, areaName)
	ClientTextUtils.setText(areaName2UBaseText, areaName)
	ClientTextUtils.setText(areaProgressUBaseText, progress)
	ClientTextUtils.setText(areaProgress2UBaseText, progress)
end

function MapCtrl:renderMultiIconSelectBox(enable, stackIcons)
	if not enable then
		if self.multiSelectBoxTaskId then
			self.view:cancelUIAsyncTask(self.multiSelectBoxTaskId)

			self.multiSelectBoxTaskId = nil
		end

		if self.multiSelectBoxTaskObj then
			self.view:destroyInstance(self.multiSelectBoxTaskObj)

			self.multiSelectBoxTaskObj = nil
		end

		self.desiredSize = nil
	else
		self:renderMultiIconSelectBox(false)

		self.multiSelectBoxTaskId = self.view:addPrefabWithPathAsync(self.view.markerListTransformLayer100, AddressDataConst.MAP_ICON_MULTI_CHOOSE_FRAME, function(objInfo)
			self.multiSelectBoxTaskObj = objInfo.gameObject

			objInfo.gameObject.transform:SetSiblingIndex(-1)

			local objectReference = objInfo.gameObject:GetComponent("ObjectReference")
			local size = objectReference:GetRefValue("size")

			objInfo.gameObject.transform.localScale = Vector3(1 / self.currentZoom, 1 / self.currentZoom, 1)

			local elements = {}

			for _, v in pairs(stackIcons) do
				elements[#elements + 1] = v.button.transform
			end

			UIUtils.CalculateSelectionBox(elements, objInfo.gameObject.transform, size.transform)

			for _, v in pairs(stackIcons) do
				if self.markCaches[v.spawnerId] and self.markCaches[v.spawnerId].selectedTaskId then
					self.view:cancelUIAsyncTask(self.markCaches[v.spawnerId].selectedTaskId)
				end

				if self.markCaches[v.spawnerId] and self.markCaches[v.spawnerId].selectedObj and self.view:checkInstanceExists(self.markCaches[v.spawnerId].selectedObj) then
					self.view:destroyInstance(self.markCaches[v.spawnerId].selectedObj)
				end
			end
		end, false, true, 0)
	end
end

function MapCtrl:canCelScrollDisabled()
	self.view.mapScroll.zoomTool.muteZoom = false

	self.view.blockRayboxUWidget.gameObject:SetActiveEx(false)
	self.view.mapScroll:SetScrollDisabled(false)

	if self.centralizingMarkId then
		self.centralizingMarkId = nil
	end
end

function MapCtrl:drawNavEffLine(info, dependencyBtn)
	if self.mapNavLineComponent then
		self.mapNavLineComponent:drawNavEffLine(info, dependencyBtn)
	end
end

function MapCtrl:onGrabEggAreaAdd(info)
	if self.grabEggAreaComponent then
		self.grabEggAreaComponent:instantiateAppearArea(info.areaData.id, info.areaData)
	end
end

function MapCtrl:onGrabEggAreaRemove(info)
	if self.grabEggAreaComponent then
		self.grabEggAreaComponent:destroyAppearArea(info.id)
	end
end

function MapCtrl:grabEggSettlementOpen(sceneId, path, cb)
	self.curStage = #self.view.scaleBasicTable
	self.currentZoom = self.view.scales[self.curStage] or 1

	self:scaleMap((#self.view.scales - self.curStage) * self.view.stepSize)

	local mapX, mapY = pg.game.map:convertPos(path[#path][1], path[#path][3], sceneId, true)

	self:centralizePos(mapX, mapY, true)
	self.view.mapScroll:SetScrollDisabled(true)

	self.view.mapScroll.zoomTool.disableZoomWhileDragging = true

	if self.mapNavLineComponent then
		self.mapNavLineComponent:grabEggSettlementOpen(sceneId, path, cb)
	end
end

function MapCtrl:grabEggSettlementClose()
	if self.mapNavLineComponent then
		self.mapNavLineComponent:grabEggSettlementClose()
	end

	self:closePanel()
end

function MapCtrl:checkHideNormalMapInfo()
	local hide = SceneData[self.sceneId].hideNormalMapInfo
	local showGather = true
	local scale = Vector3.one
	local opacity = 1

	if hide == 1 then
		showGather = false
		scale = Vector3.zero
		opacity = 0
	elseif hide == 2 then
		showGather = false
	end

	self.view.gatherInfoUComponent.gameObject:SetActiveEx(showGather)

	self.view.tabBarTransform.localScale = scale
	self.view.sortFilterUComponent.renderOpacity = opacity
end

function MapCtrl:onMapMarkUnbindEntity(info)
	if not info or not info.markId then
		return
	end

	if self.markCaches and self.markCaches[info.markId] then
		local spawner = self.markCaches[info.markId]

		if spawner then
			spawner.recTrans:SetAnchoredPositionEx(spawner.realAnchoredPositionX, spawner.realAnchoredPositionY)
		end
	end
end

function MapCtrl:checkFogBlocked(mapX, mapY)
	if not self.mapFogBlock then
		return false
	end

	if not self.mapFogGenerator then
		return false
	end

	local localX, localY = self:revertMapPosToLocalPoint(mapX, mapY)
	local inFog = self.mapFogGenerator:CheckPosInFog(localX, localY)

	if inFog then
		pg.global.showBubbleMessageRaw(pg.getGameString("MAP_FOG_BLOCKED_TIP"))
	end

	return inFog
end

function MapCtrl:getIsHomeCampMark(spawnerId)
	if not spawnerId then
		return false
	end

	local markInfo = self:getMarkInfo(spawnerId)

	if not markInfo then
		return false
	end

	return markInfo and markInfo.markType == Const.MAP_MARK_HOME_CAMP
end

function MapCtrl:openDistributionMode(showTab, resetShowTab)
	if showTab or resetShowTab then
		self.model:refreshPetShowTab(showTab)
	end

	if self.petDistributionComponent then
		self.petDistributionComponent:openDistributionMode()
	end
end

function MapCtrl:addActivatedVX(spawnerId, isTree, show)
	if not show and self.activatedVX and self.view:checkInstanceExists(self.activatedVX.gameObject) then
		self.view:destroyInstance(self.activatedVX.gameObject)

		return
	end

	local markCache = self.markCaches and self.markCaches[spawnerId]

	if not markCache then
		return
	end

	self.activatedVX = self.view:addPrefabWithPathSync(markCache.upperDynamicLoadTransform, isTree and AddressDataConst.LEYLINETREE_ACTIVATE_VX or AddressDataConst.LEYLINETREE_FLOWER_ACTIVATE_VX)

	self.activatedVX.gameObject.transform:SetParent(self.view.mapScrollContent)
	self.activatedVX.gameObject.transform:SetSiblingIndex(-1)

	local ani = self.activatedVX.gameObject.transform:GetComponent("Animation")
	local clip

	clip = isTree and "VX_Node_Map_LeylinesTree_Activate" or "VX_Node_Map_LeylinesFlower_Activate"

	UIUtils.PlayAnimation(ani, clip, function()
		self:addActivatedVX(spawnerId, isTree, false)
	end)
end

return MapCtrl
