-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientGrabEggComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientGrabEggComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local DungeonConst = require("Common.Const.DungeonConst")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local ClientConst = require("Const.ClientConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local EggRandomModelIdData = require("Data.egg_random_model_id_data")
local EggIdToModelResData = require("Data.egg_id_to_model_res_data")
local EggPatternColorData = require("Data.egg_pattern_color_data")
local SysConfigData = require("Data.sys_config_data")
local lume = require("Core.Common.lume")
local RobEggItemOut = require("Data.rob_egg_item_out")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local PlayableConst = require("Common.Const.PlayableConst")
local DiGongConfData = require("Data.digong_config_data")
local ClientUtils = require("Utils.ClientUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local RobEggLootItemList = require("CustomTypes.RobEggLootItemList")
local RobEggLootItemMap = require("CustomTypes.RobEggLootItemMap")
local EventConst = require("Const.EventConst")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local ClientGrabEggComponent = class.Component("ClientGrabEggComponent")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")

local function notifyGrabEggRedDotChanged()
	facade:SendMessageCommand(MessageName.GRAB_EGG_RED_DOT_CHANGED)
end

local function notifyNoviceProtectionChanged()
	facade:SendMessageCommand(MessageName.GRAB_EGG_NOVICE_PROTECTION_CHANGED)
end

function ClientGrabEggComponent:ctor()
	return
end

function ClientGrabEggComponent:start()
	notifyNoviceProtectionChanged()
end

function ClientGrabEggComponent:on_eggLv_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_secEggLv_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_eggStar_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_eggScore_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_eggAllScore_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_rankRewardFlag_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_rewardBoxList_id_changed(oldVal, newVal, index)
	facade:SendMessageCommand(MessageName.GRAB_EGG_REWARD_BOX_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_rewardBoxList_timestamp_changed(oldVal, newVal, index)
	facade:SendMessageCommand(MessageName.GRAB_EGG_REWARD_BOX_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_refreshCountDaily_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_REWARD_BOX_CHANGED)
	notifyGrabEggRedDotChanged()
end

function ClientGrabEggComponent:on_eggUnlockTalent_entry_added(talentId, unlocked)
	if unlocked ~= true and unlocked ~= 1 then
		return
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_TALENT_UNLOCKED, talentId)
end

function ClientGrabEggComponent:on_robEggEvtProps_changed()
	notifyNoviceProtectionChanged()
end

function ClientGrabEggComponent:on_robEggEvtProps_value_changed()
	notifyNoviceProtectionChanged()
end

function ClientGrabEggComponent:on_robEggEvtProps_entry_added()
	notifyNoviceProtectionChanged()
end

function ClientGrabEggComponent:on_safeBoxNum_changed(oldVal, newVal)
	facade:SendMessageCommand(MessageName.GRAB_EGG_SAFE_BOX_NUM_CHANGED, newVal)
end

function ClientGrabEggComponent:getTalentIsUnlockByTalentId(talentId)
	if self.eggUnlockTalent == nil then
		return false
	end

	local v = self.eggUnlockTalent[talentId]

	return v == true or v == 1
end

function ClientGrabEggComponent:on_grabEggBagSlot_changed(oldVal, newVal, index)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_robBagSlot_changed old:%s, new:%s, slot:%s", oldVal, newVal, index)
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_MY_BAG_SLOT, {
		index = index
	})
end

function ClientGrabEggComponent:on_grabEggBagEquipSlot_changed(oldVal, newVal, index)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_grabEggBagEquipSlot_changed old:%s, new:%s, slot:%s", oldVal, newVal, index)
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_MY_BAG_EQUIP_SLOT, {
		index = index
	})
end

function ClientGrabEggComponent:on_curLoad_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_curLoad_changed old:%s, new:%s", oldVal, newVal)
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_CUR_LOAD)

	local inGrabEggSpace = self.space and self.space:isGrabEgg()
	local bagOpen = pg.global.ui:checkUIOpen(UIConst.UI_ID_GRAB_EGGS_BAG)

	if inGrabEggSpace or bagOpen then
		local grabEggBag = pg.global.ui.grabEggBag
		local oldState = grabEggBag:getLoadState(oldVal)
		local newState = grabEggBag:getLoadState(newVal)

		if oldState < newState and newState >= 1 then
			local bubbleId = grabEggBag.model:getOverloadBubbleId(newState)

			if bubbleId then
				ClientUtils.showBubbleMessage(bubbleId)
			end
		end
	end
end

function ClientGrabEggComponent:on_curLoadBearing_changed(oldVal, newVal)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_curLoadBearing_changed old:%s, new:%s", oldVal, newVal)
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_CUR_LOAD)
end

function ClientGrabEggComponent:on_eggGameSuccessTimes_changed(oldVal, newVal)
	if oldVal == 0 and newVal == 1 then
		facade:SendMessageCommand(MessageName.GRAB_EGG_GAME_SUCCESS_TIMES_CHANGED)
	end
end

function ClientGrabEggComponent:grabEgg_isTalentEntryUnlocked()
	return (self.eggGameSuccessTimes or 0) > 0
end

function ClientGrabEggComponent:on_harvest_changed()
	facade:SendMessageCommand(MessageName.GRAB_EGG_HARVEST)
end

function ClientGrabEggComponent:grabEgg_isFirstTimePlay()
	return false
end

