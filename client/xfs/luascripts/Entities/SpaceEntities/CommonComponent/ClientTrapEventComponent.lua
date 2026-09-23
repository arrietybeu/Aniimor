-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientTrapEventComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ClientConst = require("Const.ClientConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local TrapEventData = require("Data.trap_event_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local PlayableConst = require("Common.Const.PlayableConst")
local BubbleGroupData = require("Data.bubble_group_data")
local PuppetData = require("Data.puppet_data")
local MessageName = require("Const.MessageName")
local PetConfigData = require("Data.pet_config_data")
local PetRandomTextData = require("Data.pet_random_text_data")
local TimerManager = require("Core.Timer.TimerManager")
local DialogueConst = require("Const.DialogueConst")
local EventConst = require("Const.EventConst")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local ClientTrapEventComponent = Class.Component("ClientTrapEventComponent")
local DEFAULT_BUBBLE_DISTANCE = 8
local DEFAULT_BUBBLE_CD = 10
local DEFAULT_BUBBLE_IDX = -1

function ClientTrapEventComponent:start()
	self.playerTrapEventTSInfo = {}
	self.characterRandomBubbleCheckCDInfo = nil

	function self.onBubbleGroup(interId)
		self:onNpcInteractBubbleGroup(interId)
	end

	pg.global.eventEmitter:addEventListener(EventConst.NPC_INTERACT_BUBBLE_GROUP, self.onBubbleGroup)

	self.bubbleGroupTimerIds = {}
end

function ClientTrapEventComponent:getTrapEventMaxDistance()
	local dist = 0

	if self.randomBubbleTextData then
		dist = PetConfigData.bubble_distance
	end

	if self.dynamicBubbleData then
		dist = math.max(dist, self.dynamicBubbleData.distance)
	end

	if self.entityBubbleData then
		dist = math.max(dist, self.entityBubbleData.distance)
	end

	local trapEventData = self:tryGetTrapEventData()

	if trapEventData and trapEventData.trapEvent then
		local trapEvents = trapEventData.trapEvent or {}

		for _, trapEvent in pairs(trapEvents) do
			local trapDist = trapEvent[1] or 0

			dist = math.max(dist, trapDist)
		end
	end

	if pg.me and pg.me.npcDialogueBubbleId and pg.me.npcDialogueBubbleId[self.staticId] then
		dist = math.max(dist, DEFAULT_BUBBLE_DISTANCE)
	end

	return dist
end

function ClientTrapEventComponent:onTriggerEnter(userData)
	if userData == ClientConst.TriggerType.TRAP_EVENT then
		self:onEnterTrapEventTrigger()
	end
end

function ClientTrapEventComponent:onTriggerExit(userData)
	if userData == ClientConst.TriggerType.TRAP_EVENT then
		self:onLeaveTrapEventTrigger()
	end
end

function ClientTrapEventComponent:onEnterTrapEventTrigger()
	facade:SendMessageCommand(MessageName.TRAP_EVENT_TRIGGER, {
		globalId = self:getGlobalId(),
		ent = self
	})
end

function ClientTrapEventComponent:onLeaveTrapEventTrigger()
	facade:SendMessageCommand(MessageName.TRAP_EVENT_LEAVE, {
		globalId = self:getGlobalId()
	})

	if self.leaveTriggerEvents and #self.leaveTriggerEvents > 0 then
		for _, interId in ipairs(self.leaveTriggerEvents) do
			pg.me:doEvent(interId, {
				globalId = self:getGlobalId()
			})
		end

		self.leaveTriggerEvents = {}
	end

	local trapEventData = self:tryGetTrapEventData()

	if trapEventData then
		local trapEvents = trapEventData.trapEvent or {}

		for idx, trapEvent in pairs(trapEvents) do
			local trapCD = trapEvent[2]

			if trapCD == -1 then
				self.playerTrapEventTSInfo[idx] = nil
			end
		end
	end
end

function ClientTrapEventComponent:onEnterSpace()
	local pdd = PuppetData[self.templateId]
	local useRandomBubbleText = pdd and ToBool(pdd.use_randomtxt) or false

	if useRandomBubbleText then
		self.randomBubbleTextData = self:getRandomBubbleData()
		self.lastSelectedRandomBubbleIndex = nil
	end

	self.entityBubbleData = self:getEntityBubbleData()

	self:refreshTrapEventTrigger()
end

function ClientTrapEventComponent:refreshTrapEventTrigger()
	local newDist = self:getTrapEventMaxDistance()

	if newDist > 0 then
		if newDist ~= self.trapEventDist and self.eModel then
			self.trapEventDist = newDist

			if not self.trapEventTriggerId then
				self.trapEventTriggerId = self.eModel:CreateSphereTrigger(ClientConst.TriggerType.TRAP_EVENT, self.trapEventDist)
			else
				self.eModel:ResizeTrigger(self.trapEventTriggerId, self.trapEventDist)
			end

			self:tryEnterTrapEventTriggerImmediately()
		end
	else
		if self.trapEventTriggerId then
			self.eModel:DestroyTrigger(self.trapEventTriggerId)

			self.trapEventTriggerId = nil
		end

		self.trapEventDist = 0
	end
end

function ClientTrapEventComponent:tryEnterTrapEventTriggerImmediately()
	if not self.trapEventTriggerId or not self.trapEventDist or self.trapEventDist <= 0 then
		return
	end

	local playerPos = pg.playerPos
	local pos = playerPos and self:getPosition()

	if not pos then
		return
	end

	if Utils.distance(pos, playerPos) > self.trapEventDist then
		return
	end

	self:onEnterTrapEventTrigger()
end

function ClientTrapEventComponent:tryTriggerEvent(distance)
	if self:tryTriggerEventFromCfg(distance) then
		return
	elseif pg.me and pg.me.npcDialogueBubbleId and pg.me.npcDialogueBubbleId[self.staticId] and distance <= DEFAULT_BUBBLE_DISTANCE and self.active and self.visible and not self:checkTrapEventInCD(DEFAULT_BUBBLE_IDX, DEFAULT_BUBBLE_CD) then
		self:tryTriggerDialogue(pg.me.npcDialogueBubbleId[self.staticId])
		self:setTrapEventTS(DEFAULT_BUBBLE_IDX)
	end
end

function ClientTrapEventComponent:tryTriggerEventFromCfg(distance)
	self:triggerExtraBubbleEvent(distance)

	local trapEventData = self:tryGetTrapEventData()

	if not trapEventData then
		return false
	end

	if not self:checkTrapEventCondition(trapEventData) then
		return false
	end

	if trapEventData.trapEvent then
		local trapEvents = trapEventData.trapEvent or {}

		for idx, trapEvent in pairs(trapEvents) do
			local trapDist = trapEvent[1]
			local trapCD = trapEvent[2]
			local probType = trapEvent[3]
			local trapGroup = trapEvent[4]
			local trapConditions = trapEvent[5]
			local conditionValid = true

			if trapConditions then
				for _, conditionId in ipairs(trapConditions) do
					if not pg.me.triggerMap:isCompleteOrMeetCondition(conditionId) then
						conditionValid = false

						break
					end
				end
			end

			if distance <= trapDist and self.active and self.visible and not self:checkTrapEventInCD(idx, trapCD) and conditionValid then
				self:doTrapGroup(trapGroup, probType)
				self:setTrapEventTS(idx)

				return true
			end
		end
	end

	return false
end

function ClientTrapEventComponent:tryGetTrapEventData()
	if self.spTrapEventId then
		return TrapEventData[self.spTrapEventId]
	end

	if self.trapEventId then
		return TrapEventData[self.trapEventId]
	end

	if self.tryGetNpcTrapEventId then
		local trapEventId = self:tryGetNpcTrapEventId()

		if trapEventId then
			return TrapEventData[trapEventId]
		end
	end
end

function ClientTrapEventComponent:checkTrapEventCondition(trapEventData)
	if trapEventData.trapCondition then
		local player = pg.me

		for _, condition in ipairs(trapEventData.trapCondition) do
			if not player.triggerMap:isCompleteOrMeetCondition(condition) then
				return false
			end
		end
	end

	return true
end

function ClientTrapEventComponent:doTrapGroup(trapGroup, probType)
	if not trapGroup then
		return
	end

	if probType == ClientConst.NPC_INTERACT.PROB_TYPE_0 then
		for _, trapInfo in ipairs(trapGroup) do
			local prob = trapInfo[#trapInfo]

			if prob < math.random() then
				return
			end

			self:tryDoTrapByInfo(trapInfo)
		end
	elseif probType == ClientConst.NPC_INTERACT.PROB_TYPE_1 then
		local weights = {}

		for _, info in ipairs(trapGroup) do
			weights[#weights + 1] = info[#info]
		end

		local index = lume.weightedchoice(weights)
		local trapInfo = trapGroup[index]

		self:tryDoTrapByInfo(trapInfo)
	end
end

function ClientTrapEventComponent:tryDoTrapByInfo(trapInfo)
	local trapType = trapInfo[1]
	local interId = trapInfo[2]

	if trapType == ClientConst.NPC_INTERACT.DIALOGUE then
		self:tryTriggerDialogue(interId)
	elseif trapType == ClientConst.NPC_INTERACT.ACTION then
		if type(interId) == "table" then
			if self.playCfgAnimation then
				self:playCfgAnimation(interId, PlayableConst.AnimationLayer.LAYER_FULLBODY)
			end
		elseif self.playAnimation then
			self:playAnimation(PlayableConst[interId], nil, nil, nil, PlayableConst.AnimationLayer.LAYER_FULLBODY)
		end
	elseif trapType == ClientConst.NPC_INTERACT.AUDIO then
		pg.game.audio:triggerEvent(interId)
	elseif trapType == ClientConst.NPC_INTERACT.BUBBLE_GROUP then
		self:tryTriggerBubbleGroup(interId)
	elseif trapType == ClientConst.NPC_INTERACT.TOP_EMOJI_BUBBLE then
		self:tryTrapEventShowEmojiBubble(interId, trapInfo[3])
	elseif trapType == ClientConst.NPC_INTERACT.PLOT_DIALOGUE then
		self:tryTriggerPlotDialogue(interId)
	elseif trapType == ClientConst.NPC_INTERACT.CUSTOM_EVENT then
		pg.me:doEvent(interId, {
			globalId = self:getGlobalId()
		})
	elseif trapType == ClientConst.NPC_INTERACT.LEAVE_EVENT then
		if self.leaveTriggerEvents == nil then
			self.leaveTriggerEvents = {}
		end

		table.insert(self.leaveTriggerEvents, interId)
	end
end

function ClientTrapEventComponent:tryTriggerDialogue(dialogueId)
	local showDialogueId

	if pg.me.npcDialogueBubbleId then
		showDialogueId = pg.me.npcDialogueBubbleId[self.staticId]

		if type(showDialogueId) == "number" and showDialogueId > 0 then
			if NpcDialogueData[showDialogueId] == nil then
				showDialogueId = dialogueId
			end
		else
			showDialogueId = dialogueId
		end
	else
		showDialogueId = dialogueId
	end

	pg.game.communication:startNpcDialog(showDialogueId, self.id)
end

function ClientTrapEventComponent:tryTrapEventShowEmojiBubble(emojiName, duration)
	self.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, duration)
end

function ClientTrapEventComponent:checkTrapEventInCD(trapEventIdx, CD)
	if not self.playerTrapEventTSInfo[trapEventIdx] then
		return false
	end

	if not CD or CD == -1 then
		return true
	end

	local now = Time.realSecondCache

	if CD > now - self.playerTrapEventTSInfo[trapEventIdx] then
		return true
	end

	return false
end

function ClientTrapEventComponent:setTrapEventTS(trapEventIdx)
	local now = Time.realSecondCache

	self.playerTrapEventTSInfo[trapEventIdx] = now
end

function ClientTrapEventComponent:tryTriggerBubbleGroup(interId)
	pg.global.eventEmitter:emit(EventConst.NPC_INTERACT_BUBBLE_GROUP, interId)
end

function ClientTrapEventComponent:onNpcInteractBubbleGroup(interId)
	self.dialogueTimer = nil

	for i = 1, #BubbleGroupData[interId] do
		if table.contains(BubbleGroupData[interId][i].staticIds, self.staticId) and self:calDialogueDistance() == true then
			self.bubbleGroupTimerIds[#self.bubbleGroupTimerIds + 1] = TimerManager.addTimer(BubbleGroupData[interId][i].time, function()
				if BubbleGroupData[interId][i].text ~= nil and self:calDialogueDistance() == true then
					TimerManager.removeTimer(self.dialogueTimer)
					self:emitGroupBubble(interId, i)

					self.dialogueTimer = TimerManager.addTimer(BubbleGroupData[interId][i].duration, function()
						self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, false, DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, nil)
					end)
				end

				if BubbleGroupData[interId][i].anim ~= nil and self.playAnimation then
					if BubbleGroupData[interId][i].anim[2] ~= nil and BubbleGroupData[interId][i].anim[2] == 0 then
						self:playAnimation(BubbleGroupData[interId][i].anim[1])
					elseif BubbleGroupData[interId][i].anim[2] ~= nil and BubbleGroupData[interId][i].anim[2] == 1 then
						self:playAnimation(BubbleGroupData[interId][i].anim[1], true)
					end
				end
			end)
		end
	end
end

function ClientTrapEventComponent:calDialogueDistance()
	local selfPos = self:getPosition()
	local cameraPos = pg.game.camera:getSceneViewPos()
	local cameraDist = Utils.distance(selfPos, cameraPos)

	return cameraDist <= SysConfigData.NPC_TOPLOGO_DISTANCE
end

function ClientTrapEventComponent:emitGroupBubble(interId, index)
	local npcTemplateId = self.templateId or 0
	local npcData = PuppetData[npcTemplateId]

	if npcData and npcData.npcType == DialogueConst.NpcType.Pet and (pg.me:isControllingMaster() or pg.me:isControllingPet() and not Utils.isPetsCanCommunicate(self, pg.pawn)) then
		self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, npcData.unknowDialogue)

		return
	end

	self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, BubbleGroupData[interId][index].text)
