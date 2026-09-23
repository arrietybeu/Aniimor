-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientTextUtils.lua

local GameStringConfig = require("Data.gamestring_config_data")
local GameStringHash = require("Data.gamestring_hash_data")
local ClientConst = require("Const.ClientConst")
local ListPool = require("Common.Container.ListPool")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientTextUtils")
local CustomEnData = require("Data.I18N.custom_en_data")
local pg = pg
local select = select
local type = type
local string = string
local pcall = pcall
local table = table
local math = math
local ipairs = ipairs
local tostring = tostring
local unpack = unpack
local GenderTextUtils = require("Utils.GenderTextUtils")
local ClientTextUtils = {}

ClientTextUtils.luaHotFixLanguage = {}

function ClientTextUtils.getRawLocalizationText(id, withoutSuffix)
	if withoutSuffix then
		return pgI18N.LocalizationText.GetFinalTextNoParamWithoutSuffix(id)
	end

	if type(id) == "number" then
		return pgI18N.LocalizationText.GetFinalTextNoParamById(id)
	end

	return pgI18N.LocalizationText.GetFinalTextNoParam(id)
end

function ClientTextUtils.fillText(text, paramList)
	text = GenderTextUtils.format(text)

	if paramList == nil then
		return text
	end

	return pgI18N.LocalizationText.GetFormatText(text, paramList)
end

function ClientTextUtils.replaceHotFixParams(paramList)
	for idx, parId in ipairs(paramList) do
		local hotText = ClientTextUtils.getLuaHotFixLanguage(parId)

		if hotText then
			paramList[idx] = hotText
		end
	end
end

function ClientTextUtils.getTextInternal(id, paramList, withoutSuffix)
	if id == nil then
		return ""
	end

	if paramList then
		ClientTextUtils.replaceHotFixParams(paramList)
	end

	local hotFixLanguage = ClientTextUtils.getLuaHotFixLanguage(id)

	if hotFixLanguage then
		if paramList == nil then
			return ClientTextUtils.fillText(hotFixLanguage, nil)
		end

		id = hotFixLanguage
	end

	return ClientTextUtils.fillText(ClientTextUtils.getRawLocalizationText(id, withoutSuffix), paramList)
end

function ClientTextUtils.getLocalizationText(id, ...)
	local num = select("#", ...)

	return ClientTextUtils.getTextInternal(id, num ~= 0 and {
		...
	} or nil, false)
end

function ClientTextUtils.getLuaHotFixLanguage(id)
	local selectLanguage = pg.languageType or 0
	local luaLanguage = ClientTextUtils.luaHotFixLanguage[selectLanguage]

	if luaLanguage then
		local key = tostring(id)

		if luaLanguage[key] then
			return luaLanguage[key]
		end
	end
end

function ClientTextUtils.getLocalizationTextWithoutSuffix(id, ...)
	local num = select("#", ...)

	return ClientTextUtils.getTextInternal(id, num ~= 0 and {
		...
	} or nil, true)
end

function ClientTextUtils.getGameString(key)
	local hashId
	local configHash = GameStringConfig[key]

	if configHash then
		hashId = configHash.desc
	else
		hashId = GameStringHash[key]
	end

	if hashId then
		return ClientTextUtils.getLocalizationText(hashId)
	end

	return key
end

function ClientTextUtils.getGameStringByLanguage(key, languageType)
	local configHash = GameStringConfig[key]
	local textId = configHash and configHash.desc or GameStringHash[key]

	if not textId then
		return key
	end

	return pgI18N.LocalizationText.GetLocalizationTextByLanguage(tostring(textId), languageType)
end

function ClientTextUtils.getGameStringTitle(key)
	local hashId
	local configHash = GameStringConfig[key]

	if configHash then
		hashId = configHash.title
	else
		hashId = GameStringHash[key]
	end

	if hashId then
		return ClientTextUtils.getLocalizationText(hashId)
	end

	return key
end

