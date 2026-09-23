-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPveDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local ClientDungeon = require("Entities.SpaceEntities.ClientDungeon")
local ClientPveDungeon = Class.Class("ClientPveDungeon", ClientDungeon)

function ClientPveDungeon:ctor(entityId)
	ClientPveDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPveDungeon create")
	end
end

function ClientPveDungeon:init(dict)
	ClientPveDungeon.super.init(self, dict)

	return true
end

function ClientPveDungeon:onResult(result)
	if result and result.result then
		pg.global.ui.tips:showTextTip(pg.getGameString("SUCCEED"))
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("FAILED"))
	end
end

function ClientPveDungeon:RPC_SC_ShowStage(stage, totalStage)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_ShowStage", stage)
	end

	pg.global.ui.tips:showA1Tips({
		id = "TowerResultWave",
		params = {
			totalStage = totalStage,
			stage = stage
		}
	})
	pg.game.audio:playEvent("SFX_UI_Rouge_WaveReminder")
end

function ClientPveDungeon:RPC_SC_ConfirmContinueDungeon(confirmPlayers)
	self.logger:debug("RPC_SC_ConfirmContinueDungeon", confirmPlayers)
	facade:sendMsgToUI(MessageName.TEAM_CONFIRM_CONTINUE_DUNGEON, {
		confirmPlayers = confirmPlayers
	})
end

return ClientPveDungeon
