-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\RogueTalentUtils.lua

local RogueTalentData = require("Data.rogue_talent_data")
local RogueMultiLevelTalentData = require("Data.rogue_multi_level_talent_data")
local Utils = require("Common.Utils.Utils")
local TalentEventData = require("Data.talent_event_data")
local RogueTalentUtils = {}

function RogueTalentUtils.getTalentMaxLevel(talentTreeNum)
	local configData = RogueTalentData[talentTreeNum]

	if not configData then
		return 0
	end

	return math.max(configData.maxLv or 1, 1)
end

function RogueTalentUtils.getTalentLevelData(talentTreeNum, talentLv)
	if talentLv == nil or talentLv <= 1 then
		return RogueTalentData[talentTreeNum]
	end

	return RogueMultiLevelTalentData[talentTreeNum * 1000 + talentLv]
end

function RogueTalentUtils.getTalentLevel(playerEnt, talentTreeNum)
	if not Utils.isPlayer(playerEnt) then
		return 0
	end

	local unlockMap = playerEnt.rogueTalentLevelUnlock or {}

	if not unlockMap[talentTreeNum] then
		return 0
	end

	local levelMap = playerEnt.rogueTalentNodeLvMap or {}
	local talentLv = levelMap[talentTreeNum] or 1
	local maxLv = RogueTalentUtils.getTalentMaxLevel(talentTreeNum)

	if maxLv > 0 and maxLv < talentLv then
		talentLv = maxLv
	end

	return talentLv
end

function RogueTalentUtils.getTalentProperty(playerEnt, talentTreeNum)
	local curLv = RogueTalentUtils.getTalentLevel(playerEnt, talentTreeNum)

	if curLv <= 0 then
		return {}
	end

	local configData = RogueTalentUtils.getTalentLevelData(talentTreeNum, curLv)
	local propertyList = configData and configData.property or nil

	if type(propertyList) ~= "table" then
		return {}
	end

	local result = {}

	for _, attrInfo in ipairs(propertyList) do
		local attrName = attrInfo[1]
		local value = attrInfo[2]

		if type(attrName) == "string" and type(value) == "number" then
			table.insert(result, {
				attrName,
				value
			})
		end
	end

	return result
end

function RogueTalentUtils.getTalentEventInfo(playerEnt, talentTreeNum)
	local curLv = RogueTalentUtils.getTalentLevel(playerEnt, talentTreeNum)
	local event, params

	if curLv <= 0 then
		return event, params or {}
	end

	for talentLv = 1, curLv do
		local configData = RogueTalentUtils.getTalentLevelData(talentTreeNum, talentLv)

		if configData and (configData.event ~= nil or configData.eventParam ~= nil) then
			event = configData.event
			params = configData.eventParam
		end
	end

	return event, params or {}
end

function RogueTalentUtils.getTalentEventParam(playerEnt, talentTreeNum)
	local _, params = RogueTalentUtils.getTalentEventInfo(playerEnt, talentTreeNum)

	return params
end

function RogueTalentUtils.hasUnlockedEvent(rogueTalentLevelUnlock, data)
	for _, level in pairs(data) do
		if rogueTalentLevelUnlock[level] then
			return true
		end
	end

	return false
end

function RogueTalentUtils.getEventData(playerEnt, data)
	if not Utils.isPlayer(playerEnt) then
		return {}
	end

	local params
	local unlockMap = playerEnt.rogueTalentLevelUnlock or {}

	for _, level in ipairs(data) do
		if unlockMap[level] then
			params = RogueTalentUtils.getTalentEventParam(playerEnt, level)
		end
	end

	return params or {}
end

function RogueTalentUtils._islockExtraTeamPos(playerEnt, extrArgs)
	return true
end

