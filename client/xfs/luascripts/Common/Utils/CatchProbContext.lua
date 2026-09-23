-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\CatchProbContext.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("CatchProbContext")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local CatchProbGroup = require("Common.Utils.CatchProbGroup")
local ItemEffectData = require("Data.item_effect_data")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local CaptureUtils = require("Common.Utils.CaptureUtils")
local CaptureConst = require("Common.Const.CaptureConst")
local camp_data = require("Data.camp_data")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local cast_item_data = require("Data.cast_item_data")
local catch_prob_data = require("Data.catch_prob_data")
local catch_prob_ai_state_data = require("Data.catch_prob_ai_state_data")
local catch_prob_ai_tag_data = require("Data.catch_prob_ai_tag_data")
local catch_prob_buff_tag_data = require("Data.catch_prob_buff_tag_data")
local catch_prob_entity_tag_data = require("Data.catch_prob_entity_tag_data")
local catch_prob_reason_enum_data
local CatchProbContext = Class.LightClass("CatchProbContext")
local BALL_PROB_FUNC = 5002
local CATCH_BUFF_VAL_NAME = "CatchProbBuffVal"
local BREAK_RATIO_PLAYER_MUTI_VAL_NAME = "breakRatioPlayerMultiplierVal"
local BUFF_VAL_FORMAT = "BUFF_VAL_%s"

function CatchProbContext:ctor()
	self.probGroup = CatchProbGroup.new()
end

function CatchProbContext:free()
	self._tempPlayer = nil
	self._tempEnt = nil
end

function CatchProbContext.get(player, hitEntity, itemId, fromBehind, isFirstCheck)
	if not CatchProbContext.cachedContext then
		CatchProbContext.cachedContext = CatchProbContext.new()
	end

	local context = CatchProbContext.cachedContext

	context:_setContext(player, hitEntity, itemId, fromBehind, isFirstCheck)
	context:_evaluate()
	context:free()

	return context
end

function CatchProbContext.clientGet(hitEntity, itemId)
	if not CatchProbContext.cachedContext then
		CatchProbContext.cachedContext = CatchProbContext.new()
	end

	local context = CatchProbContext.cachedContext

	itemId = itemId or pg.global.ui.hudV2:getCurSelectPropId()

	context:_setContext(pg.me, hitEntity, itemId)
	context:_evaluate()
	context:free()

	return context
end

function CatchProbContext.clientIsForbidCatchIgnoreBall(ent)
	local player = pg.me

	if not ent or not ent.templateId or not player or not player.space then
		return false
	end

	if Utils.isNpc(ent) then
		return true, "isNpc"
	end

	if Utils.isPet(ent) then
		return true, "isPet"
	end

	if ent.needDoGroupReward and player:isInCatchMode() and not player:isInBossCatch() then
		return true, "isElite"
	end

	if ent.spriteIdAfterCatch == nil or not PetData[ent.spriteIdAfterCatch] then
		return true, "spriteIdAfterCatch == nil"
	end

	if ent.isInCapture and not ent.needDoGroupReward then
		return true, "ent.isInCapture"
	end

	if ent.instantCatchResult and ent.instantCatchResult[player.id] then
		return true, "instantCatchResult exist"
	end

	local campInfo = camp_data[ent.camp]

	if campInfo and campInfo[Const.CAMP_PLAYER_DEFAULT] ~= Const.WORLD_PAIRS_CAMP_ENEMY then
		return true, "camp is not WORLD_PAIRS_CAMP_ENEMY"
	end

	if ent.space and ent.space:isTrainStage() then
		return true, "isTrainStage"
	end

	if ent.isTrapped then
		return true, "ent.isTrapped"
	end

	if ent.seatId and ent.seatId > 0 then
		return true, "ent.RIDING_ST"
	end

	if ent.BURROW_ST and ent:BURROW_ST() then
		return true, "ent.BURROW_ST"
	end

	if AIUtils.getMimicryState(ent) == AiConst.MimicryState.Defense then
		return true, "ent.isMimicryState"
	end

	if not Utils.checkValidTarget(ent, player) and not ent.needDoGroupReward then
		return true, "checkValidTarget false"
	end

	if not CatchProbContext._checkAiStateCanCatch(ent, ent.templateId) then
		return true, "checkAiStateCanCatch false"
	end

	local pdd = PuppetData[ent.templateId]
	local baseProbData = pdd and catch_prob_data[pdd.catchProbGroup]

	if baseProbData then
		local baseProb = ent:isDead() and baseProbData.baseProbDeath or baseProbData.baseProb

		if baseProb <= 0 then
			return true, "baseProb <= 0"
		end
	end

	if ent.isDummyClone then
		return true, "ent.isDummyClone"
	end

	if not CatchProbContext.cachedForbidContext then
		CatchProbContext.cachedForbidContext = CatchProbContext.new()
	end

	local context = CatchProbContext.cachedForbidContext

	context._tempPlayer = player

	local forbidByOwner = context:_checkMultiplePlayer(ent)

	context:free()

	if forbidByOwner then
		return true, "checkMultiplePlayer"
	end

	return false
