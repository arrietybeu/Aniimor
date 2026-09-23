-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CnAgeRating\\CnAgeRatingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CnAgeRatingCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CnAgeRatingCtrl = Class.LightClass("CnAgeRatingCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

CnAgeRatingCtrl.messages = {}

function CnAgeRatingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CnAgeRatingCtrl:addListener()
	function self.view.btnConfirm.luaClick()
		self:dismiss()
	end
end

function CnAgeRatingCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CnAgeRatingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function CnAgeRatingCtrl:onShow()
	ClientTextUtils.setText(self.view.scrollRect.content, pg.getGameString("AGE_TIP"))
	self.view.scrollRect:SetRightStickScrollConsoleBar("CONSOLE_BAR_SCROLL_VIEW", -3)
end

function CnAgeRatingCtrl:onHide()
	return
end

return CnAgeRatingCtrl
