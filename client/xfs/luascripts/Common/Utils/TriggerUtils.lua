-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\TriggerUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local TriggerConst = require("Common.Const.TriggerConst")
local Utils = require("Common.Utils.Utils")
local ItemUtils = require("Common.Utils.ItemUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local TimeTokenUtils = require("Common.Utils.TimeTokenUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local TriggerMapData = require("Data.trigger_map_data")
local TriggerData = require("Data.trigger_data")
local QuestBase = require("Data.Quest.quest_base")
local AppearanceData = require("Data.appearance_data")
local PetTalentData = require("Data.pet_talent_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local SpecialTrainBadgeData = require("Data.special_train_badge_data")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local Bitset = require("Common.Bitset")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetSkillData = require("Data.pet_skill_data")
local ItemData = require("Data.item_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local SceneData = require("Data.scene_data")
local PetBasePropAttrNames = require("Data.pet_base_prop_attr_names")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local HomeCampCarData = require("Data.home_camp_car_data")
local PlayerBadgeData = require("Data.player_badge_data")
local PlayerBadgeLayoutData = require("Data.player_badge_layout_data")
local ItemConst = require("Common.Const.ItemConst")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandFormulaRandomReverseData = require("Data.homeland_formula_random_reverse_data")
local SuitData = require("Data.appearance_suit_data")
local GameEventData = require("Data.game_event_data")
local ActivityConst = require("Common.Const.ActivityConst")
local AppearanceActionData = require("Data.appearance_action_data")
local QuestMain = require("Data.quest_main")
local PayProductData = require("Data.shopmall_recharge_data")
local getBit = Bitset.getBit
local bit = bit
local TriggerUtils = {}
local ToBool = ToBool
local Vector3 = Vector3
local Quaternion = Quaternion
local unpack = unpack

function TriggerUtils._getCommonValuePosSphere(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local needSphere = extraArg

	if needSphere == nil then
		return 0
	end

	local dstScene, dstPosition, radius = needSphere[1] or 0, Vector3.Clone(needSphere[2]), needSphere[3] or 0

	return playerEnt.space.sceneId == dstScene and Vector3.SqrDistance(playerEnt:getPosition(), dstPosition) <= radius * radius and 1 or 0
end

function TriggerUtils._isHaveSpecialTrainBadgeReward(playerEnt, arg, extraArg)
	local stageId = arg or 0

	if stageId == 0 then
		return Bitset.any(playerEnt.badgeRewardFlags) and 1 or 0
	end

	return getBit(playerEnt.badgeRewardFlags, stageId) and 1 or 0
end

function TriggerUtils._isInTimePeriod(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local targetPeriodList = extraArg

	if targetPeriodList and next(targetPeriodList) then
		local timePeriod

		if Utils.isSpaceTown(playerEnt.space.spaceType) then
			timePeriod = playerEnt.lineTimePeriod
		elseif Utils.isHomeland(playerEnt.space.spaceType) then
			timePeriod = playerEnt.space.curPeriodIndex
		elseif Utils.isSceneSingleWorld(playerEnt.space.sceneId) then
			timePeriod = playerEnt.space.curPeriodIndex
		end

		if not timePeriod then
			return 0
		end

		for _, index in ipairs(targetPeriodList) do
			if index == timePeriod then
				return 1
			end
		end
	end

	return 0
end

function TriggerUtils._getCommonValueCharacterState(playerEnt, arg, extraArg)
	local needState = extraArg

	return needState == playerEnt.characterState and 1 or 0
end

function TriggerUtils._getCommonValueControlPetCanFlyGe(playerEnt, arg, extraArg)
	local controlPet = playerEnt:getControllingPet()

	if controlPet == nil then
		return 0
	end

	local petData = controlPet:getConfigData()

	if petData == nil or petData.canFly == nil then
		return 0
	end

	return petData.canFly >= (arg or 1) and 1 or 0
end

function TriggerUtils._getCommonValuePetLevelTemplate(playerEnt, arg, extraArg)
	local basePetPrototypeId = arg or 0

	return playerEnt.petStatsInfo:getPetTemplateMaxLevel(basePetPrototypeId)
end

function TriggerUtils._getCommonValuePetIndividualLevelsReach(playerEnt, arg, extraArg)
	local petPrototypeId = arg or 0
	local propLevelPairs = extraArg or {
		{
			0,
			20
		}
	}

	if #propLevelPairs == 0 then
		propLevelPairs = {
			{
				0,
				20
			}
		}
	end

	local propIndex, minLevel = unpack(propLevelPairs[1])

	return playerEnt.petStatsInfo:getPetIndividualLevelCountMin(petPrototypeId, propIndex, minLevel)
end

function TriggerUtils._getCommonValuePetLevelCount(playerEnt, arg, extraArg)
	if extraArg == nil then
		return 0
	end

	local petPrototypeId = arg or 0
	local level = extraArg

	return playerEnt.petStatsInfo:getPetLevelCountMin(petPrototypeId, level)
end

function TriggerUtils._getCommonValueCollectPetNum(playerEnt, arg, extraArg)
	local label = 0
	local needCountryId

	if extraArg ~= nil then
		if type(extraArg) == "table" then
			label = extraArg[1] or 0
			needCountryId = extraArg[2]
		else
			label = extraArg
		end
	end

	if label == 0 then
		return TriggerUtils._getCollectPetNumAnyLabel(playerEnt, arg, needCountryId)
	end

	local mask

	if label == Const.PET_LABEL_MASK.SHINY then
		mask = Const.PET_HBMSK_SHINY_CATCHED
	elseif label == Const.PET_LABEL_MASK.ELITE then
		mask = Const.PET_HBMSK_ELITE_CATCHED
	end

	return mask and playerEnt:getPetHandbookCountByIdAndStateMask(arg, mask, needCountryId) or 0
end

function TriggerUtils._getCollectPetNumAnyLabel(playerEnt, basePetPrototypeId, needCountryId)
	basePetPrototypeId = basePetPrototypeId or 0

	if needCountryId ~= nil and needCountryId > 0 then
		local countryConfig = MapAreaConfigData[needCountryId]

		if not countryConfig or countryConfig.belongNation == nil then
			return 0
		end
	else
		needCountryId = nil
	end

	local function isMatched(petPrototypeId)
		if needCountryId ~= nil and not Utils.checkPetHasFormInCountry(petPrototypeId, needCountryId) then
			return false
		end

		return Utils.innerIsPetCatched(playerEnt, petPrototypeId)
	end

	if basePetPrototypeId ~= 0 then
		return Utils.getBoolByPetPrototypeIdAndGroupType(basePetPrototypeId, Const.GROUP_TYPE_ANY, isMatched) and 1 or 0
	end

	local count = 0
	local baseSet = {}

	for petPrototypeId in playerEnt.petHandbookMap:items() do
		if isMatched(petPrototypeId) then
			local innerBasePetPrototypeId = Utils.getBasePetPrototypeId(petPrototypeId)

			if not baseSet[innerBasePetPrototypeId] then
				baseSet[innerBasePetPrototypeId] = true
				count = count + 1
			end
		end
	end

	return count
end

function TriggerUtils._getCommonValueKnownPetNum(playerEnt, arg, extraArg)
	local label = extraArg or 0
	local mask

	if label == 0 then
		mask = Const.PET_HBMSK_KNOWN
	elseif label == Const.PET_LABEL_MASK.SHINY then
		mask = Const.PET_HBMSK_SHINY_KNOWN
	elseif label == Const.PET_LABEL_MASK.ELITE then
		mask = Const.PET_HBMSK_ELITE_KNOWN
	end

	return mask and playerEnt:getPetHandbookCountByIdAndStateMask(arg, mask) or 0
end

function TriggerUtils._getCommonValueCleanMonsterCamp(playerEnt, arg, extraArg)
	local spawnerId = arg
	local count = 0

	for oneSpawnerId, oneCount in playerEnt.battleFieldRecordMap:items() do
		if (spawnerId == 0 or spawnerId == oneSpawnerId) and oneCount > 0 then
			count = count + 1
		end
	end

	return count
end

function TriggerUtils._getCommonValueOpenChest(playerEnt, arg, extraArg)
	local tag, quality = arg, extraArg or 0

	if quality == 0 then
		local count = 0
		local chestAttr = (tag or 0) * 100

		for k, v in playerEnt.openChestCount:items() do
			if chestAttr ~= 0 and math.floor(k / chestAttr) == 1 or chestAttr == 0 then
				count = count + v
			end
		end

		return count
	end

	local chestAttr = (tag or 0) * 100 + quality

	if playerEnt.openChestCount[chestAttr] ~= nil then
		return playerEnt.openChestCount[chestAttr]
	end

	return 0
end

function TriggerUtils._getCommonValueOpenChestByStaticId(playerEnt, arg, extraArg)
	local staticId = arg

	if playerEnt.interactRecord[staticId] ~= nil then
		return playerEnt.interactRecord[staticId]
	end

	return 0
end

function TriggerUtils._getCommonValueTotalResearchLevel(playerEnt, arg, extraArg)
	if arg == 0 then
		return playerEnt:getPetHandbookMaxCountryTotalLevel()
	else
		return playerEnt:getPetHandbookCountryTotalLevel(arg)
	end
end

function TriggerUtils._getCommonValueEthnicGroupJudgment(playerEnt, arg, extraArg)
	local curPet = playerEnt:getControllingPet()
	local curVal = curPet and curPet:getConfigData().ethnicGroup or 0

	return arg == curVal and 1 or 0
end

function TriggerUtils._getCommonValueDistancePlayerNpcCallFriend(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return Const.NUMBER_MAX
	end

	local targetPuppetStaticId = arg
	local callPuppetStaticId = extraArg
	local curPet = playerEnt:getCurPetEntity()

	if curPet == nil or not curPet:isEntitySlavePuppets(callPuppetStaticId) then
		return Const.NUMBER_MAX
	end

	local calledPuppet = playerEnt.space:getEntityByStaticId(callPuppetStaticId)

	if calledPuppet == nil then
		return Const.NUMBER_MAX
	end

	local targetPuppet = playerEnt.space:getEntityByStaticId(targetPuppetStaticId)

	if targetPuppet == nil then
		return Const.NUMBER_MAX
	end

	local distance = Utils.distance(calledPuppet:getPosition(), targetPuppet:getPosition())

	return pg.component == "game" and distance - Const.SERVER_POS_CHECK_TOLERANCE or distance
end

function TriggerUtils._getCommonValueGotoPosition(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local curPos = playerEnt:getPosition()
	local curSceneId = playerEnt.space.sceneId

	return Utils.checkPositionMatch(curSceneId, curPos, arg, true) and 1 or 0
end

local _allFilterUtils = {}

function TriggerUtils.generateFiltersCommon(triggerType, customRegisterIdsAll)
	local filterArgs = _allFilterUtils[triggerType]

	if filterArgs then
		return filterArgs
	end

	filterArgs = {}
	_allFilterUtils[triggerType] = filterArgs

	local args = TriggerUtils.TRIGGER_CUSTOM_CLIENT_ONLY[triggerType]
	local generateFilterArgs = args.generateFilterArgs

	for triggerId, customRegisterIds in pairs(customRegisterIdsAll) do
		if #customRegisterIds == 1 then
			local regId = customRegisterIds[1]

			filterArgs[triggerId] = generateFilterArgs(regId)
		end
	end

	return filterArgs
end

local _allFilterUtilsSceneId

function TriggerUtils._getCommonValueGotoPosition_OnSceneLoad(sceneId)
	if _allFilterUtilsSceneId ~= sceneId then
		_allFilterUtils = {}

		Utils.InitcheckPositionMatchByClient(sceneId)

		_allFilterUtilsSceneId = sceneId
	end
end

function TriggerUtils._getCommonValueGotoPosition_generateFilterArgs(regId)
	local customDataId, triggerPos = TriggerConst.parseCustomTriggerKey(regId)
	local ctdd = CustomTriggerData[customDataId]
	local cond = ctdd.condition[triggerPos]
	local posId = cond[TriggerConst.CUSTOM_TRIGGER_TARGET_POS]
	local operator = cond[TriggerConst.CUSTOM_TRIGGER_OPERATOR_POS]
	local dstCount = cond[TriggerConst.CUSTOM_TRIGGER_NUM_POS]

	if (operator == nil or operator == ">=") and dstCount == 1 then
		return posId
	end
end

function TriggerUtils._getCommonValueGotoPosition_fastFilter(filterArg)
	return Utils.existPositionMatch(filterArg)
end

function TriggerUtils._getCommonValueControlGotoPosition(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local curPos = playerEnt:getPosition()
	local curSceneId = playerEnt.space.sceneId

	if not Utils.checkPositionMatch(curSceneId, curPos, arg, true) then
		return 0
	end

	extraArg = extraArg or {}

	return lume.findInList(extraArg, playerEnt:getPetControlEthnicGroup()) ~= nil and 1 or 0
end

local function getCurrentBattlePetInfo(playerEnt)
	local petId = playerEnt and playerEnt.curCombatPetId

	if not petId then
		return nil
	end

	local petEntity = pg.getEntity(petId)

	if petEntity and petEntity.getBattlePetInfo then
		local petInfo = petEntity:getBattlePetInfo()

		if petInfo then
			return petInfo
		end
	end

	return playerEnt.getPetInfo and playerEnt:getPetInfo(petId) or nil
end

function TriggerUtils._getCommonValueControlGotoPositionPet(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local curPos = playerEnt:getPosition()
	local curSceneId = playerEnt.space.sceneId

	if not Utils.checkPositionMatch(curSceneId, curPos, arg, true) then
		return 0
	end

	if not extraArg or not Utils.isTable(extraArg) or #extraArg ~= 2 then
		return 0
	end

	local petInfo = getCurrentBattlePetInfo(playerEnt)

	if not petInfo then
		return 0
	end

	local patternType = extraArg[1]

	if (patternType == 0 or patternType == playerEnt.controlState) and extraArg[2] == petInfo.basePetPrototypeId then
		return 1
	end

	return 0
end

local _posIdArray = {
	"boardPosition",
	"ornamentCenter",
	"carPosition",
	"carPosition"
}

function TriggerUtils._getCommonValueArriveHomeCarPosition(playerEnt, arg, extraArg)
	if not Utils.isTable(extraArg) then
		return 0
	end

	local posType, radius = extraArg[1], extraArg[2]

	if posType == nil or radius == nil then
		return 0
	end

	if not playerEnt.isHomeCampUnlocked then
		return 0
	end

	local spaceKey = playerEnt.space and playerEnt.space.spaceKey

	if spaceKey == nil or spaceKey ~= Utils.getSelfHomeCampKey(playerEnt) then
		return 0
	end

	local carEnt = HomeLandUtils.getCampCarEntity(playerEnt.uid)
	local hccdd = carEnt and HomeCampCarData[carEnt.carTmplId]

	if hccdd == nil then
		return 0
	end

	local posId = hccdd[_posIdArray[posType]]

	if posId == nil then
		return 0
	end

	if pg.component == "game" then
		radius = radius + Const.SERVER_POS_CHECK_TOLERANCE
	end

	local sceneId = SceneUtils.getMainSceneId(playerEnt.space.sceneId)
	local curPos = playerEnt:getPosition()
	local dstPos, dstRot = SceneUtils.getCommonBasicsPosition(sceneId, posId)

	if posType == 4 then
		local offsetPos = HomelandConfigData.carInteractOffset or Const.HOME_CAMP_CAR_INTERACT_OFFSET

		dstPos = dstPos + dstRot:MulVec3(Vector3(offsetPos[1], offsetPos[2], offsetPos[3]))
	end

	local isMatch = dstPos and Vector3.HoriSqrDistance(curPos, dstPos) <= radius * radius

	return isMatch and 1 or 0
end

if pg.component ~= "client" then
	local _meetPetList = {}

	function TriggerUtils._getCommonValueMeetPet(playerEnt, arg, extraArg)
		if extraArg and (not Utils.isTable(extraArg) or #extraArg ~= 2) then
			ALARM("extraArg must be nil or tablePair: %s", inspect(extraArg))

			return Const.NUMBER_MAX
		end

		if not playerEnt.space then
			return Const.NUMBER_MAX
		end

		local curLogicHour = math.floor(playerEnt.space.logicTime / 60)

		table.clearArray(_meetPetList)
		playerEnt:entitiesInRangeWithTable(math.floor(playerEnt.aoiRange / 100), Const.SEARCH_USR_TYPE_MONSTER, nil, _meetPetList)

		for _, actorId in ipairs(_meetPetList) do
			local ent = pg.getEntityByActorId(actorId)

			if (arg == 0 or arg == ent.basePetPrototypeId) and (extraArg == nil or curLogicHour >= extraArg[1] and curLogicHour <= extraArg[2]) then
				return Utils.distance(playerEnt:getPosition(), ent:getPosition())
			end
		end

		return Const.NUMBER_MAX
	end

	local _nearPetList = {}

	function TriggerUtils._getCommonValueNearPet(playerEnt, arg, extraArg)
		if extraArg and type(extraArg) ~= "number" then
			ALARM("extraArg must be nil or number(distance): %s", inspect(extraArg))

			return Const.NUMBER_MAX
		end

		table.clearArray(_nearPetList)
		playerEnt:entitiesInRangeWithTable(math.floor(playerEnt.aoiRange / 100), Const.SEARCH_USR_TYPE_MONSTER, nil, _nearPetList)

		for _, actorId in ipairs(_nearPetList) do
			local ent = pg.getEntityByActorId(actorId)

			if ent and (arg == 0 or arg == ent.basePetPrototypeId) and (extraArg == nil or extraArg == ent.label) then
				return Utils.distance(playerEnt:getPosition(), ent:getPosition())
			end
		end

		return Const.NUMBER_MAX
	end
else
	local _meetPetIdList = {}
	local _meetPetList = {}
	local _meetPetTime = -1

	setmetatable(_meetPetList, {
		__mode = "v"
	})

	function TriggerUtils._getCommonValueMeetPet(playerEnt, arg, extraArg)
		if extraArg and (not Utils.isTable(extraArg) or #extraArg ~= 2) then
			ALARM("extraArg must be nil or tablePair: %s", inspect(extraArg))

			return Const.NUMBER_MAX
		end

		if not playerEnt.space then
			return Const.NUMBER_MAX
		end

		if _meetPetTime ~= Time.unityFrameCount then
			table.clearArray(_meetPetIdList)
			table.clearArray(_meetPetList)
			playerEnt:entitiesInRangeWithTable(math.floor(playerEnt.aoiRange / 100), Const.SEARCH_USR_TYPE_MONSTER, nil, _meetPetIdList)

			for _, actorId in ipairs(_meetPetIdList) do
				local ent = pg.getEntityByActorId(actorId)

				if ent then
					_meetPetList[#_meetPetList + 1] = ent
				end
			end
		end

		local curLogicHour = math.floor(playerEnt.space.logicTime / 60)

		for _, ent in ipairs(_meetPetList) do
			if (arg == 0 or arg == ent.basePetPrototypeId) and (extraArg == nil or curLogicHour >= extraArg[1] and curLogicHour <= extraArg[2]) then
				return Utils.distance(playerEnt:getPosition(), ent:getPosition())
			end
		end

		return Const.NUMBER_MAX
	end

	local _nearPetIdList = {}
	local _nearPetList = {}
	local _nearPetTime = -1

	setmetatable(_nearPetList, {
		__mode = "v"
	})

	function TriggerUtils._getCommonValueNearPet(playerEnt, arg, extraArg)
		if extraArg and type(extraArg) ~= "number" then
			ALARM("extraArg must be nil or number(distance): %s", inspect(extraArg))

			return Const.NUMBER_MAX
		end

		if _nearPetTime ~= Time.unityFrameCount then
			table.clearArray(_nearPetIdList)
			table.clearArray(_nearPetList)
			playerEnt:entitiesInRangeWithTable(math.floor(playerEnt.aoiRange / 100), Const.SEARCH_USR_TYPE_MONSTER, nil, _nearPetIdList)

			for _, actorId in ipairs(_nearPetIdList) do
				local ent = pg.getEntityByActorId(actorId)

				if ent then
					_nearPetList[#_nearPetList + 1] = ent
				end
			end
		end

		for _, ent in ipairs(_nearPetList) do
			if (arg == 0 or arg == ent.basePetPrototypeId) and (extraArg == nil or extraArg == ent.label) then
				return Utils.distance(playerEnt:getPosition(), ent:getPosition())
			end
		end

		return Const.NUMBER_MAX
	end
end

if pg.component == "game" then
	function TriggerUtils._getCommonClientCustomVariable(playerEnt, arg, extraArg)
		ALARM("getCommonClientCustomVariable must execute in client: %s", inspect(extraArg))

		return 0
	end
else
	function TriggerUtils._getCommonClientCustomVariable(playerEnt, arg, extraArg)
		return playerEnt:getClientCustomVariable(arg)
	end
end

function TriggerUtils._getServerValueCatchCountOnce(playerEnt, arg, extraArg, triggerParams)
	local needBasePetPrototypeId = arg
	local needLabel = extraArg or 0
	local count = 0

	for basePetPrototypeId, templateIdInfo in pairs(triggerParams or EMPTY_TABLE) do
		local validCount = 0

		if needBasePetPrototypeId == 0 or needBasePetPrototypeId == basePetPrototypeId then
			for label, labelCount in pairs(templateIdInfo) do
				if needLabel == 0 or needLabel == label then
					validCount = validCount + labelCount
				end
			end
		end

		count = count + validCount
	end

	return count
end

function TriggerUtils._getServerValueSandBoxLeveItemFiledValue(playerEnt, arg, extraArg, triggerParams)
	local sandboxId = arg
	local space = playerEnt.space

	if not space then
		return 0
	end

	local sandbox = space.sandboxes and space.sandboxes[sandboxId] or {}
	local levelItemId = extraArg and extraArg[1] or 0
	local filed = extraArg and extraArg[2] or ""

	return sandbox.levelItems and sandbox.levelItems[levelItemId] and sandbox.levelItems[levelItemId][filed] or 0
end

function TriggerUtils._checkCombatActionNodeDuration(playerEnt, petPrototypeId, extraArg, triggerParams)
	if extraArg == nil then
		return 0
	end

	local cfgId, cfgDuration, triggerCnt = unpack(extraArg)
	local arg = Utils.isTable(triggerParams) and triggerParams[1] or 0

	if arg ~= cfgId then
		return 0
	end

	local lastTriggerTime = 0
	local lastTriggerCnt = 0

	if not playerEnt.triggerTimeStamps then
		playerEnt.triggerTimeStamps = {}
	end

	if playerEnt.triggerTimeStamps[arg] then
		lastTriggerTime, lastTriggerCnt = unpack(playerEnt.triggerTimeStamps[arg])
	end

	if cfgDuration < Time.realSecondCache - lastTriggerTime then
		lastTriggerCnt = 0
	end

	if cfgId == arg then
		lastTriggerCnt = lastTriggerCnt + 1

		if lastTriggerCnt < triggerCnt then
			playerEnt.triggerTimeStamps[arg] = {
				Time.realSecondCache,
				lastTriggerCnt
			}
		else
			playerEnt.triggerTimeStamps[arg] = nil
		end
	end

	return triggerCnt <= lastTriggerCnt and 1 or 0
end

function TriggerUtils._checkCombatActionNodeDurationByFrom(playerEnt, baseFormPet, extraArg, triggerParams)
	if extraArg == nil then
		return 0
	end

	local cfgId, cfgDuration, triggerCnt = unpack(extraArg)
	local arg = Utils.isTable(triggerParams) and triggerParams[1] or 0

	if arg ~= cfgId then
		return 0
	end

	local lastTriggerTime = 0
	local lastTriggerCnt = 0

	if not playerEnt.formTriggerTimeStamps then
		playerEnt.formTriggerTimeStamps = {}
	end

	if playerEnt.formTriggerTimeStamps[arg] then
		lastTriggerTime, lastTriggerCnt = unpack(playerEnt.formTriggerTimeStamps[arg])
	end

	if cfgDuration < Time.realSecondCache - lastTriggerTime then
		lastTriggerCnt = 0
	end

	if cfgId == arg then
		lastTriggerCnt = lastTriggerCnt + 1

		if lastTriggerCnt < triggerCnt then
			playerEnt.formTriggerTimeStamps[arg] = {
				Time.realSecondCache,
				lastTriggerCnt
			}
		else
			playerEnt.formTriggerTimeStamps[arg] = nil
		end
	end

	return triggerCnt <= lastTriggerCnt and 1 or 0
end

function TriggerUtils._getServerValueFlowerNourishByTree(playerEnt, arg, extraArg, triggerParams)
	if arg == 0 then
		local total = 0

		for treeId, data in pairs(playerEnt.statFlowerNourish) do
			for _, c in pairs(data) do
				total = total + c
			end
		end

		return total
	end

	local sub = playerEnt.statFlowerNourish[arg]

	if not sub then
		return 0
	end

	local total = 0

	for _, c in pairs(sub) do
		total = total + c
	end

	return total
end

function TriggerUtils._checkBuffLayer(playerEnt, buffId, extraArg, triggerParams)
	if not extraArg then
		return 0
	end

	local curPet = playerEnt:getCurPetEntity()

	if not curPet or curPet:getConfigData().petPrototypeId ~= extraArg then
		return 0
	end

	local buff = curPet.actorBuff:findOneBuffByTemplateId(buffId)

	return buff and buff.buffData.layer or 0
end

function TriggerUtils._checkInCamou(playerEnt, petPrototypeId, extraArg, triggerParams)
	local curPet = playerEnt:getCurPetEntity()

	if not curPet or curPet:getConfigData().petPrototypeId ~= petPrototypeId then
		return 0
	end

	return curPet.isCamouflage and 1 or 0
end

function TriggerUtils._checkLessEqualBallNum(extraArg, triggerParams)
	if not extraArg or #extraArg ~= 2 then
		return false
	end

	local ballId = extraArg[1]
	local num = extraArg[2]
	local curBallId = triggerParams[1]
	local curNum = triggerParams[2]

	if ballId > 0 and ballId ~= curBallId then
		return false
	end

	return curNum <= num and true or false
end

function TriggerUtils._checkPetHpLePercent(extraArg, triggerParams)
	local curPercent, isCurPet = unpack(triggerParams, 1, 2)
	local needPercent, needPetType = unpack(extraArg, 1, 2)

	needPetType = needPetType or Const.PET_TYPE_ANY

	if needPercent < curPercent then
		return false
	end

	if needPetType == Const.PET_TYPE_CUR and not isCurPet then
		return false
	end

	return true
end

function TriggerUtils._checkPetHpGePercent(extraArg, triggerParams)
	local curPercent, isCurPet = unpack(triggerParams, 1, 2)
	local needPercent, needPetType = unpack(extraArg, 1, 2)

	needPetType = needPetType or Const.PET_TYPE_ANY

	if curPercent < needPercent then
		return false
	end

	if needPetType == Const.PET_TYPE_CUR and not isCurPet then
		return false
	end

	return true
end

function TriggerUtils._getClientValueAngleOfView(playerEnt, arg, extraArg, triggerParams)
	return triggerParams
end

function TriggerUtils._getClientValuePetHpPercentTime(playerEnt, arg, extraArg, triggerParams)
	if extraArg == nil then
		return 0
	end

	local needPercent, needSecond, needPetType = unpack(extraArg, 1, 3)

	needPetType = needPetType or Const.PET_TYPE_ANY

	if needPetType == Const.PET_TYPE_ANY then
		for _, petId in pairs(playerEnt.petPrepareList) do
			local pet = pg.getEntity(petId)
			local second = Time.realSecondCache - (pet and pet.hpPercentTsMap[needPercent] or Time.realSecondCache)

			if needSecond <= second then
				return 1
			end
		end
	elseif needPetType == Const.PET_TYPE_CUR then
		local pet = playerEnt:getCurPetEntity()
		local second = Time.realSecondCache - (pet and pet.hpPercentTsMap[needPercent] or Time.realSecondCache)

		if needSecond <= second then
			return 1
		end
	end

	return 0
end

function TriggerUtils._getClientValuePetHpPercent(playerEnt, arg, extraArg, triggerParams)
	if extraArg == nil then
		return 0
	end

	local needPercent, needPetType = unpack(extraArg, 1, 2)

	needPetType = needPetType or Const.PET_TYPE_ANY

	if needPetType == Const.PET_TYPE_ANY then
		for _, petId in pairs(playerEnt.petPrepareList) do
			local pet = pg.getEntity(petId)

			if pet and ToInt(pet.hpPercentTsMap[needPercent]) > 0 then
				return 1
			end
		end
	elseif needPetType == Const.PET_TYPE_CUR then
		local pet = playerEnt:getCurPetEntity()

		if pet and ToInt(pet.hpPercentTsMap[needPercent]) > 0 then
			return 1
		end
	end

	return 0
end

local fast_pairs = pairs

function TriggerUtils._getClientValuePetTeamSkillType(playerEnt, arg, extraArg, triggerParams)
	local mgr = pg.global.abilityMgr
	local existsTag = mgr.existsTag

	if extraArg == 0 then
		for _, entityId in ipairs(playerEnt.petPrepareList) do
			local petEnt = pg.getEntity(entityId)

			if petEnt then
				for abilityId, _ in fast_pairs(petEnt.abilityMap) do
					if existsTag(mgr, abilityId, arg) then
						return 1
					end
				end
			end
		end
	elseif extraArg == 1 then
		for _, entityId in ipairs(playerEnt.petPrepareList) do
			local petEnt = pg.getEntity(entityId)

			if petEnt then
				for abilityId, _ in fast_pairs(petEnt.abilityMap) do
					if existsTag(mgr, abilityId, arg) and petEnt:checkCanCastAbilityNoTarget(abilityId, nil, false) then
						return 1
					end
				end
			end
		end
	end

	return 0
end

function TriggerUtils._getClientValueFriendsNum(playerEnt, arg, extraArg)
	local friendList = pg.game.chat.friendList or {}

	return #friendList[2].subItems
end

function TriggerUtils._getClientSpaceType(playerEnt, arg, extraArg)
	if not playerEnt or not playerEnt.space then
		return 0
	end

	return playerEnt.space.spaceType
end

function TriggerUtils._getClientValueSpPowerFull(playerEnt, arg, extraArg)
	return playerEnt.spFullTs and Time.secondCache - playerEnt.spFullTs or 0
end

function TriggerUtils._getClientTimeWeatherBlock(playerEnt, arg, extraArg)
	local times, weather, block = unpack(extraArg)

	if times then
		-- block empty
	end

	local isTimeCheck = false
	local curTime = pg.timePeriod

	for _, time in ipairs(times) do
		if time == curTime then
			isTimeCheck = true

			break
		end
	end

	if not isTimeCheck then
		return 0
	end

	if weather ~= 0 and Utils.getCurWeatherId(pg.me) ~= weather then
		return 0
	end

	if block ~= 0 and pg.game.map.curBlockId ~= block then
		return 0
	end

	return 1
end

function TriggerUtils._getClientCatchPetLevelGap(playerEnt, arg, extraArg, triggerParams)
	triggerParams = triggerParams or {}

	local targetLevel = triggerParams[1] or 0
	local targetPrototypeId = triggerParams[2] or 0

	if arg and arg ~= 0 and arg ~= targetPrototypeId then
		return 0
	end

	local playerLevel = playerEnt.level or 0

	return targetLevel - playerLevel
end

function TriggerUtils._isNotJoinTeamSpeech(playerEnt, arg, extraArg)
	return playerEnt:isInTeam() and not playerEnt:isInSpeechChannel(playerEnt.uid) and 1 or 0
end

function TriggerUtils._isTeamSpeechKeyTalk(playerEnt, arg, extraArg)
	return playerEnt:isInTeam() and playerEnt:isInSpeechChannel(playerEnt.uid) and not pg.game.setting:getTeamSpeechFreeTalk() and 1 or 0
end

function TriggerUtils._isVehicleInteraction(playerEnt, arg, extraArg)
	return playerEnt:isRidingDandelion() and 1 or 0
end

function TriggerUtils._getCommonValueSpecialPetType(playerEnt, arg, extraArg)
	local TYPE_SHINY = 1
	local TYPE_HIGHT_STAGE = 2
	local type = extraArg or 0

	for _, petId in pairs(playerEnt.petPrepareList) do
		local petEnt = pg.getEntity(petId)
		local petInfo = petEnt and petEnt.petInfo

		if petInfo then
			if type == TYPE_SHINY and Utils.isLabelShiny(petInfo.label) then
				return 1
			elseif type == TYPE_HIGHT_STAGE and petInfo.stage >= 3 then
				return 1
			end
		end
	end

	return 0
end

function TriggerUtils._getCommonValueLeylineTreeActived(playerEnt, arg, extraArg)
	local treeInfo = playerEnt.leylineTreeInfoMap[arg]

	if not treeInfo then
		return 0
	end

	return treeInfo.leylineTreeLevel >= 0 and 1 or 0
end

function TriggerUtils._getCommonValueLeylineTreeLevel(playerEnt, arg, extraArg)
	local treeInfo = playerEnt.leylineTreeInfoMap[arg]

	if not treeInfo then
		return 0
	end

	if treeInfo.leylineTreeLevel > 0 then
		return treeInfo.leylineTreeLevel
	end

	return 0
end

function TriggerUtils._getCommonValueLeylineTreePoint(playerEnt, arg, extraArg)
	if arg == 0 then
		local point = 0

		for treeId, treeInfo in pairs(playerEnt.leylineTreeInfoMap) do
			point = point + treeInfo.leylineTreePoint
		end

		return point
	end

	local treeInfo = playerEnt.leylineTreeInfoMap[arg]

	if not treeInfo then
		return 0
	end

	return treeInfo.leylineTreePoint
end

function TriggerUtils._getCommonValuePlayerBodyType(playerEnt, arg, extraArg)
	local needGender, needBody = arg, extraArg or 0
	local genderBody = playerEnt.body
	local gender, body = math.floor(genderBody / 10), genderBody % 10

	if needGender ~= 0 and needGender ~= gender then
		return 0
	end

	if needBody ~= 0 and needBody ~= body then
		return 0
	end

	return 1
end

function TriggerUtils._getCommonValueReportCollectScore(playerEnt, arg, extraArg)
	if arg == 0 then
		return 0
	end

	local curPoint = playerEnt:getPetHandbookCountryTotalExp(arg)
	local reportingPoint = playerEnt:getPetHandbookCountryReportPoint(arg)

	return curPoint + reportingPoint
end

function TriggerUtils._getCommonValuePetDieCountInState(playerEnt, arg, extraArg)
	local state = playerEnt:isInCombat() and 1 or 2

	if arg ~= 0 and arg ~= state then
		return 0
	end

	local dieCount = 0

	for _, petEnt in pairs(playerEnt.petUnits or EMPTY_TABLE) do
		if petEnt:isDead() and petEnt.isBattlePet then
			dieCount = dieCount + 1
		end
	end

	return dieCount
end

function TriggerUtils._getCommonValueMaxMinusTeamAvgValue(playerEnt, arg, extraArg)
	local maxLevel = playerEnt:getMaxControlLevel()
	local avgLevel = Utils.getPetTeamAvgLevel(playerEnt)

	return maxLevel - avgLevel
end

function TriggerUtils._getCommonValueTargetMinusTeamAvgValue(playerEnt, arg, extraArg)
	local needLabel = ToInt(extraArg)
	local targetEntity = pg.getEntityByActorId(playerEnt.lockedActorId)

	if targetEntity ~= nil and needLabel ~= 0 and bit.band(targetEntity.label or 0, needLabel) == 0 then
		targetEntity = nil
	end

	local targetLevel = targetEntity and targetEntity.level or 0
	local avgLevel = Utils.getPetTeamAvgLevel(playerEnt)

	return targetLevel - avgLevel
end

if pg.component ~= "client" then
	function TriggerUtils._getCommonValueChestDistance(playerEnt, arg, extraArg)
		if extraArg == nil then
			return 0
		end

		if not playerEnt.space then
			return 0
		end

		local chestId = extraArg[1] or 0
		local distance = extraArg[2] or 0

		return Utils.isHasCheckPositionMatchChest(playerEnt, chestId, distance) and 1 or 0
	end
else
	function TriggerUtils._getCommonValueChestDistance(playerEnt, arg, extraArg)
		if extraArg == nil then
			return 0
		end

		if not playerEnt.space then
			return 0
		end

		local chestId = extraArg[1] or 0
		local distance = extraArg[2] or 0

		return Utils.isHasCheckPositionMatchChestFast(playerEnt, chestId, distance) and 1 or 0
	end
end

function TriggerUtils._getCommonValueBackstageTypeAdvantage(playerEnt, arg, extraArg)
	local hpPercent = extraArg or 50
	local lockedEnt = pg.getEntityByActorId(playerEnt.lockedActorId)

	if lockedEnt == nil then
		return 0
	end

	local curPetEnt = playerEnt:getCurPetEntity()
	local curPdd = curPetEnt and curPetEnt:getConfigData()

	if curPdd and Utils.getElementAgainstValue(curPdd.mainElementType, lockedEnt.elementTypes) > 1 then
		return 0
	end

	for _, petId in pairs(playerEnt.petPrepareList) do
		local petEnt = pg.getEntity(petId)
		local pdd = petEnt and petEnt:getConfigData()

		if pdd and Utils.getElementAgainstValue(pdd.mainElementType, lockedEnt.elementTypes) > 1 and hpPercent <= petEnt.actorCombatAttribute:getHpPercent() then
			return 1
		end
	end

	return 0
end

function TriggerUtils._getCommonValuePetBattleTag(playerEnt, arg, extraArg)
	if extraArg == nil then
		return 0
	end

	local count = 0
	local isNeedCur = ToBool(extraArg[1])
	local needTagName = extraArg[2] or ""

	for _, petId in pairs(playerEnt.petPrepareList) do
		if not isNeedCur or petId == playerEnt.curCombatPetId then
			local petInfo = playerEnt.pets[petId]
			local pdd = petInfo and petInfo:getConfigData()
			local tagName = pdd and pdd["function"] or ""

			if not needTagName or tagName == needTagName then
				count = count + 1
			end
		end
	end

	return count
end

function TriggerUtils._getCommonValueAttributeCompare(playerEnt, arg, extraArg)
	if extraArg == nil then
		return 0
	end

	local propIndexSelf, propIndexTarget, needPercent = extraArg[1], extraArg[2], extraArg[3]

	if not needPercent or needPercent <= 0 or needPercent > 100 then
		return 0
	end

	local attrNameSelf = Utils.getPropDisplayAttrName(propIndexSelf, true)
	local attrNameTarget = Utils.getPropDisplayAttrName(propIndexTarget, true)
	local attrIdSelf, attrIdTarget = AttributeConst[attrNameSelf], AttributeConst[attrNameTarget]

	if not attrIdSelf or not attrIdTarget then
		return 0
	end

	local curPetEnt = playerEnt:getCurPetEntity()
	local targetEnt = pg.getEntityByActorId(playerEnt.lockedActorId)

	if curPetEnt == nil or targetEnt == nil or targetEnt.actorCombatAttribute == nil then
		return 0
	end

	local selfValue = curPetEnt.actorCombatAttribute:getAttribValue(attrIdSelf)
	local targetValue = targetEnt.actorCombatAttribute:getAttribValue(attrIdTarget)

	if targetValue == 0 then
		return 0
	end

	local percent = selfValue / targetValue * 100

	return percent < needPercent and 1 or 0
end

function TriggerUtils._getCommonValueCoreCarryNum(playerEnt, arg, extraArg)
	local needTemplateId, needQuality = arg or 0, extraArg or 0

	return playerEnt.petStatsInfo:getCoreCarryCount(needTemplateId, needQuality)
end

function TriggerUtils._quizIsFinish(playerEnt, arg, extraArg)
	if getBit(playerEnt.quizIsFinish, arg) then
		return 1
	end

	return 0
end

function TriggerUtils._checkGamePlayTarget(playerEnt, arg, extraArg)
	local process = playerEnt.gamePlayProcessMap[arg]

	if process and process.isFinish == true then
		return 1
	end

	return 0
end

function TriggerUtils._checkHasPetRace(playerEnt, arg, extraArg)
	if playerEnt.petStatsInfo:hasRace(arg) == 1 then
		return 1
	end

	local tempPets = playerEnt.tempPets

	for id, data in pairs(tempPets) do
		local petData = PetPrototypeData[data.templateId]

		if petData ~= nil then
			local prototypeId = petData.refId or petData.baseFormPet

			if prototypeId == arg then
				return 1
			end
		end
	end

	return 0
end

function TriggerUtils._checkHasPetById(playerEnt, arg, extraArg)
	if playerEnt.petStatsInfo:hasTemplateId(arg) == 1 then
		return 1
	end

	local tempPets = playerEnt.tempPets

	for id, data in pairs(tempPets) do
		if data.templateId == arg then
			return 1
		end
	end

	return 0
end

function TriggerUtils._checkControlPetRace(playerEnt, arg, extraArg)
	local controlPet = playerEnt:getControllingPet()

	if controlPet == nil then
		return 0
	end

	local petData = controlPet:getConfigData()

	if petData ~= nil then
		local prototypeId = petData.refId or petData.baseFormPet

		if prototypeId == arg then
			return 1
		end
	end

	return 0
end

function TriggerUtils._checkControlPetRacePosition(playerEnt, arg, extraArg)
	if not playerEnt.space then
		return 0
	end

	local curPos = playerEnt:getPosition()
	local curSceneId = playerEnt.space.sceneId

	if not Utils.checkPositionMatch(curSceneId, curPos, arg, true) then
		return 0
	end

	return TriggerUtils._checkControlPetRace(playerEnt, extraArg)
end

function TriggerUtils._checkFinishBatchDialogue(playerEnt, arg, extraArg)
	if arg == nil or arg == 0 then
		return 0
	end

	return getBit(playerEnt.finishedBatchDialogueMap, arg) and 1 or 0
end

function TriggerUtils._checkRobEggLevelCondition(playerEnt, arg, extraArg)
	if not arg or not extraArg then
		return 0
	end

	if arg <= playerEnt.eggLv and extraArg <= playerEnt.secEggLv then
		return 1
	end

	return 0
end

function TriggerUtils._checkRobEggRankStar(playerEnt, arg, extraArg)
	if not extraArg then
		return 0
	end

	local robEggLev = extraArg[1] or 0
	local robEggSecLev = extraArg[2] or 0

	if robEggLev <= playerEnt.eggLv and robEggSecLev <= playerEnt.secEggLv then
		return playerEnt.eggStar
	end

	return 0
end

function TriggerUtils._getBossFinshLevel(playerEnt, arg, extraArg)
	if pg.component == "game" then
		if playerEnt and playerEnt.space and Utils.isSpaceBossRushDungeon(playerEnt.space.spaceType) then
			return playerEnt.space:getLevelPassedNum(arg)
		end
	elseif pg.component == "client" and pg.space and pg.space.levelState then
		local BossRushUtils = require("Utils.BossRushUtils")
		local levelId

		if arg then
			levelId = BossRushUtils.getLevelIdByTargetId(arg)
		end

		if levelId then
			return pg.space.levelState[levelId] == 1 and 1 or 0
		end

		local count = 0

		for _, state in pairs(pg.space.levelState) do
			if state == 1 then
				count = count + 1
			end
		end

		return count
	end

	return 0
end

function TriggerUtils._getActArkCarnPhotoPetNum(playerEnt, arg, extraArg)
	if pg.component == "game" then
		return playerEnt:arkCarnGetPhotePetProgress()
	elseif pg.component == "client" then
		-- block empty
	end
end

function TriggerUtils._getActStageOpened(playerEnt, arg, extraArg)
	if pg.component == "game" then
		return playerEnt:checkActStageOpen(arg, extraArg) and 1 or 0
	elseif pg.component == "client" then
		-- block empty
	end
end

function TriggerUtils._checkAreaInternal(playerEnt, arg, extraArg)
	if not Utils.isOverseas() then
		return 1
	end

	return 0
end

function TriggerUtils._getPetIsExchangePet(petInfo)
	if not petInfo or not petInfo.getObj then
		return 0
	end

	local player = petInfo:getObj()

	if not player or not player.getPetExchangeFromUid then
		return 0
	end

	return string.isNilOrEmpty(player:getPetExchangeFromUid(petInfo)) and 0 or 1
end

function TriggerUtils._checkPetMBTI(petInfo, arg, extraArg)
	local talentList = petInfo.talentList
	local mbtiDic = {}

	for _, talentInfo in pairs(talentList) do
		local templateId = talentInfo.templateId or 0

		if PetTalentData[templateId] and PetTalentData[templateId].mbti then
			mbtiDic[PetTalentData[templateId].mbti] = true
		end
	end

	for index, mbti in ipairs(extraArg) do
		if mbti ~= "" and not mbtiDic[mbti] then
			return 0
		end
	end

	return 1
end

function TriggerUtils._checkPetCombatActionNode(petInfo, arg, extraArg, triggerInfo)
	if extraArg == nil then
		return 0
	end

	local cfgId, cfgDuration, triggerCount = unpack(extraArg)
	local petEnt, triggerParams = unpack(triggerInfo)
	local arg = Utils.isTable(triggerParams) and triggerParams[1] or 0

	if arg ~= cfgId then
		return 0
	end

	local lastTriggerTime = 0
	local lastTriggerCnt = 0

	if not petEnt.triggerTimeStamps then
		petEnt.triggerTimeStamps = {}
	end

	if petEnt.triggerTimeStamps[arg] then
		lastTriggerTime, lastTriggerCnt = unpack(petEnt.triggerTimeStamps[arg])
	end

	if cfgDuration < Time.realSecondCache - lastTriggerTime then
		lastTriggerCnt = 0
	end

	if cfgId == arg then
		lastTriggerCnt = lastTriggerCnt + 1
		petEnt.triggerTimeStamps[arg] = {
			Time.realSecondCache,
			lastTriggerCnt
		}
	end

	return triggerCount <= lastTriggerCnt and 1 or 0
end

function TriggerUtils._checkPetScoreStage(petInfo, arg, extraArg)
	return extraArg <= petInfo.propertyScoreStage and 1 or 0
end

function TriggerUtils._checkPetBasePropertyList(extrArg, petInfo)
	for idx = 1, Const.BASE_PROPERTY_CNT do
		local needCnt = extrArg[idx]

		if needCnt and needCnt > 0 then
			local indLv = petInfo.basePropertyList[idx].indLv

			if indLv < needCnt then
				return false
			end
		end
	end

	return true
end

function TriggerUtils._checkKillWithTeam(extraArg, petIdList)
	local idType, idList, teamCount = unpack(extraArg)

	if teamCount ~= #petIdList then
		return
	end

	local idDic = {}

	for _, petId in ipairs(petIdList) do
		local petEnt = pg.getEntity(petId)
		local id = idType == 2 and petEnt.petInfo.petPrototypeId or petEnt.petInfo.basePetPrototypeId

		idDic[id] = true
	end

	for _, id in pairs(idList) do
		if not idDic[id] then
			return false
		end
	end

	return true
end

function TriggerUtils._checkPetCharacter(petInfo, arg, extraArg)
	return arg == petInfo.petPrototypeId and extraArg == petInfo.characterInfo.curCharacter and 1 or 0
end

function TriggerUtils._checkPetHasElement(petInfo, arg, extraArg)
	if not extraArg or type(extraArg) ~= "number" then
		return 0
	end

	if arg and arg > 0 then
		return arg == petInfo.petPrototypeId and petInfo:checkHasElementType(extraArg) and 1 or 0
	else
		return petInfo:checkHasElementType(extraArg) and 1 or 0
	end
end

function TriggerUtils._checkPetIsForm(petInfo, arg, extraArg)
	if not extraArg or type(extraArg) ~= "number" then
		return 0
	end

	if arg and arg > 0 then
		return arg == petInfo.petPrototypeId and extraArg == petInfo:getFormId() and 1 or 0
	else
		return extraArg == petInfo:getFormId() and 1 or 0
	end
end

function TriggerUtils._checkPetHasExplore(petInfo, arg, extraArg)
	if not extraArg or type(extraArg) ~= "table" then
		return 0
	end

	local explore = extraArg[1]

	if arg and arg > 0 then
		return arg == petInfo.petPrototypeId and petInfo:checkCanExplore(explore) and 1 or 0
	else
		return petInfo:checkCanExplore(explore) and 1 or 0
	end
end

function TriggerUtils._checkPetCpValue(petInfo, arg, extraArg)
	if not extraArg or type(extraArg) ~= "number" then
		return 0
	end

	if arg and arg > 0 then
		return arg == petInfo.petPrototypeId and extraArg <= petInfo:getCpValue() and 1 or 0
	else
		return extraArg <= petInfo:getCpValue() and 1 or 0
	end
end

function TriggerUtils._checkPetLab(petInfo, arg, extraArg)
	arg = arg or 0
	extraArg = extraArg or 0

	if arg > 0 and extraArg > 0 then
		return arg == petInfo.petPrototypeId and extraArg <= petInfo.label and 1 or 0
	elseif arg > 0 then
		return arg == petInfo.petPrototypeId and 1 or 0
	elseif extraArg > 0 then
		return extraArg <= petInfo.label and 1 or 0
	else
		return 0
	end
end

function TriggerUtils._checkPetKillStreak(extraArg, masterEntity)
	local curPetEnt = masterEntity:getCurPetEntity()

	if not curPetEnt then
		return false
	end

	if not masterEntity.killPuppetRecord then
		return false
	end

	local recordCnt = #masterEntity.killPuppetRecord
	local puppetProtoTypeId, cnt = unpack(extraArg)

	for i = 1, cnt do
		local index = recordCnt - (i - 1)

		if index < 1 then
			return false
		end

		local recordData = masterEntity.killPuppetRecord[index]

		if recordData.entId ~= curPetEnt.id then
			return false
		end

		if puppetProtoTypeId ~= 0 and puppetProtoTypeId ~= recordData.puppetProtoTypeId then
			return false
		end
	end

	return true
end

function TriggerUtils._checkPetKillStreakForm(extraArg, masterEntity)
	local curPetEnt = masterEntity:getCurPetEntity()

	if not curPetEnt then
		return false
	end

	if not masterEntity.killPuppetRecord then
		return false
	end

	local recordCnt = #masterEntity.killPuppetRecord
	local puppetFormId, cnt = unpack(extraArg)

	for i = 1, cnt do
		local index = recordCnt - (i - 1)

		if index < 1 then
			return false
		end

		local recordData = masterEntity.killPuppetRecord[index]

		if recordData.entId ~= curPetEnt.id then
			return false
		end

		if puppetFormId ~= 0 and puppetFormId ~= Utils.Utils.getBasePetPrototypeId(recordData.puppetProtoTypeId) then
			return false
		end
	end
end

function TriggerUtils._checkPetSwitchTime(extraArg, petEnt)
	return true
end

function TriggerUtils._checkPetAIMsg(extraArg, eventId)
	return extraArg == eventId
end

function TriggerUtils._checkPetAIMsgSpecial(extraArg, objectPetPrototypeId)
	if not Utils.isTable(extraArg) then
		return false
	end

	local propVal = extraArg[1]
	local propName = extraArg[2]

	if propName == nil then
		return false
	end

	if propName == "isHuman" then
		return objectPetPrototypeId == -1
	else
		local data = PetPrototypeData[objectPetPrototypeId]

		if not data then
			return false
		end

		local val = data[propName]

		if Utils.isTable(val) then
			return table.contains(val, propVal)
		else
			return val == propVal
		end
	end

	return false
end

function TriggerUtils._returnTrue(playerEnt, arg, extraArg)
	return 1
end

function TriggerUtils._dayRobEggRetreat(playerEnt, arg, extraArg)
	return playerEnt.dayRetreat or 0
end

function TriggerUtils._isRobEggUndergraound(playerEnt, arg, extraArg)
	if playerEnt.space.spaceType == Const.SPACE_TYPE_ROBEGG_UNDERGROUND then
		return 1
	end

	return 0
end

function TriggerUtils._isControlEgg(playerEnt, arg, extraArg)
	if playerEnt.isControllingEgg and playerEnt:isControllingEgg() then
		return 1
	end

	return 0
end

function TriggerUtils._checkActOneTaskGroupCompleted(playerEnt, arg, extraArg)
	local activityId = arg or 0
	local taskGroups = extraArg or {}
	local taskGroupComps = 0

	for _, taskGruopId in ipairs(taskGroups) do
		if ActivityUtils.checkActTaskGruopCompleteed(playerEnt, activityId, taskGruopId) then
			taskGroupComps = taskGroupComps + 1
		end
	end

	return taskGroupComps
end

function TriggerUtils._checkActAllTaskGroupCompleted(playerEnt, arg, extraArg)
	local activityId = arg or 0
	local taskGroups = extraArg or {}

	if lume.tableLength(taskGroups) == 0 then
		return 0
	end

	for _, taskGruopId in ipairs(taskGroups) do
		if not ActivityUtils.checkActTaskGruopCompleteed(playerEnt, activityId, taskGruopId) then
			return 0
		end
	end

	return 1
end

function TriggerUtils._isSpecialTrainChapterFinished(playerEnt, arg, extraArg)
	local chapterId = arg or -1

	if chapterId < 0 then
		return 0
	end

	if playerEnt.specialTrainMapMap:isGetChapterReward(chapterId) then
		return 1
	end

	if playerEnt.specialTrainMapMap:isUnlocked(chapterId + 1) then
		return 1
	end

	return 0
end

function TriggerUtils._getBossScore(playerEnt, arg, extraArg)
	return playerEnt.lastBossRushScore
end

function TriggerUtils._getPetRankUpTimes(playerEnt, arg, extraArg)
	local petPrototypeId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_PET_RANKUP_TIMES, petPrototypeId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getAppearnceCount(playerEnt, arg, extraArg)
	local type = arg or 0
	local appearanceType = extraArg or 0
	local count = 0

	if type == 0 then
		count = ItemUtils.getPetAppearanceCount(playerEnt)

		if appearanceType == 0 then
			count = count + lume.tableLength(playerEnt.appearanceInfo)
		else
			for configId, _ in pairs(playerEnt.appearanceInfo) do
				local data = AppearanceData[configId]

				if data and data.type == appearanceType then
					count = count + 1
				end
			end
		end
	elseif type == 1 then
		if appearanceType == 0 then
			count = count + lume.tableLength(playerEnt.appearanceInfo)
		else
			for configId, _ in pairs(playerEnt.appearanceInfo) do
				local data = AppearanceData[configId]

				if data and data.type == appearanceType then
					count = count + 1
				end
			end
		end
	elseif type == 2 then
		count = ItemUtils.getPetAppearanceCount(playerEnt)
	end

	return count
end

function TriggerUtils._getExploreMapCover(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) or #extraArg ~= 2 then
		return 0
	end

	local mapId, rate = unpack(extraArg)

	if mapId ~= 0 then
		return rate <= Utils.getBlockCatchedRate(playerEnt, mapId) and 1 or 0
	end

	local matchCount = 0

	for k, _ in pairs(playerEnt.blockCatchedPetMap) do
		if rate <= Utils.getBlockCatchedRate(playerEnt, k) then
			matchCount = matchCount + 1
		end
	end

	return matchCount
end

function TriggerUtils._getCoreQualityNum(playerEnt, arg, extraArg)
	local quality = arg or 0
	local count = 0
	local playerBag = ItemUtils.getTypedBag(playerEnt, ItemConst.INV_TYPE_PLAYER)

	if not playerBag then
		return count
	end

	for _, item in playerBag:items() do
		if ItemUtils.isCoreCarryItem(item.id) and (quality == 0 or (ItemData[item.id] and ItemData[item.id].quality or nil) == quality) then
			count = count + 1
		end
	end

	return count
end

function TriggerUtils._getUpgradeCoreQualityCount(playerEnt, arg, extraArg)
	local quality = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_UPGRADE_CORE_QUALITY_COUNT, quality)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getRuneQualityNum(playerEnt, arg, extraArg)
	local quality = arg or 0
	local count = 0
	local playerBag = ItemUtils.getTypedBag(playerEnt, ItemConst.INV_TYPE_PLAYER)

	if not playerBag then
		return count
	end

	for _, item in playerBag:items() do
		if ItemUtils.isAssistCarryItem(item.id) and (quality == 0 or (ItemData[item.id] and ItemData[item.id].quality or nil) == quality) then
			count = count + 1
		end
	end

	return count
end

function TriggerUtils._getReduceEnergyTotal(playerEnt, arg, extraArg)
	local type = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_REDUCE_ENERGY_TOTAL, type)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getObtainRewardTotal(playerEnt, arg, extraArg)
	if extraArg == nil or type(extraArg) ~= "table" then
		return 0
	end

	local totalCount = 0

	for _, dropId in pairs(extraArg) do
		local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_OBTAIN_REWARD_TOTAL, dropId)

		if count then
			totalCount = totalCount + count
		end
	end

	return totalCount
end

function TriggerUtils._getPetUpgradeStar(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) or #extraArg ~= 2 then
		return 0
	end

	local petPrototypeId, stage = unpack(extraArg)

	return playerEnt.petStatsInfo:getStarCountMin(petPrototypeId, stage)
end

function TriggerUtils._getSimulationTrainPass(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	if #extraArg == 1 and extraArg[1] == 0 then
		local totalCount = 0

		for _, v in pairs(playerEnt.rogueLevelPassCnt) do
			totalCount = totalCount + v
		end

		return totalCount
	end

	local totalCount = 0

	for _, levelId in pairs(extraArg) do
		totalCount = totalCount + (playerEnt.rogueLevelPassCnt[levelId] or 0)
	end

	return totalCount
end

function TriggerUtils._getSimulationTrainPlay(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	if #extraArg == 1 and extraArg[1] == 0 then
		local totalCount = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_PLAY, 0)

		if not totalCount then
			return 0
		end

		return totalCount
	end

	local totalCount = 0

	for _, levelId in pairs(extraArg) do
		local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_PLAY, levelId)

		if count then
			totalCount = totalCount + count
		end
	end

	return totalCount
end

function TriggerUtils._checkNpcDuelClear(playerEnt, arg, extraArg)
	if not playerEnt or not playerEnt.checkNpcDuelClear then
		return 0
	end

	return playerEnt:checkNpcDuelClear(arg, extraArg)
end

function TriggerUtils._getNpcDuelClearCount(playerEnt, arg, extraArg)
	if not playerEnt or not playerEnt.getNpcDuelClearCount then
		return 0
	end

	local variantId = 0
	local tag = 0

	if type(extraArg) == "table" then
		variantId = extraArg[1] or 0
		tag = extraArg[2] or 0
	else
		variantId = extraArg or 0
	end

	return playerEnt:getNpcDuelClearCount(arg, variantId, tag)
end

function TriggerUtils._getRogueExchangeBox(playerEnt, arg, extraArg)
	local dungeonId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_ROGUE_EXCHANGE_BOX, dungeonId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getRobeGGRetreatCount(playerEnt, arg, extraArg)
	local sceneId = arg or 0
	local count = 0

	local function checkHardLevel(curLevel)
		if extraArg == nil then
			return true
		end

		for _, hardLv in pairs(extraArg) do
			if curLevel == hardLv then
				return true
			end
		end

		return false
	end

	local countInfo = playerEnt.triggerMap.triggerCurrentCountInfo[TriggerConst.TRIGGER_TARGET_ROBEGG_RETREAT_COUNT] or {}

	for key, curCount in pairs(countInfo) do
		local curSceneId = math.floor(key / 1000)
		local curHardLv = key % 1000 - 100

		if (sceneId == 0 or sceneId == curSceneId) and (not extraArg or checkHardLevel(curHardLv)) then
			count = count + curCount
		end
	end

	return count
end

function TriggerUtils._getRobeGGPlayCount(playerEnt, arg, extraArg)
	local sceneId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_ROBEGG_PLAY_COUNT, sceneId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getBadgeCollectionState(playerEnt, arg, extraArg)
	if playerEnt.isAwaitingOpenReward == false then
		return 1
	end

	return 2
end

function TriggerUtils._checkSubmittedEgg(playerEnt, arg, extraArg)
	return playerEnt.isSubmittedEgg
end

function TriggerUtils._getMatchGains(playerEnt, arg, extraArg)
	return playerEnt.achievedTeamProfit
end

function TriggerUtils._getOwnCoreCarryCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local coreCarryQuality, coreCarryLevel = unpack(extraArg)

	if coreCarryQuality == nil or coreCarryLevel == nil then
		return 0
	end

	local count = 0
	local playerBag = ItemUtils.getTypedBag(playerEnt, ItemConst.INV_TYPE_PLAYER)

	if not playerBag then
		return count
	end

	for _, item in playerBag:items() do
		if ItemUtils.isCoreCarryItem(item.id) and (coreCarryQuality == 0 or (ItemData[item.id] and ItemData[item.id].quality or nil) == coreCarryQuality) then
			local levelMatch = false
			local coreCarryInfo = ItemUtils.getPropertyWithType(item)

			if coreCarryInfo and coreCarryInfo:isValid() then
				local lv, _ = coreCarryInfo:getLevelAndExp()

				if coreCarryLevel <= lv then
					levelMatch = true
				end
			end

			if levelMatch then
				count = count + 1
			end
		end
	end

	return count
end

function TriggerUtils._getActivateCoreCarryEffectCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local effectStage = extraArg[1]

	if not effectStage then
		return 0
	end

	local count = 0
	local playerBag = ItemUtils.getTypedBag(playerEnt, ItemConst.INV_TYPE_PLAYER)

	if not playerBag then
		return count
	end

	for _, item in playerBag:items() do
		if ItemUtils.isCoreCarryItem(item.id) then
			local coreCarryInfo = ItemUtils.getPropertyWithType(item)

			if coreCarryInfo and coreCarryInfo.getActiveEnergyEffectCount then
				local stage = coreCarryInfo:getActiveEnergyEffectCount(playerEnt)

				if effectStage <= stage then
					count = count + 1
				end
			end
		end
	end

	return count
end

function TriggerUtils._getObtainEggItemsCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local itemIdList = extraArg[1]
	local quality = extraArg[2]
	local itemType = extraArg[3]

	if not itemIdList or not quality or not itemType then
		return 0
	end

	local sceneId = arg or 0
	local totalCount = 0

	if #itemIdList == 1 and itemIdList[1] == 0 then
		if sceneId == 0 then
			for _, itemInfo in pairs(playerEnt.eggGetItemCountInfo) do
				for itemId, itemCount in pairs(itemInfo) do
					local itemData = ItemData[itemId] or {}

					if itemType == itemData.type and quality == itemData.quality then
						totalCount = totalCount + itemCount
					end
				end
			end

			return totalCount
		else
			for itemId, itemCount in pairs(playerEnt.eggGetItemCountInfo[sceneId] or EMPTY_TABLE) do
				local itemData = ItemData[itemId] or {}

				if itemType == itemData.type and quality == itemData.quality then
					totalCount = totalCount + itemCount
				end
			end

			return totalCount
		end
	elseif sceneId == 0 then
		for _, itemId in pairs(itemIdList) do
			for _, recordedItemInfo in pairs(playerEnt.eggGetItemCountInfo) do
				local itemData = ItemData[itemId] or {}

				if itemType == itemData.type and quality == itemData.quality then
					totalCount = totalCount + (recordedItemInfo[itemId] or 0)
				end
			end
		end

		return totalCount
	else
		local recordedItemInfo = playerEnt.eggGetItemCountInfo[sceneId] or {}

		for _, itemId in pairs(itemIdList) do
			local itemData = ItemData[itemId] or {}

			if itemType == itemData.type and quality == itemData.quality then
				totalCount = totalCount + (recordedItemInfo[itemId] or 0)
			end
		end

		return totalCount
	end
end

function TriggerUtils._getSimulationTrainUnlockedMerits(playerEnt, arg, extraArg)
	local count = 0

	for k, v in pairs(playerEnt.rogueTalentLevelUnlock) do
		if v then
			count = count + 1
		end
	end

	return count
end

function TriggerUtils._getOutfitCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local function hasAppearanceSuit(configId)
		local data = SuitData[configId]

		if not data then
			return false
		end

		for _, id in ipairs(data.appearanceList) do
			if playerEnt.appearanceInfo[id] == nil then
				return false
			end
		end

		for _, id in ipairs(data.jewelryList or EMPTY_TABLE) do
			if playerEnt.appearanceInfo[id] == nil then
				return false
			end
		end

		return true
	end

	if #extraArg == 1 and extraArg[1] == 0 then
		local count = 0

		for configId, _ in pairs(SuitData) do
			if hasAppearanceSuit(configId) then
				count = count + 1
			end
		end

		return count
	end

	local totalCount = 0

	for _, configId in pairs(extraArg) do
		if hasAppearanceSuit(configId) then
			totalCount = totalCount + 1
		end
	end

	return totalCount
end

function TriggerUtils._getEmoteFluetMeetFriendsCount(playerEnt, arg, extraArg)
	local socialType = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_EMOTE_FLUET_MEET_FRIENDS, socialType)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getEmoteDoneCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local configIdList = extraArg[1] or {}

	if type(configIdList) == "number" then
		configIdList = {
			configIdList
		}
	end

	local actionTypeList = extraArg[2]

	if type(actionTypeList) == "number" then
		actionTypeList = {
			actionTypeList
		}
	end

	local noActionTypeLimit = not actionTypeList or #actionTypeList == 0
	local actionTypeSet = {}

	if not noActionTypeLimit then
		for _, actionType in ipairs(actionTypeList) do
			if actionType == -1 then
				noActionTypeLimit = true

				break
			end

			actionTypeSet[actionType] = true
		end
	end

	local allConfigIds = #configIdList == 1 and configIdList[1] == 0

	if allConfigIds and noActionTypeLimit then
		return playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_EMOTE_DONE_COUNT, 0) or 0
	end

	local function matchActionType(configId)
		if noActionTypeLimit then
			return true
		end

		local actionData = AppearanceActionData[configId]
		local interactAction = actionData and actionData.interactAction or -1

		return actionTypeSet[interactAction] == true
	end

	local totalCount = 0

	if allConfigIds then
		local emoteCountInfo = playerEnt.triggerMap.triggerCurrentCountInfo[TriggerConst.TRIGGER_TARGET_EMOTE_DONE_COUNT] or {}

		for configId, count in pairs(emoteCountInfo) do
			if matchActionType(configId) then
				totalCount = totalCount + count
			end
		end
	else
		for _, configId in ipairs(configIdList) do
			if matchActionType(configId) then
				local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_EMOTE_DONE_COUNT, configId)

				if count then
					totalCount = totalCount + count
				end
			end
		end
	end

	return totalCount
end

function TriggerUtils._getQuestTypeDoneCount(playerEnt, arg, extraArg)
	if extraArg == nil or not Utils.isTable(extraArg) then
		return 0
	end

	local catalogIdList = extraArg[1] or {
		0
	}

	if not Utils.isTable(catalogIdList) then
		return 0
	end

	local questIds = extraArg[2] or {
		0
	}

	if not Utils.isTable(questIds) then
		return 0
	end

	local allCatalogs = #catalogIdList == 1 and catalogIdList[1] == 0
	local allQuests = #questIds == 1 and questIds[1] == 0
	local totalCount = 0

	if allCatalogs then
		for catalogId, questCountInfo in pairs(playerEnt.parentQuestFinishCountInfo or EMPTY_TABLE) do
			if allQuests then
				for _, count in pairs(questCountInfo) do
					totalCount = totalCount + count
				end
			else
				for _, questId in ipairs(questIds) do
					totalCount = totalCount + (questCountInfo[questId] or 0)
				end
			end
		end
	else
		for _, catalogId in ipairs(catalogIdList) do
			local questCountInfo = (playerEnt.parentQuestFinishCountInfo or EMPTY_TABLE)[catalogId] or {}

			if allQuests then
				for _, count in pairs(questCountInfo) do
					totalCount = totalCount + count
				end
			else
				for _, questId in ipairs(questIds) do
					totalCount = totalCount + (questCountInfo[questId] or 0)
				end
			end
		end
	end

	return totalCount
end

function TriggerUtils._getSpecialTrainChapterFinishedCount(playerEnt, arg, extraArg)
	local chapterId = arg or 0

	if chapterId ~= 0 then
		return QuestCommonUtils.getSpecialTrainChapterMainQuestCompleteCount(playerEnt, chapterId)
	end

	local count = 0

	for id in pairs(playerEnt.specialTrainMapMap) do
		count = count + QuestCommonUtils.getSpecialTrainChapterMainQuestCompleteCount(playerEnt, id)
	end

	return count
end

function TriggerUtils._getHomeOrderQuantityCount(playerEnt, arg, extraArg)
	local orderQuality = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_HOME_ORDERS_DONE, orderQuality)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getEmoteTriggerTimes(playerEnt, arg, extraArg)
	local socialType = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_EMOTE_TRIGGER_TIMES, socialType)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getCommonValueReportCatchResultsTotal(playerEnt, arg, extraArg)
	local basePetPrototypeId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_REPORT_CATCH_RESULTS_TOTAL, basePetPrototypeId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getCommonValueCollectOnlyPetNum(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getCollectOnlyPetCount(arg or 0, extraArg)
end

function TriggerUtils._getReduceMoneyTotal(playerEnt, arg, extraArg)
	local moneyType = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_REDUCE_MONEY_TOTAL, moneyType)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getUseItemTotal(playerEnt, arg, extraArg)
	local itemId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_USE_ITEM_TOTAL, itemId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getEggTotal(playerEnt, arg, extraArg)
	local sType = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_GET_EGG_TOTAL, sType)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getMoneyHomeTotal(playerEnt, arg, extraArg)
	local itemId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_GET_MONEY_HOME_TOTAL, itemId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getCatchRainbowPetCount(playerEnt, arg, extraArg)
	local petPrototypeId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_CATCH_RAINBOW_PET, petPrototypeId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._getSandboxQuestEvent(playerEnt, arg, extraArg)
	local sandboxId = arg or 0
	local eventId = extraArg or 0

	return playerEnt:getSandboxFinishQuestEvent(sandboxId, eventId) and 1 or 0
end

function TriggerUtils._checkActSpecTasksCompleted(playerEnt, arg, extraArg)
	local activityId = arg or 0
	local taskIds = extraArg or {}

	if not Utils.isTable(taskIds) then
		return 0
	end

	if lume.tableLength(taskIds) == 0 then
		return 0
	end

	local completeTaskNum = 0

	for _, taskId in ipairs(taskIds) do
		if ActivityUtils.checkActTaskCompleteed(playerEnt, taskId) then
			completeTaskNum = completeTaskNum + 1
		end
	end

	return completeTaskNum
end

function TriggerUtils._checkActSpecTasksRecved(playerEnt, arg, extraArg)
	local activityId = arg or 0
	local taskIds = extraArg or {}

	if not Utils.isTable(taskIds) then
		return 0
	end

	if lume.tableLength(taskIds) == 0 then
		return 0
	end

	local recvedTaskNum = 0

	for _, taskId in ipairs(taskIds) do
		if ActivityUtils.checkActTaskRecved(playerEnt, taskId) then
			recvedTaskNum = recvedTaskNum + 1
		end
	end

	return recvedTaskNum
end

function TriggerUtils._getActContinueLoginNum(playerEnt, arg, extraArg)
	local activityId = arg or 0
	local loginNum = 0
	local actType = GameEventData and GameEventData[activityId] and GameEventData[activityId].eventType
	local actData = ActivityUtils.getActivityData(playerEnt, actType)

	if actData and actData.getContinueTotalSignNum then
		loginNum = actData:getContinueTotalSignNum()
	end

	return loginNum
end

function TriggerUtils._checkControlPet(playerEnt, arg, extraArg)
	if not extraArg or not Utils.isTable(extraArg) then
		return 0
	end

	local basePetPrototypeId = extraArg[1]
	local patternType = extraArg[2] or 0
	local petInfo = getCurrentBattlePetInfo(playerEnt)

	if not petInfo then
		return 0
	end

	if (patternType == 0 or patternType == playerEnt.controlState) and basePetPrototypeId == petInfo.basePetPrototypeId then
		return 1
	end

	return 0
end

function TriggerUtils._checkUIIsIpen(playerEnt, arg, extraArg)
	local panelId = arg or 0
	local uiCtrl = pg.global.ui:tryGetCtrlByUid(panelId)

	if uiCtrl == nil then
		return 0
	end

	if uiCtrl:checkUIVisible() then
		return 1
	end

	return 0
end

function TriggerUtils._getBattlePassGear(playerEnt, arg, extraArg)
	return playerEnt and playerEnt.activityBattlePass and playerEnt.activityBattlePass.bpGear or 0
end

function TriggerUtils.getBattlePassLevel(playerEnt, arg, extraArg)
	return playerEnt and playerEnt.activityBattlePass and playerEnt.activityBattlePass.bpLevel or 0
end

function TriggerUtils._checkHasBadge(playerEnt, arg, extraArg)
	local badgeId = arg or 0

	return playerEnt.badgeStatusMap[badgeId] == Const.BADGE_STATUS.Complete and 1 or 0
end

function TriggerUtils._checkHasBadgeByType(playerEnt, arg, extraArg)
	if not extraArg then
		return 0
	end

	local badgeType = extraArg[1] or 0
	local badgeSubType = extraArg[2] or 0
	local positionType = extraArg[3] or 0
	local qualityList = extraArg[4]
	local qualitySet

	if type(qualityList) == "table" and #qualityList > 0 then
		qualitySet = {}

		for _, q in ipairs(qualityList) do
			qualitySet[q] = true
		end
	end

	local count = 0

	for badgeId, status in pairs(playerEnt.badgeStatusMap) do
		if status == Const.BADGE_STATUS.Complete then
			local badgeData = PlayerBadgeData[badgeId]

			if badgeData then
				local badgeLayoutData = PlayerBadgeLayoutData[badgeData.group]

				if badgeLayoutData and (badgeType == 0 or badgeLayoutData.mainType == badgeType) and (badgeSubType == 0 or badgeLayoutData.subType == badgeSubType) and (positionType == 0 or badgeLayoutData.positionType == positionType) and (not qualitySet or qualitySet[badgeData.quality]) then
					count = count + 1
				end
			end
		end
	end

	return count
end

function TriggerUtils._checkHasBadges(playerEnt, arg, extraArg)
	local count = 0

	for _, badgeId in ipairs(extraArg or EMPTY_TABLE) do
		if playerEnt.badgeStatusMap[badgeId] == Const.BADGE_STATUS.Complete then
			count = count + 1
		end
	end

	return count
end

function TriggerUtils._checkFlowerLargeNumber(playerEnt, arg, extraArg)
	local infoMap = playerEnt.leylineFlowerInfoMap
	local curLargeAreaId

	if pg.component == "client" then
		curLargeAreaId = pg.game and pg.game.map and pg.game.map.curBlockId
	else
		curLargeAreaId = Utils.getCurLargeAreaBlockId(playerEnt)
	end

	if not infoMap or not curLargeAreaId or curLargeAreaId == 0 then
		return 0
	end

	local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
	local staticId = LeylineFlowerUtils.getStaticIdByBlockId(playerEnt.sceneId, curLargeAreaId)
	local info = staticId and infoMap[staticId]

	if not info then
		return 0
	end

	if arg == 1 then
		return info.pendingCaptureBloomCount or 0
	end

	return 0
end

function TriggerUtils._checkRiftReward(playerEnt, arg, extraArg)
	local count = 0

	if pg.component == "client" then
		if playerEnt.canGetReward == nil or arg == nil then
			return count
		end

		if playerEnt.canGetReward then
			local levelId = playerEnt:canGetReward(arg)

			if levelId and levelId ~= 0 then
				count = 1
			end
		end

		return count
	else
		return 1
	end
end

function TriggerUtils._getCommonValueHasPetUpdateSkillByEthnic(playerEnt, arg, extraArg)
	return 0
end

function TriggerUtils._getCommonValueHasPetUpdateSkillBySingle(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getSkillUpgradeIndividualCount(arg or 0, extraArg)
end

function TriggerUtils._checkMonthcardActivated(playerEnt, arg, extraArg)
	return Utils.monthCardIsOpen(playerEnt) and 1 or 0
end

function TriggerUtils._getCommonValueHomeCurrentItemNum(playerEnt, arg, extraArg)
	local itemId = arg or 0

	return ItemUtils.getHomeBagAndWarehouseItemCount(playerEnt, itemId)
end

function TriggerUtils._getCommonValueHomeRandomProduce(playerEnt)
	if not playerEnt:isInSelfHomeland() then
		return 0
	end

	for itemId, itemInfo in pairs(HomelandFormulaRandomReverseData) do
		if itemInfo.rType ~= 0 and ItemUtils.getWareHouseItemCount(playerEnt, itemId) > 0 then
			return 1
		end
	end

	return 0
end

function TriggerUtils._getCommonValueHomeItemNum(playerEnt, arg, extraArg)
	local itemId = arg or 0
	local count = playerEnt.triggerMap:getTriggerCurrentCount(TriggerConst.TRIGGER_TARGET_HOME_ITEM_NUM, itemId)

	if not count then
		return 0
	end

	return count
end

function TriggerUtils._checkPlayerChannel(playerEnt, arg, extraArg)
	local channels = extraArg or {}

	if not Utils.isTable(channels) then
		return 0
	end

	local playerChannel = ""

	if pg.component == "game" then
		playerChannel = playerEnt.loginChannelId
	elseif pg.component == "client" then
		local sdkManager = pg.global and pg.global.sdkManager

		playerChannel = sdkManager and sdkManager:getPkgChannel() or ""
	end

	if lume.findInList(channels, playerChannel) then
		return 1
	end

	return 0
end

function TriggerUtils._checkPlayerNotChannel(playerEnt, arg, extraArg)
	local channels = extraArg or {}

	if not Utils.isTable(channels) then
		return 0
	end

	local playerChannel = ""

	if pg.component == "game" then
		playerChannel = playerEnt.loginChannelId
	elseif pg.component == "client" then
		local sdkManager = pg.global and pg.global.sdkManager

		playerChannel = sdkManager and sdkManager:getPkgChannel() or ""
	end

	if not lume.findInList(channels, playerChannel) then
		return 1
	end

	return 0
end

function TriggerUtils._checkFirstCharge(playerEnt, arg, extraArg)
	for packageId, firstPay in pairs(playerEnt.PcFirstPayPassed or {}) do
		if firstPay then
			local payCfg = PayProductData[packageId]

			if payCfg and payCfg.type ~= 4 then
				return 1
			end
		end
	end

	return 0
end

function TriggerUtils._checkInAreaTime(playerEnt, arg, extraArg)
	local areaNo = Utils.getServerArea()

	if extraArg then
		local begTm = extraArg[1] and extraArg[1][tostring(areaNo)]
		local endTm = extraArg[2] and extraArg[2][tostring(areaNo)]

		if TimeUtils.isInRangeTimestamp(begTm, endTm) then
			return 1
		end
	end

	return 0
end

function TriggerUtils._checkInSpending(playerEnt, arg, extraArg)
	return playerEnt.PcPayTotalMoney
end

function TriggerUtils._checkAreaBlock(playerEnt, blockId, extraArg)
	local curLargeAreaBlockId = 0

	if pg.component == "game" then
		curLargeAreaBlockId = Utils.getCurLargeAreaBlockId(playerEnt) or 0
	elseif pg.component == "client" then
		curLargeAreaBlockId = pg.game and pg.game.map and pg.game.map.curBlockId or 0
	end

	return curLargeAreaBlockId == blockId and 1 or 0
end

function TriggerUtils._getPetBoxRemainderNum(playerEnt, arg, extraArg)
	return playerEnt.petBoxMap:getValidEmptySlot()
end

function TriggerUtils._isControlPetStageMatch(playerEnt, arg, extraArg)
	if not playerEnt:isControllingPet() then
		return 0
	end

	local petInfo = getCurrentBattlePetInfo(playerEnt)

	if not petInfo then
		return 0
	end

	return petInfo.stage == arg and 1 or 0
end

function TriggerUtils._checkKnowledgeUnlock(playerEnt, arg, extraArg)
	local knowledgeId = arg or 0

	if knowledgeId == 0 then
		return 0
	end

	return playerEnt.unlockedKnowledgeMap[knowledgeId] ~= nil and 1 or 0
end

function TriggerUtils._isControlPetLabelMatch(playerEnt, arg, extraArg)
	if not playerEnt:isControllingPet() then
		return 0
	end

	local petInfo = getCurrentBattlePetInfo(playerEnt)

	if not petInfo then
		return 0
	end

	return petInfo.label == arg and 1 or 0
end

function TriggerUtils._isControlPetEthnicGroupMatch(playerEnt, arg, extraArg)
	local controlPet = playerEnt:getControllingPet()

	if controlPet == nil then
		return 0
	end

	extraArg = extraArg or {}

	return lume.findInList(extraArg, controlPet:getConfigData().ethnicGroup) ~= nil and 1 or 0
end

function TriggerUtils._checkExplorePetState(playerEnt, arg, extraArg)
	if not extraArg then
		return 0
	end

	local explorePetId = playerEnt.petExploreList[extraArg] or ""

	return explorePetId ~= "" and 1 or 0
end

function TriggerUtils._checkBossRushKillBossNum(playerEnt, arg, extraArg)
	local tmpSpace = playerEnt.space

	if not tmpSpace then
		return 0
	end

	if not tmpSpace:isBossRush() then
		return 0
	end

	local resNum = 0

	for dgId, num in ipairs(tmpSpace.levelKillBossTimes) do
		resNum = resNum + 1
	end

	return resNum
end

function TriggerUtils._checkDungeonFinishTimes(playerEnt, arg, extraArg)
	if not extraArg then
		return 0
	end

	return playerEnt:getPassRecordNumByType(extraArg)
end

function TriggerUtils._checkSeasonRobEggCollectPoint(playerEnt, arg, extraArg)
	if arg == nil then
		return 0
	end

	local caseId = arg
	local caseInfo = playerEnt.showCases and playerEnt.showCases[caseId] or nil

	if not caseInfo then
		return 0
	end

	return caseInfo.allPoint
end

function TriggerUtils._checkQuestClueAcceptCheckByChapter(playerEnt, arg, extraArg)
	local chapterId = arg

	if not chapterId then
		return 0
	end

	local questMainConfigData = QuestMain[chapterId]

	if not questMainConfigData then
		return 0
	end

	for _, sectionInfo in pairs(questMainConfigData) do
		local questGroupId = sectionInfo.questGroupId

		if questGroupId and QuestCommonUtils.questInAccept(playerEnt, questGroupId) then
			return 1
		end

		local gotoClueQuestId = sectionInfo.gotoClueQuestId

		if gotoClueQuestId and QuestCommonUtils.questInAccept(playerEnt, gotoClueQuestId) and QuestCommonUtils.questInClueReveal(playerEnt, gotoClueQuestId) then
			return 1
		end
	end

	return 0
end

function TriggerUtils._getActivityTaskState(playerEnt, arg, extraArg)
	local taskId = arg or 0

	if taskId == 0 then
		return 0
	end

	return ActivityUtils.getActTaskState(playerEnt, taskId) or 0
end

function TriggerUtils._checkPhotoSubjectArea(extraArg, triggerParams)
	if type(extraArg) ~= "table" or type(triggerParams) ~= "table" then
		return false
	end

	local rtMask = triggerParams[1] or 0
	local cfgMaskList = extraArg[1]

	if type(cfgMaskList) == "table" and #cfgMaskList > 0 then
		local matched = false

		for _, cfgMask in ipairs(cfgMaskList) do
			if cfgMask == 0 or bit.band(rtMask, cfgMask) == cfgMask then
				matched = true

				break
			end
		end

		if not matched then
			return false
		end
	end

	local cfgScenes = extraArg[2]

	if type(cfgScenes) == "table" and #cfgScenes > 0 then
		local rtScene = triggerParams[2] or 0

		for _, sid in ipairs(cfgScenes) do
			if sid == rtScene then
				return true
			end
		end

		return false
	end

	return true
end

function TriggerUtils._checkPhotoPosition(extraArg, sceneId, position)
	if type(extraArg) ~= "table" or position == nil then
		return false
	end

	local targetSceneId = tonumber(extraArg[1])
	local targetPosition = extraArg[2]
	local targetRange = math.max(tonumber(extraArg[3]) or 0, 0)

	if targetSceneId == nil or targetPosition == nil or targetSceneId ~= tonumber(sceneId) then
		return false
	end

	return Vector3.SqrDistance(position, targetPosition) <= targetRange * targetRange
end

function TriggerUtils._checkPhotoByPosAndObject(extraArg, triggerParams)
	if type(triggerParams) ~= "table" or not TriggerUtils._checkPhotoPosition(extraArg, triggerParams[1], triggerParams[2]) then
		return false
	end

	local targetMask = math.max(tonumber(extraArg[4]) or 0, 0)
	local subjectMask = math.max(tonumber(triggerParams[3]) or 0, 0)

	return targetMask == 0 or bit.band(subjectMask, targetMask) == targetMask
end

function TriggerUtils._checkExtraArgBossRewardReceive(extraArg, triggerParams)
	return extraArg == nil or #extraArg == 0 or lume.find(extraArg, triggerParams) ~= nil
end

function TriggerUtils._checkIncludesLabel(extraArg, triggerParams)
	if bit.band(triggerParams, extraArg) > 0 then
		return true
	end

	return false
end

function TriggerUtils._checkPetCountLevelup(extraArg, triggerParams)
	if extraArg == nil or not next(extraArg) then
		return true
	end

	for _, basePetPrototypeId in pairs(extraArg) do
		if basePetPrototypeId == 0 or basePetPrototypeId == triggerParams then
			return true
		end
	end

	return false
end

function TriggerUtils._checkPartyClearDungeon(extraArg, triggerParams)
	return extraArg == nil or not next(extraArg) or lume.find(extraArg, triggerParams) ~= nil
end

function TriggerUtils._checkExtraArgAttributeKillPuppet(extraArg, triggerParams)
	if extraArg == nil then
		return true
	end

	local needBasePetPrototypeId, needElementType = extraArg[1] or 0, extraArg[2] or 0

	if needBasePetPrototypeId ~= 0 and triggerParams[1] ~= needBasePetPrototypeId then
		return false
	end

	if needElementType ~= 0 and not triggerParams[2][needElementType] then
		return false
	end

	return true
end

function TriggerUtils._checkAdvantageKillPuppet(extraArg, triggerParams)
	local curPetElementTypesTab = triggerParams[1] or {}
	local killPetElementTypesTab = triggerParams[2] or {}
	local killPetLabel = triggerParams[3] or 0
	local killPetConfigLabel = extraArg and extraArg[3] or 0

	if curPetElementTypesTab == nil or killPetElementTypesTab == nil then
		return false
	end

	if (extraArg == nil or type(killPetConfigLabel) == "number" and type(killPetLabel) == "number" and bit.band(killPetLabel, killPetConfigLabel) == killPetConfigLabel) and Utils.getElementAgainstValue(curPetElementTypesTab, killPetElementTypesTab) > 1 then
		return true
	end

	return false
end

function TriggerUtils._checkQualityReach(extraArg, triggerParams)
	for i, data in ipairs(extraArg) do
		if data == 0 then
			return true
		end

		if triggerParams[data] then
			return true
		end
	end

	return false
end

function TriggerUtils._checkExtraArgCombatCooperate(extraArg, triggerParams)
	if extraArg == nil then
		return true
	end

	local curMode = triggerParams and 1 or 2

	return extraArg == curMode
end

function TriggerUtils._checkEggAttrCount(extraArg, triggerParams)
	local petEggInfo = triggerParams
	local count = extraArg and extraArg[1] or 0
	local rarity = extraArg and extraArg[2] or 0

	if rarity == 0 then
		return count <= #petEggInfo.talentIds
	else
		local curCount = 0

		for _, talentId in ipairs(petEggInfo.talentIds) do
			local ptdd = PetTalentData[talentId]

			if ptdd.rarity == rarity then
				curCount = curCount + 1
			end
		end

		return count <= curCount
	end
end

function TriggerUtils._checkPuppetPercent(playerEnt, arg, extraArg, triggerParams)
	if triggerParams == nil then
		return 0
	end

	local templateId, ratio = unpack(triggerParams)

	return ratio
end

function TriggerUtils._checkSkillHitEnemy(extraArg, triggerParams)
	if not extraArg then
		return false
	end

	local abilityParamId, targetCharacterStateName, self, targetEnt = unpack(triggerParams)

	if ToBool(extraArg[1]) and extraArg[1] ~= abilityParamId then
		return false
	end

	if ToBool(extraArg[2]) and extraArg[2] ~= targetCharacterStateName then
		return false
	end

	if extraArg[3] == 0 or extraArg[3] == 1 then
		local targetEntForward = Quaternion.MulVec3(targetEnt:getRotation(), Vector3.forward)
		local dir = targetEnt:getPosition() - self:getPosition()

		dir.y = 0

		Vector3.SetNormalize(dir)

		local isBack = Vector3.Dot(targetEntForward, dir) > 0 and 1 or 0

		return isBack == extraArg[3]
	end

	return true
end

function TriggerUtils._getActivityGlobalProgress(playerEnt, arg, extraArg, triggerParams)
	local activityId = tonumber(arg) or 0

	if activityId <= 0 or pg.component ~= "game" then
		return 0
	end

	local Globals = require("Globals")
	local activitySyncAgent = Globals.activitySyncAgent

	if not activitySyncAgent then
		return 0
	end

	return activitySyncAgent:getActivityGlobalProgress(activityId)
end

function TriggerUtils._getCommonValueHomePlaceFurniture(playerEnt, arg, extraArg)
	local homeId = arg or 0
	local areaId = extraArg or -1

	if areaId == -1 then
		if not playerEnt.statHomelandOrnament then
			return 0
		end

		return playerEnt.statHomelandOrnament[homeId] or 0
	end

	if not playerEnt.statOrnamentByArea then
		return 0
	end

	local areaStat = playerEnt.statOrnamentByArea[areaId]

	if not areaStat then
		return 0
	end

	if homeId == 0 then
		local count = 0

		for _, num in pairs(areaStat) do
			count = count + num
		end

		return count
	end

	return areaStat[homeId] or 0
end

function TriggerUtils._getCommonValueHomePlaceCompose(playerEnt, arg, extraArg)
	local composeId = arg or 0
	local areaId = extraArg or -1

	if areaId == -1 then
		local count = 0

		for _, groupInfo in ipairs(playerEnt.homeBlueprintGroupInfo or EMPTY_TABLE) do
			local blueprintId = groupInfo and (groupInfo.blueprintId or 0) or 0

			if composeId == 0 and blueprintId > 0 or blueprintId == composeId then
				count = count + 1
			end
		end

		return count
	end

	if not playerEnt.statComposeByArea then
		return 0
	end

	local areaStat = playerEnt.statComposeByArea[areaId]

	if not areaStat then
		return 0
	end

	if composeId == 0 then
		local count = 0

		for _, num in pairs(areaStat) do
			count = count + num
		end

		return count
	end

	return areaStat[composeId] or 0
end

function TriggerUtils._getCommonValueHomeIsInSeason(playerEnt, arg, extraArg)
	local HomelandSeasonData = require("Data.home_season_data")

	if not HomelandSeasonData then
		return 0
	end

	local Time = require("Core.Common.Time")
	local currentTime = Time.secondCache
	local seasonId = arg or 0

	if seasonId > 0 then
		local seasonConfig = HomelandSeasonData[seasonId]

		if seasonConfig then
			local startTime = Utils.getConfigTimeOfAreaByData(seasonConfig.startDayTime, seasonConfig.startDayTimeRefId)
			local endTime = Utils.getConfigTimeOfAreaByData(seasonConfig.endDayTime, seasonConfig.endDayTimeRefId)

			if startTime and endTime and startTime <= currentTime and currentTime <= endTime then
				return 1
			end
		end

		return 0
	end

	for _, seasonConfig in pairs(HomelandSeasonData) do
		if seasonConfig then
			local startTime = Utils.getConfigTimeOfAreaByData(seasonConfig.startDayTime, seasonConfig.startDayTimeRefId)
			local endTime = Utils.getConfigTimeOfAreaByData(seasonConfig.endDayTime, seasonConfig.endDayTimeRefId)

			if startTime and endTime and startTime <= currentTime and currentTime <= endTime then
				return 1
			end
		end
	end

	return 0
end

function TriggerUtils._checkPetHitElementByElement(extraArg, triggerParams)
	if extraArg[1] ~= nil and not triggerParams[1][extraArg[1]] then
		return false
	end

	if extraArg[2] ~= nil and triggerParams[2] ~= extraArg[2] then
		return false
	end

	return true
end

function TriggerUtils._checkGetPetWeight(extraArg, triggerParams)
	local minWeight, maxWeight = extraArg[1] or 0, extraArg[2] or math.huge

	return minWeight <= triggerParams and triggerParams <= maxWeight
end

function TriggerUtils._checkCatchPetBuff(extraArg, triggerParams)
	for _, buffInfo in ipairs(triggerParams) do
		if buffInfo.templateId == extraArg then
			return true
		end
	end

	return false
end

function TriggerUtils._checkCatchPetState(extraArg, triggerParams)
	return lume.find(extraArg, triggerParams) and true or false
end

function TriggerUtils._checkCatchPetByStaticId(extraArg, triggerParams)
	if extraArg == nil then
		return true
	end

	local basePetPrototypeId, label = triggerParams[1], triggerParams[2]
	local needBasePetPrototypeId, needLabel = extraArg[1], extraArg[2]

	if needBasePetPrototypeId ~= nil and needBasePetPrototypeId ~= basePetPrototypeId then
		return false
	end

	if needLabel ~= nil and bit.band(label, needLabel) ~= needLabel then
		return false
	end

	return true
end

function TriggerUtils._checkCatchPetGroup(extraArg, triggerParams)
	if extraArg == nil then
		return true
	end

	return lume.find(extraArg, triggerParams) and true or false
end

function TriggerUtils._checkHomeOrder(extraArg, triggerParams)
	for _, v in pairs(extraArg or EMPTY_TABLE) do
		if v == 0 then
			return true
		end

		if triggerParams == v then
			return true
		end
	end

	return false
end

function TriggerUtils._getCatchGenderCount(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getGenderCount(arg, extraArg or 0)
end

function TriggerUtils._getPetScoreCount(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getScoreCount(arg, extraArg)
end

function TriggerUtils._getPetTmplSkillNum(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getSkillNumCountMin(arg, extraArg or 0)
end

function TriggerUtils._getPetAttrCount(playerEnt, arg, extraArg)
	local attrCount = extraArg and extraArg[1] or 0
	local rarity = extraArg and extraArg[2] or 0

	return playerEnt.petStatsInfo:getTalentRarityCountMin(rarity, attrCount)
end

function TriggerUtils._getSpecialCharacterCount(playerEnt, arg, extraArg)
	return playerEnt.petStatsInfo:getSpecialCharacterCount(arg or 0)
end

function TriggerUtils._getPetCpCount(playerEnt, arg, extraArg)
	if pg.component == "client" then
		return playerEnt.pets:getPetCountByPrototypeIdAndCpValueMin(arg, extraArg or 0)
	end

	return playerEnt:getPetCountByPrototypeIdAndCpValueMin(arg, extraArg or 0)
end

TriggerUtils.TRIGGER_CONDITION_FUNC = {
	[TriggerConst.TRIGGER_TARGET_CHECK_CUSTOM_VARIABLE] = function(playerEnt, arg, extraArg)
		return playerEnt.triggerMap:getCustomVariable(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_LEARN_SKILL_BY_HAND] = function(playerEnt, arg, extraArg)
		return playerEnt.skillNodeMap:getSkillNodeLevel(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_USE_SKILLPOINT] = function(playerEnt, arg, extraArg)
		return ItemUtils.getUseSkillPoint(playerEnt, arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_COLLECT_PET_AVATAR] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookAvatarResearchedCount(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_TMPL_NUM_LEVEL] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookCountByHistoryMaxLevelMin(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_RESEARCH_COMPLETE_PET] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookCountByIdAndStateMask(0, Const.PET_HBMSK_RESEARCHED)
	end,
	[TriggerConst.TRIGGER_TARGET_RESEARCH_PROGRESS] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookCountByLevelMin(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_LEVEL_TEMPLATE_HISTORY] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookHistoryMaxLevel(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_TRAIT_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookTraitUnlockedCount(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_SKILL_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetHandbookSkillUnlockedCount(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_TMPL_SKILL_NUM] = TriggerUtils._getPetTmplSkillNum,
	[TriggerConst.TRIGGER_TARGET_PET_PROP_CP] = TriggerUtils._getPetCpCount,
	[TriggerConst.TRIGGER_TARGET_PET_PROP_STRENGTHENPOINT] = function(playerEnt, arg, extraArg)
		return 0
	end,
	[TriggerConst.TRIGGER_TARGET_CATCH_GENDER] = TriggerUtils._getCatchGenderCount,
	[TriggerConst.TRIGGER_TARGET_PET_SCORE_COUNT] = TriggerUtils._getPetScoreCount,
	[TriggerConst.TRIGGER_TARGET_PET_ATTR_COUNT] = TriggerUtils._getPetAttrCount,
	[TriggerConst.TRIGGER_TARGET_PET_CHARACTER_SPECIAL] = TriggerUtils._getSpecialCharacterCount,
	[TriggerConst.TRIGGER_TARGET_HAS_ITEM_TMPL] = function(playerEnt, arg, extraArg)
		return #playerEnt.itemCountBindMap
	end,
	[TriggerConst.TRIGGER_TARGET_UNLOCKED_MAP_MARK] = function(playerEnt, arg, extraArg)
		return playerEnt.mapMarkStatusMap:getTotalUnlockedCount(arg, extraArg or 0, playerEnt.space and playerEnt.space.id)
	end,
	[TriggerConst.TRIGGER_TARGET_PLAYER_LEVEL] = function(playerEnt, arg, extraArg)
		return playerEnt.level
	end,
	[TriggerConst.TRIGGER_TARGET_PLAYER_TITLE] = function(playerEnt, arg, extraArg)
		return playerEnt.starTitle
	end,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_TMPL] = function(playerEnt, arg, extraArg)
		return #playerEnt.petTmplControledMap
	end,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_TYPE] = function(playerEnt, arg, extraArg)
		return playerEnt:isControllingPet() and playerEnt:getCurPetEntity().petPrototypeId or 0
	end,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_CAN_FLY_GE] = TriggerUtils._getCommonValueControlPetCanFlyGe,
	[TriggerConst.TRIGGER_TARGET_HAS_ITEMS] = function(playerEnt, arg, extraArg)
		return playerEnt:getItemCountById(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_FEATURE_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt.petFeatureUnlockMap:getFeatureUnlockCount(arg, extraArg or 0)
	end,
	[TriggerConst.TRIGGER_TARGET_COMPLETE_POI_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt.poiCompleteCountMap[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_COMPLETE_COMBAT_SIM] = function(playerEnt, arg, extraArg)
		return playerEnt.rogueLevelPassCnt[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_GUIDE_COURSE] = function(playerEnt, arg, extraArg)
		return playerEnt:getCourseCompleteCnt(arg) or 0
	end,
	[TriggerConst.TRIGGER_TARGET_FINISH_GUIDE] = function(playerEnt, arg, extraArg)
		return playerEnt:getGuidanceCompleteCnt(arg) or 0
	end,
	[TriggerConst.TRIGGER_TARGET_SANDBOX_PHASE] = function(playerEnt, arg, extraArg)
		return playerEnt:getSandboxPhase(arg) or 0
	end,
	[TriggerConst.TRIGGER_TARGET_CHECK_NPC_BEHAVIOR_STATUS] = function(playerEnt, arg, extraArg)
		return playerEnt.triggerMap:getNpcBehaviorStatus(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_QUEST_STATE] = function(playerEnt, arg, extraArg)
		return QuestCommonUtils.getQuestState(playerEnt, arg)
	end,
	[TriggerConst.TRIGGER_TARGET_TWIN_PET_CHOICE] = function(playerEnt, arg, extraArg)
		return playerEnt.twinPetChoiceIndex
	end,
	[TriggerConst.TRIGGER_TARGET_FINISH_SPECIAL_TRAIN_TYPE_TASK] = function(playerEnt, arg, extraArg)
		return playerEnt.specialTrainTypeMap:getCompleteCount(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_GAIN_SPECIAL_TRAIN_BADGE] = function(playerEnt, arg, extraArg)
		return playerEnt.curBadgeCnt or 0
	end,
	[TriggerConst.TRIGGER_TARGET_FINISH_ALL_SPECIAL_TRAIN_TASK] = function(playerEnt, arg, extraArg)
		return playerEnt:checkAllSpecialTrainQuestSubmited() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_DUNGEON_PASS] = function(playerEnt, arg, extraArg)
		return playerEnt.passRecord[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_SKILL_LEARN_COUNT] = function(playerEnt, arg, extraArg)
		return #playerEnt.unlockedAbilityMap - 1
	end,
	[TriggerConst.TRIGGER_TARGET_TOTEM_LEVEL] = function(playerEnt, arg, extraArg)
		return playerEnt.totemMap[arg] and playerEnt.totemMap[arg].level or 0
	end,
	[TriggerConst.TRIGGER_TARGET_CATCH_COUNT_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt.getPetTotalCount
	end,
	[TriggerConst.TRIGGER_TARGET_PLAYER_HP_PERCENT] = function(playerEnt, arg, extraArg)
		return playerEnt.actorCombatAttribute:getHpPercent()
	end,
	[TriggerConst.TRIGGER_TARGET_SCENE_ID] = function(playerEnt, arg, extraArg)
		return playerEnt.space and playerEnt.space.sceneId or 0
	end,
	[TriggerConst.TRIGGER_TARGET_SCENE_ID_STATIC] = function(playerEnt, arg, extraArg)
		return playerEnt.space and playerEnt.space.sceneId or 0
	end,
	[TriggerConst.TRIGGER_TARGET_FUNCTION_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt.functionUnlocks[extraArg] or Const.FUNCTION_UNLOCK_STATE.LOCK
	end,
	[TriggerConst.TRIGGER_TARGET_IN_COMBAT] = function(playerEnt, arg, extraArg)
		return playerEnt:isInCombat() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_PLAYER_IS_CONTROL_PET] = function(playerEnt, arg, extraArg)
		return playerEnt:isControllingPet() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_EXCHANGE_PETS_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt.exchangePetTotalCount
	end,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_FIRST] = function(playerEnt, arg, extraArg)
		return playerEnt.petTmplControledMap[arg] and 0 or 1
	end,
	[TriggerConst.TRIGGER_TARGET_IN_TEAM] = function(playerEnt, arg, extraArg)
		return playerEnt:isInTeam() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_REPORT_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt:getPetCatchReportCount()
	end,
	[TriggerConst.TRIGGER_TARGET_REPORT_EXP_LEVELUP] = function(playerEnt, arg, extraArg)
		return playerEnt:canPlayerLevelUpAfterResearchReport() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_SPECIAL_TRAIN_REPORT_TIMES] = function(playerEnt, arg, extraArg)
		return playerEnt.petCatchReportTimes
	end,
	[TriggerConst.TRIGGER_TARGET_ACTIVATE_SPECIFIC_MAP_MARKER] = function(playerEnt, arg, extraArg)
		return playerEnt.mapMarkStatusMap:isStaticIdUnlocked(arg) and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_CLEAN_SUNDRIES_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt:getOrnamentTrashRecycledCount()
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_STOREHOUSE_ITEM_NUM] = function(playerEnt, arg, extraArg)
		return playerEnt:getWareHouseItemCount(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_HAVE_FURNITURE] = function(playerEnt, arg, extraArg)
		return playerEnt:getOrnamentCountWithoutTrash(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_FACILITY_SET_FORMULA] = function(playerEnt, arg, extraArg)
		return playerEnt:getFacilitySetFormulaCount(arg, extraArg) > 0 and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_FACILITY_PROGRESS] = function(playerEnt, arg, extraArg)
		return playerEnt:getOrnamentFacilityInState(arg, extraArg) > 0 and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_IS_IN_HOME] = function(playerEnt, arg, extraArg)
		return playerEnt:isInSelfHomeland() and 1 or 0
	end,
	[TriggerConst.TRIGGER_TRAGET_ROGUE_EXCHANGE] = function(playerEnt, arg, extraArg)
		return playerEnt:getRogueExchangeRewardMarkCount(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_FACILITY_WORK] = function(playerEnt, arg, extraArg)
		return playerEnt:checkInFormulaOperation(arg, extraArg) and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_LOGIN_NUM] = function(playerEnt, arg, extraArg)
		return 1
	end,
	[TriggerConst.TRIGGER_TARGET_ADMISSION_DAY] = function(playerEnt, arg, extraArg)
		return playerEnt:getEnterSchoolDays()
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_GROUND_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt:getStatUnlockHomelandZone(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_CAR_LEVEL] = function(playerEnt, arg, extraArg)
		return playerEnt:getHomeCarLevel()
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_CAR_COMP_LEVEL] = function(playerEnt, arg, extraArg)
		return playerEnt:getHomeCarCompLevel(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_RANDOM_PRODUCE] = TriggerUtils._getCommonValueHomeRandomProduce,
	[TriggerConst.TRIGGER_TARGET_HOME_PLACE_FURNITURE] = TriggerUtils._getCommonValueHomePlaceFurniture,
	[TriggerConst.TRIGGER_TARGET_GROUP_TOUR_ACTIVATE_TIMES] = function(playerEnt, arg, extraArg)
		return playerEnt.openSpaceFollowCount
	end,
	[TriggerConst.TRIGGER_TARGET_GROUP_TOUR_GIFT_TIMES] = function(playerEnt, arg, extraArg)
		return playerEnt.givePetNumInSpaceFollow
	end,
	[TriggerConst.TRIGGER_TARGET_BOSS_RUSH_RANKS] = function(playerEnt, arg, extraArg)
		return playerEnt.bossRushCycBestGrades
	end,
	[TriggerConst.TRIGGER_TARGET_HAS_PLAYER_NAME] = function(playerEnt, arg, extraArg)
		return playerEnt.playerNameFirstChanged and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_TALENT_UNLOCK] = function(playerEnt, arg, extraArg)
		return playerEnt:getTalentIsUnlockByTalentId(arg) and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_ACTIVITY_PHASE] = function(playerEnt, arg, extraArg)
		return ActivityUtils.isOprActivityOpen(arg, playerEnt) and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_ROB_EGG_LEVEL] = TriggerUtils._checkRobEggLevelCondition,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_RANK_STAR] = TriggerUtils._checkRobEggRankStar,
	[TriggerConst.TRIGGER_TARGET_HAVE_SPECIAL_TRAIN_BADGE_REWARD] = TriggerUtils._isHaveSpecialTrainBadgeReward,
	[TriggerConst.TRIGGER_TARGET_TIME_STATE] = TriggerUtils._isInTimePeriod,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_STAGE] = TriggerUtils._isControlPetStageMatch,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET_LABEL] = TriggerUtils._isControlPetLabelMatch,
	[TriggerConst.TIRGGER_TARGET_CONTROL_PET_GROPU] = TriggerUtils._isControlPetEthnicGroupMatch,
	[TriggerConst.TRIGGER_TARGET_POS_SPHERE] = TriggerUtils._getCommonValuePosSphere,
	[TriggerConst.TRIGGER_TARGET_PLAYER_IN_BEHAVIOR] = TriggerUtils._getCommonValueCharacterState,
	[TriggerConst.TRIGGER_TARGET_PET_LEVEL_TEMPLATE] = TriggerUtils._getCommonValuePetLevelTemplate,
	[TriggerConst.TRIGGER_TARGET_PET_NUM_LEVEL] = TriggerUtils._getCommonValuePetLevelCount,
	[TriggerConst.TRIGGER_TARGET_COLLECT_PET_NUM] = TriggerUtils._getCommonValueCollectPetNum,
	[TriggerConst.TRIGGER_TARGET_KNOWN_PET_NUM] = TriggerUtils._getCommonValueKnownPetNum,
	[TriggerConst.TRIGGER_TARGET_CLEAN_MONSTER_CAMP] = TriggerUtils._getCommonValueCleanMonsterCamp,
	[TriggerConst.TRIGGER_TARGET_OPEN_CHEST] = TriggerUtils._getCommonValueOpenChest,
	[TriggerConst.TRIGGER_TARGET_OPEN_CHEST_BY_STATICID] = TriggerUtils._getCommonValueOpenChestByStaticId,
	[TriggerConst.TRIGGER_TARGET_TOTAL_RESEARCH_LEVEL] = TriggerUtils._getCommonValueTotalResearchLevel,
	[TriggerConst.TRIGGER_TARGET_ETHNICGROUP_JUDGMENT] = TriggerUtils._getCommonValueEthnicGroupJudgment,
	[TriggerConst.TRIGGER_TARGET_DISTANCE_PLAYER_NPC_CALLFRIEND] = TriggerUtils._getCommonValueDistancePlayerNpcCallFriend,
	[TriggerConst.TRIGGER_TARGET_GOTO_POSITION] = TriggerUtils._getCommonValueGotoPosition,
	[TriggerConst.TRIGGER_TARGET_CONTROL_GOTO_POSITION] = TriggerUtils._getCommonValueControlGotoPosition,
	[TriggerConst.TRIGGER_CONTROL_GOTO_POSITION_PET] = TriggerUtils._getCommonValueControlGotoPositionPet,
	[TriggerConst.TRIGGER_TARGET_ARRIVE_HOME_CAR_POSITION] = TriggerUtils._getCommonValueArriveHomeCarPosition,
	[TriggerConst.TRIGGER_TARGET_MEET_PET] = TriggerUtils._getCommonValueMeetPet,
	[TriggerConst.TRIGGER_TARGET_NEAR_PET] = TriggerUtils._getCommonValueNearPet,
	[TriggerConst.TRIGGER_TARGET_CHECK_CLIENT_CUSTOM_VARIABLE] = TriggerUtils._getCommonClientCustomVariable,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_ACTIVE] = TriggerUtils._getCommonValueLeylineTreeActived,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_LEVEL] = TriggerUtils._getCommonValueLeylineTreeLevel,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_POINT] = TriggerUtils._getCommonValueLeylineTreePoint,
	[TriggerConst.TRIGGER_TARGET_PLAYER_BODY_TYPE] = TriggerUtils._getCommonValuePlayerBodyType,
	[TriggerConst.TRIGGER_TARGET_CREAT_TEAM_VOICE_CHANNEL] = TriggerUtils._isNotJoinTeamSpeech,
	[TriggerConst.TRIGGER_TARGET_JOINED_VOICE_CHANNEL] = TriggerUtils._isTeamSpeechKeyTalk,
	[TriggerConst.TRIGGER_TARGET_REPORT_COLLECT_SCORE] = TriggerUtils._getCommonValueReportCollectScore,
	[TriggerConst.TRIGGER_TARGET_PET_DIE_COUNT_IN_STATE] = TriggerUtils._getCommonValuePetDieCountInState,
	[TriggerConst.TRIGGER_TARGET_MAX_MINUS_TEAM_AVG_LEVEL] = TriggerUtils._getCommonValueMaxMinusTeamAvgValue,
	[TriggerConst.TRIGGER_TARGET_TARGET_MINUS_TEAM_AVG_LEVEL] = TriggerUtils._getCommonValueTargetMinusTeamAvgValue,
	[TriggerConst.TRIGGER_TARGET_CHEST_DISTANCE] = TriggerUtils._getCommonValueChestDistance,
	[TriggerConst.TRIGGER_TARGET_BACKSTAGE_TYPE_ADVANTAGE] = TriggerUtils._getCommonValueBackstageTypeAdvantage,
	[TriggerConst.TRIGGER_TARGET_VEHICLE_INTERACTION] = TriggerUtils._isVehicleInteraction,
	[TriggerConst.TRIGGER_TARGET_SPECIAL_PET_TYPE] = TriggerUtils._getCommonValueSpecialPetType,
	[TriggerConst.TRIGGER_TARGET_SERVER_OPEN_DAY] = TimeUtils.getOpenServerDay,
	[TriggerConst.TRIGGER_TARGET_PET_BATTLE_TAG] = TriggerUtils._getCommonValuePetBattleTag,
	[TriggerConst.TRIGGER_TARGET_ATTRIBUTE_COMPARE] = TriggerUtils._getCommonValueAttributeCompare,
	[TriggerConst.TRIGGER_TARGET_CORE_CARRY_NUM] = TriggerUtils._getCommonValueCoreCarryNum,
	[TriggerConst.TRIGGER_TARGET_QUIZ_COMPLETE] = TriggerUtils._quizIsFinish,
	[TriggerConst.TRIGGER_TARGET_CHECK_TARGET] = TriggerUtils._checkGamePlayTarget,
	[TriggerConst.TRIGGER_PET_REMAINDER_NUM] = TriggerUtils._getPetBoxRemainderNum,
	[TriggerConst.TRIGGER_HAS_PET_RACE] = TriggerUtils._checkHasPetRace,
	[TriggerConst.TRIGGER_PET_RACE] = TriggerUtils._checkControlPetRace,
	[TriggerConst.TRIGGER_PET_RACE_POSITION] = TriggerUtils._checkControlPetRacePosition,
	[TriggerConst.TRIGGER_FINISH_BATCH_DIALOGUEID] = TriggerUtils._checkFinishBatchDialogue,
	[TriggerConst.TRIGGER_BOSS_FINISH_CHECK] = TriggerUtils._getBossFinshLevel,
	[TriggerConst.TRIGGER_ACT_ARKCARN_PHOTE_PET] = TriggerUtils._getActArkCarnPhotoPetNum,
	[TriggerConst.TRIGGER_ACT_STAGE_OPEN] = TriggerUtils._getActStageOpened,
	[TriggerConst.TRIGGER_AREA_INTERNAL] = TriggerUtils._checkAreaInternal,
	[TriggerConst.TRIGGER_ROBEGG_ENTER_DG] = TriggerUtils._isRobEggUndergraound,
	[TriggerConst.TRIGGER_ROBEGG_OPEN_EGG] = TriggerUtils._returnTrue,
	[TriggerConst.TRIGGER_ROBEGG_ACTIVATE_DG] = TriggerUtils._returnTrue,
	[TriggerConst.TRIGGER_ROBEGG_EXIT_DG] = TriggerUtils._returnTrue,
	[TriggerConst.TRIGGER_ROBEGG_TRANS_EGG] = TriggerUtils._returnTrue,
	[TriggerConst.TRIGGER_ROBEGG_RETREAT] = TriggerUtils._dayRobEggRetreat,
	[TriggerConst.TRIGGER_ACT_TASK_ONEGROUP_FINED] = TriggerUtils._checkActOneTaskGroupCompleted,
	[TriggerConst.TRIGGER_ACT_TASK_ALLGROUPS_FINED] = TriggerUtils._checkActAllTaskGroupCompleted,
	[TriggerConst.TRIGGER_TARGET_SPECIAL_TRAIN_CHAPTER_FINISH] = TriggerUtils._isSpecialTrainChapterFinished,
	[TriggerConst.TRIGGER_TARGET_BOSS_SCORE] = TriggerUtils._getBossScore,
	[TriggerConst.TRIGGER_TARGET_PET_RANKUP_TIMES] = TriggerUtils._getPetRankUpTimes,
	[TriggerConst.TRIGGER_TARGET_APPEARNCE_COUNT_TOTAL] = TriggerUtils._getAppearnceCount,
	[TriggerConst.TRIGGER_TARGET_EXPLORE_MAP_COVER] = TriggerUtils._getExploreMapCover,
	[TriggerConst.TRIGGER_TARGET_HAS_CORE_QUALITY_NUM] = TriggerUtils._getCoreQualityNum,
	[TriggerConst.TRIGGER_TARGET_UPGRADE_CORE_QUALITY_COUNT] = TriggerUtils._getUpgradeCoreQualityCount,
	[TriggerConst.TRIGGER_TARGET_HAS_RUNE_QUALITY_NUM] = TriggerUtils._getRuneQualityNum,
	[TriggerConst.TRIGGER_TARGET_REDUCE_ENERGY_TOTAL] = TriggerUtils._getReduceEnergyTotal,
	[TriggerConst.TRIGGER_TARGET_OBTAIN_REWARD_TOTAL] = TriggerUtils._getObtainRewardTotal,
	[TriggerConst.TRIGGER_TARGET_PET_UPGRADE_STAR] = TriggerUtils._getPetUpgradeStar,
	[TriggerConst.TRIGGER_HAS_PET_ID] = TriggerUtils._checkHasPetById,
	[TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_PASS] = TriggerUtils._getSimulationTrainPass,
	[TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_PLAY] = TriggerUtils._getSimulationTrainPlay,
	[TriggerConst.TRIGGER_TARGET_ROGUE_EXCHANGE_BOX] = TriggerUtils._getRogueExchangeBox,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_RETREAT_COUNT] = TriggerUtils._getRobeGGRetreatCount,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_PLAY_COUNT] = TriggerUtils._getRobeGGPlayCount,
	[TriggerConst.TRIGGER_TARGET_CONTROL_EGG] = TriggerUtils._isControlEgg,
	[TriggerConst.TRIGGER_TARGET_COLLECT_BADGE_STATE] = TriggerUtils._getBadgeCollectionState,
	[TriggerConst.TRIGGER_TARGET_SUBMITED_EGG] = TriggerUtils._checkSubmittedEgg,
	[TriggerConst.TRIGGER_TARGET_MATCH_GAINS_STATE] = TriggerUtils._getMatchGains,
	[TriggerConst.TRIGGER_TARGET_OWN_CORE_CARRY_COUNT] = TriggerUtils._getOwnCoreCarryCount,
	[TriggerConst.TRIGGER_TARGET_ACTIVATE_CORE_CARRY_EFFECT] = TriggerUtils._getActivateCoreCarryEffectCount,
	[TriggerConst.TRIGGER_TARGET_OBTAIN_EGG_ITEMS] = TriggerUtils._getObtainEggItemsCount,
	[TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_UNLOCKED_MERITS] = TriggerUtils._getSimulationTrainUnlockedMerits,
	[TriggerConst.TRIGGER_TARGET_OUTFIT_COUNT_TOTAL] = TriggerUtils._getOutfitCount,
	[TriggerConst.TRIGGER_TARGET_EMOTE_DONE_COUNT] = TriggerUtils._getEmoteDoneCount,
	[TriggerConst.TRIGGER_TARGET_EMOTE_FLUET_MEET_FRIENDS] = TriggerUtils._getEmoteFluetMeetFriendsCount,
	[TriggerConst.TRIGGER_TARGET_QUEST_TYPE_DONE] = TriggerUtils._getQuestTypeDoneCount,
	[TriggerConst.TRIGGER_TARGET_SPECIAL_TRAIN_REQUIRED_TASK] = TriggerUtils._getSpecialTrainChapterFinishedCount,
	[TriggerConst.TRIGGER_TARGET_HOME_ORDERS_DONE] = TriggerUtils._getHomeOrderQuantityCount,
	[TriggerConst.TRIGGER_TARGET_EMOTE_TRIGGER_TIMES] = TriggerUtils._getEmoteTriggerTimes,
	[TriggerConst.TRIGGER_TARGET_REPORT_CATCH_RESULTS_TOTAL] = TriggerUtils._getCommonValueReportCatchResultsTotal,
	[TriggerConst.TRIGGER_TARGET_COLLECT_ONLY_PET_NUM] = TriggerUtils._getCommonValueCollectOnlyPetNum,
	[TriggerConst.TRIGGER_TARGET_REDUCE_MONEY_TOTAL] = TriggerUtils._getReduceMoneyTotal,
	[TriggerConst.TRIGGER_TARGET_USE_ITEM_TOTAL] = TriggerUtils._getUseItemTotal,
	[TriggerConst.TRIGGER_TARGET_GET_EGG_TOTAL] = TriggerUtils._getEggTotal,
	[TriggerConst.TRIGGER_TARGET_GET_MONEY_HOME_TOTAL] = TriggerUtils._getMoneyHomeTotal,
	[TriggerConst.TRIGGER_TARGET_CATCH_RAINBOW_PET] = TriggerUtils._getCatchRainbowPetCount,
	[TriggerConst.TRIGGER_TARGET_NPC_DUEL_CLEAR] = TriggerUtils._checkNpcDuelClear,
	[TriggerConst.TRIGGER_TARGET_NPC_DUEL_CLEAR_SHOWCOUNT_TOTAL] = TriggerUtils._getNpcDuelClearCount,
	[TriggerConst.TRIGGER_TARGET_SANDBOX_QUEST_EVENT] = TriggerUtils._getSandboxQuestEvent,
	[TriggerConst.TRIGGER_ACT_TASK_SPEIC_TASKS_FINED] = TriggerUtils._checkActSpecTasksCompleted,
	[TriggerConst.TRIGGER_ACT_TASK_SPEIC_TASKS_RECVED] = TriggerUtils._checkActSpecTasksRecved,
	[TriggerConst.TRIGGER_ACT_LOGIN_CONTINUE] = TriggerUtils._getActContinueLoginNum,
	[TriggerConst.TRIGGER_TARGET_CONTROL_PET] = TriggerUtils._checkControlPet,
	[TriggerConst.TRIGGER_TARGET_BP_Gear] = TriggerUtils._getBattlePassGear,
	[TriggerConst.TRIGGER_TARGET_BP_Level] = TriggerUtils.getBattlePassLevel,
	[TriggerConst.TRIGGER_TARGET_HAS_BADGE] = TriggerUtils._checkHasBadge,
	[TriggerConst.TRIGGER_TARGET_HAS_BADGE_BY_TYPE] = TriggerUtils._checkHasBadgeByType,
	[TriggerConst.TRIGGER_TARGET_HAS_BADGES] = TriggerUtils._checkHasBadges,
	[TriggerConst.TRIGGER_TARGET_HAS_PET_UPDATE_SKILL_BY_SINGLE] = TriggerUtils._getCommonValueHasPetUpdateSkillBySingle,
	[TriggerConst.TRIGGER_TARGET_MONTHCARD_ACTIVATED] = TriggerUtils._checkMonthcardActivated,
	[TriggerConst.TRIGGER_TARGET_PET_TEMPLATE_INDIVIDUAL_LEVELS_REACH] = TriggerUtils._getCommonValuePetIndividualLevelsReach,
	[TriggerConst.TRIGGER_TARGET_AREA_CHECK] = TriggerUtils._checkAreaBlock,
	[TriggerConst.TRIGGER_TARGET_LARGE_NUMBER_CHECK] = TriggerUtils._checkFlowerLargeNumber,
	[TriggerConst.TRIGGER_TARGET_HOME_CURRENT_ITEM_NUM] = TriggerUtils._getCommonValueHomeCurrentItemNum,
	[TriggerConst.TRIGGER_TARGET_HOME_ITEM_NUM] = TriggerUtils._getCommonValueHomeItemNum,
	[TriggerConst.TRIGGER_TARGET_PKG_CHANNEL] = TriggerUtils._checkPlayerChannel,
	[TriggerConst.TRIGGER_TARGET_NOT_PKG_CHANNEL] = TriggerUtils._checkPlayerNotChannel,
	[TriggerConst.TRIGGER_TARGET_KNOWLEDGE_UNLOCK] = TriggerUtils._checkKnowledgeUnlock,
	[TriggerConst.TRIGGER_TARGET_MOBILITY_PET_STATE] = TriggerUtils._checkExplorePetState,
	[TriggerConst.TRIGGER_TARGET_BOSSRUSH_KILL_BOSS] = TriggerUtils._checkBossRushKillBossNum,
	[TriggerConst.TRIGGER_TARGET_QUEST_CLUE_ACCEPT_CHECK_BY_CHAPTER] = TriggerUtils._checkQuestClueAcceptCheckByChapter,
	[TriggerConst.TRIGGER_TARGET_ACTIVITY_QUEST_STATE] = TriggerUtils._getActivityTaskState,
	[TriggerConst.TRIGGER_TARGET_HOME_PLACE_COMPOSE] = TriggerUtils._getCommonValueHomePlaceCompose,
	[TriggerConst.TRIGGER_TARGET_HOME_IS_IN_SEASON] = TriggerUtils._getCommonValueHomeIsInSeason,
	[TriggerConst.TRIGGER_TARGET_ACCUMULATE_FINISH_DUNGEON] = TriggerUtils._checkDungeonFinishTimes,
	[TriggerConst.TRIGGER_TARGET_FIRST_CHARGE] = TriggerUtils._checkFirstCharge,
	[TriggerConst.TRIGGER_TARGET_IN_AREA_TIME] = TriggerUtils._checkInAreaTime,
	[TriggerConst.TRIGGER_TARGET_SPENDING] = TriggerUtils._checkInSpending,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_COLLECT_ITEM_POINT_SUM] = TriggerUtils._checkSeasonRobEggCollectPoint,
	[TriggerConst.PET_TRIGGER_TARGET_LEVEL] = function(petInfo)
		return petInfo.level
	end,
	[TriggerConst.PET_TRIGGER_TARGET_IS_EXCHANGE_PET] = TriggerUtils._getPetIsExchangePet,
	[TriggerConst.PET_TRIGGER_CHECK_MBTI] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetMBTI(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_CHECK_SCORE_STAGE] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetScoreStage(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_CHARACTER] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetCharacter(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_HAS_ELEMENT] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetHasElement(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_IS_FORM] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetIsForm(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_HAS_EXPLORE] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetHasExplore(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_CP_VALUE] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetCpValue(petInfo, arg, extraArg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_LAB] = function(petInfo, arg, extraArg)
		return TriggerUtils._checkPetLab(petInfo, arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_RIFT_REWARD_CHECK] = TriggerUtils._checkRiftReward,
	[TriggerConst.TRIGGER_TARGET_TIME_TOKEN] = function(playerEnt, arg, extraArg)
		return TimeTokenUtils.canTrigger(playerEnt, arg) and 1 or 0
	end
}
TriggerUtils.TRIGGER_CONDITION_FUNC_SERVER_ONLY = {
	[TriggerConst.TRIGGER_TARGET_COMPLETE_COURSE] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:isCompleteCourses(extraArg or {}) and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_UNLOCK] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.isHomelandUnlock and playerEnt.isHomeCampUnlocked and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_COMFORT_VALUE] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getHomeComfortValue(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_START_DISPATCH_HISTORY] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.homeStartDispatchHistory and playerEnt.homeStartDispatchHistory[arg or 0] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_SEASON_MUTATION_COLLECT_NUM] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getHomeSeasonMutationCollectedTotalCount(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_PLACE_FACILITY_TYPE] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getStatHomelandFacilityType(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_PALCE_PET] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getStatHomelandPet(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_HAVE_RAINBOW_PET] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.statRainbowPet[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_SIMULATION_TRAIN_LEVEL] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.statRogueDungeonCnt[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_HATCH_EGG] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getStatHatchEgg(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_FRIEND_INTIMACY] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getFriendIntimacyLevelCount(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_PHOTO_NUM] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getStatPhoneNum(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_RECOVER_CASTER_NUM] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.statRecycleBall[arg] or 0
	end,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_NOURISH_NUM] = TriggerUtils._getServerValueFlowerNourishByTree,
	[TriggerConst.TRIGGER_TARGET_SPECIAL_TRAIN_FINISH] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getSpecialTrainFinishState(arg, extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_ROGUE_TALENT_TREE_NODE] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt.rogueTalentLevelUnlock[arg] and 1 or 0
	end,
	[TriggerConst.TRIGGER_TARGET_CAMP_PLACE_FURNITURE] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getStatHomeCarOrnament(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_CATCH_COUNT_ONCE] = TriggerUtils._getServerValueCatchCountOnce,
	[TriggerConst.TRIGGER_TARGET_LEVELITEM_STATE] = TriggerUtils._getServerValueSandBoxLeveItemFiledValue,
	[TriggerConst.TRIGGER_TARGET_COMBAT_ACTION_NODE] = TriggerUtils._checkCombatActionNodeDuration,
	[TriggerConst.TRIGGER_TARGET_HAVE_BUFF] = TriggerUtils._checkBuffLayer,
	[TriggerConst.TRIGGER_TARGET_IN_CAMOU] = TriggerUtils._checkInCamou,
	[TriggerConst.TRIGGER_TARGET_COMBAT_ACTION_NODE_BY_FORM] = TriggerUtils._checkCombatActionNodeDurationByFrom,
	[TriggerConst.TRIGGER_TARGET_CLASS_OPEN_DAY] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getClassOpenDay()
	end,
	[TriggerConst.TRIGGER_TARGET_PUPPET_HP_LE_PERCENT] = TriggerUtils._checkPuppetPercent,
	[TriggerConst.TRIGGER_TARGET_GLOBAL_ACTIVITY_PROGRESS] = TriggerUtils._getActivityGlobalProgress,
	[TriggerConst.TRIGGER_TARGET_HOME_FORMULA_UNLOCK] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getHomelandFormulaUnlockNum(arg)
	end,
	[TriggerConst.TRIGGER_TARGET_BOSS_RUSH_STARS_ACC] = function(playerEnt, arg, extraArg)
		return playerEnt:getBossRushSeasonTotalStar()
	end,
	[TriggerConst.TRIGGER_TARGET_HOME_SEASON_CLEAN_SUNDRIES_NUM] = function(playerEnt, arg, extraArg, triggerParams)
		return playerEnt:getSeasonOrnamentTrashRecycledCount(arg)
	end,
	[TriggerConst.PET_TRIGGER_TARGET_COMBAT_ACTION_NODE] = function(petInfo, arg, extraArg, triggerInfo)
		return TriggerUtils._checkPetCombatActionNode(petInfo, arg, extraArg, triggerInfo)
	end
}
TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY = {
	[TriggerConst.TRIGGER_TARGET_ANGLE_OF_VIEW] = TriggerUtils._getClientValueAngleOfView,
	[TriggerConst.TRIGGER_TARGET_PET_HP_PERCENT_TIME] = TriggerUtils._getClientValuePetHpPercentTime,
	[TriggerConst.TRIGGER_TARGET_PET_HP_PERCENT] = TriggerUtils._getClientValuePetHpPercent,
	[TriggerConst.TRIGGER_TARGET_PET_TEAM_SKILL_TYPE] = TriggerUtils._getClientValuePetTeamSkillType,
	[TriggerConst.TRIGGER_TARGET_FRIENDS_NUM] = TriggerUtils._getClientValueFriendsNum,
	[TriggerConst.TRIGGER_TARGET_SPACE_TYPE] = TriggerUtils._getClientSpaceType,
	[TriggerConst.TRIGGER_TARGET_SP_POWER_FULL] = TriggerUtils._getClientValueSpPowerFull,
	[TriggerConst.TRIGGER_IN_TIME_WEATHER_BLOCK] = TriggerUtils._getClientTimeWeatherBlock,
	[TriggerConst.TRIGGER_TARGET_OPENING_INTERFACE] = TriggerUtils._checkUIIsIpen,
	[TriggerConst.TRIGGER_TARGET_CATCH_PET_LEVELGAP] = TriggerUtils._getClientCatchPetLevelGap
}
TriggerUtils.TRIGGER_CUSTOM_CLIENT_ONLY = {
	[TriggerConst.TRIGGER_TARGET_GOTO_POSITION] = {
		generateFilters = TriggerUtils.generateFiltersCommon,
		generateFilterArgs = TriggerUtils._getCommonValueGotoPosition_generateFilterArgs,
		fastFilter = Utils.checkPositionMatchClient,
		questFastFilter = Utils.checkPositionMatchClient,
		onSceneLoad = TriggerUtils._getCommonValueGotoPosition_OnSceneLoad
	}
}

