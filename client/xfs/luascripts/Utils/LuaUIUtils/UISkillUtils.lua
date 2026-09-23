-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UISkillUtils.lua

local ElementPropData = require("Data.element_prop_data")
local PetData = require("Data.pet_data")
local SkillData = require("Data.player_skill_data")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local SkillTreeData = require("Data.player_skill_tree_data")
local SkillTagData = require("Data.skill_tag_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TempleSkillNameReplaceData = require("Data.temple_skill_name_replace_data")
local AbilityParamData = require("Data.ability_param_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local UIStringPool = require("Guis.Utils.UIStringPool")
local UIConst = require("Const.UIConst")
local skillCoreTagDelayTimers = setmetatable({}, {
	__mode = "k"
})
local ToBool = ToBool

return function(LuaUIUtils)
	local function setSkillTooltipText(uBaseText, text, tooltipComponent)
		LuaUIUtils.customSetText(uBaseText, text, true, nil, tooltipComponent)
	end

	function LuaUIUtils.setSkillTipButton(button, data)
		local icon = button:Find("Icon"):GetComponent("UImage")
		local skillIconBg = button:Find("Bg"):GetComponent("UImage")
		local elementBtn = button:Find("ElementTag"):GetComponent("UButton")
		local elementType = data.elementType

		if type(elementType) == "number" then
			elementType = ElementPropData[elementType].name
		end

		LuaUIUtils.setElementButtonNew(elementBtn, elementType)

		skillIconBg.url = LuaUIUtils.getSkillElementIcon(elementType)
		icon.url = data.skillIcon

		button:TryChangePage("particle", data.rare)
	end

	function LuaUIUtils.setSkillTipButton2(button, data)
		function button.luaRenderTooltip(btn, tipPanel)
			local objectReference = tipPanel:GetComponent("ObjectReference")
			local icon = objectReference:GetRefValue("icon")
			local skillName = objectReference:GetRefValue("skillName")
			local elementList = objectReference:GetRefValue("elementList")
			local txtDetail = objectReference:GetRefValue("txtDetail")

			function elementList.luaRenderItem(button1, index1, data1)
				local objectReference = button1:GetComponent("ObjectReference")
				local txtName = objectReference:GetRefValue("txtName")

				ClientTextUtils.setText(txtName, data1.text)
			end

			elementList:SetList(data.tags or {})

			if IsNil(data.tags) or #data.tags == 0 then
				elementList.gameObject:SetActiveEx(false)
			end

			icon.url = data.skillIcon

			ClientTextUtils.setText(skillName, pg.getLocalizationText(data.skillName))
			ClientTextUtils.setText(txtDetail, pg.getLocalizationText(data.skillDesc))
		end
	end

	function LuaUIUtils.getSkillIcon(skillUrl)
		return skillUrl
	end

	function LuaUIUtils.getSkillDesc(abilityParamData, petInfo)
		LuaUIUtils.customRichTextData.petInfo = petInfo

		local desc = ""

		if abilityParamData and abilityParamData.desc then
			desc = pg.getLocalizationText(abilityParamData.desc)

			if abilityParamData.descValue then
				desc = pg.getFormatText(desc, unpack(abilityParamData.descValue))
			end
		end

		LuaUIUtils.customRichTextData.petInfo = nil

		return desc
	end

	function LuaUIUtils.getSkillInfByAbilityId(abilityId, ent)
		local skillInfo = {}

		if abilityId ~= 0 and abilityId ~= nil then
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

			skillInfo.skillIcon = LuaUIUtils.getSkillIcon(skillIcon)

			if abilityTemplateData and abilityTemplateData.maxLoadedCnt then
				skillInfo.backListNum = abilityTemplateData.maxLoadedCnt
				skillInfo.loadingCd = abilityTemplateData.loadingCd
			end
		end

		return skillInfo
	end

	function LuaUIUtils.getSkillElementIcon(elementName)
		if type(elementName) == "number" then
			if not ElementPropData[elementName] then
				return
			end

			elementName = ElementPropData[elementName].name
		end

		if not elementName then
			return
		end

		return string.format("$UI_SkillIcon_Common_Bg_%s.png", elementName)
	end

	function LuaUIUtils.getSkillIconByAbilityId(abilityId)
		if abilityId == 0 or abilityId == nil then
			return ""
		end

		local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(abilityId)
		local abilityParamId = pg.global.abilityMgr:getAbilityParamId(abilityId)
		local abilityParamData = AbilityParamData[abilityParamId] or {}
		local skillIcon = abilityTemplateData.overrideIcon and abilityTemplateData.overrideIcon or abilityParamData.icon

		return skillIcon or ""
	end

	function LuaUIUtils.checkHasEquipCoreAbility(petEntity)
		if not petEntity then
			return false
		end

		local petCoreAbilityId = petEntity.coreAbilityId

		if petCoreAbilityId == 0 then
			return false
		end

		local skillQInfo = petEntity:getSkillByType(AbilityConst.WEAPON_SKILL_ABILITY)

		if skillQInfo and skillQInfo.abilityId == petCoreAbilityId then
			return true
		end

		local skillEInfo = petEntity:getSkillByType(AbilityConst.WEAPON_SKILL_ABILITY2)

		if skillEInfo and skillEInfo.abilityId == petCoreAbilityId then
			return true
		end

		return false
	end

	function LuaUIUtils.getCoreAbilityInfo(petInfo)
		local unlockedAbilityMap = petInfo.unlockedAbilityMap

		if not unlockedAbilityMap then
			return
		end

		local ability

		for paramId, _ in pairs(unlockedAbilityMap) do
			local abilityId = AbilityUtils.getAbilityIdByParamId(petInfo.templateId, paramId)

			if abilityId and abilityId ~= 0 and ToInt(AbilityUtils.isRareAbilityId(abilityId, petInfo.templateId)) == 1 then
				ability = abilityId

				break
			end
		end

		if not ability then
			return
		end

		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(ability)
		local abilityInfo = lume.clone(abilityParamData)
		local tagList = {}

		if abilityInfo.tags then
			for _, tagId in pairs(abilityInfo.tags) do
				tagList[#tagList + 1] = {
					tagName = SkillTagData[tagId].tagName
				}
			end
		end

		abilityInfo.tagList = tagList

		if #tagList > 0 then
			local tagShowList = {
				{
					tagName = tagList[1].tagName
				}
			}

			abilityInfo.tagShowList = tagShowList
		end

		return abilityInfo
	end

	function LuaUIUtils.fillExploreBtnViewData(data, txt, icon, actionPath)
		data.isFloatingState = true
		data.ignoreValidation = true
		data.useCustomEvent = true
		data.btnText = pg.getGameString(txt)
		data.btnIcon = icon
		data.actionPath = actionPath
	end

	function LuaUIUtils.getRealSkillCost(skillData, pet, coreAbilityId)
		local curAbilityData = skillData
		local abilityMap = pet.abilityMap or {}
		local abilityInfo = abilityMap[coreAbilityId]
		local switchInfo = pet.abilitySwitchInfo[coreAbilityId]
		local curAbilityId = switchInfo and switchInfo[1] or coreAbilityId

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
			local curAbilityCost = abilityInfo:getCurEpCost(pet)

			if curAbilityCost then
				local curEnergy = ClientUtils.getSkillEnergyByType(curAbilityData)

				enough = curAbilityCost <= curEnergy
				abilityCost = curAbilityCost
			end

			local rogueEpCost = AbilityUtils.getRogueEpCost(abilityParamData, pg.me)

			if rogueEpCost then
				abilityCost = rogueEpCost

				if rogueEpCost > AbilityUtils.getRogueEp(pg.me) then
					enough = false
				end
			end
		end

		return abilityCost, enough
	end

	function LuaUIUtils.parseSkillBubbleMessage(args)
		local petTmpId = args.petTmpId
		local skillId = args.skillId

		args.skLv = args.skLv or 1

		local title, name, icon, rare, iconStyle

		if petTmpId then
			local sData = pg.global.abilityMgr:getAbilityParamData(skillId)

			name = string.format("[%s]", pg.getLocalizationText(sData.name))

			local cData = PetData[petTmpId] or {}

			icon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON)
			rare = ToInt(AbilityUtils.isRareAbilityId(skillId))
			iconStyle = 98
		else
			local sData = SkillData[skillId][args.skLv]

			name = string.format("[%s]", pg.getLocalizationText(sData.name))

			local treeNode = SkillTreeData[skillId]

			if treeNode.abilityType == AbilityConst.PLAYER_ABILITY_TYPE.PASSIVE then
				icon = LuaUIUtils.getSkillIcon(treeNode.icon)
			else
				sData = pg.global.abilityMgr:getAbilityParamData(sData.learnAbilityId or 0)
				icon = LuaUIUtils.getSkillIcon(sData.icon)
			end

			iconStyle = 99
		end

		title = args.isLearn and pg.getGameString("ACQUIRE_NEW_SKILL") or pg.getGameString("SKILL_LEVEL_UP")

		pg.global.showBubbleMessageRaw(title, 3, iconStyle, name, icon, nil, rare == 1)
	end

	function LuaUIUtils.checkNeedAbilityActionPath(actionPath)
		return LuaUIUtils.AbilityActionPath[actionPath]
	end

	function LuaUIUtils.getSkillActionPath(abilityId)
		if pg.game.controller:isInControlMainPlayer() then
			local skillId1 = pg.me:getRealSkillIdBySkillType(AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q)

			if skillId1 == abilityId then
				return AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q]
			end

			local skillId2 = pg.me:getRealSkillIdBySkillType(AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E)

			if skillId2 == abilityId then
				return AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E]
			end

			local skillId3 = pg.me:getRealSkillIdBySkillType(AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T)

			if skillId3 == abilityId then
				return AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T]
			end

			local petEnt = pg.me:getCurPetEntity()

			if petEnt then
				local finalSkillAbilityId = petEnt:getRealSkillIdBySkillType(AbilityConst.ULTIMATE_ABILITY)

				if finalSkillAbilityId == abilityId then
					return AbilityConst.ULTIMATE_ABILITY_HOTKEY
				end
			end
		else
			local petEnt = pg.me:getCurPetEntity()

			if petEnt then
				if Utils.isSupportPet(petEnt) then
					if abilityId == petEnt.coreAbilityId then
						return UIStringPool.getHudPetActionPath(petEnt.partnerIndex)
					end
				else
					local skillId1 = petEnt:getRealSkillIdBySkillType(AbilityConst.WEAPON_SKILL_ABILITY)

					if skillId1 == abilityId then
						return AbilityConst.PET_ABILITY_HOTKEY[AbilityConst.WEAPON_SKILL_ABILITY]
					end

					local skillId2 = petEnt:getRealSkillIdBySkillType(AbilityConst.WEAPON_SKILL_ABILITY2)

					if skillId2 == abilityId then
						return AbilityConst.PET_ABILITY_HOTKEY[AbilityConst.WEAPON_SKILL_ABILITY2]
					end

					local exploreSkillId = petEnt:getRealSkillIdBySkillType(AbilityConst.EXPLORE_ABILITY)

					if exploreSkillId == abilityId then
						return AbilityConst.PET_ABILITY_HOTKEY[AbilityConst.EXPLORE_ABILITY]
					end
				end

				local finalSkillAbilityId = petEnt:getRealSkillIdBySkillType(AbilityConst.ULTIMATE_ABILITY)

				if finalSkillAbilityId == abilityId then
					return AbilityConst.ULTIMATE_ABILITY_HOTKEY
				end
			end
		end
	end

	function LuaUIUtils.isResistInfoVisible()
		if not pg.game.setting:getIsShowResist() then
			return false
		end

		local player = pg.me

		if not player then
			return false
		end

		local lockedEntity = pg.getEntityByActorId(player.lockedActorId)

		if not lockedEntity then
			return false
		end

		if player.space:isPvpEnv() then
			return true, lockedEntity
		elseif player.space:isNpcDuel() then
			return true, lockedEntity
		elseif Utils.isPuppet(lockedEntity) then
			return true, lockedEntity
		end

		return false
	end

	function LuaUIUtils.hasUnlockAbility(abilityId)
		for type, info in pairs(pg.me.unlockedAbilityMap) do
			if abilityId == info.abilityId then
				return true
			end
		end

		return false
	end

	function LuaUIUtils.isEquipExploreAbility(abilityId)
		for type, id in pairs(pg.me.exploreCustomAbilityIds[pg.me.exploreCustomIndex].abilityIds) do
			if abilityId == id then
				return true
			end
		end

		return false
	end

	function LuaUIUtils.setRenderSKillTooTip(button, data, formName, petInfo, hideElement)
		function button.luaRenderTooltip(_, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local listTagUList = objectRef:GetRefValue("listTagUList")
			local elementUButton1 = objectRef:GetRefValue("elementUButton")
			local damageTypeUButton = objectRef:GetRefValue("damageTypeUButton")
			local cost = objectRef:GetRefValue("cost")
			local cd = objectRef:GetRefValue("cd")
			local iconSkillUImage = objectRef:GetRefValue("iconSkillUImage")
			local txtShortDetailsUSDFText = objectRef:GetRefValue("txtShortDetailsUSDFText")
			local txtLongDetailsUSDFText = objectRef:GetRefValue("txtLongDetailsUSDFText")
			local detailsUWidget = objectRef:GetRefValue("detailsUWidget")
			local formLockText = objectRef:GetRefValue("formLockText")

			component:TryChangePage("IsRare", data.isRare and 1 or 0)

			if formName then
				component:TryChangePage("SkillType", 3)
				ClientTextUtils.setText(formLockText, formName)
			else
				component:TryChangePage("SkillType", 0)
			end

			ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

			iconSkillUImage.url = LuaUIUtils.getSkillIcon(data.icon)

			elementUButton1:SetActiveFastest(not hideElement)
			LuaUIUtils.setElementButtonNew(elementUButton1, data.elementType)
			component:TryChangePage("Details", 1)

			local hasDesc = string.isNilOrEmpty(data.desc)

			detailsUWidget:SetActive(hasDesc)

			local txtLongDetailsUBaseText = txtLongDetailsUSDFText.content:GetComponent("UBaseText")
			local skillDesc = LuaUIUtils.getSkillDesc(data, petInfo)

			LuaUIUtils.customRichTextData.petInfo = petInfo

			setSkillTooltipText(txtLongDetailsUBaseText, skillDesc, component)

			local txtShortDetailsUBaseTextg = txtShortDetailsUSDFText:GetComponent("UBaseText")

			if txtShortDetailsUBaseTextg then
				setSkillTooltipText(txtShortDetailsUBaseTextg, skillDesc, component)
			else
				ClientTextUtils.setText(txtShortDetailsUSDFText, skillDesc)
			end

			LuaUIUtils.customRichTextData.petInfo = nil

			ClientTextUtils.setText(cost, UIStringPool.getTwoDigitText(data.epCost or 0))
			ClientTextUtils.setText(cd, data.power or 0)
			damageTypeUButton:TryChangePage("Type", data.attackType)

			local listAttributeUList = objectRef:GetRefValue("listAttributeUList")

			listAttributeUList:SetActive(true)
			LuaUIUtils.setRenderNewPetSkillAttrsList(listAttributeUList, data)

			local uniqueUWidget = objectRef:GetRefValue("uniqueUWidget")

			if uniqueUWidget then
				uniqueUWidget:SetActive(data.isUltimate)

				local txtUniqueUSDFText = objectRef:GetRefValue("txtUniqueUSDFText")

				if txtUniqueUSDFText then
					ClientTextUtils.setText(txtUniqueUSDFText, pg.getGameString("PETSKILL_ULTIMATE"))
				end
			end

			local tagTypeUWidget = objectRef:GetRefValue("tagTypeUWidget")

			LuaUIUtils.generalRefreshSkillTags(tagTypeUWidget, listTagUList, data, data.tagList)

			if data.alreadyGlazed then
				component:TryChangePage("Type", 2)
			elseif data.canGlaze then
				component:TryChangePage("Type", 1)
			else
				component:TryChangePage("Type", 0)
			end
		end
	end

	function LuaUIUtils.generalRefreshSkillTags(oldTagTypeUWidget, tagsUList, oldTagData, tagsData)
		if NotNil(oldTagTypeUWidget) then
			oldTagTypeUWidget:SetActiveFastestAndMarkIgnoreLayout(false)
		end

		if IsNil(tagsUList) then
			return
		end

		function tagsUList.luaRenderItem(b, _, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue(d.tagNameBindUI)

			ClientTextUtils.setText(txtNameUText, d.tagName or "")
			b:TryChangePage("TagType", d.tagPageIndex)
		end

		local mergeTags = {}
		local skillType = oldTagData and oldTagData.attackType

		if skillType then
			table.insert(mergeTags, {
				tIndex = 1,
				tagNameBindUI = "txtTypeUSDFText",
				tagPageIndex = UIConst.SkillAtkType2UITag[skillType] or 0,
				tagName = pg.getGameString(UIConst.SkillAtkTypeTagStrKey[skillType] or "")
			})
		end

		for _, tagData in ipairs(tagsData or {}) do
			table.insert(mergeTags, {
				tIndex = 0,
				tagNameBindUI = "txtNameUText",
				tagPageIndex = tagData.tagPageIndex or 0,
				tagName = pg.getLocalizationText(tagData.tagName or "")
			})
		end

		tagsUList:SetList(mergeTags)
	end

	function LuaUIUtils.setRenderFeatureToolTips(button, featureInfo, petInfo)
		function button.luaRenderTooltip(_, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local iconSkillUImage = objectRef:GetRefValue("iconSkillUImage")
			local txtShortDetailsUSDFText = objectRef:GetRefValue("txtShortDetailsUSDFText")
			local detailsUWidget = objectRef:GetRefValue("detailsUWidget")
			local maskImg = objectRef:GetRefValue("maskImg")

			component:TryChangePage("IsRare", featureInfo.rare and 1 or 0)
			component:TryChangePage("SkillType", 2)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(featureInfo.name))

			iconSkillUImage.url = featureInfo.icon
			maskImg.url = featureInfo.icon

			detailsUWidget.gameObject:SetActiveEx(false)

			local txtShortDetailsUBaseText = txtShortDetailsUSDFText:GetComponent("UBaseText")

			LuaUIUtils.customRichTextData.petInfo = petInfo

			if txtShortDetailsUBaseText then
				setSkillTooltipText(txtShortDetailsUBaseText, pg.getLocalizationText(featureInfo.desc), component)
			else
				ClientTextUtils.setText(txtShortDetailsUSDFText, pg.getLocalizationText(featureInfo.desc))
			end

			LuaUIUtils.customRichTextData.petInfo = nil
		end
	end

	function LuaUIUtils.setRenderNewPetSkillAttrsList(listAttributeUList, skillInfoData, compareSkillInfoData)
		local function _renderAttributeItem(b, _, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(d.nameKey))

			local txtNumUSDFText = objectReference1:GetRefValue("txtNumUSDFText")

			ClientTextUtils.setText(txtNumUSDFText, d.valStr)
		end

		function listAttributeUList.luaRenderItem(button, index, data)
			_renderAttributeItem(button, index, data)
		end

		local abilityParamData

		if skillInfoData and skillInfoData.paramId then
			abilityParamData = AbilityParamData[skillInfoData.paramId]
		end

		abilityParamData = abilityParamData or pg.global.abilityMgr:getAbilityParamData(skillInfoData and skillInfoData.abilityId or 0)
		abilityParamData = abilityParamData or {}

		local formatUnityKey = {
			"SECOND",
			"PETSKILL_POWER_UNIT"
		}

		local function formatFunc(valStr, formatOriginalDesc)
			valStr = valStr or 0

			if not formatOriginalDesc then
				return tostring(valStr)
			end

			local result = string.gsub(formatOriginalDesc, "{(%d+)}", function(idx)
				local key = formatUnityKey[tonumber(idx) + 1]
				local ret = key and pg.getGameString(key) or ""

				ClientTextUtils.concatByLanguage("", ret)

				return ret
			end)

			result = string.gsub(result, "%%d", tostring(valStr), 1)

			return result
		end

		local function getCompareVal(valStr, rawVal, formatOriginalDesc)
			if formatOriginalDesc then
				return nil
			end

			return tonumber(rawVal) or tonumber(valStr)
		end

		local function formatCompareNum(num)
			if num == math.floor(num) then
				return tostring(math.floor(num))
			end

			return tostring(num)
		end

		local function getCompareAbilityParamData(infoData)
			local compareAbilityParamData

			if infoData and infoData.paramId then
				compareAbilityParamData = AbilityParamData[infoData.paramId]
			end

			compareAbilityParamData = compareAbilityParamData or pg.global.abilityMgr:getAbilityParamData(infoData and infoData.abilityId or 0)

			return compareAbilityParamData or {}
		end

		local function buildCompareAttributeMap(infoData)
			local compareAbilityParamData = getCompareAbilityParamData(infoData)
			local compareExistSpCost = compareAbilityParamData.skillType == 4
			local compareBpRateCfgVal = compareAbilityParamData.bpRate or 1
			local comparePowerVal = compareAbilityParamData.power or 0
			local compareCostVal = compareExistSpCost and compareAbilityParamData.spCost or compareAbilityParamData.epCost or 0
			local compareBreakVal = (compareBpRateCfgVal == -1 or comparePowerVal == 0) and 0 or math.ceil((compareAbilityParamData.bpRate or 1) * 100)
			local compareCdVal = compareAbilityParamData.cd or 0
			local compareAllAttributeList = {
				{
					nameKey = "PETSKILL_POWER",
					compareVal = getCompareVal(comparePowerVal, comparePowerVal, compareAbilityParamData.powerFormat)
				},
				{
					nameKey = compareExistSpCost and "PETSKILL_SP_CONT_TIP" or "PETSKILL_ENERGY_COST",
					compareVal = getCompareVal(compareCostVal, compareCostVal, compareAbilityParamData.epCostFormat)
				},
				{
					nameKey = "PETSKILL_BREAK",
					compareVal = getCompareVal(compareBreakVal .. "%", compareBreakVal)
				},
				{
					nameKey = "PETSKILL_CD",
					compareVal = getCompareVal(compareCdVal .. pg.getGameString("SECOND"), compareCdVal, compareAbilityParamData.cdFormat)
				}
			}
			local compareIsAtkSkill = not compareAbilityParamData.attackType or compareAbilityParamData.attackType == 0
			local compareAttributeMap = {}

			for index, v in ipairs(compareAllAttributeList) do
				if compareIsAtkSkill and (index == 1 or index == 3) then
					-- block empty
				else
					compareAttributeMap[v.nameKey] = v
				end
			end

			return compareAttributeMap
		end

		local compareAttributeMap = compareSkillInfoData and buildCompareAttributeMap(compareSkillInfoData)
		local existSpCost = abilityParamData.skillType == 4
		local bpRateCfgVal = abilityParamData.bpRate or 1
		local powerVal = abilityParamData.power or 0
		local costVal = existSpCost and abilityParamData.spCost or abilityParamData.epCost or 0
		local breakVal = (bpRateCfgVal == -1 or powerVal == 0) and 0 or math.ceil((abilityParamData.bpRate or 1) * 100)
		local secondStr = pg.getGameString("SECOND")
		local cdVal = abilityParamData.cd or 0
		local attributeDefValList = {
			powerVal,
			costVal,
			breakVal .. "%",
			ClientTextUtils.concatByLanguage(cdVal, secondStr)
		}
		local allAttributeList = {
			{
				nameKey = "PETSKILL_POWER",
				diffUnit = "",
				valStr = formatFunc(attributeDefValList[1], abilityParamData.powerFormat),
				compareVal = getCompareVal(attributeDefValList[1], powerVal, abilityParamData.powerFormat)
			},
			{
				diffUnit = "",
				nameKey = existSpCost and "PETSKILL_SP_CONT_TIP" or "PETSKILL_ENERGY_COST",
				valStr = formatFunc(attributeDefValList[2], abilityParamData.epCostFormat),
				compareVal = getCompareVal(attributeDefValList[2], costVal, abilityParamData.epCostFormat)
			},
			{
				nameKey = "PETSKILL_BREAK",
				diffUnit = "%",
				valStr = formatFunc(attributeDefValList[3]),
				compareVal = getCompareVal(attributeDefValList[3], breakVal)
			},
			{
				nameKey = "PETSKILL_CD",
				valStr = formatFunc(attributeDefValList[4], abilityParamData.cdFormat),
				compareVal = getCompareVal(attributeDefValList[4], cdVal, abilityParamData.cdFormat),
				diffUnit = secondStr
			}
		}
		local attributeList = {}

		if abilityParamData.attackType ~= nil then
			local isAtkSkill = abilityParamData.attackType == 0

			for index, v in ipairs(allAttributeList) do
				if isAtkSkill and (index == 1 or index == 3) then
					-- block empty
				else
					table.insert(attributeList, v)
				end
			end
		end

		if compareAttributeMap then
			local fStr = pg.getGameString("Pet_UpSkill_Compare_AttrShow_ValStr")

			fStr = (not fStr or fStr == "Pet_UpSkill_Compare_AttrShow_ValStr") and "%s%s" or fStr

			for _, v in ipairs(attributeList) do
				local compareAttr = compareAttributeMap[v.nameKey]

				if compareAttr and v.compareVal and compareAttr.compareVal then
					local diffVal = v.compareVal - compareAttr.compareVal

					if diffVal ~= 0 then
						local diffValDesc = formatCompareNum(diffVal)

						if diffVal > 0 then
							diffValDesc = "+" .. diffValDesc
						end

						diffValDesc = diffValDesc .. (v.diffUnit or "")
						v.valStr = string.format(fStr, v.valStr, diffValDesc)
					end
				end
			end
		end

		listAttributeUList:SetList(attributeList)
	end

	function LuaUIUtils.renderSkillCmpCommon(button, data, name, icon, func, petInfo)
		local objectReference = button:GetComponent("ObjectReference")
		local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local elementUButton = objectReference:GetRefValue("elementUButton")
		local skillNameUWidget = objectReference:GetRefValue("skillNameUWidget")
		local coreTagChildName = "SkillName/TagCore"
		local coreTagChildT = button.transform:Find(coreTagChildName)
		local coreTagChildGo = coreTagChildT and coreTagChildT.gameObject

		if skillCoreTagDelayTimers[button] then
			TimerManager.removeTimer(skillCoreTagDelayTimers[button])

			skillCoreTagDelayTimers[button] = nil
		end

		if NotNil(coreTagChildGo) then
			coreTagChildGo:SetActiveEx(false)
		end

		button:TryChangePage("State", 0)
		button:TryChangePage("Element", 0)
		button:TryChangePage("IsRare", 0)

		if not data then
			button.enabledTooltip = false

			skillNameUWidget.gameObject:SetActiveEx(false)
			button:SetActive(false)

			return false
		end

		button:SetActive(true)

		local petPrototypeId = petInfo and petInfo.petPrototypeId
		local paramId = AbilityUtils.getAbilityParamId(data and data.abilityId)
		local isCore = false

		if paramId and petPrototypeId then
			isCore = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, petPrototypeId)) == 1
		end

		skillCoreTagDelayTimers[button] = TimerManager.addTimer(0.1, function()
			skillCoreTagDelayTimers[button] = nil

			if NotNil(coreTagChildGo) then
				coreTagChildGo:SetActiveEx(isCore)
			end
		end)
		button.enabledTooltip = data.enabledTooltip ~= false

		button:TryChangePage("State", 1)

		local showSkillName = data.showSkillName ~= false

		skillNameUWidget.gameObject:SetActiveEx(showSkillName)
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name or data.name))

		iconNormalUImage.url = LuaUIUtils.getSkillIcon(icon or data.icon)

		if data.elementType then
			button:TryChangePage("Element", 1)
			LuaUIUtils.setElementButtonNew(elementUButton, data.elementType)
		end

		if data.alreadyGlazed then
			button:TryChangePage("IsRare", 2)
		elseif data.hasGlazePath then
			button:TryChangePage("IsRare", 1)
		else
			button:TryChangePage("IsRare", 0)
		end

		if func then
			func()
		end

		return true
	end

	function LuaUIUtils.getSkillGlazeType(d)
		if not d then
			return UIConst.GlazeType.None
		end

		if d.hasGlazePath then
			if d.alreadyGlazed then
				return UIConst.GlazeType.Upgraded
			else
				return UIConst.GlazeType.Upgrade
			end
		end

		return UIConst.GlazeType.None
	end

	function LuaUIUtils.renderSkillHeadComp(button, data, petInfo, enbaleDrag, onPress, onEndDrag, forbidTooltip)
		LuaUIUtils.renderSkillCmpCommon(button, data, nil, nil, nil, petInfo)
		button:TryChangePage("IsRare", 0)

		if not data then
			button.luaPress = nil
			button.luaBeginDrag = nil
			button.luaEndDrag = nil

			return
		end

		button.enabledTooltip = not forbidTooltip

		LuaUIUtils.setRenderSKillTooTip(button, data, nil, petInfo)

		local glazeType = LuaUIUtils.getSkillGlazeType(data)

		button:TryChangePage("IsRare", glazeType)

		function button.luaPress()
			if onPress then
				onPress(button, data)
			end
		end

		if enbaleDrag then
			function button.luaBeginDrag()
				button.replicaWidget.transform.localScale = Vector3(1.5, 1.5, 1.5)

				local objectReference1 = button.replicaWidget:GetComponent("ObjectReference")
				local iconSkillUImage1 = objectReference1:GetRefValue("iconSkillUImage")
				local elementUButton1 = objectReference1:GetRefValue("elementUButton")

				iconSkillUImage1.url = LuaUIUtils.getSkillIcon(data.icon)

				if data.elementType then
					button.replicaWidget:TryChangePage("Element", 1)
					LuaUIUtils.setElementButtonNew(elementUButton1, data.elementType)
				end
			end

			function button.luaEndDrag(dropTarget)
				if onEndDrag then
					onEndDrag(dropTarget)
				end
			end
		else
			button.luaBeginDrag = nil
			button.luaEndDrag = nil
		end
	end

	function LuaUIUtils.buildEnhancedSkillInfo(enhancedParamId, templateId, petPrototypeId)
		if not enhancedParamId then
			return nil
		end

		local abilityId = AbilityUtils.getAbilityIdByParamId(templateId, enhancedParamId)

		if (not abilityId or abilityId == 0) and petPrototypeId then
			abilityId = AbilityUtils.getAbilityIdByParamId(petPrototypeId, enhancedParamId)
		end

		local abilityParamData

		if abilityId and abilityId ~= 0 then
			abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
		end

		if not abilityParamData then
			abilityParamData = AbilityParamData[enhancedParamId]
			abilityId = 0
		end

		if not abilityParamData then
			return nil
		end

		local info = lume.clone(abilityParamData)

		info.abilityId = abilityId
		info.paramId = enhancedParamId

		local numberList = {}

		numberList[#numberList + 1] = {
			number = info.epCost or 0
		}
		numberList[#numberList + 1] = {
			number = info.power or 0
		}
		info.numberList = numberList

		local tagList = {}

		if info.tags then
			for _, tagId in pairs(info.tags) do
				tagList[#tagList + 1] = {
					tagName = SkillTagData[tagId].tagName
				}
			end
		end

		info.tagList = tagList

		if #tagList > 0 then
			info.tagShowList = {
				{
					tagName = tagList[1].tagName
				}
			}
		end

		local elementList = {}

		elementList[#elementList + 1] = {
			elementName = ElementPropData[abilityParamData.elementType],
			elementTypeId = abilityParamData.elementType
		}
		info.elementList = elementList
		info.rare = ToInt(AbilityUtils.isRareAbilityByParamId(enhancedParamId, petPrototypeId))

		return info
	end

	function LuaUIUtils.getSkillListVisible()
		if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Skill) then
			return false
		end

		if pg.me.inTeammateView then
			return false
		end

		return true
	end

	function LuaUIUtils.setRenderExploreToolTips(button, data)
		function button.luaRenderTooltip(_, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local iconSkillUImage = objectRef:GetRefValue("iconSkillUImage")
			local txtShortDetailsUSDFText = objectRef:GetRefValue("txtShortDetailsUSDFText")
			local txtLongDetailsUSDFText = objectRef:GetRefValue("txtLongDetailsUSDFText")
			local detailsUWidget = objectRef:GetRefValue("detailsUWidget")

			component:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId)))
			component:TryChangePage("SkillType", 1)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

			if pg.game.setting:getShowDebugId() then
				ClientTextUtils.setText(txtName, txtName.text, "-", string.format("%d-%d", data.abilityId, AbilityUtils.getAbilityParamId(data.abilityId)))
			end

			iconSkillUImage.url = LuaUIUtils.getSkillIcon(data.icon)

			detailsUWidget.gameObject:SetActiveEx(data.desc ~= nil)

			local skillDesc = LuaUIUtils.getSkillDesc(data)
			local txtLongDetailsUBaseText = txtLongDetailsUSDFText.content:GetComponent("UBaseText")

			setSkillTooltipText(txtLongDetailsUBaseText, skillDesc, component)

			local txtShortDetailsUBaseText = txtShortDetailsUSDFText:GetComponent("UBaseText")

			if txtShortDetailsUBaseText then
				setSkillTooltipText(txtShortDetailsUBaseText, skillDesc, component)
			else
				ClientTextUtils.setText(txtShortDetailsUSDFText, skillDesc)
			end
		end
	end
end
