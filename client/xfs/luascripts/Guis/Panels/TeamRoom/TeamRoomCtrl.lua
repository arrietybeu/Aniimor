-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\TeamRoomCtrl.lua

local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HotkeyConst = require("Const.HotkeyConst")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local logger = require("Core.Log.LoggerManager").getLogger("TeamRoomCtrl")
local TeamRoomCtrl = Class.LightClass("TeamRoomCtrl", UICtrl)
local PlayerSkillData = require("Data.player_skill_data")
local AbilityParamData = require("Data.ability_param_data")
local PetData = require("Data.pet_data")
local FuncIdConfigData = require("Data.func_index_config_data")
local CameraConst = require("GameApp.Camera.CameraConst")
local TeamUtils = require("Utils.TeamUtils")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local TeamPrepRoomCommonComponent = require("Guis.Panels.TeamRoom.Component.TeamPrepRoomCommonComponent")
local TeamRoomSocialComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomSocialComponent")
local TeamRoomChatBarrageComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomChatBarrageComponent")
local TeamRoomSelectComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomSelectComponent")
local TeamRoomTargetComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomTargetComponent")
local TeamRoomGrabEggsEquipComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomGrabEggsEquipComponent")
local TeamRoomInterceptTipComponent = require("Guis.Panels.TeamRoom.Component.TeamRoomInterceptTipComponent")
local TeamMatchEntryComponent = require("Guis.Panels.ActiveDungeon.Component.TeamMatchEntryComponent")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local UICardRenderUtils = require("Guis.Utils.UICardRenderUtils")

TeamRoomCtrl.messages = {
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.TEAM_CONFIRM_FAIL] = {
		"teamConfirmFail",
		true
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"enterDungeon",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"onPetFormationUpdate",
		true
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onTeleport",
		false
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	},
	[MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE] = {
		"onTeamMatchedStatusChange",
		true
	}
}

function TeamRoomCtrl:checkCanOpen(showNotice, info)
	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(FuncIdConfigData[Const.FUNCTION_NAME.TEAM].unlockDesc))

		return false
	end

	return UICtrl.checkCanOpen(self, showNotice, info)
end

function TeamRoomCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.widget.visibility = CS.XGUI.EVisibility.Visible
	self.petInfoEles = {}
	self.oldPetInfoLists = {}
	self.oldPrepareInfos = {}
	self.oldSkillInfoLists = {}
	self.oldTeamLeader = nil
	self.equipedSkill = true
	self.curSelectedBtn = nil
	self.dungeonSceneId = nil
	self.dungeonId = info and info.dungeonId or nil
	self.difficultLv = info and (info.difficultLv or info.hardLv) or nil

	self.model:setDungeonInfo(self.dungeonId, self.difficultLv)
	self:bind3DUI()
	self:initTeamRoomFrameComponents()
	self:initGrabEggsEquipComponent()
	self:initView()
	self:startTimer(function()
		self:refreshModelsAni()
	end, 20, true)
end

function TeamRoomCtrl:onTeleport()
	self:dismiss()
end

function TeamRoomCtrl:refreshModelsAni()
	if self.uiScene then
		self.uiScene:refreshModelsAni()
	end
end

function TeamRoomCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCancelUButton.luaClick()
		pg.me:cancelPrepareTeamDungeon()
	end

	function self.view.btnCancelMatchUButton.luaClick()
		pg.me:cancelTeamMatching()

		if pg.me:isInTeam() and not pg.me:isEggTeam() then
			pg.me:cancelTeamDungeon()
		end
	end

	self:bindCloseButton()

	function self.view.btnReleaseUButton2.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("LEAVE_TEAM_TIP"), function()
			local matchSuccess = pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED

			pg.me:leaveTeam(matchSuccess)
			self:dismiss()
		end, nil)
	end

	function self.view.btnReleaseUButton.luaClick()
		local tip, confirmFunc

		if self:isPrepareRoom() then
			tip = pg.getGameString("TEAM_COMFIRM_REFUSE_APPLY")

			function confirmFunc()
				pg.me:cancelTeamDungeon()
				self:dismiss()
			end
		else
			tip = pg.getGameString("LEAVE_TEAM_TIP")

			function confirmFunc()
				local matchSuccess = pg.me.matchState == Const.PLAYER_MATCH_STATUS.MATCHED

				pg.me:leaveTeam(matchSuccess)
				self:dismiss()
			end
		end

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), tip, confirmFunc, nil)
	end

	self:bindTeamRoomConsoleBarActions()
end

function TeamRoomCtrl:checkAutoLeaveTeam()
	local txtCount = pg.me:isInTeam() and pg.me:getTeamMemberCount(true) or 0

	if not pg.me:isInMatching() then
		if txtCount == 1 then
			pg.me:leaveTeam()
		elseif txtCount > 1 and pg.me:isTeamLeader() then
			pg.me:cancelTeamDungeon()
		end
	end
