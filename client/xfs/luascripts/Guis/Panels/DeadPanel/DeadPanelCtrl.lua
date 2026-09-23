-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DeadPanel\\DeadPanelCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("DeadPanelCtrl")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UICtrl = require("Guis.UICtrl")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local MessageName = require("Const.MessageName")
local DeathReasonConfigData = require("Data.death_reason_config_data")
local ElementPropData = require("Data.element_prop_data")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local LevelData = require("Data.level_data")
local SysConfigData = require("Data.sys_config_data")
local NoticeDef = require("Common.NoticeDef")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientUtils = require("Utils.ClientUtils")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local DeadPanelCtrl = Class.LightClass("DeadPanelCtrl", UICtrl)
local TeamRoomSocialComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomSocialComponent")
local bit = bit

local function isUsingGamepad()
	return pg.game.input and pg.game.input.isUsingGamepad and pg.game.input:isUsingGamepad()
end

local function getAnimClipLength(animation, clipName, fallback)
	if animation == nil or clipName == nil then
		return fallback
	end

	local clip = animation:GetClip(clipName)

	if clip == nil then
		return fallback
	end

	return clip.length
end

DeadPanelCtrl.messages = {
	[MessageName.TEAM_CONFIRM_CONTINUE_DUNGEON] = {
		"onDungeonFailedPush",
		false
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerTeleport",
		true
	},
	[MessageName.BOSS_RUSH_CUR_LEVEL_TEAM_REVIVE_COUNT_CHANGED] = {
		"onCurLevelTeamReviveCountChanged",
		true
	}
}

function DeadPanelCtrl:onOpen(info)
	self.view.countDownUCountDown:SetActive(false)

	self.reviveInfo = info

	self:initDeadInfo(info)

	if isUsingGamepad() then
		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if navMgr then
			self.savedFocusSnapshot = navMgr:SaveFocusStackSnapshot()

			navMgr:AddLuaFocusCursorMovedListener("DeadPanel", function()
				if self.entranceAnimating then
					navMgr:ClearFocus()

					return
				end

				self:refreshConsoleBarState()
			end)
		end
	end

	self:initPanelView()
	self:tryShowContinueBtn()

	self.chatCom = TeamRoomSocialComponent.new(self, self.view.chatUComponent, {
		dungeonSceneId = self.dungeonId
	})
end

function DeadPanelCtrl:addListener()
	function self.view.btnRebornUButton.luaClick()
		self:onRebornBtnClick()
	end

	function self.view.miniRebornUButton.luaClick()
		self:onRebornBtnClick()
	end

	function self.view.btnAbandonUButton.luaClick()
		self:onDungeonRebornBtnClick()
	end

	function self.view.btnMinimizedUButton.luaClick()
		self:setMiniPanelState(true)

		if isUsingGamepad() then
			local navMgr = CS.XGUI.Navigation.NavManager.Instance

			if navMgr and not navMgr:FocusItem(self.view.miniRebornUButton) then
				navMgr:TryFocusFirstAvailable()
			end
		end
	end

	function self.view.btnOpenedUButton.luaClick()
		self:setMiniPanelState(false)

		if isUsingGamepad() then
			local navMgr = CS.XGUI.Navigation.NavManager.Instance

			if navMgr then
				local focused = false
				local ok, btn = self.view.listRecommendUList:TryGetChildAt(0)

				if ok and btn and navMgr:FocusItem(btn) then
					focused = true
				end

				if not focused then
					navMgr:TryFocusFirstAvailable()
				end
			end
		end
	end

	function self.view.btnRefightUButton.luaClick()
		self:onRefightBtnClick()
	end

	function self.view.countDownUCountDown.luaFinished()
		self.inCountDown = false

		if not self.selfSelected then
			self:onDungeonRebornBtnClick()
		end
	end

	function self.view.canReviveCDUCountDown.luaFinished()
		self.view.rootUComponent:TryChangePage("SceneType", 0)
		self.view:SetReviveTips(true)
	end

	function self.view.listContinue.luaRenderItem(button, idx, data)
		if data.confirmStatus == Const.TEAM_DUNGEON_CONFIRM.NONE then
			button:TryChangePage("State", 0)
		elseif data.confirmStatus == Const.TEAM_DUNGEON_CONFIRM.AGREE then
			button:TryChangePage("State", 1)
		else
			button:TryChangePage("State", 2)
		end
	end

	self:bindHotKey("Common/MouseLeftButton", nil, function()
		if self.isInMiniPanel then
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.UI, true)
		end
	end, self.view.transform.gameObject, {
		startTriggerPressTime = 0.1,
		longPressEnd = function()
			if self.isInMiniPanel then
				pg.global.ui:refreshLockCursor()
			end
		end
	})
	LuaUIUtils.bindViewCtrlKeyBind(self.view.transform.gameObject)
