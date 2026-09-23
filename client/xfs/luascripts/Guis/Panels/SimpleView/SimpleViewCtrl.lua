-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SimpleView\\SimpleViewCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local SimpleViewCtrl = Class.LightClass("SimpleViewCtrl", UICtrl)

SimpleViewCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SimpleViewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isImage = info.isImage
	self.imageUrl = info.imageUrl
	self.videoUrl = info.videoUrl

	self:Init()
end

function SimpleViewCtrl:onShow()
	return
end

function SimpleViewCtrl:onHide()
	return
end

function SimpleViewCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function SimpleViewCtrl:Init()
	self.view.root:TryChangePage("Type", not self.isImage and 1 or 0)
	self.view.infoWidgetUWidget.gameObject:SetActiveEx(false)
	self.view.locationIconUImage.gameObject:SetActiveEx(false)
	self.view.loactionTextUSDFText.gameObject:SetActiveEx(false)
	self.view.layoutBtnUWidget.gameObject:SetActiveEx(false)

	if self.isImage then
		self.view.photoUImage.url = self.imageUrl
	else
		self.view.videoPlayerVideoPlayer.resID = self.videoUrl
	end
end

function SimpleViewCtrl:destroy()
	return
end

function SimpleViewCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end
end

function SimpleViewCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_SIMPLE_VIEW)
end

return SimpleViewCtrl
