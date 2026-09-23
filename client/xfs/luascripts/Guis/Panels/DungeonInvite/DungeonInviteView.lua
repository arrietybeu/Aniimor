-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DungeonInvite\\DungeonInviteView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DungeonInviteView = Class.LightClass("DungeonInviteView", UIView)

function DungeonInviteView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.listInviteUList = objectReference:GetRefValue("listInviteUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	self.titleTextUSDFText = objectReference:GetRefValue("titleTextUSDFText")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	self.btnShareUButton = objectReference:GetRefValue("btnShareUButton")
	self.searchUWidget = objectReference:GetRefValue("searchUWidget")
end

function DungeonInviteView:registerObjects()
	return
end

function DungeonInviteView:initView()
	return
end

return DungeonInviteView
