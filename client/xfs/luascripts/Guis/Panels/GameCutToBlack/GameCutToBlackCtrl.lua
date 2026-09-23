-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameCutToBlack\\GameCutToBlackCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GameCutToBlackCtrl = Class.LightClass("GameCutToBlackCtrl", UICtrl)

GameCutToBlackCtrl.messages = {}

function GameCutToBlackCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GameCutToBlackCtrl:addListener()
	return
end

function GameCutToBlackCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GameCutToBlackCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	UIUtils.PlayAnimation(self.view.maskImgAnimation, "VX_Pb_CutTo", function()
		self:dismiss()

		if info and info.callback then
			info.callback()
		end
	end)
end

function GameCutToBlackCtrl:onShow()
	return
end

function GameCutToBlackCtrl:onHide()
	return
end

return GameCutToBlackCtrl
