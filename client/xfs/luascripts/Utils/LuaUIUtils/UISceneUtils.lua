-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UISceneUtils.lua

local Mathf = require("Common.Math.Mathf")
local _abs = Mathf.Abs
local SceneData = require("Data.scene_data")
local CountryAreaData = require("Data.country_area_data")
local MessageName = require("Const.MessageName")

return function(LuaUIUtils)
	function LuaUIUtils.isPointInPolyTest(mapPosX, mapPosY, mapAreaPoints)
		local oldVal = LuaUIUtils.isPointInPolyOld(mapPosX, mapPosY, mapAreaPoints)
		local newVal = LuaUIUtils.isPointInPoly(mapPosX, mapPosY, mapAreaPoints)

		if oldVal ~= newVal then
			error("function LuaUIUtils.isPointInPoly(mapPosX, mapPosY, mapAreaPoints)" .. string.format("%s %s", mapPosX, mapPosY))
		end

		return newVal
	end

	function LuaUIUtils.isPointInPoly(mapPosX, mapPosY, mapAreaPoints)
		local iCount = #mapAreaPoints

		if iCount < 3 then
			return false
		end

		local iSum = 0
		local dLon1, dLon2, dLat1, dLat2, dLon, points

		points = mapAreaPoints[iCount]
		dLon1 = points[1]
		dLat1 = points[2]
		points = mapAreaPoints[1]
		dLon2 = points[1]
		dLat2 = points[2]

		if (dLat1 <= mapPosY and mapPosY < dLat2 or dLat2 <= mapPosY and mapPosY < dLat1) and _abs(dLat1 - dLat2) > 0 then
			dLon = dLon1 - (dLon1 - dLon2) * (dLat1 - mapPosY) / (dLat1 - dLat2)

			if dLon < mapPosX then
				iSum = iSum + 1
			end
		end

		for iIndex = 1, iCount - 1 do
			dLon1 = dLon2
			dLat1 = dLat2
			points = mapAreaPoints[iIndex + 1]
			dLon2 = points[1]
			dLat2 = points[2]

			if (dLat1 <= mapPosY and mapPosY < dLat2 or dLat2 <= mapPosY and mapPosY < dLat1) and _abs(dLat1 - dLat2) > 0 then
				dLon = dLon1 - (dLon1 - dLon2) * (dLat1 - mapPosY) / (dLat1 - dLat2)

				if dLon < mapPosX then
					iSum = iSum + 1
				end
			end
		end

		return iSum % 2 ~= 0
	end

	function LuaUIUtils.isPointInPoly2(mapPosX, mapPosY, points)
		local aabb = points.aabb

		if mapPosX < aabb[1] or mapPosX > aabb[2] or mapPosY < aabb[3] or mapPosY > aabb[4] then
			return false
		end

		local iCount = #points

		if iCount < 6 then
			return false
		end

		local inside = false
		local x1 = points[iCount - 1]
		local y1 = points[iCount]

		for i = 1, iCount, 2 do
			local x2 = points[i]
			local y2 = points[i + 1]

			if mapPosY < y1 ~= (mapPosY < y2) and mapPosX < (x2 - x1) * (mapPosY - y1) / (y2 - y1) + x1 then
				inside = not inside
			end

			x1, y1 = x2, y2
		end

		return inside
	end

	function LuaUIUtils.isPointInPolyOld(mapPosX, mapPosY, mapAreaPoints)
		local iSum, iCount
		local dLon1 = 0
		local dLon2 = 0
		local dLat1 = 0
		local dLat2 = 0
		local dLon

		if #mapAreaPoints < 3 then
			return false
		end

		iSum = 0
		iCount = #mapAreaPoints

		for iIndex = 1, #mapAreaPoints do
			if iIndex == iCount then
				dLon1 = mapAreaPoints[iIndex][1]
				dLat1 = mapAreaPoints[iIndex][2]
				dLon2 = mapAreaPoints[1][1]
				dLat2 = mapAreaPoints[1][2]
			else
				dLon1 = mapAreaPoints[iIndex][1]
				dLat1 = mapAreaPoints[iIndex][2]
				dLon2 = mapAreaPoints[iIndex + 1][1]
				dLat2 = mapAreaPoints[iIndex + 1][2]
			end

			if (dLat1 <= mapPosY and mapPosY < dLat2 or dLat2 <= mapPosY and mapPosY < dLat1) and Mathf.Abs(dLat1 - dLat2) > 0 then
				dLon = dLon1 - (dLon1 - dLon2) * (dLat1 - mapPosY) / (dLat1 - dLat2)

				if dLon < mapPosX then
					iSum = iSum + 1
				end
			end
		end

		if iSum % 2 ~= 0 then
			return true
		end

		return false
	end

	function LuaUIUtils.getSceneIdByCountryId(countryId)
		return CountryAreaData[countryId].sceneId or 0
	end

	function LuaUIUtils.requestMapPuppetLevel(idInType, callback)
		if not idInType or not callback then
			return
		end

		local messageHandler

		function messageHandler(levelDict)
			local lvRange = levelDict and levelDict[idInType]

			if not lvRange or not lvRange[1] then
				return
			end

			local minLevel = lvRange[1]
			local maxLevel = lvRange[2]

			pcall(callback, minLevel, maxLevel, levelDict)
			pg.global.eventEmitter:removeEventListener(MessageName.MAP_PUPPET_LEVEL_UPDATE, messageHandler)
		end

		pg.global.eventEmitter:addEventListener(MessageName.MAP_PUPPET_LEVEL_UPDATE, messageHandler)
		pg.me:serverMsg("RPC_CS_ShowMapPuppetLevel", {
			idInType
		})
	end

	function LuaUIUtils.checkTeleportLimit(targetScene)
		if not targetScene then
			return false
		end

		local isTeleportLimit = pg.me.space and pg.me.space.sceneId and SceneData[pg.me.space.sceneId].teleportLimit and SceneData[pg.me.space.sceneId].teleportLimit == 1

		if isTeleportLimit and targetScene ~= pg.me.space.sceneId then
			pg.global.showBubbleMessageById(2246)

			return true
		end

		return false
	end
end
