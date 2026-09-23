-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientCombatEntityComponent.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")

function M:tryEmitPlatformAchievementBossKill(oldValue)
	if oldValue == Const.LIFE_DEAD or self._platformAchievementBossKillReported then
		return
	end

	if not Utils.isPuppet(self) or self.isDummyClone or not Utils.isSemanticallyBoss(self) then
		return
	end

	if not pg.me or not pg.global or not pg.global.eventEmitter then
		return
	end

	local shouldCount = false
	local behatredMap = self.getBehatredMap and self:getBehatredMap() or nil

	if type(behatredMap) == "table" then
		if pg.me.actorId and behatredMap[pg.me.actorId] then
			shouldCount = true
		else
			local curPetEntity = pg.me.getCurPetEntity and pg.me:getCurPetEntity() or nil

			shouldCount = curPetEntity ~= nil and behatredMap[curPetEntity.actorId] ~= nil
		end
	end

	if not shouldCount and pg.space and not pg.space:isMultiPlayerEnv() then
		shouldCount = true
	end

	if not shouldCount then
		return
	end

	self._platformAchievementBossKillReported = true

	pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_ELITE_KILLED, {
		count = 1,
		actorId = self.actorId,
		templateId = self.templateId or 0
	})
end

function M:onLifeChange(oldValue, newValue)
	if newValue == Const.LIFE_DEAD then
		M.tryEmitPlatformAchievementBossKill(self, oldValue)
	elseif newValue == Const.LIFE_ALIVE then
		self._platformAchievementBossKillReported = nil
	end
end

return M
