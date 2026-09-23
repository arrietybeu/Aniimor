-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCatchRogueDungeon.lua

local Class = require("Core.Framework.Class")
local DungeonConst = require("Common.Const.DungeonConst")
local MessageName = require("Const.MessageName")
local ClientPveDungeon = require("Entities.SpaceEntities.ClientPveDungeon")
local ClientCatchRogueDungeon = Class.Class("ClientCatchRogueDungeon", ClientPveDungeon)

function ClientCatchRogueDungeon:init(dict)
	ClientCatchRogueDungeon.super.init(self, dict)

	if self.status == DungeonConst.STATUS.PLAYING then
		pg.global.ui.tips:hideCountDown("CatchRogue")

		local remainTime = self:getStateRemainTime()

		pg.global.ui.tips:showCountDown(remainTime, "CatchRogue")
	end

	return true
end

function ClientCatchRogueDungeon:onResult(result)
	self.logger:debug("catchRogue onResult", result)

	if result and result.result then
		pg.global.ui.tips:showTextTip(pg.getGameString("SUCCEED"))
	end
end

function ClientCatchRogueDungeon:onEndTsChange(oldV, newV)
	ClientCatchRogueDungeon.super.onEndTsChange(self, oldV, newV)

	if newV <= 0 then
		pg.global.ui.tips:hideCountDown("CatchRogue")
	elseif self.status == DungeonConst.STATUS.PLAYING then
		local remainTime = self:getStateRemainTime()

		pg.global.ui.tips:hideCountDown("CatchRogue")
		pg.global.ui.tips:showCountDown(remainTime, "CatchRogue")
	end
end

function ClientCatchRogueDungeon:RPC_SC_ChallengeResult(result, failReason)
	self.logger:debug("catchRogue RPC_SC_ChallengeResult", result, failReason)

	if result then
		pg.global.ui.tips:showA1Tips({
			id = "TowerResultWin",
			showText = pg.getGameString("ROGUE_BATTLE_SUCCESS")
		})
		pg.game.audio:playEvent("SFX_UI_Rouge_ChallengeSuccessful")
	end
end

function ClientCatchRogueDungeon:onStatusPlaying(params)
	ClientCatchRogueDungeon.super.onStatusPlaying(self, params)

	local remainTime = self:getStateRemainTime()

	pg.global.ui.tips:showCountDown(remainTime, "CatchRogue")
	facade:SendMessageCommand(MessageName.ROGUE_START_BATTLE)
end

function ClientCatchRogueDungeon:onStatusClosed(params)
	ClientCatchRogueDungeon.super.onStatusClosed(self, params)
	pg.global.ui.tips:hideCountDown("CatchRogue")
end

return ClientCatchRogueDungeon
