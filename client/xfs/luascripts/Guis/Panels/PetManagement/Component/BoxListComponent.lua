-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\Component\\BoxListComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BoxListComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local BoxListComponent = Class.LightClass("BoxListComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ID_BOX_LIST_HOVER = "boxListHover"

BoxListComponent.HOVER_TIME = 1
BoxListComponent.BOX_LIST_MOVE_SPEED = 40

function BoxListComponent:findObjects()
	self.boxList = self.view.boxList
	self.boxListAlter = self.view.listBoxUList
	self.topSliderUButton = self.view.topSliderUButton
	self.botSliderUButton = self.view.botSliderUButton
	self.topAlterSliderUButton = self.view.topAlterSliderUButton
	self.botAlterSliderUButton = self.view.botAlterSliderUButton
	self.aniOnlyShowInFirst = true
	self.hoverTimer = nil
	self.boxListHoveringMoveFlag = false
	self.boxListHoveringDir = 1
	self.boxListAlterHoveringMoveFlag = false
	self.boxListAlterHoveringDir = 1

	self:showAlterBoxList(false)
end

function BoxListComponent:initView()
	self:addListener()
	self:refreshBoxList()
end

function BoxListComponent:addListener()
	return
end

function BoxListComponent:refreshBoxList()
	local boxSequence = self.model:getBoxSequenceInfo()

	function self.boxList.luaRenderItem(button, index, data)
		self:setBoxListData(button, index, data)
	end

	function self.topSliderUButton.luaHover()
		self:hoveringMove(self.boxList, 0, false)
	end

	function self.topSliderUButton.luaUnhover()
		self:hoveringMove(self.boxList, nil, true)
	end

	function self.botSliderUButton.luaHover()
		self:hoveringMove(self.boxList, -1, false)
	end

	function self.botSliderUButton.luaUnhover()
		self:hoveringMove(self.boxList, nil, true)
	end

	function self.boxListAlter.luaRenderItem(button, index, data)
		self:setAlterBoxListData(button, index, data)
	end

	function self.topAlterSliderUButton.luaHover()
		self:hoveringMove(self.boxListAlter, 0, false)
	end

	function self.topAlterSliderUButton.luaUnhover()
		self:hoveringMove(self.boxListAlter, nil, true)
	end

	function self.botAlterSliderUButton.luaHover()
		self:hoveringMove(self.boxListAlter, -1, false)
	end

	function self.botAlterSliderUButton.luaUnhover()
		self:hoveringMove(self.boxListAlter, nil, true)
	end

	function self.boxList.luaFinishRender(_)
		local selectBoxId = self.model:getSelectBoxId()

		self:refreshBoxSelectedStatus(selectBoxId)
	end

	if self.aniOnlyShowInFirst then
		self.boxList:SetEnableCustomInterval(true)

		self.aniOnlyShowInFirst = nil
	else
		self.boxList:SetEnableCustomInterval(false)
	end

	self.boxList:SetList(boxSequence)
	self.boxListAlter:SetList(boxSequence)

	local parent = self.boxList.transform:Find("View")

	self.topSliderUButton.transform.parent = parent
	self.botSliderUButton.transform.parent = parent

	self.topSliderUButton.transform:SetSiblingIndex(0)
	self.botSliderUButton.transform:SetSiblingIndex(0)

	parent = self.boxListAlter.transform:Find("View")
	self.topAlterSliderUButton.transform.parent = parent
	self.botAlterSliderUButton.transform.parent = parent

	self.topAlterSliderUButton.transform:SetSiblingIndex(0)
	self.botAlterSliderUButton.transform:SetSiblingIndex(0)
end

function BoxListComponent:setBoxListData(button, _, data)
	button.name = "Box" .. data.index

	local objectReference = button:GetComponent("ObjectReference")
	local petNumUText = objectReference:GetRefValue("petNumUText")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local boxPetInfo = pg.me.petBoxMap[data.index]
	local customName = boxPetInfo.customName
	local count = boxPetInfo.count or 0
	local slotCount = boxPetInfo.slotCount
	local lockState = PetManagementUtils.getBoxLockState(boxPetInfo)
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = customName
	else
		boxNameContent = pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.index
	end

	ClientTextUtils.setText(txtNameUText, boxNameContent)
	ClientTextUtils.setText(petNumUText, count)
	button:TryChangePage("Lock", lockState)

	if slotCount <= count then
		button:TryChangePage("BoxState", 2)
	elseif count <= 0 then
		button:TryChangePage("BoxState", 1)
	else
		button:TryChangePage("BoxState", 0)
	end

	function button.luaHover()
		self:onHover(button)
	end

	function button.luaUnhover()
		self:onUnHover(button)
	end

	function button.luaBeginDrag()
		self:beginDrag(button, data)
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:endDrag(button, dropWidget, rayBox)
		self:clearDraggingInfo()
	end

	function button.luaEndDragSimulate()
		return
	end

	function button.luaClearDragSimulate()
		button:TryChangePage("DragState", 0)

		local objectReference1 = button:GetComponent("ObjectReference")
		local selUImage = objectReference1:GetRefValue("selUImage")

		selUImage.renderOpacity = 1
	end

	function button.luaPress()
		self:boxPressEvent(data)
	end

	self.model:redDot_SetBoxRedDot(data.index, button)
	button:TryChangePage("DragState", 0)
end

function BoxListComponent:setAlterBoxListData(button, _, data)
	button.name = "Box" .. data.index

	local objectReference = button:GetComponent("ObjectReference")
	local petNumUText = objectReference:GetRefValue("petNumUText")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local boxPetInfo = pg.me.petBoxMap[data.index]
	local customName = boxPetInfo.customName
	local count = boxPetInfo.count or 0
	local slotCount = boxPetInfo.slotCount
	local lockState = PetManagementUtils.getBoxLockState(boxPetInfo)
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = customName
	else
		boxNameContent = pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.index
	end

	ClientTextUtils.setText(txtNameUText, boxNameContent)
	ClientTextUtils.setText(petNumUText, count)
	button:TryChangePage("Lock", lockState)

	if slotCount <= count then
		button:TryChangePage("BoxState", 2)
	elseif count <= 0 then
		button:TryChangePage("BoxState", 1)
	else
		button:TryChangePage("BoxState", 0)
	end

	function button.luaHover()
		self:onHover(button)
	end

	function button.luaUnhover()
		self:onUnHover(button)
	end

	self.model:redDot_SetBoxRedDot(data.index, button)
	button:TryChangePage("DragState", 0)

	button.navForceNonInteractable = self._alterBoxListVisible ~= true
end

function BoxListComponent:showAlterBoxList(show)
	self.boxListAlter:InvokeCallback(show and CS.XGUI.EInvokeTime.Custom1 or CS.XGUI.EInvokeTime.Custom2)

	self._alterBoxListVisible = show and true or false

	local btns = self.boxListAlter:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i].navForceNonInteractable = not self._alterBoxListVisible
	end
