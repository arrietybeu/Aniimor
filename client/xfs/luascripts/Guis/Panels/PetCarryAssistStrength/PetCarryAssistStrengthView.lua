-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrength\\PetCarryAssistStrengthView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryAssistStrengthView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetCarryAssistStrengthView = Class.LightClass("PetCarryAssistStrengthView", UIView)

function PetCarryAssistStrengthView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBack = objectReference:GetRefValue("btnBack")
	self.listSelectItem = objectReference:GetRefValue("listSelectItem")
	self.jewelResultUComponent = objectReference:GetRefValue("jewelResultUComponent")
	self.btnCompound = objectReference:GetRefValue("btnCompound")
	self.txtAddInfo = objectReference:GetRefValue("txtAddInfo")
	self.btnFastAdd = objectReference:GetRefValue("btnFastAdd")
	self.btnDesc = objectReference:GetRefValue("btnDesc")
	self.txtResult = objectReference:GetRefValue("txtResult")
	self.listTab = objectReference:GetRefValue("listTab")
	self.selectPanel = objectReference:GetRefValue("selectPanel")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.txtCompoundName = objectReference:GetRefValue("txtCompoundName")
	self.txtFastAddName = objectReference:GetRefValue("txtFastAddName")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.txtEmpty = objectReference:GetRefValue("txtEmpty")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.btnToGetUButton = objectReference:GetRefValue("btnToGetUButton")
	self.btnToGetTxtNameUSDFText = objectReference:GetRefValue("btnToGetTxtNameUSDFText")
	self.txtToGetUSDFText = objectReference:GetRefValue("txtToGetUSDFText")
end

function PetCarryAssistStrengthView:registerObjects()
	return
end

function PetCarryAssistStrengthView:initView()
	return
end

return PetCarryAssistStrengthView
