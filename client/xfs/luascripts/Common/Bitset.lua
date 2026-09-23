-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Bitset.lua

local bit = bit
local MAGIC_DIGIT = 5
local MAGIC_NUM = 2^MAGIC_DIGIT
local Bitset = {}

Bitset.band = bit.band
Bitset.bnot = bit.bnot
Bitset.bor = bit.bor
Bitset.lshift = bit.lshift
Bitset.rshift = bit.rshift

local band = bit.band
local bnot = bit.bnot
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift

local function bxor(x, y)
	return band(bor(x, y), bor(bnot(x), bnot(y)))
end

Bitset.bxor = bxor
Bitset.MAGIC_DIGIT = MAGIC_DIGIT
Bitset.MAGIC_NUM = MAGIC_NUM

function Bitset.updateBit(num, value, offset)
	if value then
		return bor(num, lshift(1, offset - 1))
	else
		return band(num, bnot(lshift(1, offset - 1)))
	end
end

function Bitset.getBitBool(num, offset)
	local idx = lshift(1, offset - 1)

	return band(num, idx) == idx
end

function Bitset.setBit(flags, bitIndex)
	if flags == nil then
		return false
	end

	local idx = rshift(bitIndex, MAGIC_DIGIT) + 1
	local pos = band(bitIndex, MAGIC_NUM - 1)
	local byte = lshift(1, pos)
	local newValue = bor(flags[idx] or 0, byte)

	if newValue == flags[idx] then
		return false
	end

	flags[idx] = newValue

	return true
end

function Bitset.clrBit(flags, bitIndex)
	if flags == nil then
		return false
	end

	local idx = rshift(bitIndex, MAGIC_DIGIT) + 1

	if flags[idx] then
		local pos = band(bitIndex, MAGIC_NUM - 1)
		local byte = bnot(lshift(1, pos))
		local oldValue = flags[idx] or 0
		local newValue = band(oldValue, byte)

		if oldValue == newValue then
			return false
		end

		flags[idx] = band(flags[idx] or 0, byte)

		if flags[idx] == 0 then
			flags[idx] = nil
		end

		return true
	end

	return false
end

local function getBit(flags, bitIndex)
	if flags == nil then
		return false
	end

	local idx = rshift(bitIndex, MAGIC_DIGIT) + 1
	local pos = band(bitIndex, MAGIC_NUM - 1)
	local byte = lshift(1, pos)

	return band(flags[idx] or 0, byte) ~= 0
end

Bitset.getBit = getBit

function Bitset.getList(flags)
	if flags == nil then
		return {}
	end

	local res = {}

	for idx, val in pairs(flags) do
		for pos = 0, MAGIC_NUM - 1 do
			if band(val, lshift(1, pos)) ~= 0 then
				res[#res + 1] = MAGIC_NUM * (idx - 1) + pos
			end
		end
	end

	return res
end

function Bitset.any(flags, ignoreBitIndex)
	if flags == nil then
		return false
	end

	local idx = -1
	local pos = -1

	if ignoreBitIndex ~= nil then
		idx = rshift(ignoreBitIndex, MAGIC_DIGIT) + 1
		pos = band(ignoreBitIndex, MAGIC_NUM - 1)
	end

	for i, val in pairs(flags) do
		if i == idx then
			local byte = bnot(lshift(1, pos))

			val = bor(val, byte)
		end

		if val ~= 0 then
			return true
		end
	end

	return false
end

function Bitset.dump(flags, enum)
	if flags == nil then
		return ""
	end

	local revEnum = {}

	if enum then
		for k, v in pairs(enum) do
			revEnum[v] = k
		end
	end

	local str = ""

	for i = 0, 64 do
		if getBit(flags, i) then
			if revEnum[i] then
				str = str .. revEnum[i] .. ","
			else
				str = str .. i .. ","
			end
		end
	end

	return str
end

function Bitset.getChangedIndex(idx, oldVal, newVal)
	local changedIndex, isSet
	local xor = bxor(oldVal, newVal)
	local flag

	for pos = 0, MAGIC_NUM - 1 do
		flag = lshift(1, pos)

		if band(xor, flag) ~= 0 then
			changedIndex = MAGIC_NUM * (idx - 1) + pos
			isSet = band(newVal, flag) > 0

			break
		end
	end

	return changedIndex, isSet
end

function Bitset.getMinBit(flags)
	if flags == nil then
		return nil
	end

	local minIdx

	for idx, val in pairs(flags) do
		if val and val ~= 0 and (minIdx == nil or idx < minIdx) then
			minIdx = idx
		end
	end

	if not minIdx then
		return nil
	end

	local val = flags[minIdx]

	if not val then
		return nil
	end

	for pos = 0, MAGIC_NUM - 1 do
		local mask = lshift(1, pos)

		if band(val, mask) ~= 0 then
			return MAGIC_NUM * (minIdx - 1) + pos
		end
	end

	return nil
end

return Bitset
