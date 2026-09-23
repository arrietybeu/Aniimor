-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncDIYUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncDIYUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncDIYUIComponent = Class.LightClass("PhotoFuncDIYUIComponent", UIComponent)
local DIYData = require("Data.photo_diy_data")
local lume = require("Core.Common.lume")
local AddressDataConst = require("Const.AddressDataConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local RandomString = require("Core.Common.RandomString")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LimitCount = 10
local GAMEPAD_MOVE_SPEED = 800
local GAMEPAD_ROTATE_SPEED = 120
local GAMEPAD_SCALE_SPEED = 0.8
local GAMEPAD_STICK_DEADZONE = 0.15
local GAMEPAD_MIN_SCALE = 0.31
local diyInstanceSerial = 0

local function clampFrameAxis(value, minValue, maxValue)
	if maxValue < minValue then
		return (minValue + maxValue) * 0.5
	end

	return math.clamp(value, minValue, maxValue)
end

local function constrainFramePosition(rect, boundsRect, targetX, targetY)
	local rectData = rect.rect
	local scale = rect.localScale
	local radians = math.rad(rect.localEulerAngles.z)
	local cosValue = math.cos(radians)
	local sinValue = math.sin(radians)
	local left = rectData.xMin * scale.x
	local right = rectData.xMax * scale.x
	local bottom = rectData.yMin * scale.y
	local top = rectData.yMax * scale.y
	local leftBottomX = left * cosValue - bottom * sinValue
	local leftBottomY = left * sinValue + bottom * cosValue
	local leftTopX = left * cosValue - top * sinValue
	local leftTopY = left * sinValue + top * cosValue
	local rightBottomX = right * cosValue - bottom * sinValue
	local rightBottomY = right * sinValue + bottom * cosValue
	local rightTopX = right * cosValue - top * sinValue
	local rightTopY = right * sinValue + top * cosValue
	local minOffsetX = math.min(leftBottomX, leftTopX, rightBottomX, rightTopX)
	local maxOffsetX = math.max(leftBottomX, leftTopX, rightBottomX, rightTopX)
	local minOffsetY = math.min(leftBottomY, leftTopY, rightBottomY, rightTopY)
	local maxOffsetY = math.max(leftBottomY, leftTopY, rightBottomY, rightTopY)
	local bounds = boundsRect.rect
	local minX = bounds.xMin - minOffsetX
	local maxX = bounds.xMax - maxOffsetX
	local minY = bounds.yMin - minOffsetY
	local maxY = bounds.yMax - maxOffsetY
	local localPosition = rect.localPosition

	rect.localPosition = Vector3(clampFrameAxis(targetX, minX, maxX), clampFrameAxis(targetY, minY, maxY), localPosition.z)
end

local function generateDIYInstanceUid()
	diyInstanceSerial = diyInstanceSerial + 1

	return string.format("diy_%s_%s_%s_%s", tostring(pg.me.uid), tostring(Time.millisecondCache), tostring(diyInstanceSerial), RandomString.gen(6))
end

local function getPresetDIYInstanceUid(data, index)
	local instanceUid = type(data) == "table" and data.instanceUid

	if instanceUid ~= nil and tostring(instanceUid) ~= "" then
		return tostring(instanceUid)
	end

	return string.format("legacy_%s_%s", tostring(data.id), tostring(index))
end

function PhotoFuncDIYUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncDIYUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listFirstUList = objectReference:GetRefValue("listFirstUList")
	self.listSecondUList = objectReference:GetRefValue("listSecondUList")
	self.textLimitUBaseText = objectReference:GetRefValue("textLimitUBaseText")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
end

function PhotoFuncDIYUIComponent:initView()
	self:InitDIY()
	self:initGamepad()
end

function PhotoFuncDIYUIComponent:onDestroy()
	if self.gamepadTickTimer then
		self:killTimer(self.gamepadTickTimer)

		self.gamepadTickTimer = nil
	end

	UIComponent.onDestroy(self)
end

function PhotoFuncDIYUIComponent:InitDIY()
	self.curCount = 0
	self.type2DIYData = {}
	self.type2Name = {}
	self.frameObjects = {}
	self.frameInstanceUids = {}
	self.instanceUidFrames = {}
	self.curSelectFrame = nil
	self.curSelectRootButton = nil
	self.curTab = nil
	self.gamepadStick = Vector2(0, 0)
	self.gamepadLBHeld = false
	self.gamepadRBHeld = false
	self.gamepadLTHeld = false
	self.gamepadRTHeld = false
	self.gamepadRotateDir = 0
	self.gamepadScaleDir = 0

	self.model:getAssetsData(DIYData, self.type2DIYData, self.type2Name)
	self:sortUnlockedAssetsFirst()

	function self.listFirstUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(self.type2Name[data.type or 1]))

		local subTabPath = PhotographyAssetRedDotUtils.getSubTabPath(PhotographyAssetRedDotUtils.AssetType.DIY, data.type)

		pg.global.setPreViewRedDot(subTabPath, button, function()
			return PhotographyAssetRedDotUtils.getRedDotStyle(PhotographyAssetRedDotUtils.AssetType.DIY, data.type)
		end)

		function button.luaSelectChanged(selected)
			if not selected then
				return
			end

			if data.type == self.curTab then
				return
			end

			self.curTab = data.type

			local dataList = self.type2DIYData[self.curTab]

			self.listSecondUList:SetList(dataList)
		end

		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listSecondUList)
	end

	function self.listSecondUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.icon or data.res

		local isUnLock = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.DIY, data.id)
		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.DIY, data.type, data.id)

		pg.global.setRedDot(itemPath, button, PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.DIY, data.id), RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", isUnLock and 0 or 1)

		button.interactable = true
		button.visualInteractable = isUnLock
		button.skipInListSwitch = not isUnLock

		function button.luaClick()
			if not isUnLock then
				PhotographyStudioUtils.showLockedAssetTip(data.id, button)

				return
			end

			local obj = self:createFrame(data)

			if IsNil(obj) then
				return
			end

			PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.DIY, data.id)
			self.listSecondUList:RefreshList()
			self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.DIY, data.type)
		end
	end

	if self.preset then
		self:applyPreset(self.preset)
	end
