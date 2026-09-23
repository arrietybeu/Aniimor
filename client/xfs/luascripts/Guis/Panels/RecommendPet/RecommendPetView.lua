-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RecommendPet\\RecommendPetView.lua

local logger = require("Core.Log.LoggerManager").getLogger("RecommendPetView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RecommendPetView = Class.LightClass("RecommendPetView", UIView)

function RecommendPetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.popUpObjectReference = objectReference:GetRefValue("popUpObjectReference")
	self.titleText = self.popUpObjectReference:GetRefValue("titleText")
	self.rightUpCornerCloseBtn = self.popUpObjectReference:GetRefValue("rightUpCornerCloseBtn")
	self.cancelBtn = self.popUpObjectReference:GetRefValue("cancelBtn")
	self.confirmBtn = self.popUpObjectReference:GetRefValue("confirmBtn")
	self.elementUList = self.popUpObjectReference:GetRefValue("elementUList")
	self.petUList = self.popUpObjectReference:GetRefValue("petUList")
end

function RecommendPetView:registerObjects()
	return
end

function RecommendPetView:initView()
	return
end

return RecommendPetView
