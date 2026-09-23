-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\BaseQueueItem.lua

local Class = require("Core.Framework.Class")
local BaseAreaItem = require("Guis.Panels.Tips.Items.BaseAreaItem")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local UICtrl = require("Guis.UICtrl")
local BaseQueueItem = Class.LightClass("BaseQueueItem", BaseAreaItem)

function BaseQueueItem:onCtor(info)
	self.dataQueue = {}
	self.runList = {}
	self.maxRunNum = 1
	self.longPressProgressContainers = {}

	BaseAreaItem.onCtor(self, info)
end

function BaseQueueItem:setMaxLimit(max, dynamicMax)
	max = max or 1

	if dynamicMax then
		self.maxRunNum = self.uWidget.MaxCount
	else
		self.maxRunNum = max
	end
end

function BaseQueueItem:isReachTheLimit()
	return #self.runList >= self.maxRunNum
end

function BaseQueueItem:pushData(data)
	self:enqueue(data)
end

function BaseQueueItem:enqueue(data)
	table.insert(self.dataQueue, data)
	self:onQueuePressureChanged()
	self:refreshRunState()
end

function BaseQueueItem:dequeue()
	return table.remove(self.dataQueue, 1)
end

function BaseQueueItem:peek()
	return self.dataQueue[1]
end

function BaseQueueItem:isQueueEmpty()
	return #self.dataQueue == 0
end

function BaseQueueItem:onClearRunningList(force)
	for _, v in ipairs(self.runList) do
		v.endTime = 0
	end
end

function BaseQueueItem:clearRecycleRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:recycleToast(data, force)
	end
end

function BaseQueueItem:onClearDataQueue()
	table.clearArray(self.dataQueue)
end

function BaseQueueItem:onTimelineResume(delta, suspendedAt)
	if delta == nil or delta <= 0 then
		return
	end

	suspendedAt = suspendedAt or -math.huge

	for _, data in ipairs(self.runList) do
		if data.endTime and suspendedAt < data.endTime then
			data.endTime = data.endTime + delta
		end

		if data.timeOut and suspendedAt < data.timeOut then
			data.timeOut = data.timeOut + delta
		end
	end

	self:onQueuePressureChanged()
end

function BaseQueueItem:onTimelineSuspendExpired(delta)
	self:clearAllData(true)
end

function BaseQueueItem:addRunItem(item)
	if self.__invalidRecycleContent then
		local invalid = self.__invalidRecycleContent

		if NotNil(self.uContainer) and self.uContainer.content == invalid then
			self.uContainer:DestroyContent()
		end

		self.__invalidRecycleContent = nil
	end

	if self.__recycleTasks[item] then
		self.owner.owner.recycleController:invalidate(self, item)
	end

	if self.__runCallbackGuards then
		self.__runCallbackGuards[item] = nil
	end

	item.removing = nil

	table.insert(self.runList, item)
	self:initDynamicDuration(item)
end

function BaseQueueItem:removeItem(item)
	if self.__recycleTasks[item] then
		self.owner.owner.recycleController:invalidate(self, item)
	end

	if self.__runCallbackGuards then
		self.__runCallbackGuards[item] = nil
	end

	local removed = false

	for i, v in ipairs(self.runList) do
		if v == item then
			table.remove(self.runList, i)

			removed = true

			break
		end
	end

	if removed then
		self:onQueuePressureChanged()
	end

	self:refreshRunState()
end

function BaseQueueItem:firstRunItem()
	if #self.runList == 0 then
		return nil
	end

	return self.runList[1]
end

function BaseQueueItem:setDynamicDurationConfig(config)
	self.dynamicDurationConfig = config
end

