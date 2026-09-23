-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpLoading\\PvpLoadingCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpLoadingCtrl = Class.LightClass("PvpLoadingCtrl", UICtrl)
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")

PvpLoadingCtrl.messages = {}

function PvpLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PvpLoadingCtrl:addListener()
	return
end

function PvpLoadingCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpLoadingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PvpLoadingCtrl:onShow()
	TimerManager.addNextFrameCb(function()
		self.model:initEndTime()
		self:refreshView()
		self:startLoading()
	end)
end

function PvpLoadingCtrl:refreshView()
	local infos = self.model:getTeamInfos()

	if infos == nil then
		return
	end

	ClientTextUtils.setText(self.view.name1, infos.selfInfo.name)

	self.view.rankIcon1.url = infos.srData.icon

	ClientTextUtils.setText(self.view.name2, infos.enemyInfo.name)

	self.view.rankIcon2.url = infos.orData.icon
end

function PvpLoadingCtrl:startLoading()
	if self.ticId then
		self:killTimer(self.ticId)
	end

	self.ticId = self:startTimer(function()
		self:updateProgress()
	end, 0.03, true)

	self:updateProgress()
end

function PvpLoadingCtrl:updateProgress()
	local progress = pg.global.scene:getLoadingProgress()
	local tProgress = self.model:getLoadingProgress()

	progress = tProgress

	if progress >= 1 then
		self:onFinished()
	end

	if self.view then
		self.view.progress.value = progress
	end
end

function PvpLoadingCtrl:onHide()
	self:onFinished()
end

function PvpLoadingCtrl:onFinished()
	if not self.model:checkLoadingFinished() then
		self:show()

		return
	end

	self:hide()

	if self.ticId then
		self:killTimer(self.ticId)
	end

	self.ticId = nil
end

return PvpLoadingCtrl
