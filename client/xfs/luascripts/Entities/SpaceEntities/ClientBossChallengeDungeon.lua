-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientBossChallengeDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientDungeon = require("Entities.SpaceEntities.ClientDungeon")
local ClientBossChallengeDungeon = Class.Class("ClientBossChallengeDungeon", ClientDungeon)

function ClientBossChallengeDungeon:ctor(entityId)
	ClientBossChallengeDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientBossChallengeDungeon create")
	end
end

function ClientBossChallengeDungeon:init(dict)
	ClientBossChallengeDungeon.super.init(self, dict)

	return true
end

function ClientBossChallengeDungeon:onResult(result)
	if result and result.result then
		-- block empty
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("FAILED"))
	end
end

return ClientBossChallengeDungeon
