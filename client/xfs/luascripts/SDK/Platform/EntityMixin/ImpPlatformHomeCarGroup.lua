-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformHomeCarGroup.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local M = {}
local EventConst = require("Common.Const.EventConst")
local PlatformHomeCarDecorationFilterService = require("SDK.Platform.PlatformHomeCarDecorationFilterService")

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

function M.fetchHomeOwnerPlayerInfoIfNeeded(uid, onFetched)
	if string.isNilOrEmpty(uid) or M.getHomeOwnerPlayerInfo(uid) ~= nil or not pg.game.chat or type(pg.game.chat.getPlayerInfoFromServer) ~= "function" then
		return
	end

	pg.game.chat:getPlayerInfoFromServer(uid, nil, function(playerInfo)
		if playerInfo then
			onFetched(playerInfo)
		end
	end)
end

function M.shouldShowHomeCarGroupDecoration(group)
	if string.isNilOrEmpty(group.playerUID) or PlatformHomeCarDecorationFilterService:isLocalPlayer(group.playerUID, nil, nil) then
		return true
	end

	return PlatformHomeCarDecorationFilterService:shouldShowHomeCarDecoration(M.getHomeOwnerPlayerInfo(group.playerUID), {
		isSelf = false,
		uid = group.playerUID
	})
end

function M.refreshHomeCarShadows()
	local homeCar = pg.game.homeCar

	if homeCar and homeCar.refreshShadows then
		homeCar:refreshShadows()
	end
end

function M.unregisterGroupListeners(group)
	local listeners = rawget(group, "_platformHomeCarDecorationRefreshListeners")

	if not listeners then
		return
	end

	local emitter = M.getEventEmitter()

	if emitter and emitter.removeEventListener then
		for eventName, listener in pairs(listeners) do
			emitter:removeEventListener(eventName, listener)
		end
	end

	rawset(group, "_platformHomeCarDecorationRefreshListeners", nil)
end

function M.registerGroupListeners(group)
	local emitter = M.getEventEmitter()

	if not emitter or not emitter.addEventListener then
		return
	end

	M.unregisterGroupListeners(group)

	local listeners = {}

	for _, eventName in ipairs(M.RefreshEvents) do
		listeners[eventName] = function()
			M.applyHomeCarGroupDecorationVisibility(group)
		end

		emitter:addEventListener(eventName, listeners[eventName])
	end

	rawset(group, "_platformHomeCarDecorationRefreshListeners", listeners)
end

function M.destroyGroupOrnamentById(group, ornamentId)
	local homeEntity = group.ornamentEntities and group.ornamentEntities[ornamentId]

	if homeEntity then
		group:destroyHomeCarEntity(homeEntity)

		group.ornamentEntities[ornamentId] = nil

		return true
	end

	return false
end

function M.destroyGroupOrnaments(group)
	if not group.ornamentEntities then
		return false
	end

	local destroyed = false

	for ornamentId, _ in pairs(group.ornamentEntities) do
		if M.destroyGroupOrnamentById(group, ornamentId) then
			destroyed = true
		end
	end

	return destroyed
end

function M.applyHomeCarGroupDecorationVisibility(group)
	local ornamentData = rawget(group, "platformHomeCarOrnamentData")

	if not ornamentData then
		return
	end

	if not M.shouldShowHomeCarGroupDecoration(group) then
		if M.destroyGroupOrnaments(group) then
			M.refreshHomeCarShadows()
		end

		return
	end

	local ornamentSource = rawget(group, "platformHomeCarOrnamentSource")
	local created = false

	for ornamentId in pairs(ornamentData) do
		local ornamentInfo = ornamentSource and ornamentSource[ornamentId]

		if ornamentInfo and not group.ornamentEntities[ornamentId] and group:createHomeCarEntity(ornamentId, ornamentInfo) then
			created = true
		end
	end

	if created then
		M.refreshHomeCarShadows()
	end
end

function M.onCreateHomeCarEntities(group, ornamentData)
	rawset(group, "platformHomeCarOrnamentSource", ornamentData)

	local idSet = {}

	for k in pairs(ornamentData or EMPTY_TABLE) do
		idSet[k] = true
	end

	rawset(group, "platformHomeCarOrnamentData", idSet)
	M.registerGroupListeners(group)
	M.fetchHomeOwnerPlayerInfoIfNeeded(group.playerUID, function(_)
		if rawget(group, "platformHomeCarOrnamentData") then
			M.applyHomeCarGroupDecorationVisibility(group)
		end
	end)

	local changed = M.destroyGroupOrnaments(group)

	if not M.shouldShowHomeCarGroupDecoration(group) then
		if changed then
			M.refreshHomeCarShadows()
		end

		return true
	end

	for ornamentId, ornamentInfo in pairs(ornamentData or EMPTY_TABLE) do
		if group:createHomeCarEntity(ornamentId, ornamentInfo) then
			changed = true
		end
	end

	if changed then
		M.refreshHomeCarShadows()
	end

	return true
end

function M.onCreateHomeCarEntity(group, ornamentId, ornamentInfo)
	local idSet = rawget(group, "platformHomeCarOrnamentData")

	if idSet then
		idSet[ornamentId] = true
	end

	if not M.shouldShowHomeCarGroupDecoration(group) then
		if M.destroyGroupOrnamentById(group, ornamentId) then
			M.refreshHomeCarShadows()
		end

		return true, nil
	end

	return false, nil
end

function M.onUpdateHomeCarEntity(group, ornamentId, ornamentInfo)
	local idSet = rawget(group, "platformHomeCarOrnamentData")

	if idSet then
		idSet[ornamentId] = true
	end

	if not M.shouldShowHomeCarGroupDecoration(group) then
		if M.destroyGroupOrnamentById(group, ornamentId) then
			M.refreshHomeCarShadows()
		end

		return true
	end

	if not group.ornamentEntities[ornamentId] then
		if group:createHomeCarEntity(ornamentId, ornamentInfo) then
			M.refreshHomeCarShadows()
		end

		return true
	end

	return false
end

function M:createHomeCarEntities(ornamentData)
	return M.onCreateHomeCarEntities(self, ornamentData)
end

function M:createHomeCarEntity(ornamentId, ornamentInfo)
	return M.onCreateHomeCarEntity(self, ornamentId, ornamentInfo)
end

function M:updateHomeCarEntity(ornamentId, ornamentInfo)
	return M.onUpdateHomeCarEntity(self, ornamentId, ornamentInfo)
end

function M:destroy()
	M.unregisterGroupListeners(self)
end

return M
