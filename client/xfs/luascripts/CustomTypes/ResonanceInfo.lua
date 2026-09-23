-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ResonanceInfo.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ResonanceData = require("Data.pet_resonance_data")
local PetFamilyData = require("Data.pet_family_data")
local PetConfigData = require("Data.pet_config_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local ObjHelper = require("Common.ObjHelper")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local ElementPropData = require("Data.element_prop_data")
local ResonanceInfo = class.LiteClass("ResonanceInfo", CustomDict)

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PET_INFO
	}

	function ResonanceInfo:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function ResonanceInfo:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		return obj
	end
end

function ResonanceInfo:getUpgradeResonanceData()
	local stage = self.resonanceStage
	local level = self.resonanceLevel
	local stageData = ResonanceData[stage]

	if stageData == nil then
		return
	end

	if stageData[level + 1] == nil then
		stage = stage + 1
		level = 0

		if ResonanceData[stage] == nil or ResonanceData[stage][level] == nil then
			return
		end

		stageData = ResonanceData[stage]
	else
		level = level + 1
	end

	return stageData[level], stage, level
end

function ResonanceInfo:canUpgradeResonance(petInfo, data, checkRet, player)
	checkRet = checkRet or {}

	if data == nil then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.PARAMS_ERROR

		return false
	end

	if data.needLv and data.needLv > petInfo.level then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_LEVEL
		checkRet.params = {
			needLv = data.needLv,
			curLv = petInfo.level
		}

		return false
	end

	if not self:isHaveJewelry(data.needApparence, petInfo) then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ORIENTATION
		checkRet.params = {
			jewelryId = self:getFamilyEnhanceJewelryId(petInfo)
		}

		return false
	end

	player = player or petInfo:getOwnerPlayer()

	if data.condition == 1 and player then
		local familyData = PetFamilyData[petInfo:getConfigData().ethnicGroup or 0]

		if familyData and familyData.enhanceCondition ~= nil and not player.triggerMap:isCompleteOrMeetCondition(familyData.enhanceCondition) then
			checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_FAMILY_CONDITION
			checkRet.params = {
				enhanceConditionId = familyData.enhanceCondition
			}

			return false
		end
	end

	local nextData, toStage, toLevel = self:getUpgradeResonanceData()

	if not nextData then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.PARAMS_ERROR

		return false
	end

	local isExtraItemEnough, deficitExtraItemId = self:isHaveExtraItem(nextData.extraItems, petInfo, player)

	if not isExtraItemEnough then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ITEM
		checkRet.params = {
			itemId = deficitExtraItemId
		}

		return false
	end

	local buildSuccess, itemDict, deficitItemId = self:buildResonanceItemDict(petInfo, toStage, toLevel, player)

	if not buildSuccess then
		checkRet.code = Const.UPGRADE_CHECK_FAIL_CODE.NOT_ENOUGH_ITEM
		checkRet.params = {
			itemId = deficitItemId
		}

		return false
	end

	return true, itemDict
end

function ResonanceInfo:isHaveJewelry(needApparence, petInfo)
	if needApparence ~= 1 then
		return true
	end

	local familyData = PetFamilyData[petInfo:getConfigData().ethnicGroup or 0]

	if not familyData then
		return true
	end

	local jewelryId = familyData.enhanceClothes

	if not jewelryId then
		return true
	end

	local player = petInfo:getOwnerPlayer()

	if player == nil then
		return false
	end

	local petJewelrys = player.petJewelryInfos[petInfo.id]

	if petJewelrys == nil then
		return false
	end

	for _, jewelry in pairs(petJewelrys) do
		if jewelry.configId == jewelryId then
			return true
		end
	end

	return false
end

function ResonanceInfo:getFamilyEnhanceJewelryId(petInfo)
	if not petInfo then
		return
	end

	local familyData = PetFamilyData[petInfo:getConfigData().ethnicGroup or 0]

	if not familyData then
		return
	end

	local jewelryId = familyData.enhanceClothes

	return jewelryId
end

function ResonanceInfo:isHaveFamilyItem(itemNum, petInfo)
	local reqList = Utils.getPetResonanceFamilyItemDIct(petInfo:getConfigData().ethnicGroup or 0, itemNum)

	if #reqList == 0 then
		return true
	end

	local isEnough, _, deficitMainId = Utils.allocPetResonanceFamilyConsume(reqList, petInfo:getOwnerPlayer())

	return isEnough, deficitMainId
