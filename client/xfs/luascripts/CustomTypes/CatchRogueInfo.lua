-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CatchRogueInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local ItemUtils = require("Common.Utils.ItemUtils")
local DungeonConst = require("Common.Const.DungeonConst")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local CatchRogueLevelData = require("Data.catch_rogue_level_data")
local CatchRogueLevelReverseData = require("Data.catch_rogue_level_reverse_data")
local CatchRogueInfo = Class.LiteClass("CatchRogueInfo", CustomDict)

function CatchRogueInfo:onActivityReset()
	self.statCntEnterGame = 0
	self.statCntFinishGame = 0
end

function CatchRogueInfo:onGameReset(newGameId)
	self.gameId = newGameId
	self.gameSettled = false
	self.savedPetMap = {}
	self.purchaseTimeCnt = 0
	self.purchaseReviveCnt = 0
	self.catchedPetIds = {}

	self:onFloorReset(0)
end

function CatchRogueInfo:onFloorReset(newFloorId)
	self.floorId = newFloorId
	self.floorSuccess = false
	self.savedPuppetMap = {}
	self.statCntBallUsed = {}
	self.puppetRandomAddOn = 0

	self:randomLevelInfo()
end

function CatchRogueInfo:randomLevelInfo()
	local validLevelIds = {}
	local levelIds = CatchRogueLevelReverseData[self.gameId] and CatchRogueLevelReverseData[self.gameId][self.floorId]
	local isTopFloor = self:isTopFloor()
	local lastLevelConfig = CatchRogueLevelData[self.levelId] or {}

	for _, levelId in ipairs(levelIds or EMPTY_TABLE) do
		local levelConfig = CatchRogueLevelData[levelId]

		if levelConfig and (isTopFloor or levelConfig.type ~= lastLevelConfig.type) then
			table.insert(validLevelIds, levelId)
		end
	end

	if next(validLevelIds) then
		self.levelId = validLevelIds[math.random(1, #validLevelIds)]
	else
		self.levelId = 0
	end

	self.levelTime = CatchRogueLevelData[self.levelId] and CatchRogueLevelData[self.levelId].levelTime or 0
	self.levelSettled = false
end

function CatchRogueInfo:getLevelCostTime(remainTime)
	remainTime = remainTime or self.levelTime

	local crpdd = CatchRoguePhaseData[self.gameId]
	local crldd = CatchRogueLevelData[self.levelId]

	if not crldd or not crpdd then
		return 0
	end

	local cfgTime = crldd.levelTime or 0
	local addTime = self.purchaseTimeCnt * (crpdd.addTime or 0)

	return cfgTime + addTime - remainTime
end

function CatchRogueInfo:isTopFloor(floorId)
	floorId = floorId or self.floorId

	return not CatchRogueLevelReverseData[self.gameId] or not CatchRogueLevelReverseData[self.gameId][self.floorId + 1]
end

function CatchRogueInfo:getCurLevelConfig()
	return CatchRogueLevelData[self.levelId], self.levelId
end

function CatchRogueInfo:getCurSettleFloorCount()
	return self.floorSuccess and self.floorId or math.max(0, self.floorId - 1)
end

function CatchRogueInfo:getForcePetLevel()
	local crpdd = CatchRoguePhaseData[self.gameId]

	return crpdd and crpdd.forcePetLevel or 30
end

function CatchRogueInfo:getValidPetList(player, petList)
	local petList = petList or self.petList
	local validPetList = {}
	local petSet = {}

	for _, petId in ipairs(petList) do
		if not petSet[petId] and player.pets[petId] then
			validPetList[#validPetList + 1] = petId
			petSet[petId] = true

			if #validPetList >= Const.PET_PREPARE_NUM_LIMIT then
				break
			end
		end
	end

	return validPetList
end

function CatchRogueInfo:getValidBallList(player, ballList)
	local ballList = ballList or self.ballList
	local crpdd = CatchRoguePhaseData[self.gameId]
	local validBallList = {}

	for _, ballId in ipairs(ballList) do
		local valid = false

		for _, typeInfo in ipairs(crpdd.ballType or EMPTY_TABLE) do
			if ballId == typeInfo[1] then
				valid = true

				break
			end
		end

		if lume.find(crpdd and crpdd.gameBallType or {}, ballId) then
			valid = true
		end

		if valid then
			validBallList[#validBallList + 1] = ballId
		end
	end

	for _, ballId in ipairs(crpdd and crpdd.gameBallType or EMPTY_TABLE) do
		if not lume.find(validBallList, ballId) and ItemUtils.getItemCountById(player, ballId) > 0 then
			validBallList[#validBallList + 1] = ballId
		end
	end

	return validBallList
end

function CatchRogueInfo:autoUpdateBallListOnItemAdd(player, itemId)
	if not lume.find(self.ballList, itemId) then
		self.ballList:insert(#self.ballList + 1, itemId)
		player.logger:debug("catchRogue auto add ballId to ballList:", itemId, player:repr())
	end
end

function CatchRogueInfo:autoUpdateBallListOnItemDel(player, itemId)
	if lume.find(self.ballList, itemId) and self:getValidBallCount(player, itemId) <= 0 then
		self.ballList:remove(lume.find(self.ballList, itemId))
		player.logger:debug("catchRogue auto remove ballId from ballList:", itemId, player:repr())
	end
end

function CatchRogueInfo:isGameBall(ballId)
	local crpdd = CatchRoguePhaseData[self.gameId]

	if crpdd and crpdd.gameBallType then
		return lume.find(crpdd.gameBallType, ballId) ~= nil
	end

	return false
end

function CatchRogueInfo:getValidBallCount(player, ballId)
	local validCount = ItemUtils.getItemCountById(player, ballId)
	local crpdd = CatchRoguePhaseData[self.gameId]

	if not lume.find(crpdd and crpdd.gameBallType or {}, ballId) then
		validCount = math.min(validCount, self.ballCountMap[ballId] or 0)
	end

	return validCount
end

function CatchRogueInfo:getValidBallCountMap(player)
	local validBallCountMap = {}
	local validBallList = self:getValidBallList(player)

	for _, ballId in ipairs(validBallList) do
		validBallCountMap[ballId] = self:getValidBallCount(player, ballId)
	end

	return validBallCountMap
end

function CatchRogueInfo:getValidBallCountPairs(player)
	local validBallCountPairs = {}
	local validBallList = self:getValidBallList(player)

	for _, ballId in ipairs(validBallList) do
		table.insert(validBallCountPairs, {
			ballId,
			self:getValidBallCount(player, ballId)
		})
	end

	return validBallCountPairs
end

function CatchRogueInfo:canFireBall(player, ballId, isAfterUse)
	if not player.space or player.space.status ~= DungeonConst.STATUS.PLAYING or player.space.isPausing then
		return false
	end

	return self:getValidBallCount(player, ballId) >= (isAfterUse and 0 or 1)
end

function CatchRogueInfo:onFireBall(player, ballId)
	if self.ballCountMap[ballId] then
		self.ballCountMap[ballId] = (self.ballCountMap[ballId] or 0) - 1
	end

	self.statCntBallUsed[ballId] = (self.statCntBallUsed[ballId] or 0) + 1

	self:autoUpdateBallListOnItemDel(player, ballId)
end

function CatchRogueInfo:onRecycleBall(player, ballId)
	if self.ballCountMap[ballId] then
		self.ballCountMap[ballId] = (self.ballCountMap[ballId] or 0) + 1
	end

	self.statCntBallUsed[ballId] = (self.statCntBallUsed[ballId] or 0) - 1

	self:autoUpdateBallListOnItemAdd(player, ballId)
end

function CatchRogueInfo:onCatchPet(player, petInfo)
	self.catchedPetIds:insert(#self.catchedPetIds + 1, petInfo.id)
end

function CatchRogueInfo:checkEnterGameCnt()
	local crpdd = CatchRoguePhaseData[self.gameId]
	local maxCount = crpdd and crpdd.trainCount or 0

	return maxCount > self.statCntEnterGame
end

function CatchRogueInfo:getGameCntRepr()
	local crpdd = CatchRoguePhaseData[self.gameId]
	local maxCount = crpdd and crpdd.trainCount or 0

	return string.format("%d/%d", self.statCntEnterGame, maxCount)
end

function CatchRogueInfo:getCurPuppetFinishCount()
	local finishCount, totalCount = 0, 0

	for _, puppetInfo in pairs(self.savedPuppetMap) do
		totalCount = totalCount + 1

		if puppetInfo.hpRatio <= 0 then
			finishCount = finishCount + 1
		end
	end

	return finishCount, totalCount
end

function CatchRogueInfo:getCurCanGetAddOnSet()
	local addOnSet = {}

	for _, puppetInfo in pairs(self.savedPuppetMap) do
		if puppetInfo.hpRatio > 0 and puppetInfo.addOnId ~= 0 then
			addOnSet[puppetInfo.addOnId] = true
		end
	end

	return lume.keys(addOnSet)
end

function CatchRogueInfo:canPrepareGame(player)
	if self.floorId == 0 then
		return true
	end

	if self.gameSettled and self:checkEnterGameCnt() then
		return true
	end

	return false
end

return CatchRogueInfo
