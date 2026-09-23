-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\PetResearchUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetResearchUtils")
local PetResearchCountryLevelData = require("Data.pet_research_country_level_data")
local PetPrototypeToBlockMap = require("Data.pet_prototype_to_block_map")
local CommonSwitch = require("Common.CommonSwitch")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetResearchNumberToId = require("Data.pet_research_number_to_id")
local PetResearchCountrySpeciesList = require("Data.pet_research_country_species_list")
local PetResearchCountryFormList = require("Data.pet_research_country_form_list")
local PetResearchContentData = require("Data.pet_research_content_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AbilityParamData = require("Data.ability_param_data")
local DropData = require("Data.drop_data")
local PetTraitData = require("Data.pet_trait_data")
local PetAvatarData = require("Data.pet_avatar_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local PetEvolveData = require("Data.pet_evolve_data")
local PetResearchRewardData = require("Data.pet_research_reward_data")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PlayerLevelData = require("Data.player_level_data")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientConst = require("Const.ClientConst")
local PetProtoTypeData = require("Data.pet_prototype_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetCountryCollectData = require("Data.pet_research_country_collect_data")
local PetCountrySpeciesCollectData = require("Data.pet_research_country_species_collect_data")
local math_ceil = math.ceil
local PetEvolveItemSubData = require("Data.pet_evolve_item_sub_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local PetResearchUtils = {}
local ClientTextUtils = require("Utils.ClientTextUtils")
local CustomEnData = require("Data.I18N.custom_en_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local PetResearchTargetData = require("Data.pet_research_target_data")
local PetData = require("Data.pet_data")

PetResearchUtils.PET_STATE_IS_KNOWN = 2
PetResearchUtils.PET_STATE_IS_EMPTY = 3
PetResearchUtils.PET_STATE_IS_CATCH = 1
PetResearchUtils.PET_STATE_IS_AllSTAR = 0
PetResearchUtils.ORDER_TYPE_NO = 1
PetResearchUtils.ORDER_TYPE_LEVEL = 2
PetResearchUtils.REWARD_NORMAL = 0
PetResearchUtils.REWARD_RECEIVED = 1
PetResearchUtils.REWARD_CAN_GOT = 2
PetResearchUtils.COUNTRY_START_PAGE_COUNT = 6
PetResearchUtils.TAB_IDX = {
	EVOLUTION = 2,
	ABILITY = 1,
	SURVEY = 0,
	TOPIC = 3
}
PetResearchUtils.PET_SHOW_TAB = {
	FORM = 1,
	SPECIES = 0
}
PetResearchUtils.DEFAULT_AREA_ID = 300001
PetResearchUtils.COLLECTION_NATION = 1000
PetResearchUtils.TooltipIds = {
	[PetResearchUtils.PET_SHOW_TAB.SPECIES] = {
		"PETMANUAL_COUNT_TXT_1_SPECIES",
		"PETMANUAL_COUNT_TXT_2_SPECIES",
		"PETMANUAL_COUNT_TXT_3_SPECIES"
	},
	[PetResearchUtils.PET_SHOW_TAB.FORM] = {
		"PETMANUAL_COUNT_TXT_1",
		"PETMANUAL_COUNT_TXT_2",
		"PETMANUAL_COUNT_TXT_3"
	}
}
PetResearchUtils.ShowTabName = {
	[PetResearchUtils.PET_SHOW_TAB.SPECIES] = "SPECIES",
	[PetResearchUtils.PET_SHOW_TAB.FORM] = "FORM"
}
PetResearchUtils.HandbookIcon = {
	AddressDataConst.UI_HANDBOOK_DISTRIBUTE_ICON_CAUGHT,
	AddressDataConst.UI_HANDBOOK_DISTRIBUTE_ICON_SHINY,
	AddressDataConst.UI_HANDBOOK_DISTRIBUTE_ICON_RAINBOW
}

function PetResearchUtils.openResearchDetail(templateId, subPageIdx, externalInfo, loadedCb)
	if PetResearchUtils.inDetailLoading then
		return
	end

	PetResearchUtils.inDetailLoading = true
	externalInfo = externalInfo or {}

	local ret = PetResearchUtils.openPetResearchDetail({
		templateId = Utils.getBasePetPrototypeId(templateId),
		subPageIdx = subPageIdx,
		branchId = externalInfo.branchId,
		closeCb = externalInfo.closeCb,
		countryId = externalInfo.countryId,
		formTargetTemplateId = externalInfo.formTargetTemplateId,
		formTargetLabel = externalInfo.formTargetLabel,
		formTargetShinyStyle = externalInfo.formTargetShinyStyle
	}, function()
		PetResearchUtils.inDetailLoading = nil

		if loadedCb then
			loadedCb()
		end
	end)

	if not ret then
		PetResearchUtils.inDetailLoading = nil
	end
end

function PetResearchUtils.isKnownAndCaught(templateId)
	local petHandbookMap = pg.me.petHandbookMap
	local baseTemplateId = Utils.getBasePetPrototypeId(templateId)

	if petHandbookMap:isKnown(baseTemplateId) and petHandbookMap:isCatched(baseTemplateId) then
		return true
	end

	return false
end

function PetResearchUtils.isShowInDetail(templateId)
	if not templateId then
		return false
	end

	local cfg = PetResearchContentData[templateId]

	return cfg and cfg.isShow ~= 0 or false
end

function PetResearchUtils.openPetResearchDetail(info, callback)
	local templateId = info.templateId
	local petHandbookMap = pg.me.petHandbookMap
	local dropId = PetAvatarData[templateId][0].reward
	local point = PetResearchUtils.getRewardResearchPoint(dropId or 0)
	local baseTemplateId = Utils.getBasePetPrototypeId(templateId)

	if not petHandbookMap:isKnown(baseTemplateId) then
		pg.global.showBubbleMessage(NoticeDef.PET_RESEARCH_UNCAUGHT, point)

		return
	end

	if not petHandbookMap:isCatched(baseTemplateId) then
		pg.global.showBubbleMessage(NoticeDef.PET_RESEARCH_UNCAUGHT, point)

		return
	end

	pg.global.ui.petResearchDetailV2:open(info or {}, callback)

	return true
end

function PetResearchUtils.openBranchSelect(petId, callback, extraInfo)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		extraInfo = extraInfo or {}

		LuaUIUtils.tryOpenPetCultivateUI({
			ignoreUIScene = true,
			petId = petId,
			selectPetList = extraInfo.selectPetList,
			pvpFailMode = extraInfo.pvpFailMode,
			toPage = extraInfo.toPage,
			onlyShowSkillPage = extraInfo.onlyShowSkillPage,
			notPetManagement = extraInfo.notPetManagement
		})

		if callback then
			callback(0)
		end

		return
	end

	LuaUIUtils.tryOpenPetCultivateUI({
		petId = petId,
		selectPetList = extraInfo.selectPetList,
		pvpFailMode = extraInfo.pvpFailMode,
		toPage = extraInfo.toPage,
		onlyShowSkillPage = extraInfo.onlyShowSkillPage,
		notPetManagement = extraInfo.notPetManagement
	}, nil, nil, {
		isBranchSelect = true,
		petId = petId
	})
end

function PetResearchUtils.checkFriendCatch(petPrototypeId)
	local friendList = pg.game.chat:getFriendList() or {}

	for _, info in ipairs(friendList) do
		if info.playerId then
			local playerInfo = pg.game.chat:getPlayerInfo(info.playerId)

			if playerInfo then
				local blockCatchedMap = playerInfo.blockCatchedPetMap or Utils.getStableAttributesValue(playerInfo, "blockCatchedPetMap")

				if Utils.isPetCatched(playerInfo, petPrototypeId) and blockCatchedMap then
					local blockIds = PetPrototypeToBlockMap[petPrototypeId] or {}
					local blockId

					for _, bId in ipairs(blockIds) do
						local blockCatchedInfo = blockCatchedMap[bId]

						if blockCatchedInfo and blockCatchedInfo[petPrototypeId] and blockCatchedInfo[petPrototypeId].isCatched then
							blockId = bId

							break
						end
					end

					return true, info.playerId, blockId
				end
			end
		end
	end

	return false, nil, nil
end

function PetResearchUtils.checkPetCanEvolve(petId)
	local petInfo = pg.me:getPetInfo(petId)

	return petInfo:canEvolveAny()
end

function PetResearchUtils.tryOpenPetEvolutionUI(petId)
	local pet = pg.me and pg.me:getPetInfo(petId)

	if not pet then
		return
	end

	local petTempId = pet.templateId
	local researchContentData = PetResearchContentData[petTempId]

	if not researchContentData then
		pg.global.showBubbleMessageRaw(pg.getGameString("TRAINING_NOT_VALID"))

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("PetResearchUtils.tryOpenPetEvolutionUI petTempId not found in [PetResearchContentData] !!!", petTempId)
		end

		return
	end

	local canEvolve = PetEvolveData[petTempId] and PetEvolveData[petTempId][1] and PetEvolveData[petTempId][1].targetPetId

	if not canEvolve then
		pg.global.showBubbleMessageRaw(pg.getGameString("CURRENT_PET_CANT_EVOLUTION"), 2)

		return
	end

	pg.global.ui.petEvolution:open({
		petId = petId
	})
end

function PetResearchUtils.getCountryResearchContentById(countryId)
	return PetResearchCountryLevelData[countryId]
end

function PetResearchUtils.showPetFirst(info)
	if IS_MOBILE then
		info.lowMode = true
		info.ignoreUIScene = true

		pg.global.ui.firstPetShow:open(info)
	else
		pg.global.ui.firstPetShow:open(info, nil, nil, {
			ignoreDisableMainCamera = true
		})
	end
end

function PetResearchUtils.getEvolutionItemConditionData(itemState, itemData)
	local ret = {}
	local player = pg.me
	local altIdNumDict = {}

	for _, needItemData in pairs(itemData or EMPTY_TABLE) do
		local needItem = needItemData[Const.PET_EVOLVE_ITEM_COND_POS_ITEM]
		local needItemId, _ = needItem[1], needItem[2]
		local altData = PetEvolveItemSubData[needItemId]

		if altData then
			altIdNumDict[altData.alternativeItem] = ItemUtils.getItemCountById(player, altData.alternativeItem)
		end
	end

	itemData = itemData or {}

	for idx, info in ipairs(itemData) do
		local data = {}
		local state = itemState[idx]
		local itemInfo = info[1]

		data.id = itemInfo[1]
		data.num = itemInfo[2]

		local reached = false

		if state == Const.PET_RESEARCH.STATUS_CLUE then
			data.desc = pg.getLocalizationText(info[2])
		elseif state == Const.PET_RESEARCH.STATUS_SHOW then
			data.desc = pg.getLocalizationText(info[3])
			reached = true
		elseif state == Const.PET_RESEARCH.STATUS_HIDE then
			data.desc = "????"
		end

		local itemCount = ItemUtils.getItemCountById(player, data.id)

		if itemCount >= data.num then
			data.realItem = {
				checked = true,
				itemId = data.id,
				itemCount = data.num,
				ownCount = itemCount
			}
		else
			local altData = PetEvolveItemSubData[data.id]

			if altData then
				local altNeedCount = math_ceil((data.num - itemCount) / altData.num * altData.alternativeItemNum)
				local hasAltCount = altIdNumDict[altData.alternativeItem]

				if altNeedCount <= hasAltCount then
					data.realItem = {
						checked = true,
						itemId = data.id,
						itemCount = itemCount,
						altItem = altData.alternativeItem,
						altCount = altNeedCount
					}
				else
					local altItemCount = math_ceil(hasAltCount / altData.alternativeItemNum * altData.num)

					data.realItem = {
						checked = false,
						itemId = data.id,
						itemCount = itemCount + altItemCount
					}
				end

				altIdNumDict[altData.alternativeItem] = hasAltCount - altNeedCount
			else
				data.realItem = {
					checked = false,
					itemId = data.id,
					itemCount = itemCount
				}
			end
		end

		data.reached = reached
		ret[#ret + 1] = data
	end

	return ret
end

PetResearchUtils.LEVEL_QUALITY_NAME = {
	[0] = "Gray",
	"Coppery",
	"Silver",
	"Golden",
	"Pink"
}

function PetResearchUtils.getPetResearchPoint(templateId)
	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap
	local playerData = playerHandBookMap[templateId]
	local rewardData = PetResearchRewardData[templateId]
	local researchContent = PetResearchContentData[templateId]
	local needResearchPoint = researchContent.needResearchPoint

	ret.level = playerData.level
	ret.exp = playerData.exp

	local nextLevel = math.min(playerData.level + 1, Const.PET_RESEARCH_REWARD_LEVEL_MAX)
	local needExp = needResearchPoint and needResearchPoint[nextLevel] or 0

	if nextLevel == ret.level then
		ret.exp = needExp
	end

	local targetInfo = rewardData[nextLevel]

	ret.needExp = needExp

	local defaultReward = researchContent.defaultReward

	if defaultReward then
		ret.reward = {
			type = 0,
			id = defaultReward[1],
			num = defaultReward[2]
		}
	else
		local rewardId = targetInfo.reward
		local rewardInfo = LuaUIUtils.getRewardItemByDropId(rewardId)

		if rewardInfo then
			ret.reward = rewardInfo[1]
		end
	end

	return ret
end

function PetResearchUtils.getPetResearchContent(templateId)
	local prototypeData = templateId and PetProtoTypeData[templateId]

	if not prototypeData then
		return nil
	end

	local baseFormPet = prototypeData.baseFormPet
	local oriResearchData = PetResearchContentData[templateId]
	local baseFormResearchData = PetResearchContentData[baseFormPet]

	if not baseFormResearchData then
		return nil
	end

	if oriResearchData then
		local oriScale = oriResearchData.scale
		local oriModelPos = oriResearchData.modelPos
		local oriModelRotation = oriResearchData.modelRotation
		local oriModelPosOther = oriResearchData.modelPosOther
		local oriModelRotationOther = oriResearchData.modelRotationOther
		local oriCountryId = templateId ~= baseFormPet and oriResearchData.countryId or nil

		if oriScale ~= nil or oriModelPos ~= nil or oriModelRotation ~= nil or oriModelPosOther ~= nil or oriModelRotationOther ~= nil or oriCountryId ~= nil then
			local contentData = setmetatable({}, {
				__index = baseFormResearchData
			})

			if oriScale ~= nil then
				contentData.scale = oriScale
			end

			if oriModelPos ~= nil then
				contentData.modelPos = oriModelPos
			end

			if oriModelRotation ~= nil then
				contentData.modelRotation = oriModelRotation
			end

			if oriModelPosOther ~= nil then
				contentData.modelPosOther = oriModelPosOther
			end

			if oriModelRotationOther ~= nil then
				contentData.modelRotationOther = oriModelRotationOther
			end

			if oriCountryId ~= nil then
				contentData.countryId = oriCountryId
			end

			return contentData
		end
	end

	return baseFormResearchData
end

function PetResearchUtils.getNearestCamp()
	local SceneUtils = require("Common.Utils.SceneUtils")
	local player = pg.me
	local sceneId = SceneUtils.getMainSceneId(player.space.sceneId)
	local statusMap = player.mapMarkStatusMap[sceneId] or {}
	local campStatus = statusMap[Const.MAP_MARK_CAMP] or {}
	local minDist = math.maxFloat
	local targetPos
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(sceneId)

	for staticId, status in pairs(campStatus) do
		if status == Const.MAP_MARK_STATUS_UNLOCKED then
			local position = sceneMarkPointData[staticId].markPosition
			local dist = Vector3.SqrDistance(player:getPosition(), position)

			if dist < minDist then
				dist = minDist
				targetPos = position
			end
		end
	end

	return targetPos
end

function PetResearchUtils.getMainCamp()
	local SceneUtils = require("Common.Utils.SceneUtils")
	local player = pg.me
	local sceneId = Const.SCENE_ID.COT
	local statusMap = player.mapMarkStatusMap[sceneId] or {}
	local campStatus = statusMap[Const.MAP_MARK_CAMP] or {}
	local minDist = math.maxFloat
	local targetStaticId
	local curSceneId = player.space and SceneUtils.getMainSceneId(player.space.sceneId)

	if curSceneId ~= sceneId then
		for staticId, status in pairs(campStatus) do
			if status == Const.MAP_MARK_STATUS_UNLOCKED then
				return staticId, sceneId
			end
		end

		return targetStaticId, sceneId
	end

	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(sceneId)
	local playerPos = player:getPosition()

	for staticId, status in pairs(campStatus) do
		if status == Const.MAP_MARK_STATUS_UNLOCKED then
			local markPoint = sceneMarkPointData and sceneMarkPointData[staticId]

			if markPoint and markPoint.markPosition then
				local dist = Vector3.SqrDistance(playerPos, markPoint.markPosition)

				if dist < minDist then
					minDist = dist
					targetStaticId = staticId
				end
			end
		end
	end

	return targetStaticId, sceneId
end

function PetResearchUtils.renderCountryStar(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local goldenProgress = objectReference:GetRefValue("goldenProgress")
	local multiColorProgress = objectReference:GetRefValue("multiColorProgress")

	button:TryChangePage("StarType", data.goldenStateIdx)

	if not data.isGolden then
		goldenProgress.maxValue = 1
		goldenProgress.value = 1
		multiColorProgress.maxValue = data.progressMax
		multiColorProgress.value = data.progressValue
	else
		goldenProgress.maxValue = data.progressMax
		goldenProgress.value = data.progressValue
	end
end

function PetResearchUtils.getPetSurveyPoint(templateId)
	local handbookMap = pg.me.petHandbookMap
	local handbookInfo = handbookMap[templateId]
	local curPetTemplateId = templateId
	local traitData = PetTraitData[curPetTemplateId] or {}
	local sumResearchPoint = 0
	local curResearchPoint = 0

	for traitId, info in pairs(traitData) do
		sumResearchPoint = sumResearchPoint + (info.reward or 0)

		local traitState = handbookInfo:getTraitResearchInfoWithDefault(traitId).status

		if traitState == Const.PET_RESEARCH.STATUS_SHOW then
			curResearchPoint = curResearchPoint + (info.reward or 0)
		end
	end

	local formTemplateIds = PetBasePrototypeToPrototypeMap[curPetTemplateId]

	for idx, formTemplateId in pairs(formTemplateIds) do
		local petAvatarData = PetAvatarData[formTemplateId]

		if petAvatarData then
			handbookInfo = handbookMap[formTemplateId]

			for formId, info in pairs(petAvatarData) do
				if formId == Const.PET_LABEL_MASK.NORMAL and handbookInfo and handbookInfo:isCatched() then
					curResearchPoint = curResearchPoint + PetResearchUtils.getRewardResearchPoint(info.reward or 0)
				elseif formId == Const.PET_LABEL_MASK.SHINY and handbookInfo and handbookInfo:isShinyCatched() then
					curResearchPoint = curResearchPoint + PetResearchUtils.getRewardResearchPoint(info.reward or 0)
				end

				sumResearchPoint = sumResearchPoint + PetResearchUtils.getRewardResearchPoint(info.reward or 0)
			end
		end
	end

	return {
		curResearchPoint,
		sumResearchPoint
	}
end

function PetResearchUtils.getCountryFullProgress(countryId, showTab)
	local displayMode = showTab or PetResearchUtils.getLastPetShowTab()
	local isSpecies = displayMode == PetResearchUtils.PET_SHOW_TAB.SPECIES
	local petHandbookMap = pg.me.petHandbookMap
	local curNum = isSpecies and petHandbookMap:getCatchedSpeciesCount(countryId) or petHandbookMap:getFormCatchedCount(countryId, 0)
	local countryData = isSpecies and PetCountrySpeciesCollectData[countryId] or PetCountryCollectData[countryId]

	if countryData == nil then
		return curNum, curNum
	end

	local maxLevel = table.maxn(countryData)
	local finalLevelConfig = countryData[maxLevel]

	return curNum, finalLevelConfig.collectNum
end

function PetResearchUtils.getCountryBaseProgress(countryId)
	local petHandbookMap = pg.me.petHandbookMap
	local curNum = petHandbookMap:getFormCatchedCount(countryId, 1)
	local countryData = PetCountryCollectData[countryId]
	local maxLevel = table.maxn(countryData)
	local finalLevelConfig = countryData[maxLevel]

	return curNum, finalLevelConfig.collectNum
end

function PetResearchUtils.getCountryStarData(countryId)
	local countryData = PetResearchCountryLevelData[countryId]

	if not countryData then
		return {}
	end

	local petHandbookMap = pg.me.petHandbookMap
	local curLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)

	return PetResearchUtils.getStarListByLevel(curLevel, remain, countryData)
end

function PetResearchUtils.getCountryLevelInfo(countryId)
	local countryData = PetResearchCountryLevelData[countryId]

	if not countryData then
		return 0, 0, 0, false
	end

	local petHandbookMap = pg.me.petHandbookMap

	if not petHandbookMap then
		return 0, 0, 0, false
	end

	local curLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)
	local prcldd = PetResearchCountryLevelData[countryId]
	local nextLevel = curLevel + 1

	if prcldd[nextLevel] then
		local needExp = prcldd[nextLevel].needResearchPoint - (prcldd[curLevel].needResearchPoint or 0)

		return curLevel, remain, needExp, false
	else
		local needExp = prcldd[curLevel].needResearchPoint - (prcldd[curLevel - 1].needResearchPoint or 0)

		return curLevel, remain + needExp, needExp, true
	end
end

function PetResearchUtils.resolvePetResearchAreaId(info)
	if info and info.areaId then
		return info.areaId
	end

	if info and info.templateId then
		local areaId = Utils.getPetCountryId(info.templateId)

		if areaId ~= 0 then
			return areaId
		end
	end

	return PetResearchUtils.getLastPetResearchAreaId()
end

function PetResearchUtils.openPetResearch(info)
	if pg.me:checkFunctionUnlock("PETRESEARCH") and CommonSwitch.PETRESEARCH then
		local needOpenAreaPage = PetResearchUtils.checkNeedOpenAreaPageUI()

		if needOpenAreaPage then
			pg.global.ui.petResearchCountryPage:open(info)

			return
		end

		if pg.me.isUIOpened[UIConst.UI_ID_PET_RESEARCH] then
			pg.global.ui.petResearch:open(info)
		else
			pg.global.ui.petResearchLoading:open(info)
		end
	end
end

function PetResearchUtils.CountryPageUIGoToPetResearchUI(info)
	if pg.me.isUIOpened[UIConst.UI_ID_PET_RESEARCH] then
		pg.global.ui.petResearchFrontPageV2:close()

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_RESEARCH) then
			pg.global.ui.petResearch:onOpen(info)
		else
			pg.global.ui.petResearch:open(info)
		end
	else
		pg.global.ui.petResearchLoading:open(info)
	end
end

function PetResearchUtils.getStarListByLevel(curLevel, curProgress, countryData)
	local baseLevel = curLevel <= PetResearchUtils.COUNTRY_START_PAGE_COUNT and 0 or PetResearchUtils.COUNTRY_START_PAGE_COUNT
	local isGolden = baseLevel < PetResearchUtils.COUNTRY_START_PAGE_COUNT
	local ret = {}

	for idx = 1, PetResearchUtils.COUNTRY_START_PAGE_COUNT do
		local item = {}
		local level = baseLevel + idx
		local info = countryData[level]

		if level <= curLevel then
			item.progressMax = 1
			item.progressValue = 1
		elseif level == curLevel + 1 then
			item.progressMax = info.needResearchPoint - (countryData[level - 1].needResearchPoint or 0)
			item.progressValue = curProgress
		else
			item.progressMax = 1
			item.progressValue = 0
		end

		item.goldenStateIdx = isGolden and 0 or 1
		item.isGolden = isGolden
		ret[#ret + 1] = item
	end

	return ret
end

function PetResearchUtils.getTotalNeedResearchPoint(templateId)
	templateId = Utils.getBasePetPrototypeId(templateId)

	local researchContent = PetResearchContentData[templateId]

	if not researchContent then
		return 0
	end

	local needResearchPoint = researchContent.needResearchPoint

	if not needResearchPoint then
		return 0
	end

	local sum = 0

	for _, num in ipairs(needResearchPoint) do
		sum = sum + num
	end

	return sum
end

function PetResearchUtils.getPetResearchFullProgress(templateId)
	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap

	templateId = Utils.getBasePetPrototypeId(templateId)

	local playerData = playerHandBookMap[templateId]
	local rewardData = PetResearchRewardData[templateId]
	local researchContent = PetResearchContentData[templateId]
	local needResearchPoint = researchContent.needResearchPoint

	ret.isResearched = playerData:isResearched()
	ret.level = playerData.level

	local sum = 0
	local cur = 0

	for idx = 1, Const.PET_RESEARCH_REWARD_LEVEL_SHOW_MAX do
		sum = sum + needResearchPoint[idx]
		ret["levelNeed" .. idx] = needResearchPoint[idx]

		if idx <= playerData.level then
			ret["levelGot" .. idx] = needResearchPoint[idx]
		elseif idx == playerData.level + 1 then
			ret["levelGot" .. idx] = playerData.exp
		else
			ret["levelGot" .. idx] = 0
		end

		cur = cur + ret["levelGot" .. idx]
	end

	for idx = 1, Const.PET_RESEARCH_REWARD_LEVEL_SHOW_MAX do
		ret["levelRatio" .. idx] = needResearchPoint[idx] / sum
	end

	if playerData.level >= Const.PET_RESEARCH_REWARD_LEVEL_SHOW_MAX then
		sum = sum + needResearchPoint[Const.PET_RESEARCH_REWARD_LEVEL_MAX]
		cur = cur + playerData.exp
	end

	ret.needExp = sum
	ret.exp = cur

	local nextLevel = math.min(playerData.level + 1, Const.PET_RESEARCH_REWARD_LEVEL_MAX)
	local targetInfo = rewardData[nextLevel]
	local defaultReward = researchContent.defaultReward

	if defaultReward then
		ret.reward = {
			tIndex = 0,
			type = 0,
			id = defaultReward[1],
			num = defaultReward[2]
		}
	else
		local rewardId = targetInfo.reward
		local rewardInfo = LuaUIUtils.getRewardItemByDropId(rewardId)

		if rewardInfo then
			ret.reward = rewardInfo[1]
		end
	end

	ret.icon = targetInfo.icon

	return ret
end

function PetResearchUtils.setRewardList(button, idx, data)
	LuaUIUtils.renderRewards(button, idx, data)
end

function PetResearchUtils.checkHasPetRedDotInCountry(countryId)
	local playerHandBookMap = pg.me.petHandbookMap

	for _, templateId in pairs(PetResearchUtils.getPetResearchSpeciesList(countryId)) do
		if templateId and PetResearchContentData[templateId] and PetResearchContentData[templateId].isShow ~= 0 and (not countryId or PetResearchUtils.checkPetHasFormInCountry(templateId, countryId)) then
			local playerData = playerHandBookMap[templateId]

			if playerData and playerData:isCatched() and PetResearchUtils.checkPetTemplateIsNew(templateId) then
				return RedDotConst.RedDotStyle.NEW
			end
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function PetResearchUtils.checkHasStarRaiseInReport(countryId)
	local player = pg.me
	local countryMap = player.petHandbookMap.petCountryMap[countryId]

	if countryMap then
		local reportPoint = countryMap.researchReportMap:getTotalPoint()
		local petHandbookMap = pg.me.petHandbookMap
		local curLevel, remain = petHandbookMap:getCountryTotalLevel(countryId)
		local prcldd = PetResearchCountryLevelData[countryId]
		local nextLevel = curLevel + 1

		if prcldd[nextLevel] then
			local needExp = prcldd[nextLevel].needResearchPoint - (prcldd[curLevel].needResearchPoint or 0)

			if needExp <= reportPoint + remain then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils.checkHasPetRewardByTemplateId(templateId)
	return false
end

function PetResearchUtils.checkHasTopicRewardByTemplateId(templateId)
	local playerData = pg.me.petHandbookMap

	templateId = Utils.getBasePetPrototypeId(templateId)

	local hasReward = PetResearchUtils._checkPetHasTopicReward(templateId, playerData)

	return hasReward
end

function PetResearchUtils.getPetAllTopicRewardByTemplateId(templateId)
	local res = {}
	local petHandbookMap = pg.me.petHandbookMap

	templateId = Utils.getBasePetPrototypeId(templateId)

	local petHandBookInfo = petHandbookMap[templateId]
	local conditions = PetResearchTargetData[templateId]
	local rewardMap = petHandBookInfo.rewardedTargetMap or {}
	local completedTargetMap = petHandBookInfo.completedTargetMap or {}

	if petHandBookInfo and conditions then
		for i, v in ipairs(conditions) do
			for j, conditionInfo in ipairs(v.condition or EMPTY_TABLE) do
				local isComplete = completedTargetMap[i] and completedTargetMap[i][j]

				if isComplete and conditionInfo[4] then
					local hasGet = rewardMap[i] and rewardMap[i][j]

					if not hasGet then
						local temp = {
							templateId,
							i,
							j
						}

						table.insert(res, temp)
					end
				end
			end
		end
	end

	return res
end

function PetResearchUtils.checkHasTopicReward(allPetList)
	local playerData = pg.me.petHandbookMap
	local hashMap = {}

	for k, petData in ipairs(allPetList) do
		local templateId = Utils.getBasePetPrototypeId(petData.templateId)

		if not hashMap[templateId] then
			hashMap[templateId] = true

			local hasReward = PetResearchUtils._checkPetHasTopicReward(templateId, playerData)

			if hasReward then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils.getAllCanGetTopicReward(allPetList)
	local res = {}
	local playerData = pg.me.petHandbookMap
	local hashMap = {}

	for k, petData in ipairs(allPetList) do
		local templateId = Utils.getBasePetPrototypeId(petData.templateId)

		if not hashMap[templateId] then
			hashMap[templateId] = true

			local petHandBookInfo = playerData[templateId]
			local conditions = PetResearchTargetData[templateId]
			local rewardMap = petHandBookInfo.rewardedTargetMap or {}
			local completedTargetMap = petHandBookInfo.completedTargetMap or {}

			if petHandBookInfo and conditions then
				for i, v in ipairs(conditions) do
					for j, conditionInfo in ipairs(v.condition or EMPTY_TABLE) do
						local isComplete = completedTargetMap[i] and completedTargetMap[i][j]

						if isComplete and conditionInfo[4] then
							local hasGet = rewardMap[i] and rewardMap[i][j]

							if not hasGet then
								local temp = {
									templateId,
									i,
									j
								}

								table.insert(res, temp)
							end
						end
					end
				end
			end
		end
	end

	return res
end

function PetResearchUtils.checkHasPetTopicRewardByCountryId(countryId)
	local playerData = pg.me.petHandbookMap

	for _, templateId in pairs(PetResearchUtils.getPetResearchSpeciesList(countryId)) do
		if templateId and PetResearchContentData[templateId] and PetResearchContentData[templateId].isShow ~= 0 and (not countryId or PetResearchUtils.checkPetHasFormInCountry(templateId, countryId)) then
			local hasReward = PetResearchUtils._checkPetHasTopicReward(templateId, playerData)

			if hasReward then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils._checkPetHasTopicReward(templateId, petHandbookMap)
	local petHandBookInfo = petHandbookMap[templateId]
	local conditions = PetResearchTargetData[templateId]

	if petHandBookInfo and conditions then
		local rewardMap = petHandBookInfo.rewardedTargetMap or {}
		local completedTargetMap = petHandBookInfo.completedTargetMap or {}

		for i, v in ipairs(conditions) do
			for j, conditionInfo in ipairs(v.condition or EMPTY_TABLE) do
				local isComplete = completedTargetMap[i] and completedTargetMap[i][j]

				if isComplete and conditionInfo[4] then
					local hasGet = rewardMap[i] and rewardMap[i][j]

					if not hasGet then
						return true
					end
				end
			end
		end
	end

	return false
end

function PetResearchUtils.checkPetTemplateIsNew(templateId)
	return pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_RESEARCH_RED_DOT, string.format(RedDotConst.RedDotPath.PET_RESEARCH_NEW_PET, templateId), true)
end

function PetResearchUtils.setPetTemplateNewRedDot(templateId)
	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_RESEARCH_RED_DOT, string.format(RedDotConst.RedDotPath.PET_RESEARCH_NEW_PET, templateId), false)
end

function PetResearchUtils.getElementsInfo(templateId)
	local pData = PetProtoTypeData[templateId]
	local elementNames = pData.elementType
	local ret = {}

	for idx = 1, #elementNames do
		ret[#ret + 1] = {
			element = elementNames[idx]
		}
	end

	return ret
end

function PetResearchUtils.getPetBaseResearchData(templateId)
	local prototypeData = templateId and PetProtoTypeData[templateId]

	return prototypeData, prototypeData and PetResearchContentData[prototypeData.baseFormPet]
end

function PetResearchUtils.getDisplayNumberByTemplateId(templateId)
	local _, baseResearchData = PetResearchUtils.getPetBaseResearchData(templateId)

	if not baseResearchData then
		return "", false
	end

	local researchData = PetResearchContentData[templateId]

	return LuaUIUtils.getPetDisplayNumber(Utils.getPetCountryId(templateId), researchData and researchData.numberTxt, baseResearchData.number)
end

function PetResearchUtils.getResearchDisplayNumber(templateId, countryId, showTab)
	local prototypeData, baseResearchData = PetResearchUtils.getPetBaseResearchData(templateId)

	if not baseResearchData then
		return "", false
	end

	local numberTxt
	local displayCountryId = countryId or Utils.getPetCountryId(templateId)

	if PetResearchUtils.checkAreaIsCollection(displayCountryId) then
		if showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
			for _, formTemplateId in ipairs(PetBasePrototypeToPrototypeMap[prototypeData.baseFormPet] or {
				templateId
			}) do
				local formResearchData = PetResearchContentData[formTemplateId]

				if Utils.getPetCountryId(formTemplateId) == displayCountryId and formResearchData and formResearchData.numberTxt and formResearchData.numberTxt ~= "" then
					numberTxt = formResearchData.numberTxt

					break
				end
			end
		else
			local researchData = PetResearchContentData[templateId]

			numberTxt = researchData and researchData.numberTxt
		end
	end

	return LuaUIUtils.getPetDisplayNumber(displayCountryId, numberTxt, baseResearchData.number)
end

function PetResearchUtils.checkPetHasFormInCountry(templateId, countryId)
	return Utils.checkPetHasFormInCountry(templateId, countryId)
end

function PetResearchUtils.getPetResearchSpeciesList(countryId)
	return countryId and (PetResearchCountrySpeciesList[countryId] or {}) or PetResearchNumberToId
end

function PetResearchUtils.tryGetPetInfos(orderType, isAscendingOrder, filterTypeList, countryId, showTab)
	if showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
		return PetResearchUtils.tryGetPetInfos_allSpecies(orderType, isAscendingOrder, filterTypeList, countryId, showTab)
	else
		return PetResearchUtils.tryGetPetInfos_allForm(orderType, isAscendingOrder, filterTypeList, countryId, showTab)
	end
end

function PetResearchUtils._hasSpeciesStateMask(playerHandBookMap, templateId, mask, countryId)
	return playerHandBookMap:getFormCountByIdAndStateMask(templateId, mask, countryId) > 0
end

function PetResearchUtils.tryGetPetInfos_allSpecies(orderType, isAscendingOrder, filterTypeList, countryId, showTab)
	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap

	for _, templateId in pairs(PetResearchUtils.getPetResearchSpeciesList(countryId)) do
		local researchData = PetResearchContentData[templateId]

		if researchData and researchData.isShow ~= 0 then
			local number = researchData.number
			local state = PetResearchUtils.PET_STATE_IS_EMPTY

			if PetResearchUtils._hasSpeciesStateMask(playerHandBookMap, templateId, Const.PET_HBMSK_KNOWN, countryId) then
				state = PetResearchUtils.PET_STATE_IS_KNOWN
			end

			if PetResearchUtils._hasSpeciesStateMask(playerHandBookMap, templateId, Const.PET_HBMSK_CATCHED, countryId) then
				state = PetResearchUtils.PET_STATE_IS_CATCH
			end

			if PetResearchUtils._hasSpeciesStateMask(playerHandBookMap, templateId, Const.PET_HBMSK_RESEARCHED, countryId) then
				state = PetResearchUtils.PET_STATE_IS_AllSTAR
			end

			local isShinyKnown = PetResearchUtils._hasSpeciesStateMask(playerHandBookMap, templateId, Const.PET_HBMSK_SHINY_KNOWN, countryId)
			local isNeed = filterTypeList == nil

			if filterTypeList then
				for _, fType in ipairs(filterTypeList) do
					if fType == state then
						isNeed = true

						break
					end
				end
			end

			if isNeed == true then
				local formHandBookMap = playerHandBookMap[templateId]
				local petInfo = PetResearchUtils._genPetInfo(number, templateId, formHandBookMap, isShinyKnown, state, showTab, countryId)

				ret[#ret + 1] = petInfo
			end
		end
	end

	PetResearchUtils._orderPetInfoRet(orderType, isAscendingOrder, ret)

	return ret
end

function PetResearchUtils.tryGetPetInfos_allForm(orderType, isAscendingOrder, filterTypeList, countryId, showTab)
	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap

	local function tryAddPetInfo(templateId, formTemplateId, formSort)
		local basePetBook = playerHandBookMap[templateId]
		local baseResearchData = PetResearchContentData[templateId]

		if not baseResearchData then
			return
		end

		local formHandBookMap = playerHandBookMap[formTemplateId]
		local state = PetResearchUtils.PET_STATE_IS_EMPTY
		local isShinyKnown = false

		if formHandBookMap then
			isShinyKnown = formHandBookMap:isShinyKnown()

			if formHandBookMap:isKnown() then
				state = PetResearchUtils.PET_STATE_IS_KNOWN
			end

			if formHandBookMap:isCatched() then
				state = PetResearchUtils.PET_STATE_IS_CATCH
			end

			if formHandBookMap:isResearched() then
				state = PetResearchUtils.PET_STATE_IS_AllSTAR
			end
		end

		local isNeed = filterTypeList == nil

		if filterTypeList then
			for _, fType in ipairs(filterTypeList) do
				if fType == state then
					isNeed = true

					break
				end
			end
		end

		if isNeed == true then
			local petInfo = PetResearchUtils._genPetInfo(baseResearchData.number, formTemplateId, basePetBook, isShinyKnown, state, showTab, countryId)

			petInfo.formSort = formSort
			ret[#ret + 1] = petInfo
		end
	end

	if countryId then
		for _, formTemplateId in ipairs(PetResearchCountryFormList[countryId] or EMPTY_TABLE) do
			local templateId = Utils.getBasePetPrototypeId(formTemplateId)

			tryAddPetInfo(templateId, formTemplateId, formTemplateId)
		end
	else
		for _, templateId in pairs(PetResearchNumberToId) do
			local formInfos = PetBasePrototypeToPrototypeMap[templateId]

			if formInfos then
				for formIdx, formTemplateId in ipairs(formInfos) do
					local formResearchData = PetResearchContentData[formTemplateId]

					if formResearchData and formResearchData.isShow ~= 0 then
						tryAddPetInfo(templateId, formTemplateId, formIdx)
					end
				end
			end
		end
	end

	PetResearchUtils._orderPetInfoRet(orderType, isAscendingOrder, ret)

	return ret
end

function PetResearchUtils._genPetInfo(idx, templateId, basePetBook, isShinyKnown, state, showTab, countryId)
	local petInfo = {}

	petInfo.number = idx
	petInfo.displayNumber = PetResearchUtils.getResearchDisplayNumber(templateId, countryId, showTab)
	petInfo.countryId = countryId
	petInfo.state = state
	petInfo.templateId = templateId
	petInfo.id = templateId
	petInfo.knownShiny = isShinyKnown
	petInfo.isShowRedDot = PetResearchUtils.checkHasPetRewardByTemplateId(templateId)

	if state ~= PetResearchUtils.PET_STATE_IS_EMPTY then
		local displayTemplateId, displayLabel = PetResearchUtils.getPetDisplayFormLabelTemplateId(templateId, showTab, countryId)

		petInfo.displayTemplateId = displayTemplateId
		petInfo.displayLabel = displayLabel

		local pData = PetProtoTypeData[displayTemplateId]
		local elements = PetResearchUtils.getElementsInfo(displayTemplateId)

		petInfo.iconName = pData.iconName
		petInfo.uiName = string.upper(CustomEnData[tostring(pData.name)] or "")
		petInfo.name = pData.name
		petInfo.elements = elements
		petInfo.mainElement = elements[1].element

		if state == PetResearchUtils.PET_STATE_IS_CATCH or state == PetResearchUtils.PET_STATE_IS_AllSTAR then
			petInfo.level = basePetBook.level
			petInfo.exp = basePetBook.exp

			local nextLevel = math.min(basePetBook.level + 1, Const.PET_RESEARCH_REWARD_LEVEL_MAX)
			local baseFormPet = Utils.getBasePetPrototypeId(templateId)

			if PetResearchContentData[baseFormPet] and PetResearchContentData[baseFormPet].needResearchPoint then
				petInfo.needExp = PetResearchContentData[baseFormPet].needResearchPoint[nextLevel]
			else
				petInfo.needExp = 1
			end
		end

		petInfo.isCrown = state == PetResearchUtils.PET_STATE_IS_AllSTAR
	end

	return petInfo
end

function PetResearchUtils._orderPetInfoRet(orderType, isAscendingOrder, ret)
	if orderType then
		if orderType == PetResearchUtils.ORDER_TYPE_LEVEL then
			table.sort(ret, function(a, b)
				if a.level then
					if b.level then
						if isAscendingOrder then
							return a.level <= b.level
						else
							return a.level > b.level
						end
					else
						return true
					end
				elseif b.level then
					return false
				end

				return false
			end)
		elseif orderType == PetResearchUtils.ORDER_TYPE_NO and not isAscendingOrder then
			table.sort(ret, function(a, b)
				if a.number == b.number then
					if a.formSort and b.formSort then
						return a.formSort < b.formSort
					end

					return a.templateId < b.templateId
				end

				return a.number < b.number
			end)
		end
	else
		table.sort(ret, function(a, b)
			if a.number == b.number then
				if a.formSort and b.formSort then
					return a.formSort < b.formSort
				end

				return a.templateId < b.templateId
			end

			return a.number < b.number
		end)
	end
end

function PetResearchUtils.getPetResearchPetCountSum(countryId, onlyBase)
	local normalCount = 0
	local shinyCount = 0

	local function addAvatarCount(templateId)
		local avatarInfo = PetAvatarData[templateId]

		if avatarInfo then
			if avatarInfo[Const.PET_LABEL_MASK.NORMAL] then
				normalCount = normalCount + 1
			end

			if avatarInfo[Const.PET_LABEL_MASK.SHINY] then
				shinyCount = shinyCount + 1
			end
		end
	end

	if onlyBase then
		for _, baseTemplateId in pairs(PetResearchUtils.getPetResearchSpeciesList(countryId)) do
			local baseResearchInfo = PetResearchContentData[baseTemplateId]

			if baseResearchInfo and baseResearchInfo.isShow ~= 0 then
				addAvatarCount(baseTemplateId)
			end
		end
	elseif countryId then
		for _, formTemplateId in ipairs(PetResearchCountryFormList[countryId] or EMPTY_TABLE) do
			addAvatarCount(formTemplateId)
		end
	else
		for _, baseTemplateId in pairs(PetResearchNumberToId) do
			for _, formTemplateId in ipairs(PetBasePrototypeToPrototypeMap[baseTemplateId] or {
				baseTemplateId
			}) do
				local formResearchInfo = PetResearchContentData[formTemplateId]

				if formResearchInfo and formResearchInfo.isShow ~= 0 then
					addAvatarCount(formTemplateId)
				end
			end
		end
	end

	return normalCount, shinyCount
end

function PetResearchUtils.getCountryCollectInfo(countryId, showTab)
	local baseId = showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and 1 or 0
	local playerHandBookMap = pg.me.petHandbookMap
	local knownCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_KNOWN, countryId)
	local caughtCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_CATCHED, countryId)
	local knownShinyCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_SHINY_KNOWN, countryId)
	local catchShinyCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_SHINY_CATCHED, countryId)
	local knowRainbowCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_RAINBOW_KNOWN, countryId)
	local catchRainbowCount = playerHandBookMap:getFormCountByIdAndStateMask(baseId, Const.PET_HBMSK_RAINBOW_CATCHED, countryId)

	return knownCount, caughtCount, knownShinyCount, catchShinyCount, knowRainbowCount, catchRainbowCount
