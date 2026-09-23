-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\LimitChallengeComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local BaseTipComponent = require("Guis.Panels.Tips.Component.BaseTipComponent")
local TipVisibilityHelper = require("Guis.Panels.Tips.Component.TipVisibilityHelper")
local HideReason = TipVisibilityHelper.HideReason
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LevelData = require("Data.level_data")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("LimitChallengeComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local CommonSwitch = require("Common.CommonSwitch")
local TargetConfigData = require("Data.gameplay_target_data")
local GameSceneRevert = require("Data.gameplaytarget_scene_revert_data")
local LimitChallengeComponent = Class.LightClass("LimitChallengeComponent", BaseTipComponent)

LimitChallengeComponent.messages = {
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.CHALLENGE_UPDATE] = {
		"onChallengeUpdate",
		true
	},
	[MessageName.PLAYER_INTERACT_RECORD_ADD] = {
		"onInteractRecordAdd",
		true
	},
	[MessageName.PLAYER_INTERACT_RECORD_DELETE] = {
		"onInteractRecordDelete",
		true
	},
	[MessageName.ON_PLAYER_ENTER_SPACE] = {
		"onEnterSpace",
		true
	},
	[MessageName.UI_ON_VISIBLE_CHANGE] = {
		"onUIVisibleChanged",
		true
	}
}

function LimitChallengeComponent:findObjects()
	self.container = self.transform:GetComponent("UContainer")

	self.container:LoadDefaultUrlManually(function(widget)
		self:initObjectRef()
	end)
end

function LimitChallengeComponent:initView()
	self.racingTempleSceneId = 2008
	self.hideFlags = {}
	self.baseVisible = false
	self.priorityFlag = HideReason.priorityBreakChallenge

	self:initHideFlag()
end

function LimitChallengeComponent:initObjectRef()
	self.content = self.container.content
	self.objectReference = self.container.content:GetComponent("ObjectReference")
	self.iconTitleUImage = self.objectReference:GetRefValue("iconTitleUImage")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
	self.listTaskUList = self.objectReference:GetRefValue("listTaskUList")
	self.btnClickUButton = self.objectReference:GetRefValue("btnClickUButton")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.chestUWidget = self.objectReference:GetRefValue("chestUWidget")

	function self.btnClickUButton.luaClick()
		if not self.isVisible then
			return false
		end

		self:onResetClick()
	end

	local keyBind = self.btnClickUButton:GetComponent("KeyBindingPro")

	keyBind.actionPath = "Hud/ResetPuzzle"

	function self.listTaskUList.luaRenderItem(button, idx, data)
		local objectReference = button:GetComponent("ObjectReference")
		local contentTxt = objectReference:GetRefValue("contentTxt")
		local btnPhoneUButton = objectReference:GetRefValue("btnPhoneUButton")
		local rootAnimation = objectReference:GetRefValue("rootAnimation")

		button:TryChangePage("TaskType", 5)
		btnPhoneUButton:SetActive(false)
		ClientTextUtils.setText(contentTxt, pg.getGameString(data.goal))
		UIUtils.PlayAnimation(rootAnimation, "VX_Node_QuestHUD_Text_In", function()
			return
		end)
	end
end

function LimitChallengeComponent:checkHideQuest()
	return self.isVisible
end

function LimitChallengeComponent:onResetClick()
	if self.challengeInfo and self.challengeInfo.resetFunc then
		self.challengeInfo.resetFunc()
	end

	if self.isTempleScene then
		facade:sendMsgToUI(MessageName.RACESAMPLE_PAUSE_TIMER, {})
		ClientUtils.showConfirmRaw(pg.getGameString("PUZZLE_RETRY_TITLE"), pg.getGameString("PUZZLE_TELEPORT_RETRY"), function()
			facade:sendMsgToUI(MessageName.RACESAMPLE_RESTART, {})
			pg.game.audio:stopBgmByLevel("RacingBGM")
		end, nil, function()
			facade:sendMsgToUI(MessageName.RACESAMPLE_RESUME_TIMER, {})
		end)
	end
