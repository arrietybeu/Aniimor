-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\UIView.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("UIView")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIView = Class.LightClass("UIView")
local MAX_BATCH_COUNT = 128

UIView.DESTROY_DELAY_FRAME = 4

function UIView:ctor(mediator, uid)
	self.mediator = mediator
	self.uid = uid
	self.transform = mediator.transform
	self.gameObject = mediator.gameObject
	self.widget = self.transform:GetComponent("UWidget")
	self.asyncTaskIdMap = {}
	self._instantiatePrefabs = {}

	local ok = ClientUtils.tryWithLogError(function()
		self:findObjects()
		self:registerObjects()
		self:initView()
	end)
end

function UIView:destroy(hasUISceneBlackCover)
	self:onDestroy()
	self:cancelAllUIAsyncTask()
	self:destroyAllInstance()
	pg.global.uiMgr:RemoveAssetRef(self.uid)

	if NotNil(self.widget) then
		self.widget.visibility = CS.XGUI.EVisibility.HitTestInvisible

		if self.widget.ClearCloseCor then
			self.widget:ClearCloseCor()
		end
	end

	if hasUISceneBlackCover then
		self:delayDestroyUIView()
	else
		local uid = self.uid

		pg.global.ui:markUIPendingDestroy(uid)
		TimerManager.addSpecificFrameCb(UIView.DESTROY_DELAY_FRAME, false, function()
			self:delayDestroyUIView()
			pg.global.ui:clearUIPendingDestroy(uid)
		end)
	end

	self.transform = nil
	self.gameObject = nil
	self.widget = nil
	self.uid = nil
end

function UIView:delayDestroyUIView()
	if NotNil(self.mediator) then
		pg.global.uiMgr:DestroyUIView(self.mediator)
	end

	self.mediator = nil
end

function UIView:setViewVisible(visible)
	if NotNil(self.widget) then
		self.widget:SetActiveFastest(visible)
	end
end

function UIView:setViewVisibleByOutOfView(visible)
	if NotNil(self.widget) then
		self.widget:SetPanelActiveByOutOfView(visible)
	end
end

function UIView:findObjects()
	return
end

function UIView:registerObjects()
	return
end

function UIView:initView()
	return
end

function UIView:onDestroy()
	return
end

function UIView:cancelUIAsyncTask(taskId)
	if taskId == nil or taskId == 0 then
		return
	end

	local slot = self.asyncTaskIdMap[taskId]

	if slot then
		if slot.isBatch then
			slot.completed = (slot.completed or 0) + 1

			if slot.completed >= (slot.total or 0) and slot.taskIds ~= nil then
				for i = 0, slot.taskIds.Length - 1 do
					local tid = slot.taskIds[i]

					if tid ~= 0 then
						self.asyncTaskIdMap[tid] = nil
					end
				end

				slot.taskIds = nil
			end
		else
			slot.view = nil
			slot.callback = nil
			slot.resID = nil
		end
	end

	self.asyncTaskIdMap[taskId] = nil

	pg.global.uiMgr:CancelUIAsyncTask(taskId)
end

function UIView:cancelAllUIAsyncTask()
	for taskId, slot in pairs(self.asyncTaskIdMap) do
		if slot then
			slot.view = nil
			slot.callback = nil
			slot.resID = nil
		end

		pg.global.uiMgr:CancelUIAsyncTask(taskId)
	end

	self.asyncTaskIdMap = {}
end

function UIView:setViewOrder(index)
	self.transform:SetSiblingIndex(index)
	self:onChangeDepth(index)
end

function UIView:onChangeDepth(depth)
	return
end

function UIView:adjustDepth(depth)
	if NotNil(self.canvas) then
		self.canvas.sortingOrder = depth
	end
end

function UIView:getCurDepth()
	if NotNil(self.canvas) then
		return self.canvas.sortingOrder
	else
		return 0
	end
end

function UIView:addPrefabWithPathAsync(parent, resID, callback, urgent, ignoreWhileNoParent, priority)
	if string.isNilOrEmpty(resID) then
		return
	end

	parent = parent or self.transform

	if IsNil(parent) then
		return
	end

	local uiMgr = pg.global.uiMgr

	urgent = urgent or false
	ignoreWhileNoParent = ignoreWhileNoParent or false
	priority = priority or 2
	self.asyncTaskIdMap = self.asyncTaskIdMap or {}

	local slot = {
		view = self,
		callback = callback,
		resID = resID
	}
	local taskId = 0

	taskId = uiMgr:InstantiateItem(resID, parent.transform, function(gameObject)
		local view = slot.view

		if view == nil then
			if NotNil(gameObject) then
				uiMgr:DestroyItem(gameObject)
			end

			slot.callback = nil
			slot.resID = nil

			return
		end

		local cb = slot.callback
		local rid = slot.resID

		view:addRefInstance(gameObject, rid)

		if taskId ~= 0 then
			view.asyncTaskIdMap[taskId] = nil
		end

		slot.view = nil
		slot.callback = nil
		slot.resID = nil

		if cb then
			local item = {}

			item.gameObject = gameObject
			item.transform = gameObject and gameObject.transform

			cb(item)
		end
	end, urgent, ignoreWhileNoParent, priority)

	if taskId ~= 0 then
		self.asyncTaskIdMap[taskId] = slot
	end

	return taskId