end

function DeadPanelCtrl:refreshConsoleBarState()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local isOnSelectableItem = true
	local focused = navMgr.CurrentFocusedUContent

	if focused then
		local isOnRebornBtn = focused == self.view.btnRebornUButton or focused == self.view.miniRebornUButton

		if not isOnRebornBtn then
			local listTransform = self.view.listRecommendUList.transform
			local t = focused.transform
			local found = false

			while t ~= nil do
				if t == listTransform then
					found = true

					break
				end

				t = t.parent
			end

			isOnSelectableItem = found
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isOnSelectableItem", isOnSelectableItem)

	local showMini = true

	if self.isInNpcDuel then
		showMini = false
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInMiniPanel", self.isInMiniPanel and showMini)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isNotInMiniPanel", not self.isInMiniPanel and showMini)
end

function DeadPanelCtrl:onPlayerTeleport()
	if pg.me and pg.me:isDead() then
		return
	end

	self:dismiss()
end

function DeadPanelCtrl:onDestroy()
	if self.isInMiniPanel then
		self.isInMiniPanel = false

		self.adapter:refreshUIVisible(self.uid)
		self:applyMiniHudBlacklist(false)
	end

	self:setTipsBossBloodVisible(false)

	if self.animCbTimers then
		for k, timerId in pairs(self.animCbTimers) do
			TimerManager.removeTimer(timerId)

			self.animCbTimers[k] = nil
		end

		self.animCbTimers = nil
	end

	if self.recommendVisibleWaitTimer then
		TimerManager.removeTimer(self.recommendVisibleWaitTimer)

		self.recommendVisibleWaitTimer = nil
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if navMgr then
		navMgr:RemoveLuaFocusCursorMovedListener("DeadPanel")

		if self.savedFocusSnapshot then
			navMgr:RestoreFocusStackSnapshot(self.savedFocusSnapshot)

			self.savedFocusSnapshot = nil
		end
	end

	UICtrl.onDestroy(self)

	self.selfSelected = nil
	self.inCountDown = nil
	self.confirmPlayers = nil

	pg.game.audio:stopBgm(AudioConst.BgmPriority.DeadPanel)
end

