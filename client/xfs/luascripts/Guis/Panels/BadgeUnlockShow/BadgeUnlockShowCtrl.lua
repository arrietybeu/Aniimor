-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeUnlockShow\\BadgeUnlockShowCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeUnlockShowCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BadgeUnlockShowComponent = require("Guis.Panels.BadgeUnlockShow.BadgeUnlockShowComponent")
local BadgeUnlockShowCtrl = Class.LightClass("BadgeUnlockShowCtrl", UICtrl)

BadgeUnlockShowCtrl.messages = {}

function BadgeUnlockShowCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BadgeUnlockShowCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BadgeUnlockShowCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.showComponent = BadgeUnlockShowComponent.new(self, self.view.widget, info)

	pg.game.audio:playEvent("SFX_UI_BadgeSystem_BadgeBoxCollect_01")
end

return BadgeUnlockShowCtrl
