-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpExchange\\BpExchangeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpExchangeView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BpExchangeView = Class.LightClass("BpExchangeView", UIView)

function BpExchangeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.productInformationUComponent = objectReference:GetRefValue("productInformationUComponent")
	self.propInfoUContainer = objectReference:GetRefValue("propInfoUContainer")
	self.btnGiftUButton = objectReference:GetRefValue("btnGiftUButton")
	self.playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	self.avatarBgUImage = objectReference:GetRefValue("avatarBgUImage")
	self.avatarUImage = objectReference:GetRefValue("avatarUImage")
	self.avatarFrameUImage = objectReference:GetRefValue("avatarFrameUImage")
	self.panelPlayerUWidget = objectReference:GetRefValue("panelPlayerUWidget")
	self.chatBubbleUWidget = objectReference:GetRefValue("chatBubbleUWidget")
	self.playerBgUImage = objectReference:GetRefValue("playerBgUImage")
	self.uIDUBaseText = objectReference:GetRefValue("uIDUBaseText")
	self.classInfoUBaseText = objectReference:GetRefValue("classInfoUBaseText")
	self.avatarUImage2 = objectReference:GetRefValue("avatarUImage2")
	self.avatarFrameUImage2 = objectReference:GetRefValue("avatarFrameUImage2")
	self.txtPlayerLv = objectReference:GetRefValue("txtPlayerLv")
	self.playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	self.playerSignUBaseText = objectReference:GetRefValue("playerSignUBaseText")
	self.imgGenderUImage = objectReference:GetRefValue("imgGenderUImage")
	self.avatarBgUImage2 = objectReference:GetRefValue("avatarBgUImage2")
	self.chatBgUImage = objectReference:GetRefValue("chatBgUImage")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	self.btnAvatarDisplayUButton = objectReference:GetRefValue("btnAvatarDisplayUButton")
	self.btnFilter = objectReference:GetRefValue("btnFilter")
	self.btnEllipses = objectReference:GetRefValue("btnEllipses")
	self.friendNewUComponent = objectReference:GetRefValue("friendNewUComponent")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.txtBtnBack = objectReference:GetRefValue("txtBtnBack")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
end

function BpExchangeView:registerObjects()
	return
end

function BpExchangeView:initView()
	return
end

return BpExchangeView
