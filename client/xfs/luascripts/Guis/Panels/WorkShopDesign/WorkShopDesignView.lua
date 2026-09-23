-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\WorkShopDesignView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local WorkShopDesignView = Class.LightClass("WorkShopDesignView", UIView)

function WorkShopDesignView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.tabList = self.objectReference:GetRefValue("tabList")
	self.subItemList = self.objectReference:GetRefValue("subItemList")
	self.btnStain = self.objectReference:GetRefValue("btnStain")
	self.btnCut = self.objectReference:GetRefValue("btnCut")
	self.btnPattern = self.objectReference:GetRefValue("btnPattern")
	self.btnFabric = self.objectReference:GetRefValue("btnFabric")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.hairDyeUButton = self.objectReference:GetRefValue("hairDyeUButton")
	self.hairBoneUButton = self.objectReference:GetRefValue("hairBoneUButton")
	self.leftPanelTransform = self.objectReference:GetRefValue("leftPanelTransform")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.backgroundSelectorUSelector = self.objectReference:GetRefValue("backgroundSelectorUSelector")
	self.leftLayoutBoxUWidget = self.objectReference:GetRefValue("leftLayoutBoxUWidget")
	self.btnHairTieUButton = self.objectReference:GetRefValue("btnHairTieUButton")
end

function WorkShopDesignView:registerObjects()
	return
end

function WorkShopDesignView:initView()
	return
end

return WorkShopDesignView
