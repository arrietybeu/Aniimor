-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingOperation\\SettingOperationCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local SettingOperationCtrl = Class.LightClass("SettingOperationCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")

SettingOperationCtrl.messages = {}

function SettingOperationCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local type = info.type or 0

	self.view.uIPbSettingOperationUComponent:TryChangePage("state", type)
end

function SettingOperationCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end
end

function SettingOperationCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SettingOperationCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function SettingOperationCtrl:onShow()
	return
end

function SettingOperationCtrl:onHide()
	return
end

return SettingOperationCtrl
