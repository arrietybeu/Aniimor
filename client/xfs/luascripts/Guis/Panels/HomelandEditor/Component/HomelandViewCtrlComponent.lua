-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditor\\Component\\HomelandViewCtrlComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local HomeTypeData = require("Data.home_type_data")
local HomeSubTypeData = require("Data.home_sub_type_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RevertHomeObjectData = require("Data.revert_home_object_data")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotKeyConst = require("Const.HotkeyConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local HomelandViewCtrlComponent = Class.LightClass("HomelandViewCtrlComponent", UIComponent)

function HomelandViewCtrlComponent:onCtor(info)
	HomelandViewCtrlComponent.super.onCtor(self, info)

	self.moveJoyStick = info.joyStick
end

function HomelandViewCtrlComponent:findObjects()
	self.simpleViewCtrl = self.transform:GetComponent("SimpleViewCtrl")
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.keyHintList = self.objectReference:GetRefValue("keyHintList")
	self.onSelectEnt = nil
	self.onStartDrag = nil
	self.onEndDrag = nil
	self.onDrag = nil
	self.enable = true
	self.gamepadShowHint = false
	self.editor = self.ctrl.editor or pg.game.home.editor
	self.selectType = ClientConst.HomeSelectType.All
end

function HomelandViewCtrlComponent:onDestroy()
	HomelandViewCtrlComponent.super.onDestroy(self)

	self.isDestroyed = true

	if self.gamepadZoomInTimer then
		self.ctrl:killTimer(self.gamepadZoomInTimer)

		self.gamepadZoomInTimer = nil
	end

	if self.gamepadZoomOutTimer then
		self.ctrl:killTimer(self.gamepadZoomOutTimer)

		self.gamepadZoomOutTimer = nil
	end

	if self.gamepadRotateTimer then
		self.ctrl:killTimer(self.gamepadRotateTimer)

		self.gamepadRotateTimer = nil
	end

	self.editor:handleMove(0, 0)
	pg.game.input:setViewAxisByDeltaPixel(0, 0)
end

function HomelandViewCtrlComponent:setEnable(enable)
	self.enable = enable

	self:refreshKeyHints()
	self:refreshMobileControl()

	if not enable then
		if self.gamepadZoomInTimer then
			self.ctrl:killTimer(self.gamepadZoomInTimer)

			self.gamepadZoomInTimer = nil
		end

		if self.gamepadZoomOutTimer then
			self.ctrl:killTimer(self.gamepadZoomOutTimer)

			self.gamepadZoomOutTimer = nil
		end

		if self.gamepadRotateTimer then
			self.ctrl:killTimer(self.gamepadRotateTimer)

			self.gamepadRotateTimer = nil
		end

		pg.game.input:setViewAxisByDeltaPixel(0, 0)
		self.editor:handleMove(0, 0)
	end
end

function HomelandViewCtrlComponent:initView()
	local cameraMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.gameObject, "cameraMove")

	cameraMoveBinding.isVirtual = true
	cameraMoveBinding.priority = 0
	cameraMoveBinding.actionPath = HotKeyConst.INPUT_MAP_ACTION_KEY.Move

	function cameraMoveBinding.luaTrigger(inputInfo)
		if pg.global.inputMgr:GetVirtualMouseActiveSelf() then
			return
		end

		if not self.enable then
			return true
		end

		if inputInfo.phase == "Performed" and not self.isDestroyed then
			self.editor:handleMove(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
		elseif inputInfo.phase == "Canceled" then
			self.editor:handleMove(0, 0)
		end
	end

	local cameraZoomBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.gameObject, "cameraZoom")

	cameraZoomBinding.isVirtual = true
	cameraZoomBinding.priority = 0
	cameraZoomBinding.actionPath = HotKeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom

	function cameraZoomBinding.luaTrigger(inputInfo)
		if not self.enable then
			return true
		end

		if inputInfo.phase == "Performed" then
			local deltaZoom = inputInfo.valueVec2.y

			if deltaZoom > 0 then
				self.editor:zoomIn()
			else
				self.editor:zoomOut()
			end
		elseif inputInfo.phase == "Canceled" then
			-- block empty
		end
	end

	function self.simpleViewCtrl.luaBeginDrag(screenPos, button)
		if not self.enable then
			return
		end

		self.curDragButton = button

		if self.onStartDrag and self.onStartDrag(screenPos, self.curDragButton) then
			return
		end

		self.curDragPos = screenPos
	end

	function self.simpleViewCtrl.luaDragUpdate(screenPos)
		if not self.enable then
			return
		end

		if self.onDrag and self.onDrag(screenPos, self.curDragButton) then
			return
		end

		if self.curDragPos and not pg.game.input:isUsingGamepad() then
			pg.game.input:setViewAxisByDeltaPixel(screenPos.x - self.curDragPos.x, screenPos.y - self.curDragPos.y)
		end

		self.curDragPos = screenPos
	end

	function self.simpleViewCtrl.luaEndDrag(screenPos, button)
		if not self.enable then
			return
		end

		self.curDragButton = nil

		if self.onEndDrag and self.onEndDrag(screenPos, self.curDragButton) then
			return
		end

		pg.game.input:setViewAxisByDeltaPixel(0, 0)

		self.curDragPos = nil
	end

	local gamepadRotateBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.gameObject, "gamepadRotateBinding")

	gamepadRotateBinding.isVirtual = true
	gamepadRotateBinding.actionPath = "Raw/GamepadRightStickMove"

	function gamepadRotateBinding.luaTrigger(inputInfo)
		if self.isDestroyed or not self.enable then
			return true
		end

		if inputInfo.phase == "Performed" then
			self.deltaVec2 = inputInfo.valueVec2

			if self.gamepadRotateTimer == nil then
				self.gamepadRotateTimer = self.ctrl:startTimer(function()
					pg.game.input:setViewAxisByDeltaPixel(self.deltaVec2.x * 10, self.deltaVec2.y * 10)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" then
			self.ctrl:killTimer(self.gamepadRotateTimer)

			self.gamepadRotateTimer = nil

			pg.game.input:setViewAxisByDeltaPixel(0, 0)
		end
	end

	function self.simpleViewCtrl.luaClick(screenPos, buttonType)
		if not self.enable then
			return
		end

		if not pg.global.ui.uiMgr:CheckIsMobileInteract() and buttonType ~= ClientConst.InputButtonType.Left then
			return
		end

		if self.onSelectEnt then
			local selectEnt = self.editor:trySelectEntity(screenPos, self.selectType)

			self.onSelectEnt(selectEnt)
		end
	end

	function self.simpleViewCtrl.luaZoom(distance)
		if not self.enable then
			return
		end

		self.editor:handleZoom(-distance * 0.2)
	end

	local ZOOM_PER_FRAME = 0.8
	local zoomInBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.gameObject, "gamepadZoomInBinding")

	zoomInBinding.isVirtual = true
	zoomInBinding.priority = 0
	zoomInBinding.actionPath = "Hud/GamepadZoomIn"

	function zoomInBinding.luaTrigger(inputInfo)
		if self.isDestroyed or not self.enable then
			return true
		end

		if inputInfo.phase == "Performed" then
			if self.gamepadZoomInTimer == nil then
				self.gamepadZoomInTimer = self.ctrl:startTimer(function()
					self.editor:handleZoom(-ZOOM_PER_FRAME)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.gamepadZoomInTimer then
			self.ctrl:killTimer(self.gamepadZoomInTimer)

			self.gamepadZoomInTimer = nil
		end
	end

	local zoomOutBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.uWidget.gameObject, "gamepadZoomOutBinding")

	zoomOutBinding.isVirtual = true
	zoomOutBinding.priority = 0
	zoomOutBinding.actionPath = "Hud/GamepadZoomOut"

	function zoomOutBinding.luaTrigger(inputInfo)
		if self.isDestroyed or not self.enable then
			return true
		end

		if inputInfo.phase == "Performed" then
			if self.gamepadZoomOutTimer == nil then
				self.gamepadZoomOutTimer = self.ctrl:startTimer(function()
					self.editor:handleZoom(ZOOM_PER_FRAME)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.gamepadZoomOutTimer then
			self.ctrl:killTimer(self.gamepadZoomOutTimer)

			self.gamepadZoomOutTimer = nil
		end
	end

	if self.moveJoyStick then
		function self.moveJoyStick.luaValueChanged(x, y, z)
			if not self.enable then
				return
			end

			self.editor:handleMove(x, y)
		end
	end
end

function HomelandViewCtrlComponent:initCameraHeight()
	self.cameraHeightTimers = {}

	self:initCameraHeightSelector()
	self:initCameraHeightInput()
end

function HomelandViewCtrlComponent:initCameraHeightInput()
	local increaseCameraHeightBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "increaseCameraHeightBind")

	increaseCameraHeightBind.isVirtual = true
	increaseCameraHeightBind.actionPath = "Hud/SkillQ"

	function increaseCameraHeightBind.luaTrigger(inputInfo)
		self:handleCameraHeightInput(inputInfo, 1)
	end

	local decreaseCameraHeightBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "decreaseCameraHeightBind")

	decreaseCameraHeightBind.isVirtual = true
	decreaseCameraHeightBind.actionPath = "Hud/SkillE"

	function decreaseCameraHeightBind.luaTrigger(inputInfo)
		self:handleCameraHeightInput(inputInfo, -1)
	end
