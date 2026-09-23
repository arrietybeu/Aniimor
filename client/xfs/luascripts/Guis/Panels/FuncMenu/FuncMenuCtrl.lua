-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenu\\FuncMenuCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("HelpCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FuncMenuCtrl = Class.LightClass("FuncMenuCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local VirtualCameraBlendFunction = CS.FunPlus.WorldX.VirtualCamera.VirtualCameraBlendFunction
local HotkeyConst = require("Const.HotkeyConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local CommonSwitch = require("Common.CommonSwitch")
local SysEventData = require("Data.sys_event_data")
local lume = require("Core.Common.lume")
local ClientRepo = require("Core.Client.ClientRepo")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local RedDotConst = require("Const.RedDotConst")
local FuncIdConfigData = require("Data.func_index_config_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local AudioConst = require("Const.AudioConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local WeatherData = require("Data.weather_data")
local GameEventData = require("Data.game_event_data")
local MeteorologyData = require("Data.meteorology_data")
local ClientSwitch = require("Common.ClientSwitch")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Time = require("Core.Common.Time")
local RogueUtils = require("Utils.RogueUtils")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local GameStringConfig = require("Data.gamestring_config_data")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local BossRushUtils = require("Utils.BossRushUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local SceneData = require("Data.scene_data")
local NoticeDef = require("Common.NoticeDef")
local BattlePassData = require("Data.event_battlepass_data")
local GlobalData = require("Core.Client.GlobalData")
local AiAssistantData = require("Data.ai_assistant_data")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomelandReportUtils = require("Utils.HomelandReportUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local FuncMenuVipComponent = require("Guis.Panels.FuncMenu.Component.FuncMenuVipComponent")

FuncMenuCtrl.ButtonState = {
	UnLocking = 4,
	Forbidden = 3,
	UnLock = 2,
	Lock = 1,
	Empty = 0
}

local WRIST_WATCH_ANIMATION_RETRY_MAX_SECONDS = 1.5

FuncMenuCtrl.messages = {
	[MessageName.LOGIC_TIME_UPDATE] = {
		"refreshLogicTime",
		true
	},
	[MessageName.SCENE_LOADED] = {
		"onSceneLoaded",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"refreshFixedFuncList",
		true
	},
	[MessageName.PLAYER_NAME_CHANGE] = {
		"setPlayerName",
		true
	},
	[MessageName.PLAYER_ICON_CHANGE] = {
		"setPlayerIcon",
		true
	},
	[MessageName.PLAYER_FRAME_CHANGE] = {
		"setPlayerIcon",
		true
	},
	[MessageName.WEATHER_REFRESH] = {
		"onWeatherRefresh",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onPropChangedCallback",
		true
	},
	[MessageName.GRAB_EGG_RED_DOT_CHANGED] = {
		"refreshGrabEggModeRedDot",
		true
	},
	[MessageName.CHAT_RED_DOT_UPDATE] = {
		"onChatRedDotMsg",
		true
	},
	[MessageName.PET_RESEARCH_AREA_SELECT_CHANGED] = {
		"onPetResearchAreaSelectChanged",
		true
	},
	[MessageName.SURVEY_MAP_CHANGE] = {
		"refreshFixedFuncList",
		true
	},
	[MessageName.UI_ON_CLOSE] = {
		"onAnyUIClose",
		true
	},
	[MessageName.BOSS_RUSH_RED_DOT_CHANGED] = {
		"refreshBossRushRedDot",
		true
	}
}

function FuncMenuCtrl:stopWristWatchAnimationRetry()
	self.wristWatchAnimationRetryElapsed = nil

	if self.wristWatchTickTimer then
		self:killTimer(self.wristWatchTickTimer)

		self.wristWatchTickTimer = nil
	end
end

function FuncMenuCtrl:startWristWatchAnimationRetry()
	if self.wristWatchTickTimer then
		return
	end

	self.wristWatchAnimationRetryElapsed = 0
	self.wristWatchTickTimer = self:startTimer(function()
		self:tick()
	end, 0, true)
end

function FuncMenuCtrl:tick()
	if not self.wristWatchTickTimer then
		return
	end

	self.wristWatchAnimationRetryElapsed = self.wristWatchAnimationRetryElapsed + Time.unscaledDeltaTime

	if not self:checkUIVisible() or LuaUIUtils.openWristWatch(false) or self.wristWatchAnimationRetryElapsed >= WRIST_WATCH_ANIMATION_RETRY_MAX_SECONDS then
		self:stopWristWatchAnimationRetry()
	end
end

function FuncMenuCtrl:tryOpenWristWatchWithRetry()
	if not LuaUIUtils.openWristWatch(false) then
		self:startWristWatchAnimationRetry()
	end
end

function FuncMenuCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.vipComponent = FuncMenuVipComponent.new(self)

	if info and info.selectedFuncID then
		self.initSelectedFuncId = info.selectedFuncID
	end

	if info then
		self.unlockFuncId = info.unlockFuncId
		self.guideGroupId = info.guideGroupId
		self.dialogueGraphId = info.dialogueGraphId
		self.isFuncUnlocking = self.unlockFuncId ~= nil
	end

	self.showUnlockOrForbiddenTipId = nil
	self.screenSize = 18
	self.rowSize = 4
	self.size2tIndex = {
		[1] = 1,
		[2] = 2
	}
	self.size2Ani = {
		[0] = {
			open = "VX_Node_FunMenu_Item_In",
			close = "VX_Node_FunMenu_Item_Out"
		},
		{
			open = "VX_Node_FunMenu_Item_In",
			close = "VX_Node_FunMenu_Item_Out"
		},
		{
			open = "VX_Node_FunMenu_Item_In",
			close = "VX_Node_FunMenu_Item_Out"
		}
	}
	self.closeAni = "VX_Pb_FunMenu_New_Out"
	self.delayTasks = {}
	self.itemListAniDelay = 0.05
	self.itemLineDelay = 0.05

	self:initFuncList()
	self:initBottomButtonList()
	pg.me:forceExitCaptureMode()
	self:resetCamera()
	pg.game.social:checkAndStopHornAnimation()

	if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
		pg.me:magnesisCancel()
	end

	if pg.me:WALKING_ATTACK_ST() then
		pg.me:_cancel_WALKING_ATTACK_ST()
		pg.game.controller.nextSkillAction:clearNextSkillCache()
	end

	self:tryOpenWristWatchWithRetry()
	self:setButtonsInteractable(false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.FuncMenu, true)

	self.startAniTimer = TimerManager.addTimer(self.itemListAniDelay, function()
		self.startAniTimer = nil

		self:playOpenAni()
	end)

	self.view.btnExitUButton:SetGamepadLongPress("Raw/GamepadButtonWest")
	self.view.btnExitUButton:SetHotkeyBanRay(true)
end

function FuncMenuCtrl:initFuncList()
	self.funcListEle = {}
	self.bottonFuncListEle = {}

	self:initPlayerInfo()
	self:initFixedFuncList()
	self:initBottomFuncList()
end

function FuncMenuCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.bgCloseUButton.luaClick()
		if pg.game.input:isUsingGamepad() then
			return
		end

		self:closePanel()
	end

	function self.view.btnExitUButton.luaClick()
		if ClientUtils.isPublicClient() == false then
			ClientUtils.gc()
		end

		self:quit()
	end

	function self.view.btnCopyUIDUButton.luaClick()
		local text = pg.me:isFromCopy() and pg.me:getCopyPlayerUid() or pg.me.uid

		UIUtils.ClipboardWriter(text)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	self:initHotKeys()

	local listScrollGamepadBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "listScrollGamepadBind")

	listScrollGamepadBind.actionPath = "Hud/ScrollGamepad"
	listScrollGamepadBind.isVirtual = true
	listScrollGamepadBind.priority = -1

	function listScrollGamepadBind.luaTrigger(inputInfo)
		self.delta = inputInfo.valueVec2 * 150
		self.delta.x = 0

		if inputInfo.phase == "Performed" then
			if self.listScrollTimer == nil then
				self.listScrollTimer = self:startTimer(function()
					local targetPos = self.view.listBtnUList.currentScrollPosition - self.delta

					self.view.listBtnUList:GoToPos(targetPos, false)
				end, 0, true)
			end
		elseif inputInfo.phase == "Canceled" and self.listScrollTimer then
			self:killTimer(self.listScrollTimer)

			self.listScrollTimer = nil
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.actionPath = "Hud/OpenSetup"
	closeBind.isVirtual = true
	closeBind.priority = -1

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not pg.game.input:isUsingGamepad() then
				self.view.btnCloseUButton:OnClickSimulate()

				return
			else
				return true
			end
		elseif inputInfo.phase == "Checked" then
			return false
		end
	end

	self.view.btnCopyUIDUButton:SetGamepadAction("Raw/GamepadSelect", self.view.copyBtnHotkeyContent.gameObject)

	function listScrollGamepadBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and not pg.game.input:isUsingGamepad() then
			return
		end
	end

	self.view.btnEditUButton:SetGamepadAction("Raw/GamepadStart", self.view.editHotKeyContent.gameObject)

	function self.view.keyListConsoleUList.luaRenderItem(button, index, data)
		self:onRenderBottomButtonItem(button, index, data)
	end

	FuncMenuCtrl.super.bindHotKeyPerform(self, "Raw/GamepadButtonEast", function()
		self.view.btnCloseUButton:OnClickSimulate()

		local isPS = PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation

		if isPS then
			self:closePanel()
		end
	end)
end

function FuncMenuCtrl:onSceneLoaded()
	self:initFuncList()
	self:resetCamera()
end

function FuncMenuCtrl:onInputDeviceChanged()
	self.keyProgressPress.gameObject:SetActiveEx(pg.game.input:isUsingGamepad())
end

function FuncMenuCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.lastRecordFunc = nil
	self.lastRecordFuncType = nil

	pg.global.ui.playerEnhance.model:redDot_SetPlayerHUDTreeState()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU)
	self.vipComponent:requestRedDot()
	pg.global.ui.announcement.model:getAnnouncementData(false, true)
end

function FuncMenuCtrl:onVisibleChange(visible)
	UICtrl.onVisibleChange(visible)

	local keepCamera = self:needKeepCamera()

	if visible then
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)
		self:resetCamera()
		self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		self.needRestoreFromManualClose = nil
	else
		self:stopWristWatchAnimationRetry()

		if not keepCamera then
			pg.game.camera:cancelBlendToFixedWithTarget(0.5)
		end
	end

	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.FuncMenu, visible)
end

function FuncMenuCtrl:needKeepCamera()
	local topUid = pg.global.ui:getLastNormalFirstPanel()
	local topCtrl = pg.global.ui:tryGetCtrlByUid(topUid)

	return topCtrl ~= nil and topCtrl:isBlurBg()
end

function FuncMenuCtrl:onPropChangedCallback(data)
	if data.id == Const.CommonEnergyType_Stamina then
		self:initBottomFuncList()
	end
end

function FuncMenuCtrl:refreshGrabEggModeRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE)
end