end

function TeamRoomCtrl:refreshConsoleBarState()
	if self.commonCmp then
		self.commonCmp:refreshConsoleBarState()
	end
end

function TeamRoomCtrl:refreshFocusedMemberConsoleBarState()
	if self.commonCmp then
		self.commonCmp:refreshFocusedMemberConsoleBarState()
	end
end

function TeamRoomCtrl:bind3DUI()
	self.petInfoEles = self.uiScene.petInfoEles
end

function TeamRoomCtrl:initCommonComponent()
	if self.commonCmp then
		return
	end

	self.commonCmp = TeamPrepRoomCommonComponent.new(self, nil, {
		navListenerName = "TeamRoom",
		logger = logger
	})
end

function TeamRoomCtrl:initTeamRoomFrameComponents()
	local frameContainer = self.view.teamRoomFrameUContainer

	frameContainer:LoadDefaultUrlManually(function(content)
		local objectReference = content:GetComponent("ObjectReference")

		self.view.teamRoomTargetUContainer = objectReference:GetRefValue("targetUContainer")
		self.view.teamRoomChatUContainer = objectReference:GetRefValue("chatUContainer")
		self.view.teamRoomSelectUContainer = objectReference:GetRefValue("selectUContainer")
		self.view.teamRoomBtnPanelUContainer = objectReference:GetRefValue("btnPanelUContainer")
		self.view.chatBarrageUContainer = objectReference:GetRefValue("chatBarrageUContainer")

		self:initTeamRoomSocialComponent(self.view.teamRoomChatUContainer)
		self:initTeamRoomChatBarrageComponent(self.view.chatBarrageUContainer)
		self:initTeamRoomTargetComponent(self.view.teamRoomTargetUContainer)
		self:initInterceptTipComponent(content)

		if not self:isInTeamDungeonRoom() then
			self:initTeamRoomSelectComponent(self.view.teamRoomSelectUContainer)
			self:initMatchEntryComponent(self.view.teamRoomBtnPanelUContainer)
		end

		self:refreshTeamRoomFrameState()
	end)
end

function TeamRoomCtrl:initInterceptTipComponent(content)
	self.interceptTipCmp = TeamRoomInterceptTipComponent.new(self, content)
end

function TeamRoomCtrl:initTeamRoomSelectComponent(selectContainer)
	selectContainer:LoadDefaultUrlManually(function(content)
		self.selectCmp = TeamRoomSelectComponent.new(self, content)

		self:refreshTeamRoomFrameState()
	end)
end

function TeamRoomCtrl:initTeamRoomTargetComponent(targetContainer)
	targetContainer:LoadDefaultUrlManually(function(content)
		self.targetCmp = TeamRoomTargetComponent.new(self, content)

		self:refreshTeamRoomFrameState()
	end)
end

function TeamRoomCtrl:initTeamRoomSocialComponent(chatContainer)
	chatContainer:LoadDefaultUrlManually(function(content)
		self.socialCmp = TeamRoomSocialComponent.new(self, content)

		self:refreshTeamRoomSocialComponent()
	end)
end

function TeamRoomCtrl:initTeamRoomChatBarrageComponent(chatBarrageContainer)
	if not chatBarrageContainer then
		return
	end

	chatBarrageContainer:LoadDefaultUrlManually(function(content)
		self.chatBarrageCmp = TeamRoomChatBarrageComponent.new(self, content)
	end)
end

function TeamRoomCtrl:initMatchEntryComponent(btnPanelContainer)
	btnPanelContainer:LoadDefaultUrlManually(function(content)
		local dungeonId = self:getTeamRoomFrameDungeonId()
		local hardLv = self:getTeamRoomFrameHardLv()
		local dungeonConfig = self.model:getDungeonConfig(dungeonId)
		local dungeonType = dungeonConfig and dungeonConfig.fb_type or Const.CUR_DUNGEON_TYPE.Dungeon

		self.matchCom = TeamMatchEntryComponent.new(self, content, {
			dungeonId = dungeonId,
			dungeonType = dungeonType,
			hardLv = hardLv
		})

		self.matchCom:bindTeamRoomFrameStartButton()
		self.matchCom:refreshTeamRoomFrameMatchEntryState(dungeonId, hardLv)
		self:refreshTeamRoomFrameState()
	end)
end

function TeamRoomCtrl:initGrabEggsEquipComponent()
	self.view.grabEggsUContainer:LoadDefaultUrlManually(function(content)
		self.grabEggsEquipCmp = TeamRoomGrabEggsEquipComponent.new(self, content)

		self:refreshGrabEggsEquipComponent()
	end)
	self:refreshGrabEggsEquipComponent()
