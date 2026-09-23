-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamPrepRoomCommonComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local TeamPrepRoomCommonComponent = Class.LightClass("TeamPrepRoomCommonComponent", UIComponent)

TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE = {
	MEMBER_UNMUTED = "TeamRoom_MemberUnmuted",
	MEMBER_FOCUSED = "TeamRoom_MemberFocused",
	INVITE_FOCUSED = "TeamRoom_InviteFocused",
	CAN_SELECT = "TeamRoom_CanSelect",
	PRE_EQUIP_FOCUSED = "TeamRoom_PreEquipFocused",
	OPEN_TIPS = "TeamRoom_OpenTips",
	MEMBER_MUTED = "TeamRoom_MemberMuted"
}

function TeamPrepRoomCommonComponent:onCtor(info)
	info = info or {}
	self.navListenerName = info.navListenerName or "TeamPrepRoom"
	self.useCSConsoleBar = info.useCSConsoleBar == true
	self.logger = info.logger
end

function TeamPrepRoomCommonComponent:initView()
	self:bindFocusCursorMovedListener()
	self:bindPanelTeamConsoleBar()
end

function TeamPrepRoomCommonComponent:getNavManager()
	if self.useCSConsoleBar and CS.XGUI.Navigation.NavManager.Instance then
		return CS.XGUI.Navigation.NavManager.Instance
	end

	return pg.global.navMgr
end

function TeamPrepRoomCommonComponent:bindFocusCursorMovedListener()
	local navMgr = self:getNavManager()

	if navMgr then
		navMgr:AddLuaFocusCursorMovedListener(self.navListenerName, function()
			self.ctrl:refreshConsoleBarState()
		end)
	end
end

function TeamPrepRoomCommonComponent:bindPanelTeamConsoleBar()
	local panelTeam = self.view and self.view.panelTeam

	if panelTeam then
		panelTeam:SetNavGroupConsoleBar("ConsoleBar_Enter_Team", -1)
	elseif self.logger then
		self.logger:warning("bindPanelTeamConsoleBar: panelTeam is nil, skip SetNavGroupConsoleBar")
	end
end

function TeamPrepRoomCommonComponent:setConsoleBarState(key, value)
	if pg.global.navMgr then
		pg.global.navMgr:SetConsoleBarState(key, value == true)
	end
end

function TeamPrepRoomCommonComponent:initConsoleBarStateKeys()
	if self.useCSConsoleBar then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("emjoyGroupNotShow", true)
	end

	self:clearFocusConsoleBarState()
	self:refreshConsoleBarState()
end

function TeamPrepRoomCommonComponent:refreshConsoleBarState()
	local navMgr = self:getNavManager()

	if not navMgr then
		return
	end

	local groupName = navMgr.CurrentFocusedGroupName
	local isActionFold = groupName == "ListAction"

	if self.useCSConsoleBar then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("emjoyGroupNotShow", not isActionFold)
	elseif pg.global.navMgr then
		pg.global.navMgr:SetConsoleBarState("emjoyGroupNotShow", not isActionFold)
	end

	if pg.global.navMgr then
		local canSelect = groupName == "LeftBtn" or groupName == "ListAction"

		self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.CAN_SELECT, canSelect)
	end
end

function TeamPrepRoomCommonComponent:setOpenTipsState(visible)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.OPEN_TIPS, visible == true)
end

function TeamPrepRoomCommonComponent:clearFocusConsoleBarState()
	self.focusedMemberUid = nil
	self.focusedInvite = nil
	self.focusedPreEquip = nil

	self:setOpenTipsState(false)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_FOCUSED, false)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_MUTED, false)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_UNMUTED, false)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.INVITE_FOCUSED, false)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.PRE_EQUIP_FOCUSED, false)
end

function TeamPrepRoomCommonComponent:onInviteNavFocused()
	self:clearFocusConsoleBarState()

	self.focusedInvite = true

	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.INVITE_FOCUSED, true)
end

function TeamPrepRoomCommonComponent:onMemberNavFocused(uid, index, canPreEquip)
	self:clearFocusConsoleBarState()

	self.focusedMemberUid = uid
	self.focusedPreEquip = canPreEquip == true

	local canOperateOther = uid and uid ~= pg.me.uid
	local canMuteMember = canOperateOther and pg.game.speech:checkMemberInRoom(pg.me.uid) and pg.game.speech:checkMemberInRoom(uid)
	local memberMuted = canMuteMember and pg.game.speech:checkMemberMuted(uid)

	self:setOpenTipsState(canOperateOther)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_FOCUSED, canOperateOther)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_MUTED, canMuteMember and memberMuted)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_UNMUTED, canMuteMember and not memberMuted)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.PRE_EQUIP_FOCUSED, canPreEquip == true)
end

function TeamPrepRoomCommonComponent:refreshFocusedMemberConsoleBarState()
	local uid = self.focusedMemberUid

	if not uid then
		return
	end

	local canOperateOther = uid ~= pg.me.uid
	local canMuteMember = canOperateOther and pg.game.speech:checkMemberInRoom(pg.me.uid) and pg.game.speech:checkMemberInRoom(uid)
	local memberMuted = canMuteMember and pg.game.speech:checkMemberMuted(uid)

	self:setOpenTipsState(canOperateOther)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_FOCUSED, canOperateOther)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_MUTED, canMuteMember and memberMuted)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.MEMBER_UNMUTED, canMuteMember and not memberMuted)
	self:setConsoleBarState(TeamPrepRoomCommonComponent.CONSOLE_BAR_STATE.PRE_EQUIP_FOCUSED, self.focusedPreEquip == true)
end

function TeamPrepRoomCommonComponent:onMemberNavUnfocused()
	self:clearFocusConsoleBarState()
end

function TeamPrepRoomCommonComponent:onDestroy()
	self:clearFocusConsoleBarState()

	local navMgr = self:getNavManager()

	if navMgr then
		navMgr:RemoveLuaFocusCursorMovedListener(self.navListenerName)
	end

	UIComponent.onDestroy(self)
end

return TeamPrepRoomCommonComponent
