-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuidePopupPanel\\GuidePopupPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GuidePopupPanelView = Class.LightClass("GuidePopupPanelView", UIView)

function GuidePopupPanelView:findObjects()
	return
end

function GuidePopupPanelView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.closeBtn = objectReference:GetRefValue("btnCloseUButton")
	self.titleUText = objectReference:GetRefValue("txtTitleUText")
	self.txtScrollRect = objectReference:GetRefValue("txtScrollRect")
	self.contentUText = objectReference:GetRefValue("contentTxt")
	self.picUImage = objectReference:GetRefValue("picUImage")
	self.videoPlayer = objectReference:GetRefValue("videoPlayer")

	local hotKeyOR = objectReference:GetRefValue("hotKeyOR")

	self.hotKeyContent = hotKeyOR:GetRefValue("keyHotKeyContent")
	self.btnTipsUText = hotKeyOR:GetRefValue("btnTipsUText")
	self.mainCom = objectReference:GetRefValue("mainCom")
	self.leftProgress = objectReference:GetRefValue("leftProgress")
	self.rightProgress = objectReference:GetRefValue("rightProgress")
	self.skipNode = objectReference:GetRefValue("skipNode")
end

function GuidePopupPanelView:initView()
	return
end

return GuidePopupPanelView
