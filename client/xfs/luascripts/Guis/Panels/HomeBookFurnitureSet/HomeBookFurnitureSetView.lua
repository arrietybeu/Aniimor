-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookFurnitureSet\\HomeBookFurnitureSetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookFurnitureSetView = Class.LightClass("HomeBookFurnitureSetView", UIView)

function HomeBookFurnitureSetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.txtPrrogressUSDFText = objectReference:GetRefValue("txtPrrogressUSDFText")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.leftListTabUList = objectReference:GetRefValue("leftListTabUList")
	self.listSuitUList = objectReference:GetRefValue("listSuitUList")
	self.listCropsUList = objectReference:GetRefValue("listCropsUList")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.txtNumNowUSDFText = objectReference:GetRefValue("txtNumNowUSDFText")
	self.txtNumTotalUSDFText = objectReference:GetRefValue("txtNumTotalUSDFText")
	self.leftListTabTextUList = objectReference:GetRefValue("leftListTabTextUList")
end

function HomeBookFurnitureSetView:registerObjects()
	return
end

function HomeBookFurnitureSetView:initView()
	return
end

return HomeBookFurnitureSetView
