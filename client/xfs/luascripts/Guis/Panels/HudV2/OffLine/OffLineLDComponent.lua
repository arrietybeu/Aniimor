-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\OffLine\\OffLineLDComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local OffLineLDComponent = Class.LightClass("OffLineLDComponent", HudBaseComponent)

function OffLineLDComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.ballBarUWidget = objectReference:GetRefValue("ballBarUWidget")

	local btnChat = objectReference:GetRefValue("btnChat")
	local btnEmoticonUButton = objectReference:GetRefValue("btnEmoticonUButton")
	local btnEnterPhotoUButton = objectReference:GetRefValue("btnEnterPhotoUButton")

	btnChat.gameObject:SetActiveEx(false)
	btnEmoticonUButton.gameObject:SetActiveEx(false)
	btnEnterPhotoUButton.gameObject:SetActiveEx(false)
end

function OffLineLDComponent:initView()
	return
end

function OffLineLDComponent:bindComponent()
	self.ball = self:getBaseComponentCls("ball").new(self, self.ballBarUWidget.transform, {
		compName = "ball",
		needLoadRes = false
	})
end

return OffLineLDComponent
