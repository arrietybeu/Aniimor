-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuideMode\\GuideModeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GuideModeView = Class.LightClass("GuideModeView", UIView)

function GuideModeView:findObjects()
	return
end

function GuideModeView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.imgPicUImage = objectReference:GetRefValue("imgPicUImage")
	self.txtDetailsUBaseText = objectReference:GetRefValue("txtDetailsUBaseText")
	self.btnNextUButton = objectReference:GetRefValue("btnNextUButton")
	self.btnStartUButton = objectReference:GetRefValue("btnStartUButton")
	self.rootCom = objectReference:GetRefValue("rootCom")
	self.videoPlayer = objectReference:GetRefValue("videoPlayerPVideoImage")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.modeTitle = objectReference:GetRefValue("modeTitle")
	self.txtSamllTitle = objectReference:GetRefValue("txtSamllTitle")
	self.txtBackName = objectReference:GetRefValue("txtBackName")
	self.txtNextName = objectReference:GetRefValue("txtNextName")
	self.txtConfirmName = objectReference:GetRefValue("txtConfirmName")
	self.txtTips = objectReference:GetRefValue("txtTips")
end

local leftTabComs = {}

function GuideModeView:getTabItemComs(btn)
	if leftTabComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		leftTabComs[btn] = {}
		leftTabComs[btn].name = objectReference:GetRefValue("name")
		leftTabComs[btn].recommend = objectReference:GetRefValue("recommendUWidget")
	end

	return leftTabComs[btn]
end

function GuideModeView:initView()
	return
end

function GuideModeView:onDestroy()
	for k in next, leftTabComs do
		leftTabComs[k] = nil
	end
end

return GuideModeView