function ClientGrabEggComponent:grabEgg_getNoviceProtectionInfo(sceneId, hardLv)
	local sceneConfig = DungeonDifficultLevelData[sceneId]
	local hardConfig = sceneConfig and sceneConfig[hardLv]
	local noviceRounds = hardConfig and hardConfig.novProtRound

	if hardConfig == nil or hardConfig.hasNovProt ~= 1 or noviceRounds == nil or noviceRounds == 0 then
		return nil
	end

	local gameTimesName = "GameTimes_" .. tostring(hardLv)
	local gameTimesPropId = Const.RobEggEventProp and Const.RobEggEventProp[gameTimesName]

	if gameTimesPropId == nil or self.robEggEvtProps == nil then
		return nil
	end

	local totalTimes = 0

	for roundIndex in pairs(noviceRounds) do
		if type(roundIndex) == "number" and totalTimes < roundIndex then
			totalTimes = roundIndex
		end
	end

	if totalTimes <= 0 then
		return nil
	end

	local gameTimes = self.robEggEvtProps[gameTimesPropId] or 0
	local usedTimes = math.min(math.max(gameTimes, 0), totalTimes)
	local remainingTimes = totalTimes - usedTimes
	local isCurrentRoundProtected = gameTimes > 0 and noviceRounds[gameTimes] ~= nil
	local isNextRoundProtected = noviceRounds[gameTimes + 1] ~= nil

	return {
		gameTimes = gameTimes,
		usedTimes = usedTimes,
		remainingTimes = remainingTimes,
		totalTimes = totalTimes,
		currentRound = gameTimes,
		nextRound = gameTimes + 1,
		isCurrentRoundProtected = isCurrentRoundProtected,
		isNextRoundProtected = isNextRoundProtected,
		revealCurrentRoundMapFog = isCurrentRoundProtected and hardConfig.novRevealMapFog == 1,
		revealNextRoundMapFog = isNextRoundProtected and hardConfig.novRevealMapFog == 1
	}
end

function ClientGrabEggComponent:grabEgg_isCurrentRoundNoviceProtected(sceneId, hardLv)
	local info = self:grabEgg_getNoviceProtectionInfo(sceneId, hardLv)

	return info ~= nil and info.isCurrentRoundProtected
end

function ClientGrabEggComponent:grabEgg_isNextRoundNoviceProtected(sceneId, hardLv)
	local info = self:grabEgg_getNoviceProtectionInfo(sceneId, hardLv)

	return info ~= nil and info.isNextRoundProtected
end

function ClientGrabEggComponent:grabEgg_shouldRevealMapFog(sceneId, hardLv)
	local info = self:grabEgg_getNoviceProtectionInfo(sceneId, hardLv)

	return info ~= nil and info.revealCurrentRoundMapFog
end

function ClientGrabEggComponent:getItemFromBagSlotIndex(index, inv, useDefaultData)
	local slotData

	if inv == ItemConst.INV_TYPE_ROB_EGG then
		slotData = self.slotsInfo[index]
	elseif inv == ItemConst.INV_TYPE_EQUIP_SLOTS then
		slotData = self.equipSlotsInfo[index]
	end

	local bag = ItemUtils.getTypedBag(self, inv)
	local data = bag[slotData and slotData.genId]

	if data == nil and useDefaultData then
		data = {
			count = 0,
			id = ItemConst.ROB_EGG_DEFAULT_ITEM[index] or 0
		}
	end

	return data
end

function ClientGrabEggComponent:hasEquipBag()
	local slotInfo = self.equipSlotsInfo[ItemConst.ROB_EGG_EQUIP_SLOT.BAG]
	local item = ItemUtils.getItem(self, ItemConst.INV_TYPE_EQUIP_SLOTS, slotInfo.genId)

	return ToBool(item)
end

function ClientGrabEggComponent:getGrabEggBagEmptyCount()
	if not self:hasEquipBag() then
		return nil
	end

	local packSlot = self:getItemFromBagSlotIndex(ItemConst.ROB_EGG_EQUIP_SLOT.BAG, ItemConst.INV_TYPE_EQUIP_SLOTS)
	local itemId = packSlot and packSlot.id
	local effectData = ItemEffectData[itemId]
	local capacity = effectData and effectData.volume or 0
	local beginPos = ItemConst.ROB_EGG_BAG_SLOT.NORMAL_POS_BEGIN
	local emptyCount = 0

	for i = beginPos, beginPos + capacity - 1 do
		local slot = self:getItemFromBagSlotIndex(i, ItemConst.INV_TYPE_ROB_EGG)

		if not slot then
			emptyCount = emptyCount + 1
		end
	end

	return emptyCount
end

function ClientGrabEggComponent:isGrabEggBagFull()
	local emptyCount = self:getGrabEggBagEmptyCount()

	return emptyCount ~= nil and emptyCount <= 0
end

function ClientGrabEggComponent:grabEgg_checkItemEnoughInBag(itemId, count)
	local bag = ItemUtils.getTypedBag(self, ItemConst.INV_TYPE_ROB_EGG) or {}

	if bag.count <= 0 then
		return false
	end

	for genId, item in bag:items() do
		if item.id == itemId and count <= item.count then
			return true
		end
	end

	return false
end

function ClientGrabEggComponent:isInGrabEggDungeon()
	local teamInfo = self:getCurTeamInfo()
	local dungeonId = teamInfo.dungeonSceneId

	if dungeonId == Const.ROB_EGG_SCENE_ID or dungeonId == Const.ROB_EGG_SCENE_CLIP_ID then
		return true
	end

	return false
end

function ClientGrabEggComponent:isInGrabEggTeamRoom()
	return self:isInGrabEggDungeon() and self.space and not self.space:isGrabEgg()
end

local function getGrabEggPlayerCount(space)
	local count = 0
	local teams = space and space.teamInfo and space.teamInfo.teams

	if teams == nil then
		return count
	end

	for _, team in pairs(teams) do
		for _ in ipairs(team.members or EMPTY_TABLE) do
			count = count + 1
		end
	end

	return count
end

