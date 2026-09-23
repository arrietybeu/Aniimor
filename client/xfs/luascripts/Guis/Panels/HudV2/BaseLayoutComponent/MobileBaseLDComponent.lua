-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\MobileBaseLDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileBaseLDComponent")
local Class = require("Core.Framework.Class")
local ConflictTypes = require("Common.ConflictTypes")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local SysNoticeData = require("Data.sys_notice_data")
local AttributeConst = require("Common.Const.AttributeConst")
local CommonSwitch = require("Common.CommonSwitch")
local MobileBaseLDComponent = Class.LightClass("MobileBaseLDComponent", HudBaseComponent)
local MessageName = require("Const.MessageName")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local MobileAimUIComponent = require("Guis.Panels.HudV2.BaseComponent.MobileAimUIComponent")
local CharacterStateConst = require("Common.Const.CharacterStateConst")

MobileBaseLDComponent.messages = {
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
	[MessageName.INTERACT_GESTURE_UNLOCK_CHANGED] = {
		"onInteractGestureUnlockChanged",
		true
	},
	[MessageName.APPEARANCE_CUR_SUIT_ID_CHANGED] = {
		"refreshInteractGestureBtnState",
		true
	},
	[MessageName.CONTROL_STATE_CHANGE] = {
		"refreshPetActionModeVisible",
		true
	},
	[MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE] = {
		"refreshSpeechState",
		true
	},
	[MessageName.SPEECH_ROOM_STATE_CHANGE] = {
		"refreshBtnSpeakVisible",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshVoiceBtnByTeamInfo",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"refreshVoiceBtnByTeamInfo",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	}
}

function MobileBaseLDComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnVoiceUButton = objectReference:GetRefValue("btnVoiceUButton")
	self.btnEnterPhotoUButton = objectReference:GetRefValue("btnEnterPhotoUButton")
	self.btnChat = objectReference:GetRefValue("btnChatUButton")
	self.btnEmoticonUButton = objectReference:GetRefValue("btnEmoticonUButton")
	self.btnPetModeUContainer = objectReference:GetRefValue("btnPetModeUContainer")
end

function MobileBaseLDComponent:onTeammateViewChange()
	if pg.me.inTeammateView then
		self.btnEnterPhotoUButton.gameObject:SetActiveEx(false)
		self.btnEmoticonUButton.gameObject:SetActiveEx(false)
	else
		self.btnEmoticonUButton.gameObject:SetActiveEx(true)
		self:refreshPhotoBtnState()
	end
end

function MobileBaseLDComponent:initView()
	self:bindBtnChatEvents()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_CHAT, self.btnChat, function()
		return pg.game.chat:redDot_GetHudChatButtonState()
	end, function()
		return pg.game.chat:redDot_HudChatGetAllUnreadMessage()
	end)

	function self.btnVoiceUButton.luaPress()
		if not pg.me:isInTeam() or not pg.me:isInSpeechChannel(pg.me.uid) then
			return
		end

		pg.global.gmeManager:EnableMic(true, true)
	end

	self.btnEmoticonUButton.enabledTooltip = false

	function self.btnEmoticonUButton.luaClick()
		self:openEmoticonPanel()
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE, self.btnEmoticonUButton, function()
		return pg.game.social.interactGestureComponent:hasNewInteractGesture()
	end)

	function self.btnVoiceUButton.luaRelease()
		if not pg.me:isInTeam() or not pg.me:isInSpeechChannel(pg.me.uid) then
			return
		end

		pg.global.gmeManager:EnableMic(false, true)
	end

	function self.btnEnterPhotoUButton.luaClick()
		if LuaUIUtils.checkFuncForbidden(Const.FUNCTION_IDS.TAKEPHOTO) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_CANT_STATE"))

			return
		end

		self:openPhotoPanel()
	end

	if not self.btnPetModeUContainer:CheckURLLoaded() then
		self.btnPetModeUContainer:LoadDefaultUrlManually(function(content)
			self.btnPetModeUButton = content

			self:initPetActionMode()
		end)
	else
		self.btnPetModeUButton = self.btnPetModeUContainer.content

		self:initPetActionMode()
	end

	self:refreshPetActionModeVisible()
	self:refreshInteractGestureBtnState()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
	self:refreshVoiceBtnByTeamInfo()
end

