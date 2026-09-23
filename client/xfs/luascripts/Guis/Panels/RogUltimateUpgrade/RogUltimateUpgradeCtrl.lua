-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogUltimateUpgrade\\RogUltimateUpgradeCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RogueUtils = require("Utils.RogueUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RogUltimateUpgradeCtrl = Class.LightClass("RogUltimateUpgradeCtrl", UICtrl)

function RogUltimateUpgradeCtrl:onOpen(info)
	if not pg.me or not pg.me.space or not pg.me.space:isRogueEnv() then
		self:close()

		return
	end

	if info and info.buffs and #info.buffs >= 1 then
		self.view.btnConfirm.interactable = false
	end

	function self.view.btnConfirm.luaClick()
		pg.me.space:selectBuff({
			self.selected
		})
		self:close()
	end

	ClientTextUtils.setText(self.view.titleTipUBaseText, pg.getGameString("ROGUE_TRANSFORM_SKILL_TIPS"))
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getGameString("ROGUE_TRANSFORM_SKILL_TITLE"))

	self.view.listBuff.cancelSupport = false

	local extraInfo = {
		onBuffSelectChange = function(data)
			self.selected = data.buffId
			self.view.btnConfirm.interactable = true
		end
	}

	RogueUtils.renderBuffSelectList(self.view.listBuff, info.buffs, extraInfo)
end

function RogUltimateUpgradeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return RogUltimateUpgradeCtrl
