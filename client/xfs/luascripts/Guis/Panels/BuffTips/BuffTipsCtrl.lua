-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BuffTips\\BuffTipsCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local AbilityConst = require("Common.Const.AbilityConst")
local UIConst = require("Const.UIConst")
local BuffTipsCtrl = Class.LightClass("BuffTipsCtrl", UICtrl)
local pg = pg
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils

BuffTipsCtrl.messages = {
	[MessageName.ON_BUFF_ADD] = {
		"onBuffAdd",
		false
	}
}

function BuffTipsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BuffTipsCtrl:addListener()
	return
end

function BuffTipsCtrl:onShow()
	if self.petInfo then
		self:showTips(unpack(self.petInfo))

		self.petInfo = nil
	end

	if self.playerInfo then
		self:showTips(unpack(self.playerInfo))

		self.playerInfo = nil
	end
end

function BuffTipsCtrl:onBuffAdd(body)
	local entId = body.entId
	local buffInsId = body.buffInsId
	local ent = pg.getEntity(entId)

	if not ent then
		return
	end

	if (Utils.isPlayer(ent) or Utils.isPet(ent)) and ent.authority == Const.AUTHORITY_MASTER then
		if Utils.isPlayer(ent) and ent:isControllingPet() then
			return
		end

		local buff = ent.actorBuff:findBuff(buffInsId)

		if buff and buff.buffTemplate.tips and buff.buffTemplate.tags and buff.buffData.destroyReason ~= AbilityConst.BUFF_DESTROY_REASON_INHERIT then
			if lume.find(buff.buffTemplate.tags, AbilityConst.BUFF_TAG_POSITIVE) then
				self:showTips(Utils.isPet(ent), entId, buff.buffTemplate.tips, false)
			elseif lume.find(buff.buffTemplate.tags, AbilityConst.BUFF_TAG_NEGATIVE) then
				self:showTips(Utils.isPet(ent), entId, buff.buffTemplate.tips, true)
			end
		end
	end
end

function BuffTipsCtrl:showTips(isPet, entId, tips, isDebuff)
	if not self.view then
		if isPet then
			self.petInfo = {
				isPet,
				entId,
				tips,
				isDebuff
			}
		else
			self.playerInfo = {
				isPet,
				entId,
				tips,
				isDebuff
			}
		end

		pg.global.ui:open(UIConst.UI_ID_BUFF_TIPS)

		return
	end

	if isDebuff == false then
		self.view:showTips(isPet, entId, tips, false)
	else
		self.view:showTips(isPet, entId, tips, true)
	end
end

return BuffTipsCtrl
