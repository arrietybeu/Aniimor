-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\PvpMenuCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpMenuCtrl = Class.LightClass("PvpMenuCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local MenuComponent = require("Guis.Panels.PvpMenu.Component.PvpMenuComponent")
local LinkModeComponent = require("Guis.Panels.PvpMenu.Component.PvpLinkModeComponent")
local PVPMenuSceneComponent = require("Guis.Panels.PvpMenu.Component.PVPMenuSceneComponent")
local MatchConst = require("Common.Const.MatchConst")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")

PvpMenuCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.PVP_MATCH_STATE_CHANGED] = {
		"onMatchStateChanged",
		true
	},
	[MessageName.PVP_MATCH_COVENANT_CANCEL] = {
		"onMatchCovenantCancel",
		true
	}
}

function PvpMenuCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.menuComponent = MenuComponent.new(self, self.view.pageMain)
	self.linkModeComponent = LinkModeComponent.new(self, self.view.page1)
	self.uiSceneCmp = PVPMenuSceneComponent.new(self)
	self.startMatchTime = 0
end

function PvpMenuCtrl:addListener()
	function self.view.btnInviteFriend.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PVP_FRIEND)
	end
end

function PvpMenuCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openPage = info or 0

	pg.game.pvp:reloadMatchType()
	self:enterUIScene()
end

function PvpMenuCtrl:checkCanOpen(showNotice, info)
	if LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PVP) then
		return true
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("LEARN_SKILL_TIPS"), 3)

	return false
end

function PvpMenuCtrl:enterUIScene()
	if pg.me:isMatchStatusInMatch() then
		self:switchPage(1)
	else
		self:switchPage(self.openPage)
	end

	pg.game.pvp:playPvpBGM("bgm_battle_pvp_prepare", "None")
end

function PvpMenuCtrl:onHide()
	pg.game.pvp:playPvpBGM()
end

function PvpMenuCtrl:hidePanel()
	self:hide()
end

function PvpMenuCtrl:switchPage(page)
	if page == 1 then
		self.view.component:TryChangePage("State", 1)
		self.linkModeComponent:onShow()
	else
		self.view.component:TryChangePage("State", 0)
		self.menuComponent:onShow()
	end

	self:onMatchStateChanged()
	self.uiSceneCmp:switchPage(page)
end

function PvpMenuCtrl:enterMatch()
	self.startMatchTime = Time.realSecondCache

	if self.matchTick then
		self:killTimer(self.matchTick)
	end

	self.matchTick = self:startTimer(function()
		self:onTimeTick()
	end, 0.02, true)

	self.uiSceneCmp:switchMatchState(true)
end

function PvpMenuCtrl:onTimeTick()
	local totalTime = Time.realSecondCache - self.startMatchTime
	local timeStr = TimeUtils.timeToFormatString(totalTime)

	self.linkModeComponent:viewTickTimer(timeStr)
	self.uiSceneCmp:viewTickTimer(timeStr)
end

function PvpMenuCtrl:exitMatch()
	if self.matchTick then
		self:killTimer(self.matchTick)
	end

	self.matchTick = nil

	self.uiSceneCmp:switchMatchState(false)
end

function PvpMenuCtrl:onCancelPVP()
	pg.me:cancelPvpBattle()
	self:switchPage(0)
end

function PvpMenuCtrl:onMatchStateChanged()
	if pg.me:isMatchStatusInit() then
		self.view.component:TryChangePage("InviFriends", 0)
	elseif pg.me:isMatchStateInInvite() then
		self.view.component:TryChangePage("InviFriends", 1)
	elseif pg.me:isMatchStatusInModify() then
		self.view.component:TryChangePage("InviFriends", 2)
		self.linkModeComponent:setEnemyInfo()
	elseif pg.me:isMatchStatusInMatch() then
		self.linkModeComponent:confirmMatchPostProcessing()
	end

	self.linkModeComponent:onMatchStateChanged()
end

function PvpMenuCtrl:onMatchCovenantCancel()
	self:dismiss()
end

function PvpMenuCtrl:onInputDeviceChanged(deviceType)
	return
end

function PvpMenuCtrl:onDestroy()
	if self.matchTick then
		self:killTimer(self.matchTick)
	end

	self.matchTick = nil

	UICtrl.onDestroy(self)
end

return PvpMenuCtrl
