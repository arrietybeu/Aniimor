-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientBossRushDungeon.lua

local Class = require("Core.Framework.Class")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local BossRushUtils = require("Utils.BossRushUtils")
local ClientBossRushDungeon = Class.Class("ClientBossRushDungeon", ClientPveDungeon)

function ClientBossRushDungeon:ctor(entityId)
	ClientBossRushDungeon.super.ctor(self, entityId)

	self.rogueGroundReady = false
	self.waitGroundReadySet = {}
end

function ClientBossRushDungeon:registerWaitGroundReady(entity)
	self.waitGroundReadySet[entity] = true
end

function ClientBossRushDungeon:unregisterWaitGroundReady(entity)
	self.waitGroundReadySet[entity] = nil
end

function ClientBossRushDungeon:resetGroundReady()
	self.rogueGroundReady = false
end

function ClientBossRushDungeon:onRogueGroundReady()
	self.rogueGroundReady = true

	local waiting = self.waitGroundReadySet

	self.waitGroundReadySet = {}

	for entity in pairs(waiting) do
		if entity and not entity.isDestroyed and entity.onRogueGroundReady then
			entity:onRogueGroundReady()
		end
	end
end

function ClientBossRushDungeon:init(dict)
	ClientBossRushDungeon.super.init(self, dict)

	BossRushUtils.hasSettle = false

	return true
end

function ClientBossRushDungeon:start()
	ClientBossRushDungeon.super.start(self)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_BOSS_RUSH_MAIN) then
		pg.global.ui:close(UIConst.UI_ID_BOSS_RUSH_MAIN)
	end
end

function ClientBossRushDungeon:onSelectedTankEntIdChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_TEAM_TANK_CHANGED, true)
end

function ClientBossRushDungeon:onBattleStartTimeChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_BATTLE_START_TIME_CHANGED)
end

function ClientBossRushDungeon:onLevelScoreChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_LEVEL_SCORE_CHANGED)
end

function ClientBossRushDungeon:onLevelGradeChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_LEVEL_GRADE_CHANGED)
end

function ClientBossRushDungeon:onTeamerInfosChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_TEAM_INFO_CHANGED)
end

function ClientBossRushDungeon:onSelectBatBuffsChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_TEAM_BUFF_CHANGED)
end

function ClientBossRushDungeon:onOpenLevelIdChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_TEAM_LEVEL_ID_CHANGED)
end

function ClientBossRushDungeon:onResult(result)
	return
end

function ClientBossRushDungeon:RPC_SC_ChallengeResult(result, failReason)
	return
end

function ClientBossRushDungeon:onCurLevelTeamReviveCountChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.BOSS_RUSH_CUR_LEVEL_TEAM_REVIVE_COUNT_CHANGED)
end

return ClientBossRushDungeon