function TriggerUtils.ClientOnSceneLoad(sceneId)
	for _trigger, config in pairs(TriggerUtils.TRIGGER_CUSTOM_CLIENT_ONLY) do
		local onSceneLoad = config.onSceneLoad

		if onSceneLoad then
			onSceneLoad(sceneId)
		end
	end
end

local TRIGGER_CONDITION_FUNC = TriggerUtils.TRIGGER_CONDITION_FUNC
local TRIGGER_CONDITION_FUNC_SERVER_ONLY = TriggerUtils.TRIGGER_CONDITION_FUNC_SERVER_ONLY
local TRIGGER_CONDITION_FUNC_CLIENT_ONLY = TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY

local function checkMatchOrZero(extraArg, triggerParams)
	return extraArg == nil or extraArg == 0 or triggerParams == extraArg
end

local function checkGreaterEqual(extraArg, triggerParams)
	return extraArg == nil or type(extraArg) == "number" and type(triggerParams) == "number" and extraArg <= triggerParams
end

local function checkMaskHas(extraArg, triggerParams)
	return extraArg == nil or type(extraArg) == "number" and type(triggerParams) == "number" and bit.band(triggerParams, extraArg) == extraArg
end

function TriggerUtils._checkAllConditionsMet(extraArg, triggerParams)
	if type(extraArg) ~= "table" or triggerParams == nil then
		return false
	end

	for _, condId in ipairs(extraArg) do
		if not triggerParams:isCompleteOrMeetCondition(condId) then
			return false
		end
	end

	return true
