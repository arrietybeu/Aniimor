-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\TeamUIComponent.lua

local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local RoguelikeData = require("Data.roguelike_data")
local LevelConditionData = require("Data.level_condition_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SceneData = require("Data.scene_data")
local Const = require("Common.Const.Const")
local TeamUtils = require("Utils.TeamUtils")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local LevelData = require("Data.level_data")
local SysConfigData = require("Data.sys_config_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local AudioConst = require("Const.AudioConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TeamUIComponent = Class.LightClass("TeamUIComponent", HudBaseComponent)

TeamUIComponent.CANCEL_LONG_PRESS_START_TIME = 0.25
TeamUIComponent.CANCEL_LONG_PRESS_DURATION = 0.55
TeamUIComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged"
	},
	[MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE] = {
		"refreshSpeechState"
	},
	[MessageName.TEAM_MATCHED_STATUS_CHANGE] = {
		"onTeamMatchedStatusChange"
	},
	[MessageName.EGG_MATCH_STATE_CHANGE] = {
		"onTeamMatchedStatusChange"
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"onTeamInfoChanged"
	},
	[MessageName.TEAM_ENTER_DUNGEON] = {
		"onTeamInfoChanged"
	},
	[MessageName.TEAM_PLAYER_STATE_CHANGED] = {
		"refreshMemberState"
	},
	[MessageName.TEAM_PLAYER_HP_CHANGED] = {
		"refreshMemberHp"
	},
	[MessageName.TEAM_PLAYER_MAX_HP_CHANGED] = {
		"refreshMemberMaxHp"
	},
	[MessageName.TEAM_PET_HP_CHANGED] = {
		"onTeamPetHpChanged"
	},
	[MessageName.TEAM_PET_MAX_HP_CHANGED] = {
		"onTeamPetMaxHpChanged"
	},
	[MessageName.CUR_COMBAT_PET_CHANGED] = {
		"onCurCombatPetChanged"
	},
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"onSpaceFollowInfoChanged"
	},
	[MessageName.GRAB_EGG_DUNGEON_TEAM_READY] = {
		"onGrabEggTeamReady"
	},
	[MessageName.FIRST_ENTER_TEAM] = {
		"handleFirstEnterTeam"
	},
	[MessageName.LEAVE_TEAM] = {
		"handleLeaveTeam"
	},
	[MessageName.TEAM_MATCH_START_TIME_CHANGE] = {
		"refreshTeamMatchStartTime"
	}
}

function TeamUIComponent:onCtor(info)
	self.extraTeamInfo = {}
	self.teamListData = nil
end

function TeamUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnTeam = objectReference:GetRefValue("btnTeam")
	self.txtTeamNum = objectReference:GetRefValue("txtTeamNum")
	self.teamList = objectReference:GetRefValue("teamList")
	self.matchUCountDown = objectReference:GetRefValue("matchUCountDown")
	self.txtMatching = objectReference:GetRefValue("txtMatching")
	self.cancelUWidget = objectReference:GetRefValue("cancelUWidget")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
end

function TeamUIComponent:initView()
	function self.teamList.luaRenderItem(button, index, data)
		self:renderTeamItem(button, index, data)
	end

	function self.btnTeam.luaClick()
		pg.me:tryEnterPrepRoom(true)
	end

	function self.btnCancelUButton.luaClick()
		self:cancelTeamMatching()
	end

	self:initCancelLongPressKey(self.btnCancelUButton)
	self:bindHotKeyPerform("Hud/OpenTeam", function()
		self.btnTeam:OnClickSimulate()
	end, self.btnTeam.gameObject)
	self:onTeamMatchedStatusChange()
	self:bindSpeechEvent()
end

function TeamUIComponent:getCancelLongPressProgress(pressTime)
	local startTime = self.CANCEL_LONG_PRESS_START_TIME
	local duration = self.CANCEL_LONG_PRESS_DURATION

	return math.min(math.max((pressTime - startTime) / (duration - startTime), 0), 1)
end

function TeamUIComponent:resetCancelLongPress()
	if self.cancelPressTimer then
		self:killTimer(self.cancelPressTimer)

		self.cancelPressTimer = nil
	end

	self.cancelPressTime = 0

	if self.cancelProgress then
		self.cancelProgress:ProgressToValue(0, nil, 0)
	end
end

function TeamUIComponent:initCancelLongPressKey(button)
	local cancelKeyUContainer = button:GetComponent("ObjectReference"):GetRefValue("keyUContainer")

	if not cancelKeyUContainer then
		return
	end

	self.cancelKeyPath = "Hud/ExitDungeon"

	local keyContent = cancelKeyUContainer.transform:GetComponent("HotKeyContent")

	keyContent:SetHotKeyPaths(self.cancelKeyPath)
	LuaUIUtils.waitHotKeyContentObjectReference(self, keyContent, function(objectReference)
		self:initCancelLongPressProgress(objectReference)
	end)
