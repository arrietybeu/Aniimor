-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectionPanelNew\\PetSelectionPanelNewCtrl.lua

local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PuppetData = require("Data.puppet_data")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientUtils = require("Utils.ClientUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local DialogueUtils = require("Utils.DialogueUtils")
local Time = require("Core.Common.Time")
local PetSelectionPanelNewCtrl = Class.LightClass("PetSelectionPanelNewCtrl", UICtrl)
local MessageName = require("Const.MessageName")
local isShowBothBtn = true

function PetSelectionPanelNewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetSelectionPanelNewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info ~= nil then
		self.callback = info.closeCb
		self.dialogueId = info.dialogueId or 26023027
	end

	self.lastStickInputTime = 0
	self.stickInputCooldown = 0.3

	self:init()
end

function PetSelectionPanelNewCtrl:addListener()
	function self.view.leftBtn.luaClick()
		self:selectPet(1)
	end

	function self.view.rightBtn.luaClick()
		self:selectPet(2)
	end

	function self.view.leftConfirmBtn.luaClick()
		self:confirmSelectPet(self.selectIndex)
	end

	function self.view.rightConfirmBtn.luaClick()
		self:confirmSelectPet(self.selectIndex)
	end

	function self.view.btnBothUButton.luaClick()
		self:switchDialogue(true)

		if self.dialogueId and self.dialogueId > 0 then
			self:showDialogueInfo(self.dialogueId, 1)
		end
	end

	function self.view.dialogueBtnNext.luaClick()
		if self.dialogueId and self.dialogueId > 0 and self.index and self.index > 0 then
			self:showDialogueInfo(self.dialogueId, self.index + 1)
		end
	end

	function self.view.leftElementList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.elementName, false)
	end

	function self.view.rightElementList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.elementName, false)
	end

	self.view.bottomHotKey:SetHotKeyPaths("Raw/GamepadLeftStickMove")
	self.view.leftHotKey:SetHotKeyPaths("Raw/GamepadButtonSouth")
	self.view.rightHotKey:SetHotKeyPaths("Raw/GamepadButtonSouth")
	self.view.bothHotKey:SetHotKeyPaths("Raw/GamepadButtonNorth")
	LuaUIUtils.bindHotKey(self.view.mainCom.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft, function()
		self:selectPet(1)
	end)
	LuaUIUtils.bindHotKey(self.view.mainCom.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight, function()
		self:selectPet(2)
	end)
	self:bindHotKeyPerform("Raw/GamepadLeftStickMove", function(ctrl, inputInfo)
		if not pg.game.input:isUsingGamepad() then
			return true
		end

		return self:onGamepadLeftStickMove(inputInfo)
	end)
	self:bindHotKeyPerform("Raw/GamepadButtonSouth", function()
		if not pg.game.input:isUsingGamepad() then
			return true
		end

		return self:onGamepadButtonSouth()
	end)
	self:bindHotKeyPerform("Raw/GamepadButtonNorth", function()
		if not pg.game.input:isUsingGamepad() then
			return true
		end

		self.view.btnBothUButton:OnClickSimulate()
	end, self.view.btnBothUButton.gameObject)
end

function PetSelectionPanelNewCtrl:init()
	local score = ClientUtils.getCustomVariableValue(Const.TWIN_CHOICE_CUSTOM_VARIABLE_ID)

	self.isConfirming = false

	self.view.mainCom:TryChangePage("PetSel", 2)
	self.view.btnBothUButton:SetActive(isShowBothBtn)

	local initialPets = SysConfigData.initialPets
	local leftPuppetConfig = PuppetData[initialPets[1]]

	ClientTextUtils.setTextWithId(self.view.leftNameTxt, leftPuppetConfig.name)
	ClientTextUtils.setText(self.view.leftDetailSR.content, ClientTextUtils.getGameString("PET_MAIN_CHOICE_TEXT_X"))
	self.view.leftRecommend:SetActive(score > 0)

	local leftElements = LuaUIUtils.getTargetElementsInfos(leftPuppetConfig.elementType)

	self.view.leftElementList:SetList(leftElements)
	ClientTextUtils.setText(self.view.leftBtnText, ClientTextUtils.getGameString("QUEST_PET_CHOICE_TXT1"))

	local rightPuppetConfig = PuppetData[initialPets[2]]

	ClientTextUtils.setTextWithId(self.view.rightNameTxt, rightPuppetConfig.name)
	ClientTextUtils.setText(self.view.rightDetailSR.content, ClientTextUtils.getGameString("PET_MAIN_CHOICE_TEXT_Y"))
	self.view.rightRecommend:SetActive(score <= 0)

	local rightElements = LuaUIUtils.getTargetElementsInfos(rightPuppetConfig.elementType)

	self.view.rightElementList:SetList(rightElements)
	ClientTextUtils.setText(self.view.rightBtnText, ClientTextUtils.getGameString("QUEST_PET_CHOICE_TXT1"))
