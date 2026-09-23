-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BlackChange\\BlackChangeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DoTweenAnimMgr = DoTweenAnimMgr
local ID_FADE_IN = "fadeIn"
local ID_FADE_OUT = "fadeOut"
local BlackChangeCtrl = Class.LightClass("BlackChangeCtrl", UICtrl)

function BlackChangeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BlackChangeCtrl:onDestroy()
	self.showingBlack = false

	UICtrl.onDestroy(self)
end

function BlackChangeCtrl:triggerCallback()
	if self.callback then
		local callback = self.callback

		self.callback = nil

		if callback then
			callback()
		end
	end
end

function BlackChangeCtrl:blackChangeIn(inTime)
	if self.view == nil then
		return
	end

	if self.view.blackImage.renderOpacity == 1 then
		return
	end

	self.showingBlack = true
	self.view.blackImage.renderOpacity = 0

	local changeTime = inTime or 0.3

	if self.view then
		DoTweenAnimMgr.DoAlpha(self.view.blackImage, LuaUIUtils.TweenId(ID_FADE_IN), 1, changeTime, 0)
	end
end

function BlackChangeCtrl:blackChangeOut(outTime)
	if self.view == nil then
		return
	end

	DoTweenAnimMgr.Kill(self.view.blackImage.gameObject, LuaUIUtils.TweenId(ID_FADE_IN), true)

	if self.view.blackImage.renderOpacity == 0 then
		return
	end

	self.showingBlack = false

	local changeTime = outTime or 0.3

	DoTweenAnimMgr.DoAlpha(self.view.blackImage, LuaUIUtils.TweenId(ID_FADE_OUT), 0, changeTime, 0)
end

return BlackChangeCtrl
