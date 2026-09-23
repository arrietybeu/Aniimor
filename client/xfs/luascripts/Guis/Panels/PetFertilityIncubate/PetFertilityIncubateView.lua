-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubate\\PetFertilityIncubateView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityIncubateView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityIncubateView = Class.LightClass("PetFertilityIncubateView", UIView)

function PetFertilityIncubateView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitieUBaseText = self.objectReference:GetRefValue("txtTitieUBaseText")
	self.hintTxt = self.objectReference:GetRefValue("hintTxt")
	self.eggImage = self.objectReference:GetRefValue("eggImage")
	self.btnEgg1UButton = self.objectReference:GetRefValue("btnEgg1UButton")
	self.btnEgg2UButton = self.objectReference:GetRefValue("btnEgg2UButton")
	self.btnEgg3UButton = self.objectReference:GetRefValue("btnEgg3UButton")
	self.btnEgg4UButton = self.objectReference:GetRefValue("btnEgg4UButton")
	self.bubble1 = self.objectReference:GetRefValue("bubble1")
	self.bubble2 = self.objectReference:GetRefValue("bubble2")
	self.bubble3 = self.objectReference:GetRefValue("bubble3")
	self.bubble4 = self.objectReference:GetRefValue("bubble4")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.btnSkipUButton = self.objectReference:GetRefValue("btnSkipUButton")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
end

function PetFertilityIncubateView:registerObjects()
	return
end

function PetFertilityIncubateView:initView()
	self.btnEggList = {}
	self.bubbleList = {}

	for i = 1, 4 do
		local btn = self["btnEgg" .. i .. "UButton"]

		btn:TryChangePage("egg", i == 1 and 1 or 0)

		if btn then
			table.insert(self.btnEggList, btn)
		end

		local bubble = self["bubble" .. i]

		if bubble then
			table.insert(self.bubbleList, bubble)
		end
	end
end

return PetFertilityIncubateView
