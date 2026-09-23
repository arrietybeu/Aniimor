-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerNpcDuelComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local NpcDuelData = require("Data.npc_duel_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local SysEventData = require("Data.sys_event_data")
local NoticeDef = require("Common.NoticeDef")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local NPC_DUEL_EXIT_COUNTDOWN_ID = "NpcDuelExit"
local NpcDuelCountUtils = require("Common.Utils.NpcDuelCountUtils")
local RealAvatarRobotData = require("Data.real_avatar_robot_data")
local logger = require("Core.Log.LoggerManager").getLogger("ClientPlayerNpcDuelComponent")
local ClientPlayerNpcDuelComponent = Class.Component("ClientPlayerNpcDuelComponent")

function ClientPlayerNpcDuelComponent:ctor()
	self._isStartNpcDuelRequesting = false
end

function ClientPlayerNpcDuelComponent:init(dict)
	return
end

function ClientPlayerNpcDuelComponent:onNpcDuelStateChanged(ov, nv, npcDuelId)
	facade:SendMessageCommand(MessageName.NPC_DUEL_STATE_CHANGED, {
		npcDuelId = npcDuelId,
		oldState = ov,
		newState = nv
	})
end

function ClientPlayerNpcDuelComponent:onNpcDuelStateAdded(npcDuelId, state)
	facade:SendMessageCommand(MessageName.NPC_DUEL_STATE_CHANGED, {
		npcDuelId = npcDuelId,
		newState = state
	})
end

function ClientPlayerNpcDuelComponent:startNpcDuel(successCb)
	if self._isStartNpcDuelRequesting then
		logger:debug("RPC_CS_StartNpcDuel is requesting, ignore duplicate start")

		return
	end

	self._isStartNpcDuelRequesting = true

	if pg.game.npcDuel then
		pg.game.npcDuel:resetNpcDuelEndResult()
	end

	self:serverMsg("RPC_CS_StartNpcDuel", function(ret)
		if ret == NoticeDef.SUCCESS then
			if successCb then
				successCb()
			end

			logger:info("RPC_CS_StartNpcDuel NoticeDef.SUCCESS")

			if pg.game.npcDuel then
				pg.game.npcDuel:npcDuelStartFallback()
			end
		else
			self._isStartNpcDuelRequesting = false

			logger:debug("RPC_CS_StartNpcDuel 开始npc对决失败 错误码%s", ret)

			if ret == NoticeDef.NpcDuel_PetCannotControl then
				pg.global.ui.tips:showTextTip(pg.getGameString("NPCDUEL_PET_CANNOTCONTROL"))
			elseif ret == NoticeDef.NpcDuel_PetFormationEmpty then
				pg.global.ui.tips:showTextTip(pg.getGameString("NPCDUEL_PET_EMPTY"))
			end
		end
	end)
end

function ClientPlayerNpcDuelComponent:resetStartNpcDuelRequesting()
	self._isStartNpcDuelRequesting = false
end

function ClientPlayerNpcDuelComponent:npcDuelRematch()
	if pg.game.npcDuel then
		pg.game.npcDuel:resetNpcDuelEndResult()
	end

	if pg.space and pg.space.stopNpcDuelEndTimelines then
		pg.space:stopNpcDuelEndTimelines()
	end

	pg.global.ui.tips:hideCountDown(NPC_DUEL_EXIT_COUNTDOWN_ID)

	if pg.space.npcDuelPauseBt then
		pg.space:npcDuelPauseBt()
	end

	if pg.game.npcDuel then
		pg.game.npcDuel:onRematchFadeIn(function()
			self:npcDuelRematchStart()
		end)
	end
end

function ClientPlayerNpcDuelComponent:npcDuelRematchStart()
	self:serverMsg("RPC_CS_NpcDuelRematch", function(ret)
		if ret == NoticeDef.SUCCESS then
			pg.game.npcDuel:setInRematch(true)
		else
			if pg.game.npcDuel then
				pg.game.npcDuel:onRematchFadeOut()
			end

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				logger:debug("RPC_CS_NpcDuelRematch npc对决重新开始失败 错误码%s", ret)
			end
		end
	end)
end

function ClientPlayerNpcDuelComponent:npcDuelExit()
	if pg.game.npcDuel then
		pg.game.npcDuel:npcDuelExitMask()
	end

	if pg.space and pg.space.stopNpcDuelEndTimelines then
		pg.space:stopNpcDuelEndTimelines()
	end

	pg.global.ui.tips:hideCountDown(NPC_DUEL_EXIT_COUNTDOWN_ID)
	self:serverMsg("RPC_CS_NpcDuelExit")
end

function ClientPlayerNpcDuelComponent:RPC_SC_PrepareForNpcDuel(info)
	local ret = info.ret

	self:clearNpcDuelPreviewPets()

	self.previewPetInfoList = info.previewPetInfoList

	if ret == NoticeDef.SUCCESS then
		self:npcDuelOpen()
	end

	if ret ~= NoticeDef.SUCCESS and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("RPC_SC_PrepareForNpcDuel 打开npc对决界面失败 错误码%s", ret)
	end
end

function ClientPlayerNpcDuelComponent:cacheNpcDuelPreviewPet(previewPetInfo)
	local petId = previewPetInfo and previewPetInfo.id

	if string.isNilOrEmpty(petId) then
		return nil
	end

	self.npcDuelPreviewPetMap = self.npcDuelPreviewPetMap or {}

	local cached = self.npcDuelPreviewPetMap[petId]

	if cached then
		return cached
	end

	local petInfo = PetManagementDataHelper.convertTableToPetInfo(previewPetInfo)

	self.npcDuelPreviewPetMap[petId] = petInfo

	return petInfo
end

function ClientPlayerNpcDuelComponent:getNpcDuelPreviewBotPetInfo(index)
	return self:cacheNpcDuelPreviewPet(self.previewPetInfoList and self.previewPetInfoList[index])
end

function ClientPlayerNpcDuelComponent:getNpcDuelPreviewPetInfo(petId)
	if string.isNilOrEmpty(petId) then
		return nil
	end

	local cached = self.npcDuelPreviewPetMap and self.npcDuelPreviewPetMap[petId]

	if cached then
		return cached
	end

	for _, previewPetInfo in ipairs(self.previewPetInfoList or EMPTY_TABLE) do
		if previewPetInfo.id == petId then
			return self:cacheNpcDuelPreviewPet(previewPetInfo)
		end
	end

	return nil
end

function ClientPlayerNpcDuelComponent:isNpcDuelPreviewPet(petId)
	return self:getNpcDuelPreviewPetInfo(petId) ~= nil
end

function ClientPlayerNpcDuelComponent:clearNpcDuelPreviewPets()
	self.npcDuelPreviewPetMap = nil
	self.previewPetInfoList = nil
end

function ClientPlayerNpcDuelComponent:npcDuelOpen()
	if pg.game.npcDuel then
		pg.game.npcDuel:npcDuelMaskFadeInStage1()
	end

	pg.global.ui:open(UIConst.UI_ID_NPC_DUEL_START)
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnNpcDuelAllUnitEnterCombat()
	return
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnStartNpcDuelDialogue(info)
	local entId = info.npc_eid
	local ret = info.ret

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_NPC_DUEL_START) then
		return
	end

	if pg.game.npcDuel and pg.game.npcDuel:isBanNpcInteraction() then
		return
	end

	self.curNpcDuelEntId = entId

	if pg.game.npcDuel then
		pg.game.npcDuel:cacheDuelNpc(entId)
	end

	local npcDuelData = NpcDuelData[self.curNpcDuelId] and NpcDuelData[self.curNpcDuelId][self.curNpcDuelVariantId]
	local startDialogue = npcDuelData and npcDuelData.startDialogue
	local unstartDialogue = npcDuelData and npcDuelData.unstartDialogue

	if startDialogue and ret == NoticeDef.SUCCESS then
		ClientUtils.showDialog(startDialogue, self.curNpcDuelEntId)
	elseif unstartDialogue then
		ClientUtils.showDialog(unstartDialogue, self.curNpcDuelEntId)
	end
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnStartNpcDuelClearDialogue(info)
	local entId = info.npc_eid
	local duelid = info.duelid
	local variantid = info.variantid
	local npcDuelData = NpcDuelData[duelid] and NpcDuelData[duelid][variantid]
	local clearDialogue = npcDuelData and npcDuelData.clearDialogue

	if clearDialogue then
		ClientUtils.showDialog(clearDialogue, entId)
	end
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnNpcDuelPlayEndStateDialogue(info)
	local entId = info.npc_eid
	local ent = pg.getEntity(entId)
	local cfgData = ent and ent:getConfigData()
	local npcDuelId = cfgData and cfgData.npcDuelId
	local npcDuelVariantId = npcDuelId and self.npcDuelBasicInfo.variantIdMap[npcDuelId]

	if npcDuelVariantId then
		local npcDuelData = NpcDuelData[npcDuelId] and NpcDuelData[npcDuelId][npcDuelVariantId]
		local endStateDialogue = npcDuelData and npcDuelData.endStateDialogue

		if endStateDialogue then
			ClientUtils.showDialog(endStateDialogue, entId)
		end
	end
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnNpcDuelPetDeath(petId, entId)
	facade:SendMessageCommand(MessageName.NPC_DUEL_PET_DEATH, {
		petId = petId,
		entId = entId
	})
