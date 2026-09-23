-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetManage\\PetManageSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetManageSystem")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local MessageName = require("Const.MessageName")
local lume = require("Core.Common.lume")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetData = require("Data.pet_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local Lume = require("Core.Common.lume")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CoreCarryData = require("Data.core_carry_data")
local CoreCarryLevelData = require("Data.core_carry_level_data")
local AssistCarryData = require("Data.assist_carry_data")
local PetTalentData = require("Data.pet_talent_data")
local AttributeData = require("Data.attribute_group_data")
local BuffData = require("Data.buff_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local BaseProperty = require("CustomTypes.BaseProperty")
local PetPropLevelData = require("Data.pet_prop_level_data")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetEvolveItemSubData = require("Data.pet_evolve_item_sub_data")
local AbilityConst = require("Common.Const.AbilityConst")
local RogueUtils = require("Utils.RogueUtils")
local FunctionEnum = require("Data.function_unlock_enum")
local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local PetManageSystem = Class.LightClass("PetManageSystem", SystemBase)
local CORE_CARRY_CERTIFY_SYNC_INTERVAL = 0.05
local CORE_CARRY_CERTIFY_SYNC_MAX_RETRY = 20

function PetManageSystem:onCtor()
	self.lockCarryAssistant = true

	PetManageSystem.super.onCtor(self)
end

function PetManageSystem:onDestroy()
	self.m_recyclingPetIds = nil

	PetManageSystem.super.onDestroy(self)
	self:resetInheritDataModel()
	self:resetCarryInfos()
end

function PetManageSystem:resetInheritDataModel()
	self.m_inheritSourcePetId = nil
	self.m_inheritTargetPetId = nil
	self.m_inheritSourcePetInfo = nil
end

function PetManageSystem:setInheritSourcePetId(petId)
	self.m_inheritSourcePetId = petId
end

function PetManageSystem:getInheritSourcePetId()
	return self.m_inheritSourcePetId
end

function PetManageSystem:setInheritTargetPetId(petId)
	self.m_inheritTargetPetId = petId
end

function PetManageSystem:getInheritTargetPetId()
	return self.m_inheritTargetPetId
end

function PetManageSystem:recordInheritSourcePetInfo(petId)
	self.m_inheritSourcePetInfo = PetManagementUtils.getPetSimpleInfo(petId)
end

function PetManageSystem:getInheritSourcePetInfo()
	return self.m_inheritSourcePetInfo
end

function PetManageSystem:trySendRpcInheritPetPropLevel(petId, inheritPetId)
	local sourcePetInfo = pg.me:getPetInfo(petId)
	local targetPetInfo = pg.me:getPetInfo(inheritPetId)
	local setting = PetConfigData.inheritanceSetting or {}
	local needResult = Utils.needPetInheritanceTransfer(sourcePetInfo, targetPetInfo, setting)

	if not needResult.hasTransfer then
		local sourceHasCultivation = self:hasPetCultivationByInfo(sourcePetInfo)
		local targetHasCultivation = self:hasPetCultivationByInfo(targetPetInfo)

		if sourceHasCultivation or targetHasCultivation then
			pg.global.showBubbleMessageById(NoticeDef.PET_INHERIT_TIPS_CANT_JUMP)
		else
			pg.global.showBubbleMessageById(NoticeDef.PET_INHERIT_PET_LEGAL_CHECK_INVALID_STATUS)
		end

		return
	end

	if not needResult.qualityOver then
		pg.global.showBubbleMessageById(NoticeDef.PET_INHERIT_TIPS_CANT_JUMP)

		return
	end

	pg.game.petManage:recordInheritSourcePetInfo(petId)
	pg.me:serverMsg("RPC_CS_InheritPetPropLevel", petId, inheritPetId, function(noticeId, refundItems, needResult)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.PET_INHERIT_CHANGE, {
				petId = petId,
				inheritPetId = inheritPetId
			})
			pg.global.ui:close(UIConst.UI_ID_PET_INHERITANCE_CHOOSE)
			pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_RESULT, {
				sourcePetId = petId,
				targetPetId = inheritPetId,
				refundItems = refundItems
			})
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("inherit pet prop level failed, noticeId = %d, refundItems = %s, needResult = %d", noticeId, inspect(refundItems), inspect(needResult))
		end
	end)
end

function PetManageSystem:checkInheritSourcePetLegal(player, sourcePetId)
	local petInfo = player and player:getPetInfo(sourcePetId)

	if not petInfo then
		return false, Const.ErrInheritPetType.EPRR_PET_NOT_EXIST
	end

	if lume.find(player.petPrepareList, sourcePetId) then
		return false, Const.ErrInheritPetType.EPRR_PET_IN_TEAM
	end

	if lume.find(player.petExploreList, sourcePetId) then
		return false, Const.ErrInheritPetType.EPRR_PET_IN_TEAM
	end

	return true
end

