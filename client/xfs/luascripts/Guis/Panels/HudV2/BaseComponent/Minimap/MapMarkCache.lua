-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\Minimap\\MapMarkCache.lua

local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local NpcFuncData = require("Data.npc_func_data")
local MapLevelConfigLoadData = require("Data.map_level_config_load_data")
local AddressDataConst = require("Const.AddressDataConst")
local PuppetData = require("Data.puppet_data")
local Class = require("Core.Framework.Class")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local QuestConst = require("Common.Const.QuestConst")
local SysConfigData = require("Data.sys_config_data")
local MapUtils = require("Guis.Utils.MapUtils")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggMapMarkUtils = require("GameApp.GrabEgg.GrabEggMapMarkUtils")
local MapMarkPrefabPoolManager = require("Guis.Utils.MapMarkPrefabPoolManager")
local MAP_MARK_QUEST = Const.MAP_MARK_QUEST
local NotNil = NotNil
local MapMarkCache = Class.LightClass("MapMarkCache")

function MapMarkCache:ctor(miniMap, view, root)
	self.miniMap = miniMap
	self.view = view
	self.root = root
	self.renderGeneration = 0
	self.commonIconRequest = nil
	self.commonIconLease = nil
	self.commonIconUrl = nil
	self.resPrefabPath = nil
end

function MapMarkCache:canRenderCommonIcon(spawnerTable)
	if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		return false
	end

	local resourceByScene = MapMarkResourceData[spawnerTable.markConfigId]
	local sceneId = pg.game.map.mainSceneId

	if resourceByScene and (resourceByScene[sceneId] or resourceByScene[0]) then
		return true
	end

	return spawnerTable.markType == MAP_MARK_QUEST or spawnerTable.markType == Const.MAP_MARK_CUSTOM or spawnerTable.markType == Const.MAP_MARK_SHARE or spawnerTable.markType == Const.MAP_MARK_ALLY or spawnerTable.markType == Const.MAP_MARK_GRAB_EGG or spawnerTable.markType == Const.MAP_MARK_FAST_TARGET or spawnerTable.markType == Const.MAP_MARK_GOLD_MONSTER
end

function MapMarkCache:getCommonIconData(spawnerTable)
	if not self:canRenderCommonIcon(spawnerTable) then
		return false, nil
	end

	if spawnerTable.type == Const.MAP_CONST.TYPE.NORMAL then
		if spawnerTable.markType == Const.MAP_MARK_CLUE and (self.markStatus == Const.MAP_MARK_STATUS_HIDE or self.markStatus == Const.MAP_MARK_STATUS_LOCKED) then
			return false, nil
		end

		if spawnerTable.markConfigId == 1003 then
			return false, nil
		end

		return true, self:GetImagePathNormal(spawnerTable)
	end

	if spawnerTable.type == Const.MAP_CONST.TYPE.NPC then
		return true, self:GetImagePathNpc(spawnerTable)
	end

	if spawnerTable.type == Const.MAP_CONST.TYPE.DUEL then
		local duelStatus = MapUtils.getNpcDuelStatus(self.root.markId)

		if duelStatus <= 0 then
			return true, MapUtils.getMarkDefaultUnKnownResIcon(spawnerTable.markConfigId)
		end

		return true, MapUtils.getMarkDefaultResIcon(spawnerTable.markConfigId)
	end

	if spawnerTable.type == Const.MAP_CONST.TYPE.MARK_SHARE and pg.game.markShare:shouldShowOwnMediaMarker() then
		return true, AddressDataConst.UI_MARK_IMG_MARK_SHARE
	end

	return false, nil
end

function MapMarkCache:bindCommonIcon(iconUrl)
	self.commonIconUrl = iconUrl
	self.resPrefabPath = AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON

	if self.commonIconLease then
		if NotNil(self.resObj) then
			local image = self.resObj:GetComponent("UImage")

			if NotNil(image) then
				image.url = iconUrl
			end

			return
		end

		MapMarkPrefabPoolManager:Release(self.commonIconLease, self, true)

		self.commonIconLease = nil
		self.resObj = nil
	end

	if self.commonIconRequest then
		return
	end

	self.renderGeneration = self.renderGeneration + 1

	local generation = self.renderGeneration
	local request = MapMarkPrefabPoolManager:Acquire(AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON, self, generation, self.root.btnRectTransform, function(gameObject, lease)
		self.commonIconRequest = nil

		if not lease or IsNil(gameObject) then
			return
		end

		if generation ~= self.renderGeneration or self.root.cache ~= self then
			MapMarkPrefabPoolManager:Release(lease, self)

			return
		end

		self.commonIconLease = lease
		self.resObj = gameObject
		self.resObjRef = self.resObj:GetComponent("ObjectReference")

		local image = self.resObj:GetComponent("UImage")

		if NotNil(image) then
			image.url = self.commonIconUrl
		end
	end, MapMarkPrefabPoolManager.OwnerTag.MINI_MAP_COMMON_ICON)

	if request and not request.completed then
		self.commonIconRequest = request
	else
		self.commonIconRequest = nil
	end
end

function MapMarkCache:update()
	self:loadData(self.root.markId, self.root.spawnerTable, self.root.track)
