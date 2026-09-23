-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGift\\FriendGiftView.lua

local logger = require("Core.Log.LoggerManager").getLogger("FriendGiftView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendGiftView = Class.LightClass("FriendGiftView", UIView)

function FriendGiftView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.giftIconUImage = objectReference:GetRefValue("giftIconUImage")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.btnUButton = objectReference:GetRefValue("btnUButton")
	self.giftlistUList = objectReference:GetRefValue("giftlistUList")
	self.txtTltleUSDFText = objectReference:GetRefValue("txtTltleUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.textGiveUSDFText = objectReference:GetRefValue("textGiveUSDFText")
	self.textTipsUSDFText = objectReference:GetRefValue("textTipsUSDFText")

	local btnObjectReference = self.btnUButton and self.btnUButton:GetComponent("ObjectReference")

	self.txtNameUText = LuaUIUtils.safeGetRefValue(btnObjectReference, "txtNameUText")
	self.lockUImage = LuaUIUtils.safeGetRefValue(btnObjectReference, "lockUImage")
	self.keyHotKeyContent = LuaUIUtils.safeGetRefValue(btnObjectReference, "keyHotKeyContent")
end

function FriendGiftView:registerObjects()
	return
end

function FriendGiftView:initView()
	return
end

return FriendGiftView
