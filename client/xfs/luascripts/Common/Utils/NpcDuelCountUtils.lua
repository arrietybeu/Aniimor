-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\NpcDuelCountUtils.lua

local NpcDuelData = require("Data.npc_duel_data")
local Utils = require("Common.Utils.Utils")
local NpcDuelCountUtils = {}

function NpcDuelCountUtils:checkNpcDuelClear(playerNpcDuelComponent, arg, extraArg)
	local npcDuelId = arg
	local variantId = 0
	local tag = 0
	local needClearCount = 0

	if type(extraArg) == "table" then
		variantId = extraArg[1] or 0

		if extraArg[3] ~= nil then
			tag = extraArg[2] or 0
			needClearCount = extraArg[3] or 0
		else
			needClearCount = extraArg[2] or 0
		end
	end

	if needClearCount <= 0 then
		needClearCount = 0
	end

	local clearCount = self:getNpcDuelClearCount(playerNpcDuelComponent, npcDuelId, variantId, tag)

	return needClearCount <= clearCount and 1 or 0
end

function NpcDuelCountUtils:getNpcDuelClearCount(playerNpcDuelComponent, npcDuelId, variantId, tag)
	npcDuelId = npcDuelId or 0
	variantId = variantId or 0
	tag = tag or 0

	if npcDuelId == 0 then
		return self:getAllNpcDuelClearCount(playerNpcDuelComponent, variantId, tag)
	end

	if variantId == 0 then
		return self:getNpcDuelTotalClearCount(playerNpcDuelComponent, npcDuelId, tag)
	end

	return self:getSingleVariantClearCount(playerNpcDuelComponent, npcDuelId, variantId, tag)
end

function NpcDuelCountUtils:getNpcDuelBasicInfo(playerNpcDuelComponent)
	return playerNpcDuelComponent and playerNpcDuelComponent.npcDuelBasicInfo or nil
end

function NpcDuelCountUtils:getCurrentVariantId(playerNpcDuelComponent, npcDuelId)
	local npcDuelBasicInfo = self:getNpcDuelBasicInfo(playerNpcDuelComponent)

	if not npcDuelBasicInfo or not npcDuelBasicInfo.variantIdMap then
		return 0
	end

	return npcDuelBasicInfo.variantIdMap[npcDuelId] or 0
end

function NpcDuelCountUtils:getCurrentPassCount(playerNpcDuelComponent, npcDuelId)
	local npcDuelBasicInfo = self:getNpcDuelBasicInfo(playerNpcDuelComponent)

	if not npcDuelBasicInfo or not npcDuelBasicInfo.variantPassCountMap then
		return 0
	end

	return npcDuelBasicInfo.variantPassCountMap[npcDuelId] or 0
end

function NpcDuelCountUtils:getVariantIdMap(playerNpcDuelComponent)
	local npcDuelBasicInfo = self:getNpcDuelBasicInfo(playerNpcDuelComponent)

	if not npcDuelBasicInfo or not npcDuelBasicInfo.variantIdMap then
		return nil
	end

	return npcDuelBasicInfo.variantIdMap
end

function NpcDuelCountUtils:hasTag(subNpcDuelConfig, tag)
	if tag == nil or tag == 0 then
		return true
	end

	if not Utils.isTable(subNpcDuelConfig) then
		return false
	end

	local tagList = subNpcDuelConfig.tagList

	if not Utils.isTable(tagList) then
		return false
	end

	for _, configTag in pairs(tagList) do
		if configTag == tag then
			return true
		end
	end

	return false
end

function NpcDuelCountUtils:getSingleVariantClearCount(playerNpcDuelComponent, npcDuelId, variantId, tag)
	local npcDuelConfig = NpcDuelData[npcDuelId]
	local subNpcDuelConfig = npcDuelConfig and npcDuelConfig[variantId] or nil

	if not subNpcDuelConfig or not self:hasTag(subNpcDuelConfig, tag) then
		return 0
	end

	local currentVariantId = self:getCurrentVariantId(playerNpcDuelComponent, npcDuelId)

	if currentVariantId <= 0 then
		return 0
	end

	if variantId == currentVariantId then
		return math.max(self:getCurrentPassCount(playerNpcDuelComponent, npcDuelId), 0)
	end

	if variantId < currentVariantId then
		local maxClearCount = npcDuelConfig[variantId].maxClearCount or 0

		return maxClearCount > 0 and maxClearCount or 0
	end

	return 0
end

function NpcDuelCountUtils:getNpcDuelTotalClearCount(playerNpcDuelComponent, npcDuelId, tag)
	local npcDuelConfig = NpcDuelData[npcDuelId]

	if not npcDuelConfig then
		return 0
	end

	local currentVariantId = self:getCurrentVariantId(playerNpcDuelComponent, npcDuelId)

	if currentVariantId <= 0 then
		return 0
	end

	local totalCount = 0

	for variantId = 1, currentVariantId do
		local subNpcDuelConfig = npcDuelConfig[variantId]

		if subNpcDuelConfig and self:hasTag(subNpcDuelConfig, tag) then
			if variantId == currentVariantId then
				totalCount = totalCount + math.max(self:getCurrentPassCount(playerNpcDuelComponent, npcDuelId), 0)
			else
				totalCount = totalCount + math.max(subNpcDuelConfig.maxClearCount or 0, 0)
			end
		end
	end

	return totalCount
end

function NpcDuelCountUtils:getAllNpcDuelClearCount(playerNpcDuelComponent, variantId, tag)
	variantId = variantId or 0

	local totalCount = 0
	local variantIdMap = self:getVariantIdMap(playerNpcDuelComponent)

	if not variantIdMap then
		return 0
	end

	for npcDuelId in pairs(variantIdMap) do
		if variantId > 0 then
			totalCount = totalCount + self:getSingleVariantClearCount(playerNpcDuelComponent, npcDuelId, variantId, tag)
		else
			totalCount = totalCount + self:getNpcDuelTotalClearCount(playerNpcDuelComponent, npcDuelId, tag)
		end
	end

	return totalCount
end

return NpcDuelCountUtils
