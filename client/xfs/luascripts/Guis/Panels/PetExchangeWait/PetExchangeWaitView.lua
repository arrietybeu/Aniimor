-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetExchangeWait\\PetExchangeWaitView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetExchangeWaitView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetExchangeWaitView = Class.LightClass("PetExchangeWaitView", UIView)

function PetExchangeWaitView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.costTimesUBaseText = self.objectReference:GetRefValue("costTimesUBaseText")
	self.imgPetLeftURawImage = self.objectReference:GetRefValue("imgPetLeftURawImage")
	self.imgPetRightURawImage = self.objectReference:GetRefValue("imgPetRightURawImage")
	self.leftBottomUWidget = self.objectReference:GetRefValue("leftBottomUWidget")
	self.rightBottomUWidget = self.objectReference:GetRefValue("rightBottomUWidget")
	self.btnDetailsUButton = self.objectReference:GetRefValue("btnDetailsUButton")
	self.petInfoLeftUComponent = self.objectReference:GetRefValue("petInfoLeftUComponent")
	self.petInfoRightUComponent = self.objectReference:GetRefValue("petInfoRightUComponent")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.centerUWidget = self.objectReference:GetRefValue("centerUWidget")
	self.bottomUWidget = self.objectReference:GetRefValue("bottomUWidget")
	self.topPanelUWidget = self.objectReference:GetRefValue("topPanelUWidget")
	self.switchAniAnimation = self.objectReference:GetRefValue("switchAniAnimation")
	self.vXMeshAnimation = self.objectReference:GetRefValue("vXMeshAnimation")
	self.confirmUComponent = self.objectReference:GetRefValue("confirmUComponent")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.consumeUBaseText = self.objectReference:GetRefValue("consumeUBaseText")
	self.btnRulesUButton = self.objectReference:GetRefValue("btnRulesUButton")
	self.iconPropUImage = self.objectReference:GetRefValue("iconPropUImage")
	self.listTagLUList = self.objectReference:GetRefValue("listTagLUList")
	self.listTagRUList = self.objectReference:GetRefValue("listTagRUList")
	self.txtTimesUSDFText = self.objectReference:GetRefValue("txtTimesUSDFText")
	self.btnTalentLeftUButton = self.objectReference:GetRefValue("btnTalentLeftUButton")
	self.btnTalentRightUButton = self.objectReference:GetRefValue("btnTalentRightUButton")
	self.consumeExtraUBaseText = self.objectReference:GetRefValue("consumeExtraUBaseText")
	self.consumeExtraUWidget = self.objectReference:GetRefValue("consumeExtraUWidget")
end

function PetExchangeWaitView:registerObjects()
	return
end

function PetExchangeWaitView:initView()
	return
end

return PetExchangeWaitView
