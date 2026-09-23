-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\EventStateCheck.lua

local ServerEventConst = require("Const.ServerEventConst")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")

local function checkQuestHadAccept(player, args)
	local questId = args.questId or 0

	return QuestCommonUtils.questAccepted(player, questId)
end

local function checkQuestHadCompleted(player, args)
	local questId = args.questId or 0

	return QuestCommonUtils.questCompleted(player, questId)
end

local function checkChestOpened(player, args)
	local staticId = args.staticId or 0
	local chest = player.space:getEntityByStaticId(staticId)

	if chest and chest:isChestOpened() then
		return true
	end

	return false
end

local function checkCollectItemOpened(player, args)
	local staticId = args.staticId or 0
	local collect = player.space:getEntityByStaticId(staticId)

	if collect and collect:isCollectItemOpened() then
		return true
	end

	return false
end

local function checkCustomTrigger(player, args)
	local customDataId = args.customDataId or 0

	return player.triggerMap:isCompleteOrMeetCondition(customDataId)
end

local function checkNpcSpecialState(player, args)
	local staticId = args.staticId or 0
	local npcSpecialState = args.npcSpecialState or 0
	local specialContext = player.specialContentDict[staticId]

	if specialContext and specialContext == npcSpecialState then
		return true
	end

	return false
end

local function checkNpcBehaviorStatus(player, args)
	local staticId, behaviorId, state = args.staticId or 0, args.behaviorId or 0, args.state or 0
	local npcBehaviorStatus = player.triggerMap.npcBehaviorStatus

	return npcBehaviorStatus and npcBehaviorStatus[staticId] and npcBehaviorStatus[staticId][behaviorId] == state
end

local function checkPuppetAddBuff(player, args)
	local staticId, buffId = args.staticId or 0, args.buffId or 0
	local ent = player.space:getEntityByStaticId(staticId) or {}

	if Utils.isPuppet(ent) then
		return ent.actorBuff:findOneBuffByTemplateId(buffId) ~= nil
	end

	return false
end

local function checkPlayerOrPetAddBuff(player, args)
	local buffId = args.buffId or 0

	if player.actorBuff:findOneBuffByTemplateId(buffId) ~= nil then
		return true
	end

	for petIdx, _ in ipairs(player.petPrepareList) do
		local petEnt = pg.getEntity(player.petPrepareList[petIdx])

		if petEnt and petEnt.actorBuff:findOneBuffByTemplateId(buffId) ~= nil then
			return true
		end
	end

	for petIdx, _ in ipairs(player.petExploreList) do
		local petEnt = pg.getEntity(player.petExploreList[petIdx])

		if petEnt and petEnt.actorBuff:findOneBuffByTemplateId(buffId) ~= nil then
			return true
		end
	end

	return false
end

local function checkAttachDetach(player, args)
	local staticId, attachId = args.staticId or 0, args.attachId or 0
	local ent = player.space:getEntityByStaticId(staticId)

	if ent == nil then
		return false
	end

	if not ent.attachToStaticId then
		return false
	end

	return ent.attachId == attachId and ent.attachToStaticId == 0
end

local function checkDayLight(player, args)
	local space = player.space

	return space and space.timePeriod ~= Const.TimePeriod.Night
end

local function checkDayNignt(player, args)
	local space = player.space

	return space and space.timePeriod == Const.TimePeriod.Night
end

local checkMap = {
	[ServerEventConst.ACCEPT_QUEST] = checkQuestHadAccept,
	[ServerEventConst.COMPLETED_QUEST] = checkQuestHadCompleted,
	[ServerEventConst.OPEN_CHEST] = checkChestOpened,
	[ServerEventConst.CUSTOM_TRIGGER] = checkCustomTrigger,
	[ServerEventConst.NPC_SPECIAL_STATE] = checkNpcSpecialState,
	[ServerEventConst.NPC_BEHAVIOR_STATUS] = checkNpcBehaviorStatus,
	[ServerEventConst.PUPPET_ADD_BUFF] = checkPuppetAddBuff,
	[ServerEventConst.PLAYERORPET_ADD_BUFF] = checkPlayerOrPetAddBuff,
	[ServerEventConst.ATTACH_DETACH] = checkAttachDetach,
	[ServerEventConst.ENTER_DAYLIGHT] = checkDayLight,
	[ServerEventConst.ENTER_NIGHT] = checkDayNignt,
	[ServerEventConst.OPEN_COLLECT_ITEM] = checkCollectItemOpened
}

return checkMap
