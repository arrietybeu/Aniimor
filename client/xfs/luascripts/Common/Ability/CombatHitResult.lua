-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\CombatHitResult.lua

local Class = require("Core.Framework.Class")
local CombatHitResult = Class.LiteClass("CombatHitResult")

function CombatHitResult:ctor(hitActorId, hitPos, hitActorPartIdx)
	self.hitActorId = hitActorId
	self.hitPos = hitPos
	self.hitActorPartIdx = hitActorPartIdx
end

return CombatHitResult