end

function TeamRoomCtrl:isTeamMatching()
	local status = pg.me.matchState

	return status == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON or status == Const.PLAYER_MATCH_STATUS.MATCH_TEAM
end

function TeamRoomCtrl:isInTeamDungeonRoom()
	return pg.me:isInTeamDungeonScene()
end

function TeamRoomCtrl:getTeamRoomFrameDungeonId()
	local teamInfo = pg.me:getCurTeamInfo()

	if self:isTeamMatching() then
		local matchDungeonId = pg.me:getMatchDungeonId()

		if matchDungeonId and matchDungeonId ~= 0 then
			return matchDungeonId
		end
	end

	return self.dungeonId or self.dungeonSceneId or teamInfo.dungeonSceneId
end

function TeamRoomCtrl:getTeamRoomFrameHardLv()
	if self.dungeonId then
		return self.difficultLv or self.model:getDifficultLv()
	end

	return self.model:getDifficultLv()
end

function TeamRoomCtrl:refreshGrabEggsEquipComponent()
	local visible = not self:isInTeamDungeonRoom() and self.model:isGrabEggsEquipDungeon(self:getTeamRoomFrameDungeonId())

	self.view.grabEggsUContainer:SetActive(visible)

	if self.grabEggsEquipCmp then
		if visible then
			self.grabEggsEquipCmp:show()
			self.grabEggsEquipCmp:refreshVisible()
		else
			self.grabEggsEquipCmp:hide()
		end
	end
end

function TeamRoomCtrl:refreshTeamRoomFrameState()
	local inTeamDungeonRoom = self:isInTeamDungeonRoom()

	if self.view.teamRoomSelectUContainer then
		self.view.teamRoomSelectUContainer:SetActive(not inTeamDungeonRoom)
	end

	if self.view.teamRoomBtnPanelUContainer then
		self.view.teamRoomBtnPanelUContainer:SetActive(not inTeamDungeonRoom)
	end

	self:refreshGrabEggsEquipComponent()

	if self.selectCmp then
		self.selectCmp:refreshView()
	end

	self:refreshBtnState()
end

function TeamRoomCtrl:isSinglePreviewRoom()
	return self.model and self.model:isSinglePreviewRoom()
end

function TeamRoomCtrl:refreshTeamRoomSocialComponent()
	if not self.socialCmp then
		return
	end

	if self:isSinglePreviewRoom() and not self:isInTeamDungeonRoom() then
		self.socialCmp:hide()
	else
		self.socialCmp:show()
		self.socialCmp:refreshSpeakState()
	end
end

function TeamRoomCtrl:runWithInterceptConfirm(isCaptain, callback)
	local function confirmCallback()
		if self.view then
			callback()
		end
	end

	if self.interceptTipCmp and self.interceptTipCmp:tryShowConfirm(isCaptain, confirmCallback) then
		return
	end

	callback()
end

function TeamRoomCtrl:initView()
	function self.view.recommendEleList.luaRenderItem(button, index, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	function self.view.skillListUList.luaRenderItem(button, index, data)
		local icon = AbilityParamData[data.abilityId].icon

		button:GetChild("IconSkill"):GetComponent("UImage").url = icon
	end

	function self.view.btnConfirmUButton.luaClick()
		local function confirmAction()
			if pg.me:isTeamFull() then
				pg.global.ui.tips:showTextTip(pg.getGameString("SELF_TEAM_FULL"))

				return
			end

			if not self:isPrepareRoom() then
				pg.global.ui:open(UIConst.UI_ID_DUNGEON_INVITE, {
					dungeonId = self:getTeamRoomFrameDungeonId(),
					hardLv = self:getTeamRoomFrameHardLv()
				})
			elseif pg.me:isTeamLeader() then
				pg.me:startTeamDungeon()
			else
				pg.me:prepareTeamDungeon()
			end
		end

		if self:isPrepareRoom() then
			self:runWithInterceptConfirm(pg.me:isTeamLeader(), confirmAction)
		else
			confirmAction()
		end
	end

	self:refreshTeamInfo()
	self:refreshTeamRoomTitle()
end

function TeamRoomCtrl:getTeamInfo()
	return self.model:getTeamInfo()
end

function TeamRoomCtrl:getTeamRoomMemberCount()
	if pg.me:isInTeam() then
		return pg.me:getTeamMemberCount()
	end

	return self.dungeonId and 1 or 0
end

function TeamRoomCtrl:tryPlaySingleToMultiTransition()
	local isInTeam = pg.me:isInTeam()

	if self.lastTeamRoomIsInTeam ~= nil and self.lastTeamRoomIsInTeam ~= isInTeam then
		local rootComponent = self.view and self.view.uIPbTeamRoomUComponent

		if NotNil(rootComponent) and rootComponent:CheckHasEvent(CS.XGUI.EInvokeTime.Custom1) then
			rootComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end

	self.lastTeamRoomIsInTeam = isInTeam
end

function TeamRoomCtrl:playerClickHandle(button, data)
	if not data.empty and data.uid ~= pg.me.uid then
		if pg.game.input:isUsingGamepad() then
			TeamUtils.showPlayerCard(nil, data.uid)

			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local toolTipBtnUButton = objectReference:GetRefValue("toolTipBtnUButton")

		if self.curSelectedBtn then
			self.curSelectedBtn:TryChangePage("Selected", 0)
		end

		button:TryChangePage("Selected", 1)

		self.curSelectedBtn = button

		toolTipBtnUButton:OpenTooltip()
	end
end

function TeamRoomCtrl:getFocusedMemberUid()
	return self.commonCmp and self.commonCmp.focusedMemberUid or nil
end

function TeamRoomCtrl:bindTeamRoomConsoleBarActions()
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickPress, function()
		self:toggleFocusedMemberMute()
	end, self.view.gameObject, "TeamRoomMuteFocusedMember")
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftShoulder, function()
		self:openFocusedPreEquip()
	end, self.view.gameObject, "TeamRoomFocusedPreEquip")