end

function ClientPlayerNpcDuelComponent:RPC_SC_OnNpcDuelAllPetDeath(isSuccess)
	if pg.space:isNpcDuel() then
		pg.space:onNpcDuelAllPetDeath(isSuccess)
	end
end

function ClientPlayerNpcDuelComponent:RPC_SC_NpcDuelEnd(result)
	if pg.game.npcDuel then
		pg.game.npcDuel:setNpcDuelEndResult(result)
	end

	if pg.space:isNpcDuel() then
		pg.space:npcDuelPauseBt()
		pg.space:onNpcDuelEnd(result)
	end

	if result == false then
		self:npcDuelPlayerDie()
	elseif pg.game.npcDuel then
		pg.game.npcDuel:prepareExitDialogue(self.curNpcDuelId, self.curNpcDuelVariantId)
	end
end

function ClientPlayerNpcDuelComponent:RPC_SC_NpcDuelInitFailed()
	logger:error("npc对决服务端报错强制退出")

	if pg.global and pg.global.ui then
		pg.global.ui:close(UIConst.UI_ID_NPC_DUEL_START)
	end

	if pg.game.npcDuel then
		pg.game.npcDuel:clearNpcDuelStartFallbackTimer()
	end

	self:serverMsg("RPC_CS_NpcDuelExit")