function ClientGrabEggComponent:refreshGrabEggWaitingInfo()
	if not pg.global or not pg.global.ui or not pg.global.ui.tips then
		return
	end

	if not self.space or not self.space:isGrabEgg() then
		pg.global.ui.tips:hideGrabEggWaitingInfo()

		return
	end

	if (self.space.status or 0) >= DungeonConst.STATUS.COUNT_DONW then
		pg.global.ui.tips:hideGrabEggWaitingInfo()

		return
	end

	local playerCount = getGrabEggPlayerCount(self.space)

	if playerCount <= 1 then
		pg.global.ui.tips:hideGrabEggWaitingInfo()

		return
	end

	pg.global.ui.tips:showGrabEggWaitingInfo()
end

function ClientGrabEggComponent:onLeaveSpace()
	pg.global.ui:close(UIConst.UI_ID_TEAM_ROOM)
	pg.global.ui:close(UIConst.UI_ID_GRAB_EGGS_RESULT)
	pg.global.ui:close(UIConst.UI_ID_GRAB_EGGS_SETTLEMENT)
	pg.global.ui:close(UIConst.UI_ID_FUNC_MENU)
	self:clearLimitTimeChallengeUI()

	self.limitTimePillarSyncParams = nil

	pg.global.ui.tips:hideCountDown("hatch_egg")
	pg.global.ui.tips:hideCountDown("became_egg")
	pg.global.ui.tips:hideGrabEggWaitingInfo()

	if self.space and self.space.transportInfo then
		for staticId, _ in pairs(self.space.transportInfo) do
			self:grabEgg_hideTransportCountDown(staticId)
		end
	end

	pg.global.ui.tips:hideControlPanel()
	self:setInvasionInputEnable(true)

	if self.space:isGrabEgg() and pg.me:isAlive() then
		self:setSightOfViewRange(0, true)
	end
end

function ClientGrabEggComponent:EVENT_EnterScene()
	if self.space:isGrabEgg() then
		self:tryRestoreGrabEggState()
	end
end

function ClientGrabEggComponent:tryRestoreGrabEggState()
	self:tryRestartHatchEggCountDown()
	self:tryRestartTransportCountDown()
	self:refreshGrabEggWaitingInfo()
end

function ClientGrabEggComponent:grabEgg_tryEnterPrepRoom(dungeonSceneId, difficultLv)
	dungeonSceneId = dungeonSceneId or Const.ROB_EGG_SCENE_CLIP_ID

	pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)

	if self:isInTeam() then
		if self:isTeamLeader() then
			self:applyTeamDungeon(dungeonSceneId, difficultLv, true)
		end
	else
		self:createSingleTeam(dungeonSceneId, difficultLv)
	end
end

function ClientGrabEggComponent:grabEgg_enterPrepRoom()
	if not pg.global.ui:checkUIOpen(UIConst.UI_ID_TEAM_ROOM) then
		pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM, nil, function()
			pg.game.grabEgg:tryInvokeSettlement()
		end)
	else
		pg.game.grabEgg:tryInvokeSettlement()
	end
end

function ClientGrabEggComponent:RPC_SC_ResourceBox(id, items)
	local box = pg.getEntity(id)

	if box.opened then
		local lootItemList = items

		if not items.bagSlots then
			lootItemList = RobEggLootItemList(items)
		else
			lootItemList = {
				bagSlots = RobEggLootItemMap(items.bagSlots),
				equipSlots = RobEggLootItemMap(items.equipSlots)
			}
		end

		box:opened(lootItemList)
	end
end

function ClientGrabEggComponent:RPC_SC_RobEggSceneReady(teamInfo)
	self:refreshGrabEggWaitingInfo()
	facade:sendMsgToUI(MessageName.GRAB_EGG_DUNGEON_TEAM_READY, teamInfo)
end

function ClientGrabEggComponent:RPC_SC_DiscoveryStarted(id, pos, playerNum, endTime)
	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERY_START, {
		id = id,
		pos = pos,
		playerNum = playerNum,
		endTime = endTime
	})
end

function ClientGrabEggComponent:RPC_SC_Discoverying(id, pos, playerNum)
	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERING, {
		id = id,
		pos = pos,
		playerNum = playerNum
	})
end

function ClientGrabEggComponent:RPC_SC_DiscoveryFinished(id, pos)
	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERY_FINISHED, {
		id = id,
		pos = pos
	})
end

function ClientGrabEggComponent:RPC_SC_DiscoveryInterupted(id, pos)
	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERY_INTERRUPTED, {
		id = id,
		pos = pos
	})
end

function ClientGrabEggComponent:RPC_SC_ResourceBoxInfo(id, items)
	local lootItemList = items

	if not items.bagSlots then
		lootItemList = RobEggLootItemList(items)
	else
		lootItemList = {
			bagSlots = RobEggLootItemMap(items.bagSlots),
			equipSlots = RobEggLootItemMap(items.equipSlots)
		}
	end

	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERY_INFO, {
		id = id,
		items = lootItemList
	})
end

function ClientGrabEggComponent:RPC_SC_SearchPlayerInfo(id, items)
	facade:SendMessageCommand(MessageName.GRAB_EGG_DISCOVERY_INFO, {
		id = id,
		items = items
	})
end

function ClientGrabEggComponent:grabEgg_isTeammate(uid)
	local teamInfo = self:getCurTeamInfo()
	local members = teamInfo and teamInfo.membersInfo

	if members == nil then
		return false
	end

	return members[uid] ~= nil
end

function ClientGrabEggComponent:RPC_SC_ExtractStatus(enter, endTime)
	if enter then
		local maxEndTime = Time.secondCache + SysConfigData.evacuationCountdown

		pg.global.ui.tips:showCountDownBeat(math.min(endTime, maxEndTime))
	else
		pg.global.ui.tips:hideCountDownBeat()
	end
