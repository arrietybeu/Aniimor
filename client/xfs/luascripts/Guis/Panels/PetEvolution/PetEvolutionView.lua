-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolution\\PetEvolutionView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetEvolutionView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetEvolutionView = Class.LightClass("PetEvolutionView", UIView)

function PetEvolutionView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.tabList = self.objectReference:GetRefValue("tabList")
	self.evolutionUComponent = self.objectReference:GetRefValue("evolutionUComponent")
	self.tabLeft = self.objectReference:GetRefValue("tabLeft")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function PetEvolutionView:registerObjects()
	self.tabLeftOc = self.tabLeft.transform:GetComponent("ObjectReference")
	self.petManage = self.tabLeftOc:GetRefValue("petManage")
	self.tabPetList = self.tabLeftOc:GetRefValue("tabPetList")
	self.btnPetBox = self.tabLeftOc:GetRefValue("btnPetBox")
end

function PetEvolutionView:initView()
	return
end

return PetEvolutionView
