-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelNameIn\\NpcDuelNameInView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NpcDuelNameInView = Class.LightClass("NpcDuelNameInView", UIView)

function NpcDuelNameInView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	self.textTtitleUBaseText = objectReference:GetRefValue("textTtitleUBaseText")
	self.panelTransform = objectReference:GetRefValue("panelTransform")
end

return NpcDuelNameInView