end

function TeamUIComponent:initCancelLongPressProgress(objectReference)
	self.cancelProgressContainer = objectReference:GetRefValue("progressPressContainerUContainer")

	if not self.cancelProgressContainer then
		return
	end

	self.cancelProgressContainer:SetActive(true)
	self.cancelProgressContainer:LoadDefaultUrlManually(function()
		self.cancelProgress = self.cancelProgressContainer.content

		if self.cancelProgress then
			self.cancelProgress.gameObject:SetActiveEx(true)
			self.cancelProgress:ProgressToValue(0, nil, 0)
		end

		local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCancelUButton.gameObject, self.cancelKeyPath)

		hotKeyBind.isVirtual = true
		hotKeyBind.priority = -1
		hotKeyBind.actionPath = self.cancelKeyPath

		function hotKeyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self:resetCancelLongPress()

				self.cancelPressTimer = self:startTimer(function()
					if self.cancelPressTime >= self.CANCEL_LONG_PRESS_DURATION then
						return
					end

					self.cancelPressTime = self.cancelPressTime + Time.unscaledDeltaTime

					if self.cancelProgress and self.cancelPressTime > self.CANCEL_LONG_PRESS_START_TIME then
						self.cancelProgress:ProgressToValue(self:getCancelLongPressProgress(self.cancelPressTime), nil, 0)
					end

					if self.cancelPressTime >= self.CANCEL_LONG_PRESS_DURATION then
						self:cancelTeamMatching()
						self:resetCancelLongPress()
					end
				end, 0, true)
			elseif inputInfo.phase == "Canceled" then
				if self.cancelPressTimer and self.cancelPressTime <= self.CANCEL_LONG_PRESS_START_TIME then
					pg.game.input:triggerWaitAction(inputInfo.inputControl, {
						self.cancelKeyPath
					})
				end

				self:resetCancelLongPress()
			end
		end
	end)
end

function TeamUIComponent:onInputDeviceChanged()
	if self.cancelProgress then
		self.cancelProgress:ProgressToValue(0, nil, 0)
	end
end

function TeamUIComponent:bindSpeechEvent()
	pg.game.speech:bindJoinSpeech(self.transform.gameObject)
	pg.game.speech:bindManualPushTalk(self.transform.gameObject)
end

function TeamUIComponent:onTeamInfoReady()
	local isShow = self:setShowView()

	if not isShow then
		return
	end

	self:refreshTeamInfo()
end

function TeamUIComponent:onTeamInfoChanged()
	local isShow = self:setShowView()

	if not isShow then
		return
	end

	self:refreshTeamInfo()
end

function TeamUIComponent:refreshTeamInfo()
	if not self.transform then
		return
	end

	self:refreshTeamMemberCount()

	self.teamListData = self:parseTeamInfo()

	self.teamList:SetList(self.teamListData)
end

function TeamUIComponent:parseTeamInfo()
	local teamInfo = pg.me:getShowTeamInfo()

	if not teamInfo or not teamInfo.sortList then
		return {}
	end

	local res = {}

	for i, uid in ipairs(teamInfo.sortList) do
		if uid ~= pg.me.uid then
			table.insert(res, {
				order = i,
				uid = uid
			})
		end
	end

	return res
end

function TeamUIComponent:refreshTeamMemberCount()
	if not self.transform then
		return
	end

	if not pg.me then
		return
	end

	local memberCount = pg.me:getTeamMemberCount()

	if memberCount > 0 then
		ClientTextUtils.setText(self.txtTeamNum, memberCount, "/", SysConfigData.MAX_PLAYER_NUM)
		self.rootComponent:TryChangePage("Follow", memberCount == 1 and 2 or 0)
	end
end

function TeamUIComponent:setExtraTeamInfo(uid, key, value)
	if not self.extraTeamInfo[uid] then
		self.extraTeamInfo[uid] = {}
	end

	if value then
		self.extraTeamInfo[uid][key] = value
	end
end

function TeamUIComponent:setShowView()
	if pg.space and pg.space:isNpcDuel() then
		self:hide()

		return false
	elseif pg.me:isInTeam() or pg.me:isInMatching() then
		self:show()
	else
		self:hide()

		return false
	end

	return true
end

function TeamUIComponent:onTeamMatchedStatusChange()
	self:setShowView()

	if not self.transform then
		return
	end

	local matchState = pg.me.matchState
	local inTeamMatching = false

	if matchState == Const.PLAYER_MATCH_STATUS.MATCH_TEAM or matchState == Const.PLAYER_MATCH_STATUS.MATCH_DUNGEON then
		inTeamMatching = true
	end

	local startTs = Time.secondCache

	if inTeamMatching then
		startTs = pg.me.matchStartTime
	end

	self.cancelUWidget.gameObject:SetActiveEx(inTeamMatching)

	if inTeamMatching then
		self.btnTeam:TryChangePage("Status", 1)

		local memberCount = pg.me:getTeamMemberCount()

		self.txtMatching.gameObject:SetActiveEx(memberCount <= 1)
	else
		self.btnTeam:TryChangePage("Status", 0)
		self.txtMatching.gameObject:SetActiveEx(false)
	end

	self:refreshTeamMatchStartTime()
