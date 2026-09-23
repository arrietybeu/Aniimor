-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Helper\\ItemUseChecker.lua

local class = require("Core.Framework.Class")
local ItemUseChecker = class.LightClass("ItemUseChecker")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local ItemEffectData = require("Data.item_effect_data")
local PetLevelData = require("Data.pet_level_data")
local AttributeConst = require("Common.Const.AttributeConst")
local SafeCallbackWithReturn = require("Core.Framework.SafeCallbackWithReturn")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")

function ItemUseChecker:ctor()
	return
end

local DEFINE_USE_ITEM_TYPE = {}

function ItemUseChecker.getPetFullLv()
	return #PetLevelData
end

function ItemUseChecker.previewUpLvAndExp(pId, id, num)
	local me = pg.me
	local petInfo = me:getPetInfo(pId)

	if petInfo == nil then
		return 0, 0
	end

	local eData = ItemEffectData[id]

	if eData == nil then
		return petInfo.level, 0
	end

	local addExp = eData.petExp * num
	local tExp = petInfo.exp + addExp
	local nLv = petInfo.level

	while tExp >= 0 do
		nLv = nLv + 1

		local nLvData = PetLevelData[nLv]

		if nLvData == nil then
			nLvData = PetLevelData[nLv - 1]
		end

		if nLvData == nil then
			break
		end

		tExp = tExp - (nLvData.needExp or 0)
	end

	local _, curLv = Utils.getPetExpMaxAdd(pg.me, pId)

	curLv = math.min(curLv, nLv - 1)

	local addLv = curLv - petInfo.level

	return addLv, addExp
end

function ItemUseChecker.checkPetCanUpMaxLv(petId, toLevel)
	local me = pg.me
	local petInfo = me:getPetInfo(petId)

	if petInfo == nil then
		return 0, false
	end

	local maxAddExp, maxLv, maxLvExp = Utils.getPetExpMaxAdd(pg.me, petId, toLevel)
	local curLv = petInfo.level
	local fullLv = ItemUseChecker.getPetFullLv()
	local isFullLv = fullLv <= curLv

	return maxLv, isFullLv, maxAddExp, maxLvExp
end

function ItemUseChecker.checkPetCanAddMaxExp(petId)
	local me = pg.me
	local petInfo = me:getPetInfo(petId)

	if petInfo == nil then
		return 0
	end

	local maxLv = ItemUseChecker.checkPetCanUpMaxLv(petId)
	local curLv = petInfo.level
	local ntData = PetLevelData[curLv + 1]

	if ntData == nil then
		return 0
	end

	local canAddExp = (ntData.needExp or 0) - petInfo.exp

	curLv = curLv + 1

	while curLv <= maxLv do
		ntData = PetLevelData[curLv + 1]

		if ntData == nil then
			ntData = PetLevelData[curLv]

			break
		end

		canAddExp = canAddExp + (ntData.needExp or 0)
		curLv = curLv + 1
	end

	return canAddExp
end

function ItemUseChecker.checkPetExpUseMax(petId, itemId)
	local me = pg.me
	local canAddExp = ItemUseChecker.checkPetCanAddMaxExp(petId)
	local eData = ItemEffectData[itemId]

	if eData == nil then
		return 0
	end

	local addExp = eData.petExp
	local ownNum = ItemUtils.getItemCountById(me, itemId)
	local useNum = math.ceil(canAddExp / addExp)

	return math.min(ownNum, useNum)
end

function ItemUseChecker.checkUsePropMaxLevel(petId, propIds, toLevel)
	if #propIds == 0 then
		return 0, "error"
	end

	local me = pg.me
	local petInfo = me:getPetInfo(petId)

	if petInfo == nil then
		return 0, "error"
	end

	local petExpAddRatio = pg.me:getPetExpAddRatio() or 0
	local canAddMaxExp = 0

	for _, v in ipairs(propIds) do
		local eData = ItemEffectData[v]

		if eData then
			local ownNum = ItemUtils.getItemCountById(me, v)

			canAddMaxExp = canAddMaxExp + math.round(ownNum * (eData.petExp or 0) * (1 + petExpAddRatio))
		end
	end

	if canAddMaxExp == 0 then
		return 0, "notEnough"
	end

	local tExp = petInfo.exp + canAddMaxExp
	local nLv = petInfo.level

	while tExp >= 0 do
		nLv = nLv + 1

		local nLvData = PetLevelData[nLv]

		if nLvData == nil then
			nLvData = PetLevelData[nLv - 1]
		end

		if nLvData == nil then
			break
		end

		tExp = tExp - (nLvData.needExp or 0)
	end

	local maxExpUpLv = nLv - 1
	local maxTheoryLv, isFullLv, maxAddExp, maxLevelExp = ItemUseChecker.checkPetCanUpMaxLv(petId, toLevel)
	local maxFinalLv = math.min(maxTheoryLv, maxExpUpLv)
	local addLv = maxFinalLv - petInfo.level

	addLv = math.max(0, addLv)

	local res = "error"

	if isFullLv then
		res = "fullLv"
	elseif maxTheoryLv <= petInfo.level then
		if Utils.canLevelBreakthrough(petId) then
			res = "canBreak"
		else
			res = "maxUpLv"
		end
	elseif addLv == 0 then
		res = "notEnough"
	elseif addLv > 0 then
		res = "canUpgrade"
	end

	return addLv, res, maxAddExp, maxLevelExp
end

