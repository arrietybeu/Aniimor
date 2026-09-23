-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\QuitBtnUIComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local RoguelikeData = require("Data.roguelike_data")
local ClientUtils = require("Utils.ClientUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local MessageName = require("Const.MessageName")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Time = require("Core.Common.Time")
local QuitBtnUIComponent = Class.LightClass("QuitBtnUIComponent", HudBaseComponent)
local LONG_PRESS_START_TIME = 0.25
local LONG_PRESS_DURATION = 0.55

local function getLongPressProgress(pressTime)
	return math.min(math.max((pressTime - LONG_PRESS_START_TIME) / (LONG_PRESS_DURATION - LONG_PRESS_START_TIME), 0), 1)
end

QuitBtnUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged"
	},
	[MessageName.IN_LEADER_WORLD_STATE_CHANGED] = {
		"refreshESCBtnState",
		true
	}
}

function QuitBtnUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnQuitUButton = objectReference:GetRefValue("btnQuitUButton")
	self.btnQuitHotKeyContent = objectReference:GetRefValue("btnQuitHotKeyContent")
end

function QuitBtnUIComponent:initProgressPressContainer(objectReference, setKey)
	self.progressPressContainerUContainer = objectReference:GetRefValue("progressPressContainerUContainer")

	if not self.progressPressContainerUContainer then
		return
	end

	self.progressPressContainerUContainer:SetActive(true)
	self.progressPressContainerUContainer:LoadDefaultUrlManually(function()
		self.keyProgressPress = self.progressPressContainerUContainer.content

		self.keyProgressPress:ProgressToValue(0, nil, 0)

		if not pg.global.ui.funMenuExit.model:checkShowEscKeyCode() or not pg.game.input:isUsingGamepad() then
			self.keyProgressPress.gameObject:SetActiveEx(false)
		end

		local quitDungeonBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.btnQuitUButton.gameObject, "quitDungeon")

		quitDungeonBinding.isVirtual = true
		quitDungeonBinding.actionPath = setKey
		quitDungeonBinding.priority = -100

		function quitDungeonBinding.luaTrigger(inputInfo)
			if pg.game.input:isUsingGamepad() and pg.global.ui.funMenuExit.model:checkShowEscKeyCode() then
				local pressKey = setKey .. "press"
				local pressTimeKey = setKey .. "pressTime"

				if inputInfo.phase == "Performed" then
					if self[pressKey] then
						self:killTimer(self[pressKey])
					end

					self[pressTimeKey] = 0

					self.keyProgressPress:ProgressToValue(0, nil, 0)

					self[pressKey] = self:startTimer(function()
						if self[pressTimeKey] >= LONG_PRESS_DURATION then
							return
						end

						self[pressTimeKey] = self[pressTimeKey] + Time.unscaledDeltaTime

						if self[pressTimeKey] > LONG_PRESS_START_TIME then
							self.keyProgressPress:ProgressToValue(getLongPressProgress(self[pressTimeKey]), nil, 0)
						end

						if self[pressTimeKey] >= LONG_PRESS_DURATION then
							self:onQuitBtnClick()

							self[pressTimeKey] = 0

							self:killTimer(self[pressKey])

							self[pressKey] = nil
						end
					end, 0, true)
				elseif inputInfo.phase == "Canceled" then
					if self[pressKey] then
						self:killTimer(self[pressKey])

						if self[pressTimeKey] <= LONG_PRESS_START_TIME then
							pg.game.input:triggerWaitAction(inputInfo.inputControl, {
								setKey
							})
						end

						self[pressTimeKey] = 0
						self[pressKey] = nil
					end

					self.keyProgressPress:ProgressToValue(0, nil, 0)
				end

				return false
			elseif inputInfo.phase == "Performed" then
				self:onQuitBtnClick()
			end
		end
	end)
end