function PetManageSystem:checkInheritTargetPetLegal(player, sourcePetId, targetPetId)
	local sourcePetInfo = player:getPetInfo(sourcePetId)
	local targetPetInfo = player:getPetInfo(targetPetId)

	if not sourcePetInfo or not targetPetInfo then
		return false, Const.ErrInheritPetType.EPRR_PET_NOT_EXIST
	end

	if sourcePetId == targetPetId then
		return false, Const.ErrInheritPetType.EPRR_PET_SAME
	end

	if lume.find(player.petPrepareList, targetPetId) then
		return false, Const.ErrInheritPetType.EPRR_PET_IN_TEAM
	end

	if lume.find(player.petExploreList, targetPetId) then
		return false, Const.ErrInheritPetType.EPRR_PET_IN_TEAM
	end

	local ret = Utils.checkInheritPetPropLevel(player, sourcePetId, targetPetId)

	if ret == NoticeDef.SUCCESS then
		return true, nil
	else
		return false, Const.ErrInheritPetType.EPRR_PET_TYPE_FORBID
	end

	return true
end

function PetManageSystem:hasPetCultivationByInfo(petInfo)
	if not petInfo then
		return false
	end

	local resonanceInfo = petInfo.resonanceInfo

	if resonanceInfo and ((resonanceInfo.resonanceStage or 1) > 1 or (resonanceInfo.resonanceLevel or 0) > 0) then
		return true
	end

	if Utils.getPetPropertyEnhancedCount(petInfo) > 0 then
		return true
	end

	local basePropertyList = petInfo.basePropertyList

	if not basePropertyList then
		return false
	end

	if basePropertyList.items then
		for _, baseProperty in basePropertyList:items() do
			if (baseProperty.iLvLn or 0) > 0 then
				return true
			end
		end
	else
		for _, baseProperty in pairs(basePropertyList) do
			if (baseProperty.iLvLn or 0) > 0 then
				return true
			end
		end
	end

	return false
end

function PetManageSystem:hasPetCultivation(petId)
	return self:hasPetCultivationByInfo(pg.me:getPetInfo(petId))
end

function PetManageSystem:getErrNoticeId(errType)
	if errType == Const.ErrInheritPetType.EPRR_PET_IN_TEAM then
		return NoticeDef.PET_INHERIT_PET_LEGAL_CHECK_ERR_CODE1
	end

	if errType == Const.ErrInheritPetType.EPRR_PET_TYPE_FORBID then
		return NoticeDef.PET_INHERIT_PET_LEGAL_CHECK_ERR_CODE2
	end

	if errType == Const.ErrInheritPetType.EPRR_PET_SAME then
		return NoticeDef.PET_INHERIT_PET_LEGAL_CHECK_ERR_CODE2
	end
end

