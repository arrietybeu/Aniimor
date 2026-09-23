-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIBaseAbility.lua

local Class = require("Core.Framework.Class")
local AIBaseAbility = Class.LiteClass("AIBaseAbility")

function AIBaseAbility:ctor()
	self.customTimeout = {}
end

function AIBaseAbility:init(entity)
	self.ent = entity
end

function AIBaseAbility:release()
	self.ent = nil

	if self.customTimeout then
		table.clear(self.customTimeout)
	end
end

function AIBaseAbility:_checkCustomTimeoutExist(timeoutId)
	if self.customTimeout[timeoutId] == nil then
		return false
	end

	return true
end

function AIBaseAbility:_settingCustomTimeout(timeoutId, timeout)
	self.customTimeout[timeoutId] = timeout + self.ent:getCurrScaledTime()
end

function AIBaseAbility:_getCustomTimeout(timeoutId)
	return self.customTimeout[timeoutId]
end

function AIBaseAbility:_checkCustomTimeout(timeoutId)
	if self:_checkCustomTimeoutExist(timeoutId) and self.customTimeout[timeoutId] > self.ent:getCurrScaledTime() then
		return false
	end

	return true
end

function AIBaseAbility:_checkAndRemoveCustomTimeout(timeoutId)
	if not self:_checkCustomTimeout(timeoutId) then
		return false
	end

	self:_removeCustomTimeout(timeoutId)

	return true
end

function AIBaseAbility:_checkAndSetCustomTimeout(timeoutId, timeout)
	if self:_checkCustomTimeoutExist(timeoutId) == false then
		self:_settingCustomTimeout(timeoutId, timeout)
	end

	return self:_checkAndRemoveCustomTimeout(timeoutId)
end

function AIBaseAbility:_removeCustomTimeout(timeoutId)
	self.customTimeout[timeoutId] = nil
end

function AIBaseAbility:_getLastCustomTimeout(timeoutId)
	if self.customTimeout[timeoutId] then
		return self.customTimeout[timeoutId] - self.ent:getCurrScaledTime()
	end

	return 0
end

return AIBaseAbility
