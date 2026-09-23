-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceMediaMarkerComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local InfoStampPresetContentData = require("Data.info_stamp_preset_content_data")
local PuppetName = require("Data.puppet_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local getMarkerTileKey = Utils.getMarkerTileKey
local ClientSpaceMediaMarkerComponent = Class.Component("ClientSpaceMediaMarkerComponent")

function ClientSpaceMediaMarkerComponent:ctor()
	self.mediaMarkers = {}
	self.loadMarkerIndexs = {}
	self.mainPlayerLastTile = nil
	self.mainPlayerTile = nil
end

function ClientSpaceMediaMarkerComponent:init(dict)
	return
end

function ClientSpaceMediaMarkerComponent:start()
	self:startPullMediaMarkerTimer()
end

function ClientSpaceMediaMarkerComponent:notifyMediaMarker(mediaMarkers)
	self.mediaMarkers = mediaMarkers

	self:refreshMediaMarkerUI()
end

function ClientSpaceMediaMarkerComponent:refreshMediaMarkerUI()
	self:presetContent()
	pg.game.markShare:refreshAroundInfoStamp()
end

function ClientSpaceMediaMarkerComponent:getMarkDataByInformationId(informationId)
	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(self.sceneId, self.id)

	for _, v in pairs(sceneMarkPointData) do
		if v.informationId == informationId then
			return v
		end
	end

	return nil
end

function ClientSpaceMediaMarkerComponent:presetContent()
	for posIndex, infoStamp in pairs(self.mediaMarkers) do
		for infoStampId, infoStampValue in pairs(infoStamp) do
			if infoStampValue.type == Const.MediaMarkerType.SystemText and type(infoStampValue.content) ~= "table" then
				local informationId = Utils.getNoBySysMediaMarkerId(infoStampId)
				local presetData = InfoStampPresetContentData[informationId]
				local markData = self:getMarkDataByInformationId(informationId)

				if not markData then
					self.mediaMarkers[posIndex][infoStampId] = nil
				else
					local playerName = pg.getGameString("MYSTERIOUS_ADVENTURER")

					if presetData.playerName then
						playerName = pg.getLocalizationText(presetData.playerName)
					elseif presetData.npcId ~= nil then
						playerName = pg.getLocalizationText(PuppetName[presetData.npcId].name)
					end

					infoStampValue.content = {
						pos = {
							markData.markPosition[1],
							markData.markPosition[2],
							markData.markPosition[3]
						},
						rot = Quaternion.Euler(presetData.rotation[1], presetData.rotation[2], presetData.rotation[3]),
						playerName = playerName,
						informationType = presetData.informationType
					}
				end
			end
		end
	end
end

function ClientSpaceMediaMarkerComponent:destroyMarks()
	self.mediaMarkers = {}

	pg.game.markShare:closeViewUI()
	pg.game.markShare:refreshAroundInfoStamp()
end

function ClientSpaceMediaMarkerComponent:destroy()
	self:destroyMarks()
end

function ClientSpaceMediaMarkerComponent:getTileDelta()
	return 1
end

function ClientSpaceMediaMarkerComponent:getLastTile(playerId)
	return self.playerId2LastTile[playerId]
end

function ClientSpaceMediaMarkerComponent:getMediaMarkerPosIndexByTile(tileNo)
	return tostring(pg.me.serverId) .. "-" .. tostring(self.sceneId) .. "-" .. tostring(tileNo)
end

function ClientSpaceMediaMarkerComponent:getMediaMarkerPosIndexByPos(x, z)
	local tileKey, _, _ = Utils.getSpaceMarkerTile(x, z)

	return self:getMediaMarkerPosIndexByTile(tileKey)
end

function ClientSpaceMediaMarkerComponent:markerMoveTile(playerId, tileX, tileZ)
	local curTile = getMarkerTileKey(tileX, tileZ)

	if self.mainPlayerLastTile ~= nil and self.mainPlayerLastTile == curTile then
		return
	end

	self.mainPlayerLastTile = curTile

	self:loadTileMediaMarker(tileX, tileZ)
end

function ClientSpaceMediaMarkerComponent:loadTileMediaMarker(tileX, tileZ)
	local delta = self:getTileDelta()
	local needLoadIndexes = {}
	local index

	for i = -delta, delta do
		for j = -delta, delta do
			index = self:getMediaMarkerPosIndexByTile(getMarkerTileKey(tileX + i, tileZ + j))
			needLoadIndexes[#needLoadIndexes + 1] = index
		end
	end

	self.loadMarkerIndexs = needLoadIndexes

	self:batchFindMediaMarker()
end

function ClientSpaceMediaMarkerComponent:batchFindMediaMarker()
	if #self.loadMarkerIndexs <= 0 then
		return
	end

	local areaNo, languageNo = Utils.parseClassId(pg.me.uid)
	local languages = {}

	if areaNo ~= nil then
		local mainLanguageNo = Utils.getAssociatedLanguageNo(areaNo, languageNo)

		if mainLanguageNo ~= nil and mainLanguageNo ~= languageNo then
			languages = {
				languageNo,
				mainLanguageNo
			}
		else
			languages = {
				languageNo
			}
		end
	end

	if #self.loadMarkerIndexs == 1 then
		self:callService("MediaMarkerService", "findMarkerByIndex", {
			self.loadMarkerIndexs[1],
			languages
		}, CallbackHandler(self, "batchFindMediaMarkerCb"), {
			hint = self.loadMarkerIndexs[1]
		})

		return
	end

	self:callService("MediaMarkerService", "batchFindMarker", {
		self.loadMarkerIndexs,
		{},
		languages
	}, CallbackHandler(self, "batchFindMediaMarkerCb"), {
		hint = self.loadMarkerIndexs[1]
	})
end

function ClientSpaceMediaMarkerComponent:batchFindMediaMarkerCb(retStatus, response)
	if not retStatus.status then
		return
	end

	if response.ErrorCode ~= "OK" then
		return
	end

	local mediaMarkers = {}
	local posIndex

	for k, v in pairs(response.Markers) do
		posIndex = v.posIndex

		if mediaMarkers[posIndex] == nil then
			mediaMarkers[posIndex] = {}
		end

		mediaMarkers[posIndex][k] = v
	end

	self:notifyMediaMarker(mediaMarkers)
	self:startPullMediaMarkerTimer()
end

function ClientSpaceMediaMarkerComponent:pullMediaMarker()
	if not pg.me or pg.me:isServerLost() then
		return
	end

	self:batchFindMediaMarker()
end

function ClientSpaceMediaMarkerComponent:startPullMediaMarkerTimer()
	if self.pullMediaMarkerTimer ~= nil then
		self:removeTimer(self.pullMediaMarkerTimer)

		self.pullMediaMarkerTimer = nil
	end

	self.pullMediaMarkerTimer = self:addRepeatTimer(60, function()
		self:pullMediaMarker()
	end)
end

function ClientSpaceMediaMarkerComponent:RPC_SC_RemoveMediaMarker(posIndex, markerId)
	if self.mediaMarkers[posIndex] and self.mediaMarkers[posIndex][markerId] then
		self.mediaMarkers[posIndex][markerId] = nil

		self:refreshMediaMarkerUI()
	end
end

function ClientSpaceMediaMarkerComponent:RPC_SC_AddMediaMarker(posIndex, markerId, marker)
	if self.mediaMarkers[posIndex] == nil then
		self.mediaMarkers[posIndex] = {}
	end

	self.mediaMarkers[posIndex][markerId] = marker

	self:refreshMediaMarkerUI()
end

function ClientSpaceMediaMarkerComponent:RPC_SC_UpdateMediaMarker(posIndex, markerId, likes, dislikes, encourageDays, isPermanent)
	if Utils.isSysMediaMarkerId(markerId) then
		if self.mediaMarkers[posIndex] == nil then
			self.mediaMarkers[posIndex] = {}
		end

		if self.mediaMarkers[posIndex][markerId] == nil then
			self.mediaMarkers[posIndex][markerId] = {}
		end

		self.mediaMarkers[posIndex][markerId].type = Const.MediaMarkerType.SystemText
		self.mediaMarkers[posIndex][markerId].likes = likes
		self.mediaMarkers[posIndex][markerId].dislikes = dislikes

		if encourageDays ~= nil then
			self.mediaMarkers[posIndex][markerId].encourageDays = encourageDays
		end

		if isPermanent ~= nil then
			self.mediaMarkers[posIndex][markerId].isPermanent = isPermanent
		end

		self:refreshMediaMarkerUI()
	elseif self.mediaMarkers[posIndex] and self.mediaMarkers[posIndex][markerId] then
		self.mediaMarkers[posIndex][markerId].likes = likes
		self.mediaMarkers[posIndex][markerId].dislikes = dislikes

		if encourageDays ~= nil then
			self.mediaMarkers[posIndex][markerId].encourageDays = encourageDays
		end

		if isPermanent ~= nil then
			self.mediaMarkers[posIndex][markerId].isPermanent = isPermanent
		end

		self:refreshMediaMarkerUI()
	end
end

return ClientSpaceMediaMarkerComponent