function DeadPanelCtrl:initDeadInfo(info)
	self.isInRobEgg = Utils.isRobEggSceneId(pg.me.space.sceneId)
	self.isBossRush = pg.space:isBossRushEnv()
	self.blackScreenId = info and info.blackScreenId
	self.reason = info and info.reason
	self.recommendIndex = -1
	self.recommendLevel = 0
	self.recommendAbilityId = 0
	self.recommendElements = nil
	self.isInDungeon = Utils.isSelfInSpaceDungeon() and not pg.space:isBossRushEnv()
	self.isInNpcDuel = pg.space:isNpcDuel()

	local killerActorId = info and info.srcActorId or 0

	self.killerActorId = killerActorId

	local killerEntity = pg.getEntityByActorId(killerActorId)

	if self.isInDungeon then
		local dungeonId = pg.me.space.sceneId

		self.curDungeonData = LevelData[dungeonId]
	elseif killerEntity and Utils.isSemanticallyBoss(killerEntity) and killerEntity.sandboxId and LevelRewardLinkedData[killerEntity.sandboxId] and LevelRewardLinkedData[killerEntity.sandboxId].respawnTo then
		self.isInDungeon = true

		local respawnTo = LevelRewardLinkedData[killerEntity.sandboxId].respawnTo

		self.curDungeonData = {
			respawnTo = respawnTo
		}
	else
		self.curDungeonData = nil
	end

	if self.reason == Const.LIFE_DEAD_BY_COMBAT and killerEntity and killerEntity ~= pg.me then
		local fightTypeData = pg.game.map:isPOIPopupBelongsToFightType(pg.me.space.sceneId, killerEntity.staticId)

		self.recommendLevel = fightTypeData[2] or killerEntity.level or 0

		local againstElements = Utils.getAllAgainstElementsWithValues(killerEntity.elementTypes)

		if againstElements then
			self.recommendElements = {}

			local count = 0

			for element, data in pairs(againstElements) do
				if count >= 3 then
					break
				end

				table.insert(self.recommendElements, data)

				count = count + 1
			end
		end

		if Utils.isSemanticallyBoss(killerEntity) then
			local pdd = killerEntity:getConfigData()

			if pdd.recommendSkill then
				self.recommendAbilityId = pdd.recommendSkill
			end
		end

		self.recommendIndex = self:calculateRecommendInfo(killerEntity)
	end
end

function DeadPanelCtrl:onRefightBtnClick()
	pg.me:serverMsg("RPC_CS_ConfirmContinueDungeon", Const.TEAM_DUNGEON_CONFIRM.AGREE)
end

function DeadPanelCtrl:onDungeonFailedPush(confirmPlayers)
	self.confirmPlayers = confirmPlayers.confirmPlayers

	self:tryShowContinueBtn()
end

function DeadPanelCtrl:tryShowContinueBtn()
	if self.confirmPlayers then
		self:onContinueConfirmPush(self.confirmPlayers)
	end
end

function DeadPanelCtrl:onContinueConfirmPush(confirmPlayers)
	local ret = {}
	local uid = pg.me.uid

	self.selfSelected = false

	if not self.inCountDown then
		self.view.countDownUCountDown:Play(Const.TEAM_BASE.DESTROY_DUNGEON_TIMEOUT)
		self.view.countDownUCountDown:SetActive(true)

		self.inCountDown = true
	end

	for playerUId, confirmStatus in pairs(confirmPlayers) do
		ret[#ret + 1] = {
			playerUId = playerUId,
			confirmStatus = confirmStatus
		}

		if playerUId == uid and confirmStatus ~= Const.TEAM_DUNGEON_CONFIRM.NONE then
			self.selfSelected = true
		end
	end

	self.view.rootUComponent:TryChangePage("RefightCheck", self.selfSelected and 1 or 0)
	self.view.rootUComponent:TryChangePage("SingleOrTeam", 1)
	self.view.listContinue:SetList(ret)

	self.multiConfirmsPush = true
end

function DeadPanelCtrl:beginEntranceSuppression()
	self.entranceAnimating = true

	if isUsingGamepad() then
		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if navMgr then
			navMgr:ClearFocus()
		end
	end
end

function DeadPanelCtrl:endEntranceSuppression(callback)
	self.entranceAnimating = false

	if callback then
		callback()
	end
end

function DeadPanelCtrl:playRootAnimWithCallback(clipName, callback, fallbackDuration)
	if not self.view.rootAnimation or not clipName then
		return
	end

	self:beginEntranceSuppression()
	self.view.rootAnimation:Play(clipName)

	if not callback then
		self.entranceAnimating = false

		return
	end

	local duration = getAnimClipLength(self.view.rootAnimation, clipName, fallbackDuration or 0)

	self.animCbTimers = self.animCbTimers or {}

	if self.animCbTimers[clipName] then
		TimerManager.removeTimer(self.animCbTimers[clipName])

		self.animCbTimers[clipName] = nil
	end

	self.animCbTimers[clipName] = TimerManager.addTimer(duration, function()
		self.animCbTimers[clipName] = nil

		self:endEntranceSuppression(callback)
	end)
