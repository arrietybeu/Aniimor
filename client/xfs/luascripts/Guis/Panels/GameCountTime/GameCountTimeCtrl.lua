-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameCountTime\\GameCountTimeCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local GameCountTimeCtrl = Class.LightClass("GameCountTimeCtrl", UICtrl)

GameCountTimeCtrl.messages = {}

function GameCountTimeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GameCountTimeCtrl:addListener()
	return
end

function GameCountTimeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GameCountTimeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.widget:TryChangePage("State", 1)
	self:startTimer(function()
		if info and info.callback then
			info.callback()
		else
			self:dismiss()
		end
	end, 3)
end

function GameCountTimeCtrl:onShow()
	return
end

function GameCountTimeCtrl:onHide()
	return
end

function GameCountTimeCtrl:dismiss()
	UICtrl.dismiss(self)
end

return GameCountTimeCtrl