end

function BoxListComponent:boxPressEvent(data)
	self:refreshBoxSelectedStatus(data.index)
	self:switchBoxToIdx(data.index)
end

function BoxListComponent:clearAllSelectFrames()
	local boxButtons = self.boxList:GetAllButtons()

	for i = 0, boxButtons.Length - 1 do
		boxButtons[i]:TryChangePage("select", 0)
	end
end

function BoxListComponent:refreshBoxSelectedStatus(boxId)
	local boxButtons = self.boxList:GetAllButtons()
	local boxIndex = self:getBoxIndexByBoxId(boxId)

	if boxIndex == nil then
		return
	end

	local res = tonumber(boxIndex) - 1

	self:clearAllSelectFrames()
	boxButtons[res]:TryChangePage("select", 1)
end

function BoxListComponent:getBoxIndexByBoxId(boxId)
	local petBoxMapSequence = pg.me.petBoxMap.sequence

	for i = 1, #petBoxMapSequence do
		if boxId == petBoxMapSequence[i] then
			return i
		end
	end

	return nil
end

function BoxListComponent:beginDrag(button, data)
	local boxPetInfo = pg.me.petBoxMap[data.index]

	if boxPetInfo and boxPetInfo:isTempLocked() then
		pg.global.showBubbleMessageRaw(pg.getGameString("BATTLEPASS_PET_BOX_SEQ_ERROR"))

		return
	end

	self.ctrl:setIsDragging(true)

	button.replicaWidget.name = button.name
	self.ctrl.draggingReplicaWidget = button.replicaWidget
	self.ctrl.draggingReplicaWidgetType = self.ctrl.DRAGGING_REPLICA_WIDGET.BOX_LIST_CARD

	local objectReference = button.replicaWidget:GetComponent("ObjectReference")
	local petNumUText = objectReference:GetRefValue("petNumUText")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local boxPetMap = pg.me.petBoxMap[data.index]
	local customName = boxPetMap.customName
	local count = boxPetMap.count
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = customName
	else
		boxNameContent = pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.index
	end

	ClientTextUtils.setText(txtNameUText, boxNameContent)
	ClientTextUtils.setText(petNumUText, count)
	button:TryChangePage("DragState", 2)
	button.replicaWidget:TryChangePage("DragState", 1)

	local objectReference1 = button:GetComponent("ObjectReference")
	local selUImage = objectReference1:GetRefValue("selUImage")

	selUImage.renderOpacity = 0