end

function CatchProbContext:_setContext(player, ent, itemId, fromBehind, isFirstCheck)
	self._tempPlayer = player
	self._tempEnt = ent
	self.playerId = player.id
	self.entId = ent.id
	self.itemId = itemId
	self.isFirstCheck = pg.component == "client" and true or isFirstCheck

	if pg.component ~= "client" then
		self.fromBehind = fromBehind
	end

	self.valid = false

	if not ent then
		if pg.component == "game" and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ent is nil")
		end

		return
	elseif ent.isLogEmptyEntity then
		return
	end

	if pg.component == "client" then
		local forbidCatchReason = ent:getConfigData().forbidCatchReason

		if forbidCatchReason and Utils.isNpc(ent) then
			self.valid = true

			return
		end

		if Utils.isPet(ent) then
			self.valid = true

			return
		end
	end

	local templateId = ent.templateId

	if templateId == nil then
		if pg.component == "game" and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ent.templateId is nil", ent.id)
		end

		return
	end

	local pdd = PuppetData[templateId]

	if not pdd then
		if pg.component == "game" and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Puppet templateId:%s pdd is nil, spriteIdAfterCatch:%s", ent.templateId, ent.spriteIdAfterCatch)
		end

		return
	end

	self.baseProbData = catch_prob_data[pdd.catchProbGroup]

	if not self.baseProbData then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch_prob_data is nil templateId:%s catchProbGroup:%s", templateId, pdd.catchProbGroup)
		end

		return
	end

	self.baseProbForbidCatchReason = self.baseProbData.forbidCatchReason
	self.aiStateData = catch_prob_ai_state_data[pdd.catchProbGroup]
	self.aiTagData = catch_prob_ai_tag_data[pdd.catchProbGroup]
	self.buffTagData = catch_prob_buff_tag_data[pdd.catchProbGroup]
	self.entityTagData = catch_prob_entity_tag_data[pdd.catchProbGroup]
	self.buffCacheValue = EntityCacheValueUtils.getCacheValue(self._tempEnt, CATCH_BUFF_VAL_NAME)
	self.breakRatioPlayerMultiplierVal = EntityCacheValueUtils.getCacheValue(self._tempPlayer, BREAK_RATIO_PLAYER_MUTI_VAL_NAME) or 1

	local itemEffectData = ItemEffectData[self.itemId]

	if not itemEffectData then
		return
	end

	self.castItemData = cast_item_data[itemEffectData.castItemId]

	if not self.castItemData then
		return
	end

	self.valid = true
end

