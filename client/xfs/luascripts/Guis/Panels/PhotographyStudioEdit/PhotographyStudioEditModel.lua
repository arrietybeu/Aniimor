-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\PhotographyStudioEditModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PhotographyStudioEditModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local PhotographyStudioEditModel = Class.LightClass("PhotographyStudioEditModel", UIModel)
local HISTORY_LIMIT = 10

PhotographyStudioEditModel.CameraModeIds = {
	FreeCamera = 0,
	FishEye = 2,
	WideAngle = 1
}

function PhotographyStudioEditModel:ctor()
	UIModel.ctor(self)

	self.curCameraMode = self.CameraModeIds.FreeCamera
	self.studioAssetsId = nil
	self.historyStack = {}
	self.historyIndex = 0
	self.savedSnapshot = nil
	self.isApplyingHistory = false
end

function PhotographyStudioEditModel:clearHistory()
	table.clear(self.historyStack)

	self.historyIndex = 0
	self.savedSnapshot = nil
	self.isApplyingHistory = false
end

function PhotographyStudioEditModel:initHistory(snapshot)
	table.clear(self.historyStack)

	self.historyIndex = 0

	if type(snapshot) ~= "table" then
		self.savedSnapshot = nil

		return false
	end

	local copiedSnapshot = Utils.deepCopyTable(snapshot)

	self.historyStack[1] = copiedSnapshot
	self.historyIndex = 1
	self.savedSnapshot = Utils.deepCopyTable(copiedSnapshot)

	return true
end

function PhotographyStudioEditModel:isHistoryReady()
	return self.historyIndex > 0 and self.historyStack[self.historyIndex] ~= nil
end

function PhotographyStudioEditModel:recordHistoryStep(snapshot)
	if type(snapshot) ~= "table" then
		return false
	end

	if not self:isHistoryReady() then
		return self:initHistory(snapshot)
	end

	local currentSnapshot = self.historyStack[self.historyIndex]

	if Utils.isTableEqual(currentSnapshot, snapshot) then
		return false
	end

	for index = #self.historyStack, self.historyIndex + 1, -1 do
		self.historyStack[index] = nil
	end

	self.historyStack[#self.historyStack + 1] = Utils.deepCopyTable(snapshot)

	if #self.historyStack > HISTORY_LIMIT then
		table.remove(self.historyStack, 1)
	end

	self.historyIndex = #self.historyStack

	return true
end

function PhotographyStudioEditModel:canUndoHistory()
	return self.historyIndex > 1
end

function PhotographyStudioEditModel:canRedoHistory()
	return self.historyIndex > 0 and self.historyIndex < #self.historyStack
end

function PhotographyStudioEditModel:getUndoHistoryTarget()
	if not self:canUndoHistory() then
		return nil, nil
	end

	local targetIndex = self.historyIndex - 1

	return self.historyStack[targetIndex], targetIndex
end

function PhotographyStudioEditModel:getRedoHistoryTarget()
	if not self:canRedoHistory() then
		return nil, nil
	end

	local targetIndex = self.historyIndex + 1

	return self.historyStack[targetIndex], targetIndex
end

function PhotographyStudioEditModel:commitHistoryIndex(index)
	if index < 1 or index > #self.historyStack then
		return false
	end

	self.historyIndex = index

	return true
end

function PhotographyStudioEditModel:getCurrentHistorySnapshot()
	return self.historyStack[self.historyIndex]
end

function PhotographyStudioEditModel:replaceCurrentHistorySnapshot(snapshot)
	if not self:isHistoryReady() or type(snapshot) ~= "table" then
		return false
	end

	self.historyStack[self.historyIndex] = Utils.deepCopyTable(snapshot)

	return true
end

function PhotographyStudioEditModel:markHistorySaved(snapshot)
	if type(snapshot) ~= "table" then
		return false
	end

	self.savedSnapshot = Utils.deepCopyTable(snapshot)

	return true
end

function PhotographyStudioEditModel:mergeRemotePlayerHistory(changedPlayers)
	if type(changedPlayers) ~= "table" then
		return false
	end

	local function mergeSnapshot(snapshot)
		if type(snapshot) ~= "table" or type(snapshot.players) ~= "table" then
			return
		end

		for changedUid, playerData in pairs(changedPlayers) do
			local changedUidKey = tostring(changedUid)
			local targetUid = changedUid

			for uid in pairs(snapshot.players) do
				if tostring(uid) == changedUidKey then
					targetUid = uid

					break
				end
			end

			snapshot.players[targetUid] = Utils.deepCopyTable(playerData)
		end
	end

	for _, snapshot in ipairs(self.historyStack) do
		mergeSnapshot(snapshot)
	end

	mergeSnapshot(self.savedSnapshot)

	return true
end

function PhotographyStudioEditModel:hasUnsavedChanges(snapshot)
	if type(snapshot) ~= "table" then
		return false
	end

	if not self.savedSnapshot then
		return true
	end

	return not Utils.isTableEqual(snapshot, self.savedSnapshot)
end

function PhotographyStudioEditModel:isMaster(studioUid)
	return pg.me:isStudioMaster(studioUid)
end

function PhotographyStudioEditModel:getCameraMode()
	return self.curCameraMode
end

function PhotographyStudioEditModel:setCameraMode(mode)
	self.curCameraMode = mode
end

function PhotographyStudioEditModel:setStudioAssetsId(assetsId)
	self.studioAssetsId = assetsId
end

function PhotographyStudioEditModel:getStudioAssetsId()
	if self.studioAssetsId and self.studioAssetsId >= 0 then
		return self.studioAssetsId
	end

	return nil
end

function PhotographyStudioEditModel:getAssetsData(assetTable, type2Data, type2Name)
	for _, data in pairs(assetTable) do
		local type = data.type or 1

		if not type2Data[type] then
			type2Data[type] = {}
		end

		if data.name and not type2Name[type] then
			type2Name[type] = data.name
		end

		local list = type2Data[type]

		list[#list + 1] = Lume.clone(data)
	end

	for _, dataList in pairs(type2Data) do
		table.sort(dataList, function(a, b)
			return a.id < b.id
		end)
	end
end

function PhotographyStudioEditModel:getPreparePetList()
	local player = pg.me
	local petPrepareInfoList = player:isTeamPlayerInWorld() and player:getTeamPetIds() or player.petPrepareList
	local infoList = {}

	if not petPrepareInfoList then
		return infoList
	end

	local PetData = require("Data.pet_data")
	local curPet = pg.me:getCurPetEntity()
	local curPetId = curPet and curPet.id

	for _, petId in ipairs(petPrepareInfoList) do
		local petInfo = pg.me:getPetInfo(petId)

		if petInfo ~= nil then
			local pData = PetData[petInfo.templateId]

			infoList[#infoList + 1] = {
				entityId = petId,
				config = pData,
				templateId = petInfo.templateId,
				isCurPet = petId == curPetId
			}
		end
	end

	return infoList
end

function PhotographyStudioEditModel:getCurPetIndex()
	local player = pg.me
	local curPet = pg.me:getCurPetEntity()
	local curPetId = curPet and curPet.id
	local petPrepareInfoList = player:isTeamPlayerInWorld() and player:getTeamPetIds() or player.petPrepareList

	for index, petId in ipairs(petPrepareInfoList or EMPTY_TABLE) do
		if petId == curPetId then
			return index
		end
	end

	return 1
end

return PhotographyStudioEditModel