function QuitBtnUIComponent:initView()
	self.isHomeland = false

	function self.btnQuitUButton.luaClick()
		self:onQuitBtnClick()
	end

	local needChange = pg.global.ui.funMenuExit.model:checkShowEscKeyCode()
	local setKey = needChange and "Hud/ExitDungeon" or "Hud/QuitDungeonGamepad"

	self.btnQuitHotKeyContent:SetHotKeyPaths(setKey)
	LuaUIUtils.waitHotKeyContentObjectReference(self, self.btnQuitHotKeyContent, function(objectReference)
		self:initProgressPressContainer(objectReference, setKey)
	end)
	self:refreshESCBtnState()
end

function QuitBtnUIComponent:refreshESCBtnState()
	local _, showESC = pg.global.ui.funMenuExit.model:checkShowFunc()

	self.btnQuitUButton:SetActive(showESC)

	self.isHomeland = pg.me and pg.me.space and pg.me.space:isHomeland()

	self.btnQuitHotKeyContent.gameObject:SetActiveEx(not pg.global.ui:runPlatformByMobile())
	self:onInputDeviceChanged()
end

function QuitBtnUIComponent:onInputDeviceChanged(deviceType)
	if not self.keyProgressPress then
		return
	end

	self.keyProgressPress:ProgressToValue(0, nil, 0)

	if pg.game.input:isUsingGamepad() and pg.global.ui.funMenuExit.model:checkShowEscKeyCode() then
		self.keyProgressPress.gameObject:SetActiveEx(true)
	else
		self.keyProgressPress.gameObject:SetActiveEx(false)
	end
end

function QuitBtnUIComponent:getExitTitleAndDesc()
	if self.isHomeland then
		return pg.getGameString("LEAVE_HOMELAND"), pg.global.ui.funMenuExit.model:getExitDesc() or pg.getGameString("LEAVE_HOMELAND_DESC")
	else
		return pg.getGameString("WARNING"), pg.global.ui.funMenuExit.model:getExitDesc() or pg.getGameString("EXIT_NORMAL_SCENE")
	end
end

function QuitBtnUIComponent:clearRogueInfo()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_ROG_BUFF_SELECT) then
		pg.global.ui:close(UIConst.UI_ID_ROG_BUFF_SELECT)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_DEFEAT) then
		pg.global.ui:close(UIConst.UI_ID_TOWER_DEFEAT)
	end

	ClientUtils.hideBattleUICountDown()
end

