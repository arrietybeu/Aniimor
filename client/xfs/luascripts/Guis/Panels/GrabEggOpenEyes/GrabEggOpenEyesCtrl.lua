-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggOpenEyes\\GrabEggOpenEyesCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggOpenEyesCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggOpenEyesCtrl = Class.LightClass("GrabEggOpenEyesCtrl", UICtrl)

GrabEggOpenEyesCtrl.messages = {}

function GrabEggOpenEyesCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GrabEggOpenEyesCtrl:addListener()
	self.rootWidget = self.view.widget
end

function GrabEggOpenEyesCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GrabEggOpenEyesCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function GrabEggOpenEyesCtrl:onShow()
	return
end

function GrabEggOpenEyesCtrl:playOpenEyesAnimation()
	self.rootWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self:close()
	end)
end

function GrabEggOpenEyesCtrl:onHide()
	return
end

return GrabEggOpenEyesCtrl