end

function PetResearchUtils.getAreaPetCollectInfo(areaId, showTab)
	local catchCount, catchShinyCount, catchRainbowCount
	local playerHandBookMap = pg.me.petHandbookMap

	if showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
		catchCount = playerHandBookMap:getCatchedSpeciesCount(areaId)
		catchShinyCount = playerHandBookMap:getCatchedShinySpeciesCount(areaId)
		catchRainbowCount = playerHandBookMap:getCatchedRainbowSpeciesCount(areaId)
	else
		catchCount = playerHandBookMap:getFormCatchedCount(areaId)
		catchShinyCount = playerHandBookMap:getShinyFormCatchedCount(areaId)
		catchRainbowCount = playerHandBookMap:getRainbowFormCatchedCount(areaId)
	end

	local ret = {}

	ret[1] = {
		icon = PetResearchUtils.HandbookIcon[1],
		num = catchCount,
		tooltipId = PetResearchUtils.TooltipIds[showTab][1]
	}
	ret[2] = {
		icon = PetResearchUtils.HandbookIcon[2],
		num = catchShinyCount,
		tooltipId = PetResearchUtils.TooltipIds[showTab][2]
	}
	ret[3] = {
		icon = PetResearchUtils.HandbookIcon[3],
		num = catchRainbowCount,
		tooltipId = PetResearchUtils.TooltipIds[showTab][3]
	}

	return ret
