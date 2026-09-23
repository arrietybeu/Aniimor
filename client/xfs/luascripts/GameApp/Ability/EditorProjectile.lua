-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\EditorProjectile.lua

local Class = require("Core.Framework.Class")
local ClientProjectile = require("GameApp.Ability.ClientProjectile")
local EditorProjectile = Class.LiteClass("EditorProjectile", ClientProjectile)

function EditorProjectile:onProjectileHitRPC(srcEntity, combatHitResult, nextReboundActorId)
	return false
end

function EditorProjectile:onProjectileFinishRPC()
	return false
end

function EditorProjectile:onProjectileResetRPC()
	return false
end

return EditorProjectile