end

function ClientPlayerNpcDuelComponent:npcDuelPlayerDie()
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)
	local petEnt = botEntity and botEntity:getCurPetEntity()

	self:_Rpc_RPC_SC_OnPlayerDead(Const.LIFE_DEAD, petEnt and petEnt.actorId or 0, Const.LIFE_DEAD_BY_COMBAT)
end

function ClientPlayerNpcDuelComponent:npcDuelGetPlayerAndBotPetDieState()
	local function collectDieState(entity)
		local dieState = {}

		if not entity then
			return dieState
		end

		local pets = entity:getPets() or {}
		local prepareList = entity.petPrepareList or {}

		for index, petId in ipairs(prepareList) do
			local petInfo = pets[petId]

			dieState[index] = {
				isDie = petInfo and (petInfo.hpRatio or 0) <= 0 or false
			}
		end

		return dieState
	end

	local playerDieState = collectDieState(self)
	local botDieState = collectDieState(pg.getEntity(pg.space.npcDuelBotEntityId))

	return playerDieState, botDieState
end

function ClientPlayerNpcDuelComponent:npcDuelGetCurPetName()
	local botEntity = pg.getEntity(pg.space.npcDuelBotEntityId)
	local petEntity = botEntity and botEntity:getCurPetEntity()

	if not petEntity then
		return ""
	end

	local pData = petEntity:getConfigData()
	local petNickName = pg.getLocalizationText(pData and pData.petNickName)

	if not string.isNilOrEmpty(petNickName) then
		return petNickName
	end

	return pData and pg.getLocalizationText(pData.name) or ""
end

local DUEL_STATUS_NOCHALLENGE = 0
local DUEL_STATUS_CHALLENGING = 1
local DUEL_STATUS_PART_PASS = 2
local DUEL_STATUS_ALL_PASS = 3