end

function MapMarkCache:updateMapFilter(sceneId)
	self.root.button:TryChangePage("MapFilterHide", not pg.game.map:isEnabledByFilter(sceneId, self.markConfigId, self.markStatus, self.root.markId, {
		finishStateAlwaysShow = self.finishStateAlwaysShow
	}) and 1 or 0)

	if self.type == Const.MAP_CONST.TYPE.QUEST then
		self:refreshQuestTagShow()
	end
end

function MapMarkCache:updateTotalFilter(sceneId)
	self.root.button.renderOpacity = pg.game.map:isEnabledByTotalFilter(sceneId, self.markConfigId) and 1 or 0
end

function MapMarkCache:loadData(spawnerId, spawnerTable, isTrack)
	local go = self.root.gameObject

	if UIUtils.IsNull(go) then
		return
	end

	local sceneId = pg.game.map.mainSceneId

	if isTrack then
		self.root:SetXY(0, 0)
	else
		local mapX, mapY = pg.game.map:convertPos(spawnerTable.markPosition[1], spawnerTable.markPosition[3], sceneId, true)

		self.root:SetXY(mapX, mapY)
	end

	if self:tryRefreshGrabEggInPlace(spawnerTable, isTrack) then
		return
	end

	local markStatus = self.miniMap:GetMarkMapStatus(sceneId, spawnerTable.markType, spawnerId)

	if MapHelper.isSpecialMark(spawnerTable.markType) then
		markStatus = Const.MAP_MARK_STATUS_UNLOCKED
	end

	go:SetActiveEx(false)

	local markLevel = DefaultMapMarkData[spawnerTable.markConfigId].markLevel or 1
	local btnRectTransform = self.root.btnRectTransform
	local scale = UIConst.MAP_CONST.SIZE_DELTA[markLevel]

	btnRectTransform:SetLocalScaleEx(scale[1], scale[2], scale[3])

	self.markLevel = markLevel
	self.markConfigId = spawnerTable.markConfigId
	self.belongAreaId = spawnerTable.belongAreaId
	self.finishStateAlwaysShow = spawnerTable.finishStateAlwaysShow
	self.markStatus = markStatus
	self.type = spawnerTable.type

	if spawnerTable.markConfigId == MAP_MARK_QUEST then
		self.circleRadius = spawnerTable.circleRadius
	end

	self:updateMapFilter(sceneId)
	self:updateTotalFilter(sceneId)

	local trackMarkExists = self.root.trackMode

	if trackMarkExists then
		self:addHighLight()
	else
		self:clearHighLight()
	end

	local useCommonIcon, commonIconUrl = self:getCommonIconData(spawnerTable)
	local keepCommonIcon = useCommonIcon and self.resPrefabPath == AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON and (self.commonIconLease ~= nil or self.commonIconRequest ~= nil)

	if keepCommonIcon then
		self.commonIconUrl = commonIconUrl
	end

	self:clear(trackMarkExists, keepCommonIcon)
	self:renderInAreaRange(isTrack)
	self:renderCompleteIcon(isTrack)
	self:renderTeamTrack(spawnerId, spawnerTable)

	local imgPath

	if spawnerTable.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
		self:updateTypeRainbowPet(spawnerId, spawnerTable)
	elseif MapMarkResourceData[spawnerTable.markConfigId] and (MapMarkResourceData[spawnerTable.markConfigId][sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]) or spawnerTable.markType == MAP_MARK_QUEST or spawnerTable.markType == Const.MAP_MARK_CUSTOM or spawnerTable.markType == Const.MAP_MARK_SHARE or spawnerTable.markType == Const.MAP_MARK_ALLY or spawnerTable.markType == Const.MAP_MARK_GRAB_EGG or spawnerTable.markType == Const.MAP_MARK_FAST_TARGET or spawnerTable.markType == Const.MAP_MARK_GOLD_MONSTER then
		if spawnerTable.type == Const.MAP_CONST.TYPE.NORMAL then
			self:updateTypeNormal(spawnerTable)

			imgPath = self:GetImagePathNormal(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.SINGLE_PUPPET then
			self:updateTypeSinglePuppet(spawnerTable)

			imgPath = self:GetImagePathPuppet(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.BOSS then
			self:updateTypeBoss(spawnerTable)

			imgPath = self:GetImagePathPuppet(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.NPC then
			self:updateTypeNpc(spawnerTable)

			imgPath = self:GetImagePathNpc(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.QUEST then
			self:updateTypeQuest(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.CUSTOM then
			self:updateTypeCustom(spawnerTable)

			imgPath = self:GetImagePathCustom(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.DISTRIBUTION_AREA then
			self:updateTypeDistributionArea(spawnerTable)

			imgPath = self:GetImagePathPuppet(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.LEYLINE_TREE_CREATE then
			self:updateTypeLeylineTreeCreate(spawnerTable)

			imgPath = self:GetImagePathPuppet(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.ECO_TRACE then
			self:updateTypeEcoTrace(spawnerTable)

			imgPath = self:GetImagePathDefault(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.MARK_SHARE then
			self:updateTypeMarkShare(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.DYNAMIC then
			self.miniMap.minimapDynamicMarkComponent:renderDynamicMarkIcon(self, spawnerId, spawnerTable, self.root, isTrack)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.ALLY then
			self:updateTypeAlly(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.FAST_TARGET then
			self:updateTypeFastTarget(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.GOLD then
			self:updateTypeGoldTrace(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.GRAB_EGG then
			self:updateTypeGrabEgg(spawnerTable)
		elseif spawnerTable.type == Const.MAP_CONST.TYPE.DUEL then
			self:updateTypeDuel(spawnerTable, isTrack)
		end
	end

	self.refreshLogicTimes = spawnerTable.refreshLogicTimes

	if not isTrack then
		pg.game.map:storeExtraSharedInfoToMarkId(spawnerId, "imgPath", imgPath)
	end
end

function MapMarkCache:clear(notClearHighLight, keepCommonIcon, forceDiscard)
	if not keepCommonIcon then
		self.renderGeneration = self.renderGeneration + 1

		if self.commonIconRequest then
			MapMarkPrefabPoolManager:CancelRequest(self.commonIconRequest, self)

			self.commonIconRequest = nil
		end
	end

	if self.layerStateTaskId then
		self.view:cancelUIAsyncTask(self.layerStateTaskId)

		self.layerStateTaskId = nil
	end

	if self.layerState then
		self.view:destroyInstance(self.layerState)

		self.layerState = nil
		self.layerStateIconUrl = nil
	end

	if self.resTaskId then
		self.view:cancelUIAsyncTask(self.resTaskId)

		self.resTaskId = nil
	end

	if self.resTaskTagId then
		self.view:cancelUIAsyncTask(self.resTaskTagId)

		self.resTaskTagId = nil
	end

	if self.resTagObj then
		self.view:destroyInstance(self.resTagObj)

		self.resTagObj = nil
		self.resTagCmp = nil
	end

	if self.teamTrackObj then
		self.view:destroyInstance(self.teamTrackObj)

		self.teamTrackObj = nil
	end

	if self.resTaskIds then
		for _, taskId in pairs(self.resTaskIds) do
			self.view:cancelUIAsyncTask(taskId)
		end

		self.resTaskIds = nil
	end

	if not keepCommonIcon then
		if self.commonIconLease then
			MapMarkPrefabPoolManager:Release(self.commonIconLease, self, forceDiscard)
		elseif self.resObj then
			self.view:destroyInstance(self.resObj)
		end

		self.commonIconLease = nil
		self.resObj = nil
		self.resObjRef = nil
		self.resPrefabPath = nil
		self.commonIconUrl = nil
	end

	if self.resObjs then
		for _, resObj in pairs(self.resObjs) do
			self.view:destroyInstance(resObj)
		end

		self.resObjs = nil
	end

	if self.completeIconTaskId then
		self.view:cancelUIAsyncTask(self.completeIconTaskId)

		self.completeIconTaskId = nil
	end

	if self.completeIconObj then
		self.view:destroyInstance(self.completeIconObj)

		self.completeIconObj = nil
	end

	if not keepCommonIcon then
		self.resObjRef = nil
		self.imgGlowUImage = nil
		self.circleAreaTransform = nil
	end

	if not notClearHighLight then
		self:clearHighLight()
	end
end

function MapMarkCache:clearHighLight()
	if self.highLightTaskId then
		self.view:cancelUIAsyncTask(self.highLightTaskId)

		self.highLightTaskId = nil
	end

	if self.highLightObj then
		if self.view:checkInstanceExists(self.highLightObj) then
			self.view:destroyInstance(self.highLightObj)
		end

		self.highLightObj = nil
	end
end

function MapMarkCache:addHighLight()
	if self.highLightTaskId then
		return
	end

	if self.highLightObj then
		return
	end

	self.highLightTaskId = self.view:addPrefabWithPathAsync(self.root.lowerDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_HIGHLIGHT, function(obj)
		self.highLightObj = obj.gameObject
	end, false, true)
end

function MapMarkCache:updateTrackMode()
	if self.root.trackMode then
		self:addHighLight()
	else
		self:clearHighLight()
	end
end

local EVisibilityHidden = CS.XGUI.EVisibility.Hidden
local EVisibilityVisible = CS.XGUI.EVisibility.Visible
local _visibilityArr = {
	EVisibilityHidden,
	EVisibilityVisible
}

function MapMarkCache:updateMarkDisplayOne()
	if not pg.me or not pg.me.space then
		return
	end

	if not pg.game.map:isCurrentSceneValid() then
		return
	end

	local logicTime = pg.me.space.logicTime

	self:updateMarkButtonDisplay(logicTime)
end

function MapMarkCache:updateMarkButtonDisplay(time)
	local btn = self.root.button

	if NotNil(btn) then
		local visibleIndex = 2

		if self.refreshLogicTimes then
			visibleIndex = 1

			for _, times in pairs(self.refreshLogicTimes) do
				if time >= times[1] and time <= times[2] then
					visibleIndex = 2

					break
				end
			end
		else
			visibleIndex = 2
		end

		if self.visibleIndex ~= visibleIndex then
			btn.visibility = _visibilityArr[visibleIndex]
			self.visibleIndex = visibleIndex
		end
	end
end

function MapMarkCache:renderInAreaRange(isTrack)
	if self.type == Const.MAP_CONST.TYPE.AREA then
		return
	end

	if self.type == Const.MAP_CONST.TYPE.GRAB_EGG then
		return
	end

	local sceneId = pg.game.map.mainSceneId

	if self.belongAreaId and MapLevelConfigLoadData[sceneId] and MapLevelConfigLoadData[sceneId][self.belongAreaId] and MapLevelConfigLoadData[sceneId][self.belongAreaId].isGround ~= 1 then
		local mapLayerData = pg.game.map:getMapLayerData(sceneId)
		local areaId = mapLayerData[5]
		local url

		if self.belongAreaId == areaId or MapLevelConfigLoadData[sceneId] and MapLevelConfigLoadData[sceneId][areaId] and LuaUIUtils.tableContains(MapLevelConfigLoadData[sceneId][areaId].relevantAreaIds, self.belongAreaId) then
			url = AddressDataConst.UI_MARK_IMG_LAYER_ACTIVE
		else
			url = AddressDataConst.UI_MARK_IMG_LAYER_INACTIVE
		end

		self:setLayerIcon(url)
	else
		if self.layerStateTaskId then
			self.view:cancelUIAsyncTask(self.layerStateTaskId)

			self.layerStateTaskId = nil
		end

		if self.layerState then
			self.view:destroyInstance(self.layerState)

			self.layerState = nil
			self.layerStateIconUrl = nil
		end
	end
end

function MapMarkCache:setLayerIcon(layerIconUrl)
	self.layerStateIconUrl = layerIconUrl

	if self.layerStateTaskId then
		return
	end

	if self.layerState then
		self:updateLayerState()

		return
	end

	self.layerStateTaskId = self.view:addPrefabWithPathAsync(self.root.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_LAYER_ICON, function(obj)
		self.layerStateTaskId = nil
		self.layerState = obj.gameObject

		self:updateLayerState()
	end, false, true)
end

function MapMarkCache:updateLayerState()
	if not self.layerStateIconUrl then
		return
	end

	local obj = self.layerState

	self:updateIconAnchorPosition(obj)

	obj:GetComponent("UImage").url = self.layerStateIconUrl
end

function MapMarkCache:updateIconAnchorPosition(go, forcePos)
	local pos = forcePos or MapHelper.LAYER_ICON_LOC[self.markLevel]

	go:GetComponent("RectTransform"):SetAnchoredPositionEx(pos.x, pos.y)
end

function MapMarkCache:renderCompleteIcon(isTrack, force)
	if isTrack then
		return
	end

	if self.markStatus >= Const.MAP_MARK_STATUS_CLOSED or force then
		self.completeIconTaskId = self.view:addPrefabWithPathAsync(self.root.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COMPLETE, function(obj1)
			self:updateIconAnchorPosition(obj1.gameObject)

			self.completeIconObj = obj1.gameObject
		end, false, true)
	else
		if self.completeIconTaskId then
			self.view:cancelUIAsyncTask(self.completeIconTaskId)

			self.completeIconTaskId = nil
		end

		if self.completeIconObj then
			self.view:destroyInstance(self.completeIconObj)

			self.completeIconObj = nil
		end
	end
end

function MapMarkCache:renderTeamTrack(spawnerId, spawnerTable)
	local isTrack, firstTrackUid = pg.game.map:getTrackInfo(pg.game.map.mainSceneId, spawnerTable.type, spawnerId)

	if isTrack then
		if self.teamTrackObj then
			local obj1 = self.teamTrackObj
			local uComponent = obj1.gameObject:GetComponent("UComponent")
			local objectReference = obj1.gameObject:GetComponent("ObjectReference")
			local txtPlayerNum = objectReference:GetRefValue("txtPlayerNum")
			local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, firstTrackUid)

			if contain and NotNil(uComponent) then
				uComponent:TryChangePage("Teammate", idx - 1)
				ClientTextUtils.setText(txtPlayerNum, idx)
			end

			self:updateIconAnchorPosition(obj1.gameObject, MapHelper.LAYER_ICON_TARCKLOC)
		else
			self.resTaskId = self.view:addPrefabWithPathAsync(self.root.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_PLAYER_NUM, function(obj1)
				local uComponent = obj1.gameObject:GetComponent("UComponent")
				local objectReference = obj1.gameObject:GetComponent("ObjectReference")
				local txtPlayerNum = objectReference:GetRefValue("txtPlayerNum")
				local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, firstTrackUid)

				if contain and NotNil(uComponent) then
					uComponent:TryChangePage("Teammate", idx - 1)
					ClientTextUtils.setText(txtPlayerNum, idx)
				end

				self:updateIconAnchorPosition(obj1.gameObject, MapHelper.LAYER_ICON_TARCKLOC)

				self.teamTrackObj = obj1.gameObject
			end, false, false, 0)
		end
	else
		if self.resTaskId then
			self.view:cancelUIAsyncTask(self.resTaskId)

			self.resTaskId = nil
		end

		if self.teamTrackObj then
			self.view:destroyInstance(self.teamTrackObj)

			self.teamTrackObj = nil
		end
	end
end

function MapMarkCache:updateTypeRainbowPet(spawnerId, spawnerTable)
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_CULTIVATE, function(obj1)
		local objectReference = obj1.gameObject:GetComponent("ObjectReference")
		local worldTemplateId = pg.space and pg.space.getRainbowPetTemplateIdByPointId and pg.space:getRainbowPetTemplateIdByPointId(spawnerId)

		LuaUIUtils.renderRainbowPetIcon(objectReference:GetRefValue("playerHeadRectTransform"), worldTemplateId)

		self.resObj = obj1.gameObject
		self.resObjRef = objectReference
	end, false, true)

	local active = spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, self.markStatus)

	self.root.gameObject:SetActiveEx(active)
end

function MapMarkCache:updateTypeNormal(spawnerTable)
	if spawnerTable.markType == Const.MAP_MARK_CLUE and (self.markStatus == Const.MAP_MARK_STATUS_HIDE or self.markStatus == Const.MAP_MARK_STATUS_LOCKED) then
		return
	end

	local isGrabEggTransmitter = spawnerTable.markConfigId == 1003

	if not isGrabEggTransmitter then
		self:bindCommonIcon(self:GetImagePathNormal(spawnerTable))
		self:updateTypeNormalVisiable(spawnerTable)

		return
	end

	self.resPrefabPath = AddressDataConst.UI_MARK_NODE_GRAB_EGG_TRANSMITTER
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, self.resPrefabPath, function(obj1)
		if not self:updateTypeNormalVisiable(spawnerTable) then
			return
		end

		local uComponent = obj1.gameObject:GetComponent("UComponent")

		if NotNil(uComponent) then
			local isInUse = MapUtils.isGrabEggTransmitterInUse(self.root.markId)

			uComponent:TryChangePage("Active", isInUse and 1 or 0)
		end

		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	self:updateTypeNormalVisiable(spawnerTable)
end

function MapMarkCache:updateTypeNormalVisiable(spawnerTable)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)
	local go = self.root.gameObject
	local active = false

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		active = true
	end

	if spawnerTable.markType == Const.MAP_MARK_TRACE and not pg.game.map.curTraceMark[self.root.markId] then
		active = false
	end

	go:SetActiveEx(active)

	return active
end

function MapMarkCache:updateTypeSinglePuppet(spawnerTable)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)

	if markStatus == Const.MAP_MARK_STATUS_LOCKED then
		self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE, function(obj1)
			local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS2
			self.resObj = obj1.gameObject
			self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
		end, false, true)
	else
		self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE, function(obj1)
			local imgPath = self:GetImagePathPuppet(spawnerTable)
			local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = imgPath
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS
			self.resObj = obj1.gameObject
			self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
		end, false, true)
	end

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		local go = self.root.gameObject

		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeBoss(spawnerTable)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)
	local go = self.root.gameObject

	if markStatus == Const.MAP_MARK_STATUS_LOCKED then
		self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_NO_ACTIVE, function(obj1)
			local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BOSS_INACTIVE1
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
			self.resObj = obj1.gameObject
			self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
		end, false, true)
	else
		self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_PET_ICON_ACTIVE, function(obj1)
			local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = self:GetImagePathPuppet(spawnerTable)
			objRef1:GetRefValue("iconFrame").transform:GetComponent("UImage").url = AddressDataConst.UI_MARK_IMG_BORDER_BOSS1
			self.resObj = obj1.gameObject
			self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
		end, false, true)
	end

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeNpc(spawnerTable)
	self:bindCommonIcon(self:GetImagePathNpc(spawnerTable))

	local go = self.root.gameObject

	go:SetActiveEx(self.miniMap:IsInScaleArea())

	if not self.root.trackMode then
		self.miniMap:AddNpcCache(self.root.markId, self)
	end
end

function MapMarkCache:updateTypeQuest(spawnerTable)
	local go = self.root.gameObject
	local questId = spawnerTable.questId or 0
	local showTag = false
	local id, isSpawnerId, relateData = pg.game.map:isContainMarkSpawnerId(questId, spawnerTable.objId)
	local relateShow = false

	if isSpawnerId then
		relateShow = self.miniMap:GetMarkMapStatus(self.miniMap.sceneId, relateData.markType, id) > Const.MAP_MARK_STATUS_HIDE
	end

	if spawnerTable and isSpawnerId and pg.game.map:isShowQuestTagMark(questId, spawnerTable.objId) and relateShow and not self.root.track then
		showTag = true
	end

	self:alignQuestTagToRelatePoi(questId, showTag, spawnerTable)

	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_QUEST, function(obj1)
		local questCmp = obj1.gameObject:GetComponent("UComponent")
		local objRef1 = obj1.gameObject:GetComponent("ObjectReference")
		local circleAreaTransform = objRef1:GetRefValue("circleAreaTransform")
		local questNumberUComponent = objRef1:GetRefValue("questNumberUComponent")
		local questNumberUComponentObj = questNumberUComponent.gameObject:GetComponent("ObjectReference")
		local iconUImage = questNumberUComponentObj:GetRefValue("iconUImage")
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		if taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
			questNumberUComponent:TryChangePage("OtherTask", 0)
			questNumberUComponent:TryChangePage("TaskType", taskType.taskType)
		elseif taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
			questNumberUComponent:TryChangePage("OtherTask", 1)

			iconUImage.url = taskType.deliverIcon
		end

		questNumberUComponent:TryChangePage("Arrow", 1)

		if self.root.track then
			questCmp:TryChangePage("showQuest", 1)
			questCmp:TryChangePage("showCircle", 0)
		else
			questCmp:TryChangePage("showQuest", 1)
			questCmp:TryChangePage("showCircle", 0)

			if spawnerTable.circleRadius and spawnerTable.circleRadius > 0 then
				questCmp:TryChangePage("showCircle", 1)

				local r = pg.game.map:calRadius(pg.game.map.mainSceneId, spawnerTable.circleRadius)
				local sizeDeltaNum = self.miniMap:GetQuestCircleScale(r)

				circleAreaTransform.transform:SetSizeDeltaEx(sizeDeltaNum, sizeDeltaNum)

				self.circleAreaTransform = circleAreaTransform
			end
		end

		go:SetActiveEx(true)

		self.resObj = obj1.gameObject

		questNumberUComponent:SetActive(not showTag)

		if not showTag then
			local questSpawnerId = QuestUtils.getCombinedId(questId, spawnerTable.objId)

			self.miniMap:clearPreviousQuestTagTask(questSpawnerId)
		end

		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	if spawnerTable and isSpawnerId then
		self.resTaskTagId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_QUEST_TAG, function(obj1)
			local questCmp = obj1.gameObject:GetComponent("UComponent")

			if questId and questId > 0 then
				local taskType = QuestUtils.getCurSideQuestShowType(questId)

				questCmp:TryChangePage("TaskType", taskType.taskType)
			end

			questCmp:SetActive(showTag)

			self.resTagObj = obj1.gameObject
			self.resTagCmp = questCmp
		end, false, true)
	else
		local questSpawnerId = QuestUtils.getCombinedId(questId, spawnerTable.objId)

		self.miniMap:clearPreviousQuestTagTask(questSpawnerId)
	end
end

function MapMarkCache:refreshQuestTagShow()
	local spawnerTable = self.root.spawnerTable

	if not spawnerTable then
		return
	end

	local questId = spawnerTable.questId or 0

	if questId == 0 then
		return
	end

	local id, isSpawnerId, relateData = pg.game.map:isContainMarkSpawnerId(questId, spawnerTable.objId)
	local showTag = false

	if isSpawnerId then
		local relateShow = self.miniMap:GetMarkMapStatus(self.miniMap.sceneId, relateData.markType, id) > Const.MAP_MARK_STATUS_HIDE

		if pg.game.map:isShowQuestTagMark(questId, spawnerTable.objId) and relateShow and not self.root.track then
			showTag = true
		end
	end

	if self.resObjRef then
		local questNumberUComponent = self.resObjRef:GetRefValue("questNumberUComponent")

		if questNumberUComponent then
			questNumberUComponent:SetActive(not showTag)
		end
	end

	if self.resTagCmp then
		self.resTagCmp:SetActive(showTag)
	end

	self:alignQuestTagToRelatePoi(questId, showTag, spawnerTable)
end

function MapMarkCache:alignQuestTagToRelatePoi(questId, showTag, spawnerTable)
	if self.root.track then
		return
	end

	if not spawnerTable or not spawnerTable.markPosition then
		return
	end

	local sceneId = pg.game.map.mainSceneId
	local pos = spawnerTable.markPosition

	if showTag then
		local relatePos = pg.game.map:getQuestTagRelateMarkPosition(questId, spawnerTable.objId)

		if relatePos then
			pos = relatePos
		end
	end

	local mapX, mapY = pg.game.map:convertPos(pos[1], pos[3], sceneId, true)

	self.root:SetXY(mapX, mapY)
end

function MapMarkCache:updateTypeCustom(spawnerTable)
	local go = self.root.gameObject

	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_CUSTOM, function(obj1)
		obj1.gameObject:GetComponent("UButton"):TryChangePage("IconType", spawnerTable.markIconIndex)

		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	go:SetActiveEx(true)
end

function MapMarkCache:updateTypeDistributionArea(spawnerTable)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)
	local go = self.root.gameObject

	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_DISTRIBUTION, function(obj1)
		if markStatus > Const.MAP_MARK_STATUS_LOCKED then
			local objRef1 = obj1.gameObject:GetComponent("ObjectReference")

			objRef1:GetRefValue("iconPet").transform:GetComponent("UImage").url = self:GetImagePathPuppet(spawnerTable)

			obj1.gameObject:GetComponent("UComponent"):TryChangePage("IsUnknown", 0)
		else
			obj1.gameObject:GetComponent("UComponent"):TryChangePage("IsUnknown", 1)
		end

		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeLeylineTreeCreate(spawnerTable)
	if self.miniMap.hideLeylineTree then
		return
	end

	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)

	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_PLENTY, function(obj1)
		local spawnerId = self.root.markId
		local flowerState = pg.me:getCurFlowerState(spawnerId)
		local imgPath = MapUtils.getLeylineFlowerMarkIcon(spawnerTable.markConfigId, pg.game.map.mainSceneId, markStatus, flowerState)
		local showCircle = false
		local qualityPage, radius, glowScale

		if not self.root.track then
			local flowerInfo = pg.me:getCurFlowerInfo(spawnerId)
			local createId = pg.me:getCurFlowerCreateId(spawnerId)
			local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(spawnerId, createId)

			radius = pg.game.map:calRadius(pg.game.map.mainSceneId, plentyInfo and plentyInfo.radius or 0)
			showCircle = pg.me:shouldShowPlentyCircle(spawnerId)

			if showCircle then
				qualityPage = (flowerInfo.bloomQuality or 0) - 1
			end

			local scale = self.miniMap:GetCurrentMarkPoolScale()

			glowScale = 1 / scale
		end

		self.imgGlowUImage = MapUtils.renderLeylineFlowerMark(obj1.gameObject, imgPath, showCircle, qualityPage, radius, glowScale)
		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject:GetComponent("ObjectReference")
	end, false, true)

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		local go = self.root.gameObject

		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeDuel(spawnerTable, isTrack)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)
	local duelStatus = MapUtils.getNpcDuelStatus(self.root.markId)
	local imgPath

	if duelStatus <= 0 then
		imgPath = MapUtils.getMarkDefaultUnKnownResIcon(spawnerTable.markConfigId)
	else
		imgPath = MapUtils.getMarkDefaultResIcon(spawnerTable.markConfigId)
	end

	self:bindCommonIcon(imgPath)

	if duelStatus > 2 then
		self:renderCompleteIcon(isTrack, true)
	end

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		local go = self.root.gameObject

		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeEcoTrace(spawnerTable)
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_ECO_TRACE, function(obj1)
		local objectReference = obj1.gameObject:GetComponent("ObjectReference")
		local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")
		local bgUImage = objectReference:GetRefValue("bgUImage")

		bgUImage.url = self:GetImagePathDefault(spawnerTable)

		if not self.root.track then
			local radius = ClientActivityUtils.getEcoTraceMarkRadius()
			local sceneId = pg.game.map.mainSceneId
			local r = pg.game.map:calRadius(sceneId, radius)

			imgGlowUImage.transform:SetSizeDeltaEx(r * 2, r * 2)

			local scale = self.miniMap:GetCurrentMarkPoolScale()

			imgGlowUImage.transform:SetLocalScaleEx(1 / scale, 1 / scale, 1)
		else
			imgGlowUImage.gameObject:SetActiveEx(false)
		end

		self.resObj = obj1.gameObject
		self.resObjRef = objectReference
		self.imgGlowUImage = imgGlowUImage
	end, false, true)

	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		local go = self.root.gameObject

		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeGoldTrace(spawnerTable)
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_GOLD_TRACE, function(obj1)
		local objectReference = obj1.gameObject:GetComponent("ObjectReference")
		local imgGlowUImage = objectReference:GetRefValue("imgGlowUImage")
		local bgUImage = objectReference:GetRefValue("bgUImage")

		bgUImage.url = self:GetImagePathDefault(spawnerTable)

		imgGlowUImage.gameObject:SetActiveEx(false)

		self.resObj = obj1.gameObject
		self.resObjRef = objectReference
		self.imgGlowUImage = imgGlowUImage
	end, false, true)

	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)

	if spawnerTable.UsableState ~= nil and LuaUIUtils.tableContains(spawnerTable.UsableState, markStatus) then
		local go = self.root.gameObject

		go:SetActiveEx(true)
	end
