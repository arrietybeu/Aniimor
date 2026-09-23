-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChatMail\\ChatMailCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ChatMailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ChatMailCtrl = Class.LightClass("ChatMailCtrl", UICtrl)
local MailComponent = require("Guis.Panels.Chat.Component.MailComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")

ChatMailCtrl.messages = {
	[MessageName.RECV_MAIL] = {
		"refreshMailList",
		true
	}
}

function ChatMailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.mailComponent = MailComponent.new(self, self.view.mailTransform)
end

function ChatMailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	LuaUIUtils.bindCommonTipInfo(self.view.infoUButton, pg.getGameString("CHAT_MAIL_TIP"))
end

function ChatMailCtrl:refreshMailList(info)
	self.mailComponent:refreshMailList(info and info.indexDiff)
	self.mailComponent:refreshMailContent(info and info.playAni)
end

function ChatMailCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function ChatMailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ChatMailCtrl:onShow()
	return
end

function ChatMailCtrl:onHide()
	return
end

return ChatMailCtrl
