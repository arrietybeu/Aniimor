-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelectFilter\\GrowthGiftSelectFilterView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrowthGiftSelectFilterView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrowthGiftSelectFilterView = Class.LightClass("GrowthGiftSelectFilterView", UIView)

function GrowthGiftSelectFilterView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.filterList = objectReference:GetRefValue("filterList")
	self.cleanBtn = objectReference:GetRefValue("cleanBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.root = objectReference:GetRefValue("root")
	self.txtType = objectReference:GetRefValue("txtType")
end

function GrowthGiftSelectFilterView:registerObjects()
	return
end

function GrowthGiftSelectFilterView:initView()
	return
end

return GrowthGiftSelectFilterView
