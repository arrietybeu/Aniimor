-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformPhotoCtrl.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")

M.bit = bit
M.bor = M.bit and M.bit.bor
M.lshift = M.bit and M.bit.lshift

function M.checkInViewportMaster(entPos, height)
	local inMasterThreshold = 0.02

	Vector3.enableCreateFromCache()

	local adjustPos = Vector3(entPos.x, entPos.y + height, entPos.z)
	local res1 = pg.game.camera.photoCameraMode.cameraMode:GetTargetViewportPos(entPos)
	local res2 = pg.game.camera.photoCameraMode.cameraMode:GetTargetViewportPos(adjustPos)
	local res1InViewPort = res1.x > 0 and res1.x < 1 and res1.y > 0 and res1.y < 1 and res1.z > 0
	local res2InViewPort = res2.x > 0 and res2.x < 1 and res2.y > 0 and res2.y < 1 and res2.z > 0
	local isAllScreen = res1.y < 0 and res2.y > 1 and res1.z > 0 and res2.z > 0
	local result = false

	if res1InViewPort or res2InViewPort or isAllScreen then
		local y1 = math.max(res1.y, 0)
		local y2 = math.min(res2.y, 1)

		result = inMasterThreshold < y2 - y1
	end

	Vector3.disableCreateFromCache()

	return result
end

function M.checkMainPlayerInViewport()
	if not pg.me or not pg.me.eModel or not pg.me.eModel:CheckPositionAgent() then
		return false
	end

	local entPos = pg.me:getPosition()

	if not entPos then
		return false
	end

	local nearHeight = 0

	if pg.me.getCameraHeightInfo then
		nearHeight = pg.me:getCameraHeightInfo() or 0
	end

	local configData = pg.me:getConfigData() or {}
	local modelHeight = configData.modelHeight or nearHeight
	local height = (nearHeight + modelHeight) / 2

	return M.checkInViewportMaster(entPos, height)
end

function M.isFriendPlayerUid(uid)
	if uid == nil or not pg or not pg.game or not pg.game.chat then
		return false
	end

	local friendships = pg.game.chat.friendships

	if type(friendships) ~= "table" then
		return false
	end

	local friendship = friendships[uid]

	if friendship == nil then
		friendship = friendships[tostring(uid)]
	end

	local numericUid = tonumber(uid)

	if friendship == nil and numericUid ~= nil then
		friendship = friendships[numericUid]
	end

	friendship = tonumber(friendship)

	return friendship ~= nil and friendship >= 0
end

function M.getFriendPlayerUidsInViewport()
	if not pg or not pg.game or not pg.game.camera or not pg.game.camera.photoCameraMode then
		return {}
	end

	if not M.bor or not M.lshift then
		return {}
	end

	local friendUidList = {}
	local friendPlayerUidMap = {}
	local layerMask = M.bor(M.lshift(1, ClientConst.LayerDefine.LAYER_GROUND), M.lshift(1, ClientConst.LayerDefine.LAYER_WALL), M.lshift(1, ClientConst.LayerDefine.LAYER_DEFAULT))
	local curCameraPos = pg.game.camera.photoCameraMode:getFollowPosition()
	local allEntitys = pg.getEntities() or {}

	for _, entity in pairs(allEntitys) do
		if Utils.isPlayer(entity) and not entity.isMainPlayer and entity.active and entity.visible and entity.uid ~= nil and M.isFriendPlayerUid(entity.uid) then
			local entPos = entity.getPosition and entity:getPosition() or nil

			if entPos then
				local nearHeight = 0

				if entity.getCameraHeightInfo then
					nearHeight = entity:getCameraHeightInfo() or 0
				end

				local configData = entity.getConfigData and entity:getConfigData() or {}
				local modelHeight = configData.modelHeight or nearHeight
				local height = (nearHeight + modelHeight) / 2

				Vector3.enableCreateFromCache()

				local adjustPos = Vector3(entPos.x, entPos.y + height, entPos.z)
				local distance = Vector3.Distance(adjustPos, curCameraPos)
				local isBlock = pgUtils.IsBlocked(curCameraPos, adjustPos, distance, layerMask)
				local inViewport = M.checkInViewportMaster(entPos, height)

				Vector3.disableCreateFromCache()

				if inViewport and not isBlock then
					local uidKey = tostring(entity.uid)

					if not friendPlayerUidMap[uidKey] then
						friendPlayerUidMap[uidKey] = true

						table.insert(friendUidList, entity.uid)
					end
				end
			end
		end
	end

	return friendUidList
end

function M:takePhoto(traitId)
	if not pg or not pg.global or not pg.global.eventEmitter then
		return
	end

	local photoComponent = self.photoComponent
	local friendPlayerUidsInView = M.getFriendPlayerUidsInViewport()

	pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_TAKE_PHOTO, {
		templateIds = photoComponent and photoComponent.curTemplateIds or {},
		hasPlayerInView = M.checkMainPlayerInViewport(),
		sceneId = pg.me and pg.me.space and pg.me.space.sceneId or 0,
		photoType = photoComponent and photoComponent.curPhotoType,
		isPhotoStudio = Utils.isScenePhoto(),
		friendPlayerUidsInView = friendPlayerUidsInView,
		traitId = traitId
	})
end

return M