function CatchProbContext:_evaluate()
	self:clear()

	if not self.valid then
		self.finalProb = 0
		self.cantCatchReason = ""
		self.minMaxReason = ""

		return self.finalProb
	end

	self:_evaluateCanCatch()

	if not self.canCatch then
		self.finalProb = 0
		self.cantCatchReason = self:_getCantCatchReason()
		self.minMaxReason = self:_getMinMaxReason()

		return self.finalProb
	end

	self:_evaluateBase()
	self:evaluateAffinityProb()

	if self._tempEnt:isDead() then
		self.probGroup:setBase(self.baseProb * self.ballProb)
		self.probGroup:addMust("baseProb", self.baseProb)
		self.probGroup:addMust("ballProb", self.ballProb)
		self.probGroup:addMust(self.entTagKey, self.entTagProb)
		self.probGroup:addMinMax(self.entTagKey, self.entTagProb)
		self.probGroup:addMust(self.affinityKey, self.affinityProb)
		self.probGroup:addMinMax(self.affinityKey, self.affinityProb)
	elseif self._tempEnt:isInCombat() then
		self:evaluateHpProb()
		self:evaluateBuffStateProb()
		self:evaluateLevelProb()

		if self._tempEnt:inBreak() then
			self.breakProb = self.baseProbData.breakRatio * self.breakRatioPlayerMultiplierVal
		end

		self.probGroup:setBase(self.baseProb * self.ballProb * self.hpStateProb * self.levelStateProb)
		self.probGroup:addMust("baseProb", self.baseProb)
		self.probGroup:addMust("ballProb", self.ballProb)

		local hpRatioKey = self.hpStateProb >= 1 and "hpRatioFuncBuff" or "hpRatioFuncDebuff"

		self.probGroup:addMust(hpRatioKey, self.hpStateProb)
		self.probGroup:addMust("breakRatio", self.breakProb)
		self.probGroup:addMust(self.buffStateKey, self.buffStateProb)
		self.probGroup:addMust(self.entTagKey, self.entTagProb)
		self.probGroup:addMust("levelProb", self.levelStateProb)
		self.probGroup:addMinMax("breakRatio", self.breakProb)
		self.probGroup:addMinMax(self.buffStateKey, self.buffStateProb)
		self.probGroup:addMinMax(self.entTagKey, self.entTagProb)
		self.probGroup:addMust(self.affinityKey, self.affinityProb)
		self.probGroup:addMinMax(self.affinityKey, self.affinityProb)
	else
		self:evaluateFromBehind()
		self:evaluateAIProb()
		self:evaluateBuffStateProb()
		self:evaluateLevelProb()
		self.probGroup:setBase(self.baseProb * self.ballProb * self.fromBehindProb * self.levelStateProb)
		self.probGroup:addMust("baseProb", self.baseProb)
		self.probGroup:addMust("ballProb", self.ballProb)
		self.probGroup:addMust("fromBehindRadio", self.fromBehindProb)
		self.probGroup:addMust(self.aiStateKey, self.aiStateProb)
		self.probGroup:addMust(self.buffStateKey, self.buffStateProb)
		self.probGroup:addMust(self.aiTagKey, self.aiTagProb)
		self.probGroup:addMust(self.entTagKey, self.entTagProb)
		self.probGroup:addMust("levelProb", self.levelStateProb)
		self.probGroup:addMinMax(self.aiStateKey, self.aiStateProb)
		self.probGroup:addMinMax(self.buffStateKey, self.buffStateProb)
		self.probGroup:addMinMax(self.aiTagKey, self.aiTagProb)
		self.probGroup:addMinMax(self.entTagKey, self.entTagProb)
		self.probGroup:addMust(self.affinityKey, self.affinityProb)
		self.probGroup:addMinMax(self.affinityKey, self.affinityProb)
	end

	local inCatchRogue = self._tempPlayer.space and Utils.isSpaceCatchRogueDungeon(self._tempPlayer.space.spaceType)

	if inCatchRogue then
		local buff = self._tempPlayer.actorBuff:findOneBuffByTemplateId(AbilityConst.BUFF_CATCH_ROGUE_NEXT_SUCCESS)

		if buff and buff.buffData.layer >= 1 then
			self.probGroup:addMust("catchSuccessBuff", 999)
		end
	end

	self.probGroup:evaluate()

	self.finalProb = self.probGroup.prob

	if self.finalProb <= 0 then
		self.canCatch = false
		self.finalProb = 0
	end

	if pg.component == "game" then
		self:_evaluateSpecialCaptureCondition()
	end

	if not self.canCatch then
		self.cantCatchReason = self:_getCantCatchReason()
	else
		self.cantCatchReason = ""
	end

	self.minMaxReason = self:_getMinMaxReason()

	return self.finalProb
