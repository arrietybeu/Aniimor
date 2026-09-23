-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseLUComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseLUComponent")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RoguelikeData = require("Data.roguelike_data")
local RogueUtils = require("Utils.RogueUtils")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local BaseLUComponent = Class.LightClass("BaseLUComponent", HudBaseComponent)

BaseLUComponent.messages = {
	[MessageName.ROGUE_LAYER_CHANGE] = {
		"refreshTowerLayer",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.HOME_FORMULA_TRACKING_CHANGED] = {
		"onRefreshFormulaTracking",
		true
	},
	[MessageName.BOSS_TITLE_COMBAT_STATE_CHANGE] = {
		"onBossTitleCombatStateChanged",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded"
	},
	[MessageName.UI_AI_HELPER_LIT] = {
		"onAIHelperLitMsg",
		true
	}
}

function BaseLUComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.teamPanelUContainer = objectReference:GetRefValue("teamPanelUContainer")
	self.btnQuitUButton = objectReference:GetRefValue("btnQuitUButton")
	self.btnQuitHotKeyContent = objectReference:GetRefValue("btnQuitHotKeyContent")
	self.layerUBaseText = objectReference:GetRefValue("layerUBaseText")
	self.miniMapUContainer = objectReference:GetRefValue("miniMapUContainer")
	self.guideSlightTipsUContainer = objectReference:GetRefValue("guideSlightTipsUContainer")
	self.homeFormulaTackTipsUContainer = objectReference:GetRefValue("homeFormulaTackTipsUContainer")
	self.temperatureUContainer = objectReference:GetRefValue("temperatureUContainer")

	self.temperatureUContainer:SetActive(false)

	self.showAnim = objectReference:GetRefValue("showAnim")
	self.bossRushBtnInfoUContainer = objectReference:GetRefValue("bossRushBtnInfoUContainer")
end

function BaseLUComponent:bindComponent()
	self.minimapV2 = self:getBaseComponentCls(HudSplicingCfg.componentName.miniMapV2).new(self, self.miniMapUContainer.transform, {
		isAutoLoad = true,
		isContainer = true,
		compName = HudSplicingCfg.componentName.miniMapV2
	})
	self.aiHelperLit = self:getBaseComponentCls(HudSplicingCfg.componentName.aiHelperLit).new(self, self.guideSlightTipsUContainer.transform, {
		compName = HudSplicingCfg.componentName.aiHelperLit
	})
	self.teamInfo = self:getBaseComponentCls(HudSplicingCfg.componentName.team).new(self, self.teamPanelUContainer.transform, {
		isAutoLoad = true,
		isContainer = true,
		compName = HudSplicingCfg.componentName.team
	})
	self.quitBtn = self:getBaseComponentCls(HudSplicingCfg.componentName.quitBtn).new(self, self.transform, {
		needLoadRes = false,
		compName = HudSplicingCfg.componentName.quitBtn
	})
	self.formulaTracking = self:getBaseComponentCls(HudSplicingCfg.componentName.formulaTracking).new(self, self.homeFormulaTackTipsUContainer.transform, {
		isAutoLoad = true,
		isContainer = true,
		compName = HudSplicingCfg.componentName.formulaTracking
	})
	self.bossRushInfo = self:getBaseComponentCls(HudSplicingCfg.componentName.bossRushInfo).new(self, nil, {
		isAutoLoad = false,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.bossRushInfo
	})
	self.towerInfo = self:getBaseComponentCls(HudSplicingCfg.componentName.TowerInfo).new(self, nil, {
		isAutoLoad = false,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.TowerInfo
	})
	self.bossRushBtnInfo = self:getBaseComponentCls(HudSplicingCfg.componentName.bossRushBtnInfo).new(self, self.bossRushBtnInfoUContainer.transform, {
		isAutoLoad = true,
		isContainer = true,
		compName = HudSplicingCfg.componentName.bossRushBtnInfo
	})
end

function BaseLUComponent:initView()
	self:setSceneType()

	if self.teamInfo then
		self.teamInfo:onTeamInfoChanged()
	end

	self:refreshDungeonUIState()

	local playerSpace = pg.me and pg.me.space

	if playerSpace then
		if playerSpace:isRogueEnv() then
			self:refreshTowerLayer()
			self.towerInfo:tryShowComponent()
		elseif playerSpace:isBossRushEnv() then
			self.bossRushInfo:tryShowComponent()
		end
	end

	self:onRefreshFormulaTracking()
end

