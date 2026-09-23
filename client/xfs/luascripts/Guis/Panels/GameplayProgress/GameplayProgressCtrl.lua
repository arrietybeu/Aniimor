-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameplayProgress\\GameplayProgressCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GameplayProgressCtrl = Class.LightClass("GameplayProgressCtrl", UICtrl)

function GameplayProgressCtrl:ctor()
	UICtrl.ctor(self)

	self.total = 1
	self.count = 0
	self.text = ""
	self.finished = false
end

function GameplayProgressCtrl:onCreate(info)
	GameplayProgressCtrl.super.onCreate(self, info)
end

function GameplayProgressCtrl:onShow()
	GameplayProgressCtrl.super.onShow(self)
	self.view:initProgress(self.count, self.total, self.text, self.vehicle)
end

function GameplayProgressCtrl:initProgress(count, total, text, cb, vehicle)
	self.total = total
	count = math.clamp(count, 0, self.total)
	self.count = count
	self.text = text
	self.finished = false
	self.cb = cb
	self.vehicle = vehicle

	if not self.view then
		return
	end

	self.view:initProgress(count, total, text, vehicle)
end

function GameplayProgressCtrl:setCount(count)
	count = math.clamp(count, 0, self.total)
	self.count = count

	if self.finished then
		return
	end

	if self.count == self.total then
		self.finished = true

		if self.cb then
			self.cb()
		end
	end

	if not self.view then
		return
	end

	self.view:setCount(self.count)
end

function GameplayProgressCtrl:shake()
	if not self.view then
		return
	end

	self.view:shake()
end

function GameplayProgressCtrl:onDestroy()
	GameplayProgressCtrl.super.onDestroy(self)
end

return GameplayProgressCtrl