end

function CatchProbContext:_evaluateBase()
	if self._tempEnt:isDead() then
		self.baseProb = self.baseProbData.baseProbDeath
	else
		self.baseProb = self.baseProbData.baseProb
	end

	local playerBaseProb = self._tempPlayer:getBaseCatchRatio()

	self.baseProb = self.baseProb * (1 + playerBaseProb)
	self.baseProb = math.max(0, self.baseProb)

	self:_evaluateBallProb()

	local min = math.huge
	local max = -math.huge
	local minK, maxK
	local hasTag = false

	for k, v in pairs(self.entityTagData or EMPTY_TABLE) do
		if Utils.hasEntityTag(self._tempEnt, k) then
			hasTag = true

			if v < min then
				min = v
				minK = k
			end

			if max < v then
				max = v
				maxK = k
			end
		end
	end

	if hasTag then
		if min < 1 then
			self.entTagProb = min
			self.entTagKey = minK
		else
			self.entTagProb = math.max(0, max)
			self.entTagKey = maxK
		end
	end
end

function CatchProbContext:_evaluateBallProb()
	if self.ballProb ~= nil then
		return self.ballProb
	end

	if not self.baseProbData or not self.castItemData then
		return nil
	end

	local cid = self.castItemData
	local ballProbFunc = self.baseProbData.ballProbFunc or BALL_PROB_FUNC
	local createPlenty = false

	if cid.createPlentyProb and Utils.hasEntityTag(self._tempEnt, "TE_Wild_CreatePlenty") then
		createPlenty = true
	end

	self.ballProb = Utils.formulaSafeCall(-1, ballProbFunc, cid.ballLv, cid.ballLvDownRange, cid.ballLvUpRange, self._tempEnt.level, cid.ballProbBase, self._tempPlayer:getMaxSkillCatchLevel(), createPlenty and cid.createPlentyProb or 1, self._tempPlayer.level)
	self.ballProb = math.max(0, self.ballProb)

	return self.ballProb
end

function CatchProbContext:isFromBehind(player, hitEntity)
	if hitEntity:inBreak() then
		return false
	end

	local dir = player:getPosition() - hitEntity:getPosition()

	dir.y = 0

	local entDir = hitEntity:getRotation():Forward()

	entDir.y = 0

	return Vector3.Dot(dir:Normalize(), entDir:Normalize()) < -0.5
end

function CatchProbContext:evaluateFromBehind()
	if pg.component == "client" then
		self.fromBehind = self:isFromBehind(self._tempPlayer, self._tempEnt)

		local perceivedValue = self._tempEnt:getPerceivedValue(self._tempPlayer.actorId)
		local fromBehindThreshold = self.baseProbData.fromBehindThreshold

		if fromBehindThreshold <= perceivedValue then
			self.fromBehind = false
		end
	end

	self.fromBehindProb = self.fromBehind and self.baseProbData.fromBehindRadio or 1
	self.fromBehindProb = math.max(0, self.fromBehindProb)
end

