-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestVlog\\QuestVlogCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local QuestVlogCtrl = Class.LightClass("QuestVlogCtrl", UICtrl)

function QuestVlogCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.time = 0
end

function QuestVlogCtrl:addListener()
	function self.view.btnSkipUButton.luaClick()
		self:dismiss()
	end
end

function QuestVlogCtrl:onShow()
	return
end

function QuestVlogCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:showPanel(info)
end

function QuestVlogCtrl:showPanel(info)
	LuaUIUtils.setUIViewVisible(self.view.btnSkipUButton, false)

	local countDown = self.time

	ClientTextUtils.setText(self.view.countTime, TimeUtils.timeToFormatString(countDown))

	self.updateTimer = self:startTimer(function()
		countDown = countDown + 1

		ClientTextUtils.setText(self.view.countTime, TimeUtils.timeToFormatString(countDown))
	end, 1, true)
end

function QuestVlogCtrl:onHide()
	return
end

function QuestVlogCtrl:clearUpdateTimer()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function QuestVlogCtrl:onDestroy()
	self:clearUpdateTimer()
	UICtrl.onDestroy(self)
end

function QuestVlogCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return QuestVlogCtrl
