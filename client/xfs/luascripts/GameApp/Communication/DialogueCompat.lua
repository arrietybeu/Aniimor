-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueCompat.lua

local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local DialogueConst = require("Const.DialogueConst")
local DialogueUIBridge = require("GameApp.Communication.DialogueUIBridge")
local DialogueUtils = require("Utils.DialogueUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local NpcDialogueData = require("Data.npc_dialogue_data")
local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local UIConst = require("Const.UIConst")
local DialogueLookAt = require("GameApp.Communication.DialogueLookAt")
local M = {}
local DialogueResult = {
	None = 0,
	FAILED = 3,
	NORMAL = 2,
	SPECIAL = 1
}

function M:__showDialogText(chatType, dialogueId, index, param, npcEntityId, customInfo)
	if chatType <= DialogueConst.ChatType.NONE or chatType > DialogueConst.ChatType.MAXN then
		self:finishNpcDialog()

		return DialogueResult.None
	end

	local dialogueNodeSetting = {
		chatType = chatType
	}
	local curNpcDialogueData = NpcDialogueData[dialogueId]

	if param.isDialogueGraph then
		dialogueNodeSetting.isDialogueGraph = param.isDialogueGraph
		dialogueNodeSetting.enablePresetLookAt = self.enablePresetLookAt
		dialogueNodeSetting.lookAtId = param.lookAtId or 0
		dialogueNodeSetting.npcId = param.npcId or 0
		dialogueNodeSetting.npcStaticId = param.npcStaticId or -1
	else
		local npcDialogueItem = curNpcDialogueData[index or 1]

		dialogueNodeSetting.isDialogueGraph = false
		dialogueNodeSetting.enablePresetLookAt = false
		dialogueNodeSetting.lookAtId = npcDialogueItem.lookAtId
		dialogueNodeSetting.npcId = npcDialogueItem.npcId
		dialogueNodeSetting.npcStaticId = npcDialogueItem.npcStaticId
	end

	local targetEntity = pg.getEntity(npcEntityId)
	local specialChatTypeHandleFunc = DialogueConst.SPECIAL_CHAT_TYPE_FUNC_MAP[chatType]

	if specialChatTypeHandleFunc ~= nil and self[specialChatTypeHandleFunc] ~= nil then
		if dialogueNodeSetting.isDialogueGraph then
			if chatType == DialogueConst.ChatType.BUBBLE then
				self:triggerAnimAction(dialogueNodeSetting.npcId, dialogueNodeSetting.npcStaticId or param.staticId, dialogueId, index, param.actionId)
			end
		elseif param.src ~= DialogueConst.SrcType.Interaction then
			local isDiffEthnic, dialogType, newDialogueId = DialogueUtils.checkPetsSameEthnicDialogue(pg.pawn, targetEntity)

			dialogueId = newDialogueId or dialogueId
		end

		local status, ret = SafeCallbackWithStatusAndReturn(self[specialChatTypeHandleFunc], self, dialogueId, index, npcEntityId, param)

		if not status and param ~= nil and param.callback ~= nil then
			param.callback()
		end

		return status and ret and DialogueResult.SPECIAL or DialogueResult.FAILED
	end

	local speakerEntity = DialogueLookAt.getSpeaker(self, dialogueNodeSetting)

	if speakerEntity and DialogueLookAt.handleLookAt(self, dialogueNodeSetting) then
		self.triggeredLookAtEntIds[speakerEntity.id] = true
	end

	if not dialogueNodeSetting.isDialogueGraph then
		local triggerSrc = param.src or DialogueConst.SrcType.SIMPLE_EVENT

		if self.srcPriority ~= -1 and triggerSrc > self.srcPriority then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self._logger:error(string.format("dialogueId = %d, 来源优先级低 srcPriority %d triggerSrc %d", dialogueId, self.srcPriority, triggerSrc))
			end

			return DialogueResult.FAILED
		end

		if not self:checkDialoguePriorityValid(chatType, param.overridePriority) then
			return DialogueResult.FAILED
		end

		if self.curChatType ~= chatType then
			self:finishNpcDialog()
		end

		if npcEntityId then
			self.targetEntity = targetEntity or self.targetEntity
		else
			self.targetEntity = nil
		end

		self.srcPriority = param.src or DialogueConst.SrcType.SIMPLE_EVENT
		self.dialogueEventContext.globalId = self.targetEntity ~= nil and self.targetEntity.id or nil
	else
		if self.curChatType ~= DialogueConst.ChatType.NONE and self.curChatType ~= chatType then
			DialogueUIBridge.hideDialogueTextUI()
		end

		if chatType == DialogueConst.ChatType.DIALOGUE then
			pg.game.input:setLockCursor(ClientConst.LockCursorKey.Dialogue, false)

			self.showCursor = true
		end

		self.srcPriority = DialogueConst.SrcType.NONE
	end

	self.curMaxDialogIndex = curNpcDialogueData ~= nil and table.maxn(curNpcDialogueData) or 0
	self.curChatType = chatType
	self.curDialogueId = dialogueId
	self.curDialogueIndex = index
	self.curParam = param

	local normalChatTypeHandleFunc = DialogueConst.CHAT_TYPE_FUNC_MAP[chatType]

	if normalChatTypeHandleFunc == nil or self[normalChatTypeHandleFunc] == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self._logger:warn(string.format("[__showDialogText] 不支持的 chatType=%d dialogueId=%d", chatType, dialogueId))
		end

		self:onClearData()

		return DialogueResult.None
	end

	if dialogueNodeSetting.isDialogueGraph then
		self:__triggerLookAtAndAnimForGraph(chatType, dialogueId, index, param, dialogueNodeSetting.npcId, dialogueNodeSetting.npcStaticId or param.staticId)
	end

	local dialogInfo = curNpcDialogueData ~= nil and curNpcDialogueData[index] or nil
	local isMyAudio = false

	if dialogInfo then
		isMyAudio = dialogInfo.npcId == 0
	end

	self:onDialogueStart(param, chatType, isMyAudio)

	local status, ret = SafeCallbackWithStatusAndReturn(self[normalChatTypeHandleFunc], self, dialogueId, index, npcEntityId, param, customInfo)

	if not status and param ~= nil and param.callback ~= nil then
		param.callback()
	end

	return status and ret and DialogueResult.NORMAL or DialogueResult.FAILED
end

function M:playPlotPhoneCallAnim(npcTemplateId, disableAni, callback)
	local npcName, iconUrl = self:getNpcInfoByTemplateId(npcTemplateId)

	self:stopPlotPhoneCallAnim()

	local info = {
		name = npcName,
		resId = iconUrl,
		disableAni = disableAni,
		callback = callback
	}

	pg.global.ui.plotPhoneCall:open(info)
end

function M:stopPlotPhoneCallAnim()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PLOT_PHONE_CALL) then
		pg.global.ui.plotPhoneCall:close()
	end
end

function M:playSimpleNpcCallAnim(npcTemplateId, callback)
	local npcName, iconUrl = self:getNpcInfoByTemplateId(npcTemplateId)

	self:stopSimpleNpcCallAnim()

	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:open(nil, function()
			pg.global.ui.npcCall.isDialogueGraph = true

			pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
			pg.global.ui.npcCall:show()
		end)

		return
	end

	if not pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall.isDialogueGraph = true

		pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
		pg.global.ui.npcCall:show()

		return
	end

	pg.global.ui.npcCall:showHeadIconUI(npcName, iconUrl, callback)
end

function M:stopSimpleNpcCallAnim()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_NPC_CALL) then
		pg.global.ui.npcCall:hideHeadIconUI()
	end
end

return M
