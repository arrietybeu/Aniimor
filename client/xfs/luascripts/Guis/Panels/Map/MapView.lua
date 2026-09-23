-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\MapView.lua

local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SceneData = require("Data.scene_data")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local MapView = Class.LightClass("MapView", UIView)
local GameObject = CS.UnityEngine.GameObject

function MapView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.closeBtn = self.objectReference:GetRefValue("closeBtn")
	self.mapScroll = self.objectReference:GetRefValue("mapScroll")
	self.locationInfo = self.objectReference:GetRefValue("locationInfo")
	self.mineMark = self.objectReference:GetRefValue("mineMark")
	self.mineMarkTrans = self.objectReference:GetRefValue("mineMarkTrans")
	self.mineMarkDefaultParent = self.mineMark.transform.parent
	self.chooseList = self.objectReference:GetRefValue("chooseList")
	self.fakeCustomMarkUButton = self.objectReference:GetRefValue("fakeCustomMarkUButton")
	self.fakeCustomMarkDefaultParent = self.fakeCustomMarkUButton.transform.parent
	self.root = self.objectReference:GetRefValue("root")
	self.btnAddUButton = self.objectReference:GetRefValue("btnAddUButton")
	self.btnReduceUButton = self.objectReference:GetRefValue("btnReduceUButton")
	self.deleteUWidget = self.objectReference:GetRefValue("deleteUWidget")
	self.multiDeletePanelCloseBtn = self.objectReference:GetRefValue("multiDeletePanelCloseBtn")
	self.multiDeletePanelCount = self.objectReference:GetRefValue("multiDeletePanelCount")
	self.multiDeletePanelDeleteBtn = self.objectReference:GetRefValue("multiDeletePanelDeleteBtn")
	self.sliderFakeUSlider = self.objectReference:GetRefValue("sliderFakeUSlider")
	self.btnFilterUButton = self.objectReference:GetRefValue("btnFilterUButton")
	self.bubbleGroupTransform = self.objectReference:GetRefValue("bubbleGroupTransform")
	self.safeBoxMobileUWidget = self.objectReference:GetRefValue("safeBoxMobileUWidget")
	self.bubbleGroupUComponent = self.objectReference:GetRefValue("bubbleGroupUComponent")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
	self.petAppearListUList = self.objectReference:GetRefValue("petAppearListUList")
	self.listMapLayerUList = self.objectReference:GetRefValue("listMapLayerUList")
	self.sortFloatUComponent = self.objectReference:GetRefValue("sortFloatUComponent")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.contentUWidget = self.objectReference:GetRefValue("contentUWidget")
	self.gatherInfoUComponent = self.objectReference:GetRefValue("gatherInfoUComponent")
	self.petAreaFloatUComponent = self.objectReference:GetRefValue("petAreaFloatUComponent")
	self.sortFilterUComponent = self.objectReference:GetRefValue("sortFilterUComponent")
	self.listCurrency = self.objectReference:GetRefValue("listCurrency")
	self.btnNourish = self.objectReference:GetRefValue("btnNourish")
	self.blockRayboxUWidget = self.objectReference:GetRefValue("blockRayboxUWidget")
	self.tabBarTransform = self.objectReference:GetRefValue("tabBarTransform")
	self.listTransLocUList = self.objectReference:GetRefValue("listTransLocUList")
	self.listTransLocUWidget = self.objectReference:GetRefValue("listTransLocUWidget")
	self.vXGlobalIconUWidget = self.objectReference:GetRefValue("vXGlobalIconUWidget")
	self.btnDistributionUButton = self.objectReference:GetRefValue("btnDistributionUButton")
	self.btnAreaSortUSelector = self.objectReference:GetRefValue("btnAreaSortUSelector")
	self.rootAni = self.objectReference:GetRefValue("rootAni")
	self.globalAnimation = self.objectReference:GetRefValue("globalAnimation")
	self.vXMapAnimation = self.objectReference:GetRefValue("vXMapAnimation")
	self.mapScrollRectRectTransform = self.objectReference:GetRefValue("mapScrollRectRectTransform")
	self.consoleBarTransform = self.objectReference:GetRefValue("consoleBarTransform")
	self.layoutTransUWidget = self.objectReference:GetRefValue("layoutTransUWidget")
	self.virtualMouseField = self.objectReference:GetRefValue("virtualMouseFieldUVirtualMouseField")
	self.petDistributionUContainer = self.objectReference:GetRefValue("petDistributionUContainer")

	local gatherInfoObjRef = self.gatherInfoUComponent:GetComponent("ObjectReference")

	self.teaPartyGlobalTips = gatherInfoObjRef:GetRefValue("globalTipsRectTransform")
	self.teaPartyArkTips = gatherInfoObjRef:GetRefValue("arkTipsRectTransform")
	self.petDistributionUContainer.forceSyncLoad = true

	self.petDistributionUContainer.gameObject:SetActiveEx(true)

	self.mapScrollView = self.mapScroll.transform:Find("View"):GetComponent("RectTransform")

	if pg.me ~= nil and pg.me.space ~= nil then
		self:insertSceneId(pg.game.map:convertSceneId(pg.me.space.sceneId))
	end

	self:refreshNode()
end