end

local STAGE_STRENGTH_TO_QUALITY_ID = {
	0,
	1,
	2,
	3,
	4
}

function PetResearchUtils.setEvolveQuality(qualityNode, templateId)
	local stage = PetProtoTypeData[templateId].stage or 0
	local qualityIdx = STAGE_STRENGTH_TO_QUALITY_ID[stage]

	qualityNode:TryChangePage("Quality", qualityIdx)
	ClientTextUtils.setText(qualityNode:Find("Text"), pg.getLocalizationText(pg.getGameString("PET_STAGE_TXT_" .. stage)))
end

function PetResearchUtils.getPetDisplayFormLabelTemplateId(templateId, showTab, countryId)
	local player = pg.me

	showTab = showTab or PetResearchUtils.getLastPetShowTab()

	if showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
		local baseFormPet = Utils.getBasePetPrototypeId(templateId)
		local countryMap = player.displayPetFormByCountryMap and player.displayPetFormByCountryMap[baseFormPet]
		local displayInfo = countryId and countryMap and countryMap[countryId]

		if displayInfo and PetData[displayInfo.petPrototypeId or templateId] then
			local label = displayInfo.label or Const.PET_LABEL_MASK.NORMAL
			local shinyStyle = Utils.isLabelShiny(label) and (displayInfo.shinyStyle or 0) or 0

			return displayInfo.petPrototypeId or templateId, label, shinyStyle
		end

		if countryId then
			for _, formTemplateId in ipairs(PetBasePrototypeToPrototypeMap[baseFormPet] or EMPTY_TABLE) do
				if PetData[formTemplateId] and Utils.getPetCountryId(formTemplateId) == countryId then
					return formTemplateId, Const.PET_LABEL_MASK.NORMAL, 0
				end
			end
		end
	else
		local countryMap = player.displayFormPetLabelByCountryMap and player.displayFormPetLabelByCountryMap[templateId]
		local displayInfo = countryId and countryMap and countryMap[countryId]

		if displayInfo then
			local label = displayInfo.label or Const.PET_LABEL_MASK.NORMAL
			local shinyStyle = Utils.isLabelShiny(label) and (displayInfo.shinyStyle or 0) or 0

			return templateId, label, shinyStyle
		end
	end

	return templateId, Const.PET_LABEL_MASK.NORMAL, 0
