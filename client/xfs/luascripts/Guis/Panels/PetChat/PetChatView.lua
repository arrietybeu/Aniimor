-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChat\\PetChatView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local PetChatView = Class.LightClass("PetChatView", UIView)
local LuaUIUtils = require("Utils.LuaUIUtils")

function PetChatView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")
	self.rootAni = self.objectReference:GetRefValue("rootAni")
	self.content = self.objectReference:GetRefValue("content")
end

function PetChatView:initView()
	self.root.gameObject:SetActiveEx(false)
end

return PetChatView
