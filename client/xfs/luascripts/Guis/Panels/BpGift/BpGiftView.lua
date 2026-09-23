-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpGift\\BpGiftView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpGiftView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpGiftView = Class.LightClass("BpGiftView", UIView)

function BpGiftView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBGClose = objectReference:GetRefValue("btnBGClose")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.txtSendBtn = objectReference:GetRefValue("txtSendBtn")
end

function BpGiftView:registerObjects()
	return
end

function BpGiftView:initView()
	return
end

return BpGiftView