end

function MapMarkCache:updateTypeMarkShare(spawnerTable)
	local go = self.root.gameObject

	if not pg.game.markShare:shouldShowOwnMediaMarker() then
		go:SetActiveEx(false)

		return
	end

	self:bindCommonIcon(AddressDataConst.UI_MARK_IMG_MARK_SHARE)

	local expireState = pg.game.markShare:getMyExpireInfoById(self.root.markId)

	if expireState ~= pg.game.markShare.EXPIRE_STATE.Permanent then
		self.resTaskIds = self.resTaskIds or {}
		self.resObjs = self.resObjs or {}
		self.resTaskIds.countdown = self.view:addPrefabWithPathAsync(self.root.upperDynamicLoadTransform, AddressDataConst.UI_MARK_NODE_COUNTDOWN, function(obj1)
			local uComponent = obj1.gameObject:GetComponent("UComponent")

			uComponent:TryChangePage("Time", expireState == pg.game.markShare.EXPIRE_STATE.Expired and 1 or 0)
			self:updateIconAnchorPosition(obj1.gameObject, MapHelper.MARK_SHARE_COUNTDOWN_LOC)

			self.resObjs.countdown = obj1.gameObject
		end, false, false, 0)
	end

	go:SetActiveEx(true)
end

function MapMarkCache:updateTypeAlly(spawnerTable)
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_ALLY, function(obj1)
		local uComponent = obj1.gameObject:GetComponent("UComponent")
		local ent = pg.getEntity(self.root.markId)

		if ent and ent.uid and pg.me:getCurTeamInfo().sortList then
			local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, ent.uid)

			if contain and NotNil(uComponent) then
				uComponent:TryChangePage("Teammate", idx - 1)
			end
		end

		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	local go = self.root.gameObject

	go:SetActiveEx(true)
