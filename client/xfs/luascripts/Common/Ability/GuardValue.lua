-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\GuardValue.lua

local Class = require("Core.Framework.Class")
local GuardValue = Class.LiteClass("GuardValue")

function GuardValue:ctor(obj, valName, newVal)
	if not obj then
		return
	end

	self.obj = obj
	self.oldVale = obj[valName]
	obj[valName] = newVal
	self.valName = valName
end

function GuardValue:recover()
	local obj = self.obj
	local valName = self.valName

	if obj and valName then
		obj[valName] = self.oldVale
	end

	self.obj = nil
	self.oldVale = nil
	self.valName = nil
end

return GuardValue
