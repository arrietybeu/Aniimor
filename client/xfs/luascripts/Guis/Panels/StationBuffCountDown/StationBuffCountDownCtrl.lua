-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StationBuffCountDown\\StationBuffCountDownCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local StationBuffCountDownCtrl = Class.LightClass("StationBuffCountDownCtrl", UICtrl)

function StationBuffCountDownCtrl:ctor()
	UICtrl.ctor(self)

	self.total = 1
	self.count = 0
	self.finished = false
	self.finishTimer = nil
end

function StationBuffCountDownCtrl:onCreate(info)
	StationBuffCountDownCtrl.super.onCreate(self, info)
end

function StationBuffCountDownCtrl:onShow()
	StationBuffCountDownCtrl.super.onShow(self)
	self.view:initProgress(self.count, self.total)
	self:playProgress()
end

function StationBuffCountDownCtrl:initProgress(count, total, cb)
	if self.finishTimer then
		self:killTimer(self.finishTimer)

		self.finishTimer = nil
	end

	self.total = total and total > 0 and total or 1
	self.count = math.clamp(count or 0, 0, self.total)
	self.finished = false
	self.cb = cb

	if not self.view then
		return
	end

	self.view:initProgress(self.count, self.total)
	self:playProgress()
end

function StationBuffCountDownCtrl:playProgress()
	if self.finished or not self.view then
		return
	end

	self.view:playProgressToEnd(function()
		self:onProgressFinished()
	end)
end

function StationBuffCountDownCtrl:setCount(count)
	count = math.clamp(count or 0, 0, self.total)
	self.count = count
end

function StationBuffCountDownCtrl:onProgressFinished()
	if self.finished then
		return
	end

	self.finished = true
	self.count = self.total

	if self.cb then
		self.cb()
	end

	self.finishTimer = self:startTimer(function()
		self.finishTimer = nil

		pg.global.ui:close(UIConst.UI_ID_STATION_BUFF_COUNTDOWN)
	end, 3)
end

function StationBuffCountDownCtrl:onDestroy()
	if self.finishTimer then
		self:killTimer(self.finishTimer)

		self.finishTimer = nil
	end

	StationBuffCountDownCtrl.super.onDestroy(self)
end

return StationBuffCountDownCtrl