end

function PhotoFuncDIYUIComponent:sortUnlockedAssetsFirst()
	for _, dataList in pairs(self.type2DIYData) do
		PhotographyAssetRedDotUtils.sortUnlockedFirst(dataList, PhotographyAssetRedDotUtils.AssetType.DIY)
	end
end

function PhotoFuncDIYUIComponent:refreshAssetUnlockState()
	self:sortUnlockedAssetsFirst()

	if self.curTab then
		self.listSecondUList:SetList(self.type2DIYData[self.curTab])
	end
end

function PhotoFuncDIYUIComponent:refreshUI()
	if not self.haveRefreshed then
		local typeList = {}

		for type, _ in pairs(self.type2DIYData) do
			typeList[#typeList + 1] = {
				type = type
			}
		end

		self.tabUWidget:SetActive(#typeList > 1)
		self.listFirstUList:SetList(typeList)
		self.listFirstUList:DeselectAll()
		self.listFirstUList:SelectItem(0)

		self.haveRefreshed = true
	end

	self:refreshCanFocusStickState()
end

function PhotoFuncDIYUIComponent:onDeselected()
	if pg.global.navMgr and self:isAnyDIYFrameFocused() then
		pg.global.navMgr:PopFocusGroup()
	end

	self:onSelectFrame(nil)
	self:refreshCanFocusStickState()
end

function PhotoFuncDIYUIComponent:applyPreset(preset)
	local diyInfo = preset.diyInfo

	if IsNil(diyInfo) then
		return
	end

	local isUserdata = type(diyInfo) == "userdata"
	local keepInstanceUids = {}

	local function handleData(data, index)
		if not pg.me:isPhotoUnlock(data.id) then
			return
		end

		local diyData = DIYData[data.id]

		if not diyData then
			return
		end

		local instanceUid = getPresetDIYInstanceUid(data, index)
		local obj = self.instanceUidFrames[instanceUid]

		if IsNil(obj) then
			obj = self:createFrame(diyData, instanceUid, true)
		end

		if IsNil(obj) then
			return
		end

		keepInstanceUids[instanceUid] = true
		self.frameObjects[obj] = data.id

		local rectTrans = obj:GetComponent("RectTransform")
		local objectReference = obj:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
		local btnZoomUWidget = objectReference:GetRefValue("btnZoomUWidget")
		local btnRotateUButton = objectReference:GetRefValue("btnRotateUButton")
		local oldScale = rectTrans.localScale.x
		local scale = tonumber(data.scale) or 1

		if scale <= 0 then
			scale = 1
		end

		local controlScaleRatio = oldScale / scale

		iconUImage.url = diyData.res
		rectTrans.anchoredPosition = Vector2(data.position.x, data.position.y)
		rectTrans.localRotation = Quaternion.Euler(0, 0, data.rotation)
		rectTrans.localScale = Vector3(scale, scale, scale)
		btnCloseUButton.transform.localScale = btnCloseUButton.transform.localScale * controlScaleRatio
		btnZoomUWidget.transform.localScale = btnZoomUWidget.transform.localScale * controlScaleRatio
		btnRotateUButton.transform.localScale = btnRotateUButton.transform.localScale * controlScaleRatio

		obj.transform:SetAsLastSibling()
	end

	if isUserdata then
		for i = 0, diyInfo.Count - 1 do
			handleData(diyInfo[i], i + 1)
		end
	else
		for i = 1, #diyInfo do
			handleData(diyInfo[i], i)
		end
	end

	for obj, instanceUid in pairs(self.frameInstanceUids) do
		if not keepInstanceUids[instanceUid] then
			self:destroyFrame(obj)
		end
	end
end

function PhotoFuncDIYUIComponent:saveToPreset(preset)
	preset.diyInfo = {}

	local diyInfo = preset.diyInfo

	for obj, id in pairs(self.frameObjects) do
		local rectTrans = obj:GetComponent("RectTransform")
		local anchoredPosition = rectTrans.anchoredPosition
		local localRotation = rectTrans.eulerAngles
		local localScale = rectTrans.localScale

		diyInfo[#diyInfo + 1] = {
			id = id,
			instanceUid = self.frameInstanceUids[obj],
			position = {
				x = tonumber(string.format("%.2f", anchoredPosition.x)),
				y = tonumber(string.format("%.2f", anchoredPosition.y))
			},
			rotation = tonumber(string.format("%.2f", localRotation.z)),
			scale = tonumber(string.format("%.2f", localScale.x))
		}
	end

	table.sort(diyInfo, function(left, right)
		return tostring(left.instanceUid) < tostring(right.instanceUid)
	end)
end

function PhotoFuncDIYUIComponent:createFrame(data, instanceUid, skipSelect)
	if self.curCount >= LimitCount then
		if not skipSelect then
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STICKER_CAPACITY_FULL"))
		end

		return
	end

	self.curCount = self.curCount + 1

	local objInfo = self.view:addPrefabWithPathSync(self.ctrl.dIYRootRectTransform, AddressDataConst.PHOTO_DIY_FRAME)
	local obj = objInfo.gameObject
	local objectReference = obj:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local btnZoomUWidget = objectReference:GetRefValue("btnZoomUWidget")
	local btnRotateUButton = objectReference:GetRefValue("btnRotateUButton")
	local rootUButton = objectReference:GetRefValue("rootUButton")

	iconUImage.url = data.res
	self.frameObjects[obj] = data.id
	instanceUid = instanceUid or generateDIYInstanceUid()
	self.frameInstanceUids[obj] = instanceUid
	self.instanceUidFrames[instanceUid] = obj

	if skipSelect then
		rootUButton:TryChangePage("Status", 1)
	else
		self:onSelectFrame(obj)
	end

	function rootUButton.luaBeginDrag()
		rootUButton.transform:SetAsLastSibling()
	end

	function rootUButton.luaEndDrag()
		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("diy_move")
		end
	end

	function rootUButton.luaPress()
		self:onSelectFrame(rootUButton.gameObject)
	end

	function btnRotateUButton.luaBeginDrag(pos)
		self.dragCenterScreenPos = UIUtils.WorldToScreenPoint(rootUButton.transform.position)
		self.vectorDrag = Vector2(0, 0)
		self.vectorOri = Vector2(0, 0)
	end

	function btnRotateUButton.luaDrag(pos)
		local dragBtnScreenPos = UIUtils.WorldToScreenPoint(btnRotateUButton.transform.position)

		self.vectorDrag.x = pos.x - self.dragCenterScreenPos.x
		self.vectorDrag.y = pos.y - self.dragCenterScreenPos.y
		self.vectorOri.x = dragBtnScreenPos.x - self.dragCenterScreenPos.x
		self.vectorOri.y = dragBtnScreenPos.y - self.dragCenterScreenPos.y

		local clockWise = Vector2.Cross(self.vectorOri, self.vectorDrag) < 0 and -1 or 1

		obj.transform:Rotate(0, 0, clockWise * Vector2.Angle(self.vectorOri, self.vectorDrag))
	end

	function btnRotateUButton.luaEndDrag()
		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("diy_rotate")
		end
	end

	function btnZoomUWidget.luaBeginDrag(pos)
		self.dragCenterScreenPos = UIUtils.WorldToScreenPoint(rootUButton.transform.position)
	end

	function btnZoomUWidget.luaDrag(pos)
		local dragBtnScreenPos = UIUtils.WorldToScreenPoint(btnZoomUWidget.transform.position)
		local btnScale = lume.distance(dragBtnScreenPos.x, dragBtnScreenPos.y, self.dragCenterScreenPos.x, self.dragCenterScreenPos.y)
		local dragScale = lume.distance(pos.x, pos.y, self.dragCenterScreenPos.x, self.dragCenterScreenPos.y)
		local realScale = dragScale / btnScale
		local scaleX = rootUButton.transform.localScale.x

		if realScale < 1 and (scaleX <= 0.31 or scaleX * realScale <= 0.31) then
			rootUButton.transform.localScale.x = 0.31
			rootUButton.transform.localScale.y = 0.31
			rootUButton.transform.localScale.z = 0.31

			return
		end

		rootUButton.transform.localScale = rootUButton.transform.localScale * realScale
		btnCloseUButton.transform.localScale = btnCloseUButton.transform.localScale / realScale
		btnZoomUWidget.transform.localScale = btnZoomUWidget.transform.localScale / realScale
		btnRotateUButton.transform.localScale = btnRotateUButton.transform.localScale / realScale
	end

	function btnZoomUWidget.luaEndDrag()
		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("diy_scale")
		end
	end

	function btnCloseUButton.luaClick()
		self:destroyFrame(obj)

		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("diy_delete")
		end
	end

	ClientTextUtils.setText(self.textLimitUBaseText, string.format("%s/%s", self.curCount, LimitCount))
	pg.global.navMgr:PushFocusItem(rootUButton)
	self:refreshCanFocusStickState()

	if not skipSelect and self.ctrl.recordHistoryStep then
		self.ctrl:recordHistoryStep("diy_add")
	end

	return obj
end

function PhotoFuncDIYUIComponent:isDIYFrameFocused()
	if IsNil(self.curSelectRootButton) then
		return false
	end

	return pg.global.navMgr.CurrentFocusedUContent == self.curSelectRootButton
end

function PhotoFuncDIYUIComponent:isDIYTabActive()
	return self.ctrl and self.ctrl.Funcs and self.ctrl.curSelectTab == self.ctrl.Funcs.DIY
end

function PhotoFuncDIYUIComponent:canFocusOnStick()
	if not self:isDIYTabActive() then
		return false
	end

	if self.ctrl.isMenuRaised and not self.ctrl:isMenuRaised() then
		return false
	end

	if self:isAnyDIYFrameFocused() then
		return false
	end

	return self.curCount > 0
end

function PhotoFuncDIYUIComponent:isAnyDIYFrameFocused()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return false
	end

	local focused = navMgr.CurrentFocusedUContent

	if IsNil(focused) then
		return false
	end

	for obj, _ in pairs(self.frameObjects) do
		local rootBtn = obj:GetComponent("ObjectReference"):GetRefValue("rootUButton")

		if rootBtn == focused then
			return true
		end
	end

	return false
end

function PhotoFuncDIYUIComponent:deleteFocusedFrame()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local focused = navMgr.CurrentFocusedUContent

	if IsNil(focused) then
		return
	end

	for obj, _ in pairs(self.frameObjects) do
		local objectReference = obj:GetComponent("ObjectReference")
		local rootBtn = objectReference:GetRefValue("rootUButton")

		if rootBtn == focused then
			local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")

			self:destroyFrame(obj)

			if self.ctrl.recordHistoryStep then
				self.ctrl:recordHistoryStep("diy_delete")
			end

			return
		end
	end
end

function PhotoFuncDIYUIComponent:refreshCanFocusStickState()
	if self.ctrl.isMenuRaised and not self.ctrl:isMenuRaised() and self:isAnyDIYFrameFocused() and pg.global.navMgr then
		pg.global.navMgr:PopFocusGroup()
	end

	pg.global.navMgr:SetConsoleBarState("CanFocusStick", self:canFocusOnStick())
end

function PhotoFuncDIYUIComponent:focusFirstStick()
	if not self:canFocusOnStick() or self:isDIYFrameFocused() then
		return
	end

	local target = self.curSelectFrame

	if IsNil(target) then
		target = next(self.frameObjects)
	end

	if IsNil(target) then
		return
	end

	local rootBtn = target:GetComponent("ObjectReference"):GetRefValue("rootUButton")

	pg.global.navMgr:PushFocusItem(rootBtn)
	self:refreshCanFocusStickState()
end

function PhotoFuncDIYUIComponent:initGamepad()
	local root = self.transform.gameObject
	local stickBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_RightStick")

	stickBind.isVirtual = true
	stickBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickMove

	function stickBind.luaTrigger(inputInfo)
		if not self:isDIYFrameFocused() then
			self.gamepadStick = Vector2(0, 0)

			return true
		end

		if inputInfo.phase == "Performed" then
			self.gamepadStick = Vector2(inputInfo.valueVec2.x, inputInfo.valueVec2.y)
		else
			self.gamepadStick = Vector2(0, 0)
		end
	end

	local lbBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_LB")

	lbBind.isVirtual = true
	lbBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftShoulder

	function lbBind.luaTrigger(inputInfo)
		if not self:isDIYFrameFocused() then
			self.gamepadLBHeld = false
			self.gamepadRotateDir = (self.gamepadRBHeld and 1 or 0) - (self.gamepadLBHeld and 1 or 0)

			return true
		end

		self.gamepadLBHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadRotateDir = (self.gamepadRBHeld and 1 or 0) - (self.gamepadLBHeld and 1 or 0)
	end

	local rbBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_RB")

	rbBind.isVirtual = true
	rbBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightShoulder

	function rbBind.luaTrigger(inputInfo)
		if not self:isDIYFrameFocused() then
			self.gamepadRBHeld = false
			self.gamepadRotateDir = (self.gamepadRBHeld and 1 or 0) - (self.gamepadLBHeld and 1 or 0)

			return true
		end

		self.gamepadRBHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadRotateDir = (self.gamepadRBHeld and 1 or 0) - (self.gamepadLBHeld and 1 or 0)
	end

	local ltBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_LT")

	ltBind.isVirtual = true
	ltBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftTrigger

	function ltBind.luaTrigger(inputInfo)
		if not self:isDIYFrameFocused() then
			self.gamepadLTHeld = false
			self.gamepadScaleDir = (self.gamepadRTHeld and 1 or 0) - (self.gamepadLTHeld and 1 or 0)

			return true
		end

		self.gamepadLTHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadScaleDir = (self.gamepadRTHeld and 1 or 0) - (self.gamepadLTHeld and 1 or 0)
	end

	local rtBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_RT")

	rtBind.isVirtual = true
	rtBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightTrigger

	function rtBind.luaTrigger(inputInfo)
		if not self:isDIYFrameFocused() then
			self.gamepadRTHeld = false
			self.gamepadScaleDir = (self.gamepadRTHeld and 1 or 0) - (self.gamepadLTHeld and 1 or 0)

			return true
		end

		self.gamepadRTHeld = inputInfo.phase == "Performed" and inputInfo.isPressed == true
		self.gamepadScaleDir = (self.gamepadRTHeld and 1 or 0) - (self.gamepadLTHeld and 1 or 0)
	end

	local focusStickBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_FocusStick")

	focusStickBind.isVirtual = true
	focusStickBind.actionPath = self.ctrl.getDIYFocusStickActionPath and self.ctrl:getDIYFocusStickActionPath() or HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth

	function focusStickBind.luaTrigger(inputInfo)
		if inputInfo.phase ~= "Performed" then
			return
		end

		if not self:canFocusOnStick() or self:isDIYFrameFocused() then
			return true
		end

		self:focusFirstStick()
	end

	local xBind = KeyBindingPro.GetOrAddKeyBindingByName(root, "PhotoDIY_DeleteFrame")

	xBind.isVirtual = true
	xBind.priority = 99999
	xBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest

	function xBind.luaTrigger(inputInfo)
		if inputInfo.phase ~= "Performed" then
			return
		end

		if not self:isAnyDIYFrameFocused() then
			return true
		end

		self:deleteFocusedFrame()

		return false
	end

	self.gamepadTickTimer = self:startTimer(function()
		self:gamepadTick()
	end, 0, true)
end

function PhotoFuncDIYUIComponent:gamepadTick()
	if IsNil(self.curSelectFrame) or not self:isDIYFrameFocused() then
		return
	end

	local dt = Time.deltaTime
	local rect = self.curSelectFrame:GetComponent("RectTransform")
	local changed = false
	local moved = false
	local sx, sy = self.gamepadStick.x, self.gamepadStick.y

	if math.abs(sx) > GAMEPAD_STICK_DEADZONE or math.abs(sy) > GAMEPAD_STICK_DEADZONE then
		local cur = rect.localPosition

		rect.localPosition = Vector3(cur.x + sx * GAMEPAD_MOVE_SPEED * dt, cur.y + sy * GAMEPAD_MOVE_SPEED * dt, cur.z)
		moved = true
		changed = true
	end

	if self.gamepadRotateDir ~= 0 then
		rect:Rotate(0, 0, self.gamepadRotateDir * GAMEPAD_ROTATE_SPEED * dt)

		changed = true
	end

	if self.gamepadScaleDir ~= 0 then
		local mul = 1 + self.gamepadScaleDir * GAMEPAD_SCALE_SPEED * dt
		local scaleX = rect.localScale.x

		if mul < 1 and (scaleX <= GAMEPAD_MIN_SCALE or scaleX * mul <= GAMEPAD_MIN_SCALE) then
			rect.localScale = Vector3(GAMEPAD_MIN_SCALE, GAMEPAD_MIN_SCALE, GAMEPAD_MIN_SCALE)

			if moved then
				local cur = rect.localPosition

				constrainFramePosition(rect, self.ctrl.dIYRootRectTransform, cur.x, cur.y)
			end

			if self.ctrl.scheduleHistoryStep then
				self.ctrl:scheduleHistoryStep("diy_transform", 0.2)
			end

			return
		end

		rect.localScale = rect.localScale * mul

		local objectReference = self.curSelectFrame:GetComponent("ObjectReference")
		local btnClose = objectReference:GetRefValue("btnCloseUButton")
		local btnZoom = objectReference:GetRefValue("btnZoomUWidget")
		local btnRotate = objectReference:GetRefValue("btnRotateUButton")

		btnClose.transform.localScale = btnClose.transform.localScale / mul
		btnZoom.transform.localScale = btnZoom.transform.localScale / mul
		btnRotate.transform.localScale = btnRotate.transform.localScale / mul
		changed = true
	end

	if moved then
		local cur = rect.localPosition

		constrainFramePosition(rect, self.ctrl.dIYRootRectTransform, cur.x, cur.y)
	end

	if changed and self.ctrl.scheduleHistoryStep then
		self.ctrl:scheduleHistoryStep("diy_transform", 0.2)
	end
end

function PhotoFuncDIYUIComponent:onSelectFrame(obj)
	if self.curSelectFrame == obj then
		return
	end

	if not IsNil(self.curSelectFrame) and self.curSelectFrame ~= obj then
		local objectReference = self.curSelectFrame:GetComponent("ObjectReference")
		local rootUButton = objectReference:GetRefValue("rootUButton")

		rootUButton:TryChangePage("Status", 1)
	end

	self.curSelectFrame = obj

	if obj == nil then
		self.curSelectRootButton = nil

		return
	end

	local objectReference = obj:GetComponent("ObjectReference")
	local rootUButton = objectReference:GetRefValue("rootUButton")

	rootUButton:TryChangePage("Status", 0)

	self.curSelectRootButton = rootUButton
end

function PhotoFuncDIYUIComponent:destroyFrame(obj)
	if not obj then
		return
	end

	if obj == self.curSelectFrame then
		self.curSelectFrame = nil
		self.curSelectRootButton = nil
	end

	local instanceUid = self.frameInstanceUids[obj]

	self.frameObjects[obj] = nil
	self.frameInstanceUids[obj] = nil

	if instanceUid then
		self.instanceUidFrames[instanceUid] = nil
	end

	self.view:destroyInstance(obj)

	self.curCount = self.curCount - 1

	ClientTextUtils.setText(self.textLimitUBaseText, string.format("%s/%s", self.curCount, LimitCount))
	self:refreshCanFocusStickState()
end

function PhotoFuncDIYUIComponent:onBeginPhoto(root)
	self:onSelectFrame(nil)

	for k, v in pairs(self.frameObjects) do
		k.transform:SetParent(root, false)
	end
end

function PhotoFuncDIYUIComponent:deselectAllDIY()
	self:onSelectFrame(nil)
end

function PhotoFuncDIYUIComponent:onEndPhoto(root)
	for k, v in pairs(self.frameObjects) do
		k.transform:SetParent(root, false)
	end

	self.ctrl.dIYRootRectTransform.gameObject:SetActiveEx(false)
	self.ctrl.dIYRootRectTransform.gameObject:SetActiveEx(true)
end

return PhotoFuncDIYUIComponent