function FuncMenuCtrl:refreshBossRushRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.BOSS_RUSH_MAIN)
end

function FuncMenuCtrl:onChatRedDotMsg()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_FRIEND)
end

function FuncMenuCtrl:playCloseManual()
	self.needRestoreFromManualClose = true

	self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
end

function FuncMenuCtrl:onAnyUIClose()
	if not self.needRestoreFromManualClose then
		return
	end

	if self.isCloseing or self.isFuncUnlocking then
		return
	end

	if not self:checkUIVisible() then
		return
	end

	self.needRestoreFromManualClose = nil

	self:resetCamera()
	self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function FuncMenuCtrl:resetCamera()
	LuaUIUtils.openWristWatchCamera()
	self:tryOpenWristWatchWithRetry()
end

function FuncMenuCtrl:resetCameraInfo()
	if not UNITY_EDITOR then
		return
	end

	local fixedWithTargetCameraMode = pg.game.camera.fixedWithTargetCameraMode

	if fixedWithTargetCameraMode == nil then
		return
	end

	local candidate = LuaUIUtils.getWristWatchCameraInfo()

	fixedWithTargetCameraMode.cameraMode.pivotOffset = candidate.pivotOffset

	fixedWithTargetCameraMode:setCameraInfoByActorId(candidate.cameraPos, candidate.cameraRot, candidate.fov, pg.me.actorId)
end

function FuncMenuCtrl:onDestroy()
	self:stopWristWatchAnimationRetry()
	pg.global.ui.tips:hideAIHelperTips(104)
	LuaUIUtils.closeWristWatchCamera()
	pg.me:refreshAppearanceCollideMenu(false)
	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.FuncMenu, false)

	self.unlockFuncId = nil
	self.guideGroupId = nil
	self.dialogueGraphId = nil
	self.unlockButton = nil
	self.fixedFuncListData = nil
	self.funcListEle = nil
	self.bottonFuncListEle = nil
	self.iconUImage = nil

	pg.game.audio:triggerEvent(UIConst.DEFAULT_CLOSE_AUDIO)
	pg.global.ui.hudV2:removeCurUnlockFunc()
	UICtrl.onDestroy(self)

	if self.listScrollTimer then
		self:killTimer(self.listScrollTimer)

		self.listScrollTimer = nil
	end
end

function FuncMenuCtrl:findCoordByFuncTypeAndFuncName()
	if not self.lastRecordFuncType or not self.lastRecordFunc then
		return
	end

	local x, y

	if self.lastRecordFuncType == "side" then
		local funcListData = self:getFixedFuncListData()
		local count = 1
		local size = 0
		local yStart = 0

		for i = 1, #funcListData do
			if funcListData[i].tIndex ~= 0 then
				if size % self.rowSize == 0 then
					yStart = count
				end

				local x1 = math.floor(size / self.rowSize) + 1
				local y1 = count - yStart + 1

				if funcListData[i].functionType == self.lastRecordFunc then
					x = x1
					y = y1
				end

				count = count + 1
				size = size + funcListData[i].size
			end
		end
	else
		local bottomFuncData = self:getBottomFuncListData()

		for i = 1, #bottomFuncData do
			local x1 = math.floor((i - 1) / 1) + 1
			local y1 = (i - 1) % 1 + 1

			if bottomFuncData[i]["function"] == self.lastRecordFunc then
				x = x1
				y = y1
			end
		end
	end

	return x, y
end

