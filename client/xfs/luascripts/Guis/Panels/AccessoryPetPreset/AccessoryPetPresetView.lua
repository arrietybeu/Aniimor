-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetPreset\\AccessoryPetPresetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AccessoryPetPresetView = Class.LightClass("AccessoryPetPresetView", UIView)

function AccessoryPetPresetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.outfitUList = self.objectReference:GetRefValue("outfitUList")
	self.nameUInputField = self.objectReference:GetRefValue("nameUInputField")
	self.editUButton = self.objectReference:GetRefValue("editUButton")
	self.contentUList = self.objectReference:GetRefValue("contentUList")
	self.saveSuitUButton = self.objectReference:GetRefValue("saveSuitUButton")
	self.useSuitUWidget = self.objectReference:GetRefValue("useSuitUWidget")
	self.previousUList = self.objectReference:GetRefValue("previousUList")
	self.nextUList = self.objectReference:GetRefValue("nextUList")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.saveUButton = self.objectReference:GetRefValue("saveUButton")
	self.arrowUImage = self.objectReference:GetRefValue("arrowUImage")
	self.previousUText = self.objectReference:GetRefValue("previousUText")
	self.nextUText = self.objectReference:GetRefValue("nextUText")
	self.imgPet = self.objectReference:GetRefValue("imgPet")
	self.petClanTitle = self.objectReference:GetRefValue("petClanTitle")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.infoText = self.objectReference:GetRefValue("infoText")
end

function AccessoryPetPresetView:registerObjects()
	return
end

function AccessoryPetPresetView:initView()
	return
end

return AccessoryPetPresetView