end

function ClientTrapEventComponent:triggerExtraBubbleEvent(distance)
	if self.dynamicBubbleData ~= nil and self:tryTriggerDynamicBubble(distance) then
		return
	end

	if self.entityBubbleData ~= nil and self:tryTriggerEntityBubble(distance) then
		return
	end

	if self.randomBubbleTextData ~= nil and self:tryTriggerCharacterRandomBubble(distance) then
		return
	end
end

function ClientTrapEventComponent:getEntityBubbleData()
	local ret

	if self.staticSceneEntityData and self.staticSceneEntityData.trapDialogueId then
		ret = {
			distance = self.staticSceneEntityData.trapDialogueDist,
			bubbleId = self.staticSceneEntityData.trapDialogueId,
			cd = self.staticSceneEntityData.trapDialogueCd
		}
	end

	return ToBool(ret) and ret or nil
end

function ClientTrapEventComponent:tryTriggerEntityBubble(distance)
	local triggerDistance = self.entityBubbleData.distance
	local bubbleCd = self.entityBubbleData.cd

	if triggerDistance < distance then
		return false
	end

	if not ClientUtils.checkEntityCanBeInteracted(self, true) then
		return false
	end

	if self:checkTrapEventInCD(ClientConst.EntityBubbleEvent, bubbleCd) then
		return false
	end

	self:setTrapEventTS(ClientConst.EntityBubbleEvent)
	self:tryTriggerDialogue(self.entityBubbleData.bubbleId)

	return true