end

function TeamRoomCtrl:toggleFocusedMemberMute()
	local uid = self:getFocusedMemberUid()

	if not uid or uid == pg.me.uid then
		return
	end

	if not pg.game.speech:checkMemberInRoom(pg.me.uid) or not pg.game.speech:checkMemberInRoom(uid) then
		return
	end

	local currentMuted = pg.game.speech:checkMemberMuted(uid)

	pg.game.speech:updateMutedMembers(uid, not currentMuted)
end

function TeamRoomCtrl:openFocusedPreEquip()
	if not self.commonCmp or not self.commonCmp.focusedPreEquip then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
		isDelayShowBlur = true,
		onePlusThreeMode = true,
		tab = 1,
		isPvp = Utils.getPvpMatchMode() == Const.PvpMatchMode.Double,
		closeAction = function()
			return
		end
	})
end

function TeamRoomCtrl:playerRenderFinish()
	if self:isSinglePreviewRoom() then
		self.view.challengeTipUBaseText:SetActive(false)

		return
	end

	local tip = ""
	local canChallenge = true

	if not pg.me:isAllPrepare() then
		canChallenge = false
	end

	if self:isPrepareRoom() then
		local teamMemberCount = pg.me:getTeamMemberCount()

		if teamMemberCount > self.dungeonConfig.playerNumMax or teamMemberCount < self.dungeonConfig.playerNumMin then
			tip = pg.getGameString("NUMBER_NOT_READY")
			canChallenge = false
		end
	end

	self.view.challengeTipUBaseText:SetActive(not canChallenge)
	ClientTextUtils.setText(self.view.challengeTipUBaseText, tip)
end

