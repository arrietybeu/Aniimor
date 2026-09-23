-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ThrowPanel\\Component\\ThrowPanelMobileComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("ThrowPanelMobileComponent")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIConst = require("Const.UIConst")
local ThrowPanelMobileComponent = Class.LightClass("ThrowPanelMobileComponent", UIComponent)

function ThrowPanelMobileComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnThrow = objectReference:GetRefValue("btnThrow")
	self.catchJoystick = objectReference:GetRefValue("catchJoystick")
	self.btnThrowLeft = objectReference:GetRefValue("btnThrowLeft")
	self.btnCancelThrow = objectReference:GetRefValue("btnCancelThrow")
	self.cancelThrowAni = nil

	if self.btnCancelThrow and self.btnCancelThrow.transform then
		self.cancelThrowAni = self.btnCancelThrow.transform:GetComponent("Animation")
	end

	self.isInCancelMode = false
	self._checkEdgeToastTicker = nil
end

function ThrowPanelMobileComponent:initView()
	if not self:checkPanelCatchLoaded() then
		return
	end

	self:initCatchPanel()

	self._checkEdgeToastTicker = self:startTimer(CallbackHandler(self, "checkEdgeToast"), 0.1, true)
end

function ThrowPanelMobileComponent:setCancelMode(isInCancelMode)
	self.isInCancelMode = isInCancelMode

	local cancelState = isInCancelMode and 1 or 0

	if isInCancelMode then
		pg.game.input:setViewAxisByDelta(0, 0)
	end

	self.uWidget:TryChangePage("CancelMode", cancelState)
end

function ThrowPanelMobileComponent:throwBall()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleThrow()
	end
end

function ThrowPanelMobileComponent:checkEdgeToast()
	if not self:checkPanelCatchLoaded() then
		return
	end

	local visible = not pg.global.ui.tips:isEdgeRunning({
		UIConst.UITipPriority.Edge_Quest
	}) and not pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FIRST_SHOW)

	self.uWidget:TryChangePage("BtnLeft_State", visible and 0 or 1)
end

function ThrowPanelMobileComponent:initCatchPanel()
	if not self.btnCancelThrow or not self.btnThrowLeft or not self.btnThrow or not self.catchJoystick then
		logger:warn("initCatchPanel failed: mobile refs are incomplete")

		return
	end

	function self.btnCancelThrow.luaClick()
		if self:checkCatchMode() then
			local function onSwitchCatchMode()
				if pg.game.controller ~= nil then
					pg.game.controller:onHandleSwitchCatchMode()
				end
			end

			if IsNil(self.cancelThrowAni) then
				logger:warn("cancel throw animation is nil, switch catch mode without animation")
				onSwitchCatchMode()
			else
				UIUtils.PlayAnimation(self.cancelThrowAni, "VX_Node_BattleUI_PanelCatch_Mobile_Cancel", onSwitchCatchMode)
			end
		end
	end

	function self.btnCancelThrow.luaHover()
		self:setCancelMode(true)
	end

	function self.btnCancelThrow.luaUnhover()
		self:setCancelMode(false)
	end

	function self.btnCancelThrow.luaRelease()
		self:setCancelMode(false)
		self.uWidget:TryChangePage("expand", 0)

		self.catchJoystick.defaultOpacity = 0

		pg.game.input:setViewAxisByDelta(0, 0)
	end

	function self.btnThrowLeft.luaClick()
		self:throwBall()
	end

	function self.btnThrow.luaPress()
		self.uWidget:TryChangePage("expand", 1)

		self.catchJoystick.defaultOpacity = 1

		self:setCancelMode(false)
	end

	function self.btnThrow.luaRelease()
		if not self.catchJoystick.isDragging then
			self.uWidget:TryChangePage("expand", 0)

			self.catchJoystick.defaultOpacity = 0

			self:throwBall()
		end
	end

	function self.catchJoystick.luaDragUpdate(x, y)
		local ret, page = self.uWidget:TryGetCurrentPage("expand")

		if page == 1 and not self.isInCancelMode then
			pg.game.input:setViewAxisByDeltaPixel(x, y)
		end
	end

	function self.catchJoystick.luaJoyStickEndDrag()
		local ret, page = self.uWidget:TryGetCurrentPage("expand")

		if page == 1 then
			if not self.isInCancelMode then
				self:throwBall()
			end

			self.uWidget:TryChangePage("expand", 0)

			self.catchJoystick.defaultOpacity = 0
		end

		pg.game.input:setViewAxisByDelta(0, 0)
		self:setCancelMode(false)
	end
end

function ThrowPanelMobileComponent:checkPanelCatchLoaded()
	return not IsNil(self.uWidget)
end

function ThrowPanelMobileComponent:checkCatchMode()
	return pg.me and pg.me:isInCatchMode()
end

function ThrowPanelMobileComponent:onDestroy()
	if self._checkEdgeToastTicker then
		self:killTimer(self._checkEdgeToastTicker)

		self._checkEdgeToastTicker = nil
	end

	UIComponent.onDestroy(self)
end

return ThrowPanelMobileComponent
