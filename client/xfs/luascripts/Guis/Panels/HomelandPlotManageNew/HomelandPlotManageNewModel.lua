-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlotManageNew\\HomelandPlotManageNewModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlotManageNewModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandPlotManageNewModel = Class.LightClass("HomelandPlotManageNewModel", UIModel)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local AddressDataConst = require("Const.AddressDataConst")
local CommonSwitch = require("Common.CommonSwitch")
local DropData = require("Data.drop_data")
local HomeObjectData = require("Data.home_object_data")
local RevertHomeUpgradeData = require("Data.revert_home_upgrade_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFormulaPeriodData = require("Data.homeland_formula_period_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandUpgradeData = require("Data.home_upgrade_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")

HomelandPlotManageNewModel.ENABLEUNLOCK_TYPE = {
	Unlocked = 0,
	CannotUnlock = 2,
	Unlockable = 1
}
HomelandPlotManageNewModel.UNIT_LENGTH = 180
HomelandPlotManageNewModel.ZONE_WIDTH = 20
HomelandPlotManageNewModel.ZONE_HEIGHT = 15
HomelandPlotManageNewModel.GRID_COLUMN_COUNT = CommonSwitch.HOMELAND_NEW_MAP and 4 or 5
HomelandPlotManageNewModel.GRID_LINE_COUNT = CommonSwitch.HOMELAND_NEW_MAP and 4 or 5

function HomelandPlotManageNewModel:getPlotList(areaId)
	local plotList = {}
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()

	for zoneId, info in pairs(HomelandZoneUnlockConfigData) do
		if (info.areaId or 0) == areaId and info.prefabPos then
			local enableUnlock = HomelandPlotManageNewModel.ENABLEUNLOCK_TYPE.CannotUnlock

			if info.unlockCondition and pg.me.triggerMap:isCompleteOrMeetCondition(info.unlockCondition) then
				enableUnlock = HomelandPlotManageNewModel.ENABLEUNLOCK_TYPE.Unlockable
			end

			if pg.game.home:isHomelandZoneUnlock(zoneId) then
				enableUnlock = HomelandPlotManageNewModel.ENABLEUNLOCK_TYPE.Unlocked
			end

			local line, row = self:getZoneGridPosition(info, areaId)

			table.insert(plotList, {
				level = zoneId,
				line = line,
				row = row,
				enableUnlock = enableUnlock
			})
		end
	end

	table.sort(plotList, function(a, b)
		if a.line == b.line then
			return a.row < b.row
		else
			return a.line < b.line
		end
	end)

	return plotList
end

function HomelandPlotManageNewModel:getZoneIndexByLevel(level, areaId)
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local info = HomelandZoneUnlockConfigData[level]

	if info and info.prefabPos and (info.areaId or 0) == areaId then
		local line, row = self:getZoneGridPosition(info, areaId)

		return (line - 1) * HomelandPlotManageNewModel.GRID_COLUMN_COUNT + row - 1
	end
end

function HomelandPlotManageNewModel:getDefaultZoneIndex(areaId)
	local zoneUnlockData = HomeLandUtils.getHomelandZoneUnlockData()
	local defaultZoneId

	for zoneId, info in pairs(zoneUnlockData) do
		if (info.areaId or Const.HOMELAND_AREA_TYPE.PRODUCE) == areaId and info.isUnlock == 1 and (not defaultZoneId or zoneId < defaultZoneId) then
			defaultZoneId = zoneId
		end
	end

	if defaultZoneId then
		return self:getZoneIndexByLevel(defaultZoneId, areaId)
	end
end

function HomelandPlotManageNewModel:getZoneIndexByPos(x, y, areaId)
	local zoneWidth = HomelandPlotManageNewModel.ZONE_WIDTH
	local zoneHeight = HomelandPlotManageNewModel.ZONE_HEIGHT
	local columnCount = HomelandPlotManageNewModel.GRID_COLUMN_COUNT
	local lineCount = HomelandPlotManageNewModel.GRID_LINE_COUNT
	local halfWidth = columnCount * zoneWidth * 0.5
	local halfHeight = lineCount * zoneHeight * 0.5

	if x < -halfWidth or halfWidth < x or y < -halfHeight or halfHeight < y then
		return self:getDefaultZoneIndex(areaId)
	end

	local row = math.min(math.floor((x + halfWidth) / zoneWidth) + 1, columnCount)
	local line = math.min(math.floor((halfHeight - y) / zoneHeight) + 1, lineCount)

	line, row = self:getDisplayZoneGridPosition(line, row, areaId)

	return (line - 1) * columnCount + row - 1
end

function HomelandPlotManageNewModel:getDisplayZoneGridPosition(line, row, areaId)
	if areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		line = HomelandPlotManageNewModel.GRID_LINE_COUNT + 1 - line
		row = HomelandPlotManageNewModel.GRID_COLUMN_COUNT + 1 - row
	end

	return line, row
end

function HomelandPlotManageNewModel:getZoneGridPosition(info, areaId)
	local lineCenter = (HomelandPlotManageNewModel.GRID_LINE_COUNT + 1) * 0.5
	local rowCenter = (HomelandPlotManageNewModel.GRID_COLUMN_COUNT + 1) * 0.5
	local line = lineCenter - info.prefabPos[2] / HomelandPlotManageNewModel.ZONE_HEIGHT
	local row = rowCenter + info.prefabPos[1] / HomelandPlotManageNewModel.ZONE_WIDTH

	return self:getDisplayZoneGridPosition(line, row, areaId)
end

function HomelandPlotManageNewModel:getRewardData(zoneId)
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local datas = {}
	local rewardId = HomelandZoneUnlockConfigData[zoneId].rewardId

	if rewardId then
		local dropData = DropData[rewardId]

		if dropData then
			for _, reward in pairs(dropData.displayReward) do
				local data = {}

				data.id = reward[1]
				data.num = reward[2]

				table.insert(datas, data)
			end
		end
	end

	return datas
end

function HomelandPlotManageNewModel:getOrnamentInfos(areaId)
	local ornamentTable = {}

	for ornamentId, ornamentInfo in pairs(pg.me.space.ornament) do
		local config = HomeObjectData[ornamentInfo.homeId]
		local ornamentAreaId = ornamentInfo.areaId or 0

		if ornamentAreaId == areaId and config and config.type == 1 and (not ornamentInfo.trashId or ornamentInfo.trashId == 0) then
			local rotY = ornamentInfo.rotY
			local rotation = Utils.yawAngleIntToQuaternion(rotY)
			local isRotate = Utils.checkRotationIsVertical(rotation)
			local posX, posZ = ornamentInfo.posX, ornamentInfo.posZ
			local pos = {
				x = posX * 0.01 * HomelandPlotManageNewModel.UNIT_LENGTH,
				y = posZ * 0.01 * HomelandPlotManageNewModel.UNIT_LENGTH
			}
			local revertInfo = RevertHomeUpgradeData[ornamentInfo.homeId]
			local facilityLevel = revertInfo and revertInfo[2] or 1
			local iconId = config.plotIconId or AddressDataConst.UI_HOME_PLOT_NORMAL_ICON

			ornamentTable[ornamentId] = {
				ornamentId = ornamentId,
				homeId = ornamentInfo.homeId,
				electricMode = ornamentInfo.electricMode,
				pos = pos,
				isRotate = isRotate,
				level = facilityLevel,
				iconId = iconId,
				ornamentType = config.subType
			}
		end
	end

	return ornamentTable
end

function HomelandPlotManageNewModel:getOrnamentSize(homeId, isRotate)
	local config = HomeObjectData[homeId]

	if config and config.boundSize then
		if isRotate then
			return config.boundSize[2], config.boundSize[1]
		end

		return config.boundSize[1], config.boundSize[2]
	end

	return 1, 1
end

function HomelandPlotManageNewModel:checkOrnamentCanLevelUp(homeId)
	local upgradeInfo = Utils.getHomeOrnamentUpgradeInfo(homeId)

	if upgradeInfo then
		local homeObjectData = HomeObjectData[upgradeInfo.homeTemplateId] or {}

		return pg.me.triggerMap:isCompleteOrMeetCondition(homeObjectData.unlockCondition)
	else
		return false
	end
end

function HomelandPlotManageNewModel:getEnvFacilityRunningIndex(ornamentId)
	local entity = pg.game.home:getHomeEntity(ornamentId)

	if not entity or not entity.homeFacilityType then
		return 0
	end

	local envFacilityInfo = entity:getEnvFacilityInfo()

	if entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric or entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
		if envFacilityInfo then
			if envFacilityInfo.envProduce == 0 then
				return 0
			else
				return 1
			end
		end
	elseif entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		local linkInfo = entity:getHomeLinkInfo()

		if linkInfo then
			if linkInfo.groupId ~= 0 then
				local linkGroupInfo = pg.me.space.homeLinkGroupMap[linkInfo.groupId]

				if linkGroupInfo.totalProduce > 0 then
					return 1
				else
					return 0
				end
			else
				return 0
			end
		end
	elseif (entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate or entity.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate) and envFacilityInfo then
		if envFacilityInfo.envProduce == 0 then
			return 0
		elseif math.abs(envFacilityInfo.envProduce) == 1 then
			return 1
		else
			return 2
		end
	end

	return 0
end

function HomelandPlotManageNewModel:getOperateIcon(operateInfo, facilityInfo)
	if not operateInfo or not facilityInfo then
		return ""
	end

	local topLogoIconType = operateInfo.topLogoIconType or ClientConst.HomelandTopLogoIconType.Default

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Default then
		return operateInfo.topLogoIcon or ""
	end

	if topLogoIconType == ClientConst.HomelandTopLogoIconType.Output or topLogoIconType == ClientConst.HomelandTopLogoIconType.OutputSpecial then
		local formulaId = facilityInfo.formulaId
		local formulaData = HomelandFormulaData[formulaId] or {}
		local defaultOutputItem, defaultOutputItemNum = HomeLandUtils.getDisplayOutputItemId(formulaData)

		return LuaUIUtils.getIconByItemId(defaultOutputItem)
	end

	return nil
end

function HomelandPlotManageNewModel:checkHasEntDoingOper(ornamentId)
	if not ornamentId then
		return false
	end

	local facilityInfo = pg.me.space.facility[ornamentId]

	if not facilityInfo then
		return false
	end

	local operId = facilityInfo.facilityState

	for playerId, playerOperInfo in pairs(pg.space.playerAllocation) do
		if playerOperInfo.ornamentId == ornamentId and playerOperInfo.opId == operId then
			return true
		end
	end

	local relatedPets = pg.me.space.facilityAllocationInfo[ornamentId]

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if allocation and allocation.opId == operId then
				return true
			end
		end
	end

	return false
end

function HomelandPlotManageNewModel:getStatePaused(facilityInfo, ornamentId)
	local statePaused = false
	local facilityState = facilityInfo.facilityState
	local facilityStateInfo = facilityInfo.facilityStateInfo
	local hasEntDoOper = self:checkHasEntDoingOper(ornamentId)

	if facilityInfo.disable then
		statePaused = true
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.UNDER_CONSUME] then
		statePaused = true
	elseif facilityInfo.envWorkRatio <= 0 then
		statePaused = true
	elseif facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
		statePaused = true
	elseif (facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) and not hasEntDoOper and facilityStateInfo.curValue > 0 then
		statePaused = true
	end

	return statePaused
