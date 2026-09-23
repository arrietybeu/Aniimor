-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\A1TipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local A1TipArea = Class.LightClass("A1TipArea", BaseTipArea)
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local HOME_SEASON_CELEBRATION_ITEM = "HomeSeasonCelebration"

function A1TipArea:onCtor(info)
	return
end

function A1TipArea:isOnlyHomeSeasonCelebrationRunning()
	if #self.tmpFrame == 0 then
		return false
	end

	for _, item in ipairs(self.tmpFrame) do
		if item.itemKey ~= HOME_SEASON_CELEBRATION_ITEM then
			return false
		end
	end

	return true
end

function A1TipArea:onRunStateChanged(isRun)
	local topVisible = not isRun

	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.TOP, TipAreaConst.UITipAreaFlag.AreaFlag_A1Show, topVisible)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.A2, TipAreaConst.UITipAreaFlag.AreaFlag_A1Show, topVisible)

	local a3Visible = topVisible or self:isOnlyHomeSeasonCelebrationRunning()

	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.A3, TipAreaConst.UITipAreaFlag.AreaFlag_A1Show, a3Visible)
end

return A1TipArea