function FuncMenuCtrl:initPlayerInfo()
	function self.view.btnEditUButton.luaClick()
		local param = {
			openType = ClientConst.PlayerInfoOpenType.Edit,
			playerId = pg.me.uid,
			callBack = function()
				pg.global.ui.hudV2:openFuncMenu()
			end
		}

		pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_MAIN, param)
		self:closePanel()
	end

	self.view.editAvatarUButton.enabledTooltip = false

	self:refreshPlayerInfo()

	do return end

	function self.view.editAvatarUButton.luaRenderTooltip(button, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local btnChangeNameUButton = objectReference:GetRefValue("btnChangeNameUButton")
		local btnChangePhotoUButton = objectReference:GetRefValue("btnChangePhotoUButton")
		local btnChangePhotoBorderUButton = objectReference:GetRefValue("btnChangePhotoBorderUButton")

		function btnChangeNameUButton.luaClick()
			self.view.editAvatarUButton:CloseTooltip()
			pg.global.ui:open(UIConst.UI_ID_PLAYER_RENAME, {
				mode = "Rename",
				title = pg.getGameString("CHANGE_NAME_TIP"),
				confirmCallback = function(newName)
					pg.me:serverMsg("RPC_CS_ChangePlayerName", newName)
				end
			})
		end

		function btnChangePhotoUButton.luaClick()
			self.view.editAvatarUButton:CloseTooltip()
			pg.global.ui:open(UIConst.UI_ID_CHANGE_AVATAR, {
				changeAvatar = true
			})
		end

		function btnChangePhotoBorderUButton.luaClick()
			self.view.editAvatarUButton:CloseTooltip()
			pg.global.ui:open(UIConst.UI_ID_CHANGE_AVATAR, {
				changeAvatarFrame = true
			})
		end
	end

	self:refreshPlayerInfo()
end

function FuncMenuCtrl:refreshPlayerInfo()
	local me = pg.me

	if me:isFromCopy() then
		ClientTextUtils.setText(self.view.playerUIDUText, "UID: ", me:getCopyPlayerUid())
	else
		ClientTextUtils.setText(self.view.playerUIDUText, pg.me.uid)
	end

	self:setPlayerName()
	self:setPlayerIcon()
	self:refreshLogicTime()
end

function FuncMenuCtrl:setPlayerName()
	ClientTextUtils.setText(self.view.playerNameUText, LuaUIUtils.getMeDisplayName())
end

function FuncMenuCtrl:setPlayerIcon()
	local data = {
		showAvatarFrame = true,
		showAvatar = true,
		isEquip = false,
		isLock = false,
		avatarIconId = pg.me.headIcon,
		avatarFrameIconId = pg.me.headFrame
	}

	LuaUIUtils.renderPlayerAvatar(self.view.editAvatarUButton, data)
end

function FuncMenuCtrl:refreshLogicTime()
	if not pg.me.space then
		return
	end

	local hour, minute = pg.me.space:getLogicHourAndMin()

	if hour < 10 then
		hour = "0" .. hour
	end

	if minute < 10 then
		minute = "0" .. minute
	end

	ClientTextUtils.setText(self.view.timeUText, hour, ":", minute)
end

function FuncMenuCtrl:initFixedFuncList()
	local funcListData = self:getFixedFuncListData()

	function self.view.listBtnUList.luaRenderItem(button, index, data)
		self:renderFixedFuncListItem(button, index, data)

		function button.luaClick()
			local isReviewLock = not LuaUIUtils.checkFuncUnlockForREVIEW(data.functionName)

			if isReviewLock then
				return
			end

			local isLock = not pg.me:checkFunctionUnlock(data.functionName)

			if isLock then
				self:handleTips(data, self.ButtonState.Lock)
				pg.game.audio:playEvent(AudioConst.EVENT_FUNC_MENU_LOCK_ICON)

				return
			end

			if data.id then
				local isForbidden, tip = LuaUIUtils.checkFuncIdForbidden(data.id)

				if isForbidden then
					self:handleTips(data, self.ButtonState.Forbidden, tip)

					return
				end
			end

			self.view.rootUComponent:TryChangePage("Unlock", 0)

			if data.functionType then
				self[data.functionType](self, data)

				self.lastRecordFuncType = "side"
				self.lastRecordFunc = data.functionType
			end
		end

		if pg.game.guide:isInGuide() then
			button.visualInteractable = false
		end

		self:bind_RedDotForMenuItem(button, data)
	end

	function self.view.listBtnUList.luaFinishRender(list)
		local a = 1
	end

	self.fixedFuncListData = funcListData

	self.view.listBtnUList:SetList(funcListData)
end

function FuncMenuCtrl:refreshFixedFuncList()
	if not self.view or not self.view.listBtnUList then
		return
	end

	local funcListData = self:getFixedFuncListData()

	self.fixedFuncListData = funcListData

	self.view.listBtnUList:SetList(funcListData)
end

function FuncMenuCtrl:handleTips(data, type, tip)
	if self.showUnlockOrForbiddenTipId == data.id then
		self:hiddenUnlockOrForbiddenTip()
	else
		self:showUnlockOrForbiddenTip(data, type, tip)
	end
end

function FuncMenuCtrl:showUnlockOrForbiddenTip(data, type, tip)
	self.view.rootUComponent:TryChangePage("Unlock", 1)
	self.view.rootUComponent:TryChangePage("TipsState", type == self.ButtonState.Lock and 0 or 1)

	self.showUnlockOrForbiddenTipId = data.id

	local tipText = ""

	if tip then
		tipText = tip
	elseif type == self.ButtonState.Lock then
		tipText = pg.getLocalizationText(FuncIdConfigData[data.functionName].unlockDesc)
	elseif type == self.ButtonState.Forbidden then
		tipText = pg.getGameString("FUNCTION_CANT_STATE")
	end

	ClientTextUtils.setText(self.view.unlockConditionUBaseText, tipText)

	if self.hiddenUnlockTipTimer then
		self:killTimer(self.hiddenUnlockTipTimer)

		self.hiddenUnlockTipTimer = nil
	end

	self.hiddenUnlockTipTimer = self:startTimer(function()
		self:hiddenUnlockOrForbiddenTip()
	end, 3)
end

function FuncMenuCtrl:hiddenUnlockOrForbiddenTip()
	self.view.rootUComponent:TryChangePage("Unlock", 0)

	self.showUnlockOrForbiddenTipId = nil
end

local function getHomeCampDispatchRewardRedDotStyle()
	local uid = pg.me and pg.me.uid
	local campCarEnt = uid and HomeLandUtils.getCampCarEntity(uid)
	local dispatchInfo = campCarEnt and campCarEnt:getPetsDispatchInfo()

	if dispatchInfo and campCarEnt:getCampPetDispatchState() == UIConst.HOME_CAMP_DISPATCH_STATE.Finished then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function FuncMenuCtrl:bind_RedDotForMenuItem(button, data, useHudStyle)
	button:ClearRedDot()

	if data.id == Const.FUNCTION_IDS.PLAYERENHANCEMENT then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_PLAYER, button, function()
			return pg.global.ui.playerEnhance.model:redDot_GetFuncMenuPlayerState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_PLAYER)
	elseif data.id == Const.FUNCTION_IDS.SPECIALTRAIN then
		local redDotPath = useHudStyle and RedDotConst.RedDotPath.SPECIAL_TRAIN_BTN or RedDotConst.RedDotPath.FUNC_MENU_SPECIAL_TRAIN

		pg.global.setPreViewRedDot(redDotPath, button, function()
			return pg.global.ui.SpecialTrainNew.model:redDot_GetSpecialTrainState()
		end)
		pg.global.bindCurvedUI(redDotPath)
	elseif data.id == Const.FUNCTION_IDS.SURVEY then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_SURVEY, button, function()
			return pg.global.ui.Survey.model:redDot_GetSurveyState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_SURVEY)
	elseif data.id == Const.FUNCTION_IDS.PETRESEARCH then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PET_RESEARCH, button, function()
			return pg.global.ui.petResearch.model:redDot_GetPetResearchState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.PET_RESEARCH)
	elseif data.id == Const.FUNCTION_IDS.MAIL then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAIL, button, function()
			return pg.game.chat:redDot_GetMailState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_MAIL)
	elseif data.id == Const.FUNCTION_IDS.MAP then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP, button, function()
			return pg.game.map:redDot_GetMapState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_MAP)
	elseif data.id == Const.FUNCTION_IDS.COURSE then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.QUEST_COURSE, button, function()
			return pg.global.ui.questCourseV2.model:redDot_GetState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.QUEST_COURSE)
	elseif data.id == Const.FUNCTION_IDS.FRIEND then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_FRIEND, button, function()
			return pg.game.chat:redDot_GetFriendState()
		end, function()
			return pg.game.chat:getFriendRequestCount()
		end)
	elseif data.id == Const.FUNCTION_IDS.ACTIVITYCENTER then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_EVENT, button, function()
			return ClientActivityUtils.getEventRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.ROGUE then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER, button, function()
			return RogueUtils.getRedDotState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.TOWER)
	elseif data.id == Const.FUNCTION_IDS.GRABEGGMODE then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE, button, function()
			return pg.global.ui.grabEggsMode.model:redDot_GetFuncMenuState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.GRAB_EGG_MODE)
	elseif data.id == Const.FUNCTION_IDS.SCHOOLGUIDE then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SCHOOL_GUIDE, button, function()
			return LuaUIUtils.getSchoolGuideRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.CASHSHOP then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_CASH_SHOP, button, function()
			return CashShopRedDotUtils.getCashShopEntryRedDotStyle()
		end)
	elseif data.id == Const.FUNCTION_IDS.HOMELAND then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR, button, function()
			return pg.global.ui.homeCarLevelUp.model:redDot_GetUpgradeState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_HOMECAR)
	elseif data.id == Const.FUNCTION_IDS.BATTLEPASS then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FUNC_MENU_BATTLEPASS, button, function()
			return CashShopRedDotUtils.getBattlePassHudRedDotStyle()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.FUNC_MENU_BATTLEPASS)
	elseif data.id == Const.FUNCTION_IDS.ANNOUNCEMENT then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.ANNOUNCEMENT, button, function()
			return pg.global.ui.announcement.model:redDot_GetAnnouncementState()
		end)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.ANNOUNCEMENT)
	elseif data.id == Const.FUNCTION_IDS.BOOSRUSH then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.BOSS_RUSH_MAIN, button, BossRushUtils.getBossRushMainRedDotStyle)
		pg.global.bindCurvedUI(RedDotConst.RedDotPath.BOSS_RUSH_MAIN)
	elseif data.id == Const.FUNCTION_IDS.HOME_BOOK then
		HomeBookRedDotUtils.bindHud(button)
	elseif data.functionType == "homelandSeason" then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOME_SEASON, button, function()
			return HomeSeasonUtils.getHomeSeasonRedDotStyle(pg.me)
		end)
	elseif data.functionType == "petTravel" then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD, button, function()
			return getHomeCampDispatchRewardRedDotStyle()
		end)
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_CAMP_DISPATCH_REWARD)
	elseif data.id == Const.FUNCTION_IDS.VIP then
		self.vipComponent:bindRedDot(button)
	end
