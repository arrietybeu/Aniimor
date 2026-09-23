-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseLDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseLDComponent")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local ConflictTypes = require("Common.ConflictTypes")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local MessageName = require("Const.MessageName")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Utils = require("Common.Utils.Utils")
local BaseLDComponent = Class.LightClass("BaseLDComponent", HudBaseComponent)

BaseLDComponent.messages = {
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"refreshCommonSwitchState",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_LOCKED] = {
		"onSystemFunctionLocked",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_UNLOCKED] = {
		"onSystemFunctionUnlocked",
		true
	},
	[MessageName.ON_SYSTEM_FUNCTION_SHIELDED] = {
		"onSystemFunctionShielded",
		true
	},
	[MessageName.CHAT_RED_DOT_UPDATE] = {
		"onChatRedDotMsg",
		true
	},
	[MessageName.ADD_NEW_CHAT_MESSAGE] = {
		"onNewChatMessage",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.INTERACT_GESTURE_UNLOCK_CHANGED] = {
		"onInteractGestureUnlockChanged",
		true
	},
	[MessageName.APPEARANCE_CUR_SUIT_ID_CHANGED] = {
		"refreshInteractGestureBtnState",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	}
}

function BaseLDComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.propBallContainer = objectReference:GetRefValue("propBallContainer")
	self.propUWidget = objectReference:GetRefValue("propUWidget")
	self.ballBarUWidget = objectReference:GetRefValue("ballBarUWidget")
	self.btnChat = objectReference:GetRefValue("btnChat")
	self.chatBubbleUWidget = objectReference:GetRefValue("chatBubbleUWidget")
	self.txtContentUBaseText = objectReference:GetRefValue("txtContentUBaseText")
	self.btnEmoticonUButton = objectReference:GetRefValue("btnEmoticonUButton")
	self.btnEnterPhotoUButton = objectReference:GetRefValue("btnEnterPhotoUButton")
	self.btnEmoticonObjectReference = objectReference:GetRefValue("btnEmoticonObjectReference")
	self.btnEnterPhotoHotKeyContent = objectReference:GetRefValue("btnEnterPhotoHotKeyContent")
end

function BaseLDComponent:initView()
	self:bindBtnPhotoEvents()
	self:bindBtnChatEvents()
	self:bindBtnEmoticonEvents()
	self:refreshInteractGestureBtnState()
	self:refreshBtnChatVisible()
	self:onInputDeviceChanged()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:onTeammateViewChange()
	self:refreshInteractGestureBtnState()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:bindBtnPhotoEvents()
	self:bindHotKeyPerform("Hud/QuickPhoto", function()
		self:onClickPhotoBtn()
	end, self.btnEnterPhotoUButton.gameObject, "Hud/QuickPhoto")

	function self.btnEnterPhotoUButton.luaClick()
		self:onClickPhotoBtn()
	end

	self.btnEnterPhotoHotKeyContent:SetHotKeyPaths("Hud/QuickPhoto")
	self:bindHotKeyPerform("Hud/Snapshot", function()
		self:onClickPhotoBtn(nil, true)
	end)
end

function BaseLDComponent:onClickPhotoBtn(preset, snapshot)
	if self:isInNpcDuel() then
		return
	end

	if LuaUIUtils.checkFuncForbidden(Const.FUNCTION_IDS.TAKEPHOTO) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	self:openPhotoPanel(preset, snapshot)
end

function BaseLDComponent:openPhotoPanel(preset, snapshot)
	if self:isInNpcDuel() then
		return
	end

	if pg.me:PET_SPECIAL_VISION_ST() then
		return
	end

	if self.ctrl.mutePhoto == true then
		return
	end

	if pg.me.inTeammateView then
		return
	end

	if not pg.me:checkStatus(ConflictTypes.CT_PHOTO) then
		pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	local photo = pg.global.ui.photo

	photo:open({
		photoMode = photo.ModeType.NORMAL_MODE,
		preset = preset,
		snapshot = snapshot
	})