function QuitBtnUIComponent:onQuitBtnClick()
	if pg.global.ui.funMenuExit.model:isFastQuit() then
		local title, desc = self:getExitTitleAndDesc()

		pg.global.showConfirmMsgRaw(title, desc, function()
			pg.me:leaveDungeonScene()
		end, nil, nil, nil, nil, {
			pauseGame = true
		})

		return
	end

	local data

	if pg.me.space:isBossRushEnv() then
		local isBattleLevel = table.contains(Const.BossRushBattlePlace, BossRushUtils.getCurBossRushPlace())

		if (not pg.me:isInTeam() or pg.me:isTeamLeader()) and isBattleLevel then
			data = {
				btn1Type = Const.ExitButtonType.CONTINUE,
				btn2Type = Const.ExitButtonType.END_AND_EXIT,
				btn1Text = pg.getGameString("BOSS_RUSH_CONTINUE"),
				btn2Text = pg.getGameString("BOSS_RUSH_END_BATTLE"),
				backFunc2 = function()
					pg.me:endBossRushLevel()
				end
			}
		else
			pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_SETTLEMENT, {
				pageType = 0
			})

			return
		end
	elseif pg.me.space:isCatchRogue() then
		data = {
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn2Type = Const.ExitButtonType.TEMPORARY_EXIT,
			btn3Type = Const.ExitButtonType.END_AND_EXIT,
			btn1Text = pg.getGameString("REUNION_QUEST_CONTINUE"),
			btn2Text = pg.getGameString("REUNION_QUEST_LEAVE"),
			btn3Text = pg.getGameString("REUNION_QUEST_END"),
			backFunc2 = function()
				pg.me:saveCatchRogueGame()
			end,
			backFunc3 = function()
				pg.me:settleCatchRogueGame(true)
			end
		}
	elseif pg.me.space:isRogueEnv() then
		local levelCfg = RoguelikeData[pg.me.curRogueLayer]
		local canRetry = levelCfg and levelCfg.canRestart == 1 and pg.me.curRogueLayerState == DungeonConst.STATUS.PLAYING

		data = {
			btn1Text = pg.getGameString("REUNION_QUEST_CONTINUE"),
			btn2Text = pg.getGameString("REUNION_QUEST_LEAVE"),
			btn3Text = pg.getGameString("REUNION_QUEST_END"),
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn2Type = Const.ExitButtonType.TEMPORARY_EXIT,
			btn3Type = Const.ExitButtonType.END_AND_EXIT,
			backFunc2 = function()
				self:clearRogueInfo()
				ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
					pg.me:leaveDungeonScene()
				end)
			end,
			backFunc3 = function()
				self:clearRogueInfo()
				pg.global.ui:open(UIConst.UI_ID_TOWER_SETTLEMENT, {
					confirmCb = function()
						pg.me:leaveDungeonScene()
					end
				})
			end
		}

		if canRetry then
			data.btn4Text = pg.getGameString("REUNION_QUEST_AGAIN")
			data.btn4Type = Const.ExitButtonType.READJUST

			function data.backFunc4()
				self:clearRogueInfo()

				if pg.me.curRogueLayer and pg.me.curRogueLayer > 0 then
					pg.me:reStartRogue(pg.me.curRogueLayer)
				end
			end
		end
	elseif pg.space:isGrabEgg() then
		data = {
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn2Type = Const.ExitButtonType.END_AND_EXIT,
			backFunc2 = function()
				local title = pg.getGameString("WARNING")
				local desc = pg.global.ui.funMenuExit.model:getExitDesc() or pg.getGameString("GRAB_EGG_EXIT_ECS")

				pg.global.showConfirmMsgRaw(title, desc, function()
					pg.me:leaveDungeonScene()
				end, nil, nil, nil, nil, {
					pauseGame = true
				})
			end
		}
	elseif pg.me and pg.me:isInFishingCapture() then
		data = {
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn2Type = Const.ExitButtonType.END_AND_EXIT,
			btn1Text = pg.getGameString("REUNION_QUEST_CONTINUE"),
			btn2Text = pg.getGameString("CONSOLE_BAR_EXIT"),
			backFunc2 = function()
				local gamePhase = pg.me:getFishingCaptureCurrentPhase()

				if gamePhase == FishingCaptureConst.Phase.SETTLE then
					ClientUtils.exitDungeon()
				else
					pg.global.showConfirmMsgRaw(pg.getGameString("FC_QUIT_TITLE"), pg.getGameString("FC_QUIT_SUB"), function()
						pg.me:requestQuit()
					end)
				end
			end
		}
	elseif pg.space:isNpcDuel() then
		local canRestart = pg.space:isNpcDuelActive()

		data = {
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn4Type = canRestart and Const.ExitButtonType.READJUST or nil,
			btn3Type = Const.ExitButtonType.END_AND_EXIT,
			btn1Text = pg.getGameString("NPCDUEL_BATTLE_PAUSE_CONTINUE"),
			btn4Text = pg.getGameString("NPCDUEL_BATTLE_PAUSE_RESTART"),
			btn3Text = pg.getGameString("NPCDUEL_BATTLE_PAUSE_EXIT"),
			backFunc1 = function()
				return
			end,
			backFunc3 = function()
				pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("ONLY_CONFIRM_DESC"), function()
					pg.me:npcDuelExit()
				end, false)
			end,
			backFunc4 = canRestart and function()
				pg.me:npcDuelRematch()
			end or nil
		}
	else
		data = {
			btn1Type = Const.ExitButtonType.CONTINUE,
			btn2Type = Const.ExitButtonType.END_AND_EXIT,
			backFunc2 = function()
				local title, desc = self:getExitTitleAndDesc()

				pg.global.showConfirmMsgRaw(title, desc, function()
					ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
						pg.me:leaveDungeonScene()
					end)
				end, nil, nil, nil, nil, {
					pauseGame = true
				})
			end
		}
	end

	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_EXIT, data)
end

function QuitBtnUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return QuitBtnUIComponent
