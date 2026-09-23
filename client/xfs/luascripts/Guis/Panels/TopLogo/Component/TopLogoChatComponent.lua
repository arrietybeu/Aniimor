-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoChatComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local DialogueConst = require("Const.DialogueConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local NpcDialogueData = require("Data.npc_dialogue_data")
local SysConfigData = require("Data.sys_config_data")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local vector3 = require("Common.Math.vector3")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TopLogoChatComponent = Class.LightClass("TopLogoChatComponent", TopLogoItemComponent)

function TopLogoChatComponent:ctor(refUContainer, topLogoItem)
	TopLogoChatComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoChatComponent:onCtor()
	self.m_pendingDialogue = nil

	function self.m_onDialogueScaleUpdate()
		self:m_doDialogueScaleUpdate()
	end

	function self.m_onCustomDialogueHideTimer()
		self:removeTopLogoDialogue()
	end

	function self.m_onChainDialogueAdvance()
		self:m_doChainDialogueAdvance()
	end

	self:refreshVisible()
end

function TopLogoChatComponent:m_doChainDialogueAdvance()
	if not self:checkShowDialogue() then
		self:removeTopLogoDialogue()

		return
	end

	self:tryShowNextDialogue(self.m_curDialogueChainId, self.m_curDialogueChainIdx, self.m_curDialogueChainCallback)
end

function TopLogoChatComponent:m_takeDialogueFinishCallback(fallbackCallback)
	local finishCallback = self.m_curDialogueChainCallback or fallbackCallback

	self.m_curDialogueChainCallback = nil

	return finishCallback
end

function TopLogoChatComponent:m_clearEntityDialogueCache()
	if self.entity and self.entity.topLogoData then
		self.entity.topLogoData.DialogueMsg = nil
	end
end

function TopLogoChatComponent:m_finishDialogueCallback(fallbackCallback)
	self:m_clearEntityDialogueCache()

	local finishCallback = self:m_takeDialogueFinishCallback(fallbackCallback)

	if finishCallback then
		finishCallback()
	end

	return finishCallback
end

function TopLogoChatComponent:m_doDialogueScaleUpdate()
	if self.m_curDialogueId == DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID then
		self:updateDialogueScaleAndOpacity()
	else
		local dialogGraph = NpcDialogueData[self.m_curDialogueId] or {}
		local dialog = dialogGraph[self.m_curDialogueIndex] or {}
		local chatType = dialog.chatType

		if chatType == DialogueConst.ChatType.BUBBLE_SPECIAL then
			self:updateDialogueScaleAndOpacitySpecial()
		else
			self:updateDialogueScaleAndOpacity()
		end
	end
end

function TopLogoChatComponent:shouldBeActive()
	if self.m_pendingDialogue or self.m_cbCacheDialogueInfo then
		return true
	end

	return self.dialogueId ~= nil
end

function TopLogoChatComponent:onDestroy()
	local dialogueMsg = self.entity and self.entity.topLogoData and self.entity.topLogoData.DialogueMsg
	local preserveDialogue = self.entity and self.entity.topLogoInit and dialogueMsg and dialogueMsg[1] == true
	local finishCallback

	if preserveDialogue then
		self.m_curDialogueChainCallback = nil
	else
		finishCallback = self:m_takeDialogueFinishCallback()

		self:m_clearEntityDialogueCache()
	end

	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_DIALOGUE, self.onDialogueMsg)
	end

	if self.hideTimer then
		self:killTimer(self.hideTimer)

		self.hideTimer = nil
	end

	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self.m_pendingDialogue = nil

	TopLogoChatComponent.super.onDestroy(self)

	self.m_cbCacheDialogueInfo = nil
	self.m_loadedDialogueCallBack = nil

	if finishCallback then
		finishCallback()
	end
end

function TopLogoChatComponent:resetRender()
	local dialogueMsg = self.entity and self.entity.topLogoData and self.entity.topLogoData.DialogueMsg
	local preserveDialogue = self.topLogoItem and self.topLogoItem._destroying and self.entity and self.entity.topLogoInit and dialogueMsg and dialogueMsg[1] == true
	local finishCallback

	if not preserveDialogue then
		finishCallback = self:m_takeDialogueFinishCallback()

		self:m_clearEntityDialogueCache()
	end

	if self.hideTimer then
		self:killTimer(self.hideTimer)

		self.hideTimer = nil
	end

	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self.dialogueId = nil
	self.m_pendingDialogue = nil
	self.m_cbCacheDialogueInfo = nil
	self.objectReference = nil
	self.dialogueUWidget = nil
	self.dialogueUText = nil

	TopLogoChatComponent.super.resetRender(self)

	if finishCallback then
		finishCallback()
	end
end

function TopLogoChatComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.dialogueUWidget = self.objectReference:GetRefValue("dialogueUWidget")
	self.dialogueUText = self.objectReference:GetRefValue("dialogueUText")
end

function TopLogoChatComponent:checkShowDialogue()
	if not self.commandVisible then
		return false
	end

	return self:innerGetVisible()
end

function TopLogoChatComponent:checkTopLogoCompUpdate()
	return false
end

function TopLogoChatComponent:onTopLogoCompVisibleChanged(visible, skipRefresh)
	TopLogoChatComponent.super.onTopLogoCompVisibleChanged(self, visible, skipRefresh)

	if visible or self:checkShowDialogue() then
		return
	end

	if self.m_pendingDialogue or self.dialogueId or self.m_cbCacheDialogueInfo then
		self:removeTopLogoDialogue()
	end
end

function TopLogoChatComponent:addEntityListener()
	function self.onDialogueMsg(isVisible, dialogueId, dialogueText, finishCallback, forceShowInCombat, dialogueState)
		dialogueState = dialogueState or self.entity and self.entity.topLogoData and self.entity.topLogoData.DialogueMsg
		self.commandVisible = isVisible

		if self:checkShowDialogue() then
			if finishCallback then
				self.m_curDialogueChainCallback = finishCallback
			end

			self.m_pendingDialogue = {
				dialogueId = dialogueId,
				dialogueText = dialogueText,
				finishCallback = finishCallback,
				forceShowInCombat = forceShowInCombat,
				resumeState = dialogueState
			}

			self:notifyActiveStateChanged(true)

			if not self.topLogoItem:isTopLogoPrefabReady() then
				return
			end

			self.m_pendingDialogue = nil

			self:tryShowTopDialogue(dialogueId, dialogueText, nil, finishCallback, forceShowInCombat, dialogueState)
		else
			self.m_pendingDialogue = nil

			local finishedCallback = self:removeTopLogoDialogue()

			self:notifyActiveStateChanged(self:shouldBeActive())

			if finishCallback and finishCallback ~= finishedCallback then
				finishCallback()
			end
		end
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_DIALOGUE, self.onDialogueMsg)
	end

	if self.entity.topLogoData.DialogueMsg ~= nil then
		local isVisible = self.entity.topLogoData.DialogueMsg[1]
		local dialogueId = self.entity.topLogoData.DialogueMsg[2]
		local dialogueText = self.entity.topLogoData.DialogueMsg[3]
		local finishCallback = self.entity.topLogoData.DialogueMsg[4]
		local forceShowInCombat = self.entity.topLogoData.DialogueMsg[5]
		local dialogueState = self.entity.topLogoData.DialogueMsg

		self.onDialogueMsg(isVisible, dialogueId, dialogueText, finishCallback, forceShowInCombat, dialogueState)
	end
end

function TopLogoChatComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingDialogue then
		local data = self.m_pendingDialogue

		if not self:checkShowDialogue() then
			self.m_pendingDialogue = nil

			if data.finishCallback then
				self:m_finishDialogueCallback(data.finishCallback)
			end

			self:notifyActiveStateChanged(self:shouldBeActive())

			return
		end

		self.m_pendingDialogue = nil

		self:tryShowTopDialogue(data.dialogueId, data.dialogueText, nil, data.finishCallback, data.forceShowInCombat, data.resumeState)

		return
	end
end

function TopLogoChatComponent:tryShowTopDialogue(dialogueId, dialogueText, duration, finishCallback, forceShowInCombat, resumeState)
	if finishCallback then
		self.m_curDialogueChainCallback = finishCallback
	end

	if not forceShowInCombat and self.entity.isInCombat and self.entity:isInCombat() then
		local enableBubbleInCombat = self.entity:getConfigData().enableBubbleInCombat

		if not ToBool(enableBubbleInCombat) then
			self:m_finishDialogueCallback(finishCallback)

			return
		end
	end

	if not self:checkShowDialogue() then
		self:m_finishDialogueCallback(finishCallback)
		self:notifyActiveStateChanged(self:shouldBeActive())

		return
	end

	if dialogueId then
		if self:checkContainerLoaded() then
			self:m_showDialogue(false, dialogueText, dialogueId, forceShowInCombat, duration, finishCallback, resumeState)
		else
			self.m_cbCacheDialogueInfo = {
				dialogueId = dialogueId,
				dialogueText = dialogueText,
				duration = duration,
				finishCallback = finishCallback,
				forceShowInCombat = forceShowInCombat,
				resumeState = resumeState
			}

			if not self.m_loadedDialogueCallBack then
				function self.m_loadedDialogueCallBack(isSuccess)
					local cacheInfo = self.m_cbCacheDialogueInfo

					self.m_cbCacheDialogueInfo = nil

					local cacheFinishCallback = cacheInfo and cacheInfo.finishCallback

					if cacheInfo and isSuccess and self:checkShowDialogue() then
						self:m_showDialogue(true, cacheInfo.dialogueText, cacheInfo.dialogueId, cacheInfo.forceShowInCombat, cacheInfo.duration, cacheFinishCallback, cacheInfo.resumeState)
					elseif cacheFinishCallback then
						self:m_finishDialogueCallback(cacheFinishCallback)
					end

					self:notifyActiveStateChanged(self:shouldBeActive())
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedDialogueCallBack, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
		end
	elseif finishCallback then
		self:m_finishDialogueCallback(finishCallback)
	end