end

function PetResearchUtils.getPetDisplayVideoResFromLabelTemplateId(templateId, showTab, countryId)
	local displayTemplateId, label = PetResearchUtils.getPetDisplayFormLabelTemplateId(templateId, showTab, countryId)

	if label == Const.PET_LABEL_MASK.SHINY then
		local res = string.format("$%s_Shiny.mp4", displayTemplateId)

		if pg.global.uiMgr:CheckVideoExist(res) then
			return res
		else
			res = string.format("$%s.mp4", displayTemplateId)

			if pg.global.uiMgr:CheckVideoExist(res) then
				return res
			else
				res = string.format("$%s.mp4", templateId)

				return res
			end
		end
	else
		local res = string.format("$%s.mp4", displayTemplateId)

		if not pg.global.uiMgr:CheckVideoExist(res) then
			res = string.format("$%s.mp4", templateId)
		end

		return res
	end
end

function PetResearchUtils.getRewardResearchPoint(dropId)
	local dropInfo = DropData[dropId] or {}
	local fixedDrop = dropInfo.displayReward or {}

	return fixedDrop[1] and fixedDrop[1][2] or 0
end

function PetResearchUtils.petAppearanceTrans(ent, oldId, newId)
	ClientModelUtils.applyIndividuationTrans(ent, oldId, newId)