end

function HomelandViewCtrlComponent:handleCameraHeightInput(inputInfo, delta)
	if inputInfo.phase == "Performed" and not pg.game.input:isUsingGamepad() then
		if self.cameraHeightTimers[delta] == nil then
			local function changeHeight()
				self:changeCameraHeight(delta)
			end

			changeHeight()

			self.cameraHeightTimers[delta] = self:startTimer(changeHeight, 0.2, true)
		end
	elseif inputInfo.phase == "Canceled" and self.cameraHeightTimers[delta] then
		self:killTimer(self.cameraHeightTimers[delta])

		self.cameraHeightTimers[delta] = nil
	end
end

function HomelandViewCtrlComponent:initCameraHeightSelector()
	local options = {}

	for i = 0, Const.HOMELAND_EDITOR_CAMERA_HEIGHT_MAX_INDEX do
		table.insert(options, {
			num = i
		})
	end

	function self.view.selectorMetreUSelector.luaRenderPopup(_, uList)
		self.cameraHeightPopupList = uList

		local cameraHeightMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(uList.gameObject, "cameraHeightMove")

		cameraHeightMoveBinding.isVirtual = true
		cameraHeightMoveBinding.priority = 1
		cameraHeightMoveBinding.actionPath = HotKeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickMove
		self.cameraHeightMoveDirection = nil

		function cameraHeightMoveBinding.luaTrigger(inputInfo)
			if not self.enable or not self.view.selectorMetreUSelector.isPopup then
				self.cameraHeightMoveDirection = nil

				return true
			end

			if inputInfo.phase == "Canceled" then
				self.cameraHeightMoveDirection = nil

				return false
			elseif inputInfo.phase ~= "Performed" then
				return true
			end

			local move = inputInfo.valueVec2

			if math.abs(move.y) < 0.5 or math.abs(move.y) <= math.abs(move.x) then
				self.cameraHeightMoveDirection = nil

				return false
			end

			local direction = move.y > 0 and -1 or 1

			if self.cameraHeightMoveDirection == direction then
				return false
			end

			self.cameraHeightMoveDirection = direction

			local targetIndex = self:changeCameraHeight(direction)
			local found, focusItem = uList:TryGetChildAt(targetIndex)

			if found and NotNil(focusItem) then
				pg.global.navMgr:FocusItem(focusItem, CS.XGUI.Navigation.FocusEntryMode.Restore)
			end

			return false
		end

		function uList.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")

			ClientTextUtils.setText(objectReference:GetRefValue("txtNumUSDFText"), data.num)
			ClientTextUtils.setText(objectReference:GetRefValue("txtMUSDFText"), "M")

			button.interactable = false
			button.navForceInteractable = true
		end

		uList:SetList(options)
	end

	function self.view.selectorMetreUSelector.luaOnPopupChanged(isOpen)
		if not isOpen or not pg.game.input:isUsingGamepad() or not self.cameraHeightPopupList then
			return
		end

		local targetIndex = self.view.selectorMetreUSelector.selectedIndex

		if targetIndex < 0 then
			return
		end

		self.cameraHeightPopupList:SelectItem(targetIndex, false)
		self.cameraHeightPopupList:GoToIndex(targetIndex, true)

		local found, focusItem = self.cameraHeightPopupList:TryGetChildAt(targetIndex)

		if found and NotNil(focusItem) then
			pg.global.navMgr:FocusItem(focusItem, CS.XGUI.Navigation.FocusEntryMode.Restore)
		end
	end

	self.view.selectorMetreUSelector:SetOptions(options)

	function self.view.selectorMetreUSelector.luaSelectedChanged(selector)
		local index = selector.selectedIndex

		if index < 0 then
			return
		end

		self.ctrl.cameraHeight = index

		ClientTextUtils.setText(self.view.txtCameraHeightUSDFText, index)
		self.editor:setCameraHeightOffset(index)
		self.editor:setCameraHeightLimit(index)

		if self.editor.displayHideMode ~= 0 then
			self.editor:refreshHeightHide()
		end
	end

	local initIndex = math.max(0, math.min(self.ctrl.cameraHeight, Const.HOMELAND_EDITOR_CAMERA_HEIGHT_MAX_INDEX))

	self.view.selectorMetreUSelector.selectedIndex = initIndex
	self.ctrl.cameraHeight = initIndex

	ClientTextUtils.setText(self.view.txtCameraHeightUSDFText, initIndex)
	ClientTextUtils.setText(self.view.txtMUSDFText, "M")
	self.editor:setCameraHeightOffset(initIndex)
	self.editor:setCameraHeightLimit(initIndex)
