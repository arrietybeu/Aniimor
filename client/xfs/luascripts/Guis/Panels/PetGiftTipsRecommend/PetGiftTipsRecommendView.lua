-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetGiftTipsRecommend\\PetGiftTipsRecommendView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetGiftTipsRecommendView = Class.LightClass("PetGiftTipsRecommendView", UIView)

function PetGiftTipsRecommendView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
end

function PetGiftTipsRecommendView:registerObjects()
	return
end

function PetGiftTipsRecommendView:initView()
	return
end

return PetGiftTipsRecommendView
