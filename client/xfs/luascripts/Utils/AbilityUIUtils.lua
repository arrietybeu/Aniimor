-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\AbilityUIUtils.lua

local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local UIConst = require("Const.UIConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AvatarData = require("Data.avatar_data")
local SkillTagData = require("Data.skill_tag_data")
local AbilityParamData = require("Data.ability_param_data")
local ElementPropData = require("Data.element_prop_data")
local TempleSkillNameReplaceData = require("Data.temple_skill_name_replace_data")
local AddressDataConst = require("Const.AddressDataConst")
local TimerManager = require("Core.Timer.TimerManager")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local UIStringPool = require("Guis.Utils.UIStringPool")
local ClientSwitch = require("Common.ClientSwitch")
local NoticeDef = require("Common.NoticeDef")
local pg = pg
local ToBool = ToBool
local NotNil = NotNil
local AbilityUIUtils = {}

function AbilityUIUtils.getSkillOwnerId(owner)
	return owner and (owner.actorId or owner.id) or nil
end

function AbilityUIUtils.resetEventSkillState(skillInfo, abilityId, owner)
	local ownerId = AbilityUIUtils.getSkillOwnerId(owner)

	if skillInfo.abilityId ~= abilityId or skillInfo.eventSkillOwnerId ~= ownerId then
		skillInfo.overrideTagId = nil
		skillInfo.overrideTagId = nil
		skillInfo.appliedOverrideTagId = nil
	end

	skillInfo.eventSkillOwnerId = ownerId
end

function AbilityUIUtils.setSkillDisplayName(btnRefInfo, skillInfo, name)
	local displayName = pg.getLocalizationText(name or "")

	if not skillInfo.enableLuaStateCache or not skillInfo.displayedSkillNameCached or skillInfo.displayedSkillName ~= displayName then
		skillInfo.displayedSkillNameCached = true
		skillInfo.displayedSkillName = displayName

		ClientTextUtils.setText(btnRefInfo.skillName, displayName)
	end
end

function AbilityUIUtils.setSkillNameWithoutOverride(btnRefInfo, skillInfo, name)
	if skillInfo.overrideTagId == nil then
		skillInfo.appliedOverrideTagId = nil

		AbilityUIUtils.setSkillDisplayName(btnRefInfo, skillInfo, name)
	end
end

function AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, iconUrl)
	if not skillInfo.enableLuaStateCache or not skillInfo.displayedSkillIconCached or skillInfo.displayedSkillIcon ~= iconUrl then
		skillInfo.displayedSkillIconCached = true
		skillInfo.displayedSkillIcon = iconUrl
		btnRefInfo.icon.url = iconUrl
	end
end

function AbilityUIUtils.setUIViewVisibleByCache(skillInfo, cacheKey, uiItem, visible)
	if not skillInfo.enableLuaStateCache or skillInfo[cacheKey] ~= visible then
		skillInfo[cacheKey] = visible

		LuaUIUtils.setUIViewVisible(uiItem, visible)
	end
end

function AbilityUIUtils.setGameObjectActiveByCache(skillInfo, cacheKey, gameObject, active)
	if not skillInfo.enableLuaStateCache or skillInfo[cacheKey] ~= active then
		skillInfo[cacheKey] = active

		gameObject:SetActiveEx(active)
	end
end

function AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, pageName, page)
	local pageCache = skillInfo.buttonPageCache

	if not pageCache then
		pageCache = {}
		skillInfo.buttonPageCache = pageCache
	end

	if not skillInfo.enableLuaStateCache or pageCache[pageName] ~= page then
		pageCache[pageName] = page

		btnRefInfo.button:TryChangePage(pageName, page)
	end
end

function AbilityUIUtils.getSkillBtnRefInfo(button, cacheBtnRefInfo)
	local objectReference = button:GetComponent("ObjectReference")
	local btnRefInfo = cacheBtnRefInfo or {}

	btnRefInfo.button = button
	btnRefInfo.objRef = objectReference

	local skillNameRoot = objectReference:GetRefValue("skillName")

	if skillNameRoot then
		btnRefInfo.skillNameRoot = skillNameRoot:GetComponent("UWidget")
	end

	btnRefInfo.skillName = objectReference:GetRefValue("txtNameUText")
	btnRefInfo.icon = objectReference:GetRefValue("iconUImage")
	btnRefInfo.keyBindingPro = objectReference:GetRefValue("keyBindingPro")
	btnRefInfo.pointListUContainer = objectReference:GetRefValue("pointListUContainer")
	btnRefInfo.countDown = objectReference:GetRefValue("cDUCountDown")
	btnRefInfo.maskMana = objectReference:GetRefValue("maskManaTransform")
	btnRefInfo.costRoot = objectReference:GetRefValue("costTransform")

	if NotNil(btnRefInfo.costRoot) then
		btnRefInfo.costNum = btnRefInfo.costRoot:Find("Num"):GetComponent("UBaseText")
	end

	btnRefInfo.itemNumber = objectReference:GetRefValue("itemNumber")
	btnRefInfo.switchSkillCountDown = objectReference:GetRefValue("countDownMultiSkillUCountDown")
	btnRefInfo.strengthenUContainer = objectReference:GetRefValue("vXStrengthenGlowUContainer")
	btnRefInfo.transUContainer = objectReference:GetRefValue("transUContainer")
	btnRefInfo.waterStorageUContainer = objectReference:GetRefValue("waterStorageUContainer")

	return btnRefInfo
end

function AbilityUIUtils.fillCombatSkillInfo(skillInfo, abilityType)
	local isControllongPet = Utils.isPet(pg.pawn)

	if isControllongPet then
		local pet = pg.me:getCurMainCombatPetEntity()

		AbilityUIUtils.fillPetSkillInfoByType(skillInfo, pet, abilityType)

		skillInfo.pawn = pet

		return
	end

	AbilityUIUtils.fillPlayerSkillInfBySkillType(skillInfo, abilityType)

	skillInfo.pawn = pg.me
	skillInfo.intensityData = nil
end

function AbilityUIUtils.fillExploreSkillInfo(skillInfo)
	local isControllongPet = Utils.isPet(pg.pawn)

	if not isControllongPet then
		AbilityUIUtils.fillPlayerSkillInfBySkillType(skillInfo, AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T)

		skillInfo.intensityData = nil
		skillInfo.pawn = pg.me
	else
		local pet = pg.me:getCurMainCombatPetEntity()

		AbilityUIUtils.fillPetSkillInfoByType(skillInfo, pet, AbilityConst.EXPLORE_ABILITY)

		skillInfo.pawn = pet
	end
end

function AbilityUIUtils.fillPlayerSkillInfBySkillType(skillInfo, skillType)
	local playerSkillInfo = pg.me:getSkillInfoBySkillType(skillType)
	local abilityId = playerSkillInfo and playerSkillInfo.abilityId

	if skillType == AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T then
		abilityId = ClientConst.BackSkillId
	end

	if abilityId then
		local abilityId = pg.me:getSwitchSkill(abilityId)

		AbilityUIUtils.resetEventSkillState(skillInfo, abilityId, pg.me)

		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		if pg.me:checkArkSceneState() and not lume.findInList(abilityParamData.stateCheckExclude, Const.ARK_STATE_NAME) then
			AbilityUIUtils.resetEventSkillState(skillInfo, AbilityConst.ABILITY_ID_EMPTY, pg.me)

			skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY

			return
		end

		skillInfo.abilityId = abilityId

		local attackType = abilityParamData.attackType
		local epCost = AbilityUtils.getAbilityParamEpCost(abilityParamData, pg.pawn)

		skillInfo.cost = epCost
		skillInfo.showCost = true
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
		skillInfo.skillIcon = abilityParamData.icon
		skillInfo.abilityParamData = abilityParamData
		skillInfo.abilityType = skillType

		local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(abilityId)

		if abilityTemplateData and abilityTemplateData.maxLoadedCnt then
			skillInfo.backListNum = abilityTemplateData.maxLoadedCnt
			skillInfo.loadingCd = abilityTemplateData.loadingCd
		else
			skillInfo.backListNum = nil
			skillInfo.loadingCd = nil
		end
	else
		AbilityUIUtils.resetEventSkillState(skillInfo, AbilityConst.ABILITY_ID_EMPTY, pg.me)

		skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY
	end
end

function AbilityUIUtils.fillPetSkillInfoByType(skillInfo, pet, abilityType)
	if not pet then
		AbilityUIUtils.resetEventSkillState(skillInfo, AbilityConst.ABILITY_ID_EMPTY, pet)

		skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY

		return
	end

	local abilityId = pet:getSkillIdByType(abilityType)

	AbilityUIUtils.fillSkillInfoByAbilityId(skillInfo, abilityId, pet)
end

