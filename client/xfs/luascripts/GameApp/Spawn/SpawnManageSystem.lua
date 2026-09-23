-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Spawn\\SpawnManageSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local SceneUtils = require("Common.Utils.SceneUtils")
local SpawnerNoticeData = require("Data.spawner_notice_data")
local SpawnManageSystem = Class.LightClass("SpawnManageSystem", SystemBase)

function SpawnManageSystem:onCtor()
	self.spawnerInfos = {}
end

function SpawnManageSystem:onTick()
	for _, spawnerInfo in pairs(self.spawnerInfos) do
		self:updateSpawnerInfo(spawnerInfo)
	end
end

function SpawnManageSystem:onLeaveScene(sceneId, sceneName)
	self:clearAll()
end

function SpawnManageSystem:onSpawnerCreate(spawnerId, sceneId, spaceId)
	local spawnerInfo = {}
	local sceneSpawnerData = SceneUtils.getSceneSpawnerData(sceneId, spaceId)
	local spawnerData = sceneSpawnerData[spawnerId]

	if spawnerData then
		local spawnerNoticeId = spawnerData.spawnerNoticeId
		local noticeData = SpawnerNoticeData[spawnerNoticeId or 0]

		if noticeData then
			local pos = self:getSpawnerPosition(spawnerId, sceneId, spaceId)

			if pos then
				spawnerInfo.pos = pos
				spawnerInfo.spawnerId = spawnerId
				spawnerInfo.spawnerData = spawnerData
				spawnerInfo.noticeData = noticeData

				if self.spawnerInfos[spawnerId] and self.spawnerInfos[spawnerId].effId then
					pg.game.effect:stopEffect(nil, self.spawnerInfos[spawnerId].effId)
				end

				self.spawnerInfos[spawnerId] = spawnerInfo
			end

			if noticeData.noticeSpawn then
				pg.global.showBubbleMessage(noticeData.noticeSpawn)
			end
		end
	end
end

function SpawnManageSystem:showSpawnerNotice(spawnerInfo)
	local noticeData = spawnerInfo.noticeData

	if noticeData.noticeSpawn then
		pg.global.showBubbleMessage(noticeData.noticeSpawn)
	end
end

function SpawnManageSystem:getSpawnerPosition(spawnerId, sceneId, spaceId)
	local sceneSpawnerData = SceneUtils.getSceneSpawnerData(sceneId, spaceId)
	local spawnerData = sceneSpawnerData[spawnerId]

	if spawnerData then
		return spawnerData.position
	end

	return nil
end

function SpawnManageSystem:updateSpawnerInfo(spawnerInfo)
	local noticeData = spawnerInfo.noticeData

	if spawnerInfo.noticeData.displayEffect then
		if spawnerInfo.effId then
			if self:checkDistanceInRange(spawnerInfo.pos, spawnerInfo.noticeData.hideEffectDistance or 50) then
				pg.game.effect:stopEffect(nil, spawnerInfo.effId)

				spawnerInfo.effId = nil
			end
		elseif not self:checkDistanceInRange(spawnerInfo.pos, (spawnerInfo.noticeData.hideEffectDistance or 50) + 10) then
			spawnerInfo.effId = pg.game.effect:playEffectAt(nil, noticeData.displayEffect, spawnerInfo.pos)
		end
	end

	if spawnerInfo.noticeData.noticeEnter and not spawnerInfo.noticeEnterShowed and self:checkDistanceInRange(spawnerInfo.pos, spawnerInfo.noticeData.noticeEnterDistance or 100) then
		pg.global.showBubbleMessage(spawnerInfo.noticeData.noticeEnter)

		spawnerInfo.noticeEnterShowed = true
	end
end

function SpawnManageSystem:checkDistanceInRange(pos, distance)
	local playerPos = pg.pawn:getPosition()

	return distance >= Vector3.Distance(playerPos, pos)
end

function SpawnManageSystem:onSpawnerDestroy(spawnerId)
	local spawnerInfo = self.spawnerInfos[spawnerId]

	if spawnerInfo then
		if spawnerInfo.effId then
			pg.game.effect:stopEffect(nil, spawnerInfo.effId)

			spawnerInfo.effId = nil
		end

		self.spawnerInfos[spawnerId] = nil
	end
end

function SpawnManageSystem:clearAll()
	for _, spawnerInfo in pairs(self.spawnerInfos) do
		if spawnerInfo.effId then
			pg.game.effect:stopEffect(nil, spawnerInfo.effId)

			spawnerInfo.effId = nil
		end
	end

	self.spawnerInfos = {}
end

return SpawnManageSystem
