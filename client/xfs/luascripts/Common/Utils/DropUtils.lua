-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\DropUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("DropUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local DropData = require("Data.drop_data")
local DropGroupData = require("Data.drop_group_data")
local DropPackageData = require("Data.drop_package_data")
local DropUtils = {}
local ipairs = ipairs
local pairs = pairs
local math_min = math.min
local math_max = math.max
local math_random = math.random
local unpack = unpack
local BIND_TYPE_LIST = {
	Const.INV_BOUND_TYPE_INSENSITIVE,
	Const.INV_BOUND_TYPE_BOUND,
	Const.INV_BOUND_TYPE_UNBOUND
}
local SUB_GROUP_DROP_MAX_DROP_COUNT = 10
local SUB_GROUP_DROP_MAX_RECURISVE_COUNT = 5

function DropUtils.genDropItemsNumberRange(player, dropId)
	return DropUtils._callDropFunction(player, dropId, DropUtils._genDropItemsNumberRangeFunctions)
end

function DropUtils.genDropItemsNumberInfo(player, dropId, needSplitResult, equipmentBindPetIdMap)
	assert(pg.component == "game", "Random function may be called, use 'genDropItemsNumberRange' instead.")

	return DropUtils._callDropFunction(player, dropId, DropUtils._genDropItemsNumberInfoFunctions, needSplitResult, equipmentBindPetIdMap)
end

function DropUtils.genDropDisplayInfo(dropId, useFixWhenNoConfig)
	if useFixWhenNoConfig == nil then
		useFixWhenNoConfig = true
	end

	local ddd = DropData[dropId]

	if ddd == nil then
		return {}, {}
	end

	local idNumDict, petCreateInfo = {}, {}

	if ddd.displayReward or ddd.displayPetReward then
		if ddd.displayReward then
			ItemUtils.mergeItemInfoResult(idNumDict, ItemUtils.itemList2Dict(ddd.displayReward))
		end

		if ddd.displayPetReward then
			for _, v in ipairs(ddd.displayPetReward) do
				petCreateInfo[#petCreateInfo + 1] = {
					templateId = v[1],
					level = v[2] or 1,
					label = v[3] or 0
				}
			end
		end
	elseif useFixWhenNoConfig then
		if ddd.fixedDrop then
			ItemUtils.mergeItemInfoResult(idNumDict, ItemUtils.itemList2Dict(ddd.fixedDrop))
		end

		if ddd.petDrop then
			for _, v in ipairs(ddd.petDrop) do
				petCreateInfo[#petCreateInfo + 1] = {
					templateId = v[1],
					level = v[2] or 1,
					label = v[3] or 0
				}
			end
		end
	end

	return idNumDict, petCreateInfo
end

function DropUtils.getDropInfo(player, dropId)
	if player == nil or DropData[dropId] == nil then
		logger:error("getDropInfo failed, player is nil or dropId is nil, player=%s, dropId=%s", tostring(player), tostring(dropId))

		return {}
	end

	if pg.component == "game" then
		return DropUtils.genDropItemsNumberInfo(player, dropId)
	else
		return DropUtils.genDropDisplayInfo(dropId, true)
	end
end

function DropUtils.getDropItemsBoundDict(player, dropId)
	local itemRes = DropUtils.getDropInfo(player, dropId)

	return itemRes
end

function DropUtils.getDropItemsCountTable(player, dropId)
	local itemRes = DropUtils.getDropInfo(player, dropId)

	return ItemUtils.getItemCountTable(itemRes)
end

function DropUtils._getRangeInFixedDropFunction(player, v)
	local min, max = v[2], v[2]

	if (v[3] or 1) < 1 then
		min = 0
	end

	return ItemUtils.addItemRangeInfoToRet({}, v[1], min, max)
end

function DropUtils._getRangeInFixedFormulaDropFunction(player, v)
	local min, max = Utils.formulaRange(0, v[2])

	if (v[3] or 1) < 1 then
		min = 0
	end

	return ItemUtils.addItemRangeInfoToRet({}, v[1], min, max)
end

function DropUtils._getRangeInPetDropFunction(player, v)
	return nil, {
		{
			{
				templateId = v[1],
				level = v[2] or 1,
				label = v[3] or 0
			}
		},
		1
	}
end

function DropUtils._genFixedDropRange(player, dropId)
	local ddd = DropData[dropId]

	if ddd == nil then
		return {}, {}
	end

	local itemRangeInfo, maxPetCreateInfo = {}, {}

	if ddd.fixedDrop then
		local oneItemRange = DropUtils._mergeDropRangeForeachByFunction(player, ddd.fixedDrop, DropUtils._getRangeInFixedDropFunction)

		DropUtils._mergeDropRangeResult(itemRangeInfo, nil, oneItemRange, nil)
	end

	if ddd.fixedFormulaDrop then
		local oneItemRange = DropUtils._mergeDropRangeForeachByFunction(player, ddd.fixedFormulaDrop, DropUtils._getRangeInFixedFormulaDropFunction)

		DropUtils._mergeDropRangeResult(itemRangeInfo, nil, oneItemRange, nil)
	end

	if ddd.petDrop then
		local _, oneMaxPetCreate = DropUtils._mergeDropRangeForeachByFunction(player, ddd.petDrop, DropUtils._getRangeInPetDropFunction)

		DropUtils._mergeDropRangeResult(nil, maxPetCreateInfo, nil, oneMaxPetCreate)
	end

	return itemRangeInfo, maxPetCreateInfo
end

local function getGroupSingleItemRangeInfo(player, v)
	local minNum, maxNum = v.dropMinNum or 0, v.dropMaxNum or 0

	if v.formulaNum then
		local min, max = Utils.formulaRange(0, v.formulaNum)

		minNum = minNum + min
		maxNum = maxNum + max
	end

	return minNum, maxNum
end

local function getGroupSingleMaxPetCreateInfo(player, v)
	if not v.petId then
		return nil
	end

	return {
		templateId = v.petId,
		level = v.dropMaxGrade or 1,
		label = v.petLabel or 0,
		setRollGroup = v.setRollGroup,
		shinyStyle = Utils.randomPetShinyStyle(v.shinyStyleRandomGroup or 1, v.petLabel or 0, nil)
	}
end

function DropUtils._getRangeInGroupDropFunction(player, groupId)
	local groupData = DropGroupData[groupId]

	if groupData == nil then
		return {}, {}
	end

	local itemRangeInfo, maxPetCreateInfo = {}, {}
	local extractMode = groupData[1] and groupData[1].extractMode

	if extractMode == Const.EXTRACT_MODE_PROBABILITY then
		local groupMaxPetCreate = {}

		for _, v in ipairs(groupData) do
			local itemCondition = v and v.itemConditions or nil

			if (itemCondition == nil or player.triggerMap:isCompleteOrMeetCondition(itemCondition)) and v.dropRatio > 0 then
				if v.itemId ~= nil then
					local minNum, maxNum = getGroupSingleItemRangeInfo(player, v)

					ItemUtils.addItemRangeInfoToRet(itemRangeInfo, v.itemId, minNum, maxNum, Const.INV_BOUND_TYPE_INSENSITIVE)
				end

				local groupSinglePetCreate = getGroupSingleMaxPetCreateInfo(player, v)

				lume.push(groupMaxPetCreate, groupSinglePetCreate)
			end
		end

		DropUtils._mergeDropRangeResult(nil, maxPetCreateInfo, nil, {
			groupMaxPetCreate,
			#groupMaxPetCreate
		})
	else
		local proportionList = Utils.getProportionList(extractMode, groupData, function(v)
			return v.dropRatio
		end)
		local groupMaxPetCreate = {}

		for index, ratio in pairs(proportionList or EMPTY_TABLE) do
			if ratio > 0 and groupData[index] ~= nil then
				local v = groupData[index]
				local minNum, maxNum = getGroupSingleItemRangeInfo(player, v)

				ItemUtils.addItemRangeInfoToRet(itemRangeInfo, v.itemId, minNum, maxNum, Const.INV_BOUND_TYPE_INSENSITIVE, true)

				local groupSinglePetCreate = getGroupSingleMaxPetCreateInfo(player, v)

				lume.push(groupMaxPetCreate, groupSinglePetCreate)
			end
		end

		DropUtils._mergeDropRangeResult(nil, maxPetCreateInfo, nil, {
			groupMaxPetCreate,
			math_min(#groupMaxPetCreate, 1)
		}, true)
	end

	return itemRangeInfo, maxPetCreateInfo
end

function DropUtils._genGroupDropRange(player, dropId)
	local ddd = DropData[dropId]

	if ddd == nil or ddd.dropParam == nil then
		return {}, {}
	end

	return DropUtils._mergeDropRangeForeachByFunction(player, ddd.dropParam, DropUtils._getRangeInGroupDropFunction)
end

function DropUtils._getRangeInPackageDropFunction(player, dropBagId)
	local dpdd = DropPackageData[dropBagId]

	if dpdd == nil then
		return {}, {}
	end

	local itemRangeInfo, maxPetCreateInfo = {}, {}
	local subPackageData = DropUtils._selectSubPackage(player, dropBagId)

	if subPackageData == nil then
		return {}, {}
	end

	local groupRatioList = subPackageData.groups
	local extractMode = subPackageData.extractMode

	if extractMode == Const.EXTRACT_MODE_PROBABILITY then
		for _, v in ipairs(groupRatioList) do
			if v[2] > 0 then
				local oneItemRange, oneMaxPetCreate = DropUtils._getRangeInGroupDropFunction(player, v[1])

				DropUtils._mergeDropRangeResult(itemRangeInfo, maxPetCreateInfo, oneItemRange, oneMaxPetCreate)
			end
		end
	else
		local proportionList = Utils.getProportionList(extractMode, groupRatioList, function(v)
			return v[2]
		end)

		for index, ratio in pairs(proportionList or EMPTY_TABLE) do
			if ratio > 0 and groupRatioList[index] ~= nil then
				local v = groupRatioList[index]
				local oneItemRange, oneMaxPetCreate = DropUtils._getRangeInGroupDropFunction(player, v[1])

				DropUtils._mergeDropRangeResult(itemRangeInfo, maxPetCreateInfo, oneItemRange, oneMaxPetCreate, true)
			end
		end
	end

	return itemRangeInfo, maxPetCreateInfo
end

function DropUtils._genPackageDropRange(player, dropId)
	local ddd = DropData[dropId]

	if ddd == nil or ddd.dropParam == nil then
		return {}, {}
	end

	return DropUtils._mergeDropRangeForeachByFunction(player, ddd.dropParam, DropUtils._getRangeInPackageDropFunction)
end

DropUtils._genDropItemsNumberRangeFunctions = {
	[ItemConst.DROP_TYPE_FIXED] = DropUtils._genFixedDropRange,
	[ItemConst.DROP_TYPE_GROUP] = DropUtils._genGroupDropRange,
	[ItemConst.DROP_TYPE_PACKAGE] = DropUtils._genPackageDropRange
}

function DropUtils._mergeDropRangeForeachByFunction(player, foreachList, foreachFunction, ...)
	local itemRangeInfo, maxPetCreateInfo = {}, {}

	for _, v in pairs(foreachList) do
		local oneItemRange, oneMaxPetCreate = foreachFunction(player, v, ...)

		DropUtils._mergeDropRangeResult(itemRangeInfo, maxPetCreateInfo, oneItemRange, oneMaxPetCreate)
	end

	return itemRangeInfo, maxPetCreateInfo
end

function DropUtils._mergeDropRangeResult(targetResult, targetMaxPetCreateInfo, result, maxPetCreateInfo, isMerge)
	if not targetResult and result or not targetMaxPetCreateInfo and maxPetCreateInfo then
		logger:error("DropUtils._mergeDropRangeResult failed, targetResult=%s, targetMaxPetCreateInfo=%s, result=%s, maxPetCreateInfo=%s", tostring(targetResult), tostring(targetMaxPetCreateInfo), tostring(result), tostring(maxPetCreateInfo))
	end

	if targetResult and result then
		for itemId, rangeInfo in pairs(result or EMPTY_TABLE) do
			for _, bindType in ipairs(BIND_TYPE_LIST) do
				local range = rangeInfo[bindType]

				if range ~= nil then
					ItemUtils.addItemRangeInfoToRet(targetResult, itemId, range[1], range[2], bindType, isMerge)
				end
			end
		end
	end

	if targetMaxPetCreateInfo and maxPetCreateInfo then
		targetMaxPetCreateInfo[1] = targetMaxPetCreateInfo[1] or {}

		local targetMaxCount = targetMaxPetCreateInfo[2] or 0
		local srcCreateInfo = maxPetCreateInfo[1]
		local srcMaxCount = maxPetCreateInfo[2] or 0

		if srcCreateInfo then
			lume.append(targetMaxPetCreateInfo[1], srcCreateInfo)
		end

		targetMaxPetCreateInfo[2] = isMerge and math_max(targetMaxCount, srcMaxCount) or targetMaxCount + srcMaxCount
	end
end

function DropUtils._genFixedDrop(player, dropId, needSplitResult)
	local ret, retPet = {}, {}
	local ddd = DropData[dropId]

	if ddd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("config nil", dropId, needSplitResult, player:repr())
		end

		return ret, retPet
	end

	local bound = Const.INV_BOUND_TYPE_INSENSITIVE

	for _, v in ipairs(DropData[dropId].fixedDrop or EMPTY_TABLE) do
		local itemId = v[1]
		local number = v[2]
		local weight = v[3] or 1

		if weight > math_random() then
			if needSplitResult then
				local temp = {}

				ItemUtils.addItemInfoToRet(temp, itemId, number, bound)
				lume.push(ret, temp)
			else
				ItemUtils.addItemInfoToRet(ret, itemId, number, bound)
			end
		end
	end

	for _, v in ipairs(DropData[dropId].fixedFormulaDrop or EMPTY_TABLE) do
		local itemId = v[1]
		local formulaId = v[2]
		local weight = v[3] or 0

		if weight > math_random() then
			local number = Utils.formulaSafeCall(0, formulaId, player.designerInterface:getDif())

			if needSplitResult then
				local temp = {}

				ItemUtils.addItemInfoToRet(temp, itemId, number, bound)
				lume.push(ret, temp)
			else
				ItemUtils.addItemInfoToRet(ret, itemId, number, bound)
			end
		end
	end

	for _, v in ipairs(DropData[dropId].petDrop or EMPTY_TABLE) do
		local templateId = v[1]
		local level = v[2] or 1
		local label = v[3] or 0
		local weight = v[4] or 0

		if weight > math_random() then
			retPet[#retPet + 1] = {
				templateId = templateId,
				level = level,
				label = label,
				shinyStyle = Utils.randomPetShinyStyle(v[5] or 1, label, nil)
			}
		end
	end

	return ret, retPet
end

function DropUtils.setEquipmentBindPetId(result, groupItemData, itemId)
	local equipmentBindPetId = groupItemData.equipmentBindPetId

	if result and equipmentBindPetId and equipmentBindPetId ~= 0 and itemId then
		result[itemId] = equipmentBindPetId
	end
end

function DropUtils._genSingleGroupDrop(player, groupId, needSplitResult, pathInfo, itemNum)
	local groupData = DropGroupData[groupId]

	if groupData == nil then
		ALARM("config nil: %s", groupId)

		return {}, {}
	end

	if groupData[1] == nil then
		ALARM("config nil: %s", groupId)

		return {}, {}
	end

	pathInfo.groupId = groupId

	local extractMode = groupData[1].extractMode
	local bound = Const.INV_BOUND_TYPE_INSENSITIVE
	local ret, retPet = {}, {}

	if extractMode == Const.EXTRACT_MODE_PROBABILITY then
		for _, v in ipairs(groupData) do
			local itemCondition = v and v.itemConditions or nil

			if itemCondition == nil or player.triggerMap:isCompleteOrMeetCondition(itemCondition) then
				local ratio = v.dropRatio

				if ratio > math_random() then
					local itemId = v.itemId

					if v.itemId then
						local number = 0

						if itemNum ~= nil then
							number = itemNum
						elseif v.formulaNum then
							number = Utils.formulaSafeCall(0, v.formulaNum, player.designerInterface:getDif())
						else
							local lowerBound = v.dropMinNum or 0
							local upperBound = v.dropMaxNum or 0

							number = math_random(lowerBound, upperBound)
						end

						if number > 0 then
							DropUtils.setEquipmentBindPetId(pathInfo.equipmentBindPetIdMap, v, itemId)

							if needSplitResult then
								local temp = {}

								ItemUtils.addItemInfoToRet(temp, itemId, number, bound)
								lume.push(ret, temp)
							else
								ItemUtils.addItemInfoToRet(ret, itemId, number, bound)
							end
						end
					end

					if v.petId then
						retPet[#retPet + 1] = {
							templateId = v.petId,
							level = math_random(v.dropMinGrade or 1, v.dropMaxGrade or 1),
							label = v.petLabel or 0,
							setRollGroup = v.setRollGroup,
							shinyStyle = Utils.randomPetShinyStyle(v.shinyStyleRandomGroup or 1, v.petLabel or 0, nil)
						}
					end

					if v.rewardGroupID then
						local lowerBound = v.groupDropMinNum or 0
						local upperBound = v.groupDropMaxNum or 0
						local realNum = math_random(lowerBound, upperBound)

						if realNum > SUB_GROUP_DROP_MAX_DROP_COUNT then
							ALARM("rewardGroupID realNum too large: %s, dropId=%s, groupId=%s, path=%s", realNum, pathInfo.dropId, groupId, inspect(pathInfo))

							realNum = SUB_GROUP_DROP_MAX_DROP_COUNT
						end

						pathInfo.rewardGroupIDs = pathInfo.rewardGroupIDs or {}

						if #pathInfo.rewardGroupIDs >= SUB_GROUP_DROP_MAX_RECURISVE_COUNT then
							ALARM("rewardGroupID recurrence too many: %s, dropId=%s, groupId=%s, path=%s", #pathInfo.rewardGroupIDs, pathInfo.dropId, groupId, inspect(pathInfo))

							return ret, retPet
						end

						lume.push(pathInfo.rewardGroupIDs, v.rewardGroupID)

						for i = 1, realNum do
							local gRet, gRetPet = DropUtils._genSingleGroupDrop(player, v.rewardGroupID, needSplitResult, pathInfo)

							if needSplitResult then
								lume.push(ret, unpack(gRet))
							else
								ItemUtils.mergeItemInfoResult(ret, gRet)
							end

							if #gRetPet > 0 then
								lume.append(retPet, gRetPet)
							end
						end
					end
				end
			end
		end
	else
		local proportionList = Utils.getProportionList(extractMode, groupData, function(v)
			return v.dropRatio
		end)
		local selectedIndex = lume.weightedchoice(proportionList)
		local selectedData = groupData[selectedIndex]

		if selectedData == nil then
			return {}, {}
		end

		local itemId = selectedData.itemId

		if itemId then
			local number = 0

			if itemNum ~= nil then
				number = itemNum
			elseif selectedData.formulaNum then
				number = Utils.formulaSafeCall(0, selectedData.formulaNum, player.designerInterface:getDif())
			else
				local lowerBound = selectedData.dropMinNum or 0
				local upperBound = selectedData.dropMaxNum or 0

				number = math_random(lowerBound, upperBound)
			end

			if number > 0 then
				DropUtils.setEquipmentBindPetId(pathInfo.equipmentBindPetIdMap, selectedData, itemId)

				if needSplitResult then
					local temp = {}

					ItemUtils.addItemInfoToRet(temp, itemId, number, bound)
					lume.push(ret, temp)
				else
					ItemUtils.addItemInfoToRet(ret, itemId, number, bound)
				end
			end
		end

		if selectedData.petId then
			retPet[#retPet + 1] = {
				templateId = selectedData.petId,
				level = math_random(selectedData.dropMinGrade or 1, selectedData.dropMaxGrade or 1),
				label = selectedData.petLabel or 0,
				setRollGroup = selectedData.setRollGroup,
				shinyStyle = Utils.randomPetShinyStyle(selectedData.shinyStyleRandomGroup or 1, selectedData.petLabel or 0, nil)
			}
		end

		if selectedData.rewardGroupID then
			local lowerBound = selectedData.groupDropMinNum or 0
			local upperBound = selectedData.groupDropMaxNum or 0
			local realNum = math_random(lowerBound, upperBound)

			if realNum > SUB_GROUP_DROP_MAX_DROP_COUNT then
				ALARM("rewardGroupID realNum too large: %s, dropId=%s, groupId=%s, path=%s", realNum, pathInfo.dropId, groupId, inspect(pathInfo))

				realNum = SUB_GROUP_DROP_MAX_DROP_COUNT
			end

			pathInfo.rewardGroupIDs = pathInfo.rewardGroupIDs or {}

			if #pathInfo.rewardGroupIDs >= SUB_GROUP_DROP_MAX_RECURISVE_COUNT then
				ALARM("rewardGroupID recurrence too many: %s, dropId=%s, groupId=%s, path=%s", #pathInfo.rewardGroupIDs, pathInfo.dropId, groupId, inspect(pathInfo))

				return ret, retPet
			end

			lume.push(pathInfo.rewardGroupIDs, selectedData.rewardGroupID)

			for i = 1, realNum do
				local gRet, gRetPet = DropUtils._genSingleGroupDrop(player, selectedData.rewardGroupID, needSplitResult, pathInfo)

				if needSplitResult then
					lume.push(ret, unpack(gRet))
				else
					ItemUtils.mergeItemInfoResult(ret, gRet)
				end

				if #gRetPet > 0 then
					lume.append(retPet, gRetPet)
				end
			end
		end
	end

	return ret, retPet
end

function DropUtils._genGroupDrop(player, dropId, needSplitResult, equipmentBindPetIdMap)
	local ret, retPet = {}, {}
	local ddd = DropData[dropId]

	if ddd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("config nil", dropId, needSplitResult, player:repr())
		end

		return ret, retPet
	end

	local groupIds = ddd.dropParam

	for _, groupId in ipairs(groupIds) do
		local singleGroupRet, singleGroupRetPet = DropUtils._genSingleGroupDrop(player, groupId, needSplitResult, {
			dropId = dropId,
			equipmentBindPetIdMap = equipmentBindPetIdMap
		})

		if needSplitResult then
			lume.push(ret, unpack(singleGroupRet))
		else
			ItemUtils.mergeItemInfoResult(ret, singleGroupRet)
		end

		lume.append(retPet, singleGroupRetPet)
	end

	return ret, retPet
end

function DropUtils.genGroupDropByGroupIds(player, dropId, groupIds, needSplitResult, retItem, retPet, equipmentBindPetIdMap)
	for _, groupId in ipairs(groupIds) do
		local singleGroupRet, singleGroupRetPet = DropUtils._genSingleGroupDrop(player, groupId, needSplitResult, {
			dropId = dropId,
			equipmentBindPetIdMap = equipmentBindPetIdMap
		})

		if needSplitResult then
			lume.push(retItem, unpack(singleGroupRet))
		else
			ItemUtils.mergeItemInfoResult(retItem, singleGroupRet)
		end

		if #singleGroupRetPet > 0 then
			lume.append(retPet, singleGroupRetPet)
		end
	end
end

local function getLv(player, lvType)
	lvType = lvType or ItemConst.LEVEL_TYPE_BASE

	if lvType == ItemConst.LEVEL_TYPE_BASE then
		return player.level
	elseif lvType == ItemConst.LEVEL_TYPE_TITLE then
		return player.starTitle
	else
		logger:error("getLv failed, lvType=%s", lvType)

		return 0
	end
end

function DropUtils._selectSubPackage(player, dropBagId)
	for _, subData in ipairs(DropPackageData[dropBagId]) do
		local level = getLv(player, subData.lvType)

		if level >= subData.lvLowLimit and level <= subData.lvHighLimit then
			return subData
		end
	end

	return nil
end

function DropUtils._genSinglePackageDrop(player, dropBagId, needSplitResult, pathInfo)
	local dpdd = DropPackageData[dropBagId]

	if dpdd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("config nil", dropBagId, needSplitResult, player:repr())
		end

		return {}, {}
	end

	local subPackageData = DropUtils._selectSubPackage(player, dropBagId)

	if subPackageData == nil then
		return {}, {}
	end

	local groupRatioList = subPackageData.groups
	local extractMode = subPackageData.extractMode

	if extractMode == Const.EXTRACT_MODE_PROBABILITY then
		local ret, retPet = {}, {}

		for _, v in ipairs(groupRatioList) do
			local groupId, ratio = unpack(v)

			pathInfo.groupId = groupId

			if ratio > math_random() then
				pathInfo.subPackageId = subPackageData.subDropBagId

				local singleGroupRet, singleGroupRetPet = DropUtils._genSingleGroupDrop(player, groupId, needSplitResult, pathInfo)

				if needSplitResult then
					lume.push(ret, unpack(singleGroupRet))
				else
					ItemUtils.mergeItemInfoResult(ret, singleGroupRet)
				end

				lume.append(retPet, singleGroupRetPet)
			end
		end

		return ret, retPet
	else
		local proportionList = Utils.getProportionList(extractMode, groupRatioList, function(v)
			pathInfo.groupId = v[1]

			return v[2]
		end)
		local selectedIndex = lume.weightedchoice(proportionList)
		local selectedGroup = groupRatioList[selectedIndex]

		if selectedGroup == nil then
			return {}, {}
		end

		local groupId = selectedGroup[1]

		pathInfo.subPackageId = subPackageData.subDropBagId

		return DropUtils._genSingleGroupDrop(player, groupId, needSplitResult, pathInfo)
	end
end

function DropUtils._genPackageDrop(player, dropId, needSplitResult, equipmentBindPetIdMap)
	local ret, retPet = {}, {}
	local ddd = DropData[dropId]

	if ddd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("config nil", dropId, needSplitResult, player:repr())
		end

		return ret, retPet
	end

	local dropBagIds = ddd.dropParam

	for _, dropBagId in ipairs(dropBagIds) do
		local singlePackageRet, singlePackageRetPet = DropUtils._genSinglePackageDrop(player, dropBagId, needSplitResult, {
			dropId = dropId,
			packageId = dropBagId,
			equipmentBindPetIdMap = equipmentBindPetIdMap
		})

		if needSplitResult then
			lume.push(ret, unpack(singlePackageRet))
		else
			ItemUtils.mergeItemInfoResult(ret, singlePackageRet)
		end

		lume.append(retPet, singlePackageRetPet)
	end

	return ret, retPet
end

DropUtils._genDropItemsNumberInfoFunctions = {
	[ItemConst.DROP_TYPE_FIXED] = DropUtils._genFixedDrop,
	[ItemConst.DROP_TYPE_GROUP] = DropUtils._genGroupDrop,
	[ItemConst.DROP_TYPE_PACKAGE] = DropUtils._genPackageDrop
}

function DropUtils._callDropFunction(player, dropId, functionTable, ...)
	local ddd = DropData[dropId]

	if ddd == nil then
		ALARM("config nil: %s", dropId)

		return {}
	end

	local dropType = ddd.dropType

	if dropType == nil or functionTable[dropType] == nil then
		ALARM("no function: %s, %s", dropId, dropType)

		return {}
	end

	return functionTable[dropType](player, dropId, ...)
end

return DropUtils
