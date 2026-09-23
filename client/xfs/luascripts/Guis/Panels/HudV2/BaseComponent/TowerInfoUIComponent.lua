-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\TowerInfoUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RoguelikeData = require("Data.roguelike_data")
local LevelConditionData = require("Data.level_condition_data")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local RogueUtils = require("Utils.RogueUtils")
local TowerInfoUIComponent = Class.LightClass("TowerInfoUIComponent", HudBaseComponent)

TowerInfoUIComponent.messages = {
	[MessageName.ROGUE_LAYER_CHANGE] = {
		"refreshTowerInfo",
		true
	},
	[MessageName.ROGUE_RESULT_CHANGE] = {
		"onRogueResultChange",
		true
	},
	[MessageName.ROGUE_START_BATTLE] = {
		"onRogueStartBattle",
		true
	},
	[MessageName.CATCH_ROGUE_LEVEL_CHANGE] = {
		"refreshTowerInfo",
		true
	}
}

function TowerInfoUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.towerConditionUComponent = self.objectReference:GetRefValue("towerConditionUComponent")
	self.timeTowerTransform = self.objectReference:GetRefValue("timeTowerTransform")

	self.timeTowerTransform.gameObject:SetActiveEx(false)

	local conditionRoot = self.towerConditionUComponent:GetComponent("ObjectReference")

	self.questDetailList = conditionRoot:GetRefValue("questDetailList")
	self.questNameTxt = conditionRoot:GetRefValue("questNameTxt")
end

function TowerInfoUIComponent:initView()
	self:refreshTowerInfo()

	self.isInBattle = pg.me.curRogueLayerState == DungeonConst.STATUS.PLAYING

	LuaUIUtils.setUIViewVisible(self.towerConditionUComponent, false)

	if self.isInBattle then
		RogueUtils.recoverBossCountDownTip()
	end
end

function TowerInfoUIComponent:refreshTowerInfo()
	if not pg.me.curRogueLayer then
		return
	end

	local levelCfg = RoguelikeData[pg.me.curRogueLayer]

	if levelCfg == nil then
		return
	end

	local conditions = levelCfg.completionConditions or {}
	local data = {}

	for _, conditionId in ipairs(conditions) do
		local item = {}
		local conditionInfo = LevelConditionData[conditionId]

		item.label = pg.getLocalizationText(conditionInfo.displayDesc)

		table.insert(data, item)
	end

	self.questDetailList:SetList(data)
	ClientTextUtils.setText(self.questNameTxt, pg.getGameString("TOWER_ROGUE_SUCCESS_CONDITION"))
end

function TowerInfoUIComponent:onRogueResultChange(info)
	if info and info.result then
		pg.global.ui.tips:showA1Tips({
			id = "TowerResultWin",
			showText = pg.getGameString("ROGUE_BATTLE_SUCCESS")
		})
		pg.game.audio:playEvent("SFX_UI_Rouge_ChallengeSuccessful")
	else
		pg.global.ui:open(UIConst.UI_ID_TOWER_DEFEAT, info)
	end

	self:onEndBattle()
end

function TowerInfoUIComponent:onRogueStartBattle()
	self:onStartBattle()
	pg.global.ui.tips:showA1Tips({
		id = "TowerResultStart",
		showText = pg.getGameString("ROGUE_BATTLE_START")
	})
	pg.game.audio:playEvent("SFX_UI_Rouge_ChallengeBegins")
end

function TowerInfoUIComponent:onStartBattle()
	return
end

function TowerInfoUIComponent:onEndBattle()
	LuaUIUtils.setUIViewVisible(self.towerConditionUComponent, false)
end

function TowerInfoUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return TowerInfoUIComponent