function AbilityUIUtils.fillSkillInfoByAbilityId(skillInfo, abilityId, ent)
	if ToBool(abilityId) then
		AbilityUIUtils.resetEventSkillState(skillInfo, abilityId, ent)

		skillInfo.abilityId = abilityId

		local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(abilityId)
		local abilityType = abilityTemplateData.abilityType
		local abilityParamId = pg.global.abilityMgr:getAbilityParamId(abilityId)
		local abilityParamData = AbilityParamData[abilityParamId] or {}
		local attackType = abilityParamData.attackType
		local epCost = AbilityUtils.getAbilityParamEpCost(abilityParamData, ent)

		if epCost then
			skillInfo.cost = epCost
			skillInfo.showCost = true
		end

		if abilityType == AbilityConst.ULTIMATE_ABILITY then
			skillInfo.cost = AbilityUtils.getAbilityParamSpCost(abilityParamData, ent)
			skillInfo.showCost = false
		end

		local rogueEpCost = AbilityUtils.getRogueEpCost(abilityParamData, pg.me)

		if rogueEpCost then
			skillInfo.rogueEpCost = rogueEpCost
		else
			skillInfo.rogueEpCost = nil
		end

		skillInfo.elementType = abilityParamData.elementType
		skillInfo.name = abilityParamData.name

		if abilityParamData.tags and abilityParamData.tags[1] and SkillTagData[abilityParamData.tags[1]] then
			skillInfo.name = SkillTagData[abilityParamData.tags[1]].tagName
		end

		if pg.me and pg.me.space and pg.me.space.isTemple and pg.me.space:isTemple() then
			local replaceData = TempleSkillNameReplaceData[abilityParamId]

			if replaceData then
				skillInfo.name = replaceData.tagName
			end
		end

		skillInfo.abilityId = abilityId
		skillInfo.attackType = attackType
		skillInfo.abilityType = abilityType
		skillInfo.abilityParamData = abilityParamData

		local skillIcon = abilityTemplateData.overrideIcon and abilityTemplateData.overrideIcon or abilityParamData.icon

		skillInfo.skillIcon = skillIcon

		if abilityTemplateData and abilityTemplateData.maxLoadedCnt then
			skillInfo.backListNum = abilityTemplateData.maxLoadedCnt
			skillInfo.loadingCd = abilityTemplateData.loadingCd
		else
			skillInfo.backListNum = nil
			skillInfo.loadingCd = nil
		end
	else
		AbilityUIUtils.resetEventSkillState(skillInfo, AbilityConst.ABILITY_ID_EMPTY, ent)

		skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY
		skillInfo.backListNum = nil
		skillInfo.loadingCd = nil
	end
end

function AbilityUIUtils.fillMobileBtnExtraSkillInfo(skillInfo, skillWidget)
	skillInfo.useJoyStick = true
	skillInfo.skillJoyStick = skillWidget:Find("Btn/JoyStick"):GetComponent("UJoyStick")

	if NotNil(skillInfo.skillJoyStick) then
		skillInfo.skillJoyStick.gameObject:SetActiveEx(false)
	end

	skillInfo.parentComponent = skillWidget:GetComponent("UWidget")
end

function AbilityUIUtils.handleNormalAttackActionPerformed(uiComp)
	local player = pg.me

	if player == nil then
		return
	end

	if not pg.game.input.lockCursor and not pg.game.input:isUsingGamepad() and not pg.global.ui:runPlatformByMobile() then
		return
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.NormalAttack) then
		return
	end

	if pg.game.controller:isInControlMainPlayer() and player:checkPetUseGoSkill() then
		AbilityUIUtils.useGoSkill()

		return
	end

	if player:isControllingPet() and pg.pawn:BURROW_ST() and not pg.pawn:SKILL_ST() then
		pg.pawn:stopBurrow()

		return
	end

	if pg.me.inExploreState then
		return
	end

	if Utils.isSupportPet(pg.pawn) then
		player:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

		return
	end

	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	if ToBool(abilityId) then
		pg.game.controller.longPressMap[abilityId] = Time.secondCache

		if pg.game.controller:isInControlMainPlayer() and player.isUsePetSkillMode then
			AbilityUIUtils.useGoSkill()

			return
		end

		pg.game.controller:useSkill(abilityId, AbilityConst.WEAPON_NORMAL_ATK_ABILITY)
	end

	AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)

	uiComp.normalAttackLongPressTimer = uiComp:startTimer(function()
		AbilityUIUtils.onNormalAttackLongPress()
	end, 0)
end

function AbilityUIUtils.handleNormalAttackActionCanceled(uiComp)
	if pg.pawn and pg.pawn.combatTimelineRef.isNormalAttack and pg.pawn.combatTimelineRef.cnt > 0 then
		pg.pawn:stopChargeByAbilityId(pg.pawn.combatTimelineRef.abilityId)
	end

	AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)

	pg.game.controller.nextSkillAction.holdSkillId = 0

	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	if ToBool(abilityId) then
		pg.game.controller.longPressMap[abilityId] = nil
	end
end

function AbilityUIUtils.cancelNormalAttackLongPressCallback(uiComp)
	if uiComp.normalAttackLongPressTimer then
		uiComp:killTimer(uiComp.normalAttackLongPressTimer)
	end

	uiComp.normalAttackLongPressTimer = nil
end

function AbilityUIUtils.onNormalAttackLongPress()
	if not pg.game.input.lockCursor and not pg.game.input:isUsingGamepad() and not pg.global.ui:runPlatformByMobile() then
		return
	end

	if next(pg.game.controller.autoCastController.autoCastInfo) then
		return
	end

	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	if ToBool(abilityId) then
		pg.game.controller.nextSkillAction.holdSkillId = abilityId
	end
end

function AbilityUIUtils.useGoSkill()
	local player = pg.me

	if not player then
		return
	end

	local avatarData = AvatarData[player.templateId]

	if avatarData then
		local skillId = avatarData.GoAbilityId

		pg.game.controller:useSkill(skillId)
	end
end

function AbilityUIUtils.getAbilityMobileCastType(abilityId)
	local mobileCastType = 0

	if ToBool(abilityId) then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		mobileCastType = abilityParamData.mobileCastType

		if not mobileCastType then
			if AbilityUtils.isChargeAbility(abilityId) then
				mobileCastType = AbilityConst.MobileCastType.Charge
			else
				mobileCastType = AbilityConst.MobileCastType.Default
			end
		end
	end

	return mobileCastType
end

function AbilityUIUtils.setSkillBtnInfo(btnRefInfo, skillInfo)
	AbilityUIUtils.setSkillBtnBasicInfo(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
end

function AbilityUIUtils.setSkillBtnBasicInfo(btnRefInfo, skillInfo)
	local skillNameRoot = btnRefInfo.skillNameRoot

	if skillNameRoot then
		local hideSkillType = pg.game.setting:getHideSkillType() and true or false

		if not skillInfo.enableLuaStateCache or skillInfo.hideSkillType ~= hideSkillType then
			skillInfo.hideSkillType = hideSkillType
			skillNameRoot.visibility = hideSkillType and CS.XGUI.EVisibility.Hidden or CS.XGUI.EVisibility.Visible
		end
	end

	local keyBindingPro = btnRefInfo.keyBindingPro

	if skillInfo.overrideTagId then
		AbilityUIUtils.refreshSkillBtnTag(btnRefInfo, skillInfo)
	else
		AbilityUIUtils.setSkillDisplayName(btnRefInfo, skillInfo, skillInfo.name)
	end

	AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, skillInfo.skillIcon)

	if keyBindingPro and (not skillInfo.enableLuaStateCache or not skillInfo.actionPathCached or skillInfo.cachedActionPath ~= skillInfo.actionPath) then
		skillInfo.actionPathCached = true
		skillInfo.cachedActionPath = skillInfo.actionPath
		keyBindingPro.actionPath = skillInfo.actionPath
	end
end

function AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshCDState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshResistState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshLoadCntList(btnRefInfo, skillInfo)

	if skillInfo.isExploreSkill then
		AbilityUIUtils.refreshWaterStorage(btnRefInfo, skillInfo)
	end
end

