-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BadgeDetail\\BadgeDetailModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BadgeDetailModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local Const = require("Common.Const.Const")
local PlayerBadgeData = require("Data.player_badge_data")
local BadgeDetailModel = Class.LightClass("BadgeDetailModel", UIModel)

function BadgeDetailModel:initData(groupId, badgeId, isOtherPlayer)
	if isOtherPlayer == true then
		local cfgData = PlayerBadgeData[badgeId]

		self.data = {
			{
				process = 1,
				index = 1,
				badgeId = badgeId,
				badgeState = Const.BADGE_STATUS.Complete,
				quality = cfgData.quality
			}
		}
	else
		self.data = BadgeUtils.getAllBadgeByGroupId(groupId)
	end

	self.curIndex = 1
	self.maxIndex = #self.data

	if badgeId and badgeId > 0 then
		for k, v in ipairs(self.data) do
			if v.badgeId == badgeId then
				self.curIndex = k

				return
			end
		end
	end

	for k, v in ipairs(self.data) do
		if v.badgeState < Const.BADGE_STATUS.Complete then
			return
		end

		self.curIndex = k
	end
end

function BadgeDetailModel.getEntryData(cfgData)
	return BadgeUtils.getEntryData(cfgData)
end

return BadgeDetailModel
