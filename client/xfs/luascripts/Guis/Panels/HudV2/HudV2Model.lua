-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\HudV2Model.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HudV2Model")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local FuncMenuCommonData = require("Data.func_menu_common_use_data")
local FuncMenuListData = require("Data.func_menu_list_data")
local AbilityConst = require("Common.Const.AbilityConst")
local HudFuncData = require("Data.hud_func_button_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SkillTagData = require("Data.skill_tag_data")
local lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityPopUtils = require("Utils.ActivityPopUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomelandReportUtils = require("Utils.HomelandReportUtils")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local PetConfigData = require("Data.pet_config_data")
local ElementPropData = require("Data.element_prop_data")
local AddressDataConst = require("Const.AddressDataConst")
local UIModel = require("Guis.UIModel")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local HudV2Model = Class.LightClass("HudV2Model", UIModel)

HudV2Model.NORMAL_PAGE = 0
HudV2Model.SYN_BODY = 1
HudV2Model.CATCH = 2
HudV2Model.ARK = 3
HudV2Model.PET_PVP = 4
HudV2Model.EXPLORE = 5
HudV2Model.ROGUE = 6
HudV2Model.SKILL_EX = 7
HudV2Model.VEHICLE = 9
HudV2Model.HOOK = 10

function HudV2Model:getFollowPetEnt(petIdx)
	local player = pg.me
	local petPrepareInfoList = player.petPrepareList

	if petPrepareInfoList then
		local petId = petPrepareInfoList[petIdx]

		if petId == nil then
			return nil
		end

		return pg.getEntity(petId)
	end

	return nil
end

function HudV2Model:getTeamFollowPetInfosV2()
	if pg.me.inTeammateView then
		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local player = pg.getEntity(info.entityId)
				local petInfos = {}
				local teamPetCount = #petInfos
				local petPrepareInfoList = player.petPrepareList

				if petPrepareInfoList then
					local hasSupportPet = player.space and player.space.battleMode > 0

					for idx, petId in pairs(petPrepareInfoList) do
						local petInfo = self:getTeamFollowPetInfo(idx)

						if petInfo then
							if hasSupportPet and idx > player.space.battleMode then
								petInfo.tIndex = 1
							else
								petInfo.tIndex = 0
							end

							petInfos[#petInfos + 1] = petInfo
						end
					end
				end

				local selfPetCount = #petInfos - teamPetCount

				return petInfos, selfPetCount
			end
		end
	end
end

function HudV2Model:getFollowPetInfosV2()
	local petInfos = {}
	local player = pg.me
	local teamPetCount = #petInfos
	local petPrepareInfoList = player:isTeamPlayerInWorld() and player:getTeamPetIds() or player.petPrepareList

	if petPrepareInfoList then
		local hasSupportPet = player.space and player.space.battleMode > 0

		for idx, petId in pairs(petPrepareInfoList) do
			local petInfo = self:getFollowPetInfo(idx)

			if petInfo then
				if hasSupportPet and idx > player.space.battleMode then
					petInfo.tIndex = 1
				else
					petInfo.tIndex = 0
				end

				petInfos[#petInfos + 1] = petInfo
			end
		end
	end

	local selfPetCount = #petInfos - teamPetCount

	return petInfos, selfPetCount
end

function HudV2Model:getFollowPetInfo(petIdx)
	local player = pg.me
	local petPrepareInfoList = player.petPrepareList

	if petPrepareInfoList then
		local petId = petPrepareInfoList[petIdx]

		if petId == nil then
			return nil
		end

		local petInfo = {}
		local pet = player:getPetInfo(petId)

		if pet == nil then
			return nil
		end

		if petId == player.curCombatPetId then
			self.curControlPetIdx = petIdx
		end

		local abilityInfo = pet.curAbilityMap[AbilityConst.EnumAbilityType.Ultimate]
		local abilityElementType = pg.global.abilityMgr:getAbilityParamData(abilityInfo and abilityInfo.abilityId).elementType or 0

		petInfo.abilityElementName = ElementPropData[abilityElementType].name
		petInfo.isSelected = petId == player.curCombatPetId

		local petTemplateId = pet.templateId

		petInfo.templateId = petTemplateId

		local pData = PetData[petTemplateId] or {}

		if pData.comboAbilityId then
			petInfo.finalSkillElement = pg.global.abilityMgr:getAbilityTemplate(pData.comboAbilityId, 1).elementType
		end

		local name = pData.name

		petInfo.gender = pet.gender
		petInfo.name = name
		petInfo.iconName = pData.iconName

		local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

		petInfo.elementIds = elementIds
		petInfo.mainElementType = pData.mainElementType
		petInfo.elementNames = elementNames
		petInfo.index = petIdx
		petInfo.id = petId
		petInfo.customName = pet.customName
		petInfo.label = pet.label
		petInfo.level = pet.level

		local petFunctionType = pData.functionId

		petInfo.petFunctionTypeIcon = petFunctionType and PetConfigData.petFunctionIcon[petFunctionType]
		petInfo.isTrial = pet.isTrial

		return petInfo
	end

	return nil
end

function HudV2Model:getUsePetSkillInfoBySkillType(skillType)
	local skillInfo = {}
	local petSkillType = AbilityConst.PLAYER_SKILL_TO_PET_SKILL_MAP[skillType]
	local player = pg.me
	local petEnt = player:getCurPetEntity()

	if not petEnt then
		return {}
	end

	local petSkillInfo = petEnt:getSkillByType(petSkillType)

	if not petSkillInfo then
		return {}
	end

	local abilityId = petEnt:getSwitchSkill(petSkillInfo.abilityId)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local attackType = abilityParamData.attackType
	local epCost = AbilityUtils.getAbilityParamEpCost(abilityParamData, petEnt)

	skillInfo.cost = epCost
	skillInfo.showCost = true

	if petSkillType == AbilityConst.ULTIMATE_ABILITY then
		skillInfo.cost = AbilityUtils.getAbilityParamSpCost(abilityParamData, petEnt)
		skillInfo.showCost = false
	end

	table.merge(skillInfo, petSkillInfo)

	skillInfo.elementType = abilityParamData.elementType
	skillInfo.name = abilityParamData.name
	skillInfo.attackType = attackType
	skillInfo.skillType = petSkillType
	skillInfo.skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon)
	skillInfo.abilityType = petSkillType
	skillInfo.abilityParamData = abilityParamData

	return skillInfo
end

function HudV2Model:getPetSkillInfByType(pet, abilityType)
	if not pet then
		return {}
	end

	local abilityId = pet:getSkillIdByType(abilityType)
	local skillInfo = LuaUIUtils.getSkillInfByAbilityId(abilityId, pet)

	return skillInfo
end

function HudV2Model:getExploreInfoByEnt(ent)
	local configData = ent:getConfigData()
	local templateId = configData.spriteIdAfterCatch
	local playerHandBookMap = pg.me.petHandbookMap
	local petInfo = {}

	petInfo.iconName = configData.iconName
	petInfo.level = ent.level
	petInfo.name = configData.name
	petInfo.elementTypes = ent.elementTypes

	local elementIds, elementNames = LuaUIUtils.getElementInfo(ent.elementTypes)
	local restraintElements = self:getRestraintElement(true, elementNames)
	local beRestraintElements = self:getRestraintElement(false, elementNames)
	local combatTipsId = configData.battleTips
	local captureTipsId = configData.catchTips

	petInfo.beRestraintElements = beRestraintElements
	petInfo.restraintElements = restraintElements
	petInfo.combatDesc = self:getAttrDescById(combatTipsId)
	petInfo.captureDesc = self:getAttrDescById(captureTipsId)

	local playerData = playerHandBookMap[templateId]

	if playerData and playerData:isKnown() then
		petInfo.condition = playerData.completedTarget
		petInfo.isCrown = playerData:isResearched()
	end

	return petInfo
end

function HudV2Model:getCommonSkillInfByAbilityId(abilityId)
	local skillInfo = {}

	skillInfo.abilityId = abilityId

	local abilityParamData = pg.global.abilityMgr:getAbilityParamDataByParamId(abilityId)
	local attackType = abilityParamData.attackType

	skillInfo.showCost = false
	skillInfo.elementType = abilityParamData.elementType
	skillInfo.name = abilityParamData.name

	if abilityParamData.tags and abilityParamData.tags[1] then
		skillInfo.name = SkillTagData[abilityParamData.tags[1]].tagName
	end

	skillInfo.attackType = attackType
	skillInfo.abilityParamData = abilityParamData
	skillInfo.skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon)

	return skillInfo
end

function HudV2Model:getExitExploreDelaySkillInfo()
	local abilityId = AbilityConst.CommonAbility.ExitDelayExplore
	local skillInfo = self:getCommonSkillInfByAbilityId(abilityId)

	skillInfo.actionPath = AbilityConst.CommonAbilityActionPath[abilityId] or ""

	return skillInfo
end

function HudV2Model:getExitControlEggInfo()
	local info = {}

	info.name = pg.getGameString("EXIT_CONTROL_EGG")
	info.skillIcon = AddressDataConst.UI_ICON_SKILL_EXIT
	info.actionPath = "Hud/SwitchPet"
	info.checkPetLinkModuleEnable = true

	return info
end

function HudV2Model:getExitCarryEggInfo()
	local info = {}

	info.name = pg.getGameString("EXIT_CARRY_EGG")
	info.skillIcon = AddressDataConst.UI_ICON_SKILL_EXIT
	info.actionPath = "Hud/ExitCarryEgg"

	return info
end

function HudV2Model:getEggStruggleInfo()
	local info = {}

	info.name = pg.getGameString("ROB_EGG_STRUGGLE")
	info.skillIcon = AddressDataConst.UI_ICON_SKILL_EXIT
	info.actionPath = "Common/Cancel"

	return info
end

function HudV2Model:getGhostEyeSwitchSkillInfo()
	local pet = pg.me:getCurPetEntity()
	local abilityId = pet:getSkillIdByType(AbilityConst.EXPLORE_ABILITY)
	local switchAbilityId = pet:getSwitchSkill(abilityId)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(switchAbilityId)
	local info = {}

	info.abilityId = abilityId
	info.abilityType = AbilityConst.EXPLORE_ABILITY
	info.name = pg.getGameString("PEEP_QUIT")
	info.skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon)
	info.actionPath = "Hud/ExploreSkill"

	return info
end

function HudV2Model:getPlayerSkillInfBySkillType(skillType)
	local skillInfo = {}
	local playerSkillInfo = pg.me:getSkillInfoBySkillType(skillType)

	if skillType == AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T and pg.me.skillVisibleMap.T ~= false then
		playerSkillInfo = {
			abilityLv = 1,
			abilityId = ClientConst.BackSkillId
		}
	end

	if playerSkillInfo and playerSkillInfo.abilityId and pg.me then
		local abilityId = pg.me:getSwitchSkill(playerSkillInfo.abilityId)
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		if pg.me:checkArkSceneState() and not lume.findInList(abilityParamData.stateCheckExclude, Const.ARK_STATE_NAME) then
			return skillInfo
		end

		local attackType = abilityParamData.attackType
		local epCost = AbilityUtils.getAbilityParamEpCost(abilityParamData, pg.pawn)

		skillInfo.cost = epCost
		skillInfo.showCost = true

		table.merge(skillInfo, playerSkillInfo)

		skillInfo.elementType = abilityParamData.elementType
		skillInfo.name = abilityParamData.name

		if abilityParamData.tags and abilityParamData.tags[1] then
			local tagInfo = SkillTagData[abilityParamData.tags[1]]

			if tagInfo then
				skillInfo.name = tagInfo.tagName
			end
		end

		skillInfo.attackType = attackType
		skillInfo.skillType = skillType
		skillInfo.skillIcon = LuaUIUtils.getSkillIcon(abilityParamData.icon)
		skillInfo.abilityParamData = abilityParamData
		skillInfo.abilityType = skillType

		local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(playerSkillInfo.abilityId)

		if abilityTemplateData and abilityTemplateData.maxLoadedCnt then
			skillInfo.backListNum = abilityTemplateData.maxLoadedCnt
			skillInfo.loadingCd = abilityTemplateData.loadingCd
		end
	end

	return skillInfo
end

function HudV2Model:checkFuncExtraCondition(funcId, functionType)
	if funcId == Const.FUNCTION_IDS.MONTH_CARD_PREORDER then
		return MonthCardUtils.isPreorderGuideEnabled() and MonthCardUtils.isPreorderGuideTriggerMatched()
	end

	if funcId == 203 then
		local space = pg.me and pg.me.space

		return space and space.isSelfHomeCamp and space:isSelfHomeCamp(pg.me)
	elseif funcId == Const.FUNCTION_IDS.BATTLEPASS then
		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

		return actData and actData.activityBase and actData.activityBase:isGoing()
	end

	if functionType == "homelandLog" or functionType == "homePlant" or functionType == "furnitureDesign" then
		local space = pg.me and pg.me.space

		return space and space.isSelfHomeland and space:isSelfHomeland(pg.me)
	elseif functionType == "homelandSeason" then
		local seasonId = pg.me and (pg.me.homeSeasonId or 0) or 0

		return HomeSeasonUtils.isSeasonOpen(seasonId)
	elseif functionType == "homelandReport" then
		return HomelandReportUtils.isAvailable()
	elseif functionType == "homeCampReport" then
		return HomelandReportUtils.isHomeCampReportAvailable()
	end

	return true
end

function HudV2Model:isHomeSeasonAvailable(player)
	return HomeSeasonUtils.isSeasonAvailable(player)
end

function HudV2Model:isSeasonLobbyOpen()
	if not pg.me then
		return false
	end

	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(ActivityConst.EventType.SeasonActivity, pg.me)

	if not isOpen or not activityId then
		return false
	end

	return ClientActivityUtils.isGameEventTabOpen(activityId)
end

function HudV2Model:isSeasonLobbyAvailable()
	if not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.SEASON) then
		return false
	end

	if not self:isSeasonLobbyOpen() then
		return false
	end

	if pg.me and pg.me.isInRiftMode then
		return not pg.me:isInRiftMode()
	end

	return true
