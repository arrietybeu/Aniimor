-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\Dialogue\\DialogueCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DialogueCtrl")
local DialogueBaseCtrl = require("Guis.Panels.DialogueModule.DialogueBaseCtrl")
local Class = require("Core.Framework.Class")
local PlayableConst = require("Common.Const.PlayableConst")
local DialogueCtrl = Class.LightClass("DialogueCtrl", DialogueBaseCtrl)
local TimerManager = require("Core.Timer.TimerManager")
local DialogueBranchUIComponent = require("Guis.Panels.DialogueModule.Dialogue.Component.DialogueBranchUIComponent")
local NpcDialogueData = require("Data.npc_dialogue_data")
local PuppetData = require("Data.puppet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local DialogueConst = require("Const.DialogueConst")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local AudioConst = require("Const.AudioConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local Const = require("Common.Const.Const")
local DialogCameraPreset = require("Common.Const.DialogueCameraPreset")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DialogueUtils = require("Utils.DialogueUtils")
local SafeCallback = require("Core.Framework.SafeCallback")
local EntityLookAtUtils = require("GameApp.Communication.EntityLookAtUtils")
local DialogueCamera = require("GameApp.Communication.DialogueCamera")
local Quaternion = Quaternion
local Vector3 = Vector3
local ToBool = ToBool
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

DialogueCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChange",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"refreshCurrency",
		true
	},
	[MessageName.DIALOGUE_GRAPH_PLAYBACK_STATE_CHANGE] = {
		"onPlaybackStateChange",
		true
	},
	[MessageName.AUDIO_EVENT_FINISH] = {
		"onAudioEventFinish",
		true
	}
}

function DialogueCtrl:onCreate(info)
	DialogueCtrl.super.onCreate(self, info)

	self.dialogId = nil
	self.dialogIndex = nil
	self.maxDialogIndex = nil
	self.dialogueTimer = nil
	self.waitPlayerChooseOption = false
	self.isPlaying = false
	self.playSpeed = 1
	self.pausedNpcIds = {}
	self.speakerAnimationInfo = {}
	self.view.panelObj.renderOpacity = 0
	self.reviewLogHotKey = self.view.reviewLogBtn.transform:GetChild("Key"):GetComponent("HotKeyContent")

	self.reviewLogHotKey:SetHotKeyPaths("Hud/DialogueReviewLogGamepad")
	self.reviewLogHotKey.gameObject:SetActiveEx(pg.game.input:isUsingGamepad())
	self.view.reviewLogIcon.gameObject:SetActiveEx(not pg.game.input:isUsingGamepad())

	function self.view.nextBtn.luaPress()
		if not self.isViewControlling then
			self.isViewControlling = true
		end
	end

	function self.view.nextBtn.luaClick()
		if pg.game.input:isUsingGamepad() then
			self:onNextBtnClick(true)

			return true
		end

		if self.isViewControlling then
			return true
		end

		self:onNextBtnClick(true)

		return true
	end

	function self.view.nextBtn.luaRelease()
		if self.isViewControlling then
			self.isViewControlling = false

			pg.game.camera.npcDialogueCameraMode:enableFreedomCameraAutoRotation(true)
		end
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	function self.view.reviewLogBtn.luaClick()
		if self.isDialogueGraph then
			return
		end

		self:hide()

		if self.cmd then
			self.cmd:pause()
		end

		pg.game.communication:openDialogReview(function()
			self:show()

			if self.cmd then
				self.cmd:resume()
			end
		end)
	end

	self:bindHotKeyPerform("Hud/DialogueReviewLogGamepad", self.view.reviewLogBtn.luaClick, self.view.reviewLogBtn.gameObject)

	self.dialogueBranch = DialogueBranchUIComponent.new(self, self.view.dialogueBranchListBtnTransform)

	self.view.listCurrencyUList:SetActive(true)
	self:hide()

	self.hideAnimTime = self.view.panelAnim:GetClip("UI_Ani_Dialogue_Hide").length

	if self.view.btnTipsUSDFText then
		ClientTextUtils.setText(self.view.btnTipsUSDFText, pg.getGameString("UI_Pb_Dialogue_ContinueTips"))
	end
end

function DialogueCtrl:refreshConsoleBarState()
	if pg.game.input:isUsingGamepad() and self.view.btnTipsUSDFText then
		ClientTextUtils.setText(self.view.btnTipsUSDFText, pg.getGameString("UI_Pb_Dialogue_ContinueTips"))
	end
end

function DialogueCtrl:onDestroy()
	DialogueCtrl.super.onDestroy(self)

	self.reviewLogHotKey = nil
	self.dialogueBranch = nil
end

function DialogueCtrl:onHide()
	self:KillUIStop()

	self.__hasOption = false

	DialogueCtrl.super.onHide(self)
end

