-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ColorPicker\\ColorPickerCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ColorPickerCtrl = Class.LightClass("ColorPickerCtrl", UICtrl)
local TimerManager = require("Core.Timer.TimerManager")

ColorPickerCtrl.messages = {}

function ColorPickerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.originColor = info.color
	self.colorValueChangedCb = info.colorValueChangedCb
	self.cancelCb = info.cancelCb
	self.confirmCb = info.confirmCb
	self.closeCb = info.closeCb
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.bubbleComponent = SliderBubbleComponent.new(self, self.view.bubbleUComponent.transform, {
		type = 1
	})

	self.bubbleComponent:hide()

	self.onPress = false

	local colorAreas = info.colorAreas or {
		0,
		1,
		0,
		1
	}

	self.view.rGBRectU2DSlider:SetMinMaxValue(colorAreas[1], colorAreas[2], colorAreas[3], colorAreas[4])
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("BACK_TO_PRE"))
end

function ColorPickerCtrl:closePanel()
	self.view.colorUColorPicker.enableValueChangedCallback = false
	self.view.colorUColorPicker.color = self.originColor
	self.view.colorUColorPicker.enableValueChangedCallback = true

	if self.cancelCb then
		self:cancelCb()
	end

	UICtrl.closePanel(self)
end

function ColorPickerCtrl:addListener()
	function self.view.colorUColorPicker.luaValueChanged(colorCode)
		if self.colorValueChangedCb then
			self:colorValueChangedCb(colorCode)
		end

		local r, g, b, a = lume.color(colorCode)

		self.view.handleUImage.color = Color(r, g, b, a)

		if self.showTimer then
			TimerManager.removeTimer(self.showTimer)
		end

		if not self.onPress then
			self.showTimer = TimerManager.addTimer(0.75, function()
				if not self.onPress then
					-- block empty
				end
			end)
		end
	end

	function self.view.colorUColorPicker.luaOnRelease()
		self.onPress = false
	end

	function self.view.colorUColorPicker.luaOnPress()
		self.onPress = true
	end

	function self.view.backUButton.luaClick()
		self:closePanel()
	end

	function self.view.confirmUButton.luaClick()
		if self.confirmCb then
			self:confirmCb(self.view.colorUColorPicker.colorCode)
		end

		self:dismiss()
	end

	function self.view.resetUButton.luaClick()
		self.view.colorUColorPicker.enableValueChangedCallback = false
		self.view.colorUColorPicker.color = self.originColor
		self.view.colorUColorPicker.enableValueChangedCallback = true
		self.view.handleUImage.color = self.originColor

		if self.colorValueChangedCb then
			self:colorValueChangedCb(self.view.colorUColorPicker.colorCode)
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end
end

function ColorPickerCtrl:onDestroy()
	self.originColor = nil
	self.colorValueChangedCb = nil
	self.cancelCb = nil
	self.confirmCb = nil
	self.avatarScene = nil

	if self.closeCb then
		self.closeCb()
	end

	UICtrl.onDestroy(self)
end

function ColorPickerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)

	self.view.colorUColorPicker.enableValueChangedCallback = false
	self.view.colorUColorPicker.color = self.originColor
	self.view.colorUColorPicker.enableValueChangedCallback = true
	self.view.handleUImage.color = self.originColor
end

function ColorPickerCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_ColorPicker_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_ColorPicker_CameraMove", true)
end

function ColorPickerCtrl:onShow()
	return
end

function ColorPickerCtrl:onHide()
	return
end

function ColorPickerCtrl:onVisibleChange(visible)
	if self.avatarScene then
		if visible then
			self.avatarScene:registerGesture(self.uid, {
				maskRayBoxTrans = self.view.maskRayBoxTrans
			})
		else
			self.avatarScene:unRegisterGesture(self.uid)
		end
	end
end

return ColorPickerCtrl
