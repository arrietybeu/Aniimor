-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarLoading\\AvatarLoadingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarLoadingCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local AvatarLoadingCtrl = Class.LightClass("AvatarLoadingCtrl", UICtrl)

AvatarLoadingCtrl.messages = {}

function AvatarLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function AvatarLoadingCtrl:addListener()
	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = 1
	self.view.progressUProgress.value = 0

	self:clearTimer()

	self.oldProgress = 0
	self.tickTimer = self:startTimer(function()
		self:setProgress()
	end, 0.01, true)
end

function AvatarLoadingCtrl:setProgress()
	local progress = pg.game.loading:getProgress()

	if progress < self.oldProgress then
		progress = self.oldProgress
	else
		self.oldProgress = progress
	end

	if self.view then
		self.view.numUSDFText.text = tostring(math.modf(progress * 100)) .. "%"
		self.view.progressUProgress.value = progress
	end

	if progress > 0.8 and not self.showReward then
		self.showReward = true

		self.view.widget:TryChangePage("State", 1)
	end

	if self.view.progressUProgress.value >= 1 then
		self:clearTimer()
	end
end

function AvatarLoadingCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function AvatarLoadingCtrl:clearTimer()
	if self.tickTimer then
		self:killTimer(self.tickTimer)
	end

	self.tickTimer = nil
	self.showReward = nil
end

function AvatarLoadingCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:clearTimer()
end

function AvatarLoadingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function AvatarLoadingCtrl:onShow()
	return
end

function AvatarLoadingCtrl:onHide()
	return
end

return AvatarLoadingCtrl