function DialogueCtrl:addListener()
	local viewAxisBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "viewAxis")

	viewAxisBind.isVirtual = true
	viewAxisBind.priority = 0
	viewAxisBind.actionPath = "Camera/ViewAxis"

	function viewAxisBind.luaTrigger(inputInfo)
		if not self.isViewControlling then
			return
		end

		pg.game.input.cameraProcessor:handleDialogueViewAxisAction(inputInfo)
		pg.game.camera.npcDialogueCameraMode:enableFreedomCameraAutoRotation(false)
	end

	local viewAxisGamepadBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "viewAxisGamepad")

	viewAxisGamepadBind.isVirtual = true
	viewAxisGamepadBind.priority = 0
	viewAxisGamepadBind.actionPath = "Camera/ViewAxisGamepad"

	function viewAxisGamepadBind.luaTrigger(inputInfo)
		pg.game.input.cameraProcessor:handleViewAxisGamepadAction(inputInfo)
	end

	self:bindHotKeyPerform("Common/Cancel", self.onPerformCommonCancel, self.view.gameObject)
	self:bindHotKeyPerform("Hud/InteractScroll", self.onPerformInteractScroll, self.view.gameObject)
	self:bindHotKeyPerform("Hud/DPadMoveUp", self.onPerformPadMoveUp, self.view.gameObject)
	self:bindHotKeyPerform("Hud/DPadMoveDown", self.onPerformPadMoveDown, self.view.gameObject)
	self:addNextBtnClick("space", "Hud/DialogueNext")
	self:addNextBtnClick("keyF", "Hud/Interact")
	self:addNextBtnClick("gamePadSkipTypewriter", "Common/GamepadConfirm")
end

function DialogueCtrl:onPerformCommonCancel()
	if self.isDialogueGraph then
		return true
	end

	if pg.game.communication:finishNpcDialog(nil, nil, self.customInfo) then
		return false
	end

	return true
end

function DialogueCtrl:onPerformInteractScroll(inputInfo)
	local deltaZoom = inputInfo.valueVec2.y

	if self:triggerOnMouseScroll(deltaZoom) then
		return false
	end

	if pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.FREEDOM then
		pg.game.camera.npcDialogueCameraMode:handleCameraZoom(deltaZoom)

		return false
	end

	return true
end

function DialogueCtrl:onPerformPadMoveUp(inputInfo)
	if self:triggerOnGamepadSwitch(1) then
		return false
	end

	return true
end

function DialogueCtrl:onPerformPadMoveDown(inputInfo)
	if self:triggerOnGamepadSwitch(-1) then
		return false
	end

	return true
end

function DialogueCtrl:onVisibleChange(visible)
	DialogueBaseCtrl.onVisibleChange(self, visible)

	if visible and self.view.dialogueText then
		local content = self.view.dialogueText.text

		ClientTextUtils.setText(self.view.dialogueText, content)
	end
end

function DialogueCtrl:onNextBtnClick(isClick)
	if not self.dialogId or not self.dialogIndex then
		return true
	end

	local isSkipTypewriter = false

	if isClick then
		if self.forbidNextBtnClick then
			return true
		end

		if self.view.dialogueText:IsRunningTypewriter() then
			self.view.dialogueText:TryFinishedStoryText()

			isSkipTypewriter = true
		elseif not self:checkNextBtnCooling() then
			return true
		end
	end

	if self.waitPlayerChooseOption then
		return true
	end

	local duration = pg.me:getGameTime() - self.dialogStartTime

	if isClick then
		if not pg.game.communication:getEnableStopUI() then
			return false
		end

		self:removeMoveNextTimer()
		pg.game.audio:playEvent("SFX_UI_Click_Dialogue")
	end

	local action = isClick and DialogueConst.SEND_REPORT_ACTION_EVENT.PROACTIVELY_END_SENTENCE or DialogueConst.SEND_REPORT_ACTION_EVENT.AUTO_END_SENTENCE

	DialogueUtils.sendDialogueInfoReport(self.dialogId, self.playSpeed, self.dialogIndex, action, duration)

	local hasBranch = self:tryShowBranchOption(isClick)

	if hasBranch or isSkipTypewriter then
		return true
	end

	if self.overrideNextBtnCallback then
		local tmpCallback = self.overrideNextBtnCallback

		self.overrideNextBtnCallback = nil

		tmpCallback(1, 0)

		return false
	end

	return false
end

function DialogueCtrl:checkNextBtnCooling()
	if self.dialogStartTime and pg.me then
		return pg.me:getGameTime() - self.dialogStartTime > 0.5
	else
		return true
	end
end

