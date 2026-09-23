-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\External\\bson.lua

local function ppp(t, d, e)
	if e == nil then
		e = ""
	end

	e = e .. "  "

	print("tab", t)

	if type(d) == "string" then
		print("index", "value", "char code")

		for i = 1, #d do
			print(i, d:sub(i, i), string.byte(d:sub(i, i)))
		end
	elseif type(d) == "table" then
		print("index", "value", "char code")

		for i, j in pairs(d) do
			if type(j) == "table" then
				ppp(t .. " - " .. i, j, e)
			else
				local code

				code = type(j) == "boolean" and "bool" or string.byte(j)

				print(i, j, code)
			end
		end
	else
		print(d)
	end

	if #e == 2 then
		print("")
	end
end

local bson = {}

local function _toLSB(bytes, value)
	local str = ""

	for j = 1, bytes do
		str = str .. string.char(value % 256)
		value = math.floor(value / 256)
	end

	return str
end

local function _toLSB16(value)
	return _toLSB(2, value)
end

local function _toLSB32(value)
	return _toLSB(4, value)
end

local function _toLSB64(value)
	return _toLSB(8, value)
end

local function _fromLSB8(s, p)
	return s:byte(p), p + 1
end

local function _fromLSB16(s, p)
	return s:byte(p) + s:byte(p + 1) * 256, p + 2
end

local function _fromLSB32(s, p)
	return s:byte(p) + s:byte(p + 1) * 256 + s:byte(p + 2) * 65536 + s:byte(p + 3) * 16777216, p + 4
end

local function _fromLSB64(s, p)
	return _fromLSB32(s, p) + s:byte(p + 4) * 4294967296 + s:byte(p + 5) * 1099511627776 + s:byte(p + 6) * 281474976710660 + s:byte(p + 7) * 7.2057594037928e+16, p + 8
end

local function _to_double(value)
	local buffer = ""
	local float64 = {}
	local bias = 1023
	local max_bias = 2047
	local sign
	local exponent_length = 11
	local mantissa = 0
	local mantissa_length = 52

	sign = value < 0 and 1 or 0
	value = math.abs(value)

	local exponent = math.floor(math.log(value) / math.log(2))
	local flag = math.pow(2, -exponent)

	if value * flag < 1 then
		exponent = exponent - 1
		flag = flag * 2
	end

	if value * flag >= 2 then
		exponent = exponent + 1
		flag = flag / 2
	end

	if max_bias <= exponent + bias then
		exponent = max_bias
	elseif exponent + bias >= 1 then
		mantissa = (value * flag - 1) * math.pow(2, mantissa_length)
		exponent = exponent + bias
	else
		mantissa = value * math.pow(2, bias - 1) * math.pow(2, mantissa_length)
		exponent = 0
	end

	while mantissa_length >= 8 do
		table.insert(float64, math.floor(mantissa % 256))

		mantissa = mantissa / 256
		mantissa_length = mantissa_length - 8
	end

	exponent = math.floor(exponent * math.pow(2, mantissa_length) + mantissa)
	exponent_length = exponent_length + mantissa_length

	while exponent_length > 0 do
		table.insert(float64, math.floor(exponent % 256))

		exponent = exponent / 256
		exponent_length = exponent_length - 8
	end

	float64[8] = float64[8] + sign * 128

	for i, value in pairs(float64) do
		buffer = buffer .. string.char(value)
	end

	return buffer
end

function bson.to_bool(n, v)
	local pre = "\b" .. n .. "\x00"

	if v then
		return pre .. "\x01"
	else
		return pre .. "\x00"
	end
end

