-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\AITick\\AITickModule2Perception.lua

local Time = require("Core.Common.Time")
local ListPool = require("Common.Container.ListPool")
local Utils = require("Common.Utils.Utils")
local PERCEPTION_QUEUE_POOL_TYPE = 3
local PERCEPTION_READY_STRIDE = 3
local PERCEPTION_READY_COMPACT_MIN_CONSUMED = 32
local PERCEPTION_READY_MIN_REMAINING_RATIO = 0.4
local CLIENT_PERCEPTION_ADVANCE_FRAMES = 10
local CLIENT_PERCEPTION_MAX_COUNT_PER_FRAME = 2
local SERVER_PERCEPTION_ADVANCE_FRAMES = 1
local SERVER_PERCEPTION_MAX_COUNT_PER_FRAME = 30
local AITickModule2Perception = {}
local math_max = math.max
local math_min = math.min

function AITickModule2Perception._compactPerceptionReadyQueue(queue, queueLength, head)
	local consumedLength = head - 1
	local pendingLength = queueLength - consumedLength
	local minConsumedLength = PERCEPTION_READY_COMPACT_MIN_CONSUMED * PERCEPTION_READY_STRIDE

	if consumedLength < minConsumedLength or consumedLength < pendingLength then
		return head
	end

	for index = 1, pendingLength do
		queue[index] = queue[consumedLength + index]
	end

	for index = pendingLength + 1, queueLength do
		queue[index] = nil
	end

	return 1
end

function AITickModule2Perception._finishPerceptionReadyQueue(queue, queueLength, head)
	if queueLength < head then
		for index = 1, queueLength do
			queue[index] = nil
		end

		return 1
	end

	return AITickModule2Perception._compactPerceptionReadyQueue(queue, queueLength, head)
end

function AITickModule2Perception.initPerceptionTick(tickModule)
	tickModule.perceptionReadyQueue = ListPool.getList(PERCEPTION_QUEUE_POOL_TYPE)
	tickModule.perceptionReadyHead = 1
	tickModule.petPerceptionReadyQueue = ListPool.getList(PERCEPTION_QUEUE_POOL_TYPE)
	tickModule.petPerceptionReadyHead = 1

	if Utils.checkClient() then
		tickModule.perceptionAdvanceFrames = CLIENT_PERCEPTION_ADVANCE_FRAMES
		tickModule.perceptionMaxCountPerFrame = CLIENT_PERCEPTION_MAX_COUNT_PER_FRAME
	else
		tickModule.perceptionAdvanceFrames = SERVER_PERCEPTION_ADVANCE_FRAMES
		tickModule.perceptionMaxCountPerFrame = SERVER_PERCEPTION_MAX_COUNT_PER_FRAME
	end

	local limitTime = tickModule.limitTime or 0

	tickModule.perceptionReadyAdmissionDeadlineUs = limitTime > 0 and limitTime * (1 - PERCEPTION_READY_MIN_REMAINING_RATIO) or 0
end

function AITickModule2Perception.destroyPerceptionTick(tickModule)
	ListPool.returnList(tickModule.perceptionReadyQueue, PERCEPTION_QUEUE_POOL_TYPE)
	ListPool.returnList(tickModule.petPerceptionReadyQueue, PERCEPTION_QUEUE_POOL_TYPE)

	tickModule.petPerceptionReadyQueue = nil
	tickModule.petPerceptionReadyHead = 1
	tickModule.perceptionReadyQueue = nil
	tickModule.perceptionReadyHead = 1
	tickModule.perceptionAdvanceFrames = nil
	tickModule.perceptionMaxCountPerFrame = nil
	tickModule.perceptionReadyAdmissionDeadlineUs = nil
end

function AITickModule2Perception.initPerceptionEntityInfo(entityInfo)
	entityInfo.perceptionBucketIndex = nil
	entityInfo.perceptionCycle = 1
	entityInfo.perceptionAttemptedCycle = 0
end

function AITickModule2Perception.schedulePerceptionTick(tickModule, entityInfo, interval)
	local advanceFrames = math_min(math_max(interval - 1, 0), math_max(tickModule.perceptionAdvanceFrames or 0, 0))

	if advanceFrames > 0 then
		local perceptionIndex = tickModule:getValidBucketIndex(tickModule.bucketIndex + interval - advanceFrames)

		entityInfo.perceptionBucketIndex = perceptionIndex

		tickModule:appendBucketEntry(perceptionIndex, entityInfo)
	else
		entityInfo.perceptionBucketIndex = nil
	end