function TeamRoomCtrl:renderPlayer(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local uINodeTeamRoomCenterItemUComponent = objectReference:GetRefValue("uINodeTeamRoomCenterItemUComponent")
	local listPetInfoUList = objectReference:GetRefValue("listPetInfoUList")
	local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	local topTitleUWidget = objectReference:GetRefValue("topTitleUWidget")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local skillInfoUComponent = objectReference:GetRefValue("skillInfoUComponent")
	local skillObjectReference = skillInfoUComponent:GetComponent("ObjectReference")
	local skillInfoList = skillObjectReference:GetRefValue("skillInfoList")
	local toolTipBtnUButton = objectReference:GetRefValue("toolTipBtnUButton")
	local panelPetInfo = objectReference:GetRefValue("panelPetInfo")
	local infoPetInfo = objectReference:GetRefValue("infoPetInfo")

	panelPetInfo:SetActive(false)
	infoPetInfo:SetActive(false)
	uINodeTeamRoomCenterItemUComponent:TryChangePage("Type", data.empty and 0 or 1)

	if data.empty then
		UICardRenderUtils.renderShowTitle(topTitleUWidget)
		TeamUtils.stopTeamMemberTooltipEffect(toolTipBtnUButton)

		toolTipBtnUButton.luaNavFocused = nil
		toolTipBtnUButton.luaNavUnfocused = nil

		return
	end

	objectReference:GetRefValue("btnVoiceUButton"):SetHotkeyConsoleBar("CONSOLE_BAR_MUTE_VOICE", -99)

	function toolTipBtnUButton.luaNavFocused()
		TeamUtils.playTeamMemberTooltipEffect(toolTipBtnUButton, data.uid)

		if self.commonCmp then
			self.commonCmp:onMemberNavFocused(data.uid, idx)
		end
	end

	function toolTipBtnUButton.luaNavUnfocused()
		TeamUtils.stopTeamMemberTooltipEffect(toolTipBtnUButton)

		if self.commonCmp then
			self.commonCmp:onMemberNavUnfocused()
		end
	end

	if self.dungeonConfig then
		local teamInfo = self:getTeamInfo()

		function btnSwitchUButton.luaClick()
			if pg.me:isUidPrepare(pg.me.uid) and not pg.me:isTeamLeader() then
				pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ALREADY_PREPARE"))

				return
			end

			pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT)
		end
	end

	TeamUtils.handleTeamMemberTooltip(toolTipBtnUButton, data.uid, button, true)

	local teamInfo = self:getTeamInfo()
	local memberInfo = teamInfo.membersInfo[data.uid]
	local playerName = memberInfo.playerName
	local _h = TeamRoomCtrl._platformHooks

	if _h and _h.getRenderPlayerName then
		local hookedName = _h.getRenderPlayerName(self, data, memberInfo, playerName)

		if type(hookedName) == "string" then
			playerName = hookedName
		end
	end

	ClientTextUtils.setText(playerNameUBaseText, playerName)
	UICardRenderUtils.renderShowTitle(topTitleUWidget, memberInfo.showTitles, memberInfo.showTitleExtra, memberInfo.isWholeTitle)

	if _h and _h.renderPlayerOnlineID then
		_h.renderPlayerOnlineID(self, objectReference, data, memberInfo)
	end

	if pg.me:isUidTeamLeader(data.uid) then
		self.oldTeamLeader = data.uid

		uINodeTeamRoomCenterItemUComponent:TryChangePage("MemberState", 0)
	elseif not self:isPrepareRoom() then
		uINodeTeamRoomCenterItemUComponent:TryChangePage("MemberState", 3)
	else
		local isPrepare = teamInfo.prepareInfos[data.uid] and teamInfo.prepareInfos[data.uid].isPrepare

		if isPrepare then
			if self.oldPrepareInfos[data.uid] == false and self.uiScene then
				self.uiScene:onPlayerReady(data.uid)
			end

			uINodeTeamRoomCenterItemUComponent:TryChangePage("MemberState", 2)
		else
			if self.oldPrepareInfos[data.uid] == true and self.uiScene then
				self.uiScene:onPlayerUnReady(data.uid)
			end

			uINodeTeamRoomCenterItemUComponent:TryChangePage("MemberState", 1)
		end

		self.oldPrepareInfos[data.uid] = isPrepare
	end

	function skillInfoList.luaRenderItem(button, index, data)
		local icon = AbilityParamData[data.abilityId].icon

		button:GetChild("IconSkill"):GetComponent("UImage").url = icon

		button:TryChangePage("Equiped", data.equiped and 0 or 1)
	end

	local skillLimit = self.dungeonConfig and self.dungeonConfig.skillLimit or {}
	local showSkillLimit = #skillLimit > 0

	skillInfoUComponent:SetActive(showSkillLimit)
	skillInfoUComponent:TryChangePage("Change", data.uid == pg.me.uid and 0 or 1)

	local membersInfo = self:getTeamInfo().membersInfo

	if showSkillLimit then
		local limitData = {}
		local exploreAbilityIds = membersInfo[data.uid].exploreAbilityIds

		self.oldSkillInfoLists[data.uid] = exploreAbilityIds

		for _, abilityId in ipairs(skillLimit) do
			local equiped = table.contains(exploreAbilityIds, abilityId)

			self.equipedSkill = self.equipedSkill and equiped

			table.insert(limitData, {
				tIndex = 0,
				abilityId = abilityId,
				equiped = equiped
			})
		end

		skillInfoList:SetList(limitData)
	end

	local takePet = false

	button:TryChangePage("Pet", takePet and 0 or 1)
	button:TryChangePage("Belong", data.uid == pg.me.uid and 0 or 1)

	if takePet then
		local petInfoList = teamInfo.prepareInfos[data.uid].petInfoList

		self.oldPetInfoLists[data.uid] = petInfoList

		function listPetInfoUList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local petNameUBaseText = objectReference:GetRefValue("petNameUBaseText")
			local elementUButton = objectReference:GetRefValue("elementUButton")
			local doubleElement1UButton = objectReference:GetRefValue("doubleElement1UButton")
			local doubleElement2UButton = objectReference:GetRefValue("doubleElement2UButton")
			local txtLvNumUBaseText = objectReference:GetRefValue("txtLvNumUBaseText")
			local txtCpNumUBaseText = objectReference:GetRefValue("txtCpNumUBaseText")
			local uINodeTeamRoomPetInfoUComponent = objectReference:GetRefValue("uINodeTeamRoomPetInfoUComponent")
			local nameChange1UBaseText = objectReference:GetRefValue("nameChange1UBaseText")
			local nameChange2UBaseText = objectReference:GetRefValue("nameChange2UBaseText")
			local isBoss = Utils.isLabelElite(data.label)
			local isShiny = Utils.isLabelShiny(data.label)
			local isVariant = Utils.isLabelVariant(data.label)

			button:TryChangePage("isFlash", isShiny and 1 or 0)
			PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)
			button:TryChangePage("isChange", isVariant and 1 or 0)

			local cData = PetData[data.templateId]
			local petName = pg.getLocalizationText(cData.name)

			ClientTextUtils.setText(petNameUBaseText, petName)
			ClientTextUtils.setText(nameChange1UBaseText, petName)
			ClientTextUtils.setText(nameChange2UBaseText, petName)
			ClientTextUtils.setText(txtLvNumUBaseText, data.level)
			ClientTextUtils.setText(txtCpNumUBaseText, data.cp or 0)

			local elementIds, elementNames = LuaUIUtils.getElementInfo(cData.elementType)

			uINodeTeamRoomPetInfoUComponent:TryChangePage("ElementDouble", #elementNames > 1 and 1 or 0)
			LuaUIUtils.setElementButtonNew(elementUButton, elementNames[1].element)

			if elementNames[2] then
				LuaUIUtils.setElementButtonNew(doubleElement1UButton, elementNames[1].element)
				LuaUIUtils.setElementButtonNew(doubleElement2UButton, elementNames[2].element)
			end
		end

		listPetInfoUList:SetList(petInfoList)
	end

	pg.game.speech:handlePlayerVoiceState(button, data)
end

function TeamRoomCtrl:refreshTeamPlayerInfo()
	ClientTextUtils.setText(self.view.dungeonName1UBaseText, pg.getGameString("TEAM_PANEL_TITLE"))
end

function TeamRoomCtrl:isPrepareRoom()
	return pg.me:isInPreparingRoom()
end

function TeamRoomCtrl:refreshTeamRoomTitle()
	if not self.view then
		return
	end

	ClientTextUtils.setText(self.view.dungeonName1UBaseText, pg.getGameString("TEAM_PANEL_TITLE"))
end

function TeamRoomCtrl:refreshDungeonTeamInfo()
	self:closePanel()
	pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
end

function TeamRoomCtrl:refreshBtnState()
	if self:isInTeamDungeonRoom() then
		self.view.btnConfirmUButton:SetActive(false)
		self.view.btnCancelUButton:SetActive(false)
		self.view.btnReleaseUButton:SetActive(false)
		self.view.btnCancelMatchUButton:SetActive(false)
		self.view.btnReleaseUButton2:SetActive(false)
		self.view.challengeTipUBaseText:SetActive(false)

		return
	end

	if self.matchCom or self.dungeonId then
		self.view.btnConfirmUButton:SetActive(false)
		self.view.btnCancelUButton:SetActive(false)
		self.view.challengeTipUBaseText:SetActive(false)

		return
	end

	local isTeamLeader = pg.me:isTeamLeader()

	if not self:isPrepareRoom() then
		if isTeamLeader then
			self.view.btnConfirmUButton:TryChangePage("button", pg.me:isTeamFull() and 4 or 0)
			self.view.btnConfirmUButton:SetActive(true)
			ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TEAM_INVITE"))
		else
			self.view.btnConfirmUButton:SetActive(false)
		end
	elseif isTeamLeader then
		self.view.btnConfirmUButton:TryChangePage("button", pg.me:isAllPrepare() and 0 or 4)

		local canChallenge = pg.me:isAllPrepare() and true or false

		self.view.btnConfirmUButton.visualInteractable = canChallenge

		ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TEAM_START_CHALLENGE"))
		ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("CANCEL_APPLY"))
		self.view.btnCancelUButton:SetActive(false)
		self.view.btnConfirmUButton:SetActive(true)
	else
		local isSelfPrepare = pg.me:isUidPrepare(pg.me.uid)

		self.view.btnConfirmUButton:SetActive(not isSelfPrepare and not pg.game.input:isUsingGamepad())
		self.view.btnCancelUButton:SetActive(isSelfPrepare)

		self.view.btnConfirmUButton.visualInteractable = true

		ClientTextUtils.setText(self.view.btnConfirmUText, pg.getGameString("TEAM_READY"))
		ClientTextUtils.setText(self.view.btnCancelUText, pg.getGameString("TEAM_CANCEL_READY"))
		ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("LEAVE_TEAM"))
	end

	self.view.challengeTipUBaseText:SetActive(pg.me:isTeamLeader())
