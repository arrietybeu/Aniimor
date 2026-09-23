-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CnAgeRating\\CnAgeRatingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CnAgeRatingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CnAgeRatingView = Class.LightClass("CnAgeRatingView", UIView)

function CnAgeRatingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.scrollRect = self.objectReference:GetRefValue("scrollRect")
end

function CnAgeRatingView:registerObjects()
	return
end

function CnAgeRatingView:initView()
	return
end

return CnAgeRatingView
