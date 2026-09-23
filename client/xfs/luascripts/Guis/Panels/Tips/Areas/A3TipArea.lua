-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\A3TipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local A3TipArea = Class.LightClass("A3TipArea", BaseTipArea)
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local HOME_SEASON_CELEBRATION_ITEM = "HomeSeasonCelebration"

function A3TipArea:onCtor(info)
	return
end

function A3TipArea:onRefreshAreaVisible()
	local hide = #self.hideFlags > 0

	if hide and table.contains(self.hideFlags, TipAreaConst.UITipAreaFlag.AreaFlag_FullScreen) then
		hide = false
	end

	local isVisible = not hide

	if isVisible ~= self.visible and NotNil(self.uWidget) then
		self.uWidget:SetActive(isVisible)
		self:setAreaItemVisible(isVisible)
	end

	self.visible = isVisible
end

function A3TipArea:onRunStateChanged(isRun)
	local a1Area = self.owner:getAreaWithType(TipAreaConst.AREAS.A1)

	if a1Area == nil or not a1Area:checkHasItem(HOME_SEASON_CELEBRATION_ITEM) then
		return
	end

	local item = a1Area:tryGetItem(HOME_SEASON_CELEBRATION_ITEM)

	item:setAreaHideFlag(TipAreaConst.UITipAreaFlag.AreaFlag_A3Show, isRun)
end

return A3TipArea
