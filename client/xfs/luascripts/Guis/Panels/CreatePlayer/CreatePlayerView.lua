-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayer\\CreatePlayerView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CreatePlayerView = Class.LightClass("CreatePlayerView", UIView)

function CreatePlayerView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.iAnimation = self.transform:GetComponent("Animation")
end

function CreatePlayerView:registerObjects()
	return
end

function CreatePlayerView:initView()
	return
end

return CreatePlayerView
