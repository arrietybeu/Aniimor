-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushMain\\BossRushMainView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushMainView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushMainView = Class.LightClass("BossRushMainView", UIView)

function BossRushMainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.pointBossUButton = objectReference:GetRefValue("pointBossUButton")
	self.pointBossLeftUButton = objectReference:GetRefValue("pointBossLeftUButton")
	self.pointBossRightUButton = objectReference:GetRefValue("pointBossRightUButton")
	self.btnRankUButton = objectReference:GetRefValue("btnRankUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.conditionTipsUWidget = objectReference:GetRefValue("conditionTipsUWidget")
	self.textTipsUBaseText = objectReference:GetRefValue("textTipsUBaseText")
	self.consoleBarTransform = objectReference:GetRefValue("consoleBarTransform")
	self.matchBtnUComponent = objectReference:GetRefValue("matchBtnUComponent")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.txtNotOpenUBaseText = objectReference:GetRefValue("txtNotOpenUBaseText")
	self.txtNameRewardUSDFText = objectReference:GetRefValue("txtNameRewardUSDFText")
	self.btnSeasonUButton = objectReference:GetRefValue("btnSeasonUButton")
	self.btnSeasonTxtUSDFText = objectReference:GetRefValue("btnSeasonTxtUSDFText")
	self.btnRankTxtUSDFText = objectReference:GetRefValue("btnRankTxtUSDFText")
	self.btnRealRankUButton = objectReference:GetRefValue("btnRealRankUButton")
	self.seasonUCountDown = objectReference:GetRefValue("seasonUCountDown")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtCountDownTextPlus = objectReference:GetRefValue("txtCountDownTextPlus")
	self.rewardHelpUButton = objectReference:GetRefValue("rewardHelpUButton")
	self.helpRewardNumTextPlus = objectReference:GetRefValue("helpRewardNumTextPlus")
	self.chatUContainer = objectReference:GetRefValue("chatUContainer")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.titleTMPUSDFText = objectReference:GetRefValue("titleTMPUSDFText")
	self.messageListUList = objectReference:GetRefValue("messageListUList")
	self.chatBarrageUContainer = objectReference:GetRefValue("chatBarrageUContainer")
end

function BossRushMainView:registerObjects()
	self.btnRankObjectReference = self.btnRankUButton:GetComponent("ObjectReference")

	local objectReference = self.btnRankObjectReference

	self.scoreUBase = objectReference:GetRefValue("scoreUBase")
	self.rankUBaseTex = objectReference:GetRefValue("rankUBaseTex")
	self.bestScoreTxtUSDFText = objectReference:GetRefValue("bestScoreTxtUSDFText")
end

function BossRushMainView:initView()
	ClientTextUtils.setText(self.bestScoreTxtUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_MAIN_TIP1"))
	ClientTextUtils.setText(self.btnRankTxtUSDFText, ClientTextUtils.getGameString("BOSS_RUSH_RANK"))

	local str = ClientTextUtils.getGameString("BOSS_RUSH_MAIN_TIP4")

	if str == "BOSS_RUSH_MAIN_TIP4" then
		str = ""
	end

	ClientTextUtils.setText(self.scrollRectUScrollRect.content, str)
end

return BossRushMainView
