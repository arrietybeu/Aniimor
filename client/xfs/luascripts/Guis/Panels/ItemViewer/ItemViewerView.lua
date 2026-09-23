-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemViewer\\ItemViewerView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ItemViewerView = Class.LightClass("ItemViewerView", UIView)

function ItemViewerView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnPre = self.objectReference:GetRefValue("btnPre")
	self.btnNext = self.objectReference:GetRefValue("btnNext")
	self.dotList = self.objectReference:GetRefValue("dotList")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.modelRawImage = self.objectReference:GetRefValue("modelRawImage")
	self.imgPic = self.objectReference:GetRefValue("imgPic")
	self.btnSwitch = self.objectReference:GetRefValue("btnSwitch")
	self.container = self.objectReference:GetRefValue("container")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.txtScroll = self.objectReference:GetRefValue("txtScroll")
	self.picRect = self.objectReference:GetRefValue("picRect")
	self.btnFinish = self.objectReference:GetRefValue("btnFinish")
	self.imgBg = self.objectReference:GetRefValue("imgBg")
	self.officialAccountUContainer = self.objectReference:GetRefValue("officialAccountUContainer")
	self.bgBlurUIBlurEffect = self.objectReference:GetRefValue("bgBlurUIBlurEffect")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function ItemViewerView:registerObjects()
	return
end

function ItemViewerView:initView()
	self.officialAccountUContainer:LoadDefaultUrlManually()

	self.officialAccountObjectReference = self.officialAccountUContainer.content:GetComponent("ObjectReference")
	self.officialAccountUScrollRect = self.officialAccountObjectReference:GetRefValue("officialAccountUScrollRect")

	local officialAccountContentObjectReference = self.officialAccountUScrollRect.content:GetComponent("ObjectReference")

	self.mode5TitleUBaseText = officialAccountContentObjectReference:GetRefValue("mode5TitleUBaseText")
	self.mode5NameUBaseText = officialAccountContentObjectReference:GetRefValue("mode5NameUBaseText")
	self.mode5DateUBaseText = officialAccountContentObjectReference:GetRefValue("mode5DateUBaseText")
	self.mode5ContentUList = officialAccountContentObjectReference:GetRefValue("mode5ContentUList")
end

return ItemViewerView