end

function BoxListComponent:endDrag(button, dropWidget, rayBox)
	button:TryChangePage("DragState", 0)

	local objectReference1 = button:GetComponent("ObjectReference")
	local selUImage = objectReference1:GetRefValue("selUImage")

	selUImage.renderOpacity = 1

	if rayBox == nil then
		return
	end

	if rayBox.gameObject.name ~= "PetBoxRayBox" then
		return
	end

	local curBoxId = tonumber(string.sub(button.name, 4))
	local curIndex = self:getBoxIndexByBoxId(curBoxId)

	if curIndex == nil then
		return
	end

	local targetBoxId = tonumber(string.sub(dropWidget.name, 4))
	local targetIndex = self:getBoxIndexByBoxId(targetBoxId)

	if targetIndex == nil then
		return
	end

	local curBoxInfo = pg.me.petBoxMap[curBoxId]
	local targetBoxInfo = pg.me.petBoxMap[targetBoxId]

	if curBoxInfo and curBoxInfo:isTempLocked() or targetBoxInfo and targetBoxInfo:isTempLocked() then
		pg.global.showBubbleMessageRaw(pg.getGameString("BATTLEPASS_PET_BOX_SEQ_ERROR"))

		return
	end

	self:switchBox(curIndex, targetIndex)
end

function BoxListComponent:clearDraggingInfo()
	self.ctrl.draggingReplicaWidget = nil

	self.ctrl:setIsDragging(false)

	self.ctrl.draggingReplicaWidgetType = nil
end

function BoxListComponent:onHover(button)
	if not self.ctrl then
		return
	end

	local STATE = self.ctrl.CONSOLE_BAR_STATE

	self.ctrl:recordHoveredButton(self, button, false)
	self.ctrl:setConsoleBarState(STATE.IN_EMPTY_PET_BOX, false)
	self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, false)
	self.ctrl:setConsoleBarState(STATE.CAN_DROP, false)

	local objectReference = button:GetComponent("ObjectReference")

	if not self.ctrl.isDragging then
		if button.draggable == true then
			self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, true)
		end

		return
	end

	if not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.BOX_LIST_CARD) then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 3)
		button:TryChangePage("DragState", 4)
		self.ctrl:setConsoleBarState(STATE.CAN_DROP, true)
	end

	if self.ctrl.boxPets.draggingPetId then
		button:TryChangePage("DragType", 1)

		if self.hoverTimer then
			self.ctrl:killTimer(self.hoverTimer)

			self.hoverTimer = nil

			DoTweenAnimMgr.Kill(button.transform.gameObject, LuaUIUtils.TweenId(ID_BOX_LIST_HOVER))
		end

		self.hoverTimer = self.ctrl:startTimer(function()
			if self.ctrl.inFilterMode then
				return
			end

			local toBoxId = tonumber(string.sub(button.name, 4))

			if toBoxId then
				if not self.ctrl.boxPets:prepareDraggingPetTemporaryStorageForBoxSwitch() then
					return
				end

				self:switchBoxToIdx(toBoxId, true)
			end
		end, BoxListComponent.HOVER_TIME)

		DoTweenAnimMgr.DoFloat(button.transform.gameObject, 0, 1, LuaUIUtils.TweenId(ID_BOX_LIST_HOVER), BoxListComponent.HOVER_TIME, 0, CS.DG.Tweening.Ease.__CastFrom(1), function()
			return
		end, function(val)
			self.ctrl:refreshBoxListBtnHoverPro(val)
		end, function()
			return
		end, false)
	else
		button:TryChangePage("DragType", 0)
		DoTweenAnimMgr.Kill(button.transform.gameObject, LuaUIUtils.TweenId(ID_BOX_LIST_HOVER))
	end
end

function BoxListComponent:onUnHover(button)
	if not self.ctrl then
		return
	end

	local STATE = self.ctrl.CONSOLE_BAR_STATE

	self.ctrl:clearHoveredButton(self, button)
	self.ctrl:setConsoleBarState(STATE.CAN_START_DRAG, false)
	self.ctrl:setConsoleBarState(STATE.CAN_DROP, false)
	self.ctrl:setConsoleBarState(STATE.IN_EMPTY_PET_BOX, false)

	if self.ctrl.isDragging == true and not IsNil(self.ctrl.draggingReplicaWidget) and self.ctrl.draggingReplicaWidget.name ~= button.name and (self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.PET_BOX_CARD or self.ctrl.draggingReplicaWidgetType == self.ctrl.DRAGGING_REPLICA_WIDGET.BOX_LIST_CARD) then
		self.ctrl.draggingReplicaWidget:TryChangePage("DragState", 1)
		button:TryChangePage("DragState", 0)
	end

	if self.ctrl.boxPets.draggingPetId then
		self.ctrl:refreshBoxListBtnHoverPro(0)

		if self.hoverTimer then
			self.ctrl:killTimer(self.hoverTimer)

			self.hoverTimer = nil

			DoTweenAnimMgr.Kill(button.transform.gameObject, LuaUIUtils.TweenId(ID_BOX_LIST_HOVER))
		end
	end