end

TriggerUtils.COUNT_TRIGGER_EXTARG_COMP_FUNC = {
	[TriggerConst.TRIGGER_TARGET_ATTRIBUTE_KILL_PUPPET] = TriggerUtils._checkExtraArgAttributeKillPuppet,
	[TriggerConst.TRIGGER_TARGET_COMBAT_COOPERATE] = TriggerUtils._checkExtraArgCombatCooperate,
	[TriggerConst.TRIGGER_TARGET_INTERACT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_SHOP_BUY] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_EGG_ATTR_COUNT] = TriggerUtils._checkEggAttrCount,
	[TriggerConst.TRIGGER_TARGET_SKILL_HIT_ENEMY] = TriggerUtils._checkSkillHitEnemy,
	[TriggerConst.TRIGGER_TARGET_PET_RARE_SKILL_COUNT] = function(extraArg, triggerParams)
		return ToInt(triggerParams) >= ToInt(extraArg)
	end,
	[TriggerConst.TRIGGER_TARGET_PET_HIT_ELEMENT_BY_ELEMENT] = TriggerUtils._checkPetHitElementByElement,
	[TriggerConst.TRIGGER_TARGET_PET_KILL_ELEMENT] = function(extraArg, triggerParams)
		return extraArg == nil or triggerParams[extraArg]
	end,
	[TriggerConst.TRIGGER_TARGET_GET_PET_WEIGHT] = TriggerUtils._checkGetPetWeight,
	[TriggerConst.TRIGGER_TARGET_CATCH_PET_BUFF] = TriggerUtils._checkCatchPetBuff,
	[TriggerConst.TRIGGER_TARGET_CATCH_PET_STATE] = TriggerUtils._checkCatchPetState,
	[TriggerConst.TRIGGER_TARGET_CUR_BALL_NUM_LESS_EQUAL] = TriggerUtils._checkLessEqualBallNum,
	[TriggerConst.TRIGGER_TARGET_PET_HP_LE_PERCENT] = TriggerUtils._checkPetHpLePercent,
	[TriggerConst.TRIGGER_TARGET_PET_HP_GE_PERCENT] = TriggerUtils._checkPetHpGePercent,
	[TriggerConst.TRIGGER_TARGET_CATCH_PET_BY_STATICID] = TriggerUtils._checkCatchPetByStaticId,
	[TriggerConst.TRIGGER_TARGET_POSSESSION_KILL_MONSTER] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_SEPARATE_KILL_MONSTER] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_ENTER_LINE_PHASE] = checkGreaterEqual,
	[TriggerConst.TRIGGER_TARGET_ENTER_LEADER_SPACE] = checkGreaterEqual,
	[TriggerConst.TRIGGER_TARGET_CATCH_FAIL_BY_BALL_LEVEL] = checkGreaterEqual,
	[TriggerConst.TRIGGER_TARGET_HOME_FACILITY_OUTPUT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_KILL_PET_TEMPLATE] = checkMaskHas,
	[TriggerConst.TRIGGER_TARGET_KILL_PET_TEMPLATE_SPECIFIC] = checkMaskHas,
	[TriggerConst.TRIGGER_TARGET_KILL_PET_TEMPLATEID] = checkMaskHas,
	[TriggerConst.TRIGGER_ACT_LOGIN] = checkMatchOrZero,
	[TriggerConst.TRIGGER_EVOLVE_PET] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_CATCH_PETGROUP_COUNT] = TriggerUtils._checkCatchPetGroup,
	[TriggerConst.TRIGGER_TARGET_HOME_ORDER] = TriggerUtils._checkHomeOrder,
	[TriggerConst.PET_TRIGGER_BASE_PROPERTY_LIST] = TriggerUtils._checkPetBasePropertyList,
	[TriggerConst.PET_TRIGGER_KILL_WITH_TEAM] = TriggerUtils._checkKillWithTeam,
	[TriggerConst.PET_TRIGGER_KILL_WITH_TEAM_FORM] = TriggerUtils._checkKillWithTeam,
	[TriggerConst.PET_TRIGGER_KILL_STREAK] = TriggerUtils._checkPetKillStreak,
	[TriggerConst.PET_TRIGGER_KILL_STREAK_FORM] = TriggerUtils._checkPetKillStreakForm,
	[TriggerConst.PET_TRIGGER_SWITCH_TIME] = TriggerUtils._checkPetSwitchTime,
	[TriggerConst.PET_TRIGGER_SEND_AI_MSG] = TriggerUtils._checkPetAIMsg,
	[TriggerConst.PET_TRIGGER_SEND_AI_MSG_FORM] = TriggerUtils._checkPetAIMsg,
	[TriggerConst.TRIGGER_TARGET_KILL_LAB_PET_SEPCBAT] = checkMaskHas,
	[TriggerConst.TRIGGER_TARGET_REPORT_CATCH_TOTAL_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_HOME_PLACE_FURNITURE_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_HOME_PALCE_PET_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_GROUP_TOUR_ACTIVATE_TIMES_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_ROGUE_EXCHANGE_BOX_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_PET_UPGRADE_STAR_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_TAKE_PHOTO_BY_SUBJECT_AREA_COUNT] = TriggerUtils._checkPhotoSubjectArea,
	[TriggerConst.TRIGGER_TARGET_TAKE_PHOTO_BY_SUBJECT_STUDIO_COUNT] = TriggerUtils._checkPhotoSubjectArea,
	[TriggerConst.TRIGGER_TARGET_TAKE_PHOTO_BY_POS_AND_OBJECT] = TriggerUtils._checkPhotoByPosAndObject,
	[TriggerConst.KILL_PET_TEMPLATE_BY_ELEMENTAL_RELATION] = TriggerUtils._checkAdvantageKillPuppet,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_UP_MAPBLOCK] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_LEYLINETREE_UP_CAPTURE] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_ADD_RUNE_COUNT] = TriggerUtils._checkQualityReach,
	[TriggerConst.TRIGGER_TARGET_GET_ITEMS_BYCONDITION] = TriggerUtils._checkAllConditionsMet,
	[TriggerConst.TRIGGER_TARGET_BOSS_REWARD_RECEIVE_COUNT] = TriggerUtils._checkExtraArgBossRewardReceive,
	[TriggerConst.TRIGGER_TARGET_CATCH_COUNT] = TriggerUtils._checkIncludesLabel,
	[TriggerConst.TRIGGER_TARGET_PET_COUNT_LEVELUP] = TriggerUtils._checkPetCountLevelup,
	[TriggerConst.TRIGGER_TARGET_PET_AI_MSG_SPECIAL] = TriggerUtils._checkPetAIMsgSpecial,
	[TriggerConst.TRIGGER_TARGET_ROBEGG_RAINBOW_ITEM_COUNT] = checkMatchOrZero,
	[TriggerConst.TRIGGER_TARGET_PARTY_CLEAR_DUNGEON] = TriggerUtils._checkPartyClearDungeon
}

