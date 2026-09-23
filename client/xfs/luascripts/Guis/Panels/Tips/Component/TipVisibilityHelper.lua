-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\TipVisibilityHelper.lua

local UIConst = require("Const.UIConst")
local TipVisibilityHelper = {}

TipVisibilityHelper.HideReason = {
	cutscene = "cutscene",
	hudVisible = "hudVisible",
	panelHide = "panelHide",
	forceHide = "forceHide",
	NoChallengeNoTempleNoDitto = "challengeInfo_NoTempleSceneNoInDittoDungeon",
	fullScreenShow = "fullScreenShow",
	isShowCurTarget = "isShowCurTarget",
	priorityBreakChallenge = "priorityBreakChallenge",
	priorityBreakQuest = "priorityBreakQuest",
	priorityBreakTarget = "priorityBreakTarget",
	isVisible = "isVisible",
	enableModule = "enableModule",
	inCourseScene = "inCourseScene",
	catchMode = "catchMode",
	checkShowState = "checkShowState",
	ui = "ui",
	space = "space",
	target = "targetComponent",
	screenTransition = "screenTransition"
}

function TipVisibilityHelper.checkInScreenTransition()
	local ui = pg.global.ui

	if ui == nil then
		return false
	end

	return ui:checkUIShow(UIConst.UI_ID_BLACK_SCREEN) == true or ui:checkUIShow(UIConst.UI_ID_WHITE_SCREEN) == true
end

function TipVisibilityHelper.init(owner)
	owner.hideFlags = owner.hideFlags or {}
	owner.visibleMap = owner.visibleMap or {}
end

function TipVisibilityHelper.setHideFlag(owner, reason, hidden)
	TipVisibilityHelper.init(owner)

	owner.hideFlags[reason] = hidden and 1 or nil

	return TipVisibilityHelper.refresh(owner)
end

function TipVisibilityHelper.refreshCheckShowState(owner)
	return
end

function TipVisibilityHelper.refresh(owner)
	TipVisibilityHelper.init(owner)

	local visible = next(owner.hideFlags) == nil
	local oldVisible = owner.visibleMap.visible

	owner.visibleMap.visible = visible

	if oldVisible ~= visible then
		if owner.onBaseVisibleChanged then
			owner:onBaseVisibleChanged(visible)
		end

		if owner.NotifyEdgeTipChanged then
			owner:NotifyEdgeTipChanged(visible, owner.priorityFlag)
		end
	end

	return visible
end

function TipVisibilityHelper.checkIsRunning(owner)
	return owner.visibleMap and owner.visibleMap.visible or false
end

function TipVisibilityHelper.clearRunningList(owner)
	TipVisibilityHelper.init(owner)

	owner.visibleMap.visible = false
end

return TipVisibilityHelper
