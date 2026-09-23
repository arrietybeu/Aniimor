-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggResult\\GrabEggResultCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggResultCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggResultCtrl = Class.LightClass("GrabEggResultCtrl", UICtrl)
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")

GrabEggResultCtrl.messages = {}

function GrabEggResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GrabEggResultCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:onBtnFinished()
	end
end

function GrabEggResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GrabEggResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.settlementData = info
end

function GrabEggResultCtrl:onShow()
	local info = self.settlementData.resInfo
	local killed_reason = info.killed_reason

	if info.result == Const.ROB_EGG_RESULT.Failure then
		if killed_reason == Const.ROBEGG_DEATH_REASON.KILLED_BY_PLAYER or killed_reason == Const.ROBEGG_DEATH_REASON.ACCIDENGTAL_DEATH then
			self.view.rootUWidget:TryChangePage("Type", 1)
		elseif killed_reason == Const.ROBEGG_DEATH_REASON.TIME_OUT then
			self.view.rootUWidget:TryChangePage("Type", 2)
		else
			self.view.rootUWidget:TryChangePage("Type", 2)
		end
	else
		self.view.rootUWidget:TryChangePage("Type", 0)
	end

	ClientTextUtils.setText(self.view.txtEarnings, tostring(info.profit))
end

function GrabEggResultCtrl:onBtnFinished()
	pg.me:finishedSettlement()
end

function GrabEggResultCtrl:onHide()
	return
end

return GrabEggResultCtrl