function MobileBaseLDComponent:bindBtnChatEvents()
	function self.btnChat.luaClick()
		self:openChat()
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HUD_CHAT, self.btnChat, function()
		return pg.game.chat:redDot_GetHudChatButtonState()
	end, function()
		return pg.game.chat:redDot_HudChatGetAllUnreadMessage()
	end)
	self:bindHotKeyOverride(Const.FUNCTION_IDS.CHAT, "CHAT", nil, true, function()
		local quickChatGameObject = self.quickChat.gameObject
		local isQuickChatVisible = not IsNil(quickChatGameObject) and quickChatGameObject.activeInHierarchy
		local canOpenChat = self.btnChat.gameObject.activeInHierarchy or isQuickChatVisible

		if not canOpenChat then
			return true
		end

		self:openChat()
	end)
end

function MobileBaseLDComponent:openChat()
	if self:isInNpcDuel() then
		return
	end

	if self.quickChat then
		self.quickChat:openChat()
	end
end

function MobileBaseLDComponent:onNewChatMessage(info)
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

function MobileBaseLDComponent:onChatRedDotMsg()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_CHAT)
end

function MobileBaseLDComponent:refreshInteractGestureBtnState()
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

function MobileBaseLDComponent:showEmotionBtn(show)
	if self.btnEmoticonUButton then
		self.btnEmoticonUButton:SetActiveFastest(show)
	end

	local quality = pg.game.social.interactGestureComponent:getAppearanceSuitActionQuality()

	self.btnEmoticonUButton:TryChangePage("BtnEmoticon", quality > 0 and quality - 3 or 0)
end

function MobileBaseLDComponent:initPetActionMode()
	if not self.btnPetModeUButton then
		return
	end

	local petModeObjectReference = self.btnPetModeUButton:GetComponent("ObjectReference")

	self.petModeIcon0 = petModeObjectReference:GetRefValue("petModeIcon0")
	self.petModeIcon1 = petModeObjectReference:GetRefValue("petModeIcon1")
	self.petModeIcon2 = petModeObjectReference:GetRefValue("petModeIcon2")

	function self.btnPetModeUButton.luaClick()
		self:setPetBattleState((pg.me.petActionMode + 1) % 3)
	end

	self.btnPetModeUButton:TryChangePage("PetMode", pg.me.petActionMode)
	self:refreshPetActionModeVisible()

	local player = pg.me

	if player.petActionMode == Const.PetActionMode.Catch then
		self.petModeIcon0.gameObject:SetActiveEx(true)
	elseif player.petActionMode == Const.PetActionMode.Peace then
		self.petModeIcon1.gameObject:SetActiveEx(true)
	elseif player.petActionMode == Const.PetActionMode.Invade then
		self.petModeIcon2.gameObject:SetActiveEx(true)
	end
end

function MobileBaseLDComponent:bindPetActionModeAttributeNotify()
	local actorCombatAttribute = pg.me.actorCombatAttribute

	if self.petModeAttrOwner == actorCombatAttribute then
		return
	end

	self.petModeAttrOwner = actorCombatAttribute

	actorCombatAttribute:registerAttributeNotify(AttributeConst.open_go_multi_mode, function()
		self:refreshPetActionModeVisible()
	end)
end

function MobileBaseLDComponent:setPetBattleState(state)
	self.btnPetModeUButton:TryChangePage("PetMode", state)
	pg.me:serverMsg("RPC_CS_SetPetActionMode", state)
	pg.global.ui.tips:showTextTip(pg.getLocalizationText(SysNoticeData[NoticeDef.SWITCH_PET_MODE_CATCH + state].text))
end

function MobileBaseLDComponent:bindComponent()
	self.quickChat = self:getBaseComponentCls(HudSplicingCfg.componentName.quickChat).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.quickChat
	})
	self.mobileAddonBtn = self:getBaseComponentCls(HudSplicingCfg.componentName.mobileAddonBtn).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileAddonBtn
	})
	self.aim = MobileAimUIComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.aimMobile
	})
	self.focus = self:getBaseComponentCls(HudSplicingCfg.componentName.focus).new(self, nil, {
		isFixRoot = true,
		compName = HudSplicingCfg.componentName.focus
	})
	self.focusFrame = self:getBaseComponentCls(HudSplicingCfg.componentName.focusFrame).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiWorldNode.transform,
		compName = HudSplicingCfg.componentName.focusFrame
	})
