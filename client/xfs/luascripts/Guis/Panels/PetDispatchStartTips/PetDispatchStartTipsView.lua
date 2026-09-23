-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchStartTips\\PetDispatchStartTipsView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetDispatchStartTipsView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetDispatchStartTipsView = Class.LightClass("PetDispatchStartTipsView", UIView)

function PetDispatchStartTipsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.textDetail = objectReference:GetRefValue("textDetail")
	self.listPetSelectUList = objectReference:GetRefValue("listPetSelectUList")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.txtBtnBack = objectReference:GetRefValue("txtBtnBack")
end

function PetDispatchStartTipsView:registerObjects()
	return
end

function PetDispatchStartTipsView:initView()
	return
end

return PetDispatchStartTipsView
