-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\BILoggerTableEncode.lua

local encode
local escape_char_map = {
	["\b"] = "\\b",
	["\t"] = "\\t",
	["\""] = "\\\"",
	["\r"] = "\\r",
	["\\"] = "\\\\",
	["\f"] = "\\f",
	["\n"] = "\\n"
}
local escape_char_map_inv = {
	["\\/"] = "/"
}

for k, v in pairs(escape_char_map) do
	escape_char_map_inv[v] = k
end

local function escape_char(c)
	return escape_char_map[c] or string.format("\\u%04x", c:byte())
end

local function encode_nil(val)
	return "null"
end

local function is_array(val)
	if type(val) ~= "table" then
		return false
	end

	local n = 0

	for k in pairs(val) do
		if type(k) ~= "number" or k % 1 ~= 0 or k < 1 then
			return false
		end

		n = math.max(n, k)
	end

	return n == #val
end

local function encode_table(val, stack)
	local res = {}

	stack = stack or {}

	if stack[val] then
		error("circular reference")
	end

	stack[val] = true

	if is_array(val) then
		for i, v in ipairs(val) do
			table.insert(res, encode(v, stack))
		end

		stack[val] = nil

		return "[" .. table.concat(res, ",") .. "]"
	else
		for k, v in pairs(val) do
			if type(k) == "number" or type(k) == "boolean" then
				k = tostring(k)
			elseif type(k) ~= "string" then
				error("invalid table: mixed or invalid key types")
			end

			table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
		end

		stack[val] = nil

		return "{" .. table.concat(res, ",") .. "}"
	end
end

local function encode_string(val)
	return "\"" .. val:gsub("[%z\x01-\x1F\\\"]", escape_char) .. "\""
end

local function encode_number(val)
	if val ~= val then
		error("unexpected number value '" .. tostring(val) .. "'")
	end

	if val >= math.huge then
		return "1e308"
	end

	if val <= -math.huge then
		return "-1e308"
	end

	return string.format("%.14g", val)
end

local type_func_map = {
	["nil"] = encode_nil,
	table = encode_table,
	string = encode_string,
	number = encode_number,
	boolean = tostring
}

function encode(val, stack)
	local t = type(val)
	local f = type_func_map[t]

	if f then
		return f(val, stack)
	end

	error("unexpected type '" .. t .. "'")
end

local function BILoggerTableEncode(tb)
	local res = ""

	if tb == nil then
		return res
	end

	xpcall(function()
		res = encode(tb)
	end, debug.traceback)

	return res
end

return BILoggerTableEncode
