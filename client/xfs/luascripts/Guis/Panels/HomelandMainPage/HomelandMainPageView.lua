-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandMainPage\\HomelandMainPageView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMainPageView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandMainPageView = Class.LightClass("HomelandMainPageView", UIView)

function HomelandMainPageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.textHomeNameUSDFText = objectReference:GetRefValue("textHomeNameUSDFText")
	self.btnEditUButton = objectReference:GetRefValue("btnEditUButton")
	self.textGoodUSDFText = objectReference:GetRefValue("textGoodUSDFText")
	self.textNumGoodUSDFText = objectReference:GetRefValue("textNumGoodUSDFText")
	self.textVisitUSDFText = objectReference:GetRefValue("textVisitUSDFText")
	self.listPlayerUList = objectReference:GetRefValue("listPlayerUList")
	self.btnUpGradeUButton = objectReference:GetRefValue("btnUpGradeUButton")
	self.txtUpgradeUSDFText = objectReference:GetRefValue("txtUpgradeUSDFText")
	self.btnCarDIYUButton = objectReference:GetRefValue("btnCarDIYUButton")
	self.txtCarUSDFText = objectReference:GetRefValue("txtCarUSDFText")
	self.btnShopUButton = objectReference:GetRefValue("btnShopUButton")
	self.txtShopUSDFText = objectReference:GetRefValue("txtShopUSDFText")
	self.btnCardUButton = objectReference:GetRefValue("btnCardUButton")
	self.txtCardNameUSDFText = objectReference:GetRefValue("txtCardNameUSDFText")
	self.txtCardNumUSDFText = objectReference:GetRefValue("txtCardNumUSDFText")
	self.btnGotoCampUButton = objectReference:GetRefValue("btnGotoCampUButton")
	self.txtCampNameUSDFText = objectReference:GetRefValue("txtCampNameUSDFText")
	self.txtCampIDUSDFText = objectReference:GetRefValue("txtCampIDUSDFText")
	self.btnGotoHomeUButton = objectReference:GetRefValue("btnGotoHomeUButton")
	self.txtHomeNameUSDFText = objectReference:GetRefValue("txtHomeNameUSDFText")
	self.textNoneUSDFText = objectReference:GetRefValue("textNoneUSDFText")
	self.uIPbHomeCampingCarMainUWidget = objectReference:GetRefValue("uIPbHomeCampingCarMainUWidget")
	self.vXClickLizUWidget = objectReference:GetRefValue("vXClickLizUWidget")
	self.btnLevelupUButton = objectReference:GetRefValue("btnLevelupUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnPetUButton = objectReference:GetRefValue("btnPetUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.txtNumLiveUSDFText = objectReference:GetRefValue("txtNumLiveUSDFText")
	self.btnLiveUButton = objectReference:GetRefValue("btnLiveUButton")
end

function HomelandMainPageView:registerObjects()
	return
end

function HomelandMainPageView:initView()
	return
end

return HomelandMainPageView