function AbilityUIUtils.refreshCDState(btnRefInfo, skillInfo)
	local countDown = btnRefInfo.countDown

	if countDown then
		local countDownVisible = false
		local pawn = skillInfo.pawn or pg.pawn

		if skillInfo.abilityId and skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY then
			local ability = pawn:getAbility(skillInfo.abilityId)

			if ability and ability.cdEndTime then
				local endTime = ability.cdEndTime
				local timeNow = pawn:getGameTime()
				local freezeDuration = pawn.abilityFreezeMap[skillInfo.abilityId]
				local duration = freezeDuration or endTime - timeNow
				local cd = AbilityUtils.getAbilityParamCdForUI(skillInfo.abilityId, pawn)
				local totalDuration = math.max(duration, cd)
				local loadedInfo = pg.pawn.abilityLoadingMap[skillInfo.abilityId]

				if loadedInfo and loadedInfo.cnt and skillInfo.backListNum and loadedInfo.cnt ~= skillInfo.backListNum then
					totalDuration = skillInfo.loadingCd or 0
					duration = loadedInfo.lastTime + totalDuration - Time.secondCache
					duration = math.max(0, duration)
				end

				local inFinalSkillRepress = false

				if skillInfo.isFinalSkill then
					inFinalSkillRepress = AbilityUIUtils.inSwitchSkillWindow(pawn, skillInfo.abilityId)
				end

				if not inFinalSkillRepress and (duration > UIConst.CD_LIMIT or freezeDuration) then
					countDownVisible = true

					local ownerId = AbilityUIUtils.getSkillOwnerId(pawn)

					if not skillInfo.enableLuaStateCache or skillInfo.cdOwnerId ~= ownerId or skillInfo.cdAbilityId ~= skillInfo.abilityId or skillInfo.cdEndTime ~= endTime or skillInfo.cdFreezeDuration ~= freezeDuration or skillInfo.cdTotalDuration ~= totalDuration or skillInfo.cdLoadedCnt ~= (loadedInfo and loadedInfo.cnt) or skillInfo.cdLoadedLastTime ~= (loadedInfo and loadedInfo.lastTime) then
						skillInfo.cdOwnerId = ownerId
						skillInfo.cdAbilityId = skillInfo.abilityId
						skillInfo.cdEndTime = endTime
						skillInfo.cdFreezeDuration = freezeDuration
						skillInfo.cdTotalDuration = totalDuration
						skillInfo.cdLoadedCnt = loadedInfo and loadedInfo.cnt
						skillInfo.cdLoadedLastTime = loadedInfo and loadedInfo.lastTime

						countDown:Play(duration, totalDuration)

						if freezeDuration then
							countDown:Stop()
						end
					end
				end

				if not skillInfo.enableLuaStateCache or not skillInfo.countDownCallbackRegistered then
					skillInfo.countDownCallbackRegistered = true

					function countDown.luaFinished()
						skillInfo.countDownVisible = false
						skillInfo.cdEndTime = nil

						LuaUIUtils.setUIViewVisible(countDown, false)
						AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
						btnRefInfo.button:InvokeCallback(CS.XGUI.EInvokeTime.User3)
					end
				end
			end
		end

		if not countDownVisible then
			skillInfo.cdEndTime = nil
		end

		AbilityUIUtils.setUIViewVisibleByCache(skillInfo, "countDownVisible", countDown, countDownVisible)
	end
end

function AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo, isItemCountChange)
	if skillInfo.isFinalSkill then
		return AbilityUIUtils.refreshFinalSkillCostState(btnRefInfo, skillInfo)
	else
		AbilityUIUtils.refreshNormalCostState(btnRefInfo, skillInfo, isItemCountChange)
	end
end

function AbilityUIUtils.refreshFinalSkillCostState(btnRefInfo, skillInfo)
	local button = btnRefInfo.button
	local pawn = skillInfo.pawn or pg.pawn
	local skillValid, costValid, cdValid = AbilityUIUtils.isSkillVaild(skillInfo)
	local isBuffForbidAbility = pg.pawn and pg.pawn.isBuffForbidAbility
	local pageNum = isBuffForbidAbility and 0 or AbilityUIUtils.getFinalSkillBigSkillPage(skillInfo, skillValid)
	local alphaPageName = "Ready"

	button:TryChangePage("Ready", 1)

	if not costValid or not cdValid then
		alphaPageName = "NotReady"
	end

	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "BigSkill", pageNum)
	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "Alpha", alphaPageName)

	local curSp = pawn.actorCombatAttribute:getSp()
	local energyCount = 0

	if curSp >= 300 then
		energyCount = 3
	elseif curSp >= 200 then
		energyCount = 2
	elseif curSp >= 100 then
		energyCount = 1
	end

	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "EnergyCount", energyCount)
	AbilityUIUtils.refreshFinalSkillDisplayState(btnRefInfo, skillInfo)

	return skillValid, costValid, cdValid
end

function AbilityUIUtils.refreshNormalCostState(btnRefInfo, skillInfo, isItemCountChange)
	local button = btnRefInfo.button
	local maskMana = btnRefInfo.maskMana
	local costRoot = btnRefInfo.costRoot

	if skillInfo.ignoreValidation then
		button:TryChangePage("Ready", 1)

		if NotNil(costRoot) then
			AbilityUIUtils.setUIViewVisibleByCache(skillInfo, "costVisible", costRoot, false)
		end

		return
	end

	local curAbilityData = skillInfo
	local pawn = skillInfo.pawn or pg.pawn
	local abilityMap = pawn.abilityMap or {}
	local abilityInfo = abilityMap[skillInfo.abilityId]
	local switchInfo = pawn.abilitySwitchInfo[skillInfo.abilityId]
	local curAbilityId = switchInfo and switchInfo[1] or skillInfo.abilityId

	if switchInfo then
		local toAbilityId = switchInfo[1]
		local isChange = switchInfo[2]

		if isChange and toAbilityId then
			curAbilityData = LuaUIUtils.getSkillInfByAbilityId(toAbilityId)
			abilityInfo = abilityMap[toAbilityId]
		end
	end

	local enough = true
	local abilityCost = curAbilityData.cost
	local abilityParamData = curAbilityData.abilityParamData or {}

	if abilityInfo then
		local curAbilityCost = abilityInfo:getCurEpCost(pawn)

		if curAbilityCost then
			local curEnergy = ClientUtils.getSkillEnergyByType(curAbilityData)

			enough = curAbilityCost <= curEnergy
			abilityCost = curAbilityCost
		end

		local rogueEpCost = AbilityUtils.getRogueEpCost(abilityParamData, pg.me)

		if rogueEpCost and rogueEpCost > AbilityUtils.getRogueEp(pg.me) then
			enough = false
		end
	end

	local itemCostValid = true
	local itemNumber = btnRefInfo.itemNumber

	if abilityParamData.costItemId then
		local cnt = ItemUtils.getItemCountById(pg.me, abilityParamData.costItemId, true)

		itemCostValid = cnt >= abilityParamData.costItemCnt

		if itemNumber then
			local isContainerLoaded = itemNumber:CheckURLLoaded()

			AbilityUIUtils.setGameObjectActiveByCache(skillInfo, "itemNumberVisible", itemNumber.gameObject, true)

			if isContainerLoaded then
				local contentObjRef = itemNumber.content:GetComponent("ObjectReference")
				local numUSDFText = contentObjRef:GetRefValue("numUSDFText")
				local vXRefreshUContainer = contentObjRef:GetRefValue("vXRefreshUContainer")

				if isItemCountChange then
					vXRefreshUContainer.gameObject:SetActiveEx(false)
					vXRefreshUContainer.gameObject:SetActiveEx(true)
				else
					vXRefreshUContainer.gameObject:SetActiveEx(false)
				end

				local costNum = math.min(cnt, 99)

				ClientTextUtils.setText(numUSDFText, costNum)
				itemNumber.content:TryChangePage("Item", itemCostValid and 0 or 1)
			else
				itemNumber:LoadDefaultUrlManually(function()
					local contentObjRef = itemNumber.content:GetComponent("ObjectReference")
					local numUSDFText = contentObjRef:GetRefValue("numUSDFText")
					local costNum = math.min(cnt, 99)

					ClientTextUtils.setText(numUSDFText, costNum)
					itemNumber.content:TryChangePage("Item", itemCostValid and 0 or 1)
				end)
			end
		end
	elseif itemNumber then
		AbilityUIUtils.setGameObjectActiveByCache(skillInfo, "itemNumberVisible", itemNumber.gameObject, false)
	end

	if NotNil(costRoot) then
		local costVisible = curAbilityData.showCost and abilityCost and abilityCost > 0 or false

		if costVisible then
			local costNum = btnRefInfo.costNum
			local costText = UIStringPool.getTwoDigitText(abilityCost)

			if not skillInfo.enableLuaStateCache or skillInfo.costText ~= costText then
				skillInfo.costText = costText

				ClientTextUtils.setText(costNum, costText)
			end
		end

		AbilityUIUtils.setUIViewVisibleByCache(skillInfo, "costVisible", costRoot, costVisible)
	end

	local cdValid = true

	if abilityInfo and abilityInfo.cdEndTime then
		local endTime = abilityInfo.cdEndTime
		local timeNow = pawn:getGameTime()
		local duration = endTime - timeNow

		cdValid = duration < UIConst.CD_LIMIT and not pawn.abilityFreezeMap[abilityInfo.abilityId]
	end

	local stateValid = true

	if not skillInfo.isNormalAttack then
		stateValid = not pawn.isBuffForbidAbility
	end

	stateValid = stateValid and pawn:checkCharacterStateCastAbilityValid(curAbilityId)

	if pawn:SPECIAL_ATTACK_ST() then
		stateValid = false
	end

	if maskMana then
		local showMask = not enough or not stateValid

		AbilityUIUtils.setUIViewVisibleByCache(skillInfo, "maskManaVisible", maskMana, showMask)
	end

	local forceGrayState = pawn.space and Utils.isSpaceRogueDungeon(pawn.space.spaceType) and not pawn:isInCombat() and not AbilityUtils.isNormalAttack(skillInfo.abilityId)

	if forceGrayState then
		button:TryChangePage("Ready", 0)
	elseif not itemCostValid or not stateValid then
		button:TryChangePage("Ready", 2)
	elseif enough and cdValid then
		if skillInfo.backListNum then
			AbilityUIUtils.refreshBackListState(pawn, button, skillInfo)
		else
			button:TryChangePage("Ready", 1)
		end
	elseif skillInfo.backListNum then
		AbilityUIUtils.refreshBackListState(pawn, button, skillInfo)
	else
		button:TryChangePage("Ready", 0)
	end