end

function HomelandPlotManageNewModel:getProgressWorkloadState(hasEntDoingOper, workloadRate)
	local workloadState = 0

	if workloadRate == 0 then
		if hasEntDoingOper then
			workloadState = 0
		else
			workloadState = 1
		end
	elseif workloadRate > 0 and workloadRate < 1 then
		workloadState = 2
	elseif workloadRate == 1 then
		workloadState = 0
	elseif workloadRate > 1 then
		workloadState = 3
	end

	return workloadState
end

function HomelandPlotManageNewModel:calcCurrWorkload(ornamentId)
	if not ornamentId then
		return 0
	end

	local facilityInfo = pg.me.space.facility[ornamentId]

	if not facilityInfo then
		return 0
	end

	local facilityState = facilityInfo.facilityState
	local workLoad = 0
	local relatedPets = pg.space.facilityAllocationInfo[ornamentId]
	local playerOperInfo = pg.me.space.playerAllocation[pg.me.id]

	if playerOperInfo and playerOperInfo.ornamentId == ornamentId and playerOperInfo.opId == facilityState then
		workLoad = workLoad + HomelandConfigData.playerUnitTimeWorkload
	end

	if relatedPets then
		for _, petId in ipairs(relatedPets) do
			local allocation = pg.me.space.allocation[petId]

			if allocation.opId == facilityState then
				workLoad = workLoad + allocation.workload
			end
		end
	end

	return workLoad
