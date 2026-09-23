-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchStrengthPoint\\PetBatchStrengthPointModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetBatchStrengthPointModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetBatchStrengthPointModel = Class.LightClass("PetBatchStrengthPointModel", UIModel)
local Const = require("Common.Const.Const")
local PetManagementUtils = require("Utils.PetManagementUtils")
local NoticeDef = require("Common.NoticeDef")

function PetBatchStrengthPointModel:ctor()
	return
end

function PetBatchStrengthPointModel:syncModelInfo(petId, forceSyncSvr)
	self.petId = petId

	local newSixPropInfos = PetManagementUtils.getPetNewSixPropInfos(petId)

	self.potentialPointSum = newSixPropInfos and newSixPropInfos.potentialPointSum or 0
	self.usedPotentialPointSum = newSixPropInfos and newSixPropInfos.usedPotentialPointSum or 0
	self.remainCanAddPointNum = newSixPropInfos and newSixPropInfos.remainPotentialPointSum or 0

	local detailPropInfos = newSixPropInfos and newSixPropInfos.detailPropInfos or {}

	self.batchAddPointData = self.batchAddPointData or {}

	for propId, _ in pairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		self.batchAddPointData[propId] = {
			propId = propId,
			curStrengthLv = detailPropInfos and detailPropInfos[propId] and detailPropInfos[propId].propertyStrengPoint or 0,
			maxStrengthLv = detailPropInfos and detailPropInfos[propId] and detailPropInfos[propId].propertyStrengMax or 0,
			extraStrengthLv = detailPropInfos and detailPropInfos[propId] and detailPropInfos[propId].extraStrengthLv or 0,
			extraStrengthMax = detailPropInfos and detailPropInfos[propId] and detailPropInfos[propId].propExtraStrengMax or PetManagementUtils.getNewPropExtraMaxLv()
		}

		if forceSyncSvr then
			self.batchAddPointData[propId].curSelectedSLv = self.batchAddPointData[propId].curStrengthLv
		elseif self.batchAddPointData[propId].curSelectedSLv then
			self.batchAddPointData[propId].curSelectedSLv = self.batchAddPointData[propId].curSelectedSLv
		else
			self.batchAddPointData[propId].curSelectedSLv = self.batchAddPointData[propId].curStrengthLv
		end
	end

	self:syncUpateAllPropCanReachedMaxLv()
end

function PetBatchStrengthPointModel:init(info)
	self:sysnModelInfo(info.petId)
end

function PetBatchStrengthPointModel:getDisplayPointDatas()
	return self.batchAddPointData
end

function PetBatchStrengthPointModel:getDisplayUsedPPointSum()
	return self.usedPotentialPointSum
end

function PetBatchStrengthPointModel:getDisplayStrengthLv(newPropId)
	local curSelectedSLv = self.batchAddPointData[newPropId] and self.batchAddPointData[newPropId].curSelectedSLv or 0

	return curSelectedSLv
end

function PetBatchStrengthPointModel:getManualMaxSLv(newPropId)
	return self.batchAddPointData[newPropId] and self.batchAddPointData[newPropId].maxStrengthLv or 0
end

function PetBatchStrengthPointModel:getExtraMaxSLv(newPropId)
	return self.batchAddPointData[newPropId] and self.batchAddPointData[newPropId].extraStrengthMax or 0
end

function PetBatchStrengthPointModel:tryAddStrengthLv(newPropId, addLv)
	local maxV = self.batchAddPointData[newPropId].maxStrengthLv
	local oldV = self:getDisplayStrengthLv(newPropId)
	local newV = oldV + addLv

	if maxV < newV then
		return NoticeDef.PET_NEW_PROP_HAS_REACH_MAX
	end

	local needPPoint = PetManagementUtils.getNewPropRangeLvChangePotentialPoint(self.petId, newPropId, oldV, newV)

	if needPPoint > self.remainCanAddPointNum then
		return NoticeDef.PET_NEW_PROP_NOT_CAN_ADD
	end

	return self:setSelectedStrenghLv(newPropId, newV)
end