end

function AbilityUIUtils.getResistInfo()
	return LuaUIUtils.isResistInfoVisible()
end

function AbilityUIUtils.refreshResistState(buttonOrRefInfo, skillInfo)
	local btnRefInfo = buttonOrRefInfo.button and buttonOrRefInfo or nil
	local button = btnRefInfo and btnRefInfo.button or buttonOrRefInfo
	local visible = skillInfo.resistVisible
	local targetEntity = skillInfo.resistTargetEntity

	if visible == nil then
		visible, targetEntity = AbilityUIUtils.getResistInfo()

		if skillInfo.enableLuaStateCache then
			skillInfo.resistVisible = visible
			skillInfo.resistTargetEntity = targetEntity
		end
	end

	local resistPage = 1

	if not visible then
		-- block empty
	elseif skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillInfo.abilityId)

		if not abilityParamData or abilityParamData.skillType ~= Const.SkillType.Explore then
			local skillElementType = skillInfo.elementType
			local damageShowEnum = Utils.getElementAgainstShowEnum(skillElementType, targetEntity.elementTypes)

			if damageShowEnum == Const.DAMAGE_SHOW_ENUM_EXCELLENT then
				resistPage = 2
			elseif damageShowEnum == Const.DAMAGE_SHOW_ENUM_WEAK or damageShowEnum == Const.DAMAGE_SHOW_ENUM_USELESS then
				resistPage = 0
			end
		end
	end

	if not skillInfo.enableLuaStateCache or skillInfo.resistPage ~= resistPage then
		button:TryChangePage("Resist", resistPage)

		skillInfo.resistPage = resistPage
	end
end

function AbilityUIUtils.isSwitchSkillFreezing(pawn, abilityId)
	local freezeTimeMap = pawn and pawn.switchSkillFreezeTimeMap
	local freezeTime = freezeTimeMap and freezeTimeMap[abilityId]

	if ToBool(freezeTime) then
		return freezeTime
	end

	return nil
end

function AbilityUIUtils.inSwitchSkillWindow(pawn, abilityId)
	local switchInfo = pawn and pawn.abilitySwitchInfo and pawn.abilitySwitchInfo[abilityId]

	if not switchInfo or not switchInfo[2] or not switchInfo[3] then
		return false
	end

	local nowTime = AbilityUIUtils.isSwitchSkillFreezing(pawn, abilityId) or pawn:getGameTime()

	return nowTime < switchInfo[3]
end

function AbilityUIUtils.isInCombo(data)
	if data == nil or data.abilityId == nil then
		return false
	end

	local pawn = data.pawn or pg.pawn

	if not pawn or not pawn.abilitySwitchInfo then
		return false
	end

	return AbilityUIUtils.inSwitchSkillWindow(pawn, data.abilityId)
end

function AbilityUIUtils.isSkillVaild(data)
	if not data or not data.abilityId then
		return false, false, false
	end

	local pawn = data.pawn or pg.pawn

	if not pawn or not pawn.abilityMap then
		return false, false, false
	end

	local abilityMap = pawn.abilityMap
	local costValid = true
	local cdValid = true
	local abilityInfo = abilityMap[data.abilityId]

	if data.abilityId and data.abilityId > 0 then
		costValid = pawn:checkAbilityCost(data.abilityId)
	else
		costValid = false
	end

	if data.rogueEpCost then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(data.abilityId)

		if abilityParamData then
			local realRogueEpCost = AbilityUtils.getRogueEpCost(abilityParamData, pg.me)

			if realRogueEpCost and realRogueEpCost > AbilityUtils.getRogueEp(pg.me) then
				costValid = false
			end
		end
	end

	if abilityInfo and abilityInfo.cdEndTime then
		local endTime = abilityInfo.cdEndTime
		local timeNow = pawn:getGameTime()
		local duration = pawn.abilityFreezeMap[data.abilityId] or endTime - timeNow

		cdValid = duration < UIConst.CD_LIMIT

		if AbilityUIUtils.inSwitchSkillWindow(pawn, data.abilityId) then
			cdValid = true
		end
	end

	return costValid and cdValid, costValid, cdValid
end

function AbilityUIUtils.getFinalSkillBigSkillPage(data, skillValid)
	if skillValid == nil then
		skillValid = AbilityUIUtils.isSkillVaild(data)
	end

	local isInCombo = AbilityUIUtils.isInCombo(data)

	if isInCombo then
		return 2
	elseif skillValid then
		return 1
	else
		return 0
	end
end

function AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo, skillValid)
	local button = btnRefInfo.button

	if skillInfo.isFloatingState then
		AbilityUIUtils.setSkillDisplayName(btnRefInfo, skillInfo, skillInfo.btnText)
		AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, skillInfo.btnIcon)

		return
	end

	local countDown = btnRefInfo.switchSkillCountDown
	local switchState = 0

	if skillValid == nil then
		skillValid = AbilityUIUtils.isSkillVaild(skillInfo)
	end

	local bigSkillState = skillValid and 1 or 0

	if skillInfo.abilityId then
		local pawn = skillInfo.pawn or pg.pawn
		local timeNow = pawn:getGameTime()
		local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(skillInfo.abilityId)
		local isSwitchAbility = abilityTemplate and (abilityTemplate.isSwitch or abilityTemplate.canRepress)
		local switchSkillType = isSwitchAbility and 1 or 0

		if countDown and (not skillInfo.enableLuaStateCache or skillInfo.switchSkillType ~= switchSkillType) then
			skillInfo.switchSkillType = switchSkillType

			countDown:TryChangePage("Type", switchSkillType)
		end

		local switchInfo = pawn.abilitySwitchInfo[skillInfo.abilityId]

		if switchInfo then
			local toAbilityId = switchInfo[1]
			local isChange = switchInfo[2]
			local endTime = switchInfo[3] or 0
			local totalTime = switchInfo[4] or 0
			local isSwitchFreezing = AbilityUIUtils.isSwitchSkillFreezing(pawn, skillInfo.abilityId)
			local duration = endTime - (isSwitchFreezing or timeNow)

			if isChange then
				if toAbilityId then
					local switchedSkillInfo = LuaUIUtils.getSkillInfByAbilityId(toAbilityId)

					AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, AbilityUIUtils.getSkillSwitchIcon(pawn, toAbilityId, switchedSkillInfo.skillIcon))
					AbilityUIUtils.setSkillNameWithoutOverride(btnRefInfo, skillInfo, switchedSkillInfo.name)
				end

				if duration > UIConst.CD_LIMIT then
					switchState = 1
					bigSkillState = 2

					if countDown then
						countDown:Play(duration, totalTime)

						if isSwitchFreezing then
							countDown:Stop()
						end
					end
				end
			else
				AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, AbilityUIUtils.getSkillSwitchIcon(pawn, skillInfo.abilityId, skillInfo.skillIcon))
				AbilityUIUtils.setSkillNameWithoutOverride(btnRefInfo, skillInfo, skillInfo.name)
			end
		else
			AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, AbilityUIUtils.getSkillSwitchIcon(pawn, skillInfo.abilityId, skillInfo.skillIcon))
			AbilityUIUtils.setSkillNameWithoutOverride(btnRefInfo, skillInfo, skillInfo.name)
		end

		local countDownChangeInfo = pawn.abilityCountDownInfo[skillInfo.abilityId]

		if not switchInfo and countDownChangeInfo then
			local isChange = countDownChangeInfo[1]
			local endTime = countDownChangeInfo[2]
			local duration = endTime - timeNow
			local totalTime = countDownChangeInfo[3] or 0

			if isChange and duration > UIConst.CD_LIMIT then
				switchState = 1
				bigSkillState = 2

				if countDown then
					countDown:Play(duration, totalTime)
				end
			end
		end
	end

	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "Change", switchState)

	local isBuffForbidAbility = pg.pawn and pg.pawn.isBuffForbidAbility

	bigSkillState = isBuffForbidAbility and 0 or bigSkillState

	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "BigSkill", bigSkillState)

	if switchState == 1 then
		button:InvokeCallback(CS.XGUI.EInvokeTime.User3)
	end

	if skillInfo.isFinalSkill then
		AbilityUIUtils.refreshBigSkillCost(btnRefInfo, skillInfo)
	end
end