end

function ClientGrabEggComponent:RPC_SC_GameOver(result, resInfo)
	self:clearLimitTimeChallengeUI()
	self:tryRemoveAreaEffect()
	self:setSightOfViewRange(0)

	local difficulty = resInfo and resInfo.levelInfo and tonumber(resInfo.levelInfo.hardLv)

	pg.game.grabEgg:clearGrabEggDungeonData()
	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SETTLEMENT, {
		result = result,
		resInfo = resInfo
	})
	pg.game.grabEgg:markSettlement(resInfo.levelInfo, result, difficulty)

	local areaId = self.space.becameEggAreaId

	if ToBool(areaId) then
		self.space:removeArea(areaId)
		facade:SendMessageCommand(MessageName.GRAB_EGG_REMOVE_MAP_APPEAR_AREA, {
			id = areaId
		})
	end

	pg.global.ui.tips:hideCountDown("became_egg")
end

function ClientGrabEggComponent:RPC_SC_QuitRobEgg(levelInfo)
	self:clearLimitTimeChallengeUI()

	local difficulty = levelInfo and tonumber(levelInfo.hardLv)

	if self:isInGrabEggDungeon() then
		pg.game.grabEgg:markSettlement(levelInfo, nil, difficulty)
	else
		pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SETTLEMENT_RANK, {
			rankInfo = levelInfo,
			difficulty = difficulty
		})
	end
end

function ClientGrabEggComponent:RPC_SC_RobEggResetPosition()
	for i = #self.backtrackQueue, 1, -1 do
		local data = self.backtrackQueue[i]
		local succ, heightGround = PhysicsUtils.getGroundHeight(data.pos)

		if succ and math.abs(heightGround) < 0.02 then
			pg.me:serverMsg("RPC_CS_RobEggResetPosition", data.pos, data.rotYawEuler)

			break
		end
	end
end

function ClientGrabEggComponent:RPC_SC_RobEggDungeonFinished()
	pg.game.grabEgg:clearGrabEggDungeonData()
end

function ClientGrabEggComponent:finishedSettlement()
	pg.me:serverMsg("RPC_CS_QuitSpace")
end