function CatchProbContext:evaluateAffinityProb()
	local hasEntityTag, hasClosePet, reason = CaptureUtils.isAffinityPet(self._tempPlayer, self._tempEnt)

	self.isAffinity = hasEntityTag or hasClosePet
	self.affinityReason = reason or ""

	if hasClosePet then
		local ratio = self.baseProbData and self.baseProbData.affinityRatio

		if ratio and ratio > 0 then
			self.affinityProb = ratio
		end
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("CatchProbContext:evaluateAffinityProb hasEntityTag:%s, hasClosePet:%s, reason:%s, affinityProb:%s, templateId:%s, actorId:%s, playerUid:%s", hasEntityTag, hasClosePet, reason, self.affinityProb, self._tempEnt.templateId, self._tempEnt.actorId, self._tempPlayer.uid)
	end
end

function CatchProbContext:evaluateAIProb()
	local stateName = AIUtils.getBehaviorStateName(self._tempEnt)

	self.aiStateProb = self.aiStateData[stateName] or 1
	self.aiStateKey = stateName

	local min = math.huge
	local max = -math.huge
	local hasTag = false
	local minKey, maxKey

	if self._tempEnt.hasAITag ~= nil then
		for k, v in pairs(self.aiTagData) do
			if self._tempEnt:hasAITag(k) then
				hasTag = true

				if v < min then
					min = v
					minKey = k
				end

				if max < v then
					max = v
					maxKey = k
				end
			end
		end
	end

	if hasTag then
		if min < 1 then
			self.aiTagProb = min
			self.aiTagKey = minKey
		else
			self.aiTagProb = math.max(0, max)
			self.aiTagKey = maxKey
		end
	end
end

function CatchProbContext:evaluateHpProb()
	local hpFuncId = self.baseProbData.hpRatioFunc
	local prob = Utils.formulaSafeCall(-1, hpFuncId, self._tempEnt:getHp(), self._tempEnt:getMaxHp())

	if prob < 0 then
		prob = 1
	end

	self.hpStateProb = math.max(0, prob)
end

function CatchProbContext:evaluateBuffStateProb()
	for k, v in pairs(self.buffTagData) do
		local buffTagId = AbilityConst[k]

		if buffTagId and self._tempEnt.actorBuff:hasTag(buffTagId) or self.buffCacheValue and k == string.format(BUFF_VAL_FORMAT, self.buffCacheValue) then
			self.buffStateProb = v
			self.buffStateKey = k

			break
		end
	end
end

function CatchProbContext:evaluateLevelProb()
	local levelFuncId = self.baseProbData.levelRatioFunc
	local prob = levelFuncId and Utils.formulaSafeCall(-1, levelFuncId, self._tempEnt.level, self._tempPlayer.level, self._tempPlayer:getMaxSkillMasterLevel(), self._tempPlayer:getMaxSkillCatchLevel()) or 1

	prob = math.max(0.1, prob)
	self.levelStateProb = prob
end

function CatchProbContext:_getCantCatchReason()
	if not self.valid then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("CatchProbContext:_getCantCatchReason self.valid = false! Please Check Config! templateId:%s", self._tempEnt.templateId)
		end

		return ""
	end

	local ent = self._tempEnt
	local emptySlotNum = self._emptySlotNum

	if Utils.isNpc(ent) and ent:getConfigData().forbidCatchReason then
		return ent:getConfigData().forbidCatchReason
	elseif Utils.isPet(ent) then
		if Utils.isPlayerCurPet(ent) and ent.isMainPet then
			return "isPet"
		elseif Utils.isPet(ent) and ent:getMasterEntity() ~= pg.me then
			return "hasOwner"
		end
	elseif self._tempEnt:isDead() and self.baseProbData.baseProbDeath <= 0 or self.baseProbData.baseProb <= 0 then
		return self.baseProbForbidCatchReason
	elseif self._tempEnt.needDoGroupReward and self._tempPlayer:isInCatchMode() and not self._tempPlayer:isInBossCatch() then
		return "isElite"
	elseif self.castItemData.proxy == "BigBall" and emptySlotNum < 10 or self.castItemData.proxy == "CatchBall" and emptySlotNum < 1 then
		return "lackEmptySlot"
	elseif self._mimicryState == AiConst.MimicryState.Defense then
		return "inMimicry"
	elseif ent.BURROW_ST and ent:BURROW_ST() then
		return "inSneak"
	elseif CatchProbContext._checkMultiplePlayer(self, ent) then
		return "onlyOwnerCanCatch"
	elseif self.probGroup and self.probGroup.prob and self.probGroup.prob <= 0 and self.probGroup.mustReason then
		return self.probGroup.mustReason
	elseif self:_evaluateBallProb() and self.ballProb <= 0 then
		return "ballProbZero"
	end

	return ent.agent and ent.agent:getBehaviorStateName()
