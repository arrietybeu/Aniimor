-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonPetTip\\CommonPetTipView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonPetTipView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonPetTipView = Class.LightClass("CommonPetTipView", UIView)

function CommonPetTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.iconPetUImage = self.objectReference:GetRefValue("iconPetUImage")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.txtOrientationUSDFText = self.objectReference:GetRefValue("txtOrientationUSDFText")
	self.txtContentUSDFText = self.objectReference:GetRefValue("txtContentUSDFText")
	self.elementUButton = self.objectReference:GetRefValue("elementUButton")
	self.rootCmp = self.transform:GetComponent("UPopupForm")
end

function CommonPetTipView:registerObjects()
	return
end

function CommonPetTipView:initView()
	return
end

return CommonPetTipView
