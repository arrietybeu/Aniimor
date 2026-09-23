-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerCatchRogueComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local OpDef = require("Common.OpDef")
local CatchRogueLevelData = require("Data.catch_rogue_level_data")
local EventCatchRogueData = require("Data.event_catch_rogue_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Const = require("Common.Const.Const")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local NoticeDef = require("Common.NoticeDef")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIConst = require("Const.UIConst")
local CatchRogueBuffData = require("Data.catch_rogue_buff_data")
local MessageName = require("Const.MessageName")
local ItemData = require("Data.item_data")
local ClientPlayerCatchRogueComponent = Class.Component("ClientPlayerCatchRogueComponent")

function ClientPlayerCatchRogueComponent:ctor()
	self.catchRogueBuySwitch = true
	self.catchRogueBuffSwitch = true
end

function ClientPlayerCatchRogueComponent:getCatchRogueBuyEnable()
	local curGameId = self:getCatchRogueCurGameId()

	if not curGameId then
		return
	end

	local buyEnable = CatchRoguePhaseData[curGameId] and CatchRoguePhaseData[curGameId].shopForbidden ~= 1 or false

	return buyEnable
end

function ClientPlayerCatchRogueComponent:sendCatchRogueOption(op, params, callback)
	local localCallback = callback or function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end

		self.logger:debug("catchRogue sendCatchRogueOption callback, op=%s, res=%s", OpDef.repr(op, params), NoticeDef.getRepr(noticeId, noticeArgs))
	end

	self:serverMsg("RPC_CS_CatchRogueOp", op, params or {}, localCallback)
end

function ClientPlayerCatchRogueComponent:RPC_SC_CatchRogueNotify(op, params)
	if op == OpDef.OP.SC_CR_SettleRequest then
		local reason = params.reason

		self.logger:debug("CatchRogue SettleRequest, reason=%s", reason)

		if reason == Const.CatchRogue.SETTLE_TIMEOUT then
			pg.global.ui.tips:showTextTip(pg.getGameString("FAILED"))
			pg.global.ui:open(UIConst.UI_ID_TOWER_DEFEAT, {
				fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
				gameId = self:getCatchRogueCurGameId(),
				failReason = reason
			})
		elseif reason == Const.CatchRogue.SETTLE_PLAYER_DIED then
			pg.global.ui.tips:showTextTip(pg.getGameString("FAILED"))
			pg.global.ui:open(UIConst.UI_ID_TOWER_DEFEAT, {
				fromType = UIConst.ROGUE_FROM_TYPE.CATCH_ROGUE,
				gameId = self:getCatchRogueCurGameId(),
				failReason = reason
			})
		else
			self:sendCatchRogueOption(OpDef.OP.CS_CR_GameSettle, {
				isQuit = true
			})
		end
	elseif op == OpDef.OP.SC_CR_AddOnNotify then
		local addonId = params.addonId
		local needToast = CatchRogueBuffData[addonId].ifBuffToast

		if needToast then
			pg.global.ui.tips:showA2Tips({
				duration = 3,
				id = "DungeonTips",
				uniqueId = "CatchRogue",
				buffId = addonId
			})
		end
	elseif op == OpDef.OP.SC_CR_SettleFinish then
		local itemList = {}

		for itemId, count in pairs(params.itemCountMap or EMPTY_TABLE) do
			table.insert(itemList, {
				itemId = itemId,
				itemCount = count
			})
		end

		table.sort(itemList, function(a, b)
			local aCfg, bCfg = ItemData[a.itemId], ItemData[b.itemId]

			if aCfg.quality ~= bCfg.quality then
				return aCfg.quality > bCfg.quality
			end

			return a.itemId < b.itemId
		end)

		if pg.logDebug() then
			self.logger:debug("catchRogue SettleFinish, itemList=%s", inspect(itemList))
		end

		pg.global.ui:open(UIConst.UI_ID_CATCH_ROGUE_RESULT, {
			itemList = itemList
		})
	end

	self.logger:debug("catchRogue RPC_SC_CatchRogueNotify", OpDef.repr(op, params))
end

function ClientPlayerCatchRogueComponent:playCatchRougeSceneScan(playEffect)
	if not pg.me.space:isRogueEnv() then
		return
	end

	local ins = CS.FunPlus.WorldX.RenderingScripts.Effect.SceneSwitchManager.Ins

	if ins then
		local sceneLevelId = (CatchRogueLevelData[self.space.dungeonId] or EMPTY_TABLE).sceneLevelId or 0

		ins:ChangeSceneLevelId(sceneLevelId, self:getPosition(), playEffect)

		if playEffect then
			pg.game.audio:playEvent("SFX_UI_Rouge_LoadScene")
		end
	end
end

function ClientPlayerCatchRogueComponent:modifyCatchRoguePets(petIds)
	if not self:canPrepareGame() then
		self.logger:error("catchRogue modifyCatchRoguePets fail! can not prepare game!")

		return
	end

	self:sendCatchRogueOption(OpDef.OP.CS_CR_UpdatePets, {
		petIds = petIds
	})
end

function ClientPlayerCatchRogueComponent:modifyCatchRogueBallSort(ballIds)
	if not self:canPrepareGame() then
		self.logger:error("catchRogue modifyCatchRogueBallSort fail! can not prepare game!")

		return
	end

	self:sendCatchRogueOption(OpDef.OP.CS_CR_UpdateBalls, {
		ballIds = ballIds
	})
end

function ClientPlayerCatchRogueComponent:modifyCatchRogueBallCount(ballCountMap)
	if not self:canPrepareGame() then
		self.logger:error("catchRogue modifyCatchRogueBallCount fail! can not prepare game!")

		return
	end

	self:sendCatchRogueOption(OpDef.OP.CS_CR_UpdateBallCount, {
		ballCountMap = ballCountMap
	})
end

function ClientPlayerCatchRogueComponent:enterCatchRogueGame(cb)
	self:sendCatchRogueOption(OpDef.OP.CS_CR_GameEnter, nil, cb)
end

function ClientPlayerCatchRogueComponent:nextCatchRogueGame()
	if not Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		return
	end

	self:sendCatchRogueOption(OpDef.OP.CS_CR_GameNext)
end

function ClientPlayerCatchRogueComponent:saveCatchRogueGame()
	if not Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		return
	end

	self:sendCatchRogueOption(OpDef.OP.CS_CR_GameSave)
end

function ClientPlayerCatchRogueComponent:settleCatchRogueGame(isQuit, purchaseType, cb)
	self:sendCatchRogueOption(OpDef.OP.CS_CR_GameSettle, {
		isQuit = isQuit,
		purchaseType = purchaseType
	}, cb)
end

function ClientPlayerCatchRogueComponent:getCatchRogueCurGameId()
	if self.catchRogueInfo and self.catchRogueInfo.gameId then
		return self.catchRogueInfo.gameId
	end

	local result, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.CatchRogue)
	local gameId = EventCatchRogueData[activityId].gameId

	if result and gameId then
		return gameId
	else
		self.logger:debug("catchRogue getCurGameId is nil!")

		return
	end
