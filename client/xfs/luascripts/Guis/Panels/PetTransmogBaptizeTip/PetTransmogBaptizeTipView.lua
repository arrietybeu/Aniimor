-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogBaptizeTip\\PetTransmogBaptizeTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetTransmogBaptizeTipView = Class.LightClass("PetTransmogBaptizeTipView", UIView)

function PetTransmogBaptizeTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.desUSDFText = self.objectReference:GetRefValue("desUSDFText")
	self.txtAddUSDFText = self.objectReference:GetRefValue("txtAddUSDFText")
end

function PetTransmogBaptizeTipView:registerObjects()
	return
end

function PetTransmogBaptizeTipView:initView()
	ClientTextUtils.setText(self.txtAddUSDFText, pg.getGameString("PETTRANSMOGRIFY_LOCKED"))
end

return PetTransmogBaptizeTipView
