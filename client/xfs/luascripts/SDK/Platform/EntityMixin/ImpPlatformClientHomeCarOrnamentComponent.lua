-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientHomeCarOrnamentComponent.lua

local M = {}
local ClientConst = require("Const.ClientConst")
local EventConst = require("Common.Const.EventConst")
local PlatformHomeCarDecorationFilterService = require("SDK.Platform.PlatformHomeCarDecorationFilterService")

M.UGC_VISIBLE_KEY = 1001
M.RefreshEvents = {
	EventConst.PLATFORM_UGC_POLICY_CHANGED,
	EventConst.PLATFORM_BLOCK_LIST_CHANGED,
	EventConst.PLATFORM_FRIEND_LIST_CHANGED
}

function M.getEventEmitter()
	return pg.global.eventEmitter
end

function M.getHomeOwnerPlayerInfo(uid)
	if string.isNilOrEmpty(uid) or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(uid)
end

function M.shouldShowHomeCarDecorationByUid(uid, isSelf)
	if string.isNilOrEmpty(uid) or PlatformHomeCarDecorationFilterService:isLocalPlayer(uid, nil, {
		isSelf = isSelf == true
	}) then
		return true
	end

	return PlatformHomeCarDecorationFilterService:shouldShowHomeCarDecoration(M.getHomeOwnerPlayerInfo(uid), {
		uid = uid,
		isSelf = isSelf == true
	})
end

function M.setDecorationVisible(ornament, visible)
	if ornament.setModelVisible then
		ornament:setModelVisible(M.UGC_VISIBLE_KEY, visible)
	end

	if ornament.setCollideEnable then
		ornament:setCollideEnable(M.UGC_VISIBLE_KEY, visible)
	end

	if ornament.tempDisableRendererBatch then
		ornament:tempDisableRendererBatch(ClientConst.DisableBatchReason.UGC_HOME_CAR_DECORATION, visible ~= true)
	end

	if ornament.refreshRendererBatch then
		ornament:refreshRendererBatch()
	elseif ornament.flushBatchRenderer then
		ornament:flushBatchRenderer()
	end
end

function M.applyHomeCarDecorationVisibility(ornament)
	local visible = M.shouldShowHomeCarDecorationByUid(ornament.playerUID, ornament.isSelfHomeCar and ornament:isSelfHomeCar() == true)

	M.setDecorationVisible(ornament, visible)

	return visible
end

function M.unregisterOrnamentListeners(ornament)
	local listeners = rawget(ornament, "_platformHomeCarDecorationRefreshListeners")

	if not listeners then
		return
	end

	local emitter = M.getEventEmitter()

	if emitter and emitter.removeEventListener then
		for eventName, listener in pairs(listeners) do
			emitter:removeEventListener(eventName, listener)
		end
	end

	rawset(ornament, "_platformHomeCarDecorationRefreshListeners", nil)
end

function M.registerOrnamentListeners(ornament)
	if ornament.isSelfHomeCar and ornament:isSelfHomeCar() == true then
		return
	end

	local emitter = M.getEventEmitter()

	if not emitter or not emitter.addEventListener then
		return
	end

	M.unregisterOrnamentListeners(ornament)

	local listeners = {}

	for _, eventName in ipairs(M.RefreshEvents) do
		listeners[eventName] = function()
			M.applyHomeCarDecorationVisibility(ornament)
		end

		emitter:addEventListener(eventName, listeners[eventName])
	end

	rawset(ornament, "_platformHomeCarDecorationRefreshListeners", listeners)
end

function M:start()
	M.applyHomeCarDecorationVisibility(self)
	M.registerOrnamentListeners(self)
end

function M:destroy()
	M.unregisterOrnamentListeners(self)
end

return M
