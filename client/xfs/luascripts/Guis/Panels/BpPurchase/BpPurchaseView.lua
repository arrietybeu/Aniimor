-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpPurchase\\BpPurchaseView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpPurchaseView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpPurchaseView = Class.LightClass("BpPurchaseView", UIView)

function BpPurchaseView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.txtBackName = objectReference:GetRefValue("txtBackName")
	self.maskRayBoxTrans = objectReference:GetRefValue("maskRayBoxTrans")
	self.moneyListUButton = objectReference:GetRefValue("moneyListUButton")
end

function BpPurchaseView:registerObjects()
	return
end

function BpPurchaseView:initView()
	return
end

return BpPurchaseView
