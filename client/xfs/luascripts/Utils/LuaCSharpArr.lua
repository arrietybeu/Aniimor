-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaCSharpArr.lua

local AccessAPI = CS.LuaCSMemory.LuaArrAccessAPI
local apiInit = AccessAPI.Init
local apiCreateAndPin = AccessAPI.CreateAndPinFunction

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

local needDetect = true

local function GlobalAutoDetectArch()
	if needDetect == false then
		return
	end

	needDetect = false

	if jit then
		local data = LuaCSharpArr.New(3)

		data:AutoDetectArch()
	end
end

function LuaCSharpArr.New(len, defaultVal)
	GlobalAutoDetectArch()

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
local isGCFuncSet = false

local function newGCFunc(self)
	self:OnGC()
	oldGCFunc(self)
end

local function SetCSharpAccessGCFunc(pin)
	if pin == nil then
		return
	end

	local mt = getmetatable(pin)

	if not isGCFuncSet then
		oldGCFunc = mt.__gc
		mt.__gc = newGCFunc
		isGCFuncSet = true
	end
end

function LuaCSharpArr.PinCSharpAccess(target, access)
	GlobalAutoDetectArch()

	if access == nil then
		access = apiCreateAndPin(target)

		SetCSharpAccessGCFunc(access)
	else
		pin_func(target, access)
	end

	return access
end

function LuaCSharpArr:GetCSharpAccess()
	if self.__pin == nil then
		self.__pin = LuaCSharpArr.PinCSharpAccess(self)
	end

	return self.__pin
end

function LuaCSharpArr:DestroyCSharpAccess()
	if self.__pin ~= nil then
		self.__pin:OnGC()

		self.__pin = nil
	end
end

if jit then
	function LuaCSharpArr:AutoDetectArch()
		self[1] = 32167
		self[2] = 9527.5
		self[3] = -2000000
		self[4] = "test test"

		local acc = self:GetCSharpAccess()

		if acc == nil then
			return
		end

		acc:AutoDetectArch()
	end
else
	function LuaCSharpArr:AutoDetectArch()
		return
	end
end

return LuaCSharpArr