function DialogueCtrl:showDialog(id, index, npcEntityId, extraInfo, callback, customInfo)
	if not self.view then
		return
	end

	self.dialogId = id
	self.dialogIndex = index
	self.isDialogueGraph = extraInfo and ToBool(extraInfo.isDialogueGraph)
	self.customInfo = customInfo
	self.showClock = pg.me:getGameTime()

	LuaUIUtils.setUIVisible(self.view.reviewLogBtn, not self.isDialogueGraph)

	local curNpcDialogueData = NpcDialogueData[self.dialogId]
	local curDialogInfo = curNpcDialogueData[self.dialogIndex]

	if npcEntityId then
		self:addRelatedNpc(npcEntityId)
		table.insert(self.pausedNpcIds, npcEntityId)

		self.targetNpc = pg.getEntity(npcEntityId)

		if extraInfo then
			extraInfo.targetNpc = self.targetNpc
		end
	elseif not self.isDialogueGraph then
		local npcTemplateId = curDialogInfo.npcId
		local npcStaticId = curDialogInfo.npcStaticId
		local npcEntity = DialogueUtils.getDialogueEntity(npcTemplateId, npcStaticId)

		if npcEntity then
			self:addRelatedNpc(npcEntity.id)
			table.insert(self.pausedNpcIds, npcEntity.id)

			self.targetNpc = npcEntity
		else
			self.targetNpc = nil
		end
	else
		self.targetNpc = nil
	end

	self.extraText = extraInfo and extraInfo.extraText
	self.forbidNextBtnClick = extraInfo and extraInfo.forbidNextBtnClick
	self.forbidRecoverAudioState = false

	if extraInfo ~= nil and extraInfo.chatType then
		self.chatType = extraInfo.chatType
	else
		self.chatType = curDialogInfo.chatType
	end

	if extraInfo ~= nil and extraInfo.duration then
		self.curDuration = extraInfo.duration
	else
		self.curDuration = curDialogInfo.duration or 3
	end

	local me = pg.me
	local speakerEntity, speakerType = DialogueUtils.getDialogueEntity(curDialogInfo.npcId, curDialogInfo.npcStaticId)

	if not self:checkCurSpeakerValid(speakerType) then
		self:onNextBtnClick()

		return
	end

	self.playSpeed = 1
	self.waitPlayerChooseOption = false

	LuaUIUtils.setUIViewVisible(self.view.nextIcon, true)
	self:refreshCurrency()

	local maxDialogIndex = table.maxn(curNpcDialogueData)

	if callback then
		self.overrideNextBtnCallback = callback
	end

	self:showCurrentDialogueInfo(extraInfo)

	local disableCameraAnim = curDialogInfo.disableCameraLock

	if disableCameraAnim then
		self.disableCameraAnim = disableCameraAnim
	else
		self.disableCameraAnim = extraInfo and extraInfo.disableCameraAnim
	end

	if pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.NONE then
		self.disableCameraAnim = true
	end

	self:triggerActionsPerDialogue(extraInfo, maxDialogIndex, speakerEntity)
	self:SetUIStop(pg.game.communication:getForbidClickTime())

	if not pg.global.ui:checkUIShow(UIConst.UI_ID_BOTTOM_DIALOGUE) or self.hideAnimTimer ~= nil then
		if self.hideAnimTimer ~= nil then
			self:killScaleTimer(self.hideAnimTimer)

			self.hideAnimTimer = nil
		end

		self:show()
		self.view.panelAnim:Play("UI_Ani_Dialogue_Show")
	end

	if not me.isInDialogue then
		me.isInDialogue = true

		pg.pawn:checkDialogue(true)
		pg.game.controller.nextSkillAction:clearNextSkillCache()
	end
end

function DialogueCtrl:startDialogueTimer(duration)
	duration = duration / self.playSpeed

	self:removeMoveNextTimer()
	self:startMoveNextTimer(duration, function()
		self:onNextBtnClick()
	end)
end

function DialogueCtrl:triggerActionsPerDialogue(branchParam, maxDialogIndex, speakerEntity)
	local hasOption = false
	local optionList
	local curDialogInfo = NpcDialogueData[self.dialogId][self.dialogIndex]

	self:clearDialogueBranchOption()

	if branchParam and branchParam.branch then
		hasOption, optionList = self:triggerDialogueCustomBranch(branchParam, maxDialogIndex)
	elseif ToBool(curDialogInfo.branchParam) then
		hasOption, optionList = self:triggerDialogueBranch(curDialogInfo.branchParam, maxDialogIndex)

		if hasOption and ToBool(self.curDuration) and self.moveNextTimer == nil then
			self:startDialogueTimer(self.curDuration)
		end
	end

	self.__hasOption = hasOption

	local isNpcSpeaker = self:isCurSpeakerNpc(speakerEntity)

	self:triggerCamera(isNpcSpeaker, false)

	if hasOption then
		function self.showBranchOptionFunc()
			self:refreshDialogueBranchOption(optionList)
			self:triggerCamera(isNpcSpeaker, true)

			if branchParam and branchParam.showBranchCallback then
				branchParam.showBranchCallback()
			end

			self.waitPlayerChooseOption = true
		end
	end

	if branchParam then
		local ret, isSleAni, speakerType, targetEntity = pg.game.communication:triggerAnimAction(branchParam.npcId, branchParam.npcStaticId, self.dialogId, self.dialogIndex, branchParam.actionId or curDialogInfo.actionId)

		if ret then
			self:addSpeakerAnimationInfo(speakerType, targetEntity, isSleAni or false)
		end
	end

	if self.isDialogueGraph or not pg.game.communication.enableDefaultLookAt or ToBool(curDialogInfo.disableDefaultLookAt) then
		return
	end

	local lookAtTarget = curDialogInfo.lookAtId
	local targetEntity = DialogueUtils.getDialogueEntityByTemplateId(lookAtTarget)

	if speakerEntity and targetEntity and speakerEntity ~= targetEntity then
		self:triggerLookAtTarget(speakerEntity, targetEntity)
	elseif pg.pawn and self.targetNpc then
		EntityLookAtUtils.setLookAtDialogue(pg.pawn, self.targetNpc)
		EntityLookAtUtils.setLookAtDialogue(self.targetNpc, pg.pawn)
		EntityLookAtUtils.doModifyLookAt()
		self:registerFinishCallback(function()
			if pg.pawn then
				EntityLookAtUtils.removeLookAtDialogue(pg.pawn)
			end

			if self.targetNpc then
				EntityLookAtUtils.removeLookAtDialogue(self.targetNpc)
			end

			EntityLookAtUtils.doModifyLookAt()
		end)
	end