end

function BaseLDComponent:bindComponent()
	self.ball = self:getBaseComponentCls("ball").new(self, self.ballBarUWidget.transform, {
		needLoadRes = false,
		compName = "ball"
	})
	self.quickChat = self:getBaseComponentCls(HudSplicingCfg.componentName.quickChat).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.quickChat
	})
	self.focus = self:getBaseComponentCls(HudSplicingCfg.componentName.focus).new(self, nil, {
		isFixRoot = true,
		compName = HudSplicingCfg.componentName.focus
	})
end

function BaseLDComponent:isInNpcDuel()
	local space = pg.me and pg.me.space or pg.space

	return space and type(space.isNpcDuel) == "function" and space:isNpcDuel() or false
end

function BaseLDComponent:refreshButtonVisibleState()
	if not self.view or not self.btnChat or not self.btnEnterPhotoUButton then
		return
	end

	self:refreshBtnChatVisible()
	self:refreshInteractGestureBtnState()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:refreshBtnChatVisible()
	local visible = true

	if self:isInNpcDuel() then
		visible = false
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Chat) then
		visible = false
	end

	if not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.CHAT) then
		visible = false
	end

	self.btnChat:SetActive(visible)
end

function BaseLDComponent:bindBtnChatEvents()
	function self.btnChat.luaClick()
		self:openChat()
	end

	local objectReference = self.btnChat:GetComponent("ObjectReference")
	local btnChatHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	btnChatHotKeyContent:SetHotKeyPaths("Hud/OpenChat")

	local function openChatByHotKey()
		local quickChatGameObject = self.quickChat.gameObject
		local isQuickChatVisible = not IsNil(quickChatGameObject) and quickChatGameObject.activeInHierarchy
		local canOpenChat = self.btnChat.gameObject.activeInHierarchy or isQuickChatVisible

		if not canOpenChat then
			return true
		end

		self:openChat()

		return false
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_CHAT, self.btnChat, function()
		return pg.game.chat:redDot_GetHudChatButtonState()
	end, function()
		return pg.game.chat:redDot_HudChatGetAllUnreadMessage()
	end)
	self:bindMapChatHotKey(btnChatHotKeyContent, openChatByHotKey)
end

function BaseLDComponent:tryOpenChatByHotKey(openChatByHotKey)
	if not pg.me:checkFunctionUnlock("CHAT") or not CommonSwitch.CHAT then
		return true
	end

	if pg.me:MAGNESIS_READY_ST() or pg.me:MAGNESIS_ST() then
		return true
	end

	if LuaUIUtils.checkFuncForbidden(Const.FUNCTION_IDS.CHAT) then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))
		end

		return true
	end

	return openChatByHotKey()
end