end

function DeadPanelCtrl:waitListRecommendFullyVisible(callback, maxWaitSec)
	local list = self.view.listRecommendUList

	if not list or not callback then
		self.entranceAnimating = false

		if callback then
			callback()
		end

		return
	end

	if self.recommendVisibleWaitTimer then
		TimerManager.removeTimer(self.recommendVisibleWaitTimer)

		self.recommendVisibleWaitTimer = nil
	end

	local interval = 0.05
	local elapsed = 0
	local timeout = maxWaitSec or 5

	local function fire()
		self.recommendVisibleWaitTimer = nil

		self:endEntranceSuppression(callback)
	end

	local check

	function check()
		self.recommendVisibleWaitTimer = nil
		elapsed = elapsed + interval

		local op = list.renderOpacity or 0

		if op >= 0.999 or elapsed >= timeout then
			fire()
		else
			self.recommendVisibleWaitTimer = TimerManager.addTimer(interval, check)
		end
	end

	self.recommendVisibleWaitTimer = TimerManager.addTimer(interval, check)
end

function DeadPanelCtrl:initPanelView()
	self.view:SetReviveTips(false)

	if self.isInRobEgg then
		self.view.btnBoxULayoutBox.gameObject:SetActiveEx(false)
		self.view.panelGameModeUComponent.gameObject:SetActiveEx(true)

		local isNearDead = pg.me:NEAR_DEAD_ST()

		self.view.panelGameModeUComponent:TryChangePage("Life", isNearDead and 0 or 1)

		if isNearDead then
			ClientTextUtils.setText(self.view.waitHelpUSDFText, pg.getGameString("FALLEN_RESURRECTION"))

			function self.view.waitHelpUCountDown.luaFinished()
				self.view.panelGameModeUComponent:TryChangePage("Life", 1)
				ClientTextUtils.setText(self.view.forbidHelpUSDFText, pg.getGameString("FALLEN_NORESURRECTION"))
			end

			self.view.waitHelpUCountDown:Play(SysConfigData.nearDeadDuration)
		else
			ClientTextUtils.setText(self.view.forbidHelpUSDFText, pg.getGameString("FALLEN_NORESURRECTION"))
		end

		function self.view.robEggAbandonBtn.luaClick()
			pg.me:serverMsg("RPC_CS_QuitSpace")
		end

		function self.view.robEggViewCombatUButton.luaClick()
			pg.global.showBubbleMessage(NoticeDef.FUNC_NOT_UNLOCK)
		end
	elseif self.isInNpcDuel then
		function self.view.npcDuelRechallengeUButton.luaClick()
			self:close()
			pg.me:npcDuelRematch()
		end

		function self.view.npcDuelBtnExitUButton.luaClick()
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("ONLY_CONFIRM_DESC"), function()
				self:close()
				pg.me:npcDuelExit()
			end, false)
		end

		ClientTextUtils.setText(self.view.npcDuelBtnExitTxtNameUText, pg.getGameString("NPCDUEL_BATTLE_PAUSE_EXIT"))
		ClientTextUtils.setText(self.view.npcDuelRechallengeUText, pg.getGameString("NPCDUEL_BATTLE_PAUSE_RESTART"))

		self.entranceAnimClip = "VX_Pb_Reborn_New_In"

		self:playRootAnimWithCallback(self.entranceAnimClip, function()
			self:onEntranceAnimEnd()
		end, 0.6)
		self.view.rootUComponent:TryChangePage("SceneType", "NpcPvp")
	elseif self.isBossRush then
		local reviveLast = SysConfigData.BossRushRespawnNum - (pg.space.curLevelTeamReviveCount or 0)

		if reviveLast == 0 then
			self.view.rootUComponent:TryChangePage("SceneType", 6)
		else
			self.view.rootUComponent:TryChangePage("SceneType", 5)
			self.view:StartReviveCD()
			self.view:SetReviveTipText(reviveLast)
		end
	else
		self.view.btnBoxULayoutBox.gameObject:SetActiveEx(true)
		self.view.panelGameModeUComponent.gameObject:SetActiveEx(false)

		if self.isInDungeon then
			self.view.rootUComponent:TryChangePage("SceneType", 1)

			if self.curDungeonData and self.curDungeonData.respawnButtonTxt then
				ClientTextUtils.setText(self.view.abandonBtnText, pg.getLocalizationText(self.curDungeonData.respawnButtonTxt))
			else
				ClientTextUtils.setText(self.view.abandonBtnText, pg.getGameString("GIVE_UP_CHALLENGE"))
			end

			self.entranceAnimClip = "VX_Pb_Reborn_New_In02"

			self:beginEntranceSuppression()
			self.view.rootAnimation:Play(self.entranceAnimClip)
			self:waitListRecommendFullyVisible(function()
				self:onEntranceAnimEnd()
			end)
		else
			self.view.rootUComponent:TryChangePage("SceneType", 0)
			self:beginEntranceSuppression()
			self:waitListRecommendFullyVisible(function()
				self:onEntranceAnimEnd()
			end)
		end
	end

	if self.reviveInfo and self.reviveInfo.sceneType then
		self.view.rootUComponent:TryChangePage("SceneType", self.reviveInfo.sceneType)
	end

	pg.game.audio:playBgm("", AudioConst.BgmPriority.DeadPanel)

	local title = self.reviveInfo and self.reviveInfo.title or pg.getGameString("DIE_TITLE")

	ClientTextUtils.setText(self.view.txtTitleUSDFText, title)

	local tip = self.reviveInfo and self.reviveInfo.tip or pg.getGameString("DIE_DESC")

	ClientTextUtils.setText(self.view.txtTipsUSDFText, tip)
	ClientTextUtils.setText(self.view.miniTitleUSDFText, pg.getGameString("DIE_TITLE"))
	ClientTextUtils.setText(self.view.miniTipsUSDFText, pg.getGameString("DIE_DESC"))

	self.isInMiniPanel = false

	function self.view.listRecommendUList.luaRenderItem(btn, idx, data)
		local objectReference = btn:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local rootUComponent = objectReference:GetRefValue("rootUComponent")
		local isRecommend = 0

		if self.recommendIndex > 0 and bit.band(self.recommendIndex, bit.lshift(1, data.index)) ~= 0 then
			isRecommend = 1
		end

		rootUComponent:TryChangePage("Recommend", isRecommend)
		rootUComponent:TryChangePage("Type", (data.index + 1) % 4)
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
		self:setRecommendBtnInfo(objectReference, btn, data.index, data)
	end

	self:initRecommendListInfo()
