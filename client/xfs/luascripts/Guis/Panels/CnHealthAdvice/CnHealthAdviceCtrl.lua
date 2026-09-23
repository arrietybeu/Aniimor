-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CnHealthAdvice\\CnHealthAdviceCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CnHealthAdviceCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CnHealthAdviceCtrl = Class.LightClass("CnHealthAdviceCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

CnHealthAdviceCtrl.messages = {}

function CnHealthAdviceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CnHealthAdviceCtrl:addListener()
	return
end

function CnHealthAdviceCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CnHealthAdviceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function CnHealthAdviceCtrl:onShow()
	self.view.rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	ClientTextUtils.setText(self.view.appDesc, pg.getGameString("LEGAL_LOGIN_TIP"))
end

function CnHealthAdviceCtrl:onHide()
	return
end

return CnHealthAdviceCtrl
