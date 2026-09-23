-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\IDManager.lua

local bson = require("bson")
local phonestcore = require("phonestcore")
local IDManager = {}
local string_format = string.format
local string_byte = string.byte
local string_gsub = string.gsub
local string_char = string.char

function IDManager.genID()
	return phonestcore.genID()
end

function IDManager.genB64ID()
	return phonestcore.genBase64ID()
end

function IDManager.genStrID()
	return IDManager.bytesToStr(IDManager.genID())
end

local function hex(x)
	return string_format("%02x", string_byte(x))
end

function IDManager.bytesToStr(s)
	s = string_gsub(s, "(.)", hex)

	return s
end

local h2b = {
	a = 10,
	f = 15,
	["0"] = 0,
	c = 12,
	d = 13,
	["9"] = 9,
	["8"] = 8,
	["7"] = 7,
	["6"] = 6,
	["5"] = 5,
	["4"] = 4,
	["3"] = 3,
	["2"] = 2,
	["1"] = 1,
	e = 14,
	b = 11
}

local function bin(h, l)
	return string_char(h2b[h] * 16 + h2b[l])
end

function IDManager.strToBytes(hexstr)
	local s = string_gsub(hexstr, "(.)(.)", bin)

	return s
end

return IDManager