end

function DialogueCtrl:tryShowBranchOption(isClick)
	if self.showBranchOptionFunc then
		local action = isClick and DialogueConst.SEND_REPORT_ACTION_EVENT.PROACTIVELY_END_SENTENCE or DialogueConst.SEND_REPORT_ACTION_EVENT.AUTO_END_SENTENCE

		DialogueUtils.sendDialogueInfoReport(self.dialogId, self.playSpeed, self.dialogIndex, action, pg.me:getGameTime() - self.dialogStartTime)

		self.dialogStartTime = pg.me:getGameTime()

		self.showBranchOptionFunc()

		self.showBranchOptionFunc = nil

		self:removeMoveNextTimer()
		self:ImgNextUWidgetInvoke(false)

		return true
	end

	return false
end

function DialogueCtrl:nextHasOption()
	return self.__hasOption
end

function DialogueCtrl:triggerDialogueBranch(branchParam, maxDialogIndex)
	local optionList = {}
	local totalOptionNum = 0
	local finishedOptionNum = 0
	local extraParam = NpcDialogueData[self.dialogId][self.dialogIndex].extraParam

	for idx, optionData in ipairs(branchParam) do
		local branchText = optionData[1]
		local nextDialogueId = optionData[2]
		local isOptionFinished = nextDialogueId ~= nil and ToBool(pg.me.currentBranchState[nextDialogueId])

		if isOptionFinished then
			finishedOptionNum = finishedOptionNum + 1
		end

		optionList[#optionList + 1] = {
			optionText = branchText,
			nextDialogueId = nextDialogueId,
			hasSelected = isOptionFinished
		}
		totalOptionNum = totalOptionNum + 1
	end

	if ToBool(optionList) then
		if ToBool(extraParam) then
			if totalOptionNum == finishedOptionNum then
				for idx, optionData in ipairs(extraParam) do
					local branchText = optionData[1]
					local nextDialogueId = optionData[2]

					optionList[#optionList + 1] = {
						hasSelected = false,
						optionText = branchText,
						nextDialogueId = nextDialogueId
					}
				end
			end
		elseif finishedOptionNum > 0 and totalOptionNum == finishedOptionNum then
			pg.me:serverMsg("RPC_CS_SetDialogueGroup", self.dialogId, self.dialogIndex, 2, {})
			pg.game.communication:finishNpcDialog()
		end

		LuaUIUtils.setUIViewVisible(self.view.btnLayout, false)
		LuaUIUtils.setUIViewVisible(self.view.nextIcon, false)

		self.waitPlayerChooseOption = false
		self.maxDialogIndex = maxDialogIndex

		return true, optionList
	end

	return false
end

function DialogueCtrl:refreshCurrency()
	if self.cmd and self.cmd.config and self.cmd.config.dialogCurrency then
		LuaUIUtils.setUIViewVisible(self.view.listCurrencyUList, true)
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, self.cmd.config.dialogCurrency)
	else
		LuaUIUtils.setUIViewVisible(self.view.listCurrencyUList, false)
	end
end