end

function PetSelectionPanelNewCtrl:onGamepadLeftStickMove(inputInfo)
	if not pg.game.input:isUsingGamepad() then
		return true
	end

	if self.isConfirming == true then
		return
	end

	local horizontalValue = inputInfo.valueVec2.x
	local deadZone = 0.5
	local currentTime = Time.time

	if currentTime - self.lastStickInputTime < self.stickInputCooldown then
		return
	end

	if horizontalValue < -deadZone then
		self:selectPet(1)

		self.lastStickInputTime = currentTime
	elseif deadZone < horizontalValue then
		self:selectPet(2)

		self.lastStickInputTime = currentTime
	end
end

function PetSelectionPanelNewCtrl:onGamepadButtonSouth()
	if not pg.game.input:isUsingGamepad() then
		return true
	end

	if self.isConfirming == true then
		return
	end

	if self.selectIndex == nil then
		self.selectIndex = 1
	end

	if self.selectIndex == 1 then
		self.view.leftConfirmBtn:OnClickSimulate()
	elseif self.selectIndex == 2 then
		self.view.rightConfirmBtn:OnClickSimulate()
	end
end

function PetSelectionPanelNewCtrl:selectPet(index)
	if self.isConfirming == true then
		return
	end

	self.selectIndex = index

	self.view.mainCom:TryChangePage("PetSel", index - 1)
end

function PetSelectionPanelNewCtrl:showConfirmPanel()
	if self.selectIndex == nil then
		return
	end

	self.isConfirming = true

	self.view.mainCom:TryChangePage("State", 1)
end

function PetSelectionPanelNewCtrl:confirmSelectPet(index)
	pg.me:updateTwinPetChoice(index)
	self:startTimer(function()
		self:dismiss()
	end, 1)
end

function PetSelectionPanelNewCtrl:switchDialogue(flag)
	isShowBothBtn = false

	self.view.mainCom:TryChangePage("HideUI", flag and 1 or 0)
	self.view.btnBothUButton:SetActive(false)
	self.view.boxDialogueUWidget:SetActive(flag)
end

function PetSelectionPanelNewCtrl:showDialogueInfo(dialogueId, index)
	self.index = index

	if dialogueId == nil then
		pg.game.communication:finishNpcDialog()
		self:switchDialogue(false)

		return
	end

	if NpcDialogueData[dialogueId] == nil or NpcDialogueData[dialogueId][index] == nil then
		pg.game.communication:finishNpcDialog()
		self:switchDialogue(false)

		return
	end

	ClientTextUtils.setText(self.view.txtNameUBaseText, "")
	ClientTextUtils.setText(self.view.dialogueTxt, LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogueId][index].chat))

	local duration = DialogueUtils.getDialogueDuration(nil, dialogueId, index)

	duration = duration or 3

	self:removeMoveNextTimer()

	if duration ~= -1 then
		self:startMoveNextTimer(duration, function()
			self:showDialogueInfo(dialogueId, index + 1)
		end)
	end
end

function PetSelectionPanelNewCtrl:startMoveNextTimer(duration, callback)
	if not callback then
		return
	end

	self.moveNextTimer = self:startTimer(function()
		callback()
	end, duration, false)
end

function PetSelectionPanelNewCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function PetSelectionPanelNewCtrl:removeMoveNextTimer()
	if self.moveNextTimer then
		self:killTimer(self.moveNextTimer)

		self.moveNextTimer = nil
	end
end

function PetSelectionPanelNewCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:removeMoveNextTimer()
end

return PetSelectionPanelNewCtrl