end

function HudV2Model:isSeasonActivityPopPending()
	local tipsCtrl = pg.global.ui.tips
	local dispatcher = tipsCtrl and tipsCtrl.dispatcher

	if dispatcher and dispatcher.sessionStarted then
		return dispatcher:hasActivityPopPending(ActivityConst.EventType.SeasonActivity)
	end

	return ActivityPopUtils.hasPopByEventType(ActivityConst.EventType.SeasonActivity)
end

function HudV2Model:getFunctionButtonConfigByScene()
	local playerSpace = pg.me and pg.me.space
	local sceneId = playerSpace and playerSpace.sceneId or 0

	return HudFuncData[sceneId] or HudFuncData[0] or {}
end

function HudV2Model:isSeasonEntryConfiguredByScene(useSpecialFunc)
	local hudData = self:getFunctionButtonConfigByScene()
	local funcField = useSpecialFunc and "funcSpecial" or "func"
	local funcInfo = hudData[funcField] or EMPTY_TABLE

	for _, funcValue in ipairs(funcInfo) do
		if funcValue[2] == Const.FUNCTION_IDS.SEASON then
			return true
		end
	end

	return false
end

function HudV2Model:hasSpecialFunctionButtonByScene()
	local hudData = self:getFunctionButtonConfigByScene()
	local specialInfo = hudData.funcSpecial

	return specialInfo ~= nil and #specialInfo > 0
