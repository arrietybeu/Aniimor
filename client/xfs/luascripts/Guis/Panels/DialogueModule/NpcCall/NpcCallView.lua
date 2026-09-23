-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\NpcCall\\NpcCallView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NpcCallView = Class.LightClass("NpcCallView", UIView)

function NpcCallView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.avatarName = self.objectReference:GetRefValue("avatarName")
	self.titleUText = self.objectReference:GetRefValue("titleUText")
	self.contentUText = self.objectReference:GetRefValue("contentUText")
	self.imgRoleUImage = self.objectReference:GetRefValue("imgRoleUImage")
	self.panelAvatarUComponent = self.objectReference:GetRefValue("panelAvatarUComponent")
	self.connectUText = self.objectReference:GetRefValue("connectUText")
	self.dialogueUWidget = self.objectReference:GetRefValue("dialogueUWidget")
	self.panelUComponent = self.objectReference:GetRefValue("panelUComponent")
end

function NpcCallView:registerObjects()
	return
end

function NpcCallView:initView()
	return
end

return NpcCallView
