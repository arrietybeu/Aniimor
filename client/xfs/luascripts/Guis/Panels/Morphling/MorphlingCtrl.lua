-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Morphling\\MorphlingCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MorphlingCtrl = Class.LightClass("MorphlingCtrl", UICtrl)

MorphlingCtrl.messages = {
	[MessageName.MORPHLING_STATE_CHANGE] = {
		"onStateChange",
		true
	}
}

function MorphlingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function MorphlingCtrl:onStateChange(state)
	self.view.uiRoot:TryChangePage("State", state)
end

function MorphlingCtrl:addListener()
	return
end

function MorphlingCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MorphlingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.uiRoot:TryChangePage("State", info.state)
end

function MorphlingCtrl:onShow()
	return
end

function MorphlingCtrl:onHide()
	return
end

return MorphlingCtrl
