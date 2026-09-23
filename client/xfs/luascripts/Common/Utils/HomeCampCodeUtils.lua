-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeCampCodeUtils.lua

local bit = bit
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local rshift = bit.rshift
local math_floor = math.floor
local HomeCampCodeUtils = {}

local function bxor(x, y)
	return band(bor(x, y), bor(bnot(x), bnot(y)))
end

local CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ"
local CHARSET_SIZE = 32
local IDSTR_LENGTH = 8
local IDSTR_BIT_LENGTH = IDSTR_LENGTH * 5
local HALF_BIT_LENGTH = IDSTR_BIT_LENGTH / 2
local HALF_DOMAIN = 2^HALF_BIT_LENGTH
local HALF_MASK = HALF_DOMAIN - 1
local FULL_DOMAIN = 2^IDSTR_BIT_LENGTH
local SOFT_LIMIT = math_floor(FULL_DOMAIN * 0.9)

HomeCampCodeUtils.MAX_DISPLAY_SEQ = FULL_DOMAIN
HomeCampCodeUtils.SOFT_LIMIT_DISPLAY_SEQ = SOFT_LIMIT

local CHAR_TO_VALUE = {}

for i = 1, #CHARSET do
	CHAR_TO_VALUE[CHARSET:sub(i, i)] = i - 1
end

local DISPLAY_CODE_SEP = "-"
local USE_FEISTEL_ENCODING = true
local ROUND_KEYS = {
	3825453,
	8133966,
	6200175,
	2969482
}
local KNUTH_CONST = 2654435761
local BLOCKED_SUBSTRINGS = {
	"SEX",
	"FUC",
	"FUK",
	"SHT",
	"ASS",
	"DIE",
	"KKK",
	"WTF",
	"NGA"
}

local function feistelRound(half, roundKey)
	local v = half * KNUTH_CONST + roundKey

	return band(rshift(v, 5), HALF_MASK)
end

function HomeCampCodeUtils.encryptDisplaySeq(displaySeq)
	local L = math_floor(displaySeq / HALF_DOMAIN) % HALF_DOMAIN
	local R = displaySeq % HALF_DOMAIN

	for i = 1, 4 do
		local newR = band(bxor(L, feistelRound(R, ROUND_KEYS[i])), HALF_MASK)

		L = R
		R = newR
	end

	return L * HALF_DOMAIN + R
end

function HomeCampCodeUtils.decryptToDisplaySeq(cipherValue)
	local L = math_floor(cipherValue / HALF_DOMAIN) % HALF_DOMAIN
	local R = cipherValue % HALF_DOMAIN

	for i = 4, 1, -1 do
		local newL = band(bxor(R, feistelRound(L, ROUND_KEYS[i])), HALF_MASK)

		R = L
		L = newL
	end

	return L * HALF_DOMAIN + R
end

function HomeCampCodeUtils.encodeBase32(value, length)
	local chars = {}

	for i = length, 1, -1 do
		local idx = value % CHARSET_SIZE + 1

		chars[i] = CHARSET:sub(idx, idx)
		value = math_floor(value / CHARSET_SIZE)
	end

	return table.concat(chars)
end

function HomeCampCodeUtils.decodeBase32(str)
	local value = 0

	for i = 1, #str do
		local c = str:sub(i, i)
		local v = CHAR_TO_VALUE[c]

		if not v then
			return -1
		end

		value = value * CHARSET_SIZE + v
	end

	return value
end

function HomeCampCodeUtils.encodeIdStrByFeistel(displaySeq)
	local cipher = HomeCampCodeUtils.encryptDisplaySeq(displaySeq)
	local encoded = HomeCampCodeUtils.encodeBase32(cipher, IDSTR_LENGTH)
	local special = HomeCampCodeUtils.isSpecialIdStr(encoded)

	return encoded, special
end