end

function HudV2Model:getFunctionButtonByScene(notGetLock, useSpecialFunc)
	local result = {}
	local funcMenu = pg.global.ui.funcMenu
	local hudData = self:getFunctionButtonConfigByScene()
	local info = useSpecialFunc and hudData.funcSpecial or hudData.func

	if not info or #info == 0 then
		return result
	end

	for _, funcValue in ipairs(info) do
		local funcType = funcValue[1]
		local funcId = funcValue[2]
		local funcData = self:getFunctionData(funcType, funcId)

		if funcData then
			local canAddToList = funcId ~= Const.FUNCTION_IDS.SEASON and LuaUIUtils.checkFuncUnlockForREVIEW(funcData.functionName or funcData["function"]) and self:checkFuncExtraCondition(funcId, funcData.functionType)

			if canAddToList then
				local icon = funcData.hudIcon
				local functionType = funcData["function"] or funcData.functionType
				local functionName = funcData.functionName
				local funcName = funcData.shortName

				table.insert(result, {
					id = funcId,
					name = pg.getLocalizationText(funcName),
					icon = icon,
					keyBindingName = functionName,
					actionPath = funcData.actionPath,
					btnClickFunc = function()
						funcMenu[functionType](funcMenu, funcData)
					end,
					sort1 = funcType == 2 and 1 or 2,
					sort2 = funcData.sort or math.maxInt,
					functionType = functionType
				})
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("funcData is null ", funcType, funcId)
		end
	end

	table.sort(result, function(a, b)
		if a.sort1 ~= b.sort1 then
			return a.sort1 < b.sort1
		end

		return a.sort2 < b.sort2
	end)

	return result
