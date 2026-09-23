-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushBattleDetailResult\\BossRushBattleDetailResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushBattleDetailResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BossRushBattleDetailResultView = Class.LightClass("BossRushBattleDetailResultView", UIView)

function BossRushBattleDetailResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.keyListUList = objectReference:GetRefValue("keyListUList")
	self.titleTxtUBaseText = objectReference:GetRefValue("titleTxtUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
end

function BossRushBattleDetailResultView:registerObjects()
	return
end

function BossRushBattleDetailResultView:initView()
	self.countDownUCountDown.formatText = pg.getGameString("BOSS_RUSH_RESULT_TIP5")

	ClientTextUtils.setText(self.titleTxtUBaseText, pg.getGameString("BOSS_RUSH_RESULT_TIP2"))
end

return BossRushBattleDetailResultView