end

function TeamUIComponent:refreshTeamMatchStartTime()
	if pg.me.matchStartTime == 0 then
		self.matchUCountDown:Stop()

		return
	end

	self.matchUCountDown.positiveTiming = true

	self.matchUCountDown:Play(math.max(0, Time.secondCache - pg.me.matchStartTime), 3600)
end

function TeamUIComponent:refreshMemberHp(info)
	if self.teamListData == nil then
		return
	end

	local uid = info.uid
	local hp = info.hp

	for i, v in ipairs(self.teamListData) do
		if v.uid == uid then
			v.hp = hp

			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:refreshMemberMaxHp(info)
	if self.teamListData == nil then
		return
	end

	local uid = info.uid
	local maxHp = info.maxHp

	for i, v in ipairs(self.teamListData) do
		if v.uid == uid then
			v.maxHp = maxHp

			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:refreshMemberState(info)
	if self.teamListData == nil then
		return
	end

	local uid = info.uid
	local state = info.state

	self:setExtraTeamInfo(uid, "state", state)

	for i, v in ipairs(self.teamListData) do
		if v.uid == uid then
			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:onTeamPetHpChanged(info)
	if self.teamListData == nil then
		return
	end

	self:setExtraTeamInfo(info.uid, "curHp", info.curHp)
	self:setExtraTeamInfo(info.uid, "maxHp", info.maxHp)

	for i, v in ipairs(self.teamListData) do
		if v.uid == info.uid then
			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:onTeamPetMaxHpChanged(info)
	self:onTeamPetHpChanged(info)
end

function TeamUIComponent:onCurCombatPetChanged(info)
	if self.teamListData == nil then
		return
	end

	self:setExtraTeamInfo(info.uid, "petTemplateId", info.petTemplateId)
	self:setExtraTeamInfo(info.uid, "petLabel", info.petLabel)

	for i, v in ipairs(self.teamListData) do
		if v.uid == info.uid then
			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:refreshTeamMemberInfo(uid)
	if self.teamListData == nil then
		return
	end

	for i, v in ipairs(self.teamListData) do
		if v.uid == uid then
			self.teamList:RefreshElement(i - 1)

			break
		end
	end
end

function TeamUIComponent:onSpaceFollowInfoChanged(info)
	self:refreshTeamInfo()
	self.ctrl:setSceneType()
end

function TeamUIComponent:onGrabEggTeamReady(teamInfo)
	self:onTeamInfoReady()
	self.ctrl:setSceneType()
end

