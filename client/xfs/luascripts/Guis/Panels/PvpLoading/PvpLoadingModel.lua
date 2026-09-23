-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpLoading\\PvpLoadingModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpLoadingModel = Class.LightClass("PvpLoadingModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PvpModeData = require("Data.pvp_mode_data")
local Time = require("Core.Common.Time")
local PvpRankData = require("Data.pvp_rank_data")

function PvpLoadingModel:ctor()
	self.endTime = Time.realSecondCache
	self.startTime = Time.realSecondCache
end

function PvpLoadingModel:initEndTime()
	if self.endTime >= Time.realSecondCache then
		return
	end

	local cData = PvpModeData[1] or {}

	self.endTime = Time.realSecondCache + (cData.showTime or 0)
	self.startTime = Time.realSecondCache
end

function PvpLoadingModel:checkLoadingFinished()
	return self.endTime <= Time.realSecondCache
end

function PvpLoadingModel:getLoadingProgress()
	return (Time.realSecondCache - self.startTime) / (self.endTime - self.startTime)
end

function PvpLoadingModel:getTeamInfos()
	local me = pg.me

	if me == nil then
		return nil
	end

	local space = me.space
	local res = {
		selfInfo = {},
		enemyInfo = {}
	}

	for id, v in pairs(space.passerByMap) do
		if id == me.id then
			self:parserPlayerInfo(v, res.selfInfo)
		else
			self:parserPlayerInfo(v, res.enemyInfo)
		end
	end

	if space.spaceLoadingInfo.roomInfo == nil then
		res.srData = {}
		res.orData = {}

		return res
	end

	local matchInfos = space.spaceLoadingInfo.roomInfo.matchInfos

	for k, v in pairs(matchInfos) do
		if k == me.uid then
			res.srData = LuaUIUtils.getPVPRankInfo(v.playerSorce)
		else
			res.orData = LuaUIUtils.getPVPRankInfo(v.playerSorce)
		end
	end

	return res
end

function PvpLoadingModel:parserPlayerInfo(sourceInfo, res)
	local rawInfo = sourceInfo:getDisplayInfo()

	res.name = rawInfo.name

	local curPets = {}

	for i, templateId in ipairs(rawInfo.pets) do
		local item = {}

		item.icon = LuaUIUtils.getPetIconByTemplateId(templateId, LuaUIUtils.PET_ICON)
		curPets[i] = item
	end

	res.petList = curPets
end

return PvpLoadingModel
