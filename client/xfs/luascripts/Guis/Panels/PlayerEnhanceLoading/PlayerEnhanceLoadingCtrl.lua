-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhanceLoading\\PlayerEnhanceLoadingCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerEnhanceLoadingCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerEnhanceLoadingCtrl = Class.LightClass("PlayerEnhanceLoadingCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LOADING_VALUE_TWEEN_ID = "loadingValue"
local LOOP_ANIM = "VX_Ani_Pb_Personal_LoadingPage_Entrance_Loop"
local END_ANIM = "VX_Ani_Pb_Personal_LoadingPage_Entrance_End"
local JOIN_ANIM = "VX_Ani_Pb_Personal_LoadingPage_Join_In"
local REQUEST_ENTER_TIMELINE_DELAY = 0.5

PlayerEnhanceLoadingCtrl.messages = {}

function PlayerEnhanceLoadingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerEnhanceLoadingCtrl:addListener()
	function self.view.btnEnterUButton.luaClick()
		self:startEnter()
	end

	ClientTextUtils.setText(self.view.submitTextUSDFText, pg.getGameString("OPEN_PLAYER_ENHANCE"))
	ClientTextUtils.setText(self.view.textTtileUSDFText, pg.getGameString("ACADEMIC_TITLE"))
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("TITLE_NEWBIE"))
	ClientTextUtils.setText(self.view.schoolTitleUSDFText, pg.getGameString("COLLEGE_EMBLEM"))
	ClientTextUtils.setText(self.view.schoolDesc1USDFText, pg.getGameString("COLLEGE_NUM"))
	ClientTextUtils.setText(self.view.schoolDesc2USDFText, pg.getGameString("COLLEGE_TYPE"))
end

function PlayerEnhanceLoadingCtrl:onDestroy()
	pg.game.audio:stopEvent("SFX_UI_Personal_FirstOpen_Loop")
	DoTweenAnimMgr.Kill(self.view.widget.gameObject, LuaUIUtils.TweenId(LOADING_VALUE_TWEEN_ID), true)
	self:killTimer(self.loopAnimId)

	local _h = PlayerEnhanceLoadingCtrl._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	self.info = nil
	self.uiOpenCb = nil
	self.entering = nil

	UICtrl.onDestroy(self)
end

function PlayerEnhanceLoadingCtrl:onOpen(param, uiOpenCb)
	self.info = param or {}
	self.info.firstEnter = true
	self.uiOpenCb = uiOpenCb

	pg.game.audio:playEvent("SFX_UI_Personal_Entrance_In")

	self.loopAnimId = self:startTimer(function()
		pg.game.audio:playEvent("SFX_UI_Personal_FirstOpen_Loop")
		self.view.rootAnim:Play(LOOP_ANIM)
		pg.global.ui.playerEnhance:open(self.info, self.uiOpenCb, nil, nil, nil, true)

		local _h = PlayerEnhanceLoadingCtrl._platformHooks

		if _h and _h.afterOpenPlayerEnhanceInBackground then
			_h.afterOpenPlayerEnhanceInBackground(self)
		end
	end, 1)
end

function PlayerEnhanceLoadingCtrl:onShow()
	local _h = PlayerEnhanceLoadingCtrl._platformHooks

	if _h and _h.onShow then
		_h.onShow(self)
	end
end

function PlayerEnhanceLoadingCtrl:onHide()
	local _h = PlayerEnhanceLoadingCtrl._platformHooks

	if _h and _h.onHide then
		_h.onHide(self)
	end
end

function PlayerEnhanceLoadingCtrl:startEnter()
	if self.entering then
		return
	end

	self.entering = true

	local _h = PlayerEnhanceLoadingCtrl._platformHooks

	if _h and _h.onStartEnter then
		_h.onStartEnter(self)
	end

	self:killTimer(self.loopAnimId)
	pg.game.audio:stopEvent("SFX_UI_Personal_FirstOpen_Loop")

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_PLAYER_ENHANCEMENT) then
		pg.global.ui.playerEnhance:open(self.info, self.uiOpenCb, nil, nil, nil, true)
	end

	pg.game.audio:playEvent("SFX_UI_Personal_Active")
	self.view.rootAnim:Play(END_ANIM)
	self:startTimer(function()
		self:_playEnterAnim()
	end, 1)
end

function PlayerEnhanceLoadingCtrl:_playEnterAnim()
	pg.game.audio:playEvent("SFX_UI_Personal_GatherInfo")
	self.view.rootCmp:TryChangePage("Laoding", 1)
	self.view.rootAnim:Play(JOIN_ANIM)
	pg.me:serverMsg("RPC_CS_UpdateUIOpened", UIConst.UI_ID_PLAYER_ENHANCEMENT, true)
	DoTweenAnimMgr.DoFloat(self.view.widget.gameObject, 0, 100, LuaUIUtils.TweenId(LOADING_VALUE_TWEEN_ID), 1, 0.3, CS.DG.Tweening.Ease.__CastFrom(1), function()
		return
	end, function(v)
		ClientTextUtils.setText(self.view.loadingProgressNumUSDFText, math.floor(v) .. "%")
	end, function()
		return
	end, false)
	self:startTimer(function()
		pg.global.ui.playerEnhance:requestPlayModelEnterTimeline()
	end, REQUEST_ENTER_TIMELINE_DELAY)
end

return PlayerEnhanceLoadingCtrl
