-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DeadPanel\\DeadPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DeadPanelView = Class.LightClass("DeadPanelView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")

function DeadPanelView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.listRecommendUList = self.objectReference:GetRefValue("listRecommendUList")
	self.btnRebornUButton = self.objectReference:GetRefValue("btnRebornUButton")
	self.btnMinimizedUButton = self.objectReference:GetRefValue("btnMinimizedUButton")
	self.btnOpenedUButton = self.objectReference:GetRefValue("btnOpenedUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.btnAbandonUButton = self.objectReference:GetRefValue("btnAbandonUButton")
	self.miniTitleUSDFText = self.objectReference:GetRefValue("miniTitleUSDFText")
	self.miniTipsUSDFText = self.objectReference:GetRefValue("miniTipsUSDFText")
	self.miniRebornUButton = self.objectReference:GetRefValue("miniRebornUButton")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
	self.canReviveCDUCountDown = self.objectReference:GetRefValue("canReviveCDUCountDown")
	self.txtRebornNumNoneUBaseText = self.objectReference:GetRefValue("txtRebornNumNoneUBaseText")
	self.txtRebornNumUBaseText = self.objectReference:GetRefValue("txtRebornNumUBaseText")
	self.txtRebornNumUBaseTextMini = self.objectReference:GetRefValue("txtRebornNumUBaseTextMini")
	self.canReviveCDUCountDownMini = self.objectReference:GetRefValue("canReviveCDUCountDownMini")
	self.txtRebornNumNoneUBaseTextMini = self.objectReference:GetRefValue("txtRebornNumNoneUBaseTextMini")
	self.chatUComponent = self.objectReference:GetRefValue("chatUComponent")

	local abandonBtnObjectReference = self.btnAbandonUButton:GetComponent("ObjectReference")

	self.abandonBtnText = abandonBtnObjectReference:GetRefValue("txtNameUText")
	self.btnRefightUButton = self.objectReference:GetRefValue("btnRefightUButton")
	self.listContinue = self.objectReference:GetRefValue("listContinue")
	self.countDownUCountDown = self.objectReference:GetRefValue("countDownUCountDown")
	self.btnBoxULayoutBox = self.objectReference:GetRefValue("btnBoxULayoutBox")
	self.panelGameModeUComponent = self.objectReference:GetRefValue("panelGameModeUComponent")
	self.forbidHelpUSDFText = self.objectReference:GetRefValue("forbidHelpUSDFText")
	self.waitHelpUCountDown = self.objectReference:GetRefValue("waitHelpUCountDown")
	self.waitHelpUSDFText = self.objectReference:GetRefValue("waitHelpUSDFText")
	self.robEggAbandonBtn = self.objectReference:GetRefValue("robEggAbandonBtn")
	self.robEggViewCombatUButton = self.objectReference:GetRefValue("robEggViewCombatUButton")
	self.npcDuelBtnExitUButton = self.objectReference:GetRefValue("npcDuelBtnExitUButton")

	local objectReference = self.npcDuelBtnExitUButton:GetComponent("ObjectReference")

	self.npcDuelBtnExitTxtNameUText = objectReference:GetRefValue("txtNameUText")
	self.npcDuelRechallengeUButton = self.objectReference:GetRefValue("npcDuelRechallengeUButton")

	local objectReference = self.npcDuelRechallengeUButton:GetComponent("ObjectReference")

	self.npcDuelRechallengeUText = objectReference:GetRefValue("txtNameUText")
end

function DeadPanelView:registerObjects()
	return
end

function DeadPanelView:initView()
	ClientTextUtils.setText(self.txtRebornNumNoneUBaseText, pg.getGameString("BOSS_RUSH_REVIVE_TIP2"))
	ClientTextUtils.setText(self.txtRebornNumNoneUBaseTextMini, pg.getGameString("BOSS_RUSH_REVIVE_TIP2"))

	self.canReviveCDUCountDown.formatText = pg.getGameString("BOSS_RUSH_REVIVE_TIP1")
	self.canReviveCDUCountDownMini.formatText = pg.getGameString("BOSS_RUSH_REVIVE_TIP1")
end

function DeadPanelView:SetReviveTipText(reviveLast)
	ClientTextUtils.setText(self.txtRebornNumUBaseText, pg.getFormatText(pg.getGameString("BOSS_RUSH_REVIVE_TIP3"), reviveLast, SysConfigData.BossRushRespawnNum))
	ClientTextUtils.setText(self.txtRebornNumUBaseTextMini, pg.getFormatText(pg.getGameString("BOSS_RUSH_REVIVE_TIP3"), reviveLast, SysConfigData.BossRushRespawnNum))
end

function DeadPanelView:StartReviveCD()
	self.canReviveCDUCountDown:Play(SysConfigData.BossRushRespawnTime)
	self.canReviveCDUCountDownMini:Play(SysConfigData.BossRushRespawnTime)
end

function DeadPanelView:StopReviveCD()
	self.canReviveCDUCountDown:Stop()
	self.canReviveCDUCountDownMini:Stop()
end

function DeadPanelView:SetReviveTips(isActive)
	self.txtRebornNumUBaseText.gameObject:SetActiveEx(isActive)
	self.txtRebornNumUBaseTextMini.gameObject:SetActiveEx(isActive)
end

return DeadPanelView
