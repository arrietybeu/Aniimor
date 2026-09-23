-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetProperty\\PetPropertyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetPropertyView = Class.LightClass("PetPropertyView", UIView)

function PetPropertyView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")

	local bgBlurTransform = self.transform:Find("Blur/BgBlur")

	self.bgBlurUIBlurEffect = bgBlurTransform and bgBlurTransform:GetComponent("UIBlurEffect")
end

function PetPropertyView:initView()
	return
end

return PetPropertyView
