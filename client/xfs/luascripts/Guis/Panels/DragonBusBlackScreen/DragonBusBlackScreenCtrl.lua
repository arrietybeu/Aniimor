-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DragonBusBlackScreen\\DragonBusBlackScreenCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DragonBusBlackScreenCtrl = Class.LightClass("DragonBusBlackScreenCtrl", UICtrl)

DragonBusBlackScreenCtrl.messages = {}

function DragonBusBlackScreenCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	local duration = info and info[1]

	if duration == nil or type(duration) ~= "number" then
		duration = 2
	end

	self:startTimer(function()
		if pg.global.scene:isSceneValid() then
			self:closeUI()
		else
			self:startTime(function()
				if pg.global.scene:isSceneValid() then
					self:closeUI()
				end
			end, 0.1, true)
		end
	end, duration)
end

function DragonBusBlackScreenCtrl:closeUI()
	if self.info and self.info.closeCb then
		self.info.closeCb()
	end

	self:close()
end

function DragonBusBlackScreenCtrl:addListener()
	return
end

function DragonBusBlackScreenCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function DragonBusBlackScreenCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DragonBusBlackScreenCtrl:onShow()
	return
end

function DragonBusBlackScreenCtrl:onHide()
	return
end

return DragonBusBlackScreenCtrl
