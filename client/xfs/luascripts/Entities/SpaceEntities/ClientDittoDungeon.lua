-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientDittoDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientDungeon = require("Entities.SpaceEntities.ClientDungeon")
local DITTO_CAM_EFFECT_KEY = "Eff_Env_SceneObject_MorphlingStatue_KeyItem_Cam"
local UIConst = require("Const.UIConst")
local ClientDittoDungeon = Class.Class("ClientDittoDungeon", ClientDungeon)

function ClientDittoDungeon:ctor(entityId)
	ClientDittoDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientDittoDungeon create")
	end
end

function ClientDittoDungeon:init(dict)
	ClientDittoDungeon.super.init(self, dict)
	pg.global.ui:open(UIConst.UI_ID_Morphling, {
		state = 0
	})

	return true
end

function ClientDittoDungeon:onResult(result)
	if result and result.result then
		pg.global.ui.tips:showTextTip(pg.getGameString("SUCCEED"))
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("FAILED"))
	end
end

function ClientDittoDungeon:destroy()
	pg.global.ui:close(UIConst.UI_ID_Morphling)
	ClientDittoDungeon.super.destroy(self)
end

return ClientDittoDungeon