function DialogueCtrl:triggerDialogueCustomBranch(branchParam, maxDialogIndex)
	local optionList = {}

	if branchParam.branch ~= nil then
		local totalOptionNum = 0
		local maxIndex = table.maxn(branchParam.branch)

		for i = 1, maxIndex do
			local branch = branchParam.branch[i]

			if branch then
				local dialogueId, actionId, optionText, btnIcon, important

				if type(branch) == "table" then
					dialogueId = branch.dialogueId
					actionId = branch.actionId
					optionText = branch.optionText
					btnIcon = branch.btnIcon
					important = branch.important
				else
					dialogueId = branch
				end

				if optionText == nil then
					local dialogueData = NpcDialogueData[dialogueId]

					if dialogueData then
						optionText = dialogueData[1].chat
					else
						optionText = string.format("<color=#ff0000>%s</color>", tostring(dialogueId))
					end
				end

				local function onClick(branchIndex)
					if actionId then
						local ret, isSleAni, speakerType, targetEntity = pg.game.communication:triggerAnimAction(0, nil, dialogueId, 1, actionId)

						if ret then
							self:addSpeakerAnimationInfo(speakerType, targetEntity, isSleAni or false)
						end
					end

					if dialogueId then
						pg.me:serverMsg("RPC_CS_SetDialogueGroup", dialogueId, 1, 2, {
							globalId = self.targetNpc and self.targetNpc.id
						})
						DialogueUtils.sendDialogueOptionInfoReport(self.dialogId, branchIndex, pg.me:getGameTime() - self.dialogStartTime)

						pg.me.currentBranchState[dialogueId] = true
					end

					self:clearDialogueBranchOption()

					if branchParam.callback then
						SafeCallback(branchParam.callback, branchIndex, 0)
					end

					if dialogueId == nil then
						pg.game.communication:finishNpcDialog()
					end
				end

				optionList[#optionList + 1] = {
					id = i,
					dialogueId = dialogueId,
					optionText = optionText,
					btnIcon = btnIcon,
					callback = onClick,
					important = important,
					hasSelected = ToBool(pg.me.currentBranchState[dialogueId])
				}
				totalOptionNum = totalOptionNum + 1
			end
		end
	end

	LuaUIUtils.setUIViewVisible(self.view.btnLayout, false)

	if ToBool(optionList) then
		LuaUIUtils.setUIViewVisible(self.view.nextIcon, false)

		self.maxDialogIndex = maxDialogIndex

		function self.showBranchOptionFunc()
			self:refreshDialogueBranchOption(optionList)

			if branchParam.showBranchCallback then
				branchParam.showBranchCallback()
			end

			self.waitPlayerChooseOption = true
		end

		if self.curDuration then
			self:startDialogueTimer(self.curDuration)
		end

		return true, optionList
	else
		self:removeMoveNextTimer()

		if self.curDuration then
			self:startDialogueTimer(self.curDuration)
		end
	end

	return false
end

function DialogueCtrl:triggerCamera(isNpcSpeaker, hasOption)
	if self.isDialogueGraph or ToBool(self.disableCameraAnim) then
		return
	end

	pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue, false)

	if pg.game.communication.cameraPresetType == DialogueConst.CAMERA_MODE.FREEDOM then
		if not pg.me.isInDialogue then
			DialogueCamera.triggerCameraDof(self.targetNpc)
		end
	else
		self:triggerCameraAnim(isNpcSpeaker, hasOption, self.targetNpc)
	end
end

function DialogueCtrl:triggerCameraAnim(isNpcSpeaker, hasOption, targetNpcEntity)
	local cameraAnim

	if hasOption then
		cameraAnim = DialogCameraPreset.Default_Single
	elseif not pg.me.isInDialogue or isNpcSpeaker then
		cameraAnim = DialogCameraPreset.Talk_AvatarToNPC_Shot
	else
		cameraAnim = DialogCameraPreset.Default_Single
	end

	if not targetNpcEntity then
		cameraAnim = DialogCameraPreset.Default_Single
	else
		local npcType = targetNpcEntity:getConfigData().npcType

		if Utils.isPetNpc(targetNpcEntity) or Utils.isPuppet(targetNpcEntity) and npcType ~= nil and npcType ~= Const.NPC_TYPE.Human then
			if cameraAnim == DialogCameraPreset.Default_Single then
				cameraAnim = self:getAnimResName(true)
			else
				cameraAnim = self:getAnimResName(false)
			end

			if cameraAnim == self.curCameraAnim then
				return
			end

			self.curCameraAnim = cameraAnim

			local targetDir = targetNpcEntity:getPositionAgentPosition() - pg.pawn:getPositionAgentPosition()

			targetDir.y = 0

			local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

			pg.game.camera:enableNpcDialogue(true, ClientConst.DialogueCameraPreset.PlayCameraAnim, targetNpcEntity, nil, {
				animResId = cameraAnim,
				baseTransformActorId = pg.pawn.actorId,
				initRotation = targetRotation
			})

			return
		else
			local puppetData = PuppetData[targetNpcEntity.templateId]

			if puppetData and (puppetData.npcType == DialogueConst.NpcType.EnvObj or puppetData.npcType == DialogueConst.NpcType.Other) then
				return
			end
		end
	end

	if not cameraAnim then
		return
	end

	if cameraAnim == DialogCameraPreset.Default_Single then
		pg.game.camera:setDofEnable(CameraConst.DofStateKeys.Dialogue, true)
	end

	if not pg.me.isInDialogue then
		pg.game.camera:enableNpcDialogue(true, cameraAnim, targetNpcEntity, nil, {
			needTransition = true
		})
	else
		local isNpcInBv = cameraAnim ~= DialogCameraPreset.Default_Single

		pg.game.camera:enableNpcDialogue(true, cameraAnim, isNpcInBv and targetNpcEntity or nil, nil, {
			isNpcBv = isNpcInBv
		})
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@hyj onTriggerDialogueCamera dialogId = %d, index = %d, isNpcSpeaking = ", self.dialogId, self.dialogIndex, isNpcSpeaker, cameraAnim)
	end
