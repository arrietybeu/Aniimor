-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\Delegate.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Delegate")
local Delegate = Class.LightClass("Delegate")

function Delegate:ctor()
	self.instArr = {}
	self.funcArr = {}
	self.invoking = false
	self.dirty = false
end

function Delegate:addListener(inst, func)
	if type(func) ~= "function" then
		error("Delegate.AddListener expects a function")
	end

	local funcArr = self.funcArr

	for i = 1, #funcArr do
		if funcArr[i] == func and self.instArr[i] == inst then
			return
		end
	end

	funcArr[#funcArr + 1] = func
	self.instArr[#self.instArr + 1] = inst
end

function Delegate:removeListener(func, inst)
	for i = #self.funcArr, 1, -1 do
		if self.funcArr[i] == func and (inst == nil or self.instArr[i] == inst) then
			if self.invoking then
				self.funcArr[i] = false
				self.instArr[i] = false
				self.dirty = true
			else
				table.remove(self.instArr, i)
				table.remove(self.funcArr, i)
			end
		end
	end
end

function Delegate:clear()
	self.instArr = {}
	self.funcArr = {}
	self.dirty = false
end

function Delegate:invoke(...)
	self.invoking = true

	local funcArr = self.funcArr
	local instArr = self.instArr

	for index = 1, #funcArr do
		local func = funcArr[index]

		if func then
			local inst = instArr[index]
			local status, err = xpcall(func, debug.traceback, inst, ...)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("Delegate:invoke traceback occurred \n", ex)
				end
			end
		end
	end

	self.invoking = false

	if self.dirty then
		self.dirty = false

		for i = #funcArr, 1, -1 do
			if funcArr[i] == false then
				table.remove(instArr, i)
				table.remove(funcArr, i)
			end
		end
	end
end

return Delegate
