-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampManager\\HomeCampManagerModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCampManagerModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeCampManagerModel = Class.LightClass("HomeCampManagerModel", UIModel)
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")

function HomeCampManagerModel:getCampCarEnt()
	local carUid = pg.me and pg.me.uid

	return HomeLandUtils.getCampCarEntity(carUid)
end

function HomeCampManagerModel:isEqualInitCacheCampPetIds()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return false
	end

	local campPetIds = campCarEnt:getCampCopyPetIds() or {}

	return table.equal(self.m_initCampPetIds, campPetIds)
end

function HomeCampManagerModel:init()
	self:m_setCacheCopyCampPetIds()

	self.m_initCampPetIds = {}

	for _, v in ipairs(self.m_petIds or EMPTY_TABLE) do
		table.insert(self.m_initCampPetIds, v)
	end
end

function HomeCampManagerModel:m_setCacheCopyCampPetIds()
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	self.m_petIds = campCarEnt:getCampCopyPetIds() or {}

	HomeCampUtils.setCacheHomeCampPetIds(self.m_petIds)
end

function HomeCampManagerModel:getUICacheCampPetIds()
	return self.m_petIds or {}
end

function HomeCampManagerModel:getIsInCacheCampPetIds(petId)
	local index = self:getCacheCampPetIdsIndex(petId)

	if not index then
		return false
	end

	return self.m_petIds[index] == petId
end

function HomeCampManagerModel:getCacheCampPetIdsIndex(petId)
	if not self.m_petIds or not next(self.m_petIds) then
		return nil
	end

	for i, v in ipairs(self.m_petIds) do
		if v == petId then
			return i
		end
	end

	return nil
end

function HomeCampManagerModel:tryAddCacheCampPets(petInfo, isSetToServer)
	if not petInfo or not next(petInfo) or not petInfo.id then
		return
	end

	local petId = petInfo.id

	if not petId then
		return
	end

	self.m_petIds = self.m_petIds or {}

	if table.contains(self.m_petIds, petId) then
		return pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_ALREADY_IN_CAMP)
	end

	local checkCnt = #self.m_petIds
	local campCarEnt = self:getCampCarEnt()

	if not campCarEnt then
		return
	end

	local maxPetCnt = campCarEnt:getCarPetCanSetCount()

	if maxPetCnt <= checkCnt then
		return pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_COUNT_MAX)
	end

	self:addCacheCampPetId(petId)

	if isSetToServer then
		self:setCacheCampPet()
	end

	return NoticeDef.SUCCESS
end

function HomeCampManagerModel:tryRemoveCacheCampPet(petId, sucCb, failCb, isSetToServer)
	if not petId then
		return
	end

	local isExist = false

	for i, v in ipairs(self.m_petIds or EMPTY_TABLE) do
		if v == petId then
			isExist = true

			break
		end
	end

	if not isExist then
		if failCb then
			failCb()
		end

		return pg.global.showBubbleMessageById(NoticeDef.HOME_CAR_CAMP_PET_NOT_IN_CAMP)
	end

	self:removeCacheCampPetIds({
		petId
	})

	if sucCb then
		sucCb()
	end

	if isSetToServer then
		self:setCacheCampPet()
	end

	return NoticeDef.SUCCESS
end

function HomeCampManagerModel:addCacheCampPetId(petId)
	self.m_petIds = self.m_petIds or {}

	table.insert(self.m_petIds, petId)
	HomeCampUtils.setCacheHomeCampPetIds(self.m_petIds)
end

function HomeCampManagerModel:removeCacheCampPetIds(petIds)
	if not petIds or not next(petIds) then
		return
	end

	local removeIndexes = {}

	for i, v in ipairs(petIds) do
		local index = self:getCacheCampPetIdsIndex(v)

		if index then
			table.insert(removeIndexes, index)
		end
	end

	table.sort(removeIndexes, function(a, b)
		return b < a
	end)

	for _, v in ipairs(removeIndexes) do
		table.remove(self.m_petIds, v)
	end

	HomeCampUtils.setCacheHomeCampPetIds(self.m_petIds)
end

function HomeCampManagerModel:setCacheCampPet(sucCb, failCb)
	local campCarEnt = self:getCampCarEnt()

	if campCarEnt then
		campCarEnt:setCampPetIds(self.m_petIds, function()
			if sucCb then
				sucCb()
			end
		end, function()
			if failCb then
				failCb()
			end
		end)
	end
end

return HomeCampManagerModel
