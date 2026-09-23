-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioInvite\\PhotographyStudioInviteView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotographyStudioInviteView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotographyStudioInviteView = Class.LightClass("PhotographyStudioInviteView", UIView)

function PhotographyStudioInviteView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
	self.txtEmptyUBaseText = objectReference:GetRefValue("txtEmptyUBaseText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
end

function PhotographyStudioInviteView:registerObjects()
	return
end

function PhotographyStudioInviteView:initView()
	return
end

return PhotographyStudioInviteView
