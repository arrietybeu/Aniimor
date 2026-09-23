-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\CTipArea\\PropObtainItem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local PropObtainItem = Class.LightClass("PropObtainItem", BaseQueueItem)
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local WHITE_LIST = {
	1006
}
local POP_SPEED = 0.05
local PROP_OBTAIN_DURATION_CONFIG = {
	minDuration = 1.5,
	decreasePerItem = 0.5,
	defaultDuration = 3
}
local GM_MASK_EXTRA_DURATION = 5

function PropObtainItem.compareItem(a, b)
	local aData = ItemData[a.id]
	local bData = ItemData[b.id]
	local aQuality = aData and aData.quality or 0
	local bQuality = bData and bData.quality or 0

	if aQuality ~= bQuality then
		return bQuality < aQuality
	end

	local aId = tonumber(a.id) or 0
	local bId = tonumber(b.id) or 0

	if aId ~= bId then
		return aId < bId
	end

	local aTemplateId = tonumber(a.templateId) or 0
	local bTemplateId = tonumber(b.templateId) or 0

	return aTemplateId < bTemplateId
end

function PropObtainItem:_ensureStreamRuntimeState()
	if self.streamBatches == nil then
		self.streamBatches = {}
	end

	if self.streamPendingItems == nil then
		self.streamPendingItems = {}
	end
end

function PropObtainItem:onInit()
	self:setMaxLimit(5, true)
	self:setDynamicDurationConfig(PROP_OBTAIN_DURATION_CONFIG)

	self.defaultMaxRunNum = self.maxRunNum
	self.scrollList = self.uWidget

	self:_ensureStreamRuntimeState()

	local sizeDelta = self.scrollList.rectTransform.sizeDelta

	self.defaultSizeDeltaX = sizeDelta.x
	self.defaultSizeDeltaY = sizeDelta.y

	local anchoredPosition = self.scrollList.rectTransform.anchoredPosition

	self.defaultAnchoredPositionX = anchoredPosition.x
	self.defaultAnchoredPositionY = anchoredPosition.y
	self.quickUseOccupiedHeight = nil

	function self.scrollList.luaRenderItem(item, data)
		self:RenderItem(item, data)
	end

	self.nextPopupTime = 0
	self.groupSequence = 0
end

function PropObtainItem:setQuickUseOccupiedHeight(height)
	height = math.max(0, height or 0)

	if self.quickUseOccupiedHeight == height then
		return
	end

	local rectTransform = self.scrollList and self.scrollList.rectTransform

	if IsNil(rectTransform) then
		return
	end

	self.quickUseOccupiedHeight = height

	local defaultX = self.defaultSizeDeltaX or self.defaultSizeDelta and self.defaultSizeDelta.x or rectTransform.sizeDelta.x
	local defaultY = self.defaultSizeDeltaY or self.defaultSizeDelta and self.defaultSizeDelta.y or rectTransform.sizeDelta.y
	local defaultPositionX = self.defaultAnchoredPositionX or self.defaultAnchoredPosition and self.defaultAnchoredPosition.x or rectTransform.anchoredPosition.x
	local defaultPositionY = self.defaultAnchoredPositionY or self.defaultAnchoredPosition and self.defaultAnchoredPosition.y or rectTransform.anchoredPosition.y

	rectTransform.sizeDelta = CS.UnityEngine.Vector2(defaultX, defaultY)
	rectTransform.anchoredPosition = CS.UnityEngine.Vector2(defaultPositionX, defaultPositionY - height)
end

function PropObtainItem:setQuickUseBottomWorldPosition(worldPosition)
	if worldPosition == nil then
		self:setQuickUseOccupiedHeight(0)

		return
	end

	local rectTransform = self.scrollList and self.scrollList.rectTransform

	if IsNil(rectTransform) or IsNil(rectTransform.parent) then
		return
	end

	local localPosition = rectTransform.parent:InverseTransformPoint(worldPosition)
	local defaultPositionY = self.defaultAnchoredPositionY or self.defaultAnchoredPosition and self.defaultAnchoredPosition.y or 0
	local defaultTopY = rectTransform.parent.rect.yMax + defaultPositionY

	self:setQuickUseOccupiedHeight(defaultTopY - localPosition.y)
