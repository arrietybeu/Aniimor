-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Projectile\\EditorProjectileManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ProjectileConst = require("Common.Const.ProjectileConst")
local Const = require("Common.Const.Const")
local ProjectileManager = require("Common.Ability.Projectile.ProjectileManager")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local SkillBPDebugData = CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData
local EditorProjectileManager = Class.LiteClass("EditorProjectileManager", ProjectileManager)

function EditorProjectileManager:tick(deltaTime)
	for instanceId, projectile in pairs(self.projectileMap) do
		projectile:activate(deltaTime)
	end
end

function EditorProjectileManager:addProjectile(projectileParams, combatContext)
	local projectile = self:newProjectile(projectileParams)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("addProjectile", projectileParams.templateId, projectileParams.instanceId)
	end

	if not projectile:loadDataFromTemplate() then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("projectile loadDataFromTemplate failed", projectileParams.templateId, projectileParams.srcActorId, projectileParams.projectileType)
		end

		self:removeProjectile(projectileParams.instanceId)

		return nil
	end

	projectile:start()
	SkillBPDebugData.CallXLuaEntServerMsgNoCb(projectileParams.srcActorId, "RPC_CS_DebugModeAddProjectile", {
		projectileParams,
		combatContext.id
	})

	return projectile
end

return EditorProjectileManager
