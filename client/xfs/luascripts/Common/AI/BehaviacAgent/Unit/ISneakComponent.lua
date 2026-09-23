-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\ISneakComponent.lua

local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ISneakComponent = Class.Component("ISneakComponent")

function ISneakComponent:switchToSneak__resetState(resetStateType)
	self:switchToState__resetState(resetStateType)
end

function ISneakComponent:switchToSneak()
	return self:switchToState(CharacterStateConst[CharacterStateConst.SNEAK].name)
end

function ISneakComponent:switchToSneakOut__resetState(resetStateType)
	self:switchToState__resetState(resetStateType)
end

function ISneakComponent:switchToSneakOut(isHit, timeout)
	return self:switchToState(isHit and CharacterStateConst[CharacterStateConst.SNEAKOUTBYHIT].name or CharacterStateConst[CharacterStateConst.SNEAKOUT].name, timeout)
end

function ISneakComponent:checkIsInSneak()
	local curState = AIControllerUtils.getCurrentAnimationState(self.ent)

	if curState == CharacterStateConst.SNEAKIN or CharacterStateConst.isChildOfState(curState, CharacterStateConst.SNEAK) then
		return true
	end

	return false
end

return ISneakComponent