end

function HudV2Model:getFunctionData(type, id)
	local funcData = FuncMenuListData[id]

	if type == Const.FUNCTION_TYPE.FUNC_COMMON then
		funcData = FuncMenuCommonData[id]
	end

	return funcData
end

function HudV2Model:getCapturePropInfos()
	local propList = {}

	if pg.me then
		if ClientUtils.isInDouYinOfflineScene and ClientUtils.isInDouYinOfflineScene() then
			for _, info in ipairs(pg.me:getOfflineCaptureBalls()) do
				local itemId = info.itemId

				if itemId and ItemData[itemId] then
					propList[#propList + 1] = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
				end
			end
		elseif pg.me.isInFishingCapture and pg.me:isInFishingCapture() then
			return propList
		elseif Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			for idx, itemId in ipairs(pg.me.catchRogueInfo:getValidBallList(pg.me) or EMPTY_TABLE) do
				if itemId ~= 0 and ItemData[itemId] then
					local item_data = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
					local count = ClientUtils.getItemCountById(itemId)

					if count > 0 then
						propList[#propList + 1] = item_data
					end
				end
			end
		else
			for idx, itemId in pairs(pg.me.invQuickSlotBall) do
				if itemId ~= 0 and ItemData[itemId] and not ClientCaptureUtils.isPaidBall(itemId) then
					local item_data = {
						itemId = itemId,
						icon = ItemData[itemId].icon,
						name = ItemData[itemId].itemName
					}
					local count = ClientUtils.getItemCountById(itemId)

					if count > 0 then
						propList[#propList + 1] = item_data
					end
				end
			end
		end
	end

	return propList
end

return HudV2Model
