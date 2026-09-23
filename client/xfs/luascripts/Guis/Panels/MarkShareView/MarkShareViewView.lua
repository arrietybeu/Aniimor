-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareView\\MarkShareViewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MarkShareViewView = Class.LightClass("MarkShareViewView", UIView)

function MarkShareViewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.objectReference = objectReference
	self.root = objectReference:GetRefValue("root")
	self.btnClose1UButton = objectReference:GetRefValue("btnClose1UButton")
	self.btnClose2UButton = objectReference:GetRefValue("btnClose2UButton")
	self.btnClose3UButton = objectReference:GetRefValue("btnClose3UButton")
	self.presetLikeBtn = objectReference:GetRefValue("presetLikeBtn")
	self.presetLikeNum = objectReference:GetRefValue("presetLikeNum")
	self.concatText = objectReference:GetRefValue("concatText")
	self.selfLikeNum = objectReference:GetRefValue("selfLikeNum")
	self.otherPlayerLikeBtn = objectReference:GetRefValue("otherPlayerLikeBtn")
	self.otherPlayerLikeNum = objectReference:GetRefValue("otherPlayerLikeNum")
	self.btnPositionUButton = objectReference:GetRefValue("btnPositionUButton")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.listContentUList = objectReference:GetRefValue("listContentUList")
	self.particleUWidget = objectReference:GetRefValue("particleUWidget")
	self.particle1UWidget = objectReference:GetRefValue("particle1UWidget")
	self.panelAnimation = objectReference:GetRefValue("panelAnimation")
	self.btnLikedKeyBindingPro1 = objectReference:GetRefValue("btnLikedKeyBindingPro1")
	self.btnLikedKeyBindingPro2 = objectReference:GetRefValue("btnLikedKeyBindingPro2")
	self.keyEscHotKeyContent = objectReference:GetRefValue("keyEscHotKeyContent")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtTitle1USDFText = objectReference:GetRefValue("txtTitle1USDFText")
	self.likeKeyHotKeyContent = objectReference:GetRefValue("likeKeyHotKeyContent")
	self.backKeyHotKeyContent = objectReference:GetRefValue("backKeyHotKeyContent")
	self.otherLikedBtnHotKeyContent = objectReference:GetRefValue("otherLikedBtnHotKeyContent")
	self.otherBackBtnHotKeyContent = objectReference:GetRefValue("otherBackBtnHotKeyContent")
	self.templateUWidget = objectReference:GetRefValue("templateUWidget")
	self.onlineIDImage = objectReference:GetRefValue("onlineIDImage")
	self.onlineIDText = objectReference:GetRefValue("onlineIDText")
	self.txtIDUSDFText = objectReference:GetRefValue("txtIDUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnReportUButton = objectReference:GetRefValue("btnReportUButton")
	self.textReportUSDFText = objectReference:GetRefValue("textReportUSDFText")
end

function MarkShareViewView:initView()
	return
end

return MarkShareViewView