end

function MapMarkCache:updateTypeFastTarget(spawnerTable)
	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_MARK_FAST_TARGET, function(obj1)
		local uComponent = obj1.gameObject:GetComponent("UComponent")
		local contain, idx = LuaUIUtils.tableContains(pg.me:getCurTeamInfo().sortList, spawnerTable.creatorUid)

		if contain and NotNil(uComponent) then
			uComponent:TryChangePage("Teammate", idx - 1)
		end

		self.resObj = obj1.gameObject
		self.resObjRef = obj1.gameObject.transform:GetComponent("ObjectReference")
	end, false, true)

	local go = self.root.gameObject

	go:SetActiveEx(true)
end

function MapMarkCache:updateTypeGrabEgg(spawnerTable)
	local eggView = GrabEggMapMarkUtils.getEggView(self.root.markId)
	local iconImgPath = self:GetImagePathNormal(spawnerTable)

	self.resTaskId = self.view:addPrefabWithPathAsync(self.root.btnRectTransform, AddressDataConst.UI_MARK_NODE_GRAB_EGG_HUGE_EGG, function(obj1)
		local objectReference = obj1.gameObject:GetComponent("ObjectReference")

		GrabEggMapMarkUtils.applyEggMarkView(objectReference, eggView, iconImgPath)

		self.resObj = obj1.gameObject
		self.resObjRef = objectReference
	end, false, true)

	self.root.gameObject:SetActiveEx(true)