function PetBatchStrengthPointModel:tryDecStrengthLv(newPropId, decLv)
	local oldV = self:getDisplayStrengthLv(newPropId)
	local newV = oldV - decLv

	if newV < 0 then
		return NoticeDef.PET_NEW_PROP_HAS_REACH_MIN
	end

	return self:setSelectedStrenghLv(newPropId, newV)
end

function PetBatchStrengthPointModel:trySliderStrengthLv(newPropId, sliderV)
	local oldV = self:getDisplayStrengthLv(newPropId)
	local needPPoint = PetManagementUtils.getNewPropRangeLvChangePotentialPoint(self.petId, newPropId, oldV, sliderV)

	if needPPoint > self.remainCanAddPointNum then
		return NoticeDef.PET_NEW_PROP_NOT_CAN_ADD
	end

	return self:setSelectedStrenghLv(newPropId, math.max(0, sliderV))
end

function PetBatchStrengthPointModel:setSelectedStrenghLv(newPropId, setLv)
	local maxV = self.batchAddPointData[newPropId].maxStrengthLv

	if maxV < setLv then
		return NoticeDef.PET_NEW_PROP_HAS_REACH_MAX
	end

	local oldV = self:getDisplayStrengthLv(newPropId)
	local changeLv = setLv - oldV

	if changeLv == 0 then
		return NoticeDef.PET_NEW_PROP_WITHOUT_CHANGE
	end

	self.batchAddPointData[newPropId].curSelectedSLv = setLv

	self:syncUpdatePotentialPoint()
end

function PetBatchStrengthPointModel:syncUpdatePotentialPoint()
	local costPoints = 0

	for propId, _ in ipairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		local targetLv = self:getDisplayStrengthLv(propId)
		local changePointNum = PetManagementUtils.getNewPropRangeLvChangePotentialPoint(self.petId, propId, 0, targetLv)

		costPoints = costPoints + changePointNum
	end

	self.usedPotentialPointSum = math.clamp(costPoints, 0, self.potentialPointSum)
	self.remainCanAddPointNum = math.clamp(self.potentialPointSum - self.usedPotentialPointSum, 0, self.potentialPointSum)

	self:syncUpateAllPropCanReachedMaxLv()
end

function PetBatchStrengthPointModel:syncUpateAllPropCanReachedMaxLv()
	for newPropId, _ in pairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		local oldV = self:getDisplayStrengthLv(newPropId)
		local canReachedLv = PetManagementUtils.getNewPropCostPPointCanReachedLv(self.petId, newPropId, oldV, self.remainCanAddPointNum)

		self.batchAddPointData[newPropId].canReachedLv = math.max(canReachedLv, oldV)
	end
end

function PetBatchStrengthPointModel:getCanReachedMaxStrengthLv(newPropId)
	return self.batchAddPointData[newPropId].canReachedLv
end

function PetBatchStrengthPointModel:getBatchAddPreviewAttrs()
	local retAttrs = {}
	local index2AttrIds = {}
	local attrId2Indexes = {}

	for newPropId, v in pairs(self.batchAddPointData) do
		local convertAtomInfos = PetManagementUtils.getPetNewPropUpLvConvertGains(newPropId, v.curSelectedSLv + v.extraStrengthLv or 0)

		for atomAttrId, atomPropInfo in pairs(convertAtomInfos) do
			local atomIndex = attrId2Indexes[atomAttrId]

			if not atomIndex then
				atomIndex = #index2AttrIds + 1
				attrId2Indexes[atomAttrId] = atomIndex
				index2AttrIds[atomIndex] = atomAttrId
				retAttrs[atomIndex] = {
					attrId = atomAttrId,
					value = atomPropInfo.value,
					valueType = atomPropInfo.valueType,
					propl10nName = atomPropInfo.propl10nName
				}
			else
				retAttrs[atomIndex].value = retAttrs[atomIndex].value + atomPropInfo.value
			end
		end
	end

	table.sort(retAttrs, function(a, b)
		return a.attrId < b.attrId
	end)

	return retAttrs
end

return PetBatchStrengthPointModel