function ClientGrabEggComponent:grabEgg_getEggs()
	local eggs = {}
	local entityId = self.carryEggEntId

	if entityId then
		local ent = pg.getEntity(entityId)
		local itemId = ent and ent:getRewardItemId()
		local carryEgg = {
			genID = 0,
			count = 1,
			id = itemId,
			itemId = itemId
		}

		eggs[#eggs + 1] = carryEgg
	end

	local equipEgg = pg.global.ui.grabEggBag.model:getEggData()

	if equipEgg then
		equipEgg.id = equipEgg.itemId
		eggs[#eggs + 1] = equipEgg
	end

	for _, v in ipairs(eggs) do
		function v:getExtraProp()
			return {
				characterId = 0,
				talentIds = {}
			}
		end

		function v:isStatusLocked()
			return false
		end
	end

	return eggs
end

function ClientGrabEggComponent:grabEgg_checkHasCarryEgg()
	if self.carryEggEntId then
		return true
	end

	if self:isControllingEgg() then
		return true
	end

	if self.carryId then
		return true
	end

	local egg = self.slotsInfo[ItemConst.ROB_EGG_BAG_SLOT.EGG_POS_BEGIN]

	if egg and egg.genId ~= 0 then
		return true
	end

	return false
end

function ClientGrabEggComponent:grabEgg_getHatchEggInfo(spawnerId)
	local hatchInfo = self.space.hatchInfo[spawnerId]

	if not hatchInfo then
		return {
			{
				status = Const.PET_BALL.HATCH_STATUS_INIT
			}
		}
	end

	local status = hatchInfo.status
	local mappingStatus = 0

	if status == Const.ROB_EGG_HATCH_STATUS.IDLE then
		mappingStatus = Const.PET_BALL.HATCH_STATUS_INIT
	elseif status == Const.ROB_EGG_HATCH_STATUS.HATCHING then
		mappingStatus = Const.PET_BALL.HATCH_STATUS_START
	elseif status == Const.ROB_EGG_HATCH_STATUS.HATCHED then
		mappingStatus = Const.PET_BALL.HATCH_STATUS_SUCC
	end

	local egg = {
		status = mappingStatus,
		endTs = hatchInfo.hatchFinishTime,
		itemId = hatchInfo.eggItemId,
		item = {
			count = 1,
			genID = 0,
			getExtraProp = function(self)
				return {
					characterId = 0,
					talentIds = {}
				}
			end,
			isStatusLocked = function(self)
				return false
			end,
			id = hatchInfo.eggItemId
		}
	}

	return {
		egg
	}
end

function ClientGrabEggComponent:grabEgg_canHatchEgg(spawnerId)
	local hatchInfo = self.space.hatchInfo[spawnerId]

	if not hatchInfo then
		return false
	end

	return hatchInfo.status == Const.ROB_EGG_HATCH_STATUS.IDLE
end

function ClientGrabEggComponent:grabEgg_canTakeHatchEgg(spawnerId)
	local hatchInfo = self.space.hatchInfo[spawnerId]

	if not hatchInfo then
		return false
	end

	if not self:grabEgg_isSelfTeamHatchPoint(spawnerId) then
		return false
	end

	return hatchInfo.status == Const.ROB_EGG_HATCH_STATUS.HATCHED
end

function ClientGrabEggComponent:grabEgg_canRobHatchEgg(spawnerId)
	local hatchInfo = self.space.hatchInfo[spawnerId]

	if not hatchInfo then
		return false
	end

	if self:grabEgg_isSelfTeamHatchPoint(spawnerId) then
		return false
	end

	return hatchInfo.status ~= Const.ROB_EGG_HATCH_STATUS.IDLE
end

function ClientGrabEggComponent:grabEgg_isSelfHatchPoint(spawnerId)
	local hatchInfo = self.space.hatchInfo[spawnerId]

	return hatchInfo and hatchInfo.ownerUid == self.uid
end

function ClientGrabEggComponent:grabEgg_isSelfTeamHatchPoint(spawnerId)
	local teamInfo = self:getCurTeamInfo()

	if teamInfo == nil or teamInfo.sortList == nil then
		return false
	end

	local hatchInfo = self.space.hatchInfo[spawnerId]

	if hatchInfo == nil then
		return false
	end

	return table.contains(teamInfo.sortList, hatchInfo.ownerUid)
end

function ClientGrabEggComponent:grabEgg_startHatchEgg(spawnerId, targetId, eggGenId)
	self.__interactEntId = targetId

	self:serverMsg("RPC_CS_HatchRobEgg", spawnerId, eggGenId)
end

function ClientGrabEggComponent:grabEgg_refreshInteract()
	if self.__interactEntId == nil then
		return
	end

	local ent = pg.getEntity(self.__interactEntId)

	if ent then
		ent:refreshInteractTrigger()
	end
end

function ClientGrabEggComponent:RPC_SC_StartHatchEgg(spawnerId)
	pg.global.ui.tips:showHatchEggTip(0, pg.getGameString("GRAB_EGG_HATCH_BEGIN"))

	local hatchInfo = self.space.hatchInfo[spawnerId]

	if hatchInfo == nil then
		return
	end

	if hatchInfo.ownerUid == self.uid then
		local endTime = hatchInfo.hatchFinishTime or Time.secondCache

		pg.global.ui.tips:showCountDown(endTime - Time.secondCache, "hatch_egg", {
			infoText = pg.getGameString("GRAB_EGG_HATCH_GUARDIAN")
		})
		self:grabEgg_refreshInteract()
	end
end

function ClientGrabEggComponent:tryRestartHatchEggCountDown()
	local hatchInfos = self.space.hatchInfo

	for _, hatchInfo in pairs(hatchInfos) do
		if hatchInfo.ownerUid == self.uid then
			local endTime = hatchInfo.hatchFinishTime or Time.secondCache

			if endTime > 0 then
				pg.global.ui.tips:showCountDown(endTime - Time.secondCache, "hatch_egg", {
					infoText = pg.getGameString("GRAB_EGG_HATCH_GUARDIAN")
				})

				break
			end
		end
	end
end

function ClientGrabEggComponent:RPC_SC_HatchEggAttacked(spawnerId)
	pg.global.ui.tips:showHatchEggTip(2, pg.getGameString("GRAB_EGG_HATCH_BE_ATTACKED"))
end

function ClientGrabEggComponent:RPC_SC_RobberyDone(spawnerId)
	pg.global.ui.tips:hideCountDown("hatch_egg")

	local hatchInfo = self.space.hatchInfo[spawnerId]

	if hatchInfo == nil then
		return
	end

	if hatchInfo.ownerUid == self.uid then
		local endTime = hatchInfo.hatchFinishTime or Time.secondCache

		pg.global.ui.tips:showCountDown(endTime - Time.secondCache, "hatch_egg", {
			infoText = pg.getGameString("GRAB_EGG_HATCH_GUARDIAN")
		})
	end
end

function ClientGrabEggComponent:RPC_SC_HatchEggFinished(spawnerId)
	pg.global.ui.tips:showHatchEggTip(1, pg.getGameString("GRAB_EGG_HATCH_FINISHED"))
	self:grabEgg_refreshInteract()
end

function ClientGrabEggComponent:grabEgg_TakeRobEgg(spawnerId)
	self:serverMsg("RPC_CS_TakeRobEgg", spawnerId)
end

function ClientGrabEggComponent:grabEgg_robEgg(spawnerId)
	self:serverMsg("RPC_CS_RobberyRobEgg", spawnerId)
end

function ClientGrabEggComponent:RPC_SC_InteruptReadingBar(type)
	pg.global.ui.tips:hideControlPanel()
	self:setInvasionInputEnable(true)

	if type == Const.ProgressBarType.ROB_TRANSPORT then
		self.robEggAnimToken = nil

		if not self:isControllingPet() then
			local state = self:playTrivialAnimation(PlayableConst.Show_Pose01_End)

			if state then
				state:AddAutoTransition(0)
			end
		end
	end
end

function ClientGrabEggComponent:RPC_SC_StartReadingBar(type, endTime)
	endTime = endTime or Time.secondCache + 3

	local title

	if type == Const.ProgressBarType.ROB_HATCH_POINT then
		title = pg.getGameString("GRAB_EGG_HATCH_INVADE")
	elseif type == Const.ProgressBarType.TAKE_HATCHED_EGG then
		title = pg.getGameString("GRAB_EGG_HATCH_OPENING")
	end

	local remainTime = math.max(0, endTime - Time.secondCache)

	pg.global.ui.tips:showControlPanel(Time.realSecondCache + remainTime, title)
end

function ClientGrabEggComponent:RPC_SC_RobEggTaked(uid, petInfo, type)
	if uid == self.uid then
		pg.game.soulEggEvolution:startSoulEggEvolution({
			isGrabEgg = true,
			templateId = 1200008,
			closeAction = function()
				return
			end
		}, petInfo)
		self:grabEgg_refreshInteract()
	end

	pg.global.ui.tips:showHatchEggTip(0, pg.getGameString("GRAB_EGG_HATCH_TAKEN_AWAY"), pg.getGameString("GRAB_EGG_HATCH_ASSISTANCE_REWARD_TIP"))
end

function ClientGrabEggComponent:grabEgg_IsSelfEggShip(ownUid)
	return ownUid == self.uid
end

function ClientGrabEggComponent:grabEgg_checkCanTransferEgg(targetId, isEggShip)
	if isEggShip then
		return targetId == self.uid
	end

	local transferPoint = self.space and self.space.transportInfo and self.space.transportInfo[targetId]

	if not transferPoint then
		return false
	end

	if not string.isNilOrEmpty(transferPoint.ownerUid) then
		return false
	end

	return true
end

function ClientGrabEggComponent:grabEgg_checkCanSnatchEgg(staticId)
	local transferPoint = self.space and self.space.transportInfo and self.space.transportInfo[staticId]

	if not transferPoint then
		return false
	end

	if string.isNilOrEmpty(transferPoint.ownerUid) then
		return false
	end

	if transferPoint.state == Const.ROB_EGG_TRANSPORT_STATE.INVADING then
		return false
	end

	if transferPoint.ownerUid == self.uid then
		return false
	end

	if self:grabEgg_isSelfTeamTransport(staticId) then
		return false
	end

	return true
end

function ClientGrabEggComponent:grabEgg_isSelfTeamTransport(staticId)
	local teamInfo = self:getCurTeamInfo()

	if teamInfo == nil or teamInfo.sortList == nil then
		return false
	end

	local transferPoint = self.space.transportInfo[staticId]

	if transferPoint == nil then
		return false
	end

	return table.contains(teamInfo.sortList, transferPoint.ownerUid)
end

function ClientGrabEggComponent:grabEgg_refreshTransportState(staticId)
	local ent = self.space:getEntityByStaticId(staticId)
	local transferPoint = self.space.transportInfo[staticId]

	if not transferPoint then
		return
	end

	if ent then
		ent:refreshInteractTrigger()
		ent:tryPlayTransportEffect(transferPoint.state)
		ent:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.GRAB_EGG_STATE, "refreshTopLogoInfo")
	end

	pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
		type = "addOrUpdate",
		id = staticId
	})
