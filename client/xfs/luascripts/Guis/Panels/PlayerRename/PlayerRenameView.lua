-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerRename\\PlayerRenameView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerRenameView = Class.LightClass("PlayerRenameView", UIView)

function PlayerRenameView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnCloseMin = self.objectReference:GetRefValue("btnCloseMin")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.headList = self.objectReference:GetRefValue("headList")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.btnCloseNewUButton = self.objectReference:GetRefValue("btnCloseNewUButton")
	self.btnConfirmNewUButton = self.objectReference:GetRefValue("btnConfirmNewUButton")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function PlayerRenameView:registerObjects()
	return
end

function PlayerRenameView:initView()
	return
end

return PlayerRenameView
