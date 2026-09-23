-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareBubble\\MarkShareBubbleCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MarkShareBubbleCtrl = Class.LightClass("MarkShareBubbleCtrl", UICtrl)

MarkShareBubbleCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function MarkShareBubbleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	pg.game.markShare.bubbleHelper:init(self.view.bubbleTransform.gameObject)
end

function MarkShareBubbleCtrl:onOpen(info)
	return
end

function MarkShareBubbleCtrl:onShow()
	return
end

function MarkShareBubbleCtrl:onHide()
	return
end

function MarkShareBubbleCtrl:destroy()
	return
end

function MarkShareBubbleCtrl:addListener()
	return
end

function MarkShareBubbleCtrl:onDestroy()
	UICtrl.onDestroy(self)
	pg.game.markShare.bubbleHelper:destroyBubble()
end

function MarkShareBubbleCtrl:onInputDeviceChanged(deviceType)
	return
end

return MarkShareBubbleCtrl
