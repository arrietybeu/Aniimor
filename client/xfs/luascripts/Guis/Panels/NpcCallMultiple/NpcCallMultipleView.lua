-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcCallMultiple\\NpcCallMultipleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NpcCallMultipleView = Class.LightClass("NpcCallMultipleView", UIView)

function NpcCallMultipleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnOnUButton = self.objectReference:GetRefValue("btnOnUButton")
	self.btnOffUButton = self.objectReference:GetRefValue("btnOffUButton")
	self.stateOffUWidget = self.objectReference:GetRefValue("stateOffUWidget")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.bgUImage = self.objectReference:GetRefValue("bgUImage")
	self.btnOnAnimation = self.objectReference:GetRefValue("btnOnAnimation")
	self.panePhoneAnimation = self.objectReference:GetRefValue("panePhoneAnimation")
	self.panelAvatarUComponent = self.objectReference:GetRefValue("avatarUComponent")
	self.panelAvatarAnimation = self.objectReference:GetRefValue("avatarAnimation")
	self.imgRoleUImage = self.objectReference:GetRefValue("imgRoleUImage")
	self.avatarName = self.objectReference:GetRefValue("txtNameUBaseText")
	self.keyNoKeyBindingPro = self.objectReference:GetRefValue("keyNoKeyBindingPro")
	self.keyYesKeyBindingPro = self.objectReference:GetRefValue("keyYesKeyBindingPro")
end

function NpcCallMultipleView:registerObjects()
	return
end

function NpcCallMultipleView:initView()
	return
end

return NpcCallMultipleView
