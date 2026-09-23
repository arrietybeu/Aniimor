-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerPause\\TowerPauseCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerPauseCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerPauseCtrl = Class.LightClass("TowerPauseCtrl", UICtrl)
local ClientUtils = require("Utils.ClientUtils")
local RoguelikeData = require("Data.roguelike_data")
local DungeonConst = require("Common.Const.DungeonConst")
local UIConst = require("Const.UIConst")

TowerPauseCtrl.messages = {}

function TowerPauseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local levelCfg = RoguelikeData[pg.me.curRogueLayer]
	local canRetry = levelCfg and levelCfg.canRestart == 1

	self.view.btnRetryUButton:SetActive(canRetry and pg.me.curRogueLayerState == DungeonConst.STATUS.PLAYING)
end

function TowerPauseCtrl:addListener()
	function self.view.btnContinueUButton.luaClick()
		self:close()
	end

	function self.view.btnRetryUButton.luaClick()
		self:close()
		self:clearRogueInfo()

		if pg.me.curRogueLayer and pg.me.curRogueLayer > 0 then
			pg.me:startRogue(pg.me.curRogueLayer)
		end
	end

	function self.view.btnSuspendUButton.luaClick()
		self:close()
		self:clearRogueInfo()
		ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
			pg.me:serverMsg("RPC_CS_QuitSpace")
		end)
	end

	function self.view.btnSettlementUButton.luaClick()
		self:close()
		self:clearRogueInfo()
		pg.global.ui:open(UIConst.UI_ID_TOWER_SETTLEMENT, {
			confirmCb = function()
				pg.me:serverMsg("RPC_CS_QuitSpace")
			end
		})
	end
end

function TowerPauseCtrl:clearRogueInfo()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_ROG_BUFF_SELECT) then
		pg.global.ui:close(UIConst.UI_ID_ROG_BUFF_SELECT)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_DEFEAT) then
		pg.global.ui:close(UIConst.UI_ID_TOWER_DEFEAT)
	end

	ClientUtils.hideBattleUICountDown()
end

function TowerPauseCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerPauseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerPauseCtrl:onShow()
	return
end

function TowerPauseCtrl:onHide()
	return
end

return TowerPauseCtrl
