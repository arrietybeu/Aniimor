-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritMain\\PetInheritMainView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritMainView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetInheritMainView = Class.LightClass("PetInheritMainView", UIView)

function PetInheritMainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.imgPetLeftURawImage = objectReference:GetRefValue("imgPetLeftURawImage")
	self.imgPetRightURawImage = objectReference:GetRefValue("imgPetRightURawImage")
	self.leftBottomUWidget = objectReference:GetRefValue("leftBottomUWidget")
	self.rightBottomUWidget = objectReference:GetRefValue("rightBottomUWidget")
	self.petInfoLeftUComponent = objectReference:GetRefValue("petInfoLeftUComponent")
	self.petInfoRightUComponent = objectReference:GetRefValue("petInfoRightUComponent")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	self.titleTMPUSDFText = objectReference:GetRefValue("titleTMPUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnConfirmTxtNameUSDFText = objectReference:GetRefValue("btnConfirmTxtNameUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnChooseUButton = objectReference:GetRefValue("btnChooseUButton")
	self.chooseTxtNameUSDFText = objectReference:GetRefValue("chooseTxtNameUSDFText")
	self.txtBroadcastUSDFText = objectReference:GetRefValue("txtBroadcastUSDFText")
end

function PetInheritMainView:registerObjects()
	return
end

function PetInheritMainView:initView()
	return
end

return PetInheritMainView