function ClientPlayerNpcDuelComponent:checkBanNpcDuelFunc(entityId, eventType)
	if not entityId or not eventType then
		return false
	end

	if eventType == "startNpcDuelDialogue" then
		local entity = pg.getEntity(entityId)
		local npcData = entity and entity:getConfigData()

		if npcData and npcData.npcDuelId then
			local status = self.npcDuelState[npcData.npcDuelId]

			if not status then
				local npcDuelData = NpcDuelData[npcData.npcDuelId] and NpcDuelData[npcData.npcDuelId][1]

				status = npcDuelData and npcDuelData.initState
			end

			if status == DUEL_STATUS_NOCHALLENGE or status == DUEL_STATUS_ALL_PASS then
				return true
			end
		end

		if self:checkEntityHaveSpecialInteraction(entity.staticId, "startNpcDuelClearDialogue") then
			return true
		end

		return false
	elseif eventType == "npcDuelPlayEndStateDialogue" then
		local entity = pg.getEntity(entityId)
		local npcData = entity and entity:getConfigData()

		if npcData and npcData.npcDuelId then
			local status = self.npcDuelState[npcData.npcDuelId]

			if status == DUEL_STATUS_ALL_PASS then
				return false
			end
		end

		return true
	end

	return false
end

function ClientPlayerNpcDuelComponent:checkEntityHaveSpecialInteraction(staticId, eventType)
	if not staticId or not eventType then
		return false
	end

	local eventIds = pg.me.npcSpecialInteractsMap[staticId]

	for _, eventId in ipairs(eventIds or EMPTY_TABLE) do
		local curEventData = SysEventData[eventId]
		local eventName = curEventData and curEventData.eventParam[3]

		if eventName == eventType then
			return true
		end
	end

	return false
end

function ClientPlayerNpcDuelComponent:checkBanNpcDuelFuncByIds(entityId, eventIds)
	if not entityId or not eventIds then
		return false
	end

	for _, eventId in ipairs(eventIds) do
		local eventType = SysEventData[eventId] and SysEventData[eventId].eventType

		if self:checkBanNpcDuelFunc(entityId, eventType) then
			return true
		end
	end

	return false
end

function ClientPlayerNpcDuelComponent:getNpcDuelClearCount(npcDuelId, variantId, tag)
	return NpcDuelCountUtils:getNpcDuelClearCount(self, npcDuelId, variantId, tag)
end

function ClientPlayerNpcDuelComponent:getCurNpcDuelBotName()
	if not self.npcDuelBotInfo then
		return ""
	end

	local npcBotId = self.npcDuelBotInfo.npcBotId

	if not npcBotId then
		return ""
	end

	local npcBotData = RealAvatarRobotData[npcBotId]

	return pg.getLocalizationText(npcBotData and npcBotData.name or "")
end

function ClientPlayerNpcDuelComponent:getCurBuffInfo()
	local buffInfo = {}
	local npcDuelData = NpcDuelData[self.curNpcDuelId] and NpcDuelData[self.curNpcDuelId][self.curNpcDuelVariantId]

	if npcDuelData then
		buffInfo.buffName = npcDuelData.buffName and pg.getLocalizationText(npcDuelData.buffName)
		buffInfo.buffDesc = npcDuelData.buffDesc and pg.getLocalizationText(npcDuelData.buffDesc)
		buffInfo.buffIcon = npcDuelData.buffIcon
	end

	return buffInfo
end

function ClientPlayerNpcDuelComponent:getNpcDuelWinCondDesc()
	local ALL_CONDIN = 1
	local PART_CONDIN = 2
	local npcDuelData = NpcDuelData[self.curNpcDuelId] and NpcDuelData[self.curNpcDuelId][self.curNpcDuelVariantId]
	local condin = npcDuelData and npcDuelData.winCondition
	local conditionType = tonumber(condin and condin[1]) or ALL_CONDIN

	if conditionType == ALL_CONDIN then
		return pg.getGameString("NPCDUEL_BATTLE_DEFEAT_ALL")
	elseif conditionType == PART_CONDIN and condin[2] then
		return pg.getFormatText(pg.getGameString("NPCDUEL_BATTLE_DEFEAT_PART"), condin[2])
	else
		return ""
	end
end

return ClientPlayerNpcDuelComponent
