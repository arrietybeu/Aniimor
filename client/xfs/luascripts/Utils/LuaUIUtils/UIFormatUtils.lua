-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIFormatUtils.lua

local ElementPropData = require("Data.element_prop_data")
local PuppetData = require("Data.puppet_data")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ItemSourceData = require("Data.item_source_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local FormulaExplictData = require("Data.formula_explict_data")
local GameStringConfig = require("Data.gamestring_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local FormulaData = require("Data.formula_data")
local AbilityCalcValData = require("Data.ability_calc_value_data")
local TimelineCalcValData = require("Data.timeline_calc_value_data")
local BuffCalcValueData = require("Data.buff_calc_value_data")

local function trimDecimal(v)
	if type(v) ~= "number" then
		return v
	end

	if v == math.floor(v) then
		return v
	end

	local s = string.format("%.2f", v)

	s = s:gsub("0+$", "")
	s = s:gsub("%.$", "")

	return s
end

local function formatValue(value, isPercent, formatStr)
	local needPercent = ToBool(isPercent)

	if needPercent then
		value = value * 100
	end

	local result = string.isNilOrEmpty(formatStr) and tostring(trimDecimal(value)) or string.format(formatStr, value)

	if needPercent then
		result = result .. "%"
	end

	return result
end

local function buildFormulaExplictFormatArgs(calcData, explictData)
	local formulaByPetCacheProp = calcData.formulaByPetCacheProp
	local baseValue = 0

	for i = 2, 6 do
		if type(formulaByPetCacheProp[i]) == "number" then
			baseValue = formulaByPetCacheProp[i]

			break
		end
	end

	local val1 = formatValue(math.abs(explictData.minNum * baseValue), explictData.isPercent, explictData.formatStr)
	local val2 = tostring(trimDecimal(math.abs(explictData.rate)))
	local val3 = ClientTextUtils.getLocalizationText(explictData.name)
	local val4 = formatValue(math.abs(explictData.upRate * explictData.rate * baseValue), explictData.isPercent2, explictData.formatStr2)
	local val5 = formatValue(math.abs(explictData.maxNum * baseValue), explictData.isPercent3, explictData.formatStr3)
	local iconUrl = explictData.icon
	local val6 = string.isNilOrEmpty(iconUrl) and "" or iconUrl

	return val1, val2, val3, val4, val5, val6
end

local function getCalcDataByArgs(tableName, key, paramName, level)
	if tableName == "ability" then
		return AbilityCalcValData[key] and AbilityCalcValData[key][paramName] and AbilityCalcValData[key][paramName][level] and AbilityCalcValData[key][paramName][level]
	elseif tableName == "buff" then
		return BuffCalcValueData[key] and BuffCalcValueData[key][paramName] and BuffCalcValueData[key][paramName][level] and BuffCalcValueData[key][paramName][level]
	elseif tableName == "timeline" then
		return TimelineCalcValData[key] and TimelineCalcValData[key][paramName] and TimelineCalcValData[key][paramName]
	end
end

local IsNil = IsNil
local ToBool = ToBool
local MAX_PET_ITEM_SOURCE_LINK_DEPTH = 8
local PET_ITEM_SOURCE_TOOLTIP_HORIZONTAL_GAP = 36

local function getPetItemSourceTips(LuaUIUtils, sourceData, petInfo)
	if not sourceData.tips then
		return ""
	end

	local previousPetInfo = LuaUIUtils.customRichTextData.petInfo

	LuaUIUtils.customRichTextData.petInfo = petInfo

	local tips = pg.getLocalizationText(sourceData.tips)

	LuaUIUtils.customRichTextData.petInfo = previousPetInfo

	return tips or ""
end

local function normalizeHyperlinkAction(rawAction)
	local action = string.trim(rawAction)
	local firstChar = string.sub(action, 1, 1)
	local lastChar = string.sub(action, -1)

	if firstChar == "\"" and lastChar == "\"" or firstChar == "'" and lastChar == "'" then
		action = string.sub(action, 2, -2)
	end

	return action
end

local function getHyperlinkSuffix(actionList)
	local suffix = actionList[2]

	for i = 3, #actionList do
		suffix = string.format("%s_%s", suffix, actionList[i])
	end

	return suffix
end

local function getCalcDataLinkContent(LuaUIUtils, actionList)
	local strArray = string.split(getHyperlinkSuffix(actionList), ",")
	local level = LuaUIUtils.customRichTextData[strArray[4]] or tonumber(strArray[4])
	local calcData = getCalcDataByArgs(strArray[1], tonumber(strArray[2]), strArray[3], level)

	if not calcData then
		return ""
	end

	local explictData = FormulaExplictData[calcData.formulaExplictId]
	local gameStringData = explictData and GameStringConfig[explictData.hyperlinkDes]

	if not explictData or not gameStringData then
		return ""
	end

	local desc = ClientTextUtils.getLocalizationText(gameStringData.desc)
	local val1, val2, val3, val4, val5, val6 = buildFormulaExplictFormatArgs(calcData, explictData)

	return pg.getFormatText(desc, 0, val1, val2, val3, val4, val5, val6)
end

local function resolveEmbeddedHyperlink(LuaUIUtils, rawAction, petInfo)
	local action = normalizeHyperlinkAction(rawAction)

	if string.isNilOrEmpty(action) then
		return nil
	end

	local actionList = string.split(action, "_")
	local prefixType = actionList[1]

	if prefixType == UIConst.RICH_TEXT_LINK_TYPE.SOURCE then
		local sourceId = tonumber(actionList[2])
		local sourceData = sourceId and ItemSourceData[sourceId]

		if not sourceData then
			return action, ""
		end

		return action, getPetItemSourceTips(LuaUIUtils, sourceData, petInfo)
	elseif prefixType == "calcDataLink" then
		return action, getCalcDataLinkContent(LuaUIUtils, actionList)
	end

	return nil
end

local function getEmbeddedHyperlinkText(content, sourceData)
	local linkText = content or ""

	linkText = string.gsub(linkText, "<u[^>]*>", "")
	linkText = string.gsub(linkText, "</u>", "")

	if not string.isNilOrEmpty(linkText) then
		return linkText
	end

	return sourceData and sourceData.buttonTxt and pg.getLocalizationText(sourceData.buttonTxt) or ""
end

local function collectPetItemSourceLinkDetails(LuaUIUtils, tips, petInfo, visitedSourceIdSet, detailsList, depth)
	if string.isNilOrEmpty(tips) or depth >= MAX_PET_ITEM_SOURCE_LINK_DEPTH or not string.find(tips, "<link", 1, true) then
		return
	end

	for rawAction, linkContent in string.gmatch(tips, "<link%s*=%s*([^>]+)>(.-)</link>") do
		local actionKey, childTips = resolveEmbeddedHyperlink(LuaUIUtils, rawAction, petInfo)

		if actionKey and not visitedSourceIdSet[actionKey] then
			visitedSourceIdSet[actionKey] = true

			if not string.isNilOrEmpty(childTips) then
				local actionList = string.split(actionKey, "_")
				local sourceData = actionList[1] == UIConst.RICH_TEXT_LINK_TYPE.SOURCE and ItemSourceData[tonumber(actionList[2])] or nil
				local linkText = getEmbeddedHyperlinkText(linkContent, sourceData)

				detailsList[#detailsList + 1] = {
					text = pg.getFormatText(pg.getGameString("PET_INFO_LINE_TIP"), linkText, childTips)
				}

				collectPetItemSourceLinkDetails(LuaUIUtils, childTips, petInfo, visitedSourceIdSet, detailsList, depth + 1)
			end
		end
	end
end

local function openPetItemSourceTooltip(LuaUIUtils, sourceId, content, contentRect, petInfo, tooltipAnchor)
	local sourceData = ItemSourceData[sourceId]

	if not sourceData then
		return false
	end

	local tips = getPetItemSourceTips(LuaUIUtils, sourceData, petInfo)
	local detailsList = {}
	local rootActionKey = string.format("source_%s", sourceId)

	if petInfo and petInfo.id then
		rootActionKey = string.format("%s_%s", rootActionKey, petInfo.id)
	end

	collectPetItemSourceLinkDetails(LuaUIUtils, tips, petInfo, {
		[rootActionKey] = true
	}, detailsList, 0)

	local title = sourceData.buttonTxt and pg.getLocalizationText(sourceData.buttonTxt) or ""

	if string.isNilOrEmpty(title) then
		title = getEmbeddedHyperlinkText(content, sourceData)
	end

	pg.global.ui:open(UIConst.UI_ID_TOOLTIP_SKILL_INFO_WITH_TITLE, {
		title = title,
		infoText = tips,
		detailsList = detailsList,
		targetRect = tooltipAnchor or contentRect,
		tooltipAnchor = tooltipAnchor
	})

	return true
end

local function getTargetSortingOrder(targetRect)
	if not targetRect then
		return
	end

	local transform = targetRect.transform

	while transform do
		local widget = transform:GetComponent("UWidget")

		if widget then
			return widget.sortingOrder
		end

		transform = transform.parent
	end
end

return function(LuaUIUtils)
	function LuaUIUtils._formatRawNumber(num)
		local value = tonumber(num)

		if value == nil or value ~= value then
			return tostring(num or 0)
		end

		if math.floor(value) == value then
			return string.format("%.0f", value)
		end

		return tostring(num)
	end

	function LuaUIUtils._getLocalizedShortNumberUnitText(textKey)
		local unitText = ClientTextUtils.getGameString(textKey)

		if string.isNilOrEmpty(unitText) or unitText == textKey then
			return ""
		end

		return unitText
	end

	function LuaUIUtils._getShortNumberUnitInfo(absValue, useThousandBase)
		if useThousandBase then
			if absValue >= 1000000000000 then
				return 1000000000000, "T"
			elseif absValue >= 1000000000 then
				return 1000000000, "B"
			elseif absValue >= 1000000 then
				return 1000000, "M"
			elseif absValue >= 1000 then
				return 1000, "K"
			end

			return nil, nil
		end

		if absValue >= 1000000000000 then
			return 1000000000000, LuaUIUtils._getLocalizedShortNumberUnitText("TRILLION")
		elseif absValue >= 100000000 then
			return 100000000, LuaUIUtils._getLocalizedShortNumberUnitText("HUNDRED_MILLION")
		elseif absValue >= 10000 then
			return 10000, LuaUIUtils._getLocalizedShortNumberUnitText("TEN_THOUSAND")
		end

		return nil, nil
	end

	function LuaUIUtils._formatShortNumberByBase(num, useThousandBase, decimalPlaces)
		local value = tonumber(num)

		if value == nil or value ~= value then
			return tostring(num or 0), true
		end

		local absValue = math.abs(value)
		local unitValue, unitText = LuaUIUtils._getShortNumberUnitInfo(absValue, useThousandBase)

		if unitValue == nil then
			return LuaUIUtils._formatRawNumber(num), true
		end

		if string.isNilOrEmpty(unitText) then
			return nil, false
		end

		local precision = decimalPlaces == 0 and 0 or 1
		local scale = 10^precision
		local shortValue = math.floor(absValue / unitValue * scale) / scale
		local prefix = value < 0 and "-" or ""
		local valueText = string.format("%s%." .. precision .. "f", prefix, shortValue)

		if useThousandBase or pg.languageType == ClientConst.LANGUAGE_TYPE_MAP.ko_KR then
			return valueText .. unitText, true
		end

		return ClientTextUtils.concatByLanguage(valueText, unitText), true
	end

	function LuaUIUtils._isShortNumberTenThousandLanguage(language)
		return language == ClientConst.LANGUAGE_TYPE_MAP.zh_CN or language == ClientConst.LANGUAGE_TYPE_MAP.zh_TW or language == ClientConst.LANGUAGE_TYPE_MAP.ko_KR or language == ClientConst.LANGUAGE_TYPE_MAP.ja_JP
	end

	function LuaUIUtils.formatShortNumber(num, decimalPlaces)
		local selectedLanguage = pg.languageType

		if LuaUIUtils._isShortNumberTenThousandLanguage(selectedLanguage) and not string.isNilOrEmpty(LuaUIUtils._getLocalizedShortNumberUnitText("TEN_THOUSAND")) then
			local tenThousandText, hasTenThousandUnitText = LuaUIUtils._formatShortNumberByBase(num, false, decimalPlaces)

			if hasTenThousandUnitText then
				return tenThousandText
			end
		end

		local thousandText = LuaUIUtils._formatShortNumberByBase(num, true, decimalPlaces)

		return thousandText or LuaUIUtils._formatRawNumber(num)
	end

	function LuaUIUtils.alignTooltipToAnchorLeftTop(tooltip, tooltipAnchor)
		local anchorRectTransform = tooltipAnchor.rectTransform
		local anchorRect = anchorRectTransform.rect
		local anchorLeftTop = anchorRectTransform:TransformPoint(anchorRect.xMin - PET_ITEM_SOURCE_TOOLTIP_HORIZONTAL_GAP, anchorRect.yMax, 0)

		tooltip.rectTransform:SetPivotEx(1, 1)

		local tooltipPosition = tooltip.position

		tooltip.enabledConstrainToScreen = true

		tooltip:SetPositionEx(anchorLeftTop.x, anchorLeftTop.y, tooltipPosition.z)
	end

	function LuaUIUtils.getElementColorHex(elementId)
		local elementInfo = ElementPropData[elementId] or {}

		return elementInfo.colourValue or "#FFFFFF"
	end

	function LuaUIUtils.getFormatNumber(number)
		if number < 10 then
			return string.format("00%s", number)
		elseif number < 100 then
			return string.format("0%s", number)
		else
			return number
		end
	end

	function LuaUIUtils.getResNameWithoutFormat(fullName)
		local t = string.split(fullName, ".")

		if #t > 2 then
			return nil
		end

		return t[1]
	end

	function LuaUIUtils.customSetText(uBaseText, txtCont, isEnableHyperLink, extraLinkFunc, tooltipAnchor)
		if not uBaseText then
			return
		end

		uBaseText.enabledHyperlink = isEnableHyperLink

		function uBaseText.luaOnHyperlinkClick(action, content, contentRect)
			if NotNil(action) then
				LuaUIUtils.clickHyperText(action, content, contentRect, tooltipAnchor)

				if extraLinkFunc then
					extraLinkFunc(action, content, contentRect)
				end
			end
		end

		ClientTextUtils.setText(uBaseText, txtCont)
	end

	function LuaUIUtils.resolveHyperTextEffect(action)
		if type(action) ~= "string" then
			return nil
		end

		local separatorIndex = string.find(action, "_", 1, true)

		if not separatorIndex or separatorIndex == 1 or separatorIndex == #action then
			return nil
		end

		local prefixType = string.sub(action, 1, separatorIndex - 1)

		if prefixType == UIConst.RICH_TEXT_LINK_TYPE.ITEM or prefixType == UIConst.RICH_TEXT_LINK_TYPE.SOURCE or prefixType == "calcDataLink" then
			return LuaUIUtils.HYPERLINK_EFFECT.TOOLTIP
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.HELP or prefixType == UIConst.RICH_TEXT_LINK_TYPE.APPEAR_HELP or prefixType == UIConst.RICH_TEXT_LINK_TYPE.WEB or prefixType == UIConst.RICH_TEXT_LINK_TYPE.SURVEY then
			return LuaUIUtils.HYPERLINK_EFFECT.OTHER
		end

		return nil
	end

	function LuaUIUtils.clickHyperText(action, content, infoText, tooltipAnchor)
		if action == nil or action == "" then
			return
		end

		local anchorRect = infoText

		if infoText then
			local t = infoText.transform.parent

			while t do
				local popup = t:GetComponent("UPopupForm")

				if popup then
					anchorRect = popup

					break
				end

				t = t.parent
			end
		end

		action = string.split(action, "_")

		local prefixType = action[1]
		local suffixStr = action[2]

		if string.isNilOrEmpty(prefixType) or string.isNilOrEmpty(suffixStr) then
			return
		end

		if prefixType == UIConst.RICH_TEXT_LINK_TYPE.ITEM then
			local itemId = tonumber(suffixStr)
			local itemTipCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_COMMON_ITEM_TIP)
			local isSameItemTip = itemTipCtrl and itemTipCtrl:checkUIShow() and itemTipCtrl.iData and itemTipCtrl.iData.id == itemId

			if isSameItemTip then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			else
				local targetRect = tooltipAnchor or anchorRect
				local targetSortingOrder = getTargetSortingOrder(targetRect)

				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					num = 1,
					id = itemId,
					targetRect = targetRect,
					autoHor = tooltipAnchor and true or nil,
					padding = tooltipAnchor and 8 or nil,
					hierarchyMode = targetSortingOrder and 0 or nil,
					sortingOrder = targetSortingOrder and targetSortingOrder + 1 or nil
				})
			end
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.HELP then
			if pg.global.ui:checkUIShow(UIConst.UI_ID_HELP) then
				pg.global.ui:close(UIConst.UI_ID_HELP)
			else
				pg.global.ui:open(UIConst.UI_ID_HELP, {
					helpGroupId = tonumber(suffixStr)
				})
			end
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.APPEAR_HELP then
			local res, helpId = pg.global.ui.help.model.getHelpIdByGroupId(tonumber(suffixStr))

			if res then
				pg.me:doEventByData({
					"appearHelp",
					{
						helpId
					}
				})
			end
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.SOURCE then
			local sourceData = ItemSourceData[tonumber(suffixStr)]

			if pg.global.ui:checkUIShow(UIConst.UI_ID_CLUE_SEEK_TIP) then
				pg.global.ui:close(UIConst.UI_ID_CLUE_SEEK_TIP)
			elseif not LuaUIUtils.checkItemSourceCondition(sourceData) then
				if sourceData and sourceData.conditionToast then
					ClientUtils.showBubbleMessage(sourceData.conditionToast)
				end
			else
				local petInfo
				local petId = action[3]

				if petId then
					for i = 4, #action do
						petId = string.format("%s_%s", petId, action[i])
					end

					petInfo = pg.me:getPetInfo(petId)
				end

				local isPetItemSource = petId ~= nil
				local handled = isPetItemSource and openPetItemSourceTooltip(LuaUIUtils, tonumber(suffixStr), content, infoText, petInfo, tooltipAnchor)

				if not handled then
					pg.global.ui:open(UIConst.UI_ID_CLUE_SEEK_TIP, {
						autoVer = true,
						autoHor = false,
						useCustomLayout = true,
						clueSeekID = tonumber(suffixStr),
						targetRect = tooltipAnchor or anchorRect,
						tooltipAnchor = tooltipAnchor,
						horAlign = CS.XGUI.EHorizontalAlignment.Center,
						verAlign = CS.XGUI.EVerticalAlignment.Bottom,
						petInfo = petInfo
					})
				end
			end
		elseif prefixType == "calcDataLink" then
			local infoText = getCalcDataLinkContent(LuaUIUtils, action)

			if not string.isNilOrEmpty(infoText) then
				pg.global.ui:open(UIConst.UI_ID_TOOLTIP_SKILL_INFO_WITH_TITLE, {
					title = pg.getGameString("CALC_DATA_TITLE"),
					infoText = infoText,
					targetRect = tooltipAnchor or anchorRect,
					tooltipAnchor = tooltipAnchor
				})
			end
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.SURVEY then
			local uid = pg.me.uid or pg.global.sdkManager:getAccountId()
			local url = string.format("%s?uid=%s", suffixStr, uid)
			local isConsole = pg.global.platform ~= nil and pg.global.platform:isConsole()

			if isConsole then
				local isCn = ClientConfigAppCountry == "cn"
				local qrUrl = isCn and "https://www.yimo.com/survey" or "https://www.aniimo.com/survey"

				url = string.format("%s?uid=%s", qrUrl, uid)
			end

			pg.global.sdkManager:openUrl("LuaUIUtils", "UIConst.RICH_TEXT_LINK_TYPE.SURVEY", url)
		elseif prefixType == UIConst.RICH_TEXT_LINK_TYPE.WEB then
			if tonumber(suffixStr) == UIConst.RICH_TEXT_LINK_TYPE_EX.BANSHU then
				pg.global.sdkManager:openUrl("LuaUIUtils", "UIConst.RICH_TEXT_LINK_TYPE_EX.BANSHU", Const.Legal_App_Tip)
			else
				local url = LuaUIUtils.suffixNumb(action)

				pg.global.sdkManager:openUrl("LuaUIUtils", "UIConst.RICH_TEXT_LINK_TYPE.WEB", url)
			end
		end
	end

	function LuaUIUtils.suffixNumb(action)
		return getHyperlinkSuffix(action)
	end

	function LuaUIUtils.parsePlayerName()
		return pg.me and pg.me.playerName or nil
	end

	function LuaUIUtils.parseChosenTwinPuppetName()
		if not pg.me then
			return nil
		end

		if pg.me.twinPetChoiceIndex == 0 then
			return nil
		end

		local puppetTemplateId = Utils.getTwinPuppetTemplateId(pg.me.twinPetChoiceIndex)

		return PuppetData[puppetTemplateId] and PuppetData[puppetTemplateId].name or nil
	end

	function LuaUIUtils.parsePlayerGender()
		if not pg.me then
			return nil
		end

		local configData = pg.me:getConfigData()
		local gender = pg.me.gender or configData.gender

		if gender == 1 then
			return pg.getGameString("HIM")
		elseif gender == 2 then
			return pg.getGameString("HER")
		end

		return nil
	end

	function LuaUIUtils.parseReplaceText(key)
		local fun = LuaUIUtils[UIConst.PARSE_REPLACE_TEXT_MAP[key]]

		if fun then
			return fun()
		end

		return nil
	end

	function LuaUIUtils.getReplacedDialogueText(textHashId)
		local text = pg.getLocalizationText(textHashId)

		for key, pattern in pairs(UIConst.CUSTOM_TEXT_REPLACE_PATTERN) do
			local replaceText = LuaUIUtils.parseReplaceText(key)

			if replaceText then
				text = string.gsub(text, pattern, replaceText)
			end
		end

		return text
	end

	function LuaUIUtils._getCalcDesc(calcData, format, isDecimal, calcDataLinkPayload)
		if calcData.calcValue then
			local result = math.abs(calcData.calcValue) or 0

			if type(result) == "number" and format then
				if isDecimal then
					result = string.format(format, result)
				else
					result = string.format(format, result * 100)
				end
			elseif not format then
				result = trimDecimal(result)
			end

			return result
		elseif calcData.formulaByPetCacheProp and calcData.formulaExplictId then
			local petInfo = LuaUIUtils.customRichTextData.petInfo
			local explictData = FormulaExplictData[calcData.formulaExplictId]
			local value = 0
			local attributeMap = petInfo and PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo) or nil

			if not petInfo or not attributeMap then
				for i = 2, 6 do
					local resultValue = calcData.formulaByPetCacheProp[i]

					if type(resultValue) == "number" then
						local minRate = explictData.minNum

						value = math.abs(resultValue * minRate)

						break
					end
				end
			else
				local formulaId = calcData.formulaByPetCacheProp[1]
				local formulaData = FormulaData[formulaId]

				if not formulaData then
					return "0"
				end

				local argList = {}

				for i = 2, 6 do
					local arg = 0
					local propName = calcData.formulaByPetCacheProp[i]

					if propName then
						if type(propName) == "number" then
							arg = propName
						else
							local propId = AttributeConst[propName]

							if not propId then
								break
							end

							arg = attributeMap[propId] or 0
						end
					else
						break
					end

					table.insert(argList, arg)
				end

				value = math.abs(formulaData.formula(unpack(argList)) or 0)
			end

			if type(value) == "number" and format then
				value = formatValue(value, not isDecimal, format)
			elseif not format then
				value = trimDecimal(value)
			end

			local desc = ClientTextUtils.getLocalizationText(GameStringConfig.formulaExplictDesc.desc)
			local val1, val2, val3, val4, val5, val6 = buildFormulaExplictFormatArgs(calcData, explictData)
			local result = pg.getFormatText(desc, value, val1, val2, val3, val4, val5, val6)

			if string.isNilOrEmpty(calcDataLinkPayload) then
				return result
			end

			return string.format("<link=\"%s\"><u>%s</u></link>", calcDataLinkPayload, result)
		end

		return "0"
	end

	function LuaUIUtils.getCalcData(strArray)
		local tableName = strArray[1]
		local key = tonumber(strArray[2])
		local paramName = strArray[3]
		local level = LuaUIUtils.customRichTextData[strArray[4]] or tonumber(strArray[4])
		local format = strArray.Length >= 6 and strArray[5]
		local isDecimal = strArray.Length >= 7 and strArray[6] == "1"
		local data = getCalcDataByArgs(tableName, key, paramName, level)
		local calcDataLinkPayload = string.format("calcDataLink_%s,%s,%s,%s", tableName, key, paramName, strArray[4])

		if format then
			calcDataLinkPayload = string.format("%s,%s", calcDataLinkPayload, format)
		end

		if not data then
			return 0
		end

		return LuaUIUtils._getCalcDesc(data, format, isDecimal, calcDataLinkPayload)
	end

	function LuaUIUtils.getConfigData(strArray)
		local tableName = strArray[1]
		local result, table = xpcall(require, debug.traceback, "Data." .. tableName)

		if not result then
			return
		end

		local keyLength = strArray.Length - 2
		local result = table

		for i = 1, keyLength do
			local nextKey = strArray[i + 1]

			result = result[nextKey] or result[tonumber(nextKey)]

			if not result then
				return
			end
		end

		if type(result) == "number" or type(result) == "string" then
			return tostring(result)
		end
	end

	function LuaUIUtils.petItemSource(strArray)
		local sourceName = strArray[1]

		if LuaUIUtils.customRichTextData.petInfo then
			return string.format("source_%d_%s", sourceName, LuaUIUtils.customRichTextData.petInfo.id)
		end

		return string.format("source_%d", sourceName)
	end

	local customRichTextMap = {
		buffConfigData = function(strArray)
			return require("Utils.BuffUIUtils").getBuffConfigData(strArray)
		end,
		calcData = LuaUIUtils.getCalcData,
		getConfigData = LuaUIUtils.getConfigData,
		petItemSource = LuaUIUtils.petItemSource
	}

	LuaUIUtils.customRichTextData = {}

	function LuaUIUtils.getCustomRichTextData(strArray)
		if IsNil(strArray) or strArray.Length < 2 then
			return ""
		end

		local typeName = strArray[0]
		local fun = customRichTextMap[typeName]

		return fun and fun(strArray) or ""
	end
end