end

function PropObtainItem:setSharedSlotLimit(limit)
	local nextLimit = self.defaultMaxRunNum

	if limit ~= nil then
		nextLimit = math.min(nextLimit, math.max(0, limit))
	end

	if self.maxRunNum == nextLimit then
		return
	end

	self.maxRunNum = nextLimit

	while #self.runList > self.maxRunNum do
		local recycleData

		for _, data in ipairs(self.runList) do
			if data.propObtainStreamBatchId == nil then
				recycleData = data

				break
			end
		end

		recycleData = recycleData or self.runList[1]

		self:recycleToast(recycleData, true)
	end

	self:onQueuePressureChanged()
end

function PropObtainItem:_nextGroupId()
	self.groupSequence = self.groupSequence + 1

	return self.groupSequence
end

function PropObtainItem:beginStreamBatch(batchId)
	self:_ensureStreamRuntimeState()

	if batchId == nil or self.streamBatches[batchId] ~= nil then
		return false
	end

	self.streamBatches[batchId] = {
		ended = false,
		activeCount = 0,
		pendingCount = 0
	}

	return true
end

function PropObtainItem:appendStreamBatch(batchId, data)
	self:_ensureStreamRuntimeState()

	local batch = self.streamBatches[batchId]

	if batch == nil or batch.ended or type(data) ~= "table" or data.id == nil then
		return false
	end

	local streamData = {}

	for key, value in pairs(data) do
		streamData[key] = value
	end

	streamData.propObtainGroupId = nil
	streamData.propObtainStreamBatchId = batchId
	streamData.removing = nil
	streamData.endTime = nil
	streamData.timeOut = nil
	streamData.streamRecycleSettled = nil

	table.insert(self.streamPendingItems, streamData)

	batch.pendingCount = batch.pendingCount + 1

	self:onQueuePressureChanged()
	self:refreshRunState()

	return true
end

function PropObtainItem:endStreamBatch(batchId)
	self:_ensureStreamRuntimeState()

	local batch = self.streamBatches[batchId]

	if batch == nil or batch.ended then
		return false
	end

	batch.ended = true

	self:_tryFinishStreamBatch(batchId)

	return true
end

function PropObtainItem:_isRunLimitReached()
	return #self.runList >= self.maxRunNum
end

function PropObtainItem:getDynamicDurationThreshold()
	return math.max(self.maxRunNum - 1, 0)
end

function PropObtainItem:getDynamicQueuePressure()
	self:_ensureStreamRuntimeState()

	local itemCount = #self.runList + #self.streamPendingItems

	for _, group in ipairs(self.dataQueue) do
		itemCount = itemCount + #(group.items or EMPTY_TABLE)
	end

	return math.max(itemCount - 1, 0)
end

function PropObtainItem:refreshDynamicDuration()
	if not self.dynamicDurationConfig or self:isTimelineSuspended() then
		return
	end

	for _, data in ipairs(self.runList) do
		if not data.removing then
			self:updateDynamicDuration(data)
		end
	end
end

function PropObtainItem:_tryFinishStreamBatch(batchId)
	self:_ensureStreamRuntimeState()

	local batch = self.streamBatches[batchId]

	if batch == nil or not batch.ended or batch.pendingCount > 0 or batch.activeCount > 0 then
		return
	end

	self.streamBatches[batchId] = nil

	self:refreshRunState()
end

function PropObtainItem:_getMergeKey(data)
	return string.format("%s:%s:%s", tostring(data.id), tostring(data.templateId or ""), tostring(data.petId or ""))
end

