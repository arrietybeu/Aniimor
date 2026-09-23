-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerBadgeComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("ClientPlayerBadgeComponent")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local Const = require("Common.Const.Const")
local ClientPlayerBadgeComponent = class.Component("ClientPlayerBadgeComponent")

function ClientPlayerBadgeComponent:onBadgeState_changed(ov, nv, id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("玩家徽章状态变化 %s %s->%s", id, ov, nv)
	end

	BadgeUtils.onServerDataChanged(id, ov, nv)
	facade:sendMsgToUI(MessageName.PLAYER_BADGE_STATE_CHANGED, {
		oldV = ov,
		newV = nv,
		badgeId = id
	})
end

function ClientPlayerBadgeComponent:onBadgeState_add(id, state)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("玩家徽章新增 %s %s", id, state)
	end

	BadgeUtils.onServerDataAdd(id, state)
end

function ClientPlayerBadgeComponent:on_badgeShowMap_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_badgeShowMap_changed")
	end

	if self.isMainPlayer then
		local hasEquip = false
		local hasUnload = false
		local hasExchange = false

		for i = 1, Const.BADGE_SHOW_COUNT do
			local oldBadgeId = ov and ov[i] or 0
			local newBadgeId = nv and nv[i] or 0

			if oldBadgeId ~= newBadgeId then
				if oldBadgeId == 0 and newBadgeId > 0 then
					hasEquip = true
				elseif oldBadgeId > 0 and newBadgeId == 0 then
					hasUnload = true
				elseif oldBadgeId > 0 and newBadgeId > 0 then
					hasExchange = true
				end
			end
		end

		local tip = ""

		if hasExchange or hasEquip and hasUnload then
			tip = pg.getGameString("EXCHANGE_SUCCESS")
		elseif hasEquip then
			tip = pg.getGameString("EQUIP_SUCCESS")
		elseif hasUnload then
			tip = pg.getGameString("UNLOAD_SUCCESS")
		end

		pg.global.ui.tips:showTextTip(tip)
	end

	facade:SendMessageCommand(MessageName.PLAYER_BADGE_SHOW_MAP_CHANGED, {
		oldV = ov,
		newV = nv
	})
end

return ClientPlayerBadgeComponent