end

function ClientGrabEggComponent:grabEgg_transportState(staticId)
	local transferPoint = self.space.transportInfo[staticId]

	if not transferPoint then
		return Const.ROB_EGG_TRANSPORT_STATE.NORMAL
	end

	return transferPoint.state
end

local function transportCountDownId(staticId)
	return "transport_egg_" .. tostring(staticId)
end

function ClientGrabEggComponent:tryRestartTransportCountDown()
	local transportInfos = self.space and self.space.transportInfo

	if not transportInfos then
		return
	end

	local hasDungeonTeam = self:hasDungeonTeamInfo()

	for staticId, transferPoint in pairs(transportInfos) do
		local state = transferPoint.state

		if state == Const.ROB_EGG_TRANSPORT_STATE.TRANSPORTING and hasDungeonTeam and self:grabEgg_isTeammate(transferPoint.ownerUid) then
			self:grabEgg_startTransportCountDown(staticId)
		elseif state == Const.ROB_EGG_TRANSPORT_STATE.INVADING and transferPoint.robUid == self.uid then
			local remainTime = math.max(0, (transferPoint.finishTime or Time.secondCache) - Time.secondCache)

			pg.global.ui.tips:showControlPanel(Time.realSecondCache + remainTime, pg.getGameString("GRAB_EGG_TRANSPORT_INVADING"), 1)
			self:setInvasionInputEnable(false)
		end
	end
end

function ClientGrabEggComponent:grabEgg_startTransportCountDown(staticId)
	local transferPoint = self.space and self.space.transportInfo and self.space.transportInfo[staticId]

	if not transferPoint then
		return
	end

	local duration = (transferPoint.finishTime or 0) - Time.secondCache

	if duration > 0 then
		pg.global.ui.tips:showCountDown(duration, transportCountDownId(staticId), {
			infoText = pg.getGameString("GRAB_EGG_TRANSPORT_STATIONED")
		})
	end
end

function ClientGrabEggComponent:grabEgg_hideTransportCountDown(staticId)
	pg.global.ui.tips:hideCountDown(transportCountDownId(staticId))
end

function ClientGrabEggComponent:RPC_SC_StartTransportEgg(staticId, playerUid, eggItemId)
	local cData = ItemData[eggItemId]
	local isHugeEgg = cData and cData.eggtype == Const.ROB_EGG_TYPE.SUPER_BIG

	if self:grabEgg_isTeammate(playerUid) then
		self:grabEgg_startTransportCountDown(staticId)

		if isHugeEgg then
			pg.global.ui.tips:showEggTransferTip(8, pg.getGameString("GRAB_EGG_HUGE_EGG_TRANSFERING"), pg.getGameString("GRAB_EGG_HUGEEGG_SUBMIT_2"))
		end
	elseif isHugeEgg then
		pg.global.ui.tips:showEggTransferTip(7, pg.getGameString("GRAB_EGG_HUGE_EGG_TRANSFERING"), pg.getGameString("GRAB_EGG_HUGE_EGG_FIGHT_TIP"))
	end

	self:grabEgg_refreshTransportState(staticId)
end

