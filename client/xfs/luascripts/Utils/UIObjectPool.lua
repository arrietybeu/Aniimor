-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\UIObjectPool.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("TickManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIObjectPool = Class.LightClass("UIObjectPool")

function UIObjectPool:ctor(resId, parent, preLoadMaxCount, defaultScaleX, defaultScaleY, defaultScaleZ, preLoadCb, recycleCb)
	self.asyncTaskIdMap = {}
	self._instantiatePrefabs = {}
	self.preLoadMaxCount = preLoadMaxCount or 0
	self.defaultScaleX = defaultScaleX or 1
	self.defaultScaleY = defaultScaleY or 1
	self.defaultScaleZ = defaultScaleZ or 1
	self.parent = parent
	self.resId = resId
	self.pool = {}
	self.objectPool = {}
	self.recycleCb = recycleCb

	self:preLoad(preLoadCb)
end

function UIObjectPool:preLoad(preLoadCb)
	for i = 1, self.preLoadMaxCount do
		local gameObject = self:addPrefabWithPathSync(self.parent, self.resId)

		if not gameObject then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("addPrefabWithPathSync failed", self.resId, debug.traceback())
			end

			return
		end

		gameObject.name = "pool_node_empty"
		gameObject.transform.localScale = Vector3(self.defaultScaleX, self.defaultScaleY, self.defaultScaleZ)

		gameObject:SetActiveEx(false)

		local obj = {}

		obj.gameObject = gameObject
		obj.activeStatus = false
		obj.id = -i
		obj.innerData = {}
		self.objectPool[#self.objectPool + 1] = obj
	end

	if preLoadCb then
		preLoadCb(self.objectPool)
	end
end

function UIObjectPool:isIdValid(id)
	return self.pool[id] ~= nil
end

function UIObjectPool:createFromPool(innerData, id, callback)
	if self:isIdValid(id) == true then
		local exist = self:getFromPool(id)

		exist.innerData = innerData

		if callback then
			callback(exist)
		end

		return
	end

	for _, v in pairs(self.objectPool) do
		if v.activeStatus == false and not UIUtils.IsNull(v.gameObject) then
			v.activeStatus = true

			v.gameObject:SetActiveEx(true)

			v.gameObject.name = string.format("pool_node_%s", id)
			v.id = id
			v.innerData = innerData
			self.pool[id] = v

			if callback then
				callback(v)
			end

			return
		end
	end

	self:addPrefabWithPathAsync(self.parent, self.resId, function(gameObject)
		gameObject.name = string.format("pool_node_%s", id)
		gameObject.transform.localScale = Vector3(self.defaultScaleX, self.defaultScaleY, self.defaultScaleZ)

		gameObject:SetActiveEx(true)

		local obj = {}

		obj.gameObject = gameObject
		obj.activeStatus = true
		obj.id = id
		obj.innerData = innerData
		self.objectPool[#self.objectPool + 1] = obj
		self.pool[id] = obj

		if callback then
			callback(obj)
		end
	end, false, false, 3)
end

function UIObjectPool:getFromPool(id)
	return self.pool[id]
end

function UIObjectPool:recycleToPool(id, successCallback)
	if self:isIdValid(id) == false then
		return
	end

	self.pool[id] = nil

	for _, v in pairs(self.objectPool) do
		if v.id == id and not UIUtils.IsNull(v.gameObject) then
			v.innerData = {}

			v.gameObject:SetActiveEx(false)

			v.gameObject.name = "pool_node_empty"
			v.activeStatus = false

			if self.recycleCb then
				self.recycleCb(v.gameObject)
			end

			if successCallback ~= nil then
				successCallback()
			end

			return
		end
	end
end

function UIObjectPool:recycleAll()
	for k, _ in pairs(self.pool) do
		self:recycleToPool(k)
	end
end

function UIObjectPool:addPrefabWithPathAsync(parent, resID, callback, urgent, ignoreWhileNoParent, priority)
	if string.isNilOrEmpty(resID) then
		return
	end

	if IsNil(parent) then
		return
	end

	local uiMgr = pg.global.uiMgr

	urgent = urgent or false
	ignoreWhileNoParent = ignoreWhileNoParent or false
	self.asyncTaskIdMap = self.asyncTaskIdMap or {}

	local taskId = 0

	taskId = uiMgr:InstantiateItem(resID, parent.transform, function(gameObject)
		self:addRefInstance(gameObject, resID)

		if taskId ~= 0 then
			self.asyncTaskIdMap[taskId] = nil
		end

		if callback then
			callback(gameObject)
		end
	end, urgent, ignoreWhileNoParent, priority)

	if taskId ~= 0 then
		self.asyncTaskIdMap[taskId] = true
	end

	return taskId
end

function UIObjectPool:addPrefabWithPathSync(parent, resID)
	if IsNil(parent) or not resID then
		return
	end

	local uiMgr = pg.global.uiMgr
	local gameObject = uiMgr:SyncInstantiateItem(resID, parent.transform)

	self:addRefInstance(gameObject, resID)

	return gameObject
end

function UIObjectPool:addRefInstance(instance, resID)
	if NotNil(instance) then
		table.insert(self._instantiatePrefabs, {
			instance,
			resID
		})
	end
end

function UIObjectPool:destroyInstance(instance)
	if NotNil(instance) then
		for index, instInfo in ipairs(self._instantiatePrefabs) do
			local inst, resID = unpack(instInfo)

			if inst == instance then
				table.remove(self._instantiatePrefabs, index)

				break
			end
		end

		pg.global.uiMgr:DestroyItem(instance)
	end
end

function UIObjectPool:destroyAllInstance()
	for _, instInfo in pairs(self._instantiatePrefabs) do
		local inst, resID = unpack(instInfo)

		if NotNil(inst) then
			pg.global.uiMgr:DestroyItem(inst)
		end
	end

	self._instantiatePrefabs = {}
end

function UIObjectPool:destroy()
	for taskId, _ in pairs(self.asyncTaskIdMap) do
		pg.global.uiMgr:CancelUIAsyncTask(taskId)
	end

	self.asyncTaskIdMap = {}

	self:destroyAllInstance()

	self.preLoadMaxCount = nil
	self.defaultScaleX = nil
	self.defaultScaleY = nil
	self.defaultScaleZ = nil
	self.parent = nil
	self.resId = nil
	self.pool = {}
	self.recycleCb = nil
end

return UIObjectPool
