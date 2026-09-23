-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoom\\Component\\TeamRoomSocialComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AppearanceAction = require("Data.appearance_action_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local TeamRoomSocialComponent = Class.LightClass("TeamRoomSocialComponent", UIComponent)

TeamRoomSocialComponent.messages = {
	[MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE] = {
		"onSpeechRoomMemberStateChange",
		true
	},
	[MessageName.SPEECH_ROOM_STATE_CHANGE] = {
		"refreshBtnVoiceState",
		true
	}
}

function TeamRoomSocialComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnChat = objectReference:GetRefValue("btnChat")
	self.action = objectReference:GetRefValue("action")
	self.btnFold = objectReference:GetRefValue("btnFold")
	self.btnDefaultAction = objectReference:GetRefValue("btnDefaultEmoji")
	self.btnUnfold = objectReference:GetRefValue("btnUnFold")
	self.actionList = objectReference:GetRefValue("actionList")
	self.btnVoice = objectReference:GetRefValue("btnListenUButton")
	self.btnSpeak = objectReference:GetRefValue("btnVoiceUButton")
	self.chatUComponent = objectReference:GetRefValue("chatUComponent")
end

function TeamRoomSocialComponent:registerObjects()
	function self.btnFold.luaClick()
		self.action:TryChangePage("Fold", 1)
	end

	function self.btnDefaultAction.luaClick()
		self:onDefaultActionClick()
	end

	function self.btnUnfold.luaClick()
		self.action:TryChangePage("Fold", 0)
	end

	function self.actionList.luaRenderItem(button, index, data)
		self:renderActionButton(button, data)
	end

	function self.actionList.luaClick(button, data)
		self:playAction(data)
	end

	function self.btnVoice.luaClick()
		self:onBtnVoice()
	end
end

function TeamRoomSocialComponent:initView()
	self:initTeamMessage()
	self:initTeamAction()
	self:refreshBtnVoiceState({
		inSpeechRoom = pg.game.speech:checkMemberInRoom(pg.me.uid)
	})
	self:refreshSpeakState()
end

function TeamRoomSocialComponent:initTeamMessage()
	pg.game.chat:setTeamMiniChatWidget(self.btnChat)
end

function TeamRoomSocialComponent:onShow()
	self:initTeamMessage()
end

function TeamRoomSocialComponent:onHide()
	pg.game.chat:clearTeamMiniChatWidget()
end

function TeamRoomSocialComponent:initTeamAction()
	local data = {}

	self.firstAction = nil

	for key, action in pairs(AppearanceAction) do
		if action.teamUp == 1 then
			local item = {
				configId = key,
				icon = action.icon
			}

			table.insert(data, item)

			if self.firstAction == nil then
				self.firstAction = item
			end
		end
	end

	self.actionList:SetList(data)

	if self.firstAction then
		self:renderActionButton(self.btnDefaultAction, self.firstAction)
	end
end

function TeamRoomSocialComponent:playAction(data)
	if data and data.configId and self.ctrl.uiScene then
		self.ctrl.uiScene:playTeamRoomAni(data.configId)
	end
end

function TeamRoomSocialComponent:onDefaultActionClick()
	self:playAction(self.firstAction)
end

function TeamRoomSocialComponent:renderActionButton(button, action)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = action.icon
end

function TeamRoomSocialComponent:onBtnVoice()
	if not pg.game.speech:checkMemberInRoom(pg.me.uid) then
		pg.me:joinSpeechChannel({
			notifyDenied = true
		})
	else
		pg.me:quitSpeechChannel()
	end
end

function TeamRoomSocialComponent:refreshBtnVoiceState(info)
	local inSpeechRoom = info and info.inSpeechRoom or false

	self.btnVoice:TryChangePage("State", inSpeechRoom and 1 or 0)

	local objectReference = self.btnVoice.transform:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, inSpeechRoom and pg.getGameString("QUIT_SPEECH_ROOM") or pg.getGameString("JOIN_SPEECH_ROOM"))
end

function TeamRoomSocialComponent:refreshSpeakState()
	self.btnSpeak:TryChangePage("State", pg.game.speech:checkMemberSpeaking(pg.me.uid) and 1 or 0)
	self:refreshFreeTalkState()
end

function TeamRoomSocialComponent:onSpeechRoomMemberStateChange()
	if self.ctrl.refreshTeamInfo then
		self.ctrl:refreshTeamInfo()
	else
		self:refreshSpeakState()
	end

	if self.ctrl.refreshFocusedMemberConsoleBarState then
		self.ctrl:refreshFocusedMemberConsoleBarState()
	end
end

function TeamRoomSocialComponent:refreshFreeTalkState()
	pg.game.speech:bindManualPushTalk(self.btnSpeak.gameObject, self.btnSpeak)

	if not pg.game.speech:checkMemberInRoom(pg.me.uid) or pg.game.setting:getTeamSpeechFreeTalk() then
		self.chatUComponent:TryChangePage("FreeTalk", 1)
	else
		self.chatUComponent:TryChangePage("FreeTalk", 0)
	end
end

function TeamRoomSocialComponent:onDestroy()
	pg.game.chat:clearTeamMiniChatWidget()
	UIComponent.onDestroy(self)
end

return TeamRoomSocialComponent
