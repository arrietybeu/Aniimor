-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomeEventMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local IDManager = require("Core.Common.IDManager")
local Const = require("Common.Const.Const")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local HomeEventTypeToIdData = require("Data.home_event_type_to_id_data")
local HomeEventMap = class.LiteClass("HomeEventMap", CustomDict)

function HomeEventMap:getLoginEventInsIds(startTs)
	local res = {}

	for _, eventInsId in ipairs(self.eventInsIdsByTimeAsc) do
		local eventInfo = self[eventInsId]

		if startTs < eventInfo.createTs then
			table.insert(res, eventInsId)
		end
	end

	return res
end

function HomeEventMap:updateByList(homelandSpace, eventList)
	local remainCount = HomelandConfigData.eventMaxCount - #self

	if remainCount <= #eventList then
		local needRemoveCount = #eventList - remainCount

		self:tryRemoveEventByCount(homelandSpace, needRemoveCount)
	end

	local addCount = math.min(HomelandConfigData.eventMaxCount - #self, #eventList)

	for i = 1, addCount do
		local textId = eventList[i].textId
		local targetIds = eventList[i].targetIds

		self:createEvent(homelandSpace, textId, targetIds)
	end

	return addCount
end

function HomeEventMap:tryRemoveEventByCount(homelandSpace, count)
	local successCount = 0

	for _, eventInsId in ipairs(self.eventInsIdsByTimeAsc) do
		local eventInfo = self[eventInsId]

		if eventInfo.solvedTs > 0 then
			self:removeEvent(homelandSpace, eventInsId)

			successCount = successCount + 1
		end

		if count <= successCount then
			break
		end
	end

	return successCount
end

function HomeEventMap:_modifyExternalOnRemove(homelandSpace, eventInfo)
	local typeData = eventInfo:getEventTypeData()

	if typeData and eventInfo.solvedTs == 0 then
		local targetType = typeData.targetType
		local targetId = eventInfo.targetIds[1]

		if targetType == Const.HomeEventTarget.Pet then
			local petInfo = homelandSpace:getHomelandPet(targetId)

			if petInfo then
				homelandSpace:prepareHomeEventPetResolvedPosition(targetId)
			end

			homelandSpace:setPetHomeEventInsId(targetId, "")

			if petInfo then
				homelandSpace:onHomeEventPetStatusChange(targetId, typeData.petStatus)
			end
		elseif targetType == Const.HomeEventTarget.Friend and typeData.giftStaticId then
			homelandSpace.giftEventInsId = ""

			homelandSpace:onHomeEventGiftChange()
		end
	end
end

function HomeEventMap:removeEvent(homelandSpace, eventInsId)
	local eventInfo = self[eventInsId]

	if not eventInfo then
		return false
	end

	self:_modifyExternalOnRemove(homelandSpace, eventInfo)

	self[eventInsId] = nil

	local index = lume.findInList(self.eventInsIdsByTimeAsc, eventInsId)

	if index then
		self.eventInsIdsByTimeAsc:remove(index)
	end

	homelandSpace.logger:info("homeEvent removeEvent, eventInsId=%s", eventInsId, homelandSpace:repr())

	return true
end

function HomeEventMap:solveEvent(homelandSpace, eventInsId)
	local eventInfo = self[eventInsId]

	if not eventInfo then
		return false
	end

	self:_modifyExternalOnRemove(homelandSpace, eventInfo)

	eventInfo.solvedTs = Time.secondCache

	homelandSpace.logger:info("homeEvent solveEvent, eventInsId=%s", eventInsId, homelandSpace:repr())

	return true
end

function HomeEventMap:createEvent(homelandSpace, textId, targetIds)
	local eventInsId = IDManager.genB64ID()

	self[eventInsId] = {
		solvedTs = 0,
		textId = textId,
		targetIds = targetIds,
		createTs = Time.secondCache
	}

	self.eventInsIdsByTimeAsc:insert(#self.eventInsIdsByTimeAsc + 1, eventInsId)

	local eventInfo = self[eventInsId]
	local typeData = eventInfo:getEventTypeData()

	if typeData then
		local targetType = typeData.targetType
		local targetId = eventInfo.targetIds[1]

		if targetType == Const.HomeEventTarget.Pet then
			homelandSpace:setPetHomeEventInsId(targetId, eventInsId)

			local petInfo = homelandSpace:getHomelandPet(targetId)

			if petInfo then
				homelandSpace:onHomeEventPetStatusChange(targetId, nil)
			end
		elseif targetType == Const.HomeEventTarget.Friend and typeData.giftStaticId then
			homelandSpace.giftEventInsId = eventInsId
			homelandSpace.giftOpened = false

			homelandSpace:onHomeEventGiftChange()
		end
	end

	homelandSpace.logger:info("homeEvent createEvent, eventInsId=%s", eventInsId, homelandSpace:repr())

	return eventInsId
end

function HomeEventMap:removeAll(homelandSpace)
	local toRemoveInsIds = self.eventInsIdsByTimeAsc:getRawTable()

	for _, eventInsId in ipairs(toRemoveInsIds) do
		self:removeEvent(homelandSpace, eventInsId)
	end
end

function HomeEventMap:dump()
	local solvedEvents, unsolvedEvents = {}, {}

	for _, eventInsId in ipairs(self.eventInsIdsByTimeAsc) do
		local eventInfo = self[eventInsId]

		if eventInfo.solvedTs > 0 then
			table.insert(solvedEvents, eventInfo:dump())
		else
			table.insert(unsolvedEvents, eventInfo:dump())
		end
	end

	return {
		solvedEvents = lume.tonumstrkey(solvedEvents),
		unsolvedEvents = lume.tonumstrkey(unsolvedEvents)
	}
end

return HomeEventMap