end

function HomelandPlotManageNewModel:getFinalFormulaList(ornamentId, facilityInfo)
	if not facilityInfo then
		return {}
	end

	local ornamentInfo = pg.space.ornament[ornamentId]
	local formulaList = facilityInfo.formulaList

	if ornamentInfo and facilityInfo.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch and ornamentInfo.electricMode then
		formulaList = facilityInfo.electricModeFormulaList
	end

	local validFormulaList = {}

	for _, formulaId in ipairs(formulaList or EMPTY_TABLE) do
		if HomelandFormulaData[formulaId] and HomeLandUtils.isHomelandFormulaTimeValid(formulaId) then
			table.insert(validFormulaList, formulaId)
		end
	end

	return validFormulaList
end

function HomelandPlotManageNewModel:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, level, facilityLevel)
	local formulaInfo = HomelandFormulaData[formulaId]

	if not formulaInfo then
		return
	end

	local outputItemId = HomeLandUtils.getDisplayOutputItemId(formulaInfo)
	local previewItemId = formulaInfo.previewItemId or outputItemId
	local unlockState = ClientHomelandUtils.getFormulaUnlockState(formulaId)
	local formulaItem = {
		formulaId = formulaId,
		previewItemInfo = {
			id = previewItemId
		},
		itemInfo = {
			id = outputItemId
		},
		conditionLocked = unlockState.conditionLocked,
		drawingLocked = unlockState.drawingLocked,
		unlockLocked = unlockState.isLocked,
		lockText = unlockState.lockText,
		unlockItemId = unlockState.unlockItemId,
		isLocked = facilityLevel < level
	}
	local timePeriodId = formulaInfo.timePeriodId

	if not timePeriodId or timePeriodId == 0 then
		table.insert(levelFormulaList, formulaItem)

		return
	end

	local timePeriodGroup = timePeriodGroupMap[timePeriodId]

	if not timePeriodGroup then
		local timePeriodData = HomelandFormulaPeriodData[timePeriodId] or {}

		timePeriodGroup = {
			timePeriodId = timePeriodId,
			name = timePeriodData.name,
			level = level,
			periodType = timePeriodData.periodType,
			formulaList = {},
			isLocked = facilityLevel < level
		}
		timePeriodGroupMap[timePeriodId] = timePeriodGroup

		table.insert(timePeriodGroups, timePeriodGroup)
	end

	table.insert(timePeriodGroup.formulaList, formulaItem)
