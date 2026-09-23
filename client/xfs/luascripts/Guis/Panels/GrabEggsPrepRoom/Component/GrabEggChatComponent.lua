-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsPrepRoom\\Component\\GrabEggChatComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrabEggChatComponent = Class.LightClass("GrabEggChatComponent", UIComponent)
local UIConst = require("Const.UIConst")
local AppearanceAction = require("Data.appearance_action_data")
local MessageName = require("Const.MessageName")

GrabEggChatComponent.messages = {
	[MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE] = {
		"refreshSpeakState",
		true
	}
}

function GrabEggChatComponent:findObjects()
	self.objectReference = self.uWidget.content:GetComponent("ObjectReference")
	self.btnChat = self.objectReference:GetRefValue("btnChat")
	self.txtMessage = self.objectReference:GetRefValue("txtMessage")
	self.btnFold = self.objectReference:GetRefValue("btnFold")
	self.btnUnFold = self.objectReference:GetRefValue("btnUnFold")
	self.btnDefaultEmoji = self.objectReference:GetRefValue("btnDefaultEmoji")
	self.action = self.objectReference:GetRefValue("action")
	self.actionList = self.objectReference:GetRefValue("actionList")
	self.btnSpeakUButton = self.objectReference:GetRefValue("btnVoiceUButton")
	self.chatUComponent = self.objectReference:GetRefValue("chatUComponent")
	self.uiScene = self.ctrl.uiScene
end

function GrabEggChatComponent:registerObjects()
	function self.btnFold.luaClick()
		self.action:TryChangePage("Fold", 1)
	end

	function self.btnUnFold.luaClick()
		self.action:TryChangePage("Fold", 0)
	end

	function self.btnDefaultEmoji.luaClick()
		self:onBtnDefaultEmoji()
	end

	function self.actionList.luaRenderItem(button, index, data)
		self:renderActionItem(button, data)
	end

	function self.actionList.luaClick(button, data)
		if data and data.configId then
			self.uiScene:playTeamRoomAni(data.configId)
		end
	end
end

function GrabEggChatComponent:initView()
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
		self:renderActionItem(self.btnDefaultEmoji, self.firstAction)
	end

	pg.game.chat:setTeamMiniChatWidget(self.btnChat)
	self:refreshFreeTalkState()
end

function GrabEggChatComponent:refreshSpeakState()
	self.btnSpeakUButton:TryChangePage("State", pg.game.speech:checkMemberSpeaking(pg.me.uid) and 1 or 0)
	self:refreshFreeTalkState()
end

function GrabEggChatComponent:refreshFreeTalkState()
	pg.game.speech:bindManualPushTalk(self.btnSpeakUButton.gameObject, self.btnSpeakUButton)

	if not pg.game.speech:checkMemberInRoom(pg.me.uid) or pg.game.setting:getTeamSpeechFreeTalk() then
		self.chatUComponent:TryChangePage("FreeTalk", 1)
	else
		self.chatUComponent:TryChangePage("FreeTalk", 0)
	end
end

function GrabEggChatComponent:renderActionItem(button, action)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = action.icon
end

function GrabEggChatComponent:onBtnDefaultEmoji()
	if self.firstAction and self.firstAction.configId then
		self.uiScene:playTeamRoomAni(self.firstAction.configId)
	end
end

function GrabEggChatComponent:onDestroy()
	pg.game.chat:clearTeamMiniChatWidget()
	UIComponent.onDestroy(self)
end

return GrabEggChatComponent