function BaseLDComponent:bindMapChatHotKey(btnChatHotKeyContent, openChatByHotKey)
	local actionPath = "Raw/GamepadSelect"
	local longPressStartTime = 0.25

	local function openMapByHotKey()
		self.ctrl:tryOpenMapByHotKey()

		return false
	end

	local function resetMapChatPress()
		return
	end

	local openTeamResetBind = self:bindHotKeyPerform("Hud/OpenTeam", function()
		resetMapChatPress()

		return true
	end)

	openTeamResetBind.priority = 1

	LuaUIUtils.waitHotKeyContentObjectReference(self, btnChatHotKeyContent, function(objectReference)
		local progressPressContainer = objectReference:GetRefValue("progressPressContainerUContainer")

		if not progressPressContainer then
			return
		end

		self.mapChatProgressPressContainer = progressPressContainer

		progressPressContainer:SetActive(pg.game.input:isUsingGamepad())
		progressPressContainer:LoadDefaultUrlManually(function()
			local progress = progressPressContainer.content

			if not progress then
				return
			end

			local longPressTriggered = false
			local releasedAfterLongPressStart = false
			local ignoreUntilReleased = false
			local ignoreSetFrame = -1
			local pressName = actionPath .. "press"
			local pressTimeName = actionPath .. "pressTime"

			progress:ProgressToValue(0, nil, 0)

			local hotKeyBind = self.ctrl:bindHotKeyWithProgress(actionPath, function()
				longPressTriggered = true

				self:tryOpenChatByHotKey(openChatByHotKey)
				progress:ProgressToValue(0, nil, 0)
			end, self.btnChat.gameObject, progress, function()
				progress:ProgressToValue(0, nil, 0)

				if not longPressTriggered and not releasedAfterLongPressStart then
					openMapByHotKey()
				end

				longPressTriggered = false
				releasedAfterLongPressStart = false
			end, {
				passThrough = true,
				priority = 1,
				startTriggerPressTime = longPressStartTime
			})
			local progressTrigger = hotKeyBind.luaTrigger

			function hotKeyBind.luaTrigger(inputInfo)
				if inputInfo.phase == "Checked" then
					return false
				end

				if ignoreUntilReleased then
					local isFreshPress = inputInfo.phase == "Started" and Time.frameCount > ignoreSetFrame

					if isFreshPress then
						ignoreUntilReleased = false
						longPressTriggered = false
						releasedAfterLongPressStart = false

						progress:ProgressToValue(0, nil, 0)
					elseif inputInfo.phase == "Canceled" then
						ignoreUntilReleased = false
						longPressTriggered = false
						releasedAfterLongPressStart = false

						progress:ProgressToValue(0, nil, 0)

						return true
					else
						return true
					end
				end

				if inputInfo.phase == "Performed" then
					longPressTriggered = false
					releasedAfterLongPressStart = false
				elseif inputInfo.phase == "Canceled" then
					releasedAfterLongPressStart = (self.ctrl[pressTimeName] or 0) > longPressStartTime
				end

				return progressTrigger(inputInfo)
			end

			function resetMapChatPress()
				ignoreUntilReleased = true
				ignoreSetFrame = Time.frameCount

				if self.ctrl[pressName] then
					self.ctrl:killTimer(self.ctrl[pressName])
				end

				self.ctrl[pressName] = nil
				self.ctrl[pressTimeName] = 0
				longPressTriggered = false
				releasedAfterLongPressStart = false

				progress:ProgressToValue(0, nil, 0)
			end
		end)
	end)
	self:bindHotKeyPerform("Raw/KeyBoardEnter", function()
		self:tryOpenChatByHotKey(openChatByHotKey)
	end)
	self:bindHotKeyPerform("Hud/OpenChat", function()
		if pg.game.input:isUsingGamepad() and not self.btnChat.gameObject.activeInHierarchy then
			self.ctrl:tryOpenMapByHotKey()

			return false
		end

		return true
	end)
end

function BaseLDComponent:openChat()
	if self:isInNpcDuel() then
		return
	end

	if self.quickChat then
		self.quickChat:openChat()
	end
end

function BaseLDComponent:onNewChatMessage(info)
	if pg.me == nil then
		return
	end

	local messageData = info and info.messageData
	local isNewOtherPlayerMessage = info ~= nil and info.isHistory ~= true and messageData ~= nil and messageData.playerId ~= pg.me.uid

	if not isNewOtherPlayerMessage then
		return
	end

	local showBubble = pg.game.chat:checkChatSettingState(messageData.channelType, pg.game.chat.settingType.MessageInform, messageData.channelId)

	if showBubble ~= true then
		return
	end

	local channelType = messageData.channelType
	local shouldRefreshChatButton = channelType == pg.game.chat.channelType.World or channelType == pg.game.chat.channelType.Near or channelType == pg.game.chat.channelType.Vehicle

	if shouldRefreshChatButton and self.quickChat ~= nil then
		self.quickChat:refreshBtnChatAnim(true)
	end
end

function BaseLDComponent:onChatRedDotMsg()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_CHAT)
end

