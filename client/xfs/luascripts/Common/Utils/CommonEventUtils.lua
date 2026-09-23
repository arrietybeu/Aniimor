-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\CommonEventUtils.lua

local CommonEventUtils = {}
local Utils = require("Common.Utils.Utils")
local CommonEventConst = require("Common.Const.CommonEventConst")
local ServerUtils = require("GameServer.ServerUtils")

function CommonEventUtils.checkTeleportSuccess(player, eventData, extraParam, subEventIndex, subEventList)
	if not eventData then
		return subEventIndex == nil
	end

	if not player.space then
		return false
	end

	subEventList = subEventList or Utils.decodeFromStr(eventData.subEvents)

	if subEventList == nil then
		return subEventIndex == nil
	end

	local subEvent = subEventList[subEventIndex or eventData.currentIndex]

	if not subEvent or not subEvent.params then
		return subEventIndex == nil
	end

	local sceneId = subEvent.params[1]
	local portalId = subEvent.params[2]

	if sceneId ~= player.sceneId then
		return false
	end

	local curPos = player:getPosition()
	local valid, position, yaw = ServerUtils.getPortalBornInfo(curPos, player.space, portalId)

	if not valid then
		player.logger:error("%s event_teleportScenePosition failed, portalId: %s is invalid", player:repr(), portalId)

		return subEventIndex == nil
	end

	local distance = Vector3.Distance(player:getPosition(), position)

	if distance <= CommonEventConst.TeleportMaxDeltaRadius then
		return true
	end

	return false
end

CommonEventUtils.CheckEventSuccessFunc = {
	teleportScenePosition = CommonEventUtils.checkTeleportSuccess
}

return CommonEventUtils
