-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReward\\PvpRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpRewardModel = Class.LightClass("PvpRewardModel", UIModel)

PvpRewardModel.RE_BATTLE_STATE = {
	BACK = 2,
	NONE = 0,
	AGAIN = 1
}

function PvpRewardModel:ctor()
	self.reBattleInfo = nil
end

function PvpRewardModel:getEndTime()
	if pg.me.space == nil then
		return -1
	end

	return pg.me.space.end_ts
end

function PvpRewardModel:getBattleResult()
	local me = pg.me
	local res = {}

	for id, v in pairs(me.space.passerByMap) do
		if id == me.id then
			local rawInfo = v:getDisplayInfo()

			res.result = v.result[1]
			res.oldScore = v.result[2]
			res.addScore = v.result[3]
			res.name = rawInfo.name

			break
		end
	end

	return res
end

function PvpRewardModel:getPlayerStateList(uid, isAgain)
	if self.reBattleInfo == nil then
		self:initReBattleInfo()
	end

	if uid and isAgain ~= nil and self.reBattleInfo[uid] then
		self.reBattleInfo[uid].state = isAgain and self.RE_BATTLE_STATE.AGAIN or self.RE_BATTLE_STATE.BACK
	end

	local res = {}

	for _, v in pairs(self.reBattleInfo) do
		res[#res + 1] = v
	end

	return res
end

function PvpRewardModel:initReBattleInfo()
	local res = {}

	for id, v in pairs(pg.me.space.passerByMap) do
		local rawInfo = v:getDisplayInfo()
		local uid = pg.me.uid

		if id ~= pg.me.id then
			uid = pg.me.pvpRivalUid
		end

		res[uid] = {
			uid = uid,
			state = self.RE_BATTLE_STATE.NONE,
			name = rawInfo.name
		}
	end

	self.reBattleInfo = res
end

function PvpRewardModel:clearPVPData()
	self.reBattleInfo = nil
end

return PvpRewardModel
