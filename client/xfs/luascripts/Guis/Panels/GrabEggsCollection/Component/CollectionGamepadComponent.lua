-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\Component\\CollectionGamepadComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local RectTransformUtility = CS.UnityEngine.RectTransformUtility
local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3
local CollectionGamepadComponent = Class.LightClass("CollectionGamepadComponent")
local STICK_DEAD_ZONE = 0.55
local NAVIGATE_INTERVAL = 0.25
local ARROW_LOCAL_Y_OFFSET = 0
local ARROW_LOCAL_Y_OFFSET_OVERRIDES = {
	[100106] = -40,
	[100105] = 20,
	[100103] = -40
}
local DEFAULT_BIND_PRIORITY = 10000
local DEFAULT_SLOT_LOCATION = "100106"
local LEFT_STICK_ACTION_PATH = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickMove
local CONFIRM_ACTION_PATH = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth
local NAVIGATION_SLOT_ROWS = {
	{
		100101
	},
	{
		100102,
		100103,
		100104
	},
	{
		100105,
		100106,
		100107
	}
}

function CollectionGamepadComponent:ctor(rootTransform, ctrl, modelComponent)
	self.rootTransform = rootTransform
	self.ctrl = ctrl
	self.modelComponent = modelComponent
	self.panelSelArrow = ctrl and ctrl.view and ctrl.view.panelSelArrow or nil
	self.selectedSlotTransform = nil
	self.leftStickVec = Vector2.zero
	self.nextNavigateTime = 0
	self.updateTimer = nil
	self.leftStickBind = nil
	self.confirmBind = nil
	self.modelInputBindingEnabled = nil
end

function CollectionGamepadComponent:init()
	self:bindInput()
	self:startUpdate()
end

function CollectionGamepadComponent:bindInput()
	local bindObject = self.rootTransform and self.rootTransform.gameObject

	if not bindObject or UIUtils.IsNull(bindObject) then
		return
	end

	self.leftStickBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "grabEggsCollectionLeftStick")
	self.leftStickBind.isVirtual = true
	self.leftStickBind.priority = DEFAULT_BIND_PRIORITY
	self.leftStickBind.actionPath = LEFT_STICK_ACTION_PATH

	function self.leftStickBind.luaTrigger(inputInfo)
		self:onLeftStickInput(inputInfo)

		return self.modelInputBindingEnabled == true
	end

	self.confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(bindObject, "grabEggsCollectionConfirm")
	self.confirmBind.isVirtual = true
	self.confirmBind.priority = DEFAULT_BIND_PRIORITY
	self.confirmBind.actionPath = CONFIRM_ACTION_PATH

	function self.confirmBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			return self:onConfirmInput()
		end

		return self.modelInputBindingEnabled == true
	end

	self:refreshModelInputBindingState()
end

function CollectionGamepadComponent:startUpdate()
	if self.updateTimer then
		return
	end

	self.updateTimer = TimerManager.addRepeatTimer(0, function()
		self:onUpdate()
	end)
end

function CollectionGamepadComponent:stopUpdate()
	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function CollectionGamepadComponent:isUsingGamepad()
	return pg and pg.game and pg.game.input and pg.game.input.isUsingGamepad and pg.game.input:isUsingGamepad() == true
end

function CollectionGamepadComponent:isActive()
	return self:isUsingGamepad() and self.modelComponent and self.modelComponent.interactionEnabled == true
end

function CollectionGamepadComponent:isCollectionDetailStage()
	return self.ctrl and self.ctrl.isCollectionDetailStage and self.ctrl:isCollectionDetailStage() == true
end

function CollectionGamepadComponent:isModelControlActive()
	return self:isActive() and not self:isCollectionDetailStage() and not self:isRewardFocused()
end

function CollectionGamepadComponent:setModelInputBindingEnabled(enabled)
	enabled = enabled == true

	if self.modelInputBindingEnabled == enabled then
		return
	end

	self.modelInputBindingEnabled = enabled

	if self.leftStickBind then
		self.leftStickBind.actionPath = enabled and LEFT_STICK_ACTION_PATH or nil
	end

	if self.confirmBind then
		self.confirmBind.actionPath = enabled and CONFIRM_ACTION_PATH or nil
	end
end