function AbilityUIUtils.getSkillSwitchIcon(ent, abilityId, icon)
	if ent.switchSkillIconData and ent.switchSkillIconData[abilityId] ~= nil then
		if ent.switchSkillIconData[abilityId] == false then
			return icon
		else
			return ent.switchSkillIconData[abilityId]
		end
	end

	return icon
end

function AbilityUIUtils.refreshBigSkillCost(btnRefInfo, data)
	if not data.bigSkillCostRefsInitialized then
		local objectReference = btnRefInfo.objRef or btnRefInfo.button:GetComponent("ObjectReference")

		if objectReference then
			data.usedTimesUWidget = objectReference:GetRefValue("usedTimesUWidget")
			data.numUSDFText = objectReference:GetRefValue("numUSDFText")
			data.bigSkillCostRefsInitialized = data.usedTimesUWidget ~= nil and data.numUSDFText ~= nil
		end
	end

	local usedTimesUWidget = data.usedTimesUWidget
	local numUSDFText = data.numUSDFText

	if usedTimesUWidget and numUSDFText then
		local pawn = data.pawn or pg.pawn
		local ability = pawn:getAbility(data.abilityId)

		if ability then
			local spCost = ability.spCost or 0
			local count = math.floor(spCost / 100)
			local usedTimesVisible = count > 1

			if not data.enableLuaStateCache or data.usedTimesVisible ~= usedTimesVisible then
				data.usedTimesVisible = usedTimesVisible

				usedTimesUWidget.gameObject:SetActiveEx(usedTimesVisible)
			end

			if not data.enableLuaStateCache or data.bigSkillCostCount ~= count then
				data.bigSkillCostCount = count

				ClientTextUtils.setText(numUSDFText, count)
			end
		elseif not data.enableLuaStateCache or data.usedTimesVisible ~= false then
			data.usedTimesVisible = false

			usedTimesUWidget.gameObject:SetActiveEx(false)
		end
	end
end

function AbilityUIUtils.refreshBackListState(pawn, button, data)
	local abilityId = data.abilityId
	local loadedInfo = pawn.abilityLoadingMap[abilityId]
	local loadedCnt = loadedInfo and loadedInfo.cnt or 0
	local hasLoadedCnt = loadedCnt > 0
	local isReady = hasLoadedCnt

	if abilityId == AbilityConst.BACK_SKILL_ID and not pg.me:isInCombat() then
		isReady = false
	end

	button:TryChangePage("Ready", isReady and 1 or 0)
	button:TryChangePage("Charging", hasLoadedCnt and 0 or 1)
end

function AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)
	local button = btnRefInfo.button
	local intensityData = skillInfo and skillInfo.intensityData
	local intensityStyle = 0
	local intensityTagId

	if intensityData and ((intensityData.endTime or 0) <= 0 or intensityData.endTime > Time.realSecondCache) and intensityData.isOpen and intensityData.intensityStyle then
		intensityStyle = intensityData.intensityStyle
		intensityTagId = intensityData.tagId

		if (skillInfo.isNormalAttack or skillInfo.isFinalSkill) and intensityStyle == AbilityConst.IntensitySkillTyle.ReduceEpCost then
			intensityStyle = 1
		end
	end

	if not skillInfo.enableLuaStateCache or skillInfo.cachedIntensityStyle ~= intensityStyle then
		button:TryChangePage("Strengthen", intensityStyle)

		skillInfo.cachedIntensityStyle = intensityStyle
	end

	if intensityStyle ~= 0 then
		local elementInfo = ElementPropData[skillInfo.elementType or 0]

		if elementInfo then
			local elementName = elementInfo.name or ""

			if not skillInfo.enableLuaStateCache or skillInfo.cachedIntensityElementName ~= elementName then
				button:TryChangePage("type", elementName)

				skillInfo.cachedIntensityElementName = elementName
			end
		end

		local vXStrengthenGlowUContainer = btnRefInfo.strengthenUContainer

		if vXStrengthenGlowUContainer and not skillInfo.strengthenContainerLoaded and not skillInfo.strengthenContainerLoading then
			if vXStrengthenGlowUContainer:CheckURLLoaded() then
				skillInfo.strengthenContainerLoaded = true
			else
				skillInfo.strengthenContainerLoading = true

				vXStrengthenGlowUContainer:LoadDefaultUrlManually(function()
					skillInfo.strengthenContainerLoading = nil
					skillInfo.strengthenContainerLoaded = true
				end)
			end
		end

		if intensityData.intensityStyle == AbilityConst.IntensitySkillTyle.Tag and (not skillInfo.enableLuaStateCache or skillInfo.cachedIntensityTagId ~= intensityTagId) then
			local tagData = SkillTagData[intensityTagId]

			if tagData then
				local transUContainer = btnRefInfo.transUContainer

				AbilityUIUtils.refreshSkillTags(transUContainer, tagData)
			end

			skillInfo.cachedIntensityTagId = intensityTagId
		end
	else
		skillInfo.cachedIntensityElementName = nil
		skillInfo.cachedIntensityTagId = nil
	end
end

function AbilityUIUtils.refreshSkillTags(transUContainer, tagData)
	local function renderTag()
		local objectReference = transUContainer.content:GetComponent("ObjectReference")
		local txtTransUBaseText = objectReference:GetRefValue("txtTransUBaseText")

		ClientTextUtils.setText(txtTransUBaseText, pg.getLocalizationText(tagData.tagName))
	end

	local transUContainerLoaded = transUContainer:CheckURLLoaded()

	if transUContainerLoaded then
		renderTag()
	else
		transUContainer:LoadDefaultUrlManually(function(uwi)
			renderTag()
		end)
	end
end

function AbilityUIUtils.refreshSkillBtnTag(btnRefInfo, skillInfo)
	local overrideTagId = skillInfo.overrideTagId

	if skillInfo.enableLuaStateCache and skillInfo.appliedOverrideTagId == overrideTagId then
		return
	end

	local tagData = overrideTagId and SkillTagData[overrideTagId]

	if tagData then
		AbilityUIUtils.setSkillDisplayName(btnRefInfo, skillInfo, tagData.tagName)

		skillInfo.appliedOverrideTagId = overrideTagId
	end
end

function AbilityUIUtils.refreshLoadCntList(btnRefInfo, skillInfo)
	local pointListUContainer = btnRefInfo.pointListUContainer

	if pointListUContainer == nil then
		return
	end

	local backListNum = skillInfo.backListNum
	local needShow = backListNum and backListNum > 1 or false

	if not skillInfo.enableLuaStateCache or skillInfo.loadCntVisible ~= needShow then
		skillInfo.loadCntVisible = needShow

		pointListUContainer.gameObject:SetActiveEx(needShow)
	end

	if not needShow then
		skillInfo.loadCntAbilityId = nil
		skillInfo.loadCntMax = nil
		skillInfo.loadCntValue = nil

		return
	end

	local abilityData = pg.me.abilityLoadingMap[skillInfo.abilityId] or pg.pawn.abilityLoadingMap[skillInfo.abilityId]
	local loadedCnt = abilityData and abilityData.cnt or 0
	local sameLoadSkill = skillInfo.loadCntAbilityId == skillInfo.abilityId and skillInfo.loadCntMax == backListNum
	local oldLoadedCnt = skillInfo.loadCntValue

	if skillInfo.enableLuaStateCache and sameLoadSkill and skillInfo.loadCntValue == loadedCnt then
		return
	end

	skillInfo.loadCntAbilityId = skillInfo.abilityId
	skillInfo.loadCntMax = backListNum
	skillInfo.loadCntValue = loadedCnt

	local pointListUContainerLoaded = pointListUContainer:CheckURLLoaded()

	if pointListUContainerLoaded then
		local res, btn

		for i = 1, backListNum do
			res, btn = pointListUContainer.content:TryGetChildAt(i - 1)

			if res and (not skillInfo.enableLuaStateCache or not sameLoadSkill or oldLoadedCnt == nil or i <= oldLoadedCnt ~= (i <= loadedCnt)) then
				btn:SetSelected(i <= loadedCnt)
			end
		end
	elseif not skillInfo.loadCntLoading then
		skillInfo.loadCntLoading = true

		pointListUContainer:LoadDefaultUrlManually(function(uwi)
			skillInfo.loadCntLoading = nil

			local temp = {}
			local currentBackListNum = skillInfo.backListNum
			local currentAbilityId = skillInfo.abilityId

			if currentBackListNum and currentBackListNum > 1 then
				for i = 1, currentBackListNum do
					temp[i] = {
						abilityId = currentAbilityId
					}
				end
			end

			function uwi.luaRenderItem(button, index, data)
				local curAbilityData = pg.me.abilityLoadingMap[data.abilityId] or pg.pawn.abilityLoadingMap[data.abilityId]
				local curLoadedCnt = curAbilityData and curAbilityData.cnt or 0

				button:SetSelected(index < curLoadedCnt)
			end

			uwi:SetList(temp)
		end)
	end
end

