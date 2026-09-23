-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBall\\PetFertilityChooseBallView.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("PetFertilityChooseBallView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityChooseBallView = Class.LightClass("PetFertilityChooseBallView", UIView)

function PetFertilityChooseBallView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.topBackUWidget = self.objectReference:GetRefValue("topBackUWidget")
	self.rightPanelUWidget = self.objectReference:GetRefValue("rightPanelUWidget")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.listBallUList = self.objectReference:GetRefValue("listBallUList")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.txtBallNameUSDFText = self.objectReference:GetRefValue("txtBallNameUSDFText")
	self.txtDetailsUSDFText = self.objectReference:GetRefValue("txtDetailsUSDFText")
	self.imgSelBallIconUImage = self.objectReference:GetRefValue("imgSelBallIconUImage")
	self.txtBallName2USDFText = self.objectReference:GetRefValue("txtBallName2USDFText")
	self.txtDetails2USDFText = self.objectReference:GetRefValue("txtDetails2USDFText")
	self.eggPanelUComponent = self.objectReference:GetRefValue("eggPanelUComponent")
	self.selBallUWidget = self.objectReference:GetRefValue("selBallUWidget")
	self.selBallUComponent = self.selBallUWidget and self.selBallUWidget.transform:GetComponent("UComponent")
	self.ImgLineTs = self.selBallUWidget and self.selBallUWidget.transform:Find("ImgLine")
end

function PetFertilityChooseBallView:initView()
	return
end

return PetFertilityChooseBallView