function CollectionGamepadComponent:refreshModelInputBindingState()
	self:setModelInputBindingEnabled(self:isModelControlActive())
end

function CollectionGamepadComponent:resetNavigationInput()
	self.leftStickVec = Vector2.zero
	self.nextNavigateTime = 0
end

function CollectionGamepadComponent:getNodeTransform(node)
	if not node or UIUtils.IsNull(node) then
		return nil
	end

	if node.transform and not UIUtils.IsNull(node.transform) then
		return node.transform
	end

	if node.gameObject and not UIUtils.IsNull(node.gameObject) and node.gameObject.transform and not UIUtils.IsNull(node.gameObject.transform) then
		return node.gameObject.transform
	end

	return nil
end

function CollectionGamepadComponent:isTransformInRoot(transform, root)
	if not transform or not root then
		return false
	end

	if transform == root then
		return true
	end

	local ok, isChild = pcall(function()
		return transform:IsChildOf(root)
	end)

	return ok and isChild == true
end

function CollectionGamepadComponent:isRewardFocusGroupName(groupName)
	if not groupName or groupName == "" then
		return false
	end

	groupName = string.lower(tostring(groupName))

	return string.find(groupName, "reward", 1, true) ~= nil or string.find(groupName, "award", 1, true) ~= nil
end

function CollectionGamepadComponent:isRewardFocused()
	local navMgr = pg and pg.global and pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance

	if navMgr and self:isRewardFocusGroupName(navMgr.CurrentFocusedGroupName) then
		return true
	end

	local focused = navMgr and navMgr.CurrentFocusedUContent
	local focusedTransform = self:getNodeTransform(focused)

	if not focusedTransform then
		return false
	end

	local rewardComponent = self.ctrl and self.ctrl.baseRewardComponent

	if not rewardComponent then
		return false
	end

	if self:isTransformInRoot(focusedTransform, self:getNodeTransform(rewardComponent.rewardPanel)) then
		return true
	end

	if self:isTransformInRoot(focusedTransform, self:getNodeTransform(rewardComponent.rewardList)) then
		return true
	end

	if self:isTransformInRoot(focusedTransform, self:getNodeTransform(rewardComponent.rewardBar)) then
		return true
	end

	if self:isTransformInRoot(focusedTransform, self:getNodeTransform(rewardComponent.finalRewardItem)) then
		return true
	end

	return false
end

function CollectionGamepadComponent:onLeftStickInput(inputInfo)
	if not self:isModelControlActive() then
		self:resetNavigationInput()

		return
	end

	if not inputInfo or inputInfo.phase ~= "Performed" then
		self:resetNavigationInput()

		return
	end

	self.leftStickVec = inputInfo.valueVec2 or Vector2.zero
end

function CollectionGamepadComponent:onConfirmInput()
	if not self:isModelControlActive() then
		return false
	end

	self:ensureSelectedSlot()

	if self.selectedSlotTransform and self.modelComponent and self.modelComponent.triggerSlotClick then
		local detailComponent = self.ctrl and self.ctrl.collectionDetailComponent

		if detailComponent and detailComponent.suppressCollectionItemClick then
			detailComponent:suppressCollectionItemClick()
		end

		self.modelComponent:triggerSlotClick(self.selectedSlotTransform)

		return true
	end

	return false
end

function CollectionGamepadComponent:onUpdate()
	self:refreshModelInputBindingState()

	if not self:isUsingGamepad() or not self.modelComponent then
		self:setArrowVisible(false)
		self:clearSelection()

		return
	end

	self:ensureSelectedSlot()

	if self:isCollectionDetailStage() then
		self:setArrowVisible(false)
		self:resetNavigationInput()

		return
	end

	local isRewardFocused = self:isRewardFocused()

	self:setArrowVisible(not isRewardFocused and self.selectedSlotTransform ~= nil)

	if not isRewardFocused then
		self:updateArrowPosition()
	end

	if self.modelComponent.interactionEnabled ~= true then
		self:resetNavigationInput()

		return
	end

	if isRewardFocused then
		self:resetNavigationInput()

		return
	end

	self:syncSelectedSlotHover()
	self:updateNavigation()
end

function CollectionGamepadComponent:getCurrentTime()
	return Time.unscaledTime
end