end

function ResonanceInfo:isHaveExtraItem(extraItems, petInfo, player)
	player = player or petInfo:getOwnerPlayer()

	if player == nil then
		return false
	end

	for _, item in pairs(extraItems or EMPTY_TABLE) do
		local sum = ItemUtils.getItemCountById(player, item[1])

		if sum < item[2] then
			return false, item[1]
		end
	end

	return true
end

function ResonanceInfo:buildResonanceItemDict(petInfo, toStage, toLevel, player)
	player = player or petInfo:getOwnerPlayer()

	local fromStage = self.resonanceStage
	local fromLevel = self.resonanceLevel
	local basicDict = Utils.calcPetResonanceCost(petInfo, toStage, toLevel, fromStage, fromLevel)
	local itemDict = {}
	local ethnicGroup = petInfo:getConfigData().ethnicGroup or 0
	local mainElementTypeId = petInfo:getConfigData().mainElementType
	local mainElementTypeInfo = ElementPropData[mainElementTypeId] or {}
	local mainElementType = mainElementTypeInfo and mainElementTypeInfo.name or "None"

	for itemId, count in pairs(basicDict) do
		itemDict[itemId] = count
	end

	for stage = fromStage, toStage do
		local stageData = ResonanceData[stage]

		if stageData then
			local beginLevel = stage == fromStage and fromLevel or 0
			local endLevel = stage == toStage and toLevel or lume.tableLength(stageData)

			for level = beginLevel, endLevel do
				local levelData = stageData[level]

				if not levelData then
					break
				end

				if stage ~= fromStage or level ~= fromLevel then
					if levelData.itemNum then
						for _, req in ipairs(Utils.getPetResonanceFamilyItemDIct(ethnicGroup, levelData.itemNum)) do
							itemDict[req[1]] = nil
						end

						local reqList = Utils.getPetResonanceFamilyItemDIct(ethnicGroup, levelData.itemNum)
						local result, familyDict, deficitId = Utils.allocPetResonanceFamilyConsume(reqList, player)

						if not result then
							return false, nil, deficitId
						end

						for itemId, count in pairs(familyDict or EMPTY_TABLE) do
							itemDict[itemId] = (itemDict[itemId] or 0) + count
						end
					end

					local elementItemNum = levelData.elementItemNum

					if elementItemNum and elementItemNum > 0 then
						if not mainElementType then
							if player and player.logger then
								player.logger:error("ResonanceInfo:buildResonanceItemDict elementItemNum > 0 but no mainElementType, petId=%s, uid=%s", petInfo.id, player.uid)
							end

							return false, nil, nil
						end

						if not PetConfigData.petElementItemId then
							if player and player.logger then
								player.logger:error("ResonanceInfo:buildResonanceItemDict PetConfigData.petElementItemId not exist, uid=%s", player.uid)
							end

							return false, nil, nil
						end

						local elementItemId = PetConfigData.petElementItemId[mainElementType]

						if not elementItemId then
							if player and player.logger then
								player.logger:error("ResonanceInfo:buildResonanceItemDict elementType no corresponding elementItemId, elementType=%s, uid=%s", mainElementType, player.uid)
							end

							return false, nil, nil
						end

						itemDict[elementItemId] = nil

						local hasCount = ItemUtils.getItemCountById(player, elementItemId)

						if elementItemNum <= hasCount then
							itemDict[elementItemId] = elementItemNum
						else
							local backupItemId = PetConfigData.petElementItemIdBackup and PetConfigData.petElementItemIdBackup[mainElementType]

							if backupItemId then
								local backupHasCount = ItemUtils.getItemCountById(player, backupItemId)
								local needBackup = elementItemNum - hasCount

								if needBackup <= backupHasCount then
									if hasCount > 0 then
										itemDict[elementItemId] = hasCount
									end

									itemDict[backupItemId] = (itemDict[backupItemId] or 0) + needBackup
								else
									return false, nil, elementItemId
								end
							else
								return false, nil, elementItemId
							end
						end
					end
				end
			end
		end
	end

	return true, itemDict
end

return ResonanceInfo
