-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\tuple.lua

local unpack = unpack or table.unpack
local setmetatable = setmetatable
local ipairs = ipairs
local tostring = tostring
local min = math.min
local type = type
local assert = assert
local select = select
local t_concat = table.concat
local tuple = {}

tuple.__index = tuple

function tuple.__call(t, i, j)
	return tuple(unpack(t, i, j))
end

function tuple:elements(...)
	local i = 0

	return function(...)
		i = i + 1

		if self[i] ~= nil then
			return i, self[i]
		end
	end
end

function tuple:len()
	return self.n
end

function tuple:has(v)
	for k, _v in ipairs(self) do
		if _v == v then
			return true
		end
	end

	return false
end

function tuple:includes(other)
	if self.n < other.n then
		return false
	end

	for _, element in other:elements() do
		if not self:has(element) then
			return false
		end
	end

	return true
end

function tuple:toArray()
	return {
		unpack(self)
	}
end

function tuple:__eq(other)
	if self.n ~= other.n then
		return false
	end

	for i, element in other:elements() do
		if element ~= self[i] then
			return false
		end
	end

	return true
end

function tuple:__le(other)
	local n = min(self.n, other.n)

	for i = 1, n do
		if self[i] > other[i] then
			return false
		end
	end

	return true
end

function tuple:__lt(other)
	local n = min(self.n, other.n)

	for i = 1, n do
		if self[i] >= other[i] then
			return false
		end
	end

	return true
end

function tuple.__add(a, b)
	local t = a()

	for _, element in b:elements() do
		t[#t + 1] = element
	end

	t.n = #t

	return t
end

function tuple.__mul(t, n)
	if type(n) == "number" then
		assert(math.floor(n) == n, ("Wrong argument n. Integer expected, got (%s)"):format(n))

		local _t

		for i = 1, n do
			_t = (_t or tuple()) + t
		end

		return _t
	else
		return n * t
	end
end

function tuple.__newindex(t, k, v)
	error("'tuple' object does not support item assignment")
end

tuple._TUPLE_GLOBALS = {}

local function find_tuple(...)
	local t = tuple._TUPLE_GLOBALS

	for _, v in ipairs({
		...
	}) do
		if t[v] ~= nil then
			t = t[v]
		else
			return
		end
	end

	return t
end

local function save_tuple(n, ...)
	local t = tuple._TUPLE_GLOBALS
	local args = {
		...
	}
	local an = #args

	for i, v in ipairs(args) do
		if t[v] == nil then
			if an ~= i then
				t[v] = {}
				t = t[v]
			else
				t[v] = n
			end
		else
			t = t[v]
		end
	end
end

return setmetatable(tuple, {
	__call = function(self, ...)
		local t = find_tuple(...)

		if t == nil then
			local new_tuple = {
				n = select("#", ...),
				...
			}
			local mt = setmetatable(new_tuple, tuple)

			save_tuple(mt, ...)

			return mt
		else
			return t
		end
	end
})