function AbilityUIUtils.refreshWaterStorage(btnRefInfo, skillInfo)
	local waterStorageUContainer = btnRefInfo.waterStorageUContainer

	if waterStorageUContainer == nil then
		return
	end

	local pawn = skillInfo.pawn
	local ownerId = AbilityUIUtils.getSkillOwnerId(pawn)

	if not skillInfo.enableLuaStateCache or not skillInfo.waterStorageStateCached or skillInfo.waterStorageAbilityId ~= skillInfo.abilityId or skillInfo.waterStorageOwnerId ~= ownerId then
		skillInfo.waterStorageStateCached = true
		skillInfo.waterStorageAbilityId = skillInfo.abilityId
		skillInfo.waterStorageOwnerId = ownerId
		skillInfo.isWaterExploreSkill = pawn and pawn.isMainPet and AbilityUtils.isUseWaterExploreAbility(pawn, skillInfo.abilityId) or false
	end

	local needShow = skillInfo.isWaterExploreSkill and true or false

	if not skillInfo.enableLuaStateCache or skillInfo.waterStorageVisible ~= needShow then
		skillInfo.waterStorageVisible = needShow

		waterStorageUContainer.gameObject:SetActiveEx(needShow)
	end

	local iconVisible = not needShow

	if btnRefInfo.icon and (not skillInfo.enableLuaStateCache or skillInfo.waterStorageIconVisible ~= iconVisible) then
		skillInfo.waterStorageIconVisible = iconVisible

		LuaUIUtils.setUIViewVisible(btnRefInfo.icon, iconVisible)
	end

	if not needShow then
		return
	end

	local waterStorageUContainerLoaded = waterStorageUContainer:CheckURLLoaded()

	if waterStorageUContainerLoaded then
		local entity = pawn
		local waterConfigData = entity:getWaterConfigData()
		local costVal = waterConfigData.costVal
		local curWaterVal = entity:getCurWaterVal()

		if not skillInfo.enableLuaStateCache or skillInfo.waterCostVal ~= costVal then
			skillInfo.waterCostVal = costVal

			ClientTextUtils.setText(skillInfo.waterNum, waterConfigData.costVal)
		end

		if not skillInfo.enableLuaStateCache or skillInfo.waterValue ~= curWaterVal or skillInfo.waterValueCost ~= costVal then
			skillInfo.waterValue = curWaterVal
			skillInfo.waterValueCost = costVal
			skillInfo.waterSlider.value = curWaterVal / costVal
		end
	elseif not skillInfo.waterStorageLoading then
		skillInfo.waterStorageLoading = true

		waterStorageUContainer:LoadDefaultUrlManually(function()
			skillInfo.waterStorageLoading = nil

			local objectReference = waterStorageUContainer.content:GetComponent("ObjectReference")

			skillInfo.waterNum = objectReference:GetRefValue("numUSDFText")
			skillInfo.waterSlider = objectReference:GetRefValue("sliderUSlider")

			AbilityUIUtils.refreshWaterStorage(btnRefInfo, skillInfo)
		end)
	end
end

function AbilityUIUtils.refreshAbilityGrayState(btnRefInfo, skillInfo)
	local player = pg.pawn

	if player.space and Utils.isSpaceRogueDungeon(player.space.spaceType) and not player:isInCombat() and not AbilityUtils.isNormalAttack(skillInfo.abilityId) then
		local button = btnRefInfo.button

		button:TryChangePage("Ready", 0)
		AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "BigSkill", 0)

		if skillInfo.isFinalSkill then
			AbilityUIUtils.refreshFinalSkillDisplayState(btnRefInfo, skillInfo)
		end
	else
		AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
	end
end

function AbilityUIUtils.setFinalSkillBtnInfo(btnRefInfo, skillInfo, skipCD)
	local keyBindingPro = btnRefInfo.keyBindingPro
	local keyBoardContent = keyBindingPro.keyBoardContent

	if keyBoardContent then
		local isMobileInteract = pg.global.ui.uiMgr:CheckIsMobileInteract()
		local keyBoardVisible = not isMobileInteract and skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY

		if not skillInfo.enableLuaStateCache or skillInfo.keyBoardVisible ~= keyBoardVisible then
			skillInfo.keyBoardVisible = keyBoardVisible

			keyBoardContent.gameObject:SetActiveEx(keyBoardVisible)
		end
	end

	AbilityUIUtils.setSkillBtnBasicInfo(btnRefInfo, skillInfo)

	return AbilityUIUtils.refreshFinalSkillState(btnRefInfo, skillInfo, skipCD)
end

function AbilityUIUtils.refreshFinalSkillState(btnRefInfo, skillInfo, skipCD)
	if not skipCD then
		AbilityUIUtils.refreshCDState(btnRefInfo, skillInfo)
	end

	local skillValid, costValid, cdValid = AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)

	AbilityUIUtils.refreshResistState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo, skillValid)
	AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)

	local elementInfo = ElementPropData[skillInfo.elementType or 0]
	local button = btnRefInfo.button
	local elementName = elementInfo and elementInfo.name or "null"

	button:TryChangePage("type", elementName)
	AbilityUIUtils.refreshFinalSkillBtnBar(btnRefInfo, skillInfo)

	return skillValid, costValid, cdValid
end

function AbilityUIUtils.refreshFinalSkillBtnBar(btnRefInfo, skillInfo)
	local curSp = pg.pawn.actorCombatAttribute:getSp()
	local canShowGlowTip = skillInfo.abilityId and skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY
	local hasUltimatePet = false

	if canShowGlowTip then
		local ability = pg.pawn:getAbility(skillInfo.abilityId)

		if ability then
			canShowGlowTip = curSp >= (ability.spCost or 0)
		end
	end

	for i = 1, 3 do
		AbilityUIUtils.refreshFinalSkillBtnBarInternal(btnRefInfo, skillInfo, i, curSp, canShowGlowTip, hasUltimatePet)
	end
end

function AbilityUIUtils.refreshFinalSkillBtnBarInternal(btnRefInfo, skillInfo, index, curSp, canShowGlowTip, hasUltimatePet)
	local barSpStart = (index - 1) * 100
	local finalSkillBarRefs = skillInfo.finalSkillBarRefs

	if not finalSkillBarRefs then
		finalSkillBarRefs = {}
		skillInfo.finalSkillBarRefs = finalSkillBarRefs
	end

	local barRefInfo = finalSkillBarRefs[index]

	if not barRefInfo then
		local energyRateBarObjRef = btnRefInfo.objRef:GetRefValue(UIStringPool.getHudFinalSkillBarName(index))

		if not energyRateBarObjRef then
			return
		end

		barRefInfo = {
			slider = energyRateBarObjRef:GetRefValue("sliderUSlider"),
			energyRateBarUComponent = energyRateBarObjRef:GetRefValue("energyRateBarUComponent"),
			handleUImage = energyRateBarObjRef:GetRefValue("handleUImage")
		}
		finalSkillBarRefs[index] = barRefInfo
	end

	local energyRateBarObjRef = barRefInfo

	if energyRateBarObjRef then
		local sliderValue = 0

		if barSpStart < curSp then
			sliderValue = (curSp - barSpStart) / 100

			if sliderValue > 1 then
				sliderValue = 1
			end
		end

		local slider = barRefInfo.slider
		local energyRateBarUComponent = barRefInfo.energyRateBarUComponent
		local handleUImage = barRefInfo.handleUImage

		if not barRefInfo.sliderInitialized then
			barRefInfo.sliderInitialized = true
			slider.maxValue = 1
		end

		if not skillInfo.enableLuaStateCache or barRefInfo.sliderValue ~= sliderValue then
			barRefInfo.sliderValue = sliderValue
			slider.value = sliderValue
		end

		local sliderHandleVisible = sliderValue >= 0.1 and sliderValue < 1

		if not skillInfo.enableLuaStateCache or barRefInfo.sliderHandleVisible ~= sliderHandleVisible then
			barRefInfo.sliderHandleVisible = sliderHandleVisible

			LuaUIUtils.setUIViewVisible(handleUImage, sliderHandleVisible)
		end

		local bigSkillLitePage

		bigSkillLitePage = sliderValue >= 1 and canShowGlowTip and 2 or sliderValue >= 1 and hasUltimatePet and 3 or 0

		if not skillInfo.enableLuaStateCache or barRefInfo.bigSkillLitePage ~= bigSkillLitePage then
			barRefInfo.bigSkillLitePage = bigSkillLitePage

			energyRateBarUComponent:TryChangePage("BigSkillLite", bigSkillLitePage)
		end
	end
end

function AbilityUIUtils.refreshFinalSkillDisplayState(btnRefInfo, skillInfo)
	local isEmpty, isDisable = AbilityUIUtils.checkFinalSkillEmptyState(skillInfo)

	btnRefInfo.button:TryChangePage("EmptyState", isEmpty and 1 or 0)

	if isDisable then
		btnRefInfo.button:TryChangePage("Ready", 2)
	end
end