local TRIGGER_CONDITION_FUNC_CLIENT_ONLY = TriggerUtils.TRIGGER_CONDITION_FUNC_CLIENT_ONLY

function TriggerUtils.getTriggerType(cond)
	local tmdd = cond and TriggerData[cond[TriggerConst.CUSTOM_TRIGGER_NAME_POS]]

	return tmdd and tmdd.trigger or nil
end

function TriggerUtils.isCountTrigger(trigger)
	return TriggerConst.TRIGGER_STATIS_TYPE_COUNT == TriggerMapData[trigger]
end

function TriggerUtils.needRecordTriggerCount(trigger)
	return TriggerConst.TRIGGER_STATIS_TYPE_COUNT == TriggerMapData[trigger] or TRIGGER_CONDITION_FUNC_SERVER_ONLY[trigger] or TRIGGER_CONDITION_FUNC_CLIENT_ONLY[trigger]
end

function TriggerUtils.usePresetConditionValue(trigger)
	return TRIGGER_CONDITION_FUNC_CLIENT_ONLY[trigger] or trigger == TriggerConst.TRIGGER_TARGET_PET_CONSUME or trigger == TriggerConst.TRIGGER_TARGET_ITEM_CONSUME
end

function TriggerUtils.getCountTriggerAddValue(addCnt, trigger, triggerParams, extraArg)
	if extraArg == nil then
		return addCnt
	elseif triggerParams == nil then
		return 0
	end

	local isOk = false
	local compFunc = TriggerUtils.COUNT_TRIGGER_EXTARG_COMP_FUNC[trigger]

	if compFunc ~= nil then
		isOk = compFunc(extraArg, triggerParams) == true
	else
		isOk = Utils.isTableEqual(extraArg, triggerParams)
	end

	return isOk and addCnt or 0