function CollectionGamepadComponent:updateNavigation()
	local dirX, dirY = self:getStickDirection()

	if not dirX or not dirY then
		return
	end

	local now = self:getCurrentTime()

	if now < self.nextNavigateTime then
		return
	end

	self.nextNavigateTime = now + NAVIGATE_INTERVAL

	local nextSlot = self:findNextSlotByDirection(dirX, dirY)

	if nextSlot then
		self:setSelectedSlot(nextSlot)
	end
end

function CollectionGamepadComponent:getStickDirection()
	local stick = self.leftStickVec

	if not stick then
		return nil, nil
	end

	local x = stick.x or 0
	local y = stick.y or 0

	if x * x + y * y < STICK_DEAD_ZONE * STICK_DEAD_ZONE then
		return nil, nil
	end

	if math.abs(x) > math.abs(y) then
		return x > 0 and 1 or -1, 0
	end

	return 0, y > 0 and 1 or -1
end

function CollectionGamepadComponent:ensureSelectedSlot()
	if self:isSlotValid(self.selectedSlotTransform) then
		return
	end

	local defaultSlot = self:getDefaultSlot()

	self:setSelectedSlot(defaultSlot)
end

function CollectionGamepadComponent:getDefaultSlot()
	local currentSelectedSlot = self:getCurrentSelectedSlot()

	if currentSelectedSlot then
		return currentSelectedSlot
	end

	local defaultSlot = self:getSlotByLocation(DEFAULT_SLOT_LOCATION)

	if defaultSlot then
		return defaultSlot
	end

	local slots = self:getSelectableSlots()

	return slots[1] and slots[1].slotTransform or nil
end

function CollectionGamepadComponent:getCurrentSelectedSlot()
	if self:isSlotValid(self.selectedSlotTransform) then
		return self.selectedSlotTransform
	end

	local hoveredSlot = self.modelComponent and self.modelComponent.hoveredSlot

	if self:isSlotValid(hoveredSlot) then
		return hoveredSlot
	end

	local detailComponent = self.ctrl and self.ctrl.collectionDetailComponent
	local detailSlot = detailComponent and detailComponent.selectedSlotTransform

	if self:isSlotValid(detailSlot) then
		return detailSlot
	end

	local replaceSlot = self.ctrl and self.ctrl.replaceSlotTransform

	if self:isSlotValid(replaceSlot) then
		return replaceSlot
	end

	return nil
end

function CollectionGamepadComponent:getSlotByLocation(location)
	if not location then
		return nil
	end

	for _, slotInfo in ipairs(self:getSelectableSlots()) do
		local slotConfig = slotInfo.slotConfig

		if slotConfig and slotConfig.location == location then
			return slotInfo.slotTransform
		end
	end

	return nil
end

function CollectionGamepadComponent:getSelectableSlots()
	if not self.modelComponent or not self.modelComponent.getCollectionSlotList then
		return {}
	end

	local slots = {}
	local slotList = self.modelComponent:getCollectionSlotList()

	for _, slotInfo in ipairs(slotList or EMPTY_TABLE) do
		if self:isSlotValid(slotInfo.slotTransform) then
			table.insert(slots, slotInfo)
		end
	end

	return slots
end

function CollectionGamepadComponent:isSlotValid(slotTransform)
	if not slotTransform or UIUtils.IsNull(slotTransform) then
		return false
	end

	local slotData = self.modelComponent and self.modelComponent.slotModels and self.modelComponent.slotModels[slotTransform]

	return slotData and slotData.model ~= nil
end

function CollectionGamepadComponent:setSelectedSlot(slotTransform)
	if self.selectedSlotTransform == slotTransform then
		self:refreshArrowVisibility()
		self:updateArrowPosition()

		return
	end

	self.selectedSlotTransform = slotTransform

	if self.modelComponent and self.modelComponent.syncHoverSlot then
		self.modelComponent:syncHoverSlot(slotTransform)
	end

	self:refreshArrowVisibility()
	self:updateArrowPosition()
end

function CollectionGamepadComponent:syncSelectedSlotHover()
	if not self.selectedSlotTransform or not self.modelComponent or not self.modelComponent.syncHoverSlot then
		return
	end

	if self.modelComponent.hoveredSlot ~= self.selectedSlotTransform then
		self.modelComponent:syncHoverSlot(self.selectedSlotTransform)
	end
