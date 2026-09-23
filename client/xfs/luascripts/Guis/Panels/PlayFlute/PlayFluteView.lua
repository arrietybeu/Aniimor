-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayFlute\\PlayFluteView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayFluteView = Class.LightClass("PlayFluteView", UIView)

function PlayFluteView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnPinkNoteUButton = objectReference:GetRefValue("btnPinkNoteUButton")
	self.btnGrayNoteUButton = objectReference:GetRefValue("btnGrayNoteUButton")
	self.btnBlueNoteUButton = objectReference:GetRefValue("btnBlueNoteUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
end

return PlayFluteView
