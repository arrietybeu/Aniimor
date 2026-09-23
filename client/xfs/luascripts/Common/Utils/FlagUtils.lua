-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\FlagUtils.lua

local Bitset = require("Common.Bitset")
local FlagUtils = {}
local bor = Bitset.bor
local band = Bitset.band
local bnot = Bitset.bnot
local lshift = Bitset.lshift
local getBit = Bitset.getBit
local setBit = Bitset.setBit
local clrBit = Bitset.clrBit
local getList = Bitset.getList
local bdump = Bitset.dump

local function normalizeValue(value)
	if type(value) ~= "number" then
		return 0
	end

	return value
end

local function isValidMask(mask)
	return type(mask) == "number" and mask ~= 0
end

local function isValidFlagIndex(flagIndex)
	return type(flagIndex) == "number" and flagIndex >= 0
end

local function normalizeFlags(flags)
	if flags == nil then
		return {}
	end

	return flags
end

function FlagUtils.makeMask(flagIndex)
	if not isValidFlagIndex(flagIndex) then
		return 0
	end

	return lshift(1, flagIndex)
end

function FlagUtils.hasAnyMask(value, mask)
	if not isValidMask(mask) then
		return false
	end

	return band(normalizeValue(value), mask) ~= 0
end

function FlagUtils.hasAllMask(value, mask)
	if not isValidMask(mask) then
		return false
	end

	return band(normalizeValue(value), mask) == mask
end

function FlagUtils.addMask(value, mask)
	value = normalizeValue(value)

	if not isValidMask(mask) then
		return value
	end

	return bor(value, mask)
end

function FlagUtils.removeMask(value, mask)
	value = normalizeValue(value)

	if not isValidMask(mask) then
		return value
	end

	return band(value, bnot(mask))
end

function FlagUtils.setMask(value, mask, enabled)
	if enabled then
		return FlagUtils.addMask(value, mask)
	end

	return FlagUtils.removeMask(value, mask)
end

function FlagUtils.hasFlag(flags, flagIndex)
	if not isValidFlagIndex(flagIndex) then
		return false
	end

	return getBit(flags, flagIndex)
end

function FlagUtils.addFlag(flags, flagIndex)
	flags = normalizeFlags(flags)

	if not isValidFlagIndex(flagIndex) then
		return flags, false
	end

	return flags, setBit(flags, flagIndex)
end

function FlagUtils.removeFlag(flags, flagIndex)
	flags = normalizeFlags(flags)

	if not isValidFlagIndex(flagIndex) then
		return flags, false
	end

	return flags, clrBit(flags, flagIndex)
end

function FlagUtils.setFlag(flags, flagIndex, enabled)
	if enabled then
		return FlagUtils.addFlag(flags, flagIndex)
	end

	return FlagUtils.removeFlag(flags, flagIndex)
end

function FlagUtils.getFlagList(flags)
	if flags == nil then
		return {}
	end

	return getList(flags)
end

function FlagUtils.intersects(a, b)
	if a == nil or b == nil then
		return false
	end

	for idx, aval in pairs(a) do
		local bval = b[idx]

		if bval and band(aval, bval) ~= 0 then
			return true
		end
	end

	return false
end

function FlagUtils.containsAll(a, b)
	if b == nil then
		return true
	end

	for idx, bval in pairs(b) do
		if bval ~= 0 then
			local aval = a and a[idx] or 0

			if band(aval, bval) ~= bval then
				return false
			end
		end
	end

	return true
end

function FlagUtils.merge(a, b)
	a = normalizeFlags(a)

	if b == nil then
		return a
	end

	for idx, bval in pairs(b) do
		if bval ~= 0 then
			a[idx] = bor(a[idx] or 0, bval)
		end
	end

	return a
end

function FlagUtils.subtract(a, b)
	a = normalizeFlags(a)

	if b == nil then
		return a
	end

	for idx, bval in pairs(b) do
		if bval ~= 0 and a[idx] then
			local newVal = band(a[idx], bnot(bval))

			if newVal == 0 then
				a[idx] = nil
			else
				a[idx] = newVal
			end
		end
	end

	return a
end

function FlagUtils.dump(flags, enum)
	return bdump(flags, enum)
end

return FlagUtils
