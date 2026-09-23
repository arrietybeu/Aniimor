-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Map\\Component\\MarkUnlockerComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventConst = require("Const.EventConst")
local Time = require("Core.Common.Time")
local SceneUtils = require("Common.Utils.SceneUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local MapHelper = require("GameApp.Map.MapHelper")
local ActivateSandboxData = require("Data.activate_sandbox_data")
local MapMarkActivityData = require("Data.mapmarkid_activityid_data")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientUtils = require("Utils.ClientUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local SysConfigData = require("Data.sys_config_data")
local MarkUnlockerComponent = Class.LiteClass("MarkUnlockerComponent")
local SqrDistance = Vector3.SqrDistance

local function isMarkOwnerReady(markSpawner)
	local ownerInfo = markSpawner and markSpawner.ownerInfo

	if not ownerInfo or ownerInfo[1] ~= "entity" and ownerInfo[1] ~= "sandbox" then
		return true
	end

	local initRecord = pg.game.map and pg.game.map.entityStaticIdInitRecord

	return initRecord and initRecord[ownerInfo[2]] == true
end

function MarkUnlockerComponent:ctor()
	self.player = pg.me

	if not self.player then
		return
	end

	self.playerPos = pg.me:getPosition()
	self.playerChunkIndexX, self.playerChunkIndexZ = nil
	self.sceneId = pg.game.map:convertSceneId(self.player.space.sceneId)
	self.markMap = self.player:getSpaceOwnerMapMarkStatusMap() or self.player.mapMarkStatusMap
	self.sceneMarkPointChunkData = pg.game.map.sceneMarkPointChunkData
	self.tempMarkPointData = pg.game.map.tempMarkPointData
	self.requestCountMap = {}
	self.unlockChunkMap = {}
	self.poiChunkMap = {}

	if self.markTimer then
		TimerManager.removeTimer(self.markTimer)

		self.markTimer = nil
	end

	local maxCount = #MapHelper.CHUNK_DIRECTION + 1
	local beginIndex = 1

	self.markTimer = TimerManager.addRepeatTimer(0.1, function()
		self.player = pg.me

		if not self.player then
			return
		end

		self:startCheckPlayerIsInSelectArea(beginIndex)

		beginIndex = (beginIndex + 1) % maxCount
	end)
end

local _cacheDis = {}

function MarkUnlockerComponent:startCheckPlayerIsInSelectArea(index)
	if not pg.me then
		return
	end

	local sceneMarkPointData = pg.game.map.sceneMarkPointData

	if sceneMarkPointData == nil then
		return
	end

	self.sceneMarkPointData = sceneMarkPointData
	self.playerPos = pg.me:getPosition()
	self.playerChunkIndexX, self.playerChunkIndexZ = MapHelper.calXAndZKey(self.playerPos.x, self.playerPos.z, self.sceneId)

	local points = sceneMarkPointData

	if pg.me:isUsingSpaceOwnerMap() then
		local offset = MapHelper.CHUNK_DIRECTION[index]

		if offset then
			local pos = self.playerPos
			local unlockList, poiList = self:GetUnlockList(offset)

			for i, markId in ipairs(poiList) do
				local point = points[markId]
				local markDistance = SqrDistance(pos, point.markPosition)

				self:showPoiEx(markId, point, markDistance)
			end
		else
			for markId, markSpawner in pairs(self.tempMarkPointData) do
				if not MapHelper.isSpecialMark(markSpawner.markType) then
					self:showPoi(markId, markSpawner)
				end
			end
		end
	else
		local requestCountMap = self.requestCountMap
		local offset = MapHelper.CHUNK_DIRECTION[index]

		if offset then
			local pos = self.playerPos
			local unlockList, poiList = self:GetUnlockList(offset)

			for i, markId in ipairs(poiList) do
				local point = points[markId]
				local markDistance = SqrDistance(pos, point.markPosition)

				_cacheDis[markId] = markDistance

				self:showPoiEx(markId, point, markDistance)
			end

			for i, markId in ipairs(unlockList) do
				if (requestCountMap[markId] or 0) < 3 then
					local point = points[markId]
					local markDistance = _cacheDis[markId] or SqrDistance(pos, point.markPosition)

					self:unlockMapMarkEx(markId, point, markDistance)
				end
			end

			table.clear(_cacheDis)
		else
			for markId, markSpawner in pairs(self.tempMarkPointData) do
				if not MapHelper.isSpecialMark(markSpawner.markType) then
					local count = requestCountMap[markId] or 0

					if count < 3 then
						self:unlockMapMark(markId, markSpawner)
					end

					self:showPoi(markId, markSpawner)
				end
			end
		end
	end
end

local _empty = {}

function MarkUnlockerComponent:GetUnlockList(offset)
	local x = self.playerChunkIndexX + offset[1]
	local z = self.playerChunkIndexZ + offset[2]
	local pointChunk = self.sceneMarkPointChunkData[x]

	if pointChunk and pointChunk[z] then
		local chunkZ = pointChunk[z]
		local unlockList = self.unlockChunkMap[chunkZ]

		if unlockList then
			return unlockList, self.poiChunkMap[chunkZ]
		end

		local points = self.sceneMarkPointData

		unlockList = {}

		local poiList = {}

		for _, markId in pairs(chunkZ) do
			local mark = points[markId]

			if mark and not MapHelper.isSpecialMark(mark.markType) then
				if self:filterUnlock(markId, mark) then
					unlockList[#unlockList + 1] = markId
				end

				if self:filterPoi(markId, mark) then
					poiList[#poiList + 1] = markId
				end
			end
		end

		self.unlockChunkMap[chunkZ] = unlockList
		self.poiChunkMap[chunkZ] = poiList

		return unlockList, poiList
	else
		return _empty, _empty
	end
end

function MarkUnlockerComponent:filterUnlock(spawnerId, markSpawner)
	if markSpawner.markPosition == nil or markSpawner.activeDistance == nil or markSpawner.initState == nil or markSpawner.activeState == nil or markSpawner.activeState <= markSpawner.initState then
		return
	end

	if not markSpawner.activeHigh then
		return
	end

	return true
end

function MarkUnlockerComponent:filterPoi(spawnerId, markSpawner)
	if not markSpawner.POIState or not markSpawner.activeDistance then
		return
	end

	if not markSpawner.POIShowType or not markSpawner.POIOrNot then
		return
	end

	return true
end

function MarkUnlockerComponent:isPoiForbiddenInMultiplayer(spawnerId, markSpawner)
	local space = pg.me and pg.me.space

	if not space or not space:isMultiPlayerEnv() then
		return false
	end

	if pg.me:isSpaceOwner() then
		return false
	end

	local multiplayerPoiType = markSpawner.multiplayerPoiType

	if multiplayerPoiType == nil then
		local markConfig = Utils.getMarkConfigByMarkId(spawnerId, space.id)

		multiplayerPoiType = markConfig and markConfig.multiplayerPoiType
	end

	return not ToBool(multiplayerPoiType)
end

function MarkUnlockerComponent:isMapMarkActivityAvailable(spawnerId)
	local activityId = MapMarkActivityData[spawnerId]

	if not activityId then
		return true
	end

	if not ClientActivityUtils.isEventOpen(activityId) then
		return false
	end

	local activityConfig = ActivateSandboxData[activityId]
	local conditionList = activityConfig and activityConfig.condition

	if not conditionList then
		return true
	end

	for _, conditionId in ipairs(conditionList) do
		if not ClientUtils.checkCondition(conditionId) then
			return false
		end
	end

	return true
end

function MarkUnlockerComponent:unlockMapMarkEx(spawnerId, markSpawner, markDistance)
	local dis = markSpawner.activeDistance

	if markDistance > dis * dis then
		return
	end

	local markType = markSpawner.markType

	if not self:validHeightGap(self.playerPos, markSpawner.markPosition, markSpawner.activeHigh[1], markSpawner.activeHigh[2]) then
		return
	end

	if self.markMap:getStatus(self.sceneId, markType, spawnerId) >= Const.MAP_MARK_STATUS_UNLOCKED then
		return
	end

	if not isMarkOwnerReady(markSpawner) then
		return
	end

	if not self:isMapMarkActivityAvailable(spawnerId) then
		return
	end

	if markType == Const.MAP_MARK_QUEST then
		self.player:serverMsg("RPC_CS_ChangeQuestMarkStatus", spawnerId, markSpawner.activeState, function(result)
			if result then
				pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
					type = "addOrUpdate",
					id = spawnerId
				})
			end
		end)
	else
		self.player:serverMsg("RPC_CS_MapMarkUnlock", self.sceneId, markType, spawnerId, markSpawner.activeState)
	end

	self.requestCountMap[spawnerId] = (self.requestCountMap[spawnerId] or 0) + 1
end

function MarkUnlockerComponent:tryShowLeylineFlowerPoi(markSpawner)
	if markSpawner.markConfigId ~= LeylineFlowerConst.LEYLINE_FLOWER_POINT_CONFIG_ID then
		return false
	end

	pg.global.ui.tips:showCultivateMapTip({
		cultivateState = LeylineFlowerConst.CULTIVATE_TIP_STATE.LeylineFlower,
		duration = SysConfigData.LEYLINE_FLOWER_APPROACH_HUD_DURATION or 3,
		titleKey = markSpawner.infoTitle,
		subTitleKey = markSpawner.infoText
	})

	return true
end

function MarkUnlockerComponent:showPoiEx(spawnerId, markSpawner, markDistance)
	local dis = markSpawner.activeDistance

	if markDistance > dis * dis then
		pg.game.map.mapHudOnceTable[spawnerId] = nil

		return
	elseif pg.game.map.mapHudOnceTable[spawnerId] then
		return
	end

	local markType = markSpawner.markType
	local markStatus = self.markMap:getStatus(self.sceneId, markType, spawnerId)

	if Const.MAP_MARK_STATUS_HIDE == markStatus or not LuaUIUtils.arrayContains(markSpawner.POIState, markStatus) then
		return
	end

	if not isMarkOwnerReady(markSpawner) then
		return
	end

	if self:isPoiForbiddenInMultiplayer(spawnerId, markSpawner) then
		pg.game.map.mapHudOnceTable[spawnerId] = true

		return
	end

	local areaData = {
		state = 1,
		priority = markSpawner.POIPriority,
		uniqueId = spawnerId,
		args = {
			POIShowType = markSpawner.POIShowType,
			POIIcon = markSpawner.POIIcon,
			POIMusic = markSpawner.POIMusic,
			title = markSpawner.infoTitle,
			subTitle = markSpawner.POIDesc,
			sceneId = self.sceneId,
			staticId = spawnerId
		}
	}

	if not self:tryShowLeylineFlowerPoi(markSpawner) then
		pg.global.ui.tips:showPoi(areaData)
	end

	pg.game.map.mapHudOnceTable[spawnerId] = true

	self:customLog(spawnerId)
end

function MarkUnlockerComponent:unlockMapMark(spawnerId, markSpawner)
	local markType = markSpawner.markType

	if markSpawner.markPosition == nil or markSpawner.activeDistance == nil or markSpawner.initState == nil or markSpawner.activeState == nil or markSpawner.activeState <= markSpawner.initState then
		return
	end

	local markDistance = SqrDistance(self.playerPos, markSpawner.markPosition)
	local dis = markSpawner.activeDistance

	if markDistance > dis * dis then
		return
	end

	if not markSpawner.activeHigh then
		return
	end

	if not self:validHeightGap(self.playerPos, markSpawner.markPosition, markSpawner.activeHigh[1], markSpawner.activeHigh[2]) then
		return
	end

	if not isMarkOwnerReady(markSpawner) then
		return
	end

	if self.markMap:getStatus(self.sceneId, markType, spawnerId) >= Const.MAP_MARK_STATUS_UNLOCKED then
		return
	end

	if not self:isMapMarkActivityAvailable(spawnerId) then
		return
	end

	if markType == Const.MAP_MARK_QUEST then
		self.player:serverMsg("RPC_CS_ChangeQuestMarkStatus", spawnerId, markSpawner.activeState, function(result)
			if result then
				pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
					type = "addOrUpdate",
					id = spawnerId
				})
			end
		end)
	else
		self.player:serverMsg("RPC_CS_MapMarkUnlock", self.sceneId, markType, spawnerId, markSpawner.activeState)
	end

	self.requestCountMap[spawnerId] = (self.requestCountMap[spawnerId] or 0) + 1
