-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ThrowPanel\\ThrowPanelCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ThrowPanelCtrl")
local ThrowPanelMobileComponent = require("Guis.Panels.ThrowPanel.Component.ThrowPanelMobileComponent")
local ThrowPanelPCComponent = require("Guis.Panels.ThrowPanel.Component.ThrowPanelPCComponent")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ThrowPanelCtrl = Class.LightClass("ThrowPanelCtrl", UICtrl)

ThrowPanelCtrl.messages = {
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	}
}

function ThrowPanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.throwComponent = nil
end

function ThrowPanelCtrl:onOpen()
	self:loadPlatformComponent()
end

function ThrowPanelCtrl:onShow()
	pg.global.ui:hide(UIConst.UI_ID_INTERACT)
end

function ThrowPanelCtrl:onHide()
	pg.global.ui:show(UIConst.UI_ID_INTERACT)
end

function ThrowPanelCtrl:loadPlatformComponent()
	if self.throwComponent then
		return
	end

	if not self.view.rootWidget then
		logger:warn("loadPlatformComponent failed: rootWidget is nil")

		return
	end

	local transform = self.view.rootWidget.transform or self.view.rootWidget

	if not transform then
		logger:warn("loadPlatformComponent failed: rootWidget transform is nil")

		return
	end

	if pg.global.ui:runPlatformByMobile() then
		self.throwComponent = ThrowPanelMobileComponent.new(self, transform)
	else
		self.throwComponent = ThrowPanelPCComponent.new(self, transform)
	end
end

function ThrowPanelCtrl:onCatchModeChange(enable)
	if not enable then
		self:hide()
	end
end

function ThrowPanelCtrl:onDestroy()
	self.throwComponent = nil

	UICtrl.onDestroy(self)
end

return ThrowPanelCtrl