end

function TeamRoomCtrl:checkPlayerInfoUpdate(oldData, newData)
	local teamInfo = self:getTeamInfo()

	for i = 1, #newData do
		if oldData.Count ~= #newData then
			return true
		end

		if teamInfo.leaderUid ~= self.oldTeamLeader then
			return true
		end

		local oldUid = oldData[i - 1].uid
		local newUid = newData[i].uid

		if oldUid ~= newUid then
			return true
		elseif newUid then
			local takePet = self.dungeonConfig and self.dungeonConfig.petOrNot == 1

			if takePet then
				local newPetInfo = teamInfo.prepareInfos[newUid].petInfoList
				local oldPetInfo = self.oldPetInfoLists[oldUid]

				if #newPetInfo ~= #oldPetInfo then
					return true
				end

				for j = 1, #oldPetInfo do
					if oldPetInfo[j].templateId ~= newPetInfo[j].templateId then
						return true
					end
				end
			end

			local oldSkillInfo = self.oldSkillInfoLists[oldUid] or {}
			local newSkillInfo = teamInfo.membersInfo[newUid].exploreAbilityIds or {}

			if #oldSkillInfo ~= #newSkillInfo then
				return true
			end

			for k = 1, #oldSkillInfo do
				if oldSkillInfo[k] ~= newSkillInfo[k] then
					return true
				end
			end

			if teamInfo.prepareInfos[newUid].isPrepare ~= self.oldPrepareInfos[oldUid] then
				return true
			end
		end
	end

	return false