function ClientTextUtils.getFormatText(content, ...)
	local paramList = {
		...
	}
	local newParamList = {}

	for i, param in ipairs(paramList) do
		newParamList[#newParamList + 1] = param
	end

	return pgI18N.LocalizationText.GetFormatText(content, newParamList)
end

function ClientTextUtils.getFormatNumber(content)
	return ClientTextUtils.formatSeparatedNumberText(tostring(content))
end

local NUMBER_GROUP_SEPARATOR = "<space=0.2em>"
local NUMBER_DECIMAL_SEPARATOR = "."

local function formatIntegerPartWithSeparator(integerText)
	local sign = ""
	local firstCharacter = string.sub(integerText, 1, 1)

	if firstCharacter == "-" or firstCharacter == "+" then
		sign = firstCharacter
		integerText = string.sub(integerText, 2)
	end

	local groups = {}
	local integerLength = string.len(integerText)
	local firstGroupLength = integerLength % 3
	local nextIndex = 1

	if firstGroupLength > 0 then
		groups[#groups + 1] = string.sub(integerText, 1, firstGroupLength)
		nextIndex = firstGroupLength + 1
	end

	while nextIndex <= integerLength do
		groups[#groups + 1] = string.sub(integerText, nextIndex, nextIndex + 2)
		nextIndex = nextIndex + 3
	end

	if sign ~= "" then
		groups[1] = sign .. groups[1]
	end

	return table.concat(groups, NUMBER_GROUP_SEPARATOR)
end

local function normalizeSeparatedNumberText(value)
	if type(value) == "number" then
		if value ~= value then
			return nil
		end

		if math.floor(value) == value then
			return string.format("%.0f", value)
		end

		return tostring(value)
	end

	if type(value) ~= "string" then
		return nil
	end

	return value
end

function ClientTextUtils.formatSeparatedNumber(value)
	local numberText = normalizeSeparatedNumberText(value)

	if string.isNilOrEmpty(numberText) then
		return tostring(value or 0)
	end

	local sign, integerPart, decimalPart = string.match(numberText, "^([+-]?)(%d+)%.(%d+)$")

	if not integerPart then
		sign, integerPart = string.match(numberText, "^([+-]?)(%d+)$")
	end

	if not integerPart then
		return numberText
	end

	local formattedInteger = formatIntegerPartWithSeparator(sign .. integerPart)

	if decimalPart then
		return formattedInteger .. NUMBER_DECIMAL_SEPARATOR .. decimalPart
	end

	return formattedInteger
end

function ClientTextUtils.formatSeparatedNumberText(text)
	if string.isNilOrEmpty(text) then
		return text
	end

	local protectedParts = {}
	local protectedCount = 0

	local function protect(part)
		protectedCount = protectedCount + 1

		local token = string.char(1) .. string.char(protectedCount) .. string.char(2)

		protectedParts[token] = part

		return token
	end

	local protectedText = string.gsub(text, "<[^>]->", protect)

	protectedText = string.gsub(protectedText, "{%d+}", protect)
	protectedText = string.gsub(protectedText, "([+-]?%d+%.?%d*)", function(numberText)
		return ClientTextUtils.formatSeparatedNumber(numberText)
	end)
	protectedText = string.gsub(protectedText, string.char(1) .. "(.)" .. string.char(2), function(index)
		local token = string.char(1) .. index .. string.char(2)

		return protectedParts[token] or token
	end)

	return protectedText
end

local function useInternationalNumberFormat(textComponent)
	if not textComponent then
		return false
	end

	local ok, value = pcall(function()
		return textComponent.useInternationalNumberFormat
	end)

	if ok and value ~= nil then
		return value
	end

	ok, value = pcall(function()
		local textPlus = textComponent.textPlus

		return textPlus and textPlus.useInternationalNumberFormat
	end)

	if ok and value ~= nil then
		return value
	end

	ok, value = pcall(function()
		local gameObject = textComponent.gameObject
		local textPlus = gameObject and gameObject:GetComponent(typeof(CS.XGUI.SRenderer.TextPlus))

		return textPlus and textPlus.useInternationalNumberFormat
	end)

	return ok and value or false
end

local function formatTextByInternationalNumberConfig(textComponent, text)
	if useInternationalNumberFormat(textComponent) then
		return ClientTextUtils.formatSeparatedNumberText(text)
	end

	return text
end

function ClientTextUtils.getGameStringWithSeparatedNumber(key)
	local configHash = GameStringConfig[key]

	if not configHash or not configHash.desc then
		return ClientTextUtils.getGameString(key)
	end

	local text = ClientTextUtils.getLocalizationText(configHash.desc)

	return ClientTextUtils.formatSeparatedNumberText(text)
end

function ClientTextUtils.getFormatGameStringWithSeparatedNumber(key, ...)
	local configHash = GameStringConfig[key]

	if not configHash or not configHash.desc then
		return ClientTextUtils.getFormatText(ClientTextUtils.getGameString(key), ...)
	end

	local text = ClientTextUtils.getFormatText(ClientTextUtils.getLocalizationText(configHash.desc), ...)

	return ClientTextUtils.formatSeparatedNumberText(text)
end

function ClientTextUtils.getLocalizationCountDown(seconds)
	local parts = {}
	local days = math.floor(seconds / 86400)

	if days > 0 then
		parts[#parts + 1] = days
		parts[#parts + 1] = ClientTextUtils.getGameString("DAY")
		seconds = seconds - days * 24 * 3600
	end

	local hours = math.floor(seconds / 3600)

	if hours > 0 or #parts > 0 then
		parts[#parts + 1] = hours
		parts[#parts + 1] = ClientTextUtils.getGameString("HOUR")
		seconds = seconds - hours * 3600
	end

	local minutes = math.floor(seconds / 60)

	if minutes > 0 or #parts > 0 then
		parts[#parts + 1] = minutes
		parts[#parts + 1] = ClientTextUtils.getGameString("MINUTE")
		seconds = seconds - minutes * 60
	end

	if seconds > 0 or #parts > 0 then
		parts[#parts + 1] = seconds
		parts[#parts + 1] = ClientTextUtils.getGameString("SECOND")
	end

	return ClientTextUtils.concatCountDownUnitsByLanguage(table.unpack(parts))
end

function ClientTextUtils.parseDescText(descText, dataInfo)
	descText = pg.getLocalizationText(descText)
	dataInfo = dataInfo or {}

	local resultText = string.gsub(descText, "%$([%w][%w]*)%$", function(s)
		return dataInfo[s] or ""
	end)

	return resultText
end

ClientTextUtils.UnicodeNameRangeList = {
	{
		48,
		57
	},
	{
		65,
		90
	},
	{
		97,
		122
	},
	{
		95,
		95
	},
	{
		96,
		96
	},
	{
		126,
		126
	},
	{
		161,
		161
	},
	{
		183,
		183
	},
	{
		191,
		191
	},
	{
		32,
		47
	},
	{
		58,
		64
	},
	{
		19968,
		40959
	},
	{
		13312,
		19903
	},
	{
		63744,
		64255
	},
	{
		12352,
		12447
	},
	{
		12448,
		12543
	},
	{
		12784,
		12799
	},
	{
		12288,
		12351
	},
	{
		65072,
		65103
	},
	{
		65281,
		65374
	},
	{
		44032,
		55215
	},
	{
		4352,
		4607
	},
	{
		12592,
		12687
	},
	{
		3584,
		3711
	},
	{
		1024,
		1279
	},
	{
		1280,
		1327
	},
	{
		192,
		255
	},
	{
		256,
		383
	},
	{
		384,
		591
	},
	{
		7680,
		7935
	}
}

local UnicodeNameRangeList = ClientTextUtils.UnicodeNameRangeList

function ClientTextUtils.filterName(s)
	local hexStr, hexStrArr, hexValArr = ClientTextUtils.utf8_to_unicode(s)
	local resultArr = {}

	for i, value in ipairs(hexValArr) do
		if value == 0 then
			-- block empty
		else
			local nationIdx = -1

			for j, rangeCfg in ipairs(UnicodeNameRangeList) do
				if value >= rangeCfg[1] and value <= rangeCfg[2] then
					nationIdx = j

					break
				end
			end

			if nationIdx ~= -1 then
				resultArr[#resultArr + 1] = hexStrArr[i]
			end
		end
	end

	local unicodeStr = table.concat(resultArr)
	local result = ClientTextUtils.unicode_to_utf8(unicodeStr)

	return result
end

function ClientTextUtils.containsBlank(text)
	if string.isNilOrEmpty(text) then
		return false
	end

	return string.find(text, "%s") ~= nil or string.find(text, "　", 1, true) ~= nil
end

function ClientTextUtils.utf8_to_unicode(convertStr)
	if type(convertStr) ~= "string" then
		return convertStr
	end

	local resultStr = ""
	local hexStrArr = {}
	local hexValArr = {}
	local i = 1
	local num1 = string.byte(convertStr, i)

	while num1 ~= nil do
		local tempVar1 = 0
		local tempVar2 = 0

		if num1 >= 0 and num1 <= 127 then
			tempVar1 = num1
			tempVar2 = 0
		elseif bit.band(num1, 224) == 192 then
			local t1 = 0
			local t2 = 0

			t1 = bit.band(num1, bit.rshift(255, 3))
			i = i + 1
			num1 = string.byte(convertStr, i)
			t2 = bit.band(num1, bit.rshift(255, 2))
			tempVar1 = bit.bor(t2, bit.lshift(bit.band(t1, bit.rshift(255, 6)), 6))
			tempVar2 = bit.rshift(t1, 2)
		elseif bit.band(num1, 240) == 224 then
			local t1 = 0
			local t2 = 0
			local t3 = 0

			t1 = bit.band(num1, bit.rshift(255, 3))
			i = i + 1
			num1 = string.byte(convertStr, i)
			t2 = bit.band(num1, bit.rshift(255, 2))
			i = i + 1
			num1 = string.byte(convertStr, i)
			t3 = bit.band(num1, bit.rshift(255, 2))
			tempVar1 = bit.bor(bit.lshift(bit.band(t2, bit.rshift(255, 6)), 6), t3)
			tempVar2 = bit.bor(bit.lshift(t1, 4), bit.rshift(t2, 2))
		end

		local resultU = string.format("\\u%02x%02x", tempVar2, tempVar1)

		resultStr = resultStr .. resultU
		hexStrArr[#hexStrArr + 1] = resultU
		hexValArr[#hexValArr + 1] = bit.lshift(tempVar2, 8) + tempVar1
		i = i + 1
		num1 = string.byte(convertStr, i)
	end

	return resultStr, hexStrArr, hexValArr
end

function ClientTextUtils.unicode_to_utf8(convertStr)
	if type(convertStr) ~= "string" then
		return convertStr
	end

	local resultStr = ""
	local i = 1

	while true do
		local num1 = string.byte(convertStr, i)
		local unicode

		if num1 ~= nil and string.sub(convertStr, i, i + 1) == "\\u" then
			unicode = tonumber("0x" .. string.sub(convertStr, i + 2, i + 5))
			i = i + 6
		elseif num1 ~= nil then
			unicode = num1
			i = i + 1
		else
			break
		end

		if unicode <= 127 then
			resultStr = resultStr .. string.char(bit.band(unicode, 127))
		elseif unicode >= 128 and unicode <= 2047 then
			resultStr = resultStr .. string.char(bit.bor(192, bit.band(bit.rshift(unicode, 6), 31)))
			resultStr = resultStr .. string.char(bit.bor(128, bit.band(unicode, 63)))
		elseif unicode >= 2048 and unicode <= 65535 then
			resultStr = resultStr .. string.char(bit.bor(224, bit.band(bit.rshift(unicode, 12), 15)))
			resultStr = resultStr .. string.char(bit.bor(128, bit.band(bit.rshift(unicode, 6), 63)))
			resultStr = resultStr .. string.char(bit.bor(128, bit.band(unicode, 63)))
		end
	end

	return resultStr
end

function ClientTextUtils.getValidName(name, maxLength)
	if string.isNilOrEmpty(name) then
		return name, 0
	end

	name = ClientTextUtils.filterName(name)

	local index = 1
	local useSpace = 0
	local len = string.len(name)
	local codePoint, bytes, secondByte, thirdByte, charSpace

	maxLength = maxLength * 2

	while index <= len do
		codePoint = string.byte(name, index)

		if codePoint <= 127 then
			bytes = 1
		elseif codePoint <= 223 then
			bytes = 2
			codePoint = (codePoint - 192) * 64 + string.byte(name, index + 1) - 128
		else
			bytes = 3
			secondByte, thirdByte = string.byte(name, index + 1, index + 2)
			codePoint = (codePoint - 224) * 4096 + (secondByte - 128) * 64 + thirdByte - 128
		end

		charSpace = ClientTextUtils.getNameCharSpace(codePoint)

		if maxLength < useSpace + charSpace then
			break
		end

		useSpace = useSpace + charSpace
		index = index + bytes
	end

	return string.sub(name, 1, index - 1), useSpace
end

function ClientTextUtils.getNameCharSpace(codePoint)
	if codePoint <= 127 then
		return 1
	end

	if codePoint >= 192 and codePoint <= 591 and codePoint ~= 215 and codePoint ~= 247 then
		return 1
	end

	if codePoint >= 7680 and codePoint <= 7935 then
		return 1
	end

	if codePoint >= 1024 and codePoint <= 1327 then
		return 1
	end

	return 2
end

function ClientTextUtils.applyTextColor(text, textColor)
	if string.isNilOrEmpty(textColor) then
		return text
	end

	return string.format("<color=%s>%s</color>", textColor, text)
end

function ClientTextUtils.setText(textComponent, ...)
	if not textComponent then
		return
	end

	local tmpList = ListPool.getList()
	local len = select("#", ...)

	for i = 1, len do
		local param = select(i, ...)
		local text = type(param) ~= "string" and tostring(param) or param

		tmpList[#tmpList + 1] = formatTextByInternationalNumberConfig(textComponent, text)
	end

	pgI18N.LocalizationText.SetText(textComponent, unpack(tmpList))
	ListPool.returnList(tmpList)
end

function ClientTextUtils.setTextWithId(textComponent, id, ...)
	if not textComponent then
		return
	end

	local tmpList = ListPool.getList()

	for i = 1, select("#", ...) do
		local param = select(i, ...)
		local text = type(param) ~= "string" and tostring(param) or param

		tmpList[#tmpList + 1] = formatTextByInternationalNumberConfig(textComponent, text)
	end

	if type(id) ~= "number" then
		id = tonumber(id)
	end

	if id == nil then
		pgI18N.LocalizationText.SetText(textComponent, "", unpack(tmpList))
	else
		pgI18N.LocalizationText.SetTextWithId(textComponent, id, unpack(tmpList))
	end

	ListPool.returnList(tmpList)
end

function ClientTextUtils.setTextWithIdOrDefault(textComponent, id, defaultValue)
	if type(id) ~= "number" then
		id = tonumber(id)
	end

	if id == nil then
		pgI18N.LocalizationText.SetText(textComponent, defaultValue)
	else
		pgI18N.LocalizationText.SetTextWithIdOrDefault(textComponent, id, defaultValue)
	end
end

function ClientTextUtils.setArkFontEnable(uBaseText, enable, id, fallbackText)
	if not uBaseText then
		return
	end

	if enable then
		local text = id ~= nil and CustomEnData[tostring(id)] or fallbackText or ""

		uBaseText.disabledLocalization = true

		ClientTextUtils.setText(uBaseText, text)
		uBaseText:SetArkFont()
	else
		uBaseText.disabledLocalization = false

		ClientTextUtils.setText(uBaseText, fallbackText or "")
		uBaseText:RefreshLocalization()
	end
end

local _concatResult = {}

function ClientTextUtils.concatByLanguage(...)
	table.clear(_concatResult)

	local count = 0

	for i = 1, select("#", ...) do
		local arg = select(i, ...)

		if arg ~= nil then
			count = count + 1
			_concatResult[count] = type(arg) ~= "string" and tostring(arg) or arg
		end
	end

	local separator = ClientConst.CONCAT_SEPARATOR_BY_LANGUAGE[pg.languageType or ClientConst.LANGUAGE_TYPE_MAP.zh_CN] or ""

	return table.concat(_concatResult, separator)
end

function ClientTextUtils.formatShortLevel(level)
	if level == nil then
		return ""
	end

	local language = pg.languageType or ClientConst.LANGUAGE_TYPE_MAP.zh_CN
	local formatText = ClientConst.SHORT_LEVEL_FORMAT_BY_LANGUAGE[language] or ClientConst.DEFAULT_SHORT_LEVEL_FORMAT

	return ClientTextUtils.getFormatText(formatText, ClientTextUtils.getGameString("LEVEL_LITE"), level)
end

function ClientTextUtils.formatShortLevelRange(minLevel, maxLevel)
	if minLevel == nil or maxLevel == nil then
		return ""
	end

	return ClientTextUtils.formatShortLevel(string.format("%s~%s", minLevel, maxLevel))
end

local _countDownConcatResult = {}

function ClientTextUtils.concatCountDownUnitsByLanguage(...)
	table.clear(_countDownConcatResult)

	local language = pg.languageType or ClientConst.LANGUAGE_TYPE_MAP.zh_CN

	for i = 1, select("#", ...), 2 do
		local value = select(i, ...)
		local unit = string.trim(select(i + 1, ...) or "")

		if value ~= nil then
			_countDownConcatResult[#_countDownConcatResult + 1] = tostring(value) .. unit
		end
	end

	local unitGroupSeparator = ClientConst.COUNT_DOWN_WITHOUT_UNIT_GROUP_SPACE_LANGUAGES[language] and "" or ClientConst.HALF_WIDTH_SPACE

	return table.concat(_countDownConcatResult, unitGroupSeparator)
end

function ClientTextUtils.removeRichText(text)
	if string.isNilOrEmpty(text) then
		return text or ""
	end

	local plainText = string.gsub(text, "<[^>]->", "")

	return plainText
end

function ClientTextUtils.containsRichText(text)
	if string.isNilOrEmpty(text) then
		return false
	end

	if string.find(text, "</?%a[%a%d]*[^>]*>") then
		return true
	end

	for hexColor in string.gmatch(text, "<#([^>]*)>") do
		local length = #hexColor

		if not string.find(hexColor, "[^%x]") and (length == 3 or length == 4 or length == 6 or length == 8) then
			return true
		end
	end

	return false
end

return ClientTextUtils