end

function FuncMenuCtrl:renderFixedFuncListItem(button, index, data)
	self:addEle(button, data)

	if data.isEmpty then
		button:TryChangePage("State", self.ButtonState.Empty)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local rootUButton = objectReference:GetRefValue("rootUButton")
	local hasKey = data.actionPath

	rootUButton:TryChangePage("Key", hasKey and 1 or 0)
	keyHotKeyContent.gameObject:SetActiveEx(hasKey and not pg.global.ui:runPlatformByMobile())

	if hasKey and not pg.global.ui:runPlatformByMobile() then
		keyHotKeyContent:SetHotKeyPaths(hasKey)
	end

	button.gameObject.name = data.functionType

	local isFuncForbidden = data.id and LuaUIUtils.checkFuncIdForbidden(data.id)
	local isLock = not pg.me:checkFunctionUnlock(data.functionName)
	local state = self.ButtonState.UnLock
	local isReviewLock = not LuaUIUtils.checkFuncUnlockForREVIEW(data.functionName)

	if isReviewLock then
		state = self.ButtonState.Empty
		button.visualInteractable = false
	elseif isLock then
		state = self.ButtonState.Lock
	elseif isFuncForbidden then
		state = self.ButtonState.Forbidden
		button.visualInteractable = false
	end

	button:TryChangePage("State", state)

	if data.tIndex == 0 or data.tIndex == 2 then
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local name2UBaseText = objectReference:GetRefValue("name2UBaseText")
		local iconUpUContainer = objectReference:GetRefValue("iconUpUContainer")
		local nationLevelUButton = objectReference:GetRefValue("nationLevelUButton")

		iconUImage.url = data.img

		ClientTextUtils.setArkFontEnable(nameUBaseText, isLock, data.name, data.label)
		ClientTextUtils.setArkFontEnable(name2UBaseText, isLock, data.name, data.label)

		if data.id == Const.FUNCTION_IDS.PLAYERENHANCEMENT then
			button:TryChangePage("Type", 1)

			local numLv = objectReference:GetRefValue("numLv")
			local expProgress = objectReference:GetRefValue("expProgress")
			local starUImage = objectReference:GetRefValue("starUImage")
			local starLevelUSDFText = objectReference:GetRefValue("starLevelUSDFText")

			LuaUIUtils.setUIViewVisible(nationLevelUButton, true)

			starUImage.url = LuaUIUtils.getStarIcon(pg.me.starTitle)

			ClientTextUtils.setText(starLevelUSDFText, LuaUIUtils.getStarTitleNameForIcon(pg.me.starTitle))

			function nationLevelUButton.luaClick()
				pg.global.ui.tips:openStarImprove()
			end

			local needUpTitle = LuaUIUtils.checkNeedUpTitle()
			local pData = LuaUIUtils.getPlayerInfo()
			local textLv = needUpTitle and string.format("<color=#f67574>Lv.%d</color>", pData.curLev) or string.format("Lv.%d", pData.curLev)

			if needUpTitle then
				pg.me:tryRefreshAiIds(true, 104, true, {
					offsetX = -500
				})
			end

			ClientTextUtils.setText(numLv, textLv)

			expProgress.value = pData.curExp / pData.maxExp
		else
			button:TryChangePage("Type", 0)
			LuaUIUtils.setUIViewVisible(nationLevelUButton, false)
		end

		local isUpOpen = false

		if data.id == Const.FUNCTION_IDS.ROGUE then
			isUpOpen = ClientActivityUtils.isRogueRewardUpWithRemainTimes()
		elseif data.id == Const.FUNCTION_IDS.GRABEGGMODE then
			isUpOpen = GrabEggsRankUtils.isRankScoreDoubleAvailable()
		end

		isUpOpen = isUpOpen and state == self.ButtonState.UnLock

		if iconUpUContainer then
			self._iconUpRenderVersions = self._iconUpRenderVersions or {}

			local renderVersion = (self._iconUpRenderVersions[iconUpUContainer] or 0) + 1

			self._iconUpRenderVersions[iconUpUContainer] = renderVersion

			iconUpUContainer:SetActive(isUpOpen)

			if isUpOpen then
				local function renderIconUpText()
					if IsNil(iconUpUContainer) or not self._iconUpRenderVersions or self._iconUpRenderVersions[iconUpUContainer] ~= renderVersion then
						return
					end

					local iconUpContent = iconUpUContainer.content

					if IsNil(iconUpContent) then
						return
					end

					local iconUpObjectReference = iconUpContent:GetComponent("ObjectReference")
					local txtNameUSDFText = NotNil(iconUpObjectReference) and iconUpObjectReference:GetRefValue("txtNameUSDFText") or nil

					if NotNil(txtNameUSDFText) then
						if data.id == Const.FUNCTION_IDS.GRABEGGMODE then
							ClientTextUtils.setTextWithId(txtNameUSDFText, GameStringConfig.GRAB_EGG_RANK_SCORE_DOUBLE_TAG.desc)
						else
							txtNameUSDFText:RefreshLocalization()
						end
					end
				end

				if iconUpUContainer:CheckURLLoaded() then
					renderIconUpText()
				else
					iconUpUContainer:LoadDefaultUrlManually(renderIconUpText)
				end
			end
		end
	elseif data.tIndex == 3 then
		local levelText = objectReference:GetRefValue("levelText")
		local countryProgress = objectReference:GetRefValue("countryProgress")
		local bgUImage = objectReference:GetRefValue("bgUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local name2UBaseText = objectReference:GetRefValue("name2UBaseText")
		local barUWidget = objectReference:GetRefValue("barUWidget")

		ClientTextUtils.setArkFontEnable(nameUBaseText, isLock, data.name, data.label)
		ClientTextUtils.setArkFontEnable(name2UBaseText, isLock, data.name, data.label)

		local areaId = PetResearchUtils.getLastPetResearchAreaId()

		bgUImage.url = LuaUIUtils.getCountryIconByType(areaId, LuaUIUtils.PET_ICON)

		if PetResearchUtils.checkAreaIsCollection(areaId) then
			barUWidget:SetActiveFastest(false)
		else
			barUWidget:SetActiveFastest(true)

			local curLevel, remain, needExp = PetResearchUtils.getCountryLevelInfo(areaId)

			if levelText then
				levelText.text = curLevel
			end

			if countryProgress then
				countryProgress.maxValue = needExp
				countryProgress.value = remain
			end
		end
	elseif data.tIndex == 1 then
		self.iconUImage = objectReference:GetRefValue("iconUImage")

		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")

		ClientTextUtils.setArkFontEnable(nameUBaseText, isLock, data.name, data.label)

		if not isLock then
			self:refreshWeatherIcon()
		end

		self.iconUImage.gameObject:SetActiveEx(not isLock)
	end
end

function FuncMenuCtrl:refreshWeatherIcon()
	if self.iconUImage then
		local curWeatherId = pg.me:getWeather()

		if curWeatherId == 0 then
			curWeatherId = 1
		end

		local iconURL = WeatherData[curWeatherId].icon
		local blockAreaId = pg.game.map:getCurBlockAreaId()
		local meteorologyId = pg.me:getAreaMeteorology(blockAreaId)

		if meteorologyId ~= 0 then
			iconURL = MeteorologyData[meteorologyId].icon
		end

		self.iconUImage.url = iconURL
	end
end

function FuncMenuCtrl:onWeatherRefresh(data)
	local curBlockAreaId = pg.game.map:getCurBlockAreaId()

	if curBlockAreaId == data.blockAreaId then
		self:refreshWeatherIcon()
	end
end

function FuncMenuCtrl:addEle(button, data)
	local curRow = self.funcListEle[#self.funcListEle]

	if curRow == nil or curRow.size >= self.rowSize then
		table.insert(self.funcListEle, {
			size = 0,
			items = {}
		})

		curRow = self.funcListEle[#self.funcListEle]
	end

	table.insert(curRow.items, {
		button = button,
		data = data
	})

	curRow.size = curRow.size + math.max(data.size, 1)
end

function FuncMenuCtrl:getFixedFuncListData()
	local funcListData = self.model:getFixedFuncList()
	local funcSize = 0

	for _, item in ipairs(funcListData) do
		item.label = pg.getLocalizationText(item.name)
		item.tIndex = item.prefab - 1
		funcSize = funcSize + item.size
	end

	if funcSize % self.rowSize ~= 0 then
		for i = funcSize % self.rowSize + 1, self.rowSize do
			table.insert(funcListData, {
				size = 0,
				tIndex = 0,
				id = -1,
				isEmpty = true
			})

			funcSize = funcSize + 1
		end
	end

	for i = funcSize + 1, self.screenSize do
		table.insert(funcListData, {
			size = 0,
			tIndex = 0,
			id = -1,
			isEmpty = true
		})
	end

	return funcListData
end

function FuncMenuCtrl:initBottomFuncList()
	function self.view.bottomBtnUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local vxIcon = objectReference:GetRefValue("vxIcon")
		local selectedIcon = objectReference:GetRefValue("selectedIcon")
		local progress = objectReference:GetRefValue("progress")

		icon.url = data.icon
		vxIcon.url = data.icon
		selectedIcon.url = data.icon
		button.gameObject.name = data["function"]

		local isFuncForbidden = data.id and LuaUIUtils.checkFuncIdForbidden(data.id)

		table.insert(self.bottonFuncListEle, button)

		function button.luaClick()
			if data.id then
				local isForbidden, tip = LuaUIUtils.checkFuncIdForbidden(data.id)

				if isForbidden then
					self:handleTips(data, self.ButtonState.Forbidden, tip)

					return
				end
			end

			if data["function"] then
				self[data["function"]](self, data)

				self.lastRecordFuncType = "main"
				self.lastRecordFunc = data["function"]
			end

			if data["function"] == "VIP" then
				pg.global.prefsCacheUtils:setBool(ClientConst.PrefKey.FuncMenuVipEnterClicked, true, ClientConst.CACHE_TYPE_FLAG.USER)
			end
		end

		if pg.game.guide:isInGuide() or isFuncForbidden then
			button.visualInteractable = false
		end

		button:TryChangePage("isForbidden", isFuncForbidden and 1 or 0)

		local isLock = not pg.me:checkFunctionUnlock(data.functionName)
		local state = self.ButtonState.UnLock

		if isLock then
			state = self.ButtonState.Lock
		elseif isFuncForbidden then
			state = self.ButtonState.Forbidden
		end

		button:TryChangePage("State", state)

		if data.id == 12 then
			progress:SetActive(true)

			local vitalityData = LuaUIUtils.getVitalityData()

			progress.value = vitalityData.percent

			if vitalityData.isFull then
				progress:TryChangePage("Status", 1)
			else
				progress:TryChangePage("Status", 0)
			end
		else
			progress:SetActive(false)
		end

		self:bind_RedDotForMenuItem(button, data)

		function button.luaHover()
			if self.view == nil then
				return
			end

			self.view.rootUComponent:TryChangePage("HoverKey", 1)
		end

		function button.luaUnhover()
			if self.view == nil then
				return
			end

			self.view.rootUComponent:TryChangePage("HoverKey", 0)
		end

		function button.luaRenderTooltip(button, panel)
			local objectReference = panel:GetComponent("ObjectReference")
			local textBtnName = objectReference:GetRefValue("textBtnName")
			local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
			local rootUComponent = objectReference:GetRefValue("rootUComponent")
			local hasKey

			if data["function"] then
				hasKey = LuaUIUtils.getFuncActionPath(data.id)
			end

			rootUComponent:TryChangePage("Key", hasKey and not pg.global.ui:runPlatformByMobile() and 1 or 0)

			if hasKey and not pg.global.ui:runPlatformByMobile() then
				keyHotKeyContent:SetHotKeyPaths(hasKey)
			end

			ClientTextUtils.setText(textBtnName, pg.getLocalizationText(data.name))
		end
	end

	local bottomFuncData = self:getBottomFuncListData()

	function self.view.bottomBtnUList.luaFinishRender(list)
		return
	end

	self.view.bottomBtnUList:SetList(bottomFuncData)
end

function FuncMenuCtrl:getBottomFuncListData()
	local data = self.model:getBottomFuncListData()

	for _, item in ipairs(data) do
		item.label = pg.getLocalizationText(item.name)
	end

	return data
end

function FuncMenuCtrl:closePanel()
	if self.isCloseing or not self.view or self.isFuncUnlocking then
		return
	end

	self.isCloseing = true

	self:clearAniTimer()

	if self.startAniTimer then
		TimerManager.removeTimer(self.startAniTimer)

		self.startAniTimer = nil
	end

	self.view.uIPbFunMenuAnimation:Play(self.closeAni)

	local delay = self.view.uIPbFunMenuAnimation:GetClip(self.closeAni).length

	TimerManager.addTimer(delay, function()
		self.isCloseing = false

		pg.global.ui.hudV2:removeCurUnlockFunc()
		self:close()
	end)
end

function FuncMenuCtrl:takePhoto()
	pg.global.ui.hudV2:openPhotoPanel()
end

function FuncMenuCtrl:bossRush()
	pg.global.ui:open(UIConst.UI_ID_BOSS_RUSH_MAIN)
end

function FuncMenuCtrl:help()
	pg.global.ui:open(UIConst.UI_ID_HELP)
end

function FuncMenuCtrl:VIP()
	self.vipComponent:open()
end

function FuncMenuCtrl:gameplayRule()
	local space = pg.me and pg.me.space
	local spaceType = space and space.spaceType

	if not spaceType then
		return
	end

	if Utils.isSpaceFishingCaptureDungeon(spaceType) then
		local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.FishingCapture, pg.me)

		if not isOpen or not activityId then
			return
		end

		local ruleDesc = ClientActivityUtils.getEventRule(activityId)

		space:pauseGameByType(Const.GameTimeScaleType.FISHING_RULE_DESC, -1)
		pg.global.ui.tips:openEventRuleDesc(ruleDesc, nil, function()
			if pg.me and pg.me.space and pg.me.space.resumeGameByType then
				pg.me.space:resumeGameByType(Const.GameTimeScaleType.FISHING_RULE_DESC)
			end
		end)
	end
end

function FuncMenuCtrl:config()
	pg.global.ui:open(UIConst.UI_ID_SETTING)
end

function FuncMenuCtrl:service()
	pg.global.ui.hudV2:openServicePanel()
end

function FuncMenuCtrl:announcement()
	pg.global.ui.announcement.model:getAnnouncementData(true)
end

function FuncMenuCtrl:escape()
	self:closePanel()
	ClientUtils.escape()
end

function FuncMenuCtrl:quit()
	local isConsole = pg.global.platform and pg.global.platform.isConsole and pg.global.platform:isConsole()

	if isConsole or ClientConfigCloudEnable == "true" then
		self:quitForConsole()
	else
		self:quitNormal()
	end
end

function FuncMenuCtrl:quitForConsole()
	local function okCb()
		self:closePanel()
		ClientRepo.loginAgent:logout()
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIT_GAME_WARNING"), okCb, nil, nil, nil, nil, {
		pauseGame = true,
		escSpecial = true,
		okBtnDesc = pg.getGameString("EXIT_GAME_BACK_TO_LOGIN"),
		cancelBtnDesc = pg.getGameString("EXIT_GAME_CANCEL"),
		okBtnType = UIConst.MENU_EXIT_BTN_TYPE.ReturnLogin,
		cancelType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
		okBtnKey = Const.ExitButtonType.TEMPORARY_EXIT,
		cancelBtnKey = Const.ExitButtonType.CONTINUE
	})
