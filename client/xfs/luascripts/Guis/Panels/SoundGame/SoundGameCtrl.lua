-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SoundGame\\SoundGameCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local SoundGameCtrl = Class.LightClass("SoundGameCtrl", UICtrl)

function SoundGameCtrl:ctor()
	UICtrl.ctor(self)
end

function SoundGameCtrl:onCreate(info)
	SoundGameCtrl.super.onCreate(self, info)
end

function SoundGameCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.soundGame = info.soundGame
end

function SoundGameCtrl:hit()
	if self.soundGame then
		self.soundGame:hit()
	end
end

function SoundGameCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOPLOGO] = true

	return whiteList
end

function SoundGameCtrl:perfect()
	self.view:perfect()
end

function SoundGameCtrl:miss()
	self.view:miss()
end

function SoundGameCtrl:onShow()
	SoundGameCtrl.super.onShow(self)
end

function SoundGameCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function SoundGameCtrl:onDestroy()
	if self.soundGame then
		self.soundGame:stop()
	end

	SoundGameCtrl.super.onDestroy(self)
end

return SoundGameCtrl