end

function PetResearchUtils:getPlayerSkill()
	local targetLevel = pg.me.level + 1
	local levelInfo = PlayerLevelData[targetLevel]
	local ret = {}
	local playerEnhanceModel = pg.global.ui.playerEnhance.model

	if levelInfo and levelInfo.skillDisplay then
		for _, skillId in ipairs(levelInfo.skillDisplay) do
			local skillInfo = PlayerSkillTreeData[skillId]
			local item = {}

			item.id = skillId
			item.abilityType = skillInfo.abilityType
			item.tIndex = skillInfo.abilityType == UIConst.SKILL_TYPE.COMBATS and 0 or 1
			item.hideSkillButton = true

			playerEnhanceModel:parseSkillInfo(item)

			ret[#ret + 1] = item
		end
	end

	return ret
end

function PetResearchUtils:getCurPlayerSkill()
	local targetLevel = pg.me.level
	local levelInfo = PlayerLevelData[targetLevel]

	if levelInfo and levelInfo.skillDisplay and levelInfo.skillDisplay[1] then
		local skillId = levelInfo.skillDisplay[1]
		local skillInfo = PlayerSkillTreeData[skillId]
		local item = {}

		item.id = skillId
		item.abilityType = skillInfo.abilityType
		item.tIndex = skillInfo.abilityType == UIConst.SKILL_TYPE.COMBATS and 0 or 1
		item.hideSkillButton = true

		pg.global.ui.playerEnhance.model:parseSkillInfo(item)

		return item
	end

	return nil
end

function PetResearchUtils.renderSkillItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name = objectReference:GetRefValue("name")
	local icon = objectReference:GetRefValue("icon")

	ClientTextUtils.setText(name, data.name)

	icon.url = data.icon

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				autoHor = true,
				targetRect = button,
				data = data
			})
		end
	end