end

function CatchProbContext:_getMinMaxReason()
	if not self.valid then
		return "INVALID CAPTURE CONFIG"
	end

	return string.format("isMust:%s, reason:%s, minMaxProb:%s", self.probGroup.isMust, self.probGroup.reason, self.probGroup.minMaxProb)
end

function CatchProbContext:_evaluateCanCatch()
	local ent = self._tempEnt

	if ent == nil then
		self:_setCantCatchDebugInfo("ent == nil")

		return
	end

	if Utils.isNpc(ent) then
		self:_setCantCatchDebugInfo("isNpc")

		return
	end

	if Utils.isPet(ent) then
		self:_setCantCatchDebugInfo("isPet")

		return
	end

	if pg.component == "client" and ent.needDoGroupReward and self._tempPlayer:isInCatchMode() and not self._tempPlayer:isInBossCatch() then
		return
	end

	self._emptySlotNum = TriggerUtils.getStatusTriggerCurValue(self._tempPlayer, TriggerConst.TRIGGER_PET_REMAINDER_NUM)

	if self.castItemData.proxy == "BigBall" and self._emptySlotNum < 10 or self.castItemData.proxy == "CatchBall" and self._emptySlotNum < 1 then
		self:_setCantCatchDebugInfo("emptySlot Lack")

		return
	end

	if ent.spriteIdAfterCatch == nil or not PetData[ent.spriteIdAfterCatch] then
		self:_setCantCatchDebugInfo("ent.spriteIdAfterCatch == nil")

		return
	end

	if self.isFirstCheck and ent.isInCapture and not ent.needDoGroupReward then
		self:_setCantCatchDebugInfo("ent.isInCapture")

		return
	end

	if ent.instantCatchResult and ent.instantCatchResult[self._tempPlayer.id] then
		self:_setCantCatchDebugInfo("ent.instantCatchResult exist")

		return
	end

	local campInfo = camp_data[ent.camp]

	if campInfo and campInfo[Const.CAMP_PLAYER_DEFAULT] ~= Const.WORLD_PAIRS_CAMP_ENEMY then
		self:_setCantCatchDebugInfo("camp is not WORLD_PAIRS_CAMP_ENEMY")

		return
	end

	if ent.space and ent.space:isTrainStage() then
		self:_setCantCatchDebugInfo("ent.space:isTrainStage()")

		return
	end

	if pg.component == "client" and ent.isTrapped then
		self:_setCantCatchDebugInfo("ent.isTrapped")

		return
	end

	if ent.seatId and ent.seatId > 0 then
		self:_setCantCatchDebugInfo("ent.RIDING_ST")

		return
	end

	if ent.BURROW_ST and ent:BURROW_ST() then
		self:_setCantCatchDebugInfo("ent.BURROW_ST")

		return
	end

	self._mimicryState = AIUtils.getMimicryState(ent)

	if self._mimicryState == AiConst.MimicryState.Defense then
		self:_setCantCatchDebugInfo(string.format("ent.isMimicryState curState is %s", ent.characterState))

		return
	end

	if self.isFirstCheck and not Utils.checkValidTarget(ent, self._tempPlayer) and not ent.needDoGroupReward then
		self:_setCantCatchDebugInfo("Utils.checkValidTarget(ent) return false")

		return
	end

	if not CatchProbContext._checkAiStateCanCatch(ent, ent.templateId) then
		self:_setCantCatchDebugInfo("CatchProbContext.checkAiStateCanCatch")

		return
	end

	if ent:isDead() and self.baseProbData.baseProbDeath <= 0 then
		self:_setCantCatchDebugInfo("ent.isDead baseProbData.baseProbDeath <= 0")

		return
	end

	if ent.isDummyClone then
		self:_setCantCatchDebugInfo("ent.isDummyClone")

		return
	end

	if CatchProbContext._checkMultiplePlayer(self, ent) then
		self:_setCantCatchDebugInfo("CatchProbContext.checkMultiplePlayer")

		return
	end

	local inCatchRogue = self._tempPlayer.space and Utils.isSpaceCatchRogueDungeon(self._tempPlayer.space.spaceType)

	if inCatchRogue and not self._tempPlayer.catchRogueInfo:canFireBall(self._tempPlayer, self.itemId, true) then
		self:_setCantCatchDebugInfo("checkCatchRogue canFireBall false")

		return
	end

	self.canCatch = true