end

function MapMarkCache:tryRefreshGrabEggInPlace(spawnerTable, isTrack)
	if isTrack or spawnerTable.type ~= Const.MAP_CONST.TYPE.GRAB_EGG then
		return false
	end

	if self.type ~= Const.MAP_CONST.TYPE.GRAB_EGG or self.markConfigId ~= spawnerTable.markConfigId then
		return false
	end

	if not NotNil(self.resObj) or not self.resObjRef then
		return false
	end

	local eggView = GrabEggMapMarkUtils.getEggView(self.root.markId)
	local iconImgPath = self:GetImagePathNormal(spawnerTable)

	GrabEggMapMarkUtils.applyEggMarkView(self.resObjRef, eggView, iconImgPath)
	self.root.gameObject:SetActiveEx(true)

	return true
end

function MapMarkCache:SetNpcVisiable(visiable)
	if self.root.track then
		return
	end

	self.root.gameObject:SetActiveEx(visiable)
end

function MapMarkCache:dispose(forceDiscard)
	self.miniMap:RemoveNpcCache(self.root.markId)
	self:clear(false, false, forceDiscard)
end

function MapMarkCache:GetImagePathNormal(spawnerTable)
	local img

	if spawnerTable.replaceIcon then
		img = spawnerTable.replaceIcon
	else
		local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)
		local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][pg.game.map.mainSceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]

		if Const.MAP_MARK_STATUS_HIDE == markStatus or Const.MAP_MARK_STATUS_LOCKED == markStatus then
			if self.root.markType == Const.MAP_MARK_CLUE then
				img = defaultRes.icon

				return img
			end

			img = MapUtils.getMarkDefaultUnKnownResIcon(spawnerTable.markConfigId)
		elseif Const.MAP_MARK_STATUS_UNLOCKED == markStatus then
			img = defaultRes.icon
		elseif Const.MAP_MARK_STATUS_CLOSED == markStatus then
			img = defaultRes.icon
		end
	end

	return img
