-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PropSelectCom\\PropSelectComView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PropSelectComView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PropSelectComView = Class.LightClass("PropSelectComView", UIView)

function PropSelectComView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listPropUList = objectReference:GetRefValue("listPropUList")
	self.itemSelUButton = objectReference:GetRefValue("itemSelUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.itemName = objectReference:GetRefValue("itemName")
	self.itemDesc = objectReference:GetRefValue("itemDesc")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnClose2 = objectReference:GetRefValue("btnClose2")
	self.layoutConsumeULayoutBox = objectReference:GetRefValue("layoutConsumeULayoutBox")
	self.costCountTxt = objectReference:GetRefValue("costCountTxt")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
end

function PropSelectComView:registerObjects()
	return
end

function PropSelectComView:initView()
	self.widget:TryChangePage("Quality", 1)
end

return PropSelectComView
