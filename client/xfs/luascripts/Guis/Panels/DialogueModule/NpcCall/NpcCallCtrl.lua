-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\NpcCall\\NpcCallCtrl.lua

local Class = require("Core.Framework.Class")
local DialogueBaseCtrl = require("Guis.Panels.DialogueModule.DialogueBaseCtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local DialogueConst = require("Const.DialogueConst")
local NpcCallCtrl = Class.LightClass("NpcCallCtrl", DialogueBaseCtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local DialogueUtils = require("Utils.DialogueUtils")
local ToBool = ToBool

NpcCallCtrl.HeadShowDelayTime = 1

function NpcCallCtrl:tryStopTypewriterEffect()
	if self.view and self.view.contentUText:IsRunningTypewriter() then
		self.view.contentUText:TryFinishedStoryText()

		return true
	end

	return false
end

function NpcCallCtrl:canTriggerNextBtn()
	return self:InNpcCall() and pg.game.input:IsBlockEvent() and self.view and self.view.dialogueUWidget.gameObject.activeSelf and pg.game.communication:getEnableStopUI()
end

function NpcCallCtrl:onOpen(info)
	NpcCallCtrl.super.onOpen(self, info)
	self.view.dialogueUWidget.gameObject:SetActiveEx(false)
	LuaUIUtils.setUIViewVisible(self.view.panelAvatarUComponent, false)
end

function NpcCallCtrl:onHide()
	NpcCallCtrl.super.onHide(self)
	self:hideHeadIconUI()
	self:hideNpcCallContent()
end

function NpcCallCtrl:onVisibleChange(visible)
	NpcCallCtrl.super.onVisibleChange(self, visible)

	if visible and self.inNpcCall and self.view then
		self.view.contentUText:TryFinishedStoryText()
	end
end

function NpcCallCtrl:showNpcCallContent(name, npcCallTemplateId, content, duration, isAside, callback)
	if not self.view then
		if callback then
			callback()
		end

		return
	end

	self.npcCallCallback = callback

	local invokeDuration = duration or 3

	self:removeMoveNextTimer()

	if invokeDuration ~= -1 then
		self:startMoveNextTimer(invokeDuration, function()
			self:InvokeNpcCallCallback()
		end)
	end

	self.inNpcCall = true

	self.view.dialogueUWidget.gameObject:SetActiveEx(true)
	ClientTextUtils.setText(self.view.titleUText, name or "")
	self.view.panelUComponent:TryChangePage("TitleColor", npcCallTemplateId == DialogueConst.SpeakerType.Player and 1 or 0)
	ClientTextUtils.setText(self.view.contentUText, content)
	self.view.panelUComponent:TryChangePage("Type", isAside and 1 or 0)

	self.npcCallTemplateId = npcCallTemplateId

	local npcEntity = DialogueUtils.getDialogueEntityByTemplateId(self.npcCallTemplateId)

	if npcEntity and npcEntity.playLipMotionAnim then
		npcEntity:playLipMotionAnim()

		if invokeDuration > 0.01 then
			self.lipMotionTimer = self:startScaleTimer(function()
				self:stopLipMotionAnim()
			end, invokeDuration, false)
		end
	end
end

function NpcCallCtrl:stopLipMotionAnim()
	if self.lipMotionTimer then
		self:killScaleTimer(self.lipMotionTimer)

		self.lipMotionTimer = nil
	end

	if self.npcCallTemplateId then
		local npcEntity = DialogueUtils.getDialogueEntityByTemplateId(self.npcCallTemplateId)

		if npcEntity and npcEntity.stopLipMotionAnim then
			npcEntity:stopLipMotionAnim()
		end

		self.npcCallTemplateId = nil
	end
end

function NpcCallCtrl:hideNpcCallContent()
	self:stopLipMotionAnim()

	self.inNpcCall = false

	if self.view then
		self.view.dialogueUWidget.gameObject:SetActiveEx(false)
	end
end

function NpcCallCtrl:InNpcCall()
	return self.inNpcCall == true
end

function NpcCallCtrl:InvokeNpcCallCallback()
	local npcCallCallback = self.npcCallCallback

	self.npcCallCallback = nil

	if npcCallCallback then
		npcCallCallback()
	end
end

function NpcCallCtrl:showHeadIconUI(npcName, iconResId, callback)
	if not self.view then
		if self.callback then
			self.callback()
		end

		return
	end

	self.inHeadIcon = true
	self.callback = callback

	LuaUIUtils.setUIViewVisible(self.view.panelAvatarUComponent, true)
	self:playInitialShowAnim()
	self:tryShowNpcCallHeadIcon(iconResId)
	self:tryShowNpcCallName(npcName)
	self:removeIconShowTimer()

	self.iconShowTimer = self:startScaleTimer(function()
		if not self.view then
			return
		end

		self:invokeCallback()
	end, self.HeadShowDelayTime, false)
end

function NpcCallCtrl:hideHeadIconUI()
	self.inHeadIcon = false

	self:removeIconShowTimer()

	if not self.view then
		return
	end

	LuaUIUtils.setUIViewVisible(self.view.panelAvatarUComponent, false)
end

function NpcCallCtrl:InHeadIcon()
	return self.inHeadIcon == true
end

function NpcCallCtrl:playInitialShowAnim()
	self.view.connectUText:SetActiveQuickly(false)
	self.view.avatarName:SetActiveQuickly(false)
end

function NpcCallCtrl:tryShowNpcCallName(name)
	name = name or pg.getGameString("AI_COMMUNICATE_STRANGER")

	ClientTextUtils.setText(self.view.avatarName, name)
end

function NpcCallCtrl:tryShowNpcCallHeadIcon(iconUrl)
	local enable = ToBool(iconUrl)

	LuaUIUtils.setUIViewVisible(self.view.imgRoleUImage, enable)

	if not enable then
		return
	end

	self.view.imgRoleUImage.url = iconUrl
end

function NpcCallCtrl:removeIconShowTimer()
	if self.iconShowTimer ~= nil then
		self:killScaleTimer(self.iconShowTimer)

		self.iconShowTimer = nil
	end
end

return NpcCallCtrl
