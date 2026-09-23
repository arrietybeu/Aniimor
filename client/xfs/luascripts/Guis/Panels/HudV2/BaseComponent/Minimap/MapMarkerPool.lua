-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\Minimap\\MapMarkerPool.lua

local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local MapMarkCache = require("Guis.Panels.HudV2.BaseComponent.Minimap.MapMarkCache")
local MapMarkPrefabPoolManager = require("Guis.Utils.MapMarkPrefabPoolManager")
local Class = require("Core.Framework.Class")
local MapHelper = require("GameApp.Map.MapHelper")
local MapMarkerPool = Class.LightClass("MapMarkerPool")
local _dirtys = {}

function MapMarkerPool:ctor(component, spawnerId, spawnerTable)
	self.markId = spawnerId
	self.spawnerTable = spawnerTable
	self.markType = spawnerTable.markType
	self.component = component
	self.x = -9999
	self.y = -9999
	self.logicVisiable = true
	self.old = {}
	self.traceType = pg.game.map:getMarkTraceTypeByConfigId(spawnerTable.markConfigId)
	self.rootGeneration = 0
	self.rootRequest = nil
	self.rootLease = nil
end

function MapMarkerPool:SetVisible(visible)
	if self.visible == visible then
		return
	end

	self.visible = visible
	_dirtys[self] = true
end

function MapMarkerPool:SetLogicVisible(logicVisiable)
	if self.logicVisiable == logicVisiable then
		return
	end

	self.logicVisiable = logicVisiable
	_dirtys[self] = true
end

function MapMarkerPool:SetScale(scale)
	if self.track then
		scale = UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE
	end

	self:SetScaleEx(scale)
end

function MapMarkerPool:GetRealScale(scale)
	if self.track then
		scale = UIConst.MAP_CONST.MINIMAP_ICON_SCALE_COE
	end

	return scale
end

function MapMarkerPool:SetScaleEx(scale)
	if self.scale == scale then
		return
	end

	self.scale = scale
	_dirtys[self] = true
end

function MapMarkerPool:debugScale(scale)
	return
end

function MapMarkerPool:debugDirtys()
	local tab = {}

	for k in pairs(_dirtys) do
		table.insert(tab, k:toString())
	end
end

function MapMarkerPool:toString()
	return string.format("%s %s %s_%s_%s", tostring(self), tostring(self.track), self.markType, self.spawnerTable.markConfigId, self.markId)
end

function MapMarkerPool:SetPriority(priority)
	if self.priority == priority then
		return
	end

	self.priority = priority
	_dirtys[self] = true
end

function MapMarkerPool:SetTrack(track)
	if self.track == track then
		return
	end

	self.track = track

	self:updatePrirority()
	self:SetScale(self.component:GetCurrentMarkPoolScale())

	_dirtys[self] = true
end

function MapMarkerPool:GetCurrentPriority()
	if self.trackMode then
		if self.track then
			return MapHelper.trackPriority
		else
			return MapHelper.topPriority
		end
	else
		local priority = pg.game.map:getMarkPriorityByConfigId(self.spawnerTable.markConfigId)

		return priority
	end
end

function MapMarkerPool:updatePrirority()
	local priority = self:GetCurrentPriority()

	self:SetPriority(priority)
end

function MapMarkerPool:SetXY(x, y)
	if self.x == x and self.y == y then
		return
	end

	self:SetXYEx(x, y)
end

function MapMarkerPool:SetXYEx(x, y)
	self.x = x
	self.y = y

	if self.trans then
		self.trans:SetAnchoredPositionEx(x, y)
	end
end

function MapMarkerPool:SetTrackMode(trackMode)
	if self.trackMode == trackMode then
		return
	end

	self.trackMode = trackMode

	self:updatePrirority()
	self:SetVisible(true)

	if not trackMode then
		self:SetTrack(false)
	end

	_dirtys[self] = true
end

