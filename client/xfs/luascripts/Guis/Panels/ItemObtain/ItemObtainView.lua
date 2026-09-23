-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemObtain\\ItemObtainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ItemObtainView = Class.LightClass("ItemObtainView", UIView)

function ItemObtainView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.animRoot = self.objectReference:GetRefValue("animRoot")
	self.itemList = self.objectReference:GetRefValue("itemList")
	self.closeBtn = self.objectReference:GetRefValue("closeBtn")
	self.btnCloseConsoleUButton = self.objectReference:GetRefValue("btnCloseConsoleUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.txtTipsUBaseText = self.objectReference:GetRefValue("txtTipsUBaseText")
	self.txtName1UBaseText = self.objectReference:GetRefValue("txtName1UBaseText")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.lightContentUWidget = self.objectReference:GetRefValue("lightContentUContainer")

	self.lightContentUWidget:LoadDefaultUrlManually()

	self.doubleRewardUWidget = self.objectReference:GetRefValue("doubleRewardUWidget")
	self.rankSignUContainer = self.objectReference:GetRefValue("rankSign")
	self.timeUWidget = self.objectReference:GetRefValue("timeUWidget")
	self.txtDownUBaseText = self.objectReference:GetRefValue("txtDown")
end

function ItemObtainView:registerObjects()
	return
end

function ItemObtainView:initView()
	return
end

return ItemObtainView