end

function HomelandViewCtrlComponent:changeCameraHeight(delta)
	local selector = self.view.selectorMetreUSelector
	local targetIndex = math.max(0, math.min(self.ctrl.cameraHeight + delta, Const.HOMELAND_EDITOR_CAMERA_HEIGHT_MAX_INDEX))

	if selector.isPopup and self.cameraHeightPopupList then
		self.cameraHeightPopupList:SelectItem(targetIndex, false)
		self.cameraHeightPopupList:GoToIndex(targetIndex, true)
	end

	if targetIndex ~= selector.selectedIndex then
		selector:ForceSelect(targetIndex)
	end

	return targetIndex
end

function HomelandViewCtrlComponent:refreshCameraHeight()
	self.ctrl.cameraHeight = self.editor.cameraHeightLimit

	local selector = self.view.selectorMetreUSelector

	if selector.selectedIndex ~= self.ctrl.cameraHeight then
		selector:ForceSelect(self.ctrl.cameraHeight)
	else
		ClientTextUtils.setText(self.view.txtCameraHeightUSDFText, self.ctrl.cameraHeight)
	end
end

function HomelandViewCtrlComponent:selectScreenCenter()
	local screenCenter = Vector2(Screen.width * 0.5, Screen.height * 0.5)
	local selectEnt = self.editor:trySelectEntity(screenCenter, self.selectType)

	self.onSelectEnt(selectEnt)