end

function MarkUnlockerComponent:showPoi(spawnerId, markSpawner)
	local markType = markSpawner.markType
	local markStatus = self.markMap:getStatus(self.sceneId, markType, spawnerId)

	if Const.MAP_MARK_STATUS_HIDE == markStatus or not markSpawner.POIState then
		return
	end

	if not LuaUIUtils.arrayContains(markSpawner.POIState, markStatus) then
		return
	end

	if not isMarkOwnerReady(markSpawner) then
		return
	end

	if markSpawner.POIShowType and markSpawner.POIOrNot then
		local markDistance = SqrDistance(self.playerPos, markSpawner.markPosition)
		local activeDistance = markSpawner.activeDistance

		if activeDistance and markDistance <= activeDistance * activeDistance then
			if not pg.game.map.mapHudOnceTable[spawnerId] then
				if self:isPoiForbiddenInMultiplayer(spawnerId, markSpawner) then
					pg.game.map.mapHudOnceTable[spawnerId] = true

					return
				end

				local areaData = {
					state = 1,
					priority = markSpawner.POIPriority,
					uniqueId = spawnerId,
					args = {
						POIShowType = markSpawner.POIShowType,
						POIIcon = markSpawner.POIIcon,
						POIMusic = markSpawner.POIMusic,
						title = markSpawner.infoTitle,
						subTitle = markSpawner.POIDesc,
						sceneId = self.sceneId,
						staticId = spawnerId
					}
				}

				if not self:tryShowLeylineFlowerPoi(markSpawner) then
					pg.global.ui.tips:showPoi(areaData)
				end

				pg.game.map.mapHudOnceTable[spawnerId] = true

				self:customLog(spawnerId)
			end
		elseif pg.game.map.mapHudOnceTable[spawnerId] then
			pg.game.map.mapHudOnceTable[spawnerId] = nil
		end
	end
