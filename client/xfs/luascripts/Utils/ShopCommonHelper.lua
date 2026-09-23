-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ShopCommonHelper.lua

local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ShopCommonHelper = {}

function ShopCommonHelper.isConfigAvailableInArea(config, areaNo)
	if not config or not config.areaNo then
		return true
	end

	if not Utils.isTable(config.areaNo) then
		return false
	end

	local currentAreaNo = areaNo or Utils.getServerArea()

	for _, availableAreaNo in ipairs(config.areaNo) do
		if availableAreaNo == currentAreaNo then
			return true
		end
	end

	return false
end

function ShopCommonHelper.isHitSceneLimit(commodityData, curSceneId)
	if commodityData.limitType ~= Const.LIMIT_SCENE then
		return false
	end

	local mainSceneId = Utils.getPhaseMainSceneId(curSceneId)

	if Utils.isTable(commodityData.limitParam) then
		for _, sid in ipairs(commodityData.limitParam) do
			if sid == curSceneId or mainSceneId and sid == mainSceneId then
				return true
			end
		end
	end

	return false
end

function ShopCommonHelper.getCurLimitShopSceneId()
	local player = pg.me
	local space = player and player.space

	if not space then
		return 0
	end

	if space:isGrabEgg() then
		local dungeonSceneId = player:getDungeonSceneId()

		if dungeonSceneId and dungeonSceneId > 0 then
			return dungeonSceneId
		end
	end

	return space.sceneId or 0
end

return ShopCommonHelper