function PropObtainItem:_createGroup(groupData)
	local items = {}
	local itemMap = {}
	local readyTime = Time.realSecondCache

	for _, data in ipairs(groupData.items or EMPTY_TABLE) do
		local key = self:_getMergeKey(data)
		local oldData = itemMap[key]

		if oldData then
			oldData.mergeNum = (oldData.mergeNum or 0) + (data.num or 0) + (data.mergeNum or 0)
		else
			data.mergeNum = data.mergeNum or 0
			items[#items + 1] = data
			itemMap[key] = data
		end

		readyTime = math.max(readyTime, Time.realSecondCache + (data.delay or 0))
	end

	if #items == 0 then
		return nil
	end

	table.sort(items, PropObtainItem.compareItem)

	local groupId = self:_nextGroupId()

	for _, data in ipairs(items) do
		data.propObtainGroupId = groupId
	end

	return {
		groupId = groupId,
		source = groupData.source,
		batchType = groupData.batchType,
		readyTime = readyTime,
		items = items
	}
end

function PropObtainItem:pushGroup(groupData)
	local group = self:_createGroup(groupData)

	if group then
		self:enqueue(group)
	end
end

function PropObtainItem:pushData(data)
	if data.items then
		self:pushGroup(data)
	else
		self:pushGroup({
			source = data.source,
			batchType = data.batchType,
			items = {
				data
			}
		})
	end
end

function PropObtainItem:refreshRunState()
	self:_ensureStreamRuntimeState()

	local oldRunState = self.run_state
	local hasQueuedData = #self.dataQueue > 0 or #self.streamPendingItems > 0

	if self:isAreaHidden() then
		self.run_state = (#self.runList > 0 or hasQueuedData) and TipAreaConst.ITEM_RUN_STATE.WAITING or TipAreaConst.ITEM_RUN_STATE.EMPTY
	elseif #self.runList > 0 then
		self.run_state = TipAreaConst.ITEM_RUN_STATE.RUN_QUEUE
	elseif hasQueuedData then
		self.run_state = TipAreaConst.ITEM_RUN_STATE.WAITING
	else
		self.run_state = TipAreaConst.ITEM_RUN_STATE.EMPTY
	end

	if self.run_state ~= oldRunState then
		self:onRunStateChanged(oldRunState, self.run_state)
	end
end

function PropObtainItem:onUpdate()
	self:tryPopupStreamItem()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function PropObtainItem:tryPopupStreamItem()
	self:_ensureStreamRuntimeState()

	if #self.streamPendingItems == 0 or self:_isRunLimitReached() then
		return false
	end

	local now = Time.realSecondCache

	if now < self.nextPopupTime then
		return false
	end

	local data = table.remove(self.streamPendingItems, 1)
	local batchId = data.propObtainStreamBatchId
	local batch = self.streamBatches[batchId]

	if batch == nil then
		self:onQueuePressureChanged()
		self:refreshRunState()

		return false
	end

	batch.pendingCount = math.max(0, batch.pendingCount - 1)
	batch.activeCount = batch.activeCount + 1
	self.nextPopupTime = now + POP_SPEED

	local duration = data.duration or PROP_OBTAIN_DURATION_CONFIG.defaultDuration

	if GmToolUtils.openMask then
		duration = duration + GM_MASK_EXTRA_DURATION
	end

	data.endTime = now + duration

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)

	return true
end

function PropObtainItem:tryPopupItem()
	if self:isQueueEmpty() or self:_isRunLimitReached() then
		return
	end

	local group = self:peek()

	if group == nil then
		return
	end

	if #group.items == 0 then
		self:_tryFinishCurrentGroup()

		return
	end

	local now = Time.realSecondCache

	if now < group.readyTime or now < self.nextPopupTime then
		return
	end

	self.nextPopupTime = now + POP_SPEED

	local data = table.remove(group.items, 1)
	local duration = data.duration or PROP_OBTAIN_DURATION_CONFIG.defaultDuration

	if GmToolUtils.openMask then
		duration = duration + GM_MASK_EXTRA_DURATION
	end

	data.endTime = now + duration

	self:addRunItem(data)
	self.scrollList:PushRenderItem(data)
end

function PropObtainItem:_tryFinishCurrentGroup()
	local group = self:peek()

	if group == nil or #group.items > 0 then
		return
	end

	self:dequeue()
	self:refreshRunState()
end

function PropObtainItem:refreshRemainTime()
	local now = Time.realSecondCache

	for i = #self.runList, 1, -1 do
		local data = self.runList[i]

		if not data.removing and now >= data.endTime then
			self:recycleToast(data)
		end
	end
end

function PropObtainItem:onClearRunningList(force)
	local runNum = #self.runList

	for i = runNum, 1, -1 do
		local data = self.runList[i]

		self:recycleToast(data, true)
	end
end

function PropObtainItem:onClearDataQueue()
	self:_ensureStreamRuntimeState()
	BaseQueueItem.onClearDataQueue(self)
	table.clearArray(self.streamPendingItems)

	self.streamBatches = {}

	self:onQueuePressureChanged()
	self:refreshRunState()
end

function PropObtainItem:onUIVisibleToHide()
	self:clearRunningList(true)
end

function PropObtainItem:recycleToast(data, force)
	self:requestRecycle(data, force, CS.XGUI.EInvokeTime.User2)
end

function PropObtainItem:_onToastRemoved(data)
	self:_ensureStreamRuntimeState()

	local batchId = data.propObtainStreamBatchId

	if batchId ~= nil and not data.streamRecycleSettled then
		data.streamRecycleSettled = true

		local batch = self.streamBatches[batchId]

		if batch then
			batch.activeCount = math.max(0, batch.activeCount - 1)

			self:_tryFinishStreamBatch(batchId)
		end
	end

	self:_tryFinishCurrentGroup()
end

function PropObtainItem:RenderItem(item, data)
	if table.contains(WHITE_LIST, data.id) then
		self:refreshWhiteItem(item, data)
	else
		self:refreshItem(item, data)
	end

	pg.game.audio:triggerEvent("ui_sfx_getitem")
	item:InvokeCallback(CS.XGUI.EInvokeTime.User1)
end

function PropObtainItem:refreshItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local outerFrame = oc:GetRefValue("outerFrame")
	local propIcon = oc:GetRefValue("propIcon")
	local txtName = oc:GetRefValue("txtName")
	local txtNum = oc:GetRefValue("txtNum")

	outerFrame:TryChangePage("tips", 0)

	local cData = ItemData[data.id]

	if cData == nil then
		return
	end

	outerFrame:TryChangePage("quality", data.quality or cData.quality)
	ClientTextUtils.setText(txtName, pg.getLocalizationText(cData.itemName))

	propIcon.url = LuaUIUtils.getIconByIconId(cData.icon)

	local num = (data.num or 0) + (data.mergeNum or 0)

	if num > 0 then
		ClientTextUtils.setText(txtNum, string.format("x%d", num))
	elseif num < 0 then
		ClientTextUtils.setText(txtNum, string.format("%d", num))
	else
		ClientTextUtils.setText(txtNum, "")
	end
end

function PropObtainItem:refreshWhiteItem(item, data)
	local oc = item:GetComponent("ObjectReference")
	local outerFrame = oc:GetRefValue("outerFrame")
	local petIcon = oc:GetRefValue("petIcon")
	local txtPetName = oc:GetRefValue("txtPetName")
	local txtPetNum = oc:GetRefValue("txtPetNum")

	txtPetNum.disabledLocalization = true

	outerFrame:TryChangePage("tips", 1)

	local cData = ItemData[data.id]

	if cData == nil then
		return
	end

	local pData = PetData[data.templateId]

	if pData == nil then
		return
	end

	outerFrame:TryChangePage("quality", data.quality or cData.quality)
	ClientTextUtils.setText(txtPetName, pg.getLocalizationText(data.name or cData.itemName))

	petIcon.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, data.label)

	local num = (data.num or 0) + (data.mergeNum or 0)

	if num > 0 then
		ClientTextUtils.setText(txtPetNum, string.format("x%d", num))
	elseif num < 0 then
		ClientTextUtils.setText(txtPetNum, string.format("%d", num))
	else
		ClientTextUtils.setText(txtPetNum, "")
	end
end

function PropObtainItem:getRecycleTarget(data)
	return self:getListRecycleTarget(data)
end

function PropObtainItem:onRecycleCleanup(data, target, reason)
	self:cleanupRecycleList(data, target, reason)
end

function PropObtainItem:onRecycleFinished(data, reason)
	self:_onToastRemoved(data)
end

return PropObtainItem
