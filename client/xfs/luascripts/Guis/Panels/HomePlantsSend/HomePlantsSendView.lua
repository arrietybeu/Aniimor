-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsSend\\HomePlantsSendView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsSendView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomePlantsSendView = Class.LightClass("HomePlantsSendView", UIView)

function HomePlantsSendView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")

	local confirmObjectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtConfirmUText = confirmObjectReference:GetRefValue("txtNameUText")
	self.uIPbChatFriendlPopupUComponent = objectReference:GetRefValue("uIPbChatFriendlPopupUComponent")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.groupChatListUList = objectReference:GetRefValue("groupChatListUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.emptyTipUSDFText = objectReference:GetRefValue("emptyTipUSDFText")
	self.createTipUSDFText = objectReference:GetRefValue("createTipUSDFText")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.inputHolderUSDFText = objectReference:GetRefValue("inputHolderUSDFText")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function HomePlantsSendView:registerObjects()
	return
end

function HomePlantsSendView:initView()
	return
end

return HomePlantsSendView