end

function PetResearchUtils.petLerpProperty(ent, enable, duration)
	ent.eModel.modelShaderView:LerpProperty(enable, duration)
end

function PetResearchUtils.getPetExploreSkillData(exploreId, level)
	if exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB then
		local skillInfo = AbilityParamData[9001006]

		return {
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = skillInfo.desc
		}
	elseif exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE then
		local skillInfo = AbilityParamData[9001007]

		return {
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = skillInfo.desc
		}
	elseif exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM then
		local skillInfo = AbilityParamData[9001008]

		return {
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = skillInfo.desc
		}
	end
end

function PetResearchUtils.getPetTypeNum(templateId, countryId)
	local baseFormPet = Utils.getBasePetPrototypeId(templateId)
	local protoTypeInfo = PetBasePrototypeToPrototypeMap[baseFormPet]

	if protoTypeInfo then
		local playerHandBookMap = pg.me.petHandbookMap
		local totalCnt = 0
		local curCnt = 0

		for _, petTemplateId in ipairs(protoTypeInfo) do
			local avatarData = PetAvatarData[petTemplateId]

			if avatarData and (not countryId or Utils.getPetCountryId(petTemplateId) == countryId) then
				totalCnt = totalCnt + 1

				local petHandBookInfo = playerHandBookMap[petTemplateId]

				if petHandBookInfo and petHandBookInfo:isCatched() then
					curCnt = curCnt + 1
				end
			end
		end

		return curCnt, totalCnt
	else
		return 0, 0
	end