end

function FuncMenuCtrl:quitNormal()
	local function okCb()
		ClientRepo.loginAgent:logoutService()
		appFacade.QuitGame()
	end

	local function cancelCb()
		self:closePanel()
		ClientRepo.loginAgent:logout()
	end

	local quitQrCodeUrl, quitQrCodeTip = pg.global.ui.login.model:getQuitQrCodeUrlAndTip()

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIT_GAME_WARNING"), okCb, nil, cancelCb, true, nil, {
		pauseGame = true,
		escSpecial = true,
		okBtnDesc = pg.getGameString("EXIT_GAME_IMMEDIATELY"),
		cancelBtnDesc = pg.getGameString("EXIT_GAME_BACK_TO_LOGIN"),
		nextBtnDesc = pg.getGameString("EXIT_GAME_CANCEL"),
		okBtnType = UIConst.MENU_EXIT_BTN_TYPE.ExitGame,
		cancelType = UIConst.MENU_EXIT_BTN_TYPE.ReturnLogin,
		nextBtnType = UIConst.MENU_EXIT_BTN_TYPE.Confirm,
		okBtnKey = Const.ExitButtonType.END_AND_EXIT,
		cancelBtnKey = Const.ExitButtonType.TEMPORARY_EXIT,
		nextBtnKey = Const.ExitButtonType.CONTINUE,
		qrCodeUrl = quitQrCodeUrl,
		qrCodeTip = quitQrCodeTip
	})
