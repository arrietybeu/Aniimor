-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\NpcInteract\\SpecialInteract.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local InteractionConst = require("Common.Const.InteractionConst")
local InteractData = require("Data.interact_data")
local SysEventData = require("Data.sys_event_data")
local Const = require("Common.Const.Const")
local DialogueConst = require("Const.DialogueConst")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local SpecialInteract = {}

function SpecialInteract:getData()
	if self.staticId == nil or self.staticId == 0 then
		return nil
	end

	local eventIds = pg.me.npcSpecialInteractsMap[self.staticId]

	if eventIds == nil then
		return nil
	end

	local data = {}

	for idx, eventId in ipairs(eventIds) do
		local curEventData = SysEventData[eventId]

		if curEventData then
			local eventInteractId = curEventData.eventParam[2]
			local eventName = curEventData.eventParam[3]
			local maxTriggerCnt = tonumber(curEventData.eventParam[5]) or 0
			local triggerCnt = pg.me.npcSpecialInteractsCnt[self.staticId] and pg.me.npcSpecialInteractsCnt[self.staticId][idx] or 0

			if (maxTriggerCnt <= 0 or triggerCnt < maxTriggerCnt) and not pg.me:checkBanNpcDuelFunc(self.id, eventName) then
				local questId = SysEventData[eventId].context and SysEventData[eventId].context[1]

				table.insert(data, {
					checkEntity = true,
					globalId = self:getGlobalId(),
					interactionType = InteractionConst.INTERACTION_TYPE_NPC_SPECIAL_INTERACTION,
					actionPrototypeId = idx * 100000 + eventInteractId,
					handlePetEthnicGroup = eventName == "playDialogueGraph" or eventName == "reportReward",
					eventType = eventName,
					interactFunc = function()
						if self.onlyTriggerClientEvent then
							pg.me:doEventByData({
								eventName,
								SysEventData[eventId].eventParam[4]
							}, data[idx])
						else
							pg.me:serverMsg("RPC_CS_Interact", Const.IACT_TP_NPC_SPECIAL, self.id, eventInteractId, {
								specialInteractEventId = eventId
							}, function(ret, retArgs)
								if NoticeDef.SUCCESS ~= ret then
									if ret >= NoticeDef.ERROR_1 and ret <= NoticeDef.ERROR_9 then
										if LoggerManager.checkLogger(LoggerConst.ERROR) then
											self.logger:error("RPC_SC_Interact ", ret, inspect(retArgs))
										end
									else
										ClientUtils.showBubbleMessage(ret, unpack(retArgs or {}))
									end
								end
							end)
						end
					end,
					questId = questId,
					dialogueSrc = DialogueConst.SrcType.Interaction
				})
			end
		end
	end

	return data
end

function SpecialInteract.checkInteractValid(staticId, interactId)
	if staticId == nil or staticId == 0 or interactId == nil then
		return false
	end

	if pg.me == nil or pg.me.npcSpecialInteractsMap == nil then
		return false
	end

	local eventIds = pg.me.npcSpecialInteractsMap[staticId]

	if eventIds == nil then
		return false
	end

	local entity = pg.me.space and pg.me.space:getEntityByStaticId(staticId)

	for idx, eventId in ipairs(eventIds) do
		local curEventData = SysEventData[eventId]

		if curEventData and tonumber(curEventData.eventParam[2]) == interactId then
			local eventName = curEventData.eventParam[3]
			local maxTriggerCnt = tonumber(curEventData.eventParam[5]) or 0
			local triggerCnt = pg.me.npcSpecialInteractsCnt[staticId] and pg.me.npcSpecialInteractsCnt[staticId][idx] or 0

			if (maxTriggerCnt <= 0 or triggerCnt < maxTriggerCnt) and not pg.me:checkBanNpcDuelFunc(entity and entity.id, eventName) then
				return true
			end
		end
	end

	return false
end

function SpecialInteract:onEnter()
	self._specialInteractionData = SpecialInteract.getData(self)

	if self._specialInteractionData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, self._specialInteractionData)
	end
end

function SpecialInteract:onLeave()
	if self._specialInteractionData then
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, self._specialInteractionData)

		self._specialInteractionData = nil
	end
end

function SpecialInteract:contributeDist()
	local interactiveDist = 0
	local data = SpecialInteract.getData(self)

	if ToBool(data) then
		for _, item in ipairs(data) do
			if item.actionPrototypeId then
				local realActionPrototypeId = item.actionPrototypeId % 100000
				local interactData = InteractData[realActionPrototypeId]

				if interactData then
					interactiveDist = math.max(interactiveDist, interactData.interactiveDist or 0, interactData.interactiveIconDist or 0)
				end
			end
		end
	end

	return interactiveDist
end

return SpecialInteract
