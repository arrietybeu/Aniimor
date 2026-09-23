-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BasePropertyList.lua

local CustomList = require("Core.PropertySync.CustomList")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ObjHelper = require("Common.ObjHelper")
local PetPropLearnData = require("Data.pet_prop_learn_data")
local BasePropertyList = class.LiteClass("BasePropertyList", CustomList)
local PET_INDIVIDUAL_MAX_LEARN_FORMULA_ID = 2200

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PET_INFO,
		ObjHelper.TYPE_PUPPET,
		ObjHelper.TYPE_PET
	}

	function BasePropertyList:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function BasePropertyList:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		return obj
	end
end

function BasePropertyList:getSpeciesPoint(propIndex)
	local baseProperty = self[propIndex]

	if not baseProperty then
		return 0
	end

	if baseProperty.speciesPoint and baseProperty.speciesPoint ~= 0 then
		return baseProperty.speciesPoint
	end

	return Utils.getBasePropertySpeciesPoint(ObjHelper.getObjConfigData(self:getObj()), propIndex)
end

function BasePropertyList:_getRefreshTotalParams()
	local obj = self:getObj()
	local petInfo = Utils.isPetInfoType(obj) and obj or Utils.isPet(obj) and obj.petInfo

	if petInfo then
		return Utils.genRefreshTotalParamsByPetInfo(petInfo.level, petInfo.propertyScoreStage, Utils.isIndividualFullLearned(self))
	end

	return {
		objLevel = ObjHelper.getObjLevel(obj)
	}
end

function BasePropertyList:getTotal(propIndex, params)
	local baseProperty = self[propIndex]

	if not baseProperty then
		return 0, 0
	end

	return Utils.PropertyRefreshTotal(propIndex, baseProperty, params or self:_getRefreshTotalParams(), self:getSpeciesPoint(propIndex))
end

function BasePropertyList:getTotalByUp(propIndex, params)
	local _, totalByUp = self:getTotal(propIndex, params)

	return totalByUp
end

function BasePropertyList:getRawTableWithDerived(params)
	local dict = self:getRawTable()

	for propIndex = 1, Const.BASE_PROPERTY_CNT do
		local baseProperty = dict[propIndex]

		if baseProperty then
			baseProperty.speciesPoint = self:getSpeciesPoint(propIndex)
			baseProperty.total, baseProperty.totalByUp = self:getTotal(propIndex, params)
		end
	end

	return dict
end

function BasePropertyList.genInitDict(objType, configData, forceIndividualLevelByLearnList, forceRandGroupIds, individualLevelInfo, createPlentyTalentEffect)
	local dict = {}

	if individualLevelInfo == nil then
		individualLevelInfo = {}
	end

	local forceRandGroupIdList = {}

	for idx = 1, Const.BASE_PROPERTY_CNT do
		if forceRandGroupIds[idx] then
			forceRandGroupIdList[#forceRandGroupIdList + 1] = forceRandGroupIds[idx]
		end
	end

	for idx = 1, Const.BASE_PROPERTY_CNT do
		dict[idx] = Utils.getPropertyInitDict(objType, configData, idx, nil, forceRandGroupIdList, individualLevelInfo, createPlentyTalentEffect)

		local forceIndividualLevelByLearn = forceIndividualLevelByLearnList and forceIndividualLevelByLearnList[idx]

		if forceIndividualLevelByLearn ~= nil then
			local randomLevel = dict[idx].indLv - dict[idx].iLvLn

			dict[idx] = {
				iLvLn = forceIndividualLevelByLearn,
				indLv = dict[idx].iLvLn + randomLevel
			}
		end
	end

	return dict
end

function BasePropertyList:getIndividualLearnLevel()
	local total = 0

	for idx = 1, Const.BASE_PROPERTY_CNT do
		total = total + self[idx].iLvLn
	end

	return total
end

function BasePropertyList:getIndividualMaxLearnLevel()
	local obj = self:getObj()
	local objLevel = ObjHelper.getObjLevel(obj)
	local objStage = ObjHelper.getObjStage(obj)
	local resonanceInfo = obj and obj.resonanceInfo or {}
	local total = Utils.formulaSafeCall(0, PET_INDIVIDUAL_MAX_LEARN_FORMULA_ID, objLevel or 0, objStage or 0, resonanceInfo.resonanceStage or 0)
	local max = 0

	for idx = 1, Const.BASE_PROPERTY_CNT do
		local baseLevel = self[idx]:getBaseIndividualLevel()

		max = max + (Utils.getTotalIndividualLevelMax(idx) - baseLevel)
	end

	return lume.clamp(total, 0, max)
end

function BasePropertyList:getIndividualLearnCost(propIndex, toLevel)
	local baseProp = self[propIndex]

	if baseProp == nil then
		return {}
	end

	local curLevel = baseProp.indLv

	if toLevel <= curLevel then
		return {}
	end

	local curLearnLevel = baseProp.iLvLn
	local dstLearnLevel = curLearnLevel + (toLevel - curLevel)
	local obj = self:getObj()
	local configData = ObjHelper.getObjConfigData(obj)
	local ethnicGroup = configData and configData.ethnicGroup or 0

	return Utils.calcPetLearnCost(ethnicGroup, curLearnLevel, dstLearnLevel)
end

function BasePropertyList:getIndividualResetPayback()
	local res = {}

	for propIndex, _ in self:items() do
		ItemUtils.mergeItemInfoResult(res, self:getIndividualResetPaybackOne(propIndex))
	end

	return res
end

function BasePropertyList:getIndividualResetPaybackOne(propIndex, dstLevel)
	local baseProp = self[propIndex]

	if baseProp == nil then
		return {}
	end

	dstLevel = dstLevel or baseProp:getBaseIndividualLevel()

	local curLearnLevel = baseProp.iLvLn

	if curLearnLevel == 0 then
		return {}
	end

	local dstLearnLevel = curLearnLevel - (baseProp.indLv - dstLevel)

	if dstLearnLevel < 0 then
		return {}
	end

	local obj = self:getObj()
	local configData = ObjHelper.getObjConfigData(obj)
	local ethnicGroup = configData and configData.ethnicGroup or 0

	return ItemUtils.formatIdNumBoundDict(Utils.calcPetLearnCost(ethnicGroup, dstLearnLevel, curLearnLevel))
end

function BasePropertyList.getBaseIndividualLevels(selfInfo, excludeEnhanced)
	local res = {}
	local getBaseIndividualLevel = require("CustomTypes.BaseProperty").getBaseIndividualLevel

	for index, prop in pairs(selfInfo) do
		res[index] = getBaseIndividualLevel(prop, excludeEnhanced)
	end

	return res
end

function BasePropertyList:dump()
	local res = {}

	for k, v in self:items() do
		res[tostring(k)] = string.format("spePoint=%d, indLevel=%d, indLearn=%d, total=%d", self:getSpeciesPoint(k), v.indLv, v.iLvLn, self:getTotal(k))
	end

	return res
end

return BasePropertyList