end

function LimitChallengeComponent:onStageChange(info)
	self.racingStatus = info.stage
end

function LimitChallengeComponent:checkIsRunning()
	return TipVisibilityHelper.checkIsRunning(self)
end

function LimitChallengeComponent:clearRunningList(force)
	self.isVisible = false
end

function LimitChallengeComponent:checkShowState()
	if not pg.global.ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		return false
	end

	local me = pg.me

	if me == nil or me.space == nil then
		return false
	end

	if me.space:isRogueEnv() or me.space:isPvpEnv() then
		return false
	end

	return true
end

function LimitChallengeComponent:onUpdate()
	return
end

function LimitChallengeComponent:refreshDungeonGoal(info)
	local goal = info.goal
	local goalItemList = {}

	if goal then
		local temp = {
			goal = goal
		}

		table.insert(goalItemList, temp)
	end

	self.listTaskUList:SetList(goalItemList)

	local allBtns = self.listTaskUList:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local btn = allBtns[i]

		btn:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end
end

function LimitChallengeComponent:resetChallengeState()
	return
end

function LimitChallengeComponent:onSceneLoaded()
	self.isTempleScene = pg.global.scene.curScene and pg.global.scene.curScene.getClassType() == "TempleScene" and not self.isInDittoDungeon

	if self.isTempleScene then
		self.ctrl:startTimer(function()
			self:_refreshTempSceneUI()
		end, 2)
	end

	self:_checkVisible()
end

function LimitChallengeComponent:_refreshTempSceneUI()
	self.content:TryChangePage("OriginalIconSize", 1)
	LuaUIUtils.setUIVisible(self.btnClickUButton, self.racingStatus and self.racingStatus >= 2 and pg.space.sceneId == self.racingTempleSceneId)
	ClientTextUtils.setText(self.txtTitleUBaseText, pg.getGameString("SIDEBAR_HEADLINE_TEMPLE_00"))
	self.listTaskUList:SetActiveQuickly(true)

	self.iconTitleUImage.url = AddressDataConst.UI_GAME_PLAY_TRACK_DUNGEON

	local curNum = 0
	local totalNum = 0
	local sceneId = pg.me.space.sceneId
	local chestInfo
	local targetInfo = GameSceneRevert[sceneId]

	if targetInfo then
		chestInfo = TargetConfigData[targetInfo.targetId].chest
	end

	if chestInfo then
		self.templeSceneChestInfo = chestInfo

		for index, chestStaticId in ipairs(chestInfo or EMPTY_TABLE) do
			local openCount = pg.me.interactRecord and pg.me.interactRecord[chestStaticId] or 0

			totalNum = totalNum + 1

			if openCount > 0 then
				curNum = curNum + 1
			end
		end
	end

	local chestFinish = totalNum <= curNum

	if chestFinish then
		if self._chestFinish ~= chestFinish then
			self.chestUWidget:SetActiveQuickly(true)
			self.chestUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end
	else
		self.chestUWidget:SetActiveQuickly(true)
	end

	self._chestFinish = chestFinish
end

function LimitChallengeComponent:refreshChestInfoInTempleScene()
	local curNum = 0
	local totalNum = 0

	if self.templeSceneChestInfo then
		for _, chestStaticId in ipairs(self.templeSceneChestInfo) do
			local openCount = pg.me.interactRecord and pg.me.interactRecord[chestStaticId] or 0

			totalNum = totalNum + 1

			if openCount > 0 then
				curNum = curNum + 1
			end
		end

		ClientTextUtils.setText(self.txtNumUBaseText, string.format("%s/%s", curNum, totalNum))
	end
end

function LimitChallengeComponent:onDittoStateChange(newState, gamePlay)
	return
end

