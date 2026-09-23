-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchLoading\\PetResearchLoadingCtrl.lua

local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetResearchLoadingCtrl = Class.LightClass("PetResearchLoadingCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LOADING_VALUE_TWEEN_ID = "loadingValue"

PetResearchLoadingCtrl.messages = {}

function PetResearchLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetResearchLoadingCtrl:addListener()
	return
end

function PetResearchLoadingCtrl:onDestroy()
	DoTweenAnimMgr.Kill(self.view.widget.gameObject, LuaUIUtils.TweenId(LOADING_VALUE_TWEEN_ID), true)
	UICtrl.onDestroy(self)
end

function PetResearchLoadingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.me:serverMsg("RPC_CS_UpdateUIOpened", UIConst.UI_ID_PET_RESEARCH, true)
	DoTweenAnimMgr.DoFloat(self.view.widget.gameObject, 0, 100, LuaUIUtils.TweenId(LOADING_VALUE_TWEEN_ID), 1.5, 0.37, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(v)
		ClientTextUtils.setText(self.view.loadingProgressNumUSDFText, math.floor(v) .. "%")
	end, function()
		return
	end, false)
	self:startTimer(function()
		pg.global.ui.petResearch:open(info)
	end, 1.5)
end

function PetResearchLoadingCtrl:onShow()
	return
end

function PetResearchLoadingCtrl:onHide()
	return
end

return PetResearchLoadingCtrl