function MapView:insertSceneId(sceneId)
	local sceneCfg = SceneData[sceneId]

	if sceneCfg == nil then
		return
	end

	local mapImage = sceneCfg.mapImage

	if mapImage == nil then
		return
	end

	self:unloadMapGO()

	self.mapResId = string.format("$XGUI_Panel/MapRes/UI_Node_Map_%s.prefab", mapImage)

	local go = pg.global.ui.uiMgr:LoadAssetSyncByID(self.mapResId)
	local sceneData = sceneCfg

	self.mapUISize = sceneData.mapUISize or {
		0,
		0
	}
	go:GetComponent("RectTransform").sizeDelta = Vector2(self.mapUISize[1], self.mapUISize[2])
	self.scaleBasicTable = sceneCfg.mapImageScale
	self.scaleOriTable = sceneCfg.mapImageScale
	self.mapLevelBreakdown = sceneCfg.mapLevelBreakdown

	local leylineTreeUnlocked = pg.game.map:checkAtLeastOneLeylineTreeUnlocked()

	if self.mapLevelBreakdown and #self.mapLevelBreakdown == 4 then
		local activeScale4 = leylineTreeUnlocked

		if sceneData.hideNormalMapInfo then
			activeScale4 = true
		end

		if not activeScale4 then
			local newScaleTable = {}

			for i = 1, #SceneData[sceneId].mapImageScale - 1 do
				newScaleTable[i] = SceneData[sceneId].mapImageScale[i]
			end

			self.scaleOriTable = newScaleTable

			local newMapLevelBreakdown = {}

			for i = 1, #SceneData[sceneId].mapLevelBreakdown - 1 do
				newMapLevelBreakdown[i] = SceneData[sceneId].mapLevelBreakdown[i]
			end

			self.mapLevelBreakdown = newMapLevelBreakdown
		end
	elseif self.mapLevelBreakdown and #self.mapLevelBreakdown < 4 then
		self.scaleBasicTable = Utils.deepCopyTable(self.scaleBasicTable)

		table.insert(self.scaleBasicTable, 0)
	end

	self.scales = LuaUIUtils.reverseTable(self.scaleOriTable)

	self.mapScroll.zoomTool:SetZoomSizeAndTargetIndex(self.scales, #self.scales - 1)

	self.stepSize = 1 / (#self.scales - 1)

	local uImage = go:GetComponent("UImage")

	self.mapScroll:ReInit(uImage)
	self.mapScroll.scrollTool:SetClamped()
	self.mapScroll.scrollTool:SetScrollable(true)
	self.mapScroll.scrollTool:SetScrollDisabled(false)
	self.mapScroll.scrollTool:SetScrollTypeBoth()
	self.mapScroll.scrollTool:SetCenterWhileSmall(false)
	self.mapScroll.scrollTool:SetInWayEx(true, true)

	self.mapGo = go
	self.mapScrollContent = self.mapScroll.content.gameObject:GetComponent("RectTransform")

	local objectReference = self.mapScrollContent:GetComponent("ObjectReference")

	self.markerListTransform = objectReference:GetRefValue("markerListTransform")

	local mapAreaTransformValue = objectReference:GetRefValue("mapAreaTransform")

	self.petDistributionUImage = objectReference:GetRefValue("petDistributionUImage")

	if mapAreaTransformValue then
		self.mapAreaTransform = mapAreaTransformValue:GetComponent("Transform")
	else
		self.mapAreaTransform = nil
	end

	local fogMapFogGeneratorTrans = objectReference:GetRefValue("fogMapFogGenerator")

	if fogMapFogGeneratorTrans then
		self.fogMapFogGenerator = fogMapFogGeneratorTrans:GetComponent("MapFogGenerator")
	else
		self.fogMapFogGenerator = nil
	end

	self.chunkingLoad = self.mapScrollContent:GetComponent("ChunkingLoad")
	self.mapScrollContentRect = self.mapScrollContent:GetComponent("RectTransform")

	local function inner(i)
		local name = string.format("markerListTransformLayer%s", i)

		self[name] = GameObject(string.format("Layer%s", i))

		local rectTrans = self[name]:AddComponent(typeof(CS.UnityEngine.RectTransform))

		rectTrans.parent = self.markerListTransform
		rectTrans.localPosition = Vector3.constZero
		rectTrans.localScale = Vector3.constOne
		rectTrans.anchorMin = Vector2.zero
		rectTrans.anchorMax = Vector2.one
		rectTrans.sizeDelta = Vector2.zero
	end

	for i = 0, 8 do
		inner(i)
	end

	inner(99)
	inner(100)

	self.mapInputEventHandler = self.mapScrollContent:GetComponent("UIMapInputEventHandler")
	self.listTransLocUWidget.renderOpacity = 1

	self.vXGlobalIconUWidget.gameObject:SetActiveEx(true)
end

function MapView:unloadMapGO()
	if NotNil(self.mapGo) then
		pg.global.ui.uiMgr:UnloadAsset(self.mapResId)

		self.mapGo = nil
		self.mapResId = nil
	end
end

function MapView:unloadMapFogBitMasks()
	if not self.fogMapFogGenerator then
		return
	end

	self.fogMapFogGenerator:UnloadAllMapFogBitMasks()
end

function MapView:destroy()
	self:unloadMapGO()
	self:unloadMapFogBitMasks()
	UIView.destroy(self)
end

function MapView:displayUINode(nodeName, display)
	local node = self.mapScrollContent.transform:Find(nodeName)

	if not node then
		return
	end

	if IsNil(node.gameObject) then
		return
	end

	node.gameObject:SetActiveEx(display)
end

function MapView:refreshNode()
	for nodeName, display in pairs(pg.game.map.mapNodeDisplayStatus) do
		self:displayUINode(nodeName, display)
	end
end

return MapView
