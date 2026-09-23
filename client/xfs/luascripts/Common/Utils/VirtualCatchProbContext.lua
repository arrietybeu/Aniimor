-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\VirtualCatchProbContext.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local PuppetData = require("Data.puppet_data")
local cast_item_data = require("Data.cast_item_data")
local catch_prob_data = require("Data.catch_prob_data")
local ItemEffectData = require("Data.item_effect_data")
local logger = LoggerManager.getLogger("VirtualCatchProbContext")
local VirtualCatchProbContext = {}
local BALL_PROB_FUNC = 5002

local function makeInvalidResult(reason)
	return {
		fromBehind = false,
		canCatch = false,
		finalProb = 0,
		cantCatchReason = reason or ""
	}
end

function VirtualCatchProbContext.compute(player, hitEntity, itemId)
	if not player or not hitEntity or not itemId then
		return makeInvalidResult("invalid_param")
	end

	if Utils.isNpc(hitEntity) then
		local cfg = hitEntity.getConfigData and hitEntity:getConfigData()
		local forbid = cfg and cfg.forbidCatchReason

		return makeInvalidResult(forbid or "isNpc")
	end

	if Utils.isPet(hitEntity) then
		if Utils.isPlayerCurPet(hitEntity) and hitEntity.isMainPet then
			return makeInvalidResult("isPet")
		elseif hitEntity.getMasterEntity and hitEntity:getMasterEntity() ~= player then
			return makeInvalidResult("hasOwner")
		end

		return makeInvalidResult("isPet")
	end

	if hitEntity.isTrapped then
		return makeInvalidResult("isTrapped")
	end

	local templateId = hitEntity.templateId

	if not templateId then
		return makeInvalidResult("no_template")
	end

	local pdd = PuppetData[templateId]

	if not pdd then
		return makeInvalidResult("no_puppet_data")
	end

	local baseProbData = catch_prob_data[pdd.catchProbGroup]

	if not baseProbData then
		return makeInvalidResult("no_base_prob_data")
	end

	local itemEffectData = ItemEffectData[itemId]

	if not itemEffectData then
		return makeInvalidResult("no_item_effect_data")
	end

	local castItemData = cast_item_data[itemEffectData.castItemId]

	if not castItemData then
		return makeInvalidResult("no_cast_item_data")
	end

	local baseProb

	if hitEntity.isDead and hitEntity:isDead() then
		baseProb = baseProbData.baseProbDeath
	else
		baseProb = baseProbData.baseProb
	end

	if not baseProb or baseProb <= 0 then
		return makeInvalidResult(baseProbData.forbidCatchReason or "baseProbZero")
	end

	local playerBaseProb = player.getBaseCatchRatio and player:getBaseCatchRatio() or 0

	baseProb = baseProb * (1 + playerBaseProb)
	baseProb = math.max(0, baseProb)

	local ballProbFunc = baseProbData.ballProbFunc or BALL_PROB_FUNC
	local createPlenty = false

	if castItemData.createPlentyProb and Utils.hasEntityTag(hitEntity, "TE_Wild_CreatePlenty") then
		createPlenty = true
	end

	local maxSkillCatchLevel = player.getMaxSkillCatchLevel and player:getMaxSkillCatchLevel() or 0
	local ballProb = Utils.formulaSafeCall(-1, ballProbFunc, castItemData.ballLv, castItemData.ballLvDownRange, castItemData.ballLvUpRange, hitEntity.level or 1, castItemData.ballProbBase, maxSkillCatchLevel, createPlenty and castItemData.createPlentyProb or 1, player.level or 1)

	ballProb = math.max(0, ballProb)

	if ballProb <= 0 then
		return makeInvalidResult("ballProbZero")
	end

	local finalProb = baseProb * ballProb

	finalProb = math.max(0, math.min(1, finalProb))
	finalProb = 0.8

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("compute: templateId=%s itemId=%s baseProb=%.3f ballProb=%.3f finalProb=%.3f", tostring(templateId), tostring(itemId), baseProb, ballProb, finalProb)
	end

	return {
		fromBehind = false,
		finalProb = finalProb,
		canCatch = finalProb > 0
	}
end

return VirtualCatchProbContext