end

function TopLogoChatComponent:m_showDialogue(isAsync, dialogueText, dialogueId, forceShowInCombat, duration, finishCallback, resumeState)
	if dialogueId and self.dialogueId ~= dialogueId then
		self.dialogueId = dialogueId
		self.entity.forceShowBubbleInCombat = forceShowInCombat

		if dialogueId == DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID then
			self:tryShowNextCustomDialogue(dialogueId, dialogueText, duration, resumeState)
		else
			self:tryShowNextDialogue(dialogueId, 0, finishCallback, resumeState)
		end
	elseif finishCallback then
		self:m_finishDialogueCallback(finishCallback)
	end
end

function TopLogoChatComponent:tryShowNextCustomDialogue(dialogueId, dialogueText, duration, resumeState)
	duration = duration or DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION

	if resumeState and resumeState.expireAt then
		duration = resumeState.expireAt - Time.realSecondCache
	end

	if dialogueId == DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID then
		if duration <= 0 then
			self:removeTopLogoDialogue()

			return
		end

		if not self:showDialogue(dialogueText, dialogueId) then
			self:removeTopLogoDialogue()

			return
		end

		if self.hideTimer then
			self:killTimer(self.hideTimer)

			self.hideTimer = nil
		end

		if duration > 0 then
			self.hideTimer = self:startTimer(self.m_onCustomDialogueHideTimer, duration)
		end
	end
end

function TopLogoChatComponent:tryGetDialog(dialogueId, dialogIdx)
	local dialogGraph = NpcDialogueData[dialogueId] or {}
	local dialog = dialogGraph[dialogIdx] or {}
	local dialogDesc = dialog.chat
	local duration = dialog.duration or 3

	return dialogDesc, duration
end

function TopLogoChatComponent:m_resolveDialogueResume(dialogueId, resumeState)
	if dialogueId == nil or not resumeState or not resumeState.startTime then
		return 0, nil
	end

	local elapsed = math.max(0, Time.realSecondCache - resumeState.startTime)
	local dialogGraph = NpcDialogueData[dialogueId] or {}
	local index = 1

	while dialogGraph[index] do
		local duration = tonumber(dialogGraph[index].duration) or 3

		if elapsed < duration then
			return index - 1, duration - elapsed
		end

		elapsed = elapsed - duration
		index = index + 1
	end

	return nil, nil
end

function TopLogoChatComponent:tryShowNextDialogue(dialogueId, dialogIdx, finishCallback, resumeState)
	if finishCallback then
		self.m_curDialogueChainCallback = finishCallback
	end

	local resumeDuration

	if resumeState and resumeState.startTime then
		dialogIdx, resumeDuration = self:m_resolveDialogueResume(dialogueId, resumeState)

		if dialogIdx == nil then
			self:hideDialogue()

			self.entity.forceShowBubbleInCombat = nil
			self.dialogueId = nil

			self:m_finishDialogueCallback(finishCallback)

			return
		end
	end

	local curIdx = dialogIdx + 1
	local dialogueDesc, duration = self:tryGetDialog(dialogueId, curIdx)

	duration = resumeDuration or duration

	if dialogueDesc then
		if not self:showDialogue(dialogueDesc, dialogueId, curIdx) then
			self:removeTopLogoDialogue()

			return
		end

		if self.hideTimer then
			self:killTimer(self.hideTimer)

			self.hideTimer = nil
		end

		self.m_curDialogueChainId = dialogueId
		self.m_curDialogueChainIdx = curIdx
		self.hideTimer = self:startTimer(self.m_onChainDialogueAdvance, duration)
	else
		self:hideDialogue()

		self.entity.forceShowBubbleInCombat = nil
		self.dialogueId = nil

		self:m_finishDialogueCallback(finishCallback)
	end
end