function MapMarkerPool:ChangeScale()
	self.old.scale = self.scale

	self.trans:SetLocalScaleEx(self.scale, self.scale, 1)
end

function MapMarkerPool:ChangePriority()
	self.old.priority = self.priority

	local markLayer = self.component:GetLayer(self.priority)

	self.trans:SetParent(markLayer.transform, false)
end

function MapMarkerPool:ChangeTrack()
	self.old.track = self.track

	self:changeAnchor()

	local cache = self.cache

	if cache then
		cache:update()
	end
end

function MapMarkerPool:ChangeTrackMode()
	self.old.trackMode = self.trackMode

	local cache = self.cache

	if cache then
		cache:updateTrackMode()
	end
end

function MapMarkerPool:ChangeVisible()
	self.old.visible = self.visible
	self.old.logicVisiable = self.logicVisiable

	local visible = self.visible and self.logicVisiable

	if visible then
		if NotNil(self.gameObject) then
			return
		end

		if self.rootLease then
			MapMarkPrefabPoolManager:Release(self.rootLease, self, true)

			self.rootLease = nil
			self.gameObject = nil
		end

		if self.loadTaskId or self.rootRequest then
			return
		end

		self:LoadRoot()
	else
		self:clear()
	end
end

function MapMarkerPool:update()
	if self.cache then
		self.cache:update()
	end
end

function MapMarkerPool:LoadRoot()
	if self.priority == nil then
		self:updatePrirority()
	end

	local markLayer = self.component:GetLayer(self.priority)

	if IsNil(markLayer) then
		return
	end

	self.rootGeneration = self.rootGeneration + 1

	local generation = self.rootGeneration
	local request = MapMarkPrefabPoolManager:Acquire(AddressDataConst.UI_MARK_NO_RAYBOX, self, generation, markLayer, function(gameObject, lease)
		self.rootRequest = nil

		if not lease or IsNil(gameObject) then
			return
		end

		if generation ~= self.rootGeneration or not self.visible or not self.logicVisiable then
			MapMarkPrefabPoolManager:Release(lease, self)

			return
		end

		self.rootLease = lease
		self.gameObject = gameObject
		self.trans = self.gameObject.transform
		self.gameObject.name = string.format("minimark_%s_%s_%s", self.markType, self.spawnerTable.markConfigId, self.markId)

		self:SetXYEx(self.x, self.y)
		self:InitReference()
		self:changeAnchor()
		self:UpdateCache()

		self.old.scale = nil

		local scale = self.component:GetCurrentMarkPoolScale()

		self:SetScale(scale)
		self:ChangeScale()
		self:updatePrirority()

		if self.priority ~= self.old.priority then
			self:ChangePriority()
		end
	end, MapMarkPrefabPoolManager.OwnerTag.MINI_MAP_NO_RAYBOX)

	if request and not request.completed then
		self.rootRequest = request
	else
		self.rootRequest = nil
	end
end

function MapMarkerPool:InitReference()
	local objRef = self.gameObject:GetComponent("ObjectReference")
	local btnRectTransform = objRef:GetRefValue("btnRectTransform")
	local lowerDynamicLoadTransform = objRef:GetRefValue("lowerDynamicLoadTransform")
	local upperDynamicLoadTransform = objRef:GetRefValue("upperDynamicLoadTransform")

	self.button = self.gameObject:GetComponent("UButton")
	self.btnRectTransform = btnRectTransform
	self.lowerDynamicLoadTransform = lowerDynamicLoadTransform
	self.upperDynamicLoadTransform = upperDynamicLoadTransform
end

function MapMarkerPool:UpdateCache()
	if self.cache then
		self.cache:update()
	else
		self.cache = MapMarkCache.new(self.component, self.component.view, self)

		self.cache:update()
	end
end

function MapMarkerPool:changeAnchor()
	if self.track then
		self:updateAnchorAsTrack()
	else
		self:updateAnchorAsNormal()
	end
end

