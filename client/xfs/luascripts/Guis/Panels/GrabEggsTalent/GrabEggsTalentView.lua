-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsTalent\\GrabEggsTalentView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsTalentView = Class.LightClass("GrabEggsTalentView", UIView)

function GrabEggsTalentView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.text1USDFText = objectReference:GetRefValue("text1USDFText")
	self.text1SubUSDFText = objectReference:GetRefValue("text1SubUSDFText")
	self.text2USDFText = objectReference:GetRefValue("text2USDFText")
	self.text2SubUSDFText = objectReference:GetRefValue("text2SubUSDFText")
	self.text3USDFText = objectReference:GetRefValue("text3USDFText")
	self.text3SubUSDFText = objectReference:GetRefValue("text3SubUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
end

return GrabEggsTalentView