end

function PetResearchUtils.getActivePetFormAbilityEffects(petPrototypeId, countryId)
	if not petPrototypeId or not countryId then
		return {}, {}
	end

	return PetAttributeCalcUtils.getFormCollectEntryAttributeMap({
		player = pg.me,
		petPrototypeId = petPrototypeId
	}, countryId)
end

function PetResearchUtils.getPetFormAbilityInfo(formPrototypeId, countryId)
	if not formPrototypeId or not countryId or Utils.getPetCountryId(formPrototypeId) ~= countryId then
		return nil, false, nil
	end

	local avatarData = PetAvatarData[formPrototypeId]
	local typeZeroData = avatarData and avatarData[0]
	local abilityId = typeZeroData and typeZeroData.ability
	local entryData = abilityId and AttributeEntryData[abilityId]

	if not entryData then
		return nil, false, abilityId
	end

	local petHandbookMap = pg.me and pg.me.petHandbookMap
	local handbookInfo = petHandbookMap and petHandbookMap[formPrototypeId]
	local isActive = handbookInfo and handbookInfo:isCatched() or false

	return entryData, isActive, abilityId
end

function PetResearchUtils.renderFormItem(formItem, petPrototypeId, isNoActive)
	LuaUIUtils.renderFormItemByPrototypeId(formItem, petPrototypeId, isNoActive)