end

function HomelandPlotManageNewModel:getFormulaListInfo(ornamentId, homeTemplateId)
	if not homeTemplateId then
		return {}
	end

	local revertInfo = RevertHomeUpgradeData[homeTemplateId]
	local formulaListInfo = {}
	local timePeriodGroups = {}
	local timePeriodGroupMap = {}

	if revertInfo then
		local facilityType = revertInfo[1]
		local facilityLevel = revertInfo[2]
		local tempFormulaList = {}
		local upgradeInfo = HomelandUpgradeData[facilityType] or {}

		for level, ornamentInfo in ipairs(upgradeInfo) do
			local levelFormulaList = {}
			local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeTemplateId)
			local facilityInfo = HomelandFacilityData[facilityId]

			if facilityInfo then
				local formulaList = self:getFinalFormulaList(ornamentId, facilityInfo)

				for _, formulaId in ipairs(formulaList) do
					if not tempFormulaList[formulaId] then
						tempFormulaList[formulaId] = true

						self:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, level, facilityLevel)
					end
				end
			end

			if #levelFormulaList > 0 then
				table.insert(formulaListInfo, {
					level = level,
					formulaList = levelFormulaList,
					isLocked = facilityLevel < level
				})
			end
		end
	else
		local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)
		local facilityInfo = HomelandFacilityData[facilityId]
		local levelFormulaList = {}

		if facilityInfo then
			local formulaList = self:getFinalFormulaList(ornamentId, facilityInfo)

			for _, formulaId in ipairs(formulaList) do
				self:addFormulaListItem(levelFormulaList, timePeriodGroupMap, timePeriodGroups, formulaId, 1, 1)
			end
		end

		if #levelFormulaList > 0 then
			table.insert(formulaListInfo, {
				level = 1,
				isLocked = false,
				formulaList = levelFormulaList
			})
		end
	end

	for index, timePeriodGroup in ipairs(timePeriodGroups) do
		table.insert(formulaListInfo, index, timePeriodGroup)
	end

	return formulaListInfo