function BaseLDComponent:bindBtnEmoticonEvents()
	self.btnEmoticonUButton.enabledTooltip = false

	function self.btnEmoticonUButton.luaClick()
		self:openEmoticonPanel()
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE, self.btnEmoticonUButton, function()
		return pg.game.social.interactGestureComponent:hasNewInteractGesture()
	end)
	self:bindHotKeyPerform("Hud/OpenEmotion", function()
		self:openEmoticonPanel()
	end, self.btnEmoticonUButton.gameObject, "Hud/OpenEmotion")

	self.btnEmoticonHotKeyContent = self.btnEmoticonObjectReference:GetRefValue("btnEmoticonHotKeyContent")
	self.btnEmoticonConsoleHotKeyContent = self.btnEmoticonObjectReference:GetRefValue("btnEmoticonHotKeyContent")

	self:bindGamepadEmoticonLongPress()
end

function BaseLDComponent:bindGamepadEmoticonLongPress()
	local hotKeyContent = self.btnEmoticonConsoleHotKeyContent

	if not hotKeyContent then
		return
	end

	LuaUIUtils.waitHotKeyContentObjectReference(self, hotKeyContent, function(objectReference)
		local progressPressContainers = {}
		local progressPressContainer1 = objectReference:GetRefValue("progressPressContainerSet1UContainer")

		if progressPressContainer1 then
			progressPressContainers[#progressPressContainers + 1] = progressPressContainer1
		end

		local progressPressContainer2 = objectReference:GetRefValue("progressPressContainerSet2UContainer")

		if progressPressContainer2 then
			progressPressContainers[#progressPressContainers + 1] = progressPressContainer2
		end

		if #progressPressContainers == 0 then
			return
		end

		self.emoticonProgressPressContainers = progressPressContainers

		local loadedProgresses = {}
		local pendingContainerCount = #progressPressContainers

		for _, container in ipairs(progressPressContainers) do
			container:SetActive(pg.game.input:isUsingGamepad())
			container:LoadDefaultUrlManually(function()
				local progress = container.content

				if progress then
					loadedProgresses[#loadedProgresses + 1] = progress
				end

				pendingContainerCount = pendingContainerCount - 1

				if pendingContainerCount == 0 then
					self:bindGamepadEmoticonProgress(loadedProgresses)
				end
			end)
		end
	end)
end

function BaseLDComponent:bindGamepadEmoticonProgress(loadedProgresses)
	if #loadedProgresses == 0 then
		return
	end

	local progress = {}

	function progress:ProgressToValue(value, options, duration)
		for _, loadedProgress in ipairs(loadedProgresses) do
			loadedProgress:ProgressToValue(value, options, duration)
		end
	end

	progress:ProgressToValue(0, nil, 0)
	self.ctrl:bindHotKeyWithProgress("Hud/GamepadOpenEmoticon", function()
		progress:ProgressToValue(0, nil, 0)
		self:openEmoticonPanel()
	end, self.btnEmoticonUButton.gameObject, progress, function()
		progress:ProgressToValue(0, nil, 0)
	end, {
		gamepadOnly = true
	})
end

function BaseLDComponent:onInputDeviceChanged()
	local isGamepad = pg.game.input:isUsingGamepad()

	if self.mapChatProgressPressContainer then
		self.mapChatProgressPressContainer:SetActive(isGamepad)
	end

	if self.emoticonProgressPressContainers then
		for _, container in ipairs(self.emoticonProgressPressContainers) do
			container:SetActive(isGamepad)
		end
	end

	if isGamepad then
		if self.btnEmoticonConsoleHotKeyContent then
			self.btnEmoticonConsoleHotKeyContent:SetHotKeyPaths("Hud/GamepadOpenEmoticon")
		end
	elseif self.btnEmoticonHotKeyContent then
		self.btnEmoticonHotKeyContent:SetHotKeyPaths("Hud/OpenEmotion")
	end

	self:refreshPhotoBtnState()
end

function BaseLDComponent:openEmoticonPanel(info)
	if self:isInNpcDuel() then
		return
	end

	if self.ctrl and self.ctrl.isInVehicle then
		return
	end

	if not QuestUtils.isQuestFinished(Const.INTERACT_GESTURE_QUEST_ID) then
		return
	end

	local ent = pg.me:isControllingPet() and pg.me:getCurPetEntity() or pg.me

	if not CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.LOCOMOTION) and ent.characterState ~= CharacterStateConst.SOCIALANIM then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	if self.ctrl and self.ctrl.RD and self.ctrl.RD.interactGesture then
		local interactGesture = self.ctrl.RD.interactGesture

		interactGesture:prepareOpenEmoticonPanel(info)

		if interactGesture:tryShowComponent() then
			interactGesture:openEmoticonPanel(info)
		end
	end
end

function BaseLDComponent:onInteractGestureUnlockChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE)
end

function BaseLDComponent:showEmotionBtn(show)
	if self.btnEmoticonUButton then
		self.btnEmoticonUButton:SetActiveFastest(show)
	end

	local quality = pg.game.social.interactGestureComponent:getAppearanceSuitActionQuality()

	self.btnEmoticonUButton:TryChangePage("BtnEmoticon", quality > 0 and quality - 3 or 0)
end

function BaseLDComponent:refreshInteractGestureBtnState()
	local show = QuestUtils.isQuestFinished(Const.INTERACT_GESTURE_QUEST_ID)

	if self:isInNpcDuel() then
		show = false
	end

	if pg.space and pg.space:isRogueEnv() then
		show = false
	end

	if pg.me and pg.me.inTeammateView then
		show = false
	end

	self:showEmotionBtn(show)
end

function BaseLDComponent:onModuleEnableChanged(changeInfo)
	if not self.view then
		return
	end

	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.Chat then
		self:refreshBtnChatVisible()
	end
end

function BaseLDComponent:refreshCommonSwitchState()
	self:refreshBtnChatVisible()
end

function BaseLDComponent:onSystemFunctionUnlocked()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:onSystemFunctionShielded()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:onSystemFunctionLocked()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function BaseLDComponent:refreshPhotoBtnState()
	local canOpen = pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TAKEPHOTO) and CommonSwitch[Const.FUNCTION_NAME.TAKEPHOTO] ~= false and not self:isInNpcDuel()

	if pg.me.inTeammateView then
		canOpen = false
	end

	if pg.game.input:isUsingGamepad() then
		canOpen = false
	end

	if pg.space and Utils.isRobEggSceneId(pg.space.sceneId) then
		canOpen = false
	end

	self.btnEnterPhotoUButton:SetActive(canOpen)
end

function BaseLDComponent:setVisible(visible)
	LuaUIUtils.setUIVisible(self.uWidget, visible)
end

function BaseLDComponent:showRecommendGesture(show, data)
	local objectReference = self.btnEmoticonObjectReference

	if not objectReference then
		return
	end

	local emoRecommendRectTransform = objectReference:GetRefValue("emoRecommendRectTransform")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnPoseUButton = objectReference:GetRefValue("btnPoseUButton")
	local emoRecommendAnimation = objectReference:GetRefValue("emoRecommendAnimation")

	if show then
		btnPoseUButton.gameObject:SetActiveEx(true)

		iconUImage.url = data.icon

		function btnPoseUButton.luaClick()
			if data.func then
				data.func()
			end

			self:showRecommendGesture(false)
		end

		emoRecommendRectTransform.gameObject:SetActiveEx(true)
	else
		btnPoseUButton.gameObject:SetActiveEx(false)
		UIUtils.PlayAnimation(emoRecommendAnimation, "VX_Pb_Hud_Frame_EmoRecommend_Out", function()
			emoRecommendRectTransform.gameObject:SetActiveEx(false)
		end)
	end
end

function BaseLDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function BaseLDComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function BaseLDComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return BaseLDComponent
