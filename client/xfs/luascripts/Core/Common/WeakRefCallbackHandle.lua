-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\WeakRefCallbackHandle.lua

local WeakRefCallbackHandle = {
	WeakRefCallbackHandle = true
}
local weakRefMeta = {
	__mode = "v"
}
local unpack = unpack

WeakRefCallbackHandle.__index = WeakRefCallbackHandle

function WeakRefCallbackHandle.new(handle, ...)
	local ins = {}
	local argLen = select("#", ...)

	ins.handle = handle
	ins.refValid = true

	if argLen > 0 then
		local weakTable = {}

		for i = 1, argLen do
			weakTable[i] = select(i, ...)
		end

		setmetatable(weakTable, weakRefMeta)

		ins.weakRef = weakTable
		ins.argLen = argLen
	end

	setmetatable(ins, WeakRefCallbackHandle)

	return ins
end

function WeakRefCallbackHandle:__call(...)
	self.refValid = true

	if self.argLen then
		local weakRef = self.weakRef

		for i = 1, self.argLen do
			if not weakRef or weakRef[i] == nil then
				self.refValid = false

				if self.clearFun then
					local clearFun = self.clearFun

					self.clearFun = nil

					clearFun()
				end

				return
			end
		end

		if self.argLen == 1 then
			self.handle(weakRef[1], ...)
		else
			self.handle(weakRef[1], weakRef[2], ...)
		end
	else
		return self.handle(...)
	end
end

function WeakRefCallbackHandle:setClearFun(clearFun)
	self.clearFun = clearFun
end

return WeakRefCallbackHandle
