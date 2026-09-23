-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerAssess\\PlayerAssessModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerAssessModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PlayerAssessModel = Class.LightClass("PlayerAssessModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")

function PlayerAssessModel:getAssessInfo(finishAssess)
	local res = {}

	res.star = LuaUIUtils.getPlayerStar()
	res.starName = LuaUIUtils.getStarTitleNameForIcon(res.star)
	res.fullStarName = LuaUIUtils.getStarTitleName(res.star, true)
	res.nextStar = res.star + 1
	res.assessStar = finishAssess and res.star or res.nextStar
	res.nextStarName = LuaUIUtils.getStarTitleNameForIcon(res.nextStar)
	res.fullNextStarName = LuaUIUtils.getStarTitleName(res.nextStar, true)
	res.matchTime = Utils.checkUPStarTimeMatch(res.star)
	res.icon = LuaUIUtils.getStarIcon(res.star)
	res.nextIcon = LuaUIUtils.getStarIcon(res.nextStar)

	if not res.matchTime then
		local formatTime = pg.getGameString("ASSESS_WILL_OPEN_IN_MATCH_TIME")
		local resTime = pg.getFormatText(formatTime, Utils.getUPStarFormatTime(res.nextStar))

		res.unlockTimeFormat = resTime
	end

	pg.global.ui.playerLvReward.model:parseStarReward(res)

	return res
end

return PlayerAssessModel
