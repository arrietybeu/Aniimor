-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetData = require("Data.pet_data")
local PetTalentData = require("Data.pet_talent_data")
local ItemConstSourceData = require("Data.item_const_source_data")
local PetMap = class.LiteClass("PetMap", CustomDict)

function PetMap:getPlayer()
	local obj = self:getRootOwner()

	return Utils.isPlayer(obj) and obj or nil
end

function PetMap:getPetCountByPrototypeIdAndSkillCountMin(basePetPrototypeId, skillCount)
	local count = 0

	for _, petInfo in self:items() do
		local valid = true

		if basePetPrototypeId ~= 0 and petInfo.basePetPrototypeId ~= basePetPrototypeId then
			valid = false
		end

		if skillCount ~= 0 and skillCount > #petInfo.unlockedAbilityMap then
			valid = false
		end

		count = count + (valid and 1 or 0)
	end

	return count
end

function PetMap:getPetCountByPrototypeIdAndCpValueMin(basePetPrototypeId, cpValue)
	local count = 0

	for _, petInfo in self:items() do
		local valid = true

		if basePetPrototypeId ~= 0 and petInfo.basePetPrototypeId ~= basePetPrototypeId then
			valid = false
		end

		if cpValue ~= 0 and cpValue > petInfo:getCpValue() then
			valid = false
		end

		count = count + (valid and 1 or 0)
	end

	return count
end

function PetMap:getPetCountByPrototypeIdAndGender(basePetPrototypeId, needGender)
	local count = 0

	for _, petInfo in self:items() do
		local valid = true

		if basePetPrototypeId ~= 0 and petInfo.basePetPrototypeId ~= basePetPrototypeId then
			valid = false
		end

		if needGender ~= 0 and petInfo.gender ~= needGender then
			valid = false
		end

		count = count + (valid and 1 or 0)
	end

	return count
end

function PetMap:getPetCountByScore(stage)
	local count = 0

	for _, petInfo in self:items() do
		if stage == petInfo.propertyScoreStage then
			count = count + 1
		end
	end

	return count
end

function PetMap:getPetCountByAttr(attrCount, rarity)
	local count = 0

	for _, petInfo in self:items() do
		if rarity == 0 then
			if attrCount <= #petInfo.talentList then
				count = count + 1
			end
		else
			local curAttrCount = 0

			for _, v in ipairs(petInfo.talentList) do
				local ptdd = PetTalentData[v.templateId]

				if ptdd and ptdd.rarity == rarity then
					curAttrCount = curAttrCount + 1
				end
			end

			if attrCount <= curAttrCount then
				count = count + 1
			end
		end
	end

	return count
end

function PetMap:getPetCountBySpecialCharacter(petPrototypeId)
	local count = 0

	for _, petInfo in self:items() do
		if (petPrototypeId == 0 or petInfo.petPrototypeId == petPrototypeId) and petInfo.characterInfo:isSpecialCharacter() then
			count = count + 1
		end
	end

	return count
end

function PetMap:dumpExchange(maxCount, friendshipLevel)
	maxCount = maxCount or 10
	friendshipLevel = friendshipLevel or 1

	local player = self:getPlayer()

	if not player then
		return {}
	end

	local res = {}

	for _, petInfo in pairs(player.pets) do
		local pedd = Utils.getExchangePetConfig(petInfo)

		if pedd then
			local ok, err = Utils.checkExchangeRemovePet(player, petInfo, friendshipLevel, pedd)
			local itemCost = Utils.getExchangePetCost(petInfo, friendshipLevel, pedd)
			local itemOk = NoticeDef.SUCCESS == player:checkDelItemsByIdNumDict(itemCost, ItemConstSourceData.ITEM_CONSUME_EXCHANGE_PET)

			res[#res + 1] = {
				petId = petInfo.id,
				templateId = petInfo.templateId,
				petOk = ok,
				petErr = err or 0,
				itemCost = ItemUtils.getItemCountTable(itemCost),
				itemOk = itemOk
			}
		end
	end

	table.sort(res, function(a, b)
		if a.petOk ~= b.petOk then
			return a.petOk and not b.petOk
		end

		if a.itemOk ~= b.itemOk then
			return a.itemOk and not b.itemOk
		end

		if a.petErr ~= b.petErr then
			return a.petErr < b.petErr
		end

		if a.templateId ~= b.templateId then
			return a.templateId < b.templateId
		end

		return a.petId < b.petId
	end)

	return lume.first(res, maxCount)
end

function PetMap:dumpCur()
	local player = self:getPlayer()

	if not player then
		return {}
	end

	local prepareList = player.petPrepareList:getRawTable()
	local prepareActorIds = lume.map(prepareList, function(petId)
		local ent = pg.getEntity(petId)

		return ent and ent.actorId or 0
	end)
	local exploreList = player.petExploreList:getRawTable()
	local exploreActorIds = lume.map(exploreList, function(petId)
		local ent = pg.getEntity(petId)

		return ent and ent.actorId or 0
	end)

	return {
		prepareList = prepareList,
		prepareActorIds = prepareActorIds,
		exploreList = exploreList,
		exploreActorIds = exploreActorIds
	}
end

function PetMap:dump(maxCount)
	local res = {}

	for petId, petInfo in self:items() do
		res[#res + 1] = petInfo:dump(true)

		if maxCount and maxCount <= #res then
			break
		end
	end

	table.sort(res, function(a, b)
		return a._index < b._index
	end)

	return res
end

return PetMap
