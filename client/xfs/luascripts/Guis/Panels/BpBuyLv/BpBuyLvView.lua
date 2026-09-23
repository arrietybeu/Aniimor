-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpBuyLv\\BpBuyLvView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpBuyLvView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpBuyLvView = Class.LightClass("BpBuyLvView", UIView)

function BpBuyLvView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.txtBtnConfirm = objectReference:GetRefValue("txtBtnConfirm")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.txtBtnCancel = objectReference:GetRefValue("txtBtnCancel")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.numSelector = objectReference:GetRefValue("numSelector")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnBGClose = objectReference:GetRefValue("btnBGClose")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtLvUp = objectReference:GetRefValue("txtLvUp")
	self.txtGetTitle = objectReference:GetRefValue("txtGetTitle")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnArrow = objectReference:GetRefValue("btnArrow")
	self.txtGetExTitle = objectReference:GetRefValue("txtGetExTitle")
	self.listExUList = objectReference:GetRefValue("listExUList")
	self.imgCostIcon = objectReference:GetRefValue("imgCostIcon")
	self.txtCostNum = objectReference:GetRefValue("txtCostNum")
	self.txtGetTitle2 = objectReference:GetRefValue("txtGetTitle2")
	self.listUList2 = objectReference:GetRefValue("listUList2")
end

function BpBuyLvView:registerObjects()
	return
end

function BpBuyLvView:initView()
	return
end

return BpBuyLvView
