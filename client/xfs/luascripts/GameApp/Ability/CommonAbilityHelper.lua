-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\CommonAbilityHelper.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local CommonAbilityHelper = {}

function CommonAbilityHelper.performCommonAbility(abilityId)
	local func = CommonAbilityHelper["perform_" .. abilityId]

	if func then
		return func()
	end
end

function CommonAbilityHelper.cancelCommonAbility(abilityId)
	local func = CommonAbilityHelper["cancel_" .. abilityId]

	if func then
		return func()
	end
end

function CommonAbilityHelper.perform_9000001()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleDash(true)
	end
end

function CommonAbilityHelper.cancel_9000001()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleDash(false)
	end
end

function CommonAbilityHelper.perform_9000004()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleJump(true)
	end
end

function CommonAbilityHelper.cancel_9000004()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleJump(false)
	end
end

function CommonAbilityHelper.perform_9001001()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleDash(true)
	end
end

function CommonAbilityHelper.cancel_9001001()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleDash(false)
	end
end

function CommonAbilityHelper.perform_9001004()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleJump(true)
	end
end

function CommonAbilityHelper.cancel_9001004()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleJump(false)
	end
end

function CommonAbilityHelper.perform_9000006()
	if pg.game.controller ~= nil then
		pg.game.controller:onHandleThrow()
	end
end

function CommonAbilityHelper.perform_9000007()
	if pg.game.controller ~= nil then
		pg.game.controller:setCatchModeEnable(false)
	end
end

function CommonAbilityHelper.cancel_9000006()
	return
end

return CommonAbilityHelper