function AbilityUIUtils.checkFinalSkillEmptyState(data)
	if not data then
		return true
	end

	if data.abilityId == AbilityConst.ABILITY_ID_EMPTY then
		return true
	end

	if not pg.pawn then
		return true
	end

	local pawnState = pg.pawn.characterState
	local isFlying = pawnState and CharacterStateConst.isChildOfState(pawnState, CharacterStateConst.FLYING)

	if isFlying then
		if pg.me:isControllingExplorePet() then
			return true
		end

		if not ToBool(data.abilityId) or pg.pawn.checkCharacterStateCastAbilityValid and not pg.pawn:checkCharacterStateCastAbilityValid(data.abilityId) then
			return false, true
		end
	end

	local isGliding = pawnState and CharacterStateConst.isChildOfState(pawnState, CharacterStateConst.GLIDING)

	if isGliding then
		return false, true
	end

	return false
end

function AbilityUIUtils.registSkillBtnEventNormal(button, skillInfo)
	button.enabledLongPress = true

	function button.luaBeginLongPress()
		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility then
			return
		end

		if ClientAbilityUtils.showAbilityIndicator(skillInfo.abilityId) then
			return
		end
	end

	function button.luaPress()
		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility or pg.pawn:SWITCH_ANIM_ST() then
			pg.global.showBubbleMessageById(NoticeDef.CUR_STATE_CANNOT_USE_ABILITY)

			return
		end

		local abilityId = skillInfo.abilityId

		pg.game.controller.longPressMap[abilityId] = Time.secondCache

		if skillInfo.abilityType then
			local endSwitch = pg.pawn:tryStopSwitchAbility(abilityId)

			if endSwitch then
				return
			end
		end

		if Utils.isSupportPet(pg.pawn) then
			pg.me:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

			return
		end

		pg.game.controller.curCastAbilityPawnActorId = pg.pawn.actorId

		if ClientAbilityUtils.needShowAbilityIndicator(abilityId) then
			return
		end

		pg.game.controller:useSkill(abilityId, skillInfo.abilityType)
	end

	function button.luaRelease()
		local abilityId = skillInfo.abilityId

		if pg.game.controller.curCastAbilityPawnActorId == pg.pawn.actorId then
			ClientAbilityUtils.hideAbilityIndicator(true, abilityId)
		end

		if skillInfo.abilityType then
			pg.pawn:stopChargeByAbilityId(abilityId)
		end

		pg.game.controller.longPressMap[abilityId] = nil
	end
end

function AbilityUIUtils.registUltimateBtnEventNormal(button, skillInfo)
	button.enabledLongPress = true

	function button.luaBeginLongPress()
		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility then
			return
		end

		if ClientAbilityUtils.showAbilityIndicator(skillInfo.abilityId) then
			return
		end
	end

	function button.luaPress()
		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility or pg.pawn:SWITCH_ANIM_ST() then
			pg.global.showBubbleMessageById(NoticeDef.CUR_STATE_CANNOT_USE_ABILITY)

			return
		end

		local abilityId = skillInfo.abilityId

		if skillInfo.isUsePetSkillMode then
			abilityId = skillInfo.playerAbilityId
		end

		pg.game.controller.longPressMap[abilityId] = Time.secondCache

		if skillInfo.abilityType then
			local endSwitch = pg.pawn:tryStopSwitchAbility(abilityId)

			if endSwitch then
				return
			end
		end

		if Utils.isSupportPet(pg.pawn) then
			pg.me:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

			return
		end

		if pg.me.tempForbidUltimate then
			return
		end

		pg.game.controller.curCastAbilityPawnActorId = pg.pawn.actorId

		if ClientAbilityUtils.needShowAbilityIndicator(abilityId) then
			return
		end

		local isBigSkill = false

		if ToBool(skillInfo.abilityId) then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillInfo.abilityId)

			isBigSkill = abilityParamData.skillType == Const.SkillType.Ultimate
		end

		local isVaild = AbilityUIUtils.isSkillVaild(skillInfo)
		local inCombo = AbilityUIUtils.isInCombo(skillInfo)

		if isVaild and isBigSkill and inCombo then
			button:TryChangePage("Ready", 0)
			button:TryChangePage("Ready", 1)
		end

		pg.game.controller:useSkill(abilityId, skillInfo.abilityType)
	end

	function button.luaRelease()
		local abilityId = skillInfo.abilityId

		if pg.game.controller.curCastAbilityPawnActorId == pg.pawn.actorId then
			ClientAbilityUtils.hideAbilityIndicator(true, abilityId)
		end

		if skillInfo.abilityType then
			pg.pawn:stopChargeByAbilityId(abilityId)
		end

		pg.game.controller.longPressMap[abilityId] = nil
	end
end

function AbilityUIUtils.fillNormalAttackSkillInfo(skillInfo)
	local isControllongPet = Utils.isPet(pg.pawn)
	local ent = isControllongPet and pg.pawn or pg.me
	local abilityId = AbilityUtils:getNormalAttackAbilityId()

	AbilityUIUtils.fillSkillInfoByAbilityId(skillInfo, abilityId, ent)

	skillInfo.pawn = ent
	skillInfo.isNormalAttack = true
	skillInfo.intensityData = nil
	skillInfo.skillIcon = AddressDataConst.MOBILE_NORMAL_ATTACK
end

function AbilityUIUtils.registSkillBtnEventMobile(button, skillInfo)
	local skillJoyStick = skillInfo.skillJoyStick
	local parentComponent = skillInfo.parentComponent
	local skillQteHandled = false

	function button.luaPress()
		skillQteHandled = false

		if AbilityUIUtils.handleMobileSkillButtonQte(skillInfo) then
			skillQteHandled = true

			return
		end

		local realAbilityId = skillInfo.abilityId
		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(realAbilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility or pg.pawn:SWITCH_ANIM_ST() then
			pg.global.showBubbleMessageById(NoticeDef.CUR_STATE_CANNOT_USE_ABILITY)

			return
		end

		if skillInfo.isUsePetSkillMode then
			realAbilityId = skillInfo.playerAbilityId
		end

		if skillInfo.abilityType then
			local endSwitch = pg.pawn:tryStopSwitchAbility(realAbilityId)

			if endSwitch then
				return
			end
		end

		if Utils.isSupportPet(pg.pawn) then
			pg.me:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

			return
		end

		pg.game.controller.longPressMap[skillInfo.abilityId] = Time.secondCache

		local result = pg.game.controller:useSkill(realAbilityId, skillInfo.abilityType)

		if needSkillJoyStick then
			if result and skillInfo.useJoyStick and mobileCastType == AbilityConst.MobileCastType.Aim then
				if NotNil(skillJoyStick) then
					skillJoyStick.gameObject:SetActiveEx(true)
				end

				if parentComponent then
					parentComponent:TryChangePage("expand", 1)
				end

				skillJoyStick.defaultOpacity = 1
			end
		elseif not skillInfo.isUsePetSkillMode and skillInfo.abilityType then
			pg.pawn:stopChargeByAbilityId(realAbilityId)
		end
	end

	function button.luaRelease()
		if skillQteHandled then
			skillQteHandled = false

			return
		end

		local abilityId = skillInfo.abilityId

		if pg.game.controller.longPressMap[abilityId] then
			pg.game.controller.longPressMap[abilityId] = nil
		end

		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if needSkillJoyStick then
			if mobileCastType == AbilityConst.MobileCastType.Aim and skillInfo.useJoyStick and skillJoyStick.isDragging then
				return
			end

			if skillInfo.useJoyStick and parentComponent then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					pg.game.input:setViewAxisByDelta(0, 0)
					parentComponent:TryChangePage("expand", 0)

					skillJoyStick.defaultOpacity = 0

					if NotNil(skillJoyStick) then
						skillJoyStick.gameObject:SetActiveEx(false)
					end
				end
			end

			if skillInfo.isUsePetSkillMode then
				return
			end

			if skillInfo.abilityType then
				pg.pawn:stopChargeByAbilityId(abilityId)
			end
		end
	end

	if skillInfo.useJoyStick then
		function skillJoyStick.luaDragUpdate(x, y)
			local abilityId = skillInfo.abilityId
			local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)

			if mobileCastType == AbilityConst.MobileCastType.Aim then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					pg.game.input:setViewAxisByDeltaPixel(x, y)
				end
			end
		end

		function skillJoyStick.luaJoyStickEndDrag()
			local abilityId = skillInfo.abilityId
			local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)

			if mobileCastType == AbilityConst.MobileCastType.Aim then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					parentComponent:TryChangePage("expand", 0)

					skillJoyStick.defaultOpacity = 0

					if NotNil(skillJoyStick) then
						skillJoyStick.gameObject:SetActiveEx(false)
					end

					pg.game.input:setViewAxisByDelta(0, 0)

					if skillInfo.isUsePetSkillMode then
						return
					end

					if skillInfo.abilityType then
						pg.pawn:stopChargeByAbilityId(abilityId)
					end
				end
			end
		end
	end
end