end

function DeadPanelCtrl:initRecommendListInfo()
	if self.isBossRush then
		return
	end

	local itemId = ClientConst.CALL_FOR_HELP_ITEM_ID
	local itemInvId = ItemUtils.getInvIdByItemId(itemId)
	local items = ItemUtils.getItemsById(pg.me, itemId)
	local itemGenId

	if items and items[1] then
		itemGenId = items[1].genID
	end

	local listData = Utils.deepCopyTable(DeathReasonConfigData)
	local listCount = #listData

	for idx, data in ipairs(listData) do
		data.index = idx - 1
	end

	if self.recommendElements == nil then
		listData[2] = nil
	end

	if self.recommendAbilityId <= 0 then
		listData[3] = nil
	end

	local hideCallForHelp = self.reviveInfo and self.reviveInfo.hideCallForHelp

	if hideCallForHelp or pg.me.level < 10 or itemGenId == nil or self.isInNpcDuel then
		listData[4] = nil
	else
		listData[4].itemInvId = itemInvId
		listData[4].itemGenId = itemGenId
	end

	for i = 1, listCount - 1 do
		local validIndex = i + 1

		while validIndex <= listCount and listData[validIndex] == nil do
			validIndex = validIndex + 1
		end

		if listCount < validIndex then
			break
		end

		if listData[i] == nil then
			listData[i] = listData[validIndex]
			listData[validIndex] = nil
		end
	end

	self.view.listRecommendUList:SetList(listData)