function MapMarkerPool:updateAnchorAsNormal()
	self.trans:SetAnchorMinEx(0, 1)
	self.trans:SetAnchorMaxEx(0, 1)
	self.trans:SetPivotEx(0.5, 0.5)
end

function MapMarkerPool:updateAnchorAsTrack()
	self.trans:SetAnchorMinEx(0.5, 0.5)
	self.trans:SetAnchorMaxEx(0.5, 0.5)
	self.trans:SetPivotEx(0.5, 0.5)
end

function MapMarkerPool:setTopLayer(top)
	local priority = 99

	if not top then
		priority = pg.game.map:getMarkPriorityByConfigId(self.markConfigId)
	end

	self:SetPriority(priority)
end

function MapMarkerPool:renderInAreaRange(isTrack)
	if self.cache then
		self.cache:renderInAreaRange(isTrack)
	end
end

function MapMarkerPool:clear(forceDiscard)
	_dirtys[self] = nil
	self.rootGeneration = self.rootGeneration + 1

	if self.rootRequest then
		MapMarkPrefabPoolManager:CancelRequest(self.rootRequest, self)

		self.rootRequest = nil
	end

	if self.loadTaskId then
		self.component.view:cancelUIAsyncTask(self.loadTaskId)

		self.loadTaskId = nil
	end

	if self.cache then
		self.cache:dispose(forceDiscard)

		self.cache = nil
	end

	if self.rootLease then
		MapMarkPrefabPoolManager:Release(self.rootLease, self, forceDiscard)

		self.rootLease = nil
	elseif self.gameObject then
		self.component.view:destroyInstance(self.gameObject)
	end

	self.gameObject = nil
	self.trans = nil
	self.button = nil
	self.btnRectTransform = nil
	self.lowerDynamicLoadTransform = nil
	self.upperDynamicLoadTransform = nil
	self.scale = nil
end

function MapMarkerPool:dispose()
	self:clear()
end

function MapMarkerPool:ForceRebuild()
	local shouldReload = self.visible and self.logicVisiable

	self:clear(true)

	if shouldReload then
		self:LoadRoot()
	end
end

function MapMarkerPool:UpdateNoTrackCacheScale(scaleRverse)
	if self.track then
		return
	end

	local markCache = self.cache

	if markCache then
		if self.markType == Const.MAP_MARK_LeylineTree_Create or self.markType == Const.MAP_MARK_EcoTrace_Search then
			local imgGlowUImage = markCache.imgGlowUImage

			if imgGlowUImage then
				imgGlowUImage.transform:SetLocalScaleEx(scaleRverse, scaleRverse, 1)
			end
		else
			local circleAreaTransform = markCache.circleAreaTransform

			if circleAreaTransform then
				local r = MapHelper.calRadius(pg.game.map.mainSceneId, markCache.circleRadius)
				local sizeDeltaNum = 2 * r * scaleRverse

				circleAreaTransform:SetSizeDeltaEx(sizeDeltaNum, sizeDeltaNum)
			end
		end
	end
end

function MapMarkerPool:updateMapFilter(sceneId)
	if self.cache then
		self.cache:updateMapFilter(sceneId)
	end
end

function MapMarkerPool:updateTotalFilter(sceneId)
	if self.cache then
		self.cache:updateTotalFilter(sceneId)
	end
end

function MapMarkerPool:updateDirty()
	local old = self.old

	if self.visible ~= old.visible or self.logicVisiable ~= old.logicVisiable then
		self:ChangeVisible()
	end

	if self.trans then
		if self.priority ~= old.priority then
			self:ChangePriority()
		end

		if self.scale ~= old.scale then
			self:ChangeScale()
		end

		if self.trackMode ~= old.trackMode then
			self:ChangeTrackMode()
		end

		if self.track ~= old.track then
			self:ChangeTrack()
		end
	end

	_dirtys[self] = nil
end

function MapMarkerPool.GetDirtyTable()
	return _dirtys
end

return MapMarkerPool