end

if pg.component ~= "client" then
	function TriggerUtils.getStatusTriggerCurValue(obj, trigger, arg, extraArg, triggerParams)
		if Utils.isPetInfoType(obj) and trigger < TriggerConst.PET_TRIGGER_TARGET_MIN then
			ALARM("Invalid config, PetInfo use invlaid PET_TRIGGER:%d", trigger)

			return 0
		end

		local funcCommon = TRIGGER_CONDITION_FUNC[trigger]

		if funcCommon ~= nil then
			return funcCommon(obj, arg, extraArg, triggerParams)
		end

		local funcServer = TRIGGER_CONDITION_FUNC_SERVER_ONLY[trigger]

		if funcServer ~= nil and pg.component == "game" then
			return funcServer(obj, arg, extraArg, triggerParams)
		end

		local funcClient = TRIGGER_CONDITION_FUNC_CLIENT_ONLY[trigger]

		if funcClient ~= nil and pg.component == "client" then
			return funcClient(obj, arg, extraArg, triggerParams)
		end

		ALARM("Status trigger:%d must has CONDITION_FUNC!!!", trigger)
	end
else
	local _clientTriggerFunc = {}

	for trigger, func in pairs(TRIGGER_CONDITION_FUNC_CLIENT_ONLY) do
		_clientTriggerFunc[trigger] = func
	end

	for trigger, func in pairs(TRIGGER_CONDITION_FUNC) do
		_clientTriggerFunc[trigger] = func
	end

	setmetatable(_clientTriggerFunc, {
		__index = function(t, trigger)
			ALARM("Status trigger:%d must has CONDITION_FUNC!!!", trigger)

			return nil
		end
	})

	function TriggerUtils.getStatusTriggerCurValue(obj, trigger, arg, extraArg, triggerParams)
		local funcCommon = _clientTriggerFunc[trigger]

		if funcCommon ~= nil then
			return funcCommon(obj, arg, extraArg, triggerParams)
		end
	end
