-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NetLoading\\NetLoadingCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NetLoadingCtrl = Class.LightClass("NetLoadingCtrl", UICtrl)

NetLoadingCtrl.messages = {}

function NetLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function NetLoadingCtrl:addListener()
	return
end

function NetLoadingCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function NetLoadingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info and info.reconnectCount then
		ClientTextUtils.setText(self.view.textLoadingUBaseText, string.format(pg.getGameString("NET_RECONNECT_LOADING"), info.reconnectCount, info.maxReconnectCount or ""))
	end
end

function NetLoadingCtrl:onShow()
	return
end

function NetLoadingCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function NetLoadingCtrl:onHide()
	return
end

return NetLoadingCtrl