end

function HomelandPlotManageNewModel:getFormulaListDetailInfo(formulaId)
	local formulaData = HomelandFormulaData[formulaId]
	local formulaInfo = {}

	if formulaData.pet then
		formulaInfo.formulaType = 1
		formulaInfo.petList = {
			{
				label = 0,
				petId = formulaData.pet
			}
		}
	else
		formulaInfo.formulaType = 0

		local itemList = {}

		for i = 1, 3 do
			local consumableId = formulaData["consumable" .. i]

			if consumableId then
				local numText = ""
				local curCount = ClientUtils.getHomelandItemCountById(consumableId)
				local consumeCount = formulaData["consumableNum" .. i]

				if consumeCount <= curCount then
					numText = pg.getFormatText("{0}/{1}", ClientUtils.getHomelandItemCountById(consumableId), formulaData["consumableNum" .. i])
				else
					numText = pg.getFormatText("<style=Debuff>{0}</style>/{1}", ClientUtils.getHomelandItemCountById(consumableId), formulaData["consumableNum" .. i])
				end

				table.insert(itemList, {
					tIndex = 0,
					id = consumableId,
					num = numText
				})
			else
				table.insert(itemList, {
					tIndex = 1
				})
			end
		end

		formulaInfo.itemList = itemList
	end

	if formulaData.time then
		formulaInfo.time = formulaData.time
		formulaInfo.formulaType = 0
	end

	if formulaData.workload then
		formulaInfo.workload = formulaData.workload
		formulaInfo.formulaType = formulaInfo.itemList and 2 or 1
	end

	return formulaInfo
end

function HomelandPlotManageNewModel:getMaxAllowedUpgradeInfo(homeTemplateId)
	if not homeTemplateId then
		return nil
	end

	local revertInfo = RevertHomeUpgradeData[homeTemplateId]

	if not revertInfo then
		return nil
	end

	local facilityType = revertInfo[1]
	local currentLevel = revertInfo[2] or 0
	local upgradeChain = HomelandUpgradeData[facilityType]

	if not upgradeChain then
		return nil
	end

	local maxHomeId = homeTemplateId
	local nextLevel = currentLevel + 1
	local maxCost = {}
	local upgradeItemCost = {}

	while upgradeChain[nextLevel] do
		local candidateId = upgradeChain[nextLevel].homeTemplateId
		local candidateConfig = HomeObjectData[candidateId]
		local unlockCondition = candidateConfig and candidateConfig.unlockCondition
		local canUpgrade = false

		if pg.me.triggerMap and unlockCondition then
			canUpgrade = pg.me.triggerMap:isCompleteOrMeetCondition(unlockCondition)
		end

		if not canUpgrade then
			break
		end

		for id, num in pairs(upgradeChain[nextLevel].upgradeCost or EMPTY_TABLE) do
			if not maxCost[id] then
				maxCost[id] = 0
			end

			maxCost[id] = maxCost[id] + num
		end

		for id, num in pairs(upgradeChain[nextLevel].upgradeItemCost or EMPTY_TABLE) do
			if not upgradeItemCost[id] then
				upgradeItemCost[id] = 0
			end

			upgradeItemCost[id] = upgradeItemCost[id] + num
		end

		maxHomeId = candidateId
		nextLevel = nextLevel + 1
	end

	return {
		homeTemplateId = maxHomeId,
		upgradeCost = maxCost,
		upgradeItemCost = upgradeItemCost
	}
end

function HomelandPlotManageNewModel:getOrnamentTypeId(ornamentId)
	if not ornamentId then
		return
	end

	local ornamentInfo = pg.me.space.ornament[ornamentId]

	if not ornamentInfo then
		return
	end

	local homeTemplateId = ornamentInfo.homeId

	if not homeTemplateId then
		return
	end

	local revertInfo = RevertHomeUpgradeData[homeTemplateId]

	if not revertInfo then
		return homeTemplateId
	end

	return revertInfo[1]
end

