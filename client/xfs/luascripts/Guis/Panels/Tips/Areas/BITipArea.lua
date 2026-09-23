-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\BITipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local BITipArea = Class.LightClass("BITipArea", BaseTipArea)

function BITipArea:onCtor(info)
	return
end

function BITipArea:onRunStateChanged(isRun)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.B, TipAreaConst.UITipAreaFlag.AreaFlag_BIShow, not isRun)
end

return BITipArea