function TopLogoChatComponent:removeTopLogoDialogue()
	local finishCallback = self:m_takeDialogueFinishCallback()

	self:m_clearEntityDialogueCache()

	self.m_pendingDialogue = nil
	self.m_cbCacheDialogueInfo = nil

	self:hideDialogue()

	if self.hideTimer then
		self:killTimer(self.hideTimer)

		self.hideTimer = nil
	end

	self.entity.forceShowBubbleInCombat = nil
	self.dialogueId = nil

	self:notifyActiveStateChanged(self:shouldBeActive())

	if finishCallback then
		finishCallback()
	end

	return finishCallback
end

function TopLogoChatComponent:showDialogue(text, dialogueId, dialogueIndex)
	if not self:checkShowDialogue() then
		return false
	end

	if not self:checkContainerLoaded() then
		return false
	end

	self.dialogueUWidget:SetActiveFastest(true)
	ClientTextUtils.setText(self.dialogueUText, LuaUIUtils.getReplacedDialogueText(text))

	local cameraSystem = pg.game.camera

	if self.scaleTimer then
		cameraSystem:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	self.m_curDialogueId = dialogueId
	self.m_curDialogueIndex = dialogueIndex
	self.scaleTimer = cameraSystem:addLateUpdateTimer(self.m_onDialogueScaleUpdate)

	return true
end

function TopLogoChatComponent:hideDialogue()
	if self.scaleTimer then
		pg.game.camera:removeLateUpdateTimer(self.scaleTimer)

		self.scaleTimer = nil
	end

	if self:checkContainerLoaded() then
		self.dialogueUWidget:SetActiveFastest(false)
	end
end

function TopLogoChatComponent:updateDialogueScaleAndOpacity()
	if not self.dialogueUWidget or not self.dialogueUWidget.gameObjectActive then
		return
	end

	Vector3.enableCreateFromCache()

	local pos = self.entity:getPosition()
	local playerPos = pg.me:getPosition()
	local distance = Utils.distance(pos, playerPos)

	Vector3.disableCreateFromCache()

	local distanceMin = SysConfigData.toplogoNpcDialogueDistance[1]
	local distanceMax = SysConfigData.toplogoNpcDialogueDistance[2]
	local scaleMin = SysConfigData.toplogoNpcDialogueScaleLimit[1]
	local scaleMax = SysConfigData.toplogoNpcDialogueScaleLimit[2]
	local opacityMin = SysConfigData.toplogoNpcDialogueOpacityLimit[1]
	local opacityMax = SysConfigData.toplogoNpcDialogueOpacityLimit[2]
	local scale = 1
	local opacity = 1

	if distance < distanceMin then
		scale = scaleMax
		opacity = opacityMax
	elseif distance < distanceMax then
		local percent = (distance - distanceMin) / (distanceMax - distanceMin)

		scale = lume.lerp(scaleMax, scaleMin, percent)
		opacity = lume.lerp(opacityMax, opacityMin, percent)
	else
		scale = scaleMin
		opacity = opacityMin
	end

	local dialogueVisible = distance <= SysConfigData.NPC_TOPLOGO_DISTANCE

	if not dialogueVisible then
		opacity = 0
	end

	self.dialogueUWidget.transform:SetLocalScaleEx(scale, scale, scale)

	self.dialogueUWidget.renderOpacity = opacity
end

function TopLogoChatComponent:updateDialogueScaleAndOpacitySpecial()
	if not self.dialogueUWidget or not self.dialogueUWidget.gameObjectActive then
		return
	end

	local pos = self.entity:getPosition()
	local playerPos = pg.me:getPosition()
	local distance = Utils.distance(pos, playerPos)
	local distanceMin = SysConfigData.toplogoNpcDialogueLongdistanceDistance[1]
	local distanceMax = SysConfigData.toplogoNpcDialogueLongdistanceDistance[2]
	local scaleMin = SysConfigData.toplogoNpcDialogueLongdistanceScaleLimit[1]
	local scaleMax = SysConfigData.toplogoNpcDialogueLongdistanceScaleLimit[2]
	local opacityMin = SysConfigData.toplogoNpcDialogueLongdistanceScaleLimit[1]
	local opacityMax = SysConfigData.toplogoNpcDialogueLongdistanceScaleLimit[2]
	local scale = 1
	local opacity = 1

	if distance < distanceMin then
		scale = scaleMax
		opacity = opacityMax
	elseif distance < distanceMax then
		local percent = (distance - distanceMin) / (distanceMax - distanceMin)

		scale = lume.lerp(scaleMin, scaleMax, percent)
		opacity = lume.lerp(opacityMin, opacityMax, percent)
	else
		scale = scaleMin
		opacity = opacityMin
	end

	self.dialogueUWidget.transform.localScale = Vector3.one * scale
	self.dialogueUWidget.renderOpacity = opacity
end

function TopLogoChatComponent:getInitMaxDistance()
	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

return TopLogoChatComponent