function HomelandPlotManageNewModel:getFormulaUnlockLevel(ornamentId, formulaId)
	if not ornamentId or not formulaId then
		return nil
	end

	local ornamentInfo = pg.me.space.ornament[ornamentId]

	if not ornamentInfo then
		return nil
	end

	local homeTemplateId = ornamentInfo.homeId

	if not homeTemplateId then
		return nil
	end

	local revertInfo = RevertHomeUpgradeData[homeTemplateId]

	if not revertInfo then
		local facilityId = Utils.getHomeObjectFacilityId(homeTemplateId)

		if not facilityId then
			return nil
		end

		local facilityInfo = HomelandFacilityData[facilityId]
		local formulaList = self:getFinalFormulaList(ornamentId, facilityInfo)

		if not facilityInfo or not formulaList then
			return nil
		end

		for _, fId in ipairs(formulaList) do
			if fId == formulaId then
				return 1
			end
		end

		return nil
	end

	local facilityType = revertInfo[1]

	if not facilityType then
		return nil
	end

	local upgradeInfo = HomelandUpgradeData[facilityType]

	if not upgradeInfo then
		return nil
	end

	for level, ornamentInfo in ipairs(upgradeInfo) do
		local levelHomeTemplateId = ornamentInfo.homeTemplateId

		if levelHomeTemplateId then
			local facilityId = Utils.getHomeObjectFacilityId(levelHomeTemplateId)

			if facilityId then
				local facilityInfo = HomelandFacilityData[facilityId]
				local formulaList = self:getFinalFormulaList(ornamentId, facilityInfo)

				for _, fId in ipairs(formulaList) do
					if fId == formulaId then
						return level
					end
				end
			end
		end
	end

	return nil
end

function HomelandPlotManageNewModel:canHomeObjectUpgrade(homeId)
	if not homeId then
		return false
	end

	local revertInfo = RevertHomeUpgradeData[homeId]

	if not revertInfo then
		return false
	end

	local facilityType = revertInfo[1]
	local currentLevel = revertInfo[2]
	local upgradeChain = HomelandUpgradeData[facilityType] or {}

	return #upgradeChain > 1
end

function HomelandPlotManageNewModel:canHomeObjectEnvironment(homeId)
	if not homeId then
		return false
	end

	local facilityId = Utils.getHomeObjectFacilityId(homeId)

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	if not facilityData.facilityType then
		return false
	end

	local envType = Const.HOMELAND_ENV_FACILITY_TYPES[facilityData.facilityType]

	if envType and facilityData.facilityType ~= Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		return true
	end

	return false
end

function HomelandPlotManageNewModel:getEnvFacilityInfo(homeId)
	local facilityId = Utils.getHomeObjectFacilityId(homeId)

	if not facilityId then
		return nil
	end

	local facilityData = HomelandFacilityData[facilityId] or {}

	if not facilityData.facilityType or not Const.HOMELAND_ENV_FACILITY_TYPES[facilityData.facilityType] then
		return nil
	end

	local envBounds = facilityData.envBounds

	if not envBounds then
		return nil
	end

	return {
		facilityType = facilityData.facilityType,
		envBounds = envBounds
	}
end

function HomelandPlotManageNewModel:canHomeObjectSwitchFormula(homeId)
	if not homeId then
		return false
	end

	local homeObjectData = HomeObjectData[homeId]

	if not homeObjectData then
		return false
	end

	local facilityId = homeObjectData.facilityId

	if not facilityId then
		return false
	end

	local facilityData = HomelandFacilityData[facilityId]

	if not facilityData or not facilityData.formulaList then
		return false
	end

	if Utils.isHomeEnvFacility(homeId) then
		return false
	end

	return true
end

function HomelandPlotManageNewModel:canHomeObjectPlacePet(homeId, facilityInfo)
	if not homeId then
		return false
	end

	if not facilityInfo or facilityInfo.facilityState == 0 then
		return false
	end

	if facilityInfo.facilityStateInfo and facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		return false
	end

	local homeObjectData = HomeObjectData[homeId]

	if not homeObjectData then
		return false
	end

	local maxPetCount = homeObjectData.maxPetCount or 0

	if maxPetCount < 1 then
		return false
	end

	return true
end

function HomelandPlotManageNewModel:ctor()
	self.HOME_TAG = "home"
	self.WORKPET_TAG = "workPet"
	self.NULLPET_TAG = "nullPet"
	self.HOME_SPLIT = "_"
end

return HomelandPlotManageNewModel