end

function CollectionGamepadComponent:clearSelection()
	if self.selectedSlotTransform and self.modelComponent and self.modelComponent.syncHoverSlot then
		self.modelComponent:syncHoverSlot(nil)
	end

	self.selectedSlotTransform = nil

	self:setArrowVisible(false)
	self:resetNavigationInput()
end

function CollectionGamepadComponent:bringSelectionArrowToFront()
	local arrowTransform = self:getNodeTransform(self.panelSelArrow)

	if not arrowTransform then
		return
	end

	arrowTransform:SetAsLastSibling()
end

function CollectionGamepadComponent:setArrowVisible(visible)
	if not self.panelSelArrow or UIUtils.IsNull(self.panelSelArrow) then
		return
	end

	visible = visible == true

	local gameObject = self.panelSelArrow.gameObject or self.panelSelArrow.transform and self.panelSelArrow.transform.gameObject

	if self.panelSelArrow.SetActiveEx then
		self.panelSelArrow:SetActiveEx(visible)
	elseif self.panelSelArrow.SetActive then
		self.panelSelArrow:SetActive(visible)
	elseif gameObject and gameObject.SetActiveEx then
		gameObject:SetActiveEx(visible)
	elseif gameObject then
		gameObject:SetActive(visible)
	end

	if visible then
		self:bringSelectionArrowToFront()
	end
end

function CollectionGamepadComponent:refreshArrowVisibility()
	local visible = self:isUsingGamepad() and not self:isCollectionDetailStage() and not self:isRewardFocused() and self.selectedSlotTransform ~= nil

	self:setArrowVisible(visible)

	if visible then
		self:updateArrowPosition()
	end
end

function CollectionGamepadComponent:getSlotScreenPosition(slotTransform)
	if not self.modelComponent then
		return nil
	end

	local scene = self.modelComponent.scene
	local camera = scene and scene.camera

	if not camera or UIUtils.IsNull(camera) then
		return nil
	end

	if self.modelComponent.getSlotRendererTopScreenPosition then
		local rendererTopPosition = self.modelComponent:getSlotRendererTopScreenPosition(slotTransform, camera)

		if rendererTopPosition then
			return rendererTopPosition
		end
	end

	if self.modelComponent.getSlotBoundsTopScreenPosition then
		return self.modelComponent:getSlotBoundsTopScreenPosition(slotTransform, camera)
	end

	if not self.modelComponent.getSlotBoundsTopWorldPosition then
		return nil
	end

	local worldPos = self.modelComponent:getSlotBoundsTopWorldPosition(slotTransform)

	if not worldPos then
		return nil
	end

	return UIUtils.WorldToScreenPoint(worldPos, camera)
end

function CollectionGamepadComponent:getSceneCamera()
	local scene = self.modelComponent and self.modelComponent.scene
	local camera = scene and scene.camera

	if not camera or UIUtils.IsNull(camera) then
		return nil
	end

	return camera
end

function CollectionGamepadComponent:getSlotNavigationScreenPosition(slotTransform)
	if not slotTransform or UIUtils.IsNull(slotTransform) then
		return nil
	end

	local camera = self:getSceneCamera()

	if not camera then
		return nil
	end

	return UIUtils.WorldToScreenPoint(slotTransform.position, camera)
end

function CollectionGamepadComponent:buildNavigationRows()
	local slotInfoById = {}

	for _, slotInfo in ipairs(self:getSelectableSlots()) do
		if slotInfo.slotId then
			local screenPos = self:getSlotNavigationScreenPosition(slotInfo.slotTransform)

			slotInfoById[slotInfo.slotId] = {
				slotId = slotInfo.slotId,
				slotTransform = slotInfo.slotTransform,
				screenPos = screenPos
			}
		end
	end

	local rows = {}

	for rowIndex, rowSlotIds in ipairs(NAVIGATION_SLOT_ROWS) do
		local row = {}

		for itemIndex, slotId in ipairs(rowSlotIds) do
			local slotItem = slotInfoById[slotId]

			if slotItem then
				if not slotItem.screenPos then
					slotItem.screenPos = Vector2(itemIndex, -rowIndex)
				end

				table.insert(row, slotItem)
			end
		end

		if #row > 0 then
			table.insert(rows, row)
		end
	end

	return rows
end