end

function FuncMenuCtrl:petResearch()
	pg.global.ui.hudV2:openPetResearch()
end

function FuncMenuCtrl:playerEnhancement()
	pg.global.ui.hudV2:openPlayerEnhance()
end

function FuncMenuCtrl:petEntry()
	pg.global.ui.hudV2:openPetPanel()
end

function FuncMenuCtrl:quest()
	pg.global.ui.hudV2:openQuest()
end

function FuncMenuCtrl:petBall()
	self:closePanel()
	pg.global.ui.hudV2:openPetBall()
end

function FuncMenuCtrl:pvp()
	pg.global.ui.hudV2:openPvpMenu()
end

function FuncMenuCtrl:map()
	pg.global.ui.hudV2:openMap()
end

function FuncMenuCtrl:mail()
	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		initTab = pg.game.chat.tabType.Mail
	}, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function FuncMenuCtrl:friend()
	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		initTab = pg.game.chat.tabType.Friend
	}, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function FuncMenuCtrl:chat()
	pg.global.ui:open(UIConst.UI_ID_CHAT, nil, nil, nil, {
		ignoreDisableMainCamera = true
	})
end

function FuncMenuCtrl:shop(data)
	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				36
			}
		})
	elseif pg.me and pg.me:isInFishingCapture() then
		local config = ActivityUtils.getFishingCaptureConfig(nil, pg.me)
		local shopId = config and config.shopIdInside

		if shopId then
			pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
				shopTags = {
					shopId
				}
			})
		end
	else
		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, data.functionParam)
	end
end

function FuncMenuCtrl:cashShop()
	pg.global.ui.hudV2:openCashShop()
end

function FuncMenuCtrl:paytestonly()
	pg.game.monthCard:tryShowPreorderGuide()
end

function FuncMenuCtrl:_openBattlePassMain()
	pg.global.ui:open(UIConst.UI_ID_BP_PERMIT)
end

local function _getBattlePassPopupRecord(prefsKey)
	local recordPhase = 0
	local shownLevels = {}
	local isLegacyRecord = false
	local prefsValue = pg.global.prefsCacheUtils:getString(prefsKey, "")

	if not string.isNilOrEmpty(prefsValue) then
		local phaseStr, levelsStr = string.match(prefsValue, "^(%d+):?(.*)$")

		if phaseStr then
			recordPhase = tonumber(phaseStr) or 0

			if string.isNilOrEmpty(levelsStr) then
				isLegacyRecord = true
			else
				for _, levelStr in ipairs(string.split(levelsStr, ",")) do
					local level = tonumber(levelStr)

					if level then
						shownLevels[level] = true
					end
				end
			end
		end
	end

	recordPhase = tonumber(recordPhase) or 0

	if recordPhase == 0 then
		recordPhase = tonumber(pg.global.prefsCacheUtils:getInt(prefsKey, 0)) or 0
		isLegacyRecord = recordPhase > 0
	end

	return recordPhase, shownLevels, isLegacyRecord
end

local function _saveBattlePassPopupRecord(prefsKey, phase, shownLevels)
	local levelList = {}

	for level in pairs(shownLevels) do
		table.insert(levelList, level)
	end

	table.sort(levelList)
	pg.global.prefsCacheUtils:setString(prefsKey, string.format("%d:%s", phase, table.concat(levelList, ",")))
end

local function _isBattlePassPopupRegionAllowed(regionLimitId)
	if regionLimitId == nil then
		return true
	end

	local serverArea = tonumber(Utils.getServerArea())

	if serverArea == nil then
		return false
	end

	if Utils.isTable(regionLimitId) then
		for _, areaId in ipairs(regionLimitId) do
			if tonumber(areaId) == serverArea then
				return true
			end
		end

		return false
	end

	return tonumber(regionLimitId) == serverArea
end

function FuncMenuCtrl:_isBattlePassCoreRewardActive(bpData, bpGear, popupLimitLevels)
	if not bpData or bpGear >= ActivityConst.BattlePassGear.Pay1 or not popupLimitLevels or #popupLimitLevels == 0 then
		return false
	end

	if not _isBattlePassPopupRegionAllowed(bpData.regionLimitId) then
		return false
	end

	local popupStartTime = tonumber(Utils.getConfigTimeOfArea(bpData, "popupStartDayTime"))
	local popupEndTime = tonumber(Utils.getConfigTimeOfArea(bpData, "popupEndDayTime"))

	return popupStartTime ~= nil and popupEndTime ~= nil and popupStartTime <= Time.secondCache and popupEndTime > Time.secondCache
end

function FuncMenuCtrl:battlepass()
	if not ClientCashShopUtils.canOpenBattlePass() then
		return
	end

	if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase

	if not phase then
		return
	end

	local bpData = BattlePassData[phase]
	local bpGear = actData.bpGear or ActivityConst.BattlePassGear.Free
	local popupLimitLevels = bpData and bpData.popupLimitLevels

	if not self:_isBattlePassCoreRewardActive(bpData, bpGear, popupLimitLevels) then
		self:_openBattlePassMain()

		return
	end

	local prefsKey = ClientConst.PrefKey.BPCorePop
	local recordPhase, shownLevels, isLegacyRecord = _getBattlePassPopupRecord(prefsKey)

	if isLegacyRecord and recordPhase == phase then
		for _, popupLevel in ipairs(popupLimitLevels) do
			shownLevels[popupLevel] = true
		end

		_saveBattlePassPopupRecord(prefsKey, phase, shownLevels)
	end

	local bpLevel = actData.bpLevel or 0
	local sameSeason = recordPhase == phase
	local targetLevel

	for _, popupLevel in ipairs(popupLimitLevels) do
		local hasShown = sameSeason and shownLevels[popupLevel]

		if popupLevel <= bpLevel and not hasShown and (not targetLevel or targetLevel < popupLevel) then
			targetLevel = popupLevel
		end
	end

	if targetLevel then
		if not sameSeason then
			shownLevels = {}
		end

		for _, popupLevel in ipairs(popupLimitLevels) do
			if popupLevel <= bpLevel then
				shownLevels[popupLevel] = true
			end
		end

		_saveBattlePassPopupRecord(prefsKey, phase, shownLevels)
		pg.global.ui:open(UIConst.UI_ID_BP_CORE_REWARD)

		return
	end

	self:_openBattlePassMain()
end

function FuncMenuCtrl:album()
	pg.global.ui.album:open()
end

function FuncMenuCtrl:markShare()
	if not CommonSwitch.MARK_SHARE then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_MARK_SHARE_EDIT)
end

function FuncMenuCtrl:vitality()
	pg.global.ui:open(UIConst.UI_ID_VITALITY_V0)
end

function FuncMenuCtrl:element()
	pg.global.ui.tips:showRestraint()
end

function FuncMenuCtrl:bag()
	if pg.me and pg.me.space and pg.me.space:isGrabEgg() then
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
			items = pg.me:getNearbyCollectionList(),
			bagType = UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM,
			name = pg.getGameString("GRAB_EGG_NEARBY_ITEM")
		})
	else
		pg.global.ui:open(UIConst.UI_ID_INVENTORY)
	end
end