function TeamUIComponent:renderTeamItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petBig1UImage = objectReference:GetRefValue("petBig1UImage")
	local hPUHealthbar = objectReference:GetRefValue("hPUHealthbar")
	local voiceChatUWidget = objectReference:GetRefValue("voiceChatUWidget")
	local teamInfo = pg.me:getShowTeamInfo()
	local sMember = teamInfo.membersInfo[data.uid] or {}
	local isLeader = data.uid == teamInfo.leaderUid
	local isSelf = data.uid == pg.me.uid
	local online = sMember.online
	local entityId = sMember.entityId
	local playerEntity = pg.getEntity(entityId) or pg.getEntityByUid(data.uid)
	local extraInfo = self.extraTeamInfo[data.uid]
	local state = extraInfo and extraInfo.state

	if playerEntity and playerEntity.life then
		state = playerEntity.life

		self:setExtraTeamInfo(data.uid, "state", state)
	end

	state = state or Const.LIFE_ALIVE

	local url = PlayerHeadIconData[sMember.headIcon or 1].res
	local hp = extraInfo and extraInfo.curHp or data.curHp
	local maxHp = extraInfo and extraInfo.maxHp or data.maxHp
	local petTemplateId = extraInfo and extraInfo.petTemplateId
	local petLabel = extraInfo and extraInfo.petLabel
	local curPetEntity = playerEntity and playerEntity:getCurPetEntity()

	if curPetEntity then
		if hp == nil then
			hp = curPetEntity.curHp

			self:setExtraTeamInfo(data.uid, "curHp", hp)
		end

		if maxHp == nil then
			maxHp = curPetEntity.maxHp

			self:setExtraTeamInfo(data.uid, "maxHp", maxHp)
		end

		if petTemplateId == nil then
			petTemplateId = curPetEntity.templateId

			self:setExtraTeamInfo(data.uid, "petTemplateId", petTemplateId)
		end

		if petLabel == nil then
			petLabel = curPetEntity.label

			self:setExtraTeamInfo(data.uid, "petLabel", petLabel)
		end
	elseif playerEntity then
		if hp == nil then
			hp = playerEntity.curHp

			self:setExtraTeamInfo(data.uid, "curHp", hp)
		end

		if maxHp == nil then
			maxHp = playerEntity.maxHp

			self:setExtraTeamInfo(data.uid, "maxHp", maxHp)
		end
	end

	local showPetInfo = false

	if petTemplateId and petTemplateId ~= 0 then
		url = LuaUIUtils.getPetIconByTemplateId(petTemplateId, LuaUIUtils.PET_ICON, petLabel)
		showPetInfo = true
	end

	petBig1UImage.url = url

	hPUHealthbar:SetActive(showPetInfo and state == Const.LIFE_ALIVE)
	button:TryChangePage("Teammate", data.order - 1)
	button:TryChangePage("Captain", isLeader and 1 or 0)
	button:TryChangePage("TeamMember", isSelf and 1 or 0)
	button:TryChangePage("Status", online and 0 or 2)

	if state == Const.LIFE_ALIVE then
		button:TryChangePage("TeamState", 0)
	elseif state == Const.LIFE_FAKE_DEAD then
		button:TryChangePage("TeamState", 1)
	elseif state == Const.LIFE_FALLEN then
		button:TryChangePage("TeamState", 2)
	elseif state == Const.LIFE_DEAD then
		button:TryChangePage("TeamState", 3)
	end

	if maxHp and hp then
		hPUHealthbar.maxHp = maxHp

		hPUHealthbar:ProgressHp(hp)
	end

	self:refreshTeamItemSpeechState(button, data.uid, voiceChatUWidget)
	TeamUtils.handleTeamMemberTooltip(button, data.uid)

	if pg.me.space then
		if pg.me:getTeamMemberCount() <= 1 then
			button:TryChangePage("Follow", 2)
		else
			local myLeader = pg.me.space:getSpaceFollowLeader(pg.me.uid)
			local playerLeader = pg.me.space:getSpaceFollowLeader(data.uid)
			local isSpaceFollowing = not string.isNilOrEmpty(myLeader) and not string.isNilOrEmpty(playerLeader) and myLeader == playerLeader

			button:TryChangePage("Follow", isSpaceFollowing and 1 or 0)
		end
	end
end

function TeamUIComponent:refreshSpeechState()
	if not self.teamListData then
		return
	end

	for i, memberData in ipairs(self.teamListData) do
		local isExist, button = self.teamList:TryGetChildAt(i - 1)

		if isExist and button then
			self:refreshTeamItemSpeechState(button, memberData.uid)
		end
	end
end

function TeamUIComponent:refreshTeamItemSpeechState(button, uid, voiceChatUWidget)
	if not voiceChatUWidget then
		local objectReference = button:GetComponent("ObjectReference")

		voiceChatUWidget = objectReference:GetRefValue("voiceChatUWidget")
	end

	local isSpeaking = pg.game.speech:checkMemberSpeakingVisible(uid)

	voiceChatUWidget:SetActive(isSpeaking)
end

function TeamUIComponent:handleFirstEnterTeam()
	self:tryAutoJoinTeamSpeech()

	if pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList then
		pg.global.ui.hudV2.RM.petList:refreshQuickSwitchPetTeamVisible()
	end

	pg.global.ui.tips:refreshShortCutKey()
end

function TeamUIComponent:tryAutoJoinTeamSpeech()
	if pg.me:isInTeam() and not pg.game.speech:checkMemberInRoom(pg.me.uid) then
		if pg.game.setting:getTeamSpeechAutoEnter() then
			pg.me:joinSpeechChannel()
		else
			pg.game.audio:playEvent(AudioConst.EVENT_TEAM_SPEECH_CREATE)
			pg.global.ui.tips:refreshHotKeyHint(true)

			if pg.global.ui:runPlatformByMobile() then
				pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_SPEECH_TIP_MOBILE"))
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_SPEECH_TIP"))
			end
		end
	end
end

function TeamUIComponent:handleLeaveTeam()
	if pg.global.ui.hudV2.RM and pg.global.ui.hudV2.RM.petList then
		pg.global.ui.hudV2.RM.petList:refreshQuickSwitchPetTeamVisible()
	end

	pg.global.ui.tips:refreshShortCutKey()
end

function TeamUIComponent:cancelTeamMatching()
	if pg.me:isInEggMatching() and pg.me:isInSingleTeam() then
		pg.me:disbandTeam()

		return
	end

	pg.me:cancelTeamMatching()
end

function TeamUIComponent:onDestroy()
	self:resetCancelLongPress()
end

return TeamUIComponent