end

function DeadPanelCtrl:onEntranceAnimEnd()
	if not isUsingGamepad() then
		return
	end

	if self.isInNpcDuel or self.isInRobEgg then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local focused = false

	for i = 0, 3 do
		local ok, btn = self.view.listRecommendUList:TryGetChildAt(i)

		if ok and btn then
			if navMgr:FocusItem(btn) then
				focused = true

				break
			end
		else
			break
		end
	end

	if not focused then
		navMgr:TryFocusFirstAvailable()
	end

	self:refreshConsoleBarState()
end

function DeadPanelCtrl:onRebornBtnClick()
	self:requestRevive(Const.REVIVE_TYPE_NORMAL)
end

function DeadPanelCtrl:onDungeonRebornBtnClick()
	if self.curDungeonData and self.curDungeonData.respawnCheckTxt then
		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getLocalizationText(self.curDungeonData.respawnCheckTxt), function()
			self:giveUpChallenge()
		end)
	else
		self:giveUpChallenge()
	end
end

function DeadPanelCtrl:giveUpChallenge()
	if pg.me and pg.me:isInFishingCapture() and pg.me:getFishingCaptureCurrentPhase() == FishingCaptureConst.Phase.SETTLE then
		ClientUtils.exitDungeon()
		self:close()
	elseif self.curDungeonData and self.curDungeonData.respawnTo and #self.curDungeonData.respawnTo >= 2 then
		self:close()

		if pg.me.space.sceneId ~= self.curDungeonData.respawnTo[1] then
			if pg.me.life == Const.LIFE_DEAD then
				pg.me.forbidRevivalPerformance = true

				pg.me:playPlayerDeadDissolveEffect()

				if pg.me.dungeonReviveTimer ~= nil then
					pg.me:removeTimer(pg.me.dungeonReviveTimer)

					pg.me.dungeonReviveTimer = nil
				end

				pg.me.dungeonReviveTimer = pg.me:addTimer(SysConfigData.playerDeadDissolveEffectDuration or 3.2, function()
					self:requestRevive(Const.REVIVE_TYPE_HELP)
					pg.me:CallServerMsgTeleportToScene(self.curDungeonData.respawnTo[1], self.curDungeonData.respawnTo[2], false)
				end)
			end
		else
			if pg.me.life == Const.LIFE_DEAD then
				pg.me:doRevive(self.reason, Const.REVIVE_TYPE_NORMAL)
			end

			pg.me:CallServerMsgTeleportToScene(self.curDungeonData.respawnTo[1], self.curDungeonData.respawnTo[2], false)
		end
	else
		self:requestRevive(Const.REVIVE_TYPE_NORMAL)
	end
end

function DeadPanelCtrl:requestRevive(reviveType)
	self:close()

	local blackScreenId = self.blackScreenId

	if blackScreenId ~= nil and reviveType == Const.REVIVE_TYPE_NORMAL then
		pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.DIE, {
			[UIConst.UI_ID_DEAD_PANEL] = true,
			[UIConst.UI_ID_BLACK_SCREEN] = true
		})
		pg.me:playPlayerDeadDissolveEffect()
		self:startDelayBlackScreenTimer(blackScreenId, reviveType)
	else
		pg.me:doRevive(self.reason, reviveType)
	end
end

function DeadPanelCtrl:startDelayBlackScreenTimer(blackScreenId, reviveType, delayTime)
	delayTime = delayTime or 1

	if self.delayTimer ~= nil then
		TimerManager.removeTimer(self.delayTimer)

		self.delayTimer = nil
	end

	self.delayTimer = TimerManager.addTimer(delayTime, function()
		pg.me:startDelayReviveTimer(self.reason, reviveType)
		pg.global.ui.blackScreen:open({
			id = blackScreenId,
			startCloseCb = function()
				pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.DIE)

				if pg.me.life == Const.LIFE_ALIVE then
					pg.me:performPlayerRevivalPerformance(nil, true)
				end
			end
		})
	end)