function FuncMenuCtrl:homeland()
	if pg.me.isHomeCampUnlocked then
		pg.global.ui:open(UIConst.UI_ID_HOMELAND_MAIN_PAGE)
	else
		pg.global.showConfirmMsgRaw(pg.getGameString("GO_HOMELAND"), pg.getGameString("CREATE_HOMELAND_DESC"), function()
			if HomelandConfigData.createHomelandPortId then
				pg.me:CallServerMsgTeleportToScene(Const.SCENE_ID.COT, HomelandConfigData.createHomelandPortId, false)
			end
		end)
	end
end

function FuncMenuCtrl:isHomeSeasonAvailable()
	return HomeSeasonUtils.isSeasonAvailable(pg.me)
end

function FuncMenuCtrl:getTraceableHomeSeasonQuestId(questId, visitedQuestIds)
	return HomeSeasonUtils.getTraceableHomeSeasonQuestId(pg.me, questId, visitedQuestIds)
end

function FuncMenuCtrl:acceptAndTraceHomeSeasonStageQuest(questId)
	return HomeSeasonUtils.acceptAndTraceHomeSeasonQuest(pg.me, questId)
end

function FuncMenuCtrl:homelandSeason()
	local player = pg.me
	local seasonId = player and (player.homeSeasonId or 0) or 0

	if not HomeSeasonUtils.isSeasonOpen(seasonId) then
		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_EVENT_NOT_OPEN)

		return
	end

	if player:getHomeCarLevel() < 10 then
		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_CAR_LEVEL_NOT_VALID)

		return
	end

	local questId = HomeSeasonUtils.getUnfinishedPreQuestId(player)

	questId = questId or HomeSeasonUtils.getFirstUnfinishedStageQuestId(player)

	if questId then
		if not self:acceptAndTraceHomeSeasonStageQuest(questId) and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("home season quest chain has no traceable quest, questId=%s", questId)
		end

		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_NOT_FINISH_QUEST)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_MAIN_PAGE)
end

function FuncMenuCtrl:homelandReport()
	HomelandReportUtils.open()
end

function FuncMenuCtrl:homeCampReport()
	HomelandReportUtils.openHomeCampReport()
end

function FuncMenuCtrl:homelandLog()
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_PET_ACTION, {
		type = 1
	})
	GlobalData.BILogger:customeLog("home_main_menu", {
		to_page = "home_log"
	})
end

function FuncMenuCtrl:furnitureDesign()
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_DESIGN)
end

function FuncMenuCtrl:homePlant()
	pg.global.ui:open(UIConst.UI_ID_HOME_BOOK)
	GlobalData.BILogger:customeLog("home_main_menu", {
		to_page = "index"
	})
end

function FuncMenuCtrl:stationManage()
	pg.global.ui.homeStationManage:open()
end

function FuncMenuCtrl:petTravel()
	if not CommonSwitch.CAMP_MANAGER then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_CAMP_MANAGER)
end

function FuncMenuCtrl:onEnterHomeland(res)
	if res then
		pg.global.ui:closeAllNormalPanel()
	end
end

function FuncMenuCtrl:appearance()
	LuaUIUtils.openPlayerAppearancePanel()
end

function FuncMenuCtrl:specialTrain()
	pg.global.ui.hudV2:openSpecialTrain()
end

function FuncMenuCtrl:activitycenter()
	pg.global.ui:open(UIConst.UI_ID_EVENT)
end

function FuncMenuCtrl:survey()
	pg.global.ui.hudV2:openSurvey()
end

function FuncMenuCtrl:grabeggs()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_MODE)
end

function FuncMenuCtrl:teleport(data)
	self:closePanel()

	if pg.me.curGuideCourseId ~= 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("ALREADY_IN_COURSE"))

		return
	end

	ClientUtils.playTeleportDissolveEffectAndTeleport(data.functionParam[1])
end

function FuncMenuCtrl:worldTeam()
	if pg.me:isInTeamDungeonScene() then
		local teamInfo = pg.me:getShowTeamInfo()
		local gameName = teamInfo and pg.me:getDungeonName(teamInfo.dungeonSceneId)

		if gameName then
			pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("FORBIDDEN_TEAM_OPERATE"), gameName))

			return
		end
	end

	pg.me:tryEnterPrepRoom(true)
end

function FuncMenuCtrl:dayNightChange()
	local space = pg.me and pg.me.space
	local isSpacePhase = space and SceneData[space.sceneId].mainScene == 3000
	local forceDayNight = SceneData[space.sceneId].forceDayNight

	if space and (pg.me:isSpaceOwner() or isSpacePhase and not forceDayNight) then
		pg.global.ui:open(UIConst.UI_ID_TIME_SWITCH)
	else
		ClientUtils.showBubbleMessage(NoticeDef.CANNOT_CHANGE_LOGIC_TIME)
	end
end

function FuncMenuCtrl:event(data)
	local event = SysEventData[data.functionParam[1]]

	if event.eventType ~= "openUI" then
		self:closePanel()
	end

	if event.eventType == "challengeDungeon" then
		local isInTeamRoom = pg.me.teamInfo.prepareInfos and lume.getMapLen(pg.me.teamInfo.prepareInfos) > 0

		if isInTeamRoom then
			pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_GAME_INSTANCE, {
			dungeonId = event.eventParam[1]
		})
	else
		pg.me:doEventByData({
			event.eventType,
			event.eventParam
		})
	end
end

