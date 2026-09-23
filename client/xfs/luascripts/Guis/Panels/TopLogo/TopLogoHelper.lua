-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\TopLogoHelper.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoHelper")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local Time = require("Core.Common.Time")
local AddressDataConst = require("Const.AddressDataConst")
local TablePool = require("Common.Container.TablePool")
local CircularQueue = require("Core.Framework.CircularQueue")
local Const = require("Const.Const")
local SetUIViewInVisible = Const.RecycleGameObjectType.SetUIViewInVisible
local SetUIViewVisible = Const.RecycleGameObjectType.SetUIViewVisible
local DisableGo = Const.RecycleGameObjectType.DisableGo
local EnableGo = Const.RecycleGameObjectType.EnableGo
local OpenCacheDebugName = TopLogoConst.OpenCacheDebugName
local NotNil = NotNil
local IsNil = IsNil
local MIN_TOP_LOGO_POOL_SIZE = math.max(1, TopLogoConst.PRELOAD_TOPLOG_RES_COUNT)
local TOP_LOGO_POOL_CAPACITY = TopLogoConst.PRELOAD_TOPLOG_RES_COUNT * TopLogoConst.POOL_CAPACITY_MULTIPLIER
local CONTAINER_REFILL_THRESHOLD = math.max(1, math.floor(TopLogoConst.CONTAINER_POOL_TARGET * 0.5))
local CONTAINER_POOL_CAPACITY = TopLogoConst.CONTAINER_POOL_TARGET * TopLogoConst.POOL_CAPACITY_MULTIPLIER

local function createCache(capacity)
	return CircularQueue.new(capacity, true)
end

local function takeUContainerGameObject(cacheItem)
	local gameObject = cacheItem and cacheItem.gameObject

	if cacheItem then
		cacheItem.gameObject = nil

		TablePool.returnTable(cacheItem)
	end

	return gameObject
end

local TopLogoHelper = Class.LightClass("TopLogoHelper")

function TopLogoHelper:ctor(ctrl)
	self.ctrl = ctrl
	self.topLogoId = 0
	self.topLogos = {}
	self.topLogoCache = {}
	self.tplItemComVisiblePolicies = {}
	self._topLogoMonoPaused = false
end

function TopLogoHelper:_applyTopLogoMonoPaused()
	local paused = self._topLogoMonoPaused == true
	local topLogoSystem = pg and pg.game and pg.game.topLogo

	if topLogoSystem and topLogoSystem.setUIPaused then
		topLogoSystem:setUIPaused(paused)
	end

	local root = self.topLogoRoot

	if NotNil(root) then
		root.enabled = not paused
	end
end

function TopLogoHelper:init(view, topLogoRoot, cacheConfig, preContainerRoot)
	self.view = view
	self.topLogoRoot = topLogoRoot
	self.preContainerRootT = preContainerRoot
	self.cacheConfig = cacheConfig
	self.m_pendingLoadUContainerGo = {}

	self:_applyTopLogoMonoPaused()
	self:preloadTopLogoPrefabs()
end

function TopLogoHelper:_getTopLogoRuntimeParent()
	if NotNil(self.topLogoRoot) then
		return self.topLogoRoot.transform
	end
end

function TopLogoHelper:destroy()
	self._destroyed = true
	self._topLogoMonoPaused = false

	self:_applyTopLogoMonoPaused()

	self.tplItemComVisiblePolicies = nil

	if self.m_preloadTaskIds then
		for _, taskId in ipairs(self.m_preloadTaskIds) do
			self:cancelUIAsyncTask(taskId)
		end

		self.m_preloadTaskIds = nil
	end

	if self.topLogoRoot then
		self.topLogoRoot:CleanNoEntityTopLogos()
	end

	for globalId, toplogoItem in pairs(self.topLogos) do
		toplogoItem:onTopLogoCtrlDestroy()
	end

	self.topLogos = {}

	self:destroyAllCaches()
end

function TopLogoHelper:genNoEntTopLogoGlobalId()
	self.topLogoId = self.topLogoId + 1

	if OpenCacheDebugName then
		return "TopLogo#" .. self.topLogoId
	end

	return self.topLogoId
end

function TopLogoHelper:registerTopLogo(globalId, topLogoItem)
	self.topLogos[globalId] = topLogoItem
end

function TopLogoHelper:unRegisterTopLogo(globalId)
	self.topLogos[globalId] = nil
end

function TopLogoHelper:getTopLogo(globalId)
	return self.topLogos[globalId]
end