end

function UIView:cancelLoadTask(taskId)
	self:cancelUIAsyncTask(taskId)
end

function UIView:addPrefabWithPathAsyncBatch(parent, resID, count, callback, urgent, ignoreWhileNoParent, priority, createInactive)
	if string.isNilOrEmpty(resID) or not count or count <= 0 then
		return nil
	end

	if count > MAX_BATCH_COUNT then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("addPrefabWithPathAsyncBatch count too large, resID=%s count=%s clamp=%s", resID, count, MAX_BATCH_COUNT))
		end

		count = MAX_BATCH_COUNT
	end

	parent = parent or self.transform

	if IsNil(parent) then
		return nil
	end

	local uiMgr = pg.global.uiMgr

	urgent = urgent or false
	ignoreWhileNoParent = ignoreWhileNoParent or false
	priority = priority or 2
	createInactive = createInactive or false
	self.asyncTaskIdMap = self.asyncTaskIdMap or {}

	local sharedSlot = {
		completed = 0,
		isBatch = true,
		view = self,
		callback = callback,
		resID = resID,
		total = count
	}

	local function sharedCallback(gameObject)
		local view = sharedSlot.view

		if view == nil then
			if NotNil(gameObject) then
				uiMgr:DestroyItem(gameObject)
			end
		else
			local cb = sharedSlot.callback
			local rid = sharedSlot.resID

			view:addRefInstance(gameObject, rid)

			if cb then
				local item = {}

				item.gameObject = gameObject
				item.transform = gameObject and gameObject.transform

				cb(item)
			end
		end

		sharedSlot.completed = sharedSlot.completed + 1

		if sharedSlot.completed >= sharedSlot.total and sharedSlot.taskIds ~= nil and view ~= nil then
			local map = view.asyncTaskIdMap

			for i = 0, sharedSlot.taskIds.Length - 1 do
				local tid = sharedSlot.taskIds[i]

				if tid ~= 0 then
					map[tid] = nil
				end
			end

			sharedSlot.taskIds = nil
		end
	end

	local taskIds = uiMgr:InstantiateItemBatch(resID, parent.transform, count, sharedCallback, urgent, ignoreWhileNoParent, priority, createInactive)

	if taskIds == nil then
		return sharedSlot
	end

	if sharedSlot.completed >= sharedSlot.total then
		return sharedSlot
	end

	sharedSlot.taskIds = taskIds

	for i = 0, taskIds.Length - 1 do
		local taskId = taskIds[i]

		if taskId ~= 0 then
			self.asyncTaskIdMap[taskId] = sharedSlot
		end
	end

	return sharedSlot
end

function UIView:cancelBatch(handle)
	if handle == nil or not handle.isBatch or handle.view == nil then
		return
	end

	if handle.view ~= self then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UIView:cancelBatch handle does not belong to this view, ignored")
		end

		return
	end

	handle.view = nil
	handle.callback = nil
	handle.resID = nil

	if handle.taskIds ~= nil then
		local uiMgr = pg.global.uiMgr

		for i = 0, handle.taskIds.Length - 1 do
			local tid = handle.taskIds[i]

			if tid ~= 0 and self.asyncTaskIdMap[tid] then
				self.asyncTaskIdMap[tid] = nil

				uiMgr:CancelUIAsyncTask(tid)
			end
		end

		handle.taskIds = nil
	end
end

function UIView:addPrefabWithPathSync(parent, resID)
	if IsNil(parent) or not resID then
		return
	end

	local uiMgr = pg.global.uiMgr
	local gameObject = uiMgr:SyncInstantiateItem(resID, parent.transform)

	self:addRefInstance(gameObject, resID)

	local item = {}

	item.gameObject = gameObject
	item.transform = gameObject and item.gameObject.transform

	return item
end

function UIView:addRefInstance(instance, resID)
	if NotNil(instance) then
		table.insert(self._instantiatePrefabs, {
			instance,
			resID
		})
	end
end

function UIView:destroyInstance(instance)
	if NotNil(instance) then
		local exists, index = self:checkInstanceExists(instance)

		if exists then
			table.remove(self._instantiatePrefabs, index)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UIView:destroyInstance instance not in instance list. [uid]:", self.uid, debug.traceback())
		end

		pg.global.uiMgr:DestroyItem(instance)
	end
end

function UIView:checkInstanceExists(instance)
	for index, instInfo in ipairs(self._instantiatePrefabs) do
		local inst, _ = unpack(instInfo)

		if inst == instance then
			return true, index
		end
	end

	return false
end

function UIView:destroyAllInstance()
	for _, instInfo in pairs(self._instantiatePrefabs) do
		local inst, resID = unpack(instInfo)
		local ok, errors = ClientUtils.tryWithLogError(function()
			if NotNil(inst) then
				pg.global.uiMgr:DestroyItem(inst)
			end
		end)

		if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("UIView:destroyAllInstance failed", self.uid, resID)
		end
	end

	self._instantiatePrefabs = {}
end

return UIView