end

function DeadPanelCtrl:calculateRecommendInfo(killerEntity)
	local recommendIndex = 0
	local sumLevel = 0
	local petCount = 0
	local elementAdvantagePetCount = 0
	local player = pg.me

	for _, petId in pairs(player.petPrepareList) do
		local petInfo = player:getPetInfo(petId)

		if petInfo then
			sumLevel = sumLevel + petInfo.level
			petCount = petCount + 1
		end

		local petEntity = pg.getEntity(petId)

		if petEntity then
			local configData = petEntity:getConfigData()
			local mainElementType = configData.mainElementType

			if Utils.getElementAgainstValue(mainElementType, killerEntity.elementTypes, petEntity, killerEntity) > 1 then
				elementAdvantagePetCount = elementAdvantagePetCount + 1
			end
		end
	end

	local playerPetAvgLevel = petCount > 0 and lume.round(sumLevel / petCount, 0.01) or 0

	if playerPetAvgLevel < self.recommendLevel * 0.9 then
		recommendIndex = recommendIndex + 1
	end

	if elementAdvantagePetCount <= 0 then
		recommendIndex = recommendIndex + 2
	end

	if recommendIndex > 0 then
		return recommendIndex
	end

	if self.recommendAbilityId > 0 then
		return 4
	end

	return 8
end

function DeadPanelCtrl:setRecommendBtnInfo(objectReference, btn, idx, data)
	local viewDetailBtn = objectReference:GetRefValue("viewDetailBtn")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	iconUImage.url = data.icon
	viewDetailBtn.interactable = true

	local function uiOpenCb()
		if data.guideId ~= nil then
			pg.game.guide:clientStartGuide(data.guideId)
		end
	end

	if idx == 0 then
		btn.enabledTooltip = false

		local levelNumUSDFText = objectReference:GetRefValue("levelNumUSDFText")
		local showLevel = self.recommendLevel

		if showLevel == 0 then
			showLevel = math.max(pg.me.maxPreparedPetLevel or 0, pg.me.level)
		end

		ClientTextUtils.setText(levelNumUSDFText, tostring(showLevel))
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

		viewDetailBtn.interactable = not self.isInNpcDuel

		function viewDetailBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
				selectMinLevelBattlePet = true
			}, uiOpenCb)
		end
	elseif idx == 1 then
		btn.enabledTooltip = false

		local listElementUList = objectReference:GetRefValue("listElementUList")

		function listElementUList.luaRenderItem(button, index, data)
			local elementName = ElementPropData[data.element] and ElementPropData[data.element].name

			button:TryChangePage("type", elementName)

			function button.luaClick()
				if ToBool(self.killerActorId) then
					pg.global.ui:open(UIConst.UI_ID_TARGET_ELEMENT_POPUP, {
						targetActorId = self.killerActorId
					})
				else
					pg.global.ui.tips:showRestraint(elementName)
				end
			end
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
		listElementUList:SetList(self.recommendElements)

		function viewDetailBtn.luaClick()
			if ToBool(self.killerActorId) then
				pg.global.ui:open(UIConst.UI_ID_TARGET_ELEMENT_POPUP, {
					targetActorId = self.killerActorId
				})
			else
				pg.global.ui.tips:showRestraint(nil, uiOpenCb)
			end
		end
	elseif idx == 2 then
		btn.enabledTooltip = true

		local abilityData = pg.global.abilityMgr:getAbilityParamDataByParamId(self.recommendAbilityId)
		local finalRecommendText = ClientTextUtils.concatByLanguage(pg.getGameString("RECOMMEND"), string.format("<style=Hint_BgD>%s</style>", pg.getLocalizationText(abilityData.name)))

		ClientTextUtils.setText(txtNameUSDFText, finalRecommendText)

		iconUImage.url = abilityData.icon

		LuaUIUtils.setRenderSKillTooTip(btn, abilityData)
	elseif idx == 3 then
		btn.enabledTooltip = false

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

		function viewDetailBtn.luaClick()
			local invId = data.itemInvId
			local genId = data.itemGenId

			self:callForHelp(invId, genId)
		end
	end