function AbilityUIUtils.registSkillBtnEventMobileClickVer(button, skillInfo)
	local skillJoyStick = skillInfo.skillJoyStick
	local parentComponent = skillInfo.parentComponent
	local skillQteHandled = false

	button.enabledLongPress = true

	function button.luaPress()
		skillQteHandled = false

		if AbilityUIUtils.handleMobileSkillButtonQte(skillInfo) then
			skillQteHandled = true

			return
		end

		local realAbilityId = skillInfo.abilityId
		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(realAbilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if not needSkillJoyStick then
			return
		end

		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility or pg.pawn:SWITCH_ANIM_ST() then
			pg.global.showBubbleMessageById(NoticeDef.CUR_STATE_CANNOT_USE_ABILITY)

			return
		end

		if skillInfo.isUsePetSkillMode then
			realAbilityId = skillInfo.playerAbilityId
		end

		if Utils.isSupportPet(pg.pawn) then
			pg.me:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

			return
		end

		if skillInfo.useJoyStick and mobileCastType == AbilityConst.MobileCastType.Aim then
			if NotNil(skillJoyStick) then
				skillJoyStick.gameObject:SetActiveEx(true)
			end

			if parentComponent then
				parentComponent:TryChangePage("expand", 1)
			end

			skillJoyStick.defaultOpacity = 1
		end
	end

	function button.luaBeginLongPress()
		if skillQteHandled then
			return
		end

		if AbilityUIUtils.handleMobileSkillButtonQte(skillInfo) then
			skillQteHandled = true

			return
		end

		local realAbilityId = skillInfo.abilityId
		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(realAbilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if not needSkillJoyStick then
			return
		end

		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.me.tempForbidUltimate then
			return
		end

		if pg.pawn.isBuffForbidAbility then
			return
		end

		if skillInfo.isUsePetSkillMode then
			realAbilityId = skillInfo.playerAbilityId
		end

		pg.game.controller.longPressMap[skillInfo.abilityId] = Time.secondCache

		local result = pg.game.controller:useSkill(realAbilityId, skillInfo.abilityType)

		if needSkillJoyStick and result and skillInfo.useJoyStick and mobileCastType == AbilityConst.MobileCastType.Aim then
			if NotNil(skillJoyStick) then
				skillJoyStick.gameObject:SetActiveEx(true)
			end

			if parentComponent then
				parentComponent:TryChangePage("expand", 1)
			end

			skillJoyStick.defaultOpacity = 1
		end
	end

	function button.luaRelease()
		if skillQteHandled then
			return
		end

		local abilityId = skillInfo.abilityId

		if pg.game.controller.longPressMap[abilityId] then
			pg.game.controller.longPressMap[abilityId] = nil
		end

		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if needSkillJoyStick then
			if mobileCastType == AbilityConst.MobileCastType.Aim and skillInfo.useJoyStick and skillJoyStick.isDragging then
				return
			end

			if skillInfo.useJoyStick and parentComponent then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					pg.game.input:setViewAxisByDelta(0, 0)
					parentComponent:TryChangePage("expand", 0)

					skillJoyStick.defaultOpacity = 0

					if NotNil(skillJoyStick) then
						skillJoyStick.gameObject:SetActiveEx(false)
					end
				end
			end

			if skillInfo.isUsePetSkillMode then
				return
			end

			if skillInfo.abilityType then
				pg.pawn:stopChargeByAbilityId(abilityId)
			end
		end
	end

	function button.luaClick()
		if skillQteHandled then
			skillQteHandled = false

			return
		end

		if AbilityUIUtils.handleMobileSkillButtonQte(skillInfo) then
			return
		end

		local realAbilityId = skillInfo.abilityId
		local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(realAbilityId)
		local needSkillJoyStick = mobileCastType == AbilityConst.MobileCastType.Aim or mobileCastType == AbilityConst.MobileCastType.Charge

		if needSkillJoyStick then
			return
		end

		if pg.me and pg.me.invasionInputDisabled then
			return
		end

		if pg.pawn.isBuffForbidAbility or pg.pawn:SWITCH_ANIM_ST() then
			pg.global.showBubbleMessageById(NoticeDef.CUR_STATE_CANNOT_USE_ABILITY)

			return
		end

		if skillInfo.isUsePetSkillMode then
			realAbilityId = skillInfo.playerAbilityId
		end

		if skillInfo.abilityType then
			local endSwitch = pg.pawn:tryStopSwitchAbility(realAbilityId)

			if endSwitch then
				return
			end
		end

		if Utils.isSupportPet(pg.pawn) then
			pg.me:serverMsgNoGC("RPC_CS_NotifyExitSupportPetControl")

			return
		end

		local result = pg.game.controller:useSkill(realAbilityId, skillInfo.abilityType)
	end

	if skillInfo.useJoyStick then
		function skillJoyStick.luaDragUpdate(x, y)
			local abilityId = skillInfo.abilityId
			local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)

			if mobileCastType == AbilityConst.MobileCastType.Aim then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					pg.game.input:setViewAxisByDeltaPixel(x, y)
				end
			end
		end

		function skillJoyStick.luaJoyStickEndDrag()
			local abilityId = skillInfo.abilityId
			local mobileCastType = AbilityUIUtils.getAbilityMobileCastType(abilityId)

			if mobileCastType == AbilityConst.MobileCastType.Aim then
				local ret, page = parentComponent:TryGetCurrentPage("expand")

				if page == 1 then
					parentComponent:TryChangePage("expand", 0)

					skillJoyStick.defaultOpacity = 0

					if NotNil(skillJoyStick) then
						skillJoyStick.gameObject:SetActiveEx(false)
					end

					pg.game.input:setViewAxisByDelta(0, 0)

					if skillInfo.isUsePetSkillMode then
						return
					end

					if skillInfo.abilityType then
						pg.pawn:stopChargeByAbilityId(abilityId)
					end
				end
			end
		end
	end
end

function AbilityUIUtils.refreshRogueSkill(uContainer, skillInfo)
	if uContainer:CheckURLLoaded() then
		AbilityUIUtils.refreshRogueSkillInternal(uContainer, skillInfo)
	else
		uContainer:LoadDefaultUrlManually(function()
			AbilityUIUtils.refreshRogueSkillInternal(uContainer, skillInfo)
		end)
	end
end

function AbilityUIUtils.refreshRogueSkillInternal(uContainer, skillInfo)
	local button = uContainer.content:GetComponent("UButton")
	local objectReference = uContainer.content:GetComponent("ObjectReference")
	local btnRefInfo = AbilityUIUtils.getSkillBtnRefInfo(button)

	AbilityUIUtils.setSkillBtnInfo(btnRefInfo, skillInfo)
	AbilityUIUtils.registSkillBtnEventNormal(button, skillInfo)

	local curEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] or 0
	local maxEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX] or 100

	curEp = math.min(curEp, maxEp)

	local energyUSlider = objectReference:GetRefValue("energyUSlider")

	energyUSlider.maxValue = maxEp

	energyUSlider:ProgressToValue(curEp, nil)

	if pg.me:EXTRA_TEMP_PET_ST() then
		button:TryChangePage("State", 2)
		energyUSlider:SetActive(true)
	elseif maxEp <= curEp then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	local roatateHandleUWidget = objectReference:GetRefValue("roatateHandleUWidget")

	if curEp == 0 or maxEp <= curEp then
		roatateHandleUWidget:SetActive(false)
	else
		local t = curEp / maxEp

		roatateHandleUWidget.transform.localRotation = Quaternion.Euler(0, 0, math.clamp(t, 90, -90))

		roatateHandleUWidget:SetActive(true)
	end
end

function AbilityUIUtils.refreshRogueSkillCost(uContainer)
	if not uContainer or not uContainer.content then
		return
	end

	local button = uContainer.content:GetComponent("UButton")
	local curEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP] or 0
	local maxEp = pg.me.rogueCombatData[AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX] or 100

	curEp = math.min(curEp, maxEp)

	local objectReference = uContainer.content:GetComponent("ObjectReference")
	local energyUSlider = objectReference:GetRefValue("energyUSlider")

	energyUSlider.maxValue = maxEp

	energyUSlider:ProgressToValue(curEp, nil)

	if pg.me:EXTRA_TEMP_PET_ST() then
		button:TryChangePage("State", 2)
		energyUSlider:SetActive(true)
	elseif maxEp <= curEp then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	local roatateHandleUWidget = objectReference:GetRefValue("roatateHandleUWidget")

	if curEp == 0 or maxEp <= curEp then
		roatateHandleUWidget:SetActive(false)
	else
		local t = curEp / maxEp

		roatateHandleUWidget.transform.localRotation = Quaternion.Euler(0, 0, math.clamp(t, 90, -90))

		roatateHandleUWidget:SetActive(true)
	end
end

function AbilityUIUtils.handleMobileSkillButtonQte(skillInfo)
	local qte = pg.game and pg.game.qte

	if not qte or not qte:isQtePlaying() or not skillInfo then
		return false
	end

	return qte:handleMobileSkillButtonClick(skillInfo.actionPath)
end

return AbilityUIUtils
