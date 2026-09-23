-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\String.lua

local stringEx = {}

local function checknumber(value, base)
	return tonumber(value, base) or 0
end

function stringEx.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)

	if delimiter == "" then
		return {
			input
		}
	end

	local pos, arr = 0, {}

	for st, sp in function()
		return string.find(input, delimiter, pos, true)
	end do
		table.insert(arr, string.sub(input, pos, st - 1))

		pos = sp + 1
	end

	table.insert(arr, string.sub(input, pos))

	return arr
end

function stringEx.trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")

	return string.gsub(input, "[ \t\n\r]+$", "")
end

function stringEx.ltrim(input)
	return string.gsub(input, "^[ \t\n\r]+", "")
end

function stringEx.rtrim(input)
	return string.gsub(input, "[ \t\n\r]+$", "")
end

function stringEx.utf8len(input)
	local len = string.len(input)
	local left = len
	local cnt = 0
	local arr = {
		0,
		192,
		224,
		240,
		248,
		252
	}

	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i = #arr

		while arr[i] do
			if tmp >= arr[i] then
				left = left - i

				break
			end

			i = i - 1
		end

		cnt = cnt + 1
	end

	return cnt
end

function stringEx.formatnumberthousands(num)
	local formatted = tostring(checknumber(num))
	local k

	repeat
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0

	return formatted
end

function stringEx.startswith(str, start)
	return string.startsWith(str, start)
end

function stringEx.endswith(str, ending)
	return string.endsWith(str, ending)
end

local function urlencodechar(char)
	return "%" .. string.format("%02X", string.byte(char))
end

function stringEx.urlencode(input)
	input = string.gsub(tostring(input), "\n", "\r\n")
	input = string.gsub(input, "([^%w%.%- ])", urlencodechar)

	return string.gsub(input, " ", "+")
end

function stringEx.urldecode(input)
	input = string.gsub(input, "+", " ")
	input = string.gsub(input, "%%(%x%x)", function(h)
		return string.char(checknumber(h, 16))
	end)
	input = string.gsub(input, "\r\n", "\n")

	return input
end

function stringEx.utf8len(input)
	local len = string.len(input)
	local left = len
	local cnt = 0
	local arr = {
		0,
		192,
		224,
		240,
		248,
		252
	}

	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i = #arr

		while arr[i] do
			if tmp >= arr[i] then
				left = left - i

				break
			end

			i = i - 1
		end

		cnt = cnt + 1
	end

	return cnt
end

local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-={}|[]`~"
local strLen = string.len(chars)

function stringEx.randomString(length)
	local tbl = {}

	for i = 1, length do
		local index = math.random(1, strLen)

		table.insert(tbl, string.sub(chars, index, index))
	end

	return table.concat(tbl)
end

return stringEx