function CollectionGamepadComponent:findSlotInRows(rows, slotTransform)
	for rowIndex, row in ipairs(rows or EMPTY_TABLE) do
		for itemIndex, slotItem in ipairs(row) do
			if slotItem.slotTransform == slotTransform then
				return rowIndex, itemIndex, slotItem
			end
		end
	end

	return nil, nil, nil
end

function CollectionGamepadComponent:findNearestSlotInRow(row, screenX)
	local nearestSlot, nearestDistance

	for _, slotItem in ipairs(row or EMPTY_TABLE) do
		local distance = math.abs((slotItem.screenPos.x or 0) - (screenX or 0))

		if not nearestDistance or distance < nearestDistance then
			nearestDistance = distance
			nearestSlot = slotItem.slotTransform
		end
	end

	return nearestSlot
end

function CollectionGamepadComponent:findLowerRowBoundarySlot(rows, currentRowIndex, dirX)
	local targetRow = rows and rows[currentRowIndex + 1]

	if not targetRow or #targetRow <= 0 then
		return nil
	end

	if dirX < 0 then
		return targetRow[1].slotTransform
	end

	return targetRow[#targetRow].slotTransform
end

function CollectionGamepadComponent:findNextSlotByDirection(dirX, dirY)
	if not self.selectedSlotTransform then
		return self:getDefaultSlot()
	end

	local rows = self:buildNavigationRows()
	local currentRowIndex, currentItemIndex, currentSlotItem = self:findSlotInRows(rows, self.selectedSlotTransform)

	if not currentRowIndex or not currentItemIndex or not currentSlotItem then
		return self:getDefaultSlot()
	end

	if dirX ~= 0 then
		local currentRow = rows[currentRowIndex]
		local nextItem = currentRow and currentRow[currentItemIndex + dirX]

		if nextItem then
			return nextItem.slotTransform
		end

		return self:findLowerRowBoundarySlot(rows, currentRowIndex, dirX)
	end

	if dirY ~= 0 then
		local targetRowIndex = currentRowIndex + (dirY > 0 and -1 or 1)
		local targetRow = rows[targetRowIndex]

		if not targetRow then
			return nil
		end

		return self:findNearestSlotInRow(targetRow, currentSlotItem.screenPos.x)
	end

	return nil
end

function CollectionGamepadComponent:updateArrowPosition()
	if not self.panelSelArrow or UIUtils.IsNull(self.panelSelArrow) then
		return
	end

	if not self.selectedSlotTransform then
		return
	end

	local scene = self.modelComponent and self.modelComponent.scene
	local camera = scene and scene.camera

	if not camera or UIUtils.IsNull(camera) then
		return
	end

	local arrowTransform = self.panelSelArrow.transform or self.panelSelArrow.gameObject and self.panelSelArrow.gameObject.transform

	if not arrowTransform or UIUtils.IsNull(arrowTransform) then
		return
	end

	local parentRect = arrowTransform.parent

	if not parentRect or UIUtils.IsNull(parentRect) then
		return
	end

	local screenPos = self:getSlotScreenPosition(self.selectedSlotTransform)

	if not screenPos then
		return
	end

	local _, localPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRect, screenPos, CS.XGUI.UWidget.uiCamera)
	local slotData = self.modelComponent and self.modelComponent.slotModels and self.modelComponent.slotModels[self.selectedSlotTransform]
	local slotId = slotData and slotData.slotId
	local arrowYOffset = ARROW_LOCAL_Y_OFFSET_OVERRIDES[slotId] or ARROW_LOCAL_Y_OFFSET

	arrowTransform.localPosition = Vector3(localPos.x, localPos.y + arrowYOffset, arrowTransform.localPosition.z)
end

function CollectionGamepadComponent:destroy()
	self:stopUpdate()
	self:clearSelection()

	if self.leftStickBind then
		self.leftStickBind.luaTrigger = nil
		self.leftStickBind.actionPath = nil
		self.leftStickBind = nil
	end

	if self.confirmBind then
		self.confirmBind.luaTrigger = nil
		self.confirmBind.actionPath = nil
		self.confirmBind = nil
	end

	self.rootTransform = nil
	self.ctrl = nil
	self.modelComponent = nil
	self.panelSelArrow = nil
end

return CollectionGamepadComponent
