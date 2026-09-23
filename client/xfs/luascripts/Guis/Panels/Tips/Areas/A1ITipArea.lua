-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\A1ITipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local A1ITipArea = Class.LightClass("A1ITipArea", BaseTipArea)

function A1ITipArea:onCtor(info)
	return
end

function A1ITipArea:findObjects()
	return
end

function A1ITipArea:onRunStateChanged(isRun)
	local topVisible = not isRun

	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.TOP, TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow, topVisible)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.A1, TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow, topVisible)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.A2, TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow, topVisible)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.A3, TipAreaConst.UITipAreaFlag.AreaFlag_A1IShow, topVisible)
end

return A1ITipArea