end

function CatchProbContext:_setCantCatchDebugInfo(info)
	self.cantCatchDebugInfo = info
end

function CatchProbContext._checkAiStateCanCatch(ent, templateId)
	if ent:isInCombat() then
		return true
	end

	local pdd = PuppetData[templateId]
	local aiStateData = catch_prob_ai_state_data[pdd.catchProbGroup]
	local stateName = AIUtils.getBehaviorStateName(ent)
	local aiStateProb = aiStateData[stateName] or 1

	return aiStateProb >= 0
end

function CatchProbContext:_checkMultiplePlayer(ent)
	local spaceType = Utils.getSpaceType(self._tempPlayer.space.sceneId)

	if not Utils.isSpaceSingleWorld(spaceType) then
		return false
	end

	local catchOwnerType = ent:getConfigData().catchOwnerType

	if not catchOwnerType or catchOwnerType == Const.CATCH_OWNER_TYPE.NONE then
		return false
	else
		local catchOwnerCondInfo = ent:getConfigData().catchOwnerCondInfo
		local condSuccess = false

		for _, info in ipairs(catchOwnerCondInfo or EMPTY_TABLE) do
			local checkFunc = self["check_" .. info]

			if checkFunc and checkFunc(ent, info) then
				condSuccess = true

				break
			end
		end

		if not condSuccess then
			return false
		end

		if catchOwnerType == Const.CATCH_OWNER_TYPE.OWNER then
			if pg.component == "client" then
				return not self._tempPlayer:isSpaceOwner()
			elseif pg.component == "game" then
				return not self._tempPlayer.space:isOwnerPlayer(self._tempPlayer)
			end
		end
	end
end

function CatchProbContext:_evaluateSpecialCaptureCondition()
	local ent = self._tempEnt
	local isBreakCatch = self.baseProbData.isBreakCatch
	local isDeadCatch = self.baseProbData.isDeadCatch
	local isBehindCatch = self.baseProbData.isBehindCatch
	local isInCombatCatch = self.baseProbData.isInCombatCatch
	local isNotInCombatCatch = self.baseProbData.isNotInCombatCatch
	local isOtherCatch = self.baseProbData.isOtherCatch

	if isBreakCatch ~= nil and ent:inBreak() then
		self.serverFinalProb = isBreakCatch

		return
	end

	if isDeadCatch ~= nil and ent:isDead() then
		self.serverFinalProb = isDeadCatch

		return
	end

	if isBehindCatch ~= nil and self.fromBehind then
		self.serverFinalProb = isBehindCatch

		return
	end

	if isInCombatCatch ~= nil and ent:isInCombat() then
		self.serverFinalProb = isInCombatCatch

		return
	end

	if isNotInCombatCatch ~= nil and not ent:isInCombat() then
		self.serverFinalProb = isNotInCombatCatch

		return
	end

	if isOtherCatch ~= nil then
		self.serverFinalProb = isOtherCatch

		return
	end