function ClientGrabEggComponent:RPC_SC_StartRobEgg(staticId, playerUid, endTime)
	local transferPoint = self.space and self.space.transportInfo and self.space.transportInfo[staticId]

	if playerUid == self.uid then
		local remainTime = math.max(0, (endTime or Time.secondCache) - Time.secondCache)

		pg.global.ui.tips:showControlPanel(Time.realSecondCache + remainTime, pg.getGameString("GRAB_EGG_TRANSPORT_INVADING"), 1)
		self:setInvasionInputEnable(false)

		if not self:isControllingPet() then
			local token = {}

			self.robEggAnimToken = token

			local state = self:playAnimation(PlayableConst.Show_Pose01_Start)

			if state then
				state:AddAutoTransition(0)
				state:RemoveEndCallback()
				state:AddEndCallback(function(reason)
					if reason == PlayableConst.END_REASON.PLAYBACK and self.robEggAnimToken == token and not self:isControllingPet() then
						self:playAnimation(PlayableConst.Show_Pose01_Loop)
					end
				end)
			else
				self:playAnimation(PlayableConst.Show_Pose01_Loop)
			end
		end
	end

	if transferPoint and self:grabEgg_isTeammate(transferPoint.ownerUid) then
		pg.global.ui.tips:showEggTransferTip(7, pg.getGameString("GRAB_EGG_TRANSPORT_IS_INVADING"), pg.getGameString("GRAB_EGG_TRANSPORT_DRIVE_AWAY_INTRUDERS"))
	end

	self:grabEgg_refreshTransportState(staticId)
end

function ClientGrabEggComponent:RPC_SC_RobEggSuccess(staticId, prePlayerUid, newPlayerUid)
	if self:grabEgg_isTeammate(prePlayerUid) then
		self:grabEgg_hideTransportCountDown(staticId)
		pg.global.ui.tips:showEggTransferTip(1, pg.getGameString("GRAB_EGG_TRANSPORT_FAILED"), pg.getGameString("GRAB_EGG_TRANSPORT_BE_INVADED"))
	elseif self:grabEgg_isTeammate(newPlayerUid) then
		self:grabEgg_startTransportCountDown(staticId)
	end

	if newPlayerUid == self.uid then
		pg.global.ui.tips:hideControlPanel()
		self:setInvasionInputEnable(true)

		self.robEggAnimToken = nil

		if not self:isControllingPet() then
			self:playAnimation(PlayableConst.Show_Pose01_End)
		end
	end

	self:grabEgg_refreshTransportState(staticId)
end

function ClientGrabEggComponent:RPC_SC_TransportEggSucceed(staticId, playerUid, isHuge)
	if playerUid == self.uid or self:grabEgg_isTeammate(playerUid) then
		self:grabEgg_hideTransportCountDown(staticId)

		local tipKey = isHuge and "GRAB_EGG_TRANSPORT_IS_SUCCESS_REWARD_TIP_1" or "GRAB_EGG_TRANSPORT_IS_SUCCESS_REWARD_TIP"

		pg.global.ui.tips:showEggTransferTip(8, pg.getGameString(tipKey), pg.getGameString("GRAB_EGG_TRANSPORT_IS_SUCCESS_REWARD_DESC"))
	end

	self:grabEgg_refreshTransportState(staticId)
end

function ClientGrabEggComponent:RPC_SC_RobEggFailed(staticId, ownerUid, robberUid)
	if robberUid == self.uid then
		pg.global.ui.tips:hideControlPanel()
		self:setInvasionInputEnable(true)

		self.robEggAnimToken = nil

		if not self:isControllingPet() then
			self:playAnimation(PlayableConst.Show_Pose01_End)
		end
	end

	if ToBool(ownerUid) and self:grabEgg_isTeammate(ownerUid) then
		self:grabEgg_startTransportCountDown(staticId)
	end

	self:grabEgg_refreshTransportState(staticId)
end

function ClientGrabEggComponent:RPC_SC_AchieveRobEgg(eggShipId, eggItemId, eggPattern, eggPatternColor, isHuge)
	local tipKey = isHuge and "GRAB_EGG_TRANSPORT_IS_SUCCESS_REWARD_TIP_1" or "GRAB_EGG_TRANSPORT_IS_SUCCESS_REWARD_TIP"

	pg.global.showBubbleMessageRaw(pg.getGameString(tipKey), 3)

	local eggShip = pg.getEntity(eggShipId)

	eggShip:refreshInteractTrigger()
end

function ClientGrabEggComponent:grabEgg_PvpAreaUnlock()
	pg.global.ui.tips:showEggTransferTip(0, pg.getGameString("GRAB_EGG_PVP_UNLOCK_TITLE"), pg.getGameString("GRAB_EGG_PVP_UNLOCK_DESC"))
end

function ClientGrabEggComponent:RPC_SC_SuperEggShieldTimeUp()
	return
end

