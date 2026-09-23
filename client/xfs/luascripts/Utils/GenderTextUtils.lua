-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\GenderTextUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local GenderTextUtils = {}

GenderTextUtils.logger = LoggerManager.getLogger("GenderTextUtils")
GenderTextUtils.GENDER_MALE = "male"
GenderTextUtils.GENDER_FEMALE = "female"
GenderTextUtils.SELECTOR_PLAYER_GENDER = "playerGender"
GenderTextUtils.OTHER_BRANCH = "other"
GenderTextUtils.MAX_NEST_DEPTH = 8
GenderTextUtils.BYTE_BRACE_OPEN = 123
GenderTextUtils.BYTE_BRACE_CLOSE = 125
GenderTextUtils.GENDER_WORDS = {
	pronoun = {
		male = "HIM",
		female = "HER"
	}
}
GenderTextUtils.resolvingWord = false

function GenderTextUtils.getPlayerGender()
	if not pg or not pg.me then
		return nil
	end

	local gender = pg.me.gender

	if gender == nil then
		local configData = pg.me:getConfigData()

		gender = configData and configData.gender
	end

	if gender == 1 then
		return GenderTextUtils.GENDER_MALE
	elseif gender == 2 then
		return GenderTextUtils.GENDER_FEMALE
	end

	return nil
end

function GenderTextUtils.findMatchingBrace(text, openPos)
	local depth = 0

	for i = openPos, #text do
		local byte = string.byte(text, i)

		if byte == GenderTextUtils.BYTE_BRACE_OPEN then
			depth = depth + 1
		elseif byte == GenderTextUtils.BYTE_BRACE_CLOSE then
			depth = depth - 1

			if depth == 0 then
				return i
			end
		end
	end

	return nil
end

function GenderTextUtils.resolveGenderWord(name)
	local entry = GenderTextUtils.GENDER_WORDS[name]

	if not entry or GenderTextUtils.resolvingWord then
		return nil
	end

	local key = entry[GenderTextUtils.getPlayerGender() or GenderTextUtils.GENDER_MALE]

	if not key then
		return nil
	end

	local ClientTextUtils = require("Utils.ClientTextUtils")

	GenderTextUtils.resolvingWord = true

	local ok, text = pcall(ClientTextUtils.getGameString, key)

	GenderTextUtils.resolvingWord = false

	return ok and text or nil
end

function GenderTextUtils.resolveSelector(name)
	if name == GenderTextUtils.SELECTOR_PLAYER_GENDER then
		return GenderTextUtils.getPlayerGender()
	end

	return nil
end

function GenderTextUtils.resolveSelect(name, optionsText, depth)
	local value = GenderTextUtils.resolveSelector(name)
	local firstBranch, matchedBranch, otherBranch
	local pos = 1
	local len = #optionsText

	while pos <= len do
		local _, keyEnd, key = string.find(optionsText, "^%s*([%w_]+)%s*{", pos)

		if key == nil then
			break
		end

		local closePos = GenderTextUtils.findMatchingBrace(optionsText, keyEnd)

		if closePos == nil then
			return nil
		end

		local content = string.sub(optionsText, keyEnd + 1, closePos - 1)

		if firstBranch == nil then
			firstBranch = content
		end

		if key == GenderTextUtils.OTHER_BRANCH then
			otherBranch = content
		end

		if matchedBranch == nil and value ~= nil and key == value then
			matchedBranch = content
		end

		pos = closePos + 1
	end

	if firstBranch == nil or string.find(optionsText, "%S", pos) then
		return nil
	end

	return GenderTextUtils.formatMessage(matchedBranch or otherBranch or firstBranch, depth + 1)
end

function GenderTextUtils.resolvePlaceholder(body, depth)
	local name, optionsText = string.match(body, "^%s*([%w_]+)%s*,%s*select%s*,%s*(.*)$")

	if name then
		return GenderTextUtils.resolveSelect(name, optionsText, depth)
	end

	name = string.match(body, "^%s*([%w_]+)%s*$")

	if name == nil then
		return nil
	end

	return GenderTextUtils.resolveGenderWord(name)
end

function GenderTextUtils.formatMessage(text, depth)
	if depth > GenderTextUtils.MAX_NEST_DEPTH then
		return nil
	end

	local out, count = nil, 0
	local pos = 1

	while true do
		local openPos = string.find(text, "{", pos, true)

		if openPos == nil then
			if out == nil then
				return text
			end

			count = count + 1
			out[count] = string.sub(text, pos)

			break
		end

		local closePos = GenderTextUtils.findMatchingBrace(text, openPos)

		if closePos == nil then
			return nil
		end

		local resolved = GenderTextUtils.resolvePlaceholder(string.sub(text, openPos + 1, closePos - 1), depth)

		out = out or {}
		count = count + 1
		out[count] = string.sub(text, pos, openPos - 1)
		count = count + 1
		out[count] = resolved or string.sub(text, openPos, closePos)
		pos = closePos + 1
	end

	return table.concat(out)
end

function GenderTextUtils.format(text)
	if type(text) ~= "string" or string.find(text, "{", 1, true) == nil then
		return text
	end

	local ok, result = pcall(GenderTextUtils.formatMessage, text, 0)

	if not ok then
		GenderTextUtils.logger:error("format localization text failed: %s, text: %s", tostring(result), text)

		return text
	end

	return result or text
end

return GenderTextUtils
