-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\CITipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local JoyStickDragRelay = require("Guis.Helper.JoyStickDragRelay")
local CITipArea = Class.LightClass("CITipArea", BaseTipArea)

function CITipArea:onCtor(info)
	return
end

function CITipArea:findObjects()
	return
end

function CITipArea:onInit()
	if NotNil(self.oc) then
		self.joyStickDragListener = JoyStickDragRelay.attach(self.oc.gameObject)
	end
end

function CITipArea:onDestroy()
	JoyStickDragRelay.detach(self.joyStickDragListener)

	self.joyStickDragListener = nil
end

function CITipArea:onRunStateChanged(isRun)
	local topVisible = not isRun

	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.CF, TipAreaConst.UITipAreaFlag.AreaFlag_CIShow, topVisible)
	self.owner:setAreaVisibleWithFlag(TipAreaConst.AREAS.C, TipAreaConst.UITipAreaFlag.AreaFlag_CIShow, topVisible)
	self.owner:clearAreaRunItems(TipAreaConst.AREAS.C)
end

return CITipArea