function RogueTalentUtils._isUnlockSweep(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return false
	end

	local unlockSweepNodes = TalentEventData.unlockSweep or {}
	local unlockNodes = playerEnt.rogueTalentLevelUnlock

	return RogueTalentUtils.hasUnlockedEvent(unlockNodes, unlockSweepNodes)
end

function RogueTalentUtils._getRogueInitCoin(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return 0
	end

	local rogueCoin = TalentEventData.initRogueCoin or {}
	local params = RogueTalentUtils.getEventData(playerEnt, rogueCoin)

	if #params ~= 1 or type(params[1]) ~= "number" then
		return 0
	end

	return params[1] or 0
end

function RogueTalentUtils._getUnlockBuffSeries(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return {}
	end

	local rogueExtraBuffSeries = {}
	local unlockBuffSeries = TalentEventData.unlockBuffSeries or {}

	for _, level in pairs(unlockBuffSeries) do
		if playerEnt.rogueTalentLevelUnlock[level] then
			local params = RogueTalentUtils.getTalentEventParam(playerEnt, level)

			if #params ~= 1 or type(params[1]) ~= "number" then
				return rogueExtraBuffSeries
			end

			table.insert(rogueExtraBuffSeries, params[1])
		end
	end

	return rogueExtraBuffSeries
end

function RogueTalentUtils._getRogueInitRandomCnt(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return 0
	end

	local initBuff = TalentEventData.initBuff or {}
	local params = RogueTalentUtils.getEventData(playerEnt, initBuff)

	if #params ~= 1 or type(params[1]) ~= "number" then
		return 0
	end

	return params[1]
end

function RogueTalentUtils._getExtraBuff(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return {}
	end

	local rogueExtraBuffOdds = {}
	local gainExtraBuff = TalentEventData.gainExtraBuff or {}

	for _, level in pairs(gainExtraBuff) do
		if playerEnt.rogueTalentLevelUnlock[level] then
			local params = RogueTalentUtils.getTalentEventParam(playerEnt, level)

			if #params ~= 2 or type(params[1]) ~= "number" or type(params[2]) ~= "number" then
				return rogueExtraBuffOdds
			end

			local odd, source = unpack(params)

			rogueExtraBuffOdds[source] = odd
		end
	end

	return rogueExtraBuffOdds
end

function RogueTalentUtils._getResetBuff(playerEnt, index)
	if not Utils.isPlayer(playerEnt) then
		return 0
	end

	local unlockResetBuff = TalentEventData.unlockResetBuff or {}
	local params = RogueTalentUtils.getEventData(playerEnt, unlockResetBuff)

	if #params ~= 3 or type(params[1]) ~= "number" or type(params[2]) ~= "number" or type(params[3]) ~= "number" then
		return 0
	end

	return params[index]
end

function RogueTalentUtils._getRogueRandomCount(playerEnt, extrArgs)
	return RogueTalentUtils._getResetBuff(playerEnt, 1)
end

function RogueTalentUtils._getReRandomInitCost(playerEnt, extrArgs)
	return RogueTalentUtils._getResetBuff(playerEnt, 2)
end

function RogueTalentUtils._geteReRandomCost(playerEnt, extrArgs)
	return RogueTalentUtils._getResetBuff(playerEnt, 3)
end

function RogueTalentUtils._switchRogueShopItemWeight(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return {}
	end

	local rogueShopWightId = {}
	local switchRogueShopItemWeight = TalentEventData.switchRogueShopItemWeight or {}

	for _, level in pairs(switchRogueShopItemWeight) do
		if playerEnt.rogueTalentLevelUnlock[level] then
			local params = RogueTalentUtils.getTalentEventParam(playerEnt, level)

			if #params ~= 2 or type(params[1]) ~= "number" or type(params[2]) ~= "number" then
				return rogueShopWightId
			end

			local shopId, index = unpack(params)

			rogueShopWightId[shopId] = index
		end
	end

	return rogueShopWightId
end

function RogueTalentUtils._switchDropId(playerEnt, extrArgs)
	local switchDropId = TalentEventData.switchDropId or {}
	local params = RogueTalentUtils.getEventData(playerEnt, switchDropId)

	if #params ~= 1 or type(params[1]) ~= "number" then
		return 0
	end

	return params[1]
end

function RogueTalentUtils._getAddBuffList(playerEnt, extrArgs)
	if not Utils.isPlayer(playerEnt) then
		return {}
	end

	local buffInfo = {}
	local addBuff = TalentEventData.addBuff or {}

	for _, level in pairs(addBuff) do
		if playerEnt.rogueTalentLevelUnlock[level] then
			local params = RogueTalentUtils.getTalentEventParam(playerEnt, level)

			if type(params) ~= "table" then
				return buffInfo
			end

			for _, buffId in pairs(params) do
				buffInfo[buffId] = (buffInfo[buffId] or 0) + 1
			end
		end
	end

	return buffInfo
end

function RogueTalentUtils._getApplyItemSetTypes(playerEnt, extrArgs)
	local itemSetTypes = {
		[0] = true
	}

	if not Utils.isPlayer(playerEnt) then
		return itemSetTypes
	end

	local applyItemSet = TalentEventData.applyItemSet or {}
	local maxLevel

	for _, level in pairs(applyItemSet) do
		if playerEnt.rogueTalentLevelUnlock[level] and (maxLevel == nil or maxLevel < level) then
			maxLevel = level
		end
	end

	if maxLevel == nil then
		return itemSetTypes
	end

	local params = RogueTalentUtils.getTalentEventParam(playerEnt, maxLevel)

	if type(params) ~= "table" then
		return itemSetTypes
	end

	for _, itemSetType in pairs(params) do
		itemSetTypes[itemSetType] = true
	end

	return itemSetTypes
end

function RogueTalentUtils.func(playerEnt, name, extrArgs)
	if RogueTalentUtils.UPDATEFUNC[name] then
		return RogueTalentUtils.UPDATEFUNC[name](playerEnt, extrArgs)
	end

	return nil
end

RogueTalentUtils.UPDATEFUNC = {
	rogueExtraSlot = RogueTalentUtils._islockExtraTeamPos,
	rogueInitCoin = RogueTalentUtils._getRogueInitCoin,
	rogueExtraBuffSeries = RogueTalentUtils._getUnlockBuffSeries,
	rogueInitRandomCnt = RogueTalentUtils._getRogueInitRandomCnt,
	rogueExtraBuffOdds = RogueTalentUtils._getExtraBuff,
	rogueRandomCount = RogueTalentUtils._getRogueRandomCount,
	reRandomInitCost = RogueTalentUtils._getReRandomInitCost,
	reRandomCost = RogueTalentUtils._geteReRandomCost,
	rogueShopWightId = RogueTalentUtils._switchRogueShopItemWeight,
	rogueStaminaDropId = RogueTalentUtils._switchDropId,
	rogueAddBuff = RogueTalentUtils._getAddBuffList,
	rogueApplyItemSetTypes = RogueTalentUtils._getApplyItemSetTypes,
	rogueUnlockSweep = RogueTalentUtils._isUnlockSweep
}

return RogueTalentUtils
