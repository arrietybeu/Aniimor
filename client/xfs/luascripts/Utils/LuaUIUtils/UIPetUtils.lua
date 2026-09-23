-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIPetUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local HomelandOperateData = require("Data.homeland_operate_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local ElementPropData = require("Data.element_prop_data")
local ElementNameToId = require("Data.element_name_to_id")
local PuppetData = require("Data.puppet_data")
local PetAvatarData = require("Data.pet_avatar_data")
local PetData = require("Data.pet_data")
local PetEthnicToPrototypeMap = require("Data.pet_ethnic_to_prototype_map")
local PetFormTypeData = require("Data.pet_form_type_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetIconInfoData = require("Data.pet_head_icon_info")
local PetManualInfoData = require("Data.pet_manual_icon_info")
local ExploreAbilityData = require("Data.explore_ability_data")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("LuaUIUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local PetCharacterData = require("Data.pet_character_data")
local Lume = require("Core.Common.lume")
local PetConfigData = require("Data.pet_config_data")
local CommonSwitch = require("Common.CommonSwitch")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapBlockConfigData = require("Data.map_block_config_data")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local MapAreaConfigData = require("Data.map_area_config_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetPrototypeToBlockMap = require("Data.pet_prototype_to_block_map")
local WeatherData = require("Data.weather_data")
local PetTalentData = require("Data.pet_talent_data")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local PetLevelData = require("Data.pet_level_data")
local AttributeConst = require("Common.Const.AttributeConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local FunctionEnum = require("Data.function_unlock_enum")
local FuncIdConfigData = require("Data.func_index_config_data")
local PetEvolveData = require("Data.pet_evolve_data")
local UIConst = require("Const.UIConst")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local SysConfigData = require("Data.sys_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PetShinyStyleData = require("Data.pet_shiny_style_data")
local CaptureUtils = require("Common.Utils.CaptureUtils")
local ToBool = ToBool
local PET_RESEARCH_COLLECTION_NATION = 1000
local DEFAULT_MANAGEMENT_PET_BACKGROUND = "$UI_Img_PetType_BallBg_110001.png"
local DEFAULT_CHAT_PET_BACKGROUND = "$UI_Img_PetType_BallBg_Large_110001.png"
local DEFAULT_PET_BALL_FIGURE = "$UI_Img_PetType_Shading.png"

return function(LuaUIUtils)
	local ICON_ID_TO_PATH = {
		[LuaUIUtils.PET_ICON] = {
			AddressDataConst.PET_HEAD_ICON,
			AddressDataConst.PET_HEAD_FLASH_ICON
		},
		[LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK] = {
			AddressDataConst.IMG_RESEARCH_BOOK_ICON,
			AddressDataConst.IMG_RESEARCH_BOOK_SHINY_ICON
		},
		[LuaUIUtils.PET_RESEARCH_REWARD] = AddressDataConst.PET_RESEARCH_REWARD_ICON,
		[LuaUIUtils.PET_FIRST_SHOW] = AddressDataConst.IMG_RESEARCH_BOOK_FIRST_SHOW_ICON
	}

	function LuaUIUtils.checkPetResearchAreaIsCollection(areaId)
		local areaCfgData = MapAreaConfigData[areaId]

		return areaCfgData ~= nil and areaCfgData.belongNation ~= nil and areaCfgData.belongNation >= PET_RESEARCH_COLLECTION_NATION
	end

	function LuaUIUtils.getPetDisplayNumber(countryId, numberTxt, number)
		if numberTxt and numberTxt ~= "" and LuaUIUtils.checkPetResearchAreaIsCollection(countryId) then
			return numberTxt, true
		end

		return number and string.format("%03d", number % 1000) or "", false
	end

	function LuaUIUtils.getElementName(elementId)
		local elementInfo = ElementPropData[elementId] or {}

		return elementInfo.name or "None"
	end

	function LuaUIUtils.getElementDmgRationNameByEleId(elementId)
		local elementInfo = ElementPropData[elementId] or {}

		return elementInfo.dmg_ratio_name
	end

	function LuaUIUtils.getElementIdByDmgRationName(dmgRatioName, type)
		local checkKey = type == 1 and "dmg_ratio_name" or "dmg_dec_ratio_name"

		for elementId, elementInfo in pairs(ElementPropData) do
			if elementInfo[checkKey] == dmgRatioName then
				return elementId
			end
		end
	end

	function LuaUIUtils.getElementNameLocalization(elementId, withColor)
		local elementInfo = ElementPropData[elementId] or {}

		return string.format("<sprite name=\"UI_IconTMP_Element_%s\">%s", elementInfo.name, pg.getLocalizationText(elementInfo.name_ch))
	end

	function LuaUIUtils.getTargetElementsInfos(elementTypes)
		local ret = {}

		if not elementTypes then
			return ret
		end

		for idx, flag in pairs(elementTypes) do
			if flag then
				ret[#ret + 1] = {
					elementName = LuaUIUtils.getElementName(idx),
					elementId = idx
				}
			end
		end

		return ret
	end

	function LuaUIUtils.showPetCellElements(btnObjRef, elementNames)
		local addOnUComponent = btnObjRef:GetRefValue("addOnUComponent")
		local singleElement = btnObjRef:GetRefValue("singleElement")
		local doubleElement1 = btnObjRef:GetRefValue("doubleElement1")
		local doubleElement2 = btnObjRef:GetRefValue("doubleElement2")
		local elementCount = #elementNames

		if elementCount == 0 then
			addOnUComponent:TryChangePage("DetailState", 0)
		elseif elementCount == 1 then
			addOnUComponent:TryChangePage("DetailState", 1)
			LuaUIUtils.setElementButtonNew(singleElement, elementNames[1].element)
		else
			addOnUComponent:TryChangePage("DetailState", 2)
			LuaUIUtils.setElementButtonNew(doubleElement1, elementNames[1].element)
			LuaUIUtils.setElementButtonNew(doubleElement2, elementNames[2].element)
		end
	end

	function LuaUIUtils.setElementButtonNew(button, elementName, needRestraintTip, petTemplateId, extraData)
		if type(elementName) == "number" then
			if not ElementPropData[elementName] then
				return
			end

			elementName = ElementPropData[elementName].name
		end

		if not elementName then
			return
		end

		local elementId = ElementNameToId[elementName]

		if not elementId then
			return
		end

		if button.customData ~= elementName and button:TryChangePage("type", elementName) then
			button.customData = elementName
		end

		local title = button.title

		if title then
			local nameCh = ElementPropData[elementId] and ElementPropData[elementId].name_ch

			ClientTextUtils.setText(title, pg.getLocalizationText(nameCh))
		end

		local petData = petTemplateId and PetData[petTemplateId]

		if petData then
			local objectReference = button:GetComponent("ObjectReference")

			if objectReference then
				local levelValue = objectReference:GetRefValue("level")

				if levelValue then
					local level = levelValue:GetComponent("USDFText")

					ClientTextUtils.setText(level, string.format("L%s", petData.elementLevels and petData.elementLevels[elementName] or 0))
				end
			end
		end

		function button.luaClick()
			if needRestraintTip == false then
				return
			end

			if not pg.global.ui:runPlatformByPC() then
				return
			end

			pg.global.ui.tips:showRestraint(elementName)

			if extraData and extraData.eleBtnClickFunc then
				extraData.eleBtnClickFunc(elementName)
			end
		end
	end

	function LuaUIUtils.setElementGrade(button, elementName, petTemplateId, needRestraintTip)
		if type(elementName) == "number" then
			if not ElementPropData[elementName] then
				return
			end

			elementName = ElementPropData[elementName].name
		end

		if not elementName then
			return
		end

		local icon = button:Find("Panel/Icon"):GetComponent("UImage")
		local txtGrade = button:Find("Panel/TxtGrade"):GetComponent("UBaseText")
		local elementId = ElementNameToId[elementName]

		if not elementId then
			return
		end

		local nameCh = ElementPropData[elementId] and ElementPropData[elementId].name_ch

		button:TryChangePage("type", elementName)

		if txtGrade then
			ClientTextUtils.setText(txtGrade, string.format("L%s", PuppetData[petTemplateId].elementLevels and PuppetData[petTemplateId].elementLevels[elementName] or 0))
		end

		function button.luaClick()
			if needRestraintTip == false then
				return
			end

			pg.global.ui.tips:showRestraint(elementName)
		end
	end

	function LuaUIUtils.getPetIcon(petName, iconType, label, gender)
		local ret
		local iconPath = ICON_ID_TO_PATH[iconType]

		if iconPath and petName then
			local iconCfgData

			if iconType == LuaUIUtils.PET_ICON then
				iconCfgData = PetIconInfoData
			elseif iconType == LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK then
				iconCfgData = PetManualInfoData
			end

			if iconCfgData ~= nil then
				local iconCfgInfo = iconCfgData[petName]

				if not iconCfgInfo then
					ret = string.format(iconPath[1], petName, "")
				else
					local isShinyIcon = iconCfgInfo.hasShiny and Utils.isLabelShiny(label)
					local isMaleIcon = iconCfgInfo.hasMale and gender == Const.GENDER_TYPE_MALE
					local isFemaleIcon = iconCfgInfo.hasFemale and gender == Const.GENDER_TYPE_FEMALE

					gender = isMaleIcon and "_Male" or isFemaleIcon and "_Female" or ""

					if isShinyIcon then
						ret = string.format(iconPath[2], petName, gender)
					else
						ret = string.format(iconPath[1], petName, gender)
					end
				end
			else
				ret = string.format(iconPath, petName)
			end
		end

		return ret
	end

	function LuaUIUtils.tryClearPetHeadIconInUBUtton(button)
		if IsNil(button) then
			return
		end

		local objRef = button:GetComponent("ObjectReference")
		local iconUImage = objRef:GetRefValue("iconUImage")

		LuaUIUtils.clearPetHeadIcon(iconUImage)
	end

	function LuaUIUtils.clearPetHeadIcon(iconUImage)
		if IsNil(iconUImage) then
			return
		end

		iconUImage.url = nil
	end

	function LuaUIUtils.reloadPetHeadIcon(iconUImage, iconUrl)
		if IsNil(iconUImage) then
			return
		end

		if iconUrl == nil or iconUrl == "" then
			iconUrl = iconUImage.url
		end

		iconUImage.url = nil

		if iconUrl == nil or iconUrl == "" then
			return
		end

		iconUImage:SetUrlWithCallback(iconUrl, nil)
	end

	function LuaUIUtils.getPetIconByTemplateId(templateId, iconType, label)
		local pData = PetData[templateId]

		if pData == nil then
			return ""
		end

		local iconName = pData.iconName

		return LuaUIUtils.getPetIcon(iconName, iconType, label)
	end

	function LuaUIUtils.getElementInfo(elements, mainElementId)
		local elementIds = {}
		local elementNames = {}

		if mainElementId then
			elementIds[#elementIds + 1] = mainElementId
			elementNames[#elementNames + 1] = {
				element = LuaUIUtils.getElementName(mainElementId)
			}
		end

		if elements then
			for idx, flag in pairs(elements) do
				if flag and idx ~= mainElementId then
					elementIds[#elementIds + 1] = idx
					elementNames[#elementNames + 1] = {
						element = LuaUIUtils.getElementName(idx)
					}
				end
			end
		end

		return elementIds, elementNames
	end

	function LuaUIUtils.setGenderIcon(gender, uImage)
		uImage:SetActive(true)

		if gender == Const.GENDER_TYPE_MALE then
			uImage.url = "$ui_prefab_common_gender_male.png"

			return
		end

		if gender == Const.GENDER_TYPE_FEMALE then
			uImage.url = "$ui_prefab_common_gender_female.png"

			return
		end

		uImage:SetActive(false)
	end

	function LuaUIUtils.openPetAppearancePanel(curPetId, closeCb)
		if not CommonSwitch.APPEARAMCE then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
			enableCameraMode = true,
			enterPage = "pet",
			curPetId = curPetId,
			closeCallback = closeCb
		})
	end

	function LuaUIUtils.isPetTank(templateId)
		local petData = PetData[templateId]

		if not petData then
			return false
		end

		return petData.functionId == UIConst.NEW_PET_BATTLE_TYPE.BREAK
	end

	function LuaUIUtils.getPetName(petId)
		local pet = pg.me:getPetInfo(petId)

		if not pet then
			return nil
		end

		if pet.customName and pet.customName ~= "" then
			return pet.customName
		end

		local pData = PetData[pet.templateId] or {}
		local name = pData.name

		return name
	end

	function LuaUIUtils.getPetNameByPetInfo(petInfo, withoutSuffix)
		if petInfo.customName and petInfo.customName ~= "" then
			return petInfo.customName
		end

		local pData = PetData[petInfo.templateId] or {}
		local name = ""

		if withoutSuffix then
			name = pg.getLocalizationTextWithoutSuffix(pData.name)
		else
			name = pg.getLocalizationText(pData.name)
		end

		return name
	end

	function LuaUIUtils.getPetNameWithIdOrTmpId(id)
		local pData = PetData[id]

		if pData then
			return pg.getLocalizationText(pData.name)
		end

		return LuaUIUtils.getPetName(id)
	end

	function LuaUIUtils.getPetCpValue(petId)
		local pet = pg.me:getPetInfo(petId)

		return pet and pet:getCpValue() or 0
	end

	function LuaUIUtils.getPetSpecialAttr(petId)
		if ClientUtils.isInDouYinOfflineScene() then
			return nil
		end

		local petInfo = pg.me:getPetInfo(petId)

		if petInfo then
			local controlFeatureId = petInfo.characterInfo.curCharacter
			local featureInfo = PetCharacterData[controlFeatureId]

			if featureInfo and featureInfo.rare == 1 then
				return LuaUIUtils.SP_CODE.SP_FEATURE, pg.getLocalizationText(featureInfo.name)
			end

			local abilityMap = petInfo.curAbilityMap
			local abilityMgr = pg.global.abilityMgr

			for _, abilityInfo in pairs(abilityMap) do
				if AbilityUtils.isRareAbilityId(abilityInfo.abilityId) then
					local abilityParamData = abilityMgr:getAbilityParamData(abilityInfo.abilityId)

					return LuaUIUtils.SP_CODE.SP_SKILL, pg.getLocalizationText(abilityParamData.name)
				end
			end

			local baseProperty = petInfo.basePropertyList
			local firstBaseProperty = baseProperty and baseProperty[1]

			if not firstBaseProperty or firstBaseProperty.talentPoint == nil then
				return nil
			end

			local recommendAttrs = PetData[petInfo.templateId].recommend_attr or {}
			local highAttrList = {}

			for attrId, attrName in pairs(Const.ATTRIBUTE_NAME_LIST) do
				local num = baseProperty[attrId].talentPoint

				if num / 30 >= PetConfigData.talentPointHighPercent then
					local isRecommend = table.contains(recommendAttrs, attrId) and 1 or 0

					highAttrList[#highAttrList + 1] = {
						num = num or 0,
						name = attrName,
						attrId = attrId,
						isRecommend = isRecommend or false
					}
				end
			end

			table.sort(highAttrList, function(a, b)
				if a.isRecommend == b.isRecommend then
					return a.num > b.num
				end

				return a.isRecommend > b.isRecommend
			end)

			if #highAttrList > 0 then
				return LuaUIUtils.SP_CODE.SP_ATTR, ClientTextUtils.concatByLanguage(pg.getGameString("HIGH"), pg.getGameString(highAttrList[1].name))
			end
		end

		return nil, nil
	end

	function LuaUIUtils.bindVariantPetDetailButton(button, tipsWidget, data, onClick)
		local friendUid = data.variantFriendUid or pg.me:getPetVariantFriendUid(data.id)
		local variantTime = data.variantTime or pg.me:getPetVariantTime(data.id)
		local hasVariantDetail = data.isVariantInteractPet == true and string.notNilOrEmpty(friendUid) and variantTime > 0

		button:SetActive(hasVariantDetail)

		button.enabledTooltip = hasVariantDetail

		if not hasVariantDetail then
			button.luaRenderTooltip = nil
			button.luaClick = nil

			return
		end

		function button.luaRenderTooltip(_, transform)
			LuaUIUtils.renderVariantPetDetailTooltip(transform, friendUid, variantTime)
		end

		local queryingFriendInfo = false

		function button.luaClick()
			if onClick then
				onClick()
			end

			local displayName = LuaUIUtils.getPlayerDisplayName(friendUid)

			if not string.isNilOrEmpty(displayName) then
				button:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)

				return
			end

			if queryingFriendInfo then
				return
			end

			local function openTooltip()
				queryingFriendInfo = false

				button:OpenTooltipWithUrl(AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE)
			end

			queryingFriendInfo = true

			pg.game.chat:queryFriendShowTitleName(friendUid, openTooltip)
		end
	end

	function LuaUIUtils.renderVariantPetDetailTooltip(transform, friendUid, variantTime)
		local objectReference = transform:GetComponent("ObjectReference")
		local txtTitle = objectReference:GetRefValue("txtTitle")
		local txtDesc = objectReference:GetRefValue("txtDesc")
		local friendName = LuaUIUtils.getPlayerDisplayName(friendUid)
		local variantDate = os.date("%Y/%m/%d", variantTime)
		local desc = pg.getFormatText(pg.getGameString("PET_VARIANT_DETAIL_DESC"), friendName, variantDate)

		transform:TryChangePage("Btn", 0)
		transform:TryChangePage("headTitle", 1)
		ClientTextUtils.setText(txtTitle, pg.getGameString("PET_VARIANT_DETAIL_TITLE"))
		ClientTextUtils.setText(txtDesc, desc)
	end

	function LuaUIUtils.renderOtherPetPanelAbilityTitle(component, data, forbidToolTip)
		local title = component:GetComponent("ObjectReference"):GetRefValue("title")
		local objectReference = title:GetComponent("ObjectReference")
		local petNameUText = objectReference:GetRefValue("petNameUText")
		local petElementUList = objectReference:GetRefValue("petElementUList")
		local numCPUText = objectReference:GetRefValue("numCPUText")
		local btnRenameUButton = objectReference:GetRefValue("btnRenameUButton")
		local btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")
		local numLevelUText = objectReference:GetRefValue("numLevelUText")
		local expSlider = objectReference:GetRefValue("expSlider")
		local typeImage = objectReference:GetRefValue("typeImage")
		local typeDesc = objectReference:GetRefValue("typeDesc")
		local name01USDFText = objectReference:GetRefValue("name01USDFText")
		local nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local starUContainer = objectReference:GetRefValue("starUContainer")
		local isChangeTipsUWidget = objectReference:GetRefValue("isChangeTipsUWidget")
		local btnIsChangeUButton = objectReference:GetRefValue("btnIsChangeUButton")

		function listTagUList.luaRenderItem(button, idx, tagData)
			LuaUIUtils.renderPetTagList(button, tagData)
			LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
		end

		local tagData = LuaUIUtils.getPetTagList(data)

		listTagUList:SetList(tagData)

		local stage = data.resonanceInfo and data.resonanceInfo.resonanceStage or 0
		local level = data.resonanceInfo and data.resonanceInfo.resonanceLevel or 0

		local function getStarItemUrl(starStage)
			return LuaUIUtils.getStarItemUrl(starStage, true)
		end

		local curStageStarUrl = getStarItemUrl(stage, true)

		starUContainer:SetUrlWithCallback(curStageStarUrl, function()
			if not data.id then
				return
			end

			local starUCont = starUContainer.content
			local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
			local m_starComp = PetResonaceStarComponent.new(starUCont)

			if m_starComp then
				m_starComp:updateAndRefresh(data.id, {
					stage = stage,
					lv = level,
					pos = UIConst.STARCOMP_POS.PETINFO
				}, forbidToolTip)
			end
		end)

		local petNameStr = data.name

		btnRenameUButton:SetActive(false)
		btnFavoriteUButton:SetActive(false)
		isChangeTipsUWidget:SetActive(false)
		LuaUIUtils.bindVariantPetDetailButton(btnIsChangeUButton, isChangeTipsUWidget, data)
		ClientTextUtils.setText(petNameUText, petNameStr)
		ClientTextUtils.setText(name01USDFText, petNameStr)
		ClientTextUtils.setText(nameShineUSDFText, petNameStr)

		function petElementUList.luaRenderItem(button, _, data1)
			LuaUIUtils.setElementButtonNew(button, data1.element, true, data.templateId)
		end

		petElementUList:SetList(data.elementNames)

		local cpMissing = data.cp == nil
		local cpValue = (data.isCatchReporting or cpMissing) and "???" or data.cp

		ClientTextUtils.setText(numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), cpValue))

		if data.gender == Const.GENDER_TYPE_MALE then
			component:TryChangePage("Gender", 0)
		elseif data.gender == Const.GENDER_TYPE_FEMALE then
			component:TryChangePage("Gender", 1)
		else
			component:TryChangePage("Gender", 2)
		end

		ClientTextUtils.setText(numLevelUText, data.level)

		local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

		expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

		if data.isShiny then
			component:TryChangePage("isFlash", 1)
		else
			component:TryChangePage("isFlash", 0)
		end

		if data.isBoss then
			component:TryChangePage("isBoss", 1)
		else
			component:TryChangePage("isBoss", 0)
		end

		if data.isVariant then
			title:TryChangePage("isChange", 1)
		else
			title:TryChangePage("isChange", 0)
		end

		LuaUIUtils.setPetFunction(typeImage, typeDesc, data.templateId)
	end

	function LuaUIUtils.renderOtherPetPanelAbilityProperty(component, data, forbidCultivateWay, setPetRatioUINodeCallback)
		local objectReference = component:GetComponent("ObjectReference"):GetRefValue("detail"):GetComponent("ObjectReference")
		local hpNum = objectReference:GetRefValue("hpNum")
		local hpTitle = objectReference:GetRefValue("hpTitle")
		local txtHPUSDFText = objectReference:GetRefValue("txtHPUSDFText")
		local atkNum = objectReference:GetRefValue("atkNum")
		local atkTitle = objectReference:GetRefValue("atkTitle")
		local txtATKUSDFText = objectReference:GetRefValue("txtATKUSDFText")
		local defNum = objectReference:GetRefValue("defNum")
		local defTitle = objectReference:GetRefValue("defTitle")
		local txtDEFUSDFText = objectReference:GetRefValue("txtDEFUSDFText")
		local regenNum = objectReference:GetRefValue("regenNum")
		local regenTitle = objectReference:GetRefValue("regenTitle")
		local txtSPDUSDFText = objectReference:GetRefValue("txtSPDUSDFText")
		local defMagNum = objectReference:GetRefValue("defMagNum")
		local defMagTitle = objectReference:GetRefValue("defMagTitle")
		local txtSDEFUSDFText = objectReference:GetRefValue("txtSDEFUSDFText")
		local atkMagNum = objectReference:GetRefValue("atkMagNum")
		local atkMagTitle = objectReference:GetRefValue("atkMagTitle")
		local txtSATKUSDFText = objectReference:GetRefValue("txtSATKUSDFText")
		local hpCmp = objectReference:GetRefValue("hpCmp")
		local atkCmp = objectReference:GetRefValue("atkCmp")
		local defCmp = objectReference:GetRefValue("defCmp")
		local regenCmp = objectReference:GetRefValue("regenCmp")
		local defMagCmp = objectReference:GetRefValue("defMagCmp")
		local atkMagCmp = objectReference:GetRefValue("atkMagCmp")
		local hpLevelCmp = objectReference:GetRefValue("hpLevelCmp")
		local atkLevelCmp = objectReference:GetRefValue("atkLevelCmp")
		local defLevelCmp = objectReference:GetRefValue("defLevelCmp")
		local regenLevelCmp = objectReference:GetRefValue("regenLevelCmp")
		local defMagLevelCmp = objectReference:GetRefValue("defMagLevelCmp")
		local atkMagLevelCmp = objectReference:GetRefValue("atkMagLevelCmp")
		local hpLv = objectReference:GetRefValue("hpLv")
		local atkLv = objectReference:GetRefValue("atkLv")
		local defLv = objectReference:GetRefValue("defLv")
		local regenLv = objectReference:GetRefValue("regenLv")
		local defMagLv = objectReference:GetRefValue("defMagLv")
		local atkMagLv = objectReference:GetRefValue("atkMagLv")
		local defaultRadar = objectReference:GetRefValue("defaultRadar")
		local addedRadar = objectReference:GetRefValue("addedRadar")
		local root = objectReference:GetRefValue("root")
		local ratingStr = objectReference:GetRefValue("ratingStr")
		local btnSwitchMaxUButton = objectReference:GetRefValue("btnSwitchMaxUButton")
		local btnTalentUButton = objectReference:GetRefValue("btnTalentUButton")
		local accessListUList = objectReference:GetRefValue("accessListUList")
		local btnRareTraitUButton = objectReference:GetRefValue("btnRareTraitUButton")
		local propCmpGroup = {
			hpCmp,
			atkCmp,
			defCmp,
			regenCmp,
			defMagCmp,
			atkMagCmp
		}
		local propNumGroup = {
			hpNum,
			atkNum,
			defNum,
			regenNum,
			defMagNum,
			atkMagNum
		}
		local propTitleGroup = {
			hpTitle,
			atkTitle,
			defTitle,
			regenTitle,
			defMagTitle,
			atkMagTitle
		}
		local propTitle2Group = {
			txtHPUSDFText,
			txtATKUSDFText,
			txtDEFUSDFText,
			txtSPDUSDFText,
			txtSDEFUSDFText,
			txtSATKUSDFText
		}
		local propLevelGroup = {
			hpLv,
			atkLv,
			defLv,
			regenLv,
			defMagLv,
			atkMagLv
		}
		local propLevelCmpGroup = {
			hpLevelCmp,
			atkLevelCmp,
			defLevelCmp,
			regenLevelCmp,
			defMagLevelCmp,
			atkMagLevelCmp
		}
		local baseProperty = data.basePropertyList
		local templateId = data.templateId
		local petData = PetData[templateId]
		local recommend = petData.recommend_attr
		local featureIcon = objectReference:GetRefValue("featureIcon")
		local btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")
		local newRatioNodeUComp = objectReference:GetRefValue("newRatioNodeUComp")

		if NotNil(btnDetailUButton) then
			function btnDetailUButton.luaClick()
				pg.global.ui:open(UIConst.UI_ID_PET_PROPERTY, {
					curPetId = data.id
				})
			end
		end

		local isUnverified = data.hasCompleteBaseProperty == false or data.isCatchReporting or data.isCatchReportingStatus
		local hasQualificationRating = data.hasQualificationRating ~= false

		if NotNil(ratingStr) then
			ratingStr:SetActive(hasQualificationRating and not isUnverified)
		end

		root:TryChangePage("NotVerified", isUnverified and 1 or 0)

		for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
			local propertyNameId = PetDetailPropertyData[i][1].propName

			ClientTextUtils.setTextWithId(propTitleGroup[i], propertyNameId)
			ClientTextUtils.setTextWithId(propTitle2Group[i], propertyNameId)
		end

		if isUnverified then
			if setPetRatioUINodeCallback and NotNil(newRatioNodeUComp) then
				setPetRatioUINodeCallback(newRatioNodeUComp)
			end

			return
		end

		local defaultRatioGroup = {}
		local addedRatioGroup = {}
		local isTrained = 0
		local propLevels = pg.game.petManage:getPetPropLevels(data)

		for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
			local propLevel = propLevels and propLevels[i] or {}
			local baseAndActiveTotalLv = propLevel and propLevel.baseAndActiveTotalLv or 0
			local complexBaseLv = propLevel and propLevel.complexBaseLv or 0
			local max = propLevel and propLevel.max or 1
			local learnt = propLevel and propLevel.learnt or 0
			local isMax = propLevel and propLevel.isMax or false
			local val = math.ceil(propLevel.propDisplayVal)

			ClientTextUtils.setText(propNumGroup[i], val)
			ClientTextUtils.setText(propLevelGroup[i], baseProperty[i].indLv)

			propCmpGroup[i].enabledTooltip = false

			if learnt > 0 then
				propCmpGroup[i]:TryChangePage("State", 1)
				propLevelCmpGroup[i]:TryChangePage("State", 1)
			else
				propCmpGroup[i]:TryChangePage("State", 0)
				propLevelCmpGroup[i]:TryChangePage("State", 0)
			end

			if LuaUIUtils.tableContains(recommend, i) then
				propCmpGroup[i]:TryChangePage("GoodState", 1)
				propLevelCmpGroup[i]:TryChangePage("Updated", data.propertyEnhanced and 1 or 0)

				if data.propertyEnhanced then
					propLevelCmpGroup[i]:TryChangePage("State", 1)
				end
			else
				propCmpGroup[i]:TryChangePage("GoodState", 0)
				propLevelCmpGroup[i]:TryChangePage("Updated", 0)
			end

			if isMax then
				propCmpGroup[i]:TryChangePage("State", 2)
				propLevelCmpGroup[i]:TryChangePage("State", 2)
			end

			defaultRatioGroup[i] = complexBaseLv / max
			addedRatioGroup[i] = baseAndActiveTotalLv / max

			if learnt > 0 then
				isTrained = isTrained + 1
			end
		end

		defaultRadar:SetSixProps(defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		addedRadar:SetSixProps(addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)

		if hasQualificationRating then
			root:TryChangePage("Quality", data.pageIndex)

			if NotNil(ratingStr) then
				ClientTextUtils.setText(ratingStr, pg.getGameString(data.ratingStribng))
			end
		end

		local featureInfo = PetCharacterData[data.controlFeatureId]

		btnRareTraitUButton.gameObject:SetActiveEx(featureInfo and featureInfo.rare and featureInfo.rare == 1)
		btnTalentUButton:SetActive(false)

		function accessListUList.luaRenderItem(button, _, data1)
			if data1.empty then
				return
			end

			local objRef = button:GetComponent("ObjectReference")
			local iconUImage = objRef:GetRefValue("iconUImage")
			local rayBoxUWidget = objRef:GetRefValue("rayBoxUWidget")

			iconUImage.url = data1.icon

			rayBoxUWidget.gameObject:SetActiveEx(false)
			button:TryChangePage("Quality", data1.quality)
		end

		accessListUList:SetList(data.breedTalent)

		if btnDetailUButton then
			btnDetailUButton:SetActive(false)
		end

		if btnSwitchMaxUButton then
			btnSwitchMaxUButton:SetActive(false)
		end

		if data.featureInfo then
			btnRareTraitUButton.gameObject:SetActiveEx(true)

			function btnRareTraitUButton.luaTooltipPopup(_, flag)
				btnRareTraitUButton.isSelected = flag

				btnRareTraitUButton:TryChangePage("button", flag and 5 or 0)
			end

			LuaUIUtils.setRenderFeatureToolTips(btnRareTraitUButton, data.featureInfo)

			featureIcon.url = data.featureInfo.icon
		else
			btnRareTraitUButton.gameObject:SetActiveEx(false)
		end

		if setPetRatioUINodeCallback and NotNil(newRatioNodeUComp) then
			setPetRatioUINodeCallback(newRatioNodeUComp)
		end
	end

	function LuaUIUtils.setPetFunction(typeImage, typeDesc, templateId)
		if not typeImage or not typeDesc or not templateId then
			return
		end

		local petType = PetData[templateId].functionId

		typeImage.url = PetConfigData.petFunctionIcon[petType]

		ClientTextUtils.setText(typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	end

	function LuaUIUtils.formatHomeWishingStarOutput(value)
		if type(value) ~= "number" then
			return "--"
		end

		return string.format("%.0f/%s", value, pg.getGameString("DAY"))
	end

	function LuaUIUtils.getHomeWishingStarDisplayOutputInfo(petInfo)
		if not Utils.isTable(petInfo) or not PetData[petInfo.templateId] then
			return {
				hasData = false
			}
		end

		local baseOutput, output, appearanceInfos = HomeLandUtils.calcHomeVoucherPetOutputPerDay(petInfo)

		return {
			hasData = true,
			output = output,
			baseOutput = baseOutput,
			appearanceInfos = appearanceInfos
		}
	end

	function LuaUIUtils.renderHomeWishingStarTooltip(popUp, petInfo)
		local objectReference = popUp.transform:GetComponent("ObjectReference")
		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
		local txtSpeedUSDFText = objectReference:GetRefValue("txtSpeedUSDFText")
		local txtBaseUSDFText = objectReference:GetRefValue("txtBaseUSDFText")
		local txtBaseNumUSDFText = objectReference:GetRefValue("txtBaseNumUSDFText")
		local listAppearanceUList = objectReference:GetRefValue("listAppearanceUList")
		local outputInfo = LuaUIUtils.getHomeWishingStarDisplayOutputInfo(petInfo)
		local speedText = "--"
		local baseOutputText = "--"

		if outputInfo.hasData then
			speedText = LuaUIUtils.formatHomeWishingStarOutput(outputInfo.output)
			baseOutputText = LuaUIUtils.formatHomeWishingStarOutput(outputInfo.baseOutput)
		end

		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("HOME_PET_STAR_OUTPUT_TIPS"))
		ClientTextUtils.setText(txtSpeedUSDFText, speedText)
		ClientTextUtils.setText(txtBaseUSDFText, pg.getGameString("HOME_PET_STAR_OUTPUT_SPEED_BASIC"))
		ClientTextUtils.setText(txtBaseNumUSDFText, baseOutputText)

		local appearanceList = LuaUIUtils.getHomeVoucherBonusAppearanceList(petInfo, outputInfo.appearanceInfos)

		function listAppearanceUList.luaRenderItem(button, _, itemData)
			local itemObjectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = itemObjectReference:GetRefValue("txtNameUSDFText")
			local formUContainer = itemObjectReference:GetRefValue("formUContainer")
			local txtNumUSDFText = itemObjectReference:GetRefValue("txtNumUSDFText")
			local multiplierText = "--"

			if itemData.multiplier ~= nil then
				multiplierText = "×" .. tostring(itemData.multiplier)
			end

			ClientTextUtils.setText(txtNameUSDFText, itemData.name)
			ClientTextUtils.setText(txtNumUSDFText, multiplierText)
			formUContainer:SetUrlWithCallback(itemData.labelUrl, function(content)
				if not content or button.dataFromUList ~= itemData then
					return
				end

				content.enabledTooltip = false

				if itemData.tagData then
					LuaUIUtils.renderPetTagList(content, itemData.tagData)
				end
			end)

			button.luaClick = nil
		end

		listAppearanceUList:SetActive(false)

		if #appearanceList > 0 then
			listAppearanceUList:SetList(appearanceList)
			listAppearanceUList:SetActive(true)
		else
			listAppearanceUList:SetList(EMPTY_TABLE)
		end

		local tipsULayoutBox = objectReference:GetRefValue("tipsULayoutBox")

		tipsULayoutBox:ForceRebuildLayoutImmediate()
	end

	function LuaUIUtils.refreshHomeWishingStarOutput(panelObjectReference, petInfo)
		local wishingStarUComponent = panelObjectReference:GetRefValue("wishingStarUComponent")
		local showWishingStarOutput = not HomeLandUtils.isHomePetInProduceArea(pg.space, petInfo and petInfo.id)

		wishingStarUComponent:SetActive(showWishingStarOutput)

		if not showWishingStarOutput then
			return false
		end

		local txtNumWishingStarUSDFText = panelObjectReference:GetRefValue("txtNumWishingStarUSDFText")
		local txtTitleWishingStarUSDFText = panelObjectReference:GetRefValue("txtTitleWishingStarUSDFText")
		local outputInfo = LuaUIUtils.getHomeWishingStarDisplayOutputInfo(petInfo)
		local outputText = outputInfo.hasData and LuaUIUtils.formatHomeWishingStarOutput(outputInfo.output) or "--"

		ClientTextUtils.setText(txtTitleWishingStarUSDFText, pg.getGameString("HOME_PET_STAR_OUTPUT_SPEED_TIPS"))
		ClientTextUtils.setText(txtNumWishingStarUSDFText, outputText)

		return true
	end

	function LuaUIUtils.bindHomeWishingStarOutput(panelObjectReference, petInfo)
		if not LuaUIUtils.refreshHomeWishingStarOutput(panelObjectReference, petInfo) then
			return nil
		end

		local btnWishingStarUButton = panelObjectReference:GetRefValue("btnWishingStarUButton")

		btnWishingStarUButton.enabledTooltip = true

		function btnWishingStarUButton.luaRenderTooltip(_, popUp)
			LuaUIUtils.renderHomeWishingStarTooltip(popUp, petInfo)
		end

		return btnWishingStarUButton
	end

	function LuaUIUtils.renderOtherPetInfoPanel(component, data)
		local panelInfoUContainerObjectReference = component.transform:GetComponent("ObjectReference")
		local petDesc = panelInfoUContainerObjectReference:GetRefValue("petDesc")
		local beenText = panelInfoUContainerObjectReference:GetRefValue("beenText")
		local infoPetName = panelInfoUContainerObjectReference:GetRefValue("infoPetName")
		local infoPetNameExtra = panelInfoUContainerObjectReference:GetRefValue("infoPetNameExtra")
		local txtDetailUSDFText = panelInfoUContainerObjectReference:GetRefValue("txtDetailUSDFText")
		local rawImageRawImagePro = panelInfoUContainerObjectReference:GetRefValue("rawImageRawImagePro")
		local uINodePetPanelInfoUComponent = panelInfoUContainerObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
		local accessListUListHome = panelInfoUContainerObjectReference:GetRefValue("accessListUList")
		local abilityListUList = panelInfoUContainerObjectReference:GetRefValue("abilityListUList")
		local btnPetManualUButton = panelInfoUContainerObjectReference:GetRefValue("btnPetManualUButton")
		local textUSDFText = panelInfoUContainerObjectReference:GetRefValue("textUSDFText")
		local sourceUWidget = panelInfoUContainerObjectReference:GetRefValue("sourceUWidget")
		local txtSourceUBaseText = panelInfoUContainerObjectReference:GetRefValue("txtSourceUBaseText")
		local txtNumLiveUSDFText = panelInfoUContainerObjectReference:GetRefValue("txtNumLiveUSDFText")
		local txtTitleLiveUSDFText = panelInfoUContainerObjectReference:GetRefValue("txtTitleLiveUSDFText")
		local btnLiveUButton = panelInfoUContainerObjectReference:GetRefValue("btnLiveUButton")

		component:TryChangePage("State", 1)

		local petCubeItemId = data.cubeItemId

		LuaUIUtils.refreshPetPanelInfoCubeAndBackground(petCubeItemId, panelInfoUContainerObjectReference)

		local showSource = not string.isNilOrEmpty(data.sourceDesc)

		sourceUWidget:SetActive(showSource)

		if showSource then
			ClientTextUtils.setText(txtSourceUBaseText, data.sourceDesc)
		end

		ClientTextUtils.setText(petDesc.content, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
		ClientTextUtils.setText(txtDetailUSDFText, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
		ClientTextUtils.setText(beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - data.time) / 1000 / 3600 / 24)))

		local displayBookNumberText = "No.???"

		if data.bookNum and data.bookNum < 9000 then
			local prototypeData = PetPrototypeData[data.templateId]
			local baseResearchData = prototypeData and PetResearchContentData[prototypeData.baseFormPet]
			local formResearchData = PetResearchContentData[data.templateId]
			local displayCountryId = formResearchData and formResearchData.countryId or baseResearchData and baseResearchData.countryId
			local displayNumber, isCustomNumber = LuaUIUtils.getPetDisplayNumber(displayCountryId, baseResearchData and baseResearchData.numberTxt, baseResearchData and baseResearchData.number)

			displayNumber = displayNumber ~= "" and displayNumber or data.bookNum
			displayBookNumberText = isCustomNumber and displayNumber or string.format("No.%s", displayNumber)
		end

		ClientTextUtils.setText(textUSDFText, displayBookNumberText)
		ClientTextUtils.setText(txtNumLiveUSDFText, PetData[data.templateId].comfortValue or 0)
		ClientTextUtils.setText(txtTitleLiveUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE") .. ":")

		function btnLiveUButton.luaRenderTooltip(btn, com)
			local objectReference = com.transform:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_COMFORT_TIP"))
		end

		local wishingStarUComponent = panelInfoUContainerObjectReference:GetRefValue("wishingStarUComponent")
		local btnWishingStarUButton = panelInfoUContainerObjectReference:GetRefValue("btnWishingStarUButton")

		wishingStarUComponent:SetActive(false)

		btnWishingStarUButton.luaRenderTooltip = nil

		local formName = LuaUIUtils.getPetFormName(data.templateId)

		ClientTextUtils.setText(infoPetName, formName)

		if infoPetNameExtra then
			ClientTextUtils.setText(infoPetNameExtra, data.name)
		end

		if data.isShiny then
			uINodePetPanelInfoUComponent:TryChangePage("isFlash", 1)
		else
			uINodePetPanelInfoUComponent:TryChangePage("isFlash", 0)
		end

		if data.isBoss then
			uINodePetPanelInfoUComponent:TryChangePage("isBoss", 1)
		else
			uINodePetPanelInfoUComponent:TryChangePage("isBoss", 0)
		end

		function accessListUListHome.luaRenderItem(button, _, itemData)
			if itemData.empty then
				return
			end

			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

			iconUImage.url = itemData.icon

			rayBoxUWidget.gameObject:SetActiveEx(false)
			button:TryChangePage("Quality", itemData.quality)
		end

		accessListUListHome:SetList(data.breedTalent)

		function abilityListUList.luaRenderItem(button, _, itemData)
			LuaUIUtils.renderHomeAbility(button, itemData.id, itemData.level)
		end

		local function getHomeAbilityData()
			local homeAbility = PetData[data.templateId].homeAbility
			local abilityData = {}

			if not homeAbility then
				return abilityData
			end

			for id, ability in pairs(homeAbility) do
				local data = {}

				data.id = id
				data.level = ability

				table.insert(abilityData, data)
			end

			return abilityData
		end

		abilityListUList:SetList(getHomeAbilityData())
	end

	function LuaUIUtils.getPetFormName(templateId)
		local formTypeData = Utils.getPetFormTypeDataByTemplateId(templateId)

		return formTypeData and pg.getLocalizationText(formTypeData.name) or pg.getGameString("BASIC_FORM_NAME")
	end

	function LuaUIUtils.getPetFormNameByPrototypeId(petPrototypeId)
		local formTypeData = Utils.getPetFormTypeDataByPrototypeId(petPrototypeId)

		return formTypeData and pg.getLocalizationText(formTypeData.name) or pg.getGameString("BASIC_FORM_NAME")
	end

	function LuaUIUtils.renderRTHead(uRawImage, templateId, label, rotation)
		local headSceneRes = AddressDataConst.PET_HEAD_SCENE
		local headScene = pg.game.uiScene:getScene("PetSimpleScene")

		if not headScene then
			headScene = pg.game.uiScene:getUISceneInst("PetSimpleScene", headSceneRes, nil, {
				templateId = templateId
			})

			headScene:setTemplateId(templateId, label, rotation)

			if headScene:checkLoadStateIsNone() then
				headScene:startLoad(function(succeed)
					if succeed then
						headScene:refreshEntity()
						headScene:setRawImageProRef(uRawImage)
						pg.game.uiScene:switchToScene("PetSimpleScene")
					end
				end)
			end
		else
			headScene:setTemplateId(templateId, label, rotation)
			headScene:refreshEntity()
			headScene:setRawImageProRef(uRawImage)
		end

		return headScene
	end

	function LuaUIUtils.renderHomePetHead(button, data, dispatchState, extraParam)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnCancelWorkingUContainer = objectReference:GetRefValue("btnCancelWorkingUContainer")
		local iconFavUContainer = objectReference:GetRefValue("iconFavUContainer")
		local petExchangeUButton = objectReference:GetRefValue("petExchangeUButton")
		local iconWorkStateUImage = objectReference:GetRefValue("iconWorkStateUImage")
		local panelHomeworkUButton = objectReference:GetRefValue("panelHomeworkUButton")
		local numUSDFText = objectReference:GetRefValue("numUSDFText")
		local abilityUWidget = objectReference:GetRefValue("abilityUWidget")
		local listAbilityUList = objectReference:GetRefValue("listAbilityUList")
		local petCharUButton = objectReference:GetRefValue("petCharUButton")
		local petCharacterUWidget = objectReference:GetRefValue("petCharacterUWidget")
		local petIdRectTransform = objectReference:GetRefValue("petIdRectTransform")

		petIdRectTransform.name = data.id

		button:TryChangePage("state", 0)
		petCharUButton:SetActive(false)

		iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

		petCharacterUWidget:SetActive(false)

		local showAppearanceTags = extraParam and extraParam.showAppearanceTags
		local hideWorkState = extraParam and extraParam.hideWorkState
		local showEventState = not hideWorkState or ToBool(extraParam and extraParam.showEventState)

		btnCancelWorkingUContainer:SetActive(not hideWorkState and ToBool(data.isShowCancel))

		local isWorking = not hideWorkState and data.isWorking

		if isWorking then
			abilityUWidget:SetActive(false)
			iconWorkStateUImage:SetActive(true)
			panelHomeworkUButton:SetActive(true)

			local workRate = Utils.calcWorkRate(data.facilityType, data.opId, data.workload, data.facilityInfo.formulaId)

			if workRate then
				if workRate >= 1 then
					panelHomeworkUButton:TryChangePage("WorkRatio", 1)
				else
					panelHomeworkUButton:TryChangePage("WorkRatio", 2)
				end

				ClientTextUtils.setText(numUSDFText, string.format("%s%%", math.floor(workRate * 100)))
			else
				panelHomeworkUButton:TryChangePage("WorkRatio", 0)
			end

			if data.fitPersonality and data.fitPersonality ~= 0 then
				petCharacterUWidget:SetActive(true)
				LuaUIUtils.renderTalentItem(petExchangeUButton, data.fitPersonality)
			end

			local opInfo = HomelandOperateData[data.opId]

			if opInfo then
				local homeAbility = opInfo.homeAbility

				if homeAbility then
					local petHomeAbilities = (PetData[data.templateId] or EMPTY_TABLE).homeAbility or {}
					local petAbilityLevel = petHomeAbilities[homeAbility[1]]

					if petAbilityLevel then
						LuaUIUtils.renderHomeAbility(petCharUButton, homeAbility[1], petAbilityLevel)
						petCharUButton:SetActive(true)
					else
						petCharUButton:SetActive(false)
					end
				end
			end
		else
			petCharUButton:SetActive(false)

			if not hideWorkState and data.opUrl or showEventState and data.eventUrl then
				if not hideWorkState and data.opUrl then
					iconWorkStateUImage.url = data.opUrl
				else
					iconWorkStateUImage.url = data.eventUrl
				end

				iconWorkStateUImage:SetActive(true)
			else
				iconWorkStateUImage:SetActive(false)
			end

			abilityUWidget:SetActive(true)
			panelHomeworkUButton:SetActive(false)

			local originalPoolMode = listAbilityUList.poolMode

			if button.replicaSelf then
				listAbilityUList.poolMode = CS.XGUI.EPoolMode.Default
			end

			if showAppearanceTags then
				function listAbilityUList.luaRenderItem(b, i, d)
					LuaUIUtils.renderPetTagList(b, d.tagData)
				end

				local appearanceData = {}

				for _, appearanceInfo in ipairs(LuaUIUtils.getHomeVoucherBonusAppearanceList(data)) do
					appearanceData[#appearanceData + 1] = {
						tIndex = not string.isNilOrEmpty(appearanceInfo.tagData.iconSmall) and 1 or appearanceInfo.tagData.tIndex + 1,
						tagData = appearanceInfo.tagData
					}
				end

				listAbilityUList:SetList(appearanceData)
				abilityUWidget:SetActive(#appearanceData > 0)
			else
				function listAbilityUList.luaRenderItem(b, i, d)
					LuaUIUtils.renderHomeAbility(b, d.id, d.level)
				end

				local homeAbility = (PetData[data.templateId] or EMPTY_TABLE).homeAbility or {}
				local abilityData = {}

				for id, ability in pairs(homeAbility) do
					local d = {}

					d.id = id
					d.level = ability
					abilityData[#abilityData + 1] = d
				end

				listAbilityUList:SetList(abilityData)
			end

			if button.replicaSelf then
				listAbilityUList.poolMode = originalPoolMode
			end
		end

		if extraParam and extraParam.closeAbility then
			abilityUWidget:SetActive(false)
		end

		if extraParam and extraParam.isForbidToolTips then
			button.enabledTooltip = false
		end

		local delegationUWidget = objectReference:GetRefValue("delegationUWidget")
		local receiveUWidget = objectReference:GetRefValue("receiveUWidget")
		local delegationUContainer = objectReference:GetRefValue("delegationUContainer")
		local receiveUContainer = objectReference:GetRefValue("receiveUContainer")

		if delegationUWidget then
			local isShow = dispatchState and dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching or false

			if isShow then
				delegationUWidget:SetActive(true)

				if not delegationUContainer:CheckURLLoaded() then
					delegationUContainer:LoadDefaultUrlManually()
				end
			else
				delegationUWidget:SetActive(false)
			end
		end

		if receiveUWidget then
			local isShow = dispatchState and dispatchState == UIConst.HOME_CAMP_DISPATCH_STATE.Finished or false

			if isShow then
				receiveUWidget:SetActive(true)

				if not receiveUContainer:CheckURLLoaded() then
					receiveUContainer:LoadDefaultUrlManually()
				end
			else
				receiveUWidget:SetActive(false)
			end
		end
	end

	function LuaUIUtils.renderPetHeadRound(button, data, selectedIndex)
		local objectReference = button:GetComponent("ObjectReference")
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local numCPUText = objectReference:GetRefValue("numCPUSDFText")
		local singleElement = objectReference:GetRefValue("singleElement")
		local doubleElement1 = objectReference:GetRefValue("doubleElement1")
		local doubleElement2 = objectReference:GetRefValue("doubleElement2")
		local addonUComponent = objectReference:GetRefValue("addonUComponent")
		local listCharUList = objectReference:GetRefValue("listCharUList")

		if data.isEmpty then
			button:TryChangePage("state", 2)

			iconUImage.url = nil

			addonUComponent:TryChangePage("eveState", 0)
			LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, false)
			addonUComponent:TryChangePage("favState", 0)

			petIdDisplay.gameObject.name = "Null"

			addonUComponent:TryChangePage("hasNoExplore", 1)
			addonUComponent:TryChangePage("DetailState", 0)
			addonUComponent:TryChangePage("ShowElementIcon", 0)
			addonUComponent:TryChangePage("number", 0)
			addonUComponent:TryChangePage("batchRelease", 0)

			return
		end

		button:TryChangePage("state", 0)
		iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
			return
		end)

		local pet = pg.me:getPetInfo(data.id)

		if pet and pet:isCatchReporting() then
			ClientTextUtils.setText(numCPUText, "???")
		else
			ClientTextUtils.setText(numCPUText, data.cp or "")
		end

		addonUComponent:TryChangePage("eveState", data.canEvolve and 1 or 0)

		local shinyStyle = data.shinyStyle or pet and pet.shinyStyle or 0

		LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.isShiny, shinyStyle)

		local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

		PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)
		addonUComponent:TryChangePage("favState", data.isFavorite and 1 or 0)
		button:TryChangePage("Dead", data.hpRatio <= 0 and 1 or 0)

		petIdDisplay.gameObject.name = data.id

		if (data.highestExploreSkillLevel or 0) <= 0 then
			addonUComponent:TryChangePage("hasNoExplore", 1)
		else
			addonUComponent:TryChangePage("hasNoExplore", 0)
		end

		if #data.elementNames <= 0 then
			addonUComponent:TryChangePage("DetailState", 0)
		elseif #data.elementNames == 1 then
			addonUComponent:TryChangePage("DetailState", 1)
			LuaUIUtils.setElementButtonNew(singleElement, data.elementNames[1].element)
		else
			addonUComponent:TryChangePage("DetailState", 2)
			LuaUIUtils.setElementButtonNew(doubleElement1, data.elementNames[1].element)
			LuaUIUtils.setElementButtonNew(doubleElement2, data.elementNames[2].element)
		end

		if selectedIndex then
			addonUComponent:TryChangePage("number", selectedIndex)
		end

		local tempExploreLevelAllData = {}

		for k, v in pairs(data.exploreSkillsLevel or EMPTY_TABLE) do
			local temp = {
				exploreName = k,
				exploreLevel = v
			}

			tempExploreLevelAllData[#tempExploreLevelAllData + 1] = temp
		end

		if listCharUList then
			function listCharUList.luaRenderItem(button1, _, data1)
				button1:TryChangePage("PetChar", AbilityConst.SPECIFIC_ABILITY_NAME_2_INDEX[data1.exploreName])
				button1:TryChangePage("quality", data1.exploreLevel - 1)
			end

			listCharUList:SetList(tempExploreLevelAllData)
		end
	end

	function LuaUIUtils.getPetCrownState(propLevels)
		if not propLevels then
			return UIConst.PET_CROWN_STATE.NONE
		end

		local maxPropNum = 0

		for propId = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
			local propLevel = propLevels[propId]

			if propLevel and propLevel.isMax then
				maxPropNum = maxPropNum + 1
			end
		end

		if maxPropNum >= Const.BASE_PROPERTY_CNT then
			return UIConst.PET_CROWN_STATE.GOLD
		end

		local silverCrownNeedMaxNum = tonumber(SysConfigData.silverCrownNeedMaxNum) or 3

		if silverCrownNeedMaxNum > 0 and silverCrownNeedMaxNum <= maxPropNum then
			return UIConst.PET_CROWN_STATE.SILVER
		end

		return UIConst.PET_CROWN_STATE.NONE
	end

	function LuaUIUtils.renderPetHead(button, data, extraData)
		if data.isEmpty then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local iconHomeUImage = objectReference:GetRefValue("iconHomeUImage")
		local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")
		local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
		local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
		local iconFavUContainer = objectReference:GetRefValue("iconFavUContainer")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		panelCPUContainer:LoadDefaultUrlManually()
		panelCharListUContainer:LoadDefaultUrlManually()
		panelCharListUContainer.content.gameObject:SetActiveEx(false)
		iconFavUContainer:LoadDefaultUrlManually()
		iconFavUContainer.content.gameObject:SetActiveEx(false)

		local listCharUList = panelCharListUContainer.content:GetComponent("UList")
		local objectReference1 = panelCPUContainer.content:GetComponent("ObjectReference")
		local numCPUText = objectReference1:GetRefValue("numCPUSDFText")
		local singleElement = objectReference1:GetRefValue("singleElement")
		local doubleElement1 = objectReference1:GetRefValue("doubleElement1")
		local doubleElement2 = objectReference1:GetRefValue("doubleElement2")
		local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")
		local umbralUContainer = objectReference:GetRefValue("umbralUContainer")
		local crownUComponent = objectReference:GetRefValue("crownUComponent")
		local rainBowUContainer = objectReference:GetRefValue("rainBowUContainer")
		local pet = pg.me:getPetInfo(data.id)

		if crownUComponent then
			local crownState = UIConst.PET_CROWN_STATE.NONE

			if pet and not pet:isCatchReporting() then
				local propLevels = pg.game.petManage:getPetPropLevels(pet)

				crownState = LuaUIUtils.getPetCrownState(propLevels)
			end

			crownUComponent:TryChangePage("Crown", crownState)
		end

		local flashBgUContainer = objectReference:GetRefValue("flashBgUContainer")
		local flashFrameUContainer = objectReference:GetRefValue("flashFrameUContainer")

		if rainBowUContainer then
			local isRainbow = data.isRainbow == true

			rainBowUContainer:SetActive(isRainbow)

			if isRainbow and not rainBowUContainer:CheckURLLoaded() then
				rainBowUContainer:LoadDefaultUrlManually()
			end
		end

		button:TryChangePage("state", 0)
		txtNameUSDFText:SetActive(false)

		local function setIconFunc()
			if NotNil(iconUImage) then
				iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), nil)
			end
		end

		if extraData and extraData.isShowIconAni then
			iconUImage.gameObject:SetActiveEx(false)

			LuaUIUtils.m_delayShowPetIconTimers = LuaUIUtils.m_delayShowPetIconTimers or {}
			LuaUIUtils.m_delayShowPetIconTimerSeq = (LuaUIUtils.m_delayShowPetIconTimerSeq or 0) + 1

			local timerKey = data.id .. "_" .. LuaUIUtils.m_delayShowPetIconTimerSeq

			LuaUIUtils.m_delayShowPetIconTimers[timerKey] = TimerManager.addTimer(0.01, function()
				LuaUIUtils.m_delayShowPetIconTimers[timerKey] = nil

				if NotNil(iconUImage and iconUImage.gameObject) then
					iconUImage.gameObject:SetActiveEx(true)
					setIconFunc()
				end
			end)
		else
			setIconFunc()
		end

		if pet and pet:isCatchReporting() then
			ClientTextUtils.setText(numCPUText, "???")
		else
			ClientTextUtils.setText(numCPUText, data.cp or "")
		end

		LuaUIUtils.m_renderPetHeadEvolveArrow(iconEvolveUImage, data, extraData and extraData.forceHideEvo)

		if data.isShiny then
			local shinyStyle = data.shinyStyle or pet and pet.shinyStyle or 0

			LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, true, shinyStyle)
		else
			LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, false)
		end

		if data.isDark then
			umbralUContainer:SetActive(true)
			umbralUContainer:LoadDefaultUrlManually()
		else
			umbralUContainer:SetActive(false)
		end

		local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

		PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)

		if data.isFavorite then
			iconFavUContainer.content.gameObject:SetActiveEx(true)
			iconFavUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.User3)
		end

		button:TryChangePage("Dead", data.hpRatio <= 0 and 1 or 0)

		petIdDisplay.gameObject.name = data.id

		if #data.elementNames <= 0 then
			panelCPUContainer.content.gameObject:SetActiveEx(false)
		elseif #data.elementNames == 1 then
			panelCPUContainer.content.gameObject:SetActiveEx(true)
			panelCPUContainer.content:TryChangePage("DetailState", 0)
			LuaUIUtils.setElementButtonNew(singleElement, data.elementNames[1].element)
		else
			panelCPUContainer.content.gameObject:SetActiveEx(true)
			panelCPUContainer.content:TryChangePage("DetailState", 1)
			LuaUIUtils.setElementButtonNew(doubleElement1, data.elementNames[1].element)
			LuaUIUtils.setElementButtonNew(doubleElement2, data.elementNames[2].element)
		end

		if iconHomeUImage then
			iconHomeUImage:SetActive(data.isPutInHomeland and true or false)
		end

		local tempExploreLevelAllData = {}

		for k, v in pairs(data.exploreSkillsLevel or EMPTY_TABLE) do
			local temp = {
				exploreName = k,
				exploreLevel = v
			}

			tempExploreLevelAllData[#tempExploreLevelAllData + 1] = temp
		end

		if listCharUList then
			function listCharUList.luaRenderItem(button1, _, data1)
				button1:TryChangePage("PetChar", AbilityConst.SPECIFIC_ABILITY_NAME_2_INDEX[data1.exploreName])
				button1:TryChangePage("quality", data1.exploreLevel - 1)
			end

			listCharUList:SetList(tempExploreLevelAllData)
		end
	end

	function LuaUIUtils.renderPetHeadFlashBgAndFrame(petHeadObjectReference, isShiny, shinyStyle)
		local flashBgUContainer = petHeadObjectReference:GetRefValue("flashBgUContainer")
		local flashFrameUContainer = petHeadObjectReference:GetRefValue("flashFrameUContainer")
		local flashParUContainer = petHeadObjectReference:GetRefValue("flashParUContainer")

		if not flashBgUContainer or not flashFrameUContainer then
			return
		end

		if isShiny then
			flashBgUContainer:SetActive(true)
			flashFrameUContainer:SetActive(true)

			local flashParUrl

			if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
				flashBgUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_BG_BLACK)
				flashFrameUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_FRAME_BLACK)

				flashParUrl = AddressDataConst.UI_PET_HEAD_FLASH_PAR_BLACK
			elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
				flashBgUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_BG_WHITE)
				flashFrameUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_FRAME_WHITE)

				flashParUrl = AddressDataConst.UI_PET_HEAD_FLASH_PAR_WHITE
			else
				flashBgUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_BG)
				flashFrameUContainer:SetUrlWithCallback(AddressDataConst.UI_PET_HEAD_FLASH_FRAME)

				flashParUrl = AddressDataConst.UI_PET_HEAD_FLASH_PAR
			end

			if flashParUContainer then
				flashParUContainer:SetActive(true)
				flashParUContainer:SetUrlWithCallback(flashParUrl)
			end
		else
			flashBgUContainer:SetActive(false)
			flashFrameUContainer:SetActive(false)

			if flashParUContainer then
				flashParUContainer:SetActive(false)
			end
		end
	end

	function LuaUIUtils.renderPetSlotBarItem(button, data)
		local objectReference = button:GetComponent("ObjectReference")
		local nameUText = objectReference:GetRefValue("nameUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local elementsUList = objectReference:GetRefValue("elementsUList")

		if data.customName and data.customName ~= "" then
			ClientTextUtils.setText(nameUText, data.customName)
		else
			ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		end

		if data.isShiny then
			button:TryChangePage("isFlash", 1)
		elseif data.isBoss then
			button:TryChangePage("isFlash", 2)
		else
			button:TryChangePage("isFlash", 0)
		end

		if data.gender == Const.GENDER_TYPE_MALE then
			button:TryChangePage("Gender", 0)
		elseif data.gender == Const.GENDER_TYPE_FEMALE then
			button:TryChangePage("Gender", 1)
		else
			button:TryChangePage("Gender", 2)
		end

		function elementsUList.luaRenderItem(btn, idx, eleData)
			LuaUIUtils.setElementButtonNew(btn, eleData.element)
		end

		elementsUList:SetList(data.elementNames)

		iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label)
	end

	function LuaUIUtils.generatePetInfo(pet)
		local petInfo = pet:getRawTable()
		local pData = PetData[pet.templateId] or {}

		petInfo.id = pet.id
		petInfo.templateId = pet.templateId
		petInfo.gender = pet.gender
		petInfo.name = LuaUIUtils.getPetName(pet.id)
		petInfo.iconName = pData.iconName
		petInfo.cp = LuaUIUtils.getPetCpValue(pet.id)
		petInfo.label = pet.label
		petInfo.isShiny = Utils.isLabelShiny(pet.label)
		petInfo.isVariant = Utils.isLabelVariant(pet.label)
		petInfo.isBoss = Utils.isLabelElite(pet.label)
		petInfo.isMini = Utils.isLabelRainbow(pet.label)
		petInfo.bodySizeType = pet.bodySizeType

		local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
		local prototypeData = PetPrototypeData[petPrototypeId] or {}
		local elementType = prototypeData.elementType or {}
		local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

		petInfo.elementIds = elementIds
		petInfo.elementNames = elementNames
		petInfo.level = pet.level
		petInfo.isPutInHomeland = pg.me:isPetPutInHomeland(pet)

		local petType = PetData[pet.templateId].functionId

		petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]

		return petInfo
	end

	function LuaUIUtils.generateHomePetInfoByPetInfo(pet)
		local petInfo = pet:getRawTable()
		local pData = PetData[pet.templateId] or {}

		petInfo.id = pet.id
		petInfo.templateId = pet.templateId
		petInfo.gender = pet.gender
		petInfo.name = LuaUIUtils.getPetNameByPetInfo(pet)
		petInfo.iconName = pData.iconName
		petInfo.label = pet.label
		petInfo.isShiny = Utils.isLabelShiny(pet.label)
		petInfo.isVariant = Utils.isLabelVariant(pet.label)

		local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
		local prototypeData = PetPrototypeData[petPrototypeId] or {}
		local elementType = prototypeData.elementType or {}
		local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

		petInfo.elementIds = elementIds
		petInfo.elementNames = elementNames
		petInfo.level = pet.level
		petInfo.isPutInHomeland = true

		local petType = PetData[pet.templateId].functionId

		petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]

		return petInfo
	end

	function LuaUIUtils.getDispatchPetInfo(pet)
		local petInfo = pet:getRawTable()
		local pData = PetData[pet.templateId] or {}

		petInfo.id = pet.id
		petInfo.petPrototypeId = pet.petPrototypeId
		petInfo.templateId = pet.templateId
		petInfo.gender = pet.gender
		petInfo.name = LuaUIUtils.getPetName(pet.id)
		petInfo.iconName = pData.iconName
		petInfo.cp = LuaUIUtils.getPetCpValue(pet.id)
		petInfo.label = pet.label
		petInfo.isShiny = Utils.isLabelShiny(pet.label)
		petInfo.isDark = Utils.isLabelDark(pet.label)
		petInfo.isVariant = Utils.isLabelVariant(pet.label)
		petInfo.isBoss = Utils.isLabelElite(pet.label)
		petInfo.isMini = Utils.isLabelRainbow(pet.label)
		petInfo.bodySizeType = pet.bodySizeType
		petInfo.isRainbow = Utils.isRainbowTypeByTemplateId(pet.templateId)
		petInfo.isBlackRainbow = Utils.isBlackRainbowTypeByTemplateId(pet.templateId)

		local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
		local prototypeData = PetPrototypeData[petPrototypeId] or {}
		local elementType = prototypeData.elementType or {}
		local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

		petInfo.elementIds = elementIds
		petInfo.elementNames = elementNames
		petInfo.level = pet.level
		petInfo.activityDispatching = pg.me:getPetActivityDispatching(pet)
		petInfo.isGoldAdveRewarded = pg.me:hasPetGoldAdveRewarded(pet.id)

		local petType = PetData[pet.templateId].functionId

		petInfo.petType = petType
		petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]
		petInfo.rating = pet:getPropRatingResult()
		petInfo.favoriteType = pet.favoriteType
		petInfo.inBattle = pg.game.petManage:getPetIsInBattle(pet.id)
		petInfo.inExplore = Lume.find(pg.me.prepareFormationList[1].exploreFormation, pet.id) ~= nil
		petInfo.isPutInHomeland = pg.me:isPetPutInHomeland(pet)
		petInfo.formTypeId = Utils.getPetFormIdByPrototypeId(petPrototypeId)

		local controlFeatureId = petInfo.characterInfo and petInfo.characterInfo.curCharacter
		local featureInfo = controlFeatureId and PetCharacterData[controlFeatureId]

		petInfo.hasRareFeature = featureInfo and featureInfo.rare == 1 and 1 or 0
		petInfo.exploreSkillsLevel = {
			canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
			canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
			canSwim = pData.canSwim ~= nil and pData.canSwim or nil
		}
		petInfo.climbLevel = petInfo.exploreSkillsLevel.canClimb or 0
		petInfo.glideLevel = petInfo.exploreSkillsLevel.canGlide or 0
		petInfo.swimLevel = petInfo.exploreSkillsLevel.canSwim or 0
		petInfo.exploreSkillIndexLevel = {}
		petInfo.exploreSkillIndexLevel[1] = petInfo.climbLevel
		petInfo.exploreSkillIndexLevel[2] = petInfo.glideLevel
		petInfo.exploreSkillIndexLevel[3] = petInfo.swimLevel

		return petInfo
	end

	function LuaUIUtils.checkPetIsInBlockId(prototypeId, blockId)
		local blockConfig = MapBlockConfigData[blockId]

		if not blockConfig then
			return false
		end

		local petList = blockConfig.petList

		if not petList then
			return false
		end

		for _, petPrototypeId in ipairs(petList) do
			if petPrototypeId == prototypeId then
				return true
			end
		end

		return false
	end

	function LuaUIUtils.checkCatched(petPrototypeId)
		local info = pg.me.petHandbookMap[petPrototypeId]

		if info then
			return info:isCatched()
		end

		return false
	end

	function LuaUIUtils.formatCatchRate(rate)
		local displayRate = math.min(rate or 0, 1) * 100

		if displayRate <= 0 then
			displayRate = "0"
		elseif displayRate <= 0.1 then
			displayRate = "0.1"
		elseif displayRate < 10 then
			displayRate = LuaUIUtils.m_customParseFloatPropVal(displayRate)
		elseif displayRate < 100 then
			displayRate = string.format("%d", math.floor(displayRate))
		else
			displayRate = "100"
		end

		if (pg.languageType or 0) == Const.LANGUAGE_TYPE_MAP.fr_FR and string.find(displayRate, ".", 1, true) then
			displayRate = string.gsub(displayRate, "%.", ",")
		end

		return displayRate
	end

	function LuaUIUtils.renderPetCharList(petCharList, petTemplateId)
		if not petCharList or not petTemplateId then
			return
		end

		local pData = PetData[petTemplateId]
		local exploreSkillsLevel = {
			canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
			canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
			canSwim = pData.canSwim ~= nil and pData.canSwim or nil
		}
		local tempExploreLevelAllData = {}

		for k, v in pairs(exploreSkillsLevel) do
			local temp = {
				exploreName = k,
				exploreLevel = v
			}

			tempExploreLevelAllData[#tempExploreLevelAllData + 1] = temp
		end

		function petCharList.luaRenderItem(button1, index1, data1)
			button1:TryChangePage("PetChar", AbilityConst.SPECIFIC_ABILITY_NAME_2_INDEX[data1.exploreName])
			button1:TryChangePage("quality", data1.exploreLevel - 1)
		end

		petCharList:SetList(tempExploreLevelAllData)
	end

	function LuaUIUtils.getPetTagList(petInfo, noBasicForm)
		local tagDatas = {}
		local templateId = petInfo.templateId
		local shinyIndex = 0

		if petInfo.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			shinyIndex = 1
		elseif petInfo.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			shinyIndex = 2
		end

		local formData = Utils.getPetFormTypeDataByTemplateId(templateId)

		if formData then
			local formQuality = formData.formQuality or 3
			local needForm = not noBasicForm or noBasicForm and formQuality >= 3

			if needForm then
				tagDatas[#tagDatas + 1] = {
					tIndex = 0,
					formQuality = formQuality
				}
			end
		end

		local label = petInfo.label

		if label then
			if Utils.isLabelShiny(label) then
				tagDatas[#tagDatas + 1] = {
					tIndex = 1,
					shinyIndex = shinyIndex,
					labelMask = Const.PET_LABEL_MASK.SHINY
				}
			end

			if Utils.isLabelDark(label) then
				tagDatas[#tagDatas + 1] = {
					tIndex = 3,
					labelMask = Const.PET_LABEL_MASK.DARK
				}
			end

			if Utils.isLabelRainbow(label) then
				tagDatas[#tagDatas + 1] = {
					isMini = true,
					tIndex = 2,
					isBoss = false,
					labelMask = Const.PET_LABEL_MASK.RAINBOW
				}
			elseif Utils.isLabelElite(label) then
				tagDatas[#tagDatas + 1] = {
					isMini = false,
					tIndex = 2,
					isBoss = true,
					labelMask = Const.PET_LABEL_MASK.ELITE
				}
			end
		else
			if petInfo.isShiny then
				tagDatas[#tagDatas + 1] = {
					tIndex = 1,
					shinyIndex = shinyIndex,
					labelMask = Const.PET_LABEL_MASK.SHINY
				}
			end

			if petInfo.isDark then
				tagDatas[#tagDatas + 1] = {
					tIndex = 3,
					labelMask = Const.PET_LABEL_MASK.DARK
				}
			end

			if petInfo.isMini then
				tagDatas[#tagDatas + 1] = {
					isMini = true,
					tIndex = 2,
					isBoss = false,
					labelMask = Const.PET_LABEL_MASK.RAINBOW
				}
			elseif petInfo.isBoss then
				tagDatas[#tagDatas + 1] = {
					isMini = false,
					tIndex = 2,
					isBoss = true,
					labelMask = Const.PET_LABEL_MASK.ELITE
				}
			end
		end

		for _, v in pairs(tagDatas) do
			v.templateId = templateId
			v.label = label
			v.bodySizeType = petInfo.bodySizeType
			v.shinyStyle = petInfo.shinyStyle
		end

		return tagDatas
	end

	function LuaUIUtils.getHomeVoucherBonusAppearanceList(petInfo, appearanceInfos)
		if not petInfo then
			return {}
		end

		local appearanceRules = HomeLandUtils.getHomeVoucherAppearanceRules()
		local tagDataList = LuaUIUtils.getPetTagList(petInfo)
		local tagInfoList, tagKey2IndexMap = LuaUIUtils.getPetTagInfo(petInfo.templateId, petInfo.label, petInfo.bodySizeType, petInfo.shinyStyle, true)
		local tagByRuleKey = {}

		for _, tagData in ipairs(tagDataList) do
			local appearanceType, appearanceValue, tagKey

			if tagData.tIndex == 0 then
				appearanceType = HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.FORM_QUALITY
				appearanceValue = tagData.formQuality
				tagKey = "b"
			elseif tagData.tIndex == 1 then
				appearanceType = HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE.SHINY
				appearanceValue = 0
				tagKey = "d"
			end

			if appearanceType then
				local ruleKey = tostring(appearanceType) .. "_" .. tostring(appearanceValue)
				local tagInfoIndex = tagKey2IndexMap[tagKey]

				tagByRuleKey[ruleKey] = {
					tagData = tagData,
					tagInfo = tagInfoIndex and tagInfoList[tagInfoIndex]
				}
			end
		end

		local matchedInfos = appearanceInfos

		if matchedInfos == nil then
			matchedInfos = HomeLandUtils.getHomeVoucherAppearanceInfos(petInfo)
		end

		local result = {}

		for _, appearanceInfo in ipairs(matchedInfos) do
			local ruleKey = tostring(appearanceInfo.appearanceType) .. "_" .. tostring(appearanceInfo.appearanceValue)
			local tag = tagByRuleKey[ruleKey]

			if tag then
				local labelUrl = tag.tagInfo and tag.tagInfo.labelUrl
				local appearanceRule = appearanceRules[appearanceInfo.id]

				if appearanceRule and not string.isNilOrEmpty(appearanceRule.iconSmall) then
					tag.tagData.iconSmall = appearanceRule.iconSmall
					tag.tagData.iconBg = appearanceRule.iconBg
					labelUrl = AddressDataConst.UI_NODE_PET_TAG_FORM_NEW
				end

				local multiplier = appearanceInfo.multiplier

				if multiplier == nil then
					multiplier = appearanceInfo.rate
				end

				result[#result + 1] = {
					id = appearanceInfo.id,
					name = tag.tagInfo and tag.tagInfo.name or "",
					labelUrl = labelUrl,
					tagData = tag.tagData,
					multiplier = multiplier,
					sort = appearanceInfo.sort
				}
			end
		end

		return result
	end

	function LuaUIUtils.renderPetTagList(button, data)
		local tIndex = data.tIndex

		if not string.isNilOrEmpty(data.iconSmall) then
			LuaUIUtils.renderFormItemByTypeData(button, data)
		elseif tIndex == 0 then
			if data.templateId then
				LuaUIUtils.renderFormItem(button, data.templateId)
			else
				LuaUIUtils.renderFormItemByQuality(button, data.formQuality)
			end
		elseif tIndex == 1 then
			button:TryChangePage("Type", data.shinyIndex)
		elseif tIndex == 2 then
			if data.isMini then
				button:TryChangePage("Type", 1)
			else
				button:TryChangePage("Type", 0)
			end
		elseif tIndex == 3 then
			-- block empty
		end
	end

	function LuaUIUtils.getPetTagInfo(templateId, label, bodySizeType, shinyStyle, isReturnIndex)
		local ret = {}
		local petPrototypeId = Utils.getPetPetPrototypeId(templateId)
		local avatarData = PetAvatarData[petPrototypeId]
		local formInfo = avatarData and avatarData[0]
		local tagKey2IndexMap = {}
		local curIndex = #ret + 1

		if formInfo then
			local formDesc = formInfo.formDesc

			tagKey2IndexMap.b = curIndex
			ret[curIndex] = {
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_FORM_NEW,
				name = LuaUIUtils.getPetFormName(templateId),
				desc = pg.getLocalizationText(formDesc),
				formQuality = Utils.getPetFormQualityByTemplateId(templateId),
				templateId = templateId
			}
		end

		if Utils.isLabelShiny(label) then
			curIndex = #ret + 1
			tagKey2IndexMap.d = curIndex

			local shinyIndex = 0

			if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
				shinyIndex = 1
			elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
				shinyIndex = 2
			end

			local shinyName, shinyDesc = LuaUIUtils.getPetShinyNameAndDesc(shinyStyle)

			ret[curIndex] = {
				isShiny = true,
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_FLASH,
				shinyIndex = shinyIndex,
				name = shinyName,
				desc = shinyDesc
			}
		end

		if Utils.isLabelDark(label) then
			curIndex = #ret + 1
			tagKey2IndexMap.c = curIndex
			ret[curIndex] = {
				isDark = true,
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_DARK,
				name = pg.getGameString("PET_DARK_LABEL_TITLE"),
				desc = pg.getGameString("PET_DARK_LABEL_TIPS")
			}
		end

		if Utils.isLabelRainbow(label) then
			curIndex = #ret + 1
			tagKey2IndexMap.e = curIndex

			local bossRet = {
				isMini = true,
				isBoss = false,
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_BOSS,
				name = pg.getGameString("PET_ELITESIZE_LABEL_TITLE"),
				desc = pg.getGameString("PET_ELITESIZE_LABEL_TIPS")
			}

			bossRet.name = pg.getGameString("PET_ELITESIZE_LABEL_TITLE_MINI")
			bossRet.desc = pg.getGameString("PET_ELITESIZE_LABEL_TIPS_MINI")
			bossRet.bodySizeType = bodySizeType
			ret[curIndex] = bossRet
		elseif Utils.isLabelElite(label) then
			curIndex = #ret + 1
			tagKey2IndexMap.e = curIndex

			local bossRet = {
				isMini = false,
				isBoss = true,
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_BOSS,
				name = pg.getGameString("PET_ELITESIZE_LABEL_TITLE"),
				desc = pg.getGameString("PET_ELITESIZE_LABEL_TIPS")
			}

			ret[curIndex] = bossRet
		end

		if isReturnIndex then
			return ret, tagKey2IndexMap
		end

		return ret
	end

	function LuaUIUtils.getPetShinyNameAndDesc(shinyIndex)
		if not shinyIndex then
			return pg.getGameString("PET_SHINY_LABEL_TITLE"), pg.getGameString("PET_SHINY_LABEL_TIPS")
		end

		local cfg = PetShinyStyleData[shinyIndex]

		if not cfg then
			return pg.getGameString("PET_SHINY_LABEL_TITLE"), pg.getGameString("PET_SHINY_LABEL_TIPS")
		end

		return pg.getLocalizationText(cfg.name), pg.getLocalizationText(cfg.desc)
	end

	function LuaUIUtils.setPetTagLabelToolTip(button, data, toolTipCbFunc)
		function button.luaRenderTooltip(btn, popUp)
			local objectReference = popUp:GetComponent("ObjectReference")
			local listTagUList = objectReference:GetRefValue("listTagUList")
			local title = objectReference:GetRefValue("title")

			ClientTextUtils.setText(title, pg.getGameString("PET_APPEARANCE_LABEL_TITLE"))

			function listTagUList.luaRenderItem(b, i, d)
				local ob = b:GetComponent("ObjectReference")
				local iconUContainer = ob:GetRefValue("iconUContainer")
				local txtTitleUSDFText = ob:GetRefValue("txtTitleUSDFText")
				local txtDetailsUSDFText = ob:GetRefValue("txtDetailsUSDFText")
				local listFormDetailsUList = ob:GetRefValue("listFormDetailsUList")

				ClientTextUtils.setText(txtTitleUSDFText, d.name)
				ClientTextUtils.setText(txtDetailsUSDFText, d.desc)
				iconUContainer:SetUrlWithCallback(d.labelUrl, function(content)
					content.enabledTooltip = false

					if d.isShiny then
						content:TryChangePage("Type", d.shinyIndex)
					end

					if d.isMini then
						content:TryChangePage("Type", 1)
					elseif d.isBoss then
						content:TryChangePage("Type", 0)
					end

					if d.formQuality then
						LuaUIUtils.renderFormItem(content, d.templateId)
					end
				end)
			end

			listTagUList:SetList(data)

			if toolTipCbFunc then
				toolTipCbFunc()
			end
		end
	end

	function LuaUIUtils.renderFormItemByTypeData(formItem, formTypeData, isNoActive)
		if formTypeData then
			local objectReference = formItem:GetComponent("ObjectReference")

			if not objectReference then
				return
			end

			local iconUImage = objectReference:GetRefValue("iconUImage")
			local bg2UImage = objectReference:GetRefValue("bg2UImage")

			iconUImage.url = formTypeData.iconSmall

			if string.isNilOrEmpty(formTypeData.iconBg) then
				bg2UImage:SetActive(false)
			elseif isNoActive then
				bg2UImage:SetActive(false)
			else
				bg2UImage:SetActive(true)

				bg2UImage.url = formTypeData.iconBg
			end
		end
	end

	function LuaUIUtils.renderFormItemByQuality(formItem, formQuality, isNoActive)
		for _, formTypeData in pairs(PetFormTypeData) do
			if formTypeData.formQuality == formQuality then
				LuaUIUtils.renderFormItemByTypeData(formItem, formTypeData, isNoActive)

				return
			end
		end
	end

	function LuaUIUtils.renderFormItem(formItem, petTemplateId, isNoActive)
		local formTypeData = Utils.getPetFormTypeDataByTemplateId(petTemplateId)

		LuaUIUtils.renderFormItemByTypeData(formItem, formTypeData, isNoActive)
	end

	function LuaUIUtils.renderFormItemByPrototypeId(formItem, petPrototypeId, isNoActive)
		local formTypeData = Utils.getPetFormTypeDataByPrototypeId(petPrototypeId)

		LuaUIUtils.renderFormItemByTypeData(formItem, formTypeData, isNoActive)
	end

	function LuaUIUtils.getAllPetPrepareBattleTeamInfo(padding)
		local info = {}
		local player = pg.me

		for index, formationInfo in ipairs(player.prepareFormationList) do
			if #formationInfo.formation > 0 then
				local petIds = formationInfo.formation:getRawTable()
				local petsData = {}

				for idx, petId in pairs(petIds) do
					local pet = player:getPetInfo(petId)

					if pet then
						local petInfo = LuaUIUtils.getPetCardMiniTeamInfo(pet)

						table.insert(petsData, petInfo)
					end
				end

				if ToBool(petsData) then
					if padding then
						for i = #petsData + 1, 4 do
							table.insert(petsData, {
								tIndex = 1
							})
						end
					end

					local ret = {}

					ret.petsData = petsData
					ret.teamName = formationInfo.customName
					ret.index = index

					table.insert(info, ret)
				end
			end
		end

		return info
	end

	function LuaUIUtils.getAllPetFormationsWithEmpty(padding)
		local info = {}
		local player = pg.me

		for index, formationInfo in ipairs(player.prepareFormationList) do
			local petIds = formationInfo.formation:getRawTable()
			local petsData = {}

			for _, petId in pairs(petIds) do
				local pet = player:getPetInfo(petId)

				if pet then
					local petInfo = LuaUIUtils.getPetCardMiniTeamInfo(pet)

					table.insert(petsData, petInfo)
				end
			end

			if padding then
				for _ = #petsData + 1, 4 do
					table.insert(petsData, {
						tIndex = 1,
						isEmpty = true
					})
				end
			end

			local ret = {}

			ret.petsData = petsData
			ret.teamName = formationInfo.customName
			ret.index = index
			ret.isEmpty = #petIds == 0

			table.insert(info, ret)
		end

		return info
	end

	function LuaUIUtils.renderPetElement(uList, elements)
		local elementData = {}

		for _, value in ipairs(elements) do
			table.insert(elementData, {
				element = value
			})
		end

		function uList.luaRenderItem(button, index, data)
			LuaUIUtils.setElementButtonNew(button, data.element)
		end

		uList:SetList(elementData)
	end

	function LuaUIUtils.getPetCardMiniTeamInfo(pet)
		local petInfo = {}

		if pet ~= nil then
			local pData = PetData[pet.templateId] or {}

			petInfo.iconName = pData.iconName
			petInfo.gender = pet.gender
			petInfo.label = pet.label

			local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

			petInfo.elementIds = elementIds
			petInfo.elementNames = elementNames
			petInfo.elementType = pData.elementType
			petInfo.id = pet.id
		end

		return petInfo
	end

	function LuaUIUtils.setPetActionTip(button, data)
		function button.luaRenderTooltip(_, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local iconSkillUImage = objectRef:GetRefValue("icon")
			local txtShortDetailsUSDFText = objectRef:GetRefValue("descText")
			local mainElement = objectRef:GetRefValue("mainElement")

			ClientTextUtils.setText(txtName, data.name)
			LuaUIUtils.setUIViewVisible(mainElement, false)
			ClientTextUtils.setText(txtShortDetailsUSDFText, pg.getLocalizationText(data.desc))

			local actionInfo = ExploreAbilityData[data.actionName]

			iconSkillUImage.url = actionInfo.icon[1]
		end
	end

	function LuaUIUtils.getPetBelongBoxAndSlotId(petId)
		local playerBoxMap = pg.me.petBoxMap
		local slot, box

		for boxId = 1, #playerBoxMap do
			for slotId = 1, playerBoxMap[boxId].slotCount do
				if playerBoxMap[boxId][slotId] == petId then
					box = boxId
					slot = slotId

					break
				end
			end
		end

		return slot, box
	end

	function LuaUIUtils.petManagementSelectPet(petId, cancelBlur)
		local slot, box = LuaUIUtils.getPetBelongBoxAndSlotId(petId)

		if not slot or not box then
			return
		end

		local petManagementModel = pg.global.ui.petManagement.model

		petManagementModel:setSelectBoxId(box)
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, {
			selectSlot = slot,
			cancelBlur = cancelBlur
		})
	end

	function LuaUIUtils.getSmallAreaPetData(smallAreaId, fixedCount)
		local data = {}
		local smallAreaCfg = MapBlockConfigData[smallAreaId]

		if not smallAreaCfg or not smallAreaCfg.petList then
			return data
		end

		local curIndex = 1

		for _, petPrototypeId in ipairs(smallAreaCfg.petList) do
			if data[curIndex] == nil then
				data[curIndex] = {
					petInfo = {}
				}
			end

			local info = {
				petPrototypeId = petPrototypeId,
				smallAreaId = smallAreaId
			}

			if LuaUIUtils.checkPetCatch(smallAreaId, petPrototypeId) then
				info.state = LuaUIUtils.PetInfoState.Catch
			elseif LuaUIUtils.checkPetFind(smallAreaId, petPrototypeId) then
				info.state = LuaUIUtils.PetInfoState.Find
			elseif LuaUIUtils.checkFriendCatch(smallAreaId, petPrototypeId) then
				info.state = LuaUIUtils.PetInfoState.FriendCatch
				info.friendId = LuaUIUtils.getLatestCatchFriendId(smallAreaId, petPrototypeId)
			else
				info.state = LuaUIUtils.PetInfoState.None
			end

			table.insert(data[curIndex].petInfo, info)

			if #data[curIndex].petInfo == fixedCount[curIndex] then
				curIndex = curIndex + 1
			end
		end

		return data
	end

	local function getEthnicGroupRepresentativePetTemplateId(ethnicGroup)
		local templateId = Utils.getMinStagePetTemplateIdByEthnic(ethnicGroup)

		if templateId then
			return templateId
		end

		local prototypeMap = PetEthnicToPrototypeMap[ethnicGroup]
		local minStage, minPrototypeId = math.huge

		for prototypeId, prototypeInfo in pairs(prototypeMap or EMPTY_TABLE) do
			local stage = prototypeInfo.stage or math.huge

			if stage < minStage or stage == minStage and (not minPrototypeId or prototypeId < minPrototypeId) then
				minStage = stage
				minPrototypeId = prototypeId
				templateId = prototypeInfo.defaultPet
			end
		end

		return templateId
	end

	function LuaUIUtils.getEthnicGroupPetData(ethnicGroups)
		local data = {}
		local added = {}

		for _, ethnicGroup in ipairs(ethnicGroups or EMPTY_TABLE) do
			local templateId = getEthnicGroupRepresentativePetTemplateId(ethnicGroup)

			if templateId and not added[templateId] then
				data[#data + 1] = {
					templateId = templateId,
					ethnicGroup = ethnicGroup
				}
				added[templateId] = true
			end
		end

		return data
	end

	function LuaUIUtils.getPetTemplateIdByWorldTemplateId(worldTemplateId)
		if not worldTemplateId or worldTemplateId <= 0 then
			return nil
		end

		local puppetData = PuppetData[worldTemplateId]
		local prototypeId = puppetData and puppetData.petPrototypeId or worldTemplateId
		local prototypeData = PetPrototypeData[prototypeId]
		local templateId = prototypeData and prototypeData.defaultPet or prototypeId

		if not PetData[templateId] then
			logger:error("@leylineflower rainbow pet template unresolved, worldTemplateId:", worldTemplateId, "prototypeId:", prototypeId, "templateId:", templateId)

			return nil
		end

		return templateId
	end

	function LuaUIUtils.getAreaRainbowPetWorldTemplateId(blockId)
		local staticId = blockId and LeylineFlowerUtils.getStaticIdByBlockId(nil, blockId)

		if not staticId then
			return nil
		end

		if not pg.space or not pg.space.getRainbowPetTemplateId then
			return nil
		end

		return pg.space:getRainbowPetTemplateId(staticId, nil)
	end

	function LuaUIUtils.getAreaRainbowPetData(blockId)
		local worldTemplateId = LuaUIUtils.getAreaRainbowPetWorldTemplateId(blockId)
		local templateId = worldTemplateId and LuaUIUtils.getPetTemplateIdByWorldTemplateId(worldTemplateId)

		if not templateId then
			return {}
		end

		return {
			{
				templateId = templateId,
				worldTemplateId = worldTemplateId
			}
		}
	end

	function LuaUIUtils.checkPetCanShowDistributionArea(petPrototypeId)
		local ret = {}

		for blockId, _ in pairs(MapSmallAreaIdToIndex) do
			local areaUnlocked = pg.me:getAreaFirstInData(blockId)

			if areaUnlocked and (LuaUIUtils.checkPetCatch(blockId, petPrototypeId) or LuaUIUtils.checkPetFind(blockId, petPrototypeId) or LuaUIUtils.checkFriendCatch(blockId, petPrototypeId)) then
				ret[#ret + 1] = blockId
			end
		end

		return ret
	end

	function LuaUIUtils.getSpeciesKnownDistributionFormIds(petTemplateId)
		local baseId = Utils.getBasePetPrototypeId(petTemplateId)
		local formIds = baseId ~= 0 and PetBasePrototypeToPrototypeMap[baseId] or {
			petTemplateId
		}
		local ret = {}

		for _, formId in ipairs(formIds) do
			if next(LuaUIUtils.checkPetCanShowDistributionArea(formId)) then
				ret[#ret + 1] = formId
			end
		end

		if #ret == 0 then
			ret[1] = petTemplateId
		end

		return ret
	end

	function LuaUIUtils.checkAllUnlockedArea()
		local ret = {}

		for blockId, _ in pairs(MapSmallAreaIdToIndex) do
			local areaUnlocked = pg.me:getAreaFirstInData(blockId)

			if areaUnlocked then
				ret[#ret + 1] = blockId
			end
		end

		return ret
	end

	function LuaUIUtils.checkPetCatch(blockId, petPrototypeId)
		return Utils.isBlockPetCatched(pg.me, blockId, petPrototypeId, Const.GROUP_TYPE_SELF)
	end

	function LuaUIUtils.checkPetFind(blockId, petPrototypeId)
		return Utils.isBlockPetKnown(pg.me, blockId, petPrototypeId)
	end

	function LuaUIUtils.checkFriendCatch(blockId, petPrototypeId)
		local friendList = pg.game.chat:getFriendList()

		for _, info in ipairs(friendList) do
			if info.playerId then
				local playerInfo = pg.game.chat:getPlayerInfo(info.playerId)

				if playerInfo and Utils.isBlockPetCatched(playerInfo, blockId, petPrototypeId, Const.GROUP_TYPE_SELF) then
					return true
				end
			end
		end

		return false
	end

	function LuaUIUtils.getLatestCatchFriendId(blockId, petPrototypeId)
		local friendId
		local maxCatchTime = -1
		local friendList = pg.game.chat:getFriendList()

		for _, info in ipairs(friendList) do
			if info.playerId then
				local playerInfo = pg.game.chat:getPlayerInfo(info.playerId)

				if playerInfo then
					local catchedInfo = Utils.getBlockPetCatchedInfo(playerInfo, blockId, petPrototypeId)

					if catchedInfo and catchedInfo.isCatched then
						local catchTime = catchedInfo.updateTs

						if maxCatchTime == -1 or maxCatchTime < catchTime then
							friendId = info.playerId
							maxCatchTime = catchTime
						end
					end
				end
			end
		end

		return friendId
	end

	function LuaUIUtils.renderPetTip(button, data, fromResearch, fromRogue, fromDistribution, extraInfo)
		function button.luaRenderTooltip(btn, cmp)
			local objectReference = cmp:GetComponent("ObjectReference")
			local imgPetUImage = objectReference:GetRefValue("imgPetUImage")
			local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
			local btnDetailsUButton = objectReference:GetRefValue("btnDetailsUButton")
			local btnDetailsUButtonRef = btnDetailsUButton:GetComponent("ObjectReference")
			local btnDetailsHotKey = btnDetailsUButtonRef:GetRefValue("keyHotKeyContent")
			local btnDetailsKeyBinding = btnDetailsUButton:GetComponent("KeyBindingPro")
			local formNameText = objectReference:GetRefValue("formNameText")
			local petInfoList = objectReference:GetRefValue("petInfoList")
			local btnDistributionUButton = objectReference:GetRefValue("btnDistributionUButton")
			local scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
			local txtPetResearchDesc = scrollRectUScrollRect.content:GetComponent("USDFText")

			cmp:TryChangePage("IsRainbow", Utils.isAnyRainbowType(data.petPrototypeId) and 1 or 0)

			local showDistributionBtn = extraInfo and extraInfo.showDistributionBtn

			btnDistributionUButton.gameObject:SetActiveEx(showDistributionBtn)
			btnDistributionUButton:TryChangePage("button", 0)

			function btnDistributionUButton.luaClick()
				local distributionShowTab = extraInfo and extraInfo.distributionShowTab
				local resetDistributionShowTab = distributionShowTab == nil

				if extraInfo and extraInfo.showPetDistributionAreaCb then
					extraInfo.showPetDistributionAreaCb()
				end

				pg.game.map:showPetDistributionArea(data.petPrototypeId, distributionShowTab, resetDistributionShowTab)
				button:ClosePopup()
			end

			local objectReference1 = btnDistributionUButton:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getGameString("SHOW_DISTRIBUTION_AREA"))

			local petData = PetData[data.petPrototypeId]

			imgPetUImage.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

			ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(petData.name))

			if pg.game.setting:getShowDebugId() then
				ClientTextUtils.setText(txtNameUBaseText, txtNameUBaseText.text .. "-" .. tostring(data.petPrototypeId))
			end

			local petResearchContent = PetResearchContentData[data.petPrototypeId]

			ClientTextUtils.setText(txtPetResearchDesc, pg.getLocalizationText(petResearchContent.desc))

			local petInfoData = {}
			local areaNameText = ""
			local blocks = PetPrototypeToBlockMap[data.petPrototypeId]

			if blocks then
				local areaNames = {}

				for _, smallAreaId in ipairs(blocks) do
					local smallAreaCfg = MapBlockConfigData[smallAreaId]
					local isCatch = LuaUIUtils.checkPetCatch(smallAreaId, data.petPrototypeId)
					local isFind = LuaUIUtils.checkPetFind(smallAreaId, data.petPrototypeId)
					local isFriendCatch = LuaUIUtils.checkFriendCatch(smallAreaId, data.petPrototypeId)

					if smallAreaCfg and (isCatch or isFind or isFriendCatch) then
						table.insert(areaNames, pg.getLocalizationText(smallAreaCfg.areaName))
					end
				end

				areaNameText = table.concat(areaNames, " \\ ")

				if not ToBool(areaNames) then
					LuaUIUtils.setUIViewVisible(petInfoList, false)
				end
			else
				local smallAreaCfg = MapBlockConfigData[data.smallAreaId]

				if smallAreaCfg then
					areaNameText = pg.getLocalizationText(smallAreaCfg.areaName)
				else
					areaNameText = pg.getGameString("PET_MANUAL_NO_DISTRIBUTION")
				end
			end

			if not fromDistribution then
				table.insert(petInfoData, {
					tIndex = 0,
					tName = pg.getGameString("PET_AREA_NAME"),
					tValue = areaNameText
				})
			end

			if petData.condition then
				table.insert(petInfoData, {
					tIndex = 0,
					tName = pg.getGameString("PET_WEATHER_CONDITION"),
					tValue = pg.getLocalizationText(petData.condition)
				})
			end

			if not fromDistribution and petData.clue then
				table.insert(petInfoData, {
					tIndex = 0,
					tName = pg.getGameString("PET_CLUE_CONDITION"),
					tValue = pg.getLocalizationText(petData.clue)
				})
			end

			if petData.rules then
				table.insert(petInfoData, {
					tIndex = 0,
					tName = pg.getGameString("PET_RULES_CONDITION"),
					tValue = pg.getLocalizationText(petData.rules)
				})
			end

			function petInfoList.luaRenderItem(itemBtn, itemIndex, itemData)
				local itemObjRef = itemBtn:GetComponent("ObjectReference")
				local txtNameUBaseText1 = itemObjRef:GetRefValue("txtNameUBaseText")
				local txtValueUBaseText = itemObjRef:GetRefValue("txtValueUBaseText")

				ClientTextUtils.setText(txtNameUBaseText1, itemData.tName)
				ClientTextUtils.setText(txtValueUBaseText, itemData.tValue)
			end

			petInfoList:SetList(petInfoData)

			local formName = LuaUIUtils.getPetFormNameByPrototypeId(data.petPrototypeId)

			ClientTextUtils.setText(formNameText, formName)
			btnDetailsUButton.gameObject:SetActiveEx(not fromDistribution)

			local btnDetailKey = "Raw/GamepadButtonWest"

			if not showDistributionBtn then
				btnDetailKey = "Raw/GamepadButtonNorth"
			end

			btnDetailsUButton:SetGamepadAction(btnDetailKey)

			function btnDetailsUButton.luaClick()
				button:ClosePopup()
				pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
					templateId = data.petPrototypeId,
					fromResearch = fromResearch,
					fromRogue = fromRogue,
					fromRecommend = extraInfo and extraInfo.fromRecommend
				})
			end
		end
	end

	function LuaUIUtils.renderFriendCatchTip(button, data)
		function button.luaRenderTooltip(btn, cmp)
			local objectReference = cmp:GetComponent("ObjectReference")
			local playerIconUImage = objectReference:GetRefValue("playerIconUImage")
			local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
			local catchInfoUBaseText = objectReference:GetRefValue("catchInfoUBaseText")
			local petInfoUBaseText = objectReference:GetRefValue("petInfoUBaseText")
			local playerInfo = pg.game.chat:getPlayerInfo(data.friendId)

			ClientTextUtils.setText(playerNameUBaseText, playerInfo.playerName)

			local headIcon = playerInfo.headIcon or 1

			if not data.smallAreaId or not MapBlockConfigData[data.smallAreaId] then
				ClientTextUtils.setText(catchInfoUBaseText, "")
				ClientTextUtils.setText(petInfoUBaseText, "")

				return
			end

			local smallAreaCfg = MapBlockConfigData[data.smallAreaId]
			local areaName = pg.getLocalizationText(smallAreaCfg.areaName)
			local catchInfo = Utils.getBlockPetCatchedInfo(playerInfo, data.smallAreaId, data.petPrototypeId, Const.GROUP_TYPE_SELF)
			local weatherCfg = WeatherData[catchInfo.weatherId]
			local richTextName = string.sub(weatherCfg.icon, 2, string.len(weatherCfg.icon) - 4)
			local weatherText = string.format("%s<sprite name=%s>", pg.getLocalizationText(weatherCfg.name), richTextName)

			ClientTextUtils.setText(catchInfoUBaseText, pg.getFormatText(pg.getGameString("PET_EREA_FRIENT_CATCH_TIP"), areaName, weatherText))

			local petResearchContent = PetResearchContentData[data.petPrototypeId]

			ClientTextUtils.setText(petInfoUBaseText, pg.getLocalizationText(petResearchContent.desc))
		end
	end

	function LuaUIUtils.renderMapPetList(button, index, data, blockId)
		local objectReference = button:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local petInfoTip = objectReference:GetRefValue("petInfoTip")
		local petTextTip = objectReference:GetRefValue("petTextTip")
		local weatherIconUImage = objectReference:GetRefValue("weatherIconUImage")
		local cfgData = PetData[data.petPrototypeId]

		icon.url = LuaUIUtils.getPetIcon(cfgData.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

		button:TryChangePage("state", data.state)

		if data.state == LuaUIUtils.PetInfoState.FriendCatch then
			button:TryChangePage("state", LuaUIUtils.PetInfoState.Find)
		end

		local rate = Utils.getBlockCatchedRate(pg.me, blockId)
		local blockInfo = MapBlockConfigData[blockId] or {}
		local unlockReward1 = blockInfo.unlockReward1 or 1
		local showPetArea = blockInfo.showPetArea or 0

		if data.state == LuaUIUtils.PetInfoState.None and unlockReward1 <= rate and showPetArea == 1 then
			button:TryChangePage("state", LuaUIUtils.PetInfoState.Find)
		end

		local _, page = button:TryGetCurrentPage("state")
		local weatherIcon, meteorologyOrWeatherId, isMeteorology = require("Guis.Utils.MapUtils").getWeatherIcon(blockId, data.petPrototypeId)

		if weatherIcon then
			if page == 4 then
				weatherIcon = AddressDataConst.UI_MAP_QUESTION_MARK
			end

			weatherIconUImage.url = weatherIcon

			local meteorologyId = pg.me:getAreaMeteorology(blockId)

			if meteorologyId > 0 then
				if meteorologyId == meteorologyOrWeatherId and isMeteorology then
					button:TryChangePage("Weather", 1)
				else
					button:TryChangePage("Weather", 2)
				end
			else
				local weatherId = pg.me:getWeatherByAreaId(blockId)

				if WeatherData[weatherId] then
					if weatherId == meteorologyOrWeatherId and not isMeteorology then
						button:TryChangePage("Weather", 1)
					else
						button:TryChangePage("Weather", 2)
					end
				end
			end
		else
			button:TryChangePage("Weather", 0)

			weatherIconUImage.url = nil
		end

		button.enabledTooltip = false
		button.draggable = false

		if data.state == LuaUIUtils.PetInfoState.Catch or data.state == LuaUIUtils.PetInfoState.FriendCatch or data.state == LuaUIUtils.PetInfoState.Find then
			button.enabledTooltip = true
			button.PopupTool.popupTemplate = petInfoTip

			LuaUIUtils.renderPetTip(button, data, nil, nil, nil, {
				showDistributionBtn = true
			})
		elseif data.state == LuaUIUtils.PetInfoState.None then
			if unlockReward1 <= rate and showPetArea == 1 then
				button.enabledTooltip = true
				button.PopupTool.popupTemplate = petInfoTip

				LuaUIUtils.renderPetTip(button, data, nil, nil, nil, {
					showDistributionBtn = true
				})
			else
				button.enabledTooltip = true
				button.PopupTool.popupTemplate = petTextTip

				LuaUIUtils.renderTextTip(button, data)
			end
		end

		function button.luaTooltipPopup(button, state)
			if not state then
				button.isSelected = false
			end
		end
	end

	function LuaUIUtils.renderCultivatePetItem(button, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage") or objectReference:GetRefValue("icon")
		local petConfig = PetData[data.templateId]

		if not iconUImage then
			logger:error("@leylineflower renderCultivatePetItem no icon ref, templateId:", data.templateId)
		elseif not petConfig then
			logger:error("@leylineflower renderCultivatePetItem no PetData, templateId:", data.templateId, "ethnicGroup:", data.ethnicGroup, "worldTemplateId:", data.worldTemplateId)
		else
			iconUImage.url = LuaUIUtils.getPetIcon(petConfig.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)
		end

		button:TryChangePage("state", LuaUIUtils.PetInfoState.Catch)
		button:TryChangePage("Weather", 4)

		function button.luaClick()
			if not PetData[data.templateId] then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_PET_TIP, {
				autoHor = true,
				autoVer = true,
				checkTouchBegin = false,
				addSibling = 1,
				templateId = data.templateId,
				targetRect = button
			})
		end
	end

	function LuaUIUtils.getRawPropertyData(petId)
		local data = LuaUIUtils.getPropertyData(petId)
		local ret = {}

		for _, v in pairs(data) do
			if v.tIndex == nil or v.tIndex == 0 then
				ret[#ret + 1] = v
			end
		end

		return ret
	end

	function LuaUIUtils.getPropertyData(petId, excludeZero)
		local petInfo = pg.me:getPetInfo(petId)
		local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)
		local baseProperty = {}
		local advanceProperty = {}

		local function parseVStrFunc(showType, propValue)
			if showType == 0 then
				propValue = string.format("%d", propValue)
			elseif showType == 1 and type(propValue) == "number" then
				propValue = string.format("%s%%", math.floor(propValue * 100))
			elseif showType == 2 then
				propValue = LuaUIUtils.m_customParseFloatPropVal(propValue, excludeZero)
			end

			return propValue
		end

		for order, v in pairs(PetDetailPropertyData) do
			for type1, v1 in pairs(v) do
				local curPropStrKey = v1.displayProp
				local propValue = 0
				local floatPropV = 0

				if not string.isNilOrEmpty(curPropStrKey) then
					propValue = attributeMap[AttributeConst[curPropStrKey]] or 0
					floatPropV = propValue
					propValue = parseVStrFunc(v1.showType, propValue)
				end

				local extraProp
				local floatExtraPropV = 0

				if v1.propMerge and v1.propMerge == 1 and not string.isNilOrEmpty(curPropStrKey) then
					local extraPropStrKey = curPropStrKey:gsub("^(.*)_.*$", "%1_v")

					if not string.isNilOrEmpty(extraPropStrKey) then
						local directV = attributeMap[AttributeConst[extraPropStrKey]] or 0
						local fixedPropValue = math.ceil(directV)

						extraProp = math.ceil(propValue - fixedPropValue)
						propValue = fixedPropValue
					end
				end

				local specialDes = v1.specialDes or 0
				local specialProp = v1.specialProp or {}
				local propName = pg.getLocalizationText(v1.propName)
				local specialDesInfo

				if specialDes ~= UIConst.Pet_ProperDetail_SubDesType.None then
					specialDesInfo = {
						type = specialDes
					}
				end

				local isElementDes = specialDes == UIConst.Pet_ProperDetail_SubDesType.ElementRestrain or specialDes == UIConst.Pet_ProperDetail_SubDesType.ElementResist
				local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

				if isElementDes then
					specialDesInfo.title = v1.elementTitle and pg.getGameString(v1.elementTitle) or ""
					specialDesInfo.desc = v1.elementTipDesc and pg.getGameString(v1.elementTipDesc) or ""
					specialDesInfo.activeElementTypeIds = PetManagementDataHelper.getPetUnlockedSkillElementIdSet(petId)
				end

				if specialDes == UIConst.Pet_ProperDetail_SubDesType.Info then
					specialDesInfo.decConfigId = v1.decConfigId
				elseif specialDes == UIConst.Pet_ProperDetail_SubDesType.ElementRestrain then
					local mainElementTypeId = PetManagementDataHelper.getPetSkillMainElementId(petId)
					local mainEleDmgRatioName = LuaUIUtils.getElementDmgRationNameByEleId(mainElementTypeId) or ""
					local mainEleName = LuaUIUtils.getElementName(mainElementTypeId) or ""

					specialDesInfo.mainElementTypeId = mainElementTypeId or -1
					specialDesInfo.mainEleDmgRatioName = mainEleDmgRatioName
					specialDesInfo.mainEleName = mainEleName
					specialDesInfo.mainEleDmgRatioVal = attributeMap[AttributeConst[mainEleDmgRatioName]] or 0

					local subElementShowInfos = {}

					for _, vCfg in ipairs(specialProp) do
						local subEleV = attributeMap[AttributeConst[vCfg[1]]] or 0
						local subEleVStr = parseVStrFunc(v1.showType, subEleV)
						local subEleId = LuaUIUtils.getElementIdByDmgRationName(vCfg[1], 1) or 0

						table.insert(subElementShowInfos, {
							cfg = vCfg,
							vStr = subEleVStr,
							eId = subEleId
						})
					end

					specialDesInfo.subElementShowInfos = subElementShowInfos
					propValue = parseVStrFunc(v1.showType, specialDesInfo.mainEleDmgRatioVal)
				elseif specialDes == UIConst.Pet_ProperDetail_SubDesType.ElementResist then
					local sumRatioV = 0
					local subElementShowInfos = {}

					for _, vCfg in ipairs(specialProp) do
						local eleDmgRatioName = vCfg[1]
						local eleDmgRatioVal = attributeMap[AttributeConst[eleDmgRatioName]] or 0
						local subEleVStr = parseVStrFunc(v1.showType, eleDmgRatioVal)
						local subEleId = LuaUIUtils.getElementIdByDmgRationName(eleDmgRatioName, 2) or ElementNameToId.Holy or 0

						table.insert(subElementShowInfos, {
							cfg = vCfg,
							vStr = subEleVStr,
							eId = subEleId
						})

						sumRatioV = sumRatioV + eleDmgRatioVal
					end

					local averageRatioV = sumRatioV / math.max(1, #specialProp)

					specialDesInfo.averageRatioVStr = parseVStrFunc(v1.showType, averageRatioV)
					specialDesInfo.subElementShowInfos = subElementShowInfos
					propValue = specialDesInfo.averageRatioVStr
				end

				if type1 == Const.PROP_TYPE_BASE then
					baseProperty[order] = {
						propName = propName,
						prop = propValue,
						extraProp = extraProp,
						icon = v1.icon,
						dec = v1.dec,
						showType = v1.showType,
						specialDesInfo = specialDesInfo
					}
				else
					advanceProperty[order] = {
						propName = propName,
						prop = propValue,
						extraProp = extraProp,
						icon = v1.icon,
						dec = v1.dec,
						showType = v1.showType,
						specialDesInfo = specialDesInfo
					}
				end
			end
		end

		local ret = {}

		ret[1] = {
			tIndex = 1,
			name = pg.getGameString("BASE_PROPERTY")
		}

		for _, v in pairs(baseProperty) do
			ret[#ret + 1] = {
				tIndex = 0,
				name = v.propName,
				icon = v.icon,
				value = v.prop,
				desc = v.dec,
				extraProp = v.extraProp,
				specialDesInfo = v.specialDesInfo
			}
		end

		ret[#ret + 1] = {
			tIndex = 1,
			name = pg.getGameString("ADVANCE_PROPERTY")
		}

		for _, v in pairs(advanceProperty) do
			ret[#ret + 1] = {
				tIndex = 0,
				name = v.propName,
				icon = v.icon,
				value = v.prop,
				desc = v.dec,
				extraProp = v.extraProp,
				specialDesInfo = v.specialDesInfo
			}
		end

		return ret
	end

	function LuaUIUtils.m_customParseFloatPropVal(propValue, excludeZero)
		propValue = propValue or 0

		local intPart = math.floor(propValue)
		local decimalPart = propValue - intPart
		local absDecimal = math.abs(decimalPart)
		local firstDecimal = math.floor(absDecimal * 10)
		local secondDecimal = math.floor(absDecimal * 100) % 10
		local finalFirstDecimal = firstDecimal

		if firstDecimal == 9 and secondDecimal >= 5 then
			finalFirstDecimal = 9
		elseif secondDecimal >= 5 then
			finalFirstDecimal = finalFirstDecimal + 1

			if finalFirstDecimal == 10 then
				intPart = intPart + (decimalPart >= 0 and 1 or -1)
				finalFirstDecimal = 0
			end
		end

		local sign = decimalPart < 0 and "-" or ""
		local result

		if excludeZero == true and finalFirstDecimal == 0 then
			result = string.format("%s%d", sign, math.abs(intPart))
		else
			result = string.format("%s%d.%d", sign, math.abs(intPart), finalFirstDecimal)
		end

		if sign == "-" and intPart == 0 then
			result = "-" .. result:sub(2)
		end

		return result
	end

	function LuaUIUtils.getElementDataTable(elementName)
		if LuaUIUtils.ELEMENT_BTN_DATA_TABLE[elementName] == nil and ElementNameToId[elementName] then
			local data = ElementPropData[ElementNameToId[elementName]]

			if data then
				LuaUIUtils.ELEMENT_BTN_DATA_TABLE[elementName] = {
					elementName = data.name,
					isShow = data.isShow
				}
			end
		end

		return LuaUIUtils.ELEMENT_BTN_DATA_TABLE[elementName]
	end

	function LuaUIUtils.rendererPlayerGender(icon, templateId)
		if templateId == 3 then
			-- block empty
		end
	end

	function LuaUIUtils.setTalentBtn(btnTalentUButton, breedTalent)
		function btnTalentUButton.luaClick()
			local talentData = {}

			talentData.targetRect = btnTalentUButton
			talentData.autoHor = true
			talentData.type = UIConst.GIFT_TYPE.BATTLE
			talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
			talentData.giftType = UIConst.GIFT_TYPE.HOME
			talentData.breedTalent = breedTalent
			talentData.extra = {
				openFun = function()
					btnTalentUButton.isSelected = true

					btnTalentUButton:TryChangePage("button", 5)
				end,
				closeFun = function()
					btnTalentUButton.isSelected = false

					btnTalentUButton:TryChangePage("button", 0)
				end
			}

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
		end
	end

	function LuaUIUtils.renderTalentItem(button, talentTemplateId)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")
		local talentData = PetTalentData[talentTemplateId] or {}

		iconUImage.url = talentData.talentIcon
		button.tooltipMode = 0

		rayBoxUWidget.gameObject:SetActiveEx(false)
		button:TryChangePage("Quality", talentData.rarity)
	end

	function LuaUIUtils.getPetVideoRes(templateId, label)
		if label == Const.PET_LABEL_MASK.SHINY then
			local res = string.format("$%s_Shiny.mp4", templateId)

			if pg.global.resMgr:CheckAssetExist(res) then
				return res
			end
		end

		local res = string.format("$%s.mp4", templateId)

		return res
	end

	function LuaUIUtils.renderCatchRogueCenterPet(index, button, gameId)
		local objectReference = button:GetComponent("ObjectReference")
		local characterUImage = objectReference:GetRefValue("characterUImage")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
		local textTypeUBaseText = objectReference:GetRefValue("textTypeUBaseText")
		local character2UImage = objectReference:GetRefValue("character2UImage")
		local listElementUList = objectReference:GetRefValue("listElementUList")
		local textType2UBaseText = objectReference:GetRefValue("textType2UBaseText")
		local btnPet1UButton = objectReference:GetRefValue("btnPet1UButton")
		local btnPet2UButton = objectReference:GetRefValue("btnPet2UButton")
		local listElement2UList = objectReference:GetRefValue("listElement2UList")
		local label1Root = objectReference:GetRefValue("label1Root")
		local label2Root = objectReference:GetRefValue("label2Root")
		local first, second = index * 2 - 1, index * 2
		local templateId1 = CatchRoguePhaseData[gameId].keyPetType[first]
		local templateId2 = CatchRoguePhaseData[gameId].keyPetType[second]
		local c1Data = PetData[templateId1] or {}
		local c2Data = PetData[templateId2] or {}

		button.draggable = false

		ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(c1Data.name))

		function btnPet1UButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				needShowForm = true,
				templateId = templateId1,
				fromCatchRogueGameId = gameId
			})
		end

		function btnPet2UButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				needShowForm = true,
				templateId = templateId2,
				fromCatchRogueGameId = gameId
			})
		end

		local petIcon = LuaUIUtils.getPetIcon(c1Data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

		characterUImage.url = petIcon

		local isRainbow1 = Utils.isRainbowTypeByTemplateId(templateId1)

		label1Root:TryChangePage("Status", isRainbow1 and "RainbowLight" or "Weather")

		if not isRainbow1 then
			ClientTextUtils.setText(textTypeUBaseText, LuaUIUtils.getPetFormName(templateId1))
		end

		character2UImage.url = LuaUIUtils.getPetIcon(c2Data.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

		local isRainbow2 = Utils.isRainbowTypeByTemplateId(templateId2)

		label2Root:TryChangePage("Status", isRainbow2 and "RainbowLight" or "Weather")

		if not isRainbow2 then
			ClientTextUtils.setText(textType2UBaseText, LuaUIUtils.getPetFormName(templateId2))
		end

		local _, names = LuaUIUtils.getElementInfo(c1Data.elementType)
		local temp = {}

		for _, info in ipairs(names) do
			temp[#temp + 1] = info.element
		end

		LuaUIUtils.renderPetElement(listElementUList, temp)

		local _, names2 = LuaUIUtils.getElementInfo(c2Data.elementType)

		temp = {}

		for _, info in ipairs(names2) do
			temp[#temp + 1] = info.element
		end

		LuaUIUtils.renderPetElement(listElement2UList, temp)
	end

	function LuaUIUtils.renderCatchRogueCommonPet(button, index, data)
		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				needShowForm = true,
				templateId = data.templateId,
				fromCatchRogueGameId = data.gameId
			})
		end

		button.draggable = false
		button.enabledTooltip = false

		local objectRef = button:GetComponent("ObjectReference")
		local icon = objectRef:GetRefValue("iconUImage")
		local cData = PetData[data.templateId] or {}
		local petIcon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON)

		icon.url = petIcon
	end

	function LuaUIUtils.tryOpenPetCultivateUI(info, cb, closeCb, sceneParams, onlyCheck)
		local toPage = info and info.toPage
		local ret, funcEnum = LuaUIUtils.getIsCultivateSubCompUnLocked(toPage)

		if not ret then
			local tipDesc = pg.getLocalizationText(funcEnum and FuncIdConfigData[funcEnum].unlockDesc)

			pg.global.ui.tips:showTextTip(tipDesc)

			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("tryOpenPetCultivateUI: 宠物养成子界面组件[%s]由于[%s]未解锁无法打开", toPage, tipDesc or "")
			end

			return false
		end

		if not onlyCheck then
			pg.global.ui:open(UIConst.UI_ID_PET_TRAINING_NEW, info, cb, closeCb, sceneParams)
		end

		return true
	end

	function LuaUIUtils.getIsCultivateSubCompUnLocked(subCompType)
		local subCompChecks = {
			[Const.PetCulPageIndex2Name[Const.PetCulPages.CARRY]] = {
				funcEnumName = "PETEQUIPMENT",
				funcEnum = FunctionEnum.PETEQUIPMENT,
				checkCanOpenFunc = function()
					return pg and pg.me and pg.me:isFunctionAndSwitchEnable(FunctionEnum.PETEQUIPMENT)
				end
			},
			[Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT]] = {
				funcEnumName = "PETPOTENTIAL",
				funcEnum = FunctionEnum.PETPOTENTIAL,
				checkCanOpenFunc = function()
					return pg and pg.me and pg.me:isFunctionAndSwitchEnable(FunctionEnum.PETPOTENTIAL)
				end
			},
			[Const.PetCulPageIndex2Name[Const.PetCulPages.STARUP]] = {
				funcEnumName = "PETRISINGSTAR",
				funcEnum = FunctionEnum.PETRISINGSTAR,
				checkCanOpenFunc = function()
					return pg and pg.me and pg.me:isFunctionAndSwitchEnable(FunctionEnum.PETRISINGSTAR)
				end
			}
		}

		if LuaUIUtils.getIsDebugForceOpenPetCulUI() then
			return true
		end

		local checkInfo = subCompChecks[subCompType]

		if checkInfo then
			local isValidFuncName = FunctionEnum[checkInfo.funcEnum] or CommonSwitch[checkInfo.funcEnum] ~= nil

			if isValidFuncName then
				return checkInfo.checkCanOpenFunc(), checkInfo.funcEnum
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("LuaUIUtils.getIsCultivateSubCompUnLocked: [%s]功能开关[%s]没有配置 @fenghao ", subCompType, checkInfo.funcEnumName)
			end
		end

		return true
	end

	function LuaUIUtils.getIsDebugForceOpenPetCulUI()
		return false
	end

	function LuaUIUtils.renderPetHeadEvolveArrow(petBtn, inBatch, data)
		local objectReference = petBtn:GetComponent("ObjectReference")
		local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")

		if inBatch then
			iconEvolveUImage.gameObject:SetActiveEx(false)

			return
		end

		LuaUIUtils.m_renderPetHeadEvolveArrow(iconEvolveUImage, data)
	end

	function LuaUIUtils.m_renderPetHeadEvolveArrow(iconEvolveUImage, data, forceHideEvo)
		if not iconEvolveUImage or not data then
			return
		end

		if forceHideEvo then
			iconEvolveUImage.gameObject:SetActiveEx(false)

			return
		end

		local petInfo = pg.me and pg.me:getPetInfo(data and data.id)

		if not petInfo then
			iconEvolveUImage.gameObject:SetActiveEx(false)

			return
		end

		local isCanEvolve = data and data.canEvolve or false

		if isCanEvolve then
			iconEvolveUImage.gameObject:SetActiveEx(true)

			iconEvolveUImage.url = AddressDataConst.CAN_EVOLUTION_ARROW

			return
		end

		local templateId = data.templateId
		local canEvolveConfig = PetEvolveData[templateId] and PetEvolveData[templateId][1] and PetEvolveData[templateId][1].targetPetId

		if not canEvolveConfig then
			iconEvolveUImage.gameObject:SetActiveEx(false)

			return
		end

		local isReachedExcludeWhiteConds = false
		local evolveBranchesInfo = petInfo:getEvolveBranchesInfo()

		if evolveBranchesInfo and next(evolveBranchesInfo) then
			for _, branchInfo in pairs(evolveBranchesInfo) do
				isReachedExcludeWhiteConds = branchInfo and branchInfo.isReachedExcludeWhiteConds or isReachedExcludeWhiteConds
			end
		end

		if not isReachedExcludeWhiteConds and not isCanEvolve then
			iconEvolveUImage.gameObject:SetActiveEx(false)

			return
		end

		iconEvolveUImage.gameObject:SetActiveEx(true)

		iconEvolveUImage.url = isReachedExcludeWhiteConds and AddressDataConst.CANT_EVOLUTION_ARROW or AddressDataConst.CAN_EVOLUTION_ARROW
	end

	function LuaUIUtils.openPetOverviewFromMap(areaId, showTab, switchTabCallback, closeCallback)
		if not areaId then
			return
		end

		pg.global.ui.petOverview:open({
			enableTooltip = false,
			areaId = areaId,
			showTab = showTab,
			checkShowMapView = function(data)
				return data.templateId == pg.game.map.activeDistributionPetTemplateId
			end,
			exRenderFunc = function(button, index, data, currentShowTab)
				local info = {
					state = LuaUIUtils.PetInfoState.Catch,
					petPrototypeId = data.templateId
				}

				LuaUIUtils.renderPetTip(button, info, nil, nil, true, {
					showDistributionBtn = true,
					distributionShowTab = currentShowTab,
					showPetDistributionAreaCb = function()
						pg.global.ui.petOverview:close()
					end
				})

				data._canShow = next(LuaUIUtils.checkPetCanShowDistributionArea(data.templateId))
				button.enabledTooltip = data._canShow
				button.visualInteractable = data._canShow

				button:TryChangePage("button", data._canShow and 0 or 4)
			end,
			clickFunc = function(data)
				if not data._canShow then
					pg.global.showBubbleMessageRaw(pg.getGameString("PET_DATA_LACK"))
				end
			end,
			switchTabCallback = switchTabCallback
		}, nil, closeCallback)
	end

	function LuaUIUtils.refreshPetFertilityCubeInfo(petCubeItemId, ballGetUWidget, iconBallUImage)
		ballGetUWidget:SetActive(petCubeItemId ~= nil and petCubeItemId ~= 0)

		if petCubeItemId then
			iconBallUImage.url = LuaUIUtils.getIconByItemId(petCubeItemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL) or ""
		end
	end

	function LuaUIUtils.refreshPetPanelInfoBackground(petCubeItemId, panelInfoObjectReference)
		local panelInfoUComponent = panelInfoObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
		local _, state = panelInfoUComponent:TryGetCurrentPage("State")
		local backgroundRefName, backgroundCfgName, defaultBackground

		if state == 0 then
			backgroundRefName = "managementBgUImage"
			backgroundCfgName = "petBackground1"
			defaultBackground = DEFAULT_MANAGEMENT_PET_BACKGROUND
		elseif state == 1 then
			backgroundRefName = "chatBgUImage"
			backgroundCfgName = "petBackground2"
			defaultBackground = DEFAULT_CHAT_PET_BACKGROUND
		else
			return
		end

		local ballCfg = petCubeItemId and petCubeItemId ~= 0 and CaptureUtils.getBallCfg(petCubeItemId)
		local backgroundUImage = panelInfoObjectReference:GetRefValue(backgroundRefName)

		if backgroundUImage then
			local background = ballCfg and ballCfg[backgroundCfgName]

			backgroundUImage.url = background and background ~= "" and background or defaultBackground
		end

		local shadingUImage = panelInfoObjectReference:GetRefValue("shadingUImage")

		if shadingUImage then
			local petBallFigure = ballCfg and ballCfg.petBallFigure

			shadingUImage.url = petBallFigure and petBallFigure ~= "" and petBallFigure or DEFAULT_PET_BALL_FIGURE
		end
	end

	function LuaUIUtils.refreshPetPanelInfoCubeAndBackground(petCubeItemId, panelInfoObjectReference)
		local ballGetUWidget = panelInfoObjectReference:GetRefValue("ballGetUWidget")
		local iconBallUImage = panelInfoObjectReference:GetRefValue("iconBallUImage")

		LuaUIUtils.refreshPetFertilityCubeInfo(petCubeItemId, ballGetUWidget, iconBallUImage)
		LuaUIUtils.refreshPetPanelInfoBackground(petCubeItemId, panelInfoObjectReference)
	end

	function LuaUIUtils.getSealedEggDescArgs(itemId)
		local sealedPetMap = pg.me and pg.me.sealedPetMap
		local sealedPetInfo = sealedPetMap and sealedPetMap[itemId]

		if not sealedPetInfo then
			return nil
		end

		local templateId = sealedPetInfo.templateId
		local petData = PetData[templateId]

		if not petData then
			return nil
		end

		local shinyText = ""

		if Utils.isLabelShiny(sealedPetInfo.label) then
			shinyText = pg.getGameString("PET_SHINY_LABEL_TITLE")
		end

		local formName = LuaUIUtils.getPetFormName(templateId)
		local petName = pg.getLocalizationText(petData.name)

		return shinyText, formName, petName
	end

	function LuaUIUtils.checkSealedEggCanHatch(itemId)
		local player = pg.me
		local sealedPetInfo = player and player.sealedPetMap and player.sealedPetMap[itemId]

		if not sealedPetInfo then
			return false
		end

		local petData = PetData[sealedPetInfo.templateId]
		local petPrototypeId = petData and petData.petPrototypeId
		local petHandbookMap = player.petHandbookMap

		if not petPrototypeId or not petHandbookMap then
			return false
		end

		local handbookInfo = petHandbookMap[petPrototypeId]

		return handbookInfo ~= nil and handbookInfo:isCatched()
	end

	function LuaUIUtils.safeSetUWidgetActive(uWidget, active)
		if IsNil(uWidget) then
			return
		end

		uWidget:SetActive(active)
	end

	function LuaUIUtils.safeSetGameObjectActive(gameObject, active)
		if IsNil(gameObject) then
			return
		end

		gameObject:SetActiveEx(active)
	end

	function LuaUIUtils.safeTryChangePage(uComponent, pageName, pageIndex)
		if IsNil(uComponent) or not pageName then
			return
		end

		uComponent:TryChangePage(pageName, pageIndex or 0)
	end

	function LuaUIUtils.generalRefreshCarryCertifyComp(contactTransform, certifiedBaseFormPetId)
		if NotNil(contactTransform) then
			local isCoreCarryCertified = certifiedBaseFormPetId ~= nil and certifiedBaseFormPetId ~= 0

			contactTransform.gameObject:SetActiveEx(isCoreCarryCertified)

			if isCoreCarryCertified then
				local iconPetContactTransform = contactTransform and contactTransform:Find("Pet/Mask/IconPetContact")
				local iconPetContactUImage = iconPetContactTransform and iconPetContactTransform:GetComponent("UImage")

				if NotNil(iconPetContactUImage) then
					iconPetContactUImage.url = LuaUIUtils.getPetIconByTemplateId(certifiedBaseFormPetId, LuaUIUtils.PET_ICON) or ""
				end
			end
		end
	end
end