function TopLogoHelper:preloadTopLogoPrefabs()
	self.m_preloadTaskIds = {}

	local topLogoRuntimeParent = self:_getTopLogoRuntimeParent()

	for _, resId in ipairs(self.cacheConfig.preloadTopLogoResIds) do
		self.topLogoCache[resId] = self.topLogoCache[resId] or createCache(TOP_LOGO_POOL_CAPACITY)

		for i = 1, TopLogoConst.PRELOAD_TOPLOG_RES_COUNT do
			local taskId = self.view:addPrefabWithPathAsync(topLogoRuntimeParent, resId, function(prefabInfo)
				if self._destroyed then
					return
				end

				local gameObject = prefabInfo and prefabInfo.gameObject

				if IsNil(gameObject) then
					return
				end

				local transform = prefabInfo.transform
				local topLogoScript = transform:GetComponent("TopLogo")

				if topLogoScript then
					topLogoScript:ForceInitWidget()
					topLogoScript:SetMonoEnabled(false)
					gameObject:RecycleCacheGameObjectWithGameObjectRoot(SetUIViewInVisible)
				end

				if OpenCacheDebugName then
					local preFix = TopLogoConst.PreloadTopLogoPrefixes[resId] or ""

					gameObject.name = preFix .. "PreCache_UnUse"
				end

				local cache = self.topLogoCache[resId]

				if cache then
					local _, evicted = cache:push(prefabInfo)

					if evicted then
						self.view:destroyInstance(evicted.gameObject)
					end
				end
			end)

			if taskId and taskId ~= 0 then
				self.m_preloadTaskIds[#self.m_preloadTaskIds + 1] = taskId
			end
		end
	end

	local preContainerInfo = self.cacheConfig.preloadTopLogoUContainerInfo

	if preContainerInfo and preContainerInfo.url then
		self.topLogoCache[preContainerInfo.url] = self.topLogoCache[preContainerInfo.url] or createCache(CONTAINER_POOL_CAPACITY)

		local minKeep = preContainerInfo.count or TopLogoConst.PRELOAD_TOPLOG_RES_COUNT

		for i = 1, minKeep do
			local taskId = self.view:addPrefabWithPathAsync(self.preContainerRootT, preContainerInfo.url, function(cacheItem)
				if self._destroyed or not cacheItem or not cacheItem.gameObject then
					return
				end

				if OpenCacheDebugName then
					cacheItem.gameObject.name = "PreContainer_UnUse"
				end

				local cache = self.topLogoCache[preContainerInfo.url]

				if cache then
					cacheItem.gameObject:RecycleCacheGameObject(DisableGo)

					cacheItem.transform = nil

					local _, evicted = cache:push(cacheItem)

					if evicted then
						self.view:destroyInstance(takeUContainerGameObject(evicted))
					end
				end
			end)

			if taskId and taskId ~= 0 then
				self.m_preloadTaskIds[#self.m_preloadTaskIds + 1] = taskId
			end
		end
	end
end

function TopLogoHelper:getTopLogoPrefab(resId, callback)
	local caches = self.topLogoCache[resId]

	while caches and not caches:isEmpty() do
		local cacheItem = caches:pop()
		local gameObject = cacheItem and cacheItem.gameObject

		if NotNil(gameObject) then
			cacheItem._poolTime = nil

			gameObject:RecycleCacheGameObjectWithGameObjectRoot(SetUIViewVisible)
			self:_evictExpiredItems(caches)
			callback(cacheItem)

			return 0
		end
	end

	local taskId = self.view:addPrefabWithPathAsync(self:_getTopLogoRuntimeParent(), resId, callback)

	return taskId
end

function TopLogoHelper:getTopLogoUContainerGo(parent, containerUrl)
	if not containerUrl or not parent then
		return
	end

	local resultGo
	local caches = self.topLogoCache[containerUrl]

	while caches and not caches:isEmpty() do
		local gameObject = takeUContainerGameObject(caches:pop())

		if gameObject and not IsNil(gameObject) then
			gameObject:RecycleCacheGameObject(EnableGo, parent)

			if OpenCacheDebugName then
				gameObject.name = "UContainer_InUse"
			end

			resultGo = gameObject

			break
		end
	end

	if not resultGo then
		local prefabInfo = self.view:addPrefabWithPathSync(parent, containerUrl)

		resultGo = prefabInfo and prefabInfo.gameObject
	end

	local remainCount = caches and caches:size() or 0

	if remainCount < CONTAINER_REFILL_THRESHOLD then
		self:pendingPreLoadUContainerGo(containerUrl)
	end

	return resultGo
end

function TopLogoHelper:pendingPreLoadUContainerGo(containerUrl)
	if not containerUrl or self._destroyed then
		return
	end

	if not self.preContainerRootT then
		return
	end

	self.m_pendingLoadUContainerGo = self.m_pendingLoadUContainerGo or {}

	local caches = self.topLogoCache[containerUrl] or createCache(CONTAINER_POOL_CAPACITY)

	self.topLogoCache[containerUrl] = caches

	local inFlight = self.m_pendingLoadUContainerGo[containerUrl] or 0
	local needCount = TopLogoConst.CONTAINER_POOL_TARGET - caches:size() - inFlight

	if needCount <= 0 then
		return
	end

	self.m_pendingLoadUContainerGo[containerUrl] = inFlight + needCount

	for i = 1, needCount do
		self.view:addPrefabWithPathAsync(self.preContainerRootT, containerUrl, function(item)
			if self._destroyed then
				if self.m_pendingLoadUContainerGo then
					self.m_pendingLoadUContainerGo[containerUrl] = (self.m_pendingLoadUContainerGo[containerUrl] or 1) - 1
				end

				if item and item.gameObject and self.view then
					self.view:destroyInstance(item.gameObject)
				end

				return
			end

			self.m_pendingLoadUContainerGo[containerUrl] = (self.m_pendingLoadUContainerGo[containerUrl] or 1) - 1

			if item and item.gameObject then
				if OpenCacheDebugName then
					item.gameObject.name = "PreContainer_UnUse"
				end

				local curCaches = self.topLogoCache[containerUrl] or createCache(CONTAINER_POOL_CAPACITY)

				self.topLogoCache[containerUrl] = curCaches

				item.gameObject:RecycleCacheGameObject(DisableGo)

				item.transform = nil

				local _, evicted = curCaches:push(item)

				if evicted then
					self.view:destroyInstance(takeUContainerGameObject(evicted))
				end
			end
		end)
	end
end

function TopLogoHelper:_evictExpiredItems(caches)
	if caches:size() <= MIN_TOP_LOGO_POOL_SIZE then
		return
	end

	local now = Time.realSecondCache
	local item = caches:peek()

	if item and item._poolTime and now - item._poolTime > TopLogoConst.POOL_EXPIRE_TIME then
		caches:pop()
		self.view:destroyInstance(item.gameObject)
	end
end

function TopLogoHelper:returnTopLogoPrefab(resId, objectInfo)
	local gameObject = objectInfo and objectInfo.gameObject

	if IsNil(gameObject) then
		return
	end

	local transform = objectInfo.transform
	local cacheInfo = self.topLogoCache[resId] or createCache(TOP_LOGO_POOL_CAPACITY)

	self.topLogoCache[resId] = cacheInfo

	transform:RecycleCacheGameObjectWithGameObjectRoot(SetUIViewInVisible)

	if OpenCacheDebugName then
		local preFix = TopLogoConst.PreloadTopLogoPrefixes[resId] or ""

		if resId == AddressDataConst.UI_Node_TopLogo_ElementProgress then
			preFix = "Ecs_"
		end

		gameObject.name = preFix .. "Reset_UnUse"
	end

	objectInfo._poolTime = Time.realSecondCache

	local _, evicted = cacheInfo:push(objectInfo)

	if evicted then
		self.view:destroyInstance(evicted.gameObject)
	end
end

function TopLogoHelper:cancelUIAsyncTask(taskId)
	if taskId and taskId ~= 0 then
		self.view:cancelUIAsyncTask(taskId)
	end
end

function TopLogoHelper:destroyInstance(gameObject)
	self.view:destroyInstance(gameObject)
end

function TopLogoHelper:destroyAllCaches()
	for resId, cacheList in pairs(self.topLogoCache) do
		while not cacheList:isEmpty() do
			local cacheItem = cacheList:pop()

			self.view:destroyInstance(cacheItem.gameObject)
		end
	end

	self.topLogoCache = {}
end

function TopLogoHelper:refreshTopLogoVisible()
	for k, v in pairs(self.topLogos) do
		v:refreshTopLogoVisible()
	end
end

function TopLogoHelper:isTopLogoMonoPaused()
	return self._topLogoMonoPaused == true
end

function TopLogoHelper:setTopLogoMonoPaused(paused)
	paused = paused == true

	if self._topLogoMonoPaused == paused then
		return
	end

	self._topLogoMonoPaused = paused

	self:_applyTopLogoMonoPaused()
end

local function cloneTargetCompNames(targetCompNames)
	if type(targetCompNames) ~= "table" then
		return targetCompNames
	end

	local snapshot = {}

	for componentName, value in pairs(targetCompNames) do
		snapshot[componentName] = value
	end

	return snapshot
end

local function applyTopLogoComponentVisiblePolicy(componentName, component, visibleKey, visible, targetCompNames)
	if component.ignoreCompVisibleCheck or targetCompNames == nil or targetCompNames[componentName] then
		component:setVisible(visible, visibleKey)
	else
		component:setVisible(not visible, visibleKey)
	end
end

function TopLogoHelper:applyTopLogoComponentVisiblePolicies(componentName, component)
	if not component then
		return
	end

	for visibleKey, policy in pairs(self.tplItemComVisiblePolicies or EMPTY_TABLE) do
		applyTopLogoComponentVisiblePolicy(componentName, component, visibleKey, policy.visible, policy.targetCompNames)
	end
end

function TopLogoHelper:setTopLogoComponentVisible(visibleKey, visible, targetCompNames)
	visibleKey = visibleKey or UIConst.TOPLOGO_VISIBLE_KEY.DEFAULT

	if visible == nil then
		visible = false
	end

	local targetSnapshot = cloneTargetCompNames(targetCompNames)

	self.tplItemComVisiblePolicies = self.tplItemComVisiblePolicies or {}

	if visible == true and targetSnapshot == nil then
		self.tplItemComVisiblePolicies[visibleKey] = nil
	else
		self.tplItemComVisiblePolicies[visibleKey] = {
			visible = visible,
			targetCompNames = targetSnapshot
		}
	end

	for _, topLogoItem in pairs(self.topLogos) do
		for name, comp in pairs(topLogoItem.components) do
			applyTopLogoComponentVisiblePolicy(name, comp, visibleKey, visible, targetSnapshot)
		end
	end
end

function TopLogoHelper:refreshAllTopLogos(funcName)
	for globalId, topLogo in pairs(self.topLogos) do
		if topLogo and topLogo[funcName] then
			topLogo[funcName](topLogo)
		end
	end
end

function TopLogoHelper:debugDumpPoolStatus()
	local outLines = {}

	local function line(str)
		logger:error("[TplPoolDump] %s", str)

		outLines[#outLines + 1] = str
	end

	line(string.format("[Config] PRELOAD_TOPLOG_RES_COUNT=%s POOL_CAPACITY_MULTIPLIER=%s cap(per resId)=%s", tostring(TopLogoConst.PRELOAD_TOPLOG_RES_COUNT), tostring(TopLogoConst.POOL_CAPACITY_MULTIPLIER or 2), tostring(TOP_LOGO_POOL_CAPACITY)))
	line(string.format("[Config] CONTAINER_POOL_TARGET=%s container cap=%s", tostring(TopLogoConst.CONTAINER_POOL_TARGET), tostring(CONTAINER_POOL_CAPACITY)))

	local byResId = {}

	local function bucket(resId)
		resId = tostring(resId or "nil")
		byResId[resId] = byResId[resId] or {
			registered = 0,
			hasCacheZone = 0,
			loaded = 0,
			loading = 0
		}

		return byResId[resId]
	end

	for _, topLogoItem in pairs(self.topLogos) do
		local b = bucket(topLogoItem.resId)

		b.registered = b.registered + 1

		if topLogoItem.objectInfo then
			b.loaded = b.loaded + 1
		end

		if topLogoItem.taskId and topLogoItem.taskId ~= 0 then
			b.loading = b.loading + 1
		end

		if topLogoItem.cacheZoneRootContainerTransforms and next(topLogoItem.cacheZoneRootContainerTransforms) then
			b.hasCacheZone = b.hasCacheZone + 1
		end
	end

	for resId, b in pairs(byResId) do
		line(string.format("  %s => registered=%d loaded=%d loading=%d hasCacheZone=%d", resId, b.registered, b.loaded, b.loading, b.hasCacheZone))
	end

	line("[Pool size]")

	for resId, cache in pairs(self.topLogoCache) do
		line(string.format("  pool[%s] = %d", tostring(resId), cache:size()))
	end

	local File = require("Core.Common.File")
	local dir = CS and CS.UnityEngine and CS.UnityEngine.Application and CS.UnityEngine.Application.persistentDataPath or "."
	local fullPath = dir .. "/toplogo_pool_stat.log"
	local ok, err = pcall(function()
		File.writePath(fullPath, table.concat(outLines, "\n"))
	end)

	if not ok then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("debugDumpPoolStatus writePath failed: %s", tostring(err))
		end

		return "dump 落盘失败: " .. tostring(err)
	end

	return "TopLogo pool stat dumped → " .. fullPath
end

function TopLogoHelper:debugLoadAllChildrenComponent(compName)
	for _, topLogo in pairs(self.topLogos) do
		if topLogo and topLogo.components then
			for name, comp in pairs(topLogo.components) do
				if not compName or compName == comp.compName then
					comp:checkAndLoadUContainerUrlSupportAsync()
				end
			end
		end
	end
end

return TopLogoHelper
