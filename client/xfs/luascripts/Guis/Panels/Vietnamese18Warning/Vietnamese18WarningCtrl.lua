-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Vietnamese18Warning\\Vietnamese18WarningCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Vietnamese18WarningCtrl = Class.LightClass("Vietnamese18WarningCtrl", UICtrl)
local RectTransformUtility = CS.UnityEngine.RectTransformUtility
local Screen = CS.UnityEngine.Screen
local UWidget = CS.XGUI.UWidget

local function clampButtonToScreen(btnRectTransform)
	local rect = btnRectTransform.rect
	local camera = UWidget.uiCamera
	local corners = {
		Vector3.New(rect.xMin, rect.yMin, 0),
		Vector3.New(rect.xMin, rect.yMax, 0),
		Vector3.New(rect.xMax, rect.yMin, 0),
		Vector3.New(rect.xMax, rect.yMax, 0)
	}
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge

	for _, localCorner in ipairs(corners) do
		local worldCorner = btnRectTransform:TransformPoint(localCorner)
		local screenCorner = RectTransformUtility.WorldToScreenPoint(camera, worldCorner)

		minX = math.min(minX, screenCorner.x)
		minY = math.min(minY, screenCorner.y)
		maxX = math.max(maxX, screenCorner.x)
		maxY = math.max(maxY, screenCorner.y)
	end

	local deltaX, deltaY = 0, 0

	if maxX - minX > Screen.width then
		deltaX = Screen.width * 0.5 - (minX + maxX) * 0.5
	elseif minX < 0 then
		deltaX = -minX
	elseif maxX > Screen.width then
		deltaX = Screen.width - maxX
	end

	if maxY - minY > Screen.height then
		deltaY = Screen.height * 0.5 - (minY + maxY) * 0.5
	elseif minY < 0 then
		deltaY = -minY
	elseif maxY > Screen.height then
		deltaY = Screen.height - maxY
	end

	if deltaX == 0 and deltaY == 0 then
		return
	end

	local pivotScreenPos = RectTransformUtility.WorldToScreenPoint(camera, btnRectTransform.position)
	local correctedScreenPos = Vector2.New(pivotScreenPos.x + deltaX, pivotScreenPos.y + deltaY)
	local success, correctedLocalPos = RectTransformUtility.ScreenPointToLocalPointInRectangle(btnRectTransform.parent, correctedScreenPos, camera)

	if success then
		local position = btnRectTransform.localPosition

		btnRectTransform.localPosition = Vector3.New(correctedLocalPos.x, correctedLocalPos.y, position.z)
	end
end

function Vietnamese18WarningCtrl:checkPlatform()
	return ClientConfigGameChannelName == "vietnam" and pg.global.sdkManager:isClientIPCountry("VN")
end

function Vietnamese18WarningCtrl:addListener()
	local btn = self.view.btn
	local btnRectTransform = self.view.btnRectTransform

	if not btn or not btnRectTransform then
		return
	end

	btn.draggable = true

	function btn.luaBeginDrag(screenPos)
		local parentRectTransform = btnRectTransform.parent
		local success, localPoint = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRectTransform, screenPos, UWidget.uiCamera)

		if not success then
			self.dragOffsetX = 0
			self.dragOffsetY = 0

			return
		end

		self.dragOffsetX = btnRectTransform.localPosition.x - localPoint.x
		self.dragOffsetY = btnRectTransform.localPosition.y - localPoint.y
	end

	function btn.luaDrag(screenPos)
		local parentRectTransform = btnRectTransform.parent
		local success, localPoint = RectTransformUtility.ScreenPointToLocalPointInRectangle(parentRectTransform, screenPos, UWidget.uiCamera)

		if not success then
			return
		end

		local position = btnRectTransform.localPosition

		btnRectTransform.localPosition = Vector3.New(localPoint.x + (self.dragOffsetX or 0), localPoint.y + (self.dragOffsetY or 0), position.z)

		clampButtonToScreen(btnRectTransform)
	end

	function btn.luaEndDrag()
		clampButtonToScreen(btnRectTransform)

		self.dragOffsetX = nil
		self.dragOffsetY = nil
	end
end

function Vietnamese18WarningCtrl:refreshUIVisible()
	if not self._isOpen or not self.view then
		return
	end

	self._visible = true
	self._adapterVisibilityState = UIConst.UI_ADAPTER_VISIBILITY_STATE.VISIBLE

	if self._curVisible ~= true then
		self._curVisible = true

		self:_setUIVisible(true, nil, false)
	end
end

function Vietnamese18WarningCtrl:hide()
	return
end

function Vietnamese18WarningCtrl:setUIHide()
	return
end

return Vietnamese18WarningCtrl
