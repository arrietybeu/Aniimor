-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\NpcDuelSharedUtils.lua

local NpcDuelData = require("Data.npc_duel_data")
local SysConfigData = require("Data.sys_config_data")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local NpcDuelSharedUtils = {}
local DEFAULT_VARIANT_ID = 1

function NpcDuelSharedUtils:getCurrentVariantId(playerNpcDuelComponent, npcDuelId)
	local npcDuelBasicInfo = playerNpcDuelComponent and playerNpcDuelComponent.npcDuelBasicInfo or nil
	local variantIdMap = npcDuelBasicInfo and npcDuelBasicInfo.variantIdMap or nil

	return variantIdMap and variantIdMap[npcDuelId] or DEFAULT_VARIANT_ID
end

function NpcDuelSharedUtils:getCurrentVariantStartCondition(playerNpcDuelComponent, duelId)
	local npcDuelId = tonumber(duelId) or 0
	local variantId = self:getCurrentVariantId(playerNpcDuelComponent, npcDuelId)
	local npcDuelConfig = NpcDuelData[npcDuelId]
	local subNpcDuelConfig = npcDuelConfig and npcDuelConfig[variantId] or nil
	local startCondition = subNpcDuelConfig and subNpcDuelConfig.startCondition or 0
	local result = subNpcDuelConfig ~= nil

	if result and startCondition > 0 then
		local triggerMap = playerNpcDuelComponent and playerNpcDuelComponent.triggerMap or nil

		result = triggerMap and triggerMap:isCompleteOrMeetCondition(startCondition) or false
	end

	return {
		npcDuelId = npcDuelId,
		variantId = variantId,
		startCondition = startCondition,
		result = result
	}
end

function NpcDuelSharedUtils:calcNpcDuelLevelDelta(player, npcLevel)
	local npcDuelId = tonumber(player and player.curNpcDuelId) or 0
	local variantId = tonumber(player and player.curNpcDuelVariantId) or 0
	local npcDuelConfig = NpcDuelData[npcDuelId]
	local subNpcDuelConfig = npcDuelConfig and npcDuelConfig[variantId] or nil
	local formulaId = tonumber(subNpcDuelConfig and subNpcDuelConfig.dynamicLevelAdjustment) or 0

	if formulaId <= 0 then
		return 0
	end

	local titleLv = tonumber(player and player.starTitle) or 1
	local playerLv = tonumber(player and player.level) or 1
	local playerBotLv = tonumber(npcLevel) or 1

	return Utils.formulaSafeCall(nil, formulaId, titleLv, playerLv, playerBotLv) or 0
end

function NpcDuelSharedUtils:calcNpcDuelLevelDeltaByDuelId(player, duelId, variantId, npcLevel)
	local npcDuelId = duelId or 0
	local variantId = variantId or 0
	local npcDuelConfig = NpcDuelData[npcDuelId]
	local subNpcDuelConfig = npcDuelConfig and npcDuelConfig[variantId] or nil
	local formulaId = tonumber(subNpcDuelConfig and subNpcDuelConfig.dynamicLevelAdjustment) or 0

	if formulaId <= 0 then
		return 0
	end

	local titleLv = tonumber(player and player.starTitle) or 1
	local playerLv = tonumber(player and player.level) or 1
	local playerBotLv = tonumber(npcLevel) or 1

	return Utils.formulaSafeCall(nil, formulaId, titleLv, playerLv, playerBotLv) or 0
end

function NpcDuelSharedUtils:clampNpcDuelBotLevel(level)
	local npcDuelDynamicLevelClamp = SysConfigData.NPCDUEL_DYNAMICLEVEL_CLAMP or {
		1,
		70
	}
	local npcDuelMinLevel = tonumber(npcDuelDynamicLevelClamp[1]) or 1
	local npcDuelMaxLevel = tonumber(npcDuelDynamicLevelClamp[2]) or 70

	return lume.clamp(math.floor(tonumber(level) or npcDuelMinLevel), npcDuelMinLevel, npcDuelMaxLevel)
end

return NpcDuelSharedUtils