end

function TeamRoomCtrl:onPetFormationUpdate()
	if self.uiScene and pg.me:isTeamLeader() then
		pg.me:prepareTeamDungeon()
	end
end

function TeamRoomCtrl:enterDungeon()
	self.isEnterDungeon = true

	self:closePanel()
end

function TeamRoomCtrl:teamConfirmFail()
	self:closePanel()
end

function TeamRoomCtrl:closeUI()
	self:closePanel()
end

function TeamRoomCtrl:closePanel()
	self:close()
end

function TeamRoomCtrl:refreshTeamInfo()
	local matching = self:isTeamMatching()
	local isPrepareRoom = self:isPrepareRoom()

	self.dungeonSceneId = nil
	self.dungeonConfig = nil

	local dungeonSceneId

	if matching then
		dungeonSceneId = pg.me:getMatchDungeonId()
		self.dungeonConfig = self.model:getDungeonConfig(dungeonSceneId)
	else
		self.dungeonSceneId = pg.me:getCurTeamInfo().dungeonSceneId
		dungeonSceneId = self.dungeonSceneId
		self.dungeonConfig = self.model:getDungeonConfig(dungeonSceneId)
	end

	self.model:setDungeonInfo(dungeonSceneId or 0, pg.me:getCurTeamInfo().hardLv or 0)

	local teamInfo = self:getTeamInfo()

	if self.dungeonConfig then
		-- block empty
	else
		self:refreshTeamPlayerInfo()
		self.view.challengeTipUBaseText:SetActive(false)
	end

	self.uiScene.dungeonConfig = self.dungeonConfig
	self.uiScene.teamInfo = teamInfo

	self:refreshTeamRoomFrameState()
	self:refreshTeamRoomSocialComponent()
	self:refreshTeamRoomTitle()
	self:refreshTeamMemberContainer()
	self:tryPlaySingleToMultiTransition()
	self.uiScene:refreshModels()
end

function TeamRoomCtrl:onTeamMatchedStatusChange()
	if self.view.memberContainerCount then
		self:refreshTeamMembers()
	end
end

function TeamRoomCtrl:refreshTeamMemberContainer()
	local memberCount = self.model:getMemberContainerCount(self.dungeonConfig)

	if self.view.memberContainerCount == memberCount then
		self:refreshTeamMembers()

		return
	end

	if self.view.loadingMemberContainerCount == memberCount then
		return
	end

	self.view:loadTeamMemberContainer(memberCount, function()
		if self.commonCmp then
			self.commonCmp:bindPanelTeamConsoleBar()
		else
			self:initCommonComponent()
		end

		self:refreshTeamMembers()
	end)
end

