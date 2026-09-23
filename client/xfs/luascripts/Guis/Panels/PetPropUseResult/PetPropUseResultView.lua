-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetPropUseResult\\PetPropUseResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetPropUseResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetPropUseResultView = Class.LightClass("PetPropUseResultView", UIView)

function PetPropUseResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.imgPet = self.objectReference:GetRefValue("imgPet")
	self.txtLevel = self.objectReference:GetRefValue("txtLevel")
	self.btnFeatures1 = self.objectReference:GetRefValue("btnFeatures1")
	self.btnFeatures2 = self.objectReference:GetRefValue("btnFeatures2")
	self.listAttri = self.objectReference:GetRefValue("listAttri")
	self.txtFeaturesName1 = self.objectReference:GetRefValue("txtFeaturesName1")
	self.txtFeaturesName2 = self.objectReference:GetRefValue("txtFeaturesName2")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function PetPropUseResultView:registerObjects()
	return
end

function PetPropUseResultView:initView()
	return
end

return PetPropUseResultView