end

function DialogueCtrl:getAnimResName(isReverse)
	local npcCamAnimStr = DialogueUtils.getPetBodySizeTypeCamAnimStr(self.targetNpc)

	if Utils.isPet(pg.pawn) then
		local selfPetCamAnimStr = DialogueUtils.getPetBodySizeTypeCamAnimStr(pg.pawn)

		return string.format("$CameraAni_Parmon_Common_TalkToParmon_%sTo%s.asset", selfPetCamAnimStr, npcCamAnimStr)
	else
		return string.format("$CameraAni_Avatar_Common_TalkToParmon_AvatarTo%s.asset", npcCamAnimStr)
	end
end

function DialogueCtrl:finishDialogue()
	local me = pg.me

	self:clearDialogueInfo()
	pg.game.camera:enableNpcDialogue(false)

	if self.curCameraAnim then
		self.curCameraAnim = nil

		pg.game.camera.playerCameraMode:resetCamera()
	end

	if not self.forbidRecoverAudioState then
		pg.game.audio:trySetState(AudioConst.STATE_GROUP_BGM_VOLUME, AudioConst.BGM_VOLUME_STATE_ID_NORMAL)
	end

	self:clearDialogueBranchOption()

	if self.targetNpc ~= nil then
		for _, id in ipairs(self.pausedNpcIds) do
			self:removeRelatedNpc(id)
		end

		self.pausedNpcIds = {}
		self.targetNpc = nil
	end

	me.isInDialogue = false

	self:stopSpeakersAnimation()

	return true
end

function DialogueCtrl:addSpeakerAnimationInfo(speakerType, entity, isSleAni)
	if entity == nil then
		return
	end

	self.speakerAnimationInfo = self.speakerAnimationInfo or {}
	self.speakerAnimationInfo[entity.id] = {
		entity = entity,
		isSleAni = isSleAni,
		speakerType = speakerType
	}
end

