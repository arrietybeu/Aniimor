-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\TopLogoPvp2Helper.lua

local Utils = require("Common.Utils.Utils")
local LuaTopLogoUtils = require("Utils.LuaTopLogoUtils")
local TopLogoPvp2Helper = {}

function TopLogoPvp2Helper.isPvp2EnemyTarget(entity)
	return entity ~= nil and entity.isPvp2EnemyRevealTarget ~= nil and entity:isPvp2EnemyRevealTarget()
end

function TopLogoPvp2Helper.canShowPvp2EnemyTarget(entity)
	return entity ~= nil and entity.canShowPvp2RevealTarget ~= nil and entity:canShowPvp2RevealTarget()
end

function TopLogoPvp2Helper.isPvp2EnemyPlayer(entity)
	return Utils.isPlayer(entity) and TopLogoPvp2Helper.isPvp2EnemyTarget(entity)
end

function TopLogoPvp2Helper.canShowPvp2EnemyPlayer(entity)
	return Utils.isPlayer(entity) and TopLogoPvp2Helper.canShowPvp2EnemyTarget(entity)
end

function TopLogoPvp2Helper.isPvp2FriendlyTarget(entity)
	if not entity or not LuaTopLogoUtils.isPvp2TopLogoScene() then
		return false
	end

	if Utils.isMainPlayer(entity) then
		return false
	end

	return entity._isPvp2FriendlyOwnedEntity == true
end

return TopLogoPvp2Helper
