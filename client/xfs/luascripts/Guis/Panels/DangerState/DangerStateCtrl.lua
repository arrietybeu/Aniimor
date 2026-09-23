-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DangerState\\DangerStateCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("DangerStateCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DangerStateCtrl = Class.LightClass("DangerStateCtrl", UICtrl)

DangerStateCtrl.messages = {}

function DangerStateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function DangerStateCtrl:addListener()
	return
end

function DangerStateCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function DangerStateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DangerStateCtrl:onShow()
	return
end

function DangerStateCtrl:onHide()
	return
end

return DangerStateCtrl