function ClientGrabEggComponent:RPC_SC_RobEggTipsEvent(event, param)
	local title, desc, state
	local show = true

	if event == Const.RobEggEvent.TransferEgg then
		show = (param.finishEggTask and self.space:isSingleMode() or false) and false
		state = 6
	elseif event == Const.RobEggEvent.EnterDG then
		title = pg.getGameString("GRAB_EGG_FIND_DUNGEON_1")
		desc = pg.getGameString("GRAB_EGG_FIND_DUNGEON_2")
		state = 3
	elseif event == Const.RobEggEvent.FindEgg then
		title = pg.getGameString("GRAB_EGG_FIND_EGG_1")
		desc = pg.getGameString("GRAB_EGG_FIND_EGG_2")
		state = 4
	elseif event == Const.RobEggEvent.ActivateDG then
		title = pg.getGameString("GRAB_EGG_DUNGEON_DOOR_1")
		desc = pg.getGameString("GRAB_EGG_DUNGEON_DOOR_2")
		state = 5
	elseif event == Const.RobEggEvent.SuperEggFirstControlled then
		local ownerUid = param and param.ownerUid

		if ownerUid == self.uid or self:grabEgg_isTeammate(ownerUid) then
			state = 8
			title = pg.getGameString("GRAB_EGG_LINK_HUGE_EGG")
			desc = pg.getGameString("GRAB_EGG_TRANSFER_REWARD_TIP")
		else
			state = 7
			title = pg.getGameString("GRAB_EGG_LINK_HUGE_EGG_OTHER")
			desc = pg.getGameString("GRAB_EGG_LINK_POS_EXPOSED")
		end
	elseif event == Const.RobEggEvent.SuperEggTransfered then
		local ownerUid = param and param.ownerUid
		local src = param and param.src

		if ownerUid ~= self.uid and not self:grabEgg_isTeammate(ownerUid) then
			if src == Const.TransEggSrc.Transporter then
				title = pg.getGameString("GRAB_EGG_HUGE_EGG_TRANSFERED")
			else
				title = pg.getGameString("GRAB_EGG_EGG_TRANSFER_SHIP")
			end

			desc = pg.getGameString("GRAB_EGG_EGG_ENCOURAGING_TIP")
			state = 7
		else
			show = false
		end
	elseif event == Const.RobEggEvent.LuckyMouseRefreshed then
		title = pg.getGameString("GRAB_EGG_DOUBLE_REWARDS_ACTIVATED")
		desc = pg.getGameString("GRAB_EGG_DOUBLE_PROMPT")
		state = 9
	elseif event == Const.RobEggEvent.KillLuckyMouse then
		title = pg.getGameString("GRAB_EGG_DOUBLE_REWARDS_GET")
		state = 6

		pg.global.ui.tips:showIconTextTip(title, 5, state)

		return
	elseif event == Const.RobEggEvent.GetBigEgg then
		title = pg.getGameString("GRAB_EGG_Precious_Egg_Spawn1")
		desc = pg.getGameString("GRAB_EGG_Precious_Egg_Spawn2")
		state = 10
	elseif event == Const.RobEggEvent.NeedKeyItem then
		local itemId = param and param.itemKeyId

		if itemId then
			local itemName = ItemUtils.getItemFinalNameStrByItemId(itemId)

			pg.global.showBubbleMessage(NoticeDef.ROB_EGG_NEED_KEY_ITEM, itemName)
		end

		return
	elseif event == Const.RobEggEvent.NewerGuide then
		if pg.game and pg.game.grabEgg then
			pg.game.grabEgg:startNormalGuideNavigation(param and param.guideEvent, param)
		else
			logger:warn("rob egg normal guide dropped: grabEggSystem is missing")
		end

		return
	elseif event == Const.RobEggEvent.ExitDanger then
		local text = param and param.text

		if text then
			pg.global.ui.tips:showIconTextTip(pg.getGameString(text), 6, 7)
		end

		return
	end

	if show then
		pg.global.ui.tips:showEggTransferTip(state, title, desc)
	end
end

function ClientGrabEggComponent:setInvasionInputEnable(enable)
	pg.game.input:enableControlInput(enable, HotkeyConst.INPUT_BLOCK_FLAG.CtrlMod)
	pg.game.input:setInputActionEnabled("Hud/OpenEmotion", enable, HotkeyConst.INPUT_BLOCK_FLAG.CtrlMod)
	pg.game.input:setInputActionEnabled("Hud/GamepadOpenEmoticon", enable, HotkeyConst.INPUT_BLOCK_FLAG.CtrlMod)

	if pg.me then
		pg.me.invasionInputDisabled = not enable
	end
end

function ClientGrabEggComponent:isInvasionInputDisabled()
	return self.invasionInputDisabled == true
end

function ClientGrabEggComponent:setSightOfViewRange(range, force, useAfterViewLimit)
	if range > 0 then
		local sceneId = self.space.sceneId
		local cData = DiGongConfData[sceneId]

		if cData then
			local nearFog = cData.ViewLimitNearFog
			local farFog = cData.ViewLimitFarFog
			local useAfter = useAfterViewLimit

			if useAfter == nil and self.space then
				useAfter = self.space.useAfterViewLimitFog
			end

			if useAfter then
				nearFog = cData.AfterViewLimitNearFog or nearFog
				farFog = cData.AfterViewLimitFarFog or farFog
			end

			pg.global.cameraMgr:TrySetSightOfViewRange(nearFog, farFog)
		end
	else
		pg.global.cameraMgr:UnloadSightOfViewEffect(force)

		if pg.me.fogMaskRadius and pg.me.fogMaskRadius > 0 then
			pg.me:setFogMaskRadius(0)
		end
	end
end

function ClientGrabEggComponent:getNearbyCollectionList()
	local entities = pg.game.interaction:getCollectItemEntities()
	local items = {}

	for i = 1, #entities do
		local entity = entities[i]

		if Utils.isCollectItem(entity) then
			local data = {}

			data.itemId = entity.reward
			data.entityId = entity.id
			data.interactId = entity.actionPrototypeId
			data.count = entity.isMultiple and entity.count or 1
			data.ownerUid = entity.ownerUid
			data.props = entity.props
			items[#items + 1] = data
		end
	end

	return items
end

function ClientGrabEggComponent:openNearbyItemInBag()
	local items = self:getNearbyCollectionList()

	pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_BAG, {
		items = items,
		bagType = UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM,
		name = pg.getGameString("GRAB_EGG_NEARBY_ITEM")
	})
end

function ClientGrabEggComponent:checkGrabEggLevelCondition(arg, extraArg)
	if not arg or not extraArg then
		return false
	end

	if arg <= self.eggLv and extraArg <= self.secEggLv then
		return true
	end

	return false
end

function ClientGrabEggComponent:destroy()
	if self.space and self.space:isGrabEgg() then
		self:setSightOfViewRange(0, true)
	end
end

return ClientGrabEggComponent