end

function MobileBaseLDComponent:isInNpcDuel()
	local space = pg.me and pg.me.space or pg.space

	return space and type(space.isNpcDuel) == "function" and space:isNpcDuel() or false
end

function MobileBaseLDComponent:refreshButtonVisibleState()
	if not self.view or not self.btnChat or not self.btnEnterPhotoUButton or not self.btnVoiceUButton then
		return
	end

	self:refreshPetActionModeVisible()
	self:refreshBtnChatVisible()
	self:refreshInteractGestureBtnState()
	self:refreshPhotoBtnState()
	self:refreshVoiceBtnByTeamInfo()
end

function MobileBaseLDComponent:openEmoticonPanel(info)
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

function MobileBaseLDComponent:onInteractGestureUnlockChanged()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HUD_INTERACT_GESTURE)
end

function MobileBaseLDComponent:openPhotoPanel(preset, snapshot)
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

function MobileBaseLDComponent:refreshPetActionModeVisible()
	if not self.btnPetModeUContainer then
		return
	end

	local player = pg.me

	if not player then
		return
	end

	local showPetModel = player:isControlFollow() and player.actorCombatAttribute:getAttribValue(AttributeConst.open_go_multi_mode) == 1

	if self:isInNpcDuel() then
		showPetModel = false
	end

	if showPetModel and (Utils.isInSocialScene() or Utils.isSpaceTown(pg.space and pg.space.spaceType)) then
		showPetModel = false
	end

	LuaUIUtils.setUIVisible(self.btnPetModeUContainer, showPetModel)
end

function MobileBaseLDComponent:refreshBtnChatVisible()
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

	self.btnChat.renderOpacity = visible and 1 or 0
end

function MobileBaseLDComponent:onModuleEnableChanged(changeInfo)
	if not self.view then
		return
	end

	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.Chat then
		self:refreshBtnChatVisible()
	end
end

function MobileBaseLDComponent:refreshCommonSwitchState()
	self:refreshBtnChatVisible()
end

function MobileBaseLDComponent:onSystemFunctionUnlocked()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function MobileBaseLDComponent:onSystemFunctionShielded()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function MobileBaseLDComponent:onSystemFunctionLocked()
	self:refreshBtnChatVisible()
	self:refreshPhotoBtnState()
end

function MobileBaseLDComponent:refreshPhotoBtnState()
	local canOpen = pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TAKEPHOTO) and CommonSwitch[Const.FUNCTION_NAME.TAKEPHOTO] ~= false and not self:isInNpcDuel()

	if pg.me.inTeammateView then
		canOpen = false
	end

	if pg.space and Utils.isRobEggSceneId(pg.space.sceneId) then
		canOpen = false
	end

	self.btnEnterPhotoUButton:SetActive(canOpen)
end

function MobileBaseLDComponent:setVisible(visible)
	LuaUIUtils.setUIVisible(self.uWidget, visible)
end

function MobileBaseLDComponent:showRecommendGesture(show, data)
	return
end

function MobileBaseLDComponent:refreshSpeechState()
	if pg.me and pg.game.speech:checkMemberSpeaking(pg.me.uid) then
		self.btnVoiceUButton:TryChangePage("State", 1)
	else
		self.btnVoiceUButton:TryChangePage("State", 0)
	end
end

function MobileBaseLDComponent:refreshBtnSpeakVisible(info)
	if pg.me and pg.me.space and pg.me.space:isHomeland() then
		self.btnVoiceUButton:SetActive(false)

		return
	end

	if self:isInNpcDuel() then
		self.btnVoiceUButton:SetActive(false)

		return
	end

	self.btnVoiceUButton:SetActive(info.inSpeechRoom)
end

function MobileBaseLDComponent:refreshVoiceBtnByTeamInfo()
	if pg.me and pg.me.space and pg.me.space:isHomeland() then
		self.btnVoiceUButton:SetActive(false)

		return
	end

	if self:isInNpcDuel() then
		self.btnVoiceUButton:SetActive(false)

		return
	end

	self.btnVoiceUButton:SetActive(pg.me and pg.me:isInTeam() and pg.me:isInSpeechChannel(pg.me.uid))
end

function MobileBaseLDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function MobileBaseLDComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobileBaseLDComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MobileBaseLDComponent
