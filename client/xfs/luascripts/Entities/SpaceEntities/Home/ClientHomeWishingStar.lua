-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeWishingStar.lua

local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local InteractionConst = require("Common.Const.InteractionConst")
local HomelandWishStarData = require("Common.Homeland.HomelandWishStarData")
local ClientConst = require("Const.ClientConst")
local HomelandConfigData = require("Data.homeland_config_data")
local ClientHomeEntity = require("Entities.SpaceEntities.Home.ClientHomeEntity")
local ClientHomeWishingStar = Class.Class("ClientHomeWishingStar", ClientHomeEntity)

ClientHomeWishingStar.COLLECT_INTERACTION_ID = 100014

function ClientHomeWishingStar:ctor(entityId)
	ClientHomeWishingStar.super.ctor(self, entityId)

	self.topLogoType = ClientConst.TopLogoType.HomeWishingStar
	self.overrideTopLogoEnterDistance = HomelandConfigData.facilityTopLogoEnterDistance or 10
end

function ClientHomeWishingStar:init(dict)
	ClientHomeWishingStar.super.init(self, dict)

	self.forbiddenTopLogo = false

	return true
end

function ClientHomeWishingStar:initInteraction()
	if not self.eModel then
		return
	end

	self.interactionListData = {
		{
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			actionPrototypeId = ClientHomeWishingStar.COLLECT_INTERACTION_ID,
			interactFunc = CallbackHandler(self, "collectWishStar")
		}
	}

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomeWishingStar:collectWishStar()
	local accepted, shouldRequestServer, reason = HomelandWishStarData.prepareCollect(self.space, self:getGlobalId())

	if not accepted then
		if reason ~= "pending" then
			pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"), 3)
		end

		return
	end

	if not shouldRequestServer then
		return
	end

	pg.me:requestCollectHomeVoucher(self.ornamentId, self:getGlobalId())
end

return ClientHomeWishingStar
