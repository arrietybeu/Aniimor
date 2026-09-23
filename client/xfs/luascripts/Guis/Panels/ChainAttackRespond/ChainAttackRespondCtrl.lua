-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChainAttackRespond\\ChainAttackRespondCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local NoticeDef = require("Common.NoticeDef")
local ChainAttackRespondCtrl = Class.LightClass("ChainAttackRespondCtrl", UICtrl)

function ChainAttackRespondCtrl:showChainAttackRespondBtn(visible, proposerUid)
	if visible then
		self:show()
		self:renderChainAttackRespondBtn(proposerUid)
	else
		self:hide()
	end
end

function ChainAttackRespondCtrl:renderChainAttackRespondBtn(proposerUid)
	local progressUProgress = self.view.progressUProgress
	local clickBtn = self.view.clickBtn

	function clickBtn.luaClick()
		if pg.me.chainAttackInfo.curResponderId == proposerUid then
			local curPet = pg.me:getCurPetEntity()

			if not curPet or not curPet:canCastUltimate() then
				pg.global.showBubbleMessageById(NoticeDef.RESPOND_CHAIN_ATTACK_FAILED)
			else
				pg.me:serverMsgNoGC("RPC_CS_RespondPlayerTeamChainChance", proposerUid)
			end
		end

		self:hide()
	end

	local duration = SysConfigData.chainAttackRespondDuration or 5

	progressUProgress.value = 1

	progressUProgress:ProgressToValue(0, function()
		self:hide()
	end, duration)
end

return ChainAttackRespondCtrl
