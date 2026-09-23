-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCropDetail\\HomelandCollectionCropDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandCollectionCropDetailView = Class.LightClass("HomelandCollectionCropDetailView", UIView)

function HomelandCollectionCropDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.listUList = objectReference:GetRefValue("listUList")
end

function HomelandCollectionCropDetailView:registerObjects()
	return
end

function HomelandCollectionCropDetailView:initView()
	return
end

return HomelandCollectionCropDetailView
