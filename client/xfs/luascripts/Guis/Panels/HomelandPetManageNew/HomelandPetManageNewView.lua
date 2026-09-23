-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManageNew\\HomelandPetManageNewView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandPetManageNewView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandPetManageNewView = Class.LightClass("HomelandPetManageNewView", UIView)

function HomelandPetManageNewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.tabPetUContainer = objectReference:GetRefValue("tabPetUContainer")
	self.petInfoUContainer = objectReference:GetRefValue("petInfoUContainer")
	self.tabFoodUWidget = objectReference:GetRefValue("tabFoodUWidget")
	self.btnFoodUButton = objectReference:GetRefValue("btnFoodUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnPetUButton = objectReference:GetRefValue("btnPetUButton")
	self.listMainTabUList = objectReference:GetRefValue("listMainTabUList")
	self.legacyMainTabUWidget = objectReference:GetRefValue("legacyMainTabUWidget")
	self.txtPetTabUSDFText = objectReference:GetRefValue("txtPetTabUSDFText")
	self.txtFoodTabUSDFText = objectReference:GetRefValue("txtFoodTabUSDFText")
end

function HomelandPetManageNewView:registerObjects()
	return
end

function HomelandPetManageNewView:initView()
	return
end

return HomelandPetManageNewView
