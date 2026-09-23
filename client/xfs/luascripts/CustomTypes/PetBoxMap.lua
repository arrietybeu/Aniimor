-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBoxMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local GmConst = require("Common.Const.GmConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ObjHelper = require("Common.ObjHelper")
local Const = require("Common.Const.Const")
local PetBoxMap = class.LiteClass("PetBoxMap", CustomDict)
local table_sort = table.sort
local math_max = math.max
local math_min = math.min

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PLAYER,
		ObjHelper.TYPE_HOMELANE
	}

	function PetBoxMap:getObj()
		local obj = self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function PetBoxMap:getObj()
		local obj = self:getRootOwner()

		return obj
	end
end

function PetBoxMap:getPetIndex(resPetId)
	for indexBox, info in self:items() do
		for indexSlot, petId in info:items() do
			if petId == resPetId then
				return indexBox, indexSlot
			end
		end
	end

	return nil, nil
end

function PetBoxMap:getPetId(indexBox, indexSlot)
	local boxInfo = self[indexBox]

	if boxInfo then
		local petId = boxInfo[indexSlot]

		return string.notNilOrEmpty(petId) and petId
	end

	return nil
end

function PetBoxMap:getBoxNumMax()
	if ObjHelper.validateObj(self:getObj(), ObjHelper.TYPE_HOMELANE) then
		return 1
	end

	return GmConst.getName("petBoxNumMax") or SysConfigData.BOX_NUM_MAX or 0
end

function PetBoxMap:getSlotCount()
	if ObjHelper.validateObj(self:getObj(), ObjHelper.TYPE_HOMELANE) then
		return HomeLandUtils.getPetMaxCount(self:getObj())
	end

	return GmConst.getName("petBoxSlotCount") or SysConfigData.SLOT_OF_BOX or 0
end

function PetBoxMap:getPetBoxExtraCount()
	local result, count = ObjHelper.callObjFunc(self:getObj(), "getPetBoxExtraCount")

	return result and count or 0
end

function PetBoxMap:getValidBoxCount()
	local validBoxCount = #self.sequence

	if self.tempBoxCount > self:getPetBoxExtraCount() then
		validBoxCount = validBoxCount - self.tempBoxCount + self:getPetBoxExtraCount()
	end

	return math_min(validBoxCount, self:getBoxNumMax())
end

function PetBoxMap:getValidEmptySlot()
	local count = 0

	for sIndex = 1, self:getValidBoxCount() do
		local indexBox = self.sequence[sIndex]
		local info = self[indexBox]

		count = count + (info:isLocked() and 0 or math_max(info.slotCount - info.count, 0))
	end

	return count
end

function PetBoxMap:sortPetIds(petIds, pets, sortType, orderType, familyLocalScope)
	orderType = orderType or 0

	local petBoxSortFunc

	if sortType == Const.PET_BOX_SORT.TIME then
		function petBoxSortFunc(lPetId, rPetId)
			local lv = pets[lPetId]:getTimeForRank(orderType)
			local rv = pets[rPetId]:getTimeForRank(orderType)

			if orderType == 0 then
				return lv < rv or lv == rv and lPetId < rPetId
			else
				return rv < lv or lv == rv and rPetId < lPetId
			end
		end
	elseif sortType == Const.PET_BOX_SORT.SCORE then
		function petBoxSortFunc(lPetId, rPetId)
			local lv = pets[lPetId]:getCpValueForRank(orderType)
			local rv = pets[rPetId]:getCpValueForRank(orderType)

			if orderType == 0 then
				return lv < rv or lv == rv and lPetId < rPetId
			else
				return rv < lv or lv == rv and rPetId < lPetId
			end
		end
	elseif sortType == Const.PET_BOX_SORT.NUMBER then
		function petBoxSortFunc(lPetId, rPetId)
			local lv = pets[lPetId]:getNumberIdForRank(orderType)
			local rv = pets[rPetId]:getNumberIdForRank(orderType)

			if orderType == 0 then
				return lv < rv or lv == rv and lPetId < rPetId
			else
				return rv < lv or lv == rv and rPetId < lPetId
			end
		end
	elseif sortType == Const.PET_BOX_SORT.LEVEL then
		function petBoxSortFunc(lPetId, rPetId)
			local lv = pets[lPetId]:getLevelForRank(orderType)
			local rv = pets[rPetId]:getLevelForRank(orderType)

			if orderType == 0 then
				return lv < rv or lv == rv and lPetId < rPetId
			else
				return rv < lv or lv == rv and rPetId < lPetId
			end
		end
	elseif sortType == Const.PET_BOX_SORT.RATING then
		function petBoxSortFunc(lPetId, rPetId)
			local lv = pets[lPetId]:getPropRatingResultForRank(orderType)
			local rv = pets[rPetId]:getPropRatingResultForRank(orderType)

			if orderType == 0 then
				return lv < rv or lv == rv and lPetId < rPetId
			else
				return rv < lv or lv == rv and rPetId < lPetId
			end
		end
	elseif sortType == Const.PET_BOX_SORT.FAMILY then
		local familyMinCountId = {}

		if familyLocalScope then
			for _, petId in ipairs(petIds) do
				local petInfo = pets[petId]
				local fid = petInfo:getEthnicGroup()
				local cid = petInfo.countId

				if not familyMinCountId[fid] or cid < familyMinCountId[fid] then
					familyMinCountId[fid] = cid
				end
			end
		else
			for _, petInfo in pairs(pets) do
				local fid = petInfo:getEthnicGroup()
				local cid = petInfo.countId

				if not familyMinCountId[fid] or cid < familyMinCountId[fid] then
					familyMinCountId[fid] = cid
				end
			end
		end

		function petBoxSortFunc(lPetId, rPetId)
			local lPet = pets[lPetId]
			local rPet = pets[rPetId]
			local lFamilyRank = familyMinCountId[lPet:getEthnicGroup()]
			local rFamilyRank = familyMinCountId[rPet:getEthnicGroup()]

			if lFamilyRank ~= rFamilyRank then
				if orderType == 0 then
					return lFamilyRank < rFamilyRank
				else
					return rFamilyRank < lFamilyRank
				end
			end

			if lPet.petPrototypeId ~= rPet.petPrototypeId then
				if orderType == 0 then
					return lPet.petPrototypeId < rPet.petPrototypeId
				else
					return lPet.petPrototypeId > rPet.petPrototypeId
				end
			end
		end
	end

	if petBoxSortFunc then
		table_sort(petIds, petBoxSortFunc)
	end

	return petIds
end

return PetBoxMap