end

function BoxListComponent:resetDragState()
	local boxButtons = self.boxList:GetAllButtons()

	for i = 0, boxButtons.Length - 1 do
		boxButtons[i]:TryChangePage("DragState", 0)
	end

	boxButtons = self.boxListAlter:GetAllButtons()

	for i = 0, boxButtons.Length - 1 do
		boxButtons[i]:TryChangePage("DragState", 0)
	end
end

function BoxListComponent:switchBoxToIdx(index, isHoverIn)
	self.ctrl.boxPets:clearCurBoxPetNewTags()

	local navSwitchFocusSlot = self.ctrl.boxPets:beginNavSwitchBoxFocusKeep()

	self.model:setSelectBoxId(index)
	self.ctrl:refreshPetBox(isHoverIn)
	self.ctrl.boxPets:endNavSwitchBoxFocusKeep(navSwitchFocusSlot, false)
	self.view.animationWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function BoxListComponent:switchBox(fromIndex, toIndex)
	local sequence = pg.me.petBoxMap.sequence
	local from = sequence[fromIndex]
	local to = sequence[toIndex]

	sequence[toIndex] = from
	sequence[fromIndex] = to

	pg.me:serverMsg("RPC_CS_PetBoxUpdateSequence", sequence:getRawTable())
end

function BoxListComponent:muteBoxButtons(mute)
	local boxButtons = self.boxList:GetAllButtons()

	for i = 0, boxButtons.Length - 1 do
		boxButtons[i].interactable = not mute
		boxButtons[i].draggable = not mute
	end
end

function BoxListComponent:hideFilterWhenSwitchBackToBoxList()
	if not self.ctrl.inFilterMode then
		return
	end

	self.view.btnCleanFilterUButton.luaClick()
end

function BoxListComponent:destroyAll()
	if self.hoverTimer then
		self.ctrl:killTimer(self.hoverTimer)

		self.hoverTimer = nil
	end

	self.boxListHoveringMoveFlag = false
	self.boxListAlterHoveringMoveFlag = false
end

function BoxListComponent:tick()
	if not self.ctrl.boxPets.draggingPetId then
		return
	end

	if self.boxListHoveringMoveFlag then
		if self.boxList:IsReachBound(self.boxListHoveringDir ~= 1) then
			self.boxList:StopScroll()

			self.boxListHoveringMoveFlag = false
		end

		local curPos = self.boxList.content.transform.anchoredPosition

		self.boxList.content.transform.anchoredPosition = curPos + Vector2(0, BoxListComponent.BOX_LIST_MOVE_SPEED * self.boxListHoveringDir)
	end

	if self.boxListAlterHoveringMoveFlag then
		if self.boxListAlter:IsReachBound(self.boxListAlterHoveringDir ~= 1) then
			self.boxListAlter:StopScroll()

			self.boxListAlterHoveringMoveFlag = false
		end

		local curPos = self.boxListAlter.content.transform.anchoredPosition

		self.boxListAlter.content.transform.anchoredPosition = curPos + Vector2(0, BoxListComponent.BOX_LIST_MOVE_SPEED * self.boxListAlterHoveringDir)
	end
end

function BoxListComponent:hoveringMove(list, goToIndex, stop)
	if stop then
		list:StopScroll()

		if list == self.boxList then
			self.boxListHoveringMoveFlag = false
		else
			self.boxListAlterHoveringMoveFlag = false
		end

		return
	end

	if list == self.boxList then
		if list:IsReachBound(goToIndex >= 0) then
			list:StopScroll()

			self.boxListHoveringMoveFlag = false

			return
		end

		self.boxListHoveringMoveFlag = true
		self.boxListHoveringDir = goToIndex < 0 and 1 or -1
	else
		if list:IsReachBound(goToIndex >= 0) then
			list:StopScroll()

			self.boxListAlterHoveringMoveFlag = false

			return
		end

		self.boxListAlterHoveringMoveFlag = true
		self.boxListAlterHoveringDir = goToIndex < 0 and 1 or -1
	end
end

return BoxListComponent