function BaseLUComponent:setSceneType()
	if not pg.me or not pg.me.space then
		return
	end

	local hudMode = UIConst.HUD_MODE.HUD

	if pg.me.space:isRogueEnv() then
		hudMode = UIConst.HUD_MODE.ROGUE_DUNGEON
	elseif pg.me.space:isHomeland() then
		hudMode = UIConst.HUD_MODE.HOMELAND
	elseif pg.global.scene.curScene and pg.global.scene.curScene.getClassType() == "TempleScene" then
		hudMode = UIConst.HUD_MODE.TEMPLE
	elseif QuestUtils.isInCourseScene() then
		hudMode = UIConst.HUD_MODE.COURSE
	elseif pg.me.space:isBossDungeon() then
		hudMode = UIConst.HUD_MODE.BOSS_DUNGEON
	elseif pg.me.space:isGrabEgg() then
		hudMode = UIConst.HUD_MODE.IN_TEAM
	elseif pg.me.space:isBossRushEnv() then
		hudMode = UIConst.HUD_MODE.BOSS_RUSH
	elseif pg.me.space:isCatchRogue() then
		hudMode = UIConst.HUD_MODE.CATCH_ROGUE
	elseif Utils.isScenePhoto() then
		hudMode = UIConst.HUD_MODE.PHOTO
	end

	local typeIndex = UIConst.HUD_LEFT_PANEL_TYPE[hudMode] or 1

	self.uWidget:TryChangePage("Type", typeIndex)
end

function BaseLUComponent:refreshDungeonUIState()
	if Utils.isSelfInSpaceDungeon() then
		pg.global.ui.hudV2:dungeonHideOtherUI()

		if pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList and pg.global.ui.hudV2.RM.petList.mobileQuickSwitchUButton and pg.global.ui.hudV2.RM.petList.mobileQuickSwitchUButton.gameObject then
			pg.global.ui.hudV2.RM.petList.mobileQuickSwitchUButton.gameObject:SetActiveEx(false)
		end
	end

	local isRogueSpace = false

	if pg.space and (pg.space:isRogueEnv() or pg.space:isCatchRogue()) then
		isRogueSpace = true
	end

	self.layerUBaseText:SetActive(isRogueSpace)
end

function BaseLUComponent:refreshTowerLayer()
	if not pg.me or not pg.me.curRogueLayer then
		return
	end

	local levelCfg = RoguelikeData[pg.me.curRogueLayer]

	if levelCfg == nil then
		return
	end

	if levelCfg.todParam then
		pg.game.weather:setTodTime(Const.TOD_TIME_KEY.ROGUE, true, levelCfg.todParam[1], levelCfg.todParam[2], 1)
	end

	local text = pg.getGameString("TOWER_ROGUE_FLOOR_NAME")
	local floor = string.format("%d/%d", levelCfg.floor, RogueUtils.getCurRogueLevelTotalLayerCount())
	local finalText, _ = string.gsub(text, "{floor}", floor)

	ClientTextUtils.setText(self.layerUBaseText, finalText)
end

function BaseLUComponent:onRefreshFormulaTracking()
	self.homeFormulaTackTipsUContainer:SetActive(false)

	if pg.me and pg.me.space and pg.me.space:isHomeland() and pg.me.space:isSelfHomeland(pg.me) then
		local pinnedFormulaList = pg.me.pinnedFormulaList or {}
		local pinnedFormulaId = pinnedFormulaList[1]

		if pinnedFormulaId then
			self.homeFormulaTackTipsUContainer:SetActive(true)
			self.formulaTracking:refreshPanel(pinnedFormulaId)
		end
	end
end

function BaseLUComponent:refreshTeamInfo(param)
	if self.minimapV2 then
		self.minimapV2:loadMovingTargetMark()
	end

	if self.teamInfo then
		self.teamInfo:onTeamInfoChanged()
	end
end

function BaseLUComponent:onSceneLoaded()
	self:setSceneType()
	self:refreshTeamInfo()
	self:onRefreshFormulaTracking()
end

function BaseLUComponent:setVisible(visible)
	LuaUIUtils.setUIVisible(self.uWidget, visible)
end

function BaseLUComponent:onBossTitleCombatStateChanged(combatState)
	local minimap = pg.game.map:GetMiniMapUI()

	if minimap then
		minimap:onBattleStateChange(combatState)
	end
end

function BaseLUComponent:onAIHelperLitMsg(info)
	if self.aiHelperLit then
		self.aiHelperLit:refreshAiTipByEvent(info)
	end
end

function BaseLUComponent:onDestroy()
	self.miniMapUContainer = nil
	self.teamPanelUContainer = nil
	self.layerUBaseText = nil
	self.guideSlightTipsUContainer = nil
	self.homeFormulaTackTipsUContainer = nil

	HudBaseComponent.onDestroy(self)
end

function BaseLUComponent:playShowAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function BaseLUComponent:playHideAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return BaseLUComponent
