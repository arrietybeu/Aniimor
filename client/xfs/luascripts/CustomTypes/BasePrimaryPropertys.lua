-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BasePrimaryPropertys.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Utils = require("Common.Utils.Utils")
local ObjHelper = require("Common.ObjHelper")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PetAttrConvertData = require("Data.pet_attr_convert_data")
local FormulaData = require("Data.formula_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PriProRevertData = require("Data.primaryproperty_revert_data")
local ResonanceData = require("Data.pet_resonance_data")
local RecommendData = require("Data.pet_strength_recommend_data")
local BasePrimaryPropertys = class.LiteClass("BasePrimaryPropertys", CustomDict)
local math_floor = math.floor

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PET_INFO,
		ObjHelper.TYPE_PUPPET,
		ObjHelper.TYPE_PET
	}

	function BasePrimaryPropertys:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function BasePrimaryPropertys:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		return obj
	end
end

function BasePrimaryPropertys:genInitDict(petInfo)
	self.potentialPointSum = 0
	self.usedPotentialPointSum = 0
	self.propertyStrengMax = {}
	self.propertyStrengPoint = {}

	for i = 1, Const.BASE_PROPERTY_CNT do
		self.propertyStrengMax[i] = 0
		self.propertyStrengPoint[i] = 0
	end

	self.isAutoAddStrengPoint = true
	self.potentialPointSum = 0
	self.usedPotentialPointSum = 0

	self:updatePrimaryProperty()
end

function BasePrimaryPropertys:checkAddStrengPointSum(propertyId, points, preUsedPotentialPoint, preStrengPoint)
	local strengthenPoint = preStrengPoint or self.propertyStrengPoint[propertyId] or 0

	if points <= 0 then
		return false, 0, strengthenPoint
	end

	if propertyId == nil or PriProRevertData[propertyId] == nil then
		return false, 0, strengthenPoint
	end

	local usedPotentialPoint = preUsedPotentialPoint or self.usedPotentialPointSum or 0

	if strengthenPoint + points > (self.propertyStrengMax[propertyId] or 0) then
		return false, 0, strengthenPoint
	end

	local needPotentialPoint = 0

	for i = strengthenPoint + 1, strengthenPoint + points do
		needPotentialPoint = needPotentialPoint + FormulaData[3020].formula(i, math_floor)
	end

	if needPotentialPoint + usedPotentialPoint > self.potentialPointSum then
		return false, 0, strengthenPoint
	end

	strengthenPoint = strengthenPoint + points

	return true, needPotentialPoint, strengthenPoint
end

function BasePrimaryPropertys:checkSubStrengPointSum(propertyId, points, preUsedPotentialPoint, preStrengPoint)
	local strengthenPoint = preStrengPoint or self.propertyStrengPoint[propertyId] or 0

	if points <= 0 then
		return false, 0, strengthenPoint
	end

	if propertyId == nil or PriProRevertData[propertyId] == nil then
		return false, 0, strengthenPoint
	end

	local usedPotentialPoint = preUsedPotentialPoint or self.usedPotentialPointSum or 0

	if strengthenPoint < points then
		return false, 0, strengthenPoint
	end

	local needPotentialPoint = 0

	for i = strengthenPoint - points + 1, strengthenPoint do
		needPotentialPoint = needPotentialPoint + FormulaData[3020].formula(i, math_floor)
	end

	if usedPotentialPoint < needPotentialPoint then
		return false, 0, strengthenPoint
	end

	strengthenPoint = strengthenPoint - points

	return true, needPotentialPoint, strengthenPoint
end

function BasePrimaryPropertys:getPreAllocateList(petInfo)
	local petPrototypeData = PetPrototypeData[petInfo.templateId]
	local allocateList = {}

	if petPrototypeData == nil then
		return allocateList
	end

	local recommendData = RecommendData[petPrototypeData.default_addprop]

	if recommendData == nil then
		return allocateList
	end

	local preUsedPotentialPoint = 0
	local res, needPotentialPoint, strengthenPoint = false, 0, 0
	local flag = true
	local potentialPointRate = recommendData.recommendPropWeight

	if potentialPointRate ~= nil then
		while flag do
			flag = false

			for i, propertyId in ipairs(petPrototypeData.recommend_attr or EMPTY_TABLE) do
				if potentialPointRate[i] ~= nil and potentialPointRate[i] >= 0 then
					res, needPotentialPoint, strengthenPoint = self:checkAddStrengPointSum(propertyId, potentialPointRate[i], preUsedPotentialPoint, allocateList[propertyId] or 0)

					if res then
						preUsedPotentialPoint = preUsedPotentialPoint + needPotentialPoint
						allocateList[propertyId] = strengthenPoint
					end

					flag = res or flag
				end
			end
		end
	end

	if recommendData.weight ~= nil then
		flag = true

		while flag do
			flag = false

			for propertyId, value in ipairs(recommendData.weight) do
				if value >= 0 then
					res, needPotentialPoint, strengthenPoint = self:checkAddStrengPointSum(propertyId, value, preUsedPotentialPoint, allocateList[propertyId] or 0)

					if res then
						preUsedPotentialPoint = preUsedPotentialPoint + needPotentialPoint
						allocateList[propertyId] = strengthenPoint
					end

					flag = res or flag
				end
			end
		end
	end

	flag = true

	while flag do
		flag = false

		for propertyId, _ in pairs(PriProRevertData) do
			res, needPotentialPoint, strengthenPoint = self:checkAddStrengPointSum(propertyId, 1, preUsedPotentialPoint, allocateList[propertyId] or 0)

			if res then
				preUsedPotentialPoint = preUsedPotentialPoint + needPotentialPoint
				allocateList[propertyId] = strengthenPoint
			end

			flag = res or flag
		end
	end

	return allocateList
end

function BasePrimaryPropertys:getSupportGroupPotentialPoint(petInfo)
	local pointSum = 0

	for i = 1, petInfo.resonanceInfo.resonanceStage do
		local resonanceData = ResonanceData[i]

		if resonanceData == nil then
			break
		end

		for j, data in pairs(resonanceData) do
			if j > petInfo.resonanceInfo.resonanceLevel then
				break
			end

			if data ~= nil and data.addPoint ~= nil then
				pointSum = pointSum + data.addPoint
			end
		end
	end

	return pointSum
end

function BasePrimaryPropertys:getPropertyIdByName(propertyName)
	local data = PetAttrConvertData[propertyName]

	return data and data.id or nil
end

return BasePrimaryPropertys
