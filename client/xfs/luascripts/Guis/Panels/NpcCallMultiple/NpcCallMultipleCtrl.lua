-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcCallMultiple\\NpcCallMultipleCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NpcCallMultipleCtrl = Class.LightClass("NpcCallMultipleCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local ToBool = ToBool
local state = 0
local PhoneIn = "VX_Ani_AiPhoneCall_In"
local PhoneOut = "VX_Ani_AiPhoneCall_Out"
local PhoneChange = "VX_Ani_AiPhoneCall_Change"
local PhoneAvatarAccepting = "VX_Node_AiCommunicate_Avatar_In2"
local PhoneAvatarChange = "VX_Node_AiCommunicate_Avatar_Change"
local PhoneAvatarIn = "VX_Node_AiCommunicate_Avatar_In"
local PhoneAvatarOut = "VX_Node_AiCommunicate_Avatar_Out"
local PHONE_STATE = {
	ON_HOLD = 1,
	HANGUP = 4,
	CONNECTED = 3,
	CONNECTING = 2
}

function NpcCallMultipleCtrl:onCreate(info)
	UICtrl.onCreate(self)

	self.state = PHONE_STATE.ON_HOLD
	self.npcId = info.npcId
	self.dialogueId = info.dialogueId
	self.questId = info.questId
	self.closeFunc = info.closeFunc
	self.Timeout = SysConfigData.NPC_CALL_CLOSE_TIME or 15
end

function NpcCallMultipleCtrl:addListener()
	function self.view.btnOnUButton.luaClick(button, index, data)
		self.state = PHONE_STATE.CONNECTING

		pg.game.audio:triggerEvent("stop_SFX_UI_PhoneRing")
		pg.game.audio:triggerEvent("SFX_UI_OnPhone")
		UIUtils.PlayAnimation(self.view.panelAvatarAnimation, PhoneAvatarAccepting, function()
			return
		end)
		UIUtils.PlayAnimation(self.view.panelAvatarAnimation, PhoneAvatarChange, function()
			self:dismiss()

			if self.closeFunc then
				self:closeFunc()
			end
		end)
		pg.game.dialogue:playDialogueGraph(self.dialogueId)
	end

	function self.view.btnOffUButton.luaClick(button, index, data)
		self.state = PHONE_STATE.HANGUP

		pg.game.audio:triggerEvent("stop_SFX_UI_PhoneRing")
		pg.game.audio:triggerEvent("SFX_UI_PhoneOff")
		UIUtils.PlayAnimation(self.view.panePhoneAnimation, PhoneOut, function()
			return
		end)
		UIUtils.PlayAnimation(self.view.panelAvatarAnimation, PhoneAvatarOut, function()
			self:dismiss()

			if self.closeFunc then
				self:closeFunc()
			end
		end)
	end

	self.view.keyNoKeyBindingPro.actionPath = "Hud/LeftCancel"

	function self.view.keyNoKeyBindingPro.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.btnOffUButton.luaClick()
		end
	end

	self.view.keyYesKeyBindingPro.actionPath = "Hud/LeftConfirm"

	function self.view.keyYesKeyBindingPro.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.btnOnUButton.luaClick()
		end
	end
end

function NpcCallMultipleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:showHeadIconUI(info.npcId)
	pg.game.audio:triggerEvent("SFX_UI_PhoneEntry")
	pg.game.audio:triggerEvent("SFX_UI_PhoneRing")
	UIUtils.PlayAnimation(self.view.panePhoneAnimation, PhoneIn)
	UIUtils.PlayAnimation(self.view.panelAvatarAnimation, PhoneAvatarIn)

	self.view.progressUProgress.value = 1
	self.Countdown = SysConfigData.NPC_CALL_CLOSE_TIME or self.Timeout
	self.ProgressShowTimer = self:startTimer(function()
		if not self.view then
			return
		end

		self.Countdown = self.Countdown - 1
		self.view.progressUProgress.value = self.Countdown / self.Timeout

		if self.Countdown == 0 then
			self.view.btnOffUButton.luaClick()
			self:killTimer(self.ProgressShowTimer)

			self.ProgressShowTimer = nil
		elseif self.Countdown == 3 then
			-- block empty
		end
	end, 1, true)
end

function NpcCallMultipleCtrl:onHide()
	UICtrl.onHide(self)

	self.callback = nil
end

function NpcCallMultipleCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.ProgressShowTimer ~= nil then
		pg.game.audio:triggerEvent("SFX_UI_PhoneOff")
		self:killTimer(self.ProgressShowTimer)

		self.ProgressShowTimer = nil
	end
end

function NpcCallMultipleCtrl:showHeadIconUI(templateId)
	local npcData = PuppetData[templateId]

	if npcData and npcData.isNpc then
		self:tryShowNpcCallMultipleHeadIcon(npcData.iconName, templateId)
		self:tryShowNpcCallMultipleName(pg.getLocalizationText(npcData.name))
	end
end

function NpcCallMultipleCtrl:tryShowNpcCallMultipleName(name)
	name = name or pg.getGameString("AI_COMMUNICATE_STRANGER")

	ClientTextUtils.setText(self.view.avatarName, name)
end

function NpcCallMultipleCtrl:tryShowNpcCallMultipleHeadIcon(iconName, templateId)
	local enable = ToBool(iconName)

	LuaUIUtils.setUIViewVisible(self.view.imgRoleUImage, enable)

	if not enable then
		return
	end

	self.view.imgRoleUImage.url = iconName or ""
end

function NpcCallMultipleCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return NpcCallMultipleCtrl