end

function MapMarkCache:GetImagePathPuppet(spawnerTable)
	local markStatus = self.miniMap:GetMarkMapStatusEx(self.root.markType, self.root.markId)

	if markStatus == Const.MAP_MARK_STATUS_LOCKED then
		return nil
	end

	local idInType = spawnerTable.idInType
	local puppetData = idInType and PuppetData[idInType] or nil
	local iconName = puppetData and puppetData.iconName or nil
	local img = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON)

	return img
end

function MapMarkCache:GetImagePathNpc(spawnerTable)
	local img
	local npcId = spawnerTable.idInType

	if not npcId then
		img = nil
	else
		local spData = pg.game.map:getNPCSpecialState(self.root.markId)

		if spData and spData.iconMap then
			img = spData.iconMap
		elseif NpcFuncData[npcId].iconMap then
			img = NpcFuncData[npcId].iconMap
		else
			img = nil
		end
	end

	return img
end

function MapMarkCache:GetImagePathCustom(spawnerTable)
	return string.format("$UI_Icon_Mark0%s.png", spawnerTable.markIconIndex + 1)
end

function MapMarkCache:GetImagePathDefault(spawnerTable)
	local sceneId = pg.game.map.mainSceneId
	local defaultRes = MapMarkResourceData[spawnerTable.markConfigId][sceneId] or MapMarkResourceData[spawnerTable.markConfigId][0]
	local img = defaultRes.icon

	return img
end

return MapMarkCache