end

function DeadPanelCtrl:gotoHelpPanel(helpId, uiOpenCb)
	pg.global.ui:open(UIConst.UI_ID_HELP, {
		helpId = helpId
	}, uiOpenCb)
end

function DeadPanelCtrl:callForHelp(invIdx, genId)
	local me = pg.me

	if me then
		if pg.me:isInTeam() then
			pg.global.showBubbleMessageRaw(pg.getGameString("CANT_USE_HORN_TIPS"))
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("USE_HORN_TIPS"), function()
				function me.overrideRebornPerformCb()
					if pg.me then
						pg.me:reqSendHorn(invIdx, genId)
					end
				end

				self:requestRevive(Const.REVIVE_TYPE_NORMAL)
			end, nil)
		end
	end
end

function DeadPanelCtrl:onCurLevelTeamReviveCountChanged()
	local reviveLast = SysConfigData.BossRushRespawnNum - (pg.space.curLevelTeamReviveCount or 0)

	if reviveLast == 0 then
		self.view:StopReviveCD()
		self.view.rootUComponent:TryChangePage("SceneType", 6)
	else
		self.view:SetReviveTipText(reviveLast)
	end
end

local MINI_HUD_HIDE_REASON = "DeadPanelMini"
local MINI_PANEL_UI_WHITE_LIST = {
	[UIConst.UI_ID_TIPS] = true,
	[UIConst.UI_ID_INTERACT] = true,
	[UIConst.UI_ID_HUD_V2] = true
}
local MINI_HUD_COMPONENT_BLACK_LIST = {
	HudSplicingCfg.componentName.skillRD,
	HudSplicingCfg.componentName.hp,
	HudSplicingCfg.LayoutName.LD,
	HudSplicingCfg.componentName.mobileSkill,
	HudSplicingCfg.componentName.mobile3C,
	HudSplicingCfg.componentName.mobileHpFuse,
	HudSplicingCfg.componentName.quickChat
}

function DeadPanelCtrl:getWhiteList()
	if self.isInMiniPanel then
		return MINI_PANEL_UI_WHITE_LIST
	end

	return UICtrl.getWhiteList(self)
end

function DeadPanelCtrl:applyMiniHudBlacklist(enable)
	local hud = pg.global.ui.hudV2

	if not hud then
		return
	end

	if enable then
		hud:hideBaseComponentsWithState(MINI_HUD_COMPONENT_BLACK_LIST, MINI_HUD_HIDE_REASON)
	else
		hud:restoreBaseComponentsState(MINI_HUD_HIDE_REASON)
	end
end

function DeadPanelCtrl:setTipsBossBloodVisible(visible)
	local uiConfig = UIConst.UI_CONFIGS[UIConst.UI_ID_DEAD_PANEL]

	if uiConfig then
		uiConfig.forceShowTips = visible or nil
	end

	local tips = pg.global.ui.tips

	if tips then
		tips:onUIVisibleChanged()
	end
end

function DeadPanelCtrl:setMiniPanelState(isInMiniPanel)
	if self.isInMiniPanel == isInMiniPanel then
		return
	end

	if isInMiniPanel then
		self:applyMiniHudBlacklist(true)
		self:setTipsBossBloodVisible(true)
	end

	self.isInMiniPanel = isInMiniPanel

	self:setIsModel(not isInMiniPanel)
	self:refreshConsoleBarState()
	self.adapter:refreshUIVisible(self.uid)

	if not isInMiniPanel then
		self:applyMiniHudBlacklist(false)
		self:setTipsBossBloodVisible(false)
	end

	self.view.chatUComponent.gameObject:SetActiveEx(isInMiniPanel and pg.me:isInTeam())
end

return DeadPanelCtrl