end

function ClientTrapEventComponent:getRandomBubbleData()
	local ret

	if self.staticSceneEntityData and self.staticSceneEntityData.puppetBubbles then
		ret = {}

		for _, bubbleData in ipairs(self.staticSceneEntityData.puppetBubbles) do
			table.insert(ret, {
				weight = bubbleData.weight,
				textId = bubbleData.id
			})
		end

		if ToBool(self.staticSceneEntityData.isCancelBubble) then
			return ret
		end
	end

	local prototypeId = Utils.getPuppetPetPrototypeId(self.templateId)
	local randomTextData = PetRandomTextData[prototypeId]

	if randomTextData then
		local petNature = self.nature or 0

		if ret == nil then
			ret = {}
		end

		for _, info in pairs(randomTextData) do
			if info.pet_nature == petNature and info.randomText ~= nil then
				table.insert(ret, {
					weight = info.weight,
					text = info.randomText
				})
			end
		end
	end

	return ToBool(ret) and ret or nil
end

function ClientTrapEventComponent:checkCharacterRandomBubbleInCheckCD(cd)
	if self.characterRandomBubbleCheckCDInfo == nil then
		return false
	end

	local now = Time.realSecondCache

	if cd > now - self.characterRandomBubbleCheckCDInfo then
		return true
	end

	return false