function ItemUseChecker.checkConsumeWithUpLv(petId, propIds, upLv)
	local temp = {}
	local res = {}

	if #propIds == 0 then
		return res, 0, 0, 0, 0
	end

	local me = pg.me

	for i, v in ipairs(propIds) do
		temp[i] = {
			id = v,
			ownNum = ItemUtils.getItemCountById(me, v),
			oneAddExp = ItemUtils.getItemPetExp(me, v)
		}
		res[v] = 0
	end

	table.sort(temp, function(a, b)
		return a.oneAddExp > b.oneAddExp
	end)

	local petInfo = me:getPetInfo(petId)

	if petInfo == nil then
		return res, 0, 0, 0, 0
	end

	local curExp = petInfo.exp
	local toLevel = petInfo.level + upLv
	local petExpAddRatio = pg.me:getPetExpAddRatio() or 0
	local _, state, maxAddExp, maxLevelExp = ItemUseChecker.checkUsePropMaxLevel(petId, propIds, toLevel)
	local needMaxExp = math.safe_ceil((maxAddExp or 0) / (1 + petExpAddRatio))
	local maxExp = maxLevelExp or 0
	local totalAddExp = 0
	local needMaxExpTemp = needMaxExp

	while needMaxExp > 0 do
		local hasUse = false

		for _, v in ipairs(temp) do
			if needMaxExp >= v.oneAddExp and v.ownNum - res[v.id] > 0 then
				res[v.id] = res[v.id] + 1
				needMaxExp = needMaxExp - v.oneAddExp
				totalAddExp = totalAddExp + v.oneAddExp
				hasUse = true

				break
			end
		end

		if not hasUse then
			break
		end
	end

	if needMaxExp > 0 then
		local idx = #temp

		while idx > 0 do
			local _Left = temp[idx]

			if _Left and _Left.ownNum - res[_Left.id] > 0 then
				res[_Left.id] = res[_Left.id] + 1
				needMaxExp = needMaxExp - _Left.oneAddExp
				totalAddExp = totalAddExp + _Left.oneAddExp

				break
			end

			idx = idx - 1
		end
	end

	local beyond = totalAddExp - needMaxExpTemp

	while beyond > 0 do
		local idx = #temp
		local hasSub = false

		while idx > 0 do
			local _Left = temp[idx]

			if _Left and res[_Left.id] > 0 and beyond > _Left.oneAddExp then
				res[_Left.id] = res[_Left.id] - 1
				needMaxExp = needMaxExp + _Left.oneAddExp
				totalAddExp = totalAddExp - _Left.oneAddExp
				hasSub = true

				break
			end

			idx = idx - 1
		end

		if not hasSub then
			break
		end
	end

	if state == "notEnough" then
		beyond = needMaxExpTemp + curExp
	else
		beyond = totalAddExp - needMaxExpTemp
	end

	return res, curExp, beyond, maxExp, petExpAddRatio
end

function ItemUseChecker.parseConsumeInfo(petId, itemMap, addRatio)
	addRatio = addRatio or 0

	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return 0, 0, 0
	end

	local nLv = petInfo.level
	local curExp = petInfo.exp
	local maxExp = curExp
	local nLvData = PetLevelData[nLv + 1]

	if nLvData == nil then
		nLvData = PetLevelData[nLv]
	end

	maxExp = nLvData and nLvData.needExp or maxExp

	local addExp = 0

	for k, v in pairs(itemMap) do
		local eData = ItemEffectData[k]

		if eData then
			addExp = addExp + (eData.petExp or 0) * v
		end
	end

	if addRatio > 0 then
		addExp = math.round(addExp * (1 + addRatio))
	end

	return addExp, curExp, maxExp
end

function ItemUseChecker.checkItemUse(args)
	local eData = ItemEffectData[args.id]

	if eData == nil then
		return false
	end

	local reuseTimes = eData.reuseTimes
	local usedTimes = args.usedTimes

	if reuseTimes ~= nil and reuseTimes >= 0 and reuseTimes <= usedTimes then
		return false
	end

	local limitConfigId = eData.countLimit

	if limitConfigId ~= nil and not pg.me.useLimitMap:testLimit(limitConfigId) then
		return false, NoticeDef.ERROR_LIMIT_EXCEED
	end

	local checkFunc = DEFINE_USE_ITEM_TYPE[eData.sType]

	if checkFunc == nil then
		return true
	end

	return SafeCallbackWithReturn(checkFunc, args)
end

function ItemUseChecker.check_PetExpUse(args)
	local me = pg.me
	local petInfo = me:getPetInfo(args.petId)

	if petInfo == nil then
		return false
	end

	local eData = ItemEffectData[args.id]

	if eData == nil or args.num <= 0 then
		return false
	end

	local canAddExp = ItemUseChecker.checkPetCanAddMaxExp(args.petId)
	local subExp = eData.petExp * (args.num - 1)

	if canAddExp <= subExp then
		return false
	end

	return true
end

function ItemUseChecker.check_SkillBookUse(args)
	local ied = ItemEffectData[args.id]

	if ied == nil then
		return false
	end

	local petInfo = pg.me:getPetInfo(args.petId)

	if petInfo == nil then
		return false
	end

	return true
end

DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_EXP] = ItemUseChecker.check_PetExpUse
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_MOOD] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_CHARACTER_RANDOM] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_CHARACTER_SPECIFIC] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_CHARACTER_MODIFY] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_UNLOCK_ABILITY] = ItemUseChecker.check_SkillBookUse
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_CAST_ABILITY] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PETBALL_FEED] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PETBALL_EXERCISE] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PETBALL_BREED] = nil
DEFINE_USE_ITEM_TYPE[ItemConst.USEITEM_TYPE_PET_STRENGTHEN_POINT] = nil

return ItemUseChecker
