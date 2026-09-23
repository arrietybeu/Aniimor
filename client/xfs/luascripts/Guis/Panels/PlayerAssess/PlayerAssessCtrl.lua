-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerAssess\\PlayerAssessCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerAssessCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PlayerAssessCtrl = Class.LightClass("PlayerAssessCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")

PlayerAssessCtrl.messages = {}

function PlayerAssessCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PlayerAssessCtrl:addListener()
	function self.view.btnClose.luaClick()
		pg.global.ui.playerEnhance:open({
			defaultMode = 2,
			defaultTab = 2
		})
		self:dismiss()
	end

	function self.view.btnConfirm.luaClick()
		LuaUIUtils.startUPStarAssess()
		self:dismiss()
	end

	function self.view.skillList.luaRenderItem(button, _, data)
		self:onRenderSkillItem(button, data)
	end

	function self.view.skillPointList.luaRenderItem(button, _, data)
		self:onRenderSkillPointItem(button, data)
	end
end

function PlayerAssessCtrl:onDestroy()
	pg.global.ui.hudV2:tryPlayFuncUnlock()
	UICtrl.onDestroy(self)
end

function PlayerAssessCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.finishAssess = info[1] == "2"
end

function PlayerAssessCtrl:onShow()
	local data = self.model:getAssessInfo(self.finishAssess)

	if self.finishAssess then
		pg.game.audio:playEvent("SFX_UI_ExamFinish")
		ClientTextUtils.setText(self.view.starText2, data.starName)

		self.view.starIcon.url = data.icon
		self.view.starIcon2.url = data.icon
	else
		pg.game.audio:playEvent("SFX_UI_ExamStart")
		ClientTextUtils.setText(self.view.starText, data.nextStarName)

		self.view.starIcon.url = data.nextIcon
	end

	if self.finishAssess then
		ClientTextUtils.setText(self.view.assessTitle, pg.getFormatText(pg.getGameString("PLAYER_FINISHED_ASSESS"), data.fullStarName))
		self.view.rootWidget:TryChangePage("state", 1)
		self.view.animWidget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
	elseif data.matchTime then
		ClientTextUtils.setText(self.view.assessTitle, pg.getFormatText(pg.getGameString("PLAYER_START_ASSESS"), data.fullNextStarName))
		self.view.rootWidget:TryChangePage("state", 0)
		self.view.animWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	else
		ClientTextUtils.setText(self.view.assessTitle, pg.getFormatText(pg.getGameString("PLAYER_WAIT_ASSESS"), data.fullNextStarName))
		self.view.animWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		self.view.rootWidget:TryChangePage("state", 2)
		ClientTextUtils.setText(self.view.assessTime, data.unlockTimeFormat)
	end

	ClientTextUtils.setText(self.view.btnNameUText, pg.getGameString("LEARN_PLAYER_SKILL"))
	self.view.skillList:SetList(data.skReward)
	self.view.skillPointList:SetList(data.propReward)
end

function PlayerAssessCtrl:onRenderSkillItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local tLevel = oc:GetRefValue("txtLevel")
	local tName = oc:GetRefValue("txtName")
	local iIcon = oc:GetRefValue("icon")

	iIcon.url = data.icon

	button:TryChangePage("HideText", 1)
	button:TryChangePage("SkillLevel", 1)
	button:TryChangePage("SkillStage", 2)
	button:TryChangePage("SkillType", data.isRare and 1 or 0)
	pg.global.setRedDot(string.format("FIXED_DOT_%d", data.id), button, true, data.lv > 1 and RedDotConst.RedDotStyle.UP_SIGN or RedDotConst.RedDotStyle.NEW)

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				checkTouchBegin = false,
				autoHor = true,
				data = data,
				targetRect = button,
				rayCastParent = self.view.skillList
			})
		end
	end
end

function PlayerAssessCtrl:onRenderSkillPointItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iIcon = objectReference:GetRefValue("icon")
	local textNum = objectReference:GetRefValue("textNum")
	local txtName = objectReference:GetRefValue("txtName")

	iIcon.url = data.icon

	ClientTextUtils.setText(textNum, string.format("+%d", data.num))
	ClientTextUtils.setText(txtName, data.name)
end

function PlayerAssessCtrl:onHide()
	return
end

return PlayerAssessCtrl
