-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Common.lua

local _M = {}
local enums = require("Common.AI.Behaviac.Enums")
local lib_crc32 = require("Common.AI.Behaviac.External.CRC32")
local Time = require("Core.Common.Time")
local constCharByte = enums.constCharByte

_M.d_log = {}

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Behaviac")

function _M.d_log.must(formatStr, ...)
	logger.info(string.format(formatStr, ...))
end

function _M.d_log.error(formatStr, ...)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(formatStr, ...)
	end
end

local Logging = _M.d_log

_M.StringUtils = {}

function _M.StringUtils.isNullOrEmpty(str)
	return not str or str == ""
end

function _M.StringUtils.isValidString(str)
	return str and str ~= ""
end

function _M.StringUtils.compare(str1, str2, bIgnoreCase)
	bIgnoreCase = bIgnoreCase or false

	if bIgnoreCase then
		return string.lower(str1) == string.lower(str2)
	else
		return str1 == str2
	end
end

function _M.StringUtils.trimEnclosedDoubleQuotes(str)
	if string.byte(str, 1, 1) == constCharByte.DoubleQuote and string.byte(str, -1, -1) == constCharByte.DoubleQuote then
		return string.sub(str, 2, -2), true
	else
		return str, false
	end
end

function _M.StringUtils.trimEnclosedBrackets(str)
	if string.byte(str, 1, 1) == constCharByte.LeftBraces and string.byte(str, -1, -1) == constCharByte.RightBraces then
		return string.sub(str, 2, -2), true
	else
		return str, false
	end
end

function _M.StringUtils.skipPairedBrackets(str, startPos)
	if string.byte(str, startPos) == constCharByte.LeftBraces then
		local depth = 0
		local posIt = startPos
		local strLen = string.len(str)

		while posIt <= strLen do
			if string.byte(str, posIt) == constCharByte.LeftBraces then
				depth = depth + 1
			elseif string.byte(str, posIt) == constCharByte.RightBraces then
				depth = depth - 1

				if depth == 0 then
					return posIt
				end
			end

			posIt = posIt + 1
		end
	end

	return 0
end

function _M.StringUtils.split(str, char)
	local ret = {}
	local e = 1
	local b = string.find(str, char, e)

	while b do
		table.insert(ret, string.sub(str, e, b - 1))

		e = b + 1
		b = string.find(str, char, e)
	end

	table.insert(ret, string.sub(str, e, -1))

	return ret
end

function _M.StringUtils.splitTokens(str)
	local macros = require("Common.AI.Behaviac.Macros")
	local ret = {}

	if string.byte(str, 1, 1) == constCharByte.DoubleQuote then
		macros.BEHAVIAC_ASSERT(string.byte(str, -1, -1) == constCharByte.DoubleQuote, "splitTokens string.byte(str, -1, -1) == constCharByte.DoubleQuote")
		table.insert(ret, str)

		return ret
	end

	local pB = 1
	local i = 1
	local bBeginIndex = false
	local strLen = string.len(str)

	while i < strLen do
		local bFound = false
		local c = string.byte(str, i)

		if c == constCharByte.WhiteSpace and not bBeginIndex then
			bFound = true
		elseif c == constCharByte.LeftBracket then
			bBeginIndex = true
			bFound = true
		elseif c == constCharByte.RightBracket then
			bBeginIndex = false
			bFound = true
		end

		if bFound then
			local strT = string.sub(str, pB, i - 1)

			macros.BEHAVIAC_ASSERT(string.len(strT) > 0)
			table.insert(ret, strT)

			pB = i + 1
		end

		i = i + 1
	end

	local strT = string.sub(str, pB, i)

	if string.len(strT) > 0 then
		table.insert(ret, strT)
	end

	return ret
end

function _M.StringUtils.checkArrayString(str, posStart, posEnd)
	local macros = require("Common.AI.Behaviac.Macros")
	local size = 0
	local elements = {}
	local eStart
	local strLen = string.len(str)
	local mStart_, mEnd_, m_ = string.find(str, "(%d+):", posStart)

	if mStart_ == posStart then
		size = tonumber(m_)

		local depth = 0

		for posIt = mEnd_ + 1, strLen do
			local c1 = string.byte(str, posIt)

			if c1 == constCharByte.Semicolon and depth == 0 then
				posEnd = posIt

				break
			elseif c1 == constCharByte.LeftBraces then
				macros.BEHAVIAC_ASSERT(depth < 10)

				depth = depth + 1
				eStart = posIt
			elseif c1 == constCharByte.RightBraces then
				macros.BEHAVIAC_ASSERT(depth > 0)

				depth = depth - 1

				local e = string.sub(str, eStart, posIt)

				table.insert(elements, e)
			end
		end

		return true, posEnd, size > 0 and elements
	end

	return false, posEnd, size > 0 and elements
end

function _M.StringUtils.splitTokensForStruct(str)
	local macros = require("Common.AI.Behaviac.Macros")
	local ret = {}
	local posCloseBrackets = _M.StringUtils.skipPairedBrackets(str, 1)

	macros.BEHAVIAC_ASSERT(posCloseBrackets > 0)

	local posBegin = 2
	local posEnd = string.find(str, ";", posBegin)
	local isArray

	while posEnd do
		macros.BEHAVIAC_ASSERT(string.byte(str, posEnd) == constCharByte.Semicolon)

		if posBegin < posEnd then
			local posEqual = string.find(str, "=", posBegin)

			macros.BEHAVIAC_ASSERT(posBegin < posEqual)

			local memmberName = string.sub(str, posBegin, posEqual - 1)
			local memmberValue
			local c = string.byte(str, posEqual + 1)

			if c ~= constCharByte.LeftBraces then
				isArray, posEnd = _M.StringUtils.checkArrayString(str, posEqual + 1, posEnd)
				memmberValue = string.sub(str, posEqual + 1, posEnd - 1)
			else
				local posCloseBrackets_ = _M.StringUtils.skipPairedBrackets(str, posEqual + 1)

				memmberValue = string.sub(str, posEqual + 1, posCloseBrackets_)
				posEnd = posCloseBrackets_ + 1
			end

			table.insert(ret, {
				memmberName,
				memmberValue
			})
		end

		posBegin = posEnd + 1
		posEnd = string.find(str, ";", posBegin)

		if not posEnd or posCloseBrackets <= posEnd then
			break
		end
	end

	return ret
end

_M.CRC = {}

function _M.CRC.CalcCRC(idStr)
	return lib_crc32.Hash(idStr)
end

function _M.makeVariableId(idStr)
	return _M.CRC.CalcCRC(idStr)
end

function _M.getClock()
	return Time.realSecondCache * 1000
end

function _M.getFrames()
	return Time.getCurrentFrameCount()
end

function _M.getRandomValue(method, agent, tick)
	if method then
		return method:getValue(agent, tick)
	end

	return math.random(10000) / 10000
end

return _M
