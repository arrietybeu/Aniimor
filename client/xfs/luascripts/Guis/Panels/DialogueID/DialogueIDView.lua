-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueID\\DialogueIDView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DialogueIDView = Class.LightClass("DialogueIDView", UIView)

function DialogueIDView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.idText = objectReference:GetRefValue("idText")
end

return DialogueIDView