function HomeCampCodeUtils.decodeIdStrByFeistel(idStr)
	local cipher = HomeCampCodeUtils.decodeBase32(idStr)

	if cipher < 0 then
		return -1
	end

	return HomeCampCodeUtils.decryptToDisplaySeq(cipher)
end

function HomeCampCodeUtils.encodeIdStrByBase32(displaySeq)
	local encoded = HomeCampCodeUtils.encodeBase32(displaySeq, IDSTR_LENGTH)
	local special = HomeCampCodeUtils.isSpecialIdStr(encoded)

	return encoded, special
end

function HomeCampCodeUtils.decodeIdStrByBase32(idStr)
	return HomeCampCodeUtils.decodeBase32(idStr)
end

function HomeCampCodeUtils.encodeIdStr(displaySeq)
	if USE_FEISTEL_ENCODING then
		return HomeCampCodeUtils.encodeIdStrByFeistel(displaySeq)
	end

	return HomeCampCodeUtils.encodeIdStrByBase32(displaySeq)
end

function HomeCampCodeUtils.isDisplaySeqWithinSoftLimit(displaySeq)
	return displaySeq < SOFT_LIMIT
end

function HomeCampCodeUtils.isDisplaySeqEncodable(displaySeq)
	return displaySeq >= 0 and displaySeq < FULL_DOMAIN
end

function HomeCampCodeUtils.decodeIdStr(idStr)
	if USE_FEISTEL_ENCODING then
		return HomeCampCodeUtils.decodeIdStrByFeistel(idStr)
	end

	return HomeCampCodeUtils.decodeIdStrByBase32(idStr)
end

function HomeCampCodeUtils.makeDisplayCode(areaPrefix, idStr)
	return areaPrefix .. DISPLAY_CODE_SEP .. idStr
end

function HomeCampCodeUtils.parseDisplayCode(displayCode)
	if not displayCode then
		return nil, nil
	end

	if #displayCode < 2 + IDSTR_LENGTH then
		return nil, nil
	end

	local sepPos = #displayCode - IDSTR_LENGTH

	if displayCode:sub(sepPos, sepPos) ~= DISPLAY_CODE_SEP then
		return nil, nil
	end

	local prefix = displayCode:sub(1, sepPos - 1)
	local idStr = displayCode:sub(sepPos + 1)

	return prefix, idStr
end

function HomeCampCodeUtils.extractIdStr(displayCode)
	local _, idStr = HomeCampCodeUtils.parseDisplayCode(displayCode)

	return idStr
end

function HomeCampCodeUtils.isSpecialIdStr(code)
	if #code ~= IDSTR_LENGTH then
		return false
	end

	local first = code:sub(1, 1)

	if code == string.rep(first, IDSTR_LENGTH) then
		return true
	end

	local indices = {}

	for i = 1, IDSTR_LENGTH do
		indices[i] = CHAR_TO_VALUE[code:sub(i, i)]

		if not indices[i] then
			return false
		end
	end

	local allAsc, allDesc = true, true

	for i = 2, IDSTR_LENGTH do
		if indices[i] - indices[i - 1] ~= 1 then
			allAsc = false
		end

		if indices[i] - indices[i - 1] ~= -1 then
			allDesc = false
		end
	end

	if allAsc or allDesc then
		return true
	end

	local isPalindrome = true

	for i = 1, math_floor(IDSTR_LENGTH / 2) do
		if code:sub(i, i) ~= code:sub(IDSTR_LENGTH - i + 1, IDSTR_LENGTH - i + 1) then
			isPalindrome = false

			break
		end
	end

	if isPalindrome then
		return true
	end

	if code:sub(1, 2) == code:sub(3, 4) and code:sub(3, 4) == code:sub(5, 6) and code:sub(5, 6) == code:sub(7, 8) then
		return true
	end

	if code:sub(1, 4) == code:sub(5, 8) then
		return true
	end

	for _, word in ipairs(BLOCKED_SUBSTRINGS) do
		if code:find(word, 1, true) then
			return true
		end
	end

	return false
end

return HomeCampCodeUtils