end

function HomelandViewCtrlComponent:refreshMobileControl()
	return
end

function HomelandViewCtrlComponent:setGamepadShowHint(showHint)
	self.gamepadShowHint = showHint

	if self.stateKey then
		self:refreshKeyHints()
	end
end

function HomelandViewCtrlComponent:setKeyHintInfo(stateKey, gamepadStateKey)
	self.stateKey = stateKey
	self.gamepadStateKey = gamepadStateKey

	self:refreshKeyHints()
end

function HomelandViewCtrlComponent:refreshKeyHints()
	if self.keyHintList and not pg.global.ui:runPlatformByMobile() then
		local shortcutData = {}

		if pg.game.input:isUsingGamepad() then
			if self.gamepadStateKey then
				shortcutData = LuaUIUtils.getShortcutDataByState(self.gamepadStateKey)
			end
		elseif self.stateKey then
			shortcutData = LuaUIUtils.getShortcutDataByState(self.stateKey)
		end

		function self.keyHintList.luaRenderItem(button, idx, data)
			local objectReference = button.transform:GetComponent("ObjectReference")
			local key = objectReference:GetRefValue("keyHotKeyContent")

			if data.actionPaths[1] == HotKeyConst.INPUT_MAP_ACTION_KEY.Move then
				key.useRawBindingPath = true
			else
				key.useRawBindingPath = false
			end

			key:SetHotKeyPaths(data.actionPaths[1])

			local btnTips = objectReference:GetRefValue("btnTipsUText")

			ClientTextUtils.setText(btnTips, pg.getLocalizationText(data.desc))
		end

		self.keyHintList:SetList(shortcutData)

		if self.enable then
			if pg.game.input:isUsingGamepad() then
				self.keyHintList:SetActive(false)
			else
				self.keyHintList:SetActive(true)
			end
		else
			self.keyHintList:SetActive(false)
		end
	end
end

return HomelandViewCtrlComponent