function bson.to_str(n, v)
	return "\x02" .. n .. "\x00" .. _toLSB32(#v + 1) .. v .. "\x00"
end

function bson.to_int32(n, v)
	return "\x10" .. n .. "\x00" .. _toLSB32(v)
end

function bson.to_int64(n, v)
	return "\x12" .. n .. "\x00" .. _toLSB64(v)
end

function bson._to_double(n, v)
	return "\x01" .. n .. "\x00" .. _to_double(v)
end

function bson.to_x(n, v)
	return v(n)
end

function bson.utc_datetime(t)
	local t = t or os.time() * 1000

	local function f(n)
		return "\t" .. n .. "\x00" .. _toLSB64(t)
	end

	return f
end

bson.B_GENERIC = "\x00"
bson.B_FUNCTION = "\x01"
bson.B_UUID = "\x04"
bson.B_MD5 = "\x05"
bson.B_USER_DEFINED = "\x80"

function bson.binary(v, subtype)
	local subtype = subtype or bson.B_GENERIC

	local function f(n)
		return "\x05" .. n .. "\x00" .. _toLSB32(#v) .. subtype .. v
	end

	return f
end

function bson.to_num(n, v)
	if v == math.huge then
		return "\x01" .. n .. "\x00\x00\x00\x00\x00\x00\x00\xF0\x7F"
	elseif v == -math.huge then
		return "\x01" .. n .. "\x00\x00\x00\x00\x00\x00\x00\xF0\xFF"
	elseif v ~= v then
		return "\x01" .. n .. "\x00\x01\x00\x00\x00\x00\x00\xF0\x7F"
	end

	if math.floor(v) ~= v then
		return bson._to_double(n, v)
	elseif v > 2147483647 or v < -2147483648 then
		return bson.to_int64(n, v)
	else
		return bson.to_int32(n, v)
	end
end

local lua_to_bson_tbl = {
	boolean = bson.to_bool,
	string = bson.to_str,
	number = bson.to_num,
	table = bson.to_doc,
	["function"] = bson.to_x
}

function bson.to_doc(n, doc)
	local d = bson.start()
	local docType = "\x03"

	for cnt, v in ipairs(doc) do
		local t = type(v)
		local o = lua_to_bson_tbl[t](tostring(cnt - 1), v)

		d = d .. o
		docType = "\x04"
	end

	if d == "" then
		for nm, v in pairs(doc) do
			local t = type(v)
			local o = lua_to_bson_tbl[t](nm, v)

			d = d .. o
		end
	end

	return docType .. n .. "\x00" .. bson.finish(d)
end

function bson.start()
	return ""
end

function bson.finish(doc)
	doc = doc .. "\x00"

	return _toLSB32(#doc + 4) .. doc
end

function bson.encode(doc)
	local d = bson.start()

	for e, v in pairs(doc) do
		local t = type(v)
		local o = lua_to_bson_tbl[t](e, v)

		d = d .. o
	end

	return bson.finish(d)
end

function bson.from_bool(doc, startPos)
	return doc:byte(startPos) == 1, startPos + 1
end

function bson.from_int16(doc, startPos)
	return _fromLSB16(doc, startPos)
end

function bson.from_int32(doc, startPos)
	return _fromLSB32(doc, startPos)
end

function bson.from_int64(doc, startPos)
	return _fromLSB64(doc, startPos)
end

function bson.from_double(doc, startPos)
	local buffer = {}
	local bias = 1023
	local last = 0
	local sign = 1

	for i = 1, 8 do
		last = 8 - (i - 1)
		buffer[i] = string.byte(doc:sub(startPos + last - 1, startPos + last - 1))
	end

	if math.floor(buffer[1] / math.pow(2, 7)) > 0 then
		sign = -1
	end

	local exponent = math.floor(buffer[1] % 128)

	exponent = exponent * 256 + buffer[2]

	local mantissa = math.floor(exponent % 16)

	exponent = math.floor(exponent / math.pow(2, 4))

	for i = 3, 8 do
		mantissa = mantissa * 256 + buffer[i]
	end

	if exponent == 0 then
		exponent = 1 - bias
	elseif exponent == 2047 then
		if mantissa > 0 then
			return 0 / 0
		else
			return sign * (1 / 0)
		end
	else
		mantissa = mantissa + 4503599627370496
		exponent = exponent - bias
	end

	return sign * mantissa * math.pow(2, exponent - 52), startPos + 8
end

function bson.from_utc_date_time(doc, startPos)
	return _fromLSB64(doc, startPos)
end

local bson_to_lua_tbl = {
	bson.from_double,
	bson.from_str,
	[16] = bson.from_int32,
	[18] = bson.from_int64,
	[8] = bson.from_bool,
	bson.decode_doc,
	bson.decode_doc,
	bson.from_binary,
	[9] = bson.from_utc_date_time
}

function bson.from_binary(doc, startPos)
	local len, nextPos = _fromLSB32(doc, startPos)
	local str = doc:sub(nextPos + 1, nextPos + 1 + len - 1)

	return str, nextPos + 1 + len
end

function bson.from_str(doc, startPos)
	local len, nextPos = _fromLSB32(doc, startPos)
	local str = doc:sub(nextPos, nextPos + len - 2)

	return str, nextPos + len
end

function bson.decode_doc(doc, startPos, docType)
	local len, nextPos = bson.from_int32(doc, startPos)

	return bson.decode_doc_(len, doc, nextPos, docType)
end

function bson.decode_doc_(len, doc, startPos, docType)
	local luatab = {}
	local nextPos = startPos
	local val, ename, etype

	repeat
		etype, nextPos = _fromLSB8(doc, nextPos)

		if etype == 0 then
			break
		elseif not bson_to_lua_tbl[etype] then
			val, nextPos = bson.readUnknownElement(doc, nextPos, etype)
		else
			ename = doc:match("(%Z+)\x00", nextPos)
			nextPos = nextPos + #ename + 1
			val, nextPos = bson_to_lua_tbl[etype](doc, nextPos, etype)
		end

		if docType == 4 or not ename then
			table.insert(luatab, val)
		else
			luatab[ename] = val
		end
	until not doc

	return luatab, nextPos
end

function bson.decode(len, doc)
	return bson.decode_doc_(len, doc, 1, nil)
end

function bson.decode_next_io(fd)
	local slen = fd:read(4)

	if not slen then
		return nil
	end

	local len, _ = _fromLSB32(slen, 1) - 4
	local doc = fd:read(len)

	return bson.decode(len, doc)
end

function bson.readUnknownElement(doc, startPos, etype)
	local len, nextPos = bson.from_int32(doc, startPos)
	local val = {
		is_undefined = true,
		etype = etype,
		data = doc:sub(nextPos, nextPos + len - 4 - 2)
	}

	return val, nextPos + len - 4
end

function bson.readDocument(fd)
	local slen = fd:read(4)

	if not slen then
		return nil
	end

	local len, _ = _fromLSB32(slen, 1) - 4
	local doc = fd:read(len)

	return doc, len
end

function bson.readByte(s, p)
	return _fromLSB8(s, p)
end

function bson.readBool(s, p)
	return bson.from_bool(s, p)
end

function bson.readInt16(s, p)
	return _fromLSB16(s, p)
end

function bson.readInt32(s, p)
	return _fromLSB32(s, p)
end

function bson.readString(s, p)
	local len, nextPos = _fromLSB16(s, p)
	local str = s:sub(nextPos, nextPos + len - 2)

	return str, nextPos + len
end

return bson
