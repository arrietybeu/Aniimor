-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\MapMarkPrefabPoolManager.lua

local AddressDataConst = require("Const.AddressDataConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("MapMarkPrefabPool")
local SOFT_LIMIT = 250
local SHOW_LOG = false
local MapMarkPrefabPoolManager = {
	sceneEpoch = 0,
	detailLogEnabled = true,
	nextLeaseId = 0,
	nextRequestId = 0,
	OwnerTag = {
		MINI_MAP_NO_RAYBOX = "MiniMap.NoRaybox",
		BIG_MAP_COMMON_ICON = "BigMap.CommonIcon",
		MINI_MAP_COMMON_ICON = "MiniMap.CommonIcon",
		BIG_MAP_BUBBLE_COMMON_ICON = "BigMap.Bubble.CommonIcon"
	},
	buckets = {},
	pendingRequests = {},
	reclaimProviders = {}
}

local function isValidObject(gameObject)
	return gameObject ~= nil and not UIUtils.IsNull(gameObject)
end

local function getTransform(parent)
	if parent == nil or IsNil(parent) then
		return nil
	end

	return parent.transform or parent
end

local function resetTransform(gameObject)
	local transform = gameObject.transform

	transform:SetLocalPositionEx(0, 0, 0)
	transform:SetLocalEulerAnglesEx(0, 0, 0)
	transform:SetLocalScaleEx(1, 1, 1)

	local rectTransform = gameObject:GetComponent("RectTransform")

	if NotNil(rectTransform) then
		rectTransform:SetAnchoredPositionEx(0, 0)
	end
end

local function resetCommonIcon(gameObject)
	local image = gameObject:GetComponent("UImage")

	if NotNil(image) then
		image.url = ""
	end
end

local function getMarkRootDynamicParents(gameObject)
	local objectReference = gameObject:GetComponent("ObjectReference")

	if IsNil(objectReference) then
		return nil
	end

	return {
		objectReference:GetRefValue("btnRectTransform"),
		objectReference:GetRefValue("lowerDynamicLoadTransform"),
		objectReference:GetRefValue("upperDynamicLoadTransform")
	}
end

local function validateNoRaybox(gameObject)
	local dynamicParents = getMarkRootDynamicParents(gameObject)

	if not dynamicParents then
		return false
	end

	for _, parent in ipairs(dynamicParents) do
		if IsNil(parent) or parent.childCount ~= 0 then
			return false
		end
	end

	return true
end

local function resetNoRaybox(gameObject)
	local button = gameObject:GetComponent("UButton")

	if NotNil(button) then
		button.luaClick = nil
		button.luaLongPress = nil
		button.renderOpacity = 1
		button.visibility = CS.XGUI.EVisibility.Visible

		button:TryChangePage("MapFilterHide", 0)
	end
end

local RESOURCE_CONFIGS = {
	[AddressDataConst.UI_MARK_NO_RAYBOX] = {
		softLimit = SOFT_LIMIT,
		reset = resetNoRaybox,
		validate = validateNoRaybox
	},
	[AddressDataConst.UI_MARK_NODE_MARK_COMMON_ICON] = {
		softLimit = SOFT_LIMIT,
		reset = resetCommonIcon
	}
}

function MapMarkPrefabPoolManager:_getBucket(prefabPath)
	local bucket = self.buckets[prefabPath]

	if bucket then
		return bucket
	end

	local config = RESOURCE_CONFIGS[prefabPath]

	if not config then
		return nil
	end

	bucket = {
		reclaiming = false,
		loadingCount = 0,
		totalCount = 0,
		inUseCount = 0,
		prefabPath = prefabPath,
		config = config,
		idle = {},
		idleSet = {},
		objects = {},
		inUse = {},
		stats = {
			overflowInstantiate = 0,
			reclaim = 0,
			instantiateComplete = 0,
			miss = 0,
			hit = 0,
			staleCallback = 0,
			destroyByResetReject = 0,
			destroyByScene = 0,
			destroyByOverflow = 0
		}
	}
	self.buckets[prefabPath] = bucket

	return bucket
end

function MapMarkPrefabPoolManager:_logEvent(bucket, action, ownerTag, generation, requestId, leaseId, reason)
	if not self.detailLogEnabled or not LoggerManager.checkLogger(LoggerConst.INFO) then
		return
	end

	if not SHOW_LOG then
		return
	end

	logger:info(string.format("[MapMarkPool] action=%s prefab=%s owner=%s generation=%s request=%s lease=%s reason=%s total=%s inUse=%s idle=%s loading=%s hit=%s miss=%s instantiated=%s overflow=%s", tostring(action), tostring(bucket.prefabPath), tostring(ownerTag or "Unknown"), tostring(generation or 0), tostring(requestId or 0), tostring(leaseId or 0), tostring(reason or ""), tostring(bucket.totalCount), tostring(bucket.inUseCount), tostring(#bucket.idle), tostring(bucket.loadingCount), tostring(bucket.stats.hit), tostring(bucket.stats.miss), tostring(bucket.stats.instantiateComplete), tostring(bucket.stats.overflowInstantiate)))
end

function MapMarkPrefabPoolManager:_destroyObject(bucket, gameObject, reason)
	if gameObject == nil then
		return
	end

	local wasTracked = bucket.objects[gameObject] ~= nil

	bucket.objects[gameObject] = nil
	bucket.idleSet[gameObject] = nil

	if wasTracked then
		bucket.totalCount = math.max(0, bucket.totalCount - 1)
	end

	if reason and bucket.stats[reason] ~= nil then
		bucket.stats[reason] = bucket.stats[reason] + 1
	end

	if not isValidObject(gameObject) then
		return
	end

	pg.global.uiMgr:DestroyItem(gameObject)
end

function MapMarkPrefabPoolManager:_resetObject(bucket, gameObject)
	resetTransform(gameObject)

	if bucket.config.reset then
		bucket.config.reset(gameObject)
	end
end

function MapMarkPrefabPoolManager:_prepareForUse(bucket, gameObject, parent)
	local parentTransform = getTransform(parent)

	if IsNil(parentTransform) then
		return false
	end

	gameObject:SetActiveEx(false)
	gameObject.transform:SetParent(parentTransform, false)
	self:_resetObject(bucket, gameObject)
	gameObject:SetActiveEx(true)

	return true
end

function MapMarkPrefabPoolManager:_popIdle(bucket)
	while #bucket.idle > 0 do
		local gameObject = table.remove(bucket.idle)

		bucket.idleSet[gameObject] = nil

		if bucket.objects[gameObject] and isValidObject(gameObject) then
			return gameObject
		end

		self:_destroyObject(bucket, gameObject)
	end

	return nil
end

function MapMarkPrefabPoolManager:_createLease(bucket, gameObject, owner, generation, ownerTag)
	self.nextLeaseId = self.nextLeaseId + 1

	local lease = {
		state = "in_use",
		leaseId = self.nextLeaseId,
		prefabPath = bucket.prefabPath,
		gameObject = gameObject,
		owner = owner,
		ownerTag = ownerTag or "Unknown",
		generation = generation,
		sceneEpoch = self.sceneEpoch
	}

	bucket.inUse[lease.leaseId] = lease
	bucket.inUseCount = bucket.inUseCount + 1

	return lease
end

function MapMarkPrefabPoolManager:RegisterReclaimProvider(owner, callback)
	if owner and callback then
		self.reclaimProviders[owner] = callback
	end
end

function MapMarkPrefabPoolManager:UnregisterReclaimProvider(owner)
	if owner then
		self.reclaimProviders[owner] = nil
	end
end

function MapMarkPrefabPoolManager:_tryReclaim(prefabPath, requiredCount)
	local bucket = self:_getBucket(prefabPath)

	if not bucket then
		return
	end

	local before = #bucket.idle
	local success, errorMessage

	bucket.reclaiming = true
	success, errorMessage = xpcall(function()
		for owner, callback in pairs(self.reclaimProviders) do
			if owner and callback then
				callback(prefabPath, requiredCount)

				if #bucket.idle - before >= requiredCount then
					break
				end
			end
		end
	end, debug.traceback)
	bucket.reclaiming = false

	if not success then
		error(errorMessage)
	end

	local reclaimed = math.max(0, #bucket.idle - before)

	bucket.stats.reclaim = bucket.stats.reclaim + reclaimed

	self:_logEvent(bucket, "reclaim_complete", "Pool", nil, nil, nil, reclaimed)
end

function MapMarkPrefabPoolManager:Acquire(prefabPath, owner, generation, parent, callback, ownerTag)
	local bucket = self:_getBucket(prefabPath)

	if not bucket or not owner or IsNil(parent) or not callback then
		return nil
	end

	local gameObject = self:_popIdle(bucket)

	if gameObject then
		bucket.stats.hit = bucket.stats.hit + 1

		if not self:_prepareForUse(bucket, gameObject, parent) then
			self:_destroyObject(bucket, gameObject)

			return nil
		end

		local lease = self:_createLease(bucket, gameObject, owner, generation, ownerTag)

		self:_logEvent(bucket, "acquire_hit", ownerTag, generation, nil, lease.leaseId)

		local request = {
			cancelled = false,
			completed = true,
			requestId = 0,
			owner = owner,
			generation = generation,
			sceneEpoch = self.sceneEpoch,
			lease = lease
		}

		if callback then
			callback(gameObject, lease)
		end

		return request
	end

	local managedCount = bucket.totalCount + bucket.loadingCount

	if managedCount >= bucket.config.softLimit then
		self:_tryReclaim(prefabPath, 1)

		gameObject = self:_popIdle(bucket)

		if gameObject then
			bucket.stats.hit = bucket.stats.hit + 1

			if not self:_prepareForUse(bucket, gameObject, parent) then
				self:_destroyObject(bucket, gameObject)

				return nil
			end

			local lease = self:_createLease(bucket, gameObject, owner, generation, ownerTag)

			self:_logEvent(bucket, "acquire_reclaim_hit", ownerTag, generation, nil, lease.leaseId)

			local request = {
				cancelled = false,
				completed = true,
				requestId = 0,
				owner = owner,
				generation = generation,
				sceneEpoch = self.sceneEpoch,
				lease = lease
			}

			if callback then
				callback(gameObject, lease)
			end

			return request
		end

		bucket.stats.overflowInstantiate = bucket.stats.overflowInstantiate + 1

		self:_logEvent(bucket, "overflow_instantiate_allowed", ownerTag, generation)
	end

	bucket.stats.miss = bucket.stats.miss + 1
	bucket.loadingCount = bucket.loadingCount + 1
	self.nextRequestId = self.nextRequestId + 1

	local request = {
		completed = false,
		cancelled = false,
		requestId = self.nextRequestId,
		prefabPath = prefabPath,
		owner = owner,
		generation = generation,
		sceneEpoch = self.sceneEpoch,
		parent = parent,
		callback = callback,
		ownerTag = ownerTag or "Unknown"
	}

	self.pendingRequests[request.requestId] = request

	self:_logEvent(bucket, "instantiate_request", request.ownerTag, generation, request.requestId)

	local taskId = 0

	taskId = pg.global.uiMgr:InstantiateItem(prefabPath, getTransform(parent), function(loadedObject)
		if request.completed then
			if isValidObject(loadedObject) then
				bucket.stats.instantiateComplete = bucket.stats.instantiateComplete + 1

				pg.global.uiMgr:DestroyItem(loadedObject)
				self:_logEvent(bucket, "instantiate_late_destroy", request.ownerTag, request.generation, request.requestId, nil, "cancelled")
			end

			return
		end

		request.completed = true
		request.taskId = nil
		self.pendingRequests[request.requestId] = nil
		bucket.loadingCount = math.max(0, bucket.loadingCount - 1)

		local requestOwner = request.owner
		local requestParent = request.parent
		local requestCallback = request.callback
		local requestOwnerTag = request.ownerTag

		request.owner = nil
		request.parent = nil
		request.callback = nil

		if not isValidObject(loadedObject) then
			if requestCallback then
				requestCallback(nil, nil)
			end

			return
		end

		bucket.stats.instantiateComplete = bucket.stats.instantiateComplete + 1

		if request.cancelled or request.sceneEpoch ~= self.sceneEpoch then
			bucket.stats.staleCallback = bucket.stats.staleCallback + 1

			pg.global.uiMgr:DestroyItem(loadedObject)
			self:_logEvent(bucket, "instantiate_stale_destroy", requestOwnerTag, request.generation, request.requestId, nil, "scene_epoch")

			if not request.cancelled and requestCallback then
				requestCallback(nil, nil)
			end

			return
		end

		bucket.objects[loadedObject] = true
		bucket.totalCount = bucket.totalCount + 1

		if not self:_prepareForUse(bucket, loadedObject, requestParent) then
			self:_destroyObject(bucket, loadedObject)
			self:_logEvent(bucket, "instantiate_destroy", requestOwnerTag, request.generation, request.requestId, nil, "invalid_parent")

			if requestCallback then
				requestCallback(nil, nil)
			end

			return
		end

		local lease = self:_createLease(bucket, loadedObject, requestOwner, request.generation, requestOwnerTag)

		request.lease = lease

		self:_logEvent(bucket, "instantiate_complete", requestOwnerTag, request.generation, request.requestId, lease.leaseId)

		if requestCallback then
			requestCallback(loadedObject, lease)
		end
	end, false, true, 0)

	if request.completed then
		request.taskId = nil
	else
		request.taskId = taskId
	end

	return request
end

function MapMarkPrefabPoolManager:CancelRequest(request, owner)
	if not request or request.completed or request.cancelled then
		return false
	end

	if owner and request.owner ~= owner then
		return false
	end

	request.cancelled = true
	request.completed = true
	self.pendingRequests[request.requestId] = nil

	local bucket = self:_getBucket(request.prefabPath)

	if bucket then
		bucket.loadingCount = math.max(0, bucket.loadingCount - 1)

		self:_logEvent(bucket, "instantiate_cancel", request.ownerTag, request.generation, request.requestId)
	end

	if request.taskId and request.taskId ~= 0 then
		pg.global.uiMgr:CancelUIAsyncTask(request.taskId)
	end

	request.taskId = nil
	request.owner = nil
	request.parent = nil
	request.callback = nil

	return true
end

function MapMarkPrefabPoolManager:Release(lease, owner, forceDiscard)
	if not lease or lease.state ~= "in_use" then
		return false
	end

	if owner and lease.owner ~= owner then
		return false
	end

	local bucket = self:_getBucket(lease.prefabPath)

	if not bucket or bucket.inUse[lease.leaseId] ~= lease then
		return false
	end

	bucket.inUse[lease.leaseId] = nil
	bucket.inUseCount = math.max(0, bucket.inUseCount - 1)
	lease.state = "released"
	lease.owner = nil

	local gameObject = lease.gameObject

	lease.gameObject = nil

	if not isValidObject(gameObject) then
		self:_destroyObject(bucket, gameObject)
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "invalid_object")

		return true
	end

	if forceDiscard then
		self:_destroyObject(bucket, gameObject)
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "force_rebuild")

		return true
	end

	if lease.sceneEpoch ~= self.sceneEpoch then
		self:_destroyObject(bucket, gameObject, "destroyByScene")
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "old_scene_epoch")

		return true
	end

	if bucket.config.validate and not bucket.config.validate(gameObject) then
		self:_destroyObject(bucket, gameObject, "destroyByResetReject")
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "reset_reject")

		return true
	end

	if bucket.totalCount > bucket.config.softLimit and not bucket.reclaiming then
		self:_destroyObject(bucket, gameObject, "destroyByOverflow")
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "shrink_overflow")

		return true
	end

	local stashParent = pg.global and pg.global.uiMgr and pg.global.uiMgr.infosLayer
	local stashTransform = getTransform(stashParent)

	if IsNil(stashTransform) then
		self:_destroyObject(bucket, gameObject)
		self:_logEvent(bucket, "release_destroy", lease.ownerTag, lease.generation, nil, lease.leaseId, "missing_stash_parent")

		return true
	end

	gameObject:SetActiveEx(false)
	gameObject.transform:SetParent(stashTransform, false)
	self:_resetObject(bucket, gameObject)

	gameObject.name = "map_mark_pool_idle"

	if not bucket.idleSet[gameObject] then
		bucket.idleSet[gameObject] = true
		bucket.idle[#bucket.idle + 1] = gameObject
	end

	self:_logEvent(bucket, "release_idle", lease.ownerTag, lease.generation, nil, lease.leaseId)

	return true
end

function MapMarkPrefabPoolManager:OnSceneReload()
	self:DumpStats("scene_reload_before")

	self.sceneEpoch = self.sceneEpoch + 1

	local pending = {}

	for _, request in pairs(self.pendingRequests) do
		pending[#pending + 1] = request
	end

	for _, request in ipairs(pending) do
		self:CancelRequest(request, request.owner)
	end

	for _, bucket in pairs(self.buckets) do
		local idle = bucket.idle

		bucket.idle = {}
		bucket.idleSet = {}

		for _, gameObject in ipairs(idle) do
			if bucket.objects[gameObject] then
				self:_destroyObject(bucket, gameObject, "destroyByScene")
			end
		end
	end

	self:DumpStats("scene_reload_after")
end

function MapMarkPrefabPoolManager:GetStats(prefabPath)
	local bucket = self:_getBucket(prefabPath)

	if not bucket then
		return nil
	end

	return {
		totalCount = bucket.totalCount,
		loadingCount = bucket.loadingCount,
		idleCount = #bucket.idle,
		inUseCount = bucket.inUseCount,
		stats = bucket.stats
	}
end

function MapMarkPrefabPoolManager:DumpStats(reason)
	if not LoggerManager.checkLogger(LoggerConst.INFO) then
		return
	end

	for prefabPath, bucket in pairs(self.buckets) do
		logger:info(string.format("[MapMarkPoolSummary] reason=%s prefab=%s total=%s inUse=%s idle=%s loading=%s hit=%s miss=%s instantiated=%s reclaimed=%s overflow=%s", tostring(reason or "manual"), prefabPath, bucket.totalCount, bucket.inUseCount, #bucket.idle, bucket.loadingCount, bucket.stats.hit, bucket.stats.miss, bucket.stats.instantiateComplete, bucket.stats.reclaim, bucket.stats.overflowInstantiate))
	end
end

return MapMarkPrefabPoolManager