function LimitChallengeComponent:onChallengeUpdate()
	self.challengeInfo = pg.game.challenge:getCurChallengeInfo()

	if self.challengeInfo then
		self.content:TryChangePage("OriginalIconSize", 0)

		local title = self.challengeInfo.title

		ClientTextUtils.setText(self.txtTitleUBaseText, pg.getLocalizationText(title))

		self.iconTitleUImage.url = AddressDataConst.UI_GAME_PLAY_TRACK_TIME_LIMITED

		if self.challengeInfo.resetFunc then
			LuaUIUtils.setUIVisible(self.btnClickUButton, true)
		else
			LuaUIUtils.setUIVisible(self.btnClickUButton, false)
		end

		self.chestUWidget:SetActiveQuickly(false)
		self.listTaskUList:SetActiveQuickly(false)
	end

	self:_checkVisible()
end

function LimitChallengeComponent:onInteractRecordAdd()
	self:refreshChestInfoInTempleScene()
end

function LimitChallengeComponent:onInteractRecordDelete()
	self:refreshChestInfoInTempleScene()
end

function LimitChallengeComponent:initHideFlag()
	if pg.me == nil or pg.me.space == nil then
		return
	end

	self:onEnterSpace()
	self:onUIVisibleChanged()
	self:_checkVisible()
end

function LimitChallengeComponent:onEnterSpace()
	local me = pg.me

	if me == nil or me.space == nil then
		return false
	end

	self.isInDittoDungeon = me.space:isDittoSpace()

	if self.isInDittoDungeon then
		self.chestUWidget:SetActiveQuickly(false)
		self.listTaskUList:SetActiveQuickly(true)
		LuaUIUtils.setUIVisible(self.btnClickUButton, false)
		self.content:TryChangePage("OriginalIconSize", 1)

		self.iconTitleUImage.url = AddressDataConst.UI_GAME_PLAY_TRACK_DITTO

		ClientTextUtils.setText(self.txtTitleUBaseText, pg.getGameString("MORPHLING_MAIN_GOAL"))
		self:refreshDungeonGoal({
			goal = "MORPHLING_SIDE_GOAL_1"
		})
	end

	if me.space:isRogueEnv() or me.space:isPvpEnv() then
		self:setHideFlag(HideReason.space, true)
	else
		self:setHideFlag(HideReason.space, false)
	end

	self:_checkVisible()
end

function LimitChallengeComponent:onUIVisibleChanged()
	local ui = pg.global.ui

	if not ui:checkUIShow(UIConst.UI_ID_HUD_V2) then
		self:setHideFlag(HideReason.ui, true)
	else
		self:setHideFlag(HideReason.ui, false)
	end

	self:_checkVisible()
end

function LimitChallengeComponent:refreshVisibleMap()
	return TipVisibilityHelper.refresh(self)
end

function LimitChallengeComponent:setHideFlag(flag, isEnable)
	return TipVisibilityHelper.setHideFlag(self, flag, isEnable)
end

function LimitChallengeComponent:onBaseVisibleChanged(visible)
	if self.container then
		self.container:SetActive(visible)
	end

	self.baseVisible = visible
end

function LimitChallengeComponent:setIsVisible(visible)
	self.isVisible = visible

	self:setHideFlag(HideReason.isVisible, not visible)
end

function LimitChallengeComponent:onPriorityBreak(isShow, flag)
	self:setHideFlag(flag, isShow)
end

function LimitChallengeComponent:onFullScreenShowChange(isShow)
	self:setHideFlag(HideReason.fullScreenShow, isShow)
end

function LimitChallengeComponent:_checkVisible()
	local curVisible

	if self.challengeInfo ~= nil or self.isTempleScene or self.isInDittoDungeon then
		curVisible = not CommonSwitch.TARGET
	else
		curVisible = false
	end

	self:setHideFlag(HideReason.NoChallengeNoTempleNoDitto, not curVisible)
end

function LimitChallengeComponent:onBaseVisibleChanged(isVisible)
	if self.content then
		self.content:TryChangePage("challengeState", isVisible and 1 or 0)
	end
end

function LimitChallengeComponent:setForceHideFlag(isHide)
	self:setHideFlag(HideReason.forceHide, isHide)
end

return LimitChallengeComponent