end

function MarkUnlockerComponent:customLog(spawnerId)
	if not self.sceneId or not self.player or not self.player.space or not self.player.space.sandboxes then
		return
	end

	local sandboxConfig = SceneUtils.getSceneSandboxIdData(self.sceneId, spawnerId, self.player.space.id)
	local sandbox = self.player.space.sandboxes[spawnerId]

	if sandboxConfig == nil or sandbox == nil then
		return
	end

	for _, entity in pairs(sandbox.entities or EMPTY_TABLE) do
		if Utils.isSemanticallyBoss(entity) then
			LuaUIUtils.sendCustomLog(Const.BILogName.FIND_ELITE_OR_BOSS, {
				curTime = Time.secondCache,
				eliteOrBossId = sandboxConfig.id,
				eliteOrBossPoiType = sandboxConfig.poiType
			})
		end
	end
end

function MarkUnlockerComponent:validHeightGap(playerPos, markPos, positive, negative)
	local gap = playerPos[2] - markPos[2]

	return gap <= positive and negative <= gap
end

function MarkUnlockerComponent:destroy()
	if self.markTimer then
		TimerManager.removeTimer(self.markTimer)
	end

	self.markTimer = nil
	self.sceneMarkData = nil
	self.requestCountMap = nil
	self.enableHUD = nil
	self.requestCountMap = nil
	self.unlockChunkMap = nil
	self.poiChunkMap = nil
end

return MarkUnlockerComponent