end

function CatchProbContext:clear()
	self:_setCantCatchDebugInfo(nil)

	self.canCatch = false
	self.baseProb = 0
	self.ballProb = nil

	if pg.component == "client" then
		self.fromBehind = false
	end

	self.entTagProb = 1
	self.entTagKey = "entTagKey"
	self.aiTagProb = 1
	self.aiTagKey = "aiTagKey"
	self.fromBehindProb = 1
	self.aiStateProb = 1
	self.aiStateKey = "aiStateKey"
	self.hpStateProb = 1
	self.levelStateProb = 1
	self.buffStateProb = 1
	self.buffStateKey = "buffStateKey"
	self.breakProb = 1
	self.isAffinity = false
	self.affinityReason = ""
	self.affinityKey = CaptureConst.AFFINITY_KEY
	self.affinityProb = 1
	self.finalProb = 0
	self.serverFinalProb = nil
	self.cantCatchReason = ""
	self.minMaxReason = ""
	self._emptySlotNum = math.huge
	self._mimicryState = AiConst.MimicryState.None

	self.probGroup:clear()
end

function CatchProbContext.check_Shiny(ent, key)
	local label = ent and ent.label

	return Utils.isLabelShiny(label)
end

function CatchProbContext.check_Demonic(ent, key)
	local label = ent and ent.label

	return Utils.isLabelDark(label)
end

function CatchProbContext.check_TE_Wild_OneTime(ent, key)
	return Utils.hasEntityTag(ent, key)
end

function CatchProbContext:checkReason_Npc()
	if Utils.isNpc(self._tempEnt) and self._tempEnt:getConfigData().forbidCatchReason then
		return self._tempEnt:getConfigData().forbidCatchReason
	else
		return
	end
end

function CatchProbContext:checkReason_Pet()
	if Utils.isPet(self._tempEnt) then
		if Utils.isPlayerCurPet(self._tempEnt) and self._tempEnt.isMainPet then
			return "isPet"
		elseif Utils.isPet(self._tempEnt) and self._tempEnt:getMasterEntity() ~= pg.me then
			return "hasOwner"
		end
	else
		return
	end
end

function CatchProbContext:checkReason_baseProbForbidCatchReason()
	if self._tempEnt:isDead() and self.baseProbData.baseProbDeath <= 0 or self.baseProbData.baseProb <= 0 then
		return self.baseProbForbidCatchReason
	else
		return
	end
end

function CatchProbContext:dump(effectiveFinalProb)
	if not self.valid then
		return "INVALID CAPTURE CONFIG"
	end

	local displayFinalProb = effectiveFinalProb ~= nil and effectiveFinalProb or self.finalProb

	return string.format("baseProb:%s, ballProb:%s \n fromBehindProb:%s, hpStateProb:%s, \n entTagKey:%s entTagProb:%s, \n aiStateKey:%s, aiStateProb:%s, \n aiTagKey:%s, aiTagProb:%s \n breakProb:%s, \n buffStateKey:%s, buffStateProb:%s, \n affinityKey:%s, affinityProb:%s, affinityReason:%s, \n finalProb:%s", self.baseProb, self.ballProb, self.fromBehindProb, self.hpStateProb, self.entTagKey, self.entTagProb, self.aiStateKey, self.aiStateProb, self.aiTagKey, self.aiTagProb, self.breakProb, self.buffStateKey, self.buffStateProb, self.affinityKey, self.affinityProb, self.affinityReason, displayFinalProb)
end

return CatchProbContext
