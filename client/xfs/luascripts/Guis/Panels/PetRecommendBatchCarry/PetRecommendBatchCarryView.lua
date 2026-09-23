-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchCarry\\PetRecommendBatchCarryView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchCarryView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetRecommendBatchCarryView = Class.LightClass("PetRecommendBatchCarryView", UIView)

function PetRecommendBatchCarryView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnCloseUButton2 = objectReference:GetRefValue("btnCloseUButton2")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.contentUWidget = objectReference:GetRefValue("contentUWidget")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.txtEmptyBtnUSDFText = objectReference:GetRefValue("txtEmptyBtnUSDFText")
	self.btnGoToUButton = objectReference:GetRefValue("btnGoToUButton")
end

function PetRecommendBatchCarryView:registerObjects()
	return
end

function PetRecommendBatchCarryView:initView()
	return
end

return PetRecommendBatchCarryView