end

function ClientPlayerCatchRogueComponent:getCurCatchRoguePetList()
	local pets = {}

	for index, petId in ipairs(pg.me.catchRogueInfo.catchedPetIds or EMPTY_TABLE) do
		local petInfo = self:getPetInfo(petId, true)

		if petInfo then
			table.insert(pets, petInfo)
		end
	end

	return pets
end

function ClientPlayerCatchRogueComponent:isPlayCatchRogue()
	if not pg.me or not pg.me.catchRogueInfo then
		return false
	end

	local catchRogueInfo = pg.me.catchRogueInfo

	return catchRogueInfo.floorId ~= 0 and catchRogueInfo.gameSettled ~= true
end

function ClientPlayerCatchRogueComponent:getCatchRoguePuppetInfo(staticId)
	if not pg.me or not pg.me.catchRogueInfo then
		return
	end

	local catchRogueInfo = pg.me.catchRogueInfo
	local catchRoguePuppetInfo = catchRogueInfo.savedPuppetMap and catchRogueInfo.savedPuppetMap[staticId]

	return catchRoguePuppetInfo
end

function ClientPlayerCatchRogueComponent:getCurPuppetFinishCount()
	if not pg.me or not pg.me.catchRogueInfo then
		return 0, 0
	end

	return pg.me.catchRogueInfo:getCurPuppetFinishCount()
end

function ClientPlayerCatchRogueComponent:getCurCanGetAddOnSet()
	if not pg.me or not pg.me.catchRogueInfo then
		return
	end

	return pg.me.catchRogueInfo:getCurCanGetAddOnSet()
end

function ClientPlayerCatchRogueComponent:getCatchRoguePreparePetList()
	local res = {}
	local lastPetList = pg.me.catchRogueInfo and pg.me.catchRogueInfo:getValidPetList(pg.me) or {}

	if #lastPetList > 0 then
		for _, petId in ipairs(lastPetList) do
			local petInfo = pg.me.pets[petId]

			if petInfo and petInfo.level <= pg.me.level then
				table.insert(res, petId)
			end
		end
	else
		local petPrepareInfoList = pg.me.petPrepareList

		for idx, petId in pairs(petPrepareInfoList) do
			local petInfo = pg.me.pets[petId]

			if petInfo and petInfo.level <= pg.me.level then
				table.insert(res, petId)
			end
		end
	end

	return res
end

function ClientPlayerCatchRogueComponent:canPrepareGame()
	if not pg.me.catchRogueInfo then
		return
	end

	return pg.me.catchRogueInfo:canPrepareGame(pg.me)
end

function ClientPlayerCatchRogueComponent:on_floorId_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_floorId_changed ov:%s, nv:%s", inspect(ov), inspect(nv))
	end

	facade:sendMsgToUI(MessageName.CATCH_ROGUE_LEVEL_CHANGE, {})
end

function ClientPlayerCatchRogueComponent:on_catchRogue_ballList_changed(ov, nv)
	if pg.logDebug() then
		self.logger:debug("catchRogue refresh ballList, %s", inspect(self.catchRogueInfo:getValidBallCountPairs(pg.me)))
	end

	facade:sendMsgToUI(MessageName.ITEM_COUNT_MAP_CHANGE, {})
end

function ClientPlayerCatchRogueComponent:on_catchRogue_ballCountMap_changed(ov, nv)
	if pg.logDebug() then
		self.logger:debug("catchRogue refresh ballCountMap, %s", inspect(self.catchRogueInfo:getValidBallCountPairs(pg.me)))
	end

	facade:sendMsgToUI(MessageName.ITEM_COUNT_MAP_CHANGE, {})
end

function ClientPlayerCatchRogueComponent:on_catchRogue_savedPuppetMap_changed(ov, nv)
	local finishCnt, totalCnt = self.catchRogueInfo:getCurPuppetFinishCount()
	local canGetAddOnSet = self.catchRogueInfo:getCurCanGetAddOnSet()

	facade:sendMsgToUI(MessageName.TARGET_PET_BUFF_ON_CHANGE, {})

	if pg.logDebug() then
		self.logger:debug("catchRogue refresh tasklist, %s-%s, %s", finishCnt, totalCnt, inspect(canGetAddOnSet))
	end
end

return ClientPlayerCatchRogueComponent