function TeamRoomCtrl:renderPreEquipPlayer(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local uINodeTeamRoomCenterItemUComponent = objectReference:GetRefValue("uINodeTeamRoomCenterItemUComponent")
	local panelPetInfo = objectReference:GetRefValue("panelPetInfo")
	local infoPetInfo = objectReference:GetRefValue("infoPetInfo")
	local toolTipBtnUButton = objectReference:GetRefValue("toolTipBtnUButton")

	panelPetInfo:SetActive(true)
	infoPetInfo:SetActive(false)
	uINodeTeamRoomCenterItemUComponent:TryChangePage("Type", data.empty and 0 or 1)

	if data.empty then
		TeamUtils.stopTeamMemberTooltipEffect(toolTipBtnUButton)

		toolTipBtnUButton.luaNavFocused = nil
		toolTipBtnUButton.luaNavUnfocused = nil

		return
	end

	objectReference:GetRefValue("btnVoiceUButton"):SetHotkeyConsoleBar("CONSOLE_BAR_MUTE_VOICE", -99)

	function data.switchPetsFunc()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
			isDelayShowBlur = true,
			onePlusThreeMode = true,
			tab = 1,
			isPvp = Utils.getPvpMatchMode() == Const.PvpMatchMode.Double,
			closeAction = function()
				return
			end
		})
	end

	function data.onNavFocused(uid)
		if self.commonCmp then
			self.commonCmp:onMemberNavFocused(uid, idx, uid == pg.me.uid)
		end
	end

	function data.onNavUnfocused()
		if self.commonCmp then
			self.commonCmp:onMemberNavUnfocused()
		end
	end

	UICardRenderUtils.render1Plus3RoomCard(button, data)
end

function TeamRoomCtrl:renderEmptyPlayer(button)
	local objectReference = button:GetComponent("ObjectReference")
	local uINodeTeamRoomCenterItemUComponent = objectReference:GetRefValue("uINodeTeamRoomCenterItemUComponent")
	local inviteUButton = objectReference:GetRefValue("inviteUButton")
	local toolTipBtnUButton = objectReference:GetRefValue("toolTipBtnUButton")

	uINodeTeamRoomCenterItemUComponent:TryChangePage("Type", 0)

	local canInvite = true

	if pg.global.ui.tips and pg.global.ui.tips.teamMatchTip and pg.global.ui.tips.teamMatchTip.isCountDownPlaying then
		canInvite = false
	elseif pg.me.matchState ~= Const.PLAYER_MATCH_STATUS.IDLE then
		canInvite = false
	elseif pg.me:isInTeamDungeonScene() then
		canInvite = false
	end

	button:TryChangePage("PlayerState", canInvite and 2 or 1)
	TeamUtils.handleTeamMemberTooltip(toolTipBtnUButton, nil, button, false)

	if inviteUButton then
		function inviteUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_DUNGEON_INVITE, {
				dungeonId = self:getTeamRoomFrameDungeonId(),
				hardLv = self:getTeamRoomFrameHardLv()
			})
		end

		function inviteUButton.luaNavFocused()
			if self.commonCmp then
				self.commonCmp:onInviteNavFocused()
			end
		end

		function inviteUButton.luaNavUnfocused()
			if self.commonCmp then
				self.commonCmp:clearFocusConsoleBarState()
			end
		end
	end

	toolTipBtnUButton.luaNavFocused = nil
	toolTipBtnUButton.luaNavUnfocused = nil
end

function TeamRoomCtrl:refreshTeamMembers()
	local needPreEquip = self.model:needPreEquip(self.dungeonConfig) and not self:isInTeamDungeonRoom()
	local data = needPreEquip and self.model:getPreEquipMemberRenderData(self.dungeonConfig) or self.model:getTeamMemberRenderData(self.dungeonConfig)
	local orderButtons = self.view:getTeamMemberButtons()
	local maxMemberCount = self.dungeonConfig and self.dungeonConfig.playerNumMax or #orderButtons
	local teamState = pg.me:isInTeam() and 0 or 1

	self.equipedSkill = true

	for i, button in ipairs(orderButtons) do
		local playerInfo = data[i]
		local visible = i <= maxMemberCount and (pg.me:isInTeam() or not playerInfo.empty)

		button:SetActive(visible)

		if visible then
			button:TryChangePage("Team", teamState)
			button:TryChangePage("Position", i - 1)

			if not playerInfo.empty then
				button:TryChangePage("PlayerState", 0)

				if needPreEquip then
					self:renderPreEquipPlayer(button, i, playerInfo)
				else
					self:renderPlayer(button, i, playerInfo)
				end

				function button.luaClick()
					self:playerClickHandle(button, playerInfo)
				end
			else
				self:renderEmptyPlayer(button)

				button.luaClick = nil
			end
		end
	end

	self:playerRenderFinish()
end

function TeamRoomCtrl:onDestroy()
	self.oldPetInfoLists = {}
	self.oldPrepareInfos = {}
	self.oldSkillInfoLists = {}
	self.oldTeamLeader = nil
	self.lastTeamRoomMemberCount = nil
	self.isEnterDungeon = nil

	UICtrl.onDestroy(self)
end

function TeamRoomCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TeamRoomCtrl:onShow()
	return
end

function TeamRoomCtrl:onHide()
	return
end

function TeamRoomCtrl:onVisibleChange(visible)
	if self.uiScene then
		self.uiScene:setAllModelVisible(visible)

		if visible then
			self.uiScene:playWaitShowEffect()
		end
	end
end

return TeamRoomCtrl
