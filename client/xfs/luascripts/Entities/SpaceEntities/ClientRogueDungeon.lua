-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRogueDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local DungeonConst = require("Common.Const.DungeonConst")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientRogueDungeon = Class.Class("ClientRogueDungeon", ClientPveDungeon)

function ClientRogueDungeon:ctor(entityId)
	ClientRogueDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientRogueDungeon create")
	end

	self.clientCacheInfos = {}
	self.clientCacheInfoIsPause = true
	self.rogueGroundReady = false
	self.waitGroundReadySet = {}
end

function ClientRogueDungeon:registerWaitGroundReady(entity)
	self.waitGroundReadySet[entity] = true
end

function ClientRogueDungeon:unregisterWaitGroundReady(entity)
	self.waitGroundReadySet[entity] = nil
end

function ClientRogueDungeon:resetGroundReady()
	self.rogueGroundReady = false
end

function ClientRogueDungeon:onRogueGroundReady()
	self.rogueGroundReady = true

	if not next(self.waitGroundReadySet) then
		return
	end

	local waiting = self.waitGroundReadySet

	self.waitGroundReadySet = {}

	for entity in pairs(waiting) do
		if entity and not entity.isDestroyed and entity.onRogueGroundReady then
			entity:onRogueGroundReady()
		end
	end
end

function ClientRogueDungeon:init(dict)
	ClientRogueDungeon.super.init(self, dict)
	self:initData()

	return true
end

function ClientRogueDungeon:start()
	ClientRogueDungeon.super.start(self)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_MAIN) then
		pg.global.ui:close(UIConst.UI_ID_TOWER_MAIN)
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientRogueDungeon (%s) start", self:repr(), self.status)
	end
end

function ClientRogueDungeon:RPC_SC_ChallengeResult(result, failReason)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ChallengeResult", result)
	end

	facade:sendMsgToUI(MessageName.ROGUE_RESULT_CHANGE, {
		result = result,
		failReason = failReason
	})
end

function ClientRogueDungeon:RPC_SC_ShowSelectBuff(buffIdList, selectNum, reRandomCount, buffSource)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ShowSelectBuff", inspect(buffIdList), selectNum, reRandomCount, buffSource)
	end

	if buffSource == Const.ROGUE_BUFF_SOURCE.EXTRA_BUFF then
		local cacheInfo = {
			uid = UIConst.UI_ID_ROG_ULTIMATE_UPGRADE,
			buffs = buffIdList
		}

		self:addCacheInfo(cacheInfo)
	else
		local cacheInfo = {
			isExtraBuff = false,
			uid = UIConst.UI_ID_ROG_BUFF_SELECT,
			buffSource = buffSource,
			buffs = buffIdList,
			cNum = selectNum,
			reRandomCount = reRandomCount
		}

		if self.isResetBuff then
			self.isResetBuff = false
			self.clientCacheInfos[1] = cacheInfo

			self:executeCacheInfo()
		else
			self:addCacheInfo(cacheInfo)
		end
	end
end

function ClientRogueDungeon:RPC_SC_ShowRandomBuff(buffId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ShowRandomBuff", buffId)
	end

	self:onGetBuff({
		buffId
	})
end

function ClientRogueDungeon:selectBuff(buffIdList)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("selectBuff", inspect(buffIdList))
	end

	pg.me:serverSpaceMsg("RPC_CS_SelectBuff", {
		buffIdList
	})
	self:nextCacheInfo()
end

function ClientRogueDungeon:reRandomBuff()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("reRandomBuff")
	end

	self.isResetBuff = true

	pg.me:serverSpaceMsg("RPC_CS_ReRandomBuff", {})
end

function ClientRogueDungeon:onGetBuff(buffIds)
	local curCounts = {}

	for _, buffId in ipairs(buffIds) do
		curCounts[buffId] = pg.me:getRogueBuffCount(nil, buffId)
	end

	local cacheInfo = {
		isShow = true,
		uid = UIConst.UI_ID_ROG_BUFF_SELECT,
		buffs = buffIds,
		curCounts = curCounts
	}

	self:addCacheInfo(cacheInfo)
end

function ClientRogueDungeon:startBattle(petIds)
	pg.me:serverSpaceMsg("RPC_CS_StartBattle", {
		petIds
	})
end

function ClientRogueDungeon:modifyBattleFormation(petIds)
	pg.me:serverSpaceMsg("RPC_CS_ModifyBattleFormation", {
		petIds
	})
end

function ClientRogueDungeon:onResult(result)
	return
end

function ClientRogueDungeon:addCacheInfo(cacheInfo)
	table.insert(self.clientCacheInfos, cacheInfo)

	if #self.clientCacheInfos == 1 then
		self:executeCacheInfo()
	end
end

function ClientRogueDungeon:nextCacheInfo()
	table.remove(self.clientCacheInfos, 1)

	if #self.clientCacheInfos > 0 then
		self:executeCacheInfo()
	end
end

function ClientRogueDungeon:executeCacheInfo()
	if self.clientCacheInfoIsPause then
		return
	end

	local cacheInfo = self.clientCacheInfos[1]

	if cacheInfo then
		if cacheInfo.msg then
			facade:sendMsgToUI(cacheInfo.msg, cacheInfo)
		elseif cacheInfo.uid then
			pg.global.ui:open(cacheInfo.uid, cacheInfo, nil, nil, cacheInfo.uiSceneParmas)
		end
	end
end

function ClientRogueDungeon:pauseCacheInfo()
	self.clientCacheInfoIsPause = true
end

function ClientRogueDungeon:resumeCacheInfo()
	self.clientCacheInfoIsPause = nil

	self:executeCacheInfo()
end

function ClientRogueDungeon:initData()
	self:initPetInfo()
end

function ClientRogueDungeon:initPetInfo()
	self.petMaxLevel = 0
	self.petInfos = {}

	for id, _ in pairs(pg.me.selectRoguePets) do
		local pet = pg.me.pets[id]

		if pet then
			local petInfo = LuaUIUtils.generatePetInfo(pet)

			petInfo.indexInRogue = #self.petInfos + 1
			self.petInfos[#self.petInfos + 1] = petInfo
			self.petMaxLevel = math.max(self.petMaxLevel, petInfo.level)
		end
	end

	table.sort(self.petInfos, function(petInfo1, petInfo2)
		return pg.me.selectRoguePets[petInfo1.id] < pg.me.selectRoguePets[petInfo2.id]
	end)
end

return ClientRogueDungeon
