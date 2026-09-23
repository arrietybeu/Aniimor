-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Projectile\\ProjectileManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local ProjectileManager = Class.LiteClass("ProjectileManager")
local EnableBotTest = EnableBotTest
local pg = pg

function ProjectileManager:ctor(space, projectileGenerator)
	self.space = space
	self.projFreeList = {}
	self.projectileMap = {}
	self.curProjNum = 0
	self.projectileGenerator = projectileGenerator
end

function ProjectileManager:tick(deltaTime)
	for instanceId, projectile in pairs(self.projectileMap) do
		local isSucc, result = xpcall(projectile.activate, debug.traceback, projectile, deltaTime)

		if not isSucc then
			CombatLogger.logException("tickProjectile error", projectile.templateId, result)

			if not projectile.isDestroyed then
				if not projectile.combatContext then
					projectile:destroy(true)
				else
					projectile.curTime = projectile.curTime + deltaTime

					if projectile.curTime >= projectile.duration then
						projectile:destroy()
					end
				end
			end
		end
	end
end

function ProjectileManager:onGameTimeScaleChange()
	if pg.component == "game" then
		return
	end

	for _, projectile in pairs(self.projectileMap) do
		projectile:applyTimeScale()
	end
end

function ProjectileManager:newProjectile(projectileParams)
	local newProj

	if next(self.projFreeList) == nil then
		newProj = self.projectileGenerator()
	else
		newProj = self.projFreeList[#self.projFreeList]
		self.projFreeList[#self.projFreeList] = nil
	end

	newProj:init(projectileParams)

	self.curProjNum = self.curProjNum + 1
	self.projectileMap[projectileParams.instanceId] = newProj

	return newProj
end

function ProjectileManager:removeProjectile(instanceId)
	local projectile = self.projectileMap[instanceId]

	if not projectile then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("removeProjectile failed, projectile not found", instanceId)
		end

		return
	end

	self.projectileMap[instanceId] = nil

	projectile:clear()

	self.curProjNum = self.curProjNum - 1
	self.projFreeList[#self.projFreeList + 1] = projectile
end

function ProjectileManager:addProjectile(projectileParams, combatContext)
	combatContext = combatContext or CombatActionTool.getCombatContextById(projectileParams.srcCombatContextId)

	if not combatContext then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("addProjectile failed, combatContext not found", projectileParams.templateId, projectileParams.instanceId, projectileParams.srcActorId, projectileParams.srcCombatContextId)
		end

		pg.global.abilityMgr.projectileParamsPool:returnObject(projectileParams)

		return nil
	end

	local projectile = self:newProjectile(projectileParams)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("addProjectile", projectileParams.templateId, projectileParams.instanceId)
	end

	if not projectile:loadDataFromTemplate() then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("projectile loadDataFromTemplate failed", projectileParams.templateId, projectileParams.srcActorId, projectileParams.projectileType)
		end

		self:removeProjectile(projectileParams.instanceId)
		pg.global.abilityMgr.projectileParamsPool:returnObject(projectileParams)

		return nil
	end

	projectile:start()

	local srcEntity = pg.getEntityByActorId(projectileParams.srcActorId)

	srcEntity.createdProjectileList[projectileParams.instanceId] = projectile

	if pg.component == "client" then
		local isFromDialogueGraph = combatContext and combatContext.constCasterInfo and combatContext.constCasterInfo.castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

		if srcEntity.authority == Const.AUTHORITY_MASTER and not isFromDialogueGraph then
			srcEntity:serverMsgNoGC("RPC_CS_AddProjectile", projectileParams, combatContext.id, combatContext.nodeStack)
		end
	elseif pg.component == "game" then
		if srcEntity.authority == Const.AUTHORITY_MASTER then
			srcEntity:allClientsMsgNoGC("RPC_SC_AddProjectile", projectileParams)
		else
			srcEntity:otherClientsMsgNoGC("RPC_SC_AddProjectile", projectileParams)
		end
	end

	pg.global.abilityMgr.projectileParamsPool:returnObject(projectileParams)

	return projectile
end

function ProjectileManager:getProjectile(instanceId)
	return self.projectileMap[instanceId]
end

function ProjectileManager:destroy()
	for _, projectile in pairs(self.projectileMap) do
		projectile:destroy(true)
	end

	self.space = nil
	self.projectileGenerator = nil
end

return ProjectileManager
