-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchAddPPoint\\PetRecommendBatchAddPPointView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchAddPPointView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetRecommendBatchAddPPointView = Class.LightClass("PetRecommendBatchAddPPointView", UIView)

function PetRecommendBatchAddPPointView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnCloseUButton2 = objectReference:GetRefValue("btnCloseUButton2")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
end

function PetRecommendBatchAddPPointView:registerObjects()
	return
end

function PetRecommendBatchAddPPointView:initView()
	return
end

return PetRecommendBatchAddPPointView
