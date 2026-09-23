-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeTip\\PetExchangeTipCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeTipCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetExchangeTipCtrl = Class.LightClass("PetExchangeTipCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

PetExchangeTipCtrl.messages = {}

function PetExchangeTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	ClientTextUtils.setText(self.view.txtContentUBaseText, info.desc)

	local autoVer = info.autoVer or false
	local autoHor = info.autoHor or false

	self.view.rootUPopupForm:SetAutoVertical(autoVer, autoHor)
	self.view.rootUPopupForm:OpenPopup(info.targetRect)
end

function PetExchangeTipCtrl:addListener()
	self:bindCommonCloseHotKey(function()
		self:close()
	end)

	function self.view.rootUPopupForm.luaCloseAction()
		self:close()
	end
end

function PetExchangeTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetExchangeTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetExchangeTipCtrl:onShow()
	return
end

function PetExchangeTipCtrl:onHide()
	return
end

return PetExchangeTipCtrl