function FuncMenuCtrl:tower()
	if pg.me:isInTeam(true) then
		pg.global.ui.tips:showTextTip(pg.getGameString("TOWER_FORBIDDEN_TEAM"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_ROG_LEVEL_SELECT)
end

function FuncMenuCtrl:towerTeam()
	pg.global.ui:open(UIConst.UI_ID_TOWER_STAGE_INFO)
end

function FuncMenuCtrl:towerBuff()
	pg.global.ui:open(UIConst.UI_ID_TOWER_BUFF_DETAIL)
end

function FuncMenuCtrl:schoolGuide()
	pg.global.ui:open(UIConst.UI_ID_EVENT_SCHOOL_GUIDE)
end

function FuncMenuCtrl:photoInvite()
	if Utils.isScenePhoto() then
		pg.global.ui:open(UIConst.UI_ID_INVITE_FRIEND)
	end
end

function FuncMenuCtrl:setButtonsInteractable(interactable)
	self.isButtonInteractable = interactable

	for _, row in ipairs(self.funcListEle) do
		for _, item in ipairs(row.items) do
			item.button.interactable = interactable

			if item.data.isEmpty then
				item.button.interactable = false
			end
		end
	end

	for _, button in ipairs(self.bottonFuncListEle) do
		button.interactable = interactable
	end
end

function FuncMenuCtrl:playOpenAni()
	local delayTime = 0

	for _, row in ipairs(self.funcListEle) do
		for _, item in ipairs(row.items) do
			item.button:GetComponent("ObjectReference"):GetRefValue("rootAnimation"):GetComponent("UWidget").renderOpacity = 0

			local curDelay = delayTime

			item.timer = TimerManager.addTimer(curDelay, function()
				item.timer = nil

				local ani = self.size2Ani[item.data.size].open
				local objectReference = item.button:GetComponent("ObjectReference")
				local rootAnimation = objectReference:GetRefValue("rootAnimation")

				rootAnimation:Play(ani)
			end)

			if item.data.id and item.data.id == self.unlockFuncId then
				self.unlockButton = item.button

				self.unlockButton:TryChangePage("State", self.ButtonState.Lock)
			end
		end

		delayTime = delayTime + self.itemLineDelay
	end

	delayTime = delayTime + 0.2

	if self.unlockButton then
		self.view.listBtnUList:GoToItem(self.unlockButton, true)

		self.unlockFuncTimer = TimerManager.addTimer(delayTime, function()
			self.unlockFuncTimer = nil

			self.unlockButton:TryChangePage("State", self.ButtonState.UnLocking)
			pg.game.audio:playEvent(AudioConst.EVENT_FUNC_MENU_FUNC_UNLOCK)
		end)
		delayTime = delayTime + 1
		self.unlockGuideTimer = TimerManager.addTimer(delayTime, function()
			self.unlockGuideTimer = nil

			if self.guideGroupId then
				pg.me:serverMsg("RPC_CS_StartGuidanceRecord", self.guideGroupId)
			elseif self.dialogueGraphId then
				pg.game.dialogue:playDialogueGraph(self.dialogueGraphId)
			end
		end)
		delayTime = delayTime + 0.5
		self.enableInteractableTimer = TimerManager.addTimer(delayTime, function()
			self.enableInteractableTimer = nil

			self:setButtonsInteractable(true)

			self.isFuncUnlocking = false
		end)
	else
		self.enableInteractableTimer = TimerManager.addTimer(delayTime, function()
			self.enableInteractableTimer = nil

			self:setButtonsInteractable(true)

			self.isFuncUnlocking = false

			for _, row in ipairs(self.funcListEle) do
				for _, item in ipairs(row.items) do
					CS.XGUI.Navigation.NavManager.Instance:FocusItem(item.button)

					break
				end

				break
			end
		end)
	end
end

function FuncMenuCtrl:playCloseAni()
	local delayTime = 0

	for _, row in ipairs(self.funcListEle) do
		for _, item in ipairs(row.items) do
			local curDelay = delayTime

			item.timer = TimerManager.addTimer(curDelay, function()
				item.timer = nil

				local ani = self.size2Ani[item.data.size].close
				local objectReference = item.button:GetComponent("ObjectReference")
				local rootAnimation = objectReference:GetRefValue("rootAnimation")

				rootAnimation:Play(ani)
			end)
		end
	end
end

function FuncMenuCtrl:clearAniTimer()
	for _, row in ipairs(self.funcListEle) do
		for _, item in ipairs(row.items) do
			if item.timer then
				TimerManager.removeTimer(item.timer)

				item.timer = nil
			end
		end
	end

	if self.enableInteractableTimer then
		TimerManager.removeTimer(self.enableInteractableTimer)

		self.enableInteractableTimer = nil
	end
end

function FuncMenuCtrl:initHotKeys()
	self:bindHotKey(Const.FUNCTION_IDS.PETENTRY, "PETENTRY", nil, function()
		pg.global.ui.hudV2:openPetPanel()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.BAG, "BAG", nil, function()
		pg.global.ui.inventory:open()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.PETRESEARCH, "PETRESEARCH", nil, function()
		pg.global.ui.hudV2:openPetResearch()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.QUEST, "QUEST", nil, function()
		pg.global.ui.hudV2:openQuest()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.TAKEPHOTO, "TAKEPHOTO", nil, function()
		pg.global.ui.hudV2:openPhotoPanel()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.MAP, "MAP", nil, function()
		pg.global.ui.hudV2:openMap()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.HELP, "HELP", nil, function()
		pg.global.ui:open(UIConst.UI_ID_HELP)
	end)
	self:bindHotKey(Const.FUNCTION_IDS.PVP, "PVP", nil, function()
		pg.global.ui.hudV2:openPvpMenu()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.CASHSHOP, "ShopMall_All", nil, function()
		self:cashShop()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.PLAYERENHANCEMENT, "PLAYERENHANCEMENT", nil, function()
		pg.global.ui.hudV2:openPlayerEnhance()
	end)
	self:bindHotKey(Const.FUNCTION_IDS.CHAT, "CHAT", nil, function()
		if not pg.game.input:isUsingGamepad() then
			pg.global.ui.hudV2:openChat()
		end
	end)
	self:bindHotKey(Const.FUNCTION_IDS.SPECIALTRAIN, "SPECIALTRAIN", nil, function()
		pg.global.ui.hudV2:openSpecialTrain()
	end)
end

function FuncMenuCtrl:bindHotKey(funcId, funcName, actionPath, func)
	actionPath = actionPath or LuaUIUtils.getFuncActionPath(funcId)

	if not actionPath then
		return
	end

	local openSetupBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, actionPath)

	openSetupBind.actionPath = actionPath
	openSetupBind.isVirtual = true

	function openSetupBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and pg.me:checkFunctionUnlock(funcName) and CommonSwitch[funcName] then
			if LuaUIUtils.checkFuncIdForbidden(funcId) then
				pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

				return
			end

			if not self.isButtonInteractable then
				return
			end

			func()
		end
	end
end

function FuncMenuCtrl:initChoiceArea(data)
	local t = {}
	local count = 1
	local size = 0
	local lastX = 0
	local yStart = 0

	for i = 1, #data do
		local x = math.floor(size / self.rowSize) + 1

		if lastX ~= x then
			lastX = x
			yStart = count
		end

		local y = count - yStart + 1

		if self.initSelectedFuncId and data[i].id == self.initSelectedFuncId then
			self.initSelectedNavX = x
			self.initSelectedNavY = y
		end

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			return
		end
		t[x][y].Fun3 = function(x1, y1)
			return
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun4 = function(x1, y1)
			local _, button = self.view.listBtnUList:TryGetChildAt(i - 1)

			if button and button.luaClick then
				button.luaClick()
			end
		end
		t[x][y].Fun16 = function(x1, y1)
			self:closePanel()
		end
		count = count + 1
		size = size + data[i].size
	end
end

function FuncMenuCtrl:initFunctionArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 1) + 1
		local y = (i - 1) % 1 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList, nil, true)
			self.gamePadComponent:deSelectAll()

			local _, button = self.view.bottomBtnUList:TryGetChildAt(i - 1)

			button:DoHover()
		end
		t[x][y].Fun3 = function(x1, y1)
			return
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun4 = function(x1, y1)
			local _, button = self.view.bottomBtnUList:TryGetChildAt(i - 1)

			if button and button.luaClick ~= nil then
				button.luaClick()
			end
		end
		t[x][y].Fun16 = function(x1, y1)
			self:closePanel()
		end
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.FUNCTION_AREA, t)
end

function FuncMenuCtrl:initBottomButtonList()
	local Data = {
		{
			path = "Raw/GamepadLeftStickMove",
			label = pg.getGameString("CONSOLE_BAR_LIST")
		},
		{
			path = "Raw/GamepadButtonSouth",
			label = pg.getGameString("CONSOLE_BAR_SELECT")
		},
		{
			path = "Raw/GamepadButtonEast",
			label = pg.getGameString("CONSOLE_BAR_LEAVE")
		},
		{
			path = "Raw/GamepadButtonWest",
			longPress = true,
			label = pg.getGameString("CONSOLE_BAR_EXIT") or pg.getGameString("EXIT") or "退出",
			onLongPress = function(ctrl)
				if ctrl and ctrl.view and ctrl.view.btnExitUButton then
					ctrl.view.btnExitUButton:OnClickSimulate()
				end
			end
		}
	}

	if ClientConfigCloudEnable == "true" then
		table.remove(Data)
	end

	self.view.keyListConsoleUList:SetList(Data)
end

function FuncMenuCtrl:onRenderBottomButtonItem(button, index, data)
	local objectReference = button.transform:GetComponent("ObjectReference")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local btnTipsUText = objectReference:GetRefValue("btnTipsUText")
	local progressPressContainer = objectReference:GetRefValue("progressPressContainerUContainer")

	keyHotKeyContent:SetHotKeyPaths(data.path)
	ClientTextUtils.setText(btnTipsUText, data.label)

	self.bottomButtonkeyHotKeyContent = keyHotKeyContent
	self.bottomButtonbtnTipsUText = btnTipsUText

	if not progressPressContainer then
		return
	end

	if data.longPress then
		progressPressContainer:SetActive(true)
		progressPressContainer:LoadDefaultUrlManually(function()
			local progress = progressPressContainer.content

			if not progress then
				return
			end

			progress:ProgressToValue(0, nil, 0)

			self.bottomLongPressProgress = self.bottomLongPressProgress or {}
			self.bottomLongPressProgress[data.path] = progress

			FuncMenuCtrl.super.bindHotKeyWithProgress(self, data.path, function()
				if type(data.onLongPress) == "function" then
					data.onLongPress(self)
				end

				progress:ProgressToValue(0, nil, 0)
			end, nil, progress, function()
				progress:ProgressToValue(0, nil, 0)
			end)
		end)
	else
		progressPressContainer:SetActive(false)
	end
end

function FuncMenuCtrl:onRequestGamePadComponent()
	return "Guis.Panels.FuncMenu.Component.FuncMenuGamePadComponent"
end

function FuncMenuCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function FuncMenuCtrl:onPetResearchAreaSelectChanged(info)
	if self.fixedFuncListData then
		for idx, data in ipairs(self.fixedFuncListData) do
			if data.tIndex == 3 then
				self.view.listBtnUList:RefreshElement(idx - 1)

				return
			end
		end
	end
end

return FuncMenuCtrl
