-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChangeAvatar\\ChangeAvatarView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ChangeAvatarView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChangeAvatarView = Class.LightClass("ChangeAvatarView", UIView)

function ChangeAvatarView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.tltleUBaseText = self.objectReference:GetRefValue("tltleUBaseText")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnAvatarUButton = self.objectReference:GetRefValue("btnAvatarUButton")
	self.avatarNameUBaseText = self.objectReference:GetRefValue("avatarNameUBaseText")
	self.avatarGetInfoUBaseText = self.objectReference:GetRefValue("avatarGetInfoUBaseText")
	self.avatarListUList = self.objectReference:GetRefValue("avatarListUList")
	self.btnChangeUButton = self.objectReference:GetRefValue("btnChangeUButton")
	self.btnGoToGetUButton = self.objectReference:GetRefValue("btnGoToGetUButton")
end

function ChangeAvatarView:registerObjects()
	return
end

function ChangeAvatarView:initView()
	return
end

return ChangeAvatarView