end

local function GE_FUNC(curCount, needCount)
	return needCount <= curCount
end

local COMPARE_FUNC = {
	[">="] = GE_FUNC,
	[">"] = function(curCount, needCount)
		return needCount < curCount
	end,
	["<="] = function(curCount, needCount)
		return curCount <= needCount
	end,
	["<"] = function(curCount, needCount)
		return curCount < needCount
	end,
	["="] = function(curCount, needCount)
		return curCount == needCount
	end,
	["!="] = function(curCount, needCount)
		return curCount ~= needCount
	end,
	[""] = GE_FUNC
}

setmetatable(COMPARE_FUNC, {
	__index = function()
		return GE_FUNC
	end
})

function TriggerUtils.checkMeetOperator(curCount, needCount, operator)
	if not curCount or not needCount then
		return false
	end

	local func = COMPARE_FUNC[operator]

	return func(curCount, needCount)
end

local CUSTOM_TRIGGER_TARGET_POS = TriggerConst.CUSTOM_TRIGGER_TARGET_POS
local CUSTOM_TRIGGER_EXTAR_TARGET_POS = TriggerConst.CUSTOM_TRIGGER_EXTAR_TARGET_POS
local CUSTOM_TRIGGER_OPERATOR_POS = TriggerConst.CUSTOM_TRIGGER_OPERATOR_POS
local CUSTOM_TRIGGER_NUM_POS = TriggerConst.CUSTOM_TRIGGER_NUM_POS

