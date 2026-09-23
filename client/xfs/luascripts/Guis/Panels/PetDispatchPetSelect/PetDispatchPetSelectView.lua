-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchPetSelect\\PetDispatchPetSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetDispatchPetSelectView = Class.LightClass("PetDispatchPetSelectView", UIView)

function PetDispatchPetSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.btnRoot = objectReference:GetRefValue("btnRoot")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.textForm = objectReference:GetRefValue("textForm")
	self.textSelectTitle = objectReference:GetRefValue("textSelectTitle")
	self.textCondition = objectReference:GetRefValue("textCondition")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmpty = objectReference:GetRefValue("txtEmpty")
	self.btnFilter = objectReference:GetRefValue("btnFilter")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function PetDispatchPetSelectView:registerObjects()
	return
end

function PetDispatchPetSelectView:initView()
	return
end

return PetDispatchPetSelectView