end

function PetResearchUtils.getPetFormIconSmall(petPrototypeId)
	local formTypeData = Utils.getPetFormTypeDataByPrototypeId(petPrototypeId)

	if formTypeData then
		return formTypeData.iconSmall
	end
end

function PetResearchUtils.getLastPetResearchAreaId()
	return pg.global.prefsCacheUtils:getInt("LAST_PET_RESEARCH_AREA_ID", PetResearchUtils.DEFAULT_AREA_ID, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.savePetResearchAreaId(areaId)
	pg.global.prefsCacheUtils:setInt("LAST_PET_RESEARCH_AREA_ID", areaId, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.getLastPetShowTab()
	return pg.global.prefsCacheUtils:getInt("LAST_PET_SHOW_TAB", PetResearchUtils.PET_SHOW_TAB.SPECIES, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.savePetShowTab(showTab)
	pg.global.prefsCacheUtils:setInt("LAST_PET_SHOW_TAB", showTab, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.getAreaActiveStateInPrefs(areaId)
	return pg.global.prefsCacheUtils:getBool(string.format("PET_RESEARCH_AREA_ACTIVE_%s", areaId), false, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.setAreaActiveStateInPrefs(areaId, value)
	return pg.global.prefsCacheUtils:setBool(string.format("PET_RESEARCH_AREA_ACTIVE_%s", areaId), value, ClientConst.CACHE_TYPE_FLAG.USER)
end

function PetResearchUtils.checkAreaIsCollection(areaId)
	return LuaUIUtils.checkPetResearchAreaIsCollection(areaId)
end

function PetResearchUtils.getReportPointInArea(areaId)
	local countryMap = pg.me.petHandbookMap.petCountryMap[areaId]

	if countryMap then
		local reportPoint = countryMap.researchReportMap:getTotalPoint()

		return reportPoint
	end

	return 0
end

function PetResearchUtils.checkHasAnyReportPoint()
	for areaId, info in pairs(MapAreaConfigData) do
		if info.belongNation and info.belongNation > 0 then
			local point = PetResearchUtils.getReportPointInArea(areaId)

			if point > 0 then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils.getAllHasReportPointArea()
	local ret = {}

	for areaId, info in pairs(MapAreaConfigData) do
		if info.belongNation and info.belongNation > 0 then
			local point = PetResearchUtils.getReportPointInArea(areaId)

			if point > 0 then
				table.insert(ret, {
					areaId = areaId,
					reportPoint = point,
					_sort = info.sort
				})
			end
		end
	end

	table.sort(ret, function(a, b)
		return a._sort < b._sort
	end)

	return ret
end

PetResearchUtils.REWARD_COLLECT = 1
PetResearchUtils.REWARD_LEVEL = 2

function PetResearchUtils.checkCountryReward(countryId, showTab, rewardType)
	showTab = showTab or PetResearchUtils.getLastPetShowTab()

	local petHandbookMap = pg.me.petHandbookMap
	local collectLevel, _ = showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and petHandbookMap:getCountrySpeciesCollectLevel(countryId) or petHandbookMap:getCountryCollectLevel(countryId)
	local collectRewardStatus = showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and petHandbookMap.getCountrySpeciesCollectRewardStatus or petHandbookMap.getCountryCollectRewardStatus
	local curStar, _ = petHandbookMap:getCountryTotalLevel(countryId)

	if not rewardType then
		for level = 1, collectLevel do
			local status = collectRewardStatus(petHandbookMap, countryId, level)

			if status == Const.REWARD_STATUS_CANREWARD then
				return true
			end
		end

		for level = 1, curStar do
			local status = petHandbookMap:getCountryLevelRewardStatus(countryId, level)

			if status == Const.REWARD_STATUS_CANREWARD then
				return true
			end
		end
	elseif rewardType == PetResearchUtils.REWARD_COLLECT then
		for level = 1, collectLevel do
			local status = collectRewardStatus(petHandbookMap, countryId, level)

			if status == Const.REWARD_STATUS_CANREWARD then
				return true
			end
		end
	elseif rewardType == PetResearchUtils.REWARD_LEVEL then
		for level = 1, curStar do
			local status = petHandbookMap:getCountryLevelRewardStatus(countryId, level)

			if status == Const.REWARD_STATUS_CANREWARD then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils.checkAreaIsUnlock(areaId)
	local areaMap = pg.me.petHandbookMap.petCountryMap[areaId]

	return areaMap and areaMap.unlocked or false
end

function PetResearchUtils.checkNeedOpenAreaPageUI()
	for areaId, info in pairs(MapAreaConfigData) do
		if areaId ~= PetResearchUtils.DEFAULT_AREA_ID and info.belongNation and info.belongNation > 0 then
			local isUnlock = PetResearchUtils.checkAreaIsUnlock(areaId)

			if isUnlock and not PetResearchUtils.getAreaActiveStateInPrefs(areaId) then
				return true
			end
		end
	end

	return false
end

function PetResearchUtils.tryOpenPetResearchDetail(petData)
	if petData.state ~= PetResearchUtils.PET_STATE_IS_CATCH and petData.state ~= PetResearchUtils.PET_STATE_IS_AllSTAR then
		local dropId = PetAvatarData[petData.templateId][0].reward
		local point = PetResearchUtils.getRewardResearchPoint(dropId or 0)

		if petData.state == PetResearchUtils.PET_STATE_IS_KNOWN then
			pg.global.showBubbleMessage(NoticeDef.PET_RESEARCH_UNCAUGHT, point)
		else
			pg.global.showBubbleMessage(NoticeDef.PET_RESEARCH_UNKNOWN, point)
		end

		return
	end

	PetResearchUtils.openPetResearchDetail(petData)
end

return PetResearchUtils