end

function AITickModule2Perception.processPerceptionBucketEntry(tickModule, entityInfo, bucketIndex)
	if entityInfo.perceptionBucketIndex ~= bucketIndex then
		return false
	end

	if not AITickModule2Perception.enqueuePerceptionReady(tickModule, entityInfo) then
		return false
	end

	entityInfo.perceptionBucketIndex = nil

	return true
end

function AITickModule2Perception._appendPerceptionReady(queue, entityInfo)
	queue[#queue + 1] = entityInfo.actorId
	queue[#queue + 1] = entityInfo.registrationGeneration
	queue[#queue + 1] = entityInfo.perceptionCycle
end

function AITickModule2Perception.enqueuePerceptionReady(tickModule, entityInfo)
	local entity = tickModule:getEntity(entityInfo)

	if entity == nil then
		return false
	end

	local queue = tickModule.perceptionReadyQueue

	if Utils.isPet(entity, true) then
		queue = tickModule.petPerceptionReadyQueue
	end

	AITickModule2Perception._appendPerceptionReady(queue, entityInfo)

	return true
end

function AITickModule2Perception.attemptPerception(tickModule, entityInfo)
	local entity = tickModule:getEntity(entityInfo)

	if entity == nil then
		return false
	end

	local cycle = entityInfo.perceptionCycle

	entityInfo.perceptionAttemptedCycle = cycle

	entity:tryTickPerception()

	return true
end

function AITickModule2Perception.attemptPerceptionBeforeAITick(tickModule, entityInfo)
	if entityInfo.perceptionAttemptedCycle ~= entityInfo.perceptionCycle then
		AITickModule2Perception.attemptPerception(tickModule, entityInfo)
	end
end

function AITickModule2Perception.finishPerceptionCycle(entityInfo)
	entityInfo.perceptionCycle = entityInfo.perceptionCycle + 1
end

function AITickModule2Perception._processPerceptionReadyQueue(tickModule, queue, head, startTime, attemptCount, budgetExhausted, budgetUs, maxCount)
	local queueLength = #queue

	while head <= queueLength do
		local actorId = queue[head]
		local generation = queue[head + 1]
		local cycle = queue[head + 2]
		local entityInfo = tickModule.tickEntsInfo[actorId]
		local stale = entityInfo == nil or not entityInfo.valid or entityInfo.registrationGeneration ~= generation or entityInfo.perceptionCycle ~= cycle or entityInfo.perceptionAttemptedCycle == cycle or tickModule:getEntity(entityInfo) == nil

		if stale then
			head = head + PERCEPTION_READY_STRIDE
		else
			if maxCount > 0 and maxCount <= attemptCount or budgetExhausted then
				break
			end

			if attemptCount == 0 and budgetUs > 0 and budgetUs <= Time.getMicrosecond() - startTime then
				budgetExhausted = true

				break
			end

			head = head + PERCEPTION_READY_STRIDE

			AITickModule2Perception.attemptPerception(tickModule, entityInfo)

			attemptCount = attemptCount + 1

			if budgetUs > 0 then
				budgetExhausted = budgetUs <= Time.getMicrosecond() - startTime
			end
		end
	end

	head = AITickModule2Perception._finishPerceptionReadyQueue(queue, queueLength, head)

	return head, attemptCount, budgetExhausted
end

function AITickModule2Perception.processPerceptionReady(tickModule, startTime)
	local attemptCount = 0
	local budgetExhausted = false
	local budgetUs = tickModule.perceptionReadyAdmissionDeadlineUs or 0
	local maxCount = tickModule.perceptionMaxCountPerFrame or 0

	tickModule.petPerceptionReadyHead, attemptCount, budgetExhausted = AITickModule2Perception._processPerceptionReadyQueue(tickModule, tickModule.petPerceptionReadyQueue, tickModule.petPerceptionReadyHead, startTime, attemptCount, budgetExhausted, budgetUs, maxCount)
	tickModule.perceptionReadyHead, attemptCount, budgetExhausted = AITickModule2Perception._processPerceptionReadyQueue(tickModule, tickModule.perceptionReadyQueue, tickModule.perceptionReadyHead, startTime, attemptCount, budgetExhausted, budgetUs, maxCount)
end

return AITickModule2Perception