function TriggerUtils.checkSingleStatusCondition(obj, cond)
	local triggerType = TriggerUtils.getTriggerType(cond)

	if TriggerUtils.isCountTrigger(triggerType) or TRIGGER_CONDITION_FUNC_CLIENT_ONLY[triggerType] and pg.component == "game" or TRIGGER_CONDITION_FUNC_SERVER_ONLY[triggerType] and pg.component == "client" then
		ALARM("checkSingleStatusCondition with invalid triggerType=%d, %s", triggerType, inspect(cond))

		return false
	end

	local arg = cond[CUSTOM_TRIGGER_TARGET_POS]
	local extraArg = cond[CUSTOM_TRIGGER_EXTAR_TARGET_POS]
	local operator = cond[CUSTOM_TRIGGER_OPERATOR_POS]
	local dstCount = cond[CUSTOM_TRIGGER_NUM_POS]
	local curCount = TriggerUtils.getStatusTriggerCurValue(obj, triggerType, arg, extraArg, nil)

	return TriggerUtils.checkMeetOperator(curCount, dstCount, operator)
end

function TriggerUtils.getConditionByRegInfo(regType, templateId, pos)
	if regType == TriggerConst.TRIGGER_REGTYPE_CUSTOM then
		local ctdd = CustomTriggerData[templateId]

		return ctdd and ctdd.condition and ctdd.condition[pos]
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE then
		local qdd = QuestBase[templateId]

		return qdd and qdd.objectives and qdd.objectives[pos] and qdd.objectives[pos].paramVals
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND then
		local qdd = QuestBase[templateId]

		return qdd and qdd.claimCond and qdd.claimCond.condition and qdd.claimCond.condition[pos]
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND then
		local qdd = QuestBase[templateId]

		return qdd and qdd.runCond and qdd.runCond.condition and qdd.runCond.condition[pos]
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE then
		local qdd = QuestBase[templateId]

		return qdd and qdd.comActionObjcvs and qdd.comActionObjcvs[pos] and qdd.comActionObjcvs[pos].paramVals
	elseif regType == TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND then
		local qdd = QuestBase[templateId]

		return qdd and qdd.closeCond and qdd.closeCond.condition and qdd.closeCond.condition[pos]
	end
end

return TriggerUtils
