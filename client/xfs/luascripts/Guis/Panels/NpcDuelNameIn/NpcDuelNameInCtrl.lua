-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelNameIn\\NpcDuelNameInCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local NpcDuelNameInCtrl = Class.LightClass("NpcDuelNameInCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local NpcDuelData = require("Data.npc_duel_data")

function NpcDuelNameInCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.curNpcDuelId = pg.me.curNpcDuelId
	self.curNpcDuelVariantId = pg.me.curNpcDuelVariantId

	if self.curNpcDuelId == 0 or self.curNpcDuelVariantId == 0 then
		return
	end

	ClientTextUtils.setText(self.view.textNameUBaseText, pg.me:getCurNpcDuelBotName())
	ClientTextUtils.setText(self.view.textTtitleUBaseText, pg.getLocalizationText(self:getNpcTitle()))
end

function NpcDuelNameInCtrl:getNpcTitle()
	local npcDuelData = NpcDuelData[self.curNpcDuelId] and NpcDuelData[self.curNpcDuelId][self.curNpcDuelVariantId]

	return npcDuelData and npcDuelData.npcTitle
end

return NpcDuelNameInCtrl
