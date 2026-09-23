-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBook\\HomeBookView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookView = Class.LightClass("HomeBookView", UIView)

function HomeBookView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnHomeProductUButton = objectReference:GetRefValue("btnHomeProductUButton")
	self.btnMutantCropsUButton = objectReference:GetRefValue("btnMutantCropsUButton")
	self.btnHomeBuildUButton = objectReference:GetRefValue("btnHomeBuildUButton")
	self.btnFurnitureUButton = objectReference:GetRefValue("btnFurnitureUButton")
	self.btnSeasonHarvestUButton = objectReference:GetRefValue("btnSeasonHarvestUButton")
	self.btnRatingUButton = objectReference:GetRefValue("btnRatingUButton")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.txtRatingUSDFText = objectReference:GetRefValue("txtRatingUSDFText")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.iconRewardUImage = objectReference:GetRefValue("iconRewardUImage")
	self.items = {
		self.btnHomeProductUButton,
		self.btnHomeBuildUButton,
		self.btnSeasonHarvestUButton,
		self.btnMutantCropsUButton,
		self.btnFurnitureUButton
	}
end

function HomeBookView:registerObjects()
	return
end

function HomeBookView:initView()
	return
end

return HomeBookView
