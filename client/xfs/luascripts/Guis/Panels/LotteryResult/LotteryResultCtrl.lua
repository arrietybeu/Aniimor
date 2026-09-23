-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryResult\\LotteryResultCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LotteryResultModel = require("Guis.Panels.LotteryResult.LotteryResultModel")
local LotteryResultCtrl = Class.LightClass("LotteryResultCtrl", UICtrl)

LotteryResultCtrl.modelClz = LotteryResultModel
LotteryResultCtrl.messages = {}

function LotteryResultCtrl:addListener()
	if self.view.btnBackCloseUButton then
		function self.view.btnBackCloseUButton.luaClick()
			self:dismiss()
		end
	end
end

function LotteryResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view:setInfo(self.model:buildViewData(info))
end

return LotteryResultCtrl