function PetManageSystem:getPetPropLevels(petInfo)
	if not petInfo then
		return
	end

	local baseProperty = petInfo.basePropertyList
	local individualLevelTable = {}
	local attributeMap, extraSrcMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)

	extraSrcMap = extraSrcMap or {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propInfo = baseProperty[i]
		local propExtraInfo = extraSrcMap[i] or {}
		local iconUrl, nameKey = PetManagementUtils.getPetOldPropIconAndNameKey(i)
		local propAttrConstName = PetManagementUtils.getPetOldPropAttrConstName(i)
		local proppAttrConstId = AttributeConst[propAttrConstName]
		local maxLevel = Utils.getTotalIndividualLevelMax(i) or 1
		local complexBaseLv = BaseProperty.getBaseIndividualLevel(propInfo) or 0
		local learntLv = propInfo.iLvLn or 0
		local complexBaseAndLearntLv = complexBaseLv + learntLv
		local total = complexBaseAndLearntLv + (extraSrcMap[i].iLvEx or 0)
		local levelConf = PetPropLevelData[i] or {}

		individualLevelTable[i] = {
			propDisplayVal = attributeMap[proppAttrConstId] or 0,
			total = total,
			learnt = learntLv,
			max = maxLevel or 1,
			complexBaseLv = complexBaseLv,
			baseAndActiveTotalLv = complexBaseAndLearntLv,
			passiveExtra = extraSrcMap[i].iLvEx or 0,
			iconUrl = iconUrl or "",
			l18nNameKey = nameKey or "",
			isMax = maxLevel <= complexBaseLv + learntLv or false,
			extraSrcMap = propExtraInfo.extraSrcMap or {},
			isTotalMax = #levelConf > 0 and total >= #levelConf - 1 or false
		}
		individualLevelTable[i].base = complexBaseLv
	end

	for _, propLevel in pairs(individualLevelTable) do
		propLevel.propertyCountByEvent = petInfo.propertyCountByEvent or 0
		propLevel.propertyMaxCountByEvent = PetConfigData.individualPropEnhanceTimesMax or 0
	end

	return individualLevelTable
end

function PetManageSystem:checkIsCanManualUpPropLv(petInfo, propIndex, toLevel)
	local levelConf = PetPropLevelData[propIndex] and PetPropLevelData[propIndex][toLevel]
	local needPetLv = levelConf and levelConf.needPetLv

	if needPetLv and needPetLv > petInfo.level then
		return false, needPetLv
	end

	return true, 0
end

function PetManageSystem:getPetPropLevelExtraInfo(propLevelInfo)
	local extraSrcMap = propLevelInfo.extraSrcMap
	local extraValInfos = {}

	if next(extraSrcMap) then
		for srcId, srcVal in pairs(extraSrcMap) do
			if srcId then
				local nameKey = self:getPropLevelExtraSrcNameKey(srcId)

				extraValInfos[nameKey] = extraValInfos[nameKey] or 0
				extraValInfos[nameKey] = extraValInfos[nameKey] + srcVal or 0
			end
		end
	end

	local extraInfo = {}

	for nameKey, lv in pairs(extraValInfos) do
		table.insert(extraInfo, {
			nameKey = nameKey,
			lv = lv or 0,
			sort = AbilityConst.EXTRA_SRCTYPE_STRKEYS_SORT[nameKey] or 4
		})
	end

	table.sort(extraInfo, function(a, b)
		return a.sort < b.sort
	end)

	return extraInfo
end

function PetManageSystem:getPropLevelExtraSrcNameKey(attrSrcId)
	if not attrSrcId then
		return
	end

	if attrSrcId == AbilityConst.EXCEPT_EXTRA_ATTR_SRCTYPE then
		return
	end

	local finalStrKey = AbilityConst.EXTRA_SRCTYPE_STRKEY_OTHER

	for strKey, v in pairs(AbilityConst.EXTRA_SRCTYPE_STRKEYS) do
		if table.contains(v, attrSrcId) then
			finalStrKey = strKey

			break
		end
	end

	return finalStrKey
end

function PetManageSystem:getIsReachedMaxPropLevel(petInfo, propId)
	local propLevels = self:getPetPropLevels(petInfo)
	local isReachedMax = true

	for index, propLevel in pairs(propLevels) do
		if propId and index == propId then
			return propLevel.isMax
		end

		if not propLevel.isMax then
			isReachedMax = false

			break
		end
	end

	return isReachedMax
end

function PetManageSystem:getPetPropLevelMaxInfo(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local usedCount = Utils.getPetPropertyEnhancedCount(petInfo)
	local maxCount = PetConfigData.PET_PROPENHANCE_MAX_COUNT or 2

	return usedCount, maxCount
end

function PetManageSystem:getPetRecommendPropsSumVal(petInfo)
	local propLevels = self:getPetPropLevels(petInfo)
	local pData = PetData[petInfo.templateId] or {}
	local recommend_attr = pData.recommend_attr or {}
	local sumVal = 0

	for _, recommendId in ipairs(recommend_attr) do
		sumVal = sumVal + (propLevels[recommendId] and propLevels[recommendId].base or 0)
	end

	return sumVal
end

function PetManageSystem:getPetTopTwoPropsSumVal(petInfo)
	local propLevels = self:getPetPropLevels(petInfo)
	local maxPropVal = 0
	local secondMaxPropVal = 0

	for propId = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propVal = propLevels[propId] and propLevels[propId].base or 0

		if maxPropVal <= propVal then
			secondMaxPropVal = maxPropVal
			maxPropVal = propVal
		elseif secondMaxPropVal < propVal then
			secondMaxPropVal = propVal
		end
	end

	return maxPropVal + secondMaxPropVal
end

function PetManageSystem:getIsShowShineTip(petInfo)
	if not petInfo then
		return false
	end

	local usedCount, maxCount = self:getPetPropLevelMaxInfo(petInfo.id)

	if maxCount <= usedCount then
		return false
	end

	local selfPetInfo = pg.me:getPetInfo(petInfo.id)

	if selfPetInfo and selfPetInfo:isCatchReporting() then
		return false
	end

	local propLevels = self:getPetPropLevels(petInfo) or {}
	local talentInitLevelTable = {}

	for propId = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		talentInitLevelTable[propId] = propLevels[propId] and propLevels[propId].base or 0
	end

	local weightedSum = Utils.getTalentInitLevelSum(talentInitLevelTable, petInfo.templateId, false)
	local checkScore = weightedSum + 2 * (PetConfigData.fitPropEvaluateRatio or 3) + 4
	local shineLevelValue = (PetConfigData.PetEvaluateLevelRangeValue or {})[4] or 0

	if checkScore < shineLevelValue then
		return false
	end

	local pageIndex = petInfo.getPropRatingResult and petInfo:getPropRatingResult()

	return pageIndex == 2
end

function PetManageSystem:getIsShowMaxShineTip(petInfo)
	if not petInfo then
		return false
	end

	local selfPetInfo = pg.me:getPetInfo(petInfo.id)

	if selfPetInfo and selfPetInfo:isCatchReporting() then
		return false
	end

	local templateId = selfPetInfo and selfPetInfo.templateId or petInfo.templateId

	if not templateId then
		return false
	end

	local petData = PetData[templateId] or {}
	local recommend = petData.recommend_attr or {}
	local propLevels = self:getPetPropLevels(petInfo) or {}
	local limitCnt = 2
	local maxLv = PetConfigData.individualPropEnhanceMax or 0

	if maxLv <= 0 then
		return false
	end

	local processCnt = 0
	local checkedPropIds = {}

	for _, recommendId in ipairs(recommend) do
		if recommendId and not checkedPropIds[recommendId] then
			checkedPropIds[recommendId] = true

			local recommendPropLv = propLevels[recommendId] and propLevels[recommendId].complexBaseLv or 0

			if recommendPropLv < maxLv then
				return false
			end

			processCnt = processCnt + 1

			if limitCnt <= processCnt then
				return true
			end
		end
	end

	for propId = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		if not checkedPropIds[propId] then
			local propLv = propLevels[propId] and propLevels[propId].complexBaseLv or 0

			if maxLv <= propLv then
				processCnt = processCnt + 1

				if limitCnt <= processCnt then
					return true
				end
			end
		end
	end

	return false
end

function PetManageSystem:getPetCrownStatePageIndex(petInfo)
	local crownState = UIConst.PET_CROWN_STATE.NONE
	local propLevels = self:getPetPropLevels(petInfo)

	crownState = LuaUIUtils.getPetCrownState(propLevels)

	local maxPageIndex = UIConst.PET_CROWN_STATE.NONE

	if crownState == UIConst.PET_CROWN_STATE.GOLD then
		maxPageIndex = 1
	elseif crownState == UIConst.PET_CROWN_STATE.SILVER then
		maxPageIndex = 2
	end

	return maxPageIndex
end

function PetManageSystem:sendRpcLockCarryItemStatus(data)
	local retLocked = not data.isLocked

	pg.me:serverMsg("RPC_CS_ModifyItemStatus", data.invId, {
		data.genID
	}, ItemConst.ITEM_STATUS_LOCKED, retLocked, function(retCode)
		if retCode then
			facade:sendMsgToUI(MessageName.PET_CARRY_LOCK_CHANGE, {
				isLocked = retLocked
			})
		end
	end)
end

function PetManageSystem:getCoreCarryWithAssitFullInfo(itemId)
	local function filterCoreCarryFunc(item)
		if itemId and item.id ~= itemId then
			return false
		end

		local cData = ItemData[item.id]

		return cData and cData.type == ItemConst.ITEM_TYPE_CARRY_CORE
	end

	return self:getCarryPropList(filterCoreCarryFunc)
end

function PetManageSystem:checkCoreCarryCertify(petId, player, skipCostCheck)
	player = player or pg.me

	if not player then
		return false, NoticeDef.ERROR_PET_NOT_FOUND
	end

	if not player.isFunctionAndSwitchEnable or not player:isFunctionAndSwitchEnable(FunctionEnum.PETEQUIPMENT) then
		return false, NoticeDef.FUNC_NOT_UNLOCK
	end

	if type(petId) ~= "string" then
		return false, NoticeDef.ERROR_CLIENT_PARAM
	end

	local petInfo = player.pets and player.pets[petId]

	if not petInfo then
		return false, NoticeDef.ERROR_PET_NOT_FOUND
	end

	local coreCarryItem = petInfo:getCoreCarryItem()

	if not coreCarryItem then
		return false, NoticeDef.PET_EQUIPMENT_BIND_NO_CORE_CARRY
	end

	if not ItemUtils.isCoreCarryItem(coreCarryItem.id) then
		return false, NoticeDef.PET_EQUIPMENT_BIND_CORE_CARRY_INVALID
	end

	local coreCarryInfo = ItemUtils.getPropertyWithType(coreCarryItem)

	if not coreCarryInfo or not coreCarryInfo.isValid or not coreCarryInfo:isValid() then
		return false, NoticeDef.PET_EQUIPMENT_BIND_CORE_CARRY_INVALID
	end

	if PetManagementDataHelper.isCoreCarryCertified(coreCarryInfo) then
		return false, NoticeDef.PET_EQUIPMENT_BIND_ALREADY_CERTIFIED
	end

	if coreCarryInfo.ownerPetId ~= petId then
		return false, NoticeDef.PET_EQUIPMENT_BIND_NO_CORE_CARRY
	end

	local requiredLevel = PetManagementDataHelper.getCoreCarryCertifyRequiredLevel(coreCarryItem.id)

	if requiredLevel == nil then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	if requiredLevel == -1 then
		return false, NoticeDef.PET_EQUIPMENT_BIND_CORE_CARRY_FORBIDDEN
	end

	local coreCarryLevel = coreCarryInfo:getLevelAndExp()

	if coreCarryLevel < requiredLevel then
		return false, NoticeDef.PET_EQUIPMENT_BIND_CORE_CARRY_LEVEL_LACK, {
			requiredLevel = requiredLevel,
			coreCarryLevel = coreCarryLevel
		}
	end

	local isSkillConfigValid, targetBaseFormPet = PetManagementDataHelper.checkPetCoreCarryCertifyStage(petInfo)

	if isSkillConfigValid == nil then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	if not isSkillConfigValid then
		return false, NoticeDef.PET_EQUIPMENT_BIND_PET_SKILL_INVALID
	end

	local costDict = PetManagementDataHelper.getCoreCarryCertifyCostDict(petInfo)

	if not costDict then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	if not skipCostCheck then
		for itemId, itemCount in pairs(costDict) do
			local ownCount = ItemUtils.getItemCountByIdCanUse(player, itemId, false)

			if ownCount < itemCount then
				return false, NoticeDef.ITEM_COUNT_LACK, {
					itemId = itemId,
					itemCount = itemCount,
					ownCount = ownCount
				}
			end
		end
	end

	return true, NoticeDef.SUCCESS, {
		petInfo = petInfo,
		coreCarryItem = coreCarryItem,
		coreCarryInfo = coreCarryInfo,
		coreCarryLevel = coreCarryLevel,
		requiredLevel = requiredLevel,
		targetBaseFormPet = targetBaseFormPet,
		costDict = costDict
	}
end

function PetManageSystem:sendRpcCertifyCoreCarry(petId, callback)
	local success, noticeId, context = self:checkCoreCarryCertify(petId)

	if not success then
		return false, noticeId, context
	end

	pg.me:serverMsg("RPC_CS_CertifyCoreCarry", petId, function(resultNoticeId, noticeArgs)
		if callback then
			callback(resultNoticeId, noticeArgs)
		end
	end)

	return true, NoticeDef.SUCCESS, context
end

function PetManageSystem:waitCoreCarryCertifySync(petId, expectedBaseFormPet, callback)
	local retryCount = 0

	local function tryFinish()
		local petInfo = pg.me and pg.me.pets and pg.me.pets[petId]
		local coreCarryInfo = petInfo and petInfo:getCoreCarryInfo()
		local isSynced = coreCarryInfo and coreCarryInfo.ownerPetId == petId and coreCarryInfo.certifiedBaseFormPet == expectedBaseFormPet

		if isSynced then
			if callback then
				callback(true)
			end

			return
		end

		retryCount = retryCount + 1

		if retryCount < CORE_CARRY_CERTIFY_SYNC_MAX_RETRY then
			self:startTimer(tryFinish, CORE_CARRY_CERTIFY_SYNC_INTERVAL)

			return
		end

		logger:warn("waitCoreCarryCertifySync timeout, petId=%s, expectedBaseFormPet=%s", tostring(petId), tostring(expectedBaseFormPet))

		if callback then
			callback(false)
		end
	end

	tryFinish()
end

function PetManageSystem:getCarryPropList(filterFunc)
	local itemList = {}

	local function finalFilterFunc(item, invId)
		rawset(item, "invId", invId)

		if filterFunc then
			return filterFunc(item)
		end

		return true
	end

	ItemUtils.eachSupportedTypedBag(pg.me, function(invId, itemBag)
		local iList = itemBag:getByFilter(function(item)
			return finalFilterFunc(item, invId)
		end)

		table.mergeList(itemList, iList)
	end)

	local carryInfoList = Lume.imap(itemList, function(v)
		return self:parseCarryFullInfo(v)
	end)

	return carryInfoList
end

function PetManageSystem:parseCarryFullInfo(item)
	local sData = ItemUtils.getPropertyWithType(item)

	if not sData then
		return nil
	end

	local data = sData:getRawTable()

	LuaUIUtils.parseItemCfgData(data)
	self:parseItemInfo(data, item)
	self:parseCarryPetInfo(data, sData)
	self:parseAttr(sData, data)

	return data
end

function PetManageSystem:parseItemInfo(data, v)
	data.sourceItem = v
	data.genID = v.genID
	data.isLocked = v:isStatusLocked()
	data.invId = v.invId or v.getInvID and v:getInvID()

	local cfg = self:getCarryORCarryAsstCfg(data.itemId)

	data.familyId = cfg and cfg.familyId or cfg.type
	data.ownNum = 1
	data.bigIcon = LuaUIUtils.getIconByItemId(data.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_BIG)
	data.icon = LuaUIUtils.getIconByItemId(data.itemId)
	data.l10nName = LuaUIUtils.getNameByItemId(data.itemId)
end

function PetManageSystem:getCarryORCarryAsstCfg(itemId)
	return ItemUtils.isCoreCarryItem(itemId) and CoreCarryData[itemId] or AssistCarryData[itemId]
end

function PetManageSystem:parseCarryPetInfo(data, sData)
	local pId

	if data.type == ItemConst.ITEM_TYPE_CARRY_CORE then
		pId = data.ownerPetId

		local me = pg.me
		local pInfo = me:getPetInfo(pId)

		if pInfo then
			data.isEquipped = true
			data.petIcon = LuaUIUtils.getPetIconByTemplateId(pInfo.templateId, LuaUIUtils.PET_ICON, pInfo.label)
			data.petName = pg.getLocalizationText(LuaUIUtils.getPetName(pId))
		else
			data.isEquipped = false
			data.petIcon = nil
		end
	else
		local coreCarry = sData.ownerCoreCarryPos

		data.isEquipped = false
		data.coreIcon = nil
		data.coreName = nil

		if coreCarry:isValid() then
			local coreCarryData = self:parseCarryFullInfoWithId(coreCarry:invId(), coreCarry:genId())

			if coreCarryData then
				pId = coreCarryData.ownerPetId
				data.isEquipped = true
				data.coreIcon = LuaUIUtils.getIconByItemId(coreCarryData.itemId)
				data.coreName = LuaUIUtils.getNameByItemId(coreCarryData.itemId)
			end
		end

		local me = pg.me
		local pInfo = me:getPetInfo(pId)

		if pInfo then
			data.petIcon = LuaUIUtils.getPetIconByTemplateId(pInfo.templateId, LuaUIUtils.PET_ICON, pInfo.label)
			data.petName = pg.getLocalizationText(LuaUIUtils.getPetName(pId))
		else
			data.petIcon = nil
		end
	end
end

function PetManageSystem:parseCarryFullInfoWithId(invId, genID)
	local itemBag = ItemUtils.getTypedBag(pg.me, invId)
	local item = itemBag and itemBag:get(genID)

	return self:parseCarryFullInfo(item)
end

function PetManageSystem:parseCarryAttr(sData, data)
	local sLv, cExp = sData:getLevelAndExp()

	data.cLevel = sLv
	data.curExp = cExp

	local mLv, totalCanAddExp = sData:getMaxLevelAndTotalExp()

	data.mLevel = mLv
	data.maxExp = CoreCarryLevelData[sLv + 1] and CoreCarryLevelData[sLv + 1].needExp or math.maxInt
	data.isMaxLv = mLv <= sLv
	data.addExp = sData.totalExp
	data.totalCanAddExp = totalCanAddExp

	local mainTalents = {}

	for _, tInfo in ipairs(data.talentList) do
		local tId = tInfo.templateId
		local vVa = tInfo.propValues
		local cData = PetTalentData[tId]

		if cData.props then
			for i, v in ipairs(cData.props) do
				mainTalents[#mainTalents + 1] = {
					id = v[1],
					value = vVa[i] or 0
				}
			end
		end
	end

	local cData = CoreCarryData[data.itemId]

	if cData and cData.prop then
		for id, v in pairs(cData.prop) do
			mainTalents[#mainTalents + 1] = {
				id = id,
				value = v or 0
			}
		end
	end

	local addition = sData:getEnhanceRatio()

	for _, v in ipairs(mainTalents) do
		local aData = AttributeData[v.id]

		if aData then
			v.name = pg.getLocalizationText(aData.name)
		end

		if v.value < 0 then
			v.tValue = (1 - addition) * v.value
		else
			v.tValue = (1 + addition) * v.value
		end

		v.tDesc = Utils.formatAttrDesc(v.tValue, 1, true)
		v.icon = aData.icon
	end

	data.mainProperties = mainTalents

	local desc

	if cData.buffId ~= nil then
		for _, v in ipairs(cData.buffId) do
			local bData = BuffData[v]
			local str = pg.getLocalizationText(bData.buffDesc)

			if string.isNilOrEmpty(desc) then
				desc = str
			else
				desc = string.format("%s\n%s", desc, str)
			end
		end
	end

	data.buffDesc = desc

	local assistUnlock = {}

	if cData and cData.slotUnlockLv ~= nil then
		for index, unlockLv in ipairs(cData.slotUnlockLv) do
			assistUnlock[index] = unlockLv <= data.cLevel and 1 or 0
		end
	end

	data.slotUnlockLv = cData.slotUnlockLv
	data.assistUnlock = assistUnlock

	local energyEffects = {}

	if cData and cData.energyEffects ~= nil then
		for index, effCfg in ipairs(cData.energyEffects) do
			local effDesc

			for _, v in ipairs(effCfg[2]) do
				local bData = BuffData[v]
				local str = pg.getLocalizationText(bData.buffDesc)

				if string.isNilOrEmpty(effDesc) then
					effDesc = str
				else
					effDesc = string.format("%s\n%s", effDesc, str)
				end
			end

			energyEffects[index] = {
				energy = effCfg[1],
				effDesc = effDesc,
				enhanceLv = effCfg[3] or 0
			}
		end
	end

	data.energyEffects = energyEffects

	local energySum = 0

	for _, itemPos in ipairs(data.assistCarryPosList) do
		local assistCarryCfg = self:parseCarryAssistCfgWithId(itemPos[1], itemPos[2])

		if assistCarryCfg then
			energySum = energySum + assistCarryCfg.energy
		end
	end

	data.energySum = energySum
end

function PetManageSystem:parseCarryAssistCfgWithId(invId, genID)
	local itemBag = ItemUtils.getTypedBag(pg.me, invId)
	local item = itemBag and itemBag:get(genID)
	local sData = item and ItemUtils.getPropertyWithType(item)
	local data = sData and sData:getRawTable()

	if data then
		LuaUIUtils.parseItemCfgData(data)

		local asstCfg = AssistCarryData[data.itemId]

		data.energy = asstCfg.energy
	end

	return data or nil
end

function PetManageSystem:parseAttr(sData, data)
	if data.type == ItemConst.ITEM_TYPE_CARRY_CORE then
		self:parseCarryAttr(sData, data)
	else
		self:parseCarryAssistAttr(sData, data)
	end
end

function PetManageSystem:parseCarryAssistAttr(sData, data)
	data.energy = sData:getEnergy()
	data.cpValue = sData:getCpValue()
	data.assistType = sData:getAssistType()

	local mainTalents = {}
	local cData = AssistCarryData[data.itemId]

	if cData and cData.baseprop and next(cData.baseprop) then
		for id, v in pairs(cData.baseprop) do
			mainTalents[#mainTalents + 1] = {
				id = id,
				value = v or 0
			}
		end

		for index, v in ipairs(mainTalents) do
			local aData = AttributeData[v.id]

			if aData then
				v.name = pg.getLocalizationText(aData.name)
			end

			v.tValue = v.value
			v.tDesc = Utils.formatAttrDesc(v.tValue, aData.showType, true)
			v.icon = aData.icon
		end
	end

	data.mainProperties = mainTalents

	local randomProperties = {}

	for _, tInfo in ipairs(data.talentList) do
		local tId = tInfo.templateId
		local vVa = tInfo.propValues
		local cData = PetTalentData[tId]

		if cData.props then
			for i, v in ipairs(cData.props) do
				local randomPro = tInfo.scaleFixs and next(tInfo.scaleFixs) and tInfo.scaleFixs[1] or PetConfigData.gemsPropQualityColor[1]
				local attrPro = self:parseCarryAssistValuePro(randomPro)

				randomProperties[#randomProperties + 1] = {
					id = v[1],
					value = vVa[i] or 0,
					quality = self:parseCarryAssistValueQuality(randomPro),
					pro = attrPro,
					isMax = attrPro == 1,
					isRare = cData.rarity == 2
				}
			end
		end
	end

	for index, v in ipairs(randomProperties) do
		local aData = AttributeData[v.id]

		if aData then
			v.name = pg.getLocalizationText(aData.name)
		end

		v.tValue = v.value
		v.tDesc = Utils.formatAttrDesc(v.tValue, aData.showType, true)
		v.icon = aData.icon
	end

	table.sort(randomProperties, function(a, b)
		return a.id < b.id
	end)

	data.randomProperties = randomProperties
end

function PetManageSystem:parseCarryAssistValuePro(pro)
	local newPro = pro
	local qualities = PetConfigData.gemsPropQualityColor
	local maxNum = qualities and next(qualities) and qualities[#qualities] or 1

	newPro = pro / maxNum

	return newPro
end

function PetManageSystem:parseCarryAssistValueQuality(value)
	local quality = 0
	local qualities = PetConfigData.gemsPropQualityColor

	if qualities and next(qualities) then
		for i, v in ipairs(qualities) do
			if v <= value then
				quality = quality + 1
			end
		end
	end

	return math.max(0, quality + 2)
end

function PetManageSystem:sendCoreCarryStrengthRpc(invId, genId, consumeList, consumeDict, carryStrengthInfo)
	pg.me:serverMsg("RPC_CS_UpgradeCoreCarry", invId, genId, consumeList, consumeDict)
end

function PetManageSystem:setCoreCarryStrengthRecored(invId, genId, carryStrengthInfo)
	self.m_carryInfos = self.m_carryInfos or {}

	if not invId or not genId then
		return
	end

	self.m_carryInfos.curStrengthCarryInfo = Utils.deepCopyTable(carryStrengthInfo)
end

function PetManageSystem:getCoreCarryStrengthRecored(invId, genId)
	return self.m_carryInfos and self.m_carryInfos.curStrengthCarryInfo or {}
end

function PetManageSystem:resetCarryInfos()
	self.m_carryInfos = {}
end

function PetManageSystem:onRequstBatchEquipCarrySuccess()
	facade:sendMsgToUI(MessageName.PET_CARRY_BATCH_EQUIP_SUCCESS)
end

function PetManageSystem:getRealCostItem(player, itemConditions)
	local ret = {}
	local checked, realItems, altIdNumDict, replacedInfo = ItemUtils.getEvolveNeedItemResult(player, itemConditions)

	if checked then
		for itemId, count in pairs(realItems) do
			local temp = {}

			temp[1] = itemId
			temp[2] = count

			for _, v in pairs(replacedInfo) do
				if v.oriItemId == itemId then
					temp[2] = temp[2] + realItems[v.newItemId]

					break
				end
			end

			ret[#ret + 1] = temp
		end
	end

	return ret, altIdNumDict, replacedInfo
end

local function makeUniversalConvertTipItem(player, itemId, replaceNum)
	local iData = ItemData[itemId] or {}

	return {
		id = itemId,
		ownNum = ItemUtils.getItemCountById(player, itemId),
		quality = iData.quality,
		itemName = iData.itemName,
		iconName = LuaUIUtils.getIconByIconId(iData.icon),
		replaceNum = replaceNum
	}
end

function PetManageSystem:getCostItemsAlternativeResult(player, costItems, allowInsufficientAlternative)
	local idNumDict = {}

	for _, itemInfo in ipairs(costItems or EMPTY_TABLE) do
		local itemId = itemInfo and itemInfo[1] or 0
		local itemNum = itemInfo and itemInfo[2] or 0

		if itemId > 0 and itemNum > 0 then
			idNumDict[itemId] = (idNumDict[itemId] or 0) + itemNum
		end
	end

	if Utils.tableIsEmptyOrNil(idNumDict) then
		return true, {}, {}, {}
	end

	if allowInsufficientAlternative then
		return self:getCostItemsAlternativeResultByConfig(player, idNumDict)
	end

	return ItemUtils._getRealIdNumDictWithAlternative(player, idNumDict)
end

function PetManageSystem:getCostItemsAlternativeResultByConfig(player, idNumDict)
	local resIdNumDict = Lume.clone(idNumDict)
	local altIdNumDict = {}
	local replacedInfo = {}
	local resultFlag = 0

	for needId, needCount in pairs(idNumDict or EMPTY_TABLE) do
		local realNeedCount = needCount + (altIdNumDict[needId] or 0)
		local hasCount = ItemUtils.getItemCountById(player, needId)

		if hasCount < realNeedCount then
			local altData = PetEvolveItemSubData[needId]

			if altData == nil or altData.alternativeItem == nil or ToInt(altData.num) <= 0 or ToInt(altData.alternativeItemNum) <= 0 then
				resultFlag = resultFlag + 1
			else
				local beReplacedCount = realNeedCount - hasCount
				local altNeedId = altData.alternativeItem
				local altNeedCount = math.ceil(beReplacedCount / altData.num * altData.alternativeItemNum)

				altIdNumDict[altNeedId] = (altIdNumDict[altNeedId] or 0) + altNeedCount
				resIdNumDict[needId] = resIdNumDict[needId] - beReplacedCount
				replacedInfo[#replacedInfo + 1] = {
					oriItemId = needId,
					oriNum = beReplacedCount,
					newItemId = altNeedId,
					newNum = altNeedCount
				}
			end
		end
	end

	for itemId, itemCount in pairs(altIdNumDict) do
		resIdNumDict[itemId] = (resIdNumDict[itemId] or 0) + itemCount
	end

	return resultFlag <= 0, resIdNumDict, altIdNumDict, replacedInfo
end

function PetManageSystem:openUniversalItemConvertTip(replacedInfo, ensureCb, player)
	if Utils.tableIsEmptyOrNil(replacedInfo) then
		return false
	end

	player = player or pg.me

	local leftItems = {}
	local rightItems = {}

	for _, v in ipairs(replacedInfo) do
		leftItems[#leftItems + 1] = makeUniversalConvertTipItem(player, v.newItemId, v.newNum)
		rightItems[#rightItems + 1] = makeUniversalConvertTipItem(player, v.oriItemId, v.oriNum)
	end

	if Utils.tableIsEmptyOrNil(leftItems) or Utils.tableIsEmptyOrNil(rightItems) then
		return false
	end

	pg.global.ui:open(UIConst.UI_ID_LEVEL_BREAKTHROUGH_TIP, {
		leftItem = leftItems,
		rightItem = rightItems,
		ensureCb = ensureCb
	})

	return true
end

function PetManageSystem:getPetManageFallbackPetId(player, petId)
	if not petId then
		local preparePetLsit = player and player.petPrepareList or {}

		for _, mPetId in pairs(preparePetLsit or EMPTY_TABLE) do
			if mPetId then
				petId = mPetId

				break
			end
		end

		if not petId then
			return false
		end
	end

	return petId
end

function PetManageSystem:markRecyclingPets(petIds)
	if not Utils.isTable(petIds) then
		return
	end

	self.m_recyclingPetIds = self.m_recyclingPetIds or {}

	for _, petId in pairs(petIds) do
		if petId then
			self.m_recyclingPetIds[petId] = true
		end
	end
end

function PetManageSystem:unmarkRecyclingPets(petIds)
	if not Utils.isTable(petIds) or not Utils.isTable(self.m_recyclingPetIds) then
		return
	end

	for _, petId in pairs(petIds) do
		self.m_recyclingPetIds[petId] = nil
	end
end

function PetManageSystem:hasRecyclingPet(petIds)
	if not Utils.isTable(petIds) or not Utils.isTable(self.m_recyclingPetIds) then
		return false
	end

	for _, petId in pairs(petIds) do
		if self.m_recyclingPetIds[petId] == true then
			return true
		end
	end

	return false
end

function PetManageSystem:shouldSkipPetRedDotRecord(player, petId)
	if not petId then
		return false
	end

	local isPending = Utils.isTable(self.m_recyclingPetIds) and self.m_recyclingPetIds[petId] == true

	if isPending then
		if player and Utils.isTable(player.pets) and player.pets[petId] == nil then
			self.m_recyclingPetIds[petId] = nil
		end

		return true
	end

	local isAbsent = player ~= nil and Utils.isTable(player.pets) and player.pets[petId] == nil

	return isAbsent
end

function PetManageSystem:getPetIsInBattle(petId, excludeRogue)
	if not petId then
		return false
	end

	if lume.find(pg.me.petPrepareList, petId) ~= nil then
		return true
	end

	if not excludeRogue then
		return self:getPetIsInGamePlayBattle(petId)
	end

	return false
end

function PetManageSystem:getPetIsInGamePlayBattle(petId)
	if not petId then
		return false
	end

	return RogueUtils.isPetInRogue(petId)
end

return PetManageSystem
