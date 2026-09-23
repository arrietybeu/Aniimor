-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\PhotoEntityTypeIdentification.lua

local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local Bitset = require("Common.Bitset")
local bor = bit.bor
local lshift = Bitset.lshift
local PhotoEntityTypeIdentification = {}

PhotoEntityTypeIdentification.EntityType = {
	OTHER_PLAYER = 2,
	SELF_PLAYER = 1,
	WILD_MONSTER = 6,
	NPC = 5,
	OTHER_PET = 4,
	SELF_PET = 3
}

function PhotoEntityTypeIdentification.identifyEntityType(entity)
	if not entity or not entity.templateId then
		return nil
	end

	if Utils.isPlayer(entity) then
		if entity.isMainPlayer then
			return PhotoEntityTypeIdentification.EntityType.SELF_PLAYER
		else
			return PhotoEntityTypeIdentification.EntityType.OTHER_PLAYER
		end
	elseif Utils.isPet(entity) then
		local master = Utils.getMasterPlayer(entity)

		if master and master.isMainPlayer then
			return PhotoEntityTypeIdentification.EntityType.SELF_PET
		else
			return PhotoEntityTypeIdentification.EntityType.OTHER_PET
		end
	elseif Utils.isNpc(entity) then
		return PhotoEntityTypeIdentification.EntityType.NPC
	elseif Utils.isPuppet(entity) then
		return PhotoEntityTypeIdentification.EntityType.WILD_MONSTER
	end

	return nil
end

function PhotoEntityTypeIdentification.isEntityInPhotoViewport(entity)
	if not entity.getPosition or not entity.getCameraHeightInfo or not entity.getConfigData then
		return false
	end

	local entPos = entity:getPosition()
	local nearHeight, _ = entity:getCameraHeightInfo()
	local modelHeight = entity:getConfigData().modelHeight or nearHeight
	local height = (nearHeight + modelHeight) / 2
	local inMasterThreshold = 0.02
	local adjustPos = Vector3(entPos.x, entPos.y + height, entPos.z)
	local res1 = pg.game.camera.photoCameraMode.cameraMode:GetTargetViewportPos(entPos)
	local res2 = pg.game.camera.photoCameraMode.cameraMode:GetTargetViewportPos(adjustPos)
	local res1InViewPort = res1.x > 0 and res1.x < 1 and res1.y > 0 and res1.y < 1 and res1.z > 0
	local res2InViewPort = res2.x > 0 and res2.x < 1 and res2.y > 0 and res2.y < 1 and res2.z > 0
	local isAllScreen = res1.y < 0 and res2.y > 1 and (res1.x > 0 and res1.x < 1 or res2.x > 0 and res2.x < 1) and res1.z > 0 and res2.z > 0

	if res1InViewPort or res2InViewPort or isAllScreen then
		local y1 = math.max(res1.y, 0)
		local y2 = math.min(res2.y, 1)

		return inMasterThreshold < y2 - y1
	end

	return false
end

function PhotoEntityTypeIdentification.isRayBlocked(entity, cameraPos)
	if not entity or not entity.getPosition or not entity.getCameraHeightInfo or not entity.getConfigData then
		return true
	end

	local camPos = cameraPos or pg.game.camera.photoCameraMode:getFollowPosition()

	if not camPos then
		return true
	end

	local entPos = entity:getPosition()
	local nearHeight, _ = entity:getCameraHeightInfo()
	local modelHeight = entity:getConfigData().modelHeight or nearHeight
	local height = (nearHeight + modelHeight) / 2
	local checkPos = Vector3(entPos.x, entPos.y + height / 2, entPos.z)
	local distance = Vector3.Distance(camPos, checkPos)
	local layerMask = PhotoEntityTypeIdentification.blockLayerMask or bor(lshift(1, ClientConst.LayerDefine.LAYER_GROUND), lshift(1, ClientConst.LayerDefine.LAYER_WALL), lshift(1, ClientConst.LayerDefine.LAYER_DEFAULT))

	PhotoEntityTypeIdentification.blockLayerMask = layerMask

	return pgUtils.IsBlocked(camPos, checkPos, distance, layerMask)
end

function PhotoEntityTypeIdentification.isEntityVisibleForPhoto(entity)
	if not entity or not entity.active or not entity.visible then
		return false
	end

	if not PhotoEntityTypeIdentification.isEntityInPhotoViewport(entity) then
		return false
	end

	if PhotoEntityTypeIdentification.isRayBlocked(entity) then
		return false
	end

	return true
end

function PhotoEntityTypeIdentification.getIdentifiedTypesInViewport()
	local typeNumbers = {}
	local typeExists = {}
	local allEntities = pg.getEntities()

	for entityId, entity in pairs(allEntities) do
		local entityTypeNum = PhotoEntityTypeIdentification.identifyEntityType(entity)

		if entityTypeNum and not typeExists[entityTypeNum] and PhotoEntityTypeIdentification.isEntityVisibleForPhoto(entity) then
			table.insert(typeNumbers, entityTypeNum)

			typeExists[entityTypeNum] = true
		end
	end

	table.sort(typeNumbers)

	return typeNumbers
end

return PhotoEntityTypeIdentification
