-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpBattle\\PvpBattleModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PvpBattleModel")
local Class = require("Core.Framework.Class")
local Mathf = require("Common.Math.Mathf")
local UIModel = require("Guis.UIModel")
local PvpBattleModel = Class.LightClass("PvpBattleModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local PvpRankData = require("Data.pvp_rank_data")
local DungeonConst = require("Common.Const.DungeonConst")
local STATUS = DungeonConst.STATUS

function PvpBattleModel:ctor()
	self.teamInfos = {}
end

function PvpBattleModel:getEndTime()
	if pg.me == nil or pg.me.space == nil then
		return 0
	end

	return pg.me.space.end_ts
end

function PvpBattleModel:isGameRewarded()
	return pg.me.space.status == STATUS.REWARD
end

function PvpBattleModel:isInGaming()
	return pg.me.space.status == STATUS.PLAYING
end

function PvpBattleModel:getTeamInfos()
	local res = {
		selfInfo = {},
		enemyInfo = {}
	}
	local me = pg.me

	for id, v in pairs(me.space.passerByMap) do
		if id == me.id then
			res.selfInfo.id = id

			self:parserPlayerInfo(v, res.selfInfo)
		else
			res.enemyInfo.id = id

			self:parserPlayerInfo(v, res.enemyInfo)
		end
	end

	self.teamInfos = res

	return res
end

function PvpBattleModel:parserPlayerInfo(sourceInfo, res)
	local rawInfo = sourceInfo:getDisplayInfo()

	res.result = sourceInfo.result[1]
	res.oldScore = sourceInfo.result[2]
	res.addScore = sourceInfo.result[3]
	res.name = rawInfo.name
	res.sData = LuaUIUtils.getPVPRankInfo(res.oldScore or 0)

	local curPets = {}

	for i, pId in ipairs(sourceInfo.petPrepareList) do
		local v = sourceInfo.petCombatMap[pId]
		local item = {
			templateId = v.templateId,
			id = pId
		}

		item.icon = LuaUIUtils.getPetIconByTemplateId(v.templateId, LuaUIUtils.PET_ICON)
		curPets[i] = item
	end

	res.petList = curPets
end

function PvpBattleModel:getCurPet(isPlayerPet)
	if self.teamInfos == nil then
		self:getTeamInfos()
	end

	local id = self.teamInfos.selfInfo.id

	if not isPlayerPet then
		id = self.teamInfos.enemyInfo.id
	end

	local entity = pg.global.entityMgr.getEntity(id)

	if entity == nil then
		return nil
	end

	return entity:getCurPetEntity()
end

function PvpBattleModel:getSwitchPetInfo()
	local res = {}
	local me = pg.me
	local maxCount = me.switchPetForceMaxCount
	local curCount = me.switchPetForceCount

	for i = 1, maxCount do
		res[i] = {
			hasDot = i <= curCount
		}
	end

	return res
end

PvpBattleModel.BREAK_STATE = {
	{
		min = 0,
		max = 0.3
	},
	{
		min = 0.3,
		max = 0.7
	},
	{
		min = 0.7,
		max = 1
	}
}

function PvpBattleModel:getBreakPageIndex(value, maxValue)
	if maxValue == 0 and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("@sxy invalid break max value")
	end

	local percent = value / maxValue

	if percent == 0 then
		return 0
	else
		for index, range in ipairs(self.BREAK_STATE) do
			if percent > range.min and percent <= range.max then
				return index
			end
		end
	end
end

return PvpBattleModel