end

function ClientTrapEventComponent:tryTriggerCharacterRandomBubble(distance)
	local triggerDistance = PetConfigData.bubble_distance
	local bubbleCd = PetConfigData.bubble_cd
	local bubbleCheckCd = PetConfigData.interval
	local triggerProb = PetConfigData.bubble_prob

	if triggerDistance < distance then
		return false
	end

	if not ClientUtils.checkEntityCanBeInteracted(self, true) then
		return false
	end

	if ClientUtils.checkTargetEntityDifferentEthnicGroupWithPawn(self) then
		return false
	end

	if self:checkTrapEventInCD(DialogueConst.CHARACTER_RANDOM_BUBBLE, bubbleCd) then
		return false
	end

	if self:checkCharacterRandomBubbleInCheckCD(bubbleCheckCd) then
		return false
	end

	if triggerProb < math.random() then
		return false
	end

	self:setTrapEventTS(DialogueConst.CHARACTER_RANDOM_BUBBLE)

	self.characterRandomBubbleCheckCDInfo = Time.realSecondCache

	local text, textId = self:getWeightedRandomBubbleText()

	if textId ~= nil then
		self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, textId)
	elseif text ~= nil then
		self.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, text)
	end

	return true
end

function ClientTrapEventComponent:getWeightedRandomBubbleText()
	local weights = {}

	for index, info in ipairs(self.randomBubbleTextData) do
		if self.lastSelectedRandomBubbleIndex ~= index then
			weights[#weights + 1] = info.weight
		else
			weights[#weights + 1] = 0
		end
	end

	local index = lume.weightedchoice(weights) or 1

	self.lastSelectedRandomBubbleIndex = index

	return self.randomBubbleTextData[index].text, self.randomBubbleTextData[index].textId
end

function ClientTrapEventComponent:tryTriggerDynamicBubble(distance)
	local triggerDistance = self.dynamicBubbleData.distance
	local bubbleCd = self.dynamicBubbleData.cd

	if triggerDistance < distance then
		return false
	end

	if not ClientUtils.checkEntityCanBeInteracted(self, true) then
		return false
	end

	if self:checkTrapEventInCD(ClientConst.DynamicBubbleEvent, bubbleCd) then
		return false
	end

	self:setTrapEventTS(ClientConst.DynamicBubbleEvent)
	self:tryTriggerDialogue(self.dynamicBubbleData.bubbleId)

	return true
end

function ClientTrapEventComponent:addDynamicBubble(bubbleId, bubbleDistance, bubbleCd)
	self.dynamicBubbleData = {
		bubbleId = bubbleId,
		distance = bubbleDistance,
		cd = bubbleCd
	}

	self:refreshTrapEventTrigger()
end

function ClientTrapEventComponent:removeDynamicBubble(bubbleId)
	if self.dynamicBubbleData ~= nil and self.dynamicBubbleData.bubbleId == bubbleId then
		self.dynamicBubbleData = nil

		self:refreshTrapEventTrigger()
	end
end

function ClientTrapEventComponent:destroy()
	for _, timerId in pairs(self.bubbleGroupTimerIds or EMPTY_TABLE) do
		TimerManager.removeTimer(timerId)
	end

	TimerManager.removeTimer(self.dialogueTimer)
	self:onLeaveTrapEventTrigger()
	self:destroyListeners()

	self.onBubbleGroup = nil
end

function ClientTrapEventComponent:destroyListeners()
	pg.global.eventEmitter:removeEventListener(EventConst.NPC_INTERACT_BUBBLE_GROUP, self.onBubbleGroup)
end

return ClientTrapEventComponent
