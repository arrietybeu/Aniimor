-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\SimpleLuaCSharpArr.lua

local AccessAPI = CS.LuaCSMemory.LuaArrAccessAPI
local apiInit = AccessAPI.Init
local apiCreateAccess = AccessAPI.CreateLuaShareAccess

apiInit(jit)

local LuaCSharpArr = {
	class = "LuaCSharpArr"
}
local fields = {}
local pin_func = AccessAPI.PinFunction
local IsJit = 0

if jit then
	IsJit = 1
end

setmetatable(LuaCSharpArr, LuaCSharpArr)

function LuaCSharpArr.__index(t, k)
	local var = rawget(LuaCSharpArr, k)

	return var
end

function LuaCSharpArr.New(len, defaultVal)
	local v = {}

	for i = 1, len do
		v[i] = defaultVal or 0
	end

	setmetatable(v, LuaCSharpArr)

	return v
end

function LuaCSharpArr.NewByTable(v)
	setmetatable(v, LuaCSharpArr)

	return v
end

local oldGCFunc

local function newGCFunc(self)
	self:OnGC()
	oldGCFunc(self)
end

local function SetCSharpAccessGCFunc(pin)
	local mt = getmetatable(pin)

	if oldGCFunc == nil then
		oldGCFunc = mt.__gc
	end

	mt.__gc = newGCFunc
end

function LuaCSharpArr:GetCSharpAccess()
	if self.__pin == nil then
		self.__pin = apiCreateAccess()

		pin_func(self, self.__pin)
		SetCSharpAccessGCFunc(self.__pin)
	end

	return self.__pin
end

function LuaCSharpArr:DestroyCSharpAccess()
	if self.__pin ~= nil then
		self.__pin:OnGC()

		self.__pin = nil
	end
end

return LuaCSharpArr