function DialogueCtrl:stopSpeakersAnimation()
	if self.speakerAnimationInfo == nil then
		return
	end

	for _, speakerInfo in pairs(self.speakerAnimationInfo) do
		if speakerInfo.entity then
			if speakerInfo.isSleAni then
				speakerInfo.entity:stopCfgAnimation()
			elseif not speakerInfo.entity:isFullBodyDefaultAnimationPlaying() then
				speakerInfo.entity:stopLayerAnimation(PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
			end
		end
	end

	self.speakerAnimationInfo = {}
end

function DialogueCtrl:clearDialogueInfo()
	if self.hideAnimTimer ~= nil then
		return
	end

	if ToBool(self.finishedCb) then
		for _, cb in ipairs(self.finishedCb) do
			cb()
		end

		self.finishedCb = {}
	end

	self.isPlaying = false
	self.dialogIndex = nil
	self.dialogId = nil
	self.extraText = nil

	self:removeMoveNextTimer()

	self.showBranchOptionFunc = nil
	pg.me.isInDialogue = false
	self.overrideNextBtnCallback = nil

	self:setIsModel(true)
	ClientUtils.tryWithLogError(function()
		self:stopLipMotionAnim()
	end)
	ClientUtils.stopDialogueCameraDof()

	if not self.view then
		return
	end

	self.view.panelAnim:Stop()
	LuaUIUtils.setUIViewVisible(self.view.btnLayout, false)
	self.view.panelAnim:Play("UI_Ani_Dialogue_Hide")

	self.hideAnimTimer = self:startScaleTimer(function()
		self:hide()
		self:killScaleTimer(self.hideAnimTimer)

		self.hideAnimTimer = nil
	end, self.hideAnimTime, false)
end

function DialogueCtrl:showCurrentDialogueInfo(extraInfo)
	local dialogInfos = NpcDialogueData[self.dialogId]
	local dialogInfo = dialogInfos[self.dialogIndex]
	local dialogText = dialogInfo.chat

	self.dialogStartTime = pg.me:getGameTime()

	local localizationText = LuaUIUtils.getReplacedDialogueText(dialogText)

	if self.extraText then
		if dialogInfos and #dialogInfos > 1 then
			if #dialogInfos == self.dialogIndex then
				localizationText = string.format("%s\n%s", localizationText, self.extraText)
			end
		else
			localizationText = string.format("%s\n%s", localizationText, self.extraText)
		end
	end

	ClientUtils.tryWithLogError(function()
		self:tryPlayLipMotionAnim(dialogInfo, extraInfo)
	end)
	self:removeMoveNextTimer()
	self.view:showDialogue()
	self:trySetDialogueName(extraInfo and extraInfo.overrideNameTemplateId)
	ClientTextUtils.setText(self.view.dialogueText, localizationText)

	if self.isPlaying and ToBool(self.curDuration) then
		self:startDialogueTimer(self.curDuration)
	end
end

function DialogueCtrl:tryPlayLipMotionAnim(dialogInfo, extraInfo)
	self:stopLipMotionAnim()

	self.playingCurVoiceName = extraInfo.audioName

	if self.playingCurVoiceName == nil and dialogInfo ~= nil then
		self.playingCurVoiceName = dialogInfo.audioName
	end

	local disableLipMotion = dialogInfo.disableLipMotion or extraInfo and extraInfo.disableLipMotion
	local beginClock = os.clock()

	if not disableLipMotion then
		self.curSpeakingEntity = extraInfo and extraInfo.targetNpc or pg.game.communication:getDialogueEntity(extraInfo and extraInfo.npcId, extraInfo and extraInfo.npcStaticId, self.dialogId, self.dialogIndex)

		if self.curSpeakingEntity then
			self.curSpeakingEntity:playLipMotionAnim()
		end
	end

	self.stopSpeakAnimTimer = self:startScaleTimer(function()
		self:stopLipMotionAnim()
	end, self.curDuration, false)
end

function DialogueCtrl:trySetDialogueName(overrideNameTemplateId)
	local name
	local npcId = -1
	local curDialogues = NpcDialogueData[self.dialogId]
	local curDialogue = curDialogues[self.dialogIndex]
	local npcStaticId = curDialogue.npcStaticId

	if overrideNameTemplateId and overrideNameTemplateId > 0 then
		local npcData = PuppetData[overrideNameTemplateId]

		name = npcData and pg.getLocalizationText(npcData.name)
	elseif npcStaticId then
		npcId = npcStaticId

		if npcStaticId == DialogueConst.SpeakerType.Player then
			name = pg.me.playerName
		else
			local entity = pg.me.space:getEntityByStaticId(npcStaticId)

			if entity then
				name = pg.getLocalizationText(PuppetData[entity.templateId].name)
			end
		end
	else
		npcId = curDialogue.npcId

		local npcName = curDialogue.npcName

		if npcName then
			name = LuaUIUtils.getReplacedDialogueText(npcName)
		elseif npcId == DialogueConst.SpeakerType.Player then
			name = pg.me.playerName
		else
			local npcData = PuppetData[npcId]

			if npcData then
				name = pg.getLocalizationText(npcData.name)
			else
				local templateId = self.targetNpc and self.targetNpc.templateId or 0

				if PuppetData[templateId] and PuppetData[templateId].name then
					name = pg.getLocalizationText(PuppetData[templateId].name)
				else
					local prototypeId = Utils.getPuppetPetPrototypeId(templateId)

					if PetPrototypeData[prototypeId] and PetPrototypeData[prototypeId].name then
						name = pg.getLocalizationText(PetPrototypeData[prototypeId].name)
					end
				end
			end
		end
	end

	LuaUIUtils.setUIViewVisible(self.view.dialogueNamePanel, name ~= nil)
	ClientTextUtils.setText(self.view.dialogueName, name)
	self.view.boxDialogueUComponent:TryChangePage("TitleColor", npcId == DialogueConst.SpeakerType.Player and 1 or 0)
end

function DialogueCtrl:triggerLookAtTarget(speakerEntity, targetEntity)
	if targetEntity and speakerEntity then
		EntityLookAtUtils.setLookAtDialogue(speakerEntity, targetEntity)

		speakerEntity.isInDialogue = true

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@hyj onTriggerLookAt %d -> %d", speakerEntity.actorId, targetEntity.actorId)
		end

		EntityLookAtUtils.doModifyLookAt()
		self:registerFinishCallback(function()
			if speakerEntity then
				EntityLookAtUtils.removeLookAtDialogue(speakerEntity)

				speakerEntity.isInDialogue = false
			end

			EntityLookAtUtils.doModifyLookAt()
		end)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("@hyj triggerLookAtTarget failed", speakerEntity, targetEntity)
	end
end

function DialogueCtrl:registerFinishCallback(cb)
	if not self.finishedCb then
		self.finishedCb = {}
	end

	table.insert(self.finishedCb, cb)
end

function DialogueCtrl:checkCurSpeakerValid(speakerType)
	if speakerType == DialogueConst.SpeakerType.Pet then
		local curPet = pg.me:getCurPetEntity()

		if not curPet then
			return false
		end
	end

	return true
end

function DialogueCtrl:isCurSpeakerNpc(entity)
	if not entity then
		return true
	end

	if Utils.isPlayer(entity) or Utils.isPlayerPet(entity) then
		return false
	end

	return true
end

function DialogueCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function DialogueCtrl:onBranchOptionClick(newDialogId, chooseIndex)
	DialogueUtils.sendDialogueOptionInfoReport(self.dialogId, chooseIndex + 1, pg.me:getGameTime() - self.dialogStartTime)
	self:clearDialogueBranchOption()

	self.dialogIndex = nil
	self.dialogId = nil

	pg.game.communication:showNextDialogInfo(newDialogId, 1, self.targetNpc and self.targetNpc.id, {
		isJump = true
	}, self.customInfo)
end

function DialogueCtrl:refreshDialogueBranchOption(optionList)
	if self.dialogueBranch then
		self.dialogueBranch:refreshDialogueBranchOption(optionList)
	end

	self:refreshCurInteractInfo()
end

function DialogueCtrl:clearDialogueBranchOption()
	self.showBranchOptionFunc = nil

	if self.dialogueBranch then
		self.dialogueBranch:refreshDialogueBranchOption({})
	end

	self:refreshCurInteractInfo()
end

function DialogueCtrl:onSelectItemChange()
	self:refreshCurInteractInfo()
end

function DialogueCtrl:refreshCurInteractInfo()
	self.curInteractInfo = self:innerGetCurInteractInfo()

	facade:SendMessageCommand(MessageName.INTERACT_ITEM_CHANGE, {})
end

function DialogueCtrl:getCurInteractInfo()
	return self.curInteractInfo
end

function DialogueCtrl:innerGetCurInteractInfo()
	if self.dialogueBranch then
		local dialogueItem = self.dialogueBranch:getCurInteractItem()

		if not Utils.tableIsEmptyOrNil(dialogueItem) then
			return dialogueItem
		end
	end

	return nil
end

function DialogueCtrl:triggerOnMouseScroll(delta)
	if self.dialogueBranch and self.dialogueBranch:onMouseScroll(delta) then
		return true
	end

	return false
end

function DialogueCtrl:triggerOnGamepadSwitch(delta)
	if self.dialogueBranch and self.dialogueBranch:onMouseScroll(delta) then
		return true
	end

	return false
end

function DialogueCtrl:onInputDeviceChange()
	if self.waitPlayerChooseOption then
		LuaUIUtils.setUIViewVisible(self.view.nextIcon, false)
		self:ImgNextUWidgetInvoke(false)
		self:BelogginginUWidgetInvoke(false)
	else
		LuaUIUtils.setUIViewVisible(self.view.nextIcon, true)
		self:onEnableStopUI(pg.game.communication:getForbidClickTime() > pg.me:getGameTime() - (self.showClock or 0))
	end

	self.reviewLogHotKey.gameObject:SetActiveEx(pg.game.input:isUsingGamepad())
	self.view.reviewLogIcon.gameObject:SetActiveEx(not pg.game.input:isUsingGamepad())
	self.dialogueBranch:onInputDeviceChange()
end

function DialogueCtrl:onEnableStopUI(enable)
	self:ImgNextUWidgetInvoke(not enable)
	self:BelogginginUWidgetInvoke(enable)
end

function DialogueCtrl:BelogginginUWidgetInvoke(enable)
	LuaUIUtils.setUIVisible(self.view.belogginginUWidget, enable)

	if enable then
		self.view.belogginginUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end
end

function DialogueCtrl:ImgNextUWidgetInvoke(enable)
	if enable then
		LuaUIUtils.setUIVisible(self.view.imgNextUWidget, enable)
		self.view.imgNextUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	else
		self.view.imgNextUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
		LuaUIUtils.setUIVisible(self.view.imgNextUWidget, enable)
	end
end

function DialogueCtrl:SetUIStop(duration)
	self:KillUIStop()

	if duration > 0.01 then
		self:onEnableStopUI(true)

		self.uiStopTimer = self:startScaleTimer(function()
			self.uiStopTimer = nil

			self:onEnableStopUI(false)
		end, duration, false)
	else
		self:onEnableStopUI(false)
	end
end

function DialogueCtrl:KillUIStop()
	if self.uiStopTimer then
		self:killScaleTimer(self.uiStopTimer)

		self.uiStopTimer = nil
	end
end

function DialogueCtrl:stopLipMotionAnim()
	if self.stopSpeakAnimTimer then
		self:killScaleTimer(self.stopSpeakAnimTimer)

		self.stopSpeakAnimTimer = nil
	end

	if self.curSpeakingEntity then
		self.curSpeakingEntity:stopLipMotionAnim()

		self.curSpeakingEntity = nil
	end

	self.playingCurVoiceName = nil
end

function DialogueCtrl:onAudioEventFinish(eventName)
	if eventName ~= self.playingCurVoiceName then
		return
	end

	self:stopLipMotionAnim()
end

return DialogueCtrl