function BaseQueueItem:getDynamicQueuePressure()
	return math.max(#self.runList + #self.dataQueue - 1, 0)
end

function BaseQueueItem:getDynamicDurationThreshold()
	return self.dynamicDurationConfig.threshold or 0
end

function BaseQueueItem:getDynamicDuration(defaultDuration)
	local config = self.dynamicDurationConfig

	if not config then
		return defaultDuration
	end

	local overflowCount = math.max(self:getDynamicQueuePressure() - self:getDynamicDurationThreshold(), 0)
	local minDuration = math.min(defaultDuration, config.minDuration or defaultDuration)

	return math.max(defaultDuration - overflowCount * (config.decreasePerItem or 0), minDuration)
end

function BaseQueueItem:onQueuePressureChanged()
	self:refreshDynamicDuration()
end

function BaseQueueItem:getDynamicBaseDuration(data)
	local config = self.dynamicDurationConfig

	return data.duration or config.defaultDuration
end

function BaseQueueItem:applyDynamicDurationDelta(data, delta)
	if data.endTime then
		data.endTime = data.endTime + delta
	end

	if data.timeOut then
		data.timeOut = data.timeOut + delta
	end
end

function BaseQueueItem:initDynamicDuration(data)
	if not self.dynamicDurationConfig then
		return
	end

	data.__dynamicDuration = self:getDynamicBaseDuration(data)

	self:updateDynamicDuration(data)
end

function BaseQueueItem:updateDynamicDuration(data)
	local config = self.dynamicDurationConfig

	if not config or data.removing then
		return
	end

	local baseDuration = self:getDynamicBaseDuration(data)
	local oldDuration = data.__dynamicDuration or baseDuration
	local duration = self:getDynamicDuration(baseDuration)

	data.__dynamicDuration = duration

	if duration == oldDuration then
		return
	end

	self:applyDynamicDurationDelta(data, duration - oldDuration)
end

function BaseQueueItem:refreshDynamicDuration()
	if not self.dynamicDurationConfig or self:isTimelineSuspended() then
		return
	end

	for _, data in ipairs(self.runList) do
		if not data.removing then
			self:updateDynamicDuration(data)

			return
		end
	end
end

function BaseQueueItem:refreshRunState()
	local oldRunState = self.run_state

	if self:isAreaHidden() then
		self.run_state = (#self.runList > 0 or #self.dataQueue > 0) and TipAreaConst.ITEM_RUN_STATE.WAITING or TipAreaConst.ITEM_RUN_STATE.EMPTY
	elseif #self.runList > 0 then
		self.run_state = TipAreaConst.ITEM_RUN_STATE.RUN_QUEUE
	elseif #self.dataQueue > 0 then
		self.run_state = TipAreaConst.ITEM_RUN_STATE.WAITING
	else
		self.run_state = TipAreaConst.ITEM_RUN_STATE.EMPTY
	end

	if self.run_state ~= oldRunState then
		self:onRunStateChanged(oldRunState, self.run_state)
	end
end

function BaseQueueItem:clearHotKeyBindByPath(obj, path)
	if not obj or not path then
		return
	end

	local hotKeyBind = KeyBindingPro.GetKeyBindingByName(obj, path)

	if hotKeyBind then
		hotKeyBind.luaTrigger = nil
		hotKeyBind.enabled = false
	end
end

function BaseQueueItem:bindGamepadLongPressWithProgress(data)
	if not data or IsNil(data.progressContainer) then
		return
	end

	data.progressContainer.forceSyncLoad = true

	data.progressContainer:SetActive(true)
	data.progressContainer:LoadDefaultUrlManually(function(progress)
		if NotNil(data.progressContainer) then
			data.progressContainer:SetActiveQuickly(pg.game.input:isUsingGamepad())
		end

		if IsNil(progress) or IsNil(data.object) then
			return
		end

		progress:ProgressToValue(0, nil, 0)

		local hotKeyBind = UICtrl.bindHotKeyWithProgress(self, data.path, function()
			if data.func then
				data.func()
			end

			progress:ProgressToValue(0, nil, 0)
		end, data.object, progress, function()
			progress:ProgressToValue(0, nil, 0)
		end, {
			gamepadOnly = true,
			priority = data.priority or 100
		})
		local luaTrigger = hotKeyBind.luaTrigger

		function hotKeyBind.luaTrigger(inputInfo)
			if NotNil(data.progressContainer) then
				data.progressContainer:SetActiveQuickly(pg.game.input:isUsingGamepad())
			end

			return luaTrigger(inputInfo)
		end

		if data.onBound then
			data.onBound(hotKeyBind)
		end
	end)
end

function BaseQueueItem:bindHotKeyItemLongPress(objectReference, data)
	if IsNil(objectReference) or not data then
		return
	end

	local progressContainer = objectReference:GetRefValue("progressPressContainerUContainer")

	if IsNil(progressContainer) then
		return
	end

	local enableLongPress = data.longPressFunc ~= nil and NotNil(data.hotKeyObject)

	self.longPressProgressContainers[progressContainer] = enableLongPress

	progressContainer:SetActive(enableLongPress)

	if enableLongPress then
		self:bindGamepadLongPressWithProgress({
			path = data.path or data.actionKey,
			func = data.longPressFunc,
			object = data.hotKeyObject,
			progressContainer = progressContainer,
			priority = data.priority,
			onBound = data.onBound
		})
	end
end

function BaseQueueItem:onInputDeviceChanged()
	local isUsingGamepad = pg.game.input:isUsingGamepad()

	for progressContainer, enableLongPress in pairs(self.longPressProgressContainers) do
		if NotNil(progressContainer) then
			progressContainer:SetActive(enableLongPress)

			if enableLongPress then
				progressContainer:SetActiveQuickly(isUsingGamepad)
			end
		end
	end
end

function BaseQueueItem:bindHotKeyPerform(path, func, obj, bindName, hotKeyContent)
	bindName = bindName or path

	if not obj then
		return
	end

	local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(obj, bindName)

	if hotKeyContent then
		hotKeyBind.keyBoardContent = hotKeyContent
	end

	hotKeyBind.actionPath = path
	hotKeyBind.isVirtual = true

	function hotKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if func then
				return func(self, inputInfo)
			end
		elseif inputInfo.phase == "Checked" then
			return false
		end

		return true
	end
end

function BaseQueueItem:onDestroy()
	self.longPressProgressContainers = {}

	self:onClearDataQueue()
	self:onClearRunningList(true)
end

function BaseQueueItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.Hide)
end

function BaseQueueItem:destroyContent(data, force)
	self:completeRecycle(data, force)
end

function BaseQueueItem:hasRecycleData(data)
	for _, item in ipairs(self.runList) do
		if item == data then
			return true
		end
	end

	return false
end

function BaseQueueItem:removeRecycleData(data)
	self:removeItem(data)
end

function BaseQueueItem:getRecycleTarget(data)
	if NotNil(self.uContainer) then
		return self.uContainer.content
	end
end

function BaseQueueItem:getListRecycleTarget(data)
	if IsNil(self.scrollList) then
		return
	end

	local found, item = self.scrollList:TryGetItem(data)

	if found then
		return item
	end
end

function BaseQueueItem:cleanupRecycleContainer(target, reason, always)
	if NotNil(self.uContainer) and self.uContainer.content == target and (always or reason ~= TipAreaConst.RECYCLE_REASON.NORMAL or self:isQueueEmpty()) then
		self.uContainer:DestroyContent()
	end
end

function BaseQueueItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleContainer(target, reason)
end

function BaseQueueItem:cleanupRecycleList(data, target, reason)
	self.scrollList:DestroyItem(data)
end

function BaseQueueItem:guardRunCallback(data, callback, target)
	self.__runCallbackGuards = self.__runCallbackGuards or {}

	local guards = self.__runCallbackGuards
	local guard = guards[data]

	if not guard then
		guard = {}
		guards[data] = guard
	end

	return function(...)
		if guards[data] ~= guard or data.removing or self.__recycleDestroying or not self:hasRecycleData(data) then
			return
		end

		if target and (IsNil(target) or self.uContainer and self.uContainer.content ~= target) then
			return
		end

		return callback(...)
	end
end

function BaseQueueItem:isRecycleCancelled(reason)
	return reason == TipAreaConst.RECYCLE_REASON.FORCE or reason == TipAreaConst.RECYCLE_REASON.DESTROY or reason == TipAreaConst.RECYCLE_REASON.ERROR
end

function BaseQueueItem:hasRecycleRunningData()
	return #self.runList > 0
end

return BaseQueueItem
