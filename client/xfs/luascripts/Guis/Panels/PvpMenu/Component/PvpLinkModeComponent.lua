-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\Component\\PvpLinkModeComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpLinkModeComponent = Class.LightClass("PvpLinkModeComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PvpLinkModeComponent:findObjects()
	self.component = self.transform:GetComponent("UComponent")
	self.anim = self.transform:GetComponent("Animation")
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.matchStateName = self.objectReference:GetRefValue("matchStateName")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.matchTime = self.objectReference:GetRefValue("matchTime")
	self.scoreNum = self.objectReference:GetRefValue("scoreNum")
	self.winNum = self.objectReference:GetRefValue("winNum")
	self.keyList = self.objectReference:GetRefValue("keyList")
	self.rivalName = self.objectReference:GetRefValue("rivalName")
end

function PvpLinkModeComponent:initView()
	local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
	local HotkeyConst = require("Const.HotkeyConst")
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closeMatchingPanel()
		end
	end

	function self.btnClose.luaClick()
		self:closeMatchingPanel()
	end

	function self.btnConfirm.luaClick()
		self:onConfirm()
	end

	function self.btnCancel.luaClick()
		self:onCancelOuter()
	end
end

function PvpLinkModeComponent:onShow()
	self:refreshView()
end

function PvpLinkModeComponent:closeMatchingPanel()
	if self:onCancelOuter() then
		return
	end

	self.ctrl:switchPage(0)
end

function PvpLinkModeComponent:refreshView()
	local rankData = self.model:getScoreAndRank()

	ClientTextUtils.setText(self.scoreNum, rankData.score)
	ClientTextUtils.setText(self.winNum, rankData.winNum)
	self.component:TryChangePage("GameMode", pg.game.pvp:isFairMode() and 0 or 1)
	self:onMatchStateChanged()
end

function PvpLinkModeComponent:instantiatePetItem(item, data)
	if data.empty then
		item:TryChangePage("State", 0)

		return
	end

	item:TryChangePage("State", 2)

	local orc = item:GetComponent("ObjectReference")
	local iIcon = orc:GetRefValue("icon")
	local iName = orc:GetRefValue("name")
	local elements = orc:GetRefValue("elements")

	function elements.luaRenderItem(cbt, _, d)
		LuaUIUtils.setElementButtonNew(cbt, d.element)
	end

	iIcon.url = data.icon

	ClientTextUtils.setText(iName, data.name)
	elements:SetList(data.elements)
end

function PvpLinkModeComponent:onMatchStateChanged()
	self:refreshBtnState()
end

function PvpLinkModeComponent:refreshBtnState()
	if pg.me:isMatchStatusInModify() then
		ClientTextUtils.setText(self.txtName, pg.getGameString("PVP_COVENANT_CONFIRM_TEAM"))
	else
		ClientTextUtils.setText(self.txtName, pg.getGameString("PVP_START_MATCH"))
	end

	if pg.me:isMatchStatusInCovenantMatch() then
		ClientTextUtils.setText(self.matchStateName, pg.getGameString("等待中"))
	else
		ClientTextUtils.setText(self.matchStateName, pg.getGameString("匹配中"))
	end
end

function PvpLinkModeComponent:setEnemyInfo()
	local rivalUid = pg.game.pvp:getRivalUID()
	local eInfo = self.model:getPlayerInfoWithUid(rivalUid)

	if eInfo == nil then
		return
	end

	ClientTextUtils.setText(self.rivalName, eInfo.playerName)
end

function PvpLinkModeComponent:onConfirm()
	pg.game.audio:triggerEvent("SFX_UI_PVP_StartMatch")

	if pg.me:isMatchStatusInModify() then
		self:onConfirmEdit()
	elseif pg.me:isMatchStatusInit() then
		self:onStartMatch()
	end
end

function PvpLinkModeComponent:onConfirmEdit()
	local rivalUid = pg.game.pvp:getRivalUID()

	pg.me:confirmInvitePVPTeamInfo(rivalUid)
end

function PvpLinkModeComponent:onStartMatch()
	local res, ownNum = self.model:satisfyMinTeamNum()

	if not res then
		pg.global.showBubbleMessage(2113, ownNum)

		return
	end

	pg.me:startPvpMatch(pg.game.pvp.pvpMode, pg.game.pvp.souDaCheMode, function(state)
		if not state then
			return
		end

		self:confirmMatchPostProcessing()
	end)
end

function PvpLinkModeComponent:confirmMatchPostProcessing()
	if pg.me:isMatchStatusInCovenantMatch() then
		self.component:TryChangePage("SubState", 2)
	else
		self.component:TryChangePage("SubState", 1)
	end

	self.ctrl:enterMatch()
end

function PvpLinkModeComponent:onCancelOuter()
	local isCanceled = false

	if pg.me:isMatchStatusInNormalMatch() then
		self:onCancelMatch()

		isCanceled = true
	elseif pg.me:isMatchStatusInModify() or pg.me:isMatchStatusInCovenantMatch() then
		pg.me:cancelPvpBattle()

		isCanceled = true
	end

	return isCanceled
end

function PvpLinkModeComponent:onCancelMatch()
	pg.me:cancelPvpMatch(function(state)
		if not state then
			return
		end

		self:onCancelMatchPostProcessing()
	end)
end

function PvpLinkModeComponent:covenantCancelCallback()
	self:onCancelMatchPostProcessing()
end

function PvpLinkModeComponent:onCancelMatchPostProcessing()
	self.component:TryChangePage("SubState", 0)
	self.ctrl:exitMatch()
end

function PvpLinkModeComponent:viewTickTimer(timeStr)
	ClientTextUtils.setText(self.matchTime, timeStr)
end

function PvpLinkModeComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PvpLinkModeComponent
